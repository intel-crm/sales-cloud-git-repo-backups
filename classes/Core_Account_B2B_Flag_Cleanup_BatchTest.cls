/**************************************************************************************
Apex Class Name : Core_Account_B2B_Flag_Cleanup_BatchTest 
Created Date: 4th Oct 2024
Description : Test class to check Account B2B Flag removal functionality
*************************************************************************************/
@isTest
public class Core_Account_B2B_Flag_Cleanup_BatchTest {
    @isTest
    public static void testBatchExecution() {
        // test account with contact B2B flag true
        Account acctObj = new Account();
        acctObj.Name = 'Test Account acc1';
        acctObj.Core_CNDA_Number__c = '102233';
        acctObj.BillingStreet = '1221 Test Account123456';
        acctObj.BillingCity = 'Testing City cty';
        acctObj.BillingStateCode = 'OR';
        acctObj.BillingCountryCode = 'USA';
        acctObj.BillingPostalCode = '120000';
        acctObj.ShippingStreet = 'Yemen';
        acctObj.ShippingCity = 'Testing City cty';
        acctObj.ShippingStateCode = 'OR';
        acctObj.ShippingCountryCode = 'USA';
        acctObj.ShippingPostalCode = '120000';
        acctObj.Core_CIM_ID__c = '1234567890';
        acctObj.Core_B2B_Entitlement__c = true;
        insert acctObj;
        
        Contact conObj = new Contact();
        conObj.AccountId = acctObj.Id;
        conObj.FirstName = 'B2BFlag';
        conObj.LastName = 'Test Con1';
        conObj.MailingCountry='USA';
        conObj.Email = 'b2bflagtestcon1@tester.com';
        conObj.Core_English_Only_First_Name__c = 'B2BFlag';
        conObj.Core_English_Only_Last_Name__c = 'Test Con1';
        conObj.MailingStreet = 'Test St';
        conObj.MailingCity = 'Testmailingcity';
        conObj.MailingStateCode = 'OR';
        conObj.MailingCountryCode = 'USA';
        conObj.MailingPostalCode = '101458';
        conObj.Core_Contact_B2B_Indicator__c = true;
        conObj.Phone = '35768965';
        insert conObj;    
             
        //test account with contact B2B flag false
        Account acctObj1 = new Account();
        acctObj1.Name = 'Test Account acc2';
        acctObj1.Core_CNDA_Number__c = '87610';
        acctObj1.BillingStreet = '8679 Test Account2567';
        acctObj1.BillingCity = 'Testing City NY';
        acctObj1.BillingStateCode = 'OR';
        acctObj1.BillingCountryCode = 'USA';
        acctObj1.BillingPostalCode = '12065';
        acctObj1.ShippingStreet = 'Sumter';
        acctObj1.ShippingCity = 'Testing City NY';
        acctObj1.ShippingStateCode = 'NY';
        acctObj1.ShippingCountryCode = 'USA';
        acctObj1.ShippingPostalCode = '12078';
        acctObj1.Core_CIM_ID__c = '658123';
        acctObj1.Core_B2B_Entitlement__c = true;
        insert acctObj1;
        
        Contact conObj1 = new Contact();
        conObj1.AccountId = acctObj1.Id;
        conObj1.FirstName = 'B2BFlag';
        conObj1.LastName = 'Test Con2';
        conObj1.MailingCountry='USA';
        conObj1.Email = 'b2bflagtestcon2@tester.com';
        conObj1.Core_English_Only_First_Name__c = 'B2BFlag';
        conObj1.Core_English_Only_Last_Name__c = 'Test Con2';
        conObj1.MailingStreet = 'Test St';
        conObj1.MailingCity = 'TestcityNY';
        conObj1.MailingStateCode = 'NY';
        conObj1.MailingCountryCode = 'USA';
        conObj1.MailingPostalCode = '101458';
        conObj1.Core_Contact_B2B_Indicator__c = false;
        conObj1.Phone = '35768965';
        insert conObj1;
        
        //test account with contact B2B flag true for one contact and false for other contact
        Account acctObj2 = new Account();
        acctObj2.Name = 'Test Account acc3';
        acctObj2.Core_CNDA_Number__c = '654370';
        acctObj2.BillingStreet = '9676 Test Account9676';
        acctObj2.BillingCity = 'Test City';
        acctObj2.BillingStateCode = 'OR';
        acctObj2.BillingCountryCode = 'USA';
        acctObj2.BillingPostalCode = '12065';
        acctObj2.ShippingStreet = 'Yemen';
        acctObj2.ShippingCity = 'Testing City OR';
        acctObj2.ShippingStateCode = 'OR';
        acctObj2.ShippingCountryCode = 'USA';
        acctObj2.ShippingPostalCode = '12078';
        acctObj2.Core_CIM_ID__c = '658123';
        acctObj2.Core_B2B_Entitlement__c = true;
        insert acctObj2;
        
        Contact conObj2 = new Contact();
        conObj2.AccountId = acctObj2.Id;
        conObj2.FirstName = 'B2BFlag';
        conObj2.LastName = 'Test Con3';
        conObj2.MailingCountry='USA';
        conObj2.Email = 'b2bflagtestcon3@tester.com';
        conObj2.Core_English_Only_First_Name__c = 'B2BFlag';
        conObj2.Core_English_Only_Last_Name__c = 'Test Con3';
        conObj2.MailingStreet = 'Test Main St';
        conObj2.MailingCity = 'TestcityTX';
        conObj2.MailingStateCode = 'NY';
        conObj2.MailingCountryCode = 'USA';
        conObj2.MailingPostalCode = '76558';
        conObj2.Core_Contact_B2B_Indicator__c = false;
        conObj2.Phone = '65890';
        insert conObj2;
        
        
        Contact conObj3 = new Contact();
        conObj3.AccountId = acctObj2.Id;
        conObj3.FirstName = 'B2BFlag';
        conObj3.LastName = 'Test Con4';
        conObj3.MailingCountry='USA';
        conObj3.Email = 'b2bflagtestcon4@tester.com';
        conObj3.Core_English_Only_First_Name__c = 'B2BFlag';
        conObj3.Core_English_Only_Last_Name__c = 'Test Con4';
        conObj3.MailingStreet = 'Test Main St1';
        conObj3.MailingCity = 'TestcityOR';
        conObj3.MailingStateCode = 'OR';
        conObj3.MailingCountryCode = 'USA';
        conObj3.MailingPostalCode = '76558';
        conObj3.Core_Contact_B2B_Indicator__c = true;
        conObj3.Phone = '65890';
        insert conObj3;
        
        //test account with contact B2B flag false for associated contacts
        Account acctObj3 = new Account();
        acctObj3.Name = 'Test Account acc4';
        acctObj3.Core_CNDA_Number__c = '654370';
        acctObj3.BillingStreet = '9676 Test Account9676';
        acctObj3.BillingCity = 'Test City';
        acctObj3.BillingStateCode = 'OR';
        acctObj3.BillingCountryCode = 'USA';
        acctObj3.BillingPostalCode = '12065';
        acctObj3.ShippingStreet = 'Yemen';
        acctObj3.ShippingCity = 'Testing City OR';
        acctObj3.ShippingStateCode = 'OR';
        acctObj3.ShippingCountryCode = 'USA';
        acctObj3.ShippingPostalCode = '12078';
        acctObj3.Core_CIM_ID__c = '658123';
        acctObj3.Core_B2B_Entitlement__c = true;
        insert acctObj3;
        
        Contact conObj4 = new Contact();
        conObj4.AccountId = acctObj3.Id;
        conObj4.FirstName = 'B2BFlag';
        conObj4.LastName = 'Test Con5';
        conObj4.MailingCountry='USA';
        conObj4.Email = 'b2bflagtestcon5@tester.com';
        conObj4.Core_English_Only_First_Name__c = 'B2BFlag';
        conObj4.Core_English_Only_Last_Name__c = 'Test Con5';
        conObj4.MailingStreet = 'Test Main St2';
        conObj4.MailingCity = 'TestcityTX';
        conObj4.MailingStateCode = 'NY';
        conObj4.MailingCountryCode = 'USA';
        conObj4.MailingPostalCode = '76558';
        conObj4.Core_Contact_B2B_Indicator__c = false;
        conObj4.Phone = '565890';
        insert conObj4;
        
        Contact conObj5 = new Contact();
        conObj5.AccountId = acctObj3.Id;
        conObj5.FirstName = 'B2BFlag';
        conObj5.LastName = 'Test Con6';
        conObj5.MailingCountry='USA';
        conObj5.Email = 'b2bflagtestcon6@tester.com';
        conObj5.Core_English_Only_First_Name__c = 'B2BFlag';
        conObj5.Core_English_Only_Last_Name__c = 'Test Con6';
        conObj5.MailingStreet = 'Test Main St3';
        conObj5.MailingCity = 'TestcityTX';
        conObj5.MailingStateCode = 'NY';
        conObj5.MailingCountryCode = 'USA';
        conObj5.MailingPostalCode = '76558';
        conObj5.Core_Contact_B2B_Indicator__c = false;
        conObj5.Phone = '465890';
        insert conObj5;
        
        
        // Execute the batch
        Test.startTest();
        Core_Account_B2B_Flag_Cleanup_Batch batch = new Core_Account_B2B_Flag_Cleanup_Batch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Verify the results
        acctObj = [SELECT Id, Core_B2B_Entitlement__c FROM Account WHERE Id = :acctObj.Id];
        acctObj1 = [SELECT Id, Core_B2B_Entitlement__c FROM Account WHERE Id = :acctObj1.Id];
        acctObj2 = [SELECT Id, Core_B2B_Entitlement__c FROM Account WHERE Id = :acctObj2.Id];
        acctObj3 = [SELECT Id, Core_B2B_Entitlement__c FROM Account WHERE Id = :acctObj3.Id];

        // Assert the values
        System.assertEquals(true, acctObj.Core_B2B_Entitlement__c);
        System.assertEquals(false, acctObj1.Core_B2B_Entitlement__c);
        System.assertEquals(true, acctObj2.Core_B2B_Entitlement__c);
        System.assertEquals(false, acctObj3.Core_B2B_Entitlement__c);
    }
}