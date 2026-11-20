/**
 * @description       : Controller class for Bulk Actions-Approve/Reject/Customer Revision for FSE/SDM
 * @author            : Subhanku
 * @group             : Accenture
 * @last modified on  : 04-10-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Pricing_BulkSalesRepActionController {

    /**
    * @description method will return Quote Lines with Approve Reject Access
    * @author Accenture  
    * @return List < SBQQ__QuoteLine__c > 
    **/	
    @AuraEnabled
    public static List < SBQQ__QuoteLine__c > getQuoteLineDetails(Id quoteId) {
        List < SBQQ__QuoteLine__c > quoteLineList = [SELECT Id, Pricing_Quote_Line_Number__c, Pricing_Sales_Rep__c, Pricing_Product_Nm__r.Id, Pricing_Product_Nm__r.Name, Pricing_Status_Nm__c,Pricing_Market_Segment_values_Nm__c,Pricing_SIPP_Cb__c,
            Pricing_FSE_Recommended_Price_Nm__c, Pricing_pm_approval_comments_nm__c, Pricing_Rejection_Comments_nm__c, SBQQ__Quote__c,Pricing_Rejection_Reason__c,SBQQ__Quote__r.Id,SBQQ__Quote__r.SBQQ__PrimaryContact__r.Id,Pricing_Last_Submitted_By_Id__c,SBQQ__Quote__r.SBQQ__SalesRep__c,
            Pricing_Change_Request_cb__c,Pricing_Form_Factor_Nm__c,Pricing_Sales_Rep_Approver__c,Customer_Revision_Count_Cnt__c,Pricing_Other_Product_Nm__c, Pricing_New_Quantity_qty__c, Pricing_Request_Discount_Unit_Price_qty__c, Pricing_Req_Discounted_Unit_Price__c, Pricing_Unit_Qty__c,Pricing_Total_Volume_Qty__c,Pricing_Program_Type_Nm__c,Pricing_SDM_Fast_Track__c,Pricing_Start_Date_dt__c,SBQQ__Quote__r.Pricing_Program_Type_Nm__c,Pricing_Workload_Nm__c,Pricing_New_Change_Request_cb__c FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__c =: quoteId ORDER By Pricing_Quote_Line_Number__c];

        List<Pricing_Quote_Team__c> quoteTeamList = [select id from Pricing_Quote_Team__c where Pricing_Quote_Id__c =: quoteId AND Pricing_Quote_Team_Member_Id__r.IsActive = true AND Pricing_Role_Nm__c = 'FSE/SDM' AND Pricing_Quote_Team_Member_Id__c =: UserInfo.getuserId()];

        List < SBQQ__QuoteLine__c > quoteListWithAppRejAccess = new List < SBQQ__QuoteLine__c > ();
        List < User > delegateApprovers = new List < User > ();
        List < Id > delegateApproverIds = new List < Id > ();
        Map < Id, Id > quoteLineSalesRepMap = new Map < Id, Id > ();
        Id userId = UserInfo.getUserId();
        Set < Id > multipleFSEUserIdSet = new Set < Id > ();

        for (SBQQ__QuoteLine__c ql: quoteLineList) {
            quoteLineSalesRepMap.put(ql.Id, ql.Pricing_Sales_Rep__c);
        }

        delegateApprovers = [SELECT DelegatedApproverId from User where id IN: quoteLineSalesRepMap.values()];   
        for(User u : delegateApprovers){
            delegateApproverIds.add(u.DelegatedApproverId);
        }    

        for (ProcessInstanceWorkitem workItem: [SELECT p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.OriginalActorId, p.Id
                FROM ProcessInstanceWorkitem p
                WHERE p.ProcessInstance.TargetObjectId IN: quoteLineSalesRepMap.keySet()
                AND ProcessInstance.Status = 'Pending'
            ]) {
            multipleFSEUserIdSet.add(workItem.OriginalActorId);
        }

        if (userHasValidPermissionSet(new Set < String > {
                Label.Pricing_Tender_PermissionSets_TenderUser
            })) {
            for (SBQQ__QuoteLine__c ql: quoteLineList) {
                if (delegateApproverIds.contains(userId) || ((ql.Pricing_Sales_Rep__c == userId ||  multipleFSEUserIdSet.contains(userId) ) || quoteTeamList.size() > 0 )) {
                    quoteListWithAppRejAccess.add(ql);                        
                }
            }                
        }
        return quoteListWithAppRejAccess;
    }

    /**
    * @description method will save Quote Line record and update Status, Rejection reason and Comments 
    * @author Accenture  
    * @return String 
    **/	
    @AuraEnabled
    public static String recordApproval(List < SBQQ__QuoteLine__c > quoteLineData, String action, String revisionComments, Boolean isChatterTrue) {
        String msg = 'Success';
        String quoteLineNumbers = '';
        Set<Id> qliIds = new Set<Id>();
        Set<id> lastSubmitterIds = new Set<Id>();
        Map<Id, String> qliIdtoCommentMap = new Map<Id, String>();

        try {
            for (SBQQ__QuoteLine__c qli: quoteLineData) {
                qliIds.add(qli.id);

                if(action == Label.Pricing_Tender_QuoteLine_Status_Approved){
                    qli.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
                    qli.Pricing_Sales_Rep_Approver__c = QuoteLineBusinessLogic.isAutoApproveReject ? qli.SBQQ__Quote__r.SBQQ__SalesRep__c : UserInfo.getUserId();
                    qli.Pricing_Rejection_Reason__c = '';
                    qliIdtoCommentMap.put(qli.Id, qli.Pricing_pm_approval_comments_nm__c);

                }else if(action == Label.Pricing_Tender_QuoteLine_Status_Rejected){
                    qli.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Rejected;
                    qli.Pricing_Sales_Rep_Approver__c = QuoteLineBusinessLogic.isAutoApproveReject ? qli.SBQQ__Quote__r.SBQQ__SalesRep__c : UserInfo.getUserId();
                    qli.Pricing_Change_Request_cb__c = false;
                    qli.Pricing_FSE_Recommended_Price_Nm__c = '';
                    qli.Pricing_SDM_Fast_Track__c = false;
                    qli.Pricing_pm_approval_comments_nm__c  = '';
                    qli.Pricing_Rejection_Reason__c = QuoteLineBusinessLogic.isAutoApproveReject ? Label.Pricing_rejection_reason_other_value : qli.Pricing_Rejection_Reason__c;
                    qli.Pricing_Rejection_Comments_nm__c = QuoteLineBusinessLogic.isAutoApproveReject ? 'Auto Reject by FSE.' : qli.Pricing_Rejection_Comments_nm__c;
                    qliIdtoCommentMap.put(qli.Id, qli.Pricing_Rejection_Comments_nm__c);

                }else if(action == Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM || action == Label.Pricing_Tender_QuoteLine_Action_Rollback){
                    QuoteLineBusinessLogic.isOEMRecall = true;
                    qli.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Draft;
                    qli.Pricing_Ready_for_Review_cb__c = true;
                    qli.Customer_Revision_Count_Cnt__c = (qli.Customer_Revision_Count_Cnt__c == null) ? 1 : (++qli.Customer_Revision_Count_Cnt__c);

                    lastSubmitterIds.add(qli.Pricing_Last_Submitted_By_Id__c);
                    quoteLineNumbers += qli.Pricing_Quote_Line_Number__c + ', ';
                }
            }
            if (!quoteLineData.isEmpty()) {
                if(action != Label.Pricing_Tender_QuoteLine_Action_Rollback){
                    Pricing_Tender_Utility.createUsageTrackingLog(qliIds,quoteLineData[0].SBQQ__Quote__c,action);
                }
                if(TriggerHandler.isActive('Pricing_OEM_Revert_Switch')) {
                    SBQQ.TriggerControl.disable();
                	update quoteLineData;
                	SBQQ.TriggerControl.enable();
                }
                else {
                    update quoteLineData;
                }
            }

            if(action == Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM){
                Pricing_Publish_Quote.setFSEActionOnQuoteLine(qliIds,'Reject',null,false);
                chatterPostCreation(revisionComments, quoteLineData[0], quoteLineNumbers, isChatterTrue, lastSubmitterIds);
            }
            if(action == Label.Pricing_Tender_QuoteLine_Action_Rollback){
                Pricing_Publish_Quote.setFSEActionOnQuoteLine(qliIds,'Reject',null,false);
            }
            else{
                String approvalAction = action == Label.Pricing_Tender_QuoteLine_Status_Approved ? Label.Pricing_Tender_QuoteLine_Action_Approve : Label.Pricing_Tender_QuoteLine_Action_Reject;
                Pricing_Publish_Quote.setFSEActionOnQuoteLine(qliIdtoCommentMap, approvalAction);
            }
        } catch (Exception e) {
            msg = e.getMessage();
            Pricing_Tender_Utility.logError(e);
        } finally {
            SBQQ.TriggerControl.enable();
        }
        return msg;
    }

    /**
    * @description method will check if user has valid permission set or not
    * @author Accenture  
    * @return Boolean 
    **/	
    private static Boolean userHasValidPermissionSet(Set < string > permissionSets) {
        integer count = [SELECT count() FROM PermissionSetAssignment
                         WHERE AssigneeId = : Userinfo.getUserId() AND PermissionSet.Name IN: permissionSets
                        ];
        return count > 0;
    }

    /**
    * @description Method to post chatter for Bulk Customer Revision
    * @author Sandeep | 02-22-2023 
    * @param revisionComment - comments entered by user
    * @param quoteline - first quoteline from list to get primary contact
    * @param quoteLineNumbers - String containing all quoteline numbers for which customer revision is done
    * @param isChatterTrue - post to chatter oolean
    **/
    public static void chatterPostCreation(String revisionComment, SBQQ__QuoteLine__c quoteline, String quoteLineNumbers, Boolean isChatterTrue, Set<Id> submitterIds) {
        if(isChatterTrue){
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

            ConnectApi.MentionSegmentInput mentionSegmentInput;
            List<User> primaryContact = [Select Id, ContactId from User where ContactId = :quoteline.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Id];

            submitterIds.add(primaryContact[0].Id);

            if(submitterIds.size() > 0){
                for(Id submitterId: submitterIds){
                    mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                    mentionSegmentInput.id = submitterId;
                    messageBodyInput.messageSegments.add(mentionSegmentInput);
                    textSegmentInput = new ConnectApi.TextSegmentInput(); 
                    textSegmentInput.text = '  ';
                    messageBodyInput.messageSegments.add(textSegmentInput);
                }
            }
            
            feedItemInput.visibility = ConnectApi.FeedItemVisibilityType.AllUsers;
        
            ConnectApi.EntityLinkSegmentInput entityLinkSegmentInputOpportunity = new ConnectApi.EntityLinkSegmentInput();
            entityLinkSegmentInputOpportunity.entityId = quoteline.SBQQ__Quote__r.Id;  
            messageBodyInput.messageSegments.add(entityLinkSegmentInputOpportunity);
            
            textSegmentInput = new ConnectApi.TextSegmentInput(); 
            textSegmentInput.text = '\nQuote Line Number(s): '+quoteLineNumbers.removeEnd(', ');
            messageBodyInput.messageSegments.add(textSegmentInput);

            // post body
            textSegmentInput = new ConnectApi.TextSegmentInput();
            String postBody = revisionComment;
            textSegmentInput.text = '\n'+postBody.stripHtmlTags();
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = quoteline.SBQQ__Quote__r.Id;
            //post the chatter
            if(!Test.isRunningTest()){
                ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
            }
        }
    }

    /**
    * @description method to get all Field Review Quotelines for OEM Recall on Quote level
    * @author Sandeep | 05-11-2023 
    * @param quoteId - Id of Quote Record
    * @return String - success/error message
    **/
    @AuraEnabled
    public static String getQuoteLinetoRollback(Id quoteId){
        List < SBQQ__QuoteLine__c > quoteLineList = [SELECT Id, Pricing_Quote_Line_Number__c, Pricing_Sales_Rep__c, Pricing_Product_Nm__r.Id, Pricing_Product_Nm__r.Name, Pricing_Status_Nm__c,
            Pricing_FSE_Recommended_Price_Nm__c, Pricing_pm_approval_comments_nm__c, Pricing_Rejection_Comments_nm__c, SBQQ__Quote__c,Pricing_Rejection_Reason__c,SBQQ__Quote__r.Id,SBQQ__Quote__r.SBQQ__PrimaryContact__r.Id,Pricing_Last_Submitted_By_Id__c,
            Pricing_Change_Request_cb__c,Pricing_Sales_Rep_Approver__c,Customer_Revision_Count_Cnt__c,Pricing_Other_Product_Nm__c,Pricing_SDM_Fast_Track__c FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__c =: quoteId AND Pricing_Status_Nm__c =: Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview AND Pricing_Reference_Quote_Line_Nbr__c = null
            ORDER By Pricing_Quote_Line_Number__c
            ];
        if(quoteLineList.size() > 0){
            String msg = recordApproval(quoteLineList, Label.Pricing_Tender_QuoteLine_Action_Rollback, null, false);
            return msg;
        }
        else{
            return 'Error';
        }
    }

    /**
    * @description method will return FI QuoteLine Records for FI RPM Bulk Approve Reject.
    * @author Accenture  
    * @return List<SBQQ__QuoteLine__c> 
    **/	
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> getFIQuoteLineToApproveReject(String recordId){
        try {
            String recId = String.escapeSingleQuotes(recordId);
            String getQuoteLinesQuery;
            getQuoteLinesQuery = 'SELECT Id,Pricing_Quote_Line_Number__c,Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Approved_Unit_Qty__c,Pricing_Product_VerticalSegment__c,Pricing_Other_Product_Nm__c,';
            getQuoteLinesQuery += 'Pricing_FI_Net_RPU_Amt__c,Pricing_Total_Volume_Qty__c,Pricing_Additional_T_C_s_Txt__c,Pricing_Additional_Comments_Txt__c,Pricing_Status_Nm__c,Pricing_Product_Nm__r.Name,Pricing_Other_Competitor_Product_Nm__c,';
            getQuoteLinesQuery += 'SBQQ__Quote__r.Pricing_FI_Partner_Type__c,Pricing_SIPP_Cb__c,Pricing_Competetor_Product__r.Name,Pricing_Rejection_Reason__c,Pricing_Manager__r.Name, Pricing_pm_approval_comments_nm__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :recId ORDER By Pricing_Quote_Line_Number__c';
            return Database.query(getQuoteLinesQuery);
        } catch (Exception e) {
            Pricing_Tender_Utility.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description method will return FI RPM User.  
    * @author Accenture  
    * @return List<PermissionSetAssignment> 
    **/	
    @AuraEnabled
    public static List<PermissionSetAssignment> getFIPricingManagerSearch(String searchKey){
        try {
            //This method is called by LWC to find the user from searchkey
            String searchText = String.escapeSingleQuotes(searchKey) + '%';               
            String query =  'SELECT Id, Name, Email, Isactive, IsPortalEnabled FROM User WHERE IsPortalEnabled = false AND ContactId = null AND Isactive = true AND Name LIKE :searchText LIMIT 5';
            return Database.query(query); 
        } catch (Exception e) {
            Pricing_Tender_Utility.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description method will save FI Quote Line record and update Status, Comments 
    * @author Accenture  
    * @return String 
    **/	
    @AuraEnabled
    public static String bulkApprovalRejectionQuoteLineRPM(List < SBQQ__QuoteLine__c > quoteLineData, String action, String quoteType) {
        String msg = 'Success';
        try {
            if(quoteLineData.size() > 0){                
                SBQQ.TriggerControl.disable();
                update quoteLineData;
                SBQQ.TriggerControl.enable();
                List<Id> updatedQLListId = new List<Id>();
                if(quoteType == Label.Pricing_Tender_FinancialIncentive_Quote){
                    for(SBQQ__QuoteLine__c ql : quoteLineData){
                        updatedQLListId.add(ql.Id);
                    }
                    Pricing_FinancialIncentive_BusinessLogic.populateQLNumberOnOppLineItemBulk(updatedQLListId,action);
                }
            }            
        }
        catch (Exception e) {
            msg = e.getMessage();
            Pricing_Tender_Utility.logError(e);
        } finally {
            SBQQ.TriggerControl.enable();
        }
        return msg;
    }

    /**
    * @description method will return QuoteLine Records for RPM Bulk Reject.
    * @author Accenture  
    * @return List<SBQQ__QuoteLine__c> 
    **/	
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> getQuoteLineToRejectByRPM(String recordId){
        try {
            String recId = String.escapeSingleQuotes(recordId);
            String getQuoteLinesQuery;
            String statusPFIRCheck = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
            getQuoteLinesQuery = 'SELECT Id,Pricing_Quote_Line_Number__c,Pricing_Other_Product_Nm__c,Pricing_Status_Nm__c,Pricing_Product_Nm__r.Name,Pricing_Integration_Status_Nm__c,';
            getQuoteLinesQuery += 'Pricing_Rejection_Reason__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :recId AND  Pricing_Status_Nm__c = :statusPFIRCheck AND (Pricing_Integration_Status_Nm__c = null OR Pricing_Integration_Status_Nm__c = \'\') ORDER By Pricing_Quote_Line_Number__c';
            return Database.query(getQuoteLinesQuery);
        }catch (Exception e) {
            Pricing_Tender_Utility.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
}