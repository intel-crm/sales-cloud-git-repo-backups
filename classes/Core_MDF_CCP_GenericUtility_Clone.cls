/****************************************************************************************************************************************
* Class Name        : Core_MDF_CCP_GenericUtility
* Created Date      : 10/15/2019
* Modification Log
* Developer            Date(MM/DD/YYYY)   Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       10/15/2019         Generic Utility Class for CCP Module
*****************************************************************************************************************************************/
public without sharing class Core_MDF_CCP_GenericUtility_Clone {
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
    public static List<sObject> createShareRecordsForInternal(String objectName, List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList){        
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
        Map<String,Set<Id>> accProgSubGeoGrpSetMap = new Map<String,Set<Id>>();
        Map<String,Set<Id>> accProgGeoGrpSetMap = new Map<String,Set<Id>>();
        Map<String,Core_MDF_ChannelProgram__mdt> cpMdtMap = new Map<String,Core_MDF_ChannelProgram__mdt>();
        Set<String> subGeoSharingReqProgSet = new Set<String>();
        Boolean geoBasedSharingReq = FALSE;
        //List to store all the objects that do not require Geo-based sharing
        List<String> objectsForAllGeoSharing = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Objects_for_RO_All_Geo_Sharing');
        List<String> objectsForAllBudTypeSharing = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Objects_For_All_BudType_Sharing');
        List<String> hostRegionSharingReqProg = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_HostRegionSharingReqProg');
        Map<Id,List<Id>> objectIdUserGroupIdListMap = new Map<Id,List<Id>>();
        for(Core_MDF_RecordPGMShareWrapper shareRec : recordPGMShareList)
        {
            ultAccountIdSet.add(shareRec.ultAccountId);
            programSet.add(shareRec.program);
            if(shareRec.geo != NULL){
                regionSet.add(shareRec.geo);
            }            
        }
        for(Core_MDF_ChannelProgram__mdt cpMdt : [SELECT Label,Core_MDF_Technical_Program_Name__c,Geo_Based_Sharing_Required__c FROM
                                                  Core_MDF_ChannelProgram__mdt])
        {
            cpMdtMap.put(cpMdt.Label,cpMdt);
        }
        for(Core_MDF_ClaimActAllocRecTypeMapping__mdt mdtRec : [SELECT Core_MDF_Channel_Program_Name_txt__c,Core_MDF_Region_cd__c FROM
                                                                Core_MDF_ClaimActAllocRecTypeMapping__mdt WHERE
                                                                Core_MDF_Region_cd__c != NULL])
        {
            subGeoSharingReqProgSet.add(mdtRec.Core_MDF_Channel_Program_Name_txt__c);
        }
        system.debug('objName@::'+objectName);
        if(objectsForAllGeoSharing.contains(objectName)){ 
            system.debug('cominginside1stif@::');
            for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Core_MDF_Account__c, Core_MDF_Account__r.Name, Core_MDF_Channel_Program__c,Core_MDF_Group_Name__c,
                                                        Core_MDF_Region_cd__c, Core_MDF_Group_Id__c, Core_MDF_Sub_Region_cd__c,Core_MDF_BudgetType_nm__c,Core_MDF_Channel_Program__r.Name 
                                                        FROM Core_MDF_Partner_Group_Mapping__c
                                                        WHERE Core_MDF_Account__c IN :ultAccountIdSet AND
                                                        Core_MDF_Channel_Program__r.Name IN :programSet AND
                                                        Core_MDF_Group_Id__c != NULL AND
                                                        Core_MDF_Region_cd__c != NULL AND
                                                        Core_MDF_Type_of_Access__c = 'Internal'])
            {
                system.debug('afterpgmquery1st@::');
                if(cpMdtMap.containsKey(pgm.Core_MDF_Channel_Program__r.Name) && !cpMdtMap.get(pgm.Core_MDF_Channel_Program__r.Name).Geo_Based_Sharing_Required__c && !hostRegionSharingReqProg.contains(pgm.Core_MDF_Channel_Program__r.Name)){                
                    system.debug('cominginside1stif1stcond@::');
                    if(pgm.Core_MDF_BudgetType_nm__c != NULL){
                        system.debug('cominginside1stif2ndcond@::');
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
                        system.debug('cominginside1stif3rdcond@::');
                        String accIdProgPGMKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__r.Name;
                        if(accProgGrpListMap.containsKey(accIdProgPGMKey)){
                            accProgGrpListMap.get(accIdProgPGMKey).add(pgm.Core_MDF_Group_Id__c);
                        }else{
                            accProgGrpListMap.put(accIdProgPGMKey, new Set<Id>{pgm.Core_MDF_Group_Id__c});
                        }
                    }
                }else if(!geoBasedSharingReq){
                    geoBasedSharingReq = TRUE;
                }
            }
        }
        system.debug('accProgGrpListMap@::'+accProgGrpListMap);
        system.debug('accProgBudgetTypeGrpListMap@::'+accProgBudgetTypeGrpListMap);
        system.debug('geoBasedSharingReq@::'+geoBasedSharingReq);
        if(!objectsForAllGeoSharing.contains(objectName) || geoBasedSharingReq){
            system.debug('cominginside2ndif@::');
            //Get the PGM based on account and program, filter based on geo and create accountIdProgramIdGeoGroupIdMap and accountIdProgramIdWWGroupIdMap
            for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Core_MDF_Account__c, Core_MDF_Account__r.Name, Core_MDF_Channel_Program__c,Core_MDF_Group_Name__c,
                                                         Core_MDF_Region_cd__c, Core_MDF_Group_Id__c, Core_MDF_Sub_Region_cd__c,Core_MDF_BudgetType_nm__c,Core_MDF_Channel_Program__r.Name 
                                                         FROM Core_MDF_Partner_Group_Mapping__c
                                                         WHERE Core_MDF_Account__c IN :ultAccountIdSet AND
                                                         Core_MDF_Channel_Program__r.Name IN :programSet AND
                                                         Core_MDF_Group_Id__c != NULL AND
                                                         (Core_MDF_Region_cd__c IN :regionSet OR Core_MDF_Region_cd__c ='WW') AND
                                                         Core_MDF_Type_of_Access__c = 'Internal'])
            {
				system.debug('cominginside1@::');                
                //if(!objectsForAllGeoSharing.contains(objectName) || (objectsForAllGeoSharing.contains(objectName) && cpMdtMap.containsKey(pgm.Core_MDF_Channel_Program__r.Name) && cpMdtMap.get(pgm.Core_MDF_Channel_Program__r.Name).Geo_Based_Sharing_Required__c)){
                    if(pgm.Core_MDF_Region_cd__c == 'WW'){
                        system.debug('cominginside2@::');   
                        if(pgm.Core_MDF_BudgetType_nm__c == NULL || String.isEmpty(pgm.Core_MDF_BudgetType_nm__c)){
                            system.debug('cominginside3@::');   
                            String accIdProgPGMWWKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__r.Name;
                            accProgWWGrpMap.put(accIdProgPGMWWKey,pgm.Core_MDF_Group_Id__c);                        
                        }else{
                            system.debug('cominginside4@::');   
                            //WW budget type
                            String accIdProgBudTypeWWPGMKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__r.Name + pgm.Core_MDF_BudgetType_nm__c;
                            accProgWWBudgetTypeGrpMap.put(accIdProgBudTypeWWPGMKey,pgm.Core_MDF_Group_Id__c);
                            if(objectsForAllBudTypeSharing.contains(objectName)){
                                system.debug('cominginside5@::');   
                                String accIdProgPGMKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__r.Name;
                                if(accProgGrpListMap.containsKey(accIdProgPGMKey)){
                                    accProgGrpListMap.get(accIdProgPGMKey).add(pgm.Core_MDF_Group_Id__c);
                                }else{
                                    accProgGrpListMap.put(accIdProgPGMKey, new Set<Id>{pgm.Core_MDF_Group_Id__c});
                                }
                            }
                        }
                    }else{ //for the 4 Non WW Geos
                        system.debug('cominginside6@::');   
                        if(pgm.Core_MDF_Sub_Region_cd__c == NULL || String.isEmpty(pgm.Core_MDF_Sub_Region_cd__c)){
                            system.debug('cominginside7@::');   
                            if(pgm.Core_MDF_BudgetType_nm__c == NULL || String.isEmpty(pgm.Core_MDF_BudgetType_nm__c)){
                                system.debug('cominginside8@::');
                                String accIdProgGeoPGMKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__r.Name + pgm.Core_MDF_Region_cd__c;
                                accProgGeoGrpMap.put(accIdProgGeoPGMKey,pgm.Core_MDF_Group_Id__c);
                            }
                            else{
                                system.debug('cominginside9@::');
                                String accIdProgGeoBudTypePGMKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__r.Name + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_BudgetType_nm__c;
                                accProgGeoBudgetTypeGrpMap.put(accIdProgGeoBudTypePGMKey,pgm.Core_MDF_Group_Id__c);
                                if(objectsForAllBudTypeSharing.contains(objectName)){
                                    system.debug('cominginside10@::');
                                    String accIdProgGeoPGMKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__r.Name + pgm.Core_MDF_Region_cd__c;
                                    if(accProgGeoGrpSetMap.containsKey(accIdProgGeoPGMKey)){
                                        accProgGeoGrpSetMap.get(accIdProgGeoPGMKey).add(pgm.Core_MDF_Group_Id__c);
                                    }else{
                                        accProgGeoGrpSetMap.put(accIdProgGeoPGMKey, new Set<Id>{pgm.Core_MDF_Group_Id__c});
                                    }
                                }
                            }                            
                        }else{
                            system.debug('cominginside11@::');
                            if(pgm.Core_MDF_BudgetType_nm__c == NULL || String.isEmpty(pgm.Core_MDF_BudgetType_nm__c)){ 
                                system.debug('cominginside12@::');
                                String accIdProgGeoSubGeoPGMKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__r.Name + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c;
                                accProgGeoSubGeoGrpMap.put(accIdProgGeoSubGeoPGMKey,pgm.Core_MDF_Group_Id__c);
                            }else {   
                                system.debug('cominginside13@::');
                                String accIdProgGeoSubGeoBudTypePGMKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__r.Name + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c+pgm.Core_MDF_BudgetType_nm__c;
                                accProgGeoSubGeoBudgetTypeGrpMap.put(accIdProgGeoSubGeoBudTypePGMKey,pgm.Core_MDF_Group_Id__c);
                                if(objectsForAllBudTypeSharing.contains(objectName)){
                                    system.debug('cominginside14@::');
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
                //}
            }
            geoBasedSharingReq = FALSE;
        }
        system.debug('accProgWWGrpMap@::'+accProgWWGrpMap);//{001g000002gi6vfAAAClient Co-Marketing Fund=00Gg0000006fckpEAA, 001g000002gi6vfAAAClient Co-Marketing Fund Boost=00Gg0000006fclGEAQ, 001g000002gi6vfAAAData Center Co-Marketing Fund=00Gg0000006fckwEAA, 001g000002gi6vfAAAService Provider Co-Marketing Fund=00Gg0000006fclVEAQ}
        system.debug('accProgWWBudgetTypeGrpMap@::'+accProgWWBudgetTypeGrpMap);
        system.debug('accProgGrpListMap@::'+accProgGrpListMap);
        system.debug('accProgGeoGrpMap@::'+accProgGeoGrpMap);//{001g000002gi6vfAAAClient Co-Marketing Fund BoostAPJ=00Gg0000006fclBEAQ, 001g000002gi6vfAAAClient Co-Marketing FundAPJ=00Gg0000006fckmEAA, 001g000002gi6vfAAAData Center Co-Marketing FundAPJ=00Gg0000006fcl1EAA, 001g000002gi6vfAAAService Provider Co-Marketing FundAPJ=00Gg0000006fclLEAQ}
        system.debug('accProgGeoBudgetTypeGrpMap@::'+accProgGeoBudgetTypeGrpMap);
        system.debug('accProgGeoGrpSetMap@::'+accProgGeoGrpSetMap);//{001g000002gi6vfAAAClient Co-Marketing Fund BoostAPJ={00Gg0000006fclBEAQ}, 001g000002gi6vfAAAClient Co-Marketing FundAPJ={00Gg0000006fckmEAA}, 001g000002gi6vfAAAData Center Co-Marketing FundAPJ={00Gg0000006fcl1EAA}, 001g000002gi6vfAAAService Provider Co-Marketing FundAPJ={00Gg0000006fclLEAQ}}
        system.debug('accProgGeoSubGeoGrpMap@::'+accProgGeoSubGeoGrpMap);
        system.debug('accProgGeoSubGeoBudgetTypeGrpMap@::'+accProgGeoSubGeoBudgetTypeGrpMap);
        system.debug('accProgSubGeoGrpSetMap@::'+accProgSubGeoGrpSetMap);
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
            system.debug('accIdProgBudTypeRecKey@::'+accIdProgBudTypeRecKey); //001g000002gi6vfAAAClient Co-Marketing Fundnull, 001g000002gi6vfAAAService Provider Co-Marketing Fundnull, 001g000002gi6vfAAAClient Co-Marketing Fund Boostnull, 001g000002gi6vfAAAData Center Co-Marketing Fundnull
            system.debug('accIdProgRecKey@::'+accIdProgRecKey);//001g000002gi6vfAAAClient Co-Marketing Fund, 001g000002gi6vfAAAData Center Co-Marketing Fund, 001g000002gi6vfAAAService Provider Co-Marketing Fund, 001g000002gi6vfAAAClient Co-Marketing Fund Boost
            system.debug('accIdProgGeoSubGeoBudTypeRecKey@::'+accIdProgGeoSubGeoBudTypeRecKey);// 001g000002gi6vfAAAClient Co-Marketing FundAPJSAnull, 001g000002gi6vfAAAData Center Co-Marketing FundAPJSAnull, 001g000002gi6vfAAAService Provider Co-Marketing FundAPJSAnull, 001g000002gi6vfAAAClient Co-Marketing Fund BoostAPJSAnull
            system.debug('accIdProgGeoSubGeoRecKey@::'+accIdProgGeoSubGeoRecKey);//001g000002gi6vfAAAClient Co-Marketing FundAPJSA, 001g000002gi6vfAAAData Center Co-Marketing FundAPJSA, 001g000002gi6vfAAAService Provider Co-Marketing FundAPJSA, 001g000002gi6vfAAAClient Co-Marketing Fund BoostAPJSA
            system.debug('accIdProgGeoBudTyperecKey@::'+accIdProgGeoBudTyperecKey);// 001g000002gi6vfAAAClient Co-Marketing Fund BoostAPJnull, 001g000002gi6vfAAAClient Co-Marketing FundAPJnull, 001g000002gi6vfAAAData Center Co-Marketing FundAPJnull, 001g000002gi6vfAAAService Provider Co-Marketing FundAPJnull
            system.debug('accIdProgGeoRecKey@::'+accIdProgGeoRecKey);// 001g000002gi6vfAAAClient Co-Marketing FundAPJ, 001g000002gi6vfAAAData Center Co-Marketing FundAPJ, 001g000002gi6vfAAAService Provider Co-Marketing FundAPJ, 001g000002gi6vfAAAClient Co-Marketing Fund BoostAPJ
            if(objectsForAllGeoSharing.contains(objectName) && cpMdtMap.containsKey(record.program) && !cpMdtMap.get(record.program).Geo_Based_Sharing_Required__c && !hostRegionSharingReqProg.contains(record.program)){
                system.debug('cominginside15@::');
                if(record.budgetType !=null){
                    system.debug('cominginside16@::');
                    if(accProgBudgetTypeGrpListMap.containsKey(accIdProgBudTypeRecKey) && accProgBudgetTypeGrpListMap.get(accIdProgBudTypeRecKey) != NULL){
                        system.debug('cominginside17@::');
                        grpSet.addAll(accProgBudgetTypeGrpListMap.get(accIdProgBudTypeRecKey));
                    }
                }
                if(accProgGrpListMap.containsKey(accIdProgRecKey) && accProgGrpListMap.get(accIdProgRecKey) != NULL){
                    system.debug('cominginside18@::');
                    grpSet.addAll(accProgGrpListMap.get(accIdProgRecKey));
                }                
            }else{
                system.debug('cominginside19@::');
                if(record.subGeo !=null && !Core_MDF_CustomLabelConfig.getTextList('Core_MDF_PGMSubGeoSharingNotReqProg').contains(record.program) && cpMdtMap.containsKey(record.program) && subGeoSharingReqProgSet.contains(cpMdtMap.get(record.program).Core_MDF_Technical_Program_Name__c)){
                    system.debug('cominginside20@::');
                    if(record.budgetType !=null){
                        system.debug('cominginside21@::');
                        if(accProgGeoSubGeoBudgetTypeGrpMap.containsKey(accIdProgGeoSubGeoBudTypeRecKey) && accProgGeoSubGeoBudgetTypeGrpMap.get(accIdProgGeoSubGeoBudTypeRecKey) != NULL){
                            system.debug('cominginside22@::');
                            grpSet.add(accProgGeoSubGeoBudgetTypeGrpMap.get(accIdProgGeoSubGeoBudTypeRecKey));
                        }                        
                    }
                    if(accProgGeoSubGeoGrpMap.containsKey(accIdProgGeoSubGeoRecKey) && accProgGeoSubGeoGrpMap.get(accIdProgGeoSubGeoRecKey) != NULL){
                        system.debug('cominginside23@::');
                        grpSet.add(accProgGeoSubGeoGrpMap.get(accIdProgGeoSubGeoRecKey));
                    }
                    if(objectsForAllBudTypeSharing.contains(objectName) && accProgSubGeoGrpSetMap.containsKey(accIdProgGeoSubGeoRecKey) && accProgSubGeoGrpSetMap.get(accIdProgGeoSubGeoRecKey) != NULL){
                        system.debug('cominginside24@::');
                        grpSet.addAll(accProgSubGeoGrpSetMap.get(accIdProgGeoSubGeoRecKey));
                    }                  
                }
                if(record.budgetType !=null){
                    system.debug('cominginside25@::');
                    if(accProgWWBudgetTypeGrpMap.containsKey(accIdProgBudTypeRecKey) && accProgWWBudgetTypeGrpMap.get(accIdProgBudTypeRecKey) != NULL){
                        system.debug('cominginside26@::');
                        grpSet.add(accProgWWBudgetTypeGrpMap.get(accIdProgBudTypeRecKey));
                    }
                    if(accProgGeoBudgetTypeGrpMap.containsKey(accIdProgGeoBudTyperecKey) && accProgGeoBudgetTypeGrpMap.get(accIdProgGeoBudTyperecKey) != NULL){
                        system.debug('cominginside27@::');
                        grpSet.add(accProgGeoBudgetTypeGrpMap.get(accIdProgGeoBudTyperecKey));
                    }
                }
                if(accProgWWGrpMap.containsKey(accIdProgRecKey) && accProgWWGrpMap.get(accIdProgRecKey) != NULL){
                    system.debug('cominginside28@::');
                    grpSet.add(accProgWWGrpMap.get(accIdProgRecKey));
                }
                if(accProgGeoGrpMap.containsKey(accIdProgGeoRecKey) && accProgGeoGrpMap.get(accIdProgGeoRecKey) != NULL){
                    system.debug('cominginside29@::');
                    grpSet.add(accProgGeoGrpMap.get(accIdProgGeoRecKey));
                }
                if(objectsForAllBudTypeSharing.contains(objectName) && accProgGrpListMap.containsKey(accIdProgRecKey) && accProgGrpListMap.get(accIdProgRecKey) != NULL){
                    system.debug('cominginside30@::');
                    grpSet.addAll(accProgGrpListMap.get(accIdProgRecKey));
                }
                if(objectsForAllBudTypeSharing.contains(objectName) && accProgGeoGrpSetMap.containsKey(accIdProgGeoRecKey) && accProgGeoGrpSetMap.get(accIdProgGeoRecKey) != NULL){
                    system.debug('cominginside31@::');
                    grpSet.addAll(accProgGeoGrpSetMap.get(accIdProgGeoRecKey));
                }                             
            }
            system.debug('grpSet@::'+grpSet);
            grpLst.addAll(grpSet);
            system.debug('grpLst@::'+grpLst);
            //objectIdUserGroupIdListMap.put(record.recordId,grpLst);
            //System.debug('Debug 5->'+objectIdUserGroupIdListMap);
            if(objectIdUserGroupIdListMap.containsKey(record.recordId)){
                objectIdUserGroupIdListMap.get(record.recordId).addAll(grpLst);
            }else{
                objectIdUserGroupIdListMap.put(record.recordId, grpLst);
            }
        }
        System.debug('objectIdUserGroupIdListMap->'+objectIdUserGroupIdListMap);        
        if(objectIdUserGroupIdListMap != NULL && objectIdUserGroupIdListMap.size() > 0){
            //return Core_MDF_GenericShareRecordActionClass.createShareRecordList(objectName, objectIdUserGroupIdListMap);
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass(objectName, objectIdUserGroupIdListMap, 'Edit');
            return Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
        }
        return null;
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