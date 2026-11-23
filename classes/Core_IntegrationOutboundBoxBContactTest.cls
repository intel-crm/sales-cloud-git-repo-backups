@isTest
private class Core_IntegrationOutboundBoxBContactTest {
    private static testmethod void testIntegrationOutboundBoxBContact() {
    Contact testContact = createTestContact();
        Test.startTest();
        Core_IntegrationOutboundBoxBContact.CreateOutboundMessae(New Id[]{testContact.Id});
        integer iCountMsg = 1;
        
        List<Core_Integration_Outbound_Message__c> outboundMsgs = [
            select Id from Core_Integration_Outbound_Message__c where Core_MessageType__c = 'Box B Contact'];
            if (outboundMsgs.size()<=1)
            System.assertEquals(iCountMsg, outboundMsgs.size());
            else
            {
        
            //Updating contact English only Last Name
            testContact.Core_English_Only_Last_Name__c ='Person API2';
            update testContact;
            //Core_IntegrationOutboundBoxBContact.CreateOutboundMessae(New Id[]{testContact.Id});
            
            // Make sure an outbound message was generated, for Box B
           outboundMsgs = [
            select Id from Core_Integration_Outbound_Message__c where Core_MessageType__c = 'Box B Contact'];
            System.assertEquals(3, outboundMsgs.size());
          
            //Updating Contact Phone
            testContact.Phone='9934501235';
            update testContact;
            outboundMsgs = [
            select Id from Core_Integration_Outbound_Message__c where Core_MessageType__c = 'Box B Contact'];
            System.assertEquals(4, outboundMsgs.size());
            
            //Updating Contact LastName
            testContact.LastName='person';
            update testContact;
            outboundMsgs = [
            select Id from Core_Integration_Outbound_Message__c where Core_MessageType__c = 'Box B Contact'];
            System.assertEquals(5, outboundMsgs.size());
            
            //Updating Contact Email 
            testContact.Email='OIAPITester123@test.com';
            update testContact;
            outboundMsgs = [
            select Id from Core_Integration_Outbound_Message__c where Core_MessageType__c = 'Box B Contact'];
            System.assertEquals(6, outboundMsgs.size());
            
            //Updating Contact Enterprise Id 
            testContact.Core_Enterprise_Id__c='412374';
            update testContact;
            outboundMsgs = [
            select Id from Core_Integration_Outbound_Message__c where Core_MessageType__c = 'Box B Contact'];
            System.assertEquals(7, outboundMsgs.size());
            
        }
        Test.stopTest();
    }
    private static Contact createTestContact() {
        
        Contact conObj = new Contact();
        Account acctObj = createTestAccount();
        conObj.Core_eRPM_Person_Id__c = '3111111';
        conObj.Core_Enterprise_Id__c = '4123456';
        conObj.Core_Login_Id__c = '412355';
        conObj.FirstName = 'Outbound Integrations Tester API';
        conObj.LastName = 'Person API';
        conObj.Email = 'OIAPITester123@tester.com';
        conObj.Core_English_Only_First_Name__c = 'Outbound Integrations Tester API';
        conObj.Core_English_Only_Last_Name__c = 'Person API';
        conObj.Core_Do_Not_Contact__c = false;
        conObj.Salutation = 'Mr.';
        conObj.Title = 'API OBM Tester';
        conObj.Core_Job_Function__c = 'Information Technology';
        conObj.MailingStreet = '41234 APITester St';
        conObj.MailingCity = 'APITesting City';
        conObj.MailingStateCode = 'CA';
        conObj.MailingCountryCode = 'USA';
        conObj.MailingPostalCode = '42345';
        conObj.Phone = '9934501234';
        conObj.MobilePhone = '';
        conObj.Core_Contact_B2B_Indicator__c= true;
        conObj.AccountId = acctObj.Id;
        
        insert conObj;
        
        return conObj;
    }
    private static Account createTestAccount() {
        
        Account acctObj = new Account();
        acctObj.Name = 'Outbound Test Account';
        acctObj.Core_CNDA_Number__c = '112233445566';
        acctObj.BillingStreet = '1234 Tester Account';
        acctObj.BillingCity = 'Testing City';
        acctObj.BillingStateCode = 'OR';
        acctObj.BillingCountryCode = 'USA';
        acctObj.BillingPostalCode = '12345';
        acctObj.Phone = '1234567890';
        acctObj.Core_Account_Legal_Name__c = 'Outbound Test Account';
        acctObj.Core_IsODM__c = false;
        acctObj.Core_B2B_ERPM_Account_Number__c = 'ERPM1234';
        acctObj.Core_English_Only_Name__c = 'Outbound Test Account';
        acctObj.Core_Alternate_Language_Name__c = 'Alternate Name Account';
        
        insert acctObj;
        
        return acctObj;
    }
}