/****************************************************************************************************************************************
* Class Name  : PMP_GenerateDQReportSolutionBatch 
* Version     : 1.0 
* Created Date: 08/11/2022 
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandhya Dayananda                08/11/2022             This batch class is used to generate DQ reports for Solution, batch size should be always 1
*****************************************************************************************************************************************/
global class PMP_GenerateDQReportSolutionBatch implements Database.Batchable<sObject> {
//IPA2.0: US-TWC729-7976
	
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
    /*global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id,PSS_Proposal_Name_Txt__c,PSS_Partner_Solution_Lifecycle_Status_Nm__c,PSS_Partner_Offering__r.Name from ArdiraSurvey__Survey_Result__c where PSS_Partner_Solution_Lifecycle_Status_Nm__c IN (\'Converted To MP Offerings\',\'Approved\') ';
        return Database.getQueryLocator(query);   
    }
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        system.debug('scope---'+scope);
        List<ArdiraSurvey__Survey_Result__c> solutionList = new List<ArdiraSurvey__Survey_Result__c>();
        if(scope != null){
            for(ArdiraSurvey__Survey_Result__c solutionRec : (List<ArdiraSurvey__Survey_Result__c>)scope){
                if(solutionRec.PSS_Partner_Solution_Lifecycle_Status_Nm__c=='Converted To MP Offerings'){
                    solutionList.add(solutionRec);
                }
                
            }
            if(!solutionList.isEmpty()){
                PMP_GenerateDQReportUtility.getSolutionIssueRecords(solutionList);
            }
            
            
        }
    }
    
    global void finish(Database.BatchableContext bc){
        Database.executeBatch(new PMP_UpdateDQReportBatch());
    }*/
}