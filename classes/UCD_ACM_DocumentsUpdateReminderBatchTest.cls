@isTest
private class UCD_ACM_DocumentsUpdateReminderBatchTest {
    @testSetup
    static void createAccount(){
        Account acc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Test Account','Intel Account','UNFD_CTRY_CUST');
        INSERT acc;
    }
    
    @IsTest
    static void testReminderAndEntryPoints() {
        Account account = [
            SELECT Id, Name, OwnerId, Last_Reminder_Sent__c
            FROM Account
            WHERE RecordType.Name = 'Intel Account'
            LIMIT 1
        ];
        account.Last_Reminder_Sent__c = Date.today().addMonths(-13);
        
        UCD_ACM_DocumentsUpdateReminderBatch.testLatestUploadDateByAccount =
        new Map<Id, Date>{ account.Id => Date.today().addMonths(-12) };
        
        UCD_ACM_DocumentsUpdateReminderBatch batch =
            new UCD_ACM_DocumentsUpdateReminderBatch();
        
        Test.startTest();
        batch.execute(null, new List<Account>{ account });
        Database.QueryLocator queryLocator = batch.start(null);
        batch.finish(null);
        batch.execute((SchedulableContext)null);
        Test.stopTest();
        
        System.assertNotEquals(null, queryLocator);
    }
    
    @IsTest
    static void testDocumentsAndWorkingDays() {
        Account account = [
            SELECT Id
            FROM Account
            WHERE RecordType.Name = 'Intel Account'
            LIMIT 1
        ];
        
        System.debug('Account'+account);
        
        insert new Attachment(
            Name = 'CCD.txt',
        Body = Blob.valueOf('test'),
        ParentId = account.Id
            );
        insert new ContentVersion(
            Title = 'CCD',
        PathOnClient = 'document.txt',
        VersionData = Blob.valueOf('test'),
        FirstPublishLocationId = account.Id
            );
        
        UCD_ACM_DocumentsUpdateReminderBatch.testLatestUploadDateByAccount = null;
        Map<Id, Date> latestDates =
            UCD_ACM_DocumentsUpdateReminderBatch.getLatestUploadDateByAccount(
        new Set<Id>{ account.Id }
        );
        
        Date saturday = Date.newInstance(2026, 9, 26);
        UCD_ACM_DocumentsUpdateReminderBatch.getNextWorkingDay(saturday);
        UCD_ACM_DocumentsUpdateReminderBatch.isFirstWorkingDayAfter12Months(
            Date.today().addMonths(-12)
            );
        //System.debug(latestDates);
        //System.assert(latestDates.containsKey(account.Id));
        System.assertEquals(false, UCD_ACM_DocumentsUpdateReminderBatch.isWorkingDay(saturday));
    }
}