/****************************************************************************************************************************************
* Class Name        : Core_MDF_CCP_GenericUtility
* Created Date      : 10/15/2019
* Modification Log
* Developer            Date(MM/DD/YYYY)   Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       10/15/2019         Generic Utility Class for CCP Module
*****************************************************************************************************************************************/
public without sharing class Core_MDF_CCP_GenericUtility {
/*    public Core_MDF_CCP_GenericUtility() {

    }*/

    /***************************************************************************************************** 
    Method Name   :        getCountryGeoMap
    @return       :        Map of Country and CountryGeoSubGeoWrapper
    @parameters   :        NULL
    Description   :        Prepares the country-geo-subGeo mapping
    Added By      :        Accenture - VD - 10/15/2019
    Modified By   :        Date:       Changes: 
    ******************************************************************************************************/
    public static Map<String,countryGeoSubGeoWrapper> getCountryGeoMap(){
        
        Map<String,countryGeoSubGeoWrapper> countryWrapperMap = new Map<String,countryGeoSubGeoWrapper>();
        
        try{
            for(Core_MDF_CCP_Country_Geo_Mapping__mdt mdt : [SELECT MasterLabel, Core_MDF_Geo__c, Core_MDF_Sub_Geo__c, Core_MDF_Code_2_Digits__c
                                                             FROM Core_MDF_CCP_Country_Geo_Mapping__mdt]){
                countryGeoSubGeoWrapper countryGeoSubGeoInst = new countryGeoSubGeoWrapper();
                countryGeoSubGeoInst.country = mdt.MasterLabel;
                countryGeoSubGeoInst.geo = mdt.Core_MDF_Geo__c;
                countryGeoSubGeoInst.subGeo = mdt.Core_MDF_Sub_Geo__c;
                countryGeoSubGeoInst.countryCode = mdt.Core_MDF_Code_2_Digits__c;
                countryWrapperMap.put(countryGeoSubGeoInst.country, countryGeoSubGeoInst);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        return countryWrapperMap;
    }
    
    /***************************************************************************************************** 
    Class Name    :        countryGeoSubGeoWrapper
    Description   :        Wrapper class to hold country,geo,sub geo and country code
    Added By      :        Accenture - VD - 10/15/2019
    Modified By   :        Date:       Changes: 
    ******************************************************************************************************/
    public class countryGeoSubGeoWrapper{
        public String country;
        public String geo;
        public String subGeo;
        public String countryCode;
    }
    /***************************************************************************************************** 
    Method Name:        createShareRecordsForInternal
    @return  :          List<sObject>
    @parameters:        *objectName - API Name of the Object for which share records are going to be created
                        *accountIdSet - this will contain all the Ids of the Accounts for which the Objects are related to.
                        *programIdSet - this will contain all the Ids of the Programs for which the Objects are related to.
                        *geoSet - this will contain all the Geos for which the Objects are related to.
                        *accountIdProgramIdGeoSubGeoObjectIdListMap - this will contain all the Object Id List associated with the combination of Account Id, Program Id, Geo and SubGeo. This will be used for sharing the object records with groups fetched where the PGM records have SubGeo.
                        *accountIdProgramIdGeoObjectIdListMap - this will contain all the Object Id List associated with the combination of Account Id, Program Id and Geo. This will be used for sharing the object records with groups fetched where the PGM records do not have SubGeo and only Geo is present.
                        *accountIdProgramIdObjectIdListMap - this will contain all the Object Id List associated with the combination of Account Id and Program Id. This will be used for sharing the object records with WW groups.
    Description:        Create Share records for all the Objects with Internal Account Manager Groups
    Added By:           Accenture - SB - 24-10-2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static List<sObject> createShareRecordsForInternal(String objectName, Set<Id> accountIdSet, Set<Id> programIdSet, Set<String> geoSet, 
                                                  Map<String,List<Id>> accountIdProgramIdGeoSubGeoObjectIdListMap, 
                                                  Map<String,List<Id>> accountIdProgramIdGeoObjectIdListMap, 
                                                  Map<String,List<Id>> accountIdProgramIdObjectIdListMap){        
        Map<Id,List<Id>> objectIdUserGroupIdListMap = new Map<Id,List<Id>>();
        //Get the PGM based on account and program, filter based on geo and create accountIdProgramIdGeoGroupIdMap and accountIdProgramIdWWGroupIdMap
        for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Core_MDF_Account__c, Core_MDF_Account__r.Name, Core_MDF_Channel_Program__c,Core_MDF_Group_Name__c,
                                                        Core_MDF_Region_cd__c, Core_MDF_Group_Id__c, Core_MDF_Sub_Region_cd__c 
                                                        FROM Core_MDF_Partner_Group_Mapping__c
                                                        WHERE Core_MDF_Account__c IN :accountIdSet AND
                                                        Core_MDF_Channel_Program__c IN :programIdSet AND
                                                        (Core_MDF_Region_cd__c IN :geoSet OR Core_MDF_Region_cd__c ='WW')
                                                        AND Core_MDF_Type_of_Access__c = 'Internal']){
            if(geoSet.contains(pgm.Core_MDF_Region_cd__c)){ //for the 4 Non WW Geos
                System.debug('geoSet: ' + geoSet);
                System.debug('pgm.Core_MDF_Group_Id__c: ' + pgm.Core_MDF_Group_Id__c);
                if(pgm.Core_MDF_Sub_Region_cd__c != NULL){
                    String accountIdProgramIdGeoSubGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c;
                    if(accountIdProgramIdGeoSubGeoObjectIdListMap != NULL && accountIdProgramIdGeoSubGeoObjectIdListMap.containsKey(accountIdProgramIdGeoSubGeo)){
                        for(Id objectId : accountIdProgramIdGeoSubGeoObjectIdListMap.get(accountIdProgramIdGeoSubGeo)){
                            if(objectIdUserGroupIdListMap.containsKey(objectId)){List<Id> groupIdList = new List<Id>();groupIdList = objectIdUserGroupIdListMap.get(objectId);groupIdList.add(pgm.Core_MDF_Group_Id__c);objectIdUserGroupIdListMap.put(objectId, groupIdList);
                            }
                            else{List<Id> groupIdList = new List<Id>();groupIdList.add(pgm.Core_MDF_Group_Id__c);objectIdUserGroupIdListMap.put(objectId, groupIdList);
                            }
                        }
                    }
                }
                else{
                    String accountIdProgramIdGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c;
                    if(accountIdProgramIdGeoObjectIdListMap != NULL && accountIdProgramIdGeoObjectIdListMap.containsKey(accountIdProgramIdGeo)){
                        for(Id objectId : accountIdProgramIdGeoObjectIdListMap.get(accountIdProgramIdGeo)){
                            if(objectIdUserGroupIdListMap.containsKey(objectId)){List<Id> groupIdList = new List<Id>();groupIdList = objectIdUserGroupIdListMap.get(objectId);groupIdList.add(pgm.Core_MDF_Group_Id__c);objectIdUserGroupIdListMap.put(objectId, groupIdList);
                            }
                            else{
                                List<Id> groupIdList = new List<Id>();
                                groupIdList.add(pgm.Core_MDF_Group_Id__c);
                                objectIdUserGroupIdListMap.put(objectId, groupIdList);
                            }
                        }
                    }
                }
            }
            else if(pgm.Core_MDF_Region_cd__c == 'WW'){//for WW
                String accountIdProgramId = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c;
                if(accountIdProgramIdObjectIdListMap != NULL && accountIdProgramIdObjectIdListMap.containsKey(accountIdProgramId)){
                    for(Id objectId : accountIdProgramIdObjectIdListMap.get(accountIdProgramId)){
                        if(objectIdUserGroupIdListMap.containsKey(objectId)){
                            List<Id> groupIdList = new List<Id>();
                            groupIdList = objectIdUserGroupIdListMap.get(objectId);
                            groupIdList.add(pgm.Core_MDF_Group_Id__c);
                            objectIdUserGroupIdListMap.put(objectId, groupIdList);
                        }
                        else{
                            List<Id> groupIdList = new List<Id>();groupIdList.add(pgm.Core_MDF_Group_Id__c);objectIdUserGroupIdListMap.put(objectId, groupIdList);
                        }
                    }
                }
            }
        }
        if(objectIdUserGroupIdListMap != NULL && objectIdUserGroupIdListMap.size() > 0){
            //return Core_MDF_GenericShareRecordActionClass.createShareRecordList(objectName, objectIdUserGroupIdListMap);
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass(objectName, objectIdUserGroupIdListMap, 'Edit');
            return Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
        }
        return NULL;
    }

    /***************************************************************************************************** 
    Method Name:        fetchGroupIdsFromPGM
    @return  :          Set<Id>
    @parameters:        *accountIdSet - this will contain all the Ids of the Accounts for which the Objects are related to.
                        *programIdSet - this will contain all the Ids of the Programs for which the Objects are related to.
                        *geoSet - this will contain all the Geos for which the Objects are related to.
                        *accountIdProgramIdGeoSubGeoStringSet - this will contain all the concatenated String associated with the combination of Account Id, Program Id, Geo and SubGeo.
                        *accountIdProgramIdGeoStringSet - this will contain all the concatenated String associated with the combination of Account Id, Program Id and Geo.
    Description:        Create Share records for all the Objects with Internal Account Manager Groups
    Added By:           Accenture - SB - 09-12-2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static Set<Id> fetchGroupIdsFromPGM(Set<Id> accountIdSet, Set<Id> programIdSet, Set<String> geoStringSet, 
                                                  Set<String> accountIdProgramIdGeoSubGeoStringSet,
                                                  Set<String> accountIdProgramIdGeoStringSet){
        Set<Id> groupIdSet = new Set<Id>();
        List<Core_MDF_Partner_Group_Mapping__c> pgmList = [SELECT Core_MDF_Account__c, Core_MDF_Channel_Program__c,
                                                                      Core_MDF_Region_cd__c, Core_MDF_Group_Id__c, Core_MDF_Sub_Region_cd__c 
                                                           FROM Core_MDF_Partner_Group_Mapping__c
                                                           WHERE Core_MDF_Account__c IN :accountIdSet AND
                                                                 Core_MDF_Channel_Program__c IN :programIdSet AND
                                                                 (Core_MDF_Region_cd__c IN :geoStringSet OR Core_MDF_Region_cd__c = 'WW')
                                                                 AND Core_MDF_Type_of_Access__c = 'Internal'];
        System.debug('NZ-->pgmList: '+pgmList);
        for(Core_MDF_Partner_Group_Mapping__c pgm : pgmList){
            if(pgm.Core_MDF_Region_cd__c != 'WW'){
                if(pgm.Core_MDF_Sub_Region_cd__c != NULL){
                    String accountIdProgramIdGeoSubGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c;
                    System.debug('accountIdProgramIdGeoSubGeo: ' + accountIdProgramIdGeoSubGeo);
                    if(accountIdProgramIdGeoSubGeoStringSet != NULL && accountIdProgramIdGeoSubGeoStringSet.contains(accountIdProgramIdGeoSubGeo)){
                        System.debug('accountIdProgramIdGeoSubGeoStringSet: ' + accountIdProgramIdGeoSubGeoStringSet);
                        groupIdSet.add(pgm.Core_MDF_Group_Id__c);
                        System.debug('accountIdProgramIdGeoSubGeoStringSet: ' + accountIdProgramIdGeoSubGeoStringSet);
                    }
                    
                }
                else{
                    String accountIdProgramIdGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c;
                    System.debug('accountIdProgramIdGeo: ' + accountIdProgramIdGeo);
                    if(accountIdProgramIdGeoStringSet != NULL && accountIdProgramIdGeoStringSet.contains(accountIdProgramIdGeo)){
                        System.debug('accountIdProgramIdGeoStringSet: ' + accountIdProgramIdGeoStringSet);
                        groupIdSet.add(pgm.Core_MDF_Group_Id__c);
                        System.debug('accountIdProgramIdGeoStringSet: ' + accountIdProgramIdGeoStringSet);
                    }
                }
            }
            else{
                groupIdSet.add(pgm.Core_MDF_Group_Id__c);
            }
        }
        if(groupIdSet != NULL && groupIdSet.size() > 0){
            return groupIdSet;
        }
        return NULL;
    }
    
    /***************************************************************************************************** 
    ClassName:          ActivityExternalSharingParams
    @parameters:        
    Description:        This is a wrapper class to be used to send parameters to the Invocable Method
    Added By:           Intel - SB - 12/10/2019
    ******************************************************************************************************/    
    public class ActivityExternalSharingParams{
        @InvocableVariable(label = 'Activity Id' required = true)
        public Id activityId;
        @InvocableVariable(label = 'Account Id' required = true)
        public Id accountId;
    }

    /***************************************************************************************************** 
    Method Name:        deleteExternalShareForActivity
    @return  :          void
    @parameters:        
    Description:        This is an Invocable Method for the Delete PFR Share for External method
    Added By:           Intel - SB - 12/10/2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/    
    @InvocableMethod
    public static void deleteExternalShareForActivity(List<ActivityExternalSharingParams> activityExtShareParams)
    {
        deletePFRShareForExternal(activityExtShareParams);
    }

    /***************************************************************************************************** 
    Method Name:        deletePFRShareForExternal
    @return  :          void
    @parameters:        
    Description:        This is a method for the Delete PFR Share for External method
    Added By:           Intel - SB - 12/10/2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void deletePFRShareForExternal(List<ActivityExternalSharingParams> activityExtShareParams){
        try{
            Set<Id> activityIdSet = new Set<Id>();
            Set<Id> accountIdSet = new Set<Id>();
            Set<Id> userIdSet = new Set<Id>();
            List<PartnerFundRequestShare> pfrShareList = new List<PartnerFundRequestShare>();
            if(activityExtShareParams != NULL && activityExtShareParams.size() > 0){
                for(ActivityExternalSharingParams aesp : activityExtShareParams){
                    if(aesp.activityId != NULL && aesp.accountId != NULL){
                        activityIdSet.add(aesp.activityId);
                        accountIdSet.add(aesp.accountId);
                    }
                }

                for(Core_MDF_Partner_Node_User_Mapping__c pnum : [SELECT Id, Core_MDF_Account__c, Core_MDF_User__c
                                                                FROM Core_MDF_Partner_Node_User_Mapping__c
                                                                WHERE Core_MDF_Account__c IN :accountIdSet]){
                    userIdSet.add(pnum.Core_MDF_User__c);
                }

                for(PartnerFundRequestShare pfrShare : [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                                        FROM PartnerFundRequestShare
                                                        WHERE ParentId IN :activityIdSet AND 
                                                            UserOrGroupId IN :userIdSet AND
                                                            RowCause =: Label.Core_MDF_RowCause_Manual]){
                    pfrShareList.add(pfrShare);
                }
            }
            if(pfrShareList != NULL && pfrShareList.size() > 0){
                delete pfrShareList;
            }
        }catch(Exception e){throw e;}
    }
}