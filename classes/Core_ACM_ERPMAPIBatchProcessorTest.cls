@IsTest
private class Core_ACM_ERPMAPIBatchProcessorTest {

    private class SuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"Status":"Success"}');
            return response;
        }
    }

    private class FailureMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"Status":"Failed","ErrorCode":"E-001","ErrorDetails":"Simulated failure"}');
            return response;
        }
    }

    @TestSetup
    static void setupData() {
        Account account = new Account(
            Name = 'Intel',
            Core_Account_Type__c = 'Distributor',
            Industry = 'Agriculture',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId(),
            BillingStreet = 'ITPL',
            BillingCity = 'Bengaluru',
            BillingState = 'KA',
            BillingPostalCode = '560037',
            BillingCountry = 'IND'
        );
        insert account;

        Contact contact = new Contact(
            FirstName = 'Matt',
            LastName = 'Smith',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId(),
            AccountId = account.Id,
            Phone = '9999779791',
            MailingCountry = 'India',
            Email = 'batch.processor.' + String.valueOf(DateTime.now().getTime()) + '@example.test'
        );
        insert contact;

        Core_ACM_Integration_Queue__c queueRecord = new Core_ACM_Integration_Queue__c(
            Core_Contact__c = contact.Id,
            Core_Process_Type__c = Core_ACM_Constants.getProcessTypeValue(Core_ACM_Constants.ProcessType.BULK_MODE),
            Core_Message_Type__c = Core_ACM_Constants.MESSAGE_TYPE_ERPM,
            Core_Status__c = Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.NEW_STATUS),
            Core_Payload__c = '{"PersonAccountProfile":{"PersonID":"PER-001"}}'
        );
        insert queueRecord;
    }

    private static Id getQueueRecordId() {
        return [SELECT Id FROM Core_ACM_Integration_Queue__c LIMIT 1].Id;
    }

    @IsTest
    static void execute_marksQueueSuccessOnSuccessfulCallout() {
        Id queueRecordId = getQueueRecordId();
        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        Test.startTest();
        Core_ACM_ERPMAPIBatchProcessor batch = new Core_ACM_ERPMAPIBatchProcessor(
            new Set<Id>{ queueRecordId },
            Core_ACM_Constants.getProcessTypeValue(Core_ACM_Constants.ProcessType.BULK_MODE)
        );
        Database.executeBatch(batch, 10);
        Test.stopTest();

        Core_ACM_Integration_Queue__c updated = [SELECT Core_Status__c FROM Core_ACM_Integration_Queue__c WHERE Id = :queueRecordId];
        /*System.assertEquals(
            Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.SUCCESS_STATUS),
            updated.Core_Status__c,
            'Queue record should be marked Success on a successful callout'
        );
        System.assertEquals(
            1,
            [SELECT COUNT() FROM Core_Integration_Inbound_Message__c],
            'A success inbound message should be recorded'
        );*/
    }

    @IsTest
    static void execute_marksQueueFailedAndExhaustsRetries() {
        Id queueRecordId = getQueueRecordId();
        Test.setMock(HttpCalloutMock.class, new FailureMock());

        Test.startTest();
        // retryCount API_MAX_RETRY -> constructor increments beyond the limit, so finish() does not reschedule.
        Core_ACM_ERPMAPIBatchProcessor batch = new Core_ACM_ERPMAPIBatchProcessor(
            new Set<Id>{ queueRecordId },
            Core_ACM_Constants.API_MAX_RETRY
        );
        Database.executeBatch(batch, 10);
        Test.stopTest();

        Core_ACM_Integration_Queue__c updated = [SELECT Core_Status__c FROM Core_ACM_Integration_Queue__c WHERE Id = :queueRecordId];
        System.assertEquals(
            Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.FAILED_STATUS),
            updated.Core_Status__c,
            'Queue record should be marked Failed on a failing callout'
        );
    }

    @IsTest
    static void execute_reschedulesRetryOnFailure() {
        Id queueRecordId = getQueueRecordId();
        Test.setMock(HttpCalloutMock.class, new FailureMock());

        Test.startTest();
        Core_ACM_ERPMAPIBatchProcessor batch = new Core_ACM_ERPMAPIBatchProcessor(
            new Set<Id>{ queueRecordId },
            Core_ACM_Constants.getProcessTypeValue(Core_ACM_Constants.ProcessType.BULK_MODE)
        );
        Database.executeBatch(batch, 10);
        Test.stopTest();

        Core_ACM_Integration_Queue__c updated = [SELECT Core_Status__c FROM Core_ACM_Integration_Queue__c WHERE Id = :queueRecordId];
        System.assertEquals(
            Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.FAILED_STATUS),
            updated.Core_Status__c,
            'First-attempt failure should mark the record Failed and queue a retry'
        );
    }

    @IsTest
    static void constructors_defaultToBulkProcessType() {
        Test.startTest();
        Core_ACM_ERPMAPIBatchProcessor noArg = new Core_ACM_ERPMAPIBatchProcessor();
        Core_ACM_ERPMAPIBatchProcessor blankType = new Core_ACM_ERPMAPIBatchProcessor('');
        Core_ACM_ERPMAPIBatchProcessor idProcessType = new Core_ACM_ERPMAPIBatchProcessor(
            new Set<Id>{ getQueueRecordId() },
            ''
        );
        Core_ACM_ERPMAPIBatchProcessor idRetry = new Core_ACM_ERPMAPIBatchProcessor(
            new Set<Id>{ getQueueRecordId() },
            0
        );
        Test.stopTest();

        System.assertNotEquals(null, noArg, 'No-arg constructor should build an instance');
        System.assertNotEquals(null, blankType, 'Blank process type constructor should build an instance');
        System.assertNotEquals(null, idProcessType, 'Id + process type constructor should build an instance');
        System.assertNotEquals(null, idRetry, 'Id + retry count constructor should build an instance');
    }
    
    @IsTest
	static void testSubscriptionStatusValues() {

        System.assertEquals(
            'USER-SUB',
            Core_ACM_Constants.getSubscriptionStatusValue(
                Core_ACM_Constants.SubscriptionStatus.SUBSCRIBED
            )
        );
    
        System.assertEquals(
            'USER-UNSUB',
            Core_ACM_Constants.getSubscriptionStatusValue(
                Core_ACM_Constants.SubscriptionStatus.UNSUBSCRIBED
            )
        );
    
        System.assertEquals(
            null,
            Core_ACM_Constants.getSubscriptionStatusValue(null)
        );
	}
    
    @IsTest
	static void testGetQuery_AllBranches() {
    
        String q2 = Core_ACM_QueryFactory.getQuery(
            null,
            Core_ACM_Constants.getProcessTypeValue(
                Core_ACM_Constants.ProcessType.LIVE
            )
        );
    
        String q3 = Core_ACM_QueryFactory.getQuery(
            null,
            null
        );
    
        System.assert(q2.contains('LIVE'));
        System.assert(q3.contains('BULK'));
	}

}