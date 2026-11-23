public class PRM_ScheduleCampaignReminderEmail implements Schedulable{
  public void execute(SchedulableContext sc) { 
  Integer numberofRecordstoProcess = integer.valueof(System.Label.PRM_Reminder_Processing);
  PRM_SendCampaignReminderEmail reminder = new PRM_SendCampaignReminderEmail();
      Database.executeBatch(reminder,numberofRecordstoProcess);
      }
}