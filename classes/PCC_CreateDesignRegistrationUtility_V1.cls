/*************************************************************************************************************************************
Apex Class Name     : PCC_CreateDesignRegistrationUtility_V1
Version             : 
Created Date        : May 2023

Modification Log    :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Shraddha                May- 2023        Added a methods (getDDRPicklistValues) to fetch API values of given picklists
* Sushmita				  May- 2023		   Added a method (createDDRRecords) to create DDR Records from payload and send response accordingly.
************************************************************************************************************************************************/

global class PCC_CreateDesignRegistrationUtility_V1 {
    public static final String LOG_ENTRY_ORIGIN   = 'PCC_CreateDesignRegistration';
    public static final String LOG_ENTRY_PROJECT  = 'DDR Registration';
    public static final String LOG_ENTRY_SCOPE    = 'Create DDR Records';
    public static final String LOG_ENTRY_SCOPE_1  = 'Fetch DDR Picklist Values';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static final String LOG_ENTRY_INFO     = 'info';
    
    /*****************************************************************************************************************
* Method Name:getDDRPicklistValues
* Date: 14/05/2023    
* Owner: Shraddha
* Description: return picklist values to external system based on parameter
******************************************************************************************************************/
    
    public static void getDDRPicklistValues(){
        
        Map<String, String> mapOfRfrToAPINamePicklist = new Map<String, String>();
        PCC_Wrapper.PCC_MasterData_SuccessWrapper successWrp = new PCC_Wrapper.PCC_MasterData_SuccessWrapper();
        PCC_Wrapper.PCC_MasterData_ErrorWrapper errWrp = new PCC_Wrapper.PCC_MasterData_ErrorWrapper();
        
        Boolean isSuccess = false, isError = false;
        
        try{
            String objectName = 'Core_Design_Registration__c';
            String tempName = RestContext.request.params.get('name');
            String tempCV = RestContext.request.params.get('parent');
            String name = (tempName != null) ? EncodingUtil.urlDecode(tempName, 'UTF-8') : null;
            String controllingValue = (tempCV != null) ? EncodingUtil.urlDecode(tempCV, 'UTF-8') : null;
            
            Integer paramSize = RestContext.request.params.size();
            String fieldName = (name != null) ? name.toUpperCase() : null;
            
            System.debug('fieldName-->'+fieldName);
            if((paramSize == 1 && RestContext.request.params.containsKey('name'))
               || (paramSize == 2 && RestContext.request.params.containsKey('name') && RestContext.request.params.containsKey('parent'))
              ){
                  if(fieldName == 'ALL' && controllingValue == null){
                      for(PCC_DDR_Integration_MasterData__mdt DIM : PCC_DDR_Integration_MasterData__mdt.getAll().values()){
                          mapOfRfrToAPINamePicklist.put(DIM.PCC_Picklist_API_Name__c, DIM.Label);
                      }
                      Map<String, List<PCC_Wrapper.PCC_PicklistWrapper>> picklistValuesMap = PCC_CreateDDRUtilityHandler.getPicklistValuesMap(objectName, mapOfRfrToAPINamePicklist);
                      successWrp.ResponseBody = picklistValuesMap;
                      isSuccess = true;
                      
                  }else if(fieldName != null && String.isNotBlank(fieldName)){       
                      if(PCC_DDR_Integration_MasterData__mdt.getAll().containsKey(fieldName)){ 
                          String picklistValue = PCC_DDR_Integration_MasterData__mdt.getAll().get(fieldName).PCC_Picklist_API_Name__c ;
                          String picklistLabel = PCC_DDR_Integration_MasterData__mdt.getAll().get(fieldName).Label;
                          if(controllingValue!=null){
                              Schema.sObjectField controllingField = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().get(picklistValue).getDescribe().getController();
                              
                              if (controllingField != null){
                                  if(String.isNotBlank(String.valueOf(controllingValue))){
                                      Boolean dependenciesCheck = getDependencies(controllingField, controllingValue);
                                      if(dependenciesCheck){
                                          Map<String, List<PCC_Wrapper.PCC_PicklistWrapper>> mapOfDependentFields = PCC_CreateDDRUtilityHandler.getDependentFields(objectName, picklistValue ,controllingValue, controllingField);
                                          successWrp.ResponseBody = mapOfDependentFields;
                                          isSuccess = true;
                                      }else{
                                          errWrp.ResponseBody = 'Invalid value for parent parameter';
                                          errWrp.ErrorCode = 9011;
                                          isError = true;
                                      }
                                  }else{
                                      errWrp.ResponseBody = 'Invalid URL. Please provide parent value';
                                      errWrp.ErrorCode = 9002;
                                      isError = true; 
                                  }   
                              }else{
                                  errWrp.ResponseBody = 'Could not find this child picklist for the provided parent value';
                                  errWrp.ErrorCode = 9011;
                                  isError = true;
                              }
                          }else{
                              Map<String, List<PCC_Wrapper.PCC_PicklistWrapper>> picklistValuesMap = PCC_CreateDDRUtilityHandler.getPicklistValuesMap(objectName, new map<String,String>{picklistValue => picklistLabel});
                              successWrp.ResponseBody = picklistValuesMap;
                              isSuccess = true;
                          }  
                      }else{
                          errWrp.ResponseBody = 'Invalid value for picklist name parameter';
                          errWrp.ErrorCode = 9011;
                          isError = true;
                      }
                  }else{
                      errWrp.ResponseBody = 'Invalid URL. Please provide picklist name';
                      errWrp.ErrorCode = 9002;
                      isError = true;
                  }
              }else if(paramSize == 0){
                  RestContext.response.addHeader('Content-Type', 'application/json');      
                  RestContext.response.statusCode = 404;
                  RestContext.response.responseBody = Blob.valueOf(JSON.serialize(PCC_CreateDDRUtilityHandler.setResponseBody(404, 'FAILURE', 404, 'Invalid URL. Please provide mandatory parameters', null))); 
              }else{
                  errWrp.ResponseBody = 'Invalid Request Parameter';
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
    
    
    /*****************************************************************************************************************
* Method Name:getDependencies
* Date: 14/05/2023    
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
        }catch (Exception ex){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateDesignRegistrationUtility_V1' ,'' ,ex); 
        }
        return isDependent;
    }
    
    
    /*****************************************************************************************************************
* Method Name:createDDRRecords
* Date: 04/06/2023    
* Owner: Sushmita
* Description: Create new design registration/ design registration product records based on the request sent.
******************************************************************************************************************/
    public static RestResponse createDDRRecords(String performOperation){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonBody = req.requestBody.toString();
        DateTime reqTime = System.now();
        String respBody;
        
        Id cpId = [SELECT Id FROM ChannelProgram WHERE Name = :System.label.PCC_Channel_Program_Name LIMIT 1].Id;     
        
        try {
            //read design registration product payload and store values in drList
            List<Object> listOfPayloads =  (List<Object>) JSON.deserializeUntyped(jsonBody);
            System.debug('listOfPayloads'+listOfPayloads);
            //Checking the limit size for record processing.
            if(Boolean.valueOf(System.Label.PCC_Enabled_Payload_Limit_Restriction) && listOfPayloads.size() > Integer.valueOf(System.Label.PCC_Max_Record_Limit)){
                PCC_Wrapper.SalesforceResponseWrapper responseWrapper = PCC_CreateDDRUtilityHandler.setResponseBody(429, 'FAILURE', 9012, 'Our system can process a maximum of '+System.Label.PCC_Max_Record_Limit+' records at a time. Currently the number of requested records is '+listOfPayloads.size()+'. To ensure successful processing, we kindly request you to reduce the number of records and try again.', '');
                res.statusCode = 429; 
                res.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
            }else{
                if(performOperation == 'Insert Design Registration'){
                    res = (!listOfPayloads.isEmpty()) ? PCC_CreateDDRUtilityHandler.createDesignRegistrationRec(listOfPayloads) : null;
                }
                else if(performOperation == 'Design Registration Product'){
                    //create DDR product records if payloads are below limit size
                    res = (!listOfPayloads.isEmpty()) ? PCC_CreateDRProductUtilityHandler_V1.createDDRProducts(listOfPayloads) : null; 
                }
                else if(performOperation == 'Update Design Registration'){
                    res = (!listOfPayloads.isEmpty()) ? PCC_CreateDDRUtilityHandler.updateDesignRegistrationRecords(listOfPayloads) : null;
                }
            } 
        } catch (Exception ex) {
            res.statusCode = 500;
            PCC_Wrapper.SalesforceResponseWrapper responseWrapper = PCC_CreateDDRUtilityHandler.setResponseBody(500, 'FAILURE', 500, 'An internal server error has occurred.', '');
            res.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY, '', '', '', 'PCC_CreateDesignRegistrationUtility_V1', '', ex);
        }
         finally{
            System.debug('res.responseBody'+res.responseBody);
            //create integration log records to store payload and response
            
             PRM_IPA_Utility.createPCCIntegrationLogWrapper obj=new PRM_IPA_Utility.createPCCIntegrationLogWrapper();
            obj.recordId='';
            obj.callType=PCC_Constants.CALLOUT_TYPE_INBOUND;
            obj.module=PCC_Constants.MODULE_DDR_REGISTRATION;
            obj.reqPayload=jsonBody; 
            obj.respPayload=jsonBody;
            obj.respCode=res.statusCode;
            obj.systemName=PCC_Constants.SYSTEM_NAME_M2M;
            obj.className='PCC_CreateDesignRegistrationUtility_V1';
            obj.reqTime=reqTime;
            obj.resTime=System.now();
            obj.insertRecord=true;
            obj.program=cpId;
            obj.reqUrl='';
            PRM_IPA_Utility.createPCCIntegrationLog(obj);//Athr fixes
            //PRM_IPA_Utility.createPCCIntegrationLog('',PCC_Constants.CALLOUT_TYPE_INBOUND,PCC_Constants.MODULE_DDR_REGISTRATION,jsonBody,jsonBody ,res.statusCode,PCC_Constants.SYSTEM_NAME_M2M,'PCC_CreateDesignRegistrationUtility_V1',reqTime,System.now(), true, cpId,'');
        }
        res.addHeader('Content-Type', 'application/json');
        return res;
    }  
    
    /*****************************************************************************************************************
* Method Name:getDDRRecordDetails
* Date: 23/06/2023    
* Owner: Shraddha
* Description: return design registration record to external system based on the record Id or external Id
******************************************************************************************************************/
    public static void getDDRRecordDetails(){
        Boolean isSuccess = false;
        Boolean isError = false;
        PCC_Wrapper.restAPIDDRDetailsWrapper respWrp = new PCC_Wrapper.restAPIDDRDetailsWrapper();
        PCC_Wrapper.PCC_MasterData_ErrorWrapper errWrp = new PCC_Wrapper.PCC_MasterData_ErrorWrapper();
        PCC_Wrapper.PCC_DesignRegDetailsWrapper ddrWrp = new PCC_Wrapper.PCC_DesignRegDetailsWrapper();
        
        try{
            Integer paramSize  = RestContext.request.params.keySet().size();
            
            if(paramSize == 1 && RestContext.request.params.containsKey('id')){
                String uniqueId = RestContext.request.params.get('id');
                // Decode the parameter using UTF-8 decoding
                String decodedId = EncodingUtil.urlDecode(uniqueId, 'UTF-8');
                if(decodedId != null && String.isNotBlank(decodedId)){
                    try {
                        Core_Design_Registration__c ddrRec =  [Select Id, Name, Core_Product_Application_Nm__c, Core_Product_Group_Nm__c, 
                                                               Core_Product_Segment_Nm__c, Core_Vertical_Market_Nm__c, Core_Military_Aerospace_Gvrnmt_Use_Ind__c, 
                                                               Core_External_Id__c, Core_Partner_FAE_Nm__c, Core_End_Customer_Nm__c, Core_End_Customer_Street_Addr_Line1_Txt__c, 
                                                               Core_End_Customer_Postal_Cd__c, Core_End_Customer_Country_Nm__c, Core_Intel_Platform_Nm__c,
                                                               Core_Opportunity_Volume_Cnt__c,Core_Opportunity_Decision_Dt__c, Core_First_Customer_Ship_Dt__c, 
                                                               Core_Production_End_Dt__c,Core_Design_Registration_Dsc__c,Core_Partner_FSR_Nm__c,
                                                               Core_End_Customer_Street_Addr_Line2_Txt__c,Core_End_Customer_City_Nm__c,
                                                               Core_End_Customer_Country_Subdivision_Nm__c,Core_End_Customer_Contact_Title_Txt__c,Core_End_Customer_Contact_Nm__c,
                                                               Core_End_Customer_Contact_Email_Txt__c,Core_End_Customer_Contact_Phone_Txt__c,Core_Manufacturing_Region_Cd__c,Core_Design_Registration_Nm__c 
                                                               from Core_Design_Registration__c
                                                               WHERE (id =: decodedId OR Core_External_Id__c =: decodedId) limit 1];      
                        
                        if(ddrRec != null){
                            ddrWrp = PCC_CreateDDRUtilityHandler.setDDRWrapper(ddrRec);
                        }
                        isSuccess =  true;
                        respWrp = PCC_CreateDDRUtilityHandler.setDesignRegResponseBody(200, 'SUCCESS', null, ddrWrp, ddrRec.Id);
                        
                    } catch (QueryException e) {
                        errWrp.ResponseBody = 'No Design Registration record found with ID: '+ decodedId;
                        errWrp.ErrorCode = 9011;
                        isError = true;
                    }
                }else{
                    errWrp.ResponseBody = 'Please provide an Id to get Design Registration Details';
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
   
    
}