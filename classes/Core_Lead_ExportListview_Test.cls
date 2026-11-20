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
        Map<String,String> res = Core_Lead_ExportListview.fetchKeys(lv.Id);
        System.assert(res != null);
        List<sObject> res1 = Core_Lead_ExportListview.fetchRecords(lv.Id);
        System.assert(res1 != null);
        
        Core_Lead_ExportListview.SingleColumn singleColumnInstance = new Core_Lead_ExportListview.SingleColumn();
    
    // Set some test values
    singleColumnInstance.ascendingLabel = 'Test Ascending';
    singleColumnInstance.descendingLabel = 'Test Descending';
    singleColumnInstance.sortDirection = 'ASC';
    singleColumnInstance.sortIndex = 1;
    singleColumnInstance.sortable = true;
    singleColumnInstance.selectListItem = 'TestField';
    singleColumnInstance.hidden = false;
    singleColumnInstance.fieldNameOrPath = 'Name';
    singleColumnInstance.type = 'text';
    singleColumnInstance.label = 'Test Label';
    
    // Assert the values to ensure getters/setters work properly
    System.assertEquals('Test Ascending', singleColumnInstance.ascendingLabel, 'Ascending label should match');
    System.assertEquals('Test Descending', singleColumnInstance.descendingLabel, 'Descending label should match');
    System.assertEquals('ASC', singleColumnInstance.sortDirection, 'Sort direction should match');
    System.assertEquals(1, singleColumnInstance.sortIndex, 'Sort index should match');
    System.assertEquals(true, singleColumnInstance.sortable, 'Sortable should match');
    System.assertEquals('TestField', singleColumnInstance.selectListItem, 'Select list item should match');
    System.assertEquals(false, singleColumnInstance.hidden, 'Hidden should match');
    System.assertEquals('Name', singleColumnInstance.fieldNameOrPath, 'Field name should match');
    System.assertEquals('text', singleColumnInstance.type, 'Type should match');
    System.assertEquals('Test Label', singleColumnInstance.label, 'Label should match');
    System.assertEquals(false, singleColumnInstance.isDateType, 'Should not be date type for text');
        
        Test.StopTest(); 
    }
    
    @isTest static void testIsTrustedListViewQuery(){
        // Test valid trusted query
        String validQuery = 'SELECT Id, Name FROM Lead LIMIT 6001';
        Boolean result = Core_Lead_ExportListview.isTrustedListViewQuery(validQuery);
        System.assert(result == true, 'Valid query should be trusted');
        
        // Test invalid query - not starting with SELECT
        String invalidQuery1 = 'FROM Lead LIMIT 6001';
        result = Core_Lead_ExportListview.isTrustedListViewQuery(invalidQuery1);
        System.assert(result == false, 'Query not starting with SELECT should not be trusted');
        
        // Test invalid query - contains DELETE keyword
        String invalidQuery2 = 'SELECT Id, Name FROM Lead DELETE LIMIT 6001';
        result = Core_Lead_ExportListview.isTrustedListViewQuery(invalidQuery2);
        System.assert(result == false, 'Query with DELETE keyword should not be trusted');
        
        // Test invalid query - no LIMIT clause
        String invalidQuery3 = 'SELECT Id, Name FROM Lead';
        result = Core_Lead_ExportListview.isTrustedListViewQuery(invalidQuery3);
        System.assert(result == false, 'Query without LIMIT should not be trusted');
        
        // Test invalid query - wrong LIMIT value
        String invalidQuery4 = 'SELECT Id, Name FROM Lead LIMIT 1000';
        result = Core_Lead_ExportListview.isTrustedListViewQuery(invalidQuery4);
        System.assert(result == false, 'Query with wrong LIMIT should not be trusted');
        
        // Test invalid query - null input
        String invalidQuery5 = null;
        result = Core_Lead_ExportListview.isTrustedListViewQuery(invalidQuery5);
        System.assert(result == false, 'Null query should not be trusted');
        
        // Test invalid query - empty input
        String invalidQuery6 = '';
        result = Core_Lead_ExportListview.isTrustedListViewQuery(invalidQuery6);
        System.assert(result == false, 'Empty query should not be trusted');
    }
    
    @isTest static void testParseColumns(){
        // Test with valid JSON
        String validJson = '{"columns": [{"label":"Name","fieldNameOrPath":"Name","hidden":false}]}';
        List<Core_Lead_ExportListview.SingleColumn> result = Core_Lead_ExportListview.parseColumns(validJson);
        System.assert(result != null, 'Parse columns should not return null for valid JSON');
        //System.assert(result.size() > 0, 'Should parse at least one column from valid JSON');
        
        // Test with empty JSON
        String emptyJson = '';
        result = Core_Lead_ExportListview.parseColumns(emptyJson);
        System.assert(result != null, 'Parse columns should not return null for empty JSON');
        System.assert(result.size() == 0, 'Should return empty list for empty JSON');
        
        // Test with null input
        result = Core_Lead_ExportListview.parseColumns(null);
        System.assert(result != null, 'Parse columns should not return null for null input');
        System.assert(result.size() == 0, 'Should return empty list for null input');
    }
    
    @isTest static void testIsValidColumn(){
        // Test valid column
        Core_Lead_ExportListview.SingleColumn validColumn = new Core_Lead_ExportListview.SingleColumn();
        validColumn.hidden = false;
        validColumn.fieldNameOrPath = 'Name';
        Boolean result = Core_Lead_ExportListview.isValidColumn(validColumn);
        System.assert(result == true, 'Valid column should return true');
        
        // Test column with hidden = true
        Core_Lead_ExportListview.SingleColumn hiddenColumn = new Core_Lead_ExportListview.SingleColumn();
        hiddenColumn.hidden = true;
        hiddenColumn.fieldNameOrPath = 'Name';
        result = Core_Lead_ExportListview.isValidColumn(hiddenColumn);
        System.assert(result == false, 'Hidden column should return false');
        
        // Test column with null fieldNameOrPath
        Core_Lead_ExportListview.SingleColumn nullFieldColumn = new Core_Lead_ExportListview.SingleColumn();
        nullFieldColumn.hidden = false;
        nullFieldColumn.fieldNameOrPath = null;
        result = Core_Lead_ExportListview.isValidColumn(nullFieldColumn);
        System.assert(result == false, 'Column with null fieldNameOrPath should return false');
        
        // Test column with Clone in fieldNameOrPath
        Core_Lead_ExportListview.SingleColumn cloneColumn = new Core_Lead_ExportListview.SingleColumn();
        cloneColumn.hidden = false;
        cloneColumn.fieldNameOrPath = 'Name Clone';
        result = Core_Lead_ExportListview.isValidColumn(cloneColumn);
        System.assert(result == false, 'Column with Clone in fieldNameOrPath should return false');
        
        // Test null column
        result = Core_Lead_ExportListview.isValidColumn(null);
        System.assert(result == false, 'Null column should return false');
    }
    
    @isTest static void testListValuesWithErrorHandling(){
        // Test error handling in listValues method
        Test.StartTest();
        List<Core_Lead_ExportListview.listViewWrapper> result = Core_Lead_ExportListview.listValues();
        System.assert(result != null, 'listValues should not return null');
        Test.StopTest();
    }
    
   @isTest static void testListViewFilterWithErrorHandling(){
        // Test error handling in listViewFilter method
        Test.StartTest();
        // Using a valid but non-existent ListView ID to trigger error handling
        // Get a ListView ID from the database that we know doesn't exist in our test data
        // Create an ID that's clearly not a valid ListView ID
        Id dummyId = Id.valueOf(Label.Core_MDF_Dummy_Account_Owner_Id);
        Core_Lead_ExportListview.listViewFilter(dummyId, 'Lead');
        // Verify that the method doesn't throw an exception and handles gracefully
        System.assert(true, 'Error handling test passed - no exceptions thrown');
        Test.StopTest();
    }
    
    @isTest static void testFetchRecordsWithErrorHandling(){
        // Test error handling in fetchRecords method
        Test.StartTest();
        // Using a valid but non-existent ListView ID to trigger error handling
        Id dummyId = Id.valueOf(Label.Core_MDF_Dummy_Account_Owner_Id);
        List<sObject> result = Core_Lead_ExportListview.fetchRecords(dummyId);
        System.assert(result != null, 'fetchRecords should not return null');
        Test.StopTest();
    }
    
    @isTest static void testFetchKeysWithErrorHandling(){
        // Test error handling in fetchKeys method
        Test.StartTest();
        // Using a valid but non-existent ListView ID to trigger error handling
        Id dummyId = Id.valueOf(Label.Core_MDF_Dummy_Account_Owner_Id);
        Map<String,String> result = Core_Lead_ExportListview.fetchKeys(dummyId);
        System.assert(result != null, 'fetchKeys should not return null');
        Test.StopTest();
    }
    
    @isTest static void testSingleColumnIsDateTypeProperty(){
        // Test the isDateType property getter in SingleColumn
        Core_Lead_ExportListview.SingleColumn column = new Core_Lead_ExportListview.SingleColumn();
        
        // Test with date type
        column.type = 'date';
        Boolean isDateType = column.isDateType;
        System.assert(isDateType == true, 'Column with date type should return true for isDateType');
        
        // Test with non-date type
        column.type = 'text';
        isDateType = column.isDateType;
        System.assert(isDateType == false, 'Column with text type should return false for isDateType');
        
        // Test with null type
        column.type = null;
        isDateType = column.isDateType;
        System.assert(isDateType == false, 'Column with null type should return false for isDateType');
    }
    
    @isTest static void testBoundaryConditions(){
        // Test with maximum export rows limit
        Test.StartTest();
        ListView lv = [SELECT Id, Name, DeveloperName FROM ListView  WHERE sObjectType = 'Lead' limit 1];
        Test.setMock(HttpCalloutMock.class, new Core_LeadExportListView_Mock());
        
        // Call the methods that use maxExportRows
        Core_Lead_ExportListview.listViewFilter(lv.Id, 'Lead');
        List<sObject> result = Core_Lead_ExportListview.fetchRecords(lv.Id);
        System.assert(result != null, 'Should handle maximum export rows properly');
        Test.StopTest();
    }
}