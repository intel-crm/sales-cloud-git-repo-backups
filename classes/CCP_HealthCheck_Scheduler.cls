global class CCP_HealthCheck_Scheduler implements Schedulable  
{
	global void execute(SchedulableContext sc) 
    {
        CCP_HealthCheck_Batch bc = new CCP_HealthCheck_Batch();
        ID batchprocessid=database.executebatch(bc,1);
        System.debug('Returned batch process ID: ' + batchProcessId);
        
    }
}