@isTest
private class QuoteExtControllerTests {
    
    testMethod static void testSubmit() {
        Account acc = PSG_Test_Utility.createDirectAccount();
        Account acc1 = new Account();
                acc1.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
                acc1.Name = 'Test Account'+System.now();
                acc1.Core_Account_Type__c = 'Distributor;End Customer';//added
                acc1.Industry = 'Banking';
                acc1.BillingCity = 'Texas';
                acc1.BillingCountry = 'USA';
                acc1.BillingStreet = 'G-2101'; 
                acc1.Core_Sales_Groups__c = 'CCG Sales Group'; 
                acc1.Core_Geo__c = 'APJ';
                acc1.Core_Sub_Geo__c = 'IJKK';
                acc1.Core_PSG_Account__c = true;
                acc1.Core_Account_Tier__c ='PSG-Tier 4';
                acc1.Core_Partner_Alliance_Program__c ='PSG Demand Creation - PSG';
                acc1.Core_Account_BU_Focus__c='PSG-CM;PSG-DISTI';
                acc1.Core_Direct_Pricing_Parent_Id__c=acc.id;
                acc1.Core_Direct_Legal_Parent_Id__c=acc.id;
                insert acc1;
        Contact cont = PSG_Test_Utility.createContact(acc1.Id);
        PSG_Test_Utility.CreatePriceBook('PSG Price Book');
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.RecordTypeId = PSG_Utility.getRecordTypeId('SBQQ__Quote__c', 'PSG_Quote_New');
                quote.SBQQ__Account__c = acc.id;
                quote.SBQQ__PrimaryContact__c = cont.Id;
                quote.core_cpq_revision_nbr__c =  1;
                quote.SBQQ__Status__c = 'In Review';
                quote.core_cpq_assigned_on__c = System.now();
                quote.core_cpq_quote_type_nm__c = 'Design Win';
                quote.core_cpq_end_customer_country_disty_nm__c = 'Taiwan';
                quote.core_cpq_active_cb__c = true;
                quote.SBQQ__Type__c='Quote';
               
                pricebook2 pb1 = [Select id from pricebook2 limit 1];
                quote.core_cpq_price_book_nm__c = pb1.Id;
        		List<User> lstUsers = PSG_Test_Utility.createSOSUser();
                quote.core_cpq_first_bm_approver__c = lstUsers[0].Id;
                quote.core_cpq_next_approver_nm__c = lstUsers[0].Id;
                quote.core_cpq_quote_type_nm__c = 'Design Win';
                quote.core_cpq_business_unit_nm__c = 'wireline';
        insert quote;
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onSubmit();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        con.goToRecord();
        System.assertEquals('Approved', quote.ApprovalStatus__c);
    }
    
    testMethod static void testRecall() {
        Account acc = PSG_Test_Utility.createDirectAccount();
        Account acc1 = new Account();
                acc1.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
                acc1.Name = 'Test Account'+System.now();
                acc1.Core_Account_Type__c = 'Distributor;End Customer';//added
                acc1.Industry = 'Banking';
                acc1.BillingCity = 'Texas';
                acc1.BillingCountry = 'USA';
                acc1.BillingStreet = 'G-2101'; 
                acc1.Core_Sales_Groups__c = 'CCG Sales Group'; 
                acc1.Core_Geo__c = 'APJ';
                acc1.Core_Sub_Geo__c = 'IJKK';
                acc1.Core_PSG_Account__c = true;
                acc1.Core_Account_Tier__c ='PSG-Tier 4';
                acc1.Core_Partner_Alliance_Program__c ='PSG Demand Creation - PSG';
                acc1.Core_Account_BU_Focus__c='PSG-CM;PSG-DISTI';
                acc1.Core_Direct_Pricing_Parent_Id__c=acc.id;
                acc1.Core_Direct_Legal_Parent_Id__c=acc.id;
                insert acc1;
        Contact cont = PSG_Test_Utility.createContact(acc1.Id);
        PSG_Test_Utility.CreatePriceBook('PSG Price Book');
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.RecordTypeId = PSG_Utility.getRecordTypeId('SBQQ__Quote__c', 'PSG_Quote_New');
                quote.SBQQ__Account__c = acc.id;
                quote.SBQQ__PrimaryContact__c = cont.Id;
                quote.core_cpq_revision_nbr__c =  1;
                quote.SBQQ__Status__c = 'In Review';
                quote.core_cpq_assigned_on__c = System.now();
                quote.core_cpq_quote_type_nm__c = 'Design Win';
                quote.core_cpq_end_customer_country_disty_nm__c = 'Taiwan';
                quote.core_cpq_active_cb__c = true;
                quote.SBQQ__Type__c='Quote';
               
                pricebook2 pb1 = [Select id from pricebook2 limit 1];
                quote.core_cpq_price_book_nm__c = pb1.Id;
        		List<User> lstUsers = PSG_Test_Utility.createSOSUser();
                quote.core_cpq_first_bm_approver__c = lstUsers[0].Id;
                quote.core_cpq_next_approver_nm__c = lstUsers[0].Id;
                quote.core_cpq_quote_type_nm__c = 'Design Win';
                quote.core_cpq_business_unit_nm__c = 'wireline';
        insert quote;
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onRecall();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        System.assertEquals('Recalled', quote.ApprovalStatus__c);
    }
}