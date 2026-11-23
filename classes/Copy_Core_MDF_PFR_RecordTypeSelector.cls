/*****Core_************************************************************************************************ 
Class Name :    Copy_Core_MDF_PFR_RecordTypeSelector
Description:    Server side controller for Copy_Core_MDF_PFR_RecordTypeSelector component
Added By   :     
Modified By:                      Date:                     Changes:None  
******************************************************************************************************/
public with sharing class Copy_Core_MDF_PFR_RecordTypeSelector {
    public static Map<String, String> newrecordtypemapdevname;
    public static Map<String, Id> newrecordtypemap;
/***************************************************************************************************** 
Method Name :   fetchRecordTypeValues Map(RecordTypeDeveloperName , RecordTypeLabelName)
Added By   :    Accenture - SS 
Modified By:                      Date:10/25/2018                     Changes:None  
******************************************************************************************************/
    @AuraEnabled
    public static Map<String, String> fetchRecordTypeValues(String objectName){
        system.debug('fetchRecordTypeValues objectName:::>' +objectName);
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
    /****************************************************************************************************** 
Method Name:        getCampaign
@return  :          Campaign object
@parameters:        Campaign record ID
Description:        This method is used to fetch record based on campaign ID.
Added By:           
Modified By:        Date:      Changes: 
*******************************************************************************************************/
@AuraEnabled
public static Campaign getCampaignFields(Id recordId){
    
    try{
        Campaign campObj = [SELECT Id, Name, Core_MDF_Account__c, Core_MDF_Account__r.Name, Core_MDF_Budget_Type_txt__c,
                                 Core_MDF_Priority__c, Core_MDF_Priority_2_nm__c, Core_MDF_Priority_3_nm__c, Core_MDF_Channel_Program__c,
                                 Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Technology__c, Status 
                                 FROM Campaign WHERE Id=:recordId LIMIT 1];
        
        if(campObj != null){
            return campObj;
        }
        else{return null;}
    }catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e); return null; }
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