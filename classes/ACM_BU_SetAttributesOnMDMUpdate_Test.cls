@isTest
public class ACM_BU_SetAttributesOnMDMUpdate_Test {
   
    private static UCD_ACM_ServiceContracts.IBeforeUpdateAccountTrigger accountServiceInstance = new ACM_BU_SetAttributesOnMDMUpdate();

    @TestSetup
    private static void setCommonData() {
        Account iAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account1','Intel Account','UNFD_GLBL_CUST');
        iAccount.Core_MDM_Status__c = 'APRV';
        iAccount.Core_Account_Reference_Source_Name__c = 'IQR' ;
        iAccount.Core_Data_Simplified_Account_Nm__c = 'test';
        insert iAccount;

        Account accountTestReq = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('AccountReq','Requested Account','UNFD_GLBL_CUST');
        iAccount.Core_MDM_Status__c = 'APRV';
        iAccount.Core_Account_Reference_Source_Name__c = 'Opportunity Management' ;
        iAccount.Core_Data_Simplified_Account_Nm__c = 'testAcct';
        insert accountTestReq;

        Account rejAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account2','Rejected Account','UNFD_CTRY_CUST');
        rejAccount.Core_MDM_Status__c = 'APRV';
        rejAccount.Core_Account_Reference_Source_Name__c = 'Opportunity Management' ;
        rejAccount.Core_Data_Simplified_Account_Nm__c = 'test';
        insert rejAccount;

        Account dealAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account3','End Customer Deal Account','UNFD_GLBL_CUST');
        dealAccount.Core_Business_Party_Id__c = '123456';
        dealAccount.Core_Account_Reference_Source_Name__c = '' ;
        dealAccount.Core_Data_Simplified_Account_Nm__c = 'test';
        insert dealAccount;
        
        Account intelAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account4','Intel Account','UNFD_GLBL_CUST');
        intelAccount.BillingCountryCode = 'IND';
        intelAccount.Core_Account_Reference_Source_Name__c = 'Opportunity Management';
        intelAccount.Core_Data_Simplified_Account_Nm__c = 'test';
        intelAccount.Core_MDM_Location_Country_Nm__c='India';
        insert intelAccount;

        /*Account addIntlAccount=UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('AccountTest5','Intel Account','UNFD_GLBL_CUST');
        addIntlAccount.Core_MDM_Location_Country_Nm__c='India';
        addIntlAccount.Core_Account_Reference_Source_Name__c = 'Opportunity Management';
        insert addIntlAccount;*/
        
        /*Account_Create_Process_Mapping__mdt metadatarec = new Account_Create_Process_Mapping__mdt();
        metadatarec.Set_MDM_Name__c = true;
        metadatarec.Core_Account_Reference_Source_Name__c = 'IQR';
        metadatarec.Customer_Process_Engagement_Name__c
        insert metadatarec;*/
        
       // List<Account_Create_Process_Mapping__mdt> metadatarecord = [select id,Customer_Process_Engagement_Name__c,Core_Account_Reference_Source_Name__c,Set_MDM_Name__c from Account_Create_Process_Mapping__mdt where Set_MDM_Name__c = true and Core_Account_Reference_Source_Name__c = 'IQR' limit 1];
        
        
    }

    @isTest
    private static void whenExecute() {
        List<Account> accountsBeforeUpdate = [Select Id,BillingCountryCode,Name,Core_MDM_Status__c,RecordTypeId,Core_Data_Simplified_Account_Nm__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c,Core_MDM_Location_Country_Nm__c,Core_MDM_Location_State_Nm__c,Core_Unified_Customer_Address__CountryCode__s,Core_Unified_Customer_Address__StateCode__s  from account where (Name IN ('Account1','Account2','Account3','AccountReq','Account4'))];
        
        List<Account> iAccount = [Select Id,BillingCountryCode,Core_Business_Party_Id__c,RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Geo__c,Core_Data_Simplified_Account_Nm__c,Core_Customer_Aggregation_Type__c,Core_MDM_Location_Country_Nm__c,Core_MDM_Location_State_Nm__c,Core_Unified_Customer_Address__CountryCode__s,Core_Unified_Customer_Address__StateCode__s from account where (Name = 'Account1' )];
        iAccount[0].Core_Data_Simplified_Account_Nm__c = 'Changed Name 1';
        iAccount[0].Core_Geo__c = 'APJ';

        List<Account> rejAccount = [Select Id,BillingCountryCode,Core_Business_Party_Id__c,RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Geo__c,Core_Data_Simplified_Account_Nm__c,Core_Customer_Aggregation_Type__c,Core_MDM_Location_Country_Nm__c,Core_MDM_Location_State_Nm__c,Core_Unified_Customer_Address__CountryCode__s,Core_Unified_Customer_Address__StateCode__s from account where (Name =  'Account2')];
        rejAccount[0].Core_Data_Simplified_Account_Nm__c = 'Changed Name 2';

        List<Account> dealAccount = [Select Id,BillingCountryCode,Core_Business_Party_Id__c,RecordTypeId,Core_MDM_Status__c,Core_Account_Reference_Source_Name__c,Core_Geo__c,Core_Data_Simplified_Account_Nm__c,Core_Customer_Aggregation_Type__c,Core_MDM_Location_Country_Nm__c,Core_MDM_Location_State_Nm__c,Core_Unified_Customer_Address__CountryCode__s,Core_Unified_Customer_Address__StateCode__s from account where (Name =  'Account3')];
        dealAccount[0].Core_Data_Simplified_Account_Nm__c = 'Changed Name 3';
        dealAccount[0].Core_Geo__c = 'APJ';
        
        List<Account> intelAccount = [Select Id,Core_Business_Party_Id__c,BillingCountryCode,Core_Geo__c,Core_Sub_Geo__c,RecordTypeId,Core_Data_Simplified_Account_Nm__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c,Core_MDM_Location_Country_Nm__c,Core_MDM_Location_State_Nm__c,Core_Unified_Customer_Address__CountryCode__s,Core_Unified_Customer_Address__StateCode__s  from account where (Name =  'Account4')];

        //List<Account> intlAcct=[Select Id,Core_Business_Party_Id__c,BillingCountryCode,Core_Geo__c,Core_Sub_Geo__c,RecordTypeId,Core_Data_Simplified_Account_Nm__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c,Core_MDM_Location_Country_Nm__c,Core_MDM_Location_State_Nm__c  from account where (Name =  'AccountTest5')];

        List<Account> requestedAccount = [Select Id,BillingCountryCode,Name,Core_MDM_Status__c,RecordTypeId,Core_Data_Simplified_Account_Nm__c,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c,Core_MDM_Location_Country_Nm__c,Core_MDM_Location_State_Nm__c,Core_Unified_Customer_Address__CountryCode__s,Core_Unified_Customer_Address__StateCode__s  from account where (Name = 'AccountReq')];

        List<Account> accountsAfterUpdate = new List<Account>();
        accountsAfterUpdate.addAll(iAccount);
        accountsAfterUpdate.addAll(rejAccount);
        accountsAfterUpdate.addAll(dealAccount);
        accountsAfterUpdate.addAll(intelAccount);
        accountsAfterUpdate.addAll(requestedAccount);
        accountServiceInstance.execute(new Map<Id, Account>(accountsBeforeUpdate), new Map<Id, Account>(accountsAfterUpdate));
        System.assertEquals('IND', intelAccount[0].BillingCountryCode,'Country Match');
    }
    
}