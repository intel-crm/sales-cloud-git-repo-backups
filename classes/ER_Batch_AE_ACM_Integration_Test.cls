@isTest
public class ER_Batch_AE_ACM_Integration_Test {
    public static string moduleName = System.Label.ER_ACM_Module_Name;
    public static string accountIntegration = System.Label.ER_ACM_Content_AccountId; 
    public static string contactIntegration = System.Label.ER_ACM_Content_ContactId; 
    public static string CMFGIntegration = System.Label.ER_ACM_Content_CMFG; 
    @isTest
    private static void testBatchExecution() {
        String intelAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account testAccount = new Account(Name='testAccountSetup',/*Core_Account_Type__c='Other',*/ Industry='Others',Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',BillingCountry='USA', BillingPostalCode='12345',
                                          ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',RecordTypeId=intelAccRecTypeId,Core_CNDA_Number__c = '126545');
        insert testAccount;
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Contact testContact = new Contact(FirstName='test',LastName='Contact1',RecordTypeId=IntelContRecTypeId, Email='testcontact1@mailinator.com',
                                          AccountId=testAccount.id,MailingCity='delhi',MailingState='FL',MailingCountry='USA',MailingPostalCode='123456',Core_English_Only_First_Name__c = 'Joy',Core_Enterprise_Id__c='12345');
        insert testContact;
        ER_Customer_Master_File_Group__c testCMFGroup = new ER_Customer_Master_File_Group__c(Name='testCMFGroup',ER_Active__c=true);
        insert testCMFGroup;
        
        List<ACM_Integration_Message_Queue__c> integrationMessages = new List<ACM_Integration_Message_Queue__c>();
        for (Integer i = 0; i < 3; i++) {
            ACM_Integration_Message_Queue__c integrationMessage = new ACM_Integration_Message_Queue__c();
            integrationMessage.Content__c = i == 0 ? testCMFGroup.id : i == 1 ? testAccount.id : testContact.id ;
            integrationMessage.Custom_Filter__c = i == 0 ? testCMFGroup.id : i == 1 ? testAccount.id : testContact.id ;
            integrationMessage.Content_Type__c = i == 0 ? CMFGIntegration : i == 1 ? accountIntegration : contactIntegration;
            integrationMessage.Message_Status__c = 'New';
            integrationMessage.Module_Name__c = moduleName;
            integrationMessage.Queue_Type__c = 'Outbound';
            integrationMessages.add(integrationMessage);
        }
        insert integrationMessages;
        
        Test.startTest();
        // Start the batch execution
        Database.executeBatch(new ER_Batch_AE_ACM_Integration());
        ACM_Integration_Message_Queue__c intMsg =[Select id,Content__c,Content_Type__c,Message_Status__c,Module_Name__c,Queue_Type__c from ACM_Integration_Message_Queue__c where id =:integrationMessages limit 1];
        system.assertEquals('New', intMsg.Message_Status__c);
        Database.executeBatch(new ER_Batch_AE_ACM_Integration());
        Test.stopTest();
        
    }
    
}