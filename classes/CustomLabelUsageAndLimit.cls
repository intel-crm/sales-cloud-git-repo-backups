public class CustomLabelUsageAndLimit {
    
	@AuraEnabled(cacheable=true)
    public static Integer getOrgLimits(){
        return 0;
    }
}