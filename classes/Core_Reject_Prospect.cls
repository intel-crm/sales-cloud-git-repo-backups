/**************************************************************************************
Apex Class Name:  Core_Reject_Prospect
Version     : 1.0 
Created Date: 23 Sep 2020
Function    : method to reject the prospect
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kavyashree H R            09/23/2020              Original Version
*************************************************************************************/
public without sharing class Core_Reject_Prospect {   

    /*
     * Method name  : updateStatusToDisqualified
     * Description  : Method to update status, disqualification reason and rejected date
     * Return Type  : String
     * Parameter    : String prospectId, String disqualifReason
     */ 
    @auraEnabled
    public static String updateStatusToDisqualified(String prospectId, String disqualifReason, String disqualifDetails){
        String alertMsg = '';
         
        Core_Prospect__c prospectrecord = [select Id,Core_Status_Pkt__c from Core_Prospect__c where Id =: ProspectId];
        try{  
            //Update the fields Status, Disqualification Reason and Rejected Date and return the success message          
            prospectrecord.Core_Status_Pkt__c ='Disqualified';
            prospectrecord.Core_Disqualification_Reason_Pkt__c = disqualifReason;
            prospectrecord.Core_Disqualification_Details__c = disqualifDetails;
            prospectrecord.Core_Rejected_Date__c = System.now();
            
            List<String> msg = System.Label.Core_Prospect_Reject.split(';');
            String successMsg = msg[0];
            system.debug('disqualifReason'+disqualifReason);
             system.debug('disqualifDetails'+disqualifDetails);
            if(disqualifReason =='Other'&& disqualifDetails ==''){
                alertMsg = label.Core_Disqulaification_detail_validation_msg;
            }else{
                alertMsg = successMsg; 
                update prospectrecord; 
            }
            
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
    
    /*
     * Method name  : checkifDisqualifiedProspect
     * Description  : Method to if the prospect is already disqualified
     * Return Type  : String
     * Parameter    : String prospectId
     */
    @auraEnabled
    public static String checkifDisqualifiedProspect(String prospectId){
        String alreadyRejected= '';
        Core_Prospect__c prospectrecord = [select Id,Core_Status_Pkt__c,OwnerId from Core_Prospect__c where Id =: ProspectId];   
        //Check if the prospect is already disqualified, if yes, return the message. 
        List<String> msg = System.Label.Core_Prospect_Reject.split(';');    
        if(prospectrecord.Core_Status_Pkt__c == 'Disqualified'){
            alreadyRejected = msg[1];
        }  
        if(prospectrecord.Core_Status_Pkt__c == 'Converted'){
            alreadyRejected =  msg[2];
        }
        if(prospectrecord.OwnerId != userinfo.getUserId()){
        	alreadyRejected = msg[3];   
        }
        return alreadyRejected;
    }
    
     /*
     * Method name  : ReviveProspect
     * Description  : Method to if the prospect is already disqualified
     * Return Type  : String
     * Parameter    : String prospectId
     */
    @auraEnabled
    public static String ReviveProspect(String prospectId){
        String alertMessage= '';
        String loggedInUserId = UserInfo.getUserId();
         Core_Prospect__c prospectrecord = [select Id,Core_Status_Pkt__c,OwnerId from Core_Prospect__c where Id =: prospectId]; 
        if(prospectrecord.Core_Status_Pkt__c =='Disqualified'){
            prospectrecord.Core_Status_Pkt__c = 'Accepted';
            prospectrecord.Core_Revive_Prospect_Flag__c = true;
            prospectrecord.Core_Disqualification_Reason_Pkt__c = null;
             prospectrecord.Core_Disqualification_Details__c = null;
             prospectrecord.OwnerId = loggedInUserId;
            update prospectrecord;
            alertMessage=label.Core_Prospect_Revive_success_msg;
        }else if(prospectrecord.Core_Status_Pkt__c !='Disqualified'){
            alertMessage=label.Core_Prospect_Revive_Validation_msg;
        }
        return alertMessage;
    }
}