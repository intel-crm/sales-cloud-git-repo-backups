@isTest
private class Tooling_BulkExportCntrlTest {
    @isTest
    static void testFetchRecords() {
        // Create test data for the SObject you want to query
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            testAccounts.add(new Account(Name = 'Test Account ' + i, BillingCity='Pune', BillingCountry='USA', BillingState='TN', BillingStreet='Av. Marechal Dutra 1137 Ter'));
        }
        insert testAccounts;
        
        
        Tooling_BulkExportCntrl.RecordQuery testParams = new Tooling_BulkExportCntrl.RecordQuery();
        testParams.query = 'SELECT Id, Name FROM Account';
        testParams.filterFieldName = 'Name';
        testParams.values = new List<String>();
        
        for (Account acc : testAccounts) {
            testParams.values.add(acc.Name);
        }
        String jsonString = JSON.serialize(testParams);
        
        Test.startTest();
        List<SObject> result = Tooling_BulkExportCntrl.fetchRecords(jsonString);
        Test.stopTest();
        
        // Assert that the result contains the correct number of records
        System.assertEquals(testAccounts.size(), result.size());
        
        // Assert that each record in the result has the correct name
        for (Integer i = 0; i < result.size(); i++) {
            Account acc = (Account)result[i];
            System.assertEquals(testAccounts[i].Name, acc.Name);
        }
    }
}