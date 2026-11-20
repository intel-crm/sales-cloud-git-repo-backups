/****************************************************************************************************************************************
* Class Name  : Seismic_UserDeletionTest 
* Version     : 1.0 
* Created Date: 08/24/2022 
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            08/24/2022               		Apex Test Classes for entire Seismic_UserDeletion Inteface 
*****************************************************************************************************************************************/

@isTest
private class Seismic_UserDeletionTest {
    

    @isTest 
    static void testClearLog() {
        //Test Data
        SeismicUserDeletion_User__c user = new SeismicUserDeletion_User__c(Load_ID__c = 1, Email__c = 'sandeep.joshi@intel.com', Seismic_ID__c = '0000000');
        insert user;
        Test.setCreatedDate(user.Id, DateTime.newInstance(2005,12,12));
        
        Test.startTest();
        
        Boolean flg = Seismic_UserDeletion.clearLog();
        
        Test.stopTest();
        
        System.assertEquals(true, flg, 'Was expecting TRUE testClearLog');
    } 
    
    @isTest 
    static void testClearLogNegative() {
        Test.startTest();
        
        Boolean flg = Seismic_UserDeletion.clearLog();
        
        Test.stopTest();
        
        System.assertEquals(false, flg, 'Was expecting FALSE testClearLogNegative');
    }
    
    //Test method for Seismic User Class
    @isTest 
    static void Seismic_UserClass_Test() {
        Test.startTest();
        
        //Test Data
        Seismic_UserDeletion.config = new Map<String, String>();
        Seismic_UserDeletion.config.put('Seismic_Grant_Type','delegation');
        Seismic_UserDeletion.config.put('Seismic_Client_Id','bfbabaaa-d71a-48e5-8679-e7a6b8d9fa9a');
        Seismic_UserDeletion.config.put('Seismic_Client_Secret','b0ba2a35-6ecf-4bdc-a63c-a8c2f3a658fa');
        Seismic_UserDeletion.config.put('Seismic_User_ID','5600d223-ed35-48fb-8096-a1e78866426f');
        Seismic_UserDeletion.config.put('Seismic_Scope','seismic.user.manage');
        Seismic_UserDeletion.config.put('Seismic_APIEndPoint','https://auth.seismic.com/tenants/inteldev/connect/token');
        Seismic_UserDeletion.config.put('Seismic_EndPoint','https://api.seismic.com/integration/v2/users?limit=4000&offset=0');
        
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Seismic_Token');
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        //Test Token Positive
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        String response = Seismic_User.getSeismicToken();
        System.assertNotEquals(null,response, 'The callout returned a null response. Seismic_User.getSeismicToken Positive Test');// Verify mock response is not null
        
        //Test Token Negative
        mock.setStatusCode(208);
        Test.setMock(HttpCalloutMock.class, mock);
        String response2 = Seismic_User.getSeismicToken();
        System.assertNotEquals(null,response2, 'The callout returned a null response. Seismic_User.getSeismicToken Negative Test');// Verify mock response is not null
        
        //Test Identify users
        //Create the mock response based on a static resource
        StaticResourceCalloutMock mock2 = new StaticResourceCalloutMock();
        mock2.setStaticResource('Seismic_Data');
        mock2.setHeader('Content-Type', 'application/json;charset=UTF-8');
        mock2.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock2);
        Seismic_UserDeletion.seismicUsers = new List<Seismic_User>();
        HttpResponse result = Seismic_User.identifySeismicUsers('');
        System.assertNotEquals(null,result, 'The callout returned a null response. identifySeismicUsers' + result);// Verify response is not null
        System.assertEquals(200,result.getStatusCode(), 'The status code is not 200. identifySeismicUsers' + result.getStatusCode());// Verify status code is 200
        
        //Class Constructor scope test 
        Seismic_User urs = new Seismic_User();
        urs.id = '58df9a11-6f4d-88e5-7ad8-42e85041ed20';
        urs.username = 'user_deletion_test@inteldev.com';
        urs.email = 'user_deletion_test@inteldev.com';
        urs.firstName = 'User';
        urs.lastName = 'Deletion Test';
        urs.fullName = 'User Deletion Test';
        urs.createdAt = '2022-01-19T16:49:53.283Z';
        urs.licenseType = 'premium';
        urs.ssoId = 'user_deletion_test@inteldev.com';
        urs.isDeleted = false;
        urs.organization = 'Seismic';
        
