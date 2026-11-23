/****************************************************************************************************
Apex Class Name : PSG_BatchDeleteApprovers
Version         : 1.0 
Created Date    : 01/05/2021
Function        : Batch Class to delete Approver records
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hema                     01/05/2021               Created
*****************************************************************************************************/
@isTest
global class PSG_BatchDeleteApprovers {
    /*implements Database.Batchable<Sobject>, Database.Stateful {
    Map<Id,String> failedRecordsMap = new Map<Id,String>();
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //DateTime twentyFourHoursAgo = System.now().addHours(-24);
        return Database.getQueryLocator([SELECT id, Name, sbaa__User__c, sbaa__GroupId__c FROM sbaa__Approver__c WHERE (sbaa__GroupId__c = NULL AND sbaa__User__c != NULL)] );
    }
    
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        try{
            Map<Id,String> bmUsersMap = new Map<Id,String>();
            for(PermissionSetAssignment psa : [SELECT Id,AssigneeId,PermissionSet.Name,PermissionSet.Profile.Name,Assignee.Contact.AccountId FROM PermissionSetAssignment WHERE 
                                               (PermissionSet.Name =: Label.PSG_Quote_BM_PermissionSet)]){
                                                                            
                if(psa.PermissionSet.Name == Label.PSG_Quote_BM_PermissionSet){
                    bmUsersMap.put(psa.AssigneeId,'BM');
                }
            }
            
            List<sbaa__Approver__c> approverToDeleteList = new List<sbaa__Approver__c>();
            for(sbaa__Approver__c apprRec: (List<sbaa__Approver__c>) scope){
                if(!bmUsersMap.containsKey(apprRec.sbaa__User__c) ){
                    approverToDeleteList.add(apprRec);
                }
            }
            Database.DeleteResult[] drList = Database.delete(approverToDeleteList, false);
        } 
        catch(Exception e){
            failedRecordsMap.put((String)scope[0].get('Id'),e.getMessage());
        }
    }

    public void finish(Database.BatchableContext bc) {
        PSG_Utility.createCoreLogEntry('PSG_BatchDeleteApprovers','bulkDeleteApproverRecords','Approvers failed to get deleted',
                                       ''+failedRecordsMap,'sbaa__Approver__c','Low','');
    }*/
}