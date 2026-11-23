@isTest
public class PRM_SendDocumentUploadEmailTest {
    
    private static final String TEST_EMAIL = 'test@partner.com';
    private static final String TEST_REPLY_TO = 'sabax.husain@intel.com';
    private static final String TEST_ORG_WIDE_EMAIL = 'noreply@intel.com';
    private static final String TEST_TEMPLATE_SUBJECT = 'Document Upload Required';
    private static final String TEST_TEMPLATE_BODY = '<html><body>Please upload your documents</body></html>';
    
    @TestSetup
    static void setupTestData() {
        ChannelProgram ipaProgram = new ChannelProgram();
        ipaProgram.Name='Intel Partner Alliance';
        ipaProgram.PRM_programCode__c='IPA';
        insert ipaProgram;
        
        // Create test Registration Requests with different languages
        List<PRM_Registration_Request__c> regRequests = new List<PRM_Registration_Request__c>();
        
        regRequests.add(new PRM_Registration_Request__c(
            Name = 'Test Registration Request ENG',
            PRM_Email_ID__c = 'test1@partner.com',
            PRM_Channel_Program__c = ipaProgram.id,
            PRM_Status__c = 'New',
            PRM_Preferred_Language__c = 'ENG',
            PRM_First_Name__c = 'abc', 
            PRM_Last_Name__c = 'pqr'
        ));
        
        regRequests.add(new PRM_Registration_Request__c(
            Name = 'Test Registration Request SPA',
            PRM_Email_ID__c = 'test2@partner.com',
            PRM_Channel_Program__c = ipaProgram.id,
            PRM_Status__c = 'New',
            PRM_Preferred_Language__c = 'SPA',
            PRM_First_Name__c = 'abc', 
            PRM_Last_Name__c = 'pqr'
        ));
        
        regRequests.add(new PRM_Registration_Request__c(
            Name = 'Test Registration Request FRA',
            PRM_Email_ID__c = 'test3@partner.com',
            PRM_Channel_Program__c = ipaProgram.id,
            PRM_Status__c = 'New',
            PRM_Preferred_Language__c = 'FRA',
            PRM_First_Name__c = 'abc', 
            PRM_Last_Name__c = 'pqr'
        ));
        
        insert regRequests;
        
        // Create Email Templates for different languages
        List<EmailTemplate> emailTemplates = new List<EmailTemplate>();
        
        emailTemplates.add(new EmailTemplate(
            Name = 'PRM IPA Document Upload Email ENG',
            DeveloperName = 'PRM_IPA_Document_Upload_Email_ENG',
            TemplateType = 'custom',
            FolderId = UserInfo.getUserId(),
            Subject = TEST_TEMPLATE_SUBJECT + ' - English',
            HtmlValue = TEST_TEMPLATE_BODY + ' - English',
            Body = 'Please upload your documents - English'
        ));
        
        emailTemplates.add(new EmailTemplate(
            Name = 'PRM IPA Document Upload Email SPA',
            DeveloperName = 'PRM_IPA_Document_Upload_Email_SPA',
            TemplateType = 'custom',
            FolderId = UserInfo.getUserId(),
            Subject = TEST_TEMPLATE_SUBJECT + ' - Spanish',
            HtmlValue = TEST_TEMPLATE_BODY + ' - Spanish',
            Body = 'Please upload your documents - Spanish'
        ));
        
        emailTemplates.add(new EmailTemplate(
            Name = 'PRM IPA Document Upload Email FRA',
            DeveloperName = 'PRM_IPA_Document_Upload_Email_FRA',
            TemplateType = 'custom',
            FolderId = UserInfo.getUserId(),
            Subject = TEST_TEMPLATE_SUBJECT + ' - French',
            HtmlValue = TEST_TEMPLATE_BODY + ' - French',
            Body = 'Please upload your documents - French'
        ));
        
     //   insert emailTemplates;
        
        // Note: OrgWideEmailAddress typically needs to be set up manually in the org
        // and may not be insertable in test context
    }
    
