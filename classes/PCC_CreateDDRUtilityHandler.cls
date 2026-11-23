/*************************************************************************************************************************************
Apex Class Name     : PCC_CreateDDRUtilityHandler
Version             : 
Created Date        : May 2023
Descrpition         : Utility handler of PCC_CreateDesignRegistrationUtility_V1 class

Modification Log    :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Shraddha                May- 2023        Added a methods to fetch API values of given picklists
* Shraddha                June - 2023      Added methods to get customise error responses
************************************************************************************************************************************************/

public class PCC_CreateDDRUtilityHandler {
    public static final String LOG_ENTRY_ORIGIN   = 'PCC_CreateDesignRegistration';
    public static final String LOG_ENTRY_PROJECT  = 'DDR Registration';
    public static final String LOG_ENTRY_SCOPE    = 'Create DDR Records';
    public static final String LOG_ENTRY_SCOPE_1  = 'Fetch DDR Picklist Values';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_SEVERITY = 'High';
    public static final String LOG_ENTRY_INFO     = 'info';    
    public static Map<String, String> mapExtIdtoInvalidValMsg = new Map<String, String>();  
    
    /*****************************************************************************************************************
* Method Name: getPicklistValuesMap
* Date: 04/05/2023    
* Description: This method will return picklist values of given picklist fields
* Dev: Shraddha M
* Return: returns Map of picklist field to picklist values
******************************************************************************************************************/
    public static Map<String, List<PCC_Wrapper.PCC_PicklistWrapper>> getPicklistValuesMap(String objectName, Map<String, String> mapOfPicklist) {  
        Map<String, List<PCC_Wrapper.PCC_PicklistWrapper>> picklistValuesMap = new Map<String, List<PCC_Wrapper.PCC_PicklistWrapper>>();
        try {
            Schema.DescribeSObjectResult describe = Schema.getGlobalDescribe().get(objectName).getDescribe();
            // Get the picklist values and add them to the picklistValuesMap
            if(mapOfPicklist != null && !mapOfPicklist.isEmpty()) {
                for (String apiName : mapOfPicklist.keySet()) {
                    List<PCC_Wrapper.PCC_PicklistWrapper> pickListWrpList = new List<PCC_Wrapper.PCC_PicklistWrapper>(); // initialize here
                    Schema.DescribeFieldResult picklistDescribe = describe.fields.getMap().get(apiName).getDescribe();
                    for (Schema.PicklistEntry entry : picklistDescribe.getPicklistValues()) {
                        PCC_Wrapper.PCC_PicklistWrapper pl = new PCC_Wrapper.PCC_PicklistWrapper();
                        pl.Label = entry.getLabel();
                        pl.ApiName = entry.getValue();
                        //pl.IsActive = entry.isActive();
                        pickListWrpList.add(pl);
                    }
                    picklistValuesMap.put(mapOfPicklist.get(apiName), pickListWrpList);
                }
            }
        } catch (Exception ex) {
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateDesignRegistrationUtility' ,'' ,ex); 
        }
        return picklistValuesMap;
    }
    
    
    /*****************************************************************************************************************
* Method Name: getDependentFields
* Date: 04/05/2023    
* Description: This method will return Wrapper of controlling value to it's corresponding dependent fields with label and API names
* Dev: Shraddha M
* Return: returns Wrapper of controlling value to Dependent values
******************************************************************************************************************/
    public static Map<String, List<PCC_Wrapper.PCC_PicklistWrapper>> getDependentFields(String ObjectName, String dependentField, String controllingValue, Schema.sObjectField ControllingField){
        Map<String, List<PCC_Wrapper.PCC_PicklistWrapper>> dependentPicklistValues = new Map<String,List<PCC_Wrapper.PCC_PicklistWrapper>>();
        try {
            List<PCC_Wrapper.PCC_PicklistWrapper> pickListWrpList = new List<PCC_Wrapper.PCC_PicklistWrapper>();
            List<Schema.PicklistEntry> dependentEntries = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().get(dependentField).getDescribe().getPicklistValues();
            List<Schema.PicklistEntry> controlEntries = ControllingField.getDescribe().getPicklistValues();
            String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
            if(controlEntries.size() > 0 && dependentEntries.size()>0){
                for (Schema.PicklistEntry entry : dependentEntries) {
                    //checks whether the picklist value is active and whether it has a corresponding valid bit set
                    if (String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                        
                        //splits the validFor attribute in base64chars list by assigning the result of JSON.serialize method on the 'validFor' attribute of entry to a string
                        List<String> base64chars = String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                        
                        for (Integer index = 0; index < controlEntries.size() ; index++) {
                            //assigns a controlValue variable as either the value at the given index of controlEntries, or a default of "null" if this value is not active
                            Object controlValue = controlEntries == null ? (Object)(index == 1) : controlEntries[index].getValue();
                            if(controlValue == controllingValue){
                                Integer bitIndex = index / 6;
                                if (bitIndex > base64chars.size() - 1) {
                                    break;
                                }
                                Integer bitShift = 5 - Math.mod(index, 6);
                                
                                //performs a bitwise AND operation on the character from base64chars and a shifted binary digit based on the value of bitShift.
                                if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                                    continue;
                                if (!dependentPicklistValues.containsKey((String) controlValue)) {
                                    dependentPicklistValues.put((String) controlValue, new List<PCC_Wrapper.PCC_PicklistWrapper>());
                                }
                                PCC_Wrapper.PCC_PicklistWrapper pl = new PCC_Wrapper.PCC_PicklistWrapper();
                                pl.Label = entry.getLabel();
                                pl.ApiName = entry.getValue();
                                //pl.IsActive = entry.isActive();
                                dependentPicklistValues.get((String) controlValue).add(pl);
                            } 
                        }
                    }
                }
            }
        } catch (Exception ex) {
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateDesignRegistrationUtility' ,'' ,ex); 
        }
        System.debug('dependentPicklistValues'+dependentPicklistValues);
        return dependentPicklistValues;
    }
    
