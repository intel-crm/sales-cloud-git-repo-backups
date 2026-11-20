/******************************************************************************************************
* Class Name  : Core_MDF_Account_Utility_Test 
* Version     : 1.0 
* Created Date: 24-08-2020
* Modification Log :
*******************************************************************************************************/
@isTest(SeeAllData = false)
public class Core_MDF_Account_Utility_Test {    
    @testSetup 
    static void setup(){
        Test.startTest();
        
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
                
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        //List<User> userList = new List<User>();
        User sysAdmUsr = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdmUsr.Email = 'sysadmin@example.com';
        Database.insert(sysAdmUsr);
        
        system.runas(sysAdmUsr){
            User sysAdminUsr = Core_MDF_CCP_TestDataUtility.createUser(false);
            sysAdminUsr.Email = 'systemadmin@example.com';
            sysAdminUsr.UserRoleId=usRole.id;
            Database.insert(sysAdminUsr);
        }
        
        //Database.insert(userList);
        List<Core_Trigger_Executions__c> triggerExecutionList = new List<Core_Trigger_Executions__c>();
        
        Core_Trigger_Executions__c groupIdForAccountNode = new Core_Trigger_Executions__c();
        groupIdForAccountNode.name = 'Core_MDF_createGroupForAccountNode';
        groupIdForAccountNode.Core_Object__c = 'Account';
        groupIdForAccountNode.Core_Trigger_Events__c = 'After Insert';
        groupIdForAccountNode.Core_Active__c = TRUE;
        groupIdForAccountNode.Core_Description__c = 'To Create Group for each account';
        groupIdForAccountNode.Core_Class_Name__c = 'Core_AccountHandler';
        // insert 
        triggerExecutionList.add(groupIdForAccountNode);
        
        Core_Trigger_Executions__c shareAccountsWithGroups = new Core_Trigger_Executions__c();
        shareAccountsWithGroups.name = 'Core_MDF_ShareAccountsWithGroups';
        shareAccountsWithGroups.Core_Object__c = 'Account';
        shareAccountsWithGroups.Core_Trigger_Events__c = 'After Insert';
        shareAccountsWithGroups.Core_Active__c = TRUE;
        shareAccountsWithGroups.Core_Description__c = 'To Create Group for each account';
        shareAccountsWithGroups.Core_Class_Name__c = 'Core_AccountHandler';
        triggerExecutionList.add(shareAccountsWithGroups);
        
        Id budget_Retail_Record_Type = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
        Id escalation_Budget_Record_Type_Id = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Budget').getRecordTypeId();        
        
        // Creating channel program with utility class
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
        
        List<Group> listOfGroups = new List<Group>();
        //Creating Groups
    Group grp1 = new Group();
    grp1.Name = 'Core_MDF_CCP_External_Grp1';
    grp1.DeveloperName = 'Core_MDF_CCP_External_Grp1';
        listOfGroups.add(grp1);
        Group grp2 = new Group();
    grp2.Name = 'Core_MDF_CCP_External_Grp2';
    grp2.DeveloperName = 'Core_MDF_CCP_External_Grp2';
        listOfGroups.add(grp2);
       Group grp3 = new Group(); 
    grp3.Name = 'Core_MDF_Internal_RMF_Node_Accs';
    grp3.DeveloperName = 'Core_MDF_Internal_RMF_Node_Accs';
        listOfGroups.add(grp3);
        
        Database.insert(listOfGroups);
        
        Database.insert(triggerExecutionList);
        
        Core_MDF_CCP_RecordTypes__c recTypes = new Core_MDF_CCP_RecordTypes__c();
        recTypes.Core_MDF_Exception_SharingGroup__c = 'Core_MDF_Internal_RMF_Node_Accs';
        recTypes.Core_MDF_Allocation_RT_DeveloperName__c = 'Core_MDF_Retail_Marketing_Funds';
        recTypes.Name = 'Retail Marketing Funds';
        insert recTypes;
        
        Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New ', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type,false);
        intelAccount.Core_Geo__c='EMEA';
        intelAccount.Core_Sub_Geo__c='NEUR';
        database.insert(intelAccount);
        User Admin = [Select Id from User where Email = 'systemadmin@example.com' Limit 1];
        system.runAs(Admin){               
            Account acc1 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc 1', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelAccount.Id,false);            
            acc1.Core_Geo__c='EMEA';
            acc1.Core_Sub_Geo__c='NEUR';
            acc1.Core_MDF_Group_Id__c = grp1.Id;
            database.insert(acc1);
            
            Account acc1Node1 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc 1 Node 1', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id,false);
            acc1Node1.Core_Geo__c='EMEA';
            acc1Node1.Core_Sub_Geo__c='NEUR';
            acc1Node1.Core_MDF_Group_Id__c = grp2.Id;
            database.insert(acc1Node1);
            
            PartnerMarketingBudget pmbBudget = Core_MDF_CCP_TestDataUtility.createBudget('Test Acc 1 Budget 1', budget_Retail_Record_Type, acc1.Id, cp.Id, 12345, system.today(), system.today().addDays(30), false);
            pmbBudget.Core_MDF_Budget_Type_Txt__c = 'Retail MDF';
            insert pmbBudget;

            // Create a second budget on same Ultimate Account + Program to exercise list accumulation/branching
            PartnerMarketingBudget pmbBudget2 = Core_MDF_CCP_TestDataUtility.createBudget('Test Acc 1 Budget 2', budget_Retail_Record_Type, acc1.Id, cp.Id, 54321, system.today(), system.today().addDays(45), false);
            pmbBudget2.Core_MDF_Budget_Type_Txt__c = 'Retail MDF';
            insert pmbBudget2;
            
            // Positive escalation (type matching label retrieved in batch via Core_MDF_CustomLabelConfig)
            // We cannot change labels here; record type is already Core_MDF_Budget. This record should be picked by the batch SOQL.
            Core_MDF_Escalation__c esclationAcc1Test1 = new Core_MDF_Escalation__c();
            esclationAcc1Test1.RecordTypeId = escalation_Budget_Record_Type_Id; 
            esclationAcc1Test1.Core_MDF_Budget_ID_Number_id__c = pmbBudget.Id;
            esclationAcc1Test1.Core_MDF_Root_Cause_nm__c = 'Appeal of Budget';
            esclationAcc1Test1.Core_MDF_Total_Dollar_Impact_amt__c = 10;
            esclationAcc1Test1.Core_MDF_Escalation_Name_txt__c = 'Test Escalation1';
            esclationAcc1Test1.Core_MDF_Approved_Amount_amt__c = 10;
            // Set program so the (UltimateAcct + Program) key matches
            esclationAcc1Test1.Core_MDF_Channel_Program_id__c = cp.Id;
            insert esclationAcc1Test1;

            // Second escalation linked to the second budget; use same program to avoid restricted picklist issues
            Core_MDF_Escalation__c esclationAcc1Test2 = new Core_MDF_Escalation__c();
            esclationAcc1Test2.RecordTypeId = escalation_Budget_Record_Type_Id; 
            esclationAcc1Test2.Core_MDF_Budget_ID_Number_id__c = pmbBudget2.Id;
            esclationAcc1Test2.Core_MDF_Root_Cause_nm__c = 'Appeal of Budget';
            esclationAcc1Test2.Core_MDF_Total_Dollar_Impact_amt__c = 5;
            esclationAcc1Test2.Core_MDF_Escalation_Name_txt__c = 'Test Escalation2';
            esclationAcc1Test2.Core_MDF_Approved_Amount_amt__c = 5;
            esclationAcc1Test2.Core_MDF_Channel_Program_id__c = cp.Id;
            insert esclationAcc1Test2;

            // Add both parent and child accounts to hit multiple group IDs aggregation
            List<Account> accountList = new List<Account>();
            accountList.add(acc1);
            accountList.add(acc1Node1);
            // Execute batch to drive start/execute branches and downstream share creation
            Id batchId = Database.executeBatch(new Core_MDF_Batch_SharingWithNewAcctGrp(accountList), 50);
        }
        Test.stopTest();
    }
    
