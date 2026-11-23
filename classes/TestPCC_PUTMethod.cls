public class TestPCC_PUTMethod {
    public static final String LOG_ENTRY_ORIGIN   = 'PCC_CreateDesignRegistration';
    public static final String LOG_ENTRY_PROJECT  = 'DDR Registration';
    public static final String LOG_ENTRY_SCOPE    = 'Create DDR Records';
    public static final String LOG_ENTRY_SCOPE_1  = 'Fetch DDR Picklist Values';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_SEVERITY = 'High';
    public static final String LOG_ENTRY_INFO     = 'info';    
    public static Map<String, String> mapExtIdtoInvalidValMsg = new Map<String, String>();  
    
   public static void updatePartnerAccountDetails(list<core_design_registration__c> ddrList){
            List<Contact> ownersList = new List<Contact>();   
            
            // Collect all unique Owner Ids from DDR records
            Set<Id> ownerIds = new Set<Id>();
            for (core_design_registration__c ddr : ddrList) {
                if (ddr.OwnerId != null) {
                    ownerIds.add(ddr.OwnerId);
                }
            }
            
            // Retrieve the Contact records
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name, AccountId FROM Contact WHERE Id IN :ownerIds]);
        	// Collect all unique Account Ids from Contact records
        Set<Id> accountIds = new Set<Id>();
        for (Contact contact : contactMap.values()) {
            if (contact.AccountId != null) {
                accountIds.add(contact.AccountId);
            }
        }
        
        // Retrieve the Account records
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :accountIds]);
        
        // Update the Partner Account Name on DDR records
        for (core_design_registration__c ddr : ddrList) {
            if (ddr.OwnerId != null) {
                Contact owner = contactMap.get(ddr.OwnerId);
                if (owner != null && owner.AccountId != null) {
                    Account partnerAccount = accountMap.get(owner.AccountId);
                    if (partnerAccount != null) {
                        ddr.Core_Partner_Account_Id__c = partnerAccount.Id;
                    }
                }
            }
        }
        }
    public static RestResponse updateDesignRegistrationRecords(List<Object> DDRWrapList){
        RestResponse res = RestContext.response;
        Map<Object, Database.SaveResult> mapDrRecordSaveResult = new Map<Object, Database.SaveResult>();  
        Map<String,Map<String,Object>> mapRecIdTODRList = new Map<String,Map<String,Object>>();
        Map<String,String> mapOfIdToErrMsg = new Map<String,String>();
        Map<String,String> mapOfRecIdToExtId = new Map<String,String>();
        Map<String,String> mapOfExtIdToRecId = new Map<String,String>();
        List<Core_Design_Registration__c> validDRList = new List<Core_Design_Registration__c>();
        Map<Id,Core_Design_Registration__c> existingDDR = new Map<Id,Core_Design_Registration__c>();
        //List<String> requiredFields = Label.PCC_Create_DDR_Required_Fields.split(',');
        Map<String, String> drProductApiToLabelMap = PCC_Constants.drProductApiToLabelMap;
        map<String,Map<String,Object>> mapIdToWrapMap = new map<String,map<string,Object>>();
        Map<String, List<String>> mapExtIdToMissingFld = new Map<String, List<String>>();
        Map<Integer,Map<String,Object>> mapIdToWrapMapAll= new Map<Integer,Map<String,Object>>();
        Map<String, Core_Design_Registration__c> mapOfIdToInstance = new Map<String, Core_Design_Registration__c>();
        Map<String,Map<String,Object>> mapValidIdToWrap = new Map<String,Map<String,Object>>();
        List<Core_Design_Registration__c> drProductListToUpdate = new List<Core_Design_Registration__c>();
        Integer DDRCount = 0;
        
        List<String> requiredFieldsApi = Label.PCC_DDR_Required_Fields_API.split(',');
        
        try{
            //Iterating over the wrapper list 
            for(Object reqWrap : DDRWrapList){                
                Map<String, Object> drMap = (Map<String, Object>)reqWrap;
                mapIdToWrapMapAll.put(DDRCount,drMap);
               String uniqueId = (drMap.containsKey('externalId') && (String)drMap.get('externalId')!=null) ? (String)drMap.get('externalId') :((drMap.containsKey('recordId') && (String)drMap.get('recordId')!=null) ? (String)drMap.get('recordId') : null);
                if((String)drMap.get('recordId')!=null && (String)drMap.get('recordId')!=''){
                    mapIdToWrapMap.put((String)drMap.get('recordId'),drMap);
                }
                else if((String)drMap.get('externalId')!=null && (String)drMap.get('externalId')!=''){                                  
                    mapIdToWrapMap.put((String)drMap.get('externalId'),drMap);
                }
               
                DDRCount++;
            }
            system.debug('mapIdToWrapMap'+mapIdToWrapMap);
            
            //query for valid data to check if record is present in salesforce or not 
            if(!mapIdToWrapMap.isEmpty()){
                validDRList = [SELECT Id,Core_Product_Group_Nm__c,Core_Military_Aerospace_Gvrnmt_Use_Ind__c,Core_Vertical_Market_Nm__c,Core_Product_Segment_Nm__c,Core_Product_Application_Nm__c,Core_External_Id__c,Core_Partner_FAE_Nm__c, Core_Partner_FSR_Nm__c,
                               Core_End_Customer_Nm__c,Core_End_Customer_Street_Addr_Line1_Txt__c,Core_End_Customer_Street_Addr_Line2_Txt__c,Core_End_Customer_Country_Nm__c,Core_End_Customer_Country_Subdivision_Nm__c,Core_End_Customer_Postal_Cd__c,
                               Core_End_Customer_City_Nm__c,Core_End_Customer_Contact_Title_Txt__c,Core_End_Customer_Contact_Phone_Txt__c,Core_End_Customer_Contact_Nm__c,Core_End_Customer_Contact_Email_Txt__c,Core_Manufacturing_Region_Cd__c,DDR_Partner_FAE_Email__c,
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
                        system.debug('if(existingDDR.get(dr.id).get(fieldApiName)== null && !mapIdToWrapMap.get(dr.id).containskey(labelname)'+(existingDDR.get(dr.id).get(fieldApiName)));
                       // system.debug('!mapRecIdTODRList.get(dr.id).containskey(labelname)'+!mapRecIdTODRList.get(dr.id).containskey(labelname));
                        if(existingDDR.get(dr.id).get(fieldApiName)== null && !mapIdToWrapMap.get(dr.id).containskey(labelname) /*&& (mapIdToWrapMap.get(dr.id).get(labelname))==null*/){                                    
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
            PCC_Wrapper.PCC_DRDetailsWrapper drWrp = PCC_CreateDDRUtilityHandler.getDDRObjectResponses(mapIdToWrapMapAll, mapExtIdToMissingFld, mapOfIdToInstance, mapExtIdtoInvalidValMsg,
                                                                           mapDrRecordSaveResult, mapOfRecIdToExtId, 'Update');
            
            //get statusCode based on successful or failed record count
            res.statusCode = PCC_CreateDDRUtilityHandler.getStatusCode(DDRWrapList.size(), drWrp.successfulRecordCount, drWrp.failedRecordCount);
            
            //set responsebody
            res.responseBody = Blob.valueOf(JSON.serialize(drWrp.respList));
            
        }
        catch(exception ex){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY, '', '', '', 'PCC_CreateDesignRegistrationUtility_V1', '', ex);
        }
        return res;
    }
    
   
}