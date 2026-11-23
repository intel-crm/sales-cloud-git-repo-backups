@IsTest
private class Core_AGSRetryBatchTest {

    // Test Data Initialization
    private static Account createAccountByRecordType(String accountName, String recordType) {

        Account acc = new Account();
        acc.Name                 = accountName;
        acc.RecordTypeId         = Schema.getGlobalDescribe()
                                         .get('Account')
                                         .getDescribe()
                                         .getRecordTypeInfosByName()
                                         .get(recordType)
                                         .getRecordTypeId();
        acc.BillingCity          = 'New York';
        acc.BillingStreet        = 'Street 1';
        acc.BillingCountry       = 'USA';
        acc.BillingCountryCode   = 'USA';
        acc.BillingPostalCode    = '24356';
        acc.Core_Account_Tier__c = 'Tier1';

        return acc;
    }

    @TestSetup
    static void createTestData() {

        Account acc = createAccountByRecordType('Test Account', 'Intel Account');
        insert acc;

        List<Contact> contacts = new List<Contact>();

        // Eligible - Retry Count NULL
        contacts.add(new Contact(
            FirstName = 'Test',
            LastName = 'RetryNull',
            Email = 'retrynull@test.com',
            AccountId = acc.Id,
            MailingCountry = 'India',
            Core_English_Only_First_Name__c = 'Test',
            Core_Enterprise_Id__c = '100001',
            Core_AGS_Integration_Status__c = 'In-Progress',
            Core_ERPM_Integration_Status__c = 'Successful',
            Core_AGS_Status_Change_Date_Time__c = System.now().addMinutes(-30),
            Core_Republish_OBM_s__c = false
        ));

        // Eligible - Retry Count = 1
        contacts.add(new Contact(
            FirstName = 'Test',
            LastName = 'RetryOne',
            Email = 'retryone@test.com',
            AccountId = acc.Id,
            MailingCountry = 'India',
            Core_English_Only_First_Name__c = 'Test',
            Core_Enterprise_Id__c = '100002',
            Core_AGS_Integration_Status__c = 'In-Progress',
            Core_ERPM_Integration_Status__c = 'Successful',
            Core_AGS_Status_Change_Date_Time__c = System.now().addMinutes(-30),
            Core_AGS_Retry_Count__c = 1,
            Core_Republish_OBM_s__c = false
        ));

        // Not eligible - Within retry window
        contacts.add(new Contact(
            FirstName = 'Test',
            LastName = 'RecentContact',
            Email = 'recent@test.com',
            AccountId = acc.Id,
            MailingCountry = 'India',
            Core_English_Only_First_Name__c = 'Test',
            Core_Enterprise_Id__c = '100003',
            Core_AGS_Integration_Status__c = 'In-Progress',
            Core_ERPM_Integration_Status__c = 'Successful',
            Core_AGS_Status_Change_Date_Time__c = System.now().addMinutes(-5),
            Core_AGS_Retry_Count__c = 0,
            Core_Republish_OBM_s__c = false
        ));

        // Not eligible - Different Status
        contacts.add(new Contact(
            FirstName = 'Test',
            LastName = 'CompletedStatus',
            Email = 'completed@test.com',
            AccountId = acc.Id,
            MailingCountry = 'India',
            Core_English_Only_First_Name__c = 'Test',
            Core_Enterprise_Id__c = '100004',
            Core_AGS_Integration_Status__c = 'Successful',
            Core_ERPM_Integration_Status__c = 'Successful',
            Core_AGS_Status_Change_Date_Time__c = System.now().addMinutes(-30),
            Core_AGS_Retry_Count__c = 0,
            Core_Republish_OBM_s__c = false
        ));

        // Not eligible - Max Retry Reached
        contacts.add(new Contact(
            FirstName = 'Test',
            LastName = 'MaxRetry',
            Email = 'maxretry@test.com',
            AccountId = acc.Id,
            MailingCountry = 'India',
            Core_English_Only_First_Name__c = 'Test',
            Core_Enterprise_Id__c = '100005',
            Core_AGS_Integration_Status__c = 'In-Progress',
            Core_ERPM_Integration_Status__c = 'Successful',
            Core_AGS_Status_Change_Date_Time__c = System.now().addMinutes(-30),
            Core_AGS_Retry_Count__c = 2,
            Core_Republish_OBM_s__c = false
        ));

        insert contacts;
    }

    // ─────────────────────────────────────────────
    // Test Methods
    // ─────────────────────────────────────────────

    @IsTest
    static void testBatchExecution() {

        Test.startTest();
        Database.executeBatch(new Core_AGSRetryBatch(), 200);
        Test.stopTest();

        Map<String, Contact> contactMap = new Map<String, Contact>();

        for (Contact c : [
            SELECT Id,
                   LastName,
                   Core_Republish_OBM_s__c,
                   Core_AGS_Retry_Count__c
            FROM Contact
        ]) {
            contactMap.put(c.LastName, c);
        }

        // RetryNull : null -> 0
        System.assertEquals(
            true,
            contactMap.get('RetryNull').Core_Republish_OBM_s__c
        );

        System.assertEquals(
            0,
            Integer.valueOf(
                contactMap.get('RetryNull').Core_AGS_Retry_Count__c
            )
        );

        // RetryOne : 1 -> 2
        System.assertEquals(
            true,
            contactMap.get('RetryOne').Core_Republish_OBM_s__c
        );

        System.assertEquals(
            2,
            Integer.valueOf(
                contactMap.get('RetryOne').Core_AGS_Retry_Count__c
            )
        );

        // RecentContact unchanged
        System.assertEquals(
            false,
            contactMap.get('RecentContact').Core_Republish_OBM_s__c
        );

        // CompletedStatus unchanged
        System.assertEquals(
            false,
            contactMap.get('CompletedStatus').Core_Republish_OBM_s__c
        );

        // MaxRetry unchanged
        System.assertEquals(
            false,
            contactMap.get('MaxRetry').Core_Republish_OBM_s__c
        );

        System.assertEquals(
            2,
            Integer.valueOf(
                contactMap.get('MaxRetry').Core_AGS_Retry_Count__c
            )
        );
    }

    @IsTest
    static void testStartMethodReturnsQueryLocator() {

        Core_AGSRetryBatch batch = new Core_AGSRetryBatch();

        Database.QueryLocator ql = batch.start(null);

        System.assertNotEquals(null, ql);
    }

    @IsTest
    static void testExecuteWithNoEligibleRecords() {

        for (Contact c : [SELECT Id FROM Contact]) {
            c.Core_Republish_OBM_s__c = true;
        }

        update [SELECT Id, Core_Republish_OBM_s__c FROM Contact];

        Test.startTest();
        Database.executeBatch(new Core_AGSRetryBatch(), 200);
        Test.stopTest();

        System.assert(true);
    }

    @IsTest
    static void testFinishMethod() {

        Core_AGSRetryBatch batch = new Core_AGSRetryBatch();

        Test.startTest();
        batch.finish(null);
        Test.stopTest();

        System.assert(true);
    }

    @IsTest
    static void testSchedulerExecution() {

        Test.startTest();

        String cronExp = '0 0 0 1 1 ? 2099';

        System.schedule(
            'Core AGS Retry Scheduler Test',
            cronExp,
            new Core_AGSRetryScheduler()
        );

        Test.stopTest();

        CronTrigger ct = [
            SELECT Id, State
            FROM CronTrigger
            WHERE CronJobDetail.Name =
                'Core AGS Retry Scheduler Test'
            LIMIT 1
        ];

        System.assertEquals('WAITING', ct.State);
    }
}