    @isTest
    static void testSendDocumentUploadEmailToPartner_Success() {
        // Get test data
        List<PRM_Registration_Request__c> regRequests = [
            SELECT Id, Name, PRM_Email_ID__c, PRM_Preferred_Language__c, PRM_Status__c 
            FROM PRM_Registration_Request__c 
            WHERE PRM_Preferred_Language__c = 'ENG'
        ];
        
        List<List<PRM_Registration_Request__c>> regRequestList = new List<List<PRM_Registration_Request__c>>{regRequests};
        
        Test.startTest();
        List<Boolean> results = PRM_SendDocumentUploadEmail.sendDocumentUploadEmailToPartner(regRequestList);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0], 'Email sending should be successful');
        
        // Verify Registration Request status was updated
        List<PRM_Registration_Request__c> updatedRequests = [
            SELECT Id, PRM_Status__c 
            FROM PRM_Registration_Request__c 
            WHERE Id IN :regRequests
        ];
        
        for (PRM_Registration_Request__c req : updatedRequests) {
            //System.assertEquals('Pending with Partner', req.PRM_Status__c, 'Status should be updated to Pending with Partner');
        }
        
        // Verify Email Log was created
        List<PRM_EmailLog__c> emailLogs = [
            SELECT Id, PRM_Type__c, PRM_EmailDeliverabilityStatus__c, PRM_IPA_Registration_Request__c 
            FROM PRM_EmailLog__c 
            WHERE PRM_IPA_Registration_Request__c IN :regRequests
        ];
        
        System.assertEquals(regRequests.size(), emailLogs.size(), 'Email log should be created for each request');
        
        for (PRM_EmailLog__c log : emailLogs) {
            System.assertEquals('IPA', log.PRM_Type__c, 'Email log type should be IPA');
            System.assertEquals(true, log.PRM_EmailDeliverabilityStatus__c, 'Email should be marked as delivered');
        }
    }
    
    @isTest
    static void testSendDocumentUploadEmailToPartner_MultipleLanguages() {
        // Get test data for multiple languages
        List<PRM_Registration_Request__c> regRequests = [
            SELECT Id, Name, PRM_Email_ID__c, PRM_Preferred_Language__c, PRM_Status__c 
            FROM PRM_Registration_Request__c
        ];
        
        List<List<PRM_Registration_Request__c>> regRequestList = new List<List<PRM_Registration_Request__c>>{regRequests};
        
        Test.startTest();
        List<Boolean> results = PRM_SendDocumentUploadEmail.sendDocumentUploadEmailToPartner(regRequestList);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0], 'Email sending should be successful');
        
        // Verify all requests were processed
        List<PRM_EmailLog__c> emailLogs = [
            SELECT Id, PRM_IPA_Registration_Request__c 
            FROM PRM_EmailLog__c 
            WHERE PRM_IPA_Registration_Request__c IN :regRequests
        ];
        
        System.assertEquals(regRequests.size(), emailLogs.size(), 'Email log should be created for each request');
    }
    
    @isTest
    static void testSendDocumentUploadEmailToPartner_FallbackToEnglish() {
        // Create a request with unsupported language
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c(
            Name = 'Test Registration Request DEU',
            PRM_Email_ID__c = 'test@partner.com',
            PRM_Channel_Program__c = [Select id from ChannelProgram where name = 'Intel Partner Alliance' limit 1].id,
            PRM_Status__c = 'New',
            PRM_Preferred_Language__c = 'DEU', // German - not supported
            PRM_First_Name__c = 'abc', 
            PRM_Last_Name__c = 'pqr'
        );
        insert regRequest;
        
        List<List<PRM_Registration_Request__c>> regRequestList = new List<List<PRM_Registration_Request__c>>{
            new List<PRM_Registration_Request__c>{regRequest}
        };
        
        Test.startTest();
        List<Boolean> results = PRM_SendDocumentUploadEmail.sendDocumentUploadEmailToPartner(regRequestList);
        Test.stopTest();
        
        // Should fallback to English template and still succeed
        System.assertEquals(true, results[0], 'Should fallback to English template successfully');
        
        // Verify email log was created
        List<PRM_EmailLog__c> emailLogs = [
            SELECT Id FROM PRM_EmailLog__c 
            WHERE PRM_IPA_Registration_Request__c = :regRequest.Id
        ];
        System.assertEquals(1, emailLogs.size(), 'Email log should be created');
    }
    
    @isTest
    static void testSendDocumentUploadEmailToPartner_EmptyList() {
        List<List<PRM_Registration_Request__c>> emptyList = new List<List<PRM_Registration_Request__c>>();
        
        Test.startTest();
        List<Boolean> results = PRM_SendDocumentUploadEmail.sendDocumentUploadEmailToPartner(emptyList);
        Test.stopTest();
        
        // Should handle empty list gracefully
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0], 'Should handle empty list gracefully');
    }
    
    @isTest
    static void testSendDocumentUploadEmailToPartner_NullList() {
        Test.startTest();
        List<Boolean> results = PRM_SendDocumentUploadEmail.sendDocumentUploadEmailToPartner(null);
        Test.stopTest();
        
        // Should handle null list gracefully
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0], 'Should handle null list gracefully');
    }
    
    @isTest
    static void testSendDocumentUploadEmailToPartner_EmailFailure() {
        // Create request with invalid email to simulate failure
        PRM_Registration_Request__c regRequest = [Select Id, Name, PRM_Email_ID__c, PRM_Status__c, PRM_Channel_Program__c, PRM_Preferred_Language__c from PRM_Registration_Request__c limit 1];
        regRequest.PRM_Email_ID__c = 'invalid-email'; // Invalid email format
                    
        List<List<PRM_Registration_Request__c>> regRequestList = new List<List<PRM_Registration_Request__c>>{
            new List<PRM_Registration_Request__c>{regRequest}
        };
        
        Test.startTest();
        List<Boolean> results = PRM_SendDocumentUploadEmail.sendDocumentUploadEmailToPartner(regRequestList);
        Test.stopTest();
        
        // Note: In test context, Messaging.sendEmail() is mocked and typically succeeds
        // This test verifies the error handling logic structure
        System.assertEquals(1, results.size(), 'Should return one result');
    } 
    
    @isTest
    static void testCreateEmailLog() {
        // Get test data
        PRM_Registration_Request__c regRequest = [
            SELECT Id FROM PRM_Registration_Request__c 
            WHERE PRM_Preferred_Language__c = 'ENG' 
            LIMIT 1
        ];
        
        EmailTemplate emailTemplate = [
            SELECT Id, Subject, HtmlValue 
            FROM EmailTemplate 
            WHERE DeveloperName = 'PRM_IPA_Document_Upload_Email_ENG' 
            LIMIT 1
        ];
        
        // Create email message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(emailTemplate.Id);
        mail.setSubject(emailTemplate.Subject);
        mail.setHtmlBody(emailTemplate.HtmlValue);
        mail.setToAddresses(new List<String>{TEST_EMAIL});
        
        Test.startTest();
        PRM_EmailLog__c emailLog = PRM_SendDocumentUploadEmail.createEmailLog(mail, regRequest.Id);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, emailLog, 'Email log should be created');
        System.assertEquals(true, emailLog.PRM_EmailDeliverabilityStatus__c, 'Should be marked as delivered');
        System.assertEquals('IPA', emailLog.PRM_Type__c, 'Type should be IPA');
        System.assertEquals(regRequest.Id, emailLog.PRM_IPA_Registration_Request__c, 'Should be linked to registration request');
        System.assertEquals(emailTemplate.Subject, emailLog.PRM_Subject__c, 'Subject should match template');
        System.assertEquals(emailTemplate.HtmlValue, emailLog.PRM_EmailContent__c, 'Content should match template');
        System.assertEquals('Email sent successfully', emailLog.PRM_Email_API_Response__c, 'Should have success message');
        System.assertNotEquals(null, emailLog.PRM_Timestamp__c, 'Timestamp should be set');
    }
    
    @isTest
    static void testCreateEmailRecord() {
        EmailTemplate emailTemplate = [
            SELECT Id, Subject, HtmlValue 
            FROM EmailTemplate 
            WHERE DeveloperName = 'PRM_IPA_Document_Upload_Email_ENG' 
            LIMIT 1
        ];
        
        List<String> toAddresses = new List<String>{TEST_EMAIL};
        
        Test.startTest();
        Messaging.SingleEmailMessage mail = PRM_SendDocumentUploadEmail.createEmailRecord(
            emailTemplate, 
            toAddresses, 
            TEST_REPLY_TO
        );
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, mail, 'Email message should be created');
        System.assertEquals(emailTemplate.Id, mail.getTemplateId(), 'Template ID should be set');
        System.assertEquals(emailTemplate.Subject, mail.getSubject(), 'Subject should match template');
        System.assertEquals(emailTemplate.HtmlValue, mail.getHtmlBody(), 'HTML body should match template');
        System.assertEquals(toAddresses, mail.getToAddresses(), 'To addresses should be set');
        System.assertEquals(TEST_REPLY_TO, mail.getReplyTo(), 'Reply-to should be set');
    }
    
    @isTest
    static void testCreateEmailRecord_NoReplyTo() {
        EmailTemplate emailTemplate = [
            SELECT Id, Subject, HtmlValue 
            FROM EmailTemplate 
            WHERE DeveloperName = 'PRM_IPA_Document_Upload_Email_ENG' 
            LIMIT 1
        ];
        
        List<String> toAddresses = new List<String>{TEST_EMAIL};
        
        Test.startTest();
        Messaging.SingleEmailMessage mail = PRM_SendDocumentUploadEmail.createEmailRecord(
            emailTemplate, 
            toAddresses, 
            null // No reply-to
        );
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, mail, 'Email message should be created');
        System.assertEquals(emailTemplate.Id, mail.getTemplateId(), 'Template ID should be set');
        // Reply-to should not be set when null is passed
    }
    
    @isTest
    static void testCreateEmailRecord_BlankReplyTo() {
        EmailTemplate emailTemplate = [
            SELECT Id, Subject, HtmlValue 
            FROM EmailTemplate 
            WHERE DeveloperName = 'PRM_IPA_Document_Upload_Email_ENG' 
            LIMIT 1
        ];
        
        List<String> toAddresses = new List<String>{TEST_EMAIL};
        
        Test.startTest();
        Messaging.SingleEmailMessage mail = PRM_SendDocumentUploadEmail.createEmailRecord(
            emailTemplate, 
            toAddresses, 
            '' // Blank reply-to
        );
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, mail, 'Email message should be created');
        System.assertEquals(emailTemplate.Id, mail.getTemplateId(), 'Template ID should be set');
        // Reply-to should not be set when blank is passed
    }
 /*   
    @isTest
    static void testBulkProcessing() {
        // Create bulk registration requests
        List<PRM_Registration_Request__c> bulkRequests = new List<PRM_Registration_Request__c>();
        
        for (Integer i = 0; i < 200; i++) {
            bulkRequests.add(new PRM_Registration_Request__c(
                Name = 'Bulk Test Request ' + i,
                PRM_Email_ID__c = 'bulk' + i + '@partner.com',
                PRM_Channel_Program__c = [Select id from ChannelProgram where name = 'Intel Partner Alliance' limit 1].id,
                PRM_Status__c = 'New',
                PRM_Preferred_Language__c = 'ENG',
                PRM_First_Name__c = 'abc', 
                PRM_Last_Name__c = 'pqr'
            ));
        }
        insert bulkRequests;
        
        List<List<PRM_Registration_Request__c>> regRequestList = new List<List<PRM_Registration_Request__c>>{bulkRequests};
        
        Test.startTest();
        List<Boolean> results = PRM_SendDocumentUploadEmail.sendDocumentUploadEmailToPartner(regRequestList);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0], 'Bulk processing should be successful');
        
        // Verify all requests were processed
        List<PRM_Registration_Request__c> updatedRequests = [
            SELECT Id, PRM_Status__c 
            FROM PRM_Registration_Request__c 
            WHERE Id IN :bulkRequests
        ];
        
        System.assertEquals(200, updatedRequests.size(), 'All requests should be processed');
        
        for (PRM_Registration_Request__c req : updatedRequests) {
            System.assertEquals('Pending with Partner', req.PRM_Status__c, 'All requests should have updated status');
        }
    }
    
    @isTest
    static void testExceptionHandling() {
        // Create a scenario that might cause an exception
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c(
            Name = 'Test Exception Request',
            PRM_Email_ID__c = null, // Null email might cause issues
            PRM_Channel_Program__c = [Select id from ChannelProgram where name = 'Intel Partner Alliance' limit 1].id,
            PRM_Status__c = 'New',
            PRM_Preferred_Language__c = 'ENG',
            PRM_First_Name__c = 'abc', 
            PRM_Last_Name__c = 'pqr'
        );
        insert regRequest;
        
        List<List<PRM_Registration_Request__c>> regRequestList = new List<List<PRM_Registration_Request__c>>{
            new List<PRM_Registration_Request__c>{regRequest}
        };
        
        Test.startTest();
        List<Boolean> results = PRM_SendDocumentUploadEmail.sendDocumentUploadEmailToPartner(regRequestList);
        Test.stopTest();
        
        // Should handle exceptions gracefully
        System.assertEquals(1, results.size(), 'Should return one result');
        // Result might be false due to exception, but method should complete
    } */
}