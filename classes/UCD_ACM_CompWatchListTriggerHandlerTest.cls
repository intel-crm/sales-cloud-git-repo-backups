@IsTest
public class UCD_ACM_CompWatchListTriggerHandlerTest {
    @TestSetup
    private static void setCommonData(){
        insert new Core_Trigger_Executions__c(Name='UCD_ACM_ExecutePlatformEvent',Core_Active__c = true,
                                              Core_Class_Name__c='Test',Core_Description__c='TestDescription',Core_Object__c='TestObject',
                                              Core_Trigger_Events__c = 'TestEvent');
        
        // Create Parent Account
        Account parentAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        insert parentAccount;
        
        // Create End Customer Deal Account
        Account acc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestComplianceWatchList','End Customer Deal Account','UNFD_GLBL_CUST');
        acc.parentId = parentAccount.Id;
        acc.Core_Survivor_Account_Id__c = parentAccount.Id;
        insert acc;
          
        // Create Compliance Watch List
        Core_Account_Compliance_Watch_List__c complianceWatchList = UCD_ACM_Cntrlr_TestDataInitialization.createComplianceWatchList(acc.Id,'NOTRDOUT');
        insert complianceWatchList;
    }
    
    
    
    @IsTest
    private static void whenComplianceWatchListUpdated(){
        Core_Account_Compliance_Watch_List__c complianceWatchList = [Select Id,Core_Effective_Start_Date__c,Core_Effective_End_Date__c,Core_Type__c from Core_Account_Compliance_Watch_List__c limit 1];
        //complianceWatchList.Core_Effective_Start_Date__c = system.today()-10;
        //complianceWatchList.Core_Effective_End_Date__c = system.today()+10;
        complianceWatchList.Core_Type__c = 'DELIST';
        Test.startTest();
        update complianceWatchList;
        Test.stopTest();
    }
    
    @IsTest
    private static void whenThrowError(){
        Core_Account_Compliance_Watch_List__c complianceWatchList = [Select Id,Core_Effective_Start_Date__c,Core_Effective_End_Date__c,Core_Type__c from Core_Account_Compliance_Watch_List__c limit 1];
        complianceWatchList.Core_Effective_Start_Date__c = system.today()-10;
        complianceWatchList.Core_Effective_End_Date__c = system.today()+10;
        complianceWatchList.Core_Type__c = 'DELIST';
        Test.startTest();
        UCD_ACM_AccountService.isTestException = true;
        update complianceWatchList;
        Test.stopTest();
    }
    
}