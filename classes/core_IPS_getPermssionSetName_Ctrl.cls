public with sharing class core_IPS_getPermssionSetName_Ctrl {// Changed by tushar because for vanuability changes
    
    @AuraEnabled
    public static List<PermissionSetAssignment> getLoggedInPermissonSets(){
        // Venrublity Fix - Refering query to service class
        // List<PermissionSetAssignment> pSet = [SELECT Id,Assignee.Name,PermissionSet.Name, PermissionSet.Label 
        //                                       FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() ];
        List<PermissionSetAssignment> pSet = (List<PermissionSetAssignment>) Core_IPS_QueryService.queryRecords(
            'SELECT Id,Assignee.Name,PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId = :userId',
            new Map<String, Object>{ 'userId' => UserInfo.getUserId() }
        );
        return pSet;
    }
    
}