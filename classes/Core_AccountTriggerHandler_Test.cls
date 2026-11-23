@isTest
public class Core_AccountTriggerHandler_Test {
    @TestSetup
    public static void setData(){
        
        insert new Core_Trigger_Executions__c(Name='UCD_ACM_ExecutePlatformEvent',Core_Active__c = true,
                Core_Class_Name__c='Test',Core_Description__c='TestDescription',Core_Object__c='TestObject',
                Core_Trigger_Events__c = 'TestEvent');
        insert new Core_Trigger_Executions__c(Name='BypassAccTriggerOnSalesAssistUpdate',Core_Active__c = true,
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

        insert new Core_Trigger_Executions__c(Name='AccountTriggerExecution',Core_Active__c = true,
                Core_Class_Name__c='Test5',Core_Description__c='TestDescription6',Core_Object__c='TestObject6',
                Core_Trigger_Events__c = 'TestEvent6');

        insert new Core_Trigger_Executions__c(Name='accountObjectBeforeHandler',Core_Active__c = true,
                Core_Class_Name__c='Test Class',Core_Description__c='This is test description',Core_Object__c='Descriptive Feature',
                Core_Trigger_Events__c = 'After insert');

        insert new Core_Trigger_Executions__c(Name = 'Core_MDF_MultipleVCForSameProg',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountHandler',Core_Description__c = 'To Prevent Multiple Virtual Corp for same program.',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'before insert');

        insert new Core_Trigger_Executions__c(Name = 'ValidateTierValues',Core_Active__c = true,
                Core_Class_Name__c = 'Core_AccountHandler',Core_Object__c = 'Account',
                Core_Trigger_Events__c = 'After Update',Core_Description__c = 'Update the related MDA Partner info when ever Account updated.');
        
        insert new Core_Trigger_Executions__c(Name = 'accountPreventAEUserOwnership',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountHandler',Core_Description__c = 'This is Test Descriptions',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'before update');

        insert new Core_Trigger_Executions__c(Name = 'Account_Update_IPA_Integration_Trigger',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountHandlerTest1',Core_Description__c = 'This is Test Descriptions1',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'before update');

        insert new Core_Trigger_Executions__c(Name = 'preventUncoveredAccountChange',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountHandlerTest2',Core_Description__c = 'This is Test Descriptions2',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'before update');

        insert new Core_Trigger_Executions__c(Name = 'Core_MDF_ValidatePFAChange',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountHandlerTest3',Core_Description__c = 'This is Test Descriptions3',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'before update');

        insert new Core_Trigger_Executions__c(Name = 'Core_MDF_createGroupForAccountNode',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountHandlerTest4',Core_Description__c = 'This is Test Descriptions4',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'After Insert');

        insert new Core_Trigger_Executions__c(Name = 'Core_MDF_ShareAccountsWithGroups',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountHandlerTest5',Core_Description__c = 'This is Test Descriptions5',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'After Insert');

        insert new Core_Trigger_Executions__c(Name = 'Core_MDF_Account_node_share',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountHandlerTest6',Core_Description__c = 'This is Test Descriptions6',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'After Insert');

        insert new Core_Trigger_Executions__c(Name = 'UpdatePrimaryDirectAccount',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountHandlerTest7',Core_Description__c = 'This is Test Descriptions7',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'After Insert');

        insert new Core_Trigger_Executions__c(Name = 'CIMIDStampCheck',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountHandlerTest8',Core_Description__c = 'This is Test Descriptions8',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'After Update');

        insert new Core_Trigger_Executions__c(Name = 'Update_MP_Partners',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountHandlerTest9',Core_Description__c = 'This is Test Descriptions9',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'After Update');

        insert new Core_Trigger_Executions__c(Name = 'accountPartnerTypeAfterUpate',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountHandlerTest10',Core_Description__c = 'This is Test Descriptions10',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'After Update');

        insert new Core_Trigger_Executions__c(Name = 'Roll_up_account',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountHandlerTest11',Core_Description__c = 'This is Test Descriptions11',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'After Update');
        
        insert new Core_Trigger_Executions__c(Name = 'accountObjectAfterDelete',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountHandlerTest12',Core_Description__c = 'This is Test Descriptions12',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'After Delete');
        insert new Core_Trigger_Executions__c(Name = 'UCD_ACM_UpdateRecordtype',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountHandlerTest12',Core_Description__c = 'This is Test Descriptions12',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'After Delete');
        insert new Core_Trigger_Executions__c(Name = 'UCD_ACM_PublishAccount',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountHandlerTest12',Core_Description__c = 'This is Test Descriptions12',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'After Delete');
        insert new Core_Trigger_Executions__c(Name = 'PRM_CreateTrackerMilestones',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountHandlerTest12',Core_Description__c = 'This is Test Descriptions12',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'After Delete');

        insert new Core_Trigger_Executions__c(Name = 'Core_MDF_UpdateHostRegionOnNodeAcc',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountTriggerHandler',Core_Description__c = 'To update the host region on node accounts from its parent fund account',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'Before Insert');
        
        insert new Core_Trigger_Executions__c(Name = 'Core_MDF_UpdateHostRegionAfterVCUpdate',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountTriggerHandler',Core_Description__c = 'Update the host region on node accounts when a virtual corps host region is updated',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'After Update');
        
        insert new Core_Trigger_Executions__c(Name = 'Core_MDF_IPA_Account_Region_Check',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountTriggerHandler',Core_Description__c = 'To restrict the updates of region and sub-region field on IPA Co-Marketing Account',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'Before Update');
        
        insert new Core_Trigger_Executions__c(Name = 'UnifiedHierarchyView',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountTriggerHandler',Core_Description__c = 'To restrict the updates of region and sub-region field on IPA Co-Marketing Account',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'Before Update');

        insert new Core_Trigger_Executions__c(Name = 'Core_MDF_ValidatePFAChangeOnAftrUpdt',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountTriggerHandler',Core_Description__c = 'To restrict the updates of region and sub-region field on IPA Co-Marketing Account',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'Before Update');

        insert new Core_Trigger_Executions__c(Name = 'accountDetailsUpdateOnPsgMethod',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountTriggerHandler',Core_Description__c = 'To restrict the updates of region and sub-region field on IPA Co-Marketing Account',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'Before Update');
        
        insert new Core_Trigger_Executions__c(Name = 'Core_MDF_AccountOnBeforeInsert',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountTriggerHandler',Core_Description__c = 'To restrict the updates on before insert',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'Before Insert');
        
        insert new Core_Trigger_Executions__c(Name = 'Core_MDF_AccountOnBeforeUpdate',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountTriggerHandler',Core_Description__c = 'To restrict the updates on before update',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'Before update');
        
        insert new Core_Trigger_Executions__c(Name = 'Core_MDF_AccountOnAfterInsert',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountTriggerHandler',Core_Description__c = 'To restrict the updates on after insert',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'After Insert');
        
        insert new Core_Trigger_Executions__c(Name = 'Core_MDF_AccountOnAfterUpdate',Core_Active__c = True,
                Core_Class_Name__c = 'Core_AccountTriggerHandler',Core_Description__c = 'To restrict the updates on after update',
                Core_Object__c = 'Account',Core_Trigger_Events__c = 'After Update');

    }
    @isTest
    public static void whenBeforeInsert(){
        Test.startTest();
        Core_AccountTriggerHandler ucdAccountHandlers = new Core_AccountTriggerHandler();
        ucdAccountHandlers.beforeInsert();
        Test.stopTest();
    }
    @isTest
    public static void whenBeforeUpdate(){
        Test.startTest();
        Core_AccountTriggerHandler ucdAccountHandlers = new Core_AccountTriggerHandler();
        ucdAccountHandlers.beforeUpdate();
        Test.stopTest();
    }
    @isTest
    public static void whenBeforeDelete(){
        Test.startTest();
        Core_AccountTriggerHandler ucdAccountHandlers = new Core_AccountTriggerHandler();
        ucdAccountHandlers.beforeDelete();
        Test.stopTest();
    }
    
    @isTest
    public static void whenAfterInsert(){
        Test.startTest();
        Core_AccountTriggerHandler ucdAccountHandlers = new Core_AccountTriggerHandler();
        ucdAccountHandlers.afterInsert();
        Test.stopTest();
    }
    @isTest
    public static void whenAfterUpdate(){
        Test.startTest();
        Core_AccountTriggerHandler ucdAccountHandlers = new Core_AccountTriggerHandler();
        ucdAccountHandlers.afterUpdate();
        Test.stopTest();
    }
    @isTest
    public static void whenAfterDelete(){
        Test.startTest();
        Core_AccountTriggerHandler ucdAccountHandlers = new Core_AccountTriggerHandler();
        ucdAccountHandlers.afterDelete();
        Test.stopTest();
    }
    @isTest
    public static void whenAfterUnDelete(){
        Test.startTest();
        Core_AccountTriggerHandler ucdAccountHandlers = new Core_AccountTriggerHandler();
        ucdAccountHandlers.afterUndelete();
        Test.stopTest();
    }

}