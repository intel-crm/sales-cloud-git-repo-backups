/**************************************************************************************************************
Apex Class Name:  Delete_Old_Entries_Batch_Test
Version     : 1.0 
Created Date: 07 Sep 2022
Function    : Test class for Delete_Old_Entries
Note		: 
Modification Log :
* Developer                      Date              Description
* ----------------------------------------------------------------------------                 
* Sreeharsha Karanam             07/09/2021        Initial version
***************************************************************************************************************/
@isTest //(seeAllData=true)
public class Delete_Old_Entries_Batch_Test  {

    static testMethod void testDeletion() {
        
        core_Log_Entry__c testEntry = new Core_Log_Entry__c(Core_Origin__c='Batch Cleanup Test', Core_Severity__c='Test',
                                                          Core_When__c=DateTime.now());
        insert testEntry;
        String noOfDays = 'LAST_90_DAYS';
        String objectName = 'Core_Log_Entry__c';
        String notifyEmail = 'sreeharshax.karanam@intel.com';
        
        Test.startTest();
        Delete_Old_Entries_Batch DOE = new Delete_Old_Entries_Batch(objectName,noOfDays,notifyEmail);  
        Database.executeBatch(DOE);
        Test.stopTest();
    }
    
}