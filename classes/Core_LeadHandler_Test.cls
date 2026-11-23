/**************************************************************************************
Apex Class Name:  Core_LeadHandler_Test
Version     : 1.0 
Created Date: 06 OCT 2014
Function    : Test Class for the Core_Lead trigger
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             10/06/2014              Original Version
* Kunal Mehta               12/01/2014              Test class update for scenarios
* Harshith M L              12/23/2014              Test Class for Lead Conversion
* Harshith M L              12/23/2014              Test Class for Lead Conversion
* Srikant Joshi             19/02/2014              Modified the code to fetch only 1 user
* Brian Matthews            08/10/2015              Will have to leave this at 81% coverage (up from 45%)
* Bishal Singh				10/12/2024				Refactored whole test class and move test coverage to 83% for ATHR Fixes
One of the remaining uncovered branches requires an account
with a createDate that is older that 1 minute.   :( --> Got Covered - Thanks me Later - Bishal
* Venu Karumuru             05/15/2016              Method to test the assignment of Partner Leads to correct Partner Queues
*************************************************************************************/
@isTest
public class Core_LeadHandler_Test {
    
    @testSetup 
    private static void setup(){
        User u = SWS_TestUtilty.createUser();
        PermissionSet permissionRec = [SELECT Id,Name FROM PermissionSet WHERE Name = 'PSG_Master_Data_Read_Write_Access' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = permissionRec.Id);
        System.runAs(u){
            List<String> triggerExecutionStringList = new List<String>();
            triggerExecutionStringList.add('leadObjectBeforeHandler');
            triggerExecutionStringList.add('leadObjectSalesGroup');
            triggerExecutionStringList.add('leadConversionDeduplication');
            List<Core_Trigger_Executions__c> lstCustomSetting = new List<Core_Trigger_Executions__c>();
            for(String triggerExection :  triggerExecutionStringList){
                Core_Trigger_Executions__c triggerExecutionLead = new Core_Trigger_Executions__c();
                triggerExecutionLead.name = triggerExection;
                triggerExecutionLead.Core_Object__c = 'Lead';
                triggerExecutionLead.Core_Active__c = TRUE;
                triggerExecutionLead.Core_Description__c = 'This is test description';
                triggerExecutionLead.Core_Class_Name__c = 'Core_LeadHandler_Test';
                triggerExecutionLead.Core_Trigger_Events__c = 'After Update';
                lstCustomSetting.add(triggerExecutionLead);
            }
            insert lstCustomSetting;
            
            List<Core_Country_Reference__c> lstCS = Core_Test_Utility.Core_CountryState(1);
            for (Core_Country_Reference__c sobjCS: lstCS) {
                sobjCS.Name = 'United States';
                sobjCS.Core_Geo__c = 'ASMO';
                sobjCS.Core_Has_States__c = true;
                sobjCS.Core_ISO_Code__c = 'USA';
                sobjCS.Core_Sub_Geo__c = 'NAR';
            }
            
            insert lstCS;
            
            List<Account> lstAccounts = new List<Account>{SWS_TestUtilty.createAccount()};
                List<Contact> lstContacts = Core_Test_Utility.createContacts(1);
            
            for (Integer i = 0; i<lstContacts.size(); i++) {
                lstContacts.get(i).AccountId = lstAccounts.get(i).Id;
                lstContacts.get(i).Email = 'test' + i + '@test.com';
                lstContacts.get(i).MailingCountry='USA';
            }
            
            String SalesleadRectypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Lead').getRecordTypeId();
            List<Lead> lstLeads = Core_Test_Utility.createLead(1);
            for (Lead sobjLead: lstLeads) {
                sobjLead.RecordTypeId = SalesleadRectypeId;
                sobjLead.Core_Lead_Status__c = 'Accepted';
                sobjLead.Core_Lead_State__c = 'Terminated';
                sobjLead.Core_lead_Id__c = 'TestingAdded';
                sobjLead.Status = 'Marketing Qualified Lead';
                sobjLead.Core_Lead_Status__c='New';
            }
            insert lstLeads;            
        }
    }
    
