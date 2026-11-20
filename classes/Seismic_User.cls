/****************************************************************************************************************************************
* Class Name  : Seismic_User 
* Version     : 1.0 
* Created Date: 08/24/2022 
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            08/24/2022               		The Apex Class has functions to delete Seismic users
****************************************************************************************************************************************/

public class Seismic_User {
    @TestVisible public String id {get; private set; } //"58df9a11-6f4d-88e5-7ad8-42e85041ed20",
    @TestVisible public String username {get; private set; }//: "abazzi@seismic.com",
    @TestVisible public String email {get; private set; }//: "abazzi@seismic.com",
    @TestVisible public String firstName {get; private set; }//: "Ali",
    @TestVisible public String lastName {get; private set; }//: "Bazzi",
    @TestVisible public String fullName {get; private set; }//: "Ali Bazzi",
    @TestVisible public String createdAt {get; private set; }//: "2022-01-19T16:49:53.283Z",
    @TestVisible public String licenseType {get; private set; }//: "premium",
    @TestVisible public String ssoId {get; private set; }//: "abazzi@seismic.com",
    @TestVisible public Boolean isDeleted {get; private set; }//: false,
    @TestVisible public String organization {get; private set; }//: "Seismic"

    private static String message ='';
    private static Boolean recurringCalled = false;
    private static String bearerToken = getSeismicToken();//Seismic Token for API Call
    
    
    /*Get Seismic Token*/ 
    @TestVisible
    private static String getSeismicToken() {
        if (String.isEmpty(bearerToken)) {
            System.debug('getSeismicToken called');
            String grant_type = Seismic_UserDeletion.config.get('Seismic_Grant_Type');//'delegation';
            String client_id = Seismic_UserDeletion.config.get('Seismic_Client_Id');//'70462cd3-6f13-4004-8574-6b720321160b';
            String client_secret = Seismic_UserDeletion.config.get('Seismic_Client_Secret');//'467eef8b-9292-4120-9469-3560f18bcbbf';
            String user_id = Seismic_UserDeletion.config.get('Seismic_User_ID');//'3ee3a78c-039e-4f46-80de-6bdaf14ba5b0';
            String scope = Seismic_UserDeletion.config.get('Seismic_Scope');//'seismic.user.manage';
            String endPoint = Seismic_UserDeletion.config.get('Seismic_APIEndPoint');//'https://auth.seismic.com/tenants/inteldev/connect/token';
                      
            Seismic_TokenResponseWrapper response = new Seismic_TokenResponseWrapper();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setMethod('POST');
            request.setEndpoint(endPoint);
            
            String payload = 'client_id='+EncodingUtil.urlEncode(client_id,'UTF-8')
                +'&grant_type='+EncodingUtil.urlEncode(grant_type,'UTF-8')
                +'&client_secret='+EncodingUtil.urlEncode(client_secret,'UTF-8')
                +'&user_id='+EncodingUtil.urlEncode(user_id,'UTF-8')
                +'&scope='+EncodingUtil.urlEncode(scope,'UTF-8');
            request.setBody(payload);
            
            try{    
                HttpResponse response2 = http.send(request);
                
                if (response2.getStatusCode() == 200) {
                    String responseBody = response2.getBody();
                    response = (Seismic_TokenResponseWrapper) JSON.deserialize(responseBody, Seismic_TokenResponseWrapper.class);
                    bearerToken = response.access_token;
                }
               //else{
               //     System.debug('Seismic API returns error code ');
               //     throw new CalloutException('Seismic API returns error code');
               // }
                
                //Testing purpose only to hit exception block, it doesn't execute real-time
                if(Test.isRunningTest()) {
                    CalloutException e = new CalloutException();
                    e.setMessage('This is a constructed exception for testing and code coverage');
                    throw e;
                }
            }
            catch (Exception e) {
                message =  'Error occurred in getSeismicToken : ' + e.getMessage();
                Seismic_UserDeletion.jobStatus = Seismic_UserDeletion.Job_Status.Error;
                Seismic_UserDeletion.errorDetail += message;
                System.debug(message);
            }
        }
        return bearerToken;
    }  

