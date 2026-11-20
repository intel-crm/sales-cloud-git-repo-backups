/*********************************************
* Name : Core_IPS_BES_OutboundMessage 
* Author : Sriranjini J N
* Date Created : 19/4/2020
* Description : This is being used in process builder
* Version Updates : 
*   
************************************************/
public with sharing class Core_IPS_BES_OutboundMessage {
    /*********************************************
* Method Name : createPlatformEventHSD 
* Author : Sriranjini J N
* Date Created : 
* Description : This method is used to create Platform event Once a Case is created. 
* Version Updates : 
************************************************/
    public static void createPlatformEventHSD(Set<Id> caseList){
       // system.debug('HD-Entered into createPlatformEventHSD: '+ caseList);
        // List<Profile> profile = [SELECT Id,Name FROM Profile WHERE Id=:UserInfo.getProfileId()];
        List<Core_IPS_Backend_Outbound_Integration__e> backendIntegrationEventsList = new List<Core_IPS_Backend_Outbound_Integration__e>();
        list<Core_IPS_BES_Outbound_Message__c>outboundCaseList  = new list<Core_IPS_BES_Outbound_Message__c>();

        if(!caseList.isEmpty() && caseList != null){
            for(Id caseId : caseList){
                Core_IPS_BES_Outbound_Message__c outVar = new Core_IPS_BES_Outbound_Message__c();
                /*US1021249 - 05/27/2021 - yamini - FLS Check for security vulnerability --*/
                //if (Schema.sObjectType.Core_IPS_BES_Outbound_Message__c.fields.Core_IPS_Case_ID__c.isCreateable()) {
                
                outVar.Core_IPS_Case_ID__c = caseId;
                if (Schema.sObjectType.Core_IPS_BES_Outbound_Message__c.fields.Core_IPS_BES_Message_Type__c.isCreateable()) {
                    outVar.Core_IPS_BES_Message_Type__c = 'Case';
                }
                //}
                outboundCaseList.add(outVar);
            }
        }
        try{
            //if(Core_IPS_BES_Outbound_Message__c.SObjectType.getDescribe().isCreateable()){
                if(outboundCaseList.size() > 0){
                    //System.debug('outboundCaseList'+outboundCaseList);
                    insert outboundCaseList;
                    List<Database.SaveResult> results;
                    for(Core_IPS_BES_Outbound_Message__c outboundCase :outboundCaseList){
                        Core_IPS_Backend_Outbound_Integration__e backEndOutboundIntegrationEvent = new Core_IPS_Backend_Outbound_Integration__e();
                        backEndOutboundIntegrationEvent.Outbound_Message_Id__c = outboundCase.id;
                        backendIntegrationEventsList.add(backEndOutboundIntegrationEvent);
                    }
                    if(Limits.getLimitPublishImmediateDML() < 249000){
                        results = EventBus.publish(backendIntegrationEventsList);
                    }else{
                        throw new StringException('Event Publishing limit hit');
                    }
                    
                    for (Database.SaveResult sr : results) {
                        if (sr.isSuccess()) {
                        } else {
                            for(Database.Error err : sr.getErrors()) {
                                /*System.debug('Error returned: ' +
                                             err.getStatusCode() +
                                             ' - ' +
                                             err.getMessage());*/
                                throw new StringException('Event Publishing exception '+ err.getMessage());
                            }
                        }  
                    }
                }
            }
        //}
        catch(exception e){
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null , String.join(new List<Id>(caseList),','));
           
        }
    }
     /*********************************************
* Method Name : createPlatformEventHSD 
* Author : Farooq Ahmed
* Date Created : 
* Description : This method is used to create Platform event Once a Case is created. 
* Version Updates : 
************************************************/
    public static void createPlatformEventHSD(Map<String,String> caseOldBackendMap){
       // system.debug('HD-Entered into createPlatformEventHSD: '+ caseOldBackendMap);
        // List<Profile> profile = [SELECT Id,Name FROM Profile WHERE Id=:UserInfo.getProfileId()];
        List<Core_IPS_Backend_Outbound_Integration__e> backendIntegrationEventsList = new List<Core_IPS_Backend_Outbound_Integration__e>();
        list<Core_IPS_BES_Outbound_Message__c>outboundCaseList  = new list<Core_IPS_BES_Outbound_Message__c>();
        try{
        if(!caseOldBackendMap.isEmpty() && caseOldBackendMap != null){
            List<String> backendIdList = new List<String>();
            Map<String, String> backendStringMap = new Map<String,String>();
            for(String backendDetails : caseOldBackendMap.values()){
                if(backendDetails.split(';').size()>1){
                     backendIdList.add(backendDetails.split(';')[1]);
                } 
            }
            if(Core_IPS_Backend_System2__c.SObjectType.getDescribe().isAccessible()){
            for(Core_IPS_Backend_System2__c backendSystem: [select id,Core_IPS_Target_System__c from Core_IPS_Backend_System2__c where ID IN: backendIdList]){
                backendStringMap.put(backendSystem.Id, backendSystem.Core_IPS_Target_System__c);
            }
            }
            for(Id caseId : caseOldBackendMap.keySet()){
                Core_IPS_BES_Outbound_Message__c outVar = new Core_IPS_BES_Outbound_Message__c();
                /*US1021249 - 05/27/2021 - yamini - FLS Check for security vulnerability --*/
                //if (Schema.sObjectType.Core_IPS_BES_Outbound_Message__c.fields.Core_IPS_Case_ID__c.isCreateable()) {
                if (Schema.sObjectType.Core_IPS_BES_Outbound_Message__c.fields.Core_IPS_BES_Message_Type__c.isCreateable()) {
                    outVar.Core_IPS_BES_Message_Type__c = 'Case';
                }
                outVar.Core_IPS_Case_ID__c = caseId;
                if (Schema.sObjectType.Core_IPS_BES_Outbound_Message__c.fields.Core_IPS_BES_Depromote_Id__c.isCreateable()) {
                    outVar.Core_IPS_BES_Depromote_Id__c = (caseOldBackendMap.get(caseId).split(';')[0]) != 'null' ? caseOldBackendMap.get(caseId).split(';')[0] : '';
                }
                if (Schema.sObjectType.Core_IPS_BES_Outbound_Message__c.fields.Core_IPS_Old_Backend_String__c.isCreateable()) {
                    outVar.Core_IPS_Old_Backend_String__c = backendStringMap.get(caseOldBackendMap.get(caseId).split(';')[1]);
                }
                //}
                outboundCaseList.add(outVar);
            }
        }
        
            //if(Core_IPS_BES_Outbound_Message__c.SObjectType.getDescribe().isCreateable()){
                if(outboundCaseList.size() > 0){
                    //System.debug('outboundCaseList'+outboundCaseList);
                    insert outboundCaseList;
                    List<Database.SaveResult> results;
                    for(Core_IPS_BES_Outbound_Message__c outboundCase :outboundCaseList){
                        Core_IPS_Backend_Outbound_Integration__e backEndOutboundIntegrationEvent = new Core_IPS_Backend_Outbound_Integration__e();
                        backEndOutboundIntegrationEvent.Outbound_Message_Id__c = outboundCase.id;
                        backendIntegrationEventsList.add(backEndOutboundIntegrationEvent);
                    }
                    if(Limits.getLimitPublishImmediateDML() < 249000){
                        results = EventBus.publish(backendIntegrationEventsList);
                    }else{
                        throw new StringException('Event Publishing limit hit');
                    }
                    
                    for (Database.SaveResult sr : results) {
                        if (sr.isSuccess()) {
                        } else {
                            for(Database.Error err : sr.getErrors()) {
                                /*System.debug('Error returned: ' +
                                             err.getStatusCode() +
                                             ' - ' +
                                             err.getMessage());*/
                                throw new StringException('Event Publishing exception '+ err.getMessage());
                            }
                        }  
                    }
                }
            }
        //}
        catch(exception e){
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null , String.join(new List<String>(caseOldBackendMap.keySet()),','));
           
        }
    }
    /*********************************************
* Method Name : createPlatformEventHSD 
* Author : Farooq Ahmed
* Date Created : 
* Description : This method is used to create Platform event Once a Comment is created. 
* Version Updates : 
************************************************/ 
    public static void createPlatformEventHSD(List<Core_IPS_Case_Comments__c> commentList, Boolean dePromote){
        try{
            //if(Core_IPS_BES_Outbound_Message__c.SObjectType.getDescribe().isCreateable()){
                List<Core_IPS_BES_Outbound_Message__c> outboundMsgList = new List<Core_IPS_BES_Outbound_Message__c>();
                List<Core_IPS_Backend_Outbound_Integration__e> backendIntegrationEventsList = new List<Core_IPS_Backend_Outbound_Integration__e>();
                Core_IPS_BES_Outbound_Message__c outboundMsg;
                List<Database.SaveResult> results;
                Core_IPS_Backend_Outbound_Integration__e outboundEvent;
                List<Id> caseIdList = new List<Id>();
                Map<String, Case> caseBackendMap = new Map<String, Case>();
                for(Core_IPS_Case_Comments__c comment: commentList){
                    caseIdList.add(comment.Core_IPS_Case__c);
                } 
                if (Schema.sObjectType.case.isAccessible()) {
                    for(Case cs: [select id,Core_IPS_BackendID__c,Core_IPS_New_Backend_System__r.Core_IPS_Target_System__c from case where Id IN:caseIdList]){
                        caseBackendMap.put(cs.Id, cs);
                    }
                }
            
                for(Core_IPS_Case_Comments__c comment: commentList){
                    outboundMsg = new Core_IPS_BES_Outbound_Message__c();
                    if (Schema.sObjectType.Core_IPS_BES_Outbound_Message__c.fields.Core_IPS_BES_Message_Type__c.isCreateable()) {
                        outboundMsg.Core_IPS_BES_Message_Type__c = 'Comment';
                    }
                    if (Schema.sObjectType.Core_IPS_BES_Outbound_Message__c.fields.Comment_Id__c.isCreateable()) {
                        outboundMsg.Comment_Id__c = comment.Id;
                    }
                    String caseId =comment.Core_IPS_Case__c; 
                    if(dePromote){
                       // outboundMsg.Core_IPS_BES_Depromote_Id__c = caseoldBackendMap.get(caseId).split(';')[0];
                       // outboundMsg.Core_IPS_Old_Backend_String__c = caseoldBackendMap.get(caseId).split(';')[1]; 
                        if (Schema.sObjectType.Core_IPS_BES_Outbound_Message__c.fields.Core_IPS_BES_Depromote_Id__c.isCreateable()) {
                            outboundMsg.Core_IPS_BES_Depromote_Id__c = caseBackendMap.get(caseId).Core_IPS_BackendID__c;
                        }
                        if (Schema.sObjectType.Core_IPS_BES_Outbound_Message__c.fields.Core_IPS_Old_Backend_String__c.isCreateable()) {
                            outboundMsg.Core_IPS_Old_Backend_String__c = caseBackendMap.get(caseId).Core_IPS_New_Backend_System__r.Core_IPS_Target_System__c; 
                        }
                    }
                    if (Schema.sObjectType.Core_IPS_BES_Outbound_Message__c.fields.Core_IPS_Case_ID__c.isCreateable()) {
                        outboundMsg.Core_IPS_Case_ID__c = comment.Core_IPS_Case__c;
                    }
                    outboundMsgList.add(outboundMsg);
                }
                insert outboundMsgList;
                if(outboundMsgList.size() > 0){
                    for(Core_IPS_BES_Outbound_Message__c outboundMessage : outboundMsgList){
                        outboundEvent = new Core_IPS_Backend_Outbound_Integration__e();
                        outboundEvent.Outbound_Message_Id__c = outboundMessage.Id;
                        backendIntegrationEventsList.add(outboundEvent);  
                    }
                }
                if(Limits.getLimitPublishImmediateDML() < 249000){
                    results = EventBus.publish(backendIntegrationEventsList);
                }else{
                    throw new StringException('Event Publishing limit hit');
                }
                for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                    } else {
                        for(Database.Error err : sr.getErrors()) {
                            /*System.debug('Error returned: ' +
                                         err.getStatusCode() +
                                         ' - ' +
                                         err.getMessage());*/
                            throw new StringException('Event Publishing exception '+ err.getMessage());
                        }
                    }  
                }
            //}
        }catch(Exception e){
             Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, null);
          
        }
    }
    /******************
     * Method Name: createPlatformEventHSD
     * Input Param: Core_IPS_Case_Attachments__c List.
     * Author: Chandra Shekar Pallikonda
     * Description : This method is used to create Platform event Once an Attachment's upload status is 'Complete'. 
     * ***************/
    public static void createPlatformEventHSD(List<Core_IPS_Case_Attachments__c> attachmentsList) {
        try{
            //if(Core_IPS_BES_Outbound_Message__c.SObjectType.getDescribe().isCreateable()) {
                List<Core_IPS_BES_Outbound_Message__c> outboundMsgList = new List<Core_IPS_BES_Outbound_Message__c>();
                List<Core_IPS_Backend_Outbound_Integration__e> backendIntegrationEventsList = new List<Core_IPS_Backend_Outbound_Integration__e>();
                Core_IPS_BES_Outbound_Message__c outboundMsg;
                Core_IPS_Backend_Outbound_Integration__e outboundEvent;
                List<Database.SaveResult> results;
                
                for(Core_IPS_Case_Attachments__c attachment: attachmentsList){
                    outboundMsg = new Core_IPS_BES_Outbound_Message__c();
                    if (Schema.sObjectType.Core_IPS_BES_Outbound_Message__c.fields.Core_IPS_BES_Message_Type__c.isCreateable()) {
                        outboundMsg.Core_IPS_BES_Message_Type__c = 'Attachment';
                    }
                    /* Start---US1038641 06/24/2021 - Sai Krishna - FLS Check for security vulnerability--*/
                    //if(Schema.sObjectType.Core_IPS_BES_Outbound_Message__c.fields.Core_IPS_Attachment_ID__c.isCreateable()){
                        outboundMsg.Core_IPS_Attachment_ID__c = attachment.Id; 
                    //}
                    
                    //if(Schema.sObjectType.Core_IPS_BES_Outbound_Message__c.fields.Core_IPS_Case_ID__c.isCreateable()){
                        outboundMsg.Core_IPS_Case_ID__c = attachment.Core_Case__c;
                    //}
                    /* End ---US1038641 06/24/2021 - Sai Krishna - FLS Check for security vulnerability--*/
                    
                    outboundMsgList.add(outboundMsg);
                }
                insert outboundMsgList;
                if(outboundMsgList.size() > 0){
                    for(Core_IPS_BES_Outbound_Message__c outboundMessage : outboundMsgList){
                        outboundEvent = new Core_IPS_Backend_Outbound_Integration__e();
                        outboundEvent.Outbound_Message_Id__c = outboundMessage.Id;
                        backendIntegrationEventsList.add(outboundEvent);  
                    }
                }
                if(Limits.getLimitPublishImmediateDML() < 249000){
                    results = EventBus.publish(backendIntegrationEventsList);
                }else{
                    throw new StringException('Event Publishing limit hit');
                }
                for (Database.SaveResult res : results) {
                    if (res.isSuccess()) {
                    } else {
                        for(Database.Error err : res.getErrors()) {
                            /*System.debug('Error returned: ' +
                                         err.getStatusCode() +
                                         ' - ' +
                                         err.getMessage());*/
                            throw new StringException('Event Publishing exception '+ err.getMessage());
                        }
                    }  
                }
            //}
        } catch(Exception e) {
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, null);
        }
    }
    


}