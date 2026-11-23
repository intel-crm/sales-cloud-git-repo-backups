/**************************************************************************************************************
Apex Class Name:  Core_Batch_Unlock_Opportunities_Test
Version     : 1.0 
Created Date: 31 MAR 2016
Function    : Test class for batch class that unlocks opportunities
Modification Log :
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
* Dave Hood             03/31/2016        Initial version
***************************************************************************************************************/
@isTest
public class Core_Batch_Unlock_Opportunities_Test {

    static testMethod void testUnlocking() {
        List<Opportunity> opps = Core_Test_Utility.createOpportunity(10);
        //newly added start
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId(); 
        Account accountForOpp = Core_Test_Utility.createAccount(1)[0];
        accountForOpp.Core_Sales_Groups__c = 'PRC Sales Group';
        accountForOpp.recordtypeID = accountRecordTypeIntel;
        insert accountForOpp;
        //newly added end
        for (Opportunity opp : opps) {
           opp.Core_Approval_Status__c = 'Submitted';
           opp.AccountId= accountForOpp.Id;
        }
        insert opps;
        
        Approval.lock(opps, false);
        
        Test.startTest();
        Database.executeBatch(new Core_Batch_Unlock_Opportunities());
        Test.stopTest();
        Assert.areEqual(true, opps!= null);
    }
    
    static testMethod void testScheduling() {
        String CRON_EXP = '0 0 0 15 3 ? *';
        Test.startTest();
        
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new Core_Schedule_Batch_Unlock_Opportunities());
        Test.stopTest();
        CronTrigger ct = [ SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId ];
		System.assertEquals(CRON_EXP, ct.CronExpression);
    }
}