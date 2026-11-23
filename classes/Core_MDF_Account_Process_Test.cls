/******************************************************************************************************
* Class Name  : Core_MDF_Account_Process_Test 
* Version     : 1.0 
* Created Date: 24-08-2020
* Modification Log :
*******************************************************************************************************/
@isTest(SeeAllData = false)
public class Core_MDF_Account_Process_Test {
    @isTest static void createGroupForAccountNode_Test(){
        Core_Trigger_Executions__c groupIdForAccountNode = new Core_Trigger_Executions__c();
        groupIdForAccountNode.name = 'Core_MDF_createGroupForAccountNode';
        groupIdForAccountNode.Core_Object__c = 'Account';
        groupIdForAccountNode.Core_Trigger_Events__c = 'After Insert';
        groupIdForAccountNode.Core_Active__c = TRUE;
        groupIdForAccountNode.Core_Description__c = 'To Create Group for each account';
        groupIdForAccountNode.Core_Class_Name__c = 'Core_AccountHandler';
        insert groupIdForAccountNode;
        
        // Creating channel program with utility class
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        
        Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New ', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account acc1 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 1', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelAccount.Id, true);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New check group limit', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelAccount.Id, true);
        
    }
    
    
}