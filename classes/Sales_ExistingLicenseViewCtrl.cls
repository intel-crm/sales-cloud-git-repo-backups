/*********************************************************************************************************************
Class Name    : Sales_ExistingLicenseViewCtrl
Version       : 1.0
Created Date  : March 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma          21-March-2021             Controller class for License View Component.
* Sahil Bahadure 		  9-June-2022 				Added sorting logic on License View Component.
* *********************************************************************************************************************/
public without sharing class Sales_ExistingLicenseViewCtrl {
    private static final String LICSTATUS_UNLICENSED='Unlicensed';
    private static final String ORIGINAL='Original';
    private static final String RELATED_PRODUCT='Related Product';
    private static final String LICSTATUS_CANCELLED='Cancelled';
    public static List<Id> recordsWithDistributeAction=new List<Id>();
    @AuraEnabled(cacheable=true)
    public static licenseWrapperClass getLicenseListForAdmin(String recId) {
        Id recordId=(Id)recId;
        String sObjName = recordId?.getSObjectType().getDescribe().getName();
        Id orderId;
        Set<Id> orderProductIdSet = new Set<Id>();
        Set<String> nonCorporateWithOriginalLicense = new Set<String>();
        //String legacyContractId;-- unused
        Switch on sObjName{
            when 'Order'{
                for(OrderItem item:[Select Id,OrderId from OrderItem where OrderId =:recId]){
                    orderProductIdSet.add(item.Id);                    
                }
            }
            when 'Contract'{
                for(OrderItem item:[Select Id,Order.Status,Order.SBQQ__Contracted__c,SBQQ__Contract__c, SBQQ__Contract__r.Sales_Legacy_Contract_Id__c from OrderItem where SBQQ__Contract__c =:recId And Order.SBQQ__Contracted__c=true And Order.Status='Activated']){
                    orderProductIdSet.add(item.Id);
                }
            }
            when 'OrderItem'{
                orderProductIdSet.add(recId);
            }
        }
        List<licenseDataTableRecordWrapper> licenseJunctionWrapperList = new List<licenseDataTableRecordWrapper>();
        User loggerInUser = [Select Id,ContactId, AccountId from User where Id=:UserInfo.getUserId()];
        Id contactId = loggerInUser.ContactId;
        List<Sales_License_Order_Product__c> junctionRecordList = new List<Sales_License_Order_Product__c>();
        String junctionRecordQuery = 'Select Id, Sales_License__c,Sales_Order_Product__c,Sales_License__r.Sales_License_Order_Product__r.OrderItemNumber,'+ 
            'Sales_License_Expiration_Date_Dt__c,Sales_Quantity__c,Sales_License__r.Sales_License_Activation_Code__c,Sales_License__r.Name,'+
            'Sales_License__r.Sales_License_Product__c,Sales_License__r.Sales_License_Product_OPN__c,Sales_License__r.Sales_License_Product__r.Name,Sales_License__r.Sales_License_Status__c,'+
            'Sales_License__r.Sales_License_Maintenance_Exp_Dt__c,Sales_License__r.Sales_License_Expiration_Date_Dt__c,Sales_License__r.Sales_License_Host_Node_Id__c,Sales_License__r.Sales_License_Host_Node_Id__r.Name,'+
            'Sales_License__r.Sales_License_Primary_Admin_Contact__r.Name, Sales_License__r.Sales_License_Lic_User_Contact_ID__c,'+
            'Sales_License__r.Sales_License_Lic_User_Contact_ID__r.Name,Sales_License__r.Sales_License_Avbl_Qty_Nbr__c,Sales_License__r.Sales_License_Order_Product__r.Order.Status,'+
            'Sales_License__r.Sales_License_Type__c,Sales_License__r.Sales_License_Order_Product__c,Sales_License__r.Sales_License_Order_Product__r.Product2Id,'+
            'Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c,Sales_License__r.Sales_License_Order_Product__r.Sales_Contact__c, '+
            'Sales_License__r.Sales_License_SAPLine_Nbr__c,Sales_License__r.Sales_License_Quantity__c,Sales_License__r.Sales_Parent_License__c,Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c, Sales_License__r.Sales_License_Web_Display_Flag__c '+
            'from Sales_License_Order_Product__c';
        String whereCondition = '';
        if(contactId==null){
            if(recordId!=null){
                if(sObjName == 'Contract'){
                    whereCondition = ' where (Sales_License_ContractId__c = :recordId and Sales_License_ContractId__r.Sales_Legacy_Contract_Id__c != null) or (Sales_Order_Product__c IN :orderProductIdSet and Sales_Order_Product__r.SBQQ__Contract__r.Sales_Legacy_Contract_Id__c = null)';
                }else{
                    whereCondition = ' where Sales_Order_Product__c IN :orderProductIdSet';
                }
            }                        
        }
        else{
            whereCondition = ' where Sales_License__r.Sales_License_Lic_User_Contact_ID__c=:contactId';
        }
        whereCondition=whereCondition+' order by Sales_License__r.Sales_License_Product_OPN__c,Sales_License__c ASC' ;
        Set<Id> productIdSet = new Set<Id>();
        Set<Id> licenseCreatedWIthParent = new Set<Id>();
        Set<Id> parentLicenseIds = new Set<Id>();
        Set<Id> orderItemIds = new Set<Id>();
        String finalQueryString= junctionRecordQuery+whereCondition;
        junctionRecordList = Database.query(finalQueryString);
        Map<Id,licenseDataTableRecordWrapper> junctionRecordMap = new Map<Id,licenseDataTableRecordWrapper>();	
        for(Sales_License_Order_Product__c junctionRecord : junctionRecordList){
            if(!junctionRecordMap.containsKey(junctionRecord.Sales_License__c)){
                productIdSet.add(junctionRecord.Sales_License__r.Sales_License_Product__c);
                licenseDataTableRecordWrapper licenseJunctionWrapper = new licenseDataTableRecordWrapper();
                licenseJunctionWrapper.productFromOrderProduct = junctionRecord.Sales_License__r.Sales_License_Order_Product__r.Product2Id;
                licenseJunctionWrapper.productOPN = junctionRecord.Sales_License__r.Sales_License_Product_OPN__c;
                licenseJunctionWrapper.licenseId = junctionRecord.Sales_License__c;
                licenseJunctionWrapper.orderItemRecordId = junctionRecord.Sales_License__r.Sales_License_Order_Product__c;
                licenseJunctionWrapper.orderNumber = junctionRecord.Sales_License__r.Sales_License_Order_Product__r.OrderItemNumber;
                licenseJunctionWrapper.licenseActivationCode = junctionRecord.Sales_License__r.Sales_License_Activation_Code__c;
                licenseJunctionWrapper.productId = junctionRecord.Sales_License__r.Sales_License_Product__c;
                licenseJunctionWrapper.productName = junctionRecord.Sales_License__r.Sales_License_Product__r.Name;
                licenseJunctionWrapper.maintenanaceExpiration = (Date)junctionRecord.Sales_License__r.Sales_License_Maintenance_Exp_Dt__c;
                licenseJunctionWrapper.primaryComputerId =  junctionRecord.Sales_License__r.Sales_License_Host_Node_Id__c;
                licenseJunctionWrapper.primaryComputerName =  junctionRecord.Sales_License__r.Sales_License_Host_Node_Id__r.Name;
                licenseJunctionWrapper.salesExpirationDate = (Date)junctionRecord.Sales_License__r.Sales_License_Expiration_Date_Dt__c;
                licenseJunctionWrapper.primaryContactId = junctionRecord.Sales_License__r.Sales_License_Primary_Admin_Contact__c;
                licenseJunctionWrapper.primaryContactName = junctionRecord.Sales_License__r.Sales_License_Primary_Admin_Contact__r.Name;
                licenseJunctionWrapper.licenseUserId = junctionRecord.Sales_License__r.Sales_License_Lic_User_Contact_ID__c;
                licenseJunctionWrapper.licenseUserName = junctionRecord.Sales_License__r.Sales_License_Lic_User_Contact_ID__r.Name;
                licenseJunctionWrapper.quantity = junctionRecord.Sales_License__r.Sales_License_Quantity__c;
                licenseJunctionWrapper.availableQuanity = junctionRecord.Sales_License__r.Sales_License_Avbl_Qty_Nbr__c;
                licenseJunctionWrapper.licenseType = junctionRecord.Sales_License__r.Sales_License_Type__c;
                licenseJunctionWrapper.licenseStatus = junctionRecord.Sales_License__r.Sales_License_Status__c;
                licenseJunctionWrapper.toolLicenseType = junctionRecord.Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c;
                licenseJunctionWrapper.toolProdLicType = junctionRecord.Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c;
                licenseJunctionWrapper.licenseName= junctionRecord.Sales_License__r.Name;
                licenseJunctionWrapper.parentLicense = junctionRecord.Sales_License__r.Sales_Parent_License__c;
                licenseJunctionWrapper.contactFromOrderProduct = junctionRecord.Sales_License__r.Sales_License_Order_Product__r.Sales_Contact__c;
                licenseJunctionWrapper.webDisplayFlag = junctionRecord.Sales_License__r.Sales_License_Web_Display_Flag__c;       
                if(junctionRecord.Sales_License__r.Sales_License_Type__c==ORIGINAL && junctionRecord.Sales_License__r.Sales_License_Status__c!=LICSTATUS_CANCELLED && junctionRecord.Sales_License__r.Sales_License_Order_Product__r.Order.Status=='Activated'){
                    licenseJunctionWrapper.showCreateOptionLicenseAction=false; 
                }
                if(junctionRecord.Sales_License__r.Sales_Parent_License__c!=null){
                    parentLicenseIds.add(junctionRecord.Sales_License__r.Sales_Parent_License__c);
                    licenseCreatedWIthParent.add(junctionRecord.Sales_License__r.Sales_License_Product__c);
                }    
                if((junctionRecord.Sales_License__r.Sales_License_Type__c=='Amend Contract - Qty Decrease' ||junctionRecord.Sales_License__r.Sales_License_Type__c=='Renew Contract - Qty Decrease') && (junctionRecord.Sales_License__r.Sales_License_Avbl_Qty_Nbr__c!=0 &&junctionRecord.Sales_License__r.Sales_License_Status__c!=LICSTATUS_CANCELLED)){
                    recordsWithDistributeAction.add(junctionRecord.Sales_License__c);
                }
                orderItemIds.add(junctionRecord.Sales_License__r.Sales_License_Order_Product__c);
                junctionRecordMap.put(junctionRecord.Sales_License__c,licenseJunctionWrapper);	   
            }
        }
        Map<Id,licenseDataTableRecordWrapper> updatedjunctionRecordMap = new Map<Id,licenseDataTableRecordWrapper>();
        for(Id distRecordIds:recordsWithDistributeAction){
            updatedjunctionRecordMap.put(distRecordIds,junctionRecordMap.get(distRecordIds));
        }
        updatedjunctionRecordMap.putAll(junctionRecordMap);      
        if(!updatedjunctionRecordMap.isEmpty()){
            licenseJunctionWrapperList.addAll(updatedjunctionRecordMap.values());
        }
        Map<Id,Boolean> isCorporateMap = new Map<Id,Boolean>();
        Map<Id,Boolean> isNonCorporateMap = new Map<Id,Boolean>();
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> conIdSet = new Set<Id>();
        Set<Id> foundationProductIdSet = new Set<Id>();
        Map<Id,Id> productToFoundProdMap = new Map<Id,Id>();
        Map<Id,List<Id>> tempProductToFoundProdFinalMap = new Map<Id,List<Id>>();
        Map<Id,List<Id>> productToFoundProdFinalMap = new Map<Id,List<Id>>();
        Map<Id,Sales_License__c> licMap = new Map<Id,Sales_License__c>();
        for(Sales_License__c lic:[SELECT Id, Sales_License_Status__c,Sales_License_Contract__c,Sales_License_Order__c,Sales_License_Order_Product__c,Sales_License_Order_Product__r.Product2Id,Sales_License_Product__c,
                                  Sales_License_Product__r.Name,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c,Sales_License_Type__c,Sales_License_Quantity__c,Sales_Tool_License_Type__c,
                                  Sales_License_Web_Display_Flag__c FROM Sales_License__c where Sales_License_Order_Product__c IN:orderProductIdSet and Sales_License_Product__c!=null and Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c!=null]){
                                      licMap.put(lic.Sales_License_Order_Product__c,lic);
                                  }
        for(OrderItem orderItemRec:[Select Id,Order.Sales_End_Customer_Account__c,Product2Id,Sales_Contact__c,
                                    Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c,
                                    Order.Sales_Order_Sub_Type__c,Order.SBQQ__Quote__c,Order.SBQQ__Quote__r.SBQQ__Type__c
                                    from OrderItem where Id IN:orderProductIdSet]){
                                        if(orderItemRec.Order.SBQQ__Quote__c!=null 
                                           && (orderItemRec.Order.SBQQ__Quote__r.SBQQ__Type__c=='Renewal'   || orderItemRec.Order.SBQQ__Quote__r.SBQQ__Type__c=='Amendment')){
                                               isCorporateMap.put(orderItemRec.Id,true);
                                           }
                                        else if(orderItemRec.Order.SBQQ__Quote__c==null){
                                            isNonCorporateMap.put(orderItemRec.Id,true);
                                            if(orderItemRec.Sales_Contact__c!=null){
                                                contactIdSet.add(orderItemRec.Sales_Contact__c);
                                                conIdSet.add(orderItemRec.Sales_Contact__c);
                                            }
                                            if(licMap.containsKey(orderItemRec.Id) && orderItemRec.Product2Id!=null &&  licMap.get(orderItemRec.Id).Sales_License_Product__c!=null && orderItemRec.Product2Id == licMap.get(orderItemRec.Id).Sales_License_Product__c){
                                                foundationProductIdSet.add(orderItemRec.Product2?.Core_Product_Ext_Attribute_Id__r?.Core_Foundation_Product_Id__c);
                                                productToFoundProdMap.put(orderItemRec.Product2Id,orderItemRec.Product2?.Core_Product_Ext_Attribute_Id__r?.Core_Foundation_Product_Id__c);
                                            }   
                                            else if(licMap.containsKey(orderItemRec.Id) && orderItemRec.Product2Id!=null && orderItemRec.Product2Id != licMap.get(orderItemRec.Id).Sales_License_Product__c ){
                                                foundationProductIdSet.add(licMap.get(orderItemRec.Id).Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c);
                                                productToFoundProdMap.put(licMap.get(orderItemRec.Id).Sales_License_Product__c,licMap.get(orderItemRec.Id).Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c);
                                            }
                                        }
                                    }
        foundationProductIdSet.remove(null);
        Set<Id> tempFoundIdSet=new Set<Id>();
        Set<Id> finalFoundProdIdSet = new Set<Id>();
        List<Sales_License_Admin_Delegate__c> delegateList = new List<Sales_License_Admin_Delegate__c>(); 
        Map<Id,Set<Id>> delPrimaryContactMap = new Map<Id,Set<Id>>();
        for(SBQQ__ProductOption__c childProd:[Select Id,SBQQ__Type__c, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c from SBQQ__ProductOption__c where SBQQ__Type__c ='Accessory' AND SBQQ__ConfiguredSKU__c IN :foundationProductIdSet]){
            tempFoundIdSet.add(childProd.SBQQ__ConfiguredSKU__c);
            finalFoundProdIdSet.add(childProd.SBQQ__OptionalSKU__c);
            if(tempProductToFoundProdFinalMap.containsKey(childProd.SBQQ__ConfiguredSKU__c)){
                List<Id> optionProductId = tempProductToFoundProdFinalMap.get(childProd.SBQQ__ConfiguredSKU__c);
                optionProductId.add(childProd.SBQQ__OptionalSKU__c);
                tempProductToFoundProdFinalMap.put(childProd.SBQQ__ConfiguredSKU__c,optionProductId);
            }
            else{
                List<Id> optionProductId = new List<Id>();
                optionProductId.add(childProd.SBQQ__OptionalSKU__c);
                tempProductToFoundProdFinalMap.put(childProd.SBQQ__ConfiguredSKU__c,optionProductId);
            }
        }
        for(Id foundationId:foundationProductIdSet){
            if(!tempFoundIdSet.contains(foundationId)){
                finalFoundProdIdSet.add(foundationId);
                List<Id> optionProductId = new List<Id>();
                optionProductId.add(foundationId);
                tempProductToFoundProdFinalMap.put(foundationId,optionProductId);
            }
        }
        for(Id productId:productToFoundProdMap.keySet()){
            Id foundationProdId = productToFoundProdMap.get(productId);
            if(foundationProdId!=null){
                List<Id> childProd = tempProductToFoundProdFinalMap.get(foundationProdId);
                productToFoundProdFinalMap.put(productId,childProd);
            }
            else{
                List<Id> childProd = new List<Id>();
                childProd.add(productId);
                productToFoundProdFinalMap.put(productId,childProd);
            }
        }
        if(contactIdSet.size()>0){
            delPrimaryContactMap = Sales_LicenseGenerationGenericFunctions.validateDelegateUsers(contactIdSet);
        }
        for(Id conId : delPrimaryContactMap.keySet()) {
            conIdSet.addAll(delPrimaryContactMap.get(conId));
        }
        finalFoundProdIdSet.remove(null);
        contactIdSet.remove(null);
        conIdSet.remove(null);
        Map<String,Boolean> expiredLicenseMap = new Map<String,Boolean>();
        for(Sales_License__c nonCorLicense:[SELECT Id, Sales_License_Account__c, Sales_License_Avbl_Qty_Nbr__c, Sales_License_Status__c,Sales_License_Avbl_Rehost_Nbr__c,
                                            Sales_License_Contract__c, Sales_License_Expiration_Date_Dt__c,  Sales_License_Lic_User_Contact_ID__c,
                                            Sales_License_Activation_Code__c,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Order__c,Sales_License_Order_Product__c,Sales_License_Primary_Admin_Contact__c,
                                            Sales_License_Primary_Admin_Contact__r.Name,Sales_License_Product__c,Sales_License_Product__r.Name,Sales_License_Type__c,
                                            Sales_License_Start_Date_Dt__c,Sales_License_Quantity__c,Sales_License_SubscriptionId__c,Sales_Tool_License_Type__c,Sales_License_Web_Display_Flag__c,Sales_Distributed_Quantity__c
                                            FROM Sales_License__c where Sales_License_Product__c IN:finalFoundProdIdSet 
                                            AND (Sales_License_Primary_Admin_Contact__c IN:conIdSet OR Sales_License_Lic_User_Contact_ID__c IN:contactIdSet) 
                                            And Sales_License_Type__c=:ORIGINAL And Sales_Parent_License__c=null ]){
                                                String key;
                                                if(nonCorLicense.Sales_License_Primary_Admin_Contact__c!=null){
                                                    key = nonCorLicense.Sales_License_Primary_Admin_Contact__c+'-'+nonCorLicense.Sales_License_Product__c;
                                                }
                                                else if(nonCorLicense.Sales_License_Lic_User_Contact_ID__c!=null){
                                                    key = nonCorLicense.Sales_License_Lic_User_Contact_ID__c+'-'+nonCorLicense.Sales_License_Product__c;
                                                }
                                                else{
                                                    key = null+'-'+nonCorLicense.Sales_License_Product__c;
                                                }
                                                if(nonCorLicense.Sales_License_Maintenance_Exp_Dt__c>=System.today()){
                                                    expiredLicenseMap.put(key,false);
                                                }
                                                else{
                                                    expiredLicenseMap.put(key,true);
                                                }
                                                nonCorporateWithOriginalLicense.add(key);
                                            }  
        List<String> nonCorporateWithOriginalLicenseList = new List<String>();
        nonCorporateWithOriginalLicenseList.addAll(nonCorporateWithOriginalLicense);
        List<Id> tempList = new List<Id>();
        tempList.addAll(parentLicenseIds);
        licenseWrapperClass licWrapper = new licenseWrapperClass();
        licWrapper.licenseJunctionWrapperList=licenseJunctionWrapperList;
        licWrapper.nonCorporateWithOriginalLicenseList = nonCorporateWithOriginalLicenseList;
        licWrapper.isCorporateMap = isCorporateMap;
        licWrapper.isNonCorporateMap = isNonCorporateMap;
        licWrapper.productToFoundProdFinalMap = productToFoundProdFinalMap;
        licWrapper.expiredLicenseMap = expiredLicenseMap;
        licWrapper.parentLicenseIds = tempList;
        return licWrapper;
    }
    @AuraEnabled(cacheable=true)
    public static licenseWrapperClass getExistingLicenseList(String orderItemId,String licenseType) {
        Set<Id> conIdSet = new Set<Id>();
        Boolean addSeatOrder=false;
        OrderItem orderItemRec=[Select Id,Order.Sales_End_Customer_Account__c,Product2Id,Sales_Contact__c,
                                Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c,
                                Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,
                                Order.Sales_Order_Sub_Type__c,Order.SBQQ__Quote__c,Order.SBQQ__Quote__r.SBQQ__Type__c
                                from OrderItem where Id =:orderItemId Limit 1];
        Id orderId = orderItemRec.OrderId;
        Id conId=orderItemRec.Sales_Contact__c;
        Id prodId=orderItemRec.Product2Id;
        Id foundProdOfRenewalId=orderItemRec.Product2?.Core_Product_Ext_Attribute_Id__r?.Core_Foundation_Product_Id__c;
        String extendedToolType = orderItemRec.Product2?.Core_Product_Ext_Attribute_Id__r?.Core_Prod_Tool_Type_Nm__c;
        Id renewalContractId; 
        //Id oldAmendOrderId;--unused
        Id amendQuoteContractId; 
        Boolean isCorporateOrder=false;
        Boolean isAmendOrder = false;
        Set<Id> foundProdIdSet=new Set<Id>();
        Set<Id> baseProdIdSet =new Set<Id>();
        List<Sales_License_Admin_Delegate__c> delegateList = new List<Sales_License_Admin_Delegate__c>(); 
        List<Sales_License__c> licReturnList=new List<Sales_License__c>();
        Set <Id> contactIdSet = new Set<Id>();
        Map<Id,Set<Id>> delPrimaryContactMap = new Map<Id,Set<Id>>();
        contactIdSet.add(conId);
        if(orderItemRec.Order.SBQQ__Quote__c!=null){
            if(orderItemRec.Order.SBQQ__Quote__r.SBQQ__Type__c=='Renewal'){
                isCorporateOrder = true;
            }
            else if(orderItemRec.Order.SBQQ__Quote__r.SBQQ__Type__c=='Amendment'){
                isAmendOrder=true;
            }
        }
        if(isCorporateOrder){
            renewalContractId=  [Select Id,SBQQ__Quote__r.Sales_Renewed_from_Contract_Id__c from Order where Id =:orderId AND SBQQ__Quote__r.SBQQ__Type__c='Renewal' LIMIT 1].SBQQ__Quote__r.Sales_Renewed_from_Contract_Id__c;
        }
        if(isAmendOrder){
            amendQuoteContractId = [Select Id,SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Quote__c from Order where Id =:orderId AND SBQQ__Quote__r.SBQQ__Type__c='Amendment' Limit 1].SBQQ__Quote__r?.SBQQ__MasterContract__c;
        }
        List<SBQQ__ProductOption__c> compositeBundleChildList=[Select Id,SBQQ__Type__c, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c from SBQQ__ProductOption__c where SBQQ__Type__c ='Accessory' AND (SBQQ__ConfiguredSKU__c=:foundProdOfRenewalId OR SBQQ__ConfiguredSKU__c=:prodId)];
        if(compositeBundleChildList.size()>0){
            for(SBQQ__ProductOption__c childProd:compositeBundleChildList){
                if(childProd.SBQQ__ConfiguredSKU__c==foundProdOfRenewalId){
                    foundProdIdSet.add(childProd.SBQQ__OptionalSKU__c); 
                }
                else if(childProd.SBQQ__ConfiguredSKU__c==prodId){
                    baseProdIdSet.add(childProd.SBQQ__OptionalSKU__c);
                }
            }
        }else{
            foundProdIdSet.add(orderItemRec.Product2?.Core_Product_Ext_Attribute_Id__r?.Core_Foundation_Product_Id__c);
            baseProdIdSet.add(prodId);           
        }
        if(contactIdSet.size()>0){
            delPrimaryContactMap = Sales_LicenseGenerationGenericFunctions.validateDelegateUsers(contactIdSet);
        }
        for(Id conId1 : delPrimaryContactMap.keySet()) {
            conIdSet.addAll(delPrimaryContactMap.get(conId1));
        }
        foundProdIdSet.remove(null);
        Date todayDate = System.today();
        User loggerInUser = [Select Id,ContactId, AccountId from User where Id=:UserInfo.getUserId()];
        String licQuery = 'SELECT Id,Name, Sales_License_Account__c, Sales_License_Avbl_Qty_Nbr__c, Sales_License_Status__c,Sales_License_Avbl_Rehost_Nbr__c,'+
            'Sales_License_Contract__c,Sales_License_Quantity__c, Sales_License_Host_Node_Id__c,Sales_License_Host_Node_Id__r.Name,Sales_License_Expiration_Date_Dt__c, Sales_License_Lic_User_Contact_ID__c,'+
            'Sales_License_Activation_Code__c,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Order__c,Sales_License_Order_Product__c,Sales_License_Primary_Admin_Contact__c,'+
            'Sales_License_Primary_Admin_Contact__r.Name,Sales_License_Product__c,Sales_License_Product__r.Name,Sales_License_Type__c,'+
            'Sales_License_Start_Date_Dt__c,Sales_License_SubscriptionId__c,Sales_Tool_License_Type__c,Sales_License_Web_Display_Flag__c,Sales_Distributed_Quantity__c'+
            ' FROM Sales_License__c';
        String whereCondition='';
        conIdSet.add(conId);
        if(isCorporateOrder){
            whereCondition = ' where Sales_License_Product__c IN:baseProdIdSet AND Sales_License_Order_Product__r.SBQQ__Contract__c=:renewalContractId AND Sales_License_Type__c=:ORIGINAL And Sales_Parent_License__c=null order by Sales_Processed__c asc';
        }
        else if(isAmendOrder){
            whereCondition = ' where Sales_License_Product__c IN:baseProdIdSet AND Sales_License_Order_Product__r.SBQQ__Contract__c=: amendQuoteContractId AND Sales_License_Type__c=:ORIGINAL And Sales_Parent_License__c=null order by Sales_Processed__c asc';
        }
        else{
            if(orderItemRec.Order.SBQQ__Quote__c==  null&&licenseType==System.Label.Sales_Licencse_Add_Seat_record_type &&extendedToolType=='ADD SEAT'){
                addSeatOrder=true;
                whereCondition = ' where Sales_License_Product__c IN:foundProdIdSet AND (Sales_License_Primary_Admin_Contact__c IN:conIdSet OR Sales_License_Lic_User_Contact_ID__c=:conId) AND Sales_License_Type__c=:ORIGINAL And Sales_Parent_License__c=null AND Sales_License_Maintenance_Exp_Dt__c>=:todayDate order by Sales_Processed__c asc';
            }
            else{
                whereCondition = ' where Sales_License_Product__c IN:foundProdIdSet AND (Sales_License_Primary_Admin_Contact__c IN:conIdSet OR Sales_License_Lic_User_Contact_ID__c=:conId)AND Sales_License_Type__c=:ORIGINAL And Sales_Parent_License__c=null order by Sales_Processed__c asc';
            }
        }
        String queryString = licQuery+whereCondition;
        licReturnList= Database.query(queryString);
        licenseWrapperClass licWrapper = new licenseWrapperClass();
        licWrapper.licenseList=licReturnList;
        licWrapper.addSeatOrder=addSeatOrder;
        Set<Id> orderItemIdSet = new Set<Id>{orderItemId};
            licWrapper.processedLicIdList=getProcessedLicenseList(orderItemIdSet,licReturnList);
        return licWrapper;
    }
    @AuraEnabled(cacheable=true)
    public static licenseWrapperClass getOptionProducts(String licenseId,String prodId,String orderItemId, String toolType){
        List<SBQQ__ProductOption__c> productOptionList = new List<SBQQ__ProductOption__c>();
        List<SBQQ__ProductOption__c> productOptionReturnList = new List<SBQQ__ProductOption__c>();
        Set<Id> optionProductIdSet = new Set<Id>();
        Set<Id> optionProductsToRemove= new Set<Id>();
        productOptionList = [Select Id,SBQQ__Type__c, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c, 
                             SBQQ__OptionalSKU__r.Name from SBQQ__ProductOption__c 
                             where SBQQ__Type__c =:RELATED_PRODUCT AND SBQQ__ConfiguredSKU__c=:prodId];
        if(orderItemId!='' && orderItemId!=null){ 
            for(SBQQ__ProductOption__c prodOption : productOptionList){
                optionProductIdSet.add(prodOption.SBQQ__OptionalSKU__c);
            }
            for(Sales_License__c licRecord:[Select Id,Sales_License_Product__c,Sales_Parent_License__c,Sales_License_Order_Product__c
                                            from Sales_License__c where Sales_Parent_License__c!=null 
                                            and Sales_License_Product__c IN :optionProductIdSet AND Sales_License_Order_Product__c=: orderItemId]){
                                                if((toolType=='Fixed' && licRecord.Sales_Parent_License__c==licenseId) || toolType!='Fixed'){
                                                    optionProductsToRemove.add(licRecord.Sales_License_Product__c);
                                                }
                                            }
            for(SBQQ__ProductOption__c prodOption : productOptionList){
                if(!optionProductsToRemove.contains(prodOption.SBQQ__OptionalSKU__c)){
                    productOptionReturnList.add(prodOption);
                }
            }
            licenseWrapperClass licWrapper = new licenseWrapperClass();
            licWrapper.productOptionReturnList = productOptionReturnList;
            if(productOptionList.size()==0){
                licWrapper.optionNotAvailable = true;
            }
            return licWrapper;
        }
        else{
            if(licenseId!=null){
                for(Sales_License__c licRecord:[Select Id,Sales_License_Product__c,Sales_Parent_License__c,Sales_License_Order_Product__c
                                                from Sales_License__c where Sales_Parent_License__c =:licenseId 
                                               ]){
                                                   optionProductsToRemove.add(licRecord.Sales_License_Product__c);
                                               }
                for(SBQQ__ProductOption__c prodOption : productOptionList){
                    if(!optionProductsToRemove.contains(prodOption.SBQQ__OptionalSKU__c)){
                        productOptionReturnList.add(prodOption);
                    }
                }
                licenseWrapperClass licWrapper = new licenseWrapperClass();
                licWrapper.productOptionReturnList = productOptionReturnList;
                if(productOptionList.size()==0){
                    licWrapper.optionNotAvailable = true;
                }
                return licWrapper;
            }
            else{
                licenseWrapperClass licWrapper = new licenseWrapperClass();
                licWrapper.productOptionReturnList = productOptionList;
                if(productOptionList.size()==0){
                    licWrapper.optionNotAvailable = true;
                }
                return licWrapper;
            }
        }
    }
    @AuraEnabled
    public static void createOptionLicense(String licenseId,List<Id> optionProductIdList,String renewalLicId){
        Sales_License__c parentLicense = [Select id,Sales_License_Expiration_Date_Dt__c,Sales_License_Quantity__c,Sales_License_Avbl_Qty_Nbr__c,Sales_License_SAPLine_Nbr__c,Sales_License_Comments_Txt__c,Sales_License_Internal_Comments_Txt__c,Sales_License_Avbl_Rehost_Nbr__c,Sales_License_Web_Display_Flag__c,Sales_License_Lic_User_Contact_ID__c,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Status__c,Sales_License_Primary_Admin_Contact__c,Sales_License_Contract__c,Sales_License_Activation_Code__c,Sales_License_Order_Product__c,Sales_License_Host_Node_Id__c,Sales_License_Start_Date_Dt__c,Sales_License_Account__c from Sales_License__c where Id=:licenseId];
        Id orderItemId = parentLicense?.Sales_License_Order_Product__c;
        List<OrderItem> orderProductList = [Select Id,Product2Id,Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c,OrderId,Quantity from OrderItem where Id=:orderItemId];
        orderProductList[0].Quantity=parentLicense.Sales_License_Quantity__c;
        Set<Id> productIdSet = new Set<Id>(optionProductIdList);
        Map<Id,Order> ordMap = new Map<Id,Order>([Select id,Type,Sales_Req_Ship_Date_Dt__c,SBQQ__Quote__r.SBQQ__EndDate__c,Sales_End_Customer_Account__c,Sales_Order_Reason__c,
                                                  SBQQ__Quote__r.SBQQ__StartDate__c,AccountId,Sales_Sold_To_Account__c,Sales_Order_Sub_Type__c,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__Type__c,
                                                  SBQQ__Quote__r.SBQQ__Opportunity2__c, SBQQ__Quote__r.SBQQ__MasterContract__c,SBQQ__Quote__r.Sales_Renewed_from_Contract_Id__c from Order where Id=:orderProductList[0].OrderId]);
        Sales_OrderProductTriggerUtility.createSalesLicense(orderProductList, ordMap, productIdSet,false,true,parentLicense,renewalLicId);
    }
    public static void updateProcessedStatus(List<Sales_License__c> oldLicList){
        List<Sales_License__c> updateLicenseList=new List<Sales_License__c>();
        for(Sales_License__c licRecord : oldLicList){
            licRecord.Sales_Processed__c=true;
            updateLicenseList.add(licRecord);
        }
        if(updateLicenseList.size()>0){
            update updateLicenseList;
        }
    }
    @AuraEnabled
    public static void processDistributionAction(Integer distyQty,Id orderItemId, List<Sales_License__c> oldLicList, Id renewalLicId){
        if(oldLicList.size()>0){
            updateProcessedStatus(oldLicList);
        }
        Sales_License__c renewalLic= [Select Id,Sales_License_Avbl_Qty_Nbr__c,Sales_Distributed_Quantity__c,Sales_License_Quantity__c  from Sales_License__c where Id = :renewalLicId];
        distyQty = distyQty!=null?distyQty:0;
        Map<OrderItem,List<Sales_License__c>> renOrItemOldLicMap=new Map<OrderItem,List<Sales_License__c>>();
        Map<Id,Map<OrderItem, List<Sales_License__c>>> mapOfOrdProdLicListLinkMap= new  Map<Id,Map<OrderItem, List<Sales_License__c>>>();
        OrderItem orderItemRecord = [Select Id,Quantity from OrderItem where Id=:orderItemId LIMIT 1];
        List<Sales_License__c> updatedOldLicList = new List<Sales_License__c>();
        if(renewalLic.Sales_License_Avbl_Qty_Nbr__c<0){
            for(Sales_License__c licRecord : oldLicList){
                licRecord.Sales_License_Avbl_Qty_Nbr__c = licRecord.Sales_License_Avbl_Qty_Nbr__c*-1;
                updatedOldLicList.add(licRecord);
            }
            oldLicList.clear();
            oldLicList.addAll(updatedOldLicList);
        }
        renOrItemOldLicMap.put(orderItemRecord,oldLicList);
        mapOfOrdProdLicListLinkMap.put(renewalLicId,renOrItemOldLicMap);
        Sales_OrderProductTriggerUtility.createLicenseOrderProducts(mapOfOrdProdLicListLinkMap,null,mapOfOrdProdLicListLinkMap.keyset());
        List<Sales_License__c> updateRenewalLicList=new List<Sales_License__c>();
        Integer renewalDistiQuantity = renewalLic.Sales_Distributed_Quantity__c!=null?(Integer)renewalLic.Sales_Distributed_Quantity__c:0;
        if(renewalLic.Sales_License_Avbl_Qty_Nbr__c<0){
            renewalLic.Sales_License_Avbl_Qty_Nbr__c=Integer.valueOf(renewalLic.Sales_License_Avbl_Qty_Nbr__c+distyQty);
            renewalLic.Sales_Distributed_Quantity__c=renewalDistiQuantity-distyQty;
        }
        else{
            renewalLic.Sales_License_Avbl_Qty_Nbr__c=Integer.valueOf(renewalLic.Sales_License_Avbl_Qty_Nbr__c-distyQty);
            renewalLic.Sales_Distributed_Quantity__c=renewalDistiQuantity+distyQty;
        }
        updateRenewalLicList.add(renewalLic);
        update updateRenewalLicList;
    }
    @AuraEnabled
    public static void createLicensedForRenewalFixed(Integer distyQty,Id orderItemId, List<Sales_License__c> oldLicList, Id renewalLicId, Integer quantityRollup){
        Sales_License__c renewalLic= [Select Id,Sales_License_Avbl_Qty_Nbr__c,Sales_Distributed_Quantity__c from Sales_License__c where Id = :renewalLicId];
        distyQty = distyQty!=null?distyQty:0;
        quantityRollup = quantityRollup!=null?quantityRollup:0;
        Map<OrderItem,List<Sales_License__c>> renOrItemOldLicMap=new Map<OrderItem,List<Sales_License__c>>();
        Set<Id> productIdSet = new Set<Id>();
        OrderItem orderItem = [Select Id,Product2Id,Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c,OrderId,Quantity from OrderItem where Id=:orderItemId];
        renOrItemOldLicMap.put(orderItem,oldLicList);
        orderItem.Quantity= distyQty-quantityRollup;
        Id orderId = orderItem.OrderId;
        productIdSet.add(orderItem.Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c);
        List<OrderItem> orderProductList=new List<OrderItem>();
        orderProductList.add(orderItem);
        Map<Id,Order> ordMap = new Map<Id,Order>([Select id,Type,Sales_Req_Ship_Date_Dt__c,SBQQ__Quote__r.SBQQ__EndDate__c,SBQQ__Quote__r.SBQQ__StartDate__c,Sales_Order_Reason__c,AccountId,Sales_End_Customer_Account__c,Sales_Sold_To_Account__c,Sales_Order_Sub_Type__c,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__Type__c,SBQQ__Quote__r.SBQQ__Opportunity2__c from Order where Id=:orderId]);
        Map<Id,Map<OrderItem, List<Sales_License__c>>> mapOfOrdProdLicListLinkMap= new  Map<Id,Map<OrderItem, List<Sales_License__c>>>();
        Sales_OrderProductTriggerUtility.createSalesLicense(orderProductList, ordMap, productIdSet,true,false,null,renewalLicId);
        mapOfOrdProdLicListLinkMap.put(renewalLicId,renOrItemOldLicMap);
        Sales_OrderProductTriggerUtility.createLicenseOrderProducts(mapOfOrdProdLicListLinkMap,null,mapOfOrdProdLicListLinkMap.keyset());
        List<Sales_License__c> updateRenewalLicList=new List<Sales_License__c>();
        renewalLic.Sales_License_Avbl_Qty_Nbr__c=Integer.valueOf(renewalLic.Sales_License_Avbl_Qty_Nbr__c-distyQty);
        Integer renewalDistiQuantity = renewalLic.Sales_Distributed_Quantity__c!=null?(Integer)renewalLic.Sales_Distributed_Quantity__c:0;
        renewalLic.Sales_Distributed_Quantity__c=renewalDistiQuantity+distyQty;
        updateRenewalLicList.add(renewalLic);
        update updateRenewalLicList;   
    }
    private static List<Id> getProcessedLicenseList(Set<Id> orderItemIdSet,List<Sales_License__c> licReturnList){
        Set<String> existingLicOISet = new Set<String>();
        List<Id> processedLicIdList=new List<Id>();
        for(Sales_License_Order_Product__c licenseOrderProduct : [Select id,Sales_License__c,Sales_Order_Product__c 
                                                                  FROM Sales_License_Order_Product__c where Sales_Order_Product__c IN :orderItemIdSet]){
                                                                      existingLicOISet.add(licenseOrderProduct.Sales_Order_Product__c+'-'+licenseOrderProduct.Sales_License__c);
                                                                  }
        for(Sales_License__c licenseRecord:licReturnList){
            if(existingLicOISet.contains((new list<Id>(orderItemIdSet))[0]+'-'+licenseRecord.Id)){
                processedLicIdList.add(licenseRecord.Id);
            }
        }
        return processedLicIdList;
    }
    public class licenseWrapperClass{
        @AuraEnabled public List<Sales_License__c> licenseList;
        @AuraEnabled public List<Id> processedLicIdList;
        @AuraEnabled public Map<String,List<Sales_License__c>> productWithCorporateLicense;
        @AuraEnabled public Map<Id,Boolean> isCorporateMap;
        @AuraEnabled public List<licenseDataTableRecordWrapper> licenseJunctionWrapperList;
        @AuraEnabled public List<String> nonCorporateWithOriginalLicenseList;
        @AuraEnabled public Map<Id,Boolean> isNonCorporateMap;
        @AuraEnabled public Map<Id,List<Id>> productToFoundProdFinalMap;
        @AuraEnabled public Boolean addSeatOrder;
        @AuraEnabled public Map<String,Boolean> expiredLicenseMap;
        @AuraEnabled public List<Id> parentLicenseIds;
        @AuraEnabled public List<SBQQ__ProductOption__c> productOptionReturnList;
        @AuraEnabled public Boolean optionNotAvailable=false;
    }
    public class licenseDataTableRecordWrapper{
        @AuraEnabled public String licenseId;
        @AuraEnabled public Id orderItemRecordId;
        @AuraEnabled public String orderNumber;
        @AuraEnabled public Id productId;
        @AuraEnabled public String productOPN;
        @AuraEnabled public String productName;
        @AuraEnabled public Date maintenanaceExpiration;
        @AuraEnabled public Date salesExpirationDate;
        @AuraEnabled public Id primaryContactId;
        @AuraEnabled public String primaryContactName;
        @AuraEnabled public String licenseUserId;
        @AuraEnabled public String licenseUserName;
        @AuraEnabled public String licenseActivationCode;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Decimal availableQuanity;
        @AuraEnabled public String licenseType;
        @AuraEnabled public String toolLicenseType;
        @AuraEnabled public String licenseStatus;
        @AuraEnabled public String licenseName;
        @AuraEnabled public Id productFromOrderProduct;
        @AuraEnabled public Id parentLicense;
        @AuraEnabled public Id contactFromOrderProduct;
        @AuraEnabled public String toolProdLicType;
        @AuraEnabled public Boolean webDisplayFlag;
        @AuraEnabled public Boolean isProductOptionAvailable =false;
        @AuraEnabled public Boolean showCreateOptionLicenseAction=false;
        @AuraEnabled public Id primaryComputerId;
        @AuraEnabled public String primaryComputerName;			   
    }
}