public without sharing class Core_MDF_BulkPOPUploadController {
	@AuraEnabled
    public static List<Core_MDF_Claim_Batch_Stage__c> fetchPendingDocumentsRecords(Id clmBatchId) {
        List<Core_MDF_Claim_Batch_Stage__c> clmBatchStgRecList = new List<Core_MDF_Claim_Batch_Stage__c>();
        clmBatchStgRecList = [SELECT Id,Name,Core_MDF_Claim_Nm__c, Core_MDF_Activity_Nbr__c,Core_MDF_Ad_Run_Start_Dt__c, 
                              Core_MDF_Ad_Run_End_Dt__c,Core_MDF_Country_Location_nm__c,Core_MDF_Inv_Receipt_Cur_Cd__c,Core_MDF_Ultimate_Account_Txt__c,Core_MDF_Program_Txt__c,
                              Core_MDF_Total_Amt__c,Core_MDF_Non_Reimbursable_Amt__c,Core_MDF_Upload_POP_Document__c,Core_MDF_Ultimate_Account_ID__c,Core_MDF_Budget_Type_Nm__c,
                              Core_MDF_Batch_ID__r.Core_MDF_Program_Id__r.Name,Core_MDF_Request_Id__c,Core_MDF_Bank_Id__c, Core_MDF_Bank_Id__r.Name,Core_MDF_Node_Account_Txt__c,
                              Core_MDF_Media_Vehicle_txt__c,Core_MDF_Impressions_Cnt__c,Core_MDF_Inv_Receipt_Dt__c,Core_MDF_Reimbursement_Percent_Nbr__c,Core_MDF_VAT_Opt_In__c,Core_MDF_Applicable_VAT_Percentage_nm__c,
                              Core_MDF_Inv_Receipt_Nbr__c, Core_MDF_Taxes_Local_Amt__c, Core_MDF_Claim_Comment_txt__c,Core_MDF_ActivityCategory__c,
                              Core_MDF_Batch_ID__r.Name,Core_MDF_Is_Duplicate_ind__c,Core_MDF_Create_Duplicate_ind__c,Core_MDF_Activity_Type_Nm__c, Core_MDF_Activity_SubType_nm__c
                              FROM Core_MDF_Claim_Batch_Stage__c 
                              WHERE Core_MDF_Batch_ID__c =: clmBatchId
                             AND Core_MDF_Processing_Status_Nm__c =: Label.Core_MDF_Status_PendingDocuments]; 
      
        return clmBatchStgRecList;
    }
    
    @AuraEnabled
    public static PartnerFundRequest fetchActivityDetails(String activityNbr) {
        PartnerFundRequest activity = new  PartnerFundRequest();
        return activity = [SELECT Id, Core_MDF_Budget_Type_nm__c FROM PartnerFundRequest WHERE Core_MDF_Activity_Number__c =: activityNbr LIMIT 1];
    }
    
    @AuraEnabled
    public static string saveClaim(Core_MDF_Claim_Batch_Stage__c claimBatchRec, List<Core_MDF_Audit_Document__c> auditDocList){
       
        try{
            if(claimBatchRec.id!=null && auditDocList!=null && auditDocList.size()>0){
                assignDocumentList(auditDocList,claimBatchRec.Id); 
                }
                claimBatchRec.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Status_Submitted;
            List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();
            list<Core_MDF_Claim_Batch_Stage__c> claimBatchRecList = new list<Core_MDF_Claim_Batch_Stage__c>();
            claimBatchRecList.add(claimBatchRec);
            //Added to stop recurssion
            Core_MDF_ClaimStage_TriggerHandler.recursiveCheckStopAfterUpdate = true;
            
            //Update 3rd Party indicator and Log informations.
            Core_MDF_Claim_Batch_Stage__c claimBatchStage = new Core_MDF_Claim_Batch_Stage__c(Id = claimBatchRec.Id, Core_MDF_3rd_Party_POP_Doc_Required_Ind__c = claimBatchRec.Core_MDF_3rd_Party_POP_Doc_Required_Ind__c, Core_MDF_Log_Info_txt__c = claimBatchRec.Core_MDF_Log_Info_txt__c);
            update claimBatchStage;
            
            // Get the Claim Object List From the ClaimStage List as Input
            List<PartnerFundClaim> getBulkOfClaims = Core_MDF_BatchClaimHelper.mapStageRecordsToClaim(claimBatchRecList);
            // call the function to check whether the ClaimList contains duplicates
            Core_MDF_ClaimStage_ServiceHandler.stageAndClaimRecWrapper wrapInstance = new Core_MDF_ClaimStage_ServiceHandler.stageAndClaimRecWrapper();
            wrapInstance = Core_MDF_ClaimStage_ServiceHandler.handleDuplicateClaimsOnUpdate(getBulkOfClaims,wrapInstance);
            // to insert claims and update stage records
           Core_MDF_BatchClaimHelper.insertClaimsAndUpdateClaimStageRecords(wrapInstance);
            return 'Success';
        }catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            return 'Exception: '+e.getMessage();            
        }
    }
    /****************************************************************************************************** 
    Method Name:        assignDocumentList
    @return  :          boolean
    @parameters:        auditDocList and claimId
    Description:        This method is used to assignDocumentList to claimId .
    Added By:           Intel - Areefa - 15 Oct 2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public static boolean assignDocumentList(List<Core_MDF_Audit_Document__c> auditDocList,Id linkedEntityId) {
        try {
            //list of content document link to be insert/update
            List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();
            if(auditDocList != null && auditDocList.size() >0){
                for(Core_MDF_Audit_Document__c auditDoc : auditDocList){
                    //ContentDocumentLink instance will not be created , if record already exists
                    //if(String.isBlank(auditDoc.Core_MDF_Claim__c)){
                        ContentDocumentLink conDocLink = new ContentDocumentLink();
                        //auditDoc.Core_MDF_Claim_Batch_Record__c = claimBatchRec.Id;
                        String entityId = linkedEntityId.to15();
                        if(entityId.startsWith('a4N')) {
                            auditDoc.Core_MDF_Claim_Batch_Record__c = linkedEntityId;
                        } else {
                            auditDoc.Core_MDF_Claim__c = linkedEntityId;
                        }
                         
                        //Documents uploaded during claim edit should be attached over case as well.
                       /* if(claim.Core_MDF_Claim_Review_Case__c!=null){
                            auditDoc.Core_MDF_Audit__c = claim.Core_MDF_Claim_Review_Case__c;
                        }*/
                        conDocLink.ContentDocumentId = auditDoc.Core_MDF_Document_Id__c;    // documentId
                        conDocLink.LinkedEntityId = linkedEntityId;          //LinkedEntityId: attaching to ClaimId or Claim stage Id
                        conDocLink.ShareType='I';
                        conDocLink.Visibility='AllUsers';
                        contentDocLinkList.add(conDocLink);
                   // }
                }
                if(auditDocList != null && auditDocList.size() > 0){
                    Database.upsert(auditDocList); 
                }
                if(contentDocLinkList.size()>0){
                    Database.upsert(contentDocLinkList);
                }
                return true;
            }else { return false;}            
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
        
    }
    
    /****************************************************************************************************** 
    Method Name:        showModalForDocSubmissionConfirmation
    @return  :          boolean
    Description:        This method is used to decide whether the confirm modal popup is disabled/enabled
    Added By:           Vinodhini - 25 Nov 2021
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    @AuraEnabled
    public  static Boolean showModalForDocSubmissionConfirmation() {
         Core_MDF_Configuration__c config = Core_MDF_Configuration__c.getValues('Core_MDF_DocUploadConfirm');

        if(config.Core_MDF_Value__c == 'true') {


            return true;
        } else {
            return false;
        }
    }
    
/****************************************************************************************************** 
    Method Name:        createClaimInstanceAction
    @return  :          boolean
    Description:        This method is used to create Claim Instance
    Added By:           Accenture-NK - 24-01-2022
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    @AuraEnabled
    public  static List<PartnerFundClaim> createClaimInstanceAction(List<Core_MDF_Claim_Batch_Stage__c> stageList) {
     
        List<PartnerFundClaim> claimInstanceList = Core_MDF_BatchClaimHelper.mapStageRecordsToClaim(stageList);
      
        return claimInstanceList;
    }

    /****************************************************************************************************** 
    Method Name:        fetchLogInfoByPassCheckValue
    @return  :          boolean
    Description:        This method is used to fetch the 3rd party by-pass value to add a value in the Core_MDF_Log_Info_txt__c field or not.
    Added By:           Accenture - JB      07/05/2022
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    @AuraEnabled
    public static Boolean fetchLogInfoByPassCheckValue(){
        return Core_MDF_Utility.byPassFeature('Bypass_LogInfoTextFieldMapping');
    }
}