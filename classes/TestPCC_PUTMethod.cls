public class TestPCC_PUTMethod {
    public static final String LOG_ENTRY_ORIGIN   = 'PCC_CreateDesignRegistration';
    public static final String LOG_ENTRY_PROJECT  = 'DDR Registration';
    public static final String LOG_ENTRY_SCOPE    = 'Create DDR Records';
    public static final String LOG_ENTRY_SCOPE_1  = 'Fetch DDR Picklist Values';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_SEVERITY = 'High';
    public static final String LOG_ENTRY_INFO     = 'info';    
    public static Map<String, String> mapExtIdtoInvalidValMsg = new Map<String, String>();  
    
    public static RestResponse updateDesignRegistrationRecords(){     
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonBody = req.requestBody.toString();
        DateTime reqTime = System.now();
        String respBody;
        Integer failedRecordCount = 0;
        Integer successfulRecordCount = 0; 
        Set<String> errorString;
        String errorMsgForLogEntry = '';  
        Id cpId = [SELECT Id FROM ChannelProgram WHERE Name = :System.label.PCC_Channel_Program_Name LIMIT 1].Id;
        try {
            //read design registration product payload and store values in wrapper
            List<PCC_Wrapper.PCC_Update_DDRRequestWrapper> updateDDRWrapList = (List<PCC_Wrapper.PCC_Update_DDRRequestWrapper>)JSON.deserialize(jsonBody, List<PCC_Wrapper.PCC_Update_DDRRequestWrapper>.class);
            System.debug('responseWrap----> '+updateDDRWrapList);
            
            //Check the limit size for record processing.
            if(Boolean.valueOf(System.Label.PCC_Enabled_Payload_Limit_Restriction) && updateDDRWrapList.size() > Integer.valueOf(System.Label.PCC_Max_Record_Limit)){
                PCC_Wrapper.SalesforceResponseWrapper responseWrapper = PCC_CreateDDRUtilityHandler.setResponseBody(429, 'FAILURE', 9012, 'Our system can process a maximum of '+System.Label.PCC_Max_Record_Limit+' records at a time. Currently the number of requested records is '+updateDDRWrapList.size()+'. To ensure successful processing, we kindly request you to reduce the number of records and try again.', '');
                res.statusCode = 429; 
                res.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
            }else{
                //update DDR records if payloads are below limit size
                res = (!updateDDRWrapList.isEmpty()) ? PCC_CreateDDRUtilityHandler.updateDDRRecs(updateDDRWrapList) : null;
            }            			                      
        } catch (Exception ex) {
            res.statusCode = 500;
            PCC_Wrapper.SalesforceResponseWrapper responseWrapper = PCC_CreateDDRUtilityHandler.setResponseBody(500, 'FAILURE', 500, 'An internal server error has occurred.', '');
            res.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY, '', '', '', 'PCC_CreateDesignRegistrationUtility_V1', '', ex);
        }
        finally{
            respBody = res.responseBody.toString();
            //Create integration log with the requested payload and response
            PRM_IPA_Utility.createPCCIntegrationLog('',PCC_Constants.CALLOUT_TYPE_INBOUND,PCC_Constants.MODULE_DDR_REGISTRATION,jsonBody,respBody ,res.statusCode,PCC_Constants.SYSTEM_NAME_M2M,'PCC_CreateDesignRegistrationUtility_V1',reqTime,System.now(), true, cpId);
        }
        res.addHeader('Content-Type', 'application/json');
        return res;
    } 
    
    public static RestResponse updateDDRRecs(List<PCC_Wrapper.PCC_Update_DDRRequestWrapper> updateDDRWrapList){
        RestResponse res = RestContext.response;
        Map<String, Core_Design_Registration__c> finalMapOfRecIdToDR = new Map<String, Core_Design_Registration__c>();
        List<Database.SaveResult> srList = new  List<Database.SaveResult>();
        Map<String,PCC_Wrapper.PCC_Update_DDRRequestWrapper> mapOfIdToWrap = new Map<String,PCC_Wrapper.PCC_Update_DDRRequestWrapper>();
        Map<Core_Design_Registration__c, Database.SaveResult> mapDrRecordSaveResult = new Map<Core_Design_Registration__c, Database.SaveResult>();  
        List<Core_Design_Registration__c>  listOfDR = new List<Core_Design_Registration__c>();  
        Map<Id,PCC_Wrapper.PCC_Update_DDRRequestWrapper> mapRecIdTODRList = new Map<Id,PCC_Wrapper.PCC_Update_DDRRequestWrapper>();
        String objectName = 'Core_Design_Registration__c';
        Map<String,String> mapOfIdToErrMsg = new Map<String,String>();
        Map<String,String> mapOfRecIdToExtId = new Map<String,String>();
        Map<String,String> mapOfExtIdToRecId = new Map<String,String>();
        List<Core_Design_Registration__c> validDRList = new List<Core_Design_Registration__c>();
        Map<Id,Core_Design_Registration__c> existingDDR = new Map<Id,Core_Design_Registration__c>();
        Map<String,List<String>> controlValueWrapMap = new Map<String,List<String>>();
        Map<String,Core_Design_Registration__c> mapRecIdToDDR = new Map<String,Core_Design_Registration__c>();
        List<String> requiredFields = Label.PCC_Create_DDR_Required_Fields.split(',');
        Map<String, String> drProductLabelToApiMap = PCC_Constants.drProductLabelToApiMap;
        Map<String, String> drProductApiToLabelMap = PCC_Constants.drProductApiToLabelMap;
        List<String> requiredFieldsApi = new List<String>();
        for(String st:requiredFields){
            requiredFieldsApi.add(drProductLabelToApiMap.get(st));
        }
        try{
            controlValueWrapMap = PCC_CreateDDRUtilityHandler.getDependentPicklistValues(objectName,'Core_Product_Application_Nm__c');
            system.debug('controlValueWrapMap'+controlValueWrapMap);
            //Iterating over the wrapper list 
            for(PCC_Wrapper.PCC_Update_DDRRequestWrapper reqWrap : updateDDRWrapList){   
                if(reqWrap.recOrExtId!=null){                    
                    mapOfIdToWrap.put(reqWrap.recOrExtId,reqWrap);
                }                  
            }
            if(!mapOfIdToWrap.isEmpty()){
                validDRList = [SELECT Id,Core_Product_Group_Nm__c,Core_Military_Aerospace_Gvrnmt_Use_Ind__c,Core_Vertical_Market_Nm__c,Core_Product_Segment_Nm__c,Core_Product_Application_Nm__c,Core_External_Id__c,Core_Partner_FAE_Nm__c, Core_Partner_FSR_Nm__c,
                               Core_End_Customer_Nm__c,Core_End_Customer_Street_Addr_Line1_Txt__c,Core_End_Customer_Street_Addr_Line2_Txt__c,Core_End_Customer_Country_Nm__c,Core_End_Customer_Country_Subdivision_Nm__c,Core_End_Customer_Postal_Cd__c,
                               Core_End_Customer_City_Nm__c,Core_End_Customer_Contact_Title_Txt__c,Core_End_Customer_Contact_Phone_Txt__c,Core_End_Customer_Contact_Nm__c,Core_End_Customer_Contact_Email_Txt__c,Core_Manufacturing_Region_Cd__c,
                               Core_Opportunity_Decision_Dt__c,Core_First_Customer_Ship_Dt__c,Core_Production_End_Dt__c,Core_Intel_Platform_Nm__c
                               FROM Core_Design_Registration__c 
                               WHERE Id IN :mapOfIdToWrap.keySet() OR Core_External_Id__c IN :mapOfIdToWrap.keySet()];
                for(Core_Design_Registration__c vl:validDRList){
                    
                    existingDDR.put(vl.Id,vl);
                    
                    mapOfRecIdToExtId.put(string.valueof(vl.Id),vl.Core_External_Id__c);
                    mapOfExtIdToRecId.put(vl.Core_External_Id__c,string.valueof(vl.Id));
                }                              
            }
            for(String DRId : mapOfIdToWrap.keySet()){
                if(mapOfRecIdToExtId.containskey(DRId)){
                    mapRecIdTODRList.put(DRId,mapOfIdToWrap.get(DRId));
                    mapRecIdToDDR.put(DRId,existingDDR.get(DRId));
                }
                else if(mapOfExtIdToRecId.containskey(DRId)){
                    mapRecIdTODRList.put(mapOfExtIdToRecId.get(DRId),mapOfIdToWrap.get(DRId));
                    mapRecIdToDDR.put(mapOfExtIdToRecId.get(DRId),existingDDR.get(mapOfExtIdToRecId.get(DRId)));
                }               
            }
            
            
            System.debug('mapRecIdTODRList---> '+mapRecIdTODRList);

            
            if (!validDRList.isEmpty()) {               
                for(Core_Design_Registration__c dr : validDRList)
                {  
                    String controllingValue;
                    Core_Design_Registration__c reqFieldChcekDR=existingDDR.get(dr.id);
                    if(mapRecIdTODRList.containsKey(dr.Id)){
                        for(string fieldApiName : requiredFieldsApi){
                            string labelname= drProductApiToLabelMap.get(fieldApiName);
                            if(existingDDR.get(dr.id).get(fieldApiName) == null && (mapRecIdToDDR.get(dr.id).get(labelname))==null){
                             mapOfIdToErrMsg.put(dr.id,'Mandatory fields are Missing');
                    		} 
                          }
                        PCC_Wrapper.PCC_Update_DDRRequestWrapper drPayload = mapRecIdTODRList.get(dr.Id);
                        String productSegment = drPayload.productSegment != null ? drPayload.productSegment : null ; 
						String productApplication = drPayload.productApplication !=null ? drPayload.productApplication : null ;
                       // Core_Design_Registration__c drInst = new Core_Design_Registration__c();
                        
                        if(drPayload.productGroup!=null )
                            dr.Core_Product_Group_Nm__c = drPayload.productGroup;
                        if(drPayload.militaryAerospaceGvrnmtUseInd!=null)
                            dr.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = drPayload.militaryAerospaceGvrnmtUseInd;
                        if(drPayload.verticalMarket!=null)
                            dr.Core_Vertical_Market_Nm__c= drPayload.verticalMarket;
                        
                        if(productSegment!=null && productApplication!=null){
                            if(controlValueWrapMap.get(productSegment).contains(productApplication)){
                            	dr.Core_Product_Segment_Nm__c = productSegment;
                                dr.Core_Product_Application_Nm__c = productApplication;
                            } else{
                                 mapOfIdToErrMsg.put(dr.Id,'Cannot find the Parent field value and Child field value mapping');
                            }
                        }else{                       
                            if(productSegment!=null){
                                if(controlValueWrapMap.get(productSegment).contains(existingDDR.get(dr.Id).Core_Product_Application_Nm__c)){
                                    dr.Core_Product_Segment_Nm__c = productSegment;	
                                }else{
                                  mapOfIdToErrMsg.put(dr.Id,'Cannot update the parent field value for the child field value present on the DDR');
                                    //Parent field value is not supported by the Child field value
                                } 
                                controllingValue=productSegment;                                                                                              
                            }else{
                                controllingValue =existingDDR.containsKey(dr.Id) ? existingDDR.get(dr.Id).Core_Product_Segment_Nm__c : null;
                            }
                            
                            if(productApplication!=null){                                   
                                if(controlValueWrapMap.get(controllingValue).contains(productApplication)){                                 
                                    dr.Core_Product_Application_Nm__c = productApplication;
                                }else{
                                    mapOfIdToErrMsg.put(dr.Id,'Cannot find the Child field value provided for the Parent field value');
                                }                                    
                            }
                        }
                        if(drPayload.partnerFAE!=null){
                            dr.Core_Partner_FAE_Nm__c=drPayload.partnerFAE;
                        }
                        if(drPayload.endCustomerName!=null){
                            dr.Core_End_Customer_Nm__c=drPayload.endCustomerName;
                        }
                        if(drPayload.endCustomerAddress1!=null){
                            dr.Core_End_Customer_Street_Addr_Line1_Txt__c=drPayload.endCustomerAddress1;
                        }
                        if(drPayload.endCustomerPostalCode!=null){
                            dr.Core_End_Customer_Postal_Cd__c=drPayload.endCustomerPostalCode;
                        }
                        if(drPayload.endCustomerCountry!=null){
                            dr.Core_End_Customer_Country_Nm__c=drPayload.endCustomerCountry;
                        }
                            
                        
                        
                       /* Integer opportunityVolume = mapOfExtIdtoValidDDR.get(str).containsKey('opportunityVolume') ? Integer.valueOf(mapOfExtIdtoValidDDR.get(str).get('opportunityVolume')) : null;
                    String partnerFAE = mapOfExtIdtoValidDDR.get(str).containsKey('partnerFAE') ? (String)mapOfExtIdtoValidDDR.get(str).get('partnerFAE') : null;
                    String endCustomerName = mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerName') ? (String)mapOfExtIdtoValidDDR.get(str).get('endCustomerName') : null;
                    String endCustomerAddress1 = mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerAddress1') ? (String)mapOfExtIdtoValidDDR.get(str).get('endCustomerAddress1') : null;
                    String endCustomerPostalCode = mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerPostalCode') ? (String)mapOfExtIdtoValidDDR.get(str).get('endCustomerPostalCode') : null;
                    String endCustomerCountry = mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerCountry') ? (String)mapOfExtIdtoValidDDR.get(str).get('endCustomerCountry') : null;
                    //Date designDecisionDate = mapOfExtIdtoValidDDR.get(str).containsKey('designDecisionDate') ? (Date)mapOfExtIdtoValidDDR.get(str).get('designDecisionDate') : null;
                    //String productionEndDate = mapOfExtIdtoValidDDR.get(str).containsKey('firstCustomerShipDate') ? (String)mapOfExtIdtoValidDDR.get(str).get('firstCustomerShipDate') : null;
                    //  String retiredAsOf = mapOfExtIdtoValidDDR.get(str).containsKey('retiredAsOf') ? (String)mapOfExtIdtoValidDDR.get(str).get('retiredAsOf') : null;
                    String designDecisionDate = mapOfExtIdtoValidDDR.containsKey(str) && mapOfExtIdtoValidDDR.get(str).containsKey('designDecisionDate') ? (String) mapOfExtIdtoValidDDR.get(str).get('designDecisionDate') : null;
                    String firstCustomerShipDate = mapOfExtIdtoValidDDR.containsKey(str) && mapOfExtIdtoValidDDR.get(str).containsKey('firstCustomerShipDate') ? (String) mapOfExtIdtoValidDDR.get(str).get('firstCustomerShipDate') : null;
                    String productionEndDate = mapOfExtIdtoValidDDR.containsKey(str) && mapOfExtIdtoValidDDR.get(str).containsKey('productionEndDate') ? (String) mapOfExtIdtoValidDDR.get(str).get('productionEndDate') : null;
                    String intelPlatform = mapOfExtIdtoValidDDR.get(str).containsKey('intelPlatform') ? (String)mapOfExtIdtoValidDDR.get(str).get('intelPlatform') : null;
                    String designRegistrationName = mapOfExtIdtoValidDDR.get(str).containsKey('designRegistrationName') ? (String)mapOfExtIdtoValidDDR.get(str).get('designRegistrationName') : null;
                    String description = mapOfExtIdtoValidDDR.get(str).containsKey('description') ? (String)mapOfExtIdtoValidDDR.get(str).get('description') : null;
                    String partnerFSR = mapOfExtIdtoValidDDR.get(str).containsKey('partnerFSR') ? (String)mapOfExtIdtoValidDDR.get(str).get('partnerFSR') : null;
                    String endCustomerAddress2 = mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerAddress2') ? (String)mapOfExtIdtoValidDDR.get(str).get('endCustomerAddress2') : null;
                    String endCustomerCity = mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerCity') ? (String)mapOfExtIdtoValidDDR.get(str).get('endCustomerCity') : null;
                    String endCustomerState = mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerState') ? (String)mapOfExtIdtoValidDDR.get(str).get('endCustomerState') : null;
                    String endCustomerContactTitle = mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerContactTitle') ? (String)mapOfExtIdtoValidDDR.get(str).get('endCustomerContactTitle') : null;
                    String endCustomerContactName = mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerContactName') ? (String)mapOfExtIdtoValidDDR.get(str).get('endCustomerContactName') : null;
                    String endCustomerContactEmail = mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerContactEmail') ? (String)mapOfExtIdtoValidDDR.get(str).get('endCustomerContactEmail') : null;
                    String endCustomerContactPhone = mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerContactPhone') ? (String)mapOfExtIdtoValidDDR.get(str).get('endCustomerContactPhone') : null;
                    String manufacturingRegion = mapOfExtIdtoValidDDR.get(str).containsKey('manufacturingRegion') ? (String)mapOfExtIdtoValidDDR.get(str).get('manufacturingRegion') : null;
                    */
                        listOfDR.add(dr);
                        finalMapOfRecIdToDR.put(string.valueof(dr.Id),dr);                        
                    }                   
                }     
            }
            
            System.debug('listOfDR----> '+listOfDR);
            if(!listOfDR.isEmpty()){
                srList = Database.update(listOfDR, false);
            }
            System.debug('finalMapOfRecIdToDR----> '+finalMapOfRecIdToDR);
            for (Integer i = 0; i < listOfDR.size(); i++) {
                mapDrRecordSaveResult.put(listOfDR[i], srList[i]);
            }            
            //get response of records that are successfully inserted and the records that have errors
            PCC_Wrapper.PCC_DRDetailsWrapper drWrp = getDDRUpdateResponses(updateDDRWrapList,mapOfIdToWrap,finalMapOfRecIdToDR,mapDrRecordSaveResult,mapOfExtIdToRecId,mapOfRecIdToExtId,mapOfIdToErrMsg);
            
            //get statusCode based on successful or failed record count
            res.statusCode = getStatusCode(updateDDRWrapList.size(), drWrp.successfulRecordCount, drWrp.failedRecordCount);
            
            //set responsebody
            res.responseBody = Blob.valueOf(JSON.serialize(drWrp.respList));
            
        }
        catch(exception ex){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY, '', '', '', 'PCC_CreateDesignRegistrationUtility_V1', '', ex);
        }
        return res;
    }
    /*********************************************************************************************************************************************************
    * Method Name: getDDRUpdateResponses
    * Date: 28/06/2023    
    * Owner: Manasa
    * Description: This is a method to return PCC_Wrapper.PCC_DRDetailsWrapper which has the response list for the particular update on ddr
    * Return: Returns PCC_Wrapper.PCC_DRDetailsWrapper
    * *****************************************************************************************************************************************************************/
    
    public static PCC_Wrapper.PCC_DRDetailsWrapper getDDRUpdateResponses(List<PCC_Wrapper.PCC_Update_DDRRequestWrapper> reqWrapper,Map<String, PCC_Wrapper.PCC_Update_DDRRequestWrapper> mapOfIdToWrap,
                                                                        Map<String, Core_Design_Registration__c> finalMapOfRecIdToDR,Map<Core_Design_Registration__c, Database.SaveResult> mapDrRecordSaveResult,
                                                                        Map<String,String> mapOfExtIdToRecId,Map<String,String> mapOfRecIdToExtId,Map<String,String>mapOfIdToErrMsg)
    {
        Set<String> errorString;      
        String errorMsgForLogEntry = '';
        Integer failedRecordCount = 0;
        Integer successfulRecordCount = 0;
        Map<String, String> drProductApiToLabelMap = PCC_Constants.drProductApiToLabelMap;
        
        List<PCC_Wrapper.restAPIResponseWrapper> respList = new List<PCC_Wrapper.restAPIResponseWrapper>();   
        PCC_Wrapper.PCC_DRDetailsWrapper drWrp = new PCC_Wrapper.PCC_DRDetailsWrapper();
        
        try{ 
            Integer count = 0;
            for(PCC_Wrapper.PCC_Update_DDRRequestWrapper dr:reqWrapper){
                
                //getting the record id for the DDR to be updated , to display in the response and also to get the message for ir Wrp as the wrapper contains extid or recid
                String uniqueId = mapOfExtIdToRecId.containskey(dr.recOrExtId) ? mapOfExtIdToRecId.get(dr.recOrExtId) : dr.recOrExtId ;
                String extId = mapOfExtIdToRecId.containskey(dr.recOrExtId) ? dr.recOrExtId : mapOfRecIdToExtId.get(dr.recOrExtId) ;

                PCC_Wrapper.restAPIInnerResponseWrapper irWrp = new PCC_Wrapper.restAPIInnerResponseWrapper();               
                if(mapOfIdToWrap.containskey(dr.recOrExtId)){
                    
                    if(!mapOfIdToErrMsg.isEmpty() && mapOfIdToErrMsg.containsKey(uniqueId)){
                        failedRecordCount++;
                        irWrp.ExternalId=extId;
                        irWrp.Message = mapOfIdToErrMsg.get(uniqueId);
                        respList.add(PCC_CreateDDRUtilityHandler.setJsonResponseBody(400, 'FAILURE', 9002, irWrp, uniqueId));
                    }               
                    else if(finalMapOfRecIdToDR.containsKey(uniqueId)){
                        System.debug('InsideIF---->');
                        Database.SaveResult sr = mapDrRecordSaveResult.get(finalMapOfRecIdToDR.get(uniqueId));
                        //return success message if record is created successfully
                        if (sr != null && sr.isSuccess()) {
                            successfulRecordCount++;
                            String recId = uniqueId;
                            irWrp.ExternalId=extId;
                            irWrp.Message = 'Record has been successfully updated.';
                            respList.add(setJsonResponseBody(201, 'SUCCESS', null ,irWrp, sr.getId()));        
                        }
                        else{
                            //return database error if record insertion is failed
                            failedRecordCount++;
                            String failedRecordId = uniqueId;
                            // Handle the error as needed
                            if (sr != null) {
                                errorString = new Set<String>();
                                for (Database.Error err : sr.getErrors()) {
                                    
                                    String fieldName = err.Fields.toString();
                                    if (errorString.contains(fieldName + err.getMessage())) {
                                        continue;
                                    }else {
                                        String errMessage = '';
                                        Integer errCd;
                                        
                                        //getting fieldlist for which we are getting error
                                        List<String> fieldsNameList = new List<String>();
                                        if(err.getfields().size()>0){
                                            for(String fn: err.getfields()){
                                                fieldsNameList.add(drProductApiToLabelMap.get(fn));
                                            }
                                        }
                                        
                                        String statusCode = String.valueOf(err.getStatusCode());
                                        
                                        if(statusCode == 'DUPLICATE_VALUE'){
                                            System.debug('err.getMessage()'+err.getMessage());
                                            String badValue, existingRecId;
                                            List<String> messageParts = err.getMessage().split(':');
                                            if (messageParts.size() > 1) {
                                                badValue = messageParts[1].trim().substringBefore(' ');
                                                existingRecId = messageParts[2].trim();
                                            }
                                            System.debug('badValue'+badValue);
                                            errMessage = 'The `' + drProductApiToLabelMap.get(badValue) +  '` value you are trying to use is already being used by another record with ID `'+ existingRecId + '`. Please update it to something unique and try again.';
                                            errCd = 9011;
                                        }
                                        else if(statusCode == 'INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST'){
                                            errMessage = 'Bad or Inactive value given to '+ fieldsNameList +' picklist: '+ finalMapOfRecIdToDR.get(drProductApiToLabelMap.get(err.getfields()[0])) +'. Please choose an option from the available list of values for this field.' ;
                                            errCd = 9011;
                                        }
                                        else if(statusCode == 'FIELD_FILTER_VALIDATION_EXCEPTION'){
                                            errMessage =  'Given value does not exist or does not match filter criteria for following fields: '+  fieldsNameList;      
                                            errCd = 9011;
                                        }
                                        else if(statusCode == 'REQUIRED_FIELD_MISSING'){
                                            errMessage =  'Following required fields are missing:  '+  fieldsNameList;      
                                            errCd = 9011;
                                        }else if(statusCode == 'FIELD_INTEGRITY_EXCEPTION' || statusCode == 'MALFORMED_ID' || statusCode == 'INVALID_ID_FIELD'){
                                            String badValue;
                                            List<String> messageParts = err.getMessage().split(':');
                                            if (messageParts.size() > 1) {
                                                badValue = messageParts[2].trim();
                                            }
                                            errMessage =  'Provided '+ fieldsNameList+ ' is incorrect: '+ badValue;      
                                            errCd = 9011;
                                        }
                                        else if(statusCode == 'STRING_TOO_LONG'){
                                            String badValue;
                                            List<String> messageParts = err.getMessage().split(':');
                                            if (messageParts.size() > 1) {
                                                badValue = messageParts[2].trim();
                                            }
                                            errMessage =  'Given Data value is too large for '+  fieldsNameList + ': '+ badValue;      
                                            errCd = 9011;
                                        }
                                        else{
                                            errMessage =  err.getMessage();      
                                            errCd = 9011;
                                        }
                                        
                                        irWrp.ExternalId = uniqueId;
                                        irWrp.Message = errMessage;
                                        respList.add(setJsonResponseBody(400, 'FAILURE', errCd, irWrp , uniqueId));
                                        errorString.add(fieldName + err.getMessage());
                                        errorMsgForLogEntry += uniqueId+' - '+err.getMessage()+'\n';
                                    }
                                }                               
                            }
                        }
                    }
                    else{
                        System.debug('InsideELSE1---->');
                        //return error if the requested record doesn't have record id
                        failedRecordCount++;
                        irWrp.Message='Please provide a Valid Record Id/External Id field to update the record.';
                        respList.add(setJsonResponseBody(400, 'FAILURE',9002,irWrp, uniqueId));
                        errorMsgForLogEntry += 'Invalid Id field: No valid id found in the payload for that record'+'\n';
                        
                    }
                }
                
                else{ 
                    System.debug('InsideELSE2---->');
                    //return error if the requested record doesn't have record id
                    failedRecordCount++;
                    irWrp.Message='Please provide Record id/External id field to update the record.';
                    respList.add(setJsonResponseBody(400, 'FAILURE',9002,irWrp, ''));
                    errorMsgForLogEntry += 'missing Id field: No id found in the payload for that record'+'\n';
                }  
                count++;
            }
            System.debug('respList---> '+respList);
            drWrp.failedRecordCount = failedRecordCount;
            drWrp.successfulRecordCount = successfulRecordCount;
            drWrp.respList = respList;
            
            if(failedRecordCount!=0){
                Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY, 'Exception occurred while updating Design Registration Record',errorMsgForLogEntry, '', '', '');
            }
              
        }
        catch (Exception ex) {
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateDesignRegistrationUtility' ,'' ,ex); 
        }
        return drWrp;
        
    }
    
    public static Map<String, List<String>> getDependentPicklistValues(String ObjectName,String dependToken) {
   List<Schema.PicklistEntry> dependentEntries = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().get(dependToken).getDescribe().getPicklistValues();
   Schema.sObjectField controlToken = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().get(dependToken).getDescribe().getController();

    //Schema.DescribeFieldResult depend = dependToken.getDescribe();
    //Schema.sObjectField controlToken = depend.getController();
    if (controlToken == null) {
        return new Map<String, List<String>>();
    }

    Schema.DescribeFieldResult control = controlToken.getDescribe();
    List<Schema.PicklistEntry> controlEntries;
    if(control.getType() != Schema.DisplayType.Boolean) {
        controlEntries = control.getPicklistValues();
    }

    String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
    for (Schema.PicklistEntry entry : dependentEntries) {
        if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
            List<String> base64chars =
                    String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
            for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                Object controlValue =
                        (controlEntries == null
                                ?   (Object) (index == 1)
                                :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                        );
                Integer bitIndex = index / 6;
                if (bitIndex > base64chars.size() - 1) {
                    break;
                }
                Integer bitShift = 5 - Math.mod(index, 6);
                if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                    continue;
                if (!dependentPicklistValues.containsKey((String) controlValue)) {
                    dependentPicklistValues.put((String) controlValue, new List<String>());
                }
                dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
            }
        }
    }
    return dependentPicklistValues;
   }
    public static PCC_Wrapper.restAPIResponseWrapper setJsonResponseBody(Integer statusCode, String status, Integer errorCode, PCC_Wrapper.restAPIInnerResponseWrapper responseBody, String recordId){
        PCC_Wrapper.restAPIResponseWrapper respWrapper = new PCC_Wrapper.restAPIResponseWrapper();
        respWrapper.StatusCode = statusCode;
        respWrapper.Status = status;
        respWrapper.ErrorCode = errorCode;
        respWrapper.ResponseBody = responseBody;
        respWrapper.RecordId = recordId;
        return respWrapper;
    }
     Public static Integer getStatusCode(Integer totalDrRecordCount, Integer successfulRecordCount, Integer failedRecordCount){
        Integer statusCode = 0;
        try{
            if (totalDrRecordCount>0 && totalDrRecordCount == successfulRecordCount) { //if all the records are successfully inserted
                statusCode = 201;   
            }
            if(failedRecordCount > 0 && failedRecordCount != totalDrRecordCount){ //incase of Partial insert
                statusCode = 207;
            }
            if(totalDrRecordCount == failedRecordCount){ //if all the records fail
                statusCode = 400;
            }
        }catch(exception ex){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY, '', '', '', 'PCC_CreateDesignRegistrationUtility_V1', '', ex);
        }
        return statusCode;
        
    }  
    

}