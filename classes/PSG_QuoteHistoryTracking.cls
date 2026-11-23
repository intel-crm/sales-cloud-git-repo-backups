/****************************************************************************************************
Apex Class Name : PSG_QuoteHistoryTracking
Version         : 1.0 
Created Date    : 9/6/2023
Function        : This class is used for storing the history of status field of Quote
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Bishal Singh               9/6/2023                Created
*****************************************************************************************************/
@isTest
public class PSG_QuoteHistoryTracking {
    
    /************************************************************************************************************
    *Method Name : createHistory
    *Created Date: 9/6/2023
    *Author: Bishal Singh
    *Description : Creates PSG Field History Record on Quote Status Change.
    ************************************************************************************************************/
    /*public static void createHistory(Map<String,String> quoteIdToNewStatusMap,Map<String,String> quoteIdToOldStatusMap){
        try{
            Map<Id,SBQQ__Quote__c> quoteMap = new Map<Id,SBQQ__Quote__c>([SELECT Id,SBQQ__Status__c,CreatedDate,CreatedById from SBQQ__Quote__c where Id  IN :quoteIdToNewStatusMap.keyset()]);
            List<core_cpq_quote_history__c> quoteHistoryList = new List<core_cpq_quote_history__c>();
            Map<Id, core_cpq_quote_history__c> quoteHistoryMap = new Map<Id, core_cpq_quote_history__c>();
            Map<Id,sbaa__Approval__c> quoteIdToApprRecMap=new Map<Id,sbaa__Approval__c>();
            List<core_cpq_bm_level__c> bmRecord = [SELECT id, core_cpq_bm_level_nm__c, core_cpq_bm_name__c  
                                                   FROM core_cpq_bm_level__c 
                                                   WHERE core_cpq_bm_name__c =:UserInfo.getUserId()];
            for (core_cpq_quote_history__c quoteHis : [SELECT Id, core_cpq_quote__c,core_cpq_end_date__c, core_cpq_end_user__c, 
                                                       core_cpq_status__c,core_cpq_start_user__c
                                                       FROM core_cpq_quote_history__c
                                                       WHERE core_cpq_quote__c IN :quoteIdToNewStatusMap.keyset() ORDER BY CreatedDate DESC]) {
                                                           if(!quoteHistoryMap.containsKey(quoteHis.core_cpq_quote__c))
                                                               quoteHistoryMap.put(quoteHis.core_cpq_quote__c, quoteHis);
                                                       } 
            
            for(sbaa__Approval__c approvalRecord : [SELECT Id, sbaa__ApprovalChain__r.Name, sbaa__Status__c,Quote__c  
                                                    FROM sbaa__Approval__c WHERE Quote__c IN :quoteIdToNewStatusMap.keyset()
                                                    AND sbaa__Status__c = 'Approved' AND sbaa__ApprovedBy__c =: UserInfo.getUserId() ORDER By sbaa__ApprovalStep__c DESC]){
                                                        if(!quoteIdToApprRecMap.containsKey(approvalRecord.Quote__c))
                                                            quoteIdToApprRecMap.put(approvalRecord.Quote__c, approvalRecord);
                                                    }
            
            for(String quoteId : quoteIdToNewStatusMap.keySet()){
                SBQQ__Quote__c quoteRec=quoteMap.get(quoteId);            
                core_cpq_quote_history__c oldHistoryRecord = quoteHistoryMap.get(quoteId);
                core_cpq_quote_history__c newHistoryRecord = new core_cpq_quote_history__c();
                newHistoryRecord.core_cpq_quote__c=quoteId;
                newHistoryRecord.core_cpq_prev_status__c = quoteIdToOldStatusMap.get(quoteId);
                newHistoryRecord.core_cpq_status__c =quoteIdToNewStatusMap.get(quoteId);
                newHistoryRecord.core_cpq_end_user__c = UserInfo.getUserId();
                newHistoryRecord.core_cpq_end_date__c = System.now();
                newHistoryRecord.core_cpq_start_date__c = oldHistoryRecord!=null ? oldHistoryRecord.core_cpq_end_date__c : quoteRec.CreatedDate;
                newHistoryRecord.core_cpq_start_user__c = oldHistoryRecord!=null  ? oldHistoryRecord.core_cpq_end_user__c : quoteRec.CreatedById;           
                if (quoteIdToNewStatusMap.get(quoteId) == 'Approved') {
                    if(quoteIdToApprRecMap.containsKey(quoteId) && quoteIdToApprRecMap.get(quoteId)?.sbaa__ApprovalChain__r.Name.contains('BM')){
                        newHistoryRecord.core_cpq_bm_level__c = !bmRecord.isEmpty() ? bmRecord[0].core_cpq_bm_level_nm__c : '';
                    }else{
                        newHistoryRecord.core_cpq_bm_level__c ='';
                    }                
                    newHistoryRecord.core_cpq_approval__c = quoteIdToApprRecMap.containsKey(quoteId) ? quoteIdToApprRecMap.get(quoteId).Id : null;
                    newHistoryRecord.core_cpq_approval_chain__c = quoteIdToApprRecMap.containsKey(quoteId) ? quoteIdToApprRecMap.get(quoteId).sbaa__ApprovalChain__r.Name : '';
                }
                quoteHistoryList.add(newHistoryRecord);
            }
            if(!quoteHistoryList.isEmpty()){
                List<Database.SaveResult> results = Database.insert(quoteHistoryList,false);
                List<core_cpq_quote_history__c> failedList = new List<core_cpq_quote_history__c>();
                for(Integer i=0;i<results.size();i++){
                    if(!results[i].isSuccess()){
                        failedList.add(quoteHistoryList[i]);
                    }
                }
                if(!failedList.isEmpty()){
                    PSG_Utility.createCoreLogEntry('PSG_QuoteHistoryTracking', 'createHistory', 'Error while creating records for quote field history', 'FieldHistory Failed to Insert => '+failedList, 'core_cpq_quote_history__c', 'Low', '');
                }        
            }             
        }catch(Exception e ){
            PSG_Utility.createCoreLogEntry('PSG_QuoteHistoryTracking', 'createHistory', 'Exception while creating records for quote field history', 'quoteIdToNewStatusMap=> '+quoteIdToNewStatusMap+' quoteIdToOldStatusMap=> '+quoteIdToOldStatusMap+' Exception =>'+e, 'core_cpq_quote_history__c', 'Low', '');
        }               
    }
    
    /************************************************************************************************************
    *Method Name : updateApprovalHistory
    *Created Date: 9/6/2023
    *Author: Bishal Singh
    *Description : Creates PSG Field History Record on approval of Quote Approval Record. 
    ************************************************************************************************************/
    /*@future
    public static void updateApprovalHistory(Set<String> quoteIds){
        try{
            List<core_cpq_quote_history__c> fieldHistoryToInsert = new List<core_cpq_quote_history__c>();
            Map<Id, core_cpq_quote_history__c> quoteHistoryMap = new Map<Id, core_cpq_quote_history__c>();
            Map<Id,sbaa__Approval__c> quoteToApprovalMap=new Map<Id,sbaa__Approval__c>();
            Set<String> nextApprovalRecord = new Set<String>();
            Set<String> quoteWithNextApprovaRecords=new Set<String>();
            List<core_cpq_bm_level__c> bmRecord = [SELECT id, core_cpq_bm_level_nm__c, core_cpq_bm_name__c  
                                                   FROM core_cpq_bm_level__c 
                                                   WHERE core_cpq_bm_name__c =:UserInfo.getUserId()];  
            for(sbaa__Approval__c approvalRecord : [SELECT Id, Quote__c, sbaa__ApprovalChain__c,sbaa__ApprovalChain__r.Name, sbaa__Status__c,sbaa__ApprovedBy__c 
                                                    FROM sbaa__Approval__c WHERE Quote__c =:quoteIds and ((sbaa__ApprovedBy__c =: UserInfo.getUserId() and sbaa__Status__c='Approved') or sbaa__Status__c='Requested') order by sbaa__ApprovalStep__c DESC]){
                                                        if(approvalRecord.sbaa__Status__c=='Requested'){
                                                            quoteWithNextApprovaRecords.add(approvalRecord.Quote__c);
                                                        }else if(approvalRecord.sbaa__Status__c=='Approved' && !quoteToApprovalMap.containsKey(approvalRecord.Quote__c)){
                                                            quoteToApprovalMap.put(approvalRecord.Quote__c,approvalRecord);
                                                        }
                                                        
                                                    }
            
            for (core_cpq_quote_history__c quoteHis : [SELECT Id, core_cpq_quote__c,core_cpq_end_date__c, core_cpq_end_user__c, core_cpq_status__c,core_cpq_start_user__c
                                                       FROM core_cpq_quote_history__c
                                                       WHERE core_cpq_quote__c =:quoteIds  ORDER BY CreatedDate DESC]) {
                                                           if(!quoteHistoryMap.containsKey(quoteHis.core_cpq_quote__c)){
                                                               quoteHistoryMap.put(quoteHis.core_cpq_quote__c, quoteHis);
                                                           }
                                                       }
            
            for(String quoteId : quoteIds){
                if(quoteWithNextApprovaRecords.contains(quoteId)){
                    core_cpq_quote_history__c newHistoryRecord = new core_cpq_quote_history__c();
                    core_cpq_quote_history__c oldHistoryRecord = quoteHistoryMap.get(quoteId);
                    newHistoryRecord.core_cpq_status__c = 'In Review';
                    newHistoryRecord.core_cpq_end_date__c = System.now();
                    newHistoryRecord.core_cpq_end_user__c = UserInfo.getUserId();
                    newHistoryRecord.core_cpq_quote__c = quoteId;
                    newHistoryRecord.core_cpq_prev_status__c = oldHistoryRecord!=null ? oldHistoryRecord.core_cpq_status__c : null;
                    newHistoryRecord.core_cpq_start_date__c = oldHistoryRecord!=null ? oldHistoryRecord.core_cpq_end_date__c : null;
                    newHistoryRecord.core_cpq_start_user__c = oldHistoryRecord!=null ? oldHistoryRecord.core_cpq_end_user__c : null;
                    if(quoteToApprovalMap.containsKey(quoteId) && quoteToApprovalMap.get(quoteId)?.sbaa__ApprovalChain__r.Name.contains('BM')){
                        newHistoryRecord.core_cpq_bm_level__c = !bmRecord.isEmpty() ? bmRecord[0].core_cpq_bm_level_nm__c : '';
                    }else{
                        newHistoryRecord.core_cpq_bm_level__c =null;
                    }                
                    newHistoryRecord.core_cpq_approval__c = quoteToApprovalMap.containsKey(quoteId) ? quoteToApprovalMap.get(quoteId).Id : null;
                    newHistoryRecord.core_cpq_approval_chain__c = quoteToApprovalMap.containsKey(quoteId) ? quoteToApprovalMap.get(quoteId).sbaa__ApprovalChain__r.Name : '';
                    fieldHistoryToInsert.add(newHistoryRecord);
                }
            }
            if(!fieldHistoryToInsert.isEmpty()){
                List<Database.SaveResult> results = Database.insert(fieldHistoryToInsert,false);
                //Handle result and log failures
                List<core_cpq_quote_history__c> failedList = new List<core_cpq_quote_history__c>();
                for(Integer i=0;i<results.size();i++){
                    if(!results[i].isSuccess()){
                        failedList.add(fieldHistoryToInsert[i]);
                    }
                }
                if(!failedList.isEmpty()){
                    PSG_Utility.createCoreLogEntry('PSG_QuoteHistoryTracking', 'updateApprovalHistory', 'Error while creating records for quote field history', 'FieldHistory Failed to Insert => '+failedList, 'core_cpq_quote_history__c', 'Low', '');
                }        
            }
        }catch(Exception e){
           PSG_Utility.createCoreLogEntry('PSG_QuoteHistoryTracking', 'updateApprovalHistory', 'Exception while creating records for quote field history', 'quoteIds=> '+quoteIds+' Exception =>'+e, 'core_cpq_quote_history__c', 'Low', '');
        }                
    }*/
}