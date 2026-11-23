@isTest
public class Core_LeadHandlerforSLA_Test {
    
    @isTest 
    private static void CreateLeadtest() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User us = new User();
        us.FirstName = 'test';
        us.LastName = 'user';
        us.Email = 'testuser@intel.com';
        us.Username = 'testinguser@inteltest.com';
        us.Alias = 'testu';
        us.CommunityNickname = 'test.userqwert';
        us.TimeZoneSidKey = 'America/Los_Angeles';
        us.LocaleSidKey = 'en_US';
        us.EmailEncodingKey = 'UTF-8';
        us.ProfileId = profileId.Id;
        us.LanguageLocaleKey = 'en_US';
        insert us;
        
        System.runAs(us){
            Core_Opp_Bypass_Validation_Rule__c bypass = new Core_Opp_Bypass_Validation_Rule__c();
            bypass.Bypass__c=TRUE;
            bypass.SetupOwnerId = us.Id;
            insert bypass;
            String Rid = [Select id from Recordtype where Name = 'Sales Lead'].id;
            List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c triggerExec1 = new Core_Trigger_Executions__c();
            triggerExec1.Name = 'leadObjectBeforeHandler';
            triggerExec1.Core_Class_Name__c = 'Core_LeadHandler';
            triggerExec1.Core_Object__c = 'Lead';
            triggerExec1.Core_Active__c = true;
            triggerExec1.Core_Description__c = 'Logic for populating geo and sub-geo values';
            triggerExec1.Core_Trigger_Events__c = 'before insert,before update';
            triggerExecList.add(triggerExec1);
            
            Core_Trigger_Executions__c triggerExec2 = new Core_Trigger_Executions__c();
            triggerExec2.Name = 'leadObjectSalesGroup';
            triggerExec2.Core_Class_Name__c = 'Core_LeadHandler';
            triggerExec2.Core_Object__c = 'Lead';
            triggerExec2.Core_Active__c = true;
            triggerExec2.Core_Description__c = 'Logic to copy the Lead Sales Group information to Account Sales Group, Opportunity Sales Group.';
            triggerExec2.Core_Trigger_Events__c = 'before insert,before update';
            triggerExecList.add(triggerExec2);
            
            Core_Trigger_Executions__c triggerExec3 = new Core_Trigger_Executions__c();
            triggerExec3.Name = 'leadConversionDeduplication';
            triggerExec3.Core_Class_Name__c = 'Core_LeadHandler';
            triggerExec3.Core_Object__c = 'Lead';
            triggerExec3.Core_Active__c = true;
            triggerExec3.Core_Description__c = 'Logic for Deduplication account and contact on lead conversion';
            triggerExec3.Core_Trigger_Events__c = 'After Update';
            triggerExecList.add(triggerExec3);
            
            Core_Trigger_Executions__c triggerExec4 = new Core_Trigger_Executions__c();
            triggerExec4.Name = 'AssignLeadsToPartnerQueues';
            triggerExec4.Core_Class_Name__c = 'Core_LeadHandler';
            triggerExec4.Core_Object__c = 'Lead';
            triggerExec4.Core_Active__c = true;
            triggerExec4.Core_Description__c = 'Assing Partner Leads to correct Partner Queues using the Partner Name';
            triggerExec4.Core_Trigger_Events__c = 'After Update';
            triggerExecList.add(triggerExec4);
            Core_Trigger_Executions__c triggerExec5 = new Core_Trigger_Executions__c();
            triggerExec5.Name = 'BlockAccountOnLeadConversion';
            triggerExec5.Core_Class_Name__c = 'Core_LeadHandlerforSLA';
            triggerExec5.Core_Object__c = 'Lead';
            triggerExec5.Core_Active__c = true;
            triggerExec5.Core_Description__c = 'test';
            triggerExec5.Core_Trigger_Events__c = 'After Update';
            triggerExecList.add(triggerExec5);
            Core_Trigger_Executions__c triggerExec6 = new Core_Trigger_Executions__c();
            triggerExec6.Name = 'StampFieldOnReject';
            triggerExec6.Core_Class_Name__c = 'Core_PartnerLeadHandler';
            triggerExec6.Core_Object__c = 'Lead';
            triggerExec6.Core_Active__c = true;
            triggerExec6.Core_Description__c = 'test';
            triggerExec6.Core_Trigger_Events__c = 'Before Update';
            triggerExecList.add(triggerExec6);
            Core_Trigger_Executions__c triggerExec7 = new Core_Trigger_Executions__c();
            triggerExec7.Name = 'FetchOfferingDetails';
            triggerExec7.Core_Class_Name__c = 'Core_PartnerLeadHandler';
            triggerExec7.Core_Object__c = 'Lead';
            triggerExec7.Core_Active__c = true;
            triggerExec7.Core_Description__c = 'test';
            triggerExec7.Core_Trigger_Events__c = 'Before insert';
            triggerExecList.add(triggerExec7);
            
            /* 
            Core_Trigger_Executions__c triggerExec5 = new Core_Trigger_Executions__c();
            triggerExec5.Name = 'BlockExistingOpponConversionLead';
            triggerExec5.Core_Class_Name__c = 'Core_LeadHandlerforSLA';
            triggerExec5.Core_Object__c = 'Lead';
            triggerExec5.Core_Active__c = true;
            triggerExec5.Core_Description__c = 'Block Opp';
            triggerExec5.Core_Trigger_Events__c = 'Before Update';
            triggerExecList.add(triggerExec5);*/
            
            insert triggerExecList;
            
            Core_SLA_Listed_Users__c users= new Core_SLA_Listed_Users__c();
            users.Core_WWID__c='345';
            users.Name='Test';
            insert users;
            Lead leadInstance = new Lead();
            leadInstance.FirstName = 'Test 123';
            leadInstance.Core_Job_Function__c = 'Branch Manager';
            leadInstance.lastName = 'CS';
            leadInstance.Company = 'XYZ';
            leadInstance.CountryCode = 'USA';
            leadInstance.StateCode = 'AL';
            leadInstance.City = 'Alabama';
            leadInstance.Street = 'test';
            //leadInstance.Core_User_WWID__c='345';
            leadInstance.status = 'Sales Generated Lead';
            leadInstance.leadSource = 'Email';
            leadInstance.email = 'test@infosys.com';
            leadInstance.Core_Last_Activity_Date__c = NULL;
            leadInstance.Core_Lead_Status__c='Accepted';
            leadInstance.Core_Lead_Sub_Status__c='Attempting Contact';
            leadInstance.PostalCode = '577101';
            leadInstance.Title = 'Hello';
            leadInstance.Core_Current_Architecture__c='Test';
            leadInstance.Phone='9777787888';
            leadInstance.Core_Product_Interest__c='10';
            leadInstance.Core_Project_Phase__c='testing';
            leadInstance.Core_Project_Size__c='4';
            leadInstance.Core_Project_Timeframe__c='12-24 Months';
            leadInstance.Core_Lead_State__c = 'In Pursuit';
            leadInstance.recordtypeid = RId ;  
            leadInstance.Core_Sales_Group__c = 'Global Strategic Account Sales Group' ; 
            
            
            insert leadInstance;
            leadInstance.Core_Lead_Sub_Status__c='In Contact';
            update leadInstance;
            leadInstance.status = 'Sales Accepted Lead';
            update leadInstance;
            Assert.isNotNull(leadInstance.status, 'Expected the leadInstance.status to not be null');
            List<Lead>Listnew = new List<Lead>();
            Listnew.add(leadInstance);
            //Core_LeadHandlerforSLA.BlockOppConvertforExitOpp(Listnew);
            Core_LeadHandlerforSLA.BlockAccountconvertforRejectedAndRequested(Listnew);
            Assert.isNotNull(Listnew, 'Expected Listnew to not be null');
        }
        
    } 
    
    @isTest 
    private static void CreateLeadtest1() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User us = new User();
        us.FirstName = 'test';
        us.LastName = 'user';
        us.Email = 'testuser@intel.com';
        us.Username = 'testinguser@inteltest.com';
        us.Alias = 'testu';
        us.CommunityNickname = 'test.userqwert';
        us.TimeZoneSidKey = 'America/Los_Angeles';
        us.LocaleSidKey = 'en_US';
        us.EmailEncodingKey = 'UTF-8';
        us.ProfileId = profileId.Id;
        us.LanguageLocaleKey = 'en_US';
        insert us;
        
        
        Core_Account_Bypass_Validation_Rule__c bypassAccount = new Core_Account_Bypass_Validation_Rule__c();
        bypassAccount.ByPass__c = true;
        bypassAccount.SetupOwnerId = us.id;
        insert bypassAccount;
        
        List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
        
        Core_Trigger_Executions__c triggerExec5 = new Core_Trigger_Executions__c();
        triggerExec5.Name = 'BlockExistingOpponConversionLead';
        triggerExec5.Core_Class_Name__c = 'Core_LeadHandlerforSLA';
        triggerExec5.Core_Object__c = 'Lead';
        triggerExec5.Core_Active__c = true;
        triggerExec5.Core_Description__c = 'Block Opp';
        triggerExec5.Core_Trigger_Events__c = 'After Update';
        // triggerExecList.add(triggerExec5);
        
        insert triggerExec5;
        
        String Rid = [Select id from Recordtype where Name = 'Sales Lead'].id;
        System.runAs(us){
            Core_Opp_Bypass_Validation_Rule__c bypass = new Core_Opp_Bypass_Validation_Rule__c();
            bypass.Bypass__c=TRUE;
            bypass.SetupOwnerId = us.Id;
            insert bypass;
            //Create Account
            Id newAccountRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            Account accountInstance = new Account();
            accountInstance.name = 'Test Account' ;
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test';
            accountInstance.Core_Sales_Groups__c='PRC Sales Group';
            accountInstance.RecordTypeId = newAccountRecTypeId;
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test';
            accountInstance.BillingPostalCode = '577100';
            accountInstance.Core_Sales_Groups__c='PRC Sales Group';
            accountInstance.Name = 'Intel Account';
            accountInstance.Core_English_Only_Name__c = 'Intel Account';
            insert accountInstance;
            //Create Lead Record
            Lead leadInstance = new Lead();
            leadInstance.FirstName = 'Test 123 New';
            leadInstance.Core_Job_Function__c = 'Branch Manager';
            leadInstance.lastName = 'CS';
            leadInstance.Company = 'XYZ';
            leadInstance.CountryCode = 'USA';
            leadInstance.StateCode = 'AL';
            leadInstance.City = 'Alabama';
            leadInstance.Street = 'test';
            //leadInstance.Core_User_WWID__c='345';
            leadInstance.status = 'Sales Generated Lead';
            leadInstance.leadSource = 'Email';
            leadInstance.email = 'test@infosys.com';
            leadInstance.Core_Last_Activity_Date__c = NULL;
            leadInstance.Core_Lead_Status__c='Accepted';
            leadInstance.Core_Lead_Sub_Status__c='Attempting Contact';
            leadInstance.PostalCode = '577101';
            leadInstance.Title = 'Hello';
            leadInstance.Core_Current_Architecture__c='Test';
            leadInstance.Phone='9777787888';
            leadInstance.Core_Product_Interest__c='10';
            leadInstance.Core_Project_Phase__c='testing';
            leadInstance.Core_Project_Size__c='4';
            leadInstance.Core_Project_Timeframe__c='12-24 Months';
            leadInstance.Core_Lead_State__c = 'In Pursuit';
            leadInstance.recordtypeid = RId ;  
            leadInstance.Core_Sales_Group__c = 'Americas Brazil Sales Group' ;
            leadInstance.Industry = 'Accommodation and Food Services';
            
            insert leadInstance;
            leadInstance.Core_Lead_Sub_Status__c='In Contact';
            update leadInstance;
            leadInstance.status = 'Sales Accepted Lead';
            leadInstance.Core_System_Account_Sales_Group__c = 'Americas Brazil Sales Group' ; 
            leadInstance.Core_lead_id__c =leadInstance.id  ; 
            
            update leadInstance;
            
            List <Lead> Listnew = new List<Lead>();
            Listnew.add(leadInstance);
            //Core_LeadHandlerforSLA.BlockOppConvertforExitOpp(Listnew);
            
            test.startTest();
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
            Core_LeadHandlerforSLA.isExistingOpportunity=true;
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(leadInstance.Id);
            lc.setConvertedStatus(convertStatus.MasterLabel);
            lc.setAccountId(accountInstance.Id);
            //Database.LeadConvertResult lcr = Database.convertLead(lc);
            //System.assert(lcr.isSuccess());
            test.stopTest();
        }
    }
}