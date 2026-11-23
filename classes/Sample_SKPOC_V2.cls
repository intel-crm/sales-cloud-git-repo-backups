@RestResource(urlMapping='/skpocv2')
global class Sample_SKPOC_V2 implements RestResponse{
/*
    private static DateTime entryTime = System.now();

     
    
    @HttpGet
    global static SKPOC_V2_Core_RestApiResponse doGet(){
        
        SKPOC_V2_RestApi getInstance = new SKPOC_V2_RestApi();
        String sql = null;
        Map<String, String> fieldMapping = new Map<String, String>();
        SKPOC_V2_RestApiGetRequestHandler handler = null;
        
        
            
        sql = ' SELECT Id,CaseNumber,Status,Subject,LastModifiedDate, Core_CEP_Contact_Update__c, Core_Next_Response_Due_Date__c, CreatedDate, Asset.Core_Supported_Product__r.Name, Contact.Account.Name  '+
                     ' FROM case WHERE Asset.Core_Supported_Product__r.Name != null  LIMIT 100';

        fieldMapping.put('CaseNumber', 'CaseNumber_Custom');
        fieldMapping.put('Subject', 'Subject_Custom');
        fieldMapping.put('Id', 'id_Custom');   
        fieldMapping.put('Status', 'Status_Custom');   
        fieldMapping.put('Core_CEP_Contact_Update__c', 'CEP_Contact__Custom');   
        fieldMapping.put('Core_Next_Response_Due_Date__c', 'NextxResponseDate__Custom');   
        fieldMapping.put('CreatedDate', 'CreatedDate_Custom');
        fieldMapping.put('LastModifiedDate', 'LastModifiedDate_Custom');  
        fieldMapping.put('Asset.Core_Supported_Product__r.Name', 'ProductName');  
        fieldMapping.put('Contact.Account.Name', 'AccountName');  
        handler = new SKPOC_V2_RestApiGetRequestHandler(sql, entryTime, fieldMapping);

        handler.queryRecords();  
        
        SKPOC_V2_Core_RestApiResponse resp = new SKPOC_V2_Core_RestApiResponse();

        return null;
    }
    
    
    @HttpPost
    global static void createCase(){
        //Steps : Write another handler by extending abstract class
        //Core_Rest_CreateCasesHandler handler = new Core_Rest_CreateCasesHandler();
    }
    */
}