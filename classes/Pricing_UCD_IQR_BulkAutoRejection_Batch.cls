/****************************************************************************************************
Apex Class Name : Pricing_UCD_IQR_BulkAutoRejection_Batch
Version         : 1.0 
Created Date    : -
Function        : This class is used to bulk auto reject quotelines if end customer is on restricted party list 
Modifications   :
*****************************************************************************************************
* Developer : Grishma                            
*****************************************************************************************************/

public without sharing class Pricing_UCD_IQR_BulkAutoRejection_Batch implements Database.Batchable<sObject> {
 
    public Database.QueryLocator start(Database.BatchableContext bc){
        //Query to get all quotelines where Status = PIFR or PFIR and Is Sanctioned = true and change requests that are not active(Integration status = null)
        system.debug('entering'); 
        return database.getQueryLocator([SELECT id,Pricing_Status_Nm__c, Pricing_Is_Sanctioned__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c,Pricing_Reference_Quote_Line_Nbr__c,Pricing_Integration_Status_Nm__c,Pricing_Rejection_Reason__c, 
                                        Pricing_Rejection_Comments_nm__c FROM SBQQ__QuoteLine__c WHERE Pricing_Quote_Program_Nm__c =: Label.Pricing_Tender_Quote_Program AND 
                                        Pricing_Is_Sanctioned__c=true AND (Pricing_Status_Nm__c IN: Label.Pricing_Tender_QuoteLine_Edit_Status.split(':')) 
                                        AND (Pricing_New_Change_Request_cb__c = false OR (Pricing_New_Change_Request_cb__c = true AND Pricing_Integration_Status_Nm__c = null))]);
                                        
    }   
    
    public void execute(Database.BatchableContext bc, List<SBQQ__QuoteLine__c> quoteLineList){
        try{
            List<SBQQ__QuoteLine__c> quoteLinesToBeRejected = new List<SBQQ__QuoteLine__c>(); //List of quotelines to be Rejected
            Set<Id> rejectApprovalRecordsQLIds = new Set<Id>();  //Set of PIFR quoteline Ids where multiple FSE Approval records are to be rejected
            Id IntegrationUserId = [SELECT Id FROM User WHERE Name =: Label.Pricing_Integration_User LIMIT 1][0].Id ;
            Set<Id> quoteLineUpdatedIdSet = new Set<Id>();
            Set<Id> rejectedQuoteLineIds = new Set<Id>();
            String failedQuoteLineId = '';
            
            system.debug('quoteLineList:'+quoteLineList);
            if(quoteLineList.size() > 0) {
                for(SBQQ__QuoteLine__c quoteLine : quoteLineList) {
                    if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview ) {
                        rejectedQuoteLineIds.add(quoteLine.Id);
                    }else {  //Populate Pricing Manager as Integration User for PFIR quotelines 
                        if(quoteLine.Pricing_Integration_Status_Nm__c == null && IntegrationUserId != null){
                            quoteLine.Pricing_Manager__c = IntegrationUserId;
                        }   
                    }
                    quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Rejected;
                    quoteLine.Pricing_Change_Request_cb__c = false;
                    quoteLine.Pricing_Rejection_Reason__c = Label.Pricing_rejection_reason_other_value;
                    List<String> complianceWatchList = new List<String>();
                    complianceWatchList = quoteLine.SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c.split(';');
                    quoteLine.Pricing_Rejection_Comments_nm__c = complianceWatchList.contains('EC') ? Label.Pricing_UCD_Auto_Rejection_Comments_For_EC:Label.Pricing_UCD_Auto_Rejection_Comments;
                    quoteLine.Pricing_pm_approval_comments_nm__c  = '';
                    if(!quoteLinesToBeRejected.contains(quoteLine)){
                        quoteLinesToBeRejected.add(quoteLine);
                        //quoteLineUpdatedIdSet.add(quoteLine.Id);
                    }
                }
                //Update quotelines to rejected
                if(quoteLinesToBeRejected.size() > 0) {
                    //Update QuoteLines to rejected
                    SBQQ.TriggerControl.disable();	
                    //update quoteLinesToBeRejected;
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
					//Update TPT record Role for quotelines that got rejected
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
                   Pricing_Publish_Quote.setFSEActionOnQuoteLine(rejectApprovalRecordsQLIds,Label.Pricing_Tender_QuoteLine_Action_Reject,Label.Pricing_UCD_Auto_Rejection_Comments,false);
                }

                if(!String.isBlank(failedQuoteLineId)){
                    Pricing_QuoteLine_AutoRejection_Batch.createCoreLogEntry(failedQuoteLineId,'Failed to Update','Pricing_UCD_IQR_BulkAutoRejection_Batch');
                }
            }  
        } catch(exception ex) {
            Pricing_Tender_Utility.logError(ex);}
        finally{
        	SBQQ.TriggerControl.enable();
        }
    } 
    
    public void finish(database.BatchableContext bc) {       
    }
}