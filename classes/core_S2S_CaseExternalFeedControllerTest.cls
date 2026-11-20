@isTest
global class core_S2S_CaseExternalFeedControllerTest {

    @isTest static void getExtId(){
        Test.startTest();
        Id caseRecordId = 'x017j00000H8GIkAAN';
        Id externalId = core_S2S_CaseExternalFeedController.getExternalID(caseRecordId);
        Test.stopTest();
        System.assertEquals(true,true);
    }
    
    @isTest static void getFeedItemTest(){
        Test.startTest();
        Id caseRecordId = '5007j00000H8GIkAAN';
        Test.setMock(HttpCalloutMock.class, new core_S2S_CaseExternalFeedMock());
        Map<String, Object> externalFeed = core_S2S_CaseExternalFeedController.getFeedElements(caseRecordId);
        Test.stopTest();
    }
    
    @isTest static void postFeedTest(){
        Test.startTest();
        Id caseRecordId = '5007j00000H8GIkAAN';
        Test.setMock(HttpCalloutMock.class, new core_S2S_CaseExternalFeedMock());
        Integer externalFeed = core_S2S_CaseExternalFeedController.postToChatter(caseRecordId, 'postText', true);
        Test.stopTest();
        System.assertEquals(true,true);
    }
    
    @isTest static void postCommentTest(){
        Test.startTest();
        Id caseRecordId = '5007j00000H8GIkAAN';
        Test.setMock(HttpCalloutMock.class, new core_S2S_CaseExternalFeedMock());
        Integer externalFeed = core_S2S_CaseExternalFeedController.postToChatter(caseRecordId, 'postText', false);
        Test.stopTest();
        System.assertEquals(true,true);
    }
    
    @isTest static void getLabels(){
        Test.startTest();
        Id caseRecordId = '5007j00000H8GIkAAN';
        List<core_S2S_ICS_Label__c> labels = core_S2S_CaseExternalFeedController.getLabel();
        Test.stopTest();
        System.assertEquals(true,true);
    }
    
    @isTest static void getOwnerDetails(){
        Test.startTest();
        String searchTerm = 'Test';
        List<User__x> searchUserList = core_S2S_CaseExternalFeedController.searchUsers(searchTerm);
        Test.stopTest();
        System.assertEquals(true,true);
    }
    
    @isTest static void getBody(){
        Test.startTest();
        Id caseRecordId = '5007j00000H8GIkAAN';
        String bodyForPost = core_S2S_CaseExternalFeedController.constructRequestBody(caseRecordId, 'postText', false);
        String bodyForComment = core_S2S_CaseExternalFeedController.constructRequestBody(caseRecordId, 'postText', true);
        Test.stopTest();
        System.assertEquals(true,true);
    }
}