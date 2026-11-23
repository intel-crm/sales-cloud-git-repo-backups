/*************************************************************************************************************************************
Apex Class Name     : PCC_CreateDRProductUtilityHandler_V1
Version             : 
Created Date        : May 2023

Modification Log    :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Shraddha                May- 2023        Added a methods (getDDRPicklistValues) to fetch API values of given picklists
************************************************************************************************************************************************/

public class PCC_CreateDRProductUtilityHandler_V1 {
    
	public static final String LOG_ENTRY_ORIGIN   = 'PCC_CreateDesignRegistration';
    public static final String LOG_ENTRY_PROJECT  = 'DDR Registration';
    public static final String LOG_ENTRY_SCOPE    = 'Create DDR Records';
    public static final String LOG_ENTRY_SCOPE_1  = 'Fetch DDR Picklist Values';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_SEVERITY = 'High';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static Map<String, String> mapExtIdtoInvalidValMsg = new Map<String, String>();  

       
/*****************************************************************************************************************
* Method Name: createDDRProducts
* Date: /06/2023    
* Owner: Shraddha
* Description: This is a handler method to Create DDR products records based on the payload received
* Return: Returns RestResponse with successful and error messages to external systems
******************************************************************************************************************/
    public static RestResponse createDDRProducts(List<Object> listOfPayloads){
        RestResponse res = RestContext.response;
        Map<String, Core_Design_Registration_Product__c> mapExtIdToValidDr = new Map<String, Core_Design_Registration_Product__c>();
        List<Core_Design_Registration_Product__c> drProductListToInsert = new List<Core_Design_Registration_Product__c>();
        Map<String, List<String>> mapExtIdToMissingFld = new Map<String, List<String>>();
        Map<Integer, Map<String, Object>> mapOfCountToDrmap = new Map<Integer, Map<String, Object>>();
        Map<String, Map<String, Object>> mapOfExtIdtoValidDDR = new Map<String, Map<String, Object>>();
        List<String> requiredFields = Label.PCC_Required_DDRProducts.split(',');
        Map<Object, Database.SaveResult> mapDrRecordSaveResult = new Map<Object, Database.SaveResult>();  
        
        
        try{
            Integer count = 0;
            for(Object dr : listOfPayloads){
                Map<String, Object> drMap = (Map<String, Object>)dr;    
                mapOfCountToDrmap.put(count, drMap);
                
                String uniqueExtId = (String)drMap.get('uniqueId') + count;
                String extId = (String)drMap.get('uniqueId');
                Boolean isReqFieldsMissing = false;
                
                //put required fields that are missing in map 
                for (String fieldName : requiredFields) {                    
                    if(String.isBlank((String)drMap.get(fieldName))&& uniqueExtId != null){
                        if (mapExtIdToMissingFld.containsKey(uniqueExtId)) {
                            mapExtIdToMissingFld.get(uniqueExtId).add(fieldName);
                        } else {
                            mapExtIdToMissingFld.put(uniqueExtId, new List<String>{fieldName});
                        }
                    }
                }
                if(uniqueExtId != null && !isReqFieldsMissing){ 
                    mapOfExtIdtoValidDDR.put(uniqueExtId, drMap); 
                }
                count++;
            }
            
            //create DDR instance fot valid DDR's
            if(mapOfExtIdtoValidDDR.size()>0){
                mapExtIdToValidDr = createDRProductInstance(mapOfExtIdtoValidDDR);
                drProductListToInsert = mapExtIdToValidDr.values();
            }
            
            //insert records from payload that have an external id's
            if (!drProductListToInsert.isEmpty()) {
                Integer i = 0;
                for(Database.SaveResult sr: Database.insert(drProductListToInsert, false)){
                    mapDrRecordSaveResult.put(drProductListToInsert[i], sr);
                    i++;
                }
            }
            
            //get response of records that are successfully inserted and the records that have errors
            PCC_Wrapper.PCC_DRDetailsWrapper drProductWrp = PCC_CreateDDRUtilityHandler.getDDRObjectResponses(mapOfCountToDrmap , mapExtIdToMissingFld, 
                                                                                                              mapExtIdToValidDr, mapExtIdtoInvalidValMsg, 
                                                                                                              mapDrRecordSaveResult, null, null, 'Insert');
            
            //get statusCode based on successful or failed record count
            res.statusCode = PCC_CreateDDRUtilityHandler.getStatusCode(listOfPayloads.size(), drProductWrp.successfulRecordCount, drProductWrp.failedRecordCount);
            
            //set responsebody
            res.responseBody = Blob.valueOf(JSON.serialize(drProductWrp.respList));
            
        }catch(exception ex){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY, '', '', '', 'PCC_CreateDesignRegistrationUtility_V1', '', ex);
        }
        return res;
    }

    
 /*****************************************************************************************************************
* Method Name: createDRProductInstance
* Date: /06/2023    
* Owner: Shraddha
* Description: This is a method to create instances of Design Registration Product Object for valid payloads
* Return: Returns map with DR product List
******************************************************************************************************************/
    public static Map<String, Core_Design_Registration_Product__c> createDRProductInstance( Map<String, Map<String, Object>> mapOfExtIdtoValidDDR){   
        Map<String, Core_Design_Registration_Product__c> mapExtIdToValidDr = new Map<String, Core_Design_Registration_Product__c>();
        try{
            if(mapOfExtIdtoValidDDR.size() > 0){
                for(string str: mapOfExtIdtoValidDDR.keySet()){
                    String designId = mapOfExtIdtoValidDDR.get(str).containsKey('designRegId') ? (String)mapOfExtIdtoValidDDR.get(str).get('designRegId') : null;
                    String productId = mapOfExtIdtoValidDDR.get(str).containsKey('productId') ? (String)mapOfExtIdtoValidDDR.get(str).get('productId') : null;
                    Integer quantity = mapOfExtIdtoValidDDR.get(str).containsKey('quantity') ? Integer.valueOf(mapOfExtIdtoValidDDR.get(str).get('quantity')) : null;
                    String status = mapOfExtIdtoValidDDR.get(str).containsKey('status') ? (String)mapOfExtIdtoValidDDR.get(str).get('status') : null;
                    String retiredAsOf = mapOfExtIdtoValidDDR.get(str).containsKey('retiredAsOf') ? (String)mapOfExtIdtoValidDDR.get(str).get('retiredAsOf') : null;
                    
                    Core_Design_Registration_Product__c drProduct = new Core_Design_Registration_Product__c();
                    drProduct.Core_External_Id__c = (String)mapOfExtIdtoValidDDR.get(str).get('uniqueId');
                    if(designId != null){//if(designId.length()== 15 || designId.length()== 18)
                        try{
                            drProduct.Core_Design_Registration_Id__c = designId;
                        }catch(exception ex){
                            mapExtIdtoInvalidValMsg.put(str, 'Provided Design Registration ID is incorrect or blank: '+designId);
                        }
                    }
                    if(productId!= null){
                        try{
                            drProduct.Core_Product_Id__c = productId;
                        }catch(exception ex){
                            mapExtIdtoInvalidValMsg.put(str, 'Provided Product ID is incorrect or blank: ' +productId);
                        }
                    }
                    if(quantity!= null){
                        drProduct.Core_Full_Year_Qty__c = quantity;
                    }
                    if(status != null){
                        drProduct.Core_Design_Product_Status_Nm__c = status;
                    }
                    if(retiredAsOf != null){
                        try{
                            drProduct.Core_Retired_As_Of_Dt__c = Date.valueOf(retiredAsOf);
                        }catch(exception ex){
                            mapExtIdtoInvalidValMsg.put(str,'Please provide date in valid format (YYYY-MM-DD)');
                        }
                    }  
                    drProduct.Core_Submission_Type__c = 'M2M';          
                    mapExtIdToValidDr.put(str, drProduct);
                }
            }
        }catch (Exception ex) {
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateDesignRegistrationUtility' ,'' ,ex); 
        }
        
        return mapExtIdToValidDr;
    }
    

}