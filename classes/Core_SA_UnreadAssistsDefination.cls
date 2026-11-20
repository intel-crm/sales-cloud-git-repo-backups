public class Core_SA_UnreadAssistsDefination {
// This class is used to SAServiceWrapper.getNewAssists to read the JSON data from a service call related to Unread Assists lightning component SAShowNewAsssits
// Number of New Assists Per User and Boolean to show the object or not
	@AuraEnabled
	public string content;
    
    @AuraEnabled
    public boolean show;
     
    @AuraEnabled
	public static Core_SA_UnreadAssistsDefination parse(String json) {
		return (Core_SA_UnreadAssistsDefination) System.JSON.deserialize(json, Core_SA_UnreadAssistsDefination.class);
	}
}