/*********************************************************************************************************************
Apex Class Name  : PRM_Unlocking_RegRecords
Version       : 1.0
Created Date  : Jan 2019
Function      : Unlocking the records which are locked by approval Process

Modification Log 
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Anupam Agarwal            02/01/2019              This is used to unlock the Registration Request record after the 
                                                    submission to Approval Process manually.

*********************************************************************************************************************/

Public Class PRM_Unlocking_RegRecords{
    /**
*  @description      : Unlocking Locked Records.
*  @name             : unlockRecords
*  @param            : List<PRM_Registration_Request__c>
*  @throws exception : NONE
**/ 
    
    
    @InvocableMethod
    public static void unlockRecords(List<PRM_Registration_Request__c> regReqList){
       /* if(!regReqList.isEmpty() && regReqList != null) {
            for(PRM_Registration_Request__c eachReq :regReqList){
                system.debug('record which will be be unlocked'+eachReq.id);
                System.debug('record is locked by Approval Process---==>'+Approval.isLocked(eachReq.id));                             
                if(eachReq.PRM_isLocked__c==True){
                    Approval.UnlockResult unlockedRersult = Approval.unlock(eachReq);
                    
                    // Iterate through each returned result
                    if (unlockedRersult.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully unlocked RegistrationRequest with ID: ' + unlockedRersult.getId());
                        
                    }
                 //   else {for(Database.Error err : unlockedRersult.getErrors()) {
                  //          System.debug('The following error has occurred.');                    
                  //          System.debug(err.getStatusCode() + ': ' + err.getMessage());
                  //          System.debug('opportunity fields that affected this error: ' + err.getFields());
                //    }}                
                }
            } 
        }*/
} 
}