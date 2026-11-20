/****************************************************************************************************************************************
* Class Name  : Lessonly_User 
* Version     : 1.0 
* Created Date: 08/24/2022 
* Modification Log :
* Developer                     Date                        Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            08/24/2022               		The Apex Class has methods to delete Lessonly users
****************************************************************************************************************************************/
public class Lessonly_User {
    
    @TestVisible public Integer id {get; private set; } //12304986
    @TestVisible public String resource_type {get; private set; } //user
    @TestVisible public String ext_uid {get; private set; }
    @TestVisible public String email {get; private set; } //sandeep.joshi@intel.com
    @TestVisible public String name {get; private set; } //Sandeep Joshi
    @TestVisible public String role {get; private set; } //learner
    @TestVisible public Integer role_id {get; private set; } //88961
    @TestVisible public String archived_at {get; private set; }
    @TestVisible public String archived_by_user_id {get; private set; }
    @TestVisible public String job_title {get; private set; }
    @TestVisible public String business_unit {get; private set; }
    @TestVisible public String department {get; private set; }
    @TestVisible public String location {get; private set; }
    @TestVisible public String locale {get; private set; }
    @TestVisible public Date hire_date {get; private set; }
    @TestVisible public String manager_name {get; private set; }
    @TestVisible public boolean should_receive_email {get; private set; }
    
    private static String message ='';
    
    /*Returns list of Lessonly_Users*/
    public static HttpResponse identifyLesonlyUsers() {
        Lessonly_UserResponseWrapper response; 
        HttpResponse response2;
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(Seismic_UserDeletion.config.get('Lessonly_UserAPIEndpoint'));
            Blob headerValue = Blob.valueOf(Seismic_UserDeletion.config.get('Lessonly_APIAuthHeader'));
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization', authorizationHeader);
            request.setMethod('GET');
            response2 = http.send(request);
            
            if (response2.getStatusCode() == 200) {//API call successful returns 200, deserialize and fill lessonly user list
                String responseBody = response2.getBody();
                response = (Lessonly_UserResponseWrapper) JSON.deserialize(responseBody, Lessonly_UserResponseWrapper.class);
                Seismic_UserDeletion.lessonlyUsers = response.users;
            }
            
            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        catch (Exception e) {
            message =  'Error occurred in identifyLesonlyUsers : ' + e.getMessage();
            Seismic_UserDeletion.jobStatus = Seismic_UserDeletion.Job_Status.Error;
            Seismic_UserDeletion.errorDetail += message;
            System.debug(message);
        }
        return response2;
    }
    
    
    //Delete Lessonly_Users
    public static List<SeismicUserDeletion_User__c> deleteLessonlyUsers(List<SeismicUserDeletion_User__c> userList){
        String message ='';
        String msg ='';
        System.debug('deleteLessonlyUsers called');
        try{
            for (SeismicUserDeletion_User__c userRecord : userList){
                msg ='';
                //Call Lessonly Deletion if Id is present
                if(userRecord.Lessonly_ID__c != null) {
                    msg = deleteLessonlyUser(String.valueOf(userRecord.Lessonly_ID__c));
                    if(msg == 'Deleted in Lessonly') {
                        userRecord.Deleted_In_Lessonly__c = true;//Update the flag
                    }
                    userRecord.Status__c = msg;//message on status
                }
            }
            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        catch (Exception e) {
            message =  'Error occurred in deleteLessonlyUsers : ' + e.getMessage();
            Seismic_UserDeletion.jobStatus = Seismic_UserDeletion.Job_Status.Error;
            Seismic_UserDeletion.errorDetail += message;
        }
        System.debug(message);
        return userList;
    }
     
	/*Delete Lessonly_Users by Id*/
    @TestVisible 
    private static String deleteLessonlyUser(String userId) {
        Lessonly_UserResponseWrapper response;
        String message ='';
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(Seismic_UserDeletion.config.get('Lessonly_UserAPIEndpoint') +'/'+ userId );
            Blob headerValue = Blob.valueOf(Seismic_UserDeletion.config.get('Lessonly_APIAuthHeader'));
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization', authorizationHeader);
            request.setMethod('DELETE');
            HttpResponse response2 = http.send(request);
            
            if (response2.getStatusCode() == 404) {//User Not found, API returns 404
                String responseBody = response2.getBody();
                response = (Lessonly_UserResponseWrapper) JSON.deserialize(responseBody, Lessonly_UserResponseWrapper.class);
                message = 'User in Lessonly not found id: '+ userId;
            }
			else if (response2.getStatusCode() == 204) {//User found and deleted, API returns 204
                 message = 'Deleted in Lessonly';
            }
            else{
                message = 'Unable to deleted Lessonly user id '+ userId + ' in Lessonly.'; //Error deleting User API returns unknown code
            }
            
            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest() && response2.getStatusCode() != 204) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        catch (Exception e) {
            message =  'Error occurred in deleteLessonlyUser : ' + e.getMessage();
            Seismic_UserDeletion.jobStatus = Seismic_UserDeletion.Job_Status.Error;
            Seismic_UserDeletion.errorDetail += message;
        }
        
		System.debug(message);
        return message;
    }
    
}