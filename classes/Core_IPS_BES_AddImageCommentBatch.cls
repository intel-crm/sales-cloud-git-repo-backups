/*********************************************
* Name : Core_IPS_BES_AddImageCommentBatch 
* Author : Pavani
* Date Created : 24/8/2024
* Description : Batch Class to insert the comments which contains Images in the HSD to IPS flow
* Version Updates : 
*   
************************************************/
global class Core_IPS_BES_AddImageCommentBatch implements Database.Batchable<sObject> {
    public class CustomException extends Exception {}
    public List<Id> inboundRecList = new List<Id>();
    Map<String, String> userDetailsMap = new Map<String, String>();
    Map<String,String> sourceDetailsMap = new Map<String,String>();
    public Core_IPS_BES_AddImageCommentBatch(List<Id> inboundList,Map<String, String> userDetailsRecMap,Map<String,String> sourceDetailsRecMap) {
        inboundRecList = inboundList;
        userDetailsMap = userDetailsRecMap;
        sourceDetailsMap = sourceDetailsRecMap;
    }

    global Database.QueryLocator start(Database.BatchableContext BC ) {
        String query = 'SELECT parentId, BodyLength, Body from attachment WHERE parentId IN: inboundRecList';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Attachment> scope) {
        List<String> inboundfailedRec = new List<String>();
        List<String> caseCommentInsertList = new List<String>();
        try{
            for(attachment att: scope){
                Map<string,Object> backendJSONMap = new Map<String, Object>();
                
                backendJSONMap = (Map<string,Object>) JSON.deserializeUntyped(att.body.toString());
                
                if(backendJSONMap.containsKey('system_details') && backendJSONMap.containsKey('issue_information')){
                    Map<string,Object> issueInfoMap = (Map<string,Object>) JSON.deserializeUntyped(JSON.serialize(backendJSONMap.get('issue_information')));
                    issueInfoMap.put('comment_type', 'Public to Customers');
                    List<String> inboundMappings= new List<String>();
                    inboundMappings = System.Label.Core_IPS_BES_HSDInboundFields.split(',');
                    for(String key: inboundMappings){
                        if(issueInfoMap.containsKey(key)){
                            issueInfoMap.remove(key);
                        }
                    }
                    backendJSONMap.put('issue_information', issueInfoMap);      
                    caseCommentInsertList.add(JSON.serialize(backendJSONMap));
                    backendJSONMap.clear();
                    issueInfoMap.clear();
                    inboundMappings.clear();
                    if(att.BodyLength >= Integer.valueOf(System.Label.Core_IPS_BES_BodyLengthLimit)){
                       
                        inboundfailedRec.add((String) att.ParentId);
                    }

                    
                }
            }
            
            scope.clear();
           
            if(!inboundfailedRec.isEmpty()){
                CustomException customEx = new CustomException(System.Label.Core_IPS_BES_CommentImage_Excpetion);
                Core_IPS_BES_LogEntry_Utility.insertLog(customEx, null, null, null,String.join(inboundfailedRec,','));
            }
            
            if(!caseCommentInsertList.isEmpty()){
                Core_IPS_BES_UpdateComment.Core_IPS_BES_Update(caseCommentInsertList, userDetailsMap,sourceDetailsMap);
                caseCommentInsertList.clear();
            }
            
        }
        catch(Exception e){
            
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null,null);
        }
    }

    global void finish(Database.BatchableContext BC) {
        
       
    }

    
}