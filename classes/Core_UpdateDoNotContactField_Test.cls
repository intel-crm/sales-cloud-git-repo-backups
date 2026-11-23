@isTest
public class Core_UpdateDoNotContactField_Test {
    
    public static Account createTestAccount() 
    {
      
        Account acctObj = new Account();
        acctObj.Name = 'Outbound Test Account';
        acctObj.Core_CNDA_Number__c = '112233445566';
        acctObj.BillingStreet = '1234 Tester Account123456789123456789123456789123456789Account1123456789123456789123456789123456789Account11234567891234567891Account 1123456789123456789';
        acctObj.BillingCity = 'Testing City';
        acctObj.BillingStateCode = 'OR';
        acctObj.BillingCountryCode = 'USA';
        acctObj.BillingPostalCode = '12345';
        acctObj.ShippingStreet = 'Yemen';
        acctObj.ShippingCity = 'Testing City';
        acctObj.ShippingStateCode = 'OR';
        acctObj.ShippingCountryCode = 'USA';
        acctObj.ShippingPostalCode = '12345';
        acctObj.Core_User_Defined_Phone_Number__c = '1234567890';
        acctObj.Core_User_Defined_Website__c ='www.xyz.com';
        acctObj.Core_User_Defined_Number_of_Employees__c = '1-9';
        acctObj.Core_Account_Legal_Name__c = 'Outbound Test Account';
        acctObj.Core_IsODM__c = false;
        acctObj.Core_B2B_ERPM_Account_Number__c = 'ERPM1234';
        acctObj.Core_English_Only_Name__c = 'Outbound Test Account';
        acctObj.Core_Alternate_Language_Name__c = 'Alternate Name Account';
        acctObj.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        acctObj.Core_CIM_ID__c = '123456789';
        
        insert acctObj;
        
        return acctObj;
    }
    
    public static Contact createTestContact() 
    {
        Contact conObj = new Contact();
        Account acctObj = createTestAccount();
        conObj.AccountId = acctObj.Id;
        conObj.Core_eRPM_Person_Id__c = '111111';
        conObj.Core_Sales_Do_Not_Contact_Ind__c=True;
        conObj.Core_Do_Not_Contact__c=True;
        conObj.Core_Enterprise_Id__c = '123456';
        conObj.Core_Login_Id__c = '12355';
        conObj.FirstName = 'Outbound Integrations Tester';
        conObj.LastName = 'Person';
        conObj.Email = 'OITester123@tester.com';
        conObj.Core_English_Only_First_Name__c = 'Outbound Integrations Tester';
        conObj.Core_English_Only_Last_Name__c = 'Person';
        conObj.Core_Do_Not_Contact__c = false;
        conObj.Salutation = 'Mr.';
        conObj.Title = 'OBM Tester';
        conObj.Core_Job_Function__c = 'Information Technology';
        conObj.Core_Preferred_Language__c= 'ENG';
        conObj.MailingStreet = '1234 Tester St';
        conObj.MailingCity = 'Testing City';
        conObj.MailingStateCode = 'OR';
        conObj.MailingCountryCode = 'USA';
        conObj.MailingPostalCode = '12345';
        conObj.Phone = '1234567890';
        conObj.MobilePhone = '0987654321';
        //conObj.Core_IPA_Partner_Role__c = 'Service Provider';
        conObj.Core_IPA_PartnerRole__c = 'Service Provider';
        conObj.Core_ERPM_Integration_Status__c = 'Pending';
        conObj.Core_AGS_Integration_Status__c = 'Pending';
        conObj.RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id;
        insert conObj;
        return conObj;
    }
    
    @isTest static void updateDoNotContactFields(){
        Test.startTest();
        Contact newContact = createTestContact();
        newContact.Core_Sales_Do_Not_Contact_Ind__c=False;
        newContact.Core_Do_Not_Contact__c=False;
        update newContact;
        
        List<Contact> updateContactList = new List<Contact>();
        updateContactList.add(newContact);
        Core_UpdateDoNotContactField.updateDoNotContactFields(updateContactList);
        
        
        newContact.Core_Sales_Do_Not_Contact_Ind__c=True;
        newContact.Core_Do_Not_Contact__c=True;
        update newContact;
        
        Core_UpdateDoNotContactField.updateDoNotContactFields(updateContactList);
        
        Test.stopTest();
    }
}