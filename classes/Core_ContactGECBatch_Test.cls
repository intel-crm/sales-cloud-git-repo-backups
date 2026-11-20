@isTest
public class Core_ContactGECBatch_Test {
    
    @TestSetup static void createAllRecordsForTest() {
        List<Core_Trigger_Executions__c> triggerSettingList = new List<Core_Trigger_Executions__c>();
        List<String> settingNameList = new List<String>();
        settingNameList.add('SendContactGECInfoToAGS');
        Core_Trigger_Executions__c triggerSetting;
        for(String settingName : settingNameList){
            triggerSetting = new Core_Trigger_Executions__c();
            triggerSetting.name = settingName;
            triggerSetting.Core_Object__c = 'Contact';
            triggerSetting.Core_Active__c = False;
            triggerSetting.Core_Description__c = 'This is test description';
            triggerSetting.Core_Class_Name__c = 'Contact Flow';
            triggerSetting.Core_Trigger_Events__c = 'After Update';
            triggerSettingList.add(triggerSetting);
        }
        insert triggerSettingList;
        Core_Contact_GEC_Staging__c gecStaging = new Core_Contact_GEC_Staging__c();
        gecStaging.Core_Account_Id__c = 'test';
        gecStaging.Core_Contact_ID__c = 'test';
        gecStaging.Core_Contact_Rec_Id__c = 'we32312xddw';
        gecStaging.Core_Contact_WWID__c = '3223242';
        gecStaging.Core_GEC_Blocked__c = true;
        gecStaging.Core_GEC_Blocked_Reason__c = 'test';
        gecStaging.Core_Payload__c = 'test';
        gecStaging.Core_Response__c = 'test';
        gecStaging.Core_Status__c = 'New';
        insert gecStaging;
        List<Core_Apigee_Cred_Contact_GEC__c> GECCred= new List<Core_Apigee_Cred_Contact_GEC__c>();
        Core_Apigee_Cred_Contact_GEC__c gec = new Core_Apigee_Cred_Contact_GEC__c();
        gec.Name='SendContact_to_AGS';
        gec.Core_Class_name__c='Core_SendContact_to_AGS_onGECChange';
        gec.Core_Client_Id__c='ec3dc7a0-5f81-4846-8b34-d288386dc520 ';
        gec.Core_Client_Secret__c='6Cr7Q~j1Zbsw3psK8K_xlqcSll7CZlx0n7a7l';
        gec.Core_EndPoint_Url__c='https://apis-sandbox.intel.com/m2r/global-export-compliance/v1/identities/';
        gec.Core_Grant_Type__c='ccc';
        
        gec.Core_Token_EndPoint_URL__c='https://apis-sandbox.intel.com/v1/auth/token'; 
        GECCred.add(gec);
        insert GECCred;
        RecordType rec = [select Id,Name from RecordType where sObjectType='Account' AND Name = 'Intel Account' LIMIT 1];
        List<Account> lstAccounts = Core_Test_Utility.createAccount(1);
        Account account = lstAccounts[0];
        account.RecordTypeId = rec.Id;
        insert account;
        
        List<Contact> lstContacts = Core_Test_Utility.createContacts(1);
        Contact contact = lstContacts[0];
        contact.AccountId = account.id;
        contact.Core_Enterprise_Id__c='300002753379'; 
        contact.MailingCountry = 'IND';
        insert lstContacts;
        contact.Core_Contact_Export_Compliance_Block__c=true;
        contact.Core_Con_Export_Compliance_Block_Reason__c ='Global Export Compliance Block';
        update lstContacts;
        
    }
    
    @isTest
    public static void testBatchExecution() {
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new Core_HttpCallouts_MockResponse_Pass());
        
        Core_ContactGECBatch batch = new Core_ContactGECBatch();
        ID jobID = Database.executeBatch(batch);
        System.assertNotEquals(jobId,null);
        
        Test.stopTest();
    }
    @isTest
    public static void testRetry() {
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new Core_HttpCallouts_MockResponse_fail());
        
        Core_ContactGECBatch batch = new Core_ContactGECBatch();
        ID jobID = Database.executeBatch(batch);
        System.assertNotEquals(jobId,null);
        
        Test.stopTest();
    }
    
    public class Core_HttpCallouts_MockResponse_fail implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
             String accessToken ='';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token": "' + accessToken + '", "token_type": "Bearer","expires_in": "3599", "ext_expires_in": "3599"}');
            
            
            res.setStatusCode(500);
            return res;
        }
    }
    public class Core_HttpCallouts_MockResponse_Pass implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
           String accessToken= '';
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token": "' + accessToken + '", "token_type": "Bearer","expires_in": "3599", "ext_expires_in": "3599"}');
            
            
            res.setStatusCode(200);
            return res; 
        }
    }
    
    
}