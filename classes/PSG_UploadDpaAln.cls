/****************************************************************************************************
Apex Class Name : PSG_UploadDpaAln
Version         : 1.0 
Created Date    : 02/11/2021
Function        : This class is controller of DPA/ALN Bulk Upload.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Adarsh/Drushti              02/11/2022                Created
*****************************************************************************************************/
public without sharing class PSG_UploadDpaAln {
    @AuraEnabled
    public static resultWrapper validateRecord(String obj, String cisNo, String action, Date shipEndDate){
        resultWrapper res = new resultWrapper();
        List<String> dpaAlnList = cisNo.trim().split(',');
        List<String> trimString = new List<String>();
        for(String s : dpaAlnList){
            trimString.add(s.trim());
        }
        dpaAlnList = trimString;
        Map<String,String> dpaAlnToResultMap = new Map<String,String>();
        Map<String,String> dpaAlnToReasonMap = new Map<String,String>();
        List<String> duplicateList = new List<String>();
        Set<String> dpaAlnSet = new Set<String>();
        List<String> successList = new List<String>();
        List<core_cpq_dpa_aln__c> dpaAlnValidList = new List<core_cpq_dpa_aln__c>();
        List<String> duplicateValidList = new List<String>();
        List<core_cpq_dpa_aln__c> dpaAlnRec = [Select id,Name,core_cpq_ship_end_date_dt__c, core_cpq_change_flag__c,core_cpq_record_type_identifier__c,core_cpq_status_txt__c from core_cpq_dpa_aln__c WHERE Name IN: dpaAlnList];
        List<String> validCis = new List<String>();
        List<String> invalidCis = new List<String>();
        Integer s=0;
        for(core_cpq_dpa_aln__c dpaAlnNo : dpaAlnRec){
            if(dpaAlnNo.core_cpq_record_type_identifier__c == obj && dpaAlnNo.core_cpq_status_txt__c == 'Approved'){
                validCis.add(dpaAlnNo.Name);
            }
            else{
                invalidCis.add(dpaAlnNo.Name);
            }
        }
        for(String dpaAln : dpaAlnList){
            if(dpaAlnSet.contains(dpaAln)){
                duplicateList.add(dpaAln);
            }
            else{
                dpaAlnSet.add(dpaAln);
            }
        }
        
        for(String str : dpaAlnList){
            if(validCis.contains(str)){
                if(dpaAlnSet.contains(str) && !duplicateValidList.contains(str)){
                    dpaAlnToResultMap.put(str,'Success');
                    dpaAlnToReasonMap.put(str,'');
                    duplicateValidList.add(str);
                }
                else{
                    dpaAlnToResultMap.put(str,'Duplicate');
                    dpaAlnToReasonMap.put(str,'Duplicate Records Found');
                } 
            }
            else if(invalidCis.contains(str)){
                dpaAlnToResultMap.put(str,'Failure');
                dpaAlnToReasonMap.put(str,'Not '+obj+' Number');
            }
            else{
                dpaAlnToResultMap.put(str,'Failure');
                dpaAlnToReasonMap.put(str,'Invalid CIS Number');
            }
        }
        for(core_cpq_dpa_aln__c dpaAln : dpaAlnRec){
            if(dpaAln.core_cpq_record_type_identifier__c == obj && dpaAln.core_cpq_status_txt__c == 'Approved'){
                if(dpaAln.core_cpq_record_type_identifier__c == 'ALN' && action == 'Hold'){
                dpaAln.core_cpq_change_flag__c = 'H';
            	}
            	else{
                	dpaAln.core_cpq_change_flag__c = 'E';
            		dpaAln.core_cpq_ship_end_date_dt__c = shipEndDate;
                }
            	dpaAlnValidList.add(dpaAln);
            }
            else if(dpaAln.core_cpq_record_type_identifier__c == obj){
                dpaAlnToReasonMap.put(dpaAln.Name,'Not an Approved '+ obj);
            }
        }
        if(dpaAlnValidList != null && !dpaAlnValidList.isEmpty()){
            Database.SaveResult[] result = Database.update(dpaAlnValidList, false);
            for(Integer i=0;i<result.size();i++){
                if (!result?.get(i)?.isSuccess()){
                    Database.Error error = result?.get(i)?.getErrors()?.get(0);
                    String failedDML = error?.getMessage();
                    dpaAlnToReasonMap.put(dpaAlnValidList[i]?.Name,failedDML);
                    dpaAlnToResultMap.put(dpaAlnValidList[i]?.Name,'Failure');
                }   
                else{
                    s++;
                    successList.add(dpaAlnValidList[i]?.Name);
                }
            }
        }        
        res.dpaAlnNoList = dpaAlnList;
        res.cisNoToResultMap = dpaAlnToResultMap;
        res.cisNoToReasonMap = dpaAlnToReasonMap;
        res.successCount = s;
        res.successValues = successList;
        return res;        
    }
    public class resultWrapper{  
        @AuraEnabled public List<String> dpaAlnNoList {get; set;}  
        @AuraEnabled public Map<String,String> cisNoToResultMap {get; set;}
        @AuraEnabled public Map<String,String> cisNoToReasonMap {get; set;}
        @AuraEnabled public List<String> successValues{get; set;}
        @AuraEnabled public Integer successCount;
    }
    @AuraEnabled
    public static void submitRecToSAP(List<String> successLst){
        if(successLst != null && !successLst.isEmpty()){
            PSG_SendBulkSAPRequestBatch batch1 = new PSG_SendBulkSAPRequestBatch();
            batch1.cisNoList = successLst;
			Database.executeBatch(batch1, 1);
        }
    }
    
    @AuraEnabled
    public static void validateQuoteRecord(String quoteNo, String action){
        List<String> quoteNoList = quoteNo.trim().split(',');
        List<String> trimString = new List<String>();
        for(String str : quoteNoList){
            trimString.add(str.trim());
        }
        quoteNoList = trimString;
        PSG_BulkQuoteRevisionDeactivationBatch bat = new PSG_BulkQuoteRevisionDeactivationBatch();
        bat.quoteNoList = quoteNoList;
        bat.action = action;
        String jobId;
        if(action=='Revise'){
            jobId = Database.executeBatch(bat, 1);
        }else{
            jobId = Database.executeBatch(bat,Integer.valueOf(Label.PSG_QuoteDeactivateBatchLimit));
        }
        PSG_Utility.createCoreLogEntry('PSG_UploadDpaAln','validateQuoteRecord',action+' batch job details','batch jobId :'+jobId
                                           ,'SBQQ__Quote__c','Info','');   
    }
    /************************************************************************************************************
	*Method Name : validatingUserAccess
	*Created Date: 11/30/2023
	*Author: Adarsh Parashar
	*Description : Checking User is available in the group.
	************************************************************************************************************/
    @AuraEnabled
    public static boolean validatingUserAccess(){
        boolean isUserAccess = false;
        
        for(GroupMember gId : [select UserOrGroupId,GroupId from GroupMember where UserOrGroupId =: UserInfo.getUserId() AND group.DeveloperName = 'PSG_Bulk_Operation_Quote']){
            isUserAccess=true;
        }
        return isUserAccess;
    }
}