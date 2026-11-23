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
        @AuraEnabled (cacheable=true)
        public static Map<String,countryGeoSubGeoWrapper> getCountryGeoMap(){
            
            Map<String,countryGeoSubGeoWrapper> countryWrapperMap = new Map<String,countryGeoSubGeoWrapper>();
            
            try{
                for(Core_MDF_CCP_Country_Geo_Mapping__mdt mdt : [SELECT MasterLabel, Core_MDF_Geo__c, Core_MDF_Sub_Geo__c, Core_MDF_Code_2_Digits__c,Core_MDF_All_Other_ASMO_Ind__c, Core_MDF_All_Other_EMEA_Ind__c, Core_MDF_All_Other_APJ_Ind__c, Core_MDF_Blocked_in_UI_ind__c
                                                                 FROM Core_MDF_CCP_Country_Geo_Mapping__mdt LIMIT 1000]){
                    countryGeoSubGeoWrapper countryGeoSubGeoInst = new countryGeoSubGeoWrapper();
                    countryGeoSubGeoInst.country = mdt.MasterLabel;
                    countryGeoSubGeoInst.geo = mdt.Core_MDF_Geo__c;
                    countryGeoSubGeoInst.subGeo = mdt.Core_MDF_Sub_Geo__c;
                    countryGeoSubGeoInst.countryCode = mdt.Core_MDF_Code_2_Digits__c;
                    countryGeoSubGeoInst.allOtherASMO = mdt.Core_MDF_All_Other_ASMO_Ind__c;
                    countryGeoSubGeoInst.allOtherAPJ = mdt.Core_MDF_All_Other_APJ_Ind__c;
                    countryGeoSubGeoInst.allOtherEMEA = mdt.Core_MDF_All_Other_EMEA_Ind__c;
                    countryGeoSubGeoInst.blockInUI = mdt.Core_MDF_Blocked_in_UI_ind__c;
                    countryWrapperMap.put(countryGeoSubGeoInst.country, countryGeoSubGeoInst);
                }
            }
            catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
            return countryWrapperMap;
        }
        
     /****************************************************************************************************** 
    Method Name:        getPickListvalues
    @return  :          List<String>
    @parameters:        Object Name and api name
    Description:        This method is used to fetch pick list values for specific field.
    Added By:           Accenture - MD - 28/8/2024
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    @AuraEnabled
    public static Map<String,String> getPickListvalues(String objectName, String fieldApiName){
        Map<String,String> optionlist = new Map<String,String>();
        try {
            Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
            Map<String, Schema.SObjectField> fieldmap = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap(); 
            List<Schema.PicklistEntry> picklistValues = fieldmap.get(fieldApiName).getDescribe().getPickListValues();
            
            for (Schema.PicklistEntry pv : picklistValues) {
                optionlist.put(pv.getValue(),pv.getLabel());
            }
            
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        return optionlist;
    }
    
    public static Map<String,List<String>> getUserAccessMap(String fields, String whereClause) {
         List<PermissionSetAssignment> queryResults = new  List<PermissionSetAssignment>();
         Map<String,List<String>> acccessTypeMap = new Map<String,List<String>>();
         List<String> assignedPermissionSets = new List<String>();
         List<String> assignedPermSetGrps = new List<String>();
         List<String> assignedProfiles= new List<String>();
         List<String> assignedCustomPermission = new List<String>();
         Set<String> permissionSetIds = new Set<String>();
         Set<Id> assignedCustomPermSetIds = new Set<Id>();
         
        if(fields != null){
            String queryString = 'SELECT '+fields+' FROM ' + 'PermissionSetAssignment';
        
            if (whereClause != null && whereClause.trim() != '') {
                queryString += ' WHERE ' + whereClause;
            }

            if(String.isNotBlank(queryString)){
                queryResults = Database.query(queryString);
            }
            
            for(PermissionSetAssignment psa : queryResults) {
                if(psa.PermissionSet.Profile.Name != null) {
                    assignedProfiles.add((String)psa.PermissionSet.Profile.Name);
                    
                } else if(psa.PermissionSetGroup.DeveloperName != null) {
                    assignedPermSetGrps.add((String)psa.PermissionSetGroup.DeveloperName);                    
                }
                else {
                    permissionSetIds.add((String)psa.PermissionSet.Id);
                    assignedPermissionSets.add((String)psa.PermissionSet.Name);
                }
                
            }
            
            for(SetupEntityAccess customPS : [SELECT ParentId, Parent.Label,SetupEntityId,SetupEntity.Name
                                              FROM SetupEntityAccess WHERE ParentId IN : permissionSetIds and SetupEntityType ='CustomPermission']) {
                                                  assignedCustomPermSetIds.add(customPS.SetupEntityId);
                                                  
                                              }
            
            for(CustomPermission cs : [SELECT id,DeveloperName from CustomPermission where id IN :assignedCustomPermSetIds]) {
                assignedCustomPermission.add(cs.DeveloperName);
                
            }
            acccessTypeMap= new Map<String,List<String>>{'Profile' => assignedProfiles, 'PermissionSet' => assignedPermissionSets, 
                'PermissionSetGroup' => assignedPermSetGrps, 'CustomPermission' => assignedCustomPermission} ;
            
                    //acccessTypeMap.put('PermissionSet',assignedPermissionSets);

        }

        return acccessTypeMap;
    }
    
    @AuraEnabled
    public static List<PermissionSetAssignment> getPermSetAssignmentList(String fields, String whereClause) {
        
        //Take for WW49 as part of Checkmarx scan
        List<PermissionSetAssignment> assignedPermissionSets = new  List<PermissionSetAssignment>();
        String sanitizedFields = String.escapeSingleQuotes(fields);
        String sanitizedWhereClause = String.escapeSingleQuotes(whereClause);
        sanitizedWhereClause = sanitizedWhereClause.replaceAll('\\\\','');
            String queryString = 'SELECT '+ sanitizedFields +' FROM ' + 'PermissionSetAssignment';
        
            if (whereClause != null && whereClause.trim() != '') {
                queryString += ' WHERE ' + sanitizedWhereClause;
            }

            if(String.isNotBlank(queryString)){
                assignedPermissionSets = Database.query(queryString);
            }
        
      
        return assignedPermissionSets;
    }
    
        /***************************************************************************************************** 
        Class Name    :        countryGeoSubGeoWrapper
        Description   :        Wrapper class to hold country,geo,sub geo and country code
        Added By      :        Accenture - VD - 10/15/2019
        Modified By   :        Date:       Changes: 
        ******************************************************************************************************/
        public class countryGeoSubGeoWrapper{
            @AuraEnabled
            public String country;
            @AuraEnabled
            public String geo;
            @AuraEnabled
            public String subGeo;
            public String countryCode;
            @AuraEnabled
            public Boolean allOtherASMO;
            @AuraEnabled
            public Boolean allOtherAPJ;
            @AuraEnabled
            public Boolean allOtherEMEA;
            @AuraEnabled
            public Boolean blockInUI;
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
                                                            Core_MDF_Region_cd__c, Core_MDF_Group_Id__c, Core_MDF_Sub_Region_cd__c,Core_MDF_BudgetType_nm__c,Core_MDF_Channel_Program__r.Name 
                                                            FROM Core_MDF_Partner_Group_Mapping__c
                                                            WHERE Core_MDF_Account__c IN :accountIdSet AND
                                                            Core_MDF_Inactive_Ind__c = false AND
                                                            Core_MDF_Channel_Program__c IN :programIdSet AND
                                                            (Core_MDF_Region_cd__c IN :geoSet OR Core_MDF_Region_cd__c ='WW')
                                                            AND Core_MDF_Type_of_Access__c = 'Internal']){
                if(geoSet.contains(pgm.Core_MDF_Region_cd__c)){ //for the 4 Non WW Geos
                    if(pgm.Core_MDF_Sub_Region_cd__c != NULL){
                        String accountIdProgramIdGeoSubGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c;
    
                        if(accountIdProgramIdGeoSubGeoObjectIdListMap != NULL && accountIdProgramIdGeoSubGeoObjectIdListMap.containsKey(accountIdProgramIdGeoSubGeo)){
                            for(Id objectId : accountIdProgramIdGeoSubGeoObjectIdListMap.get(accountIdProgramIdGeoSubGeo)){
                                if(objectIdUserGroupIdListMap.containsKey(objectId)){List<Id> groupIdList = new List<Id>();
                                 groupIdList = objectIdUserGroupIdListMap.get(objectId);
                                 groupIdList.add(pgm.Core_MDF_Group_Id__c);
                                 objectIdUserGroupIdListMap.put(objectId, groupIdList);
                                }
                                else{List<Id> groupIdList = new List<Id>();
                                     groupIdList.add(pgm.Core_MDF_Group_Id__c);
                                     objectIdUserGroupIdListMap.put(objectId, groupIdList);
                                }
                            }
                        }
                    }
                    else{
                        String accountIdProgramIdGeo = '';
                        if(pgm.Core_MDF_BudgetType_nm__c == null){
                           accountIdProgramIdGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c;
                        }
                        else{
                            accountIdProgramIdGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_BudgetType_nm__c;
                        }
                        if(accountIdProgramIdGeoObjectIdListMap != NULL && accountIdProgramIdGeoObjectIdListMap.containsKey(accountIdProgramIdGeo)){
                            for(Id objectId : accountIdProgramIdGeoObjectIdListMap.get(accountIdProgramIdGeo)){
                                if(objectIdUserGroupIdListMap.containsKey(objectId)){List<Id> groupIdList = new List<Id>();
                                     groupIdList = objectIdUserGroupIdListMap.get(objectId);
                                     groupIdList.add(pgm.Core_MDF_Group_Id__c);
                                     objectIdUserGroupIdListMap.put(objectId, groupIdList);                                                
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
                    
                    //budget type sharing for activity map
                    if(pgm.Core_MDF_BudgetType_nm__c != null){
                        String accountIdProgramIdGeoBudget = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c + pgm.Core_MDF_BudgetType_nm__c;
                        if(accountIdProgramIdGeoObjectIdListMap != NULL && accountIdProgramIdGeoObjectIdListMap.containsKey(accountIdProgramIdGeoBudget)){
                            for(Id objectId : accountIdProgramIdGeoObjectIdListMap.get(accountIdProgramIdGeoBudget)){
                                if(objectIdUserGroupIdListMap.containsKey(objectId)){
                                    List<Id> groupIdList = new List<Id>();
                                    groupIdList = objectIdUserGroupIdListMap.get(objectId);
                                    groupIdList.add(pgm.Core_MDF_Group_Id__c);
                                    objectIdUserGroupIdListMap.put(objectId, groupIdList);
                                }
                                else{
                                    List<Id> groupIdList = new List<Id>();
                                    groupIdList.add(pgm.Core_MDF_Group_Id__c);
                                    objectIdUserGroupIdListMap.put(objectId, groupIdList);
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
                                List<Id> groupIdList = new List<Id>();
                                groupIdList.add(pgm.Core_MDF_Group_Id__c);
                                objectIdUserGroupIdListMap.put(objectId, groupIdList);
                            }
                        }
                    }
                    
                    //WW budget type
                    String accountIdProgramIdBudget = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_BudgetType_nm__c;
                    if(accountIdProgramIdObjectIdListMap != NULL && accountIdProgramIdObjectIdListMap.containsKey(accountIdProgramIdBudget)){
                        for(Id objectId : accountIdProgramIdObjectIdListMap.get(accountIdProgramIdBudget)){
                            if(objectIdUserGroupIdListMap.containsKey(objectId)){
                                List<Id> groupIdList = new List<Id>();
                                groupIdList = objectIdUserGroupIdListMap.get(objectId);
                                groupIdList.add(pgm.Core_MDF_Group_Id__c);
                                objectIdUserGroupIdListMap.put(objectId, groupIdList);
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
    
            //Merging the Internal Users and AccNodeGroups 
            Map<Id,List<Id>> objectIdUserGroupIdListMapStatic = Core_MDF_ProcessCCP_PartnerFundRequest.objectIdUserGroupIdListMap;
            objectIdUserGroupIdListMap.putAll(objectIdUserGroupIdListMapStatic);
            if(objectIdUserGroupIdListMap != NULL && objectIdUserGroupIdListMap.size() > 0){
                //return Core_MDF_GenericShareRecordActionClass.createShareRecordList(objectName, objectIdUserGroupIdListMap);
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass(objectName, objectIdUserGroupIdListMap, 'Edit');
                return Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
            }
            return NULL;
        }
    
        /***************************************************************************************************** 
        Method Name:        createShareRecForInternalPGMgrps
        @return  :          List<sObject>
        @parameters:        *objectName - API Name of the Object for which share records are going to be created
                            *recordPGMShareList - contains List of Core_MDF_RecordPGMShareWrapper records
        Description:        Create Share records for all the Objects with Internal PGM Groups
        Added By:           Accenture 
        Modified By:        Date:       Changes: 
        ******************************************************************************************************/
        public static List<sObject> createShareRecForInternalPGMgrps(String objectName, List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList){
            List<sobject> finalShareRecordList = new List<sobject>();
            
            finalShareRecordList = createShareRecForInternalPGMgrps (objectName,recordPGMShareList,true);
            if(finalShareRecordList != NULL && finalShareRecordList.size() >0)
            {
                return finalShareRecordList;
            }
            return null;
        }

        /***************************************************************************************************** 
        Method Name:        createShareRecForInternalPGMgrps
        @return  :          List<sObject>
        @parameters:        *objectName - API Name of the Object for which share records are going to be created
                            *recordPGMShareList - contains List of Core_MDF_RecordPGMShareWrapper records
                            *insertRecords - Decide to insert the records or not
        Description:        Create Share records for all the Objects with Internal PGM Groups
        Added By:           Accenture 
        Modified By:        Date:       Changes: 
        ******************************************************************************************************/
        public static List<sObject> createShareRecForInternalPGMgrps(String objectName, List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList, Boolean insertRecords){        
            
            Map<Id,List<Id>> objectIdUserGroupIdListMap = new Map<Id,List<Id>>();
            Map<Id,List<Id>> objectIdUserGroupIdListMapRead = new Map<Id,List<Id>>();
            InternalPGMSharingWrapper intPgmWrapper = prepareInternalPGMSharingMaps(objectName, recordPGMShareList);
            objectIdUserGroupIdListMap = intPgmWrapper.objectIdUserGroupIdListMap;
            objectIdUserGroupIdListMapRead = intPgmWrapper.objectIdUserGroupIdListMapRead;

             List<sobject> finalShareRecordList = new List<sobject>();
             if(objectIdUserGroupIdListMapRead != NULL && objectIdUserGroupIdListMapRead.size() > 0){
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInstRead = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass(objectName, objectIdUserGroupIdListMapRead, 'Read',false);
                List<sobject> readShareRecords = Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInstRead);
                if(readShareRecords != NULL && readShareRecords.size() >0)
                {
                 finalShareRecordList.addAll(readShareRecords);
                }
  
            }
             if(objectIdUserGroupIdListMap != NULL && objectIdUserGroupIdListMap.size() > 0){
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass(objectName, objectIdUserGroupIdListMap, 'Edit',false);
                List<sobject> editShareRecords = Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
                if(editShareRecords != NULL && editShareRecords.size() >0)
                {
                  finalShareRecordList.addAll(editShareRecords);
                }
               
            }
            if(finalShareRecordList != NULL && finalShareRecordList.size() >0 && insertRecords)
            {
                   List<Database.SaveResult> saveResultList = Database.insert(finalShareRecordList);
                   return finalShareRecordList;
            }

            return finalShareRecordList;
        }

        public static InternalPGMSharingWrapper prepareInternalPGMSharingMaps(String objectName, List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList){
            Set<Id> ultAccountIdSet = new Set<Id>();
            Set<string> programSet = new Set<string>();
            Set<String> regionSet = new Set<String>();        
            Map<String,Id> accProgWWBudgetTypeGrpMap= new Map<String,Id>();
            Map<String,Id> accProgWWGrpMap = new Map<String,Id>();
            Map<String,Id> accProgGeoSubGeoBudgetTypeGrpMap = new Map<String,Id>();
            Map<String,Id> accProgGeoSubGeoGrpMap= new Map<String,Id>();
            Map<String,Id> accProgGeoBudgetTypeGrpMap = new Map<String,Id>();
            Map<String,Id> accProgGeoGrpMap= new Map<String,Id>();
            Map<String,Set<Id>> accProgBudgetTypeGrpListMap = new Map<String,Set<Id>>();
            Map<String,Set<Id>> accProgGrpListMap = new Map<String,Set<Id>>();
            Map<String,Set<Id>> accProgGrpSetMap = new Map<String,Set<Id>>();
            Map<String,Set<Id>> accProgSubGeoGrpSetMap = new Map<String,Set<Id>>();
            Map<String,Set<Id>> accProgGeoGrpSetMap = new Map<String,Set<Id>>();
            Map<String,Core_MDF_ChannelProgram__mdt> cpMdtMap = new Map<String,Core_MDF_ChannelProgram__mdt>();
            Set<String> subGeoSharingReqProgSet = new Set<String>();
            Boolean geoBasedSharingReq = FALSE;
            //List to store all the objects that do not require Geo-based sharing
            List<String> objectsForAllGeoSharing = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Objects_for_RO_All_Geo_Sharing');
            List<String> objectsForAllBudTypeSharing = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Objects_For_All_BudType_Sharing');
            List<String> hostRegionSharingReqProg = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_HostRegionSharingReqProg');
            List<String> objectsForHostRegSharing = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_HostRegionSharingReqObj');
            Map<Id,List<Id>> objectIdUserGroupIdListMap = new Map<Id,List<Id>>();
            Map<Id,List<Id>> objectIdUserGroupIdListMapRead = new Map<Id,List<Id>>();

            for(Core_MDF_RecordPGMShareWrapper shareRec : recordPGMShareList)
            {
                ultAccountIdSet.add(shareRec.ultAccountId);
                programSet.add(shareRec.program);
                if(String.isNotBlank(shareRec.geo)){
                    regionSet.add(shareRec.geo);
                }            
            }
            for(Core_MDF_ChannelProgram__mdt cpMdt : [SELECT Label,Core_MDF_Technical_Program_Name__c,Geo_Based_Sharing_Required__c FROM
                                                      Core_MDF_ChannelProgram__mdt LIMIT 1000])
            {
                cpMdtMap.put(cpMdt.Label,cpMdt);
            }
            for(Core_MDF_ClaimActAllocRecTypeMapping__mdt mdtRec : [SELECT Core_MDF_Channel_Program_Name_txt__c,Core_MDF_Region_cd__c FROM
                                                                    Core_MDF_ClaimActAllocRecTypeMapping__mdt WHERE
                                                                    Core_MDF_Region_cd__c != NULL])
            {
                subGeoSharingReqProgSet.add(mdtRec.Core_MDF_Channel_Program_Name_txt__c);
            }
    
            if(objectsForAllGeoSharing.contains(objectName)){ 
                for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Core_MDF_Account__c, Core_MDF_Account__r.Name, Core_MDF_Channel_Program__c,Core_MDF_Group_Name__c,
                                                            Core_MDF_Region_cd__c, Core_MDF_Group_Id__c, Core_MDF_Sub_Region_cd__c,Core_MDF_BudgetType_nm__c,Core_MDF_Channel_Program__r.Name 
                                                            FROM Core_MDF_Partner_Group_Mapping__c
                                                            WHERE Core_MDF_Account__c IN :ultAccountIdSet AND
                                                            Core_MDF_Inactive_Ind__c = false AND 
                                                            Core_MDF_Channel_Program__r.Name IN :programSet AND
                                                            Core_MDF_Group_Id__c != NULL AND
                                                            Core_MDF_Region_cd__c != NULL AND
                                                            Core_MDF_Type_of_Access__c = 'Internal'])
                {
                    if(hostRegionSharingReqProg.contains(pgm.Core_MDF_Channel_Program__r.Name) || (!hostRegionSharingReqProg.contains(pgm.Core_MDF_Channel_Program__r.Name) && cpMdtMap.containsKey(pgm.Core_MDF_Channel_Program__r.Name) && !cpMdtMap.get(pgm.Core_MDF_Channel_Program__r.Name).Geo_Based_Sharing_Required__c)){                
                        if(pgm.Core_MDF_BudgetType_nm__c != NULL){
                            String accIdProgBudTypePGMKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__r.Name + pgm.Core_MDF_BudgetType_nm__c;
                            if(accProgBudgetTypeGrpListMap.containsKey(accIdProgBudTypePGMKey)){
                                accProgBudgetTypeGrpListMap.get(accIdProgBudTypePGMKey).add(pgm.Core_MDF_Group_Id__c);
                            }else{
                                accProgBudgetTypeGrpListMap.put(accIdProgBudTypePGMKey, new Set<Id>{pgm.Core_MDF_Group_Id__c});
                            }
                            if(objectsForAllBudTypeSharing.contains(objectName)){
                                String accIdProgPGMKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__r.Name;
                                if(accProgGrpListMap.containsKey(accIdProgPGMKey)){
                                    accProgGrpListMap.get(accIdProgPGMKey).add(pgm.Core_MDF_Group_Id__c);
                                }else{
                                    accProgGrpListMap.put(accIdProgPGMKey, new Set<Id>{pgm.Core_MDF_Group_Id__c});
                                }
                            }
                        }else{
                            String accIdProgPGMKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__r.Name;
                            if(accProgGrpListMap.containsKey(accIdProgPGMKey)){
                                accProgGrpListMap.get(accIdProgPGMKey).add(pgm.Core_MDF_Group_Id__c);
                            }else{
                                accProgGrpListMap.put(accIdProgPGMKey, new Set<Id>{pgm.Core_MDF_Group_Id__c});
                            }
                        }
                        if(hostRegionSharingReqProg.contains(pgm.Core_MDF_Channel_Program__r.Name) && objectsForHostRegSharing.contains(objectName)){
                            geoBasedSharingReq = TRUE;
                        }
                    }else if(!geoBasedSharingReq){
                        geoBasedSharingReq = TRUE;
                    }
                }
            }
            if(!objectsForAllGeoSharing.contains(objectName) || geoBasedSharingReq){
                //Get the PGM based on account and program, filter based on geo and create accountIdProgramIdGeoGroupIdMap and accountIdProgramIdWWGroupIdMap
                for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Core_MDF_Account__c, Core_MDF_Account__r.Name, Core_MDF_Channel_Program__c,Core_MDF_Group_Name__c,
                                                             Core_MDF_Region_cd__c, Core_MDF_Group_Id__c, Core_MDF_Sub_Region_cd__c,Core_MDF_BudgetType_nm__c,Core_MDF_Channel_Program__r.Name 
                                                             FROM Core_MDF_Partner_Group_Mapping__c
                                                             WHERE Core_MDF_Account__c IN :ultAccountIdSet AND
                                                             Core_MDF_Inactive_Ind__c = false AND 
                                                             Core_MDF_Channel_Program__r.Name IN :programSet AND
                                                             Core_MDF_Group_Id__c != NULL AND
                                                             (Core_MDF_Region_cd__c IN :regionSet OR Core_MDF_Region_cd__c ='WW') AND
                                                             Core_MDF_Type_of_Access__c = 'Internal'])
                {
                    if(pgm.Core_MDF_Region_cd__c == 'WW'){
                        if(pgm.Core_MDF_BudgetType_nm__c == NULL || String.isEmpty(pgm.Core_MDF_BudgetType_nm__c)){
                            String accIdProgPGMWWKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__r.Name;
                            accProgWWGrpMap.put(accIdProgPGMWWKey,pgm.Core_MDF_Group_Id__c);                        
                        }else{
                            //WW budget type
                            String accIdProgBudTypeWWPGMKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__r.Name + pgm.Core_MDF_BudgetType_nm__c;
                            accProgWWBudgetTypeGrpMap.put(accIdProgBudTypeWWPGMKey,pgm.Core_MDF_Group_Id__c);
                            if(objectsForAllBudTypeSharing.contains(objectName)){
                                String accIdProgPGMKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__r.Name;
                                if(accProgGrpSetMap.containsKey(accIdProgPGMKey)){
                                    accProgGrpSetMap.get(accIdProgPGMKey).add(pgm.Core_MDF_Group_Id__c);
                                }else{
                                    accProgGrpSetMap.put(accIdProgPGMKey, new Set<Id>{pgm.Core_MDF_Group_Id__c});
                                }
                            }
                        }
                    }else{ //for the 4 Non WW Geos
                        if(pgm.Core_MDF_Sub_Region_cd__c == NULL || String.isEmpty(pgm.Core_MDF_Sub_Region_cd__c)){
                            if(pgm.Core_MDF_BudgetType_nm__c == NULL || String.isEmpty(pgm.Core_MDF_BudgetType_nm__c)){
                                String accIdProgGeoPGMKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__r.Name + pgm.Core_MDF_Region_cd__c;
                                accProgGeoGrpMap.put(accIdProgGeoPGMKey,pgm.Core_MDF_Group_Id__c);
                            }
                            else{
                                String accIdProgGeoBudTypePGMKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__r.Name + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_BudgetType_nm__c;
                                accProgGeoBudgetTypeGrpMap.put(accIdProgGeoBudTypePGMKey,pgm.Core_MDF_Group_Id__c);
                                if(objectsForAllBudTypeSharing.contains(objectName)){
                                    String accIdProgGeoPGMKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__r.Name + pgm.Core_MDF_Region_cd__c;
                                    if(accProgGeoGrpSetMap.containsKey(accIdProgGeoPGMKey)){
                                        accProgGeoGrpSetMap.get(accIdProgGeoPGMKey).add(pgm.Core_MDF_Group_Id__c);
                                    }else{
                                        accProgGeoGrpSetMap.put(accIdProgGeoPGMKey, new Set<Id>{pgm.Core_MDF_Group_Id__c});
                                    }
                                }
                            }                            
                        }else{
                            if(pgm.Core_MDF_BudgetType_nm__c == NULL || String.isEmpty(pgm.Core_MDF_BudgetType_nm__c)){ 
                                String accIdProgGeoSubGeoPGMKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__r.Name + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c;
                                accProgGeoSubGeoGrpMap.put(accIdProgGeoSubGeoPGMKey,pgm.Core_MDF_Group_Id__c);
                            }else {   
                                String accIdProgGeoSubGeoBudTypePGMKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__r.Name + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c+pgm.Core_MDF_BudgetType_nm__c;
                                accProgGeoSubGeoBudgetTypeGrpMap.put(accIdProgGeoSubGeoBudTypePGMKey,pgm.Core_MDF_Group_Id__c);
                                if(objectsForAllBudTypeSharing.contains(objectName)){
                                    String accIdProgSubGeoPGMKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__r.Name + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c;
                                    if(accProgSubGeoGrpSetMap.containsKey(accIdProgSubGeoPGMKey)){
                                        accProgSubGeoGrpSetMap.get(accIdProgSubGeoPGMKey).add(pgm.Core_MDF_Group_Id__c);
                                    }else{
                                        accProgSubGeoGrpSetMap.put(accIdProgSubGeoPGMKey, new Set<Id>{pgm.Core_MDF_Group_Id__c});
                                    }
                                }
                            }                             
                        }
                    }
                }
                geoBasedSharingReq = FALSE;
            }
            //To Loop thro each incoming record and store the groups that it should be shared with
            for(Core_MDF_RecordPGMShareWrapper record: recordPGMShareList){                  
                //to store rw group id's
                List<Id> grpLst = new List<Id>();
                Set<Id>grpSet = new Set<Id>();
                String accIdProgBudTypeRecKey = (String)record.ultAccountId + (String)record.program + record.budgetType;
                String accIdProgRecKey = (String)record.ultAccountId + (String)record.program;
                String accIdProgGeoSubGeoBudTypeRecKey = (String)record.ultAccountId + (String)record.program + record.geo + record.subGeo + record.budgetType;
                String accIdProgGeoSubGeoRecKey = (String)record.ultAccountId + (String)record.program + record.geo + record.subGeo;
                String accIdProgGeoBudTyperecKey = (String)record.ultAccountId + (String)record.program + record.geo + record.budgetType;
                String accIdProgGeoRecKey = (String)record.ultAccountId + (String)record.program + record.geo;
                if(objectsForAllGeoSharing.contains(objectName) && ((hostRegionSharingReqProg.contains(record.program) && ((String.isBlank(record.geo) && objectsForHostRegSharing.contains(objectName)) || !objectsForHostRegSharing.contains(objectName))) || (!hostRegionSharingReqProg.contains(record.program) && cpMdtMap.containsKey(record.program) && !cpMdtMap.get(record.program).Geo_Based_Sharing_Required__c))){
                    if(record.budgetType !=null){
                        if(accProgBudgetTypeGrpListMap.containsKey(accIdProgBudTypeRecKey) && accProgBudgetTypeGrpListMap.get(accIdProgBudTypeRecKey) != NULL){
                            grpSet.addAll(accProgBudgetTypeGrpListMap.get(accIdProgBudTypeRecKey));
                        }
                    }
                    if(accProgGrpListMap.containsKey(accIdProgRecKey) && accProgGrpListMap.get(accIdProgRecKey) != NULL){
                        grpSet.addAll(accProgGrpListMap.get(accIdProgRecKey));
                    }                
                }else{
                    if(record.subGeo !=null && !Core_MDF_CustomLabelConfig.getTextList('Core_MDF_PGMSubGeoSharingNotReqProg').contains(record.program) && cpMdtMap.containsKey(record.program) && subGeoSharingReqProgSet.contains(cpMdtMap.get(record.program).Core_MDF_Technical_Program_Name__c)){
                        if(record.budgetType !=null){
                            if(accProgGeoSubGeoBudgetTypeGrpMap.containsKey(accIdProgGeoSubGeoBudTypeRecKey) && accProgGeoSubGeoBudgetTypeGrpMap.get(accIdProgGeoSubGeoBudTypeRecKey) != NULL){
                                grpSet.add(accProgGeoSubGeoBudgetTypeGrpMap.get(accIdProgGeoSubGeoBudTypeRecKey));
                            }                        
                        }
                        if(accProgGeoSubGeoGrpMap.containsKey(accIdProgGeoSubGeoRecKey) && accProgGeoSubGeoGrpMap.get(accIdProgGeoSubGeoRecKey) != NULL){
                            grpSet.add(accProgGeoSubGeoGrpMap.get(accIdProgGeoSubGeoRecKey));
                        }
                        if(objectsForAllBudTypeSharing.contains(objectName) && accProgSubGeoGrpSetMap.containsKey(accIdProgGeoSubGeoRecKey) && accProgSubGeoGrpSetMap.get(accIdProgGeoSubGeoRecKey) != NULL){
                            grpSet.addAll(accProgSubGeoGrpSetMap.get(accIdProgGeoSubGeoRecKey));
                        }                  
                    }
                    if(record.budgetType !=null){
                        if(accProgWWBudgetTypeGrpMap.containsKey(accIdProgBudTypeRecKey) && accProgWWBudgetTypeGrpMap.get(accIdProgBudTypeRecKey) != NULL){
                            grpSet.add(accProgWWBudgetTypeGrpMap.get(accIdProgBudTypeRecKey));
                        }
                        if(accProgGeoBudgetTypeGrpMap.containsKey(accIdProgGeoBudTyperecKey) && accProgGeoBudgetTypeGrpMap.get(accIdProgGeoBudTyperecKey) != NULL){
                            grpSet.add(accProgGeoBudgetTypeGrpMap.get(accIdProgGeoBudTyperecKey));
                        }
                    }
                    if(accProgWWGrpMap.containsKey(accIdProgRecKey) && accProgWWGrpMap.get(accIdProgRecKey) != NULL){
                        grpSet.add(accProgWWGrpMap.get(accIdProgRecKey));
                    }
                    if(accProgGeoGrpMap.containsKey(accIdProgGeoRecKey) && accProgGeoGrpMap.get(accIdProgGeoRecKey) != NULL){
                        grpSet.add(accProgGeoGrpMap.get(accIdProgGeoRecKey));
                    }
                    if(objectsForAllBudTypeSharing.contains(objectName) && accProgGrpSetMap.containsKey(accIdProgRecKey) && accProgGrpSetMap.get(accIdProgRecKey) != NULL){
                        grpSet.addAll(accProgGrpSetMap.get(accIdProgRecKey));
                    }
                    if(objectsForAllBudTypeSharing.contains(objectName) && accProgGeoGrpSetMap.containsKey(accIdProgGeoRecKey) && accProgGeoGrpSetMap.get(accIdProgGeoRecKey) != NULL){
                        grpSet.addAll(accProgGeoGrpSetMap.get(accIdProgGeoRecKey));
                    }                             
                }
                grpLst.addAll(grpSet);

                if(record.accessLevel != NULL && record.accessLevel.equalsIgnoreCase('READ'))
                {
                  if(objectIdUserGroupIdListMapRead.containsKey(record.recordId)){
                    objectIdUserGroupIdListMapRead.get(record.recordId).addAll(grpLst);
                   }else{
                    objectIdUserGroupIdListMapRead.put(record.recordId, grpLst);
                   }
                }
                else
                {
                   if(objectIdUserGroupIdListMap.containsKey(record.recordId)){
                    objectIdUserGroupIdListMap.get(record.recordId).addAll(grpLst);
                   }else{
                    objectIdUserGroupIdListMap.put(record.recordId, grpLst);
                    }

                }

            }
            InternalPGMSharingWrapper intPgmWrapper = new InternalPGMSharingWrapper();
            intPgmWrapper.objectIdUserGroupIdListMapRead = objectIdUserGroupIdListMapRead;
            intPgmWrapper.objectIdUserGroupIdListMap = objectIdUserGroupIdListMap;

            return intPgmWrapper;
        }

        public class InternalPGMSharingWrapper{
            public Map<Id,List<Id>> objectIdUserGroupIdListMapRead;
            public Map<Id,List<Id>> objectIdUserGroupIdListMap;
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
                                                                     Core_MDF_Inactive_Ind__c = false AND 
                                                                     Core_MDF_Channel_Program__c IN :programIdSet AND
                                                                     (Core_MDF_Region_cd__c IN :geoStringSet OR Core_MDF_Region_cd__c = 'WW')
                                                                     AND Core_MDF_Type_of_Access__c = 'Internal'];
            for(Core_MDF_Partner_Group_Mapping__c pgm : pgmList){
                if(pgm.Core_MDF_Region_cd__c != 'WW'){
                    if(pgm.Core_MDF_Sub_Region_cd__c != NULL){
                        String accountIdProgramIdGeoSubGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c;
                        if(accountIdProgramIdGeoSubGeoStringSet != NULL && accountIdProgramIdGeoSubGeoStringSet.contains(accountIdProgramIdGeoSubGeo)){
                            groupIdSet.add(pgm.Core_MDF_Group_Id__c);
                        }
                        
                    }
                    else{
                        String accountIdProgramIdGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c;
                        if(accountIdProgramIdGeoStringSet != NULL && accountIdProgramIdGeoStringSet.contains(accountIdProgramIdGeo)){
        
                            groupIdSet.add(pgm.Core_MDF_Group_Id__c);
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
           /****************************************************************************************************** 
    Method Name:        getTechnicalProgramName
    @return  :          String
    @parameters:        Program Label
    Description:        This method is used to get Technical Program Name
    Added By:           Accenture - AN - 22/10/2024
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
        public static String getTechnicalProgramName(String programLabel){
            try{
                String technicalProgramNm = '';
                if(String.isNotBlank(programLabel)){
                    technicalProgramNm = (programLabel.toLowerCase()) == (Core_MDF_CCP_ConstantClass.CCF_PROGRAM.toLowerCase()) ? (Core_MDF_CCP_ConstantClass.CCF_TECHNICAL_PROGRAM_NAME) : (programLabel.toLowerCase() == (Core_MDF_CCP_ConstantClass.DCF_PROGRAM.toLowerCase()) ? (Core_MDF_CCP_ConstantClass.DCF_TECHNICAL_PROGRAM_NAME) : (programLabel.replace('-', '')));
                }
                return technicalProgramNm;
                
            }catch(Exception e){throw e;}
        }
              /****************************************************************************************************** 
    Method Name:        getProgramLabel
    @return  :          String
    @parameters:        Technical Program Name
    Description:        This method is used to get Program Label
    Added By:           Accenture - AN - 11/11/2024
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public static String getProgramLabel(String programName){
        try{
            String programLabel = '';

            if(String.isNotBlank(programName)){
               
                switch on programName {
                    when 'Client CoMarketing Fund' {
                        programLabel = Core_MDF_CCP_ConstantClass.CCF_PROGRAM;
                    }
                    when 'Data Center CoMarketing Fund' {
                        programLabel = Core_MDF_CCP_ConstantClass.DCF_PROGRAM;
                    }
                    when 'Client CoMarketing Fund Boost' {
                        programLabel = Core_MDF_CCP_ConstantClass.CCFB_PROGRAM;
                    }
                    when 'Service Provide CoMarketing Fund' {
                        programLabel = Core_MDF_CCP_ConstantClass.SPCF_PROGRAM;
                    }
                    when else{
                        programLabel = programName;
                    }
                 }
                }
               
            return programLabel;
            
        }catch(Exception e){throw e;}
    }
    
    /****************************************************************************************************** 
    Method Name:        getUserIdToPermissionSetsMapByPSNames
    @return  :          Map of userId to his assigned permission sets
    @parameters:        Permission Set name list
    Description:        This method is used to get userId and his assigned permission sets by passing permission set names
    Added By:           Accenture - Vikas Soni - 26/12/2024
    Modified By:        Accenture - Vikas Soni Date: 14/04/2025      Changes: additional conditions for query
    Roshan              06/02/2025    Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
    *******************************************************************************************************/  
    public static Map<Id,Set<String>> getUserIdToPermissionSetsMapByPSNames(List<String> psNameList, String additionalWhereCondition){
        Map<Id, Set<String>> userIdToPermissionSetAssignmentsMap = new Map<Id, Set<String>>();
        String query = 'SELECT Id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSet.Name IN: psNameList AND (Assignee.IsActive = TRUE OR Assignee.Partner_License_Reclaimed__c = TRUE) ';
        if(additionalWhereCondition != null && additionalWhereCondition != ''){
            query += additionalWhereCondition;
        }
        for(PermissionSetAssignment psaList : Database.query(query)){
            if(userIdToPermissionSetAssignmentsMap.containsKey(psaList.AssigneeId)){
                userIdToPermissionSetAssignmentsMap.get(psaList.AssigneeId).add(psaList.PermissionSet.Name);
            }else{
                userIdToPermissionSetAssignmentsMap.put(psaList.AssigneeId, new Set<String>{psaList.PermissionSet.Name});
            }
        }
        return userIdToPermissionSetAssignmentsMap;
    }
    
    /****************************************************************************************************** 
    Method Name:        getIUPGMRecordsByWrapper
    @return  :          List of Core_MDF_Int_Users_Partner_Geo_Mapping__c records
    @parameters:        Wrapper object of 'QueryIUPGMRecordsWrapper'
    Description:        This method is used to get IUPGM records by passing data through wrapper
    Added By:           Accenture - Vikas Soni - 26/12/2024
    Modified By:        Accenture - Vikas Soni Date: 14/04/2025      Changes: additional conditions for query
    *******************************************************************************************************/    
    public static List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> getIUPGMRecordsByWrapper(QueryIUPGMRecordsWrapper queryIUPGMRecordsWrapperObj){
        Set<Id> userIdSet = new Set<Id>();
        Map<Id, Set<String>> userIdToPermissionSetAssignmentsMap = new Map<Id, Set<String>>();
        List<String> combinedPSNames = new List<String>();
        Set<Id> channelProgramIds = queryIUPGMRecordsWrapperObj.channelProgramIds;
        List<String> psNameList = queryIUPGMRecordsWrapperObj.psNameList;
        Set<Id> accountIdsForIUPGMSet = queryIUPGMRecordsWrapperObj.accountIdsForIUPGMSet;
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Set<Id> subUnsubUserIdSet = new Set<Id>();
        List<Id> filteredUserIdList = new List<Id>();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> filterdIupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Boolean filterUsersBasedOnSub = false;
        
        if(queryIUPGMRecordsWrapperObj.isPermissionSetAssignmentBased){
            if(!queryIUPGMRecordsWrapperObj.psNameList.isEmpty()){
                combinedPSNames.addAll(queryIUPGMRecordsWrapperObj.psNameList);
            }
            if(queryIUPGMRecordsWrapperObj.psNamesToExcludeForEmail != null && !queryIUPGMRecordsWrapperObj.psNamesToExcludeForEmail.isEmpty()){
                combinedPSNames.addAll(queryIUPGMRecordsWrapperObj.psNamesToExcludeForEmail);
            }            
            //get all the permission set assignments by combining PS to exlcude and PS to include
            userIdToPermissionSetAssignmentsMap = getUserIdToPermissionSetsMapByPSNames(combinedPSNames, queryIUPGMRecordsWrapperObj.additionalWhereCondition);
            
            //filter userIdSet by removing users having PS to exclude
            for (Id userId : userIdToPermissionSetAssignmentsMap.keySet()){
                Set<String> assignedPermissionSets = userIdToPermissionSetAssignmentsMap.get(userId);                
                Boolean hasCSCPermissionSet = false;
                
                for(String psName : assignedPermissionSets){
                    if (queryIUPGMRecordsWrapperObj.psNamesToExcludeForEmail != null && queryIUPGMRecordsWrapperObj.psNamesToExcludeForEmail.contains(psName)) {
                        hasCSCPermissionSet = true; break;
                    }
                }
                if(!hasCSCPermissionSet){
                    userIdSet.add(userId);
                }
            }
        }
        
        String query = 'SELECT Id, Core_MDF_Role_nm__c, Core_MDF_User_id__c, Core_MDF_User_id__r.Email, Core_MDF_User_id__r.Name, Core_MDF_Program_nm__c, Core_MDF_All_Accounts_cd__c, Core_MDF_Account_id__c, Core_MDF_Channel_Program_id__c, Core_MDF_Channel_Program_id__r.Name' + 
            ' FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c' + 
            ' WHERE Core_MDF_Channel_Program_id__c IN :channelProgramIds' + 
            ' AND Core_MDF_Role_nm__c IN :psNameList' + 
            (queryIUPGMRecordsWrapperObj.queryAllAccounts ? ' AND (Core_MDF_Account_id__c IN :accountIdsForIUPGMSet OR Core_MDF_All_Accounts_cd__c = \'Yes\') ' : ' AND Core_MDF_Account_id__c IN :accountIdsForIUPGMSet ') +
            ' AND Core_MDF_is_User_Active_ind__c = true' +
            ' AND Core_MDF_Active_Ind__c = true';
        //keep this comment ' AND Core_MDF_Is_Not_an_Approver_Ind__c = false';
        if(queryIUPGMRecordsWrapperObj.isPSCheckReqForIUPGM != null && queryIUPGMRecordsWrapperObj.isPSCheckReqForIUPGM){
            query += ' AND Core_MDF_User_id__c IN: userIdSet';
        } else{
            query += userIdSet.size() > 0 ? ' AND Core_MDF_User_id__c IN: userIdSet' : '';
        }
        if(queryIUPGMRecordsWrapperObj.maxRows != null && queryIUPGMRecordsWrapperObj.maxRows != ''){
            query += queryIUPGMRecordsWrapperObj.maxRows;
        }
        iupgmList =  Database.query(query);
        filterUsersBasedOnSub = String.isNotBlank(queryIUPGMRecordsWrapperObj.notificationType) && String.isNotBlank(queryIUPGMRecordsWrapperObj.objectName);
        if(filterUsersBasedOnSub){
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmList){
                subUnsubUserIdSet.add(iupgm.Core_MDF_User_id__c);
            }
            
            filteredUserIdList = Core_MDF_SubUnsub_Notifications_Utility.filterUserBasedOnSubscription(queryIUPGMRecordsWrapperObj.notificationType, queryIUPGMRecordsWrapperObj.objectName, subUnsubUserIdSet);
            
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmList){
                if(filteredUserIdList.contains(iupgm.Core_MDF_User_id__c)){
                    filterdIupgmList.add(iupgm);
                }
            }
        }
        return filterUsersBasedOnSub ? filterdIupgmList : iupgmList;
    }
    
    /****************************************************************************************************** 
    Method Name:        getPNUMRecordsByWrapper
    @return  :          List of Core_MDF_Int_Users_Partner_Geo_Mapping__c records
    @parameters:        Wrapper object of 'QueryPNUMRecordsWrapper'
    Description:        This method is used to get PNUM records by passing data through wrapper
    Added By:           Accenture - Vikas Soni - 26/03/2025
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/    
    public static List<Core_MDF_Partner_Node_User_Mapping__c> getPNUMRecordsByWrapper(QueryPNUMRecordsWrapper queryPNUMRecordsWrapperObj){
        Set<Id> userIdSet = new Set<Id>();
        Map<Id, Set<String>> userIdToPermissionSetAssignmentsMap = new Map<Id, Set<String>>();
        List<String> combinedPSNames = new List<String>();
        Set<Id> channelProgramIds = queryPNUMRecordsWrapperObj.channelProgramIds;
        List<String> psNameList = queryPNUMRecordsWrapperObj.psNameList;
        Set<Id> accountIdsForPNUMSet = queryPNUMRecordsWrapperObj.accountIdsForPNUMSet;
        List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
        Set<Id> subUnsubUserIdSet = new Set<Id>();
        List<Id> filteredUserIdList = new List<Id>();
        List<Core_MDF_Partner_Node_User_Mapping__c> filterdIupgmList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
        Boolean filterUsersBasedOnSub = false;
        
        if(queryPNUMRecordsWrapperObj.isPermissionSetAssignmentBased){
            if(!queryPNUMRecordsWrapperObj.psNameList.isEmpty()){
                combinedPSNames.addAll(queryPNUMRecordsWrapperObj.psNameList);
            }
            if(queryPNUMRecordsWrapperObj.psNamesToExcludeForEmail != null && !queryPNUMRecordsWrapperObj.psNamesToExcludeForEmail.isEmpty()){
                combinedPSNames.addAll(queryPNUMRecordsWrapperObj.psNamesToExcludeForEmail);
            }            
            //get all the permission set assignments by combining PS to exlcude and PS to include
            userIdToPermissionSetAssignmentsMap = getUserIdToPermissionSetsMapByPSNames(combinedPSNames, queryPNUMRecordsWrapperObj.additionalWhereCondition);
            
            //filter userIdSet by removing users having PS to exclude
            for (Id userId : userIdToPermissionSetAssignmentsMap.keySet()){
                Set<String> assignedPermissionSets = userIdToPermissionSetAssignmentsMap.get(userId);                
                Boolean hasCSCPermissionSet = false;
                
                for(String psName : assignedPermissionSets){
                    if (queryPNUMRecordsWrapperObj.psNamesToExcludeForEmail != null && queryPNUMRecordsWrapperObj.psNamesToExcludeForEmail.contains(psName)) {
                        hasCSCPermissionSet = true; break;
                    }
                }
                if(!hasCSCPermissionSet){
                    userIdSet.add(userId);
                }
            }
        }
        String query = 'Select id,Core_MDF_User__c, Core_MDF_User__r.name,Core_MDF_User__r.email FROM Core_MDF_Partner_Node_User_Mapping__c ' + 
            'WHERE Core_MDF_Active_Ind__c = true AND Core_MDF_Account__r.Core_MDF_Channel_Program__c IN: channelProgramIds ' + 
            'AND Core_MDF_Account__c IN: accountIdsForPNUMSet ' + 'AND Core_MDF_User__c IN: userIdSet';
        if(queryPNUMRecordsWrapperObj.maxRows != null && queryPNUMRecordsWrapperObj.maxRows != ''){
            query += queryPNUMRecordsWrapperObj.maxRows;
        }
        pnumList =  Database.query(query);
        filterUsersBasedOnSub = String.isNotBlank(queryPNUMRecordsWrapperObj.notificationType) && String.isNotBlank(queryPNUMRecordsWrapperObj.objectName);
        if(filterUsersBasedOnSub){
            for(Core_MDF_Partner_Node_User_Mapping__c pnum : pnumList){
                subUnsubUserIdSet.add(pnum.Core_MDF_User__c);
            }
            
            filteredUserIdList = Core_MDF_SubUnsub_Notifications_Utility.filterUserBasedOnSubscription(queryPNUMRecordsWrapperObj.notificationType, queryPNUMRecordsWrapperObj.objectName, subUnsubUserIdSet);
            
            for(Core_MDF_Partner_Node_User_Mapping__c pnum : pnumList){
                if(filteredUserIdList.contains(pnum.Core_MDF_User__c)){
                    filterdIupgmList.add(pnum);
                }
            }
        }
        return filterUsersBasedOnSub ? filterdIupgmList : pnumList;
    }
    
    @AuraEnabled(cacheable=true)
    public static Date getUserTodayDate() {
        TimeZone userTz = UserInfo.getTimeZone();
    	String formattedDate = System.now().format('yyyy-MM-dd', userTz.getID());
    	return Date.valueOf(formattedDate);
    }
    
    public class QueryIUPGMRecordsWrapper {
        public List<String> psNameList;
        public List<String> psNamesToExcludeForEmail;
        public Set<Id> channelProgramIds;
        public Set<Id> accountIdsForIUPGMSet;
        public Boolean isPermissionSetAssignmentBased;
        public Boolean queryAllAccounts;
        public String notificationType;
        public String objectName;
        public String additionalWhereCondition;
        public String maxRows;
        public Boolean isPSCheckReqForIUPGM;
    }
    
    public class QueryPNUMRecordsWrapper {
        public List<String> psNameList;
        public List<String> psNamesToExcludeForEmail;
        public Set<Id> channelProgramIds;
        public Set<Id> accountIdsForPNUMSet;
        public Boolean isPermissionSetAssignmentBased;
        public Boolean queryAllAccounts;
        public String notificationType;
        public String objectName;
        public String additionalWhereCondition;
        public String maxRows;
    }
}