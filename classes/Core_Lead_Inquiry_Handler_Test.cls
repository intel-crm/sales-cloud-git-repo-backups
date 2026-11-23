@isTest
public class Core_Lead_Inquiry_Handler_Test {
    
    @testSetup 
    private static void setup(){
        System.runAs(Core_Test_Utility.systemAdminUser) {
            List<Core_Trigger_Executions__c> triggerSettingList = new List<Core_Trigger_Executions__c>();
            List<String> settingNameList = new List<String>();
            //settingNameList.add('leadObjectBeforeHandler');
            //settingNameList.add('leadObjectSalesGroup');
            //settingNameList.add('StampFieldOnReject');
            //settingNameList.add('createGroupForLeadRouting');
            //settingNameList.add('AssignLeadsToPartnerQueues');
            //settingNameList.add('FetchOfferingDetails');
            //settingNameList.add('NewPartnerLeadNotification');
            //settingNameList.add('BlockExistingOpponConversionLead');
            //settingNameList.add('leadConversionDeduplication');
            //settingNameList.add('updateInquiryOwnerOnLeadOwnerUpdate');
            //settingNameList.add('updateInquiryAccNameonLeadConversion');
            settingNameList.add('fetchCountryLabels');
            Core_Trigger_Executions__c triggerSetting;
            
            for(String settingName : settingNameList){
                triggerSetting = new Core_Trigger_Executions__c();
                triggerSetting.name = settingName;
                triggerSetting.Core_Object__c = 'Lead';
                triggerSetting.Core_Active__c = TRUE;
                triggerSetting.Core_Description__c = 'This is test description';
                triggerSetting.Core_Class_Name__c = 'Core_PartnerLeadHandler';
                triggerSetting.Core_Trigger_Events__c = 'Before Insert, Before Update, After Insert, After Update';
                triggerSettingList.add(triggerSetting);
            }
            
            insert triggerSettingList;
            
            List<Lead> lstLeads = new List<Lead>();
            List<Account> lstAccounts = new List<Account>();
            List<Contact> lstContacts = new List<Contact>();
            
            String recordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('Sales Lead').getRecordTypeId();
            
            for (integer i = 0; i <1; i++) {      
                Lead leadInstance = new Lead(); 
                leadInstance.FirstName = 'Team'+i;        
                leadInstance.lastName = 'CSot'+i;
                leadInstance.Company = 'Xcza'+i;
                leadInstance.lastName = String.valueOf(i);
                leadInstance.email = 'tes6578t@' + i + '.com';
                leadInstance.CountryCode = 'USA';
                leadInstance.StateCode = 'AL';
                leadInstance.City = 'Alabama'+i;
                leadInstance.Street = 'test'+i;
                leadInstance.status = 'Marketing Qualified Lead';
                leadInstance.leadSource = 'Email';
                leadInstance.Core_Last_Activity_Date__c = NULL;
                leadInstance.Core_Lead_Status__c='New';
                leadInstance.PostalCode = '57710'+i;
                leadInstance.Title = 'He8lo'+i;
                leadInstance.Core_Current_Architecture__c='Test';
                leadInstance.Phone='97788788'+i;
                leadInstance.Core_Product_Interest__c='10';
                leadInstance.Core_Project_Phase__c='testing';
                leadInstance.Core_Project_Size__c='4';
                leadInstance.Core_Project_Timeframe__c='12-24 Months';
                leadInstance.Core_Lead_State__c = 'In Pursuit';
                leadInstance.recordtypeid = recordTypeId ; 
                leadInstance.Core_Sales_Group__c='PRC Sales Group';
                leadInstance.Core_System_Account_Sales_Group__c='DCG Sales Group';            
                lstLeads.add(leadInstance);
            }
            
            for(integer i = 0; i <3; i++) {
                Account accountInstance = new Account();
                accountInstance.name = 'Test ' + i;
                accountInstance.BillingCountryCode = 'USA';
                accountInstance.BIllingStateCode = 'AL';
                accountInstance.BillingCity = 'Alabama';
                accountInstance.BillingStreet = 'test';
                accountInstance.Core_Sales_Groups__c='PRC Sales Group';
                lstAccounts.add(accountInstance);
            }
            Contact contactInstance;
            
            for (Integer i = 0; i <6; i++) {
                contactInstance = new Contact();
                contactInstance.FirstName = 'test';
                contactInstance.LastName = i + '';
                contactInstance.email = 'test@test' + i + '.com';
                lstContacts.add(contactInstance);
            }
            
            Id newAccountRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            // Insert Accounts
            for (Integer i = 0; i<lstAccounts.size(); i++) {
                lstAccounts[i].RecordTypeId = newAccountRecTypeId;
                lstAccounts[i].BillingCountryCode = 'USA';
                lstAccounts[i].BIllingStateCode = 'AL';
                lstAccounts[i].BillingCity = 'Alabama';
                lstAccounts[i].BillingStreet = 'test';
                lstAccounts[i].BillingPostalCode = '577100';
                lstAccounts[i].Core_Sales_Groups__c='PRC Sales Group';
                lstAccounts[i].Name = 'Deloitte' + i;
            }
            insert lstAccounts;
            
            
            // Insert Contacts
            for (Integer i = 0; i<lstContacts.size(); i++) { 
                for(Integer j = 0; j<3 ;j++){                       
                    lstContacts[i].AccountId = lstAccounts.get(j).Id;
                    lstContacts[i].Email = 'tet77st' + i + '@tes.com';
                    lstContacts[i].MailingCountry='USA';
                }
            }
            
            insert lstContacts;
            
            // Insert Leads
            for (Integer i = 0; i<lstLeads.size(); i++) {
                lstLeads[i].CountryCode = 'USA';
                lstLeads[i].StateCode = 'AL';
                lstLeads[i].City = 'Alabama';
                lstLeads[i].Street = 'te7sst';
                lstLeads[i].postalCode = '5771' + i;
                lstLeads[i].Company = 'Delitte' + i;
                lstLeads[i].email = 'test77new' + i + '@teshht.com';
                lstLeads[i].Core_Sales_Group__c='PRC Sales Group';
                lstLeads[i].Core_System_Account_Sales_Group__c = 'US Sales Group';
                lstLeads[i].Status = 'Sales Generated Lead';
                lstLeads[i].Core_Lead_Status__c = 'Accepted';    
                lstLeads[i].Core_Lead_Sub_Status__c = 'Attempting Contact';
            }
            
            insert lstLeads;
        }
    }

