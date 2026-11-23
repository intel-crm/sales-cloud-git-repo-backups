/**************************************************************************************
Apex Class Name:  Core_PartnerLead_ReminderEmail
Version     : 1.0 
Created Date: 28 August 2019
Function    : This class is used for partner lead reminder email
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar             28/08/2019              Original Version
*************************************************************************************/
global class Core_PartnerLead_ReminderEmail implements Database.Batchable<sObject>{

  List<String> partnerSegmentList = new List<String>();
    public Integer currentYear = date.today().year();
    
    //Public group name suffix
    public static String adminPublicGroupNameSuffix = 'Leads';
    
    global Core_PartnerLead_ReminderEmail(){
        Schema.sObjectType objType = Schema.getGlobalDescribe().get('Account');
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        list<Schema.PicklistEntry> values = fieldMap.get('Core_IPA_Partner_Segment__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : values){
            partnerSegmentList.add(a.getValue());
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String partnerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        String query = 'select id, Name from Account where recordtypeId =: partnerRecTypeId';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> opidList){
		Core_PartnerLeadHandler.sendLeadEmailNotifications(opidList,true,partnerSegmentList);	

    }
    
      
    
    global void finish(Database.BatchableContext BC){
        
    }
}