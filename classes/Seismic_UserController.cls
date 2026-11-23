/****************************************************************************************************************************************
* Class Name  : Seismic_UserController 
* Version     : 1.0 
* Created Date: 06-16-2022
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            06/16/2022            			  
*****************************************************************************************************************************************/

public class Seismic_UserController {

    public class TokenResponseWrapper{
        @AuraEnabled
        public String access_token; //eyJhbGci...
        @AuraEnabled
        public String expires_in; //21600
        @AuraEnabled
        public String token_type; //Bearer
        @AuraEnabled
        public String scope; //seismic.user.manage
    }
    
    public class UserResponseWrapper{
        @AuraEnabled
        public Seismic_User[] entries; //eyJhbGci...
        @AuraEnabled
        public Integer totalCount; //119
        //@AuraEnabled
        //public Integer limit; //1000 -- this property is not working bcz reserved name
        @AuraEnabled
        public Integer offset; //0
    }

    public class DeleteResponseWrapper{
        @AuraEnabled
        public Integer scimType; //innerError
        @AuraEnabled
        public String detail; //User 58df9a11-6f4d-88e5-7ad8-42e85041ed20 does not exist...
        //@AuraEnabled
        //public String schemas; //urn:ietf:params:scim:api:messages:2.0:Error
    }

    public class Seismic_User {
        @AuraEnabled
        public String id; //"58df9a11-6f4d-88e5-7ad8-42e85041ed20",
        @AuraEnabled
        public String username;//: "abazzi@seismic.com",
        @AuraEnabled
        public String email;//: "abazzi@seismic.com",
        @AuraEnabled
        public String firstName;//: "Ali",
        @AuraEnabled
        public String lastName;//: "Bazzi",
        @AuraEnabled
        public String fullName;//: "Ali Bazzi",
        @AuraEnabled
        public String createdAt;//: "2022-01-19T16:49:53.283Z",
        @AuraEnabled
        public String licenseType;//: "premium",
        @AuraEnabled
        public String ssoId;//: "abazzi@seismic.com",
        @AuraEnabled
        public String isDeleted;//: false,
        @AuraEnabled
        public String organization;//: "Seismic"
    }

    @AuraEnabled
    public static String getSeismicToken(){
        TokenResponseWrapper response = new TokenResponseWrapper();
        try{
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                request.setMethod('POST');
                request.setEndpoint('https://auth.seismic.com/tenants/inteldev/connect/token');

                String grant_type = 'delegation';
                String client_id = 'bfbabaaa-d71a-48e5-8679-e7a6b8d9fa9a';
                String client_secret = 'b0ba2a35-6ecf-4bdc-a63c-a8c2f3a658fa';
                String user_id = '5600d223-ed35-48fb-8096-a1e78866426f';
                String scope = 'seismic.user.manage';

                String payload = 'client_id='+EncodingUtil.urlEncode(client_id,'UTF-8')
                    +'&grant_type='+EncodingUtil.urlEncode(grant_type,'UTF-8')
                    +'&client_secret='+EncodingUtil.urlEncode(client_secret,'UTF-8')
                    +'&user_id='+EncodingUtil.urlEncode(user_id,'UTF-8')
                    +'&scope='+EncodingUtil.urlEncode(scope,'UTF-8');
                request.setBody(payload);

                HttpResponse response2 = http.send(request);
                System.debug(response2.getBody());
                
                if (response2.getStatusCode() == 200) {
                    String responseBody = response2.getBody();
                    response = (TokenResponseWrapper) JSON.deserialize(responseBody, TokenResponseWrapper.class);
                }

                else{
                    //no record found.
                }
        }
        catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

        return response.access_token;
    }     

    @AuraEnabled
    public static UserResponseWrapper getSeismicUsers(String filter){
        UserResponseWrapper response;

        try{
            String bearerToken = getSeismicToken();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            request.setEndpoint('https://api.seismic.com/integration/v2/users?filter=sandeep');//+filter
            request.setHeader('Authorization', 'Bearer ' + bearerToken);
            HttpResponse response2 = http.send(request);
            //System.debug(response2.getBody());
            
            if (response2.getStatusCode() == 200) {
                String responseBody = response2.getBody();
                response = (UserResponseWrapper) JSON.deserialize(responseBody, UserResponseWrapper.class);
            }

            else{
                //no record found.
            }
        }
        catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

        return response;
    }

