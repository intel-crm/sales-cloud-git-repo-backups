/***************************************************************************************************** 
Class Name :    Core_MDF_PartnerFundRequestCreatePage
Description:    Server side controller for Core_Intel_createEditPFR
Added By   :    Accenture - AS    Date:07/25/2018 
Modified By:    Ramapriya         Date:07/25/2025                     Changes:In-Progress Activity Edit Validation   
******************************************************************************************************/
public with sharing class Core_MDF_PartnerFundRequestCreatePage{
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    public static Boolean exchangeRateFlag = False;
    private static string approvedStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Status_Approved'); 
    public static Set<String> geoSet;  
    public static Set<String> subGeoSet;
    private static string pfrCancelledStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Cancelled_Status');
    private static boolean isValidUserToCancelActvity = FeatureManagement.checkPermission('Core_MDF_Allowed_Permission_Set_for_Cancel_Activity');
    private static Map<string,Boolean> fieldToEditabilityMap = new Map<string,Boolean>();
    Public static List<string> pfcStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFC_Status_CancelEligible').split(';');
    private static final String IPA_PROPOSAL_GO_LIVE_DATE = '2026-08-20';
    
    /***************************************************************************************************** 
    Method Name :   savenSendRecordId
    @return     :   RecordIdA
    @parameters :   PartnerFundRequest form data, mdfReimbursement as String for MDF/MDF+
    Description :   US106541 - Create Activity initial screen
    Added By    :   Accenture - AS 
    Modified By :                      Date:07/25/2018                     Changes:None                               
    ******************************************************************************************************/
    
    @AuraEnabled
    public static Id savenSendRecordId(PartnerFundRequest pfr, List<String> contentdocumentids, Boolean budgetException,
                                       String recType, String segmentAndProduct,string BudId,Boolean isPropIndicator,
                                       String mdfReimbursement, object tacticMetrics, object outcomeActivity, object outcomeAccountNode, object ecosystemPartner)
    {
        //Akash, IPA outcome - new parameter added -object outcomeAccountNode
        PartnerFundRequest partnerFundRequestRecord = new PartnerFundRequest();
        partnerFundRequestRecord = pfr;
        if(mdfReimbursement != null && mdfReimbursement != ''){
            partnerFundRequestRecord.Core_MDF_MDFReimbursement_Amt__c = Decimal.valueof(mdfReimbursement);
        }
        List<String> cdocumentids = contentdocumentids; String partnerFundError = '';
        Boolean isError = false;
        Boolean isCPAdded = false;
        Boolean isOCPAdded = false; 
       
        Boolean isPropBased = isPropIndicator;
        Boolean isIPAProposalBased =
    recType ==
        Core_MDF_CustomLabelConfig.getTextValues(
            'Core_MDF_IPA_RecordType'
        ) &&
    isPropBased;
        Boolean isCreation = false; // Indu IPA Proposal
        
        
        List<String> opalBudgetTypeList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_OPAL_BudgetTypes').Split(';');
        Boolean ipaL1ApproverPS = FeatureManagement.checkPermission('Core_MDF_CCP_Int_IPA_ProposalL1_Approver');  
        Map<Id, String> pfrIdSegmentMapping = new Map<Id, String>();
        

            /*List<Core_MDF_BudgetType_Benefit_Mapping__mdt> budgetTypeMappingsList = [SELECT Id, MasterLabel, Core_MDF_Budget_Type__c, Core_MDF_RecordType__c FROM Core_MDF_BudgetType_Benefit_Mapping__mdt 
                                                                                 WHERE Core_MDF_RecordType__c != null 
                                                                                 AND Core_MDF_Budget_Type__c = :partnerFundRequestRecord.Core_MDF_Budget_Type_nm__c];
        

        if(budgetTypeMappingsList != null && !budgetTypeMappingsList.isEmpty()){
            for(Core_MDF_BudgetType_Benefit_Mapping__mdt budgetTypeMapping : budgetTypeMappingsList){
             
                if(budgetTypeMapping.Core_MDF_RecordType__c == 'Proposal Based'){
                    isPropBased = true;
                }
                else {
                    isPropBased = false;
                }
            }
            }*/
            string program = partnerFundRequestRecord.Core_MDF_Program__c;
            DateTime createdDate = partnerFundRequestRecord.CreatedDate;
            Map<string,Boolean> fieldToByPassFlagMap = Core_MDF_GeneralPurpose_UI_Utility.getByPassFieldValidationConfiq('PartnerFundRequest',program,createdDate);
       
          if(String.isBlank(pfr.BudgetId) && (opalBudgetTypeList.contains(partnerFundRequestRecord.Core_MDF_Budget_Type_nm__c) )){ pfr.BudgetId=BudId;
        
        } if(!Core_MDF_Utility.byPassFeature('Core_MDF_ActModifiedByUserBypass')){if(partnerFundRequestRecord.id != null && recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType') && !isPropBased && !pfr.Core_MDF_Is_Outcome_Based_Ind__c){List<PartnerFundRequest> pfrRecordList = new List<PartnerFundRequest>();pfrRecordList  = [Select id, Core_MDF_Approval_Stage__c, Core_MDF_Fund_Request_Status__c from PartnerFundRequest where id=: partnerFundRequestRecord.id limit 1]; if(!pfrRecordList.isEmpty() && pfrRecordList[0].Core_MDF_Approval_Stage__c != partnerFundRequestRecord.Core_MDF_Approval_Stage__c || (pfrRecordList[0].Core_MDF_Fund_Request_Status__c != partnerFundRequestRecord.Core_MDF_Fund_Request_Status__c  && (pfrRecordList[0].Core_MDF_Fund_Request_Status__c == 'Closed' && partnerFundRequestRecord.Core_MDF_Fund_Request_Status__c != 'Cancelled'))){partnerFundError = System.Label.Core_MDF_Updated_By_Another_User;AuraHandledException ex = new AuraHandledException(partnerFundError);ex.setMessage(partnerFundError);throw ex;
                               }
                }   }if(recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType') && isPropBased && partnerFundRequestRecord.Id == NULL){
                isCreation = true;
            }
            if(budgetException == true)
        {
             partnerFundError=partnerFundError + System.Label.Core_MDF_Currency_Error +'<br>';            isError = true;
        }
        if(partnerFundRequestRecord.CampaignId == null && !partnerFundRequestRecord.Core_MDF_Is_Outcome_Based_Ind__c){ partnerFundError=System.Label.Core_MDF_CampaignErrorMessage + '<br/>';
            isError = true;
        }
        if(partnerFundRequestRecord.ChannelPartnerId == null){partnerFundError=partnerFundError+System.Label.Core_MDF_ChannelPartnerError +'<br>';        isError = true;
        }
            if(String.isBlank(partnerFundRequestRecord.Core_MDF_Reimbursement_Rate_txt__c) && recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType') && isPropBased){ partnerFundError=partnerFundError + System.Label.Core_MDF_Empty_Field_Error + '<br>';
                isError = true;
            }
            if(String.isBlank(partnerFundRequestRecord.Core_MDF_Focus_Area_nm__c) && recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType')){ partnerFundError=partnerFundError + System.Label.Core_MDF_Focus_Area_Error_Message + '<br>';
                isError = true;
            }
          if(String.isBlank(partnerFundRequestRecord.Core_MDF_TargetAudience__c) && !(recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType')  || recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NRE_RecordType'))){partnerFundError=partnerFundError + System.Label.Core_MDF_TargetAudienceError +'<br>';isError = true;
            
        }  if(String.isBlank(partnerFundRequestRecord.Core_MDF_ProductType__c) && !(recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType')  || recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NRE_RecordType'))){partnerFundError=partnerFundError + System.Label.Core_MDF_ProductTypeError + '<br/>';
            isError = true;
           
        }if(String.isBlank(partnerFundRequestRecord.Core_MDF_Brand_nm__c) && !(recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType')  || recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NRE_RecordType'))){partnerFundError=partnerFundError + System.Label.Core_MDF_BrandError +'<br>';isError = true;
        }
          Boolean byPassInitiativeValidation = Core_MDF_GeneralPurpose_UI_Utility.isByPassFieldValidation(fieldToByPassFlagMap,'Core_MDF_Initiative_nm__c');if(String.isBlank(partnerFundRequestRecord.Core_MDF_Initiative_nm__c) && recType == System.Label.Core_MDF_PFR_Retail && !byPassInitiativeValidation){partnerFundError=partnerFundError + System.Label.Core_MDF_Initiative_Error_Msg +'<br>';            isError = true;
            }
        if(String.isBlank(partnerFundRequestRecord.Core_MDF_ActivityCategory__c) && !(recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NRE_RecordType'))){ partnerFundError=partnerFundError + System.Label.Core_MDF_ActivityCategoryError +'<br>';
            isError = true;
        }
        if(String.isBlank(partnerFundRequestRecord.Core_MDF_Activity_Types__c) && !(recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NRE_RecordType'))){ partnerFundError=partnerFundError + System.Label.Core_MDF_ActivityTypeError + '<br>';
            isError = true;
        }
            if(String.isNotBlank(partnerFundRequestRecord.Core_MDF_Focus_Area_nm__c) && recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType')){ if(String.isBlank(partnerFundRequestRecord.Core_MDF_Initiative_nm__c)){
                    partnerFundError=partnerFundError + System.Label.Core_MDF_Initiative_Error_Msg + '<br>';
                    isError = true;
                }
                   if(String.isBlank(partnerFundRequestRecord.Core_MDF_TargetAudience_nm__c) && !(recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NRE_RecordType'))){partnerFundError=partnerFundError + System.Label.Core_MDF_TargetAudienceError + '<br>';
                    isError = true;
                } if(String.isBlank(partnerFundRequestRecord.Core_MDF_Industry_Multi_nm__c) && !partnerFundRequestRecord.Core_MDF_Is_Outcome_Based_Ind__c && !(recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NRE_RecordType'))){partnerFundError=partnerFundError + System.Label.Core_MDF_Industry_Error_Msg + '<br>';
                    isError = true;
                } if(String.isBlank(partnerFundRequestRecord.Core_MDF_Priority_nm__c) && !(recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NRE_RecordType'))){  partnerFundError=partnerFundError + System.Label.Core_MDF_Priority_Error + '<br>';
                    isError = true;
                }
                if(String.isBlank(partnerFundRequestRecord.Core_MDF_ProductType__c) && !(recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NRE_RecordType'))){  partnerFundError=partnerFundError + System.Label.Core_MDF_ProductTypeError + '<br>';
                    isError = true;
                }
                if(String.isBlank(partnerFundRequestRecord.Core_MDF_Brand_nm__c) && !(recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NRE_RecordType'))){ partnerFundError=partnerFundError + System.Label.Core_MDF_BrandError +'<br>';
                    isError = true;
                }
                if(String.isBlank(partnerFundRequestRecord.Core_MDF_EcosystemPartner_nm__c) && partnerFundRequestRecord.Core_MDF_Is_Outcome_Based_Ind__c&& !(recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NRE_RecordType'))){partnerFundError=partnerFundError + System.Label.Core_MDF_Error_Message_for_Empty_Ecosystem_partner +'<br>';isError = true;
                }
               if(String.isBlank(partnerFundRequestRecord.Core_MDF_Technology_txt__c) && partnerFundRequestRecord.Core_MDF_Is_Outcome_Based_Ind__c&& !(recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NRE_RecordType'))){ partnerFundError=partnerFundError + System.Label.Core_MDF_Error_Message_for_Technology +'<br>';isError = true;
                }
               if(String.isBlank(partnerFundRequestRecord.Core_MDF_Outcomes_nm__c) && partnerFundRequestRecord.Core_MDF_Is_Outcome_Based_Ind__c&& !(recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NRE_RecordType'))){partnerFundError=partnerFundError + System.Label.Core_MDF_Error_Message_for_Outcomes +'<br>'; isError = true;
                }
            } if(String.isBlank(partnerFundRequestRecord.Core_MDF_Country_nm__c) && !(recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NRE_RecordType'))){ partnerFundError = partnerFundError + System.Label.Core_MDF_MarketError + '<br>';
            isError = true;
        }
        if(String.isBlank(partnerFundRequestRecord.Core_MDF_Priorities__c) && !(recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType')  || recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NRE_RecordType'))){partnerFundError=partnerFundError + System.Label.Core_MDF_Priority_Error + '<br>';          isError = true;
        }
            List<string> EVENT_ACTIVITY_TYPE = Core_MDF_CCP_ConstantClass.EVENT_ACTIVITY_TYPE != null ? Core_MDF_CCP_ConstantClass.EVENT_ACTIVITY_TYPE.split(',') : new List<string>(); if(EVENT_ACTIVITY_TYPE.contains(partnerFundRequestRecord.Core_MDF_Activity_Types__c)){
                Boolean byPassEventNameValidation = Core_MDF_GeneralPurpose_UI_Utility.isByPassFieldValidation(fieldToByPassFlagMap,'Core_MDF_Event_Name_nm__c');
                if(string.isBlank(partnerFundRequestRecord.Core_MDF_Event_Name_nm__c) && (!byPassEventNameValidation || partnerFundRequestRecord.id == null)){partnerFundError = partnerFundError + System.Label.Core_MDF_EventNameError +'<br>';isError = true;
                }
                Boolean byPassEventOtherValidation = Core_MDF_GeneralPurpose_UI_Utility.isByPassFieldValidation(fieldToByPassFlagMap,'Core_MDF_Other_Event_Name_txt__c');if(partnerFundRequestRecord.Core_MDF_Event_Name_nm__c == System.Label.Core_MDF_Other_Localized 
                   && string.isBlank(partnerFundRequestRecord.Core_MDF_Other_Event_Name_txt__c) && (!byPassEventOtherValidation || partnerFundRequestRecord.id == null)){
                    partnerFundError = partnerFundError + System.Label.Core_MDF_OtherEventNameError +'<br>';
                    isError = true;
                }   } if(String.isNotBlank(partnerFundRequestRecord.Core_MDF_Opportunity_id__c) && (recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType') ||recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_PFRRecordTypeDevName'))){ Boolean isInvalidID = false;
                String objName = '';
                //To check if Opportunity Id is valid Id or not
               try{  String oppId = partnerFundRequestRecord.Core_MDF_Opportunity_id__c;
                   if(oppId instanceOf Id){                       objName = Id.valueOf(oppId).getSObjectType().getDescribe().getName();
                   }
                   if(String.isBlank(objName) || objName != Core_MDF_CCP_ConstantClass.OPPORTUNITY_OBJECT_NAME){ isInvalidID = true;                   }               }catch(exception ex){                   isInvalidID = true;
               }
                if(isInvalidID){            partnerFundError=partnerFundError + System.Label.Core_MDF_OpportunityID_Error +'<br>';  // Error : Please enter a valid Opportunity Id.
                    isError = true;
                }
            }  List<String> L2_APPROVAL_STAGES=Core_MDF_CCP_ConstantClass.L2_APPROVAL_STAGES; List<Campaign> cmpList = [Select Core_MDF_Approval_Stage_nm__c, Status from Campaign Where Id= : partnerFundRequestRecord.CampaignId];
            for(Campaign cmp : cmpList){if(partnerFundRequestRecord.Core_MDF_Budget_Amount_Local_amt__c == 0 && recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType') && isPropBased && (cmp.Core_MDF_Approval_Stage_nm__c == 'L1 Approval' || L2_APPROVAL_STAGES.contains(cmp.Core_MDF_Approval_Stage_nm__c)))  {  partnerFundRequestRecord.Core_MDF_Fund_Request_Status__c ='Cancelled';  } if(recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType') && isPropBased && validatePfrModifyAccess(cmp, isCreation)) { partnerFundError = partnerFundError + System.Label.Core_MDF_IPA_Activity_Creation_Updation_Error + '<br>';  isError = true;
                }
            }  if( !opalBudgetTypeList.contains(partnerFundRequestRecord.Core_MDF_Budget_Type_nm__c)){ //industry partner
		//stamp the standard status as approved on saving the activity
			if(Label.Core_MDF_RetailProgram.contains(recType) || (Label.Core_MDF_IPA_RecordType.contains(recType) && !isPropBased)){
                List<String> budgetTypeReqAllocationValidationList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ActBudgtTypesForAllocationCheck').split(';');
                    if(budgetTypeReqAllocationValidationList.contains(partnerFundRequestRecord.Core_MDF_Budget_Type_nm__c)
                        || (Label.Core_MDF_IPA_RecordType.contains(recType) && !isPropBased)){
                    //PartnerFundAllocationDetails pfaDetails = new PartnerFundAllocationDetails();
                      if( partnerFundRequestRecord.AllocationId != null){                          partnerFundRequestRecord.Status = approvedStatus;
                     }
                    }

                } 
            }
            
            //Bu Split Multiselect Field validation for IPA
            List<String> buSupportedBudgetType = Label.Core_MDF_Bu_Supp_BudgetType.Split(';'); 
            // if((recType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType') || isPropBased) && buSupportedBudgetType.contains(partnerFundRequestRecord.Core_MDF_Budget_Type_nm__c)  && String.isBlank(partnerFundRequestRecord.Core_MDF_BU_Split__c)){ partnerFundError = partnerFundError + System.Label.Core_MDF_BU_Split_Error + '<br>'; isError = true;  
            //}
                List<String> spifActivityTypesList = Label.Core_MDF_SPIF_Activity_Types.Split(';');

        if (isIPAProposalBased) {

            if (partnerFundRequestRecord.Id == null) {partnerFundRequestRecord.Core_MDF_Budget_Currency_cd__c = 'USD';
} else {
    PartnerFundRequest storedPFR = [SELECT Core_MDF_Budget_Currency_cd__c FROM PartnerFundRequest WHERE Id = :partnerFundRequestRecord.Id LIMIT 1 ];
    Map<String, Object> suppliedFields = partnerFundRequestRecord.getPopulatedFieldsAsMap();
    Boolean budgetCurrencyChanged = suppliedFields.containsKey('Core_MDF_Budget_Currency_cd__c') &&  partnerFundRequestRecord.Core_MDF_Budget_Currency_cd__c != storedPFR.Core_MDF_Budget_Currency_cd__c;

    if (budgetCurrencyChanged && partnerFundRequestRecord.Core_MDF_Budget_Currency_cd__c != 'USD') {
        partnerFundError +=
            System.Label.Core_MDF_Currency_Error +
            '<br>';
        isError = true;
    }
}
        } // Indu IPA Proposal

        if(isError){
            AuraHandledException ex = new AuraHandledException(partnerFundError);
            ex.setMessage(partnerFundError);
            throw ex;
        }
        try{ 
            
            if(partnerFundRequestRecord.Core_MDF_Budget_Type_nm__c != null && partnerFundRequestRecord.BudgetId != null && ((Label.Core_MDF_CCFDCF_RecordType_API_Name.contains(recType) && 
                                                                                                                            (Label.Core_MDF_BudgetType_CMP.equals(partnerFundRequestRecord.Core_MDF_Budget_Type_nm__c) 
                                                                                                                            || Label.Core_MDF_BudgetType_SP_CMP.equals(partnerFundRequestRecord.Core_MDF_Budget_Type_nm__c))) 
                                                                                                                            
															    || (Label.Core_MDF_EEF_RecordType.contains(recType))
                                                                                                                            || (Label.Core_MDF_Retail_RSA_MD_Budget_Type.equals(partnerFundRequestRecord.Core_MDF_Budget_Type_nm__c)))){
                   PartnerFundAllocationDetails pfaDetails = new PartnerFundAllocationDetails();
                                                                                                                                 //Creation of zero dollar allocation
                   partnerFundRequestRecord.AllocationId = pfaDetails.getAllocationId(partnerFundRequestRecord.BudgetId,partnerFundRequestRecord.ChannelPartnerId);

                                                                                                                             }
            ////Customer Auto Approval for MDF and MDF+ - to check if acitvity is created by external user, if so mark the field true  
                if(userinfo.getUserType() == Label.Core_MDF_Partner_User_Type){
                   
                   		partnerFundRequestRecord.Core_MDF_Activity_CreatedByExternalUsr__c = true;
                  
                    partnerFundRequestRecord.Core_MDF_Is_Field_Modified__c =false;
                }
               
            //Customer Auto Approval for MDF and MDF+ - to check if acitvity is created by external user, if so mark the field true 
            if(partnerFundRequestRecord.Id == null){
	        //Capturing Activity Creation End Time
            	partnerFundRequestRecord.Core_MDF_EndTime_dtm__c = System.now();
                Core_MDF_PFR_Utility.insertPFR(partnerFundRequestRecord);
            }
            else{
                
                //Remove Approval Record lock before Update
                // New Budget Type field changes replaced txt field with new global picklist field
                if(Approval.isLocked(partnerFundRequestRecord.Id) && 
                   partnerFundRequestRecord.Core_MDF_Budget_Type_nm__c != Label.Core_MDF_BudgetType_MDF && !isPropBased &&
                   partnerFundRequestRecord.Core_MDF_Budget_Type_nm__c != Label.Core_MDF_BudgetType_MDFPlus &&
                   partnerFundRequestRecord.Core_MDF_Budget_Type_nm__c != Label.Core_MDF_BudgetType_CMP &&
                   partnerFundRequestRecord.Core_MDF_Budget_Type_nm__c != Label.Core_MDF_BudgetType_SP_CMP )
                    {
                        List<PartnerFundRequest> pfrlst = new List<PartnerFundRequest>();  
                        pfrlst.add(partnerFundRequestRecord); 
                        boolean apprlck = Core_MDF_ProcessCCP_PartnerFundRequest.RemoveApprovalLock(pfrlst);
                    }                                                 
                                   
                  Core_MDF_PFR_Utility.updatePFR(partnerFundRequestRecord);
                
            }
            if(cdocumentids != null ){
                List<ContentDocumentLink> conDocuLink = new List<ContentDocumentLink>();
                
                List<FeedItem> chatterfiles = new List<FeedItem>();
                for(ContentDocument docuLink : [SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE Id IN: cdocumentids]){
                    ContentDocumentLink odocLink = new ContentDocumentLink(ContentDocumentId = docuLink.Id,LinkedEntityId=partnerFundRequestRecord.Id,ShareType='I',Visibility='AllUsers');
                   
                    FeedItem chatterDetail = new FeedItem();
                    chatterDetail.ParentId = partnerFundRequestRecord.Id;
                    chatterDetail.RelatedRecordId = docuLink.LatestPublishedVersionId;
                    chatterDetail.Type = 'ContentPost';
                    chatterDetail.Visibility = 'AllUsers';
                    
                    chatterfiles.add(chatterDetail);
                    conDocuLink.add(odocLink);
                }
                insert(conDocuLink);
                 insert(chatterfiles);
                
            }
        if(String.isNotBlank(segmentAndProduct) && partnerFundRequestRecord.Id != NULL){
            Core_MDF_ActivitySegmentMapping.createUpdateSegmentAndProductMappingRecords(partnerFundRequestRecord.Id,segmentAndProduct);
        }
        //Outcome Based changes - Save tactics metrics and percentage value in Activity attributes objects
        if(tacticMetrics != null && partnerFundRequestRecord.Id != NULL){
            Core_MDF_Tactics_Controller.saveKpiData(tacticMetrics, partnerFundRequestRecord.Id, false);
        }
	    if(outcomeActivity != null && partnerFundRequestRecord.Id != NULL){
            Core_MDF_Activity_Purpose_Controller.saveActivityOutcome(partnerFundRequestRecord.Id,outcomeActivity);
        }
        //Akash, IPA outcome
        if(outcomeAccountNode != null && partnerFundRequestRecord.Id != NULL){
            Core_MDF_Outcome_Acc_Based_Activity.saveAccountAllocations(partnerFundRequestRecord.Id,outcomeAccountNode);
        }
        //Akash, Ecosystem
        if(ecosystemPartner != null && partnerFundRequestRecord.Id != NULL){
            Core_MDF_Ecosystem_Partner_Handler.saveEcosystemPartnerAllocations(partnerFundRequestRecord.Id,ecosystemPartner);
        }
              
        }catch(AuraHandledException e){
            String errMsg = e.getMessage();
            if(!(errMsg.contains(System.Label.Core_MDF_OpportunityID_Error))){
                Core_MDF_CCP_UtilityClass.logError(e);
            }
            
            throw e;
        }
              return partnerFundRequestRecord.Id;
       }
    /*@AuraEnabled
    public static void CampStatusUpdates(Id cmpId,String status){
        
        
                                   
        
        try{
            
            if(cmpId != NULL){
                
            
                if((status == 'Planned' || status == 'In Progress')){
                     Campaign cmpObj=new Campaign(); 
                    cmpObj.Id=cmpId;
                    cmpObj.Status='Revision Required';
                     
                     Database.update(cmpObj);
                }
            }
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
        
       
        
        
    }
    }*/
    
    /***************************************************************************************************** 
    Method Name : loadPFRRecord
    @return     : Object
    @parameters : PFR Record
    Description : US106541 - Create Activity initial screen
    Added By    : Accenture - AS
    Modified By :      Date:07/25/2018                    Changes:None        
    Ganapati            26/06/2020          US700986: [Tech] - [IPA] Hide Country/Region field in Activity form layout - Added Campaign.Core_MDF_Market__c field into the query                        
    ******************************************************************************************************/
    @AuraEnabled
    public static PartnerFundRequest loadPFRRecord(String pfrId){
        Set<String> sQueryfields = new Set<String>();
		 PartnerFundRequest pfrRecord = new PartnerFundRequest();
        try{
        String sanitiziedpfrId = String.escapeSingleQuotes(pfrId);
        String sQuery='SELECT ';
        for(Schema.FieldSetMember f : SObjectType.PartnerFundRequest.FieldSets.Core_MDF_Activity_FieldList.getFields()) {
            sQueryfields.add(f.getFieldPath());         
        }
        // Anjali changes - Explicitly add new Measurement Approach fields not yet in the field set
        sQueryfields.add('Core_MDF_Measurement_Approach_nm__c');
        sQueryfields.add('Core_MDF_Other_Measurement_Approach_txt__c');
        sQueryfields.add('Core_MDF_Maximum_Intel_Investment_amt__c');
        for(String fs : sQueryfields){
            sQuery += fs + ',';
        }
        //Added curency and budget amount field 
        //test code begins for Digital Media
       
        
            sQuery += 'Campaign.Name,Campaign.Core_MDF_Supports_legacy_program__c,Campaign.Core_MDF_Is_Opal__c, Campaign.Core_MDF_Priority__c,Campaign.Core_MDF_Opal_Budget_Type_Txt__c,Campaign.Core_MDF_Budget_Type_txt__c,Campaign.Core_MDF_Priority_2_nm__c,Campaign.Core_MDF_Priority_3_nm__c, '+' Campaign.Core_MDF_Reimbursement_Rate__c,Campaign.Core_MDF_ReimbursementRate_pct__c,Campaign.Core_MDF_Strategic_Marketing_Fund_Ind__c,Campaign.Core_MDF_Primary_Member_Acceptance_Ind__c,Campaign.Core_MDF_Account_Based_Ind__c,Campaign.Core_MDF_Proposal_Based_Ind__c,ChannelPartner.Name,RecordType.Name,RecordType.DeveloperName,Id, Campaign.Core_MDF_Product_Type__c,Campaign.Core_MDF_Audience__c,'+
            ' CreatedDate,Budget.Id,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Campaign.Core_MDF_Budget_Cap__c, Campaign.Core_MDF_Available_BudgetCap_amt__c, Campaign.Core_MDF_Reimbursement_Amount_Amt__c,'+
            ' ChannelPartner.Core_MDF_Channel_Program__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, '+
            ' Campaign.StartDate, Campaign.EndDate, Campaign.Core_MDF_Account__c, Campaign.Core_MDF_Account__r.Name, Campaign.Core_MDF_Campaign_Status__c, '+
            ' Campaign.Core_MDF_Channel_Program__c,Campaign.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Campaign.Core_MDF_Technology__c, Campaign.Status, Campaign.Core_MDF_Market__c, Campaign.Core_MDF_Brand__c,' +
            ' Campaign.Core_MDF_Approver_1_id__c, Campaign.Core_MDF_Approver_2_id__c, Campaign.Core_MDF_Approver_3_id__c, Campaign.Core_MDF_Approver_4_id__c, Campaign.Core_MDF_Approver_5_id__c, '+
            ' Campaign.Core_MDF_Approver_6_id__c, Campaign.Core_MDF_Approver_7_id__c, Campaign.Core_MDF_Approver_8_id__c, Campaign.Core_MDF_Approver_9_id__c, Campaign.Core_MDF_Approver_10_id__c, '+
            ' Campaign.Core_MDF_Focus_Area_nm__c,Campaign.Core_MDF_IPA_Priority_nm__c,Campaign.Core_MDF_Ecosystem_Partner_Nm__c,Campaign.Core_MDF_Industry_Nm__c,Campaign.Core_MDF_Initiative_nm__c, '+
                ' Campaign.Core_MDF_Claims_Created_Ind__c, Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c,Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__r.name,Core_MDF_Intel_Activity_Owner_Id__c, '+
                ' Core_MDF_Intel_Activity_Owner_Id__r.Name,Core_MDF_Member_Acceptor_Id__r.Name,Core_MDF_Program_Office_Check_ind__c, Campaign.Core_MDF_Program__c,Core_MDF_Member_Owner_txt__c,Core_MDF_CreatedBy__c,Core_MDF_Activity_Reimbursement_Amt_nbr__c, '+
                ' Core_MDF_Approval_Stage__c,Core_MDF_Host_Region_or_Region_txt__c,Core_MDF_Activity_Number__c,Core_MDF_ATF_Flag_nm__c,tolabel(Campaign.Core_MDF_Opal_Budget_Type_Txt__c) localizedBudType, Campaign.Core_MDF_Approval_Stage_nm__c,'+
                ' Campaign.Core_MDF_Channel_Program__r.Name,Core_MDF_NEX_Ind__c,Core_MDF_CSP_Intel_Based_Revenue_amt__c,Core_MDF_Primary_Intel_Owner_Id__c,Core_MDF_Primary_Intel_Owner_Id__r.Name,Core_MDF_End_Customer_txt__c, Campaign.Core_MDF_Activity_Category_Type__c, Campaign.Core_MDF_Activity_Category__c, Campaign.Core_MDF_CampOutcomeOpt_In_Ind__c '+
                ' FROM PartnerFundRequest WHERE Id =:sanitiziedpfrId';
        //test code ends for Digital Media
         pfrRecord = Database.query(sQuery);
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
        return pfrRecord;
    }
    /***************************************************************************************************** 
    Method Name : fetchMetadataMapping
    @return     : Custom Metadata
    @parameters : NA
    Description : Created for fetching Metadata Mapping and sending it to client-side controller
    Added By    : Accenture - AS
    Modified By :                      Date:07/25/2018                    Changes:None                                
    ******************************************************************************************************/
    @AuraEnabled
    public static List<Core_MDF_CCP_Custom_Metadata_Utility__c> fetchMetadataMapping(){
        String query = 'SELECT ' + 'Core_MDF_Number_1_num__c, ' + 'Core_MDF_Field_7_txt__c, ' + 'Core_MDF_Checkbox_Field_2_Ind__c, ' + 'Core_MDF_Checkbox_Field_4_Ind__c, ' +'Core_MDF_Field_1_txt__c, ' +'Core_MDF_Checkbox_Field_3_Ind__c, ' +'Core_MDF_Checkbox_Field_5_Ind__c, ' +'Core_MDF_Checkbox_Field_6_Ind__c, ' +'Core_MDF_Checkbox_Field_7_Ind__c, ' + 'Core_MDF_Checkbox_Field_8_Ind__c, ' +'Core_MDF_Checkbox_Field_9_Ind__c, ' + 'Core_MDF_Checkbox_Field_1_Ind__c, ' + 'Core_MDF_Field_8_txt__c, ' + 'Core_MDF_Field_4_txt__c, ' +'Core_MDF_Sub_Category__c, ' + 'Core_MDF_Field_9_txt__c, ' +'Core_MDF_Checkbox_Field_10_Ind__c ' +'FROM Core_MDF_CCP_Custom_Metadata_Utility__c ' +'WHERE Core_MDF_Category__c = \'' + String.escapeSingleQuotes(Core_MDF_CCP_ConstantClass.ATTRIBUTES_MAP_CATEGORY) + '\' '  +
            'AND Core_MDF_Is_Active_Ind__c = TRUE';List<Core_MDF_CCP_Custom_Metadata_Utility__c> customMetadataUtilityRecords = Core_MDF_Custom_Metadata_Utility.getCustomObjectRecordsUsingDynamicQuery(query);
        /*return [SELECT Id,DeveloperName,MasterLabel,Budget_Amount__c,Category__c,Core_MDF_Enable_Channel_Partner_Led__c,Core_MDF_Enable_Event_Format_Ind__c, Core_MDF_POP_Requirements_txt__c,
                Core_MDF_Enable_ELC_Reminder__c,Enable_Event_Popup__c,Core_MDF_Enable_File_Upload__c,Core_MDF_Enable_Question__c,RecordType_Name__c,Type__c,Govt_Nexus_Flag__c,
                Print__c,Channel_Partner__c,Record_Type_Picklist__c,Core_MDF_Activity_Description_Txt__c,Activity_Sub_Type__c,Core_MDF_Segment_Ind__c FROM CCP_Attributes_Map__mdt];*/

        return customMetadataUtilityRecords;
    }
 @AuraEnabled public static UserDetailsWrapper fetchActivityOwner(){ UserDetailsWrapper userDetail = new UserDetailsWrapper();   userDetail.userName = userinfo.getName();
        userDetail.userId = userinfo.getuserid();
       
        return userDetail; } public class UserDetailsWrapper{ @AuraEnabled public String userName {get;set;}  @AuraEnabled public Id userId {get;set;}
        
    }  @AuraEnabled public static String fetchAccPropCampaign(Campaign camp){ String campType = '';
       try{ if(camp !=null ){       List<Campaign> campList = [Select Id, Core_MDF_Proposal_Based_Ind__c,Core_MDF_Program__c from Campaign where id =: camp.Id LIMIT 1];            if((/*campList[0].Core_MDF_Program__c == 'Channel MDF' ||*/campList!= null && !campList.isEmpty() && campList[0].Core_MDF_Program__c == 'Intel Partner Alliance') && campList[0].Core_MDF_Proposal_Based_Ind__c){ campType = 'Proposal Based';  }    }   }  catch(Exception e){  Core_MDF_CCP_UtilityClass.logError(e);throw new AuraHandledException(e.getMessage());
        } return campType;    }   @AuraEnabled  public static List<Core_MDF_Campaign_Budgets__c> fetchCampBudgetInfo(Id campRecordId, Date startDate, Date endDate, String budgetType){
    //public static List<Core_MDF_Campaign_Budgets__c> fetchCampBudgetInfo(Id campRecordId, Date startDate, Date endDate){
    List<Core_MDF_Campaign_Budgets__c> cmpgnBudgetlst = new List<Core_MDF_Campaign_Budgets__c>(); try{if(campRecordId != null){ CampaignBudgets campBudget = new CampaignBudgets();   cmpgnBudgetlst = campBudget.getCampaignBudgets(campRecordId,startDate,endDate,budgetType); } }catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e);  throw new AuraHandledException(e.getMessage());
        }return cmpgnBudgetlst;  } 
@AuraEnabled
    public static List<PartnerMarketingBudget> fetchBudgetInfo(Id accountId, Date startDate, Date endDate, String budgetType,Boolean isIPAAccBased, Id currentBudgetId)
    {
        List<PartnerMarketingBudget> budgetList = new List<PartnerMarketingBudget>();
        String releasedStatus  = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Status_Released');

        Date pfrStartOrEndDate =(isIPAAccBased)?startDate:endDate;
        try{
            if(accountId!=null)
            {
                // Modified by Shravani for story : TWC702-14748:
                // Include budgets that were previously in Released status using history tracking
                Set<Id> releasedBudgetIds = new Set<Id>();

                for (PartnerMarketingBudgetHistory budgetHistory : [
                    SELECT PartnerMarketingBudgetId, NewValue
                    FROM PartnerMarketingBudgetHistory
                    WHERE Field = 'Core_MDF_Budget_Status__c'
                    AND PartnerMarketingBudget.Core_MDF_Ultimate_Account_Id__c = :accountId
                    AND PartnerMarketingBudget.Core_MDF_Budget_Type__c = :budgetType
                    AND PartnerMarketingBudget.StartDate <= :startDate
                    AND PartnerMarketingBudget.EndDate >= :pfrStartOrEndDate
                ]) {
                    if (budgetHistory.NewValue != null &&
                        String.valueOf(budgetHistory.NewValue) == releasedStatus) {

                        releasedBudgetIds.add(budgetHistory.PartnerMarketingBudgetId);
                    }
                }

                //Fetching eligible budgets for activity based on date range, account and budget type              
                budgetList = [SELECT Id,Core_MDF_Budget_Partner__c,
                             Core_MDF_Ultimate_Account_Id__c,Title,
                             Core_MDF_budget_ref_nbr__c,StartDate,EndDate,
                             Core_MDF_Budget_Type_Txt__c
                             from PartnerMarketingBudget
                             where Core_MDF_Ultimate_Account_Id__c =:accountId
                             and Core_MDF_Budget_Type__c =:budgetType
                             and StartDate <= :startDate
                             and EndDate >= :pfrStartOrEndDate
                             and (Core_MDF_Budget_Status__c =:releasedStatus OR Id = :currentBudgetId OR Id IN :releasedBudgetIds)]; //Include previously Released budgets
                             // Modified by: Shravani,  story: TWC702-14748  
            }
        
        }catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
        return budgetList;
    }		
		
    /***************************************************************************************************** 
    Method Name : fetchAllocation
    @return     : Allocation Id
    @parameters : Budget Id
    Description : Fetches Allocation ID
    Added By     : Nuzhath Zaiba
    Modified By :                      Date:02/19/2020                  Changes:None                                
    *****************************************************************************************************
    @AuraEnabled
    public static Id fetchAllocation(Id budgetId,Id activityAccountId){
        Id allocationId = null;
        Id allocatId = null;
        String budgetName = '';
        Boolean allocationWithCP = false;
        for(PartnerFundAllocation pfa : [SELECT Id,BudgetId,Budget.Title,ChannelPartnerId
                                        FROM PartnerFundAllocation 
                                        WHERE BudgetId = :budgetId]){
             
             budgetName = pfa.Budget.Title;
             if(pfa.ChannelPartnerId == activityAccountId){
                                                 
                 allocationWithCP = true;
                 allocatId = pfa.Id; 
             }
        }
        if(allocationWithCP){
           allocationId = allocatId;
        }else{
            PartnerMarketingBudget pmb = [SELECT Id, Title,Core_MDF_Program__r.Core_MDF_Technical_Program_Name__c FROM PartnerMarketingBudget WHERE Id =: budgetId];
            if(pmb != NULL){
                PartnerFundAllocation partnerFndAllocation = new PartnerFundAllocation(Title = pmb.Title,
                                                                                       BudgetId = budgetId,
                                                                                       ChannelPartnerId = activityAccountId,
                                                                                       Amount = 0);       
                insert partnerFndAllocation;
                allocationId = partnerFndAllocation.Id;
            }
            
        }
        return allocationId;
    }
    */
    /***************************************************************************************************** 
    Method Name : calculateIncentiveForActivity
    @return     : Custom Metadata
    @parameters : NA
    Description : Created for fetching Incentive Questions
    Added By    : Vivek K
    Modified By :                      Date:03/20/2020                    Changes:None                                
    ******************************************************************************************************/
    @AuraEnabled
    public static Core_MDF_ChannelProgram__mdt fetchVRMetadataMapping(string channelProgram){
        try{
            return [SELECT Id,Core_MDF_Technical_Program_Name__c,Core_MDF_InctQuest_Label_Ref__c FROM Core_MDF_ChannelProgram__mdt where Core_MDF_Technical_Program_Name__c =:channelProgram];
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); throw new AuraHandledException(e.getMessage());
        }
    }  @AuraEnabled public static List<String> fetchFieldSets(){ List<String> fieldSetList = new List<String>();
        for(Schema.FieldSetMember fields :Schema.SObjectType.PartnerFundRequest.fieldSets.getMap().get('Core_MDF_Activity_FieldList').getFields()){
            fieldSetList.add(fields.getFieldPath());
        }
        return fieldSetList;  }    @AuraEnabled public static Core_MDF_VRQuestionsWrapper.vrQuestionWrap calculateIncentiveForActivity(PartnerFundRequest pfr,Id channelProgramId,String camptechnology){Map<PartnerFundRequest, Id> pfrCPIdMap = new Map<PartnerFundRequest, Id>();Core_MDF_VRQuestionsWrapper.vrQuestionWrap holdVRData = new Core_MDF_VRQuestionsWrapper.vrQuestionWrap();pfrCPIdMap.put(pfr, channelProgramId);holdVRData = Core_MDF_PFR_Reimbursement_Handler.calculateVariableReimbursement(pfrCPIdMap,camptechnology);return holdVRData;} @AuraEnabled public static Boolean ischannelpartner(String activityCategory, String activityType, String recordType){ List<Core_MDF_CCP_Custom_Metadata_Utility__c> metaData = fetchMetadataMapping();Boolean isCP = false;for(Core_MDF_CCP_Custom_Metadata_Utility__c metData : metaData){if(activityCategory != null && activityCategory!='' && activityType!=null && activityType!='' && recordType!=null && recordType!='' && metData.Core_MDF_Field_7_txt__c!= null){if(activityCategory.equalsIgnoreCase(metData.Core_MDF_Field_7_txt__c.trim()) && activityType.equalsIgnoreCase(metData.Core_MDF_Field_9_txt__c.trim()) && metData.Core_MDF_Checkbox_Field_1_Ind__c == true && recordType.equalsIgnoreCase(metData.Core_MDF_Field_4_txt__c)){                   isCP = true;                   break;
               }
        } } return isCP;} @AuraEnabled public static Map<String,Object> mainPicklistFetcher(String recordTypeName){ String rec = recordTypeName; Map<String,Object> returnMap = new Map<String,Object>();try{returnMap = Core_Intel_customPicklistController.picklistFetcher(rec); }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw new AuraHandledException(e.getMessage());
        }
        return returnMap; }
 @AuraEnabled public static Map<String,Object> customPicklistFetcher(String recordTypeName){ String rec = recordTypeName;
        Map<String,Object> returnMap = new Map<String,Object>();
        try{
            returnMap = Core_Intel_customPicklistController.customPicklistFetcher(rec);
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());   }        return returnMap;
        
    }
    /***************************************************************************************************** 
    Method Name : ExternalOrInternal
    @return     : boolean
    @parameters : None
    Description : US149042 - Cancel Activity - status
    Added By    : Accenture - ashar
    Modified By :                      Date:08/31/2018                    Changes:None                                
    ******************************************************************************************************/
    /*@AuraEnabled
    public static boolean ExternalOrInternal(){
    Id profileId = UserInfo.getProfileId();
    List<Profile> profileName = [Select Name from Profile where Id =: profileId];
    if(profileName[0].Name == System.Label.Core_MDF_ExternalUserProfileName)
    return true;
    return false;   
    }*/
    
    /******************************************************************
     * *********************************** 
    Method Name : UserHasPermissionSet
    @return     : boolean
    @parameters : perset
    Description : Validate whether the user has the permission associated or not
    Added By    : Sridhar
    Modified By :                      Date:09/01/2018                    Changes:None                                
     Bharath                           Date:26/10/2020                    US789098 - Checking for Custom Permissions rather than Permission set assignment
    ******************************************************************************************************/
    @AuraEnabled
    public static UserPermissionSetWrapper userHasPermissionSet(Map<String,List<String>> permissionsets){
        UserPermissionSetWrapper usrprmissionWrapper = new UserPermissionSetWrapper();
        try{
       
        Map<String,boolean> userPermissions = new Map<String,boolean>();List<PermissionSetAssignment> userPerSets = new List<PermissionSetAssignment>();
        
        for(String perKey : permissionsets.keySet())
        {
            for(String customPermissionStr : permissionsets.get(perKey))
            {
                
                if(isCustomPermissionAssigned(customPermissionStr) && !userPermissions.containsKey(perKey)){                 userPermissions.put(perKey,true);
                }
            } if (!userPermissions.containsKey(perKey))
            {
                userPermissions.put(perKey,false); }     }if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_isActivityReviewRequired') &&            mapFunctionalityNameTriggerExecution.get('Core_MDF_isActivityReviewRequired').Core_Active__c){ usrprmissionWrapper.isActivityReviewRequired = true; }usrprmissionWrapper.userPermissions = userPermissions;
        
        }catch(Exception ex){ Core_MDF_CCP_UtilityClass.logError(ex);
            throw new AuraHandledException(ex.getMessage());
        }
         return usrprmissionWrapper; 
    }
    public class UserPermissionSetWrapper{ @AuraEnabled  public Map<String,boolean> userPermissions; @AuraEnabled public Boolean isActivityReviewRequired;
    }

    /***************************************************************************************************** 
    Method Name :   getLabelApiMapforPicklistfields
    Added By   :    Accenture - AS 
    Description :   Get the all the values of all the picklist field on the load of the page.
    Modified By:                      Date:10/15/2018                     Changes:None  
    ******************************************************************************************************/
    
    @AuraEnabled
    public static Map<String, String> getLabelApiMapforPicklistfields (String objName, List <String> pfrPiclistField){
        String objectname = objName;
        List <String> picklistfields = pfrPiclistField;Map<String, String> returnMap = new Map<String, String>();try{
            returnMap = Core_Intel_customPicklistController.apitoLabelReference(objectname , pfrPiclistField);
        }
        catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
        return returnMap;     }     @AuraEnabled     public static PartnerFundRequest recalculatebudgetAmountOnPFR (PartnerFundRequest newPFR, PartnerFundRequest oldPFR){ PartnerFundRequest returnPFR = new PartnerFundRequest();        Date todayDate = date.newInstance(System.today().year(), System.today().month(), System.today().day());  Date pfrcreatedDate = date.newInstance(newPFR.createdDate.year(), newPFR.createdDate.month(), newPFR.createdDate.day());Integer numberDaysDue = pfrcreatedDate.daysBetween(todayDate);Integer activityDateChangeRange = Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Budget_Dt_Change_Range')) == NULL  ? 180 : Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Budget_Dt_Change_Range')) ; try{if(numberDaysDue <= activityDateChangeRange){ if(newPFR.Core_MDF_Budget_Currency_cd__c != NULL && oldPFR.Core_MDF_Budget_Currency_cd__c != NULL  && newPFR.Core_MDF_Budget_Currency_cd__c != oldPFR.Core_MDF_Budget_Currency_cd__c && newPFR.Core_MDF_Budget_Currency_cd__c != 'USD' ){ PartnerFundRequest newPFRExchange = calculateExchangeRateAndAmount(newPFR);returnPFR.RequestedAmount = newPFRExchange.RequestedAmount; returnPFR.Core_MDF_Exchange_Rate_ptc__c = newPFRExchange.Core_MDF_Exchange_Rate_ptc__c; }else{ if(newPFR.Core_MDF_Budget_Currency_cd__c != 'USD'){if(oldPFR.Core_MDF_Exchange_Rate_ptc__c != NULL && newPFR.Core_MDF_Budget_Amount_Local_amt__c!=NULL){returnPFR.RequestedAmount = (newPFR.Core_MDF_Budget_Amount_Local_amt__c * oldPFR.Core_MDF_Exchange_Rate_ptc__c).setScale(2,RoundingMode.HALF_UP); returnPFR.Core_MDF_Exchange_Rate_ptc__c = oldPFR.Core_MDF_Exchange_Rate_ptc__c;  }else{ PartnerFundRequest newPFRExchange = calculateExchangeRateAndAmount(newPFR);returnPFR.RequestedAmount = newPFRExchange.RequestedAmount; returnPFR.Core_MDF_Exchange_Rate_ptc__c = newPFRExchange.Core_MDF_Exchange_Rate_ptc__c;}}else{ returnPFR.RequestedAmount = newPFR.Core_MDF_Budget_Amount_Local_amt__c;returnPFR.Core_MDF_Exchange_Rate_ptc__c = 1; }   }  }else{ returnPFR.RequestedAmount = null;returnPFR.Core_MDF_Exchange_Rate_ptc__c = null;  } returnPFR.Core_MDF_Budget_Currency_cd__c = newPFR.Core_MDF_Budget_Currency_cd__c; } catch(Exception e){  Core_MDF_CCP_UtilityClass.logError(e); throw new AuraHandledException(e.getMessage());
        }     return returnPFR;
    }
    /****************************************************************************************************** 
    Method Name:        calculateExchangeRateAndAmount
    @return  :          PartnerFundRequest
    @parameters:        PartnerFundRequest 
    Description:        To Calculate the Exchange Rate and Converted Amount if its null
    Added By:           Accenture - SS  - 04/28/2020
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    @AuraEnabled    public static PartnerFundRequest calculateExchangeRateAndAmount (PartnerFundRequest pfr){PartnerFundRequest returnPFR = new PartnerFundRequest();ExchangeRateConvertedAmountWrapper exchangeRateAndConvertedAmtWrap  = budgetAmountCalculatePFR(pfr,false); if(exchangeRateAndConvertedAmtWrap != NULL && exchangeRateAndConvertedAmtWrap.exchangeRate != NULL && exchangeRateAndConvertedAmtWrap.usdBudgetAmount != NULL){returnPFR.RequestedAmount = exchangeRateAndConvertedAmtWrap.usdBudgetAmount;returnPFR.Core_MDF_Exchange_Rate_ptc__c = exchangeRateAndConvertedAmtWrap.exchangeRate; returnPFR.Core_MDF_Budget_Currency_cd__c = pfr.Core_MDF_Budget_Currency_cd__c; }else{ returnPFR.RequestedAmount = null;returnPFR.Core_MDF_Exchange_Rate_ptc__c = null;returnPFR.Core_MDF_Budget_Currency_cd__c = null;
        }        return returnPFR;
    }
     /****************************************************************************************************** 
Method Name:        getUltimateAccountIds
@return       :     List Of Ultimate Account IDs
@parameters   :     Campaign Id
Description:        ultimateAccList will be used to get accounts associated to these ultimate Accounts (EEF)
Added By:           Shwetali  - 20/03/2024

*******************************************************************************************************/   
    @AuraEnabled
    public static List<id> getUltimateAccountIds(Id campId)
    {
       Id campaignId = campId;List<Id> ultimateAccList =  new List<Id>(); 
       if(campaignId != null){for(Core_MDF_Camp_to_ActPartner__c campMapRec : [SELECT Core_MDF_Activating_Partner_Account_id__r.Core_MDF_CoMarketing_Ultimate_Account__c ,Core_MDF_Active_Ind__c

                              FROM Core_MDF_Camp_to_ActPartner__c WHERE Core_MDF_Campaign_Id__c =:campaignId AND Core_MDF_Active_Ind__c = true ]){                              ultimateAccList.add(campMapRec.Core_MDF_Activating_Partner_Account_id__r.Core_MDF_CoMarketing_Ultimate_Account__c); 
                              }
        }  return ultimateAccList;    } 
