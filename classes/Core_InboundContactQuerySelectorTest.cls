@isTest
public class Core_InboundContactQuerySelectorTest{
    private static Core_InboundContactSelectorContracts.IContactQuerySelector contactQuerySelectorInstance = Core_InboundContactQuerySelector.getInstance();
    
    @TestSetup
    private static void setCommonData(){
        Account accountInstance = new Account();
        accountInstance.name = 'Test Acct1';
        accountInstance.BillingCountryCode = 'USA';
        accountInstance.BIllingStateCode = 'AL';
        accountInstance.BillingCity = 'Alabama';
        accountInstance.BillingStreet = 'test';
        accountInstance.Core_Sales_Groups__c = 'APJ India Sales Group';
        accountInstance.Industry = 'Agriculture';
        accountInstance.Core_Sub_Industry__c = 'Animal Production';
        insert accountInstance;

        Contact testContact=new Contact();
        testContact.FirstName = 'FNameTest';
        testContact.LastName = 'LastContTest';
        testContact.email = 'testg@gmail.com';
        testContact.AccountId=accountInstance.Id;
        testContact.Core_eRPM_Person_Id__c = '3000000';
        testContact.Core_Login_ID__c = 'test0';
        testContact.Core_Enterprise_ID__c = '1000001000';
        testContact.Title = 'Mr';
        testContact.Phone = '1001001000';
        insert testContact;
        Core_Integration_Inbound_Message__c inBoundMessage=new Core_Integration_Inbound_Message__c(Core_Source_System__c='ERPM',Core_Message_Type__c='Contact',Core_Payload__c='Test Payload');  
        insert inBoundMessage;
    }
    @isTest
    public static void WhengetContact(){
        String queryContactFields = 'Id, AccountId, Email, Core_eRPM_Person_Id__c, Core_Login_Id__c, Core_Login_Status__c, Core_Enterprise_Id__c, Core_Identity_Status__c,'+
            'Core_ERPM_Integration_Publish_Timestamp__c,Core_English_Only_First_Name__c,Core_IPA_PartnerRole__c';

        String erpmPersonId='3000000';
        String erpmEmail='testcontact0@acct0.com';
    
        Set<Id> contactIdsInserted = new Set<Id>();
        Contact c = [Select Id, AccountId, Email, Core_eRPM_Person_Id__c, Core_Login_Id__c, Core_Login_Status__c, Core_Enterprise_Id__c, Core_Identity_Status__c,
                     Core_ERPM_Integration_Publish_Timestamp__c,Core_English_Only_First_Name__c,Core_IPA_PartnerRole__c From contact where Core_eRPM_Person_Id__c = '3000000' Limit 1];
        
        contactIdsInserted.add(c.id);
        Test.startTest();
        contactQuerySelectorInstance.getContact(erpmPersonId, erpmEmail, queryContactFields);
        contactQuerySelectorInstance.getContactsById(contactIdsInserted, queryContactFields);
        contactQuerySelectorInstance.getContactById(c.Id, queryContactFields);
        Test.stopTest();
    }
    @isTest
    public static void whengetContactEntitlement(){
        String queryConEntitlementFields = 'Id, Core_Contact_Id__c, Core_Entitlement_Id__c, Core_Engagement_Tier__c, Core_Selected__c, Core_From_Source__c, Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c, Core_ERPM_Account_Data__c,'+
            'Core_Entitlement_Id__r.Core_AGS_Role_Id__c, Core_Entitlement_Id__r.Name, Core_Type__c, Core_Update_Reason__c';
        
            Contact c = [Select Id, AccountId, Email, Core_eRPM_Person_Id__c, Core_Login_Id__c, Core_Login_Status__c, Core_Enterprise_Id__c, Core_Identity_Status__c,
            Core_ERPM_Integration_Publish_Timestamp__c,Core_English_Only_First_Name__c,Core_IPA_PartnerRole__c From contact where Core_eRPM_Person_Id__c = '3000000' Limit 1];
            Id contactId=c.Id;
            Test.startTest();
            contactQuerySelectorInstance.getContactEntitlements(contactId, queryConEntitlementFields);
            Test.stopTest();
    }

    @isTest
    public static void whengetAccount(){
        String queryAccount = 'Id, Core_CIM_ID__c, CreatedDate, Core_B2B_Entitlement__c, Core_CNDA_Number__c';
        Contact c = [Select Id, AccountId, Email, Core_eRPM_Person_Id__c, Core_Login_Id__c, Core_Login_Status__c, Core_Enterprise_Id__c, Core_Identity_Status__c,
                     Core_ERPM_Integration_Publish_Timestamp__c,Core_English_Only_First_Name__c,Core_IPA_PartnerRole__c From contact where Core_eRPM_Person_Id__c = '3000000' Limit 1];
        Test.startTest();
        contactQuerySelectorInstance.getAccount(c.AccountId, queryAccount);
        Test.stopTest();
    }

    @isTest
    public static void whengetInboundMsg(){
        String queryInboundMsg = 'Id, Core_Processing_Status__c, Core_Exception_Message__c, Core_Log_Entry__c, Core_Tags__c, Core_Publish_Timestamp__c';
        Core_Integration_Inbound_Message__c inboundMsg = [Select Id, Core_Processing_Status__c, Core_Exception_Message__c, Core_Log_Entry__c, Core_Tags__c, Core_Publish_Timestamp__c
                                                          from Core_Integration_Inbound_Message__c LIMIT 1]; 
        Test.startTest();
        contactQuerySelectorInstance.getInboundMsg(inboundMsg.Id, queryInboundMsg);
        Test.stopTest();
    }

    @isTest
    public static void whengetgetEntitlements(){
        String queryEntitlement = 'Id, Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c';
        String andClauseEntitlement = 'Core_ERPM_Engagement_Id__c != null'; 
        Test.startTest();
        contactQuerySelectorInstance.getEntitlements(queryEntitlement, andClauseEntitlement);
        Test.stopTest();
    }
    
}