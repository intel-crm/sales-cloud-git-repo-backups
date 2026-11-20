@isTest()
public class PRM_Email_Handler_UtilityTest {
    @isTest
    static void testduplicateRecordCheck(){
        Test.startTest();
        Id recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
         Account newAccount = new Account();//Account
        newAccount.Name='John Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        
        Contact contact = PRM_TestUtility.getContact();
        contact.Core_Enterprise_Id__c='300002199713';
        contact.Core_Preferred_Language__c='ENG';
        contact.RecordTypeId=recordTypeIdContact;          
        contact.Email='johnwood@asr.com';
        contact.FirstName = 'Vijay';
        contact.LastName = 'Darshan';
        contact.AccountId = newAccount.id;
        contact.MailingCountry='USA';
        contact.MailingCountryCode = 'USA';
        insert contact;
        
        PRM_Email_Handler__c emailHand = new PRM_Email_Handler__c();
        emailHand.PRM_Contact__c =contact.Id;
        emailHand.PRM_Event__c = 'Admin Registration';
        emailHand.PRM_Email_Handler_Status__c = 'Requested For Suppression';
        emailHand.PRM_Suppress_Email__c = true;  
        insert emailHand;
        
        PRM_Email_Handler_Utility.returnContactSupressionMap(new Set<Id>{newAccount.id},emailHand.PRM_Event__c);
        PRM_Email_Handler_Utility.checkForEmailSupression(contact.id, emailHand.PRM_Event__c);  
        PRM_Email_Handler_Utility.updateEmailHandlerDetails(new List<PRM_Email_Handler__c>{emailHand});
        test.stopTest();
        System.assertEquals('Requested For Suppression', emailHand.PRM_Email_Handler_Status__c);
    }
}