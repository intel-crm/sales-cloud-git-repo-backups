/*********************************************************************************************************************
Class Name    : Sales_ApplyRenewalController
Version       : 1.0
Created Date  : June 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Monika Shinde           22-June-2021              Sales_ApplyRenewalController
*monika Shinde            23-june- 2021           US972836 US972837
* Shubham Khandelwal      29-june -2021           
* *********************************************************************************************************************/
@isTest
public without sharing class Sales_ApplyRenewalController {
    /*private static final String ORDER_SUBTYPE_CORPORATEORDER='Corporate Order';
    public static Date getLastDateOfMonth(Date dt){
        Date result;
        Integer noOfDays;
        if(dt != null){
            noOfDays = Date.daysInMonth(dt.year(), dt.month());
            result = date.newInstance(dt.year(), dt.month(), noOfDays);
        }   
        return result;
    }
    public static void updateDateLogic(List<Sales_License__c> baseLicList){
        Integer prodExpiryDurationInDays;
        Integer prodRenewalGracePeriodInDays;
        Integer prodAdditionExpDurationGracePeriod ;
        Integer prodSubscriptionTerm;
        String hostId;
        date dte;
    }
    @AuraEnabled
    public static Boolean validateRenewalrecord(Id renewalprodId){
        Boolean isValid=true;
        List<Product2> renewprodList = [Select id,Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c,Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c
                                        from Product2 where Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c =:renewalprodId and Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c='RENEWAL'];
        If(renewprodList.size()>0){
            isValid=false;
        }                          
        return isValid;
    }
    @AuraEnabled
    public static void applyRenewals(List<Sales_License__c> licensesList, Integer noOfSeatsToRenew, Id renewalLic,String contactforFile){
        Integer prodExpiryDurationInDays;
        Integer prodMaintenanceDurInMonths;
        Integer prodRenewalGracePeriodInDays;
        Integer prodAdditionExpDurationGracePeriod ;
        Integer prodSubscriptionTerm;
        Id newLicenseCreatedId;
        Id baseLicenseCreatedId;
        List<Sales_License__c> newLicenseList = new List<Sales_License__c>();
        List<Sales_License__c> baseLicenseList = new List<Sales_License__c>();
        Date dte;
        Boolean newLicense=false;
        Boolean baseLicenseUpdate=false;
        Map<OrderItem, List<Sales_License__c>> mapOfOrdProdLicListLink= new  Map<OrderItem, List<Sales_License__c>>();
        Map<OrderItem, List<Sales_License__c>> mapOfBaseOrdProdLicListLink= new  Map<OrderItem, List<Sales_License__c>>();
        Map<OrderItem, List<Sales_License__c>> mapOfOrdProdLicListUpdateLink=new Map<OrderItem, List<Sales_License__c>>();
        Map<Id,Map<OrderItem, List<Sales_License__c>>> mapOfOrdProdLicListLinkMap= new  Map<Id,Map<OrderItem, List<Sales_License__c>>>();
        Map<Id,Map<OrderItem, List<Sales_License__c>>> mapOfOrdProdbaseLicListLinkMap= new  Map<Id,Map<OrderItem, List<Sales_License__c>>>();
        String orderproduct;        
        Sales_License__c newLicenseData = new Sales_License__c();
        List<Sales_License__c> listOfLicensesToProcess = new List<Sales_License__c>();
        List<Sales_License__c> listofRenewalLicense = new List<Sales_License__c>();
        List<Sales_License__c> listofbaseLicenseToUpadate=new List<Sales_License__c>();
        Set<Id> hostSet = new Set<Id>();
        for(Sales_License__c lic : [Select Id,Sales_License_Quantity__c ,Sales_License_Start_Date_Dt__c,Sales_License_Activation_Code__c,Sales_License_Comments_Txt__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c,Sales_License_Avbl_Qty_Nbr__c ,Sales_License_Status__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c,
                                    Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c,Sales_License_Order_Product__c,
                                    Sales_License_Order_Product__r.Order.Sales_Order_Sub_Type__c,Sales_License_Avbl_Rehost_Nbr__c, Sales_License_Maintenance_Exp_Dt__c,Sales_License_Expiration_Date_Dt__c,
                                    Sales_License_Available_Temp_Licenses__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,
                                    Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Renewal_Period_Nbr__c,Sales_License_Order__c,
                                    Sales_License_Primary_Admin_Contact__c,Sales_License_Lic_User_Contact_ID__c,Sales_License_Account__c,Sales_License_Type__c,Sales_License_Web_Display_Flag__c,
                                    Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c,Sales_License_Host_Node_Id__c ,Sales_License_Contract__c,
                                    Sales_License_Product__r.SBQQ__SubscriptionTerm__c,Sales_License_Renewal_Status__c,Sales_License_Renewed_Date__c
                                    from Sales_License__c where Id IN: licensesList]){
                                        prodExpiryDurationInDays = lic.Sales_License_Product__r?.Core_Product_Ext_Attribute_Id__r?.Core_SW_Prod_Expiration_Duration_Nbr__c != null?(Integer)lic.Sales_License_Product__r?.Core_Product_Ext_Attribute_Id__r?.Core_SW_Prod_Expiration_Duration_Nbr__c:0;
                                        prodRenewalGracePeriodInDays = lic.Sales_License_Product__r?.Core_Product_Ext_Attribute_Id__r?.Core_SW_Lic_Renewal_Period_Nbr__c!= null?(Integer)lic.Sales_License_Product__r?.Core_Product_Ext_Attribute_Id__r?.Core_SW_Lic_Renewal_Period_Nbr__c:0;
                                        prodSubscriptionTerm = lic.Sales_License_Product__r?.SBQQ__SubscriptionTerm__c != null?(Integer)lic.Sales_License_Product__r.SBQQ__SubscriptionTerm__c:0;
                                        prodAdditionExpDurationGracePeriod = prodExpiryDurationInDays + prodRenewalGracePeriodInDays;
                                        if(lic.Sales_License_Host_Node_Id__c != null){
                                            hostSet.add(lic.Sales_License_Host_Node_Id__c);
                                        }
                                        if(noOfSeatsToRenew < lic.Sales_License_Quantity__c){
                                            newLicense=true;
                                            newLicenseData = lic.clone(false,true);
                                            listofbaseLicenseToUpadate.add(newLicenseData);
                                            orderproduct=lic.Sales_License_Order_Product__c;
                                            OrderItem orderitemrecord = new OrderItem(Id=orderproduct);
                                            if(orderitemrecord !=null){
                                                mapOfOrdProdLicListUpdateLink.put(orderitemrecord,listofbaseLicenseToUpadate);
                                            }
                                            newLicenseData.Sales_License_Quantity__c =  noOfSeatsToRenew;
                                            lic.Sales_License_Quantity__c = lic.Sales_License_Quantity__c - noOfSeatsToRenew;
                                            if(lic.Sales_License_Available_Temp_Licenses__c != null){
                                                newLicenseData.Sales_License_Available_Temp_Licenses__c = newLicenseData.Sales_License_Quantity__c;
                                                lic.Sales_License_Available_Temp_Licenses__c = lic.Sales_License_Quantity__c;
                                            }                                            
                                        }
                                        else if(lic.Sales_License_Quantity__c == noOfSeatsToRenew || lic.Sales_License_Quantity__c < noOfSeatsToRenew){
                                            baseLicenseUpdate=true;
                                            baseLicenseList.add(lic);
                                            baseLicenseCreatedId=lic.Id;
                                            orderproduct=lic.Sales_License_Order_Product__c;
                                            OrderItem orderitemrecord = new OrderItem(Id=orderproduct);
                                            if(orderitemrecord !=null){
                                                mapOfBaseOrdProdLicListLink.put(orderitemrecord,baseLicenseList);
                                            }
                                        }
                                        if(newLicense==true){
                                                if( prodExpiryDurationInDays <= 0 || prodExpiryDurationInDays == null || lic.Sales_License_Expiration_Date_Dt__c == null){ 
                                                    newLicenseData.Sales_License_Expiration_Date_Dt__c = null;
                                                }
                                                else if((prodRenewalGracePeriodInDays == null || prodRenewalGracePeriodInDays == 0 ) && prodExpiryDurationInDays > 0){
                                                    if(lic.Sales_License_Maintenance_Exp_Dt__c != null && lic.Sales_License_Maintenance_Exp_Dt__c >= Date.Today()){
                                                        newLicenseData.Sales_License_Expiration_Date_Dt__c = getLastDateOfMonth(lic.Sales_License_Maintenance_Exp_Dt__c.addDays(prodExpiryDurationInDays)).addDays(1);     
                                                    }else{
                                                        newLicenseData.Sales_License_Expiration_Date_Dt__c = getLastDateOfMonth(date.today().addDays(prodExpiryDurationInDays)).addDays(1); 
                                                    }
                                                }
                                                else if(prodRenewalGracePeriodInDays > 0  
                                                        && lic.Sales_License_Maintenance_Exp_Dt__c >(Date.today())
                                                        && prodExpiryDurationInDays > 0)
                                                {   
                                                    newLicenseData.Sales_License_Expiration_Date_Dt__c =  getLastDateOfMonth(lic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodExpiryDurationInDays)).addDays(1);
                                                } 
                                                else  if(prodRenewalGracePeriodInDays > 0 &&((lic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodRenewalGracePeriodInDays))>(Date.today())) && prodExpiryDurationInDays != null && lic.Sales_License_Maintenance_Exp_Dt__c <(Date.today())){
                                                    newLicenseData.Sales_License_Expiration_Date_Dt__c =  getLastDateOfMonth(date.today().addDays(prodExpiryDurationInDays)).addDays(1);
                                                }
                                                else if(prodRenewalGracePeriodInDays > 0 &&((lic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodRenewalGracePeriodInDays))<(Date.today())) && prodExpiryDurationInDays != null && lic.Sales_License_Maintenance_Exp_Dt__c <(Date.today())){
                                                    newLicenseData.Sales_License_Expiration_Date_Dt__c = getLastDateOfMonth(lic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodAdditionExpDurationGracePeriod)).addDays(1);
                                                }
                                                if(prodRenewalGracePeriodInDays == null || prodRenewalGracePeriodInDays == 0){
                                                    if(lic.Sales_License_Maintenance_Exp_Dt__c != null && lic.Sales_License_Maintenance_Exp_Dt__c >= Date.today()){
                                                        newLicenseData.Sales_License_Maintenance_Exp_Dt__c =  getLastDateOfMonth(lic.Sales_License_Maintenance_Exp_Dt__c.addMonths(prodSubscriptionTerm)); 
                                                    }else{
                                                        newLicenseData.Sales_License_Maintenance_Exp_Dt__c =  getLastDateOfMonth(date.today().addMonths(prodSubscriptionTerm)); 
                                                    }
                                                }
                                                else if(prodRenewalGracePeriodInDays > 0 
                                                        && lic.Sales_License_Maintenance_Exp_Dt__c >(Date.today())){
                                                            newLicenseData.Sales_License_Maintenance_Exp_Dt__c = getLastDateOfMonth(lic.Sales_License_Maintenance_Exp_Dt__c?.addMonths(prodSubscriptionTerm));
                                                        }
                                                else if(prodRenewalGracePeriodInDays > 0 
                                                        &&((lic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodRenewalGracePeriodInDays))>(Date.today()))){
                                                            newLicenseData.Sales_License_Maintenance_Exp_Dt__c = getLastDateOfMonth(date.today().addMonths(prodSubscriptionTerm));
                                                        }
                                                else if(prodRenewalGracePeriodInDays > 0 
                                                        &&((lic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodRenewalGracePeriodInDays))<(Date.today()))){
                                                            dte = lic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodRenewalGracePeriodInDays);
                                                            newLicenseData.Sales_License_Maintenance_Exp_Dt__c = getLastDateOfMonth((dte.addMonths(prodSubscriptionTerm)));
                                                        }
                                            newLicenseData.Sales_License_Avbl_Rehost_Nbr__c=lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c;
                                            if(lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c==true && lic.Sales_License_Available_Temp_Licenses__c != null){
                                                lic.Sales_License_Available_Temp_Licenses__c = lic.Sales_License_Quantity__c;                 
                                                newLicenseData.Sales_License_Available_Temp_Licenses__c=newLicenseData.Sales_License_Quantity__c;
                                            }
                                            if(lic.Sales_License_Status__c=='Unlicensed'){
                                                lic.Sales_License_Avbl_Qty_Nbr__c=lic.Sales_License_Quantity__c;
                                            }
                                            if(newLicenseData.Sales_License_Status__c=='Unlicensed'){
                                                newLicenseData.Sales_License_Avbl_Qty_Nbr__c=newLicenseData.Sales_License_Quantity__c;
                                            }                            
                                            if(newLicenseData.Sales_License_Status__c=='Licensed'){
                                                newLicenseData.Sales_License_Avbl_Qty_Nbr__c=0;
                                            }
                                            newLicenseData.Sales_License_Comments_Txt__c='License was manually renewed on '+date.today().format();
                                            newLicenseData.Sales_License_Renewal_Status__c='License Renewed';
                                            newLicenseData.Sales_License_Renewed_Date__c = Date.today();
                                        }
                                        if(baseLicenseUpdate==true){
                                            if(lic.Sales_License_Status__c=='Unlicensed'){
                                                lic.Sales_License_Avbl_Qty_Nbr__c=lic.Sales_License_Quantity__c;
                                            }
                                            if(lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c==true){
                                                lic.Sales_License_Available_Temp_Licenses__c = lic.Sales_License_Quantity__c;                 
                                            }
                                            lic.Sales_License_Avbl_Rehost_Nbr__c = lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c;              
                                            if( prodExpiryDurationInDays <= 0 || prodExpiryDurationInDays == null){ 
                                                lic.Sales_License_Expiration_Date_Dt__c = null;
                                            }
                                            else if((prodRenewalGracePeriodInDays == null || prodRenewalGracePeriodInDays == 0 ) && prodExpiryDurationInDays > 0){
                                                if(lic.Sales_License_Maintenance_Exp_Dt__c != null && lic.Sales_License_Maintenance_Exp_Dt__c >= Date.Today()){
                                                    lic.Sales_License_Expiration_Date_Dt__c = getLastDateOfMonth(lic.Sales_License_Maintenance_Exp_Dt__c.addDays(prodExpiryDurationInDays)).addDays(1); 
                                                }else{
                                                    lic.Sales_License_Expiration_Date_Dt__c = getLastDateOfMonth(date.today().addDays(prodExpiryDurationInDays)).addDays(1);     
                                                }
                                            }
                                            else if(prodRenewalGracePeriodInDays > 0  
                                                    && lic.Sales_License_Maintenance_Exp_Dt__c >(Date.today())
                                                    && prodExpiryDurationInDays > 0)
                                            {   
                                                lic.Sales_License_Expiration_Date_Dt__c =  getLastDateOfMonth(lic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodExpiryDurationInDays)).addDays(1);
                                            } 
                                            else  if(prodRenewalGracePeriodInDays > 0 &&((lic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodRenewalGracePeriodInDays))>(Date.today()))&& prodExpiryDurationInDays != null && lic.Sales_License_Maintenance_Exp_Dt__c <(Date.today())){
                                                lic.Sales_License_Expiration_Date_Dt__c =  getLastDateOfMonth(date.today().addDays(prodExpiryDurationInDays)).addDays(1);
                                            }
                                            else if(prodRenewalGracePeriodInDays > 0 &&((lic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodRenewalGracePeriodInDays))<(Date.today())) && prodExpiryDurationInDays != null && lic.Sales_License_Maintenance_Exp_Dt__c <(Date.today())){
                                                lic.Sales_License_Expiration_Date_Dt__c = getLastDateOfMonth(lic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodAdditionExpDurationGracePeriod)).addDays(1);
                                            }
                                            if(prodRenewalGracePeriodInDays == null || prodRenewalGracePeriodInDays == 0){
                                                if(lic.Sales_License_Maintenance_Exp_Dt__c != null && lic.Sales_License_Maintenance_Exp_Dt__c >= Date.today()){
                                                    lic.Sales_License_Maintenance_Exp_Dt__c =  getLastDateOfMonth(lic.Sales_License_Maintenance_Exp_Dt__c.addMonths(prodSubscriptionTerm));  
                                                }else{
                                                    lic.Sales_License_Maintenance_Exp_Dt__c =  getLastDateOfMonth(date.today().addMonths(prodSubscriptionTerm));  
                                                }
                                            }
                                            else if(prodRenewalGracePeriodInDays > 0 
                                                    && lic.Sales_License_Maintenance_Exp_Dt__c >(Date.today())){
                                                        lic.Sales_License_Maintenance_Exp_Dt__c = getLastDateOfMonth(lic.Sales_License_Maintenance_Exp_Dt__c?.addMonths(prodSubscriptionTerm));
                                                    }
                                            else if(prodRenewalGracePeriodInDays > 0 
                                                    &&((lic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodRenewalGracePeriodInDays))>(Date.today()))){
                                                        lic.Sales_License_Maintenance_Exp_Dt__c = getLastDateOfMonth(date.today().addMonths(prodSubscriptionTerm));
                                                    }
                                            else if(prodRenewalGracePeriodInDays > 0 
                                                    &&((lic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodRenewalGracePeriodInDays))<(Date.today()))){
                                                        dte = lic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodRenewalGracePeriodInDays);
                                                        lic.Sales_License_Maintenance_Exp_Dt__c = getLastDateOfMonth((dte.addMonths(prodSubscriptionTerm)));
                                                    }
                                            lic.Sales_License_Comments_Txt__c='License was manually renewed on '+date.today().format();
                                            lic.Sales_License_Renewal_Status__c='License Renewed';
                                            lic.Sales_License_Renewed_Date__c = Date.today();
                                        }
                                        newLicenseList.add(lic);
                                        listOfLicensesToProcess.add(lic);   
                                        orderproduct=lic.Sales_License_Order_Product__c;
                                        if(newLicense==true){
                                            newLicenseData.Id = null;
                                            listOfLicensesToProcess.add(newLicenseData);
                                            newLicenseList.add(newLicenseData);
                                        }
                                        newLicenseCreatedId=newLicenseData.Id;
                                    }
        list<Sales_License__c> NewlyInsertLicList=new list<Sales_License__c>();
        Id NewlyInsertLicId;
        List<Database.upsertResult> re = Database.upsert(listOfLicensesToProcess);
        if(listOfLicensesToProcess.size()>0){
            List<Sales_License_Order_Product__c> licOrdProdToUpdate = new List<Sales_License_Order_Product__c>();
            for(Sales_License_Order_Product__c licordprodlist : [select id,name,Sales_Quantity__c,Sales_License__r.Sales_License_Avbl_Qty_Nbr__c,Sales_License__r.Sales_License_Quantity__c,Sales_License__c from Sales_License_Order_Product__c where Sales_License__c IN:listOfLicensesToProcess])
            {     
             if(licordprodlist.Sales_Quantity__c!=licordprodlist.Sales_License__r.Sales_License_Quantity__c)
             {
                 licordprodlist.Sales_Quantity__c=licordprodlist.Sales_License__r.Sales_License_Quantity__c;
                 licOrdProdToUpdate.add(licordprodlist);
             }
            }
            update licOrdProdToUpdate;
            for(Database.upsertResult result:re){
                if(result.isSuccess() && result.isCreated()){
                        NewlyInsertLicId=(result.getId());
                }
            }  
            For(Sales_License__c newInsertList:[Select Id, Sales_License_Quantity__c ,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c,Sales_License_Avbl_Qty_Nbr__c ,Sales_License_Status__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c,
                                                Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c,
                                                Sales_License_Order_Product__r.Order.Sales_Order_Sub_Type__c,Sales_License_Avbl_Rehost_Nbr__c, Sales_License_Maintenance_Exp_Dt__c,Sales_License_Expiration_Date_Dt__c,
                                                Sales_License_Available_Temp_Licenses__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,
                                                Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Renewal_Period_Nbr__c,
                                                Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c,Sales_License_Host_Node_Id__c ,Sales_License_Contract__c,
                                                Sales_License_Product__r.SBQQ__SubscriptionTerm__c
                                                from Sales_License__c where Id =:NewlyInsertLicId]){
                                                    NewlyInsertLicList.add(newInsertList);
                                                    orderproduct=newInsertList.Sales_License_Order_Product__c;
                                                    OrderItem orderitemrecord = new OrderItem(Id=orderproduct);
                                                    if(orderitemrecord !=null){
                                                        mapOfOrdProdLicListLink.put(orderitemrecord,NewlyInsertLicList);
                                                    }
                                                }
            if(NewlyInsertLicList.size()>0)
            {
                mapOfOrdProdLicListLinkMap.put(renewalLic,mapOfOrdProdLicListLink);
                Sales_OrderProductTriggerUtility.createLicenseOrderProducts(mapOfOrdProdLicListLinkMap,null,mapOfOrdProdLicListLinkMap.keyset());
            }
            if(baseLicenseList.size()>0){
                mapOfOrdProdbaseLicListLinkMap.put(renewalLic,mapOfOrdProdLicListLink);
                Sales_OrderProductTriggerUtility.createLicenseOrderProducts(mapOfOrdProdbaseLicListLinkMap,null,mapOfOrdProdbaseLicListLinkMap.keyset());
            }       
        }                            
        for(Sales_License__c renewalLicense : [Select Id, Sales_License_Quantity__c ,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c,Sales_License_Avbl_Qty_Nbr__c ,Sales_License_Status__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c,
                                               Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c,
                                               Sales_License_Order_Product__r.Order.Sales_Order_Sub_Type__c,Sales_License_Avbl_Rehost_Nbr__c, Sales_License_Maintenance_Exp_Dt__c,Sales_License_Expiration_Date_Dt__c,
                                               Sales_License_Available_Temp_Licenses__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,
                                               Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Renewal_Period_Nbr__c,
                                               Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c,Sales_License_Host_Node_Id__c ,Sales_License_Contract__c,
                                               Sales_License_Product__r.SBQQ__SubscriptionTerm__c
                                               from Sales_License__c where Id =:renewalLic]){
                                                   renewalLicense.Sales_License_Avbl_Qty_Nbr__c=renewalLicense.Sales_License_Avbl_Qty_Nbr__c-noOfSeatsToRenew;
                                                   if(renewalLicense.Sales_License_Avbl_Qty_Nbr__c==0){
                                                       renewalLicense.Sales_License_Status__c='Renewals Applied';
                                                   }
                                                   listofRenewalLicense.add(renewalLicense);
                                               }
        if(listofRenewalLicense.size()>0){
            update listofRenewalLicense;
        }
        if(!Test.isRunningTest() && hostSet.size()>0){
            For(Id host : hostSet){
                Sales_LicenseGenIntegration_Utility.returnHostIdDetail(host,'HostId',contactforFile);
            }
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Sales_License__c> getLicenseList() {
        return [SELECT Id, Sales_License_Product__c, Sales_License_Product_OPN__c, Sales_License_Maintenance_Exp_Dt__c,
                Sales_License_Quantity__c, Sales_License_Avbl_Rehost_Nbr__c, Sales_License_Computer_Name__c
                FROM Sales_License__c];
    }
    @AuraEnabled(cacheable=true)
    public static Map<Id, Sales_License__c> validateRenewal(Id licenseId){
        Set<Id> contactId = new Set<Id>();
        Set<Id> foundProdIdSet = new Set<Id>();
        Set<Id> conIdSet=new Set<Id>();
        Map<Id,Set<Id>> delPrimaryContactMap = new Map<Id,Set<Id>>();
        Id loggerInUser=UserInfo.getUserId();
        User loggedInUserRecord=[Select Id,ContactId from User where Id =:loggerInUser limit 1];
        contactId.add(loggedInUserRecord.ContactId);
        if(contactId.size()>0){
            delPrimaryContactMap = Sales_LicenseGenerationGenericFunctions.validateDelegateUsers(contactId);
        }
        for(Id conId1 : delPrimaryContactMap.keySet()) {
            conIdSet.addAll(delPrimaryContactMap.get(conId1));
        }
        List<Sales_License__c> renewalLicList = [SELECT Id, Name, Sales_License_Account__c,Sales_License_Status__c, Sales_License_Expiration_Date_Dt__c,Sales_License_Maintenance_Exp_Dt__c,
                                                 Sales_License_Primary_Admin_Contact__c,Sales_License_Type__c,Sales_License_Lic_User_Contact_ID__c,
                                                 Sales_License_Product__c,Sales_License_Quantity__c,Sales_License_Order_Product__r.OrderItemNumber,Sales_License_Order_Product__c, Sales_Tool_License_Type__c,
                                                 Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c, Sales_License_Order__r.Sales_Order_Sub_Type__c, Sales_License_Order_Product__r.Sales_Contact__c,
                                                 Sales_License_Avbl_Qty_Nbr__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c
                                                 FROM Sales_License__c where Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c = 'RENEWAL'
                                                 AND Sales_License_Avbl_Qty_Nbr__c > 0 AND Id =:licenseId ];
        if(renewalLicList.size()>0){
            for(Sales_License__c renewalLicItem:renewalLicList){
                foundProdIdSet.add(renewalLicItem.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c);
            }
        }
        List<Sales_License__c> baseLicList = [SELECT Id, Name, Sales_License_Account__c,Sales_License_Status__c, Sales_License_Expiration_Date_Dt__c,Sales_License_Maintenance_Exp_Dt__c,
                                              Sales_License_Primary_Admin_Contact__c,Sales_License_Type__c,Sales_License_Lic_User_Contact_ID__c,Sales_License_Avbl_Qty_Nbr__c,
                                              Sales_License_Product__c,Sales_License_Quantity__c,Sales_License_Order_Product__r.OrderItemNumber,Sales_License_Order_Product__c, Sales_Tool_License_Type__c 
                                              FROM Sales_License__c where
                                              Sales_License_Product__c IN:foundProdIdSet 
                                              AND (Sales_License_Primary_Admin_Contact__c IN:contactId OR Sales_License_Lic_User_Contact_ID__c IN:contactId
                                                   OR(Sales_License_Primary_Admin_Contact__c IN : conIdSet))
                                              AND Sales_License_Type__c ='ORIGINAL'
                                              AND Sales_License_Avbl_Qty_Nbr__c > 0
                                              AND Sales_License_Status__c = 'UNLICENSED'];
        Map<Id,Sales_License__c> baseLicMap = new Map<Id,Sales_License__c>();
        if(baseLicList.size()>0){
            for(Sales_License__c licItem :baseLicList){
                if(licItem.Sales_License_Maintenance_Exp_Dt__c < System.Today()){
                    baseLicMap.put(licItem.Id, licItem);
                }
            }
        }
        return baseLicMap;
    }
    @AuraEnabled    
    public static List<Sales_License__c> getBaseLicenseRecords(Id licRecordId){
        List<Sales_License__c> baseLicensesList = new List<Sales_License__c>();
        Map<Id,Set<Id>> delPrimaryContactMap = new Map<Id,Set<Id>>();
        Set<Id> conIdSet=new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        try{
            if(licRecordId != null){ 
                Sales_License__c licRecord = [Select Id, Name,Sales_License_Primary_Admin_Contact__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c from Sales_License__c where id = :licRecordId];
                Id baseProdId = licRecord.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c;
                Id contactId = licRecord.Sales_License_Primary_Admin_Contact__c;
                contactIdSet.add(contactId);
                if(String.isNotBlank(contactId)){
                    delPrimaryContactMap = Sales_LicenseGenerationGenericFunctions.validateDelegateUsers(contactIdSet);
                }
                for(Id conId1 : delPrimaryContactMap.keySet()) {
                    conIdSet.addAll(delPrimaryContactMap.get(conId1));
                }
                if(baseProdId == null){
                    baseProdId = licRecord.Sales_License_Product__c;    
                }
                baseLicensesList = [Select Id,Name, Sales_License_Avbl_Rehost_Nbr__c, Sales_License_Host_Node_Id__c, Sales_License_Host_Node_Id__r.Name, Sales_License_Host_Node_Id__r.Sales_Computer_Name_Txt__c,Sales_License_Host_Node_Txt__c, Sales_License_Avbl_Qty_Nbr__c, Sales_License_Quantity__c, Sales_License_Maintenance_Exp_Dt__c,  
                                    Sales_License_Expiration_Date_Dt__c, Sales_License_Product__c, Sales_License_Product__r.Name, Sales_License_Product__r.Core_OPN__c , Sales_License_Type__c from Sales_License__c where Sales_License_Quantity__c > 0 and Sales_License_Product__c = :baseProdId
                                    and (Sales_License_Primary_Admin_Contact__c IN:contactIdSet OR Sales_License_Lic_User_Contact_ID__c IN:contactIdSet
                                         OR(Sales_License_Primary_Admin_Contact__c IN : conIdSet)) and Sales_License_Type__c != 'Evaluation' AND Sales_License_Type__c !='Employee' AND  Sales_License_Status__c ='Licensed' and Sales_License_Web_Display_Flag__c = true and id !=:licRecordId];
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return baseLicensesList;
    }
    @AuraEnabled(cacheable=true)
    public static Boolean  checkUserPermissionSet(){
        Boolean isValiduser=false;
        List<PermissionSetAssignment> pset = [SELECT Id,Assignee.Name,PermissionSet.Name, PermissionSet.Label 
                                              FROM PermissionSetAssignment WHERE AssigneeId= : userinfo.getuserid()];
        for (PermissionSetAssignment psa: pset)
        {
            List<String> PsSetName = System.Label.Sales_Bypass_Permissionset.Split(', ');
            for (String PermissionSetName  : PsSetName){
                if(psa.PermissionSet.Name.contains(PermissionSetName)){
                    isValiduser=true; 
                }
            }
        }                                          
        return isValiduser;    
    }*/
}