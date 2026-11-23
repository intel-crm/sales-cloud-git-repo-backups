public without sharing class ACM_SalesCRM_CPEManagement {
    @InvocableMethod
    public static void cpeManagement(List<Id> ids){
        List<Account_Business_Types__c> acctBusinessTypeToInsert=new List<Account_Business_Types__c>();
        List<Account> accounts=[Select Id, Name From Account Where Id IN : ids];
        List<Business_Types__c> businessTypes = [
            Select Id,Business_Type_Code__c, Name 
            from Business_Types__c 
            where Is_Active__c = true AND Business_Type_Code__c='SLS_CRM'
        ];
        for(Account account : accounts){
            Account_Business_Types__c accountBusinessType=new Account_Business_Types__c();
            accountBusinessType.Account__c=account.Id;
            accountBusinessType.Business_Types__c=businessTypes[0].Id;
            accountBusinessType.Effective_Start_Date__c = System.today();
            acctBusinessTypeToInsert.add(accountBusinessType);
        }
        if(!acctBusinessTypeToInsert.isEmpty()){
            insert acctBusinessTypeToInsert;
        }
    }
}