@IsTest
public class UCD_ACM_AccountBusinessTypeHandlerTest {
    @TestSetup
    private static void setCommonData(){
        insert new Core_Trigger_Executions__c(Name='UCD_ACM_ExecutePlatformEvent',Core_Active__c = true,
                                            Core_Class_Name__c='Test',Core_Description__c='TestDescription',Core_Object__c='TestObject',
                                            Core_Trigger_Events__c = 'TestEvent');
                                             
        insert new Core_Trigger_Executions__c(Name='UCD_ACM_EnableReltioSync',Core_Active__c = true,
                                            Core_Class_Name__c='ReltioSyncAccountBusinessTypes',Core_Description__c='ReltioSyncAccountBusinessTypes',Core_Object__c='AccountBusinessTypes',
                                            Core_Trigger_Events__c = 'TestEvent');
        
        // Create Parent Account
        Account parentAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        insert parentAccount;
        
        // Create End Customer Deal Account
        Account acc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('AccountForBusinessType','End Customer Deal Account','UNFD_GLBL_CUST');
        acc.parentId = parentAccount.Id;
        acc.Core_Survivor_Account_Id__c = parentAccount.Id;
        insert acc;
       
        // Create Business Type
        Business_Types__c businessType = UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Direct Price Exception','DIR_PRC_EXCPT');
        insert businessType;

        // Create Account Business Type
        Account_Business_Types__c accountBusinessType = UCD_ACM_Cntrlr_TestDataInitialization.createAccountBusinessType(acc.Id,businessType.Id);
        insert accountBusinessType;
    }
    
    @isTest
    private static void whenAccountBusinessTypeIsCreated(){
        Account acc = [Select Id from Account where Name = 'AccountForBusinessType'];
        Business_Types__c businessType = [Select Id from Business_Types__c where Name = 'Direct Price Exception'];
        
        Account_Business_Types__c accountBusinessType = new Account_Business_Types__c();
        accountBusinessType.Account__c = acc.Id;
        accountBusinessType.Business_Types__c = businessType.Id;
        accountBusinessType.Effective_Start_Date__c = system.today()-5;
        accountBusinessType.Effective_End_Date__c = system.today()+5;
        
        test.startTest();
        insert accountBusinessType;
        test.stopTest();
    }
    
    
    @isTest
    private static void whenAccountBusinessTypeIsUpdated(){
        Account_Business_Types__c accountBusinessType = [Select Effective_Start_Date__c,Effective_End_Date__c from Account_Business_Types__c limit 1];
        accountBusinessType.Effective_Start_Date__c = system.today()-10;
        accountBusinessType.Effective_End_Date__c = system.today()+10;
        Test.startTest();
        update accountBusinessType;
        Test.stopTest();
    }

    @isTest
    private static void whenAccountBusinessTypeThrowError(){
        Account_Business_Types__c accountBusinessType = [Select Effective_Start_Date__c,Effective_End_Date__c from Account_Business_Types__c limit 1];
        accountBusinessType.Effective_Start_Date__c = system.today()-10;
        accountBusinessType.Effective_End_Date__c = system.today()+10;
        Test.startTest();
        UCD_ACM_AccountService.isTestException = true;
        update accountBusinessType;
        Test.stopTest();
    }
}