public without sharing class Core_MDF_AuditDocumentHelper_Revamp {

    /*************************************************************************************************************
    Method Name : getAuditDocumentDetailsWrapper
    @return     : auditDocumentDetailsWrapper
    @parameters : recordId -> claimId, claim batch stageId
    Description : This method is to return the claim and audit document details on create/clone/edit/claim detail page and from bulk claim
    @Added By   : Accenture - VB - 28-06-2022
	Modified By :        Date:       Changes: 
    **************************************************************************************************************/
    @AuraEnabled
    public static auditDocumentDetailsWrapper getAuditDocumentDetailsWrapper(Id recordId, Boolean outComeBasedFlag){ 
        auditDocumentDetailsWrapper auditDocWrapper = new auditDocumentDetailsWrapper();
        List<Core_MDF_Audit_Document__c> auditDocList = new List<Core_MDF_Audit_Document__c>();
        List<String> claimStatusesList = System.Label.Core_MDF_Claim_Statuses_for_enabling_disabling_Buttons.split(';');
        List<String> claimSubmitterPSList = Label.Core_MDF_External_Claim_Submitter.split(';');
        PartnerFundClaim pfc = new PartnerFundClaim();
        Case caseDetail = new case();
        String sObjectName;
        Boolean isValidUser;
        String claimStatus;
        Boolean enableDocumentUploadSection = false;
        Boolean disableDocumentUploadSection = false;
        Boolean showUploadFileSection = true;
        Boolean isClaimCreate = false;
        Boolean isClaimEdit = false;
        Boolean isBulkClaim = false;
        Boolean isThirdPartyClaim = false;
        Boolean isOutcomeBased = false;
        List<String> docUploadBasedOnClaimStatus = new List<String>{'Draft', 'Resubmission Required'};//for NRE
        try {
                // check the user details and enable component
                //ATHR Fix- Deeply nested if
                if(!FeatureManagement.checkPermission(Label.Core_MDF_UploadDocs_Access)){
                    isClaimCreate = true;
                    disableDocumentUploadSection = true;
                    isOutcomeBased = outComeBasedFlag; //anushya TWC3117-14374
                }
                //if(FeatureManagement.checkPermission(Label.Core_MDF_UploadDocs_Access)){
                else{
                    if(recordId == null) { //added && anushya TWC3117-14374
                        isClaimCreate = true;
                        enableDocumentUploadSection = true;
                        //pfr = getPFRData(partnerFundReqId); //anushya TWC3117-14374
                        isOutcomeBased = outComeBasedFlag; //anushya TWC3117-14374

                    }
                    //if(recordId != null) {
                    else{
                        //get object name
                        sObjectName = recordId.getSObjectType().getDescribe().getName();
                        if(sObjectName == Label.Core_MDF_PFCText) {
                            isClaimEdit = true;
                            //get claim data
                            pfc = getClaimData(recordId);
                            //get Audit Documents -claim edit/claim detail page
                            if(pfc != null){
                                claimStatus = pfc.Core_MDF_Status__c;
                                isThirdPartyClaim = pfc.Core_MDF_3rd_Party_POP_Doc_Required_Ind__c;
                                auditDocList = getAuditDocumentDetails(recordId);
                                isOutcomeBased = pfc.Request.Core_MDF_Is_Outcome_Based_Ind__c; 
                            }
                        
                            //Enable upload button based on Claim Status and PIC Review Completion
                            if (!claimStatusesList.contains(claimStatus) && !pfc.Core_MDF_PIC_Review_Completed__c && pfc.Core_MDF_Claim_Id__c == NULL){
                                if(pfc.Core_MDF_Program__c == Label.Core_MDF_IPA_Program_Name) {
                                    if(UserInfo.getUserType() == 'PowerPartner') {
                                        //ATHR Fix- Deeply nested if
                                        /*if(((pfc.RecordType.developername == Label.Core_MDF_IPA_AccountBased_RecType_DevName && FeatureManagement.checkPermission('Core_MDF_CCP_External_IPA_Account_Based_User') && !pfc.Core_MDF_Proposal_Based_Ind__c) ||
                                        (pfc.RecordType.developername == Label.Core_MDF_IPA_RecordType && FeatureManagement.checkPermission('Core_MDF_CCP_External_IPA_Proposal_Based_User') && pfc.Core_MDF_Proposal_Based_Ind__c))){
                                            enableDocumentUploadSection = true;
                                                                } else {
                                                                    enableDocumentUploadSection = false;
                                                                }*/
                                        enableDocumentUploadSection = ((pfc.RecordType.developername == Label.Core_MDF_IPA_AccountBased_RecType_DevName && FeatureManagement.checkPermission('Core_MDF_CCP_External_IPA_Account_Based_User') && !pfc.Core_MDF_Proposal_Based_Ind__c) || (pfc.RecordType.developername == Label.Core_MDF_IPA_RecordType && FeatureManagement.checkPermission('Core_MDF_CCP_External_IPA_Proposal_Based_User') && pfc.Core_MDF_Proposal_Based_Ind__c));
                                    } else {
                                        enableDocumentUploadSection = true;
                                    }
                                } else if(pfc.Core_MDF_Program__c == 'Co-GTM') {
                                    enableDocumentUploadSection = docUploadBasedOnClaimStatus.contains(claimStatus) ? true : false;
                                }else {
                                    enableDocumentUploadSection = true;
                                }
                            } else {
                                disableDocumentUploadSection = true;
                            }
                        } else if(sObjectName == 'Core_MDF_Claim_Batch_Stage__c') {
                            isClaimCreate = true;
                            isBulkClaim = true;
                            enableDocumentUploadSection = true;
                        } else {
                            isClaimCreate = true;
                            enableDocumentUploadSection = true;
                        }
                    } /*else {
                        isClaimCreate = true;
                        enableDocumentUploadSection = true;
                    }*/
                } /*else {
                    isClaimCreate = true;
                    disableDocumentUploadSection = true;
                }*/
                //stamp data on wrapper
                auditDocWrapper.claimStatus = claimStatus;
                auditDocWrapper.documentList = auditDocList;
                auditDocWrapper.sObjName = sObjectName;
                auditDocWrapper.enableDocumentUploadSection = enableDocumentUploadSection;
                auditDocWrapper.pfcRec = pfc;
                auditDocWrapper.showUploadFileSection = showUploadFileSection;
                auditDocWrapper.isClaimCreate = isClaimCreate;
                auditDocWrapper.isClaimEdit = isClaimEdit;
                auditDocWrapper.isBulkClaim = isBulkClaim;
                auditDocWrapper.isThirdPartyClaim = isThirdPartyClaim;
                auditDocWrapper.disableDocumentUploadSection = disableDocumentUploadSection;
                auditDocWrapper.isOutComeBased = isOutcomeBased;
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
        return auditDocWrapper;
    }

    /*************************************************************************************************************
    Method Name : getClaimData
    @return     : PartnerFundClaim Record
    @parameters : claimId
    Description : This method is to return the claim details based on the claim Id
    @Added By   : Accenture - VB - 28-06-2022
	Modified By :        Date:       Changes: 
    **************************************************************************************************************/
    public static PartnerFundClaim getClaimData(Id claimId) {
        PartnerFundClaim pfc = new PartnerFundClaim();
        pfc = [SELECT Id,RecordType.DeveloperName, Core_MDF_Program__c, Core_MDF_Budget_Type_Options_Nm__c, Request.Core_MDF_Budget_Type_nm__c,Core_MDF_Claim_Review_Case__c,Core_MDF_Budget_Type_Nm__c,Core_MDF_3rd_Party_POP_Doc_Required_Ind__c,
                                Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c,Core_MDF_Status__c,Core_MDF_Document_Hold_Ind__c, Core_MDF_Document_Hold_Eligibility_Ind__c,Core_MDF_Audit_Hold__c,Core_MDF_Audit_Type__c,Core_MDF_PIC_Review_Completed__c,
                                Core_MDF_Total_Invoice_Amount_Local__c, Core_MDF_OtherCostsnotReimbursable_Local__c,Core_MDF_Reimbursable_TransactionAmt_Loc__c,Core_MDF_Taxes_Local__c,Core_MDF_Country_Location_nm__c,Core_MDF_Legacy_Claim_Ind__c,
                                Core_MDF_Currency__c,CreatedDate,Core_MDF_Reimbursement_Percent__c,Core_MDF_Requested_Reimbursement_Amt__c,Core_MDF_Audit_Adjustment_Amount__c,Core_MDF_Reimbursable_Transaction_Amount__c,Amount,Core_MDF_Activity_Types__c,Core_MDF_Escalation_Id__c,Core_MDF_Ad_Run_Start_Date__c,
                                Core_MDF_Ultimate_Account_ID__c,Core_MDF_Media_Vehicle__c,Core_MDF_Target_Audience__c,RequestId,Core_MDF_AccountCompany__c,Core_MDF_Invoice_Number__c,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Activity_Category__c, Core_MDF_Claim_Id__c, Request.Core_MDF_Is_Outcome_Based_Ind__c
                                FROM PartnerFundClaim WHERE Id =: claimId limit 1];
        return pfc;
    }

    /*************************************************************************************************************
    Method Name : getAuditDocumentDetails
    @return     : AuditDocumentDetails Record
    @parameters : claimId
    Description : This method is to return the audit document details based on the claim Id
    @Added By   : Accenture - VB - 28-06-2022
	Modified By :        Date:       Changes: 
    **************************************************************************************************************/
    public static List<Core_MDF_Audit_Document__c> getAuditDocumentDetails(Id claimId) {
        List<Core_MDF_Audit_Document__c> auditDocList = new List<Core_MDF_Audit_Document__c>();
        auditDocList = [SELECT Id, Core_MDF_Audit__c, Core_MDF_App_Document_Types_nm__c, Core_MDF_Applicable_Document_Types_txt__c, Core_MDF_Selected_Document_Types_txt__c, Core_MDF_Claim__c, Core_MDF_Document_Id__c, Core_MDF_Document_Title__c,
                                            Core_MDF_Document_Types__c FROM Core_MDF_Audit_Document__c WHERE (Core_MDF_Claim__c != null AND Core_MDF_Claim__c =: claimId)];
        return auditDocList;
    }

    /*************************************************************************************************************
    Method Name : fetchMetaDataRecords
    @return     : List<Core_MDF_POP_Document_Types_Revamp__mdt>
    @parameters : ProgramName and BudgetType
    Description : This method returns the list of pop document types metadata based on the program and budget type(create/clone/edit/bulk claim)
    @Added By   : Accenture - VB - 28-06-2022
	Modified By :        Date:       Changes: 
    **************************************************************************************************************/
    @AuraEnabled
    public static List<Core_MDF_POP_Document_Types_Revamp__mdt> fetchMetaDataRecords(string programName, string budgetType) {
        // Creating instance of metadataWrapper
        MetadataWrapper popWrapper = new MetadataWrapper();
        List<Core_MDF_POP_Document_Types_Revamp__mdt> popMetadata = new List<Core_MDF_POP_Document_Types_Revamp__mdt>();
        popWrapper.metadataWrapperList = [SELECT Core_MDF_Program_nm__c, Core_MDF_RecordType_DeveloperName_txt__c,
                                        Core_MDF_Budget_Type_txt__c, Core_MDF_ApplicableToAll_BudgetTypes_Ind__c,
                                        Core_MDF_Active_ind__c, Core_MDF_ReqforPOPSubmission_ind__c, Core_MDF_Order_nbr__c,
                                        Core_MDF_Document_Type_nm__c, toLabel(Core_MDF_Document_Type_nm__c) Document_Type_Label, Core_MDF_Req_Doc_Types_ind__c FROM 
                                        Core_MDF_POP_Document_Types_Revamp__mdt WHERE Core_MDF_Active_ind__c = true and Core_MDF_Program_nm__c =:  programName order by Core_MDF_Order_nbr__c];
        for(Core_MDF_POP_Document_Types_Revamp__mdt mdt: popWrapper.metadataWrapperList) {
            if((mdt.Core_MDF_Budget_Type_txt__c == budgetType || mdt.Core_MDF_ApplicableToAll_BudgetTypes_Ind__c)) {
                popMetadata.add(mdt);
            }
        }
        return popMetadata; 
    }

    /*************************************************************************************************************
    Method Name : insertAuditDocumentAndContentDocumentLink
    @return     : void
    @parameters : auditDocumentListToInsertOrUpdate, recordId - claimId, switchClaimStatusToPICPending
    Description : This method is to insert/update the audit document and claim details
    @Added By   : Accenture - VB - 28-06-2022
	Modified By :        Date:       Changes: 
    **************************************************************************************************************/
    @AuraEnabled
    public static void insertAuditDocumentAndContentDocumentLink(List<auditDocumentWrapper> auditDocumentListToInsertOrUpdate , Id recordId, Boolean switchClaimStatusToPICPending) {
        List<ContentDocumentLink> conDocLinksToBeInserted = new List<ContentDocumentLink>();
        List<Core_MDF_Audit_Document__c> auditDocList = new List<Core_MDF_Audit_Document__c>();
        Boolean pfcOnDocHold = false;
        Map<Id, PartnerFundClaim> claimIdToClaimRecMap = new Map<Id, PartnerFundClaim>();//AI PIC
         PartnerFundClaim pfc;//Moved from claim block to here as part of AI PIC changes
        try {
            if(auditDocumentListToInsertOrUpdate != null && auditDocumentListToInsertOrUpdate.size() > 0) {
                for(auditDocumentWrapper auditDocWrapper : auditDocumentListToInsertOrUpdate) {
                    if(auditDocWrapper.isNewDocument) {
                        auditDocWrapper.auditDocument.Core_MDF_Claim__c = recordId;
                        //content Document link
                        ContentDocumentLink conDocLink = new ContentDocumentLink();
                        conDocLink.ContentDocumentId = auditDocWrapper.auditDocument.Core_MDF_Document_Id__c;
                        conDocLink.ShareType='I';
                        conDocLink.Visibility='AllUsers';
                        conDocLink.LinkedEntityId = auditDocWrapper.auditDocument.Core_MDF_Claim__c;
                        conDocLinksToBeInserted.add(conDocLink);
                        auditDocList.add(auditDocWrapper.auditDocument);
                    } else {
                        auditDocWrapper.auditDocument.Core_MDF_Claim__c = recordId;
                        auditDocList.add(auditDocWrapper.auditDocument);
                    }
                }
            }

            if(recordId != null){
                String recId = String.valueof(recordId);
                String sObjectName = recordId.getSObjectType().getDescribe().getName();
                //Added claim condition to make it usable for claim also
                //ATHR Fix- Deeply nested if  
                if(sObjectName == Label.Core_MDF_PFCText){
                    pfc = [SELECT Id,Core_MDF_Claim_Review_Case__c, Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c, 
                                            Core_MDF_Audit_Hold__c, Core_MDF_Audit_Type__c, Core_MDF_FlaggedForAudit__c, Core_MDF_Status__c,
                                            Core_MDF_Document_Hold_Ind__c,Core_MDF_Document_Hold_Eligibility_Ind__c,Core_MDF_RMF_Last_POP_Submission_Dt__c,
                                            Core_MDF_Manaul_Audit_Staging_Ind__c,Core_MDF_ESD_Hold__c,Core_MDF_Payment_Hold_ind__c, 
                                            Core_MDF_Criteria_Hold_Ind__c, Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c, 
                                            Core_MDF_VAT_Hold_Ind__c,Core_MDF_Claim_Previous_Status__c, Core_MDF_Bank_Doc_Hold_Ind__c, Core_MDF_Eligible_for_PIC__c, Core_MDF_Budget_Type_Nm__c, Core_MDF_Budget_Type_Options_Nm__c, Core_MDF_Program__c, Core_MDF_OutcomeBased_Ind__c, Core_MDF_3rd_Party_POP_Doc_Required_Ind__c,
                                            Core_MDF_Ad_Run_Start_Date__c, Core_MDF_Ad_Run_End_Date__c, Core_MDF_Reimbursable_TransactionAmt_Loc__c, Core_MDF_Total_Invoice_Amount_Local__c, Core_MDF_Currency__c, Core_MDF_Activity_Types__c, CreatedDate,Request.Core_MDF_Is_Outcome_Based_Ind__c, Request.Core_MDF_Activity_Description__c, Request.Core_MDF_POP_Requirements_txt__c, Request.Core_MDF_Attribution_Requirements_txt__c, Amount
                                            FROM PartnerFundClaim 
                                            WHERE Id =:recId];//query updated for AI PIC
                }//ATHR Fix- Deeply nested if                    
                    //Changing of status when documents are submitted                        
                if(pfc!=null && switchClaimStatusToPICPending && (pfc.Core_MDF_Status__c == label.Core_MDF_Claim_Status_Resubmission_Required || pfc.Core_MDF_Status__c == label.Core_MDF_Claim_Status_Pending_Documents || pfc.Core_MDF_Status__c == Core_MDF_CCP_ConstantClass.PENDING_ACCOUNT_MANAGER_CLARIFICATION))//ATHR Fix- Deeply nested if
                        {
                            pfc.Core_MDF_Status__c = pfc.Request.Core_MDF_Is_Outcome_Based_Ind__c == TRUE ? Label.Core_MDF_Claim_Status_Payment_Clearance_Processing : Label.Core_MDF_Claim_Status_PIC_Pending; //Pic-Pop Changes Anushya
                            pfc.Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c  = null;
                            pfc.Core_MDF_Legacy_Reminder_txt__c = '';
                            Database.update(pfc);  
                        }
                        
                        // For post payment Manual Audit
                if(pfc!=null && switchClaimStatusToPICPending&& (pfc.Core_MDF_Status__c == label.Core_MDF_Claim_Status_Paid_and_Pending_Documents  || pfc.Core_MDF_Status__c == label.Core_MDF_Claim_Status_Paid_and_Resubmission_Required))//ATHR Fix- Deeply nested if
                        {
                            pfc.Core_MDF_Status__c =  label.Core_MDF_Claim_Status_Paid_and_PIC_Pending;
                            pfc.Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c  = null;
                            pfc.Core_MDF_Legacy_Reminder_txt__c = ''; 
                            Database.update(pfc);   
                }
                claimIdToClaimRecMap.put(pfc.Id, pfc);
            }

			if(auditDocList != NULL && auditDocList.size() > 0) {
                Database.upsert(auditDocList); 
                updateLastPOPDocDateOnClaim(auditDocList);
        }

            if(conDocLinksToBeInserted.size() > 0){
                Database.insert(conDocLinksToBeInserted);
            }

            //Added by VB - AI PIC
            try 
            {
                 if(!(Core_MDF_Claim_Utility.bypassCDBCalloutValidationCheck('Core_MDF_ProcessClaimsWithAIForPICReview','Core_MDF_Bypass_AI_CDB_CallForClaims'))) {

                    if(Core_MDF_Claim_Utility.isClaimEligibleForAICDBCallout(pfc)) {
                        Core_MDF_AI_Integration_Outbound.generateAIResponseForPICProcess(claimIdToClaimRecMap, 'update');            
                    }
                }
            }
            catch (Exception e) {
              Core_MDF_CCP_UtilityClass.logError(e);
            }
            
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*************************************************************************************************************
    Method Name : updateLastPOPDocDateOnClaim
    @return     : void
    @parameters : auditDocList
    Description : This method is to update the 'Core_MDF_RMF_Last_POP_Submission_Dt__c' of claim either on 
                    uploading a new audit document or on editing the existing one
    @Added By   : Accenture - VB - 28-06-2022
	Modified By :        Date:       Changes: 
    **************************************************************************************************************/
    public static void updateLastPOPDocDateOnClaim(list<Core_MDF_Audit_Document__c> auditDocList){
        Map<Id,PartnerFundClaim> pfcMap = new Map<Id,PartnerFundClaim>();
        try{
            for(Core_MDF_Audit_Document__c auditDoc : [SELECT Id, CreatedDate, Core_MDF_Claim__c, Core_MDF_Claim__r.Core_MDF_RMF_Last_POP_Submission_Dt__c
                                                       FROM Core_MDF_Audit_Document__c WHERE Id IN: auditDocList  ORDER BY CreatedDate Desc]){
                                                           
                                                           Date auditCreatedDate = date.newinstance(auditDoc.CreatedDate.year(), auditDoc.CreatedDate.month(), auditDoc.CreatedDate.day());
                                                           if((auditDoc.Core_MDF_Claim__r.Core_MDF_RMF_Last_POP_Submission_Dt__c == null || auditCreatedDate > auditDoc.Core_MDF_Claim__r.Core_MDF_RMF_Last_POP_Submission_Dt__c) && !pfcMap.containsKey(auditDoc.Core_MDF_Claim__c)){
                                                               PartnerFundClaim pfc = new PartnerFundClaim();
                                                               pfc.Id = auditDoc.Core_MDF_Claim__c;
                                                               pfc.Core_MDF_RMF_Last_POP_Submission_Dt__c = auditCreatedDate;
                                                               pfcMap.put(pfc.Id,pfc);
                                                           }                                                         
                                                       }
            if(pfcMap != null && pfcMap.size() >0){Database.update(pfcMap.values());}
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }

    /*************************************************************************************************************
    Method Name : deleteDocumentIds
    @return     : void
    @parameters : docId, claimId
    Description : This method is to delete the auditDocument and associated content document link based on the docId
    @Added By   : Accenture - VB - 28-06-2022
	Modified By :        Date:       Changes: 
    **************************************************************************************************************/
    @AuraEnabled
    public static void deleteDocumentIds(String docId)
    {
        List<ContentDocument> contentDocumentIdToDelete = new List<ContentDocument>();
        try{
            if (String.isNotBlank(docId)){
                Id documentId = Id.valueOf(docId);
                removeDocIdfromAITracking(documentId);
                contentDocumentIdToDelete = [SELECT Id FROM ContentDocument WHERE Id =: docId];
                if (contentDocumentIdToDelete != null && contentDocumentIdToDelete.size() > 0){
                    Database.delete(contentDocumentIdToDelete);
                }
            }
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
        
    }


    /*************************************************************************************************************
    Method Name : checkClaimStatusForPICProcess
    @return     : True/False
    @parameters : claimId
    Description : This method is to check on whether the claim status is resubmission required/paid and resubmission required or not
    custom label: Core_MDF_ClaimStatus_For_PICProcess - Resubmission Required;Paid and Resubmission Required
    @Added By   : Accenture - VB - 12-06-2022
	Modified By :        Date:       Changes: 
    Roshan: added Pending Account Manager Clarification status in Core_MDF_SubmitForPIC_ClaimStatus for IPA Outcome - based claims
    **************************************************************************************************************/
    @AuraEnabled
    public static ClaimPICStatusWrapper checkClaimStatusForPICProcess(Id claimId){
    
        ClaimPICStatusWrapper wrapper = new ClaimPICStatusWrapper();
        List<String> claimStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SubmitForPIC_ClaimStatus').split(';');
        PartnerFundClaim pfc = new PartnerFundClaim();
        try {
            pfc = [select Id, Core_MDF_Status__c, Core_MDF_Eligible_for_PIC__c, Request.Core_MDF_Is_Outcome_Based_Ind__c from PartnerFundClaim where Id =: claimId];
            
            wrapper.isOutcomeBased = pfc.Request.Core_MDF_Is_Outcome_Based_Ind__c;
            if(pfc.Core_MDF_Eligible_for_PIC__c == true && claimStatus.contains(pfc.Core_MDF_Status__c)){
                wrapper.isClaimAvailableForPIC = true;
            } else {
                wrapper.isClaimAvailableForPIC = false;
            }
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); throw new AuraHandledException(e.getMessage()); }

        return wrapper;
    }

    /*************************************************************************************************************
    Method Name : isValidThirdPartyPOPClaim
    @return     : wrapperThirdPartyPOP
    @parameters : PartnerFundClaim
    Description : This method is to check on whether the claim belongs to 3rd party or not - third party rule engine call
    @Added By   : Accenture - VB - 28-06-2022
	Modified By :        Date:       Changes: 
    **************************************************************************************************************/
    @AuraEnabled
    public static wrapperThirdPartyPOP isValidThirdPartyPOPClaim(PartnerFundClaim pfc, String amountFields){
        
        //Assign Amount field values to fix issue with Amount fields for localized users(Portugese, Brazil and Italian)
        if(String.isNotBlank(amountFields)) {
            Core_MDF_PartnerFundClaim.AmountFieldsWrapper parsedAmountFields = (Core_MDF_PartnerFundClaim.AmountFieldsWrapper) JSON.deserialize(amountFields, Core_MDF_PartnerFundClaim.AmountFieldsWrapper.class);  
            if(parsedAmountFields.totalAmountLocal != null)
                pfc.Core_MDF_Total_Invoice_Amount_Local__c = Decimal.valueOf(parsedAmountFields.totalAmountLocal);
                
            if(parsedAmountFields.costNotReimbursable != null)
                pfc.Core_MDF_OtherCostsnotReimbursable_Local__c = Decimal.valueOf(parsedAmountFields.costNotReimbursable);
                
            if(parsedAmountFields.taxesLocal != null)
                pfc.Core_MDF_Taxes_Local__c = Decimal.valueOf(parsedAmountFields.taxesLocal);
        }

        wrapperThirdPartyPOP thirdPartyWrapper = new wrapperThirdPartyPOP();
        
        try{
            List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
            Map<string,List<sobject>> inputForRuleEngine= new Map<string,List<sobject>>();
            Map<String,Map<String,Core_MDF_Rules_Engine.RulesEngineParams>> ruleEngineResult = new  Map<String,Map<String,Core_MDF_Rules_Engine.RulesEngineParams>>();

            //Exclude RMF program from 3rd Party Rule Engine check
            List<String> thirdPartyRuleCheckExclusionProgramList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_3rdPartyRuleCheckExclusionPrgms');
            if(String.isNotBlank(pfc.Core_MDF_Program__c) && !thirdPartyRuleCheckExclusionProgramList.contains(pfc.Core_MDF_Program__c)){
                claimListToBeProcessed.add(pfc);
            }

            if(claimListToBeProcessed!=null && claimListToBeProcessed.size()>0){
                Core_MDF_Claim_Utility.calculateClaimAmtFieldsOnInsert(claimListToBeProcessed);  
                getGeoAndSubGeo(claimListToBeProcessed); 
                inputForRuleEngine.put('Third Party',claimListToBeProcessed);
                ruleEngineResult = Core_MDF_Rules_Engine.executeRulesByObjects(inputForRuleEngine); // try excepetion if rule engin fails : what will be falge and rule id value
            }       	
            
            if(!ruleEngineResult.isEmpty() &&  ruleEngineResult.containsKey('Third Party')){
                Map<String,Core_MDF_Rules_Engine.RulesEngineParams> rule1 = ruleEngineResult.get('Third Party');
                for(String thirdPartyPOP : rule1.keySet()){
                    if(rule1.get(thirdPartyPOP).result){
                        thirdPartyWrapper.isThirdPartyPOP = true;
                        thirdPartyWrapper.ruleId =rule1.get(thirdPartyPOP).ruleRecord.Name;                    
                    }
                    else{
                        thirdPartyWrapper.isThirdPartyPOP = false;
                    }
                }
            }
        }catch (Exception e) { 
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
        return thirdPartyWrapper;
    }

    /*************************************************************************************************************
    Method Name : getGeoAndSubGeo
    @return     : void
    @parameters : newclaimList
    Description : This method is to update the region and sub region of claim
    @Added By   : Accenture - VB - 28-06-2022
	Modified By :        Date:       Changes: 
    **************************************************************************************************************/
    public static void getGeoAndSubGeo(List<PartnerFundClaim> newclaimList){
        // update Region field according to country on claim record
        Map<String,Core_MDF_CCP_GenericUtility.countryGeoSubGeoWrapper> wrapperMapOfCountryRegion = new Map<String,Core_MDF_CCP_GenericUtility.countryGeoSubGeoWrapper>();        
        wrapperMapOfCountryRegion = Core_MDF_CCP_GenericUtility.getCountryGeoMap();
        if(newclaimList != NULL && newclaimList.size() > 0){
            for(PartnerFundClaim pfc : newclaimList){
                pfc.Core_MDF_Region_Cd__c = wrapperMapOfCountryRegion.get(pfc.Core_MDF_Country_Location_nm__c).geo;
                pfc.Core_MDF_Sub_Region_Cd__c = wrapperMapOfCountryRegion.get(pfc.Core_MDF_Country_Location_nm__c).subGeo;
            }
        }
    }
     /*************************************************************************************************************
    Method Name : getClaimAndUserDetails
    @return     : True/False
    Description : Method to fetch User and Claim details (submit for PIC quick action)
    @Added By:        Accenture - JK - 11-18-2024
	Modified By:        Date:       Changes: 
    **************************************************************************************************************/
    @AuraEnabled
    public static submitForPICWrapper getClaimAndUserDetails(Id claimId){
        submitForPICWrapper wrapper = new submitForPICWrapper();
        Boolean isValidUser = false;
        try {
            wrapper.isValidClaimUser = FeatureManagement.checkPermission(Label.Core_MDF_SubmitForPICAccess);
            if(wrapper.isValidClaimUser) {
                ClaimPICStatusWrapper picWrapper = checkClaimStatusForPICProcess(claimId);
                wrapper.isClaimEligibleForPIC = picWrapper.isClaimAvailableForPIC;
                wrapper.isOutComeBased = picWrapper.isOutcomeBased;
                wrapper.AreDocsAvailable = fetchAuditDocuments(claimId);
            }

        } catch (Exception e) {Core_MDF_CCP_UtilityClass.logError(e);throw new AuraHandledException(e.getMessage());}
        return wrapper;
    }

     /*************************************************************************************************************
    Method Name : fetchAuditDocuments
    Description : This method is get the list of claim review documents
    @Added By:        Accenture - JK - 11-18-2024
	Modified By:        Date:       Changes: 
    **************************************************************************************************************/
    @AuraEnabled
    public static Boolean fetchAuditDocuments(Id claimId){
        Boolean AreDocsAvailable = false;
       // MetadataWrapper mdtList = new MetadataWrapper();
        PartnerFundClaim pfc = new PartnerFundClaim();
        List<Core_MDF_Audit_Document__c> auditDocumentList = new List<Core_MDF_Audit_Document__c>();
        List<Core_MDF_Audit_Document__c> finalDocumentList = new List<Core_MDF_Audit_Document__c>();
        Set<String> selectedDocumentTypes = new Set<String>();
        Set<String> availableDocumentTypes = new Set<String>();
        List<String> docTypeReqForAllBudTypePrograms = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DocTypeReqForAllBudTypePrograms').split(';');
        try {
            auditDocumentList = getAuditDocumentDetails(claimId);
            pfc = [select Id, Core_MDF_Status__c, Core_MDF_Program__c, Core_MDF_Budget_Type_Nm__c, Core_MDF_Budget_Type_Options_Nm__c, Core_MDF_Legacy_Claim_Ind__c from PartnerFundClaim where Id =: claimId limit 1];
           List<Core_MDF_POP_Document_Types_Revamp__mdt> mdtList = fetchMetaDataRecords (pfc.Core_MDF_Program__c,pfc.Core_MDF_Budget_Type_Nm__c);
            for(Core_MDF_POP_Document_Types_Revamp__mdt mdt: mdtList) {
                availableDocumentTypes.add(mdt.Core_MDF_Document_Type_nm__c);
            }
            if(auditDocumentList.size() > 0) {
                for(Core_MDF_Audit_Document__c auditDoc: auditDocumentList) {
                    if(auditDoc.Core_MDF_Document_Types__c == null || auditDoc.Core_MDF_App_Document_Types_nm__c == null) {
                        continue;//ATHR Fix- Deeply nested if
                    }//ATHR Fix- Deeply nested if
                        if(auditDoc.Core_MDF_Document_Types__c.contains(';')) {
                            selectedDocumentTypes.addAll(auditDoc.Core_MDF_Document_Types__c.split(';'));
                        } else {
                            selectedDocumentTypes.add(auditDoc.Core_MDF_Document_Types__c);
                        }
                            finalDocumentList.add(auditDoc);
                    }
                }
           if(finalDocumentList.size() > 0 && selectedDocumentTypes.equals(availableDocumentTypes)) {
                AreDocsAvailable = true;
            } else {
                AreDocsAvailable = false;
            }
        } catch (Exception e) {Core_MDF_CCP_UtilityClass.logError(e);throw new AuraHandledException(e.getMessage());}
        return AreDocsAvailable;
    }
     /*************************************************************************************************************
    Method Name : updateClaimStatus
    Description : This method is to update the claim status to PIC Pending/Paid and PIC pending(confirmation popup - submit for PIC)
    @Added By:        Accenture - VB - 2-03-2022
	Modified By: Jahnavi K       Date:    11-19-2024   Changes: 
    **************************************************************************************************************/
    @AuraEnabled
    public static void updateClaimStatus(Id claimId){
        PartnerFundClaim pfc = new PartnerFundClaim();
        Map<Id, PartnerFundClaim> claimIdToClaimRecMap = new Map<Id, PartnerFundClaim>();//AI PIC
        try {
            pfc = [select Id, Core_MDF_Status__c, Core_MDF_Budget_Type_Nm__c, Core_MDF_Budget_Type_Options_Nm__c, Core_MDF_Program__c, Core_MDF_OutcomeBased_Ind__c, Core_MDF_3rd_Party_POP_Doc_Required_Ind__c,
                    Core_MDF_Ad_Run_Start_Date__c, Core_MDF_Ad_Run_End_Date__c, Core_MDF_Reimbursable_TransactionAmt_Loc__c, Core_MDF_Total_Invoice_Amount_Local__c, Core_MDF_Currency__c,
                    Core_MDF_Activity_Types__c,createdDate, Request.Core_MDF_Is_Outcome_Based_Ind__c, request.Core_MDF_Activity_Description__c, request.Core_MDF_POP_Requirements_txt__c, request.Core_MDF_Attribution_Requirements_txt__c, Amount from PartnerFundClaim where Id =: claimId limit 1];//query updated for AI PIC

            if(pfc.Core_MDF_Status__c == Label.Core_MDF_Claim_Status_Resubmission_Required || pfc.Core_MDF_Status__c == Label.Core_MDF_Claim_Status_Pending_Documents || pfc.Core_MDF_Status__c == Core_MDF_CCP_ConstantClass.PENDING_ACCOUNT_MANAGER_CLARIFICATION) {

                //Roshan - Final Outcome Based New Status
                pfc.Core_MDF_Status__c = pfc.Request.Core_MDF_Is_Outcome_Based_Ind__c == TRUE ? Label.Core_MDF_Claim_Status_Payment_Clearance_Processing : Label.Core_MDF_Claim_Status_PIC_Pending;
                pfc.Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c  = null;
                pfc.Core_MDF_Legacy_Reminder_txt__c = '';
            } 
            else if(pfc.Core_MDF_Status__c == Label.Core_MDF_Claim_Status_Paid_and_Resubmission_Required || pfc.Core_MDF_Status__c == Label.Core_MDF_Claim_Status_Paid_and_Pending_Documents) {
                pfc.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Paid_and_PIC_Pending;
                pfc.Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c  = null;
                pfc.Core_MDF_Legacy_Reminder_txt__c = '';
            } 
            Database.update(pfc);

            //Added by VB - AI PIC
            try 
            {
                if(!(Core_MDF_Claim_Utility.bypassCDBCalloutValidationCheck('Core_MDF_ProcessClaimsWithAIForPICReview','Core_MDF_Bypass_AI_CDB_CallForClaims'))) {
                    claimIdToClaimRecMap.put(claimId, pfc);
                    
                    if(Core_MDF_Claim_Utility.isClaimEligibleForAICDBCallout(pfc)) {
                        Core_MDF_AI_Integration_Outbound.generateAIResponseForPICProcess(claimIdToClaimRecMap, 'update');  
                    }
                }
            } catch (Exception e) {
                Core_MDF_CCP_UtilityClass.logError(e);
            }
        } catch (Exception e) {Core_MDF_CCP_UtilityClass.logError(e);throw new AuraHandledException(e.getMessage());}
    
    }
    /*********************************************************************************************************************************
    Method Name : removeDocIdfromAITracking
    @return     : void
    @parameters : docId
    Description : This method is to query on the AI Tracking and remove the doc, where a doc was uploaded on 1st page using Claim Ezy 
				  and removed later on 3rd page while claim creation.
    @Added By   : Ayush - 22-11-2024
	Modified By :        Date:       Changes: 
    **********************************************************************************************************************************/
    public static void removeDocIdfromAITracking(Id docId){
        if(Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_ClaimEzyEnabled') && docId != null){//ATHR Fix- Deeply nested if
            //if(docId != null){
                List<Core_MDF_AI_Tracking__c> aiTrackList = new List<Core_MDF_AI_Tracking__c>();
                for(Core_MDF_AI_Tracking__c aiTrack : [Select id,Core_MDF_Content_Document_Id__c from Core_MDF_AI_Tracking__c where Core_MDF_Content_Document_Id__c =: docId and Core_MDF_Claim_Id__c = null LIMIT 1]){
                    aiTrack.Core_MDF_Content_Document_Id__c = '';
                    aiTrackList.add(aiTrack);
                }
                if(!aiTrackList.isEmpty() && aiTrackList.size() > 0){
                    update aiTrackList;
            }
        }
    }

     // wrapper class with @AuraEnabled
     //POP Document Types Wrapper
     public class MetadataWrapper{
        @AuraEnabled
        public List<Core_MDF_POP_Document_Types_Revamp__mdt> metadataWrapperList;
    }

    // Audit Document Details wrapper
    public class auditDocumentDetailsWrapper{
        @AuraEnabled
        public String claimStatus{get;set;}
        @AuraEnabled
        public List<Core_MDF_Audit_Document__c> documentList{get;set;}
        @AuraEnabled
        public String sObjName{get;set;}
        @AuraEnabled
        public Boolean enableDocumentUploadSection{get;set;}
        @AuraEnabled
        public PartnerFundClaim pfcRec{get;set;}
        @AuraEnabled
        public Boolean showUploadFileSection{get;set;}
        @AuraEnabled
        public Boolean isClaimCreate{get;set;}
        @AuraEnabled
        public Boolean isClaimEdit{get;set;}
        @AuraEnabled
        public Boolean disableDocumentUploadSection{get;set;}
        @AuraEnabled
        public Boolean isBulkClaim{get;set;}
        @AuraEnabled
        public Boolean isThirdPartyClaim{get;set;}
        @AuraEnabled
        public Boolean isOutComeBased{get;set;} 
    }

    // audit document wrapper - claim detail page
    public class auditDocumentWrapper {
        @AuraEnabled
        public Boolean isNewDocument{get;set;}
        @AuraEnabled
        public Core_MDF_Audit_Document__c auditDocument{get;set;}
    }

    //third party wrapper
    public class wrapperThirdPartyPOP{
        @AuraEnabled public string ruleId;
        @AuraEnabled public boolean isThirdPartyPOP; 
    }
    //as part of WW05 ,Pop Document metadata clean up
    public class submitForPICWrapper{
        @AuraEnabled
        public Boolean isValidClaimUser;
        @AuraEnabled
        public Boolean isClaimEligibleForPIC;
        @AuraEnabled
        public Boolean AreDocsAvailable;
        @AuraEnabled
        public Boolean isOutComeBased;
    }

    public class ClaimPICStatusWrapper{
        @AuraEnabled
        public Boolean isClaimAvailableForPIC;
        @AuraEnabled
        public Boolean isOutComeBased;
    }
}