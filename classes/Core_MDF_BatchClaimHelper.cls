public without sharing class Core_MDF_BatchClaimHelper {    
    public static List<Core_MDF_CCP_Custom_Metadata_Utility__c> metadataRecordList;
    public static Core_MDF_Claim_Batch__c batch;
    public static List<Core_MDF_Claim_Batch_Stage__c> stageClaimRecs;
    public static Map<String,PartnerFundRequest> activityNumberToPfrMap;
    //Jk - New Vat Process changes 
    public static String vatApplicable = Label.Core_MDF_nonTranslate_Service_Invoice_to_Intel;
    public static String nonVatApplicable = Label.Core_MDF_nonTranslate_Reimbursement_Request_for_3rd_party_payment;
    
    /************************************************************************************************************ 
Method Name:         preventDeleteWhenClaimInSuccessStatus
Description:         Method to Prevent Delete on the Claim Batch Stage Records if the Claim status is not equal to 'Failed'
@Added By:           Intel      - Areefa - 28-03-2019
Modified By:         Date:      - Changes: 
*************************************************************************************************************/ 
    public static void preventDeleteWhenClaimInSuccessStatus(List<Core_MDF_Claim_Batch_Stage__c> oldClaimStageList) {
        for(Core_MDF_Claim_Batch_Stage__c claimBatchRec: oldClaimStageList){
            if(claimBatchRec.Core_MDF_Processing_Status_Nm__c <> System.Label.Core_MDF_Claim_Batch_Failed) 
            {
                claimBatchRec.addError(system.Label.Core_MDF_Claim_Cannot_BeDeleted);
            } 
        }
    }
    
    
    
    /************************************************************************************************************ 
Method Name:        getListofClaims
@return  :          List<PartnerFundClaim>
@parameters:        List<Core_MDF_Claim_Batch_Stage__c> List of stage claims
Description:        This method will return the list of claims to be created                      
Added By:           Intel  - Areefa - 29/03/2019
Modified By:        Date:       Changes: 
Accenture - JV      4/7/2019    Dynamically Mapping the Stage and Claim Records based on Cutom Metadata
*************************************************************************************************************/
/*******************************************************************************************************************************
    Moved from Custom Metadata (Core_MDF_BulkClaimTemplateParticulars__mdt) to Custom Object (Core_MDF_CCP_Custom_Metadata_Utility__c)
        Below are the field Mapping :
        DeveloperName --> Name
        Core_MDF_Channel_program__c --> Core_MDF_Program__c
        Core_MDF_Claim_Field_API_Name__c --> Core_MDF_Name_Criteria__c
        Core_MDF_Column_Index__c --> Core_MDF_Sort_Order_Nbr__c
        Core_MDF_Field_DataType_Txt__c --> Core_MDF_Field_1_txt__c
        Core_MDF_Stage_Field_API_Name__c --> Core_MDF_Field_2_txt__c
        Core_MDF_Stage_Required_Ind__c --> Core_MDF_Checkbox_Field_1_Ind__c
        Core_MDF_Target_Field_API_Name__c --> Core_MDF_Field_3_txt__c
        Core_MDF_Upload_Record_Type__c --> Core_MDF_Sub_Category__c
        
        To Identity the Bulk Claim records in Core_MDF_CCP_Custom_Metadata_Utility__c Custom object used Core_MDF_Category__c
        Core_MDF_Category__c---> "Bulk Claim Template"
*********************************************************************************************************************************/

    public static List<PartnerFundClaim> mapStageRecordsToClaim(List<Core_MDF_Claim_Batch_Stage__c> stageClaimRecs){
        Set<Id> claimbatchIds = new Set<Id>();
        Map<Id,Core_MDF_Claim_Batch__c> claimbatchMaps = new Map<Id,Core_MDF_Claim_Batch__c>();
        Set<String> claimPrograms = new Set<String>();
        Map<Id,PartnerFundRequest> pfrMap;
        Map<Id,Core_MDF_Bank__c> bankMap;
        Set<Id> pfrIdSet = new set<Id>();
        Set<Id> bankIdSet = new set<Id>();
        string bankLE420 = Core_MDF_CCP_ConstantClass.Bank_LE420;
        string bankLE650 = Core_MDF_CCP_ConstantClass.Bank_LE650;

        for(Core_MDF_Claim_Batch_Stage__c claimBatchStg:stageClaimRecs) {
            claimbatchIds.add(claimBatchStg.Core_MDF_Batch_ID__c);
            pfrIdSet.add(claimBatchStg.Core_MDF_Request_Id__c);
            bankIdSet.add(claimBatchStg.Core_MDF_Bank_Id__c);
        }   
        
        if(pfrIdSet!= null && pfrIdSet.size()>0){
            pfrMap = new Map<Id,PartnerFundRequest>([Select id,Core_MDF_Country_nm__c from PartnerFundRequest where id IN : pfrIdSet]);
        }
        if(bankIdSet != null && bankIdSet.size()>0)
        {
            bankMap = new Map<Id,Core_MDF_Bank__c>([Select Id,Core_MDF_Vat_pct__c,Core_MDF_Intel_Company_Code__c from Core_MDF_Bank__c where Id IN : bankIdSet]);
        }
        
        if(claimbatchIds != null && claimbatchIds.size()>0){
            for(Core_MDF_Claim_Batch__c batchRec:[SELECT Id,Name,Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c FROM Core_MDF_Claim_Batch__c WHERE Id IN:claimbatchIds]) {
                claimbatchMaps.put(batchRec.Id,batchRec);
                claimPrograms.add(batchRec.Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c);
            }
        }
        
        /*Map<String,List<Core_MDF_BulkClaimTemplateParticulars__mdt>> progToMetadataRecordsMap = new Map<String,List<Core_MDF_BulkClaimTemplateParticulars__mdt>>();
        for(Core_MDF_BulkClaimTemplateParticulars__mdt metadataRec:[SELECT Id,Core_MDF_Stage_Field_API_Name__c,Core_MDF_Field_DataType_Txt__c,Core_MDF_Column_Index__c,
                                                                    Core_MDF_Target_Field_API_Name__c, Core_MDF_Stage_Required_Ind__c,Core_MDF_Channel_program__c
                                                                    FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                                                    WHERE Core_MDF_Channel_program__c IN:claimPrograms
                                                                    AND Core_MDF_Upload_Record_Type__c =: Label.Core_MDF_PFCText]) {
                                                                        if(progToMetadataRecordsMap.containsKey(metadataRec.Core_MDF_Channel_program__c)) {
                                                                            progToMetadataRecordsMap.get(metadataRec.Core_MDF_Channel_program__c).add(metadataRec);
                                                                        }
                                                                        else {
                                                                            progToMetadataRecordsMap.put(metadataRec.Core_MDF_Channel_program__c,new List<Core_MDF_BulkClaimTemplateParticulars__mdt>{metadataRec});
                                                                        }                                                                      
                                                                    }*/

        Map<String,List<Core_MDF_CCP_Custom_Metadata_Utility__c>> progToMetadataRecordsMap = new Map<String,List<Core_MDF_CCP_Custom_Metadata_Utility__c>>();
        for(Core_MDF_CCP_Custom_Metadata_Utility__c metadataRec:[SELECT Id,Core_MDF_Field_2_txt__c,Core_MDF_Field_1_txt__c,Core_MDF_Sort_Order_Nbr__c, Core_MDF_Field_3_txt__c, Core_MDF_Checkbox_Field_1_Ind__c,Core_MDF_Program__c FROM Core_MDF_CCP_Custom_Metadata_Utility__c WHERE Core_MDF_Program__c IN:claimPrograms AND Core_MDF_Sub_Category__c =: Label.Core_MDF_PFCText AND Core_MDF_Category__c =: Core_MDF_CCP_ConstantClass.BULK_CLAIM_TEMPLATE]) {
                                                                        if(progToMetadataRecordsMap.containsKey(metadataRec.Core_MDF_Program__c)) {
                                                                            progToMetadataRecordsMap.get(metadataRec.Core_MDF_Program__c).add(metadataRec);
                                                                        }
                                                                        else {
                                                                            progToMetadataRecordsMap.put(metadataRec.Core_MDF_Program__c,new List<Core_MDF_CCP_Custom_Metadata_Utility__c>{metadataRec});
                                                                        }                                                                      
                                                                    }
    
        
        List<PartnerFundClaim>  claimRecords = new List<PartnerFundClaim>();
        if(stageClaimRecs != NULL && stageClaimRecs.size() > 0)
        {
            // Roshan - Populate Processing Preference on Claim based on Today's Date
            Date claimDate = System.today();
            // Core_MDF_PartnerFundClaim.PayTypeWrapper payType = Core_MDF_PartnerFundClaim.getDefaultPayTypePicklist(claimDate);
            // String processingPreference = payType.surePay ? Label.Core_MDF_nonTranslate_Sure_Pay : Label.Core_MDF_nonTranslate_Fast_Pay;
            
            for(Core_MDF_Claim_Batch_Stage__c stageClaim: stageClaimRecs)
            {   

                String program = stageClaim.Core_MDF_Program_Txt__c;
                String budgetType = stageClaim.Core_MDF_Budget_Type_Nm__c;
                Core_MDF_PartnerFundClaim.PayTypeWrapper payType = Core_MDF_PartnerFundClaim.getDefaultPayTypePicklist(claimDate, program, budgetType);
                String processingPreference = payType.surePay ? Label.Core_MDF_nonTranslate_Sure_Pay : Label.Core_MDF_nonTranslate_Fast_Pay;

                //if(stageClaim.Core_MDF_Processing_Status_Nm__c != Label.Core_MDF_Claim_Batch_Failed) 
                if(stageClaim.Core_MDF_Processing_Status_Nm__c == Label.Core_MDF_Status_Submitted)
                {
                    PartnerFundClaim pfc = new PartnerFundClaim();
                    List<String> stageFieldsNotToBeMappedWithClaim = Label.Core_MDF_StageFieldsNotToBeMapped.split(',');
                    for(Core_MDF_CCP_Custom_Metadata_Utility__c metadataRecord:progToMetadataRecordsMap.get(claimbatchMaps.get(stageClaim.Core_MDF_Batch_ID__c).Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c))
                    {
                        if(!stageFieldsNotToBeMappedWithClaim.contains(metadataRecord.Core_MDF_Field_2_txt__c)){
                            pfc.put(metadataRecord.Core_MDF_Field_3_txt__c,stageClaim.get(metadataRecord.Core_MDF_Field_2_txt__c));
                        }
                    }

                    pfc.RequestId = stageClaim.Core_MDF_Request_Id__c;
                    pfc.Core_MDF_Bank__c =  stageClaim.Core_MDF_Bank_Id__c;
                    if(bankMap.containsKey(stageClaim.Core_MDF_Bank_Id__c) && 
                       bankMap.get(stageClaim.Core_MDF_Bank_Id__c).Core_MDF_Intel_Company_Code__c == bankLE420 && 
                       stageClaim.Core_MDF_VAT_Opt_In__c == vatApplicable)	
                    {
                        pfc.Core_MDF_Applicable_VAT_Percentage_nm__c = bankMap.get(stageClaim.Core_MDF_Bank_Id__c).Core_MDF_VAT_pct__c;
                    }
		    // for 650 LE code bank 
                    if(bankMap.containsKey(stageClaim.Core_MDF_Bank_Id__c) && 
                       bankMap.get(stageClaim.Core_MDF_Bank_Id__c).Core_MDF_Intel_Company_Code__c == bankLE650)
                    {
                        pfc.Core_MDF_Applicable_VAT_Percentage_nm__c = stageClaim.Core_MDF_VAT_Opt_In__c == vatApplicable ? '10': stageClaim.Core_MDF_VAT_Opt_In__c == nonVatApplicable ?'0':'';
                    }
                    
                    pfc.Core_MDF_Claim_Batch_Stage__c = stageClaim.Id;
                    pfc.Core_MDF_Batch_Nbr__c = claimbatchMaps.get(stageClaim.Core_MDF_Batch_ID__c).Name;
                    if(pfc.Core_MDF_Country_Location_nm__c == null && stageClaim.Core_MDF_Country_Location_nm__c != null){
                        pfc.Core_MDF_Country_Location_nm__c = stageClaim.Core_MDF_Country_Location_nm__c;
                    }
                    if(stageClaim.Core_MDF_Review_Hold_Rule_Nm__c != null){
                        pfc.Core_MDF_Review_Hold_Rule_Nm__c =stageClaim.Core_MDF_Review_Hold_Rule_Nm__c;
                    }
                    if(stageClaim.Core_MDF_3rd_Party_POP_Doc_Required_Ind__c!=null){
                        pfc.Core_MDF_3rd_Party_POP_Doc_Required_Ind__c = stageClaim.Core_MDF_3rd_Party_POP_Doc_Required_Ind__c;
                    }

                    if(stageClaim.Core_MDF_Log_Info_txt__c != null){
                        pfc.Core_MDF_Log_Info_txt__c = stageClaim.Core_MDF_Log_Info_txt__c;
                    }

                    if(stageClaim.Core_MDF_Program_Txt__c == Label.Core_MDF_Retail_Program_Name && stageClaim.Core_MDF_Activity_SubType_nm__c!=null){
                        pfc.Core_MDF_Activity_SubType_nm__c = stageClaim.Core_MDF_Activity_SubType_nm__c;
                    }
                    // Avoid claim submitter, if execute in external user context.
                    if(UserInfo.getUserType() != 'PowerPartner') {
                        pfc.Core_MDF_Claim_Submitter_Id__c =stageClaim.CreatedById;//added by vaishali to update claim owner as claim submitter
                    }
                    if(stageClaim.Core_MDF_Budget_Type_Nm__c!=null){
                        pfc.Core_MDF_Budget_Type_Options_Nm__c = stageClaim.Core_MDF_Budget_Type_Nm__c;
                    }

                    // Roshan - TWC3117-11893 Bulk claims going into Submitted status when edited after PIC is Passed
                    pfc.Core_MDF_Taxes_Local__c = (stageClaim.Core_MDF_Taxes_Local_Amt__c == null) ? 0 : stageClaim.Core_MDF_Taxes_Local_Amt__c;
                    
                    // Roshan - Populate Processing Preference on Claim based on Today's Date
                    pfc.Core_MDF_Processing_Preference_nm__c = processingPreference;

                    claimRecords.add(pfc);
                }
            }       
        }
        return claimRecords;        
    }
    
    /************************************************************************************************************ 
Method Name:        isClaimStageRecordEdited
@return  :          Boolean
@parameters:        newClaimStageRecord,oldClaimStageMap,lstBulkUploadMappings
Description:        To check whether the incoming claimstage record is edited or not
Added By:           Accenture  - JV - 07/04/2019
Modified By:        Date:       Changes: 
*************************************************************************************************************/
    public static Boolean isClaimStageRecordEdited(Core_MDF_Claim_Batch_Stage__c newClaimStageRecord, Map<Id,Core_MDF_Claim_Batch_Stage__c> oldClaimStageMap,List<Core_MDF_CCP_Custom_Metadata_Utility__c> lstBulkUploadMappings)
    {
        Boolean isEdited = FALSE;
        for(Core_MDF_CCP_Custom_Metadata_Utility__c mdtRecord : lstBulkUploadMappings){
            if( oldClaimStageMap!=null && oldClaimStageMap.get(newClaimStageRecord.Id)!=null
               && (newClaimStageRecord.get(mdtRecord.Core_MDF_Field_2_txt__c) != (oldClaimStageMap.get(newClaimStageRecord.Id).get(mdtRecord.Core_MDF_Field_2_txt__c)))
              ){
                  isEdited = TRUE;
                  break;
              }
        }
        // check if "Create Duplicate" check box was set by the User or not:
        if(newClaimStageRecord.Core_MDF_Create_Duplicate_ind__c == TRUE && oldClaimStageMap.get(newClaimStageRecord.Id).Core_MDF_Create_Duplicate_ind__c == FALSE){
            isEdited = TRUE;
        }
        // check if "Retry Indicatior" check box was set by the User or not://sarah's poc, not needed anymore, so commented
        /*if(newClaimStageRecord.Core_MDF_Retry_Ind__c == TRUE && oldClaimStageMap.get(newClaimStageRecord.Id).Core_MDF_Retry_Ind__c == FALSE){
isEdited = TRUE;
}*/
        if(isEdited){
            return TRUE;
        }else{return FALSE;}
    }
    
    /************************************************************************************************************ 
Method Name:        insertClaimsAndUpdateClaimStageRecords
@return  :          Boolean
@parameters:        Claims List to be inserted
Description:        This method is used to Insert the Claims And Updated the Corresponding claim stage records with the proper status
Added By:           Accenture  - JV - 07/04/2019
Modified By:        Date:       Changes: 
*************************************************************************************************************/
    public static void insertClaimsAndUpdateClaimStageRecords(Core_MDF_ClaimStage_ServiceHandler.stageAndClaimRecWrapper wrapperInst)
    {        
        Set<Id> succesRecordIdSet = new Set<Id>();
        List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
        Map<Id,PartnerFundClaim> successClaimMap = new Map<Id,PartnerFundClaim>();
        List<PartnerFundClaim> failedClaims = new List<PartnerFundClaim>();
        List<PartnerFundRequest> pfrToBeUpdated = new List<PartnerFundRequest>();
        List<Core_MDF_Claim_Batch_Stage__c> stageRecordsToUpdate = new List<Core_MDF_Claim_Batch_Stage__c>();
        Map<PartnerFundClaim,Id> claimToClaimStageIdMap = new Map<PartnerFundClaim,Id>();
        Map<PartnerFundClaim,Id> successClaimToClaimStageIdMap = new Map<PartnerFundClaim,Id>();
        Set<Id> failedPFR = new Set<Id>();
        
        try{
            //for(PartnerFundClaim pfc : claims){
            for(PartnerFundClaim pfc : wrapperInst.nonduplicateClaims){
                if(pfc.Id == null){
                    claimList.add(pfc);
                }
            }

            //check for batch limit to check and retry.
            //null check for claims
            if(claimList!=null && claimList.size()>0)//
            {     
                List<Core_MDF_Claim_Batch_Stage__c> successfulStageRecords = new List<Core_MDF_Claim_Batch_Stage__c>();
                List<Core_MDF_Claim_Batch_Stage__c> failedStageRecords = new List<Core_MDF_Claim_Batch_Stage__c>();
                if(claimList != NULL && claimList.size() > 0){
                    Database.SaveResult[] result = Database.insert(claimList, false);
                    
                    for (Database.SaveResult sr : result) {
                        if (sr.isSuccess()) {
                            succesRecordIdSet.add(sr.getId());
                        }
                    }

                    successClaimMap = new Map<Id,PartnerFundClaim>([Select Id,Core_MDF_Claim_Batch_Stage__c, Core_MDF_Claim_Ref_Number__c, RequestId, Request.Status,
                                                                    Request.Core_MDF_Fund_Request_Status__c, Core_MDF_Budget_Type_Nm__c, Core_MDF_Program__c, Core_MDF_OutcomeBased_Ind__c, Core_MDF_3rd_Party_POP_Doc_Required_Ind__c,
                                                                    Core_MDF_Ad_Run_Start_Date__c, Core_MDF_Ad_Run_End_Date__c, Core_MDF_Reimbursable_TransactionAmt_Loc__c, Core_MDF_Total_Invoice_Amount_Local__c, Core_MDF_Currency__c,
                                                                    Core_MDF_Activity_Types__c FROM PartnerFundClaim where ID IN :succesRecordIdSet]);//query updated for AI PIC
                    
                    for(PartnerFundClaim claim : successClaimMap.values()){
                        successClaimToClaimStageIdMap.put(claim,claim.Core_MDF_Claim_Batch_Stage__c);
                    }
                    for(PartnerFundClaim claim : claimList)
                    {
                        claimToClaimStageIdMap.put(claim,claim.Core_MDF_Claim_Batch_Stage__c);
                    }

                    for(Integer index=0;index<result.size();index++){
                        if (result[index].isSuccess()){
                            ID stageid = successClaimToClaimStageIdMap.get(successClaimMap.get(result[index].getId()));//success record from the list
                            Core_MDF_Claim_Batch_Stage__c stageRecord = new Core_MDF_Claim_Batch_Stage__c();
                            stageRecord.ID = stageid;
                            stageRecord.Core_MDF_Claim_Reference_Nbr__c = successClaimMap.get(result[index].getId()).Core_MDF_Claim_Ref_Number__c;
                            stageRecord.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Successful;
                            stageRecord.Core_MDF_Message_txt__c =''; //added by Vaishali to wipe off comment once it is successful
                            stageRecord.Core_MDF_Failure_Reason_Txt__c ='';
                            successfulStageRecords.add(stageRecord);

                        }
                        else {                             
                            //start vaishali -
                            Database.Error errorMsg = result[index].getErrors()[0];
                            String errorCode = String.valueOf(errorMsg.getStatusCode());
                            failedPFR.add(claimList.get(index).RequestId);
                            
                            ID stageid = claimList.get(index).Core_MDF_Claim_Batch_Stage__c;
                            Core_MDF_Claim_Batch_Stage__c stageRecord = new Core_MDF_Claim_Batch_Stage__c();
                            stageRecord.ID = stageid;
                            
                            //user exception or custom exception
                            if((Label.Core_MDF_UserExceptionErrorCode).contains(errorCode)){
                                String errorMessage = errorMsg.getMessage();  
                                stageRecord.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Failed;                            
                                stageRecord.Core_MDF_Message_txt__c =  errorMessage;//Confirmed with Amal we can override message earlier we were appending messages
                                stageRecord.Core_MDF_Failure_Reason_Txt__c ='';
                            }
                            //system exception
                            else{                                
                                String errorMessage = errorMsg.getMessage();
                                stageRecord.Core_MDF_Message_txt__c ='';
                                stageRecord.Core_MDF_Failure_Reason_Txt__c = errorMessage; 
                                stageRecord.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Status_Submitted;
                            }
                            failedStageRecords.add(stageRecord);
                            //end - vaishali
                        } 
                    }
                    
                    stageRecordsToUpdate.addAll(successfulStageRecords);
                    stageRecordsToUpdate.addAll(failedStageRecords);
                    //Move it outside the if block
                    //  stageRecordsToUpdate.addAll(wrapperInst.failedStageRecordsList);
                    //Move it outside the if block
                    //  Database.update(stageRecordsToUpdate);
                    
                    Map<Id, List<PartnerFundClaim>> pfrClaimMap = new Map<Id,List<PartnerFundClaim>>();
                    Map<Id, String> pfrStatusMap = new Map<Id, String>();
                    Map<Id, String> pfrBudgetMap = new Map<Id, String>();
                    //to get pfr status when no claims are inserted
                    for(PartnerFundRequest pfr : [Select Core_MDF_Fund_Request_Status__c, Status, Id, Core_MDF_Budget_Type_nm__c from PartnerFundRequest where Id in :failedPFR])
                    {
                        pfrStatusMap.put(pfr.Id, pfr.Status);
                        pfrBudgetMap.put(pfr.Id, pfr.Core_MDF_Budget_Type_nm__c);
                    }
                    for(PartnerFundClaim claim : [Select RequestId, Id from PartnerFundClaim where RequestId IN :failedPFR])
                    {
                        if(pfrClaimMap.containsKey(claim.RequestId)){
                            pfrClaimMap.get(claim.RequestId).add(claim);
                        }
                        else{
                            pfrClaimMap.put(claim.RequestId, new List<PartnerFundClaim>{claim});
                        }
                    }
                   
                    if(failedPFR!=null && failedPFR.size()>0)
                    {
                        for(Id pfrID : failedPFR)
                        {
                            if(!pfrClaimMap.containsKey(pfrID) && pfrStatusMap.get(pfrID)=='Approved' && !Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MDF_BudgetTypes').contains(pfrBudgetMap.get(pfrID)))
                            {
                                pfrToBeUpdated.add(new PartnerFundRequest(Id = pfrID, Status= 'Draft'));
                            }
                        }
                    }
                    if(pfrToBeUpdated != null && pfrToBeUpdated.size() > 0)
                    {
                        Database.Update(pfrToBeUpdated);   
                    }                    
                }
            }  
            if(wrapperInst.failedStageRecordsList != null && wrapperInst.failedStageRecordsList.size()>0){
                stageRecordsToUpdate.addAll(wrapperInst.failedStageRecordsList);//failed duplicate records
            }

            Database.update(stageRecordsToUpdate);
            if(succesRecordIdSet != null && succesRecordIdSet.size()>0){
                Map<Id, List<Core_MDF_Audit_Document__c>> auditList = new map<id, List<Core_MDF_Audit_Document__c>>();
                List<Core_MDF_Audit_Document__c> auditDocumentList = new List<Core_MDF_Audit_Document__c>([select Id, Core_MDF_Claim_Batch_Record__c, Core_MDF_Claim__c, Core_MDF_Document_Id__c from Core_MDF_Audit_Document__c where Core_MDF_Claim_Batch_Record__c IN :successClaimToClaimStageIdMap.values()]);
                for(Core_MDF_Audit_Document__c auditRecord : auditDocumentList) {
                    if(!auditList.containskey(auditRecord.Core_MDF_Claim_Batch_Record__c)) {
                        List<Core_MDF_Audit_Document__c> auditDocument = new List<Core_MDF_Audit_Document__c>();
                        auditDocument.add(auditRecord);
                        auditList.put(auditRecord.Core_MDF_Claim_Batch_Record__c, auditDocument);
                    } else {
                        List<Core_MDF_Audit_Document__c> auditDocument = auditList.get(auditRecord.Core_MDF_Claim_Batch_Record__c);
                        auditDocument.add(auditRecord);
                        auditList.put(auditRecord.Core_MDF_Claim_Batch_Record__c, auditDocument);
                    }
                   
                }
                if(successClaimToClaimStageIdMap != null && successClaimToClaimStageIdMap.size()>0){
                    Map<Id, PartnerFundClaim> claimIdToClaimRecMap = new Map<Id, PartnerFundClaim>();//AI PIC
                    for (PartnerFundClaim claim : successClaimToClaimStageIdMap.keySet()) {
                        if(auditList!=null && auditList.containsKey(claim.Core_MDF_Claim_Batch_Stage__c)) {
                            Core_MDF_BulkPOPUploadController.assignDocumentList(auditList.get(claim.Core_MDF_Claim_Batch_Stage__c), claim.Id);
                        }
                        
                        if(!claim.Core_MDF_OutcomeBased_Ind__c) { //AI PIC
                        claimIdToClaimRecMap.put(claim.Id, claim); //AI PIC
                        }
                    }
                    //Added by VB - AI PIC
                    try 
                        {
                            if(!(Core_MDF_Claim_Utility.bypassCDBCalloutValidationCheck('Core_MDF_ProcessClaimsWithAIForPICReview','Core_MDF_Bypass_AI_CDB_CallForClaims'))) {
                                if(claimIdToClaimRecMap != null && !claimIdToClaimRecMap.isEmpty()) {
                                    Core_MDF_AI_Integration_Outbound.generateAIResponseForPICProcess(claimIdToClaimRecMap, 'insert');
                                }
                            }
                        }   
                        catch (Exception e) {
                            Core_MDF_CCP_UtilityClass.logError(e);
                        }
                    }
                }
            
        }
        catch (Exception e) {
            if(!e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            Core_MDF_CCP_UtilityClass.logError(e); }
            throw e;
        }
    }
    
    /************************************************************************************************************ 
Method Name:        checkAccessiblityForInsertAndUpdate
@return  :          void
@parameters:        List<Core_MDF_Claim_Batch_Stage__c> List of stage claims and its map
Description:        This method will check if user has access to given activities and banks when updating and inserting a stage record                      
Added By:           Accenture  - NK - 26/11/2021
Modified By:        Date:        Changes: 
Accenture - JV     07/04/2019    To check if user has access to given activities and banks when updating a stage record
*************************************************************************************************************/
    public static List<Core_MDF_Claim_Batch_Stage__c> checkAccessiblityForInsertAndUpdate(List<Core_MDF_Claim_Batch_Stage__c> claimStageListToBeProcessed)
    {
        Set<String> activityNumbers = new Set<String>();
        Set<String> bankNumbers = new Set<String>();
        Map<String, String> bankAccountNumberMap = new Map<String, String>();
        Map<String,List<String>> bnkSplrToBnkAccNumber = new Map<String,List<String>>();
        Map<String,Id> bnkSplrAccNbrToBnkId = new Map<String,Id>();
        Map<String,Id> validBankNumbers = new Map<String,Id>();
        Set<Id> accounts = new Set<Id>();
        Map<String,List<String>> bankAccountMap = new Map<String,List<String>>();
        Map<String,String> bankSupplierNumberToLegalEntity = new Map<String,String>();
        List<Core_MDF_Account_Bank_Mapping__c> accountBankMapping = new List<Core_MDF_Account_Bank_Mapping__c>();
        Set<String> bankStatusSet = createBankStatusSet();
        Set<Id> channelPartnerIdSet = new Set<Id>();
        activityNumberToPfrMap= new Map<String,PartnerFundRequest>();
        Map<String,Boolean> isPopRequired = new Map<String, Boolean>();
 
        if(claimStageListToBeProcessed != NULL && claimStageListToBeProcessed.size() > 0)
        {
            //To get a mapping of the Channel Program in the Bank Object
            Id batch = claimStageListToBeProcessed[0].Core_MDF_Batch_ID__c;
            Core_MDF_Claim_Batch__c programAccRec = [Select Id, Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Account__c,Core_MDF_Program_Id__r.Name
                                                     From Core_MDF_Claim_Batch__c 
                                                     where Id = :batch LIMIT 1];
            //To store the channel program and ultimate account of the user
            String program = programAccRec.Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c; 
            Id ultimateAccountId = programAccRec.Core_MDF_Account__c;
            String programName = programAccRec.Core_MDF_Program_Id__r.Name;
            //fetch bulk claim  metadata to check if tax and bank check
	    
            /************************************************************************************************************ 
            Moved from Custom Metadata (Core_MDF_BulkClaimConfiguration__mdt) to Custom Object (Core_MDF_CCP_Custom_Metadata_Utility__c)

            Below are the field Mapping :
            Core_MDF_Active__c --> Core_MDF_Is_Active_Ind__c
            Core_MDF_Bank_Required__c -->  Core_MDF_Checkbox_Field_1_Ind__c
            Core_MDF_Budget_Type__c --> Core_MDF_Sub_Category__c
            Core_MDF_Program__c -->Core_MDF_Program__c
            Core_MDF_Tax_Required__c --> Core_MDF_Checkbox_Field_2_Ind__c
            DeveloperName --> Core_MDF_Name_Criteria__c
        
            To Identity the Bulk Claim records in Core_MDF_CCP_Custom_Metadata_Utility__c Custom object used Core_MDF_Category__c
            Core_MDF_Category__c---> BulkClaim

            *************************************************************************************************************/
            List<Core_MDF_CCP_Custom_Metadata_Utility__c> bulkClaimConfigMetadata = [select Core_MDF_Name_Criteria__c,Core_MDF_Category__c , Core_MDF_Is_Active_Ind__c, Core_MDF_Sub_Category__c, Core_MDF_Program__c, Core_MDF_Checkbox_Field_1_Ind__c, Core_MDF_Checkbox_Field_2_Ind__c from Core_MDF_CCP_Custom_Metadata_Utility__c  where Core_MDF_Program__c =: program and Core_MDF_Is_Active_Ind__c = true and Core_MDF_Category__c = 'BulkClaim' ];
            Map<String, Boolean> isTaxRequired = new Map<String, Boolean>();
            Map<String, Boolean> isBankRequired = new Map<String, Boolean>();
            for(Core_MDF_CCP_Custom_Metadata_Utility__c bulkClaimConfig: bulkClaimConfigMetadata) {
                isTaxRequired.put(bulkClaimConfig.Core_MDF_Sub_Category__c==null?bulkClaimConfig.Core_MDF_Program__c : bulkClaimConfig.Core_MDF_Program__c+bulkClaimConfig.Core_MDF_Sub_Category__c, bulkClaimConfig.Core_MDF_Checkbox_Field_2_Ind__c);
                isBankRequired.put(bulkClaimConfig.Core_MDF_Sub_Category__c==null?bulkClaimConfig.Core_MDF_Program__c : bulkClaimConfig.Core_MDF_Program__c+bulkClaimConfig.Core_MDF_Sub_Category__c, bulkClaimConfig.Core_MDF_Checkbox_Field_1_Ind__c);
            }
            Map<String,Boolean> vatOptInRequired =  new Map<String, Boolean>();
            Map<String,Boolean> applicableVATPerRequired =  new Map<String, Boolean>();
            List<Core_MDF_CCP_VAT_Config__mdt> vatConfigMetadata = [select Core_MDF_Legal_Entity__c,Core_MDF_VAT_Opt_in_Option_Required__c,Core_MDF_Show_Applicable_VAT_Percentage__c from Core_MDF_CCP_VAT_Config__mdt where Core_MDF_Program__c = :program ];
            for(Core_MDF_CCP_VAT_Config__mdt vatConfig :vatConfigMetadata ){
                vatOptInRequired.put(vatConfig.Core_MDF_Legal_Entity__c,vatConfig.Core_MDF_VAT_Opt_in_Option_Required__c);
                applicableVATPerRequired.put(vatConfig.Core_MDF_Legal_Entity__c,vatConfig.Core_MDF_Show_Applicable_VAT_Percentage__c);
            }

            Core_MDF_ChannelProgram__mdt bankProgram = [SELECT Core_MDF_Bank_Program_Value__c 
                                                        FROM Core_MDF_ChannelProgram__mdt
                                                        WHERE Core_MDF_Technical_Program_Name__c = :program LIMIT 1];
            
            //To have a set of the activities and bank input by user
            Set<Id> claimStageListToBeProcessedIds = new Set<Id>();
            for(Core_MDF_Claim_Batch_Stage__c claim : claimStageListToBeProcessed)
            {
                activityNumbers.add(claim.Core_MDF_Activity_Nbr__c);
                bankNumbers.add(claim.Core_MDF_Bank_Nbr__c);
                bankAccountNumberMap.put(claim.Core_MDF_Bank_Nbr__c+claim.Core_MDF_Bank_Account_Nbr__c,claim.Core_MDF_Bank_Nbr__c); //WW 11 - added by JK to map bank account numbers and supplier number 
               if(claim.Id !=null)
               {
                   claimStageListToBeProcessedIds.add(claim.Id); //ids of the claimStageListToBeProcessed
               }                
            }
            
            //To retrieve all the activities that are valid and match the ones input by user
            List<PartnerFundRequest> userActivities = [SELECT Id, ChannelPartnerId, Core_MDF_Activity_Number__c, Core_MDF_Country_nm__c,Core_MDF_ActivityCategory__c,Core_MDF_Activity_Types__c,Core_MDF_Activity_SubType_nm__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Program__c,
                                                       ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Reimbursement_Rate__c
                                                       FROM PartnerFundRequest
                                                       WHERE Core_MDF_Activity_Number__c IN :activityNumbers
                                                       AND ChannelPartner.Core_MDF_Active_Ind__c = true
                                                       AND ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c = :ultimateAccountId
                                                       AND Core_MDF_Fund_Request_Status__c IN :Label.Core_MDF_PFR_Status_CreateClaim.split(';')
                                                       AND ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c =:program];
            Map<String,Boolean> actNbrToHideMedia = new Map<String,Boolean>();
            Map<String,String> actNbrToBgtType = new Map<String,String>();
            Map <String,Set<String>> actNbrToActSubtype = new  Map <String,Set<String>>();
            Map <String,String> actNbrToActType = new  Map <String,String>();
            Map <String,String> actNbrToActCategory = new  Map <String,String>();
            Map<String, Boolean> actNbrToCheckTaxReq = new Map<String, boolean>();
            Map<String, Boolean> actNbrToCheckBankReq = new Map<String, boolean>();
            Map <String,String> actNbrToReimbursementRate = new  Map <String,String>();
             Map <String,String> actNbrToAcctId = new  Map <String,String>();
            //To store all the accounts belonging to the given activities
            
            if( userActivities != null && userActivities.size() > 0 )
            {  
                for(PartnerFundRequest activity : userActivities)
                {
                    activityNumberToPfrMap.put(activity.Core_MDF_Activity_Number__c,activity);
                    channelPartnerIdSet.add(activity.ChannelPartnerId);
                    //String activityString = activity.Core_MDF_Program__c + activity.Core_MDF_Budget_Type_nm__c + activity.Core_MDF_ActivityCategory__c + activity.Core_MDF_Activity_Types__c ;
                    String programBudgetType = activity.Core_MDF_Budget_Type_nm__c != null ? activity.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c + activity.Core_MDF_Budget_Type_nm__c : activity.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c;
                    //actNbrToHideMedia.put(activity.Core_MDF_Activity_Number__c,hideMediaVehicleMap.containsKey(activityString)? True : False );
                    if(isTaxRequired.containsKey(programBudgetType)){
                    actNbrToCheckTaxReq.put(activity.Core_MDF_Activity_Number__c, isTaxRequired.get(programBudgetType));
                    }
                    if(isBankRequired.containsKey(programBudgetType)){
                    actNbrToCheckBankReq.put(activity.Core_MDF_Activity_Number__c, isBankRequired.get(programBudgetType));
                    }
                    actNbrToBgtType.put(activity.Core_MDF_Activity_Number__c,activity.Core_MDF_Budget_Type_nm__c);
                    if(activity.Core_MDF_Activity_SubType_nm__c != null){
                        List<string> actSubtypeList = new List<String>();
                        actSubtypeList = activity.Core_MDF_Activity_SubType_nm__c.split(';'); 
                        Set<String> actSubtypeSet = new Set<String>();
                        actSubtypeSet.addAll(actSubtypeList);
                        actNbrToActSubtype.put(activity.Core_MDF_Activity_Number__c,actSubtypeSet);
                    }
                    if(activity.Core_MDF_Activity_Types__c != null){
                        actNbrToActType.put(activity.Core_MDF_Activity_Number__c,activity.Core_MDF_Activity_Types__c);
                    }
                    if(activity.Core_MDF_ActivityCategory__c != null){
                        actNbrToActCategory.put(activity.Core_MDF_Activity_Number__c,activity.Core_MDF_ActivityCategory__c);
                    }
                    if(activity.Core_MDF_Reimbursement_Rate__c != null){
                        actNbrToReimbursementRate.put(activity.Core_MDF_Activity_Number__c,activity.Core_MDF_Reimbursement_Rate__c);
                    }
                    if(activity.ChannelPartnerId != null){
                        actNbrToAcctId.put(activity.Core_MDF_Activity_Number__c,activity.ChannelPartnerId);
                    }
                    
                }
            }
            
            //To retrieve all the banks that are valid and match the ones input by user and belong to the same account as the activities
            if(activityNumberToPfrMap.size() > 0)
            {
                
                accountBankMapping = [SELECT Id, Core_MDF_Account__c, Core_MDF_Bank__c,Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c, Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, Core_MDF_Program__c, Core_MDF_AccountIdBankIdMapping__c,Core_MDF_Bank__r.Core_MDF_Bank_Account_Number__c  
                                      FROM Core_MDF_Account_Bank_Mapping__c
                                      WHERE Core_MDF_Account__c IN :channelPartnerIdSet
                                      AND Core_MDF_Bank__r.Core_MDF_Program__c includes (:bankProgram.Core_MDF_Bank_Program_Value__c)
                                      AND Core_MDF_Bank__r.Core_MDF_Supplier_Number__c IN :bankNumbers
                                      AND Core_MDF_Bank__r.Core_MDF_Bank_Status__c IN: bankStatusSet
                                      AND Core_MDF_Account__r.Core_MDF_Active_Ind__c  = true
                                      AND Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c = :ultimateAccountId
                                      AND Core_MDF_Active_ind__c=TRUE
                                     ];
                /*if(accountBankMapping.size() > 0 || accountBankMapping != null)*/
                if(accountBankMapping != null && accountBankMapping.size() > 0)
                {                
                    for(Core_MDF_Account_Bank_Mapping__c abm : accountBankMapping)
                    {
                        // storing bank supplier number with list of bank account numbers
                        if(bnkSplrToBnkAccNumber.containsKey(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + abm.Core_MDF_Account__c)){
                            bnkSplrToBnkAccNumber.get(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + abm.Core_MDF_Account__c).add(abm.Core_MDF_Bank__r.Core_MDF_Bank_Account_Number__c);
                        }
                        else{
                            bnkSplrToBnkAccNumber.put(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + abm.Core_MDF_Account__c, new List<String>{abm.Core_MDF_Bank__r.Core_MDF_Bank_Account_Number__c});
                        }
                        // To check whether the given bank account number is valid or not
                        if(bankAccountNumberMap.get(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c+abm.Core_MDF_Bank__r.Core_MDF_Bank_Account_Number__c) == abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c) {
                            validBankNumbers.put(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + abm.Core_MDF_Account__c, abm.Core_MDF_Bank__c);
                        }
                        // To check when the bank account number is null
                        if(bnkSplrToBnkAccNumber.get(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + abm.Core_MDF_Account__c).size() == 1){
                            
                            validBankNumbers.put(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + abm.Core_MDF_Account__c, abm.Core_MDF_Bank__c);
                        }
                        if(bankAccountMap.containsKey(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c)){
                            bankAccountMap.get(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c).add(abm.Core_MDF_Account__c);
                        }
                        else{
                            bankAccountMap.put(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, new List<String>{abm.Core_MDF_Account__c});
                        }
                        bnkSplrAccNbrToBnkId.put(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + abm.Core_MDF_Account__c + abm.Core_MDF_Bank__r.Core_MDF_Bank_Account_Number__c, abm.Core_MDF_Bank__c);
                        validBankNumbers.put(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + abm.Core_MDF_Account__c, abm.Core_MDF_Bank__c);
                        bankSupplierNumberToLegalEntity.put(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c,abm.Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c);
                    }
                    
                }
            }
            
            String spcfTechName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SPCF_Technical_program_name');
            
          // querying content document link records linked to claim stage records to be processed
          List<ContentDocumentLink> docLinkListIds = new List<ContentDocumentLink>();
          if(claimStageListToBeProcessedIds.size()>0)
          {
             docLinkListIds= [select Id, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN :claimStageListToBeProcessedIds];           
          }
            // storing linked entity ids
            Set<Id> docLinkedclaimStageIds = new Set<Id>();
            if(docLinkListIds.size()>0) {
                for(ContentDocumentLink doc : docLinkListIds) {
                    docLinkedclaimStageIds.add(doc.LinkedEntityId);
                }
            }
			List<Core_MDF_POP_Document_Types_Revamp__mdt> popDocType = [select id, Core_MDF_Program_nm__c, Core_MDF_Budget_Type_txt__c, Core_MDF_Req_Doc_Types_ind__c, Core_MDF_Active_ind__c from Core_MDF_POP_Document_Types_Revamp__mdt   where  Core_MDF_Active_ind__c=true And Core_MDF_Req_Doc_Types_ind__c=true];
			for(Core_MDF_POP_Document_Types_Revamp__mdt popDocConfig: popDocType) {
                String popProgToBudget= popDocConfig.Core_MDF_Budget_Type_txt__c ==null ? popDocConfig.Core_MDF_Program_nm__c : popDocConfig.Core_MDF_Program_nm__c + popDocConfig.Core_MDF_Budget_Type_txt__c;
                isPopRequired.put(popProgToBudget,popDocConfig.Core_MDF_Req_Doc_Types_ind__c);             
            }
           //To populate approiate error messages in case of any errors or assign RequestId, Bank and Processing status
            for(Core_MDF_Claim_Batch_Stage__c claimStageRec : claimStageListToBeProcessed)
            {
                
                List<String> errorList = new List<String>();
               
                //Activity and Activity Subtype validations
                if(activityNumberToPfrMap.containsKey(claimStageRec.Core_MDF_Activity_Nbr__c)) { // to check a valid activity
                    //stamp Request id and activity types for a valid activity
                    claimStageRec.Core_MDF_Request_Id__c = (activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c)).Id;
                    if(actNbrToActType.containsKey(claimStageRec.Core_MDF_Activity_Nbr__c) 
                       && actNbrToActType.get(claimStageRec.Core_MDF_Activity_Nbr__c)!=null){
                                                     claimStageRec.Core_MDF_Activity_Type_Nm__c = actNbrToActType.get(claimStageRec.Core_MDF_Activity_Nbr__c);
                       }
                       //stamp Activity category
                       if(actNbrToActCategory.containsKey(claimStageRec.Core_MDF_Activity_Nbr__c) 
                       && actNbrToActCategory.get(claimStageRec.Core_MDF_Activity_Nbr__c)!=null){
                                                      claimStageRec.Core_MDF_ActivityCategory__c = actNbrToActCategory.get(claimStageRec.Core_MDF_Activity_Nbr__c);
                       }
                    //stamp Reimbursement rate
                    if(actNbrToReimbursementRate.containsKey(claimStageRec.Core_MDF_Activity_Nbr__c) 
                       && actNbrToReimbursementRate.get(claimStageRec.Core_MDF_Activity_Nbr__c)!=null){
                                                      claimStageRec.Core_MDF_Reimbursement_Percent_Nbr__c = actNbrToReimbursementRate.get(claimStageRec.Core_MDF_Activity_Nbr__c);
                       }
                    //stamp budget type
                    if(actNbrToBgtType.containsKey(claimStageRec.Core_MDF_Activity_Nbr__c) 
                       && actNbrToBgtType.get(claimStageRec.Core_MDF_Activity_Nbr__c)!=null){
                        claimStageRec.Core_MDF_Budget_Type_Nm__c=actNbrToBgtType.get(claimStageRec.Core_MDF_Activity_Nbr__c);
                    }
                    //stamp node account
                    if(actNbrToAcctId.containsKey(claimStageRec.Core_MDF_Activity_Nbr__c) 
                       && actNbrToAcctId.get(claimStageRec.Core_MDF_Activity_Nbr__c)!=null){
                        claimStageRec.Core_MDF_Node_Account_Txt__c=actNbrToAcctId.get(claimStageRec.Core_MDF_Activity_Nbr__c);
                    }
                    
                    // If claim stage activity is empty,Inherit activity subtype from pfr activity
                    if(claimStageRec.Core_MDF_Activity_SubType_nm__c == null && 
                       activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c).Core_MDF_Activity_SubType_nm__c != null){
                           List<String> availableActSubtype = new List<String>();
                           availableActSubtype.addAll(actNbrToActSubtype.get(claimStageRec.Core_MDF_Activity_Nbr__c));
                           claimStageRec.Core_MDF_Activity_SubType_nm__c = String.join(availableActSubtype,';');
                       }
                    //check if activity subtype entered is available on activity
                    else if(claimStageRec.Core_MDF_Activity_SubType_nm__c != null && 
                            activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c).Core_MDF_Activity_SubType_nm__c != null && !actNbrToActSubtype.get(claimStageRec.Core_MDF_Activity_Nbr__c).containsAll(claimStageRec.Core_MDF_Activity_SubType_nm__c.split(';'))) {
                                List<String> availableActSubtype = new List<String>();
                                availableActSubtype.addAll(actNbrToActSubtype.get(claimStageRec.Core_MDF_Activity_Nbr__c));
                                String actSubType = String.join(availableActSubtype,'; ');
                                errorList.add(Label.Core_MDF_Bulk_Claim_Invalid_Activity_Subtype + ' ' + actSubType+'.'); 
                                
                            } 
                    // To check if activity subtype is applicable
                    else if(claimStageRec.Core_MDF_Activity_SubType_nm__c != null && 
                            activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c).Core_MDF_Activity_SubType_nm__c == null){
                                errorList.add(Label.Core_MDF_Bulk_Claim_Activity_Subtype_Inapplicable);
                            }
                    
                }
                else {
                    //to check an invalid activity
                    errorList.add(Label.Core_MDF_Claim_Stage_Activity_Error);
                }
			
                
             if(actNbrToCheckBankReq.containsKey(claimStageRec.Core_MDF_Activity_Nbr__c)) {
                    // To check if bank is mandatory
                    if(claimStageRec.Core_MDF_Bank_Nbr__c == null && actNbrToCheckBankReq.get(claimStageRec.Core_MDF_Activity_Nbr__c)) {
                        errorList.add(Label.Core_MDF_Bulk_claim_Bank_Mandatory);
                    }
                    // To check if its a valid bank 
                    else if(actNbrToCheckBankReq.get(claimStageRec.Core_MDF_Activity_Nbr__c) && !validBankNumbers.keySet().contains(claimStageRec.Core_MDF_Bank_Nbr__c + claimStageRec.Core_MDF_Node_Account_Txt__c)) {
                        errorList.add(Label.Core_MDF_Claim_Stage_Bank_Error);
                    }
                    //To Check bank account number is 4-digit
                    else if(claimStageRec.Core_MDF_Bank_Account_Nbr__c != null && ((claimStageRec.Core_MDF_Bank_Account_Nbr__c).length() != 4) && actNbrToCheckBankReq.get(claimStageRec.Core_MDF_Activity_Nbr__c))
                    {
                        errorList.add(Label.Core_MDF_Bulk_claim_BankNumber_Mandatory);
                    }
                    // To check bank account number is mandatory
                    else if(claimStageRec.Core_MDF_Bank_Account_Nbr__c == null && actNbrToCheckBankReq.get(claimStageRec.Core_MDF_Activity_Nbr__c) &&  !bnkSplrToBnkAccNumber.isEmpty() && bnkSplrToBnkAccNumber.containsKey(claimStageRec.Core_MDF_Bank_Nbr__c + claimStageRec.Core_MDF_Node_Account_Txt__c) &&  
                    bnkSplrToBnkAccNumber.get(claimStageRec.Core_MDF_Bank_Nbr__c + claimStageRec.Core_MDF_Node_Account_Txt__c).size() > 1 )
                    {
                        errorList.add(Label.Core_MDF_Bulk_claim_BankNumber_Mandatory);
                    }
                    // To check given bank account number is valid or not
                    else if(claimStageRec.Core_MDF_Bank_Account_Nbr__c != null && actNbrToCheckBankReq.get(claimStageRec.Core_MDF_Activity_Nbr__c) && !bnkSplrToBnkAccNumber.isEmpty() && bnkSplrToBnkAccNumber.containsKey(claimStageRec.Core_MDF_Bank_Nbr__c + claimStageRec.Core_MDF_Node_Account_Txt__c) && 
                    bnkSplrToBnkAccNumber.get(claimStageRec.Core_MDF_Bank_Nbr__c + claimStageRec.Core_MDF_Node_Account_Txt__c).size() > 1 && !bnkSplrToBnkAccNumber.get(claimStageRec.Core_MDF_Bank_Nbr__c + claimStageRec.Core_MDF_Node_Account_Txt__c).contains(claimStageRec.Core_MDF_Bank_Account_Nbr__c)){
                        errorList.add(Label.Core_MDF_Claim_Stage_Bank_Number_Error);
                    }
                    // To check if the given bank belongs to the account on the given activity
                    else if(actNbrToCheckBankReq.get(claimStageRec.Core_MDF_Activity_Nbr__c) && !(bankAccountMap.get(claimStageRec.Core_MDF_Bank_Nbr__c).contains((activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c)).ChannelPartnerId))) {
                        errorList.add(Label.Core_MDF_Bulk_Claim_Account_Bank_Error);
                    } 
                    // To check if bank is entered on template when not applicable
                    else if(claimStageRec.Core_MDF_Bank_Nbr__c != null && !actNbrToCheckBankReq.get(claimStageRec.Core_MDF_Activity_Nbr__c)) {
                        errorList.add( Label.Core_MDF_Bulk_Claim_Bank_Inapplicable);
                    }
                    /*else if(claimStageRec.Core_MDF_Bank_Account_Nbr__c != null && !actNbrToCheckBankReq.get(claimStageRec.Core_MDF_Activity_Nbr__c))
                    {
                         errorList.add(Label.Core_MDF_Bulk_Claim_AccountNumber_Inapplicable);
                    }*/
                    
		    //To check if bank's Intel Company code is not 420 and Vat opt-in is provided --> Vat Opt-in Inapplicable(Retail MDF)
                    
                   else if((claimStageRec.Core_MDF_Bank_Nbr__c != null && bankSupplierNumberToLegalEntity.containsKey(claimStageRec.Core_MDF_Bank_Nbr__c) && 
                        ((!vatOptInRequired.containsKey(bankSupplierNumberToLegalEntity.get(claimStageRec.Core_MDF_Bank_Nbr__c)) || 
                        vatOptInRequired.containsKey(bankSupplierNumberToLegalEntity.get(claimStageRec.Core_MDF_Bank_Nbr__c)) && !vatOptInRequired.get(bankSupplierNumberToLegalEntity.get(claimStageRec.Core_MDF_Bank_Nbr__c))  &&
                        (applicableVATPerRequired.containsKey(bankSupplierNumberToLegalEntity.get(claimStageRec.Core_MDF_Bank_Nbr__c)) && 
                        applicableVATPerRequired.get(bankSupplierNumberToLegalEntity.get(claimStageRec.Core_MDF_Bank_Nbr__c)) &&
                        //JK - new Vat Process Changes
                         claimStageRec.Core_MDF_VAT_Opt_In__c != vatApplicable)) 
                        && claimStageRec.Core_MDF_VAT_Opt_In__c != null)) || claimStageRec.Core_MDF_Bank_Nbr__c == null && claimStageRec.Core_MDF_VAT_Opt_In__c != null)
                   {
                            if((applicableVATPerRequired.containsKey(bankSupplierNumberToLegalEntity.get(claimStageRec.Core_MDF_Bank_Nbr__c)) && 
                            applicableVATPerRequired.get(bankSupplierNumberToLegalEntity.get(claimStageRec.Core_MDF_Bank_Nbr__c)) && 
                            //JK - new Vat Process Changes
                            claimStageRec.Core_MDF_VAT_Opt_In__c == nonVatApplicable )){
                                errorList.add(Label.Core_MDF_Vat_OptIn_Applicable_to_VAT_Percentage); //if 650 - VAT opt no there error
                            }else{
                        errorList.add(Label.Core_MDF_Bulk_Claim_Vat_Inapplicable);
                            }
                    }
                    //To check if Vat opt-in is entered in template when applicable(Retail MDF)
                    else if(claimStageRec.Core_MDF_Bank_Nbr__c != null && bankSupplierNumberToLegalEntity.containsKey(claimStageRec.Core_MDF_Bank_Nbr__c) && vatOptInRequired.containsKey(bankSupplierNumberToLegalEntity.get(claimStageRec.Core_MDF_Bank_Nbr__c))
                        && vatOptInRequired.get(bankSupplierNumberToLegalEntity.get(claimStageRec.Core_MDF_Bank_Nbr__c)) && claimStageRec.Core_MDF_VAT_Opt_In__c == null){
                        errorList.add(Label.Core_MDF_Bulk_Claim_Vat_Mandatory);
                    }
                 //To check if bank's Intel Company code is not 650 and Applicable VAT Percentage is provided -> Applicable VAT Percentage (Retail MDF)
                 else if(((claimStageRec.Core_MDF_Bank_Nbr__c != null && bankSupplierNumberToLegalEntity.containsKey(claimStageRec.Core_MDF_Bank_Nbr__c) && applicableVATPerRequired.containsKey(bankSupplierNumberToLegalEntity.get(claimStageRec.Core_MDF_Bank_Nbr__c))
                        && !applicableVATPerRequired.get(bankSupplierNumberToLegalEntity.get(claimStageRec.Core_MDF_Bank_Nbr__c))) || claimStageRec.Core_MDF_Bank_Nbr__c == null) && claimStageRec.Core_MDF_Applicable_VAT_Percentage_nm__c != null ){
                        errorList.add(Label.Core_MDF_Bulk_Claim_Applicable_VAT_Percentage_Inapplicable);
                    }
                 //To check if Applicable VAT Percentage is entered in template when applicable(Retail MDF)
                    else if(claimStageRec.Core_MDF_Bank_Nbr__c != null && bankSupplierNumberToLegalEntity.containsKey(claimStageRec.Core_MDF_Bank_Nbr__c) && applicableVATPerRequired.containsKey(bankSupplierNumberToLegalEntity.get(claimStageRec.Core_MDF_Bank_Nbr__c))
                        && applicableVATPerRequired.get(bankSupplierNumberToLegalEntity.get(claimStageRec.Core_MDF_Bank_Nbr__c)) && claimStageRec.Core_MDF_Applicable_VAT_Percentage_nm__c == null ){
                        errorList.add(Label.Core_MDF_Bulk_Claim_Applicable_VAT_Percentage_Mandatory);
                    }
                 else {

                        claimStageRec.Core_MDF_Bank_Id__c = bnkSplrToBnkAccNumber.containsKey(claimStageRec.Core_MDF_Bank_Nbr__c + claimStageRec.Core_MDF_Node_Account_Txt__c) && bnkSplrToBnkAccNumber.get(claimStageRec.Core_MDF_Bank_Nbr__c  + claimStageRec.Core_MDF_Node_Account_Txt__c).size() > 1 
                        ? bnkSplrAccNbrToBnkId.get(claimStageRec.Core_MDF_Bank_Nbr__c + claimStageRec.Core_MDF_Node_Account_Txt__c + claimStageRec.Core_MDF_Bank_Account_Nbr__c) 
                        : validBankNumbers.get(claimStageRec.Core_MDF_Bank_Nbr__c + claimStageRec.Core_MDF_Node_Account_Txt__c) ;
                    }
                }
                
            //to check whether the tax is mandatory or not based on the program and budget type
            if(actNbrToCheckTaxReq.containsKey(claimStageRec.Core_MDF_Activity_Nbr__c) 
                && (actNbrToCheckTaxReq.get(claimStageRec.Core_MDF_Activity_Nbr__c)) && claimStageRec.Core_MDF_Taxes_Local_Amt__c == null) {
                    errorList.add(Label.Core_MDF_Bulk_Claim_Tax_Mandatory);
            }
            //tax is not applicable for OPAL, MDF and MDF+
            // Roshan - TWC3117-11893 Bulk claims going into Submitted status when edited after PIC is Passed
            else if(actNbrToCheckTaxReq.containsKey(claimStageRec.Core_MDF_Activity_Nbr__c)) {
                if (claimStageRec.Core_MDF_Taxes_Local_Amt__c == null) {
                    claimStageRec.Core_MDF_Taxes_Local_Amt__c = 0;
                }
                if ((!actNbrToCheckTaxReq.get(claimStageRec.Core_MDF_Activity_Nbr__c)) && (claimStageRec.Core_MDF_Taxes_Local_Amt__c != null && claimStageRec.Core_MDF_Taxes_Local_Amt__c != 0)) {
                    errorList.add(Label.Core_MDF_Bulk_Claim_Tax_Inapplicable);
                }
            }


                //To check if activity Contains No Countries
                /*if(activityNumberToPfrMap.keySet().contains(claimStageRec.Core_MDF_Activity_Nbr__c)
                   && (activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c)).Core_MDF_Country_nm__c==null){
                       errorList.add(Label.Core_MDF_No_Countries_Error);
                   } */
                //To check if activity Contains Multiple Countries only for SPCF
               if(activityNumberToPfrMap.keySet().contains(claimStageRec.Core_MDF_Activity_Nbr__c)
                        && (activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c)).Core_MDF_Country_nm__c!=null
                        && ((activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c)).Core_MDF_Country_nm__c).contains(';') && program == spcfTechName){
                        	errorList.add(Label.Core_MDF_Multiple_Countries_Error);
                        }
                else if(activityNumberToPfrMap.keySet().contains(claimStageRec.Core_MDF_Activity_Nbr__c)
                        && (activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c)).Core_MDF_Country_nm__c!=null
                        && ((activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c)).Core_MDF_Country_nm__c).contains(';')  && program != spcfTechName
                        && claimStageRec.Core_MDF_Country_Location_nm__c == null){
                            errorList.add(Label.Core_MDF_Bulk_Claim_Country_Mandatory);
                            
                        } 
                else if(activityNumberToPfrMap.keySet().contains(claimStageRec.Core_MDF_Activity_Nbr__c)
                        && (activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c)).Core_MDF_Country_nm__c!=null
                        && claimStageRec.Core_MDF_Country_Location_nm__c != null
                        && (!(activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c)).Core_MDF_Country_nm__c.split(';').contains(claimStageRec.Core_MDF_Country_Location_nm__c))){
                            List<String> availableCountryList = new List<String>();
                                availableCountryList = activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c).Core_MDF_Country_nm__c.split(';');
                                String countries = String.join(availableCountryList,'; ');
                            errorList.add(Label.Core_MDF_Bulk_claim_Country_Invalid+ ' ' + countries+'.');
                        }
                else {
                    //claimStageRec.Core_MDF_Country_nm__c=(activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c)).Core_MDF_Country_nm__c;//added by VD for country
                    if(activityNumberToPfrMap.keySet().contains(claimStageRec.Core_MDF_Activity_Nbr__c)
                        && (activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c)).Core_MDF_Country_nm__c!=null && claimStageRec.Core_MDF_Country_Location_nm__c == null){
                        claimStageRec.Core_MDF_Country_Location_nm__c = activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c).Core_MDF_Country_nm__c.split(';')[0];
                    }
                }
                if(errorList !=null && errorList.size() == 0) {
                    // Call a method to check if pop is required
                    
                    String budgetType = actNbrToBgtType.containsKey(claimStageRec.Core_MDF_Activity_Nbr__c)?actNbrToBgtType.get(claimStageRec.Core_MDF_Activity_Nbr__c):Null;
                    //added check for RMF Program 
      		    String progToBudgetType = programName == Core_MDF_CCP_ConstantClass.RMF_PROGRAM ? programName : programName + budgetType;
                    claimStageRec.Core_MDF_Processing_Status_Nm__c = (isPopRequired.containskey(progToBudgetType) && isPopRequired.get(progToBudgetType)) ? docLinkedclaimStageIds.size()>0 ?
                        (docLinkedclaimStageIds.contains(claimStageRec.Id) ? Label.Core_MDF_Status_Submitted : Label.Core_MDF_Status_PendingDocuments) : Label.Core_MDF_Status_PendingDocuments : Label.Core_MDF_Status_Submitted;
                    claimStageRec.Core_MDF_Message_txt__c = '';
                    
                    if(claimStageRec.Core_MDF_Bank_Nbr__c != null && bankSupplierNumberToLegalEntity != null && bankSupplierNumberToLegalEntity.containsKey(claimStageRec.Core_MDF_Bank_Nbr__c) 
                    && applicableVATPerRequired != null && applicableVATPerRequired.containsKey(bankSupplierNumberToLegalEntity.get(claimStageRec.Core_MDF_Bank_Nbr__c))
                    && applicableVATPerRequired.get(bankSupplierNumberToLegalEntity.get(claimStageRec.Core_MDF_Bank_Nbr__c)) && claimStageRec.Core_MDF_Applicable_VAT_Percentage_nm__c != null){

                    	claimStageRec.Core_MDF_VAT_Opt_In__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NonTranslateYes');
                	}
                    
                } else {
                    String errorString = String.join(errorList, Label.newLine);
                    errorString = errorString.Remove('_');
                    claimStageRec.Core_MDF_Message_txt__c = errorString;
                    claimStageRec.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Failed;
                }
                
        }
        
           
    }
    return claimStageListToBeProcessed;
    
}
    /************************************************************************************************************ 
Method Name:        createBankStatusSet
@return  :          Set<String>
@parameters:        -
Description:        This method returns valid bank status for creating claim                      
Added By:           Accenture  - Krishna Kulkarni - 19/06/2019
Modified By:        Date:       Changes: 
***************************************************************************************************/        
    public static Set<String> createBankStatusSet()
    {
        Set<String> bankStatusSet = new Set<String>();
        String bankStatusList = System.label.Core_MDF_Claim_Bank_StatusList;
        //To get valid bank status
        if(!String.IsBlank(bankStatusList)){
            for(String bankStatus : bankStatusList.split(';')){
                bankStatusSet.add(bankStatus);
            }
        }
        return bankStatusSet;         
    }
    
    /************************************************************************************************************ 
Method Name:        generateBatchChaining
@return  :          void
@parameters:        Datetime runStartTime
Description:        This method is used to chain the bulk claim job                      
Added By:           Accenture  - Ashutosh -12/01/2021
Modified By:        Date:       Changes: 
*************************************************************************************************************/
    public static void generateBatchChaining(Datetime runStartTime) {
        //CRON expression - hold schedule time to run batch
        String nextRunCron;
        String claimBatchJobName;
        //Adding X minutes to current time to calculate next run time
        Integer minuteValue = Integer.ValueOf(Core_MDF_Configuration__c.getValues('BULK_CLAIM_JOB_MINUTES').Core_MDF_Value__c);
        Boolean skipSameDayCheck = Boolean.ValueOf(Core_MDF_Configuration__c.getValues('BULK_CLAIM_SKIP_SAMEDAY_CHECK').Core_MDF_Value__c);
        DateTime nextRunTime = system.now().addMinutes(minuteValue);
        Integer scheduledJobLimit = Integer.ValueOf(Core_MDF_Configuration__c.getValues('BULK_CLAIM_SCHEDULED_JOB_LIMIT').Core_MDF_Value__c);
        // check if next run time day is same day is today, yes - schedule run after x minutes, else - skip
        if(skipSameDayCheck || (!skipSameDayCheck && nextRunTime.isSameDay(runStartTime))) {
            Integer currentJobCount = getScheduledApexJobCount();
            // check if current scheduled job count is less than job limit
            if(currentJobCount < scheduledJobLimit) {
                nextRunCron = 0+' '+nextRunTime.minute()+' '+nextRunTime.hour()+' '+nextRunTime.day()+'-'+nextRunTime.day()+' '+nextRunTime.month()+'  ? '+nextRunTime.year();
                // provide unique name to job
                Double randomNum = math.random();
                claimBatchJobName = 'CCP_MDF_BulkClaimJob_'+nextRunTime+'_'+randomNum ;
                string jobId = System.schedule(claimBatchJobName, nextRunCron, new Core_MDF_ClaimInsert_Schedule(runStartTime));
            }
            else {
                // log custom exception 
                String excMessage = Core_MDF_Configuration__c.getValues('BULK_CLAIM_MAX_JOB_EXCEPTION_MESSAGE').Core_MDF_Value__c;
                Core_MDF_CCP_UtilityClass.logError(new customException(excMessage));
            }
        }
    }
    
    /************************************************************************************************************ 
Method Name:        getScheduledApexJobCount
@return  :          Integer
@parameters:        
Description:        This method will return the current count of job scheduled.          
Added By:           Accenture  - Ashutosh -12/01/2021
Modified By:        Date:       Changes: 
*************************************************************************************************************/
    public static Integer getScheduledApexJobCount() {
        Integer  jobCount = 0;
        jobCount = [SELECT COUNT() FROM Crontrigger WHERE cronjobDetail.JobType = '7' and State NOT IN ('DELETED','COMPLETE','ERROR')];
        return jobCount;
    } 
    // cutom exception class to generate custom exception
    public class customException extends Exception{}   
}