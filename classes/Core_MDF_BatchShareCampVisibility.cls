/****************************************************************************************************************************************
* Class Name  : Core_MDF_BatchShareCampVisibility 
* Version     : 1.0 
* Created Date: 08-08-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Raj D        8/8/2018                    Batch class to periodically share Campaign records based on external visibility date
* Accenture - Shridhar K        2/08/2019                   Co-marketing recordType check is modified to handle new recordType dynamically 
*****************************************************************************************************************************************/

public class Core_MDF_BatchShareCampVisibility implements Database.Batchable<sObject>
{    
    
    private final string queryString;
    
    //Below variable is added by Shridhar to fetch Co-Marketing campaign
    //This varibale is refered class "Core_MDF_BatchSharecmpSchedule" to genearate SOQL query string
    public List<String> recTypeDeveloperName = Label.Core_MDF_CCP_RecordType_API_Name.split(',');    
    
    // Batch constructor
    public Core_MDF_BatchShareCampVisibility (String inputStrquery) {
        
        this.queryString = inputStrquery;       
        
    }
    
    // Batch start method
    public Database.QueryLocator start(Database.BatchableContext bc) {        
        
        return Database.getQueryLocator(queryString);
        
    }
    
    // Batch execute method
    public void execute(Database.BatchableContext bc, List<Campaign> scope) {        
        Map<Id,List<Id>> objectIdUserGroupIdListMapToShare = new Map<Id,List<Id>> ();
        Map<Id,List<Id>> actPartnerGroupIdsToShare = new Map<Id,List<Id>>();
        Set<Id> accId = new Set<Id>();
        Map<Id,Id> accIdWithParentId = new Map<Id,Id>();
          
        Set<Id> programSetId = new Set<Id>();
        List<Id> programIdList = new List<Id>();
    List<Id> eefCmpId = new List<Id>();
        Map<Id, List<Core_MDF_Camp_to_ActPartner__c>> campIdToActPartMap = new Map<Id, List<Core_MDF_Camp_to_ActPartner__c>>();
            // Identifying accounts from campaigns
            for (Campaign cmp : scope){            
                accId.add(cmp.Core_MDF_Account__c);
        programSetId.add(cmp.Core_MDF_Channel_Program__c);
        if(cmp.Core_MDF_Program__c == Label.Core_MDF_EEF_Program_Name){
                    accId.addAll((List<Id>)cmp.Core_MDF_Partner_Mapping_Txt__c.split(';'));
                    eefCmpId.add(cmp.Id);
                }
            }
        programIdList.addAll(programSetId);
        // Map of virtual account and parent account Ids(Corp accounts)
        for(Account acc: [SELECT Id, parentId, Core_MDF_Parent_Fund_Account__c FROM Account WHERE Id IN : accId LIMIT 50000]){
            if(acc.Core_MDF_Parent_Fund_Account__c != null){
                accIdWithParentId.put(acc.Id, acc.Core_MDF_Parent_Fund_Account__c);
            }
        }
        if(eefCmpId != NULL && eefCmpId.size() > 0){
            for(Core_MDF_Camp_to_ActPartner__c campToActPartner : [Select id,Core_MDF_Activating_Partner_Account_id__c, Core_MDF_PrimPartner_Ultimate_Acc_Id__c,Core_MDF_ActPartner_Ultimate_Acc_Id__c,Core_MDF_Channel_Program__c,Core_MDF_Campaign_Id__c, 
                                                                   Core_MDF_Campaign_Id__r.Core_MDF_Region_cd__c,Core_MDF_Campaign_Id__r.Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_Campaign_Id__r.Core_MDF_External_Visibility_Date__c,Core_MDF_Active_Ind__c 
                                                                   from Core_MDF_Camp_to_ActPartner__c where Core_MDF_Campaign_Id__c in:eefCmpId])
            {                
                if(campIdToActPartMap.containsKey(campToActPartner.Core_MDF_Campaign_Id__c)){
                    campIdToActPartMap.get(campToActPartner.Core_MDF_Campaign_Id__c).add(campToActPartner);
                }else{
                    campIdToActPartMap.put(campToActPartner.Core_MDF_Campaign_Id__c, new List<Core_MDF_Camp_to_ActPartner__c>{campToActPartner});
                }
            }            
        }
        // Listing Group mapping with corporate accounts         
        /*List <Core_MDF_Partner_Group_Mapping__c> pgMappingList = [SELECT Id, Name, Core_MDF_Account__c, Core_MDF_Group_Name__c,
                                                                  Core_MDF_Type_of_Access__c,Core_MDF_Group_Id__c,
                                                                  Core_MDF_Works_For__c, Core_MDF_Channel_Program__c 
                                                                  FROM Core_MDF_Partner_Group_Mapping__c WHERE Core_MDF_Account__c IN :accIdWithParentId.Values()
                                                                  AND Core_MDF_Type_of_Access__c = 'External' and Core_MDF_Inactive_Ind__c = false LIMIT 50000];*/
        Core_MDF_PGM_Utility.pgmKeyGroupIdWrapper pgmKeyGrpIdWrapper = new Core_MDF_PGM_Utility.pgmKeyGroupIdWrapper();
        pgmKeyGrpIdWrapper = Core_MDF_PGM_Utility.getAccPGMKeyGrpIdMap(accIdWithParentId.Values(),programIdList,'EXTERNAL');
        Map<String,Id> extPGMAccKeyGroupIdMap = pgmKeyGrpIdWrapper.extPGMKeyGroupIdMap;
            
        for(Campaign cmp : scope) {     
            
            List<Id> userorGroupIdToShare = new List<Id>();
            // Getting list of group id's to be shared with campaign
            /*for(Core_MDF_Partner_Group_Mapping__c pgShare : pgMappingList){                
                
                if(cmp.Core_MDF_Account__c != NULL &&
                    accIdWithParentId.get(cmp.Core_MDF_Account__c) == pgShare.Core_MDF_Account__c &&
                    cmp.Core_MDF_Channel_Program__c == pgShare.Core_MDF_Channel_Program__c &&
                    pgShare.Core_MDF_Group_Id__c != NULL){
                    //Channel program in the above condition is added by Shridhar   
                    userorGroupIdToShare.add(pgShare.Core_MDF_Group_Id__c);                    
                }            
            }*/
        if(accIdWithParentId.containsKey(cmp.Core_MDF_Account__c)){
              String campAccProgrmKey = String.valueOf(accIdWithParentId.get(cmp.Core_MDF_Account__c))+String.valueOf(cmp.Core_MDF_Channel_Program__c);
                if(extPGMAccKeyGroupIdMap.containsKey(campAccProgrmKey)){
                    userorGroupIdToShare.add(extPGMAccKeyGroupIdMap.get(campAccProgrmKey)); 
                }
            }
            if(cmp.Core_MDF_Program__c == Label.Core_MDF_EEF_Program_Name && campIdToActPartMap != NULL && campIdToActPartMap.containsKey(cmp.Id)){
                for(Core_MDF_Camp_to_ActPartner__c actPart : campIdToActPartMap.get(cmp.Id)){
                    String actPartnerUltimateAccProgramKey = String.valueOf(actPart.Core_MDF_ActPartner_Ultimate_Acc_Id__c)+String.valueOf(actPart.Core_MDF_Channel_Program__c);
                    String primPartnerUntimateAccProgramKey =  String.valueOf(actPart.Core_MDF_PrimPartner_Ultimate_Acc_Id__c)+String.valueOf(actPart.Core_MDF_Channel_Program__c);
                    if(extPGMAccKeyGroupIdMap.containsKey(actPartnerUltimateAccProgramKey)){
                        userorGroupIdToShare.add(extPGMAccKeyGroupIdMap.get(actPartnerUltimateAccProgramKey)); 
                        if(actPartnerGroupIdsToShare.containsKey(actPart.Id)){
                            actPartnerGroupIdsToShare.get(actPart.Id).add(extPGMAccKeyGroupIdMap.get(actPartnerUltimateAccProgramKey));
                        }else{
                            actPartnerGroupIdsToShare.put(actPart.Id, new List<Id>{extPGMAccKeyGroupIdMap.get(actPartnerUltimateAccProgramKey)});
                        }
                    }
                    if(extPGMAccKeyGroupIdMap.containsKey(primPartnerUntimateAccProgramKey)){ 
                        if(actPartnerGroupIdsToShare.containsKey(actPart.Id)){
                            actPartnerGroupIdsToShare.get(actPart.Id).add(extPGMAccKeyGroupIdMap.get(primPartnerUntimateAccProgramKey));
                        }else{
                            actPartnerGroupIdsToShare.put(actPart.Id, new List<Id>{extPGMAccKeyGroupIdMap.get(primPartnerUntimateAccProgramKey)});
                        }
                    }
                }      
            }    
            // Preparing map of campaign Id and List of Group Id's to be shared 
            if (userorGroupIdToShare.Size()>0){                    
                objectIdUserGroupIdListMapToShare.Put(cmp.Id, userorGroupIdToShare);
                
            }
        }

        // Call Generic share method class using Map(objectIdUserGroupIdListMapToShare) for sharing Campaign records with 
        // External Users from Partner Group Mapping
        if(!objectIdUserGroupIdListMapToShare.isEmpty()){
            //Core_MDF_GenericShareRecordActionClass.createShareRecordList('Campaign', objectIdUserGroupIdListMapToShare); 
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Campaign', objectIdUserGroupIdListMapToShare, 'Read');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
        
        }
    if(!actPartnerGroupIdsToShare.isEmpty()){
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Camp_to_ActPartner__c', actPartnerGroupIdsToShare, 'Read');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
        }
        /*Map<Id,List<Id>> categoryWiseShareMap = new Map<Id,List<Id>>();
        Map<Id,List<Id>> regionWiseShareMap = new Map<Id,List<Id>>();
        
        for(Core_MDF_Regionwise_Campaign_Budget__c rWise : [Select Id, Core_MDF_Campaign__c FROM Core_MDF_Regionwise_Campaign_Budget__c WHERE 
                                                            Core_MDF_Campaign__c IN:objectIdUserGroupIdListMapToShare.Keyset()]){
                 regionWiseShareMap.put(rWise.Id, objectIdUserGroupIdListMapToShare.get(rWise.Core_MDF_Campaign__c));                                          
        }
        
        for(Core_MDF_Categorywise_Campaign_Budget__c cWise : [Select Id, Core_MDF_Campaign__c FROM Core_MDF_Categorywise_Campaign_Budget__c WHERE 
                                                            Core_MDF_Campaign__c IN:objectIdUserGroupIdListMapToShare.Keyset()]){
                 categoryWiseShareMap.put(cWise.Id, objectIdUserGroupIdListMapToShare.get(cWise.Core_MDF_Campaign__c));                                          
        }
        
        //Null Check added by Shridhar
        if(regionWiseShareMap.size() > 0){
            //Core_MDF_GenericShareRecordActionClass.createShareRecordList('Core_MDF_Regionwise_Campaign_Budget__c',regionWiseShareMap);
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Regionwise_Campaign_Budget__c',regionWiseShareMap, 'Edit');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);            
        }
        
        //Null Check added by Shridhar
        if(categoryWiseShareMap.size() > 0){
            //Core_MDF_GenericShareRecordActionClass.createShareRecordList('Core_MDF_Categorywise_Campaign_Budget__c',categoryWiseShareMap);
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Categorywise_Campaign_Budget__c',categoryWiseShareMap, 'Edit');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);            
        }*/                
    }
    
    // Batch finish method
    public void finish(Database.BatchableContext bc) {
        
    }
}