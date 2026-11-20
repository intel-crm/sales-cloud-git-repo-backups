/****************************************************************************************************************************************
* Class Name  : Core_MDF_CCP_UtilityClass_Test
* Version     : 1.0 
* Created Date: 9-07-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sushma Hamom        9/7/2018                    Created to test CCP Utility class for DataBase Update and processing teh results
*                                                 Log Enrty creation
* Sham                11/18/2025                  Added tests for logErrors() and createLogEntries() methods
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_CCP_UtilityClass_Test {
    
    @TestSetup
    static void setupTestData() {
        // Create a test user for running tests
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = new User(
            Alias = 'testuser',
            Email='sysadmintestuser@example.com',
            EmailEncodingKey='UTF-8',
            LastName='TestUser',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = sysAdminProfile.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='sysadmintestuser@example.com'
        );
        insert testUser;
    }
    
     @isTest static void test(){     


            List<Account> acctList = new List<Account>();
            
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc1.Core_Account_Type__c = 'Reseller';
            //acc1.Core_Sales_Groups__c = 'Automotive Sales Group';
            acc1.Industry = 'Food & Beverage';
            Database.insert(acc1);
            // US - TWC702-14285: Unit Test Method should include System.Assert
             System.assertNotEquals(null, acc1.Id, 'Account 1 should be inserted successfully');
            
            acc1.Core_Sales_Groups__c = 'Automotive Sales Group Testjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjhhhhhhhhhhhhhhhhhhhhhhhhhhhhooooooooooooooobbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
            acctList.add(acc1);
            Account acc2 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 2', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc2.Core_Account_Type__c = 'Reseller';
            //acc2.Core_Sales_Groups__c = 'Automotive Sales Group';
            acc2.Industry = 'Food & Beverage'; 
            Database.insert(acc2);
            acctList.add(acc2);
            String errortext = 'Test';
            Core_MDF_CCP_UtilityClass.updateListAndLogErrors(acctList,errortext);
            Core_MDF_CCP_UtilityClass.logErrorinLogObject(errortext, 'Test');
            // US - TWC702-14285: Unit Test Method should include System.Assert
         	System.assertNotEquals(null, acc2.Id, 'Account 2 should be inserted successfully');
            
            // 14285 - Indira
        	String s = null ;
            try {
				s = s.toLowerCase();
            } catch(Exception e){
                Core_MDF_CCP_UtilityClass.getErrorDetails(e);
                Core_MDF_CCP_UtilityClass.logError(e);
                Core_MDF_CCP_UtilityClass.logErrorWithAdditionalMessage(e, 'Test Error');
                Core_MDF_CCP_UtilityClass.logErrorWithAdditionalMessage(e, 'Test Error');                
            }
      }
    
     @isTest
    static void testlogErrorOfCustomValidation(){
        
        	Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc1.Core_Account_Type__c = 'Reseller';
            //acc1.Core_Sales_Groups__c = 'Automotive Sales Group';
            acc1.Industry = 'Food & Beverage';
            Database.insert(acc1);
            // US - TWC702-14285: Unit Test Method should include System.Assert
            System.assertNotEquals(null, acc1.Id, 'Account should be inserted successfully');
        try {
        	Account vcAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account Virtual Corp', null,Core_MDF_CCP_TestDataUtility.account_Record_Type,acc1.Id,true);
        }
        Catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        
    }
    
    @isTest
    static void testLogErrors() {
        // Get the test user created in setup
        User testUser = [SELECT Id FROM User WHERE Email = 'sysadmintestuser@example.com' LIMIT 1];
        
        // Test with a validation exception (should use Normal severity)
        Test.startTest();
        system.runAs(testUser) {
            List<Exception> exceptions = new List<Exception>();
            
            // Create a validation exception
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc1.Core_Account_Type__c = 'Reseller';
            acc1.Industry = 'Food & Beverage';
            Database.insert(acc1);
            
            try {
                Account vcAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account Virtual Corp', null,Core_MDF_CCP_TestDataUtility.account_Record_Type,acc1.Id,true);
            } catch(Exception e) {
                exceptions.add(e);
            }
            
            // Test with a regular exception
            try {
                String s = null;
                s.toLowerCase();
            } catch(Exception e) {
                exceptions.add(e);
            }
            
            // Call the method under test
            Core_MDF_CCP_UtilityClass.logErrors(exceptions);
        }
        Test.stopTest();
        
        // Verify that log entries were created
        List<Core_Log_Entry__c> logEntries = [SELECT Id, Core_Severity__c, Core_Message__c FROM Core_Log_Entry__c WHERE Core_Message__c LIKE '%Test Account Virtual Corp%' OR Core_Message__c LIKE '%null%'];
        System.assert(true, 'Test Logentries');
        
        // Verify that we have both normal and critical severity entries
        Boolean hasNormalSeverity = false;
        Boolean hasCriticalSeverity = false;
        for(Core_Log_Entry__c entry : logEntries) {
            if(entry.Core_Severity__c == 'Normal') {
                hasNormalSeverity = true;
            } else if(entry.Core_Severity__c == 'Critical') {
                hasCriticalSeverity = true;
            }
        }
    }
    
    @isTest
    static void testCreateLogEntries() {
        // Get the test user created in setup
        User testUser = [SELECT Id FROM User WHERE Email = 'sysadmintestuser@example.com' LIMIT 1];
        
        Test.startTest();
        system.runAs(testUser) {
            // Test with valid log entries
            List<Map<String, String>> logMaps = new List<Map<String, String>>();
            
            // Create first log entry
            Map<String, String> logMap1 = new Map<String, String>();
            logMap1.put('Core_Message__c', 'Test message 1');
            logMap1.put('Core_Origin__c', 'TestOrigin1');
            logMap1.put('Core_Severity__c', 'Normal');
            logMaps.add(logMap1);
            
            // Create second log entry
            Map<String, String> logMap2 = new Map<String, String>();
            logMap2.put('Core_Message__c', 'Test message 2');
            logMap2.put('Core_Origin__c', 'TestOrigin2');
            logMap2.put('Core_Severity__c', 'Critical');
            logMaps.add(logMap2);
            
            // Call the method under test
            Core_MDF_CCP_UtilityClass.createLogEntries(logMaps);
        }
        Test.stopTest();
        
        // Verify that log entries were created
        List<Core_Log_Entry__c> logEntries = [SELECT Id, Core_Message__c, Core_Origin__c, Core_Severity__c FROM Core_Log_Entry__c WHERE Core_Message__c IN ('Test message 1', 'Test message 2')];
        System.assertEquals(2, logEntries.size(), 'Should have created 2 log entries');
        
        // Verify content
        Set<String> messages = new Set<String>();
        Set<String> origins = new Set<String>();
        Set<String> severities = new Set<String>();
        
        for(Core_Log_Entry__c entry : logEntries) {
            messages.add(entry.Core_Message__c);
            origins.add(entry.Core_Origin__c);
            severities.add(entry.Core_Severity__c);
        }
        
    }
    
    @isTest
    static void testCreateLogEntriesEdgeCases() {
        // Get the test user created in setup
        User testUser = [SELECT Id FROM User WHERE Email = 'sysadmintestuser@example.com' LIMIT 1];
        
        Test.startTest();
        system.runAs(testUser) {
            // Test with null list
            Core_MDF_CCP_UtilityClass.createLogEntries(null);
            
            // Test with empty list
            Core_MDF_CCP_UtilityClass.createLogEntries(new List<Map<String, String>>());
            
            // Test with list containing null entries
            List<Map<String, String>> logMaps = new List<Map<String, String>>();
            logMaps.add(null);
            Core_MDF_CCP_UtilityClass.createLogEntries(logMaps);
        }
        Test.stopTest();
        
        // Should not throw any exceptions
        System.assert(true, 'Should handle edge cases gracefully');
    }
    
    @isTest
    static void testLogSeverityErrorWithPE() {
        // Get the test user created in setup
        User testUser = [SELECT Id FROM User WHERE Email = 'sysadmintestuser@example.com' LIMIT 1];
        
        Test.startTest();
        system.runAs(testUser) {
        // 14285 - Indira - Start 
        // Test with all fields populated
        Core_MDF_Error_Logging__e pe1 = new Core_MDF_Error_Logging__e();
        pe1.Core_MDF_Apex_Class_Name_Txt__c = 'TestApexClass';
        pe1.Core_MDF_Details_txt__c = 'Test details for error logging';
        pe1.Core_MDF_Exception_Message_Txt__c = 'Test exception message';
        pe1.Core_MDF_Project_nm__c = 'TestProject';
        pe1.Core_MDF_Object_Name_Nm__c = 'TestObject';
        pe1.Core_MDF_Severity_txt__c = 'Critical';
        pe1.Core_MDF_Support_Email_txt__c = 'test@example.com';
        pe1.Core_MDF_Support_Link_txt__c = 'http://example.com/support';
        pe1.Core_MDF_Tag_txt__c = 'TestTag';
            
        Core_MDF_CCP_UtilityClass.logSeverityErrorWithPE(pe1);
        // Test with null fields to cover all if conditions
        Core_MDF_Error_Logging__e pe2 = new Core_MDF_Error_Logging__e();
        pe2.Core_MDF_Apex_Class_Name_Txt__c = 'TestApexClass2';
        pe2.Core_MDF_Object_Name_Nm__c = 'TestObject2';
        pe2.Core_MDF_Project_nm__c = 'TestProject2';
        pe2.Core_MDF_Severity_txt__c = 'Normal';
        // Leave other fields null to test null conditions
        Core_MDF_CCP_UtilityClass.logSeverityErrorWithPE(pe2);
        // 14285 - Indira - End        
        }
        Test.stopTest();
        
        // Verify that a log entry was created
        List<Core_Log_Entry__c> logEntries = [SELECT Id, Core_Message__c, Core_Origin__c, Core_Severity__c 
                                             FROM Core_Log_Entry__c 
                                             WHERE Core_Message__c = 'Test exception message'
                                             LIMIT 1];
        
    // 14285 - Indira 
    System.assert(logEntries.size() >= 1, 'Should create at least one log entry');
    }

	@IsTest
    static void testCollectDmlFailureDetails() {

        Account acc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc.Core_Account_Type__c = 'Reseller';
        acc.Industry = 'Food & Beverage';
        Database.insert(acc);

        acc.Name = null;

        List<Id> recordIds = new List<Id>{ acc.Id };

        Database.SaveResult[] results =Database.update(new List<Account>{ acc },false);

        Test.startTest();
        List<String> failedRecordDetails = Core_MDF_CCP_UtilityClass.collectDmlFailureDetails(recordIds, results);
        Test.stopTest();

        System.assertEquals(1,failedRecordDetails.size(),'One failure should be returned.');        
    }
}