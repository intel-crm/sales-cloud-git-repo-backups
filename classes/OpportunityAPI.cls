@RestResource(urlMapping='/opportunitydata/*/*/*')
global with sharing class OpportunityAPI {
	// Define a GET method to retrieve opportunity data for a given account ID
	//public static List<Core_OpportunityDataFetcher.OpportunityWrapper> response = new List<Core_OpportunityDataFetcher.OpportunityWrapper>();
    
    @HttpGet
    global static Pricing_RestAPI_Response getOpportunityData(){
        RestRequest req = RestContext.request;
        // Extract the account ID from the request URL
        List<Core_OpportunityDataFetcher.OpportunityWrapper> oppWrapper = new List<Core_OpportunityDataFetcher.OpportunityWrapper>();
        Pricing_RestAPI_Response restResponse = new Pricing_RestAPI_Response();
        String[] params = req.requestURI.split('/');
        String encodedSellerName = params[2];
        String encodedAccountName = params[3];
        String methodName = params[4];
        // Decode the URL-encoded parameters
        String sellerName = EncodingUtil.urlDecode(encodedSellerName, 'UTF-8');
        String accountId = EncodingUtil.urlDecode(encodedAccountName, 'UTF-8');
        
        if(methodName=='getStagnentOpp'){
            restResponse.successContent = Core_OpportunityDataFetcher.getSparseOpportunity(sellerName,accountId);
        }
        else if(methodName=='getOpenOpp'){
            restResponse.successContent = Core_OpportunityDataFetcher.getOpenOpportunity(sellerName,accountId);
        }
        else if(methodName=='getOppInfo'){
            restResponse.successContent = Core_OpportunityDataFetcher.getOpportunityInfo(sellerName,accountId);
        }
        restResponse.totalRecords = restResponse.successContent.size();
        
        // Call the method from the Core_OpportunityDataFetcher class
        
        return restResponse;
    }
}