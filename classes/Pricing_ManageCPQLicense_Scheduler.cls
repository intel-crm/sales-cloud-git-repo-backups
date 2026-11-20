/**************************************************************************************
Apex Class Name : Pricing_ManageCPQLicense_Scheduler
Version     : 1.0 
Description : Scheduler class to Schedule Pricing_ManageCPQLicenseAssignment class
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Mahesh                  09/07/2020             Original Version
*************************************************************************************/
public without sharing class Pricing_ManageCPQLicense_Scheduler implements Schedulable {
    public void execute(SchedulableContext sc){
        /*Pricing_ManageCPQLicenseAssignment mlp = new Pricing_ManageCPQLicenseAssignment();       
        database.executebatch(mlp);*/
        
        Pricing_MyDealsRetryBatch pmdr = new Pricing_MyDealsRetryBatch();
        database.executeBatch(pmdr, Integer.valueof(Label.Pricing_MyDealsRetry_Batch_Size));

        Pricing_QuoteTeam_QuoteSharing_Batch batchObj = new Pricing_QuoteTeam_QuoteSharing_Batch();
        database.executeBatch(batchObj, Integer.valueof(Label.Pricing_Quote_Team_Batch_Size_Label));

        Flow.Interview decisionTableFlow = Flow.Interview.createInterview('Pricing_Decision_Table_Refresh_Flow_From_Batch',new Map<String, Object>());
        decisionTableFlow.start();
    }
}