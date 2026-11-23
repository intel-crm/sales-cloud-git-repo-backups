@isTest
public class ACM_BU_AssignParentToIntelAccount_Test {
   
    private static UCD_ACM_ServiceContracts.IBeforeUpdateAccountTrigger accountServiceInstance = new ACM_BU_AssignParentToIntelAccount();

    @TestSetup
    private static void setCommonData(){

        Account account1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('IntelParent1','Intel Account','UNFD_GLBL_CUST');
        account1.Core_Account_Reference_Source_Name__c = 'Opportunity Management' ;
        account1.Core_MDM_Status__c = 'APRV';
        account1.Core_Business_Party_Id__c = '12345678';
        insert account1;

        Account account2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('IntelChild1','Intel Account','UNFD_CTRY_CUST');
        account2.Core_Account_Reference_Source_Name__c = 'Opportunity Management' ;
        account2.Core_MDM_Status__c = 'APRV';
        account2.Core_Business_Party_Id__c = '1234';
        //account2.ParentId = account1.Id;
        insert account2;

        Account account3 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('IntelChild2','Intel Account','UNFD_CTRY_CUST');
        account3.Core_Account_Reference_Source_Name__c = 'Opportunity Management' ;
        account3.Core_MDM_Status__c = 'APRV';
        account3.Core_Business_Party_Id__c = '12345';
        //account2.ParentId = account1.Id;
        insert account3;


        Account dealAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('ECDChild1','End Customer Deal Account','UNFD_CTRY_CUST');
        dealAccount.Core_Account_Reference_Source_Name__c = 'IQR' ;
        //dealAccount.ParentId = account1.Id;
        insert dealAccount;

        Account InactiveAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('InactiveAccount1','Inactive Account','UNFD_CTRY_CUST');
        //InactiveAccount.ParentId = account1.Id;
        insert InactiveAccount;

    }

    @isTest
    private static void setParentForIntelAccountException(){
        List<Account> oldAccounts = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where (Name = 'IntelChild1')];

        List<Account> childAccounts = [Select Id,Core_Business_Party_Id__c, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where (Name = 'IntelChild1' )];
        childAccounts[0].Core_Parent_Business_Party_Id__c = '12345678';

        List<Account> newAccounts = new List<Account>();
        newAccounts.addAll(childAccounts);
		