        //User Deletion Test
        List<SeismicUserDeletion_User__c> userList = new List<SeismicUserDeletion_User__c>();
        SeismicUserDeletion_User__c user = new SeismicUserDeletion_User__c();
        user.Name ='Test';
        user.Seismic_ID__c = '000';
        user.Email__c = 'user_deletion_test@inteldev.com';
        user.Deleted_In_Seismic__c = false;
        userList.add(user);
        
        mock2.setStatusCode(408);//Unable to delete
        Test.setMock(HttpCalloutMock.class, mock2);
        List<SeismicUserDeletion_User__c> userList0 = Seismic_User.deleteSeismicUsers(userList);
        for (SeismicUserDeletion_User__c userRecord0 : userList0){
            System.assertEquals(false,userRecord0.Deleted_In_Seismic__c,'Expecting false deleteSeismicUsers 408');
        }
        
        mock2.setStatusCode(404);//Negative User not found
        Test.setMock(HttpCalloutMock.class, mock2);
        List<SeismicUserDeletion_User__c> userList1 = Seismic_User.deleteSeismicUsers(userList);
        for (SeismicUserDeletion_User__c userRecord1 : userList1) {
            System.assertEquals(false,userRecord1.Deleted_In_Seismic__c,'Expecting false deleteSeismicUsers 404');
        }
        
        mock2.setStatusCode(204);//Positve user deleted
        Test.setMock(HttpCalloutMock.class, mock2);
        List<SeismicUserDeletion_User__c> userList2 = Seismic_User.deleteSeismicUsers(userList);
        for (SeismicUserDeletion_User__c userRecord2 : userList2) {
            System.assertEquals(true,userRecord2.Deleted_In_Seismic__c,'Expecting true deleteSeismicUsers 204');
        }
        
