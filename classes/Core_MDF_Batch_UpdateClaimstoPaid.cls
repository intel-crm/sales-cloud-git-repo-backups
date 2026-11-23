/*******************************************************************************************************************************
* Class Name  : Core_MDF_Batch_UpdateClaimstoPaid 
* Version     : 1.0 
* Created Date: 14-12-2020 
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - Pranav      14-Dec-2020        This Batch Updates Claim Status to Paid When Payment Record status is changed to Paid                                  
********************************************************************************************************************************/

public without sharing class Core_MDF_Batch_UpdateClaimstoPaid implements Database.Batchable<sObject>, Database.Stateful{
	
    // Map of Payments
    public Map<Id, Core_MDF_Payment__c> paymentMap;
    // Set of payment Ids
	public Set<Id> paymentIdsSet;
    // Payment records to be rollbacked
	public Map<Id, Core_MDF_Payment__c> failedPaymentMap = new Map<Id, Core_MDF_Payment__c>();
    // Get Incoming Payments
    public Core_MDF_Batch_UpdateClaimstoPaid(Map<Id, Core_MDF_Payment__c> paymentMap){
        this.paymentMap = paymentMap;
        paymentIdsSet = paymentMap.keySet();
    }
	
    // Query Related Claims for the Payments Ids
	public database.querylocator start(Database.BatchableContext bc) {
		String query = 'Select Id, Core_MDF_Status__c,Core_MDF_Payment_Id__c from PartnerFundClaim Where Core_MDF_Payment_Id__c IN : paymentIdsSet';
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext bc, List<PartnerFundClaim> claimList){
        
        Database.SaveResult[] srList;
        // List of claims whose status to be updated to paid
        List<PartnerFundClaim> claimsToBeUpdated = new List<PartnerFundClaim>();
        // Map of Claim Id and Payment Id
        Map<Id, Id> claimIdtoPaymentIdMap = new Map<Id, Id>();
        // Change Claim Status to Paid ,Add claims in claimIdtoPaymentIdMap
        for(PartnerFundClaim claim : claimList){
            if(!failedPaymentMap.containsKey(claim.Core_MDF_Payment_Id__c)){
                claim.Core_MDF_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Paid');  
                if(paymentMap.containsKey(claim.Core_MDF_Payment_Id__c)){
                    Core_MDF_Payment__c paymentRec = paymentMap.get(claim.Core_MDF_Payment_Id__c);
                    claim.Core_MDF_EFT_Number_txt__c = paymentRec.Core_MDF_EFT_Nbr__c;
                }
                claimsToBeUpdated.add(claim);
                claimIdtoPaymentIdMap.put(claim.Id, claim.Core_MDF_Payment_Id__c);
            }
        }
        // Update Claims
        if(claimsToBeUpdated != NULL && claimsToBeUpdated.size()>0){
            srList = database.update(claimsToBeUpdated, false);
        }
        // For failed claim records Add its corresponding Payment Id and record in a map
        if(srList != NULL && srList.size()>0){
            for (Integer i = 0; i < srList.size(); i++) {
                Database.SaveResult sr = srList[i];                
                if(!sr.isSuccess()){                    
                    Id paymentId = claimIdtoPaymentIdMap.get(claimsToBeUpdated[i].Id);
                    failedPaymentMap.put(paymentId, paymentMap.get(paymentId));                    
                }
            }
        }
	}
    
	public void finish(Database.BatchableContext bc){
        // Invoke Rollback batch to revert back the MD Claims and Payments to previous status
        if(failedPaymentMap != NULL && failedPaymentMap.size()>0){ Id batchJobId = Database.executeBatch(new Core_MDF_Batch_RollbackPaidPaymentClaims(failedPaymentMap),200); 
        }
	}
}