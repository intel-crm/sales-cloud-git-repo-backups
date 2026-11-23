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
                                                    One of the remaining uncovered branches requires an account
                                                    with a createDate that is older that 1 minute.   :(
* Venu Karumuru             05/15/2016              Method to test the assignment of Partner Leads to correct Partner Queues
*************************************************************************************/
@isTest
public class Core_LeadHandler_Test {

    /*
     * Method name  : GeoSubgeoPopulation
     * Description  : test method to cover Core_Lead trigger
     * Return Type  : VOID
     * Parameter    : NONE
     */
    static testMethod void GeoSubgeoPopulation() {
        List<Core_Trigger_Executions__c> lstCustomSetting = new List<Core_Trigger_Executions__c>();
        List<User> lstUser = new List<User>();

        lstCustomSetting = Core_test_Utility.Core_TriggerExecution(2);
        lstCustomSetting[0].Name = 'leadObjectBeforeHandler';
        lstCustomSetting[1].Name = 'leadObjectSalesSegment';
        insert lstCustomSetting;

        Profile p1 = [SELECT Id FROM Profile WHERE Name = : System.label.Core_StandardUser];
               
        lstUser = Core_Test_Utility.Core_User(1);
        
        lstUser[0].Profileid = p1.id;

        insert lstUser;

        //Declare/Initialize the Variables
        List<Lead> lstLead = new List<Lead>();
        List<Core_Country_Reference__c> lstCS = new List<Core_Country_Reference__c> {};

        // Construct the CountryStateReference instances
        lstCS = Core_Test_Utility.Core_CountryState(1);

        for (Core_Country_Reference__c sobjCS: lstCS) {
            sobjCS.Name = 'United States';
            sobjCS.Core_Geo__c = 'ASMO';
            sobjCS.Core_Has_States__c = true;
            sobjCS.Core_ISO_Code__c = 'USA';
            sobjCS.Core_Sub_Geo__c = 'NAR';
        }

        Core_Trigger_Executions__c sobjNew = new Core_Trigger_Executions__c();
        sobjNew.Name = 'Lead Conversion';
        sobjNew.Core_Object__c = 'Change_Request__c';
        sobjNew.Core_Description__c = 'TEST';
        sobjNew.Core_Class_Name__c = 'Change_Request__c';
        sobjNew.Core_Trigger_Events__c = 'After Update';
        insert sobjNew;

        // Construct the Lead instances        
        lstLead = Core_Test_Utility.createLead(100);

        for (Lead sobjLead: lstLead) {
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

        }
        
        insert lstCS;
        
        User StandardUser = lstUser[0];
        
        System.runAs(StandardUser) {

            // Insert the intialized Lead
            insert lstLead;

            for (Lead sobjLead: lstLead) {
                System.assertEquals(sobjLead.Core_Geo__c, '');
                System.assertEquals(sobjLead.Core_Sub_Geo__c, '');

            }
        }
    }

    private static List<Lead> lstLeads {
        get;
        set;
    }
    private static List<Account> lstAccounts {
        get;
        set;
    }
    private static List<Contact> lstContacts {
        get;
        set;
    }
    
    /*
     * Method name  : setupTestData
     * Description  : Method to setup test data for Lead Conversion
     * Return Type  : None
     * Parameter    : None
     */
     
    static void setupData() {
    
        lstLeads = new List<Lead>();
        lstAccounts = new List<Account>();
        lstContacts = new List<Contact>();

        lstLeads = Core_Test_Utility.createLead(8);
        lstAccounts = Core_Test_Utility.createAccount(8);
        lstContacts = Core_Test_Utility.createContacts(8);
        
        // Insert Accounts
        for (Integer i = 0; i<lstAccounts.size(); i++) {
            lstAccounts.get(i).BillingCountryCode = 'USA';
            lstAccounts.get(i).BIllingStateCode = 'AL';
            lstAccounts.get(i).BillingCity = 'Alabama';
            lstAccounts.get(i).BillingStreet = 'test';
            lstAccounts.get(i).BillingPostalCode = '57710' + i;
            lstAccounts.get(i).Name = 'Deloitte' + i;
        }
        insert lstAccounts;
        
        // Insert Contacts
        for (Integer i = 0; i<lstContacts.size(); i++) {
            lstContacts.get(i).AccountId = lstAccounts.get(i).Id;
            lstContacts.get(i).Email = 'test' + i + '@test.com';
        }

        insert lstContacts;
        
        // Insert Leads
        for (Integer i = 0; i<lstLeads.size(); i++) {
            lstLeads.get(i).CountryCode = 'USA';
            lstLeads.get(i).StateCode = 'AL';
            lstLeads.get(i).City = 'Alabama';
            lstLeads.get(i).Street = 'test';
            lstLeads.get(i).postalCode = '577101' + i;
            lstLeads.get(i).Company = 'Deloitte' + i;
            lstleads.get(i).email = 'testnew' + i + '@test.com';

        }

        lstLeads.get(4).postalCode = '577103';
        lstLeads.get(4).email = 'test3@test.com';

        lstLeads.get(5).postalCode = '577102';
        lstLeads.get(5).company = 'Deloitte2';
        lstLeads.get(5).email = 'test1@test.com';

        lstLeads.get(6).email = 'test1@test.com';

        lstLeads.get(7).email = 'test2@test.com';

        insert lstLeads;


    }
    
     /*
     * Method name  : leadConversion
     * Description  : Method to test "Lead Conversion" functionality
     * Return Type  : None
     * Parameter    : None
     */
    static testMethod void leadConversion() {
    
        System.runAs(Core_Test_Utility.systemAdminUser) {
            setupData();
        }

        Core_Trigger_Executions__c triggerExecutionLeadConversion = new Core_Trigger_Executions__c();
        triggerExecutionLeadConversion.name = 'leadConversionDeduplication';
        triggerExecutionLeadConversion.Core_Object__c = 'Lead';
        triggerExecutionLeadConversion.Core_Active__c = TRUE;
        triggerExecutionLeadConversion.Core_Description__c = 'This is test description';
        triggerExecutionLeadConversion.Core_Class_Name__c = 'Test Class';
        triggerExecutionLeadConversion.Core_Trigger_Events__c = 'After Update';

        insert triggerExecutionLeadConversion;

        // Create a list of lead conversions, then create a leadConvert object
        // and add it to the list of lead conversions to be executed.
        List<Database.LeadConvert> leadConversions = new List<Database.LeadConvert>();

        // Get a valid lead conversion status.
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];

        Database.LeadConvert lc;

        Integer idatabaseIndex = 4;

        for (Lead LeadInstance: lstLeads) {

            lc = new database.LeadConvert();
            lc.setLeadId(LeadInstance.id);
            lc.setConvertedStatus(convertStatus.MasterLabel);
            lc.setDoNotCreateOpportunity(false);
            leadConversions.add(lc);
            idatabaseIndex++;
        }

        // Execute the conversions and check for success.
        List<Database.LeadConvertResult> results = Database.convertLead(leadConversions);

        List<Account> lstAccount = new List<Account>();
        lstAccount = [SELECT Id, (SELECT AccountId, ContactId FROM AccountContactRoles) FROM Account Where Id = : lstAccounts.get(2).Id];
        
        // [BM] 8/12/15 - exhibits a non-deterministic behavior.
        // System.assertEquals(lstAccount.get(0).AccountContactRoles.size(), 0);

    }


    /*
     * Method name  : AssignLeadsToPartnerQueues_Test
     * Description  : Method to test the assignment of Partner Leads to correct Partner Queues using the Partner Name
     * Return Type  : None
     * Parameter    : None
     */
    
    static testMethod void AssignLeadsToPartnerQueues_Test() {

        System.runAs(Core_Test_Utility.systemAdminUser) {

            // Insert a row in Trigger Execution table so the trigger to 'AssignLeadsToPartnerQueues' is executed
            Core_Trigger_Executions__c triggerSetting = new Core_Trigger_Executions__c();
            triggerSetting.name = 'AssignLeadsToPartnerQueues';
            triggerSetting.Core_Object__c = 'Lead';
            triggerSetting.Core_Active__c = TRUE;
            triggerSetting.Core_Description__c = 'This is test description';
            triggerSetting.Core_Class_Name__c = 'Core_LeadHandler';
            triggerSetting.Core_Trigger_Events__c = 'After Update';
            insert triggerSetting;
        
            // Create Parter-Queue mapping record
            Core_Partner_Queue_Mapping__c mappingRecord = new Core_Partner_Queue_Mapping__c();
            mappingRecord.Core_Partner_Name__c = 'TestPartner1';
            mappingRecord.Core_Queue_Name__c = 'Core_PTNR_TestPartner1';
            mappingRecord.Core_Active__c = true;
            insert mappingRecord;
        
            // Create a Lead Queue
            Group group1 = new Group();
            group1.Type = 'Queue';
            group1.Name = 'PTNR - TestPartner1';
            group1.DeveloperName = 'Core_PTNR_TestPartner1';
            insert group1;
            
            Queuesobject queue1 = new Queuesobject();
            queue1.SobjectType = 'Lead';
            queue1.QueueId = group1.id;
            insert queue1;
        
            // TEST1: Create a Lead that has VALID Partner Name. It Should assign the lead to the correct Partner Queue
            // Create a new lead and assign it to the Global Partner Queue
            Lead lead1 = new Lead();
            lead1.RecordTypeId = System.Label.Core_Partner_Lead_Record_Id;
            lead1.FirstName = 'Test1';
            lead1.LastName = 'Test1';
            lead1.email = 'test1@test1.com';
            lead1.Phone = '123 4567';
            lead1.Company = 'Test1';
            lead1.CountryCode = 'USA';
            lead1.LeadSource = 'Partner Program';
            lead1.Core_Partner_Name__c = 'TestPartner1'; // Valid Partner Name
            lead1.OwnerId = System.Label.Core_Partner_Global_Queue_Id;
            insert lead1;
        
            // Check the new Owner of the Lead. It should be the TestPartner1 Queue
            Lead lead1AfterAssignment = [SELECT OwnerId FROM Lead WHERE Id = :lead1.Id];
            System.assertEquals(lead1AfterAssignment.Ownerid, queue1.QueueId); 


            // TEST2: Create a Lead that has INVALID Partner Name. It Should assign the lead to Invalid Partner Queue
            // Create a new lead and assign it to the Global Partner Queue
            Lead lead2 = new Lead();
            lead2.RecordTypeId = System.Label.Core_Partner_Lead_Record_Id;
            lead2.FirstName = 'Test2';
            lead2.LastName = 'Test2';
            lead2.email = 'test2@test1.com';
            lead2.Phone = '123 4567';
            lead2.Company = 'Test2';
            lead2.CountryCode = 'USA';
            lead2.LeadSource = 'Partner Program';
            lead2.Core_Partner_Name__c = 'TestPartnerInvalid'; // Invalid Partner Name
            lead2.OwnerId = System.Label.Core_Partner_Global_Queue_Id;
            insert lead2;
        
            // Check the new Owner of the Lead. It should be the Invalid Partner Queue
            Lead lead2AfterAssignment = [SELECT OwnerId FROM Lead WHERE Id = :lead2.Id];
            System.assertEquals(lead2AfterAssignment.Ownerid, System.Label.Core_Partner_Invalid_Queue_Id); 
        }    
    }
}