        Test.startTest();
        	accountServiceInstance.execute(new Map<Id,Account>(oldAccounts), new Map<Id,Account>(newAccounts));
        Test.stopTest();        
    }


    @isTest
    private static void setParentForOneChildIntelAccount(){

        List<Account> oldAccounts = [Select Id,Core_Business_Party_Id__c, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where (Name = 'IntelChild1')];

        List<Account> childAccounts = [Select Id,Core_Business_Party_Id__c, ParentId, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where (Name = 'IntelChild1' )];
        childAccounts[0].Core_Parent_Business_Party_Id__c = '12345678';

        List<Account> newAccounts = new List<Account>();
        newAccounts.addAll(childAccounts);
        
        Test.startTest();
        	accountServiceInstance.execute(new Map<Id,Account>(oldAccounts), new Map<Id,Account>(newAccounts));
           // accountServiceInstance.execute(new Map<Id,Account>(oldAccounts), new Map<Id,Account>(newAccounts));
        Test.stopTest();
        
        List<Account> parentAccount = [SELECT Id FROM Account WHERE Name = 'IntelParent1'];
        System.assertEquals(parentAccount[0].Id, childAccounts[0].ParentId, 'Parent assignment is not correct.');
        
    }

    
    @isTest
    private static void setParentForOneChildDealAccount(){
        List<Account> oldAccounts = [Select Id,Core_Business_Party_Id__c, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where (Name = 'ECDChild1')];

        List<Account> childAccounts = [Select Id,Core_Business_Party_Id__c, ParentId, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where (Name = 'ECDChild1' )];
        childAccounts[0].Core_Parent_Business_Party_Id__c = '12345678';

        List<Account> newAccounts = new List<Account>();
        newAccounts.addAll(childAccounts);

        Test.startTest();
        	accountServiceInstance.execute(new Map<Id,Account>(oldAccounts), new Map<Id,Account>(newAccounts));
        Test.stopTest();

        System.assertEquals(null, childAccounts[0].ParentId, 'Parent assignment is not correct.');
    }

    @isTest
    private static void setParentForBulkChilIntelAccount(){
        List<Account> oldAccounts = [Select Id,Core_Business_Party_Id__c, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where (Name = 'IntelChild1' Or Name = 'IntelChild2')];

        List<Account> childAccounts = [Select Id,Core_Business_Party_Id__c, ParentId, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where (Name = 'IntelChild1' or Name = 'IntelChild2')];
        childAccounts[0].Core_Parent_Business_Party_Id__c = '12345678';
        childAccounts[1].Core_Parent_Business_Party_Id__c = '12345678';

        List<Account> newAccounts = new List<Account>();
        newAccounts.addAll(childAccounts);
        
        Test.startTest();
        	accountServiceInstance.execute(new Map<Id,Account>(oldAccounts), new Map<Id,Account>(newAccounts));
        Test.stopTest();

        List<Account> parentAccount = [SELECT Id FROM Account WHERE Name = 'IntelParent1'];
        System.assertEquals(parentAccount[0].Id, childAccounts[0].ParentId, 'Parent assignment is not correct.');
        System.assertEquals(parentAccount[0].Id, childAccounts[1].ParentId, 'Parent assignment is not correct.');



    }

    @isTest
    private static void setParentForChildDealAndIntelAccount() {
        List<Account> oldAccounts = [Select Id,Core_Business_Party_Id__c, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where (Name = 'ECDChild1' Or Name = 'IntelChild2')];

        List<Account> ecdAccount = [Select Id,Core_Business_Party_Id__c, ParentId, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where (Name = 'ECDChild1')];
        ecdAccount[0].Core_Parent_Business_Party_Id__c = '12345678';

        List<Account> intelAccount = [Select Id,Core_Business_Party_Id__c, ParentId, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where (Name = 'IntelChild2')];
        intelAccount[0].Core_Parent_Business_Party_Id__c = '12345678';

        List<Account> newAccounts = new List<Account>();
        newAccounts.addAll(ecdAccount);
        newAccounts.addAll(intelAccount);

        Test.startTest();
        	accountServiceInstance.execute(new Map<Id,Account>(oldAccounts), new Map<Id,Account>(newAccounts));
        Test.stopTest();

        List<Account> parentAccount = [SELECT Id FROM Account WHERE Name = 'IntelParent1'];
      //  System.assertEquals(parentAccount[0].Id, ecdAccount[0].ParentId, 'Parent assignment is not correct.');
      //  System.assertEquals(null, intelAccount[0].ParentId, 'Parent assignment is not correct.');
    }


    //Negative
  /*  @isTest
    private static void whenExecuteParentAssignmentIntelGlobalWithInactiveChild(){
        List<Account> finalAccountsForOld = new List<Account>();
        List<Account> finalAccountsForNew = new List<Account>();


        List<Account> parentIntelAccount1New = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where Name = 'IntelParent1' ];
        parentIntelAccount1New[0].Core_Business_Party_Id__c = '123456';
        finalAccountsForNew.addAll(parentIntelAccount1New);

        List<Account> InactiveAccountNew = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where Name = 'InactiveAccount1' ];
        InactiveAccountNew[0].Core_Business_Party_Id__c = '123456';
        finalAccountsForNew.addAll(InactiveAccountNew);


        List<Account> parentIntelAccount1Old = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where Name = 'IntelParent1' ];
        finalAccountsForOld.addAll(parentIntelAccount1New);
        List<Account> InactiveAccountOld = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where Name = 'InactiveAccount1' ];
        finalAccountsForOld.addAll(InactiveAccountOld);


        Test.startTest();
        accountServiceInstance.execute(new Map<Id,Account>(finalAccountsForOld) ,new Map<Id,Account>(finalAccountsForNew));
        Test.stopTest();

    }*/

    /*
    @isTest
    private static void whenExecuteParentAssignmentIntelGlobalWithInactiveChild(){
        accountServiceInstance.execute(new Map<Id,Account>(childAccount) ,new Map<Id,Account>(finalAccounts));

    }*/
}