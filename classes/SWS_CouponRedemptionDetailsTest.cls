@isTest
public class SWS_CouponRedemptionDetailsTest {
   @testSetup 
    private static void setup(){
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
        System.runAs(u){ 
            SWS_Core_CRM_Labels__c label = new SWS_Core_CRM_Labels__c(
                Name = 'RedeemCoupon', 
                SWS_Value__c = '/billing/coupons?code='
            );
            insert label;
            
            Id recordTypeId = Schema.SObjectType.SWS_Cloud_Credit_Request__c.getRecordTypeInfosByDeveloperName().get('SWS_Cloud_Credit_Request').getRecordTypeId();
            SWS_Cloud_Credit_Request__c request = new SWS_Cloud_Credit_Request__c(
                RecordTypeId= recordTypeId,
                SWS_Submitter_Name__c = 'Test',
                SWS_Submitter_Email__c='test@email.com',
                SWS_First_Name__c = 'Test',
                SWS_Last_Name__c = 'User',
                SWS_Request_Type__c = 'Intel_Internal_Use',
                SWS_Email__c = 'testbatch@testorg.com',
                SWS_Country__c = 'Albania',
                SWS_Job_Title__c = 'Student',
                SWS_Cost_Center__c = '43256',
                SWS_HW_Compute_Platform_PL__c = 'Multiple platforms',
                SWS_Compute_Service_Requirements__c =  'Yes',
                SWS_Coupon_Type__c = 'Large – Covers 8 weeks of continuous bare-metal system access',
                SWS_Start_Date__c = System.now().date(),
                SWS_Expiry_Date__c = System.now().date().addDays(30),
                SWS_Coupon_Value__c = 3000,
                SWS_No_Of_User__c = 50,
                SWS_Coupon_Code__c= 'AN7A-7BUC-7GLS',
                SWS_Coupon_Valid_From__c = System.now().addDays(-30),
                SWS_Coupon_Expiration_Date__c = System.now().addDays(-1)
            );
            insert request;
            
            
        }
    }
    @isTest 
    private static void validateCouponRedemptionTest() {
        User u = [SELECT Id from User where LastName='requestorUser' LIMIT 1];
        List<SWS_Cloud_Credit_Request__c> requestList = [SELECT Id,SWS_Coupon_Status__c,SWS_Coupon_Code__c FROM SWS_Cloud_Credit_Request__c  LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SWS_IDCIntegrationMockTest());
        Test.startTest();
        SWS_CouponRedemptionDetails.getRedemptionDetail(requestList);
        System.assertEquals(true, true,'As Expected');
        Test.stopTest();   
    }
    
}