/****************************************************************************************************** 
Method Name:        getHierarchyAccountIds
@return       :     List Of Account IDs within the hierarchy
@parameters   :     Campaign Id
Description:        hierarchyAccList will be used to get accounts associated to the same hierarchy
                        as the account on the campaign (CCF/DCF)
Added By:           Gayathri
*******************************************************************************************************/
    @AuraEnabled
    public static List<Id> getHierarchyAccountIds(Id campId) {
        
        List<Id> hierarchyAccList = new List<Id>();
        
        if(campId == null) {
            return hierarchyAccList;
        }
        
        //Get the Campaign's Account and its Ultimate Parent
        List<Campaign> campList = [
            SELECT Id, 
                   Core_MDF_Account__c,
                   Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c
            FROM Campaign
            WHERE Id = :campId
            LIMIT 1
        ];
        
        if(campList.isEmpty() || campList[0].Core_MDF_Account__c == null) {
            return hierarchyAccList;
        }
        
        Campaign camp = campList[0];
        Id campaignAccountId = camp.Core_MDF_Account__c;
        Id ultimateParentId = camp.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c;
        
        //Use Ultimate Parent if available, else Campaign Account as root
        Id hierarchyRootId = (ultimateParentId != null) ? ultimateParentId : campaignAccountId;
        
        //Get all accounts in the same hierarchy
        for(Account acc : [
            SELECT Id
            FROM Account
            WHERE Core_MDF_Active_Ind__c = true
            AND Core_MDF_CoMarketing_Ultimate_Account__c = :hierarchyRootId
        ]) {
            hierarchyAccList.add(acc.Id);
        }
        
        return hierarchyAccList;
    } 
	
    public class ExchangeRateConvertedAmountWrapper{  @AuraEnabled  public Decimal usdBudgetAmount = 0 ; @AuraEnabled  public Decimal exchangeRate = 0 ;@AuraEnabled public Id pfrId; }    @AuraEnabled      public static ExchangeRateConvertedAmountWrapper budgetAmountCalculatePFR(PartnerFundRequest pfr, Boolean createdDateCloneFlag){ Set<ExchangeRateConvertedAmountWrapper> convertedAmountAndExchangeRateSet = new Set<ExchangeRateConvertedAmountWrapper>();List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();ExchangeRateConvertedAmountWrapper exchngeRateWrapperInstn = new ExchangeRateConvertedAmountWrapper();if(pfr.Core_MDF_Budget_Currency_cd__c != NULL && pfr.Core_MDF_Budget_Amount_Local_amt__c >0){pfrList.add(pfr); }if(!pfrList.isEmpty()){Boolean budgetflag = TRUE;convertedAmountAndExchangeRateSet = getExchangeRateConvertedAmountWrapperList(pfrList,budgetflag,createdDateCloneFlag);if(convertedAmountAndExchangeRateSet != NULL && convertedAmountAndExchangeRateSet.size() > 0){exchngeRateWrapperInstn = (new list<ExchangeRateConvertedAmountWrapper>(convertedAmountAndExchangeRateSet))[0]; } else{ exchngeRateWrapperInstn = NULL;  }   } return exchngeRateWrapperInstn;
    }
    /****************************************************************************************************** 
    Method Name:        getExchangeRateConvertedAmountWrapperList
    @return  :          ExchangeRateConvertedAmountWrapper
    @parameters:        PFR list
    Description:        This method is used to calulate Budget Amount from Local Currency to USD[Bulkified]
    Added By:           SB
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/ 

    public static Set<ExchangeRateConvertedAmountWrapper> getExchangeRateConvertedAmountWrapperList(List<PartnerFundRequest> pfrList, Boolean budgetflag, Boolean createdDateCloneFlag){
        
     String partnerFundErrorBudgetUSD = System.Label.Core_MDF_Budget_Amount_Error +'<br/>'; String partnerFundErrorCurrency = System.Label.Core_MDF_Currency_Error +'<br/>';
        
       Map<String,Set<Id>> budgetAmountCurrencyDateStrPFRIdSetMap = new Map<String,Set<Id>>();Set<ExchangeRateConvertedAmountWrapper> convertedAmountAndExchangeRateSet = new Set<ExchangeRateConvertedAmountWrapper>();
        
 List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> inputList = new List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>(); String keyValue;
        try{            
            for(PartnerFundRequest pfr : pfrList){if(pfr.Core_MDF_Budget_Amount_Local_amt__c != NULL && pfr.Core_MDF_Budget_Currency_cd__c != NULL){Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount input = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount(); input.inputCurrency = pfr.Core_MDF_Budget_Currency_cd__c; input.inputAmount = pfr.Core_MDF_Budget_Amount_Local_amt__c; if(createdDateCloneFlag){ input.inputDate = System.today() ; keyValue = pfr.Core_MDF_Budget_Amount_Local_amt__c + '\t' + pfr.Core_MDF_Budget_Currency_cd__c + '\t' +  string.valueof(System.today() );}else{input.inputDate = pfr.createdDate == NULL  ? System.today() : pfr.createdDate.Date() ;keyValue = pfr.Core_MDF_Budget_Amount_Local_amt__c + '\t' + pfr.Core_MDF_Budget_Currency_cd__c + '\t' + string.valueof(pfr.createdDate == NULL  ? System.today() : pfr.createdDate.Date()); } inputList.add(input); if(budgetAmountCurrencyDateStrPFRIdSetMap.containsKey(keyValue)){Set<Id> pfrIdSet = new Set<Id>();pfrIdSet = budgetAmountCurrencyDateStrPFRIdSetMap.get(keyValue);pfrIdSet.add(pfr.Id);budgetAmountCurrencyDateStrPFRIdSetMap.put(keyValue, pfrIdSet); } else{ Set<Id> pfrIdSet = new Set<Id>(); pfrIdSet.add(pfr.Id);budgetAmountCurrencyDateStrPFRIdSetMap.put(keyValue, pfrIdSet); } }else{AuraHandledException ex = new AuraHandledException(partnerFundErrorBudgetUSD); ex.setMessage(partnerFundErrorBudgetUSD);throw ex;
                }
            }
            //Call to Core_MDF_CCP_Multicurrency method
            Map<String,Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> usdAmountMap = Core_MDF_CCP_Multicurrency.getUSDExchangeRateBasedOnDate(inputList);
           
            //Check if usdAmountMap && budgetAmountCurrencyDateStrPFRIdSetMap has data ,
            if(budgetflag == true && usdAmountMap != NULL && usdAmountMap.size()>0){ExchangeRateConvertedAmountWrapper ercaw = new ExchangeRateConvertedAmountWrapper(); if(usdAmountMap.containsKey(keyValue) && usdAmountMap.size() > 0 && usdAmountMap.get(keyValue).conversionRate != NULL)  { ercaw.usdBudgetAmount = usdAmountMap.get(keyValue).convertedAmount.setScale(2,RoundingMode.HALF_UP); ercaw.exchangeRate= usdAmountMap.get(keyValue).conversionRate;convertedAmountAndExchangeRateSet.add(ercaw);}else{ AuraHandledException ex = new AuraHandledException(partnerFundErrorCurrency);ex.setMessage(partnerFundErrorCurrency);    throw ex;
                }
            }else if(budgetAmountCurrencyDateStrPFRIdSetMap.size()>0 && usdAmountMap != NULL && usdAmountMap.size()>0){for(String key : usdAmountMap.keySet()){if(usdAmountMap.containsKey(key) && usdAmountMap.get(key).conversionRate != NULL ){for(Id activityId : budgetAmountCurrencyDateStrPFRIdSetMap.get(key)){ExchangeRateConvertedAmountWrapper ercaw = new ExchangeRateConvertedAmountWrapper();ercaw.usdBudgetAmount = usdAmountMap.get(key).convertedAmount.setScale(2,RoundingMode.HALF_UP);ercaw.exchangeRate = usdAmountMap.get(Key).conversionRate;ercaw.pfrId = activityId; convertedAmountAndExchangeRateSet.add(ercaw);  } } else{AuraHandledException ex = new AuraHandledException(partnerFundErrorCurrency);   ex.setMessage(partnerFundErrorCurrency);     throw ex;
                    }
               } }  }catch (Exception e) {  Core_MDF_CCP_UtilityClass.logError(e);  throw e;  } return convertedAmountAndExchangeRateSet; }    @AuraEnabled     public static Boolean validateIfInApprvlQue(String pfrId){ Boolean apprvalQueueFlag = false; try{List<ProcessInstanceWorkItem> piwitm = [SELECT ProcessInstance.TargetObjectId, Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.Status = :'Pending' AND ProcessInstance.TargetObjectId = :pfrId LIMIT 1];if(piwitm != NULL &&  !piwitm.isEmpty()) { apprvalQueueFlag = true;   }     }catch(Exception e) {      Core_MDF_CCP_UtilityClass.logError(e);  throw e;            } return apprvalQueueFlag;   }    @AuraEnabled public static Boolean isRecordApprove(String accId, String program, List<String> country, String approvalStage, String userId){ Boolean returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(accId,program,country,approvalStage,userId); return returnValue;}  @AuraEnabled  public static Boolean checkCurrentUserIsApprover( PartnerFundRequest obj , String userId) { Boolean returnValue ;returnValue = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(obj,userId); return returnValue;
    }   @AuraEnabled public static List<Core_MDF_CCP_Custom_Metadata_Utility__c> fetchOpalMetadataMapping(String queryFilterStr){ List<Core_MDF_CCP_Custom_Metadata_Utility__c> metadataList;
        String sanitizedqueryFilterStr = String.escapeSingleQuotes(queryFilterStr);
        sanitizedqueryFilterStr = sanitizedqueryFilterStr.replaceAll('\\\\','');
        try{
            
            String query = 'SELECT Core_MDF_Field_1_txt__c, ' +'Core_MDF_Field_2_txt__c, ' +'Core_MDF_Checkbox_Field_1_Ind__c, ' +'Core_MDF_Is_Active_Ind__c ' +'FROM Core_MDF_CCP_Custom_Metadata_Utility__c ' +'WHERE Core_MDF_Category__c = \'' + String.escapeSingleQuotes(Core_MDF_CCP_ConstantClass.OPAL_CATEGORY) + '\' ' +'AND Core_MDF_Is_Active_Ind__c = TRUE';if(String.isNotBlank(sanitizedqueryFilterStr)) {query+=sanitizedqueryFilterStr;
            } metadataList = Core_MDF_Custom_Metadata_Utility.getCustomObjectRecordsUsingDynamicQuery(query);        }catch(Exception e) {      Core_MDF_CCP_UtilityClass.logError(e); }  return metadataList;
    }    public static Boolean isCustomPermissionAssigned(String customPermissionNameStr){
       
        return String.isNotBlank(customPermissionNameStr) ? FeatureManagement.checkPermission(customPermissionNameStr) : false;  }  @AuraEnabled public static List<String> fetchIndPartnerCtryPgmMapping(String country,String prgName){List<String> returnIPCtryMetaData = new List<String>();
        try{
            returnIPCtryMetaData = Core_Intel_customPicklistController.fetchIndPartnerCtryPgmMapping(country,prgName);        } catch(Exception e){            Core_MDF_CCP_UtilityClass.logError(e); throw new AuraHandledException(e.getMessage());
        }
        return returnIPCtryMetaData;
    } 
    /***************************************************************************************************** 
Method Name : fetchMetadataMappingSplitSection
@return     : Custom Metadata
@parameters : NA
Description : Created for fetching Metadata Mapping and sending it to client-side controller
Added By    : Accenture - AS
Modified By :                      Date:07/25/2018                    Changes:None                                
******************************************************************************************************/
//the below method needs to be commented as part of the metadata clean up and the method is not being called from any components.
   /*@AuraEnabled
    public static List<Core_MDF_CCP_Custom_Metadata_Utility__c> fetchMetadataMappingSplitSection(String prgName, String budgetType){
        
        List<Core_MDF_BU_Splits__mdt> returnValueList = new List<Core_MDF_BU_Splits__mdt>();
        try{
            String whereClause = 'Core_MDF_Program__c = \'' + String.escapeSingleQuotes(prgName) + '\' ' +
            'AND Core_MDF_Category__c = \'' + String.escapeSingleQuotes(Core_MDF_CCP_ConstantClass.BU_SPLIT) + '\' ' +
            'AND Core_MDF_Is_Active_Ind__c = TRUE ' +
            'AND Core_MDF_Field_7_txt__c = \'' + String.escapeSingleQuotes(budgetType) + '\'';

            
            returnValueList = [select Id,Core_MDF_Budget_Type__c,Core_MDF_Proposal_Based_Ind__c,Core_MDF_BU_Name__c,Core_MDF_Default_BU__c, Core_MDF_IsActive__c, Core_MDF_Program__c, Core_MDF_Split_Percent__c,Core_MDF_Field_Name__c from Core_MDF_BU_Splits__mdt
                               where Core_MDF_Program__c  = :prgName and Core_MDF_Budget_Type__c =:budgetType and Core_MDF_IsActive__c = true]; 
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
        return customMetadataUtilityRecords;              
    }*/
    
    public without sharing class PartnerFundAllocationDetails{
        /*****************************************************************************************************
        Method Name : Fund Allocation Creation
        Added By    : SR
        @return     : Allocation Id
        Description : Creation of new Fund Allocation with Zero Budget
        Modified By :             
        *******************************************************************************************************/
        public ID getAllocationId(Id budgetId,Id activityAccountId){
            Id allocationId = null;
            Id allocatId = null;
            String budgetName = '';
            Boolean allocationWithCP = false;
            for(PartnerFundAllocation pfa : [SELECT Id,BudgetId,Budget.Title,ChannelPartnerId
                                             FROM PartnerFundAllocation 
                                             WHERE BudgetId = :budgetId]){                                                 budgetName = pfa.Budget.Title;
                                                 if(pfa.ChannelPartnerId == activityAccountId){
                                                     
                                                     allocationWithCP = true;                                                     allocatId = pfa.Id; 
                                                 }
                                             } if(allocationWithCP){allocationId = allocatId;
            }else{
                PartnerMarketingBudget pmb = [SELECT Id, Title, Core_MDF_Program__r.Core_MDF_Technical_Program_Name__c FROM PartnerMarketingBudget WHERE Id =: budgetId];
                //(Title=titleName, Budget = pmbRecord, BudgetId=pmbRecord.Id, ChannelPartnerId=cp.Id, Amount=allocationAmount);
                if(pmb != NULL){ Core_MDF_ObjRecType_Budget_FieldSetMap__mdt recTypeMetaData = [Select Id,Core_MDF_Channel_Program_Name_txt__c,Core_MDF_Allocation_RecordType_txt__c 
                                                                           from Core_MDF_ObjRecType_Budget_FieldSetMap__mdt 
                                                                             where Core_MDF_Channel_Program_Name_txt__c =:pmb.Core_MDF_Program__r.Core_MDF_Technical_Program_Name__c limit 1];Id recordtypeId = Schema.SObjectType.PartnerFundAllocation.getRecordTypeInfosByDeveloperName().get(recTypeMetaData.Core_MDF_Allocation_RecordType_txt__c).getRecordTypeId();
                // Setting record type for PFA
                    PartnerFundAllocation partnerFndAllocation = new PartnerFundAllocation(Title = pmb.Title,RecordTypeId = recordtypeId,
                                                                                           BudgetId = budgetId,
                                                                                           ChannelPartnerId = activityAccountId,
                                                                                           Amount = 0);       
                   
                    insert partnerFndAllocation;
                   
                    allocationId = partnerFndAllocation.Id;
                }            
            } return allocationId;
        }
        public PartnerFundAllocation getAllocationDetails(PartnerFundRequest pfrRecrd){
            
            Id Pfr_RecordType_IPA = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
            
            PartnerFundAllocation pfa1 = new PartnerFundAllocation(); List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
            //For IPA AccBased , It consider only pfr StartDate for BudgetConsumption
            Date pfrStartOrEndDate = (pfrRecrd.RecordTypeId == Pfr_RecordType_IPA && !pfrRecrd.Core_MDF_Proposal_Based_Ind__c)?pfrRecrd.Core_MDF_Start_Date__c:pfrRecrd.Core_MDF_End_Date__c ;for(PartnerFundAllocation pfa : [SELECT Id,BudgetId,Budget.Title,ChannelPartnerId
                                             FROM PartnerFundAllocation 
                                             WHERE ChannelPartnerId = :pfrRecrd.ChannelPartnerId  AND Core_MDF_Budget_Type__c = : pfrRecrd.Core_MDF_Budget_Type_nm__c
                                             AND Amount > 0
                                             AND Budget.StartDate <= :pfrRecrd.Core_MDF_Start_Date__c AND Budget.EndDate >=  :pfrStartOrEndDate]){                                                 pfa1 =    pfa;
                                             }                  return    pfa1;    }  }  @AuraEnabled  public static Boolean isLoggedInUsrApprover(String recordId) {Boolean result = false; Id curLoggedInUsrId = UserInfo.getUserId(); if(String.isNotBlank(recordId)) {Set<Id> actorGrpIdSet = new Set<Id>();Set<Id> grpMemberIdSet = new Set<Id>();for(ProcessInstanceWorkItem piwi : [SELECT Id, ActorId  FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :recordId]) {if(String.isNotBlank(piwi.ActorId) && String.valueOf(piwi.ActorId).startsWith('005') && piwi.ActorId == curLoggedInUsrId ) {result = true; break;} else { actorGrpIdSet.add(piwi.ActorId);  }  }if(actorGrpIdSet != null && !actorGrpIdSet.isEmpty()) {grpMemberIdSet = getUsersFromGroup(actorGrpIdSet);if(grpMemberIdSet != null && !grpMemberIdSet.isEmpty() && grpMemberIdSet.size() > 0 && grpMemberIdSet.contains(curLoggedInUsrId)) {result = true; }            }     }    return result;    }    
     public static Set<Id> getUsersFromGroup(Set<Id> groups) {
        Set<Id> groupIdSet = new Set<Id>();
        Set<Id> userIdSet = new Set<Id>();
        
        if(groups != null && !groups.isEmpty() && groups.size() > 0) {            for(GroupMember gm : [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId IN :groups]) {
                if(String.valueOf(gm.UserOrGroupId).startsWith('005')) {
                    userIdSet.add(gm.UserOrGroupId);
                } else {
                    groupIdSet.add(gm.UserOrGroupId);
                }
            }            if(groupIdSet != null && !groupIdSet.isEmpty() && groupIdSet.size() > 0) {
                
                for(GroupMember gm : [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId IN :groupIdSet]) {                    if(String.valueOf(gm.UserOrGroupId).startsWith('005')) {
                        userIdSet.add(gm.UserOrGroupId);                    } else {                        groupIdSet.add(gm.UserOrGroupId);
                    }
                }
            }
            // below code is for recursion
        }
        return userIdSet;
    } @AuraEnabled
    public static ComponentAttributes getInitialData(String inputValues) {   ComponentAttributes cmpAttr = new ComponentAttributes();
        if (String.isNotBlank(inputValues)){
            try {
                Map<String, Object> queryVariabels = (Map<String, Object>) JSON.deserializeUntyped(inputValues);
                String recordId = (String)queryVariabels.get('recordId');
                Boolean isClone = (Boolean)queryVariabels.get('isClone');
                
                if(String.isNotBlank(recordId) && !isClone) {                    cmpAttr.isLoggedInUserApprover = isLoggedInUsrApprover(recordId);   
                }
            } catch (Exception exp) {  Core_MDF_CCP_UtilityClass.logError(exp);
                throw new AuraHandledException(exp.getMessage());
            }
        } return cmpAttr; }    public class ComponentAttributes {        @AuraEnabled public Boolean isLoggedInUserApprover {get;set;}
    }
     @AuraEnabled public static Core_MDF_GeneralPurpose_UI_Utility.IntelMainOwnerWrapper getIntelActivityOwners(String accId,String primaryAcctId,String program, List<String> country,String budgetType,Boolean isActEdit) { return Core_MDF_GeneralPurpose_UI_Utility.getIntelActivityOwners(accId,primaryAcctId, program,country,budgetType,isActEdit);
        
    } @AuraEnabled public static List<Core_MDF_GeneralPurpose_UI_Utility.MemberActivityOwnerWrapper> getMemberactivityOwners(String accId, Boolean isPlannedEdit) { List<Core_MDF_GeneralPurpose_UI_Utility.MemberActivityOwnerWrapper> resultWrapperList = new List<Core_MDF_GeneralPurpose_UI_Utility.MemberActivityOwnerWrapper>();
        resultWrapperList = Core_MDF_GeneralPurpose_UI_Utility.getMemberactivityOwners(accId,isPlannedEdit);
       return resultWrapperList;
    
    } @AuraEnabled  public static Boolean checkSubmitterActive(String accId,String userId) { return Core_MDF_GeneralPurpose_UI_Utility.isSubmitterActive(accId,userId);
    }
     @AuraEnabled public static Boolean checkApproverActive(String accId,string primaryAcctId,String program, List<String> country,String budgetType,String userId) { return Core_MDF_GeneralPurpose_UI_Utility.isApprover(accId,primaryAcctId,program,country,budgetType,userId);
    }
    @AuraEnabled    public static Boolean checkEMEARegion(String country){
      
       Boolean isEMEARegion = false;       Set<String> geoSet = new Set<String>(); 
       List<String> countryList = country.Split(';');
       List<Core_MDF_CCP_Country_Geo_Mapping__mdt> countryGeoMetaDataList = Core_MDF_CCP_Country_Geo_Mapping__mdt.getAll().values(); 
       Map<String , String> countryGeoMap = new Map <String , String>();
        try{
                for(Core_MDF_CCP_Country_Geo_Mapping__mdt countryGeoMetaData : countryGeoMetaDataList){ 
                    countryGeoMap.put(countryGeoMetaData.MasterLabel , countryGeoMetaData.Core_MDF_Geo__c );
                }
                           if(countryList != NULL){for(String splitCountry : countryList){ if(countryGeoMap.containsKey(splitCountry)){geoSet.add(countryGeoMap.get(splitCountry));  break;
                                    }                                
                                } }if(geoSet.contains('EMEA')){isEMEARegion = true;        }       }        catch(Exception e){            Core_MDF_CCP_UtilityClass.logError(e);            throw new AuraHandledException(e.getMessage());
        }
       return isEMEARegion;
    } 
    
    /***************************************************************************************************** 
Method Name :   loadDynamicFields
Added By   :    Accenture
Modified By:                      Date:                   
*******************************************************************************************************/
    
    @AuraEnabled
    public static List<FieldSetMemberWrapperClass> loadDynamicFields(String pickListObj, String budType, String recType,Boolean isPropBased,String objectName){
       
        String dynamicRecTypeName = '';List<Core_MDF_RecordType_FieldSet_Mapping__mdt> fieldSetMap = new List<Core_MDF_RecordType_FieldSet_Mapping__mdt>();
        List<FieldSetMemberWrapperClass> wrapperList = new List<FieldSetMemberWrapperClass>();
        try{
        if(isPropBased != null){
        if(isPropBased){
            	dynamicRecTypeName = recType+'_Proposal';
        }
        else{  dynamicRecTypeName = recType+'_Account';
        }
        } if(dynamicRecTypeName != null & dynamicRecTypeName != ''){ recType = Core_MDF_CustomLabelConfig.getTextValues(dynamicRecTypeName);
        }
            if(recType != null){if(budType != 'defaultBudget'){
                    fieldSetMap = [SELECT Core_MDF_Record_Type_DeveloperName_nm__c, Core_MDF_Field_Set_API_Name_nm__c,Core_MDF_Budget_Type_nm__c FROM Core_MDF_RecordType_FieldSet_Mapping__mdt WHERE Core_MDF_Object_API_Name_nm__c =:pickListObj and Core_MDF_Budget_Type_nm__c =: budType and Core_MDF_Current_Object_nm__c =:objectName and Core_MDF_Record_Type_DeveloperName_nm__c =:recType];
                }
            } Map<String, String> options = new Map<String, String>(); Schema.SObjectType sObj = Schema.getGlobalDescribe().get(pickListObj);
            String fieldSetName = ''; 
            if(!fieldSetMap.isEmpty()){              fieldSetName = fieldSetMap[0].Core_MDF_Field_Set_API_Name_nm__c;
            }  if(fieldSetName != ''){ for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldSetName).getFields()){FieldSetMemberWrapperClass wrapper = new FieldSetMemberWrapperClass();wrapper.isRequired = fieldMember.getRequired();wrapper.fieldType = String.valueOf(fieldMember.getType()); wrapper.fieldLabel = fieldMember.getLabel();wrapper.fieldAPIName = fieldMember.getFieldPath();wrapper.helpText = fieldMember.getSObjectField().getDescribe().getInlineHelpText(); if(String.valueOf(fieldMember.getType()) == 'PICKLIST' || String.valueOf(fieldMember.getType()) == 'MULTIPICKLIST') {options = new Map<String, String>();for (Schema.PicklistEntry p: sObj.getDescribe().fields.getMap().get(fieldMember.getFieldPath()).getDescribe().getPicklistValues()) { options.put(p.getValue(), p.getLabel()); }  wrapper.pickListValues = options;      }   if(wrapper != null){ wrapperList.add(wrapper);
        }
                }       } } catch(Exception e){  Core_MDF_CCP_UtilityClass.logError(e);  throw new AuraHandledException(e.getMessage());  } return wrapperList;
    }
    
    @AuraEnabled
    public static List<String> fetchPicklistFromCampaign(String pickListObj, String budType, String recType, Boolean isPropBased, String objectName){
        String dynamicRecTypeName = '';
        List<Core_MDF_RecordType_FieldSet_Mapping__mdt> fieldSetMapList = new List<Core_MDF_RecordType_FieldSet_Mapping__mdt>();
        List<String> fieldsToFetchPicklistValueList = new List<String>();
        try{
       if(isPropBased != null){if(isPropBased){dynamicRecTypeName = recType+'_Proposal'; } else{ dynamicRecTypeName = recType+'_Account';
        }
       }     if(dynamicRecTypeName != null & dynamicRecTypeName != ''){ recType = Core_MDF_CustomLabelConfig.getTextValues(dynamicRecTypeName);
            }
        String fieldsToFetchPicklistValue = '';  if(recType != null){ fieldSetMapList = [SELECT Core_MDF_FieldsToFetchPicklistValues__c,Core_MDF_Record_Type_DeveloperName_nm__c, Core_MDF_Field_Set_API_Name_nm__c,Core_MDF_Budget_Type_nm__c FROM Core_MDF_RecordType_FieldSet_Mapping__mdt WHERE Core_MDF_Object_API_Name_nm__c =:pickListObj and Core_MDF_Budget_Type_nm__c =: budType and Core_MDF_Current_Object_nm__c =:objectName and Core_MDF_Record_Type_DeveloperName_nm__c =:recType];
                }
               if(!fieldSetMapList.isEmpty()){     for(Core_MDF_RecordType_FieldSet_Mapping__mdt fieldSet : fieldSetMapList){
                fieldsToFetchPicklistValue = fieldSet.Core_MDF_FieldsToFetchPicklistValues__c;
                /*if(fieldSet.Core_MDF_FieldsToFetchPicklistValues2__c != null){
                    fieldsToFetchPicklistValue = fieldsToFetchPicklistValue+';'+fieldSet.Core_MDF_FieldsToFetchPicklistValues2__c;
                    if(fieldSet.Core_MDF_FieldsToFetchPicklistValues3__c != null){
                        fieldsToFetchPicklistValue = fieldsToFetchPicklistValue+';'+fieldSet.Core_MDF_FieldsToFetchPicklistValues3__c;
                        if(fieldSet.Core_MDF_FieldsToFetchPicklistValues4__c != null){
                            fieldsToFetchPicklistValue = fieldsToFetchPicklistValue+';'+fieldSet.Core_MDF_FieldsToFetchPicklistValues4__c;
                        }
                        if(fieldSet.Core_MDF_FieldsToFetchPicklistValues5__c != null){
                            fieldsToFetchPicklistValue = fieldsToFetchPicklistValue+';'+fieldSet.Core_MDF_FieldsToFetchPicklistValues5__c;
                        }
                    }
                }*/
            }
        }
       
            if(fieldsToFetchPicklistValue != null & fieldsToFetchPicklistValue != ''){
                fieldsToFetchPicklistValueList = fieldsToFetchPicklistValue.split(';');  }   } catch(Exception e){  Core_MDF_CCP_UtilityClass.logError(e);   throw new AuraHandledException(e.getMessage());
        }
        return fieldsToFetchPicklistValueList;    }  @AuraEnabled public static AllocationDetailsWrapper checkAvailableAllocAmt(PartnerFundRequest pfr,String recordType,string accountId,Id budgetId){string amountToBeDisplayed = ''; List<PartnerFundAllocation> pfaList=new List<PartnerFundAllocation>(); AllocationDetailsWrapper allocDetailsWrapper = new AllocationDetailsWrapper(); allocDetailsWrapper.autoEnabled = false;try{if(pfr != null){if(string.isNotBlank(recordType) &&  string.isNotBlank(accountId) && budgetId!=null && pfr.Core_MDF_Start_Date__c != null && pfr.Core_MDF_End_Date__c != null){if(pfr.Core_MDF_Start_Date__c<=pfr.Core_MDF_End_Date__c ){Date pfrStartOrEndDate =(Label.Core_MDF_IPA_RecordType.contains(recordType) && !pfr.Core_MDF_Proposal_Based_Ind__c) ?pfr.Core_MDF_Start_Date__c:pfr.Core_MDF_End_Date__c;if(!Label.Core_MDF_Co_GTM_RecordType.contains(recordType)){ pfaList = [Select Id,Core_MDF_Available_Activity_Alloc_Amt__c,ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c,BudgetId,Core_MDF_Program_Txt__c,RecordType.DeveloperName,Core_MDF_Start_Date_dt__c,Core_MDF_End_Date_dt__c,ChannelPartnerId,Core_MDF_Budget_Type__c FROM PartnerFundAllocation WHERE ChannelPartnerId = :accountId AND RecordType.DeveloperName = :recordType AND BudgetId = : budgetId AND Amount > 0 AND Budget.StartDate <= :pfr.Core_MDF_Start_Date__c AND Budget.EndDate >=  :pfrStartOrEndDate]; } else{  pfaList = [Select Id,Core_MDF_Available_Activity_Alloc_Amt__c,ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c,BudgetId,Core_MDF_Program_Txt__c,RecordType.DeveloperName,Core_MDF_Start_Date_dt__c,Core_MDF_End_Date_dt__c,ChannelPartnerId,Core_MDF_Budget_Type__c FROM PartnerFundAllocation WHERE ChannelPartnerId = :accountId AND RecordType.DeveloperName = :recordType AND Amount >= 0 and BudgetId = : budgetId AND Budget.StartDate <= :pfr.Core_MDF_Start_Date__c AND Budget.EndDate >=  :pfrStartOrEndDate];  }   } if(Label.Core_MDF_Co_GTM_RecordType.contains(recordType) && pfaList.isEmpty()){ Integer amount = 0;pfaList = createCoGtmAllocation(accountId,budgetId,recordType,amount); }if(!pfaList.isEmpty()){amountToBeDisplayed = String.valueOf(pfaList[0].Core_MDF_Available_Activity_Alloc_Amt__c);allocDetailsWrapper.allocationId = pfaList[0].Id;if(pfaList[0].ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c){allocDetailsWrapper.autoEnabled = true;
                        }
                    }
                    else{ amountToBeDisplayed=System.Label.Core_MDF_ZeroAllocationAmount;
                        //allocDetailsWrapper.allocationId = '';
                    }
                    //allocDetailsWrapper.amountToBeDisplayed = amountToBeDisplayed;
                }else{ amountToBeDisplayed=System.Label.Core_MDF_ZeroAllocationAmount;
                } allocDetailsWrapper.amountToBeDisplayed = amountToBeDisplayed;
            }
        }   catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e); throw new AuraHandledException(e.getMessage());  }return allocDetailsWrapper; }public static List<PartnerFundAllocation> createCoGtmAllocation(Id accountId,Id budgetId, String recordtype, Integer amount){List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>(); Map<Id,PartnerMarketingBudget> budgetIdToRecordMap = new Map<Id, PartnerMarketingBudget>([SELECT Id, Title FROM PartnerMarketingBudget WHERE Id =:budgetId]);Id recordtypeId = Schema.SObjectType.PartnerFundAllocation.getRecordTypeInfosByDeveloperName().get(recordtype).getRecordTypeId(); PartnerFundAllocation partnerFndAllocation = new PartnerFundAllocation(RecordTypeId = recordtypeId, Title = budgetIdToRecordMap.get(budgetId).Title, BudgetId = budgetId, ChannelPartnerId = accountId, Amount = amount); insert partnerFndAllocation;pfaList.add(partnerFndAllocation);            return pfaList; }public class AllocationDetailsWrapper{ @AuraEnabled     public Id allocationId { get; set; } @AuraEnabled   public String amountToBeDisplayed { get; set; } @AuraEnabled public Boolean autoEnabled {get; set;}}public class FieldSetMemberWrapperClass {   @AuraEnabled public Boolean isRequired { get; set; }   @AuraEnabled public String fieldType { get; set; } @AuraEnabled public String fieldLabel { get; set; }@AuraEnabled public String fieldAPIName { get; set; } @AuraEnabled public String helpText { get; set; } @AuraEnabled public Map<String, String> pickListValues { get; set; }
    }
