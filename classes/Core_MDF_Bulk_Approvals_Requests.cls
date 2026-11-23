/****************************************************************************************************************************************
* Class Name        : Core_MDF_Bulk_Approvals_Requests
* Test Class Name   : Core_MDF_Bulk_Approvals_Requests_Test
* Created Date      : 03/11/2021
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Sai      03/11/2021      Class to process bulk approval requests
*****************************************************************************************************************************************/   
public without sharing class Core_MDF_Bulk_Approvals_Requests {
    
    /****************************************************************************************************************** 
Method Name   :        isBulkApprovalRequestsNeeded
@return       :        Boolean
@parameters   :        null
Description   :        returns true for the users based on the permission sets defined for bulk approvals and object & program type
Added By      :        Accenture - Sai - 03/11/2021
Modified By   :        Date:           Changes:
1. Sai                 06/12/2021      Now checking the user with its permission sets defined for bulk approvals.
1. Sai                 07/01/2022      After checking with PS, checking object and program type additionally
***********************************************************************************************************************/  
    //Commented - WW14 as part of unused code - Alekhya
    /*@AuraEnabled
    public static Boolean isBulkApprovalRequestsNeeded(){        
        try {
            List<ProcessInstanceWorkItem> piwiList = new List<ProcessInstanceWorkItem>();
            Boolean isBulkApprovalRequestsActive = false;
            String bulkApproverUserId = UserInfo.getUserId(); 
            List<String> bulkApprovalPermSetsList = new List<String>();
            String bulkApprovalPermSet = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Bulk_Approval_Permission_Sets');
            if(bulkApprovalPermSet != null){
                bulkApprovalPermSetsList = bulkApprovalPermSet.split(','); 
            } 
            List<PermissionSetAssignment> perSetAssList = [SELECT Id, AssigneeId, PermissionSet.Name, PermissionSetId FROM PermissionSetAssignment 
                                                           WHERE AssigneeId = :bulkApproverUserId AND PermissionSet.Name = :bulkApprovalPermSetsList
                                                           AND Assignee.IsActive = TRUE];
            if(perSetAssList != null && perSetAssList.size() > 0){
                isBulkApprovalRequestsActive = true;
                System.debug('CHECK 1: ' +isBulkApprovalRequestsActive);
                for(ProcessInstanceWorkItem piwi : [SELECT id, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Type, 
                                                    ProcessInstance.TargetObject.Name, CreatedBy.name, CreatedDate FROM ProcessInstanceWorkItem
                                                    WHERE ProcessInstance.Status = 'Pending' AND Actor.Id = :bulkApproverUserId  ORDER BY CreatedDate desc])
                { 
                    piwiList.add(piwi); 
                }
                System.debug('CHECK 2: ' +piwiList);
                System.debug('CHECK 2_1: ' +piwiList.size());
                List<Id> campaignOrPfrIds = new List<Id>();
                List<String> programType = new List<String>();
                if(piwiList != null && piwiList.size() > 0){
                    for(ProcessInstanceWorkItem piwi : piwiList){
                        campaignOrPfrIds.add(piwi.ProcessInstance.TargetObjectId);
                        programType.add(piwi.ProcessInstance.TargetObject.Type); 
                        System.debug('CHECK 3_1: ' +programType);
                        System.debug('CHECK 3_2: ' +piwi);
                    }
                    System.debug('CHECK 3_3: ' +programType[0]);
                    System.debug('CHECK 3_4: ' +programType[1]);
                    System.debug('CHECK 3_5: ' +programType.size());
                }
                if(programType[0] == 'Campaign'){
                    Campaign campaignRecord = [Select Id, Core_MDF_Program__c from Campaign where Id=:campaignOrPfrIds LIMIT 1];
                    if(campaignRecord != null){
                        isBulkApprovalRequestsActive = campaignRecord.Core_MDF_Program__c == 'Intel Partner Alliance' ? true : false;
                        System.debug('CHECK 3: ' +campaignRecord.Core_MDF_Program__c);
                        System.debug('CHECK 4: ' +isBulkApprovalRequestsActive);
                    }
                    
                }
                else if(programType[0] == 'PartnerFundRequest'){
                    PartnerFundRequest pfrRecord = [Select Id, Core_MDF_Program__c from PartnerFundRequest where Id=:campaignOrPfrIds LIMIT 1];
                    if(pfrRecord != null){
                        isBulkApprovalRequestsActive = pfrRecord.Core_MDF_Program__c == 'Intel Partner Alliance' ? true : false;
                        System.debug('CHECK 5: ' +pfrRecord.Core_MDF_Program__c);
                        System.debug('CHECK 6: ' +isBulkApprovalRequestsActive);
                    }
                }
            }               
            System.debug('CHECK 7: ' +isBulkApprovalRequestsActive);
            return isBulkApprovalRequestsActive;  
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
    }*/

    /****************************************************************************************************************** 
Method Name   :        isBulkApprovalRequestsNeeded
@return       :        Boolean
@parameters   :        null
Description   :        returns true for the users based on the permission sets defined for bulk approvals
Added By      :        Accenture - Sai - 03/11/2021
Modified By   :        Date:           Changes:
1. Sai                 06/12/2021      Now checking the user with its permission sets defined for bulk approvals.
***********************************************************************************************************************/  
@AuraEnabled
public static Boolean isBulkApprovalRequestsNeeded(){        
    try {
        Boolean isBulkApprovalRequestsActive = false;
        String bulkApproverUserId = UserInfo.getUserId(); 
        List<String> bulkApprovalPermSetsList = new List<String>();
        String bulkApprovalPermSet = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Bulk_Approval_Permission_Sets');
        if(bulkApprovalPermSet != null){
            bulkApprovalPermSetsList = bulkApprovalPermSet.split(','); 
        } 
         //Jahnavi K -- Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
        for(List<PermissionSetAssignment> perSetAssList : [SELECT Id, AssigneeId, PermissionSet.Name, PermissionSetId
                                                           FROM PermissionSetAssignment 
                                                           WHERE AssigneeId = :bulkApproverUserId
                                                           AND PermissionSet.Name = :bulkApprovalPermSetsList
                                                           AND (Assignee.IsActive = TRUE or Assignee.Partner_License_Reclaimed__c = TRUE)]){
                                                               if(perSetAssList != null && perSetAssList.size() > 0){
                                                                   isBulkApprovalRequestsActive = true;
                                                               }
                                                           }
        return isBulkApprovalRequestsActive;  
    } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
}
    
    /***************************************************************************************************** 
Method Name   :        submitBulkApprovalRequests
@return       :        Core_MDF_ResponseHandler
@parameters   :        approvalRequests
Description   :        Returns Bulk Approval Result wrapper instance
Added By      :        Accenture - Sai - 03/11/2021
******************************************************************************************************/  
    
    @AuraEnabled
    public static Core_MDF_ResponseHandler submitBulkApprovalRequests(String approvalRequests){
        String recordId;
        String action;
        String approvalComments;
        String responseMessage = '';
        Boolean isSuccess;
        Core_MDF_ResponseHandler result;
        List<Approval.ProcessWorkitemRequest> pwrList = new List<Approval.ProcessWorkitemRequest>();
        List<ApprovalRequestsWrapper> aprReqsList = new List<ApprovalRequestsWrapper>();
        try{
            if(String.isNotBlank(approvalRequests) && approvalRequests != null){
                aprReqsList = (List<ApprovalRequestsWrapper>) JSON.deserialize(approvalRequests, List<ApprovalRequestsWrapper>.class);
            }
            if(aprReqsList.size() <= 0){
                isSuccess = false;
                responseMessage += Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_No_Approvals_Selected_Message');
                result = new Core_MDF_ResponseHandler(isSuccess, responseMessage, null); 
            }
            else if(aprReqsList != null && aprReqsList.size() <= 10){
                for(ApprovalRequestsWrapper aprReqs : aprReqsList){
                    Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                    recordId = aprReqs.requestId;
                    action = aprReqs.actionStatus;
                    approvalComments = aprReqs.comments;
                    pwr.setComments(approvalComments);
                    pwr.setAction(action);
                    pwr.setWorkitemId(recordId);
                    pwrList.add(pwr);
                }
                processBulkApprovalRequests(pwrList);
                isSuccess = true;
                responseMessage += Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Bulk_Approvals_Sync_Message');
                result = new Core_MDF_ResponseHandler(isSuccess, responseMessage, null); 
            }
            else if(aprReqsList != null && aprReqsList.size() > 10){
                addrecordTrackingForBulkRequests(aprReqsList);
                Database.executeBatch(new Core_MDF_Bulk_Approval_requests_Batch(aprReqsList));
                isSuccess = true;
                responseMessage   += Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Bulk_Approvals_Async_Message');
                result = new Core_MDF_ResponseHandler(isSuccess, responseMessage, null);
            }     
        }
        catch (Exception e) {
            String logerror = e.getLineNumber() + '->' + e.getMessage() + '->';Core_MDF_CCP_UtilityClass.logErrorinLogObject(logerror,'submitBulkApprovalRequests Method');
            isSuccess = false;responseMessage += Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Bulk_Approvals_Error_Message');
            result = new Core_MDF_ResponseHandler(isSuccess, responseMessage, null);           
        }
        return result;
    }
    
    /***************************************************************************************************** 
Method Name   :        getBulkApprovalCustomMessages
@return       :        BulkApprovalCustomUIMessagesWrapper
@parameters   :        none
Description   :        Returns custom messages
Added By      :        Accenture - Sai - 08/11/2021
******************************************************************************************************/ 
    
    @AuraEnabled
    public static BulkApprovalCustomUIMessagesWrapper getBulkApprovalCustomMessages(){
        BulkApprovalCustomUIMessagesWrapper custMessage = new BulkApprovalCustomUIMessagesWrapper();
        custMessage.disclaimerHeader = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BulkApprovals_Disclaimer_Header');
        custMessage.disclaimerMessage = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BulkApprovals_DisclaimerMessage');
        custMessage.approveAllHoverText = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Bulk_Approve_All_Hover_Message');
        custMessage.rejectAllHoverText = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Bulk_Reject_All_Hover_Message');
        return custMessage;
    }
    
    /***************************************************************************************************** 
Method Name   :        processBulkApprovalRequests
@return       :        ProcessResultWrapper
@parameters   :        List<Approval.ProcessWorkitemRequest>
Description   :        Returns wrapper instance
Added By      :        Accenture - Sai - 09/12/2021
******************************************************************************************************/ 
    
    public static ProcessResultWrapper processBulkApprovalRequests(List<Approval.ProcessWorkitemRequest> pwrList){
        ProcessResultWrapper processResWrapper = new ProcessResultWrapper();
        Integer index = 0;
        List<Approval.ProcessWorkitemRequest> successProcessItemsList = new List<Approval.ProcessWorkitemRequest>();
        List<Approval.ProcessWorkitemRequest> errorProcessItemsList = new List<Approval.ProcessWorkitemRequest>();
        List<Approval.ProcessWorkitemRequest> allProcessItemsList = new List<Approval.ProcessWorkitemRequest>();
        List<Approval.ProcessResult> processResultList = Approval.process(pwrList, false);
        for(Approval.ProcessResult proRes : processResultList){
            if(proRes.isSuccess()){
                successProcessItemsList.add(pwrList[index]);
                processResWrapper.successItemsList = successProcessItemsList;
            }
            else if(proRes != null && !proRes.isSuccess()){
                String errorMessage = 'Approval failed for -> ' + pwrList[index] + '; '; 
                for(Database.Error errDetail : proRes.getErrors()){
                    errorMessage += errDetail.getMessage();
                }
                errorProcessItemsList.add(pwrList[index]);
                processResWrapper.errorItemsList = errorProcessItemsList;
            }
            allProcessItemsList.add(pwrList[index]);
            processResWrapper.allItemsList = allProcessItemsList;
            index++;
        }
        return processResWrapper;
    }
    
    /************************************************************************************************* 
Method Name   :        addrecordTrackingForBulkRequests
@return       :        none
@parameters   :        List<ApprovalRequestsWrapper>
Description   :        Add records in Record Tracking object for processing the bulk approvals
Added By      :        Accenture - Sai - 16/12/2021
******************************************************************************************************/ 
    
    public static void addrecordTrackingForBulkRequests(List<ApprovalRequestsWrapper> aprReqsList){
        List<Core_MDF_Record_Tracking__c> recTrackingList = new List<Core_MDF_Record_Tracking__c>();
        for(ApprovalRequestsWrapper aprReqs : aprReqsList){
            Core_MDF_Record_Tracking__c recTracking = new Core_MDF_Record_Tracking__c();
            recTracking.Core_MDF_Object_Name_nm__c = 'Approval.ProcessWorkitemRequest';
            recTracking.Core_MDF_Scope_nm__c = 'Bulk Approval Batch';
            recTracking.Core_MDF_Target_Record_Id__c = aprReqs.requestId;
            recTrackingList.add(recTracking);
        }
        Database.Insert(recTrackingList);
    }
    
    /**************************************************************************************************
Method Name   :        getRecordTrackingForBulkRequests
@return       :        List<Id>
@parameters   :        none
Description   :        get active records in Record Tracking object with scope of Bulk Approval Batch
Added By      :        Accenture - Sai - 17/12/2021
******************************************************************************************************/ 
    @AuraEnabled   
    public static List<Id> getRecordTrackingForBulkRequests(){
        List<Id> trackingWorkItemIds = new List<Id>();
        List<Core_MDF_Record_Tracking__c> recTrackingList = [SELECT Id, Core_MDF_Object_Name_nm__c, Core_MDF_Scope_nm__c, Core_MDF_Target_Record_Id__c
                                                             FROM Core_MDF_Record_Tracking__c
                                                             WHERE Core_MDF_Object_Name_nm__c = 'Approval.ProcessWorkitemRequest'
                                                             AND Core_MDF_Scope_nm__c = 'Bulk Approval Batch'];
        if(recTrackingList != null && recTrackingList.size() > 0){
            for(Core_MDF_Record_Tracking__c recTracking : recTrackingList){
                trackingWorkItemIds.add(recTracking.Core_MDF_Target_Record_Id__c);
            }
        }
        return trackingWorkItemIds;
    }
    
    public class ApprovalRequestsWrapper {
        @AuraEnabled public String requestId {get; set;}
        @AuraEnabled public String actionStatus {get; set;}
        @AuraEnabled public String comments {get; set;}
    }
    
    public class BulkApprovalCustomUIMessagesWrapper{
        @AuraEnabled public String disclaimerHeader {get; set;}
        @AuraEnabled public String disclaimerMessage {get; set;}
        @AuraEnabled public String approveAllHoverText {get; set;}
        @AuraEnabled public String rejectAllHoverText {get; set;}
    }
    
    public class ProcessResultWrapper {
        @AuraEnabled public List<Approval.ProcessWorkitemRequest> successItemsList {get; set;}
        @AuraEnabled public List<Approval.ProcessWorkitemRequest> errorItemsList {get; set;}
        @AuraEnabled public List<Approval.ProcessWorkitemRequest> allItemsList {get; set;}
    }
    
}