/****************************************************************************************************************************************
* Class Name        : Core_MDF_Bulk_Approval_requests_Batch
* Test Class Name   : Core_MDF_Bulk_ApprovalReqs_Batch_Test
* Created Date      : 16/11/2021
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Sai       16/11/2021         Batch class to do processing of bulk approval requests
*****************************************************************************************************************************************/

public with sharing class Core_MDF_Bulk_Approval_requests_Batch implements Database.Batchable<Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper>, Database.Stateful {
    List<Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper> finalaprReqsList = new List<Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper>();
    String recordId;
    String action;
    String approvalComments;
    public List<String> workItemsIds = new List<String>();
    
    public Core_MDF_Bulk_Approval_requests_Batch(List<Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper> aprReqsList) {
        finalaprReqsList = aprReqsList;
    }
    
    /***************************************************************************************************** 
Method Name :   start
@return     :   List of approval requests from a wrapper class for bulk approvals
@parameters :   Database.BatchableContext
Description :   It fetches all approval requests from a controller class of Core_MDF_Bulk_Approvals_Requests for bulk approvals
Added By    :   Accenture - Sai - 16/11/2021 
Modified By :                               Date:                   Changes:
******************************************************************************************************/ 
    public Iterable<Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper> start(Database.BatchableContext context) {
        return finalaprReqsList;
    }
    
    /******************************************************************************************************** 
Method Name :   execute
@return     :   void
@parameters :   Database.BatchableContext
Description :   Selects all approval requests for bulk approvals
Added By    :   Accenture - Sai - 16/11/2020
Modified By :                               Date:         Changes:  
**********************************************************************************************************/
    public void execute(Database.BatchableContext context, List<Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper> aprReqsListScope) {
        List<Approval.ProcessWorkitemRequest> pwrList = new List<Approval.ProcessWorkitemRequest>();
        for(Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper aprReqs : aprReqsListScope){
            Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
            recordId = aprReqs.requestId;
            action = aprReqs.actionStatus;
            approvalComments = aprReqs.comments;
            pwr.setComments(approvalComments);
            pwr.setAction(action);
            pwr.setWorkitemId(recordId);
            pwrList.add(pwr);
        }
        Core_MDF_Bulk_Approvals_Requests.ProcessResultWrapper procResult = Core_MDF_Bulk_Approvals_Requests.processBulkApprovalRequests(pwrList);
        workItemsIds = getSuccessIdsFromExecuteBatch(procResult);
    }
    
    /******************************************************************************************************** 
Method Name :   finish
@return     :   void
@parameters :   Database.BatchableContext
Description :   finish method of a batch class
Added By    :   Accenture - Sai - 16/11/2021
Modified By :                               Date:         Changes:  
**********************************************************************************************************/
    public void finish(Database.BatchableContext context) {
        if(workItemsIds.size() > 0){
            deleteSuccessfulRecordTracingRecords(workItemsIds);
        }
        sendEmail();
    }
    
    /******************************************************************************************************** 
Method Name :   sendEmail
@return     :   void
@parameters :   null
Description :   Sends the email to the respective users which has the result of the processing of bulk approval records
Added By    :   Accenture - Sai - 03/12/2021
Modified By :                               Date:         Changes:  
**********************************************************************************************************/
    public static void sendEmail(){
        List<Messaging.SingleEmailMessage> emailTosendList= new List<Messaging.SingleEmailMessage>();
        String userId = UserInfo.getUserId();
        String emailTemplateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Notify_Bulk_Proposals_Approver');
        
        List<EmailTemplate> etList = new List<EmailTemplate>();
        if(String.isNotBlank(emailTemplateName)){
            etList = [SELECT Id, Body, HtmlValue, Subject, DeveloperName FROM EmailTemplate WHERE DeveloperName =:emailTemplateName LIMIT 1];                      
        }
        if(etList != null && etList.size() > 0){
            
            emailTosendList.add(Core_MDF_GenericClassToSendMail.createEmailInstanceTarget(null, etList[0].Id, userId));
            
            if(emailTosendList != NULL && emailTosendList.size() > 0){
                Core_MDF_GenericClassToSendMail.sendEmails(emailTosendList);
            }
        }
    }
    
    /******************************************************************************************************
Method Name :   deleteSuccessfulRecordTracingRecords
@return     :   void
@parameters :   List<String>
Description :   Delete the successfull records from the Record Tracking object once the batch is completed.
Added By    :   Accenture - Sai - 17/12/2021
Modified By :                               Date:         Changes:  
**********************************************************************************************************/
    public static void deleteSuccessfulRecordTracingRecords(List<String> workItemsIds){
        List<Core_MDF_Record_Tracking__c> recTrackingListToDelete = [SELECT Id, Core_MDF_Object_Name_nm__c, Core_MDF_Scope_nm__c, Core_MDF_Target_Record_Id__c
                                                                     FROM Core_MDF_Record_Tracking__c 
                                                                     WHERE Core_MDF_Target_Record_Id__c =:workItemsIds];  
        if(recTrackingListToDelete != null && recTrackingListToDelete.size() > 0){
            Database.Delete(recTrackingListToDelete);
        }          
    }
    
    /******************************************************************************************************** 
Method Name :   getSuccessIdsFromExecuteBatch
@return     :   List<String>
@parameters :   Core_MDF_Bulk_Approvals_Requests.ProcessResultWrapper
Description :   Get the successfull records from the Execute method
Added By    :   Accenture - Sai - 17/12/2021
Modified By :                               Date:         Changes:  
**********************************************************************************************************/
    public static List<String> getSuccessIdsFromExecuteBatch(Core_MDF_Bulk_Approvals_Requests.ProcessResultWrapper procResult){
        List<String> workItemsIds = new List<String>();
        if(procResult.allItemsList != null && procResult.allItemsList.size() > 0){
            String allItemsString = JSON.serialize(procResult.allItemsList);
            List<ProcResultWrapper> procResultList = (List<ProcResultWrapper>)JSON.deserialize(allItemsString, List<ProcResultWrapper>.class);
            if(procResultList != null && procResultList.size() > 0){
                for(ProcResultWrapper procRes : procResultList){
                    workItemsIds.add(procRes.workitemId);
                }
            }
        }
        return workItemsIds;
    }
    
    public class ProcResultWrapper {
        @AuraEnabled public String workitemId {get; set;}
    }
}