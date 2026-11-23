/******************************************************************************************************************************************
Class Name  : Core_RestAPI_UserUpdate_test
Version     : 1.0
Created Date: 09 NOV 2023
Function    : Test Class: Custom REST Endpoint to consume User CRUD operations done by AGS API User   

Modification Log :
* Developer                   Date [DD/MM/YYYY]             Description
* ----------------------------------------------------------------------------
* Hemant Tiwari [Team: DRACO]      09/11/2023                Original version
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_RestAPI_UserUpdate_test {
    
    @testSetup 
    static void setup() {
        //Prepare Test User for running test
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name ='IT Admin' LIMIT 1];
        User newUser1 = new User(
            profileId = profile.id, 
            username = 'testUser'+String.valueOf(Math.random())+'@intel.com', 
            email = 'testRestAPIUser@intel.com', 
            emailencodingkey = 'UTF-8', 
            localesidkey = 'en_US', 
            languagelocalekey = 'en_US', 
            timezonesidkey = 'America/Los_Angeles', 
            alias='nuser', 
            lastname='lastname');
        insert newUser1;
    }
    
    @isTest
    static void testuserCreateSuccess() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        // Set request parameters
        req.requestURI = '/services/apexrest/userapi/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"Username":"testusernew15@intel.com.crm.crmdevipa","Alias":"NU","Email":"testusernew15@example.com","LastName":"TestUsernew15","CommunityNickname":"test15","ProfileId":"00eo0000000TVVlAAO","TimeZoneSidKey":"America/Los_Angeles","LocaleSidKey":"en_US","EmailEncodingKey":"ISO-8859-1","LanguageLocaleKey":"en_US","IsActive":"true"}');
        
        // Call the REST service
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        String result = Core_RestAPI_UserUpdate.userCreate();
        Assert.isTrue(result.contains('Successfully inserted User'));
        Test.stopTest();
        
    }
    @isTest
    static void testuserCreateError() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        // Set request parameters
        req.requestURI = '/services/apexrest/userapi/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"Username":"testusernew15@intel.com.crm.crmdevipa","Alias":"NU","Email":"testusernew15","LastName":"TestUsernew15","CommunityNickname":"test15","ProfileId":"00eo0000000TVVlAAO","TimeZoneSidKey":"America/Los_Angeles","LocaleSidKey":"en_US","EmailEncodingKey":"ISO-8859-1","LanguageLocaleKey":"en_US","IsActive":"true"}');
        
        // Call the REST service
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        String result = Core_RestAPI_UserUpdate.userCreate();
        Assert.isTrue(result.contains('Following error occured at Salesforce'));
        Test.stopTest();
        
    }
    @isTest
    static void testuserUpdateSuccess() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        User usr1 = [SELECT Id FROM User WHERE email = 'testRestAPIUser@intel.com'];
        
        // Set request parameters
        req.requestURI = '/services/apexrest/userapi/';
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{"Id":"' + usr1.Id + '","IsActive":"true"}');
        
        // Call the REST service
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        String result = Core_RestAPI_UserUpdate.userUpdate();
        Assert.isTrue(result.contains('Successfully updated User'));
        Test.stopTest();
        
    }
    @isTest
    static void testuserUpdateError() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        User usr1 = [SELECT Id FROM User WHERE email = 'testRestAPIUser@intel.com'];
        
        // Set request parameters
        req.requestURI = '/services/apexrest/userapi/';
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{"Id":"' + usr1.Id + '","IsActive":"true","Email":"usertest"}');
        
        // Call the REST service
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        String result = Core_RestAPI_UserUpdate.userUpdate();
        Assert.isTrue(result.contains('Following error occured at Salesforce'));
        Test.stopTest();
        
    }
}