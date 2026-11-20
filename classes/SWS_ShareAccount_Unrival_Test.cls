@isTest
public class SWS_ShareAccount_Unrival_Test {
 
    @testSetup 
    private static void setup(){
    User u = SWS_TestUtilty.createUser();
        Account acc = new Account();
        Account acc1 = new Account();
        System.runAs(u){ 
           
            acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
            acc.Name = 'Test AccountU'+ math.random();
            acc.Core_Account_Type__c = 'Distributor;End Customer';//added
            acc.Industry = 'Banking';
            acc.BillingCity = 'Texas';
            acc.BillingCountry = 'USA';
            acc.BillingStreet = 'G-2101'; 
            acc.Core_Sales_Groups__c = 'EMEA Sales Group'; 
            acc.Core_Geo__c = 'APJ';
            acc.Core_Sub_Geo__c = 'IJKK';
            acc.Core_PSG_Account__c = true;
            acc.Core_Account_Tier__c ='PSG-Tier 4';
            acc.Core_Partner_Alliance_Program__c ='PSG Demand Creation - PSG';
            acc.Core_Account_BU_Focus__c='PSG-CM;PSG-DISTI';
            acc.Industry = 'Arts';
            acc.Core_Is_Active__c = true;
            acc.Core_Account_Primary_Coverage__c = 'Intel Covered';
            acc.Core_Account_Category__c = 'Distributors (IA)';
            acc.Is_Shared_With_Unrival__c = false;
            insert acc;
            
            
            acc1.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
            acc1.Name = 'Test Account11'+ math.random();
            acc1.Core_Account_Type__c = 'Distributor;End Customer';//added
            acc1.Industry = 'Banking';
            acc1.BillingCity = 'Texas';
            acc1.BillingCountry = 'USA';
            acc1.BillingStreet = 'G-2101'; 
            acc1.Core_Sales_Groups__c = 'EMEA Sales Group'; 
            acc1.Core_Geo__c = 'APJ';
            acc1.Core_Sub_Geo__c = 'IJKK';
            acc1.Core_PSG_Account__c = true;
            acc1.Core_Account_Tier__c ='PSG-Tier 4';
            acc1.Core_Partner_Alliance_Program__c ='PSG Demand Creation - PSG';
            acc1.Core_Account_BU_Focus__c='PSG-CM;PSG-DISTI';
            acc1.Industry = 'Arts';
            acc1.Core_Is_Active__c = true;
            acc1.Core_Account_Primary_Coverage__c = 'Intel Covered';
            acc1.Core_Account_Category__c = 'Distributors (IA)';
            acc1.Is_Shared_With_Unrival__c = false;
            insert acc1;
        }
    }
   @isTest
    static void testShareAccount_Unrival_BothBranches() {
        Account acc = [SELECT Id, Is_Shared_With_Unrival__c FROM Account WHERE Name like '%Test AccountU%' limit 1];
        Account acc1 = [SELECT Id, Is_Shared_With_Unrival__c FROM Account WHERE Name like '%Test Account11%' limit 1];
        // Input that meets the "true" branch
        SWS_ShareAccount_Unrival.UnrivalAccounts input1 = new SWS_ShareAccount_Unrival.UnrivalAccounts();
        input1.accountId = acc.Id;
        input1.Shared_With_Unrival = 'false';
      

        // Input that meets the "false" branch
        SWS_ShareAccount_Unrival.UnrivalAccounts input2 = new SWS_ShareAccount_Unrival.UnrivalAccounts();
        input2.accountId = acc1.Id;
       input1.Shared_With_Unrival = 'true';

        List<SWS_ShareAccount_Unrival.UnrivalAccounts> inputs = new List<SWS_ShareAccount_Unrival.UnrivalAccounts>{input1, input2};

        Test.startTest();
        SWS_ShareAccount_Unrival.ShareAccount_Unrival(inputs);
        Test.stopTest();

        // Assert results
        Account updated1 = [SELECT Id, Is_Shared_With_Unrival__c FROM Account WHERE Id = :acc.Id];
        Account updated2 = [SELECT Id, Is_Shared_With_Unrival__c FROM Account WHERE Id = :acc1.Id];

        System.assertEquals(true, updated1.Is_Shared_With_Unrival__c, 'Account 1 should be shared');
        System.assertEquals(false, updated2.Is_Shared_With_Unrival__c, 'Account 2 should not be shared');
    }

    @isTest
    static void testShareAccount_Unrival_EmptyInput() {
        // Test with empty input list
        List<SWS_ShareAccount_Unrival.UnrivalAccounts> emptyInputs = new List<SWS_ShareAccount_Unrival.UnrivalAccounts>();
        Test.startTest();
        SWS_ShareAccount_Unrival.ShareAccount_Unrival(emptyInputs);
        Test.stopTest();
        // No exception should be thrown
        System.assert(true, 'No exception for empty input');
    }
}