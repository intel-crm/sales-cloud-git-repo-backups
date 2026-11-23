/**************************************************************************************
Apex Class Name:  Core_SendContact_to_AGS_onGECChange
Version     : 1.0 
Created Date: 27 Sep 2021
Function    : test class for Core_SendContact_to_AGS_onGECChange
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh Manikonda             27/09/2020             Original Version
*************************************************************************************/
@isTest
public class Core_SendContact_to_AGS_onGECChange_test {
    
    
    @testSetup 
    static void setup(){
        List<Core_Trigger_Executions__c> triggerSettingList = new List<Core_Trigger_Executions__c>();
        List<String> settingNameList = new List<String>();
        settingNameList.add('userGroupMappingIndicator');
        settingNameList.add('intStatusLastUpdate');
        settingNameList.add('ContactAccountChangeUpdate');
        settingNameList.add('MergeContactEntitlements');
        settingNameList.add('ContactEmailChangeUpdate');
        //settingNameList.add('updateInquiryOwnerOnContactOwnerUpdate');
        settingNameList.add('contactJobFunction');
        settingNameList.add('eRPM_Int_Status_Pending_Insert');
        settingNameList.add('eRPM_Int_Status_Pending_Update');
        settingNameList.add('UpdateJobFunctionAndCode');
        settingNameList.add('UpdateMembershipFlagInd');
        settingNameList.add('UpdateExternalUserLanguageInd');
        settingNameList.add('Contact_Insert_IPA_Integration_Trigger');
        settingNameList.add('Contact_Update_IPA_Integration_Trigger');
        settingNameList.add('SendContactGECInfoToAGS');
        settingNameList.add('SendContactstoLicense');
        Core_Trigger_Executions__c triggerSetting;
        for(String settingName : settingNameList){
            triggerSetting = new Core_Trigger_Executions__c();
            triggerSetting.name = settingName;
            triggerSetting.Core_Object__c = 'Contact';
            triggerSetting.Core_Active__c = TRUE;
            triggerSetting.Core_Description__c = 'This is test description';
            triggerSetting.Core_Class_Name__c = 'Core_ContactHandler';
            triggerSetting.Core_Trigger_Events__c = 'Before Insert, Before Update, After Insert, After Update';
            triggerSettingList.add(triggerSetting);
        }
        insert triggerSettingList;
     
    }
    
    
    static testMethod void SendGECtoAGSTest() {
        
        
        List<Core_Apigee_Cred_Contact_GEC__c> GECCred= new List<Core_Apigee_Cred_Contact_GEC__c>();
        Core_Apigee_Cred_Contact_GEC__c gec = new Core_Apigee_Cred_Contact_GEC__c();
        gec.Name='SendContact_to_AGS';
        gec.Core_Class_name__c='Core_SendContact_to_AGS_onGECChange';
        gec.Core_Client_Id__c='ec3dc7a0-5f81-4846-8b34-d288386dc520 ';
        gec.Core_Client_Secret__c='6Cr7Q~j1Zbsw3psK8K_xlqcSll7CZlx0n7a7l';
        gec.Core_EndPoint_Url__c='https://apis-sandbox.intel.com/m2r/global-export-compliance/v1/identities/';
        //gec.Core_Grant_Type__c='client_credentials';
        gec.Core_Grant_Type__c='ccc';
        
        gec.Core_Token_EndPoint_URL__c='https://apis-sandbox.intel.com/v1/auth/token';
        GECCred.add(gec);
        insert GECCred;
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new Core_HttpCallouts_MockResponse_Pass());
        
        
        
		Account account = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        
        insert account;
        
        
        List<Contact> lstContacts = Core_Test_Utility.createContacts(1);
        Contact contact = lstContacts[0];
        contact.AccountId = account.id;
        contact.Core_Enterprise_Id__c='300002753379';
        
