/****************************************************************************************************************************************
* Class Name  : PMP_GenerateDQReportOfferingBatch 
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal                 22/08/2022            This batch class is used to generate DQ reports for Offering, batch size should be always 1
*****************************************************************************************************************************************/
//IPA2.0 - As part of TWC729-7977 commented the entire class & added dummy syntax to override error
global class PMP_GenerateDQReportOfferingBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // added dummy syntax to override error
       return null;
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        // added dummy syntax to override error
    }

    global void finish(Database.BatchableContext bc) {
        // added dummy syntax to override error
    }
  /*
    global Database.QueryLocator start(Database.BatchableContext bc) {
     
        String query = 'Select Id,PMP_Offering_Language_Nm__c,Name,PMP_Partner_Offering_Tag_Line_Txt__c,PMP_Partner_Offering_Dsc__c,PMP_Partner_Offering_Lifecycle_Status_Nm__c from PMP_Partner_Offering__c';
        
        return Database.getQueryLocator(query);   
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        if(scope !=null){
            List<PMP_Partner_Offering__c> translationOffList = new List<PMP_Partner_Offering__c>();
            for(PMP_Partner_Offering__c off : (List<PMP_Partner_Offering__c>)scope)
            {
                if(off.PMP_Partner_Offering_Lifecycle_Status_Nm__c =='Draft' || off.PMP_Partner_Offering_Lifecycle_Status_Nm__c =='Admin Review'
                   || off.PMP_Partner_Offering_Lifecycle_Status_Nm__c =='Update Required')
                {
                    translationOffList.add(off);
                }
            }
            if(!translationOffList.isEmpty())
            {
                 PMP_GenerateDQReportUtility.getOfferingTranslationRecords(translationOffList);
            }         
            PMP_GenerateDQReportUtility.getOfferingImageIssueRecords((List<PMP_Partner_Offering__c>)scope);
        }   
    }   
    
    global void finish(Database.BatchableContext bc){
        Database.executeBatch(new PMP_GenerateDQReportSolutionBatch(),1);
      // Database.executeBatch(new PMP_UpdateDQReportBatch());     
    }
*/
}