    @isTest 
    private static void beforeInsertBeforeUpdateTest(){
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u){
            Test.startTest();
            List<Lead> lstLead = Core_Test_Utility.createLead(1);
            String SalesleadRectypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Lead').getRecordTypeId();
            for (Lead sobjLead: lstLead) {
                sobjLead.RecordTypeId = SalesleadRectypeId;
                sobjLead.Email='avoidduplicatetest@gmail.com';
                sobjLead.Core_Geo__c = '';
                sobjLead.Core_Sub_Geo__c = '';
                sobjLead.Phone = '(555) 555-5555';
                sobjLead.Title = '(555) 555-5555';
                sobjLead.Core_Current_Architecture__c = '(555) 555-5555';
                sobjLead.Core_Job_Function__c = '(555) 555-5555';
                sobjLead.Core_Product_Interest__c = '(555) 555-5555';
                sobjLead.Core_Project_Phase__c = '(555) 555-5555';
                sobjLead.Core_Project_Size__c = '555';
                sobjLead.Core_Project_Timeframe__c = '555';
                sobjLead.Core_Sales_Segment__c = '555';
                sobjLead.PostalCode = '560035';
                sobjLead.Status='Marketing Qualified Lead';
                sobjLead.Core_Lead_Status__c='New';
            }
            insert lstLead;
            Test.stopTest();

            // Assert that leads were inserted and have expected values
            List<Lead> leads = [SELECT Id, Core_Geo__c, Core_Sub_Geo__c FROM Lead WHERE Id IN :lstLead];
            System.assertEquals(1, leads.size(), '1 lead should be inserted');
            for (Lead l : leads) {
                System.assertNotEquals(null, l.Id, 'Lead Id should not be null');
            }
        }
    }
    
    @isTest 
    private static void leadConversionDeduplicationTest(){
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u){
            
            List<Lead> lstLeads = [SELECT Id FROM Lead];
            for (Lead LeadInstance: lstLeads) {
                LeadInstance.Core_Lead_Status__c = 'Qualified';
                LeadInstance.Core_Lead_Sub_Status__c = 'In Contact';
                LeadInstance.Phone='2396189672';
            }
            update lstLeads;
            for (Lead LeadInstance: lstLeads) {
                LeadInstance.Status = 'Sales Accepted Lead';
            }
            update lstLeads;
            
            List<Account> lstAccounts = Core_Test_Utility.createAccount(2);            
            List<Contact> lstContacts = Core_Test_Utility.createContacts(2);
            for(Account acc: lstAccounts){
                acc.BillingStreet = 'G-2101TexasUSA577101';
                acc.Core_Address_Details__c = 'G-2101TexasUSA577101';
            }
            
            insert lstAccounts;
            for (Integer i = 0; i<lstContacts.size(); i++) {
                lstContacts.get(i).AccountId = lstAccounts[0].Id;
                lstContacts.get(i).Email = 'test@test.com';
                lstContacts.get(i).MailingCountry='USA';
            }
            
            insert lstContacts;
            
            Id newOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
            Id newOppRecTypeIddesign = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
            List<Opportunity> opptyList = new List<Opportunity>();
            opptyList.add(new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, Core_Opportunity_Coverage_Nm__c= 'Partner-Led Opportunity', Core_Coverage_Type_Nm__c= 'Deal Registration',
                                          AccountId = lstAccounts[0].Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = u.Id, Core_Sales_Group__c='Global Accounts', Core_Commissionable__c ='No', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c = 'Storage', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='ALDER LAKE D', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8), Core_Solution_Area__c='DCG Compute Deal $'));
            insert opptyList;
            
            Test.startTest();
            
            List<Database.LeadConvert> leadConversions = new List<Database.LeadConvert>();
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true AND MasterLabel LIKE 'Sales Qualified Lead' LIMIT 1];
            for (Lead LeadInstance: lstLeads) {
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(LeadInstance.id);
                lc.setAccountId(lstAccounts[1].Id);
                lc.setContactId(lstContacts[0].Id);
                lc.setOpportunityId(opptyList[0].Id);
                lc.setConvertedStatus(convertStatus.MasterLabel); 
                leadConversions.add(lc);
            }
            List<Database.LeadConvertResult> results = Database.convertLead(leadConversions);
            Test.stopTest();

            // Assert all leads were converted successfully
            for (Database.LeadConvertResult res : results) {
                System.assert(res.isSuccess(), 'Lead conversion should be successful');
                System.assertNotEquals(null, res.getAccountId(), 'Converted AccountId should not be null');
                System.assertNotEquals(null, res.getContactId(), 'Converted ContactId should not be null');
            }
        }
    }
    
    @isTest 
    private static void leadConversionDeduplicationSecondTest(){
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u){
            List<Lead> lstLeads = [SELECT Id FROM Lead];
            for (Lead LeadInstance: lstLeads) {
                LeadInstance.Core_Lead_Status__c = 'Qualified';
                LeadInstance.Core_Lead_Sub_Status__c = 'In Contact';
                LeadInstance.Phone='2396189672';
            }
            update lstLeads;
            for (Lead LeadInstance: lstLeads) {
                LeadInstance.Status = 'Sales Accepted Lead';
            }
            update lstLeads;
            
            List<Account> lstAccounts = new List<Account>{SWS_TestUtilty.createAccount()};
                System.assertEquals(1, lstAccounts.size());
            lstAccounts.add(SWS_TestUtilty.createAccount());
            
            List<Contact> lstContacts = Core_Test_Utility.createContacts(2);
            
            for(Account acc: lstAccounts){
                Test.setCreatedDate(acc.Id, DateTime.newInstance(2012,12,12));
            }
            
            for (Integer i = 0; i<lstContacts.size(); i++) {
                lstContacts.get(i).AccountId = lstAccounts.get(i).Id;
                lstContacts.get(i).Email = 'test@test.com';
                lstContacts.get(i).MailingCountry='USA';
            }
            
            insert lstContacts;
            
            
            Test.startTest();
            
            List<Database.LeadConvert> leadConversions = new List<Database.LeadConvert>();
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true AND MasterLabel LIKE 'Sales Qualified Lead' LIMIT 1];
            for (Lead LeadInstance: lstLeads) {
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(LeadInstance.id);
                lc.setAccountId(lstAccounts[0].Id);
                lc.setContactId(lstContacts[0].Id);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                leadConversions.add(lc);
            }
            List<Database.LeadConvertResult> results = Database.convertLead(leadConversions);
            Test.stopTest();

            // Assert all leads were converted successfully
            for (Database.LeadConvertResult res : results) {
                System.assert(res.isSuccess(), 'Lead conversion should be successful');
                System.assertNotEquals(null, res.getAccountId(), 'Converted AccountId should not be null');
                System.assertNotEquals(null, res.getContactId(), 'Converted ContactId should not be null');
            }
        }
    }
    
    @isTest 
    private static void leadConversionDeduplicationThirdTest(){
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u){
            List<Lead> lstLeads = [SELECT Id FROM Lead];
            for (Lead LeadInstance: lstLeads) {
                LeadInstance.Core_Lead_Status__c = 'Qualified';
                LeadInstance.Core_Lead_Sub_Status__c = 'In Contact';
                LeadInstance.Phone='2396189672';
            }
            update lstLeads;
            for (Lead LeadInstance: lstLeads) {
                LeadInstance.Status = 'Sales Accepted Lead';
                LeadInstance.Company = 'Intel 10';
            }
            update lstLeads;
            
            List<Account> lstAccounts = Core_Test_Utility.createAccount(2);
            List<Contact> lstContacts = Core_Test_Utility.createContacts(2);
            Integer j = 0;
            for(Account acc: lstAccounts){
                acc.BillingCountryCode = 'USA';
                acc.BIllingStateCode = 'AL';
                acc.BillingCity = 'Alabama';
                acc.BillingStreet = 'test';
                acc.BillingPostalCode = '57710' + j;
                acc.Name = 'Intel' + j;
                j++;
            }
            j=0;
            insert lstAccounts;
            
            List<Account> duplstAccounts = Core_Test_Utility.createAccount(2);
            List<Contact> duplstContacts = Core_Test_Utility.createContacts(2);
            
            for(Account acc: duplstAccounts){
                acc.BillingCountryCode = 'USA';
                acc.BIllingStateCode = 'AL';
                acc.BillingCity = 'Alabama';
                acc.BillingStreet = 'test';
                acc.BillingPostalCode = '57710' + j;
                acc.Name = 'Intel 1' + j;
                j++;
            }
            
            insert duplstAccounts;
            
            for (Integer i = 0; i<lstContacts.size(); i++) {
                lstContacts.get(i).AccountId = lstAccounts[0].Id;
                lstContacts.get(i).Email = 'test@test.com';
                lstContacts.get(i).MailingCountry='USA';
            }
            
            insert lstContacts;
            
            for (Integer i = 0; i<duplstContacts.size(); i++) {
                duplstContacts.get(i).AccountId = duplstAccounts[i].Id;
                duplstContacts.get(i).Email = 'tes1t@test.com';
                duplstContacts.get(i).MailingCountry='USA';
            }
            
            insert duplstContacts;
            
            Test.startTest();
            
            List<Database.LeadConvert> leadConversions = new List<Database.LeadConvert>();
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true AND MasterLabel LIKE 'Sales Qualified Lead' LIMIT 1];
            for (Lead LeadInstance: lstLeads) {
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(LeadInstance.id);
                lc.setAccountId(lstAccounts[0].Id);
                lc.setContactId(lstContacts[0].Id);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                leadConversions.add(lc);
            }
            List<Database.LeadConvertResult> results = Database.convertLead(leadConversions);
            Test.stopTest();

            // Assert all leads were converted successfully
            for (Database.LeadConvertResult res : results) {
                System.assert(res.isSuccess(), 'Lead conversion should be successful');
                System.assertNotEquals(null, res.getAccountId(), 'Converted AccountId should not be null');
                System.assertNotEquals(null, res.getContactId(), 'Converted ContactId should not be null');
            }
        }
    }
    
    @isTest
    private static void AssignLeadsToPartnerQueuesTest(){
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u){
            Core_Partner_Queue_Mapping__c mappingRecord = new Core_Partner_Queue_Mapping__c();
            mappingRecord.Core_Partner_Name__c = 'TestPartner1';
            mappingRecord.Core_Queue_Name__c = 'Core_PTNR_TestPartner1';
            mappingRecord.Core_Active__c = true;
            insert mappingRecord;
            
            Group group1 = new Group();
            group1.Type = 'Queue';
            group1.Name = 'PTNR - TestPartner1';
            group1.DeveloperName = 'Core_PTNR_TestPartner1';
            insert group1;
            
            Queuesobject queue1 = new Queuesobject();
            queue1.SobjectType = 'Lead';
            queue1.QueueId = group1.id;
            insert queue1;
            
            Test.startTest();
            List<Lead> lstLead = Core_Test_Utility.createLead(10);
            for (Lead sobjLead: lstLead) {
                sObjLead.RecordTypeId = System.Label.Core_Partner_Lead_Record_Id;
                sObjLead.Core_Partner_Name__c = 'TestPartner1';
                sobjLead.Core_Geo__c = '';
                sobjLead.Core_Sub_Geo__c = '';
                sobjLead.Phone = '(555) 555-5555';
                sobjLead.Title = '(555) 555-5555';
                sobjLead.Core_Current_Architecture__c = '(555) 555-5555';
                sobjLead.Core_Job_Function__c = '(555) 555-5555';
                sobjLead.Core_Product_Interest__c = '(555) 555-5555';
                sobjLead.Core_Project_Phase__c = '(555) 555-5555';
                sobjLead.Core_Project_Size__c = '555';
                sobjLead.Core_Project_Timeframe__c = '555';
                sobjLead.Core_Sales_Segment__c = '555';
                sobjLead.PostalCode = '560035';
                sobjLead.Status='Marketing Qualified Lead';
                sobjLead.OwnerId = System.Label.Core_Partner_Global_Queue_Id;
            }
            insert lstLead;
            Core_LeadHandler.AssignLeadsToPartnerQueues(lstLead);
            Test.stopTest();

            // Assert that leads are now assigned to the correct queue
            List<Lead> updatedLeads = [SELECT Id, OwnerId FROM Lead WHERE Id IN :lstLead];
            for (Lead l : updatedLeads) {
                System.assertNotEquals(System.Label.Core_Partner_Global_Queue_Id, l.OwnerId, 'Lead OwnerId should be updated from global queue');
            }
        }
    }
    @isTest 
    private static void convertLead_Succeeds_WithPrereqsAndLinks_AssertResults(){
        // Covers Core_LeadHandler convertLead path with asserts
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u){
            // Prepare one Lead and set prerequisites
            List<Lead> leads = [SELECT Id, Status, Core_Lead_Status__c, Core_Lead_Sub_Status__c FROM Lead LIMIT 1];
            if (leads.isEmpty()) {
                // Create one if test setup didn't insert
                Lead l = Core_Test_Utility.createLead(1)[0];
                insert l;
                leads = new List<Lead>{ l };
            }
            Lead l0 = leads[0];

            // First transaction: prerequisite fields
            l0.Core_Lead_Status__c = 'Qualified';
            l0.Core_Lead_Sub_Status__c = 'In Contact';
            l0.Phone='2396189672';
            update l0;

            Lead afterPrereq = [SELECT Id, Core_Lead_Status__c, Core_Lead_Sub_Status__c FROM Lead WHERE Id = :l0.Id];
            System.assertEquals('Qualified', afterPrereq.Core_Lead_Status__c, 'convertLead prereq: Core_Lead_Status__c');
            System.assertEquals('In Contact', afterPrereq.Core_Lead_Sub_Status__c, 'convertLead prereq: Core_Lead_Sub_Status__c');

            // Second transaction: move Status
            l0 = [SELECT Id, Status FROM Lead WHERE Id = :l0.Id];
            l0.Status = 'Sales Accepted Lead';
            update l0;

            Lead afterStatus = [SELECT Id, Status FROM Lead WHERE Id = :l0.Id];
            System.assertEquals('Sales Accepted Lead', afterStatus.Status, 'convertLead prereq: Status');

            // Prepare related records
            Account acc = Core_Test_Utility.createAccount(1)[0];
            insert acc;
            Contact con = Core_Test_Utility.createContacts(1)[0];
            con.AccountId = acc.Id;
            con.MailingCountry= 'IND';
            insert con;

            Id dealRt = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
            Opportunity opp = new Opportunity(Name='ConvLead_Opp', AccountId=acc.Id, RecordTypeId=dealRt, StageName='Qualify', CloseDate=Date.today().addDays(10));
            insert opp;

             Test.startTest();
            // Build request per Core_LeadHandler.convertLead signature
            SWS_LeadWrappers.LeadConvertRequest req = new SWS_LeadWrappers.LeadConvertRequest();
            req.leadId = l0.Id;
            req.contactId = con.Id;
            Core_LeadHandler.convertLead(new List<SWS_LeadWrappers.LeadConvertRequest>{ req });
            Test.stopTest();

            Lead converted = [SELECT Id, IsConverted, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId FROM Lead WHERE Id = :l0.Id LIMIT 1];
        }
    }
}