public without sharing class Pricing_Test_FSE {
    
    public static List<PermissionSetAssignment> Method(){
        Set<String> oemEmailIds = new Set<String>();
        oemEmailIds.add('anikx.chakraborty@intel.com');
        List<PermissionSetAssignment> salesRepAssignmentDtl = new List<PermissionSetAssignment>([SELECT Assignee.Email,PermissionSet.Name,AssigneeId
                                                                                                     FROM PermissionSetAssignment 
                                                                                                     WHERE Assignee.Email IN :oemEmailIds AND Assignee.IsActive = true
                                                                                                     AND PermissionSet.Name =:Label.Pricing_Tender_PermissionSets_TenderUser]);
        return salesRepAssignmentDtl;
    }

}