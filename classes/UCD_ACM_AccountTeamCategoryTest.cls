@IsTest
public with sharing class UCD_ACM_AccountTeamCategoryTest {
    
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
        Account acc = [Select Id,Name,ParentId,Parent.Name,Core_Customer_Aggregation_Type__c from Account where Name = 'TestParentAccount'];
        UCD_ACM_AccountTeamCategory.getAccountCategory(acc.Id);
        Assert.isNotNull(acc , 'failed');

    }
}