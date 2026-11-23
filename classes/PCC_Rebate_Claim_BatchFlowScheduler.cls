global class PCC_Rebate_Claim_BatchFlowScheduler implements Database.Batchable<sObject> {
    
     String flowApiName='PCC_Rebate_Analyst_Actions';
    
    // public PCC_Rebate_Claim_BatchFlowScheduler(String flowApiName) {
    //     this.flowApiName = 'PCC_Rebate_Analyst_Actions';
    // }
    // start method - collects the records to process
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id FROM PCC_Rebate_Claim__c LIMIT 1]);
        
    }
    
    // execute method - invokes the auto-launched flow for each batch of records
    global void execute(Database.BatchableContext BC, List<PCC_Rebate_Claim__c> scope) {
        Map<String, Object> params = new Map<String, Object>();
        // Start the auto-launched flow
        Flow.Interview.PCC_Rebate_Analyst_Actions flow = new Flow.Interview.PCC_Rebate_Analyst_Actions(params) ;
        flow.start();
    }
    
    global void finish(Database.BatchableContext BC) { 
        // You can send an email, create a log record, or perform another operation here
    }
}