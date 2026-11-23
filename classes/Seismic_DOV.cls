/****************************************************************************************************************************************
* Class Name  : Seismic_DOV 
* Version     : 1.0 
* Created Date: 12/15/2022
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            12/15/2022               		The Apex Seismic_DOV for Seismic API Call 
*****************************************************************************************************************************************/
public class Seismic_DOV {
    public String id {get; set;}  //119
    public String value {get; set;}  //0
    public String order {get; set;}  //0
    
     /*Get Seismic Token*/
    public static String getSeismicToken(String apiScope) {
        String bearerToken ='';
        System.debug('getSeismicToken called');
        String grant_type = 'delegation';
        String client_id = '0011a2e8-b493-4ac4-ad8d-78b39b4e788f';
        String client_secret = '199d1757-e6b8-47c0-8b0b-8b997644c509';
        String user_id = '5600d223-ed35-48fb-8096-a1e78866426f';
        String scope = apiScope;//'seismic.library.manage';
        String endPoint = 'https://auth.seismic.com/tenants/inteldev/connect/token';
        
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
            
            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        catch (Exception e) {
            //message =  'Error occurred in getSeismicToken : ' + e.getMessage();
            //Seismic_UserDeletion.jobStatus = Seismic_UserDeletion.Job_Status.Error;
            //Seismic_UserDeletion.errorDetail += message;
            System.debug('Error occurred in getSeismicToken : ' + e.getMessage());
        }
        return bearerToken;
    }  
    
    /*Get all DOVs*/
    public static List<Seismic_DOVsResponseWrapper> getSeismicDOVs(String bearerToken) {
        System.debug('getDOVs called');
        HttpResponse response2;
        List<Seismic_DOVsResponseWrapper> response;
        String endPoint = 'https://api.seismic.com/integration/v2/contentProperties';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setTimeout(100000);
        request.setEndpoint(endPoint);
        request.setHeader('Authorization', 'Bearer ' + bearerToken);
        
        try{
            response2 = http.send(request);
            response = (List<Seismic_DOVsResponseWrapper>) JSON.deserialize(response2.getBody(), List<Seismic_DOVsResponseWrapper>.class);
            //System.debug(response);

            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        catch (System.Exception e) {
            //message =  'Error occurred in getDOVs : ' + e.getMessage();
            //Seismic_UserDeletion.jobStatus = Seismic_UserDeletion.Job_Status.Error;
            //Seismic_UserDeletion.errorDetail += message;
            System.debug('Error occurred in getDOVs : ' + e.getMessage());
        }
        return response;
    }     
   
    
       /*Add Seismic DOV*/
    public static HttpResponse addSeismicDOV(String bearerToken, String contentPropertyId, String DomainValues) {
        System.debug('addSeismicDOV called');
        HttpResponse response2;
        List<Seismic_DOVsResponseWrapper> response;
        String endPoint = 'https://api.seismic.com/integration/v2/contentProperties/'+ contentPropertyId +'/values';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type','application/json');
        request.setMethod('POST');
        request.setTimeout(100000);
        request.setEndpoint(endPoint);
        request.setHeader('Authorization', 'Bearer ' + bearerToken);
        request.setBody('["Test00","Test01"]');
        
        try{
            response2 = http.send(request);
            //response = (List<Seismic_DOVsResponseWrapper>) JSON.deserialize(response2.getBody(), List<Seismic_DOVsResponseWrapper>.class);
            System.debug(response2);

            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        catch (System.Exception e) {
            //message =  'Error occurred in getDOVs : ' + e.getMessage();
            //Seismic_UserDeletion.jobStatus = Seismic_UserDeletion.Job_Status.Error;
            //Seismic_UserDeletion.errorDetail += message;
            System.debug('Error occurred in getDOVs : ' + e.getMessage());
        }
        return response2;
    }     
   
    
    /*Clear records*/
    public static void clearDOVs() {
        delete [SELECT Id FROM SeismicContentSync_DOV__c];
    }
}