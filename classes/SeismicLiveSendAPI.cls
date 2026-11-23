/****************************************************************************************************************************************
* Class Name  : SeismicLiveSendAPI 
* Version     : 1.0 
* Created Date: 10-06-2021
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Saif Alam            10/06/2021                 REST Endpoint created for Seismic to call that validates email addresses.If 
                                                  HasOptedOutOfEmail or Core_Sales_Do_Not_Contact_Ind__c or Core_Contact_Export_Compliance_Block__c 
                                                  is checked for a contact that matches the email then validation fails.
                                                  If HasOptedOutOfEmail or Core_Do_not_call__c is checked for a lead that matches the email then
                                                  validation fails.If there are no matching Contact or Lead for the email address then the validation passes.
* Sandeep Joshi		   06/27/2023				  added Core_Enterprise_Id__c to API response
*****************************************************************************************************************************************/
// Setting up the Request URL
@RestResource(urlMapping='/SeismicLiveSendAPI/*')
global with sharing class SeismicLiveSendAPI {
    
    // POST Method
    @HTTPPost
    global static List<Map<String, String>> Validate( List<String> emailAddresses) {
        String emailVar;
        String messageVar;
        String statusVar;
        String enterpriseId;
        String SUCCESS_CODE_200 = '200';
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
        firstContactList= [Select Id,Email,HasOptedOutOfEmail,Core_Sales_Do_Not_Contact_Ind__c,Core_Contact_Export_Compliance_Block__c, Core_Enterprise_Id__c  
                           from Contact where Email in :emailAddresses];
        firstLeadList= [Select Id,Email,HasOptedOutOfEmail,Core_Do_not_call__c from Lead where Email in :emailAddresses];
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
            enterpriseId=null;
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
                //enterprise id
                if (firstContactMap.get(email) != null && firstContactMap.get(email).Core_Enterprise_Id__c != null) {
                    enterpriseId = firstContactMap.get(email).Core_Enterprise_Id__c;
                }
            }
            
            // Add email address to return payload
            responseSingleMap.put('status', statusVar);
            responseSingleMap.put('message', messageVar);
            responseSingleMap.put('email', email);
            
            if(enterpriseId!=null){
                responseSingleMap.put('enterpriseId', enterpriseId);   
            }
              
            
            // ------------------------------------------------------------------- 
            // Add to return list of map for each email address
            responseMap.add(responseSingleMap);
            // logging
            SeismicResponseWrapper seismicWrapp = new SeismicResponseWrapper();
            seismicWrapp.email = email;
            seismicWrapp.message = messageVar;
            seismicWrapp.status =statusVar;
            if(enterpriseId!=null){
                seismicWrapp.enterpriseId =enterpriseId;
            }
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
        
        public String email {get;set;}
        public String status {get;set;}
        public String message{get;set;}
        public String enterpriseId{get;set;}
        
    }

}