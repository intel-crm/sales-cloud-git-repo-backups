@isTest(seeAllData=false)
private class CustomLookupControllerTest {
    @isTest
    private static void findRecordsTest() {
        List<Account> AccountList = TestUtilities.getAccountsList(2);
        insert AccountList;
        String searchKey = 'Dell';
        String quesryString = 'SELECT Id, Name FROM Account WHERE Name like :key LIMIT 9999';
        CustomLookupController.findRecords(searchKey, quesryString);
    }
}