    /*****************************************************************************************************************
* Method Name: getDependentvaluesList
* Date: 04/05/2023    
* Description: This method will return map of controlling value to it's corresponding dependent fields
* Dev: Shraddha M
* Return: returns Map of controlling value to Dependent values
******************************************************************************************************************/
    public static Map<String, List<String>> getDependentvaluesList(String ObjectName,String dependToken) {
        List<Schema.PicklistEntry> dependentEntries = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().get(dependToken).getDescribe().getPicklistValues();
        Schema.sObjectField controlToken = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().get(dependToken).getDescribe().getController();
        
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
    
    
    /*****************************************************************************************************************
* Method Name: createDesignRegistrationRec
* Date: 06/2023    
* Owner: Sushmita/Shraddha
* Description: This is a handler method to Create DDR/ create DR products records based on the payload received
* Return: Returns RestResponse with successful and error messages to external systems
******************************************************************************************************************/
    public static RestResponse createDesignRegistrationRec(List<Object> listOfPayloads){
        RestResponse res = RestContext.response;
        Map<String, Core_Design_Registration__c> mapExtIdToValidDr = new Map<String, Core_Design_Registration__c>();
        List<Core_Design_Registration__c> ddrListToInsert = new List<Core_Design_Registration__c>();
        Map<String, List<String>> mapExtIdToMissingFld = new Map<String, List<String>>();
        Map<Integer, Map<String, Object>> mapOfCountToDrmap = new Map<Integer, Map<String, Object>>();
        Map<String, Map<String, Object>> mapOfExtIdtoValidDDR = new Map<String, Map<String, Object>>();
        List<String> requiredFields = Label.PCC_Create_DDR_Required_Fields.split(',');
        Map<Object, Database.SaveResult> mapDrRecordSaveResult = new Map<Object, Database.SaveResult>();  
        System.debug('ListOfPayload--> '+listOfPayloads);
        Map<Id,Core_Design_Registration__c> mapExistingDDR = new Map<Id,Core_Design_Registration__c>();
        List<String> partnerFAEMailToCheck = new List<String>();
        Map<String, String> partnerFAEtoUser = new Map<String, String>();
        
        try{
            Integer count = 0;
            for(Object dr : listOfPayloads){
                Map<String, Object> drMap = (Map<String, Object>)dr;    
                mapOfCountToDrmap.put(count, drMap);
                
                String uniqueExtId = (String)drMap.get('uniqueId') + count;
                String extId = (String)drMap.get('uniqueId');
                Boolean isReqFieldsMissing = false;
                System.debug('uniqueExtId--> '+uniqueExtId);
                System.debug('extId--> '+extId);
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
                    if(drMap.containsKey('partnerFAEEmail')){
                        partnerFAEMailToCheck.add((string)drMap.get('partnerFAEEmail'));
                    }
                }
                count++;
            }
            
            if(partnerFAEMailToCheck.size()>0){
                partnerFAEtoUser = PCC_checkValidPartnerFAE(partnerFAEMailToCheck);
            }
            
            System.debug('mapOfExtIdtoValidDDR--->'+mapOfExtIdtoValidDDR);
            //create DDR instance fot valid DDR's
            if(mapOfExtIdtoValidDDR.size()>0){ 
                mapExtIdToValidDr = createDRInstance(mapOfExtIdtoValidDDR,'Insert', mapExistingDDR, partnerFAEtoUser);
                ddrListToInsert = mapExtIdToValidDr.values();
            }
            
            System.debug('mapExtIdToValidDr--->'+mapExtIdToValidDr);
            //insert records from payload that have an external id's
            if (!ddrListToInsert.isEmpty()) {
                Integer i = 0;
                for(Database.SaveResult sr: Database.insert(ddrListToInsert, false)){
                    mapDrRecordSaveResult.put(ddrListToInsert[i], sr);
                    i++;
                }
            }
            
            //get response of records that are successfully inserted and the records that have errors
            PCC_Wrapper.PCC_DRDetailsWrapper drProductWrp = getDDRObjectResponses(mapOfCountToDrmap , mapExtIdToMissingFld, mapExtIdToValidDr, 
                                                                                  mapExtIdtoInvalidValMsg, mapDrRecordSaveResult, null, null, 'Insert');
            
            //get statusCode based on successful or failed record count
            res.statusCode = getStatusCode(listOfPayloads.size(), drProductWrp.successfulRecordCount, drProductWrp.failedRecordCount);
            
            //set responsebody
            res.responseBody = Blob.valueOf(JSON.serialize(drProductWrp.respList));
            
        }catch(exception ex){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY, '', '', '', 'PCC_CreateDesignRegistrationUtility_V1', '', ex);
        }
        return res;
    }
    
    /*****************************************************************************************************************
* Method Name: updateDesignRegistrationRecords
* Date: 07/2023  
* Description: This is a handler method to Update DDR records based on the payload received
* Return: Returns RestResponse with successful and error messages to external systems
******************************************************************************************************************/
    public static RestResponse updateDesignRegistrationRecords(List<Object> DDRWrapList){
        RestResponse res = RestContext.response;
        Map<Object, Database.SaveResult> mapDrRecordSaveResult = new Map<Object, Database.SaveResult>();  
        Map<String,Map<String,Object>> mapRecIdTODRList = new Map<String,Map<String,Object>>();
        Map<String,String> mapOfIdToErrMsg = new Map<String,String>();
        Map<String,String> mapOfRecIdToExtId = new Map<String,String>();
        Map<String,String> mapOfExtIdToRecId = new Map<String,String>();
        List<Core_Design_Registration__c> validDRList = new List<Core_Design_Registration__c>();
        Map<Id,Core_Design_Registration__c> existingDDR = new Map<Id,Core_Design_Registration__c>();
        List<String> requiredFields = Label.PCC_Create_DDR_Required_Fields.split(',');
        Map<String, String> drProductLabelToApiMap = PCC_Constants.drProductLabelToApiMap;
        Map<String, String> drProductApiToLabelMap = PCC_Constants.drProductApiToLabelMap;
        map<String,Map<String,Object>> mapIdToWrapMap = new map<String,map<string,Object>>();
        Map<String, List<String>> mapExtIdToMissingFld = new Map<String, List<String>>();
        Map<Integer,Map<String,Object>> mapIdToWrapMapAll= new Map<Integer,Map<String,Object>>();
        Map<String, Core_Design_Registration__c> mapOfIdToInstance = new Map<String, Core_Design_Registration__c>();
        Map<String,Map<String,Object>> mapValidIdToWrap = new Map<String,Map<String,Object>>();
        List<Core_Design_Registration__c> drProductListToUpdate = new List<Core_Design_Registration__c>();
        Integer DDRCount = 0;
        
        List<String> requiredFieldsApi = new List<String>();
        for(String st:requiredFields){
            String labelToApi = drProductLabelToApiMap.containsKey(st)?drProductLabelToApiMap.get(st):null;
            if(labelToApi!=null)
                requiredFieldsApi.add(labelToApi);
        }
        system.debug('requiredFieldsApi'+requiredFieldsApi);
        
        try{
            //Iterating over the wrapper list 
            for(Object reqWrap : DDRWrapList){                
                Map<String, Object> drMap = (Map<String, Object>)reqWrap;
                mapIdToWrapMapAll.put(DDRCount,drMap);
                if((String)drMap.get('uniqueId')!=null && (String)drMap.get('uniqueId')!=''){                    
                    mapIdToWrapMap.put((String)drMap.get('uniqueId'),drMap);
                } 
                DDRCount++;
            }
            system.debug('mapIdToWrapMap'+mapIdToWrapMap);
            
            //query for valid data to check if record is present in salesforce or not 
            if(!mapIdToWrapMap.isEmpty()){
                validDRList = [SELECT Id,Core_Product_Group_Nm__c,Core_Military_Aerospace_Gvrnmt_Use_Ind__c,Core_Vertical_Market_Nm__c,Core_Product_Segment_Nm__c,Core_Product_Application_Nm__c,Core_External_Id__c,Core_Partner_FAE_Nm__c, Core_Partner_FSR_Nm__c,
                               Core_End_Customer_Nm__c,Core_End_Customer_Street_Addr_Line1_Txt__c,Core_End_Customer_Street_Addr_Line2_Txt__c,Core_End_Customer_Country_Nm__c,Core_End_Customer_Country_Subdivision_Nm__c,Core_End_Customer_Postal_Cd__c,
                               Core_End_Customer_City_Nm__c,Core_End_Customer_Contact_Title_Txt__c,Core_End_Customer_Contact_Phone_Txt__c,Core_End_Customer_Contact_Nm__c,Core_End_Customer_Contact_Email_Txt__c,Core_Manufacturing_Region_Cd__c,
                               Core_Opportunity_Decision_Dt__c,Core_First_Customer_Ship_Dt__c,Core_Production_End_Dt__c,Core_Intel_Platform_Nm__c
                               FROM Core_Design_Registration__c 
                               WHERE Id IN :mapIdToWrapMap.keySet() OR Core_External_Id__c IN :mapIdToWrapMap.keySet()];                           
            }
            
            if(validDRList.size()>0){
                for(Core_Design_Registration__c vl:validDRList){                    
                    existingDDR.put(vl.Id,vl);                    
                    mapOfRecIdToExtId.put(string.valueof(vl.Id),vl.Core_External_Id__c);
                    mapOfExtIdToRecId.put(vl.Core_External_Id__c,string.valueof(vl.Id));
                }   
            }
            
            
            for(String DRId : mapIdToWrapMap.keySet()){
                if(mapOfRecIdToExtId.containskey(DRId)){
                    mapRecIdTODRList.put(DRId,mapIdToWrapMap.get(DRId));
                    // mapRecIdToDDR.put(DRId,existingDDR.get(DRId));
                }
                else if(mapOfExtIdToRecId.containskey(DRId)){
                    mapRecIdTODRList.put(mapOfExtIdToRecId.get(DRId),mapIdToWrapMap.get(DRId));
                    // mapRecIdToDDR.put(mapOfExtIdToRecId.get(DRId),existingDDR.get(mapOfExtIdToRecId.get(DRId)));
                }               
            }                        
            System.debug('mapRecIdTODRList---> '+mapRecIdTODRList);            
            
            Boolean requiredFieldsMissing = false;
            if (!validDRList.isEmpty()) {               
                for(Core_Design_Registration__c dr : validDRList){  
                    String controllingValue; 
                    boolean nomissingfields;
                    for(string fieldApiName : requiredFieldsApi){
                        string labelname=drProductApiToLabelMap.containsKey(fieldApiName)? drProductApiToLabelMap.get(fieldApiName): null;
                        
                        if(existingDDR.get(dr.id).get(fieldApiName)== null && !mapIdToWrapMap.get(dr.id).containskey(labelname) && (mapIdToWrapMap.get(dr.id).get(labelname))==null){                                    
                            if (mapExtIdToMissingFld.containsKey(dr.id)) {
                                mapExtIdToMissingFld.get(dr.id).add(labelname);
                            } else {
                                mapExtIdToMissingFld.put(dr.id, new List<String>{labelname});
                            }
                            requiredFieldsMissing = true;
                        }                                              
                    }
                    
                    System.debug('mapExtIdToMissingFld---->'+mapExtIdToMissingFld);
                    
                    if(!requiredFieldsMissing){
                        mapValidIdToWrap.put(dr.Id,mapRecIdTODRList.get(dr.Id));
                    }                  
                }      
            }    
            
            System.debug('mapValidIdToWrap----> '+mapValidIdToWrap);
            if(!mapValidIdToWrap.isEmpty()){
                mapOfIdToInstance = PCC_CreateDDRUtilityHandler.createDRInstance(mapValidIdToWrap,'Update',existingDDR, null);
                drProductListToUpdate = mapOfIdToInstance.values();
            }
            
            System.debug('mapOfIdToInstance----> '+mapOfIdToInstance);
            
            
            if (!drProductListToUpdate.isEmpty()) {
                Integer i = 0;
                for(Database.SaveResult sr: Database.update(drProductListToUpdate, false)){
                    mapDrRecordSaveResult.put(drProductListToUpdate[i], sr);
                    i++;
                }
            }
            
            //get response of records that are successfully inserted and the records that have errors
            PCC_Wrapper.PCC_DRDetailsWrapper drWrp = getDDRObjectResponses(mapIdToWrapMapAll, mapExtIdToMissingFld, mapOfIdToInstance, mapExtIdtoInvalidValMsg,
                                                                           mapDrRecordSaveResult, mapOfExtIdToRecId, mapOfRecIdToExtId, 'Update');
            
            //get statusCode based on successful or failed record count
            res.statusCode = getStatusCode(DDRWrapList.size(), drWrp.successfulRecordCount, drWrp.failedRecordCount);
            
            //set responsebody
            res.responseBody = Blob.valueOf(JSON.serialize(drWrp.respList));
            
        }
        catch(exception ex){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY, '', '', '', 'PCC_CreateDesignRegistrationUtility_V1', '', ex);
        }
        return res;
    }
    
    
    /*****************************************************************************************************************
* Method Name: createDRInstance
* Date: /06/2023    
* Owner: Shraddha
* Description: This is a method to create instances of Design Registration Product Object for valid payloads
* Return: Returns map with DR product List
******************************************************************************************************************/
    public static Map<String, Core_Design_Registration__c> createDRInstance( Map<String, Map<String, Object>> mapOfExtIdtoValidDDR, String Action, Map<Id,Core_Design_Registration__c> mapExistingDDR,
                                                                             Map<String, String> partnerFAEtoUser){   
        Map<String, Core_Design_Registration__c> mapExtIdToValidDr = new Map<String, Core_Design_Registration__c>();
        try{
            
            String objectName = 'Core_Design_Registration__c';
            Map<String,List<String>> controlValueWrapMap = getDependentvaluesList(objectName,'Core_Product_Application_Nm__c');
            if(mapOfExtIdtoValidDDR.size() > 0){
                for(string str: mapOfExtIdtoValidDDR.keySet()){
                    String uniqueId = mapOfExtIdtoValidDDR.get(str).containsKey('uniqueId') ? (String)mapOfExtIdtoValidDDR.get(str).get('uniqueId') : null;
                    String productGroup = mapOfExtIdtoValidDDR.get(str).containsKey('productGroup') ? (String)mapOfExtIdtoValidDDR.get(str).get('productGroup') : null;
                    String militaryAerospaceGvrnmtUseInd = mapOfExtIdtoValidDDR.get(str).containsKey('militaryAerospaceGvrnmtUseInd') ? (String)mapOfExtIdtoValidDDR.get(str).get('militaryAerospaceGvrnmtUseInd') : null;
                    String verticalMarket = mapOfExtIdtoValidDDR.get(str).containsKey('verticalMarket') ? (String)mapOfExtIdtoValidDDR.get(str).get('verticalMarket') : null;
                    String productSegment = mapOfExtIdtoValidDDR.get(str).containsKey('productSegment') ? (String)mapOfExtIdtoValidDDR.get(str).get('productSegment') : null;
                    String productApplication = mapOfExtIdtoValidDDR.get(str).containsKey('productApplication') ? (String)mapOfExtIdtoValidDDR.get(str).get('productApplication') : null;
                    String opportunityVolume = mapOfExtIdtoValidDDR.get(str).containsKey('opportunityVolume') ? (String)mapOfExtIdtoValidDDR.get(str).get('opportunityVolume') : null;
                    String partnerFAE = mapOfExtIdtoValidDDR.get(str).containsKey('partnerFAE') ? (String)mapOfExtIdtoValidDDR.get(str).get('partnerFAE') : null;
                    String endCustomerName = mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerName') ? (String)mapOfExtIdtoValidDDR.get(str).get('endCustomerName') : null;
                    String endCustomerAddress1 = mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerAddress1') ? (String)mapOfExtIdtoValidDDR.get(str).get('endCustomerAddress1') : null;
                    String endCustomerPostalCode = mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerPostalCode') ? (String)mapOfExtIdtoValidDDR.get(str).get('endCustomerPostalCode') : null;
                    String endCustomerCountry = mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerCountry') ? (String)mapOfExtIdtoValidDDR.get(str).get('endCustomerCountry') : null;
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
                    String partnerFAEEmail = mapOfExtIdtoValidDDR.get(str).containsKey('partnerFAEEmail') ? (String)mapOfExtIdtoValidDDR.get(str).get('partnerFAEEmail') : null;
                    
                    Core_Design_Registration__c drRec = new Core_Design_Registration__c();
                    System.debug('drRec.Core_External_Id__c--> '+drRec.Core_External_Id__c);
                                        
                    if(partnerFAEEmail!=null){
                        if(partnerFAEtoUser.containsKey(partnerFAEEmail)){
                            drRec.DDR_Partner_FAE_Email__c = partnerFAEEmail;
                            drRec.OwnerId = partnerFAEtoUser.get(partnerFAEEmail);
                        }else{
                            String errMsg = 'The Contact associated with the provided PartnerFAE Email is not configured in the Intel System: '+ partnerFAEEmail;
                            mapExtIdtoInvalidValMsg.put(str, errMsg);
                            continue;
                        }
                    }
                    
                    if(productGroup!= null){
                        drRec.Core_Product_Group_Nm__c = productGroup;
                    }
                    if(militaryAerospaceGvrnmtUseInd != null){
                        drRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = militaryAerospaceGvrnmtUseInd;
                    }
                    if(verticalMarket != null){
                        drRec.Core_Vertical_Market_Nm__c = verticalMarket;
                    }
                    if(Action == 'Insert'){
                        drRec.Core_External_Id__c = (String)mapOfExtIdtoValidDDR.get(str).get('uniqueId');
                        if(productSegment != null){
                            drRec.Core_Product_Segment_Nm__c = productSegment;
                        }
                        if(productApplication != null){
                            drRec.Core_Product_Application_Nm__c = productApplication;
                        }
                        if(designRegistrationName!= null){
                            drRec.Core_Design_Registration_Nm__c = designRegistrationName;
                        }else{
                            String concatDate = String.valueOf(System.today().year()) + String.valueOf(System.today().month()) + String.valueOf(System.today().day());
                            String concatTime =    String.valueOf(System.now().hour()) + String.valueOf(System.now().minute()) + String.valueOf(System.now().second());
                            drRec.Core_Design_Registration_Nm__c = 'DDR_'+userInfo.getName()+'_'+concatDate+'_'+concatTime;
                        }
                        drRec.Core_Submission_Type__c = 'M2M';                        
                    }
                    else if(Action == 'Update'){
                        Core_Design_Registration__c existingDDRId = mapExistingDDR.get(str);
                        List<String> dependentValues = new List<String>();
                        //drRec.id = uniqueId;
                        drRec.id = str;
                        String controllingValue;
                        if(productSegment!=null && productApplication!=null){
                            dependentValues = controlValueWrapMap.containsKey(productSegment) ? controlValueWrapMap.get(productSegment) : null;
                            if(dependentValues!= null){
                                if(dependentValues.contains(productApplication)){
                                    drRec.Core_Product_Segment_Nm__c = productSegment;
                                    drRec.Core_Product_Application_Nm__c = productApplication;
                                }else{
                                mapExtIdtoInvalidValMsg.put(drRec.Id,'Cannot find the Parent field value and Child field value mapping');
                                continue;
                            }
                            }
                        }else{                       
                            if(productSegment!=null){
                                dependentValues = controlValueWrapMap.containsKey(productSegment) ? controlValueWrapMap.get(productSegment) : null;
                                if(dependentValues!= null){
                                    if(dependentValues.contains(existingDDRId.Core_Product_Application_Nm__c)){
                                        drRec.Core_Product_Segment_Nm__c = productSegment;	
                                    }else{    
                                    //Parent field value is not supported by the Child field value
                                    mapExtIdtoInvalidValMsg.put(drRec.Id,'Cannot update the parent field value for the child field value present on the DDR');
                                    continue;
                                }
                                    controllingValue=productSegment; 
                                }else{    
                                    //Parent field value is not supported by the Child field value
                                    mapExtIdtoInvalidValMsg.put(drRec.Id,'Invalid picklist value for the parent field value for the child field value present on the DDR');
                                    continue;
                                }
                                                                                                                              
                            }else{
                                controllingValue =mapExistingDDR.containsKey(drRec.Id) ? existingDDRId.Core_Product_Segment_Nm__c : null;
                            }  
                            //productApplication is not null
                            if(productApplication!=null){     
                                dependentValues = controlValueWrapMap.containsKey(controllingValue) ? controlValueWrapMap.get(controllingValue) : null;
                                if(dependentValues!= null && dependentValues.contains(productApplication)){
                                        drRec.Core_Product_Application_Nm__c = productApplication;
                                }else{
                                    mapExtIdtoInvalidValMsg.put(drRec.Id,'Cannot find the Child field value provided for the Parent field value on DDR');
                                    continue;
                                }                                    
                            }
                        }
                        if(designRegistrationName!= null){
                            drRec.Core_Design_Registration_Nm__c = designRegistrationName;
                        }
                    }
                    
                    if(partnerFAE != null){
                        drRec.Core_Partner_FAE_Nm__c = partnerFAE;
                    }
                    if(endCustomerName != null){
                        drRec.Core_End_Customer_Nm__c = endCustomerName;
                    }
                    if(endCustomerAddress1 != null){
                        drRec.Core_End_Customer_Street_Addr_Line1_Txt__c = endCustomerAddress1;
                    }
                    if(endCustomerPostalCode != null){
                        drRec.Core_End_Customer_Postal_Cd__c = endCustomerPostalCode;
                    }
                    if(endCustomerCountry != null){
                        drRec.Core_End_Customer_Country_Nm__c = endCustomerCountry;
                    }
                    if(intelPlatform != null){
                        drRec.Core_Intel_Platform_Nm__c = intelPlatform;
                    }
                    if(opportunityVolume != null){
                        try{
                            drRec.Core_Opportunity_Volume_Cnt__c = Integer.valueOf(opportunityVolume);
                        }catch(exception ex){
                             mapExtIdtoInvalidValMsg.put(str,'Please provide opportunityVolume in number format.');
                             continue;
                        }
                    }
                    if(designDecisionDate != null){
                        try{
                            if(Date.valueOf(designDecisionDate) >= System.today()){
                                drRec.Core_Opportunity_Decision_Dt__c = Date.valueOf(designDecisionDate);
                            }else{
                                mapExtIdtoInvalidValMsg.put(str,'Please ensure that the date field should have either current date or a date in the future.');
                                continue;
                            }
                        }catch(exception ex){
                            mapExtIdtoInvalidValMsg.put(str,'Please provide designDecisionDate date in valid format (YYYY-MM-DD)');
                            continue;
                        }
                    }
                    if(firstCustomerShipDate != null){
                        try{
                            if( Date.valueOf(firstCustomerShipDate) >= System.today()){
                                drRec.Core_First_Customer_Ship_Dt__c = Date.valueOf(firstCustomerShipDate);
                            }else{
                                mapExtIdtoInvalidValMsg.put(str,'Please ensure that the date field should have either current date or a date in the future.');
                                continue;
                            }
                        }catch(exception ex){
                            mapExtIdtoInvalidValMsg.put(str,'Please provide firstCustomerShipDate date in valid format (YYYY-MM-DD)');
                            continue;
                        }
                    }
                    if(productionEndDate != null){
                        try{
                            if(Date.valueOf(productionEndDate) >= System.today()){
                                drRec.Core_Production_End_Dt__c = Date.valueOf(productionEndDate);
                            }else{
                                mapExtIdtoInvalidValMsg.put(str,'Please ensure that the date field should have either current date or a date in the future.');
                                continue;
                            }
                        }catch(exception ex){
                            mapExtIdtoInvalidValMsg.put(str,'Please provide productionEndDate date in valid format (YYYY-MM-DD)');
                            continue;
                        }
                    }
                    if(description != null){
                        drRec.Core_Design_Registration_Dsc__c = description;
                    }
                    if(partnerFSR != null){
                        drRec.Core_Partner_FSR_Nm__c = partnerFSR;
                    }
                    if(endCustomerAddress2 != null){
                        drRec.Core_End_Customer_Street_Addr_Line2_Txt__c = endCustomerAddress2;
                    }
                    if(endCustomerCity != null){
                        drRec.Core_End_Customer_City_Nm__c = endCustomerCity;
                    }
                    if(endCustomerState != null){
                        drRec.Core_End_Customer_Country_Subdivision_Nm__c = endCustomerState;
                    }
                    if(endCustomerContactTitle != null){
                        drRec.Core_End_Customer_Contact_Title_Txt__c = endCustomerContactTitle;
                    }
                    if(endCustomerContactName != null){
                        drRec.Core_End_Customer_Contact_Nm__c = endCustomerContactName;
                    }
                    if(endCustomerContactEmail != null){
                        drRec.Core_End_Customer_Contact_Email_Txt__c = endCustomerContactEmail;
                    }
                    if(endCustomerContactPhone != null){
                        drRec.Core_End_Customer_Contact_Phone_Txt__c = endCustomerContactPhone;
                    }
                    if(manufacturingRegion != null){
                        drRec.Core_Manufacturing_Region_Cd__c = manufacturingRegion;
                    }
                    
                    
                    
                    mapExtIdToValidDr.put(str, drRec);
                }
            }
        }catch (Exception ex) {
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateDesignRegistrationUtility' ,'' ,ex); 
        }
        return mapExtIdToValidDr;
    }
    
    
    /*****************************************************************************************************************
* Method Name: getDDRObjectResponses
* Date: /06/2023 
* Description: This is a generic method to Get responses of the records that are successfully inserted and the records that have an errors
* Return: Returns PCC_DRDetailsWrapper with response List with successful message or user friendly errors
******************************************************************************************************************/
    public static PCC_Wrapper.PCC_DRDetailsWrapper getDDRObjectResponses(Map<Integer, Map<String, Object>> listOfDrmap, Map<String, List<String>> mapExtIdToMissingFld,
                                                                         Map<String, Object> mapExtIdToValidDr, Map<String, String> mapExtIdtoInvalidValMsg,
                                                                         Map<object, Database.SaveResult> mapDrRecordSaveResult,
                                                                         Map<String,String> mapOfExtIdToRecId, Map<String,String> mapOfRecIdToExtId, String Action)
    {
        Set<String> errorString;      
        String errorMsgForLogEntry = '';
        Integer failedRecordCount = 0;
        Integer successfulRecordCount = 0;
        List<PCC_Wrapper.restAPIResponseWrapper> respList = new List<PCC_Wrapper.restAPIResponseWrapper>();   
        PCC_Wrapper.PCC_DRDetailsWrapper drProductWrp = new PCC_Wrapper.PCC_DRDetailsWrapper();  
        Map<String, String> drProductApiToLabelMap = PCC_Constants.drProductApiToLabelMap;
        String uniqueExtId, extId, uniqueId, successMsg, noUniqueIdMsg;
        
        try{          
            Integer count = 0;
            for (Map<String, Object> drMap : listOfDrmap.values()) {
                PCC_Wrapper.restAPIInnerResponseWrapper irWrp = new PCC_Wrapper.restAPIInnerResponseWrapper();
                
                if(Action == 'Insert'){
                    successMsg = 'Record has been successfully created.';
                    noUniqueIdMsg = 'Please provide uniqueId field correctly to create the record.';
                    uniqueExtId = drMap.containsKey('uniqueId') ? (String)drMap.get('uniqueId') + count : null;
                    extId = (String)drMap.get('uniqueId');
                }
                else if(Action == 'Update'){
                    successMsg = 'Record has been successfully updated.';
                    noUniqueIdMsg = 'Please provide a Valid Record Id/External Id as a uniqueId to update the record.';
                    uniqueId = drMap.containsKey('uniqueId') ? (String)drMap.get('uniqueId') : null ;
                    //getting the record id for the DDR to be updated , to display in the response and also to get the message for ir Wrp as the wrapper contains extid or recid
                    if(mapOfExtIdToRecId.containskey(uniqueId)){
                        uniqueExtId = mapOfExtIdToRecId.get(uniqueId);
                        extId = uniqueId;
                    }else{
                        uniqueExtId = uniqueId;
                        extId = mapOfRecIdToExtId.get(uniqueId);
                    }
                }
                irWrp.ExternalId = extId;
                
                System.debug('mapExtIdtoInvalidValMsg--> '+mapExtIdtoInvalidValMsg);
                
                //return error if the required fields are missing in payload
                if (!mapExtIdToMissingFld.isEmpty() && mapExtIdToMissingFld.containsKey(uniqueExtId)) {
                    System.debug('mapExtIdToMissingFld--> '+mapExtIdToMissingFld);
                    failedRecordCount++;
                    irWrp.Message = 'Following required fields are missing: '+ mapExtIdToMissingFld.get(uniqueExtId) +'.';
                    respList.add(setJsonResponseBody(400, 'FAILURE', 9002, irWrp, null));
                }
                //return error if the user sends invalid values to the fields in payload
                else if(!mapExtIdtoInvalidValMsg.isEmpty() && mapExtIdtoInvalidValMsg.containsKey(uniqueExtId)){
                    failedRecordCount++;
                    irWrp.Message = mapExtIdtoInvalidValMsg.get(uniqueExtId);
                    respList.add(setJsonResponseBody(400, 'FAILURE', 9002, irWrp, null));
                }
                else if(mapExtIdToValidDr.containsKey(uniqueExtId)){
                    Database.SaveResult sr = mapDrRecordSaveResult.get(mapExtIdToValidDr.get(uniqueExtId));
                    //return success message if record is created successfully
                    if (sr != null && sr.isSuccess()) {
                        successfulRecordCount++;
                        irWrp.Message = successMsg;
                        respList.add(setJsonResponseBody(201, 'SUCCESS', null, irWrp, sr.getId()));        
                    }else{
                        //return database error if record insertion is failed
                        failedRecordCount++;
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
                                        errMessage = 'Bad or Inactive value given to '+ fieldsNameList +' picklist: '+ drMap.get(drProductApiToLabelMap.get(err.getfields()[0])) +'. Please choose an option from the available list of values for this field.' ;
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
                                    
                                    irWrp.ExternalId = extId;
                                    irWrp.Message = errMessage;
                                    respList.add(setJsonResponseBody(400, 'FAILURE', errCd, irWrp , null));
                                    errorString.add(fieldName + err.getMessage());
                                    errorMsgForLogEntry += extId+' - '+err.getMessage()+'\n';
                                }
                            }
                        }
                    }
                }else{ //return error if the requested record doesn't have an external id 
                    failedRecordCount++;
                    irWrp.ExternalId = null;
                    irWrp.Message = noUniqueIdMsg;
                    respList.add(setJsonResponseBody(400, 'FAILURE',9002, irWrp, null));
                    errorMsgForLogEntry += 'missing unique id. No unique id found in the payload for that record'+'\n';
                }
                count++;
            }
            
            drProductWrp.failedRecordCount = failedRecordCount;
            drProductWrp.successfulRecordCount = successfulRecordCount;
            drProductWrp.respList = respList;
            if(failedRecordCount!=0){
                Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY, 'Exception occurred while inserting Design Registration Record',errorMsgForLogEntry, '', '', '');
            }
            
        }catch (Exception ex) {
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateDesignRegistrationUtility' ,'' ,ex); 
        }
        return drProductWrp;
        
    }
    
    /*****************************************************************************************************************
* Method Name:getStatusCode
* Date: 04/06/2023    
* Description: This is a generic method to get statusCode based on successful or failed record count
* Return: returns statusCode as Integer
******************************************************************************************************************/
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
    
    /***********************************************************************************************************************************************
* description: Check if PartnerFAE email exists on SF on the IPA contact and is set up with the proper IPA entitlements.
* return: returns list of valid PartnerFAE emails
* dev: Shraddha M 
* US: TWC729-5678
***********************************************************************************************************************************************/
     Private static Map<String, String> PCC_checkValidPartnerFAE( List<String> partnerFAEMailToCheck){
        List<String> validPartnerFAEMail = new List<String>();
        Boolean isValidEmail = false;
        Set<Id> setOfconId = new Set<Id>();
		Map<String, String> partnerFAEtoUser = new Map<String, String>();
          
        //check for IPA entitlements
        for(Core_Contact_Entitlement__c ce : [SELECT id, Core_Contact_Id__c, Core_Contact_Id__r.Email, Core_Entitlement_Id__r.Name,
                                              Core_Status__c , Core_Contact_Id__r.Account.Core_Intel_Partner_Alliance_PartnerGroup__c 
                                              FROM Core_Contact_Entitlement__c 
                                              WHERE  Core_Entitlement_Id__r.Name = 'Employee'
                                              and Core_Status__c='Complete' and Core_Selected__c = true
                                              and Core_Contact_Id__r.Account.Core_Intel_Partner_Alliance_PartnerGroup__c = true
                                              and Core_Contact_Id__r.Email IN: partnerFAEMailToCheck 
                                             ]
           ){
               validPartnerFAEMail.add(ce.Core_Contact_Id__r.Email);
           }
         
         if(validPartnerFAEMail.size() > 0){//active check
             for(user u: [SELECT Id, Name, Contact.Email, IsActive  
                          FROM User 
                          WHERE IsActive = true AND Contact.Email IN: validPartnerFAEMail]
                ){
                 partnerFAEtoUser.put(u.Contact.Email, u.Id);
             }
         }
        return partnerFAEtoUser;
    }   
    
    
    
    /*****************************************************************************************************************
* Method Name: setDDRWrapper
* Date: 23/06/2023    
* Owner: Shraddha
* Description: This is a method to create PCC_DesignRegDetailsWrapper instance using design registration record
* Return: Returns PCC_DesignRegDetailsWrapper
******************************************************************************************************************/    
    public static PCC_Wrapper.PCC_DesignRegDetailsWrapper setDDRWrapper(Core_Design_Registration__c ddrRec){
        PCC_Wrapper.PCC_DesignRegDetailsWrapper ddrWrp = new PCC_Wrapper.PCC_DesignRegDetailsWrapper();
        try{
            ddrWrp.name = ddrRec.Name;
            ddrWrp.productGroup = ddrRec.Core_Product_Group_Nm__c;
            ddrWrp.productSegment = ddrRec.Core_Product_Segment_Nm__c;
            ddrWrp.militaryAerospaceGvrnmtUseInd = ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c;
            ddrWrp.productApplication = ddrRec.Core_Product_Application_Nm__c;
            ddrWrp.verticalMarket = ddrRec.Core_Vertical_Market_Nm__c;
            ddrWrp.uniqueId = ddrRec.Core_External_Id__c; 
            ddrWrp.opportunityVolume = String.valueOf(ddrRec.Core_Opportunity_Volume_Cnt__c);
            ddrWrp.partnerFAE = ddrRec.Core_Partner_FAE_Nm__c;
            ddrWrp.partnerFSR = ddrRec.Core_Partner_FSR_Nm__c;
            ddrWrp.endCustomerName = ddrRec.Core_End_Customer_Nm__c;
            ddrWrp.endCustomerAddress1 = ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c;
            ddrWrp.endCustomerAddress2 = ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c;
            ddrWrp.endCustomerCountry = ddrRec.Core_End_Customer_Country_Nm__c;
            ddrWrp.endCustomerCity = ddrRec.Core_End_Customer_City_Nm__c;
            ddrWrp.endCustomerState = ddrRec.Core_End_Customer_Country_Subdivision_Nm__c;
            ddrWrp.endCustomerPostalCode = ddrRec.Core_End_Customer_Postal_Cd__c;
            ddrWrp.endCustomerContactTitle = ddrRec.Core_End_Customer_Contact_Title_Txt__c;
            ddrWrp.endCustomerContactName = ddrRec.Core_End_Customer_Contact_Nm__c;
            ddrWrp.endCustomerContactEmail = ddrRec.Core_End_Customer_Contact_Email_Txt__c;
            ddrWrp.endCustomerContactPhone = ddrRec.Core_End_Customer_Contact_Phone_Txt__c;
            ddrWrp.manufacturingRegion = ddrRec.Core_Manufacturing_Region_Cd__c;
            ddrWrp.firstCustomerShipDate = ddrRec.Core_First_Customer_Ship_Dt__c;
            ddrWrp.intelPlatform = ddrRec.Core_Intel_Platform_Nm__c;
            ddrWrp.designRegistrationName = ddrRec.Core_Design_Registration_Nm__c;
            ddrWrp.description = ddrRec.Core_Design_Registration_Dsc__c;
        }catch (Exception ex) {
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateDesignRegistrationUtility' ,'' ,ex); 
        }
        return ddrWrp;
    } 
    
    /***********************************************************************************************************************************************
* description: creates PCC_Wrapper.SalesforceResponseWrapper (generic)
* return: returns PCC_Wrapper.SalesforceResponseWrapper
* dev: Shraddha M 
***********************************************************************************************************************************************/
    
    public static PCC_Wrapper.restAPIResponseWrapper setJsonResponseBody(Integer statusCode, String status, Integer errorCode, PCC_Wrapper.restAPIInnerResponseWrapper responseBody, String recordId){
        PCC_Wrapper.restAPIResponseWrapper respWrapper = new PCC_Wrapper.restAPIResponseWrapper();
        respWrapper.StatusCode = statusCode;
        respWrapper.Status = status;
        respWrapper.ErrorCode = errorCode;
        respWrapper.ResponseBody = responseBody;
        respWrapper.RecordId = recordId;
        return respWrapper;
    }
    public static PCC_Wrapper.SalesforceResponseWrapper setResponseBody(Integer statusCode, String status, Integer errorCode, String responseBody, String recordId){
        PCC_Wrapper.SalesforceResponseWrapper respWrapper = new PCC_Wrapper.SalesforceResponseWrapper();
        respWrapper.StatusCode = statusCode;
        respWrapper.Status = status;
        respWrapper.ErrorCode = errorCode;
        respWrapper.ResponseBody = responseBody;
        respWrapper.RecordId = recordId;
        return respWrapper;
    }
    Public static PCC_Wrapper.restAPIDDRDetailsWrapper setDesignRegResponseBody(Integer StCodeParam, String StatusParam, Integer ErrCodeParam, PCC_Wrapper.PCC_DesignRegDetailsWrapper ResBodyParam, String RecIdParam){
        PCC_Wrapper.restAPIDDRDetailsWrapper respWrp = new PCC_Wrapper.restAPIDDRDetailsWrapper();
        respWrp.StatusCode = StCodeParam;
        respWrp.Status = StatusParam;
        respWrp.ErrorCode = ErrCodeParam;
        respWrp.ResponseBody = ResBodyParam;
        respWrp.RecordId = RecIdParam;    
        return respWrp;
    }   
    
}