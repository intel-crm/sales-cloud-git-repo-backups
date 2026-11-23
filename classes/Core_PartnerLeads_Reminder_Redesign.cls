global class Core_PartnerLeads_Reminder_Redesign implements Database.Batchable<sObject>, Database.Stateful{
    
    List<String> partnerSegmentList = new List<String>();
    public Integer currentYear = date.today().year();
    
    //Public group name suffix
    public static String adminPublicGroupNameSuffix = 'Leads';
    
    global Core_PartnerLeads_Reminder_Redesign(){
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
        String testPAGid='0013b00001phGiUAAU';
        String query = 'select id, Name from Account where recordtypeId =: partnerRecTypeId AND id =: testPAGid';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> opidList){
		Core_PartnerLeadHandler.sendLeadEmailNotifications(opidList,true,partnerSegmentList);	

    }
    
      
    
    global void finish(Database.BatchableContext BC){
        
    }
}