        Test.stopTest();
    }     

    //Test method for Lessonly Users Class
    @isTest 
    static void Lessonly_UserClass_Test() {
        Test.startTest();
        //Test Data
        Seismic_UserDeletion.config = new Map<String, String>();
        Seismic_UserDeletion.config.put('Lessonly_UserAPIEndpoint','https://api.lessonly.com/api/v1/users');
        Seismic_UserDeletion.config.put('Lessonly_APIAuthHeader','inteldev:LWDfYbqDrHrQVs0rAMWKj8E4VVQK5jjP');

        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Lessonly_Data');
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
                
        //Test Identify users
        HttpResponse result = Lessonly_User.identifyLesonlyUsers();
        // Verify mock response is not null
        System.assertNotEquals(null,result, 'The callout returned a null response.' + result);
        // Verify status code
        System.assertEquals(200,result.getStatusCode(), 'The status code is not 200. identifyLesonlyUsers' + result.getStatusCode());
        
        //User Deletion Test
        //List<SeismicUserDeletion_User__c> userList
        List<SeismicUserDeletion_User__c> userList = new List<SeismicUserDeletion_User__c>();
        SeismicUserDeletion_User__c user = new SeismicUserDeletion_User__c();
        user.Name ='Test';
        user.Lessonly_ID__c = 22;
        user.Email__c = 'user_deletion_test@inteldev.com';
        userList.add(user);
                
        mock.setStatusCode(404);//No user found block
        Test.setMock(HttpCalloutMock.class, mock);
        List<SeismicUserDeletion_User__c> deletedUsers2 = Lessonly_User.deleteLessonlyUsers(userList);
        for (SeismicUserDeletion_User__c userRecord2 : deletedUsers2) {
            System.assertEquals(false,userRecord2.Deleted_In_Lessonly__c,'Expecting false deleteLessonlyUsers 404');
        }
       
        mock.setStatusCode(407);//Else block
        Test.setMock(HttpCalloutMock.class, mock);
        List<SeismicUserDeletion_User__c> deletedUsers3 = Lessonly_User.deleteLessonlyUsers(userList);
        for (SeismicUserDeletion_User__c userRecord3 : deletedUsers3){
            System.assertEquals(false,userRecord3.Deleted_In_Lessonly__c,'Expecting false deleteLessonlyUsers 407');
        }
        
        mock.setStatusCode(204);//User Found
        Test.setMock(HttpCalloutMock.class, mock);
        List<SeismicUserDeletion_User__c> deletedUsers = Lessonly_User.deleteLessonlyUsers(userList);
        for (SeismicUserDeletion_User__c userRecord1 : deletedUsers) {
            System.assertEquals(true,userRecord1.Deleted_In_Lessonly__c,'Expecting true deleteLessonlyUsers 204');
        }
        
        
        
        //Class Constructor scope test 
        Lessonly_User urs = new Lessonly_User();
        urs.id = 22;
        urs.resource_type = 'user';
        urs.ext_uid  ='';
        urs.email = 'user_deletion_test@inteldev.com';
        urs.name ='';
        urs.role ='';
        urs.role_id =0;
        urs.archived_at ='';
        urs.archived_by_user_id ='';
        urs.job_title ='';
        urs.business_unit ='';
        urs.department ='';
        urs.location ='';
        urs.locale ='';
        urs.hire_date = null;
        urs.manager_name ='';
        urs.should_receive_email = false;
        
        Test.stopTest();
    }     
   
    //Test methods for Seismic User Deletion Class
    @isTest 
    static void Seismic_UserDeletionClass_Test() {
         
        Test.startTest();
        
        //Test data
        SeismicUserDeletion_User__c user = new SeismicUserDeletion_User__c(Load_ID__c = 1, Email__c = 'sandeep.joshi@intel.com', Seismic_ID__c = '0000000');
        insert user;
        
        SeismicUserDeletion_User__c tmpTable = [SELECT Load_ID__c FROM SeismicUserDeletion_User__c ORDER BY Load_ID__c DESC LIMIT 1];
        
        //Test New Load ID
        Integer newId = Seismic_UserDeletion.newLoadID();
        System.assertEquals(newId, (Integer)tmpTable.Load_ID__c + 1, 'newLoadID');
        
        
        //Test Config Data
        List<SeismicUserDeletion_Config__c> configs = new List<SeismicUserDeletion_Config__c>();
        configs.add(new SeismicUserDeletion_Config__c(Name = 'GraphAPI_apiScope', Key__c = 'GraphAPI_apiScope', Value__c = 'https://graph.microsoft.com/.default'));
        configs.add(new SeismicUserDeletion_Config__c(Name = 'GraphAPI_ClientId', Key__c = 'GraphAPI_ClientId', Value__c = 'd27aaefe-a853-45a0-ab45-04ba27a230ad'));
        configs.add(new SeismicUserDeletion_Config__c(Name = 'GraphAPI_ClientSecret', Key__c = 'GraphAPI_ClientSecret', Value__c = 'fVB7Q~_7IXC1E6dClojFNBLkbb~OQ5LUKmB65'));         
        configs.add(new SeismicUserDeletion_Config__c(Name = 'GraphAPI_EndPoint', Key__c = 'GraphAPI_EndPoint', Value__c = 'https://login.microsoftonline.com/46c98d88-e344-4ed4-8496-4ed7712e255d/oauth2/v2.0/token'));
        configs.add(new SeismicUserDeletion_Config__c(Name = 'Seismic_AD_PremiumUser', Key__c = 'Seismic_AD_PremiumUser', Value__c = '8b0b84e3-f02f-480f-a7e8-ca75c5d90755'));         
        configs.add(new SeismicUserDeletion_Config__c(Name = 'Seismic_AD_BusinessUser', Key__c = 'Seismic_AD_BusinessUser', Value__c = 'b683f081-4afd-4c91-9292-fb1af0e07539'));
        configs.add(new SeismicUserDeletion_Config__c(Name = 'Yoda_Email', Key__c = 'Yoda_Email', Value__c = 'yoda.seismic.support@intel.com'));         
        configs.add(new SeismicUserDeletion_Config__c(Name = 'Sales_POCEmail', Key__c = 'Sales_POCEmail', Value__c = 'sales_content_poc@intel.com'));
        configs.add(new SeismicUserDeletion_Config__c(Name = 'IsTest', Key__c = 'IsTest', Value__c = 'true'));
        configs.add(new SeismicUserDeletion_Config__c(Name = 'MaxRecordAllow', Key__c = 'MaxRecordAllow', Value__c = '2'));
        insert configs;
                
        //Test Initilization
        Boolean flg = Seismic_UserDeletion.initialize();
        System.assertEquals(true, flg);
        System.assertEquals(configs.size(), Seismic_UserDeletion.config.size(), 'initialize');
     
        Test.stopTest(); 
    }   
    
	//Test methods for Seismic User Deletion Class
    @isTest 
    static void Seismic_UserDeletionClass_Test_Negative() {
         
        Test.startTest();

        //Test Data
        Seismic_UserDeletion.config = new Map<String, String>();
        Seismic_UserDeletion.config.put('Seismic_Grant_Type','delegation');
        Seismic_UserDeletion.config.put('Seismic_Client_Id','bfbabaaa-d71a-48e5-8679-e7a6b8d9fa9a');
        Seismic_UserDeletion.config.put('Seismic_Client_Secret','b0ba2a35-6ecf-4bdc-a63c-a8c2f3a658fa');
        Seismic_UserDeletion.config.put('Seismic_User_ID','5600d223-ed35-48fb-8096-a1e78866426f');
        Seismic_UserDeletion.config.put('Seismic_Scope','seismic.user.manage');
        Seismic_UserDeletion.config.put('Seismic_APIEndPoint', 'https://auth.seismic.com/tenants/inteldev/connect/token');    
        Seismic_UserDeletion.config.put('GraphAPI_apiScope', 'https://graph.microsoft.com/.default');
        Seismic_UserDeletion.config.put('GraphAPI_ClientId', 'd27aaefe-a853-45a0-ab45-04ba27a230ad');
        Seismic_UserDeletion.config.put('GraphAPI_ClientSecret', 'fVB7Q~_7IXC1E6dClojFNBLkbb~OQ5LUKmB65');         
        Seismic_UserDeletion.config.put('GraphAPI_EndPoint', 'https://login.microsoftonline.com/46c98d88-e344-4ed4-8496-4ed7712e255d/oauth2/v2.0/token');
        Seismic_UserDeletion.config.put('Seismic_AD_PremiumUser', '8b0b84e3-f02f-480f-a7e8-ca75c5d90755');         
        Seismic_UserDeletion.config.put('Seismic_AD_BusinessUser', 'b683f081-4afd-4c91-9292-fb1af0e07539');
        Seismic_UserDeletion.config.put('Yoda_Email', 'yoda.seismic.support@intel.com');
        Seismic_UserDeletion.config.put('Sales_POCEmail', 'sales_content_poc@intel.com');
        Seismic_UserDeletion.config.put('IsTest', 'true');
        Seismic_UserDeletion.config.put('MaxRecordAllow', '2');
        
        Seismic_UserDeletion.errorDetail = '';
        
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GraphAPI_Data');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        
        //Test Data
        String message ='';
        Seismic_UserDeletion.isTest = true;
        Seismic_UserDeletion.testUser = 'user_deletion_test@inteldev.com';
        String raw = '{@odata.context=https://graph.microsoft.com/v1.0/$metadata#directoryObjects(displayName,mail,extension_0f4113104c90419c9f4205e0384e2ac7_enterpriseID), value=({@odata.type=#microsoft.graph.user, displayName=Zaman, Muhammad A, extension_0f4113104c90419c9f4205e0384e2ac7_enterpriseID=11421160, mail=muhammad.a.zaman@intel.com}, {@odata.type=#microsoft.graph.user, displayName=Norman, Thomas W, extension_0f4113104c90419c9f4205e0384e2ac7_enterpriseID=10659019, mail=tom.norman@intel.com})}';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setTimeout(100000);
        request.setBody(raw); 
        request.setEndpoint('https://api.seismic.com/scim/v2/Users');//+filter
        request.setHeader('Authorization', 'Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjRGMUEwMTYxNUUzM0E0NEQwNEE0MUE5QzFBRDVGQjE2MkQyQkFDMDciLCJ0eXAiOiJhdCtqd3QiLCJ4NXQiOiJUeG9CWVY0enBFMEVwQnFjR3RYN0ZpMHJyQWMifQ.eyJuYmYiOjE2NjYyMTM5MzgsImV4cCI6MTY2NjIzNTUzOCwiaXNzIjoiaHR0cHM6Ly9hdXRoLnNlaXNtaWMuY29tL3RlbmFudHMvaW50ZWxkZXYiLCJhdWQiOlsiaHR0cHM6Ly9hdXRoLnNlaXNtaWMuY29tL3RlbmFudHMvaW50ZWxkZXYvcmVzb3VyY2VzIiwicHVibGljX2ludGVncmF0aW9uX2FwaSJdLCJjbGllbnRfaWQiOiJiZmJhYmFhYS1kNzFhLTQ4ZTUtODY3OS1lN2E2YjhkOWZhOWEiLCJ0ZW5hbnQiOiJpbnRlbGRldiIsInRlbmFudF9mcWRuIjoiaW50ZWxkZXYuc2Vpc21pYy5jb20iLCJ0ZW5hbnRfaWQiOiJjZTczMTFiYS02ZDU4LTQ3ZWItYTEwMC1hMjgzNGVjMmVhMGMiLCJ0b2tlbl9zb3VyY2UiOiJ0ZW5hbnQiLCJjbGllbnRfbmFtZSI6ImFwcF9pbnRlbGRldl9Vc2VyTWFuYWdlbWVudEFQSV8wLjIuMCIsInN1YiI6IjU2MDBkMjIzLWVkMzUtNDhmYi04MDk2LWExZTc4ODY2NDI2ZiIsImF1dGhfdGltZSI6MTY2NjIxMzkzOCwiaWRwIjoiU2Vpc21pYyAtIERlbGVnYXRpb246YWQyZjk3N2QtOTViZi00MjYwLWJlYTMtMDM5ZjA3YzUwMWQ3IiwiaWQiOiI1NjAwZDIyMy1lZDM1LTQ4ZmItODA5Ni1hMWU3ODg2NjQyNmYiLCJhY2NvdW50X3R5cGUiOiJQcmVtaXVtIiwianRpIjoibXhnT0lqcm50U1hwUUphUDdOdEU5ZyIsInNjb3BlIjpbInNlaXNtaWMudXNlci5tYW5hZ2UiXSwiYW1yIjpbImV4dGVybmFsIl19.cs613G2oNpq_xgxWWN4lpYtukdZyFXKEkZKNsesGGMXEyDFhEduXJjh21NHV2890UWQmV1sEtHtBTPncjrDKPPqF_RHuJzj2QVttDRAFQUf391JUShx1luB_oDfkgkfDLqZ1f1htJ67JAgm-Z9POK3G7sUGm9_NrZR7a3SsPQtLCj7YG0T0NZ6wcdot4Vr_FuWl-LIiqDeR-C9h7KkymA0kTzDjGshTjYRdMMGsabJxImdbcdKAqhyt1A9vjONTZFX9zcaHYsPezlA65h8hHhEhiaVgw0UdVURCfBqN19rbLtUeaU6zUKSzLvy1AFUGQ8ZwVUBCUjhZbdhlGDuQ6DQ');
        request.setHeader('Content-Type', 'application/json');
        HttpResponse response = http.send(request);
        
        
        // Verify mock response is not null
        System.assertNotEquals(null,response, 'The callout returned a null response.');
        // Verify status code
        System.assertEquals(200,response.getStatusCode(), 'The status code is not 200.');      
        
        String accessToken = Seismic_UserDeletion.getAccessToken();
        //System.assertNotEquals(null,accessToken, 'The callout returned a null response.' + accessToken); 
        
        accessToken = 'eyJ0eXAiOiJKV1QiLCJub25jZSI6Ild5SVNwRTU4M29rSHVLdE9feldMZ0lWOVQ3c1NHSnVUb2tqZ0doX19zdk0iLCJhbGciOiJSUzI1NiIsIng1dCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSIsImtpZCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC80NmM5OGQ4OC1lMzQ0LTRlZDQtODQ5Ni00ZWQ3NzEyZTI1NWQvIiwiaWF0IjoxNjY2NzE1ODQ4LCJuYmYiOjE2NjY3MTU4NDgsImV4cCI6MTY2NjcxOTc0OCwiYWlvIjoiRTJaZ1lKZ1lzZkJxOVQyclZXN1h1OFIvM05xZ0JRQT0iLCJhcHBfZGlzcGxheW5hbWUiOiJEUkRfQ';        
        
        //HttpResponse response3 = Seismic_UserDeletion.getAzureGroupMembers('','8b0b84e3-f02f-480f-a7e8-ca75c5d90755',accessToken); //Seismic SSO AZAD-CORP - Premium User (PRODUCTION)
        //System.assertNotEquals(null, response3, response3);
        //System.assertEquals(200,response3.getStatusCode(), 'The status code is not 200.' + response3.getBody());
        
        //User Test Data
        Seismic_UserDeletion.seismicUsers = new List<Seismic_User>();
        Seismic_User urs = new Seismic_User();
        urs.id = '58df9a11-6f4d-88e5-7ad8-42e85041ed20';
        urs.username = 'user_deletion_test@inteldev.com';
        urs.email = 'user_deletion_test@inteldev.com';
        urs.firstName = 'User';
        urs.lastName = 'Deletion Test';
        urs.fullName = 'User Deletion Test';
        urs.createdAt = '2022-01-19T16:49:53.283Z';
        urs.licenseType = 'premium';
        urs.ssoId = 'user_deletion_test@inteldev.com';
        urs.isDeleted = false;
        urs.organization = 'Seismic';
        Seismic_UserDeletion.seismicUsers.add(urs);
        
        Seismic_UserDeletion.jobStatus = Seismic_UserDeletion.Job_Status.Success;
        Seismic_UserDeletion.jobStatus = Seismic_UserDeletion.Job_Status.Failure;
        Seismic_UserDeletion.jobStatus = Seismic_UserDeletion.Job_Status.Error;
        Seismic_UserDeletion.jobStatus = Seismic_UserDeletion.Job_Status.NoRecord;
        Seismic_UserDeletion.jobStatus = Seismic_UserDeletion.Job_Status.Skip;
        
        Seismic_UserDeletion.lessonlyUsers = new List<Lessonly_User>();
        Lessonly_User urs2 = new Lessonly_User();
        urs2.id = 123;
        urs2.resource_type = 'user';
        urs2.ext_uid  ='';
        urs2.email = 'user_deletion_test@inteldev.com';
        urs2.name ='';
        urs2.role ='';
        urs2.role_id =0;
        urs2.archived_at ='';
        urs2.archived_by_user_id ='';
        urs2.job_title ='';
        urs2.business_unit ='';
        urs2.department ='';
        urs2.location ='';
        urs2.locale ='';
        urs2.hire_date = null;
        urs2.manager_name ='';
        urs2.should_receive_email = false;
        Seismic_UserDeletion.lessonlyUsers.add(urs2);
        
        Seismic_UserDeletion.errorDetail = '';
        Seismic_UserDeletion.missingUsers = new Set<String>();
        Seismic_UserDeletion.missingUsers.add('missinguser@inteldev.com');
        
        Seismic_UserDeletion.sysAccounts = new Set<String>();
        Seismic_UserDeletion.sysAccounts.add('abc@inteldev.com');
        Seismic_UserDeletion.errorDetail = '';
        
        Seismic_UserDeletion.deleteVerifiedUsers(accessToken);
        
        Seismic_UserDeletion.errorDetail = '';
        Seismic_UserDeletion su = new Seismic_UserDeletion();
        su.execute(null);
        
        Test.stopTest(); 
    } 
    
    //Test methods for Seismic_UserDeletionNotification
    @isTest 
    static void Seismic_UserDeletionNotification_Test() {
        
        Test.startTest();
        
        //Test Data
        Seismic_UserDeletion.config = new Map<String, String>();
        Seismic_UserDeletion.config.put('SalesContentEmablement_Dlist','sandeep.joshi@intel.com');
        Seismic_UserDeletion.config.put('DeveloperEmail','sandeep.joshi@intel.com');
        Seismic_UserDeletion.config.put('CCEmail','sandeep.joshi@intel.com');
        Seismic_UserDeletion.config.put('IsTest', 'true');
        Seismic_UserDeletion.config.put('MaxRecordAllow', '2');
        
        //No record found email in summary
        Boolean flg = Seismic_UserDeletionNotification.sendSummary(3);
        System.assertEquals(true, flg, 'Was expecting TRUE sendSummary');
        
        //Test sendSummary
        SeismicUserDeletion_User__c user = new SeismicUserDeletion_User__c(Load_ID__c = 2, Email__c = 'sandeep.joshi@intel.com', Seismic_ID__c = '0000000', Deleted_In_Seismic__c = true, Deleted_In_Lessonly__c = true);
        insert user;
        flg = Seismic_UserDeletionNotification.sendSummary(2);
        System.assertEquals(true, flg, 'Was expecting TRUE sendSummary');
                
        //Test sendSummary Negative
        user = new SeismicUserDeletion_User__c(Load_ID__c = 1, Email__c = 'sandeep.joshi@intel.com', Seismic_ID__c = '0000000', Deleted_In_Seismic__c = true, Deleted_In_Lessonly__c = true);
        insert user;
        flg = Seismic_UserDeletionNotification.sendSummary(1);
        System.assertEquals(false, flg, 'Was expecting FALSE sendSummary Negative');
        
        //Test DevTeam Summary Emails
        flg = Seismic_UserDeletionNotification.sendDevTeamSummary(3);
        System.assertEquals(true, flg, 'Was expecting TRUE sendSummary');
        
        flg = Seismic_UserDeletionNotification.sendDevTeamSummary(2);
        System.assertEquals(true, flg, 'Was expecting TRUE sendSummary');
        
        flg = Seismic_UserDeletionNotification.sendDevTeamSummary(1);
        System.assertEquals(false, flg, 'Was expecting FALSE sendSummary Negative');
        
                
        //Test senderrorEmail
        Boolean flg2 = Seismic_UserDeletionNotification.senderrorEmail('Test error email', 'Test error email message');
        System.assertEquals(true, flg2, 'Was expecting TRUE senderrorEmail');
        
        //Test senderrorEmail Negative
        flg2 = Seismic_UserDeletionNotification.senderrorEmail('Test Exception Block', 'Test error email message');
        System.assertEquals(false, flg2, 'Was expecting FALSE senderrorEmail');
        
        Test.stopTest();
    }
    
    @isTest 
    static void Lessonly_UserResponseWrapper_Test(){
        Test.startTest();
        Lessonly_UserResponseWrapper user = new Lessonly_UserResponseWrapper();
        user.type='users';
        user.users = null;
        user.total_users=7;
        user.total_pages=1;
        user.page=1;
        user.per_page=50;
        System.assertEquals(7, user.total_users, 'Was expecting 7 Lessonly_UserResponseWrapper_Test');
        Test.stopTest();
    }
    
    @isTest 
    static void Seismic_UserResponseWrapper_Test() {
        Test.startTest();
        Seismic_UserResponseWrapper wraper = new Seismic_UserResponseWrapper();
        wraper.entries = null;
        wraper.totalCount = 0;
        wraper.offset =0;
        wraper.continuationToken ='';
        wraper.nextPageLink='';
        System.assertEquals(0, wraper.totalCount, 'Was expecting 0 Seismic_UserResponseWrapper_Test');
        Test.stopTest();
    }
    
    @isTest 
    static void Seismic_TokenResponseWrapper_Test() {
        Test.startTest();
        Seismic_TokenResponseWrapper token = new Seismic_TokenResponseWrapper();
        token.access_token='eyJhbGci...';
        token.expires_in='0';
        token.token_type='Bearer';
        token.scope='seismic.user.manage';
        System.assertEquals('Bearer', token.token_type, 'Was expecting "Bearer" Seismic_TokenResponseWrapper_Test');
        Test.stopTest();
    }
    
    @isTest 
    static void Seismic_DeleteResponseWrapper_Test() {
        Test.startTest();
        Seismic_DeleteResponseWrapper wraper = new Seismic_DeleteResponseWrapper();
        wraper.scimType = 1;
        wraper.detail = '';
        System.assertEquals(1, wraper.scimType, 'Was expecting 1 Seismic_TokenResponseWrapper_Test');
        Test.stopTest();
    }
     
}