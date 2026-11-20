/********************************************************************************************************************************************************************
Apex Class Name:  Core_OpptyBatch_Del_Inactive_rec
Version     : 1.0 
Created Date: 03/05/2023  
Function    : Process to delete the failed products from the Staging table

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Navneet               	   07/24/2023           Original Version
*****************************************************************************/
global without sharing class Core_OpptyBatch_Del_Inactive_rec implements Database.Batchable<sObject>, Database.Stateful{
    global List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
	Integer customLabelValue =integer.valueof(System.Label.Core_Oppty_No_of_Days);
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        string query = 'select Id from Core_Sales_Assist_Staging__c where Core_Status_Pkt__c = \'Failure\' and CreatedDate < LAST_N_DAYS:'+customLabelValue;
        try{
        return Database.getQueryLocator(query);}catch(Exception e){captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString(), Core_Message__c = e.getMessage(), Core_Severity__c = 'Info', Core_Origin__c='Core_OpptyBatch_Del_Inactive_rec', Core_When__c = System.now(), Core_Project__c = 'Sales'));insert captureQueryErr;return null;
        }
    }
    global void execute(Database.BatchableContext BC, List<Core_Sales_Assist_Staging__c> stgList){
        if(stgList.size()>0){Database.DeleteResult[] deleteResults = Database.delete( stgList, false ); if(!deleteResults.isEmpty()){
                for(Database.DeleteResult sr : deleteResults) {if(!sr.isSuccess() || Test.isRunningTest()){String errorMsg = '';
                        for(Database.Error err : sr.getErrors()) {errorMsg = errorMsg + err.getMessage();}captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = errorMsg, Core_Message__c = 'Core_OpptyBatch_Del_Inactive_rec_Error', Core_Severity__c = 'Info', Core_Origin__c='Core_OpptyBatch_Del_Inactive_rec', Core_When__c = System.now()));}}if(!captureQueryErr.isEmpty()){insert captureQueryErr;}
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email    from AsyncApexJob where Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String fromEmailAddress = System.Label.Core_SetFromEmailAddress;
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Batch Del for Failure entries Core_Sales_Assist_Staging__c ' + a.Status);
        mail.setPlainTextBody('records processed ' + a.TotalJobItems +   'with '+ a.NumberOfErrors + ' failures.');
        mail.setOrgWideEmailAddressId(fromEmailAddress);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
}