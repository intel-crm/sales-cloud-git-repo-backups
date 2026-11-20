@isTest 
public class UCD_ACM_DeactiavtedValidation_Test {
    private static UCD_ACM_ServiceContracts.IBeforeUpdateAccountTrigger accountServiceInstance = new UCD_ACM_DeactiavtedValidation();
    @TestSetup
    static void setCommonData(){

        Account account1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('IntelParent1','Intel Account','UNFD_GLBL_CUST');
        insert account1;

        Account account2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('IntelParent2','Intel Account','UNFD_GLBL_CUST');
        account2.ParentId = account1.Id;
        insert account2;
    }

    @isTest
    private static void setParentAccountcheckValidation(){
        List<Account> oldAccounts = [Select Id,Core_Deactivated__c,Core_Business_Party_Id__c,RecordTypeId,Core_Customer_Aggregation_Type__c from account where (Name = 'IntelParent1')];

        List<Account> childAccount = [Select Id,Core_Deactivated__c,Core_Business_Party_Id__c,RecordTypeId,Core_Customer_Aggregation_Type__c from account where (Name = 'IntelParent1')];
        childAccount[0].Core_Deactivated__c=true;

        List<Account> newAccounts= new List<Account>();
        newAccounts.addAll(childAccount);
        Test.startTest();
        	accountServiceInstance.execute(new Map<Id,Account>(oldAccounts), new Map<Id,Account>(newAccounts));
        Test.stopTest();
    }

}