/****************************************************************************************************************************
Apex Class Name     : PRM_ACM_Utility 
Version             : 1.0
Created Date        : Dec 2018
Developer           : UTKARSH
****************************************************************************************************************************/
public without sharing class PRM_ACM_Utility 
{   
    public static  boolean firstRun = true;
    public static  boolean firstRunAfterInsert = true;
    public static  boolean firstRunBeforeInsert = true;
    public static  boolean firstRunBeforeUpdate = true;
    public static  boolean firstRunAfterUpdate = true;
    public static  boolean isOpidrecommendationexecuted = true;
    
    
    public static final String LOG_ENTRY_ORIGIN   = 'PRM_ACM_Utility';
    public static final String LOG_ENTRY_PROJECT  = 'IPA Registrations';
    public static final String LOG_ENTRY_SCOPE    = 'PRM_ACM_Utility';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    
    public static void duplicateRecordCheck(List<PRM_AccountChannelMembership__c > acmNewList, List<PRM_AccountChannelMembership__c > acmOldList)
    {   
        Set<String> channelPrograms = new Set<String>();
        Set<String> accountIds = new Set<String>();
        Set<String> idSet = new Set<String>();
        List<String> uniqstr = new List<String>();
        List<Id> idslist = new List<Id>();
        Map<String,Id> uniqueMap = new Map<String,Id>();
        Map<String,Id> uniqueUpdateMap = new Map<String,Id>();
        List<PRM_AccountChannelMembership__c> initialACMList = new List<PRM_AccountChannelMembership__c>();
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        try{
            //Fetching ACM field values
            for(PRM_AccountChannelMembership__c acm: acmNewList){
                accountIds.add(acm.PRM_Account_Id__c);   
                channelPrograms.add(acm.PRM_Channel_Program_Id__c);
                idSet.add(acm.Id);
            }
            if((accountIds != null && !accountIds.IsEmpty()) && (channelPrograms != null && !channelPrograms.IsEmpty()) && (idSet != null && !idSet.IsEmpty())){
                initialACMList = [Select Id,PRM_Partner_Role__c,PRM_Account_Id__c, PRM_Channel_Program_Id__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c in :accountIds and PRM_Channel_Program_Id__c in :channelPrograms AND Id IN :idSet];
            }
            System.debug('initialACMList-->'+initialACMList);
            //Throwing error message for mismatch ACM record.
            if(initialACMList != null && !initialACMList.IsEmpty()){
                for(PRM_AccountChannelMembership__c acm :initialACMList){
                    if((idSet != null && !idSet.IsEmpty()) && (accountIds != null && !accountIds.IsEmpty()) && (channelPrograms != null && !channelPrograms.IsEmpty())){
                        if(!idSet.contains(acm.Id) && accountIds.contains(acm.PRM_Account_Id__c) && channelPrograms.contains(acm.PRM_Channel_Program_Id__c)){
                            if(channelPrograms.contains(acm.PRM_Channel_Program_Id__c) ){acm.addError (System.Label.PRM_ACM_Error_Message);
                            }
                        }
                    }
                }
            }
        }catch(Exception ex){String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
            System.debug('##### Exception: ' + exceptionMessage);   
        }  
        
        if(acmNewList != null && !acmNewList.IsEmpty()){
            for(PRM_AccountChannelMembership__c acm: acmNewList){
                uniqstr.add(acm.PRM_Account_Channel_Program_Key__c);
                idsList.add(acm.id);
            }
            System.debug('uniqstr-->'+uniqstr);
            System.debug('idsList-->'+idsList);
        }
        //Throwing error message if CP, CPL and partner role combination already exists in an ACM record.
        acmList = [SELECT Id,PRM_Partner_Role__c, PRM_Account_Id__c, PRM_Account_Channel_Program_Key__c FROM PRM_AccountChannelMembership__c where PRM_Account_Channel_Program_Key__c IN: uniqstr];
        if(acmOldList == null){
            if(acmList != null && !acmList.IsEmpty()){
                for(PRM_AccountChannelMembership__c acm :acmList){uniqueMap.put(acm.PRM_Account_Channel_Program_Key__c, acm.Id);
                }
                System.debug('uniqueMap-->'+uniqueMap);
            }
            if(acmNewList != null && !acmNewList.IsEmpty()){
                for(PRM_AccountChannelMembership__c acm: acmNewList)
                {    
                    if(uniqueMap.containsKey(acm.PRM_Account_Channel_Program_Key__c)){acm.addError(System.Label.PRM_ACM_Error_Message);
                    }            
                }
            }
        }else{
            if(acmList != null && !acmList.IsEmpty()){
                for(PRM_AccountChannelMembership__c acm :acmList){
                    if((uniqstr != null && !uniqstr.IsEmpty()) && (idsList != null && !idsList.IsEmpty())){
                        if((!idsList.contains(acm.Id)) && (uniqstr.contains(acm.PRM_Account_Channel_Program_Key__c))){uniqueUpdateMap.put(acm.PRM_Account_Channel_Program_Key__c,acm.Id);
                        }
                    }
                    
                }
            }
            if(acmNewList != null && !acmNewList.IsEmpty()){
                for(PRM_AccountChannelMembership__c acm: acmNewList)
                {    
                    if(uniqueUpdateMap.containsKey(acm.PRM_Account_Channel_Program_Key__c)){acm.addError(System.Label.PRM_ACM_Error_Message);
                    }            
                }
            }
        } 
    }

    public static void UpsertOPIDACM(List<PRM_AccountChannelMembership__c > acmNewList,Map<Id,PRM_AccountChannelMembership__c> oldMap)
    {
        boolean upsertOPIDACM = false;
        Set<String> acmPartnerRole = new Set<String>();
        Set<Id> parentACMAccId = new Set<Id>();
        Set<Id> acmAccId = new Set<Id>();
        Map<Id,PRM_AccountChannelMembership__c> parentACMMap = new Map<Id,PRM_AccountChannelMembership__c>();
        Map<Id,PRM_AccountChannelMembership__c> acmMap = new Map<Id,PRM_AccountChannelMembership__c>();
        Map<Id,Id> childParentMap = new Map<Id,Id>();
        PRM_AccountChannelMembership__c parentAcm = new PRM_AccountChannelMembership__c();
        PRM_AccountChannelMembership__c locationAcm = new PRM_AccountChannelMembership__c();
        List<PRM_AccountChannelMembership__c> upsertACMList = new List<PRM_AccountChannelMembership__c>();
        set<PRM_AccountChannelMembership__c> processACMID = new set<PRM_AccountChannelMembership__c>();
        List<Core_Account_Group_Member__c> initialPAGMRecordList = new List<Core_Account_Group_Member__c>();
        Map<string,integer> OPIDTierRollUpMap=new Map<string,integer>();
        set<Id> acrIds=new set<id>();
        
        for(PRM_AccountChannelMembership__c acm :acmNewList){
            PRM_AccountChannelMembership__c oldACM;
            if(oldMap != null && oldMap.size() > 0){
                oldACM = (PRM_AccountChannelMembership__c) oldMap.get(acm.Id);
                System.debug('ACM Record: '+oldACM);
            }
            if(((oldACM == null) || (oldACM != null && oldACM.PRM_Status_Nm__c != acm.PRM_Status_Nm__c)) && (acm.PRM_Status_Nm__c == System.Label.PRM_Status)){
                upsertOPIDACM=true;
                processACMID.add(acm);
                acrIds.add(acm.Id);
            }
        }
        System.debug('upsertOPIDACM-->'+upsertOPIDACM);
        
        if(upsertOPIDACM){
            ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name =:System.Label.PRM_Intel_Partner_Alliance LIMIT 1];
            if(processACMID != null && !processACMID.IsEmpty()){
                for(PRM_AccountChannelMembership__c acm :processACMID){ // Fetching location ACM details.
                    acmAccId.add(acm.PRM_Account_Id__c);
                    acmPartnerRole.add(acm.PRM_Partner_Role__c);
                    acmMap.put(acm.PRM_Account_Id__c,acm);
                }
            }
            System.debug('acmAccId-->'+acmAccId);
            System.debug('acmPartnerRole-->'+acmPartnerRole);
            if(acmAccId!=null && !acmAccId.IsEmpty()){ // Fetching parent account id.
                for(Core_Account_Group_Member__c agm :[Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Intel_Account_Id__c IN :acmAccId AND Core_Inactive_Ind__c = false]){ 
                    parentACMAccId.add(agm.Core_Partner_Account_Id__c);
                    childParentMap.put(agm.Core_Intel_Account_Id__c,agm.Core_Partner_Account_Id__c);
                }
            }
            System.debug('parentACMAccId-->'+parentACMAccId);
            System.debug('childParentMap-->'+childParentMap);
            set<string> partnerRoleSet=new set<string>();
            set<string> allACMAccid=new set<string>();
            
            for(Core_Account_Group_Member__c agm :[Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Partner_Account_Id__c IN :parentACMAccId AND Core_Inactive_Ind__c = false]){ 
                allACMAccid.add(agm.Core_Intel_Account_Id__c);
                childParentMap.put(agm.Core_Intel_Account_Id__c,agm.Core_Partner_Account_Id__c);
            }
            
            for(PRM_AccountChannelMembership__c acm :[Select Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Account_Id__r.RecordTypeId,PRM_Status_Nm__c From PRM_AccountChannelMembership__c Where PRM_Account_Id__c IN :allACMAccid AND PRM_Partner_Role__c IN :acmPartnerRole and PRM_Status_Nm__c = 'Approved']){
                if(partnerRoleSet.contains(acm.PRM_Partner_Role__c)){
                    if(childParentMap.containsKey(acm.PRM_Account_Id__c)){ //true
                        if(OPIDTierRollUpMap.containsKey(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c)){
                            OPIDTierRollUpMap.put(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c,OPIDTierRollUpMap.get(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c)+1);
                        }else{
                            OPIDTierRollUpMap.put(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c,1);
                        } 
                    }
                }
                else if(acm.PRM_Partner_Role__c != null){
                    partnerRoleSet.add(acm.PRM_Partner_Role__c);
                    OPIDTierRollUpMap.put(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c,1);
                }
            }
            if(Trigger.isBefore && Trigger.isInsert){
                System.debug('>>>running in before insert');
                for(PRM_AccountChannelMembership__c acm :acmNewList){
                    if(OPIDTierRollUpMap.containsKey(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c)){
                        OPIDTierRollUpMap.put(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c,OPIDTierRollUpMap.get(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c)+1);
                    }else{
                        OPIDTierRollUpMap.put(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c,1);
                    }
                }
            }
            

            if(parentACMAccId!=null && !parentACMAccId.IsEmpty()){ // Fecting OPID ACM details.
                for(PRM_AccountChannelMembership__c acm :[Select Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Account_Id__r.RecordTypeId,PRM_Status_Nm__c From PRM_AccountChannelMembership__c Where PRM_Account_Id__c IN :parentACMAccId AND PRM_Partner_Role__c IN :acmPartnerRole]){
                parentACMMap.put(acm.PRM_Account_Id__c, acm);
                    
                }
            }
            if(acmAccId != null && !acmAccId.IsEmpty()){ 
                for(Id accid :acmAccId){
                    parentAcm = parentACMMap.get(childParentMap.get(accid));
                    System.debug('parentAcm-->'+parentAcm);
                    locationAcm = acmMap.get(accid);
                    System.debug('locationAcm-->'+locationAcm);
                    system.debug('---OPIDTierRollUpMap '+OPIDTierRollUpMap);
                    if(parentAcm != null){ // Update back location account ACM.
                        if(Trigger.isAfter){
                            System.debug('---After ');
                            if(parentAcm.PRM_Channel_Program_Level_Id__c != locationAcm.PRM_Channel_Program_Level_Id__c){
                                if(OPIDTierRollUpMap!=null && OPIDTierRollUpMap.containskey(parentAcm.PRM_Account_Id__c+locationAcm.PRM_Partner_Role__c) && OPIDTierRollUpMap.get(parentAcm.PRM_Account_Id__c+locationAcm.PRM_Partner_Role__c)==1){
                                    parentAcm.PRM_Channel_Program_Level_Id__c = locationAcm.PRM_Channel_Program_Level_Id__c;
                                    parentAcm.PRM_Status_Nm__c = System.Label.PRM_Status;
                                    upsertACMList.add(parentAcm);
                                }
                            }
                            if(parentAcm.PRM_Status_Nm__c != System.Label.PRM_Status){
                                parentAcm.PRM_Status_Nm__c = System.Label.PRM_Status;
                                upsertACMList.add(parentAcm);
                            }
                        }
                        if(Trigger.isBefore){
                        System.debug('---Before ');
                        
                            if(parentAcm.PRM_Channel_Program_Level_Id__c != locationAcm.PRM_Channel_Program_Level_Id__c){
                                if((OPIDTierRollUpMap!=null && OPIDTierRollUpMap.containskey(parentAcm.PRM_Account_Id__c+locationAcm.PRM_Partner_Role__c) && 
								  (OPIDTierRollUpMap.get(parentAcm.PRM_Account_Id__c+locationAcm.PRM_Partner_Role__c)==1)) || 
									OPIDTierRollUpMap == null || OPIDTierRollUpMap.isEmpty()){
                                    parentAcm.PRM_Channel_Program_Level_Id__c = locationAcm.PRM_Channel_Program_Level_Id__c;
                                    parentAcm.PRM_Status_Nm__c = System.Label.PRM_Status;
                                    upsertACMList.add(parentAcm);
                                }
                              
                                else {
                                    locationAcm.PRM_Channel_Program_Level_Id__c = parentAcm.PRM_Channel_Program_Level_Id__c;
                                }             
                            }
                                //upsertACMList.add(locationAcm);
                            if(parentAcm.PRM_Status_Nm__c != System.Label.PRM_Status){
                                parentAcm.PRM_Status_Nm__c = System.Label.PRM_Status;
                                upsertACMList.add(parentAcm);
                            }
                        }
                        system.debug('upsertACMList-->'+upsertACMList);
                        system.debug('---OPIDTierRollUpMap '+OPIDTierRollUpMap);
                        system.debug('---parentAcm '+parentAcm.PRM_Channel_Program_Level_Id__c+'--'+locationAcm.PRM_Channel_Program_Level_Id__c);
                                
                    }
                    else{ // insert ACM on OPID.
                        if(Trigger.isAfter){
                            PRM_AccountChannelMembership__c insertAcm = new PRM_AccountChannelMembership__c();
                            System.debug('childParentMap.get(accid)-->'+childParentMap.get(accid));
                            insertAcm.PRM_Account_Id__c = childParentMap.get(accid);
                            System.debug('insertAcm.PRM_Account_Id__c-->'+insertAcm.PRM_Account_Id__c);
                            insertAcm.PRM_Channel_Program_Id__c = cp.Id;
                            if(locationAcm != null){
                                insertAcm.PRM_Channel_Program_Level_Id__c = locationAcm.PRM_Channel_Program_Level_Id__c;
                                insertAcm.PRM_Partner_Role__c = locationAcm.PRM_Partner_Role__c;
                            }
                            insertAcm.PRM_Status_Nm__c = System.Label.PRM_Status;
                            if(!Test.isRunningTest() && insertAcm.PRM_Account_Id__c != null){upsertACMList.add(insertAcm);
                                System.debug('upsertACMList-->'+upsertACMList);
                            }
                        }
                    }
                }
            }
        }
        try{
            if(upsertACMList != null && !upsertACMList.IsEmpty())
            {
                //PRM_ACM_TriggerHandler.firstRun = true;
                upsert upsertACMList;
            }
        }catch(Exception e){Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',e);            
                            System.debug('Inside Catch =>'+e.getMessage());
                           }
    }
}