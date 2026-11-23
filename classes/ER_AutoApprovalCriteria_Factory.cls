public class ER_AutoApprovalCriteria_Factory {
	private Map<String, ER_AutoApprovalCriteria> creators = new Map<String, ER_AutoApprovalCriteria>();
    
    public ER_AutoApprovalCriteria_Factory() {
        creators.put('IPA', new ER_IPA_AutoApprovalCriteria());
    }
    
    public  ER_AutoApprovalCriteria getAutoApprovalCriteriaType(string autpapproval_type) {
        if(autpapproval_type == null){
           return null;
        }
        return creators.get(autpapproval_type);
    }
}