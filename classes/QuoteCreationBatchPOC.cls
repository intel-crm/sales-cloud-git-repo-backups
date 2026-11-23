global class QuoteCreationBatchPOC implements Database.Batchable<String> {
    
    String actionType;
    List<String> jsonList;
    
    global QuoteCreationBatchPOC(List<String> jsons, String action) {
        jsonList   = jsons;
        actionType = action;
    }
    
    global List<String> start(Database.BatchableContext bc) {
        return jsonList;
    }
    
    global void execute(Database.BatchableContext bc, List<String> scope) {
        
        // ── Step 1: Initialize currentUser ──────────────────────────
        try {
            Pricing_RestAPI_QuotesUtilityV2.currentUser = [
                SELECT Id, ContactId, AccountId, Email 
                FROM User 
                WHERE Id = :UserInfo.getUserId() 
                LIMIT 1
            ];
        } catch(Exception ex) {
            System.debug('Failed to load currentUser: ' + ex.getMessage());
            return;
        }
        
        // ── Step 2: Mock RestContext (NULL in Batch!) ────────────────
        // RestContext.response is NULL in Batch → causes line 89 crash
        // Must initialize ONCE before the loop
        RestRequest  mockRequest  = new RestRequest();
        RestResponse mockResponse = new RestResponse();
        
        mockRequest.requestURI  = '/services/apexrest/v2.0/quoterequest/quotes';
        mockRequest.httpMethod  = 'POST';
        mockRequest.params.put('action', actionType);
        
        RestContext.request  = mockRequest;
        RestContext.response = mockResponse;
        
        for(String requestBody : scope) {
            try {
                // ── Step 3: Reset response mock per iteration ────────
                RestContext.response            = new RestResponse();
                RestContext.request             = new RestRequest();
                RestContext.request.requestURI  = '/services/apexrest/v2.0/quoterequest/quotes';
                RestContext.request.httpMethod  = 'POST';
                RestContext.request.params.put('action', actionType);
                
                // ── Step 4: Reset ALL statics ────────────────────────
                Pricing_RestAPI_QuotesV2.response                  = new Pricing_RestAPI_Response();
                Pricing_RestAPI_QuotesV2.actionType                = actionType;
                Pricing_RestAPI_QuotesV2.isGetStatus               = false;
                Pricing_RestAPI_QuotesV2.isCreateQuoteTeam         = false;
                Pricing_RestAPI_QuotesV2.isResubmit                = false;
                Pricing_RestAPI_QuotesV2.isRollBack                = false;
                Pricing_RestAPI_QuotesV2.isSvdQuote                = false;
                Pricing_RestAPI_QuotesV2.isClient                  = false;
                Pricing_RestAPI_QuotesV2.qliTypeToQli              = new Map<String, List<SBQQ__QuoteLine__c>>();
                Pricing_RestAPI_QuotesV2.pmMap                     = new Map<Id, List<Pricing_Performance_Metric__c>>();
                Pricing_RestAPI_QuotesUtilityV2.isCreateDraftQuote = (actionType == 'create');
                Pricing_RestAPI_QuotesUtilityV2.isSubmitQuote      = (actionType == 'submit');
                Pricing_RestAPI_QuotesUtilityV2.isDataCenterCPU    = (actionType == 'submit');
                Pricing_RestAPI_QuotesUtilityV2.isUpdateDraftQuote = false;
                
                // ── Step 5: Process ──────────────────────────────────
                Pricing_RestAPI_QuotesV2.processRequest(requestBody);
                
                // ── Step 6: Log result ───────────────────────────────
                Pricing_RestAPI_Response res = Pricing_RestAPI_QuotesV2.response;
                if(res != null && res.code == '200') {
                    System.debug('Success => ' + JSON.serialize(res.successContent));
                } else {
                    System.debug('Failed  => ' + JSON.serialize(res?.errorContent));
                }
                
            } catch(Exception ex) {
                System.debug('Error: ' + ex.getMessage() 
                           + ' | Line: '  + ex.getLineNumber()
                           + ' | Stack: ' + ex.getStackTraceString());
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('All Quotes Processed!');
    }
}