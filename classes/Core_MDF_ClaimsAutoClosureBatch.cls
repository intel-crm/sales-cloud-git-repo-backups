/******************************************************
@Author: Accenture
@Description: Batch class executes for every 5 mins for updating the Claims (Which are in PIC Review Revision Required) Status to Closed when Activity status is Closed.
@CreatedDate: 7-DEC-2021
@Version: <V.1.0>
@ReturnType:NA
*******************************************************/
public class Core_MDF_ClaimsAutoClosureBatch implements Database.batchable<Sobject>{
    public Database.QueryLocator start(Database.batchableContext bc){ 
        String closedStatus = System.Label.Core_MDF_Claim_Status_Closed;
        List<String> statusForRWC = new List<String>{System.Label.Core_MDF_PIC_Review_Resubmission_Required, System.Label.Core_MDF_PIC_Review_Pending_Account_Manager_Clarification, System.Label.Core_MDF_PendingClarification, System.Label.Core_MDF_PFR_Status_Draft_IPA};
        String closedActivityClaims = 'Select id,Core_MDF_Status__c,Status,Core_MDF_Claim_EvalInProgress_Ind__c FROM PartnerFundClaim WHERE Core_MDF_Legacy_Claim_Ind__c = FALSE AND Request.Core_MDF_Fund_Request_Status__c =: closedStatus AND Core_MDF_Status__c IN :statusForRWC AND Core_MDF_Escalation_Id__c =null';
        //Custom Label or Custom Setting         
        return database.getQueryLocator(closedActivityClaims);
    }
    public void execute(Database.batchableContext bc, List<PartnerFundClaim> closedActivityClaims){
        List<PartnerFundClaim> claimsToClosed = new List<PartnerFundClaim>();
        if(!closedActivityClaims.isEmpty()){
            for(PartnerFundClaim pfc: closedActivityClaims){                
                pfc.Core_MDF_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ResubWinClosed');
                pfc.Status = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Rejected');
                claimsToClosed.add(pfc);                
            }
        }
        if(!claimsToClosed.isEmpty())
            Database.update(claimsToClosed);
    }
    public void finish(Database.batchableContext bc){
        
    }
    
}