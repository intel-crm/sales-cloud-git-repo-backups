@isTest
public class SWS_RetryOperationUtilityTest {
    
    @testSetup 
    private static void setup(){
        User u = SWS_TestUtilty.createUser();
        System.runAs(u){
            SWS_Cloud_Credit_Request__c req = SWS_TestUtilty.createSingleRequest(true);
        }
    }
    
    @isTest 
    private static void updateRecordsSimultaneously(){
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u){
            List<sObject> listOfRecord = new List<sObject>();
            SWS_TestUtilty.createLabel('RetryError','UNABLE_TO_LOCK_ROW;FIELD_CUSTOM_VALIDATION_EXCEPTION;RECORD_LOCKED;');
            SWS_TestUtilty.createLabel('ITTeamEmail','requestoremail@testorg.com');
            SWS_Cloud_Credit_Request__c request = [SELECT Id FROM SWS_Cloud_Credit_Request__c];
            request.SWS_Is_Submitted_For_Coupon__c = true;
            listOfRecord.add(request);
            Test.startTest();
            SWS_RetryOperationUtility retryUtility = new SWS_RetryOperationUtility(listOfRecord);
            List<Core_Log_Entry__c> entryList = [SELECT Id FROM Core_Log_Entry__c];
            System.assert(!entryList.isEmpty(),'New Log created sucessfully');
            Test.stopTest();
        }
    }
}