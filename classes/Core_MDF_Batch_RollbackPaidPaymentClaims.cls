/*******************************************************************************************************************************
* Class Name  : Core_MDF_Batch_RollbackPaidPaymentClaims 
* Version     : 1.0 
* Created Date: 18-12-2020 
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - Pranav      18-Dec-2020        This Batch reverts payment and related Claim Status to previous status                                  
********************************************************************************************************************************/

public class Core_MDF_Batch_RollbackPaidPaymentClaims implements Database.Batchable<sObject>{
	private static String pendingPayment = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Payment');
    // Payment Map  
    public Map<Id, Core_MDF_Payment__c> paymentToBeRollbackMap = new Map<Id, Core_MDF_Payment__c>();
    // Set of Payment Ids
    public Set<Id> paymentIdsSet = new Set<Id>();
    
    // Incoming Map of failed Payments 
    public Core_MDF_Batch_RollbackPaidPaymentClaims(Map<Id, Core_MDF_Payment__c> failedPaymentMap){
        this.paymentToBeRollbackMap = failedPaymentMap;
        paymentIdsSet = paymentToBeRollbackMap.keySet();
    }
    
    // Query Related Claims
    public database.querylocator start(Database.BatchableContext bc) {
		String query = 'Select Id, Core_MDF_Status__c from PartnerFundClaim Where Core_MDF_Payment_Id__c IN : paymentIdsSet';
		return Database.getQueryLocator(query);
	}
	
    public void execute(Database.BatchableContext bc, List<PartnerFundClaim> claimList){
        try{
            // Update Claim Status back to pending Payment
            for(PartnerFundClaim claim : claimList){
                claim.Core_MDF_Status__c = pendingPayment;
            }
            if(claimList != NULL && claimList.size()>0){
                Database.update(claimList);
            }
        }
        catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    public void finish(Database.BatchableContext bc){
        try{
            // Update Payment status back to Pending Payment
            if(paymentToBeRollbackMap != NULL && paymentToBeRollbackMap.size()>0){
                for(Core_MDF_Payment__c payment : paymentToBeRollbackMap.values()){
                    payment.Core_MDF_Payment_Status_Txt__c = pendingPayment;
                }
                Database.update(paymentToBeRollbackMap.values());
            }
        }
        catch(Exception excep){ Core_MDF_CCP_UtilityClass.logError(excep);
        }
    }
}