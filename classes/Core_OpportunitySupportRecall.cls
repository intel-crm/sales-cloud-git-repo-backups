/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-02-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Core_OpportunitySupportRecall{
    @InvocableMethod(label = 'Opportunity Support Recall' description = '')
    public static void recallOppSupport(List<Id> oppSupportToRecall){
        System.debug('oppsupports'+ oppSupportToRecall);
        Id oppSupportIdAfterRecall;
        List<ProcessInstanceWorkitem> processInstWorkItm = [SELECT Id,ProcessInstance.TargetObjectId FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId IN :oppSupportToRecall AND ProcessInstance.Status = 'Pending']; 
            if (processInstWorkItm.size() > 0) {
                
                Approval.ProcessWorkItemRequest Preq = null;
                
                for(Id opps : oppSupportToRecall){
                    for(ProcessInstanceWorkitem pval :[SELECT Id,ProcessInstance.TargetObjectId FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId =:opps AND ProcessInstance.Status = 'Pending' LIMIT 1] ){
                        Preq = new Approval.ProcessWorkItemRequest();
                        Preq.setAction('Removed');
                        Preq.setWorkItemId(pval.Id);
                        Approval.ProcessResult result = Approval.process(Preq);
                        oppSupportIdAfterRecall = opps;
                    }                   
                }             
            }
        //resubmitting the recalled records to approval process
        if(oppSupportIdAfterRecall <> null){
            Core_Opportunity_Support__c oppSupp = [select id,Core_Approver_6__c, Core_Approver_7__c, Core_Approver_8__c,Core_Approver_9__c, Core_Approver_10__c, Core_Status__c  from Core_Opportunity_Support__c where id =:oppSupportIdAfterRecall];
            List<PermissionSetAssignment> dataOpsUsersWithPS = [SELECT AssigneeId FROM PermissionSetAssignment  WHERE PermissionSet.Name = 'Data_Ops_Elevated_Access' AND Assignee.Profile.Name = 'Data Ops' AND Assignee.IsActive = TRUE];
            List<id> dataOpsApprovers = new List<id>();
           /* if(dataOpsUsersWithPS.size()>0){
                for(PermissionSetAssignment psa : dataOpsUsersWithPS){
                    dataOpsApprovers.add(psa.AssigneeId);
                }
                if(dataOpsApprovers.size() == 1){
                    oppSupp.Core_Approver_6__c = dataOpsApprovers[0];
                    oppsupp.Core_Approver_7__c = dataOpsApprovers[0];
                    oppsupp.Core_Approver_8__c = dataOpsApprovers[0];
                    oppsupp.Core_Approver_9__c = dataOpsApprovers[0];
                    oppsupp.Core_Approver_10__c = dataOpsApprovers[0];
                }
                else if(dataOpsApprovers.size() == 2){
                    oppSupp.Core_Approver_6__c = dataOpsApprovers[0];
                    oppsupp.Core_Approver_7__c = dataOpsApprovers[1];
                    oppsupp.Core_Approver_8__c = dataOpsApprovers[0];
                    oppsupp.Core_Approver_9__c = dataOpsApprovers[0];
                    oppsupp.Core_Approver_10__c = dataOpsApprovers[0];
                }
                else if(dataOpsApprovers.size() == 3){
                    oppSupp.Core_Approver_6__c = dataOpsApprovers[0];
                    oppsupp.Core_Approver_7__c = dataOpsApprovers[1];
                    oppsupp.Core_Approver_8__c = dataOpsApprovers[2];
                    oppsupp.Core_Approver_9__c = dataOpsApprovers[0];
                    oppsupp.Core_Approver_10__c = dataOpsApprovers[0];
                }
                else if(dataOpsApprovers.size() == 4){
                    oppSupp.Core_Approver_6__c = dataOpsApprovers[0];
                    oppsupp.Core_Approver_7__c = dataOpsApprovers[1];
                    oppsupp.Core_Approver_8__c = dataOpsApprovers[2];
                    oppsupp.Core_Approver_9__c = dataOpsApprovers[3];
                    oppsupp.Core_Approver_10__c = dataOpsApprovers[0];
                }
                else if(dataOpsApprovers.size() == 5){
                    oppSupp.Core_Approver_6__c = dataOpsApprovers[0];
                    oppsupp.Core_Approver_7__c = dataOpsApprovers[1];
                    oppsupp.Core_Approver_8__c = dataOpsApprovers[2];
                    oppsupp.Core_Approver_9__c = dataOpsApprovers[3];
                    oppsupp.Core_Approver_10__c = dataOpsApprovers[4];
                }
                
                update oppSupp;
            }
            else
            {
                System.debug('No dataops user to assign');
            }*/
        }
    }        
}