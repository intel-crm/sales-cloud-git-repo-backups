/*************************************************************************************************************************************
Apex Class Name     : PCC_CreateL4L5ProductsDetails_V1
Version             : 
Created Date        : June 2023

Modification Log    :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Utkarsh                June- 2023              Added a createDDRProductRecords method to create Design Registration Product Records through payload 
* Shivini                30-sep-2024             Added WITH USER_MODE to SOQL and DML statements.
************************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/design-registration/product/*')
global with sharing class PCC_CreateL4L5ProductsDetails_V1 {
    public static final String LOG_ENTRY_ORIGIN   = 'PCC_CreateL4L5ProductsDetails_V1';
    public static final String LOG_ENTRY_PROJECT  = 'L4 L5 Projects';
    public static final String LOG_ENTRY_SCOPE    = 'Get Product Records';
    public static final String LOG_ENTRY_SCOPE_1  = 'Get Product Records';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static final String LOG_ENTRY_INFO     = 'info'; 
    
    @HttpGet
    global static void getProductRecord(){
        RestRequest req = RestContext.request;
        //RestResponse res = RestContext.response;
        Boolean isSuccess = false;
        Boolean isError = false;
        
        String mmid = req.params.get('mmid');
        String orderingCode = req.params.get('orderingcd');
        //String oldMMID = req.params.get('oldmmid');/*TWC727-2709 - PCC: Remove all references from old MMID*/
        //List<Product_MM_Attribute_Mapping__c> l4l5Mapping = new List<Product_MM_Attribute_Mapping__c>();
        Product_MM_Attribute_Mapping__c l4l5Mapping = new Product_MM_Attribute_Mapping__c();
        PCC_Wrapper.PCC_restAPIl4l5DetailsWrapper respWrp = new PCC_Wrapper.PCC_restAPIl4l5DetailsWrapper();
        PCC_Wrapper.PCC_MasterData_ErrorWrapper errWrp = new PCC_Wrapper.PCC_MasterData_ErrorWrapper();
        
        try {
            Integer paramSize  = RestContext.request.params.keySet().size();
            
            if(paramSize == 1) {
                if(mmid != null || orderingCode != null){// || oldMMID!= null) {/*TWC727-2709 - PCC: Remove all references from old MMID*/
                    try {
                        l4l5Mapping=getL4L5Mapping(mmid,orderingCode);//,oldMMID);/*TWC727-2709 - PCC: Remove all references from old MMID*/
                        system.debug('l4l5Mapping--->'+l4l5Mapping);
                        
                        PCC_Wrapper.PCC_l4l5DetailsWrapper ddrWrp = PCC_CreateDRProductUtilityHandler_V1.setl4l5Wrapper(l4l5Mapping);
                        isSuccess =  true;
                        respWrp = PCC_CreateDRProductUtilityHandler_V1.setResponseBodyForl4l5Product(200, 'SUCCESS', null, ddrWrp, null);
                         }
                    catch(QueryException e) {
                         String identifier = mmid != null ? 'MMID: ' + mmid :
                                                orderingCode != null ? 'orderingcode: ' + orderingCode : 'unknown identifier';
                                                //oldMMID != null ? 'oldMMID: ' + oldMMID : 'unknown identifier';/*TWC727-2709 - PCC: Remove all references from old MMID*/
                            errWrp.ResponseBody = 'No Product tagged with provided ' + identifier;
                            errWrp.ErrorCode = 9011;
                            isError = true;
                    }
                }
            }
            else if(paramSize == 0) {
                RestContext.response.addHeader('Content-Type', 'application/json');      
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(PCC_CreateDDRUtilityHandler.setResponseBody(400, 'FAILURE', 400, 'Please provide MMID or ordering code to get L4 &L5 product details ', null))); 
            }
            if(isSuccess) {
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(respWrp));      
                RestContext.response.statusCode = 200;
            }
            else if(isError) {
                errWrp.StatusCode = 400;
                errWrp.Status = 'FAILURE';
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errWrp));      
                RestContext.response.statusCode = 400;
            }
            
        }
        catch(Exception ex) {
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateL4L5ProductsDetails_V1.getProductRecord' ,'' ,ex); 
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(PCC_CreateDDRUtilityHandler.setResponseBody(500, 'FAILURE', 500, 'An internal server error has occurred', null))); 
            RestContext.response.statusCode = 500;
        }
    }

    global static Product_MM_Attribute_Mapping__c getL4L5Mapping(String mmid,String orderingCode){//String oldMMID) {/*TWC727-2709 - PCC: Remove all references from old MMID*/
        Product_MM_Attribute_Mapping__c l4l5Mapping = new Product_MM_Attribute_Mapping__c();
    if(mmid != null) {
        l4l5Mapping = [SELECT id,Ordering_Code__c, Name,L4_Product__r.Name,L5_Product__r.Name From Product_MM_Attribute_Mapping__c where Name =:mmid WITH USER_MODE];
        }
        else if(orderingCode != null) {
        l4l5Mapping = [SELECT id,Ordering_Code__c, Name,L4_Product__r.Name,L5_Product__r.Name From Product_MM_Attribute_Mapping__c where Ordering_Code__c =:orderingCode WITH USER_MODE];
        }/*TWC727-2709 - PCC: Remove all references from old MMID*/
        /*else if(oldMMID != null) {
        l4l5Mapping = [SELECT id,Ordering_Code__c,MMID__c, Name,L4_Product__r.Name,L5_Product__r.Name From Product_MM_Attribute_Mapping__c where MMID__c =:oldMMID WITH USER_MODE];
        }*/
        return l4l5Mapping;
    }
}