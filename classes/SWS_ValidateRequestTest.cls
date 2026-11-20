/****************************************************************************************************
Apex Class Name : SWS_ValidateRequestTest
Version         : 1.0 
Created Date    : 2024-03-28
Author          : Team Garnet
Description     : This class is created to cover the code of SWS_ValidateRequest apex class.
*****************************************************************************************************/
@isTest
public class SWS_ValidateRequestTest {
    
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
        List<SWS_Cloud_Credit_Request__c> requestList = new List<SWS_Cloud_Credit_Request__c>();
        Id recordTypeId = Schema.SObjectType.SWS_Cloud_Credit_Request__c.getRecordTypeInfosByDeveloperName().get('SWS_Cloud_Credit_Request').getRecordTypeId();
        SWS_Cloud_Credit_Request__c request = new SWS_Cloud_Credit_Request__c(
            RecordTypeId= recordTypeId, SWS_Request_Type__c = 'Intel_Internal_Use', SWS_Submitter_Requster_Email__c = false, SWS_First_Name__c='Nik@test',SWS_Email__c = 'testbatch@testorg.com',SWS_Last_Name__c = 'User',SWS_Submitter_Email__c='testbatch@testorg.com',SWS_Submitter_Name__c='test'
        );
        
        insert request;
        requestList.add(request);
        System.runAs(u){
            List<String> missingFields= SWS_ValidateRequest.validateRequest(requestList);
            System.assertEquals(!String.isBlank(missingFields[0]), true,'As Expected');
        }
    }
}