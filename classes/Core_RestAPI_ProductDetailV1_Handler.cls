/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_ProductDetailV1_Handler
* Version     : 1.0 
* Created Date: 12/13/2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps      12/13/2017                 Handler class to process request and response for the product API
*****************************************************************************************************************************************/
public with sharing class  Core_RestAPI_ProductDetailV1_Handler{
    
    private String ERROR_CODE_500 = '500';
    private String SUCCESS_CODE_200 = '200';
    private String MALFORMED_INPUT_9011 = '9011';
    private DateTime entryTime = null;
    private String apiName; 
    public Core_RestAPI_Response response = new Core_RestAPI_Response();
    
   // private static final String filterCondition = 'Core_Supported_Product__r.Core_IPS_Public_Product__c = false ';
    private static final String filterCondition = 'RecordType.Name NOT IN (\'IPS Public Product\', \'Public Product\')';
    private static final String productFilterCondition = Core_RestAPI_Util.getConditionWithURIParam('id',3); 
    private static final String PRODUCT_ID = Core_RestAPI_Util.getInputFromURIParam(3);
    
    //condition is not null if api call is with product
    private static final String GET_PRODUCTS_SOQL='SELECT Core_IPS_Project_Name__c, id, Core_IPS_Project__c'+
        ',core_Product_Application__c,Core_IPS_Project__r.Core_IPS_Project_ID__c,Core_Supported_Product__r.Core_IPS_Public_Product__c'+
        ',Core_Supported_Product__r.Core_Supported_Product_Name__c, Core_Supported_Product__r.Name'+  
        ' FROM Asset WHERE '+productFilterCondition+' AND ' +filterCondition +' LIMIT 1';
    
    //Default Constructor
    public Core_RestAPI_ProductDetailV1_Handler(DateTime currTime, String APIname){
        this.entryTime = currTime;
        this.apiName= APIname;
        response.successContent = new List<ProductWrapper>();
        System.debug('Core_RestAPI_ProductDetailV1_Handler  URI '+RestContext.request.requestURI  );
    }
    
    
    //Retrieve product for the logged in User
    public Core_RestAPI_Response getProducts(){
        
        System.debug(' Core_RestAPI_ProductDetailV1_Handler getProducts Entered  \n ');
        try{
                  
            boolean isRequestValid = doValidations();
            //Process the api request
          if(isRequestValid == true){
                processRequest(); 
          }
          //  else
              //  Core_RestAPI_Util.processException(null ,MALFORMED_INPUT_9011, response, apiName, entryTime);   
            
        }catch(Exception e){
            System.debug(' Core_RestAPI_ProductDetailV1_Handler Exception '+e.getStackTraceString()+' message '+e.getMessage());
            String errMessage = e.getMessage();
            if(errMessage != null && errMessage.contains('invalid ID field'))
                Core_RestAPI_Util.processException(e, MALFORMED_INPUT_9011, response, apiName, entryTime);    
            else 
                Core_RestAPI_Util.processException(e, ERROR_CODE_500, response, apiName, entryTime);    
        }finally{
            System.debug('Core_RestAPI_ProductDetailV1_Handler Logging transaction and returning the response '+response);
            if(String.isBlank(response.code))
                response.code = SUCCESS_CODE_200;
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
        }       
        System.debug(' Core_RestAPI_ProductDetailV1_Handler getProducts Exiting ');
        return response;
    } 
    
    //Validate the data , Incase of error set the error code to 
    @testVisible private Boolean doValidations(){
        
        System.debug('Core_RestAPI_ProductDetailV1_Handler doValidations Invoked '+PRODUCT_ID);
        Boolean isRequestValid = true;
        if(Core_RestAPI_Util.isRequestURIValid('/v1.0/products/*') == false){
            //TODO Move to constant after the code review
            Core_RestAPI_Util.processException(null ,'404', response, apiName, entryTime);   
            isRequestValid = false;
        }else if (Core_RestAPI_Util.isProductIdValid(PRODUCT_ID)){
            Core_RestAPI_Util.processException(null ,MALFORMED_INPUT_9011, response, apiName, entryTime);
            isRequestValid = false;
        }
        system.debug('inside doValidations ==>> '+isRequestValid );        
        return isRequestValid;
    }
    
    //Execute the SOQL and populate the result to wrapper list objects 
    //Executing SOQL to get all the products for the logged in user and which is not a public product
    public void processRequest()
    { 
        System.debug(' Core_RestAPI_ProductDetailV1_Handler processRequest Entering SOQL  \n '+GET_PRODUCTS_SOQL);
        List<Asset> lstAsset= new List<Asset>();
        lstAsset= Database.Query(GET_PRODUCTS_SOQL);
        if(lstAsset!=null && !lstAsset.isEmpty()){
            for(Asset objAsset : lstAsset){  
                ProductWrapper objProductWrapper = new ProductWrapper();
                objProductWrapper.intelProductId= objAsset.id;
                objProductWrapper.ipsProjectName = objAsset.Core_IPS_Project_Name__c;
                objProductWrapper.ipsProjectId = objAsset.Core_IPS_Project__r.Core_IPS_Project_ID__c;
                objProductWrapper.productFocusArea =objAsset.core_Product_Application__c;
                objProductWrapper.intelProductName = objAsset.Core_Supported_Product__r.Core_Supported_Product_Name__c;
                response.successContent.add(objProductWrapper);
            } 
        }
        else{
            Core_RestAPI_Util.processException(null, MALFORMED_INPUT_9011 , response, apiName, entryTime); 
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