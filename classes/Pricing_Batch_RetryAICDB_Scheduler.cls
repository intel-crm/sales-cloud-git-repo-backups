/****************************************************************************************************************************************************
 * Class Name           : Pricing_Batch_RetryAICDB_Scheduler
 * Version              : 1.0
 * Created Date         : 07-07-2026
 * Modification Log     :
 * Developer            Date             Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------
 * Sinduja                07-07-2026       Scheduler class for CDB Outbound Integration Retry for AI Pricing Process
 ******************************************************************************************************************************************************/
global without sharing class Pricing_Batch_RetryAICDB_Scheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        Integer batchSize = Integer.valueOf(Label.Pricing_Application_Agent_Retry_Batch_Size);
        Database.executeBatch(new Pricing_Batch_RetryAICDBOutbound('Pricing Application Agent'), batchSize);
    }
}