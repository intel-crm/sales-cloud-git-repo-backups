@isTest
public class CRM_AlertwatchTest {
    
    @testSetup
    static void setup() {
        // Create test data for Core_MDF_CCP_Custom_Metadata_Utility__c
        List<Core_MDF_CCP_Custom_Metadata_Utility__c> metadataRecords = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
        metadataRecords.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Name = 'AuditTrailSections',
            Core_MDF_Value__c = 'Apex Class, Apex Trigger',
            Core_MDF_Program__c = 'Alert_Watch'
        ));
        metadataRecords.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Name = 'AuditTrailExcludedUserEmails',
            Core_MDF_Value__c = 'excluded@example.com',
            Core_MDF_Program__c = 'Alert_Watch'
        ));
        metadataRecords.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Name = 'AuditTrailWhereCondition',
            Core_MDF_Value__c = 'CreatedDate = LAST_N_DAYS:0',
            Core_MDF_Program__c = 'Alert_Watch'
        ));
        metadataRecords.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Name = 'AuditTrailSelectFields',
            Core_MDF_Value__c = 'Id, Section, CreatedBy.Name, CreatedDate, Display, Action',
            Core_MDF_Program__c = 'Alert_Watch'
        ));
        metadataRecords.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Name = 'EmailSubject',
            Core_MDF_Value__c = 'Audit Trail Alert',
            Core_MDF_Program__c = 'Alert_Watch'
        ));
        metadataRecords.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Name = 'AuditTrailsetReplyTo',
            Core_MDF_Value__c = 'noreply@example.com',
            Core_MDF_Program__c = 'Alert_Watch'
        ));
        metadataRecords.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Name = 'AuditTrailCSVHeader',
            Core_MDF_Value__c = 'Id,Section,CreatedBy,CreatedDate,Display,Action',
            Core_MDF_Program__c = 'Alert_Watch'
        ));
        metadataRecords.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Name = 'AuditTrailCSVFileName',
            Core_MDF_Value__c = 'AuditTrail',
            Core_MDF_Program__c = 'Alert_Watch'
        ));
        metadataRecords.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Name = 'AuditTrail_NoChanges',
            Core_MDF_Value__c = 'No changes found',
            Core_MDF_Program__c = 'Alert_Watch'
        ));
        insert metadataRecords;

            }

    @isTest
    static void testGetAuditTrailReminderData() {
        Test.startTest();
           
        List<SetupAuditTrail> auditTrailData = CRM_Alertwatch.getAuditTrailReminderData();
       
    List<Core_Log_Entry__c> logEntries = [SELECT Id, Core_Message__c FROM Core_Log_Entry__c limit 10];
        System.assertEquals(0, logEntries.size(), 'There should be no log entries for errors');
        //System.assertNotEquals(0, auditTrailData.size(), 'Audit trail data should not be empty');
        Test.stopTest();
    }

    @isTest
    static void testSendAuditTrailMail() {
         Test.startTest();
        List<SetupAuditTrail> auditTrailData = CRM_Alertwatch.getAuditTrailReminderData();

       
        CRM_Alertwatch.sendAuditTrailMail(auditTrailData);
      
    List<Core_Log_Entry__c> logEntries = [SELECT Id, Core_Message__c FROM Core_Log_Entry__c limit 10];
        System.assertEquals(0, logEntries.size(), 'There should be no log entries for errors');
          Test.stopTest();            
    }

    @isTest
    static void testGenerateCSVFile() {
         Test.startTest();
        List<SetupAuditTrail> auditTrailData = CRM_Alertwatch.getAuditTrailReminderData();
        Map<String, String> metadataValues = CRM_Alertwatch.retrieveMetadataValues();

       
        Messaging.EmailFileAttachment attachment = CRM_Alertwatch.generateCSVFile(
            auditTrailData,
            metadataValues.get('AuditTrailCSVHeader'),
            metadataValues.get('AuditTrailCSVFileName'),
            metadataValues.get('AuditTrail_NoChanges')
        );
     

        System.assertNotEquals(null, attachment, 'CSV file attachment should not be null');
        System.assertEquals('AuditTrail.csv', attachment.getFilename(), 'CSV file name should match');
           Test.stopTest();
    }
    
   /*  @isTest
    static void testBatchJob() {
        Test.startTest();
        CRM_AlertwatchReminderBatch batchJob = new CRM_AlertwatchReminderBatch();
        Database.executeBatch(batchJob,200);
      

        // Verify that the batch job processed the records
        List<Core_Log_Entry__c> logEntries = [SELECT Id, Core_Message__c FROM Core_Log_Entry__c limit 10];
        System.assertEquals(0, logEntries.size(), 'There should be no log entries for errors');
		  Test.stopTest();
      
    }
    
    @isTest
    static void testBatchExecution1() {
        Test.startTest();
        
        // Create a list of SetupAuditTrail records to pass to the execute method
        List<SetupAuditTrail> auditTrails = [SELECT Id, Action, CreatedDate, CreatedBy.Name, Section, Display, DelegateUser FROM SetupAuditTrail WHERE CreatedDate >= LAST_N_DAYS:0 ORDER BY CreatedDate DESC LIMIT 1];
        
        // Create an instance of the batch class
        CRM_AlertwatchReminderBatch batch = new CRM_AlertwatchReminderBatch();        
        Database.executeBatch(batch,200);
        
     
        
        // Verify that the log entry was created
        List<Core_Log_Entry__c> logEntries = [SELECT Id, Core_Message__c, Core_Details__c, Core_Origin__c, Core_Severity__c, Core_When__c, Core_Project__c FROM Core_Log_Entry__c WHERE Core_Origin__c = 'CRM_AlertWatchNotificationBatch' limit 10];
        System.debug('logEntries::' + logEntries);
        System.assertEquals(0, logEntries.size(), 'No log entry should have been created.');    
        
           Test.stopTest();
    }*/

 
     @isTest
    static void testBatchJobStart1() {
        Test.startTest();
        CRM_AlertwatchReminderBatch batchJob = new CRM_AlertwatchReminderBatch();
        List<SetupAuditTrail> auditTrailData = batchJob.start(null);
       

        System.assertNotEquals(null, auditTrailData, 'Audit trail data should not be null');
        //System.assertNotEquals(0, auditTrailData.size(), 'Audit trail data should not be empty');
         Test.stopTest();
    }

    @isTest
    static void testBatchJobExecute1() {
           Test.startTest();
        // Create a list of SetupAuditTrail records to pass to the execute method
        List<SetupAuditTrail> auditTrailData = [SELECT Id, Action, Section, CreatedById, CreatedDate, Display FROM SetupAuditTrail limit 1];

     
        CRM_AlertwatchReminderBatch batchJob = new CRM_AlertwatchReminderBatch();
        batchJob.execute(null, auditTrailData);
      

        // Verify that the records were processed
        System.assertEquals(auditTrailData.size(), batchJob.lst_aw_response.size(), 'All records should be processed');
        
          Test.stopTest();
    }
}