@isTest
public class SWS_CouponRedemptionBatchTest {
    @testSetup 
    private static void setup(){
        User u = SWS_TestUtilty.createUser();
        System.runAs(u){ 
            SWS_TestUtilty.createLabel('GetRedeemDetail','/cloudcredits/coupons?redeemed=');
            SWS_Bypass_Validation_Rule__c bypass = SWS_TestUtilty.createBypass(false, System.now());
            SWS_Cloud_Credit_Request__c req = SWS_TestUtilty.createSingleRequest(true);
            req.SWS_Coupon_Code__c = 'AN7A-7BUC-7GLS';
            update req;
        }
    }
    
    @isTest 
    private static void validateCouponTest() {
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        Test.startTest();
        System.runAs(u){
            Test.setMock(HttpCalloutMock.class, new IDCBatchIntegrationMockTest());
            List<SWS_Cloud_Credit_Request__c> requestList = [SELECT Id,SWS_Number_of_Redemptions__c,SWS_Coupon_Expiration_Date__c,SWS_Coupon_Status__c FROM SWS_Cloud_Credit_Request__c  LIMIT 1];
            requestList[0].SWS_Coupon_Expiration_Date__c = System.now().addDays(30);
            update requestList;
            SWS_CouponRedemptionBatch couponRedeemBatch = new SWS_CouponRedemptionBatch();
            Database.executeBatch(couponRedeemBatch,50);
            System.assert(requestList.isEmpty() == false,'As Expected');
        }
        Test.stopTest();
    }
        
    public class IDCBatchIntegrationMockTest implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"coupons": [], "redemptions": [{ "code": "AN7A-7BUC-7GLS","cloudAccountId": "097854682559","redeemed": "2023-07-23T11:26:28Z","installed": true}]}');
            res.setStatusCode(200);
            return res;
        }
    }
}