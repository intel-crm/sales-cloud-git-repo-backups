public class Seismic_UserDeletion_Callout {

    public static String errorMessage = '';
    
    /*Access token for Graph API*/
    @TestVisible 
    public static HTTPResponse getAccessToken(){
        //Seismic_UserDeletion.initialize();
        String accessToken = '';
        String clientId = '';
        String clientSecret = '';
        String endPoint = '';
        String apiScope = '';
        
        //Initialization
        Map<String, Object> resGetBody = new Map<String, Object>();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HTTPResponse res = new HTTPResponse();
        
        System.debug('getAccessToken called');
        try{
            apiScope = 'https://graph.microsoft.com/.default';
            clientId = 'd27aaefe-a853-45a0-ab45-04ba27a230ad'; 
            clientSecret = 'fVB7Q~_7IXC1E6dClojFNBLkbb~OQ5LUKmB65'; 
            endPoint = 'https://login.microsoftonline.com/46c98d88-e344-4ed4-8496-4ed7712e255d/oauth2/v2.0/token';//
            req.setMethod('POST');
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setEndpoint(endPoint);
            req.setBody('grant_type=client_credentials' + '&client_id=' + clientId + '&client_secret=' + clientSecret + '&scope=' + apiScope);
            res = http.send(req);
            resGetBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            accessToken = (String)resGetBody.get('access_token'); 
        }
        catch (Exception e){
            //Seismic_UserDeletion.jobStatus = Seismic_JobStatus.Error;
            errorMessage = 'Error occurred in getAccessToken : ' + e.getMessage();
            System.debug(errorMessage);
       }
        return res;
    }
    
    @TestVisible 
    public static HttpResponse getAzureGroupMembers(String endPoint, String azureGroup, String accessToken){
        String CONTENT_TYPE='application/json';
        String CONTENT_TYPE_ACCEPT='application/json';
        String APPLICATION_CODE='SALESFORCE';
        Integer TIME_OUT=120000; 
        String METHOD='GET';  
        String employeeID;
        String email;
        String displayName;
        Set<String> missingUsers = new Set<String>();
        //accessToken = getAccessToken();
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HTTPResponse();
        Map<String, Object> responseGetBody = new Map<String, Object>();
        List<Object> lstData = new List<Object>();
        Map<String,Object> data = new Map<String, Object>();
        
        //if endpoint is blank set the endpoint to first Graph API link
        if(endPoint ==''){
            endPoint = 'https://graph.microsoft.com/v1.0/groups/' + azureGroup+ '/members?$format=JSON&$select=displayName,mail,extension_0f4113104c90419c9f4205e0384e2ac7_enterpriseID';  
        }
        
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setEndpoint(endPoint);
        request.setTimeout(TIME_OUT); // Maximum Timeout Period
        request.setMethod(METHOD);
        request.setHeader('applicationCd', APPLICATION_CODE);
        request.setHeader('Content-Type', CONTENT_TYPE);
        request.setHeader('accept', CONTENT_TYPE_ACCEPT);
        try{
            response = http.send(request);
            responseGetBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            //Seismic_UserDeletion.NextLink = (String)responseGetBody.get('@odata.nextLink');
            
            if(response.getStatusCode() == 200){
                lstData = (list<Object>)responseGetBody.get('value');
                
                for(Object fld : lstData){
                    data.clear();
                    data = (Map<String,Object>)fld;
                    email = String.valueOf(data.get('mail'));
                    displayName = String.valueOf(data.get('displayName'));
                    employeeID = String.valueOf(data.get('extension_0f4113104c90419c9f4205e0384e2ac7_enterpriseID'));
                    if (employeeID != null){ 
                        missingUsers.add(email);
                        //System.debug(displayName + '_' + email + '_' + employeeID);
                    }
                }
            }
            
        }
        catch (Exception e){
            //Seismic_UserDeletion.jobStatus = Seismic_JobStatus.Error;
            errorMessage = 'Error occurred in getAzureGroupMembers : ' + e.getMessage();
        }
        
        return response;
    }
}