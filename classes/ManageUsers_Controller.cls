/****************************************************************************************************************************************
* Class Name  : ManageUsers_Controller 
* Version     : 1.0 
* Created Date: 06-16-2022
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            06/16/2022            			  This class make Lessionly API call to get user detail and delete user
*****************************************************************************************************************************************/

public class ManageUsers_Controller {

//Seismic Code Start here ******************************************
//**************************************************************** */
    
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

    @AuraEnabled
    public static TokenResponseWrapper getSeismicToken(){
        TokenResponseWrapper response;

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

        return response;
    }

    //Seismic Code Ends here ******************************************
    //**************************************************************** */



    /////Lessonly Code Starts Here**********************************************
    @AuraEnabled
    public static ResponseWrapper getUsers(string searchKey){
        ResponseWrapper response;

        try{
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //request.setEndpoint('https://api.lessonly.com/api/v1/users?filter[email]=sandeep.joshi@intel.com');
            request.setEndpoint('https://api.lessonly.com/api/v1/users?filter[email]='+ searchKey);
            Blob headerValue = Blob.valueOf('inteldev:LWDfYbqDrHrQVs0rAMWKj8E4VVQK5jjP');
            //Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization', authorizationHeader);
            request.setMethod('GET');
            HttpResponse response2 = http.send(request);
            
            if (response2.getStatusCode() == 200) {
                //String responseBody = '{ "type": "users", "users": [ { "id": 12304986, "resource_type": "user", "ext_uid": null, "email": "sandeep.joshi@gmail.com", "name": "Sandeep Joshi", "role": "learner", "role_id": 88961, "archived_at": null, "archived_by_user_id": null, "job_title": null, "business_unit": null, "department": null, "location": null, "locale": "en", "hire_date": null, "manager_name": null, "should_receive_email": true }, { "id": 12304990, "resource_type": "user", "ext_uid": 12345, "email": "test.test@gmail.com", "name": "test test", "role": "learner", "role_id": 88962, "archived_at": null, "archived_by_user_id": null, "job_title": null, "business_unit": null, "department": null, "location": null, "locale": "en", "hire_date": null, "manager_name": null, "should_receive_email": false }, { "id": 12304967, "resource_type": "user", "ext_uid": null, "email": "sachin.t@gmail.com", "name": "Sachin Tendulkar", "role": "learner", "role_id": 88950, "archived_at": null, "archived_by_user_id": null, "job_title": null, "business_unit": null, "department": null, "location": null, "locale": "en", "hire_date": null, "manager_name": null, "should_receive_email": true }, { "id": 12304800, "resource_type": "user", "ext_uid": null, "email": "Virat.K@gmail.com", "name": "Virat Kohli", "role": "learner", "role_id": 88700, "archived_at": null, "archived_by_user_id": null, "job_title": null, "business_unit": null, "department": null, "location": null, "locale": "en", "hire_date": null, "manager_name": null, "should_receive_email": false } ], "total_users": 7, "total_pages": 1, "page": 1, "per_page": 50 }';
                String responseBody = response2.getBody();
               // System.debug('Header Data for you dear 2:'+  responseBody);
                response = (ResponseWrapper) JSON.deserialize(responseBody, ResponseWrapper.class);
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


    public class ResponseWrapper{
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

    @AuraEnabled
    public static Lessonly_User saveDeletedUser(String deletedData){
        Lessonly_User usersData = (Lessonly_User) JSON.deserialize(deletedData, Lessonly_User.class);
        System.debug('Users:'+usersData);
       
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
       
        //Delete User Record
        deleteUser(String.valueOf(usersData.id));

        insert user;
              
        return usersData;
    }


    @AuraEnabled(cacheable=true)
    public static List<LessonlyUser__c> getDeletedUsers() {
        return [
            SELECT
                User_Id__c,
                Name__c,
                Email__c,
                Role__c,
                CreatedDate,
                LastModifiedById
            FROM LessonlyUser__c
            WITH SECURITY_ENFORCED
            LIMIT 100
        ];
    }

//////////////////Delete User
///////////////////////////////////////////////////////////////////
    @AuraEnabled
    public static DeleteResponseWrapper deleteUser(String user_id){
        DeleteResponseWrapper response;

        try{
            if(user_id != ''){
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                //request.setEndpoint('https://api.lessonly.com/api/v1/users?filter[email]=sandeep.joshi@intel.com');
                request.setEndpoint('https://api.lessonly.com/api/v1/users/'+ user_id );
                Blob headerValue = Blob.valueOf('inteldev:LWDfYbqDrHrQVs0rAMWKj8E4VVQK5jjP');
                //Blob headerValue = Blob.valueOf(username + ':' + password);
                String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
                request.setHeader('Authorization', authorizationHeader);
                request.setMethod('DELETE');
                HttpResponse response2 = http.send(request);
                
                if (response2.getStatusCode() == 200) {
                    //String responseBody = '{"type": "delete_user", "id": 15475549}';
                    String responseBody = response2.getBody();
                 System.debug('Header Data for you dear 2:'+  responseBody);
                   // response = (DeleteResponseWrapper) JSON.deserialize(responseBody, DeleteResponseWrapper.class);
                }
                else{
                    //no record found.
                }
            }
        }
        catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

        return response;
    }

    public class DeleteResponseWrapper{
        @AuraEnabled
        public String type; //delete_user
        @AuraEnabled
        public Integer id; //15475549
    }
 
}