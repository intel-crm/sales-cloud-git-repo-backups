/****************************************************************************************************************************************
* Class Name        : Core_MDF_ShareBanktoBudgetAdmins
* Created Date      : 11-30-2018
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - Kushal       11/30/2018          It is batch class which shares bank record with user when they are elevated with 
AccountBudgetAdmin Permission Set.
*****************************************************************************************************************************************/

global class Core_MDF_ShareBanktoBudgetAdmins implements Database.Batchable<sObject>, Database.Stateful {
    
    //Will be used in the query
    global static String spaceStr = ' ';
    
    //Will be used in the query
    global static String singleQuoteStr = '\'';
    
    /***************************************************************************************************** 
    Method Name :   start
    @return     :   List of partner group mapping object records
    @parameters :   Database.BatchableContext
    Description :   It fetches all object data of PGM
    Added By    :   Intel - Kushal 
    Modified By :   Accenture - AS                  Date:11/28/2018                     Changes:None                               
    ******************************************************************************************************/  
        
    global Database.QueryLocator start(Database.BatchableContext bc) {
        try{
            //SELECT Id, Core_MDF_Account__c, Core_MDF_Account__r.RecordType.Name,Core_MDF_Group_Id__c, Core_MDF_Channel_Program__r.Name, 
            //       Core_MDF_Type_of_Access__c
            //FROM Core_MDF_Partner_Group_Mapping__c 
            //WHERE Core_MDF_Type_of_Access__c = 'External' AND 
            //      Core_MDF_Account__r.RecordType.DeveloperName = 'Mastered_Account' AND
            //      Core_MDF_Account__c = '0013D00000fCx4O'
            //LIMIT 50000
            String strQuery = Label.Core_MDF_Query1 + singleQuoteStr + Label.Core_MDF_External + singleQuoteStr + spaceStr + Label.Core_MDF_Query2 + 
                singleQuoteStr  + Label.Core_MDF_MasterAccount + singleQuoteStr + spaceStr + Label.Core_MDF_Query3 ;
            
            return Database.getQueryLocator(strQuery);
        }catch(Exception e){String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e);Core_MDF_BankServiceHandler.logErrorinLogObjectWithReason(errorDetails,Label.Core_MDF_OriginName);return NULL;}
    }
    
    /******************************************************************************************************** 
    Method Name :   execute
    @return     :   void
    @parameters :   Database.BatchableContext,
    Description :   Creates a bank to user list map which is shared with respective banks
    Added By    :   Intel - Kushal 
    Modified By :   Accenture - AS          Date:11/30/2018     Changes:None  
    Modified By :   Intel - Areefa          Date:13/02/2019     Changes: added code for SPCF records sharing
    Modified By :   Accenure - NZ           Date:07/31/2019     Changes: Made the class Generic to remove Program dependency
    **********************************************************************************************************/ 
    
    global void execute(Database.BatchableContext bc, List<Core_MDF_Partner_Group_Mapping__c> scope){
        Map<Id, List<Core_MDF_Partner_Group_Mapping__c>> accountPGMMap = new Map<Id, List<Core_MDF_Partner_Group_Mapping__c>>();
        Set<Id> groupIds = new Set<Id>();
        Set<Id> extBudgetAdminUsrids = new Set<Id>();       
        Set<Id> budgetAdminIds = new Set<Id>();
        Map<Id,Set<Id>> groupIdABAUserIdSetMap = new Map<Id,Set<Id>>();
        //key -> program Id, value -> Map<Id,Set<Id>> -> key -> accountId, value -> Set of Budget Admin Ids
        Map<Id, Map<Id,Set<Id>>> programIdAccIdABAUserIdSetMap = new Map<Id, Map<Id,Set<Id>>>();
        Map<Id, List<Id>> bankIdUserIdMap = new Map<Id, List<Id>>();
        //key -> program Id, value -> Set of Budget Admin Ids
        Map<Id,Set<Id>> programIdUserIdsSetMap = new Map<Id,Set<Id>>();
        Set<Id> bankIdSet = new Set<Id>();
        
        try{
            // Map of Channel Program Id and Channel Program Name
            Map <String , String> channelProgramNameMap = new Map<String , String>();
            Map <String , String> channelProgramNameSetMap = new Map<String, String>();
            
            for(Core_MDF_BankProgram_Entitlement_Mapping__mdt bpem : ([SELECT Core_MDF_Bank_Program_Name__c, Core_MDF_Channel_Program__c, Core_MDF_Entitlement_Name__c
                                                                       FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt])){
                channelProgramNameMap.put(bpem.Core_MDF_Channel_Program__c, bpem.Core_MDF_Bank_Program_Name__c);  
            }
            // Get Channel program Id and Core_MDF name
            for (ChannelProgram cpRecord : [SELECT Id, Name
                                            FROM ChannelProgram
                                            WHERE Name IN :channelProgramNameMap.keySet()
                                            ORDER BY CreatedDate] ){
                if(cpRecord.Name != NULL){
                    channelProgramNameSetMap.put(channelProgramNameMap.get(cpRecord.Name), cpRecord.Id);
                }
            }
            
            for (Core_MDF_Partner_Group_Mapping__c pgm : scope){
                groupIds.add(pgm.Core_MDF_Group_Id__c); // contains userIds from the group
                
                if(accountPGMMap.containsKey(pgm.Core_MDF_Account__c)){
                    accountPGMMap.get(pgm.Core_MDF_Account__c).add(pgm);
                } else{
                    accountPGMMap.put(pgm.Core_MDF_Account__c, new list<Core_MDF_Partner_Group_Mapping__c> {pgm});
                } 
            }
            
            // Query users with budget admin PS 
            for (PermissionSetAssignment psa : [SELECT AssigneeId,Id,PermissionSet.Name,PermissionSetId FROM PermissionSetAssignment 
                                                WHERE PermissionSet.Name = :Label.Core_MDF_External_Account_Budget_Administrator
                                                AND Assignee.IsActive = true]){
                extBudgetAdminUsrids.add(psa.AssigneeId);
            } 
            
            // Map of groupIds with their Budget Admins 
            if(!groupIds.isEmpty()){
                for(GroupMember groupmem : [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN: groupIds]){
                    if(extBudgetAdminUsrids.contains(groupmem.UserOrGroupId)){                 
                        if(groupIdABAUserIdSetMap.containsKey(groupmem.GroupId)){
                            groupIdABAUserIdSetMap.get(groupmem.GroupId).add(groupmem.UserOrGroupId);
                        }
                        else{
                            groupIdABAUserIdSetMap.put(groupmem.GroupId,new Set<Id> {groupmem.UserOrGroupId});
                        }
                    }
                }
            }
            
            // Create Generic Map of Program Id + Account Id as key and Account Budget Admin User Ids as values
            for (Core_MDF_Partner_Group_Mapping__c pgm : scope){
                //if Group Id from the PGM exists in the groupIdABAUserIdSetMap
                if(pgm.Core_MDF_Group_Id__c != NULL && groupIdABAUserIdSetMap.containsKey(pgm.Core_MDF_Group_Id__c)){
                    //Channel Program already exists in the programIdAcctIdBudgetAdminIdSetMap
                    if(pgm.Core_MDF_Channel_Program__c != NULL && programIdAccIdABAUserIdSetMap.containsKey(pgm.Core_MDF_Channel_Program__c)){
                        
                        Map<Id, Set<Id>> accIdABAIdSetMap = new Map<Id, Set<Id>>();
                        accIdABAIdSetMap = programIdAccIdABAUserIdSetMap.get(pgm.Core_MDF_Channel_Program__c);
                        //there are 2 entries for same account in PGM for External Type
                        if(accIdABAIdSetMap.containsKey(pgm.Core_MDF_Account__c)){
                            Set<Id> userIdSet = accIdABAIdSetMap.get(pgm.Core_MDF_Account__c);
                            userIdSet.addAll(groupIdABAUserIdSetMap.get(pgm.Core_MDF_Group_Id__c));
                            accIdABAIdSetMap.put(pgm.Core_MDF_Account__c,userIdSet);                                
                        }
                        else{
                            accIdABAIdSetMap.put(pgm.Core_MDF_Account__c,groupIdABAUserIdSetMap.get(pgm.Core_MDF_Group_Id__c));
                        }
                        programIdAccIdABAUserIdSetMap.put(pgm.Core_MDF_Channel_Program__c, accIdABAIdSetMap);
                    }
                    else{//Channel Program already does not exist in the programIdAccIdABAUserIdSetMap
                        Map<Id,Set<Id>> accIdABAIdSetMap = new Map<Id,Set<Id>>();
                        accIdABAIdSetMap.put(pgm.Core_MDF_Account__c,groupIdABAUserIdSetMap.get(pgm.Core_MDF_Group_Id__c));
                        programIdAccIdABAUserIdSetMap.put(pgm.Core_MDF_Channel_Program__c, accIdABAIdSetMap);
                    }
                    
                }
                
            }
            
            //Mapping AccountId with the list of userIds to share
            for(Core_MDF_Bank__c bankVar : [SELECT Id,Core_MDF_Account__c,Core_MDF_Program__c, Core_MDF_Program_Value__c
                                            FROM Core_MDF_Bank__c 
                                            WHERE Core_MDF_Account__c IN :accountPGMMap.keySet()]){
				bankIdSet.add(bankVar.Id);
                List<String> programList = bankVar.Core_MDF_Program__c.split(';');
                for(String prgm : programList){
                    //programIdAccIdABAUserIdSetMap = new Map<Id, Map<Id,Set<Id>>>();
                    //channelProgramNameSetMap = new Map<String, String>();
                    if(channelProgramNameSetMap.containsKey(prgm) &&
                       programIdAccIdABAUserIdSetMap.containsKey(channelProgramNameSetMap.get(prgm))){
                        if(bankVar.Core_MDF_Account__c != NULL && 
                           programIdAccIdABAUserIdSetMap.get(channelProgramNameSetMap.get(prgm)).containsKey(bankVar.Core_MDF_Account__c)){
                            for(Id userId : programIdAccIdABAUserIdSetMap.get(channelProgramNameSetMap.get(prgm)).get(bankVar.Core_MDF_Account__c)){
                                if(programIdUserIdsSetMap.containsKey(userId) != NULL){ 
                                    if(bankIdUserIdMap.containsKey(bankVar.Id)){
                                        bankIdUserIdMap.get(bankVar.Id).add(userId);
                                    }
                                    else{
                                        bankIdUserIdMap.put(bankVar.Id, new List<Id>{userId});
                                    }
                                }
                            }  
                        }
                    }
                    
                }
            }
                        
            // fetch all records from Bank Share object with row cause AccountBudgetAdmin
            List<Core_MDF_Bank__Share> banksShareList = [SELECT ParentId,UserOrGroupId FROM Core_MDF_Bank__Share
                                                         WHERE RowCause =: Schema.Core_MDF_Bank__Share.RowCause.AccountBudgetAdmin__c AND 
                                                               ParentId IN :bankIdSet];
                                                               
			//Delete Records from BankShare object
            if(banksShareList != NULL && banksShareList.size() > 0){
                delete banksShareList;
            }
            //SELECT RowCause, AccessLevel, UserOrGroupId, ParentId, Id FROM Core_MDF_Bank__Share
            List<Core_MDF_Bank__Share> bankShareList = new List<Core_MDF_Bank__Share>();
            
            //Share all entries from bankIdUserIdMap
            for(Id bm : bankIdUserIdMap.keySet()){
                for(Id userId : bankIdUserIdMap.get(bm)){
                    Core_MDF_Bank__Share bankShare = new Core_MDF_Bank__Share();
                    bankShare.ParentId = bm;
                    bankShare.UserOrGroupId = userId;
                    bankShare.RowCause = Schema.Core_MDF_Bank__Share.RowCause.AccountBudgetAdmin__c;
                    bankShare.AccessLevel = Label.Core_MDF_Read_Access;
                    bankShareList.add(bankShare);
                }
            }
            
            if(bankShareList.size() > 0){
                insert bankShareList;
            }
            /*if(bankIdUserIdMap != NULL && bankIdUserIdMap.size() > 0){
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Bank__c',bankIdUserIdMap, 'Edit', Schema.Core_MDF_Bank__Share.RowCause.AccountBudgetAdmin__c);
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
            }*/
        }catch(Exception e){String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e);Core_MDF_BankServiceHandler.logErrorinLogObjectWithReason(errorDetails,Label.Core_MDF_OriginName);}
    }
    
    /***************************************************************************************************** 
    Method Name :   finish
    @return     :   void
    @parameters :   Database.BatchableContext
    Description :   
    Added By    :   Accenture - AS
    Modified By :                        Date:11/30/2018                     Changes:None                         
    ******************************************************************************************************/
        
    global void finish(Database.BatchableContext bc){
        
        
    }
}