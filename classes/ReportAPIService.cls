public class ReportAPIService {

    public static void runReport(String reportId) {

        String endpoint ='callout:ReportNC/services/data/v59.0/analytics/reports/' + reportId;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            System.debug('API Error: ' + res.getBody());
            throw new AuraHandledException('Report calling failed: ' + res.getStatusCode());
        }

        parseReportResults(res.getBody());
    }

    private static void parseReportResults(String jsonResponse) {

        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);

        
        Map<String, Object> factMap = (Map<String, Object>) root.get('factMap');
        Map<String, Object> details = (Map<String, Object>) factMap.get('T!T');

        if (details == null || !details.containsKey('rows')) {
            System.debug('No rows returned from report');
            return;
        }

        List<Object> rows = (List<Object>) details.get('rows');
        List<Account> toUpdate = new List<Account>();

        for (Object rowObj : rows) {

            Map<String, Object> row = (Map<String, Object>) rowObj;

            List<Object> dataCells  = (List<Object>) row.get('dataCells');

           
            Map<String, Object> idCell = (Map<String, Object>) dataCells.get(0);
            String accountId = (String) idCell.get('label');
            
            if (String.isBlank(accountId)) {
                continue;
            }

            Map<String, Object> nameCell = (Map<String, Object>) dataCells.get(1);
            String accountName = (String) nameCell.get('label');

            Map<String, Object> tierCell = (Map<String, Object>) dataCells.get(2);
            String accountTier = (String) tierCell.get('label');

            System.debug('Row :' + accountId + ' ' + accountName + ' ' + accountTier);

           
            Account acc = new Account(
                Id = accountId,
                Name = accountName,                     
                Core_IPA_Badge_Tier__c = accountTier          
            );

            //toUpdate.add(acc);
        }

        
        // if (!toUpdate.isEmpty()) {
        //     update toUpdate;
        //     System.debug('Updated accounts: ' + toUpdate.size());
        // }
    }
}