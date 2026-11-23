/**************************************************************************************
Apex Class Name:  Core_PartnerLead_ScheduleEmail_Test
Version     : 1.0 
Created Date: 28 August 2019
Function    : This test class is used for partner lead summary and reminder email scheduler class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar             28/08/2019              Original Version
*************************************************************************************/
@isTest
public class Core_PartnerLead_ScheduleEmail_Test {

    public static testMethod void scheduleSummaryEmail(){
        Test.startTest();
        String cronExp = '0 0 21 ? * *';
        Core_Lead_Daily_PartnerNotification summary = new Core_Lead_Daily_PartnerNotification();
        System.schedule('Partner Lead Summary Email', cronExp, summary);
        Test.stopTest();
    }
    
    public static testMethod void scheduleReminderEmail(){
        Test.startTest();
        String cronExp = '0 0 5 ? * *';
        Core_Lead_Weekly_PartnerNotification reminder = new Core_Lead_Weekly_PartnerNotification();
        System.schedule('Partner Lead Reminder Email', cronExp, reminder);
        Test.stopTest();
    }
}