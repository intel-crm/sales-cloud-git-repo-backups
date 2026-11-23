/*********************************************
* Name : Core_IPS_BES_InboundMessage 
* Author : Farooq Ahmed
* Date Created : 21/08/2020
* Description : This excecuted by the process builder
* Version Updates : 
*   
************************************************/
public with sharing class Core_IPS_BES_InboundMessage {
    public class CustomException extends Exception {}
    public static Map<String,String> revisionMap = new Map<String,String>(); //Added as part of Code Refactor TWC745-6459
    public static Map<String,String> sourceDetailsMap = new Map<String,String>(); //Added as part of Code Refactor TWC745-6459
    @InvocableMethod
    public static void setJson(List<Id> recordIdList){
        // Heapsize Change
        System.debug('recordIdList Data>>>>>'+recordIdList);
        Map<String, String> userDetailsMap; /* Tejaswini 22/02/2024 DCG Custom Logic */
       // Map<String,String> sourceDetailsMap = new Map<String,String>(); //Commented as part of Code Refactor TWC745-6459
        List<attachment> attachmentList = new List<attachment>();
        Map<string,Object> backendJSONMap;
        List<String> caseBackendList = new List<String>();
        List<String> commentBackendList = new List<String>();
        List<String> attachmentBackendList = new List<String>();
        // Heapsize Change
        List<String> caseCommentUpdateList = new List<String>();
        List<String> caseCommentUpdateCloneList = new List<String>();
        List<Id> commentImageInboundList = new List<Id>();
        Set<String> listIdSId = new Set<String>();
        try{
            if(attachment.SObjectType.getDescribe().isQueryable()){
                // Heapsize Change
                //attachmentList = [SELECT parentId, Name, Id, Body, BodyLength from attachment WHERE parentId IN: recordIdList];
                //System.debug('heap size attachment size : '+Limits.getHeapSize());// 1.6MB, V2_3.6MB
                for(attachment att: [SELECT parentId, Name, Id, Body, BodyLength from attachment WHERE parentId IN: recordIdList]){
                    backendJSONMap = (Map<string,Object>) JSON.deserializeUntyped(att.body.toString());
                    
                    //Backend Response for case & comment
                    if(backendJSONMap.containsKey('response')){
                        Map<string,Object> responseMap = (Map<string,Object>) JSON.deserializeUntyped(JSON.serialize(backendJSONMap.get('response'))); 
                        String messageType = (String)responseMap.get('message_type');
                        switch on messageType.toLowerCase(){
                            when 'case'{
                                caseBackendList.add(JSON.serialize(responseMap));   
                            }
                            when 'comment'{
                                commentBackendList.add(JSON.serialize(responseMap));
                            }
                            when 'attachment'{
                                attachmentBackendList.add(JSON.serialize(responseMap));
                            }
                        }
                    }
                    //Case Update & comment Insert - HSD to IPS
                    if(backendJSONMap.containsKey('system_details') && backendJSONMap.containsKey('issue_information')){
                        //Minhaj 
                         Map<string,Object> systemDetailMap = (Map<string,Object>) JSON.deserializeUntyped(JSON.serialize(backendJSONMap.get('system_details')));
                        //String sourceSystem = (String)systemDetailMap.get('source_system'); //client_platf
                        system.debug('COG Issue Validation---- inboundmessage strt before revmap--'+Core_IPS_BES_InboundMessage.revisionMap);
                system.debug('COG Issue Validation---- inboundmessage strt before srcMap--'+Core_IPS_BES_InboundMessage.sourceDetailsMap);
                        if(!sourceDetailsMap.containskey((String)systemDetailMap.get('target_id'))){
                            system.debug('COG Issue Validation----  inboundmessage Inside srcMap');
                            sourceDetailsMap.put((String)systemDetailMap.get('target_id'),(String)systemDetailMap.get('source_id')); }
                        systemDetailMap.clear();
                            Map<string,Object> issueInfoMap = (Map<string,Object>) JSON.deserializeUntyped(JSON.serialize(backendJSONMap.get('issue_information')));
                            issueInfoMap.put('comment_type', 'Public to Customers');
                        
                        if(issueInfoMap.get('comment_text')!=null && ((String)issueInfoMap.get('comment_text')).countMatches('img src') >= 1){
                            
                            commentImageInboundList.add(att.parentId);
                            issueInfoMap.put('comment_text',null); 
                        }
                            backendJSONMap.put('issue_information', issueInfoMap);
                            
                            /* Tejaswini 22/02/2024 DCG Custom Logic */
                            listIdSId.addAll(Core_IPS_BES_HSD_CustomLogic.getUsersFromIssueInfo(issueInfoMap));
                            //String commentText = (String)issueInfoMap.get('comment_text');
                        // Heap Change
                        /*if(att.BodyLength >= Integer.valueOf(System.Label.Core_IPS_BES_BodyLengthLimit) ){
                                throw new CustomException('Custom Exception, Record Insert Failed due to Heap Size too large, Maybe Comment');
                        } else if(att.BodyLength >= Integer.valueOf(System.Label.Core_IPS_BES_OneMBLimit) && ((String)issueInfoMap.get('comment_text')).countMatches('img src') == 1){
                                throw new CustomException('Custom Exception, Record Insert Failed due to attachment size more than 1 MB, Maybe Comment');
                        }*/
                        
                        //issueInfoMap.clear();
                        

                        caseCommentUpdateList.add(JSON.serialize(backendJSONMap));
                        
                    }
                }
                attachmentList.clear();
                backendJSONMap.clear();
            }

            /* Tejaswini 22/02/2024 DCG Custom Logic */
            if(listIdSId.size() > 0) {
                userDetailsMap = Core_IPS_BES_HSD_CustomLogic.getUserDetailsUsingIdSid(listIdSId);
				
                listIdSId.clear(); //added to fix heapsize exception -tejaswini 02/06/2024
            }
            if(caseBackendList.size()>0) {
                Core_IPS_BES_updateBackendID.setJson(caseBackendList) ;   
                caseBackendList.clear();
            }
            if(commentBackendList.size()>0) { 
                Core_IPS_BES_UpdateCommentID.setCommentId(commentBackendList);
                commentBackendList.clear();
            } 
            if(attachmentBackendList.size()>0) {
                Core_IPS_BES_UpdateAttachment.setAttachmentStatus(attachmentBackendList);
                attachmentBackendList.clear();
            }
            
           if(caseCommentUpdateList.size()>0) {
                // Tejaswini Harpanhalli  - Line 107 updated to match changed signature of the method - DCG Custom Logic
                
		caseCommentUpdateCloneList.addAll(caseCommentUpdateList);
                Core_IPS_BES_UpdateComment.Core_IPS_BES_Update(caseCommentUpdateList, userDetailsMap,sourceDetailsMap); 
                
		caseCommentUpdateList.addAll(caseCommentUpdateCloneList);
                caseCommentUpdateCloneList.clear();
                
		
		
		
		            }
            Boolean updateCalled = false; //added as art of code refactor
            if(caseCommentUpdateList.size()>0) {
                /* Tejaswini Harpanhalli  - Line 112 updated to match changed signature of the method - DCG Custom Logic */
                updateCalled = true; 
                Core_IPS_BES_UpdateCase.updateCase(caseCommentUpdateList, userDetailsMap);
                //Minhaj - clearing memoery
                caseCommentUpdateList.clear();
            }
            //Added as part of code refactor
            if (!updateCalled) {
                setjsoncasedml();
            }
            system.debug('COG Issue Validation---- inboundmessage before revmap--'+revisionMap);
                system.debug('COG Issue Validation---- inboundmessage before srcMap--'+sourceDetailsMap);
            if(revisionMap != null){
                //system.debug('Debugg24 -- '+revisionMap);
                system.debug('COG Issue Validation---- inboundmessage Inside revmap');
                Core_IPS_BES_InboundMessage.updateRevision(revisionMap,sourceDetailsMap); 
            }
            system.debug('COG Issue Validation---- inboundmessage after revmap--'+revisionMap);
            system.debug('COG Issue Validation---- inboundmessage after srcMap--'+sourceDetailsMap);
            revisionMap.clear();
            //sourceDetailsMap.clear();
            system.debug('COG Issue Validation---- inboundmessage after clear revmap--'+revisionMap);
            system.debug('COG Issue Validation---- inboundmessage after clear srcMap--'+sourceDetailsMap);
            
            if(commentImageInboundList.size()>0){
                System.debug('heap size  24 : '+ Limits.getHeapSize());
                Core_IPS_BES_AddImageCommentBatch addImageComment = new Core_IPS_BES_AddImageCommentBatch(commentImageInboundList,userDetailsMap,sourceDetailsMap);
                Database.executeBatch(addImageComment,1);
                System.debug('heap size  25 : '+ Limits.getHeapSize());
            }
               
        } catch(Exception e) {
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, String.join(recordIdList,','));
        }
    }
    //FLS Added as Part of code refactor
    //Added as art of code refactor
    public static void setjsoncasedml(){
        if(Core_IPS_BES_UpdateBackendID.caseList!=null && !Core_IPS_BES_UpdateBackendID.caseList.isEmpty() && Schema.sObjectType.Case.isUpdateable()){
        		update Core_IPS_BES_UpdateBackendID.caseList;
        }
    }
    //Chandrashekar -- This method is used to update revision on case on any response recieved from IPass
   public static void updateRevision(Map<String,String> revMap, Map<String,String> sourceDetMap){
        List<Case> caseList;
        List<Case> updatedCaseList = new List<Case>();
        Integer latestRevValue,RevValue;
        
        if(Case.SObjectType.getDescribe().isQueryable()) {
            caseList = [SELECT Id,CaseNumber,Core_IPS_New_Backend_System__c,Core_IPS_Backend_Rev__c,Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c,Core_IPS_BackendID__c, Core_IPS_BES_Promote_Status__c FROM Case WHERE CaseNumber =: revMap.keySet()];
        }
        for(Case cs: caseList){
            latestRevValue = revMap.get(cs.CaseNumber)!='' && revMap.get(cs.CaseNumber) !=null ? Integer.ValueOf(revMap.get(cs.CaseNumber)):0;
            RevValue = cs.Core_IPS_Backend_Rev__c!='' && cs.Core_IPS_Backend_Rev__c!=null ? Integer.ValueOf(cs.Core_IPS_Backend_Rev__c):0;
            
            if (Schema.sObjectType.Case.fields.Core_IPS_Backend_Rev__c.isUpdateable() && cs.Core_IPS_New_Backend_System__c !=null && (latestRevValue > RevValue)) {
                cs.Core_IPS_Backend_Rev__c = revMap.get(cs.CaseNumber);
                //Ajith added this logic to restrict the Case Update, when Backend system is deactivated
                 if(cs.Core_IPS_New_Backend_System__c != null && cs.Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c ==false && cs.Core_IPS_BES_Promote_Status__c =='Done' && cs.Core_IPS_BackendID__c!= null && sourceDetMap.get(cs.CaseNumber)== cs.Core_IPS_BackendID__c){
                updatedCaseList.add(cs);
                 }
            }
        }
        
    if(Case.SObjectType.getDescribe().isUpdateable() && updatedCaseList.size()>0){
            //update caseList; 
            update updatedCaseList; 
        }
    }
}