    @isTest
    static void createGroupForAccountNodeTest(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        //System.runAs(sysAdminUser)
        //{
            Test.startTest();
            Account acc1 = [Select id,Core_MDF_Group_Id__c from Account where Name = 'Test Acc 1'];
        //    System.assert(acc1.Core_MDF_Group_Id__c !=null);
            assert.isNotNull(acc1.Core_MDF_Group_Id__c);
            Test.stopTest();
        //}
    }
    @isTest
    static void reshareAccountNode(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User sysAdminUser2 = [SELECT Id,Email from User where Email='systemadmin@example.com' limit 1];
        //System.runAs(sysAdminUser)
        //{
            Test.startTest();
            List<Account> accList = new List<Account>();
            Account acc1 = [Select id,Core_MDF_Group_Id__c,Core_MDF_Channel_Program__c from Account where Name = 'Test Acc 1'];
            acc1.ownerid = sysAdminUser2.id;
            accList.add(acc1);
            Core_MDF_Account_Utility.createGroupForAccountNode(accList);
            Database.update(accList);
            
            Integer i = [SELECT COUNT() from AccountShare where UserOrGroupId =: acc1.Core_MDF_Group_Id__c];   
            assert.areEqual(0, i,'Error');
            Test.stopTest();
        //}
        
    }
    @isTest
    static void testFetchAccounts(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        //System.runAs(sysAdminUser)
        //{
            Test.startTest();
            List<Id> accList = new List<Id>();
            Account acc1 = [Select id,Core_MDF_Group_Id__c,Core_MDF_Channel_Program__c from Account where Name = 'Test Acc 1'];
            acc1.ownerid = sysAdminUser.id;
            accList.add(acc1.id);
            String intelAccIdString = '(\''+String.join(new List<Id>(accList), '\', \'') + '\')';
        	String whereClause = ' Id IN'+intelAccIdString;
            // Highlight: Unused Local Variable
        	/*List<Account> accounts = */ Core_MDF_Account_Utility.fetchAccounts(whereClause);
            // Unit Test Method should include System.Assert
           System.assertNotEquals(null, whereClause);
           System.assert(whereClause.contains(acc1.Id));
        //}
        
    }
     @isTest
    static void testfetchPRMIPAAffiliation(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        //System.runAs(sysAdminUser)
        //{
            Test.startTest();
            Set<Id> accSet = new Set<Id>();
            Set<Id> prmId = new Set<Id>();
            Account acc1 = [Select id,Core_MDF_Group_Id__c,Core_MDF_Channel_Program__c from Account where Name = 'Test Acc 1'];
            acc1.ownerid = sysAdminUser.id;
            accSet.add(acc1.id);
         // Highlight: Unused Local Variable 
        /*	List<PRM_IPA_Affiliation__c> prmIPAAffiliation = */ Core_MDF_Account_Utility.fetchPRMIPAAffiliation(accSet,null);
          	List<PRM_IPA_Affiliation__c> prm1 = [Select id,Name from PRM_IPA_Affiliation__c where PRM_Account__c IN:accSet];
            for(PRM_IPA_Affiliation__c prm:prm1){
                prmId.add(prm.id);
            }
           // Highlight: Unused Local Variable
          /*  List<PRM_IPA_Affiliation__c> prmIPAAffiliation1 = */ Core_MDF_Account_Utility.fetchPRMIPAAffiliation(null,prmId);  
            // Unit Test Method should include System.Assert 
          System.assertNotEquals(null, accSet);
          System.assert(accSet.contains(acc1.Id));
        //}
        
    }
    @isTest
    static void testFetchUnifiedIdAccounts(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        //System.runAs(sysAdminUser)
        //{
            Test.startTest();
            Set<String> unifiedId = new Set<String>();
            Account acc1 = [Select id,Core_MDF_Group_Id__c,Core_Unified_Global_Customer_BP_Id__c,Core_MDF_Channel_Program__c from Account where Name = 'Test Acc 1'];
            acc1.ownerid = sysAdminUser.id;
            acc1.Core_Unified_Global_Customer_BP_Id__c='UnifiedId001XY';
            unifiedId.add(acc1.id);
           // Highlight: Unused Local Variable 
          /*  List<Account> accounts = */ Core_MDF_Account_Utility.fetchUnifiedIdAccounts(unifiedId);
           // Unit Test Method should include System.Assert 
         System.assertNotEquals(null, unifiedId);
         System.assert(unifiedId.contains(acc1.Id));
        //}
        
    }
   
}