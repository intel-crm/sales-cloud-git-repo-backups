public class SK_OpportunityService {
 	// Method to fetch Opportunity and OpportunityLineItem attributes and return as JSON
    public static String getOpportunitiesAndLineItemsAsJson(Id accountId, Id ownerId) {
        // List to hold the results
        List<OpportunityWrapper> results = new List<OpportunityWrapper>();
        
        // Query to fetch Opportunities based on Account ID and Owner ID
        List<Opportunity> opportunities = [
            SELECT Id, Name, StageName, CloseDate, Amount
            FROM Opportunity
            WHERE AccountId = :accountId AND OwnerId = :ownerId
        ];
        
        // Iterate through each Opportunity
        for (Opportunity opp : opportunities) {
            // Query to fetch OpportunityLineItems for the current Opportunity
            List<OpportunityLineItem> lineItems = [
                SELECT Id, OpportunityId, Product2Id, Quantity, UnitPrice, TotalPrice
                FROM OpportunityLineItem
                WHERE OpportunityId = :opp.Id
            ];
            
            // Create a wrapper object to hold Opportunity and its LineItems
            OpportunityWrapper oppWrapper = new OpportunityWrapper();
            oppWrapper.opportunity = opp;
            oppWrapper.lineItems = lineItems;
            
            // Add the wrapper object to the results list
            results.add(oppWrapper);
        }
        
        // Convert the results to JSON
        String jsonResponse = JSON.serialize(results);
        
        // Return the JSON response
        return jsonResponse;
    }
    
    // Wrapper class to hold Opportunity and its LineItems
    public class OpportunityWrapper {
        public Opportunity opportunity { get; set; }
        public List<OpportunityLineItem> lineItems { get; set; }
    }


}