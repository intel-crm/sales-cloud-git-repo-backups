global class Core_PartnerLead_IndividualEmail_Batch implements Database.Batchable<sObject>, Database.Stateful{
    
    Set<Id> allLeadIds = new Set<Id>();
    Map<Id,Lead> leadMap;
    EmailTemplate EmailTemp;
    List<Lead> updateLead;
    global Core_PartnerLead_IndividualEmail_Batch(List<Lead> leads){
        leadMap = new Map<Id,Lead>(leads);
        updateLead = new List<Lead>(leads);
        allLeadIds = leadMap.keySet();
        
        EmailTemp = [Select Id, Name From EmailTemplate Where Name ='New Lead Partner' limit 1];
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String partnerRecType = System.Label.Core_Partner_Lead_Record_Id;
        
        String query = 'Select id, Core_Lead_Name__c, Core_Public_Group_Ids__c, Core_OPID_Name__c from Core_OPID_Lead_Relationship__c Where Core_Lead_Name__c IN: allLeadIds';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Core_OPID_Lead_Relationship__c> LeadOPIDSlst){
        try{
            Boolean allOrNone = false;
            //List<Lead> updatedLead = new List<Lead>();
           Core_PartnerLeadHandler.sendEmailNotification(LeadOPIDSlst, leadMap, EmailTemp);
            
            for(lead newlead : updateLead){
                newLead.Core_Individual_Send_Email__c=true;
                //updatedLead.add(newLead);
            }
            database.update(updateLead,allOrNone );
            if(Test.isRunningTest()){
                allOrNone =null;
                database.update(updateLead,allOrNone );
            }
            
        }
        Catch(Exception e){
            Core_Exceptions__c ExcepLog = new Core_Exceptions__c( Core_Class_Name__c = 'Core_PartnerLead_IndividualEmail_Batch', Core_Exception__c  = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString(), Core_Login_User_Id__c= userInfo.getUserId());
            insert ExcepLog;
        }
        
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}