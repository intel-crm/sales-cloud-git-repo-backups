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
        System.debug('heap size batchclass 1 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
        inboundRecList = inboundList;
        System.debug('heap size batchclass 4 : '+Limits.getHeapSize());
        userDetailsMap = userDetailsRecMap;
        sourceDetailsMap = sourceDetailsRecMap;
        System.debug('heap size batchclass 5 : '+Limits.getHeapSize());
        //system.debug('BatchPP inbounddata: + ' + inboundRecList);
        //system.debug('BatchPP inbounddatasize: + ' + inboundRecList.size());
    }

    global Database.QueryLocator start(Database.BatchableContext BC ) {
        System.debug('heap size batchclass 111 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
        String query = 'SELECT parentId, BodyLength, Body from attachment WHERE parentId IN: inboundRecList';
        System.debug('heap size batchclass 112 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Attachment> scope) {
        //system.debug('BatchPP scope: + ' + scope);
        List<String> inboundfailedRec = new List<String>();
        List<String> caseCommentInsertList = new List<String>();
        System.debug('heap size batchclass 11 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
        try{
            for(attachment att: scope){
                Map<string,Object> backendJSONMap = new Map<String, Object>();
                System.debug('heap size batchclass 24 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
                backendJSONMap = (Map<string,Object>) JSON.deserializeUntyped(att.body.toString());
                System.debug('heap size batchclass 25 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
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
                    System.debug('heap size batchclass 26 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
                    backendJSONMap.put('issue_information', issueInfoMap);      
                    System.debug('heap size batchclass 27 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
                    caseCommentInsertList.add(JSON.serialize(backendJSONMap));
                    //system.debug('BatchPP caseCommentInsertList: + ' + caseCommentInsertList);
                    //system.debug('BatchPP userDetailsMap: + ' + userDetailsMap);
                    //System.debug('heap size batchclass 2 : '+Limits.getHeapSize());
                    System.debug('heap size batchclass 12 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
                    backendJSONMap.clear();
                    System.debug('heap size batchclass 13 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
                    issueInfoMap.clear();
                    System.debug('heap size batchclass 16 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
                    inboundMappings.clear();
                    System.debug('heap size batchclass 21 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
                    if(att.BodyLength >= Integer.valueOf(System.Label.Core_IPS_BES_BodyLengthLimit)){
                        //Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null,null);
                        inboundfailedRec.add((String) att.ParentId);
                    }

                    //Core_IPS_BES_UpdateComment.Core_IPS_BES_Update(caseCommentInsertList, userDetailsMap,sourceDetailsMap);
                    //System.debug('heap size batchclass 3 : '+Limits.getHeapSize());
                    //System.debug('heap size batchclass 14 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
                    //caseCommentInsertList.clear();
                    //System.debug('heap size batchclass 17 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
                }
            }
            System.debug('heap size batchclass 14 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
            scope.clear();
            System.debug('heap size batchclass 17 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
            if(!inboundfailedRec.isEmpty()){
                CustomException customEx = new CustomException(System.Label.Core_IPS_BES_CommentImage_Excpetion);
                Core_IPS_BES_LogEntry_Utility.insertLog(customEx, null, null, null,String.join(inboundfailedRec,','));
            }
            System.debug('heap size batchclass 100 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
            if(!caseCommentInsertList.isEmpty()){
                Core_IPS_BES_UpdateComment.Core_IPS_BES_Update(caseCommentInsertList, userDetailsMap,sourceDetailsMap);
                caseCommentInsertList.clear();
            }
            System.debug('heap size batchclass 99 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
        }
        catch(Exception e){
            //System.debug('heap size batchclass 19 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null,null);
        }
    }

    global void finish(Database.BatchableContext BC) {
        system.debug('batch finishhhh');
        System.debug('heap size batchclass 20 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
       
    }

    
}