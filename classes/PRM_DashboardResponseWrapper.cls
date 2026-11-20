public class PRM_DashboardResponseWrapper {
	
    @AuraEnabled 
    public String link{get;set;} 
    @AuraEnabled
    public String userType{get;set;} 
    @AuraEnabled
    public String LoggedInuserType{get;set;} 
    @AuraEnabled
    public boolean legalAgreementCheck{get;set;} 
    @AuraEnabled
    public boolean showManagePartnerBtn{get;set;} 
    @AuraEnabled
    public boolean showManageStorefrontBtn{get;set;} 
    @AuraEnabled
    public String partnerKeyMetricExtLink{get;set;} 
    @AuraEnabled
    public Map<String,boolean> tabAccess = new Map<String,boolean>();
    
}