        insert lstContacts;
        contact.FirstName = 'test test test ';
        contact.LastName = 'your test ';
        update lstContacts;
        System.assertNotEquals(account.Id,null);
        
        
        // Core_SendContact_to_AGS_onGECChange.ContactGECJSON('abc','Export',true,'300002753379');
        // Core_SendContact_to_AGS_onGECChange.ContactGECJSON('','Export',false,'300002753379'); 
        //Core_SendContact_to_AGS_onGECChange.SendUpdatedContactsDatatoLicence(lstContacts, new Map<Id,Contact>(lstContacts));
        Test.stopTest();
        
        
    }
    
    
    
    
    
    
    
    static testMethod void GECsummaryEmail_test(){
        List<Core_Contact_GEC_Staging__c> ContactGECStaging= new List<Core_Contact_GEC_Staging__c> ();
        Account account = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        
        insert account;
        List<Contact> lstContacts = Core_Test_Utility.createContacts(1);
        Contact contact = lstContacts[0];
        contact.AccountId = account.id;
        contact.Core_Enterprise_Id__c='300002753379';
        
        insert lstContacts;
        
        ContactGECStaging.add(new Core_Contact_GEC_Staging__c(Core_Status__c='Failed',Core_GEC_Retry_Counter__c=3,Core_Payload__c='Xyz',
                                                              Core_Contact_ID__c=contact.Core_Enterprise_Id__c,Core_Response__c='Success'));
        
        ContactGECStaging.add(new Core_Contact_GEC_Staging__c(Core_Status__c='Failed',Core_GEC_Retry_Counter__c=3,Core_Payload__c='Xyz',
                                                              Core_Contact_ID__c=contact.Core_Enterprise_Id__c,Core_Response__c='Success'));
        
        insert ContactGECStaging;
        Test.setCreatedDate(ContactGECStaging[0].Id, Date.today().addDays(-1));
         Test.setCreatedDate(ContactGECStaging[1].Id, Date.today().addDays(-1));
        Test.startTest();
        
        Core_FailedGEC_Summary_Email  GECEmail= new Core_FailedGEC_Summary_Email(); 
          GECEmail.GECFailedRecordsize =1;
         GECEmail.GECBlockedContactSize=1;
         GECEmail.GECUnBlockedContactSize=1;
        Id batchJobId = Database.executeBatch(GECEmail);
         System.assertNotEquals(batchJobId,null);
        Test.stopTest();
        
        
    }
    
    static testMethod void GECsummaryEmail_Schdule(){
        List<Account> lstAccounts = Core_Test_Utility.createAccount(1);
        Account account = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        insert account; 
        
        List<Contact> lstContacts = Core_Test_Utility.createContacts(1);
        Contact contact = lstContacts[0];
        contact.AccountId = account.id;
        contact.Core_Enterprise_Id__c='300002753379';
        insert lstContacts;
        account.Core_Export_Compliance_Block__c=true;
        account.Core_Export_Compliance_Block_Reason__c='Global Export Compliance Block';
        update account;
        
        String CRON_EXP = '0 6 * * * ?';
        
        Test.startTest();
        
        String jobId = System.schedule('Update Contacts', CRON_EXP, new Core_GEC_Summary_Schedule());
                 System.assertNotEquals(jobId,null);
         Test.stopTest();
        
    }
    
    
    public class Core_HttpCallouts_MockResponse_Pass implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            String accessToken ='';
            // System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token": "' + accessToken + '", "token_type": "Bearer","expires_in": "3599", "ext_expires_in": "3599"}');
            
            // res.setBody(' "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Imwzc1EtNTBjQ0g0eEJWWkxIVEd3blNSNzY4MCJ9.eyJhdWQiOiJhMDExOTc4Yy04MGYzLTRlMmUtOWJmNS02NmM1MzM2MjQ3YTEiLCJpc3MiOiJodHRwczovL2xvZ2luLm1pY3Jvc29mdG9ubGluZS5jb20vNDZjOThkODgtZTM0NC00ZWQ0LTg0OTYtNGVkNzcxMmUyNTVkL3YyLjAiLCJpYXQiOjE2MzM2NzQ1NzYsIm5iZiI6MTYzMzY3NDU3NiwiZXhwIjoxNjMzNjc4NDc2LCJhaW8iOiJFMlpnWURpaHdIWm4vc3AvcDluKy9Wa3czYUttRGdBPSIsImF6cCI6ImEwMTE5NzhjLTgwZjMtNGUyZS05YmY1LTY2YzUzMzYyNDdhMSIsImF6cGFjciI6IjEiLCJvaWQiOiI3ZmE4ZDQ3Ni1iNjFkLTRmMDgtOGI4YS0xZjY5MzdkZWJkMTkiLCJyaCI6IjAuQVEwQWlJM0pSa1RqMUU2RWxrN1hjUzRsWFl5WEVhRHpnQzVPbV9WbXhUTmlSNkVOQUFBLiIsInJvbGVzIjpbIkRhYVNfU3VwcGxpZXJfUl9OUCIsIkVEVlBfUFJPRF9JUEFfVVNFUiIsIkVEVlBfREVWX1JGUEVHQV9VU0VSIiwiRURWUF9ERVZfVVNFUl9TTFNfT1BJRCIsIkVEVlBfUFJPRF9QUE1fVVNFUiIsIkVEVlBfUFJFUFJPRF9QUE1fVVNFUiIsIkVEVlBfREVWX1VTRVJfUEVHQV9DSVJBIiwiRURWUF9QUk9EX1VTRVJfUEVHQV9DSVJBIiwiRURWUF9QUk9EX1JGUEVHQV9VU0VSIiwiRGFhU19TdXBwbGllcl9SX1BSRCIsIkVEVlBfREVWX0lQQV9VU0VSIiwiRURWUF9QUk9EX1VTRVJfU0xTX09QSUQiXSwic3ViIjoiN2ZhOGQ0NzYtYjYxZC00ZjA4LThiOGEtMWY2OTM3ZGViZDE5IiwidGlkIjoiNDZjOThkODgtZTM0NC00ZWQ0LTg0OTYtNGVkNzcxMmUyNTVkIiwidXRpIjoiQUtYcUxzNGRmRXVkZmhUMmZBRGlBQSIsInZlciI6IjIuMCJ9.JSZtueEotliWf3h4_ZzGH4qPSJFCHluDQ5XD6lERLF5sn-bEiFUA7RJCIngkQVrnJ2lNAT4md5s6_s4HBgiuZbWa0n0rHfmNT4bgKTxpkcY1tuRaSpUo96Tzkm7OvD9BZMLu511RMccns2vam9ToFYRGBvvz23eoEs-Rf1uvhxorb6bOUjUTBcIy5LwhL0krqzgYwi18FQH-OPL-KFT4NX0EsfctG9ANup7wTaxwtZWMf9s0hjGWwKCnl8UB_71WbuaEreNiOE8Y6OW0DvkzQ9fUAX-lNg70KwGoabqiGw1Ogtg9l5GqyHo5UIRfBvo2rqansU2JqkhM7Oo-mVUoE,
            
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class Core_HttpCallouts_MockResponse_fail implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            String accessToken ='';
            // System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token":"' + accessToken + '", "token_type": "Bearer","expires_in": "3599", "ext_expires_in": "3599"}');
            
            // res.setBody(' "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Imwzc1EtNTBjQ0g0eEJWWkxIVEd3blNSNzY4MCJ9.eyJhdWQiOiJhMDExOTc4Yy04MGYzLTRlMmUtOWJmNS02NmM1MzM2MjQ3YTEiLCJpc3MiOiJodHRwczovL2xvZ2luLm1pY3Jvc29mdG9ubGluZS5jb20vNDZjOThkODgtZTM0NC00ZWQ0LTg0OTYtNGVkNzcxMmUyNTVkL3YyLjAiLCJpYXQiOjE2MzM2NzQ1NzYsIm5iZiI6MTYzMzY3NDU3NiwiZXhwIjoxNjMzNjc4NDc2LCJhaW8iOiJFMlpnWURpaHdIWm4vc3AvcDluKy9Wa3czYUttRGdBPSIsImF6cCI6ImEwMTE5NzhjLTgwZjMtNGUyZS05YmY1LTY2YzUzMzYyNDdhMSIsImF6cGFjciI6IjEiLCJvaWQiOiI3ZmE4ZDQ3Ni1iNjFkLTRmMDgtOGI4YS0xZjY5MzdkZWJkMTkiLCJyaCI6IjAuQVEwQWlJM0pSa1RqMUU2RWxrN1hjUzRsWFl5WEVhRHpnQzVPbV9WbXhUTmlSNkVOQUFBLiIsInJvbGVzIjpbIkRhYVNfU3VwcGxpZXJfUl9OUCIsIkVEVlBfUFJPRF9JUEFfVVNFUiIsIkVEVlBfREVWX1JGUEVHQV9VU0VSIiwiRURWUF9ERVZfVVNFUl9TTFNfT1BJRCIsIkVEVlBfUFJPRF9QUE1fVVNFUiIsIkVEVlBfUFJFUFJPRF9QUE1fVVNFUiIsIkVEVlBfREVWX1VTRVJfUEVHQV9DSVJBIiwiRURWUF9QUk9EX1VTRVJfUEVHQV9DSVJBIiwiRURWUF9QUk9EX1JGUEVHQV9VU0VSIiwiRGFhU19TdXBwbGllcl9SX1BSRCIsIkVEVlBfREVWX0lQQV9VU0VSIiwiRURWUF9QUk9EX1VTRVJfU0xTX09QSUQiXSwic3ViIjoiN2ZhOGQ0NzYtYjYxZC00ZjA4LThiOGEtMWY2OTM3ZGViZDE5IiwidGlkIjoiNDZjOThkODgtZTM0NC00ZWQ0LTg0OTYtNGVkNzcxMmUyNTVkIiwidXRpIjoiQUtYcUxzNGRmRXVkZmhUMmZBRGlBQSIsInZlciI6IjIuMCJ9.JSZtueEotliWf3h4_ZzGH4qPSJFCHluDQ5XD6lERLF5sn-bEiFUA7RJCIngkQVrnJ2lNAT4md5s6_s4HBgiuZbWa0n0rHfmNT4bgKTxpkcY1tuRaSpUo96Tzkm7OvD9BZMLu511RMccns2vam9ToFYRGBvvz23eoEs-Rf1uvhxorb6bOUjUTBcIy5LwhL0krqzgYwi18FQH-OPL-KFT4NX0EsfctG9ANup7wTaxwtZWMf9s0hjGWwKCnl8UB_71WbuaEreNiOE8Y6OW0DvkzQ9fUAX-lNg70KwGoabqiGw1Ogtg9l5GqyHo5UIRfBvo2rqansU2JqkhM7Oo-mVUoE,
            
            res.setStatusCode(400);
            return res;
        }
    }
    
}