    //@isTest 
    /*private static void testInquiryAcctNameLeadConversion(){
        //Core_Lead_Inquiry_Handler.updateInquiryAccNameonLeadConversion(Trigger.New,Trigger.OldMap);
        List<Lead> lstLeads = [SELECT Id FROM Lead];
        List<Account> lstAccounts = [SELECT Id FROM Account];
        for(Lead leads : lstLeads){
            leads.status = 'Sales Accepted Lead';
        }
        update lstLeads;
        
        for(Lead leads : lstLeads){
            leads.Core_Lead_Status__c = 'Disqualified';
            leads.Core_Lead_Sub_Status__c = 'Not Target Profile';
        }
        update lstLeads;
        
        List<Core_Inquiry__c> inqList = new List<Core_Inquiry__c>();
        for(integer i=0;i<2;i++){
            Core_Inquiry__c inq = new Core_Inquiry__c();
            inq.Name ='TinTin1';
            inq.Core_Lead_Inquiries__c = lstLeads[0].Id;
            inq.Core_Inquiry_Type_Pkt__c ='Requested Quote';
            inqList.add(inq);
        }
        if(inqList.size()>0 && inqList!= null){
            Database.insert(inqList);
        }
        
        List<Database.LeadConvert> leadConversions = new List<Database.LeadConvert>();
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true AND MasterLabel= 'Contact - No Opportunity' LIMIT 1];
        for (Lead LeadInstance: lstLeads) {
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(LeadInstance.id);
            lc.setConvertedStatus(convertStatus.MasterLabel);
            lc.setDoNotCreateOpportunity(false);
            lc.setAccountId(lstAccounts[0].Id);
            leadConversions.add(lc);
        }
        Test.starttest();
        //List<Database.LeadConvertResult> results = Database.convertLead(leadConversions);
        Test.stoptest();        
    }
    
    @isTest 
    private static void testInquiryOwnerChange(){
        List<Lead> lstLeads = [SELECT Id FROM Lead];
        Profile p1 = [SELECT Id FROM Profile WHERE Name = : 'Sales Manager'];
        List<User> lstUser = Core_Test_Utility.Core_User(1);
        lstUser[0].Profileid = p1.id;
        insert lstUser;
        
        List<Core_Inquiry__c> inqList = new List<Core_Inquiry__c>();
        for(integer i=0;i<2;i++){
            Core_Inquiry__c inq = new Core_Inquiry__c();
            inq.Name ='TinTin1';
            inq.Core_Lead_Inquiries__c = lstLeads[0].Id;
            inq.Core_Inquiry_Type_Pkt__c ='Requested Quote';
            inqList.add(inq);
        }
        System.runAs(Core_Test_Utility.systemAdminUser) {
            if(inqList.size()>0 && inqList!= null){
                Database.insert(inqList);
            }
        }
        
        Test.starttest();
        lstLeads[0].ownerId = lstUser[0].Id;
        update lstLeads[0];                
        test.stoptest();        
    }*/

    @isTest
    public static void testUpdateCountryLabelOnLeadCountryChange(){
        
        // Create country reference record with matching ISO code
        List<Core_Country_Reference__c> countryRefList = new List<Core_Country_Reference__c>();
        Core_Country_Reference__c countryRef = new Core_Country_Reference__c();
        countryRef.Name = 'Test Country Ref';
        countryRef.Core_ISO_Code__c = 'USA';
        countryRef.Core_Geo__c = 'EMEA';
        countryRefList.add(countryRef);
        insert countryRefList;
        
        // Create a test lead with CountryCode that matches our country reference
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            CountryCode = 'USA',
            StateCode = 'AL',
            City = 'Test City',
            Street = 'Test Street',
            Status = 'Marketing Qualified Lead',
            LeadSource = 'Email',
            Email = 'test@example.com',
            PostalCode = '12345',
            Title = 'Test Title',
            Core_Current_Architecture__c = 'Test',
            Phone = '1234567890',
            Core_Product_Interest__c = '10',
            Core_Project_Phase__c = 'testing',
            Core_Project_Size__c = '4',
            Core_Project_Timeframe__c = '12-24 Months',
            Core_Lead_State__c = 'In Pursuit',
            Core_Lead_Status__c = 'New',
            Core_Sales_Group__c = 'PRC Sales Group'
           
        );
        insert testLead;
        
        // Test the method
        Test.startTest();
        Core_Lead_Inquiry_Handler.updateCountryLabelOnLeadCountryChange(new List<Lead>{testLead});
        Test.stopTest();
        
        // Verify the method worked correctly
        Lead updatedLead = [SELECT Id, CountryCode, Core_CountryLabel__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('Test Country Ref', updatedLead.Core_CountryLabel__c, 'Core_CountryLabel__c should be set to the country reference name');
    }
    
}