global class Core_Batch_PlatformEventBus_PurgeRecords implements  Database.Batchable<sObject>, Database.Stateful {
    
    @InvocableMethod(label='Execute Platform Event Bus Purge Batch' description='This method will be execute Core_Batch_PlatformEventBus_PurgeRecords')
    public static void executePlatformEventBusPurgeBatch() {
        Integer batchSize=1;
        //Query Custom Setting for Batch Size
        List<Core_Platform_Event_Attempts__c> platFormEventAttempList = [SELECT Id, Core_Batch_Size__c FROM Core_Platform_Event_Attempts__c WITH SECURITY_ENFORCED limit 1];
        if(platFormEventAttempList!=null && platFormEventAttempList.size()>0 && platFormEventAttempList[0]!=null && platFormEventAttempList[0].Core_Batch_Size__c!=null){
            batchSize = Integer.valueOf(platFormEventAttempList[0].Core_Batch_Size__c);
        }
        
        Core_Batch_PlatformEventBus_PurgeRecords pEBBatch = new Core_Batch_PlatformEventBus_PurgeRecords();
        if(!Test.isRunningTest()){
            database.executebatch(pEBBatch,batchSize);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        Integer numberOfDaysUntil;
        Date numberOfDays;
        //Query Custom Setting for Core_Days_To_Purge_Until__c
        List<Core_Platform_Event_Attempts__c> platFormEventAttempList = [SELECT Id, Core_Days_To_Purge_Until__c FROM Core_Platform_Event_Attempts__c WITH SECURITY_ENFORCED limit 1];
        if(platFormEventAttempList!=null && platFormEventAttempList.size()>0 && platFormEventAttempList[0]!=null && platFormEventAttempList[0].Core_Days_To_Purge_Until__c!=null){
            numberOfDaysUntil = Integer.valueOf(platFormEventAttempList[0].Core_Days_To_Purge_Until__c);
            numberOfDaysUntil = numberOfDaysUntil;
            numberOfDays = Date.today().addDays(-numberOfDaysUntil);
        }
        query='SELECT Id, Name, CreatedDate FROM Core_Platform_Event_Log__c where CreatedDate <:numberOfDays';
        
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Core_Platform_Event_Log__c> scope){
        try{
            delete scope;
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