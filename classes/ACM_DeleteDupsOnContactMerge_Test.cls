@isTest
public class ACM_DeleteDupsOnContactMerge_Test {
    
    @TestSetup static void createAllRecordsForTest() {
        Account account = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Acct1','Intel Account','UNFD_CTRY_CUST');
        account.Core_Business_Party_Id__c = '1234568';
        insert account;
        
        List<Contact> lstContacts = Core_Test_Utility.createContacts(2);
        Contact contact1 = lstContacts[0];
        Contact contact2 = lstContacts[1];
                
        contact1.MailingCountry='IND';
        contact1.AccountId = account.id;

        contact2.MailingCountry='IND';
        contact2.AccountId = account.id;
        insert lstContacts;
        
        Core_ACM_Contact_Staging__c acmStaging = new Core_ACM_Contact_Staging__c();
        acmStaging.ContactId__c = contact1.Id;
        acmStaging.Core_Action__c = 'CM';
        acmStaging.Core_Status__c = 'NEW';
        insert acmStaging;
        
        List<PRM_Partner_Community_Enrollment_Request__c> partnrEnrmntReqList = new List<PRM_Partner_Community_Enrollment_Request__c>();
        PRM_Partner_Community_Enrollment_Request__c partnerReq1 = new PRM_Partner_Community_Enrollment_Request__c();
        partnerReq1.PRM_Contact_Id__c = contact1.Id;
        partnerReq1.PRM_Partner_Community_Nm__c = 'Funded Head';
        partnerReq1.PRM_Start_Date_Dt__c = system.now();
        partnerReq1.CreatedDate = system.now();
        partnrEnrmntReqList.add(partnerReq1);
        
        PRM_Partner_Community_Enrollment_Request__c partnerReq2 = new PRM_Partner_Community_Enrollment_Request__c();
        partnerReq2.PRM_Contact_Id__c = contact1.Id;
        partnerReq2.PRM_Partner_Community_Nm__c = 'Funded Head';
        partnerReq2.PRM_Start_Date_Dt__c = system.now();
        partnerReq2.CreatedDate = system.now();
        partnrEnrmntReqList.add(partnerReq2);
        insert partnrEnrmntReqList;
        
        PRM_Partner_Subscription__c sub = new PRM_Partner_Subscription__c();
        sub.Name = 'Membership Communications';
        sub.PRM_Subscription_Cd__c = 'MEMBCOM';
        insert sub;
        
        List<PRM_ContactSubscriptionAssociation__c> conSubList = new List<PRM_ContactSubscriptionAssociation__c>();
        PRM_ContactSubscriptionAssociation__c conSub1 = new PRM_ContactSubscriptionAssociation__c();
        conSub1.PRM_Contact_Id__c = contact1.Id;
        conSub1.PRM_Partner_Subscription_Id__c = sub.Id;
        conSub1.PRM_Status_Nm__c = 'Active';
        conSub1.CreatedDate = system.now();
        conSubList.add(conSub1);
        
        PRM_ContactSubscriptionAssociation__c conSub2 = new PRM_ContactSubscriptionAssociation__c();
        conSub2.PRM_Contact_Id__c = contact1.Id;
        conSub2.PRM_Partner_Subscription_Id__c = sub.Id;
        conSub2.PRM_Status_Nm__c = 'Active';
        conSub2.CreatedDate = system.now();
        conSubList.add(conSub2);
        insert conSubList;
        
        List<Core_Inquiry__c> inqList = new List<Core_Inquiry__c>();
        Core_Inquiry__c inq1 = new Core_Inquiry__c();
        inq1.Core_Contact_Inquiries__c = contact1.Id;
        inq1.Name = 'Sales Approved';
        inq1.Core_Inquiry_Type_Pkt__c = 'Sales Approved';
        inq1.CreatedDate = system.now();
        inqList.add(inq1);
        
        Core_Inquiry__c inq2 = new Core_Inquiry__c();
        inq2.Core_Contact_Inquiries__c = contact1.Id;
        inq2.Name = 'Sales Approved';
        inq2.Core_Inquiry_Type_Pkt__c = 'Sales Approved';
        inq2.CreatedDate = system.now();
        inqList.add(inq2);
        insert inqList;
        
        User user = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration'].Id,
            FirstName = 'CRM ACM',
            LastName = 'System User',
            Email = 'Test@example.com',
            Username = 'Test@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'Test Title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert user;
        System.runAs(user) {   
            Core_Engagement__c conEngg = new Core_Engagement__c();
            conEngg.Name = 'CRM Cloud Contacts';
            conEngg.Core_Engagement_Code__c = 'CRM_Cloud_Cntct';
            insert conEngg;
            
            List<Core_Contact_Engagement__c> conEnggList= new List<Core_Contact_Engagement__c>();
            Core_Contact_Engagement__c conEngg1 = new Core_Contact_Engagement__c();
            conEngg1.Core_Engagement__c = conEngg.Id;
            conEngg1.Core_Contact__c = contact1.Id;
            conEngg1.Core_Active__c = true;
            conEngg1.CreatedDate = system.now();
            conEnggList.add(conEngg1);
            
            Core_Contact_Engagement__c conEngg2 = new Core_Contact_Engagement__c();
            conEngg2.Core_Engagement__c = conEngg.Id;
            conEngg2.Core_Contact__c = contact1.Id;
            conEngg2.Core_Active__c = true;
            conEngg2.CreatedDate = system.now();
            conEnggList.add(conEngg2);   
            insert conEnggList;
        }
        
    }
    
    @isTest
    public static void testBatchExecution() {
        
        Test.startTest();
        
        Core_ContactACMStagingBatch batch = new Core_ContactACMStagingBatch();
        ID jobID = Database.executeBatch(batch);
        System.assertNotEquals(jobId,null);
        
        Test.stopTest();
    }
    
    @isTest
    public static void testStagRecCreation(){

		Test.startTest();
        
        Set<Id> conIDs = new Set<Id>();
        ACM_DeleteDupsOnContactMergeHandler.contactStagingRecords(conIDs); 
                
        Test.stopTest();        
    }
    
}