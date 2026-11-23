/*************************************************************************************************************************************
Apex Class Name     : PCC_CreateDDRUtilityHandler_V2
Version             : 
Created Date        : June 2024
Descrpition         : Utility handler of PCC_CreateDesignRegistrationUtility_V2 class

Modification Log    :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Shraddha                June - 2024        Added a methods to fetch API values of given picklists
* Shraddha                June - 2024      Added methods to get customise error responses
************************************************************************************************************************************************/

public with sharing class PCC_CreateDDRUtilityHandler_V2 {
    public static final String LOG_ENTRY_ORIGIN   = 'PCC_CreateDesignRegistration_V2';
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
    public static final String RESTRICTED_PICKLIST = PCC_Constants.RESTRICTED_PICKLIST;
    public static final String FIELD_FILTER_VALIDATION = PCC_Constants.FIELD_FILTER_VALIDATION;
    public static final String REQUIRED_FIELD_MISSING = PCC_Constants.REQUIRED_FIELD_MISSING;
    public static final String FIELD_INTEGRITY_EXCEPTION = PCC_Constants.FIELD_INTEGRITY_EXCEPTION;
    public static final String MALFORMED_ID = PCC_Constants.MALFORMED_ID;
    public static final String INVALID_ID_FIELD = PCC_Constants.INVALID_ID_FIELD;
    public static final String STRING_TOO_LONG = PCC_Constants.STRING_TOO_LONG;
    public static final String INVALID_CROSS_REFERENCE_KEY = PCC_Constants.INVALID_CROSS_REFERENCE_KEY;
    public static final String DUPLICATE_VALUE = PCC_Constants.DUPLICATE_VALUE;
    
    public static map<string,string> returnCountryMappings() {
        Map<string,string> countryMap = new map<string,string>();
        for(Core_Country_Code_Mapping__c allCountries : Core_Country_Code_Mapping__c.getAll().values()) {
            countryMap.put(allCountries.Name, allCountries.Country_Code__c);
        }
        return countryMap;
    }
    
    /*****************************************************************************************************************
* Method Name: getNameDDR
* Date: 04/06/2024    
* Description: This method will return Map of Id and Names of Dr 
* Dev: Vinita Chugh
* Return: returns Map of Id and DR/DRP Name 
******************************************************************************************************************/
    
    public static Map<Id,String> getNameDDR(List<Id> dDRids){
        Map<Id,String> nameValues= new Map<Id,String>();
        if(dDRids!= null && !dDRids.isEmpty()){
            List<Core_Design_Registration__c> DRName= new  List<Core_Design_Registration__c>();
            List<Core_Design_Registration_Product__c> DRName1= new List<Core_Design_Registration_Product__c>();
            if(dDRids[0].getSObjectType().getDescribe().getName() == 'Core_Design_Registration__c'){
                DRName = [Select Id,Name from Core_Design_Registration__c where Id IN :dDRids];
            }
            else{
                DRName1 = [Select Id,Name from Core_Design_Registration_Product__c where Id IN :dDRids];
            }
            if(DRName!= null && !DRName.isEmpty()){
                for(Core_Design_Registration__c dr: DRName){
                    nameValues.put(dr.Id,dr.Name);
                }
            }
            else if(DRName1!= null && !DRName1.isEmpty()){
                for(Core_Design_Registration_Product__c dr: DRName1){
                    nameValues.put(dr.Id,dr.Name);
                }
            }
        }
        return nameValues;  
    }  
    /*****************************************************************************************************************
* Method Name: getPicklistValuesMap
* Date: 04/06/2024    
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
                        if(apiName=='PCC_End_Customer_Country__c'){
                            pl.ApiName = returnCountryMappings().get(string.valueof(entry.getValue()));
                        }else{
                            pl.ApiName = entry.getValue();
                        }                       
                        //pl.IsActive = entry.isActive();
                        pickListWrpList.add(pl);
                    }
                    picklistValuesMap.put(mapOfPicklist.get(apiName), pickListWrpList);
                }
            }
        } catch (Exception ex) { Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateDDRUtilityHandler_V2.getPicklistValuesMap' ,'' ,ex); 
                               }
        return picklistValuesMap;
    }
    
    
    /*****************************************************************************************************************
* Method Name: getDependentFields
* Date: 04/06/2024    
* Description: This method will return Wrapper of controlling value to it's corresponding dependent fields with label and API names
* Dev: Shraddha M
* Return: returns Wrapper of controlling value to Dependent values
******************************************************************************************************************/
    public static Map<String, List<PCC_Wrapper.PCC_PicklistWrapper>> getDependentFields(String ObjectName, String dependentField, String controllingValue, Schema.sObjectField ControllingField){
        Map<String, List<PCC_Wrapper.PCC_PicklistWrapper>> dependentPicklistValues = new Map<String,List<PCC_Wrapper.PCC_PicklistWrapper>>();
        String staticLabel = PCC_Constants.static_DDR_MD_Label;
        try {
            //List<PCC_Wrapper.PCC_PicklistWrapper> pickListWrpList = new List<PCC_Wrapper.PCC_PicklistWrapper>();
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
                                if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0){
                                    continue;
                                }
                                if (!dependentPicklistValues.containsKey(staticLabel)) {
                                    dependentPicklistValues.put(staticLabel, new List<PCC_Wrapper.PCC_PicklistWrapper>());
                                }
                                PCC_Wrapper.PCC_PicklistWrapper pl = new PCC_Wrapper.PCC_PicklistWrapper();
                                pl.Label = entry.getLabel();
                                pl.ApiName = entry.getValue();
                                //pl.IsActive = entry.isActive();
                                dependentPicklistValues.get(staticLabel).add(pl);
                            } 
                        }
                    }
                }
            }
        } catch (Exception ex) { Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateDDRUtilityHandler_V2.getDependentFields' ,'' ,ex); 
                               }
        //System.debug('dependentPicklistValues'+dependentPicklistValues);
        return dependentPicklistValues;
    }
    
    /*****************************************************************************************************************
* Method Name: getDependentvaluesList
* Date: 04/06/2024    
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
                        (controlEntries == null ? (Object) (index == 1)
                         :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                        );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0){
                        continue;
                    }
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
* Date: 06/2024   
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
        //System.debug('ListOfPayload--> '+listOfPayloads);
        Map<Id,Core_Design_Registration__c> mapExistingDDR = new Map<Id,Core_Design_Registration__c>();
        List<String> partnerFAEMailToCheck = new List<String>();
        Map<String, String> partnerFAEtoUser = new Map<String, String>();
        List<STring> validExternalIdValue = new List<String>();
        Map<String, String> mapOfExtIdToPartnerFaeEmail = new Map<String, String>();
        Map<String, String> mapOfExtIdToOwnerId = new Map<String, String>();
        Map<String,list<string>> mapIdTounexpected = new Map<String,list<string>>();
        
        try{
            Integer count = 0;
            for(Object dr : listOfPayloads){
                Map<String, Object> drMap = (Map<String, Object>)dr;    
                mapOfCountToDrmap.put(count, drMap);
                
                String uniqueExtId = (String)drMap.get('externalId') + count;
                Boolean isReqFieldsMissing = false;
                
                list<string> unExpValues =new List<String>();
                for(string payloadLabel : drMap.keyset()){
                    if(payloadLabel !=null && !PCC_Constants.allowedFieldsPostDR.contains(payloadLabel)&& !string.isEmpty(((string)drMap.get(payloadLabel)))){
                        unExpValues.add(payloadLabel);    
                    }
                    mapIdTounexpected.put(uniqueExtId,unExpValues);
                }
                if((String)drMap.get('externalId') != null && mapIdTounexpected.get(uniqueExtId).isEmpty()){
                    //put required fields that are missing in map 
                    for (String fieldName : requiredFields) {                    
                        if(String.isBlank(String.valueOf(drMap.get(fieldName)))&& uniqueExtId != null){
                            if (mapExtIdToMissingFld.containsKey(uniqueExtId)) {
                                mapExtIdToMissingFld.get(uniqueExtId).add(fieldName);
                            } else {
                                mapExtIdToMissingFld.put(uniqueExtId, new List<String>{fieldName});
                            }
                            isReqFieldsMissing = true; 
                        }
                    }
                    if(uniqueExtId != null && !isReqFieldsMissing){ 
                        mapOfExtIdtoValidDDR.put(uniqueExtId, drMap); 
                        if(drMap.containsKey('partnerFAEEmail')){
                            String tempPartnerFAEEmail = String.valueOf(drMap.get('partnerFAEEmail'));
                            String FAEMailToLowerCase = tempPartnerFAEEmail.toLowerCase();
                            partnerFAEMailToCheck.add(FAEMailToLowerCase);
                            if(drMap.containsKey('externalId')){
                                mapOfExtIdToPartnerFaeEmail.put((string)drMap.get('externalId'), FAEMailToLowerCase);
                            }
                        }
                    }
                }
                count++;
            }
            
            if(partnerFAEMailToCheck.size()>0){
                partnerFAEtoUser = PCC_checkValidPartnerFAE(partnerFAEMailToCheck);
            }
            
            for(String extId : mapOfExtIdToPartnerFaeEmail.keySet()){
                String partnerFAEmail = mapOfExtIdToPartnerFaeEmail.get(extId);
                if(partnerFAEtoUser.containsKey(partnerFAEmail)){
                    mapOfExtIdToOwnerId.put(extId, partnerFAEtoUser.get(partnerFAEmail));
                }
            }
            
            if(mapOfExtIdToOwnerId!= null && !mapOfExtIdToOwnerId.isEmpty()){
                validExternalIdValue = PCC_checkDuplicateExtId(mapOfExtIdToOwnerId, DESIGN_REG);
            }
            //  }
            
            //create DDR instance for valid DDR's
            if(mapOfExtIdtoValidDDR.size()>0){ 
                mapExtIdToValidDr = createDRInstance(mapOfExtIdtoValidDDR,INSERT_ACTION, mapExistingDDR, partnerFAEtoUser, validExternalIdValue);
                ddrListToInsert = mapExtIdToValidDr.values();
            }
            
            //System.debug('mapExtIdToValidDr--->'+mapExtIdToValidDr);
            //insert records from payload that have an external id's
            // Vinita's Changes -- for adding DR/DRP Name in response
            List<Id> drids=new List<Id>();
            if (!ddrListToInsert.isEmpty()) {
                Integer i = 0;
                for(Database.SaveResult sr: Database.insert(ddrListToInsert, false)){
                    if (sr.isSuccess()) {
                        drids.add(sr.getId());
                    }
                    mapDrRecordSaveResult.put(ddrListToInsert[i], sr);
                    i++;
                }
            }
            
            Map<Id,String> namesDr = new Map<Id,String> ();
            if( drids.size() >0){
                namesDr= getNameDDR(drids);
                system.debug(namesDr);
            }
            
            //get response of records that are successfully inserted and the records that have errors
            PCC_Wrapper.PCC_DRDetailsWrapper drProductWrp = getDDRObjectResponses(mapIdTounexpected,mapOfCountToDrmap , mapExtIdToMissingFld, mapExtIdToValidDr, 
                                                                                  mapExtIdtoInvalidValMsg, mapDrRecordSaveResult, null,null,INSERT_ACTION, DESIGN_REG,namesDr);
            
            //get statusCode based on successful or failed record count
            res.statusCode = getStatusCode(listOfPayloads.size(), drProductWrp.successfulRecordCount, drProductWrp.failedRecordCount);
            
            //set responsebody
            res.responseBody = Blob.valueOf(JSON.serialize(drProductWrp.respList));
        }catch(exception ex){ Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY, '', '', '', 'PCC_CreateDDRUtilityHandler_V2.createDesignRegistrationRec', '', ex);
                            }
        return res;
    }
    
    /*****************************************************************************************************************
* Method Name: updateDesignRegistrationRecords
* Date: 06/2024  
* Owner: Manasa
* Description: This is a handler method to Update DDR records based on the payload received
* Return: Returns RestResponse with successful and error messages to external systems
******************************************************************************************************************/
    public static RestResponse updateDesignRegistrationRecords(List<Object> DDRWrapList){
        RestResponse res = RestContext.response;
        Map<Object, Database.SaveResult> mapDrRecordSaveResult = new Map<Object, Database.SaveResult>();  
        Map<String,String> mapOfRecIdToExtId = new Map<String,String>();
        List<Core_Design_Registration__c> validDRList = new List<Core_Design_Registration__c>();
        Map<Id,Core_Design_Registration__c> existingDDR = new Map<Id,Core_Design_Registration__c>();
        Map<String, String> drProductApiToLabelMap = PCC_Constants.drProductApiToLabelMap;
        map<String,Map<String,Object>> mapIdToWrapMap = new map<String,map<string,Object>>();
        Map<String, List<String>> mapExtIdToMissingFld = new Map<String, List<String>>();
        Map<Integer,Map<String,Object>> mapIdToWrapMapAll= new Map<Integer,Map<String,Object>>();
        Map<String, Core_Design_Registration__c> mapOfIdToInstance = new Map<String, Core_Design_Registration__c>();
        Map<String,Map<String,Object>> mapValidIdToWrap = new Map<String,Map<String,Object>>();
        Map<Id,string> mapOfRecIdToApprovedDr = new Map<Id,string>();
        List<Core_Design_Registration__c> drProductListToUpdate = new List<Core_Design_Registration__c>();
        List<String> partnerFAEMailToCheck = new List<String>();
        Map<String, String> partnerFAEtoUser = new Map<String, String>();
        Integer DDRCount = 0;
        Map<String,list<string>> mapIdTounexpected = new Map<String,list<string>>();
        List<String> requiredFieldsApi = Label.PCC_DDR_Required_Fields_API_V2.split(',');
        List<id> validDrIds = new list<id>();
        try{
            //Iterating over the wrapper list 
            for(Object reqWrap : DDRWrapList){                
                Map<String, Object> drMap = (Map<String, Object>)reqWrap;
                mapIdToWrapMapAll.put(DDRCount,drMap);
                
                if(drMap.containskey('recordId') && (String)drMap.get('recordId')!=null && (String)drMap.get('recordId')!=''){
                    mapIdToWrapMap.put((String)drMap.get('recordId'),drMap);
                }
                DDRCount++;
                list<string> unExpValues =new List<String>();
                if(!mapIdToWrapMap.isEmpty()){
                    for(string payloadLabel : drMap.keyset()){
                        string recid=(string)drMap.get('recordId');
                        if(!PCC_Constants.allowedFieldsPutDR.contains(payloadLabel) /*&& !string.isEmpty(((string)drMap.get(payloadLabel)))*/){
                            unExpValues.add(payloadLabel);    
                        }
                       
                     if(!unExpValues.isEmpty()){
                            mapIdTounexpected.put(recid,unExpValues);
                     }
                    }
                }
            }
            
            if(!mapIdToWrapMap.isEmpty()){
                validDRList = validDrRecords(mapIdToWrapMap);
                
                if(validDRList.size()>0){
                    for(Core_Design_Registration__c vl:validDRList){                    
                        validDrIds.add(vl.id);
                        existingDDR.put(vl.Id,vl);                    
                        mapOfRecIdToExtId.put(string.valueof(vl.Id),vl.Core_External_Id__c);                                    
                    }   
                } 
            }
            if(!mapIdToWrapMap.isEmpty()){
                
               // Boolean requiredFieldsMissing = false;
                if (!validDRList.isEmpty() && !existingDDR.isEmpty()) {               
                    for(Core_Design_Registration__c dr : validDRList){
                        Boolean requiredFieldsMissing = false;
                        system.debug('insideeeee for');
                        system.debug('inside for unexp'+mapIdTounexpected);
                        if(!mapIdTounexpected.containskey(dr.id)){
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
                        if(!requiredFieldsMissing){
                            // if(dr.Core_Design_Registration_Status_Nm__c != 'Approved' && dr.Core_Design_Registration_Status_Nm__c != 'Rejected' 
                            //    && dr.Core_Design_Registration_Status_Nm__c != 'Cancelled' && dr.Core_Design_Registration_Status_Nm__c != 'Abandoned'){
                            List<String> DDRStatuses = LabelConfiguration__mdt.getInstance('PCC_DDR_Statuses').Value__c.split(':'); //sushmita
                            if(!DDRStatuses.contains(dr.Core_Design_Registration_Status_Nm__c)){
                                //mapOfRecIdToApprovedDr.put(dr.Id, dr);
                                mapValidIdToWrap.put(dr.Id,mapIdToWrapMap.get(dr.Id));
                                if(mapIdToWrapMap.get(dr.id).containsKey('partnerFAEEmail')){
                                    String tempPartnerFAEEmail = (string)mapIdToWrapMap.get(dr.id).get('partnerFAEEmail');
                                    partnerFAEMailToCheck.add(tempPartnerFAEEmail.toLowerCase());
                                }  
                            }else{
                                mapOfRecIdToApprovedDr.put(dr.Id, dr.Core_Design_Registration_Status_Nm__c);
                            }    
                        } 
                        }
                    }      
                    if(partnerFAEMailToCheck.size()>0){
                        partnerFAEtoUser = PCC_checkValidPartnerFAE(partnerFAEMailToCheck);
                    }
                }    
            }
            //System.debug('mapValidIdToWrap----> '+mapValidIdToWrap);
            if(!mapValidIdToWrap.isEmpty()){
                mapOfIdToInstance = PCC_CreateDDRUtilityHandler_V2.createDRInstance(mapValidIdToWrap,UPDATE_ACTION,existingDDR, partnerFAEtoUser, null);
                drProductListToUpdate = mapOfIdToInstance.values();
            }
            
            //System.debug('mapOfIdToInstance----> '+mapOfIdToInstance);
            // Vinita's Changes -- for adding DR/DRP Name in response
            List<Id> drids=new List<Id>();
            if (!drProductListToUpdate.isEmpty()) {
                Integer i = 0;
                for(Database.SaveResult sr: Database.update(drProductListToUpdate, false)){
                    if(sr.isSuccess()){
                        drids.add(sr.getId());
                    }
                    mapDrRecordSaveResult.put(drProductListToUpdate[i], sr);
                    i++;
                }
            }
            Map<Id,String> namesDr = new Map<Id,String> ();
            if( validDrIds.size() >0){
                namesDr= getNameDDR(validDrIds);
            }
            
            //get response of records that are successfully inserted and the records that have errors
            PCC_Wrapper.PCC_DRDetailsWrapper drWrp = PCC_CreateDDRUtilityHandler_V2.getDDRObjectResponses(mapIdTounexpected,mapIdToWrapMapAll, mapExtIdToMissingFld, mapOfIdToInstance, mapExtIdtoInvalidValMsg,
                                                                                                          mapDrRecordSaveResult, mapOfRecIdToExtId, mapOfRecIdToApprovedDr, UPDATE_ACTION, DESIGN_REG,namesDr);
            
            //get statusCode based on successful or failed record count
            res.statusCode = PCC_CreateDDRUtilityHandler_V2.getStatusCode(DDRWrapList.size(), drWrp.successfulRecordCount, drWrp.failedRecordCount);
            
            //set responsebody
            res.responseBody = Blob.valueOf(JSON.serialize(drWrp.respList));
            
        }
        catch(exception ex){ Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY, '', '', '', 'PCC_CreateDDRUtilityHandler_V2.updateDesignRegistrationRecords', '', ex);
                           }
        return res;
    }
    
    /*****************************************************************************************************************
* Method Name: createDRInstance
* Date: 04/06/2024    
* Owner: Shraddha
* Description: This is a method to create instances of Design Registration Product Object for valid payloads
* Return: Returns map with DR product List
******************************************************************************************************************/
    public static Map<String, Core_Design_Registration__c> createDRInstance( Map<String, Map<String, Object>> mapOfExtIdtoValidDDR, String Action, Map<Id,Core_Design_Registration__c> mapExistingDDR, Map<String, String> partnerFAEtoUser,List<String> validExternalIdValue){
        
        List<String> existingRquiredFields = Label.PCC_Create_DDR_Required_Fields.split(',');
        Set<String> processedExternalIds = new Set<String>(); // Keep track of processed external IDs
        Map<Id, String> drRecToStatusMap = new Map<Id, String>();
        Map<Id, Date> drRecToFrstCustShipDateMap = new Map<Id, Date>();
        Map<Id, Date> drRecToProdEndDateMap = new Map<Id, Date>();
        Map<String, Core_Design_Registration__c> mapExtIdToValidDr = new Map<String, Core_Design_Registration__c>();
        // Country Mapping
        Map<string,string> countryMap = new map<string,string>();
        for(Core_Country_Code_Mapping__c allCountries : Core_Country_Code_Mapping__c.getAll().values()) {
            countryMap.put(allCountries.Country_Code__c,allCountries.Name);
        }
        system.debug('countrynames'+countryMap);
        try{
            String objectName = 'Core_Design_Registration__c';
            Map<String,List<String>> controlValueWrapMap = getDependentvaluesList(objectName,'Core_Product_Application_Nm__c');
            PCC_Wrapper.PCC_checkDdrDrp drDrpWrp = checkForDrAndDrp(mapOfExtIdtoValidDDR);
            Map<String, Integer> mapOfDrToDRPCnt = new Map<String, Integer>();
            Map<String, String> mapOfDrToDrstatus = new Map<String, String>();
            if(Action == UPDATE_ACTION){
                drDrpWrp = checkForDrAndDrp(mapOfExtIdtoValidDDR);
                mapOfDrToDRPCnt = drDrpWrp.mapOfDrToDRPCnt;
                mapOfDrToDrstatus = drDrpWrp.mapOfDrToDrstatus;
            }
            
            for (Core_Design_Registration__c dr : [SELECT Id, Core_Design_Registration_Status_Nm__c, Core_First_Customer_Ship_Dt__c, Core_Production_End_Dt__c FROM Core_Design_Registration__c WHERE Id IN :mapOfExtIdtoValidDDR.keySet()]) {                
                drRecToStatusMap.put(dr.Id, dr.Core_Design_Registration_Status_Nm__c);
                drRecToFrstCustShipDateMap.put(dr.Id, dr.Core_First_Customer_Ship_Dt__c);
                drRecToProdEndDateMap.put(dr.Id, dr.Core_Production_End_Dt__c);
            }
            List<PCC_ODR_Onboarding_Matrix__c> lstDesignReg = [SELECT PCC_Account__r.Id FROM PCC_ODR_Onboarding_Matrix__c];
            List<string> acctId = new List<string>();
            for(PCC_ODR_Onboarding_Matrix__c iDesign : lstDesignReg) {
                acctId.add(iDesign.PCC_Account__r.Id);
            }
            List<Contact> lstContact = [SELECT Email FROM Contact where AccountId IN: acctId];
            List<string> mailsId = new List<string>();
            for(Contact iDesign : lstContact) {
                mailsId.add(iDesign.Email);
            }
            
            if(mapOfExtIdtoValidDDR.size() > 0){
                
                for(string str: mapOfExtIdtoValidDDR.keySet()){
                    
                    //String recordId = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('recordId')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('recordId')) : null;
                    String externalId = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('externalId')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('externalId')) : null;
                    String productGroup = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('productGroup')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('productGroup')) : null;
                    //String productGroup = mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('productGroup') ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('productGroup')) : null;
                    String militaryAerospaceGvrnmtUseInd = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('militaryAerospaceGvrnmtUseInd')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('militaryAerospaceGvrnmtUseInd')) : null;
                    String verticalMarket = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('verticalMarket')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('verticalMarket')) : null;
                    String productSegment = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('productSegment')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('productSegment')) : null;
                    String productApplication = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('productApplication')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('productApplication')) : null;
                    String opportunityVolume = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('opportunityVolume')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('opportunityVolume')) : null;
                    String partnerFAE = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('partnerFAE')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('partnerFAE')) : null;
                    String endCustomerName = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerName')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('endCustomerName')) : null;
                    String endCustomerAddress1 = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerAddress1')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('endCustomerAddress1')) : null;
                    String endCustomerPostalCode = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerPostalCode')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('endCustomerPostalCode')) : null;
                    String endCustomerCountry = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerCountry')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('endCustomerCountry')) : null;
                    String endCustomerUrl = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerUrl')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('endCustomerUrl')) : null;
                    String designDecisionDate = (mapOfExtIdtoValidDDR.containsKey(str) && mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('designDecisionDate')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('designDecisionDate')) : null;
                    String firstCustomerShipDate = (mapOfExtIdtoValidDDR.containsKey(str) && mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('firstCustomerShipDate')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('firstCustomerShipDate')) : null;
                    String productionEndDate = (mapOfExtIdtoValidDDR.containsKey(str) && mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('productionEndDate')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('productionEndDate')) : null;
                    String intelPlatform = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('intelPlatform')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('intelPlatform')) : null;
                    String designRegistrationName = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('designRegistrationName')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('designRegistrationName')) : null;
                    String description = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('description')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('description')) : null;
                    String partnerFSR = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('partnerFSR')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('partnerFSR')) : null;
                    String endCustomerAddress2 = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerAddress2')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('endCustomerAddress2')) : null;
                    String endCustomerCity = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerCity')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('endCustomerCity')) : null;
                    String endCustomerState = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerState')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('endCustomerState')) : null;
                    String endCustomerContactTitle = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerContactTitle')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('endCustomerContactTitle')) : null;
                    String endCustomerContactName = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerContactName')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('endCustomerContactName')) : null;
                    String endCustomerContactEmail = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerContactEmail')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('endCustomerContactEmail')) : null;
                    String endCustomerContactPhone = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('endCustomerContactPhone')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('endCustomerContactPhone')) : null;
                    String manufacturingRegion = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('manufacturingRegion')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('manufacturingRegion')) : null;
                    String partnerFAEEmail = (mapOfExtIdtoValidDDR.get(str) != null &&mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('partnerFAEEmail') )? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('partnerFAEEmail')) : null;
                    String status = (mapOfExtIdtoValidDDR.get(str) != null && mapOfExtIdtoValidDDR.get(str).containsKey('status')) ? String.valueOf(mapOfExtIdtoValidDDR.get(str).get('status')) : null;
                    
                    Date firstCustShipDt, desgDecisionDt, prodEndDt;  
                    if(firstCustomerShipDate != null && !String.isBlank(firstCustomerShipDate)){
                        try{
                            firstCustShipDt =  Date.valueOf(firstCustomerShipDate);
                        }catch(exception ex){
                            mapExtIdtoInvalidValMsg.put(str,LabelConfiguration__mdt.getInstance('PCC_ErrMsg_FirstCustShipDt_PostDDR').Value__c);
                            continue;
                        }
                    }
                    
                    if(designDecisionDate != null && !String.isBlank(designDecisionDate)){
                        try{
                            desgDecisionDt =  Date.valueOf(designDecisionDate);
                        }catch(exception ex){
                            mapExtIdtoInvalidValMsg.put(str,LabelConfiguration__mdt.getInstance('PCC_ErrMsg_designDecisionDate_PostDDR').Value__c);
                            continue;
                        }
                    }
                    
                    if(productionEndDate != null && !String.isBlank(productionEndDate)){
                        try{
                            prodEndDt =  Date.valueOf(productionEndDate);
                            
                        }catch(exception ex){
                            mapExtIdtoInvalidValMsg.put(str,LabelConfiguration__mdt.getInstance('PCC_ErrMsg_productionEndDate_PostDDR').Value__c);
                            continue;
                        }
                    }
                    
                    Core_Design_Registration__c drRec = new Core_Design_Registration__c();
                    //System.debug('drRec.Core_External_Id__c--> '+drRec.Core_External_Id__c);
                    
                    if(partnerFAEtoUser!=null && partnerFAEEmail!=null){
                        String FAEEmailtoLowerCase = partnerFAEEmail.toLowerCase();
                        if(partnerFAEtoUser.containsKey(FAEEmailtoLowerCase)){
                            drRec.DDR_Partner_FAE_Email__c = FAEEmailtoLowerCase;
                            drRec.OwnerId = partnerFAEtoUser.get(FAEEmailtoLowerCase);
                        }else{
                            String errMsg = LabelConfiguration__mdt.getInstance('PCC_IncorrectPartnerFae_PostDDR').Value__c+ partnerFAEEmail;
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
                    //System.debug('EXTID----> '+externalId);
                    if(Action == INSERT_ACTION){
                        if(externalId!=null){
                            if (processedExternalIds.contains(externalId)) { //if the external id is used in the payload by more than 1 record.
                                //System.debug('inside1stIF-->');
                                String errMsg = LabelConfiguration__mdt.getInstance('PCC_RepeatingExtIdSamePayload_PostDDR').Value__c.replace('{1}',externalId);
                                mapExtIdtoInvalidValMsg.put(str, errMsg);
                                continue;
                            }
                            
                            if (validExternalIdValue != null && validExternalIdValue.contains(externalId)) {
                                //System.debug('inside2ndIF-->');
                                // Processed external IDs are added to the set here
                                processedExternalIds.add(externalId);
                                drRec.Core_External_Id__c = (String)mapOfExtIdtoValidDDR.get(str).get('externalId');
                            } else {
                                //System.debug('insideELSEEEE-->');
                                String errMsg = LabelConfiguration__mdt.getInstance('PCC_NonUniqueExtId_PostDDR').Value__c.replace('{1}',externalId);
                                mapExtIdtoInvalidValMsg.put(str, errMsg);
                                continue;
                            }
                            //System.debug('processedExternalIds----> '+processedExternalIds);
                        }
                        if(productSegment != null){
                             if(mailsId.contains(partnerFAEEmail))
							 {// odr
    							if(productSegment == 'Embedded / IOT' || productSegment == 'Comms Infra. / Networking')
								{
									drRec.Core_Product_Segment_Nm__c = productSegment;
								}
								else
								{
									mapExtIdtoInvalidValMsg.put(str,'Product segment validation'+productGroup);
                                    continue;
								}
							 }
							 else
							 {// non odr
    							drRec.Core_Product_Segment_Nm__c = productSegment;
							 }
                        }
                        if(productApplication != null){
                            drRec.Core_Product_Application_Nm__c = productApplication;
                        }
                        if(designDecisionDate != null){
                            if(Date.valueOf(designDecisionDate) >= System.today()){
                                drRec.Core_Opportunity_Decision_Dt__c = Date.valueOf(designDecisionDate);
                            }else{
                                mapExtIdtoInvalidValMsg.put(str,LabelConfiguration__mdt.getInstance('PCC_PastDescisionDate_PostDDR').Value__c);
                                continue;
                            }
                        }
                        if(firstCustomerShipDate != null){
                            if((firstCustShipDt > System.today()) && ((firstCustShipDt < prodEndDt)) && ((firstCustShipDt > desgDecisionDt))){
                                drRec.Core_First_Customer_Ship_Dt__c = firstCustShipDt;
                            }else{
                                mapExtIdtoInvalidValMsg.put(str,LabelConfiguration__mdt.getInstance('PCC_PastFirstCustShipDt_PostDDR').Value__c);
                                continue;
                            }
                        }
                        if(productionEndDate != null){
                            if(prodEndDt > System.today() && (prodEndDt > desgDecisionDt )){
                                drRec.Core_Production_End_Dt__c = prodEndDt;
                            }else{
                                mapExtIdtoInvalidValMsg.put(str,LabelConfiguration__mdt.getInstance('PCC_PastProdEndDt_PostDDR').Value__c);
                                continue;
                            }
                        }
                        if(designRegistrationName!= null && !String.isBlank(designRegistrationName)){
                            drRec.Core_Design_Registration_Nm__c = designRegistrationName;
                        }/*else{
String concatDate = String.valueOf(System.today().year()) + String.valueOf(System.today().month()) + String.valueOf(System.today().day());
String concatTime = String.valueOf(System.now().hour()) + String.valueOf(System.now().minute()) + String.valueOf(System.now().second());
drRec.Core_Design_Registration_Nm__c = 'DDR_'+userInfo.getName()+'_'+concatDate+'_'+concatTime;
}*/
                        drRec.Core_Submission_Type__c = 'M2M';  
                        drRec.Workflow_Status__c = 'Draft';
                        drRec.Core_Design_Registration_Status_Nm__c = 'Draft';
                        drRec.RecordTypeId = Schema.SObjectType.Core_Design_Registration__c.getRecordTypeInfosByDeveloperName().get('Design_Registration_Partner_Draft').getRecordTypeId();
                    }
                    else if(Action == UPDATE_ACTION){
                        
                        
                        drRec.Id = str ;
                        
                        Boolean isRequiredFieldBlank = false;
                        for(String reqField : mapOfExtIdtoValidDDR.get(str).keySet()){
                            String fieldValue= String.valueOf(mapOfExtIdtoValidDDR.get(str).get(reqField));
                            if(existingRquiredFields.contains(reqField) && String.isBlank(fieldValue)){
                                mapExtIdtoInvalidValMsg.put(drRec.Id,LabelConfiguration__mdt.getInstance('PCC_ReqFieldBlankingOut_PutDDR').Value__c + reqField + '.');
                                isRequiredFieldBlank = true;
                                break;
                            }
                        }
                        
                        if(isRequiredFieldBlank){
                            continue;
                        }
                        
                        Core_Design_Registration__c existingDDRId = mapExistingDDR.get(str);
                        Date existingDecisionDate=existingDDRId.Core_Opportunity_Decision_Dt__c;
                        Date existingProductionEndDate=existingDDRId.Core_Production_End_Dt__c;
                        Date existingFirstCustShipDate=existingDDRId.Core_First_Customer_Ship_Dt__c;
                        List<String> dependentValues = new List<String>();
                        //drRec.id = recordId!=null ? recordId :  existingDDRId.id;
                        String controllingValue;
                        if(productSegment!=null && productApplication!=null){
                            dependentValues = controlValueWrapMap.containsKey(productSegment) ? controlValueWrapMap.get(productSegment) : null;
                            if(dependentValues!= null){
                                if(dependentValues.contains(productApplication)){
                                    drRec.Core_Product_Segment_Nm__c = productSegment;
                                    drRec.Core_Product_Application_Nm__c = productApplication;
                                }else{
                                    mapExtIdtoInvalidValMsg.put(drRec.Id,LabelConfiguration__mdt.getInstance('PCC_ParentToChildMapping_PutDDR').Value__c);
                                    continue;
                                }
                            }
                            else{
                                mapExtIdtoInvalidValMsg.put(drRec.Id,LabelConfiguration__mdt.getInstance('PCC_InvalidProdSegmentVal_PutDDR').Value__c);
                                continue;
                            }
                        }else{                       
                            if(productSegment!=null){
                                dependentValues = controlValueWrapMap.containsKey(productSegment) ? controlValueWrapMap.get(productSegment) : null;
                                if(dependentValues!= null){
                                    if(dependentValues.contains(existingDDRId.Core_Product_Application_Nm__c)){
                                        drRec.Core_Product_Segment_Nm__c = productSegment;  
                                    }else{    
                                        //Parent field value is not supported by the Child field value
                                        mapExtIdtoInvalidValMsg.put(drRec.Id,LabelConfiguration__mdt.getInstance('PCC_ProdSegToProdAppUpdate_PutDDR').Value__c);
                                        continue;
                                    }
                                    controllingValue=productSegment; 
                                }else{    
                                    //Parent field value is incorrect
                                    mapExtIdtoInvalidValMsg.put(drRec.Id,LabelConfiguration__mdt.getInstance('PCC_InvalidProdSegmentVal_PutDDR').Value__c);
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
                                    mapExtIdtoInvalidValMsg.put(drRec.Id,LabelConfiguration__mdt.getInstance('PCC_ProdSegToProdAppUpdate_PutDDR').Value__c);
                                    continue;
                                }
                            }
                        }
                        if(designRegistrationName!= null){
                            drRec.Core_Design_Registration_Nm__c = designRegistrationName;    
                        }
                        //Decision date should not be editable                  
                        if(designDecisionDate != null ){
                            if ((!drRecToStatusMap.isEmpty() && drRecToStatusMap.get(drRec.Id) == 'Draft' && Date.valueOf(designDecisionDate) >= System.today() 
                                 && (
                                     (firstCustomerShipDate != null &&  Date.valueOf(designDecisionDate) <  Date.valueOf(firstCustomerShipDate))
                                     || (productionEndDate != null &&  Date.valueOf(designDecisionDate) <  Date.valueOf(productionEndDate))
                                 )
                                )||(!drRecToStatusMap.isEmpty() && drRecToStatusMap.get(drRec.Id) == 'Draft' && Date.valueOf(designDecisionDate) >= System.today()
                                    && ((!drRecToFrstCustShipDateMap.isEmpty() && Date.valueOf(designDecisionDate) < drRecToFrstCustShipDateMap.get(drRec.Id)) 
                                        && (!drRecToProdEndDateMap.isEmpty() && Date.valueOf(designDecisionDate) < drRecToProdEndDateMap.get(drRec.Id)))
                                   )
                               )   
                            {
                                drRec.Core_Opportunity_Decision_Dt__c = Date.valueOf(designDecisionDate);
                            }else if(!drRecToStatusMap.isEmpty() && drRecToStatusMap.get(drRec.Id) == 'Draft' && (Date.valueOf(designDecisionDate) < System.today()
                                                                                                                  || (!drRecToFrstCustShipDateMap.isEmpty() && Date.valueOf(designDecisionDate) >= drRecToFrstCustShipDateMap.get(drRec.Id)) 
                                                                                                                  || (!drRecToProdEndDateMap.isEmpty() && Date.valueOf(designDecisionDate) >= drRecToProdEndDateMap.get(drRec.Id)))){
                                                                                                                      System.debug('Inside elseif-->');
                                                                                                                      mapExtIdtoInvalidValMsg.put(drRec.Id,LabelConfiguration__mdt.getInstance('PCC_DecisionEndDate_PutDDR').Value__c);
                                                                                                                      continue;
                                                                                                                  }
                            else{
                                System.debug('Inside else-->');
                                mapExtIdtoInvalidValMsg.put(drRec.Id,LabelConfiguration__mdt.getInstance('PCC_NonEditableDecisionDt_PutDDR').Value__c);
                                system.debug('mapExtIdtoInvalidValMsg--> '+mapExtIdtoInvalidValMsg);
                                continue;
                            }
                        }
                        
                        if(firstCustomerShipDate != null){                                                               
                            // Check if production end date is present in payload then check first customer ship date is before production end date and after existing decision date from org                                
                            if(productionEndDate != null){
                                if((firstCustShipDt < prodEndDt) && (firstCustShipDt > existingDecisionDate)){
                                    drRec.Core_First_Customer_Ship_Dt__c = firstCustShipDt;
                                }else{
                                    String errMsg = LabelConfiguration__mdt.getInstance('PCC_FirstCustShipDtValidation1_PutDDR').Value__c.replace('{1}',string.valueOf(existingDecisionDate));
                                    mapExtIdtoInvalidValMsg.put(drRec.Id,errMsg);
                                    continue;
                                }
                            }else{
                                //If production date is not present in payload compare it with existing product end date and decision date
                                if((firstCustShipDt < existingProductionEndDate) && (firstCustShipDt > existingDecisionDate)){
                                    drRec.Core_First_Customer_Ship_Dt__c = firstCustShipDt;
                                }else{
                                    String errMsg = LabelConfiguration__mdt.getInstance('PCC_FirstCustShipDtValidation2_PutDDR').Value__c.replace('{1}',string.valueOf(existingProductionEndDate)).replace('{2}', string.valueOf(existingDecisionDate));
                                    mapExtIdtoInvalidValMsg.put(drRec.Id,errMsg);
                                    continue;
                                }  
                            }       
                        }
                        if(productionEndDate != null){   
                            //Check if production end date is after decision date or first customer ship date in org
                            if(firstCustomerShipDate != null){
                                if((prodEndDt > existingDecisionDate ) && (prodEndDt >existingFirstCustShipDate)){
                                    drRec.Core_Production_End_Dt__c = prodEndDt;
                                }else{
                                    String errMsg = LabelConfiguration__mdt.getInstance('PCC_ProdEndDtValidation1_PutDDR').Value__c.replace('{1}',string.valueOf(existingDecisionDate));
                                    mapExtIdtoInvalidValMsg.put(drRec.Id,errMsg);
                                    continue;
                                }
                            }else{  
                                if((prodEndDt > existingDecisionDate ) && (prodEndDt >existingFirstCustShipDate)){
                                    drRec.Core_Production_End_Dt__c = prodEndDt;
                                }else{
                                    String errMsg = LabelConfiguration__mdt.getInstance('PCC_ProdEndDtValidation2_PutDDR').Value__c.replace('{1}',string.valueOf(existingDecisionDate)).replace('{2}',string.valueOf(existingFirstCustShipDate));
                                    mapExtIdtoInvalidValMsg.put(drRec.Id,errMsg);
                                    continue;
                                }
                            }
                        } 
                        
                        if(status == 'Submitted'){
                            if(mapOfDrToDRPCnt.get(drRec.Id) == 0){
                                mapExtIdtoInvalidValMsg.put(drRec.Id,System.Label.PCC_ProductsMessage);
                            }else{
                                drRec.Workflow_Status__c = 'Submitted';
                                drRec.Core_Design_Registration_Status_Nm__c = 'Submitted';
                            }  
                        }
                        if(mapOfDrToDrstatus.get(drRec.Id) != 'Draft'  && status != null && mapOfDrToDrstatus.get(drRec.Id) != status){
                            mapExtIdtoInvalidValMsg.put(drRec.Id,'This record is already Submitted for Approval. You cannot change the status field. Please remove the status field from the payload before updating the record.');
                            continue;
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
                        //drRec.Core_End_Customer_Country_Nm__c = endCustomerCountry;
                        system.debug('endcst'+endCustomerCountry);
                        system.debug('countryMap.get(endCustomerCountry);'+countryMap.get(string.valueof(endCustomerCountry)));
                        if((countryMap.get(string.valueof(endCustomerCountry)))!= null){
                            drRec.PCC_End_Customer_Country__c = countryMap.get(string.valueof(endCustomerCountry)); 
                        }else{
                            mapExtIdtoInvalidValMsg.put(str,LabelConfiguration__mdt.getInstance('PCC_EndCustomerInvalid').Value__c); 
                            continue;
                        }
                        
                    }
                    if(endCustomerUrl != null){
                        drRec.Core_End_Customer_URL__c = endCustomerUrl;
                    }
                    if(intelPlatform != null){
                        drRec.Core_Intel_Platform_Nm__c = intelPlatform;
                    }
                    if(opportunityVolume != null){
                        try{
                            drRec.Core_Opportunity_Volume_Cnt__c = Integer.valueOf(opportunityVolume);
                        }catch(exception ex){
                            mapExtIdtoInvalidValMsg.put(str,LabelConfiguration__mdt.getInstance('PCC_OppVolNumberFrmt_PostDDR').Value__c);
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
        }catch (Exception ex) { Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateDDRUtilityHandler_V2.createDRInstance' ,'' ,ex); 
                              }
        return mapExtIdToValidDr;
    }
    
    
    /*****************************************************************************************************************
* Method Name: getDDRObjectResponses
* Date: 04/06/2024 
* Description: This is a generic method to Get responses of the records that are successfully inserted and the records that have an errors
* Return: Returns PCC_DRDetailsWrapper with response List with successful message or user friendly errors
******************************************************************************************************************/
    public static PCC_Wrapper.PCC_DRDetailsWrapper getDDRObjectResponses(Map<String,list<string>> mapIdTounexpected,Map<Integer, Map<String, Object>> listOfDrmap, Map<String, List<String>> mapExtIdToMissingFld,
                                                                         Map<String, Object> mapExtIdToValidDr, Map<String, String> mapExtIdtoInvalidValMsg,
                                                                         Map<object, Database.SaveResult> mapDrRecordSaveResult,
                                                                         Map<String,String> mapOfRecIdToExtId, Map<Id,string> mapOfRecIdToApprovedDr, 
                                                                         String Action, String objectName, Map<Id,String> namesDr)
    {
        // Set<String> errorString;      
        String errorMsgForLogEntry = '';
        Integer failedRecordCount = 0;
        Integer successfulRecordCount = 0;
        List<PCC_Wrapper.restAPIResponseWrapper> respList = new List<PCC_Wrapper.restAPIResponseWrapper>();   
        PCC_Wrapper.PCC_DRDetailsWrapper drProductWrp = new PCC_Wrapper.PCC_DRDetailsWrapper();  
        //  Map<String, String> drProductApiToLabelMap = PCC_Constants.drProductApiToLabelMap;
        String uniqueExtId, extId, uniqueId, successMsg, noexternalIdMsg, nameofdr;
        
        try{          
            Integer count = 0;
            System.debug('drMapppp----> '+listOfDrmap.values());
            System.debug('mapExtIdToValidDr----> '+mapExtIdToValidDr);
            
            for (Map<String, Object> drMap : listOfDrmap.values()) {
                System.debug('drMap----> '+drMap);
                PCC_Wrapper.restAPIInnerResponseWrapper irWrp = new PCC_Wrapper.restAPIInnerResponseWrapper();
                String recordId;
                if(Action == INSERT_ACTION){
                    successMsg = LabelConfiguration__mdt.getInstance('PCC_RecordSuccessfullyCreated').Value__c;
                    noexternalIdMsg = LabelConfiguration__mdt.getInstance('PCC_CorrectExtId').Value__c;
                    uniqueExtId = drMap.containsKey('externalId') ? (String)drMap.get('externalId') + count : String.valueOf(count);
                    extId = (String)drMap.get('externalId');
                    // Id check= (Id)
                    //nameofdr =namesDr.get(uniqueId);
                    
                }
                else if(Action == UPDATE_ACTION){
                    successMsg = LabelConfiguration__mdt.getInstance('PCC_RecordSuccessfullyUpdated').Value__c;
                    noexternalIdMsg = LabelConfiguration__mdt.getInstance('PCC_InvalidRecordId').Value__c; 
                    uniqueId = drMap.containsKey('recordId')?(String)drMap.get('recordId'):null;
                    uniqueExtId = uniqueId;
                    recordId = uniqueId;
                    extId = mapOfRecIdToExtId.get(uniqueId);
                    //nameofdr =namesDr.get(uniqueId);
                }
                // nameofdr=(String)drMap.get('Name');
                if(!string.isblank(uniqueId) && uniqueId != null && (uniqueId.length()==18) && namesDr.ContainsKey(uniqueId)){
                    nameofdr =namesDr.get(uniqueId);
                    
                }
                else{
                    nameofdr='';
                }
                irWrp.ExternalId = extId;
                system.debug('mapExtIdtoInvalidValMsg----'+mapExtIdtoInvalidValMsg);
                system.debug(' mapExtIdtoInvalidValMsg.containsKey(uniqueExtId)'+ mapExtIdtoInvalidValMsg.containsKey(uniqueExtId));
                system.debug('uniqueExtId'+uniqueExtId);
                system.debug('mapIdTounexpected--'+mapIdTounexpected);
                system.debug('mapExtIdToMissingFld--'+mapExtIdToMissingFld);
                //return error if the required fields are missing in payload
                /* if (mapExtIdToMissingFld != null && !mapExtIdToMissingFld.isEmpty() && mapExtIdToMissingFld.containsKey(uniqueExtId)) {
//System.debug('mapExtIdToMissingFld--> '+mapExtIdToMissingFld);
failedRecordCount++;
irWrp.Message =  LabelConfiguration__mdt.getInstance('PCC_ReqFieldMissing').Value__c+ mapExtIdToMissingFld.get(uniqueExtId) +'.';
respList.add(setJsonResponseBody(400, 'FAILURE', 9002, irWrp, recordId));
}*/
                if(uniqueExtId!=null && !mapIdTounexpected.isEmpty() && mapIdTounexpected.containsKey(uniqueExtId) &&
                   !((mapIdTounexpected.get(uniqueExtId)).isEmpty())){
                       failedRecordCount++; 
                       system.debug('mapIdTounexpected.get(uniqueExtId)'+mapIdTounexpected.get(uniqueExtId));
                       irWrp.Message = 'Unexpected fields in payload : '+ String.join(mapIdTounexpected.get(uniqueExtId), ',');
                       respList.add(setJsonResponseBody(400, 'FAILURE', 9002, irWrp, recordId,nameofdr));
                   }
                else if((mapExtIdToMissingFld != null && !mapExtIdToMissingFld.isEmpty() && mapExtIdToMissingFld.containsKey(uniqueExtId))
                        ||(mapOfRecIdToApprovedDr != null && !mapOfRecIdToApprovedDr.isEmpty() && mapOfRecIdToApprovedDr.containsKey(uniqueExtId))){
                            failedRecordCount++;
                            irWrp.Message = mapExtIdToMissingFld.containsKey(uniqueExtId)?(LabelConfiguration__mdt.getInstance('PCC_ReqFieldMissing').Value__c+ mapExtIdToMissingFld.get(uniqueExtId) +'.')
                                :LabelConfiguration__mdt.getInstance('PCC_ApprovedRecordUpdate_PutDDR').Value__c.replace('{1}',mapOfRecIdToApprovedDr.get(uniqueExtId));
                            respList.add(setJsonResponseBody(400, 'FAILURE', 9002, irWrp, recordId,nameofdr));
                        }
                //return error if the user sends invalid values to the fields in payload
                
                else if(mapExtIdtoInvalidValMsg != null && !mapExtIdtoInvalidValMsg.isEmpty() && mapExtIdtoInvalidValMsg.containsKey(uniqueExtId)){
                    failedRecordCount++;
                    irWrp.Message = mapExtIdtoInvalidValMsg.get(uniqueExtId);
                    Integer errCd = (irWrp.Message == LabelConfiguration__mdt.getInstance('PCC_MMIDorOrderingCdReq').Value__c) 
                        ? 9002 : 9011;
                    respList.add(setJsonResponseBody(400, 'FAILURE', errCd, irWrp, recordId, nameofdr));
                }
                /*else if(mapOfRecIdToApprovedDr != null && !mapOfRecIdToApprovedDr.isEmpty() && mapOfRecIdToApprovedDr.containsKey(uniqueExtId)){
failedRecordCount++;

irWrp.Message = LabelConfiguration__mdt.getInstance('PCC_ApprovedRecordUpdate_PutDDR').Value__c.replace('{1}',mapOfRecIdToApprovedDr.get(uniqueExtId));   
respList.add(setJsonResponseBody(400, 'FAILURE', 9002, irWrp, recordId));
}*/
                else if((objectName == DESIGN_REG_PROD && (Action != UPDATE_ACTION || mapExtIdToValidDr.containsKey(uniqueExtId))) 
                        || (objectName == DESIGN_REG && mapExtIdToValidDr.containsKey(uniqueExtId))){
                            System.debug(objectName);
                            PCC_Wrapper.PCC_DRDetailsWrapper resp = getSuccessFailureResp(mapDrRecordSaveResult,mapExtIdToValidDr,uniqueExtId,extId,successMsg,drMap,namesDr);
                            successfulRecordCount+= resp.successfulRecordCount;
                            failedRecordCount+=resp.failedRecordCount;
                            respList.addAll(resp.respList);
                            errorMsgForLogEntry= resp.errorMsgForLogEntry;
                            /*  Database.SaveResult sr = mapDrRecordSaveResult.get(mapExtIdToValidDr.get(uniqueExtId));
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
//getting fieldlist for which we are getting error
String fieldsNameList='';
if(err.getfields().size()>0){
for(String fn: err.getfields()){
fieldsNameList += drProductApiToLabelMap.get(fn);
}
}

String statusCode = String.valueOf(err.getStatusCode());
errMessage = getErrorMessages(fieldsNameList, statusCode, drMap, err, drProductApiToLabelMap);
Integer errCd = 9011;
irWrp.ExternalId = extId;
irWrp.Message = errMessage;
respList.add(setJsonResponseBody(400, 'FAILURE', errCd, irWrp , null));
errorString.add(fieldName + err.getMessage());
errorMsgForLogEntry += extId+' - '+err.getMessage()+'\n';
}
}
}
}*/
                        }
                else{ //return error if the requested record doesn't have an external id 
                    failedRecordCount++;
                    irWrp.ExternalId = null;
                    irWrp.Message = noexternalIdMsg;
                    respList.add(setJsonResponseBody(400, 'FAILURE',9002, irWrp, null,null));
                    errorMsgForLogEntry +=  LabelConfiguration__mdt.getInstance('PCC_MissingUniqueId').Value__c+'\n';
                }
                count++;
            }
            
            drProductWrp.failedRecordCount = failedRecordCount;
            drProductWrp.successfulRecordCount = successfulRecordCount;
            drProductWrp.respList = respList;
            if(failedRecordCount!=0){
                Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,LabelConfiguration__mdt.getInstance('PCC_ExceptionWhileInsertingDDR').Value__c ,errorMsgForLogEntry, '', '', '');
            }
            
        }catch (Exception ex) { Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateDDRUtilityHandler_V2.getDDRObjectResponses' ,'' ,ex); 
                              }
        return drProductWrp;
        
    }
    
    
    
    /*****************************************************************************************************************
* Method Name:getStatusCode
* Date: 04/06/2024    
* Owner: Sushmita
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
        }catch(exception ex){ Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY, '', '', '', 'PCC_CreateDDRUtilityHandler_V2.getStatusCode', '', ex);
                            }
        return statusCode;
        
    }  
    
    /***********************************************************************************************************************************************
* description: Check if PartnerFAE email exists on SF on the IPA contact and is set up with the proper IPA entitlements.
* return: returns list of valid PartnerFAE emails
* dev: Shraddha M 
* US: TWC729-5678
***********************************************************************************************************************************************/
    public static Map<String, String> PCC_checkValidPartnerFAE( List<String> partnerFAEMailToCheck){
        List<String> validPartnerFAEMail = new List<String>();
        //Boolean isValidEmail = false;
        // Set<Id> setOfconId = new Set<Id>();
        Map<String, String> partnerFAEtoUser = new Map<String, String>();
        String employeeEnt = LabelConfiguration__mdt.getInstance('PCC_Employee_Entitlement').Value__c;
        String completeStatus = LabelConfiguration__mdt.getInstance('PCC_Complete_Entitlement').Value__c;
        //check for IPA entitlements
        for(Core_Contact_Entitlement__c ce : [SELECT id, Core_Contact_Id__c, Core_Contact_Id__r.Email,
                                              Core_Status__c , Core_Contact_Id__r.Account.Core_Intel_Partner_Alliance_PartnerGroup__c 
                                              FROM Core_Contact_Entitlement__c 
                                              WHERE  Core_Display_Nm__c = :employeeEnt
                                              // Core_Entitlement_Id__r.Name = 'Employee'
                                              and Core_Status__c=:completeStatus and Core_Selected__c = true
                                              and Core_Contact_Id__r.Account.Core_Intel_Partner_Alliance_PartnerGroup__c = true
                                              and Core_Contact_Id__r.Email IN: partnerFAEMailToCheck
                                             ]
           ){
               validPartnerFAEMail.add(ce.Core_Contact_Id__r.Email);
           }
        
        if(validPartnerFAEMail.size() > 0){//active check
            //partnerFAEtoUser =  PCC_DDRUtilityHandler_WithoutSharing.checkPartnerFaeEmailUser(validPartnerFAEMail);
            for(user u: [SELECT Id, Name, Contact.Email, IsActive  
                         FROM User 
                         WHERE IsActive = true AND Contact.Email IN: validPartnerFAEMail]
               ){
                   partnerFAEtoUser.put(u.Contact.Email, u.Id);
               }
        }
        return partnerFAEtoUser;
    }   
    
    
    /***********************************************************************************************************************************************
* description: Checks if external id is unique for that particular account
* return: returns list of valid and account level unique externalIds 
* dev: Sushmita, Shraddha
* US: TWC729-5799
***********************************************************************************************************************************************/
    public static List<String> PCC_checkDuplicateExtId( Map<String, String> mapOfExtIdToOwnerId, String objName){ 
        
        //create a combination of extId and accountId from the requested Payload
        Map<String, String> extIdToAccountIdPayloadMap = new Map<String, String>();
        List<String> validExternalIdList = new List<String>();
        Map<String, Id> userIdToAcctIdReqPayloadMap = new Map<String, Id>();
        List<String> uniqueExistingExtIdAccountIDComb  = new List<String>();
        Map<String, Set<Id>> ddrExtIdToAccountIdPayloadMap = new Map<String, Set<Id>>();
        Set<String> existingExternalIds = new Set<String>();
        
        //Creating combination of externalId and AccountId from the requested Payload
        if(!mapOfExtIdToOwnerId.isEmpty()){
            for (User u : [SELECT id, ContactId, AccountId FROM user where IsActive = true AND ContactId != null AND id IN :mapOfExtIdToOwnerId.values()]){
                userIdToAcctIdReqPayloadMap.put(u.Id, u.AccountId);
            }
            
            //  if (!mapOfExtIdToOwnerId.isEmpty()) {
            for(String extId : mapOfExtIdToOwnerId.keySet()){
                String extIdAcctIdCombination = extId + userIdToAcctIdReqPayloadMap.get(mapOfExtIdToOwnerId.get(extId));
                extIdToAccountIdPayloadMap.put(extIdAcctIdCombination, extId);
            }
            // }
            //Get the combination of accountId of the existing ddr records and externalId
            //Query all ddr records with the externalIds sent in the payload     
            // if(!mapOfExtIdToOwnerId.isEmpty()){
            if(objName == DESIGN_REG){
                // Loop through the query results and collect the existing record's external ids in a set.
                for (Core_Design_Registration__c ddrRecord : [Select id, ownerId, Core_External_Id__c, Core_Partner_Account_Id__c 
                                                              from Core_Design_Registration__c 
                                                              where Core_External_Id__c IN :mapOfExtIdToOwnerId.keySet()]
                    ){
                        existingExternalIds.add(ddrRecord.Core_External_Id__c);
                        if (ddrExtIdToAccountIdPayloadMap.containsKey(ddrRecord.Core_External_Id__c)) { //if the external id is used by two records with different owners, this block will add those owners for taht external id
                            ddrExtIdToAccountIdPayloadMap.get(ddrRecord.Core_External_Id__c).add(ddrRecord.Core_Partner_Account_Id__c);
                        } else {
                            ddrExtIdToAccountIdPayloadMap.put(ddrRecord.Core_External_Id__c, new Set<Id>{ddrRecord.Core_Partner_Account_Id__c});
                        }
                    }
            } else if(objName == DESIGN_REG_PROD){
                // Loop through the query results and collect the existing record's external ids in a set.
                for (Core_Design_Registration_Product__c drp : [SELECT id, Core_External_Id__c, Core_Design_Registration_Id__r.Core_Partner_Account_Id__c 
                                                                FROM Core_Design_Registration_Product__c 
                                                                WHERE Core_External_Id__c IN :mapOfExtIdToOwnerId.keySet()]
                    ){
                        existingExternalIds.add(drp.Core_External_Id__c);
                        if (ddrExtIdToAccountIdPayloadMap.containsKey(drp.Core_External_Id__c)) { //if the external id is used by two records with different owners, this block will add those owners for taht external id
                            ddrExtIdToAccountIdPayloadMap.get(drp.Core_External_Id__c).add(drp.Core_Design_Registration_Id__r.Core_Partner_Account_Id__c);
                        } else {
                            ddrExtIdToAccountIdPayloadMap.put(drp.Core_External_Id__c, new Set<Id>{drp.Core_Design_Registration_Id__r.Core_Partner_Account_Id__c});
                        }
                    }
            }
            // }
            
            //Creating combination of externalId and AccountId from the existing recrds 
            if(!ddrExtIdToAccountIdPayloadMap.isEmpty() && ddrExtIdToAccountIdPayloadMap != null){
                for(String extId : ddrExtIdToAccountIdPayloadMap.keySet()){
                    Set<Id> AccountIdSet = ddrExtIdToAccountIdPayloadMap.get(extId);
                    for(Id AcctId : AccountIdSet){
                        String existingExtIdandAcctId = extId + AcctId;
                        uniqueExistingExtIdAccountIDComb.add(existingExtIdandAcctId);
                    }
                }
            }
            
            //to check if the external id is completely new and unique. if yes then add it to the validExternalIdList
            // if(!mapOfExtIdToOwnerId.isEmpty()){
            for (String externalId : mapOfExtIdToOwnerId.keySet()) {
                validExternalIdList.add(!existingExternalIds.contains(externalId) ? externalId : null);
            }
        }
        
        if(!uniqueExistingExtIdAccountIDComb.isEmpty() && !extIdToAccountIdPayloadMap.isEmpty()){
            for(String key : extIdToAccountIdPayloadMap.keySet()){
                validExternalIdList.add(!uniqueExistingExtIdAccountIDComb.contains(key) ? extIdToAccountIdPayloadMap.get(key) : null);
            }
        }
        
        return validExternalIdList;
    }
    
    
    /***********************************************************************************************************************************************
* description: Checks the number of DRP in a DR and checks the status of DR
* return: returns a wrapper containing maps
* dev: Sushmita
***********************************************************************************************************************************************/
    private static  PCC_Wrapper.PCC_checkDdrDrp  checkForDrAndDrp(Map<String, Map<String, Object>> mapOfExtIdtoValidDDR){
        Map<String, Integer> mapOfDrToDRPCnt = new Map<String, Integer>();
        Map<String, String> mapOfDrToDrstatus = new Map<String, String>();
        PCC_Wrapper.PCC_checkDdrDrp DrDrpWrapper = new PCC_Wrapper.PCC_checkDdrDrp ();
        
        List<Core_Design_Registration__c> ddrLst = [Select id, Core_Pending_Product_Cnt__c, Core_Design_Registration_Status_Nm__c 
                                                    From Core_Design_Registration__c 
                                                    Where Id in :mapOfExtIdtoValidDDR.keySet()];
        for(Core_Design_Registration__c dr : ddrLst){
            
            mapOfDrToDRPCnt.put(dr.Id, Integer.valueOf(dr.Core_Pending_Product_Cnt__c));
            mapOfDrToDrstatus.put(dr.Id, dr.Core_Design_Registration_Status_Nm__c);
        }
        
        DrDrpWrapper.mapOfDrToDRPCnt = mapOfDrToDRPCnt;
        DrDrpWrapper.mapOfDrToDrstatus = mapOfDrToDrstatus;
        return DrDrpWrapper;
    }
    
    /*****************************************************************************************************************
* Method Name: setDDRWrapper
* Date: 04/06/2024    
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
            ddrWrp.externalId = ddrRec.Core_External_Id__c; 
            ddrWrp.opportunityVolume = String.valueOf(ddrRec.Core_Opportunity_Volume_Cnt__c);
            ddrWrp.partnerFAE = ddrRec.Core_Partner_FAE_Nm__c;
            ddrWrp.partnerFSR = ddrRec.Core_Partner_FSR_Nm__c;
            ddrWrp.endCustomerName = ddrRec.Core_End_Customer_Nm__c;
            ddrWrp.endCustomerAddress1 = ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c;
            ddrWrp.endCustomerAddress2 = ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c;
            //ddrWrp.endCustomerCountry = ddrRec.Core_End_Customer_Country_Nm__c;
            ddrWrp.endCustomerCountry = returnCountryMappings().get(ddrRec.PCC_End_Customer_Country__c);
            ddrWrp.endCustomerCity = ddrRec.Core_End_Customer_City_Nm__c;
            ddrWrp.endCustomerState = ddrRec.Core_End_Customer_Country_Subdivision_Nm__c;
            ddrWrp.endCustomerPostalCode = ddrRec.Core_End_Customer_Postal_Cd__c;
            ddrWrp.endCustomerContactTitle = ddrRec.Core_End_Customer_Contact_Title_Txt__c;
            ddrWrp.endCustomerContactName = ddrRec.Core_End_Customer_Contact_Nm__c;
            ddrWrp.endCustomerContactEmail = ddrRec.Core_End_Customer_Contact_Email_Txt__c;
            ddrWrp.endCustomerContactPhone = ddrRec.Core_End_Customer_Contact_Phone_Txt__c;
            ddrWrp.endCustomerUrl = ddrRec.Core_End_Customer_URL__c;
            ddrWrp.manufacturingRegion = ddrRec.Core_Manufacturing_Region_Cd__c;
            ddrWrp.firstCustomerShipDate = ddrRec.Core_First_Customer_Ship_Dt__c;
            ddrWrp.intelPlatform = ddrRec.Core_Intel_Platform_Nm__c;
            ddrWrp.designRegistrationName = ddrRec.Core_Design_Registration_Nm__c;
            ddrWrp.description = ddrRec.Core_Design_Registration_Dsc__c;
            ddrWrp.status = ddrRec.Core_Design_Registration_Status_Nm__c;
            ddrWrp.rejectionReason = ddrRec.Core_Rejection_Reason_Nm__c;
            ddrWrp.rejectionComment = ddrRec.Core_Rejection_Comment_Txt__c;
            ddrWrp.opportunityId = String.valueof(ddrRec.Core_Opportunity_Id__c);
            ddrWrp.designSolutionNetwork = (ddrRec.Core_Design_Solution_Network_Ind__c) ? 'true' : 'false';            
            ddrWrp.mindsMessage = ddrRec.Core_MINDS_Message_Txt__c;
            ddrWrp.fpgaQuoteComments = ddrRec.Core_FPGA_Quote_Comments_Txt__c;
            ddrWrp.partnerAccount = ddrRec.Core_Partner_Account_Nm__c;
            ddrWrp.endCustomerAccount = ddrRec.Core_End_Customer_Account_Nm__c;
            ddrWrp.intelTechnicalOwner = ddrRec.PCC_Intel_Technical_Owner_Name__c;
            ddrWrp.designDecisionDate = ddrRec.Core_Opportunity_Decision_Dt__c;
            ddrWrp.productionEndDate = ddrRec.Core_Production_End_Dt__c;
        }catch (Exception ex){ Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateDDRUtilityHandler_V2.setDDRWrapper' ,'' ,ex); 
                             }
        return ddrWrp;
    } 
    
    /*****************************************************************************************************************
* Method Name: setDDRProdWrapper
* Date: 04/06/2024    
* Owner: Sushmita
* Description: This is a method to create PCC_DDRDetailsWrapper instance using design registration prod record
* Return: Returns PCC_DDRDetailsWrapper
******************************************************************************************************************/    
    public static List<PCC_Wrapper.PCC_DDRDetailsWrapper> setDDRProdWrapper(List<Core_Design_Registration_Product__c> drpRecList){
        List<PCC_Wrapper.PCC_DDRDetailsWrapper> drpWrpList = new List<PCC_Wrapper.PCC_DDRDetailsWrapper>();
        try{
            for(Core_Design_Registration_Product__c drProduct : drpRecList){
                PCC_Wrapper.PCC_DDRDetailsWrapper ddrProductWrp = new PCC_Wrapper.PCC_DDRDetailsWrapper();
                ddrProductWrp.name = drProduct.Name;
                ddrProductWrp.id = drProduct.Id;
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
                    //ddrProductWrp.oldMMId = ddrL5Product.PCC_Old_MM_Id__c ; ///*TWC727-2709 - PCC: Remove all references from old MMID*/
                    ddrProductWrp.l4ProductName = ddrL5Product.PCC_L4_Product_Name__c;
                    ddrProductWrp.l5ProductName = ddrL5Product.PCC_L5_Product_Name__c; 
                }
                drpWrpList.add(ddrProductWrp);
            }
        }catch (Exception ex){ Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateDDRUtilityHandler_V2.setDDRProdWrapper' ,'' ,ex); 
                             }
        return drpWrpList;
    } 
    
    /***********************************************************************************************************************************************
* description: creates PCC_Wrapper.SalesforceResponseWrapper (generic)
* return: returns PCC_Wrapper.SalesforceResponseWrapper
* dev: Shraddha M 
***********************************************************************************************************************************************/
    
    public static PCC_Wrapper.restAPIResponseWrapper setJsonResponseBody(Integer statusCode, String status, Integer errorCode, PCC_Wrapper.restAPIInnerResponseWrapper responseBody, String recordId, String Drname){
        PCC_Wrapper.restAPIResponseWrapper respWrapper = new PCC_Wrapper.restAPIResponseWrapper();
        respWrapper.StatusCode = statusCode;
        respWrapper.Status = status;
        respWrapper.ErrorCode = errorCode;
        respWrapper.ResponseBody = responseBody;
        respWrapper.RecordId = recordId;
        respWrapper.Name=Drname;
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
    Public static PCC_Wrapper.restAPIDDRDetailsWrapper setDesignRegResponseBody(Integer StCodeParam, String StatusParam, Integer ErrCodeParam, PCC_Wrapper.PCC_allDdrDetailsWrapper ResBodyParam, String RecIdParam,String Drname){
        PCC_Wrapper.restAPIDDRDetailsWrapper respWrp = new PCC_Wrapper.restAPIDDRDetailsWrapper();
        respWrp.StatusCode = StCodeParam;
        respWrp.Status = StatusParam;
        respWrp.ErrorCode = ErrCodeParam;
        respWrp.ResponseBody = ResBodyParam;
        respWrp.RecordId = RecIdParam; 
        respWrp.Name = Drname;
        return respWrp;
    } 
    Public static PCC_Wrapper.restAPIDDRDetailsWrapper1 setDesignRegResponseBody(Integer StCodeParam, String StatusParam, Integer ErrCodeParam, PCC_Wrapper.PCC_DesignRegDetailsWrapper ResBodyParam, String RecIdParam,String Drname){
        PCC_Wrapper.restAPIDDRDetailsWrapper1 respWrp = new PCC_Wrapper.restAPIDDRDetailsWrapper1();
        respWrp.StatusCode = StCodeParam;
        respWrp.Status = StatusParam;
        respWrp.ErrorCode = ErrCodeParam;
        respWrp.ResponseBody = ResBodyParam;
        respWrp.RecordId = RecIdParam; 
        respWrp.Name = Drname;
        return respWrp;
    } 
    public static PCC_Wrapper.PCC_DRDetailsWrapper getSuccessFailureResp (Map<object, Database.SaveResult> mapDrRecordSaveResult, Map<String, Object> mapExtIdToValidDr, String uniqueExtId,String extId,String successMsg,Map<String,Object> drMap,Map<Id,String> namesDr){
        
        PCC_Wrapper.restAPIInnerResponseWrapper inrRespWrp = new PCC_Wrapper.restAPIInnerResponseWrapper();
        Map<String, String> drProductApiToLabelMap = PCC_Constants.drProductApiToLabelMap;
        PCC_Wrapper.PCC_DRDetailsWrapper drDetailProductWrp = new PCC_Wrapper.PCC_DRDetailsWrapper();  
        
        drDetailProductWrp.successfulRecordCount = 0;
        drDetailProductWrp.failedRecordCount = 0;
        Set<String> errorString;      
        Integer errCd = 9011;
        
        Database.SaveResult sr = mapDrRecordSaveResult.get(mapExtIdToValidDr.get(uniqueExtId));
        //return success message if record is created successfully
        if (sr != null && sr.isSuccess()) {
            drDetailProductWrp.successfulRecordCount++;
            inrRespWrp.Message = successMsg;
            inrRespWrp.ExternalId = extId;
            String tempRecID=sr.getId();
            
            /* if(sr.getId()!= null && sr.getId().getSObjectType().getDescribe().getName() == 'Core_Design_Registration__c'){
List<Core_Design_Registration__c> DRName= [Select Name from Core_Design_Registration__c where Id=:tempRecID Limit 1];
drDetailProductWrp.respList.add(setJsonResponseBody(201, 'SUCCESS', null, inrRespWrp, sr.getId(), DRName[0].Name));
}
else{
List<Core_Design_Registration_Product__c> DRName1= [Select Name from Core_Design_Registration_Product__c where Id=:tempRecID Limit 1];*/
            String DrNames;
            if(tempRecID!=null && namesDr.ContainsKey(tempRecID)){
                DrNames=namesDr.get(tempRecID);
            }else{
                DrNames='';
            }
            drDetailProductWrp.respList.add(setJsonResponseBody(201, 'SUCCESS', null, inrRespWrp, sr.getId(),DrNames)); 
            
        }else{
            //return database error if record insertion is failed
            drDetailProductWrp.failedRecordCount++;
            // Handle the error as needed
            if (sr != null) {
                String tempRecID=sr.getId();
                String DrNames;
                if(tempRecID!=null && namesDr.ContainsKey(tempRecID)){
                    DrNames=namesDr.get(tempRecID);
                }else{
                    DrNames='';
                }
                errorString = new Set<String>();
                for (Database.Error err : sr.getErrors()) {
                    String fieldName = err.Fields.toString();
                    if (errorString.contains(fieldName + err.getMessage())) {
                        continue;
                    }else {
                        String errMessage = '';
                        //getting fieldlist for which we are getting error
                        String fieldsNameList='';
                        if(err.getfields().size()>0){
                            for(String fn: err.getfields()){
                                fieldsNameList += drProductApiToLabelMap.get(fn);
                            }
                        }
                        
                        String statusCode = String.valueOf(err.getStatusCode());
                        errMessage = getErrorMessages(fieldsNameList, statusCode, drMap, err, drProductApiToLabelMap);
                        inrRespWrp.ExternalId = extId;
                        inrRespWrp.Message = errMessage;
                        drDetailProductWrp.respList.add(setJsonResponseBody(400, 'FAILURE', errCd, inrRespWrp ,tempRecID,DrNames));
                        errorString.add(fieldName + err.getMessage());
                        drDetailProductWrp.errorMsgForLogEntry += extId+' - '+err.getMessage()+'\n';
                    }
                }
            }
        }
        return drDetailProductWrp;                   
    }
    
    
    public static String getErrorMessages(String fieldsNameList, String statusCode, Map<String, Object> drMap, Database.Error err, Map<String, String> drProductApiToLabelMap){
        
        String errMessage = '';
        if(statusCode == RESTRICTED_PICKLIST){
            String strField =  string.valueOf(drMap.get(drProductApiToLabelMap.get(err.getfields()[0])));
            errMessage = LabelConfiguration__mdt.getInstance('PCC_InvalidPicklistValue').Value__c.replace('{1}',fieldsNameList).replace('{2}',strField);
        }
        else if(statusCode == FIELD_FILTER_VALIDATION){
            List<String> fieldFilterValidation = LabelConfiguration__mdt.getInstance('PCC_FieldFilterValidation').Value__c.split(';');
            errMessage =  fieldsNameList.contains('productId') ? fieldFilterValidation[0] : fieldFilterValidation[1] +  fieldsNameList;      
        }
        else if(statusCode == REQUIRED_FIELD_MISSING){
            errMessage =  LabelConfiguration__mdt.getInstance('PCC_ReqFieldMissing').Value__c +  fieldsNameList;      
        }else if(statusCode == FIELD_INTEGRITY_EXCEPTION || statusCode == MALFORMED_ID || statusCode == INVALID_ID_FIELD){
            String badValue;
            List<String> messageParts = err.getMessage().split(':');
            if (messageParts.size() > 1) {
                badValue = messageParts[2].trim();
            }
            errMessage =  LabelConfiguration__mdt.getInstance('PCC_FieldIncorrect').Value__c.replace('{1}',fieldsNameList).replace('{2}',badValue);      
        }
        else if(statusCode == STRING_TOO_LONG){
            String badValue;
            List<String> messageParts = err.getMessage().split(':');
            if (messageParts.size() > 1) {
                badValue = messageParts[2].trim();
            }
            errMessage =   LabelConfiguration__mdt.getInstance('PCC_TooLargeData').Value__c+  fieldsNameList + ': '+ badValue;      
        }
        else if(statusCode == INVALID_CROSS_REFERENCE_KEY){
            errMessage =    LabelConfiguration__mdt.getInstance('PCC_IncorrectDesignReg').Value__c;      
        }else if(statusCode == DUPLICATE_VALUE){
            //System.debug('err.getMessage()'+err.getMessage());
            String badValue, existingRecId;
            List<String> messageParts = err.getMessage().split(':');
            if (messageParts.size() > 1) {
                badValue = messageParts[1].trim().substringBefore(' ');
                existingRecId = messageParts[2].trim();
            }
            //System.debug('badValue'+badValue);
            errMessage = LabelConfiguration__mdt.getInstance('PCC_BadValue_ErrMsg').Value__c.replace('{1}',drProductApiToLabelMap.get(badValue)).replace('{2}',existingRecId);
        }
        else{
            errMessage =  err.getMessage();      
        }
        return errMessage;
    }
    
    
    public static List<Core_Design_Registration__c> validDrRecords(map<String,Map<String,Object>> mapIdToWrapMap){
        List<Core_Design_Registration__c> validDRList= new List<Core_Design_Registration__c>();
        //query for valid data to check if record is present in salesforce or not 
        if(!mapIdToWrapMap.isEmpty()){
            validDRList = [SELECT Id,Core_Product_Group_Nm__c,Core_Military_Aerospace_Gvrnmt_Use_Ind__c,Core_Vertical_Market_Nm__c,Core_Product_Segment_Nm__c,Core_Product_Application_Nm__c,Core_External_Id__c,Core_Partner_FAE_Nm__c, Core_Partner_FSR_Nm__c,Core_Opportunity_Volume_Cnt__c,
                           Core_End_Customer_Nm__c,Core_Design_Registration_Nm__c,Core_End_Customer_Street_Addr_Line1_Txt__c,Core_End_Customer_Street_Addr_Line2_Txt__c,Core_End_Customer_Country_Nm__c,PCC_End_Customer_Country__c,Core_End_Customer_Country_Subdivision_Nm__c,Core_End_Customer_Postal_Cd__c,
                           Core_End_Customer_City_Nm__c,Core_End_Customer_Contact_Title_Txt__c,Core_End_Customer_Contact_Phone_Txt__c,Core_End_Customer_Contact_Nm__c,Core_End_Customer_Contact_Email_Txt__c,Core_End_Customer_URL__c,Core_Manufacturing_Region_Cd__c,DDR_Partner_FAE_Email__c,
                           Core_Opportunity_Decision_Dt__c,Core_First_Customer_Ship_Dt__c,Core_Production_End_Dt__c,Core_Intel_Platform_Nm__c, Core_Design_Registration_Status_Nm__c
                           FROM Core_Design_Registration__c 
                           WHERE Id IN :mapIdToWrapMap.keySet()];
            
        }
        return validDRList;
    }
    
}