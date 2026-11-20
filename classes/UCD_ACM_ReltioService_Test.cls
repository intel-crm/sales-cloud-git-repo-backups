@isTest
public with sharing class UCD_ACM_ReltioService_Test {
    private static UCD_ACM_ServiceContracts.IMDMService mdmServiceInstance = UCD_ACM_ReltioService.getInstance();
    @isTest
    public static void searchAccountReltioTest(){
        Test.setMock(HttpCalloutMock.class, new UCD_ACM_MockHttpResponse()); 
        UCD_ACM_Models.SearchRequest requestPayload = new UCD_ACM_Models.SearchRequest();
        requestPayload.BusinessOrganizationName = 'Spain National Intelligence Center';
        requestPayload.CustomerAggregationTypeCd = 'Unified Intermediate Customer';
        requestPayload.WebsiteURL = 'https://www.cni.es/';
        requestPayload.Address = '';
        requestPayload.CustomerProcessEngagement = 'Direct Price Exception';
        String accessToken = 'b8ceae45b0bf0279493806d734e79f5a38fb3044273e13b3fa3d4496d64039bb';
        String requestModel = '{"WebsiteURL":"https://www.cni.es/","CustomerProcessEngagement":"Direct Price Exception","CustomerAggregationTypeCd":"Unified Intermediate Customer","BusinessOrganizationName":"Spain National Intelligence Center","Address":""}';
        test.startTest();
        mdmServiceInstance.searchAccountReltio(requestPayload);
        mdmServiceInstance.searchAccountReltio(null);
        test.stopTest();
    }
     

}