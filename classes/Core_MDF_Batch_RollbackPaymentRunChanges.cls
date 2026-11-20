/***********************************************************************************************************************************
* Class Name  : Core_MDF_Batch_RollbackPaymentRunChanges  
* Version     : 1.0    
* Created Date: 05-11-2020
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - Pranav      05/11/2020      This batch Reverts back the Status of Claim to Payment Due / PAF and Payment field to NULL
										  In case of any Exception/Error Occured during previous batch
*************************************************************************************************************************************/
public class Core_MDF_Batch_RollbackPaymentRunChanges implements Database.Batchable<sObject> {
    
    // List of Claims that needs to be reverted
    public List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
    // Payment Records to be deleted 
    public List<Id> paymentRecordIdsToBeDeleted = new List<Id>();
    // Payment Wrapper Used for Deletion of Payment Records
    public Map<String, Core_MDF_PaymentWrapper> paymentWrapperMap = new Map<String, Core_MDF_PaymentWrapper>();
    
    // Constructor to initialise the claimList 
    public Core_MDF_Batch_RollbackPaymentRunChanges(List<PartnerFundClaim> claimList,Map<String, Core_MDF_PaymentWrapper> paymentWrapperMap){
        this.claimList = claimList;
        this.paymentWrapperMap = paymentWrapperMap;
    }
	
    public Iterable<sObject> start(Database.BatchableContext bc) {
        return claimList;
    }
    
    public void execute(Database.BatchableContext bc, List<PartnerFundClaim> listOfClaims) {
        for(PartnerFundClaim claim : listOfClaims)
        {   
            // Change Status of Positive claims to Payment Due and Negative Claim that are of C Type to Pending Available Funds
            claim.Core_MDF_Status__c = (!claim.Core_MDF_C_Type_Ind__c)?Label.Core_MDF_Claim_Status_Payment_Due : Label.Core_MDF_Claim_Status_Pending_Available_Fund;
            // Reseting Payment Field to Empty
            claim.Core_MDF_Payment_Id__c = NULL;
            claim.Core_MDF_Payment_Rollback_Reason_nm__c = 'Payment Run Issue';
        }
		// Update List of Claims        
        if(listOfClaims != NULL && listOfClaims.size()>0){       
            Database.update(listOfClaims); 
        } 
        
    }
    
    public void finish(Database.BatchableContext bc) {
        try{
            // Deleting all Payment Records created as part of this Payment Run
            if(paymentWrapperMap != NULL && paymentWrapperMap.size()>0 ){
                for(Core_MDF_PaymentWrapper paymentWrapper : paymentWrapperMap.values())
                    {
                        paymentRecordIdsToBeDeleted.add(paymentWrapper.paymentForClaims.Id);
                    }
                if(paymentRecordIdsToBeDeleted != NULL && paymentRecordIdsToBeDeleted.size()>0){
                    Database.delete(paymentRecordIdsToBeDeleted);
                }
            }
        }
        catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e); 
        }
    }
}