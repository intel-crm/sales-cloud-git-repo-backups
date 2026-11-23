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

    /*
    * Method name  : httpRequestResposeHandler
    * Description  : Used to construct http request and send back http respose back
    * Return Type  : VOID
    * Parameter    : String sBody, String sEndPointUrl, String sMethod, String sTimeOut
    */
    public static HTTPResponse restServiceCallout(String sBody, String sEndPointUrl, String sMethod, String sTimeOut, String sSystemCred){
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
    }
}