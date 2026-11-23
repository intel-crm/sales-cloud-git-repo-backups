/**************************************************************************************
Apex Class Name:  Core_WebServiceUtility
Version     : 1.0 
Created Date: 11 NOV 2014
Function    : Utility methods to handle generic Webservice Callout
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             11/11/2014              Original Version
*************************************************************************************/
public class Core_WebServiceUtility{
    
    public static final Integer TIME_OUT=60000; 
    public static final string METHOD='GET'; 
    public static final string CONTENT_TYPE='Content-Type';
    public static final string CONTENT_TYPE_JSON='application/json;charset=UTF-8';
    public static final string API_KEY='API_KEY';


   

    /*
    * Method name  : httpRequestResposeHandler
    * Description  : Used to construct http request and send back http respose back
    * Return Type  : VOID
    * Parameter    : String sBody, String sEndPointUrl, String sMethod, String sTimeOut
    */
    public static HTTPResponse restServiceCallout(String sBody, String sEndPointUrl, String sMethod, String sTimeOut, String sSystemCred){
         system.debug('---------------sEndPointUrl------------------' + sEndPointUrl); 
         
              /*
    
         //--------------------Basic Authorization---------Starting-----------
        HttpRequest httpReq = new HttpRequest();
        HTTPResponse httpResp = new HTTPResponse();
        
        //Get the System Credential record using the sSystemCred variable passed through the method
        Core_System_Credentials__c sObjRecSystemCred = Core_System_Credentials__c.getValues(sSystemCred);

        // Construct the Http Request and Response instances 
        Http http = new Http();
        httpReq.setMethod('GET');
        httpReq.setEndpoint(sEndPointUrl);
        
        // Add the the iPaas service to authenticate without an authentication context
        String sUsername = sObjRecSystemCred.Core_UserName__c ;
        String sPassword = sObjRecSystemCred.Core_Password__c ;
        Blob bAuthValue = Blob.valueOf(sUsername+ ':' + sPassword);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(bAuthValue);
        httpReq.setHeader('Authorization', authorizationHeader);
        httpReq.setTimeout(Integer.Valueof(sTimeOut));
        
        //Make the callout to the service
        httpResp = http.send(httpReq);
        
        // return the constructed http response
        return httpResp; 

         //--------------------Basic Authorization---------Ending-----------
     
      //--------------------Point to Point integration---------Starting-----------   
                String str_response= '';
                String acessToken =''; 
                Http http = new Http();
                HttpRequest requestAccessToken = new HttpRequest();
                HttpRequest request = new HttpRequest();
                HttpResponse response =new HttpResponse();
                
        try
        {
                //Get Token using Client Id and Client Secret
                system.debug('---------------Callout_OATH------------------' );
                    requestAccessToken.setEndpoint(Core_SalesCRM_APIGEE__c.getValues('AuthtokenURL').Value__c);                    
                    requestAccessToken.setBody(Core_SalesCRM_APIGEE__c.getValues('AccessToken').Value__c);                
                   
                    requestAccessToken.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    
                    requestAccessToken.setMethod('POST');
                    requestAccessToken.setTimeout(40000);            
                    HttpResponse responseAccessToken = http.send(requestAccessToken);
                    if(responseAccessToken.getStatusCode() == 200) { 
                        system.debug('---------------responseAccessToken.getStatusCode() == 200------------------' );
                        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(responseAccessToken.getBody());
                        acessToken = (String)results.get('access_token');           
                            
                        request.setEndpoint(sEndPointUrl);              
                        request.setHeader('Authorization', 'Bearer '+acessToken);
                        request.setMethod('GET');
                        request.setTimeout(60000);            
                        response = http.send(request);      
                       
                        if(response.getStatusCode() == 200) {                           
                            str_response= response.getBody();
                            system.debug('------'+ str_response);
                            }
                    }
                    else
                    {
                        system.debug('Callout Failed : ' + responseAccessToken.getStatusCode());
                    }
        }
        catch(Exception ex){
                system.debug('-------------Exception----');
                system.debug('ex0:'+ex.getCause());
        }
        return response;
   
         //----------Point to Point integration---------Ending-----------
    
   */ 
  
         //----------Named Credentials integration---------Starting-----------
        HttpRequest request= new HttpRequest();
        HTTPResponse response= new HTTPResponse();
        request.setEndpoint(sEndPointUrl); 
        system.debug('EndPoint:' + request.getEndpoint());
        Http http = new Http();
        request.setMethod(METHOD);
        request.setTimeout(TIME_OUT);
        request.setHeader(CONTENT_TYPE, CONTENT_TYPE_JSON);
    
       try {
       
        response= http.send(request);
        system.debug('response:' + response.getBody());

        if (response != Null && response.getStatusCode() == 200) {           
            System.debug('---------------200----------');
        }
        //if the status code is not 200, then exception
        else {
             System.debug('---------------NOT 200----------');
            //formulate JSON data
          
            if (response != Null) {
               system.debug('Callout Failed : ' + response.getStatusCode());
            }
        }
    } catch (Exception e) {
      
        system.debug('Callout Exception:' + e.getMessage());
    } finally {

    }
 
       //----------Named Credentials integration---------Ending-----------
         return response;

    }
    
public static HTTPResponse ServiceCallout(String sBody, String sEndPointUrl, String sMethod, String sTimeOut, String sSystemCred){
        
        system.debug('--------ServiceCallout-------sEndPointUrl---' + sEndPointUrl); 
        HttpRequest httpReq = new HttpRequest();
        HTTPResponse httpResp = new HTTPResponse();
      try {
        //Get the System Credential record using the sSystemCred variable passed through the method
        Core_System_Credentials__c sObjRecSystemCred = Core_System_Credentials__c.getValues(sSystemCred);

        // Construct the Http Request and Response instances 
        Http http = new Http();
        httpReq.setMethod('GET');
        httpReq.setEndpoint(sEndPointUrl);
        
        // Add the the iPaas service to authenticate without an authentication context
        String sUsername = sObjRecSystemCred.Core_UserName__c ;
        String sPassword = sObjRecSystemCred.Core_Password__c ;
        Blob bAuthValue = Blob.valueOf(sUsername+ ':' + sPassword);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(bAuthValue);
        httpReq.setHeader('Authorization', authorizationHeader);
        httpReq.setTimeout(Integer.Valueof(sTimeOut));
        
        //Make the callout to the service
        httpResp = http.send(httpReq);
          
      } catch (Exception e) {
      
        system.debug('Callout Exception:' + e.getMessage());
    } finally {

    }
        
        // return the constructed http response
        return httpResp;      
    }
    
}