global class Core_MDF_Batch_ClaimInsert implements Database.Batchable<PartnerFundClaim>, Database.Stateful {
    
    global List<PartnerFundClaim> claimList;
    global set<id> allIds=new set<id>();
    global set<id> allFailedId=new set<id>();
    global set<id> allSuccessId=new set<id>();
    global integer totalSizeRecords=0;
    global Set<Id> succesRecordIdSet = new Set<Id>();
    global Map<Id,PartnerFundClaim> successClaimMap;
    global Map<PartnerFundClaim,Id> claimToClaimStageIdMap = new Map<PartnerFundClaim,Id>();
    global Map<PartnerFundClaim,Id> successClaimToClaimStageIdMap = new Map<PartnerFundClaim,Id>();
    global List<PartnerFundClaim> failedClaims = new List<PartnerFundClaim>();
    global List<PartnerFundRequest> pfrToBeUpdated = new List<PartnerFundRequest>();
    global Set<Id> failedPFR = new Set<Id>();
    global List<Core_MDF_Claim_Batch_Stage__c> stageRecordsToUpdate = new List<Core_MDF_Claim_Batch_Stage__c>();
    
    global Core_MDF_Batch_ClaimInsert(List<PartnerFundClaim> claimList){
        this.claimList = claimList;    
    }
    
    global Iterable<PartnerFundClaim> start(Database.BatchableContext BC){
        return claimList;
    }
    
    global void execute(Database.BatchableContext BC, List<PartnerFundClaim> claimList){
        
        try{
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
                                                                Request.Core_MDF_Fund_Request_Status__c
                                                                FROM PartnerFundClaim where ID IN :succesRecordIdSet]);
                
                for(PartnerFundClaim claim : successClaimMap.values())
                {
                    successClaimToClaimStageIdMap.put(claim,claim.Core_MDF_Claim_Batch_Stage__c);
                }
                for(PartnerFundClaim claim : claimList)
                {
                    claimToClaimStageIdMap.put(claim,claim.Core_MDF_Claim_Batch_Stage__c);
                }
                for(Integer i=0;i<result.size();i++){
                    if (result[i].isSuccess()){
                        ID stageid = successClaimToClaimStageIdMap.get(successClaimMap.get(result[i].getId()));//success record from the list
                        Core_MDF_Claim_Batch_Stage__c stageRecord = new Core_MDF_Claim_Batch_Stage__c();
                        stageRecord.ID = stageid;
                        stageRecord.Core_MDF_Claim_Reference_Nbr__c = successClaimMap.get(result[i].getId()).Core_MDF_Claim_Ref_Number__c;
                        stageRecord.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Successful;
                        successfulStageRecords.add(stageRecord);        
                    }
                    else {
                        // DML operation failed
                        Database.Error errorMsg = result[i].getErrors()[0];
                        failedClaims.add(claimList.get(i));
                        failedPFR.add(claimList.get(i).RequestId);
                        ID stageid = claimToClaimStageIdMap.get(claimList.get(i));//failed record from the list
                        Core_MDF_Claim_Batch_Stage__c stageRecord = new Core_MDF_Claim_Batch_Stage__c();
                        stageRecord.ID = stageid;
                        stageRecord.Core_MDF_Message_txt__c = stageRecord.Core_MDF_Message_txt__c == NUll ? errorMsg.getMessage() : stageRecord.Core_MDF_Message_txt__c + errorMsg.getMessage();
                        stageRecord.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Failed;
                        failedStageRecords.add(stageRecord);
                    } 
                }
               
                
                stageRecordsToUpdate.addAll(successfulStageRecords);
                stageRecordsToUpdate.addAll(failedStageRecords);
                
            }
        }
        catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e); throw e;
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
        try{
            
            Database.update(stageRecordsToUpdate);
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
                Database.Update(pfrToBeUpdated);   
            }
        }
        catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e); throw e;
        }
    }
}