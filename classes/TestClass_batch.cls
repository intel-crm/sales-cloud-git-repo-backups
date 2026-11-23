/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_ClaimInsert_Batch 
* Version     : 1.0 
* Created Date: 08-12-2020
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - SM				08-12-2020					  Batch class to process submitted claim batch records
****************************************************************************************************************************************/

//Commented class Author : Team Bhoomi,
//Reason:Apex class character limit exceeded and class is giving compilation error.
//Error : TestClass_batch: line 52, column 63: Method does not exist or incorrect signature:
//         void handleDuplicateClaims(List<PartnerFundClaim>) from the type Core_MDF_ClaimStage_ServiceHandler
//Dated : 19th Oct 2023  
//Commented Line : 60,128,159
 
public without sharing class TestClass_batch implements Database.Batchable<sObject>{
   
    public set<id> allIds=new set<id>();
    public set<id> allFailedId=new set<id>();
    public set<id> allSuccessId=new set<id>();
    public integer totalSizeRecords=0;
    public Set<Id> succesRecordIdSet = new Set<Id>();
    public Map<Id,PartnerFundClaim> successClaimMap;
    public List<PartnerFundClaim> failedClaims = new List<PartnerFundClaim>();
    public List<PartnerFundRequest> pfrToBeUpdated = new List<PartnerFundRequest>();
    public Set<Id> failedPFR = new Set<Id>();
    public List<Core_MDF_Claim_Batch_Stage__c> stageRecordsToUpdate = new List<Core_MDF_Claim_Batch_Stage__c>();

    
    public Database.QueryLocator start(Database.BatchableContext batchableContext){   
        //null check for custom setting value//put defaylt value on field level use ternanry operator if null thn covert
       //String str = (Core_MDF_Configuration__c.getValues('BATCH_RECORD_LIMIT').Core_MDF_Value__c) = '' ? 5 : Core_MDF_Configuration__c.getValues('BATCH_RECORD_LIMIT').Core_MDF_Value__c;
              
        Integer queryLimit = 30;
        Integer retryCountLimit = 5;
        
        String queryStr= 'select Core_MDF_NoOfEngagements_Nbr__c, Core_MDF_Impressions_Cnt__c, Core_MDF_NoOfLeads_Nbr__c, Core_MDF_NoOfTrialActivations_Nbr__c,'+
            'Core_MDF_Activity_Nbr__c, Core_MDF_Ad_Run_End_Dt__c, Core_MDF_Ad_Run_Start_Dt__c, Core_MDF_Bank_Nbr__c, Core_MDF_Batch_ID__c, Core_MDF_Claim_Nm__c,'+
            'Core_MDF_Processing_Status_Nm__c, Core_MDF_Claim_Comment_txt__c, Core_MDF_Non_Reimbursable_Amt__c, Core_MDF_Create_Duplicate_ind__c, Core_MDF_Inv_Receipt_Cur_Cd__c,'+
            'Core_MDF_Inv_Receipt_Dt__c, Core_MDF_Inv_Receipt_Nbr__c, Core_MDF_Is_Duplicate_ind__c, Core_MDF_Media_Vehicle_txt__c, Core_MDF_Message_txt__c,'+ 
            'Core_MDF_Taxes_Local_Amt__c, Core_MDF_Total_Amt__c,CreatedById,Core_MDF_Country_nm__c, Core_MDF_Request_Id__c, Core_MDF_Bank_Id__c,Core_MDF_Retry_Count_Nbr__c,Core_MDF_Failure_Reason_Txt__c from Core_MDF_Claim_Batch_Stage__c where Core_MDF_Processing_Status_Nm__c = \'Submitted\' '+
            'AND Core_MDF_Retry_Count_Nbr__c < '+retryCountLimit +
            ' ORDER BY Createddate Asc LIMIT '+queryLimit;
        
        return Database.getQueryLocator(queryStr);
    }
     
    public void execute(Database.BatchableContext BC, List<Core_MDF_Claim_Batch_Stage__c> claimStageList){
		
        //save point to rollback all the transaction if any exception occurs
        Savepoint transactionSavePoint = Database.setSavepoint();
        
        try{
            Map<Id,Core_MDF_Claim_Batch_Stage__c> claimStageMap = new Map<Id,Core_MDF_Claim_Batch_Stage__c>(claimStageList);
            List<PartnerFundClaim> getBulkOfClaims = Core_MDF_BatchClaimHelper.mapStageRecordsToClaim(claimStageList);
            // call the function to check whether the ClaimList contains duplicates
            Core_MDF_ClaimStage_ServiceHandler.stageAndClaimRecWrapper wrapInstance = new Core_MDF_ClaimStage_ServiceHandler.stageAndClaimRecWrapper();                       
           // wrapInstance = Core_MDF_ClaimStage_ServiceHandler.handleDuplicateClaims(getBulkOfClaims);
                
            List<PartnerFundClaim> claimToBeInserted = new List<PartnerFundClaim>();
            for(PartnerFundClaim pfc : wrapInstance.nonduplicateClaims){
                if(pfc.Id == null){
                    claimToBeInserted.add(pfc);                   
                }
            }
            
            if(claimToBeInserted != NULL && claimToBeInserted.size() > 0){
                Database.SaveResult[] result = Database.insert(claimToBeInserted, false);
                
                for (Database.SaveResult sr : result) {
                    if (sr.isSuccess()) {
                        succesRecordIdSet.add(sr.getId());
                    }
                }                
                successClaimMap = new Map<Id,PartnerFundClaim>([Select Id,Core_MDF_Claim_Batch_Stage__c, Core_MDF_Claim_Ref_Number__c, RequestId, Request.Status,
                                                                Request.Core_MDF_Fund_Request_Status__c,Core_MDF_Claim_Batch_Stage__r.Core_MDF_Processing_Status_Nm__c
                                                                FROM PartnerFundClaim where ID IN :succesRecordIdSet]);

                List<Core_MDF_Claim_Batch_Stage__c> successfulStageRecords = new List<Core_MDF_Claim_Batch_Stage__c>();
                List<Core_MDF_Claim_Batch_Stage__c> failedStageRecords = new List<Core_MDF_Claim_Batch_Stage__c>();
                
                for(Integer index=0;index<result.size();index++){                    
                    
                    if (result[index].isSuccess()){
                        ID stageid = claimToBeInserted.get(index).Core_MDF_Claim_Batch_Stage__c;
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
                        failedPFR.add(claimToBeInserted.get(index).RequestId);

                        ID stageid = claimToBeInserted.get(index).Core_MDF_Claim_Batch_Stage__c;
                        Core_MDF_Claim_Batch_Stage__c stageRecord = new Core_MDF_Claim_Batch_Stage__c();
                        stageRecord.ID = stageid;

                        //user exception or custom exception
                        if((Label.Core_MDF_UserExceptionErrorCode).contains(errorCode)){
                            String errorMessage = errorMsg.getMessage();  
                            stageRecord.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Failed;                                                        
                        	stageRecord.Core_MDF_Message_txt__c = errorMessage;//confirmed with amal to override the message, as earlier we were appending error message
                            stageRecord.Core_MDF_Failure_Reason_Txt__c ='';
                        }
                        //system exception
                        else{                                
                            String errorMessage = errorMsg.getMessage();
                            stageRecord.Core_MDF_Message_txt__c =''; stageRecord.Core_MDF_Failure_Reason_Txt__c = errorMessage; 
                            stageRecord.Core_MDF_Retry_Count_Nbr__c = claimStageMap.get(stageRecord.Id).Core_MDF_Retry_Count_Nbr__c + 1;              
                        }
                        failedStageRecords.add(stageRecord);
                        //end - vaishali
                    } 
                }
                
                stageRecordsToUpdate.addAll(successfulStageRecords);
                stageRecordsToUpdate.addAll(failedStageRecords);
                stageRecordsToUpdate.addAll(wrapInstance.failedStageRecordsList);//failed duplicate records
                
               // Database.update(stageRecordsToUpdate);
                
                Map<Id, List<PartnerFundClaim>> pfrClaimMap = new Map<Id,List<PartnerFundClaim>>();
                Map<Id, String> pfrStatusMap = new Map<Id, String>();
                //to get pfr status when no claims are inserted
                for(PartnerFundRequest pfr : [Select Core_MDF_Fund_Request_Status__c, Status, Id from PartnerFundRequest where Id in :failedPFR])
                {
                    pfrStatusMap.put(pfr.Id, pfr.Status);
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
                System.debug('pfrStatusMap::'+pfrStatusMap);
                if(failedPFR!=null && failedPFR.size()>0)
                {
                    for(Id pfrID : failedPFR)
                    {
                        if(!pfrClaimMap.containsKey(pfrID) && pfrStatusMap.get(pfrID)=='Approved')
                        {
                            pfrToBeUpdated.add(new PartnerFundRequest(Id = pfrID, Status= 'Draft'));
                        }
                    }
                }
                if(pfrToBeUpdated != null && pfrToBeUpdated.size() > 0)
                {
                 //   Database.Update(pfrToBeUpdated);   
                }
                
            }
        }
        catch (Exception e) { Database.rollback(transactionSavePoint); Core_MDF_CCP_UtilityClass.logError(e); throw e;         
        }
    }
    
    public void finish(Database.BatchableContext BC){

    }
}