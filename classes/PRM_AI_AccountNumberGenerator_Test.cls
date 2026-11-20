@IsTest
public class PRM_AI_AccountNumberGenerator_Test {
    private static UCD_ACM_ServiceContracts.IAfterInsertAccountTrigger AccountNumberInstance_AI = new PRM_AI_AccountNumberGenerator();

    @isTest
    public static void setCommonDataFunction() {
        Account account = new Account();
        account.Name='Account0';
        account.Industry='Agriculture';
        account.RecordTypeId=Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        account.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        account.Core_IPA_Partner_Role__c = 'Service Provider';
        account.Core_Account_Type__c='Cloud Service Provider (CSP)';
        account.BillingCity='Bengaluru';
        account.BillingCountry='India';
        account.BillingStreet='4th Floor,ITPL,Brookfield';
        account.BillingPostalCode='560037';
        insert account;

        Account account1 = new Account();
        account1.Name='Account1';
        account1.Industry='Agriculture';
        account1.RecordTypeId=Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        account1.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        account1.Core_IPA_Partner_Role__c = 'Service Provider';
        account1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        account1.BillingCity='Bengaluru';
        account1.BillingCountry='India';
        account1.BillingStreet='4th Floor,ITPL,Brookfield';
        account1.BillingPostalCode='560037';
        insert account1;
        
       Account account2 = new Account();
        account2.Name='Account2';
        account2.Industry='Agriculture';
        account2.AccountNumber='85378488';
        account2.RecordTypeId=Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        account2.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        account2.Core_IPA_Partner_Role__c = 'Service Provider';
        account2.Core_Account_Type__c='Cloud Service Provider (CSP)';
        account2.BillingCity='Bengaluru';
        account2.BillingCountry='India';
        account2.BillingStreet='4th Floor,ITPL,Brookfield';
        account2.BillingPostalCode='560037';
        insert account2;
        
        Account account3 = new Account();
        account3.Name='Account3';
        account3.Industry='Agriculture';
        account3.AccountNumber='85375488';
        account3.RecordTypeId=Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        account3.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        account3.Core_IPA_Partner_Role__c = 'Service Provider';
        account3.Core_Account_Type__c='Cloud Service Provider (CSP)';
        account3.BillingCity='Bengaluru';
        account3.BillingCountry='India';
        account3.BillingStreet='4th Floor,ITPL,Brookfield';
        account3.BillingPostalCode='560037';
        insert account3;
        
        UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork(); 
        map<id,Account> oldaccounts = new map<id,Account>();
        oldaccounts.put(account.id,account);
        oldaccounts.put(account1.id,account1);
        map<id,Account> newaccounts = new map<id,Account>();
        newaccounts.put(account2.id,account2);
        newaccounts.put(account3.id,account3);
        map<id,Account> newaccounts_emp = new map<id,Account>();
        AccountNumberInstance_AI.execute(unitwork,oldaccounts,newaccounts);
        AccountNumberInstance_AI.execute(unitwork,oldaccounts,newaccounts_emp);
    }

    @isTest
    private static void whenFunctionExecute() {
              
        /*[Select Id,Core_MDM_Status__c,RecordTypeId from account where (Name IN ('Account1','Account2','Account3','Account4'))];
        List<Account> finalAccounts = new List<Account>();
        finalAccounts.addAll(accounts);*/
        
    }

}