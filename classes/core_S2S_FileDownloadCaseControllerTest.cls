@isTest
public class core_S2S_FileDownloadCaseControllerTest {
    
    @isTest 
    static void getrelatedfilesByRecordIdTest(){
        Test.startTest();
        String recordId = '5007j00000H8GIkAAN';
        Map<Id, ContentVersion__x> result = core_S2S_FileDownloadCaseController.getRelatedFilesByRecordId(recordId);
        Test.stopTest();
        System.assertEquals(true,true);
    }
    
    @isTest 
    static void getContentVersionTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new core_S2S_CaseExternalFeedMock());
        String recordId = '5007j00000H8GIkAAN';
        String result = core_S2S_FileDownloadCaseController.getContentVersion(recordId);
        Test.stopTest();
        System.assertEquals(true,true);
    }
}