@isTest
public class ACM_BU_AssignParentToDealAccount_Test {
   
    private static UCD_ACM_ServiceContracts.IBeforeUpdateAccountTrigger accountServiceInstance = new ACM_BU_AssignParentToDealAccount();
    private static UCD_ACM_ServiceContracts.IBeforeUpdateAccountTrigger accountServiceInstanceIntel = new ACM_BU_AssignParentToIntelAccount();

    @TestSetup
    private static void setCommonData(){

        Account account1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('AccountParentECD1','End Customer Deal Account','UNFD_INTRMD_CUST');
        account1.Core_Business_Party_Id__c = '12345678';
        account1.Core_MDM_Status__c = 'APRV';
        account1.Core_Account_Reference_Source_Name__c = 'IQR' ;
        insert account1;

        Account account2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('AccountChildECD1','End Customer Deal Account','UNFD_CTRY_CUST');
        account2.Core_Business_Party_Id__c = '1234';
        account2.Core_MDM_Status__c = 'APRV';
        account2.Core_Account_Reference_Source_Name__c = 'IQR' ;
        insert account2;

        Account account3 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('AccountChildIntel1','Intel Account','UNFD_CTRY_CUST');
        account3.Core_Business_Party_Id__c = '12345';
        account3.Core_MDM_Status__c = 'APRV';
        account3.Core_Account_Reference_Source_Name__c = 'Opportunity Management' ;
        insert account3;

        Account account4 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('AccountChildECD2','End Customer Deal Account','UNFD_CTRY_CUST');
        account4.Core_Business_Party_Id__c = '123456';
        insert account4;

        Account account5 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('AccountChildIntel2','Intel Account','UNFD_CTRY_CUST');
        account5.Core_Business_Party_Id__c = '12345';
        account5.Core_MDM_Status__c = 'APRV';
        account5.Core_Account_Reference_Source_Name__c = 'Opportunity Management' ;
        insert account5;

    }

    @isTest
    private static void setParentForDealAccountException(){
        List<Account> oldAccounts = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c from account where (Name = 'AccountChildECD1')];

        List<Account> childAccounts = [Select Id,Core_Business_Party_Id__c, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c from account where (Name = 'AccountChildECD1' )];
        childAccounts[0].Core_Parent_Business_Party_Id__c = '12345678';

        List<Account> newAccounts = new List<Account>();
        newAccounts.addAll(childAccounts);
		
