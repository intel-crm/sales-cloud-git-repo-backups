public with sharing class PRM_OPIDSyncRequest {
    
    @AuraEnabled
    public static string getAccountDetails(Id sfdcOnepartnerId){
        Account a = [select id/*, Core_CIM_ID__c//TWC729-7726 : Cim Prime EOL*/ from account where id = :sfdcOnepartnerId limit 1];
        return validateSyncRequest(a.Id);
    }
    
    @AuraEnabled
    public static String validateSyncRequest(Id sfdcOnepartnerId){        
        //check records present in OPID Sync request object 
        Boolean returnValue =false;  
        string msg;
        for(OPID_Sync_Request__c osr : [select id from OPID_Sync_Request__c where Status__c ='In Progress' and OPID_Account__c=:sfdcOnepartnerId]){
            //returnValue =true;
             //msg='Sync is in Progress';
             msg= label.PRM_OPID_SyncError;
        }
        /*for(PRM_IPA_Membership__c syncRec : [Select Id,PRM_Status__c,PRM_Account_Id__c from PRM_IPA_Membership__c where PRM_Status__c= 'In Progress' AND PRM_Account_Id__c=:sfdcOnepartnerId]){            
            //returnValue =true; 
            system.debug('--->Inside Role Tier');
             //msg='Role-Tier automation update in progress';
            msg=label.PRM_OPID_RoleTierErrorMsg;
        }*/
        return msg;
    }
    
    @AuraEnabled
    public static string createSyncRequest(Id recordId){
        PRM_OPID_OnDemandsyncRequest.ondemandSyncReq(recordId);
        return 'Success';
    }
}