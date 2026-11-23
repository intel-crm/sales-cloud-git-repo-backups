@isTest
public class PRM_SendInviteEmail_Batch_Test {
 @TestSetup
    //test data creation
    static void setupDataCreation(){
        String strTags = '';
        DateTime reqTime = System.now();
        List<IPA_Batch_Configurations__mdt> listBatchConfigItems = [select id, DeveloperName, Record_Limit__c, PRM_SchedulingTimeMins__c, PRM_StandardEmailBulk__c from IPA_Batch_Configurations__mdt where DeveloperName =: 'PRM_BulkBatchConfigurableItems' limit 1];
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Account acc = new Account();
        acc.Name ='Intel';
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry ='Agriculture';
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_User_Defined_Website__c = 'abc.com';
        acc.AccountNumber = '5879807687';
        acc.RecordTypeId = accountRecordTypeIntel;
        insert(acc);
        
        Contact con1 = new Contact();
        con1.FirstName='Mathew';
        con1.LastName='Smithy';
        con1.Email='testmathewsmithy@mailinator.com';
        con1.Phone='9999779791';
        con1.AccountId = acc.Id;
        con1.Core_Job_Function__c='Branch Manager';
        con1.Core_eRPM_Language_Code__c='Eng';        
        con1.Core_IPA_PartnerRole__c = 'Service Provider';
        con1.Core_Login_Id__c = 'xyz';
        con1.Core_IPA_Email_Verification_Date__c = System.now();
        con1.Core_Enterprise_Id__c = '463179832';
        con1.Core_Preferred_Language__c = 'ENG';
        con1.MailingCountryCode = 'USA';
        insert con1;
        
        
        ChannelProgram cp = PRM_TestUtility.getChannelPrograms();
        insert cp;
        
        PRM_ContactRelationships__c admin = new PRM_ContactRelationships__c();   //Contact Relationship
        admin.Name='Partner Admin';
        admin.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        admin.PRM_Channel_Program_Id__c = cp.Id;
        admin.PRM_Default_Relationship_Ind__c = true;
        insert admin;
        
        PRM_ContactRelationships__c employee = new PRM_ContactRelationships__c();   //Contact Relationship
        employee.Name='Employee';
        employee.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
        employee.PRM_Channel_Program_Id__c = cp.Id;
        employee.PRM_Default_Relationship_Ind__c = true;
        insert employee;
        
        PRM_Contact_Relationship__c emp = new PRM_Contact_Relationship__c();
        emp.Name ='Employee';
        emp.PRM_Relationship_Name__c='Employee';
        emp.PRM_Relationship_Id__c=employee.Id;
        insert emp;
        
        PRM_Contact_Relationship__c adm = new PRM_Contact_Relationship__c();
        adm.Name ='Partner Admin';
        adm.PRM_Relationship_Name__c='Partner Admin';
        adm.PRM_Relationship_Id__c=admin.Id;
        insert adm;
        
        PRM_Account_Contact_Relationship__c acrEmpA = new PRM_Account_Contact_Relationship__c();
        acrEmpA.PRM_Relationship_Id__c = employee.Id;
        acrEmpA.PRM_Account_Id__c = acc.Id;
        acrEmpA.PRM_Contact_Id__c = con1.Id;
        acrEmpA.PRM_InActive_Ind__c= false;
        acrEmpA.PRM_Status_Nm__c = 'Pending Action';
        insert acrEmpA;
        
        PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();
        be.PRM_Contact_Id__c = con1.Id;
        be.Source__c = 'Admin Invite Email';
        be.PRM_Status_Nm__c = 'New';
        be.PRM_EV_Token__c = 'abcd';
        be.PRM_IdentityAttribute__c = con1.Core_Enterprise_Id__c;
        insert be;
    }
    @isTest
    static void invitedContact(){
        test.startTest();
        String strTags = '';
        List<IPA_Batch_Configurations__mdt> listBatchConfigItems = [select id, DeveloperName, Record_Limit__c, PRM_SchedulingTimeMins__c, PRM_StandardEmailBulk__c from IPA_Batch_Configurations__mdt where DeveloperName =: 'PRM_BulkBatchConfigurableItems' limit 1];
        Account acc = [select id, name from Account where name =: 'Intel'];
        Contact cont = [Select id, email,Core_Enterprise_Id__c,Core_Login_Id__c,Core_IPA_PartnerRole__c,Core_Preferred_Language__c from contact where email = 'testmathewsmithy@mailinator.com'];
        PRM_Batch_Entitlement__c be = [Select Id, Name,PRM_Contact_Id__c,Source__c,PRM_Status_Nm__c,PRM_EV_Token__c,PRM_IdentityAttribute__c from PRM_Batch_Entitlement__c where PRM_Contact_Id__c =:cont.Id];
        strTags = cont.Core_Enterprise_Id__c;
        PRM_SendInviteEmail_Batch inviteEmailBatch=new PRM_SendInviteEmail_Batch();//cont, null, strTags
        Database.executeBatch(inviteEmailBatch,200);
        test.stopTest();         
    }
}