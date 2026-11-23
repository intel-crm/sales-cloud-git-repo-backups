/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_ProductV1_Handler 
* Version     : 1.0 
* Created Date: 11/20/2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps      11/20/2017                 Handler class to process request and response for the product API
*****************************************************************************************************************************************/
public with sharing class  Core_RestAPI_ProductV1_Handler{
    
    private String ERROR_CODE_500 = '500';
     private String INVALID_QUERY_PRAMS_9010 = '9010';
    private String SUCCESS_CODE_200 = '200';
    private DateTime entryTime = null;
    private String apiName; 
    private String condition{get;set;}
    public Core_RestAPI_Response response = new Core_RestAPI_Response();
    
    private static final String filterCondition = 'Status =\''+'Active'+'\' AND '+
        '( (  RecordType.Name NOT IN (\'IPS Public Product\', \'Public Product\') AND Core_IPS_Project__c = null )  OR  Core_IPS_Project__c != null )';
    
    //condition is not null if api call is with product  
    private static final String GET_PRODUCTS_SOQL='SELECT Core_IPS_Project_Name__c, id,Core_IPS_Case__c , Core_IPS_Project__c ,'+
        'Status ,Core_IPS_Project__r.Core_Status__c,Core_IPS_Project__r.Core_IPS_Project_ID__c,core_Product_Application__c,Core_Supported_Product__r.Core_IPS_Public_Product__c,'+
        'Core_Supported_Product__r.Core_Supported_Product_Name__c, Core_Supported_Product__r.Name FROM Asset WHERE '+
        filterCondition +' LIMIT '+Label.Core_RestAPI_ProductsV1_Records_Limit ; 
    //Default Constructor
    public Core_RestAPI_ProductV1_Handler(DateTime currTime, String APIname){
        this.entryTime = currTime;
        this.apiName = APIname;
        this.condition = '';
        response.successContent = new List<ProductWrapper>();
        System.debug('Core_RestAPI_ProductV1_Handler URI '+RestContext.request.requestURI);
    }
    
    //Retrieve cases for the logged in User
    public Core_RestAPI_Response getProducts(){
        System.debug(' Core_RestAPI_ProductV1_Handler getProducts Entered  \n ');
        try{
            //Validations if need to be handled in util class      
            boolean isRequestValid = doValidations();
            
            //Process the api request
            if(isRequestValid == true)
                processRequest();
            
        }catch(Exception e){
            Core_RestAPI_Util.processException(e, ERROR_CODE_500, response, apiName, entryTime);    
        }finally{
            System.debug('Core_RestAPI_ProductV1_Handler Logging transaction and returning the response '+response);
            if(String.isBlank(response.code))
                response.code = SUCCESS_CODE_200;
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
        }        
        System.debug(' Core_RestAPI_ProductV1_Handler getProducts Exiting ');
        return response;
    } 
    
    //Validate the data , Incase of error set the error code to 
    @testVisible private Boolean doValidations(){
        
        System.debug('Core_RestAPI_ProductV1_Handler doValidations Invoked ');
        Boolean isRequestValid = true;
        return isRequestValid;
    }
    //Execute the SOQL and populate the result to wrapper list objects 
    //Executing SOQL to get all the products for the logged in user and which is not a public product
    public void processRequest(){
        
        System.debug(' Core_RestAPI_ProductV1_Handler processRequest Entering SOQL  \n '+GET_PRODUCTS_SOQL);
        for(Asset objAsset : Database.Query(GET_PRODUCTS_SOQL)){                  
            ProductWrapper objProductWrapper = new ProductWrapper();
            objProductWrapper.intelProductId= objAsset.id;
            objProductWrapper.ipsProjectName = objAsset.Core_IPS_Project_Name__c;
            objProductWrapper.ipsProjectId = objAsset.Core_IPS_Project__r.Core_IPS_Project_ID__c;
            objProductWrapper.productFocusArea =objAsset.core_Product_Application__c;
            objProductWrapper.intelProductName = objAsset.Core_Supported_Product__r.Core_Supported_Product_Name__c;
            response.successContent.add(objProductWrapper);
        } 
        System.debug('processRequest response.successContent '+response.successContent);
        
    }
    //IMPORTANT : Wrapper class must implement the interface Core_RestAPI_SuccessContent
    //Wrapper class to build product's data
    public class ProductWrapper implements Core_RestAPI_SuccessContent{
        
        public String intelProductId{get;set;}
        public String ipsProjectName{get;set;}
        public String ipsProjectId{get;set;}
        public String productFocusArea{get;set;}
        public String intelProductName {get;set;}       
    }
    
}