    @AuraEnabled
    public static String deleteSeismicUser(String id){
        DeleteResponseWrapper response;
        String message ='';
        try{
            String bearerToken = getSeismicToken();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('DELETE');
            request.setEndpoint('https://api.seismic.com/scim/v2/Users/'+ id);
            request.setHeader('Authorization', 'Bearer ' + bearerToken);
            HttpResponse response2 = http.send(request);
            //System.debug(response2.getStatusCode());
            
            if (response2.getStatusCode() == 404) {
                String responseBody = response2.getBody();
                response = (DeleteResponseWrapper) JSON.deserialize(responseBody, DeleteResponseWrapper.class);
                message = response.detail;
            }
			else if (response2.getStatusCode() == 204) {
                 message = 'User Deleted Sucessfully';
            }
            else{
                message = 'Unable to deleted user id '+ id;
            }
        }
        catch (Exception e) {
            message =  'The following exception has occurred: ' + e.getMessage();
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

        return message;
    }
     


    //Returns all Seismic and Lessonly user records from User Table
    @AuraEnabled(cacheable=true)
    public static List<LessonlyUser__c> getAllUsers() {
        return [SELECT Id, User_Id__c, Seismic_UserId__c, Name__c , Email__c, 	Status__c, Deleted_In_Seismic__c, 
                Deleted_In_Lessonly__c from LessonlyUser__c limit 200];
    }

    /*
    This method perform following operations
        1. Delete Records from Seismic
        2. Delete Records from Lessonly
        3. Update User record flags & status
    IN: Ids of selected records
    */
    @AuraEnabled()
    public static void deleteUsers(String[] ids) {
        List<LessonlyUser__c> recordsToUpdate = new List<LessonlyUser__c>();
        List<LessonlyUser__c> selectedRecords = [SELECT Id, User_Id__c, Name__c FROM LessonlyUser__c WHERE Id in :ids];

        Integer i = 0;
        for (LessonlyUser__c userRecord : selectedRecords){
            userRecord.Status__c = 'Deleted sucessfully';
            userRecord.Deleted_In_Seismic__c = true;
            userRecord.Deleted_In_Lessonly__c = true;
            recordsToUpdate.add(userRecord);
            i++;
    	}
        
        update recordsToUpdate;
    }


    /*
    This method perform following operations
        1. Delete Records from Seismic
        2. Delete Records from Lessonly
        3. Update User record flags & status
    IN: Ids of selected records
    */
     @AuraEnabled
     public static boolean getUserDetails() {
        
        //Make Lessonly API calls and save user details
        //Lessonly_UserController.saveLessonlyUsers();

        //Make Seismic API calls and save user details
        //Seismic_UserController.saveSeismicUsers();

        return true;
     }


    /*
     * Used in Seismic User Controller - getUserDetails
    */
    @AuraEnabled
    public static boolean saveSeismicUsers(){
        List<SeismicUserManagement_Temp__c> tempEmails = [SELECT Email__c from SeismicUserManagement_Temp__c limit 200];
        List<String> ids = new List<String>();
        for (SeismicUserManagement_Temp__c userRecord2 : tempEmails){
            ids.add(userRecord2.Email__c);
            System.debug(userRecord2.Email__c);
        }

        List<LessonlyUser__c> recordsToUpdate = new List<LessonlyUser__c>();
        List<LessonlyUser__c> selectedRecords = [SELECT Id, User_Id__c, Seismic_UserId__c, Email__c, Name__c FROM LessonlyUser__c WHERE Email__c in :ids];
		UserResponseWrapper response;  
	    try{
      
                for (LessonlyUser__c userRecord : selectedRecords){
                    String bearerToken = getSeismicToken();
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setMethod('GET');
                    request.setEndpoint('https://api.seismic.com/integration/v2/users?filter='+ userRecord.Email__c);
                    request.setHeader('Authorization', 'Bearer ' + bearerToken);
                    HttpResponse response2 = http.send(request);
                    
                    if (response2.getStatusCode() == 200) {
                        String responseBody = response2.getBody();
                        response = (UserResponseWrapper) JSON.deserialize(responseBody, UserResponseWrapper.class);
                        for (Seismic_User usersData : response.entries) {               
                            System.debug('Updating ' + userRecord.Name__c);
                            userRecord.Seismic_UserId__c = usersData.Id; 
                            recordsToUpdate.add(userRecord);
                            System.debug('Completed Update ' + userRecord.Name__c);
                        }
                    } 
                }
                if(!recordsToUpdate.isEmpty())
                {
                    update recordsToUpdate;
                }
            }
            catch (Exception e) {
                System.debug('The following exception has occurred in saveSeismicUsers: ' + e.getMessage());
            }        

            return true;

    }

    @AuraEnabled
    public static boolean clearLastLoad()
    {
        try{
            List<SeismicUserManagement_Temp__c> tempTable = [SELECT Id from SeismicUserManagement_Temp__c];
            delete tempTable;

            List<LessonlyUser__c> lessonlyTable = [SELECT Id FROM LessonlyUser__c];
            delete lessonlyTable;
        }
         catch (Exception e) {
                System.debug('The following exception has occurred in clearLastLoad: ' + e.getMessage());
        }        

        return true;
    }

   
}