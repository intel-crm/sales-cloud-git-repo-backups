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
     public static Map< String , List< Core_MDF_CCP_Custom_Metadata_Utility__c >> getCCPAttributeMapMetadata(){
		/*for(CCP_Attributes_Map__mdt ccpAttribute : [SELECT Id, Core_MDF_Activity_Secondary_Pillar_Nm__c, Core_MDF_Activity_Pillar_Nm__c , Type__c, Category__c, Activity_Sub_Type__c, Record_Type_Picklist__c 
                                                      FROM CCP_Attributes_Map__mdt WHERE DeveloperName != null]){*/
        Map<String,List<Core_MDF_CCP_Custom_Metadata_Utility__c>> pfrRecordTypeAttributeMetadataMap = new Map<String,List<Core_MDF_CCP_Custom_Metadata_Utility__c>>();
        String query = 'SELECT Core_MDF_Field_5_txt__c, ' +
        'Core_MDF_Field_3_txt__c, ' +
        'Core_MDF_Field_9_txt__c, ' +
        'Core_MDF_Field_4_txt__c, ' + 
        'Core_MDF_Field_7_txt__c, ' +
        'Core_MDF_Sub_Category__c, ' +
        'Core_MDF_Field_8_txt__c ' +
        'FROM Core_MDF_CCP_Custom_Metadata_Utility__c ' +
        'WHERE Core_MDF_Category__c = \'' + String.escapeSingleQuotes(Core_MDF_CCP_ConstantClass.ATTRIBUTES_MAP_CATEGORY) + '\' ' +
        'AND Core_MDF_Is_Active_Ind__c = TRUE';
        
        //Metadata object records, returned based on the above querys
        List<Core_MDF_CCP_Custom_Metadata_Utility__c> customMetadataUtilityRecords = Core_MDF_Custom_Metadata_Utility.getCustomObjectRecordsUsingDynamicQuery(query);
        for(Core_MDF_CCP_Custom_Metadata_Utility__c ccpAttribute : customMetadataUtilityRecords){
            if(pfrRecordTypeAttributeMetadataMap.containsKey(ccpAttribute.Core_MDF_Field_4_txt__c )){                    
                pfrRecordTypeAttributeMetadataMap.get(ccpAttribute.Core_MDF_Field_4_txt__c ).add(ccpAttribute);
            }
            else {
                pfrRecordTypeAttributeMetadataMap.put(ccpAttribute.Core_MDF_Field_4_txt__c , new List<Core_MDF_CCP_Custom_Metadata_Utility__c> {ccpAttribute}); 
            }   
        }
        return pfrRecordTypeAttributeMetadataMap;
    }
    
    public static Map< String , List< Core_MDF_CCP_Custom_Metadata_Utility__c >> getCCPAttributeMapMetadata(string recordType){
	/*[SELECT Id, Core_MDF_Activity_Secondary_Pillar_Nm__c, Core_MDF_Activity_Pillar_Nm__c , Type__c, Category__c, Activity_Sub_Type__c, Record_Type_Picklist__c 
                                                    FROM CCP_Attributes_Map__mdt WHERE Record_Type_Picklist__c =: recordType]*/
        Map<String,List<Core_MDF_CCP_Custom_Metadata_Utility__c>> pfrRecordTypeAttributeMetadataMap = new Map<String,List<Core_MDF_CCP_Custom_Metadata_Utility__c>>();
        String query = 'SELECT Core_MDF_Field_5_txt__c, ' +
        'Core_MDF_Field_3_txt__c, ' +
        'Core_MDF_Field_9_txt__c, ' +
        'Core_MDF_Field_7_txt__c, ' +
        'Core_MDF_Sub_Category__c, ' +
        'Core_MDF_Field_8_txt__c, ' + // Removed the trailing space from the previous line
        'Core_MDF_Field_4_txt__c ' +
        'FROM Core_MDF_CCP_Custom_Metadata_Utility__c ' +
        'WHERE Core_MDF_Category__c = \'' + String.escapeSingleQuotes(Core_MDF_CCP_ConstantClass.ATTRIBUTES_MAP_CATEGORY) + '\' ' +
        'AND Core_MDF_Is_Active_Ind__c = TRUE ' +
        'AND Core_MDF_Field_4_txt__c = \'' + recordType + '\'';

        List<Core_MDF_CCP_Custom_Metadata_Utility__c> customMetadataUtilityRecords = Core_MDF_Custom_Metadata_Utility.getCustomObjectRecordsUsingDynamicQuery(query);             
        for(Core_MDF_CCP_Custom_Metadata_Utility__c ccpAttribute : customMetadataUtilityRecords){
                                                        if(pfrRecordTypeAttributeMetadataMap.containsKey(ccpAttribute.Core_MDF_Field_4_txt__c )){                    
                                                            pfrRecordTypeAttributeMetadataMap.get(ccpAttribute.Core_MDF_Field_4_txt__c ).add(ccpAttribute);
                                                        }
                                                        else {
                                                            pfrRecordTypeAttributeMetadataMap.put(ccpAttribute.Core_MDF_Field_4_txt__c , new List<Core_MDF_CCP_Custom_Metadata_Utility__c> {ccpAttribute}); 
                                                        }   
                                                    }
        return pfrRecordTypeAttributeMetadataMap;
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
        //Avoid using Soql / Sosl queries without filters and limits
        for(Core_MDF_ClaimActAllocRecTypeMapping__mdt mtrecord : [SELECT Id, Core_MDF_Activity_Close_Days__c,Core_MDF_Activity_RecordType_txt__c, Core_MDF_Region_cd__c
                                                                    FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt Limit 5000])
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
        Map< String , List< Core_MDF_CCP_Custom_Metadata_Utility__c >> activityAttributesMap = new Map< String , List< Core_MDF_CCP_Custom_Metadata_Utility__c >> ();        
        String activityType = pfr.Core_MDF_Activity_Types__c;
        String actvityCategory = pfr.Core_MDF_ActivityCategory__c;
        String actvitySubtype = pfr.Core_MDF_Activity_SubType_nm__c;//Core_MDF_Activity_Sub_Type_nm__c
        activityAttributesMap = getCCPAttributeMapMetadata(pfrRecordTypeDevName);
        
        if(activityType != NULL && actvityCategory != NULL && activityAttributesMap != NULL && activityAttributesMap.size() > 0 && activityAttributesMap.containsKey(pfrRecordTypeDevName)){
            for(Core_MDF_CCP_Custom_Metadata_Utility__c customMetadata : activityAttributesMap.get(pfrRecordTypeDevName)){
                //Avoid Deeply Nested IF Statements
                Boolean actCatCheck = ((activityType.equals(customMetadata.Core_MDF_Field_9_txt__c) && actvityCategory.equals(customMetadata.Core_MDF_Field_7_txt__c)) && 
                   (String.isBlank(customMetadata.Core_MDF_Sub_Category__c) || String.isBlank(actvitySubtype) || actvitySubtype.equals(customMetadata.Core_MDF_Sub_Category__c)));
                    if(actCatCheck && String.isNotBlank(customMetadata.Core_MDF_Field_3_txt__c)){
                        pfr.Core_MDF_Activity_Pillar_Nm__c = customMetadata.Core_MDF_Field_3_txt__c;
                    }
                    if(actCatCheck && String.isNotBlank(customMetadata.Core_MDF_Field_5_txt__c)){
                        pfr.Core_MDF_Activity_Secondary_Pillar_Nm__c = customMetadata.Core_MDF_Field_5_txt__c;
                    }
                    break;
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
        
	//Method to check if Activity is part of Japan cycle
   /* public static boolean isJapanCycle(PartnerFundRequest pfr,string program){
        boolean boolctryflg = false;      
        if(pfr!=null && string.isNotBlank(program)){
            if(pfr.Core_MDF_Country_nm__c.containsIgnoreCase(System.Label.Core_MDF_Country_JAPAN) && program.equals(System.Label.Core_MDF_PFR_Retail) && pfr.Core_MDF_Budget_Type_txt__c.equals(System.Label.Core_MDF_Retail_RSAMD_UnTranslated)){
            	boolctryflg = true;
            }
        }        
        return boolctryflg;
    } */
        
    
}