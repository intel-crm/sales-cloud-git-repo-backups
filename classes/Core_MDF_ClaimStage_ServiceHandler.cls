/*
* Class Name  : Core_MDF_ClaimStage_ServiceHandler 
* Version     : 1.0 
* Created Date: 02-04-2019
* Modification Log :
* Developer               Date                          Description 
* -----------------------------------------------------------------------------------------------------------------------------------------------------
* Accenture – JV         03/04/2019                    Created Core_MDF_ClaimStage_ServiceHandler as a Validator Class for checking 
the With Sharing Transactions
-------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public with sharing class Core_MDF_ClaimStage_ServiceHandler {
    
    public static Core_MDF_Claim_Batch__c batch;
    public static List<Core_MDF_CCP_Custom_Metadata_Utility__c> lstBulkUploadMappings;
    public static List<PartnerFundClaim> duplicateClaimsList;
    public static List<PartnerFundClaim> nonduplicateClaimsList;
    

     /************************************************************************************************************ 
Method Name:        isValidForReprocessing
@return  :          void
@parameters:        List<List<Core_MDF_Claim_Batch_Stage__c>> List of list  of stage claims
                
Added By:           Bishal Singh 06-01-2021
Modified By:        Date:       Changes: 
	        06-01-2021   This method will return true or false to the flow after we are checking the validation of the claim stage records
*************************************************************************************************************/ 
    @InvocableMethod
    public static List<boolean> isValidForReprocessing(List<List<Core_MDF_Claim_Batch_Stage__c>> claimstageList){
        List<Boolean> updateStageRecordFields = new List<Boolean>();
        List<Core_MDF_Claim_Batch_Stage__c> claimStageUpdatedList = new List<Core_MDF_Claim_Batch_Stage__c>();
        Boolean updateStageRecord=false;
        try{
            //check claimstageList is greater than 0
            
            if(claimstageList != null && claimstageList.size()>0 && claimstageList[0]!= null && claimstageList[0].size()>0){
                claimStageUpdatedList = isValidOnInsert(claimstageList[0]);
            }

            if(claimStageUpdatedList!= null && claimStageUpdatedList.size()>0){                
                Database.update(claimStageUpdatedList);
                updateStageRecord = true;
            }
          }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
            updateStageRecordFields.add(updateStageRecord);
            return updateStageRecordFields;
    }

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

        //To check the basic validations before processing the bulk claim upload
    public static List<Core_MDF_Claim_Batch_Stage__c> isValidOnInsert(List<Core_MDF_Claim_Batch_Stage__c> newclaimStageList)
    {
        system.debug('claimstageList::'+newclaimStageList);
        List<Core_MDF_Claim_Batch_Stage__c> claimStage = new List<Core_MDF_Claim_Batch_Stage__c>();
        if(newclaimStageList != NULL && newclaimStageList.size() > 0)
        {
            batch = [SELECT Id, Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c FROM Core_MDF_Claim_Batch__c WHERE Id = :newclaimStageList[0].Core_MDF_Batch_ID__c LIMIT 1];
            system.debug('batchvd:::'+batch);
            /*lstBulkUploadMappings = [SELECT Core_MDF_Stage_Field_API_Name__c, Core_MDF_Field_DataType_Txt__c,
                                     Core_MDF_Stage_Required_Ind__c
                                     FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                     WHERE Core_MDF_Channel_program__c = :batch.Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c
                                     AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText];*/
            //lstBulkUploadMappings = [SELECT Core_MDF_Field_2_txt__c, Core_MDF_Field_1_txt__c, Core_MDF_Checkbox_Field_1_Ind__c FROM Core_MDF_CCP_Custom_Metadata_Utility__c WHERE Core_MDF_Program__c = :batch.Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c AND Core_MDF_Sub_Category__c =:Label.Core_MDF_PFCText AND Core_MDF_Category__c =:Core_MDF_CCP_ConstantClass.BULK_CLAIM_TEMPLATE];
            String whereClause = 'Core_MDF_Program__c = \'' + batch.Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c + '\' ' + 'AND Core_MDF_Sub_Category__c = \'' + Label.Core_MDF_PFCText + '\' ' + 'AND Core_MDF_Category__c = \'' + Core_MDF_CCP_ConstantClass.BULK_CLAIM_TEMPLATE + '\' ';
        	lstBulkUploadMappings = Core_MDF_Custom_Metadata_Utility.getCustomObjectRecords(whereClause);

            claimStage = isValidForInsert(newclaimStageList);
          system.debug('claimstageNNN::'+claimStage);
        }
        return claimStage;
        
    }
    
    
    /************************************************************************************************************ 
Method Name:        isValidForInsert
@return  :          void
@parameters:        List<Core_MDF_Claim_Batch_Stage__c> List of stage claims
Description:        This method will check if the claim data input by users satisfies all the basic validations 
and sends them for further processing                    
Added By:           Intel  - Sarah Manuel - 07/04/2019
Modified By:        Date:       Changes: 
Intel - SM	        07/04/2019    This method will check if the claim data input by users satisfies all the basic validations 
and sends them for further processing  
*************************************************************************************************************/  
    
    public static List<Core_MDF_Claim_Batch_Stage__c> isValidForInsert(List<Core_MDF_Claim_Batch_Stage__c> newclaimStageList)
    {
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Core_MDF_Claim_Batch_Stage__c').getDescribe().fields.getMap();
        //To store the labels of the stage fields
        Boolean updateStageRecords = false;
        List<Core_MDF_Claim_Batch_Stage__c> claimStageList = new List<Core_MDF_Claim_Batch_Stage__c>();
      
        Map<String,String> fieldToLabelMap = new Map<String,String>();
        for(Core_MDF_CCP_Custom_Metadata_Utility__c iBU : lstBulkUploadMappings)
        {
            string key = iBU.Core_MDF_Field_2_txt__c;
            fieldToLabelMap.put(key, fieldMap.get(key).getDescribe().getLabel());
        }
        List<Core_MDF_Claim_Batch_Stage__c> claimStgRecordsForIns = new List<Core_MDF_Claim_Batch_Stage__c>();
        List<String> missingFields = new List<String>();
        //Checking the required fields
        system.debug('newclaimStageList:::::::b'+newclaimStageList);
        for(Core_MDF_Claim_Batch_Stage__c iClaimStg : newclaimStageList)
        {
            missingFields.clear();
            String errorText = Label.Core_MDF_Claim_Req_Field_Error;
            //MandatoryErrorHeaderText
            Boolean mandatoryErrorHeaderText = TRUE;
            if(iClaimStg.Core_MDF_Message_Txt__c == NULL)
            {
                iClaimStg.Core_MDF_Message_Txt__c = '';
            }
            
            //Iterating all the fields for checking the required field is filled or not. Records which have all the required fields will be sent to creation method
            for(Core_MDF_CCP_Custom_Metadata_Utility__c iBU : lstBulkUploadMappings)
            {	
                if(iBU.Core_MDF_Checkbox_Field_1_Ind__c && (iClaimStg.get(iBU.Core_MDF_Field_2_txt__c) == null))
                {system.debug('hereiam22::');
                    if(mandatoryErrorHeaderText)
                    {
                        iClaimStg.Core_MDF_Message_Txt__c = errorText+' '; 
                        mandatoryErrorHeaderText = FALSE;
                        system.debug('hereiam::');
                    }
                    missingFields.add(fieldToLabelMap.get(iBU.Core_MDF_Field_2_txt__c));
                    
                }
            }
            system.debug('missingFields::'+missingFields);
            //Add the missing field labels to the message box
            if(missingFields != Null && missingFields.size() > 0)
            {
                iClaimStg.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Failed;
                iClaimStg.Core_MDF_Message_Txt__c += String.join(missingFields,', ');
            }
            else{
                // change the Failed status to Successful 
                iClaimStg.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Status_Submitted;
            }
        }
        system.debug('listvd:::'+newclaimStageList);
        //Seperate successful stage records to be sent for accessibility check                               
        for(Core_MDF_Claim_Batch_Stage__c iClaimStg : newclaimStageList)
        {
            if(!Label.Core_MDF_Claim_Batch_Failed.equals((iClaimStg.Core_MDF_Processing_Status_Nm__c)))
            {	
                system.debug('Insidpe:::VD');
                claimStgRecordsForIns.add(iClaimStg);
            } 
        } 
        //Send the valid stage records for checking the users accessiblity
        if(claimStgRecordsForIns.size() > 0 && claimStgRecordsForIns[0].Core_MDF_Batch_ID__c != NULL)
        { 
            system.debug('testHere::');
          claimStageList = Core_MDF_BatchClaimHelper.checkAccessiblityForInsertAndUpdate(claimStgRecordsForIns); //inserting records into stage,if any error adding that error to that stage claim record
            
        }
        return claimStageList;
    }
    
    //To check the basic validations before processing the Design registrations and its products
    public static void isValidOnUpdate(List<Core_MDF_Claim_Batch_Stage__c> newClaimStageList, Map<Id,Core_MDF_Claim_Batch_Stage__c> oldClaimStageMap,Map<Id,Core_MDF_Claim_Batch_Stage__c> newclaimStageMap)
    {
    system.debug('in isValidOnUpdate');
        if(newClaimStageList != NULL && newClaimStageList.size() > 0)
        {
            // To create global Map for custom metadata
            batch = [SELECT Id, Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c FROM Core_MDF_Claim_Batch__c WHERE Id = :newClaimStageList[0].Core_MDF_Batch_ID__c LIMIT 1];
            /*lstBulkUploadMappings = [SELECT Core_MDF_Stage_Field_API_Name__c, Core_MDF_Field_DataType_Txt__c,
                                     Core_MDF_Stage_Required_Ind__c
                                     FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                     WHERE Core_MDF_Channel_program__c = :batch.Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c
                                     AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText];*/
            //lstBulkUploadMappings = [SELECT Core_MDF_Field_2_txt__c, Core_MDF_Field_1_txt__c, Core_MDF_Checkbox_Field_1_Ind__c FROM Core_MDF_CCP_Custom_Metadata_Utility__c WHERE Core_MDF_Program__c = :batch.Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c AND Core_MDF_Sub_Category__c =:Label.Core_MDF_PFCText AND Core_MDF_Category__c =:Core_MDF_CCP_ConstantClass.BULK_CLAIM_TEMPLATE];
            String whereClause = 'Core_MDF_Program__c = \'' + batch.Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c + '\' ' + 'AND Core_MDF_Sub_Category__c = \'' + Label.Core_MDF_PFCText + '\' ' + 'AND Core_MDF_Category__c = \'' + Core_MDF_CCP_ConstantClass.BULK_CLAIM_TEMPLATE + '\' ';
        	lstBulkUploadMappings = Core_MDF_Custom_Metadata_Utility.getCustomObjectRecords(whereClause);

            // List<Core_MDF_Claim_Batch_Stage__c> : Claim Stage List which contains modified Stage Records
            List<Core_MDF_Claim_Batch_Stage__c> claimStageListToBeProcessed = new List<Core_MDF_Claim_Batch_Stage__c>();
            // check whether there was a change on editable fields and if status of the stage record is Failed
            for(Core_MDF_Claim_Batch_Stage__c claimStageRecord: newClaimStageList){
                if(claimStageRecord.Id == oldClaimStageMap.get(claimStageRecord.Id).Id 
                   &&(Label.Core_MDF_Claim_Batch_Failed.equals(claimStageRecord.Core_MDF_Processing_Status_Nm__c) || claimStageRecord.Core_MDF_Processing_Status_Nm__c == Label.Core_MDF_Status_PendingDocuments )
                   &&(Core_MDF_BatchClaimHelper.isClaimStageRecordEdited(claimStageRecord,oldClaimStageMap,lstBulkUploadMappings))
                  ){
                      claimStageRecord.Core_MDF_Message_Txt__c = '';
                      claimStageListToBeProcessed.add(claimStageRecord);
                  }
            }
            System.debug('claimStageListToBeProcessed::'+claimStageListToBeProcessed);
            // Call the checkValidationsForUpdate process passing the claimStageListToBeProcessed
            if(claimStageListToBeProcessed != NULL && claimStageListToBeProcessed.size() > 0){
                isValidForUpdate(claimStageListToBeProcessed,newclaimStageMap);
            }
        }
        
        
    }
    
    //To check the basic validations before processing the Claim Stage Records 
    public static void isValidForUpdate(List<Core_MDF_Claim_Batch_Stage__c> claimStageListToBeProcessed,Map<Id,Core_MDF_Claim_Batch_Stage__c> newclaimStageMap)
    {
        system.debug('in isValidForUpdate');
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Core_MDF_Claim_Batch_Stage__c').getDescribe().fields.getMap();
        //To store the labels of the stage fields
        Map<String,String> fieldToLabelMap = new Map<String,String>();
        List<String> missingFields = new List<String>();
        for(Core_MDF_CCP_Custom_Metadata_Utility__c iBU : lstBulkUploadMappings)
        {
            string key = iBU.Core_MDF_Field_2_txt__c;
            fieldToLabelMap.put(key, fieldMap.get(key).getDescribe().getLabel());
        }
        List<Core_MDF_Claim_Batch_Stage__c> claimStgRecordsForIns = new List<Core_MDF_Claim_Batch_Stage__c>();
        
        //Checking the required fields
        for(Core_MDF_Claim_Batch_Stage__c iClaimStg : claimStageListToBeProcessed)
        {   
            String errorText = Label.Core_MDF_Claim_Req_Field_Error;
            Boolean mandatoryErrorHeaderText = TRUE;
            missingFields.clear();
            //Iterating all the fields for checking the required field is filled or not. Records which have all the required fields will be sent to creation method
            for(Core_MDF_CCP_Custom_Metadata_Utility__c iBU : lstBulkUploadMappings)
            {	
                if(iBU.Core_MDF_Checkbox_Field_1_Ind__c && (newclaimStageMap.get(iClaimStg.Id).get(iBU.Core_MDF_Field_2_txt__c) == null))
                {
                    newclaimStageMap.get(iClaimStg.Id).Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Failed;
                    
                    if(mandatoryErrorHeaderText)
                    {
                        newclaimStageMap.get(iClaimStg.Id).Core_MDF_Message_Txt__c = errorText + ' ';                        
                        mandatoryErrorHeaderText = FALSE;
                    }
                    missingFields.add(fieldToLabelMap.get(iBU.Core_MDF_Field_2_txt__c));
                }else{
                    system.debug('entered @@@');
                    // change the Failed status to Successful 
                    newclaimStageMap.get(iClaimStg.Id).Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Status_Submitted;
                }
                //Add the missing field labels to the meesage box
                if(missingFields != Null && missingFields.size() > 0)
                {
                    newclaimStageMap.get(iClaimStg.Id).Core_MDF_Message_Txt__c += String.join(missingFields,', ');
                    //Clear missing field list
                    missingFields.clear();
                }
            }    
        }
        //Seperate the failed records from list for update stage records with proper message and adding the unfailed records for processing                                
        for(Core_MDF_Claim_Batch_Stage__c iClaimStg : claimStageListToBeProcessed)
        {
            //if(Label.Core_MDF_In_Progress_Status.equals(iClaimStg.Core_MDF_Processing_Status_Nm__c))//commented by VD
            if(Label.Core_MDF_Status_Submitted.equals(iClaimStg.Core_MDF_Processing_Status_Nm__c))
            {
                claimStgRecordsForIns.add(iClaimStg);
            } 
        } 
        
        if(claimStgRecordsForIns.size() > 0 && claimStgRecordsForIns[0].Core_MDF_Batch_ID__c != NULL) 
        { 
            Core_MDF_BatchClaimHelper.checkAccessiblityForInsertAndUpdate(claimStgRecordsForIns);
            
        }
    }

    /**
* @description               : This method is used to check the duplicate Claims from the input claimsToBeProcessed, 
								And Update the corresponding Claim Stage Records 
* @param claimsToBeProcessed : List of Claims to be checked for duplicate 
* Added By                   : Accenture - JV  - 07/04/2019
*/
    public static stageAndClaimRecWrapper handleDuplicateClaims(List<PartnerFundClaim> claimsToBeProcessed,stageAndClaimRecWrapper wrapInst){    
        // check the duplicates for input claim list within the list and with the DB
        Core_MDF_Claim_Utility.duplicateClaimCheckOnInsert(claimsToBeProcessed);
        system.debug('in handleDuplicateClaims');
       // stageAndClaimRecWrapper wrapInst = new stageAndClaimRecWrapper();
        
        nonduplicateClaimsList = nonduplicateClaimsList == null ? new List<PartnerFundClaim>() : nonduplicateClaimsList;
        
        for(PartnerFundClaim pfc : claimsToBeProcessed){
            if(pfc.Core_MDF_Duplicate_Claim__c){
                Core_MDF_Claim_Batch_Stage__c stageRecord = new Core_MDF_Claim_Batch_Stage__c();
                stageRecord.Id=pfc.Core_MDF_Claim_Batch_Stage__c;
                stageRecord.Core_MDF_Is_Duplicate_ind__c = TRUE;
                stageRecord.Core_MDF_Message_txt__c = stageRecord.Core_MDF_Message_txt__c == NUll ? Label.Core_MDF_BulkClaim_DuplicateMessage : stageRecord.Core_MDF_Message_txt__c +'\n'+ Label.Core_MDF_BulkClaim_DuplicateMessage;
                stageRecord.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Failed;
                wrapInst.failedStageRecordsList.add(stageRecord);
            }else{
                // update the isduplicate to false 
                Core_MDF_Claim_Batch_Stage__c stageRecord = new Core_MDF_Claim_Batch_Stage__c();
                stageRecord.Id=pfc.Core_MDF_Claim_Batch_Stage__c;
                stageRecord.Core_MDF_Is_Duplicate_ind__c = FALSE;
                //clear off the message
                stageRecord.Core_MDF_Message_txt__c = '';
                wrapInst.nonduplicateClaims.add(pfc);
            } 
        }
        return wrapInst;
    }
    
    /**
* @description               : This method is used to check the duplicate Claims from the input claimsToBeProcessed, 
And pass the claimsToBeProcessed for duplicates to handleDuplicateClaims method
* @param claimsToBeProcessed : List of Claims to be checked for duplicate on Update of Claim Stage Record
* Added By                   : Accenture - JV  - 07/04/2019
*/
    public static stageAndClaimRecWrapper handleDuplicateClaimsOnUpdate(List<PartnerFundClaim> claimsToBeProcessed,stageAndClaimRecWrapper wrapperInst){
       // stageAndClaimRecWrapper wrapperInst = new stageAndClaimRecWrapper();
        system.debug('handleDuplicateClaimsOnUpdate' + claimsToBeProcessed +'---'+wrapperInst);
        
        Set<Id> claimStageSet = new Set<Id>();
        List<Id> claimStageListNotToBeProcessedForDuplicate = new List<Id>();
        List<PartnerFundClaim> claimListNotToBeProcessedForDuplicate = new List<PartnerFundClaim>();
        List<PartnerFundClaim> claimListToBeProcessedForDuplicate = new List<PartnerFundClaim>();
        
        // initialize the global nonduplicateClaimsList
        nonduplicateClaimsList = new List<PartnerFundClaim>(); 
        
        /* query on claim List to filter out the claims for which corresponding stage record's "Create Duplicate" flag
		is checked */
        for(PartnerFundClaim pfc:claimsToBeProcessed){
            claimStageSet.add(pfc.Core_MDF_Claim_Batch_Stage__c);
        }
        
        for(Core_MDF_Claim_Batch_Stage__c claimStageRecord: [SELECT Id,Core_MDF_Claim_Nm__c,Core_MDF_Request_Id__c,Core_MDF_Bank_Id__c,
                                                             Core_MDF_Ad_Run_Start_Dt__c,Core_MDF_Ad_Run_End_Dt__c,Core_MDF_Media_Vehicle_txt__c,
                                                             Core_MDF_Impressions_Cnt__c,Core_MDF_Inv_Receipt_Dt__c,Core_MDF_Inv_Receipt_Nbr__c,
                                                             Core_MDF_Inv_Receipt_Cur_Cd__c,Core_MDF_Taxes_Local_Amt__c,Core_MDF_Non_Reimbursable_Amt__c,
                                                             Core_MDF_Claim_Comment_txt__c,Core_MDF_Total_Amt__c,Core_MDF_Batch_ID__r.Name,
                                                             Core_MDF_Is_Duplicate_ind__c,Core_MDF_Create_Duplicate_ind__c 
                                                             FROM Core_MDF_Claim_Batch_Stage__c
                                                             WHERE ID IN:claimStageSet 
                                                             AND Core_MDF_Create_Duplicate_ind__c = TRUE])
        {
            if(claimStageRecord.Core_MDF_Is_Duplicate_ind__c  && claimStageRecord.Core_MDF_Create_Duplicate_ind__c ){
                claimStageListNotToBeProcessedForDuplicate.add(claimStageRecord.Id);
            }
        }
        
        for(PartnerFundClaim pfc:claimsToBeProcessed){
            if(claimStageListNotToBeProcessedForDuplicate.contains(pfc.Core_MDF_Claim_Batch_Stage__c)){
                nonduplicateClaimsList.add(pfc);
                claimListNotToBeProcessedForDuplicate.add(pfc);
            }else{
                claimListToBeProcessedForDuplicate.add(pfc);
            }
        }
        // Call the duplicate method handler for Insert for processing the Claims to be checked for Duplicate  
        if(claimListToBeProcessedForDuplicate != null && claimListToBeProcessedForDuplicate.size()>0){                                                                                    
           wrapperInst = handleDuplicateClaims(claimListToBeProcessedForDuplicate,wrapperInst);
        }
        if(claimListNotToBeProcessedForDuplicate != null && claimListNotToBeProcessedForDuplicate.size()>0){
            wrapperInst.nonduplicateClaims.addAll(claimListNotToBeProcessedForDuplicate); 
        }
        return wrapperInst;
    }
    
    /**
* @description : This method is used get the Edited Claim Batch Stage Records 
* @param claimStageListToBeProcessed : New Claim Stage Record list from the Trigger
*/
    public static List<Core_MDF_Claim_Batch_Stage__c> getUpdatedStageRecordList(List<Core_MDF_Claim_Batch_Stage__c> claimStageListToBeProcessed, Map<Id,Core_MDF_Claim_Batch_Stage__c> oldClaimStageMap){
        
        List<Core_MDF_Claim_Batch_Stage__c> updatedStageRecordList = new List<Core_MDF_Claim_Batch_Stage__c>();
        
        for(Core_MDF_Claim_Batch_Stage__c claimStageRecord : claimStageListToBeProcessed){
            
            if(Core_MDF_BatchClaimHelper.isClaimStageRecordEdited(claimStageRecord,oldClaimStageMap,lstBulkUploadMappings)){
                updatedStageRecordList.add(claimStageRecord);
            }
        }
        system.debug('updatedStageRecordList::'+updatedStageRecordList);
        return updatedStageRecordList;
    }
    
    
    /****************************************************************************************************************************************
* Class Name  :  Core_MDF_ClaimStage_ServiceHandler
* Version     : 1.0 
* Created Date: 22-DEC-2020
* Modification Log :
* Developer            		Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Bishal       22-DEC-2020         Used to Update the Status of Claim Batch Status to either submitted,Failed or Sucessful
*****************************************************************************************************************************************/
    public static void statusUpdateClaimBatch(List<Core_MDF_Claim_Batch_Stage__c> newClaimStageList,Map<Id,Core_MDF_Claim_Batch_Stage__c> oldClaimStageMap){
        
        Set<id> batchClaimIds = new Set<id>();
        try{
        for(Core_MDF_Claim_Batch_Stage__c claimStageList : newClaimStageList){    
            // Comparing the old status with new status if true then only go inside.
            if(claimStageList.Core_MDF_Processing_Status_Nm__c != oldClaimStageMap.get(claimStageList.id).Core_MDF_Processing_Status_Nm__c){
                batchClaimIds.add(claimStageList.Core_MDF_Batch_ID__c);
                
            }
        }                    
            updateClaimBatch(batchClaimIds);
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e); throw e;
        }
        
    }
    
    
    public static void statusUpdateClaimBatchStageDeletion(List<Core_MDF_Claim_Batch_Stage__c> oldrecord){
         Set<Id> batchClaimIds = new Set<Id>();
        try{
            for(Core_MDF_Claim_Batch_Stage__c claimStageList : oldrecord){
                batchClaimIds.add(claimStageList.Core_MDF_Batch_ID__c);
            }
            
            if(!batchClaimIds.isEmpty()){
                updateClaimBatch(batchClaimIds);
            }
        }catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e); throw e;
        }
        
    }
    public static void updateClaimBatch(Set<Id> batchClaimIds){
        Map<id,String> claimBatchNewStatus = new Map<id,String>();
        Map<id,String> claimBatchOldStatus = new Map<id,String>();
        for(Core_MDF_Claim_Batch_Stage__c claimBatchStage : [select id,Core_MDF_Processing_Status_Nm__c, Core_MDF_Batch_ID__r.id,Core_MDF_Batch_ID__r.Core_MDF_ClaimBatch_Status_Nm__c,Core_MDF_Batch_ID__r.Core_MDF_Send_Email__c from Core_MDF_Claim_Batch_Stage__c where Core_MDF_Batch_ID__c IN :batchClaimIds]){
            //Creating Map with claim batch id as key and claim batch status as Value
            claimBatchOldStatus.put(claimBatchStage.Core_MDF_Batch_ID__c,claimBatchStage.Core_MDF_Batch_ID__r.Core_MDF_ClaimBatch_Status_Nm__c);
            //check if claim batch stage status is Pending Documents
            if(claimBatchStage.Core_MDF_Processing_Status_Nm__c.equals(Label.Core_MDF_Status_PendingDocuments)){
                claimBatchNewStatus.put(claimBatchStage.Core_MDF_Batch_ID__c,Label.Core_MDF_Status_PendingDocuments);
            
            //check if claim batch stage status is Submitted
            }else if(claimBatchStage.Core_MDF_Processing_Status_Nm__c.equals(Label.Core_MDF_Status_Submitted) && claimBatchNewStatus.get(claimBatchStage.Core_MDF_Batch_ID__c) != Label.Core_MDF_Status_PendingDocuments){
                claimBatchNewStatus.put(claimBatchStage.Core_MDF_Batch_ID__c,Label.Core_MDF_Status_Submitted);
                
              //check if claim batch stage status is Failed 
            }else if(claimBatchStage.Core_MDF_Processing_Status_Nm__c.equals(Label.Core_MDF_Claim_Batch_Failed) && claimBatchNewStatus.get(claimBatchStage.Core_MDF_Batch_ID__c) != Label.Core_MDF_Status_PendingDocuments && claimBatchNewStatus.get(claimBatchStage.Core_MDF_Batch_ID__c) != Label.Core_MDF_Status_Submitted){
                claimBatchNewStatus.put(claimBatchStage.Core_MDF_Batch_ID__c,Label.Core_MDF_Claim_Batch_Failed);
                
              //check if claim batch stage status is Successful
            }else if(claimBatchStage.Core_MDF_Processing_Status_Nm__c.equals(Label.Core_MDF_Claim_Batch_Successful) && claimBatchNewStatus.get(claimBatchStage.Core_MDF_Batch_ID__c) != Label.Core_MDF_Status_PendingDocuments && claimBatchNewStatus.get(claimBatchStage.Core_MDF_Batch_ID__c) != Label.Core_MDF_Status_Submitted && claimBatchNewStatus.get(claimBatchStage.Core_MDF_Batch_ID__c) != Label.Core_MDF_Claim_Batch_Failed){
                claimBatchNewStatus.put(claimBatchStage.Core_MDF_Batch_ID__c,Label.Core_MDF_Claim_Batch_Successful);
               
            }
        }
        List<Core_MDF_Claim_Batch__c> claimBatchUpdateList = new List<Core_MDF_Claim_Batch__c>();
        for(Id claimBatchId : claimBatchNewStatus.keyset()){
           Boolean checkStatus = false;
            //checking if status is failed or succesful and making the boolean as true for sending email.
            if(claimBatchNewStatus.get(claimBatchId) == Label.Core_MDF_Claim_Batch_Failed || claimBatchNewStatus.get(claimBatchId) == Label.Core_MDF_Claim_Batch_Successful){
                checkStatus = true;
            }
             //checking if status is changed then updating the claim Batch status with the changed status
            if(claimBatchNewStatus.get(claimBatchId) <> claimBatchOldStatus.get(claimBatchId)) {
                claimBatchUpdateList.add(new Core_MDF_Claim_Batch__c(Id=claimBatchId,Core_MDF_ClaimBatch_Status_Nm__c=claimBatchNewStatus.get(claimBatchId),Core_MDF_Send_Email__c=checkStatus));
            }
        }
        if(!claimBatchUpdateList.isEmpty()) {
            update claimBatchUpdateList;
        }
    }
    
    /****************************************************************************************************************************************
* Class Name  :  Core_MDF_ClaimStage_ServiceHandler
* Version     : 1.0 
* Created Date: 22-DEC-2020
* Modification Log :
* Developer            		Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Bishal       04-JAN-2020         Used when we are Inserting the claim batch record to check the Status of Claim Batch Status to either submitted,Failed or Sucessful
*****************************************************************************************************************************************/
    
    
    public static void statusUpdateClaimBatchOnAfterInsert(List<Core_MDF_Claim_Batch_Stage__c> newclaimStageList){
       Set<id> batchClaimInsertIds = new Set<id>();
        try{
        for(Core_MDF_Claim_Batch_Stage__c claimStageList : newClaimStageList){    
                batchClaimInsertIds.add(claimStageList.Core_MDF_Batch_ID__c);
        }        
        Map<id,String> claimBatchInsertNewStatus = new Map<id,String>();
        Map<id,String> claimBatchInsertOldStatus = new Map<id,String>();
        for(Core_MDF_Claim_Batch_Stage__c claimBatchStage : [select id,Core_MDF_Processing_Status_Nm__c, Core_MDF_Batch_ID__r.id,Core_MDF_Batch_ID__r.Core_MDF_ClaimBatch_Status_Nm__c,Core_MDF_Batch_ID__r.Core_MDF_Send_Email__c from Core_MDF_Claim_Batch_Stage__c where Core_MDF_Batch_ID__c IN :batchClaimInsertIds]){
            //Creating Map with claim batch id as key and claim batch status as Value
          
            claimBatchInsertOldStatus.put(claimBatchStage.Core_MDF_Batch_ID__c,claimBatchStage.Core_MDF_Batch_ID__r.Core_MDF_ClaimBatch_Status_Nm__c);
            //check if claim batch stage status is Pending Documents
            if(claimBatchStage.Core_MDF_Processing_Status_Nm__c.equals(Label.Core_MDF_Status_PendingDocuments)){
                claimBatchInsertNewStatus.put(claimBatchStage.Core_MDF_Batch_ID__c,Label.Core_MDF_Status_PendingDocuments);
            
            //check if claim batch stage status is Submitted
            }else if(claimBatchStage.Core_MDF_Processing_Status_Nm__c.equals(Label.Core_MDF_Status_Submitted) && claimBatchInsertNewStatus.get(claimBatchStage.Core_MDF_Batch_ID__c) != Label.Core_MDF_Status_PendingDocuments){
                claimBatchInsertNewStatus.put(claimBatchStage.Core_MDF_Batch_ID__c,Label.Core_MDF_Status_Submitted);
                
              //check if claim batch stage status is Failed 
            }else if(claimBatchStage.Core_MDF_Processing_Status_Nm__c.equals(Label.Core_MDF_Claim_Batch_Failed) && claimBatchInsertNewStatus.get(claimBatchStage.Core_MDF_Batch_ID__c) != Label.Core_MDF_Status_PendingDocuments && claimBatchInsertNewStatus.get(claimBatchStage.Core_MDF_Batch_ID__c) != Label.Core_MDF_Status_Submitted){
                claimBatchInsertNewStatus.put(claimBatchStage.Core_MDF_Batch_ID__c,Label.Core_MDF_Claim_Batch_Failed);
                
              //check if claim batch stage status is Successful
            }else if(claimBatchStage.Core_MDF_Processing_Status_Nm__c.equals(Label.Core_MDF_Claim_Batch_Successful) && claimBatchInsertNewStatus.get(claimBatchStage.Core_MDF_Batch_ID__c) != Label.Core_MDF_Status_PendingDocuments && claimBatchInsertNewStatus.get(claimBatchStage.Core_MDF_Batch_ID__c) != Label.Core_MDF_Status_Submitted && claimBatchInsertNewStatus.get(claimBatchStage.Core_MDF_Batch_ID__c) != Label.Core_MDF_Claim_Batch_Failed){
                claimBatchInsertNewStatus.put(claimBatchStage.Core_MDF_Batch_ID__c,Label.Core_MDF_Claim_Batch_Successful);
               
            }
        }
        List<Core_MDF_Claim_Batch__c> claimBatchInsertList = new List<Core_MDF_Claim_Batch__c>();
        for(Id claimBatchId : claimBatchInsertNewStatus.keyset()){
             Boolean checkInsertStatus = false;
            //checking if status is failed or succesful and making the boolean as true for sending email.
            if(claimBatchInsertNewStatus.get(claimBatchId) == Label.Core_MDF_Claim_Batch_Failed || claimBatchInsertNewStatus.get(claimBatchId) == Label.Core_MDF_Claim_Batch_Successful){
                checkInsertStatus = true;
            }
            //checking if status is changed then updating the claim Batch status with the changed status
            if(claimBatchInsertNewStatus.get(claimBatchId) <> claimBatchInsertOldStatus.get(claimBatchId)) {
                
                claimBatchInsertList.add(new Core_MDF_Claim_Batch__c(Id=claimBatchId,Core_MDF_ClaimBatch_Status_Nm__c=claimBatchInsertNewStatus.get(claimBatchId),Core_MDF_Send_Email__c=checkInsertStatus));
            }
        }
       
        	if(!claimBatchInsertList.isEmpty()) {
        		update claimBatchInsertList;
        	}
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e); throw e;
        }
         
    }
      /*
	* Class Name  : Core_MDF_ClaimStage_ServiceHandler 
	* Version     : 1.0 
	* Created Date: 02-04-2019
	* Modification Log :
	* Developer               Date                          Description 
	  Vaishali				05-Jan-2021						This is to store List of claim and failed duplicate stage records
     */   
    public class stageAndClaimRecWrapper{
        public List<PartnerFundClaim> nonduplicateClaims = new List<PartnerFundClaim>();
        public List<Core_MDF_Claim_Batch_Stage__c> failedStageRecordsList = new List<Core_MDF_Claim_Batch_Stage__c>();

        //Roshan - Tactics POC
        public Map<Id, List<Core_MDF_Claim_Attributes__c>> claimStageIdToClaimAttributesMap = new Map<Id, List<Core_MDF_Claim_Attributes__c>>();
        public Map<Id, Integer> claimStageIdToQuantityToDateMap = new Map<Id, Integer>();
    }  
}