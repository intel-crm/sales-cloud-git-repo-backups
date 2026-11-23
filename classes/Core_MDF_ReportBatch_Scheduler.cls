/*************************************************************************************************
Class Name  : Core_MDF_ReportBatch_Scheduler
Function    : Schedulable class to run Core MDF Report Batch Class
Modification Log :
* Developer              Date          Description
* ---------------------------------------------------------------------------- 
* Akash Bawankar         04/06/2025    Original version
**************************************************************************************************/
global class Core_MDF_ReportBatch_Scheduler implements Schedulable {
	 global void execute(SchedulableContext sc) 
    {
        Core_MDF_ReportBatch batch = new Core_MDF_ReportBatch();
        database.executeBatch(batch,100);
    }
     Public static void SchedulerMethod() 
    {
        //String strJobName = 'Hourly Reports Batch Job';
        
          //System.schedule(strJobName, '0 0 * * * ?', new Core_MDF_ReportBatch_Scheduler());
        
    }
}