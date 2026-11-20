public class Core_SA_UserSessionDefination {
// Used by SAServiceWrapper.getUserSessionId();
// This class defines the User and the session properties
	@AuraEnabled
	public string cimId;
    
	@AuraEnabled
	public string orgId;
    
    @AuraEnabled
    public string sessionId;

    @AuraEnabled
    public string wwid;

    @AuraEnabled
    public string email;
    
    //Sales Assist Opp
    @AuraEnabled
    public List<opportunitylineitem> prodJSON;
    
    //Sales Assist Opp
    @AuraEnabled
    public string opp_name;
    
    @AuraEnabled
	public static Core_SA_UserSessionDefination parse(String json) {
		return (Core_SA_UserSessionDefination) System.JSON.deserialize(json, Core_SA_UserSessionDefination.class);
	}
}