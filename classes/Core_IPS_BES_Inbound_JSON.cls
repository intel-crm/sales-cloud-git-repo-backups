/*********************************************
* Name : Core_IPS_HSD_CreateJSON 
* Author : Farooq Ahmed
* Date Created : 20/08/2020
* Description : This is the Rest API class for ipass inbound message
* Version Updates : 
*   
************************************************/
@RestResource(urlMapping='/IPS_BES_InboundMessageJSON/*')
global with sharing class Core_IPS_BES_Inbound_JSON {
    @HttpPost
    global static void getBackendId(){
        String OutboundId;
        String outboundNum;
        List<Core_IPS_BES_Outbound_Message__c> outboundList;
        Core_IPS_BES_Inbound_Message__c inVar = new Core_IPS_BES_Inbound_Message__c();
        try{
            List<Attachment> attList = new List<Attachment>();
            List<Core_IPS_Backend_Inbound_Integration__e> backendIntegrationEventsList = new List<Core_IPS_Backend_Inbound_Integration__e>();
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            
            String response = body.toString();
            if(response != ''){
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
                Map<String, Object> responseStringMap = new Map<String,Object>();
                
                if(responseMap.containsKey('system_details')){
                    responseStringMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(responseMap.get('system_details')));    
                }  
                if(responseMap.containsKey('response')){
                    responseStringMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(responseMap.get('response')));
                }
                outboundNum = (responseStringMap!=null) ? (String) responseStringMap.get('message_id') : '';
                
                if(outboundNum !=''){
                    /*US1038991 - 07/08/2021 - Vishal - FLS Check for security vulnerability --*/
                    if (Schema.sObjectType.Core_IPS_BES_Inbound_Message__c.fields.Core_IPS_Inbound_Message_ID__c.isCreateable()) {
                        inVar.Core_IPS_Inbound_Message_ID__c = outboundNum;
                    }
                    
                    if(Core_IPS_BES_Outbound_Message__c.SObjectType.getDescribe().isQueryable ()){
                        outboundList = [SELECT ID FROM Core_IPS_BES_Outbound_Message__c WHERE Name=:outboundNum];
                        if(outboundList.size() > 0){
                            /*US1038991 - 07/09/2021 - Vishal - FLS Check for security vulnerability --*/
                            if (Schema.sObjectType.Core_IPS_BES_Outbound_Message__c.fields.Status__c.isUpdateable()) {
                                outboundList[0].Status__c = 'IPass Success';
                            }
                            if (Schema.sObjectType.Core_IPS_BES_Inbound_Message__c.fields.Core_BES_Outbound__c.isCreateable()) {
                                inVar.Core_BES_Outbound__c =  outboundList[0].Id;
                            }
                            
                            OutboundId = outboundList[0].Id;
                            update outboundList;
                        }
                        
                    }
                }
                insert inVar; 
                
                Attachment att=new Attachment();
                /*US1038991 - 07/08/2021 - Vishal - FLS Check for security vulnerability --*/
                if (Schema.sObjectType.Attachment.fields.Body.isCreateable()) {
                    att.Body=Blob.valueOf(response);
                }
                if (Schema.sObjectType.Attachment.fields.Name.isCreateable()) {
                    att.Name='Note_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
                }
                if (Schema.sObjectType.Attachment.fields.parentId.isCreateable()) {
                    att.parentId=inVar.id;
                }
                attList.add(att);
                insert attList; 
                
                Core_IPS_Backend_Inbound_Integration__e backEndInboundIntegrationEvent = new Core_IPS_Backend_Inbound_Integration__e();
                backEndInboundIntegrationEvent.Core_IPS_BES_InboundId__c = inVar.id;
                backendIntegrationEventsList.add(backEndInboundIntegrationEvent);
                List<Database.SaveResult> results = EventBus.publish(backendIntegrationEventsList);
                for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                        system.debug('-->results'+results);
                    } else {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('Error returned: ' +
                                         err.getStatusCode() +
                                         ' - ' +
                                         err.getMessage());
                        }
                    }  
                }
            }
            
        }catch(exception e){
            RestContext.response.statusCode = 500;
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null,  null);
        }
    }
}