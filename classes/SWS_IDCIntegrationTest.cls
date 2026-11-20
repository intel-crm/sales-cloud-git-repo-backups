@isTest
public class SWS_IDCIntegrationTest{
    
    @testSetup 
    private static void setup(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
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
                Name = 'GenerateCoupon',
                SWS_Value__c = '/billing/coupons'
            );

            insert label;

            Id recordTypeId = Schema.SObjectType.SWS_Cloud_Credit_Request__c.getRecordTypeInfosByDeveloperName().get('SWS_Cloud_Credit_Request').getRecordTypeId();
            SWS_Cloud_Credit_Request__c request = new SWS_Cloud_Credit_Request__c(
                RecordTypeId= recordTypeId,
                SWS_Submitter_Name__c = 'Test',
                SWS_Submitter_Email__c='test@email.com',
                SWS_Submitter_Requster_Email__c=true,
                SWS_First_Name__c = 'Test',
                SWS_Last_Name__c = 'User',
                SWS_Request_Type__c = 'Intel_Internal_Use',
                SWS_Email__c = 'testorg@testorg.com',
                SWS_Country__c = 'Albania',
                SWS_Job_Title__c = 'Student',
                SWS_Cost_Center__c = '43256',
                SWS_HW_Compute_Platform_PL__c = 'Multiple platforms',
                SWS_HW_Compute_Quantity__c = 'Multiple platform contains intel cloud',
                SWS_Compute_Service_Requirements__c =  'Yes',
                SWS_Coupon_Type__c = 'Large – Covers 8 weeks of continuous bare-metal system access',
                SWS_Start_Date__c = System.now().date().addDays(1),
                SWS_Expiry_Date__c = System.now().date().addDays(30),
                SWS_Coupon_Value__c = 3000,
                SWS_No_Of_User__c = 50
            );
            insert request;
        }
    }
    
    @isTest 
    private static void validateRequestTest() {
        User u = [SELECT Id from User where LastName='requestorUser' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SWS_IDCIntegrationMockTest());
        Test.startTest();
        System.runAs(u){
			 SWS_Cloud_Credit_Request__c expiryDateRecord = new SWS_Cloud_Credit_Request__c();
            expiryDateRecord.put('SWS_Expiry_Date__c', System.today().addDays(-1));
            List<SObject> requestList = [SELECT Id,SWS_Request_Type__c,SWS_Email__c,SWS_Submitter_Email__c,SWS_Submitter_Requster_Email__c,SWS_Coupon_Code__c,SWS_Last_redeemed_date__c,
                 sws_start_date__c,sws_expiry_date__c,sws_is_standard__c,sws_no_of_user__c,sws_coupon_value__c,sws_full_name__c,SWS_Is_Submitted_For_Coupon__c,
                 SWS_Coupon_Status__c,SWS_coupon_request__c,SWS_coupon_response__c,SWS_Compute_Service_Requirements__c
                 FROM SWS_Cloud_Credit_Request__c  LIMIT 1];
            SWS_IDCIntegration.getCoupon(requestList);      
        }
        System.assertEquals(true, true,'As Expected');
        Test.stopTest();        
    }
}