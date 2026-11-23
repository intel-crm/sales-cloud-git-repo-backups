/****************************************************************************************************************************************
* Class Name  : Core_MDF_ManualSharing  
* Version     : 1.0 
* Created Date: 4-25-2018 
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Krishna Kulkarni       04/25/2018          Class to create Share records.
*****************************************************************************************************************************************/
public without sharing class Core_MDF_ManualSharing {    

    public static Map<String,String> mapOfClaimActAllocRecTypeMetadata = new Map<String,String>();
    public static Map<String,Boolean> mapOfProgGeoSharingReq = new Map<String,Boolean>();
   
    //Assign all record type meta data
    static{
        mapOfClaimActAllocRecTypeMetadata = fetchClaimActAllocRecType();
        mapOfProgGeoSharingReq = fetchProgForGeoBasedSharing();
    }
   /***************************************************************************************************** 
        Method Name:        sharingAccountUser
        @return  :          void
        @parameters:        accountUserList - This will contain all the accountUser List to be shared 
        Description:        Whenever a record is created/updated of Account User, this method shares the account user to the Internal Managers 
                            according the Account on which the Account user is created
        @Added By:          Accenture - VD - 30-10-2019
        Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void sharingAccountUser(List<Core_MDF_Partner_Node_User_Mapping__c> accountUserList){
        
        // Account & Channel Program To Group Ids Map
        Map<String,List<id>> accountChannelProgramToGroupIdsMap = new Map <String,List<Id>>();
        
        // Account,Channel Program & Region To Group Ids Map- Accn VD
        Map<String,List<id>> accountChannelProgramRegionToGroupIdsMap = new Map<String,List<id>>();
        
        // Account,Channel Program, Region & SubRegion To Group Ids Map- Accn VD
        Map<String,List<id>> accountChannelProgramRegionSubRegionToGroupIdsMap = new Map<String,List<id>>();
        
        // Record Id To Group Id Map
        Map<Id,List<Id>> recordIdToGrpIdMap = new Map<Id,List<Id>>();
        
        //Getting Core_MDF_Partner_Group_Mapping__c Access Type from Custom Label   
        String accountUserSharePGMType = System.Label.Core_MDF_AccountUserShare_PGM_Type; 
        
        //Getting the type of access to which we want to share the account user records
        List<String> typeOfAccess = accountUserSharePGMType.split(',');     
        
        //Getting all the account ids from Account User list - Accenture VD
        List<Id> accountIds = new List<Id>();
        
        //Set of virtual account's ultimate account - Accenture VD
        Set<Id> setOfUltimateAccountIds = new Set<Id>();
        
        //Set of virtual account's program - Accenture VD
        Set<Id> setOfProgramIds = new Set<Id>();
        
        //Map of account id and account - Accenture VD
        Map<Id,Account> accountIdToAccountMap = new Map<Id,Account>();
        
        //To share record on the basis of Channel Program and geo 
        List<Core_MDF_RecordGeoShare> recordGeoShareList= new List<Core_MDF_RecordGeoShare>();
        
        //To store program ids
        List<Id> programIds = new List<Id>();
        
        
        try{
            for(Core_MDF_Partner_Node_User_Mapping__c accountUser: accountUserList){
                accountIds.add(accountUser.Core_MDF_Account__c);
            }
            
            for (Account acc: [Select Id,Core_Geo__c,Core_Sub_Geo__c, Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Name, Core_MDF_CoMarketing_Ultimate_Account__c from Account where id IN :accountIds]) {
                //Storing ultimate accounts
                setOfUltimateAccountIds.add(acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                //Storing program ids
                setOfProgramIds.add(acc.Core_MDF_Channel_Program__c);
                accountIdToAccountMap.put(acc.Id,acc);
                programIds.add(acc.Core_MDF_Channel_Program__c);
            }
            
            if(setOfUltimateAccountIds!=NULL && setOfUltimateAccountIds.size()>0 && setOfProgramIds!=NULL && setOfProgramIds.size()>0){
                for (Core_MDF_Partner_Group_Mapping__c pgm: [Select Id, Core_MDF_Account__c,Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c, Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Group_Id__c,Core_MDF_Type_of_Access__c,Core_MDF_Group_Name__c 
                                                             from Core_MDF_Partner_Group_Mapping__c where Core_MDF_Account__c IN :setOfUltimateAccountIds 
                                                             AND Core_MDF_Channel_Program__c IN :setOfProgramIds AND Core_MDF_Type_of_Access__c IN :typeOfAccess]) 
                {
                    if(pgm.Core_MDF_Region_cd__c!= Null && pgm.Core_MDF_Sub_Region_cd__c != NULL){
                        String accountIdProgramIdGeoSubGeo = pgm.Core_MDF_Account__c + '_' + pgm.Core_MDF_Channel_Program__c + '_' + pgm.Core_MDF_Region_cd__c+ '_' +pgm.Core_MDF_Sub_Region_cd__c;
                        if (accountChannelProgramRegionSubRegionToGroupIdsMap.containsKey(accountIdProgramIdGeoSubGeo)) {
                            accountChannelProgramRegionSubRegionToGroupIdsMap.get(accountIdProgramIdGeoSubGeo).add(pgm.Core_MDF_Group_Id__c);
                        } else {
                            accountChannelProgramRegionSubRegionToGroupIdsMap.put(accountIdProgramIdGeoSubGeo, new List <String>{pgm.Core_MDF_Group_Id__c});
                        }
                    }else if(pgm.Core_MDF_Region_cd__c!= Null){
                        String accountIdProgramIdGeo = pgm.Core_MDF_Account__c + '_' + pgm.Core_MDF_Channel_Program__c+'_' + pgm.Core_MDF_Region_cd__c;
                        if (accountChannelProgramRegionToGroupIdsMap.containsKey(accountIdProgramIdGeo)) {
                            accountChannelProgramRegionToGroupIdsMap.get(accountIdProgramIdGeo).add(pgm.Core_MDF_Group_Id__c);
                        } else {
                            accountChannelProgramRegionToGroupIdsMap.put(accountIdProgramIdGeo, new List <String>{pgm.Core_MDF_Group_Id__c});
                        }
                    }
                    if(mapOfProgGeoSharingReq!=null && mapOfProgGeoSharingReq.containsKey(pgm.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c) && ((mapOfProgGeoSharingReq.get(pgm.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c) && pgm.Core_MDF_Type_of_Access__c.equals(System.Label.Core_MDF_External)) || !mapOfProgGeoSharingReq.get(pgm.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c))) {
                        String accountIdProgramId = pgm.Core_MDF_Account__c + '_' + pgm.Core_MDF_Channel_Program__c;
                        if (accountChannelProgramToGroupIdsMap.containsKey(accountIdProgramId)) {
                            accountChannelProgramToGroupIdsMap.get(accountIdProgramId).add(pgm.Core_MDF_Group_Id__c);
                        }else {
                            accountChannelProgramToGroupIdsMap.put(accountIdProgramId, new List <String>{pgm.Core_MDF_Group_Id__c});
                        }
                    }
                }
            }
            
            for (Core_MDF_Partner_Node_User_Mapping__c accountUser: accountUserList) {
                Account account = accountIdToAccountMap.get(accountUser.Core_MDF_Account__c);
                List<id> grpIds = new List<id>();
                // mapOfProgGeoSharingReq to check if Geo based Sharing is required
                if(mapOfProgGeoSharingReq!=null && mapOfProgGeoSharingReq.containsKey(account.Core_MDF_Channel_Program__r.Name) && mapOfProgGeoSharingReq.get(account.Core_MDF_Channel_Program__r.Name))
                {
                    // mapOfClaimActAllocRecTypeMetadata to check if SubGeo based sharing is required
                   if(mapOfClaimActAllocRecTypeMetadata!=null && mapOfClaimActAllocRecTypeMetadata.containsKey(account.Core_MDF_Channel_Program__r.Name) && mapOfClaimActAllocRecTypeMetadata.get(account.Core_MDF_Channel_Program__r.Name).contains(account.Core_Geo__c)){
                       String mapKey = account.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+account.Core_MDF_Channel_Program__c+'_'+account.Core_Geo__c+'_'+account.Core_Sub_Geo__c;
                       if(accountChannelProgramRegionSubRegionToGroupIdsMap.containsKey(mapKey)){
                            
                           grpIds = accountChannelProgramRegionSubRegionToGroupIdsMap.get(mapKey);
                       }
                       if(grpIds!=NULL && grpIds.size()>0){
                           if (recordIdToGrpIdMap.containsKey(accountUser.Id)) {
                                recordIdToGrpIdMap.get(accountUser.Id).addAll(grpIds);
                           } else {
                               recordIdToGrpIdMap.put(accountUser.Id,grpIds);
                           }
                       }
                   }
                   else{
                       String mapKey = account.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+account.Core_MDF_Channel_Program__c+'_'+account.Core_Geo__c;
                       if(accountChannelProgramRegionToGroupIdsMap.containsKey(mapKey)){
                           grpIds = accountChannelProgramRegionToGroupIdsMap.get(mapKey);
                       }
                       if(grpIds!=NULL && grpIds.size()>0){
                           if (recordIdToGrpIdMap.containsKey(accountUser.Id)) {
                               recordIdToGrpIdMap.get(accountUser.Id).addAll(grpIds);
                           } else {
                               recordIdToGrpIdMap.put(accountUser.Id,grpIds);
                           }
                       }
                   }
                }
                
                // Sharing for programs where Geo based sharing is not required eg CCF/DCF/SPCF/CCFB
                String mapKey = account.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+account.Core_MDF_Channel_Program__c;
                if(accountChannelProgramToGroupIdsMap.containsKey(mapKey)){
                    grpIds = accountChannelProgramToGroupIdsMap.get(mapKey);
                }
                if(grpIds!=NULL && grpIds.size()>0){
                    if (recordIdToGrpIdMap.containsKey(accountUser.Id)) {
                        recordIdToGrpIdMap.get(accountUser.Id).addAll(grpIds);
                    } else {
                        recordIdToGrpIdMap.put(accountUser.Id,grpIds);
                    }
                }
                
                //To share record on the basis of Channel Program and geo 
                recordGeoShareList.add(new Core_MDF_RecordGeoShare(accountUser.Id,account.Core_Geo__c,account.Core_Sub_Geo__c,account.Core_MDF_Channel_Program__r.Name));
            }
            //To share record on the basis of Channel Program and geo 
            if(recordGeoShareList != null && recordGeoShareList.size() >0){
                Core_MDF_ShareRecordToGeoGroup.shareRecordToGeoGroup('Core_MDF_Partner_Node_User_Mapping__c',recordGeoShareList);
            }
            //To share account user records with internal geo groups
            if(recordIdToGrpIdMap != null && recordIdToGrpIdMap.size() > 0){
               Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Partner_Node_User_Mapping__c',recordIdToGrpIdMap, 'Edit');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);            
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    /***************************************************************************************************** 
        Method Name:        sharingAccountTransfer
        @return  :          void
        @parameters:        accountTransferList - This will contain all the BudgetTransfer accounts List to be shared 
        Description:        
        @Added By:          Accenture - VD - 30-10-2019
        Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void sharingAccountTransfer(List<Core_MDF_Budget_Transfer_Log__c> accountTransferList) {  
        
        // Account & Channel Program To Group Ids Map
        Map<String,List<id>> accountChannelProgramToGroupIdsMap = new Map <String,List<Id>>();
        
        // Account,Channel Program & Region To Group Ids Map- Accn VD
        Map<String,List<id>> accountChannelProgramRegionToGroupIdsMap = new Map<String,List<id>>();
        
        // Account,Channel Program, Region & SubRegion To Group Ids Map- Accn VD
        Map<String,List<id>> accountChannelProgramRegionSubRegionToGroupIdsMap = new Map<String,List<id>>();
        
        // Record Id To Group Id Map
        Map<Id,List<Id>> recordIdToGrpIdMap = new Map<Id,List<Id>>();
        
        //Getting Core_MDF_Partner_Group_Mapping__c Access Type from Custom Label   
        String accountTransferLogSharePGMType = System.Label.Core_MDF_AccountTransferLogShare_PGM_Type;
        
        //Getting the type of access to which we want to share the account user records
        List<String> typeOfAccess = accountTransferLogSharePGMType.split(',');     
        
        //Getting all the account ids from Account Transfer Log list - Accenture VD
        List<Id> acctTransLogIds = new List<Id>();
        
        //Set of virtual account's ultimate account - Accenture VD
        Set<Id> setOfUltimateAccountIds = new Set<Id>();
        
        //Set of virtual account's program - Accenture VD
        Set<Id> setOfProgramIds = new Set<Id>();
        
        //Map of account id and account - Accenture VD
        Map<Id,Account> accountIdToAccountMap = new Map<Id,Account>();
        
        //To share record on the basis of Channel Program and geo
        List<Core_MDF_RecordGeoShare> recordGeoShareList= new List<Core_MDF_RecordGeoShare>();
        
        //To store program ids
        List<Id> programIds = new List<Id>();
        
        //Map of GroupId and Type of access
        Map<Id,String> mapOfGroupIdAndTypeOfAccess = new Map<Id,String>();
        
        try{
            // For loop on Core_MDF_Budget_Transfer_Log__c List
            for (Core_MDF_Budget_Transfer_Log__c accountTransfer: accountTransferList) {
                acctTransLogIds.add(accountTransfer.Core_MDF_Source_Account__c);
            }
            
            for (Account acc: [Select Id,Core_Geo__c,Core_Sub_Geo__c, Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Name, Core_MDF_CoMarketing_Ultimate_Account__c from Account where id IN :acctTransLogIds]) {
                //Storing ultimate accounts
                setOfUltimateAccountIds.add(acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                //Storing program Ids
                setOfProgramIds.add(acc.Core_MDF_Channel_Program__c);
                accountIdToAccountMap.put(acc.Id,acc);  
                programIds.add(acc.Core_MDF_Channel_Program__c);
            }
            
            if(setOfUltimateAccountIds!=NULL && setOfUltimateAccountIds.size()>0 && setOfProgramIds!=NULL && setOfProgramIds.size()>0){
                for (Core_MDF_Partner_Group_Mapping__c pgm: [Select Id, Core_MDF_Account__c,Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c, Core_MDF_Channel_Program__c, Core_MDF_Group_Id__c, Core_MDF_Group_Name__c,Core_MDF_Type_of_Access__c  
                                                             from Core_MDF_Partner_Group_Mapping__c where Core_MDF_Account__c IN :setOfUltimateAccountIds 
                                                             AND Core_MDF_Channel_Program__c IN :setOfProgramIds AND Core_MDF_Type_of_Access__c IN :typeOfAccess]){
                    mapOfGroupIdAndTypeOfAccess.put(pgm.Core_MDF_Group_Id__c,pgm.Core_MDF_Type_of_Access__c);
                    if(pgm.Core_MDF_Region_cd__c!= Null && pgm.Core_MDF_Sub_Region_cd__c != NULL){
                        String accountIdProgramIdGeoSubGeo = pgm.Core_MDF_Account__c + '_' + pgm.Core_MDF_Channel_Program__c + '_' + pgm.Core_MDF_Region_cd__c+ '_' +pgm.Core_MDF_Sub_Region_cd__c;
                        if (accountChannelProgramRegionSubRegionToGroupIdsMap.containsKey(accountIdProgramIdGeoSubGeo)) {
                            accountChannelProgramRegionSubRegionToGroupIdsMap.get(accountIdProgramIdGeoSubGeo).add(pgm.Core_MDF_Group_Id__c);
                        } else {
                            accountChannelProgramRegionSubRegionToGroupIdsMap.put(accountIdProgramIdGeoSubGeo, new List <String>{pgm.Core_MDF_Group_Id__c});
                        }
                    }else if(pgm.Core_MDF_Region_cd__c!= Null){
                        String accountIdProgramIdGeo = pgm.Core_MDF_Account__c + '_' + pgm.Core_MDF_Channel_Program__c+'_' + pgm.Core_MDF_Region_cd__c;
                        if (accountChannelProgramRegionToGroupIdsMap.containsKey(accountIdProgramIdGeo)) {
                            accountChannelProgramRegionToGroupIdsMap.get(accountIdProgramIdGeo).add(pgm.Core_MDF_Group_Id__c);
                        } else {
                            accountChannelProgramRegionToGroupIdsMap.put(accountIdProgramIdGeo, new List <String>{pgm.Core_MDF_Group_Id__c});
                        }
                    }
                        String accountIdProgramId = pgm.Core_MDF_Account__c + '_' + pgm.Core_MDF_Channel_Program__c;
                    if (accountChannelProgramToGroupIdsMap.containsKey(accountIdProgramId)) {
                        accountChannelProgramToGroupIdsMap.get(accountIdProgramId).add(pgm.Core_MDF_Group_Id__c);
                    } else {
                        accountChannelProgramToGroupIdsMap.put(accountIdProgramId, new List <String>{pgm.Core_MDF_Group_Id__c});
                    }
                }
            }
            
            for (Core_MDF_Budget_Transfer_Log__c accountTransLog: accountTransferList) {
                Account account = accountIdToAccountMap.get(accountTransLog.Core_MDF_Source_Account__c);
               List<id> grpIds = new List<id>();
               // mapOfProgGeoSharingReq to check if Geo based Sharing is required
                if(mapOfProgGeoSharingReq!=null && mapOfProgGeoSharingReq.containsKey(account.Core_MDF_Channel_Program__r.Name) && mapOfProgGeoSharingReq.get(account.Core_MDF_Channel_Program__r.Name))
                {
                     // mapOfProgGeoSharingReq to check if Geo based Sharing is required
                   if(mapOfClaimActAllocRecTypeMetadata!=null && mapOfClaimActAllocRecTypeMetadata.containsKey(account.Core_MDF_Channel_Program__r.Name) && mapOfClaimActAllocRecTypeMetadata.get(account.Core_MDF_Channel_Program__r.Name).contains(account.Core_Geo__c)){
                        String mapKey = account.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+account.Core_MDF_Channel_Program__c+'_'+account.Core_Geo__c+'_'+account.Core_Sub_Geo__c;
                        if(accountChannelProgramRegionSubRegionToGroupIdsMap.containsKey(mapKey) && mapOfGroupIdAndTypeOfAccess!=null && mapOfGroupIdAndTypeOfAccess.size()>0){
                            for (Id groupId : accountChannelProgramRegionSubRegionToGroupIdsMap.get(mapKey)){
                                if(mapOfGroupIdAndTypeOfAccess.containsKey(groupId) && mapOfGroupIdAndTypeOfAccess.get(groupId).equals(System.Label.Core_MDF_TypeOfAccessInternal)){
                                    grpIds.add(groupId);
                                }
                            }
                        }
                        if(grpIds!=NULL && grpIds.size()>0){
                            if (recordIdToGrpIdMap.containsKey(accountTransLog.Id)) {
                                recordIdToGrpIdMap.get(accountTransLog.Id).addAll(grpIds);
                            } else {
                                recordIdToGrpIdMap.put(accountTransLog.Id,grpIds);
                            }
                        }
                    }
                    else{
                        String mapKey = account.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+account.Core_MDF_Channel_Program__c+'_'+account.Core_Geo__c;
                        if(accountChannelProgramRegionToGroupIdsMap.containsKey(mapKey) && mapOfGroupIdAndTypeOfAccess!=null && mapOfGroupIdAndTypeOfAccess.size()>0){
                            for (Id groupId : accountChannelProgramRegionToGroupIdsMap.get(mapKey)){
                                
                                if(mapOfGroupIdAndTypeOfAccess.containsKey(groupId) && mapOfGroupIdAndTypeOfAccess.get(groupId).equals(System.Label.Core_MDF_TypeOfAccessInternal)){
                                    grpIds.add(groupId);
                                }
                            }
                            
                        }
                        if(grpIds!=NULL && grpIds.size()>0){
                            if (recordIdToGrpIdMap.containsKey(accountTransLog.Id)) {
                                recordIdToGrpIdMap.get(accountTransLog.Id).addAll(grpIds);
                            } else {
                                recordIdToGrpIdMap.put(accountTransLog.Id,grpIds);
                            }
                        }
                    }
                }else{
                    // Sharing for programs where Geo based sharing is not required eg CCF/DCF/SPCF/CCFB
                    String mapKey = account.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+account.Core_MDF_Channel_Program__c;
                    if(accountChannelProgramToGroupIdsMap.containsKey(mapKey)){ 
                        grpIds = accountChannelProgramToGroupIdsMap.get(mapKey);
                    }
                    if(grpIds!=NULL && grpIds.size()>0){
                        if (recordIdToGrpIdMap.containsKey(accountTransLog.Id)) {
                            recordIdToGrpIdMap.get(accountTransLog.Id).addAll(grpIds);
                        } else {
                            recordIdToGrpIdMap.put(accountTransLog.Id,grpIds);
                        }
                    }
                }
                //To share record on the basis of Channel Program and geo
                recordGeoShareList.add(new Core_MDF_RecordGeoShare(accountTransLog.Id,account.Core_Geo__c,account.Core_Sub_Geo__c,account.Core_MDF_Channel_Program__r.Name));
            }
            //To share record on the basis of Channel Program and geo
            if(recordGeoShareList != null && recordGeoShareList.size() >0){
                Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('Core_MDF_Budget_Transfer_Log__c',recordGeoShareList);
            }
            
            //To share budget transfer log records with internal geo groups
            system.debug('sizeofMAP'+recordIdToGrpIdMap);
            if(recordIdToGrpIdMap != null && recordIdToGrpIdMap.size() > 0){
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Budget_Transfer_Log__c',recordIdToGrpIdMap, 'Edit');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);            
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
/*******************************************************************************************************************************
  ****************************************************************************************************************************/
    public static void recalculateSharePnumWhenOwnerChange(List<Core_MDF_Partner_Node_User_Mapping__c> accountUserList, Map<Id,Core_MDF_Partner_Node_User_Mapping__c> oldAccountUserMap) {  
        
        List<Core_MDF_Partner_Node_User_Mapping__c> accountUserTobeReshared = new List<Core_MDF_Partner_Node_User_Mapping__c>();
        
        try{            
            // Check whether the Owner is updated from the new and old list
            for(Core_MDF_Partner_Node_User_Mapping__c newAccountUser : accountUserList){                
                if(newAccountUser.OwnerId != oldAccountUserMap.get(newAccountUser.Id).OwnerId){
                    accountUserTobeReshared.add(newAccountUser);
                }                
            }            
            // Share the Pnum 
            if(accountUserTobeReshared!=null && accountUserTobeReshared.size()>0){            
                sharingAccountUser(accountUserTobeReshared);    
                
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
   }
    
/*********************************************************************************************************************
  *************************************************************************************************************************/
    
public static void recalculateShareAccountTransferWhenOwnerChange(List<Core_MDF_Budget_Transfer_Log__c> accountTransferList, Map<Id,Core_MDF_Budget_Transfer_Log__c> oldAccountTransferMap) {  
        
        List<Core_MDF_Budget_Transfer_Log__c> accountTransferTobeReshared = new List<Core_MDF_Budget_Transfer_Log__c>();
        
        try{            
            // Check whether the Owner is updated from the new and old list
            for(Core_MDF_Budget_Transfer_Log__c newAccountTransfer : accountTransferList){                
                if(newAccountTransfer.OwnerId != oldAccountTransferMap.get(newAccountTransfer.Id).OwnerId){
                    accountTransferTobeReshared.add(newAccountTransfer);
                }                
            }            
            // Share the Pnum 
            if(accountTransferTobeReshared!=null && accountTransferTobeReshared.size()>0){            
                sharingAccountTransfer(accountTransferTobeReshared);    
                
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
                
/***************************************************************************************************** 
Method Name:        fetchClaimActAllocRecType
@return  :          Map of string and String
@parameters:        N/A
Description:        Method to query all metadata records and create a map
@Added By:          Accenture - AD 
Modified By:        Date:       Changes: 
******************************************************************************************************/    
    public static Map<String,String> fetchClaimActAllocRecType(){
        Map<String,String> mapOfRecordTypes = new Map<String,String>();
        for(Core_MDF_ClaimActAllocRecTypeMapping__mdt recTypeMetaData:[Select Id,Core_MDF_Region_cd__c,Core_MDF_Activity_RecordType_txt__c,Core_MDF_Allocation_RecordType_txt__c,
                                                                       Core_MDF_Claim_RecordType_txt__c,Core_MDF_Channel_Program_txt__c,Core_MDF_Enable_Fund_Reservation_chk__c 
                                                                       from Core_MDF_ClaimActAllocRecTypeMapping__mdt]){
                                                                           mapOfRecordTypes.put(recTypeMetaData.Core_MDF_Channel_Program_txt__c,recTypeMetaData.Core_MDF_Region_cd__c);  
                                                                       }
        return mapOfRecordTypes;
    }
/***************************************************************************************************** 
Method Name:        fetchProgForGeoBasedSharing
@return  :          Map of string and Boolean object
@parameters:        N/A
Description:        Method to query all metadata records and create a map
@Added By:          Accenture - VD 
Modified By:        Date:       Changes: 
******************************************************************************************************/    
    public static Map<String,Boolean> fetchProgForGeoBasedSharing(){
        Map<String,Boolean> mapOfProgGeoBasedSharing = new Map<String,Boolean>();
        for(Core_MDF_ChannelProgram__mdt progMetadata:[Select Id,Core_MDF_Technical_Program_Name__c,  Geo_Based_Sharing_Required__c from Core_MDF_ChannelProgram__mdt]){
            mapOfProgGeoBasedSharing.put(progMetadata.Core_MDF_Technical_Program_Name__c,progMetadata.Geo_Based_Sharing_Required__c);  
        }
        return mapOfProgGeoBasedSharing;
    }
}