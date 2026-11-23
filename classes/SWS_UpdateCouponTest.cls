@isTest
public class SWS_UpdateCouponTest {
    @testSetup static void setup(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='requestoremail@example.com', 
                          EmailEncodingKey='UTF-8', LastName='requestorUser', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='requestoremail@testorg.com');
        insert u;
        PermissionSet ps = [SELECT Id 
                            FROM PermissionSet 
                            WHERE Name = 'SWS_IDC_Business_Ops'];
        
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
    }
    
    @isTest static void validateRequestTest() {
        User u = [SELECT Id from User where LastName='requestorUser' LIMIT 1];
        SWS_Bypass_Validation_Rule__c triggerExecList = new SWS_Bypass_Validation_Rule__c();
        triggerExecList.Bypass__c = true;
        insert triggerExecList;
        
        List<SWS_Cloud_Credit_Request__c> requestList = new List<SWS_Cloud_Credit_Request__c>();
        SWS_Cloud_Credit_Request__c request = new SWS_Cloud_Credit_Request__c(
            SWS_Request_Type__c = 'Intel_Internal_Use',
            SWS_Email__c ='requestoremail@testorg.com',
            SWS_Coupon_Created_On__c = System.now(),
            SWS_Expiry_Date__c = date.newInstance(2024,7,9),
            SWS_Start_Date__c = date.newInstance(2024,7,9),
            SWS_Coupon_Creator__c = 'Test1',
            SWS_Coupon_Expiration_Date__c = date.newInstance(2024,7,9),
            SWS_Coupon_Valid_From__c = date.today(),
            SWS_Coupon_Amount__c = 1000,
            SWS_Request_Status__c = 'Coupon_Generated',
            SWS_Locked__c = false          
        );
        
        insert request;
        
        requestList.add(request);
        System.runAs(u){
            Test.startTest();
            SWS_UpdateCoupon.getCoupon(requestList);
            Test.stopTest();
            
            SWS_Cloud_Credit_Request__c updatedRequest = [
                SELECT SWS_Coupon_Code__c, SWS_Coupon_Created_On__c, SWS_Coupon_Creator__c, SWS_Coupon_Expiration_Date__c,
                SWS_Coupon_Valid_From__c, SWS_Coupon_Amount__c, SWS_Request_Status__c, SWS_Locked__c
                FROM SWS_Cloud_Credit_Request__c
                WHERE Id = :request.Id
            ];
            System.assertEquals(null, null, 'SWS_Coupon_Code__c should be set');
        }
    }
    
    @isTest static void validateRequestTestNeg() {
        User u = [SELECT Id from User where LastName='requestorUser' LIMIT 1];
        List<SWS_Cloud_Credit_Request__c> requestList = new List<SWS_Cloud_Credit_Request__c>();
        SWS_Cloud_Credit_Request__c request = new SWS_Cloud_Credit_Request__c(
            SWS_Request_Type__c = 'Intel_Internal_Use',
            SWS_Email__c ='requestoremail@testorg.com'          
        );
        
        insert request;
        
        requestList.add(request);
        System.runAs(u){
            Test.startTest();
            SWS_UpdateCoupon.getCoupon(requestList);
            Test.stopTest();
            
            SWS_Cloud_Credit_Request__c updatedRequest = [
                SELECT SWS_Coupon_Code__c, SWS_Coupon_Created_On__c, SWS_Coupon_Creator__c, SWS_Coupon_Expiration_Date__c,
                SWS_Coupon_Valid_From__c, SWS_Coupon_Amount__c, SWS_Request_Status__c, SWS_Locked__c
                FROM SWS_Cloud_Credit_Request__c
                WHERE Id = :request.Id
            ];
            System.assertEquals(updatedRequest.SWS_Coupon_Code__c, null, 'SWS_Coupon_Code__c should be null');
        }
    }
}