/****************************************************************************************************************************************
* Class Name      : Core_MDF_PICReviewScreen_Controller
* Version               : 1.0 
* Created Date          : 12-21-2021
* Modification Log      : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - BD     12-21-2021        Controller class for PIC Review Screen
*****************************************************************************************************************************************/
public without sharing class Core_MDF_PICReviewScreen_Controller {
    public static double reviewCycle = 0.0;
    public static List<String> documentTypes = Label.Core_MDF_Claim_Document_Types.split(';');
    
    /***************************************************************************************************** 
	Method Name:        fetchClaimRecords
	Description:        Fetching Claim details for displaying them in PIC Review Screen
	@Added By:          Accenture - VB - 12-21-2021
	Modified By:        Date:       Changes: 
	******************************************************************************************************/ 
    @AuraEnabled(cacheable=true)
    public static PartnerFundClaim fetchClaimRecords(Id claimId, Boolean isPICReviewer) {
        PartnerFundClaim claim = new PartnerFundClaim();
        claim = [select Id,Core_MDF_Eligible_for_PIC__c, Title, Core_MDF_Claim_Ref_Number__c, Core_MDF_Ad_Run_Start_Date__c, Core_MDF_Ad_Run_End_Date__c,
                 Core_MDF_AccountCompany__c, Core_MDF_Status__c, Core_MDF_Program__c, Core_MDF_Budget_Type_Nm__c, Core_MDF_Currency__c, Core_MDF_Country_Location_nm__c, Core_MDF_Invoice_Date__c,
                 Core_MDF_Invoice_Number__c,  Core_MDF_Total_Invoice_Amount_Local__c, Core_MDF_OtherCostsnotReimbursable_Local__c, Core_MDF_Reimbursable_TransactionAmt_Loc__c,
                 Core_MDF_Reimbursable_Transaction_Amount__c,Core_MDF_Reimbursement_Percent__c, Core_MDF_Requested_Reimbursement_Amt__c,
                 Core_MDF_Taxes_Local__c, Core_MDF_Media_Vehicle__c,  Core_MDF_Escalation_Id__c, Core_MDF_Exchange_rate__c, Amount, Core_MDF_Claim_Comments__c,
                 RequestId, Request.Title,Core_MDF_Activity_Category__c, Core_MDF_Activity_Types__c, Core_MDF_Activity_SubType_nm__c,
                 Core_MDF_Owner_Nm__c, Core_MDF_Bank__c,  Core_MDF_Bank__r.Name, Core_MDF_Region_Cd__c, Core_MDF_Activity_End_Date__c, Core_MDF_Activity_Start_Date__c,
                 Request.Core_MDF_Budget_Amount_Local_amt__c, Request.Core_MDF_Activity_Number__c,Core_MDF_3rd_Party_POP_Doc_Required_Ind__c, Request.Core_MDF_NEX_Ind__c, Core_MDF_Escalation_Id__r.Name,
                 ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Id, Core_MDF_Campaign_Id__r.Core_MDF_CampOutcomeOpt_In_Ind__c,Core_MDF_OutcomeBased_Ind__c,Core_MDF_Campaign_Id__c //added by Sham,16654
                 from PartnerFundClaim where id =: claimId limit 1];
        
        return claim;
    }
    
    /***************************************************************************************************** 
	Method Name:        fetchAuditDocuments
	Description:        Fetching Claim review documents related to the claim for displaying them in PIC Review Screen
	@Added By:          Accenture - BD - 12-21-2021
	Modified By:        Date:       Changes: 
	******************************************************************************************************/ 
    @AuraEnabled(cacheable=true)
    public static List<Core_MDF_Audit_Document__c> fetchAuditDocuments(Id claimId) {
        List<Core_MDF_Audit_Document__c> auditDocumentList = new List<Core_MDF_Audit_Document__c>();
        auditDocumentList = [select Id, Core_MDF_Document_Types__c, Core_MDF_Selected_Document_Types_txt__c, Core_MDF_Document_Title__c, Core_MDF_Int_Document_Name__c, Core_MDF_Claim__c, createdDate, createdById, CreatedBy.Name, Core_MDF_Document_Id__c from Core_MDF_Audit_Document__c where Core_MDF_Claim__c =: claimId];
        return auditDocumentList;
    }
    
    /***************************************************************************************************** 
	Method Name:        fetchQuestionRecords
	Description:        Fetching Questions from PIC Review Question object for displaying in PIC Review Screen
	@Added By:          Accenture - BD - 12-21-2021
	Modified By:        Date:       Changes: 
	******************************************************************************************************/ 
    @AuraEnabled(cacheable=true)
    public static List<core_MDF_PICReviewQuestion__c> fetchQuestionRecords(Id claimId){
        Date today = System.today();
        PartnerFundClaim prc = fetchClaimRecords(claimId, false);

        Boolean isOutcomeBasedClaim = false;
        if (prc.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM && prc.Core_MDF_OutcomeBased_Ind__c == true) {
            isOutcomeBasedClaim = true;
        }

        //Fetching Question records which are active and have the same program and budget type as claim
        List<core_MDF_PICReviewQuestion__c> questionList = [select id,Core_MDF_Question_en_US_txt__c,Core_MDF_Question_File_Type_nm__c,Core_MDF_Budget_Type_nm__c,Name,Core_MDF_Parent_Question__r.Name, 
                                                            Core_MDF_Sort_Order__c,Core_MDF_Sub_Question_Ind__c,Core_MDF_All_Budget_Types_Ind__c,Core_MDF_Channel_Program__c,Core_MDF_All_Programs_Ind__c,Core_MDF_Third_Party_Ind__c
                                                            from core_MDF_PICReviewQuestion__c where Core_MDF_EffectiveDate_dt__c <= today 
                                                            AND Core_MDF_IneffectiveDate_dt__c >= today AND Core_MDF_Is_Active_ind__c = true
                                                            AND (Core_MDF_Budget_Type_nm__c = :prc.Core_MDF_Budget_Type_Nm__c OR Core_MDF_All_Budget_Types_Ind__c = true)
                                                            AND (Core_MDF_Channel_Program__c = :prc.Core_MDF_Program__c OR Core_MDF_All_Programs_Ind__c = true)
                                                            AND Core_MDF_Outcome_Based_Indicator_Ind__c = :isOutcomeBasedClaim
                                                            ORDER BY Core_MDF_Sort_Order__c];
        return questionList;
        
    }

    /***************************************************************************************************** 
	Method Name:        fetchTactics
	Description:        Fetching Tactics from Claim Attributes object for displaying in PIC Review Screen
	@Added By:          Accenture - RP - 12-Sept-2025
	Modified By:        Date:           Changes: 
    	Roshan              07-Oct-2025     Returning tactics record instead of a list of tactics
    ******************************************************************************************************/
    @AuraEnabled
    public static Map<String, List<Core_MDF_Claim_Attributes__c>> fetchTactics(Id claimId) {
        Map<String, List<Core_MDF_Claim_Attributes__c>> tacticMap = new Map<String, List<Core_MDF_Claim_Attributes__c>>();

        List<Core_MDF_Claim_Attributes__c> allTactics = [SELECT Id, Name, Core_MDF_Field_Value_nbr__c, Core_MDF_Is_Active_Ind__c, Core_MDF_Tactics_nm__c, Core_MDF_Type_nm__c, Core_MDF_Field_Name_nm__c FROM Core_MDF_Claim_Attributes__c
                                                            WHERE Core_MDF_Claim_Id__c = :claimId AND Core_MDF_Is_Active_Ind__c = true AND Core_MDF_Type_nm__c IN ('KPI - Claim', 'Spend This Period')];

        for (Core_MDF_Claim_Attributes__c tacticRec : allTactics) {
            if (String.isNotBlank(tacticRec.Core_MDF_Tactics_nm__c)) {
                if (!tacticMap.containsKey(tacticRec.Core_MDF_Tactics_nm__c)) {
                    tacticMap.put(tacticRec.Core_MDF_Tactics_nm__c, new List<Core_MDF_Claim_Attributes__c>());
                }
                tacticMap.get(tacticRec.Core_MDF_Tactics_nm__c).add(tacticRec);
            }
        }

        return tacticMap;
    }


    /***************************************************************************************************** 
	Method Name:        reviewDataInsertion
	Description:        Inserting PIC review responses to PIC Review Result object
	@Added By:          Accenture - BD - 12-21-2021
	Modified By:        Date:       Changes: 
	******************************************************************************************************/
    @AuraEnabled
    public static void reviewDataInsertion(picReviewDetailsWrapper picReviewWrapper)
    {   
        Core_MDF_PIC_Review__c picReview = new Core_MDF_PIC_Review__c();
        
        list<Core_MDF_PIC_Review__c> existingPICReviewRecords = new List<Core_MDF_PIC_Review__c>();
        try {
			//TWC3117-18978 defect
            PartnerFundClaim claimToLock = [SELECT Id, Core_MDF_Status__c FROM PartnerFundClaim WHERE Id = :picReviewWrapper.claimId FOR UPDATE];
            Boolean isEligibleForReview =
            claimToLock.Core_MDF_Status__c == Label.Core_MDF_Claim_Status_PIC_Pending ||
            claimToLock.Core_MDF_Status__c == Label.Core_MDF_Claim_Status_Payment_Clearance_Processing;
            
            if (!isEligibleForReview) {
                return;
            }
			//TWC3117-18978 defect
            existingPICReviewRecords = [select Id,Core_MDF_CycleNumber_nbr__c from Core_MDF_PIC_Review__c where Core_MDF_Claim_ID_id__c =: picReviewWrapper.claimId and Core_MDF_AI_PIC_Review_Ind__c = false order by Core_MDF_CycleNumber_nbr__c DESC limit 1]; 
        	
            if(!existingPICReviewRecords.isEmpty()) {
                reviewCycle = existingPICReviewRecords.get(0).Core_MDF_CycleNumber_nbr__c + 1;
            } else {
                reviewCycle = 1;
            }       
        
            // PIC Review Insertion
            picReview = insertPICReview(reviewCycle,picReviewWrapper.internalComments,picReviewWrapper.startDateTime,picReviewWrapper.endDateTime,picReviewWrapper.claimId,picReviewWrapper.userId,picReviewWrapper.isReviewFailed, picReviewWrapper.latestAIPICreviewID);
        
            // PIC Review Details insertion
            insertPICReviewDetails(picReviewWrapper.questionData,picReview.Id);
        
            // For Claim Updates
            claimUpdateOperations(picReview,picReviewWrapper.claimId,picReviewWrapper.isRecommendedForAudit);
        }catch(Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    /***************************************************************************************************** 
	Method Name:        fetchClaimRecordData
	Description:        To fetch the updated claim details during start and complete of PIC review process
	@Added By:          Accenture - VB - 12-21-2021
	Modified By:        Date:       Changes: 
	******************************************************************************************************/ 
    @AuraEnabled
    public static PartnerFundClaim fetchClaimRecordData(Id claimId) {
        PartnerFundClaim claim = new PartnerFundClaim();
        Set<String> kpiFieldsList = fetchKPIFields(claimId);
        String kpiFields;
        String queryString = 'Select Id,Core_MDF_Ad_Run_Start_Date__c,Core_MDF_Ad_Run_End_Date__c,Core_MDF_Status__c,Core_MDF_Budget_Type_Nm__c,Core_MDF_Program__c,Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Requested_Reimbursement_Amt__c,Core_MDF_Currency__c, Core_MDF_Invoice_Date__c, Core_MDF_Invoice_Number__c, Core_MDF_OtherCostsnotReimbursable_Local__c, Core_MDF_Bank__c, Core_MDF_Taxes_Local__c, Title, Core_MDF_Claim_Comments__c, Core_MDF_Media_Vehicle__c, Core_MDF_Last_Reviewed_By_id__c, Core_MDF_Last_Reviewed_By_id__r.Name,Core_MDF_VAT_Opt_In__c,Core_MDF_Country_Location_nm__c,Core_MDF_Campaign_Id__r.Core_MDF_CampOutcomeOpt_In_Ind__c, Core_MDF_Quantity_to_Date_Nbr__c,Core_MDF_OutcomeBased_Ind__c,Core_MDF_3rd_Party_POP_Doc_Required_Ind__c,Core_MDF_Campaign_Id__c,Core_MDF_Reimbursable_TransactionAmt_Loc__c,Core_MDF_Activity_Types__c';//16654
        if(!kpiFieldsList.isEmpty()) {
            for(String kpiField: kpiFieldsList) {
               queryString = queryString + ','+ kpiField;
            }
        }
        //queryString = queryString +' '+ 'from PartnerFundClaim'+' '+'where  Id = \'' + claimId + '\'' + ' '+'limit 1'; 
        queryString = String.escapeSingleQuotes(queryString) +' '+ 'from PartnerFundClaim'+' '+'where  Id = \'' + String.escapeSingleQuotes(claimId) + '\'' + ' '+'limit 1';
        claim = Database.query(queryString);
        return claim;
    }
    
    /***************************************************************************************************** 
	Method Name:        checkUserPermissionSet
	Description:        Checking permission set of user attempting to do PIC Review
	@Added By:          Accenture - VB - 12-21-2021
	Modified By:        Date:       Changes: 
	******************************************************************************************************/ 
    @AuraEnabled(cacheable=true)
    public static Boolean checkUserPermissionSet(Id userId){
        Boolean isAccessProvided = false;
        String customPermissionSetName = 'Core_MDF_CCP_PIC_Reviewer';
        //Ensuring only users with PIC Reviewer permission set can complete review
        try {
            isAccessProvided = FeatureManagement.checkPermission(customPermissionSetName);
        } catch(Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return isAccessProvided;
    }
    
    /***************************************************************************************************** 
	Method Name:        insertPICReview
	Description:        To insert record in PIC Review Object
	@Added By:          Accenture - BD - 1-15-2022
	Modified By:        Date:       Changes: 
	******************************************************************************************************/ 
    public static Core_MDF_PIC_Review__c insertPICReview(double reviewCycle,String intComments, Datetime startDate, Datetime endDate, Id claimId, Id userId,Boolean isReviewFailed, Id aiPICReviewId){
        
        Core_MDF_PIC_Review__c picReview = new Core_MDF_PIC_Review__c();
        
        picReview.Core_MDF_InternalComments_txt__c = intComments;
        picReview.Core_MDF_Claim_ID_id__c = claimId;
        picReview.Core_MDF_CycleNumber_nbr__c = reviewCycle;
        picReview.Core_MDF_StartTime_dtm__c = startDate;
        picReview.Core_MDF_EndTime_dtm__c = endDate;
        picReview.Core_MDF_ReviewedBy_id__c = userId;
        picReview.Core_MDF_AI_PIC_Review_Id__c = aiPICReviewId;
        
        if(isReviewFailed == true)
        {
            picReview.Core_MDF_Review_Status_nm__c = label.Core_MDF_PICReview_Status_Failed ;
        }
        else if(isReviewFailed == false)
        {
            picReview.Core_MDF_Review_Status_nm__c = label.Core_MDF_PICReview_Status_Completed;  
        }
        
        insert picReview;
        return picReview; 
        
    }
    
    @AuraEnabled
    public static List<String> getClaimAttributesFromMetaData(Id claimId){
        List<String> claimAttributesList = new List<String>();
        List<String> finalClaimAttributesList = new List<String>();
        Set<String> kpiFieldList = new Set<String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        String objectAPIName = 'PartnerFundClaim';
        Set <String> fieldMap = schemaMap.get(objectAPIName).getDescribe().fields.getMap().keySet();
        try {
            kpiFieldList = fetchKPIFields(claimId);
            claimAttributesList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Fields').split(',');
            claimAttributesList.addAll(kpiFieldList);
            for(String claimAttr : claimAttributesList) {
                if(fieldMap.contains(claimAttr.toLowerCase())) {
                    finalClaimAttributesList.add(claimAttr);
                }
            }
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
        return finalClaimAttributesList;
    }
    
    /***************************************************************************************************** 
	Method Name:        fetchAuditDocumentList
	Description:        To fetch Audit Document List for the claim
	@Added By:          Accenture - BD - 1-25-2022
	Modified By:        Date:       Changes: 
	******************************************************************************************************/ 
    @AuraEnabled
    public static List<Core_MDF_Audit_Document__c> fetchAuditDocumentList(Id claimId){
        List<Core_MDF_Audit_Document__c> auditDocumentList = new List<Core_MDF_Audit_Document__c>();
        auditDocumentList = [select Id, Core_MDF_Document_Types__c, Core_MDF_Selected_Document_Types_txt__c, Core_MDF_Document_Title__c, Core_MDF_Int_Document_Name__c, Core_MDF_Claim__c, CreatedDate, CreatedById, CreatedBy.Name, Core_MDF_Document_Id__c from Core_MDF_Audit_Document__c where Core_MDF_Claim__c =: claimId];
        return auditDocumentList;
    }
    
    /***************************************************************************************************** 
	Method Name:        insertPICReviewDetails
	Description:        To insert record in PIC Review Details object
	@Added By:          Accenture - BD - 1-25-2022
	Modified By:        Date:       Changes: 
	******************************************************************************************************/ 
    public static void insertPICReviewDetails(List<QuestionWrapper> questionData,Id picReviewID)
    {
        List<QuestionWrapper> wrapper = questionData;
        list<core_MDF_PICReviewResult__c> reviewInputList = new list<core_MDF_PICReviewResult__c>();
        
        // Extracting response data from questionData array passed by LWC
        if(!questionData.isEmpty() && questionData!=null)
        {
            for(QuestionWrapper objVar : wrapper){
                String fileType = objVar.fileType;
                    List<String> filesAffected = new List<String>();
                    String response = objVar.response;
                    if(Core_MDF_CCP_ConstantClass.picQuestionResponses.contains(response))
                    {
                        for(FileDetails fileName : objVar.fileNames){
                            if(fileName.selected == true) {
                                filesAffected.add(fileName.originalFileName);
                            }
                        }
                    }
                    //Inserting PIC Review Result when files affected is selected
                    core_MDF_PICReviewResult__c reviewInput = new core_MDF_PICReviewResult__c();
                    reviewInput.Core_MDF_PIC_Review_id__c = picReviewID;
                    reviewInput.Core_MDF_Question_id__c = objVar.Id;
                    reviewInput.Core_MDF_Response_txt__c = objVar.response;
                    reviewInput.Core_MDF_Comment_txt__c = objVar.comment; 
                    reviewInput.Core_MDF_FilesAffected_txt__c = String.join(filesAffected, ';'+' ');
                    reviewInput.Core_MDF_Tactics_nm__c = String.join(objVar.tactic, ';');
                    reviewInput.Core_MDF_AI_PIC_Review_Detail_Id__c = objVar.aiPicReviewResId;
                    reviewInput.Core_MDF_AI_Response_Agreement_Nm__c = objVar.agreementToAIResponse;
                    reviewInput.Core_MDF_Feedback_To_AI_Agent_Txt__c = objVar.feedbackCmtToAIResponse;
                    reviewInput.Core_MDF_AI_Confidence_Score_Nm__c =  objVar.aiConfidenceScore;
                    reviewInputList.add(reviewInput);   
                }
            }
        insert reviewInputList;
    }
    
    /***************************************************************************************************** 
	Method Name:        claimUpdateOperations
	Description:        To update claim record after one PIC review cycle
	@Added By:          Accenture - BD - 1-25-2022
	Modified By:        Date:       Changes: 
	Roshan              13 Jan 26   Super Claim PIC changes
	******************************************************************************************************/ 
    public static void claimUpdateOperations(Core_MDF_PIC_Review__c picReview,Id claimID,Boolean isRecommendedForAudit)
    {
        List<PartnerFundClaim> claimsToUpdate = new List<PartnerFundClaim>();

        PartnerFundClaim claim = [select id,Core_MDF_Status__c,Status,Core_MDF_Legacy_Claim_Ind__c,Core_MDF_Escalation_Id__r.Core_MDF_Escalation_Type_nm__c,Core_MDF_Recommend_For_ClaimReview__c,Core_MDF_RecentInternalComments_txt__c,Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c,Core_MDF_Document_Submission_Missed_Ind__c,Core_MDF_Program__c,Core_MDF_Latest_Review_Cycle_Number_nbr__c,Core_MDF_Document_Hold_Ind__c,Core_MDF_Last_Reviewed_By_id__c,Core_MDF_Budget_Type_Nm__c,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_PIC_Review_Completed__c,Core_MDF_Campaign_Id__r.Core_MDF_CampOutcomeOpt_In_Ind__c, Core_MDF_OutcomeBased_Ind__c, Core_MDF_Has_Sub_Claims_Ind__c from PartnerFundClaim where id = : claimID];
        claim.Core_MDF_Last_Reviewed_By_id__c = picReview.Core_MDF_ReviewedBy_id__c;
        
        
        if(isRecommendedForAudit)
        {
            claim.Core_MDF_Recommend_For_ClaimReview__c = isRecommendedForAudit;
        }
        
        if(picReview.Core_MDF_InternalComments_txt__c!= null)
        {
            if(claim.Core_MDF_RecentInternalComments_txt__c!=null)
            {
                String newLine = '\n' + label.Core_MDF_Cycle_Text + ' ' + String.valueOf(Integer.valueOf(picReview.Core_MDF_CycleNumber_nbr__c)) + ' : ' + picReview.Core_MDF_InternalComments_txt__c;
                claim.Core_MDF_RecentInternalComments_txt__c = claim.Core_MDF_RecentInternalComments_txt__c + newline;
            }
            else
            {
                claim.Core_MDF_RecentInternalComments_txt__c = label.Core_MDF_Cycle_Text + ' ' + String.valueOf(Integer.valueOf(picReview.Core_MDF_CycleNumber_nbr__c)) + ' : ' + picReview.Core_MDF_InternalComments_txt__c;
            }
        }
        else
        {
            if(claim.Core_MDF_RecentInternalComments_txt__c!=null)
            {
                String newLine = '\n' + label.Core_MDF_Cycle_Text + ' ' + String.valueOf(Integer.valueOf(picReview.Core_MDF_CycleNumber_nbr__c)) + ' : ';
                claim.Core_MDF_RecentInternalComments_txt__c = claim.Core_MDF_RecentInternalComments_txt__c + newline;
            }
            else
            {
                claim.Core_MDF_RecentInternalComments_txt__c = label.Core_MDF_Cycle_Text + ' ' + String.valueOf(Integer.valueOf(picReview.Core_MDF_CycleNumber_nbr__c)) + ' : ' ;
            }
        }
        
        
        //For PIC Failure Scenario
        if(picReview.Core_MDF_Review_Status_nm__c == label.Core_MDF_PICReview_Status_Failed)
        {
            //  For pre payment PIC Review
            if(claim.Core_MDF_Status__c == label.Core_MDF_Claim_Status_PIC_Pending || claim.Core_MDF_Status__c == label.Core_MDF_Claim_Status_Payment_Clearance_Processing)  //Roshan - Final Outcome Based New Status
            {
					claimUpdateOnPicFailurePrePayment(claim);                
            }//Pre Payment Ends
            // For post payment PIC Review
            if(claim.Core_MDF_Status__c == label.Core_MDF_Claim_Status_Paid_and_PIC_Pending)
            {
               claimUpdateOnPicFailurePostPayment(claim);
            }//Post Payment Ends
        }// Failure Scenario Ends
        
        // For PIC Success scenario
        else if(picReview.Core_MDF_Review_Status_nm__c == label.Core_MDF_PICReview_Status_Completed)
        {
            claimUpdateOnPicSuccess(claim);
	    
            if (claim.Core_MDF_Has_Sub_Claims_Ind__c == true && claim.Core_MDF_PIC_Review_Completed__c == true) {
                List<PartnerFundClaim> subClaims = [SELECT Id, Core_MDF_PIC_Review_Completed__c, Core_MDF_Eligible_for_PIC__c FROM PartnerFundClaim WHERE Core_MDF_Claim_Id__c = :claim.Id AND Core_MDF_PIC_Review_Completed__c = FALSE];

                for (PartnerFundClaim sub : subClaims) {
                    sub.Core_MDF_PIC_Review_Completed__c = true;
                    sub.Core_MDF_Eligible_for_PIC__c = true;
                    claimsToUpdate.add(sub);
                }
            }
            
        } // Success scenario ends
	
        claimsToUpdate.add(claim);
        if (!claimsToUpdate.isEmpty()) {
            update claimsToUpdate;
        }
        //update claim;
    }
    
    public static void claimUpdateOnPicSuccess(PartnerFundClaim claim){
        // For pre payment PIC Review for both Legacy/Non Legacy
            if(claim.Core_MDF_Status__c == label.Core_MDF_Claim_Status_PIC_Pending || claim.Core_MDF_Status__c == label.Core_MDF_Claim_Status_Payment_Clearance_Processing)  //Roshan - Final Outcome Based New Status
            {
                claim.Core_MDF_PIC_Review_Completed__c = true;
            }
            
            // For Post Payment PIC Review
            if(claim.Core_MDF_Status__c == label.Core_MDF_Claim_Status_Paid_and_PIC_Pending)
            {
                claim.Core_MDF_PIC_Review_Completed__c = true;
                claim.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Paid;
            }
    }
    public static void claimUpdateOnPicFailurePrePayment(PartnerFundClaim claim){

        if (claim.Core_MDF_OutcomeBased_Ind__c && claim.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM) {
            claim.Core_MDF_Status__c = Core_MDF_CCP_ConstantClass.PENDING_ACCOUNT_MANAGER_CLARIFICATION;
        } else {
            claim.Core_MDF_Status__c = label.Core_MDF_Claim_Status_Resubmission_Required;
        }


                //Late Claims
                if(!claim.Core_MDF_Legacy_Claim_Ind__c && claim.Core_MDF_Escalation_Id__r.Core_MDF_Escalation_Type_nm__c == label.Core_MDF_Escalation_Status_Type && !Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_LateClaimOperations'))
                {
                    claim.Core_MDF_Status__c = label.Core_MDF_Claim_Status_Resubmission_Window_Closed;
                    claim.Status = label.Core_MDF_Status_Rejected;
                }
                else if(claim.Core_MDF_Legacy_Claim_Ind__c)
                {
                    claim.Core_MDF_Legacy_Reminder_txt__c = Label.Core_MDF_Legacy_Reminder_1;
                    
                    if(claim.Core_MDF_Latest_Review_Cycle_Number_nbr__c < Integer.valueOf(label.Core_MDF_Review_Cycle_Number))
                    {
                        claim.Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c = System.now() +Integer.valueOf(Label.Core_MDF_Document_Submission_Days);
                    }
                    
                    if(claim.Core_MDF_Latest_Review_Cycle_Number_nbr__c == Integer.valueOf(label.Core_MDF_Review_Cycle_Number))
                    {
                       claim.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Denied;
                       claim.Core_MDF_Legacy_Reminder_txt__c = Label.Core_MDF_Legacy_Maximum_Attempts_Reached; //To send Denied email after 3 unsucessful attempts.
                    }
                }
            
            
    }
    public static void claimUpdateOnPicFailurePostPayment(PartnerFundClaim claim){
         claim.Core_MDF_Status__c = label.Core_MDF_Claim_Status_Paid_and_Resubmission_Required;
                
                //if(claim.Core_MDF_Legacy_Claim_Ind__c){
                    if (!claim.Core_MDF_Legacy_Claim_Ind__c) { //ATHR Fix WW19
                        return;
                    }

                    claim.Core_MDF_Legacy_Reminder_txt__c = Label.Core_MDF_Legacy_Reminder_1;
                    
                	if(claim.Core_MDF_Latest_Review_Cycle_Number_nbr__c == Integer.valueOf(label.Core_MDF_Review_Cycle_Number))
                	{
                    	claim.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Paid;
                    	claim.Core_MDF_Document_Submission_Missed_Ind__c = true;
                    	claim.Core_MDF_Legacy_Reminder_txt__c = Label.Core_MDF_Legacy_Maximum_Attempts_Reached;//To send the Final email after 30 days time period.
                	}
                    
                	if(claim.Core_MDF_Latest_Review_Cycle_Number_nbr__c < Integer.valueOf(label.Core_MDF_Review_Cycle_Number))
                	{
                    	claim.Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c = System.now() + Integer.valueOf(Label.Core_MDF_Document_Submission_Days);
                	}
                
                //}
    }

    /***************************************************************************************************** 
	Method Name:        fetchKPIFields
	Description:        To fetch the kpi fields based on program, activity category and activity type
	@Added By:          Accenture - VB - 2-07-2022
	Modified By:        Date:       Changes: 
	******************************************************************************************************/ 
    public static Set<String> fetchKPIFields(Id claimId) {
        List<CCP_Activity_Type_dependent_fields__mdt> kpiFieldsMdtList = new List<CCP_Activity_Type_dependent_fields__mdt>();
        Set<String> kpiFieldsList = new Set<String>();
        PartnerFundClaim pfc = fetchClaimRecords(claimId, false);
        kpiFieldsMdtList = [select Id, Core_MDF_Object_API_Field_Name__c from CCP_Activity_Type_dependent_fields__mdt where Core_MDF_Program_Txt__c =: pfc.Core_MDF_Program__c and Core_MDF_Activity_Category_Txt__c =: pfc.Core_MDF_Activity_Category__c and Core_MDF_Activity_Type_Txt__c =: pfc.Core_MDF_Activity_Types__c];
        if(kpiFieldsMdtList.size() > 0) {
            for(CCP_Activity_Type_dependent_fields__mdt kpiFields: kpiFieldsMdtList) {
                kpiFieldsList.add(kpiFields.Core_MDF_Object_API_Field_Name__c);
            }
        }
        if(pfc.Core_MDF_Program__c == Label.Core_MDF_SPCF_Program_Name){
            Set<String> fields = new Set<String>{'Core_MDF_NoOfTrialActivations_Nbr__c','Core_MDF_NoOfEngagements_Nbr__c','Core_MDF_NoOfLeads_Nbr__c','Core_MDF_NoOfImpressions_Nbr__c'};
            kpiFieldsList.addAll(fields);
        }
        return kpiFieldsList;
    }

    /****************************************************************************************************** 
    Method Name:        fetchExceptionsByClaimId
    @return       :     Map<Id, sObject>
    Description   :     To get potential Exception a claim could get mapped to
    @Added By:          Accenture - RP
    ******************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Map<Id, Core_MDF_Exception__c> fetchExceptionsByClaimId(Id claimId, Id corpAccountRecordId) {
        String programName = '';
        Map<Id, Core_MDF_Exception__c> exceptionMap = new Map<Id, Core_MDF_Exception__c>();
    
        try {
            PartnerFundClaim pfc = fetchClaimRecords(claimId, true);
            if (pfc != null && pfc.Core_MDF_Program__c != null) {
                /*Core_MDF_BankProgram_Entitlement_Mapping__mdt bpem = [SELECT Core_MDF_Bank_Program_Name__c, Core_MDF_Channel_Program__c FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt
                                            WHERE Core_MDF_Channel_Program__c = :pfc.Core_MDF_Program__c  LIMIT 1];*/
                Core_MDF_ChannelProgram__mdt bpem = [SELECT Label, Core_MDF_Bank_Program_Value__c FROM Core_MDF_ChannelProgram__mdt
                                            WHERE Label = :pfc.Core_MDF_Program__c  LIMIT 1];//Core_MDF_BankProgram_Entitlement_Mapping__mdt optimization
                
    
                if (bpem != null && bpem.Label != null) {
                    programName = bpem.Core_MDF_Bank_Program_Value__c;//Swati

                    String activityCategoryType = pfc.Core_MDF_Activity_Category__c + '->' + pfc.Core_MDF_Activity_Types__c;
                    if (String.isNotBlank(activityCategoryType) && pfc.Core_MDF_Activity_Start_Date__c != null && pfc.Core_MDF_Activity_End_Date__c != null) {
                        exceptionMap = fetchExceptions(pfc, programName, activityCategoryType, corpAccountRecordId);
                    }
                }
            }
    
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
        return exceptionMap;
    }
    
    private static Map<Id, Core_MDF_Exception__c> fetchExceptions(PartnerFundClaim pfc, String programName, String activityCategoryType, Id corpAccountRecordId) {
        Map<Id, Core_MDF_Exception__c> exceptionMap = new Map<Id, Core_MDF_Exception__c>();

        //Filter the Accounts based on Exception Account Mapping
        List<Id> exceptionIdList = new List<Id>();
        for(Core_MDF_Exception_Account_Mapping__c mappingRecord : [SELECT Id, Core_MDF_Exception_id__c, Core_MDF_Account_id__c, Core_MDF_Account_id__r.name  
                                                                    FROM Core_MDF_Exception_Account_Mapping__c WHERE Core_MDF_Account_id__c =: corpAccountRecordId AND Core_MDF_Active_ind__c = true]){// Inactive check //FLS //Sharing context
            exceptionIdList.add(mappingRecord.Core_MDF_Exception_id__c);
        }

        List<Core_MDF_Exception__c> exceptions = [SELECT Id, Name, Core_MDF_Exception_Start_Date_dt__c, Core_MDF_Exception_End_Date_dt__c, Core_MDF_Program_nm__c, 
                       Core_MDF_Activity_Cate_and_Type_nm__c, Core_MDF_Account_id__c, Core_MDF_Select_All_Accounts_ind__c, 
                       Core_MDF_Name_of_Exception_nm__c, Core_MDF_Exception_Reason_nm__c, Core_MDF_Budget_Type_nm__c, 
                       Core_MDF_Exception_Status_nm__c, Core_MDF_Exception_Detail_Link_txt__c
                FROM Core_MDF_Exception__c
                WHERE Core_MDF_Exception_Status_nm__c = :Label.Core_MDF_Exception_Approved_Status
                AND Core_MDF_Exception_Start_Date_dt__c <= :pfc.Core_MDF_Ad_Run_Start_Date__c
                AND Core_MDF_Exception_End_Date_dt__c >= :pfc.Core_MDF_Ad_Run_End_Date__c
                AND Core_MDF_Program_nm__c = :programName 
                AND (Core_MDF_Select_All_Accounts_ind__c = true OR Id IN: exceptionIdList) 
                ORDER BY Core_MDF_Name_of_Exception_nm__c
        ];
    
        for (Core_MDF_Exception__c exceptionRecord : exceptions) {
            if (exceptionRecord.Core_MDF_Activity_Cate_and_Type_nm__c.containsIgnoreCase(activityCategoryType)) {
                if ((exceptionRecord.Core_MDF_Budget_Type_nm__c != null && pfc.Core_MDF_Budget_Type_nm__c != null) &&
                    exceptionRecord.Core_MDF_Budget_Type_nm__c.contains(pfc.Core_MDF_Budget_Type_nm__c)) {
                        exceptionMap.put(exceptionRecord.Id, exceptionRecord);
                    } else if (String.isBlank(exceptionRecord.Core_MDF_Budget_Type_nm__c)) {
                    exceptionMap.put(exceptionRecord.Id, exceptionRecord);
                }
            }
        }
        return exceptionMap;
    }
    
/*****************************************************************************************************************************************************************
Method Name:        fetchAIResponse
Description:        method gets the latest PIC review record for a given claim and determines its availability status. 
                    AVAILABLE - if the latest review is an AI PIC review with status 'AI Failed' or 'AI Passed'. 
                    INPROGRESS - if the latest review is an AI PIC review with no status.
                    UNAVAILABLE - if there's no PIC review record, the latest review is manual, or the latest review is an AI review with any other status.
@Added By:          Accenture - Sham - 24-Sept-2025
Modified By:        Date:       Changes:
*********************************************************************************************************************************************************************/
    @AuraEnabled
     public static AIResponseWrapper fetchAIResponse(Id claimId) {
        AIResponseWrapper responseWrapper = new AIResponseWrapper();
        String aiResponse='';
        try {
            Core_MDF_PIC_Review__c latest = [
                SELECT Id, Core_MDF_AI_PIC_Review_Ind__c, Core_MDF_Review_Status_nm__c, Core_MDF_Overall_AI_Confidence_Score_Nm__c
                FROM Core_MDF_PIC_Review__c
                WHERE Core_MDF_Claim_ID_id__c = :claimId
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            if (latest == null || !latest.Core_MDF_AI_PIC_Review_Ind__c) {
                aiResponse='UNAVAILABLE';
            } else {
                String status = latest.Core_MDF_Review_Status_nm__c;
                // Using ternary logic to determine status
                aiResponse = (String.isBlank(status) ? 'INPROGRESS' : 
                                 (status == 'AI Failed'|| status == 'AI Passed') ? 'AVAILABLE' : 'UNAVAILABLE');
                
                // Only fetch results if status is AVAILABLE
                if (aiResponse == 'AVAILABLE') {
                    responseWrapper.picReviewId = latest.Id;
                    responseWrapper.overallAIConfScore = latest.Core_MDF_Overall_AI_Confidence_Score_Nm__c;
                    List<Core_MDF_PICReviewResult__c> picReviewResult = [
                        SELECT Id,Core_MDF_Question_id__c, Core_MDF_Response_txt__c, Core_MDF_Comment_txt__c, Core_MDF_PIC_Review_id__c, Core_MDF_AI_Confidence_Score_Nm__c
                        FROM Core_MDF_PICReviewResult__c
                        WHERE Core_MDF_PIC_Review_id__c = :latest.Id
                    ];
                    responseWrapper.picReviewDetails = picReviewResult;
                }
            }
            responseWrapper.status = aiResponse;
            
            return responseWrapper;
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            responseWrapper.status = 'UNAVAILABLE';
            return responseWrapper;
        }
    }
    
    
    public class QuestionWrapper{
        @auraenabled public String name{get;set;}
        @auraenabled public String id{get;set;}
        @auraenabled public list<FileDetails> fileNames{get;set;}
        @auraenabled public String fileType{get;set;}
        @auraenabled public String response{get;set;}
        @auraenabled public String questionEnglish{get;set;}
        @auraenabled public String comment{get;set;}
        @AuraEnabled public List<String> tactic{get;set;}
        @AuraEnabled public String agreementToAIResponse{get;set;}
        @AuraEnabled public String feedbackCmtToAIResponse{get;set;}
        @AuraEnabled public String aiConfidenceScore{get;set;}
        @Auraenabled public Id aiPicReviewResId{get;set;}
        
    }
    
    public class FileDetails{
        @auraenabled public String value{get;set;}
        @auraenabled public String label{get;set;}
        @auraenabled public String id{get;set;}
        @auraenabled public String originalFileName{get;set;}
        @auraenabled public String questionCode{get;set;}
        @auraenabled public Boolean selected{get;set;}
    }
    
    public class picReviewDetailsWrapper {
        @AuraEnabled
        public List<QuestionWrapper> questionData{get;set;}
        @AuraEnabled
        public string internalComments{get;set;}
        @AuraEnabled
        public Datetime startDateTime{get;set;}
        @AuraEnabled
        public Datetime endDateTime{get;set;}
        @AuraEnabled
        public Id claimId{get;set;}
        @AuraEnabled
        public Id userId{get;set;}
        @AuraEnabled
        public Boolean isReviewFailed{get;set;}
        @AuraEnabled
        public Boolean isRecommendedForAudit{get;set;}
        @AuraEnabled
        public Id latestAIPICreviewID{get;set;}
    }

    //Added by Sham 
    public class AIResponseWrapper {
    @AuraEnabled
    public Id picReviewId { get; set; }
    
    @AuraEnabled
    public String status { get; set; }
    
    @AuraEnabled
    public List<Core_MDF_PICReviewResult__c> picReviewDetails { get; set; }

    @AuraEnabled
    public String overallAIConfScore { get; set; }
    
    public AIResponseWrapper() {
        this.picReviewDetails = new List<Core_MDF_PICReviewResult__c>();
    }
}
}