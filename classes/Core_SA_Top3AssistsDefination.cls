public class Core_SA_Top3AssistsDefination {
// This class is used to SAServiceWrapper.getTop3Assists to read the JSON data from a service call related to Unread Assists lightning component SAShowNewAsssits
// Number of New Assists Per User and Boolean to show the object or not
// TOP 3 Assists Wrapper

    @AuraEnabled
	public Integer total_count; 
    
    @AuraEnabled
	public Boolean show; 
    
    @AuraEnabled
	public List<Assist> AssistDetails; 

	public class Assist {
        @AuraEnabled
		public String title;
        @AuraEnabled
		public String assist_id;
        @AuraEnabled
		public String L1Key;
        @AuraEnabled
		public String L1Val;
        @AuraEnabled
		public String L2Key;
        @AuraEnabled
		public String L2Val;
        @AuraEnabled
		public String L3Key;
        @AuraEnabled
		public String L3Val;
        @AuraEnabled
		public String cim_id;
        @AuraEnabled
		public String user_id; 
        
        /*
        @AuraEnabled
        public String getFormattedEmail() {
             return this.title;
        }*/
	}

	@AuraEnabled
	public static Core_SA_Top3AssistsDefination parse(String json) {
		return (Core_SA_Top3AssistsDefination) System.JSON.deserialize(json, Core_SA_Top3AssistsDefination.class);
	}
}