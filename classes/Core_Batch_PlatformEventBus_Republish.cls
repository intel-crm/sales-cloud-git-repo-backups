global class Core_Batch_PlatformEventBus_Republish implements  Database.Batchable<sObject>, Database.Stateful {
    
    
   @InvocableMethod(label='Execute Platform Event Bus Republish Batch' description='This method will be execute Core_Batch_PlatformEventBus_Republish')
    public static void executePlatformEventBusRepublishBatch() {
        Integer batchSize=1;
        //Query Custom Setting for Batch Size
        List<Core_Platform_Event_Attempts__c> platFormEventAttempList = [SELECT Id, Core_Batch_Size__c FROM Core_Platform_Event_Attempts__c WITH SECURITY_ENFORCED limit 1];
        if(platFormEventAttempList!=null && platFormEventAttempList.size()>0 && platFormEventAttempList[0]!=null && platFormEventAttempList[0].Core_Batch_Size__c!=null){
            batchSize = Integer.valueOf(platFormEventAttempList[0].Core_Batch_Size__c);
        }
        
        Core_Batch_PlatformEventBus_Republish pEBBatch = new Core_Batch_PlatformEventBus_Republish();
        if(!Test.isRunningTest()){
            database.executebatch(pEBBatch,batchSize);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        Integer maxAttempts=2;
        //Query Custom Setting for max number of attempts
        List<Core_Platform_Event_Attempts__c> platFormEventAttempList = [SELECT Id, Core_Number_Of_Attempts__c FROM Core_Platform_Event_Attempts__c WITH SECURITY_ENFORCED limit 1];
        if(platFormEventAttempList!=null && platFormEventAttempList.size()>0 && platFormEventAttempList[0]!=null && platFormEventAttempList[0].Core_Number_Of_Attempts__c!=null){
            maxAttempts = Integer.valueOf(platFormEventAttempList[0].Core_Number_Of_Attempts__c);
        }
        query='SELECT Id, Name, Account__c, Core_Message__c, Core_Status__c, Core_Object_API_Name__c, Core_Number_Of_Attempts__c FROM Core_Platform_Event_Log__c where Core_IsActive__c=True and Core_Status__c=\'failed\' and Core_Number_Of_Attempts__c<:maxAttempts';
        
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Core_Platform_Event_Log__c> scope){
        try{
            List<String> xmlMessageList = new List<String>();
            Boolean rePublish = True;
            List<Id> platFormEventLogidList = new List<Id>();
            List<Id> accountSalesforceIdList = new List<Id>();
            List<Integer> attemptList = new List<Integer>();
            for(Core_Platform_Event_Log__c eventLog: scope){
                eventLog.Core_Status__c='republish';
                xmlMessageList.add(eventLog.Core_Message__c);
                platFormEventLogidList.add(eventLog.Id);
                accountSalesforceIdList.add(eventLog.Account__c);
                attemptList.add(Integer.valueOf(eventLog.Core_Number_Of_Attempts__c));
            }
            update scope;
            Core_Platform_Event_Producer.publish_Platform_Event('Account', xmlMessageList, accountSalesforceIdList, rePublish, platFormEventLogidList, attemptList);
            
        }        
        catch(Exception e)
        {            
            system.debug('#ex:Message:'+e.getMessage());
            system.debug('#ex:LineNumber:'+e.getLineNumber());
        }
        
    }    
    global void finish(Database.BatchableContext bc){
        
    }    
}