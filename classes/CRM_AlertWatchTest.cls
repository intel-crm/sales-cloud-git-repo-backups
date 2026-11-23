@isTest
public class CRM_AlertWatchTest {
    
    @testSetup
    static void setup() {
        // Create a test user
        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(testUser) {
            // Create test data for Core_Log_Entry__c
            List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
            logEntries.add(new Core_Log_Entry__c(
                Core_Message__c = 'Test Message',
                Core_Details__c = 'Test Details',
                Core_Origin__c = 'AlertWatch',
                Core_Severity__c = 'Low',
                Core_When__c = System.now(),
                Core_Project__c = 'Sales CRM'
            ));
            insert logEntries;
        }
    }
    
    @isTest
    static void testGetAuditTrailData() {
        Test.setMock(HttpCalloutMock.class, new CRM_SetupAuditTrailMock());        
        Test.startTest();        
        // Call the method to test
        CRM_AlertWatch.GetAuditTrailData();        
        Test.stopTest();
        List<Core_Log_Entry__c> logEntries = [SELECT Id, Core_Message__c, Core_Details__c FROM Core_Log_Entry__c];
        System.assert(logEntries.size() > 0, 'Log entries should have been created.');
    }
    
    @isTest
    static void testSendEmail() {
        Test.setMock(HttpCalloutMock.class, new CRM_SetupAuditTrailMock());        
        // Create test data for SetupAuditTrail
        List<SetupAuditTrail> auditTrails = [SELECT Id, Action, CreatedDate,  CreatedBy.Name, Section, Display, DelegateUser FROM SetupAuditTrail WHERE CreatedDate >= LAST_N_DAYS:2  ORDER BY CreatedDate DESC limit 1];
        Test.startTest();
        // Call the method to test
        CRM_AlertWatch.SendEmail(auditTrails);  
     // System.assertNotNull(auditTrails, 'The object should not be null.');
       // System.assertEquals('1222222222', auditTrails[0].Size, 'ID is not null');   
        Test.stopTest();
    }
    
    @isTest
    static void testGetEmailBodyHtml() {
        Test.setMock(HttpCalloutMock.class, new CRM_SetupAuditTrailMock());
        
        // Create test data for SetupAuditTrail
        List<SetupAuditTrail> auditTrails = [SELECT Id, Action, CreatedDate,  CreatedBy.Name, Section, Display, DelegateUser FROM SetupAuditTrail WHERE CreatedDate >= LAST_N_DAYS:2  ORDER BY CreatedDate DESC limit 1];

         System.assertEquals('1222222222', auditTrails[0].Id, 'The Id is not null');      
        }
        
         @isTest
   static void testBatch() {
       
         Id jobId = Database.executeBatch(new CRM_AlertWatchReminderBatch());
          System.assertEquals('1222222222', jobId , 'job id got as expected');  
         //String cronExp = '0 0 5 ? * *';
         //system.schedule('Send Email at 5am', cronExp, new AlertWatch());
        }
}