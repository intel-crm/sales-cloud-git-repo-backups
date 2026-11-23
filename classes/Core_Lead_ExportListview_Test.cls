@isTest
public class Core_Lead_ExportListview_Test {
    
    
    @testSetup 
    static void setup(){
        
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
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
        
        List<Lead> lstLeads = new List<Lead>();
        RecordType r1 = [Select Id from recordType where Name='Partner Lead'];
        Lead lead1 = new Lead();
        lead1.RecordTypeId = r1.Id;
        lead1.FirstName = 'Test1';
        lead1.LastName = 'Test12';
        lead1.email = 'gerald.reinartz=intel.com@example.com';
        lead1.Phone = '123 4567';
        lead1.Company = 'Test1';
        lead1.CountryCode = 'USA';
        lead1.LeadSource = 'Partner Program';
        lead1.Status='PRL';
        lead1.Core_Lead_Status__c='New';
        lead1.Core_Lead_State__c='Unclaimed';
        lead1.Core_Rejection_Comments__c ='Test';
        // lead1.PMP_MDA_BizOrg_Id__c = marketingProfile.PMP_Marketing_Profile_Id__c;
        //lead1.Core_Partner_Name__c = partnerRec.Name;
        lead1.PMP_MktProfile_BizSegment__c = 'Data Center;Client Computing';
        lead1.Core_Notify_Owner__c = true;
        lstLeads.add(lead1);
        
        Lead lead2 = new Lead();
        lead2.RecordTypeId = r1.Id;
        lead2.FirstName = 'Test12';
        lead2.LastName = 'Test123';
        lead2.email = 'qwert@gmail.com';
        lead2.Phone = '123 87345';
        lead2.Company = 'Test1qwe';
        lead2.CountryCode = 'USA';
        lead2.LeadSource = 'Partner Program';
        lead2.Status='PAL';
        lead2.Core_Lead_Status__c='Accepted';
        lead2.Core_Lead_State__c='In Persuit';
        lead2.Core_Rejection_Comments__c ='Test';
        //lead2.PMP_MDA_BizOrg_Id__c = partnerRec.Id;
        //lead2.Core_Partner_Name__c = partnerRec.Name;
        lead2.Core_Notify_Owner__c = true;
        lstLeads.add(lead2);
        
        insert lstLeads;
    }
    
    @isTest static void testExportListView(){  
        Test.StartTest();
        ListView lv = [SELECT Id, Name, DeveloperName FROM ListView  WHERE sObjectType = 'Lead' limit 1];
        Test.setMock(HttpCalloutMock.class, new Core_LeadExportListView_Mock());
        
        Core_Lead_ExportListview.listValues();
        Core_Lead_ExportListview.listViewFilter(lv.Id, 'Lead');
        Core_Lead_ExportListview.fetchKeys(lv.Id);
        Core_Lead_ExportListview.fetchRecords(lv.Id);
        
        
        Core_Lead_ExportListview.SingleColumn singleColumnInstance = new Core_Lead_ExportListview.SingleColumn();
        String ascendingLabel = singleColumnInstance.ascendingLabel;
        String descendingLabel = singleColumnInstance.descendingLabel;
        String sortDirection = singleColumnInstance.sortDirection;
        Integer sortIndex = singleColumnInstance.sortIndex;
        Boolean sortable = singleColumnInstance.sortable;
        String selectListItem = singleColumnInstance.selectListItem;    
        Boolean hidden = singleColumnInstance.hidden;
        String fieldNameOrPath = singleColumnInstance.fieldNameOrPath;             
        String type = singleColumnInstance.type;                   
        String label = singleColumnInstance.label;
        Boolean isDateType = singleColumnInstance.isDateType;
        
        Test.StopTest(); 
    }
}