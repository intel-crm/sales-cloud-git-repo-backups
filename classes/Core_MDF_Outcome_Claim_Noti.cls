public class Core_MDF_Outcome_Claim_Noti {
    public static boolean notifyClaimOwnerCheck = false;
	@InvocableMethod
    public static void notifyPartner(List<Id> ids) {
        //notifyClaimOwnerCheck = true; 
        try{
        	//Core_MDF_PIC_SendEmailToClaimOwner.sendEmailtoClaimOwnerOnResubReqd(ids);            
        }
        catch(Exception ex){
            System.debug('An error occurred while trying to send the email: ' + ex.getMessage());
        }
    }
}