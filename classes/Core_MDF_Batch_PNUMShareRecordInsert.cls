/****************************************************************************************************************************************
* Class Name        : Core_MDF_CreateBatchShareRecordsInternal
* Created Date      : 10/06/2022
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Mayuri       10/06/2022        Batch class to Create and Insert share records for Account User Object on Internal PGM Insertion
*****************************************************************************************************************************************/
public class Core_MDF_Batch_PNUMShareRecordInsert implements Database.Batchable<sObject> {
    String sobjectName; 
    String accQuery;
    String programQuery;
    String noOfPNUM;
    Set<Id> setOfAccountId = new Set<Id>();
    Set<Id> setOfProgramId = new Set<Id>();
    Set<String> accIdProgramIdSet = new Set<String>();
    List<Core_MDF_Partner_Group_Mapping__c> newPGMList = new List<Core_MDF_Partner_Group_Mapping__c>();  
    public static Map<String,String> mapOfClaimActAllocRecTypeMetadata = new Map<String,String>();
    public static Map<String,Boolean> mapOfProgGeoSharingReq = new Map<String,Boolean>();
    //Assign all record type meta data
    static{
        mapOfClaimActAllocRecTypeMetadata = Core_MDF_ManualSharing.fetchClaimActAllocRecType();
        mapOfProgGeoSharingReq = Core_MDF_ManualSharing.fetchProgForGeoBasedSharing();
    }
    //Constructor called from PGM_BatchHelper class
    public Core_MDF_Batch_PNUMShareRecordInsert(String objectName, String firstQuery, String secondQuery, 
                                                Set<Id> accIdSet, Set<Id> programIdSet, Set<String> uniqueKeySet,List<Core_MDF_Partner_Group_Mapping__c> newPGMList) {
                                                    
                                                    this.sobjectName = objectName;
                                                    this.accQuery = firstQuery;
                                                    this.setOfAccountId = accIdSet;
                                                    this.accIdProgramIdSet = uniqueKeySet;
                                                    if(programIdSet != null) {
                                                        this.setOfProgramId = programIdSet;
                                                    }
                                                    if(secondQuery != null) {
                                                        this.programQuery = secondQuery;
                                                    }
                                                    this.newPGMList = newPGMList;
                                                }
    /*****************************************************************************************************
Method Name :   start
@return     :   List of Account User records
@parameters :   Database.BatchableContext
Description :   It fetches all records based on input parameters
Added By    :   Accenture - Mayuri - 10-06-2022
Modified By :                               Date:                   Changes:
******************************************************************************************************/    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        try {
            return Database.getQueryLocator(accQuery + ':setOfAccountId' + programQuery + ':setOfProgramId');
            
        } catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
        
    }
    /********************************************************************************************************
Method Name :   execute
@return     :   void
@parameters :   Database.BatchableContext
Description :   Method to create and Insert share records
Added By    :   Accenture - Mayuri - 10-06-2022
Modified By :                               Date:         Changes:
**********************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<sObject> scope) {//log entries
        List<sObject> shareRecordList = new List<sObject>();
        // Account & Channel Program To Group Ids Map
        Map<String,List<id>> accountChannelProgramToGroupIdsMap = new Map <String,List<Id>>();
        
        // Account,Channel Program & Region To Group Ids Map- Accn VD
        Map<String,List<id>> accountChannelProgramRegionToGroupIdsMap = new Map<String,List<id>>();
        
        // Account,Channel Program, Region & SubRegion To Group Ids Map- Accn VD
        Map<String,List<id>> accountChannelProgramRegionSubRegionToGroupIdsMap = new Map<String,List<id>>();
        
        // Record Id To Group Id Map
        Map<Id,List<Id>> recordIdToGrpIdMap = new Map<Id,List<Id>>();   
        
        //Getting all the account ids from Account User list - Accenture VD
        List<Id> accountIds = new List<Id>();
        List<Id> pgmIds = new List<Id>();
        //Set of virtual account's ultimate account - Accenture VD
        Set<Id> setOfUltimateAccountIds = new Set<Id>();
        
        //Set of virtual account's program - Accenture VD
        Set<Id> setOfProgramIds = new Set<Id>();
        
        //Map of account id and account - Accenture VD
        Map<Id,Account> accountIdToAccountMap = new Map<Id,Account>();
        
        //map of record id and group id with which it needs to be shared-VD
        Map<Id,List<Id>> acctUserIdGroupIdListMap = new Map<Id,List<Id>>();
        List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = (List<Core_MDF_Partner_Node_User_Mapping__c>) scope;
        try{
            for(Core_MDF_Partner_Node_User_Mapping__c accountUser: pnumList){
                accountIds.add(accountUser.Core_MDF_Account__c);
            }
            //Storing PGM Ids from Input PGM List
            for(Core_MDF_Partner_Group_Mapping__c PGMList: newPGMList){
                pgmIds.add(PGMList.Id);
            }
            for (Account acc: [Select Id,Core_Geo__c,Core_Sub_Geo__c,Core_MDF_Group_Id__c, Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Name, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_CoMarketing_Ultimate_Account__c from Account where id IN :accountIds]) {
                //Storing ultimate accounts
                setOfUltimateAccountIds.add(acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                //Storing program ids
                setOfProgramIds.add(acc.Core_MDF_Channel_Program__c);
                accountIdToAccountMap.put(acc.Id,acc);
                //programIds.add(acc.Core_MDF_Channel_Program__c);
            }
            if(setOfUltimateAccountIds!=NULL && setOfUltimateAccountIds.size()>0 && setOfProgramIds!=NULL && setOfProgramIds.size()>0){
                for (Core_MDF_Partner_Group_Mapping__c pgm: [Select Id, Core_MDF_Account__c,Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c, Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Group_Id__c,Core_MDF_Type_of_Access__c,Core_MDF_Group_Name__c 
                                                             from Core_MDF_Partner_Group_Mapping__c where Id IN :pgmIds and  Core_MDF_Inactive_Ind__c = false]) 
                {
                    
                    if(mapOfProgGeoSharingReq!=null && mapOfProgGeoSharingReq.containsKey(pgm.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c) && !mapOfProgGeoSharingReq.get(pgm.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c)) {
                        String accountIdProgramId = pgm.Core_MDF_Account__c + '_' + pgm.Core_MDF_Channel_Program__c;
                        //ATHR - Deeply Nested if 16209
                        if (!accountChannelProgramToGroupIdsMap.containsKey(accountIdProgramId)) {
                            accountChannelProgramToGroupIdsMap.put(accountIdProgramId, new List <String>{pgm.Core_MDF_Group_Id__c});
                        }
                        accountChannelProgramToGroupIdsMap.get(accountIdProgramId).add(pgm.Core_MDF_Group_Id__c);
                        continue;
                    }
                    //else 
                    //{
                    if(pgm.Core_MDF_Region_cd__c!= Null && pgm.Core_MDF_Sub_Region_cd__c != NULL){
                        String accountIdProgramIdGeoSubGeo = pgm.Core_MDF_Account__c + '_' + pgm.Core_MDF_Channel_Program__c + '_' + pgm.Core_MDF_Region_cd__c+ '_' +pgm.Core_MDF_Sub_Region_cd__c;
                        if (!accountChannelProgramRegionSubRegionToGroupIdsMap.containsKey(accountIdProgramIdGeoSubGeo)) {
                            accountChannelProgramRegionSubRegionToGroupIdsMap.put(accountIdProgramIdGeoSubGeo, new List <String>{pgm.Core_MDF_Group_Id__c});
                        }
                        accountChannelProgramRegionSubRegionToGroupIdsMap.get(accountIdProgramIdGeoSubGeo).add(pgm.Core_MDF_Group_Id__c);
       
                    }
                    else if(pgm.Core_MDF_Region_cd__c!= Null){
                        String accountIdProgramIdGeo = pgm.Core_MDF_Account__c + '_' + pgm.Core_MDF_Channel_Program__c+'_' + pgm.Core_MDF_Region_cd__c;
                        if (!accountChannelProgramRegionToGroupIdsMap.containsKey(accountIdProgramIdGeo)) {
                            accountChannelProgramRegionToGroupIdsMap.put(accountIdProgramIdGeo, new List <String>{pgm.Core_MDF_Group_Id__c});                            
                        } 
                        accountChannelProgramRegionToGroupIdsMap.get(accountIdProgramIdGeo).add(pgm.Core_MDF_Group_Id__c);
                    }
                    //}
                }
            }
            for (Core_MDF_Partner_Node_User_Mapping__c accountUser: pnumList) {
                Account account = accountIdToAccountMap.get(accountUser.Core_MDF_Account__c);
                List<id> grpIds = new List<id>();
                // mapOfProgGeoSharingReq to check if Geo based Sharing is required
                
                if(mapOfProgGeoSharingReq!=null && mapOfProgGeoSharingReq.containsKey(account.Core_MDF_Channel_Program__r.Name) && mapOfProgGeoSharingReq.get(account.Core_MDF_Channel_Program__r.Name)){
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
                else{  
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
                }
            }
                //To share account user records with internal geo groups
                if(recordIdToGrpIdMap != null && recordIdToGrpIdMap.size() > 0){
                    
                    Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Partner_Node_User_Mapping__c',recordIdToGrpIdMap, 'Edit');
                    List<sObject> shareRecList = Core_MDF_GenericShareRecordActionClass.getShareRecordList(rmsInst);      
                    if(shareRecList!=Null && shareRecList.size()>0){
                        shareRecordList.addAll(shareRecList);
                    }
                }
                if(shareRecordList!=Null && shareRecordList.size()>0){
                    Insert shareRecordList;
                }
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        
    }
    /*****************************************************************************************************
Method Name :   finish
@return     :   void
@parameters :   Database.BatchableContext
Description :
Added By    :   Accenture - Mayuri - 10-06-2022
Modified By :                               Date:                     Changes:None
******************************************************************************************************/ 
    public void finish(Database.BatchableContext bContext) {
        
    }
    
}