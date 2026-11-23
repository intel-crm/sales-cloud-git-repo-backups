@isTest
public class PRM_ReminderEmail_UtilityTest {
@testSetup
public static void createData() {   
Campaign testCampaign1 = new Campaign(Name='Test1', Description='Tewst', Core_Activity_Types__c='Promotion',
                                             Status='Planned', EndDate=Date.today().addMonths(1));
        insert testCampaign1;
        PRM_Reminder_Email__c rem1 = new PRM_Reminder_Email__c();
        rem1.PRM_Campaign__c=testCampaign1.id;
        rem1.PRM_Status__c='Scheduled';
        rem1.PRM_BatchID__c='BB-1001';
        rem1.PRM_Email_Template__c ='CampaignInviteForBulk_Rem_ENG';
        rem1.PRM_Reminder_Date__c = system.today();
        insert rem1;
}
    @isTest
    public static void testReminder()
    {
        PRM_Reminder_Email__c rr = [select id,PRM_Email_Template__c,PRM_Status__c from PRM_Reminder_Email__c limit 1];
        rr.PRM_Status__c = 'Reminder Processed';
        rr.PRM_Email_Template__c ='CampaignInviteForBulk';
        update rr;
           
    }
    @isTest
    public static void testReminder1()
    {
     
    Campaign testCampaign2 = [select id from campaign limit 1];
        List<PRM_Reminder_Email__c> remList = new  List<PRM_Reminder_Email__c>();
        PRM_Reminder_Email__c rem1 = new PRM_Reminder_Email__c();
        rem1.PRM_Campaign__c=testCampaign2.id;
        rem1.PRM_Status__c='Scheduled';
        rem1.PRM_BatchID__c='BB-1001';
        rem1.PRM_Email_Template__c ='CampaignInviteForBulk_Rem_ENG';
        rem1.PRM_Reminder_Date__c = system.today();
        //insert rem1;
        remList.add(rem1);
        PRM_ReminderEmail_Utility.updateTemplateName(remList,null);
    }
     
}