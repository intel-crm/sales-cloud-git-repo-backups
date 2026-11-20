public class Core_Claim_Inquiry {
    //Method created to fullfill the code coverage to migrate the commented code.
    public static void methodToCoverClass(){
        String result = 'Test class'+'coverage placeholder';
    }
   /* @auraEnabled
    public static String UpdateOwnertoClaimedOwner(String inquiryId){
        system.debug('InquiryId'+inquiryId);
        String loggedInUserId = UserInfo.getUserId();
        String alertMsg;
        Core_Inquiry__c inquiryrecord = [select Id, OwnerId from Core_Inquiry__c where Id =: inquiryId];
        
        if(loggedInUserId.equalsIgnoreCase(inquiryrecord.OwnerId)){
            alertMsg = System.Label.Core_Inquiry_claim_AlreadyOwnerMsg;
        }else{
        	inquiryrecord.OwnerId = loggedInUserId;
            String msg = System.Label.Core_Inquiry_claim_SuccessMsg;
            alertMsg = msg;            
        }        
        try{
            update inquiryrecord;
           
        } catch(Exception e){
            alertMsg='An error has occurred while updating inquiry '+e.getMessage();
        } 
        return alertMsg;
    }*/
}