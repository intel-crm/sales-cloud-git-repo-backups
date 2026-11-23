public class Pricing_DecisionTableRefresh_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Pull up to 20 pending tables
        return Database.getQueryLocator([
            SELECT Id, Pricing_Decision_Table_API_Name_Txt__c 
            FROM Pricing_Decision_Table_Refresh_Queue__c 
            WHERE Pricing_Decision_Table_Refresh_Status_Nm__c = 'Pending' 
            LIMIT 20
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Pricing_Decision_Table_Refresh_Queue__c> scope) {
        List<Pricing_Decision_Table_Refresh_Queue__c> recordsToUpdate = new List<Pricing_Decision_Table_Refresh_Queue__c>();
        
        for (Pricing_Decision_Table_Refresh_Queue__c queueItem : scope) {
            try {
                Http http = new Http();
                String baseUrl = URL.getOrgDomainUrl().toExternalForm() + '/services/data/v60.0/actions/standard/refreshDecisionTable';
                
                HttpRequest req = new HttpRequest();
                req.setEndpoint(baseUrl);
                req.setMethod('POST');
                req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
                req.setHeader('Content-Type', 'application/json');
                
                // Construct payload for the current table
                String body = '{"inputs": [{"decisionTableApiName": "' + queueItem.Pricing_Decision_Table_API_Name_Txt__c + '", "isDecisionTableIncremental": false}]}';
                req.setBody(body);
                
                try {
                    HttpResponse res = http.send(req);
                    if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                        queueItem.Pricing_Decision_Table_Refresh_Status_Nm__c = 'Completed';
                        System.debug('Successfully queued refresh for: ' + queueItem.Pricing_Decision_Table_Refresh_Status_Nm__c);
                    } else {
                        queueItem.Pricing_Decision_Table_Refresh_Status_Nm__c = 'Failed';
                        System.debug('Failed to refresh Decision Table' + queueItem.Pricing_Decision_Table_Refresh_Status_Nm__c + ': ' + res.getBody());
                    }
                } catch (Exception e) {
                    System.debug('Exception refreshing ' + queueItem.Pricing_Decision_Table_Refresh_Status_Nm__c + ': ' + e.getMessage());
                }
                /*Invocable.Action action = Invocable.Action.createStandardAction('refreshDecisionTable');
                action.setInvocationParameter('decisionTableApiName', queueItem.Pricing_Decision_Table_API_Name_Txt__c.split('->')[0]);
                List<Invocable.Action.Result> results = action.invoke();

                for (Invocable.Action.Result result : results) {
                    if (result.isSuccess()) {
                         queueItem.Pricing_Decision_Table_Refresh_Status_Nm__c = 'Completed';
                        System.debug('Decision table refreshed successfully');
                    } else {
                        queueItem.Pricing_Decision_Table_Refresh_Status_Nm__c = 'Failed';
                        System.debug('Refresh failed: ' + result.getErrors());
                    }
                }*/
                
            } catch (Exception ex) {
                queueItem.Pricing_Decision_Table_Refresh_Status_Nm__c = 'Failed';
            }
            recordsToUpdate.add(queueItem);
        }
        update recordsToUpdate;
    }
    
    public void finish(Database.BatchableContext bc) {
        // Check if there are remaining pending records that couldn't fit in this hour's limit
        Integer remainingCount = [SELECT COUNT() FROM Pricing_Decision_Table_Refresh_Queue__c WHERE Pricing_Decision_Table_Refresh_Status_Nm__c = 'Pending' LIMIT 1];
        
        if (remainingCount > 0) {
            // Schedule a ONE-TIME job to run exactly 60 minutes from now
            Datetime executionTime = System.now().addMinutes(60);
            
            // Format CRON expression for a specific date/time: s m H d M ? Y
            String cronStr = executionTime.format('s m H d M') + ' ? ' + executionTime.format('yyyy');
            String jobName = 'DecisionTable_DelayedChain_' + executionTime.getTime();
            
            System.schedule(jobName, cronStr, new Pricing_DecisionTable_RefreshBatch_Sch());
        }
        // If remainingCount == 0, the engine completely stops executing!
    }
}