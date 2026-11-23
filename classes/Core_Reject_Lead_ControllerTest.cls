/**************************************************************************************
Apex Class Name:  Core_Reject_Lead_ControllerTest
Version     : 1.0 
Created Date: 2nd August 2019
Function    : Test Class for Core_Reject_Lead_Controller
Modification Log :
* Developer                       Date                    Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar                  02/08/2019              Original Version
*************************************************************************************/
@isTest
public class Core_Reject_Lead_ControllerTest {

    @testSetup 
    static void setup(){
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User us = new User();
        us.FirstName = 'test';
        us.LastName = 'user';
        us.Email = 'testuser@intel.com';
        us.Username = 'testinguser@inteltest.com';
        us.Alias = 'testu';
        us.CommunityNickname = 'test1.user1';
        us.TimeZoneSidKey = 'America/Los_Angeles';
        us.LocaleSidKey = 'en_US';
        us.EmailEncodingKey = 'UTF-8';
        us.ProfileId = profileId.Id;
        us.LanguageLocaleKey = 'en_US';
        insert us;
        
        List<Lead> lstLeads = new List<Lead>();
        RecordType r1 = [Select Id from recordType where Name='Partner Lead'];
        Lead lead1 = new Lead();
        lead1.RecordTypeId = r1.Id;
        lead1.FirstName = 'Test1';
        lead1.LastName = 'Test12';
        lead1.email = 'mnbvftyj@gmail.com';
        lead1.Phone = '123 246789';
        lead1.Company = 'Test1hcjcj';
        lead1.CountryCode = 'USA';
        lead1.LeadSource = 'Partner Program';
        lead1.Core_Partner_Name__c = 'TestPartner1';
        lead1.Status='PRL';
        lead1.Core_Lead_Status__c='New';
        lead1.Core_Lead_State__c='Unclaimed';
        lead1.Core_Rejection_Comments__c ='Test';
        lstLeads.add(lead1);
                
        Lead lead2 = new Lead();
        lead2.RecordTypeId = r1.Id;
        lead2.FirstName = 'Test12';
        lead2.LastName = 'Test123';
        lead2.email = 'dfgjnkjhgc@gmail.com';
        lead2.Phone = '123 89709878542';
        lead2.Company = 'Test1gjhkvjn';
        lead2.CountryCode = 'USA';
        lead2.LeadSource = 'Partner Program';
        lead2.Core_Partner_Name__c = 'TestPartner2';
        lead2.Status='PRL';
        lead2.Core_Lead_Status__c='New';
        lead2.Core_Lead_State__c='Unclaimed';
        lead2.Core_Rejection_Comments__c ='Test';
        lstLeads.add(lead2);
          
        insert lstLeads;
    }
    
    static testmethod void acceptReject_Lead_test1() {
        
        List<Lead> lstLeads = [select Id, Core_Rejection__c, Core_Rejection_Comments__c, Core_Lead_State__c from Lead];
        Test.startTest();
        String s = String.valueOf(Schema.getGlobalDescribe().get('Lead').newSObject());
        system.debug('sssssssssssssss'+s);
        Test.setMock(HttpCalloutMock.class, new Core_AcceptReject_LeadMockHttpResponse());
        Core_Reject_Lead_Controller.picklistMsgWrapper pickListVal = Core_Reject_Lead_Controller.getPicklistValuesRejection(lstLeads[0].Id,s,'Core_Rejection__c');
        pickListVal = Core_Reject_Lead_Controller.getPicklistValuesRejection(lstLeads[1].Id,s,'Core_Rejection__c');
        Core_Reject_Lead_Controller.getPicklistValues(s,'Core_Rejection__c');
        
        lstLeads[0].Core_Rejection__c = 'Bad Data';
        lstLeads[0].Core_Rejection_Comments__c = 'test';
        Core_Reject_Lead_Controller.updateToLead(lstLeads[0]);
        
        String leadsList = '[';
        for(Lead led : lstLeads){
            leadsList = leadsList + led.Id + ',';
        }
        leadsList = leadsList.removeEnd(',');
        leadsList = leadsList + ']';
        Core_Reject_Lead_Controller.rejectSelectedLeads(leadsList,'Bad Data','Test');
        Test.stopTest();
    }
    
    public class Core_AcceptReject_LeadMockHttpResponse implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test" , "values":[{"value":"test value"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
}