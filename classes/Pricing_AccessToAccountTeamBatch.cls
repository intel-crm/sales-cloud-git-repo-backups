public without sharing class Pricing_AccessToAccountTeamBatch implements Database.Batchable<sObject>, Database.Stateful {
    public PermissionSet ps;
    // Constructor to get the FSE permission set Id
    public Pricing_AccessToAccountTeamBatch(){
        ps = [SELECT Id FROM PermissionSet
              WHERE Name =:
              Label.Pricing_Tender_PermissionSets_TenderUser Limit 1];
    }
    // Get all the user/assignee id of FSE permission set
    public Database.querylocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([Select Id, AssigneeId, PermissionSetId from PermissionSetAssignment where PermissionSetId=:ps.Id]);
    }
    public void execute(Database.BatchableContext bc, List<PermissionSetAssignment> permissionAssignList){
        Pricing_AccessToAccountTeamHelper.getAccountTeamMem(permissionAssignList);
    }
    public void finish(Database.BatchableContext bc){}
}