//Added for Activity field editability on edit
   @AuraEnabled
    public static activityEditWrapper getFieldEditibilityMappingActivity(String objectName, String recTypeDevloperName, String status, Id activityId, Boolean proposalBasedIndicator, Date startDate){
        List<String> fieldApiNameList = new List<String>();
        Set<String> fieldReadApiNameSet = new Set<String>();
        String userId = UserInfo.getUserId();
        String applicableDate;
        List<String> budgetTypeList =  new List<String>();
        Set<String> psNameSet = new Set<String>();
        string pfrBothDated = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_FieldEditability_PastFutureDate').Split(';')[2];
        string pfrPastDated = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_FieldEditability_PastFutureDate').Split(';')[0];
        string pfrFutureDated = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_FieldEditability_PastFutureDate').Split(';')[1];
	string IpaRecordType=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType');
        activityEditWrapper activityEditWrapperList = new activityEditWrapper(); 
        activityEditWrapper activityEditList = new activityEditWrapper();   
     try{
            if(startDate != null){ if(recTypeDevloperName == IpaRecordType && (status == Core_MDF_CCP_ConstantClass.PFR_PLANNED_STATUS || status == Core_MDF_CCP_ConstantClass.PFR_RR_STATUS)){ applicableDate = startDate< system.today() ? pfrPastDated : pfrFutureDated ;}else{applicableDate = pfrBothDated;} }else{applicableDate = pfrBothDated; }if(proposalBasedIndicator){budgetTypeList.add('Proposal II MDF;Proposal I MDF');}else if(!proposalBasedIndicator){budgetTypeList.add('Account Plan'); } for(PermissionSetAssignment psa : [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :userId]) {psNameSet.add(psa.PermissionSet.Name);  }partnerFundRequestCreateWithOutSharing pfrWithOutSharing = new partnerFundRequestCreateWithOutSharing();List<Core_MDF_Custom_Configuration__c> customConfiqList = pfrWithOutSharing.getEditCustomConfiqRecords(objectName, recTypeDevloperName, status, budgetTypeList, applicableDate);for(Core_MDF_Custom_Configuration__c fieldEdit : customConfiqList){ if(psNameSet != null && psNameSet.contains(fieldEdit.Core_MDF_Permission_Set_API_Name__c)){activityEditWrapperList.fieldApiName.addAll(fieldEdit.Core_MDF_Field_Read_Write_Attributes__c.split(','));activityEditWrapperList.fieldApiNameListReadOnly.addAll(fieldEdit.Core_MDF_Field_ReadOnly_Attributes__c.split(','));
            }
        }if(activityEditWrapperList != null)
        {
            activityEditList = activityEditWrapperList;        }    }   catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e); throw new AuraHandledException(e.getMessage());       }        return activityEditList; } @AuraEnabled     Public static OutputWrapper getFieldEditabilityMapping(SObject obj, string contentType){OutputWrapper outputWrap = new OutputWrapper(); try{if(obj != NULL && obj.Id != NULL){List<string> eligibleDates = (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_FieldEditability_PastFutureDate') != NULL) ? Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_FieldEditability_PastFutureDate').Split(';') : new List<string>(); string pastDated,futureDated,bothDated = '';  if(eligibleDates.size() == 3){ pastDated = eligibleDates[0]; futureDated = eligibleDates[1];  bothDated = eligibleDates[2]; } string futurePastDateProgramsStr = Core_MDF_CCP_ConstantClass.PFR_RMF_RECORDTYPE + ';Core_MDF_Intel_Partner_Alliance';List<string> BUDGETTYPE_BASED_PROG = new List<string>{Core_MDF_CCP_ConstantClass.PFR_CCF_RECORDTYPE,Core_MDF_CCP_ConstantClass.PFR_DCF_RECORDTYPE,'Core_MDF_Co_GTM','Core_MDF_Intel_Partner_Alliance'};List<string> futurePastDateProgramsList = futurePastDateProgramsStr.split(';'); InputWrapper inputWrap = new InputWrapper(); inputWrap.objectName = obj.Id.getSObjectType().getDescribe().getName(); inputWrap.contentType = contentType; inputWrap.applicableDate = bothDated; switch on inputWrap.objectName {when 'PartnerFundRequest'{PartnerFundRequest pfr = (PartnerFundRequest)obj;inputWrap.status  = pfr.Core_MDF_Fund_Request_Status__c;inputWrap.recordType = pfr.RecordType.DeveloperName;  inputWrap.approvalStage = (pfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' && string.isNotBlank(pfr.Core_MDF_Approval_Stage__c) && pfr.Core_MDF_Approval_Stage__c != 'None') ? pfr.Core_MDF_Approval_Stage__c : '';inputWrap.budgetType = BUDGETTYPE_BASED_PROG.contains(inputWrap.recordType) ? pfr.Core_MDF_Budget_Type_nm__c : ''; if(futurePastDateProgramsList.contains(inputWrap.recordType) && (inputWrap.status == Core_MDF_CCP_ConstantClass.PFR_PLANNED_STATUS || inputWrap.status == Core_MDF_CCP_ConstantClass.PFR_RR_STATUS)){ inputWrap.applicableDate = pfr.Core_MDF_Start_Date__c < system.today() ? pastDated : futureDated;
                        }
                    }
                }for(PermissionSetAssignment psa : [SELECT PermissionSet.Name FROM PermissionSetAssignment 
                                                   WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSet.Name Like: 'Core_MDF%']) {
                    inputWrap.loggedInUserPS.add(psa.PermissionSet.Name);
                }
                
                
                
                partnerFundRequestCreateWithOutSharing pfrWithOutSharing = new partnerFundRequestCreateWithOutSharing();
                List<Core_MDF_Custom_Configuration__c> customConfiqList = pfrWithOutSharing.getCustomConfiqRecords(inputWrap);
                
                if(!customConfiqList.isEmpty()){
                    outputWrap.confiqRecord = customConfiqList;
                    //Method to preapre a editability map based on confiq data
                    setEditabiltyMap(customConfiqList);
                }
            }
            
            outputWrap.status = !fieldToEditabilityMap.isEmpty() ? 'success' : 'No Data Found';
        }
        catch(Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            outputWrap.status = 'exception';
            outputWrap.message = ex.getLineNumber() + ' ' + ex.getMessage();
        }
        
        outputWrap.fieldEditability = (fieldToEditabilityMap != null) ? fieldToEditabilityMap : new Map<string,Boolean>();
        return outputWrap;
    }

    public static void setEditabiltyMap(List<Core_MDF_Custom_Configuration__c> customConfiqList){
        Map<Id,Core_MDF_Custom_Configuration__c> idToCustomConfiqMap = new Map<Id,Core_MDF_Custom_Configuration__c>();
        Map<Id,Set<Id>> parentIdToChildIdSet = new Map<Id,Set<Id>>();

        //parentIdToChildIdSet Map stores values for parent to its child data.
        for(Core_MDF_Custom_Configuration__c content : customConfiqList) {
            idToCustomConfiqMap.put(content.Id,content);
            
            if(content.Core_MDF_Parent_Confiquration__c == NULL){
                parentIdToChildIdSet.put(content.Id, new Set<Id>());
            }else{
                if(!parentIdToChildIdSet.containsKey(content.Core_MDF_Parent_Confiquration__c)){
                    parentIdToChildIdSet.put(content.Core_MDF_Parent_Confiquration__c, new Set<Id>());
                }
                parentIdToChildIdSet.get(content.Core_MDF_Parent_Confiquration__c).add(content.Id);
            }
        }  
        
        //Method to set editability. If child data present it will override with parent confiq
        if(!parentIdToChildIdSet.isEmpty()){
            for(Id parentId : parentIdToChildIdSet.keySet()){
                Core_MDF_Custom_Configuration__c parentRecord = idToCustomConfiqMap.get(parentId);
                getFieldDetails(parentRecord);
                if(!parentIdToChildIdSet.get(parentId).isEmpty()){
                    for(Id childId : parentIdToChildIdSet.get(parentId)){
                        Core_MDF_Custom_Configuration__c childRecord = idToCustomConfiqMap.get(childId);
                        getFieldDetails(childRecord);
                    }
                }
            }
        }
    }

    
    
    public static void getFieldDetails(Core_MDF_Custom_Configuration__c content){
        List<string> editableFields = string.isNotBlank(content.Core_MDF_Field_Read_Write_Attributes__c) ? content.Core_MDF_Field_Read_Write_Attributes__c.split(',') : new List<String>();
        List<string> readOnlyFields = string.isNotBlank(content.Core_MDF_Field_ReadOnly_Attributes__c) ? content.Core_MDF_Field_ReadOnly_Attributes__c.split(',') : new List<String>();
        
        //Param as false which behaves as editable fields
        if(!editableFields.isEmpty()){
            getEditability(editableFields,false);
        }
        //Param as true which behaves as readOnly fields
        if(!readOnlyFields.isEmpty()){
            getEditability(readOnlyFields,true);
        }
    }
    
    public static void getEditability(List<String> fields, Boolean readOnly){
        for(string fieldApiName : fields) {
            //This condition checks if the incoming value for the field has the highest access then it doesn't over it with lower access.
            //Only open up of access is allowed i.e -> ReadOnly to Editable.
            if(!fieldToEditabilityMap.containsKey(fieldApiName) || 
               (fieldToEditabilityMap.containsKey(fieldApiName) && fieldToEditabilityMap.get(fieldApiName) != readOnly && fieldToEditabilityMap.get(fieldApiName) == true)){
                fieldToEditabilityMap.put(fieldApiName,readOnly);
            }
        }
    }


