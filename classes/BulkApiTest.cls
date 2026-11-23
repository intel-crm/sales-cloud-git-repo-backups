public class BulkApiTest {
    // Define Salesforce instance URL and API version
    private static final String SALESFORCE_INSTANCE_URL = 'https://intel--crmdevsls3.sandbox.my.salesforce.com';
    private static final String API_VERSION = '59.0';
    
    // Define the access token (you must obtain this through authentication)
    private static final String ACCESS_TOKEN = 'YOUR_ACCESS_TOKEN';
    
    public static void executeBulkApi2Example() {
        
        // Query data from the source object (e.g., Source_Object__c)
        String query = 'SELECT Id, Name FROM product2 LIMIT 10'; // Adjust your query as needed
        
        // Perform the query and get CSV data
        List<sObject> queryResults = executeQuery(query);
        String csvData = createCSVFromQuery();
        
        // Create a Bulk API 2.0 job for inserting data
        String jobInfoEndpoint = SALESFORCE_INSTANCE_URL + '/services/data/v' + API_VERSION + '/jobs/ingest';
        String jobInfoRequest = '{"operation": "insert", "object":  "Core_Products_Staging__c" , "contentType": "CSV"}';
        
        HttpRequest jobInfoHttpRequest = new HttpRequest();
        jobInfoHttpRequest.setEndpoint(jobInfoEndpoint);
        jobInfoHttpRequest.setMethod('POST');
        jobInfoHttpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        jobInfoHttpRequest.setHeader('Content-Type', 'application/json');
        jobInfoHttpRequest.setBody(jobInfoRequest);
        
        // Create the job
        HttpResponse jobInfoResponse = new Http().send(jobInfoHttpRequest);
        Map<String, Object> jobIdresponse = (Map<String, Object>)JSON.deserializeUntyped(jobInfoResponse.getBody());
        String jobId = (String) jobIdresponse.get('id');
        
        // Upload data to the job
        String dataEndpoint = SALESFORCE_INSTANCE_URL + '/services/data/v' + API_VERSION + '/jobs/ingest/' + jobId + '/batches';
        HttpRequest dataHttpRequest = new HttpRequest();
        dataHttpRequest.setEndpoint(dataEndpoint);
        dataHttpRequest.setMethod('PUT');
        dataHttpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        dataHttpRequest.setHeader('Content-Type', 'text/csv');
        dataHttpRequest.setBody(csvData);
        
        HttpResponse dataHttpResponse = new Http().send(dataHttpRequest);
        system.debug(dataHttpResponse.getStatusCode());
        //String batchId = dataHttpResponse.getHeader('Location').substring(dataHttpResponse.getHeader('Location').lastIndexOf('/') + 1);
        
        // Close the job to start processing
        String closeEndpoint = SALESFORCE_INSTANCE_URL + '/services/data/v' + API_VERSION + '/jobs/ingest/' + jobId;
        HttpRequest closeHttpRequest = new HttpRequest();
        closeHttpRequest.setEndpoint(closeEndpoint);
        closeHttpRequest.setMethod('PATCH');
        closeHttpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        closeHttpRequest.setHeader('Content-Type', 'application/json');
        closeHttpRequest.setBody('{"state": "UploadComplete"}');
        
        HttpResponse closeHttpResponse = new Http().send(closeHttpRequest);
        /*
        // Check the status of the job
        String jobStatusEndpoint = SALESFORCE_INSTANCE_URL + '/services/data/v' + API_VERSION + '/jobs/ingest/' + jobId;
        HttpRequest jobStatusHttpRequest = new HttpRequest();
        jobStatusHttpRequest.setEndpoint(jobStatusEndpoint);
        jobStatusHttpRequest.setMethod('GET');
        jobStatusHttpRequest.setHeader('Authorization', 'Bearer ' + ACCESS_TOKEN);
        
        HttpResponse jobStatusHttpResponse = new Http().send(jobStatusHttpRequest);
        String jobStatus = jobStatusHttpResponse.getBody();
        
        // Handle job status and potential errors here
        System.debug('Job Status: ' + jobStatus);*/
    }
    
    // Execute a SOQL query and return the results as a list of sObjects
    private static List<sObject> executeQuery(String query) {
        return Database.query(query);
    }
    
    // Create CSV data from a list of sObjects
    public static String createCSVFromQuery() {
        List<String> fieldsList = Product_Utility.getObjectFields('Product_Inbound_Staging__c');
        String csvColumnHeader = String.join(Product_Utility.getObjectFields('Product_Inbound_Staging__c'),',');
        List<String> csvRowValues = new List<String>();
        for(Product_Inbound_Staging__c inb : Database.query('SELECT '+String.join(Product_Utility.getObjectFields('Product_Inbound_Staging__c'),',')+' FROM Product_Inbound_Staging__c limit 10')){
            String csvRowVal='';
            for(String s: fieldsList){
                csvRowVal += string.valueOf(inb.get(s))+',';
            }
            csvRowValues.add(csvRowVal);
            system.debug('csvRowVal --- '+csvRowVal);
        }
        System.debug('csvRowValues size --- '+csvRowValues.size());
        String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
        system.debug('csvFile --- '+csvFile);
        return csvFile;
    }
}