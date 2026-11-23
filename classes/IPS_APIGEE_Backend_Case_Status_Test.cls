/*********************************************
* Name : IPS_APIGEE_Backend_Case_Status_Test 
* Author : Karthik Bandla
* Date Created : 23/09/2021
* Description : Test class for IPS_APIGEE_Backend_Case_Status_Update.
*   
************************************************/
@isTest
public class IPS_APIGEE_Backend_Case_Status_Test {
    
    @testSetup
    static void testData() {
        
        Account caseContactAccount = TestUtilities.getAccountRecord();
        caseContactAccount.Name = 'Test Sony Products';
        insert caseContactAccount;
        System.assert(caseContactAccount.Id != null, 'Record not created');

        Contact caseContact = new Contact();
        caseContact.FirstName = 'Test';
        caseContact.LastName = 'Contact1';
        caseContact.Email = 'testemail@email.com';
        caseContact.Core_Enterprise_Id__c = '88899';
        caseContact.AccountId = caseContactAccount.Id;
        caseContact.MailingCountry='India';
        insert caseContact;
		System.assert(caseContact.Id != null, 'Record not created');
        
        
        Product2 prod = new Product2();
        prod.Name = 'Purley';
        prod.Core_Sales_Visible_Flag__c = false;
        prod.Core_IPS_Visible_Flag_External__c = true;
        prod.Core_IPS_Visible_Flag_Internal__c = 'Yes';
        prod.IsActive = true;
        prod.Core_Product_Org__c = 'IPS';//@@New Validation Rule!!!
        insert prod;
        System.assert(prod.Id != null, 'Record not created');

        Core_IPS_Backend_System__c backendSystem = new Core_IPS_Backend_System__c();
        backendSystem.Name = 'Test Backend System';
        backendSystem.Core_IPS_Backend_Connection_String__c = 'Test Backend Connection';
        backendSystem.Core_IPS_Cloud_Internal_URL__c ='Test.org.com';
        backendSystem.Core_IPS_Deactivated__c = false;
        insert backendSystem;
        System.assert(backendSystem.Id != null, 'Record not created');

        Core_IPS_System_Credentails_Apigee__c label17 = new Core_IPS_System_Credentails_Apigee__c();
        label17.Name = 'Core_IPS_Case_Promote';
        label17.Core_IPS_EndPointURL__c = 'Test.org1.com';
        insert label17;
        System.assert(label17.Id != null, 'Record not created');

        Core_IPS_System_Credentails_Apigee__c label18 = new Core_IPS_System_Credentails_Apigee__c();
        label18.Name = 'Core_IPS_Case_DePromote';
        label18.Core_IPS_EndPointURL__c = 'Test.org2.com';
        insert label18;
        System.assert(label18.Id != null, 'Record not created');
        Core_IPS_System_Credentails_Apigee__c label19 = new Core_IPS_System_Credentails_Apigee__c();
        label19.Name = 'Core_IPS_Case_FieldUpdate';
        label19.Core_IPS_EndPointURL__c = 'Test.org3.com';
        insert label19;
        System.assert(label19.Id != null, 'Record not created');
        Core_IPS_System_Credentails_Apigee__c label20 = new Core_IPS_System_Credentails_Apigee__c();
        label20.Name = 'Core_IPS_CaseComment_Update';
        label20.Core_IPS_EndPointURL__c = 'Test.org.com';
        insert label20;
        System.assert(label20.Id != null, 'Record not created');
    }
    
    @isTest
    static void test1() {
        Account caseContactAccount = [SELECT Id FROM Account WHERE Name = 'Test Sony Products'];
        Contact caseContact = [SELECT Id FROM Contact WHERE Email = 'testemail@email.com'];
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Purley'];
        Core_IPS_Backend_System__c backendSystem = [SELECT Id FROM Core_IPS_Backend_System__c WHERE Name = 'Test Backend System'];
        Case caseRecord = new Case();
        caseRecord.Subject = 'Test Subject';
        caseRecord.ProductId = prod.Id;
        caseRecord.Status = 'Open';
        caseRecord.CreatedDate = DateTime.parse(System.Now().format());
        caseRecord.LastModifiedDate = DateTime.parse(System.Now().format());
        caseRecord.AccountId = caseContactAccount.Id;
        caseRecord.ContactId = caseContact.Id;
        caseRecord.Core_CaseType__c = 'Debug Request';
        caseRecord.Core_IPS_Customer_Visible__c = true;
        caseRecord.Core_IPS_Backend_ID__c = '-1';
        caseRecord.Core_IPS_Backend_Previous_Status__c = 'Test Previous Status';
        caseRecord.Core_IPS_Backend_System__c = backendSystem.Id;
        caseRecord.Core_IPS_Backend_Previous_Status__c = 'disassociate';
        insert caseRecord;
        System.assert(caseRecord.Id != null, 'Record not created');
        Test.setMock(HttpCalloutMock.class, new IPS_APIGEE_BackendHttpCalloutMock());
        Test.startTest();
        caseRecord.Core_IPS_Backend_Previous_Status__c = 'Test Previous';
        update caseRecord; 
        Test.stopTest();
    }
    
}