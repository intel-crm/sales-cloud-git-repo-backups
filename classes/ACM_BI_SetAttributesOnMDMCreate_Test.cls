@isTest
public class ACM_BI_SetAttributesOnMDMCreate_Test {

    private static UCD_ACM_ServiceContracts.IBeforeInsertAccountTrigger accountServiceInstance = new ACM_BI_SetAttributesOnMDMCreate();

    @TestSetup
    private static void setCommonDataFunction() {
        Account account1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account1','Intel Account','UNFD_GLBL_CUST');
        account1.Core_MDM_Status__c='APRV';
        account1.Core_MDM_CPEs__c='DIR_PRC_EXCPT';
        insert account1;

        Account account2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account2','Intel Account','UNFD_GLBL_CUST');
        account2.Core_MDM_Status__c='APRV';
        insert account2;
        
        Account account4 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account4','Intel Account','UNFD_INTRMD_CUST');
        account4.Core_MDM_Status__c='REJ';
        insert account4;
        
        Account account3 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account3','Intel Account','UNFD_INTRMD_CUST');
        account3.Core_MDM_Status__c='APRV';
        account3.Core_MDM_CPEs__c='DIR_PRC_EXCPT';
        insert account3;        
    }

    @isTest
    private static void whensetAttributes() {
        List<Account> accounts = [Select Id,Core_MDM_Status__c,RecordTypeId from account where (Name IN ('Account1','Account2','Account3','Account4'))];
        List<Account> finalAccounts = new List<Account>();
        finalAccounts.addAll(accounts);
        accountServiceInstance.execute(new List<Account>(finalAccounts));
    }
}