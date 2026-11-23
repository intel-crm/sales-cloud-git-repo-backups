public without sharing class Core_MDF_PFR_Approval
{  
    static final String APPROVE_BUTTON = 'Approve';
    static final String DECLINE_BUTTON = 'Decline';
    /*****************************************************************************************************
Method Name : loadPFRRecord
@return     : Object
@parameters : PFR Record
Description : US106541 - Create Activity initial screen
Added By    : Sridhar on 3-Jun-2020
Modified By : Nuzhath Zaiba                  Date:  14/11/2019                  Changes:None
              Ramapriya                 07-25-2025                          Added status check as part of In-progress Activity Edit 
******************************************************************************************************/
    @AuraEnabled
    public static userPermissionApproval loadPFRRecord(String pfrId)
    {
        userPermissionApproval userPermissionApprovalPFR = new userPermissionApproval();
        userPermissionApprovalPFR.isUserPCTApprover = false;
         // ** NEW DUAL-ROLE PROPERTY **
        userPermissionApprovalPFR.isIPAAccountMgrAndPCTApprover = false;
        List<String> pfrIds = new List<String>();
       try{
        pfrIds.add(pfrId);
        List<String> ccfDcfProgramStrList = new List<String>();
        ccfDcfProgramStrList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCFDCF_RecordType_API_Name').split(',');
        List<String> opalBudgetTypeList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_OPAL_BudgetTypes').Split(';');  
        Boolean isLoggedInUserApprover = false;
        // US949836 : New Budget Type field changes replaced txt field with new global picklist field
        // US1072007 : [RMF] - Ability for RSM to Edit an Activity when in Geo Lead's Queue
            PartnerFundRequest pfrval= new PartnerFundRequest();
            List<PartnerFundRequest> pfrvalList = [SELECT Id,Core_MDF_Activity_CreatedByExternalUsr__c,Core_MDF_L1_Approver_Id__c,
                                                   Core_MDF_Approval_Step_Completed__c,ChannelPartnerId,Core_MDF_Host_Region_or_Region_txt__c,
                                                   ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Country_nm__c,
                                                   Core_MDF_Approval_Status_Stage_txt__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Region_nm__c,
                                                   Core_MDF_Fund_Request_Status__c,Core_MDF_Activity_Closure_Type__c,
                                                   recordtype.developername,Core_MDF_Program__c,Core_MDF_Activity_Classification_nm__c,Core_MDF_Proposal_Based_Ind__c,
                                                   Core_MDF_Approval_Stage__c,Core_MDF_Host_Region_txt__c,Campaign.Core_MDF_Account__r.Id,Core_MDF_Campaign_Ultimate_Account_Id__c,
                                                   Core_MDF_Ultimate_Account_Id__c,Core_MDF_Sub_Region_nm__c,Core_MDF_Additional_Review_Type_txt__c
                                                FROM PartnerFundRequest 
                                               where Id IN: pfrIds LIMIT 1];
        if(pfrvalList != null && !pfrvalList.isEmpty()){
           pfrval = pfrvalList[0];
        }        
      /* ProcessInstanceWorkItem piwitm = [SELECT ProcessInstance.TargetObjectId, Id 
                                                  FROM ProcessInstanceWorkItem
                                                  WHERE ProcessInstance.Status = 'Pending' AND
                                                      ProcessInstance.TargetObjectId =: pfrId LIMIT 1];*/
        
         List<ProcessInstanceWorkItem> piwitmList = [SELECT ProcessInstance.TargetObjectId, Id 
                                                  FROM ProcessInstanceWorkItem
                                                  WHERE ProcessInstance.Status = 'Pending' AND
                                                      ProcessInstance.TargetObjectId =: pfrId LIMIT 1];
        
        ProcessInstanceWorkItem piwitm;
        if(piwitmList != null && !piwitmList.isEmpty()){
            piwitm = piwitmList[0];
        }
        List<String> ctryList = new List<String>();
        
        if(pfrval.Core_MDF_Country_nm__c != null && pfrval.Core_MDF_Country_nm__c.contains(';')){
            ctryList.addAll(pfrval.Core_MDF_Country_nm__c.split(';'));
        } 
        else{
            ctryList.add(pfrval.Core_MDF_Country_nm__c);
        }
       

        //TWC702-1949: [Technical] [X-Platform] - Account Based PCT approvers
        if(pfrval.Core_MDF_Approval_Stage__c != null && pfrval.Core_MDF_Approval_Stage__c == 'Price Reviewer'){
               //userPermissionApprovalPFR.isUserPCTApprover = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfrval.ChannelPartnerId, pfrval.recordType.DeveloperName, ctryList, pfrval.Core_MDF_Approval_Stage__c, UserInfo.getUserId());
                userPermissionApprovalPFR.isUserPCTApprover = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfrval,UserInfo.getUserId());
            // ** NEW DUAL-ROLE LOGIC **
                // Check if user is also an IPA Account Manager AND the designated approver for the PFR
                if(userPermissionApprovalPFR.isUserPCTApprover && isCustomPermissionAssigned('Core_MDF_CCP_Internal_IPA_Acct_Mgr')) {
                    userPermissionApprovalPFR.isIPAAccountMgrAndPCTApprover = true;
        }
	}
         else if(pfrval.Core_MDF_Approval_Stage__c != null && pfrval.Core_MDF_Approval_Stage__c == 'L1 Approval'){
          
                //userPermissionApprovalPFR.isLevel1Approver = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfrval.ChannelPartnerId, pfrval.recordType.DeveloperName, ctryList, pfrval.Core_MDF_Approval_Stage__c, UserInfo.getUserId());
             if(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name').equals(pfrval.Core_MDF_Program__c)){
           userPermissionApprovalPFR.isLevel1Approver = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover( pfrval,UserInfo.getUserId());
             }
            else {
                isLoggedInUserApprover = Core_MDF_GeneralPurpose_UI_Utility.isApprover(pfrval.ChannelPartnerId,pfrval.Campaign.Core_MDF_Account__r.Id,pfrval.recordType.DeveloperName,ctryList,pfrval.Core_MDF_Budget_Type_nm__c,UserInfo.getUserId());
            }
             
            // userPermissionApprovalPFR.isLevel1Approver = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover( pfrval,UserInfo.getUserId());
            
             /*if(opalBudgetTypeList.contains(pfrval.Core_MDF_Budget_Type_nm__c)){
                 isLoggedInUserApprover = userPermissionApprovalPFR.isLevel1Approver;
             }*/
        }
         else if(pfrval.Core_MDF_Approval_Stage__c != null && pfrval.Core_MDF_Approval_Stage__c == 'Program Office Reviewer'){
           
                userPermissionApprovalPFR.isPORApprover = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover( pfrval,UserInfo.getUserId()); 
         }
             else if(pfrval.Core_MDF_Approval_Stage__c != null && pfrval.Core_MDF_Approval_Stage__c == 'Geo Lead Approval'){
                    
                    userPermissionApprovalPFR.isGeoLeadApprover = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover( pfrval,UserInfo.getUserId());       
             }
           //Additional reviewer
        else if(pfrval.Core_MDF_Approval_Stage__c != null && pfrval.Core_MDF_Approval_Stage__c == 'Additional Reviewer'){
                    
                    userPermissionApprovalPFR.isAdditionalReviewer = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover( pfrval,UserInfo.getUserId());      
                    //userPermissionApprovalPFR.isAdditionalReviewer=true;  
             }

            else if(pfrval.Core_MDF_Approval_Stage__c != null && (pfrval.Core_MDF_Approval_Stage__c ==  Core_MDF_CCP_ConstantClass.L2_REGIONAL_MARKETING||pfrval.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L2_REGIONAL_SALES) &&  pfrval.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Prg_Name')){
                userPermissionApprovalPFR.isLevel2Approver = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfrval,UserInfo.getUserId()); 
            }
        else{
          
            isLoggedInUserApprover = Core_MDF_GeneralPurpose_UI_Utility.isApprover(pfrval.ChannelPartnerId,pfrval.Campaign.Core_MDF_Account__r.Id,pfrval.recordType.DeveloperName,ctryList,pfrval.Core_MDF_Budget_Type_nm__c,UserInfo.getUserId());
        }
        userPermissionApprovalPFR.pfrInstance = pfrval;
        String userId = UserInfo.getUserId();
        if (pfrval.recordtype.developername == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Record_Type_Devlpr_Name')){
                if(isCustomPermissionAssigned('Core_MDF_EmeaReviewer')) {
                    userPermissionApprovalPFR.userEmeaReviewer = true;
                    
                }else if(isCustomPermissionAssigned('Core_MDF_ExternalActivityApprover')){
                    
                    userPermissionApprovalPFR.userPermissionsPowerPartner = true;
                    
                }else if(isCustomPermissionAssigned('Core_MDF_CCP_Internal_RMF_Account_Manager')){
                   userPermissionApprovalPFR.isAccountMng = true; 
                }else if(isCustomPermissionAssigned('Core_MDF_PriceReviewer')) {  
                userPermissionApprovalPFR.isPriceReviewer = true; 
            }
            // EOL - commented below OR condition associated to Channel MDF
            }else if(ccfDcfProgramStrList.contains(pfrval.recordtype.developername)  || ((/*pfrval.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ChannelMDF_Program_Name') ||*/ pfrval.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Prg_Name')) && pfrval.Core_MDF_Proposal_Based_Ind__c == false)){
            //US821309 : [Opal] CCF and DCF - Client Acceptance - Added code for OPAL Client Acceptance
                if(isCustomPermissionAssigned('Core_MDF_CCP_Internal_IPA_Acct_Mgr')){
                   userPermissionApprovalPFR.isIPAAccountMgr=true;
                }
            if(isCustomPermissionAssigned('Core_MDF_CCP_External_Activity_Submitter') 
               || isCustomPermissionAssigned('Core_MDF_CCP_External_IPA_Activity_Manager')){  
                userPermissionApprovalPFR.userPermissionsPowerPartner = true; 
            }
            //TWC702-1949: [Technical] [X-Platform] - Account Based PCT approvers
            if(isCustomPermissionAssigned('Core_MDF_PriceReviewer')) { userPermissionApprovalPFR.isPriceReviewer = true;   
            }
            //US946280 : [Opal CCF/DCF] - Activity Edits - Activity Status = Pending Approval - Show Reject button for Internal Account Manager
           
            if((isCustomPermissionAssigned(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Field_Owner')) || isCustomPermissionAssigned(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Field_Owner'))) &&
               (pfrval.Core_MDF_Budget_Type_nm__c == 'MDF' || pfrval.Core_MDF_Budget_Type_nm__c == 'MDF+')){
                   userPermissionApprovalPFR.isFieldOwner = true;    
               }else if((isCustomPermissionAssigned(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Marketing_Owner')) || isCustomPermissionAssigned(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Marketing_Owner'))) &&
                        (pfrval.Core_MDF_Budget_Type_nm__c == 'OEM CMP' || pfrval.Core_MDF_Budget_Type_nm__c == 'Service Provider CMP')){userPermissionApprovalPFR.isMarktngOwner = true;    
            }
            //Opal approaval chnages-Ealisha
            //If budget type is opal and program is ccfdcf,
            //then based on acct all acct managers can approve/reject the activity 
            //along with the actual approval(tagged on the pfr)                     
            if(opalBudgetTypeList.contains(pfrval.Core_MDF_Budget_Type_nm__c)

              && pfrval.Core_MDF_Activity_CreatedByExternalUsr__c
              && piwitm != null && pfrval.Core_MDF_Fund_Request_Status__c == 'Pending Review' && UserInfo.getUserType() == 'Standard'
                && (pfrval.Core_MDF_Approval_Step_Completed__c == 0 && pfrval.Core_MDF_L1_Approver_Id__c == null)){
                    
                  if(isLoggedInUserApprover){
                      
                     userPermissionApprovalPFR.isIntelActivityApprover = true;
                  }
                }
            } else if(pfrval.recordtype.developername == Core_MDF_CCP_ConstantClass.PFR_EEF_RECORDTYPE
                     && pfrval.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_REVIEW_STATUS){
                if(pfrval.Core_MDF_Approval_Stage__c != null 
                    && pfrval.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL_PRIMARY_PARTNER
                    && isCustomPermissionAssigned('Core_MDF_CCP_Internal_EEF_Primary_Account_Manager')
                    && Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfrval,UserInfo.getUserId())){
                        userPermissionApprovalPFR.isL1PrimaryPartnerApprover= true;
                } else if(pfrval.Core_MDF_Approval_Stage__c != null 
                    && pfrval.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL_ACTIVATING_PARTNER
                    && isCustomPermissionAssigned('Core_MDF_CCP_Internal_EEF_Activating_Account_Manager')
                    && Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfrval,UserInfo.getUserId())){
                        userPermissionApprovalPFR.isL1ActivatingPartnerApprover = true;
                } else if(pfrval.Core_MDF_Approval_Stage__c != null 
                          && pfrval.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L2_PRIMARY_APPROVAL
                          && isCustomPermissionAssigned('Core_MDF_CCP_Internal_EEF_L2_Approver')
                          && Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfrval,UserInfo.getUserId())){
                            userPermissionApprovalPFR.isL2PrimaryApprover= true;
                } else if(pfrval.Core_MDF_Approval_Stage__c != null 
                          && pfrval.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.PROGRAM_OFFICE_REVIEWER
                          && isCustomPermissionAssigned('Core_MDF_CCP_Internal_Proposal_Activity_POR_Approver')
                          && userPermissionApprovalPFR.isPORApprover){
                            userPermissionApprovalPFR.isEEFPORApprover = true;
                } else if(pfrval.Core_MDF_Approval_Stage__c != null 
                          && pfrval.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.PRICE_REVIEWER
                          && isCustomPermissionAssigned('Core_MDF_PriceReviewer')
                          && userPermissionApprovalPFR.isUserPCTApprover){
                            userPermissionApprovalPFR.isEEFPCTApprover = true;
                }
            } else if(pfrval.recordtype.developername == Core_MDF_CCP_ConstantClass.PFR_EEF_RECORDTYPE
                       && pfrval.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS){
                    if(pfrval.Core_MDF_Approval_Stage__c != null 
                        && pfrval.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.CUSTOMER_ACCEPTANCE_PRIMARY_PARTNER
                        && isCustomPermissionAssigned('Core_MDF_CCP_EEF_Primary_Partner_User')){
                            userPermissionApprovalPFR.isPrimaryPartnerApprover = true;
                    } else if(pfrval.Core_MDF_Approval_Stage__c != null 
                        && pfrval.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.CUSTOMER_ACCEPTANCE_ACTIVATING_PARTNER
                        && isCustomPermissionAssigned('Core_MDF_CCP_EEF_Activating_Partner_User')){
                            userPermissionApprovalPFR.isActivatingPartnerApprover = true;
                }
            }   
              
        else{
            userPermissionApprovalPFR = null;
        }
            // Recall for EEF Program
            if(pfrval.recordtype.developername == Core_MDF_CCP_ConstantClass.PFR_EEF_RECORDTYPE
                        && (((pfrval.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_REVIEW_STATUS
                                || (pfrval.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS
                                    && pfrval.Core_MDF_Approval_Stage__c != Core_MDF_CCP_ConstantClass.CUSTOMER_ACCEPTANCE_ACTIVATING_PARTNER))
                                && isCustomPermissionAssigned('Core_MDF_CCP_External_EEF_Activity_Submitter'))
                        || ((pfrval.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS
                                || (pfrval.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_REVIEW_STATUS
                                        && pfrval.Core_MDF_Approval_Stage__c != Core_MDF_CCP_ConstantClass.L1_APPROVAL_PRIMARY_PARTNER))
                            && isCustomPermissionAssigned('Core_MDF_CCP_Internal_EEF_Primary_Account_Manager'))
                        || ((pfrval.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS
                                || (pfrval.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_REVIEW_STATUS
                                            && pfrval.Core_MDF_Approval_Stage__c != Core_MDF_CCP_ConstantClass.L1_APPROVAL_ACTIVATING_PARTNER))
                            && isCustomPermissionAssigned('Core_MDF_CCP_Internal_EEF_Activating_Account_Manager')))){ 
                userPermissionApprovalPFR.userPermissionsEEFRecall = true; 
            }
        //Add record type & budget type check       
        
            if(userPermissionApprovalPFR != null){
        userPermissionApprovalPFR.pfrMapInstance = new Map<Id,Map<String,String>>();
        userPermissionApprovalPFR.approverAssigned = isApproverAssigned(pfrId,userId,userPermissionApprovalPFR.userPermissionsPowerPartner);
            }
        //userPermissionApprovalPFR.statusMapInstance = new Map<String,String>();
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            
            throw new AuraHandledException(e.getMessage());
        } 
        return userPermissionApprovalPFR;
    }
    /*****************************************************************************************************
    Method Name:        isCustomPermissionAssigned
    @return  :          Boolean
    @parameters:        String - Custom Permission Name
    Description:        This method is used to check if the Custom permission is assigned to the User
    Added By:           Accenture SB
    Modified By:        Date:       Changes:
    ******************************************************************************************************/
    public static Boolean isCustomPermissionAssigned(String customPermissionNameStr){
        Boolean userHasPer = false;
        
        if(customPermissionNameStr != NULL && String.isNotBlank(customPermissionNameStr)){
            userHasPer =  FeatureManagement.checkPermission(customPermissionNameStr);
        }
        return userHasPer;
    }
    /*****************************************************************************************************
    Method Name :  Update PFR Record on Approval (Updates status to planned when External User Approves)
    Added By    : Sridhar on 3-Jun-2020
    Modified By : Nuzhath Zaiba                  Date:  14/11/2019                  Changes:None
    ******************************************************************************************************/
    @AuraEnabled
    public static Boolean submitForApprovalClosed(List<Id> pfrIds,String comments)
            {
        Boolean isSubmitted = false;
             List<String> pctPfrIds = new List<String>();    
        String pendingReview = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Status_PendingReview');
        String pendingApproval = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Approval_Nm');
        String retailApprovalProcess = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RetailApprovalProcess');        
        
        try{        
            Boolean inApprvlPrs = isApproverAssigned(pfrIds[0], null ,false);
            
            Map<Id,PartnerFundRequest> pfrMapToBeUpdated = new Map<Id,PartnerFundRequest>();            

            for(PartnerFundRequest pfr : [SELECT Id,Core_MDF_Program__c,Core_MDF_Approval_Step_Completed__c, Core_MDF_Fund_Request_Status__c,
                                          Core_MDF_Region_nm__c, RequestedAmount, Core_MDF_Price_reviewer_check_ind__c
                                          FROM PartnerFundRequest
                                          WHERE Id IN :pfrIds ]){
                                              
               
                if(pfr.RequestedAmount < 25000){ 
                    //US1098882: Replaced Core_MDF_Region_cd__c with Core_MDF_Region_nm__c
                    if(pfr.Core_MDF_Region_nm__c == 'EMEA' && !inApprvlPrs){
                        pfr.Core_MDF_Approval_Step_Completed__c = 1;   
                    }else{
                      pfr.Core_MDF_Approval_Step_Completed__c = 0;    
                    }                   
                    if(!pfr.Core_MDF_Price_reviewer_check_ind__c){
                        pfr.Core_MDF_Fund_Request_Status__c = pendingApproval;
                     }
                    else{
                        pfr.Core_MDF_Fund_Request_Status__c = pendingReview;
                        pctPfrIds.add(pfr.Id);
                    }
                }else if(pfr.RequestedAmount >= 25000 && pfr.RequestedAmount < 250000 ){
                    //US1098882: Replaced Core_MDF_Region_cd__c with Core_MDF_Region_nm__c
                    if(pfr.Core_MDF_Region_nm__c == 'EMEA' && !inApprvlPrs){  
                        pfr.Core_MDF_Approval_Step_Completed__c = 2;  
                    }else{
                      pfr.Core_MDF_Approval_Step_Completed__c = 1;    
                    } 
                    if(!pfr.Core_MDF_Price_reviewer_check_ind__c){
                        pfr.Core_MDF_Fund_Request_Status__c = pendingApproval;
                    }else{ 
                        pfr.Core_MDF_Fund_Request_Status__c = pendingReview;
                         pctPfrIds.add(pfr.Id);
                    }
                }else if(pfr.RequestedAmount >= 250000 ){
                    //US1098882: Replaced Core_MDF_Region_cd__c with Core_MDF_Region_nm__c
                    if(pfr.Core_MDF_Region_nm__c == 'EMEA' && !inApprvlPrs){                      pfr.Core_MDF_Approval_Step_Completed__c = 3;   
                    }else{
                      pfr.Core_MDF_Approval_Step_Completed__c = 2;    
                    }
                    if(!pfr.Core_MDF_Price_reviewer_check_ind__c){
                        pfr.Core_MDF_Fund_Request_Status__c = pendingApproval;
                    }else{
                        pfr.Core_MDF_Fund_Request_Status__c = pendingReview;
                        pctPfrIds.add(pfr.Id);
                    }
                }                            
                pfr.Core_MDF_Activity_Closure_Type__c = '';
                pfr.Core_MDF_No_Internal_Close_Date__c = null;  
                pfrMapToBeUpdated.put(pfr.Id,pfr);                
            }
            
            if(pfrMapToBeUpdated != NULL && pfrMapToBeUpdated.Size() > 0){
              
                
                List<Approval.ProcessWorkitemRequest> pwrList = new List<Approval.ProcessWorkitemRequest>(); 
                for(ProcessInstanceWorkItem piwitm : [SELECT ProcessInstance.TargetObjectId, Id 
                                                  FROM ProcessInstanceWorkItem
                                                  WHERE ProcessInstance.Status = 'Pending' AND
                                                      ProcessInstance.TargetObjectId IN:pfrMapToBeUpdated.keySet() LIMIT 1]){
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setAction('Approve');
                    ////[System Comment]- Approved by After The Fact Approver; [Approver Comment]- Test ATF
                    /*String commentsATF = '';
                    if(pfrMapToBeUpdated.get(piwitm.ProcessInstance.TargetObjectId).Core_MDF_Program__c == 'Retail Marketing Funds'){
                        commentsATF = '[System]- Approved by After The Fact Approver';
                    if(String.isNotBlank(comments)){
                        commentsATF = commentsATF + '; [Approver]- '+comments;                                            
                    }  
                    }
                    else{
                        commentsATF = comments;
                    }*/
                    req.setComments(comments);
                    req.setWorkitemId(piwitm.Id);
                    pwrList.add(req);
                }  
                 database.update(pfrMapToBeUpdated.values());
                if(pwrList != NULL && pwrList.Size() > 0){
                   List<Approval.ProcessResult> result = Approval.process(pwrList);
                }  
                
                if(pctPfrIds != NULL && pctPfrIds.Size()>0){
                  
                  for(ProcessInstance pi : [SELECT Id, TargetObjectId, Status
                                           FROM ProcessInstance
                                           WHERE TargetObjectId = :pctPfrIds 
                                           AND Status = 'Pending']){
                     
                     if(pctPfrIds.contains(pi.TargetObjectId)){                        
                         pctPfrIds.remove(pctPfrIds.indexOf(pi.TargetObjectId));
                         
                     }                           
                }
                    List<Approval.ProcessSubmitRequest> appRequests = new List<Approval.ProcessSubmitRequest> ();
                    for(Id pid: pctPfrIds){
                        
                        Approval.ProcessSubmitRequest appObj = new Approval.ProcessSubmitRequest();
                        appObj.setObjectId(pid);
                        appObj.setProcessDefinitionNameOrId(retailApprovalProcess);
                        appRequests.add(appObj);                                   
                    
                    }
                    if (appRequests.size()> 0){   
                            
                            Approval.ProcessResult[] result = Approval.process(appRequests);
                    }    
                    
                }
                              
            }                       
            
            isSubmitted = true;
        }catch (Exception e){ string errorlog = 'Submit for approval failed for activities->' + pfrIds + '-> Error->' + e; Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorlog,'submitForApproval Method'); throw e;}
        return isSubmitted;
    }
    /*****************************************************************************************************
    Method Name :  Update PFR Record on Approval (Updates status to planned when External User Approves)
    Added By    : Sridhar on 3-Jun-2020
    Modified By :                  Date:                   Changes:
    Nuzhath Zaiba                  14/11/2019              None
    ******************************************************************************************************/
    @AuraEnabled
    public static Boolean submitForApproval(List<Id> pfrIds,String approvalComments)
    {
        Map<id,PartnerFundRequest> mapPfr = new Map<id,PartnerFundRequest>();
        List<PartnerFundRequest> listPfr = new List<PartnerFundRequest>();
        List<PartnerFundRequest> pfrvals = new List<PartnerFundRequest>();
        String queryFields = '';
        String querystr = '';
        Boolean isSubmitted = false;
        try
        {
            // Read the field names from fieldset and query the values
            Schema.FieldSet fieldSet = Schema.SObjectType.PartnerFundRequest.FieldSets.Core_MDF_Approval_Field_Set;

            if (fieldSet != null){

                List<String> fields = new  List<String>();

                for(FieldSetMember field: fieldSet.getFields()) {
                    fields.add(field.getFieldPath());
                }
                queryFields = String.join(fields,',');

                querystr = String.format(
                    'SELECT {0} FROM {1} where id IN :pfrIds',
                    new List<String>{
                        String.escapeSingleQuotes(queryFields),
                            String.escapeSingleQuotes('PartnerFundRequest')
                            }
                );
                pfrvals = Database.query(querystr);
                
                for (PartnerFundRequest pfrl : pfrvals){
                    pfrl.Core_MDF_Completed_Approval_Level_Name__c = 'EMEA Reviewer' ;
                    mapPfr.put(pfrl.Id,pfrl); listPfr.add(pfrl);
                }
                
                if(listPfr != NULL && !listPfr.isEmpty()){
                    update listPfr;
                }
                	//Core_MDF_ProcessCCP_PartnerFundRequest.callApprovalProcess( mapPfr, listPfr, null,true); 
            }           
            isSubmitted = true;
        } catch (Exception e){ string errorlog = 'Submit for approval failed for activities->' + pfrIds + '-> Error->' + e; Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorlog,'submitForApproval Method'); throw e;}
        return isSubmitted;
    }

    /*****************************************************************************************************
    Method Name :  isApproverAssigned (Verify the assigned approvers from process instance object)
    Added By    : Sridhar on 3-Jun-2020
    Modified By : Nuzhath Zaiba                  Date:  14/11/2019                  Changes:None
    ******************************************************************************************************/

    @AuraEnabled
    public static Boolean isApproverAssigned(String pfrId, Id userId, Boolean isPartnerUser)
    {
        if (isPartnerUser){return [SELECT Id, TargetObjectId, Status, (select actorid from Workitems where actorid =: userId) FROM ProcessInstance WHERE TargetObjectId =: pfrId and Status =: 'Pending' limit 1].size() > 0;

                          }
        else{
            ProcessInstance[] processInsItem = [SELECT Id, TargetObjectId, Status FROM ProcessInstance WHERE TargetObjectId =: pfrId and Status =: 'Pending' limit 1]; return processInsItem.size() > 0;

        }
    }

    /*****************************************************************************************************
Method Name : approveRejectActivity (Handle the submit or reject actions)
Added By    : Sridhar on 3-Jun-2020
Modified By : Nuzhath Zaiba                  Date:  14/11/2019                  Changes:None
              Ramapriya Rajesh                      25/07/2025                  Added status check as part of 'In-Progress Activity edit'
******************************************************************************************************/
    @AuraEnabled
    public static String approveRejectActivity(Map<Id,Map<String,String>> mapValues,string approvalComments,Boolean isExternal)
    {
        Map<Id,Id>  piList = new Map<Id,Id>();
         List<PartnerFundRequest> pfrToUpdateList = new List<PartnerFundRequest>();
        List<Approval.ProcessWorkitemRequest> processWorkItemReqList = new  List<Approval.ProcessWorkitemRequest>();
        List<Id> pfrIds = new List<Id>();
        List<PartnerFundRequest> pfrsToBeUpdated = new List<PartnerFundRequest>();
        List<String> opalBudgetTypeList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_OPAL_BudgetTypes').Split(';');
        String msg = '';
        Boolean isFieldUpdate = false;
        List<String> L2_APPROVAL_STAGES=Core_MDF_CCP_ConstantClass.L2_APPROVAL_STAGES;
        try {
            for(Id pfrId : mapValues.keySet()){
                pfrIds.add(pfrId);
            }
            for(ProcessInstanceWorkItem piwitm : [SELECT ProcessInstance.TargetObjectId,Id FROM ProcessInstanceWorkItem
                                                  WHERE ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId IN:pfrIds]){
                 piList.put(piwitm.ProcessInstance.TargetObjectId, piwitm.Id);
            }
            
            Map<Id,PartnerFundRequest> pfrInstMap = new Map<Id,PartnerFundRequest>();
            for(PartnerFundRequest pfr : [Select Id,Core_MDF_Budget_Type_nm__c,Core_MDF_Program__c,Core_MDF_External_Approval_Comment_txt__c,Core_MDF_Fund_Request_Status__c,Core_MDF_Approval_Stage__c,Core_MDF_IPA_Int_Approver_Comment_txt__c,Core_MDF_Proposal_Based_Ind__c
                                                   FROM PartnerFundRequest 
                                          WHERE Id IN :piList.keySet()]){
                                              pfrInstMap.put(pfr.Id,pfr);
                                          } 
            
            
            String comment, action, btnName = '';
            for(Id pfrId : piList.keySet()) { 
                
                Map<String,String> commentStatus = mapValues.get(pfrId);                
                for (String commentVal : commentStatus.keySet()){
                    
                    comment = commentVal;
                    btnName = commentStatus.get(comment);
                    
                    
                    //if internal user and status is pendign review then get the approval comment
                    
                    
                    if (btnName == 'Reject' || btnName == 'Recall'){
                        
                        action = 'Reject'; 
                        if(btnName == 'Reject' && (pfrInstMap.get(pfrId).Core_MDF_Approval_Stage__c == 'Price Reviewer' 
                                                   || pfrInstMap.get(pfrId).Core_MDF_Approval_Stage__c == 'L1 Approval' 
                                                   || pfrInstMap.get(pfrId).Core_MDF_Approval_Stage__c == 'L2 Approval' 
                                                   || pfrInstMap.get(pfrId).Core_MDF_Approval_Stage__c == 'L2 Regional Sales'  
                                                   || pfrInstMap.get(pfrId).Core_MDF_Approval_Stage__c == 'L2 Regional Marketing'
                                                   || pfrInstMap.get(pfrId).Core_MDF_Approval_Stage__c == 'Program Office Reviewer'
                                                   || pfrInstMap.get(pfrId).Core_MDF_Approval_Stage__c == 'L1 Approval (Primary Partner)'
                                                   || pfrInstMap.get(pfrId).Core_MDF_Approval_Stage__c == 'L1 Approval (Activating Partner)' 
                                                   || pfrInstMap.get(pfrId).Core_MDF_Approval_Stage__c == 'L2 Primary Approval'
                                                   || pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'Pending Approval'
                                                   || pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Approval' ||
                                                   (pfrInstMap.get(pfrId).Core_MDF_Program__c == 'Retail Marketing Funds' && pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'Pending Approval'))){
                                                       comment = approvalComments;
                                                       
                                                   }
                        else if(btnName == 'Recall') {
                            comment = approvalComments ;
                        }
                      
                        //Added by Ealisha--start
                    if(btnName == 'Reject' && opalBudgetTypeList.contains(pfrInstMap.get(pfrId).Core_MDF_Budget_Type_nm__c) && 
                       (pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'Pending Review' || pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'Pending Approval')){
                        action = 'Reject'; 
                        comment = approvalComments;
                    } 
                    //Added by Ealisha--end
                    }
                    
                    else if(btnName == 'Approve'&& (pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'Pending Review' || pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'Pending Approval' ||pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Review'||pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Approval')){
                        action = 'Approve'; 
                        comment = approvalComments;
                        if(pfrInstMap.get(pfrId).Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Prg_Name')
                           && pfrInstMap.get(pfrId).Core_MDF_Proposal_Based_Ind__c == false
                           && (pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'Pending Review' || pfrInstMap.get(pfrId).Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Review')
                           && (pfrInstMap.get(pfrId).Core_MDF_Approval_Stage__c != 'Price Reviewer')) {
                          PartnerFundRequest pfrObj = new PartnerFundRequest( 
                               Id = pfrId,
                               Core_MDF_IPA_Int_Approver_Comment_txt__c = approvalComments
                           );
                           pfrToUpdateList.add(pfrObj);
                               isFieldUpdate=true;
                           }
                    }
                    
                    else{          
                        
                        action = btnName;
                        
                    } 
                    break;
                }                
                // Approval.ProcessResult processResult = null;
                Approval.ProcessWorkitemRequest aprReq = new Approval.ProcessWorkitemRequest();
                aprReq.setComments(comment);
                aprReq.setAction(action);
                aprReq.setWorkitemId(piList.get(pfrId));
                aprReq.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                processWorkItemReqList.add(aprReq);
              /*   processResult = Approval.process(aprReq);

if (processResult != null && !processResult.isSuccess()){

string errorlog = 'Approval failed for activiy ->' + pfrId + ';' ; 
for(Database.Error errDet : processResult.getErrors()){
errorlog += errDet.getMessage();
msg = errDet.getMessage();
} 
Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorlog,'approveRejectActivity Method');
return msg;
}*/
            }
            if( !pfrToUpdateList.isEmpty() && isFieldUpdate ){
                    
                Database.update(pfrToUpdateList);
            }
            
            List<Approval.ProcessResult> processResultList = Approval.process(processWorkItemReqList);
            if(processResultList!=null && !processResultList.isEmpty()){
                for(Approval.ProcessResult processResult:processResultList){
                    if (processResult != null && !processResult.isSuccess()){
                        string errorlog = 'Approval failed for activiy ->' + processResult.getEntityId() + ';' ; 
                        for(Database.Error errDet : processResult.getErrors()){
                            errorlog += errDet.getMessage();
                            msg = errDet.getMessage();
                        } 
                        Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorlog,'approveRejectActivity Method');
                        return msg;  
                    }
                }
            }
            for(PartnerFundRequest pfrInst : [Select Id, Core_MDF_External_Approval_Comment_txt__c,Core_MDF_Internal_Approval_Comment_txt__c,Core_MDF_Approval_Stage__c,Core_MDF_Approval_Step_Completed__c,Core_MDF_Fund_Request_Status__c
                                              ,Core_MDF_Rejection_Comments_txt__c,Core_MDF_Program__c,Core_MDF_IPA_Int_Approver_Comment_txt__c,Core_MDF_Completed_Approval_Level_Name__c,Core_MDF_PriorValueOfStatus__c 
                                              FROM PartnerFundRequest 
                                              WHERE Id IN :piList.keySet()]){
                //Call method to append comments
                                                                                           
                if(isExternal){
                    pfrInst.Core_MDF_External_Approval_Comment_txt__c = populateApproverComments(btnName,pfrInst.Core_MDF_External_Approval_Comment_txt__c,approvalComments);
                }
                if (btnName == 'Reject'){
            		if(pfrInst.Core_MDF_PriorValueOfStatus__c == 'In-Progress Pending Review' || pfrInst.Core_MDF_PriorValueOfStatus__c == 'In-Progress Pending Approval' ){
                              pfrInst.Core_MDF_Fund_Request_Status__c = 'In-progress Revision Required';                       
                        }
                        else{
                                                          
                              pfrInst.Core_MDF_Fund_Request_Status__c = 'Revision Required';
                        }
                    pfrInst.Core_MDF_Approval_Step_Completed__c = 0;
                }
                                                  if( action == 'Reject' && pfrInst.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM){
                                                    
                                                        pfrInst.Status = 'Draft';
                                                      
                                                  }
                                                  
                                                  else if((pfrInst.Core_MDF_Approval_Step_Completed__c == 1 ||
                                                  L2_APPROVAL_STAGES.contains( pfrInst.Core_MDF_Completed_Approval_Level_Name__c)) 
                                                          && btnName == 'Approve' && string.isNotBlank(approvalComments)){
                                                      
                     pfrInst.Core_MDF_Internal_Approval_Comment_txt__c = approvalComments;
                 }
                                                  if(pfrInst.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Prg_Name')){
                                                     
                                                       pfrInst.Core_MDF_IPA_Int_Approver_Comment_txt__c = '';
                                                  }
                pfrsToBeUpdated.add(pfrInst);
               
            }   
            
            if(pfrsToBeUpdated != NULL && !pfrsToBeUpdated.isEmpty()){
                update pfrsToBeUpdated;
                 msg = 'true';
            }
        } catch (Exception e) {string logerror = '';logerror += 'PFRIDs->' + string.join(pfrIds, ',->');logerror += e.getLineNumber() + '->';logerror += e.getMessage() + '->';
                               Core_MDF_CCP_UtilityClass.logErrorinLogObject(logerror,'approveRejectActivity Method');
                               msg = e.getMessage().contains(Label.Core_MDF_AutoBudgetTransfer_ErrorMsg) ? Label.Core_MDF_AutoBudgetTransfer_ErrorMsg:e.getMessage();

                               return msg;
                              }
        return msg;
    }
    /*****************************************************************************************************
    Method Name :   populateApproverComments
    @return     :   String
    @parameters :   String - buttonType
    String - existingApprovalComments
    String - approvalComments
    Description :   The method concatenates Approve or Rejection informatio along with approval comments and with existing comments(if present)
    Created By  :   Nuzhath Zaiba                  Date:  04/15/2020
    ******************************************************************************************************/
    public static String populateApproverComments(String buttonType, String previousExternalApprovalComments,String externalApproverComments){
        String externalApprovalRejectionComments = '';
        String concatenateCommentswithApprovalOrRejectionInfo;

        //Custom Label used below
        //Core_MDF_Retail_Approve - approve
        //Core_MDF_Activity_Decline  - Decline,
        //Core_MDF_Retail_Approval_Comments - Approval Comments : , Core_MDF_Activity_Decline_Comments - Decline Comments : ,

        //Appends Approval or Rejection comments with appropriate Info And Not need to concatinate if Approval Comment is blank or null
        
        if(buttonType.equalsIgnoreCase(APPROVE_BUTTON)){
            if(String.isNotBlank(externalApproverComments)){
                //If Approvers Approves Activity prefix comments with 'Approval Comments :'
                concatenateCommentswithApprovalOrRejectionInfo = 'Approval Comments' +' ' + DateTime.now() +' (GMT) : '+ externalApproverComments;
            }else{    concatenateCommentswithApprovalOrRejectionInfo = 'Approval Comments'  +' '+ DateTime.now() +' (GMT) : ' +' No Comments provided';
            
                 }
           
        }else if(buttonType.equalsIgnoreCase(DECLINE_BUTTON)){
            String userType = UserInfo.getUserType();
            //If Approvers Declines Activity prefix comments with 'Decline Comments :'
            if(String.isNotBlank(userType) && userType != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Partner_User_Type')){
                concatenateCommentswithApprovalOrRejectionInfo = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Decline_Comments') + ' ' +DateTime.now() +' (GMT)' + ', ' +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Intel_System_User') + ' : ' + externalApproverComments;
            }else{ concatenateCommentswithApprovalOrRejectionInfo = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Decline_Comments') + ' '+ DateTime.now() +' (GMT) : ' + externalApproverComments;
            }
        }
        //Check if external comments field of PFR has info, then concatenate the existing comments and new comments
        if(String.isNotBlank(previousExternalApprovalComments)){
            externalApprovalRejectionComments = concatenateCommentswithApprovalOrRejectionInfo +'\n' +previousExternalApprovalComments ;
        }else{
            externalApprovalRejectionComments = concatenateCommentswithApprovalOrRejectionInfo;
        }
       
        return externalApprovalRejectionComments;
    }
    /*****************************************************************************************************
    Method Name : isApproverActive
    Date:  14/4/2021                
    ******************************************************************************************************/
    @AuraEnabled
    public static Boolean isApproverActive(String recId,String userId) 
    {Boolean returnValue = true;
     userPermissionApproval pfrval = new userPermissionApproval();
     
     try{
         PartnerFundRequest pfr = [Select Id,ChannelPartnerId,Core_MDF_Region_nm__c,Core_MDF_Sub_Region_nm__c,Core_MDF_Approval_Step_Completed__c,
                                   Core_MDF_Ultimate_Account_Id__c,Core_MDF_Program__c, Core_MDF_Country_nm__c, Core_MDF_Approval_Stage__c,
                                   Core_MDF_Activity_Classification_nm__c,Core_MDF_Host_Region_txt__c,Core_MDF_Proposal_Based_Ind__c,
                                   Core_MDF_Fund_Request_Status__c,Core_MDF_Activity_CreatedByExternalUsr__c, recordtype.developername,Campaign.Core_MDF_Account__r.Id,
                                   Core_MDF_Budget_Type_nm__c,Core_MDF_Additional_Review_Type_txt__c,Core_MDF_Host_Region_or_Region_txt__c,Core_MDF_Campaign_Ultimate_Account_Id__c,Campaign.Core_MDF_Account__c
                                   FROM PartnerFundRequest 
                                   WHERE Id =:recId];
 
         
	 String accId = pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM && pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.CUSTOMER_ACCEPTANCE_PRIMARY_PARTNER ? String.valueOf(pfr.Campaign.Core_MDF_Account__c) : String.valueOf(pfr.ChannelPartnerId);
         String country = pfr.Core_MDF_Country_nm__c; 
         List<String> countryList = country.split(';');
         if(pfr.Core_MDF_Fund_Request_Status__c == 'Pending Approval' || pfr.Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Approval'){
             returnValue = Core_MDF_GeneralPurpose_UI_Utility.isSubmitterActive(accId,userId);
         }
         else if(pfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' || pfr.Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Review'){
             if(pfr.Core_MDF_Approval_Stage__c =='Price Reviewer'){
                 //returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(accId,pfr.recordType.DeveloperName,countryList,pfr.Core_MDF_Approval_Stage__c,userId);
                 returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfr,userId);
         }
         else if(pfr.Core_MDF_Approval_Stage__c =='L1 Approval'){
                 //returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(accId,pfr.recordType.DeveloperName,countryList,pfr.Core_MDF_Approval_Stage__c,userId);
                 returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfr,userId);
                 
                 if(!returnValue && (pfr.Core_MDF_Approval_Step_Completed__c == 0 && pfr.Core_MDF_Activity_CreatedByExternalUsr__c)){
                     returnValue = Core_MDF_GeneralPurpose_UI_Utility.isApprover(pfr.ChannelPartnerId,pfr.Campaign.Core_MDF_Account__r.Id,pfr.recordType.DeveloperName,countryList,pfr.Core_MDF_Budget_Type_nm__c,userId);
                 }
             }
  
             else if(pfr.Core_MDF_Approval_Stage__c != null && (pfr.Core_MDF_Approval_Stage__c == 'L2 Regional Marketing'||pfr.Core_MDF_Approval_Stage__c == 'L2 Regional Sales') &&  pfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Prg_Name')){
                // returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApproverByActivityClassification(pfr,UserInfo.getUserId()); 
                                  returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfr,userId);
      
         }
             else if(pfr.Core_MDF_Approval_Stage__c =='Program Office Reviewer'){
              //   returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(accId,pfr.recordType.DeveloperName,countryList,pfr.Core_MDF_Approval_Stage__c,userId);
                returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfr,userId);
             }
            else if (pfr.Core_MDF_Approval_Step_Completed__c == 0 && pfr.Core_MDF_Activity_CreatedByExternalUsr__c){
                 returnValue = Core_MDF_GeneralPurpose_UI_Utility.isApprover(pfr.ChannelPartnerId,pfr.Campaign.Core_MDF_Account__r.Id,pfr.recordType.DeveloperName,countryList,pfr.Core_MDF_Budget_Type_nm__c,userId);
            } 
            // To check the approver have the valid IUPGM or not
            else if(pfr.Core_MDF_Approval_Stage__c != null && pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL_ACTIVATING_PARTNER){
                returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfr,userId);
            } else if(pfr.Core_MDF_Approval_Stage__c != null && pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL_PRIMARY_PARTNER){
                returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfr,userId);
            } else if(pfr.Core_MDF_Approval_Stage__c != null && pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L2_PRIMARY_APPROVAL){
                returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfr,userId);
            }
        }
         else {
             if(pfr.Core_MDF_Program__c == 'Retail Marketing Funds' && pfr.Core_MDF_Fund_Request_Status__c == 'Closed') 
             {returnValue = true;}
             else
             {returnValue = false;}
         }
     }
     catch(Exception e){
         Core_MDF_CCP_UtilityClass.logError(e);
         throw new AuraHandledException(e.getMessage());
     }
     return returnValue;
    } 
    
       
   
    /*****************************************************************************************************
    Method Name :   userPermissionApproval (Created a Wrapper to reduce the server side call)
    Added By    : Sridhar on 3-Jun-2020
    Modified By : Nuzhath Zaiba                  Date:  14/11/2019                  Changes:None
    ******************************************************************************************************/
    public class userPermissionApproval{
        //Added by Ealisha--start
        @AuraEnabled
        public Boolean isIntelActivityApprover = false;
        //Added by Ealisha--end
        @AuraEnabled
        public Boolean userPermissionsPowerPartner = false;
        @AuraEnabled
        public Boolean userEmeaReviewer = false;
        @AuraEnabled
        public Boolean userMDFFact = false; 
        @AuraEnabled
        public PartnerFundRequest pfrInstance;
        @AuraEnabled
        public Boolean approverAssigned = false;
        @AuraEnabled
        public Map<Id,Map<String,String>> pfrMapInstance;
        @AuraEnabled
        public Boolean isUserPCTApprover = false;
        @AuraEnabled
        public Boolean isFieldOwner = false;
        @AuraEnabled
        public Boolean isMarktngOwner = false;
        @AuraEnabled
        public Boolean isAccountMng = false;
    @AuraEnabled
        public Boolean isIPAAccountMgr = false;
        @AuraEnabled
        public Boolean isPriceReviewer = false;
        @AuraEnabled
        public Boolean isLevel1Approver = false;
        @AuraEnabled
        public Boolean isLevel2Approver = false;
         @AuraEnabled
        public Boolean isPORApprover = false;
        @AuraEnabled
        public Boolean isGeoLeadApprover = false;
        @AuraEnabled
        public Boolean isL1ActivatingPartnerApprover = false;
        @AuraEnabled
        public Boolean isL1PrimaryPartnerApprover = false;
        @AuraEnabled
        public Boolean isL2PrimaryApprover = false;  
        @AuraEnabled
        public Boolean isEEFPORApprover = false; 
        @AuraEnabled
        public Boolean isEEFPCTApprover = false;
        @AuraEnabled
        public Boolean isPrimaryPartnerApprover = false; 
        @AuraEnabled
        public Boolean isActivatingPartnerApprover = false;
        @AuraEnabled
        public Boolean userPermissionsEEFRecall = false;
        @AuraEnabled
        public Boolean isAdditionalReviewer = false;
        @AuraEnabled
        public Boolean isIPAAccountMgrAndPCTApprover = false;
    }
}