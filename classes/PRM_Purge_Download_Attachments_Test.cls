@isTest
public with sharing class PRM_Purge_Download_Attachments_Test {
    @isTest
    public static void contactTest (){

        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();

        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas222';
        newAccount.BillingCity='City2';
        newAccount.BillingStreet='Street2';
        newAccount.BillingCountry='India';
        //newAccount.BillingCountryCode='IND';
        newAccount.BillingPostalCode='123456';
        newAccount.BillingState='';
        //newAccount.Core_IPA_Partner_Role__c='Distributor';
        newAccount.Core_IPA_Partner_Role__c='Guest';
        newAccount.Core_IPA_Badge_Tier__c='member';
        newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        newAccount.Core_User_Defined_Website__c = 'abz.yz';
        newAccount.Core_Geo__c = 'ASMO';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c =true;
        insert newAccount;

        Contact con2 = new Contact();
        con2.FirstName='Ivory';
        con2.LastName='Smithy';
        con2.Email='testivorysmithy@mailinator.com';
        con2.Phone='9999779791';
        con2.AccountId = newAccount.Id;
        con2.Core_Job_Function__c='Branch Manager';
        con2.Core_eRPM_Language_Code__c='Eng';        
        con2.Core_Login_Id__c = 'tuv';
        insert con2;

        Profile p = [SELECT Id FROM Profile WHERE Name='Partner'];
        
        User u = new User(Alias = 'black', Email='testmail@mailinator.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='samuel.test@peoplenet.com', contactid = con2.Id);
        List<contentDocument> contentDocs = PMP_TestDataUtility.createContentDocument(true);
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.ContentDocumentId = contentDocs[0].id;
        cl.LinkedEntityId = con2.Id;
        cl.ShareType = 'V';
        insert cl;

        delete cl;

       
        Test.startTest();
        PRM_Purge_Download_Attachments batchschedule1 = new PRM_Purge_Download_Attachments();
        String cronExpression1 = '0 0 0/2 1/2 * ? *';
        system.schedule('Batch Test' , cronExpression1 , batchschedule1);
        PRM_Purge_Download_Attachments.start(0);
        Test.stopTest();       
    }
    public static testMethod void testschedule() {
		Test.StartTest();
        database.executebatch(new PRM_Purge_Download_Attachments());
       
        PRM_Purge_Download_Attachments batchschedule1 = new PRM_Purge_Download_Attachments();
        String cronExpression1 = '0 0 0/2 1/2 * ? *';
        system.schedule('Batch Test' , cronExpression1 , batchschedule1);
        PRM_Purge_Download_Attachments.start(1);
       
		Test.stopTest();
	}
}