global without sharing class PRM_ScheduleEmailReminder implements Schedulable  {
    global void execute(SchedulableContext sc) {
        Integer numberofRecordstoProcess = integer.valueof(System.Label.PRM_Email_Reminder_Run);
        PRM_EmailReminderBatch b = new PRM_EmailReminderBatch(); 
        Database.executeBatch(b,numberofRecordstoProcess);
    }
}