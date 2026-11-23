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
    public static List<Core_MDF_BulkClaimTemplateParticulars__mdt> lstBulkUploadMappings;
    public static List<PartnerFundClaim> duplicateClaimsList;
    public static List<PartnerFundClaim> nonduplicateClaimsList;
    
    
    
    //To check the basic validations before processing the bulk claim upload
    public static void isValidOnInsert(List<Core_MDF_Claim_Batch_Stage__c> newclaimStageList)
    {
        if(newclaimStageList != NULL && newclaimStageList.size() > 0)
        {
            batch = [SELECT Id, Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c FROM Core_MDF_Claim_Batch__c WHERE Id = :newclaimStageList[0].Core_MDF_Batch_ID__c LIMIT 1];
            lstBulkUploadMappings = [SELECT Core_MDF_Stage_Field_API_Name__c, Core_MDF_Field_DataType_Txt__c,
                                     Core_MDF_Stage_Required_Ind__c
                                     FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                     WHERE Core_MDF_Channel_program__c = :batch.Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c
                                     AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText];
            isValidForInsert(newclaimStageList);
        }
        
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
    public static void isValidForInsert(List<Core_MDF_Claim_Batch_Stage__c> newclaimStageList)
    {
        
        System.debug('lstBulkUploadMappings'+lstBulkUploadMappings);
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Core_MDF_Claim_Batch_Stage__c').getDescribe().fields.getMap();
        //To store the labels of the stage fields
        Map<String,String> fieldToLabelMap = new Map<String,String>();
        for(Core_MDF_BulkClaimTemplateParticulars__mdt iBU : lstBulkUploadMappings)
        {
            string key = iBU.Core_MDF_Stage_Field_API_Name__c;
            fieldToLabelMap.put(key, fieldMap.get(key).getDescribe().getLabel());
        }
        
        List<Core_MDF_Claim_Batch_Stage__c> claimStgRecordsForIns = new List<Core_MDF_Claim_Batch_Stage__c>();
        List<String> missingFields = new List<String>();
        //Checking the required fields
        for(Core_MDF_Claim_Batch_Stage__c iClaimStg : newclaimStageList)
        {
            System.debug('iClaimStg:'+iClaimStg);
            missingFields.clear();
            String errorText = Label.Core_MDF_Claim_Req_Field_Error;
            //MandatoryErrorHeaderText
            Boolean mandatoryErrorHeaderText = TRUE;
            
            if(iClaimStg.Core_MDF_Message_Txt__c == NULL)
            {
                iClaimStg.Core_MDF_Message_Txt__c = '';
            }
            
            //Iterating all the fields for checking the required field is filled or not. Records which have all the required fields will be sent to creation method
            for(Core_MDF_BulkClaimTemplateParticulars__mdt iBU : lstBulkUploadMappings)
            {	
                if(iBU.Core_MDF_Stage_Required_Ind__c && (iClaimStg.get(iBU.Core_MDF_Stage_Field_API_Name__c) == null))
                {
                    if(mandatoryErrorHeaderText)
                    {
                        iClaimStg.Core_MDF_Message_Txt__c += errorText + '\n'; 
                        mandatoryErrorHeaderText = FALSE;
                    }
                    missingFields.add(fieldToLabelMap.get(iBU.Core_MDF_Stage_Field_API_Name__c));
                    
                }
            }
            //Add the missing field labels to the meesage box
            if(missingFields != Null && missingFields.size() > 0)
            {
                iClaimStg.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Failed;
                iClaimStg.Core_MDF_Message_Txt__c += String.join(missingFields,',');
            }
            else{
                    // change the Failed status to Successful 
                    iClaimStg.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Successful;
                }
        }
        
        //Seperate successful stage records to be sent for accessibility check                               
        for(Core_MDF_Claim_Batch_Stage__c iClaimStg : newclaimStageList)
        {
            if(!Label.Core_MDF_Claim_Batch_Failed.equals((iClaimStg.Core_MDF_Processing_Status_Nm__c)))
            {
                claimStgRecordsForIns.add(iClaimStg);
            } 
        } 
        //Send the valid stage records for checking the users accessiblity
        if(claimStgRecordsForIns.size() > 0 && claimStgRecordsForIns[0].Core_MDF_Batch_ID__c != NULL)
        { 
            Core_MDF_BatchClaimHelper.checkAccessiblityForInsert(claimStgRecordsForIns);
        }
    }
    
    //To check the basic validations before processing the Design registrations and its products
    public static void isValidOnUpdate(List<Core_MDF_Claim_Batch_Stage__c> newClaimStageList, Map<Id,Core_MDF_Claim_Batch_Stage__c> oldClaimStageMap,Map<Id,Core_MDF_Claim_Batch_Stage__c> newclaimStageMap)
    {
        if(newClaimStageList != NULL && newClaimStageList.size() > 0)
        {
            // To create global Map for custom metadata
            batch = [SELECT Id, Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c FROM Core_MDF_Claim_Batch__c WHERE Id = :newClaimStageList[0].Core_MDF_Batch_ID__c LIMIT 1];
            lstBulkUploadMappings = [SELECT Core_MDF_Stage_Field_API_Name__c, Core_MDF_Field_DataType_Txt__c,
                                     Core_MDF_Stage_Required_Ind__c
                                     FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                     WHERE Core_MDF_Channel_program__c = :batch.Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c
                                     AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText];
            
            // List<Core_MDF_Claim_Batch_Stage__c> : Claim Stage List which contains modified Stage Records
            List<Core_MDF_Claim_Batch_Stage__c> claimStageListToBeProcessed = new List<Core_MDF_Claim_Batch_Stage__c>();
            // check whether there was a change on editable fields and if status of the stage record is Failed
            for(Core_MDF_Claim_Batch_Stage__c claimStageRecord: newClaimStageList){
                if(claimStageRecord.Id == oldClaimStageMap.get(claimStageRecord.Id).Id 
                   &&(Label.Core_MDF_Claim_Batch_Failed.equals(claimStageRecord.Core_MDF_Processing_Status_Nm__c))
                   &&(Core_MDF_BatchClaimHelper.isClaimStageRecordEdited(claimStageRecord,oldClaimStageMap,lstBulkUploadMappings))
                  ){
                      claimStageRecord.Core_MDF_Message_Txt__c = '';
                      claimStageListToBeProcessed.add(claimStageRecord);
                  }
            }
            // Call the checkValidationsForUpdate process passing the claimStageListToBeProcessed
            if(claimStageListToBeProcessed != NULL && claimStageListToBeProcessed.size() > 0){
                isValidForUpdate(claimStageListToBeProcessed,newclaimStageMap);
            }
        }
        
        
    }
    
    //To check the basic validations before processing the Claim Stage Records 
    public static void isValidForUpdate(List<Core_MDF_Claim_Batch_Stage__c> claimStageListToBeProcessed,Map<Id,Core_MDF_Claim_Batch_Stage__c> newclaimStageMap)
    {
        
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Core_MDF_Claim_Batch_Stage__c').getDescribe().fields.getMap();
        //To store the labels of the stage fields
        Map<String,String> fieldToLabelMap = new Map<String,String>();
        List<String> missingFields = new List<String>();
        for(Core_MDF_BulkClaimTemplateParticulars__mdt iBU : lstBulkUploadMappings)
        {
            string key = iBU.Core_MDF_Stage_Field_API_Name__c;
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
            for(Core_MDF_BulkClaimTemplateParticulars__mdt iBU : lstBulkUploadMappings)
            {	
                if(iBU.Core_MDF_Stage_Required_Ind__c && (newclaimStageMap.get(iClaimStg.Id).get(iBU.Core_MDF_Stage_Field_API_Name__c) == null))
                {
                    newclaimStageMap.get(iClaimStg.Id).Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Failed;
                    
                    if(mandatoryErrorHeaderText)
                    {
                        newclaimStageMap.get(iClaimStg.Id).Core_MDF_Message_Txt__c += errorText + '\n';
                        mandatoryErrorHeaderText = FALSE;
                    }
                    missingFields.add(fieldToLabelMap.get(iBU.Core_MDF_Stage_Field_API_Name__c));
                }else{
                    // change the Failed status to Successful 
                    newclaimStageMap.get(iClaimStg.Id).Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Successful;
                }
                //Add the missing field labels to the meesage box
                if(missingFields != Null && missingFields.size() > 0)
                {
                    newclaimStageMap.get(iClaimStg.Id).Core_MDF_Message_Txt__c += String.join(missingFields,',');
                }
            }    
        }
        //Seperate the failed records from list for update stage records with proper message and adding the unfailed records for processing                                
        for(Core_MDF_Claim_Batch_Stage__c iClaimStg : claimStageListToBeProcessed)
        {
            if(Label.Core_MDF_Claim_Batch_Successful.equals(iClaimStg.Core_MDF_Processing_Status_Nm__c))
            {
                claimStgRecordsForIns.add(iClaimStg);
            } 
        } 
        
        if(claimStgRecordsForIns.size() > 0 && claimStgRecordsForIns[0].Core_MDF_Batch_ID__c != NULL) 
        { 
            Core_MDF_BatchClaimHelper.checkAccessiblityForUpdate(claimStgRecordsForIns,newclaimStageMap);
            
        }
    }
    
    /**
* @description               : This method is used to check the duplicate Claims from the input claimsToBeProcessed, 
And Update the corresponding Claim Stage Records 
* @param claimsToBeProcessed : List of Claims to be checked for duplicate 
* Added By                   : Accenture - JV  - 07/04/2019
*/
    public static void handleDuplicateClaims(List<PartnerFundClaim> claimsToBeProcessed){
        
        List<Core_MDF_Claim_Batch_Stage__c> failedStageRecords = new List<Core_MDF_Claim_Batch_Stage__c>();
        List<Core_MDF_Claim_Batch_Stage__c> succeessStageRecords = new List<Core_MDF_Claim_Batch_Stage__c>();
        // check the duplicates for input claim list within the list and with the DB
        Core_MDF_Claim_Utility.duplicateClaimCheckOnInsert(claimsToBeProcessed);
        
        nonduplicateClaimsList = nonduplicateClaimsList == null ? new List<PartnerFundClaim>() : nonduplicateClaimsList;
        
        for(PartnerFundClaim pfc : claimsToBeProcessed){
            if(pfc.Core_MDF_Duplicate_Claim__c){
                Core_MDF_Claim_Batch_Stage__c stageRecord = new Core_MDF_Claim_Batch_Stage__c();
                stageRecord.Id=pfc.Core_MDF_Claim_Batch_Stage__c;
                stageRecord.Core_MDF_Is_Duplicate_ind__c = TRUE;
                stageRecord.Core_MDF_Message_txt__c = stageRecord.Core_MDF_Message_txt__c == NUll ? Label.Core_MDF_BulkClaim_DuplicateMessage : stageRecord.Core_MDF_Message_txt__c +'\n'+ Label.Core_MDF_BulkClaim_DuplicateMessage;
                stageRecord.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Failed;
                failedStageRecords.add(stageRecord);
            }else{
                // update the isduplicate to false 
                Core_MDF_Claim_Batch_Stage__c stageRecord = new Core_MDF_Claim_Batch_Stage__c();
                stageRecord.Id=pfc.Core_MDF_Claim_Batch_Stage__c;
                stageRecord.Core_MDF_Is_Duplicate_ind__c = FALSE;
                succeessStageRecords.add(stageRecord);
                nonduplicateClaimsList.add(pfc);
            }
            
        }
        if(failedStageRecords != NULL & failedStageRecords.size() > 0)
        {
            Database.update(failedStageRecords);
        }
        if(succeessStageRecords != NULL & succeessStageRecords.size() > 0)
        {
            Database.update(succeessStageRecords);
        }
    }
    
    /**
* @description               : This method is used to check the duplicate Claims from the input claimsToBeProcessed, 
And pass the claimsToBeProcessed for duplicates to handleDuplicateClaims method
* @param claimsToBeProcessed : List of Claims to be checked for duplicate on Update of Claim Stage Record
* Added By                   : Accenture - JV  - 07/04/2019
*/
    public static void handleDuplicateClaimsOnUpdate(List<PartnerFundClaim> claimsToBeProcessed){
        
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
        // Call the duplicate method handler for Insert for processing the Cliams to be checked for Duplicate                                                                                      
        handleDuplicateClaims(claimListToBeProcessedForDuplicate);
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
        if(updatedStageRecordList != NULL && updatedStageRecordList.size() > 0){
            return updatedStageRecordList;
        }else{ return NULL;}
    }
    
}