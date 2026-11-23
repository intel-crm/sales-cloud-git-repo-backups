global without sharing class Pricing_ApproveRejectCmntsUpdate_Batch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, Pricing_Quote_Line_Number__c, Pricing_Status_Nm__c, Pricing_Rejection_Comments_nm__c, Pricing_Rejection_Reason__c, Pricing_pm_approval_comments_nm__c 
                                         FROM SBQQ__QuoteLine__c WHERE Pricing_Quote_Program_Nm__c =: Label.Pricing_Tender_Quote_Program AND 
                                         Pricing_Status_Nm__c IN: Label.Pricing_ApproveRejectCmntsUpdate_QLI_Statuses.split(',') ORDER BY CreatedDate DESC]);
    }
    public void execute(Database.BatchableContext bc, List<SBQQ__QuoteLine__c> quoteLineList){
        try{
            Map<Id,String> qlIdToQLNumMap = new Map<Id,String>();
            List<SBQQ__QuoteLine__c> qlListToUpdate = new List<SBQQ__QuoteLine__c>();
            List<Database.SaveResult> qliUpdResults = new List<Database.SaveResult>();
            Map<String,String> errorMap = new Map<String,String>();
            String errorMsg;
            for(SBQQ__QuoteLine__c qli: quoteLineList){
                if(!String.isBlank(qli.Pricing_pm_approval_comments_nm__c) && qli.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected){
                    qli.Pricing_Rejection_Comments_nm__c = qli.Pricing_pm_approval_comments_nm__c;
                    qli.Pricing_pm_approval_comments_nm__c = '';
                    qlListToUpdate.add(qli);
                }
                qlIdToQLNumMap.put(qli.Id,qli.Pricing_Quote_Line_Number__c);
            }
            system.debug('qlListToUpdate: '+qlListToUpdate);
            if(!qlListToUpdate.isEmpty()){
                qliUpdResults = database.update(qlListToUpdate, false);
            }
            for(Database.SaveResult res : qliUpdResults){
                if(!res.isSuccess()){
                    for(Database.Error err : res.getErrors()) {
                        errorMsg = err.getMessage();
                    }
                    if(qlIdToQLNumMap.containsKey(res.getId())){
                        errorMap.put(qlIdToQLNumMap.get(res.getId()),errorMsg);
                    }
                }
            }
            if(errorMap.size()>0){
                createLogEntry(errorMap);
            }
        }
        catch(Exception e){
            Pricing_Tender_Utility.logError(e);
        }
    }
    public void finish(Database.BatchableContext bc)
    {
        
    }
    public static void createLogEntry(Map<String, String> errorQLIToMsgMap){
        List<Core_Log_Entry__c> logEntryList =  new List<Core_Log_Entry__c>();
        for(Id qliId : errorQLIToMsgMap.keySet()) {
            Core_log_Entry__c logEntry = new Core_Log_Entry__c();
            logEntry.Core_Origin__c = Label.Pricing_IQR_Program_Name;
            logEntry.Core_Project__c = Label.Pricing_IQR_Program_Name;
            logEntry.Core_sObjectId__c = qliId;
            logEntry.Core_Severity__c = 'Critical';
            logEntry.Core_Details__c = errorQLIToMsgMap.get(qliId);
            logEntry.Core_Message__c = Label.Pricing_IQR_SFDC_Environment + ':' +errorQLIToMsgMap.get(qliId) + ' ' + 'Class.Pricing_ApproveRejectCmntsUpdate_Batch - sObject Id:' +qliId;
            logEntry.Core_Support_Email__c = Label.Pricing_IQR_Support_Email;
            logEntry.Core_Support_Link__c = Label.Pricing_IQR_Support_Link;
            logEntryList.add(logEntry);
        }
        insert logEntryList;
    }
}