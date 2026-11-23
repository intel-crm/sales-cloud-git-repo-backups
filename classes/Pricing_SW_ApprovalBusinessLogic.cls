/************************************************************************************************************
    *Method Name : afterInsertUpdateApprovalComments
    *Created Date: 12/08/2024
    *Author: Priyanka Mishra 
    *Description : The  afterInsertUpdateApprovalComments method updates quotes based on their approval status by setting the 
          ApprovalStatus_c, SBQQ_Statusc, and Pricing_SW_Approval_Comments_c fields, clearing comments for recalled approvals.
    ************************************************************************************************************/
    public without sharing class Pricing_SW_ApprovalBusinessLogic {

        public static void afterInsertUpdateApprovalComments(
            List<sbaa__Approval__c> approvalList,
            Map<Id, sbaa__Approval__c> oldMap   
        ) {
            if (approvalList == null || approvalList.isEmpty() || oldMap == null) return;

            Map<Id, SBQQ__Quote__c> quotesToUpdateMap = new Map<Id, SBQQ__Quote__c>();
            List<Id> recallApprovalIds = new List<Id>();
            List<Id> approveApprovalIds = new List<Id>();
            List<Id> rejectApprovalIds = new List<Id>();
            List<Id> submitForApprovalNotificationIds = new List<Id>();

            for (sbaa__Approval__c approval : approvalList) {
                String oldStatus = oldMap.containsKey(approval.Id) && oldMap.get(approval.Id) != null 
                    ? oldMap.get(approval.Id).sbaa__Status__c 
                    : null;
                String newStatus = approval.sbaa__Status__c;

                if (newStatus != oldStatus) {
                    processApprovalStatusChange(approval, oldStatus, newStatus, quotesToUpdateMap, recallApprovalIds, approveApprovalIds, rejectApprovalIds);
                }

                if (newStatus == 'Requested') {
                    submitForApprovalNotificationIds.add(approval.Id);
                }
            }

            // Update the quotes if needed
            if (!quotesToUpdateMap.isEmpty()) {
                update quotesToUpdateMap.values();
            }

            // Send notifications based on approval status
            sendNotifications(submitForApprovalNotificationIds, recallApprovalIds, approveApprovalIds, rejectApprovalIds);
        }

        private static void processApprovalStatusChange(
            sbaa__Approval__c approval,
            String oldStatus,
            String newStatus,
            Map<Id, SBQQ__Quote__c> quotesToUpdateMap,
            List<Id> recallApprovalIds,
            List<Id> approveApprovalIds,
            List<Id> rejectApprovalIds
        ) {
            SBQQ__Quote__c quote = quotesToUpdateMap.get(approval.Quote__c);
            if (quote == null) {
                quote = new SBQQ__Quote__c(Id = approval.Quote__c);
            }

            if (newStatus == Label.Pricing_SW_QuoteApprovalStatusApproved) {
                quote.Pricing_SW_Approval_Comments__c = approval.sbaa__CommentsLong__c;
                approveApprovalIds.add(approval.Id);
            } else if (newStatus == Label.Pricing_SW_QuoteApprovalStatusRejected) {
                quote.Pricing_SW_Approval_Comments__c = approval.sbaa__CommentsLong__c;
                rejectApprovalIds.add(approval.Id);
            } else if (oldStatus == Label.Pricing_SW_Requested && newStatus == Label.Pricing_SW_QuoteApprovalStatusRecalled) {
                quote.Pricing_SW_Approval_Comments__c = null;
                recallApprovalIds.add(approval.Id);
            }

            quotesToUpdateMap.put(quote.Id, quote); 
        }

        private static void sendNotifications(
            List<Id> submitForApprovalNotificationIds,
            List<Id> recallApprovalIds,
            List<Id> approveApprovalIds,
            List<Id> rejectApprovalIds
        ) {

            if (!submitForApprovalNotificationIds.isEmpty()) {
                Pricing_SendAdvanceApprovalEmail.sendNotification(submitForApprovalNotificationIds, Label.AA_OrgWideEmailAddress, 'Pricing_SW_QuoteApprovalNotification');
            }

            if (!recallApprovalIds.isEmpty()) {
                Pricing_SendAdvanceApprovalEmail.sendNotification(recallApprovalIds, Label.AA_OrgWideEmailAddress, 'Pricing_SW_QuoteRecallNotification');
            }

            if (!approveApprovalIds.isEmpty()) {
                Pricing_SendAdvanceApprovalEmail.sendNotification(approveApprovalIds, Label.AA_OrgWideEmailAddress, 'Pricing_SW_QuoteApprovedNotification');
            }

            if (!rejectApprovalIds.isEmpty()) {
                Pricing_SendAdvanceApprovalEmail.sendNotification(rejectApprovalIds, Label.AA_OrgWideEmailAddress, 'Pricing_SW_QuoteRejectedNotification');
            }
        }
    }