Public class InputWrapper {
        public string objectName;
        public Set<string> loggedInUserPS = new Set<string>();
        public string recordType;
        public string contentType;
        public string applicableDate;
	public string approvalStage;
        public string budgetType;
        public string status;
    } 
    
        
    Public class OutputWrapper {
        @AuraEnabled public string message;
        @AuraEnabled public string status = '';
        @AuraEnabled public List<Core_MDF_Custom_Configuration__c> confiqRecord = new List<Core_MDF_Custom_Configuration__c>();
        @AuraEnabled public Map<string,Boolean> fieldEditability = new Map<string,Boolean>();
    } 
    

    
    /****************************************************************************************************** 
Method Name:        cancelActvityForCancelledClaims
@return       :     activityCancelWrapper
@parameters   :     PartnerFundRequest newPFR
Description:        This method is used to cancel the in-progress activity on edit
Added By:           Hemapriyadharshini.k - 2/7/2022 
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static activityCancelWrapper cancelActvityForCancelledClaims(PartnerFundRequest newPFR, String pfrSelectedStatus, Boolean isPfrStatusClosed)
    {
        boolean hasNonCancelledClaims = false;
        boolean hasActiveEscalation = false;
        activityCancelWrapper activityCancelCheckWrapper = new activityCancelWrapper();
        Map<Id,PartnerFundRequest> newPFRMap = new Map<Id,PartnerFundRequest>();
        Map<Id,Boolean> pfrIdAndCheckForValidClaimMap = new Map<Id,Boolean>();        
        Map<Id,Boolean> pfrIdAndCheckForActiveEscalationMap = new Map<Id,Boolean>();
        newPFRMap.put(newPFR.Id,newPFR);
        Map<Id,List<Id>> activityClaimMap = new Map<Id,List<Id>>();
        try{
            if(newPFR != null && isValidUserToCancelActvity == true){
                activityCancelCheckWrapper.isValidActivityCancelUser = true;
            }else{
                activityCancelCheckWrapper.isValidActivityCancelUser = false;
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}  
        return activityCancelCheckWrapper;
    }
   
/****************************************************************************************************** 
Method Name:        checkAndValidateClaims
@return       :     Boolean
@parameters   :     Map<Id,PartnerFundRequest> oldPfrMap, Map<Id,PartnerFundRequest> newMap, String pfrSelectedStatus
Description   :     Check the active claims other than cancelled claims
Added By:           Hemapriyadharshini.k - 2/7/2022 
Modified By:        Date:      Changes: 
*******************************************************************************************************/
Public static Map<Id,Boolean> checkAndValidateClaims(Map<Id,PartnerFundRequest> newPfrMap, Map<Id,PartnerFundRequest> oldPfrMap){ 
    boolean hasNonCancelledClaims =false; 
    Id pfrId;Integer pfcCounts; 
    Set<Id> pfrIdSet = new Set<Id>();
    Map<Id,Integer> pfrIdPfcCountMap = new Map<Id,Integer>();
    Map<Id,Boolean> pfrIdAndCheckForValidClaimMap = new Map<Id, Boolean>();
    try{
        if(!(System.Label.Core_MDF_Is_ValidationBypassed == 'TRUE' && System.Label.Core_MDF_VRBypassByUser.contains(UserInfo.getUserName()))){
            for(PartnerFundRequest pfr :newPfrMap.values()){                if(oldPfrMap.get(pfr.Id) != null && newPfrMap.get(pfr.Id) != null && (oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c.Equals(Label.Core_MDF_pfrInprogress) ||oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == 'Closed' || oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c .Equals(Label.Core_MDF_PFR_In_Progress_Revision_Required) ) && newPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c.Equals(pfrCancelledStatus)){                    pfrIdSet.add(pfr.Id);  
                            //pfrIdAndCheckForValidClaimMap.put(pfr.Id);                                                    
                        }
            }
                //pfcStatus - Cancelled;Resubmission Window Closed
            if(pfrIdSet != null && !pfrIdSet.isEmpty()){for(AggregateResult pfcMap : [SELECT RequestId Id ,count(id) pfcCount FROM PartnerFundClaim WHERE RequestId IN:pfrIdSet AND Core_MDF_Status__c NOT IN: pfcStatus AND (Request.Core_MDF_Fund_Request_Status__c =: Label.Core_MDF_pfrInprogress OR Request.Core_MDF_Fund_Request_Status__c =: Label.Core_MDF_PFR_Status_Closed OR Request.Core_MDF_Fund_Request_Status__c =: Label.Core_MDF_PFR_In_Progress_Revision_Required)AND Core_MDF_Escalation_Id__c = null GROUP BY RequestId]){  pfrID =(Id)pfcMap.get('Id');pfcCounts=(Integer)pfcMap.get('pfcCount'); pfrIdPfcCountMap.put(pfrID,pfcCounts);
                                            
                                                                 
                }
            }
            if(pfrIdPfcCountMap != null && !pfrIdPfcCountMap.isEmpty()){  for(Id pfrIdList : pfrIdPfcCountMap.keyset()){ if(pfrIdPfcCountMap.get(pfrIdList) != 0 &&  pfrIdPfcCountMap.get(pfrIdList) >0){if(!pfrIdAndCheckForValidClaimMap.containsKey(pfrIdList)){pfrIdAndCheckForValidClaimMap.put(pfrIdList,true);
                                
                            }
                        }
                    }
            }
        }}catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}  
    //return hasNonCancelledClaims;
    return pfrIdAndCheckForValidClaimMap;} Public static Map<Id,Boolean> checkActiveEscalation(Map<Id,PartnerFundRequest> newPfrMap, Map<Id,PartnerFundRequest> oldPfrMap){ boolean hasActiveEscalation =false;Id pfrId;Integer escCounts;  Set<Id> pfrIdSet = new Set<Id>();Map<Id,Integer> pfrIdEscCountMap = new Map<Id,Integer>();Map<Id,Boolean> pfrIdAndCheckForActiveEscalation = new Map<Id, Boolean>(); try{if(!(System.Label.Core_MDF_Is_ValidationBypassed == 'TRUE' && System.Label.Core_MDF_VRBypassByUser.contains(UserInfo.getUserName()))){for(PartnerFundRequest pfr :newPfrMap.values()){if(oldPfrMap.get(pfr.Id) != null && newPfrMap.get(pfr.Id) != null && (oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c.Equals(Label.Core_MDF_pfrInprogress) || oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == 'Closed') && newPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c.Equals(pfrCancelledStatus) ){pfrIdSet.add(pfr.Id);   } } }if(pfrIdSet != null && !pfrIdSet.isEmpty()){for(AggregateResult escMap : [Select Core_MDF_Co_Marketing_Activity_id__c Id,count(id) escCount FROM Core_MDF_Escalation__c WHERE (Core_MDF_Escalation_Status_nm__c = 'Approved' OR Core_MDF_Escalation_Status_nm__c = 'Pending Review') AND Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Fund_Request_Status__c =: Label.Core_MDF_PFR_Status_Closed AND Core_MDF_Co_Marketing_Activity_id__c IN:pfrIdSet GROUP BY Core_MDF_Co_Marketing_Activity_id__c]){ pfrID =(Id)escMap.get('Id');escCounts=(Integer)escMap.get('escCount'); pfrIdEscCountMap.put(pfrID,escCounts); }  } if(pfrIdEscCountMap != null && !pfrIdEscCountMap.isEmpty())   {  for(Id pfrIds : pfrIdEscCountMap.keyset()){ if(pfrIdEscCountMap.get(pfrIds) != 0 &&  pfrIdEscCountMap.get(pfrIds) >0){ if(!pfrIdAndCheckForActiveEscalation.containsKey(pfrIds)){pfrIdAndCheckForActiveEscalation.put(pfrIds,true);  }  }  }  } }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;} return pfrIdAndCheckForActiveEscalation;
}    

    public class activityCancelWrapper{ @AuraEnabled         public boolean isValidActivityCancelUser=false; @AuraEnabled         public boolean hasNonCancelledClaims=false; @AuraEnabled         public boolean hasActiveEscalation=false;
    }  
    

