/*************************************************************************************************************************************
Apex Class Name     : PCC_CreateDRProductUtility_V2
Version             : 
Created Date        : June 2024

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Shraddha                June- 2024
***************************************************************************************************************************************/
Global with sharing class PCC_CreateDRProductUtility_V2 {
    public static final String LOG_ENTRY_ORIGIN   = 'PCC_CreateDesignRegistration';
    public static final String LOG_ENTRY_PROJECT  = 'DDR Registration';
    public static final String LOG_ENTRY_SCOPE    = 'Create DDR Records';
    public static final String LOG_ENTRY_SCOPE_1  = 'Fetch DDR Picklist Values';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static final String LOG_ENTRY_INFO     = 'info'; 
    public static final List<Id> cpList = new List<Id>{Label.PCC_ChannelProgramId};
    
/*****************************************************************************************************************
* Method Name:createDRProductRecord
* Date: 04/06/2024   
* Owner: Shraddha
* Description: return design registration product records based on the Id
******************************************************************************************************************/
    public static void getDRProductRecordDetails(){
        Boolean isSuccess = false;
        Boolean isError = false;
        PCC_Wrapper.PCC_restAPIDDRDetailsWrapper respWrp = new PCC_Wrapper.PCC_restAPIDDRDetailsWrapper();
        PCC_Wrapper.PCC_MasterData_ErrorWrapper errWrp = new PCC_Wrapper.PCC_MasterData_ErrorWrapper();
		String requestedUrl = 'RequestedURI: '+RestContext.request.requestURI+' Params: '+RestContext.request.params;    
        DateTime reqTime = System.now();
        String respBody;
        
        try{
            Integer paramSize  = RestContext.request.params.keySet().size();
            
            if(paramSize == 1 && RestContext.request.params.containsKey('id')){
                String uniqueId = RestContext.request.params.get('id');
                // Decode the parameter using UTF-8 decoding
				String decodedId = EncodingUtil.urlDecode(uniqueId, 'UTF-8');
                if(decodedId != null && String.isNotBlank(decodedId)){
                    try {
                        respWrp = getDrProd(decodedId);
                        isSuccess =  true;   
                    } catch (QueryException e) {
                        errWrp.ResponseBody =LabelConfiguration__mdt.getInstance('PCC_NoDRPFound_GetDRP').Value__c+ decodedId;
                        errWrp.ErrorCode = 9011;
                        isError = true;
                    }
                }else{
                    errWrp.ResponseBody = LabelConfiguration__mdt.getInstance('PCC_NoDRPId_GetDRP').Value__c;
                    errWrp.ErrorCode = 9002;
                    isError = true;
                }
            }else if(paramSize == 0){
                RestContext.response = PCC_CreateDesignRegistrationUtility_V2.getDDRwithNoParam();
            }else{
                errWrp.ResponseBody = LabelConfiguration__mdt.getInstance('PCC_InvalidParamId_GetDDR').Value__c;
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
                RestContext.response = PCC_CreateDesignRegistrationUtility_V2.getErrorResponse(errWrp);
            }
            
        }catch (Exception ex){
            RestContext.response = PCC_CreateDesignRegistrationUtility_V2.getErrorForCatch(ex);
        }finally{
            respBody = RestContext.response.responseBody.toString();
            if (respBody.length() > PCC_Constants.MAX_CHARACTER_TO_STORE) { respBody = respBody.substring(0, PCC_Constants.MAX_CHARACTER_TO_STORE);
            }
            PRM_IPA_Utility.createPCCIntegrationLog('',PCC_Constants.CALLOUT_TYPE_INBOUND,PCC_Constants.MODULE_DDR_REGISTRATION,'',respBody ,
                                                    RestContext.response.statusCode,PCC_Constants.SYSTEM_NAME_M2M,'PCC_CreateDRProductUtility_V2.getDRProductRecordDetails',
                                                    reqTime,System.now(), true, cpList[0],requestedUrl);
        }  
    } 

/*****************************************************************************************************************
* Method Name: getDrProd
* Date: 04/06/2024   
* Owner: Sushmita
* Description: returns payload response
******************************************************************************************************************/
    public static PCC_Wrapper.PCC_restAPIDDRDetailsWrapper getDrProd(String decodedId){
        PCC_Wrapper.PCC_restAPIDDRDetailsWrapper respWrp = new PCC_Wrapper.PCC_restAPIDDRDetailsWrapper();
        Core_Design_Registration_Product__c drProduct =  [SELECT Id,Name,Core_Design_Registration_Id__c, Core_Product_Id__c, Core_Full_Year_Qty__c,
                                                                          Core_Retired_As_Of_Dt__c, Core_External_Id__c, Core_Target_Resale_Amt__c,
                                                                          DDR_Target_Resale_Price_Note__c, Core_Design_Product_Status_Nm__c,
                                                                          Core_Comment_Txt__c, Core_Partner_Tracking_Cd__c,Core_Product_List_Price_Amt__c,	
                                                                          Core_Full_Year_Value_Amt__c, Core_Opportunity_Product_Id__c,
                                                                          (SELECT Id, PCC_MM_ID__c, PCC_Ordering_Cd__c, PCC_L4_Product_Name__c, PCC_L5_Product_Name__c
                                                                          FROM DDR_Product_Mappings__r LIMIT 1)
                                                                          FROM Core_Design_Registration_Product__c
                                                                          WHERE Id = :decodedId
                                                                          LIMIT 1]; 
        PCC_Wrapper.PCC_DDRDetailsWrapper ddrWrp = PCC_CreateDRProductUtilityHandler_V2.setDDRProductWrapper(drProduct);
        respWrp = PCC_CreateDRProductUtilityHandler_V2.setResponseBody(200, 'SUCCESS', null, ddrWrp, drProduct.Id,drProduct.Name);

        return respWrp;
    }
}