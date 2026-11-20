public class Core_MDF_FlowInputWrapper {
    @AuraEnabled @InvocableVariable public Boolean createdByExternal; 
    @AuraEnabled @InvocableVariable public String createdById; 
    @AuraEnabled @InvocableVariable public String memberOfActivity; 
    @AuraEnabled @InvocableVariable public String recordId; 
    @AuraEnabled @InvocableVariable public String status; 
    @AuraEnabled @InvocableVariable public String program; 
    @AuraEnabled @InvocableVariable public Boolean proposalBasedIndicator; 
    
    public Core_MDF_FlowInputWrapper(Boolean ctdByExternal, String ctdById, String memberAcceptor, String recdId,
                                      String statusValue, String prgm, Boolean propBasedIndicator) {
		this.createdByExternal = ctdByExternal; 
        this.createdById = ctdById; 
        this.memberOfActivity = memberAcceptor; 
        this.recordId = recdId; 
        this.status = statusValue; 
        this.program = prgm; 
        this.proposalBasedIndicator = propBasedIndicator; 
	}
}