/****************************************************************************************************** 
Method Name:        activityEditWrapper
Added By:           Hemapriyadharshini.k - 2/7/2022 
Modified By:        Date:      Changes: 
*******************************************************************************************************/
     public class activityEditWrapper{   	
        @AuraEnabled
        public List<String> fieldApiName = new List<String>();
        @AuraEnabled
        public List<String> fieldApiNameListReadOnly = new List<String>();   }  @AuraEnabled  public static Boolean restrictMutliGeoCountry(PartnerFundRequest pfr,PartnerFundRequest oldPfr){Map<String, String> countryGeoMap = new Map <String, String>(); Boolean errorThrown = false;List<Core_MDF_CCP_Country_Geo_Mapping__mdt> countryGeoMetaDataList = Core_MDF_CCP_Country_Geo_Mapping__mdt.getAll().values(); try{for(Core_MDF_CCP_Country_Geo_Mapping__mdt countryGeoMetaData : countryGeoMetaDataList){countryGeoMap.put(countryGeoMetaData.MasterLabel , countryGeoMetaData.Core_MDF_Geo__c ); }  Set<String> geoSet = new Set<String>(); if(oldPfr == null || (oldPfr!= null && oldPfr.Core_MDF_Country_nm__c != pfr.Core_MDF_Country_nm__c )){ if(pfr.Core_MDF_Country_nm__c != NULL){ List<String> splitCountry = pfr.Core_MDF_Country_nm__c.split(';');for(String Country : splitCountry){if(countryGeoMap.containsKey(Country)){  geoSet.add(countryGeoMap.get(Country));    }   }  if(geoSet != NULL && geoSet.size() > 1 ){	errorThrown = true;  }  }   } } catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e); throw new AuraHandledException(e.getMessage()); }return errorThrown;
        
    }
    /****************************************************************************************************** 
Method Name:        validatePfrCreationAccess
@return       :     Boolean
@parameters   :     recordTypeDevloperName
Description   :     Check the creation access of pfr
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static Boolean validatePfrCreationAccess(String recordType){
        Boolean hasCreateAccess = false;
        string IPARecordType=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType');
        Boolean hasIPACreateAccess = (isCustomPermissionAssigned('Core_MDF_CCP_Internal_IPA_Acct_Mgr') || ((isCustomPermissionAssigned('Core_MDF_CCP_External_IPA_Activity_Manager') || isCustomPermissionAssigned('Core_MDF_CCP_External_IPA_Proposal_Manager')) && isCustomPermissionAssigned('Core_MDF_IPA_User'))) ? true : false ;
        String CCFRecordType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_PFRRecordTypeDevName');
        Boolean hasCCFCreateAccess = (isCustomPermissionAssigned('Core_MDF_CCP_Internal_CCF_Acct_Mgr') || isCustomPermissionAssigned('Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr') || (isCustomPermissionAssigned('Core_MDF_CCP_External_Activity_Submitter') &&  isCustomPermissionAssigned('Core_MDF_CCF_USER'))) ? true : false ;
        String DCFRecordType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_PFRRecordTypeDevName');
        Boolean hasDCFCreateAccess = (isCustomPermissionAssigned('Core_MDF_CCP_Internal_DCF_Acct_Mgr') || isCustomPermissionAssigned('Core_MDF_CCP_Internal_DCF_Field_Acct_Mgr') || (isCustomPermissionAssigned('Core_MDF_CCP_External_Activity_Submitter') &&  isCustomPermissionAssigned('Core_MDF_DCF_USER'))) ? true : false ;
        String RMFRecordType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Retail');
        Boolean hasRMFCreateAccess = isCustomPermissionAssigned('Core_MDF_CCP_Internal_RMF_Account_Manager') ? true : false ;
        String EEFRecordType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_PFRRecordTypeDevName');
        Boolean hasEEFCreateAccess = (isCustomPermissionAssigned('Core_MDF_CCP_Internal_EEF_Activating_Account_Manager') || isCustomPermissionAssigned('Core_MDF_CCP_Internal_EEF_Primary_Account_Manager') || (isCustomPermissionAssigned('Core_MDF_CCP_External_EEF_Activity_Submitter') &&  isCustomPermissionAssigned('Core_MDF_CCP_EEF_User')))  ? true : false ;
        String NRERecordType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NRE_RecordType');
        Boolean hasNRECreateAccess = (isCustomPermissionAssigned('Core_MDF_CCP_Internal_Co_GTM_Account_Manager') || (isCustomPermissionAssigned('Core_MDF_CCP_External_Co_GTM_Claim_Submitter') &&  isCustomPermissionAssigned('Core_MDF_Co_GTM_USER'))) ? true : false ;
        try{
            if(String.isNotBlank(recordType) && ((recordType == RMFRecordType && hasRMFCreateAccess) || (recordType == CCFRecordType && hasCCFCreateAccess) || (recordType == DCFRecordType && hasDCFCreateAccess) || (recordType == IPARecordType && hasIPACreateAccess) || (recordType == EEFRecordType && hasEEFCreateAccess) || (recordType == NRERecordType && hasNRECreateAccess) )){
                hasCreateAccess = true;  }       }catch(Exception e){            Core_MDF_CCP_UtilityClass.logError(e);            throw new AuraHandledException(e.getMessage());
        } 
        
        return hasCreateAccess;
    }
    /****************************************************************************************************** 
    Method Name:        validatePfrModifyAccess
    @return       :     Boolean
    @parameters   :     Campaign, isPfrCreation
    Description   :     Check the modify acess of pfr on the current status
    Added By:           Saikat - 8/11/2023 
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public static Boolean validatePfrModifyAccess(Campaign cmp, Boolean isPfrCreation){
        Boolean isCreationError = false;
        if((cmp.Status == Core_MDF_CCP_ConstantClass.CAMPAIGN_PENDING_REVIEW             || cmp.Status == Core_MDF_CCP_ConstantClass.CAMPAIGN_PENDING_APPROVAL)
            && (isCustomPermissionAssigned('Core_MDF_CCP_Internal_IPA_Acct_Mgr') 
                || isCustomPermissionAssigned('Core_MDF_CCP_External_IPA_Proposal_Manager'))){                    isCreationError = true;
        }
        //For Dual role Edit(As a L1 Approver)
        if(cmp.Status == Core_MDF_CCP_ConstantClass.CAMPAIGN_PENDING_REVIEW 
            && cmp.Core_MDF_Approval_Stage_nm__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL && !isPfrCreation             && isCustomPermissionAssigned('Core_MDF_CCP_Internal_IPA_Acct_Mgr')             && isCustomPermissionAssigned('Core_MDF_CCP_Int_IPA_ProposalL1_Approver')){                    isCreationError = false;
        }
        //For Dual Role Edit(IPA Accounnt Manager+Price reviewer)
        if(cmp.Status == Core_MDF_CCP_ConstantClass.CAMPAIGN_PENDING_REVIEW 
            && cmp.Core_MDF_Approval_Stage_nm__c == Core_MDF_CCP_ConstantClass.PFR_PRICE_REVIEWER && !isPfrCreation 
            && (isCustomPermissionAssigned('Core_MDF_CCP_Internal_IPA_Acct_Mgr')             && isCustomPermissionAssigned('Core_MDF_PriceReviewer'))){                    isCreationError = false;
        }
        return isCreationError;    }  public without sharing class CampaignBudgets{   public List<Core_MDF_Campaign_Budgets__c> getCampaignBudgets(Id campRecordId, Date startDate, Date endDate, String budgetType){List<Core_MDF_Campaign_Budgets__c> cmpgnBudgetlst = [SELECT Id, Core_MDF_Budget_Amt__c,Core_MDF_Reimbursement_Amt__c,toLabel(Core_MDF_Reimbursement_Rate_Pct__c),Core_MDF_Budget_Name_Id__c,Core_MDF_Budget_Name_Id__r.Core_MDF_budget_ref_nbr__c,Core_MDF_Budget_Name_Id__r.Title,Core_MDF_Budget_Type_Nm__c,Core_MDF_Campaign_Id__c,Core_MDF_End_Date_Dt__c,Core_MDF_Start_Date_Dt__c,Core_MDF_Campaign_Id__r.Core_MDF_Brand__c,Core_MDF_Campaign_Id__r.Core_MDF_Proposal_Based_Ind__c FROM Core_MDF_Campaign_Budgets__c WHERE Core_MDF_Campaign_Id__r.id = :campRecordId AND Core_MDF_Budget_Name_Id__r.TotalAllocatedAmount > 0 AND Core_MDF_Start_Date_Dt__c <= :startDate  AND Core_MDF_End_Date_Dt__c >= :endDate AND Core_MDF_Active_ind__c = TRUE ORDER BY Core_MDF_Budget_Type_Nm__c];  return cmpgnBudgetlst; } }public without sharing class partnerFundRequestCreateWithOutSharing{public List<Core_MDF_Custom_Configuration__c> getCustomConfiqRecords(InputWrapper inputWrap){List<string> BUDGETTYPE_BASED_PROG = new List<string>{'Core_MDF_Client_CoMarketing_Fund','Core_MDF_Data_Center_CoMarketing_Fund','Core_MDF_Co_GTM','Core_MDF_Intel_Partner_Alliance'};List<Core_MDF_Custom_Configuration__c> customConfiqList = [SELECT Name,Core_MDF_Object_Name__c,Core_MDF_Type__c,Core_MDF_Field_Read_Write_Attributes__c,Core_MDF_Field_ReadOnly_Attributes__c, Core_MDF_Record_Type_Developer_Name__c,Core_MDF_Permission_Set_Api_Name__c,Core_MDF_Applicable_for_Past_Future__c,
                                                                       Core_MDF_Active__c,Core_MDF_Budget_Type__c,Core_MDF_Parent_Confiquration__c,Core_MDF_Status__c
                                                                       FROM Core_MDF_Custom_Configuration__c WHERE Core_MDF_Object_Name__c =: inputWrap.objectName AND Core_MDF_Permission_Set_Api_Name__c IN: inputWrap.loggedInUserPS
                                                                       AND Core_MDF_Type__c =: inputWrap.contentType AND Core_MDF_Record_Type_Developer_Name__c =: inputWrap.recordType
                                                                       AND Core_MDF_Status__c =: inputWrap.status AND Core_MDF_Applicable_for_Past_Future__c =: inputWrap.applicableDate
                                                                       AND ((Core_MDF_Record_Type_Developer_Name__c IN: BUDGETTYPE_BASED_PROG AND Core_MDF_Budget_Type__c INCLUDES (:inputWrap.budgetType)) OR (Core_MDF_Record_Type_Developer_Name__c NOT IN: BUDGETTYPE_BASED_PROG AND Core_MDF_Budget_Type__c = NULL))
                                                                       AND ((Core_MDF_Record_Type_Developer_Name__c!='Core_MDF_Intel_Partner_Alliance' AND Core_MDF_Approval_Stage__c =: inputWrap.approvalStage) OR (Core_MDF_Record_Type_Developer_Name__c='Core_MDF_Intel_Partner_Alliance' AND Core_MDF_Approval_Stage__c = NULL)) AND Core_MDF_Active__c = true];
            return customConfiqList;
        }
        
        public List<Core_MDF_Custom_Configuration__c> getEditCustomConfiqRecords(String objectName, String recTypeDevloperName, String status, List<String> budgetTypeList, string applicableDate){
            
            List<Core_MDF_Custom_Configuration__c> customConfiqList = [SELECT Core_MDF_Object_Name__c,Core_MDF_Record_Type_Developer_Name__c,Core_MDF_Field_Read_Write_Attributes__c,
                                                                       Core_MDF_Field_ReadOnly_Attributes__c,Core_MDF_Status__c,Core_MDF_Active__c,
                                                                       Core_MDF_Permission_Set_Api_Name__c,Core_MDF_Applicable_for_Past_Future__c,Core_MDF_Budget_Type__c 
                                                                       FROM Core_MDF_Custom_Configuration__c
                                                                       WHERE Core_MDF_Object_Name__c =:objectName 
                                                                       AND Core_MDF_Record_Type_Developer_Name__c =:recTypeDevloperName
                                                                       AND Core_MDF_Status__c =:status AND Core_MDF_Active__c = true                                                                   AND Core_MDF_Budget_Type__c IN:budgetTypeList 
                                                                       AND Core_MDF_Applicable_for_Past_Future__c =:applicableDate];
            
            return customConfiqList;
        }
        
    }
/****************************************************************************************************** 
    Method Name:        getNewCategoryValues
    @return       :     List of String
    @parameters   :     program
    Description   :     Method to get new activity categories from Core_MDF_ActivityCategoryMapping__c custom setting
    Added By:           Ayush - 9/9/2024 
    Modified By:        Date:      Changes: 
*******************************************************************************************************/	
	
    @auraEnabled
    public static List<String> getNewCategoryValues (String program){

        List<String> categoryValuesList = new List<String>();
        try{
            for(Core_MDF_ActivityCategoryMapping__c categoryMappingRecord : [SELECT Id, Core_MDF_Category_Name_txt__c 
                                                                             FROM Core_MDF_ActivityCategoryMapping__c 
                                                                             WHERE Core_MDF_Program_txt__c =: program
                                                                             AND Core_MDF_Is_Active_Ind__c = TRUE]){
                    categoryValuesList.add(categoryMappingRecord.Core_MDF_Category_Name_txt__c);       }    }  catch(Exception e){  Core_MDF_CCP_UtilityClass.logError(e);            throw e;
        }
        return categoryValuesList;
    }
