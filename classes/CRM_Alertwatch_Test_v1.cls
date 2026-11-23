@isTest
public class CRM_Alertwatch_Test_v1 {
    
    @testSetup
    static void setup() {
        // Create test data for Core_MDF_CCP_Custom_Metadata_Utility__c
        List<Core_MDF_CCP_Custom_Metadata_Utility__c> metadataRecords = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
        metadataRecords.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Name = 'AuditTrailSections',
            Core_MDF_Value__c = 'Section1,Section2',
            Core_MDF_Program__c = 'Alert_Watch'
        ));
        metadataRecords.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Name = 'AuditTrailExcludedUserEmails',
            Core_MDF_Value__c = 'excluded@example.com',
            Core_MDF_Program__c = 'Alert_Watch'
        ));
        metadataRecords.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Name = 'AuditTrailWhereCondition',
            Core_MDF_Value__c = 'CreatedDate = LAST_N_DAYS:30',
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
        Test.stopTest();

        //System.assertNotEquals(0, auditTrailData.size(), 'Audit trail data should not be empty');
    }

    @isTest
    static void testSendAuditTrailMail() {
        List<SetupAuditTrail> auditTrailData = CRM_Alertwatch.getAuditTrailReminderData();

        Test.startTest();
        CRM_Alertwatch.sendAuditTrailMail(auditTrailData);
        Test.stopTest();

                    
    }

    @isTest
    static void testGenerateCSVFile() {
        List<SetupAuditTrail> auditTrailData = CRM_Alertwatch.getAuditTrailReminderData();
        Map<String, String> metadataValues = CRM_Alertwatch.retrieveMetadataValues();

        Test.startTest();
        Messaging.EmailFileAttachment attachment = CRM_Alertwatch.generateCSVFile(
            auditTrailData,
            metadataValues.get('AuditTrailCSVHeader'),
            metadataValues.get('AuditTrailCSVFileName'),
            metadataValues.get('AuditTrail_NoChanges')
        );
        Test.stopTest();

        System.assertNotEquals(null, attachment, 'CSV file attachment should not be null');
        System.assertEquals('AuditTrail.csv', attachment.getFilename(), 'CSV file name should match');
    }
    
     @isTest
    static void testBatchJob() {
        Test.startTest();
        CRM_AlertwatchReminderBatch batchJob = new CRM_AlertwatchReminderBatch();
        Database.executeBatch(batchJob);
        Test.stopTest();

        // Verify that the batch job processed the records
        List<Core_Log_Entry__c> logEntries = [SELECT Id, Core_Message__c FROM Core_Log_Entry__c];
        System.assertEquals(0, logEntries.size(), 'There should be no log entries for errors');

        // Verify that the email was sent
        //List<Messaging.SingleEmailMessage> sentEmails = [SELECT Id, Subject FROM Messaging.SingleEmailMessage];
        //System.assertNotEquals(0, sentEmails.size(), 'Emails should have been sent');
        //System.assertEquals('Audit Trail Alert', sentEmails[0].Subject, 'Email subject should match');
    }
    
    @isTest
    static void testBatchExecution1() {
        Test.startTest();
        
        // Create a list of SetupAuditTrail records to pass to the execute method
        List<SetupAuditTrail> auditTrails = [SELECT Id, Action, CreatedDate, CreatedBy.Name, Section, Display, DelegateUser FROM SetupAuditTrail WHERE CreatedDate >= LAST_N_DAYS:2 ORDER BY CreatedDate DESC LIMIT 1];
        
        // Create an instance of the batch class
        CRM_AlertwatchReminderBatch batch = new CRM_AlertwatchReminderBatch();        
        Database.executeBatch(batch);
        
        Test.stopTest();
        
        // Verify that the log entry was created
        List<Core_Log_Entry__c> logEntries = [SELECT Id, Core_Message__c, Core_Details__c, Core_Origin__c, Core_Severity__c, Core_When__c, Core_Project__c FROM Core_Log_Entry__c WHERE Core_Origin__c = 'CRM_AlertWatchNotificationBatch'];
        System.debug('logEntries::' + logEntries);
        System.assertEquals(0, logEntries.size(), 'No log entry should have been created.');        
    }

    /*@isTest
    static void testSendEmail() {
        List<SetupAuditTrail> auditTrailData = CRM_Alertwatch.getAuditTrailReminderData();
        Map<String, String> metadataValues = CRM_Alertwatch.retrieveMetadataValues();

        Test.startTest();
        CRM_Alertwatch.sendEmail(
            auditTrailData,
            metadataValues.get('EmailSubject'),
            metadataValues.get('AuditTrailsetReplyTo'),
            metadataValues.get('AuditTrailCSVHeader'),
            metadataValues.get('AuditTrailCSVFileName'),
            metadataValues.get('AuditTrail_NoChanges')
        );
        Test.stopTest();

        // Verify that the email was sent
        List<Messaging.SingleEmailMessage> sentEmails = [SELECT Id, Subject FROM Messaging.SingleEmailMessage];
        System.assertNotEquals(0, sentEmails.size(), 'Emails should have been sent');
        System.assertEquals('Audit Trail Alert', sentEmails[0].Subject, 'Email subject should match');
    }*/
    
     @isTest
    static void testBatchJobStart1() {
        Test.startTest();
        CRM_AlertwatchReminderBatch batchJob = new CRM_AlertwatchReminderBatch();
        List<SetupAuditTrail> auditTrailData = batchJob.start(null);
        Test.stopTest();

        System.assertNotEquals(null, auditTrailData, 'Audit trail data should not be null');
        //System.assertNotEquals(0, auditTrailData.size(), 'Audit trail data should not be empty');
    }

    @isTest
    static void testBatchJobExecute1() {
        // Create a list of SetupAuditTrail records to pass to the execute method
        List<SetupAuditTrail> auditTrailData = [SELECT Id, Action, Section, CreatedById, CreatedDate, Display FROM SetupAuditTrail limit 1];

        Test.startTest();
        CRM_AlertwatchReminderBatch batchJob = new CRM_AlertwatchReminderBatch();
        batchJob.execute(null, auditTrailData);
        Test.stopTest();

        // Verify that the records were processed
        System.assertEquals(auditTrailData.size(), batchJob.lst_aw_response.size(), 'All records should be processed');
    }
}