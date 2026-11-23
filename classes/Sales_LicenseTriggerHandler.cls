/*********************************************************************************************************************
Class Name    : Sales_LicenseTriggerHandler
Version       : 1.0
Created Date  : Mar 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Saba Husain           9-Mar-2021              License Trigger Handler 
* *********************************************************************************************************************/
@isTest
public without sharing class Sales_LicenseTriggerHandler {
    /*extends TriggerHandler {
    private static final String TOOL_LICENSE_TYPE_OPTIONAL = 'Optional';
    private static final String LICENSE_OBJECT_NAME ='Sales_License__c';
    public static Boolean byPassForBulkLicCreation = false;
    public override void afterInsert() {
        if(isActive('PSG_License_After_Insert_Trigger')) {             
            Set<Id> licUpdateSetId=new Set<Id>();
            List<Sales_License__c> licUpdateList=new List<Sales_License__c>();
            for(Sales_License__c lic: (List<Sales_License__c>) Trigger.new){
                licUpdateSetId.add(lic.Id);
            }
            for(Sales_License__c lic:[Select Id,Sales_License_Type__c,Sales_License_SAPLine_Nbr__c,Sales_License_Order_Product__c,Sales_License_Account__c,Sales_License_Account__r.Name,Sales_License_Order_Product__r.OrderItemNumber,Sales_License_Order__r.OrderNumber,Sales_License_Order__c,Sales_License_Product__c,Sales_License_Lic_User_Contact_ID__c,Sales_License_Product__r.Name,Sales_License_Lic_User_Contact_ID__r.Name,Sales_License_Host_Node_Id__c,Sales_License_Contract__c,Sales_License_Host_Node_Id__r.Name,Sales_License_Contract__r.ContractNumber,Sales_Parent_License__r.Name,Sales_Parent_License__c,Sales_License_SubscriptionId__c,Sales_License_SubscriptionId__r.Name,Sales_License_Primary_Admin_Contact__r.Name,Sales_License_Primary_Admin_Contact__c,Sales_License_Primary_Admin_Contact__r.Email,Sales_License_Primary_Admin_Contact__r.Account.IsPartner,Sales_License_Web_Display_Flag__c, Sales_License_Lic_User_Contact_ID__r.Email,Sales_License_Lic_User_Contact_ID__r.Account.IsPartner from Sales_License__c where Id IN:licUpdateSetId])
            {
                licUpdateList.add(lic);
            }
            Sales_LicenseTriggerUtility.updatefieldForListViewFilter(licUpdateList); 
            List<Sales_License__c> recordsRequiringSharingUpdate = new List<Sales_License__c>();
            for(Sales_License__c licRec : licUpdateList ){
                if( (licRec.Sales_License_Lic_User_Contact_ID__c != null || licRec.Sales_License_Primary_Admin_Contact__c != null)&& licRec.Sales_License_Web_Display_Flag__c==true){
                    recordsRequiringSharingUpdate.add(licRec);
                }
            }
            if(!recordsRequiringSharingUpdate.isEmpty()){
                Sales_LicenseTriggerUtility.shareLicenseRecordsWithDelegates(recordsRequiringSharingUpdate, null);
            }           
        }
    }
    public override void beforeInsert() {
        byPassForBulkLicCreation  = true;
        if(isActive('Sales_License_Before_Insert_Trigger')) {
            Sales_SequenceGenerator.sequenceGenerator((List<Sales_License__c>)Trigger.new ,LICENSE_OBJECT_NAME);
            List<Id> ordItmIds = new List<Id>();
            Set<Id> prodIdsSet = new Set<Id>();
            for(Sales_License__c lic: (List<Sales_License__c>) Trigger.new){
                if(lic.Sales_License_Type__c!=TOOL_LICENSE_TYPE_OPTIONAL && lic.Sales_License_Activation_Code__c==null){       
                    lic.Sales_License_Activation_Code__c=Sales_LicenseTriggerUtility.mdFiveHashAsLicenseActivationCode();
                }
                if(lic.Sales_License_Start_Date_Dt__c != null){
                    ordItmIds.add(lic.Sales_License_Order_Product__c);      
                }
                prodIdsSet.add(lic.Sales_License_Product__c);
                /*if(Sales_AddNewLicenseAdminController.isCommunity() == false){
                    lic.OwnerId=system.label.Sales_systemUser;
                }*/            
            /*}  
            Map<Id, Product2> prodMap = new Map<Id, Product2>([Select id, Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c,SBQQ__SubscriptionTerm__c from Product2 where ID IN:prodIdsSet]);
            Map<Id, OrderItem> ordItmMap = new Map<Id, OrderItem>([Select Id,SBQQ__Contract__c, Product2.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c,
                                                                   Order.SBQQ__Quote__r.SBQQ__StartDate__c, Order.SBQQ__Quote__r.SBQQ__SubscriptionTerm__c, 
                                                                   Order.SBQQ__Quote__r.SBQQ__EndDate__c,Order.Status, 
                                                                   Order.Sales_Order_Sub_Type__c, Order.SBQQ__Quote__r.SBQQ__Type__c, Order.Type  from OrderItem where Id IN: ordItmIds and (Order.SBQQ__Quote__c = null or Order.SBQQ__Quote__r.SBQQ__MasterContract__c = null)]);
            if(!ordItmIds.IsEmpty()){ 
                Sales_LicenseTriggerUtility.updateExpiryDatesonLicense((List<Sales_License__c>)Trigger.new, ordItmMap, prodMap);
            }
            if(isActive('Sales_Primary_DelegateNames')){
                List<Sales_License__c> recordsRequiringFieldUpdate = new List<Sales_License__c>();
                for(Sales_License__c licRec : (List<Sales_License__c>)Trigger.new ){
                    if(licRec.Sales_License_Primary_Admin_Contact__c!=null){
                        recordsRequiringFieldUpdate.add(licRec);
                    }
                }
                if(!recordsRequiringFieldUpdate.isEmpty()){
                    Sales_Primary_DelegateNames_Utility.OnLicenseInsertUpdate((Map<Id, Sales_License__c>)Trigger.newMap, null);
                }       
            }
        }
    }
    public override void beforeUpdate() {
        if(isActive('Sales_License_Before_Update_Trigger')) {   
            Map<Id, Sales_License__c> oldLicMap = (Map<Id, Sales_License__c>)Trigger.oldMap;
            List<Id> ordItmIds = new List<Id>();
            Set<Id> prodIdsSet = new Set<Id>();
            Set<Id> orderSet = new Set<Id>();  
            Map<Id,Id> licenseMap=new Map<Id,Id>();
            List<Sales_License__c> licRenStatusUpd =new List<Sales_License__c>();
            List<Sales_License__c> licUpdateList = new List<Sales_License__c>();
            for(Sales_License__c lic: (List<Sales_License__c>) Trigger.new){
                if(lic.Sales_License_Start_Date_Dt__c != null & oldLicMap.get(lic.Id).Sales_License_Start_Date_Dt__c != lic.Sales_License_Start_Date_Dt__c && lic.Sales_License_Status__c != 'Cancelled'){
                    ordItmIds.add(lic.Sales_License_Order_Product__c);      
                }
                prodIdsSet.add(lic.Sales_License_Product__c);
                if((lic.Sales_License_Order__r.Sales_status__c=='SAP Order Shipped' && lic.Sales_License_Order__r.Type!='Non Commercial Order')||(lic.Sales_License_Order__r.Sales_status__c=='Order created successfully' && lic.Sales_License_Order__r.Type=='Non Commercial Order')){
                    orderSet.add(lic.Sales_License_Order__c);
                }             
                if((oldLicMap.get(lic.Id).Sales_License_Renewal_Status__c == 'License Expired' && oldLicMap.get(lic.Id).Sales_License_Maintenance_Exp_Dt__c != null && lic.Sales_License_Maintenance_Exp_Dt__c != null) &&
                   (lic.Sales_License_Maintenance_Exp_Dt__c > oldLicMap.get(lic.Id).Sales_License_Maintenance_Exp_Dt__c ) &&
                   (lic.Sales_License_Maintenance_Exp_Dt__c >= System.Today())){
                       licRenStatusUpd.add(lic);                    
                   }
                if(oldLicMap!= null &&(
                    ((oldLicMap.get(lic.Id).Sales_License_Maintenance_Exp_Dt__c != lic.Sales_License_Maintenance_Exp_Dt__c) && (lic.Sales_License_Maintenance_Exp_Dt__c == null)) ||
                    ((oldLicMap.get(lic.Id).Sales_License_Status__c != lic.Sales_License_Status__c) && (lic.Sales_License_Status__c == 'Cancelled')))){
                        licUpdateList.add(lic);
                    }
            }            
            Map<Id, Product2> prodMap = new Map<Id, Product2>([Select id,Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c, SBQQ__SubscriptionTerm__c from Product2 where ID IN:prodIdsSet]);
            Map<Id, OrderItem> ordItmMap = new Map<Id, OrderItem>([Select Id,Order.Type, Product2.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c,
                                                                   Order.SBQQ__Quote__r.SBQQ__SubscriptionTerm__c, Order.SBQQ__Quote__r.SBQQ__EndDate__c,Product2.SBQQ__SubscriptionTerm__c,SBQQ__SubscriptionTerm__c,
                                                                   Order.SBQQ__Quote__r.SBQQ__StartDate__c, Order.Status,
                                                                   Order.Sales_Order_Sub_Type__c, Order.SBQQ__Quote__r.SBQQ__Type__c, SBQQ__Contract__c from OrderItem where Id IN: ordItmIds and (Order.SBQQ__Quote__c = null or Order.SBQQ__Quote__r.SBQQ__MasterContract__c = null)]);
            if(!ordItmIds.IsEmpty() ){            
                Sales_LicenseTriggerUtility.updateExpiryDatesonLicense((List<Sales_License__c>)Trigger.new, ordItmMap, prodMap);
            }
            if(!licUpdateList.IsEmpty()){
                Sales_LicenseTriggerUtility.updateLicenseRenewalStatus(licUpdateList , 'NotApplicable');
            }           
            if(isActive('Sales_Primary_DelegateNames')){
                List<Sales_License__c> recordsRequiringFieldUpdate = new List<Sales_License__c>();
                for(Sales_License__c licRec : (List<Sales_License__c>)Trigger.new ){
                    if(oldLicMap.get(licRec.Id)?.Sales_License_Primary_Admin_Contact__c != licRec.Sales_License_Primary_Admin_Contact__c){
                        recordsRequiringFieldUpdate.add(licRec);
                    }
                }
                if(!recordsRequiringFieldUpdate.isEmpty()){
                    Sales_Primary_DelegateNames_Utility.OnLicenseInsertUpdate((Map<Id, Sales_License__c>)Trigger.newMap, (Map<Id, Sales_License__c>)Trigger.oldMap);
                }                       
            }
            Sales_LicenseTriggerUtility.validateHostonLicense((List<Sales_License__c>)Trigger.new, (Map<Id, Sales_License__c>)Trigger.oldMap);
            /*if(Sales_LicenseRecordPageComponentsUtility.BypassTriggerReassignmentLogic==false && byPassForBulkLicCreation  == false){
                Sales_ValidateUpdateOnHost.hostReassigment((List<Sales_License__c>)Trigger.new,(Map<Id, Sales_License__c>)Trigger.oldMap,(Map<Id, Sales_License__c>)Trigger.newMap);
            }*/
        /*}
    }  
    public override void afterUpdate() {
        if(isActive('PSG_License_After_Insert_Trigger')) {  
            Set<Id> licUpdateSetId=new Set<Id>();
            Set<Id> hostUpdateOnLicense=new Set<Id>();
            Map<Id, Sales_License__c> oldLicMap = (Map<Id, Sales_License__c>)Trigger.oldMap;
            List<Sales_License__c> licUpdateList=new List<Sales_License__c>();
            List<Sales_License__c> hostUpdateOnLicenseList=new List<Sales_License__c>();
            for(Sales_License__c lic: (List<Sales_License__c>) Trigger.new){
                if(lic.Sales_License_Account__c!=oldLicMap.get(lic.Id).Sales_License_Account__c
                   || lic.Sales_License_Order_Product__c!=oldLicMap.get(lic.Id).Sales_License_Order_Product__c
                   || lic.Sales_License_Order__c!=oldLicMap.get(lic.Id).Sales_License_Order__c
                   || lic.Sales_License_Product__c!=oldLicMap.get(lic.Id).Sales_License_Product__c
                   || lic.Sales_License_Lic_User_Contact_ID__c!=oldLicMap.get(lic.Id).Sales_License_Lic_User_Contact_ID__c
                   || lic.Sales_License_Host_Node_Id__c!=oldLicMap.get(lic.Id).Sales_License_Host_Node_Id__c
                   || lic.Sales_License_Contract__c!=oldLicMap.get(lic.Id).Sales_License_Contract__c
                   || lic.Sales_Parent_License__c!=oldLicMap.get(lic.Id).Sales_Parent_License__c
                   || lic.Sales_License_SubscriptionId__c!=oldLicMap.get(lic.Id).Sales_License_SubscriptionId__c
                   || lic.Sales_License_Primary_Admin_Contact__c!=oldLicMap.get(lic.Id).Sales_License_Primary_Admin_Contact__c
                   || lic.Sales_License_Lic_User_Contact_ID__r.Email!=oldLicMap.get(lic.Id).Sales_License_Lic_User_Contact_ID__r.Email
                   ||lic.Sales_License_Web_Display_Flag__c!=oldLicMap.get(lic.Id).Sales_License_Web_Display_Flag__c
                   || lic.OwnerId!=oldLicMap.get(lic.Id).OwnerId
                  )
                {
                    licUpdateSetId.add(lic.Id);
                }
                if((lic.Sales_License_Host_Node_Id__c!=oldLicMap.get(lic.Id).Sales_License_Host_Node_Id__c) ||(lic.Sales_License_Primary_Admin_Contact__c!=oldLicMap.get(lic.Id).Sales_License_Primary_Admin_Contact__c)){
                    hostUpdateOnLicense.add(lic.Id);
                }                
            }
            for(Sales_License__c lic:[Select Id,Sales_License_Type__c,OwnerId,Sales_License_SAPLine_Nbr__c,Sales_License_Order_Product__c,Sales_License_Account__c,Sales_License_Account__r.Name,Sales_License_Order_Product__r.OrderItemNumber,Sales_License_Order__r.OrderNumber,Sales_License_Order__c,Sales_License_Product__c,Sales_License_Lic_User_Contact_ID__c,Sales_License_Product__r.Name,Sales_License_Lic_User_Contact_ID__r.Name,Sales_License_Host_Node_Id__c,Sales_License_Contract__c,Sales_License_Host_Node_Id__r.Name,Sales_License_Contract__r.ContractNumber,Sales_Parent_License__r.Name,Sales_Parent_License__c,Sales_License_SubscriptionId__c,Sales_License_SubscriptionId__r.Name,Sales_License_Primary_Admin_Contact__r.Name,Sales_License_Primary_Admin_Contact__r.Email,Sales_License_Primary_Admin_Contact__r.Account.IsPartner,Sales_License_Web_Display_Flag__c,Sales_License_Lic_User_Contact_ID__r.Email from Sales_License__c where Id IN:licUpdateSetId])
            {
                licUpdateList.add(lic);
            }
            Sales_LicenseTriggerUtility.updatefieldForListViewFilter(licUpdateList); 
            for(Sales_License__c lic:[Select id,Sales_License_Type__c,Sales_License_Host_Node_Id__c,Sales_Parent_License__c from Sales_License__c where Id In:hostUpdateOnLicense and Sales_License_Type__c!='Optional']){
                hostUpdateOnLicenseList.add(lic);
            }
            if(!hostUpdateOnLicenseList.isEmpty()){
                Sales_LicenseTriggerUtility.updateHostOnOptionLicense(hostUpdateOnLicenseList);
            }
            List<Sales_License__c> recordsRequiringSharingUpdate = new List<Sales_License__c>();
            for(Sales_License__c licRec : licUpdateList ){
                if((oldLicMap.get(licRec.Id)?.Sales_License_Web_Display_Flag__c!= licRec.Sales_License_Web_Display_Flag__c && ( licRec.Sales_License_Lic_User_Contact_ID__c!=null || 
                                                                                                                               licRec.Sales_License_Primary_Admin_Contact__c!=null)) || (licRec.Sales_License_Web_Display_Flag__c==true && (oldLicMap.get(licRec.Id)?.Sales_License_Lic_User_Contact_ID__c != licRec.Sales_License_Lic_User_Contact_ID__c 
                                                                                                                                                                                                                                            || oldLicMap.get(licRec.Id)?.Sales_License_Primary_Admin_Contact__c != licRec.Sales_License_Primary_Admin_Contact__c))|| (licRec.OwnerId!=oldLicMap.get(licRec.Id).OwnerId)){
                                                                                                                                                                                                                                                recordsRequiringSharingUpdate.add(licRec);
                                                                                                                                                                                                                                            }
            }
            if(!recordsRequiringSharingUpdate.isEmpty()){
                Sales_LicenseTriggerUtility.shareLicenseRecordsWithDelegates(recordsRequiringSharingUpdate, oldLicMap);
            } 
        }
    }
    public override void beforeDelete() {
        if(isActive('Sales_License_Before_Delete_Trigger')){
            Sales_SequenceGenerator.licSeqGenerationForDelete((List<Sales_License__c>)Trigger.old );
        }
    }*/
}