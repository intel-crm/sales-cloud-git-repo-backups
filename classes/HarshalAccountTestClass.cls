@IsTest
public class HarshalAccountTestClass {
	 @TestSetup
    private static void setCommonData(){
        User us = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration'].Id,
                FirstName = 'Reltio',
                LastName = 'SFDC Connector',
                Email = 'Test@example.com',
                Username = 'Test@test.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'Test Title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            );
            insert us;
        insert new Core_Trigger_Executions__c(Name='UCD_ACM_ExecutePlatformEvent',Core_Active__c = true,
                                                 Core_Class_Name__c='Test',Core_Description__c='TestDescription',Core_Object__c='TestObject',
                                                 Core_Trigger_Events__c = 'TestEvent');
            insert new Core_Trigger_Executions__c(Name='UCD_ACM_IgnoreUpdateAccountFields',Core_Active__c = true,
                                                 Core_Class_Name__c='Test2',Core_Description__c='TestDescription2',Core_Object__c='TestObject2',
                                                 Core_Trigger_Events__c = 'TestEvent2');
            insert new Core_Trigger_Executions__c(Name='UCD_ACM_UpdateRecordType',Core_Active__c = true,
                                                 Core_Class_Name__c='Test3',Core_Description__c='TestDescription3',Core_Object__c='TestObject3',
                                                 Core_Trigger_Events__c = 'TestEvent3');
            insert new Core_Trigger_Executions__c(Name='UCD_ACM_UpdateHierarchy',Core_Active__c = true,
                                                Core_Class_Name__c='Test4',Core_Description__c='TestDescription4',Core_Object__c='TestObject4',
                                                Core_Trigger_Events__c = 'TestEvent4');
            insert new Core_Trigger_Executions__c(Name='UCD_ACM_EnableInfoLog',Core_Active__c = true,
                                                Core_Class_Name__c='Test5',Core_Description__c='TestDescription5',Core_Object__c='TestObject5',
                                                Core_Trigger_Events__c = 'TestEvent5');
            insert new Core_Trigger_Executions__c(Name='UCD_ACM_EnableReltioSync', Core_Active__c = true, Core_Class_Name__c='Test6', Core_Description__c='TestDescription6', Core_Object__c='TestObject6', Core_Trigger_Events__c = 'TestEvent6');
            
            insert new Core_Trigger_Executions__c(Name='UCD_ACM_UpdateParentOnAccount',Core_Active__c = true,
                                                Core_Class_Name__c='Test5',Core_Description__c='TestDescription5',Core_Object__c='TestObject5',
                                                Core_Trigger_Events__c = 'TestEvent5');
            insert new Core_Trigger_Executions__c(Name='accountDupCheck',Core_Active__c = true,
                                                Core_Class_Name__c='Test5',Core_Description__c='TestDescription5',Core_Object__c='TestObject5',
                                                Core_Trigger_Events__c = 'TestEvent5');


            /*insert new Core_Trigger_Executions__c(Name='accountObjectBeforeHandler',Core_Active__c = true,
                                                Core_Class_Name__c='Test5',Core_Description__c='TestDescription5',Core_Object__c='TestObject5',
                                                Core_Trigger_Events__c = 'TestEvent5');

            insert new Core_Trigger_Executions__c(Name='Core_MDF_MultipleVCForSameProg',Core_Active__c = true,
                                                Core_Class_Name__c='Test5',Core_Description__c='TestDescription5',Core_Object__c='TestObject5',
                                                Core_Trigger_Events__c = 'TestEvent5');


            insert new Core_Trigger_Executions__c(Name='Account_Update_IPA_Integration_Trigger',Core_Active__c = true,
                                                Core_Class_Name__c='Test5',Core_Description__c='TestDescription5',Core_Object__c='TestObject5',
                                                Core_Trigger_Events__c = 'TestEvent5');

            insert new Core_Trigger_Executions__c(Name='preventUncoveredAccountChange',Core_Active__c = true,
                                                Core_Class_Name__c='Test5',Core_Description__c='TestDescription5',Core_Object__c='TestObject5',
                                                Core_Trigger_Events__c = 'TestEvent5');

            insert new Core_Trigger_Executions__c(Name='Core_MDF_createGroupForAccountNode',Core_Active__c = true,
                                                Core_Class_Name__c='Test5',Core_Description__c='TestDescription5',Core_Object__c='TestObject5',
                                                Core_Trigger_Events__c = 'TestEvent5');

            insert new Core_Trigger_Executions__c(Name='Core_MDF_ShareAccountsWithGroups',Core_Active__c = true,
                                                Core_Class_Name__c='Test5',Core_Description__c='TestDescription5',Core_Object__c='TestObject5',
                                                Core_Trigger_Events__c = 'TestEvent5');

            insert new Core_Trigger_Executions__c(Name='CIMIDStampCheck',Core_Active__c = true,
                                                Core_Class_Name__c='Test5',Core_Description__c='TestDescription5',Core_Object__c='TestObject5',
                                                Core_Trigger_Events__c = 'TestEvent5');

            insert new Core_Trigger_Executions__c(Name='Core_MDF_Account_node_share',Core_Active__c = true,
                                                Core_Class_Name__c='Test5',Core_Description__c='TestDescription5',Core_Object__c='TestObject5',
                                                Core_Trigger_Events__c = 'TestEvent5');*/


            // Create Parent Account
            Account parentAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
            insert parentAccount;
        
        	parentAccount.Name = 'xyz';
        	update parentAccount;
    }
    
     @isTest
    private static void whenTriggerPlatformEventOnUpdate(){}
}