/*********************************************************************************************************************
Class Name    : Sales_SplitSeatsOnLicenseController
Version       : 1.0
Created Date  : July 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Saba Husain              July 2021         Created utility class for Sales_SplitSeatsOnLicense LWC
* *********************************************************************************************************************/
public inherited sharing class Sales_SplitSeatsOnLicenseController {
    @AuraEnabled
    public static Sales_License__c getLicenseRecord(Id licRecordId) {
        Sales_License__c licRecord = new Sales_License__c();
        try {
            if(licRecordId != null){
                licRecord = [Select Id,Sales_License_Contract__c,Sales_License_Order__c , Sales_License_Expiration_Date_Dt__c, Sales_License_Avbl_Qty_Nbr__c, Sales_License_Order_Product__c, Sales_License_Status__c, Sales_License_Product__c, Sales_License_Product__r.Name, Sales_License_Product__r.Core_OPN__c, 
                             Sales_License_Maintenance_Exp_Dt__c, Sales_License_Host_Node_Id__r.Name, Sales_License_Quantity__c, Sales_Tool_License_Type__c,
                             Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c from Sales_License__c where id = :licRecordId];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return licRecord;
    }
    @AuraEnabled
    public static List<Sales_License__c> splitLicenses(Sales_License__c licRecord, Integer noOfSeatsToSplit, Integer noOfServers){    
        Sales_SpliSeatsOnLicenseWithSharing sharedSplitSeatsCont = new Sales_SpliSeatsOnLicenseWithSharing();
        return sharedSplitSeatsCont.splitSourceLicenses(licRecord, noOfSeatsToSplit, noOfServers); 
    }
    @AuraEnabled
    public static List<Sales_License__c> returnSplitLicenses(Sales_License__c licRecord, Integer noOfSeatsToSplit, Integer noOfServers){    
        set<Id> licenseIdsSet = new set<Id>();
        List<Sales_License__c> licList = new List<Sales_License__c>();
        List<Sales_License__c> newLicenses = new List<Sales_License__c>();
        List<Sales_License_Order_Product__c> licOrdProdToUpdate = new List<Sales_License_Order_Product__c>();
        List<Id> newlicList1= new List<Id>();
        Set<Id> splittedLicId=new Set<Id>();
        try {
            List<Sales_License__c> licListToUpsert = new List<Sales_License__c>();
            if(licRecord != null){
                Sales_License__c licRecordToClone = [SELECT Id,Maintenance_Ended_in_last_365_days__c,Maintenance_ending_in_next_90_days__c,Name,OwnerId,RecordTypeId,Sales_Distributed_Quantity__c,Sales_Licensed_User_Email_Address__c,Sales_License_Account_Name_Txt__c,Sales_License_Account__c,Sales_License_Activation_Code__c,Sales_License_Available_Temp_Licenses__c,Sales_License_Avbl_Qty_Nbr__c,Sales_License_Avbl_Rehost_Nbr__c,Sales_License_Computer_Name__c,Sales_License_Contract_Txt__c,Sales_License_Contract__c,Sales_License_DelegateNames_Txt__c,Sales_License_Expiration_Date_Dt__c,Sales_License_Host_Node_Id__c,
                                                     Sales_License_Host_Node_Txt__c,Sales_License_Lic_User_Contact_ID__c,Sales_License_LoggedIn_User__c,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Number__c,Sales_License_Order_Product_Txt__c,Sales_License_Order_Product__c,Sales_License_Order_Txt__c,Sales_License_Order__c,Sales_License_Primary_Admin_Contact_Txt__c,Sales_License_Primary_Admin_Contact__c,Sales_License_Product_Name_Txt__c,Sales_License_Product_OPN__c,Sales_License_Product__c,Sales_License_Quantity__c,Sales_License_SAPLine_Nbr__c,Sales_License_Start_Date_Dt__c,
                                                     Sales_License_Status__c,Sales_License_SubscriptionId__c,Sales_License_Subscription_Name_Txt__c,Sales_License_Type__c,Sales_License_Web_Display_Flag__c,Sales_Lic_User_Contact_Txt__c,Sales_Parent_License_Name_Txt__c,Sales_Parent_License__c,Sales_SessionId_Bot__c,Sales_Tool_License_Type__c FROM Sales_License__c where id = :licRecord.id];
                licRecord.Sales_License_Order_Product__c= licRecordToClone.Sales_License_Order_Product__c;
                Integer qty = 0;
                if(noOfServers == 1){
                    qty = noOfSeatsToSplit;
                }else{
                    qty = 1;
                }
                List<Sales_License__c> newLicensesList = new List<Sales_License__c>();
                for(Integer i = 0; i < noOfServers; i++){
                    Sales_License__c newLicRecord = licRecordToClone.clone(false, true, false, false);
                    newLicRecord.Sales_License_Quantity__c = qty;
                    newLicRecord.OwnerId = UserInfo.getUserId();
                    if(newLicRecord.Sales_License_Status__c == 'Unlicensed'){
                        newLicRecord.Sales_License_Avbl_Qty_Nbr__c = qty;
                    }
                    if(licRecordToClone.Sales_License_Available_Temp_Licenses__c != null){
                        newLicRecord.Sales_License_Available_Temp_Licenses__c =  newLicRecord.Sales_License_Quantity__c;   
                    }
                    newLicensesList.add(newLicRecord);
                    licListToUpsert.add(newLicRecord);
                }
                licRecord.Sales_License_Quantity__c = licRecord.Sales_License_Quantity__c - noOfSeatsToSplit;
                if(licRecordToClone.Sales_License_Status__c == 'Unlicensed'){
                    licRecord.Sales_License_Avbl_Qty_Nbr__c = licRecord.Sales_License_Quantity__c;
                }
                if(licRecordToClone.Sales_License_Available_Temp_Licenses__c != null){
                    licRecord.Sales_License_Available_Temp_Licenses__c =  licRecord.Sales_License_Quantity__c;   
                }
                licListToUpsert.add(licRecord);
                List<Database.upsertResult> upsertResultList=Database.upsert(licListToUpsert,false);
                for(Database.upsertResult result:upsertResultList){
                    if (result.isSuccess() && result.isCreated()){
                        newlicList1.add(result.Id);
                    }
                }
                Map<OrderItem, List<Sales_License__c>> mapOfOrdProdLicListForLinking = new Map<OrderItem, List<Sales_LIcense__c>>();
                for(Sales_License__c lic: licListToUpsert){
                    if(lic.id != licRecord.id){
                        OrderItem ordProd = new OrderItem();
                        ordProd.id = lic.Sales_License_Order_Product__c;
                        licenseIdsSet.add(lic.id);   
                        if(mapOfOrdProdLicListForLinking.containsKey(ordProd)){
                            mapOfOrdProdLicListForLinking.get(ordProd).add(lic);
                        } else{
                            licList.add(lic);
                            splittedLicId.add(lic.Id);
                            mapOfOrdProdLicListForLinking.put(ordProd, licList);
                        }
                    }
                }
                for(Sales_License_Order_Product__c existinglicOrdProd: [Select Id, Sales_Order_Product__c, Sales_License_Expiration_Date_Dt__c, Sales_License_Order_Prod_Maint_Exp_Dt__c, Sales_License_ContractId__c from Sales_License_Order_Product__c where Sales_License__c = :licRecord.id and Sales_Order_Product__c != :licRecordToClone.Sales_License_Order_Product__c]){
                    for(Sales_License__c lic: newLicensesList){
                        Sales_License_Order_Product__c licOrdProd = new Sales_License_Order_Product__c();
                        licOrdProd.Sales_Order_Product__c = existinglicOrdProd.Sales_Order_Product__c;
                        licOrdProd.Sales_License_Expiration_Date_Dt__c = existinglicOrdProd.Sales_License_Expiration_Date_Dt__c;
                        licOrdProd.Sales_License_Order_Prod_Maint_Exp_Dt__c = existinglicOrdProd.Sales_License_Order_Prod_Maint_Exp_Dt__c;
                        licOrdProd.Sales_License_ContractId__c = existinglicOrdProd.Sales_License_ContractId__c;
                        licOrdProd.Sales_Quantity__c = lic.Sales_License_Quantity__c;
                        licOrdProd.Sales_License__c = lic.id;
                        licOrdProdToUpdate.add(licOrdProd);
                    }
                }
                insert licOrdProdToUpdate;
                licOrdProdToUpdate.clear();
                if(licenseIdsSet!=null && !licenseIdsSet.isEmpty()){
                    for(Sales_License__c lic : [select Id   ,  Sales_License_Maintenance_Exp_Dt__c, Sales_License_Expiration_Date_Dt__c,Sales_License_Avbl_Qty_Nbr__c,
                                                Sales_License_Status__c,Sales_License_Product__c,
                                                Sales_License_Product__r.Name   ,   Sales_License_Product__r.Core_OPN__c,Sales_License_Activation_Code__c,
                                                Sales_License_Web_Display_Flag__c,Sales_License_Host_Node_Id__c,Sales_License_Host_Node_Id__r.Name,Sales_License_Quantity__c,
                                                Sales_Tool_License_Type__c, Sales_License_Primary_Admin_Contact__c
                                                from Sales_License__c where id in :licenseIdsSet])
                    {
                        newLicenses.add(lic);
                    }
                }
                Sales_OrderProductTriggerUtility.createLicenseOrderProducts(null,mapOfOrdProdLicListForLinking,null);
                Set<Sales_License_Order_Product__c> licOrdProdToUpdateSet = new Set<Sales_License_Order_Product__c>();
                for(Sales_License_Order_Product__c licOrdProd : [Select Id,Sales_License__r.Sales_License_Quantity__c,Sales_License__r.Sales_License_Contract__c,Sales_Quantity__c,Sales_License_ContractId__c,Sales_License__c,Sales_License__r.Id from Sales_License_Order_Product__c where (Sales_License__c = :licRecordToClone.id or Sales_License__c =:newlicList1) and Sales_Order_Product__c = :licRecordToClone.Sales_License_Order_Product__c]){    
                    if(newlicList1.size()>0 && newlicList1.contains(licOrdProd.Sales_License__r.Id)) {
                        licOrdProd.Sales_Quantity__c=licOrdProd.Sales_License__r.Sales_License_Quantity__c;  
                        licOrdProd.Sales_License_ContractId__c = licOrdProd.Sales_License__r.Sales_License_Contract__c;
                    }
                    else
                    {licOrdProd.Sales_Quantity__c = licRecordToClone.Sales_License_Quantity__c-noOfSeatsToSplit;
                    }
                    licOrdProdToUpdateSet.add(licOrdProd); 
                } 
                licOrdProdToUpdate.addAll(licOrdProdToUpdateSet);
                update licOrdProdToUpdate;
            }
        }catch (DmlException ex) {
            throw new AurahandledException('' + ex.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }        
        return newLicenses;
    }
    @AuraEnabled
    public static List<Sales_License__c> newLicenseDetails(String ids){
        List<Id> licenseIdsSet = ids.split(';');
        List<Sales_License__c> newLicenses = new List<Sales_License__c>();
        if(licenseIdsSet!=null && !licenseIdsSet.isEmpty()){
            for(Sales_License__c lic : [select Id,Sales_License_Expiration_Date_Dt__c,Sales_License_Avbl_Qty_Nbr__c,Sales_Tool_License_Type__c, Sales_License_Primary_Admin_Contact__c,
                                        Sales_License_Status__c,Sales_License_Product__c,Sales_License_Product__r.Name,Sales_License_Product__r.Core_OPN__c,Sales_License_Activation_Code__c,Sales_License_Web_Display_Flag__c,Sales_License_Host_Node_Id__c,Sales_License_Host_Node_Id__r.Name,Sales_License_Quantity__c
                                        from Sales_License__c where id in :licenseIdsSet])
            {
                newLicenses.add(lic);
            }
        }
        return newLicenses;
    }
    @AuraEnabled
    public static List<Sales_License__c> getTargetLicensesForMerging(Id licRecordId){
        List<Sales_License__c> targetLicListToReturn;
        boolean isNotInCommunity = Sales_AddNewLicenseAdminController.isCommunity();
        if(isNotInCommunity){
            targetLicListToReturn = returnTargetLicensesForMerging(licRecordId);    
        }else{
            Sales_SpliSeatsOnLicenseWithSharing sharedSplitSeatsCont = new Sales_SpliSeatsOnLicenseWithSharing();
            targetLicListToReturn = sharedSplitSeatsCont.getTargetLicenses(licRecordId);  
        }
        return targetLicListToReturn;
    }
    @AuraEnabled
    public static List<Sales_License__c> returnTargetLicensesForMerging(Id licRecordId){
        List<Sales_License__c> targetLicListToReturn = new List<Sales_license__c>();
        List<Sales_License__c> targetLicensesList = new List<Sales_license__c>();
        Id sourceProductId;
        try {
            if(licRecordId != null){
                Boolean isNotInCommunity = Sales_AddNewLicenseAdminController.isCommunity();
                Set<Id> primaryAdminContactIdsSet = new Set<Id>();
                Sales_License__c sourceLicRec = [Select Id,Sales_License_Maintenance_Exp_Dt__c,  Sales_License_Expiration_Date_Dt__c, Sales_License_Primary_Admin_Contact__c, Sales_License_Product__c, Sales_License_Lic_User_Contact_ID__c,Sales_License_Type__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c  from Sales_License__c where Id = :licRecordId];
                if(sourceLicRec.Sales_License_Primary_Admin_Contact__c != null){
                    primaryAdminContactIdsSet.add(sourceLicRec.Sales_License_Primary_Admin_Contact__c);
                }
                if(sourceLicRec.Sales_License_Lic_User_Contact_ID__c != null){
                    primaryAdminContactIdsSet.add(sourceLicRec.Sales_License_Lic_User_Contact_ID__c);
                }
                for(Sales_License_Admin_Delegate__c admnDel: [Select Id,Sales_License_DlgAdmin_Contact__c,  Sales_License_PrimaryAdmin_Contact__c from Sales_License_Admin_Delegate__c where Sales_License_PrimaryAdmin_Contact__c = :sourceLicRec.Sales_License_Primary_Admin_Contact__c and Sales_License_isActive__c = true]){
                    if(admnDel.Sales_License_DlgAdmin_Contact__c != null){
                        primaryAdminContactIdsSet.add(admnDel.Sales_License_DlgAdmin_Contact__c);   
                    }
                }
                if(sourceLicRec.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c =='Add Seat'){
                    sourceProductId=sourceLicRec.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c ;
                }
                else{
                    sourceProductId=sourceLicRec.Sales_License_Product__c;
                }
                Date sourceExpDt = sourceLicRec.Sales_License_Maintenance_Exp_Dt__c; 
                String query = 'Select Id, Name, Sales_License_Web_Display_Flag__c, Sales_License_Available_Temp_Licenses__c, Sales_License_Status__c,UserRecordAccess.HasEditAccess, Sales_License_Order_Product__c, Sales_License_Avbl_Qty_Nbr__c, Sales_License_Quantity__c, Sales_License_Product__r.Core_OPN__c, Sales_License_Host_Node_Id__c,Sales_License_Host_Node_Id__r.Name,Sales_License_Expiration_Date_Dt__c, Sales_License_Maintenance_Exp_Dt__c, Sales_License_Comments_Txt__c  from Sales_License__c where Sales_License_Product__c = :sourceProductId';
                query = query + ' and (Sales_License_Maintenance_Exp_Dt__c = :sourceExpDt or (Sales_License_Maintenance_Exp_Dt__c < :sourceExpDt and Sales_License_Maintenance_Exp_Dt__c >= TODAY))';
                Boolean addClosingBracket = false;
                if(primaryAdminContactIdsSet.size() > 0){
                    query = query + ' and (Sales_License_Primary_Admin_Contact__c IN:primaryAdminContactIdsSet';                        
                    addClosingBracket = true;
                }
                if(sourceLicRec.Sales_License_Lic_User_Contact_ID__c != null){
                    query = query + ' or Sales_License_Lic_User_Contact_ID__c = \''+sourceLicRec.Sales_License_Lic_User_Contact_ID__c+'\'';
                }
                if (addClosingBracket == true){
                    query = query + ')';        
                }
                query = query + ' and (Sales_License_Expiration_Date_Dt__c = null or Sales_License_Expiration_Date_Dt__c >= TODAY)';
                query = query + ' and Sales_License_Type__c  NOT IN (\'Optional\', \'Evaluation\',\'RENEWAL\') and Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c != \'RENEWAL\' and Sales_Tool_License_Type__c IN (\'Float\', \'Neutral\', \'N-A\') and id  != :licRecordId and (Sales_License_Quantity__c > 0) AND Sales_License_Status__c !=\'Cancelled\' AND Sales_License_Status__c !=\'Renewals Applied\'';                 
                targetLicensesList =  Database.query(query); 
                if(isNotInCommunity == false){
                    for(Sales_License__c lic: targetLicensesList){
                        if(lic.Sales_License_Web_Display_Flag__c == true){
                            targetLicListToReturn.add(lic);    
                        }
                    }
                }else{
                    targetLicListToReturn.addAll(targetLicensesList);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return targetLicListToReturn;
    }
    @AuraEnabled
    public static List<Sales_License__c> mergeLicenseRecords(Integer noOfSeatsToMerge, Sales_License__c sourceLicRec, Sales_License__c targetLicRec){
        Sales_SpliSeatsOnLicenseWithSharing sharedSplitSeatsCont = new Sales_SpliSeatsOnLicenseWithSharing();
        return sharedSplitSeatsCont.mergeLicense(noOfSeatsToMerge, sourceLicRec, targetLicRec);  
    }
    @AuraEnabled
    public static List<Sales_License__c> mergeLicenseRec(Integer noOfSeatsToMerge, Sales_License__c sourceLicRec, Sales_License__c targetLicRec){
        Map<Id, Sales_License__c> licMapToUpdate = new Map<Id, Sales_License__c>();        
        Map<OrderItem, List<Sales_License__c>> mapOfOrdProdLicListLink= new  Map<OrderItem, List<Sales_License__c>>();
        List<Sales_License__c> baselicList = new List<Sales_License__c>();
        List<Sales_License__c> licRecordListToUpsert = new List<Sales_License__c>();
        Map<Id,Sales_License__c> licRecordMaptoUpsert= new Map<Id, Sales_License__c>();
        Set<Sales_License__c> targetLicOpnLicSet= new Set<Sales_License__c>();
        List<Sales_License__c> targetLicOpnLicList= new List<Sales_License__c>();
        try {
            Set<id> orderPrdIds = new Set<Id>();
            List<Sales_License_Order_Product__c> licOrdProdToUpdate = new List<Sales_License_Order_Product__c>();
            Set<Sales_License_Order_Product__c> licOrdProdToUpdateSet = new Set<Sales_License_Order_Product__c>();
            if(sourceLicRec != null && targetLicRec != null){
                targetLicRec = [SELECT Sales_License_Comments_Txt__c,Id,Maintenance_Ended_in_last_365_days__c,Maintenance_ending_in_next_90_days__c,Name,OwnerId,RecordTypeId,Sales_Distributed_Quantity__c,Sales_Licensed_User_Email_Address__c,Sales_License_Account_Name_Txt__c,Sales_License_Account__c,Sales_License_Activation_Code__c,Sales_License_Available_Temp_Licenses__c,Sales_License_Avbl_Qty_Nbr__c,Sales_License_Avbl_Rehost_Nbr__c,Sales_License_Computer_Name__c,Sales_License_Contract_Txt__c,Sales_License_Contract__c,Sales_License_DelegateNames_Txt__c,Sales_License_Expiration_Date_Dt__c,Sales_License_Host_Node_Id__c,
                                Sales_License_Host_Node_Txt__c,Sales_License_Lic_User_Contact_ID__c,Sales_License_LoggedIn_User__c,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Number__c,Sales_License_Order_Product_Txt__c,Sales_License_Order_Product__c,Sales_License_Order_Txt__c,Sales_License_Order__c,Sales_License_Primary_Admin_Contact_Txt__c,Sales_License_Primary_Admin_Contact__c,Sales_License_Product_Name_Txt__c,Sales_License_Product_OPN__c,Sales_License_Product__c,Sales_License_Quantity__c,Sales_License_SAPLine_Nbr__c,Sales_License_Start_Date_Dt__c,
                                Sales_License_Status__c,Sales_License_SubscriptionId__c,Sales_License_Subscription_Name_Txt__c,Sales_License_Type__c,Sales_License_Web_Display_Flag__c,Sales_Lic_User_Contact_Txt__c,Sales_Parent_License_Name_Txt__c,Sales_Parent_License__c,Sales_SessionId_Bot__c,Sales_Tool_License_Type__c FROM Sales_License__c where id = :targetLicRec.id];
                Integer qty  = (Integer)sourceLicRec.Sales_License_Quantity__c  - noOfSeatsToMerge; 
                String msg = noOfSeatsToMerge + ' seats merged into license ' + targetLicRec.Name; 
                sourceLicRec = updateLicenseRecord(sourceLicRec, qty, msg, true);
                Sales_License__c licenseOrderProduct=[select id,Sales_License_Order_Product__c from Sales_License__c where id = :sourceLicRec.id];
                if(sourceLicRec.Sales_License_Host_Node_Id__c != null && sourceLicRec.Sales_License_Host_Node_Id__c != targetLicRec.Sales_License_Host_Node_Id__c && sourceLicRec.Sales_License_Avbl_Rehost_Nbr__c != null){
                    sourceLicRec.Sales_License_Avbl_Rehost_Nbr__c = sourceLicRec.Sales_License_Avbl_Rehost_Nbr__c - 1;
                }
                orderPrdIds.add(licenseOrderProduct.Sales_License_Order_Product__c);
                licMapToUpdate.put(sourceLicRec.id, sourceLicRec);
                qty  = (Integer)targetLicRec.Sales_License_Quantity__c + noOfSeatsToMerge; 
                msg = noOfSeatsToMerge + ' seats merged from license ' + sourceLicRec.Name; 
                targetLicRec = updateLicenseRecord(targetLicRec, qty, msg, false);
                if(targetLicRec.Sales_License_Maintenance_Exp_Dt__c > Date.today() && targetLicRec.Sales_License_Maintenance_Exp_Dt__c < sourceLicRec.Sales_License_Maintenance_Exp_Dt__c){
                    Integer differenceInMonths = targetLicRec.Sales_License_Maintenance_Exp_Dt__c.monthsBetween(sourceLicRec.Sales_License_Maintenance_Exp_Dt__c);
                    Integer extraMaintenanceForExtraSeats = noOfSeatsToMerge * differenceInMonths;
                    Integer extraMaintForEachSeat = (Integer) (extraMaintenanceForExtraSeats / targetLicRec.Sales_License_Quantity__c).round(System.RoundingMode.CEILING);
                    targetLicRec.Sales_License_Maintenance_Exp_Dt__c = Sales_LicenseTriggerUtility.getLastDateOfMonth((targetLicRec.Sales_License_Maintenance_Exp_Dt__c).addMonths(extraMaintForEachSeat));                    
                }
                if(sourceLicRec.Sales_License_Expiration_Date_Dt__c != null && targetLicRec.Sales_License_Expiration_Date_Dt__c != null &&  targetLicRec.Sales_License_Maintenance_Exp_Dt__c > Date.today() && targetLicRec.Sales_License_Maintenance_Exp_Dt__c < sourceLicRec.Sales_License_Maintenance_Exp_Dt__c){
                    Integer differenceInMonths = targetLicRec.Sales_License_Expiration_Date_Dt__c.monthsBetween(sourceLicRec.Sales_License_Expiration_Date_Dt__c);
                    Integer extraMaintenanceForExtraSeats = noOfSeatsToMerge * differenceInMonths;
                    Integer extraMaintForEachSeat = (Integer) (extraMaintenanceForExtraSeats / targetLicRec.Sales_License_Quantity__c).round(System.RoundingMode.CEILING);
                    date sampledate ;
                    sampledate = targetLicRec.Sales_License_Expiration_Date_Dt__c.addMonths(extraMaintForEachSeat);
                    if(sampledate.day() == 1){
                        targetLicRec.Sales_License_Expiration_Date_Dt__c = (targetLicRec.Sales_License_Expiration_Date_Dt__c).addMonths(extraMaintForEachSeat);
                    } 
                    else {
                        targetLicRec.Sales_License_Expiration_Date_Dt__c = Sales_LicenseTriggerUtility.getLastDateOfMonth((targetLicRec.Sales_License_Expiration_Date_Dt__c).addMonths(extraMaintForEachSeat)).addDays(1);
                    }
                }
                orderPrdIds.add(targetLicRec.Sales_License_Order_Product__c);
                licMapToUpdate.put(targetLicRec.id, targetLicRec);
                licRecordMaptoUpsert.putAll(licMapToUpdate);
                Set<Id> targetOptnLicProdIdSet = new Set<Id>();
                Set<Id> sourceOptnLicProdIdSet = new Set<Id>();
                for(Sales_License__c optnLic : [Select Id,Sales_License_Avbl_Rehost_Nbr__c,Sales_License_Status__c, Sales_License_Expiration_Date_Dt__c, Sales_License_Comments_Txt__c, Sales_License_Product__c,Sales_License_Available_Temp_Licenses__c, Sales_License_Host_Node_Id__c, Sales_License_Quantity__c, Sales_License_Avbl_Qty_Nbr__c, Sales_Parent_License__c, Sales_License_Maintenance_Exp_Dt__c from Sales_License__c where Sales_Parent_License__c IN: licMapToUpdate.keyset()]){
                    if(optnLic.Sales_Parent_License__c == targetLicRec.id){
                        targetOptnLicProdIdSet.add(optnLic.Sales_License_Product__c);
                        qty = (Integer)targetLicRec.Sales_License_Quantity__c;
                        msg = noOfSeatsToMerge + ' seats merged from license ' + sourceLicRec.Name; 
                        optnLic = updateLicenseRecord(optnLic, qty, msg, false);
                        optnLic.Sales_License_Maintenance_Exp_Dt__c = targetLicRec.Sales_License_Maintenance_Exp_Dt__c;
                        optnLic.Sales_License_Expiration_Date_Dt__c = targetLicRec.Sales_License_Expiration_Date_Dt__c;
                    }else{
                        sourceOptnLicProdIdSet.add(optnLic.Sales_License_Product__c);
                        qty = (Integer)sourceLicRec.Sales_License_Quantity__c;
                        msg = noOfSeatsToMerge + ' seats merged into license ' + targetLicRec.Name;
                        optnLic = updateLicenseRecord(optnLic, qty, msg, true);
                        if(optnLic.Sales_License_Host_Node_Id__c !=null && optnLic.Sales_License_Host_Node_Id__c != targetLicRec.Sales_License_Host_Node_Id__c){
                            optnLic.Sales_License_Avbl_Rehost_Nbr__c = optnLic.Sales_License_Avbl_Rehost_Nbr__c - 1;
                        }                       
                    }
                    licRecordMaptoUpsert.put(optnLic.id,optnLic);
                    licMapToUpdate.put(optnLic.id,optnLic);
                }              
                Set<Id> prodIdSetForOptnLic = new Set<Id>();
                for(Id sourceOptnLicProdId: sourceOptnLicProdIdSet){
                    if(!targetOptnLicProdIdSet.contains(sourceOptnLicProdId)){
                        prodIdSetForOptnLic.add(sourceOptnLicProdId);
                    }
                }               
                if(!prodIdSetForOptnLic.isEmpty()){
                    for(Id prodId :prodIdSetForOptnLic){
                        Sales_License__c licRecord = new Sales_License__c();
                        licRecord.Sales_License_Quantity__c = targetLicRec.Sales_License_Quantity__c;
                        licRecord.Sales_License_Avbl_Qty_Nbr__c = targetLicRec.Sales_License_Avbl_Qty_Nbr__c;                        
                        licRecord.Sales_License_Status__c=targetLicRec.Sales_License_Status__c;
                        licRecord.Sales_License_Product__c=prodId;
                        licRecord.Sales_License_Expiration_Date_Dt__c=targetLicRec.Sales_License_Expiration_Date_Dt__c;
                        licRecord.Sales_License_Maintenance_Exp_Dt__c=targetLicRec.Sales_License_Maintenance_Exp_Dt__c;
                        licRecord.Sales_License_Primary_Admin_Contact__c = targetLicRec.Sales_License_Primary_Admin_Contact__c;
                        licRecord.Sales_Parent_License__c = targetLicRec.Id;
                        licRecord.Sales_License_Web_Display_Flag__c = false;
                        licRecord.Sales_License_Avbl_Rehost_Nbr__c=targetLicRec.Sales_License_Avbl_Rehost_Nbr__c;
                        licRecord.Sales_License_Activation_Code__c=targetLicRec.Sales_License_Activation_Code__c;
                        licRecord.Sales_License_Type__c='Optional';
                        licRecord.Sales_License_SAPLine_Nbr__c=targetLicRec.Sales_License_SAPLine_Nbr__c;
                        licRecord.Sales_License_Contract__c=targetLicRec.Sales_License_Contract__c; 
                        licRecord.Sales_License_Order_Product__c=targetLicRec.Sales_License_Order_Product__c;
                        licRecord.Sales_License_Order__c=targetLicRec.Sales_License_Order__c;
                        licRecord.Sales_License_Account__c=targetLicRec.Sales_License_Account__c;
                        targetLicOpnLicSet.add(licRecord);
                        targetLicOpnLicList.add(licRecord); 
                    }
                }
                for(Sales_License_Order_Product__c licOrdProd : [Select Id, Sales_License__c, Sales_License_Expiration_Date_Dt__c, Sales_License_Order_Prod_Maint_Exp_Dt__c, Sales_Quantity__c, Sales_Order_Product__c from Sales_License_Order_Product__c where Sales_Order_Product__c IN: orderPrdIds and Sales_License__c IN : licMapToUpdate.keyset()]){
                    licOrdProd.Sales_Quantity__c = licRecordMaptoUpsert.get(licOrdProd.Sales_License__c).Sales_License_Quantity__c;
                    licOrdProd.Sales_License_Expiration_Date_Dt__c = licRecordMaptoUpsert.get(licOrdProd.Sales_License__c).Sales_License_Expiration_Date_Dt__c;
                    licOrdProd.Sales_License_Order_Prod_Maint_Exp_Dt__c = licRecordMaptoUpsert.get(licOrdProd.Sales_License__c).Sales_License_Maintenance_Exp_Dt__c;
                    licOrdProdToUpdateSet.add(licOrdProd);
                    if(licOrdProd.Sales_License__c == targetLicRec.id){
                        licOrdProd.Sales_Renewable_license__c = sourceLicRec.id;
                    }
                }
                licRecordListToUpsert.addAll(licRecordMaptoUpsert.values());
                licRecordListToUpsert.addAll(targetLicOpnLicSet);
                upsert licRecordListToUpsert;
                licOrdProdToUpdate.addAll(licOrdProdToUpdateSet);
                update licOrdProdToUpdate;
                baselicList.add(targetLicRec);
                OrderItem orderitemrecord =new OrderItem();
                orderitemrecord.id = targetLicRec.Sales_License_Order_Product__c;
                mapOfOrdProdLicListLink.put(orderitemrecord,targetLicOpnLicList);
                Sales_OrderProductTriggerUtility.createLicenseOrderProducts(null,mapOfOrdProdLicListLink,null);
            }
        }catch (DmlException ex) {
            throw new AurahandledException('' + ex.getDmlMessage(0));
        }    
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return licMapToUpdate.values();
    }
    private static Sales_License__c updateLicenseRecord(Sales_License__c licRec, Integer qty, String msg, Boolean isSource){
        if(licRec != null){
            licRec.Sales_License_Quantity__c = qty;
            if(licRec.Sales_License_Available_Temp_Licenses__c != null){
                licRec.Sales_License_Available_Temp_Licenses__c = qty;
            }
            if(licRec.Sales_License_Status__c == 'Unlicensed'){
                licRec.Sales_License_Avbl_Qty_Nbr__c = qty; 
            }
            if(licRec.Sales_License_Quantity__c == 0 && isSource == true){
                licRec.Sales_License_Web_Display_Flag__c = false;
                licRec.Sales_License_Status__c = 'Merged';
            }       
            if(licRec.Sales_License_Comments_Txt__c != null){
                licRec.Sales_License_Comments_Txt__c  = licRec.Sales_License_Comments_Txt__c + '\n';
            }else{
                licRec.Sales_License_Comments_Txt__c  = '';
            }
            licRec.Sales_License_Comments_Txt__c = licRec.Sales_License_Comments_Txt__c + msg;
        }          
        return licRec;
    }                                                  
    private without sharing class Sales_SpliSeatsOnLicenseWithSharing{
        public List<Sales_License__c> getTargetLicenses(id licRecordId){
            return returnTargetLicensesForMerging(licRecordId);
        } 
        public List<Sales_License__c>mergeLicense(Integer noOfSeatsToMerge, Sales_License__c sourceLicRec, Sales_License__c targetLicRec){
            return mergeLicenseRec(noOfSeatsToMerge, sourceLicRec, targetLicRec);
        }
        public List<Sales_License__c> splitSourceLicenses(Sales_License__c licRecord, Integer noOfSeatsToSplit, Integer noOfServers){
            return returnSplitLicenses(licRecord, noOfSeatsToSplit, noOfServers);   
        }
    }
}