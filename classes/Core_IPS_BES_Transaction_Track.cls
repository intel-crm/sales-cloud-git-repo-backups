/*********************************************
* Name : Core_IPS_BES_Transaction_Track 
* Author : Chandrashekar Pallikonda
* Date Created : 
* Description : When an BES error log is created, this class sends the error details to trasaction tracking API.
*   
************************************************/ 
public with sharing class Core_IPS_BES_Transaction_Track {
    @future(callout=true)
    public static void sendTransactionDetails(String errorId, String outboundId, String inboundId, String errorCode) {
        List<Core_IPS_BES_Error_Log__c> errorRec = new List<Core_IPS_BES_Error_Log__c>() ;
        List<Core_IPS_BES_Outbound_Message__c> outboundRec = new List<Core_IPS_BES_Outbound_Message__c>();
        List<Core_IPS_BES_Inbound_Message__c> inboundRec = new List<Core_IPS_BES_Inbound_Message__c>();
        try {
            
	    String endPointURL = 'callout:Core_IPS_Transaction_Tracking_NamedCred';
            if(Core_IPS_BES_Error_Log__c.SObjectType.getDescribe().isAccessible()){
            errorRec = [select Core_IPS_Status__c,Core_IPS_Error_Description__c from Core_IPS_BES_Error_Log__c where Id=:errorId];
            }
            if(Core_IPS_BES_Outbound_Message__c.SObjectType.getDescribe().isAccessible()){
            outboundRec = [select Core_IPS_Case_ID__c,Name from Core_IPS_BES_Outbound_Message__c where Id=:outboundId];
            }
            if(Core_IPS_BES_Inbound_Message__c.SObjectType.getDescribe().isAccessible()){
            inboundRec = [select Name from Core_IPS_BES_Inbound_Message__c where Id=:outboundId];
            }
            String jsonBody = formJson((errorRec.size() > 0) ? errorRec[0] : null, (outboundRec.size() > 0) ? outboundRec[0] : null, (inboundRec.size() > 0) ? inboundRec[0] : null, errorCode);
            
            
                Http calloutreq = new Http(); 
                HttpRequest postRequest = new HttpRequest();
                postRequest.setMethod('POST');
                postRequest.setEndpoint(endPointURL);
                postRequest.setHeader('content-type', 'application/json');               
                
                postRequest.setBody(jsonBody);
                postRequest.setTimeout(12000);
                HttpResponse response = calloutreq.send(postRequest); 
                if(response.getStatusCode() == 200) {
                   
                    if (Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Transaction_Track_Status__c.isUpdateable()) {
                        errorRec[0].Transaction_Track_Status__c = 'Sent Successfully';
                    }
                } else {
                   
                    errorRec[0].Transaction_Track_Status__c = 'Failed';
                }
                update errorRec;
            
        } catch (Exception e ) {
           
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
            
        }
        return null;
        
    }
}