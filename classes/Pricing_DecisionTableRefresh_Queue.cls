public class Pricing_DecisionTableRefresh_Queue implements Queueable, Database.AllowsCallouts{
        private List<String> decisionTableSet;
        private Integer currentIndex;
        private static final Integer CHUNK_SIZE = 10; // Process 10 tables per transaction
        
        public Pricing_DecisionTableRefresh_Queue(List<String> decisionTableSet, Integer index) {
            this.decisionTableSet = decisionTableSet;
            this.currentIndex = index;
        }
        
        public void execute(QueueableContext context) {
            Integer endIndex = Math.min(currentIndex + CHUNK_SIZE, this.decisionTableSet.size());
            
            // Process the current chunk of tables
            for (Integer i = currentIndex; i < endIndex; i++) {
                String decisionTableName = decisionTableSet[i];
                try {
                    // Set second parameter to 'true' if you want incremental refresh, or 'false' for full refresh
                    Http http = new Http();
                    String baseUrl = URL.getOrgDomainUrl().toExternalForm() + '/services/data/v60.0/actions/standard/refreshDecisionTable';
                    
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint(baseUrl);
                    req.setMethod('POST');
                    req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
                    req.setHeader('Content-Type', 'application/json');
                    
                    // Construct payload for the current table
                    String body = '{"inputs": [{"decisionTableApiName": "' + decisionTableName + '", "isDecisionTableIncremental": false}]}';
                    req.setBody(body);
                
                    try {
                        HttpResponse res = http.send(req);
                        // Check if the error indicates a rate limit exception
                        if ((res.getStatusCode() == 429) || (res.getStatusCode() == 400 && res.getBody().contains('limit') || res.getBody().contains('40') || res.getBody().contains('Limit_Exceeded'))) {                                
                            // Push the remaining items out by a full 60 minutes to let the rolling window clear
                            if (!Test.isRunningTest()) {
                                Pricing_DecisionTable_RefreshQueue_Sch.scheduleRetry(this.decisionTableSet, i);
                            }
                            return; 
                        }
                        
                        if (res.getStatusCode() != 200 && res.getStatusCode() != 201) {
                            throw new CalloutException('Refresh Failed for decision table' + decisionTableName + '. Status: ' + res.getStatusCode() + ' Body: ' + res.getBody());
                        }
                    } catch(Exception e) {
                        Pricing_Tender_Utility.logError(e);
                    }
                } catch (Exception e) {
                    Pricing_Tender_Utility.logError(e);
                }
            }
            
            // If more tables remain, automatically chain the next chunk
            if (endIndex < this.decisionTableSet.size()) {
                if (!Test.isRunningTest()) {
                    System.enqueueJob(new Pricing_DecisionTableRefresh_Queue(this.decisionTableSet, endIndex));
                }
            }
        }
}