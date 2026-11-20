/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_ProductCategoryV1_Handler
* Version     : 1.0 
* Created Date: 11/20/2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps      11/17/2017                 Handler class to process request and response for the product categories
*****************************************************************************************************************************************/
public  class Core_RestAPI_ProductCategoryV1_Handler{
    
    private String ERROR_CODE_500 = '500';
    private String SUCCESS_CODE_200 = '200';
    private String MALFORMED_INPUT_9011 = '9011';
    private DateTime entryTime = null;
    private String apiName;    
    public Core_RestAPI_Response response = new Core_RestAPI_Response();
    public static final String conditionToFilter = Core_RestAPI_Util.getConditionWithURIParam('Id',3);
    private static final String PRODUCT_ID = Core_RestAPI_Util.getInputFromURIParam(3);
    private String SUPPORTED_PRODUCT_NAME;
    private String ProductCategoryV1_URI ='/v1.0/products/*/categories';
    private String INVALID_URI_404= '404';
    
    
    
    private static final String GET_SUPPORTED_PRODUCT_ID = 'SELECT Core_Supported_Product__r.Name FROM Asset WHERE '+ conditionToFilter;
    private static final String GET_PRODUCTS_CATEGORIES_SOQL = 'SELECT Core_Issue_Category_Name__r.Name, Name,'+
        '(SELECT  Name, Core_Issue_Sub_Category_Name__r.Name FROM Product_Issue_Sub_Categories__r WHERE Core_Status__c = \'Active\')'+ 
        ' FROM Core_IPS_Product_Issue_Category__c WHERE Core_Supported_Product__r.Name =: SUPPORTED_PRODUCT_NAME '+
        ' AND Core_Status__c = \'Active\' LIMIT '+ LABEL.Core_RestAPI_ProductCategoriesV1_Records_Limit;
    
    
    public Core_RestAPI_ProductCategoryV1_Handler(DateTime currTime, String APIname){
        this.entryTime = currTime;
        this.apiName= APIname;
        response.successContent = new List<ProductCategoriesWrapper>();
    }
    
    //Retrieve Product's categories and Sub Categories for the logged in User
    public Core_RestAPI_Response getCategoriesandSubCategories(){
        
        try{
            //Validations if need to be handled in util class      
            boolean isRequestValid = doValidations();
            //Process the api request
            if(isRequestValid == true){
                processRequest(); 
            }   
            
        }catch(Exception e){
            Core_RestAPI_Util.processException( e, ERROR_CODE_500, response, apiName, entryTime); 
            
        }finally{ 
            if(String.isBlank(response.code))
                response.code = SUCCESS_CODE_200;
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
        }     
        return response;
    } 
    
    //Validate the data , Incase of error set the error code to 
    @testVisible private Boolean doValidations(){
        
        Boolean isRequestValid = true;
        if (Core_RestAPI_Util.isProductIdValid(PRODUCT_ID)){
            Core_RestAPI_Util.processException(null ,MALFORMED_INPUT_9011, response, apiName, entryTime);
            isRequestValid = false;
        }else if(Core_RestAPI_Util.isRequestURIValid(ProductCategoryV1_URI) == false){
            Core_RestAPI_Util.processException(null , INVALID_URI_404, response, apiName, entryTime);   
            isRequestValid = false;
        } 
        return isRequestValid;
    }
    //Execute the SOQL and populate the result to wrapper list objects
    public void processRequest(){
        
        Map<String, List<Core_IPS_Product_Issue_Category__c>> mProdIssueCat = new Map<String,List<Core_IPS_Product_Issue_Category__c>>();
        
        //Running the Query to get all categories and subcategories based on the product id
        List<Asset> objSupportedProductName = Database.query(GET_SUPPORTED_PRODUCT_ID);
        if(!objSupportedProductName.isEmpty()){
            SUPPORTED_PRODUCT_NAME = objSupportedProductName[0].Core_Supported_Product__r.Name; 
            List<Core_IPS_Product_Issue_Category__c > lstProdIssueCat= Database.query(GET_PRODUCTS_CATEGORIES_SOQL);
            
            if(!lstProdIssueCat.isEmpty()){
                //Mapping the single category as key with their multiple sub categories as value through the list
                for(Core_IPS_Product_Issue_Category__c objProduct: lstProdIssueCat){
                    mProdIssueCat.put(objProduct.Name,objProduct.Product_Issue_Sub_Categories__r);
                }
                if(mProdIssueCat != null){
                    for(Core_IPS_Product_Issue_Category__c objAllCat : lstProdIssueCat){
                        //Wrapper object to structure the category and sub-Category
                        ProductCategoriesWrapper objProdCat = new ProductCategoriesWrapper();
                        objProdCat.caseCategoryName= objAllCat.Core_Issue_Category_Name__r.Name;
                        objProdCat.caseCategoryId = objAllCat.Name;
                        List<CaseSubCategoryWrapper> lstSubCatWrapper= new List<CaseSubCategoryWrapper>();
                        if(mProdIssueCat.get(objAllCat.Name) != null)
                            for(Core_IPS_Product_Issue_Category__c objSubCategory : mProdIssueCat.get(objAllCat.Name)){
                                CaseSubCategoryWrapper objSubCat= new CaseSubCategoryWrapper();
                                objSubCat.subCategoryName = objSubCategory.Core_Issue_Sub_Category_Name__r.Name;
                                objSubCat.subCategoryId= objSubCategory.Name;
                                lstSubCatWrapper.add(objSubCat);
                            }
                        objProdCat.caseSubcategory = lstSubCatWrapper;
                        response.successContent.add(objProdCat); 
                    }
                }
            }
        }else{
            Core_RestAPI_Util.processException(null,MALFORMED_INPUT_9011 , response, apiName, entryTime); 
        }
    }
    
    //IMPORTANT : Wrapper class must implement the interface Core_RestAPI_SuccessContent
    // Wrapper to display the categories and sub categories 
    public class ProductCategoriesWrapper implements Core_RestAPI_SuccessContent{
        
        public String caseCategoryName{get;set;}
        public String caseCategoryId{get;set;}
        public List<caseSubCategoryWrapper> caseSubcategory {get;set;}
        
    }
    //Separate wrapper for displayng sub-Category
    public class CaseSubCategoryWrapper{
        public String subCategoryName{set;get;}
        public String subCategoryId{set;get;}
    }
    
}

//INFO : https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/errorcodes.htm