/***************************************************************************************************************************************
Apex Class Name     : PRM_CIMOutboundCallout 
Version             : 1.0
Created Date        : 12/3/2021
Function            : This class is created to pass Payload of Integration Outbound Message object to CIM System.
Modification Log    :
* Developer                     Date                          Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Lata                        12/3/2021                  
*************************************************************************************************************************************/

public without sharing class PRM_CIMOutboundCallout {
    public static String xml;        
    public static String strResponse;
    
    @InvocableMethod(label='sendPayloadToCIM' description='To send payloads to CIM')
    public static void sendPayloadToCIM(List<Id> OBMIds){
        
        if(OBMIds.size()>0){   
            // Added by agate - TWC729-1292
            System.enqueueJob(new PRM_makeCallout(OBMIds));
        }          
    }
    
    //Updating status of Core_Integration_Outbound_Message__c by Successful/ Failed based on the callout status.
    public static void updateStatus(Core_Integration_Outbound_Message__c obm, String status){
        obm.Core_Status__c = status;
        update obm; 
    }
    
    //The sendPayload method is created to send payload to CIM system. 
    public static Map<id,Core_Integration_Outbound_Message__c> invokeCalloutToCIM(Core_Integration_Outbound_Message__c obm){ 
        strResponse+='\n*****Callout Start******\n';
        Map<id,Core_Integration_Outbound_Message__c> statusMap = new Map<id,Core_Integration_Outbound_Message__c>();           
        HttpRequest req = new HttpRequest();
        req.setEndPoint('callout:CIM_OUTBOUND');
        req.setMethod('POST');
        req.setHeader('Content-Type','application/xml');                         
        String payLoadforCIM=constructInputPayLoad(obm);
        req.setBody(payLoadforCIM);
        try{           
            HttpResponse resp = new Http().send(req);
            
            if(resp.getStatusCode()== 200){ 
                strResponse += 'Request\n'+payLoadforCIM+ 'Response\n'+resp.getBody();
                strResponse +='Transaction Status:\nSuccessful';
                obm.Core_Status__c = 'Successful';
                statusMap.put(obm.Id,obm);
            }
            else{
                strResponse += 'Request\n'+payLoadforCIM+ 'Response'+resp.getBody();
                strResponse +='Transaction Status:\nFailed';
                obm.Core_Status__c = 'Failed';                
                statusMap.put(obm.Id,obm);                              
            }         
            system.debug('strResponse--->'+strResponse);
            return statusMap;
        }
        catch (Exception e) {
            strResponse += 'Request\n'+payLoadforCIM+ 'Exception\n'+e.getMessage();
            strResponse +='Transaction Status:\nFailed';
            obm.Core_Status__c = 'Failed';
            statusMap.put(obm.Id,obm);
            
            return statusMap;
        }
    }
    
    //Construct Input Payload for Callout 
    public static string constructInputPayLoad(Core_Integration_Outbound_Message__c obm){
        String returnPayLoad = '<?xml version="1.0" encoding="UTF-8"?>';
        returnPayLoad+='<Notification xmlns="http://soap.sforce.com/2005/09/outbound">';
        returnPayLoad+='<sObject xmlns:sf="urn:sobject.enterprise.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="sf:Core_Integration_Outbound_Message__c">'; 
        returnPayLoad+='<sf:Id>'+obm.Id+'</sf:Id>';
        returnPayLoad+='<sf:Core_MessageType__c>'+obm.Core_MessageType__c+'</sf:Core_MessageType__c>';
        returnPayLoad+='<sf:Core_Payload__c>'+obm.Core_Payload__c+'</sf:Core_Payload__c>';
        returnPayLoad+='</sObject>';
        returnPayLoad+='</Notification>';
        return returnPayLoad;
    }
    
}