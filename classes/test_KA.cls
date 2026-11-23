/*********************************************************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_PartnerFundRequest 
* Version     : 1.0 
* Created Date: 8-21-2018
* Modification Log :
* Developer                     Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel – Narayani Perachi      8/21/2018                     callApprovalProcess() - To determine Activities to be sent for Approval process along with their approvers or to 
*                                                             auto approve the activity based on certain criteria.
*                                                             This method is called in PartnerFundRequest trigger during afterUpdate and afterInsert.
*
* Intel – Narayani Perachi      9/05/2018                     assignAccountManagers() - For Approval Process which do not have Approvers configured, 
*                                                             the Account Managers of the parent Account will be assigned as the Approvers. 
*
* Intel – Narayani Perachi      8/21/2018                     callApprovalProcess() - This will trigger the standard Approval Process
*
* Intel – Narayani Perachi      8/21/2018                     updateApprovers() - This will set the approvers in the PartnerFundRequest object.
* Accenture – Shridhar K        9/17/2018                     Replaced custom label with Id variable ccfRecordTypeId and dcfRecordTypeId.
* Intel – Narayani Perachi      9/24/2018                     Replaced variables from PFRMap to pfrMap, PFRList to pfrList, PRFreq to pfrReq as per Code scan suggestions
* Intel - Narayani Perachi      9/24/2018                     Added without sharing to class Core_MDF_ProcessCCP_PartnerFundRequest
* Accenture – Shridhar K        12/23/2018                    Added recallApprovalProcess method to recall approval process
* Intel - Narayani Perachi      02/01/2019                    SPCF Changes - Added getRecordIDFromEnvironment() to get all the CCP Recordtype IDs from the environment
* Intel - Narayani Perachi      02/01/2019                    SPCF Changes - Commented Lines #34,#35 and made changes to If() in #58
* Intel - Narayani Perachi      02/08/2019                    Made changes to incorporate Auto Approval of Activity if created/modified by Account Manager
* Accenture - Shridhar K        03/08/2019                    Modified recallApprovalProcess to prevent Approve/Reject/Reassign Cancelled Activity 
* Intel - Narayani Perachi      03/11/2019                    Made changes in checkIfActivitySubmitterIsAccountManager() to check if activity is updated by account manager     
* Intel - Narayani Perachi    03/12/2019            Made changes to catch block of every method to get the error deatils using Core_MDF_CCP_UtilityClass.getErrorDetails()
* Accenture - Sai Sugathri      06/07/2019                    Added approvers from six to ten in tobeUpdatedList
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Custom Labels used:
* Core_MDF_CCP_Account_Manager_Permission_Sets : Core_MDF_CCP_Internal_CCF_Account_Manager,Core_MDF_CCP_Internal_DCF_Account_Manager,Core_MDF_CCP_Internal_SPCF_Account_Manager
* Core_MDF_Activity_Cancelled_Status           : Cancelled
* Core_MDF_Activity_Recall_Exception_Origin    : Activity Recall Process
*********************************************************************************************************************************************************************************/
public without sharing class test_KA {
    
    public static Boolean runOnce = true;
    public static Boolean apprunOnce = true;
    public static Boolean emailSendOnce = true;    //DE115127
    public static Boolean sendEmailOnce = true;
    public static Boolean plannedEmailSendOnce = true;
    public static Boolean camprunonce = true;
    public static String logEntryMsg = '';
    public static Boolean isError = false;
    public static Boolean recallRunOnce = true;
    
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    public static Map<Id,List<Id>> objectIdUserGroupIdListMap = new Map<Id,List<Id>>();
    public static final List<String> channelMDFBudgetTypes = new List<String>{'Intel MDF Account Based1','Intel MDF Account Based2'}; 
    public static Boolean stopRecursion = false;
    
    //Commented the following code as part of SPCF Changes - Narayani Perachi
    //Follwing record type id variables are added by Shridhar to replace custom label
    //public static Id ccfRecordTypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId();
    //public static Id dcfRecordTypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Data_Center_CoMarketing_Fund').getRecordTypeId();
    
    //public static Map<id,string> ccpRecordTypeIds= getRecordIDFromEnvironment();
    
     /* public static void callApprovalProcess(Map<id,PartnerFundRequest> pfrMap, List<PartnerFundRequest> pfrList, List<SObject> sObjectList, Boolean emeaSubmission)
      
    {
        system.debug('pfrList'+pfrList);
        List<PartnerFundRequest> toBeUpdated = new List<PartnerFundRequest>();
        List<PartnerFundRequest> toBeUpdatedApproval = new List<PartnerFundRequest>();
        List<PartnerFundRequest> toBeUpdatedNullApproval = new List<PartnerFundRequest>();
        List<PartnerFundRequest> toBeSentForApproval = new List<PartnerFundRequest>();
        List<SObject> toBeProcessed = new List<SObject>();  
        List<string> nullApprovers = new List<string>();
        Set<id> campaignId = new set<id>();
        
        List<PartnerFundRequest> checkIfSubmittedByAccountManagerInput = new List<PartnerFundRequest>();
        Map<string,List<sobject>> checkIfSubmittedByAccountManagerOutput = new Map<string,List<sobject>>();
        
        Map<String, Map<String,List<Id>>> sObjResultMap = new Map<String, Map<String,List<Id>>>();
        Map<Id, string> autoApprovedmap = new Map<Id, string>();
        Map<String,List<id>> approvalRequiredmap = new Map<String,List<id>>();
        Map<Id, string> approvalTemplatemap = new Map<Id, string>();
        Map<String, list<id>> accountManagerApproverList = new  Map<String, list<id>>();
        Map<id,string> idAndUpdateStatus = new Map<id,string>();
        Map<Id, Set<PartnerFundRequest>> userIdPFRSetMap = new Map<Id , Set<PartnerFundRequest>>(); 
        Set<Id> pfrRetailIdForManagerApproverSet = new Set<Id>();
        
        Map<id,Boolean> pfrIdxtranlFlagMap = new Map<id,Boolean>();
        List<PartnerFundRequest> pendingApprovalPfrList = new List<PartnerFundRequest>();
        List<PartnerFundRequest> pendingApprovalEmailList = new List<PartnerFundRequest>();
        List<PartnerFundRequest> plannedPfrList = new List<PartnerFundRequest>();
        
        
        Set<Id> accIdSet = new Set<Id>();
        Set<String> perSetStr = new Set<String>();
        Set<String> accStrSet = new Set<String>();        
        List<PartnerFundRequest> clearApproversPfrList = new List<PartnerFundRequest>();
        Decimal thresholdAmount = Decimal.ValueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ManagerApprovalThreshold'));
        Boolean ccfFieldOwner = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Field_Owner'));
        Boolean dcfFieldOwner = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Field_Owner'));
        Boolean ccfMarketingOwner = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Marketing_Owner'));
        Boolean dcfMarketingOwner = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Marketing_Owner'));
        Boolean geoApprover = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Marketing_GEO_Approver');
        List<PartnerFundRequest> frontEndReviewList = new List<PartnerFundRequest>();
        List<PartnerFundRequest> revReqPfrList = new List<PartnerFundRequest>();
        //added by Akilan
        Boolean priceReviewer = FeatureManagement.checkPermission('Core_MDF_PriceReviewer');
        List<PartnerFundRequest> pendingPCTApprovalPFR = new List<PartnerFundRequest>();
        List<String> geoList = new List<String>();
        List<String> accntList = new List<String>();
        List<String> programList = new List<String>();
        //added H
        List<String> pfrAccntList = new List<String>();
        List<String> pfrProgramList = new List<String>();
        List<String> pfrGeoList = new List<String>();
        List<String> pfrApprovalStageStatusList = new List<String>();
        List<String> pfrBudgetTypeList = new List<String>();
        List<PartnerFundRequest> pendingApprovalPFR = new List<PartnerFundRequest>(); 
        List<PartnerFundRequest> pendingReviewIPAPFR = new List<PartnerFundRequest>(); 
        //Set<Id> ultimateAccIdSet = new Set<Id>();
        //Retail Changes
        Boolean hasRetailCustomPermission = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Custom_Permission_IAM_Retail'));
        
        try{
            System.debug('isAfterFalse'+emeaSubmission);
            for(PartnerFundRequest pfrRec: pfrList){
                if(pfrRec.Core_MDF_Budget_Type_nm__c == 'RSA MD' || pfrRec.Core_MDF_Budget_Type_nm__c == 'MDF' || pfrRec.Core_MDF_Budget_Type_nm__c == 'OEM CMP' ){
                  //  frontEndReviewList.add(pfrRec);
                    Break;
                } 
                
            }
            
            if(frontEndReviewList.size() > 0){
                approvalProcessFrontEndReview(frontEndReviewList);
            }else{
                // Country Geo Map
                Map<String , String> countryGeoMap = new Map <String , String>();
                List<Core_MDF_CCP_Country_Geo_Mapping__mdt> countryGeoMetaDataList = Core_MDF_CCP_Country_Geo_Mapping__mdt.getAll().values();
                //for (Core_MDF_CCP_Country_Geo_Mapping__mdt countryGeoMetaData : [SELECT Id, MasterLabel, Core_MDF_Geo__c FROM Core_MDF_CCP_Country_Geo_Mapping__mdt]){
                for(Core_MDF_CCP_Country_Geo_Mapping__mdt countryGeoMetaData : countryGeoMetaDataList){ 
                    countryGeoMap.put(countryGeoMetaData.MasterLabel , countryGeoMetaData.Core_MDF_Geo__c );
                }
                

                for(PartnerFundRequest pfr: pfrList)
                {   system.debug('pfr.Core_MDF_Fund_Request_Status__c-->>'+pfr.Core_MDF_Fund_Request_Status__c+'Trigger.isInsert:'+Trigger.isInsert);
                 //added H pfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' && pfr.Core_MDF_Approval_Stage__c == 'Price Reviewer'
                 if((Trigger.isInsert == true && pfr.Core_MDF_Approval_Stage__c !=null) || (pfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' && (pfr.Core_MDF_Approval_Stage__c == 'L1 Approval'|| pfr.Core_MDF_Approval_Stage__c == 'L2 Approval' || pfr.Core_MDF_Approval_Stage__c == 'Program Office Reviewer'))){
                     pendingApprovalPFR.add(pfr);
                     pfrAccntList.add(pfr.Core_MDF_Ultimate_Account_Id__c);
                     pfrProgramList.add(pfr.Core_MDF_Program__c);
                     pfrGeoList.add(pfr.Core_MDF_Region_nm__c);
                     system.debug('pfr.Core_MDF_Approval_Stage__c:Notify'+pfr.Core_MDF_Approval_Stage__c);
                     pfrApprovalStageStatusList.add(pfr.Core_MDF_Approval_Stage__c);
                     pfrBudgetTypeList.add(pfr.Core_MDF_Budget_Type_nm__c);
                 }
                 if((pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Exception_PendingReview_Status') 
                     || pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Approval_Nm')) 
                    && (ccpRecordTypeIds.containsKey(pfr.RecordTypeId)) 
                    && pfr.Core_MDF_Fund_Request_Status__c != label.Core_MDF_PFR_Status_Closed){
                        if (pfr.Core_MDF_Program__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name')){
                            //Channel MDF Changes - scope- CCF, DCF and Channel MDF  
                           if((pfr.Core_MDF_Program__c == 'Client Co-Marketing Fund' || pfr.Core_MDF_Program__c == 'Data Center Co-Marketing Fund' || pfr.Core_MDF_Program__c == 'Channel MDF' ) &&
                             // (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP').equals(pfr.Core_MDF_Budget_Type_nm__c) || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDF').equals(pfr.Core_MDF_Budget_Type_nm__c) || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDFPlus').equals(pfr.Core_MDF_Budget_Type_nm__c) || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP').equals(pfr.Core_MDF_Budget_Type_nm__c) )){
                              (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_OPAL_CustomerAutoApprBudgetType').contains(pfr.Core_MDF_Budget_Type_nm__c) || pfr.Core_MDF_Proposal_Based_Ind__c == false)){      
                                    if(pfr.Core_MDF_Approval_Step_Completed__c == 0){
                                        checkIfSubmittedByAccountManagerInput.add(pfr);  
                                        //added to trigger approval notification for customers for cmp/spcmp activity without additional review
                                        if((Label.Core_MDF_BudgetType_CMP.equals(pfr.Core_MDF_Budget_Type_nm__c) || Label.Core_MDF_BudgetType_SP_CMP.equals(pfr.Core_MDF_Budget_Type_nm__c)) && pfr.Core_MDF_Fund_Request_Status__c == Label.Core_MDF_Status_Pending_Approval_Nm && !pfr.Core_MDF_Require_Additional_Review_ind__c){
                                            //pendingApprovalPfrList.add(pfr);
                                            pfrIdxtranlFlagMap.put(pfr.id,true);
                                            accIdSet.add(pfr.ChannelPartnerId);
                                        }
                                    }
                                    else if((pfr.Core_MDF_Approval_Step_Completed__c == 1 && !pfr.Core_MDF_Price_reviewer_check_ind__c &&
                                             !pfr.Core_MDF_Program_Office_Check_ind__c && pfr.Core_MDF_Require_Additional_Review_ind__c) || 
                                            (pfr.Core_MDF_Approval_Step_Completed__c == 2 && pfr.Core_MDF_Program_Office_Check_ind__c &&
                                             !pfr.Core_MDF_Price_reviewer_check_ind__c && pfr.Core_MDF_Require_Additional_Review_ind__c) || 
                                            (pfr.Core_MDF_Approval_Step_Completed__c == 3 && pfr.Core_MDF_Price_reviewer_check_ind__c &&
                                             pfr.Core_MDF_Require_Additional_Review_ind__c)) 
                                    {
                                        checkIfSubmittedByAccountManagerInput.add(pfr);  
                                    }
                                    
                                    else if(((pfr.Core_MDF_Approval_Step_Completed__c == 1 && !pfr.Core_MDF_Program_Office_Check_ind__c 
                                              && !pfr.Core_MDF_Price_reviewer_check_ind__c && !pfr.Core_MDF_Require_Additional_Review_ind__c &&  pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c < thresholdAmount) ||
                                             //condition to send the activity to customer acceptance, when edited by Internal user with Intel Contribution > 50K for CMP and SPCMP
                                             (pfr.Core_MDF_Approval_Step_Completed__c == 1 && !pfr.Core_MDF_Program_Office_Check_ind__c 
                                              && !pfr.Core_MDF_Price_reviewer_check_ind__c && !pfr.Core_MDF_Require_Additional_Review_ind__c 
                                              && pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c >= thresholdAmount 
                                              &&(Label.Core_MDF_BudgetType_CMP.equals(pfr.Core_MDF_Budget_Type_nm__c) || Label.Core_MDF_BudgetType_SP_CMP.equals(pfr.Core_MDF_Budget_Type_nm__c))
                                             ) ||  //condition end                                         
                                             (pfr.Core_MDF_Approval_Step_Completed__c == 2 && pfr.Core_MDF_Program_Office_Check_ind__c && 
                                              !pfr.Core_MDF_Price_reviewer_check_ind__c && !pfr.Core_MDF_Require_Additional_Review_ind__c &&  pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c < thresholdAmount) ||
                                             (pfr.Core_MDF_Approval_Step_Completed__c == 3 && pfr.Core_MDF_Price_reviewer_check_ind__c && 
                                              !pfr.Core_MDF_Require_Additional_Review_ind__c &&  pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c < thresholdAmount) ||
                                             (pfr.Core_MDF_Approval_Step_Completed__c == 4 && pfr.Core_MDF_Require_Additional_Review_ind__c && 
                                              pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c < thresholdAmount) ||
                                             (pfr.Core_MDF_Approval_Step_Completed__c == 4 && ((pfr.Core_MDF_Program__c =='Channel MDF' || pfr.Core_MDF_Program__c =='Intel Partner Alliance')  && pfr.Core_MDF_Proposal_Based_Ind__c == false) && //Channel MDF Changes
                                              pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c >= thresholdAmount) ||
                                             (pfr.Core_MDF_Approval_Step_Completed__c == 5 && 
                                              pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c >= thresholdAmount)) ||
                                            (pfr.Core_MDF_Approval_Step_Completed__c == 4 && pfr.Core_MDF_Require_Additional_Review_ind__c && 
                                             (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP').equals(pfr.Core_MDF_Budget_Type_nm__c) || 
                                              Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP').equals(pfr.Core_MDF_Budget_Type_nm__c)))){
                                                  
                                                  system.debug('inside condition if-->');                                            
                                                  //US1011425: Customer Auto Approval for MDF and MDF+ if no edit done by internal account manager - start
                                                  //US1109412: Condition added for Customer auto approval for OEM CMP/ SP CMP
                                                  Boolean approvalReqr = true;
                                                 
                                                  
                                                  if(pfr.Core_MDF_Is_Field_Modified__c == false && pfr.Core_MDF_Activity_CreatedByExternalUsr__c == true && ((Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_OPAL_CustomerAutoApprBudgetType').contains(pfr.Core_MDF_Budget_Type_nm__c)) || ((pfr.Core_MDF_Program__c =='Channel MDF' || pfr.Core_MDF_Program__c =='Intel Partner Alliance')  && pfr.Core_MDF_Proposal_Based_Ind__c == false))){
                                                      approvalReqr = false;
                                                      
                                                  }
                                                  
                                                  if(approvalReqr){
    
                                                      pfrIdxtranlFlagMap.put(pfr.id,true);
                                                      accIdSet.add(pfr.ChannelPartnerId); 
                                                      system.debug('<<pfrstatus--afterUpdate>>' +pfr.Core_MDF_Fund_Request_Status__c);
                                                  }
                                                  
                                                  
                                                  
                                              }
                                   
                                    else if(pfr.Core_MDF_Approver_1__c != NULL){
                                        clearApproversPfrList.add(pfr);
                                    }else{
                                        checkIfSubmittedByAccountManagerInput.add(pfr); 
                                    }    
                                }else{
                                    checkIfSubmittedByAccountManagerInput.add(pfr);
                                }
                        }else{
                            if(pfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name')){
                                
                                
                                if(pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Approval_Nm')){                                
                                    pendingApprovalPfrList.add(pfr);
                                    accIdSet.add(pfr.ChannelPartnerId);
                                    System.debug('pendingApprovalPfrList'+pendingApprovalPfrList);
                                    
                                }else{
                                    System.debug('NZ-->pfr.Core_MDF_Approval_Step_Completed__c: '+pfr.Core_MDF_Approval_Step_Completed__c);
                                    
                                    //rmf external mail
                                    
                                    if(pfr.Core_MDF_Approval_Step_Completed__c == 1 &&
                                       ((pfr.RequestedAmount >= 25000 && pfr.RequestedAmount < 250000) || (pfr.RequestedAmount >= 250000 ))){if(userIdPFRSetMap.containsKey(pfr.CreatedById)){userIdPFRSetMap.get(pfr.CreatedById).add(pfr);
                                                                                                                                                                                             }
                                                                                                                                             else{userIdPFRSetMap.put(pfr.CreatedById, new set<PartnerFundRequest>{pfr});}pfrRetailIdForManagerApproverSet.add(pfr.Id);
                                                                                                                                            }
                                    if(pfr.Core_MDF_Approval_Step_Completed__c == 2 && (pfr.RequestedAmount >= 250000 )){
                                        if(userIdPFRSetMap.containsKey(pfr.Core_MDF_Approver_1__c)){
                                            userIdPFRSetMap.get(pfr.Core_MDF_Approver_1__c).add(pfr);
                                        }else{
                                            userIdPFRSetMap.put(pfr.Core_MDF_Approver_1__c, new set<PartnerFundRequest>{pfr});
                                        }
                                        
                                        pfrRetailIdForManagerApproverSet.add(pfr.Id);
                                    }
                                    System.debug('NZ-->pfr.Core_MDF_Approver_1__c: '+pfr.Core_MDF_Approver_1__c);
                                    //userIdPFRSetMap.put('005g0000006oegH', new set<PartnerFundRequest>{pfr});
                                    System.debug('NZ-->userIdPFRSetMap: '+userIdPFRSetMap);
                                }
                            }
                            // Get all the Geo values to check the existence with the PFR
                            Set<String> geoSet = new Set<String>();
                            if(pfr.Core_MDF_Country_nm__c != NULL){
                                for(String splitCountry : pfr.Core_MDF_Country_nm__c.split(';'))
                                {
                                    if(countryGeoMap.containsKey(splitCountry)){
                                        geoSet.add(countryGeoMap.get(splitCountry));    
                                        break;
                                    }                                
                                }
                            }
                            //Retail Changes
                            if(pfr.Core_MDF_Program__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_IPA')){//Any program except IPA
                                // US949836 : New Budget Type field changes replaced txt field with new global picklist field
                                if(((!emeaSubmission && !geoSet.contains('EMEA')) || 
                                    (!emeaSubmission && pfr.Core_MDF_Approval_Step_Completed__c > 0) || 
                                    (emeaSubmission ) || (hasRetailCustomPermission && pfr.Core_MDF_Start_Date__c < System.today() && !geoSet.contains('EMEA'))) &&
                                   pfr.Core_MDF_Budget_Type_nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDFPlus') &&
                                   pfr.Core_MDF_Budget_Type_nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP') &&
                                   pfr.Core_MDF_Budget_Type_nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDF') &&
                                   pfr.Core_MDF_Budget_Type_nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP')){//For 2nd Emea Approval,directly go for Approval
                                       if(checkIfSubmittedByAccountManagerOutput != NULL && checkIfSubmittedByAccountManagerOutput.size() > 0 && 
                                          checkIfSubmittedByAccountManagerOutput.containsKey('approvalReq')){
                                              System.debug('<<Inside 273>>');
                                              checkIfSubmittedByAccountManagerOutput.get('approvalReq').add(pfr);
                                          }
                                       else {
                                           System.debug('<<Inside 277>>');
                                           checkIfSubmittedByAccountManagerOutput.put('approvalReq',new List<sobject>{pfr});
                                       }
                                   }
                           }
                        }
                    }
                 /*else if(pfr.Core_MDF_Owner_nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Intel_System_User') && pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Revision_Required') && ( Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Program_Name').equals(pfr.Core_MDF_Program__c) ||  Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Program_Name').equals(pfr.Core_MDF_Program__c)) &&
(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP').equals(pfr.Core_MDF_Budget_Type_nm__c) || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP').equals(pfr.Core_MDF_Budget_Type_nm__c) || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDF').equals(pfr.Core_MDF_Budget_Type_nm__c) || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDFPlus').equals(pfr.Core_MDF_Budget_Type_nm__c))){   
//US914737 : [Opal CCF/DCF] - Activity Rejection Notifications when rejected by POR, PCT & L2 Approver
//Get the proper PS for User based on budget type and program
//CCF 
// US949836 : New Budget Type field changes replaced txt field with new global picklist field 
if( Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Program_Name').equals(pfr.Core_MDF_Program__c)){

if(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP').equals(pfr.Core_MDF_Budget_Type_nm__c) || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP').equals(pfr.Core_MDF_Budget_Type_nm__c)){
//perSetStr.add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Marketing_Owner'));
perSetStr.add(Label.Core_MDF_CCF_Marketing_Acc_Mgr_PS);
}else if((Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDF').equals(pfr.Core_MDF_Budget_Type_nm__c)) || (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDFPlus').equals(pfr.Core_MDF_Budget_Type_nm__c))){
//perSetStr.add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Field_Owner'));
perSetStr.add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Field_Acc_Mgr_PS'));
}
}
//DCF
// US949836 : New Budget Type field changes replaced txt field with new global picklist field
if( Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Program_Name').equals(pfr.Core_MDF_Program__c)){

if(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP').equals(pfr.Core_MDF_Budget_Type_nm__c) || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP').equals(pfr.Core_MDF_Budget_Type_nm__c)){
//perSetStr.add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Marketing_Owner'));
perSetStr.add(Label.Core_MDF_DCF_Marketing_Acc_Mgr_PS);

}else if((Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDF').equals(pfr.Core_MDF_Budget_Type_nm__c)) ||(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDFPlus').equals(pfr.Core_MDF_Budget_Type_nm__c))){
//perSetStr.add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Field_Owner'));
perSetStr.add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Field_Acc_Mgr_PS'));
}
}
pendingApprovalPfrList.add(pfr);
accStrSet.add(pfr.Core_MDF_Ultimate_Account_Name__c);
}*/
                 // Activity Rejection Notifications to L1 Approver when rejected by POR, PCT & L2 Approver
            /*     System.debug('<<PFR Status>>' + pfr.Core_MDF_Fund_Request_Status__c + '<<Step Completed>>' + pfr.Core_MDF_Approval_Step_Completed__c );
                 if(pfr.Core_MDF_Approval_Step_Completed__c == 0 && pfr.Core_MDF_Fund_Request_Status__c == 'Revision Required' &&
                    pfr.Core_MDF_Activity_CreatedByExternalUsr__c == true && pfr.Core_MDF_L1_Approver_Id__c != NULL && pfr.Core_MDF_L1_Approver_Id__c != pfr.CreatedById &&
                    (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Program_Name').equals(pfr.Core_MDF_Program__c) ||  Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Program_Name').equals(pfr.Core_MDF_Program__c) ||(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_IPA').equals(pfr.Core_MDF_Program__c) && pfr.Core_MDF_Proposal_Based_Ind__c == false))){                           
                        revReqPfrList.add(pfr);                       
                    }
                 //added by Akilan
                 System.debug('<<priceReviewer>>' + priceReviewer);
                 if(pfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' && pfr.Core_MDF_Approval_Stage__c == 'Price Reviewer' && pfr.Core_MDF_Price_reviewer_check_ind__c
                   && !priceReviewer){
                     pendingPCTApprovalPFR.add(pfr);
                     accntList.add(pfr.Core_MDF_Ultimate_Account_Id__c);
                     programList.add(pfr.Core_MDF_Program__c);
                     geoList.add(pfr.Core_MDF_Region_nm__c);
                 }
                 
                 //external mail for planned activity
                 if(pfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name')){
                     if(pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Planned_Status')){                                
                         plannedPfrList.add(pfr);
                         accIdSet.add(pfr.ChannelPartnerId);
                     }
                    
                 }
                  if(pfr.Core_MDF_Program__c == 'Intel Partner Alliance' && pfr.Core_MDF_Proposal_Based_Ind__c == false){
                         system.debug('entered inside ipa check for IPA');
                         pendingReviewIPAPFR.add(pfr);
                     }
                 system.debug('plannedPfrList1-->'+plannedPfrList);
                 system.debug('accIdSet-->'+accIdSet);
                 system.debug('pfr status -->'+pfr.Core_MDF_Fund_Request_Status__c+'-->'+pfr.Core_MDF_Approval_Step_Completed__c);
                 //external mail for planned activity
                 
                }
                //Calling method to check if the Activity Submitter is Account Manager
                
                
                if(pfrIdxtranlFlagMap != NULL && pfrIdxtranlFlagMap.size()>0){
                    //Set Fund Request Status as 'Pending Approval'
                    for(id externalApprovalId : pfrIdxtranlFlagMap.keyset()){        
                        PartnerFundRequest autoApprovalpfr = new PartnerFundRequest(Id = externalApprovalId);
                        autoApprovalpfr.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
                        toBeUpdated.add(autoApprovalpfr);                                
                        
                    } 
                    System.debug('<<toBeUpdated@@>>' +toBeUpdated);
                }            
                else if (checkIfSubmittedByAccountManagerOutput.size() == 0){
                    checkIfSubmittedByAccountManagerOutput = checkIfActivitySubmitterIsAccountManager(checkIfSubmittedByAccountManagerInput);
                }
                System.debug('<<checkIfSubmittedByAccountManagerInput@@>>' +checkIfSubmittedByAccountManagerInput);
                System.debug('checkIfSubmittedByAccountManagerOutput => '+checkIfSubmittedByAccountManagerOutput);            
                for(string mapKey :checkIfSubmittedByAccountManagerOutput.keySet())
                {
                    
                    if(mapKey=='approvalReq')
                    {
                        for(sobject pfr:checkIfSubmittedByAccountManagerOutput.get(mapkey))
                        {
                            toBeProcessed.add(pfr);
                        }  
                    }
                   
                    else if(mapKey=='noApproval' && pendingReviewIPAPFR.size() == 0)
                    {
                        for(sobject pfr:checkIfSubmittedByAccountManagerOutput.get(mapkey))
                        { 
                            System.debug('<<autoapproval@@>>');
                            autoApprovedmap.put(pfr.Id, 'Planned');
                        }
                    }
                 }
                
                //Calling method to identify IDs for approval and their approvers
               
        System.debug('toBeProcessed => '+toBeProcessed);
                sObjResultMap = Core_MDF_GenericApprovalProcess.setApprovers(toBeProcessed);
                System.debug('sObjResultMap => '+sObjResultMap);
                Map<Id,Core_MDF_Approver__c> pfrIdApprId = new Map<Id,Core_MDF_Approver__c>();
                
                for(string key: sObjResultMap.keySet())
                { 
                    
                    //Assign all Approval required IDs to approvalRequired
                    if(key=='approvalRequired'){
                        for(string key1:sObjResultMap.get(key).keyset()){
                            if(sObjResultMap.get(key).keyset()!=NULL){
                                approvalRequiredmap.put(key1,sObjResultMap.get(key).get(key1));
                            }                                           
                        }
                    }
                    //Assign all Auto Approved IDs to autoApprovedmap
                   else if(key=='autoApproved' ) {

                        for(Id key1:sObjResultMap.get(key).keyset())
                        {
                            if(sObjResultMap.get(key).keyset()!=NULL && pendingReviewIPAPFR.size() == 0 )
                            {
                                autoApprovedmap.put(key1,'Planned');
                            }
                        }
                   }
                    //Assign Approval Template name
                    else{
                        for(string key2:sObjResultMap.get(key).keyset())
                        { 
                            if(sObjResultMap.get(key).keyset()!=NULL){
                                approvalTemplatemap.put(key,key2);
                            }
                        }
                    }                    
                }        
                //Set Fund Request Status as 'Planned' for all Auto approved IDs
                for(id autoApprovalID:autoApprovedmap.keyset())
                {        
                    if(runOnce)
                    {        
                        
                        
                        PartnerFundRequest autoApprovalpfr = new PartnerFundRequest(Id = autoApprovalID);
                        
                        system.debug('before planned-->'+ccfFieldOwner+'--'+dcfFieldOwner+'--'+ccfMarketingOwner+'--'+dcfMarketingOwner);
                        
                        //US964831: 2. For SPCF/CCFB/RMF/IPA/CCF1.0/DCF 1.0, set to Planned, for autoApproval if no approvers or no criteria
                        if(pfrMap.containsKey(autoApprovalID) && pfrMap.get(autoApprovalID).Core_MDF_Program__c != 'Channel MDF' &&
                           (pfrMap.get(autoApprovalID).Core_MDF_Budget_Type_nm__c == NULL || 
                            (pfrMap.get(autoApprovalID).Core_MDF_Budget_Type_nm__c != 'OEM CMP' && pfrMap.get(autoApprovalID).Core_MDF_Budget_Type_nm__c != 'Service Provider CMP') || //OEM created by Int/MDF(Int/EXt), always goes for approval
                            ((pfrMap.get(autoApprovalID).Core_MDF_Budget_Type_nm__c == 'OEM CMP' || pfrMap.get(autoApprovalID).Core_MDF_Budget_Type_nm__c == 'Service Provider CMP') && (!(ccfFieldOwner||dcfFieldOwner||ccfMarketingOwner||dcfMarketingOwner))) //OEM created by External, set to planned if auto approvalrequired when no criteria matches
                           )){ 
                               autoApprovalpfr.Core_MDF_Fund_Request_Status__c = 'Planned';
                               
                           }          
                        toBeUpdated.add(autoApprovalpfr);   
                    }
                    runOnce = false;
                }
                if(pfrRetailIdForManagerApproverSet != NULL && pfrRetailIdForManagerApproverSet.size() > 0){
                    for(id pfrId : pfrRetailIdForManagerApproverSet){
                        if(approvalRequiredmap.containsKey(pfrId)){
                            approvalRequiredmap.remove(pfrId);
                        }
                    }
                }
                //Initiate Approval Process
                // US949836 : New Budget Type field changes replaced txt field with new global picklist field
                for(id appRequiredID:approvalRequiredmap.keyset()){
                    if(apprunOnce &&  approvalRequiredmap.get(appRequiredID) != NULL){                    
                        toBeUpdatedApproval = updateApprovers(approvalRequiredmap, pfrMap);
                        System.debug('Ak1-->toBeUpdatedApproval' + toBeUpdatedApproval);
                    }else if(approvalRequiredmap.get(appRequiredID) == NULL && 
                             pfrMap.get(appRequiredID).Core_MDF_Program__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name') && 
                             pfrMap.get(appRequiredID).Core_MDF_Program__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_IPA') &&
                             pfrMap.get(appRequiredID).Core_MDF_Program__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP') &&
                             pfrMap.get(appRequiredID).Core_MDF_Budget_Type_nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP') && 
                             pfrMap.get(appRequiredID).Core_MDF_Budget_Type_nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDF') && 
                             pfrMap.get(appRequiredID).Core_MDF_Budget_Type_nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDFPlus')){
                                 campaignId.add(pfrMap.get(appRequiredID).CampaignId);
                                 nullApprovers.add(appRequiredID);
                             }
                    apprunOnce = false;
                }
                if(userIdPFRSetMap != NULL && userIdPFRSetMap.size() > 0){
                    toBeUpdatedApproval.addAll(updateRetailManagerApprovers(userIdPFRSetMap));
                    System.debug('NZ-->updateRetailManagerApprovers: '+updateRetailManagerApprovers(userIdPFRSetMap));
                }
                System.debug('NZ-->toBeUpdatedApproval: '+toBeUpdatedApproval);
                if(campaignId.size() > 0 && camprunonce){
                    accountManagerApproverList = assignAccountManagers(pfrMap,campaignId,nullApprovers);
                    if(accountManagerApproverList.size()>0){
                        toBeUpdatedNullApproval = updateApprovers(accountManagerApproverList, null);
                        toBeUpdatedApproval.addall(toBeUpdatedNullApproval);
                        System.debug('Ak2-->toBeUpdatedApproval');
                    }
                    camprunonce=false;
                }
                
                
                toBeUpdated.addall(toBeUpdatedApproval); //Adding all Autoapproval and Approval object to be updated
                
                if(toBeUpdated!=NULL && toBeUpdated.size()>0)
                {  
                    Map<String, Object> databaseResult = new map<String,Object>();
                    System.debug('<<Calling method to update pfr>>' + toBeUpdated);
                    databaseResult = Core_MDF_CCP_UtilityClass.updateListAndLogErrors(toBeUpdated, logEntryMsg);
                    idAndUpdateStatus = (Map<id,string>) databaseResult.get('DatabaseResult');
                    logEntryMsg = (string)databaseResult.get('ErrorMessage');
                }
                
                //Replacing toBeSentForApproval List with below Map
                Map<Id,PartnerFundRequest> updatedPfrMap = new Map<Id,PartnerFundRequest>();
                for(PartnerFundRequest updateId: toBeUpdatedApproval){
                    if(idAndUpdateStatus.get(updateId.Id) == 'Success'){
                        //toBeSentForApproval.add(updateId);
                        updatedPfrMap.put(updateId.Id,updateId);
                        System.debug('<<updatedPfrMap1>>' + updatedPfrMap); 
                    }
                }      
                
                
                
                //Call method to initiate Approval Process
                //callApprovalProcessCall(toBeSentForApproval,approvalTemplatemap,pfrList);
                //  if(!(geoApprover && geoEditFlag)){
                System.debug('<<PFRDetails>>' + updatedPfrMap + approvalTemplatemap + pfrList);
                callApprovalProcessCall(updatedPfrMap,approvalTemplatemap,pfrList); 
                System.debug('yyy');   
                //            Core_MDF_PFR_Rules_Processing.executeActivityRule((List<PartnerFundRequest>) pfrList,true);
                
                //}
                
                
                Boolean marketingUserUpdateSwitch = FALSE;                              
                
                if( mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_RMFActivityEmailValidation') && 
                   mapFunctionalityNameTriggerExecution.get('Core_MDF_RMFActivityEmailValidation') !=null &&
                   mapFunctionalityNameTriggerExecution.get('Core_MDF_RMFActivityEmailValidation').Core_Active__c){
                       marketingUserUpdateSwitch = TRUE;
                   }
                
                //DE115127
                if(marketingUserUpdateSwitch && emailSendOnce && pendingApprovalPfrList != NULL && pendingApprovalPfrList.Size() > 0 && accIdSet != NULL && accIdSet.Size() > 0){
                    notifyExternalReviewers(pendingApprovalPfrList,accIdSet);
                    System.debug('<<[487]>>');
                    emailSendOnce = false;
                }
                
                //Send RMf Email for Planned Activity 
                System.debug('check condition__>'+plannedEmailSendOnce+plannedPfrList+accIdSet);
                if(marketingUserUpdateSwitch && plannedEmailSendOnce && plannedPfrList != NULL && plannedPfrList.Size() > 0 && accIdSet != NULL && accIdSet.Size() > 0){
                    notifyExternalReviewers(plannedPfrList,accIdSet);
                    plannedEmailSendOnce = false;
                    system.debug('call external send plannned');
                }
                //
                
             
                if(revReqPfrList != NULL && revReqPfrList.Size() > 0){
                    System.debug('<<Final revReqPfrList>>' + revReqPfrList);                   
                    notifyInternalApproversOnRejection(revReqPfrList);
                    emailSendOnce = false;
                } 
                if(pendingPCTApprovalPFR != NULL && pendingPCTApprovalPFR.Size() > 0){
                    System.debug('<<Final pendingPCTApprovalPFR>>' + pendingPCTApprovalPFR);                   
                    notifyPCTApprovers(pendingPCTApprovalPFR, accntList, geoList, programList);
                    emailSendOnce = false;
                }
                //pfrApprovalStageStatusList.add('L1 Approval');
                if(pendingApprovalPFR != Null && pendingApprovalPFR.size()>0){
                    notifyApprovers(pendingApprovalPFR,pfrAccntList,pfrGeoList,pfrProgramList,pfrApprovalStageStatusList,pfrBudgetTypeList);
                }
                
            }
            
        }
        catch(exception ex)
        {
            logEntryMsg += Core_MDF_CCP_UtilityClass.getErrorDetails(ex);
            isError = true;
        }      
        finally
        {           
            if(isError || idAndUpdateStatus.values().contains('Failed'))
            {
                Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'PFR Trigger - Main class()');
            }
        }   
    }*/
    /*****************************************************************************************************
Method Name :   notifyInternalApprovers
@return     :   NULL
@parameters :   pfr list, account set,permission set 
Description :   Notification to internal field.marketing owner
Added By    :   
US          :   US914737 : [Opal CCF/DCF] - Activity Rejection Notifications when rejected by POR, PCT & L2 Approver
Modified By :                      Date:03/29/2021                     Changes:None
******************************************************************************************************/
 /*   public static void notifyInternalApprovers(List<PartnerFundRequest> pfrList, Set<String> accNameSet, Set<String> perSetStr){
        
        
        Map<String,Set<Id>> accIdUserNmSetMap = new Map<String,Set<Id>>();
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> userWithReqdPermissionSet = new Set<Id>();
        List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();
        if(accNameSet != NULL && accNameSet.Size() > 0){
            
            //Fetch User Info w.r.t Account using IUPGM
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [SELECT Id,Core_MDF_Account_id__c,Core_MDF_User_id__c,Core_MDF_Active_Ind__c,Core_MDF_Account_id__r.Name
                                                                   FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                   WHERE Core_MDF_Account_id__r.Name  IN: accNameSet AND 
                                                                   Core_MDF_is_User_Active_ind__c = TRUE AND
                                                                   Core_MDF_Active_Ind__c = TRUE]){ 
                                                                       
                                                                       if(accIdUserNmSetMap.containsKey(iupgm.Core_MDF_Account_id__r.Name)){
                                                                           accIdUserNmSetMap.get(iupgm.Core_MDF_Account_id__r.Name).add(iupgm.Core_MDF_User_id__c);
                                                                       }else{
                                                                           accIdUserNmSetMap.put(iupgm.Core_MDF_Account_id__r.Name, new Set<Id> {iupgm.Core_MDF_User_id__c});
                                                                       }
                                                                       userIdSet.add(iupgm.Core_MDF_User_id__c);
                                                                       accIdSet.add(iupgm.Core_MDF_Account_id__c);                
                                                                   }            
        }
        //Check if User has required Permission
        if(userIdSet != NULL  && userIdSet.size() > 0){
            for(PermissionSetAssignment usrPer : [SELECT Id, AssigneeId, Assignee.AccountId, Assignee.IsActive, PermissionSet.Name 
                                                  FROM PermissionSetAssignment WHERE AssigneeId IN :userIdSet 
                                                  AND (PermissionSet.Name IN :perSetStr)]){                                                           
                                                      userWithReqdPermissionSet.add(usrPer.AssigneeId);
                                                  }
        }  
        //sendEmailNotification(pfrList,accIdSet,accIdUserIdSetMap,userIdSet);
        //Trigger email using template Core_MDF_NotifyActivityApprovers
        for(PartnerFundRequest pfr : pfrList){
            
            if(accNameSet.contains(pfr.Core_MDF_Ultimate_Account_Name__c)){
                for(Id userId : accIdUserNmSetMap.get(pfr.Core_MDF_Ultimate_Account_Name__c)){
                    if(userWithReqdPermissionSet.contains(userId)){
                        Core_MDF_GenericClassToSendMail.MailParams sendEmailToReviewer = new Core_MDF_GenericClassToSendMail.MailParams();
                        sendEmailToReviewer.recordId = pfr.Id;
                        sendEmailToReviewer.templateName = 'Core_MDF_Internal_Status_Change';
                        sendEmailToReviewer.userIdList = new List<Id>{userId};
                            sendEmailToReviewer.sendDiff = false;
                        inputList.add(sendEmailToReviewer);                        
                    }
                }
            }          
        }
        if(inputList != NULL && inputList.size() >0){
            System.debug('<<inputList>>' + inputList);
            Core_MDF_GenericClassToSendMail.sendEmailMethod(inputList);
        }
    } */
    /*****************************************************************************************************
Method Name :   notifyInternalApproversOnRejection
@return     :   NULL
@parameters :   pfr list 
Description :   Notification to L1 Approver 
Added By    :   
US          :   US914737 : [Opal CCF/DCF] - Activity Rejection Notifications when rejected by POR, PCT & L2 Approver
Modified By :                      Date:03/29/2021                     Changes:None
******************************************************************************************************/
    public static void notifyInternalApproversOnRejection(List<PartnerFundRequest> pfrList){
        
        List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();        
        for(PartnerFundRequest pfr : pfrList){
            //sending the email to L1 Approver, the email will be sent to created by user also through Process builder
            if(pfr != NULL && pfr.Core_MDF_L1_Approver_Id__c != NULL){ 
                System.debug('<<Inside [587]>>');
                Core_MDF_GenericClassToSendMail.MailParams sendEmailToReviewer = new Core_MDF_GenericClassToSendMail.MailParams();
                sendEmailToReviewer.recordId = pfr.Id;
                sendEmailToReviewer.templateName = 'Core_MDF_Internal_Status_Change';
                sendEmailToReviewer.userIdList = new List<Id>{pfr.Core_MDF_L1_Approver_Id__c};
                sendEmailToReviewer.sendDiff = false;
                inputList.add(sendEmailToReviewer);  
            }
        }
        
        if(inputList != NULL && inputList.size() >0){
            System.debug('<<inputList>>' + inputList);
            Core_MDF_GenericClassToSendMail.sendEmailMethod(inputList);           
            
        }
    }
        /*****************************************************************************************************
Method Name :   notifyCCFDCFExternalReviewer
@return     :   NULL
@parameters :   pfr list 
Description :   Activity Approval Notification to CCF/DCF activity creator only, 
                if the activity was created by external user and now its in pending approval status 
Added By    :   Akilan Murugan
US          :   TWC702-1696 - [CCF/DCF] - Notify Only Activity Submitter for Acceptance
Modified By :                      Date:03/11/2022                     Changes:None
******************************************************************************************************/    
    public static void notifyCCFDCFExternalReviewer(List<PartnerFundRequest> pfrList){
        
        List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();        
        for(PartnerFundRequest pfr : pfrList){
            //sending the Acceptance email to CCF/DCF activity creator only, if the activity was created by external user else to the Member Activity Owner 
            if(pfr != NULL && pfr.Core_MDF_Member_Acceptor_Id__c != NULL){ 
                Core_MDF_GenericClassToSendMail.MailParams sendEmailToReviewer = new Core_MDF_GenericClassToSendMail.MailParams();
                sendEmailToReviewer.recordId = pfr.Id;
                sendEmailToReviewer.templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ExternalStatusChangeCCFDCF');
                sendEmailToReviewer.userIdList = new List<Id>{pfr.Core_MDF_Member_Acceptor_Id__c};
                sendEmailToReviewer.sendDiff = false;
                inputList.add(sendEmailToReviewer); 
            }
        }
        
        if(inputList != NULL && inputList.size() >0){
            System.debug('<<inputList702>>' + inputList);
            Core_MDF_GenericClassToSendMail.sendEmailMethod(inputList);           
            
        }
    }
        
            /*****************************************************************************************************
Method Name :   notifyPCTApprovers
@return     :   NULL
@parameters :   pfr list,accntList,geoList,programList
Description :   Activity Approval Notification to PCT Approvers
Added By    :   Akilan Murugan
US          :   
Modified By :                      Date:03/11/2022                     Changes:None
******************************************************************************************************/    
    public static void notifyPCTApprovers(List<PartnerFundRequest> pfrList, List<String> accntList, List<String> geoList, List<String> programList){
        
        List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();      
        Set<Id> userIdSet = new Set<Id>();   
        String pctRole = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Price_Reviewer_Roles');
        String emailTemplate;
        Map<String,Object> emailTemplateMap;
        
        Map<String, Map<String, List<Id>>> resultMap = new Map<String, Map<String, List<Id>>>();
              resultMap = Core_MDF_GeneralPurpose_UI_Utility.getIupgmRecordsPCT(accntList,programList,geoList,pctRole);
        
        Map<String,Object> programNameByRecNameMap = Core_MDF_GeneralPurpose_UI_Utility.getProgramNameByRecName();            
            for(PartnerFundRequest pfr : pfrList){
                String program = '';
                Map<string,List<Id>> resultsubMap;
                    if(programNameByRecNameMap.containsKey(pfr.Core_MDF_Program__c)){
                         program = ((String)programNameByRecNameMap.get(pfr.Core_MDF_Program__c));
                }
                List<Id> userIds;
                if(resultMap != null){
                    
                        String allAccountNOKey = program+pfr.Core_MDF_Region_nm__c+pctRole+pfr.Core_MDF_Ultimate_Account_Id__c;
                        String allAccountNOKeyWW = program+'WW'+pctRole+pfr.Core_MDF_Ultimate_Account_Id__c;
                        String allAccountYesKey = program+pfr.Core_MDF_Region_nm__c+pctRole+'null';
                        String allAccountYesKeyWW = program+'WW'+pctRole+'null';
                        System.debug('<<allAccountNOKey>>' + allAccountNOKey + '<<allAccountNOKeyWW>>' + allAccountNOKeyWW + '<<allAccountYesKey>>' + allAccountYesKey + '<<allAccountYesKeyWW>>' + allAccountYesKeyWW);
                    userIds = new List<Id>();
                    if(resultMap.containsKey('allAccountsYesOrNo')){
                        resultsubMap = resultMap.get('allAccountsYesOrNo');                        
                        for(String key :resultsubMap.keySet()){
                            if(key == allAccountNOKey || key == allAccountNOKeyWW ||
                               key == allAccountYesKey || key == allAccountYesKeyWW){
                                   userIds.addAll(resultsubMap.get(Key));
                               }
                        }
                    }else if(resultMap.containsKey('allAccountsYes')){                        
                        resultsubMap = resultMap.get('allAccountsYes');
                        for(String key :resultsubMap.keySet()){
                            if(key == allAccountYesKey || key == allAccountYesKeyWW){
                                   userIds.addAll(resultsubMap.get(Key));
                               }
                        }
                    }else if(resultMap.containsKey('allAccountsNO')){
                        resultsubMap = resultMap.get('allAccountsNO');
                        for(String key :resultsubMap.keySet()){
                            if(key == allAccountNOKey || key == allAccountNOKeyWW){
                                   userIds.addAll(resultsubMap.get(Key));
                               }
                        }
                    }
                }

                 if(pfr.Core_MDF_Program__c == 'Intel Partner Alliance' && pfr.Core_MDF_Proposal_Based_Ind__c != true)
                     {
                         emailTemplateMap = getTemplateNameByProgNameIPA();
                     }
                else
                    {
                        emailTemplateMap = getTemplateNameByProgName();
                    }

                if(!emailTemplateMap.isEmpty() && emailTemplateMap.containsKey(pfr.Core_MDF_Program__c)){
                          emailTemplate = (String)emailTemplateMap.get(pfr.Core_MDF_Program__c);
                   }

                if(userIds != NULL && !userIds.isEmpty()){
                    Core_MDF_GenericClassToSendMail.MailParams sendEmailToPRCReviewer = new Core_MDF_GenericClassToSendMail.MailParams();
                    sendEmailToPRCReviewer.recordId = pfr.Id;
                    sendEmailToPRCReviewer.templateName = emailTemplate;
                    sendEmailToPRCReviewer.userIdList = userIds;
                    sendEmailToPRCReviewer.sendDiff = false;
                    inputList.add(sendEmailToPRCReviewer);                    
                }
                
            }
        
        if(inputList != NULL && inputList.size() >0 ){
            System.debug('<<inputList>>' + inputList);
            Core_MDF_GenericClassToSendMail.sendEmailMethod(inputList); 
            
        }
    }
        /*****************************************************************************************************
Method Name :   notifyApprovers
@return     :   NULL
@parameters :   pfr list 
Description :   Activity Approval Notification to  Approvers
Added By    :   Harshadeep Kalita
US          :   
Modified By :                      Date:21/06/2022                     Changes:None
******************************************************************************************************/    
    public static void notifyApprovers(List<PartnerFundRequest> pfrList, List<String> accntList, List<String> geoList, List<String> programList,
                                      List<String> approvalStageStatusList,List<String> budgetTypeList){

        List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();      
        Set<Id> userIdSet = new Set<Id>();   
        List<String> roleList = new List<String>();  
        Map<String, String> approvalStageToRoleMap = new Map<String, String>();
        Map<String, String> programToEmailTemplateMap = new Map<String, String>();                                  
       // Map<String, Object> emailTemplateMap = getTemplateNameByProgName();
        Map<String,string> roleCheckforAccountAccessMap = new Map<String,string>();
        String emailTemplate;                                  
        String category ='notifyIUPGMBasedNotification';
        String categoryGeneralUtility = 'Core_MDF_GeneralPurpose_UI_Utility_Role_Mappings';                                                                    
        List<Core_MDF_Custom_Label_Configration__mdt> mdtRecList = [SELECT DeveloperName, Core_MDF_Value_Txt__c, Core_MDF_Value2_Txt__c,
                                                                    Core_MDF_Value3_Txt__c,Core_MDF_Value4_Txt__c, Core_MDF_Category_Txt__c, 
                                                                    Core_MDF_Org_Specific_Ind__c,Core_MDF_Value5_Txt__c
                                                                    FROM Core_MDF_Custom_Label_Configration__mdt 
                                                                    WHERE Core_MDF_Category_Txt__c =: category 
                                                                    AND Core_MDF_Value3_Txt__c IN:approvalStageStatusList 
                                                                    AND Core_MDF_Value_Txt__c IN:programList AND (Core_MDF_Value5_Txt__c IN:budgetTypeList OR Core_MDF_Value5_Txt__c=null)];
        System.debug('mdtRecListNotifyApprovers--> '+mdtRecList);                                 
        for(Core_MDF_Custom_Label_Configration__mdt meta: mdtRecList){
            roleList.add(meta.Core_MDF_Value4_Txt__c);
            programToEmailTemplateMap.put(meta.Core_MDF_Value_Txt__c,meta.Core_MDF_Value2_Txt__c);
            
            if(!String.isBlank(meta.Core_MDF_Value5_Txt__c)){
                approvalStageToRoleMap.put(meta.Core_MDF_Value_Txt__c+meta.Core_MDF_Value5_Txt__c+meta.Core_MDF_Value3_Txt__c, meta.Core_MDF_Value4_Txt__c);    
            }else{
                approvalStageToRoleMap.put(meta.Core_MDF_Value_Txt__c+meta.Core_MDF_Value3_Txt__c, meta.Core_MDF_Value4_Txt__c);    
            }
            
        }    
        System.debug('approvalStageToRoleMap--> '+approvalStageToRoleMap);                                        
        //String pctRole = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Price_Reviewer_Roles');
        List<Core_MDF_Custom_Label_Configration__mdt> mdtAccountRecList =  [SELECT DeveloperName, Core_MDF_Value_Txt__c,Core_MDF_Value2_Txt__c,Core_MDF_Value3_Txt__c,
                                                                            Core_MDF_Value4_Txt__c,Core_MDF_Category_Txt__c, Core_MDF_Org_Specific_Ind__c
                                                                            FROM Core_MDF_Custom_Label_Configration__mdt WHERE Core_MDF_Category_Txt__c =: categoryGeneralUtility
                                                                            AND Core_MDF_Value_Txt__c IN: programList AND Core_MDF_Value2_Txt__c IN: roleList]; 
        
        for(Core_MDF_Custom_Label_Configration__mdt mdtRec: mdtAccountRecList){
            roleCheckforAccountAccessMap.put(mdtRec.Core_MDF_Value_Txt__c+mdtRec.Core_MDF_Value2_Txt__c,mdtRec.Core_MDF_Value3_Txt__c);
        }       
        System.debug('roleCheckforAccountAccessMap--->>' + roleCheckforAccountAccessMap);                                  
        Map<String, Map<String, List<Id>>> resultMap = new Map<String, Map<String, List<Id>>>();
        resultMap = Core_MDF_GeneralPurpose_UI_Utility.getIupgmRecordsForApprovers(accntList,programList,geoList,roleList);
        System.debug('resultMap::--> '+resultMap);              
        Map<String,Object> programNameByRecNameMap = Core_MDF_GeneralPurpose_UI_Utility.getProgramNameByRecName(); 
        System.debug('programNameByRecNameMap::--> '+programNameByRecNameMap);                          
            for(PartnerFundRequest pfr : pfrList){
                String approvalMapKey = pfr.Core_MDF_Program__c+pfr.Core_MDF_Budget_Type_nm__c+pfr.Core_MDF_Approval_Stage__c;
                String approvalMapKeyWithoutBudgetType = pfr.Core_MDF_Program__c+pfr.Core_MDF_Approval_Stage__c;
                System.debug('approvalMapKey-->'+approvalMapKey);
                String program = '';
                Map<string, List<Id>> resultsubMap;
                    if(programNameByRecNameMap.containsKey(pfr.Core_MDF_Program__c)){
                         program = ((String)programNameByRecNameMap.get(pfr.Core_MDF_Program__c));   
                }
                System.debug('program::--> '+program);                          
                List<Id> userIds;
                if(resultMap != null){
                    String role ='';
                    if(approvalStageToRoleMap.containsKey(approvalMapKey)){
                      role = approvalStageToRoleMap.get(approvalMapKey);  
                    }else{
                      role = approvalStageToRoleMap.get(approvalMapKeyWithoutBudgetType);    
                    }
                    
                    String roleCheckforAccountKey = pfr.Core_MDF_Program__c+role;
                    System.debug('roleCheckforAccountKey-->'+roleCheckforAccountKey);
                    String accountAccess = roleCheckforAccountAccessMap.get(roleCheckforAccountKey);
                   
                    System.debug('accountAccess-->'+accountAccess);
                    System.debug('role-->'+role);
                        String allAccountNOKey = program+pfr.Core_MDF_Region_nm__c+role+pfr.Core_MDF_Ultimate_Account_Id__c;
                        String allAccountNOKeyWW = program+'WW'+role+pfr.Core_MDF_Ultimate_Account_Id__c;
                        String allAccountYesKey = program+pfr.Core_MDF_Region_nm__c+role+'null';
                        String allAccountYesKeyWW = program+'WW'+role+'null';
                        System.debug('<<allAccountNOKey>>' + allAccountNOKey + '<<allAccountNOKeyWW>>' + allAccountNOKeyWW + '<<allAccountYesKey>>' + allAccountYesKey + '<<allAccountYesKeyWW>>' + allAccountYesKeyWW);
                    userIds = new List<Id>();
                    if(resultMap.containsKey(role) && accountAccess=='allAccountsYesOrNo'){
                        resultsubMap = resultMap.get(role);                        
                        for(String key :resultsubMap.keySet()){
                            if(key == allAccountNOKey || key == allAccountNOKeyWW ||
                               key == allAccountYesKey || key == allAccountYesKeyWW){
                                   userIds.addAll(resultsubMap.get(Key));
                               }
                        }
                    }else if(resultMap.containsKey(role) && accountAccess=='allAccountsYes'){
                        System.debug('<<Inside allAccountsYes Condition>>');
                        resultsubMap = resultMap.get(role);
                        for(String key :resultsubMap.keySet()){
                            if(key == allAccountYesKey || key == allAccountYesKeyWW){
                                   userIds.addAll(resultsubMap.get(Key));
                               }
                        }
                    }else if(resultMap.containsKey(role) && accountAccess=='allAccountsNo'){
                        resultsubMap = resultMap.get(role);
                        System.debug('resultsubMap-->'+resultsubMap);
                        for(String key :resultsubMap.keySet()){
                            if(key == allAccountNOKey || key == allAccountNOKeyWW){
                                   userIds.addAll(resultsubMap.get(Key));
                               }
                        }
                    }
                }
                System.debug('<<userIds>>' + userIds);
                //System.debug('<<emailTemplateMap>>' + emailTemplateMap);
                if(programToEmailTemplateMap.containsKey(pfr.Core_MDF_Program__c)){
                    emailTemplate = programToEmailTemplateMap.get(pfr.Core_MDF_Program__c);    
                }
                
                /*if(!emailTemplateMap.isEmpty() && emailTemplateMap.containsKey(pfr.Core_MDF_Program__c)){
                    
                     if(pfr.Core_MDF_Program__c == 'Intel Partner Alliance' && pfr.Core_MDF_Proposal_Based_Ind__c== false){
                        String programKey = pfr.Core_MDF_Program__c + ' Account Based';
                         emailTemplate = (String)emailTemplateMap.get(programKey);
                    }else{
                         emailTemplate = (String)emailTemplateMap.get(pfr.Core_MDF_Program__c);
                    }    
                 }*/
                System.debug('<<emailTemplate>>' + emailTemplate);
                if(userIds != NULL && !userIds.isEmpty()){
                    Core_MDF_GenericClassToSendMail.MailParams sendEmailToPRCReviewer = new Core_MDF_GenericClassToSendMail.MailParams();
                    sendEmailToPRCReviewer.recordId = pfr.Id;
                   // sendEmailToPRCReviewer.templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PCTApproverNotification');
                    sendEmailToPRCReviewer.templateName = emailTemplate;
                    sendEmailToPRCReviewer.userIdList = userIds;
                    sendEmailToPRCReviewer.sendDiff = false;
                    inputList.add(sendEmailToPRCReviewer);
                    System.debug('<<inputListLoop>>' + inputList);
                }
                
            }
        
        if(inputList != NULL && inputList.size() >0 && sendEmailOnce){
            System.debug('<<inputList>>' + inputList);
            Core_MDF_GenericClassToSendMail.sendEmailMethod(inputList); 
            sendEmailOnce = false;
        }
    }    
    public static void notifyExternalReviewers(List<PartnerFundRequest> pfrList, Set<Id> accIdSet){
        
        Map<Id,Set<Id>> accIdUserIdSetMap = new Map<Id,Set<Id>>();
        Set<Id> userIdSet = new Set<Id>();
        
        if(accIdSet != NULL && accIdSet.Size() > 0){
            for(Core_MDF_Partner_Node_User_Mapping__c pnum : [SELECT Id,Core_MDF_Account__c, Core_MDF_User__c 
                                                              FROM Core_MDF_Partner_Node_User_Mapping__c 
                                                              WHERE Core_MDF_Account__c IN : accIdSet AND
                                                              Core_MDF_User__r.IsActive = TRUE]){                
                                                                  if(accIdUserIdSetMap.containsKey(pnum.Core_MDF_Account__c)){
                                                                      accIdUserIdSetMap.get(pnum.Core_MDF_Account__c).add(pnum.Core_MDF_User__c);
                                                                  }else{
                                                                      accIdUserIdSetMap.put(pnum.Core_MDF_Account__c, new Set<Id> {pnum.Core_MDF_User__c});
                                                                  }
                                                                  userIdSet.add(pnum.Core_MDF_User__c);
                                                              }
            //PRC MS User
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [SELECT Id,Core_MDF_Account_id__c,Core_MDF_User_id__c,Core_MDF_Active_Ind__c,Core_MDF_Account_id__r.Name
                                                                   FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                   WHERE Core_MDF_Account_id__c  IN: accIdSet AND 
                                                                   Core_MDF_is_User_Active_ind__c = TRUE AND
                                                                   Core_MDF_Active_Ind__c = TRUE AND
                                                                   Core_MDF_Role_nm__c =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_RMF_PRC_Claim_Operations')]){ 
                                                                       
                                                                       if(accIdUserIdSetMap.containsKey(iupgm.Core_MDF_Account_id__c)){
                                                                           accIdUserIdSetMap.get(iupgm.Core_MDF_Account_id__c).add(iupgm.Core_MDF_User_id__c);
                                                                       }else{
                                                                           accIdUserIdSetMap.put(iupgm.Core_MDF_Account_id__c, new Set<Id> {iupgm.Core_MDF_User_id__c});
                                                                       }
                                                                       userIdSet.add(iupgm.Core_MDF_User_id__c);
                                                                   }   
            
            
        }
        
        Set<Id> userWithReqdPermissionSet = new Set<Id>();
        Set<Id> userWithClaimPermissionSet = new Set<Id>();
        Set<Id> userWithPRCClaimOperationPermissionSet = new Set<Id>();
        if(userIdSet != NULL  && userIdSet.size() > 0){
            for(PermissionSetAssignment usrPer : [SELECT Id, AssigneeId, Assignee.AccountId, Assignee.IsActive, PermissionSet.Name 
                                                  FROM PermissionSetAssignment WHERE AssigneeId IN :userIdSet 
                                                  AND (PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_External_Activity_Approver')
                                                       OR PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_External_Activity_Submitter')
                                                       OR PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Ext_RMF_Claim_Submitter')  
                                                       OR PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_RMF_PRC_Claim_Operations') 
                                                       OR PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Channel_MDF_Permission_Sets')
                                                       OR PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External_IPA_Proposal_Manager'))]){ 
                                                           
                                                           if(usrPer.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_External_Activity_Approver') 
                                                              ||  usrPer.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_External_Activity_Submitter')                                                              
                                                              || usrPer.PermissionSet.Name == 'Core_MDF_CCP_External_Channel_MDF_Activity_Submitter'
                                                              || usrPer.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Channel_MDF_Permission_Sets')
                                                              || usrPer.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External_IPA_Proposal_Manager')
                                                             ){
                                                                 userWithReqdPermissionSet.add(usrPer.AssigneeId);
                                                             }
                                                           
                                                               if(usrPer.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Ext_RMF_Claim_Submitter')|| 
                                                                
                                                                  usrPer.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_External_Activity_Approver')){
                                                                      userWithClaimPermissionSet.add(usrPer.AssigneeId);
                                                                  }
                                                           if( usrPer.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_RMF_PRC_Claim_Operations')){
                                                               userWithPRCClaimOperationPermissionSet.add(usrPer.AssigneeId);
                                                           }
                                                          
                                                       }
        }
        SYSTEM.debug('userWithClaimPermissionSet>>'+userWithClaimPermissionSet);
        
        List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();
        
        for(PartnerFundRequest pfr : pfrList){
            
            Set<Id> userFinalPermissionSet = new Set<Id>();
            If(pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Planned_Status') ) { 
               userFinalPermissionSet = userWithClaimPermissionSet;
            }else
                If(pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Approval_Nm') ) { 
                userFinalPermissionSet = userWithReqdPermissionSet;
                }
            
           
            if(accIdSet.contains(pfr.ChannelPartnerId) && accIdUserIdSetMap.containsKey(pfr.ChannelPartnerId) && 
               accIdUserIdSetMap.get(pfr.ChannelPartnerId) != NULL){                
                   for(Id userId : accIdUserIdSetMap.get(pfr.ChannelPartnerId)){
                       if(pfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name') && 
                       userFinalPermissionSet.contains(userId)){
                           Core_MDF_GenericClassToSendMail.MailParams sendEmailToReviewer = new Core_MDF_GenericClassToSendMail.MailParams();
                           sendEmailToReviewer.recordId = pfr.Id;
                          
                           sendEmailToReviewer.templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Notify_RMF_User');
                           sendEmailToReviewer.userIdList = new List<Id>{userId};
                               sendEmailToReviewer.sendDiff = false;
                           inputList.add(sendEmailToReviewer);                        
                       }
                       //prc
                       if(pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Planned_Status')&&
                          userWithPRCClaimOperationPermissionSet.contains(userId)){
                           Core_MDF_GenericClassToSendMail.MailParams sendEmailToPRCReviewer = new Core_MDF_GenericClassToSendMail.MailParams();
                           sendEmailToPRCReviewer.recordId = pfr.Id;
                           sendEmailToPRCReviewer.templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Notify_Internal_RMF_User');
                           sendEmailToPRCReviewer.userIdList = new List<Id>{userId};
                           sendEmailToPRCReviewer.sendDiff = false;
                           inputList.add(sendEmailToPRCReviewer);                        
                       }
                       //prc
                       //TWC702-760
                       if((Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Program_Name').equals(pfr.Core_MDF_Program__c) || 
                          Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Program_Name').equals(pfr.Core_MDF_Program__c) || 
                           ((Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ChannelMDF_Program_Name').equals(pfr.Core_MDF_Program__c) || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_IPA').equals(pfr.Core_MDF_Program__c)) && pfr.Core_MDF_Proposal_Based_Ind__c == false)) &&
                          userFinalPermissionSet.contains(userId)){  
                              String templateName = (pfr.Core_MDF_Program__c == 'Intel Partner Alliance') ? Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Notify_IPAAccountBased'): Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ExternalStatusChangeCCFDCF'); 
                              Core_MDF_GenericClassToSendMail.MailParams sendEmailToExternalUser = new Core_MDF_GenericClassToSendMail.MailParams();
                              sendEmailToExternalUser.recordId = pfr.Id;
                              sendEmailToExternalUser.templateName = templateName;
                              sendEmailToExternalUser.userIdList = new List<Id>{userId};
                                  sendEmailToExternalUser.sendDiff = false;
                              inputList.add(sendEmailToExternalUser);
                              
                          }
                   }
               }
        }
        if(inputList != NULL && inputList.size() >0){
            Core_MDF_GenericClassToSendMail.sendEmailMethod(inputList);
        }
        
    }
    
    //Method to assign Internal Account Managers as Approvers in case of NULL Approvers
    /* public static Map<String, list<id>> assignAccountManagers(Map<id,PartnerFundRequest> pfrMap, set<id> campaignId,List<string> nullApprovers)
    {
        Map<Id, String> campaignProgramMap = new Map<Id, String>();
        Map<String, List<Id>> partnerGroupIdMap = new Map<String,List<Id>>();
        Map<Id, List<Id>> groupUserMap =  new Map<Id, List<Id>>();  
        Map<String, list<id>> accountManagerApproverList = new  Map<String, list<id>>();
        List<string> accountManagerPermissionSet = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Account_Mgr_Permission_Sets').split(',');
        
        Set<Id> parentAccountIds = new Set<Id>();
        Set<Id> channelProgramIdSet = new Set<Id>();
        Set<Id> groupIds = new Set<Id>();
        
        try{
            //US1098882
            for(PartnerFundRequest pfr : [SELECT Id, CampaignId, Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, 
                                          Campaign.Core_MDF_Channel_Program__c,Core_MDF_Region_cd__c, Core_MDF_Region_nm__c 
                                          FROM PartnerFundRequest 
                                          WHERE Id IN: pfrMap.keySet()]){
                                              parentAccountIds.add(pfr.Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c);
                                              channelProgramIdSet.add(pfr.Campaign.Core_MDF_Channel_Program__c);
                                              //String value =  (String)pfr.Campaign.Core_MDF_Channel_Program__c + (String)pfr.Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c + pfr.Core_MDF_Region_cd__c;
                                              //US1098882
                                              String value =  (String)pfr.Campaign.Core_MDF_Channel_Program__c + (String)pfr.Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c + pfr.Core_MDF_Region_nm__c;
                                              campaignProgramMap.put(pfr.CampaignId, value);    
                                          }
            
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [SELECT Id, Core_MDF_Account_id__c, Core_MDF_Channel_Program_id__c,
                                                                   Core_MDF_Region_cd__c, Core_MDF_User_id__c,Core_MDF_Sub_Region_cd__c,
                                                                   Core_MDF_Region_Sub_Region_nm__c,Core_MDF_Role_nm__c 
                                                                   FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c 
                                                                   WHERE Core_MDF_Account_id__c IN: parentAccountIds AND 
                                                                   Core_MDF_Channel_Program_id__c IN: channelProgramIdSet AND
                                                                   Core_MDF_Role_nm__c IN:accountManagerPermissionSet AND
                                                                   Core_MDF_Active_Ind__c = TRUE]){
                                                                       for(String region : iupgm.Core_MDF_Region_cd__c.Split(';')){
                                                                           String key;
                                                                           if(region != 'WW'){
                                                                               key = (String)iupgm.Core_MDF_Channel_Program_id__c + iupgm.Core_MDF_Account_id__c + iupgm.Core_MDF_Region_cd__c;
                                                                           }
                                                                           else{
                                                                               key = (String)iupgm.Core_MDF_Channel_Program_id__c + iupgm.Core_MDF_Account_id__c;
                                                                           }
                                                                           
                                                                           if(partnerGroupIdMap.containsKey(key)){
                                                                               partnerGroupIdMap.get(key).add(iupgm.Core_MDF_User_id__c);
                                                                           }
                                                                           else{
                                                                               partnerGroupIdMap.put(key, new List<Id>{iupgm.Core_MDF_User_id__c});
                                                                           }
                                                                           
                                                                       }
                                                                   }
            
            for(String pfrReq:nullApprovers){
                String parentProgram = campaignProgramMap.get(pfrMap.get(pfrReq).campaignId);
                String forWW = parentProgram.left(36);
                
                if(parentProgram != null && forWW != null)
                {
                    List<Id> userList = new List<Id>();
                    if(partnerGroupIdMap.get(forWW) != NULL){userList.addAll(partnerGroupIdMap.get(forWW));
                                                            }  
                    if(partnerGroupIdMap.get(parentProgram) != NULL){userList.addAll(partnerGroupIdMap.get(parentProgram));
                                                                    } 
                    if(userList.size() > 0){while(userlist.size() < 10){userlist.add(userlist[0]);
                                                                       }
                                            accountManagerApproverList.put(pfrReq,userList);
                                           }
                }                                              
            }
        }
        
        catch(exception ex){
            logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex); Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'PFR Trigger - assignAccountManagers()');
        }
        
        return accountManagerApproverList;       
    } */
    
    //Method to initiate Approval Process
    /*public static void callApprovalProcessCall(Map<Id,PartnerFundRequest> approvalMap, Map<Id, string> approvalTemplatemap,List<PartnerFundRequest> pfrnew)
    {
        List<Approval.ProcessSubmitRequest> appRequests = new List<Approval.ProcessSubmitRequest> ();
        List<Id> instancrNotExists = new List<Id>();
        Id actId = null;
        Boolean geoApprover = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Marketing_GEO_Approver');
        //Boolean afterTheFactUser = FeatureManagement.checkPermission('Core_MDF_AfterTheFact');
        Boolean retailAccMgrPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Account_Manager');
        System.debug('<<approvalMaptemp>>' + approvalMap + approvalTemplatemap);
        //Calling Approval Process 
        try{
            
           
            
            Boolean ccfFieldOwner = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Field_Owner'));
            Boolean dcfFieldOwner = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Field_Owner'));
            Boolean ccfMarketingOwner = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Marketing_Owner'));
            Boolean dcfMarketingOwner = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Marketing_Owner'));
            Boolean channelMDFManager = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Channel_MDF_Acc_Mgr');
            Boolean ipaMDFManager = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_IPA_MDF_Manager'));
            Boolean ipaExternalMDFManager = FeatureManagement.checkPermission('Core_MDF_CCP_External_IPA_Proposal_Manager');

            
            instancrNotExists = isProcessInstanceExist(pfrnew);
            
            for(PartnerFundRequest newPfr : pfrnew){
                
                if(approvalMap.containsKey(newPfr.Id) && approvalMap.get(newPfr.Id) != NULL){
                    System.debug('newPfr.Core_MDF_PriorValueOfStatus__c'+newPfr.Core_MDF_PriorValueOfStatus__c);
                    approvalMap.get(newPfr.Id).Core_MDF_Approval_Step_Completed__c = newPfr.Core_MDF_Approval_Step_Completed__c; 
                    approvalMap.get(newPfr.Id).Core_MDF_PriorValueOfStatus__c = newPfr.Core_MDF_PriorValueOfStatus__c; 
                    approvalMap.get(newPfr.Id).Core_MDF_Fund_Request_Status__c = newPfr.Core_MDF_Fund_Request_Status__c; 
                    approvalMap.get(newPfr.Id).Core_MDF_Start_Date__c= newPfr.Core_MDF_Start_Date__c; 
                }
                //Retail Changes

                if(newPfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name') && !approvalMap.containsKey(newPfr.Id)){
                   
                    System.debug('Inside if-->');
                    if((geoApprover && newpfr.Core_MDF_Fund_Request_Status__c == 'Pending Review') ||                        
                       (geoApprover && newPfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Approval_Nm') && 
                        !newPfr.Core_MDF_Price_reviewer_check_ind__c) ||
                       ((geoApprover || (retailAccMgrPermission && newPfr.Core_MDF_Start_Date__c < System.today() && newPfr.Core_MDF_Region_nm__c != 'EMEA')) && 
                        newPfr.Core_MDF_Fund_Request_Status__c == 'Pending Review')){ 
                       //(afterTheFactUser && newpfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' && newPfr.Core_MDF_Price_reviewer_check_ind__c)){                           
                           approvalMap.put(newPfr.Id,newPfr);
                           System.debug('<<approvalmapafter>>' + approvalMap);
                       }            
                }
                System.debug('#663: '+approvalMap); 
                System.debug('before approval map==>'+newPfr.Core_MDF_Fund_Request_Status__c+'==='+newPfr.Core_MDF_Approval_Step_Completed__c); 
                // US949836 : New Budget Type field changes replaced txt field with new global picklist field
                // US964831: 3. Added Pending Approval condition for CMP to add to approvalMap to Submit for Approval
                if((ccfFieldOwner || dcfFieldOwner || ccfMarketingOwner || dcfMarketingOwner) &&
                   (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP').equals(newPfr.Core_MDF_Budget_Type_nm__c) 
                    || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDF').equals(newPfr.Core_MDF_Budget_Type_nm__c) 
                    || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDFPlus').equals(newPfr.Core_MDF_Budget_Type_nm__c)
                    || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP').equals(newPfr.Core_MDF_Budget_Type_nm__c)) && 
                   !approvalMap.containsKey(newPfr.Id) && 
                   (newPfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' || (newPfr.Core_MDF_Fund_Request_Status__c == 'Pending Approval' && (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP').equals(newPfr.Core_MDF_Budget_Type_nm__c) || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP').equals(newPfr.Core_MDF_Budget_Type_nm__c))))
                    && (newPfr.Core_MDF_Approval_Step_Completed__c == 1 ||  newPfr.Core_MDF_Approval_Step_Completed__c == 0 || (newPfr.Core_MDF_Approval_Step_Completed__c == 4 && newPfr.Core_MDF_Require_Additional_Review_ind__c && (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP').equals(newPfr.Core_MDF_Budget_Type_nm__c) || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP').equals(newPfr.Core_MDF_Budget_Type_nm__c))))){
                       approvalMap.put(newPfr.Id,newPfr);  
                   }
                //Channel MDF Changes
                if((channelMDFManager || ipaMDFManager || ipaExternalMDFManager) && newPfr.Core_MDF_Proposal_Based_Ind__c == false && !approvalMap.containsKey(newPfr.Id) && newPfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' && (newPfr.Core_MDF_Approval_Step_Completed__c == 1 ||  newPfr.Core_MDF_Approval_Step_Completed__c == 0)){
                    approvalMap.put(newPfr.Id,newPfr);
                }
            }
            System.debug('approvalMap---' + approvalMap);
           
            
            
            for(PartnerFundRequest updatedpfr:approvalMap.values()) {
                Integer stepsCompleted = updatedpfr.Core_MDF_Approval_Step_Completed__c == null ? 0 : Integer.valueOf(updatedpfr.Core_MDF_Approval_Step_Completed__c);
                
                system.debug('opal rr--'+ccfFieldOwner+updatedpfr.Core_MDF_Fund_Request_Status__c+stepsCompleted+instancrNotExists.contains(updatedpfr.Id)+updatedpfr.Core_MDF_Budget_Type_nm__c+updatedpfr.Core_MDF_Price_reviewer_check_ind__c);
                System.debug('if condition line 853 => '+(!instancrNotExists.contains(updatedpfr.Id) && ((stepsCompleted == 0 || updatedpfr.Core_MDF_PriorValueOfStatus__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Revision_Required')) || updatedpfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Approval_Nm') || updatedpfr.Core_MDF_Fund_Request_Status__c == Label.Core_MDF_PFR_Status_PendingReview)));

                // US949836 : New Budget Type field changes replaced txt field with new global picklist field
                if(
                    (((ccfFieldOwner || dcfFieldOwner) && (stepsCompleted == 1 || stepsCompleted == 2) && updatedpfr.Core_MDF_PriorValueOfStatus__c == 'Planned' && (updatedpfr.Core_MDF_Require_Additional_Review_ind__c)) ||
                     ( 
                         
                         !instancrNotExists.contains(updatedpfr.Id) && 
                         ((stepsCompleted == 0 || updatedpfr.Core_MDF_PriorValueOfStatus__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Revision_Required')) || 
                          updatedpfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Approval_Nm') ||
                          updatedpfr.Core_MDF_Fund_Request_Status__c == Label.Core_MDF_PFR_Status_PendingReview)
                     )
                    )||
                    (                        
                        (stepsCompleted == 1 || stepsCompleted == 0) && (updatedpfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' || (updatedpfr.Core_MDF_Fund_Request_Status__c == 'Pending Approval' && (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP').equals(updatedpfr.Core_MDF_Budget_Type_nm__c) || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP').equals(updatedpfr.Core_MDF_Budget_Type_nm__c)))) &&
                        !instancrNotExists.contains(updatedpfr.Id) && (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP').equals(updatedpfr.Core_MDF_Budget_Type_nm__c) || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDF').equals(updatedpfr.Core_MDF_Budget_Type_nm__c) || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDFPlus').equals(updatedpfr.Core_MDF_Budget_Type_nm__c) ||Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP').equals(updatedpfr.Core_MDF_Budget_Type_nm__c))
                    ) 
                ) { 
                    //  Core_MDF_PFR_Rules_Processing.callPFRApproval(updatedpfr,updatedpfr.Core_MDF_Rule_Engine_Process_Name__c);
                    system.debug('opal rr1-->>');
                    Approval.ProcessSubmitRequest appObj = new Approval.ProcessSubmitRequest();
                    appObj.setObjectId(updatedpfr.id);
                    System.debug('Approval process name'+approvalTemplatemap.get(updatedpfr.Id));
                   
                    appObj.setProcessDefinitionNameOrId(approvalTemplatemap.get(updatedpfr.Id));
                    if(geoApprover && (updatedpfr.Core_MDF_Start_Date__c >= System.today())){
                        if(updatedpfr.Core_MDF_Approval_Step_Completed__c == 0){
                            system.debug('If 1-->>');
                            appObj.setComments('Record submitted for approval');
                        } else{
                            appObj.setComments(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_GeoLead_Approval_Comments'));     
                        }
                    }else{
                        
                        
                            system.debug('else If 1-->>');
                            appObj.setComments('Record submitted for approval');   
                        
                        
                    }
                    actId = updatedpfr.Id;
                    appRequests.add(appObj);
                    if (appRequests.size()> 0){
                        system.debug('Inside 1010-->>' + appRequests);
                        Approval.ProcessResult[] result = Approval.process(appRequests);
                    }
                }
            }
        }
        catch(exception ex){logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex); Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'PFR Trigger - callApprovalProcess()+actId'+actId);
                           }
        
    }*/
    
/*public static void callApprovalProcessCall(Map<Id,PartnerFundRequest> approvalMap, Map<Id, string> approvalTemplatemap,List<PartnerFundRequest> pfrnew)
    {
        List<Approval.ProcessSubmitRequest> appRequests = new List<Approval.ProcessSubmitRequest> ();
        List<Id> instancrNotExists = new List<Id>();
        Id actId = null;
        Boolean geoApprover = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Marketing_GEO_Approver');
        //Boolean afterTheFactUser = FeatureManagement.checkPermission('Core_MDF_AfterTheFact');
        Boolean retailAccMgrPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Account_Manager');
        System.debug('<<approvalMaptemp>>' + approvalMap + approvalTemplatemap);
        //Calling Approval Process 
        try{
            
           
            
            Boolean ccfFieldOwner = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Field_Owner'));
            Boolean dcfFieldOwner = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Field_Owner'));
            Boolean ccfMarketingOwner = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Marketing_Owner'));
            Boolean dcfMarketingOwner = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Marketing_Owner'));
            Boolean channelMDFManager = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Channel_MDF_Acc_Mgr');
            Boolean ipaMDFManager = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_IPA_MDF_Manager'));
            Boolean ipaExternalMDFManager = FeatureManagement.checkPermission('Core_MDF_CCP_External_IPA_Proposal_Manager');

            
            instancrNotExists = isProcessInstanceExist(pfrnew);
            
            for(PartnerFundRequest newPfr : pfrnew){
                
                if(approvalMap.containsKey(newPfr.Id) && approvalMap.get(newPfr.Id) != NULL){
                    System.debug('newPfr.Core_MDF_PriorValueOfStatus__c'+newPfr.Core_MDF_PriorValueOfStatus__c);
                    approvalMap.get(newPfr.Id).Core_MDF_Approval_Step_Completed__c = newPfr.Core_MDF_Approval_Step_Completed__c; 
                    approvalMap.get(newPfr.Id).Core_MDF_PriorValueOfStatus__c = newPfr.Core_MDF_PriorValueOfStatus__c; 
                    approvalMap.get(newPfr.Id).Core_MDF_Fund_Request_Status__c = newPfr.Core_MDF_Fund_Request_Status__c; 
                    approvalMap.get(newPfr.Id).Core_MDF_Start_Date__c= newPfr.Core_MDF_Start_Date__c; 
                }
                //Retail Changes

                if(newPfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name') && !approvalMap.containsKey(newPfr.Id)){
                   
                    System.debug('Inside if-->');
                    if((geoApprover && newpfr.Core_MDF_Fund_Request_Status__c == 'Pending Review') ||                        
                       (geoApprover && newPfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Approval_Nm') && 
                        !newPfr.Core_MDF_Price_reviewer_check_ind__c) ||
                       ((geoApprover || (retailAccMgrPermission && newPfr.Core_MDF_Start_Date__c < System.today() && newPfr.Core_MDF_Region_nm__c != 'EMEA')) && 
                        newPfr.Core_MDF_Fund_Request_Status__c == 'Pending Review')){ 
                       //(afterTheFactUser && newpfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' && newPfr.Core_MDF_Price_reviewer_check_ind__c)){                           
                           approvalMap.put(newPfr.Id,newPfr);
                           System.debug('<<approvalmapafter>>' + approvalMap);
                       }            
                }
                System.debug('#663: '+approvalMap); 
                System.debug('before approval map==>'+newPfr.Core_MDF_Fund_Request_Status__c+'==='+newPfr.Core_MDF_Approval_Step_Completed__c); 
                // US949836 : New Budget Type field changes replaced txt field with new global picklist field
                // US964831: 3. Added Pending Approval condition for CMP to add to approvalMap to Submit for Approval
                if((ccfFieldOwner || dcfFieldOwner || ccfMarketingOwner || dcfMarketingOwner) &&
                   (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP').equals(newPfr.Core_MDF_Budget_Type_nm__c) 
                    || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDF').equals(newPfr.Core_MDF_Budget_Type_nm__c) 
                    || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDFPlus').equals(newPfr.Core_MDF_Budget_Type_nm__c)
                    || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP').equals(newPfr.Core_MDF_Budget_Type_nm__c)) && 
                   !approvalMap.containsKey(newPfr.Id) && 
                   (newPfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' || (newPfr.Core_MDF_Fund_Request_Status__c == 'Pending Approval' && (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP').equals(newPfr.Core_MDF_Budget_Type_nm__c) || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP').equals(newPfr.Core_MDF_Budget_Type_nm__c))))
                    && (newPfr.Core_MDF_Approval_Step_Completed__c == 1 ||  newPfr.Core_MDF_Approval_Step_Completed__c == 0 || (newPfr.Core_MDF_Approval_Step_Completed__c == 4 && newPfr.Core_MDF_Require_Additional_Review_ind__c && (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP').equals(newPfr.Core_MDF_Budget_Type_nm__c) || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP').equals(newPfr.Core_MDF_Budget_Type_nm__c))))){
                       approvalMap.put(newPfr.Id,newPfr);  
                   }
                //Channel MDF Changes
                if((channelMDFManager || ipaMDFManager || ipaExternalMDFManager) && newPfr.Core_MDF_Proposal_Based_Ind__c == false && !approvalMap.containsKey(newPfr.Id) && newPfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' && (newPfr.Core_MDF_Approval_Step_Completed__c == 1 ||  newPfr.Core_MDF_Approval_Step_Completed__c == 0)){
                    approvalMap.put(newPfr.Id,newPfr);
                }
            }
            System.debug('approvalMap---' + approvalMap);
           
            
            
            for(PartnerFundRequest updatedpfr:approvalMap.values()) {
                Integer stepsCompleted = updatedpfr.Core_MDF_Approval_Step_Completed__c == null ? 0 : Integer.valueOf(updatedpfr.Core_MDF_Approval_Step_Completed__c);
                
                system.debug('opal rr--'+ccfFieldOwner+updatedpfr.Core_MDF_Fund_Request_Status__c+stepsCompleted+instancrNotExists.contains(updatedpfr.Id)+updatedpfr.Core_MDF_Budget_Type_nm__c+updatedpfr.Core_MDF_Price_reviewer_check_ind__c);
                System.debug('if condition line 853 => '+(!instancrNotExists.contains(updatedpfr.Id) && ((stepsCompleted == 0 || updatedpfr.Core_MDF_PriorValueOfStatus__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Revision_Required')) || updatedpfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Approval_Nm') || updatedpfr.Core_MDF_Fund_Request_Status__c == Label.Core_MDF_PFR_Status_PendingReview)));

                // US949836 : New Budget Type field changes replaced txt field with new global picklist field
                if(
                    (((ccfFieldOwner || dcfFieldOwner) && (stepsCompleted == 1 || stepsCompleted == 2) && updatedpfr.Core_MDF_PriorValueOfStatus__c == 'Planned' && (updatedpfr.Core_MDF_Require_Additional_Review_ind__c)) ||
                     ( 
                         
                         !instancrNotExists.contains(updatedpfr.Id) && 
                         ((stepsCompleted == 0 || updatedpfr.Core_MDF_PriorValueOfStatus__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Revision_Required')) || 
                          updatedpfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Approval_Nm') ||
                          updatedpfr.Core_MDF_Fund_Request_Status__c == Label.Core_MDF_PFR_Status_PendingReview)
                     )
                    )||
                    (                        
                        (stepsCompleted == 1 || stepsCompleted == 0) && (updatedpfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' || (updatedpfr.Core_MDF_Fund_Request_Status__c == 'Pending Approval' && (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP').equals(updatedpfr.Core_MDF_Budget_Type_nm__c) || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP').equals(updatedpfr.Core_MDF_Budget_Type_nm__c)))) &&
                        !instancrNotExists.contains(updatedpfr.Id) && (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP').equals(updatedpfr.Core_MDF_Budget_Type_nm__c) || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDF').equals(updatedpfr.Core_MDF_Budget_Type_nm__c) || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDFPlus').equals(updatedpfr.Core_MDF_Budget_Type_nm__c) ||Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP').equals(updatedpfr.Core_MDF_Budget_Type_nm__c))
                    ) 
                ) { 
                    //  Core_MDF_PFR_Rules_Processing.callPFRApproval(updatedpfr,updatedpfr.Core_MDF_Rule_Engine_Process_Name__c);
                    system.debug('opal rr1-->>');
                    Approval.ProcessSubmitRequest appObj = new Approval.ProcessSubmitRequest();
                    appObj.setObjectId(updatedpfr.id);
                    System.debug('Approval process name'+approvalTemplatemap.get(updatedpfr.Id));
                   
                    appObj.setProcessDefinitionNameOrId(approvalTemplatemap.get(updatedpfr.Id));
                    if(geoApprover && (updatedpfr.Core_MDF_Start_Date__c >= System.today())){
                        if(updatedpfr.Core_MDF_Approval_Step_Completed__c == 0){
                            system.debug('If 1-->>');
                            appObj.setComments('Record submitted for approval');
                        } else{
                            appObj.setComments(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_GeoLead_Approval_Comments'));     
                        }
                    }else{
                        
                        
                            system.debug('else If 1-->>');
                            appObj.setComments('Record submitted for approval');   
                        
                        
                    }
                    actId = updatedpfr.Id;
                    appRequests.add(appObj);
                    if (appRequests.size()> 0){
                        system.debug('Inside 1010-->>' + appRequests);
                        Approval.ProcessResult[] result = Approval.process(appRequests);
                    }
                }
            }
        }
        catch(exception ex){logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex); Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'PFR Trigger - callApprovalProcess()+actId'+actId);
                           }
        
    }*/
    //Method to Update the Retail Manager(L1/L2) Approvers in PartnerFundRequest Object
   /* public static List<PartnerFundRequest> updateRetailManagerApprovers(Map<Id, Set<PartnerFundRequest>> approverListAndPFRIdSet)
    {   
        List<PartnerFundRequest> tobeUpdatedList = new List<PartnerFundRequest>();
        Map<Id , Id> userAndusermanagerIdmap = new Map<Id, Id>();
        Set<Id> usrWithoutMngrSet = new Set<Id>();
        for(User usr : [Select Id, ManagerId, Manager.DelegatedApproverId FROM User Where Id IN: approverListAndPFRIdSet.keySet() ]){if(usr.ManagerId != NULL){userAndusermanagerIdmap.put(usr.Id , usr.ManagerId);} else {usrWithoutMngrSet.add(usr.Id);
                                                                                                                                                                                                                          }
                                                                                                                                    }
        Set<Id> allUserIds = new Set<Id>();
        allUserIds.addAll(userAndusermanagerIdmap.keyset());
        allUserIds.addAll(usrWithoutMngrSet);
        try{
            if(allUserIds != null && allUserIds.size() > 0){for(Id userId : allUserIds){if(approverListAndPFRIdSet.containsKey(userId)){for(PartnerFundRequest pfr : approverListAndPFRIdSet.get(userId)){PartnerFundRequest appPFR = new PartnerFundRequest(Id = pfr.Id);if(userAndusermanagerIdmap.containsKey(userId)){appPFR.Core_MDF_Approver_1__c = userAndusermanagerIdmap.get(userId);}else if(usrWithoutMngrSet.contains(userId)){appPFR.Core_MDF_Approver_1__c = null;}appPFR.Core_MDF_Approver_2__c = null;appPFR.Core_MDF_Approver_3__c = null;appPFR.Core_MDF_Approver_4__c = null;appPFR.Core_MDF_Approver_5__c = null;appPFR.Core_MDF_Approver_6__c = null;appPFR.Core_MDF_Approver_7__c = null;appPFR.Core_MDF_Approver_8__c = null;appPFR.Core_MDF_Approver_9__c = null;appPFR.Core_MDF_Approver_10__c = null;tobeUpdatedList.add(appPFR);
                                                                                                                                                                                                         }
                                                                                                                                       }
                                                                                        
                                                                                       }
                                                           }
        }
        catch(exception ex){logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex); Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'PFR Trigger - updateApprovers()');
                           }
        return tobeUpdatedList;       
    } */
    
    //Method to Update the Approvers in PartnerFundRequest Object
   /* public static List<PartnerFundRequest> updateApprovers(Map<String, list<id>> approverIdList, Map<Id, PartnerFundRequest> pfrMap)
    {
        
        List<PartnerFundRequest> tobeUpdatedList = new List<PartnerFundRequest>();       
        try{  for(id appRequiredID:approverIdList.keyset()){
            PartnerFundRequest appPFR = new PartnerFundRequest(Id = appRequiredID);
            List<id> approvers = approverIdList.get(appRequiredID);
            appPFR.Core_MDF_Approver_1__c = approvers[0];
            appPFR.Core_MDF_Approver_2__c = approvers[1];
            appPFR.Core_MDF_Approver_3__c = approvers[2];
            appPFR.Core_MDF_Approver_4__c = approvers[3];
            appPFR.Core_MDF_Approver_5__c = approvers[4];
            appPFR.Core_MDF_Approver_6__c = approvers[5];
            appPFR.Core_MDF_Approver_7__c = approvers[6];
            appPFR.Core_MDF_Approver_8__c = approvers[7];
            appPFR.Core_MDF_Approver_9__c = approvers[8];
            appPFR.Core_MDF_Approver_10__c = approvers[9];
                                                            
                                                            tobeUpdatedList.add(appPFR);
                                                           }
           }
        catch(exception ex)
        {
            logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex); Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'PFR Trigger - updateApprovers()');
        }
        return tobeUpdatedList;       
    }*/
    
    //Method to check if the Activity Submitter is Account Manager
  /*  public static Map<string,List<sobject>> checkIfActivitySubmitterIsAccountManager(List<partnerfundrequest> toBeProcessed)
    {
        List<string> accountManagerPermissionSet = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Account_Mgr_Permission_Sets').split(',');
        List<id> createdAndModifiedBy = new List<id>();
        List<id> accountManagerList = new List<id>();
        List<sobject> autoApproval = new List<sobject>();
        List<sobject> needApproval = new List<sobject>();
        Map<string,id> pfrAccountManagerMap = new Map<string,id>();
        Map<string,List<sobject>> outputMap = new Map<string,List<sobject>>();
        
        try
        {
            for(partnerfundrequest pfr:toBeProcessed)
            {
                createdAndModifiedBy.add(pfr.CreatedById);
                createdAndModifiedBy.add(pfr.LastModifiedById); 
            }
            
            
            
            List<PermissionSetAssignment> permissionSetToAssignee = [SELECT Id, PermissionSetId, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment where AssigneeId IN: createdAndModifiedBy and PermissionSet.Name IN: accountManagerPermissionSet];
            
            for(PermissionSetAssignment permissionSet:permissionSetToAssignee )
            {
                
                accountManagerList.add(permissionSet.AssigneeId);
            }
            
            for(partnerfundrequest pfr:toBeProcessed)
            {
                if (pfr.Core_MDF_Program__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name')){
                    // US949836 : New Budget Type field changes replaced txt field with new global picklist field
                    if(
                        ((accountManagerList.contains(pfr.CreatedById) && accountManagerList.contains(pfr.LastModifiedById)) || accountManagerList.contains(pfr.LastModifiedById))
                        &&
                        (
                            //US964831: 1. Excluded CMP for AutoApproval
                            //US1008100:  Added condition to exclude SP CMP for AutoApproval
                            (((pfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Program_Name') || pfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Program_Name')) && 
                              pfr.Core_MDF_Budget_Type_nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDFPlus') && pfr.Core_MDF_Budget_Type_nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDF') &&
                              pfr.Core_MDF_Budget_Type_nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP') && pfr.Core_MDF_Budget_Type_nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP')) ||
                             (pfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ChannelMDF_Program_Name') && pfr.Core_MDF_Proposal_Based_Ind__c ) ||
                             pfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SPCF_Program_Name') || pfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCFB_Program_Name')) //|| 
                            //(pfr.Core_MDF_Budget_Type_nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP') && !pfr.Core_MDF_Require_Additional_Review_ind__c)
                        )
                    ){
                        
                               autoApproval.add(pfr);
                    }
                    else 
                    {
                        needApproval.add(pfr);
                    }
                }
            }
            
            outputMap.put('approvalReq', needApproval);
            outputMap.put('noApproval', autoApproval);
            system.debug('---> outputMap' + outputMap.keyset());
            system.debug('---> outputMap Values' + outputMap);
        }
        
        
        catch(exception ex)
        {
            logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex); Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'PFR Trigger - checkIfActivitySubmitterIsAccountManager()');         
        } 
        
        return outputMap;
    }*/
    
    //Method to check if the PartnerFundRequest Belongs to any of the mentioned RecordTypes
   /* public static Map<id,string>  getRecordIDFromEnvironment()
    {
        Map<id,string> ccpRecordTypeIds= new Map<id,string> ();
        List<string> ccpProgramsInList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_RecordType_API_Name').split(',');
        
        //'Core_MDF_Client_CoMarketing_Fund,Core_MDF_Data_Center_CoMarketing_Fund,Core_MDF_Service_Provider_CoMarketing_Fund';
        
        try
        {
            for(string program:ccpProgramsInList)
            {
                id recordTypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get(program).getRecordTypeId();
                string recordTypeName = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get(program).getName();
                ccpRecordTypeIds.put(recordTypeId,recordTypeName);   
            }
        }
        
        catch(exception ex){logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex); Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'PFR Trigger - getRecordIDFromEnvironment()');
                            //isError = true;         
                           } 
        
        
        return ccpRecordTypeIds;        
    }
*/
    
    /*****************************************************************************************************************************************
Method Name:                                             recallApprovalProcess
@return  :                                               return boolean
@parameters:                                             PFR List to be recalled , pfr Old Map
Description:                                             All the cancel activities should be recalled to prevent Approve/Reject action.
Modifies :                         Added code to recall the Approval Process when Activity is closed.

**************************************************************************************************************************************************/
    //Recall Approval for Cancelled/Closed Activities
   /* public static boolean recallApprovalActivities(List<PartnerFundRequest> pfrList, Map<Id,PartnerFundRequest> oldPfrMap)
    {
        //DE118351 : Production Issue: ATF flow still  failing after the recent fix
        list<Id> recallPFRId = new list<Id>();
        list<ProcessInstanceWorkitem>  piList = new list<ProcessInstanceWorkitem>();        
        boolean res = false;
        List<Id> pfrsToBeSubmittedForATFApproval = new List<Id>();
        
        try
        { 
            for(PartnerFundRequest pfr: pfrList)
            {     
                if(oldPfrMap.containsKey(pfr.Id) && oldPfrMap.get(pfr.Id) != NULL){          
                    //To recall activities from approval process when closed or cancelled
                    if((pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Cancelled_Status') ||
                        (pfr.Core_MDF_Fund_Request_Status__c == 'Closed' 
                         && pfr.Core_MDF_Activity_Closure_Type__c != 'No Internal Approval'))){
                             recallPFRId.add(pfr.Id);    
                         } 
                }     
            } 
            system.debug('recallPFRId-->'+recallPFRId);
            //Check the size of recallPFRId , remove the Activities from Approval Queue
            if(recallPFRId.size()>0){
              /*  ProcessInstanceWorkitem[] workItems = [SELECT Id
                List<Approval.ProcessWorkitemRequest> pwrList = new List<Approval.ProcessWorkitemRequest>();                         
               // for(ProcessInstanceWorkitem PIns:workItems){
                for(ProcessInstanceWorkitem PIns: [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :recallPFRId AND ProcessInstance.Status = 'Pending']){
                    Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                    pwr.setAction('Removed');
                    pwr.setWorkItemId(PIns.id);
                    
                    pwrList.add(pwr);   
                }
                system.debug('pwrList-->'+pwrList);
                Integer index = 0;
                List<Approval.ProcessResult> resultList = Approval.process(pwrList);
                for(Approval.ProcessResult result : resultList){
                    if(result.isSuccess()){res = true;
                                          }
                    else{
                        logEntryMsg = 'Approval Error: '+pwrList[index]; Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Recal_Exception_Origin'));
                        system.debug('logEntryMsg-->'+logEntryMsg);
                    }
                    index++;
                }  
            }  
            
            
        }
        catch(exception ex){logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,Label.Core_MDF_Activity_Recall_Exception_Origin);         
                           } 
		
		system.debug('res-->'+res);          
        return res;
    }
		*/
    //Remove Approval lock on Activities
    public static boolean RemoveApprovalLock(List<PartnerFundRequest> pfrList)
    {           
        boolean result = false;
        
        try{
            if(pfrList != NULL && !pfrList.isEmpty()){
                List<Approval.UnlockResult> ulrList = Approval.unlock(pfrList, false);for(Approval.UnlockResult ulr:ulrList){if(ulr.isSuccess()) result = true;}
            }
            
        }
        catch(exception ex){            logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex); Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,Label.Core_MDF_Activity_Recall_Exception_Origin);   
                            
                           } 
        
        return result;
    }
    
   /* public static List<Id> isProcessInstanceExist(List<PartnerFundRequest> recordIds)
    {
        List<Id> ids = new List<Id>();
        if(recordIds.size()>0)
        {
            List<Id> pfrIds = new List<Id>();
            
            for(PartnerFundRequest recId : recordIds)
            {
                pfrIds.add(recId.Id);
            }
            
            for(ProcessInstance pi : [SELECT Id, TargetObjectId ,Status FROM ProcessInstance 
                                      WHERE TargetObjectId IN: pfrIds and Status != 'Rejected' and Status != 'Removed' and Status != 'Approved']){ids.add(pi.TargetObjectId);
                                                                                                                                                 }
            
        }
        
        return ids;
    }*/
    /***************************************************************************************************** 
Method Name   :        publishActivityPlatformEvent
@return       :        void
@parameters   :        
Description   :            
Added By      :        HA
Modified By   :        Date:          Changes: 

******************************************************************************************************/
    public static void publishActivityPlatformEvent(List<PartnerFundRequest> newPFRList, Map<Id,PartnerFundRequest> oldPfrMap){        
        List<Activity_Status_Changed__e> newEventList = new List<Activity_Status_Changed__e>();
        //Map of channel program meta data
        Map<String,String> mapOfChannelProgram = new Map<String,String>();
        //Existing channel program meta data
      /*  List<Core_MDF_ChannelProgram__mdt> channelProgramMetadata = [SELECT Label,Core_MDF_Technical_Program_Name__c FROM Core_MDF_ChannelProgram__mdt];
        for(Core_MDF_ChannelProgram__mdt cp : channelProgramMetadata){*/
    for(Core_MDF_ChannelProgram__mdt cp : [SELECT Label,Core_MDF_Technical_Program_Name__c FROM Core_MDF_ChannelProgram__mdt]){
            String key = cp.Core_MDF_Technical_Program_Name__c;
            mapOfChannelProgram.put(key, cp.Label);
        }
        if(newPFRList != NULL && newPFRList.size() > 0 && oldPfrMap != NULL && oldPfrMap.size() > 0){
            for(PartnerFundRequest pfr: newPFRList){
                //check if program is IPA and activity status is Revision Required or In-progress
                if(mapOfChannelProgram != NULL && mapOfChannelProgram.size() > 0 && mapOfChannelProgram.containsKey(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_ProgramName')) &&
                   oldPfrMap.containsKey(pfr.Id) && oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c != pfr.Core_MDF_Fund_Request_Status__c 
                   && pfr.Core_MDF_Proposal_Based_Ind__c == true && (pfr.Core_MDF_Fund_Request_Status__c == Label.Core_MDF_PFR_Status_RevisionRequired || pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_pfrInprogress'))){
                       //creating instance of the event and assigning the values in the event fields
                       Activity_Status_Changed__e  activityEvent = new Activity_Status_Changed__e(
                           Core_MDF_Activity_Id_txt__c = pfr.Id, Core_MDF_Activity_Status_txt__c = pfr.Core_MDF_Fund_Request_Status__c,
                           Core_MDF_Campaign_Id_txt__c = pfr.CampaignId,Core_MDF_Program_txt__c = mapOfChannelProgram.get(pfr.Core_MDF_Program__c) + ';'
                       );newEventList.add(activityEvent);                       
                   }               
            }
            // Call method to publish events
            List<Database.SaveResult> results = EventBus.publish(newEventList);
            // Inspect publishing result for each event
            Integer eventListIndex = 0;
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {  for(Database.Error err : sr.getErrors()) {  Core_MDF_CCP_UtilityClass.logErrorinLogObject(err.getMessage(),'Failed to publish event for ' + newEventList[eventListIndex].Core_MDF_Activity_Id_txt__c + ' related to ' +  newEventList[eventListIndex].Core_MDF_Campaign_Id_txt__c + ' tagged to ' +  newEventList[eventListIndex].Core_MDF_Program_txt__c + '.');}
                                     } 
                eventListIndex++;
            }
        }        
    }
    
    /***************************************************************************************************** 
Method Name   :        shareActivityWithUsers
@return       :        void
@parameters   :        Map<Id,PartnerFundRequest> from Trigger.newMap
Description   :        Calls the Core_MDF_GeoBasedGenericSharing class to create sharing with geo based groups
Added By      :        Accenture - VK - 08/05/2019
Modified By   :        Date:          Changes: 
Shivaprasad            08/29/2019     Added condition to check closed status PFR records to avoid unnecessary excecution.
******************************************************************************************************/
    public static void shareActivityWithUsers(Map<Id,PartnerFundRequest> activityMap){
        list<Id> pfrIdList = new list<Id>();
        Set<Id> activityIdSet = new Set<Id>();
        
        for(PartnerFundRequest pfr: activityMap.values()){
            pfrIdList.add(pfr.Id);
            
        }
        
        //activityIdSet = activityMap.keySet();
        //pfrIdList.addAll(activityIdSet);
        if(pfrIdList.size() > 0){
            Core_MDF_GeoBasedGenericSharing.checkObjectAndPgm('PartnerFundRequest', pfrIdList);
        }
        
        
    }
    
    /***************************************************************************************************** 
Method Name   :        shareActivityWithInternalUsers
@return       :        void
@parameters   :        Map<Id,PartnerFundRequest> from Trigger.newMap
Map<Id,PartnerFundRequest> from Trigger.oldMap
Description   :        Checks if the Account/Owner/Country is updated
Added By      :        Accenture - VK - 08/05/2019
Modified By   :        Date:          Changes: 
Shivaprasad            08/29/2019     Added condition to check closed status PFR records to avoid unnecessary excecution.
******************************************************************************************************/
    public static void shareActivityWithInternalUsers(Map<Id,PartnerFundRequest> oldActivityMap, Map<Id,PartnerFundRequest> newActivityMap){
        Map<Id,PartnerFundRequest> updatedActivityMap = new Map<Id,PartnerFundRequest>();
        //Set<Id> pfrIdSet = new Set<Id>();
        Set<String> accountIdProgramIdGeoSubGeoStringSet = new Set<String>();
        Set<String> accountIdProgramIdGeoStringSet = new Set<String>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<String> programStrSet = new Set<String>();
        Set<Id> programIdSet = new Set<Id>();
        Set<Id> groupIdSet = new Set<Id>();
        Set<String> groupRORWIdSet = new Set<String>();
        Set<String> geoStringSet = new Set<String>();
        Set<Id> oldAccountIdSet = new Set<Id>();
        Map<Id, Account> oldAccountMap = new Map<Id, Account>();
        Map<Id, Id> pfrIdAccountIdMap = new Map<Id, Id>();
        Map<Id, Id> pfrIdOldAccountIdMap = new Map<Id, Id>();
        
        //Map<Id, PartnerFundRequest> oldStaticPFRMap = Core_MDF_UpdateActivityFields.oldStaticPFRMap;
        //for(PartnerFundRequest pfr : oldStaticPFRMap.values()){
        for(PartnerFundRequest pfr : oldActivityMap.values()){
            oldAccountIdSet.add(pfr.ChannelPartnerId);
            pfrIdAccountIdMap.put(pfr.Id, pfr.ChannelPartnerId);
            //if Account has been Changed
            if(pfr.ChannelPartnerId != newActivityMap.get(pfr.Id).ChannelPartnerId){
                pfrIdOldAccountIdMap.put(pfr.Id, pfr.ChannelPartnerId);
            }
        }
        oldAccountMap = new Map<Id, Account> ([SELECT Id, Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Channel_Program__c, Core_MDF_Group_Id__c
                                               FROM Account
                                               WHERE Id IN :oldAccountIdSet]);
        
        //Call the method to delete the PFRShare for old records
        if(pfrIdOldAccountIdMap != NULL && !pfrIdOldAccountIdMap.isEmpty()){
            deletePFRShare(pfrIdOldAccountIdMap, oldAccountMap);
        }
        
        /* for(Account accountRecord : [SELECT Id, Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Channel_Program__c, Core_MDF_Group_Id__c
FROM Account
WHERE Id IN :oldAccountIdSet]){
oldAccountMap.put(accountRecord.Id, accountRecord);
} */
        String region = '';
        String subRegion = '';
        string Region_sub='';
        string Old_region_sub='';
        string new_region_sub='';
        string new_regn_sub='';
        //Put one Map instead of 3 Maps
        system.debug('here-->0'+newActivityMap.keySet());
        //US1098882
        for(PartnerFundRequest pfr : [SELECT Id, ChannelPartnerId,Core_MDF_Program__c, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, /*Core_MDF_Region_cd__c,*/ Core_MDF_Region_nm__c,
                                      ChannelPartner.Core_MDF_Channel_Program__c,ChannelPartner.Core_MDF_Channel_Program__r.Name, /*Core_MDF_Sub_Region_cd__c,*/ Core_MDF_Sub_Region_nm__c,
                                      ChannelPartner.Core_MDF_Group_Id__c, ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c
                                      FROM PartnerFundRequest WHERE Id IN :newActivityMap.keySet()]){
                                          accountIdSet.add(oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_CoMarketing_Ultimate_Account__c);
                                          programIdSet.add(oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_Channel_Program__c);
                                          programStrSet.add(oldActivityMap.get(pfr.Id).Core_MDF_Program__c);
                                          
                                          // geoStringSet.add(oldActivityMap.get(pfr.Id).Core_MDF_Region_cd__c);
                                          List<String> oldRegions = new List<String>();
                                          if(oldActivityMap.get(pfr.Id).Core_MDF_Region_nm__c != null){
                                              oldRegions = oldActivityMap.get(pfr.Id).Core_MDF_Region_nm__c.split(';');
                                          }
                                          if(!oldRegions.isEmpty()){
                                              geoStringSet.addAll(oldRegions);
                                          }
                                          
                                          
  
                                              //US1098882
                                              //geoStringSet.add(oldActivityMap.get(pfr.Id).Core_MDF_Region_cd__c);
                                              geoStringSet.add(oldActivityMap.get(pfr.Id).Core_MDF_Region_nm__c);
                                              
                                              //Populate a String of Account + ProgramId + Geo + SubRegion(If Applicable) to delete old share records
                                              //if(oldActivityMap.get(pfr.Id).Core_MDF_Sub_Region_cd__c != NULL){
                                              //US1098882
                                              if(oldActivityMap.get(pfr.Id).Core_MDF_Sub_Region_nm__c != NULL){
                                                  //US1098882
                                                  //String accountIdProgramIdGeoSubGeo = (String)oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_CoMarketing_Ultimate_Account__c + (String)oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_Channel_Program__c + oldActivityMap.get(pfr.Id).Core_MDF_Region_cd__c + oldActivityMap.get(pfr.Id).Core_MDF_Sub_Region_cd__c;
                                                  String accountIdProgramIdGeoSubGeo = (String)oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_CoMarketing_Ultimate_Account__c + (String)oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_Channel_Program__c + oldActivityMap.get(pfr.Id).Core_MDF_Region_nm__c + oldActivityMap.get(pfr.Id).Core_MDF_Sub_Region_nm__c;

                                                  //String accountIdProgramIdGeoSubGeo = (String)oldActivityMap.get(pfr.Id).ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + (String)oldActivityMap.get(pfr.Id).ChannelPartner.Core_MDF_Channel_Program__c + oldActivityMap.get(pfr.Id).Core_MDF_Region_cd__c + oldActivityMap.get(pfr.Id).Core_MDF_Sub_Region_cd__c;
                                                  accountIdProgramIdGeoSubGeoStringSet.add(accountIdProgramIdGeoSubGeo);
                                                  
                                              }
                                              else{
                                                  //US1098882
                                                  //String accountIdProgramIdGeo = (String)oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_CoMarketing_Ultimate_Account__c + (String)oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_Channel_Program__c + oldActivityMap.get(pfr.Id).Core_MDF_Region_cd__c;
                                                  String accountIdProgramIdGeo = (String)oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_CoMarketing_Ultimate_Account__c + (String)oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_Channel_Program__c + oldActivityMap.get(pfr.Id).Core_MDF_Region_nm__c;
                                                  //String accountIdProgramIdGeo = (String)oldActivityMap.get(pfr.Id).ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + (String)oldActivityMap.get(pfr.Id).ChannelPartner.Core_MDF_Channel_Program__c + oldActivityMap.get(pfr.Id).Core_MDF_Region_cd__c;
                                                  accountIdProgramIdGeoStringSet.add(accountIdProgramIdGeo);
                                              }
                                              
                                              //Check if change in program/Geo/Sub-Region/BudgetType for re-trigger sharing 
                                              //US949836 : New Budget Type field changes replaced txt field with new global picklist field
                                              //US1098882: Replace Core_MDF_Region_cd__c with Core_MDF_Region_nm__c && Core_MDF_Sub_Region_cd__c with Core_MDF_Sub_Region_nm__c 
                                              if((oldActivityMap.get(pfr.Id).RecordTypeId != newActivityMap.get(pfr.Id).RecordTypeId)|| //Program
                                                 (oldActivityMap.get(pfr.Id).Core_MDF_Region_nm__c != newActivityMap.get(pfr.Id).Core_MDF_Region_nm__c) ||//Geo
                                                 (
                                                     (oldActivityMap.get(pfr.Id).Core_MDF_Sub_Region_nm__c != NULL || newActivityMap.get(pfr.Id).Core_MDF_Sub_Region_nm__c != NULL) && //Subgeo
                                                     oldActivityMap.get(pfr.Id).Core_MDF_Sub_Region_nm__c != newActivityMap.get(pfr.Id).Core_MDF_Sub_Region_nm__c
                                                 ) || //Budget Type 
                                                 (
                                                     (oldActivityMap.get(pfr.Id).Core_MDF_Budget_Type_nm__c != NULL || newActivityMap.get(pfr.Id).Core_MDF_Budget_Type_nm__c != NULL) && 
                                                     (oldActivityMap.get(pfr.Id).Core_MDF_Budget_Type_nm__c != newActivityMap.get(pfr.Id).Core_MDF_Budget_Type_nm__c)
                                                 )
                                                ){
                                                    updatedActivityMap.put(pfr.Id,newActivityMap.get(pfr.Id));
                                                }
                                              //Check if change in Account/Owner for re-trigger sharing 
                                              if((oldActivityMap.get(pfr.Id).OwnerId != newActivityMap.get(pfr.Id).OwnerId) || //Owner
                                                 (pfrIdAccountIdMap.get(pfr.Id) != newActivityMap.get(pfr.Id).ChannelPartnerId)){ //Account
                                                     updatedActivityMap.put(pfr.Id,newActivityMap.get(pfr.Id));
                                                     /*if owner/account changes - prepare the objId grp id map to create share records 
* objectIdUserGroupIdListMap is merged into Core_MDF_CCP_GenericUtility.createShareRecordsForInternal 
*/
                                                     if(Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd(pfr.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c)){
                                                         objectIdUserGroupIdListMap.put(pfr.Id, new List<Id>{pfr.ChannelPartner.Core_MDF_Group_Id__c});
                                                     }                
                                                 }
                                         
                                      }//End of PFR for loop
        
        /* if(objectIdUserGroupIdListMap != NULL && !objectIdUserGroupIdListMap.isEmpty()){
Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('PartnerFundRequestShare', objectIdUserGroupIdListMap, 'Edit', 'Manual');
Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
} */
        
        //Fetch the RO share groups from metadata to delete Old RO share records
        for(Core_MDF_ProgramGeoGroupMap__mdt programGeoMap :[SELECT Core_MDF_Program__c, Core_MDF_Region__c,Core_MDF_Sub_Region__c,Core_MDF_Group_Name_RO__c,Core_MDF_Group_Name__c
                                                             FROM Core_MDF_ProgramGeoGroupMap__mdt
                                                             WHERE Core_MDF_Program__c IN  :programStrSet
                                                             AND Core_MDF_Region__c IN :geoStringSet]){
                                                                 groupRORWIdSet.add(programGeoMap.Core_MDF_Group_Name_RO__c);
                                                                 groupRORWIdSet.add(programGeoMap.Core_MDF_Group_Name__c);     
                                                             }
        //Get group id's from PGM based to delete records based on Account/Program/Geo/Subgeo
        groupIdSet = Core_MDF_CCP_GenericUtility.fetchGroupIdsFromPGM(accountIdSet, programIdSet, geoStringSet, accountIdProgramIdGeoSubGeoStringSet, accountIdProgramIdGeoStringSet);
        
        Set<Id> groupROIdSet = new Set<Id>();
        //Fetch group id's from DeveloperName of groupRORWIdSet 
        for(Group grpId : [SELECT Id
                           FROM Group
                           WHERE DeveloperName IN :groupRORWIdSet]){
                               groupROIdSet.add(grpId.Id);
                           }
        
        
        if(updatedActivityMap != NULL && updatedActivityMap.size() > 0 ){
            if((groupIdSet != NULL && groupIdSet.size() > 0 ) || 
               (groupROIdSet != NULL && groupROIdSet.size()>0)){
                   
                   List<PartnerFundRequestShare> pfrShareToBeDeletedList = [SELECT Id, ParentId, RowCause, UserOrGroupId
                                                                            FROM PartnerFundRequestShare
                                                                            WHERE  ParentId IN :updatedActivityMap.keySet() AND
                                                                            RowCause =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RowCause_Manual') AND 
                                                                            (UserOrGroupId  IN :groupIdSet OR UserOrGroupId IN :groupROIdSet)];
                   if(pfrShareToBeDeletedList != NULL && pfrShareToBeDeletedList.size() > 0){
                       delete pfrShareToBeDeletedList;
                   }
               }
        }
        List<Id> pfrIdList = new List<Id>();
        pfrIdList.addAll(updatedActivityMap.keySet());
        if(pfrIdList != NULL && pfrIdList.size() > 0){            
            Core_MDF_GeoBasedGenericSharing.checkObjectAndPgm('PartnerFundRequest', pfrIdList);
        }
    }
    
    private static Boolean run = true;
    public static Boolean runOnce()
    {
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
    
    /***************************************************************************************************** 
Method Name   :        deletePFRShare
@return       :        void
@parameters   :        Map<Id, Id> pfrIdAccountIdMap, Map<Id, Account> accountMap
Description   :        deletes Activity share records
******************************************************************************************************/    
    public static void deletePFRShare(Map<Id, Id> pfrIdAccountIdMap, Map<Id, Account> accountMap){
        Map<Id, Id> pfrIdGroupIdMap = new Map<Id, Id>();
        List<PartnerFundRequestShare> pfrShareList = new List<PartnerFundRequestShare>();
        for(Id pfrId : pfrIdAccountIdMap.keySet()){
            if(pfrIdAccountIdMap.get(pfrId) != null && accountMap.get(pfrIdAccountIdMap.get(pfrId)).Core_MDF_Group_Id__c != null) {
                pfrIdGroupIdMap.put(pfrId, accountMap.get(pfrIdAccountIdMap.get(pfrId)).Core_MDF_Group_Id__c);   
            }
        }
        
        if(pfrIdGroupIdMap != NULL && !pfrIdGroupIdMap.isEmpty()){
            for(PartnerFundRequestShare pfrShare : [SELECT Id, ParentId, UserOrGroupId
                                                    FROM PartnerFundRequestShare
                                                    WHERE ParentId IN :pfrIdGroupIdMap.keySet() AND 
                                                    UserOrGroupId IN :pfrIdGroupIdMap.values() AND
                                                    RowCause = 'Manual']){
                                                        if(pfrIdGroupIdMap.get(pfrShare.ParentId) == pfrShare.UserOrGroupId){
                                                            pfrShareList.add(pfrShare);
                                                        }
                                                    }
            if(pfrShareList != NULL && !pfrShareList.isEmpty()){
                delete pfrShareList;
            }
        }
    }
    
    /*
* Method Name : shareActivityWithAccNodeGroup
* Description : shares records with account manager group
* Input Params: Map<Id,PartnerFundRequest> from Trigger.newMap, Map<Id,PartnerFundRequest> from Trigger.oldMap
* Return      : None
*/ 
    /*public static void shareActivityWithAccNodeGroup(Map<Id,PartnerFundRequest> newActivityMap){
        Map<Id,Id> pfrIdAccIdMap = new Map<Id,Id>();
        Map<Id,Id> accIdGroupIdMap = new Map<Id,Id>();
        List<PartnerFundRequestShare> pfrShareList = new List<PartnerFundRequestShare>();
        Map<Id,List<Id>> objectIdUserGroupIdListMap = new Map<Id,List<Id>>();
        
        for(Id pfrId : newActivityMap.keySet()) {      
            pfrIdAccIdMap.put(pfrId, newActivityMap.get(pfrId).ChannelPartnerId);      
        }
        
        if(pfrIdAccIdMap != NULL && !pfrIdAccIdMap.isEmpty()){
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Core_MDF_Group_Id__c, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c
                                                                FROM Account
                                                                WHERE Id IN :pfrIdAccIdMap.values() 
                                                                AND Core_MDF_Group_Id__c != NULL]);
            if(accountMap != NULL && !accountMap.isEmpty()) {
                for(Id pfrId : pfrIdAccIdMap.keySet()){
                    if(pfrIdAccIdMap.get(pfrId) != NULL && accountMap.get(pfrIdAccIdMap.get(pfrId)) != NULL && 
                       (Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd((accountMap.get(pfrIdAccIdMap.get(pfrId))).Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c))){ 
                           objectIdUserGroupIdListMap.put(pfrId, new List<Id>{accountMap.get(pfrIdAccIdMap.get(pfrId)).Core_MDF_Group_Id__c});
                       }
                }
                
                if(objectIdUserGroupIdListMap != NULL && !objectIdUserGroupIdListMap.isEmpty()){
                    Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('PartnerFundRequest', objectIdUserGroupIdListMap, 'Edit', 'Manual');
                    Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
                }
            }
        }
    }*/
    /*****************************************************************************************************
Method Name :   fetchProdCategory
@return     :   List<PartnerFundRequest>
@parameters :   New PFR List, Old PFR Map
Description :   Fetch Product Category based on Category and Product
Added By    :   NZ
Modified By :                      Date:09/04/2020                     Changes:None
******************************************************************************************************/
   /* public static List<PartnerFundRequest> fetchProdCategory(List<PartnerFundRequest> newPFRList, Map<Id, PartnerFundRequest> oldMap){ 
        Map<String, String> prodTypeCategoryMap = new Map<String, String>();
       List<Core_MDF_Product_Type_Category_Split__mdt> prdTypeCategoryList = Core_MDF_Product_Type_Category_Split__mdt.getAll().values();
        for(Core_MDF_Product_Type_Category_Split__mdt prodTypeCat : prdTypeCategoryList){                                 
                                                                          prodTypeCategoryMap.put(prodTypeCat.Core_MDF_Product_Type_txt__c , prodTypeCat.Core_MDF_Product_Category_txt__c);
                                                                      }
        
        for(PartnerFundRequest pfr : newPFRList){
            if(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AppliPrgmsFor_Product_Cat_Split').contains(pfr.Core_MDF_Program__c) && pfr.Core_MDF_ProductType__c != NULL && prodTypeCategoryMap.containsKey(pfr.Core_MDF_ProductType__c)){
                if(oldMap == NULL || //insert
                   (oldMap != NULL && !oldMap.isEmpty() && oldMap.containsKey(pfr.Id) && pfr.Core_MDF_ProductType__c != oldMap.get(pfr.Id).Core_MDF_ProductType__c)){//Product Type update
                       pfr.Core_MDF_Product_Category_txt__c = prodTypeCategoryMap.get(pfr.Core_MDF_ProductType__c);
                   }
            }
        }
        return newPFRList;
    }
*/
    
    /*****************************************************************************************************
Method Name :   validateActivityWithCampaign
@return     :   NULL
@parameters :   Map of old Activity record and Map of new Activity record
Description :   It throws the error if Sum of Activity Amount Increase beyond Campaign Amount
Added By    :   SS
Modified By :                      Date:07/16/2020                     Changes:None
******************************************************************************************************/
    public static void validateActivityWithCampaign(Map<Id,PartnerFundRequest> oldMap, List<PartnerFundRequest> newList, Boolean isAfter){
        try{
        // Get all the activities whose Amount is decreased
        Map<Id, Set<PartnerFundRequest>> campActivitiesSetMap = new Map<Id, Set<PartnerFundRequest>>();
        //Set<String> programsForActBudgetAmtCheck = new Set<String>();
        Set<Id> pfrIds = new Set<Id>();
        //Map to store the Activity as key and its Available Budget Amount.
        Map<Id,Decimal> mapOfCampWithAvailableBudget = new Map<Id,Decimal>();
        
        List<String> programsForActBudgetAmtCheck = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Prog_For_Bgt_Validation_PFR').split(';');
        //Map created for OPAL Validations - Activity Id to Budget Id
        Map<String,Id> campaignIdBudgetTypeToBudgetIdMap = new Map<String,Id>();
        
        //Map contains sum of all the activities amount against CampaignId+BudgetId+BudgetType
        Map<String,Decimal> budgetAgainstAmountMap = new Map<String,Decimal>();  
        
        //Map contains the campaign-budget's amount against CampaignId+BudgetId+BudgetType
        Map<String,Decimal> cmpIdBudgetIdBudgetTypeToAmountMap = new Map<String,Decimal>();
        
        //MDF, MDF+, OEM CMP
        List<String> opalBudgetTypeList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_OPAL_BudgetTypes').Split(';');
        String retailMDF_BudgetType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RetailMDF_BudgetType');
        List<Campaign> campReimbAmount = new List<Campaign>();
        Decimal pfrCampaignAmtAccount = 0;
         Set<Id> accountId = new Set<Id>();
        Boolean isRMF = false;
        Boolean isIPAAccountBased = false;
        Boolean checkCampaignError = false;
        Map<Id, Campaign> campaignMap = new Map<Id, Campaign>();
        Set<Id> allocationIdSet = new Set<Id>();
        //Varun
        //String budgetTypesApplicableForAllocationValidation = 'MDF;MDF+';
        //List<String> budgetTypeReqAllocationValidationList = budgetTypesApplicableForAllocationValidation.split(';');
        List<String> budgetTypeReqAllocationValidationList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ActBudgtTypesForAllocationCheck').split(';');
        //Opal CampaignId set
        Set<Id> campaignIdSet = new Set<Id>();
         Set<Id> rmfBudgetId = new Set<Id>();
          decimal rmfAmount = 0;
        System.debug('programsForActBudgetAmtCheckBEFORE'+programsForActBudgetAmtCheck);
        
        // US949836 : New Budget Type field changes replaced txt field with new global picklist field
        for(PartnerFundRequest pfr : newList){
            System.debug('PROGRAMfor' +pfr.Core_MDF_Program__c);
            if(programsForActBudgetAmtCheck.contains(pfr.Core_MDF_Program__c) || (isAfter && Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_IPA').equalsIgnoreCase(pfr.Core_MDF_Program__c))){
                System.debug('programsForActBudgetAmtCheckAFTER'+programsForActBudgetAmtCheck);
                
                if((oldMap != NULL && !oldMap.isEmpty() && 
                    pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c != oldMap.get(pfr.Id).Core_MDF_Activity_Reimbursement_Amt_nbr__c &&
                    pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c > oldMap.get(pfr.Id).Core_MDF_Activity_Reimbursement_Amt_nbr__c &&
                    ((pfr.Core_MDF_Fund_Request_Status__c != 'Cancelled') || oldMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c != 'Cancelled')) ||
                   oldMap == NULL || (oldMap != null && ((oldMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c != pfr.Core_MDF_Fund_Request_Status__c 
                                                          && Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Cancelled_Status').equalsIgnoreCase(pfr.Core_MDF_Fund_Request_Status__c))
                                                         || oldMap.get(pfr.Id).RequestedAmount != pfr.RequestedAmount))){ 
                                                             if(opalBudgetTypeList.contains(pfr.Core_MDF_Budget_Type_nm__c)){
                                                                 String campaignIdBudgetType = string.valueOf(pfr.CampaignId)+pfr.Core_MDF_Budget_Type_nm__c;
                                                                 campaignIdBudgetTypeToBudgetIdMap.put(campaignIdBudgetType, pfr.BudgetId);
                                                                 campaignIdSet.add(pfr.CampaignId);
                                                                 checkCampaignError = true;
                                                                 if(budgetTypeReqAllocationValidationList.contains(pfr.Core_MDF_Budget_Type_nm__c)){
                                                                     allocationIdSet.add(pfr.AllocationId);
                                                                 }
                                                             }else if(isAfter && pfr.Core_MDF_Program__c == 'Intel Partner Alliance' && pfr.Core_MDF_Proposal_Based_Ind__c == true){
                                                                 
                                                                 if(campActivitiesSetMap.containsKey(pfr.CampaignId)){  
                                                                     campActivitiesSetMap.get(pfr.CampaignId).add(pfr);
                                                                 }else{ 
                                                                     campActivitiesSetMap.put(pfr.CampaignId, new Set<PartnerFundRequest>{pfr}); 
                                                                 }
                                                             }
                                                             else if(!isAfter && pfr.Core_MDF_Program__c == 'Intel Partner Alliance' && pfr.Core_MDF_Proposal_Based_Ind__c == false){
                                                              
                                                                isIPAAccountBased = true;
                                                                         String campaignIdBudgetType = string.valueOf(pfr.CampaignId)+pfr.Core_MDF_Budget_Type_nm__c;
                                                                       
                                                                         campaignIdBudgetTypeToBudgetIdMap.put(campaignIdBudgetType, pfr.BudgetId);
                                                                 
                                                                         campaignIdSet.add(pfr.CampaignId);
                                                                
                                                                         allocationIdSet.add(pfr.AllocationId);
                                                                 
                                                                         checkCampaignError = true;
                                                                 
                                                             }
                                                             else if(!isAfter && pfr.Core_MDF_Program__c == 'Retail Marketing Funds' &&
                                                                     budgetTypeReqAllocationValidationList.contains(pfr.Core_MDF_Budget_Type_nm__c)){                                                              
                                                                    isRMF = true;
                                                                    String campaignIdBudgetType = string.valueOf(pfr.CampaignId)+pfr.Core_MDF_Budget_Type_nm__c;
                                                                    campaignIdBudgetTypeToBudgetIdMap.put(campaignIdBudgetType, pfr.BudgetId);
                                                                    campaignIdSet.add(pfr.CampaignId);
                                                                     rmfAmount =  pfr.Core_MDF_Campaign_Amount__c;
                                                                     pfr.Amount = pfr.RequestedAmount;                                                                     
                                                                     if(pfr.Core_MDF_Fund_Request_Status__c=='Cancelled' && pfr.status == 'Approved'){
                                                                          pfr.status = 'Rejected';
                                                                      }
                                                                     allocationIdSet.add(pfr.AllocationId);
                                                                     checkCampaignError = true;                                                                 
                                                             }
                                                             if(oldMap != NULL && !oldMap.isEmpty()){
                                                               //  if(!isRMF ){
                                                                     pfrIds.add(pfr.Id); 
                                                               //  }
                                                                
                                                             }
                                                         }              
            }
        }
        if(isIPAAccountBased){
            
        campReimbAmount = [select Core_MDF_Reimbursement_Amt__c from Campaign where id IN:campaignIdSet ];
             
        for(Campaign cmp : campReimbAmount){
        pfrCampaignAmtAccount =(Decimal)cmp.get('Core_MDF_Reimbursement_Amt__c');
            
        }
        }
        // Calculate the Total Amaount of Activities Under Same Campaign
        // For IPA Record Type
        if(isAfter && campActivitiesSetMap != NULL && campActivitiesSetMap.size() > 0){
            // Get the Campaigns Amount
            /*for(Campaign camp : [Select Id, Core_MDF_Total_Campaign_Cost_Amt__c,Core_MDF_Reimbursement_Amt__c from Campaign where Id IN : campActivitiesSetMap.keySet()])
{
// Add Campaigns Id and Amount in Map
mapOfCampWithAvailableBudget.put(camp.Id, camp.Core_MDF_Reimbursement_Amt__c);
}*/
            
            //Aggregate result to the Sum of Claims Amount on an Activity
            /*List<AggregateResult> sumofPFRRequestedAmount = [SELECT CampaignID, SUM(Core_MDF_Activity_Reimbursement_Amt_nbr__c) pfrRequestedAmt, MAX(Campaign.Core_MDF_Reimbursement_Amt__c) pfrCampaignAmount 
FROM PartnerFundRequest
WHERE CampaignID IN :campActivitiesSetMap.keySet() AND
Core_MDF_Fund_Request_Status__c <> 'Cancelled' AND
Id Not IN :pfrIds
GROUP BY CampaignID];*/
            List<AggregateResult> sumofPFRRequestedAmount = [SELECT CampaignID, SUM(RequestedAmount) TotalCampaignCost 
                                                             FROM PartnerFundRequest
                                                             WHERE CampaignID IN :campActivitiesSetMap.keySet() AND
                                                             Core_MDF_Fund_Request_Status__c <> 'Cancelled'
                                                             GROUP BY CampaignID];
            
            List<Campaign> cmpLstTobeUpdated = new List<Campaign>();
            //To Obtain the Available Amount by decducting the sum of the Request Amount from the Camapign Budget Amount
            if(sumofPFRRequestedAmount != null && sumofPFRRequestedAmount.size() > 0){
                for(AggregateResult agg : sumofPFRRequestedAmount){
                    /*Decimal pfrCampaignAmount =(Decimal)agg.get('pfrCampaignAmount');
Decimal pfrRequestedAmt=(Decimal)agg.get('pfrRequestedAmt');
if(pfrCampaignAmount != NULL && pfrRequestedAmt != NULL ){
mapOfCampWithAvailableBudget.put((id)agg.get('CampaignID'), pfrCampaignAmount - pfrRequestedAmt);
}*/
                    final Decimal pfrCampaignAmt =(Decimal)agg.get('TotalCampaignCost');
                    if (pfrCampaignAmt != null) {
                        Campaign cmpObj = new Campaign();
                        cmpObj.Id = (Id)agg.get('CampaignID');
                        cmpObj.Core_MDF_Total_Campaign_Cost_Amt__c = pfrCampaignAmt;
                        cmpLstTobeUpdated.add(cmpObj);
                    }
                }
                if (isAfter && cmpLstTobeUpdated != null && !cmpLstTobeUpdated.isEmpty()) {
                    update cmpLstTobeUpdated;
                }
            }
        }
  
        //For OPAL && RMF
        if(!isAfter && campaignIdBudgetTypeToBudgetIdMap != NULL && campaignIdBudgetTypeToBudgetIdMap.Size() > 0){
            
            Map<Id, Decimal> allocationInDraftState = new Map<Id, Decimal>();
            Map<Id, Decimal> finalAllocationAmountMap = new Map<Id, Decimal>();
            map<Id, Decimal> allocationIdToAllocatedAmountMap = new Map<Id,Decimal>();
            
            if(allocationIdSet != NULL && allocationIdSet.Size() > 0){
                
                for(PartnerFundAllocation pfa : [SELECT Id, Amount, TotalApprovedFrs 
                                                 FROM PartnerFundAllocation
                                                 WHERE Id IN: allocationIdSet]){
                                                     finalAllocationAmountMap.put(pfa.Id,  pfa.TotalApprovedFrs);
                                                     
                                                     allocationIdToAllocatedAmountMap.put(pfa.Id,pfa.Amount);
                                                      
                                                 }
            }

            if(!isRMF){  
            for(Core_MDF_Campaign_Budgets__c campBudget : [SELECT Id, Core_MDF_Reimbursement_Amt__c, Core_MDF_Budget_Type_Nm__c,
                                                           Core_MDF_Campaign_Id__c,Core_MDF_Budget_Name_Id__c
                                                           FROM Core_MDF_Campaign_Budgets__c
                                                           WHERE Core_MDF_Budget_Name_Id__c IN: campaignIdBudgetTypeToBudgetIdMap.values() AND
                                                           Core_MDF_Campaign_Id__c IN: campaignIdSet]){
                                                               String cmpIdBudgetIdBudgetType = String.ValueOf(campBudget.Core_MDF_Campaign_Id__c) + campBudget.Core_MDF_Budget_Name_Id__c + campBudget.Core_MDF_Budget_Type_Nm__c;
                                                               cmpIdBudgetIdBudgetTypeToAmountMap.put(cmpIdBudgetIdBudgetType, campBudget.Core_MDF_Reimbursement_Amt__c);              
                                                           }
               }
         
            // US949836 : New Budget Type field changes replaced txt field with new global picklist field
             
            for(PartnerFundRequest pfr : [SELECT Id, BudgetId, Core_MDF_Activity_Reimbursement_Amt_nbr__c, 
                                          Core_MDF_Fund_Request_Status__c, CampaignId, Core_MDF_Budget_Type_nm__c
                                          FROM PartnerFundRequest
                                          WHERE BudgetId IN: campaignIdBudgetTypeToBudgetIdMap.values() AND
                                          Core_MDF_Fund_Request_Status__c != 'Cancelled' AND
                                          CampaignId IN: campaignIdSet AND
                                          Id NOT IN: pfrIds]){
                                              String cmpIdBudgetIdBudgetType = String.ValueOf(pfr.CampaignId) + pfr.BudgetId + pfr.Core_MDF_Budget_Type_nm__c;
                                               
                                               
                                              if(budgetAgainstAmountMap.containsKey(cmpIdBudgetIdBudgetType) && pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c != null){
                                                  decimal amount = budgetAgainstAmountMap.get(cmpIdBudgetIdBudgetType) + pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c;
                                                  budgetAgainstAmountMap.put(cmpIdBudgetIdBudgetType, amount);
                                                 
                                              }else{
                                                  if(pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c != null){
                                                  decimal amount = pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c;
                                                  budgetAgainstAmountMap.put(cmpIdBudgetIdBudgetType, amount);

                                              }
                                          }
                                          }
            
     
            for(PartnerFundRequest pfr : newList){
                Boolean addError = FALSE;
             
                
                
                if(budgetTypeReqAllocationValidationList.contains(pfr.Core_MDF_Budget_Type_nm__c) || (pfr.Core_MDF_Program__c == 'Intel Partner Alliance' && pfr.Core_MDF_Proposal_Based_Ind__c == false)){
                    decimal pfrsUsingAllocation = 0;
                    decimal allocationAmount = 0;
                    decimal currentActivityAmount = 0;
                    decimal totalPfrAmountUsingAllocation = 0;
                    System.debug('AllocationID'+pfr.AllocationId);
                    if(finalAllocationAmountMap.containsKey(pfr.AllocationId) && finalAllocationAmountMap.get(pfr.AllocationId) != NULL){
                        pfrsUsingAllocation = finalAllocationAmountMap.get(pfr.AllocationId);
                    }
 
                    if(allocationIdToAllocatedAmountMap.containsKey(pfr.AllocationId) &&
                       allocationIdToAllocatedAmountMap.get(pfr.AllocationId) != NULL){
                           allocationAmount = allocationIdToAllocatedAmountMap.get(pfr.AllocationId);
                       }
     
                    if(oldMap != NULL && oldMap.containsKey(pfr.Id) && (pfr.Amount > oldMap.get(pfr.Id).Amount)){
                        currentActivityAmount = pfr.Amount - oldMap.get(pfr.Id).Amount; 
                    }else if(oldMap == NULL){   
                        currentActivityAmount = pfr.Amount;
                    }
                   currentActivityAmount = currentActivityAmount!=null ? currentActivityAmount:0;
                     decimal existingPfrAmount=0;
                    if(isRMF){
                       String cmpIdBudgetIdBudgetType = String.ValueOf(pfr.CampaignId) + pfr.BudgetId + pfr.Core_MDF_Budget_Type_nm__c;
                         existingPfrAmount = budgetAgainstAmountMap.get(cmpIdBudgetIdBudgetType); 
                         existingPfrAmount= existingPfrAmount !=null ? existingPfrAmount:0;
                       //  totalPfrAmountUsingAllocation = existingPfrAmount + currentActivityAmount;
                    }
                        pfrsUsingAllocation = pfrsUsingAllocation !=null ? pfrsUsingAllocation:0;
                        totalPfrAmountUsingAllocation = pfrsUsingAllocation + currentActivityAmount;
                       System.debug('Core_MDF_Fund_Request_Status__c '+  pfr.Core_MDF_Fund_Request_Status__c );  
                    if(!stopRecursion){
                        stopRecursion = true;
                    if(allocationAmount < totalPfrAmountUsingAllocation && pfr.Core_MDF_Fund_Request_Status__c != 'Cancelled'){
                        pfr.addError(Label.Core_MDF_ActivityAmountExceedsAllocation);
                        addError = TRUE;
                    }
                }
                }
                
                if(!addError && campaignIdBudgetTypeToBudgetIdMap.containsKey(pfr.CampaignId+pfr.Core_MDF_Budget_Type_nm__c) && 
                   campaignIdBudgetTypeToBudgetIdMap.get(pfr.CampaignId+pfr.Core_MDF_Budget_Type_nm__c) != NULL){
                       Id budgetId = pfr.BudgetId;                  
                      
                       
                       String cmpIdBudgetIdBudgetType = String.ValueOf(pfr.CampaignId) + pfr.BudgetId + pfr.Core_MDF_Budget_Type_nm__c;
                       
                       
                       //Get amount from Campaign Budget
             decimal amountOnBudget = 0;
                       if(isRMF){
                      amountOnBudget =   rmfAmount  ; 
                       }
                       else if(isIPAAccountBased){
                        amountOnBudget = pfrCampaignAmtAccount;

                       }
                       else{   
                       amountOnBudget  =  cmpIdBudgetIdBudgetTypeToAmountMap.get(cmpIdBudgetIdBudgetType);                  
                       }
                       
                       //Get sum of all existing activities amount
                       decimal existingPfrAmount = budgetAgainstAmountMap.get(cmpIdBudgetIdBudgetType);                  
                       
                       
                       //Get current activity amount
                       decimal currentActivityAmount = pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c !=null ? pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c : pfr.Amount;                  
                       
                       
                       //Total amount to be inserted/updated
                       decimal finalAmountForCompare;
                       if(existingPfrAmount != NULL){
                           finalAmountForCompare = existingPfrAmount + currentActivityAmount;
                       }else{
                           finalAmountForCompare = currentActivityAmount;
                       }
                       
                       //Check if total amount is exceeding Campaign Budget's amount
                       if(finalAmountForCompare > amountOnBudget && checkCampaignError && pfr.Core_MDF_Fund_Request_Status__c != 'Cancelled' ){
                           pfr.addError(Label.Core_MDF_OPAL_Amount_Validation_Error);
                       }
                   } 
            }
        }                        
        /*
// Map of Campaign and PFR Set where Ammount is exceeding the campaigns amount
Map< Id, Set<PartnerFundRequest>> errorPFRRecordsWithExceedingBudgets = New Map<Id, Set<PartnerFundRequest>>();
//their Amount lies within the corresponding Campaign's Budget Amount
if(campActivitiesSetMap != NULL && !campActivitiesSetMap.isEmpty()){
for(Id campId : campActivitiesSetMap.keySet()){
//get the list of pfrs for a given campaign
Set<PartnerFundRequest> pfrSet = campActivitiesSetMap.get(campId);
if(pfrSet != NULL && !pfrSet.isEmpty()){
for(PartnerFundRequest pfr : pfrSet){
// if(pfr.CampaignId != null && pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c != null){
//Get the corresponding Actvity's Available Budget Amount
Decimal availableAmount = mapOfCampWithAvailableBudget.get(pfr.CampaignId);
Decimal activityReimbursementAmount;
if(pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c == NULL && pfr.RequestedAmount != NULL && pfr.Core_MDF_Reimbursement_Rate_pct__c != NULL){
activityReimbursementAmount = (pfr.RequestedAmount * decimal.valueOf(pfr.Core_MDF_Reimbursement_Rate_pct__c.removeEnd('%')))/100;
}else if(pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c != NULL){
activityReimbursementAmount = pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c;
}
if(activityReimbursementAmount  > availableAmount){
errorPFRRecordsWithExceedingBudgets.put(campId, pfrSet);
break;            
}else{
//If Activity Amount is lesser than or equal to the Campaign Amount,
//process it by deducting Requested Amount from the Available Amount
if(activityReimbursementAmount != NULL){
mapOfCampWithAvailableBudget.put(pfr.CampaignId, availableAmount - activityReimbursementAmount);
}
}
}
}
}
}
if(errorPFRRecordsWithExceedingBudgets != NULL && !errorPFRRecordsWithExceedingBudgets.isEmpty()){
for(Id errorCampId : errorPFRRecordsWithExceedingBudgets.keySet()){for(PartnerFundRequest errorPFR : errorPFRRecordsWithExceedingBudgets.get(errorCampId)){
//Core_MDF_Bgt_Validation_PFR : Sum of all requested Amount cannot be greater than Propasal Amount.  
//Add error if activity amount is more than the campaign's available amount
errorPFR.addError(Label.Core_MDF_Bgt_Validation_PFR);
}
}
}*/
    }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        } 
    }
/*****************************************************************************************************
Method Name :   geoLeadRecallAndSubmitApprovalProcess
@return     :   NULL
@parameters :   List of Activity record and Map of new Activity record
Description :   It approves record already in approval process
Added By    :   PD
Modified By :   NZ                   Date:07/26/2021                    Changes:None
******************************************************************************************************/
   /* public static void geoLeadRecallAndSubmitApprovalProcess(Map<id,PartnerFundRequest> pfrMap, List<PartnerFundRequest> pfrList){
        Boolean geoApprover = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Marketing_GEO_Approver'); 
        List<Id> instancrNotExists = new List<Id>();
        List<Core_MDF_Recall_Approval__e> approvalRecallList = new  List<Core_MDF_Recall_Approval__e>();
        instancrNotExists = isProcessInstanceExist(pfrList);
   
        Set<Id> pfrIdSet = new Set<Id>(); 
        Map<Id,Id> pfrIdInsIdMap = new Map<Id,Id>(); 
        String region = '';
        Boolean isEmeaFlag = false;
        for(PartnerFundRequest pfr:pfrList){
            if(pfrMap != null && pfr.Core_MDF_Start_Date__c != pfrMap.get(pfr.Id).Core_MDF_Start_Date__c && 
               geoApprover && instancrNotExists.contains(pfr.Id) && pfr.Core_MDF_Start_Date__c >= System.today()&&
               pfr.Core_MDF_Fund_Request_Status__c != pfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c &&
               pfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c =='Closed' &&
               (pfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' ||  pfr.Core_MDF_Fund_Request_Status__c == 'Pending Approval')&&
               pfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Channel_Program_Name') && (pfr.Core_MDF_Approval_Step_Completed__c == 0 || pfr.Core_MDF_Approval_Step_Completed__c == 1)){
                   //US1098882
                   //region = pfr.Core_MDF_Region_cd__c;
                   region = pfr.Core_MDF_Region_nm__c;
                   pfrIdSet.add(pfr.Id);
               }
        }
        for(ProcessInstanceNode prst : [SELECT id,ProcessNodeName,ProcessInstanceId,ProcessInstance.TargetObjectId
                                             FROM ProcessInstanceNode
                                             WHERE ProcessInstance.TargetObjectId   IN :pfrIdSet 
                                             AND ProcessInstance.Status = :'Pending' 
                                           AND ProcessNodeName = :'Geo Lead Approval']){
                                              
                                                 isEmeaFlag = true; 
                                  
                                        }
        if(isEmeaFlag){
          List<Approval.ProcessWorkitemRequest> pwrList = new List<Approval.ProcessWorkitemRequest>(); 
          for(ProcessInstanceWorkItem piwitm : [SELECT ProcessInstance.TargetObjectId, Id 
                                              FROM ProcessInstanceWorkItem
                                              WHERE ProcessInstance.Status = 'Pending' AND
                                              ProcessInstance.TargetObjectId IN:pfrIdSet LIMIT 1]){
          pfrIdInsIdMap.put(piwitm.ProcessInstance.TargetObjectId,piwitm.id); 
    }    
        for(Id pfrId : pfrIdInsIdMap.keySet()){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction('Approve');
            req.setComments('Recalled due to Geo Lead Edit');
            req.setWorkitemId(pfrIdInsIdMap.get(pfrId));
            pwrList.add(req);     
        }
        if(pwrList != NULL && pwrList.Size() > 0){
            List<Approval.ProcessResult> result = Approval.process(pwrList);
        }
        }
       
    }
    } */
    
    public static void updateTotalCampaignCostIpa(Map<Id,PartnerFundRequest> oldMap, List<PartnerFundRequest> newList, Boolean isAfter){
      try{
    // Get all the activities whose Amount is decreased
    Map<Id, Set<PartnerFundRequest>> campActivitiesSetMap = new Map<Id, Set<PartnerFundRequest>>();

        for(PartnerFundRequest pfr : newList){
            
            if(isAfter && ((Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_IPA').equalsIgnoreCase(pfr.Core_MDF_Program__c) && pfr.Core_MDF_Proposal_Based_Ind__c == true) || (pfr.Core_MDF_Program__c =='Channel MDF' && pfr.Core_MDF_Proposal_Based_Ind__c == true))){

                if(oldMap == NULL || 
                   (oldMap != null && !oldMap.isEmpty() && 
                    ((oldMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c != pfr.Core_MDF_Fund_Request_Status__c && Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Cancelled_Status').equalsIgnoreCase(pfr.Core_MDF_Fund_Request_Status__c))
                        || oldMap.get(pfr.Id).RequestedAmount != pfr.RequestedAmount))){
                        
                        if(campActivitiesSetMap.containsKey(pfr.CampaignId)){  
                            campActivitiesSetMap.get(pfr.CampaignId).add(pfr);
                        }else{ 
                            campActivitiesSetMap.put(pfr.CampaignId, new Set<PartnerFundRequest>{pfr}); 
                        }
                }               
            }
        }

        // Calculate the Total Amount of Activities Under Same Campaign
        // For IPA Record Type
        if(isAfter && campActivitiesSetMap != NULL && campActivitiesSetMap.size() > 0){
            
            // Get the Campaigns Amount
            List<AggregateResult> sumofPFRRequestedAmount = [SELECT CampaignID, SUM(RequestedAmount) TotalCampaignCost 
                                                             FROM PartnerFundRequest
                                                             WHERE CampaignID IN :campActivitiesSetMap.keySet() AND
                                                             Core_MDF_Fund_Request_Status__c <> 'Cancelled'
                                                             GROUP BY CampaignID];
            
            List<Campaign> cmpLstTobeUpdated = new List<Campaign>();
            //To Obtain the Available Amount by decducting the sum of the Request Amount from the Camapign Budget Amount
            if(sumofPFRRequestedAmount != null && sumofPFRRequestedAmount.size() > 0){
                for(AggregateResult agg : sumofPFRRequestedAmount){
                    
                    final Decimal pfrCampaignAmt =(Decimal)agg.get('TotalCampaignCost');
                    if (pfrCampaignAmt != null) {
                        Campaign cmpObj = new Campaign();
                        cmpObj.Id = (Id)agg.get('CampaignID');
                        cmpObj.Core_MDF_Total_Campaign_Cost_Amt__c = pfrCampaignAmt;
                        cmpLstTobeUpdated.add(cmpObj);
                    }
                }
                if (isAfter && cmpLstTobeUpdated != null && !cmpLstTobeUpdated.isEmpty()) {
                    update cmpLstTobeUpdated;
                }
            }
        }
      }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}  

    }
      //Changes By PD
     /*public static void shareActivityWithExternalUsers(Map<Id,PartnerFundRequest> newActivityMap, Map<Id,PartnerFundRequest> oldActivityMap, Boolean isInsert){
      
        Set<Id> accountIdSet = new Set<Id>();
        List<PartnerFundRequestShare> pfrShareList = new List<PartnerFundRequestShare>();
        Set<Id> userDetailMap = new Set<Id>();
        Set<Id> newOwnerIdSet = new Set<Id>();
        Set<Id> oldOwnerIdSet = new Set<Id>();
        Set<Id> allOwnerIdSet = new Set<Id>();      
        Set<Id> pfrIdSet = new Set<Id>();
        Set<Id> oldAccountIdSet = new Set<Id>();
        Set<Id> newAccountIdSet = new Set<Id>();
        Set<Id> allAccountIdSet = new Set<Id>();
        Map<Id,PartnerFundRequest> pfrMap = new Map<Id,PartnerFundRequest>();
        for(PartnerFundRequest pfr : newActivityMap.values()){
            PartnerFundRequest oldrPfr = oldActivityMap !=null ? oldActivityMap.get(pfr.Id) : new PartnerFundRequest();
            if((pfr.ChannelPartnerId != null && pfr.ChannelPartnerId != oldrPfr.ChannelPartnerId ) ){
                pfrIdSet.add(pfr.Id);
                pfrMap.put(pfr.Id,pfr);
                newAccountIdSet.add(pfr.ChannelPartnerId);
                allAccountIdSet.add(pfr.ChannelPartnerId);
                if(oldrPfr.ChannelPartnerId !=null){
                    oldAccountIdSet.add(oldrPfr.ChannelPartnerId);
                    allAccountIdSet.add(oldrPfr.ChannelPartnerId);
                }
            }
            
            if(pfr.OwnerId != oldrPfr.OwnerId){
               pfrMap.put(pfr.Id,pfr);
               newAccountIdSet.add(pfr.ChannelPartnerId);
                allAccountIdSet.add(pfr.ChannelPartnerId);
                if(oldrPfr.OwnerId !=null){
                    oldOwnerIdSet.add(oldrPfr.OwnerId);             
                }
            }
            allOwnerIdSet.add(pfr.ownerId);
        }
               
        Map<Id,set<Id>> accountUserMap = new Map<Id,set<Id>>();     
        accountUserMap = getUsersFromPNUM(allAccountIdSet);
        System.debug('accountUserMap'+accountUserMap);
        //delete share records
        if(oldAccountIdSet!= null && !oldAccountIdSet.isEmpty()){
            Set<Id> userIds = new Set<Id>();
            Set<Id> pfrIds = new Set<Id>();
            for(PartnerFundRequest pfr : pfrMap.values()){
                //if(accountUserMap.containsKey(pfr.ChannelPartnerId) && oldActivityMap!=null && oldAccountIdSet.contains(oldActivityMap.get(pfr.Id).ChannelPartnerId)){
                if(oldActivityMap!=null && accountUserMap.containsKey(oldActivityMap.get(pfr.Id).ChannelPartnerId) && oldAccountIdSet.contains(oldActivityMap.get(pfr.Id).ChannelPartnerId)){
                     userIds.addAll(accountUserMap.get(oldActivityMap.get(pfr.Id).ChannelPartnerId));
                    pfrIds.add(pfr.Id);
                }
            }
            if(userIds != null && pfrIds!=null ){
                deletePFRExternalShare(pfrIds, userIds);
            }
        }
       for(PartnerFundRequest pfr : pfrMap.values()){
           if(newAccountIdSet.contains(pfr.ChannelPartnerId)  && accountUserMap.containsKey(pfr.ChannelPartnerId) && accountUserMap.get(pfr.ChannelPartnerId) !=null){
               for(Id userId: accountUserMap.get(pfr.ChannelPartnerId)){
                   if(pfr.OwnerId != userId){
                    PartnerFundRequestShare pfrShare = createPartnerFundRequestShare(pfr.Id, userId, 'Edit', 'Manual'); 
                    pfrShareList.add(pfrShare);
                   }
               }
           }
       }
       if(pfrShareList != NULL && !pfrShareList.isEmpty()){
           insert pfrShareList;
       }
    }
    public static PartnerFundRequestShare createPartnerFundRequestShare(Id parentId, Id userOrGroupId, String AccessLevel, String rowcause){
       PartnerFundRequestShare pfrShare = new PartnerFundRequestShare();
       pfrShare.parentId =parentId;
       pfrShare.userOrGroupId = userOrGroupId;
       pfrShare.AccessLevel = AccessLevel;
       pfrShare.rowcause = rowcause;
      return pfrShare;
    }
    public static void deletePFRExternalShare(Set<Id> parentIdSet, Set<Id> userIdSet){
      List<PartnerFundRequestShare> pfrShareList =[SELECT Id,Rowcause FROM PartnerFundRequestShare WHERE ParentId IN:parentIdSet and
                                                    UserorGroupId IN:userIdSet and Rowcause!='Owner'];
      if(pfrShareList!=null && !pfrShareList.isEmpty()){
          delete pfrShareList;
      }
    }
    public static Map<Id,Set<Id>> getUsersFromPNUM(Set<Id> accountIdSet){
        Map<Id,Set<Id>> resultMap = new Map<Id,Set<Id>>();
        for( Core_MDF_Partner_Node_User_Mapping__c pnumObj: [SELECT Id,Core_MDF_Account__c,Core_MDF_User__c,Core_MDF_User__r.isActive FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_Account__c IN: accountIdSet and Core_MDF_User__r.isActive = true]){
            if(!resultMap.containsKey(pnumObj.Core_MDF_Account__c)){
                resultMap.put(pnumObj.Core_MDF_Account__c, new Set<Id>());
            }
            resultMap.get(pnumObj.Core_MDF_Account__c).add(pnumObj.Core_MDF_User__c);
        }
        return resultMap;
    }*/
    /***************************************************************************************************** 
Method Name   :        shareActivityWithAccNodeGroupMethod
@return       :        void
@parameters   :        Map<Id,PartnerFundRequest> newActivityMap, Map<Id,PartnerFundRequest> oldActivityMap
Description   :        Share the activity with Acc node groups
Added By      :        Accenture - Sai - 22/02/2022
******************************************************************************************************/
    public static void shareActivityWithAccNodeGroupMethod(Map<Id,PartnerFundRequest> newActivityMap, Map<Id,PartnerFundRequest> oldActivityMap){
        Map<Id,List<Id>> objectIdUserGroupIdListMap = new Map<Id,List<Id>>();
        Set<Id> pfrShareToBeDeleted = new Set<Id>();
        List<PartnerFundRequestShare> pfrShareList = new List<PartnerFundRequestShare>();
        Set<Id> accountNodeIdSet = new Set<Id>();
        Set<Id> oldAccountNodeIdSet = new Set<Id>();
        Map<Id, Id> accountIdGroupIdMap = new Map<Id, Id>();
        Map<Id, Id> accountIdExternalGroupIdMap = new Map<Id, Id>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        
        for(PartnerFundRequest pfr : newActivityMap.values()){
            PartnerFundRequest oldrPfr = oldActivityMap != null ? oldActivityMap.get(pfr.Id) : new PartnerFundRequest();
            //Checking if account changes in PFR record, then adding pfr id to a set and account id to a set to delete the old pfr share record
            if((pfr.ChannelPartnerId != null && (oldrPfr.ChannelPartnerId != null && pfr.ChannelPartnerId != oldrPfr.ChannelPartnerId))){
                pfrShareToBeDeleted.add(pfr.Id);
                accountNodeIdSet.add(oldrPfr.ChannelPartnerId);
                oldAccountNodeIdSet.add(oldrPfr.ChannelPartnerId);
            }
            accountNodeIdSet.add(pfr.ChannelPartnerId);
        }
        for(Account acc : [SELECT Id, Core_MDF_External_Group_Id__c, Core_MDF_Group_Id__c, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c FROM Account 
                           WHERE Id IN :accountNodeIdSet AND (Core_MDF_Group_Id__c != NULL OR Core_MDF_External_Group_Id__c != NULL)]){
                               if(acc.Core_MDF_Group_Id__c != null){
                                   accountIdGroupIdMap.put(acc.Id, acc.Core_MDF_Group_Id__c);
                               }
                               if(acc.Core_MDF_External_Group_Id__c != null){
                                   accountIdExternalGroupIdMap.put(acc.Id, acc.Core_MDF_External_Group_Id__c);
                               }
                               accountMap.put(acc.Id, acc);
                           }
        if(pfrShareToBeDeleted.size() > 0){
            for(Id accId : oldAccountNodeIdSet){
                for(PartnerFundRequestShare pfrShare : [SELECT Id, ParentId, UserOrGroupId, Parent.Core_MDF_Program__c
                                                        FROM PartnerFundRequestShare WHERE ParentId IN : pfrShareToBeDeleted AND
                                                        (UserOrGroupId =:accountIdGroupIdMap.get(accId) OR
                                                         UserOrGroupId =:accountIdExternalGroupIdMap.get(accId))]){
                                                             pfrShareList.add(pfrShare);
                                                         }
            }
            if(pfrShareList != NULL && pfrShareList.size() > 0){
                delete pfrShareList;
            }
        }
        for(PartnerFundRequest pfr : newActivityMap.values())
        {   
            List<Id> groupIds = new List<Id>();
            //If operation is insert OR is update and account/owner change occured in PFR record
            if(oldActivityMap == null || (oldActivityMap != null && (pfr.OwnerId != oldActivityMap.get(pfr.Id).OwnerId || pfrShareToBeDeleted.contains(pfr.Id)))){
                if(accountIdGroupIdMap.get(pfr.ChannelPartnerId) != null && (Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd((accountMap.get(pfr.ChannelPartnerId)).Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c))){
                    groupIds.add(accountIdGroupIdMap.get(pfr.ChannelPartnerId));
                    //objectIdUserGroupIdListMap.put(pfr.Id, new list<Id> {accountIdGroupIdMap.get(pfr.ChannelPartnerId)});
                }
                if(accountIdExternalGroupIdMap.get(pfr.ChannelPartnerId) != null){
                    groupIds.add(accountIdExternalGroupIdMap.get(pfr.ChannelPartnerId));
                    //objectIdUserGroupIdListMap.put(pfr.Id, new list<Id> {accountIdExternalGroupIdMap.get(pfr.ChannelPartnerId)});
                }
                }
            if(groupIds != null && groupIds.size() > 0){
                objectIdUserGroupIdListMap.put(pfr.Id, groupIds);
            }
        }
        if(objectIdUserGroupIdListMap != NULL && !objectIdUserGroupIdListMap.isEmpty()){
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('PartnerFundRequest', objectIdUserGroupIdListMap, 'Edit', 'Manual');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
        }
    }
    public static Map<String,Object> getTemplateNameByProgName(){
        String jsonInputString = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EmailTemplateMappingByProgrName');
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(jsonInputString);
        System.debug('<<resultMapOutput>>'+resultMap);
        return resultMap;
    }
     public static Map<String,Object> getTemplateNameByProgNameIPA(){
        String jsonInputString = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EmailTemplateMappingByProgIPA');
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(jsonInputString);
        System.debug('<<resultMap>>'+resultMap);
        return resultMap;
    } 
}