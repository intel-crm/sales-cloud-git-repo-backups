/*************************************************************************************************************************************
Apex Class Name     : PCC_CreateDesignRegistrationUtility_V2
Version             : 
Created Date        : June 2024

Modification Log    :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Shraddha                June- 2024       Added a methods (getDDRPicklistValues) to fetch API values of given picklists
* Sushmita                June- 2024        Added a method (createDDRRecords) to create DDR Records from payload and send response accordingly.
* Aravind                 5-NOv-2024         Changes to move PCC_DDR_Integration_MasterData__mdt custom metadata to new framework
************************************************************************************************************************************************/

global with sharing class PCC_CreateDesignRegistrationUtility_V2 {
    public static final String LOG_ENTRY_ORIGIN   = 'PCC_CreateDesignRegistration_V2';
    public static final String LOG_ENTRY_PROJECT  = 'DDR Registration';
    public static final String LOG_ENTRY_SCOPE    = 'Create DDR Records';
    public static final String LOG_ENTRY_SCOPE_1  = 'Fetch DDR Picklist Values';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static final String LOG_ENTRY_INFO     = 'info';
	//public static final Id cpId = [SELECT id FROM ChannelProgram where Name='Partner Covers Customer (PCC)' LIMIT 1].Id;
    //public static final List<Id> cpList = new List<Id>{Label.PCC_ChannelProgramId};
    
    /*****************************************************************************************************************
* Method Name:getDDRPicklistValues
* Date: 04/06/2024    
* Owner: Shraddha
* Description: return picklist values to external system based on parameter
******************************************************************************************************************/
    
    public static void getDDRPicklistValues(){
        
        //Map<String, String> mapOfRfrToAPINamePicklist = new Map<String, String>();
        PCC_Wrapper.PCC_MasterData_SuccessWrapper successWrp = new PCC_Wrapper.PCC_MasterData_SuccessWrapper();
        PCC_Wrapper.PCC_MasterData_ErrorWrapper errWrp = new PCC_Wrapper.PCC_MasterData_ErrorWrapper();
        Boolean isSuccess = false, isError = false;
        String requestedUrl = 'RequestedURI: '+RestContext.request.requestURI+' Params: '+RestContext.request.params;
        DateTime reqTime = System.now();
        String respBody;
        String staticLabel = PCC_Constants.static_DDR_MD_Label;
		Id cpId;
        
        try{
            cpId = [SELECT Id, Name FROM ChannelProgram WHERE Name = :System.label.PCC_Channel_Program_Name LIMIT 1].Id;
        }catch(exception ex){ 
            cpId = null;
        }
        try{
            String objectName = 'Core_Design_Registration__c';
            String tempName = RestContext.request.params.get('name');
            String tempCV = RestContext.request.params.get('parent');
            String name = (tempName != null) ? EncodingUtil.urlDecode(tempName, 'UTF-8') : null;
            String controllingValue = (tempCV != null) ? EncodingUtil.urlDecode(tempCV, 'UTF-8') : null;
            
            Integer paramSize = RestContext.request.params.size();
            String fieldName = (name != null) ? name.toUpperCase() : null;

            if((paramSize == 1 && RestContext.request.params.containsKey('name'))
               || (paramSize == 2 && RestContext.request.params.containsKey('name') && RestContext.request.params.containsKey('parent'))
              ){
                  if(fieldName == 'ALL' && controllingValue == null){
                    successWrp.ResponseBody = getPicklistValMap(objectName);
                    isSuccess = true;
                      
                  }else if(fieldName != null && String.isNotBlank(fieldName)){       
                      Map<String, Map<String, Object>> integMasterDataMap = new Core_CustomMetadataObjectController('PCC_DDR_Integration_MasterData__mdt').getAll();       
                        if(integMasterDataMap.containsKey(fieldName)){
                          String picklistValue = String.valueOf(integMasterDataMap.get(fieldName).get('PCC_Picklist_API_Name__c')) ;
                          String picklistLabel = String.valueOf(integMasterDataMap.get(fieldName).get('MasterLabel'));
                          if(controllingValue!=null){
                              Schema.sObjectField controllingField = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().get(picklistValue).getDescribe().getController();
                              
                              if (controllingField != null){
                                  if(String.isNotBlank(String.valueOf(controllingValue))){
                                      Boolean dependenciesCheck = getDependencies(controllingField, controllingValue);
                                      if(dependenciesCheck){
                                          Map<String, List<PCC_Wrapper.PCC_PicklistWrapper>> mapOfDependentFields = PCC_CreateDDRUtilityHandler_V2.getDependentFields(objectName, picklistValue ,controllingValue, controllingField);
                                          successWrp.ResponseBody = mapOfDependentFields;
                                          isSuccess = true;
                                      }else{
                                          errWrp.ResponseBody = LabelConfiguration__mdt.getInstance('PCC_Invalid_Parent_Param_GetMethod').Value__c;
                                          errWrp.ErrorCode = 9011;
                                          isError = true;
                                      }
                                  }else{
                                      errWrp.ResponseBody =  LabelConfiguration__mdt.getInstance('PCC_No_Parent_Value_GetMethod').Value__c;
                                      errWrp.ErrorCode = 9002;
                                      isError = true;
                                  }   
                              }else{
                                  errWrp.ResponseBody =  LabelConfiguration__mdt.getInstance('PCC_InvalidChildValue_GetMethod').Value__c;
                                  errWrp.ErrorCode = 9011;
                                  isError = true;
                              }
                          }else{
                              Map<String, List<PCC_Wrapper.PCC_PicklistWrapper>> picklistValuesMap = PCC_CreateDDRUtilityHandler_V2.getPicklistValuesMap(objectName, new map<String,String>{picklistValue => picklistLabel});
                              Map<String, List<PCC_Wrapper.PCC_PicklistWrapper>> staticLabelPkValuesMap = new Map<String, List<PCC_Wrapper.PCC_PicklistWrapper>>{staticLabel => picklistValuesMap.get(picklistLabel)};
                              successWrp.ResponseBody = staticLabelPkValuesMap;
                              isSuccess = true;
                          }  
                      }else{
                          errWrp.ResponseBody =  LabelConfiguration__mdt.getInstance('PCC_PicklistNameParam_GetMethod').Value__c;
                          errWrp.ErrorCode = 9011;
                          isError = true;
                      }
                  }else{
                      errWrp.ResponseBody =  LabelConfiguration__mdt.getInstance('PCC_NoPicklistName_GetMethod').Value__c;
                      errWrp.ErrorCode = 9002;
                      isError = true;
                  }
              }else if(paramSize == 0){
                    RestContext.response = getDDRwithNoParam();
                  }else{
                  errWrp.ResponseBody = LabelConfiguration__mdt.getInstance('PCC_InvalidReqParam_GetMethod').Value__c;
                  errWrp.ErrorCode = 9010;
                  isError = true;
              }
            //send response
            if(isSuccess){
                successWrp.StatusCode = 200;
                successWrp.Status = 'SUCCESS';
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(successWrp));
            }else if(isError){
                errWrp.StatusCode = 400;
                errWrp.Status = 'FAILURE';
                RestContext.response = getErrorResponse(errWrp);
            } 
        }catch (Exception ex){
            RestContext.response = getErrorForCatch(ex);
        }
        finally{
            respBody = RestContext.response.responseBody.toString();
            if (respBody.length() > PCC_Constants.MAX_CHARACTER_TO_STORE) { respBody = respBody.substring(0, PCC_Constants.MAX_CHARACTER_TO_STORE);
            }
            //create integration log records to store payload and response
            PRM_IPA_Utility.createPCCIntegrationLog('',PCC_Constants.CALLOUT_TYPE_INBOUND,PCC_Constants.MODULE_DDR_REGISTRATION,'',respBody ,
                                                    RestContext.response.statusCode,PCC_Constants.SYSTEM_NAME_M2M,'PCC_CreateDesignRegistrationUtility_V2.getDDRPicklistValues',
                                                    reqTime,System.now(), true, cpId, requestedUrl);
        }        
    }   
    /*****************************************************************************************************************
* Method Name:getDependencies
* Date: 04/06/2024    
* Owner: Shraddha
* Description: check if is it valid controlling value
******************************************************************************************************************/  
    private static Boolean getDependencies(Schema.SObjectField controllingField, String controllingValue){
        Boolean isDependent = false;
        try{
            List<Schema.PicklistEntry> controllingFieldValues = controllingField.getDescribe().getPicklistValues();
            for(Schema.PicklistEntry en : controllingFieldValues){
                if(en.getValue() == controllingValue){
                    isDependent = true;
                }
            }
        }catch (Exception ex){ Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateDesignRegistrationUtility_V2.getDependencies' ,'' ,ex); 
        }
        return isDependent;
    }
 
    /*****************************************************************************************************************
* Method Name:createDDRRecords
* Date: 04/06/2024   
* Owner: Sushmita
* Description: Create new design registration/ design registration product records based on the request sent.
******************************************************************************************************************/
    public static RestResponse createDDRRecords(String performOperation){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonBody = req.requestBody.toString();
        DateTime reqTime = System.now();
        String respBody;
        String requestedUrl = 'RequestedURI: '+req.requestURI; 
        Id cpId;
        
        try{
            cpId = [SELECT Id, Name FROM ChannelProgram WHERE Name = :System.label.PCC_Channel_Program_Name LIMIT 1].Id;
        }catch(exception ex){ 
            cpId = null;
        }
        try {
            res = createDDRTryBlock(jsonBody, performOperation);
        } catch (Exception ex) {
            res = getErrorForCatch(ex);
        }
        finally{ 
            if(RestContext.response.responseBody != null){
                respBody = RestContext.response.responseBody.toString();
                if (respBody.length() > PCC_Constants.MAX_CHARACTER_TO_STORE){ respBody = respBody.substring(0, PCC_Constants.MAX_CHARACTER_TO_STORE);
                                                                              }
                //create integration log records to store payload and response
                PRM_IPA_Utility.createPCCIntegrationLog('',PCC_Constants.CALLOUT_TYPE_INBOUND,PCC_Constants.MODULE_DDR_REGISTRATION,jsonBody,respBody ,res.statusCode,PCC_Constants.SYSTEM_NAME_M2M,
                                                        'PCC_CreateDesignRegistrationUtility_V2.createDDRRecords',reqTime,System.now(), true, cpId ,requestedUrl);
            }
        }
        res.addHeader('Content-Type', 'application/json');
        return res;     
    }  
    
    /*****************************************************************************************************************
* Method Name:getDDRRecordDetails
* Date: 04/06/2024    
* Owner: Shraddha
* Description: return design registration record to external system based on the record Id 
******************************************************************************************************************/
    public static void getDDRRecordDetails(){
        Boolean isSuccess = false;
        Boolean isError = false;
        PCC_Wrapper.restAPIDDRDetailsWrapper respWrp = new PCC_Wrapper.restAPIDDRDetailsWrapper();
        PCC_Wrapper.restAPIDDRDetailsWrapper1 respWrp1 = new PCC_Wrapper.restAPIDDRDetailsWrapper1();
        PCC_Wrapper.PCC_MasterData_ErrorWrapper errWrp = new PCC_Wrapper.PCC_MasterData_ErrorWrapper();
        PCC_Wrapper.PCC_DesignRegDetailsWrapper ddrWrp = new PCC_Wrapper.PCC_DesignRegDetailsWrapper();
        PCC_Wrapper.PCC_allDdrDetailsWrapper allDdrDetails = new PCC_Wrapper.PCC_allDdrDetailsWrapper();
       // List<PCC_Wrapper.PCC_DDRDetailsWrapper> drpWrpList = new List<PCC_Wrapper.PCC_DDRDetailsWrapper>();
        String requestedUrl = 'RequestedURI: '+RestContext.request.requestURI+' Params: '+RestContext.request.params;
        DateTime reqTime = System.now();
        String respBody;
        Boolean returnOnlyDDR = false;
        Id cpId;
        
        try{
            cpId = [SELECT Id, Name FROM ChannelProgram WHERE Name = :System.label.PCC_Channel_Program_Name LIMIT 1].Id;
        }catch(exception ex){ 
            cpId = null;
        }
        try{
            Integer paramSize  = RestContext.request.params.keySet().size();
            
            if(paramSize == 1 && RestContext.request.params.containsKey('id') 
               || (paramSize == 2 && RestContext.request.params.containsKey('id') && RestContext.request.params.containsKey('type'))
              ){
                String uniqueId = RestContext.request.params.get('id');
                String reqType = RestContext.request.params.containsKey('type') ? RestContext.request.params.get('type') : null;
                // Decode the parameter using UTF-8 decoding
                String decodedId = EncodingUtil.urlDecode(uniqueId, 'UTF-8');    
                String decodedReqType = reqType!= null ? EncodingUtil.urlDecode(reqType, 'UTF-8') : null;
                
                if(decodedId != null && String.isNotBlank(decodedId)){
                    try {
                        //fetch design registration details by passing RecordID/ExternalID
                        Core_Design_Registration__c ddrRec =  [Select Id, Name, Core_Product_Application_Nm__c, Core_Product_Group_Nm__c, 
                                                               Core_Product_Segment_Nm__c, Core_Vertical_Market_Nm__c, Core_Military_Aerospace_Gvrnmt_Use_Ind__c, 
                                                               Core_External_Id__c, Core_Partner_FAE_Nm__c, Core_End_Customer_Nm__c, Core_End_Customer_Street_Addr_Line1_Txt__c, 
                                                               Core_End_Customer_Postal_Cd__c, Core_End_Customer_Country_Nm__c,PCC_End_Customer_Country__c, Core_End_Customer_URL__c, Core_Intel_Platform_Nm__c,
                                                               Core_Opportunity_Volume_Cnt__c,Core_Opportunity_Decision_Dt__c, Core_First_Customer_Ship_Dt__c, 
                                                               Core_Production_End_Dt__c,Core_Design_Registration_Dsc__c,Core_Partner_FSR_Nm__c,
                                                               Core_End_Customer_Street_Addr_Line2_Txt__c,Core_End_Customer_City_Nm__c,
                                                               Core_End_Customer_Country_Subdivision_Nm__c,Core_End_Customer_Contact_Title_Txt__c,Core_End_Customer_Contact_Nm__c,
                                                               Core_End_Customer_Contact_Email_Txt__c,Core_End_Customer_Contact_Phone_Txt__c,Core_Manufacturing_Region_Cd__c,
                                                               Core_Design_Registration_Nm__c, Core_Design_Registration_Status_Nm__c, Core_Rejection_Reason_Nm__c, 
                                                               Core_Rejection_Comment_Txt__c, Core_Opportunity_Id__c, Core_Design_Solution_Network_Ind__c,
                                                               Core_MINDS_Message_Txt__c, Core_FPGA_Quote_Comments_Txt__c, Core_Partner_Account_Nm__c, Core_End_Customer_Account_Nm__c, 
                                                               Core_Intel_Technical_Owner_Id__r.name,PCC_Intel_Technical_Owner_Name__c
                                                               from Core_Design_Registration__c
                                                               WHERE id =: decodedId limit 1];      
                        
                        //set DDRwrapper
                        if(ddrRec != null){
                            ddrWrp = PCC_CreateDDRUtilityHandler_V2.setDDRWrapper(ddrRec);
                            
                            if(decodedReqType != null && decodedReqType == 'DR'){
                                //To send the response body to an external system
                                respWrp1 = PCC_CreateDDRUtilityHandler_V2.setDesignRegResponseBody(200, 'SUCCESS', null, ddrWrp, ddrRec.Id,ddrRec.name); 
                                returnOnlyDDR = true;
                            }else{              
                                allDdrDetails = getDrpRecList(ddrRec.Id);                  
                                allDdrDetails.DesignRegistrationDetails = ddrWrp;
                                //To send the response body to an external system
                                respWrp = PCC_CreateDDRUtilityHandler_V2.setDesignRegResponseBody(200, 'SUCCESS', null, allDdrDetails, ddrRec.Id,ddrRec.name);
                            }
                        }
                        isSuccess =  true;                      
                    } catch (QueryException e) {

                        errWrp.ResponseBody = LabelConfiguration__mdt.getInstance('PCC_NoDDRFound_GetDDR').Value__c+ decodedId;
                        errWrp.ErrorCode = 9011;
                        isError = true;
                    }
                }else{
                    errWrp.ResponseBody = LabelConfiguration__mdt.getInstance('PCC_NoDDRId_GetDDR').Value__c;
                    errWrp.ErrorCode = 9002;
                    isError = true;
                }
            }else if(paramSize == 0){
                RestContext.response = getDDRwithNoParam();
            }else if(!RestContext.request.params.containsKey('id')){
                errWrp.ResponseBody = LabelConfiguration__mdt.getInstance('PCC_InvalidParamId_GetDDR').Value__c;
                errWrp.ErrorCode = 9010;
                isError = true;
            }else{
                errWrp.ResponseBody = LabelConfiguration__mdt.getInstance('PCC_InvalidParamType_GetDDR').Value__c;
                errWrp.ErrorCode = 9010;
                isError = true;
            }
            
            //send response
            if(isSuccess){
                RestContext.response = getSuccessResponse(returnOnlyDDR, respWrp1, respWrp);    
            }else if(isError){
                errWrp.StatusCode = 400;
                errWrp.Status = 'FAILURE';
                RestContext.response = getErrorResponse(errWrp);
            }
        }catch (Exception ex){
            RestContext.response = getErrorForCatch(ex);
        }finally{
            respBody = RestContext.response.responseBody.toString();
            if (respBody.length() > PCC_Constants.MAX_CHARACTER_TO_STORE) { respBody = respBody.substring(0, PCC_Constants.MAX_CHARACTER_TO_STORE);
            }
            //create integration log records to store payload and response
            PRM_IPA_Utility.createPCCIntegrationLog('',PCC_Constants.CALLOUT_TYPE_INBOUND,PCC_Constants.MODULE_DDR_REGISTRATION,'',respBody ,
                                                    RestContext.response.statusCode,PCC_Constants.SYSTEM_NAME_M2M,'PCC_CreateDesignRegistrationUtility_V2.getDDRRecordDetails',
                                                    reqTime,System.now(), true,cpId,requestedUrl);
        }
    } 

