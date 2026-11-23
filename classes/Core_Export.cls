public class Core_Export {
    public String recentlyViewedListID { get; set; }
    
    public Core_Export() {
        // Initialize the recentlyViewedListID list using the getRecentlyViewed method
        recentlyViewedListID = getRecentlyViewed();
    }
    
    public String getRecentlyViewed() {
        String q = String.escapeSingleQuotes('SELECT Id FROM Core_MDF_Escalation__c LIMIT 2');
        List<sObject> objList = Database.query(q);
        System.debug('objListValue ' +objList);
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(objList);
        String recentlyViewedFilterId = controller.getFilterId();
        System.debug('recentlyViewedFilterId ' +recentlyViewedFilterId);
        return recentlyViewedFilterId;
    }
    
    
}