public without sharing class Core_AGSApigeeOutboundCallout {
    public class CustomException extends Exception {}
    public static Map<String,Id> sObjectNameToRecordIdMap = new Map<String,Id>();
    @InvocableMethod(label='sendPayloadToApigee' description='To send payloads to Apigee')
    public static void sendPayloadToApigee(List<Id> OBMIds){
        for(Id obmId : OBMIds){
            makeCallout(obmId);
        }      
    }
   
    @Future(callout=True)
    public static void makeCallout( Id OBMId){       
        List<Core_Integration_Outbound_Message__c> obms = [SELECT id,Core_Payload__c,Core_Retry_Number__c,Core_Status__c,Core_MessageType__c 
                                                     FROM Core_Integration_Outbound_Message__c WHERE Id=:OBMId];
        if(obms.size() > 0){            
            sendPayload(obms[0], 0);            
        }
    }
    public static void updateStatus(Core_Integration_Outbound_Message__c obm, String status){
        obm.Core_Status__c = status;
        obm.Core_Retry_Number__c = (obm.Core_Retry_Number__c==null) ? 1 : obm.Core_Retry_Number__c+1;
        update obm; 
        if(obm.Core_Status__c == 'Failed' && obm.Core_Retry_Number__c > 1) {
          Core_Log_Entry.logEntryWithException('SFDC', 'Entitlement', 'AGS_Apigee_Outbound_Integration', 'Error',
                                                 'Error sending AGS Apigee outbound message', '', obm.Id, 'Core_Integration_Outbound_Message__c', '', null);
        }
    }
    public static void sendPayload(Core_Integration_Outbound_Message__c obm, Integer retryCounter){        
        system.debug('Retry Counter ==>'+retryCounter);
        try{
            if(retryCounter==3){
                updateStatus(obm, 'Failed');
                return; 
            }            
        }catch(Exception exp){
            Core_Log_Entry.logEntryWithException('SFDC', 'Entitlement', 'AGS_Apigee_Outbound_Integration', 'Error',
                                                 'Error sending AGS Apigee outbound message', '', obm.Id, 'Core_Integration_Outbound_Message__c', '', exp);
            return;
        }
        
        try{
            HttpRequest req = new HttpRequest();
            req.setEndPoint('callout:APIGEE_AGS_OUTBOUND');
            req.setMethod('POST');
            req.setHeader('Content-Type','application/xml');  
            req.setTimeout(120000);
            String xml='<?xml version="1.0" encoding="UTF-8"?>';
                xml+='<Notification xmlns="http://soap.sforce.com/2005/09/outbound">';
                xml+='<sObject xmlns:sf="urn:sobject.enterprise.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="sf:Core_Integration_Outbound_Message__c">'; 
                xml+='<sf:Id>'+obm.Id+'</sf:Id>';
                xml+='<sf:Core_MessageType__c>'+obm.Core_MessageType__c+'</sf:Core_MessageType__c>';
                xml+='<sf:Core_Payload__c>'+obm.Core_Payload__c+'</sf:Core_Payload__c>';
                xml+='</sObject>';
                xml+='</Notification>';
            req.setBody(xml);
            HttpResponse resp = new Http().send(req);
            if(resp.getStatusCode() == 200){
                System.debug('STATUS_CODE:' + resp.getStatusCode());
                system.debug('Response==>'+resp.getBody());                
                updateStatus(obm, 'Successful');                    
            }else{
                System.debug('STATUS_CODE:' + resp.getStatusCode());
                System.debug('respBody-->'+resp.getbody());
                retryCounter++;                
                sendPayload(obm,retryCounter); 
            }            
        }catch(Exception exp){
            retryCounter++;            
            sendPayload(obm,retryCounter);           
            system.debug('Error==>'+exp.getMessage()+';;;'+exp.getStackTraceString());
        }    
    }   
}