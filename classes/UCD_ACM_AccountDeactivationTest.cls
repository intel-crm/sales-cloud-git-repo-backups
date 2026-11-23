@isTest
public class UCD_ACM_AccountDeactivationTest {
    
    private static UCD_ACM_ServiceContracts.IAccountService accountServiceInstance = UCD_ACM_AccountService.getInstance();
    
     @TestSetup
    private static void setCommonData(){
        Id ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration'].Id;
        User us = UCD_ACM_Cntrlr_TestDataInitialization.createUser(ProfileId);
        insert us; 
        
        
        Account intelAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestIntelAccount','Intel Account','UNFD_GLBL_CUST');
        insert intelAccount;
        
        // Create Business Type
        List<Business_Types__c> businessTypes = new List<Business_Types__c>();
        businessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Sales CRM','SLS_CRM'));
        businessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Supply Demand Revenue','SD_REV'));
        insert businessTypes;
        
        // Create Account Business Type
        List<Account_Business_Types__c> accountBusinessTypes = new List<Account_Business_Types__c>();
        For(Business_Types__c businessType : businessTypes){
            accountBusinessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createAccountBusinessType(intelAccount.Id,businessType.Id));
        }
        insert accountBusinessTypes;
        
        // Create Compliance Watch List
        List<Core_Account_Compliance_Watch_List__c> complianceWatchLists = new List<Core_Account_Compliance_Watch_List__c>();
        complianceWatchLists.add(UCD_ACM_Cntrlr_TestDataInitialization.createComplianceWatchList(intelAccount.Id,'NOTRDOUT'));
        complianceWatchLists.add(UCD_ACM_Cntrlr_TestDataInitialization.createComplianceWatchList(intelAccount.Id,'DPL'));
        insert complianceWatchLists;

    	
    }
     @isTest
    private static void whenAccountDeactivated(){
        Map<Id,Account> accountById = new Map<Id,Account>([Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Data_Country_Cd__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet from Account where Name = 'TestIntelAccount']);
        Test.startTest();
        UCD_ACM_AccountDeactivation.removeUCDAttributes(accountById);
        Test.stopTest();
    }


}