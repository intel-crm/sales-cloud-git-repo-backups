/****************************************************************************************************************************************
* Class Name  : Lessonly_UserController 
* Version     : 1.0 
* Created Date: 06-16-2022
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            06/16/2022            			  
*****************************************************************************************************************************************/

public class Lessonly_UserController {

    public class UserResponseWrapper{
        @AuraEnabled
        public String type; //users
        @AuraEnabled
        public Lessonly_User[] users;
        @AuraEnabled
        public Integer total_users; //7
        @AuraEnabled
        public Integer total_pages; //1
        @AuraEnabled
        public Integer page; //1
        @AuraEnabled
        public Integer per_page; //50
    }

    public class DeleteResponseWrapper{
        @AuraEnabled
        public String type; //delete_user
        @AuraEnabled
        public Integer id; //15475549
    }

    public class Lessonly_User {
        @AuraEnabled
        public Integer id; //12304986
        @AuraEnabled
        public String resource_type; //user
        @AuraEnabled
        public String ext_uid;
        @AuraEnabled
        public String email; //sandeep.joshi@intel.com
        @AuraEnabled
        public String name; //Sandeep Joshi
        @AuraEnabled
        public String role; //learner
        @AuraEnabled
        public Integer role_id; //88961
        @AuraEnabled
        public String archived_at;
        @AuraEnabled
        public String archived_by_user_id;
        @AuraEnabled
        public String job_title;
        @AuraEnabled
        public String business_unit;
        @AuraEnabled
        public String department;
        @AuraEnabled
        public String location;
        @AuraEnabled
        public String locale; //en
        @AuraEnabled
        public Date hire_date;
        @AuraEnabled
        public String manager_name;
        @AuraEnabled
        public boolean should_receive_email;
    }

