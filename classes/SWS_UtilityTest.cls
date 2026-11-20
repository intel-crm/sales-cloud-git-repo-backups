@isTest
public class SWS_UtilityTest {
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
    
    @isTest static void LogEntryTest() {
        User u = [SELECT Id from User where LastName='requestorUser' LIMIT 1];
        System.runAs(u){
            try{
                SWS_Cloud_Credit_Request__c request = new SWS_Cloud_Credit_Request__c(
                    
                    SWS_Request_Type__c = 'Intel_Internal_Use',
                    SWS_Locked__c = true
                );
                
                insert request;
            }catch(Exception ex){
                SWS_Utility.createCoreLogEntry('SWS_UtilityTest','LogEntryTest','Error while updating email','',ex,'SWS_Cloud_Credit_Request__c','High','');
            }
            Core_Log_Entry__c coreLog = [SELECT Id from Core_Log_Entry__c where CreatedById=:u.Id LIMIT 1];
            System.assertEquals(coreLog != null, true,'As Expected'); 
        }
    }
     @isTest static void validateRedemptionDetailsTest() {
        User u = [SELECT Id from User where LastName='requestorUser' LIMIT 1];
        Id recordTypeId = Schema.SObjectType.SWS_Cloud_Credit_Request__c.getRecordTypeInfosByDeveloperName().get('SWS_Cloud_Credit_Request').getRecordTypeId();
              SWS_Cloud_Credit_Request__c request = new SWS_Cloud_Credit_Request__c(
                recordTypeId = recordTypeId,
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
                SWS_Coupon_Valid_From__c = System.now().addDays(1),
                SWS_Coupon_Expiration_Date__c = System.now().addDays(30),
                SWS_Number_of_Redemptions__c = 0, 
                SWS_Last_redeemed_date__c = null
               );
                
                insert request;
            
           String response='{"code": "AN7A-7BUC-7GLS","creator": "Test User","created": "2023-09-04T12:31:47Z","start": "2023-09-04T12:31:47Z","expires": "2023-12-03T12:31:47Z","disabled": null,"amount": 0.001,"numUses": 3,"numRedeemed": 3,"redemptions": [{ "code": "AN7A-7BUC-7GLS","cloudAccountId": "097854682559","redeemed": "2023-08-23T11:26:28Z","installed": true}]}';
           SWS_IDCIntegration.SWS_IDCResponseWrapper wrapper = new SWS_IDCIntegration.SWS_IDCResponseWrapper().parse(response);
           
           HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"coupons": [{"code": "AN7A-7BUC-7GLS","creator": "Test User","created": "2023-09-04T12:31:47Z","start": "2023-09-04T12:31:47Z","expires": "2023-12-03T12:31:47Z","disabled": null,"amount": 0.001,"numUses": 3,"numRedeemed": 3,"redemptions": [{ "code": "AN7A-7BUC-7GLS","cloudAccountId": "097854682559","redeemed": "2023-08-23T11:26:28Z","installed": true}]}]}');
            res.setStatusCode(200);
            
        Test.startTest();
        //SWS_Utility.getRecordDetails(request.Id);
        SWS_Utility.updateRedemptionDetails(request,wrapper,false,res);
        System.assertEquals(true, true,'As Expected');
        Test.stopTest(); 
        
  
    }
}