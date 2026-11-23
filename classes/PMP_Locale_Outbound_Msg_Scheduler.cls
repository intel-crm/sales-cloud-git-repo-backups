global class PMP_Locale_Outbound_Msg_Scheduler implements Schedulable  
{
	global void execute(SchedulableContext sc) 
    {
        PMP_Batch_Locale_Outbound_Msg bc = new PMP_Batch_Locale_Outbound_Msg('50');
        database.executebatch(bc);
    }
}