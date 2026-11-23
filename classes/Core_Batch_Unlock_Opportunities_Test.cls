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
        for (Opportunity opp : opps)
            opp.Core_Approval_Status__c = 'Submitted';
        insert opps;
        
        Approval.lock(opps, false);
        
        Test.startTest();
        Database.executeBatch(new Core_Batch_Unlock_Opportunities());
        Test.stopTest();
    }
    
    static testMethod void testScheduling() {
      Test.startTest();
 
      // Schedule the test job
      String jobId = System.schedule('ScheduleApexClassTest', '0 0 0 15 3 ? 2022', new Core_Schedule_Batch_Unlock_Opportunities());
      Test.stopTest();
    }
}