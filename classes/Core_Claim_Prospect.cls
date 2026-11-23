public without sharing class Core_Claim_Prospect {
    
    @auraEnabled
    public static String UpdateOwnertoQueue(String ProspectId){
        system.debug('ProspectId'+ProspectId);
        String loggedInUserId = UserInfo.getUserId();
        String alertMsg;
        Core_Prospect__c prospectrecord = [select Id,OwnerId from Core_Prospect__c where Id =: ProspectId];
        
        if(loggedInUserId.equalsIgnoreCase(prospectrecord.OwnerId)){
            alertMsg='You are already an owner of this Prospect';
        }else{
            prospectrecord.OwnerId = loggedInUserId;
            prospectrecord.Core_Status_Pkt__c ='Accepted';
            prospectrecord.Core_Claimed_Date__c = System.now();
            String msg=System.Label.Core_Prospect_claim;
            alertMsg=msg;            
        }        
        try{
            update prospectrecord;           
        } 
        catch(Exception e){                       
            String errMessage = e.getMessage();
            List<String> spltError;
            //Trim the validation message 
            if(errMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                spltError = errMessage.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
            } 
            if(spltError[1]!=''){
                List<String> err = spltError[1].split(':');
                alertMsg= err[0];
            }
            else{
                alertMsg='An error has occurred while updating lead '+errMessage;    
            }              
        } 
        return alertMsg;
    }
}