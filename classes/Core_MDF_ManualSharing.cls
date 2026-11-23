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
        
        List<sObject> shareRecordList = new List<sObject>();
        // Account & Channel Program To Group Ids Map
        Map<String,Id> accountChannelProgramToGroupIdsMap = new Map <String,Id>();        
        // Record Id To Group Id Map
        Map<Id,List<Id>> recordIdToGrpIdMap = new Map<Id,List<Id>>();
        
        String typeOfAccess = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PGM_Ext_AccessType');
        
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
        try{
            for(Core_MDF_Partner_Node_User_Mapping__c accountUser: accountUserList){
                accountIds.add(accountUser.Core_MDF_Account__c);
            }
            
            for (Account acc: [Select Id,Core_Geo__c,Core_Sub_Geo__c,Core_MDF_Group_Id__c, Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Name, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_CoMarketing_Ultimate_Account__c from Account where id IN :accountIds]) {
                //Storing ultimate accounts
                setOfUltimateAccountIds.add(acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                //Storing program ids
                setOfProgramIds.add(acc.Core_MDF_Channel_Program__c);
                accountIdToAccountMap.put(acc.Id,acc);
            }
            
            if(setOfUltimateAccountIds!=NULL && setOfUltimateAccountIds.size()>0 && setOfProgramIds!=NULL && setOfProgramIds.size()>0){
                for (Core_MDF_Partner_Group_Mapping__c pgm: [Select Id, Core_MDF_Account__c,Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c, Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Group_Id__c,Core_MDF_Type_of_Access__c,Core_MDF_Group_Name__c 
                                                             from Core_MDF_Partner_Group_Mapping__c where Core_MDF_Account__c IN :setOfUltimateAccountIds 
                                                             AND Core_MDF_Channel_Program__c IN :setOfProgramIds AND Core_MDF_Inactive_Ind__c = false and Core_MDF_Type_of_Access__c =: typeOfAccess]) 
                {
                    String accountIdProgramId = pgm.Core_MDF_Account__c + '_' + pgm.Core_MDF_Channel_Program__c;
                    accountChannelProgramToGroupIdsMap.put(accountIdProgramId, pgm.Core_MDF_Group_Id__c);
                }
            }
            
            for (Core_MDF_Partner_Node_User_Mapping__c accountUser: accountUserList) {
                Account account = accountIdToAccountMap.get(accountUser.Core_MDF_Account__c);
                List<id> grpIds = new List<id>();
                
                String mapKey = account.Core_MDF_CoMarketing_Ultimate_Account__c + '_' + account.Core_MDF_Channel_Program__c;
                if(accountChannelProgramToGroupIdsMap.containsKey(mapKey)){
                    grpIds.add(accountChannelProgramToGroupIdsMap.get(mapKey));
                }
                if(grpIds!=NULL && grpIds.size()>0){
                    recordIdToGrpIdMap.put(accountUser.Id,grpIds);
                }
                //To share record on the basis of Channel Program and geo 
                recordGeoShareList.add(new Core_MDF_RecordGeoShare(accountUser.Id,account.Core_Geo__c,account.Core_Sub_Geo__c,account.Core_MDF_Channel_Program__r.Name));
                recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(accountUser.Id,account.Core_Geo__c,account.Core_Sub_Geo__c,account.Core_MDF_Channel_Program__r.Name,account.Core_MDF_CoMarketing_Ultimate_Account__c));
                //to share account user record with its account's group
                if(accountIdToAccountMap.containskey(accountUser.Core_MDF_Account__c) && accountIdToAccountMap.get(accountUser.Core_MDF_Account__c).Core_MDF_Channel_Program__c != Null 
                   && accountIdToAccountMap.get(accountUser.Core_MDF_Account__c).Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c != Null 
                   && Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd(accountIdToAccountMap.get(accountUser.Core_MDF_Account__c).Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c)
                   && accountIdToAccountMap.get(accountUser.Core_MDF_Account__c).Core_MDF_Group_Id__c != Null)
                {                    
                    acctUserIdGroupIdListMap.put(accountUser.Id,new List<Id>{accountIdToAccountMap.get(accountUser.Core_MDF_Account__c).Core_MDF_Group_Id__c});
                }                              
            }
            //to share account user record with its account's group
            if(acctUserIdGroupIdListMap != NULL && !acctUserIdGroupIdListMap.isEmpty()){
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Partner_Node_User_Mapping__c', acctUserIdGroupIdListMap, 'Edit', 'Manual');
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
            if(recordPGMShareList != null && recordPGMShareList.size() >0){
                Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('Core_MDF_Partner_Node_User_Mapping__c', recordPGMShareList);
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
                Core_MDF_Batch_ShareRecordInsert batchInstance = new Core_MDF_Batch_ShareRecordInsert(shareRecordList); 
                Id batchId = Database.executeBatch(batchInstance,500);// custom  setting - 2000
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
        Map<String,id> accountChannelProgramToGroupIdsMap = new Map <String,Id>();
        
        // Record Id To Group Id Map
        Map<Id,List<Id>> recordIdToGrpIdMap = new Map<Id,List<Id>>();
        
        String typeOfAccess = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PGM_Ext_AccessType');//External
        //Getting all the account ids from Account Transfer Log list - Accenture VD
        //List<Id> acctTransLogIds = new List<Id>();
        
        //Set of virtual account's ultimate account - Accenture VD
        //Set<Id> setOfUltimateAccountIds = new Set<Id>();
        
        //Set of virtual account's program - Accenture VD
        //Set<Id> setOfProgramIds = new Set<Id>();
        
        //Map of Budget to budgetTypes
        Map<Id,String> budgetToBudgetTypeMap = new Map<Id,String>();
        
        //Map of account id and account - Accenture VD
        Map<Id,Account> accountIdToAccountMap = new Map<Id,Account>();
        
        //Set of account id's of Source and target accounts
        Set<Id> accountNodeIdSet = new Set<Id>();
        
        //Map of account Id and Group Id for account Id and List of Account's External groups mapping
        Map<Id, Id> accountIdGroupIdMap = new Map<Id, Id>();
        
        //To share record on the basis of Channel Program and geo
        List<Core_MDF_RecordGeoShare> recordGeoShareList= new List<Core_MDF_RecordGeoShare>();
        List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList= new List<Core_MDF_RecordPGMShareWrapper>();
        
        //budget set
        Set<Id> pmbSet = new Set<Id>();
        
        //String cmdfProgram = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ChannelMDF_Program_Name');
        
        try{
            // For loop on Core_MDF_Budget_Transfer_Log__c List
            for (Core_MDF_Budget_Transfer_Log__c accountTransfer: accountTransferList) {
                //acctTransLogIds.add(accountTransfer.Core_MDF_Source_Account__c);
                pmbSet.add(accountTransfer.Core_MDF_Partner_Marketing_Budget__c);
                //To add account id's of Source and target accounts
                accountNodeIdSet.add(accountTransfer.Core_MDF_Target_Account__c);
                accountNodeIdSet.add(accountTransfer.Core_MDF_Source_Account__c);
            }
            
            for(Account acc : [Select Id,Core_Geo__c,Core_Sub_Geo__c, Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Name, Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_External_Group_Id__c from Account 
                               where id in:accountNodeIdSet and Core_MDF_External_Group_Id__c != null]){
                accountIdGroupIdMap.put(acc.Id, acc.Core_MDF_External_Group_Id__c);
                accountIdToAccountMap.put(acc.Id,acc); 
            }
            //Calling Method to share Account Transfer Logs with External groups according to Node Accounts
            if(!Core_MDF_Utility.byPassFeature('Bypass_BTL_AccExternalGrp_Sharing')){
                if(accountTransferList != null && accountTransferList.size() >0 && accountIdGroupIdMap!=null && accountIdGroupIdMap.size() > 0){
                    shareBudgetTransferToPartnerUsers(accountTransferList,accountIdGroupIdMap);
                }
            }
            
            List<PartnerMarketingBudget> pmbList = [ Select Id,Core_MDF_Budget_Type_Txt__c from PartnerMarketingBudget where Id IN:pmbSet];
            for(PartnerMarketingBudget pmb : pmbList ){
                budgetToBudgetTypeMap.put(pmb.Id,pmb.Core_MDF_Budget_Type_Txt__c);
            }
            //for (Account acc: [Select Id,Core_Geo__c,Core_Sub_Geo__c, Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Name, Core_MDF_CoMarketing_Ultimate_Account__c from Account where id IN :acctTransLogIds]) {
                //Storing ultimate accounts
                //setOfUltimateAccountIds.add(acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                //Storing program Ids
                //setOfProgramIds.add(acc.Core_MDF_Channel_Program__c);
             //   accountIdToAccountMap.put(acc.Id,acc);  
            //}
            
            /*if(setOfUltimateAccountIds!=NULL && setOfUltimateAccountIds.size()>0 && setOfProgramIds!=NULL && setOfProgramIds.size()>0){
                for (Core_MDF_Partner_Group_Mapping__c pgm: [Select Id, Core_MDF_Account__c,Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c, Core_MDF_Channel_Program__c, Core_MDF_Group_Id__c, Core_MDF_Group_Name__c,Core_MDF_Type_of_Access__c,Core_MDF_BudgetType_nm__c,Core_MDF_Channel_Program__r.Name   
                                                             from Core_MDF_Partner_Group_Mapping__c where Core_MDF_Account__c IN :setOfUltimateAccountIds 
                                                             AND Core_MDF_Channel_Program__c IN :setOfProgramIds AND Core_MDF_Inactive_Ind__c = false and Core_MDF_Type_of_Access__c =: typeOfAccess])
                {
                    String accountIdProgramId = pgm.Core_MDF_Account__c + '_' + pgm.Core_MDF_Channel_Program__c;
                    accountChannelProgramToGroupIdsMap.put(accountIdProgramId, pgm.Core_MDF_Group_Id__c);                    
                }
            } */          
            for (Core_MDF_Budget_Transfer_Log__c accountTransLog: accountTransferList){
                Account account = accountIdToAccountMap.get(accountTransLog.Core_MDF_Source_Account__c);
                //List<id> grpIds = new List<id>();                
                //String mapKey = account.Core_MDF_CoMarketing_Ultimate_Account__c + '_' + account.Core_MDF_Channel_Program__c;
                /*
                if(accountChannelProgramToGroupIdsMap.containsKey(mapKey) && mapOfProgGeoSharingReq!=null && mapOfProgGeoSharingReq.containsKey(account.Core_MDF_Channel_Program__r.Name) && !mapOfProgGeoSharingReq.get(account.Core_MDF_Channel_Program__r.Name)){ 
                    grpIds.add(accountChannelProgramToGroupIdsMap.get(mapKey));
                }
                if(grpIds!=NULL && grpIds.size()>0){
                    recordIdToGrpIdMap.put(accountTransLog.Id,grpIds);                    
                }
                */
                //To share record on the basis of Channel Program and geo
                if((/*account.Core_MDF_Channel_Program__r.Name == cmdfProgram ||*/ account.Core_MDF_Channel_Program__r.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name')) && budgetToBudgetTypeMap.containsKey(accountTransLog.Core_MDF_Partner_Marketing_Budget__c) && budgetToBudgetTypeMap.get(accountTransLog.Core_MDF_Partner_Marketing_Budget__c) != Null){
                    recordGeoShareList.add(new Core_MDF_RecordGeoShare(accountTransLog.Id,account.Core_Geo__c,account.Core_Sub_Geo__c,account.Core_MDF_Channel_Program__r.Name,budgetToBudgetTypeMap.get(accountTransLog.Core_MDF_Partner_Marketing_Budget__c)));
                    recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(accountTransLog.Id,account.Core_Geo__c,account.Core_Sub_Geo__c,account.Core_MDF_Channel_Program__r.Name,budgetToBudgetTypeMap.get(accountTransLog.Core_MDF_Partner_Marketing_Budget__c),account.Core_MDF_CoMarketing_Ultimate_Account__c));
                }
                else{
                    recordGeoShareList.add(new Core_MDF_RecordGeoShare(accountTransLog.Id,account.Core_Geo__c,account.Core_Sub_Geo__c,account.Core_MDF_Channel_Program__r.Name));
                    recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(accountTransLog.Id,account.Core_Geo__c,account.Core_Sub_Geo__c,account.Core_MDF_Channel_Program__r.Name,account.Core_MDF_CoMarketing_Ultimate_Account__c));
                }
                if(account.Core_MDF_Channel_Program__r.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name')){
                    Account acc =accountIdToAccountMap.get(accountTransLog.Core_MDF_Target_Account__c);
                     

                    if(acc.Core_MDF_CoMarketing_Ultimate_Account__c != account.Core_MDF_CoMarketing_Ultimate_Account__c){
                        recordGeoShareList.add(new Core_MDF_RecordGeoShare(accountTransLog.Id,acc.Core_Geo__c,acc.Core_Sub_Geo__c,acc.Core_MDF_Channel_Program__r.Name,budgetToBudgetTypeMap.get(accountTransLog.Core_MDF_Partner_Marketing_Budget__c)));
                    recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(accountTransLog.Id,acc.Core_Geo__c,acc.Core_Sub_Geo__c,acc.Core_MDF_Channel_Program__r.Name,budgetToBudgetTypeMap.get(accountTransLog.Core_MDF_Partner_Marketing_Budget__c),acc.Core_MDF_CoMarketing_Ultimate_Account__c));
                    }
                  }
            }
            //To share record on the basis of Channel Program and geo
            if(recordGeoShareList != null && recordGeoShareList.size() >0){
                Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('Core_MDF_Budget_Transfer_Log__c',recordGeoShareList);// meta data sharing
            }
            if(recordPGMShareList != null && recordPGMShareList.size() >0){
                Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('Core_MDF_Budget_Transfer_Log__c', recordPGMShareList);// internal user sharing using PGM
            }
            
            //To share budget transfer log records with external geo groups
            /*if(recordIdToGrpIdMap != null && recordIdToGrpIdMap.size() > 0){
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Budget_Transfer_Log__c',recordIdToGrpIdMap, 'Edit');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);            
            }*/
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    /*******************************************************************************************************************************
****************************************************************************************************************************/
    /***************************************************************************************************** 
        Method Name:        shareBudgetTransferToPartnerUsers
        @return  :          void
        @parameters:        newBTLTobeShared - This will contain all the budget transfer log records to be shared and accountIdGroupIdMap - map of Account Id and their external PNUM Group ids
        Description:        Whenever a record is inserted/updated of Budget Transfer log record, this method shares the record to the external users 
                            according the Account Node on which the BTL record is created
        @Added By:          Accenture - AK - 08-12-22
        Modified By:        Date:       Changes: 
    ******************************************************************************************************/
     
     public static void shareBudgetTransferToPartnerUsers(List<Core_MDF_Budget_Transfer_Log__c> newBTLTobeShared , Map<Id, Id> accountIdGroupIdMap){
        
        Map<Id,List<Id>> budgetTransferLogGroupShareList = new Map<Id,List<Id>>(); 
  
        for(Core_MDF_Budget_Transfer_Log__c btl : newBTLTobeShared)
        {      
            //For each budgettransferLogRecord add record Id and list of users to whom the record to be shared 
            if(accountIdGroupIdMap.containsKey(btl.Core_MDF_Target_Account__c) && accountIdGroupIdMap.get(btl.Core_MDF_Target_Account__c)!=null) 
            {
                budgetTransferLogGroupShareList.put(btl.Id, new list<Id> {accountIdGroupIdMap.get(btl.Core_MDF_Target_Account__c)});
            }
            if(accountIdGroupIdMap.containsKey(btl.Core_MDF_Source_Account__c) && accountIdGroupIdMap.get(btl.Core_MDF_Source_Account__c)!=null) 
            {
                if(budgetTransferLogGroupShareList.containsKey(btl.Id))
                {
                    budgetTransferLogGroupShareList.get(btl.Id).add(accountIdGroupIdMap.get(btl.Core_MDF_Source_Account__c));
                }
                else 
                {
                    budgetTransferLogGroupShareList.put(btl.Id, new list<Id> {accountIdGroupIdMap.get(btl.Core_MDF_Source_Account__c)});              
                }
            }
        }
        
         if(budgetTransferLogGroupShareList!=null && budgetTransferLogGroupShareList.size() > 0)
        {
            //Call the generic sharing method to share the list of Budget Transfer Logs records and corresponding node Groups
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Budget_Transfer_Log__c',budgetTransferLogGroupShareList, 'Edit');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
        }
         
    }
    /*********************************************************************************************************************
    *************************************************************************************************************************/
    
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
                                                                       from Core_MDF_ClaimActAllocRecTypeMapping__mdt LIMIT 1000]){
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
        for(Core_MDF_ChannelProgram__mdt progMetadata:[Select Id,Core_MDF_Technical_Program_Name__c,  Geo_Based_Sharing_Required__c from Core_MDF_ChannelProgram__mdt LIMIT 1000]){
            mapOfProgGeoBasedSharing.put(progMetadata.Core_MDF_Technical_Program_Name__c,progMetadata.Geo_Based_Sharing_Required__c);  
        }
        return mapOfProgGeoBasedSharing;
    }
}