public class BulkQuoteSubmitScriptPOC {
    
    public static void run(List<String> myJsonList) {
        
        // Pre-load currentUser
        Pricing_RestAPI_QuotesUtilityV2.currentUser = [SELECT Id, ContactId, AccountId, Email  FROM User WHERE Id = :UserInfo.getUserId()];
        
        // LOOP
        for (String quoteJson : myJsonList) {
            
            RestRequest req      = new RestRequest();
            req.requestURI       = '/services/apexrest/v2.0/quoterequest/quotes';
            req.httpMethod       = 'POST';
            req.requestBody      = Blob.valueOf(quoteJson);
            req.params.put('action', 'submit');
            RestContext.request  = req;
            RestContext.response = new RestResponse();
            
            Pricing_RestAPI_QuotesV2.response                  = new Pricing_RestAPI_Response();
            Pricing_RestAPI_QuotesV2.isGetStatus               = false;
            Pricing_RestAPI_QuotesV2.isRollBack                = false;
            Pricing_RestAPI_QuotesV2.isSvdQuote                = false;
            Pricing_RestAPI_QuotesV2.isClient                  = false;
            Pricing_RestAPI_QuotesUtilityV2.isCreateDraftQuote = false;
            Pricing_RestAPI_QuotesUtilityV2.isSubmitQuote      = false;
            Pricing_RestAPI_QuotesUtilityV2.isDataCenterCPU    = false;
            
            Pricing_RestAPI_QuotesUtilityV2.currentUser = [
                SELECT Id, ContactId, AccountId, Email 
                FROM User 
                WHERE Id = :UserInfo.getUserId()
            ];
            
            Pricing_RestAPI_Response res = Pricing_RestAPI_QuotesV2.doPost();
            
            System.debug('Code  : ' + res.code);
            System.debug('Data  : ' + JSON.serialize(res.successContent));
            System.debug('Error : ' + JSON.serialize(res.errorContent));
        }
    }
    
    public static void runFromStaticResource(String staticResourceName) {
        
        // Load JSON array from Static Resource
        StaticResource sr = [ SELECT Body FROM StaticResource WHERE Name = :staticResourceName LIMIT 1];
        
        List<Object> parsedList = (List<Object>) JSON.deserializeUntyped(sr.Body.toString());
        
        List<String> myJsonList = new List<String>();
        for (Object obj : parsedList) {
            myJsonList.add(JSON.serialize(obj));
        }
        
        // Call main run method
        run(myJsonList);
    }
}