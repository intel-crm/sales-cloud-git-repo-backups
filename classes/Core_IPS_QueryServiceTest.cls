@isTest
private class Core_IPS_QueryServiceTest {

    @TestSetup
    static void setupAccountValidationBypass() {
        insert new Core_Account_Bypass_Validation_Rule__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            ByPass__c = true
        );
    }

    @isTest
    static void testQueryRecordsWithParamsReturnsResults() {
        Account acc = new Account(
            Name = 'Test QS Account',
            BillingCountry = 'United States',
            BillingStreet = '123 Test St',
            BillingCity = 'Bareilly'
        );
        insert acc;

        String query = 'SELECT Id, Name FROM Account WHERE Name = :accountName';
        Map<String, Object> params = new Map<String, Object>{ 'accountName' => 'Test QS Account' };
        User runAsUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        System.runAs(runAsUser) {
            Test.startTest();
            List<SObject> results = Core_IPS_QueryService.queryRecords(query, params);
            Test.stopTest();

            System.assertEquals(1, results.size(), 'Should return exactly one matching Account');
            System.assertEquals(acc.Id, results[0].Id, 'Returned record Id should match');
        }
    }

    @isTest
    static void testQueryRecordsWithParamsNoResults() {
        String query = 'SELECT Id FROM Account WHERE Name = :accountName';
        Map<String, Object> params = new Map<String, Object>{ 'accountName' => 'NonExistentAccount_XYZ' };

        Test.startTest();
        List<SObject> results = Core_IPS_QueryService.queryRecords(query, params);
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Should return an empty list when no match');
    }

    @isTest
    static void testQueryRecordsPlainReturnsResults() {
        Account acc = new Account(
            Name = 'Test QS Plain Account',
            BillingCountry = 'United States',
            BillingStreet = '123 Test St',
            BillingCity = 'Bareilly'
        );
        insert acc;

        Test.startTest();
        List<SObject> results = Core_IPS_QueryService.queryRecords(
            'SELECT Id, Name FROM Account WHERE Name = \'Test QS Plain Account\''
        );
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Should return exactly one Account for plain query');
        System.assertEquals(acc.Id, results[0].Id, 'Returned plain-query Account Id should match');
    }

    @isTest
    static void testQueryRecordsAsMapReturnsMap() {
        Account acc = new Account(
            Name = 'Test QS Map Account',
            BillingCountry = 'United States',
            BillingStreet = '123 Test St',
            BillingCity = 'Bareilly'
        );
        insert acc;

        String query = 'SELECT Id, Name FROM Account WHERE Name = :accountName';
        Map<String, Object> params = new Map<String, Object>{ 'accountName' => 'Test QS Map Account' };

        Test.startTest();
        Map<Id, SObject> resultMap = Core_IPS_QueryService.queryRecordsAsMap(query, params);
        Test.stopTest();

        System.assertEquals(true, resultMap.containsKey(acc.Id), 'Map should contain the inserted Account Id');
    }

    @isTest
    static void testQueryRecordsAsMapEmptyResult() {
        String query = 'SELECT Id FROM Account WHERE Name = :accountName';
        Map<String, Object> params = new Map<String, Object>{ 'accountName' => 'NoSuchAccount_ABC' };

        Test.startTest();
        Map<Id, SObject> resultMap = Core_IPS_QueryService.queryRecordsAsMap(query, params);
        Test.stopTest();

        System.assertEquals(0, resultMap.size(), 'Map should be empty when no records found');
    }

    @isTest
    static void testExecuteDynamicQueryReturnsResults() {
        Account acc = new Account(
            Name = 'Test QS Dynamic Account',
            BillingCountry = 'United States',
            BillingStreet = '123 Test St',
            BillingCity = 'Bareilly'
        );
        insert acc;

        Test.startTest();
        List<SObject> results = Core_IPS_QueryService.executeDynamicQuery(
            'SELECT Id, Name FROM Account WHERE Name = \'Test QS Dynamic Account\''
        );
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Dynamic query should return exactly one record');
        System.assertEquals(acc.Id, results[0].Id, 'Dynamic query should return the inserted Account');
    }

    @isTest
    static void testExecuteSoslReturnsResults() {
        Account acc = new Account(
            Name = 'SOSLSearchAccount',
            BillingCountry = 'United States',
            BillingStreet = '123 Test St',
            BillingCity = 'Bareilly'
        );
        insert acc;

        Test.startTest();
        List<List<SObject>> results = Core_IPS_QueryService.executeSOSL(
            'FIND \'SOSLSearchAccount\' IN NAME FIELDS RETURNING Account(Id, Name)'
        );
        Test.stopTest();

        System.assertNotEquals(null, results, 'SOSL results should not be null');
        System.assertNotEquals(null, acc.Id, 'Inserted Account Id should not be null');
    }

    @isTest
    static void testInsertRecordsSuccess() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Insert Test 1', BillingCountry = 'United States', BillingStreet = '123 Test St'),
            new Account(Name = 'Insert Test 2', BillingCountry = 'United States', BillingStreet = '123 Test St')
        };

        Test.startTest();
        List<SObject> inserted = Core_IPS_QueryService.insertRecords(accounts);
        Test.stopTest();

        for (SObject rec : inserted) {
            System.assertNotEquals(null, rec.Id, 'Inserted record should have an Id assigned');
        }
    }

    @isTest
    static void testInsertRecordsNullInputReturnsNull() {
        Test.startTest();
        List<SObject> result = Core_IPS_QueryService.insertRecords(null);
        Test.stopTest();

        System.assertEquals(null, result, 'Null input should be returned as-is');
    }

    @isTest
    static void testInsertRecordsEmptyListReturnsEmpty() {
        Test.startTest();
        List<SObject> result = Core_IPS_QueryService.insertRecords(new List<SObject>());
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Empty list should be returned as-is');
    }

    @isTest
    static void testInsertRecordsDmlErrorLogsError() {
        List<Account> accounts = new List<Account>{ new Account() };

        Test.startTest();
        List<SObject> result = Core_IPS_QueryService.insertRecords(accounts);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Result list should be returned even when DML error occurs');
    }

    @isTest
    static void testUpdateRecordsSuccess() {
        Account acc = new Account(Name = 'Update Test', BillingCountry = 'United States', BillingStreet = '123 Test St');
        insert acc;
        acc.Name = 'Update Test Modified';

        Test.startTest();
        List<SObject> updated = Core_IPS_QueryService.updateRecords(new List<SObject>{ acc });
        Test.stopTest();

        Account requeried = [SELECT Name FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Update Test Modified', requeried.Name, 'Name should be updated');
        System.assertEquals(1, updated.size(), 'Updated list should contain one record');
    }

    @isTest
    static void testUpdateRecordsNullInputReturnsNull() {
        Test.startTest();
        List<SObject> result = Core_IPS_QueryService.updateRecords(null);
        Test.stopTest();

        System.assertEquals(null, result, 'Null input should be returned as-is');
    }

    @isTest
    static void testUpdateRecordsEmptyListReturnsEmpty() {
        Test.startTest();
        List<SObject> result = Core_IPS_QueryService.updateRecords(new List<SObject>());
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Empty list should be returned as-is');
    }

    @isTest
    static void testUpdateRecordsDmlErrorLogsError() {
        Account existingAcc = new Account(
            Name = 'Fake Update',
            BillingCountry = 'United States',
            BillingStreet = '123 Test St'
        );
        insert existingAcc;
        delete existingAcc;

        Account deletedAcc = new Account(Id = existingAcc.Id, Name = 'Fake Update Changed');

        Test.startTest();
        List<SObject> result = Core_IPS_QueryService.updateRecords(new List<SObject>{ deletedAcc });
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Result list should be returned even when DML error occurs');
    }

    @isTest
    static void testDeleteRecordsSuccess() {
        Account acc = new Account(Name = 'Delete Test', BillingCountry = 'United States', BillingStreet = '123 Test St');
        insert acc;

        Test.startTest();
        Core_IPS_QueryService.deleteRecords(new List<SObject>{ acc });
        Test.stopTest();

        List<Account> remaining = [SELECT Id FROM Account WHERE Id = :acc.Id];
        System.assertEquals(0, remaining.size(), 'Record should be deleted');
    }

    @isTest
    static void testDeleteRecordsNullInputReturnsNull() {
        Test.startTest();
        List<SObject> result = Core_IPS_QueryService.deleteRecords(null);
        Test.stopTest();

        System.assertEquals(null, result, 'Null input should be returned as-is');
    }

    @isTest
    static void testDeleteRecordsEmptyListReturnsEmpty() {
        Test.startTest();
        List<SObject> result = Core_IPS_QueryService.deleteRecords(new List<SObject>());
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Empty list should be returned as-is');
    }

    @isTest
    static void testDeleteRecordsDmlErrorLogsError() {
        // Non-existent but well-formed Id to force a DML failure without deleting real org data
        Account deletedAcc = new Account(Id = '001000000000001AAA');

        Test.startTest();
        List<SObject> result = Core_IPS_QueryService.deleteRecords(new List<SObject>{ deletedAcc });
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Result list should be returned even when DML error occurs');
    }

    @isTest
    static void testUpsertRecordsInsert() {
        Account acc = new Account(Name = 'Upsert New Account', BillingCountry = 'United States', BillingStreet = '123 Test St');

        Test.startTest();
        List<SObject> result = Core_IPS_QueryService.upsertRecords(new List<SObject>{ acc });
        Test.stopTest();

        System.assertNotEquals(null, result[0].Id, 'Upserted new record should have an Id');
    }

    @isTest
    static void testUpsertRecordsUpdate() {
        Account acc = new Account(Name = 'Upsert Existing', BillingCountry = 'United States', BillingStreet = '123 Test St');
        insert acc;
        acc.Name = 'Upsert Existing Updated';

        Test.startTest();
        List<SObject> result = Core_IPS_QueryService.upsertRecords(new List<SObject>{ acc });
        Test.stopTest();

        Account requeried = [SELECT Name FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Upsert Existing Updated', requeried.Name, 'Name should be updated via upsert');
        System.assertEquals(1, result.size(), 'Upsert should return one record');
    }

    @isTest
    static void testUpsertRecordsNullInputReturnsNull() {
        Test.startTest();
        List<SObject> result = Core_IPS_QueryService.upsertRecords(null);
        Test.stopTest();

        System.assertEquals(null, result, 'Null input should be returned as-is');
    }

    @isTest
    static void testUpsertRecordsEmptyListReturnsEmpty() {
        Test.startTest();
        List<SObject> result = Core_IPS_QueryService.upsertRecords(new List<SObject>());
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Empty list should be returned as-is');
    }

    @isTest
    static void testUpsertRecordsDmlErrorLogsError() {
        List<Account> accounts = new List<Account>{ new Account() };

        Test.startTest();
        List<SObject> result = Core_IPS_QueryService.upsertRecords(accounts);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Result list should be returned even when DML error occurs');
    }

    @isTest
    static void testUpsertRecordsWithExternalIdInsert() {
        Account acc = new Account(Name = 'Upsert ExternalId New', BillingCountry = 'United States', BillingStreet = '123 Test St');

        Test.startTest();
        List<SObject> result = Core_IPS_QueryService.upsertRecords(
            new List<SObject>{ acc },
            Account.Id
        );
        Test.stopTest();

        System.assertNotEquals(null, result[0].Id, 'Upserted record should have an Id');
    }

    @isTest
    static void testUpsertRecordsWithExternalIdNullInputReturnsNull() {
        Test.startTest();
        List<SObject> result = Core_IPS_QueryService.upsertRecords(null, Account.Id);
        Test.stopTest();

        System.assertEquals(null, result, 'Null input should be returned as-is');
    }

    @isTest
    static void testUpsertRecordsWithExternalIdEmptyListReturnsEmpty() {
        Test.startTest();
        List<SObject> result = Core_IPS_QueryService.upsertRecords(new List<SObject>(), Account.Id);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Empty list should be returned as-is');
    }

    @isTest
    static void testUpsertRecordsWithExternalIdDmlErrorLogsError() {
        List<Account> accounts = new List<Account>{ new Account() };

        Test.startTest();
        List<SObject> result = Core_IPS_QueryService.upsertRecords(accounts, Account.Id);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Result list should be returned even when DML error occurs');
    }
}