/*********************************************************************************************************************
Class Name    : Sales_LicenseTriggerUtility
Version       : 1.0
Created Date  : March 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Saba Husain           9-Mar-2021              License Trigger Utility
* Shivam Vishwakarma    18-Mar-2021             For US942963: Added License Activation Code Generation Logic using Crypto Library
* *********************************************************************************************************************/
public without sharing class Sales_LicenseTriggerUtility{
    private static final String STATUS_RENEWALS_APPLIED = 'Renewals Applied';
    private static final String OPTIONAL_LICENSE = 'Optional';
    private static final String ARM_PRODUCT_CLASS_VALUE = 'SV';
    private static final String ARM_PRODUCT_SUBCATEGORY_VALUE = 'A';
    private static final String ORDER_TYPE_NONCOMMERCIAL='Non Commercial Order';
    private static final String ORDER_STATUS_ACTIVATED='Activated';
    private static final String QUOTE_TYPE='Quote';
    private static final string ORIGIN = 'Sales_LicenseTriggerUtility';
    private static final string SEVERITY = 'info';
    private static final string PROJECT = 'Sales';
    public static Map<id, id> contactUserIdMap;
    public static void updateExpiryDatesonLicense(List<Sales_License__c> newlicList, Map<Id, OrderItem> ordItmMap, Map<Id, Product2> prodMap){
        date licfirstdate ;
        Integer prodExpiryDurationInDays;
        Integer prodMaintExpSubTermInMonths;
        Map<Id, Contract> contMap = new Map<Id, Contract>();
        List<Sales_License_Order_Product__c> licOrdPrdList =  new List<Sales_License_Order_Product__c>();
        Map<Id, Sales_License_Order_Product__c> licIdLicOrdProdMap = new Map<Id, Sales_License_Order_Product__c>();
        for(Sales_License_Order_Product__c licOrdPrd: [Select Id, Sales_Order_Product__r.SBQQ__SubscriptionTerm__c,Sales_Order_Product__r.Order.Type, Sales_License__c,Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c, Sales_Order_Product__r.Order.SBQQ__Quote__r.SBQQ__Type__c, Sales_Order_Product__r.Order.SBQQ__Quote__r.SBQQ__MasterContract__c, Sales_License_Expiration_Date_Dt__c, Sales_License_Order_Prod_Maint_Exp_Dt__c from Sales_License_Order_Product__c where Sales_Order_Product__c IN: ordItmMap.keySet()]){
            licIdLicOrdProdMap.put(licOrdPrd.Sales_License__c, licOrdPrd);
        }     
        for(Sales_License__c lic: newlicList){
            if(lic.Sales_License_Start_Date_Dt__c != null){ 
                prodExpiryDurationInDays = null;
                prodMaintExpSubTermInMonths = null;
                licfirstdate = null;
                if((Integer)prodMap.get(lic.Sales_License_Product__c)?.Core_Product_Ext_Attribute_Id__r?.Core_SW_Prod_Expiration_Duration_Nbr__c!=null){
                    prodExpiryDurationInDays = (Integer)prodMap.get(lic.Sales_License_Product__c)?.Core_Product_Ext_Attribute_Id__r?.Core_SW_Prod_Expiration_Duration_Nbr__c;    
                }
                prodMaintExpSubTermInMonths = (Integer)prodMap.get(lic.Sales_License_Product__c)?.SBQQ__SubscriptionTerm__c;
                if(lic.Sales_License_Start_Date_Dt__c != null && ordItmMap.containsKey(lic.Sales_License_Order_Product__c) && !(Trigger.isupdate && ordItmMap.get(lic.Sales_License_Order_Product__c)?.Order.Sales_Order_Sub_Type__c == System.label.Sales_CorporateOrder_SubType )){
                    if(prodExpiryDurationInDays!=null){
                        licfirstdate = lic.Sales_License_Start_Date_Dt__c.addDays(prodExpiryDurationInDays);
                    }
                    if(prodExpiryDurationInDays != null && !Trigger.IsInsert){
                        if  (licfirstdate!= null && licfirstdate.day() ==1  ) {                            
                            lic.Sales_License_Expiration_Date_Dt__c =  lic.Sales_License_Start_Date_Dt__c.addDays(prodExpiryDurationInDays);                                     
                        }
                        else{
                            lic.Sales_License_Expiration_Date_Dt__c =  getLastDateOfMonth(lic.Sales_License_Start_Date_Dt__c.addDays(prodExpiryDurationInDays)).addDays(1);                                      
                        }
                    }
                    if(prodMaintExpSubTermInMonths != null && (Trigger.IsUpdate || Trigger.IsInsert && lic.Sales_License_Maintenance_Exp_Dt__c == null) ){
                        lic.Sales_License_Maintenance_Exp_Dt__c =  getLastDateOfMonth(lic.Sales_License_Start_Date_Dt__c.addMonths(prodMaintExpSubTermInMonths));
                    }               
                    Sales_License_Order_Product__c licOrdProd = licIdLicOrdProdMap.get(lic.id); 
                    if(licOrdProd != null){
                        licOrdProd.Sales_License_Expiration_Date_Dt__c = lic.Sales_License_Expiration_Date_Dt__c;
                        licOrdProd.Sales_License_Order_Prod_Maint_Exp_Dt__c = lic.Sales_License_Maintenance_Exp_Dt__c;
                        licOrdPrdList.add(licOrdProd);
                    }
                }else if(lic.Sales_License_Start_Date_Dt__c != null && 
                         ordItmMap.containsKey(lic.Sales_License_Order_Product__c) && 
                         ordItmMap.get(lic.Sales_License_Order_Product__c)?.Order.Sales_Order_Sub_Type__c == System.label.Sales_CorporateOrder_SubType &&
                         ordItmMap.get(lic.Sales_License_Order_Product__c)?.Order.SBQQ__Quote__r.SBQQ__Type__c == QUOTE_TYPE &&
                         ordItmMap.get(lic.Sales_License_Order_Product__c)?.Order.Status == ORDER_STATUS_ACTIVATED && 
                         ordItmMap.get(lic.Sales_License_Order_Product__c)?.Order.Type == ORDER_TYPE_NONCOMMERCIAL){
                             Contract con = new Contract();
                             con.id = ordItmMap.get(lic.Sales_License_Order_Product__c)?.SBQQ__Contract__c;
                             contMap.put(con.id, con);
                         }
            }
        }
        if(!licOrdPrdList.IsEmpty()){
            update licOrdPrdList;
        }  
        if(!contMap.isEmpty()){
        }
    }
    public static Date getLastDateOfMonth(Date dt){
        Date result;
        Integer noOfDays;
        if(dt != null){
            noOfDays = Date.daysInMonth(dt.year(), dt.month());
            result = date.newInstance(dt.year(), dt.month(), noOfDays);
        }   
        return result;
    }
    public static String mdFiveHashAsLicenseActivationCode(){        
        String stringToHash = String.valueOf(Math.abs(Crypto.getRandomLong())) + String.valueOf(Datetime.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hashDigest = Crypto.generateDigest('MD5', Blob.valueOf(stringToHash));
        String uniqueString = EncodingUtil.convertToHex(hashDigest).toUpperCase();
        return uniqueString; 
    }
    public static void cancelLicense(Id orderid){
        Set<Id> contractIdsSet = new Set<Id>();
        List<Sales_License__c> licListToUpdate = new List<Sales_License__c>();
        Map<Id, Sales_License_Order_Product__c> mapOfLicIdLicOrdProd = new Map<Id, Sales_License_Order_Product__c>();
        List<Sales_License__c> licenseList = [Select Id,Sales_License_Status__c,Sales_License_Contract__c,Sales_License_Order_Product__r.SBQQ__Contract__c from Sales_License__c Where Sales_License_Order__c =: orderid];
        for(Sales_License__c sL:licenseList ){
            contractIdsSet.add(sL.Sales_License_Contract__c);
            contractIdsSet.add(sL.Sales_License_Order_Product__r.SBQQ__Contract__c);
        }
        for(Sales_License_Order_Product__c olderlicOrdProd: [Select id, Sales_Order_Product__r.OrderId, Sales_License_ContractId__c,Sales_License_ContractId__r.StartDate,Sales_Order_Product__r.SBQQ__Contract__c, Sales_License__c from Sales_License_Order_Product__c where Sales_License__c IN: licenseList and Sales_Order_Product__r.SBQQ__Contract__c != null and Sales_License__r.Sales_License_Status__c!= 'Cancelled' order by Sales_License_ContractId__r.enddate]){
            if(!contractIdsSet.contains(olderlicOrdProd.Sales_License_ContractId__c) && !mapOfLicIdLicOrdProd.containsKey(olderlicOrdProd.Sales_License__c)){
                mapOfLicIdLicOrdProd.put(olderlicOrdProd.Sales_License__c, olderlicOrdProd);
            }
        }
        for(Sales_License__c lic: licenseList){
            if(mapOfLicIdLicOrdProd.containsKey(lic.Id)){
                lic.Sales_License_Order_Product__c = mapOfLicIdLicOrdProd.get(lic.Id).Sales_Order_Product__c;
                lic.Sales_License_Start_Date_Dt__c = mapOfLicIdLicOrdProd.get(lic.Id).Sales_License_ContractId__r?.StartDate;
                lic.Sales_License_Order__c = mapOfLicIdLicOrdProd.get(lic.Id).Sales_Order_Product__r.OrderId;
                lic.Sales_License_Contract__c = mapOfLicIdLicOrdProd.get(lic.Id).Sales_License_ContractId__r.Id;
                lic.Sales_License_Status__c = 'Cancelled';
                lic.Sales_License_Web_Display_Flag__c = false;
            }else{
                lic.Sales_License_Status__c = 'Cancelled';
                lic.Sales_License_Web_Display_Flag__c = false;
            }
            licListToUpdate.add(lic);
        }
        if(!licListToUpdate.IsEmpty()){
            update licListToUpdate;
        }
    }
    public static void updatefieldForListViewFilter(List<Sales_License__c> licUpdateList){
        List<Sales_License__c> updateLicenseList=new List<Sales_License__c>();
        for(Sales_License__c licUpdate:licUpdateList){
            licUpdate.Sales_License_Account_Name_Txt__c=licUpdate.Sales_License_Account__r.Name;
            licUpdate.Sales_License_Order_Txt__c=licUpdate.Sales_License_Order__r.OrderNumber;
            licUpdate.Sales_License_Product_Name_Txt__c=licUpdate.Sales_License_Product__r.Name;
            licUpdate.Sales_Lic_User_Contact_Txt__c=licUpdate.Sales_License_Lic_User_Contact_ID__r.Name;
            licUpdate.Sales_License_Host_Node_Txt__c=licUpdate.Sales_License_Host_Node_Id__r.Name;
            licUpdate.Sales_License_Contract_Txt__c=licUpdate.Sales_License_Contract__r.ContractNumber;
            licUpdate.Sales_Parent_License_Name_Txt__c=licUpdate.Sales_Parent_License__r.Name;
            licUpdate.Sales_License_PriAdm_Email__c=licUpdate.Sales_License_Primary_Admin_Contact__r.Email;
            licUpdate.Licensed_User_Email_Address_Txt__c=licUpdate.Sales_License_Lic_User_Contact_ID__r.Email;
            licUpdate.Sales_License_Primary_Admin_Contact_Txt__c = licUpdate.Sales_License_Primary_Admin_Contact__r.Name;
            if(licUpdate.Sales_License_Type__c =='Evaluation'){
                licUpdate.Sales_License_SAPLine_Nbr__c=null;
            }
            updateLicenseList.add(licUpdate);
        }
        update updateLicenseList;
    }
    public static void shareLicenseRecordsWithDelegates(List<Sales_License__c> licList , Map<Id,Sales_License__c> oldLicMap){   
        Set<id> contactIdsForAdminDelegate = new Set<id>();
        Map<Id,List<Id>> primaryAdminsDelegatesMap = new Map<Id,List<Id>>();
        Map<Id,List<Id>> GrantAccessMap = new Map<Id,List<Id>>();   
        Map<Id,List<Id>> RevokeAccessMap = new Map<Id,List<Id>>();
        Map<Id,List<Id>> RevokeLicenseAccessForUsersMap = new Map<Id,List<Id>>();
        Map<Id,List<Id>> GrantLicenseAccessForUsersMap = new Map<Id,List<Id>>();
        Map<Id,Id> primaryAdminDelegateUsrMap = new Map<Id,Id>();           
        set<Id> contIds = new Set<Id>();                                    
        Set<Id>  delegateAdminIdSet = new Set<Id>();
        set<Id> licensecontactuser= new set<Id>();
        Boolean isAfterInsert, isAfterUpdate;
        if(oldLicMap==null){
            isAfterInsert = true;
            isAfterUpdate = false;    
        }else{
            isAfterInsert = false;
            isAfterUpdate = true;    
        }
        for(Sales_License__c lic: licList){
            if(lic.Sales_License_Primary_Admin_Contact__c != null){
                contactIdsForAdminDelegate.add(lic.Sales_License_Primary_Admin_Contact__c);     
            }
            if(oldLicMap != null && oldLicMap.get(lic.id).Sales_License_Primary_Admin_Contact__c != null){
                contactIdsForAdminDelegate.add(oldLicMap.get(lic.id).Sales_License_Primary_Admin_Contact__c);     
            }
            if(lic.Sales_License_Lic_User_Contact_ID__c != null||(oldLicMap != null && oldLicMap.get(lic.id).Sales_License_Lic_User_Contact_ID__c!=null)){
                if(lic.Sales_License_Lic_User_Contact_ID__c != null){
                    licensecontactuser.add(lic.Sales_License_Lic_User_Contact_ID__c);                    
                }
                else{
                    licensecontactuser.add(oldLicMap.get(lic.id).Sales_License_Lic_User_Contact_ID__c); 
                }
            }
        }
        List<Sales_License_Admin_Delegate__c> allDelegateAdminsList = [SELECT Id, Sales_License_PrimaryAdmin_Contact__c, Sales_License_DlgAdmin_Contact__c  
                                                                       FROM Sales_License_Admin_Delegate__c WHERE Sales_License_isActive__c=true and Sales_License_PrimaryAdmin_Contact__c IN: contactIdsForAdminDelegate];
        for( Sales_License_Admin_Delegate__c delegateRecord : allDelegateAdminsList ){
            contIds.add(delegateRecord.Sales_License_PrimaryAdmin_Contact__c);
            if(primaryAdminsDelegatesMap.containsKey(delegateRecord.Sales_License_PrimaryAdmin_Contact__c) == true){
                List<Id> allExistingDelegates = primaryAdminsDelegatesMap.get(delegateRecord.Sales_License_PrimaryAdmin_Contact__c);
                allExistingDelegates.add(delegateRecord.Sales_License_DlgAdmin_Contact__c);
                primaryAdminsDelegatesMap.put(delegateRecord.Sales_License_PrimaryAdmin_Contact__c , allExistingDelegates);
            }else{
                primaryAdminsDelegatesMap.put(delegateRecord.Sales_License_PrimaryAdmin_Contact__c , new List<Id>{delegateRecord.Sales_License_DlgAdmin_Contact__c});
            }
            if(primaryAdminsDelegatesMap.containsKey(delegateRecord.Sales_License_PrimaryAdmin_Contact__c)){                
                contIds.addAll(primaryAdminsDelegatesMap.get(delegateRecord.Sales_License_PrimaryAdmin_Contact__c));
            }
        }
        if(primaryAdminsDelegatesMap.size() > 0 || contactIdsForAdminDelegate.size() > 0 || licensecontactuser.size()>0){ 
            if(isAfterInsert){     
                for(Sales_License__c licRecord : licList){                                                         
                    if(licRecord.Sales_License_Primary_Admin_Contact__c != null){  
                        contIds.add(licRecord.Sales_License_Primary_Admin_Contact__c); 
                    }
                    if(licRecord.Sales_License_Lic_User_Contact_ID__c != null){
                        contIds.add(licRecord.Sales_License_Lic_User_Contact_ID__c);       
                    }
                }
                if(!contIds.isEmpty()){ 
                    List<User> usrList = [SELECT Id, ContactId FROM User WHERE ContactId IN :contIds];
                    for(User usr: usrList){                     
                        primaryAdminDelegateUsrMap.put(usr.ContactId, usr.Id);
                        contIds.remove(usr.ContactId);
                    }
                    if(usrList.isEmpty() || contIds.size() > 0){
                        Map<Id, id> contUserMap = Sales_CreateLicenseContactUser_Utility.getContactUserMapForInternalUser(contIds);
                        if(contUserMap != null && !contUserMap.isEmpty()){
                            primaryAdminDelegateUsrMap.putAll(contUserMap);         
                        }                                
                    }
                    if(contactUserIdMap != null && !contactUserIdMap.isEmpty()){
                        primaryAdminDelegateUsrMap.putAll(contactUserIdMap);    
                    }
                }
                Map<Id,List<Id>> manualSharingMap = new Map<Id,List<Id>>();
                for(Sales_License__c licRecord : licList){
                    Id licRecordId = licRecord.Id;        
                    List<Id> recUserIds = new List<Id>();
                    if(
                        ((licRecord.Sales_License_Primary_Admin_Contact__c != null) && (licRecord.Sales_License_Primary_Admin_Contact__r.Account.IsPartner == true) && (licRecord.Sales_License_Web_Display_Flag__c == true)) 
                        || 
                        ((licRecord.Sales_License_Primary_Admin_Contact__c != null) && (licRecord.Sales_License_Primary_Admin_Contact__r.Account.IsPartner == false))
                        ||
                        ((licRecord.Sales_License_Lic_User_Contact_ID__c != null) && (licRecord.Sales_License_Lic_User_Contact_ID__r.Account.IsPartner == false))
                        ||
                        ((licRecord.Sales_License_Lic_User_Contact_ID__c != null) && (licRecord.Sales_License_Lic_User_Contact_ID__r.Account.IsPartner == true) && (licRecord.Sales_License_Web_Display_Flag__c == true)) 
                    ){                  
                        try{
                            if(licRecord.Sales_License_Lic_User_Contact_ID__c != null && primaryAdminDelegateUsrMap.containskey(licRecord.Sales_License_Lic_User_Contact_ID__c)){
                                recUserIds.add(primaryAdminDelegateUsrMap.get(licRecord.Sales_License_Lic_User_Contact_ID__c));    
                            }
                            if(primaryAdminDelegateUsrMap.containsKey(licRecord.Sales_License_Primary_Admin_Contact__c)){
                                recUserIds.add(primaryAdminDelegateUsrMap.get(licRecord.Sales_License_Primary_Admin_Contact__c));  
                            }  
                        }catch(System.QueryException e){
                        } 
                        if(primaryAdminsDelegatesMap.containsKey(licRecord.Sales_License_Primary_Admin_Contact__c)){
                            for(Id delegateContId : primaryAdminsDelegatesMap.get(licRecord.Sales_License_Primary_Admin_Contact__c)){
                                if(primaryAdminDelegateUsrMap.containsKey(delegateContId)){
                                    recUserIds.add(primaryAdminDelegateUsrMap.get(delegateContId));
                                }
                            }
                        }                  
                        if(recUserIds.size() > 0){
                            manualSharingMap.put(licRecordId, recUserIds);
                        }
                    }                
                }  
                if(manualSharingMap.size() > 0){
                    manualShareEditAccessOnLicenses(manualSharingMap);
                }   
            }
            else if(isAfterUpdate){
                Id oldLicUserContactId;
                for(Sales_License__c licRecord : licList){                    
                    Id licRecordId = licRecord.Id;
                    Id oldPrimaryAdmin = oldLicMap.get(licRecordId)?.Sales_License_Primary_Admin_Contact__c;
                    Id newPrimaryAdmin = licRecord.Sales_License_Primary_Admin_Contact__c;  
                    if(oldPrimaryAdmin != null && (oldPrimaryAdmin== newPrimaryAdmin)){
                        List<Id> delegateAdminIdsListOld = primaryAdminsDelegatesMap.get(oldPrimaryAdmin);  
                        if(delegateAdminIdsListOld != null){
                            delegateAdminIdSet.addAll(delegateAdminIdsListOld); 
                        }
                    }
                    if((oldLicMap.get(licRecordId)?.Sales_License_Lic_User_Contact_ID__c != licRecord.Sales_License_Lic_User_Contact_ID__c && licRecord.Sales_License_Web_Display_Flag__c==true)||(licRecord.Sales_License_Lic_User_Contact_ID__c!=null)){
                        if(oldLicMap.get(licRecordId)?.Sales_License_Lic_User_Contact_ID__c != null && !delegateAdminIdSet.contains(oldLicMap.get(licRecordId)?.Sales_License_Lic_User_Contact_ID__c ) && newPrimaryAdmin!=  oldLicMap.get(licRecordId)?.Sales_License_Lic_User_Contact_ID__c){ 
                            if(oldLicMap.get(licRecordId)?.Sales_License_Lic_User_Contact_ID__c != licRecord.Sales_License_Lic_User_Contact_ID__c){
                                oldLicUserContactId = oldLicMap.get(licRecordId)?.Sales_License_Lic_User_Contact_ID__c;
                            }if(licRecord.Sales_License_Lic_User_Contact_ID__c!=null && licRecord.Sales_License_Web_Display_Flag__c==false){
                                oldLicUserContactId=licRecord.Sales_License_Lic_User_Contact_ID__c;
                            }
                            if(oldLicUserContactId!=null){
                                if(RevokeAccessMap.containsKey(licRecordId)){
                                    List<Id> contactsToRevoke = RevokeAccessMap.get(licRecordId);
                                    contactsToRevoke.add(oldLicUserContactId);                                                                                                               
                                    RevokeAccessMap.put(licRecordId,contactsToRevoke);
                                }
                                else{
                                    List<Id> contactsToRevoke = new List<Id>();
                                    contactsToRevoke.add(oldLicUserContactId);                                                                                                               
                                    RevokeAccessMap.put(licRecordId,contactsToRevoke);
                                }  
                            }
                        }
                        if(licRecord.Sales_License_Lic_User_Contact_ID__c != null && licRecord.Sales_License_Web_Display_Flag__c==true){                  
                            Id newLicUserContactId = licRecord.Sales_License_Lic_User_Contact_ID__c;
                            if(GrantAccessMap.containsKey(licRecordId)){
                                List<Id> contactsToAssign = GrantAccessMap.get(licRecordId);
                                contactsToAssign.add(newLicUserContactId);                                   
                                GrantAccessMap.put(licRecordId,contactsToAssign);
                            }
                            else{
                                List<Id> contactsToAssign = new List<Id>();
                                contactsToAssign.add(newLicUserContactId);                                   
                                GrantAccessMap.put(licRecordId,contactsToAssign);
                            } 
                        } 
                    }
                    if((oldLicMap.get(licRecordId)?.Sales_License_Primary_Admin_Contact__c != licRecord.Sales_License_Primary_Admin_Contact__c && licRecord.Sales_License_Web_Display_Flag__c==true)||(licRecord.Sales_License_Primary_Admin_Contact__c!=null)){
                        if(oldLicMap.get(licRecordId)?.Sales_License_Primary_Admin_Contact__c != null || (licRecord.Sales_License_Lic_User_Contact_ID__c!=null && licRecord.Sales_License_Web_Display_Flag__c==false)){                               
                            Id oldPrimaryAdminId;
                            if(oldLicMap.get(licRecordId)?.Sales_License_Primary_Admin_Contact__c != licRecord.Sales_License_Primary_Admin_Contact__c){
                                oldPrimaryAdminId = oldLicMap.get(licRecordId)?.Sales_License_Primary_Admin_Contact__c;
                            }
                            if(licRecord.Sales_License_Primary_Admin_Contact__c!=null && licRecord.Sales_License_Web_Display_Flag__c==false){
                                oldPrimaryAdminId = licRecord.Sales_License_Primary_Admin_Contact__c;
                            }
                            if(oldPrimaryAdminId!=null){
                                List<Id> delegateAdminIdsList = primaryAdminsDelegatesMap.get(oldPrimaryAdminId);                            
                                if(RevokeAccessMap.containsKey(licRecordId)){
                                    List<Id> contactsToRevoke = RevokeAccessMap.get(licRecordId);
                                    contactsToRevoke.add(oldPrimaryAdminId);                                
                                    if(delegateAdminIdsList != null){
                                        contactsToRevoke.addAll(delegateAdminIdsList);                      
                                    }
                                    RevokeAccessMap.put(licRecordId,contactsToRevoke);
                                }
                                else{
                                    List<Id> contactsToRevoke = new List<Id>();
                                    contactsToRevoke.add(oldPrimaryAdminId);                                
                                    if(delegateAdminIdsList != null){
                                        contactsToRevoke.addAll(delegateAdminIdsList);                      
                                    }
                                    RevokeAccessMap.put(licRecordId,contactsToRevoke);
                                } 
                            }							
                        }
                        if(licRecord.Sales_License_Primary_Admin_Contact__c != null && licRecord.Sales_License_Web_Display_Flag__c==true){                             
                            Id newPrimaryAdminId = licRecord.Sales_License_Primary_Admin_Contact__c;
                            List<Id> delegateAdminIdsList = primaryAdminsDelegatesMap.get(licRecord.Sales_License_Primary_Admin_Contact__c); 
                            if(GrantAccessMap.containsKey(licRecordId)){
                                List<Id> contactsToAssign = GrantAccessMap.get(licRecordId);
                                contactsToAssign.add(newPrimaryAdminId);            
                                if(delegateAdminIdsList != null){
                                    contactsToAssign.addAll(delegateAdminIdsList);                          
                                }
                                GrantAccessMap.put(licRecordId,contactsToAssign);
                            }
                            else{
                                List<Id> contactsToAssign = new List<Id>();
                                contactsToAssign.add(newPrimaryAdminId);            
                                if(delegateAdminIdsList != null){
                                    contactsToAssign.addAll(delegateAdminIdsList);                          
                                }
                                GrantAccessMap.put(licRecordId,contactsToAssign);
                            }                                                                                                                               
                        }
                    }                      
                }
                List<Id> allContIds = new List<Id>();
                Map<Id,Id> contUsrMap = new Map<Id,Id>();
                for( Id licRecId : RevokeAccessMap.keySet() ){
                    allContIds.addAll(RevokeAccessMap.get(licRecId));
                }
                for( Id recId : GrantAccessMap.keySet() ){
                    allContIds.addAll(GrantAccessMap.get(recId));
                }
                if(!allContIds.isEmpty()){                    
                    List<User> usrList = [ SELECT Id, ContactId FROM User WHERE ContactId IN : allContIds];                    
                    for(User usr: usrList){                     
                        contUsrMap.put(usr.ContactId, usr.Id);
                        allContIds.remove(allContIds.indexof(usr.ContactId));
                    }
                    if(usrList.isEmpty() || allContIds.size() > 0){
                        Set<id> contIdsSet = new Set<id>();
                        contIdsSet.addAll(allContIds);
                        Map<Id, id> contUserMap = Sales_CreateLicenseContactUser_Utility.getContactUserMapForInternalUser(contIdsSet);
                        if(contUserMap != null && !contUserMap.isEmpty()){
                            contUsrMap.putAll(contUserMap);              
                        }                                
                    }
                    if(contactUserIdMap != null && !contactUserIdMap.isEmpty()){
                        contUsrMap.putAll(contactUserIdMap);    
                    }
                    for( Id licRecId : RevokeAccessMap.keySet() ){
                        List<Id> usrIds = new List<Id>();
                        for(Id contId : RevokeAccessMap.get(licRecId)){
                            if(contUsrMap.containsKey(contId)){
                                usrIds.add(contUsrMap.get(contId));
                            }
                        }
                        if(!usrIds.isEmpty()){
                            RevokeLicenseAccessForUsersMap.put(licRecId,usrIds);
                        }                       
                    }
                    if(RevokeLicenseAccessForUsersMap.size() > 0){
                        revokeSharedEditAccessOnLicenses(RevokeLicenseAccessForUsersMap);
                    }
                    for( Id licRecId : GrantAccessMap.keySet() ){                        
                        List<Id> grantAccessUsrIds = new List<Id>();
                        for(Id contId : GrantAccessMap.get(licRecId)){
                            if(contUsrMap.containsKey(contId)){
                                grantAccessUsrIds.add(contUsrMap.get(contId));
                            }                           
                        }
                        if(grantAccessUsrIds.size() > 0){
                            GrantLicenseAccessForUsersMap.put(licRecId, grantAccessUsrIds);
                        }                        
                    }
                    if(GrantLicenseAccessForUsersMap.size() > 0){
                        manualShareEditAccessOnLicenses(GrantLicenseAccessForUsersMap);
                    }
                }                 
            }
        }
    }
    public static void manualShareEditAccessOnLicenses(Map<Id,List<Id>> recUserIdMap){
        List<Sales_License__Share> listOfLicenseShareRecords = new List<Sales_License__Share>();
        for(Id recordId : recUserIdMap.keySet()){
            for(Id usrId : recUserIdMap.get(recordId)){
                Sales_License__Share licenseShare  = new Sales_License__Share();        
                licenseShare.ParentId = recordId;                                       
                licenseShare.UserOrGroupId = usrId;                                    
                licenseShare.AccessLevel = 'Edit';                                      
                licenseShare.RowCause = Schema.Sales_License__Share.RowCause.Manual;                
                listOfLicenseShareRecords.add(licenseShare);                            
            }
        }
        if(listOfLicenseShareRecords.size() > 0){
            Database.SaveResult[] results = Database.insert(listOfLicenseShareRecords,false);
        }
    }        
    public static void revokeSharedEditAccessOnLicenses(Map<Id,List<Id>> recUserIdMap){
        Set<Id> allUserIds = new Set<Id>();
        for(Id recId : recUserIdMap.keySet()){
            allUserIds.addAll(recUserIdMap.get(recId));
        }
        List<Sales_License__Share> listOfLicenseRevokeShareRecords = new List<Sales_License__Share>();
        for(Sales_License__Share shareRec : [SELECT Id, ParentId, UserOrGroup.Name, UserOrGroupId
                                             FROM Sales_License__Share 
                                             WHERE ParentId IN :recUserIdMap.keySet() AND UserOrGroupId IN :allUserIds]){
                                                 if(recUserIdMap.get(shareRec.ParentId).contains(shareRec.UserOrGroupId)){
                                                     listOfLicenseRevokeShareRecords.add(shareRec);
                                                 }                  
                                             }
        if(listOfLicenseRevokeShareRecords.size() > 0){
            Database.DeleteResult [] results = Database.delete(listOfLicenseRevokeShareRecords,false);
        }
    }
    public static void validateHostonLicense(List<Sales_License__c> newLicList, Map<Id, Sales_License__c> oldLicMap){
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> hostIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        Set<Id> LicIds = new Set<Id>();
        Set<Id> conIdSet=new Set<Id>();
        List<Sales_License__c> licList=new List<Sales_License__c>();
        Map<Id,Set<Id>> delPrimaryContactMap = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> dlgOfPrimaryAdminOnLicenseContactMap = new Map<Id,Set<Id>>();
        Map<Id,Id> contactAccountMap = new Map<Id,Id>();
        Map<Id, List<Sales_License__c>> licensedHostMap = new Map<Id, List<Sales_License__c>>();
        for(Sales_License__c lic: newLicList){
            contactIdSet.add(lic.Sales_License_Primary_Admin_Contact__c);
            hostIds.add(lic.Sales_License_Host_Node_Id__c);
            orderIds.add(lic.Sales_License_Order__c);
            LicIds.add(lic.id);
        }
        if(contactIdSet.size() > 0){
            for(Contact con : [SELECT Id,AccountId from Contact WHERE Id IN:contactIdSet]){
                contactAccountMap.put(con.Id,con.AccountId);
            }
        }
        licList=[select id,Sales_License_Account__c,Sales_License_Order__c,Sales_License_Order__r.Sales_Order_Reason__c from Sales_License__c where Sales_License_Order__c IN:orderIds and Id IN:LicIds];
        Map<id, Sales_Host__c> hostMap = new Map<id, Sales_Host__c>([select id, Sales_Contact__c,Sales_Contact__r.Name from Sales_Host__c where id in:hostIds]);         
        List<Sales_License__c> lcList = new List<Sales_License__c>();
        if(hostIds.size()>0){
            for(Sales_License__c lc : [SELECT Id, Sales_License_Host_Node_Id__c from Sales_License__c WHERE Sales_License_Host_Node_Id__c IN: hostIds and Sales_License_Host_Node_Id__c!=null]){
                if(licensedHostMap.containsKey(lc.Sales_License_Host_Node_Id__c)){
                    lcList = licensedHostMap.get(lc.Sales_License_Host_Node_Id__c);
                    lcList.add(lc);
                    licensedHostMap.put(lc.Sales_License_Host_Node_Id__c,lcList);
                }
                else{
                    licensedHostMap.put(lc.Sales_License_Host_Node_Id__c, new List<Sales_License__c>{lc});
                }
            }
        }  
        if(contactIdSet.size()>0){
            delPrimaryContactMap = Sales_LicenseGenerationGenericFunctions.validateDelegateUsers(contactIdSet);
            for(Id conId1 : delPrimaryContactMap.keySet()) {
                conIdSet.addAll(delPrimaryContactMap.get(conId1));
            }
            List<Sales_License_Admin_Delegate__c> dlgsList = [Select Id, Sales_License_PrimaryAdmin_Contact__c, Sales_License_DlgAdmin_Contact__c , Sales_License_isActive__c 
                                                              From Sales_License_Admin_Delegate__c Where Sales_License_PrimaryAdmin_Contact__c IN:contactIdSet AND Sales_License_isActive__c = true];
            if(!dlgsList.isEmpty()){
                for(Sales_License_Admin_Delegate__c primDlgAdmRecord : dlgsList){
                    if(dlgOfPrimaryAdminOnLicenseContactMap.containsKey(primDlgAdmRecord.Sales_License_PrimaryAdmin_Contact__c)){
                        Set<Id> existingIds = dlgOfPrimaryAdminOnLicenseContactMap.get(primDlgAdmRecord.Sales_License_PrimaryAdmin_Contact__c);
                        existingIds.add(primDlgAdmRecord.Sales_License_DlgAdmin_Contact__c);
                        dlgOfPrimaryAdminOnLicenseContactMap.put(primDlgAdmRecord.Sales_License_PrimaryAdmin_Contact__c, existingIds);
                    }else{
                        dlgOfPrimaryAdminOnLicenseContactMap.put(primDlgAdmRecord.Sales_License_PrimaryAdmin_Contact__c, new Set<Id>{primDlgAdmRecord.Sales_License_DlgAdmin_Contact__c});
                    }
                }
            }
        }
        for(Sales_License__c lic: newLicList){
            if(oldLicMap!= null && lic.Sales_License_Host_Node_Id__c!=null && 
               lic.Sales_License_Host_Node_Id__c != oldLicMap.get(lic.id)?.Sales_License_Host_Node_Id__c){
                   if((hostMap.get(lic.Sales_License_Host_Node_Id__c)?.Sales_Contact__c != null)
                      && (contactIdSet.contains(hostMap.get(lic.Sales_License_Host_Node_Id__c)?.Sales_Contact__c) || (conIdSet.contains(hostMap.get(lic.Sales_License_Host_Node_Id__c)?.Sales_Contact__c)) 
                          || (lic.Sales_License_Lic_User_Contact_ID__c == hostMap.get(lic.Sales_License_Host_Node_Id__c)?.Sales_Contact__c) 
                          || (dlgOfPrimaryAdminOnLicenseContactMap.containsKey(lic.Sales_License_Primary_Admin_Contact__c) && dlgOfPrimaryAdminOnLicenseContactMap.get(lic.Sales_License_Primary_Admin_Contact__c).contains(hostMap.get(lic.Sales_License_Host_Node_Id__c)?.Sales_Contact__c))) ){
                          }else{
                              if(Sales_AddNewLicenseAdminController.isCommunity() == true){  
                                  lic.addError(System.Label.Sales_InvalidHost_ErrMsg);
                              }
                          }
               }
            if(licList.size()>0){   
                for(Sales_License__c license:licList){
                    if(lic.Sales_License_Status__c=='Licensed' && oldLicMap.get(lic.Id).Sales_License_Status__c!='Licensed'){
                        if(license.id==lic.id && license.Sales_License_Order__r.Sales_Order_Reason__c!='Non Stocking Order'){           
                            lic.Sales_License_Account__c = contactAccountMap.get(lic.Sales_License_Primary_Admin_Contact__c) ; 
                        }
                    }
                }
            }
            else if(lic.Sales_License_Status__c=='Licensed' && oldLicMap.get(lic.Id).Sales_License_Status__c!='Licensed'){
                lic.Sales_License_Account__c = contactAccountMap.get(lic.Sales_License_Primary_Admin_Contact__c) ; 
            }
        }
    }
    public static Sales_License__c updateAvailableRehostWebdisplayflag(Sales_License__c licRec){
        List<Sales_License__c> licList=new List<Sales_License__c>();
        boolean result1=false;
        if(licRec.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Rehostable_Ind__c == true){    
            licRec.Sales_License_Avbl_Rehost_Nbr__c = licRec.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c;
        }
        if(licRec.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Web_Displayable_Ind__c== true){
            licRec.Sales_License_Web_Display_Flag__c=true;
        }
        if(licRec.Sales_License_Order_Product__r.Product2.Core_Item_Class_Nm__c != ARM_PRODUCT_CLASS_VALUE || licRec.Sales_License_Order_Product__r.Product2.Core_Item_Sub_Component_Category_Nm__c != ARM_PRODUCT_SUBCATEGORY_VALUE && licRec.Sales_License_Type__c!=OPTIONAL_LICENSE){
            licRec.Sales_License_Web_Display_Flag__c = true;         
        }else{
            licRec.Sales_License_Web_Display_Flag__c=false;
        }  
        return licRec;
    }
    public static  Map<Id, List<Id>> validateDelegateUsers(Set<id> contactIds){
        Map<Id, List<Id>> delPrimaryContactMap = new  Map<Id, List<Id>>();
        for(Sales_License_Admin_Delegate__c delegateItem : [SELECT Id,Name,Sales_License_DlgAdmin_Contact__c,Sales_License_DlgAdmin_Contact__r.Name,Sales_License_DlgAdmin_Email_Txt__c,
                                                            Sales_License_PrimaryAdmin_Contact__c,Sales_License_isActive__c from Sales_License_Admin_Delegate__c where Sales_License_DlgAdmin_Contact__c in :contactIds and Sales_License_isActive__c=true]){
                                                                if(!delPrimaryContactMap.containsKey(delegateItem.Sales_License_DlgAdmin_Contact__c)){
                                                                    List<Id> existingIds = new List<Id>();
                                                                    existingIds.add(delegateItem.Sales_License_PrimaryAdmin_Contact__c);
                                                                    delPrimaryContactMap.put(delegateItem.Sales_License_DlgAdmin_Contact__c, existingIds);
                                                                }else{
                                                                    delPrimaryContactMap.put(delegateItem.Sales_License_DlgAdmin_Contact__c, new List<Id>{delegateItem.Sales_License_PrimaryAdmin_Contact__c});
                                                                }
                                                            }
        return delPrimaryContactMap;
    }
    private static List<Id> validateContactsDelegate(List<Id> contactList, Map<Id, List<Id>> delegateAdminPrimaryAdminMap){
        List<Id> primaryAdminContList = new List<Id>();
        for(Id contId: contactList){
            if(delegateAdminPrimaryAdminMap.containsKey(contId)){
                primaryAdminContList.addAll(delegateAdminPrimaryAdminMap.get(contId));
            }
        }
        return primaryAdminContList;
    }
    public static void automateRenewals(List<Order> newOrderList){  
        Set<id> orderIds = new Set<Id>();
        Set<id> productIdSet = new Set<Id>();
        Set<id> foundProdIdSet = new Set<Id>();
        Set<Id> contactId = new Set<Id>();
        Map<Id, List<Id>> mapofLicenseRenewalContactId = new Map<Id, List<Id>>();
        Map<Id, List<Id>> mapofLicenseBaseContactId = new Map<Id, List<Id>>();
        Map<Id, Sales_License__c> licenseProductMap = new Map<Id, Sales_License__c>();
        List<Sales_License__c> baseLicList = new  List<Sales_License__c>();
        List<Sales_License__c> renewaltargetBaseRecords = new  List<Sales_License__c>();
        List<Sales_License__c> validbaseLicensesList = new  List<Sales_License__c>();
        Map<Id, Integer> licenseQuantityMap = new Map<Id, Integer>();
        List<Id> delPrimaryContactMap = new List<Id>();
        Map<Id, List<Id>> renewaldelPrimaryContactMap = new  Map<Id, List<Id>>();
        Map<Id, List<Id>> basedelPrimaryContactMap = new  Map<Id, List<Id>>();
        Id orderproduct;
        List<Sales_License__c> renewalLicenseList = new List<Sales_License__c>();
        List<Sales_License__c> baseLicenseList = new List<Sales_License__c>();
        Set<ID> prodIdsSet = new Set<Id>();
        List<Sales_License__c> licenseListforRenewal = new List<Sales_License__c>();
        for(Order ord : newOrderList){
            if(ord.Sales_Order_Sub_Type__c!='Corporate Order' && ord.Status=='Activated' && 
               ((ord.Type!='Non Commercial Order' && ord.Sales_status__c=='SAP Order Shipped') || 
                (ord.Type=='Non Commercial Order' && ord.Sales_status__c=='Order created successfully'))){
                    orderIds.add(ord.Id);
                }
        }
        List<Sales_License__c> renewallicensesList = [SELECT id,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,
                                                      Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c,
                                                      Sales_License_Avbl_Qty_Nbr__c,Sales_License_Quantity__c,
                                                      Sales_License_Primary_Admin_Contact__c,Sales_License_Contract__c
                                                      from Sales_License__c WHERE Sales_License_Order__c IN : orderIds and 
                                                      Sales_License_Status__c = 'Unlicensed' and
                                                      (Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c = 'RENEWAL'
                                                       or Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c = 'BASE')];
        if(renewallicensesList.size()>0){
            for(Sales_License__c lc : renewallicensesList){
                prodIdsSet.add(lc.Sales_License_Product__c);
            }
        }
        Set<Id> foundationSet=new Set<Id>();
        if(prodIdsSet.size() > 0){
            for(Product2 prod:[SELECT Id,Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c,Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c from Product2 where Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c IN :prodIdsSet and Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c ='RENEWAL' ]){
                foundationSet.add(prod.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c);
            }
        }
        List<Sales_License__c> licensesList = [SELECT id,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,
                                               Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c,
                                               Sales_License_Avbl_Qty_Nbr__c,Sales_Renewed_Description__c,Sales_License_Quantity__c,
                                               Sales_License_Primary_Admin_Contact__c,Sales_License_Contract__c,
                                               Sales_License_Order_Product__r.Sales_Contact__r.Name,Sales_License_Product__c,
                                               Sales_License_Order_Product__r.Sales_Contact__r.Email 
                                               from Sales_License__c WHERE Sales_License_Order__c IN : orderIds and 
                                               Sales_License_Status__c = 'Unlicensed' and Sales_License_Product__c NOT IN :foundationSet and
                                               (Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c = 'RENEWAL'
                                                or Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c = 'BASE')];
        Set<Id> licenseIds =new Set<Id>();
        if(licensesList.size() > 0){
            foundProdIdSet.clear();
            for(Sales_License__c renewalLicItem : licensesList){
                if(renewalLicItem.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c == 'RENEWAL'){
                    if(mapofLicenseRenewalContactId != null && mapofLicenseRenewalContactId?.containsKey(renewalLicItem?.Sales_License_Product__r?.Core_Product_Ext_Attribute_Id__r?.Core_Foundation_Product_Id__c)){
                        mapofLicenseRenewalContactId.get(renewalLicItem.Sales_License_Product__r?.Core_Product_Ext_Attribute_Id__r?.Core_Foundation_Product_Id__c).add(renewalLicItem?.Sales_License_Primary_Admin_Contact__c);
                    }else{
                        List<Id> contIds= new List<Id>();
                        contIds.add(renewalLicItem.Sales_License_Primary_Admin_Contact__c);    
                        mapofLicenseRenewalContactId.put(renewalLicItem.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c, contIds);
                    } 
                    foundProdIdSet.add(renewalLicItem.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c);
                }else if(renewalLicItem.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c == 'BASE'){                    
                    if(mapofLicenseBaseContactId.containsKey(renewalLicItem.Sales_License_Product__c)){
                        mapofLicenseBaseContactId.get(renewalLicItem.Sales_License_Product__c).add(renewalLicItem.Sales_License_Primary_Admin_Contact__c);
                    }else{
                        List<Id> contIds= new List<Id>();
                        contIds.add(renewalLicItem.Sales_License_Primary_Admin_Contact__c);    
                        mapofLicenseBaseContactId.put(renewalLicItem.Sales_License_Product__c, contIds);
                    } 
                    licenseIds.add(renewalLicItem.Id);
                    productIdSet.add(renewalLicItem.Sales_License_Product__c);
                }                }
        }
        Set<id> delegaterenewalIds = new Set<id>();
        if(mapofLicenseRenewalContactId.size()>0){
            for(List<Id> contId : mapofLicenseRenewalContactId.values()){
                delegaterenewalIds.addAll(contId);
            }
            renewaldelPrimaryContactMap = validateDelegateUsers(delegaterenewalIds);
        }
        Set<Id> primaryContactIdSet= new Set<Id>();
        for(Id delegateId: renewaldelPrimaryContactMap.keySet())
        {
            primaryContactIdSet.addAll(renewaldelPrimaryContactMap.get(delegateId));
        }
        Set<id> delegatebaseIds = new Set<id>();
        if(mapofLicenseBaseContactId.size()>0){
            for(List<Id> contId : mapofLicenseBaseContactId.values()){
                delegatebaseIds.addAll(contId);
            }
            basedelPrimaryContactMap = validateDelegateUsers(delegatebaseIds);
        }
        Set<Id> primaryContactIdBaseSet= new Set<Id>();
        for(Id delegateId: basedelPrimaryContactMap.keySet())
        {
            primaryContactIdBaseSet.addAll(basedelPrimaryContactMap.get(delegateId));
        }
        if(foundProdIdSet.size() > 0){
            for(Sales_License__c lic :[SELECT Id, Name, Sales_License_Order_Product__r.Product2Id, Sales_License_Account__c,Sales_License_Status__c, Sales_License_Expiration_Date_Dt__c,Sales_License_Maintenance_Exp_Dt__c,
                                       Sales_License_Primary_Admin_Contact__c,Sales_License_Type__c,Sales_License_Lic_User_Contact_ID__c,Sales_License_Avbl_Qty_Nbr__c,
                                       Sales_License_Product__c,Sales_License_Quantity__c,Sales_License_Order_Product__r.OrderItemNumber,Sales_License_Order_Product__c, Sales_Tool_License_Type__c ,
                                       Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Renewal_Period_Nbr__c,Sales_License_Contract__c,
                                       Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c
                                       FROM Sales_License__c where (Sales_License_Product__c IN:foundProdIdSet) AND Sales_License_Type__c ='ORIGINAL'
                                       AND Sales_License_Status__c = 'Licensed' AND Sales_License_Type__c != 'Evaluation' AND Sales_License_Type__c != 'Employee' AND 
                                       (Sales_License_Primary_Admin_Contact__c IN: delegaterenewalIds OR Sales_License_Lic_User_Contact_ID__c IN: delegaterenewalIds
                                        OR Sales_License_Primary_Admin_Contact__c IN: primaryContactIdSet/*OR
/*(Sales_License_Primary_Admin_Contact__c IN : renewaldelPrimaryContactMap.values())*/)]){
    if(mapofLicenseRenewalContactId.containsKey(lic.Sales_License_Product__c) &&
       ((mapofLicenseRenewalContactId.get(lic.Sales_License_Product__c).contains(lic.Sales_License_Primary_Admin_Contact__c)) ||
        (mapofLicenseRenewalContactId.get(lic.Sales_License_Product__c).contains(lic.Sales_License_Lic_User_Contact_ID__c)) 
        /* || delegateIds.contains((mapofLicenseRenewalContactId.get(lic.Sales_License_Product__c)))*/ || validateContactsDelegate(mapofLicenseRenewalContactId.get(lic.Sales_License_Product__c),renewaldelPrimaryContactMap).contains(lic.Sales_License_Primary_Admin_Contact__c))){
            renewaltargetBaseRecords.add(lic);
        }
}
        }
        if(productIdSet.size () > 0){
            for(Sales_License__c lic :[SELECT Id, Name, Sales_License_Account__c,Sales_License_Status__c, Sales_License_Expiration_Date_Dt__c,Sales_License_Maintenance_Exp_Dt__c,
                                       Sales_License_Primary_Admin_Contact__c, Sales_License_Primary_Admin_Contact__r.Account.IsPartner,Sales_License_Type__c,Sales_License_Lic_User_Contact_ID__c,Sales_License_Avbl_Qty_Nbr__c,
                                       Sales_License_Product__c,Sales_License_Quantity__c,Sales_License_Order_Product__r.OrderItemNumber,Sales_License_Order_Product__c, Sales_Tool_License_Type__c ,
                                       Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Renewal_Period_Nbr__c,Sales_License_Contract__c,
                                       Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c
                                       FROM Sales_License__c where (Sales_License_Product__c IN:productIdSet and Id NOT IN :licenseIds)
                                       AND (Sales_License_Primary_Admin_Contact__c IN:delegatebaseIds OR Sales_License_Lic_User_Contact_ID__c IN:delegatebaseIds
                                            OR Sales_License_Primary_Admin_Contact__c IN:primaryContactIdBaseSet
                                            /*OR(Sales_License_Primary_Admin_Contact__c IN : basedelPrimaryContactMap)*/) AND Sales_License_Type__c ='ORIGINAL'
                                       AND Sales_License_Status__c = 'Licensed' AND Sales_License_Type__c != 'Evaluation' AND Sales_License_Type__c != 'Employee']){
                                           if(mapofLicenseBaseContactId.containsKey(lic.Sales_License_Product__c) && 
                                              ((mapofLicenseBaseContactId.get(lic.Sales_License_Product__c).contains(lic.Sales_License_Primary_Admin_Contact__c)) || 
                                               (mapofLicenseBaseContactId.get(lic.Sales_License_Product__c).contains(lic.Sales_License_Lic_User_Contact_ID__c)) 
                                               /*|| basedelPrimaryContactMap.contains(mapofLicenseBaseContactId.get(lic.Sales_License_Product__c)*/
                                               || validateContactsDelegate(mapofLicenseBaseContactId.get(lic.Sales_License_Product__c),basedelPrimaryContactMap).contains(lic.Sales_License_Primary_Admin_Contact__c))){
                                                   baseLicList.add(lic);
                                               }
                                       }
        }
        for(Sales_License__c lic: baseLicList){ 
            Integer prodRenewalGracePeriodInDays = (Integer)lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r?.Core_SW_Lic_Renewal_Period_Nbr__c;
            if(prodRenewalGracePeriodInDays > 0 && (((lic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodRenewalGracePeriodInDays))>(Date.today()))
                                                    && (lic.Sales_License_Maintenance_Exp_Dt__c?.addDays(-prodRenewalGracePeriodInDays))<(Date.today()))){
                                                        validbaseLicensesList.add(lic);
                                                        orderproduct=lic.Sales_License_Order_Product__c;
                                                        baseLicenseList.add(lic);
                                                    }
        }
        for(Sales_License__c lic: renewaltargetBaseRecords){ 
            validbaseLicensesList.add(lic);
            renewalLicenseList.add(lic);
        }
        if(renewalLicenseList.size() > 0){
            Integer count=0;
            for(Sales_License__c lic: renewalLicenseList){
                if(licenseQuantityMap.containsKey(lic.Sales_License_Product__c)){
                    count = licenseQuantityMap.get(lic.Sales_License_Product__c);
                    if(lic.Sales_License_Quantity__c!=null){
                        count = count + (Integer)lic?.Sales_License_Quantity__c;
                    }    
                }else 
                {  
                    if(lic.Sales_License_Quantity__c!=null){
                        count = (Integer)lic?.Sales_License_Quantity__c;
                    }else{
                        count =0;
                    }
                }
                licenseQuantityMap.put(lic.Sales_License_Product__c, count);    
            }
        }
        if(baseLicenseList.size() > 0){
            Integer count=0;
            for(Sales_License__c lic: baseLicenseList){
                if(licenseQuantityMap.containsKey(lic.Sales_License_Product__c)){
                    count = licenseQuantityMap.get(lic.Sales_License_Product__c);
                    if(lic.Sales_License_Quantity__c!=null){
                        count = count + (Integer)lic?.Sales_License_Quantity__c;
                    }    
                }else 
                {  
                    if(lic.Sales_License_Quantity__c!=null){
                        count = (Integer)lic?.Sales_License_Quantity__c;
                    }else{
                        count =0;
                    }
                }
                licenseQuantityMap.put(lic.Sales_License_Product__c, count);    
            }
        }
        Map<Id, Sales_License__c> validSourceLicense = new Map<Id, Sales_License__c>();
        Decimal licenseRollupQuantity=0;
        for(Sales_License__c renewallic : licensesList){
            if(renewallic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c=='RENEWAL' && (licenseQuantityMap.containsKey(renewallic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c))){
                licenseRollupQuantity = licenseQuantityMap.get(renewallic.Sales_License_Product__r?.Core_Product_Ext_Attribute_Id__r?.Core_Foundation_Product_Id__c);
                if(licenseRollupQuantity == renewallic.Sales_License_Avbl_Qty_Nbr__c){
                    licenseProductMap.put(renewallic.Sales_License_Product__r?.Core_Product_Ext_Attribute_Id__r?.Core_Foundation_Product_Id__c,renewallic);
                    if(validSourceLicense.size()>0){
                        if(!validSourceLicense.containsKey(renewallic?.Sales_License_Product__c)){
                            validSourceLicense.put(renewallic?.Sales_License_Product__c, renewallic);
                        }else{
                            if(validSourceLicense.get(renewallic?.Sales_License_Product__c)?.Sales_License_Primary_Admin_Contact__c!=null &&
                               (validSourceLicense.get(renewallic?.Sales_License_Product__c)?.Sales_License_Primary_Admin_Contact__c==renewallic?.Sales_License_Primary_Admin_Contact__c)){ 
                                   validSourceLicense.put(renewallic?.Sales_License_Product__c, renewallic);
                               }
                        }   
                    }
                    else{
                        validSourceLicense.put(renewallic?.Sales_License_Product__c, renewallic);
                    }
                }
            }
            if(licenseQuantityMap.containsKey(renewallic.Sales_License_Product__c) && renewallic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c=='BASE'){
                licenseRollupQuantity = licenseQuantityMap.get(renewallic.Sales_License_Product__c);
                if(licenseRollupQuantity == renewallic.Sales_License_Avbl_Qty_Nbr__c){
                    licenseProductMap.put(renewallic.Sales_License_Product__c,renewallic);
                    if(validSourceLicense.size()>0){
                        if(!validSourceLicense.containsKey(renewallic?.Sales_License_Product__c)){
                            validSourceLicense.put(renewallic?.Sales_License_Product__c, renewallic);
                        }else{
                            if((validSourceLicense.get(renewallic?.Sales_License_Product__c)?.Sales_License_Primary_Admin_Contact__c)!=null &&
                               (validSourceLicense.get(renewallic?.Sales_License_Product__c)?.Sales_License_Primary_Admin_Contact__c)==renewallic?.Sales_License_Primary_Admin_Contact__c){ 
                                   validSourceLicense.put(renewallic?.Sales_License_Product__c, renewallic);
                               }
                        }   
                    }
                    else{
                        validSourceLicense.put(renewallic?.Sales_License_Product__c, renewallic);
                    }
                }
            }
        }
        List<Sales_License__c> validBaseLicenses= new List<Sales_License__c>();
        List<Sales_License__c> validRenewalLicenses= new List<Sales_License__c>();
        Map<Id,Map<OrderItem, List<Sales_License__c>>> mapOfOrdProdLicListLinkMap= new  Map<Id,Map<OrderItem, List<Sales_License__c>>>();        
        if(licenseProductMap.size() > 0){
            for(Sales_License__c baseLic : renewalLicenseList){
                if(foundProdIdSet.size() > 0 && (licenseProductMap.containsKey(baseLic.Sales_License_Product__c))){
                    validRenewalLicenses.add(baseLic);
                    licenseListforRenewal.add(baseLic);
                }
            }
            for(Sales_License__c baseLic : baseLicenseList){
                if(productIdSet.size() > 0 && (licenseProductMap.containsKey(baseLic.Sales_License_Product__c))){
                    validBaseLicenses.add(baseLic);
                    licenseListforRenewal.add(baseLic);
                }
            }
        }
        Set<Id> validSourceListIds = new Set<Id>();
        List<Sales_License__c> updatedList = new List<Sales_License__c>();
        if(licenseListforRenewal.size() > 0){
            for(Sales_License__c lic : validSourceLicense.values()){
                lic.Sales_License_Status__c = STATUS_RENEWALS_APPLIED;
                lic.Sales_License_Avbl_Qty_Nbr__c = 0;
                lic.Sales_Renewed_Description__c='License is eligible for autorenewal '+date.today().format();
                updatedList.add(lic);
                validSourceListIds.add(lic.Id);
            }
            if(updatedList.size() > 0){
                update updatedList;
            }
        }
        if(licenseListforRenewal.size() > 0 && updatedList.size() > 0){
            for(Sales_License__c lic2: [SELECT id,Sales_License_Order_Product__r.Product2Id,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,
                                        Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c
                                        from Sales_License__c WHERE Id IN : validSourceListIds]){
                                            Map<OrderItem, List<Sales_License__c>>  mapOfOrdProdLicListLink=new Map<OrderItem, List<Sales_License__c>>();
                                            if(lic2.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c == 'RENEWAL'){
                                                if(validRenewalLicenses.size()>0){
                                                    for(Sales_License__c lic : validRenewalLicenses){
                                                        if(lic.Sales_License_Product__c == lic2.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c){ 
                                                            OrderItem orderitemrec = new OrderItem();
                                                            orderitemrec.id = lic.Sales_License_Order_Product__c;
                                                            if(mapOfOrdProdLicListLink.containsKey(orderitemrec)){
                                                                mapOfOrdProdLicListLink.get(orderitemrec).add(lic);
                                                            }else{
                                                                List<Sales_License__c> renlices= new List<Sales_License__c>();
                                                                renlices.add(lic);    
                                                                mapOfOrdProdLicListLink.put(orderitemrec,renlices);
                                                            } 
                                                        }
                                                    }
                                                }
                                            }
                                            if(lic2.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c == 'BASE' && validBaseLicenses.size()>0 ){
                                                for(Sales_License__c lic : validBaseLicenses){
                                                    if(lic.Sales_License_Product__c == lic2.Sales_License_Product__c){ 
                                                        OrderItem orderitemrec = new OrderItem();
                                                        orderitemrec.id = lic.Sales_License_Order_Product__c;
                                                        if(mapOfOrdProdLicListLink.containsKey(orderitemrec)){
                                                            mapOfOrdProdLicListLink.get(orderitemrec).add(lic);
                                                        }else{
                                                            List<Sales_License__c> renlices= new List<Sales_License__c>();
                                                            renlices.add(lic);    
                                                            mapOfOrdProdLicListLink.put(orderitemrec,renlices);
                                                        } 
                                                    }
                                                }
                                            }
                                            if(!mapOfOrdProdLicListLink.isEmpty()){
                                                mapOfOrdProdLicListLinkMap.put(lic2.id,mapOfOrdProdLicListLink);
                                            }
                                        }
            if(!mapOfOrdProdLicListLinkMap.isEmpty()){
                Sales_OrderProductTriggerUtility.createLicenseOrderProducts(mapOfOrdProdLicListLinkMap,null,mapOfOrdProdLicListLinkMap.keyset());
            }
            Sales_LicenseGenerationGenericFunctions.applyRenewals(licenseListforRenewal);
        }
    }
    public static void updateHostOnOptionLicense(List<Sales_License__c> licUpdateList){
        Set<Id> licUpdateSetId=new Set<Id>();
        List<Sales_License__c> hostUpdateOnLicenseList=new List<Sales_License__c>();
        for(Sales_License__c licUpdate:licUpdateList){
            licUpdateSetId.add(licUpdate.id);
        }
        for(Sales_License__c lic:[Select id,Sales_License_Primary_Admin_Contact__c,Sales_License_Type__c,Sales_License_Host_Node_Id__c,Sales_Parent_License__c,
                                  Sales_License_Status__c,Sales_Parent_License__r.Sales_License_Status__c,Sales_License_Avbl_Qty_Nbr__c,
                                  Sales_License_Maintenance_Exp_Dt__c,Sales_Parent_License__r.Sales_License_Maintenance_Exp_Dt__c,
                                  Sales_License_Expiration_Date_Dt__c,Sales_Parent_License__r.Sales_License_Expiration_Date_Dt__c,
                                  Sales_Parent_License__r.Sales_License_Host_Node_Id__c,Sales_Parent_License__r.Sales_License_Avbl_Rehost_Nbr__c,Sales_Parent_License__r.Sales_License_Primary_Admin_Contact__c from Sales_License__c where Sales_Parent_License__c In:licUpdateSetId and Sales_Parent_License__c!=null]){
                                      lic.Sales_License_Host_Node_Id__c=lic.Sales_Parent_License__r.Sales_License_Host_Node_Id__c;
                                      lic.Sales_License_Avbl_Rehost_Nbr__c=lic.Sales_Parent_License__r.Sales_License_Avbl_Rehost_Nbr__c;
                                      lic.Sales_License_Status__c=lic.Sales_Parent_License__r.Sales_License_Status__c;
                                      lic.Sales_License_Maintenance_Exp_Dt__c=lic.Sales_Parent_License__r.Sales_License_Maintenance_Exp_Dt__c;
                                      lic.Sales_License_Expiration_Date_Dt__c=lic.Sales_Parent_License__r.Sales_License_Expiration_Date_Dt__c;
                                      lic.Sales_License_Primary_Admin_Contact__c=lic.Sales_Parent_License__r.Sales_License_Primary_Admin_Contact__c;
                                      if(lic.Sales_Parent_License__r.Sales_License_Status__c=='Licensed'){
                                          lic.Sales_License_Avbl_Qty_Nbr__c=0;
                                      }
                                      hostUpdateOnLicenseList.add(lic);
                                  }
        try{
            update hostUpdateOnLicenseList;
        }catch(Exception e){
            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Info', SEVERITY,null, e.getMessage(),null,'', '');
        }
    }
    public static void updateLicenseRenewalStatus(List<Sales_License__c> licUpdateList , String updateType){
        List<Sales_License__c> licRenStatusUpd =new List<Sales_License__c>();
        if(updateType == 'Renewed'){
            for(Sales_License__c lic : licUpdateList){
                lic.Sales_License_Renewal_Status__c = 'License Renewed';
                lic.Sales_License_Renewed_Date__c = Date.today();
                licRenStatusUpd.add(lic);
            }
        }else if (updateType == 'Extended'){         
            for(Sales_License__c lic : licUpdateList){
                lic.Sales_License_Renewal_Status__c = '';
                lic.Sales_License_Renewed_Date__c = null;
                licRenStatusUpd.add(lic);
            }
        }else if (updateType == 'NotApplicable'){
            for(Sales_License__c lic : licUpdateList){
                lic.Sales_License_Renewal_Status__c = 'N/A';
                lic.Sales_License_Renewed_Date__c = null;
                licRenStatusUpd.add(lic);
            }
        } 
        try{ 
            Database.SaveResult[] results = Database.update(licRenStatusUpd, false);
            for(Database.SaveResult sr : results) {                    
                if(!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()){
                        Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Line 1356', SEVERITY,null, err.getMessage(),null,'', '');  
                    }
                }
            }
        }catch(Exception e){
            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Line 1362', SEVERITY,null, e.getMessage(),null,'', '');
        }
    }
}