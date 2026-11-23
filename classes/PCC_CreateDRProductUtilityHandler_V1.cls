/*************************************************************************************************************************************
Apex Class Name     : PCC_CreateDRProductUtilityHandler_V1
Version             : 
Created Date        : May 2023

Modification Log    :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Shraddha                May- 2023        Added a methods (getDDRPicklistValues) to fetch API values of given picklists
* Shivini                 30-sep-2024      Added WITH USER_MODE to SOQL and DML statements.
************************************************************************************************************************************************/

public with sharing class PCC_CreateDRProductUtilityHandler_V1 {
    
    public static final String LOG_ENTRY_ORIGIN   = 'PCC_CreateDesignRegistration';
    public static final String LOG_ENTRY_PROJECT  = 'DDR Registration';
    public static final String LOG_ENTRY_SCOPE    = 'Create DDR Records';
    public static final String LOG_ENTRY_SCOPE_1  = 'Fetch DDR Picklist Values';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_SEVERITY = 'High';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static Map<String, String> mapExtIdtoInvalidValMsg = new Map<String, String>();  
    public static final String INSERT_ACTION = PCC_Constants.INSERT_ACTION;
    public static final String UPDATE_ACTION = PCC_Constants.UPDATE_ACTION;
    public static final String DESIGN_REG = PCC_Constants.DESIGN_REG;
    public static final String DESIGN_REG_PROD = PCC_Constants.DESIGN_REG_PROD;
    public static final String SPECCODE = LabelConfiguration__mdt.getInstance('PCC_SpecCode_DRP').Value__c;
    public static final String PRODUCTSTATUS = LabelConfiguration__mdt.getInstance('PCC_ProdStatus_DRP').Value__c;
    public static final String CUSTOMERIND = LabelConfiguration__mdt.getInstance('PCC_CustomerIndStatus_DRP').Value__c;
    public static final String ELIGIBLE = LabelConfiguration__mdt.getInstance('PCC_Eligible_DRP').Value__c;
        
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
        List<String> listOfOrderingCd = new List<String>();
        List<String> listOfMMId = new List<String>();
        List<String> listOfoldMMId = new List<String>();
        Map<String, String> mapOfExtIdToDesignRegId = new Map<String, String>();
        Map<String,list<string>> mapIdTounexpected = new Map<String,list<string>>();
        //Map<String, String> mmIdToProductIdMap = new Map<String, String>();
        //Map<String, String> orderingCdToProductIdMap = new Map<String, String>();
        //List<Product_MM_Attribute_Mapping__c> listOfProductMMAtr = new List<Product_MM_Attribute_Mapping__c>();
        Productwrapper pWrp = new Productwrapper();
        List<String> validExternalIdValue = new List<String>();
        designRegDetailsWrapper drWrp = new designRegDetailsWrapper();
        List<Id> Drids=new List<Id>();
        Map<Id,String> namesDr;
        try{
            Integer count = 0;
            for(Object dr : listOfPayloads){
                String uniqueExtId;
                String extId;
                Map<String, Object> drMap = (Map<String, Object>)dr;    
                mapOfCountToDrmap.put(count, drMap);
                
                uniqueExtId = drMap.containsKey('externalId') ? String.valueOf(drMap.get('externalId')) + count : String.valueOf(count);
                extId = drMap.containsKey('externalId') ? String.valueOf(drMap.get('externalId')) : String.valueOf(count);
                //System.debug('UNIQ--> '+uniqueExtId+' --> '+extId);
                Boolean isReqFieldsMissing = false;
                
                if(!drMap.isEmpty()){
                    list<string> unExpValues =new List<String>();
                    for(string payloadLabel : drMap.keyset()){                       
                        if(!PCC_Constants.allowedFieldsPostDRP.contains(payloadLabel)  && !string.isEmpty(((string)drMap.get(payloadLabel)))){
                            unExpValues.add(payloadLabel);
                        }
                            mapIdTounexpected.put(uniqueExtId,unExpValues);
                    
                    }

                }
                if(mapIdTounexpected.isEmpty() || 
                   (mapIdTounexpected.containskey(uniqueExtId) && uniqueExtId !=null && (
                    (mapIdTounexpected.get(uniqueExtId).isEmpty() || mapIdTounexpected.get(uniqueExtId)==null)))){
                //put required fields that are missing in map 
                for (String fieldName : requiredFields) {                    
                    if(String.isBlank(String.valueOf(drMap.get(fieldName)))&& uniqueExtId != null){
                        if (mapExtIdToMissingFld.containsKey(uniqueExtId)) {
                            mapExtIdToMissingFld.get(uniqueExtId).add(fieldName);
                        } else  {
                            mapExtIdToMissingFld.put(uniqueExtId, new List<String> {fieldName});
                        } isReqFieldsMissing=true;
                    }
                }
                //System.debug('mapExtIdToMissingFld--> '+mapExtIdToMissingFld);
                if (uniqueExtId != null /*&& mapExtIdToMissingFld.isEmpty()*/  && !isReqFieldsMissing) { 
                    mapOfExtIdtoValidDDR.put(uniqueExtId, drMap); 
                    if(drMap.containskey('orderingCd') && drmap.get('orderingCd')!= null){
                        listOfOrderingCd.add(String.valueOf(drmap.get('orderingCd')));
                    }
                    if(drMap.containskey('mmId') && drmap.get('mmId')!= null){
                        listOfMMId.add(String.valueOf(drmap.get('mmId')));
                    }
                    if(drMap.containskey('designRegId') && drmap.get('designRegId')!= null && extId!= null){
                        mapOfExtIdToDesignRegId.put(extId, String.valueOf(drmap.get('designRegId')));
                    }
                    if(drMap.containskey('oldMMId') && drmap.get('oldMMId')!= null){
                        listOfoldMMId.add(String.valueOf(drmap.get('oldMMId')));
                    }
                }
                
            }
                count++;
            }
            
            //method to get partnerFaeEmails based on designRegId
            if(mapOfExtIdToDesignRegId!= null && !mapOfExtIdToDesignRegId.isEmpty()){
                drWrp = getOwnerIdsBasedOnDDRIds(mapOfExtIdToDesignRegId);
            }
            
            if(drWrp.mapOfExtIdToOwnerIds != null && !drWrp.mapOfExtIdToOwnerIds.isEmpty()){
                //PCC_checkDuplicateExtId returns list of valid and account level unique externalIds 
                validExternalIdValue = PCC_CreateDDRUtilityHandler.PCC_checkDuplicateExtId(drWrp.mapOfExtIdToOwnerIds, DESIGN_REG_PROD);
            }
            
            //System.debug('validExternalIdValue--> '+validExternalIdValue);
            //System.debug('listOfOrderingCd--->'+ listOfOrderingCd);
            //System.debug('listOfMMId--->'+ listOfMMId);
            
            if(listOfOrderingCd.size() > 0 || listOfMMId.size()>0  || listOfoldMMId.size() > 0){
                pWrp = getProductId(listOfOrderingCd, listOfMMId, listOfoldMMId);
            }
            
            //create DDR instance fot valid DDR's
            if (mapOfExtIdtoValidDDR.size()>0) {
                mapExtIdToValidDr = createDRProductInstance(mapOfExtIdtoValidDDR, pWrp, null, validExternalIdValue, drWrp.validDrIds, INSERT_ACTION, null);
                drProductListToInsert = mapExtIdToValidDr.values();
            }
            
           // Vinita's Changes -- for adding DR/DRP Name in response
            //insert records from payload that have an external id's
            if (!drProductListToInsert.isEmpty()) {
                Integer i = 0;
                for(Database.SaveResult sr: Database.insert(drProductListToInsert, false,AccessLevel.User_mode)){
                    if (sr.isSuccess()) {
                        Drids.add(sr.getId());
                    }
                    mapDrRecordSaveResult.put(drProductListToInsert[i], sr);
                    i++;
                }
            }
            namesDr=PCC_CreateDDRUtilityHandler.getNameDDR(Drids);
            //System.debug('mapDrRecordSaveResult--> '+mapDrRecordSaveResult);
            //get response of records that are successfully inserted and the records that have errors
           
            PCC_Wrapper.PCC_DRDetailsWrapper drProductWrp = PCC_CreateDDRUtilityHandler_V2.getDDRObjectResponses(mapIdTounexpected,mapOfCountToDrmap,mapExtIdToMissingFld, 
                                                                                                              mapExtIdToValidDr, mapExtIdtoInvalidValMsg, 
                                                                                                              mapDrRecordSaveResult, null,null, INSERT_ACTION, DESIGN_REG_PROD,namesDr);
            
            //get statusCode based on successful or failed record count
            res.statusCode = PCC_CreateDDRUtilityHandler.getStatusCode(listOfPayloads.size(), drProductWrp.successfulRecordCount, drProductWrp.failedRecordCount);
            
            //set responsebody
            res.responseBody = Blob.valueOf(JSON.serialize(drProductWrp.respList));
            
        }catch(exception ex){ Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY, '', '', '', 'PCC_CreateDRProductUtilityHandler_V1.createDDRProducts', '', ex);
        }
        return res;
    }
    
    
    /*****************************************************************************************************************
* Method Name: updateDDRProducts
* Date: /06/2023    
* Owner: Shraddha
* Description: This is a handler method to update DR products records based on the payload received
* Return: Returns RestResponse with successful and error messages to external systems
******************************************************************************************************************/
    Public static RestResponse updateDDRProducts(List<Object> listOfPayloads){
        RestResponse res = RestContext.response;
        Map<integer, Map<String, Object>> mapOfDRPPaylods = new Map<integer, Map<String, Object>>();
        Map<String, Map<String, Object>> mapOfRecIdtoDRP = new Map<String, Map<String, Object>>();
        List<Core_Design_Registration_Product__c> listOfValidDrp = new List<Core_Design_Registration_Product__c>();
        Map<String, Core_Design_Registration_Product__c> mapOfRecIdtoDRPInstance = new Map<String, Core_Design_Registration_Product__c>();
        List<String> listOfOrderingCd = new List<String>();
        List<String> listOfMMId = new List<String>();
        List<String> listOfOldMMId = new List<String>();
        Productwrapper pWrp = new Productwrapper();
        Map<Object, Database.SaveResult> mapDrpRecordSaveResult = new Map<Object, Database.SaveResult>(); 
        List<Core_Design_Registration_Product__c> drProductListToUpdate = new List<Core_Design_Registration_Product__c>();
        Map<String,String> mapOfRecIdToExtId = new Map<String,String>();
        Set<Id> validRecordIds = new Set<Id>();
        Map<Id, String> nonEditableDrpIds = new map<Id, String>();
        List<Id> Drids=new List<Id>();
        list<id> validDrpIds = new List<id>();
        Map<Id,String> namesDr;
        Map<String,list<string>> mapIdTounexpected = new Map<String,list<string>>();
        try {
            Integer count = 0;
            for(Object payload : listOfPayloads){
                Map<String, Object> drpMap = (Map<String, Object>)payload;
                String uniqueExtId = drpMap.containsKey('recordId')?(String)drpMap.get('recordId'):null;
                mapOfDRPPaylods.put(count, drpMap);
                if (drpMap.containsKey('recordId') && String.valueOf(drpMap.get('recordId')) !=null && String.isNotBlank(String.valueOf(drpMap.get('recordId')))) {
                    mapOfRecIdtoDRP.put(String.valueOf(drpMap.get('recordId')), drpMap);
                }
                list<string> unExpValues =new List<String>();
                if(uniqueExtId!=null && !mapOfRecIdtoDRP.isEmpty()){
                    for(string payloadLabel : drpMap.keyset()){
                    if(!PCC_Constants.allowedFieldsPutDRP.contains(payloadLabel)){
                        unExpValues.add(payloadLabel);    
                    }
                     //   if(!unExpValues.isEmpty())
                         mapIdTounexpected.put(uniqueExtId,unExpValues);
                }
                    
                }
                
                if(mapIdTounexpected.isEmpty() ||
                   (mapIdTounexpected.containskey(uniqueExtId) && uniqueExtId !=null && (
                      (mapIdTounexpected.get(uniqueExtId).isEmpty() || mapIdTounexpected.get(uniqueExtId)==null)))){
                
                //collect mmId and orderingCd to get ProductID's
                if(drpMap.containskey('mmId') && String.isNotBlank(String.valueOf(drpMap.get('mmId')))){
                    listOfMMId.add(String.valueOf(drpMap.get('mmId')));
                }else if(drpMap.containskey('orderingCd') && String.isNotBlank(String.valueOf(drpMap.get('orderingCd')))){
                    listOfOrderingCd.add(String.valueOf(drpMap.get('orderingCd')));
                }else if(drpMap.containskey('oldMMId') && String.isNotBlank(String.valueOf(drpMap.get('oldMMId')))){
                    listOfOldMMId.add(String.valueOf(drpMap.get('oldMMId')));
                }
                      }
                          count++;
            
            }
            
            if(listOfOrderingCd.size() > 0 || listOfMMId.size()>0 || listOfOldMMId.size() > 0){
                pWrp = getProductId(listOfOrderingCd, listOfMMId, listOfOldMMId);
            }
            
            
            //get the DRP list by passing recordId's from payload
            if(mapOfRecIdtoDRP.size() > 0){
                listOfValidDrp = [SELECT Id, Core_Design_Registration_Id__c, Core_Product_Id__c, Core_Full_Year_Qty__c,Core_Target_Resale_Amt__c, 
                                  Core_Comment_Txt__c, Core_Partner_Tracking_Cd__c, Core_External_Id__c, Core_Design_Product_Status_Nm__c
                                  FROM Core_Design_Registration_Product__c 
                                  WHERE Id IN: mapOfRecIdtoDRP.keySet() WITH USER_MODE];
            }
            
            if(listOfValidDrp.size() > 0){
                for(Core_Design_Registration_Product__c drp : listOfValidDrp){
                    mapOfRecIdToExtId.put(drp.Id, drp.Core_External_Id__c);
                   // if (drp.Core_Design_Product_Status_Nm__c == 'Approved' || drp.Core_Design_Product_Status_Nm__c == 'Rejected' || drp.Core_Design_Product_Status_Nm__c == 'Cancelled'
                   //                                                     || drp.Core_Design_Product_Status_Nm__c == 'Retired') {
                    List<String> DDRStatuses = LabelConfiguration__mdt.getInstance('PCC_DRP_Statuses').Value__c.split(':'); //sushmita
                    if (DDRStatuses.contains(drp.Core_Design_Product_Status_Nm__c)) {
                        nonEditableDrpIds.put(drp.Id, drp.Core_Design_Product_Status_Nm__c);
                    }
                    validDrpIds.add(drp.Id);
                }
            }
            
            //get valid record id's
            for(String recId : mapOfRecIdtoDRP.keySet()){
                if(mapOfRecIdToExtId.containsKey(recId)){
                    validRecordIds.add(recId);
                }
            }
            
            if (mapOfRecIdtoDRP.size() > 0) {
                mapOfRecIdtoDRPInstance = createDRProductInstance(mapOfRecIdtoDRP, pWrp, validRecordIds, null, null, UPDATE_ACTION, nonEditableDrpIds);
                drProductListToUpdate = mapOfRecIdtoDRPInstance.values();
            }
            
            // Vinita's Changes -- for adding DR/DRP Name in response
            //update records from payload that have an record id's
            if (!drProductListToUpdate.isEmpty()) {
                Integer i = 0;
                for(Database.SaveResult sr: Database.update(drProductListToUpdate, false, AccessLevel.User_mode)){
                    if (sr.isSuccess()) {
                        Drids.add(sr.getId());
                    }
                    mapDrpRecordSaveResult.put(drProductListToUpdate[i], sr);
                    i++;
                }
            }
           namesDr= PCC_CreateDDRUtilityHandler.getNameDDR(validDrpIds);
            
            //get response of records that are successfully inserted and the records that have errors
            PCC_Wrapper.PCC_DRDetailsWrapper drProductWrp = PCC_CreateDDRUtilityHandler_V2.getDDRObjectResponses(mapIdTounexpected,mapOfDRPPaylods , null, 
                                                                                                              mapOfRecIdtoDRPInstance, mapExtIdtoInvalidValMsg, 
                                                                                                              mapDrpRecordSaveResult, mapOfRecIdToExtId,null, UPDATE_ACTION, DESIGN_REG_PROD,namesDr);
            
            //get statusCode based on successful or failed record count
            res.statusCode = PCC_CreateDDRUtilityHandler.getStatusCode(listOfPayloads.size(), drProductWrp.successfulRecordCount, drProductWrp.failedRecordCount);
            
            //set responsebody
            res.responseBody = Blob.valueOf(JSON.serialize(drProductWrp.respList));
            
            
        }catch(exception ex){ Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY, '', '', '', 'PCC_CreateDRProductUtilityHandler_V1.updateDDRProducts', '', ex);
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
    public static Map<String, Core_Design_Registration_Product__c> createDRProductInstance( Map<String, Map<String, Object>> mapOfRecIdOrExtIdtoValidDDR, Productwrapper pWrp,Set<Id> validRecordIds, List<String> validExternalIdValue, Set<String> validDrIds, String action, Map<Id, String> nonEditableDrpIds){   
        Map<String, Core_Design_Registration_Product__c> mapIdToValidDr = new Map<String, Core_Design_Registration_Product__c>();
        Set<String> processedExternalIds = new Set<String>(); // Keep track of processed external IDs                                                    

        try{
            if(mapOfRecIdOrExtIdtoValidDDR.size() > 0){
                for(string str: mapOfRecIdOrExtIdtoValidDDR.keySet()){
                    String designId = mapOfRecIdOrExtIdtoValidDDR.get(str).containsKey('designRegId') ? String.valueOf(mapOfRecIdOrExtIdtoValidDDR.get(str).get('designRegId')) : null;
                    String quantity = mapOfRecIdOrExtIdtoValidDDR.get(str).containsKey('quantity') ? String.valueOf(mapOfRecIdOrExtIdtoValidDDR.get(str).get('quantity')) : null;
                    String orderingCd = mapOfRecIdOrExtIdtoValidDDR.get(str).containsKey('orderingCd') ? String.valueOf(mapOfRecIdOrExtIdtoValidDDR.get(str).get('orderingCd')) : null;
                    String mmId = mapOfRecIdOrExtIdtoValidDDR.get(str).containsKey('mmId') ? String.valueOf(mapOfRecIdOrExtIdtoValidDDR.get(str).get('mmId')) : null;
                    String oldMMId = mapOfRecIdOrExtIdtoValidDDR.get(str).containsKey('oldMMId') ? String.valueOf(mapOfRecIdOrExtIdtoValidDDR.get(str).get('oldMMId')) : null;
                    String targetResalePrice = mapOfRecIdOrExtIdtoValidDDR.get(str).containsKey('targetResalePrice') ? String.valueOf(mapOfRecIdOrExtIdtoValidDDR.get(str).get('targetResalePrice')) : null;
                    String comments = mapOfRecIdOrExtIdtoValidDDR.get(str).containsKey('comments') ? String.valueOf(mapOfRecIdOrExtIdtoValidDDR.get(str).get('comments')) : null;
                    String partnerTrackingNumber = mapOfRecIdOrExtIdtoValidDDR.get(str).containsKey('partnerTrackingNumber') ? String.valueOf(mapOfRecIdOrExtIdtoValidDDR.get(str).get('partnerTrackingNumber')) : null;
                    String externalId = mapOfRecIdOrExtIdtoValidDDR.get(str).containsKey('externalId') ? String.valueOf(mapOfRecIdOrExtIdtoValidDDR.get(str).get('externalId')) : null;
                    
                    Core_Design_Registration_Product__c drProduct = new Core_Design_Registration_Product__c();
                    if (action == INSERT_ACTION) {
                        drProduct.Core_Submission_Type__c = 'M2M'; 
                        if(designId != null && validDrIds.contains(designId)){
                            drProduct.Core_Design_Registration_Id__c = designId;
                        }else {
                            mapExtIdtoInvalidValMsg.put(str,  LabelConfiguration__mdt.getInstance('PCC_IncorrectDesignRegId_DRP').Value__c+designId);
                            // mapExtIdtoInvalidValMsg.put(str, 'Provided Design Registration ID is incorrect: '+designId);
                            continue;
                        }
                        
                        if(!String.isBlank(externalId)){
                            if (processedExternalIds.contains(externalId)) { //if the external id is used in the payload by more than 1 record.
                                String errMsg = LabelConfiguration__mdt.getInstance('PCC_RepeatingExtIdSamePayload_PostDDR').Value__c.replace('{1}',externalId);
                                mapExtIdtoInvalidValMsg.put(str, errMsg);
                                continue;
                            }
                            if (validExternalIdValue != null && validExternalIdValue.contains(externalId)) {
                                // Processed external IDs are added to the set here
                                processedExternalIds.add(externalId);
                                drProduct.Core_External_Id__c = externalId;
                            } 
                            else  {
                                String errMsg = LabelConfiguration__mdt.getInstance('PCC_RepeatingExtIdSamePayload_PostDDR').Value__c.replace('{1}',externalId);
                                mapExtIdtoInvalidValMsg.put(str, errMsg);
                                continue;
                            }
                            //System.debug('processedExternalIds----> '+processedExternalIds);
                        }
                    }
                    
                    if (action == UPDATE_ACTION) {
                        if (validRecordIds.contains(str)) {
                            drProduct.Id = str;
                        }else {
                            mapExtIdtoInvalidValMsg.put(str, LabelConfiguration__mdt.getInstance('PCC_InvalidRecordId_PutDRP').Value__c);
                            continue;
                        }
                        
                        if (designId != null) {
                            mapExtIdtoInvalidValMsg.put(str,LabelConfiguration__mdt.getInstance('PCC_NonEditableDesignReg_PutDRP').Value__c);
                            continue;
                        }
                        
                        if (nonEditableDrpIds!= null && nonEditableDrpIds.containsKey(str)) {
                            mapExtIdtoInvalidValMsg.put(str,LabelConfiguration__mdt.getInstance('PCC_NonUpdatable_PutDRP').Value__c+' '+nonEditableDrpIds.get(str) + '.');
                            continue;
                        }
                    }
                    
                    //get productID to create DRP record based on mmId or orderingCd
                    if (String.isNotBlank(mmId)) {
                        if (pWrp.mmIdToProductIdMap.containsKey(mmId)) {
                            id productId = pWrp.mmIdToProductIdMap.get(mmId);
                            string drEligible = drEligible(pWrp,productId);
                            if (drEligible==SPECCODE || drEligible == PRODUCTSTATUS) {
                                String errMsg = LabelConfiguration__mdt.getInstance('PCC_ProductSubmission_DRP').Value__c.replace('{1}',drEligible);
                                mapExtIdtoInvalidValMsg.put(str, errMsg);
                                continue;
                            }else if (drEligible==CUSTOMERIND) {
                                String errMsg = LabelConfiguration__mdt.getInstance('PCC_CustomerInd_DRP').Value__c;
                                mapExtIdtoInvalidValMsg.put(str, errMsg);
                                continue;
                            }
                            else {
                                drProduct.Core_Product_Id__c = productId;
                                drProduct.MMID_or_Ordering_code__c = pWrp.uniqueIdToAttributeMap.containsKey(mmId) ? pWrp.uniqueIdToAttributeMap.get(mmId) : null;
                            }
                        }else {
                            mapExtIdtoInvalidValMsg.put(str, LabelConfiguration__mdt.getInstance('PCC_NoProdForMMID_DRP').Value__c);
                            continue;
                        }
                    }else if (String.isNotBlank(orderingCd)) {
                        if (pWrp.orderingCdToProductIdMap.containsKey(orderingCd)) {
                            id productId = pWrp.orderingCdToProductIdMap.get(orderingCd);
                            string drEligible = drEligible(pWrp,productId);
                            if (drEligible==SPECCODE || drEligible == PRODUCTSTATUS) {
                                String errMsg = LabelConfiguration__mdt.getInstance('PCC_ProductSubmission_DRP').Value__c.replace('{1}',drEligible);
                                mapExtIdtoInvalidValMsg.put(str, errMsg);
                                continue;
                            }else if (drEligible==CUSTOMERIND) {
                                String errMsg = LabelConfiguration__mdt.getInstance('PCC_CustomerInd_DRP').Value__c;
                                mapExtIdtoInvalidValMsg.put(str, errMsg);
                                continue;
                            }else {                         
                                drProduct.Core_Product_Id__c = productId;
                                drProduct.MMID_or_Ordering_code__c = pWrp.uniqueIdToAttributeMap.containsKey(orderingCd) ? pWrp.uniqueIdToAttributeMap.get(orderingCd) : null;
                            }
                        }else {
                            mapExtIdtoInvalidValMsg.put(str, LabelConfiguration__mdt.getInstance('PCC_NoProdForOrdCd_DRP').Value__c);
                            continue;
                        }
                    }else if (String.isNotBlank(oldMMId)) {
                        if (pWrp.oldMMIdToProductIdMap.containsKey(oldMMId)) {
                            id productId = pWrp.oldMMIdToProductIdMap.get(oldMMId);
                            string drEligible = drEligible(pWrp,productId);
                            if (drEligible==SPECCODE || drEligible == PRODUCTSTATUS) {
                                String errMsg = LabelConfiguration__mdt.getInstance('PCC_ProductSubmission_DRP').Value__c.replace('{1}',drEligible);
                                mapExtIdtoInvalidValMsg.put(str, errMsg);
                                continue;
                            }else if (drEligible==CUSTOMERIND) {
                                String errMsg = LabelConfiguration__mdt.getInstance('PCC_CustomerInd_DRP').Value__c;
                                mapExtIdtoInvalidValMsg.put(str, errMsg);
                                continue;
                            }else {
                                drProduct.Core_Product_Id__c = productId;   
                                drProduct.MMID_or_Ordering_code__c = pWrp.uniqueIdToAttributeMap.containsKey(oldMMId) ? pWrp.uniqueIdToAttributeMap.get(oldMMId) : null;
                            }
                        }else {
                            mapExtIdtoInvalidValMsg.put(str, LabelConfiguration__mdt.getInstance('PCC_NoProdForOldMMId_DRP').Value__c);
                            continue;
                        }
                    }else if (action == INSERT_ACTION) {
                        mapExtIdtoInvalidValMsg.put(str,LabelConfiguration__mdt.getInstance('PCC_CreateDRP_DRP').Value__c);
                        continue;
                    }              
                    
                    if(quantity!= null){
                        try{
                            drProduct.Core_Full_Year_Qty__c = Integer.valueOf(quantity);
                        }
                        catch(exception ex) {
                            mapExtIdtoInvalidValMsg.put(str,LabelConfiguration__mdt.getInstance('PCC_QtyIntegerFrmt_DRP').Value__c );
                            continue;
                        }
                    }
                    
                    if(targetResalePrice!= null){
                        try{
                            drProduct.Core_Target_Resale_Amt__c = decimal.valueOf(targetResalePrice);
                        }catch(exception ex){
                            mapExtIdtoInvalidValMsg.put(str,LabelConfiguration__mdt.getInstance('PCC_TargetResalePrice_DRP').Value__c);
                            continue;
                        }
                    }
                    
                    if(comments!= null){
                        drProduct.Core_Comment_Txt__c = comments;
                    }
                    
                    if(partnerTrackingNumber!= null){
                        drProduct.Core_Partner_Tracking_Cd__c = partnerTrackingNumber;
                    }
                    
                    mapIdToValidDr.put(str, drProduct);
                }
            }
        }catch (Exception ex) { Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateDRProductUtilityHandler_V1.createDRProductInstance' ,'' ,ex); 
        }
        //System.debug('mapIdToValidDr-->'+mapIdToValidDr);
        return mapIdToValidDr;
    }
    
    
    /*****************************************************************************************************************
* Method Name: getProductId
* Date: 07/2023    
* Owner: Shraddha
* Description: This is a method to get productId based on MMId and ordering code
* Return: Returns Product_MM_Attribute_Mapping__c List
******************************************************************************************************************/ 
    
    Public Static Productwrapper getProductId(List<String> listOfOrderingCd, List<String> listOfmmId, List<String> listOfoldMMId){ 
        Map<String, String> mmIdToProductIdMap = new Map<String, String>();
        Map<String, String> orderingCdToProductIdMap = new Map<String, String>();
        Map<String, String> oldMMIdToProductIdMap = new Map<String, String>();
        Map<String, String> specCdToProductIdMap = new Map<String, String>();
        Map<String, String> custIndToProductIdMap = new Map<String, String>();
        Map<String, String> prodStatusToProductIdMap = new Map<String, String>();
        Map<String, Id> uniqueIdToAttributeMap = new Map<String, Id>();
        
        Productwrapper pWrp = new Productwrapper();
        
        List<Product_MM_Attribute_Mapping__c> listOfProductMMAtr = [SELECT Id, Ordering_Code__c, Name,MMID__c,Spec_Code__c,
                                                                    Custom_Indicator__c,Product_Status__c,L5_Product__r.id,
                                                                    L5_Product__r.Core_Product_Type__c, L4_Product__c, 
                                                                    L4_Product__r.id, L4_Product__r.Core_Sales_Visible_Flag__c, 
                                                                    L4_Product__r.Core_Design_Registration_Eligible_Ind__c, L4_Product__r.IsActive 
                                                                    FROM Product_MM_Attribute_Mapping__c
                                                                    WHERE (L4_Product__c != null OR L5_Product__c != null)
								    AND (Ordering_Code__c IN: listOfOrderingCd OR Name IN: listOfmmId OR MMID__c IN: listOfoldMMId) WITH USER_MODE];
                                                                    /*WHERE ((L4_Product__c != null
                                                                            AND L4_Product__r.Core_Sales_Visible_Flag__c= true 
                                                                            AND L4_Product__r.Core_Design_Registration_Eligible_Ind__c = true 
                                                                            AND L4_Product__r.IsActive = true)
                                                                           OR (L5_Product__c != null
                                                                               AND L5_Product__r.Core_Sales_Visible_Flag__c= true 
                                                                               AND L5_Product__r.Core_Design_Registration_Eligible_Ind__c = true 
                                                                               AND L5_Product__r.IsActive = true))
                                                                    AND (Ordering_Code__c IN: listOfOrderingCd OR Name IN: listOfmmId)]*/
        if(listOfProductMMAtr.size() > 0){
            for(Product_MM_Attribute_Mapping__c pm: listOfProductMMAtr){
                if(pm.L4_Product__r.id != null){
                    mmIdToProductIdMap.put(pm.Name, pm.L4_Product__r.id);
                    orderingCdToProductIdMap.put(pm.Ordering_Code__c, pm.L4_Product__r.id);
                    oldMMIdToProductIdMap.put(pm.MMID__c, pm.L4_Product__r.id);
                    specCdToProductIdMap.put(pm.L4_Product__r.id,pm.Spec_Code__c);
                    custIndToProductIdMap.put(pm.L4_Product__r.id,pm.Custom_Indicator__c);
                    prodStatusToProductIdMap.put(pm.L4_Product__r.id,pm.Product_Status__c);
                }
                else if(pm.L5_Product__r.id != null && pm.L5_Product__r.Core_Product_Type__c == 'Intel® FPGAs'){
                    mmIdToProductIdMap.put(pm.Name, pm.L5_Product__r.id);
                    orderingCdToProductIdMap.put(pm.Ordering_Code__c, pm.L5_Product__r.id);
                    oldMMIdToProductIdMap.put(pm.MMID__c, pm.L5_Product__r.id);
                    specCdToProductIdMap.put(pm.L5_Product__r.id,pm.Spec_Code__c);
                    custIndToProductIdMap.put(pm.L5_Product__r.id,pm.Custom_Indicator__c);
                    prodStatusToProductIdMap.put(pm.L5_Product__r.id,pm.Product_Status__c);
                }

		uniqueIdToAttributeMap.put(pm.Name, pm.Id);
                uniqueIdToAttributeMap.put(pm.Ordering_Code__c, pm.Id);
                uniqueIdToAttributeMap.put(pm.MMID__c, pm.Id);
            }
        }
        pWrp.mmIdToProductIdMap = mmIdToProductIdMap;
        pWrp.orderingCdToProductIdMap = orderingCdToProductIdMap;
        pWrp.oldMMIdToProductIdMap = oldMMIdToProductIdMap;
        pWrp.specCdToProductIdMap = specCdToProductIdMap;
        pWrp.prodStatusToProductIdMap = prodStatusToProductIdMap;
        pWrp.custIndToProductIdMap = custIndToProductIdMap;
	pWrp.uniqueIdToAttributeMap = uniqueIdToAttributeMap;
        
        return pWrp;
    }
    
    Public Class Productwrapper {
        Public Map<String, String> mmIdToProductIdMap {get;set;}
        Public Map<String, String> orderingCdToProductIdMap {get;set;}
        Public Map<String, String> oldMMIdToProductIdMap {get;set;}
        Public Map<String, String> specCdToProductIdMap {get;set;}
        Public Map<String, String> prodStatusToProductIdMap {get;set;}
        Public Map<String, String> custIndToProductIdMap {get;set;}
        Public Map<String, Id> uniqueIdToAttributeMap {get;set;}
    }
    
    Public static PCC_Wrapper.PCC_restAPIDDRDetailsWrapper setResponseBody(Integer StCodeParam, String StatusParam, Integer ErrCodeParam, PCC_Wrapper.PCC_DDRDetailsWrapper ResBodyParam, String RecIdParam, String RecordName) {
        PCC_Wrapper.PCC_restAPIDDRDetailsWrapper respWrp = new PCC_Wrapper.PCC_restAPIDDRDetailsWrapper();
        respWrp.StatusCode = StCodeParam;
        respWrp.Status = StatusParam;
        respWrp.ErrorCode = ErrCodeParam;
        respWrp.ResponseBody = ResBodyParam;
        respWrp.RecordId = RecIdParam; 
        respWrp.Name=RecordName;
        return respWrp;
    }
    
    public static PCC_Wrapper.PCC_DDRDetailsWrapper setDDRProductWrapper(Core_Design_Registration_Product__c drProduct){
        PCC_Wrapper.PCC_DDRDetailsWrapper ddrProductWrp = new PCC_Wrapper.PCC_DDRDetailsWrapper();
        try {
            ddrProductWrp.id = drProduct.Id;
	    ddrProductWrp.name = drProduct.Name;
            ddrProductWrp.designRegId = drProduct.Core_Design_Registration_Id__c;
            ddrProductWrp.productId = drProduct.Core_Product_Id__c;
            ddrProductWrp.quantity = drProduct.Core_Full_Year_Qty__c;
            ddrProductWrp.retiredAsOf = drProduct.Core_Retired_As_Of_Dt__c;
            ddrProductWrp.externalId = drProduct.Core_External_Id__c;   
            ddrProductWrp.targetResaleAmt = drProduct.Core_Target_Resale_Amt__c;
            ddrProductWrp.targetResalePriceNote = drProduct.DDR_Target_Resale_Price_Note__c;
            ddrProductWrp.status = drProduct.Core_Design_Product_Status_Nm__c;
            ddrProductWrp.comment = drProduct.Core_Comment_Txt__c;
            ddrProductWrp.partnerTrackingNumber = drProduct.Core_Partner_Tracking_Cd__c;
            ddrProductWrp.productListPrice = drProduct.Core_Product_List_Price_Amt__c;
            ddrProductWrp.fullYearValueAmt = drProduct.Core_Full_Year_Value_Amt__c;
            ddrProductWrp.opportunityProductId = drProduct.Core_Opportunity_Product_Id__c;
            if(drProduct.DDR_Product_Mappings__r != null && !drProduct.DDR_Product_Mappings__r.isEmpty()){
                PCC_DDR_L5_Product_Mapping__c ddrL5Product = drProduct.DDR_Product_Mappings__r;
                ddrProductWrp.orderingId = ddrL5Product.PCC_Ordering_Cd__c;
                ddrProductWrp.mmId = ddrL5Product.PCC_MM_ID__c;
                ddrProductWrp.oldMMId = ddrL5Product.PCC_Old_MM_ID__c;
                ddrProductWrp.l4ProductName = ddrL5Product.PCC_L4_Product_Name__c;
                ddrProductWrp.l5ProductName = ddrL5Product.PCC_L5_Product_Name__c;  
            }
        }
        catch (Exception ex) { Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateDRProductUtilityHandler_V1' ,'' ,ex); 
        }
        return ddrProductWrp;
    } 
    
    Public static PCC_Wrapper.PCC_restAPIl4l5DetailsWrapper setResponseBodyForl4l5Product(Integer StCodeParam, String StatusParam, Integer ErrCodeParam, PCC_Wrapper.PCC_l4l5DetailsWrapper ResBodyParam, String RecIdParam){
        PCC_Wrapper.PCC_restAPIl4l5DetailsWrapper respWrp = new PCC_Wrapper.PCC_restAPIl4l5DetailsWrapper();
        respWrp.StatusCode = StCodeParam;
        respWrp.Status = StatusParam;
        respWrp.ErrorCode = ErrCodeParam;
        respWrp.ResponseBody = ResBodyParam;
        respWrp.RecordId = RecIdParam;    
        return respWrp;
    }
    
    Public static PCC_Wrapper.PCC_l4l5DetailsWrapper setl4l5Wrapper(Product_MM_Attribute_Mapping__c l4l5mapping){
        PCC_Wrapper.PCC_l4l5DetailsWrapper l4l5Wrp = new PCC_Wrapper.PCC_l4l5DetailsWrapper();
        try{
            l4l5Wrp.mmid = l4l5mapping.Name;
            l4l5Wrp.orderingCode = l4l5mapping.Ordering_Code__c;
            l4l5Wrp.oldMMid = l4l5mapping.MMID__c;
            l4l5Wrp.l4Product = l4l5mapping.L4_Product__r.Name;
            l4l5Wrp.l5Product = l4l5mapping.L5_Product__r.Name;
        }catch (Exception ex){ Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateL4L5ProductsDetails_V1' ,'' ,ex); 
        }
        return l4l5Wrp;
    }
/*****************************************************************************************************************
* Method Name: getOwnerIdsBasedOnDDRIds
* Date: 08/2023    
* Owner: Shraddha
* Description: This is a method to get ownerIds based on designRegId
* Return: Returns designRegDetailsWrapper with ownerIds and valid designReg Ids
******************************************************************************************************************/
    Public static designRegDetailsWrapper getOwnerIdsBasedOnDDRIds(Map<String, String> mapOfExtIdToDesignRegId){
        
        Map<String, String> mapOfDdrToOwnerIds = new Map<String, String>();
        Map<String, String> mapOfExtIdToOwnerIds = new Map<String, String>();
        designRegDetailsWrapper drWrp = new designRegDetailsWrapper();

        //System.debug('mapOfExtIdToDesignRegId.values()--->'+mapOfExtIdToDesignRegId.values());
        
        for(Core_Design_Registration__c ddr : [SELECT id, OwnerId FROM Core_Design_Registration__c 
                                               WHERE Id IN: mapOfExtIdToDesignRegId.values() WITH USER_MODE]
           ){
               mapOfDdrToOwnerIds.put(ddr.Id, ddr.OwnerId);
           }

        //System.debug('mapOfDdrToOwnerIds--->'+mapOfDdrToOwnerIds);
        
        for(String str : mapOfExtIdToDesignRegId.keySet()){
            String ddrID = mapOfExtIdToDesignRegId.get(str);
            if(mapOfDdrToOwnerIds.containsKey(ddrID)){
                 mapOfExtIdToOwnerIds.put(str, mapOfDdrToOwnerIds.get(ddrID));
            }
        }
        //System.debug('mapOfExtIdToOwnerIds-->'+mapOfExtIdToOwnerIds);     
        
        drWrp.mapOfExtIdToOwnerIds = mapOfExtIdToOwnerIds;
        drWrp.validDrIds =  mapOfDdrToOwnerIds.keySet();
        
        return drWrp;
    }
    
    Public class designRegDetailsWrapper{
        Public Map<String, String> mapOfExtIdToOwnerIds{get;set;}
        Public Set<String> validDrIds{get;set;}
        
    }
    
    public static String drEligible(Productwrapper pWrp,id productId) {
        String prodstatus='';
        if (pWrp.specCdToProductIdMap.containsKey(productId) &&
           (String.isNotBlank(pWrp.specCdToProductIdMap.get(productId))) &&
           (((pWrp.specCdToProductIdMap.get(productId)).touppercase()).startsWith('Q'))) {
               prodstatus=SPECCODE; 
           }else if (pWrp.prodStatusToProductIdMap.containsKey(productId) &&
           String.isNotBlank(pWrp.prodStatusToProductIdMap.get(productId)) &&
           (((pWrp.prodStatusToProductIdMap.get(productId)).touppercase().contains('RT')) || 
              ((pWrp.prodStatusToProductIdMap.get(productId)).touppercase()).contains('OB'))) {
               prodstatus=PRODUCTSTATUS;
           }else if (pWrp.custIndToProductIdMap.containsKey(productId) &&
           String.isNotBlank(pWrp.custIndToProductIdMap.get(productId)) &&
           (((pWrp.custIndToProductIdMap.get(productId)).touppercase())=='Y' || ((pWrp.custIndToProductIdMap.get(productId)).touppercase())=='O')) {
               prodstatus=CUSTOMERIND;
           }else {
               prodstatus=ELIGIBLE;
           }
        return prodstatus;
    }
    
}