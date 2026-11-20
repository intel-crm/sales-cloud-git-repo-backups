@isTest
private class PRM_CreateIssueControllerTest {
    @isTest
    static void testSaveCase() {
        // Test data setup
        ServiceNow_Case__c caseRecNew = new ServiceNow_Case__c();
        caseRecNew.Title__c = 'Test Value';
        caseRecNew.Program__c = 'IPA';
        List<PRM_CreateIssueController.FileDataWrapper> filesData1 = new List<PRM_CreateIssueController.FileDataWrapper>();
        PRM_CreateIssueController.FileDataWrapper fileData = new PRM_CreateIssueController.FileDataWrapper();
        fileData.fileName = 'TestFile.txt';
        fileData.file = 'VGhpcyBpcyBhIHRlc3QgZmlsZQ=='; // Base64 encoded file content
        filesData1.add(fileData);
        Test.startTest();
        String caseId = PRM_CreateIssueController.saveCase(caseRecNew, filesData1);
        Test.stopTest();
        System.assertNotEquals(null, caseId);
    }

    @isTest
    static void testCheckIfUserHasAssignedPermissionSet() {
        Test.startTest();
        Boolean hasPermissionSet = PRM_CreateIssueController.checkIfUserHasAssignedPermissionSet();
        Test.stopTest();
        system.assert(hasPermissionSet != null);
    }
}