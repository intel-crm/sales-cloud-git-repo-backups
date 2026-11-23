/******************************************************************************************************************************************
Class Name  : Core_CampaignWaveImportController
Version     : 1.0 
Created Date: 01 JAN 2016
Function    : Custom controller for the Campaign Wave Import VF page. Much of the code in this class was copied
              from Salesforce Wave Labs code and modified to fit our requirements.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Dave Hood                 01/19/2016              Original version
*****************************************************************************************************************************************/
global class Core_CampaignWaveImportController {
    
    // Constants for the query and CSV result set generation
    //private static final String URL_LENS_APEX = '/analytics/wave/web/lens.apexp';
    private static final String URL_LENS_APEX = '/analytics/wave/web/explore.apexp';
    private static final Set<String> ACCOUNT_ID_FIELD_NAMES = new Set<String>{'account_id','Core_Account_Name__c.Id','Core_Account_Name__c'};
    private static final String ACCOUNT_NAME_FIELD_NAME = 'Core_Account_Name__c.Name';
    private static final String ACCOUNT_OWNER_FIELD_NAME = 'Core_Account_Name__c.Owner.Name';
    private static final String BUSINESS_ID_FIELD_NAME = 'Business ID';
    private static final Integer QUERY_LIMIT = 20000; // 22000 is currently the upper limit, due to Apex CPU time and SOQL records returned
    private static final Boolean OVERRIDE_DEFAULT_QUERY_LIMIT = TRUE;
    
    //public Campaign camp { get; set; } // Don't actually need this yet, but may in the future
    
    public String sid { get; set; }
    public String org { get; set; }
    
    public Core_CampaignWaveImportController() {
        
        // Don't actually need this yet, but may in the future
        //Id campId = ApexPages.currentPage().getParameters().get('id');
        //camp = [select Id, Name from Campaign where Id = :campId];
        
        String forwardedHeader = ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To');
        org = 'https://' + ((forwardedHeader == null) ? ApexPages.currentPage().getHeaders().get('host') : forwardedHeader);
        sid = getSessionIdFromLensApex();
    }
    
    // Get all lenses that user has access to for initial opening of VF page    
    @RemoteAction
    global static string getLenses(){
        return makeRequest('lenses', 'GET');
    }
    
    // Get all datasets for future dataset alias to ID mapping during initial opening of VF page
    @RemoteAction
    global static string getDatasets(){
        return makeRequest('datasets', 'GET');
    }
    
    // Get JSON for one specific lens which was selected by the user
    @RemoteAction
    global static string getOneLens(string lensId, string sID){
        System.debug('##### getOneLens');
        string lensString = makeRequest('lenses/'+lensId, 'GET');
        System.debug('##### lensString: ' + lensString);
        Map<String, Object> lensMapped = (Map<String, Object>)JSON.deserializeUntyped(lensString);
        Map<String, Object> dataSetAttr = (Map<String, Object>)lensMapped.get('dataset');
        
        Map<String, Object> xmd = getXMD((string)dataSetAttr.get('id'), sID);
        Map<String, String> toReturn = new Map<String,String>();
        
        toReturn.put('lensJson', lensString);
        toReturn.put('datasetVersion', (string)xmd.get('datasetVersion'));
        toReturn.put('xmdJson', (string)xmd.get('xmd'));
        System.debug('##### toReturn: ' + toReturn);
     
        return JSON.serialize(toReturn);
    }
    
    // Send generated queries for non-comparetable types and get results in a JSON string
    @RemoteAction
    global static String getQueryResults(String queryString, Boolean csv) {
        
        // For now, strip out the default limits from Wave, replace with a higher upper limit
        // TO DO: refactor this to be more generic
        if (OVERRIDE_DEFAULT_QUERY_LIMIT) {
            queryString = queryString.replace('limit q 100;', 'limit q ' + QUERY_LIMIT + ';');
            queryString = queryString.replace('limit q 200;', 'limit q ' + QUERY_LIMIT + ';');
            queryString = queryString.replace('limit q 1000;', 'limit q ' + QUERY_LIMIT + ';');
            queryString = queryString.replace('limit q 5000;', 'limit q ' + QUERY_LIMIT + ';');
            queryString = queryString.replace('limit q 10000;', 'limit q ' + QUERY_LIMIT + ';');
            queryString = queryString.replace('limit q 15000;', 'limit q ' + QUERY_LIMIT + ';');
            queryString = queryString.replace('limit q 20000;', 'limit q ' + QUERY_LIMIT + ';');
        }
        
        // Strip out any fields we don't need
        queryString = queryString.remove(', \'account_name\' as \'account_name\'');
        queryString = queryString.remove(', \'business_id\' as \'business_id\'');
        queryString = queryString.remove(', \'country\' as \'country\'');
        queryString = queryString.remove(', \'current_membership_tier\' as \'current_membership_tier\'');
        queryString = queryString.remove(', \'geo\' as \'geo\'');
        queryString = queryString.remove(', \'invoice_date\' as \'invoice_date\'');
        queryString = queryString.remove(', \'invoice_quarter\' as \'invoice_quarter\'');
        queryString = queryString.remove(', \'invoice_ww\' as \'invoice_ww\'');
        queryString = queryString.remove(', \'invoice_year\' as \'invoice_year\'');
        queryString = queryString.remove(', \'product_level_1\' as \'product_level_1\'');
        queryString = queryString.remove(', \'product_level_4\' as \'product_level_4\'');
        queryString = queryString.remove(', \'product_level_5\' as \'product_level_5\'');
        queryString = queryString.remove(', \'product_level_6\' as \'product_level_6\'');
        queryString = queryString.remove(', \'sales_revenue\' as \'sales_revenue\'');
        queryString = queryString.remove(', \'sales_type\' as \'sales_type\'');
        queryString = queryString.remove(', \'sales_units\' as \'sales_units\'');
        
        Map<String,String> queryBody = new Map<String,String>();
        queryBody.put('query', queryString);
        System.debug('##### queryBody: ' + queryBody);
        String results = makeRequest('query', 'POST', queryBody);
        System.debug('##### results: ' + results);
        
        // If we're generating a CSV file (or output to display), we need to do a few more things with the JSON results
        // we got from the Lens query before returning the final JSON. Basically we're dropping some fields and
        // augmenting the data with additional fields to construct a CSV that can be bulk-imported into a Campaign.
        //   - Capture key values in the JSON (action, responseId, query, responseTime) to reconstruct it later
        //   - Build up a set of all Account IDs, as well as a list of "export records" which will be the full
        //     set of augmented records we'll return
        //   - Query for the extra data we need (Account & Contact data), and use it to build up the augmented records
        //   - Reconstruct the JSON to based on the augmented records, and return it
        
        if (csv == true ) {
            Set<Id> accountIds = new Set<Id>();
            List<ExportRecord> exportRecords = new List<ExportRecord>();
            String jsonAction, jsonResponseId, jsonQuery, jsonResponseTime;
            
            JSONParser parser = JSON.createParser(results);
            
            while (parser.nextToken() != null) {                
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String field = parser.getText();
                    if (field == 'action') {
                        parser.nextToken();
                        jsonAction = parser.getText();
                    }
                    else if (field == 'responseId') {
                        parser.nextToken();
                        jsonResponseId = parser.getText();
                    }
                    else if (field == 'query') {
                        parser.nextToken();
                        jsonQuery = parser.getText();
                    }
                    else if (field == 'responseTime') {
                        parser.nextToken();
                        jsonResponseTime = parser.getText();
                    }
                    // If we're on an Account ID field, build the set of IDs for the SOQL query for supplemental data
                    else if (ACCOUNT_ID_FIELD_NAMES.contains(field)) {
                        parser.nextToken();
                        if (!accountIds.contains(parser.getIdValue())) {
                            accountIds.add(parser.getIdValue());
                            exportRecords.add(new ExportRecord(parser.getIdValue()));
                        }
                    }
                }
            }
            
            if (accountIds.size() > 0) {
                
                // Query for all of our supplemental data, and add it in
                Map<Id,Account> supplementalData = new Map<Id,Account>([select Id, Name, Owner.Name, Core_Business_ID__c,
                                                                        (select Id, Name, Email, Core_Primary_Contact__c from Contacts
                                                                         order by Core_Primary_Contact__c desc, LastName, FirstName limit 1)
                                                                        from Account where Id in :accountIds]);
                
                if (supplementalData.size() > 0) {
                    for (ExportRecord e : exportRecords) {
                        if (supplementalData.containsKey(e.accountId)) {
                            Account acct = supplementalData.get(e.accountId);
                            e.accountName = acct.Name;
                            e.accountOwner = acct.Owner.Name;
                            e.businessId = acct.Core_Business_ID__c;
                            if (acct.Contacts.size() > 0) {
                                e.contactId = acct.Contacts[0].Id;
                                e.contactName = acct.Contacts[0].Name;
                                e.contactEmail = acct.Contacts[0].Email;
                                e.primaryContactFlag = acct.Contacts[0].Core_Primary_Contact__c;
                            }
                        }
                    }
                }
            }
            
            // Custom-generate the new JSON, in the most compact format possible, to help with performance/scalability
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartArray();
            for (ExportRecord e : exportRecords) {
                gen.writeStartObject();
                gen.writeIdField('0', e.accountId);
                gen.writeStringField('1', e.accountName);
                gen.writeStringField('2', e.accountOwner);
                gen.writeStringField('3', (e.businessId != null ? e.businessId : '') );
                gen.writeStringField('4', (e.contactId != null ? e.contactId : ''));
                gen.writeStringField('5', (e.contactName != null ? e.contactName : ''));
                gen.writeStringField('6', (e.contactEmail != null ? e.contactEmail : ''));
                gen.writeBooleanField('7', e.primaryContactFlag);
                gen.writeEndObject();
            }
            gen.writeEndArray();
            String jsonRecords = gen.getAsString();
            
            String jsonFull = '{ "action" : "' + jsonAction + '", "responseId" : "' + jsonResponseId + '", "results" : { "records" : ' +
                jsonRecords + '}, "query" : "SAQL + SOQL (see debug logs)", "responseTime" : ' + jsonResponseTime + ' }';
            
            return JSON.serialize(jsonFull);
        }
        else
            return JSON.serialize(results);
    }
    
    // Data structure to represent one "export record," which is everything we need to create the CSV format
    private class ExportRecord {
        Id      accountId;
        String  accountName = '';
        String  accountOwner = '';
        String  businessId = '';
        String  contactId;
        String  contactName = '';
        String  contactEmail = '';
        Boolean primaryContactFlag = false;
        
        ExportRecord(Id acctId) {
            accountId = acctId;
        }
    }
    
    // Public API GET Request here
    global static string makeRequest(string endpoint, string method) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://' + getWaveURL() + endpoint);
        req.setHeader('Authorization', 'Bearer ' + getSessionID());
        req.setMethod(method);
        
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        System.debug('##### HTTP GET - request: ' + req);
        res = http.send(req);
        System.debug('##### HTTP GET - response: ' + res);
        System.debug('##### HTTP GET - response body: ' + res.getBody());
        
        return res.getBody();
    }
    
    // Public API Post Request here
    global static string makeRequest(string endpoint, string method, Map<string, string> body){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://' + getWaveURL() + endpoint);
        req.setHeader('Authorization', 'Bearer ' + getSessionID());
        req.setHeader('Content-Type','application/json');
        req.setMethod(method);
        req.setBody(JSON.serialize(body));
        
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        res = http.send(req);
        System.debug('##### HTTP POST - req: ' + req);
        System.debug('##### HTTP POST - req.getBody(): ' + body);
        System.debug('##### HTTP POST - res: ' + res);
        System.debug('##### HTTP POST - res.getBody(): ' + res.getBody());
        
        return res.getBody();
    }
    
    @RemoteAction
    global static string getBaseURL(){
        return System.URL.getSalesforceBaseURL().toExternalForm();
    }
    
    // Get session ID for public API
    @RemoteAction
    global static String getSessionID(){
        return UserInfo.getSessionId();
    }
    
    // Get URL for Wave Public REST API
    global static string getWaveURL(){
        //string url = System.URL.getSalesforceBaseUrl().getHost() + '/services/data/v36.0/wave/';
        string url = System.URL.getSalesforceBaseUrl().getHost() + '/services/data/v' + getNewestVersion() + '/wave/';
        return url;
    }
    
    // [Note: Salesforce descripton here]
    // Get newest version of API which is available in org, this is not best practice and I will be fixing this
    // but doing this as a workaround due to Wave API still being in Pilot mode
    global static string getNewestVersion(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(getBaseURL() + '/services/data');
        req.setHeader('Authorization', 'Bearer ' + getSessionID());
        req.setMethod('GET');
        
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        res = http.send(req);
        //System.debug('##### HTTP GET - req: ' + req);
        //System.debug('##### HTTP GET - res: ' + res);
        //System.debug('##### HTTP GET - res.getBody(): ' + res.getBody());
        
        List<Object> versionsList = (List<Object>)JSON.deserializeUntyped(res.getBody());
        Map<String, Object> lastVersion = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize((versionsList[versionsList.size()-1])));
        
        return (string)lastVersion.get('version');
    }
    
    // Get XMD which still uses old Private API as new API gets XMD 2.0 but compact -> SAQL code in JS uses 1.0
    global static Map<String, Object> getXMD(string datasetId, string sID){
        string datasetInfoString = makeRequest('datasets/'+ datasetId, 'GET');
        Map<String, Object> datasetInfoMap = (Map<String, Object>)JSON.deserializeUntyped(datasetInfoString); 
        string currentID = (string)datasetInfoMap.get('currentVersionId');  
        string endpoint = String.format('/insights/internal_api/v1.0/esObject/edgemart/{0}/version/{1}/file/main.xmd.json', new String[]{datasetId, currentID});  
        string xmdString = oldApiRequest(endpoint, 'GET', sID);
        
        Map<String, Object> toReturnMap = new Map<String, Object>();
        toReturnMap.put('datasetVersion', currentID);
        toReturnMap.put('xmd', xmdString);
        
        return toReturnMap;
    }
    
    // Private API request specifically for purpose of getting old (1.0) XMD
    global static string oldApiRequest(string fullEndpoint, string method, string sId){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://'+System.URL.getSalesforceBaseUrl().getHost()+fullEndpoint);
        req.setHeader('Authorization', 'Bearer ' + sId);
        req.setMethod(method);
        
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        res = http.send(req);
        
        // redirection checking
        boolean redirect = false;
        if ((res.getStatusCode() >=300 && res.getStatusCode() <= 307 && res.getStatusCode() != 306) || (Test.isRunningTest())) {
            do {
            redirect = false; // reset the value each time
            String loc = res.getHeader('Location'); // get location of the redirect
            if(loc == null) {
                redirect = false;
                continue;
            }
            req = new HttpRequest();
            req.setEndpoint(loc);
            req.setHeader('Authorization', 'Bearer ' + getSessionID());
            req.setMethod('GET');
            res = http.send(req);
            if(res.getStatusCode() != 500) { // 500 = fail
                if(res.getStatusCode() >=300 && res.getStatusCode() <= 307 && res.getStatusCode() != 306) {
                    redirect= true;
                }
            }
        } while (redirect && Limits.getCallouts() != Limits.getLimitCallouts());
            return res.getBody();
        }
        return res.getBody();
    }
    
    // Get Session ID from lens.apex page to use with the Private API as sometimes Public API session ID doesn't work for this
    global String getSessionIdFromLensApex() {
        String homeContent;
        PageReference home = new PageReference(org + URL_LENS_APEX);

        if(test.isRunningTest()) {
            homeContent = 'Some random string';
        } else {
            blob homeblob = home.getContent();            
            homeContent = homeblob.toString();
        }
        Matcher m = Pattern.compile('\"OAuth \" [+] \"([\\w!.]+)').matcher(homeContent);
        
        if(m.find()) {
            return m.group(1);
        } else {
            return UserInfo.getSessionId();
        }
    } 
}