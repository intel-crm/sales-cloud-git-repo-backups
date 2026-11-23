/****************************************************************************************************************************************
* Class Name  : Core_MDF_EmailToGSPO 
* Version     : 1.0 
* Created Date: 10-Nov-2020
* Modification Log :
* Developer            Date               	Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Pranav       10-NOV-2020      This Class Calls Batch Class to Send Email to GSPO for Vat Claims of a Payment Run from Process Builder and Flows.
*****************************************************************************************************************************************/

public without sharing class Core_MDF_EmailToGSPO {
	
    /****************************************************************************************************** 
     Method Name:        callBatchToSendEmailToGSPO
     @return  :          
     @parameters:        List of Payment Run Ids
     Description:        This Function calls Batch to send Emails to GSPO
     Added By:           Pranav - Accenture - 11/11/2020 
     Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    
    @InvocableMethod
    public static void callBatchToSendEmailToGSPO(List<Id> paymentRunId){
        // List Of Vat Claims
        List<PartnerFundClaim> vatClaimList = new List<PartnerFundClaim>();
        //Querying Vat claims for given Payment Run
    	vatClaimList = [Select Id, Core_MDF_Payment_Id__r.Core_MDF_Payment_Run_Id__c from PartnerFundClaim Where Core_MDF_Payment_Id__r.Core_MDF_Payment_Run_Id__c IN: paymentRunId AND Core_MDF_VAT_Eligibility_Ind__c = true];
       	system.debug('vatClaimList::'+vatClaimList);
		if(vatClaimList.size() > 0){
            // Invoke Batch Class to Send Email to GSPO
            Core_MDF_Batch_SendEmailToGSPO sendEmailToGSPOBatch = new Core_MDF_Batch_SendEmailToGSPO(vatClaimList);
			Database.executeBatch(sendEmailToGSPOBatch,200);
        }
    }
}