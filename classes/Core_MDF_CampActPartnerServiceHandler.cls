public without sharing class Core_MDF_CampActPartnerServiceHandler{
    @invocableMethod(label = 'share unshare CamptoActPartner')
    public static void shareUnshareCamptoActPartner(List<InitialInputs> processInput){
        List<id> campToActPartnerIds = new List<id>();
        List<Core_MDF_Camp_to_ActPartner__c> campToActPartnerList = new List<Core_MDF_Camp_to_ActPartner__c>();
        //List to store Partner Mapping share records to be deleted
        List<Id> partnerMappingToBeDeleted = new List<Id>();
        try{
            for(InitialInputs inputwrapper:processInput){
                if(inputwrapper.mode == 'delete'){
                    partnerMappingToBeDeleted.add(inputwrapper.campToActPartner.id);
                }
                else if(inputwrapper.mode == 'Share'){
                    campToActPartnerIds.add(inputwrapper.campToActPartner.id);
                    // campToActPartnerList.add(inputwrapper.campToActPartner.id);
                }
            }
            if(campToActPartnerIds!=null){
                campToActPartnerList = [Select id,Core_MDF_Activating_Partner_Account_id__c, Core_MDF_PrimPartner_Ultimate_Acc_Id__c,Core_MDF_ActPartner_Ultimate_Acc_Id__c,Core_MDF_Channel_Program__c,Core_MDF_Campaign_Id__c, 
                                        Core_MDF_Campaign_Id__r.Core_MDF_Region_cd__c,Core_MDF_Campaign_Id__r.Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_Campaign_Id__r.Core_MDF_External_Visibility_Date__c,Core_MDF_Active_Ind__c 
                                        from Core_MDF_Camp_to_ActPartner__c where id in:campToActPartnerIds];
                
                if(campToActPartnerList!=null){
                    shareCamToActPartner(campToActPartnerList);}
            }
            if(partnerMappingToBeDeleted!=null){
                unShareCampActPartner(partnerMappingToBeDeleted);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        
    }
    /***************************************************************************************************** 
Method Name    :       shareCamToActPartner
Description   :        share the mapping records to the required public groups
Added By      :        Accenture - AN - 03/28/2024
Modified By   :        Date:       Changes: 
******************************************************************************************************/
    public static void shareCamToActPartner(List<Core_MDF_Camp_to_ActPartner__c> campToActPartnerList){
        Map<id,id> pMappingtoPrimaryPartnerUltimateaccId = new Map<id,id>();
        Map<id,id> pMappingtoActivatingPartnerUltimateaccId= new Map<id,id>();
        List<id> ultimateAccIds = new List<id>();
        Map<Id,List<Id>> objectIdUserGroupIdListMapToShare = new Map<Id,List<Id>> ();
        //Map used to determine subgeo based internal group; key - AccId+ProgramId+Geo+SubGeo and Value - GroupId
        Map<String,Id> subgeoInternalMap = new Map<String,Id>();
        //Map used to determine geo based internal group; key - AccId+ProgramId+Geo and Value - GroupId
        Map<String,Id> geoInternalMap = new Map<String,Id>();
        Map<String,Id> subGeobudgetTypeMap = new Map<String,Id>();
        //Map used to determine budget type group; key- AccId+ProgramId+BudgetType and Value - GroupId
        Map<String,Id> GeobudgetTypeMap = new Map<String,Id>();
        //Map used to determine WW group; key - AccId+ProgramId and Value - GroupId
        Map<String,Id> wwInternalMap = new Map<String,Id>();
        Map<String,Id> wwInternalBudgetTypeMap = new Map<String,Id>();
        //Map used to determine external group; key - AccId+ProgramId and Value - GroupId
        Map<String,Id> externalMap = new Map<String,Id>();
        //Set<Id> grpSet = new Set<Id>();
        List<Core_MDF_Camp_to_ActPartner__Share> partnerMappingshareList = new List<Core_MDF_Camp_to_ActPartner__Share>();
        //RecordShare list to be shared to metadata groups
        List<Core_MDF_RecordGeoShare> recGeoShrLst = new List<Core_MDF_RecordGeoShare>();
        Map<String,Id> accPGMGroupIdMap = new Map<String,Id>();
        ChannelProgram eefCP = [Select id from ChannelProgram where Core_MDF_Technical_Program_Name__c ='Ecosystem Extension Fund'];
        List<Id> cpIdList = new List<Id>();
        cpIdList.add(eefCP.id);
        try{
            for(Core_MDF_Camp_to_ActPartner__c cmpAccPartner:campToActPartnerList){
                pMappingtoPrimaryPartnerUltimateaccId.put(cmpAccPartner.id,cmpAccPartner.Core_MDF_PrimPartner_Ultimate_Acc_Id__c);
                pMappingtoActivatingPartnerUltimateaccId.put(cmpAccPartner.id,cmpAccPartner.Core_MDF_ActPartner_Ultimate_Acc_Id__c);
                ultimateAccIds.add(cmpAccPartner.Core_MDF_PrimPartner_Ultimate_Acc_Id__c); 
                ultimateAccIds.add(cmpAccPartner.Core_MDF_ActPartner_Ultimate_Acc_Id__c);
            }
            for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Core_MDF_Group_Id__c,Id, Name, Core_MDF_Account__c, Core_MDF_Group_Name__c,
                                                         Core_MDF_Type_of_Access__c,Core_MDF_Works_For__c, Core_MDF_Channel_Program__c, Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c,Core_MDF_BudgetType_nm__c,Core_MDF_Channel_Program__r.Name
                                                         FROM Core_MDF_Partner_Group_Mapping__c 
                                                         WHERE 
                                                         Core_MDF_Inactive_Ind__c = false AND Core_MDF_Account__c IN :ultimateAccIds AND
                                                         Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c =: Label.Core_MDF_NonTranslateEEFRecordType ])
            {//replace hardcoded value
                if(pgm.Core_MDF_Type_of_Access__c == 'INTERNAL' && pgm.Core_MDF_BudgetType_nm__c == null){                                        
                    String accountIdProgramIdGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c;
                    geoInternalMap.put(accountIdProgramIdGeo, pgm.Core_MDF_Group_Id__c);     
                } 
                if(pgm.Core_MDF_Type_of_Access__c == 'INTERNAL' && pgm.Core_MDF_BudgetType_nm__c != null){
                    String accountIdProgramIdGeoBudgetType = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_BudgetType_nm__c;
                    GeobudgetTypeMap.put(accountIdProgramIdGeoBudgetType,pgm.Core_MDF_Group_Id__c);
                } 
                if(pgm.Core_MDF_Type_of_Access__c == 'INTERNAL' && pgm.Core_MDF_Region_cd__c == 'WW'){
                    if(pgm.Core_MDF_BudgetType_nm__c == null){
                        String accountIdProgramId = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c;
                        wwInternalMap.put(accountIdProgramId,pgm.Core_MDF_Group_Id__c);
                    }else{ // for WW with budget type
                        String accountIdProgramIdBudget = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_BudgetType_nm__c;
                        wwInternalBudgetTypeMap.put(accountIdProgramIdBudget,pgm.Core_MDF_Group_Id__c);
                    }
                } 
                if(pgm.Core_MDF_Type_of_Access__c == 'EXTERNAL'){
                    String accountIdProgramId = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c;
                    externalMap.put(accountIdProgramId,pgm.Core_MDF_Group_Id__c);
                }
            }
            //accPGMGroupIdMap = getAccPGMKeyGrpIdMap(ultimateAccIds,cpIdList);
            /*for(Core_MDF_Camp_to_ActPartner__c cmpAccPartner: campToActPartnerList){     
                Set<Id> grpSet = new Set<Id>(); 
                List<Id> userorGroupIdToShare = new List<Id>();
                List<String> geoLst = new List<String>();
                String primaryUltimateAccId = cmpAccPartner.Core_MDF_PrimPartner_Ultimate_Acc_Id__c;
                String actUltimateAccId = cmpAccPartner.Core_MDF_ActPartner_Ultimate_Acc_Id__c;
                String priPartnerUltimateAccCPKey = (string)primaryUltimateAccId+(string)cmpAccPartner.Core_MDF_Channel_Program__c;
                String actPatnerUltimateAccCPKey = (string)actUltimateAccId+(string)cmpAccPartner.Core_MDF_Channel_Program__c;
                //Ext Group
                if(accPGMGroupIdMap.containsKey(priPartnerUltimateAccCPKey) && cmpAccPartner.Core_MDF_Campaign_Id__r.Core_MDF_External_Visibility_Date__c <= system.today()){
                    grpSet.add(accPGMGroupIdMap.get(priPartnerUltimateAccCPKey));
                }
                if(accPGMGroupIdMap.containsKey(actPatnerUltimateAccCPKey) && cmpAccPartner.Core_MDF_Campaign_Id__r.Core_MDF_External_Visibility_Date__c <= system.today()){
                    grpSet.add(accPGMGroupIdMap.get(actPatnerUltimateAccCPKey));
                }
                geoLst = cmpAccPartner.Core_MDF_Campaign_Id__r.Core_MDF_Region_cd__c.Split(';');
                geoLst.add('WW');
                for(String geo:geoLst){
                    String primUltAccountIdProgramIdGeo = (String)primaryUltimateAccId + (String)cmpAccPartner.Core_MDF_Channel_Program__c +geo;
                    String actUltAccountIdProgramIdGeo = (String)actUltimateAccId + (String)cmpAccPartner.Core_MDF_Channel_Program__c +geo;
                    String primUltAccountIdProgramIdGeoBudgetType = (String)primaryUltimateAccId + (String)cmpAccPartner.Core_MDF_Channel_Program__c+geo+(String)cmpAccPartner.Core_MDF_Campaign_Id__r.Core_MDF_Opal_Budget_Type_Txt__c;
                    String actUltAccountIdProgramIdGeoBudgetType = (String)actUltimateAccId + (String)cmpAccPartner.Core_MDF_Channel_Program__c+geo+ (String)cmpAccPartner.Core_MDF_Campaign_Id__r.Core_MDF_Opal_Budget_Type_Txt__c;
                    //Geo Internal Group  (including WW)
                    if(accPGMGroupIdMap.containsKey(primUltAccountIdProgramIdGeo)){
                        grpSet.add(accPGMGroupIdMap.get(primUltAccountIdProgramIdGeo));
                    }
                    if(accPGMGroupIdMap.containsKey(actUltAccountIdProgramIdGeo)){
                        grpSet.add(accPGMGroupIdMap.get(actUltAccountIdProgramIdGeo));
                    }
                    //Geo Budget Type Internal Group (including WW)
                    if(accPGMGroupIdMap.containsKey(primUltAccountIdProgramIdGeoBudgetType)){
                        grpSet.add(accPGMGroupIdMap.get(primUltAccountIdProgramIdGeoBudgetType));
                    }
                    if(accPGMGroupIdMap.containsKey(actUltAccountIdProgramIdGeoBudgetType)){
                        grpSet.add(accPGMGroupIdMap.get(actUltAccountIdProgramIdGeoBudgetType));
                    }
                    //Metadata Groups
                    Core_MDF_RecordGeoShare recGeoShr = new Core_MDF_RecordGeoShare(cmpAccPartner.Id,geo,null,'Ecosystem Extension Fund',cmpAccPartner.Core_MDF_Campaign_Id__r.Core_MDF_Opal_Budget_Type_Txt__c);
                    recGeoShrLst.add(recGeoShr);
                }
                userorGroupIdToShare.addAll(grpSet);
                // Preparing map of Activating Partners Id and List of Group Id's to be shared 
                if (userorGroupIdToShare.Size()>0){                    
                    objectIdUserGroupIdListMapToShare.Put(cmpAccPartner.Id, userorGroupIdToShare);
                }
            }*/
            Core_MDF_PGM_Utility.pgmKeyGroupIdWrapper pgmKeyGrpIdWrapper = new Core_MDF_PGM_Utility.pgmKeyGroupIdWrapper();
            pgmKeyGrpIdWrapper = Core_MDF_PGM_Utility.getAccPGMKeyGrpIdMap(ultimateAccIds,cpIdList,null);
            Map<String,Id> intPGMAccKeyGroupIdMap = pgmKeyGrpIdWrapper.intPGMKeyGroupIdMap;
            Map<String,Id> extPGMAccKeyGroupIdMap = pgmKeyGrpIdWrapper.extPGMKeyGroupIdMap;
            for(Core_MDF_Camp_to_ActPartner__c cmpAccPartner: campToActPartnerList){     
                Set<Id> grpSet = new Set<Id>(); 
                List<Id> userorGroupIdToShare = new List<Id>();
                List<String> geoLst = new List<String>();
                String primaryUltimateAccId = cmpAccPartner.Core_MDF_PrimPartner_Ultimate_Acc_Id__c;
                String actUltimateAccId = cmpAccPartner.Core_MDF_ActPartner_Ultimate_Acc_Id__c;
                String priPartnerUltimateAccCPKey = (string)primaryUltimateAccId+(string)cmpAccPartner.Core_MDF_Channel_Program__c;
                String actPatnerUltimateAccCPKey = (string)actUltimateAccId+(string)cmpAccPartner.Core_MDF_Channel_Program__c;
                String primUltIdProgramIdBudgetType = (String)primaryUltimateAccId + (String)cmpAccPartner.Core_MDF_Channel_Program__c +  (String)cmpAccPartner.Core_MDF_Campaign_Id__r.Core_MDF_Opal_Budget_Type_Txt__c;
                String actUltIdProgramIdBudgetType = (String)actUltimateAccId + (String)cmpAccPartner.Core_MDF_Channel_Program__c +  (String)cmpAccPartner.Core_MDF_Campaign_Id__r.Core_MDF_Opal_Budget_Type_Txt__c;
                //Ext Group
                if(extPGMAccKeyGroupIdMap.containsKey(priPartnerUltimateAccCPKey) && cmpAccPartner.Core_MDF_Campaign_Id__r.Core_MDF_External_Visibility_Date__c <= system.today()){
                    grpSet.add(extPGMAccKeyGroupIdMap.get(priPartnerUltimateAccCPKey));
                }
                if(extPGMAccKeyGroupIdMap.containsKey(actPatnerUltimateAccCPKey) && cmpAccPartner.Core_MDF_Campaign_Id__r.Core_MDF_External_Visibility_Date__c <= system.today()){
                    grpSet.add(extPGMAccKeyGroupIdMap.get(actPatnerUltimateAccCPKey));
                }
                //WW Internal Group
                if(intPGMAccKeyGroupIdMap.containsKey(priPartnerUltimateAccCPKey)){
                    grpSet.add(intPGMAccKeyGroupIdMap.get(priPartnerUltimateAccCPKey));
                }
                if(intPGMAccKeyGroupIdMap.containsKey(actPatnerUltimateAccCPKey)){
                    grpSet.add(intPGMAccKeyGroupIdMap.get(actPatnerUltimateAccCPKey));
                }
                //WW Budget Type Internal Group 
                if(intPGMAccKeyGroupIdMap.containsKey(primUltIdProgramIdBudgetType)){
                    grpSet.add(intPGMAccKeyGroupIdMap.get(primUltIdProgramIdBudgetType));
                }
                if(intPGMAccKeyGroupIdMap.containsKey(actUltIdProgramIdBudgetType)){
                    grpSet.add(intPGMAccKeyGroupIdMap.get(actUltIdProgramIdBudgetType));
                }
                geoLst = cmpAccPartner.Core_MDF_Campaign_Id__r.Core_MDF_Region_cd__c.Split(';');
                for(String geo:geoLst){
                    String primUltAccountIdProgramIdGeo = (String)primaryUltimateAccId + (String)cmpAccPartner.Core_MDF_Channel_Program__c +geo;
                    String actUltAccountIdProgramIdGeo = (String)actUltimateAccId + (String)cmpAccPartner.Core_MDF_Channel_Program__c +geo;
                    String primUltAccountIdProgramIdGeoBudgetType = (String)primaryUltimateAccId + (String)cmpAccPartner.Core_MDF_Channel_Program__c+geo+(String)cmpAccPartner.Core_MDF_Campaign_Id__r.Core_MDF_Opal_Budget_Type_Txt__c;
                    String actUltAccountIdProgramIdGeoBudgetType = (String)actUltimateAccId + (String)cmpAccPartner.Core_MDF_Channel_Program__c+geo+ (String)cmpAccPartner.Core_MDF_Campaign_Id__r.Core_MDF_Opal_Budget_Type_Txt__c;
                    //Geo Internal Group  
                    if(intPGMAccKeyGroupIdMap.containsKey(primUltAccountIdProgramIdGeo)){
                        grpSet.add(intPGMAccKeyGroupIdMap.get(primUltAccountIdProgramIdGeo));
                    }
                    if(intPGMAccKeyGroupIdMap.containsKey(actUltAccountIdProgramIdGeo)){
                        grpSet.add(intPGMAccKeyGroupIdMap.get(actUltAccountIdProgramIdGeo));
                    }
                    //Geo Budget Type Internal Group
                    if(intPGMAccKeyGroupIdMap.containsKey(primUltAccountIdProgramIdGeoBudgetType)){
                        grpSet.add(intPGMAccKeyGroupIdMap.get(primUltAccountIdProgramIdGeoBudgetType));
                    }
                    if(intPGMAccKeyGroupIdMap.containsKey(actUltAccountIdProgramIdGeoBudgetType)){
                        grpSet.add(intPGMAccKeyGroupIdMap.get(actUltAccountIdProgramIdGeoBudgetType));
                    }
                    //Metadata Groups
                    Core_MDF_RecordGeoShare recGeoShr = new Core_MDF_RecordGeoShare(cmpAccPartner.Id,geo,null,'Ecosystem Extension Fund',cmpAccPartner.Core_MDF_Campaign_Id__r.Core_MDF_Opal_Budget_Type_Txt__c,'Read');
                    recGeoShrLst.add(recGeoShr);
                }
                userorGroupIdToShare.addAll(grpSet);
                // Preparing map of Activating Partners Id and List of Group Id's to be shared 
                if (userorGroupIdToShare.Size()>0){                    
                    objectIdUserGroupIdListMapToShare.Put(cmpAccPartner.Id, userorGroupIdToShare);
                }
            }
            //Internal and External PGM group sharing
            if(!objectIdUserGroupIdListMapToShare.isEmpty()){
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Camp_to_ActPartner__c', objectIdUserGroupIdListMapToShare, 'Read');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
            }
            //Metadata group sharing
            if(recGeoShrLst !=NULL && recGeoShrLst.size() > 0){
                Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('Core_MDF_Camp_to_ActPartner__c', recGeoShrLst);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    /***************************************************************************************************** 
Method Name    :       unShareCampActPartner
Description   :        To delete the share records
Added By      :        Accenture - AN - 03/28/2024
Modified By   :        Date:       Changes: 
******************************************************************************************************/
    public static void unShareCampActPartner(List<Id> partnerMappingToBeDeleted){
        List<Core_MDF_Camp_to_ActPartner__Share> partnerMappingshareList = new List<Core_MDF_Camp_to_ActPartner__Share>();
        try{
            if(partnerMappingToBeDeleted != NULL && partnerMappingToBeDeleted.size() > 0){
                for(Core_MDF_Camp_to_ActPartner__Share pMapShare : [SELECT Id, ParentId, UserOrGroupId
                                                                    FROM Core_MDF_Camp_to_ActPartner__Share WHERE ParentId IN : partnerMappingToBeDeleted AND 
                                                                    RowCause =: Schema.Core_MDF_Camp_to_ActPartner__Share.RowCause.Manual]){
                                                                        if(String.valueOf(pMapShare.UserOrGroupId).startsWith('00G')){
                                                                            partnerMappingshareList.add(pMapShare);
                                                                        }
                                                                    }
            }
            if(partnerMappingshareList != NULL && partnerMappingshareList.size() > 0){
                delete partnerMappingshareList;
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
   /***************************************************************************************************** 
Method Name    :       getAccPGMKeyGrpIdMap
Description   :        To retuen a map with corresponding with keys and group Ids
Added By      :        Accenture - AN - 03/28/2024
Modified By   :        Date:       Changes: 
******************************************************************************************************/
//AccessType
/*public static Map<String,Id> getAccPGMKeyGrpIdMap(List<Id> ultimateAccId,List<Id> programIdSet){
    //Map used to determine subgeo based internal group; key - AccId+ProgramId+Geo+SubGeo and Value - GroupId
    Map<String,Id> accPGMKeyGroupIDMap = new Map<String,Id>();
    if(programIdSet!=null){
        for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Core_MDF_Group_Id__c,Id, Name, Core_MDF_Account__c, Core_MDF_Group_Name__c,
                                                         Core_MDF_Type_of_Access__c,Core_MDF_Works_For__c, Core_MDF_Channel_Program__c, Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c,Core_MDF_BudgetType_nm__c/*Core_MDF_Budget_Type_nm__c,Core_MDF_Channel_Program__r.Name
                                                         FROM Core_MDF_Partner_Group_Mapping__c 
                                                         WHERE Core_MDF_Account__c IN : ultimateAccId AND
                                                         Core_MDF_Inactive_Ind__c = false AND
                                                         Core_MDF_Channel_Program__c IN : programIdSet]){
                                                    
                                                        if(pgm.Core_MDF_Type_of_Access__c == 'INTERNAL' && pgm.Core_MDF_BudgetType_nm__c == null){                                        
                                                                 if(pgm.Core_MDF_Sub_Region_cd__c != NULL){
                                                                     String accountIdProgramIdSubGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c;
                                                                     accPGMKeyGroupIDMap.put(accountIdProgramIdSubGeo, pgm.Core_MDF_Group_Id__c); 
                                                                 }   
                                                                 else{
                                                                     String accountIdProgramIdGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c;
                                                                     accPGMKeyGroupIDMap.put(accountIdProgramIdGeo, pgm.Core_MDF_Group_Id__c);     
                                                                 }
                                                        } 
                                                        if(pgm.Core_MDF_Type_of_Access__c == 'INTERNAL' && pgm.Core_MDF_BudgetType_nm__c != null){
                                                            if(pgm.Core_MDF_Sub_Region_cd__c != NULL){
                                                                String accountIdProgramIdSubGeoBudgetType = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c + pgm.Core_MDF_BudgetType_nm__c;
                                                                accPGMKeyGroupIDMap.put(accountIdProgramIdSubGeoBudgetType,pgm.Core_MDF_Group_Id__c);
                                                            }
                                                            else{
                                                                String accountIdProgramIdGeoBudgetType = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_BudgetType_nm__c;
                                                                accPGMKeyGroupIDMap.put(accountIdProgramIdGeoBudgetType,pgm.Core_MDF_Group_Id__c);
                                                                
                                                            }

                                                             } 
                                                             
                                                             if(pgm.Core_MDF_Type_of_Access__c == 'INTERNAL' && pgm.Core_MDF_Region_cd__c == 'WW'){
                                                                 if(pgm.Core_MDF_BudgetType_nm__c == null){
                                                                     String accountIdProgramId = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c+'WW';
                                                                     accPGMKeyGroupIDMap.put(accountIdProgramId,pgm.Core_MDF_Group_Id__c);
                                                                 }else{ // for WW with budget type
                                                                     String accountIdProgramIdBudget = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c +'WW'+pgm.Core_MDF_BudgetType_nm__c;
                                                                     accPGMKeyGroupIDMap.put(accountIdProgramIdBudget,pgm.Core_MDF_Group_Id__c);
                                                                 }
                                                             }
                                                             
                                                             if(pgm.Core_MDF_Type_of_Access__c == 'EXTERNAL'){
                                                                 String accountIdProgramId = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c;
                                                                 accPGMKeyGroupIDMap.put(accountIdProgramId,pgm.Core_MDF_Group_Id__c);
                                                             }
                                                        }
                                                    }
    return accPGMKeyGroupIDMap;
        
}*/
    
    /***************************************************************************************************** 
Class Name    :        initialInputs
Description   :        contains all the invocable variables
Added By      :        Accenture - AN - 03/28/2024
Modified By   :        Date:       Changes: 
******************************************************************************************************/
    public class InitialInputs{
        @InvocableVariable(label = 'campToActPartner')
        public Core_MDF_Camp_to_ActPartner__c campToActPartner;
        @InvocableVariable(label = 'mode')
        public String mode;
    }
}