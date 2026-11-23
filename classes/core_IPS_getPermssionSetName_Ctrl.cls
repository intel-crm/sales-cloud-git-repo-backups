public without sharing class core_IPS_getPermssionSetName_Ctrl {
    
    @AuraEnabled
    public static List<PermissionSetAssignment> getLoggedInPermissonSets(){
        List<PermissionSetAssignment> pSet = [SELECT Id,Assignee.Name,PermissionSet.Name, PermissionSet.Label 
                                              FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() ];
        return pSet;
    }
    
}