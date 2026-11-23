/****************************************************************************************************************************
Apex Class Name     : PRM_ACM_Utility 
Version             : 1.0
Created Date        : Dec 2018
Developer           : UTKARSH
****************************************************************************************************************************/
public without sharing class PRM_ACM_Utility 
{   
    public static  boolean firstRun = true;
    public static  boolean secondRun = true;
    public static  boolean firstRunAfterInsert = true;
    public static  boolean firstRunBeforeInsert = true;
    public static  boolean firstRunBeforeUpdate = true;
    public static  boolean firstRunAfterUpdate = true;
    public static  boolean isOpidrecommendationexecuted = true;
    //public static boolean ipaRefresh = Boolean.valueOf(label.PRM_IPARefresh);  //IPA2.0-TWC727-2861 // IPA Switch Removal
    
    public static final String LOG_ENTRY_ORIGIN   = 'PRM_ACM_Utility';
    public static final String LOG_ENTRY_PROJECT  = 'IPA Registrations';
    public static final String LOG_ENTRY_SCOPE    = 'PRM_ACM_Utility';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    
    //checks if Pending membership records on ACM
    //Added by DINESH as part of US1040000
    /* Commenting for SOQL Reduction 201 - TWC729-4593
public static void checkPendingMembership(Map<Id,PRM_AccountChannelMembership__c > acmNewMap){
// get acm Id
try{        
for( PRM_IPA_Membership__c memRecord:[select id,PRM_Account_Channel_Membership__c from PRM_IPA_Membership__c where PRM_Account_Channel_Membership__c in : acmNewMap.keySet() and PRM_Status__c ='Pending']){
if(acmNewMap.get(memRecord.PRM_Account_Channel_Membership__c).PRM_Status_Nm__c!='Approved')
acmNewMap.get(memRecord.PRM_Account_Channel_Membership__c).addError(Label.PRM_ACM_Update_message);
}
}catch(Exception e){
Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',e);            
}
}*/
    //This method is used to restrict user from adding the duplicate Account Channel Membership record for the same account.
    public static void duplicateRecordCheck(List<PRM_AccountChannelMembership__c > acmNewList, List<PRM_AccountChannelMembership__c > acmOldList)
    {   
        //Set<String> channelPrograms = new Set<String>();
        //Set<String> accountIds = new Set<String>();
        //Set<String> idSet = new Set<String>();
        List<String> uniqstr = new List<String>();
        List<Id> idslist = new List<Id>();
        Map<String,Id> uniqueMap = new Map<String,Id>();
        Map<String,Id> uniqueUpdateMap = new Map<String,Id>();
        //List<PRM_AccountChannelMembership__c> initialACMList = new List<PRM_AccountChannelMembership__c>();
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        //Commenting below code for fixing SOQL issue TWC729-4591, this code looks unnecessary
        /*  try{
//Fetching ACM field values
for(PRM_AccountChannelMembership__c acm: acmNewList){
accountIds.add(acm.PRM_Account_Id__c);   
channelPrograms.add(acm.PRM_Channel_Program_Id__c);
idSet.add(acm.Id);
}
if((accountIds != null && !accountIds.IsEmpty()) && (channelPrograms != null && !channelPrograms.IsEmpty()) && (idSet != null && !idSet.IsEmpty())){
initialACMList = [Select Id,PRM_Partner_Role__c,PRM_Account_Id__c, PRM_Channel_Program_Id__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c in :accountIds and PRM_Channel_Program_Id__c in :channelPrograms AND Id IN :idSet];
}

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
  
} */ 
        
        if(acmNewList != null && !acmNewList.IsEmpty()){
            for(PRM_AccountChannelMembership__c acm: acmNewList){
                uniqstr.add(acm.PRM_Account_Channel_Program_Key__c);
                idsList.add(acm.id);
            }
            
        }
        //Throwing error message if CP, CPL and partner role combination already exists in an ACM record.
        if(uniqstr != null && !uniqstr.isEmpty()){
            acmList = [SELECT Id,PRM_Partner_Role__c, PRM_Account_Id__c, PRM_Account_Channel_Program_Key__c FROM PRM_AccountChannelMembership__c where PRM_Account_Channel_Program_Key__c IN: uniqstr];
        }
        if(acmOldList == null){
            if(acmList != null && !acmList.IsEmpty()){
                for(PRM_AccountChannelMembership__c acm :acmList){uniqueMap.put(acm.PRM_Account_Channel_Program_Key__c, acm.Id);
                                                                 }
                
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
                for(PRM_AccountChannelMembership__c acm :acmList){if((uniqstr != null && !uniqstr.IsEmpty()) && (idsList != null && !idsList.IsEmpty())){if((!idsList.contains(acm.Id)) && (uniqstr.contains(acm.PRM_Account_Channel_Program_Key__c))){uniqueUpdateMap.put(acm.PRM_Account_Channel_Program_Key__c,acm.Id);                                                                                                                     }
                    
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
    /* **********************************************************************************************************************************************
* author       : UTKARSH    
* Date         : 11/08/2020
* Description  : This method includes all the logic to rollup membership on OPID when new ACM is created on loaction account.
* USERSTORY    : US759862,US766682
* Modification : 
************************************************************************************************************************************************* */
    public static void UpsertOPIDACM(List<PRM_AccountChannelMembership__c > acmNewList,Map<Id,PRM_AccountChannelMembership__c> oldMap)
    {
        boolean upsertOPIDACM = false;
        Set<String> acmPartnerRole = new Set<String>();
        Set<Id> parentACMAccId = new Set<Id>();
        Set<Id> acmAccId = new Set<Id>();
        Map<Id,PRM_AccountChannelMembership__c> parentACMMap = new Map<Id,PRM_AccountChannelMembership__c>();
        Map<Id,PRM_AccountChannelMembership__c> acmMap = new Map<Id,PRM_AccountChannelMembership__c>();
        Map<Id,PRM_AccountChannelMembership__c> acmRecMap = new Map<Id,PRM_AccountChannelMembership__c>();
        Map<Id,Id> childParentMap = new Map<Id,Id>();
        PRM_AccountChannelMembership__c parentAcm = new PRM_AccountChannelMembership__c();
        PRM_AccountChannelMembership__c locationAcm = new PRM_AccountChannelMembership__c();
        List<PRM_AccountChannelMembership__c> upsertACMList = new List<PRM_AccountChannelMembership__c>();
        set<PRM_AccountChannelMembership__c> processACMID = new set<PRM_AccountChannelMembership__c>();
        //List<Core_Account_Group_Member__c> initialPAGMRecordList = new List<Core_Account_Group_Member__c>();
        Map<string,integer> OPIDTierRollUpMap=new Map<string,integer>();
        set<Id> acrIds=new set<id>();       
        
        for(PRM_AccountChannelMembership__c acm :acmNewList){
            PRM_AccountChannelMembership__c oldACM;
            if(oldMap != null && oldMap.size() > 0){
                oldACM = (PRM_AccountChannelMembership__c) oldMap.get(acm.Id);
                
            }
            if(((oldACM == null) || (oldACM != null && oldACM.PRM_Status_Nm__c != acm.PRM_Status_Nm__c)) && (acm.PRM_Status_Nm__c == System.Label.PRM_Status)){
                upsertOPIDACM=true;
                processACMID.add(acm);
                acrIds.add(acm.Id);
            }
        }
        
        
        if(upsertOPIDACM){
            ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name =:System.Label.PRM_Intel_Partner_Alliance LIMIT 1];
            if(processACMID != null && !processACMID.IsEmpty()){
                for(PRM_AccountChannelMembership__c acm :processACMID){ // Fetching location ACM details.
                    acmAccId.add(acm.PRM_Account_Id__c);
                    acmPartnerRole.add(acm.PRM_Partner_Role__c);
                    acmMap.put(acm.PRM_Account_Id__c,acm);
                    acmRecMap.put(acm.id, acm);
                }
            }
            
            if(acmAccId!=null && !acmAccId.IsEmpty()){ // Fetching parent account id.
                for(Core_Account_Group_Member__c agm :[Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Intel_Account_Id__c IN :acmAccId AND Core_Inactive_Ind__c = false]){ 
                    parentACMAccId.add(agm.Core_Partner_Account_Id__c);
                    childParentMap.put(agm.Core_Intel_Account_Id__c,agm.Core_Partner_Account_Id__c);
                }
            }
            
            set<string> partnerRoleSet=new set<string>();
            set<string> allACMAccid=new set<string>();
            
            if(!parentACMAccId.IsEmpty()){
                for(Core_Account_Group_Member__c agm :[Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Partner_Account_Id__c IN :parentACMAccId AND Core_Inactive_Ind__c = false]){ 
                    allACMAccid.add(agm.Core_Intel_Account_Id__c);
                    childParentMap.put(agm.Core_Intel_Account_Id__c,agm.Core_Partner_Account_Id__c);
                }
            }
            
            for(PRM_AccountChannelMembership__c acm :[Select Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Segment__c,PRM_Account_Id__r.Name,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Account_Id__r.RecordTypeId,PRM_Status_Nm__c From PRM_AccountChannelMembership__c Where (PRM_Account_Id__c IN :allACMAccid or PRM_Account_Id__c IN:parentACMAccId)  AND PRM_Partner_Role__c IN :acmPartnerRole]){
                
                if(acmRecMap.containsKey(acm.id)){
                    acm = acmRecMap.get(acm.id);
                }
                if(allACMAccid.contains(acm.PRM_Account_Id__c) && acm.PRM_Status_Nm__c == 'Approved'){
                    
                    if(partnerRoleSet.contains(acm.PRM_Partner_Role__c)){
                        if(childParentMap.containsKey(acm.PRM_Account_Id__c)){ if(OPIDTierRollUpMap.containsKey(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c)){OPIDTierRollUpMap.put(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c,OPIDTierRollUpMap.get(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c)+1);
                            }else{
                                OPIDTierRollUpMap.put(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c,1);
                            } 
                        }
                    }
                    else if(acm.PRM_Partner_Role__c != null){
                        partnerRoleSet.add(acm.PRM_Partner_Role__c);
                        OPIDTierRollUpMap.put(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c,1);
                    }
                }if(parentACMAccId.contains(acm.PRM_Account_Id__c)){            
                    parentACMMap.put(acm.PRM_Account_Id__c, acm);                     
                }
            }
            if(Test.isRunningTest() || (Trigger.isBefore && Trigger.isInsert)){
                
                for(PRM_AccountChannelMembership__c acm :acmNewList){
                    if(OPIDTierRollUpMap.containsKey(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c)){
                        OPIDTierRollUpMap.put(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c,OPIDTierRollUpMap.get(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c)+1);
                    }else{
                        OPIDTierRollUpMap.put(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c,1);
                    }
                }
            }
            
            
            if(parentACMAccId!=null && !parentACMAccId.IsEmpty()){ // Fecting OPID ACM details.
                //Commenting below code for fixing SOQL issue TWC729-4591, moved this logic above on existing ACM query
                /*  for(PRM_AccountChannelMembership__c acm :[Select Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Account_Id__r.RecordTypeId,PRM_Status_Nm__c From PRM_AccountChannelMembership__c Where PRM_Account_Id__c IN :parentACMAccId AND PRM_Partner_Role__c IN :acmPartnerRole]){
parentACMMap.put(acm.PRM_Account_Id__c, acm);                    
} */
                
            }
            
            if(acmAccId != null && !acmAccId.IsEmpty()){ 
                for(Id accid :acmAccId){
                    parentAcm = parentACMMap.get(childParentMap.get(accid));
                    
                    locationAcm = acmMap.get(accid);
                    
                    if(parentAcm != null){ // Update back location account ACM.
                        if(Test.isRunningTest() || Trigger.isAfter){
                            
                            if(parentAcm.PRM_Channel_Program_Level_Id__c != locationAcm.PRM_Channel_Program_Level_Id__c){
                                if(OPIDTierRollUpMap!=null && OPIDTierRollUpMap.containskey(parentAcm.PRM_Account_Id__c+locationAcm.PRM_Partner_Role__c) && OPIDTierRollUpMap.get(parentAcm.PRM_Account_Id__c+locationAcm.PRM_Partner_Role__c)==1){
                                    parentAcm.PRM_Channel_Program_Level_Id__c = locationAcm.PRM_Channel_Program_Level_Id__c;
                                    parentAcm.PRM_Status_Nm__c = System.Label.PRM_Status;
                                    parentAcm.PRM_Status_Reason_Txt__c = 'Approved as part of Rollup from Location';//TWC729-8089 : Adding reason text : NJ
                                    upsertACMList.add(parentAcm);
                                }
                            }
                            if(parentAcm.PRM_Status_Nm__c != System.Label.PRM_Status){
                                parentAcm.PRM_Status_Nm__c = System.Label.PRM_Status;
                                parentAcm.PRM_Status_Reason_Txt__c = 'Approved as part of Rollup from Location';//TWC729-8089 : Adding reason text : NJ
                                upsertACMList.add(parentAcm);
                            }
                        }
                        if(Test.isRunningTest() || Trigger.isBefore){
                           
                            if(parentAcm.PRM_Channel_Program_Level_Id__c != locationAcm.PRM_Channel_Program_Level_Id__c){
                                if((OPIDTierRollUpMap!=null && OPIDTierRollUpMap.containskey(parentAcm.PRM_Account_Id__c+locationAcm.PRM_Partner_Role__c) && 
                                    (OPIDTierRollUpMap.get(parentAcm.PRM_Account_Id__c+locationAcm.PRM_Partner_Role__c)==1)) || 
                                   OPIDTierRollUpMap == null || OPIDTierRollUpMap.isEmpty()){
                                       parentAcm.PRM_Channel_Program_Level_Id__c = locationAcm.PRM_Channel_Program_Level_Id__c;
                                       parentAcm.PRM_Status_Nm__c = System.Label.PRM_Status;
                                       parentAcm.PRM_Status_Reason_Txt__c ='Approved as part of Rollup from Location' ;//TWC729-8089 : Adding reason text : NJ
                                       upsertACMList.add(parentAcm);
                                   }
                                else {
                                    locationAcm.PRM_Channel_Program_Level_Id__c = parentAcm.PRM_Channel_Program_Level_Id__c;
                                }
                            }
                            //upsertACMList.add(locationAcm);
                            if(parentAcm.PRM_Status_Nm__c != System.Label.PRM_Status){
                                parentAcm.PRM_Status_Nm__c = System.Label.PRM_Status;
                                parentAcm.PRM_Status_Reason_Txt__c ='Approved as part of Rollup from Location' ;//TWC729-8089 : Adding reason text : NJ
                                upsertACMList.add(parentAcm);
                            }
                        }
                        
                        
                    }
                    else{ // insert ACM on OPID.
                        if(Test.isRunningTest() || Trigger.isAfter){
                            PRM_AccountChannelMembership__c insertAcm = new PRM_AccountChannelMembership__c();
                            
                            insertAcm.PRM_Account_Id__c = childParentMap.get(accid);
                            
                            insertAcm.PRM_Channel_Program_Id__c = cp.Id;
                            if(locationAcm != null){
                                insertAcm.PRM_Channel_Program_Level_Id__c = locationAcm.PRM_Channel_Program_Level_Id__c;
                                insertAcm.PRM_Partner_Role__c = locationAcm.PRM_Partner_Role__c;
                            }
                            insertAcm.PRM_Status_Nm__c = System.Label.PRM_Status;
                            insertAcm.PRM_Status_Reason_Txt__c = 'ACM Created as part of Rollup from Location' ;//TWC729-8089 : Adding reason text : NJ
                            if(!Test.isRunningTest() && insertAcm.PRM_Account_Id__c != null){upsertACMList.add(insertAcm);
                                                                                             
                                                                                            }
                        }
                    }
                }
            }
        }
        try{
            if(upsertACMList != null && !upsertACMList.IsEmpty())
            {
                PRM_ACM_TriggerHandler.firstRun = true; upsert upsertACMList;
            }
        }catch(Exception e){Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',e);            
                            
                           }
    }
    /* **********************************************************************************************************************************************
* author       : UTKARSH    
* Date         : 
* Description  : As part of the story update partner tier of child ACM when partner tier of parent ACM get updated, email will be sent to primary contact and vx record status will flip to "processed".
* User Story   : US676452
************************************************************************************************************************************************* */
    public Static  void UpdateLocationAccACM(List<PRM_AccountChannelMembership__c> acmList,Map<Id,PRM_AccountChannelMembership__c> oldMap ){
        
        List<Id> opidAccountList = new List<Id>();
        List<PRM_AccountChannelMembership__c> upsertACMList = new List<PRM_AccountChannelMembership__c>();
        List<PRM_AccountChannelMembership__c> initialACMList = new List<PRM_AccountChannelMembership__c>();
        List<Id> acmid = new List<Id>();
        Map<Id,PRM_AccountChannelMembership__c> mapLocationAccIdACM = new Map<Id,PRM_AccountChannelMembership__c>();
        Map<Id,String> opidAccPartnerRole = new Map<Id,String>();
        Map<Id,String> opidAccPartnerTier = new Map<Id,String>();
        Map<Id,String> mapLocationAccPartnerTier = new Map<Id,String>();
        Map<Id,PRM_AccountChannelMembership__c> opidAccPartnerACMMap = new Map<Id,PRM_AccountChannelMembership__c>();
        Map<Id,Id> mapLocationAccOpid = new Map<Id,Id>();
        Set<Id> locationAccList = new Set<Id>();
        boolean opidAccount = false;
        boolean isLocAccUpgraded = false;
        Map<String,String> mapOFTierAndBusinessEvent = new Map<String,String>();
        List<PRM_Value_Exchange_Recommendation__c> updatedVxRecList = new List<PRM_Value_Exchange_Recommendation__c>(); //TWC729-6800 EOL activities
        List<Id> updatedACMList = new List<Id>();
        Set<Id> activeLocationACMAccid = new Set<Id>();
        Id opidAccRecordType =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        Id[] intelAndOPIDAccRecTypes = new Id[]{opidAccRecordType};
            
        
        if(Test.isRunningTest() || Trigger.isAfter){
            for(PRM_AccountChannelMembership__c acm :acmList){ // fetching acmid.
                acmid.add(acm.Id);
                if(acm.PRM_Tier_Name_txt__c=='Gold' && oldMap!=null && oldMap.containsKey(acm.Id)  && oldMap.get(acm.Id).PRM_Tier_Name_txt__c=='Member'){
                    mapOFTierAndBusinessEvent.put(acm.PRM_Tier_Name_txt__c, 'OPID_Upgrade_Gold');
                }
                else if(acm.PRM_Tier_Name_txt__c=='Titanium' && oldMap!=null && oldMap.containsKey(acm.Id) && oldMap.get(acm.Id).PRM_Tier_Name_txt__c=='Gold'){
                    mapOFTierAndBusinessEvent.put(acm.PRM_Tier_Name_txt__c, 'OPID_Upgrade_Titanium');
                }
                else if(acm.PRM_Tier_Name_txt__c=='Titanium' && oldMap!=null && oldMap.containsKey(acm.Id) && oldMap.get(acm.Id).PRM_Tier_Name_txt__c=='Member'){
                    mapOFTierAndBusinessEvent.put(acm.PRM_Tier_Name_txt__c, 'OPID_Upgrade_Titanium');
                }
                 else if(acm.PRM_Tier_Name_txt__c=='Prestige' && oldMap!=null && oldMap.containsKey(acm.Id) && oldMap.get(acm.Id).PRM_Tier_Name_txt__c=='Partner'){
                    mapOFTierAndBusinessEvent.put(acm.PRM_Tier_Name_txt__c, 'OPID_Upgrade_Prestige');
                }
              
                
            }
            
            if(acmid != null && !acmid.IsEmpty()){ //fetching parent account id.
                initialACMList = [Select Id,Name, PRM_Account_Id__c,PRM_Partner_Role__c, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name, PRM_Account_Id__r.RecordTypeId,PRM_Status_Nm__c from PRM_AccountChannelMembership__c where Id IN :acmid];
            }
            if(initialACMList != null && !initialACMList.IsEmpty()){
                for(PRM_AccountChannelMembership__c acm :initialACMList){
                    if(intelAndOPIDAccRecTypes.contains(acm.PRM_Account_Id__r.RecordTypeId)){
                        opidAccountList.add(acm.PRM_Account_Id__c);
                        opidAccPartnerRole.put(acm.PRM_Account_Id__c, acm.PRM_Partner_Role__c);
                        /**
* Below variable was updated as part of Defect related changes: DE83025
* By : Prasant sahu
*/ 
                        opidAccPartnerTier.put(acm.PRM_Account_Id__c, acm.PRM_Channel_Program_Level_Id__r.Name);
                        opidAccPartnerACMMap.put(acm.PRM_Account_Id__c, acm);
                        opidAccount = true;
                    }
                }
            }
            
            if(opidAccount){
                //ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name =:System.Label.PRM_Intel_Partner_Alliance LIMIT 1];
                if(opidAccountList != null && !opidAccountList.IsEmpty()){ //Fetching location account id.
                    for(Core_Account_Group_Member__c agm : [Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Partner_Account_Id__c in :opidAccountList AND Core_Inactive_Ind__c = false]){
                        locationAccList.add(agm.Core_Intel_Account_Id__c);
                        mapLocationAccOpid.put(agm.Core_Intel_Account_Id__c,agm.Core_Partner_Account_Id__c);
                    }
                }
                
                if((locationAccList != null && !locationAccList.IsEmpty()) && (mapLocationAccOpid != null && !mapLocationAccOpid.IsEmpty()) && (opidAccPartnerRole != null && !opidAccPartnerRole.IsEmpty())){
                    for(PRM_AccountChannelMembership__c acm :[Select Id,Name, PRM_Account_Id__c,PRM_Partner_Role__c, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name, PRM_Account_Id__r.RecordTypeId from PRM_AccountChannelMembership__c where PRM_Account_Id__c IN :locationAccList AND PRM_Status_Nm__c =:System.Label.PRM_Status]){
                        mapLocationAccPartnerTier.put(acm.PRM_Account_Id__c,acm.PRM_Channel_Program_Level_Id__r.Name);
                        if(acm.PRM_Partner_Role__c == opidAccPartnerRole.get(mapLocationAccOpid.get(acm.PRM_Account_Id__c))){
                            mapLocationAccIdACM.put(acm.PRM_Account_Id__c,acm);
                            activeLocationACMAccid.add(acm.PRM_Account_Id__c);
                        }
                    }
                }
                
                if((locationAccList != null && !locationAccList.IsEmpty()) && (opidAccPartnerACMMap != null && !opidAccPartnerACMMap.IsEmpty())){
                    for(Id accid :locationAccList){ //updating child ACM
                        if(mapLocationAccIdACM.get(accid) != null){
                            PRM_AccountChannelMembership__c updateacm = new PRM_AccountChannelMembership__c();
                            updateacm = mapLocationAccIdACM.get(accid);
                            if(updateacm != null){
                                /**
* Below code was modified for status reason update at ACM level when rolldown scenrio happen. 
* Defect : DE83025
* By : Prasant Sahu
*/
                                PRM_AccountChannelMembership__c parentACM = opidAccPartnerACMMap.get(mapLocationAccOpid.get(accid));
                                String parentAccChannelPrg = parentACM.PRM_Channel_Program_Level_Id__r.name;
                                String locationAccChannelPrg = updateacm.PRM_Channel_Program_Level_Id__r.name;
                                if(locationAccChannelPrg != parentAccChannelPrg){
                                    updateacm.PRM_Channel_Program_Level_Id__c = parentACM.PRM_Channel_Program_Level_Id__c;
                                    String statusMessage = PRM_OPIDProcessUtility.acmUpdateStatusMessage(locationAccChannelPrg,parentAccChannelPrg);
                                    updateacm.PRM_Status_Reason_Txt__c =  statusMessage;   
                                    
                                    upsertACMList.add(updateacm);
                                    isLocAccUpgraded = true;
                                }
                                
                            }
                        }
                        else{ //inserting child ACM
                            /* PRM_AccountChannelMembership__c insertacm = new PRM_AccountChannelMembership__c();
insertacm.PRM_Account_Id__c = accid;
insertacm.PRM_Channel_Program_Id__c = cp.Id;
insertacm.PRM_Channel_Program_Level_Id__c = opidAccPartnerTier.get(mapLocationAccOpid.get(accid));
insertacm.PRM_Partner_Role__c = opidAccPartnerRole.get(mapLocationAccOpid.get(accid));
insertacm.PRM_Status_Nm__c = System.Label.PRM_Status;
upsertACMList.add(insertacm); */
                        }
                    }
                }
            }
            
            try{
                /**
* Error handling code implemented by Prasant Sahu as part of : US698395
*/
                Database.UpsertResult[] acmErrorHandle = null;
                Id finalACMId;
                
                if(upsertACMList != null && !upsertACMList.IsEmpty()){
                    //upsert upsertACMList;
                    PRM_ACM_TriggerHandler.firstRun = true;
                    acmErrorHandle = Database.upsert(upsertACMList,false);
                    Map<String,String> acmMapError = PRM_OPIDProcessUtility.getErrorMessageForACMupsert(upsertACMList, acmErrorHandle);
                    PRM_OPIDProcessUtility.updateErrorDetailsAtInboundTable(acmMapError);
                    for(Database.UpsertResult sr : acmErrorHandle){
                        if(sr.isSuccess()){
                            finalACMId = sr.getId();
                            updatedACMList.add(finalACMId);
                        }
                    }
                    
                }
                
            }catch(Exception ex){Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',ex);            
                                 
                                }
            
            /* Start - Send upgrade email to primary contact*/
            Set<String> updatedACMpartnerRole = new Set<String>();
            Set<String> acmPartnerTierList = new Set<String>();
            Set<Id> updatedACMAccountId = new Set<Id>();
            Map<Id,String> intelaccPartnerRoleMap = new Map<Id,String>();
            //Map<String,String> mapOFTierAndBusinessEvent = new Map<String,String>();
            List<PRM_EmailQueue__c> emqList= new List<PRM_EmailQueue__c>();
            
            if(updatedACMList != null && !updatedACMList.IsEmpty()){
                for(PRM_AccountChannelMembership__c acm :[Select Id,Name, PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Tier_Name_txt__c, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name, PRM_Account_Id__r.RecordTypeId from PRM_AccountChannelMembership__c where Id IN :updatedACMList AND PRM_Status_Nm__c =:System.Label.PRM_Status]){
                    updatedACMpartnerRole.add(acm.PRM_Partner_Role__c);
                    updatedACMAccountId.add(acm.PRM_Account_Id__c);
                    acmPartnerTierList.add(acm.PRM_Channel_Program_Level_Id__r.Name);
                    intelaccPartnerRoleMap.put(acm.PRM_Account_Id__c,acm.PRM_Channel_Program_Level_Id__r.name);
                }
            }
            
            
            // if((acmPartnerTierList != null && !acmPartnerTierList.IsEmpty()) && (updatedACMpartnerRole != null && !updatedACMpartnerRole.IsEmpty())){
            //     for(PRM_EmailConfiguration__mdt emailConfigList :[Select Id,PRM_BusinessEvent__c,PRM_PartnerRole__c,PRM_Entitlement_List__c,PRM_Priority__c,PRM_Tier__c from PRM_EmailConfiguration__mdt where PRM_Tier__c IN :acmPartnerTierList and PRM_PartnerRole__c IN :updatedACMpartnerRole])
            //     {
            //       
            //         mapOFTierAndBusinessEvent.put(emailConfigList.PRM_Tier__c, 'OPID_Upgrade_Gold');
            //        
            //        
            //     }
            // }
            
            
            if((updatedACMAccountId != null && !updatedACMAccountId.IsEmpty()) && (updatedACMpartnerRole != null && !updatedACMpartnerRole.IsEmpty())){
                Map<Id,PRM_Email_Handler__c> emailSuppressionMap =PRM_Email_Handler_Utility.returnContactSupressionMap(updatedACMAccountId,'Upgrade Request');                
                List<PRM_Email_Handler__c> emailHandlersToUpdate = new List<PRM_Email_Handler__c>();
                Boolean suppressEmail=false;
                for(PRM_Account_Contact_Relationship__c accCon : [Select PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Account_Id__r.Core_IPA_Badge_Tier__c,PRM_Contact_Id__c, PRM_Contact_Id__r.email,Name,PRM_Partner_Role__c,PRM_Contact_Id__r.Core_Preferred_Language__c,PRM_Contact_Id__r.FirstName,PRM_Contact_Id__r.LastName,PRM_Contact_Id__r.Name,PRM_Contact_Id__r.Core_Do_Not_Contact__c,PRM_Contact_Id__r.Core_IPA_PartnerRole__c,PRM_Relationship_Id__r.Name From PRM_Account_Contact_Relationship__c Where PRM_Account_Id__c IN :updatedACMAccountId and PRM_Contact_Id__r.Core_Do_Not_Contact__c = false AND PRM_InActive_Ind__c = false  AND PRM_Status_Nm__c =:System.Label.PRM_ACR_Status AND PRM_Contact_Id__r.Core_IPA_PartnerRole__c != null]){
                    
                    //Boolean suppressEmail = PRM_Email_Handler_Utility.checkForEmailSupression(accCon.PRM_Contact_Id__r.email,'Upgrade Request');                   
                    if(accCon.PRM_Relationship_Id__r.Name == System.Label.PRM_Primary_Contact || accCon.PRM_Relationship_Id__r.name == System.Label.PRM_Admin_Delegate){ // US760255 - UTKARSH - Added partner admin delegate as a recepient of upgrade emails.
                        if(!mapOFTierAndBusinessEvent.isEmpty() && updatedACMpartnerRole.contains(accCon.PRM_Contact_Id__r.Core_IPA_PartnerRole__c)){                                
                            contact c=new contact();c.id=accCon.PRM_Contact_Id__c;c.Email=accCon.PRM_Contact_Id__r.email;
                            PRM_EmailQueue__c emqu = new PRM_EmailQueue__c();
                            emqu.PRM_Business_Event__c = intelaccPartnerRoleMap!=null ? mapOFTierAndBusinessEvent.get(intelaccPartnerRoleMap.get(accCon.PRM_Account_Id__c)):mapOFTierAndBusinessEvent.get(accCon.PRM_Account_Id__r.Core_IPA_Badge_Tier__c);
                            emqu.PRM_Email_Content__c = '';emqu.PRM_Contact__c =  c.id;emqu.PRM_Status__c = System.Label.PRM_Pending;
                            emqu.PRM_Tier__c = intelaccPartnerRoleMap!=null ? intelaccPartnerRoleMap.get(accCon.PRM_Account_Id__c) : accCon.PRM_Account_Id__r.Core_IPA_Badge_Tier__c;
                            emqu.PRM_PartnerRole__c = accCon.PRM_Contact_Id__r.Core_IPA_PartnerRole__c;emqu.PRM_Priority__c = 1;   
                            if(emailSuppressionMap.containsKey(accCon.PRM_Contact_Id__c)){
                                suppressEmail=true; // Setting SuppressEmail Indicator 
                                emailSuppressionMap.get(accCon.PRM_Contact_Id__c).PRM_Email_Handler_Status__c='Completed';
                                emailSuppressionMap.get(accCon.PRM_Contact_Id__c).PRM_Email_Suppressed_Time__c=datetime.now();
                                emailHandlersToUpdate.add(emailSuppressionMap.get(accCon.PRM_Contact_Id__c));
                            }
                            if(!emqList.contains(emqu)&& suppressEmail==false){                                 
                                emqList.add(emqu);
                            }
                        }
                    }                    
                    suppressEmail=false;//Reset SuppressEmail Indicator
                }
                //Update EmailHandler Details 
                if(!emailHandlersToUpdate.isEmpty() && emailHandlersToUpdate!=null){
                    PRM_Email_Handler_Utility.updateEmailHandlerDetails(emailHandlersToUpdate);
                }
            }
            /* END - Send upgrade email to primary contact*/
            
        }
    }
    
    /* **********************************************************************************************************************************************
* author       : UTKARSH    
* Date         : 03/07/2020
* Description  : This method includes all the logic which are supposed to execute in "After" event.
* Modification : Optimize the code logic to reduce SOQL count.
************************************************************************************************************************************************* */
    public static void AfterOperationsOnACM(List<PRM_AccountChannelMembership__c> acmList,Map<Id,PRM_AccountChannelMembership__c> oldMap){
        Set<Id> opidAndIntelAccRecList = new Set<Id>();
        List<Id> acmIdList = new List<Id>();
        Map<String,String> accandHighestTierMap = new Map<String,String>();
        List<Account> toUpdateAccList = new List<Account>();
        //Set<String> intelAndOPIDAccRecTypes = new Set<String>{System.Label.PRM_Intel_Account,System.Label.PRM_Partner_Account_Group_Record_Type};
        Id opidAccRecordType =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        Id intelAccRecType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();  
        Id[] intelAndOPIDAccRecTypes = new Id[]{opidAccRecordType,intelAccRecType};
            Map<String,Integer> tierAndRankMap = new Map<String,Integer>{System.Label.PRM_Member => 1, System.Label.PRM_Tier_Gold => 2, System.Label.PRM_Tier_Titanium => 3};
                List<Id> acmAccountIDList = new List<Id>();
        Set<Id> accSet = new Set<Id>();
        List<Account> updateAcc = new List<Account>();
        Map<Id, Account> acctounsToUpdateMap = new Map<Id, Account>();
        List<Id> initialACMIdList = new List<Id>();
        List<PRM_AccountChannelMembership__c> initialACMRecordList = new List<PRM_AccountChannelMembership__c>();
        //List<Core_Account_Group_Member__c> initialPAGMRecordList = new List<Core_Account_Group_Member__c>();
        List<PRM_AccountChannelMembership__c> accACMsList;
        List<PRM_AccountChannelMembership__c> resaccACMsList;
        List<Id> inactivatedACMsAccIdList = new List<Id>();
        Map<Id, List<PRM_AccountChannelMembership__c>> mapOfAccACMsList = new Map<Id,List<PRM_AccountChannelMembership__c>>(); 
        Map<Id, List<PRM_AccountChannelMembership__c>> resmapOfAccACMsList = new Map<Id,List<PRM_AccountChannelMembership__c>>(); 
        Map<Id,String> mapOfAccIdBadgeTier = new Map<Id,String>();
        Map<Id,String> resmapOfAccIdBadgeTier = new Map<Id,String>();
        //List<PRM_IPABadgeMapping__mdt> badgeMappingList = new List<PRM_IPABadgeMapping__mdt>();
        Map<String,Integer> ProgramTierRankingMap = new Map<String,Integer>();
        Map<String, Decimal> mapOfBadgeNameTier = new Map<String, Decimal>();
        Map<String, Decimal> resmapOfBadgeNameTier = new Map<String, Decimal>();
        String highestTier = '';
        String accountBadgeTier = '';
        String reshighestTier = '';
        List<Account> accsToUpdate = new List<Account>();
        List<Account> resaccsToUpdate = new List<Account>();
        //List<Account> initialAccList = new List<Account>();
        List<Id> initialACCId = new List<Id>();
        Set<String> accountIds = new Set<String>();
        Set<String> contactIds = new Set<String>();
        Set<String> channelPrograms = new Set<String>();
        Set<String> cpLevels= new Set<String>();
        Set<Id> automaticBenefits = new Set<Id>();
        Set<String> partnerRole = new Set<String>(); 
        List<PRM_ContactSubscriptionAssociation__c> csaList = new List<PRM_ContactSubscriptionAssociation__c>();
        List<PRM_AccountBenefitAssociation__c> updateABAList = new List<PRM_AccountBenefitAssociation__c>();
        //List<Id> updateAccid = new List<Id>();
        boolean inactiveIPAAccount = false;
        boolean activeIPAAccount = false;
        boolean updateBatchTierRollup = false;
        boolean updateBatchTierRolldown = false;
        boolean inactiveABAandSubs = false;
        //boolean upsertOPIDACM = false;
        Set<Id> acmActiveAccountIDset = new Set<Id>(); //added by Teja Munagala 
        Set<Id> acmActiveIDset = new Set<Id>(); //added by Teja Munagala
        List<Account> accountIPAActive = new List<Account>();
        //Map<Id,Account>accountIPAActiveset = new Map<Id,Account>();
        //set<PRM_AccountChannelMembership__c> processACMID = new set<PRM_AccountChannelMembership__c>();
        Set<String>activeACMPartnerRole = new Set<String>();
        Set<Id>activeACMPartnerRoleBenefits = new Set<Id>();
        Set<String> cpl = new Set<String>{'Member','Gold','Titanium'};
            Set<Id> existingABA = new Set<Id>();
        Map<String, String> mapRoleandTier = new Map<String, String>();
        String benefittier;
        Map<Id,String> mapAcmPartnerRole = new Map<Id,String>();
        List<PRM_Account_Specialty_Association__c> updateChildASA = new List<PRM_Account_Specialty_Association__c>();
        List<Account> updateLocationAcc = new List<Account>();
        Set<Id> accPartnerSegment = new Set<Id>();
        /*Variables used for add logic in condition 4 */
        boolean inactivateOPIDACM = false;
        Set<Id> inactiveACMId = new Set<Id>();
        Set<Id> inactiveACMAccId = new Set<Id>();
        Set<String> inactiveACMPartnerrole = new Set<String>();
        Set<Id> parentAccId = new Set<Id>();
        Set<Id> childAccId = new Set<Id>();
        Map<Id,Id> mapLocationAccOpid = new Map<Id,Id>();
        Map<id,list<PRM_AccountChannelMembership__c>> mapOpidLoc = new Map<id,list<PRM_AccountChannelMembership__c>> () ; //TWC729-5005
        Map<id,set<string>> mapOpidEligBenefits = new Map<id,set<string>> () ; //TWC729-5005
        Map<string,set<string>> mapPartnerTierBenefits = new Map<string,set<string>> () ; //TWC729-5005
        //set<string> allEligBenefits = new set<string>() ; //TWC729-5005
        Set<Id> activeParentAccIdSet = new Set<Id>();
        List<PRM_AccountChannelMembership__c> updateOPIDACM = new List<PRM_AccountChannelMembership__c>();
        List<PRM_Account_Contact_Relationship__c> inactiveACRIdList = new List<PRM_Account_Contact_Relationship__c>();
        //List<PRM_Account_Contact_Relationship__c> activeACRIdList = new List<PRM_Account_Contact_Relationship__c>();
        List<PRM_AccountChannelMembership__c> acmAccountList = new List<PRM_AccountChannelMembership__c>();
        List<Id> accountACMList = new List<Id>();
        //Set<Id> acrAccId = new Set<Id>();
        Set<String> activeACMPR = new Set<String>();
   Map<id, Account> mapAccountsToUpdate = new Map<id, Account>();
        //List<PRM_Account_Contact_Relationship__c> inactiveAllACRIdList;
        /*Variables used for add logic in condition 4  - END*/
        /*Start - Filtering based on conditions*/
        Set<String> actIdPartnerRole = new set<String>();
        Map<Id, Map<String, String>> accountIdOldNewPartnerROleMap = new Map<Id, Map<String, String>>();
        Set<id> accountId = new Set<id>();
        //Set<Id>conPartRoleRemoveSet = new Set<Id>();
        List<Contact>contactsToUpdateList = new List<Contact>();
        if(Test.isRunningTest() || Trigger.isAfter){
            for(PRM_AccountChannelMembership__c acm:acmList){
                
                //added by dinesh
                if(oldMap!=null){
                    if(accountIdOldNewPartnerROleMap.size()>0 && accountIdOldNewPartnerROleMap.containskey(acm.PRM_Account_Id__c) && accountIdOldNewPartnerROleMap.get(acm.PRM_Account_Id__c)!=null ){                   
                        accountIdOldNewPartnerROleMap.get(acm.PRM_Account_Id__c).put(acm.PRM_Partner_Role__c,oldMap.get(acm.Id).PRM_Partner_Role__c);
                    }else{
                        accountIdOldNewPartnerROleMap.put(acm.PRM_Account_Id__c,new Map<String, String>{acm.PRM_Partner_Role__c=>oldMap.get(acm.Id).PRM_Partner_Role__c});
                    }
                }
                if(oldMap!=null && oldMap.get(acm.Id).PRM_Partner_Role__c!=acm.PRM_Partner_Role__c){
                    accountId.add(acm.PRM_Account_Id__c);// storing account ids
                    actIdPartnerRole.add(acm.PRM_Account_Id__c+'-'+acm.PRM_Partner_Role__c);
                }
                //------------------
                initialACMIdList.add(acm.Id);
                PRM_AccountChannelMembership__c oldACM;
                if(oldMap != null && oldMap.size() > 0){
                    oldACM = (PRM_AccountChannelMembership__c) oldMap.get(acm.Id);
                    
                }
                //condition - 1 - Update Badge tier when manual or OPID upgrade take place rollup.
                if((oldMap == null) || ((oldMap != null && oldMap.size() > 0) && ((acm.PRM_Channel_Program_Level_Id__c != oldACM.PRM_Channel_Program_Level_Id__c) || ((oldACM.PRM_Status_Nm__c != System.Label.PRM_Status) && (acm.PRM_Status_Nm__c == System.Label.PRM_Status))))){
                    acmIdList.add(acm.Id);
                    updateBatchTierRollup = true;
                }
                //condition - 2 - Update Badge tier when manual or OPID upgrade take place rolldown.
                if(acm.PRM_Status_Nm__c == System.label.PRM_Status_Inactive && oldMap != null && oldMap.containsKey(acm.Id) && oldMap.get(acm.id).PRM_Status_Nm__c != acm.PRM_Status_Nm__c){
                    inactivatedACMsAccIdList.add(acm.PRM_Account_Id__c);
                    updateBatchTierRolldown = true;                 
                }
                //condition - 3 - Inactivate IPA Account.
                if(oldACM != null && (oldACM.PRM_Status_Nm__c != acm.PRM_Status_Nm__c && acm.PRM_Status_Nm__c != System.Label.PRM_Status)){
                    inactiveIPAAccount = true;
                    acmAccountIDList.add(acm.PRM_Account_Id__c);
                }
                //condition - 4 - Inactivate ABA records on account and inactive subscriptions.
                if(oldACM != null && (oldACM.PRM_Status_Nm__c != acm.PRM_Status_Nm__c && acm.PRM_Status_Nm__c == System.label.PRM_Status_Inactive)){
                    inactiveABAandSubs = true;
                    inactiveACMId.add(acm.Id);
                    
                    accountIds.add(acm.PRM_Account_Id__c);
                    channelPrograms.add(acm.PRM_Channel_Program_Id__c);
                    cpLevels.add(acm.PRM_Channel_Program_Level_Id__c);
                    partnerRole.add(acm.PRM_Partner_Role__c);
                }
                //condition  - 5 - Activate IPA Account. added by Teja Munagala
                    if(( oldACM == null && acm.PRM_Status_Nm__c == System.Label.PRM_Status )  || (oldACM != null && (oldACM.PRM_Status_Nm__c != acm.PRM_Status_Nm__c && acm.PRM_Status_Nm__c == System.Label.PRM_Status)) ) {
                    activeIPAAccount=true;
                    acmActiveAccountIDset.add(acm.PRM_Account_Id__c);
                    activeACMPR.add(acm.PRM_Partner_Role__c);
                    
                    acmActiveIDset.add(acm.id);
                }
            }
            /*END - Filtering based on conditions*/
            //added by dinesh
            // get the account details
            
            Map<Id, List<String>> actIdBizTypes = new Map<Id, List<String>>();
            Map<Id, List<String>> actIdPartnerRoles = new Map<Id, List<String>>();
            Map<id,account> accountDetailsMap = new Map<Id,Account>();
            if(accountId!=null && !accountId.isEmpty()){
                for(Account accRecord : [select id, Core_Account_Type__c, Core_IPA_Partner_Role__c from Account  where id in :accountId]){
                    List<String> bizTypes = new List<String>();
                    List<String> roles = new List<String>();
                    if(!String.isEmpty(accRecord.Core_Account_Type__c)){
                        bizTypes = accRecord.Core_Account_Type__c.split(';');
                    }
                    
                    if(!String.isEmpty(accRecord.Core_IPA_Partner_Role__c)){
                        roles = accRecord.Core_IPA_Partner_Role__c.split(';');
                    }
                    
                    actIdBizTypes.put(accRecord.id, bizTypes);
                    actIdPartnerRoles.put(accRecord.id, roles);
                    accountDetailsMap.put(accRecord.id,accRecord);
                }
            }
            
            // get the metedata default mapping
            Map<String, String> defaultPartnerRoleBizType = new Map<String, String>();
             for(PRM_PartnerRoleTypeMappings__mdt Temp : [Select Id,PRM_Biz_Org_Type__c,PRM_Partner_Role__c from PRM_PartnerRoleTypeMappings__mdt where Grouping_Method__c != null]){
                defaultPartnerRoleBizType.put(Temp.PRM_Partner_Role__c,Temp.PRM_Biz_Org_Type__c);
            }
            // update account with new values
            
            Map<id, Account> accountsToBeUpdated =  new Map<Id, Account>();
            Map<Id, Account> allInitialAccMap = new Map<Id, Account>();
            
            //if(actIdPartnerRole!=null && !actIdPartnerRole.isEmpty()){
            for(String record :  actIdPartnerRole){
                String accId = record.split('-')[0];
                String newRole = record.split('-')[1];
                String bizType = defaultPartnerRoleBizType.get(newRole);
                
                if(accountDetailsMap.size()>0 && accountDetailsMap.containsKey(accId)){ 
                    Account a = accountDetailsMap.get(accId);                            
                    a.Core_Account_Type__c=(actIdBizTypes!=null && actIdBizTypes.containsKey(accId) && actIdBizTypes.get(accId).contains(bizType))?a.Core_Account_Type__c:a.Core_Account_Type__c+';'+bizType;                                                    
                    if(actIdPartnerRoles.size()>0 ){
                        if(actIdPartnerRoles.containsKey(accId) && actIdPartnerRoles.get(accId).contains(newRole)){                                    
                            a.Core_IPA_Partner_Role__c = a.Core_IPA_Partner_Role__c;
                        }
                        else if(actIdPartnerRoles.containsKey(accId) && accountIdOldNewPartnerROleMap.size()>0 && actIdPartnerRoles.get(accId).contains(accountIdOldNewPartnerROleMap.get(accId).get(newRole))){
                            a.Core_IPA_Partner_Role__c = string.valueOf(a.Core_IPA_Partner_Role__c).replace(accountIdOldNewPartnerROleMap.get(accId).get(newRole), newRole);
                        }else{
                            a.Core_IPA_Partner_Role__c = newRole;//a.Core_IPA_Partner_Role__c+';'+
                        }
                        
                    }else{
                        a.Core_IPA_Partner_Role__c = a.Core_IPA_Partner_Role__c+';'+newRole;
                    }
                    accountsToBeUpdated.put(a.Id, a);
                    
                }
            }
            //}
            
            
            Database.SaveResult [] srList = Database.update(accountsToBeUpdated.values(), false);
            for(Database.SaveResult sr: srList){
                if(!sr.isSuccess()){
                    
                }
            }
            
            Map<id, Account> accountMap = new Map<Id, Account>();
            Map<Id, List<String>> mapOfInactiveAccPartnerRole = new Map<Id, List<String>>();
            
            //---- End 
            /*Start - Required query on objects to use later in the method*/
            if(initialACMIdList != null && !initialACMIdList.IsEmpty()){                                        
                initialACMRecordList = [Select Id,Name,PRM_Account_Id__r.Core_IPA_Partner_Segment__c,PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_One_Partner_Id__c, PRM_Account_Id__r.Core_IPA_Badge_Tier__c,PRM_Account_Id__r.Name,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Account_Id__r.RecordTypeId,PRM_Status_Nm__c, PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c From PRM_AccountChannelMembership__c Where Id IN :initialACMIdList];
                for(PRM_AccountChannelMembership__c acm :initialACMRecordList){
                    initialACCId.add(acm.PRM_Account_Id__c);
                    
                    if(inactivatedACMsAccIdList.contains(acm.PRM_Account_Id__c)){
                        if(!accountMap.containsKey(acm.PRM_Account_Id__c)){  
                            Account acc = new Account();
                            acc.id = acm.PRM_Account_Id__c;                            
                            acc.Core_IPA_Partner_Segment__c = acm.PRM_Account_Id__r.Core_IPA_Partner_Segment__c;
                            accountMap.put(acc.id, acc);
                        }
                        
                        if(mapOfInactiveAccPartnerRole.containsKey(acm.PRM_Account_Id__c)){
                            mapOfInactiveAccPartnerRole.get(acm.PRM_Account_Id__c).add(acm.PRM_Partner_Role__c);
                        }else{                          
                            List<String> roleList = new List<String>();
                      roleList.add(acm.PRM_Partner_Role__c);
                            mapOfInactiveAccPartnerRole.put(acm.PRM_Account_Id__c, roleList);
                        }

                    }
                    
                    if(!allInitialAccMap.containsKey(acm.PRM_Account_Id__c)){
                        Account acc = new Account();    
                        acc.id = acm.PRM_Account_Id__c;
                        acc.Core_IPA_Badge_Tier__c = acm.PRM_Account_Id__r.Core_IPA_Badge_Tier__c;
                        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c;                        
                        acc.Core_IPA_Partner_Segment__c = acm.PRM_Account_Id__r.Core_IPA_Partner_Segment__c;
                        allInitialAccMap.put(acc.id, acc);
                    }
                }
            }
            /*(updateBatchTierRollup || updateBatchTierRolldown){
initialPAGMRecordList = [Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c From Core_Account_Group_Member__c];
}*/
            if(updateBatchTierRollup || inactiveIPAAccount){
                if(initialACCId != null && !initialACCId.IsEmpty()){
                    //initialAccList = [Select Id,Name,Core_IPA_Badge_Tier__c,Core_Intel_Partner_Alliance_PartnerGroup__c,RecordType.DeveloperName,RecordTypeId From Account Where Id IN :initialACCId];
                }
            }
            if(updateBatchTierRolldown){
                //badgeMappingList = [Select Id, IPA_Badge_Name__c, Rank__c from PRM_IPABadgeMapping__mdt];
                for(String prgmrank : LabelConfiguration__mdt.getInstance('ChannelProgramLevelRanking').Value__c.split(';'))
                {
                    List<String> progTier = prgmrank.split(':');
                    ProgramTierRankingMap.put(progTier[0],Integer.valueOf(progTier[1]));
                    
                }
            }
            /*END - Required query on objects to use later in the method*/
            /*Start - condition-1, Developer - Bharath*/
            if(updateBatchTierRollup){
                if(initialACMRecordList != null && !initialACMRecordList.IsEmpty()){
                    for(PRM_AccountChannelMembership__c acm :initialACMRecordList){
                        
                        if(acmIdList!= null && !acmIdList.IsEmpty()){
                            if(acmIdList.contains(acm.Id) && intelAndOPIDAccRecTypes.contains(acm.PRM_Account_Id__r.RecordTypeId) && acm.PRM_Status_Nm__c == System.Label.PRM_Status){
                                opidAndIntelAccRecList.add(acm.PRM_Account_Id__c);
                            }
                        }
                    }
                }
                
                if(opidAndIntelAccRecList!=null && !opidAndIntelAccRecList.IsEmpty()){// Fetch location account from opid account when upgrade teakes place
                    //for(Core_Account_Group_Member__c agm :initialPAGMRecordList){
                    for(Core_Account_Group_Member__c agm :[Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Partner_Account_Id__c IN :opidAndIntelAccRecList AND Core_Inactive_Ind__c = false]){
                        // if(opidAndIntelAccRecList.contains(agm.Core_Partner_Account_Id__c)){ 
                        opidAndIntelAccRecList.add(agm.Core_Intel_Account_Id__c);
                        /*}else if(opidAndIntelAccRecList.contains(agm.Core_Intel_Account_Id__c)){
opidAndIntelAccRecList.add(agm.Core_Partner_Account_Id__c);    
} */
                    }
                }
                
                if(opidAndIntelAccRecList!=null && !opidAndIntelAccRecList.IsEmpty()){ // Fetch opid from location account when opid get activated 
                    //for(Core_Account_Group_Member__c agm :initialPAGMRecordList){
                    for(Core_Account_Group_Member__c agm :[Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Intel_Account_Id__c IN :opidAndIntelAccRecList AND Core_Inactive_Ind__c = false]){
                        //if(opidAndIntelAccRecList.contains(agm.Core_Partner_Account_Id__c)){
                        opidAndIntelAccRecList.add(agm.Core_Partner_Account_Id__c);
                        //}
                    }
                } 
                
                if(opidAndIntelAccRecList!=null && !opidAndIntelAccRecList.IsEmpty()){
                    List<PRM_AccountChannelMembership__c> opidAcmRecList = [SELECT Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Badge_Tier__c,PRM_Account_Id__r.Name,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c IN :opidAndIntelAccRecList and PRM_Account_Id__r.RecordTypeId IN:intelAndOPIDAccRecTypes and PRM_Status_Nm__c = :System.Label.PRM_Status];
                    
                    if(opidAcmRecList!=null && !opidAcmRecList.IsEmpty()){
                        for(PRM_AccountChannelMembership__c acm:opidAcmRecList){                                                       
                            
                            if(accandHighestTierMap.containsKey(acm.PRM_Account_Id__c)){Integer currentRank = tierAndRankMap.get(accandHighestTierMap.get(acm.PRM_Account_Id__c));
                                if(currentRank < tierAndRankMap.get(acm.PRM_Channel_Program_Level_Id__r.Name)){accandHighestTierMap.put(acm.PRM_Account_Id__c,acm.PRM_Channel_Program_Level_Id__r.Name);
                                                                                                              }
                            }else{
                                if(!accandHighestTierMap.containsKey(acm.PRM_Account_Id__c)){
                                    accandHighestTierMap.put(acm.PRM_Account_Id__c,acm.PRM_Channel_Program_Level_Id__r.Name);
                                }
                            }
                        }
                    }
                }
                
                
                if(opidAndIntelAccRecList!=null && !opidAndIntelAccRecList.IsEmpty()){                   
                    List<Account> allOPIDaccs = [Select Id,Name,Core_IPA_Badge_Tier__c,RecordTypeId from Account where Id IN:opidAndIntelAccRecList and RecordTypeId IN:intelAndOPIDAccRecTypes];
                    
                    for(Account acc : allOPIDaccs){
                        // for(Account acc: accMap.values()){
                        
                        if(accandHighestTierMap!=null && !accandHighestTierMap.IsEmpty()){
                            if(acc.Core_IPA_Badge_Tier__c !=accandHighestTierMap.get(acc.Id) && (accandHighestTierMap.containsKey(acc.Id))){
                                acc.Core_IPA_Badge_Tier__c = accandHighestTierMap.get(acc.Id);
                                toUpdateAccList.add(acc);
                            }
                        }
                    }
                }
                
                if(toUpdateAccList != null && !toUpdateAccList.IsEmpty()){
                    if(!System.isBatch()){
                        //Schema.SObjectType acc = Schema.Account.getSObjectType();
                        System.enqueueJob(new ContactERPMIntegrationStatusHandler(toUpdateAccList,Schema.Account.getSObjectType()));
                    }
                    else if(System.isBatch()){update toUpdateAccList;
                                             }
                }
            }
          
            /*END -condition-1*/
            /*Start - condition-2, Developer - SABA*/
            if(Test.isRunningTest() || (trigger.Isupdate && updateBatchTierRolldown)){
                if(inactivatedACMsAccIdList!=null && !inactivatedACMsAccIdList.IsEmpty()){
                    for(Core_Account_Group_Member__c agm :[Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Intel_Account_Id__c IN :inactivatedACMsAccIdList AND Core_Inactive_Ind__c = false]){
                        inactivatedACMsAccIdList.add(agm.Core_Partner_Account_Id__c);
                    }
                }
                
                if(inactivatedACMsAccIdList != null && !inactivatedACMsAccIdList.IsEmpty()){
                    acmAccountList = [Select Id, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Segment__c, PRM_Account_Id__r.Core_IPA_Badge_Tier__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Status_Nm__c,PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c IN:inactivatedACMsAccIdList and PRM_Status_Nm__c = :System.label.PRM_Status];
                    
                    for(PRM_AccountChannelMembership__c acm: acmAccountList){
                        if(mapOfInactiveAccPartnerRole.containsKey(acm.PRM_Account_Id__c)){
                            mapOfInactiveAccPartnerRole.get(acm.PRM_Account_Id__c).add(acm.PRM_Partner_Role__c);
                        }else{                          
                            List<String> roleList = new List<String>();
                      roleList.add(acm.PRM_Partner_Role__c);
                            mapOfInactiveAccPartnerRole.put(acm.PRM_Account_Id__c, roleList);
                        }
                        
                        mapOfAccIdBadgeTier.put(acm.PRM_Account_Id__c, acm.PRM_Account_Id__r.Core_IPA_Badge_Tier__c);
                        if(mapOfAccACMsList.containsKey(acm.PRM_Account_Id__c)){accACMsList = mapOfAccACMsList.get(acm.PRM_Account_Id__c);
                                                                               }else{
                                                                                   accACMsList = new List<PRM_AccountChannelMembership__c>();
                                                                               }
                        accACMsList.add(acm);
                        mapOfAccACMsList.put(acm.PRM_Account_Id__c,accACMsList);
                    }
                }
                if(ProgramTierRankingMap != null && !ProgramTierRankingMap.IsEmpty()){
                    for(String bageMapping :ProgramTierRankingMap.keyset()){
                        mapOfBadgeNameTier.put(bageMapping, ProgramTierRankingMap.get(bageMapping));            
                    }
                }
                
                if(inactivatedACMsAccIdList != null && !inactivatedACMsAccIdList.IsEmpty()){
                    for(Id accId: inactivatedACMsAccIdList){
                        if(!mapOfAccACMsList.containskey(accId)){
                            Account acc = new Account();acc.Core_IPA_Badge_Tier__c = '';acc.Core_IPA_Partner_Segment__c = '';acc.Id = accId;
                            if(!accsToUpdate.contains(acc)){accsToUpdate.add(acc);
                                                           }
                        }                    
                    }
                }
                
                if(mapOfAccACMsList != null && !mapOfAccACMsList.IsEmpty()){
                    for(Id accId: mapOfAccACMsList.keyset()){
                        accACMsList = mapOfAccACMsList.get(accId);
                        accountBadgeTier = mapOfAccIdBadgeTier.get(accId);
                        if(accACMsList == null || accACMsList.isEmpty()){Account acc = new Account();
                                                                         acc.Core_IPA_Badge_Tier__c = '';acc.Id = accId;
                                                                         if(!accsToUpdate.contains(acc)){accsToUpdate.add(acc);
                                                                                                        } 
                                                                        }
                        highestTier = null;
                        for(PRM_AccountChannelMembership__c acm: accACMsList){
                            if(String.isBlank(highestTier)){
                                highestTier = acm.PRM_Channel_Program_Level_Id__r.Name;
                            }else if(mapOfBadgeNameTier.get(highestTier) > mapOfBadgeNameTier.get(acm.PRM_Channel_Program_Level_Id__r.Name)){highestTier = acm.PRM_Channel_Program_Level_Id__r.Name;                                      
                                                                                                                                            }
                        }
                        if(accountBadgeTier != highestTier){
                            Account acc = new Account();
                            acc.Core_IPA_Badge_Tier__c = highestTier;
                            acc.Id = accId;
                            if(!accsToUpdate.contains(acc)){accsToUpdate.add(acc);
                                                           }    
                        }
                    }
                }
                
                
                
                if(accsToUpdate != null && !accsToUpdate.IsEmpty()){                    
                    if(!System.isBatch()){
                        //Commenting below code as part of defect fix for DE97259: 
                        //Added a single update call on account to prevent overwrting changes        
                        
                        /*Schema.SObjectType acc = Schema.Account.getSObjectType();
System.enqueueJob(new ContactERPMIntegrationStatusHandler(accsToUpdate,acc)); */
                        
                        acctounsToUpdateMap.putAll(accsToUpdate);
                    }
                    else if(System.isBatch()){update accsToUpdate;
                                             }
                }
            }
            /*END -condition-2*/
            /*Start - condition-3, Developer - UTKARSH*/
            if(Test.isRunningTest() || (trigger.Isupdate && inactiveIPAAccount)){
                if(acmAccountIDList!=null && !acmAccountIDList.IsEmpty()){
                    //Commenting below code for fixing SOQL issue TWC729-4591, used existing ACM query above to get ACM values
                    // for(PRM_AccountChannelMembership__c acm :[SELECT Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c IN :acmAccountIDList and PRM_Status_Nm__c =:System.Label.PRM_Status and PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c=TRUE]){
                     for(PRM_AccountChannelMembership__c  acm : acmAccountList){
                        if(acmAccountIDList.contains(acm.PRM_Account_Id__c) && acm.PRM_Status_Nm__c ==System.Label.PRM_Status)
                        {
                            accountACMList.add(acm.PRM_Account_Id__c);
                        }
                   }
                    for(PRM_AccountChannelMembership__c acm: initialACMRecordList){  
                        if(acmAccountIDList.contains(acm.PRM_Account_Id__c) && acm.PRM_Status_Nm__c ==System.Label.PRM_Status && acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c==TRUE){
                            accSet.add(acm.PRM_Account_Id__c);
                        }
                    }
                    
                }
                if(initialACCId!=null && !initialACCId.IsEmpty()){
                    //Commenting below code for fixing SOQL issue TWC729-4591, used existing ACM query above to get Account values
                    for(Account acc :[Select Id,Name,Core_Intel_Partner_Alliance_PartnerGroup__c,RecordType.DeveloperName,RecordTypeId From Account Where Id IN :initialACCId]){
                    //for(Account acc: allInitialAccMap.values()){
                        if(acmAccountIDList!=null && !acmAccountIDList.IsEmpty() && acmAccountIDList.contains(acc.Id)){
                            if((accountACMList==null || accountACMList.IsEmpty()) || !accountACMList.contains(acc.Id)){
                                if((accSet==null || accSet.IsEmpty()) || !accSet.contains(acc.Id)){
                                    if(acctounsToUpdateMap.containsKey(acc.Id)){
                                        acctounsToUpdateMap.get(acc.Id).Core_Intel_Partner_Alliance_PartnerGroup__c = false;                                        
                                    } else{acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
                                           updateAcc.add(acc);
                                          }
                                }
                            }
                        }
                    }
                    
                }
                if(updateAcc != null && !updateAcc.IsEmpty()){acctounsToUpdateMap.putAll(updateAcc);
                                                             }  
                //Commenting below code as part of defect fix for DE97259: 
                //Added a single update call on account to prevent overwrting changes              
                /*
if(updateAcc != null && !updateAcc.IsEmpty()){
if(!System.isBatch()){
Schema.SObjectType acc = Schema.Account.getSObjectType();
System.enqueueJob(new ContactERPMIntegrationStatusHandler(updateAcc,acc));
}
else if(System.isBatch()){update updateAcc;
}

} */
            }
            //DE97259: update account
            if(acctounsToUpdateMap != null && !acctounsToUpdateMap.IsEmpty()){                    
                if(!System.isBatch()){
                    Schema.SObjectType acc = Schema.Account.getSObjectType();
                    System.enqueueJob(new ContactERPMIntegrationStatusHandler(acctounsToUpdateMap.values(),acc));
                }
            }
            
            /*END -condition-3*/
            /*Start - condition-4, Developer - UTKARSH*/
            if(Test.isRunningTest() || (trigger.Isupdate && inactiveABAandSubs)){ 
                /*US759862 -UTKARSH - Inactive OPID ACM when its location account ACM become inactive*/
                //Commenting below code for fixing SOQL issue TWC729-4591, used existing ACM query above to get ACM values
                //for(PRM_AccountChannelMembership__c acm :[Select Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Account_Id__r.RecordTypeId,PRM_Status_Nm__c From PRM_AccountChannelMembership__c Where Id IN :inactiveACMId]){
                for(PRM_AccountChannelMembership__c acm: initialACMRecordList){
                    if(inactiveACMId.contains(acm.id)){       
                        mapAcmPartnerRole.put(acm.PRM_Account_Id__c,acm.PRM_Partner_Role__c);
                        //if(acm.PRM_Channel_Program_Level_Id__r.Name == System.Label.PRM_Channel_Program_Level){
                            inactivateOPIDACM = true;
                            inactiveACMAccId.add(acm.PRM_Account_Id__c);
                            inactiveACMPartnerrole.add(acm.PRM_Partner_Role__c);                        
                        //}
                    }
                }   
                
                //Set<Id> updateOPIDACMIDList=new Set<Id>();               
                if(inactivateOPIDACM){                    
                  if(inactiveACMAccId != null && !inactiveACMAccId.IsEmpty()){ //Fetching parent account id.
                        for(Core_Account_Group_Member__c agm : [Select Id,Name,Core_Partner_Account_Id__c, Core_Partner_Account_Id__r.Core_IPA_Partner_Segment__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Intel_Account_Id__c IN :inactiveACMAccId AND Core_Inactive_Ind__c = false]){
                            parentAccId.add(agm.Core_Partner_Account_Id__c);
                            Account opidAcc = new Account();
                            opidAcc.id = agm.Core_Partner_Account_Id__c;                            
                            opidAcc.Core_IPA_Partner_Segment__c = agm.Core_Partner_Account_Id__r.Core_IPA_Partner_Segment__c;
                            accountMap.put(opidAcc.id, opidAcc);
                        }
                     } 
                    
                    if(parentAccId != null && !parentAccId.IsEmpty()){ //Fetching other child accounts id from the parent accounts.
                        for(Core_Account_Group_Member__c agm : [Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Partner_Account_Id__c IN :parentAccId AND Core_Inactive_Ind__c = false]){
                            childAccId.add(agm.Core_Intel_Account_Id__c);
                            mapLocationAccOpid.put(agm.Core_Intel_Account_Id__c,agm.Core_Partner_Account_Id__c);
                        }
                    }
                    
                    if((childAccId != null && !childAccId.IsEmpty()) && (inactiveACMPartnerrole != null && !inactiveACMPartnerrole.IsEmpty())){ //Fetching parent account id if its child account has same ACM configuration present.
                        for(PRM_AccountChannelMembership__c acm :[Select Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Account_Id__r.RecordTypeId,PRM_Status_Nm__c From PRM_AccountChannelMembership__c Where PRM_Account_Id__c IN :childAccId AND PRM_Partner_Role__c IN :inactiveACMPartnerrole AND PRM_Status_Nm__c =:System.Label.PRM_Status]){activeParentAccIdSet.add(mapLocationAccOpid.get(acm.PRM_Account_Id__c));
                                                                                                                                                                                                                                                                                                                                                                                                                                            }
                    }                    
                    
                    // checking - if the sibling account does not have matching partner role then we could conclude this is the last ACM with this partner role for this OPID. Inacitvate the ACM at OPID. But try to avoid the recursion
                    if(parentAccId != null && !parentAccId.IsEmpty()){ //Inactivating ACM from parent account
                        for(PRM_AccountChannelMembership__c acm :[Select Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Account_Id__r.RecordTypeId,PRM_Status_Nm__c From PRM_AccountChannelMembership__c Where PRM_Account_Id__c IN :parentAccId AND PRM_Status_Nm__c =:System.Label.PRM_Status]){
                            if(mapOfInactiveAccPartnerRole.containsKey(acm.PRM_Account_Id__c)){
                                mapOfInactiveAccPartnerRole.get(acm.PRM_Account_Id__c).add(acm.PRM_Partner_Role__c);
                            }else{
                                List<String> roleList = new List<String>();roleList.add(acm.PRM_Partner_Role__c);
                                mapOfInactiveAccPartnerRole.put(acm.PRM_Account_Id__c, roleList);
                            }
                            if((activeParentAccIdSet == null || activeParentAccIdSet.IsEmpty()) || !activeParentAccIdSet.contains(acm.PRM_Account_Id__c)){
                                if(inactiveACMPartnerrole.contains(acm.PRM_Partner_Role__c) ){
                                    acm.PRM_Status_Nm__c = System.Label.PRM_Status_Inactive;
                                    acm.PRM_Status_Reason_Txt__c = 'Inactivating ACM as no child has ACM with this partner role' ;//TWC729-8089 : Adding reason text : NJ
                                    updateOPIDACM.add(acm);
                                    inactiveACMAccId.add(acm.PRM_Account_Id__c);
                                  }else{
                                    //TWC729-5005
                                    if(mapOpidLoc.keyset().contains(acm.PRM_Account_Id__c)){
                                        // This Map will have parent , list of cag.
                                        List<PRM_AccountChannelMembership__c> acmRecords = mapOpidLoc.get(acm.PRM_Account_Id__c);
                                        acmRecords.add(acm);mapOpidLoc.put(acm.PRM_Account_Id__c, acmRecords);
                                    }
                                    else{
                                        mapOpidLoc.put(acm.PRM_Account_Id__c,new List<PRM_AccountChannelMembership__c>{acm}) ;
                                    } 
                                    //TWC729-5005

                                }
                            }
                        }
                    }
                    
                }
    //roll up OPID Account Partner Segment on inactivating Location Account ACM
                Map<String, List<String>> mapOfPartnerSegmentRole = getPartnerSegmentPartnerRoleMapping();
                Map<Id,Account> rolledUpAccountMap = new Map<Id,Account>();
                for(Id accId: inactiveACMAccId){
                    if(mapOfInactiveAccPartnerRole.containsKey(accId) && accountMap.containsKey(accId)){
                      Account acc = accountMap.get(accId);                                                       
            List<String> partnerSegmentList = new List<String>();
                        if(String.IsNotBlank(acc.Core_IPA_Partner_Segment__c))
                          partnerSegmentList.addAll(acc.Core_IPA_Partner_Segment__c.split(';'));  
            acc.Core_IPA_Partner_Segment__c = '';   
            for(String partnerSeg: partnerSegmentList){
              if(mapOfPartnerSegmentRole.containsKey(partnerSeg) && mapOfPartnerSegmentRole.get(partnerSeg).Size() == 1 && !inactiveACMPartnerrole.contains(mapOfPartnerSegmentRole.get(partnerSeg)[0])){
                acc.Core_IPA_Partner_Segment__c = acc.Core_IPA_Partner_Segment__c + ';' + partnerSeg;
              }else
                            if(mapOfPartnerSegmentRole.containsKey(partnerSeg) && mapOfPartnerSegmentRole.get(partnerSeg).Size() > 1){                              
                for(String role: mapOfPartnerSegmentRole.get(partnerSeg)){
                  if(mapOfInactiveAccPartnerRole.get(accId).contains(role) && !inactiveACMPartnerrole.contains(role)){
                                        if(String.isNotBlank(acc.Core_Account_Type__c))
                                            acc.Core_IPA_Partner_Segment__c = acc.Core_IPA_Partner_Segment__c +';' + partnerSeg;   
                                        else
                                            acc.Core_IPA_Partner_Segment__c = partnerSeg;                       
                  }
                  
                }
                            }        
                        }
                           
                        rolledUpAccountMap.put(acc.id, acc);   
                    }
                }
                
                //Added below Code as a Part of TWC729-1602 KIIT: Agate: Clear contact Partner role on membership inactivation - Vijay AGATE
                if(childAccId.size () > 0){
                    for(PRM_Account_Contact_Relationship__c acr : [Select Id,PRM_Account_Id__c,PRM_Contact_Id__c,PRM_Contact_Id__r.Core_IPA_PartnerRole__c, PRM_Partner_Role__c,PRM_InActive_Ind__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :childAccId]){
                        if(inactiveACMPartnerrole.contains(acr.PRM_Partner_Role__c) &&(inactiveACMAccId.contains(acr.PRM_Account_Id__c)) || (inactiveACMPartnerrole.contains(acr.PRM_Partner_Role__c) && acr.PRM_InActive_Ind__c == true)) {
                            //conPartRoleRemoveSet.add(acr.PRM_Contact_Id__c);
                            if(acr.PRM_Contact_Id__r.Core_IPA_PartnerRole__c != null){
                                Contact con = new Contact();
                                con.id = acr.PRM_Contact_Id__c;
                                con.Core_IPA_PartnerRole__c = ''; 
                                if(!contactsToUpdateList.contains(con)){
                                    contactsToUpdateList.add(con);  
                                }
                            }
                        }
                    }  
                }else If(inactiveACMAccId.size() > 0){
                    for(PRM_Account_Contact_Relationship__c acr : [Select Id,PRM_Account_Id__c,PRM_Contact_Id__c,PRM_Contact_Id__r.Core_IPA_PartnerRole__c,PRM_Partner_Role__c,PRM_InActive_Ind__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :inactiveACMAccId]){
                        if(inactiveACMPartnerrole.contains(acr.PRM_Partner_Role__c) &&(inactiveACMAccId.contains(acr.PRM_Account_Id__c)) || (inactiveACMPartnerrole.contains(acr.PRM_Partner_Role__c) && acr.PRM_InActive_Ind__c == true)) {
                            //conPartRoleRemoveSet.add(acr.PRM_Contact_Id__c);
                            if(acr.PRM_Contact_Id__r.Core_IPA_PartnerRole__c != null){
                                Contact con = new Contact();con.id = acr.PRM_Contact_Id__c;con.Core_IPA_PartnerRole__c = ''; 
                                if(!contactsToUpdateList.contains(con)){
                                    contactsToUpdateList.add(con);  
                                }
                            }
                        }
                    }  
                }
                
                /*
//Commenting below code for fixing SOQL issue TWC729-4591, added the logic above on existing ACR query
if(conPartRoleRemoveSet.size () > 0){
for(Contact con : [Select Id,name,Core_IPA_PartnerRole__c from Contact where id in: conPartRoleRemoveSet]){
if(con.Core_IPA_PartnerRole__c != null){
con.Core_IPA_PartnerRole__c = '';
if(!contactsToUpdateList.contains(con)){
contactsToUpdateList.add(con);  
}
}
}  
} */
                
                
                /*US759862 - END*/
                /*US775822 -UTKARSH - Inactive ASA on location account when ACM become inactive*/
                /*if(accountIds != null && !accountIds.IsEmpty() && (!ipaRefresh || test.isrunningtest())){ //Inactivating ASA from Child account //IPA2.0-TWC727-2861
                    for(PRM_Account_Specialty_Association__c asa :[Select Id,Name,PRM_Account_Id__c,PRM_Specialty_Id__c,PRM_Specialty_Id__r.Name,PRM_InActive_Ind__c,PRM_Partner_Role__c From PRM_Account_Specialty_Association__c Where PRM_Account_Id__c IN :accountIds]){
                        if(asa.PRM_Partner_Role__c == mapAcmPartnerRole.get(asa.PRM_Account_Id__c) && asa.PRM_InActive_Ind__c == false){asa.PRM_InActive_Ind__c = true;
                                                                                                                                        updateChildASA.add(asa);
                                                                                                                                       }
                    }
                }*/ // IPA Switch Removal
                
                /*US775822 - END*/
                if((accountIds != null && !accountIds.IsEmpty())){ //Fetching ABA records.
                    //Commenting below code for fixing SOQL issue TWC729-4591, used existing ACM query above to get ACM values
                    //for(PRM_AccountChannelMembership__c acm :[Select Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Account_Id__r.RecordTypeId,PRM_Status_Nm__c From PRM_AccountChannelMembership__c Where PRM_Account_Id__c IN :accountIds AND PRM_Status_Nm__c =:System.Label.PRM_Status]){
                    for(PRM_AccountChannelMembership__c acm: initialACMRecordList){ 
                        if(accountIds.contains(acm.PRM_Account_Id__c) && acm.PRM_Status_Nm__c ==System.Label.PRM_Status){
                            accPartnerSegment.add(acm.PRM_Account_Id__c);
                            activeACMPartnerRole.add(acm.PRM_Partner_Role__c);
                            mapRoleandTier.put(acm.PRM_Partner_Role__c,acm.PRM_Channel_Program_Level_Id__r.Name);
                        }
                    }
                }
                if((cpLevels != null && !cpLevels.IsEmpty()) && (channelPrograms != null && !channelPrograms.IsEmpty())){ //Fetching benefit matrix records.
                    for(PRM_VXBnftMatrix__c bm :[Select Id,PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,PRM_Partner_Role_Nm__c,PRM_Channel_Program_Level_Id__r.Name From PRM_VXBnftMatrix__c Where PRM_Channel_Program_Id__c IN :channelPrograms and PRM_Partner_Role_Nm__c != null and PRM_Channel_Program_Level_Id__r.Name != null ]){
                        if(activeACMPartnerRole != null && activeACMPartnerRole.contains(bm.PRM_Partner_Role_Nm__c)){
                            benefittier =  mapRoleandTier.get(bm.PRM_Partner_Role_Nm__c);
                            if(bm.PRM_Channel_Program_Level_Id__r.Name == benefittier){
                                activeACMPartnerRoleBenefits.add(bm.PRM_Partner_Benefit_Id__c);
                            }
                        }
                        //TWC729-5005below map will have benefits based on role and tier combination
                        if(mapPartnerTierBenefits.ContainsKey(bm.PRM_Partner_Role_Nm__c.toUpperCase()+'_'+bm.PRM_Channel_Program_Level_Id__r.Name.toUpperCase())){
                            // This Map will have parent , list of cag.
                            set<string> bnftIds = mapPartnerTierBenefits.get(bm.PRM_Partner_Role_Nm__c.toUpperCase()+'_'+bm.PRM_Channel_Program_Level_Id__r.Name.toUpperCase());
                            bnftIds.add(bm.PRM_Partner_Benefit_Id__c);
                            mapPartnerTierBenefits.put(bm.PRM_Partner_Role_Nm__c.toUpperCase()+'_'+bm.PRM_Channel_Program_Level_Id__r.Name.toUpperCase(), bnftIds);
                        }
                        else{
                            mapPartnerTierBenefits.put(bm.PRM_Partner_Role_Nm__c.toUpperCase()+'_'+bm.PRM_Channel_Program_Level_Id__r.Name.toUpperCase(),new set<string>{bm.PRM_Partner_Benefit_Id__c}) ;
                        }  //TWC729-5005                                     
                    }                     
                  
                     // the below map will make sure that higher tier has all the benefits of lower tier
                  
                     for( string roleTier :    mapPartnerTierBenefits.keySet()){
                        String role = roleTier.split('_')[0];
                        String tier = roleTier.split('_')[1];
                        if(tier == 'MEMBER' ){
                            

                            if(mapPartnerTierBenefits.containsKey(role+'_'+'GOLD')){
                                mapPartnerTierBenefits.get(role+'_'+'GOLD').addall(mapPartnerTierBenefits.get(roleTier));
                            }
                            if(mapPartnerTierBenefits.containsKey(role+'_'+'TITANIUM')){
                                mapPartnerTierBenefits.get(role+'_'+'TITANIUM').addall(mapPartnerTierBenefits.get(roleTier));
                            }
                        }
                        if(tier == 'GOLD' ){
                           
                            if(mapPartnerTierBenefits.containsKey(role+'_'+'TITANIUM')){
                                mapPartnerTierBenefits.get(role+'_'+'TITANIUM').addall(mapPartnerTierBenefits.get(roleTier));
                            }
                        }
                        

                     }  
                }
                //TWC729-5005
                //Iterating over OPID to get all the eligible benefits for the OPID even though one of it's acm is inactive
                for(id opidId : mapOpidLoc.keyset()){
                    for(PRM_AccountChannelMembership__c acmList1 : mapOpidLoc.get(opidId)){

                        if(mapOpidEligBenefits.keyset().contains(acmList1.PRM_Account_Id__c)){
                            // This Map will have parent , list of cag.
                            set<string> bnftIds = mapOpidEligBenefits.get(acmList1.PRM_Account_Id__c);bnftIds.addall(mapPartnerTierBenefits.get(acmList1.PRM_Partner_Role__c.toUpperCase()+'_'+acmList1.PRM_Channel_Program_Level_Id__r.Name.toUpperCase()));
                            mapOpidEligBenefits.put(acmList1.PRM_Account_Id__c, bnftIds);
                        }
                        else{
                            mapOpidEligBenefits.put(acmList1.PRM_Account_Id__c,mapPartnerTierBenefits.get(acmList1.PRM_Partner_Role__c.toUpperCase()+'_'+acmList1.PRM_Channel_Program_Level_Id__r.Name.toUpperCase() )) ;
                        }  //TWC729-5005   

                    }
                }
                
                //TWC729-5005 

                if((accountIds != null && !accountIds.IsEmpty()) && (activeACMPartnerRoleBenefits != null && !activeACMPartnerRoleBenefits.IsEmpty())){ //Fetching ABA records.
                    for(PRM_AccountBenefitAssociation__c aba : [Select Id,Name,PRM_Account_Id__c,PRM_Partner_Benefit_Id__c,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c From PRM_AccountBenefitAssociation__c Where PRM_Account_Id__c IN :accountIds AND PRM_Partner_Benefit_Id__c IN :activeACMPartnerRoleBenefits]){existingABA.add(aba.PRM_Partner_Benefit_Id__c);
                                                                                                                                                                                                                                                                                                                  }
                }
                
                if((partnerRole != null && !partnerRole.IsEmpty()) && (channelPrograms != null && !channelPrograms.IsEmpty())){ //Fetching benefit matrix records.
                    for(PRM_VXBnftMatrix__c bm :[Select Id,PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c From PRM_VXBnftMatrix__c Where PRM_Channel_Program_Level_Id__r.Name IN :cpl AND PRM_Channel_Program_Id__c IN :channelPrograms AND PRM_Partner_Role_Nm__c IN :partnerRole]){
                        if(!existingABA.contains(bm.PRM_Partner_Benefit_Id__c)){
                            automaticBenefits.add(bm.PRM_Partner_Benefit_Id__c);
                        }
                    }
                }
                
                if((accountIds != null && !accountIds.IsEmpty()) && (automaticBenefits != null && !automaticBenefits.IsEmpty())){ //Fetching ABA records.
                    for(PRM_AccountBenefitAssociation__c aba : [Select Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Segment__c,PRM_Account_Id__r.RecordType.Name  ,PRM_Account_Id__r.Core_IPA_Badge_Tier__c,PRM_Partner_Benefit_Id__c,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c,PRM_Source__c From PRM_AccountBenefitAssociation__c Where (PRM_Account_Id__c IN :accountIds or PRM_Account_Id__c IN :inactiveACMAccId) AND PRM_Partner_Benefit_Id__c IN :automaticBenefits]){ //TWC729-5005                                                                    
                        
                        if(aba.PRM_Source__c != System.Label.PRM_ProgramLevel || (aba.PRM_Source__c == System.Label.PRM_ProgramLevel && aba.PRM_Status_Nm__c == 'Active') ){ // TWC729-5005 - Condition will only Inactivate those benefits that are already active. DML would be saved if not required. 

                            if(mapOpidEligBenefits == null){
                                

                            }
                                                     




                            if(aba.PRM_Source__c == System.Label.PRM_ProgramLevel && (aba.PRM_Account_Id__r.RecordType.Name != 'Partner Account Group' || mapOpidEligBenefits.isEmpty() || (aba.PRM_Account_Id__r.RecordType.Name == 'Partner Account Group' && mapOpidEligBenefits.containskey(aba.PRM_Account_Id__c) && !mapOpidEligBenefits.get(aba.PRM_Account_Id__c).contains(aba.PRM_Partner_Benefit_Id__c) ) )){ //TWC729-5005
                                aba.PRM_Source__c='';
                                aba.PRM_Status_Nm__c = System.Label.PRM_Status_Inactive;
                                aba.PRM_Status_Reason_Txt__c = System.Label.PRM_ABA_Status_Reason;
                                // making values null
                                // aba.PRM_Account_Id__r.Core_IPA_Partner_Segment__c='';
                                // aba.PRM_Account_Id__r.Core_IPA_Badge_Tier__c='';
                            }else{aba.PRM_Source__c= System.Label.PRM_Source_Specialty;
                                }
                            
                            //aba.PRM_Status_Nm__c = System.Label.PRM_Status_Inactive;
                            //aba.PRM_Status_Reason_Txt__c = System.Label.PRM_ABA_Status_Reason;
                                updateABAList.add(aba);

                      } // TWC729-5005
                        
                        
                    }
                }
                if(accountIds != null && !accountIds.IsEmpty()){
                    for(PRM_Account_Contact_Relationship__c acrList : [Select id, name, PRM_Account_Id__c, PRM_Contact_Id__c,PRM_Partner_Role__c,PRM_InActive_Ind__c,PRM_Status_Reason_Txt__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c IN :accountIds AND PRM_Partner_Role__c IN :partnerRole]){
                        contactIds.add(acrList.PRM_Contact_Id__c);
                        /*US808806 -UTKARSH - inactivate ACR when ACM become inactive*/
                        if(acrList.PRM_InActive_Ind__c == false){
                            acrList.PRM_InActive_Ind__c = true;
                            acrList.PRM_Status_Reason_Txt__c = System.Label.PRM_ACR_Status_Reason;
                            inactiveACRIdList.add(acrList);
                        }
                        /*US808806 - END*/
                    }
                }
                
                //Deactivating CSA records.
                if(contactIds != null && !contactIds.IsEmpty()){
                    for(PRM_ContactSubscriptionAssociation__c csa : [Select id , name, PRM_Contact_Id__c, PRM_Status_Nm__c,PRM_Status_Reason_Txt__c from PRM_ContactSubscriptionAssociation__c where PRM_Contact_Id__c IN :contactIds]){
                        csa.PRM_Status_Nm__c = System.Label.PRM_Status_Inactive;
                        csa.PRM_Status_Reason_Txt__c = 'Contact Subscription inactivated as part of membership inactivation.';//TWC729-8089 : Adding reason text : NJ
                        csaList.add(csa);
                    }
                }
                
                /*US775822 -UTKARSH - Update partner segment on location account when ACM become inactive*/
                if(accountIds != null && !accountIds.IsEmpty()){
                    //Commenting below code for fixing SOQL issue TWC729-4591, used existing ACM query above to get Account values
                    for(Account acc : [Select Id , Core_IPA_Partner_Segment__c from Account where Id IN :accountIds]){
                    //for(Id accId: accountIds){
                      //  Account acc = allInitialAccMap.get(accId);
                        if(acc != null && !accPartnerSegment.contains(acc.Id)){
                            //acrAccId.add(acc.Id);
                            if(acc.Core_IPA_Partner_Segment__c != null){acc.Core_IPA_Partner_Segment__c = '';
                                                                        if(!rolledUpAccountMap.containsKey(acc.id))                                                                            
                                                                            updateLocationAcc.add(acc);
                                                                       }
                        }
                    }
                    /*US808806 -UTKARSH - inactivate all ACRs when last ACM become inactive*/
                    /*
for(PRM_Account_Contact_Relationship__c acrList : [Select id, name, PRM_Account_Id__c, PRM_Contact_Id__c,PRM_Partner_Role__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c IN :acrAccId]){
acrList.PRM_InActive_Ind__c = true;
inactiveACRIdList.add(acrList);
}*/
                }
                //rolledUpAccountList contains OPID and Location account
                updateLocationAcc.addAll(rolledUpAccountMap.values());
                
                //inactiveAllACRIdList = new List<PRM_Account_Contact_Relationship__c>(inactiveACRIdList);
                
                /*US808806 - END*/
                
                if(updateLocationAcc != null && !updateLocationAcc.IsEmpty()){if(!System.isBatch()){Schema.SObjectType acc = Schema.Account.getSObjectType();
                                                                                                    System.enqueueJob(new ContactERPMIntegrationStatusHandler(updateLocationAcc,acc));
                                                                                                   }
                                                                              else if(System.isBatch()){update updateLocationAcc;
                                                                                                       }
                                                                              
                                                                             }
                /*US775822 - END*/
            }
            /*END -condition-4*/
            /*Start - condition-5, Developer - TEJA*/
            if((Test.isRunningTest() || trigger.Isupdate || trigger.IsInsert ) && (activeIPAAccount==TRUE)){
                
                if(acmActiveAccountIDset!=null && !acmActiveAccountIDset.IsEmpty()){
                    
                    Map<String, Integer> mapProgramToPriority = new Map<String, Integer>{
                        'Titanium' => 3,
                        'Gold' => 2,
                        'Member' => 1
                    };
                    for(PRM_AccountChannelMembership__c acm :[SELECT Id,PRM_Account_Id__c,PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c,PRM_Channel_Program_Level_Id__r.Name from PRM_AccountChannelMembership__c where PRM_Account_Id__c IN :acmActiveAccountIDset and PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c=false]){
                        
                        if(mapAccountsToUpdate.containsKey(acm.PRM_Account_Id__c)){
                            if(mapProgramToPriority.get(acm.PRM_Channel_Program_Level_Id__r.Name) > mapProgramToPriority.get(mapAccountsToUpdate.get(acm.PRM_Account_Id__c).Core_IPA_Badge_Tier__c )){
                                mapAccountsToUpdate.get(acm.PRM_Account_Id__c).Core_IPA_Badge_Tier__c = acm.PRM_Channel_Program_Level_Id__r.Name;
                            }
                        }else{
                                Account acc= new account();
                                acc.id=acm.PRM_Account_Id__c;
                                acc.Core_IPA_Badge_Tier__c = acm.PRM_Channel_Program_Level_Id__r.Name;
                                acc.Core_Intel_Partner_Alliance_PartnerGroup__c=TRUE;
                                mapAccountsToUpdate.put(acc.id, acc);
                        
                        }  
                    }
                    
                }
                if(accountIPAActive != null && !accountIPAActive.IsEmpty()){
                    if(!System.isBatch()){
                        Schema.SObjectType acc = Schema.Account.getSObjectType();
                        System.enqueueJob(new ContactERPMIntegrationStatusHandler(mapAccountsToUpdate.values(),acc));
                    }
                    else if(System.isBatch()){
                        update mapAccountsToUpdate.values();
                    }
                    
                }
                /*US808806 - UTKARSH - activate ACR when ACM become active*/
                /*commenting reactivation of ACR logic since admin will reactivate ACR manualy.
if((acmActiveAccountIDset != null && !acmActiveAccountIDset.IsEmpty()) && (activeACMPR != null && !activeACMPR.IsEmpty())){
for(PRM_Account_Contact_Relationship__c acr : [Select id, name, PRM_Account_Id__c, PRM_Contact_Id__c,PRM_Partner_Role__c,PRM_InActive_Ind__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c IN :acmActiveAccountIDset AND PRM_Partner_Role__c IN :activeACMPR]){
if(acr.PRM_InActive_Ind__c == true){
acr.PRM_InActive_Ind__c = false;
activeACRIdList.add(acr);
}
}
}*/
                /*US808806 - END*/
            }
            /*END -condition-5*/
            try{
                Database.SaveResult[] result;
                if((updateABAList != null && !updateABAList.IsEmpty()) && !System.isBatch()){
                    //To skip the MP benefit validation
                    PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits = true;
                    update updateABAList;
                }
                if(csaList != null && !csaList.IsEmpty()){update csaList;
                                                         }
                if(inactiveACRIdList != null && !inactiveACRIdList.IsEmpty()){update inactiveACRIdList;
                                                                             }
                /*if(activeACRIdList != null && !activeACRIdList.IsEmpty()){update activeACRIdList;
}
if(inactiveAllACRIdList != null && !inactiveAllACRIdList.IsEmpty()){update inactiveAllACRIdList;
}*/
                if((updateOPIDACM != null && !updateOPIDACM.IsEmpty()) || Test.isRunningTest()){
                    PRM_ACM_TriggerHandler.firstRun = true;
                    result= Database.update(updateOPIDACM,false);
                    
                    set<string> setOfOpidACM = new set<string>(); 
                    string resACMId;
                    Set<Id> resAccSet = new Set<Id>();
                    if(result != null && !result.isEmpty()){
                        for(Database.SaveResult sr : result){
                            
                            if(sr.isSuccess()){
                                
                                resACMId = sr.getId();
                                if(resACMId != null && resACMId !=''){
                                    setOfOpidACM.add(resACMId);  
                                }
                            }
                        }  
                    }
                    
                    for(PRM_AccountChannelMembership__c acm :[Select Id,PRM_Account_Id__c,PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c from PRM_AccountChannelMembership__c where Id IN: setOfOpidACM]){
                        resAccSet.add(acm.PRM_Account_Id__c);
                    }    
                    
                    if(resAccSet != null && !resAccSet.IsEmpty()){
                        for(PRM_AccountChannelMembership__c acm: [Select Id, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Badge_Tier__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c IN:resAccSet and PRM_Status_Nm__c = :System.label.PRM_Status]){
                            resmapOfAccIdBadgeTier.put(acm.PRM_Account_Id__c, acm.PRM_Account_Id__r.Core_IPA_Badge_Tier__c);
                            if(resmapOfAccACMsList.containsKey(acm.PRM_Account_Id__c)){resaccACMsList = resmapOfAccACMsList.get(acm.PRM_Account_Id__c);
                                                                                      }else{resaccACMsList = new List<PRM_AccountChannelMembership__c>();
                                                                                           }
                            resaccACMsList.add(acm);
                            resmapOfAccACMsList.put(acm.PRM_Account_Id__c,resaccACMsList);
                        }
                    }
                    if(ProgramTierRankingMap != null && !ProgramTierRankingMap.IsEmpty()){
                        for(String bageMapping :ProgramTierRankingMap.keyset()){
                            resmapOfBadgeNameTier.put(bageMapping, ProgramTierRankingMap.get(bageMapping));            
                        }
                    }
                    
                    if(resAccSet != null && !resAccSet.IsEmpty()){
                        for(Id accId: resAccSet){
                            if(!resmapOfAccACMsList.containskey(accId)){
                                Account acc = new Account();
                                acc.Core_IPA_Badge_Tier__c = '';
                                acc.Id = accId;
                                
                                if(!resaccsToUpdate.contains(acc)){resaccsToUpdate.add(acc);
                                                                  }
                            }                    
                        }
                    }
                    
                    if(resmapOfAccACMsList != null && !resmapOfAccACMsList.IsEmpty()){
                        for(Id accId: resmapOfAccACMsList.keyset()){resaccACMsList = resmapOfAccACMsList.get(accId);
                                                                    reshighestTier = resmapOfAccIdBadgeTier.get(accId);
                                                                    if(resaccACMsList == null || resaccACMsList.isEmpty()){Account acc = new Account();
                                                                                                                           acc.Core_IPA_Badge_Tier__c = '';
                                                                                                                           acc.Id = accId;
                                                                                                                           if(!resaccsToUpdate.contains(acc)){resaccsToUpdate.add(acc);
                                                                                                                                                             } 
                                                                                                                          }
                                                                    for(PRM_AccountChannelMembership__c acm: resaccACMsList){if(resmapOfBadgeNameTier.get(reshighestTier) > resmapOfBadgeNameTier.get(acm.PRM_Channel_Program_Level_Id__r.Name)){Account acc = new Account();
                                                                                                                                                                                                                                                 acc.Core_IPA_Badge_Tier__c = acm.PRM_Channel_Program_Level_Id__r.Name;
                                                                                                                                                                                                                                                 acc.Id = acm.PRM_Account_Id__c;
                                                                                                                                                                                                                                                 if(!resaccsToUpdate.contains(acc)){resaccsToUpdate.add(acc);
                                                                                                                                                                                                                                                                                   }                            
                                                                                                                                                                                                                                                }
                                                                                                                            }
                                                                   }
                        
                    }
                    if(resaccsToUpdate != null && !resaccsToUpdate.IsEmpty()){
                        if(!System.isBatch()){
                            Schema.SObjectType acc = Schema.Account.getSObjectType();
                            System.enqueueJob(new ContactERPMIntegrationStatusHandler(resaccsToUpdate,acc));
                        }
                        else if(System.isBatch()){update resaccsToUpdate;
                                                 }
                    }
                }
                if(updateChildASA != null && !updateChildASA.IsEmpty()){update updateChildASA;
                                                                       }
                if(contactsToUpdateList.size() > 0){
                    if(!System.isBatch()){
                        
                        Schema.SObjectType con = Schema.Contact.getSObjectType();
                        System.enqueueJob(new ContactERPMIntegrationStatusHandler(contactsToUpdateList,con));  
                    }                                    
                }
            }catch(Exception e){Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',e);            
                                
                               }
        }
    }
    
    //Added by Vijay(Agate Team) as a part Suppress Email functionality from Userstory TWC729-174  
    public static void suppressEmail(List<PRM_AccountChannelMembership__c> acmList){
        //Map<Id,String> conIdConEmailMap = new Map<Id,String>();
        List<PRM_Email_Handler__c> emailHandlerRecordsToInsert= new List<PRM_Email_Handler__c>();
        Set<Id>acmAccountIdSet = new Set<Id>();
        String acmPartnerrolestring ='';
        //Set<Id>contactId = new Set<Id>();
        Set<Id>intelAccountIds = new Set<Id>();
        List<Core_Account_Group_Member__c > pagMemberList = New List<Core_Account_Group_Member__c >();
        
        for(PRM_AccountChannelMembership__c acm : acmList){
            if(acm.PRM_Suppress_Email__c == true){
                acmAccountIdSet.add(acm.PRM_Account_Id__c);      
                
                if(acmPartnerrolestring != null){
                    acmPartnerrolestring =  acmPartnerrolestring + ';'  + acm.PRM_Partner_Role__c ;
                }else{acmPartnerrolestring = acm.PRM_Partner_Role__c;
                     }
                acmPartnerrolestring = acmPartnerrolestring.removeEnd(';');
            }
        }
        
        if(acmAccountIdSet !=null && !acmAccountIdSet.isEmpty()){
            pagMemberList = [SELECT id, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c from Core_Account_Group_Member__c where 
                             Core_Partner_Account_Id__c IN :acmAccountIdSet];
        }
        
        
        for(Core_Account_Group_Member__c mem : pagMemberList){
            intelAccountIds.add(mem.Core_Intel_Account_Id__c);
        }
        
        System.debug('acmPartnerrolestring=' + acmPartnerrolestring);
        if((intelAccountIds != null && !intelAccountIds.IsEmpty()) && (acmPartnerrolestring != null)){
            for(PRM_Account_Contact_Relationship__c accCon : [Select PRM_Account_Id__c,PRM_Contact_Id__c, PRM_Contact_Id__r.email,PRM_Partner_Role__c,PRM_Contact_Id__r.Core_IPA_PartnerRole__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :intelAccountIds and PRM_Relationship_Id__r.name=:System.Label.PRM_Primary_Contact AND PRM_InActive_Ind__c = false AND PRM_Status_Nm__c =:System.Label.PRM_ACR_Status]){
                if(accCon.PRM_Contact_Id__r.Core_IPA_PartnerRole__c != null){
                    if(acmPartnerrolestring.containsAny(accCon.PRM_Contact_Id__r.Core_IPA_PartnerRole__c)){
                        //contactId.add(accCon.PRM_Contact_Id__c);
                        PRM_Email_Handler__c emailHandler = new PRM_Email_Handler__c();
                        emailHandler.PRM_Contact__c =accCon.PRM_Contact_Id__c;                
                        emailHandler.PRM_Event__c = 'Upgrade Request';
                        emailHandler.PRM_Email_Handler_Status__c = 'Requested For Suppression';
                        emailHandler.PRM_Suppress_Email__c = true;
                        emailHandlerRecordsToInsert.add(emailHandler);                       
                    }
                }                
            }
        }
        if(emailHandlerRecordsToInsert!=null && !emailHandlerRecordsToInsert.isEmpty()){
            insert emailHandlerRecordsToInsert;
        }
    }
    
    public static void updateSuppressEmail(List<PRM_AccountChannelMembership__c> asaList,Map<Id,PRM_AccountChannelMembership__c> oldMap){
        for(PRM_AccountChannelMembership__c acm :asaList){
            PRM_AccountChannelMembership__c acmOld ; 
            if(oldMap!=null && !oldMap.isEmpty()) {
                acmOld = (PRM_AccountChannelMembership__c) oldMap.get(acm.id) ;
            }
            if(acmOld != null && (acmOld.PRM_Status_Nm__c == 'Approved' && (acm.PRM_Status_Nm__c == 'Pending'||acm.PRM_Status_Nm__c == 'Inactive')) && acmOld.PRM_Suppress_Email__c==true)
            {
                acm.PRM_Suppress_Email__c =false;
            }
        }
    }
    //Deactivated workflow rule PRM_Channel_Program_Level_Status_Change which updates the status change date on ACM
    //It was causing ACM trigger execution increasing SOQL count per transaction   
    public static void updateACMStatusChangeDate(List<PRM_AccountChannelMembership__c> acmNewList, Map<Id, PRM_AccountChannelMembership__c> acmOldMap){
        for(PRM_AccountChannelMembership__c acm: acmNewList){
            if((acmOldMap.containsKey(acm.id) && acm.PRM_Status_Nm__c != acmOldMap.get(acm.id).PRM_Status_Nm__c) || 
               (acmOldMap.containsKey(acm.id) && acm.PRM_Channel_Program_Level_Id__c != acmOldMap.get(acm.id).PRM_Channel_Program_Level_Id__c)){
                   acm.PRM_Status_Change_Dt__c = System.now();
               }    
        }
        
    }
  
  public static void createTrackerMilestonesForMembershipUpdate(List<PRM_AccountChannelMembership__c> acms, Map<Id,PRM_AccountChannelMembership__c> oldAcmMap) {
        List<PRM_Tracker__c> trackers = new List<PRM_Tracker__c>();
        Core_CustomMetadataObjectController customMetadata = new Core_CustomMetadataObjectController('PRM_Tracker_steps__mdt');
        for (PRM_AccountChannelMembership__c acm: acms) {
            if ((acm.PRM_Channel_Program_Level_Id__c != oldAcmMap.get(acm.Id).PRM_Channel_Program_Level_Id__c ||
            acm.PRM_Partner_Role__c != oldAcmMap.get(acm.Id).PRM_Partner_Role__c) 
            && acm.PRM_Account_RT__c == 'Mastered_Account') {
                
                trackers.add(PRM_IPA_Utility.createTrackerInstance('OPID Updates',
                'MEM_UPDATED_LOC',
                null,
                acm.PRM_Account_Id__c,
                acm.PRM_Onepartner_Id__c,
                acm.PRM_Onepartner_Id__c,
                acm.PRM_Partner_Role__c,
                acm.PRM_Tier_Name_txt__c,
                true,
                '',
                '',
                String.valueOf(customMetadata.getInstance('MEM_UPDATED_LOC').get('PRM_Milestone_Display_Name__c'))
                ));
            }
            
            if ((acm.PRM_Channel_Program_Level_Id__c != oldAcmMap.get(acm.Id).PRM_Channel_Program_Level_Id__c ||
            acm.PRM_Partner_Role__c != oldAcmMap.get(acm.Id).PRM_Partner_Role__c) &&
            acm.PRM_Account_RT__c == 'Core_Partner_Account_Group') {
                
                trackers.add(PRM_IPA_Utility.createTrackerInstance('OPID Updates 1PID',
                'MEM_UPDATED_1PID',
                null,
                null,
                acm.PRM_Account_Id__c,
                acm.PRM_Account_Id__c,
                acm.PRM_Partner_Role__c,
                acm.PRM_Tier_Name_txt__c,
                true,
                '',
                '',
                String.valueOf(customMetadata.getInstance('MEM_UPDATED_1PID').get('PRM_Milestone_Display_Name__c'))
                ));
            }
        }

        if (!trackers.isEmpty()) {
            insert trackers;
        }
    }
    private static Map<String, List<String>> getPartnerSegmentPartnerRoleMapping(){
      Map<String, List<String>> mapOfPartnerSegmentRole =  new Map<String, List<String>>();
        for(PRM_PartnerRoleTypeMappings__mdt segRoleTypeRec: [Select id, PRM_Partner_Role__c, PRM_Partner_Segment__c from PRM_PartnerRoleTypeMappings__mdt where PRM_Partner_Segment__c != null]){
          if(mapOfPartnerSegmentRole.containsKey(segRoleTypeRec.PRM_Partner_Segment__c))
              mapOfPartnerSegmentRole.get(segRoleTypeRec.PRM_Partner_Segment__c).add(segRoleTypeRec.PRM_Partner_Role__c);
            else{
                List<String> roleList = new List<String>();
                roleList.add(segRoleTypeRec.PRM_Partner_Role__c);
                mapOfPartnerSegmentRole.put(segRoleTypeRec.PRM_Partner_Segment__c, roleList);
            }
        }
        return mapOfPartnerSegmentRole;    
    }
}