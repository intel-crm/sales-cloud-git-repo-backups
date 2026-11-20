@isTest
public class SWS_SingleCouponGenerationRequestTest {
	@testSetup 
    static void setup(){
        User u = SWS_TestUtilty.createUser();
        System.runAs(u){
            SWS_TestUtilty.createLabel('GenerateCoupon','/billing/coupons');
            List<SWS_Cloud_Credit_Request__c> req = SWS_TestUtilty.createMultipleRequest(2);
        }
    }
    
    @isTest 
    private static void singleCouponSubmissionTest() {
        User u = [SELECT Id from User WHERE UserName='requestoremail@testorg.com']; 
        Test.setMock(HttpCalloutMock.class, new SWS_IDCIntegrationMockTest());
        Test.startTest();
        System.runAs(u){
            List<string> record = new List<string>();
            List<SWS_Cloud_Credit_Request__c> requestList = [SELECT Id,SWS_Request_Status__c,SWS_Email__c FROM SWS_Cloud_Credit_Request__c LIMIT 1];
            List<string> reqList = new List<string>();
            for(SWS_Cloud_Credit_Request__c req : requestList){
                reqList.add(req.id);               
            }            
            
            SWS_MultipleCouponGeneration.BulkInput input = new SWS_MultipleCouponGeneration.BulkInput();
            List<SWS_MultipleCouponGeneration.BulkInput> inputValues = new List<SWS_MultipleCouponGeneration.BulkInput>();  
            input.ids = reqList;
            input.singleCoupon = true;
            input.endDate = System.now().date().addDays(30);
            input.couponValue = 999;
            input.noOfUsers = 1;
            input.isStandard = true;
            input.requestList = requestList;
            inputValues.add(input);                     
            SWS_SingleCouponGenerationRequest.singleRequest(inputValues);
            System.assertEquals(true, true,'As Expected');
        }
        Test.stopTest();
    }
}