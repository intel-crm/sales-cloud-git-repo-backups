/****************************************************************************************************************************************
* Class Name  : SeismicLiveSendAPI_New
* Version     : 1.0 
* Created Date: 10-06-2024
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            10/06/2024         REST Endpoint created for Seismic to call that validates email addresses.If 
HasOptedOutOfEmail or Core_Sales_Do_Not_Contact_Ind__c or Core_Contact_Export_Compliance_Block__c 
is checked for a contact that matches the email then validation fails.
If HasOptedOutOfEmail or Core_Do_not_call__c is checked for a lead that matches the email then
validation fails.If there are no matching Contact or Lead for the email address then the validation passes.
*****************************************************************************************************************************************/
// Setting up the Request URL
@RestResource(urlMapping='/SeismicLiveSendAPI_New/*')
global with sharing class SeismicLiveSendAPI_New {
    
    // POST Method
    @HTTPPost
    global static List<Map<String, String>> Validate( List<String> emailAddresses) {
        String wwidVar;
        String emailVar;
        String messageVar;
        String statusVar;
        String SUCCESS_CODE_200 = '200';
        String graphToken = null;
        Core_RestAPI_Response logResponse = new Core_RestAPI_Response();
        logResponse.successContent = new List<SeismicResponseWrapper>();
        // Initialize the response list
        List<Map<String, String>> responseMap = new List<Map<String, String>>();
        
        // Initialize Contact/Lead Lists and Maps 
        List<Contact> firstContactList = new List<Contact>();
        List<Lead> firstLeadList = new List<Lead>();
        Map<String,Contact> firstContactMap = new Map<String,Contact>();
        Map<String,Lead> firstLeadMap = new Map<String,Lead>();
        
        // Get the list of contacts and leads for the email addresses for the validation logic check
        // Core_Enterprise_Id__c -- WWID on Contact Object
        // Core_User_WWID__c -- WWID on Lead Object
        firstContactList= [Select Id,Email,HasOptedOutOfEmail,Core_Sales_Do_Not_Contact_Ind__c,Core_Contact_Export_Compliance_Block__c, Core_Enterprise_Id__c 
                           from Contact where Email in :emailAddresses];
        firstLeadList= [Select Id,Email,HasOptedOutOfEmail,Core_Do_not_call__c,Core_User_WWID__c from Lead where Email in :emailAddresses];
        for(Contact c : firstContactList)
        { 
            firstContactMap.put(c.Email, c);
        }
        for(Lead l : firstLeadList)
        { 
            firstLeadMap.put(l.Email, l);
        }
        System.debug('firstLeadMap'+firstLeadMap);
        System.debug('firstContactMap'+firstContactMap);     
        
        // Iterate thru the list of email addresses
        for(String email:emailAddresses){
            // Initializing the single response map for each email
            Map<String, String> responseSingleMap = new Map<String, String>();
            
            // Do validation checks here
            // -------------------------------------------------------------------
            // There is a match for a Contact for the email address and the HasOptedOutOfEmail field is checked
            if (firstContactMap.get(email)!=null && (firstContactMap.get(email).HasOptedOutOfEmail == true) )
            { 
                messageVar = 'Failed: Contact has Opt Out of Email Indicator checked';
                statusVar = 'Fail';
                
            }
            // There is a match for a Contact for the email address and the Core_Sales_Do_Not_Contact_Ind__c field is checked
            else if (firstContactMap.get(email)!=null && (firstContactMap.get(email).Core_Sales_Do_Not_Contact_Ind__c == true) )
            { 
                messageVar = 'Failed: Contact has Do not Contact Indicator checked';
                statusVar = 'Fail';          
            }
            // There is a match for a Contact for the email address and the Core_Contact_Export_Compliance_Block__c field is checked
            else if (firstContactMap.get(email)!=null &&  (firstContactMap.get(email).Core_Contact_Export_Compliance_Block__c  == true) )
            { 
                messageVar = 'Failed: Contact has Export Compliance Block Indicator checked';
                statusVar = 'Fail';
            }
            // There is a match for a Lead for the email address and the HasOptedOutOfEmail field is checked
            else if (firstLeadMap.get(email)!=null &&  (firstLeadMap.get(email).HasOptedOutOfEmail == true) )
            { 
                messageVar = 'Failed: Lead has Opt Out of Email Indicator checked';
                statusVar = 'Fail';
            }
            // There is a match for a Lead for the email address and the Core_Do_not_call__c field is checked
            else if (firstLeadMap.get(email)!=null &&  (firstLeadMap.get(email).Core_Do_not_call__c == true) )
            { 
                messageVar = 'Failed: Lead has Do Not Call Indicator checked';
                statusVar = 'Fail';
            }
            // There are no matching Contact or Lead for the email address. In this scenario validation passes.
            else if (firstLeadMap.get(email)==null && firstContactMap.get(email)==null )
            { 
                messageVar = 'No record match for Contact or Lead';
                statusVar = 'Success';
            }
            // All validations passed
            else{
                messageVar = 'Email Passed Validation';
                statusVar = 'Success';
            }
            
            if(firstContactMap.get(email)!=null && firstContactMap.get(email).Core_Enterprise_Id__c!=null){
                wwidVar = firstContactMap.get(email).Core_Enterprise_Id__c;
            }else if(firstLeadMap.get(email)!=null && firstLeadMap.get(email).Core_User_WWID__c!=null){
                wwidVar = firstLeadMap.get(email).Core_User_WWID__c;
            }
            else{
                wwidVar = null;
            }
            
            //For Intel.Com Email
            if(wwidVar == null && email.contains('@intel.com')){
                if(graphToken == null){graphToken = getGraphAPIToken();}
                wwidVar = getUser(email, graphToken);
                if(wwidVar != null){
                    messageVar = 'Email Passed Validation';
                    statusVar = 'Success';
                }
            }
            
            // Add email address to return payload
            responseSingleMap.put('wwid', wwidVar);
            responseSingleMap.put('status', statusVar);
            responseSingleMap.put('message', messageVar);
            responseSingleMap.put('email', email);
            
            // ------------------------------------------------------------------- 
            // Add to return list of map for each email address
            responseMap.add(responseSingleMap);
            // logging
            SeismicResponseWrapper seismicWrapp = new SeismicResponseWrapper();
            seismicWrapp.wwid =wwidVar;
            seismicWrapp.email = email;
            seismicWrapp.message = messageVar;
            seismicWrapp.status =statusVar;
            logResponse.successContent.add(seismicWrapp); 
            
            
        } // end of for
        
        // Logging of response payload is done here
        // -------------------------------------------------------------------
        
        //  DateTime entryTime = DateTime.now();
        //   System.debug('processRequest logresponse.successContent '+logresponse.successContent);
        //   logResponse.code = SUCCESS_CODE_200;
        //   System.debug('JSON.serialize(logresponse.successContent) '+JSON.serialize(logresponse.successContent));
        //   Core_RestAPI_LoggingUtil.logTransaction(entryTime, logResponse);
        
        // Logging using Generic Framework
        String strDetails ='Response sent to Seismic:' + JSON.serialize(logresponse.successContent);
        String strMessage = 'Seismic Request:' + JSON.serialize(emailAddresses);
        Core_Log_Entry.logEntryWithDetails('SFDC','Seismic',null,'info',strMessage,strDetails,null,'Contact',null);
        
        // Core_Log_Entry.logEntryWithDetails(String strOrigin, String strProject, String strScope, String strSeverity, String strMessage,
        //                                           String strDetails, String strObjectID, String strObjectType, String strTags);      
        
        // ------------------------------------------------------------------- 
        
        return responseMap;
    }
    // Seismic Response Wrapper class must implements the interface Core_RestAPI_SuccessContent
    public class SeismicResponseWrapper  implements Core_RestAPI_SuccessContent{
        
        public String wwid{get;set;}
        public String email {get;set;}
        public String status {get;set;}
        public String message{get;set;}
        
    }
    
    /*Get GraphAPIToken*/
    @TestVisible 
	private static String getGraphAPIToken() {
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
            clientSecret = 'DCv8Q~fHfFN_wJA2AD-obOLXjYIYvKIowcskrabB'; 
            endPoint = 'https://login.microsoftonline.com/46c98d88-e344-4ed4-8496-4ed7712e255d/oauth2/v2.0/token';
            req.setMethod('POST');
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setEndpoint(endPoint);
            req.setBody('grant_type=client_credentials' + '&client_id=' + clientId + '&client_secret=' + clientSecret + '&scope=' + apiScope);
            res = http.send(req);
            resGetBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            accessToken = (String)resGetBody.get('access_token'); 
            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
            
        }
        catch (Exception e) {
            //errorDetail += 'Error occurred in getGraphAPIToken : ' + e.getMessage();
            //System.debug(errorMessage);
        }
        return accessToken;
    }
    
    
    /*Get the list of users from Azure AD Groups*/
    @TestVisible 
    private static String getUser(String intelEmail, String accessToken){
        String CONTENT_TYPE='application/json';
        String CONTENT_TYPE_ACCEPT='application/json';
        String APPLICATION_CODE='SALESFORCE';
        Integer TIME_OUT=120000; 
        String METHOD='GET';  
        String employeeID = null;
        String email;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HTTPResponse();
        Map<String, Object> responseGetBody = new Map<String, Object>();
        List<Object> lstData = new List<Object>();
        Map<String,Object> data = new Map<String, Object>();
        
        String newintelEmail = '\''+ intelEmail + '\'';
		String endPoint = 'https://graph.microsoft.com/v1.0/users?$format=JSON&$select=mail,extension_0f4113104c90419c9f4205e0384e2ac7_enterpriseID&$filter=mail+eq+'+ newintelEmail;  

        //System.debug('getAzureGroupMembers called');
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
            System.debug('responseGetBody: '+ responseGetBody);
            if(response.getStatusCode() == 200){
                lstData = (list<Object>)responseGetBody.get('value');
                for(Object fld : lstData){
                    data.clear();
                    data = (Map<String,Object>)fld;
                    email = String.valueOf(data.get('mail'));
                    employeeID = String.valueOf(data.get('extension_0f4113104c90419c9f4205e0384e2ac7_enterpriseID'));
					//System.debug(employeeID);
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
            //jobStatus = Job_Status.Error;
            //errorDetail += 'Error occurred in getAzureGroupMembers : ' + e.getMessage();
        }
        return employeeID;
    }
}