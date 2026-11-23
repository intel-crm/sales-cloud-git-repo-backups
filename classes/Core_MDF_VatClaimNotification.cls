/****************************************************************************************************************************************
* Class Name  : Core_MDF_VatClaimNotification 
* Version     : 1.0 
* Created Date: 10-Nov-2020
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Pranav       10-NOV-2020         Used to Call Batch to send Email To GSPO With File Attachments It is Invoked from flow 
												and Process Builder
*****************************************************************************************************************************************/

public class Core_MDF_VatClaimNotification {
    
    // List of Vat Claims
    public static List<PartnerFundClaim> vatClaimList = new List<PartnerFundClaim>();
	
    /****************************************************************************************************** 
     Method Name:        getCountOfVatClaimRecords
     @return  :          Boolean
     @parameters:        List of Payment Run Ids 
     Description:        This Function checks if there are any vat eligible claims picked during the payment Run
     Added By:           Pranav - Accenture - 11/11/2020 
     Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    
    public static Boolean getCountOfVatClaimRecords(List<Id> paymentRunId){
        
        Boolean booleanCountIsNotZero = false;
        // Querying Vat eligible Claims from the Payment Run
        vatClaimList = [Select Id, Core_MDF_Payment_Id__r.Core_MDF_Payment_Run_Id__c from PartnerFundClaim Where Core_MDF_Payment_Id__r.Core_MDF_Payment_Run_Id__c IN: paymentRunId AND Core_MDF_VAT_Eligibility_Ind__c = true];
        if(vatClaimList.size() > 0){
            // Set the variable to true if vat claims are more than 0
            booleanCountIsNotZero = true;
        }
        return booleanCountIsNotZero;
    }
	
    /****************************************************************************************************** 
     Method Name:        checkClmCountSendEmailToGSPO
     @return  :          List of Boolean
     @parameters:        List of SendEmailParams Wrapper
     Description:        This Function calls Batch to send Emails to GSPO
     Added By:           Pranav - Accenture - 11/11/2020 
     Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    
    @InvocableMethod
    public static List<Boolean> checkClmCountSendEmailToGSPO(List<SendEmailParams> paramList){
        
        // List of Boolean to return
		List<Boolean> booleanList = new List<Boolean>();
		Boolean vatClaimCountNotZero = false;
		
        for(SendEmailParams params : paramList){	
            // If there are vat claims in the payment Run then set boolean variable to true otherwise false 
			vatClaimCountNotZero = getCountOfVatClaimRecords(params.paymentRunId);
			booleanList.add(vatClaimCountNotZero);
            // If sendEmail is set to true and Count of vat claim are more than zero; Call Batch to Send Emails to GSPO
			if(params.sendEmail){			
				if(vatClaimCountNotZero){
					Core_MDF_Batch_SendEmailToGSPO sendEmailBatch = new Core_MDF_Batch_SendEmailToGSPO(vatClaimList);
					Database.executeBatch(sendEmailBatch);
				}				
			}
        }       
        return booleanList;
    }
    
    public class SendEmailParams{
        @InvocableVariable(label = 'SendEmail')
        public Boolean sendEmail;
        
        @InvocableVariable(label = 'PaymentRunId')
        public List<Id> paymentRunId = new List<Id>();        
    }
}