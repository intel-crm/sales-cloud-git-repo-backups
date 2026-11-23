/****************************************************************************************************
Apex Class Name : PSG_BatchCreateApprovers
Version         : 1.0 
Created Date    : 01/05/2021
Function        : Batch Class to Insert Approver records
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hema                     01/05/2021               Created
*****************************************************************************************************/
@isTest
global class PSG_BatchCreateApprovers {
    /*implements Database.Batchable<Sobject>, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime twentyFourHoursAgo = System.now().addHours(-24);
        return Database.getQueryLocator([SELECT id,Assignee.name,AssigneeId,PermissionSet.Name,Assignee.IsActive FROM PermissionSetAssignment
                                         WHERE PermissionSet.Name like '%PSG_Internal_Business_Manager%' AND SystemModstamp >=: twentyFourHoursAgo AND Assignee.IsActive= true]);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        try{
            Set<Id> userToApproverSet = new Set<Id>();
            for(sbaa__Approver__c approverRec: [SELECT id, Name, sbaa__User__c from sbaa__Approver__c]){
                if(approverRec.Name != null){
                    userToApproverSet.add(approverRec.sbaa__User__c);
                }
            }
            
            List<sbaa__Approver__c> newApproverList = new List<sbaa__Approver__c>();
            for(PermissionSetAssignment psa: (List<PermissionSetAssignment>) scope){
                if(!userToApproverSet.contains(psa.AssigneeId)){
                    sbaa__Approver__c approver = new sbaa__Approver__c(sbaa__User__c = psa.AssigneeId,ownerId=psa.AssigneeId, Name = psa.Assignee.Name );
                    newApproverList.add(approver);
                }
            }
            insert newApproverList;
        }catch(Exception e){
            PSG_Utility.logError(e);
        }
    }

    public void finish(Database.BatchableContext bc) {
        PSG_BatchDeleteApprovers deleteApprover = new PSG_BatchDeleteApprovers();
        Database.executeBatch(deleteApprover);
    }*/
    
}