/*****************************************************************************************************************
* Method Name:createDDRTryBlock, getPayloadResponse, getErrorForCatch, getFailureResponse, getLimitationResponse
* Date: 04/06/2024    
* Owner: Sushmita
* Description: returns payload response
******************************************************************************************************************/
    public static RestResponse createDDRTryBlock(String jsonBody, String performOperation){
        
        RestResponse res = RestContext.response;
        if (jsonBody != null && jsonBody.length() > 2 && jsonBody.contains('{') && jsonBody.contains('}')) {
            List<Object> listOfPayloads =  (List<Object>) JSON.deserializeUntyped(jsonBody);
            //Checking the limit size for record processing.
            String limitExceedMsg = LabelConfiguration__mdt.getInstance('PCC_LimitExceededMsg_PostDDR').Value__c.replace('{1}',string.ValueOf(System.Label.PCC_Max_Record_Limit)).replace('{2}',string.valueOf(listOfPayloads.size()));
            if((Boolean.valueOf(System.Label.PCC_Enabled_Payload_Limit_Restriction) && listOfPayloads.size() > Integer.valueOf(System.Label.PCC_Max_Record_Limit))){
                res = getLimitationResponse(limitExceedMsg);  
            }else{
                res = getPayloadResponse(performOperation, listOfPayloads);
            } 
        }else{
            res = getFailureResponse();    
        }
        return res;
    }

    public static RestResponse getPayloadResponse(String performOperation, List<Object> listOfPayloads){

        RestResponse res = RestContext.response;
        if(performOperation == PCC_Constants.INSERT_DDR){
            res = (!listOfPayloads.isEmpty()) ? PCC_CreateDDRUtilityHandler_V2.createDesignRegistrationRec(listOfPayloads) : null;
        }
        else if(performOperation == PCC_Constants.INSERT_DRP){
            //create DDR product records if payloads are below limit size
            res = (!listOfPayloads.isEmpty()) ? PCC_CreateDRProductUtilityHandler_V2.createDDRProducts(listOfPayloads) : null; 
        }
        else if(performOperation == PCC_Constants.UPDATE_DDR){
            res = (!listOfPayloads.isEmpty()) ? PCC_CreateDDRUtilityHandler_V2.updateDesignRegistrationRecords(listOfPayloads) : null;
        }
        else if(performOperation == PCC_Constants.UPDATE_DRP){
            //update DDR product records if payloads are below limit size
            res = (!listOfPayloads.isEmpty()) ? PCC_CreateDRProductUtilityHandler_V2.updateDDRProducts(listOfPayloads) : null; 
        }
        else if(performOperation == PCC_Constants.DELETE_DDR){
             res = (!listOfPayloads.isEmpty()) ? PCC_DesignDeleteAPIUtilityHandler.deleteDRRecords(listOfPayloads) : null;
             //res = (!listOfPayloads.isEmpty()) ? PCC_CreateDDRUtilityHandler_V2.deleteDRRecords(listOfPayloads) : null;
        }
        else if(performOperation == PCC_Constants.DELETE_DRP){
             //res = (!listOfPayloads.isEmpty()) ? PCC_CreateDRProductUtilityHandler_V2.deleteDRPRecords(listOfPayloads) : null;
             res = (!listOfPayloads.isEmpty()) ? PCC_DesignDeleteAPIUtilityHandler.deleteDRPRecords(listOfPayloads) : null;
        }
        return res;
    }

    public static RestResponse getErrorForCatch(Exception ex){
        RestResponse res = RestContext.response;
        res.statusCode = 500;
        res.addHeader('Content-Type', 'application/json');
        PCC_Wrapper.SalesforceResponseWrapper responseWrapper = PCC_CreateDDRUtilityHandler_V2.setResponseBody(500, 'FAILURE', 500, LabelConfiguration__mdt.getInstance('PCC_InternalServerError_Catch').Value__c, '');
        res.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
        Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY, '', '', '', 'PCC_CreateDesignRegistrationUtility_V2.createDDRRecords', '', ex);

        return res;      
    }

    public static RestResponse getFailureResponse(){
        RestResponse res = RestContext.response;
        res.statusCode = 400;
        PCC_Wrapper.SalesforceResponseWrapper responseWrapper = PCC_CreateDDRUtilityHandler_V2.setResponseBody(400, 'FAILURE', 9013, LabelConfiguration__mdt.getInstance('PCC_InvalidEmptyRequest_PostMethod').Value__c, '');
        res.responseBody = Blob.valueOf(JSON.serialize(responseWrapper)); 

        return res;
    }

    public static RestResponse getLimitationResponse(String limitExceedMsg){
        RestResponse res = RestContext.response;
        PCC_Wrapper.SalesforceResponseWrapper responseWrapper = PCC_CreateDDRUtilityHandler_V2.setResponseBody(429, 'FAILURE', 9012, limitExceedMsg , null);
        res.statusCode = 429; 
        res.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));

        return res;
    }

    public static  PCC_Wrapper.PCC_allDdrDetailsWrapper getDrpRecList(Id drRecId){
        
        List<Core_Design_Registration_Product__c> drpRecList = new List<Core_Design_Registration_Product__c>();
        List<PCC_Wrapper.PCC_DDRDetailsWrapper> drpWrpList = new List<PCC_Wrapper.PCC_DDRDetailsWrapper>();
        PCC_Wrapper.PCC_allDdrDetailsWrapper allDdrDetails = new PCC_Wrapper.PCC_allDdrDetailsWrapper();
        drpRecList = [SELECT Id, Name, Core_Design_Registration_Id__c, Core_Product_Id__c, Core_Full_Year_Qty__c,
                        Core_Retired_As_Of_Dt__c, Core_External_Id__c, Core_Target_Resale_Amt__c,
                        DDR_Target_Resale_Price_Note__c, Core_Design_Product_Status_Nm__c,
                        Core_Comment_Txt__c, Core_Partner_Tracking_Cd__c,Core_Product_List_Price_Amt__c,    
                        Core_Full_Year_Value_Amt__c, Core_Opportunity_Product_Id__c,
                        (SELECT Id, PCC_Ordering_Cd__c, PCC_L4_Product_Name__c, PCC_L5_Product_Name__c
                        FROM DDR_Product_Mappings__r LIMIT 1)
                        FROM Core_Design_Registration_Product__c where Core_Design_Registration_Id__c =:drRecId];

        if(drpRecList!=null && !drpRecList.isEmpty()){
            drpWrpList = PCC_CreateDDRUtilityHandler_V2.setDDRProdWrapper(drpRecList);
            allDdrDetails.AssociatedDesignRegistrationProducts = drpWrpList;
        }
        return allDdrDetails;
    }

    public static RestResponse getDDRwithNoParam(){
        RestContext.response.addHeader('Content-Type', 'application/json');      
        RestContext.response.statusCode = 404;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(PCC_CreateDDRUtilityHandler_V2.setResponseBody(404, 'FAILURE', 404, LabelConfiguration__mdt.getInstance('PCC_InvalidUrl_GetDDR').Value__c, null))); 

        return RestContext.response;

        }

    public static RestResponse getSuccessResponse(Boolean returnOnlyDDR, PCC_Wrapper.restAPIDDRDetailsWrapper1 respWrp1,PCC_Wrapper.restAPIDDRDetailsWrapper respWrp){
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.statusCode = 200;
        if(returnOnlyDDR){
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(respWrp1));      
        }else{
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(respWrp));      
        }
        return RestContext.response;
    }

    public static RestResponse getErrorResponse(PCC_Wrapper.PCC_MasterData_ErrorWrapper errWrp){
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errWrp));      
        RestContext.response.statusCode = 400;
        
        return RestContext.response;
    }

    public static Map<String, List<PCC_Wrapper.PCC_PicklistWrapper>> getPicklistValMap(String objectName){

        Map<String, String> mapOfRfrToAPINamePicklist = new Map<String, String>();
        List<String> picklistValuesForVersion2 = LabelConfiguration__mdt.getInstance('PCC_GetAPIPicklistValues_V2').Value__c.split(',');
        for(Map<String,Object> DIM : new Core_CustomMetadataObjectController('PCC_DDR_Integration_MasterData__mdt').getAll().values()){
            if(picklistValuesForVersion2.contains(String.valueOf(DIM.get('DeveloperName')))){
                mapOfRfrToAPINamePicklist.put(String.valueOf(DIM.get('PCC_Picklist_API_Name__c')), String.valueOf(DIM.get('MasterLabel')));
            }
        }
        Map<String, List<PCC_Wrapper.PCC_PicklistWrapper>> picklistValuesMap = PCC_CreateDDRUtilityHandler_V2.getPicklistValuesMap(objectName, mapOfRfrToAPINamePicklist);
        return picklistValuesMap;
    }

}