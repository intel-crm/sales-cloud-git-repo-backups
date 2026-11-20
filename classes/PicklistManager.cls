/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-05-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
//Class to Insert/Update Picklist values and Add/Remove from Record Types dynamically
public without sharing class PicklistManager {
    
    public static PicklistManagerMetadataService.MetadataPort createService(){
        PicklistManagerMetadataService.MetadataPort service = new PicklistManagerMetadataService.MetadataPort();
        service.SessionHeader = new PicklistManagerMetadataService.SessionHeader_element();
        service.SessionHeader.sessionId=fetchUserSessionId();
        return service;    
    }
    
    public static String fetchUserSessionId(){
        String sessionId = '';
        String vfContent;
        PageReference reportPage = Page.Picklist_VF;
        if(Test.isRunningTest()) { return 'sessionID'; }
        vfContent = reportPage.getContent().toString();
        Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
            endP = vfContent.indexOf('End_Of_Session_Id');
        sessionId = vfContent.substring(startP, endP);
        return sessionId;
    }
    
    //Call method to Add new PL value or change label of existing PL value from UI and Backfill from other environments
    @AuraEnabled(cacheable=true)
    public static Map<boolean,string> createOrUpdatePLV(PicklistWrapperClass pwcParams, boolean backfill){
        Map<boolean,string> result = new Map<boolean,string>();
        PicklistManagerMetadataService.CustomField plValues = new PicklistManagerMetadataService.CustomField();
        try{
            //Backfill code WIP
            backfill = false;
            if(pwcParams.objectName !='' && pwcParams.fieldName !='' && 
               pwcParams.fieldAPIName != '' && pwcParams.picklistValues.size() > 0){
                   plValues = upsertPLV(pwcParams);
                   if(backfill){
                       /* Backfill code WIP
PicklistManagerBackFillBatch queJob = new PicklistManagerBackFillBatch(plValues,'PL');
ID jobID = System.enqueueJob(queJob); 
if(jobID!=null) {
result.put(true, 'Job scheduled successfully: '+ jobID);
} else {
result.put(false, 'There has been an error');
}*/
                   }
                   else {
                       PicklistManagerMetadataService.MetadataPort service = createService();
                       List<PicklistManagerMetadataService.SaveResult> saveResults = service.updateMetadata(new PicklistManagerMetadataService.CustomField[] { plValues });
                       if(saveResults[0].success) { result.put(true,'Sucess!'); } 
                       else { result.put(false,saveResults[0].errors[0].message); }   
                   }
               }   
        }
        catch(exception ex){PMP_Utility.logError(ex, 'PicklistManager.createOrUpdatePLV');} 
        return result;
    }
    
    //Method to create new Picklist value template for insert/update 
    public static PicklistManagerMetadataService.CustomField upsertPLV(PicklistWrapperClass pwcParams){
        List<PickListWrapper> newPicklistValues = new List<PickListWrapper>();
        PicklistManagerMetadataService.CustomField customField = new PicklistManagerMetadataService.CustomField();
        
        try{
            //system.debug('pwcParams: '+pwcParams);
            string objectName = pwcParams.objectName;
            string fieldAPIName = pwcParams.fieldAPIName;
            newPicklistValues = pwcParams.picklistValues;
            
            customField.fullName = objectName  + '.' + fieldAPIName;
            customField.label = pwcParams.fieldName;
            customField.type_x = 'Picklist';
            
            //system.debug('customField: '+customField);
            
            // Define the Value Set and Value Set Definitions
            PicklistManagerMetadataService.ValueSet vs = new PicklistManagerMetadataService.ValueSet();
            PicklistManagerMetadataService.ValueSetValuesDefinition vd = new PicklistManagerMetadataService.ValueSetValuesDefinition();
            
            //Create new picklist values in the field
            List<PicklistManagerMetadataService.CustomValue> customValues = new List<PicklistManagerMetadataService.CustomValue>();
            
            for(PickListWrapper pck:newPicklistValues){
                PicklistManagerMetadataService.CustomValue cv = new PicklistManagerMetadataService.CustomValue();
                cv.label = pck.label;
                cv.fullName = pck.value;
                cv.isActive = true;
                cv.default_x = false;
                customValues.add(cv);   
            }
            
            vd.value = customValues;
            vd.sorted = pwcParams.sorted;
            
            vs.valueSetDefinition = vd;
            
            customField.valueSet  = vs;
            
            //system.debug('customField: '+ customField.valueSet); 
        }
        
        catch(exception ex){PMP_Utility.logError(ex, 'PicklistManager.upsertPLV');}   
        return customField;
    }
    
    //Call method to update picklist values to Record Types from UI and Backfill from other environments
    @AuraEnabled(cacheable=true)
    public static Map<boolean,string> createOrUpdateRT(RecordTypeWrapperClass rtParams, boolean backfill){
        Map<boolean,string> result = new Map<boolean,string>();
        PicklistManagerMetadataService.RecordType rtValues = new PicklistManagerMetadataService.RecordType();
        try{
            //Backfill code WIP
            backfill = false;
            if(rtParams.recordTypeName !='' && rtParams.recordTypeFullName !=''){
                rtValues = updateRecordTypes(rtParams);
                if(backfill){
                    /*Backfill code WIP
PicklistManagerBackFillBatch queJob = new PicklistManagerBackFillBatch(rtValues,'RT');
ID jobID = System.enqueueJob(queJob); 
if(jobID!=null) {
result.put(true, 'Job scheduled successfully: '+ jobID);
} else {
result.put(false, 'There has been an error');
}*/
                }
                else{
                    PicklistManagerMetadataService.MetadataPort service = createService();
                    List<PicklistManagerMetadataService.SaveResult> saveResults = service.updateRTMetadata(new PicklistManagerMetadataService.RecordType[] { rtValues });
                    if(saveResults[0].success) { result.put(true,'Sucess!'); } 
                    else { result.put(false,saveResults[0].errors[0].message); }   
                }
            }   
        }
        catch(exception ex){PMP_Utility.logError(ex, 'PicklistManager.createOrUpdateRT');}   
        return result;
    }
    
    //Method to create Record Type template for insert/update 
    public static PicklistManagerMetadataService.RecordType updateRecordTypes(RecordTypeWrapperClass rtwcParams){
        PicklistManagerMetadataService.RecordType mdRecordTypes = new PicklistManagerMetadataService.RecordType();
        Map<boolean,string> result = new Map<boolean,string>();
        try {
            List<PicklistManagerMetadataService.RecordTypePicklistValue> picklistValues = new List<PicklistManagerMetadataService.RecordTypePicklistValue>();
            
            mdRecordTypes.label= rtwcParams.recordTypeName;
            mdRecordTypes.fullName= rtwcParams.recordTypeFullName;
            mdRecordTypes.active = true;
            
            //system.debug('mdRecordTypes: '+mdRecordTypes);
            PicklistManagerMetadataService.RecordTypePicklistValue pV1 = new PicklistManagerMetadataService.RecordTypePicklistValue();
            List<PicklistManagerMetadataService.PicklistValue> pLVal = new List<PicklistManagerMetadataService.PicklistValue>();
            
            for(PickListWrapper picklistValue :rtwcParams.pLWrapperParams.picklistValues){
                pV1.picklist = rtwcParams.pLWrapperParams.fieldAPIName;                   
                PicklistManagerMetadataService.PicklistValue pvv1 = new PicklistManagerMetadataService.PicklistValue();
                pvv1.fullName=picklistValue.value;
                pvv1.default_x=false;
                pvv1.isActive = true;
                pLVal.add(pvv1);  
                //system.debug('pvv1: '+pvv1);     
            }  
            pV1.values = pLVal;   
            picklistValues.add(pV1);
            mdRecordTypes.picklistValues = picklistValues;
        }
        catch(exception ex){PMP_Utility.logError(ex, 'PicklistManager.updateRecordTypes');
        }
        return mdRecordTypes;   
    }
    
    @AuraEnabled
    public static RecordTypeWrapperClass getExistingPLValues(RecordTypeWrapperClass rtwo){
        List<string> exstingValues = new List<string>();
        String res;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        List<PickListWrapper> picklistW = new List<PickListWrapper>();
        Id recordTypeID = [select id from RecordType where Name=:rtwo.recordTypeName and SobjectType=:rtwo.pLWrapperParams.objectName].id;
        
        string url = System.URL.getSalesforceBaseURL().toExternalForm();
        url+= '/services/data/v52.0/ui-api/object-info/';
        url+= rtwo.pLWrapperParams.objectName;
        url+= '/picklist-values/';
        url+= recordTypeID + '/';
        url+=rtwo.pLWrapperParams.fieldAPIName;
        request.setEndpoint(url);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + fetchUserSessionId());
        request.setHeader('Content-Type', 'application/json; charset=UTF-8'); 
        HttpResponse response = http.send(request);
        res = response.getBody();
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res);
        List<Object> values = (List<Object>)m.get('values');
        for (Object picklist : values) {
            ExistingPicklistWrapper pl = new ExistingPicklistWrapper();
            pl = (ExistingPicklistWrapper)JSON.deserialize(JSON.serialize(picklist),ExistingPicklistWrapper.class);
            PickListWrapper pw = new PickListWrapper();
            pw.value = String.valueOf(pl.value);
            pw.label = String.valueOf(pl.label);
            picklistW.add(pw);
        }
        rtwo.pLWrapperParams.picklistValues = picklistW;
        return rtwo;
    }
    
    //Retrieve Active values for Picklist
    //Input: PicklistManager.getPicklistValues(Core_Opportunity_Support_Team__c.Test_Picklist__c);
    @AuraEnabled
    public static List<PickListWrapper> getPicklistValues(String objName, String fieldAPIName) {
        List<PickListWrapper> wrapperList = new List<PickListWrapper>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldAPIName).getDescribe();
        List<Schema.PicklistEntry> entries = fieldResult.getPickListValues();
        
        for (Schema.PicklistEntry entry : entries) {
            PickListWrapper wrapper = new PickListWrapper();
            wrapper.label = entry.getLabel();
            wrapper.value = entry.getValue();
            wrapper.isActive = entry.isActive();
            wrapper.isDefaultValue = entry.isDefaultValue();
            wrapperList.add(wrapper);
        }
        
        //System.debug('wrapperList'+wrapperList);
        return wrapperList;
    }
    @AuraEnabled(cacheable=true)//fetching the Core_MDF record types based on object
    public Static List<Items> GetRecordType (string ObjName){
        List<Items> rectyp = new List<Items>();		
        
        for(Schema.RecordTypeInfo RTI : Schema.getGlobalDescribe().get(ObjName).getDescribe().getRecordTypeInfosByName().values())
        {
            //System.debug('developername'+RTI.getDeveloperName());
            Items RecTypeWrapp = new Items();
            RecTypeWrapp.developerName = RTI.getDeveloperName();
            RecTypeWrapp.name =  RTI.getName();
            RecTypeWrapp.recordTypeId = RTI.getRecordTypeId();
            RecTypeWrapp.ConCatname = ObjName+'+'+RTI.getName()+'+'+RTI.getRecordTypeId();
            rectyp.add(RecTypeWrapp);
            //system.debug('Line 555'+RecTypeWrapp.ConCatname);   
        }
        return rectyp;
    }
    
    //Check User access to Read or Edit Picklist Manager
    @AuraEnabled(cacheable=true)
    public static string userAccess() {
        string result;
        try{
            List<PermissionSetAssignment> psa = [SELECT id,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name in ('PicklistManager_Edit','PicklistManager_ReadOnly')];
            if(psa.size()>1){ result = 'Edit'; }
            else if(psa.size()>0){ result = psa[0].PermissionSet.Name == 'PicklistManager_ReadOnly'? 'Read':'Edit'; }
            else { result= 'No Access'; }
            //system.debug('result: '+result);
        }
        catch(exception ex){PMP_Utility.logError(ex, 'PicklistManager.userAccess');
        }
        return result;   
    }
    
    //Update GlobalValueSet values
    /*public static void updateGVS(){
Map<boolean,string> result = new Map<boolean,string>();
PicklistManagerMetadataService.GlobalValueSet gvsValues = new PicklistManagerMetadataService.GlobalValueSet();
PicklistManagerMetadataService.CustomValue customVal = new PicklistManagerMetadataService.CustomValue();
customVal.fullName = 'It works!';
customVal.label='It works!';
customVal.default_x = false;
customVal.isActive = true;
gvsValues.fullName ='Picklist_Manager';
gvsValues.masterLabel = 'Picklist Manager';
gvsValues.sorted =true;
gvsValues.customValue = new PicklistManagerMetadataService.CustomValue[] {customVal};


PicklistManagerMetadataService.MetadataPort service = createService();
List<PicklistManagerMetadataService.SaveResult> saveResults = service.updateGVSMetadata(new PicklistManagerMetadataService.GlobalValueSet[] { gvsValues });
if(saveResults[0].success) {
result.put(true,'Sucess!');
} else {
result.put(false,saveResults[0].errors[0].message);
} 

system.debug('result: '+result);
}*/
    
    //Wrapper Classes
    public class PicklistWrapperClass {
        @AuraEnabled
        public String objectName { get; set; }
        @AuraEnabled
        public String fieldName { get; set; }
        @AuraEnabled
        public String fieldAPIName { get; set; }
        @AuraEnabled
        public List<PickListWrapper> picklistValues { get; set;}
        @AuraEnabled
        public boolean sorted {get; set;}
    }
    
    public class RecordTypeWrapperClass {
        @AuraEnabled
        public String recordTypeName { get; set; }
        @AuraEnabled
        public String recordTypeFullName { get; set; }
        @AuraEnabled
        public PicklistWrapperClass pLWrapperParams {get; set;}
    }
    
    public class PickListWrapper {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}
        @AuraEnabled
        public Boolean isActive {get; set;}
        @AuraEnabled
        public Boolean isDefaultValue {get; set;}
        @AuraEnabled
        public boolean isNew {get;set;}
    }
    
    public class ExistingPicklistWrapper{
        public string attributes {get;set;}
        public string label {get;set;}
        public string value {get;set;}       
    }
    public Class Items{
        @AuraEnabled
        public ID recordTypeId {get; set;}
        @AuraEnabled
        public String developerName {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String ConCatname {get;set;}
        @AuraEnabled
        public String label {get;set;}
    } 
}