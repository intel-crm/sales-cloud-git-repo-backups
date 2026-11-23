/**
 * @description       : Batch class to auto reject PIFR and PFIR Quotelines which has passed past date check
 * @author            : Sandeep
 * @group             : Accenture
 * @last modified on  : 02-01-2024
 * @last modified by  : Sandeep Chamate
**/
public without sharing class Pricing_QuoteLine_AutoRejection_Batch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return database.getQueryLocator(Label.Pricing_QuoteLine_AutoRejection_Query);
    }
    
    public void execute(Database.BatchableContext bc, List<SBQQ__QuoteLine__c> quoteLineList){
        try{
            List<SBQQ__QuoteLine__c> quoteLinesToBeRejected = new List<SBQQ__QuoteLine__c>();
            Set<Id> rejectApprovalRecordsQLIds = new Set<Id>();
            Set<Id> rejectedQuoteLineIds = new Set<Id>();
            Set<Id> quoteLineUpdatedIdSet = new Set<Id>();
            String failedQuoteLineId = '';
            
            if(quoteLineList.size() > 0) {
                for(SBQQ__QuoteLine__c quoteLine : quoteLineList) {
                    if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview ) {
                        rejectedQuoteLineIds.add(quoteLine.Id);
                    }

                    quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Rejected;
                    quoteLine.Pricing_Change_Request_cb__c = false;
                    quoteLine.Pricing_Rejection_Reason__c = Label.Pricing_rejection_reason_other_value;
                    quoteLine.Pricing_Rejection_Comments_nm__c = Label.Pricing_Past_QuoteLine_AutoRejection_Error;
                    quoteLine.Pricing_pm_approval_comments_nm__c  = '';                    
                    if(!quoteLinesToBeRejected.contains(quoteLine)){
                        quoteLinesToBeRejected.add(quoteLine);
                        //quoteLineUpdatedIdSet.add(quoteLine.Id);
                    }
                }

                if(quoteLinesToBeRejected.size() > 0) {
                    SBQQ.TriggerControl.disable();	
                   // update quoteLinesToBeRejected;
                    List<Database.SaveResult> results = Database.update(quoteLinesToBeRejected,false);
                    SBQQ.TriggerControl.enable();

                    for(database.SaveResult sr : results) {
                        if(sr.isSuccess()){
                            quoteLineUpdatedIdSet.add(sr.getId());
                            if(rejectedQuoteLineIds.contains(sr.getId())) {
                                rejectApprovalRecordsQLIds.add(sr.getId());
                            }
                        }
                        else {
                            failedQuoteLineId = failedQuoteLineId + sr.getId() + ',';
                        }
                    }

                    List<Pricing_Quote_Line_Status_Age__c> updateRoleTPTRecordList = [Select id,Pricing_TPT_Status_From__c,Pricing_TPT_Status_Name__c,Pricing_TPT_User_Role__c FROM Pricing_Quote_Line_Status_Age__c WHERE 
                                                                                      Pricing_TPT_Quote_Line_Number__c IN :quoteLineUpdatedIdSet AND Pricing_TPT_Status_Name__c = 'Rejected'];
                    if(updateRoleTPTRecordList.size() > 0) {
                        for(Pricing_Quote_Line_Status_Age__c tptRec : updateRoleTPTRecordList) {
                            tptRec.Pricing_TPT_User_Role__c = tptRec.Pricing_TPT_Status_From__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview ? 'System User (SDM)' : 'System User (RPM)'; 
                        }  
                    }
                    update updateRoleTPTRecordList;
                }
                if(rejectApprovalRecordsQLIds.size()>0){
                   Pricing_Publish_Quote.setFSEActionOnQuoteLine(rejectApprovalRecordsQLIds,Label.Pricing_Tender_QuoteLine_Action_Reject,Label.Pricing_Past_QuoteLine_AutoRejection_Error,false);
                }

                if(!String.isBlank(failedQuoteLineId)){
                    createCoreLogEntry(failedQuoteLineId,'Failed to Update','Pricing_QuoteLine_AutoRejection_Batch');
                }
            }  
        } catch(exception ex) {
            Pricing_Tender_Utility.logError(ex);
        }
        finally{
        	SBQQ.TriggerControl.enable();
        }
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
    public static void createCoreLogEntry(String details, String message, String origin){
        String subject = Label.Pricing_IQR_Support_Email_Subject + ' ' +origin;
        core_log_entry__c logEntry = new core_log_entry__c();
        logEntry.Core_Details__c = 'Failed to process following records: ' +details.removeEnd(',');
        logEntry.Core_Message__c = Label.Pricing_IQR_SFDC_Environment + ': ' + subject;
        logEntry.Core_Origin__c = Label.Pricing_IQR_Program_Name;
        logEntry.Core_Project__c = Label.Pricing_IQR_Program_Name;
        logEntry.Core_Severity__c = 'Critical';
        logEntry.Core_Scope__c = origin;
        logEntry.Core_Support_Email__c = Label.Pricing_IQR_Support_Email;
        logEntry.Core_Support_Link__c = Label.Pricing_IQR_Support_Link;
        logEntry.Core_When__c = system.now();
        insert logEntry;
    }

}