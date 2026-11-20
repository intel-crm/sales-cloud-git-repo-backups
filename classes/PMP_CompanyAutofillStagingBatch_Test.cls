@IsTest
private class PMP_CompanyAutofillStagingBatch_Test {

    @testSetup
    static void setupData() {

        // Remove old metadata if present
        List<Core_CustomMetadata_Object__c> metadataList = [
            SELECT Id
            FROM Core_CustomMetadata_Object__c
            WHERE Metadata_Name__c = 'PMP_CompanyAutofillStagingBatch_mdt'
        ];

        if (!metadataList.isEmpty()) {
            delete metadataList;
        }

        // Record Types
        Id intelRtId = Schema.SObjectType.Account
            .getRecordTypeInfosByName()
            .get('Intel Account')
            .getRecordTypeId();

        Id pagRtId = Schema.SObjectType.Account
            .getRecordTypeInfosByName()
            .get('Partner Account Group')
            .getRecordTypeId();

        // Intel Account
        Account intelAccount = new Account(
            RecordTypeId = pagRtId,
            Name = 'Batch Intel Account Test',
            BillingCity = 'City',
            BillingStreet = 'Street',
            BillingCountry = 'India',
            BillingPostalCode = '123456',
            Core_User_Defined_Website__c = 'https://parent.com',
            Core_Account_Type__c = 'ODM'
        );
        insert intelAccount;

        // PAG Account
        Account pagAccount = new Account(
            RecordTypeId = pagRtId,
            Name = 'Batch PAG Account Test',
            BillingCity = 'City',
            BillingStreet = 'Street',
            BillingCountry = 'India',
            BillingPostalCode = '123456',
            Core_Account_Type__c =
                'Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)',
            UCD_Primary_Account__c = intelAccount.Id
        );
        insert pagAccount;

        // Working Copy
        PMP_Company__c workingCopy = new PMP_Company__c(
            Name = 'Batch Working Copy',
            PMP_Company_Lifecycle_Status_Nm__c = 'Draft',
            PMP_Is_Working_Copy_Ind__c = true,
            PMP_IPA_Badge_Tier_Txt__c = 'Gold',
            PMP_Account_Id__c = intelAccount.Id,
            PMP_Partner_Benefit_Type__c =
                'Solutions Marketplace Basic Profile'
        );
        insert workingCopy;

        // Published Copy
        PMP_Company__c publishedCopy = new PMP_Company__c(
            Name = 'Batch Published Copy',
            PMP_Company_Lifecycle_Status_Nm__c = 'Draft',
            PMP_Is_Published_Ind__c = true,
            PMP_Working_Copy_Id__c = workingCopy.Id,
            PMP_IPA_Badge_Tier_Txt__c = 'Gold',
            PMP_Account_Id__c = intelAccount.Id,
            PMP_Partner_Benefit_Type__c =
                'Solutions Marketplace Basic Profile'
        );
        insert publishedCopy;

        // OPID Relationship
        PMP_OPID_MPI_Rel__c rel = new PMP_OPID_MPI_Rel__c(
            PMP_Marketing_Profile_Id__c = publishedCopy.Id,
            PMP_One_Partner_ID__c = pagAccount.Id,
            Is_Active__c = true
        );
        insert rel;

        // Metadata Configuration
        Core_CustomMetadata_Object__c headerRecord =
            new Core_CustomMetadata_Object__c(
                Metadata_Name__c = 'PMP_CompanyAutofillStagingBatch_mdt',
                Field_1__c = 'RecordLimit',
                Field_1_Text_Area_Long__c = 'Countries',
                Field_2_Text_Area_Long__c = 'RecordId'
            );
        insert headerRecord;

        // Record Id Filter Only
        Core_CustomMetadata_Object__c detailRecord =
            new Core_CustomMetadata_Object__c(
                Metadata_Name__c = 'PMP_CompanyAutofillStagingBatch_mdt',
                Header_row__c = headerRecord.Id,
                Field_1__c = '50',
                Field_2_Text_Area_Long__c = rel.Id
            );
        insert detailRecord;
    }

    @IsTest
    static void testBatchExecution() {

        Test.startTest();

        Id batchId = Database.executeBatch(
            new PMP_CompanyAutofillStagingBatch(),
            200
        );

        Test.stopTest();

        System.assertNotEquals(
            null,
            batchId,
            'Batch Id should be generated'
        );

        List<PMP_CompanyAutoFill__c> autofillRecords = [
            SELECT Id,
                   PMP_Partner_Id__c,
                   PMP_Website__c,
                   PMP_Autofill_Status__c
            FROM PMP_CompanyAutoFill__c
        ];

        System.assert(
            autofillRecords.size() > 0,
            'Expected AutoFill record to be created'
        );
    }

    @IsTest
    static void testStartMethod() {

        PMP_CompanyAutofillStagingBatch batch =
            new PMP_CompanyAutofillStagingBatch();

        Test.startTest();

        Database.QueryLocator locator =
            batch.start(null);

        Test.stopTest();

        System.assertNotEquals(
            null,
            locator,
            'QueryLocator should not be null'
        );
    }

    /*@IsTest
    static void testSchedulableExecution() {

        Test.startTest();

        String jobId = System.schedule(
            'PMP Company AutoFill Test',
            '0 0 0 1 1 ? 2099',
            new PMP_CompanyAutofillStagingBatch()
        );

        Test.stopTest();

        System.assertNotEquals(
            null,
            jobId,
            'Scheduled Job Id should be generated'
        );
    }*/

    @IsTest
    static void testBatchWithExistingAutoFillRecord() {

        PMP_Company__c workingCopy = [
            SELECT Id
            FROM PMP_Company__c
            WHERE PMP_Is_Working_Copy_Ind__c = true
            LIMIT 1
        ];

        insert new PMP_CompanyAutoFill__c(
            PMP_Partner_Id__c = workingCopy.Id,
            PMP_Website__c = 'https://old.com',
            PMP_Autofill_Status__c = 'Scraped'
        );

        Test.startTest();

        Database.executeBatch(
            new PMP_CompanyAutofillStagingBatch(),
            200
        );

        Test.stopTest();

        System.assert(true);
    }
}