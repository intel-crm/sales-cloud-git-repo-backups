/****************************************************************************************************************************************
* Class Name  : Seismic_PIMResponseWrapper 
* Version     : 1.0 
* Created Date: 05/15/2023
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            05/15/2023               		The Apex Seismic_PIMResponseWrapper for PIM API Call 
* Sandeep Joshi            09/04/2023               		Updated to address Seismic API changes 
*****************************************************************************************************************************************/
public class Seismic_PIMResponseWrapper{// implements Queueable{//, Database.AllowsCallouts

    public List<Seismic_PIMCategory> categories {get; private set;}
       
    public class Seismic_PIMTokenResponse {
        public String access_token {get; set;}
        //public String token_type {get; set;}
        //public String expires_in {get; set;}
        //public String ext_expires_in {get; set;}
    }
    
    public class Seismic_PIMCategory { 
        @TestVisible public String displayName {get; set;}  
        @TestVisible public String guid {get; set;}  
        @TestVisible public String intelLabel {get; set;}  
        @TestVisible public String taggingPath {get; set;}
    }
    
    /*Get PIM Token*/
    // @Future(callout=true)
    public static String getPIMToken() {
        String bearerToken ='';
        System.debug('getPIMToken called');
 
        String client_id = Seismic_PIMDOVSync.config.get('PIM_client_id');//'192ac5e8-e44f-42c3-8444-017ee3bcefc4';
        String client_secret = Seismic_PIMDOVSync.config.get('PIM_client_secret');//'0Lt8Q~HvzaXvAwLpKM78FiZ6F0m7eu70QoSCsaD6';
        String endPoint = Seismic_PIMDOVSync.config.get('PIM_Token_endPoint');//'https://apis-sandbox.intel.com/v1/auth/token';
        String grant_type = 'client_credentials';
        
        Seismic_PIMTokenResponse response = new Seismic_PIMTokenResponse();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setMethod('POST');
        request.setEndpoint(endPoint);
        
        String payload = 'client_id='+EncodingUtil.urlEncode(client_id,'UTF-8')
            +'&grant_type='+EncodingUtil.urlEncode(grant_type,'UTF-8')
            +'&client_secret='+EncodingUtil.urlEncode(client_secret,'UTF-8');
        	
        request.setBody(payload);
        try{    
            HttpResponse response2 = http.send(request);
            String responseBody = response2.getBody();
            response = (Seismic_PIMTokenResponse) JSON.deserialize(responseBody, Seismic_PIMTokenResponse.class);
            bearerToken = response.access_token; 
        }
        catch (Exception e) {
            Seismic_PIMDOVSync_Notification.senderrorEmail('Error occurred in getPIMToken', 'Error occurred in getPIMToken : ' + e.getMessage());
            throw e;
        }
        
        return bearerToken;
    }   
    
    
     /*Get getContentHierarchy*/
   // @Future(callout=true)
    public static List<Seismic_PIMCategory> getContentHierarchy(String hierarchyId, String bearerToken) {
        System.debug('getContentHierarchy called :' + bearerToken);
        
        String endPoint = Seismic_PIMDOVSync.config.get('PIM_ContentHierarchy_endpoint') + hierarchyId;//'https://apis-sandbox.intel.com/pim/v1/services/synapticaLayer/hierarchies/' + hierarchyId;

        HttpResponse response2;
        Seismic_PIMResponseWrapper response;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        List<Seismic_PIMCategory> responseCat;
        request.setMethod('GET');
        request.setEndpoint(endPoint);
        request.setHeader('Authorization', 'Bearer ' + bearerToken);
        System.debug('getContentHierarchy called');
        try{
            response2 = http.send(request);
            String jsonString = response2.getBody().replace('"intel.com Label":', '"intelLabel":');
            jsonString = jsonString.replace('"intel.com Label":', '"intelLabel":');
            response = (Seismic_PIMResponseWrapper) JSON.deserialize(jsonString, Seismic_PIMResponseWrapper.class);
            responseCat = response.categories;
            
        }
        catch (Exception e) {
            Seismic_PIMDOVSync_Notification.senderrorEmail('Error occurred in getContentHierarchy for ' + hierarchyId, 'Error occurred in getContentHierarchy : ' + e.getMessage());
        	throw e;
        }
        
		return responseCat;
    }
    
    
}