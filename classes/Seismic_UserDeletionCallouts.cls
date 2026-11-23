public class Seismic_UserDeletionCallouts {
    public Integer Load_ID {get; set; } //"58df9a11-6f4d-88e5-7ad8-42e85041ed20",
    public String Email {get; set; }//: "abazzi@seismic.com",
    public String Seismic_ID {get; set; }//: "abazzi@seismic.com",
    public String Status {get; set; }//: "abazzi@seismic.com",
    public Integer Lessonly_ID {get; set; }//: "abazzi@seismic.com",
    public Boolean Deleted_In_Lessonly {get; set; }
    
    /*Delete Lessonly_Users by Id*/
    public static List<Seismic_UserDeletionCallouts> deleteLessonlyUsers(List<Seismic_UserDeletionCallouts> selectedRecords){
        String message ='';
        String msg ='';
        List<Seismic_UserDeletionCallouts> recordsToUpdate = new List<Seismic_UserDeletionCallouts>();
        try{
            //Iterate thru Seismic-Identified Users to delete from Seismic, Lessonly and update their flags           
            for(Seismic_UserDeletionCallouts userRecord : selectedRecords){
                msg = deleteLessonlyUser('999');//userRecord.Lessonly_ID__c
                if(msg == 'Deleted Sucessfully in Seismic') {
                    userRecord.Deleted_In_Lessonly = true;//Update Deleted_In_Lessonly__c flag
                }
                userRecord.Status = msg;
                recordsToUpdate.add(userRecord);
                System.debug(userRecord.Lessonly_ID + ' : ' + msg);
            }
        }
        catch (Exception e) {
            message =  'Error occurred in deleteLessonlyUsers: ' + e.getMessage();
        }
        
        System.debug(message);
        return recordsToUpdate;
    }
    
	/*Delete Lessonly_Users by Id*/
    public static String deleteLessonlyUser(String userId){
        Lessonly_UserResponseWrapper response;
        String message ='';
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://api.lessonly.com/api/v1/users/'+ userId );
            Blob headerValue = Blob.valueOf('inteldev:LWDfYbqDrHrQVs0rAMWKj8E4VVQK5jjP');
            //request.setEndpoint(Seismic_UserDeletion.config.get('Lessonly_UserAPIEndpoint') +'/'+ userId );
            //Blob headerValue = Blob.valueOf(Seismic_UserDeletion.config.get('Lessonly_APIAuthHeader'));
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization', authorizationHeader);
            request.setMethod('DELETE');
            HttpResponse response2 = http.send(request);
            
            if (response2.getStatusCode() == 404) {
                String responseBody = response2.getBody();
                response = (Lessonly_UserResponseWrapper) JSON.deserialize(responseBody, Lessonly_UserResponseWrapper.class);
                message = 'User not found in Lessonly #: '+ userId;
            }
			else if (response2.getStatusCode() == 204) {
                 message = 'Deleted in Lessonly';
            }
            else{
                message = 'Unable to deleted Lessonly user id '+ userId;
            }
        }
        catch (Exception e) {
            message =  'Error occurred in deleteLessonlyUser: ' + e.getMessage();
        }
        
		System.debug(message);
        return message;
    }
    
    
    
    /*Delete Lessonly_Users by Id*/
    public static Map<String, String> deleteLessonlyUsers_unused(Map<String, String> users){
        String message ='';
        String msg ='';
        Map<String, String> deletedUserList = new Map<String, String>();

        try{
            for (String key : users.keySet()) {
                msg = deleteLessonlyUser('99');//key
                deletedUserList.put(key, msg);
            }
        }
        catch (Exception e) {
            message =  'Error occurred in deleteLessonlyUsers: ' + e.getMessage();
        }
        
        System.debug(message);
        return deletedUserList;
    }
}