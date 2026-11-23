/**************************************************************************************
Apex Class Name:  Core_AcceptReject_Lead_LexCon_test
Version     : 1.0 
Created Date: 19 Jun 2018
Function    : Test Class for Core_AcceptReject_Lead_LexController
Modification Log :
* Developer                       Date                    Description
* ----------------------------------------------------------------------------                 
* Ragamalika Mohanraj             19/06/2018              Original Version
* Sougata Sarkar                  19/06/2018              Updated Version
*************************************************************************************/
@isTest
public class Core_AcceptReject_Lead_LexCon_test{
    
    @testSetup 
    static void setup(){
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User us = new User();
        us.FirstName = 'test';
        us.LastName = 'user';
        us.Email = 'testuser@intel.com';
        us.Username = 'testinguser@inteltest.com';
        us.Alias = 'testu';
        us.CommunityNickname = 'test.user';
        us.TimeZoneSidKey = 'America/Los_Angeles';
        us.LocaleSidKey = 'en_US';
        us.EmailEncodingKey = 'UTF-8';
        us.ProfileId = profileId.Id;
        us.LanguageLocaleKey = 'en_US';
        insert us;
        Core_Opp_Bypass_Validation_Rule__c bypass = new Core_Opp_Bypass_Validation_Rule__c();
        bypass.Bypass__c=TRUE;
        insert bypass;
        
        List<Lead> lstLeads = new List<Lead>();
        RecordType LeadrecordType = [SELECT Id FROM RecordType where name = 'Lead'];        
        Lead lead1 = new Lead();
        lead1.RecordTypeId = LeadrecordType.id;
        lead1.FirstName = 'Test1';
        lead1.LastName = 'Test12';
        lead1.email = 'gerald.reinartz=intel.com@example.com';
        lead1.Phone = '123 4567';
        lead1.Company = 'Test1';
        lead1.CountryCode = 'USA';
        lead1.LeadSource = 'Partner Program';
        lead1.Core_Partner_Name__c = 'TestPartner1';
        lead1.Status='Marketing Qualified Lead';
        lead1.Core_Lead_Status__c = 'New';
        lead1.Core_Rejection_Comments__c ='Test';
        lstLeads.add(lead1);
        RecordType PartnerLeadrecordType = [SELECT Id, Name FROM RecordType where name = 'Partner Lead'];         
        Lead lead2 = new Lead();
        lead2.RecordTypeId = PartnerLeadrecordType.id;
        lead2.FirstName = 'Test12';
        lead2.LastName = 'Test123';
        lead2.email = 'geral.reinartz=intel.com@example.com';
        lead2.Phone = '123 4567';
        lead2.Company = 'Test1';
        lead2.CountryCode = 'USA';
        lead2.LeadSource = 'Partner Program';
        lead2.Core_Partner_Name__c = 'TestPartner2';
        lead2.Status='Tele Accepted Prospect';
        lead2.Core_Rejection_Comments__c ='Test';
        lstLeads.add(lead2);
        
        Lead lead3 = new Lead();
        lead3.RecordTypeId = LeadrecordType.id;
        lead3.FirstName = 'Test123';
        lead3.LastName = 'Test1234';
        lead3.email = 'gera.reinartz=intel.com@example.com';
        lead3.Phone = '123 4567';
        lead3.Company = 'Test1';
        lead3.CountryCode = 'USA';
        lead3.LeadSource = 'Partner Program';
        lead3.Core_Partner_Name__c = 'TestPartner2';
        lead3.Status='Tele Accepted Prospect';
        lead3.Core_Rejection_Comments__c ='Test';
        lstLeads.add(lead3);
        
        Lead lead4 = new Lead();
        lead4.RecordTypeId = PartnerLeadrecordType.id;
        lead4.FirstName = 'Test1';
        lead4.LastName = 'Test50';
        lead4.email = 'gerald.reinartz=intel.com@example.com';
        lead4.Phone = '123 4567';
        lead4.Company = 'Test1';
        lead4.CountryCode = 'USA';
        lead4.LeadSource = 'Partner Program';
        lead4.Core_Partner_Name__c = 'TestPartner1';
        lead4.Status='Tele Accepted Prospect';
        lead4.Core_Rejection_Comments__c ='Test';
        lead4.OwnerId = us.Id;
        lstLeads.add(lead4);
        
        Lead lead5 = new Lead();
        lead5.RecordTypeId = PartnerLeadrecordType.id;
        lead5.FirstName = 'Test12';
        lead5.LastName = 'Test123';
        lead5.email = 'geral.reinartz=intel.com@example.com';
        lead5.Phone = '123 4567';
        lead5.Company = 'Test1';
        lead5.CountryCode = 'USA';
        lead5.LeadSource = 'Partner Program';
        lead5.Core_Partner_Name__c = 'TestPartner2';
        lead5.Status='Tele Accepted Prospect';
        lead5.Core_Rejection_Comments__c ='Test';
        lead5.OwnerId = us.Id;
        lstLeads.add(lead5);
        
        insert lstLeads;
    }
    
    static testmethod void acceptReject_Lead_test1() {
        
        List<Lead> lstLeads = [select Id, Core_Rejection__c, Core_Rejection_Comments__c, Core_Lead_State__c from Lead];
        Test.startTest();
        String s = String.valueOf(Schema.getGlobalDescribe().get('Lead').newSObject());
        Test.setMock(HttpCalloutMock.class, new Core_AcceptReject_LeadMockHttpResponse());
        Core_AcceptReject_Lead_LexController.picklistMsgWrapper pickListVal = Core_AcceptReject_Lead_LexController.getPicklistValues(lstLeads[0].Id,s,'Core_Lead_Priority__c');
        pickListVal = Core_AcceptReject_Lead_LexController.getPicklistValues(lstLeads[3].Id,s,'Core_Lead_Priority__c');
        pickListVal = Core_AcceptReject_Lead_LexController.getPicklistValues(lstLeads[2].Id,s,'Core_Lead_Priority__c');
        pickListVal = Core_AcceptReject_Lead_LexController.getPicklistValues(lstLeads[4].Id,s,'Core_Lead_Priority__c');
        pickListVal = Core_AcceptReject_Lead_LexController.getPicklistValues(lstLeads[1].Id,s,'Core_Lead_Priority__c');
        
        Core_AcceptReject_Lead_LexController.updateLead(lstLeads[0].Id);
        Core_AcceptReject_Lead_LexController.updateTeleQualifiedLead(lstLeads[0].Id);
        Core_AcceptReject_Lead_LexController.updateLead(lstLeads[1].Id);
        Core_AcceptReject_Lead_LexController.updateTeleQualifiedLead(lstLeads[1].Id);
        Core_AcceptReject_Lead_LexController.updateLead(lstLeads[2].Id);
        Core_AcceptReject_Lead_LexController.updateTeleQualifiedLead(lstLeads[2].Id);
        Core_AcceptReject_Lead_LexController.updateToLead(lstLeads[0]);
        
        Test.stopTest();
    }
    
    public class Core_AcceptReject_LeadMockHttpResponse implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"values":[{"attributes":null,"label":"Hot","validFor":[],"value":"Hot"},{"attributes":null,"label":"Warm","validFor":[],"value":"Warm"},{"attributes":null,"label":"Cold","validFor":[],"value":"Cold"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
}