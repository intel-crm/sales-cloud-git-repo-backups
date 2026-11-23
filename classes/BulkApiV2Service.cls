/***************************************************************************************************
* @Name BulkApiV2Service 
* @Description Wrapper class over the Bulk API 2.0 Query job REST endpoints. 
* @version 1.0
* @Created Date 13/09/2026
* @Modified Date 08/09/2026
***************************************************************************************************/
public class BulkApiV2Service {
    
    private static final String API_VERSION = 'v60.0';
    private static final String NAMED_CREDENTIAL = 'callout:Salesforce_Bulk_API_Internal_Test';
    private static final Integer DEFAULT_MAX_RECORDS_PER_PAGE = 10000;

    public class BulkAPIException extends Exception{}

    public class ResultsPage {
        public String csv;
        public String nextLocator;
    }

    public static String createQueryJob(String jobName, String soqlQuery){

        try{

            HttpRequest req = new HttpRequest();
            req.setEndpoint(NAMED_CREDENTIAL+'/services/data/'+API_VERSION+'/jobs/query');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            req.setTimeout(120000);
            req.setBody(JSON.serialize(new Map<String, Object>{
                'operation' => 'query',
                'query' => soqlQuery
            }));
    
            HttpResponse res = new Http().send(req);
            if(res.getStatusCode() == 200) {
                Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                System.debug('BULK API: Query Job created');
                return (String) body.get('id');
            } else {
                //Core_Log_Entry.logEntryWithDetails(jobName, 'Quality Builder', 'ISVC', 'Critical', jobName + 'Bulk Query Failed', 'Failed to create query job for: '+ jobName + ' [Status Code: ' + res.getStatusCode() + ']');
                System.debug('Bulk API: Failed to create query job for: '+ jobName + ' [Status Code: ' + res.getStatusCode() + ']');
                return null;
            }
        } catch(Exception exp) {
            //Core_Log_Entry.logEntryWithException(jobName, 'Quality Builder', 'ISVC', 'Critical', jobName + 'Failed to create query job for: '+ jobName, exp);
            System.debug('Bulk API: ' + jobName + 'Failed to create query job for: '+ jobName + 'Exp: ' + exp);
            return null;
        }
    }

    public static Map<String, Object> getJobStatus(String jobName, String bulkJobId) {

        try {

            HttpRequest req = new HttpRequest();
            req.setEndpoint(NAMED_CREDENTIAL + '/services/data/' + API_VERSION + '/jobs/query/' + bulkJobId);
            req.setMethod('GET');
            req.setHeader('Accept', 'application/json');

            HttpResponse res = new Http().send(req);
            if (res.getStatusCode() == 200) {
                System.debug('BULK API: Query Job Status sent');
                return (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            } else {
                //Core_Log_Entry.logEntryWithDetails(jobName, 'Quality Builder', 'ISVC', 'Critical', jobName + 'Bulk Query Failed', 'Failed to get query job status for: '+ bulkJobId + ' [Status Code: ' + res.getStatusCode() + ']');
                System.debug('Bulk API: Failed to create query job for: '+ jobName + ' [Status Code: ' + res.getStatusCode() + ']');
                return null;
            }

        } catch(Exception exp) {
            //Core_Log_Entry.logEntryWithException(jobName, 'Quality Builder', 'ISVC', 'Critical', jobName + 'Failed to get query job status for: '+ bulkJobId, exp);
            System.debug('Bulk API: ' + jobName + 'Failed to get query job status for: '+ bulkJobId + ' Exp: ' + exp);
            return null;
        }
    }

    public static ResultsPage getJobResults(String jobName, String bulkJobId, String locator) {
        return getJobResults(jobName, bulkJobId, locator, DEFAULT_MAX_RECORDS_PER_PAGE);
    }

    public static ResultsPage getJobResults(String jobName, String bulkJobId, String locator, Integer maxRecords) {
        String endpoint = NAMED_CREDENTIAL + '/services/data/' + API_VERSION + '/jobs/query/' + bulkJobId + '/results';
        List<String> queryParams = new List<String>();
        if (String.isNotBlank(locator)) {
            queryParams.add('locator=' + EncodingUtil.urlEncode(locator, 'UTF-8'));
        }
        if (maxRecords != null) {
            queryParams.add('maxRecords=' + maxRecords);
        }
        if (!queryParams.isEmpty()) {
            endpoint += '?' + String.join(queryParams, '&');
        }

        try {

            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Accept', 'text/csv');
            req.setTimeout(120000);
    
            HttpResponse res = new Http().send(req);
            if (res.getStatusCode() == 200) {
                ResultsPage page = new ResultsPage();
                page.csv = res.getBody();
                String rawLocator = res.getHeader('Sforce-Locator');
                page.nextLocator = (rawLocator == 'null') ? null : rawLocator; // API quirk on last page
                System.debug('BULK API: Query Job Results sent');
                return page;
            } else {
                //Core_Log_Entry.logEntryWithDetails(jobName, 'Quality Builder', 'ISVC', 'Critical', jobName + 'Bulk Query Failed', 'Failed to get query job results for: '+ bulkJobId + ' [Status Code: ' + res.getStatusCode() + ']');
                System.debug('Bulk API: Failed to create query job for: '+ jobName + ' [Status Code: ' + res.getStatusCode() + ']');
                return null;
            }

        } catch(Exception exp) {
            //Core_Log_Entry.logEntryWithException(jobName, 'Quality Builder', 'ISVC', 'Critical', jobName + 'Failed to get query job results for: '+ bulkJobId, exp);
            System.debug('Bulk API: ' + jobName + 'Failed to get query job results for: '+ bulkJobId + ' Exp: ' + exp);
            return null;
        }
    }
}