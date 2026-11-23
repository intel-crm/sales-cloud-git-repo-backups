/*********************************
Class Name  : Core_MDF_Outcome_Claim_Auto_Reminder
Function    : [IPA] Outcome based: Notification 
Modification Log :
* Developer              Date          Description
* ---------------------------------------------------------------------------- 
* Akash Bawankar     6/10/2025    Original version
**********************************/
public class Core_MDF_Outcome_Claim_Auto_Reminder {
   public static boolean notifyClaimOwnerCheck = false;
	@InvocableMethod
    public static void notifyPartner(List<Id> ids) {
        notifyClaimOwnerCheck = true; 
        try{
            //claim ids print
            //soql limit before
            System.debug('Claim Ids ->'+ids);
            System.debug('=== SOQL BEFORE METHOD ===');
            System.debug('Queries Used before: ' + Limits.getQueries() + ' / ' + Limits.getLimitQueries());
        	Core_MDF_PIC_SendEmailToClaimOwner.sendEmailtoClaimOwnerOnResubReqd(ids);
            System.debug('=== SOQL AFTER QUERY ===');
            System.debug('Queries Used after: ' + Limits.getQueries() + ' / ' + Limits.getLimitQueries());
            //soql limit after            
        }
        catch(Exception ex){
            System.debug('An error occurred while trying to send the email: ' + ex.getMessage());
        }
    }
}