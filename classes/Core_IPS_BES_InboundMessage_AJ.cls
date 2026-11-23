/*********************************************
* Name : Core_IPS_BES_InboundMessage 
* Author : Farooq Ahmed
* Date Created : 21/08/2020
* Description : This excecuted by the process builder
* Version Updates : 
*   
************************************************/
public with sharing class Core_IPS_BES_InboundMessage_AJ {
    public class CustomException extends Exception {}
    @InvocableMethod
    public static void setJson(List<Id> recordIdList){
        // Heapsize Change
        System.debug('heap size  1 : '+Limits.getHeapSize());
        Map<String, String> userDetailsMap; /* Tejaswini 22/02/2024 DCG Custom Logic */
        Map<String,String> sourceDetailsMap = new Map<String,String>();
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
        System.debug('heap size  2 : '+Limits.getHeapSize());
        try{
            if(attachment.SObjectType.getDescribe().isQueryable()){
                // Heapsize Change
                //attachmentList = [SELECT parentId, Name, Id, Body, BodyLength from attachment WHERE parentId IN: recordIdList];
                //System.debug('heap size attachment size : '+Limits.getHeapSize());// 1.6MB, V2_3.6MB
                for(attachment att: [SELECT parentId, Name, Id, Body, BodyLength from attachment WHERE parentId IN: recordIdList]){
                    backendJSONMap = (Map<string,Object>) JSON.deserializeUntyped(att.body.toString());
                    //System.debug('Heapsize at 36: '+ Limits.getHeapSize()); // 3.2MB, V2_7.3MB
                    //Backend Response for case & comment
                    System.debug('heap size  3 : '+Limits.getHeapSize());
                    if(backendJSONMap.containsKey('response')){
                        Map<string,Object> responseMap = (Map<string,Object>) JSON.deserializeUntyped(JSON.serialize(backendJSONMap.get('response'))); 
                        String messageType = (String)responseMap.get('message_type');
                        System.debug('heap size messageType 42 : '+Limits.getHeapSize());
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
                    System.debug('heap size  4 : '+Limits.getHeapSize());
                    //Case Update & comment Insert - HSD to IPS
                    if(backendJSONMap.containsKey('system_details') && backendJSONMap.containsKey('issue_information')){
                        //Minhaj 
                        Map<string,Object> systemDetailMap = (Map<string,Object>) JSON.deserializeUntyped(JSON.serialize(backendJSONMap.get('system_details')));
                        //String sourceSystem = (String)systemDetailMap.get('source_system'); //client_platf
                        sourceDetailsMap.put((String)systemDetailMap.get('target_id'),(String)systemDetailMap.get('source_id'));
                        systemDetailMap.clear();
                        Map<string,Object> issueInfoMap = (Map<string,Object>) JSON.deserializeUntyped(JSON.serialize(backendJSONMap.get('issue_information')));
                        issueInfoMap.put('comment_type', 'Public to Customers');
                        //System.debug('PB Debug 3 : '+issueInfoMap.get('comment_text'));
                        if(issueInfoMap.get('comment_text')!=null && ((String)issueInfoMap.get('comment_text')).countMatches('img src') >= 1){
                            System.debug('PB Debug 1 : comment image');
                            commentImageInboundList.add(att.parentId);
                            issueInfoMap.put('comment_text',null); 
                        }
                        backendJSONMap.put('issue_information', issueInfoMap);
                        System.debug('heap size  5 : '+Limits.getHeapSize());
                        /* Tejaswini 22/02/2024 DCG Custom Logic */
                        listIdSId.addAll(Core_IPS_BES_HSD_CustomLogic.getUsersFromIssueInfo(issueInfoMap));
                        //System.debug('heap size  71 : '+Limits.getHeapSize()); 
                        // Heap Change
                        /*if(att.BodyLength >= Integer.valueOf(System.Label.Core_IPS_BES_BodyLengthLimit) ){
throw new CustomException('Custom Exception, Record Insert Failed due to Heap Size too large, Maybe Comment');
} else if(att.BodyLength >= Integer.valueOf(System.Label.Core_IPS_BES_OneMBLimit) && ((String)issueInfoMap.get('comment_text')).countMatches('img src') == 1){
throw new CustomException('Custom Exception, Record Insert Failed due to attachment size more than 1 MB, Maybe Comment');
}*/
                        //issueInfoMap.clear();
                        caseCommentUpdateList.add(JSON.serialize(backendJSONMap));
                        System.debug('heap size  6 : '+Limits.getHeapSize()); //6.5MB , V2_14MB_11MB
                        System.debug('PB Debug 2 : '+caseCommentUpdateList);
                        //System.debug('PB Debug 1 : '+caseCommentUpdateList);
                    }
                }
                attachmentList.clear();
                backendJSONMap.clear();
            }
            
            /* Tejaswini 22/02/2024 DCG Custom Logic */
            if(listIdSId.size() > 0) {
                System.debug('heap size  7 : '+Limits.getHeapSize()); //3.2MB , V2_7.39MB
                userDetailsMap = Core_IPS_BES_HSD_CustomLogic.getUserDetailsUsingIdSid(listIdSId);
                System.debug('heap size  8 : '+Limits.getHeapSize());//3.2MB , V2_7.39MB
                listIdSId.clear(); //added to fix heapsize exception -tejaswini 02/06/2024
            }
            
            System.debug('heap size  9 : '+ Limits.getHeapSize()); //3.2MB , V2_7.39MB
            if(caseBackendList.size()>0) {
                System.debug('heap size  10 : '+Limits.getHeapSize()); 
                Core_IPS_BES_updateBackendID.setJson(caseBackendList);  
                System.debug('heap size  11 : '+Limits.getHeapSize());
                caseBackendList.clear();
                System.debug('heap size  12 : '+Limits.getHeapSize());
            }
            //AJ
            System.debug('heap size  13 : '+ Limits.getHeapSize()); //3.2MB , V2_7.39MB
            if(commentBackendList.size()>0) { 
                Core_IPS_BES_UpdateCommentID.setCommentId(commentBackendList);
                commentBackendList.clear();
            } 
            System.debug('heap size  14 : '+ Limits.getHeapSize()); //3.2MB , V2_7.39MB
            if(attachmentBackendList.size()>0) {
                Core_IPS_BES_UpdateAttachment.setAttachmentStatus(attachmentBackendList);
                attachmentBackendList.clear();
            }
            System.debug('heap size  15 : '+ Limits.getHeapSize()); //3.2MB , V2_7.39MB
            if(caseCommentUpdateList.size()>0) {
                // Tejaswini Harpanhalli  - Line 107 updated to match changed signature of the method - DCG Custom Logic
                System.debug('heap size  16 : '+ Limits.getHeapSize()); //3.2MB , V2_7.39MB
                caseCommentUpdateCloneList.addAll(caseCommentUpdateList);
                Core_IPS_BES_UpdateComment.Core_IPS_BES_Update(caseCommentUpdateList, userDetailsMap,sourceDetailsMap); 
                System.debug('heap size  17 : '+ Limits.getHeapSize()); // 3.5 MB 
                caseCommentUpdateList.addAll(caseCommentUpdateCloneList);
                caseCommentUpdateCloneList.clear();
                //Minhaj - clearing memoery
                //caseCommentUpdateList = null;
                //sourceDetailsMap.clear();//added to fix heapsize exception -tejaswini 02/06/2024
                System.debug('heap size  18 : '+ Limits.getHeapSize()); // 1.6 MB
            }
            System.debug('heap size  19 : '+ Limits.getHeapSize());
            Boolean updateCalled = false;
            if(caseCommentUpdateList.size()>0) {
                /* Tejaswini Harpanhalli  - Line 112 updated to match changed signature of the method - DCG Custom Logic */
                System.debug('heap size  20 : '+ Limits.getHeapSize()); // 1.6MB
                updateCalled = true; 
                Core_IPS_BES_UpdateCase.updateCase(caseCommentUpdateList, userDetailsMap);
                System.debug('heap size  21 : '+ Limits.getHeapSize()); // 1.6MB
                //Minhaj - clearing memoery
                caseCommentUpdateList.clear();
                //userDetailsMap.clear();
                System.debug('heap size  22 : '+ Limits.getHeapSize()); // 0.26MB
            }
            //Added by AJ
            if (!updateCalled) {
                setjsoncasedml();
            }
            System.debug('heap size  23 : '+ Limits.getHeapSize());
            System.debug('PB Debug 4 : '+commentImageInboundList);
            if(commentImageInboundList.size()>0){
                System.debug('heap size  24 : '+ Limits.getHeapSize());
                Core_IPS_BES_AddImageCommentBatch addImageComment = new Core_IPS_BES_AddImageCommentBatch(commentImageInboundList,userDetailsMap,sourceDetailsMap);
                Database.executeBatch(addImageComment,1);
                System.debug('heap size  25 : '+ Limits.getHeapSize());
            }
            
        } catch(Exception e) {
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, String.join(recordIdList,','));
        }
        System.debug('heap size  total size : '+ Limits.getLimitHeapSize());
        System.debug('heap size  27 : '+ Limits.getHeapSize());
    }
    
    public static void setjsoncasedml(){
        List<Case> accessClassList = Core_IPS_BES_UpdateBackendID_AJ.caseList;
        if (Case.SObjectType.getDescribe().isUpdateable()){
            update accessClassList;
        }
        
    }
    //Chandrashekar -- This method is used to update revision on case on any response recieved from IPass
    public static void updateRevision(Map<String,String> revMap, Map<String,String> sourceDetMap){
        System.debug('Heapsize at updateRevision entry 152: '+ Limits.getHeapSize()); // 6.6
        List<Case> caseList;
        List<Case> updatedCaseList = new List<Case>();
        Integer latestRevValue,RevValue;
        
        if(Case.SObjectType.getDescribe().isQueryable()) {
            caseList = [SELECT Id,CaseNumber,Core_IPS_New_Backend_System__c,Core_IPS_Backend_Rev__c,Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c,Core_IPS_BackendID__c, Core_IPS_BES_Promote_Status__c FROM Case WHERE CaseNumber =: revMap.keySet()];
            System.debug('Heapsize at 159: '+ Limits.getHeapSize());
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
            System.debug('Heapsize at 172 Inner For loop: '+ Limits.getHeapSize());
        }
        System.debug('Heapsize at 174 Outer For loop: '+ Limits.getHeapSize());
        if(Case.SObjectType.getDescribe().isUpdateable() && updatedCaseList.size()>0){
            //update caseList; 
            update updatedCaseList; 
            // system.debug('updatedCaseList'+updatedCaseList[0].id);
        }
        
    }
}