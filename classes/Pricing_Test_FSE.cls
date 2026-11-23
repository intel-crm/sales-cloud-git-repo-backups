public without sharing class Pricing_Test_FSE {
     @AuraEnabled
    public static List<PermissionSetAssignment> testFSEUser(){
        Set<String> oemEmailIds = new Set<String>();
        oemEmailIds.add('anikx.chakraborty@intel.com');
        List<PermissionSetAssignment> salesRepAssignmentDtl = new List<PermissionSetAssignment>([SELECT Assignee.Email,PermissionSet.Name,AssigneeId
                                                                                                     FROM PermissionSetAssignment 
                                                                                                     WHERE Assignee.Email IN :oemEmailIds AND Assignee.IsActive = true
                                                                                                     AND PermissionSet.Name =:Label.Pricing_Tender_PermissionSets_TenderUser]);
        System.debug(salesRepAssignmentDtl);
        return salesRepAssignmentDtl;
    }

}