    /**
     * Used in Seismic User Controller
     */
    @AuraEnabled
    public static boolean saveLessonlyUsers(){
        List<SeismicUserManagement_Temp__c> tempEmails = [SELECT Email__c from SeismicUserManagement_Temp__c limit 200];
        List<LessonlyUser__c> userList = new List<LessonlyUser__c>();
        UserResponseWrapper response;    
        LessonlyUser__c user;
            for (SeismicUserManagement_Temp__c userRecord : tempEmails){
                System.debug('Processing Email: '+ userRecord.Email__c);
                            
                try{
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint('https://api.lessonly.com/api/v1/users?filter[email]='+ userRecord.Email__c);
                    Blob headerValue = Blob.valueOf('inteldev:LWDfYbqDrHrQVs0rAMWKj8E4VVQK5jjP');
                    String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
                    request.setHeader('Authorization', authorizationHeader);
                    request.setMethod('GET');
                    HttpResponse response2 = http.send(request);
                    
                    if (response2.getStatusCode() == 200) {
                        String responseBody = response2.getBody();
                        response = (UserResponseWrapper) JSON.deserialize(responseBody, UserResponseWrapper.class);
                        for (Lessonly_User usersData : response.users) {               
                            System.debug('Inserting ' + usersData.Name);
                            user = new LessonlyUser__c();
                            user.Name = usersData.Name;
                            user.Name__c = usersData.Name;
                            user.User_Id__c = usersData.id;
                            user.Archived_By_User_Id__c = usersData.archived_by_user_id;
                            user.Business_Unit__c = usersData.business_unit;
                            user.Department__c = usersData.department;
                            user.Email__c = usersData.email;
                            user.Ext_Uid__c = usersData.ext_uid;
                            user.Hire_Date__c = usersData.hire_date;
                            user.Job_Title__c = usersData.job_title;
                            user.Locale__c = usersData.locale;
                            user.Location__c = usersData.location;
                            user.Manager_Name__c = usersData.manager_name;
                            user.Resource_Type__c = usersData.resource_type;
                            user.Role__c = usersData.role;
                            user.Role_Id__c = usersData.role_id;
                            user.Should_Receive_Email__c = usersData.should_receive_email;
                            userList.add(user);
                            System.debug('Completed Insertion ' + usersData.Name);
                        }
                            
                    }
                    else{
                        //no record found.
                    }
                }
                catch (Exception e) {
                    System.debug('The following exception has occurred in saveLessonlyUsers: ' + e.getMessage());
                }
                            
    
                //Make Lessonly API calls and save user details
                //Lessonly_UserController.saveLessonlyUsers(userRecord.Email__c);
                System.debug('Completed Processing Email: '+ userRecord.Email__c);

                //Add users in LessonlyUser__c

            }
         
            if(!userList.isEmpty())
            {
                insert userList ;
            }

        return true;
    }

   
    public static String deleteLessonlyUser(String user_id){
        DeleteResponseWrapper response;
        String message ='';
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://api.lessonly.com/api/v1/users/'+ user_id );
            Blob headerValue = Blob.valueOf('inteldev:LWDfYbqDrHrQVs0rAMWKj8E4VVQK5jjP');
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization', authorizationHeader);
            request.setMethod('DELETE');
            HttpResponse response2 = http.send(request);
            
            if (response2.getStatusCode() == 404) {
                String responseBody = response2.getBody();
                response = (DeleteResponseWrapper) JSON.deserialize(responseBody, DeleteResponseWrapper.class);
                message = 'User not found id: '+ user_id;
            }
			else if (response2.getStatusCode() == 204) {
                 message = 'User Deleted Sucessfully';
            }
            else{
                message = 'Unable to deleted user id '+ user_id;
            }
        }
        catch (Exception e) {
            message =  'The following exception has occurred: ' + e.getMessage();
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

        return message;
    }

    
    public static List<Lessonly_User> getLessonlyUsers_NOTINUSE(String filter){
        UserResponseWrapper response;
        //List<Lessonly_User> lessonly_Users;

        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://api.lessonly.com/api/v1/users?filter[email]='+ filter);
            Blob headerValue = Blob.valueOf('inteldev:LWDfYbqDrHrQVs0rAMWKj8E4VVQK5jjP');
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization', authorizationHeader);
            request.setMethod('GET');
            HttpResponse response2 = http.send(request);
            
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

        return response.users;
    }

    public static void saveLessonlyUser_NOTINUSE(Lessonly_User usersData){
        //Lessonly_User usersData = (Lessonly_User) JSON.deserialize(deletedData, Lessonly_User.class);
        //System.debug('Users:'+usersData);
        try{
            LessonlyUser__c user = new LessonlyUser__c();
            user.Name = usersData.Name;
            user.Name__c = usersData.Name;
            user.User_Id__c = usersData.id;
            user.Archived_By_User_Id__c = usersData.archived_by_user_id;
            user.Business_Unit__c = usersData.business_unit;
            user.Department__c = usersData.department;
            user.Email__c = usersData.email;
            user.Ext_Uid__c = usersData.ext_uid;
            user.Hire_Date__c = usersData.hire_date;
            user.Job_Title__c = usersData.job_title;
            user.Locale__c = usersData.locale;
            user.Location__c = usersData.location;
            user.Manager_Name__c = usersData.manager_name;
            user.Resource_Type__c = usersData.resource_type;
            user.Role__c = usersData.role;
            user.Role_Id__c = usersData.role_id;
            user.Should_Receive_Email__c = usersData.should_receive_email;
        

            insert user;
        }
        catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        //return usersData;
    }

    @AuraEnabled
    public static UserResponseWrapper getLessonlyUsers_NOTINUSE2(String filter){
        UserResponseWrapper response;

        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://api.lessonly.com/api/v1/users?filter[email]='+ filter);
            Blob headerValue = Blob.valueOf('inteldev:LWDfYbqDrHrQVs0rAMWKj8E4VVQK5jjP');
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization', authorizationHeader);
            request.setMethod('GET');
            HttpResponse response2 = http.send(request);
            
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

     
}