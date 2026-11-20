@IsTest
public with sharing class ACM_AI_createAccountTeamTest {
    
    private static UCD_ACM_ServiceContracts.IAfterInsertAccountTrigger accountServiceInstance = new ACM_AI_createAccountTeam();


    @TestSetup
    private static void setCommonData(){
        Account parentAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        parentAccount.Core_Business_Party_Id__c = '12345' ;
        parentAccount.Core_Account_Primary_Coverage__c = System.Label.Intel_Covered;
        parentAccount.Core_Account_Category__c = 'Regional Co-Sell Partners';
        insert parentAccount;

        AccountTeamMember accTeamMember = new AccountTeamMember();
        accTeamMember.AccountId = parentAccount.Id ;
        accTeamMember.Core_Account_Category__c = 'Distributors (IA)' ;
        accTeamMember.UserId = UserInfo.getUserId();
        insert accTeamMember;

    }

    @isTest
    private static void whenGetAccounts(){
        UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
        

        List<Account> parentAccounts = [Select Id,Core_Business_Party_Id__c, ParentId, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c,OwnerId,Core_Account_Category__c from account where (Name = 'TestParentAccount' )];

        List<Account> oldParentAccounts = [Select Id,Core_Business_Party_Id__c, ParentId, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c,OwnerId,Core_Account_Category__c from account where (Name = 'TestParentAccount' )];


        Test.startTest();
          accountServiceInstance.execute(unitWork, new Map<Id,Account>(parentAccounts), new Map<Id,Account>(oldParentAccounts));
        Test.stopTest();

        List<AccountTeamMember> lstAccountTeam = [Select id from AccountTeamMember] ;
        Assert.isTrue( lstAccountTeam.size() > 0, 'Failed');

    }

}