/*****Core_************************************************************************************************ 
Class Name :    Core_MDF_PFR_RecordTypeSelector
Description:    Server side controller for Core_MDF_PFR_RecordTypeSelector component
Added By   :    Accenture - AS 
Modified By:                      Date:07/25/2018                     Changes:None  
******************************************************************************************************/
public with sharing class Core_MDF_PFR_RecordTypeSelector {
    public static Map<String, String> newrecordtypemapdevname;
    public static Map<String, Id> newrecordtypemap;
/***************************************************************************************************** 
Method Name :   fetchRecordTypeValues Map(RecordTypeDeveloperName , RecordTypeLabelName)
Added By   :    Accenture - SS 
Modified By:                      Date:10/25/2018                     Changes:None  
******************************************************************************************************/
    @AuraEnabled
    public static Map<String, String> fetchRecordTypeValues(String objectName){
        List<Schema.RecordTypeInfo> recordtypes = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfos();
        newrecordtypemapdevname = new Map<String, String>();
        for(RecordTypeInfo rt : recordtypes){
            if( rt.isMaster() == false && rt.getName().trim() != '' &&  rt.isAvailable() && rt.isActive()){  //rt.getName() != label.Core_MDF_Master
                  newrecordtypemapdevname.put(rt.getDeveloperName(), rt.getName());
                  system.debug('Map of Dev Name and String'+newrecordtypemapdevname);
            }    
        }
        return newrecordtypemapdevname;
    }
/***************************************************************************************************** 
Method Name :   fetchRecordTypeValues_string_id // map(RecordTypeDeveloperName , RecordTypeId)
Added By   :    Accenture - SS 
Modified By:                      Date:10/25/2018                     Changes:None  
******************************************************************************************************/
    @AuraEnabled
    public static Map<String, Id> fetchRecordTypeValues_string_id(String objectName){
        List<Schema.RecordTypeInfo> recordtypes = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfos();
        newrecordtypemap = new Map<String, Id>();
        for(RecordTypeInfo rt : recordtypes){
            if( rt.isMaster() == false && rt.getName().trim() != '' &&  rt.isAvailable() && rt.isActive()){  //rt.getName() != label.Core_MDF_Master
                  newrecordtypemap.put( rt.getDeveloperName() , rt.getRecordTypeId());
                  system.debug('Map of Dev Name and Id'+newrecordtypemap);
            }    
        }
        return newrecordtypemap;
    }
/***************************************************************************************************** 
Method Name :   fetchRecordType // Wrapper(Map(String, String) , Map(String,Id))
Added By   :    Accenture - SS 
Modified By:                      Date:10/25/2018                     Changes:None  
******************************************************************************************************/
    @AuraEnabled
    public static recordTypeWrapper fetchRecordType(String objectName) {
        String objName = objectName;
        recordTypeWrapper recTypeInst = new recordTypeWrapper();
        recTypeInst.recordTypeDevNameAndLabelName = fetchRecordTypeValues(objName);
        recTypeInst.recordTypeDevNameAndId = fetchRecordTypeValues_string_id(objName);
        return recTypeInst;
    }
/***************************************************************************************************** 
Method Name :   recordTypeWrapper (Created a Wrapper to reduce the server side call)
Added By   :    Accenture - SS 
Modified By:                      Date:10/25/2018                     Changes:None  
******************************************************************************************************/

    public class recordTypeWrapper
    {   @AuraEnabled   
        public Map<String, String> recordTypeDevNameAndLabelName  ; 
        @AuraEnabled
        public Map<String, Id> recordTypeDevNameAndId;
    }
}