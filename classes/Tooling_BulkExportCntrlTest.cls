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
        
        // Call the fetchRecords method in the Tooling_BulkExportCntrl class
        List<String> accountNames = new List<String>();
        for (Account acc : testAccounts) {
            accountNames.add(acc.Name);
        }
        
        List<SObject> result = Tooling_BulkExportCntrl.fetchRecords('SELECT Id, Name FROM Account', 'Name', accountNames);
        
        // Assert that the result contains the correct number of records
        System.assertEquals(testAccounts.size(), result.size());
        
        // Assert that each record in the result has the correct name
        for (Integer i = 0; i < result.size(); i++) {
            Account acc = (Account)result[i];
            System.assertEquals(testAccounts[i].Name, acc.Name);
        }
    }
}