/****************************************************************************************************************************************
* Class Name  : PMP_GenerateDQReportBatchScheduler 
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal                 06/04/2022            this is the scheduler class for PMP_GenerateDQReportStorefrontBatch batch class
*****************************************************************************************************************************************/
global class PMP_GenerateDQReportBatchScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        DataBase.executeBatch(new PMP_GenerateDQReportStorefrontBatch(),1);
    }
}