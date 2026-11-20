/***************************************************************************************************************************************
Apex Class Name     : PRM_ISVCDQBatch
    Version             : 1.0
    Created Date        : May 2026
    Function            : Batch class to fix status of Outbound Messages
    Maximum Batch Size  : 100
    Modification Log    :
     * Developer                         Date                           Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------
 * Ruchi                       24th May 2026                     Start Method returns all the Outbound Messages which are modified in Last specified number of hours.
 *************************************************************************************************************************************************************/


global class PRM_ISVCDQBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {

        DateTime lastSuccessfulRun;
        PRM_BatchCustomSetting__c batchCustomSetting;
        batchCustomSetting = [Select Id, Name, PRM_NoOfRecords__c, PRM_SchedulingHour__c,PRM_PartnerType__c,PRM_ChannelProgramLevel__c From PRM_BatchCustomSetting__c Where Name =:System.Label.PRM_BatchValues];
        Integer batchExecutionInterval = batchCustomSetting.PRM_SchedulingHour__c.intValue();
        DateTime batchExecutionHours = System.Now().addHours(- batchExecutionInterval);

        //Query on AsyncApexJob to get the identical records which got modified in last 6 hrs.
        List<AsyncApexJob> lastBatchRun = [SELECT CompletedDate FROM AsyncApexJob WHERE ApexClass.Name = 'PRM_ISVCDQBatch' AND Status =:System.Label.PRM_AsyncStatus Order By CompletedDate DESC LIMIT 1];

        Set<String> coreTags = new Set<String>();

        if(lastBatchRun != NULL && !lastBatchRun.IsEmpty()){
            lastSuccessfulRun = (DateTime)lastBatchRun[0].CompletedDate;
            for(Core_Integration_Outbound_Message__c objid : [SELECT id, name, Core_MessageType__c, Core_Tags__c, CreatedDate FROM Core_Integration_Outbound_Message__c WHERE Core_Status__c = 'Successful' AND (Core_MessageType__c ='Account Integration' OR Core_MessageType__c = 'Contact Integration') AND (LastModifiedDate > :batchExecutionHours OR LastModifiedDate > :lastSuccessfulRun) ]){
                coreTags.add(objid.Core_Tags__c);
            }
        }
        else{
            for(Core_Integration_Outbound_Message__c objid : [SELECT id, name, Core_MessageType__c, Core_Tags__c, CreatedDate FROM Core_Integration_Outbound_Message__c WHERE Core_Status__c = 'Successful' AND (Core_MessageType__c ='Account Integration' OR Core_MessageType__c = 'Contact Integration') AND (LastModifiedDate > :batchExecutionHours) ]){
                coreTags.add(objid.Core_Tags__c);
            }
        }

        return Database.getQueryLocator(
            'SELECT Id, Name, Core_Status__c, Core_MessageType__c, Core_Tags__c, CreatedDate ' +
            'FROM Core_Integration_Outbound_Message__c ' +
            'WHERE Core_Tags__c IN :coreTags ' +
            'AND (Core_MessageType__c = \'Account Integration\' ' +
            'OR Core_MessageType__c = \'Contact Integration\') ' +
            'AND Core_Status__c = \'Pending\' ' +
            'AND CreatedDate >= 2026-04-01T00:00:00.456+05:30'
            );
  }

  global void execute(Database.BatchableContext context, List<Core_Integration_Outbound_Message__c> scope){
        String logEntryMsgString='';
        logEntryMsgString+='\nPRM_ISVCDQBatch execute method invoked at:'+System.Now().format('MM/dd/YYYY HH:MM:SS','PST')+' PST dt@@@';
        logEntryMsgString+='\n\nScope for execute method:'+scope;
        List<Core_Integration_Outbound_Message__c> inboundToBeUpdated = new List<Core_Integration_Outbound_Message__c>();
        try{
            logEntryMsgString+='\nMaking outbound messages stuck in pending to Discard.';
            for(Core_Integration_Outbound_Message__c inboundobj : scope){
                inboundobj.Core_Status__c = 'Discard';
                inboundToBeUpdated.add(inboundobj);

            }
            List<Database.SaveResult> dqResultList = Database.update(inboundToBeUpdated,false);
            for(Database.SaveResult dqResult: dqResultList){
                if(!dqResult.isSuccess()){
                    for (Database.Error err : dqResult.getErrors()) {
                        logEntryMsgString+= 'Message: ' + err.getMessage() + '\n'  + 'Fields: ' + err.Fields.toString() + '\n' + 'StatusCode: ' + err.getStatusCode() + '\n';
                    }
                }
            }
        }catch(Exception exp){
            logEntryMsgString+='\n\nException occurred:'+exp.getMessage() + '-' + exp.getStackTraceString();
            PRM_IPA_Utility.createLogEntry(logEntryMsgString, 'PRM_BenefitsUpdateBatch', 'IPA', null, 'error', '');
        }
    }

    global void finish(Database.BatchableContext context){
        
    }


}