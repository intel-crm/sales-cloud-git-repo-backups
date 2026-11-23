/*********************************************
* Name : Core_IPS_BES_InboundMessage 
* Author : Farooq Ahmed
* Date Created : 21/08/2020
* Description : This excecuted by the process builder
* Version Updates : 
*   
************************************************/
public with sharing class Core_IPS_BES_InboundMessage_v1 {
    public class CustomException extends Exception {}
    public static Map<String, String> userDetailsMap; /* Tejaswini 22/02/2024 DCG Custom Logic */
    public static Map<String,String> sourceDetailsMap = new Map<String,String>();
    
    @InvocableMethod
 public static void setJson(List<Id> recordIdList){
        if (System.isFuture()) {
            System.debug('Running in a Future context.');
        } else {
            System.debug('Running in a synchronous context.');
        }
        Request reqInfo = Request.getCurrent();
        String currentRequestId = reqInfo.getRequestId();
        Quiddity currentType = reqInfo.getQuiddity();
         System.debug('currentType : '+ currentType);
        
     // Heapsize Change
     Map<String, String> userDetailsMap; /* Tejaswini 22/02/2024 DCG Custom Logic */
     Map<String,String> sourceDetailsMap = new Map<String,String>();
     // 1.2MB V1
     // 2.7MB V2
        List<attachment> attachmentList = new List<attachment>();
        Map<string,Object> backendJSONMap;
        Map<string,Object> caseJSONMap;
        Map<String,String> caseMap = new Map<String,String>();
        List<String> caseBackendList = new List<String>();
        List<String> commentBackendList = new List<String>();
        List<String> attachmentBackendList = new List<String>();
        // Heapsize Change
        List<String> caseCommentUpdateList = new List<String>();
        //List<String> commentUpdateList = new List<String>();
        Set<String> listIdSId = new Set<String>();
        try{
            if(attachment.SObjectType.getDescribe().isQueryable()){
                // Heapsize Change
                attachmentList = [SELECT parentId, Name, Id, Body, BodyLength from attachment WHERE parentId IN: recordIdList];
                System.debug('heap size attachment size : '+Limits.getHeapSize());// 1.6MB, V2_3.6MB
                for(attachment att: attachmentList){
                backendJSONMap = (Map<string,Object>) JSON.deserializeUntyped(att.body.toString());
                System.debug('Heapsize at 36: '+ Limits.getHeapSize()); // 3.2MB, V2_7.3MB
                 att = null;
                    //Backend Response for case & comment
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
                    System.debug('heap size messageType 58 : '+Limits.getHeapSize());
                    //Case Update & comment Insert - HSD to IPS
                    if(backendJSONMap.containsKey('system_details') && backendJSONMap.containsKey('issue_information')){
                        //Minhaj 
                         Map<string,Object> systemDetailMap = (Map<string,Object>) JSON.deserializeUntyped(JSON.serialize(backendJSONMap.get('system_details')));
                         String sourceSystem = (String)systemDetailMap.get('source_system'); //client_platf
                           sourceDetailsMap.put((String)systemDetailMap.get('target_id'),(String)systemDetailMap.get('source_id'));
                            Map<string,Object> issueInfoMap = (Map<string,Object>) JSON.deserializeUntyped(JSON.serialize(backendJSONMap.get('issue_information')));
                            issueInfoMap.put('comment_type', 'Public to Customers');
                            backendJSONMap.put('issue_information', issueInfoMap);
                          
                            /* Tejaswini 22/02/2024 DCG Custom Logic */
                            listIdSId.addAll(Core_IPS_BES_HSD_CustomLogic.getUsersFromIssueInfo(issueInfoMap));
                        System.debug('heap size  71 : '+Limits.getHeapSize()); 
                           // Heap Change
                            // String commentText = (String)issueInfoMap.get('comment_text');
                            if(att.BodyLength >= Integer.valueOf(System.Label.Core_IPS_BES_BodyLengthLimit) ){
                                throw new CustomException('Custom Exception, Record Insert Failed due to Heap Size too large, Maybe Comment');
                            } else if(att.BodyLength >= Integer.valueOf(System.Label.Core_IPS_BES_OneMBLimit) && ((String)issueInfoMap.get('comment_text')).countMatches('img src') == 1){
                                throw new CustomException('Custom Exception, Record Insert Failed due to attachment size more than 1 MB, Maybe Comment');
                            }
                           System.debug('heap size  78 : '+Limits.getHeapSize());  //3.2MB , V2_7.39MB
                            //commentText=null;
                            issueInfoMap = null;
                        System.debug('heap size  81 : '+Limits.getHeapSize()); //3.2MB , V2_7.39MB
                        sourceSystem = null;
                        //Minhaj end
                        //commentUpdateList.add(JSON.serialize(backendJSONMap));
                        caseCommentUpdateList.add(JSON.serialize(backendJSONMap));
                        System.debug('heap size  85 : '+Limits.getHeapSize()); //6.5MB , V2_14MB_11MB
                    }
                }
                attachmentList.clear();
                backendJSONMap.clear();
            }

            /* Tejaswini 22/02/2024 DCG Custom Logic */
            if(listIdSId.size() > 0) {
                System.debug('heap size  95 : '+Limits.getHeapSize()); //3.2MB , V2_7.39MB
                userDetailsMap = Core_IPS_BES_HSD_CustomLogic.getUserDetailsUsingIdSid(listIdSId);
                System.debug('heap size  97 : '+Limits.getHeapSize());//3.2MB , V2_7.39MB
                listIdSId.clear(); //added to fix heapsize exception -tejaswini 02/06/2024
            }

            System.debug('Heapsize at 93: '+ Limits.getHeapSize()); //3.2MB , V2_7.39MB
            if(caseBackendList.size()>0) {
            System.debug('heap size  103 : '+Limits.getHeapSize()); 
                Core_IPS_BES_updateBackendID.setJson(caseBackendList) ;  
            System.debug('heap size  105 : '+Limits.getHeapSize());
                caseBackendList.clear();
            System.debug('heap size  107 : '+Limits.getHeapSize());
            }
            System.debug('Heapsize at 109: '+ Limits.getHeapSize()); //3.2MB , V2_7.39MB
            if(commentBackendList.size()>0) { 
                Core_IPS_BES_UpdateCommentID.setCommentId(commentBackendList);
                commentBackendList.clear();
            } 
            System.debug('Heapsize at 1114: '+ Limits.getHeapSize()); //3.2MB , V2_7.39MB
            if(attachmentBackendList.size()>0) {
                Core_IPS_BES_UpdateAttachment.setAttachmentStatus(attachmentBackendList);
                attachmentBackendList.clear();
            }
            System.debug('Heapsize at 119: '+ Limits.getHeapSize()); //3.2MB , V2_7.39MB
            if(caseCommentUpdateList.size()>0) {
                /* Tejaswini Harpanhalli  - Line 107 updated to match changed signature of the method - DCG Custom Logic */
                System.debug('Heapsize at 125: '+ Limits.getHeapSize()); //3.2MB , V2_7.39MB
                Core_IPS_BES_UpdateComment.Core_IPS_BES_Update(caseCommentUpdateList, userDetailsMap,sourceDetailsMap); 
                 System.debug('Heapsize at 127: '+ Limits.getHeapSize()); // 3.5 MB 
                //Minhaj - clearing memoery
                //caseCommentUpdateList = null;
                sourceDetailsMap.clear();//added to fix heapsize exception -tejaswini 02/06/2024
                 System.debug('Heapsize at 131: '+ Limits.getHeapSize()); // 1.6 MB
            }
            System.debug('Heapsize at 133: '+ Limits.getHeapSize());
            if(caseCommentUpdateList.size()>0) {
                /* Tejaswini Harpanhalli  - Line 112 updated to match changed signature of the method - DCG Custom Logic */
                 System.debug('Heapsize at 136: '+ Limits.getHeapSize()); // 1.6MB
                Core_IPS_BES_UpdateCase.updateCase(caseCommentUpdateList, userDetailsMap);
                System.debug('Heapsize at 138: '+ Limits.getHeapSize()); // 1.6MB
                //Minhaj - clearing memoery
                caseCommentUpdateList.clear();
                System.debug('Heapsize at 142: '+ Limits.getHeapSize()); // 0.26MB
            }
               
        } catch(Exception e) {
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, String.join(recordIdList,','));
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
    
     public static void methodExtension(List<String> caseCommentUpdateList, Map<String, String> userDetailsMap, Map<String,String> sourceDetailsMap){
        if(caseCommentUpdateList.size()>0) {
            System.debug('Heapsize at methodExtension: '+ Limits.getHeapSize());
            Core_IPS_BES_UpdateComment.Core_IPS_BES_Update(caseCommentUpdateList, userDetailsMap,sourceDetailsMap); 
            System.debug('Heapsize at methodExtension: '+ Limits.getHeapSize());
        }
          if(caseCommentUpdateList.size()>0) {
                System.debug('Heapsize at methodExtension: '+ Limits.getHeapSize());
                Core_IPS_BES_UpdateCase.updateCase(caseCommentUpdateList, userDetailsMap);
                System.debug('Heapsize at methodExtension: '+ Limits.getHeapSize());
            }
    }
}