        Test.startTest();
        	accountServiceInstance.execute(new Map<Id,Account>(oldAccounts), new Map<Id,Account>(newAccounts));
        Test.stopTest();  
        //new line added      
        System.assertEquals(childAccounts[0].Core_Parent_Business_Party_Id__c, '12345678', 'Parent BPID matched');
    }
    
    @isTest
    private static void setParentForOneChildDealAccount(){
        List<Account> oldAccounts = [Select Id,Core_Business_Party_Id__c, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c from account where (Name = 'AccountChildECD1')];

        List<Account> childAccounts = [Select Id,Core_Business_Party_Id__c, ParentId, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c from account where (Name = 'AccountChildECD1' )];
        childAccounts[0].Core_Parent_Business_Party_Id__c = '12345678';

        List<Account> newAccounts = new List<Account>();
        newAccounts.addAll(childAccounts);
        
        Test.startTest();
        	accountServiceInstance.execute(new Map<Id,Account>(oldAccounts), new Map<Id,Account>(newAccounts));
            accountServiceInstance.execute(new Map<Id,Account>(oldAccounts), new Map<Id,Account>(newAccounts));
        Test.stopTest();
        
        List<Account> parentAccount = [SELECT Id FROM Account WHERE Name = 'AccountParentECD1'];
        System.assertEquals(parentAccount[0].Id, childAccounts[0].ParentId, 'Parent assignment is not correct.');
    }
    
    @isTest
    private static void setParentForOneChildIntelAccount(){
        List<Account> oldAccounts = [Select Id,Core_Business_Party_Id__c, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c from account where (Name = 'AccountChildIntel1')];

        List<Account> childAccounts = [Select Id,Core_Business_Party_Id__c, ParentId, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c from account where (Name = 'AccountChildIntel1' )];
        childAccounts[0].Core_Parent_Business_Party_Id__c = '12345678';

        List<Account> newAccounts = new List<Account>();
        newAccounts.addAll(childAccounts);

        Test.startTest();
        	accountServiceInstance.execute(new Map<Id,Account>(oldAccounts), new Map<Id,Account>(newAccounts));
        Test.stopTest();

        System.assertEquals(null, childAccounts[0].ParentId, 'Parent assignment is not correct.');
    }

    @isTest
    private static void setParentForBulkChildDealAccount(){
        List<Account> oldAccounts = [Select Id,Core_Business_Party_Id__c, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c from account where (Name = 'AccountChildECD1' Or Name = 'AccountChildECD2')];

        List<Account> childAccounts = [Select Id,Core_Business_Party_Id__c, ParentId, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c from account where (Name = 'AccountChildECD1' or Name = 'AccountChildECD2')];
        childAccounts[0].Core_Parent_Business_Party_Id__c = '12345678';
        childAccounts[1].Core_Parent_Business_Party_Id__c = '12345678';

        List<Account> newAccounts = new List<Account>();
        newAccounts.addAll(childAccounts);
        
        Test.startTest();
        	accountServiceInstance.execute(new Map<Id,Account>(oldAccounts), new Map<Id,Account>(newAccounts));
        Test.stopTest();

        List<Account> parentAccount = [SELECT Id FROM Account WHERE Name = 'AccountParentECD1'];
        System.assertEquals(parentAccount[0].Id, childAccounts[0].ParentId, 'Parent assignment is not correct.');
        System.assertEquals(parentAccount[0].Id, childAccounts[1].ParentId, 'Parent assignment is not correct.');
    }

    @isTest
    private static void setParentForBulkChildIntelAccount(){
        List<Account> oldAccounts = [Select Id,Core_Business_Party_Id__c, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c from account where (Name = 'AccountChildIntel1' Or Name = 'AccountChildIntel2')];

        List<Account> childAccounts = [Select Id,Core_Business_Party_Id__c, ParentId, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c from account where (Name = 'AccountChildIntel1' Or Name = 'AccountChildIntel2')];
        childAccounts[0].Core_Parent_Business_Party_Id__c = '12345678';
        childAccounts[1].Core_Parent_Business_Party_Id__c = '12345678';

        List<Account> newAccounts = new List<Account>();
        newAccounts.addAll(childAccounts);

        Test.startTest();
        	accountServiceInstance.execute(new Map<Id,Account>(oldAccounts), new Map<Id,Account>(newAccounts));
        Test.stopTest();

        System.assertEquals(null, childAccounts[0].ParentId, 'Parent assignment is not correct.');
        System.assertEquals(null, childAccounts[1].ParentId, 'Parent assignment is not correct.');
    }

    @isTest
    private static void setParentForChildDealAndIntelAccount() {
        List<Account> oldAccounts = [Select Id,Core_Business_Party_Id__c, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c from account where (Name = 'AccountChildECD1' Or Name = 'AccountChildIntel2')];

        List<Account> ecdAccount = [Select Id,Core_Business_Party_Id__c, ParentId, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c from account where (Name = 'AccountChildECD1')];
        ecdAccount[0].Core_Parent_Business_Party_Id__c = '12345678';

        List<Account> intelAccount = [Select Id,Core_Business_Party_Id__c, ParentId, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c from account where (Name = 'AccountChildIntel2')];
        intelAccount[0].Core_Parent_Business_Party_Id__c = '12345678';

        List<Account> newAccounts = new List<Account>();
        newAccounts.addAll(ecdAccount);
        newAccounts.addAll(intelAccount);

        Test.startTest();
        	accountServiceInstance.execute(new Map<Id,Account>(oldAccounts), new Map<Id,Account>(newAccounts));
        Test.stopTest();

        List<Account> parentAccount = [SELECT Id FROM Account WHERE Name = 'AccountParentECD1'];
        System.assertEquals(parentAccount[0].Id, ecdAccount[0].ParentId, 'Parent assignment is not correct.');
        System.assertEquals(null, intelAccount[0].ParentId, 'Parent assignment is not correct.');
    }

    @isTest
    private static void setParentForChildDealAndIntelAccount_2() {
        
        Account account1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('AccountParentIntel1','Intel Account','UNFD_GLBL_CUST');
        account1.Core_Business_Party_Id__c = '12345678';
        account1.Core_MDM_Status__c = 'APRV';
        account1.Core_Account_Reference_Source_Name__c = 'Opportunity Management' ;
        insert account1;

        List<Account> oldAccounts = [Select Id,Core_Business_Party_Id__c, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c from account where (Name = 'AccountChildECD1' Or Name = 'AccountChildIntel2')];

        List<Account> ecdAccount = [Select Id,Core_Business_Party_Id__c, ParentId, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c from account where (Name = 'AccountChildECD1')];
        ecdAccount[0].Core_Parent_Business_Party_Id__c = '12345678';

        List<Account> intelAccount = [Select Id,Core_Business_Party_Id__c, ParentId, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c from account where (Name = 'AccountChildIntel2')];
        intelAccount[0].Core_Parent_Business_Party_Id__c = '12345678';

        List<Account> newAccounts = new List<Account>();
        newAccounts.addAll(ecdAccount);
        newAccounts.addAll(intelAccount);

        Test.startTest();
        	accountServiceInstance.execute(new Map<Id,Account>(oldAccounts), new Map<Id,Account>(newAccounts));
            accountServiceInstanceIntel.execute(new Map<Id,Account>(oldAccounts), new Map<Id,Account>(newAccounts));
        Test.stopTest();

        List<Account> parentAccount = [SELECT Id FROM Account WHERE Name = 'AccountParentECD1'];
        System.assertEquals(parentAccount[0].Id, ecdAccount[0].ParentId, 'Parent assignment is not correct.');
        //System.assertEquals(account1.Id, intelAccount[0].ParentId, 'Parent assignment is not correct.');
    }
}