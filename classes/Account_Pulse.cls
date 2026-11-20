@RestResource(urlMapping='/accountpulse/*')
global with sharing class Account_Pulse {
	// Define a GET method to retrieve opportunity data for a given account ID
	//public static List<Core_OpportunityDataFetcher.OpportunityWrapper> response = new List<Core_OpportunityDataFetcher.OpportunityWrapper>();
    
    @HttpGet
    global static Pricing_RestAPI_Response getAccountPulse(){
        RestRequest req = RestContext.request;
        // Extract the account ID from the request URL
        List<Core_OpportunityDataFetcher.OpportunityWrapper> oppWrapper = new List<Core_OpportunityDataFetcher.OpportunityWrapper>();
        Pricing_RestAPI_Response restResponse = new Pricing_RestAPI_Response();
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        if (accountId.startsWith('001')) {
            restResponse.successContent = Core_OpportunityDataFetcher.getOpportunityData(accountId); 
            restResponse.totalRecords = restResponse.successContent.size(); 
        } else if (accountId.startsWith('006')){
            restResponse.successContent = Core_OpportunityDataFetcher.getOpportunity(accountId); 
            restResponse.totalRecords = restResponse.successContent.size(); 
        }
        // Call the method from the Core_OpportunityDataFetcher class
        
        return restResponse;
    }
    
    public static List<User> getFullReportingHierarchy(String wwid) {
        List<User> fullHierarchy = new List<User>();
        Set<String> processedWWIDs = new Set<String>();  // To track processed WWIDs
        
        // Collect all WWIDs to process
        Set<String> wwidSet = new Set<String>();
        wwidSet.add(wwid);
        
        // A map to store users and their direct reports
        Map<String, List<User>> reportsMap = new Map<String, List<User>>();
        
        // Get all users once to avoid hitting SOQL limits
        LIst<UserRole> UsrRole = [SELECT Id FROM UserRole WHERE ParentRoleId IN (SELECT UserRoleId FROM User WHERE Core_WWID__c IN :wwidSet)];
        List<User> allUsers = [
            SELECT Id, Name, Core_WWID__c, UserRoleId 
            FROM User 
            WHERE Core_WWID__c IN :wwidSet OR UserRoleId IN :UsrRole
        ];
        // Populate the reports map
        for (User user : allUsers) {
            if (!reportsMap.containsKey(user.Core_WWID__c)) {
                reportsMap.put(user.Core_WWID__c, new List<User>());
            }
            reportsMap.get(user.Core_WWID__c).add(user);
        }

        // Use a queue-like structure to track WWIDs that need to be processed
        List<String> wwidList = new List<String>(wwidSet);
        
        while (!wwidList.isEmpty()) {
            String currentWWID = wwidList.remove(0); // Get the first element
            if (!processedWWIDs.contains(currentWWID)) {
                processedWWIDs.add(currentWWID);  // Mark this WWID as processed
                
                // Get direct reports for the current WWID
                List<User> directReports = reportsMap.get(currentWWID);
                if (directReports != null) {
                    fullHierarchy.addAll(directReports);
                    
                    // Add direct reports' WWIDs for further processing
                    for (User user : directReports) {
                        if (!processedWWIDs.contains(user.Core_WWID__c)) {
                            wwidList.add(user.Core_WWID__c);
                        }
                    }
                }
            }
        }
        
        return fullHierarchy;
    }
    
    public static List<User> runExample(String wwid) {
        List<User> hierarchy = getFullReportingHierarchy(wwid);
        
        // Output the results
        for (User user : hierarchy) {
            System.debug('User ID: ' + user.Id + ', Name: ' + user.Name);
        }
        
        return hierarchy;
    }
}