/****************************************************************************************************** 
    Method Name:        validateApprovalClaimStatus
    @return       :     Boolean
    @parameters   :     activityId
    Description   :     For an In-Progress activity ,check whether the claim status is Pending Review
    Added By:           Ramapriya 8/8/2025
    Modified By:        Date:      Changes: 
*******************************************************************************************************/

    @AuraEnabled
    public static Boolean validateApprovalClaimStatus(Id activityId) {
        String PENDING_REVIEW_STATUS = 'Pending Review';
        boolean restrictedit=false;
        
        List<PartnerFundClaim> pendingClaims = [SELECT Id,Core_MDF_Status__c 
                                                FROM PartnerFundClaim
                                                WHERE RequestId = :activityId
                                                AND Core_MDF_Status__c = :PENDING_REVIEW_STATUS];
        
        
        if(!pendingClaims.isEmpty()){            restrictedit=true;
        }
        //returns true when the activity has claim in pending review status
        return restrictedit;
    }

@AuraEnabled(cacheable=true)
public static List<String> getCountryLabelsByRegion(String region, List<String> allowedCountryLabels) {
    List<String> results = new List<String>();
    
    if (String.isBlank(region)) {
        return allowedCountryLabels;
    }

    List<Core_MDF_CCP_Country_Geo_Mapping__mdt> maps = [
        SELECT MasterLabel 
        FROM Core_MDF_CCP_Country_Geo_Mapping__mdt
        WHERE MasterLabel IN :allowedCountryLabels 
          AND Core_MDF_Geo__c = :region
    ];

    for (Core_MDF_CCP_Country_Geo_Mapping__mdt m : maps) {
        results.add(m.MasterLabel);
    }

    return results;
}
    
    /*******************WW50 -BudgetType Benefit Mapping**************************/
    @AuraEnabled
    public static Map<string,string> getBudgetType(Id accId, String operation, String isProposalBased, String program){
        return Core_MDF_AccountABACheck.getBudgetType(accId, operation, isProposalBased, program);
    }
