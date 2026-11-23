/****************************************************************************************************************************************
* Class Name  : PMP_GenerateDQReportAccountBatch 
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal                 22/08/2022            This batch class is used to generate DQ reports for OPID & Intel Accounts
                                                          Batch size should be always 1
*****************************************************************************************************************************************/
global class PMP_GenerateDQReportAccountBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> accTypeList = new List<String>();
        accTypeList.add('Intel Account');
        accTypeList.add('Partner Account Group');
        String query = 'Select Id,Name from Account where RecordType.Name in :accTypeList' ;
        
        return Database.getQueryLocator(query);   
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        if(scope !=null){
            PMP_GenerateDQReportUtility.getOPIDAccountBenefitIssueRecords((List<Account>)scope);
        }     
    }   
    
    global void finish(Database.BatchableContext bc){
        Database.executeBatch(new PMP_UpdateDQReportBatch());  
    } 
}