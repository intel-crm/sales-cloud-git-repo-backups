/*************************************************************************************************************************************
Apex Class Name     : PCC_DesignDeleteAPIUtilityHandler
Version             : V2.0- Delete API enabled in V2.0 .
Created Date        : June 2024

Modification Log    :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Manasa                June- 2024       Added delete methods in without sharing class,to enable m2m jwt delete api , when faceless user and partner user roles are same
************************************************************************************************************************************************/
public without sharing class PCC_DesignDeleteAPIUtilityHandler {
    public static final String LOG_ENTRY_ORIGIN   = 'PCC_CreateDesignRegistration_V2';
    public static final String LOG_ENTRY_PROJECT  = 'DDR Registration';
    public static final String LOG_ENTRY_SCOPE    = 'Create DDR Records';
    public static final String LOG_ENTRY_SCOPE_1  = 'Fetch DDR Picklist Values';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_SEVERITY = 'High';
    public static final String LOG_ENTRY_INFO     = 'info';  
    
    /*****************************************************************************************************************
* Method Name: deleteDesignRegistrationRecords
* Date: 06/2024 
* Owner: Manasa
* Description: This is a handler method to delete DDR records based on the payload received
* Return: Returns RestResponse with successful and error messages to external systems
******************************************************************************************************************/
    public static RestResponse deleteDRRecords(List<Object> dDRWrapList){
        list<Core_Design_Registration__c> validDRList = new list<Core_Design_Registration__c>();
        list<Core_Design_Registration__c> validDrForDML = new list<Core_Design_Registration__c>();
        list<id> validDRIds = new list<id>();
        Integer dDRCount = 0;
        List<id> deleteSuccessRec = new list<id>();
        Map<String,Map<String,Object>> mapIdToWrapMap = new Map<String,map<string,Object>>();
        Map<String,Map<String,Object>> mapIdToWrapMapValidId = new Map<String,map<string,Object>>();
        Map<Integer,Map<String,Object>> mapIdToWrapMapAll= new Map<Integer,Map<String,Object>>();
        map<id,string> mapIdToValidationMsg = new map<id,string>();
        Map<Id,String> getDRNames = new Map<Id,String>();
        Map<Id,String> drIdToExtIdMap = new Map<Id,String>();
        Map<String,list<string>> mapIdTounexpected = new Map<String,list<string>>();
        try{
            for(Object reqWrap : dDRWrapList){                
                Map<String, Object> drMap = (Map<String, Object>)reqWrap;
                mapIdToWrapMapAll.put(dDRCount,drMap);
                if((drMap.keyset()).contains('recordId')){
                    if((String)drMap.get('recordId')!=null && (String)drMap.get('recordId')!=''){
                        mapIdToWrapMapValidId.put((String)drMap.get('recordId'),drMap);
                        
                        list<string> unExpValues =new List<String>();
                        for(string payloadLabel : drMap.keyset()){
                            if(!PCC_Constants.allowedFieldsDeleteAPI.contains(payloadLabel)){
                                unExpValues.add(payloadLabel);    
                            }                           
                        }
                        if(!unExpValues.isEmpty()){
                            mapIdTounexpected.put((String)drMap.get('recordId'),unExpValues);
                        }else{
                            mapIdToWrapMap.put((String)drMap.get('recordId'),drMap);
                        }
                    }
                }
                dDRCount++;
            }                    
            //validDRList = PCC_CreateDDRUtilityHandler_V2.validDrRecords(mapIdToWrapMap);
            if(!mapIdToWrapMapValidId.isEmpty()){
                validDRList = [SELECT Id,Core_External_Id__c,Name,Core_Design_Registration_Nm__c, Core_Design_Registration_Status_Nm__c
                               FROM Core_Design_Registration__c 
                               WHERE Id IN :mapIdToWrapMapValidId.keySet()]; 
            }
            if(validDRList.size()>0){
                for(Core_Design_Registration__c vl:validDRList){
                    if(mapIdToWrapMap.keyset().contains(vl.id)){
                        validDRIds.add(vl.id);
                        validDrForDML.add(vl);
                    }               	
                    getDRNames.put(vl.id,vl.Name);
                    drIdToExtIdMap.put(vl.id,vl.Core_External_Id__c);
                }
            }
            
            if(validDrForDML.size()>0){
                Database.DeleteResult[] drList = Database.delete(validDrForDML, false);
                for(Database.DeleteResult dr : drList) {
                    if (dr.isSuccess()) {
                        deleteSuccessRec.add(dr.id);
                    }
                    else {              
                        for(Database.Error err : dr.getErrors()) {
                            mapIdToValidationMsg.put(dr.id,err.getMessage());
                        }
                    }
                }
            }
        }catch(exception ex){Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY, '', '', '', 'PCC_CreateDDRUtilityHandler_V2.deleteDRRecords', '', ex);
                            }
        
        return deleteResponse(mapIdTounexpected,mapIdToWrapMapAll,deleteSuccessRec,mapIdToValidationMsg,validDRIds,dDRWrapList,getDRNames,drIdToExtIdMap);
    }
    /*****************************************************************************************************************
* Method Name: deleteDesignRegistrationRecords
* Date: 06/2024 
* Owner: Manasa
* Description: This is a handler method to delete DDR records based on the payload received
* Return: Returns RestResponse with successful and error messages to external systems
******************************************************************************************************************/
    public static RestResponse deleteResponse(Map<String,list<string>> mapIdTounexpected,Map<Integer,Map<String,Object>> mapIdToWrapMapAll,List<id> deleteSuccessRec
                                              ,map<id,string> mapIdToValidationMsg,list<Id> validDRIds,List<Object> dDRWrapList,Map<Id,String> getDRNames,Map<Id,String> drIdToExtIdMap)
    {   
        Integer deleteSuccess = 0 ;
        Integer deleteFailure = 0 ;
        string uniqueId = '' ;
        List<PCC_Wrapper.restAPIResponseWrapper> respList = new List<PCC_Wrapper.restAPIResponseWrapper>();
        RestResponse res = RestContext.response;
        for(Map<String, Object> drMap : mapIdToWrapMapAll.values()) {
            PCC_Wrapper.restAPIResponseWrapper response = new PCC_Wrapper.restAPIResponseWrapper();           
            PCC_Wrapper.restAPIInnerResponseWrapper irWrp = new PCC_Wrapper.restAPIInnerResponseWrapper();
            
            uniqueId = drMap.containsKey('recordId')?(String)drMap.get('recordId'):null;
            if(!mapIdTounexpected.isEmpty() && mapIdTounexpected.get(uniqueId)!=null){
                irWrp.ExternalId = drIdToExtIdMap.get(uniqueId);
                irWrp.Message = 'Unexpected Fields found in payload :'+String.join(mapIdTounexpected.get(uniqueId), ',') ;
                deleteFailure++;
                respList.add(PCC_CreateDDRUtilityHandler_V2.setJsonResponseBody(400, 'FAILURE', 9002, irWrp, uniqueId,getDRNames.get(uniqueId)));          
            }else if(uniqueId == null || String.isblank(uniqueId)){
                irWrp.ExternalId = null;
                irWrp.Message = LabelConfiguration__mdt.getInstance('PCC_DeleteDRNoRecordId').Value__c ;
                deleteFailure++;
                respList.add(PCC_CreateDDRUtilityHandler_V2.setJsonResponseBody(400, 'FAILURE', 9002, irWrp, uniqueId,null));
            }else if(!validDRIds.contains(uniqueId)){
                irWrp.ExternalId = null;
                irWrp.Message = LabelConfiguration__mdt.getInstance('PCC_DeleteDRValidRecordId').Value__c;
                deleteFailure++;
                respList.add(PCC_CreateDDRUtilityHandler_V2.setJsonResponseBody(400, 'FAILURE', 9002, irWrp, uniqueId,null));
            }else if(deleteSuccessRec.contains(uniqueId)){
                irWrp.ExternalId = drIdToExtIdMap.get(uniqueId);
                irWrp.Message = LabelConfiguration__mdt.getInstance('PCC_DeleteDRSuccessMsg').Value__c;
                deleteSuccess++;
                respList.add(PCC_CreateDDRUtilityHandler_V2.setJsonResponseBody(201,'SUCCESS', null, irWrp, uniqueId,getDRNames.get(uniqueId)));
            }else if((mapIdToValidationMsg.keyset()).contains(uniqueId)){
                irWrp.ExternalId = drIdToExtIdMap.get(uniqueId);
                irWrp.Message = mapIdToValidationMsg.get(uniqueId);
                deleteFailure++; 
                respList.add(PCC_CreateDDRUtilityHandler_V2.setJsonResponseBody(400,'FAILURE',9013, irWrp, uniqueId,getDRNames.get(uniqueId))); 
            }
        }
        res.statusCode = getDeleteStatusCode(dDRWrapList.size(),deleteSuccess,deleteFailure);
        res.responseBody = Blob.valueOf(JSON.serialize(respList)); 
        return res;
    }
    /*****************************************************************************************************************
* Method Name:getDeleteStatusCode
* Date: 04/06/2024   
* Owner: Manasa
* Description: This is a generic method to get statusCode based on successful or failed record count
* Return: returns statusCode as Integer
******************************************************************************************************************/
    
    Public static Integer getDeleteStatusCode(Integer totalDrRecordCount, Integer successfulRecordCount, Integer failedRecordCount){
        Integer statusCode = 0;
        try{
            if (totalDrRecordCount>0 && totalDrRecordCount == successfulRecordCount) { //if all the records are successfully deleted
                statusCode = 200;   //204 no content or 200 ok 
            }
            if(failedRecordCount > 0 && failedRecordCount != totalDrRecordCount){ //incase of Partial delete
                statusCode = 207;
            }
            if(totalDrRecordCount == failedRecordCount){ //if all the records fail to delete
                statusCode = 404; //or 403 insuffiecient access
            }
        }catch(exception ex){ Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY, '', '', '', 'PCC_CreateDDRUtilityHandler_V2.getStatusCode', '', ex);
                            }
        return statusCode;
        
    } 
    /*****************************************************************************************************************
* Method Name: deleteDRPRecords
* Date: 04/06/2024 
* Owner: Manasa
* Description: This is a handler method to delete DRP records based on the payload received
* Return: Returns RestResponse with successful and error messages to external systems
******************************************************************************************************************/
    public static RestResponse deleteDRPRecords(List<Object> drpWrapList){
        list<Core_Design_Registration_Product__c> validDRPList = new list<Core_Design_Registration_Product__c>();
        list<Core_Design_Registration_Product__c> validDrpForDML = new list<Core_Design_Registration_Product__c>();
        Integer drpCount = 0;
        List<id> deleteSuccessRec = new List<id>();
        map<id,integer> mapIdToErrorCode = new map<id,integer>();
        Map<String,Map<String,Object>> mapIdToWrapMap = new Map<String,map<string,Object>>();
        Map<String,Map<String,Object>> mapIdToWrapMapValidId = new Map<String,map<string,Object>>();
        Map<Integer,Map<String,Object>> mapIdToWrapMapAll= new Map<Integer,Map<String,Object>>();
        map<id,string> mapIdToValidationMsg = new map<id,string>();
        list<id> validDRPIds = new list<id>();
        Map<Id,String> getDRPNames = new Map<Id,String>();
        Map<Id,String> drpIdToExtIdMap = new Map<Id,String>();
        Map<String,list<string>> mapIdTounexpected = new Map<String,list<string>>();
        
        try{
            for(Object reqWrap : drpWrapList){ 
                Map<String, Object> drMap = (Map<String, Object>)reqWrap;
                mapIdToWrapMapAll.put(drpCount,drMap);
                if((drMap.keyset()).contains('recordId')){
                    if((String)drMap.get('recordId')!=null && (String)drMap.get('recordId')!=''){
                        mapIdToWrapMapValidId.put((String)drMap.get('recordId'),drMap);
                        
                        list<string> unExpValues =new List<String>();
                        for(string payloadLabel : drMap.keyset()){
                            if(!PCC_Constants.allowedFieldsDeleteAPI.contains(payloadLabel)){
                                unExpValues.add(payloadLabel);    
                            }
                        }
                        if(!unExpValues.isEmpty()){
                            mapIdTounexpected.put((String)drMap.get('recordId'),unExpValues);
                        }else{
                            mapIdToWrapMap.put((String)drMap.get('recordId'),drMap);}
                    }
                }
                
                drpCount++;
            }
            
            if(!mapIdToWrapMapValidId.isEmpty()){
	                    validDRPList = [SELECT Id, Name,Core_Design_Registration_Id__c, Core_External_Id__c
                                FROM Core_Design_Registration_Product__c 
                                WHERE Id IN: mapIdToWrapMapValidId.keySet()];
            }
            
            if(validDRPList.size()>0){
                for(Core_Design_Registration_Product__c vl:validDRPList){
                    if(mapIdToWrapMap.keyset().contains(vl.id)){
                        validDRPIds.add(vl.id);
                        validDrpForDML.add(vl);
                    }   
                    getDRPNames.put(vl.id,vl.Name);
                    drpIdToExtIdMap.put(vl.id,vl.Core_External_Id__c);
                }
                /*if(validDRPIds.size()>0){
getDRPNames = PCC_CreateDDRUtilityHandler_V2.getNameDDR(validDRPIds);
} */  
            }
            if(validDrpForDML.size()>0){
                Database.DeleteResult[] drList = Database.delete(validDrpForDML, false);
                
                for(Database.DeleteResult dr : drList) {
                    if (dr.isSuccess()) {
                        deleteSuccessRec.add(dr.id);
                    }
                    else {              
                        for(Database.Error err : dr.getErrors()) {
                            mapIdToValidationMsg.put(dr.id,err.getMessage());
                        }
                    }
                }                  
            }           
        }catch(exception ex){Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY, '', '', '', 'PCC_CreateDDRUtilityHandler_V2.deleteDRRecords', '', ex);
                            }
        return deleteDRPResponse(mapIdTounexpected,mapIdToWrapMapAll,deleteSuccessRec,mapIdToValidationMsg,validDRPIds,drpWrapList,getDRPNames,drpIdToExtIdMap);
    }

    /*****************************************************************************************************************
* Method Name: deleteDesignRegistrationRecords
* Date: 06/2024 
* Owner: Manasa
* Description: This is a handler method to delete DRP records based on the payload received
* Return: Returns RestResponse with successful and error messages to external systems
******************************************************************************************************************/
    public static RestResponse deleteDRPResponse(Map<String,list<string>> mapIdTounexpected,Map<Integer,Map<String,Object>> mapIdToWrapMapAll,List<id> deleteSuccessRec
                                                 ,map<id,string> mapIdToValidationMsg,list<Id> validDRPIds,List<Object> drpWrapList,Map<Id,String> getDRPNames,Map<Id,String> drpIdToExtIdMap)
    { 
        Integer deleteSuccess = 0 ;
        Integer deleteFailure = 0 ;
        string uniqueId = '' ;
        List<PCC_Wrapper.restAPIResponseWrapper> respList = new List<PCC_Wrapper.restAPIResponseWrapper>();
        RestResponse res = RestContext.response;
        for(Map<String, Object> drMap : mapIdToWrapMapAll.values()) {
            PCC_Wrapper.restAPIResponseWrapper response = new PCC_Wrapper.restAPIResponseWrapper();           
            PCC_Wrapper.restAPIInnerResponseWrapper irWrp = new PCC_Wrapper.restAPIInnerResponseWrapper();
            uniqueId = drMap.containsKey('recordId')?(String)drMap.get('recordId'):null;
            if(!mapIdTounexpected.isEmpty() && mapIdTounexpected.get(uniqueId)!=null){
                irWrp.ExternalId = drpIdToExtIdMap.get(uniqueId);
                irWrp.Message = 'Unexpected Fields found in payload :'+String.join(mapIdTounexpected.get(uniqueId), ',') ;
                deleteFailure++;
                respList.add(PCC_CreateDDRUtilityHandler_V2.setJsonResponseBody(400, 'FAILURE', 9002, irWrp, uniqueId,getDRPNames.get(uniqueId)));          
            }
            else if(uniqueId == null || String.isblank(uniqueId)){
                irWrp.ExternalId = Null;
                irWrp.Message = LabelConfiguration__mdt.getInstance('PCC_DeleteDRPNoRecordId').Value__c;
                deleteFailure++;
                respList.add(PCC_CreateDDRUtilityHandler_V2.setJsonResponseBody(400, 'FAILURE', 9002, irWrp, uniqueId,null));
            }else if(!validDRPIds.contains(uniqueId)){
                irWrp.ExternalId = Null;
                irWrp.Message = LabelConfiguration__mdt.getInstance('PCC_DeleteDRPValidRecordId').Value__c;
                deleteFailure++;
                respList.add(PCC_CreateDDRUtilityHandler_V2.setJsonResponseBody(400, 'FAILURE', 9002, irWrp, uniqueId,null));
            }else if(deleteSuccessRec.contains(uniqueId)){
                irWrp.ExternalId = drpIdToExtIdMap.get(uniqueId);
                irWrp.Message = LabelConfiguration__mdt.getInstance('PCC_DeleteDRPSuccessMsg').Value__c;
                deleteSuccess++;
                respList.add(PCC_CreateDDRUtilityHandler_V2.setJsonResponseBody(201,'SUCCESS', null, irWrp, uniqueId,getDRPNames.get(uniqueId)));
            }else if((mapIdToValidationMsg.keyset()).contains(uniqueId)){
                irWrp.ExternalId = drpIdToExtIdMap.get(uniqueId);
                irWrp.Message = mapIdToValidationMsg.get(uniqueId);
                deleteFailure++;                    
                respList.add(PCC_CreateDDRUtilityHandler_V2.setJsonResponseBody(400,'FAILURE',9013, irWrp, uniqueId,getDRPNames.get(uniqueId)));  
            }
        }
        res.statusCode = getDeleteStatusCode(drpWrapList.size(),deleteSuccess,deleteFailure);
        res.responseBody = Blob.valueOf(JSON.serialize(respList)); 
        return res;
    }
    
    
}