/**************************************************************************************************************Apex Class Name:  Core_Batch_Delete_Old_Log_Entries
Version     : 1.0 
Created Date: 28 July 2016
Function    : Test class for the batch class to delete Log Entry records older than 90 days
Modification Log :
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
* Dave Hood             07/28/2016        Initial version
***************************************************************************************************************/

// Using seeAllData=true as a special case here since we need to get log entries...
@isTest //(seeAllData=true)
public class Core_Batch_Delete_Old_Log_Entries_Test {

    static testMethod void testDeletion() {
        
        Core_Log_Entry__c testEntry = new Core_Log_Entry__c(Core_Origin__c='Batch Cleanup Test', Core_Severity__c='Test',
                                                            Core_When__c=DateTime.now());
        insert testEntry;
        
        Test.startTest();
        Database.executeBatch(new Core_Batch_Delete_Old_Log_Entries());
        Test.stopTest();
    }
    
    static testMethod void testScheduling() {
      Test.startTest();
 
      // Schedule the test job
      String jobId = System.schedule('ScheduleApexClassTest', '0 0 0 15 3 ? 2022', new Core_Schedule_Batch_Delete_Old_Logs());
      Test.stopTest();
    }
}