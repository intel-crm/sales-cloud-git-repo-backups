/*********************************************
* Name : Core_IPS_BES_Transaction_Track 
* Author : Chandrashekar Pallikonda
* Date Created : 
* Description : When an BES error log is created, this class sends the error details to trasaction tracking API.
*   
************************************************/ 
public with sharing class Core_IPS_BES_Transaction_Track {//After 0Pk1J000000KywA changes 22102024
    /* Start ---- Tushar----Added part of vanuability changes*/
    @TestVisible
    private static Boolean isValidSalesforceId(String idStr) {
        if (String.isBlank(idStr)) return false;
        try {
            Id validId = Id.valueOf(idStr);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
	/* End ---- Tushar----Added part of vanuability changes*/
    @future(callout=true)
    public static void sendTransactionDetails(String errorId, String outboundId, String inboundId, String errorCode) {
        List<Core_IPS_BES_Error_Log__c> errorRec = new List<Core_IPS_BES_Error_Log__c>() ;
        List<Core_IPS_BES_Outbound_Message__c> outboundRec = new List<Core_IPS_BES_Outbound_Message__c>();
        List<Core_IPS_BES_Inbound_Message__c> inboundRec = new List<Core_IPS_BES_Inbound_Message__c>();
        try {
            System.debug('inside transaction track callout class-Core_IPS_BES_Transaction_Track21102024');
            //TWC745-6469//String integrationName = 'Core_IPS_Transaction_Tracking';//TWC745-6469-IPS Named Credentials chnage- Gangadhar
            //TWC745-6469//String endPointURL = Core_IPS_System_Credentails_Apigee__c.getInstance(integrationName).Core_IPS_EndPointURL__c;
            //TWC745-6469//String accessToken = Core_IPS_APIGEE_Utility.generateAccessToken1(integrationName);
            String endPointURL = 'callout:Core_IPS_Transaction_Tracking_NamedCred';
			// Tushar ---- Added isValidSalesforceId as part of vanuability
            if (isValidSalesforceId(errorId) && Core_IPS_BES_Error_Log__c.SObjectType.getDescribe().isAccessible()) {
                errorRec = [SELECT Core_IPS_Status__c, Core_IPS_Error_Description__c FROM Core_IPS_BES_Error_Log__c WHERE Id = :errorId];
            }
            // Tushar ---- Added isValidSalesforceId as part of vanuability
            if (isValidSalesforceId(outboundId) && Core_IPS_BES_Outbound_Message__c.SObjectType.getDescribe().isAccessible()) {
                outboundRec = [SELECT Core_IPS_Case_ID__c, Name FROM Core_IPS_BES_Outbound_Message__c WHERE Id = :outboundId];
            }
            // Tushar ---- Added isValidSalesforceId as part of vanuability
            if (isValidSalesforceId(inboundId) && Core_IPS_BES_Inbound_Message__c.SObjectType.getDescribe().isAccessible()) {
                inboundRec = [SELECT Name FROM Core_IPS_BES_Inbound_Message__c WHERE Id = :inboundId];
            }

            String jsonBody = formJson((errorRec.size() > 0) ? errorRec[0] : null, (outboundRec.size() > 0) ? outboundRec[0] : null, (inboundRec.size() > 0) ? inboundRec[0] : null, errorCode);
            
            //TWC745-6469//if(String.isNotBlank(accessToken)) { 
                System.debug('inside transaction track callout class 22102024'+endPointURL);
                Http calloutreq = new Http(); 
                HttpRequest postRequest = new HttpRequest();
                postRequest.setMethod('POST');
                postRequest.setEndpoint(endPointURL);
                postRequest.setHeader('content-type', 'application/json');               
                //TWC745-6469//postRequest.setHeader(Label.Core_Apigee_Auth, 'Bearer ' + accessToken);
                postRequest.setBody(jsonBody);
                System.debug('Named cred test 22102024'+jsonBody);
                postRequest.setTimeout(12000);
                HttpResponse response = calloutreq.send(postRequest); 
                System.debug('Named cred response test 23102024'+response);
                if (!errorRec.isEmpty()) {
                    if (response.getStatusCode() == 200) {
                        System.debug('Post succesful details NamedCred Test23102024: '+response.getBody());
                        if (Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Transaction_Track_Status__c.isUpdateable()) {
                            errorRec[0].Transaction_Track_Status__c = 'Sent Successfully';
                        }
                    } else {
                        System.debug('Post Failed, details: '+response.getBody());
                        errorRec[0].Transaction_Track_Status__c = 'Failed';
                    }
                    update errorRec;
                }
            //TWC745-6469//}
        } catch (Exception e ) {
          System.debug('Exception occured in transaction tracking'+ e.getStackTraceString());
        }
    }
    
    public static String formJson(Core_IPS_BES_Error_Log__c logRec, Core_IPS_BES_Outbound_Message__c outbound, Core_IPS_BES_Inbound_Message__c inbound, String error) {
        String body ='';
        Case cs = new Case();
        try{
            if(outbound!=null && outbound.Core_IPS_Case_ID__c !=null && Case.SObjectType.getDescribe().isQueryable()){
                cs = [SELECT Id, Core_IPS_New_Backend_System__c,Core_IPS_New_Backend_System__r.Name FROM Case WHERE Id=: outbound.Core_IPS_Case_ID__c];
            }
            JSONGenerator jsonGen = JSON.createGenerator(true);
            jsonGen.writeStartObject();
            if(outbound!=null){
                jsonGen.writeStringField('SourceSystem', 'IPS');
            } else if(inbound!=null){
                jsonGen.writeStringField('SourceSystem', 'HSD');
            }
            jsonGen.writeStringField('ApplicationName', 'IPS');
            if(outbound!=null){
                jsonGen.writeStringField('MessageId', outbound.Name);
            } else if(inbound!=null){
                jsonGen.writeStringField('MessageId', inbound.Name);
            }
            if(outbound!=null){
                jsonGen.writeStringField('CaseId',  outbound.Core_IPS_Case_ID__c);
            } else {
                jsonGen.writeNullField('CaseId');
            }
            if(cs.Core_IPS_New_Backend_System__c!=null){
                jsonGen.writeStringField('BackendId', cs.Core_IPS_New_Backend_System__r.Name);
            } else {
                jsonGen.writeNullField('BackendId'); 
            }
            if(logRec.Core_IPS_Status__c !='' && logRec.Core_IPS_Status__c!=null){
                jsonGen.writeStringField('Status',  logRec.Core_IPS_Status__c);
            } else {
                jsonGen.writeNullField('Status');
            }
            if(error!=null){
                jsonGen.writeStringField('StatusCode',  error);
            } else {
                jsonGen.writeNullField('StatusCode');
            }
            if(logRec.Core_IPS_Error_Description__c !='' && logRec.Core_IPS_Error_Description__c!=null) {
                jsonGen.writeStringField('Description', logRec.Core_IPS_Error_Description__c);
            } else {
                jsonGen.writeNullField('Description');
            }
            jsonGen.writeStringField('Stage',  '');
            jsonGen.writeEndObject();
            body = jsonGen.getAsString();
            if(String.isNotBlank(body)){
                return body;
            }
        }catch(Exception e){
            //System.debug('excp1'+e.getMessage()+'trace'+e.getStackTraceString());
        }
        return null;
        
    }
}