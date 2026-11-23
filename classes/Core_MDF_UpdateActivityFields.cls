/****************************************************************************************************** 
Class Name:         Core_MDF_UpdateActivityFields
@parameters:        N/A
Description:        Before Insert/Upadte call these functions and update the activity to be closed date
Added By:           Sridhar   06-17-2019
Modified By:        Date:           Changes:
Shivaprasad         08-29-2019      Added the condition to check closed status of PFR records in populateBackEndFieldsUpdate method.
*******************************************************************************************************/
public without sharing class Core_MDF_UpdateActivityFields {
    
    public static Map<Id, PartnerFundRequest> oldStaticPFRMap = new Map<Id, PartnerFundRequest>();
    
    /****************************************************************************************************** 
    Method Name:        populateBackEndFieldsUpdate
    @return  :          void
    @parameters:        PFR Map
    Description:        This method is used to update the to be closed date before update trigger
    Added By:           Sridhar - 06/17/2019
    Modified By:        Date:         Changes: 
    Shivaprasad         08-29-2019    Added the condition to check closed status of PFR records.
    *******************************************************************************************************/
    
    public static void populateBackEndFieldsUpdate(Map<Id,PartnerFundRequest> newMap, Map<Id,PartnerFundRequest> oldMap)
    {
        try
        {
            if(oldMap != NULL && oldMap.size() > 0){
                oldStaticPFRMap = oldMap;
            }
            List<PartnerFundRequest> pfrs = new List<PartnerFundRequest>();
            for(PartnerFundRequest pfr: newMap.values()){
                if(pfr.Core_MDF_Fund_Request_Status__c != label.Core_MDF_PFR_Status_Closed){
                    pfrs.add(newMap.get(pfr.Id));   
                }
            }
            
            if (pfrs.size() > 0)
            {
                processPFRRecords(pfrs,oldMap);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
    
    /****************************************************************************************************** 
    Method Name:        populateBackEndFieldsInsert
    @return  :          void
    @parameters:        PFR Map
    Description:        This method is used to update the to be closed date in before insert
    Added By:           Sridhar - 06/17/2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public static void populateBackEndFieldsInsert(List<PartnerFundRequest> newList)
    {
        try
        {
            if (newList != NULL && newList.size() > 0)
            {
                //close activity & activity event rules method call
                processPFRRecords(newList,NULL);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
    
    /****************************************************************************************************** 
    Method Name:        getMetaDataValues
    @return  :          void
    @parameters:        PFR Map
    Description:        get meta data values to know the no of days after the activity to be closed
    Added By:           Sridhar - 06/17/2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
        
    private static Map<string,Integer> getMetaDataValues()
    {
        Map<string,Integer> metadtMap = new Map<string,Integer>();
        
        for(Core_MDF_ClaimActAllocRecTypeMapping__mdt mtrecord : [select Id, Core_MDF_Activity_Close_Days__c,Core_MDF_Activity_RecordType_txt__c from Core_MDF_ClaimActAllocRecTypeMapping__mdt])
        {
            if (!metadtMap.containsKey(mtrecord.Core_MDF_Activity_RecordType_txt__c))
            {
                metadtMap.put(mtrecord.Core_MDF_Activity_RecordType_txt__c,(Integer)mtrecord.Core_MDF_Activity_Close_Days__c);
            }
        }
        return metadtMap;
    } 
    
    /****************************************************************************************************** 
    Method Name:        getCCPRTNames
    @return  :          void
    @parameters:        PFR Map
    Description:        return the record type id and names for all programs passed in input
    Added By:           Sridhar - 06/17/2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    private static Map<Id,string> getCCPRTNames(Map<string,Integer> metaDataMap)
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
    Method Name:        processPFRRecords
    @return  :          void
    @parameters:        list of PFR
    Description:        proess all the records and update the to be closed date and event activity validation
    Added By:           Sridhar - 06/17/2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    
    public static void processPFRRecords(List<PartnerFundRequest> pfrList, Map<Id,PartnerFundRequest> oldPfrMap)
    {
        Map<string,Integer> metadtMap = new Map<string,Integer>();
        Map<Id,string> ccpRecordTypeIds = new Map<Id,string>();
        Date endDate = null;
        
        metadtMap = getMetaDataValues();
        ccpRecordTypeIds = getCCPRTNames(metadtMap);
        try{
                //Fetch owner id from pfrList
                    Id OwnerId = null;
            for(PartnerFundRequest pfr: pfrList){
                //closed date validations
                endDate = pfr.Core_MDF_End_Date__c;
                String progName = ccpRecordTypeIds.get(pfr.recordTypeId);

                if (oldPfrMap != null && oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == 'Cancelled'
                    && pfr.Core_MDF_Fund_Request_Status__c != 'Cancelled'){
                        pfr.Core_MDF_Fund_Request_Status__c = 'Cancelled';
                    }

                if (metadtMap.containsKey(progName))
                {
                    Integer actCloseDays  = (Integer)metadtMap.get(progName);
                    pfr.Core_MDF_ToBeClosedDate__c = endDate.addDays(actCloseDays);
                }
                endDate = NULL;

                //closed date validations complete
                //Storing Owner id
                OwnerId = pfr.OwnerId;
            }
            
            //hasCustomPermission is Boolean type contains whether the Internal Account Manager custom permission is present or not
            Boolean hasCustomPermission = FeatureManagement.checkPermission(Label.Core_MDF_Custom_Permission_IAM);
            //Retail 14 day validation
            Boolean hasRetailCustomPermission = FeatureManagement.checkPermission(Label.Core_MDF_Custom_Permission_IAM_Retail);
            
            //loop meta data and form Map --> Record type id, list of metadata
            Map<String,List<Core_MDF_PFR_Event_Rule__mdt>> pfrRecordIdMetadataMap = new Map<String,List<Core_MDF_PFR_Event_Rule__mdt>>();
            
            //Map of Record Type id and Record Type Developer Name
            Map<Id, String> recordTypeIdDevName = new Map<Id, String>();
            for(RecordType recordType : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'PartnerFundRequest' ] ){
                recordTypeIdDevName.put(recordType.Id ,recordType.DeveloperName);
            }    
            //Record type restrict
            for(Core_MDF_PFR_Event_Rule__mdt metadata : ([SELECT Id, Core_MDF_PFR_RecordType__c,Core_MDF_Country_Picklist_Value__c,
                                                          Core_MDF_Activity_Category__c, Core_MDF_Requested_Amount__c, Core_MDF_Activity_Types__c,
                                                          Core_MDF_Day_Difference__c, Core_MDF_PFR_RecordType_Id__c, Core_MDF_PFR_StartDate__c,
                                                          Core_MDF_Amount_Operator__c, Core_MDF_Days_Difference_Operator__c, Core_MDF_Error_Message__c 
                                                          FROM Core_MDF_PFR_Event_Rule__mdt ])){
                if(pfrRecordIdMetadataMap.containsKey(metadata.Core_MDF_PFR_RecordType__c)){                    
                    pfrRecordIdMetadataMap.get(metadata.Core_MDF_PFR_RecordType__c).add(metadata);
                }
                else
                {
                    pfrRecordIdMetadataMap.put(metadata.Core_MDF_PFR_RecordType__c, 
                                                new List<Core_MDF_PFR_Event_Rule__mdt> {metadata}); 
                }
            }
            
            // Country Geo Map
            Map<String , String> countryGeoMap = new Map <String , String>();
            Map<String , String> countrySubGeoMap = new Map <String , String>();
            for (Core_MDF_CCP_Country_Geo_Mapping__mdt countryGeoMetaData : [SELECT Id, MasterLabel, Core_MDF_Geo__c, Core_MDF_Sub_Geo__c FROM Core_MDF_CCP_Country_Geo_Mapping__mdt]){
                countryGeoMap.put(countryGeoMetaData.MasterLabel , countryGeoMetaData.Core_MDF_Geo__c );
                countrySubGeoMap.put(countryGeoMetaData.MasterLabel, countryGeoMetaData.Core_MDF_Sub_Geo__c);
            }
            // Program and Required Geo Map
            Map<String, List<String>> programGeoReqMap = new Map<String,List<String>>();
            
            for(Core_MDF_ClaimActAllocRecTypeMapping__mdt claimActAllocRectypeMetadata : [SELECT Id, Core_MDF_Activity_RecordType_txt__c, Core_MDF_Region_cd__c FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt ]){
                if(claimActAllocRectypeMetadata.Core_MDF_Region_cd__c != NULL){//if Region Code has some values for that particular program record
                    List<String> geoProgramList = claimActAllocRectypeMetadata.Core_MDF_Region_cd__c.split(';');//split the Region Code into List of Regions
                    if(geoProgramList != NULL && geoProgramList.size() > 0){
                        programGeoReqMap.put(claimActAllocRectypeMetadata.Core_MDF_Activity_RecordType_txt__c, geoProgramList );
                    }
                }
            }
            
            //Fetch the owner language locale and store in ownerIdLangLocaleMap
            Map<Id, String> ownerIdLangLocaleMap = new Map<Id, String>();
            for(User ownerLang : [SELECT Id, LanguageLocaleKey
                                            FROM User
                                            WHERE Id  =: OwnerId]){
                ownerIdLangLocaleMap.put(ownerLang.Id , ownerLang.LanguageLocaleKey);
            }
            
            if(pfrList != NULL && pfrList.size() > 0){
                for(PartnerFundRequest pfr: pfrList){                    
                    Boolean errorthrown = false;
                    // List<String> countryList = pfr.Core_MDF_Country_nm__c.split(';');
                    Date startDate = pfr.Core_MDF_Start_Date__c;
                    Date todayDate = System.today()    ;
                    Integer daysDifference = todayDate.daysBetween(startDate);
                    String dayDifference = String.valueOf(daysDifference);
                    String amount = String.valueOf(pfr.RequestedAmount); //looping over the queried metadata list
                    for(Core_MDF_PFR_Event_Rule__mdt customMetadata : pfrRecordIdMetadataMap.get(recordTypeIdDevName.get(pfr.RecordTypeId))) {
                        if(pfr.Core_MDF_Country_nm__c != NULL){
                            List< String > countryList = pfr.Core_MDF_Country_nm__c.split(';');
                            if(countryList != null && countryList.size() > 0){
                                for(String country : countryList){
                                    if(customMetadata.Core_MDF_Country_Picklist_Value__c != NULL && recordTypeIdDevName.get(pfr.RecordTypeId) == customMetadata.Core_MDF_PFR_RecordType__c && customMetadata.Core_MDF_PFR_StartDate__c > pfr.Core_MDF_Start_Date__c && !customMetadata.Core_MDF_Country_Picklist_Value__c.contains(country)){
                                        pfr.addError(Label.Core_MDF_Country_CCFB_2020_Validation);errorthrown = true;break;
                                    }                                                           
                                }
                            }
                        }
			if(!hasCustomPermission){
                            if((oldPfrMap != NULL && oldPfrMap.size() > 0 && ((oldPfrMap.get(pfr.Id).Core_MDF_Start_Date__c != pfr.Core_MDF_Start_Date__c) || (oldPfrMap.get(pfr.Id).Core_MDF_ActivityCategory__c != pfr.Core_MDF_ActivityCategory__c ) || (oldPfrMap.get(pfr.Id).Core_MDF_Activity_Types__c != pfr.Core_MDF_Activity_Types__c) || (oldPfrMap.get(pfr.Id).RequestedAmount != pfr.RequestedAmount))) || (pfr.Id == NULL)){     //Calling the Generic Compare Method
                                Boolean checkDate = Core_MDF_GenericApprovalProcess.validateRule(customMetadata.Core_MDF_Day_Difference__c, dayDifference, customMetadata.Core_MDF_Days_Difference_Operator__c, 'DOUBLE');
                                Boolean checkAmount = Core_MDF_GenericApprovalProcess.validateRule(customMetadata.Core_MDF_Requested_Amount__c,amount, customMetadata.Core_MDF_Amount_Operator__c, 'DOUBLE');
                                //checking the pfr recordtype, pfr activity category, pfr activity type, pfr status
                                if(customMetadata.Core_MDF_PFR_RecordType__c == recordTypeIdDevName.get(pfr.RecordTypeId) &&   customMetadata.Core_MDF_Activity_Category__c == pfr.Core_MDF_ActivityCategory__c &&  customMetadata.Core_MDF_Activity_Types__c.contains(pfr.Core_MDF_Activity_Types__c) && !(pfr.Core_MDF_Fund_Request_Status__c.Contains(Label.Core_MDF_PFR_Status))) {
                                    // 30 and 60 days validation for event activity starting from 01.01.2020 with budget less than and greater than or equal 50K
                                    if(startDate >= customMetadata.Core_MDF_PFR_StartDate__c && checkDate && checkAmount){ pfr.addError(customMetadata.Core_MDF_Error_Message__c); errorthrown = true;break;
                                                                                                                         }
                                    // 22 days validation for event activity starting before 01.01.2020
                                    else if(startDate < customMetadata.Core_MDF_PFR_StartDate__c && pfr.RequestedAmount >= (Double.valueof(customMetadata.Core_MDF_Requested_Amount__c)) && customMetadata.Core_MDF_Activity_Category__c == pfr.Core_MDF_ActivityCategory__c && daysDifference < Integer.valueOf(Label.Core_MDF_22_Days_More_Than_50K) && pfr.Core_MDF_Activity_Types__c != Label.Core_MDF_Activity_Type_Promotion){
                                        pfr.addError(Label.Core_MDF_Activity_Event_22_Days);errorthrown = true;break;
                                    }
                                }
                            }
                        }
                        //Retail 14 day validation 
                        if(hasRetailCustomPermission)
                        {
                            if((oldPfrMap != NULL && oldPfrMap.get(pfr.Id).Core_MDF_Start_Date__c != pfr.Core_MDF_Start_Date__c && oldPfrMap.size() > 0) || (pfr.Id == NULL))
                            {
                                if(!(pfr.Core_MDF_Fund_Request_Status__c.Contains(Label.Core_MDF_PFR_Status)) && customMetadata.Core_MDF_PFR_RecordType__c == recordTypeIdDevName.get(pfr.RecordTypeId) && recordTypeIdDevName.get(pfr.RecordTypeId) == Label.Core_MDF_PFR_Retail && daysDifference < Integer.valueOf(customMetadata.Core_MDF_Day_Difference__c))
                                {
                                    pfr.addError(Label.Core_MDF_Activity_Retail_14_Days);
                                    errorthrown = true;
                                    break;
                                }                                       
                            }                           
                        }
                       
                    }
                    //closed date validations
                    if(!errorthrown){
                        Set<String> geoSet = new Set<String>();
                        Set<String> subGeoSet = new Set<String>();
                        if(pfr.Core_MDF_Country_nm__c != NULL){ 
                           List<String> splitCountry = pfr.Core_MDF_Country_nm__c.split(';');
                            for(String country : splitCountry){
                                if(countryGeoMap.containsKey(country)){
                                    if(countrySubGeoMap.containsKey(country)){
                                        subGeoSet.add(countrySubGeoMap.get(country));
                                    }
                                    geoSet.add(countryGeoMap.get(country));
                                    
                                }                                
                            }
                            
                           // if((geoSet != NULL && geoSet.size() > 1 ) || (subGeoSet != NULL && subGeoSet.size() > 1)){
                                
                                if(geoSet != NULL && geoSet.size() > 1 ){
                                    pfr.addError(Label.Core_MDF_Country_Multiple_Geo_Error);
                                    break;
                                }else if(subGeoSet != NULL && subGeoSet.size() > 1
                                    && (programGeoReqMap != NULL && programGeoReqMap.size() > 0 && programGeoReqMap.containsKey(recordTypeIdDevName.get(pfr.RecordTypeId)))){
                                    pfr.addError(Label.Core_MDF_Country_Multiple_SubGeo_Error);
                                    break;
                                }else{
                                List<String> geoSetList = new List<String>();                                
                                geoSetList.addAll(geoSet);
                                String test =  geoSetList[0];
                                pfr.Core_MDF_Region_cd__c =  geoSetList[0];
                                if(programGeoReqMap != NULL && programGeoReqMap.size() > 0 && recordTypeIdDevName.containsKey(pfr.RecordTypeId) && programGeoReqMap.containsKey(recordTypeIdDevName.get(pfr.RecordTypeId))){
                                    List<String> geoProgramList = programGeoReqMap.get(recordTypeIdDevName.get(pfr.RecordTypeId));
                                    if(geoProgramList != NULL && geoProgramList.contains(geoSetList[0])){
                                        List<String> subGeoSetList = New List<String>();
                                        subGeoSetList.addAll(subGeoSet);
                                        pfr.Core_MDF_Sub_Region_cd__c = subGeoSetList[0];
                                    }
                                }
                            }
                                
                        }
                    }
                   
                }
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
}