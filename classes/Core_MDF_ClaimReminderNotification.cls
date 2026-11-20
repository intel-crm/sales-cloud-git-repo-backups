/****************************************************************************************************************************************
* Class Name  : Core_MDF_ClaimReminderNotification 
* Version     : 1.0   
* Created Date: 16 Feb,2021
* Description : This class contains invocable method which is getting called from Flow for sending reminder notification to payment admins
				once claims are put on bank document hold
* Developer   : Accenture -TT                                  
* ---------------------------------------------------------------------------------------------------------------------------------------

* Testclass coverage : Core_MDF_ClaimActivityHelper_Test
*****************************************************************************************************************************************/
public without sharing class Core_MDF_ClaimReminderNotification {
/***************************************************************************************************** 
Method Name:        updatePaymentAdminReminderDateAsync
@return  :          void
@parameters:        List<PartnerFundClaim> claimsRecords
Description:        This method is used to update the next reminder date for Claim Notification on Bank Doc Hold to Payment Admins
Added By:           Accenture - TS Date : 9-FEB-2021
Modified By:        Date:       Changes: 
******************************************************************************************************/   
    @InvocableMethod(label='updatePaymentAdminReminderDate')
    public static void updatePaymentAdminReminderDateAsync(List<PartnerFundClaim> claimRecords){
        if(claimRecords!=null && claimRecords.size()>0){
            Integer queryLimit = Integer.ValueOf(Core_MDF_Configuration__c.getValues('BATCH_RECORD_LIMIT_FOR_UPDATE_REM_DATE').Core_MDF_Value__c);//Get limit of claim records
         	Core_MDF_Batch_UpdateReminderDtOnClaims reminderBatchClass = new Core_MDF_Batch_UpdateReminderDtOnClaims(claimRecords);
         	database.executebatch(reminderBatchClass,queryLimit);
        }
    }
}