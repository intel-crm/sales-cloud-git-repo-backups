@isTest
public class PRM_ScheduleCampaignReminderEmailTest {
    @isTest
    public static void testReminder(){
     PRM_ScheduleCampaignReminderEmail sh1 = new PRM_ScheduleCampaignReminderEmail();
        String sch = '0 0 23 * * ?'; 
        String jobId = system.schedule('Test Reminder', sch, sh1); 
    }

}