@AuraEnabled
public static Map<String, Object> analyzeDescriptionWithAI(String description, String recordTypeDeveloperName,Map<String, Object> picklistValues) {
    return Core_MDF_AiFieldSuggestions.analyzeDescriptionWithAI(description, recordTypeDeveloperName,picklistValues);
}
@AuraEnabled
public static Map<String, Object> analyzeFileWithAI(List<String> contentDocumentIds, String recordTypeDeveloperName,Map<String, Object> picklistValues) {
    return Core_MDF_AiFieldSuggestions.analyzeFileWithAI(contentDocumentIds, recordTypeDeveloperName,picklistValues);
}
@AuraEnabled
public static Map<String, Object> analyzeCombinedContent(String description, List<String> contentDocumentIds, String recordTypeDeveloperName,Map<String, Object> picklistValues) {
    return Core_MDF_AiFieldSuggestions.analyzeCombinedContent(description, contentDocumentIds, recordTypeDeveloperName,picklistValues);
}
@AuraEnabled
public static Map<String, Object> detectFocusAreaFromFile(List<String> contentDocumentIds) {
    return Core_MDF_AiFieldSuggestions.detectFocusAreaFromFile(contentDocumentIds);
}
@AuraEnabled
public static Boolean checkCurrentUserEmailForAI() {
    try {
        String currentUserEmail = UserInfo.getUserEmail();
        List<String> allowedEmailsList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_AI_Access_Settings');
        if (allowedEmailsList != null && !allowedEmailsList.isEmpty()) {
            Set<String> allowedEmails = new Set<String>();
            for (String emailString : allowedEmailsList) {
                if (String.isNotBlank(emailString)) {
                    String[] emails = emailString.split(';');
                    for (String email : emails) {
                        if (String.isNotBlank(email)) {
                            allowedEmails.add(email.trim().toLowerCase());
                        }
                    }
                }
            }
            if (allowedEmails.contains(currentUserEmail.toLowerCase())) {
                return true;
            }
        }
        return false;
    } catch (Exception e) {
        return false;
    }
}


