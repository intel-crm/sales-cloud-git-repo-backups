/*-------------------------------------------------------------------------------------------
Apex Class  : Pricing_QuoteLineController_Mock
Version     : 1.0 
Created Date: 08 Jun 2022
Function    : Dummy Apex class for Quote Line Aura component to implement Apex Mock
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Accenture        		  08 Jun 2022              Dummy Version
-------------------------------------------------------------------------------------------*/
public without sharing class Pricing_QuoteLineController_Mock extends TriggerHandler{
    public static Integer retryCounter = 0;
    @AuraEnabled
    public static List < SBQQ__QuoteLine__c > getQuoteLines(Id recordId) {
        return Pricing_QuoteLines_Selector.newInstance().selectByIdAndStatus(recordId,Label.Pricing_Tender_QuoteLine_Status_Revised);
    }
    
    @AuraEnabled
    public static List < SBQQ__Quote__c > getQuote(Id recordId) {
        return Pricing_Quote_Selector.newInstance().selectByIds(new Set<Id>{recordId});
    }
    
    @AuraEnabled
    public static Boolean isCreateable() {
        return Schema.sObjectType.SBQQ__QuoteLine__c.isCreateable();
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean isOEMField() {
        return Pricing_PermissionSetAssignment_Selector.newInstance().selectByName(Userinfo.getUserId(),new Set<String>{Label.Pricing_Tender_PermissionSets_TenderUser});
    }
    
    @AuraEnabled
    public static SBQQ__QuoteLine__c getQuoteLine(Id quoteLineId) {
        return Pricing_QuoteLines_Selector.newInstance().selectByQuoteLineIds(new Set<Id>{quoteLineId})[0];
    }

    @AuraEnabled
    public static String getProductName(Id quoteLineId) {
        String productName;
        SBQQ__QuoteLine__c qlRec = getQuoteLine(quoteLineId);
        if(qlRec.Pricing_Product_Nm__r.Name != 'Write In Product'){
            productName = qlRec.Pricing_Product_Nm__r.Name;
        }
        else
        {
            productName = qlRec.Pricing_Other_Product_Nm__c;
        }
        return productName;
    }
    
    @AuraEnabled
    public static List < string > getAvailableUserActions(Id quoteLineId) {
        SBQQ__QuoteLine__c quoteLine = Pricing_QuoteLines_Selector.newInstance().selectByQuoteLineIds(new Set<Id>{quoteLineId})[0];        
        List<User> delegateApprovers = new List<User>();
        delegateApprovers = Pricing_User_Selector.newInstance().selectbyUserId(quoteLine.Pricing_Sales_Rep__c);
        Id delegateApprover = delegateApprovers.size() > 0 ? delegateApprovers[0].DelegatedApproverId : null;
        
        List < string > actions = new List < string > ();
        // VARIABLE USED TO GET USER ID
        Id userId = UserInfo.getUserId();
        // If user has create access he can clone always
        if(isCreateable()) {
            Set < String > allPersona = getPersonaExcludingSet(new Set < String > ());
            if(userHasValidPermissionSet(allPersona)) {
                actions.add('Clone');
            }
        }
        Set < String > allPersona = getPersonaExcludingSet(new Set < String > ());
        Set < String > isRPMPersona = new Set < String > ();

        isRPMPersona.add(Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager);
        Map<Id, Boolean> qLIdintRejectionAllowedMap = isIntegartionRejectionAllowed(new Set<Id>{quoteLine.Id}); 

        switch on quoteLine.Pricing_Status_Nm__c {
            when 'Draft' {
                getAvailableUserActionsDraft(actions, quoteLine, userId, allPersona);
            }
            when 'Pending Intel Field Review' {
                getAvailableUserActionsPIFR(actions, quoteLine, userId, delegateApprover);
            }
            when 'Pending Further Intel Review' {
                getAvailableUserActionsPFIR(actions, quoteLine, qLIdintRejectionAllowedMap);
            }
            when 'Approved' {  
                getAvailableUserActionsApproved(actions, quoteLine, isRPMPersona, allPersona);
            }
            when 'Lost' {
                getAvailableUserActionsLost(actions);
            }
            when 'Won' {
                getAvailableUserActionsWon(actions, quoteLine);
            }
        }
        return actions;
    }

    public static void getAvailableUserActionsDraft(List < string > actions, SBQQ__QuoteLine__c quoteLine, Id userId,Set < String > allPersona){
        Set < String > allPersonaExceptRPM = getPersonaExcludingSet(new Set < String > {
            Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager,
                Label.Pricing_Tender_PermissionSets_TenderAccountExecutive, Label.Pricing_Tender_Permission_Set_IT_Specialist
                });
        if(userHasValidPermissionSet(allPersona)) {
            actions.add(Label.Pricing_Tender_QuoteLine_Action_Edit);
            if(quoteLine.CreatedById == userId || quoteLine.Pricing_Primary_Contact_Nm__c == userId || quoteLine.SBQQ__Quote__r.OwnerId == userId || userHasValidPermissionSet(new Set < String > {
                Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator
                    })) {
                        actions.add(Label.Pricing_Tender_QuoteLine_Action_Delete);
                    }
        }
        if(userHasValidPermissionSet(allPersonaExceptRPM) && quoteLine.SBQQ__Quote__r.SBQQ__Status__c != 'Draft') {
            actions.add(Label.Pricing_Tender_QuoteLine_Action_Submit_For_Approval);
        }
    }

    public static void getAvailableUserActionsPIFR(List < string > actions, SBQQ__QuoteLine__c quoteLine,Id userId,Id delegateApprover){
        Set<Id> multipleFSEUserIdSet = new Set<Id>();
        for(ProcessInstanceWorkitem workItem : Pricing_ProcessInstanceWorkitem_Selector.newInstance().selectbyQliIdandStatus(quoteLine.id,'Pending')){
                                                    multipleFSEUserIdSet.add(workItem.OriginalActorId);
                                            }
        if(userHasValidPermissionSet(new Set < String > {
            Label.Pricing_Tender_PermissionSets_TenderUser}))
        {
            if(quoteLine.Pricing_Sales_Rep__c == userId || delegateApprover == userId || multipleFSEUserIdSet.contains(userId)) {
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Edit);
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Approve);
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Reject);
                if(!quoteLine.Pricing_Change_Request_cb__c) {
                    actions.add(Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM);
                }
            }
        }
    }

    public static void getAvailableUserActionsPFIR(List < string > actions, SBQQ__QuoteLine__c quoteLine,Map<Id, Boolean> qLIdintRejectionAllowedMap){
        Set<String> exceptionQuoteTypeSet = new Set<String>(Label.Pricing_Tender_ExceptionQuoteType.split(','));
        Boolean isDPGQuoteLine = false;
        if(exceptionQuoteTypeSet.contains(quoteLine.Pricing_Program_Type_Nm__c)) {
            isDPGQuoteLine = true;
        }
        if(userHasValidPermissionSet(new Set < String > {Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager})){
            //No Actions are Available for Integration Status "Pending","InProcess" and Deal Status "Submitted"
            if(quoteLine.Pricing_Integration_Status_Nm__c != Label.Pricing_Tender_MyDeal_Integration_Status_Pending && quoteLine.Pricing_Integration_Status_Nm__c !=  Label.Pricing_Tender_MyDeal_Integration_Status_InProcess &&
            quoteLine.Pricing_Deal_RFQ_Status_Nm__c != Label.Pricing_Tender_MyDeal_RFQ_Status_Submitted){
                //Avaiable for All Scenarios
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Edit);
		        //actions.add(Label.Pricing_Tender_Action_RPM_Edit);
                //Recision Actions Available only for Non-Change Request Non Integration QuoteLines
                if(quoteLine.Pricing_Integration_Status_Nm__c == null){
                    actions.add(Label.Pricing_Tender_QuoteLine_Action_Reject);
                    if(!quoteLine.Pricing_Change_Request_cb__c){
                        actions.add(Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM);
                        actions.add(Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyField);
                    }
                    
                    if(quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product){
                       /* if(!(String.isNotBlank(quoteLine.Pricing_Deal_RFQ_Id__c))){
                            actions.add(Label.Pricing_GetAI_Button_Label);
                        }*/
                        if(quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null){
                            actions.add(Label.Pricing_Update_Deal_MD_button_label);
                        }
                        else{
                            actions.add(Label.Pricing_Send_Request_MD_Button_Label);
                        }
                    }else{
                        actions.add(Label.Pricing_Tender_QuoteLine_Action_Approve);
                    }

                    if(!isDPGQuoteLine && (!(String.isNotBlank(quoteLine.Pricing_Deal_RFQ_Id__c)))){
                        actions.add(Label.Pricing_GetAI_Button_Label);
                    }

                }
                if(quoteLine.Pricing_Integration_Status_Nm__c == Label.Pricing_Tender_MyDeal_Integration_Status_Error 
                    && ((String.isBlank(quoteLine.Pricing_Deal_RFQ_Id__c) && String.isBlank(quoteLine.Pricing_Deal_RFQ_Status_Nm__c))|| (String.isBlank(quoteLine.Pricing_Deal_RFQ_Status_Nm__c) && quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null))){
                                actions.add(Label.Pricing_Tender_QuoteLine_Action_Reject);
                                if(quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product){
                                    if(quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null){
                                        actions.add(Label.Pricing_Update_Deal_MD_button_label);
                                    }else{
                                        actions.add(Label.Pricing_Send_Request_MD_Button_Label);
                                    }
                                }
                                if(!isDPGQuoteLine && quoteLine.Pricing_Reference_Quote_Line_Nbr__c == null){
                                    actions.add(Label.Pricing_GetAI_Button_Label);
                                }
                            }
                if(quoteLine.Pricing_Deal_RFQ_Status_Nm__c == Label.Pricing_Tender_MyDeal_RFQ_Status_Requested && String.isNotBlank(quoteLine.Pricing_Deal_RFQ_Id__c)){
                    if(quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product){
                        actions.add(Label.Pricing_Update_Deal_MD_button_label);
                    }
                    if(!isDPGQuoteLine && quoteLine.Pricing_Reference_Quote_Line_Nbr__c == null)
                    actions.add(Label.Pricing_GetAI_Button_Label);
                }
            }
            if(qLIdintRejectionAllowedMap.get(quoteLine.Id)) {
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Reject);
            }
        }
    }

    public static void getAvailableUserActionsApproved(List < string > actions, SBQQ__QuoteLine__c quoteLine,Set < String > isRPMPersona,Set < String > allPersona){
        Boolean allowOnlyForRPM = allowWonLostForRPM(quoteLine);
        if(allowOnlyForRPM){
            if(userHasValidPermissionSet(isRPMPersona)){           //Restrict Won/Loss to RPM for 16 identified Accounts
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Won);
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Lost);
            }
        }else{
            if(userHasValidPermissionSet(allPersona) || userHasValidPermissionSet(new set<String>{Label.Pricing_Tender_PermissionSets_TenderRebateAnalyst})) {
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Won);
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Lost);
            }
        }
        Set < String > extPersona = new Set < String > {Label.Pricing_Tender_PermissionSets_TenderPartner};
        extPersona.add(Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator);
        extPersona.add(Label.Pricing_Tender_PermissionSets_TenderDrafter); 
        //extPersona.add(Label.Pricing_Tender_PermissionSets_TenderDrafterLimited);
        if(userHasValidPermissionSet(extPersona)) {
            if(quoteLine.Pricing_Approved_End_Date_Dt__c == null || quoteLine.Pricing_Approved_End_Date_Dt__c > (System.today() - 91)){
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Request_Change);
            }
        }
        if(userHasValidPermissionSet(new Set < String > {
            Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager}))  {
            actions.add(Label.Pricing_Tender_Cancel_Action);
            //added By ANushaM for US835690
            if(quoteLine.Pricing_Approved_End_Date_Dt__c == null || quoteLine.Pricing_Approved_End_Date_Dt__c > (System.today() - 91)){
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Request_Change);
            }
        }
    }

    public static void getAvailableUserActionsLost(List < string > actions){
        if(userHasValidPermissionSet(new Set < String > {
            Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager}))  {
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Approve);
            }
    }

    public static void getAvailableUserActionsWon(List < string > actions, SBQQ__QuoteLine__c quoteLine){
        Set < String > extPersona = new Set < String > { Label.Pricing_Tender_PermissionSets_TenderPartner };
        extPersona.add(Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator);
        extPersona.add(Label.Pricing_Tender_PermissionSets_TenderDrafter);
        //extPersona.add(Label.Pricing_Tender_PermissionSets_TenderDrafterLimited);
        
        if(userHasValidPermissionSet(extPersona)) {
            if(quoteLine.Pricing_Approved_End_Date_Dt__c == null || quoteLine.Pricing_Approved_End_Date_Dt__c > (System.today() - 91)){
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Request_Change);
            }
        }
        if(userHasValidPermissionSet(new Set < String > {
            Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager}))  {
            actions.add(Label.Pricing_Tender_Cancel_Action);
            //added By ANushaM for US835690
            if(quoteLine.Pricing_Approved_End_Date_Dt__c == null || quoteLine.Pricing_Approved_End_Date_Dt__c > (System.today() - 91)){
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Request_Change);
            }
        }
    }
    
    @AuraEnabled
    public static void deleteRecord(Id quoteLineId) {
        if(quoteLineId != null){
            SBQQ__QuoteLine__c quoteLine = Pricing_QuoteLines_Selector.newInstance().selectByQuoteLineIds(new Set<Id>{quoteLineId})[0];
            List<Pricing_Quote_Line_Status_Age__c> deleteTPTList = new List<Pricing_Quote_Line_Status_Age__c>();
            deleteTPTList = Pricing_Quote_Line_Status_Age_Selector.newInstance().selectbyQliId(quoteLineId);
            if(quoteLine != null) {
                Pricing_QuoteLines_DML.deleteQLI(new List<SBQQ__QuoteLine__c>{quoteLine});            
            }
            if(!deleteTPTList.isEmpty()){
                Pricing_Quote_Line_Status_Age_DML.deleteTPT(deleteTPTList);
            }
        }
    }
    @AuraEnabled
    public static String cancelRecord(Id quoteLineId) {
        String retMsg = null;
        try{
            SBQQ__QuoteLine__c quoteLine = Pricing_QuoteLines_Selector.newInstance().selectByQuoteLineIds(new Set<Id>{quoteLineId})[0];
            if(quoteLine != null) {
                quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Cancelled;
                SBQQ.TriggerControl.disable();
                Pricing_QuoteLines_DML.updateQLI(new List<SBQQ__QuoteLine__c>{quoteLine});
                SBQQ.TriggerControl.enable();
            }
        }
        catch(Exception e){
            retMsg = Pricing_Tender_Utility.getExceptionMessage(e);
            Pricing_Tender_Utility.logError(e);        
        }
        return retMsg;
    }
    private static Set < String > getPersonaExcludingSet(Set < String > excludePermission) {
        Set < String > ps = new Set < String > ();
        ps.add(Label.Pricing_Tender_PermissionSets_TenderUser);
        ps.add(Label.Pricing_Tender_PermissionSets_TenderPartner);
        ps.add(Label.Pricing_Tender_PermissionSets_TenderDrafter);
        ps.add(Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager);
        ps.add(Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator);
        ps.add(Label.Pricing_Tender_PermissionSets_TenderAccountExecutive);
        ps.add(Label.Pricing_Tender_Permission_Set_IT_Specialist);
        ps.add(Label.Pricing_Tender_PermissionSets_TenderDrafterLimited);
        ps.removeAll(excludePermission);
        return ps;
    }
    
    private static Boolean userHasValidPermissionSet(Set < string > permissionSets) {
        return Pricing_PermissionSetAssignment_Selector.newInstance().selectByName(Userinfo.getUserId(),permissionSets);
    }
    
    //Method to check if Won/Loss has to be aloowed only for RPM
    public static Boolean allowWonLostForRPM(SBQQ__QuoteLine__c quoteLine){
        Boolean allowOnlyFoRPM = false;
        integer count = Pricing_QLIWonLossRestriction_Selector.newInstance().selectByAccountIds(quoteLine.SBQQ__Quote__r.SBQQ__Account__c);
        if(count > 0){
            allowOnlyFoRPM = true;
        }else{
            allowOnlyFoRPM = false;
        }       
        return allowOnlyFoRPM;
    }
    
    @AuraEnabled
    public static boolean isPartnerUser() {
        Set < String > extPersona = new Set < String > {Label.Pricing_Tender_PermissionSets_TenderPartner};
            extPersona.add(Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator);
        	extPersona.add(Label.Pricing_Tender_PermissionSets_TenderDrafter);
        	extPersona.add(Label.Pricing_Tender_PermissionSets_TenderDrafterLimited); 
        return userHasValidPermissionSet(extPersona);
    }
    
    @AuraEnabled
    public static String recordApproval(Id quoteLineId, string comments, string status, SBQQ__QuoteLine__c lineItem, String revisionComment, Boolean showRevisionFields){
        String retMsg = null;
        try {
        String currentAction = status;
        Boolean isFieldReviewQL = false;
        SBQQ__QuoteLine__c quoteLine = Pricing_QuoteLines_Selector.newInstance().selectByQuoteLineIds(new Set<Id>{quoteLineId})[0]; 
        Map < string, string > statusMapping = new Map < string, string > ();
        statusMapping.put(Label.Pricing_Tender_QuoteLine_Action_Approve, Label.Pricing_Tender_QuoteLine_Status_Approved);
        statusMapping.put(Label.Pricing_Tender_QuoteLine_Action_Reject, Label.Pricing_Tender_QuoteLine_Status_Rejected);
        statusMapping.put(Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyField, Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview);
        statusMapping.put(Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM, Label.Pricing_Tender_QuoteLine_Status_Draft);
        Map<Id,Set<Id>> quoteQTMMap = new Map<Id,Set<Id>>();
        if(quoteLine != null) {
            String approvalAction = null;
            List < SBQQ__QuoteLine__c > quoteLineList = new List < SBQQ__QuoteLine__c > ();
            if(isOEMField() && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview) {
                recordApprovalPIFR(quoteLine, approvalAction, showRevisionFields, quoteLineList, status, lineItem, comments, statusMapping,revisionComment);
            }
            else if(isOEMField() && quoteLine.Pricing_Status_Nm__c != Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview){
                return 'QuoteLine already Approved.';
            }
            else{
                quoteLineList.add(quoteLine);
                //Set the PM Approval Comments when RPM is performing Actions
                isFieldReviewQL = recordApprovalStatusCheckAgainstPIFR(quoteLine, showRevisionFields, quoteLineList, status, comments,revisionComment,quoteQTMMap,retMsg);
                recordApprovalChangeReq(quoteLine, quoteLineList, status, statusMapping);
            }
            if(!quoteLineList.isEmpty()) {
                SBQQ.TriggerControl.disable();
                Pricing_QuoteLines_DML.updateQLI(quoteLineList);
                SBQQ.TriggerControl.enable();
            }
             //Create Approval records for only valid FSE on field revision
            if(isFieldReviewQL){
                Pricing_Publish_Quote.publishQuoteLinesToMultipleFSE(new Set<Id>{quoteLine.Id});
            }
        }
             system.debug('retMsg==>'+retMsg);
        }
        catch(Exception e){
            retryCounter++;
            if(retryCounter<=Integer.valueOf(Label.Pricing_Retry_Record_Approval_Counter_Label)){
                retMsg = recordApprovalRetry(quoteLineId,comments,status, lineItem,  revisionComment,  showRevisionFields);
                //Pricing_Tender_Utility.logError(e);
            }else {
                retMsg = Pricing_Tender_Utility.getExceptionMessage(e);
            	system.debug('retMsg==>'+retMsg); 
                Pricing_Tender_Utility.logError(e); 
            }   
        }
        finally {
            SBQQ.TriggerControl.enable();
        }
        return retMsg;
    }

    public static String recordApprovalRetry(Id quoteLineId, string comments, string status, SBQQ__QuoteLine__c lineItem, String revisionComment, Boolean showRevisionFields){
        return recordApproval(quoteLineId,comments,status, lineItem,  revisionComment,  showRevisionFields);
    }

    public static void recordApprovalPIFR(SBQQ__QuoteLine__c quoteLine, String approvalAction,Boolean showRevisionFields,List < SBQQ__QuoteLine__c > quoteLineList, String status,SBQQ__QuoteLine__c lineItem,string comments,Map < string, string > statusMapping,String revisionComment){
        if(status != Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM){
            quoteLine.Pricing_FSE_Recommended_Price_Nm__c = lineItem.Pricing_FSE_Recommended_Price_Nm__c;
            quoteLine.Pricing_Sales_Rep_Approver__c = UserInfo.getUserId();
            quoteLine.Pricing_pm_approval_comments_nm__c = comments == '' ? quoteLine.Pricing_pm_approval_comments_nm__c : comments;
            SBQQ.TriggerControl.disable();
            Pricing_QuoteLines_DML.updateQLI(new List<SBQQ__QuoteLine__c>{quoteLine});
            SBQQ.TriggerControl.enable();
        }

        // Revision required by OEM Reject the Approval Process and set the Status to Draft
        if(status == Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM) {
            //req.setAction(Label.Pricing_Tender_QuoteLine_Action_Reject);
            approvalAction = Label.Pricing_Tender_QuoteLine_Action_Reject;
            quoteLine.Pricing_Status_Nm__c = statusMapping.get(status);
            quoteLine.Pricing_Ready_for_Review_cb__c = true;
            //TPT
            quoteLine.Customer_Revision_Count_Cnt__c = (quoteLine.Customer_Revision_Count_Cnt__c == null) ? 1 :quoteLine.Customer_Revision_Count_Cnt__c + 1;
            //TPT
            quoteLineList.add(quoteLine);
                chatterPostCreation(revisionComment, quoteLine, false, showRevisionFields);
        } else if(status == Label.Pricing_Tender_QuoteLine_Action_Reject) {
            //If Rejected then Reject the Approval Process and set the status to Rejected
            //req.setAction(status);
            approvalAction = Label.Pricing_Tender_QuoteLine_Action_Reject;
            quoteLine.Pricing_Status_Nm__c = statusMapping.get(status);
            quoteLine.Pricing_Change_Request_cb__c = false;
            quoteLineList.add(quoteLine); 
        } else {
            //If Approved then Approve the Approval Process(Approval Process automatically sets the status to Approved)
            //req.setAction(status);
            approvalAction = status;
        }
        /*req.setNextApproverIds(new Id[] {
            UserInfo.getUserId()
                });
        req.setWorkitemId(workItem.Id);
        //Process the Approval Request
        */
	if(!quoteLineList.isEmpty()) {
        SBQQ.TriggerControl.disable();
        Pricing_QuoteLines_DML.updateQLI(quoteLineList);
        SBQQ.TriggerControl.enable();
        }
        //Approval.ProcessResult result = Approval.process(req);
        Pricing_Publish_Quote.setFSEActionOnQuoteLine(new Set<Id>{quoteLine.Id},approvalAction,comments,false);
    }

    public static Boolean recordApprovalStatusCheckAgainstPIFR(SBQQ__QuoteLine__c quoteLine,Boolean showRevisionFields,List < SBQQ__QuoteLine__c > quoteLineList, String status,string comments,string revisionComment,Map<Id,Set<Id>> quoteQTMMap,string retMsg){
        Boolean isFieldReview = false;
        if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview ) {
            quoteLine.Pricing_pm_approval_comments_nm__c = comments == '' ? quoteLine.Pricing_pm_approval_comments_nm__c : comments;
            if(status == Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM) {
                quoteLine.Pricing_Ready_for_Review_cb__c = true;
                //TPT
                quoteLine.Customer_Revision_Count_Cnt__c = (quoteLine.Customer_Revision_Count_Cnt__c == null) ? 1 : quoteLine.Customer_Revision_Count_Cnt__c + 1;
                //TPT
                chatterPostCreation(revisionComment, quoteLine, false, showRevisionFields);
            }
            //TPT
            if(status == Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyField){
                //Validate Quote Team's FSEs on field revision
                quoteQTMMap = Pricing_Publish_Quote.validateQtmFse(new Set<Id>{quoteLine.SBQQ__Quote__c});
                if(quoteQTMMap.size() > 0){
                    isFieldReview = true;
                    quoteLine.Field_Revision_Count_Cnt__c = (quoteLine.Field_Revision_Count_Cnt__c == null) ? 1: quoteLine.Field_Revision_Count_Cnt__c + 1;
                }else{
                    isFieldReview = false;
                    quoteLineList.remove(quoteLineList.indexOf(quoteLine));
                    retMsg = Label.Pricing_Tender_Quote_Sales_Rep_Error_Message;
                }
                chatterPostCreation(revisionComment, quoteLine, true, showRevisionFields);
            }
            //TPT
        }

        quoteLine.Pricing_pm_approval_comments_nm__c = quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Action_Lost && status == Label.Pricing_Tender_QuoteLine_Action_Approve ? comments : quoteLine.Pricing_pm_approval_comments_nm__c;
        quoteLine.Pricing_Won_Lost_Comments_Txt__c = status == Label.Pricing_Tender_QuoteLine_Action_Won || status == Label.Pricing_Tender_QuoteLine_Action_Lost ? comments : quoteLine.Pricing_Won_Lost_Comments_Txt__c;
        return isFieldReview;
    }

    public static void recordApprovalChangeReq(SBQQ__QuoteLine__c quoteLine,List < SBQQ__QuoteLine__c > quoteLineList, String status, Map < string, string > statusMapping){
        System.debug('recordApprovalChangeReq start===>');
        Boolean statusOverrideForWonCR = false;
        List<String> statusList = new List<String>();
        statusList.add(Label.Pricing_Tender_QuoteLine_Action_Lost);
        statusList.add(Label.Pricing_Tender_QuoteLine_Action_Reject);
        statusList.add(Label.Pricing_Tender_QuoteLine_Action_Approve);
        statusList.add(Label.Pricing_Tender_QuoteLine_Action_Won);
        if(quoteLine.Pricing_Change_Request_cb__c && quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null && statusList.contains(status)) {
            //Check if Change Request Quote Line is getting Approved then make the Parent as Revised
            if(status == Label.Pricing_Tender_QuoteLine_Action_Approve) {
                SBQQ__QuoteLine__c parentQuoteLine = Pricing_QuoteLines_Selector.newInstance().selectByQuoteLineIds(new Set<Id>{quoteLine.Pricing_Reference_Quote_Line_Nbr__c})[0];
                if(parentQuoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Action_Won) {
                    quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Action_Won;
                    quoteLine.Pricing_Won_Lost_Comments_Txt__c = parentQuoteLine.Pricing_Won_Lost_Comments_Txt__c;
                    statusOverrideForWonCR = true;
                }
                parentQuoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Revised;
                quoteLineList.add(parentQuoteLine);
            }
            quoteLine.Pricing_Change_Request_cb__c = false;
        }
        if(!statusOverrideForWonCR) {
            //Map the Actions with Appropriate QuoteLine Status Value.
            quoteLine.Pricing_Status_Nm__c = statusMapping.containsKey(status) ? statusMapping.get(status) : status;
        }
       
    }
    
    public static void chatterPostCreation(String revisionComment, SBQQ__QuoteLine__c quoteline, Boolean isFieldRevision, Boolean showRevisionFields) {
        if(showRevisionFields){
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

            //mention primary contact
            ConnectApi.MentionSegmentInput mentionSegmentInput;
            List<User> primaryContact = Pricing_User_Selector.newInstance().selectbyContactId(quoteline.SBQQ__Quote__r.SBQQ__PrimaryContact__c);
            if(!isFieldRevision){
                //mention primary contact
                mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                mentionSegmentInput.id = primaryContact[0].Id;
                messageBodyInput.messageSegments.add(mentionSegmentInput);

            textSegmentInput = new ConnectApi.TextSegmentInput(); 
            textSegmentInput.text = '  ';
            messageBodyInput.messageSegments.add(textSegmentInput);

            //mention last submitted by
            mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            mentionSegmentInput.id = quoteline.Pricing_Last_Submitted_By_Id__c;
            messageBodyInput.messageSegments.add(mentionSegmentInput);

            textSegmentInput = new ConnectApi.TextSegmentInput(); 
            textSegmentInput.text = '  ';
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            //visible for all users with access
            feedItemInput.visibility = ConnectApi.FeedItemVisibilityType.AllUsers;
	    }else{
            //mention sales rep approver
	        if(quoteline.Pricing_Sales_Rep_Approver__c != null){

                mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                mentionSegmentInput.id = quoteline.Pricing_Sales_Rep_Approver__c;
                messageBodyInput.messageSegments.add(mentionSegmentInput);

                textSegmentInput = new ConnectApi.TextSegmentInput(); 
                textSegmentInput.text = '  ';
                messageBodyInput.messageSegments.add(textSegmentInput);
            }
        }
        
        /*ConnectApi.LinkCapabilityInput linkInput = new ConnectApi.LinkCapabilityInput();
        linkInput.url = '/'+quoteline.SBQQ__Quote__r.Id;
        linkInput.urlName = quoteline.Pricing_Quote_Line_Number__c;

            ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();
            feedElementCapabilitiesInput.link = linkInput;

        feedItemInput.capabilities = feedElementCapabilitiesInput;*/
        
        ConnectApi.EntityLinkSegmentInput entityLinkSegmentInputOpportunity = new ConnectApi.EntityLinkSegmentInput();
        entityLinkSegmentInputOpportunity.entityId = quoteline.SBQQ__Quote__r.Id;  
        messageBodyInput.messageSegments.add(entityLinkSegmentInputOpportunity);
        
        textSegmentInput = new ConnectApi.TextSegmentInput(); 
        textSegmentInput.text = '\nQuote Line Number: '+quoteline.Pricing_Quote_Line_Number__c;
        messageBodyInput.messageSegments.add(textSegmentInput);

            // post body
            textSegmentInput = new ConnectApi.TextSegmentInput();
            String postBody = revisionComment;
            textSegmentInput.text = '\n'+postBody.stripHtmlTags();
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            feedItemInput.body = messageBodyInput;
            
            
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = quoteline.SBQQ__Quote__r.Id;
            
            If(!test.isRunningTest()){
            //post the chatter
            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
            }
        }
    }
    
    // Get the document Id from the name
    @AuraEnabled
    public static Id getDocumentId(string name) {
        List < Document > document = Pricing_DocumentSelector.newInstance().selectByName(name);
        return document.isEmpty() ? null : document[0].Id;
    }
    
    //Method used in Pricing_CPQ_RunReport to get the user type of the current user
    @AuraEnabled
    public static String reportingURLValue(id quoteIdPara) {
        String fullRecordURL;
        try{
            //String fullRecordURL;
            Id quoteId = (Id) String.escapeSingleQuotes(String.valueOf(quoteIdPara)); 
            SBQQ__Quote__c quote = Pricing_Quote_Selector.newInstance().selectByIds(new Set<Id>{quoteId})[0];
            Report generateReportRecord = new Report();
            String reportName;
            Set < String > internalPSWithoutRPM = new Set < String > ();
            Set < String > internalPSWithRPM = new Set < String > ();
            if(Label.Pricing_Tender_PermissionSets_AllInternal != null) {
                internalPSWithoutRPM.addAll(new List < String > ((Label.Pricing_Tender_PermissionSets_AllInternal).split(':')));
                internalPSWithoutRPM.remove(Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager);
                internalPSWithRPM = new Set < String > {
                    Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager
                        };
                            }
            Set < String > externalPS = new Set < String > ();
            if(Label.Pricing_Tender_PermissionSets_AllExternal != null) {
                externalPS.addAll(new List < String > ((Label.Pricing_Tender_PermissionSets_AllExternal).split(':')));
            }
            ReportFilters filter = new ReportFilters('equals', quote.Name, 'SBQQ__Quote__c.Name');
            List < reportFilters > reportFilters = new List < ReportFilters > {
                filter
                    };
                        String filterString = JSON.serialize(reportFilters);
            Boolean isInternalUserWithoutRPM = userHasValidPermissionSet(internalPSWithoutRPM) ? true : false;
            Boolean isRPMUser = userHasValidPermissionSet(internalPSWithRPM) ? true : false;
            Boolean isExternalUser =userHasValidPermissionSet(externalPS) ? true : false;
            fullRecordURL = reportingURLValueDetails(isRPMUser, isInternalUserWithoutRPM, fullRecordURL, isExternalUser, quote, filterString);
            
        }
        catch(Exception e){
            //retMsg = Pricing_Tender_Utility.getExceptionMessage(e);
            //system.debug('retMsg==>'+retMsg);          
            Pricing_Tender_Utility.logError(e);        
        }
        return fullRecordURL;
    }

    public static String reportingURLValueDetails(Boolean isRPMUser, Boolean isInternalUserWithoutRPM, String fullRecordURL, Boolean isExternalUser, SBQQ__Quote__c quote,String filterString){
        String reportName;
        String quoteType = quote.Pricing_Program_Type_Nm__c;
        Report generateReportRecord = new Report();
        if(isRPMUser || isInternalUserWithoutRPM) {
            fullRecordURL = URL.getSalesforceBaseURL().toExternalForm().split('\\.')[0];
            reportName = (quoteType.contains(Label.Pricing_Tender_SSD_Quote))?Label.Pricing_Tender_SSD_Report:
            (quoteType == Label.Pricing_Tender_PMem_Quote)?Label.Pricing_Tender_PMem_Report:
            (quoteType == Label.Pricing_Tender_NIC_Quote)?Label.Pricing_Tender_NIC_Report:
            Label.Pricing_Tender_Report_GenerateInternalReport;
            fullRecordURL = fullRecordURL.toLowerCase() + '.lightning.force.com/lightning/r/Report/';
        } else if(isExternalUser) {
            fullRecordURL = URL.getSalesforceBaseURL().toExternalForm();
            reportName = (quoteType == Label.Pricing_Tender_SSD_Quote)?Label.Pricing_Tender_SSD_Report_External:
            (quoteType == Label.Pricing_Tender_PMem_Quote)?Label.Pricing_Tender_PMem_Report_External:
            (quoteType == Label.Pricing_Tender_NIC_Quote)?Label.Pricing_Tender_NIC_Report_External:
            Label.Pricing_Tender_Report_GenerateExternalReport;
        }
        if(!Test.isRunningTest()) {
            generateReportRecord = [SELECT Id, Name FROM Report where DeveloperName = : reportName Limit 1];
        }
        if(isRPMUser) {
            fullRecordURL = fullRecordURL + generateReportRecord.Id + '/view?fv0=' + quote.Name + '&fv1=' + Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
        } else if(isInternalUserWithoutRPM) {
            fullRecordURL = fullRecordURL + generateReportRecord.Id + '/view?fv0=' + quote.Name + '&fv1=' + Label.Pricing_Tender_PicklistValue_AllQLStatus;
            system.debug('fullRecordURL final: '+fullRecordURL);
        } else if(isExternalUser && Network.getNetworkId() != null) {
            fullRecordURL = Network.getLoginUrl(Network.getNetworkId());
            fullRecordURL = fullRecordURL.removeEnd('login') + 'report/' + generateReportRecord.Id + '?reportFilters=' + filterString;
        }
        return fullRecordURL;
    }

    public Class ReportFilters {
        public String operator {set;get;}
        public String value {set;get;}
        public String column {set;get;}
        public ReportFilters(String str1, String str2, String str3) {
            this.operator = str1;
            this.value = str2;
            this.column = str3;
        }
    }
    @AuraEnabled
    public Static String insertOutbound(Id parentId,String action) 
    {
        Map<Id,String> quoteLineIdToActionMap = new Map<Id,String>();
        Map<Id,String> quoteLineIdToErrorMap = new Map<Id,String>();
        Map<Id,SBQQ__QuoteLine__c> quoteLineMap;
        Map<Id,String> qlIdToRuleIdRuleNameMap = new Map<Id,String>();
        String overLapDealQLErrMsg;
	    String qlStatusMsg;
        quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>(Pricing_QuoteLines_Selector.newInstance().selectByIdAndPM(parentId)); 
        Pricing_IntegrationSFDCToPricingSystems integrationSystem =  new Pricing_IntegrationSFDCToPricingSystems();
        quoteLineIdToErrorMap.putAll(integrationSystem.validationMethod(quoteLineMap.values()));
        
        if(quoteLineIdToErrorMap.containsKey(parentId) && quoteLineIdToErrorMap.get(parentId) == 'Success' || Test.isRunningTest()){
            if (TriggerHandler.isActive('Pricing_OverLap_Deal_QL_Switch')){
                overLapDealQLErrMsg = isOverLapDealQL(quoteLineMap,parentId);
            }
            if(String.isNotBlank(overLapDealQLErrMsg)){
                qlStatusMsg = overLapDealQLErrMsg;
            }
            else
            {
                quoteLineIdToActionMap.put(parentId,action);
                User loggedInUser = Pricing_User_Selector.newInstance().selectbyUserId(userInfo.getUserId())[0];
                quoteLineIdToErrorMap = Pricing_IntegrationSFDCToPricingSystems.insertQuoteOutBoundMessage(quoteLineIdToActionMap,quoteLineMap,loggedInUser.Core_WWID__c,true,qlIdToRuleIdRuleNameMap);
                qlStatusMsg = quoteLineIdToErrorMap.get(parentId);
            }
            return qlStatusMsg;
        }
        else{
            return quoteLineIdToErrorMap.get(parentId);
        }
    }

    /*Method written to prevent RPM from creating/updating a Deal for a Quote Line which belongs to the 
    same Account, End Customer, Product, Project and has a partial overlap or exact match as the Approved Start 
    and Approved End Date of the existing Quote Lines of a Quote*/
    public static String isOverLapDealQL(Map<Id,SBQQ__QuoteLine__c> quoteLineMap,Id parentId){
        String overLapDealMsg;
        List<String> overLapQLNums = new List<String>();
        /*Query which retrieves the overlapping quote lines belonging to the same Account, Product, Project and has a 
        partial overlap or exact match as the Approved Start and Approved End Date of the existing Quote Lines of a Quote*/
        List<SBQQ__QuoteLine__c> quoteLineList = Pricing_QuoteLines_Selector.newInstance().overLapQuery(quoteLineMap,parentId);
        
        for(SBQQ__QuoteLine__c oQL: quoteLineList){
            /*Condition to check the Unified End Customer/End Customer/Write in End Customer against the Unified Global End 
            Customer lookup field or the End Customer lookup field or the Write In End Customer text field. 
            If a match is found, the overlapping QL numbers are added to the list and then concatenated with the error message 
            to be shown on the UI*/
            if((quoteLineMap.get(parentId).SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c == true && (oQL.SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name == quoteLineMap.get(parentId).SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name || oQL.SBQQ__Quote__r.Pricing_End_Customer__r.Name == quoteLineMap.get(parentId).SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name || oQL.SBQQ__Quote__r.Pricing_Customer_Nm__c == quoteLineMap.get(parentId).SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name)) || 
            (quoteLineMap.get(parentId).SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c == false && (oQL.SBQQ__Quote__r.Pricing_End_Customer__r.Name == quoteLineMap.get(parentId).SBQQ__Quote__r.Pricing_End_Customer_Name__c || 
            oQL.SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name == quoteLineMap.get(parentId).SBQQ__Quote__r.Pricing_End_Customer_Name__c || 
            oQL.SBQQ__Quote__r.Pricing_Customer_Nm__c == quoteLineMap.get(parentId).SBQQ__Quote__r.Pricing_End_Customer_Name__c))){
                overLapQLNums.add(oQL.Pricing_Quote_Line_Number__c);
            }
        }
        if(overLapQLNums.size() > 0){
            overLapDealMsg = Label.Pricing_OverlapDeal_Error_Message + ' ' + overLapQLNums;
        }
        return overLapDealMsg;
    }
    
    //Method to delete the related records(Document share, TPT, Comments) when is quote is delete
    @AuraEnabled
    public static Boolean deleteIQRQuote(Id quoteId){
        Id currentUserid = userinfo.getUserId();
        Boolean deletable = false;
        List<Pricing_Comments__c> comList = new List<Pricing_Comments__c>();
        List<Pricing_Document__c> documentShareList = new List<Pricing_Document__c>();
        List<Pricing_Quote_Line_Status_Age__c> pricingTPTList = new List<Pricing_Quote_Line_Status_Age__c>();
        List<Pricing_Quote_Team__c> quoteTeamList = new List<Pricing_Quote_Team__c>();
        SBQQ__Quote__c quote = Pricing_Quote_Selector.newInstance().selectByIds(new Set<Id>{quoteId})[0];
        integer count = Pricing_PermissionSetAssignment_Selector.newInstance().getCountbyName(Userinfo.getUserId(),new Set<String>{Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator});
        if(quoteId != null){
            if(quote.CreatedbyId == currentUserid || quote.OwnerId == currentUserid || count > 0){
                deletable = true;
                comList = Pricing_Comments_Selector.newInstance().selectByQuoteId(quoteId);
                documentShareList = Pricing_Document_Selector.newInstance().selectByquoteId(quoteId);
                pricingTPTList = Pricing_Quote_Line_Status_Age_Selector.newInstance().selectbyQuoteId(quoteId);
                quoteTeamList = Pricing_Quote_Team_Selector.newInstance().selectbyQuoteId(quoteId);
                if(!comList.isEmpty()){
                    Pricing_Comments_DML.deleteComments(comList);
                }
                if(!documentShareList.isEmpty()){
                    Pricing_Document_DML.deleteDocuments(documentShareList);
                }
                if(!pricingTPTList.isEmpty()){
                    Pricing_Quote_Line_Status_Age_DML.deleteTPT(pricingTPTList);
                }
                if(!quoteTeamList.isEmpty()){
                    Pricing_Quote_Team_DML.deleteQTMS(quoteTeamList);
                }
                Pricing_Quote_DML.deleteQuotes(new List<SBQQ__Quote__c>{quote});
            } else{
                deletable = false;
            }
        }
        return deletable;  
    }

    //Method to check if rejection is allowed after integration
    public static Map<Id, Boolean> isIntegartionRejectionAllowed(set<Id> quoteLineIdSet) {
        Map<Id, Boolean> validQlIdToIsIntegrationRejectMap = new Map<Id, Boolean>();
        for(SBQQ__QuoteLine__c quoteLine: Pricing_QuoteLines_Selector.newInstance().selectByQuoteLineIds(quoteLineIdSet)) {
            if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview) {
                if(quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product 
                && quoteLine.Pricing_Integration_Status_Nm__c == Label.Pricing_Tender_MyDeal_Integration_Status_Complete && quoteLine.Pricing_Reference_Quote_Line_Nbr__c == null) {
                    validQlIdToIsIntegrationRejectMap.put(quoteLine.Id , true);
                } else {
                    validQlIdToIsIntegrationRejectMap.put(quoteLine.Id , false);
                }
            }                                 
        }
        return validQlIdToIsIntegrationRejectMap;
    }

    //Method to restrict won through bulk list view if QL is not unified and country is in REVIEWWIP or country is blocked
    public static Map<Id,String> isNotUnifiedQuoteLineBulk(Set<Id> quoteLineIdSet) {
        Map<Id, String> quoteLineIdMsgMap = new Map<Id, String>();
        List<SBQQ__QuoteLine__c> nonWriteInQLList = Pricing_QuoteLines_Selector.newInstance().selectByIdAndProduct(quoteLineIdSet);

        
        try {
            if(nonWriteInQLList.size() > 0) {
                for(SBQQ__QuoteLine__c quoteLine : nonWriteInQLList) {
                    if(!quoteLineIdMsgMap.containsKey(quoteLine.Id)) {
                        if(quoteLine.SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c == false) {
                            quoteLineIdMsgMap.put(quoteLine.Id, Label.Pricing_Tender_Not_Unified_Error);
                        } else if(TriggerHandler.isActive('Pricing_UCD_Switch') && quoteLine.SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c == true) {
                            List<String> complianceWatchList = new List<String>();
                            String cwlValue = quoteLine.SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c;
                            if(cwlValue != null) {
                                complianceWatchList.addAll(cwlValue.split(';'));
                            }
                            if(quoteLine.SBQQ__Quote__r.Pricing_Is_Sanctioned__c == true) {
                                if(complianceWatchList.contains('EC')) {
                                    quoteLineIdMsgMap.put(quoteLine.Id, Label.Pricing_UCD_Auto_Rejection_Comments_For_EC);
                                } else {
                                    quoteLineIdMsgMap.put(quoteLine.Id, Label.Pricing_UCD_Auto_Rejection_Comments);
                                }
                            } else if (quoteLine.SBQQ__Quote__r.Pricing_Is_Sanctioned__c == false && (complianceWatchList.contains('REVIEWWIP') || complianceWatchList.isEmpty())) {
                                quoteLineIdMsgMap.put(quoteLine.Id, Label.Pricing_UCD_Auto_Rejection_Comments_for_REVIEWWIP_and_blank);
                            }
                        }
                    }
                } 
            } 
        } catch(exception ex) {
            Pricing_Tender_Utility.logError(ex);
        }
        return quoteLineIdMsgMap;
    }

    //Method to restrict won through dropdown if QL is not unified and country is in REVIEWWIP or country is blocked 
    @AuraEnabled
    public static String isNotUnifiedQuoteLine(Id quoteLineId) {
        String msg;
        Map<Id, String> qlIdMsgMap = new Map<Id, String>();
        List<SBQQ__QuoteLine__c> pendingCRList =  Pricing_QuoteLines_Selector.newInstance().selectByRefQLIIdAndStatus(quoteLineId,Label.Pricing_Tender_QuoteLine_Status_Rejected);
        
        if((pendingCRList.Size() > 0)) {
            msg =  'PendingCRExist;' + Label.Pricing_Active_CR_Warning_Header + ';' + pendingCRList[0].Pricing_Quote_Line_Number__c;
        }  else {
            qlIdMsgMap = isNotUnifiedQuoteLineBulk(new Set<Id>{quoteLineId});
            String errorMsg = qlIdMsgMap.isEmpty() ? 'Success' : (qlIdMsgMap.containsKey(quoteLineId)) ? qlIdMsgMap.get(quoteLineId) : 'Error';
            msg = 'customerBlocked;' + Label.Pricing_Won_Not_Allowed_Warning_Header +';' + errorMsg;
        }                                         
        
        System.debug('Message map===>'+qlIdMsgMap);
        System.debug('Message ===>'+msg);
        return msg;
    }

    //Method to return Quoteline RecordTypeId using Quote Line Type 
    @AuraEnabled(cacheable = true)
    public static String getRecordTypeId(String quoteLineType){
        Id recordTypeId;
        String recordTypeDeveloperName = '';
        recordTypeDeveloperName = (quoteLineType == Label.Pricing_Tender_Standard_QuoteLine) ? Label.Pricing_Tender_Quote_Line_Create
                                 :(quoteLineType == Label.Pricing_Tender_Small_Volume_Quote) ? Label.Pricing_SVD_Quote_Line_Create
                                 :(quoteLineType == Label.Pricing_Tender_SSD_Quote) ? Label.Pricing_SSD_Quote_Line_Create
                                 :(quoteLineType == Label.Pricing_Tender_PMem_Quote) ? Label.Pricing_PMem_Quote_Line_Create
                                 :(quoteLineType == Label.Pricing_Tender_NIC_Quote) ? Label.Pricing_NIC_Quote_Line_Create
                                 : Label.Pricing_Tender_Quote_Line_Create;

        if(recordTypeDeveloperName!= null){
            recordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c',recordTypeDeveloperName);
        }
        
        system.debug(recordTypeId);
        return recordTypeId;
    }
     
    //Method to search Products and return Product list to show in DataTable
    @AuraEnabled
    public static List<Product2> searchProductsSOQL(String searchString, String quoteLineType) {
        if(quoteLineType!=null) {
            Pricing_Dynamic_Data_Table__mdt dynamicDataTableMetadata = Pricing_Dynamic_Data_Table_Selector.newInstance().selectByType(new Set<String>{quoteLineType})[0];
            List<Product2> productList = new List<Product2>();
            if(dynamicDataTableMetadata != null) {
                String queryString =dynamicDataTableMetadata.Pricing_Query__c;
                if(searchString!=null && searchString!='') {
                    searchString = '%'+string.escapeSingleQuotes(searchString.trim())+'%';
                    String whereClause = dynamicDataTableMetadata.Pricing_Where_Clause__c + dynamicDataTableMetadata.Pricing_SearchColumn_Field__c.replace('{{searchString}}',searchString);
                    queryString = queryString+ ' ' + whereClause;
                    queryString = queryString + ' Limit 100';
                    productList = Pricing_Product_Selector.newInstance().selectByText(queryString);
                    return productList;
                } 
                else { 
                    return null;
                }
            } 
            else {
                return null;
            }
        }
        else {
            return null;
        } 
    }

    //Method to get Data Table columns with the use of Metadata record
    @AuraEnabled
    public static Map<String,List<DataTableColumns>>  getDataTableColumns() {
    Map<String,List<DataTableColumns>> qlTypeToDataTblColMap = new Map<String,List<DataTableColumns>>();
    List<Pricing_Dynamic_Data_Table__mdt> dynamicDataTableMetadata = Pricing_Dynamic_Data_Table_Selector.newInstance().selectByLabel();
    for(Pricing_Dynamic_Data_Table__mdt pd: dynamicDataTableMetadata){
        List<string> columnList = new List<string>();
        List<string> fieldAPINameList = new List<string>();
        List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
        if(pd.Pricing_Field_Label__c != null) {
            columnList = pd.Pricing_Field_Label__c.split(',');
        }
        if(pd.Pricing_Field_Value__c != null) {
            fieldAPINameList = pd.Pricing_Field_Value__c.split(',');
        }
        if(columnList.size() > 0) {
            for(integer i = 0; i < columnList.size(); i++) {
                DataTableColumns datacolumn = new DataTableColumns(columnList[i].substringBefore(':').trim(), 
                                                                    fieldAPINameList[i].substringBefore(':').trim(), 
                                                                    fieldAPINameList[i].substringAfter(':').trim(),
                                                                    true);
                lstDataColumns.add(datacolumn);
            }
            if(qlTypeToDataTblColMap.get(pd.Pricing_Record_Type__c) == null){
                qlTypeToDataTblColMap.put(pd.Pricing_Record_Type__c,lstDataColumns);
            }
        }
    }
    if(!(qlTypeToDataTblColMap.isEmpty())){
        return qlTypeToDataTblColMap;
    }
    else{
        return null;
    }
    }
    
    //Wrapper class to return Dynamic DataTable columns based on Quote Type
    public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public Boolean sortable {get;set;}

        public DataTableColumns(String label, String fieldName, String type, Boolean sortable)
        {
            this.label     = label;
            this.fieldName = fieldName;
            this.type      = type;  
            this.sortable = sortable;        
        }
    }

    //method to get wrapper of listViews.
    @AuraEnabled
    public static list<listViewWrapper> listValues(string objectInfo){
 
        list<listViewWrapper> oListViewWrapper = new list<listViewWrapper>();
 
        for(ListView lv : [SELECT id, Name, DeveloperName FROM ListView
                           WHERE sObjectType = : objectInfo AND DeveloperName = :Label.Pricing_Tender_QuoteLine_ListViews.split(',') ORDER By Name ASC]){ 
            listViewWrapper oWrapper = new listViewWrapper();
            oWrapper.label = lv.Name;
            oWrapper.developerName = lv.DeveloperName;
            oListViewWrapper.add(oWrapper);
        }
        return oListViewWrapper; 
    }
 
    //wrapper class to store listView details
    public class listViewWrapper{
        @AuraEnabled public string label{get;set;} 
        @AuraEnabled public string developerName{get;set;} 
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isPricingManager() {
        Boolean isRPMUser = Pricing_CommentsController_Mock.isPricingManager();
        return isRPMUser;
    }
}