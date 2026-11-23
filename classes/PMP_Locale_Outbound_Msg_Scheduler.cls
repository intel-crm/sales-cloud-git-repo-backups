global with sharing class PMP_Locale_Outbound_Msg_Scheduler implements Schedulable  
{
	global void execute(SchedulableContext sc) 
    { //IPA2.0 - As part of TWC729-7977 commented the entire class
        //PMP_Batch_Locale_Outbound_Msg bc = new PMP_Batch_Locale_Outbound_Msg('50');
        //database.executebatch(bc);
    }
}