@AuraEnabled
public static Boolean shouldShowRRBanner(String recordId) {
if (String.isBlank(recordId)) {return false;}
PartnerFundRequest pfr = [SELECT CreatedDate,Core_MDF_Program__c,Core_MDF_Is_Outcome_Based_Ind__c,Core_MDF_Activity_Level_nm__c,Core_MDF_Fund_Request_Status__c FROM PartnerFundRequest WHERE Id = :recordId LIMIT 1];
Datetime cutoffDate = Datetime.newInstanceGmt(2026,5,7,0,0,0);

    return
        pfr.Core_MDF_Fund_Request_Status__c != 'Cancelled' &&
        pfr.Core_MDF_Fund_Request_Status__c != 'Closed' &&
        pfr.Core_MDF_Fund_Request_Status__c != 'In-Progress' &&
        pfr.Core_MDF_Program__c == 'Intel Partner Alliance' &&
        pfr.Core_MDF_Is_Outcome_Based_Ind__c == true && 
        pfr.Core_MDF_Activity_Level_nm__c == 'Super Activity' &&
        pfr.CreatedDate < cutoffDate;
} 

// RR Banner Dynamic Date - Start
@AuraEnabled
public static String getRRBannerDate() {
    Date today = System.today(), nextPaymentDate;
    String jsonString = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Recovery_Notification_Mapping');

    List<Core_MDF_Recovery_Utility.RecoveryNotificationMapping> mappings =
        (List<Core_MDF_Recovery_Utility.RecoveryNotificationMapping>)JSON.deserialize(
            jsonString,
            List<Core_MDF_Recovery_Utility.RecoveryNotificationMapping>.class
        );

    List<Period> quarterPeriods = Core_MDF_Calendar_Utility.getFiscalQuarterWeekPeriods(today);

    for(Integer q = 0; q < 2 && nextPaymentDate == null; q++) {
        if(quarterPeriods.size() != 13) break;

        Map<String, Period> periodMap =
            Core_MDF_Calendar_Utility.mapMonthAndWeekPeriods(quarterPeriods);

        for(Core_MDF_Recovery_Utility.RecoveryNotificationMapping record : mappings) {
            if(record.program != 'Intel Partner Alliance') continue;

            Integer week = Integer.valueOf(record.weekAndDay.split(',')[0]);
            Integer dayOfWeek = Integer.valueOf(record.weekAndDay.split(',')[1]);

            for(String recordMonth : record.months.split(',')) {
                String key = 'M' + recordMonth + 'WW' + String.valueOf(week);

                if(periodMap.containsKey(key)) {
                    Date recoveryDate = Date.valueOf(periodMap.get(key).StartDate) + dayOfWeek;
                    Date paymentDate = recoveryDate.addDays(1);

                    if(paymentDate >= today &&
                       (nextPaymentDate == null || paymentDate < nextPaymentDate))
                        nextPaymentDate = paymentDate;
                }
            }
        }

        if(nextPaymentDate == null) {
            Date nextQuarterDate =
                quarterPeriods[quarterPeriods.size() - 1].EndDate.addDays(1);

            quarterPeriods =
                Core_MDF_Calendar_Utility.getFiscalQuarterWeekPeriods(nextQuarterDate);
        }
    }

    if(nextPaymentDate == null) return '';

    Date bannerDate = nextPaymentDate.addDays(-14);

    return Datetime.newInstance(
        bannerDate,
        Time.newInstance(0, 0, 0, 0)
    ).format('MMMM d, yyyy') + '.';
}
// RR Banner Dynamic Date - End Indu

@AuraEnabled
public static Boolean shouldShowIPAProposalEditWarning(String recordId) {if (String.isBlank(recordId)) {return false;}

    PartnerFundRequest pfr = [SELECT CreatedDate,RecordType.DeveloperName,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Is_Outcome_Based_Ind__c FROM PartnerFundRequest WHERE Id = :recordId LIMIT 1];
    Date cutoffDate = Date.valueOf(IPA_PROPOSAL_GO_LIVE_DATE);
    Datetime cutoffDateTime = Datetime.newInstanceGmt(cutoffDate.year(),cutoffDate.month(),cutoffDate.day(),0,0,0);
    return
        pfr.RecordType.DeveloperName ==Core_MDF_CustomLabelConfig.getTextValues(
                'Core_MDF_IPA_RecordType'
            ) && pfr.Core_MDF_Proposal_Based_Ind__c == true && pfr.CreatedDate < cutoffDateTime;}


    @AuraEnabled
    public static void saveAiTrackingRecords(Id activityId, String trackingEntriesJson) {
        if (String.isBlank(trackingEntriesJson)) {
            return;
        }
        try {
            List<Object> entries = (List<Object>)JSON.deserializeUntyped(trackingEntriesJson);
            if (entries == null || entries.isEmpty()) {
                return;
            }
            PartnerFundRequest pfr = null;
            if (activityId != null) {
                List<PartnerFundRequest> pfrs = [SELECT Id, Core_MDF_Approval_Stage__c FROM PartnerFundRequest WHERE Id = :activityId LIMIT 1];
                if (!pfrs.isEmpty()) {
                    pfr = pfrs[0];
                }
            }
            Core_MDF_AITrackingService.saveTracking(activityId, entries, pfr);
        } catch (Exception e) {
        }
    }
@AuraEnabled
    public static Account resolveAccountByAIName(String accountName, String recordTypeDeveloperName) {
        if (String.isBlank(accountName)) {
            return null;
        }
        if (!isCustomPermissionAssigned('Core_MDF_CCP_Internal_IPA_Acct_Mgr')) {
            return null;
        }
        String searchName = '%' + accountName.trim() + '%';
        String ipaTechnicalProgramName = Label.Core_MDF_IPA_Technical_program_name;
        String ipaRecordType = Label.Core_MDF_IPA_RecordType;
        List<Account> matches;
        if (String.isNotBlank(recordTypeDeveloperName) && recordTypeDeveloperName == ipaRecordType) {
            matches = [SELECT Id, Name, Core_MDF_CoMarketing_Ultimate_Account__c FROM Account WHERE Name LIKE :searchName AND RecordType.DeveloperName = 'Core_MDF_Co_Marketing' AND isPartner = true AND Core_MDF_Active_Ind__c = true AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c = :ipaTechnicalProgramName LIMIT 1];
        } else {
            matches = [SELECT Id, Name, Core_MDF_CoMarketing_Ultimate_Account__c FROM Account WHERE Name LIKE :searchName LIMIT 1];
        }
        return matches.isEmpty() ? null : matches[0];
    }
    /*Ramapriya - Commented as part of TWC702-16422
    @AuraEnabled
    //Added by Ramapriya for Partner Contact field to fetch domain mapping for respective account
    public static List<Core_MDF_Partner_Group_Domain_Mapping__c> getDomainsForAccount(String accountId) {
        if (String.isBlank(accountId)) {
            return new List<Core_MDF_Partner_Group_Domain_Mapping__c>();
        }
        List<Account> accounts = [SELECT Id, Core_MDF_Virtual_Corp_Account_Id__c
                                   FROM Account WHERE Id = :accountId LIMIT 1];
        String resolvedId = (!accounts.isEmpty() && accounts[0].Core_MDF_Virtual_Corp_Account_Id__c != null)
                            ? accounts[0].Core_MDF_Virtual_Corp_Account_Id__c
                            : accountId;
        return new DomainQueryHelper().fetchDomainsForAccount(resolvedId);
    }

    private without sharing class DomainQueryHelper {
        private List<Core_MDF_Partner_Group_Domain_Mapping__c> fetchDomainsForAccount(String accountId) {
            return [SELECT Name FROM Core_MDF_Partner_Group_Domain_Mapping__c
                    WHERE Core_MDF_Partner_Group_Mapping_Id__r.Core_MDF_Virtual_Corp_nm__c = :accountId
                    AND Core_MDF_Active_Ind__c = true];
        }
    }*/
}