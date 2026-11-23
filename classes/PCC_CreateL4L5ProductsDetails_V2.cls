/*************************************************************************************************************************************
Apex Class Name     : PCC_CreateL4L5ProductsDetails_V2
Version             : 
Created Date        : June 2024

Modification Log    :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Utkarsh                June- 2024             Added a createDDRProductRecords method to create Design Registration Product Records through payload 
************************************************************************************************************************************************/
@RestResource(urlMapping='/v2.0/design-registration/product/*')
global with sharing class PCC_CreateL4L5ProductsDetails_V2 {
    public static final String LOG_ENTRY_ORIGIN   = 'PCC_CreateL4L5ProductsDetails_V2';
    public static final String LOG_ENTRY_PROJECT  = 'L4 L5 Projects';
    public static final String LOG_ENTRY_SCOPE    = 'Get Product Records';
    public static final String LOG_ENTRY_SCOPE_1  = 'Get Product Records';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static final String LOG_ENTRY_INFO     = 'info'; 
    
    @HttpGet
    global static void getProductRecord(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Boolean isSuccess = false;
        Boolean isError = false;
        
        String mmid = req.params.get('mmid');
        String orderingCode = req.params.get('orderingcd');
        //String oldMMID = req.params.get('oldmmid');
        //List<Product_MM_Attribute_Mapping__c> l4l5Mapping = new List<Product_MM_Attribute_Mapping__c>();
        Product_MM_Attribute_Mapping__c l4l5Mapping = new Product_MM_Attribute_Mapping__c();
        PCC_Wrapper.PCC_restAPIl4l5DetailsWrapper respWrp = new PCC_Wrapper.PCC_restAPIl4l5DetailsWrapper();
        PCC_Wrapper.PCC_MasterData_ErrorWrapper errWrp = new PCC_Wrapper.PCC_MasterData_ErrorWrapper();
        
        try{
            Integer paramSize  = RestContext.request.params.keySet().size();
            system.debug('paramSize-->'+paramSize);
            system.debug('mmid-->'+mmid);
            system.debug('orderingCode-->'+orderingCode);
            //system.debug('oldMMID-->'+oldMMID);
            
            if(paramSize == 1){
                if(mmid == null && orderingCode == null){
                	isError = true;
                    errWrp.ResponseBody=PCC_Constants.MMID_ORDCODE;
                }
                if(mmid != null || orderingCode != null){//} || oldMMID!= null){
                    try{
                        if(mmid != null){
                        l4l5Mapping = [SELECT id,Ordering_Code__c,MMID__c, Name,L4_Product__r.Name,L5_Product__r.Name From Product_MM_Attribute_Mapping__c where Name =:mmid];
                        }
                        else if(orderingCode != null){
                        l4l5Mapping = [SELECT id,Ordering_Code__c,MMID__c, Name,L4_Product__r.Name,L5_Product__r.Name From Product_MM_Attribute_Mapping__c where Ordering_Code__c =:orderingCode];
                        }
                        //else if(oldMMID != null){
                        //l4l5Mapping = [SELECT id,Ordering_Code__c,MMID__c, Name,L4_Product__r.Name,L5_Product__r.Name From Product_MM_Attribute_Mapping__c where MMID__c =:oldMMID];
                        //}
                        
                        system.debug('mmid --> ' + mmid  + ' ordering code --> ' + orderingCode);// +   'old MMID --> ' + oldMMID);
                        system.debug('l4l5Mapping-->'+l4l5Mapping);
                        PCC_Wrapper.PCC_l4l5DetailsWrapper ddrWrp = PCC_CreateDRProductUtilityHandler_V2.setl4l5Wrapper(l4l5Mapping);
                        system.debug('ddrWrp-->'+ddrWrp);
                        isSuccess =  true;
                        respWrp = PCC_CreateDRProductUtilityHandler_V2.setResponseBodyForl4l5Product(200, 'SUCCESS', null, ddrWrp, null);
                        system.debug('respWrp-->'+respWrp);
                    }
                    catch(QueryException e){
                        if(mmid != null){
                                errWrp.ResponseBody = 'No Product tagged with provided MMID: '+ mmid;
                                errWrp.ErrorCode = 9011;
                                isError = true;
                        }
                        else if(orderingCode != null){
                                errWrp.ResponseBody = 'No Product tagged with provided orderingcode: '+ orderingCode;
                                errWrp.ErrorCode = 9011;
                                isError = true;
                        }
                        /*else if(oldMMID != null){
                                errWrp.ResponseBody = 'No Product tagged with provided oldMMID: '+ oldMMID;
                                errWrp.ErrorCode = 9011;
                                isError = true;
                        }*/
                    }
                }
            }
            else if(paramSize == 0){
                RestContext.response.addHeader('Content-Type', 'application/json');      
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(PCC_CreateDDRUtilityHandler_V2.setResponseBody(400, 'FAILURE', 400, PCC_Constants.MMID_ORDCODE, null))); 
            }
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
            
        }
        catch(Exception ex){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateL4L5ProductsDetails_V2.getProductRecord' ,'' ,ex); 
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(PCC_CreateDDRUtilityHandler_V2.setResponseBody(500, 'FAILURE', 500, 'An internal server error has occurred', null))); 
            RestContext.response.statusCode = 500;
        }
    }
}