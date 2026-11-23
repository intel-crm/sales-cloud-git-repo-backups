/*************************************************************************************************************************************
Apex Class Name     : PCC_CreateDRProductUtility_V1 
Version             : 
Created Date        : June 2023

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Shraddha                June- 2023        
***************************************************************************************************************************************/
Global class PCC_CreateDRProductUtility_V1 {
    public static final String LOG_ENTRY_ORIGIN   = 'PCC_CreateDesignRegistration';
    public static final String LOG_ENTRY_PROJECT  = 'DDR Registration';
    public static final String LOG_ENTRY_SCOPE    = 'Create DDR Records';
    public static final String LOG_ENTRY_SCOPE_1  = 'Fetch DDR Picklist Values';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static final String LOG_ENTRY_INFO     = 'info'; 
    
    
/*****************************************************************************************************************
* Method Name:createDRProductRecord
* Date: 22/06/2023    
* Owner: Shraddha
* Description: return design registration product records based on the Id
******************************************************************************************************************/
    public static void getDRProductRecordDetails(){
        Boolean isSuccess = false;
        Boolean isError = false;
        restAPIDDRDetailsWrapper respWrp = new restAPIDDRDetailsWrapper();
        PCC_Wrapper.PCC_MasterData_ErrorWrapper errWrp = new PCC_Wrapper.PCC_MasterData_ErrorWrapper();
        
        try{
            Integer paramSize  = RestContext.request.params.keySet().size();
            
            if(paramSize == 1 && RestContext.request.params.containsKey('id')){
                String uniqueId = RestContext.request.params.get('id');
                // Decode the parameter using UTF-8 decoding
				String decodedId = EncodingUtil.urlDecode(uniqueId, 'UTF-8');
                if(decodedId != null && String.isNotBlank(decodedId)){
                    try {
                        Core_Design_Registration_Product__c drProduct =  [SELECT Id, Name, Core_Design_Registration_Id__c, Core_Product_Id__c,Core_Full_Year_Qty__c, Core_Retired_As_Of_Dt__c, Core_External_Id__c 
                                                                          FROM Core_Design_Registration_Product__c 
                                                                          WHERE (id =: decodedId OR Core_External_Id__c =: decodedId) limit 1];      
                        
                        PCC_DDRDetailsWrapper ddrWrp = new PCC_DDRDetailsWrapper(drProduct.Name, drProduct.Core_Design_Registration_Id__c, drProduct.Core_Product_Id__c, 
                                                                                 String.valueOf(drProduct.Core_Full_Year_Qty__c), drProduct.Core_Retired_As_Of_Dt__c, drProduct.Core_External_Id__c );
                        isSuccess =  true;
                        respWrp = setResponseBody(200, 'SUCCESS', null, ddrWrp, drProduct.Id);
                        
                    } catch (QueryException e) {
                        errWrp.ResponseBody = 'No Design Registration Product found with ID: '+ decodedId;
                        errWrp.ErrorCode = 9011;
                        isError = true;
                    }
                }else{
                    errWrp.ResponseBody = 'Please provide an Id to get Design Registration Product Details';
                    errWrp.ErrorCode = 9002;
                    isError = true;
                }
            }else if(paramSize == 0){
                RestContext.response.addHeader('Content-Type', 'application/json');      
                RestContext.response.statusCode = 404;
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(PCC_CreateDDRUtilityHandler.setResponseBody(404, 'FAILURE', 404, 'Invalid URL. Please provide mandatory parameters', null))); 
            }else{
                errWrp.ResponseBody = 'The parameter provided in the request is not valid. The expected parameter is `Id`';
                errWrp.ErrorCode = 9010;
                isError = true;
            }
            
            //send response
            if(isSuccess){
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(respWrp));      
                RestContext.response.statusCode = 200;
            }else if(isError){
                errWrp.StatusCode = 400;
                errWrp.Status = 'FAILURE';
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errWrp));      
                RestContext.response.statusCode = 400;
            }
            
        }catch (Exception ex){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateDesignRegistrationUtility_V1' ,'' ,ex); 
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(PCC_CreateDDRUtilityHandler.setResponseBody(500, 'FAILURE', 500, 'An internal server error has occurred', null))); 
            RestContext.response.statusCode = 500;
        }
        
    }
    
    //wrappers (to move in PCC_Wrapper) 
     global class PCC_DDRDetailsWrapper{
        Public String name{get;set;}
        Public String designRegId{get;set;}
        Public String productId{get;set;}
        Public String quantity{get;set;}
        Public Date retiredAsOf{get;set;}
        Public String externalId{get;set;}
        
        global PCC_DDRDetailsWrapper(String nameParam, Id designRegIdParam, Id productIdParam, String quantityParam, Date retiredAsOfParam, String externalIdParam){
            name = nameParam;
            designRegId = designRegIdParam;
            productId = productIdParam;
            quantity = quantityParam;
            retiredAsOf = retiredAsOfParam;
            externalId = externalIdParam;        
        }
    }
    
    global class restAPIDDRDetailsWrapper{
        public Integer StatusCode{get;set;}
        public String Status{get;set;}
        public Integer ErrorCode{get;set;}
        public PCC_DDRDetailsWrapper ResponseBody{get;set;}
        public String RecordId{get;set;}
    }  
    
    Public static restAPIDDRDetailsWrapper setResponseBody(Integer StCodeParam, String StatusParam, Integer ErrCodeParam, PCC_DDRDetailsWrapper ResBodyParam, String RecIdParam){
        restAPIDDRDetailsWrapper respWrp = new restAPIDDRDetailsWrapper();
        respWrp.StatusCode = StCodeParam;
        respWrp.Status = StatusParam;
        respWrp.ErrorCode = ErrCodeParam;
        respWrp.ResponseBody = ResBodyParam;
        respWrp.RecordId = RecIdParam;    
        return respWrp;
    }
    
}