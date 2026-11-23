/****************************************************************************************************************************************
* Class Name        : Core_MDF_CampaignPFR_Controller
* Created Date      : 5/20/2020
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VK       5/20/2020          Server side controller for Core_MDF_DisplayActivities
*****************************************************************************************************************************************/
public without sharing class Core_MDF_CampaignPFR_Controller {
    public static Id ipaCampaignRecordId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
    public static Id coGTMCampaignRecordId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();  //Roshan - added CoGTM for customer approval
    public static String extUserType = Core_MDF_CCP_ConstantClass.Ext_UserType;
    public static String pendingStatus = Core_MDF_CCP_ConstantClass.PFR_PENDING_STATUS;
    public static String priceReviewer = Core_MDF_CCP_ConstantClass.PRICE_REVIEWER;
    public static String l1Approval = Core_MDF_CCP_ConstantClass.L1_APPROVAL;
    public static String l2RegionalSales = Core_MDF_CCP_ConstantClass.L2_REGIONAL_SALES;
    public static String l2RegionalMarketing = Core_MDF_CCP_ConstantClass.L2_REGIONAL_MARKETING;
    public static String progOfficeReviewer = Core_MDF_CCP_ConstantClass.PROGRAM_OFFICE_REVIEWER;
    public static String legalReviewer = Core_MDF_CCP_ConstantClass.LEGAL_REVIEWER;  //Roshan - Co-GTM campaign setup 
    public static String l2Approval = Core_MDF_CCP_ConstantClass.L2_APPROVAL;  //Roshan - Co-GTM campaign setup (use L2 Sales or create separate for CoGTM?)
    public static String pendingReviewStatus = Core_MDF_CCP_ConstantClass.CAMPAIGN_PENDING_REVIEW;
    public static String pendingApprovalStatus = Core_MDF_CCP_ConstantClass.CAMPAIGN_PENDING_APPROVAL;
    public static String businessApprover = Core_MDF_CCP_ConstantClass.BUSINESS_APPROVER;  //Aditya
    public static String technicalApprover = Core_MDF_CCP_ConstantClass.Technical_Approver;  //Roshan - Co-GTM Claim
    public static String accountManagerApprover = Core_MDF_CCP_ConstantClass.Account_Manager;  //Swati - IPA Claim
    public static String ipaProgram = Core_MDF_CCP_ConstantClass.IPA_PROGRAM;  // Roshan 
    

    /***************************************************************************************************** 
    Method Name :   getActivityRecords
    @return     :   List of Activities 
    @parameters :   Campaign Id
    Description :   It fetches all activities for a given campaign
    Added By    :   Accenture - VK - 5/20/2020 
    Modified By :                               Date:                   Changes:
    ******************************************************************************************************/ 
    
    @AuraEnabled
    public static List<PartnerFundRequest> getActivityRecords(Id recordId){
        
        try{
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        
            if(recordId != NULL){
                pfrList = [SELECT Id, CampaignId, RecordType.Name, RecordType.DeveloperName, RecordTypeId,Title,    
                           Description, Core_MDF_Start_Date__c, Core_MDF_End_Date__c, Core_MDF_Priorities__c, ChannelPartnerId, 
                           Core_MDF_Channel_Partner_Led__c, Campaign.Core_MDF_Claims_Created_Ind__c, 
                           Core_MDF_Budget_Currency_cd__c, Core_MDF_Budget_Amount_Local_amt__c, RequestedAmount, Core_MDF_TargetAudience__c,
                           Core_MDF_ProductType__c,Core_MDF_Brand_Nm__c, Core_MDF_ActivityCategory__c, Core_MDF_Activity_Types__c,
                           Core_MDF_Activity_SubType_nm__c, Core_MDF_Fund_Request_Status__c, Core_MDF_Country_nm__c,
                           Core_MDF_Channel_Partner__c, Core_MDF_Budget_Type_nm__c, Core_MDF_Activity_Number__c, 
                           Core_MDF_PFRDetailLink__c,Core_MDF_PFRRecordCommunityLink__c, Core_MDF_Proposal_Based_Ind__c,
                           toLabel(Core_MDF_Fund_Request_Status__c) activityStatus
                           FROM PartnerFundRequest
                           WHERE CampaignId =: recordId];
            }
            if(pfrList.Size() == 0){
                 pfrList = null;
            }
            
            return pfrList;            
        }catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e); 
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            pfrList = null;
            return pfrList;
        } 
    }
 
    @AuraEnabled
    public static Boolean isAccountBased(Id recordId){
        boolean accountbased = true;
        try{
            List<Campaign> campList = new List<Campaign>();
            if(recordId != NULL){
                campList = [Select Id,Core_MDF_Program__c,Core_MDF_Proposal_Based_Ind__c
                            FROM Campaign
                            WHERE Id =: recordId];  
                if(campList.Size() > 0){
                    if(campList[0].Core_MDF_Program__c == 'Intel Partner Alliance'  && campList[0].Core_MDF_Proposal_Based_Ind__c == true ) {
                        accountbased = false;
                    }
                }
            }
            
            return accountbased;
        }catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e); 
            return accountbased;
        }
    } 
        
    /***************************************************************************************************** 
    Method Name :   checkUserType
    @return     :   EditActivityWrapper
    @parameters :   Campaign Id
    Description :   It determines whether logged in user is internal/external and whether he can create claim and edit activity
    Added By    :   Accenture - VK - 5/20/2020 
    Modified By :                               Date:                   Changes:
    ******************************************************************************************************/ 
    @AuraEnabled
    public static EditActivityWrapper checkUserType(Boolean isProposalBased){
        
        EditActivityWrapper wrapper = new EditActivityWrapper();
        try {
            //Edit Activity
            Schema.DescribeSObjectResult pfr = Schema.sObjectType.PartnerFundRequest;
            if(pfr.isUpdateable()){
                wrapper.activityEditAccess = TRUE;
            }else{
                wrapper.activityEditAccess = FALSE; 
            }

            //Create Claim
            Schema.DescribeSObjectResult pfc = Schema.sObjectType.PartnerFundClaim;
            if(UserInfo.getUserType() == 'PowerPartner') {
                if(pfc.isCreateable() && ((FeatureManagement.checkPermission('Core_MDF_CCP_External_IPA_Account_Based_User') && !isProposalBased) ||
                                          (FeatureManagement.checkPermission('Core_MDF_CCP_External_IPA_Proposal_Based_User') && isProposalBased))){
                                              wrapper.claimCreateAccess = TRUE;
                                          } else {
                                              wrapper.claimCreateAccess = FALSE;
                                          }
            } else {
                if(pfc.isCreateable()){
                    wrapper.claimCreateAccess = TRUE;
                }else{
                    wrapper.claimCreateAccess = FALSE; 
                }     
            }    
            
            //Internal or External User
            if(UserInfo.getUserType() == 'PowerPartner'){
                wrapper.isInternalUser = FALSE;
            }else{
                wrapper.isInternalUser = TRUE;
            }
            wrapper.hasIPAAccountManagerPS = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_IPA_Acct_Mgr') ? true : false;
            
            return wrapper;
        }     
        catch (Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            return wrapper;
        }
    } 

    /***************************************************************************************************** 
    Method Name :   isActiveClaimAssociated
    return     :   Boolean
    @parameters :   List of Campaign ID
    Description :   It determines whether a campaign has active claim association or not
    Added By    :   Accenture - NB - 1/12/2023 
    Modified By :                               Date:                   Changes:
    ******************************************************************************************************/ 
    @AuraEnabled
    public static Boolean isActiveClaimAssociated(List<Id> cmpClaimAssocList) {
        Boolean isActiveClaimExist = false;
        Map<Id,List<PartnerFundClaim>> campClaimAssocMap = Core_MDF_Proposal_Based_Campaign_Process.checkClaimsAssociatedToCampaign(cmpClaimAssocList);  //Roshan - Campaign trigger optimisation
        if(campClaimAssocMap!=null && campClaimAssocMap.size()>0 && campClaimAssocMap.containsKey(cmpClaimAssocList[0]) && campClaimAssocMap.get(cmpClaimAssocList[0])!=null && campClaimAssocMap.get(cmpClaimAssocList[0]).size()>0){
            isActiveClaimExist = true;
        }
        else{
            isActiveClaimExist = false;
        }
        return isActiveClaimExist;
    }

    public static Boolean isCustomPermissionAssigned(String customPermissionNameStr){
        Boolean userHasPer = false;
        if(customPermissionNameStr != NULL && String.isNotBlank(customPermissionNameStr)){
            userHasPer =  FeatureManagement.checkPermission(customPermissionNameStr);
        }
        return userHasPer;
    }
    
    @AuraEnabled
    public static EditActivityWrapper loadCampRecord(Id cmpId) {

        //Roshan - Co-GTM claim setup
        if (String.valueOf(cmpId).startsWith('0RB')) {
            return loadClaimRecord(cmpId);
        }

        EditActivityWrapper userPermissionApprovalCamp = new EditActivityWrapper();
        try{
            List<Campaign> cmpval = new List<Campaign>();
            if(cmpId != null ) {

                cmpval = [SELECT Id,Core_MDF_Host_Region_cd__c,Core_MDF_Ultimate_Account_txt__c,Core_MDF_Region_cd__c,Core_MDF_Sub_Region_cd__c, 
                            Core_MDF_Budget_Type_txt__c, Core_MDF_Proposal_Based_Ind__c, Core_MDF_Program__c, Core_MDF_Market__c, Status,
                            Core_MDF_Approval_Stage_nm__c, Core_MDF_Account__c,recordtype.developername, RecordTypeId, Core_MDF_IPA_Approval_Status_nm__c,Core_MDF_Total_Campaign_Cost_Amt__c
                            FROM Campaign WHERE Id =: cmpId];
                
                if(cmpval.Size() > 0) {
                    userPermissionApprovalCamp.campaignRecord = cmpval[0];
                    userPermissionApprovalCamp.piwitmGlb = fetchPiwitmId(cmpId);

                    List<String> ctryList = new List<String>();
                    if(cmpval[0].Core_MDF_Market__c != null && cmpval[0].Core_MDF_Market__c.contains(';')) {
                        ctryList.addAll(cmpval[0].Core_MDF_Market__c.split(';'));
                    } else {
                        ctryList.add(cmpval[0].Core_MDF_Market__c);
                    }
                    
                    if(cmpval[0].Core_MDF_Approval_Stage_nm__c != null) {
                        if(cmpval[0].Core_MDF_Approval_Stage_nm__c == priceReviewer && cmpval[0].Core_MDF_IPA_Approval_Status_nm__c !=pendingApprovalStatus) {
                            userPermissionApprovalCamp.isUserPCTApprover = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(cmpval[0], userInfo.getUserId());
                        } else if(cmpval[0].Core_MDF_Approval_Stage_nm__c == progOfficeReviewer && cmpval[0].Core_MDF_IPA_Approval_Status_nm__c !=pendingApprovalStatus) {
                             userPermissionApprovalCamp.isUserPORApprover = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(cmpval[0], userInfo.getUserId());
                        } else if(cmpval[0].Core_MDF_Approval_Stage_nm__c == l1Approval) {
                            userPermissionApprovalCamp.isUserL1Approver = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(cmpval[0], userInfo.getUserId());
                        } else if(cmpval[0].Core_MDF_Approval_Stage_nm__c == l2RegionalMarketing) {
                            userPermissionApprovalCamp.isUserL2MarketingApprover = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(cmpval[0], userInfo.getUserId());
                        } else if(cmpval[0].Core_MDF_Approval_Stage_nm__c == l2RegionalSales) {
                            userPermissionApprovalCamp.isUserL2SalesApprover = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(cmpval[0], userInfo.getUserId());
                        } else if(cmpval[0].Core_MDF_Approval_Stage_nm__c == legalReviewer) {
                            userPermissionApprovalCamp.isUserLegalReviewer = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(cmpval[0], userInfo.getUserId());
                        } else if(cmpval[0].Core_MDF_Approval_Stage_nm__c == l2Approval) {
                            userPermissionApprovalCamp.isUserL2Approver = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(cmpval[0], userInfo.getUserId());
                        }  else if(cmpval[0].Core_MDF_Approval_Stage_nm__c == businessApprover) {
                            userPermissionApprovalCamp.isUserBusinessApprover = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(cmpval[0], userInfo.getUserId());  //Aditya
                        }
                    }

                    if(cmpval[0].Status == pendingReviewStatus && isCustomPermissionAssigned('Core_MDF_PriceReviewer') && userPermissionApprovalCamp.isUserPCTApprover) {
                        userPermissionApprovalCamp.isPriceReviewer = true; 
                    } else { userPermissionApprovalCamp.isPriceReviewer = false; }
                    if(cmpval[0].Status == pendingReviewStatus && isCustomPermissionAssigned('Core_MDF_CCP_Int_IPA_ProposalL1_Approver') && userPermissionApprovalCamp.isUserL1Approver) { 
                        userPermissionApprovalCamp.isL1ProposalApprover = true; 
                    } else { userPermissionApprovalCamp.isL1ProposalApprover = false; }
                    if(cmpval[0].Status == pendingReviewStatus && isCustomPermissionAssigned('Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver') && userPermissionApprovalCamp.isUserL2MarketingApprover) { 
                        userPermissionApprovalCamp.isL2ProposalMarketingApprover = true; 
                    } else { userPermissionApprovalCamp.isL2ProposalMarketingApprover = false; }
                    if(cmpval[0].Status == pendingReviewStatus && isCustomPermissionAssigned('Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver') && userPermissionApprovalCamp.isUserL2SalesApprover) { 
                        userPermissionApprovalCamp.isL2ProposalSalesApprover = true; 
                    } else { userPermissionApprovalCamp.isL2ProposalSalesApprover = false; }
                    if(cmpval[0].Status == pendingReviewStatus && isCustomPermissionAssigned('Core_MDF_CCP_Internal_Proposal_Activity_POR_Approver') && userPermissionApprovalCamp.isUserPORApprover) {
                         userPermissionApprovalCamp.isPORApprover = true; 
                    } else { userPermissionApprovalCamp.isPORApprover = false; }
                    if (cmpval[0].Status == pendingReviewStatus && isCustomPermissionAssigned('Core_MDF_CCP_Internal_Co_GTM_Legal_Reviewer') && userPermissionApprovalCamp.isUserLegalReviewer) {
                        userPermissionApprovalCamp.isLegalReviewer = true; 
                    } else { userPermissionApprovalCamp.isLegalReviewer = false; }
                    if (cmpval[0].Status == pendingReviewStatus && isCustomPermissionAssigned('Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver') && userPermissionApprovalCamp.isUserL2Approver) {
                        userPermissionApprovalCamp.isL2Approver = true; 
                    } else { userPermissionApprovalCamp.isL2Approver = false; }
                    if (cmpval[0].Status == pendingReviewStatus && isCustomPermissionAssigned('Core_MDF_PriceReviewer') && userPermissionApprovalCamp.isUserBusinessApprover) {  //Aditya
                        userPermissionApprovalCamp.isBusinessApprover = true;
                    } else { userPermissionApprovalCamp.isBusinessApprover = false; }
                  
                    //visibility of recall button for internal proposal manager
                    if ((cmpval[0].Status == pendingReviewStatus || cmpval[0].Status == pendingApprovalStatus) && ((cmpval[0].RecordTypeId == ipaCampaignRecordId && isCustomPermissionAssigned('Core_MDF_CCP_Internal_IPA_Acct_Mgr')) || (cmpVal[0].RecordTypeId == coGTMCampaignRecordId &&  isCustomPermissionAssigned('Core_MDF_CCP_Internal_Co_GTM_Account_Manager')))) {
                        userPermissionApprovalCamp.isInternalProposalManager = true;
                        if(cmpval[0].Core_MDF_Approval_Stage_nm__c == l1Approval && isCustomPermissionAssigned('Core_MDF_CCP_Int_IPA_ProposalL1_Approver')) {
                            userPermissionApprovalCamp.isInternalProposalManager = false; 
                        } else if ((cmpval[0].Core_MDF_Approval_Stage_nm__c == priceReviewer || cmpval[0].Core_MDF_Approval_Stage_nm__c == businessApprover) && isCustomPermissionAssigned('Core_MDF_PriceReviewer')) {  //Aditya
                            userPermissionApprovalCamp.isInternalProposalManager = false; 
                        } else if (cmpval[0].Core_MDF_Approval_Stage_nm__c == progOfficeReviewer && isCustomPermissionAssigned('Core_MDF_CCP_Internal_Proposal_Activity_POR_Approver')) {
                            userPermissionApprovalCamp.isInternalProposalManager = false; 
                        } else if ((cmpval[0].Core_MDF_Approval_Stage_nm__c == l2RegionalMarketing || cmpval[0].Core_MDF_Approval_Stage_nm__c == l2RegionalSales) && isCustomPermissionAssigned('Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver')){
                            userPermissionApprovalCamp.isInternalProposalManager = false; 
                        } else if (cmpval[0].Core_MDF_Approval_Stage_nm__c == legalReviewer && isCustomPermissionAssigned('Core_MDF_CCP_Internal_Co_GTM_Legal_Reviewer')) {
                            userPermissionApprovalCamp.isInternalProposalManager = false; 
                        } else if (cmpval[0].Core_MDF_Approval_Stage_nm__c == l2Approval && isCustomPermissionAssigned('Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver')) {   
                            userPermissionApprovalCamp.isInternalProposalManager = false; 
                        }
                    } else { 
                        userPermissionApprovalCamp.isInternalProposalManager = false; 
                    }
                    
                    //visibility of recall button for external proposal manager
                    if(cmpval[0].Status == pendingReviewStatus && (isCustomPermissionAssigned('Core_MDF_CCP_External_IPA_Proposal_Manager') || isCustomPermissionAssigned('Core_MDF_CCP_External_Co_GTM_Project_Submitter'))){
                        userPermissionApprovalCamp.isExternalManager = true;
                    } else {
                        userPermissionApprovalCamp.isExternalManager = false;
                    }  
                        
                    if (cmpval[0] != null && ((cmpval[0].RecordTypeId == ipaCampaignRecordId || cmpVal[0].RecordTypeId == coGTMCampaignRecordId) && cmpval[0].Core_MDF_Proposal_Based_Ind__c == true) 
                        && cmpval[0].Status == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Approval_Nm')) {
                        if ((isCustomPermissionAssigned('Core_MDF_ExternalProposalApprover')||isCustomPermissionAssigned('Core_MDF_CCP_External_Co_GTM_Project_Approver') ) && UserInfo.getUserType() == extUserType) {
                            userPermissionApprovalCamp.userPermissionsPowerPartner = true;
                        } else {
                            userPermissionApprovalCamp.userPermissionsPowerPartner = false;
                        }
                    }
                }

                //Indicates if active claims is assocated for a specified campaignId
                List<Id> cmpClaimAssocList = new List<Id>();
                cmpClaimAssocList.add(cmpId);
                userPermissionApprovalCamp.isActiveClaimExist = isActiveClaimAssociated(cmpClaimAssocList); 
            }

        } catch(Exception e) {
            String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); 
            Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails, 'Campaign');                  
        }
        return userPermissionApprovalCamp;
    }

    //Roshan - Co-GTM claim setup
    private static EditActivityWrapper loadClaimRecord(Id claimId) {

        EditActivityWrapper wrapper = new EditActivityWrapper();
        try {
            PartnerFundClaim claim = [SELECT Id, Title, Core_MDF_Program__c, ChannelPartner.Name, Core_MDF_Status__c, RecordType.DeveloperName, Core_MDF_Ultimate_Account_ID__c, Core_MDF_Budget_Type_Nm__c, 
                                        Core_MDF_Proposal_Based_Ind__c, Core_MDF_Campaign_Id__r.Core_MDF_Program__c, Core_MDF_Campaign_Id__r.Core_MDF_Region_cd__c, Core_MDF_Approval_Stage_nm__c, Core_MDF_Campaign_Id__r.Core_MDF_CampOutcomeOpt_In_Ind__c, Core_MDF_Campaign_Id__r.Core_MDF_Host_Region_cd__c, Request.Core_MDF_Host_Region_txt__c, ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c
                                        FROM PartnerFundClaim WHERE Id =: claimId LIMIT 1];  //Roshan

            wrapper.claimRecord = claim;
            wrapper.piwitmGlb = fetchPiwitmId(claimId);
            
            if (claim.Core_MDF_Approval_Stage_nm__c != null) {
                if (claim.Core_MDF_Approval_Stage_nm__c == technicalApprover) {
                    wrapper.isUserTechnicalApprover = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(claim, UserInfo.getUserId());  //Roshan
                } else if (claim.Core_MDF_Approval_Stage_nm__c == accountManagerApprover) {
                    wrapper.isUserAccountManagerApprover = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(claim, UserInfo.getUserId());  //Swati
                }
            }

            if (claim.Core_MDF_Status__c == pendingReviewStatus && isCustomPermissionAssigned('Core_MDF_CCP_Internal_Co_GTM_Technical_Approver') && wrapper.isUserTechnicalApprover) {
                wrapper.isTechnicalApprover = true; 
            } else { wrapper.isTechnicalApprover = false; }
            if (claim.Core_MDF_Status__c == pendingReviewStatus && (isCustomPermissionAssigned('Core_MDF_CCP_Internal_IPA_Acct_Mgr') && !isCustomPermissionAssigned('Core_MDF_CCP_Internal_CSC_Claim_Submitter')) && wrapper.isUserAccountManagerApprover) { 
                wrapper.isAccountManagerApprover = true; 
            } else { wrapper.isAccountManagerApprover = false; }


            // Recall button visibility - separate for cogtm and outcomebased
            if (claim.Core_MDF_Status__c == pendingReviewStatus ) {

                if (isCustomPermissionAssigned('Core_MDF_CCP_External_Co_GTM_Claim_Submitter') || isCustomPermissionAssigned('Core_MDF_IPAClaimSubmitter')) {
                    wrapper.isExternalClaimSubmitter = true;
                } else { wrapper.isExternalClaimSubmitter = false; }  
    
                if (claim.Core_MDF_Program__c == ipaProgram && (isCustomPermissionAssigned('Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager') || isCustomPermissionAssigned('Core_MDF_CCP_Internal_Claim_Case_Reviewer') || isCustomPermissionAssigned('Core_MDF_CCP_Internal_CSC_Claim_Submitter'))) {
                    wrapper.isInternalClaimSubmitter = true;
                } else { wrapper.isInternalClaimSubmitter = false; } 

            }

        } catch (Exception e) {
            String err = Core_MDF_CCP_UtilityClass.getErrorDetails(e);
            Core_MDF_CCP_UtilityClass.logErrorinLogObject(err, 'PartnerFundClaim');
        }
        return wrapper;
    }

    // Roshan - moving common ProcessInstanceWorkItem query into a helper method
    private static Id fetchPiwitmId(Id recordId) {
        List<ProcessInstanceWorkItem> piwitmList = [
            SELECT Id FROM ProcessInstanceWorkItem
            WHERE ProcessInstance.Status = :pendingStatus AND ProcessInstance.TargetObjectId = :recordId LIMIT 1
        ];
        return (piwitmList.isEmpty()) ? null : piwitmList[0].Id;
    }
    
    @AuraEnabled
    public static ApproveRejectWrapper approveRejectProposal(string buttonName, Id cmpId, string approvalComments, Id piwitmId, Boolean terminalRejectionInd)
    {
        List<Id> cmpIds = new List<Id>();
        List<Campaign> cmpsToBeUpdated = new List<Campaign>();
        ApproveRejectWrapper appRejObj = new ApproveRejectWrapper();
        appRejObj.isExternalUser = UserInfo.getUserType() == extUserType ? true : false;
        String msg='';
        String propApprovalComments = approvalComments;
        Savepoint sp = Database.setSavepoint();
        try{

            //Roshan - Co-GTM claim setup
            if (String.valueOf(cmpId).startsWith('0RB')) {
                return approveRejectClaim(buttonName, cmpId, approvalComments, piwitmId, false);
            }

            Campaign cmpInst = [Select Id, Core_MDF_Comments_Appvr_Only_txt__c, Status,Core_MDF_Approval_Stage_nm__c,Core_MDF_Completed_Approval_Level_Nm__c
                                FROM Campaign 
                                WHERE Id =:cmpId];
            cmpIds.add(cmpId);
            
            List <ProcessInstanceWorkItem> processInstanceList = [SELECT ProcessInstance.TargetObjectId, Id FROM ProcessInstanceWorkItem WHERE Id =: piwitmId AND ProcessInstance.Status = 'Pending'];
            
            if(processInstanceList != null && !processInstanceList.isEmpty()) {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
    
                if (buttonName == Label.Core_MDF_Retail_Approve) {
                    req.setComments(propApprovalComments);
                    req.setAction('Approve');    
                }
                if (buttonName == Label.Core_MDF_Retail_Reject) {          
                    req.setComments(propApprovalComments);
                    req.setAction('Reject');     
                }
                if (buttonName == Label.Core_MDF_Activity_Recall_Nm) { 
                    cmpInst.status = 'Revision Required';
                    cmpInst.Core_MDF_Last_Rejected_Level_Nm__c = cmpInst.Core_MDF_Approval_Stage_nm__c;
                    if(String.isBlank(propApprovalComments)) {
                        propApprovalComments = 'Recalled';
                    }
                    else {
                        propApprovalComments = 'Recalled - ' + propApprovalComments;
                    }
                    req.setComments(propApprovalComments);
                    req.setAction('Reject'); 
                }

                cmpInst.Core_MDF_Comments_Appvr_Only_txt__c = propApprovalComments;
                cmpInst.Core_MDF_Terminal_Rejection_Ind__c = terminalRejectionInd;

                cmpsToBeUpdated.add(cmpInst);
                if(cmpsToBeUpdated != NULL && !cmpsToBeUpdated.isEmpty()){
                    Database.update(cmpsToBeUpdated);             
                }
                approveOrRejectWorkItem(cmpInst.Id, req, appRejObj);
            } else {
                appRejObj.isSuccess = false;
                appRejObj.returnMessage = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Another_User_Responded');
                appRejObj.type = 'warning';
            }
        } catch (Exception e) {
            handleApprovalException(e, cmpIds, 'approveRejectProposal Method', appRejObj, sp);
        }
        return appRejObj;
    }

    //Roshan - Co-GTM claim setup
    private static ApproveRejectWrapper approveRejectClaim(String buttonName, Id claimId, String approvalComments, Id piwitmId, Boolean terminalRejectionInd) {
        ApproveRejectWrapper appRejObj = new ApproveRejectWrapper();

        List<Id> claimIds = new List<Id>();
        List<PartnerFundClaim> claimsToBeUpdated = new List<PartnerFundClaim>();
        String propApprovalComments = approvalComments;
        String msg='';
        Savepoint sp = Database.setSavepoint();

        try {
            PartnerFundClaim claimInst = [SELECT Id, Core_MDF_Status__c, Core_MDF_Comments_Appvr_Only_txt__c, Core_MDF_Campaign_Id__r.Core_MDF_CampOutcomeOpt_In_Ind__c, Core_MDF_OutcomeBased_Ind__c FROM PartnerFundClaim WHERE Id = :claimId];  //Roshan
            claimIds.add(claimId);
            
            List <ProcessInstanceWorkItem> processInstanceList = [SELECT ProcessInstance.TargetObjectId, Id FROM ProcessInstanceWorkItem WHERE Id =: piwitmId AND ProcessInstance.Status = 'Pending'];
            
            if(processInstanceList != null && !processInstanceList.isEmpty()){
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
    
                if (buttonName == Label.Core_MDF_Retail_Approve){
                    req.setComments(propApprovalComments);
                    req.setAction('Approve');    
                }

                if (buttonName == Label.Core_MDF_Retail_Reject){          
                    req.setComments(propApprovalComments);
                    req.setAction('Reject'); 
                    if(claimInst.Core_MDF_OutcomeBased_Ind__c) {  //Roshan
                        claimInst.Core_MDF_Status__c = 'Pending Clarification';  
                    } 
                }
                
                if (buttonName == Label.Core_MDF_Activity_Recall_Nm){ 
                    if(String.isBlank(propApprovalComments)) {
                        propApprovalComments = 'Recalled';
                    } else {
                        propApprovalComments = 'Recalled - ' + propApprovalComments;
                    }
                    req.setComments(propApprovalComments);
                    req.setAction('Reject');
                    if(claimInst.Core_MDF_OutcomeBased_Ind__c) {  //Roshan
                        claimInst.Core_MDF_Status__c = 'Resubmission Required';   
                    } 
                }

                claimInst.Core_MDF_Comments_Appvr_Only_txt__c = propApprovalComments;
                claimsToBeUpdated.add(claimInst);
                
                if(claimsToBeUpdated != NULL && !claimsToBeUpdated.isEmpty()){
                    Database.update(claimsToBeUpdated);             
                }
                approveOrRejectWorkItem(claimInst.Id, req, appRejObj);

            } else {
                appRejObj.isSuccess = false;
                appRejObj.returnMessage = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Another_User_Responded');
                appRejObj.type = 'warning';
            }
        } catch (Exception e) {
            handleApprovalException(e, claimIds, 'approveRejectClaim Method', appRejObj, sp);
        }
        return appRejObj;
    }

    // Roshan - moving common approval process call ito a helper method
    private static void approveOrRejectWorkItem(Id targetRecordId, Approval.ProcessWorkitemRequest req, ApproveRejectWrapper appRejObj) {

        ProcessInstanceWorkItem piwitm = [SELECT ProcessInstance.TargetObjectId, Id FROM ProcessInstanceWorkItem 
                                            WHERE ProcessInstance.TargetObjectId = :targetRecordId AND ProcessInstance.Status = 'Pending' LIMIT 1];
        req.setWorkitemId(piwitm.Id);
        
        // Submit the request for approval
        Approval.ProcessResult result = Approval.process(req);

        if (result != null) {
            appRejObj.isSuccess = true;
            appRejObj.returnMessage = '';
        }
    }

    // Roshan - moving duplicate error logging logic into a helper method
    private static void handleApprovalException(Exception e, List<Id> recordIds, String methodName, ApproveRejectWrapper wrapper, Savepoint sp) {
        String msg = e.getMessage();
        String logerror = '';
        logerror += 'CAMPAIGN/CLAIM IDs' + String.join(recordIds, ',->');
        logerror += e.getLineNumber() + '->';
        logerror += msg + '->';
        Core_MDF_CCP_UtilityClass.logErrorinLogObject(logerror, methodName);

        String errorMessage = '';
        String FIELD_VALIDATION = Label.Core_MDF_Error_code;
        if (msg.contains(FIELD_VALIDATION)) {
            String[] errorMsg = msg.split(FIELD_VALIDATION + ',');
            String rightStr = errorMsg[1].right(errorMsg[1].indexOf('.:'));
            errorMessage = errorMsg[1].left(rightStr.length()).trim() + '.';
        } else {
            errorMessage = Label.Core_MDF_ApplicationErrorMessage;
        }

        wrapper.isSuccess = false;
        wrapper.returnMessage = errorMessage;
        wrapper.type = 'error';

        Database.rollback(sp);
    }

    /***************************************************************************************************** 
    Class Name    :        EditActivityWrapper
    Description   :        contains all the wrapper variables
    Added By      :        Accenture - VK - 5/20/2020
    Modified By   :        Date:       Changes: 
    ******************************************************************************************************/
    public class EditActivityWrapper{
        @AuraEnabled
        public Boolean isPriceReviewer = false;
        @AuraEnabled
        public Boolean isUserPCTApprover = false;
        @AuraEnabled
        public Boolean isUserL1Approver = false;
        @AuraEnabled
        public Boolean isUserL2MarketingApprover = false;
        @AuraEnabled
        public Boolean isUserL2SalesApprover = false;
        @AuraEnabled
        public Boolean isUserPORApprover = false;
        @AuraEnabled
        public Boolean activityEditAccess;
        @AuraEnabled
        public Boolean isInternalUser;
        @AuraEnabled
        public Boolean claimCreateAccess;
        @AuraEnabled
        public Boolean userPermissionsPowerPartner;
        @AuraEnabled
        public Boolean isL1ProposalApprover=false;
        @AuraEnabled
        public Boolean isL2ProposalSalesApprover=false;
        @AuraEnabled
        public Boolean isL2ProposalMarketingApprover=false;
        @AuraEnabled// Progran Office Reviewer
        public Boolean isPORApprover=false;
        @AuraEnabled
        public Boolean isInternalProposalManager = false;
        @AuraEnabled
        public Boolean isExternalManager = false;
        @AuraEnabled
        public Campaign campaignRecord;
        @AuraEnabled
        public Id piwitmGlb;
        @AuraEnabled
        public Boolean isActiveClaimExist = false;
        //Roshan - Co-GTM campaign setup
        @AuraEnabled
        public Boolean isUserLegalReviewer = false;
        @AuraEnabled
        public Boolean isLegalReviewer = false;
        @AuraEnabled
        public Boolean isUserL2Approver = false;
        @AuraEnabled
        public Boolean isL2Approver = false;
        //Aditya
        @AuraEnabled
        public Boolean isUserBusinessApprover = false;
        @AuraEnabled
        public Boolean isBusinessApprover = false;
        //Roshan - Co-GTM claim setup
        @AuraEnabled
        public PartnerFundClaim claimRecord;
        @AuraEnabled
        public Boolean isUserTechnicalApprover = false;
        @AuraEnabled
        public Boolean isTechnicalApprover = false;
        //Swati - IPA Claim
        @AuraEnabled
        public Boolean isUserAccountManagerApprover = false;
        @AuraEnabled
        public Boolean isAccountManagerApprover = false;
        @AuraEnabled
        public Boolean isExternalClaimSubmitter = false;
        @AuraEnabled
        public Boolean isInternalClaimSubmitter = false;
        //Ramapriya - In-Progress Edit Button Visibility
        @AuraEnabled
        public Boolean hasIPAAccountManagerPS = false;
    }
    
    public class ApproveRejectWrapper{
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public string type;
        @AuraEnabled
        public string returnMessage;
        @AuraEnabled
        public Boolean isExternalUser;
    }
}