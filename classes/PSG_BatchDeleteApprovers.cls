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
global class PSG_BatchDeleteApprovers implements Database.Batchable<Sobject>, Database.Stateful {
    Map<Id,String> failedRecordsMap = new Map<Id,String>();
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT id, Name, sbaa__User__c, sbaa__GroupId__c FROM sbaa__Approver__c WHERE (sbaa__GroupId__c = NULL AND sbaa__User__c != NULL)] );
    }
    
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        try{
            List<sbaa__Approver__c> approverList=(List<sbaa__Approver__c>) scope; 
            List<sbaa__Approver__c> approverToDeleteList = new List<sbaa__Approver__c>();
            Set<Id> userIdList=new Set<Id>();
            Set<Id> bmUserIdList=new Set<Id>();
            for(sbaa__Approver__c appr: approverList){
                userIdList.add(appr.sbaa__User__c);
            }
            for(PermissionSetAssignment psa : [SELECT Id,AssigneeId,PermissionSet.Name,PermissionSet.Profile.Name,Assignee.Contact.AccountId FROM PermissionSetAssignment WHERE 
                                               (PermissionSet.Name =: Label.PSG_Quote_BM_PermissionSet AND AssigneeId IN :userIdList)]){
                bmUserIdList.add(psa.AssigneeId);
            }
            for(sbaa__Approver__c apprRec: approverList){
                if(!bmUserIdList.contains(apprRec.sbaa__User__c) ){
                    approverToDeleteList.add(apprRec);
                }
            }
            if(!approverToDeleteList.isEmpty()){
                Database.DeleteResult[] drList = Database.delete(approverToDeleteList, false);
                for(Integer i=0;i<drList.size(); i++){
                    Database.DeleteResult dr = drList[i];
                    if (!dr.isSuccess()) {
                        String msg=PSG_QuoteCloneFuture.getErrorAsString(dr.getErrors());
                        failedRecordsMap.put(dr.getId(),msg);
                    }                        
                }
            }            
        }catch(Exception e){
            PSG_Utility.createCoreLogEntry('PSG_BatchDeleteApprovers','bulkDeleteApproverRecords','Exception while deleting approvers',
                                       'Exception ==> /n'+e,'sbaa__Approver__c','Low','');
        }
    }

    public void finish(Database.BatchableContext bc) {
        if(!failedRecordsMap.isEmpty()){
           PSG_Utility.createCoreLogEntry('PSG_BatchDeleteApprovers','bulkDeleteApproverRecords','Approvers failed to get deleted',
                                       ''+failedRecordsMap,'sbaa__Approver__c','Low',''); 
        }        
    }
}