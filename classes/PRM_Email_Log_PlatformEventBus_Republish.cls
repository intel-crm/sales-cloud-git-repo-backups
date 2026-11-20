/******************************************************************************************************************************
Apex Class Name:  PRM_Email_Log_PlatformEventBus_Republish
Version     : 1.0 
Created Date: 01 JUN 2021
Function    : Batch Class for Republishing failed PlatformEvents

Modification Log :
* Developer                     Date                Description
* ----------------------------------------------------------------------------------------------------------------------------------
* GopiKrishna Vankadari       01/06/2021           Batch Class invoked from ProcessBuilder for Republishing failed PlatformEvent Records

****************************************************************************************************************************************/
global class PRM_Email_Log_PlatformEventBus_Republish implements  Database.Batchable<sObject>, Database.Stateful {
    
    @InvocableMethod(label='Execute EmailLog Platform Event Bus Republish Batch' description='This method will  execute PRM_Email_Log_PlatformEventBus_Republish')
    public static void executePlatformEventBusRepublishBatch() {
        Integer batchSize=1;
        //Query Custom Setting for Batch Size
        List<Core_Platform_Event_Attempts__c> platFormEventAttempList = [SELECT Id, Core_Batch_Size__c FROM Core_Platform_Event_Attempts__c WITH SECURITY_ENFORCED limit 1];
        if(platFormEventAttempList!=null && platFormEventAttempList.size()>0 && platFormEventAttempList[0]!=null && platFormEventAttempList[0].Core_Batch_Size__c!=null){
            batchSize = Integer.valueOf(platFormEventAttempList[0].Core_Batch_Size__c);
        }
        
        PRM_Email_Log_PlatformEventBus_Republish pEBBatch = new PRM_Email_Log_PlatformEventBus_Republish();
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
        query='SELECT Name,Core_Message__c, Core_Status__c, Core_Object_API_Name__c, Core_Number_Of_Attempts__c FROM Core_Platform_Event_Log__c where Core_IsActive__c=True and Core_Status__c=\'failed\' and Core_Number_Of_Attempts__c<:maxAttempts';
                
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Core_Platform_Event_Log__c> eventLogList){
        try{            
            string recordId;
            List<Integer> numberOfattempts =new List<Integer>(); 
            List<Id> platformEventLogId = new List<Id>();
            for(Core_Platform_Event_Log__c eventLog1: eventLogList){               
                recordId =eventLog1.Core_Message__c;
                eventLog1.Core_Status__c='republish';
                numberOfattempts.add(Integer.valueOf(eventLog1.Core_Number_Of_Attempts__c));
                platformEventLogId.add(eventLog1.Id);
            }
            update eventLogList;   
            System.debug('record ID'+recordId);
            List<PRM_EmailLog__c> emailList =[SELECT Name, PRM_Subject__c, PRM_Read__c, PRM_EmailContent__c, CreatedDate FROM PRM_EmailLog__c WHERE Name =: recordId];
            PRM_Email_Log_Utility.publish_Platform_EventWrapper wrapperInstance = new PRM_Email_Log_Utility.publish_Platform_EventWrapper();
            wrapperInstance.republishList = emailList;
            wrapperInstance.isRepublish = True;
            wrapperInstance.platFormEventLogidList = platformEventLogId;
            wrapperInstance.attemptList = numberOfattempts;
            PRM_Email_Log_Utility.publish_Platform_Event(wrapperInstance);

            //PRM_Email_Log_Utility.publish_Platform_Event(emailList, True, platformEventLogId, numberOfattempts);     
        }        
        catch(Exception e)
        {            
            //system.debug('#ex:Message:'+e.getMessage());
            system.debug('#ex:LineNumber:'+e.getLineNumber());
        }
        
    }    
    global void finish(Database.BatchableContext bc){
        
    }    
}