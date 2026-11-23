/*-------------------------------------------------------------------------------------------
Apex Class  : Core_Claim_Lead_Ctrl
Version     : 1.0 
Created Date: 22 November 2018
Function    : Apex class for Claim button to change the ownership of record to loggrdin user on click of claim button
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar            22/11/2018              Original Version
--------------------------------------------------------------------------------------------*/

public without sharing class Core_Claim_Lead_Ctrl {

    @auraEnabled
    public static boolean verifyOwner(String leadId){
        String loggedInUserId = UserInfo.getUserId();
        Lead leadRecord = [select Id, OwnerId from Lead where Id =: leadId];
        if(loggedInUserId.equalsIgnoreCase(leadRecord.OwnerId)){
            return true;
        }else{
            leadRecord.OwnerId = loggedInUserId;
            update leadRecord;
            return false;
        }
    }
}