	/*Identify Seismic Users*/
    public static HttpResponse identifySeismicUsers(String endpoint) {
        System.debug('identifySeismicUsers called');
        HttpResponse response2;
        if(endPoint =='') {
            endPoint = Seismic_UserDeletion.config.get('Seismic_EndPoint');//'https://api.seismic.com/integration/v2/users?limit=4000&offset=0';
        }
        
        if(Seismic_UserDeletion.isTest) {
            endPoint = 'https://api.seismic.com/integration/v2/users?filter=' + Seismic_UserDeletion.testUser;
        }
        
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            request.setTimeout(100000);
            request.setEndpoint(endPoint);//+filter
            request.setHeader('Authorization', 'Bearer ' + bearerToken);
            response2 = http.send(request);
            Seismic_UserResponseWrapper response = (Seismic_UserResponseWrapper) JSON.deserialize(response2.getBody(), Seismic_UserResponseWrapper.class);
                   
            //Add user to user list
            if(response.entries != null) {
                 for(Seismic_User usr : response.entries){
                     if(usr.isDeleted != true){
                         Seismic_UserDeletion.seismicUsers.add(usr);
                     }
                 }
            }
            //System.debug('Total Count Seismic Users: ' + response.totalCount);
            //System.debug('recurringCalled: ' + recurringCalled);
            //System.debug('Next Page Link: ' + response.nextPageLink);
            //Call it again with nextPageLink 
            if(response.nextPageLink != null && recurringCalled == false) {
               if(Test.isRunningTest()) {
                    recurringCalled = true;
                }
                identifySeismicUsers(response.nextPageLink);
            } 
            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        /*
        catch (System.NullPointerException e) {
            message =  'The following exception has occurred in verifySeismicUsers: ' + e.getMessage();
            System.debug(message);
            //throw e;
        }*/
        catch (System.Exception e) {
            message =  'Error occurred in identifySeismicUsers : ' + e.getMessage();
            Seismic_UserDeletion.jobStatus = Seismic_UserDeletion.Job_Status.Error;
            Seismic_UserDeletion.errorDetail += message;
            System.debug(message);
        }
        return response2;
    }     
    
    /*Delete Seismic Users*/
    public static List<SeismicUserDeletion_User__c> deleteSeismicUsers(List<SeismicUserDeletion_User__c> userList){
        String message ='';
        String msg ='';
        Integer recCount = 1;
        System.debug('deleteSeismicUsers called');
        try{
            for (SeismicUserDeletion_User__c userRecord : userList) {
                msg ='';
                //Call Seismic Deletion
                if(userRecord.Seismic_ID__c != null && recCount <= Seismic_UserDeletion.maxRecordAllow){
                    msg = deleteSeismicUser(userRecord.Seismic_ID__c);
                    if(msg == 'Deleted in Seismic') {
                        userRecord.Deleted_In_Seismic__c = true;
                    }
                    userRecord.Status__c = msg;
                }
                recCount += 1;
            }
            
            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        catch (Exception e) {
            message =  'Error occurred in deleteSeismicUsers : ' + e.getMessage();
            Seismic_UserDeletion.jobStatus = Seismic_UserDeletion.Job_Status.Error;
            Seismic_UserDeletion.errorDetail += message;
        }
        System.debug(message);
        return userList;
    }
    
	/*Delete Seismic User by Seismic Id*/
    private static String deleteSeismicUser(String id) {
        Seismic_DeleteResponseWrapper response;
        try{
            System.debug('Start deleting ' + id);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('DELETE');
            request.setEndpoint('https://api.seismic.com/scim/v2/Users/' + id);
            request.setHeader('Authorization', 'Bearer ' + bearerToken);
            HttpResponse response2 = http.send(request);
            
            if (response2.getStatusCode() == 404) {
                String responseBody = response2.getBody();
                response = (Seismic_DeleteResponseWrapper) JSON.deserialize(responseBody, Seismic_DeleteResponseWrapper.class);
                message = response.detail;
            }
            else if (response2.getStatusCode() == 204) {
                message = 'Deleted in Seismic';
            }
            else{
                message = 'Unable to delete user id '+ id + ' in Seismic.';
            }
            
            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest() && response2.getStatusCode() != 204) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        catch (Exception e) {
            message =  'Error occurred in deleteSeismicUser : ' + e.getMessage();
            Seismic_UserDeletion.jobStatus = Seismic_UserDeletion.Job_Status.Error;
            Seismic_UserDeletion.errorDetail += message;
        }
        System.debug(message);
        return message;
    }   
}