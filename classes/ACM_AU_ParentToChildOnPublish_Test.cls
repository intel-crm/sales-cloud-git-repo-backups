@isTest
public class ACM_AU_ParentToChildOnPublish_Test {
    private static UCD_ACM_ServiceContracts.IAfterUpdateAccountTrigger accountServiceInstance = new ACM_AU_ParentToChildOnPublish();
    private static UCD_ACM_SelectorContracts.IUnitOfWork unitWork = new UCD_ACM_UnitOfWork();
    @TestSetup
    private static void setCommonData(){

        Account account1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('IntelParentAcct','Intel Account','UNFD_GLBL_CUST');
        account1.Core_Business_Party_Id__c = '112459';
        account1.Core_MDM_Status__c = 'APRV';
        account1.Core_Account_Reference_Source_Name__c = 'Opportunity Management' ;
        insert account1;

        Account account2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('IntelChildAcct','Intel Account','UNFD_CTRY_CUST');
        account2.Core_Business_Party_Id__c = '1235980';
        account2.Core_MDM_Status__c = 'APRV';
        account2.Core_Account_Reference_Source_Name__c = 'Opportunity Management' ;
        account2.Core_Parent_Business_Party_Id__c ='112459';
        insert account2;
    }
    @isTest
    private static void setParentForIntelChildAccount(){
        UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();

        List<Account> parentAccounts = [Select Id,Core_Business_Party_Id__c, ParentId, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where (Name = 'IntelParentAcct' )];

        List<Account> oldParentAccounts = [Select Id,Core_Business_Party_Id__c, ParentId, Core_Parent_Business_Party_Id__c, RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c from account where (Name = 'IntelParentAcct' )];
        oldParentAccounts[0].Core_Business_Party_Id__c='12578';

        List<Account> parentnewAccounts = new List<Account>();
        parentnewAccounts.addAll(parentAccounts);

        List<Account> parentoldAccounts = new List<Account>();
        parentoldAccounts.addAll(oldParentAccounts);
        
        Test.startTest();
        	accountServiceInstance.execute(unitWork, new Map<Id,Account>(parentoldAccounts), new Map<Id,Account>(parentnewAccounts));
        Test.stopTest();
        
        //List<Account> childAccount = [SELECT Id, ParentId FROM Account WHERE Name = 'IntelChildAcct'];
        //System.assertEquals(childAccount[0].ParentId,parentAccounts[0].Id,'Success');
    }
}