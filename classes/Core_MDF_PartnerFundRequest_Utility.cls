/****************************************************************************************************** 
Class Name:         Core_MDF_PartnerFundRequest_Utility
@parameters:        N/A
Description:        Utility Class for PartnerFundRequest to fetch Various metadata Records
Added By:           SS   24-12-2019
Modified By:        Date:           Changes:
*******************************************************************************************************/
public without sharing class Core_MDF_PartnerFundRequest_Utility {
    /****************************************************************************************************** 
    Method Name:        getCCPAttributeMapMetadata
    @return  :          ActivityTypeAndPillarsMappingWrapper
    @parameters:        RecordType
    Description:        returns conditions for the PFR Event Rules to fire
    Added By:           SS - 06/17/2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public static Map< String , List< CCP_Attributes_Map__mdt >> getCCPAttributeMapMetadata(){
        Map<String,List<CCP_Attributes_Map__mdt>> pfrRecordTypeAttributeMetadataMap = new Map<String,List<CCP_Attributes_Map__mdt>>();
        
        for(CCP_Attributes_Map__mdt ccpAttribute : [SELECT Id, Core_MDF_Activity_Secondary_Pillar_Nm__c, Core_MDF_Activity_Pillar_Nm__c , Type__c, Category__c, Activity_Sub_Type__c, Record_Type_Picklist__c 
                                                      FROM CCP_Attributes_Map__mdt]){
            if(pfrRecordTypeAttributeMetadataMap.containsKey(ccpAttribute.Record_Type_Picklist__c )){                    
                pfrRecordTypeAttributeMetadataMap.get(ccpAttribute.Record_Type_Picklist__c ).add(ccpAttribute);
            }
            else {
                pfrRecordTypeAttributeMetadataMap.put(ccpAttribute.Record_Type_Picklist__c , new List<CCP_Attributes_Map__mdt> {ccpAttribute}); 
            }   
        }
        return pfrRecordTypeAttributeMetadataMap;
    }
    /****************************************************************************************************** 
    Method Name:        getPfrEventRulesMetadata
    @return  :          Map<String,List<Core_MDF_PFR_Event_Rule__mdt>>
    @parameters:        none
    Description:        returns conditions for the PFR Event Rules to fire
    Added By:           SS - 06/17/2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public static Map<String,List<Core_MDF_PFR_Event_Rule__mdt>> getPfrEventRulesMetadata(){
        Map<String,List<Core_MDF_PFR_Event_Rule__mdt>> pfrRecordTypeEventMetadataMap = new Map<String,List<Core_MDF_PFR_Event_Rule__mdt>>();
        for(Core_MDF_PFR_Event_Rule__mdt metadata : ([SELECT Id, Core_MDF_PFR_RecordType__c,Core_MDF_Country_Picklist_Value__c,
                                                      Core_MDF_Activity_Category__c, Core_MDF_Requested_Amount__c, Core_MDF_Activity_Types__c,
                                                      Core_MDF_Day_Difference__c, Core_MDF_PFR_RecordType_Id__c, Core_MDF_PFR_StartDate__c,
                                                      Core_MDF_Amount_Operator__c, Core_MDF_Days_Difference_Operator__c, Core_MDF_Error_Message__c 
                                                      FROM Core_MDF_PFR_Event_Rule__mdt ])){
            if(pfrRecordTypeEventMetadataMap.containsKey(metadata.Core_MDF_PFR_RecordType__c)){                    
                pfrRecordTypeEventMetadataMap.get(metadata.Core_MDF_PFR_RecordType__c).add(metadata);
            }
            else
            {
                pfrRecordTypeEventMetadataMap.put(metadata.Core_MDF_PFR_RecordType__c, new List<Core_MDF_PFR_Event_Rule__mdt> {metadata}); 
            }
        }
        return pfrRecordTypeEventMetadataMap;
    }
    /****************************************************************************************************** 
    Method Name:        getOwnerLanguage
    @return  :          Map<Id, String>
    @parameters:        Owner Id
    Description:        returns owner id and respective language
    Added By:           SS - 06/17/2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public static Map<Id,string> getOwnerLanguage( Set < Id > ownerIdSet)
    {
        Map<Id,string> ownerIdLangLocaleMap = new Map<Id,string>();
        for(User ownerLang : [SELECT Id, LanguageLocaleKey
                                FROM User
                                WHERE Id  IN: ownerIdSet]){
            ownerIdLangLocaleMap.put(ownerLang.Id , ownerLang.LanguageLocaleKey);
                                            
        }
        
        return ownerIdLangLocaleMap;
    }
    /****************************************************************************************************** 
    Method Name:        getCCPRTNames
    @return  :          void
    @parameters:        PFR Map
    Description:        return the record type id and names for all programs passed in input
    Added By:           Sridhar - 06/17/2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public static Map<Id,string> getCCPRTNames(Map<string,Integer> metaDataMap)
    {
        Map<Id,string> ccpRTNames = new Map<Id,string>();
        for(string programe : metaDataMap.keySet())
        {
            if (Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get(programe) != null)
            {
                id recordTypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get(programe).getRecordTypeId();
                ccpRTNames.put(recordTypeId,programe);
            }
            
        } 
        return ccpRTNames;
    }
    /****************************************************************************************************** 
    Method Name:        getMetaDataValues
    @return  :          void
    @parameters:        PFR Map
    Description:        get meta data values to know the no of days after the activity to be closed
    Added By:           Sridhar - 06/17/2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public static ClaimActAllocRecTypeMappingWrapper getMetaDataValues()
    {
        Map<string,Integer> metadtMap = new Map<string,Integer>();
        Map<String, List<String>> programGeoReqMap = new Map<String,List<String>>();
        
        ClaimActAllocRecTypeMappingWrapper claimActAllocRecTypeMappingInstance = new ClaimActAllocRecTypeMappingWrapper();
        
        for(Core_MDF_ClaimActAllocRecTypeMapping__mdt mtrecord : [SELECT Id, Core_MDF_Activity_Close_Days__c,Core_MDF_Activity_RecordType_txt__c, Core_MDF_Region_cd__c
                                                                    FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt])
        {
            if (!metadtMap.containsKey(mtrecord.Core_MDF_Activity_RecordType_txt__c))
            {
                metadtMap.put(mtrecord.Core_MDF_Activity_RecordType_txt__c,(Integer)mtrecord.Core_MDF_Activity_Close_Days__c);
            }
            if(mtrecord.Core_MDF_Region_cd__c != NULL){//if Region Code has some values for that particular program record
                List<String> geoProgramList = mtrecord.Core_MDF_Region_cd__c.split(';');//split the Region Code into List of Regions
                if(geoProgramList != NULL && geoProgramList.size() > 0){
                    programGeoReqMap.put(mtrecord.Core_MDF_Activity_RecordType_txt__c, geoProgramList );
                }
            }
        }
        claimActAllocRecTypeMappingInstance.activityRecordTypeCloseDateMap = metadtMap;
        claimActAllocRecTypeMappingInstance.activityRecordTypeGeoListMap = programGeoReqMap;
        return claimActAllocRecTypeMappingInstance;
    }

    /***************************************************************************************************** 
    Method Name :  claimActAllocRecTypeMappingWrapper (Created a Wrapper to reduce the server side call)
    Added By   :    Accenture - SS 
    Modified By:                      Date:12/25/2018                     Changes:None  
    ******************************************************************************************************/
    public class ClaimActAllocRecTypeMappingWrapper
    {   public Map<string,Integer> activityRecordTypeCloseDateMap  ; 
        public Map<String, List<String>> activityRecordTypeGeoListMap;
    }
    /****************************************************************************************************** 
    Method Name:        getActivityPillarAndActivitySecondaryPillar
    @return  :          Wrapper ActivityFieldsWrapper 
    @parameters:        Map< String , List< CCP_Attributes_Map__mdt >> , PFR DeveloperName, PFR ActivityType , PFR ActvityCategory
    Description:        returns Activity Pillars associated to Activity Type 
    Added By:           SS - 06/17/2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public static void getActivityPillarAndActivitySecondaryPillar(PartnerFundRequest pfr, String pfrRecordTypeDevName){
        Map< String , List< CCP_Attributes_Map__mdt >> activityAttributesMap = new Map< String , List< CCP_Attributes_Map__mdt >> ();        
        String activityType = pfr.Core_MDF_Activity_Types__c;
        String actvityCategory = pfr.Core_MDF_ActivityCategory__c;
        String actvitySubtype = pfr.Core_MDF_Activity_SubType_nm__c;

        activityAttributesMap = getCCPAttributeMapMetadata();
        
        if(activityAttributesMap != NULL && activityAttributesMap.size() > 0 && activityAttributesMap.containsKey(pfrRecordTypeDevName)){
            for(CCP_Attributes_Map__mdt customMetadata : activityAttributesMap.get(pfrRecordTypeDevName)){
                if((activityType.equals(customMetadata.Type__c) && actvityCategory.equals(customMetadata.Category__c)) && 
                   (String.isBlank(customMetadata.Activity_Sub_Type__c) || actvitySubtype.equals(customMetadata.Activity_Sub_Type__c))){
                    if(String.isNotBlank(customMetadata.Core_MDF_Activity_Pillar_Nm__c)){
                        pfr.Core_MDF_Activity_Pillar_Nm__c = customMetadata.Core_MDF_Activity_Pillar_Nm__c;
                    }
                    if(String.isNotBlank(customMetadata.Core_MDF_Activity_Secondary_Pillar_Nm__c)){
                        pfr.Core_MDF_Activity_Secondary_Pillar_Nm__c = customMetadata.Core_MDF_Activity_Secondary_Pillar_Nm__c;
                    }
                    break;
                }
            }
        } 
    }
    
    /***************************************************************************************************** 
    Method Name :  ActivityFieldsWrapper (Created a Wrapper to reduce the server side call)
    Added By   :    Accenture - SS 
    Modified By:                      Date:12/25/2018                     Changes:None  
    ******************************************************************************************************/
    /*public class ActivityFieldsWrapper
    {   public String activityPillar; 
        public String activitySecondaryPillar;
    }*/
    /****************************************************************************************************** 
    Method Name:        updateActFields
    @return  :          None 
    @parameters:        PartnerFundRequest
    Description:        
    Added By:           SS - 01/21/2020
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public static void updateActFields (PartnerFundRequest pfr){
        try{
            //if(pfrList != NULL){
            //database.update(pfr);
            //}
            update(pfr);
        }catch (Exception e) {Core_MDF_CCP_UtilityClass.logError(e);}
    }
        
    
}