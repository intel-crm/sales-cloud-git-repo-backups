/***************************************************************************************************
* Apex Class Name : Core_IPS_CustomLookupController
* Test Class Name : Core_IPS_CustomLookupControllerTest
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ganapati                    23/10/2019              Created
****************************************************************************************************/
@isTest(seeAllData=false)
private class Core_IPS_CustomLookupControllerTest {
    
    @isTest
    private static void findRecordsTest() {
        List<Account> accountList = TestUtilities.getAccountsList(2);
        insert accountList;
        String searchKey = 'Dell';
        Integer recordLimit = 10;
        String quesryString = 'SELECT Id, Name FROM Account WHERE Name like :key LIMIT :recordLimit';
        String countQueryString = 'SELECT count() FROM Account WHERE Name LIKE :key';
        List<sObject> records = Core_IPS_CustomLookupController.findRecords(searchKey, quesryString, recordLimit, false);
        System.assertEquals(2, records.size());
        Integer recCount = Core_IPS_CustomLookupController.findTotalRecords(searchKey, countQueryString);
        System.assertEquals(2, recCount);
        quesryString = 'FIND :key IN ALL Fields RETURNING Account(Name) LIMIT :recordLimit';
        countQueryString = 'FIND :key IN ALL Fields RETURNING Account(Name)';
        records = Core_IPS_CustomLookupController.findRecords(searchKey, quesryString, recordLimit, true);
        recCount = Core_IPS_CustomLookupController.findTotalRecordsSosl(searchKey, countQueryString);
    }
}