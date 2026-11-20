/****************************************************************************************************************************************
 * Class Name        : Core_MDF_Batch_HostGeoPNUMShareInsert
 * Created Date      : 06/10/2023  
 * Modification Log
 * Developer            Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 *  Accenture - Mayuri - 06/10/2023       Batch class to Create and Insert share records for Account User Object on Internal PGM Insertion
 *****************************************************************************************************************************************/
public without sharing class Core_MDF_Batch_HostGeoPNUMShareInsert implements Database.Batchable<sObject>,Database.AllowsCallouts {
    String sobjectName; 
    String accQuery;
    String programQuery;
    String noOfPNUM;
    Set<Id> setOfAccountId = new Set<Id>();
    Set<Id> setOfProgramId = new Set<Id>();
    Set<String> accIdProgramIdSet = new Set<String>();
    Set<String> hostGeo = new Set<String>();
    List<Core_MDF_Partner_Group_Mapping__c> newPGMList = new List<Core_MDF_Partner_Group_Mapping__c>();  
    public static Map<String,String> mapOfClaimActAllocRecTypeMetadata = new Map<String,String>();
    public static Map<String,Boolean> mapOfProgGeoSharingReq = new Map<String,Boolean>();
    //Assign all record type meta data
    static{
        mapOfClaimActAllocRecTypeMetadata = Core_MDF_ManualSharing.fetchClaimActAllocRecType();
        mapOfProgGeoSharingReq = Core_MDF_ManualSharing.fetchProgForGeoBasedSharing();
    }
    //Constructor called from PGM_BatchHelper class
    public Core_MDF_Batch_HostGeoPNUMShareInsert(String objectName, String firstQuery, String secondQuery, 
                                                Set<Id> accIdSet, Set<Id> programIdSet, Set<String> uniqueKeySet, Set<String> hostGeo) {
                                                    
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
       this.hostGeo = hostGeo;
    }
    /*****************************************************************************************************
       Method Name :   start
       @return     :   List of Account User records
       @parameters :   Database.BatchableContext
       Description :   It fetches all records based on input parameters
       Added By    :    Accenture - Mayuri - 06/10/2023
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
       Added By    :    Accenture - Mayuri - 06/10/2023
       Modified By :                               Date:         Changes:
     **********************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<sObject> scope) {//log entries
        List<sObject> shareRecordList = new List<sObject>();
        // Account & Channel Program To Group Ids Map
        Map<String,List<id>> accountChannelProgramToGroupIdsMap = new Map <String,List<Id>>();        
        // Record Id To Group Id Map
        Map<Id,List<Id>> recordIdToGrpIdMap = new Map<Id,List<Id>>();
        
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
        List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList= new List<Core_MDF_RecordPGMShareWrapper>();
        
        //map of record id and group id with which it needs to be shared-VD
        Map<Id,List<Id>> acctUserIdGroupIdListMap = new Map<Id,List<Id>>();
        List<Core_MDF_BulkAPI_Operations.AysncJobDetailWrapper> wrapperList = new List<Core_MDF_BulkAPI_Operations.AysncJobDetailWrapper>();
        try{

             Set<Id> PNUMIds = new Set<Id>();
             Set<String> geoSet = new Set<String>();
             List<Core_MDF_Partner_Node_User_Mapping__c> accountUserList = (List<Core_MDF_Partner_Node_User_Mapping__c>) scope;
            for(Core_MDF_Partner_Node_User_Mapping__c accountUser: accountUserList){
                accountIds.add(accountUser.Core_MDF_Account__c);
                PNUMIds.add(accountUser.Id);
            }
            wrapperList.add(Core_MDF_BulkAPI_Operations.deleteShareBulkRecords(PNUMIds,hostGeo,'Core_MDF_Partner_Node_User_Mapping__Share','ParentId'));
    
           for (Account acc: [Select Id,Core_Geo__c,Core_Sub_Geo__c,Core_MDF_Group_Id__c, Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Name, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_CoMarketing_Ultimate_Account__c from Account where id IN :accountIds]) {
                //Storing ultimate accounts
                setOfUltimateAccountIds.add(acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                //Storing program ids
                setOfProgramIds.add(acc.Core_MDF_Channel_Program__c);
                geoSet.add(acc.Core_Geo__c);
                accountIdToAccountMap.put(acc.Id,acc);
            }

            if(setOfUltimateAccountIds!=NULL && setOfUltimateAccountIds.size()>0 && setOfProgramIds!=NULL && setOfProgramIds.size()>0){
                for (Core_MDF_Partner_Group_Mapping__c pgm: [Select Id, Core_MDF_Account__c,Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c, Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Group_Id__c,Core_MDF_Type_of_Access__c,Core_MDF_Group_Name__c 
                                                             from Core_MDF_Partner_Group_Mapping__c where Core_MDF_Account__c IN :setOfUltimateAccountIds 
                                                             AND Core_MDF_Channel_Program__c IN :setOfProgramIds AND Core_MDF_Inactive_Ind__c = false  and Core_MDF_Region_cd__c IN: geoSet]) 
                {
                    String accountIdProgramId = pgm.Core_MDF_Account__c + '_' + pgm.Core_MDF_Channel_Program__c;
                    if (accountChannelProgramToGroupIdsMap.containsKey(accountIdProgramId)) {
                        accountChannelProgramToGroupIdsMap.get(accountIdProgramId).add(pgm.Core_MDF_Group_Id__c);
                    }else {
                        accountChannelProgramToGroupIdsMap.put(accountIdProgramId, new List <String>{pgm.Core_MDF_Group_Id__c});
                    }
                }
            }
            
            for (Core_MDF_Partner_Node_User_Mapping__c accountUser: accountUserList) {
                Account account = accountIdToAccountMap.get(accountUser.Core_MDF_Account__c);
                List<id> grpIds = new List<id>();
                
                String mapKey = account.Core_MDF_CoMarketing_Ultimate_Account__c + '_' + account.Core_MDF_Channel_Program__c;
                if(accountChannelProgramToGroupIdsMap.containsKey(mapKey)){
                    grpIds.addAll(accountChannelProgramToGroupIdsMap.get(mapKey));
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
            //To share account user records with internal geo groups
            if(recordIdToGrpIdMap != null && recordIdToGrpIdMap.size() > 0){
                
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Partner_Node_User_Mapping__c',recordIdToGrpIdMap, 'Edit');
                List<sObject> shareRecList = Core_MDF_GenericShareRecordActionClass.getShareRecordList(rmsInst);      
                if(shareRecList!=Null && shareRecList.size()>0){
                    shareRecordList.addAll(shareRecList);
                }
            }      

                
            //To share record on the basis of Channel Program and geo 
            if(recordGeoShareList != null && recordGeoShareList.size() >0){
                List<sObject> shareRecList = Core_MDF_ShareRecordToGeoGroup.getShareRecordToGeoGroup('Core_MDF_Partner_Node_User_Mapping__c',recordGeoShareList);
                if(shareRecList!=Null && shareRecList.size()>0){
                    shareRecordList.addAll(shareRecList);
                }
            }
           
                 
            if(shareRecordList!=Null && shareRecordList.size()>0){
                wrapperList.add(Core_MDF_BulkAPI_Operations.insertShareBulkRecords(shareRecordList,'Core_MDF_Partner_Node_User_Mapping__Share','ParentId'));
                
            }

          if(wrapperList!= null)
          {
            Core_MDF_BulkAPI_Operations.insertAsyncBulkRecords(wrapperList);
          }
         
    } catch(Exception e) { 
        if(wrapperList != null){   
            Core_MDF_BulkAPI_Operations.insertAsyncBulkRecordsByPE(wrapperList);
        }
        Core_MDF_CCP_UtilityClass.logError(e);
    }
}
     /*****************************************************************************************************
       Method Name :   finish
       @return     :   void
       @parameters :   Database.BatchableContext
       Description :
       Added By    :   Accenture - Mayuri - 06/10/2023
       Modified By :                               Date:                     Changes:None
     ******************************************************************************************************/ 
    public void finish(Database.BatchableContext bContext) {
        
    }
    
}