/***************************************************************************************************************************************
Apex Class Name     : PRM_PartnerDealOpportunitySharingService 
Version             : 1.0
Created Date        : August 2026
Function            : Class to share partner deal opportunity records with account team members of partner account and end customer account
Modification Log    : 
* Developer                         Date                           Description
  Utkarsh                         
***********************************************/
public without sharing class PRM_PartnerDealOpportunitySharingService {

    private static final String ACCESS_LEVEL = 'Read';
    private static final String SHARING_REASON = 'Account_Team_Access__c';
    private static final String OPP_SHARING_REASON = 'Opportunity_Owner_Access__c';
    public static String logEntryMsgString;
    public static final String LOG_ENTRY_ORIGIN   = 'PRM_PartnerDealOpportunitySharingService';
    public static final String LOG_ENTRY_PROJECT  = 'IPA Deal';
    public static final String LOG_ENTRY_SCOPE    = 'PRM_PartnerDealOpportunitySharingService';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';

    /*Method to share PDO Record when ACCOUNT TEAM MEMBER is added on End customer or Partner Account.*/
    
    public static void createShares(List<AccountTeamMember> teamMembers) {
        logEntryMsgString+='Inside createShares '+teamMembers;
        if (teamMembers == null || teamMembers.isEmpty()) {return;
        }

        Set<Id> accountIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        Map<Id, Set<Id>> accountToUsers = new Map<Id, Set<Id>>();
        Set<Id> opportunityIds = new Set<Id>();

        for (AccountTeamMember teamMember : teamMembers) {

            if (teamMember.AccountId == null || teamMember.UserId == null) {continue;
            }

            accountIds.add(teamMember.AccountId);
            userIds.add(teamMember.UserId);

            if (!accountToUsers.containsKey(teamMember.AccountId)){
                accountToUsers.put(teamMember.AccountId,new Set<Id>());
            }
            accountToUsers.get(teamMember.AccountId).add(teamMember.UserId);
        }

        if (accountIds.isEmpty()) {return;
        }
        
        // Fetch Partner deal opportunity with partner account and end customer account
        List<PRM_Partner_Deal_Opportunity__c> opportunities = [SELECT Id,PRM_Partner_Account__c,PRM_End_Customer_Account__c FROM PRM_Partner_Deal_Opportunity__c WHERE PRM_Partner_Account__c IN :accountIds
        OR PRM_End_Customer_Account__c IN :accountIds];

        if (opportunities.isEmpty()) {return;
        }
        for (PRM_Partner_Deal_Opportunity__c opp : opportunities) {
            opportunityIds.add(opp.Id);
        }
        Set<String> existingShareKeys = new Set<String>();

        for(PRM_Partner_Deal_Opportunity__Share share : [SELECT Id,ParentId,UserOrGroupId FROM PRM_Partner_Deal_Opportunity__Share WHERE ParentId IN :opportunityIds AND UserOrGroupId IN :userIds AND RowCause = 'Account_Team_Access__c']) 
        {
            existingShareKeys.add(share.ParentId +'-' +share.UserOrGroupId);
        }

        List<PRM_Partner_Deal_Opportunity__Share> sharesToInsert = new List<PRM_Partner_Deal_Opportunity__Share>();
        for (PRM_Partner_Deal_Opportunity__c opp : opportunities) {
            Set<Id> usersForOpportunity = new Set<Id>();
            if (opp.PRM_Partner_Account__c != null && accountToUsers.containsKey(opp.PRM_Partner_Account__c)) {
                usersForOpportunity.addAll(accountToUsers.get(opp.PRM_Partner_Account__c));
            }
            if (opp.PRM_End_Customer_Account__c != null && accountToUsers.containsKey(opp.PRM_End_Customer_Account__c)){
                usersForOpportunity.addAll(accountToUsers.get(opp.PRM_End_Customer_Account__c));
            }

            for (Id userId : usersForOpportunity) {
                String shareKey = opp.Id + '-' + userId;
                if (existingShareKeys.contains(shareKey)) {continue;
                }
                PRM_Partner_Deal_Opportunity__Share shareRecord = new PRM_Partner_Deal_Opportunity__Share();
                shareRecord.ParentId = opp.Id;
                shareRecord.UserOrGroupId = userId;
                shareRecord.AccessLevel = ACCESS_LEVEL;
                shareRecord.RowCause = SHARING_REASON;
                sharesToInsert.add(shareRecord);
            }
        }
        try{
            if (!sharesToInsert.isEmpty()) {
                Database.insert(sharesToInsert,false);
            }
        }
        catch(Exception ex){
            logEntryMsgString += '\n[PDO sharing failed] ' + ex.getMessage();
        }
        finally{
            createLogEntry(logEntryMsgString);
        }
    }

    /*Method to remove PDO share when ACCOUNT TEAM MEMBER is removed from end customer or partner account.*/
    
    public static void removeShares(List<AccountTeamMember> teamMembers) {
        logEntryMsgString+='Inside removeShares '+teamMembers;
        if (teamMembers == null || teamMembers.isEmpty()) {return;
        }
        Set<Id> accountIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        for (AccountTeamMember teamMember : teamMembers) {
            if (teamMember.AccountId != null && teamMember.UserId != null){
                accountIds.add(teamMember.AccountId);
                userIds.add(teamMember.UserId);
            }
        }
        if (accountIds.isEmpty() || userIds.isEmpty()) {return;
        }
        List<PRM_Partner_Deal_Opportunity__c> opportunities = [SELECT Id,PRM_Partner_Account__c,PRM_End_Customer_Account__c FROM PRM_Partner_Deal_Opportunity__c WHERE PRM_Partner_Account__c IN :accountIds OR PRM_End_Customer_Account__c IN :accountIds];

        if (opportunities.isEmpty()) {return;
        }
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id, PRM_Partner_Deal_Opportunity__c> opportunityMap = new Map<Id, PRM_Partner_Deal_Opportunity__c>();
        for (PRM_Partner_Deal_Opportunity__c opp : opportunities) {
            opportunityIds.add(opp.Id);
            opportunityMap.put(opp.Id,opp);
        }
        Set<Id> allRelevantAccountIds = new Set<Id>();
        for (PRM_Partner_Deal_Opportunity__c opp : opportunities) {
            if (opp.PRM_Partner_Account__c != null) {
                allRelevantAccountIds.add(opp.PRM_Partner_Account__c);
            }
            if (opp.PRM_End_Customer_Account__c != null) {
                allRelevantAccountIds.add(opp.PRM_End_Customer_Account__c);
            }
        }
        Map<Id, Set<Id>> userToAccounts = new Map<Id, Set<Id>>();


        for (AccountTeamMember currentTeamMember : [SELECT Id,AccountId,UserId FROM AccountTeamMember WHERE AccountId IN :allRelevantAccountIds AND UserId IN :userIds]) {
            if (!userToAccounts.containsKey(currentTeamMember.UserId)) {
                userToAccounts.put(currentTeamMember.UserId,new Set<Id>());
            }
            userToAccounts.get(currentTeamMember.UserId).add(currentTeamMember.AccountId);
        }
        List<PRM_Partner_Deal_Opportunity__Share> existingShares = [SELECT Id,ParentId,UserOrGroupId FROM PRM_Partner_Deal_Opportunity__Share WHERE ParentId IN :opportunityIds AND UserOrGroupId IN :userIds AND RowCause = 'Account_Team_Access__c'];
        List<PRM_Partner_Deal_Opportunity__Share> sharesToDelete = new List<PRM_Partner_Deal_Opportunity__Share>();

        for (PRM_Partner_Deal_Opportunity__Share share :existingShares) {
            PRM_Partner_Deal_Opportunity__c opp =opportunityMap.get(share.ParentId);
            if (opp == null) {continue;
            }
            Set<Id> remainingAccounts = userToAccounts.get(share.UserOrGroupId);
            Boolean stillHasAccountTeamAccess = false;


            if (remainingAccounts != null) {
                if (opp.PRM_Partner_Account__c != null && remainingAccounts.contains(opp.PRM_Partner_Account__c)
                ) {
                    stillHasAccountTeamAccess = true;
                }

                if (opp.PRM_End_Customer_Account__c != null &&remainingAccounts.contains(opp.PRM_End_Customer_Account__c)
                ) {
                    stillHasAccountTeamAccess = true;
                }
            }
            if (!stillHasAccountTeamAccess) {sharesToDelete.add(share);
            }
        }
        try{
            if (!sharesToDelete.isEmpty()) {
                Database.delete(sharesToDelete,false);
            }
        }
        catch(Exception ex){
            logEntryMsgString += '\n[PDO sharing failed] ' + ex.getMessage();
        }
        finally{
            createLogEntry(logEntryMsgString);
        }
    }


    /* Method to share PDO record when PDO is created and Account Team members already exist on End customer or Partner Account.*/
    
    public static void createSharesForNewOpportunities(List<PRM_Partner_Deal_Opportunity__c> opportunities) {
        logEntryMsgString+='Inside createSharesForNewOpportunities '+opportunities;
        if (opportunities == null || opportunities.isEmpty()) {return;
        }
        Set<Id> accountIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();


        for (PRM_Partner_Deal_Opportunity__c opp : opportunities) {
            if (opp.PRM_Partner_Account__c != null) {
                accountIds.add(opp.PRM_Partner_Account__c);
            }
            if (opp.PRM_End_Customer_Account__c != null) {
                accountIds.add(opp.PRM_End_Customer_Account__c);
            }
            if (opp.Id != null) {
                opportunityIds.add(opp.Id);
            }
        }
        if (accountIds.isEmpty()) {return;
        }
        List<AccountTeamMember> teamMembers = [SELECT Id,AccountId,UserId FROM AccountTeamMember WHERE AccountId IN :accountIds];
        if (teamMembers.isEmpty()) {
            return;
        }

        Map<Id, Set<Id>> accountToUsers = new Map<Id, Set<Id>>();
        Set<Id> userIds = new Set<Id>();
        for (AccountTeamMember teamMember : teamMembers) {
            if (teamMember.AccountId == null || teamMember.UserId == null) {continue;
            }
            if (!accountToUsers.containsKey(teamMember.AccountId)
            ) {
                accountToUsers.put(teamMember.AccountId,new Set<Id>());
            }
            accountToUsers.get(teamMember.AccountId).add(teamMember.UserId);
            userIds.add(teamMember.UserId);
        }
        Set<String> existingShareKeys = new Set<String>();


        for (PRM_Partner_Deal_Opportunity__Share share : [SELECT Id,ParentId,UserOrGroupId FROM PRM_Partner_Deal_Opportunity__Share WHERE ParentId IN :opportunityIds AND UserOrGroupId IN :userIds AND RowCause = 'Account_Team_Access__c']) {
            existingShareKeys.add(share.ParentId +'-' +share.UserOrGroupId);
        }
        List<PRM_Partner_Deal_Opportunity__Share> sharesToInsert = new List<PRM_Partner_Deal_Opportunity__Share>();

        for (PRM_Partner_Deal_Opportunity__c opp : opportunities) {
            Set<Id> usersForOpportunity = new Set<Id>();
            if (opp.PRM_Partner_Account__c != null && accountToUsers.containsKey(opp.PRM_Partner_Account__c)
            ) {
                usersForOpportunity.addAll(accountToUsers.get(opp.PRM_Partner_Account__c));
            }
            if (opp.PRM_End_Customer_Account__c != null && accountToUsers.containsKey(opp.PRM_End_Customer_Account__c)){
                usersForOpportunity.addAll(accountToUsers.get(opp.PRM_End_Customer_Account__c));
            }
            for (Id userId : usersForOpportunity) {
                String shareKey = opp.Id + '-' + userId;
                if (existingShareKeys.contains(shareKey)) {
                    continue;
                }
                PRM_Partner_Deal_Opportunity__Share shareRecord = new PRM_Partner_Deal_Opportunity__Share();
                shareRecord.ParentId = opp.Id;
                shareRecord.UserOrGroupId = userId;
                shareRecord.AccessLevel = ACCESS_LEVEL;
                shareRecord.RowCause = SHARING_REASON;
                sharesToInsert.add(shareRecord);
            }
        }
        try{
            if (!sharesToInsert.isEmpty()) {
                Database.insert(sharesToInsert,false);
            }
        }
        catch(Exception ex){
            logEntryMsgString += '\n[PDO sharing failed] ' + ex.getMessage();
        }
        finally{
            createLogEntry(logEntryMsgString);
        }
    }
    
    /* Method to share PDO with opportunity owner.*/
    
    public static void shareWithOpportunityOwner(List<PRM_Partner_Deal_Opportunity__c> newRecords,Map<Id, PRM_Partner_Deal_Opportunity__c> oldMap) 
    {
        logEntryMsgString+='Inside createSharesForNewOpportunities '+newRecords;
        Set<Id> opportunityIds = new Set<Id>();
        List<PRM_Partner_Deal_Opportunity__Share> shares = new List<PRM_Partner_Deal_Opportunity__Share>();
        for (PRM_Partner_Deal_Opportunity__c pdo : newRecords) {
            if (pdo.PRM_Sales_Opportunity__c != null) {
                if (oldMap == null ||
                    oldMap.get(pdo.Id).PRM_Sales_Opportunity__c != pdo.PRM_Sales_Opportunity__c) {
                    opportunityIds.add(pdo.PRM_Sales_Opportunity__c);
                }
            }
        }
        if (opportunityIds.isEmpty()) {
            return;
        }
        Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([SELECT Id, OwnerId FROM Opportunity WHERE Id IN :opportunityIds]);
        for (PRM_Partner_Deal_Opportunity__c pdo : newRecords) {
            if (pdo.PRM_Sales_Opportunity__c == null) {
                continue;
            }

            Opportunity opp = opportunities.get(pdo.PRM_Sales_Opportunity__c);

            if (opp == null ||opp.OwnerId == null) {
                continue;
            }

            PRM_Partner_Deal_Opportunity__Share share = new PRM_Partner_Deal_Opportunity__Share();
            share.ParentId = pdo.Id;
            share.UserOrGroupId = opp.OwnerId;
            share.AccessLevel = 'Read';
            share.RowCause = OPP_SHARING_REASON;
            shares.add(share);
        }
        try{
            if (!shares.isEmpty()) {
                Database.insert(shares, false);
            }
        }
        catch(Exception ex){
            logEntryMsgString += '\n[PDO sharing failed] ' + ex.getMessage();
        }
        finally{
            createLogEntry(logEntryMsgString);
        }
    }
    
    /* Method to recalculate PDO record share when opportunity owner updates.*/
    
    public static void updateOpportunityOwnerSharing(Set<Id> opportunityIds) {
        logEntryMsgString+='Update share when ownerId on opportunity is updated '+opportunityIds;
        if (opportunityIds == null || opportunityIds.isEmpty()) {
            return;
        }
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([SELECT Id,OwnerId FROM Opportunity WHERE Id IN :opportunityIds]);

        List<PRM_Partner_Deal_Opportunity__c> pdoList = [SELECT Id,PRM_Sales_Opportunity__c FROM PRM_Partner_Deal_Opportunity__c WHERE PRM_Sales_Opportunity__c IN :opportunityIds];

        if (pdoList.isEmpty()) {
            return;
        }
        List<PRM_Partner_Deal_Opportunity__Share> existingShares = [SELECT Id FROM PRM_Partner_Deal_Opportunity__Share
            WHERE ParentId IN :new Map<Id, PRM_Partner_Deal_Opportunity__c>(pdoList).keySet()
            AND RowCause = :Schema.PRM_Partner_Deal_Opportunity__Share.RowCause.Opportunity_Owner_Access__c
        ];
        try{
            if (!existingShares.isEmpty()) {
                Database.delete(existingShares, false);
            }
        }
        catch(Exception ex){
            logEntryMsgString += '\n[PDO sharing failed] ' + ex.getMessage();
        }
        List<PRM_Partner_Deal_Opportunity__Share> newShares = new List<PRM_Partner_Deal_Opportunity__Share>();
        for (PRM_Partner_Deal_Opportunity__c pdo : pdoList) {
            Opportunity opp = opportunityMap.get(pdo.PRM_Sales_Opportunity__c);
            if (opp == null ||
                opp.OwnerId == null) {
                continue;
            }

            PRM_Partner_Deal_Opportunity__Share share = new PRM_Partner_Deal_Opportunity__Share();
            share.ParentId = pdo.Id;
            share.UserOrGroupId = opp.OwnerId;
            share.AccessLevel = 'Read';
            share.RowCause = OPP_SHARING_REASON;
            newShares.add(share);
        }
        try{
            if (!newShares.isEmpty()) {
                Database.insert(newShares, false);
            }
        }
        catch(Exception ex){
            logEntryMsgString += '\n[PDO sharing failed] ' + ex.getMessage();
        }
        finally{
            createLogEntry(logEntryMsgString);
        }
    }
    
    /* Method to recalculate PDO record share when end customer updates on PDO.*/
    
    public static void handleEndCustomerAccountChange(List<PRM_Partner_Deal_Opportunity__c> newRecords,Map<Id, PRM_Partner_Deal_Opportunity__c> oldMap) 
    {
        logEntryMsgString+='Update share when end customer accout is updated '+newRecords;
        Set<Id> oldEndCustomerAccountIds = new Set<Id>();
        Set<Id> pdoIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id, Set<Id>> accountToUsers = new Map<Id, Set<Id>>();
        Set<Id> oldEndCustomerUsers = new Set<Id>();
        Set<Id> partnerAccountIds = new Set<Id>();
        Set<Id> partnerUsers = new Set<Id>();
        Set<Id> usersToRemove = new Set<Id>();
        List<Account> accListToUpdate = new List<Account>();
        List<OpportunityShare> opportunitySharesToDelete = new List<OpportunityShare>();
        List<PRM_Partner_Deal_Opportunity__Share> pdoSharesToDelete = new List<PRM_Partner_Deal_Opportunity__Share>();

        for (PRM_Partner_Deal_Opportunity__c newPDO : newRecords) {
            PRM_Partner_Deal_Opportunity__c oldPDO = oldMap.get(newPDO.Id);
            if (oldPDO != null &&oldPDO.PRM_End_Customer_Account__c !=newPDO.PRM_End_Customer_Account__c) {
                pdoIds.add(newPDO.Id);
                if (oldPDO.PRM_End_Customer_Account__c != null) {
                    oldEndCustomerAccountIds.add(oldPDO.PRM_End_Customer_Account__c);
                }
            }
        }
        system.debug('oldEndCustomerAccountIds-->'+oldEndCustomerAccountIds);
        if (pdoIds.isEmpty() || oldEndCustomerAccountIds.isEmpty()) {
            return;
        }
        
        // Update end customer flag on account if end customer changes on PDO.
        for(Account acc : [Select id,name,PRM_Is_Deal_End_Customer_Account__c from Account where Id IN :oldEndCustomerAccountIds]){
            if(acc.PRM_Is_Deal_End_Customer_Account__c == true){
                acc.PRM_Is_Deal_End_Customer_Account__c = false;
                accListToUpdate.add(acc);
            }
        }
        system.debug('accListToUpdate--->'+accListToUpdate);
        Database.update(accListToUpdate, false);
        
        for (AccountTeamMember teamMember : [SELECT AccountId,UserId FROM AccountTeamMember WHERE AccountId IN :oldEndCustomerAccountIds AND UserId != null]) {
            system.debug('came here--->'+accountToUsers);
            if (!accountToUsers.containsKey(teamMember.AccountId)) {
                accountToUsers.put(teamMember.AccountId,new Set<Id>());
            }
            accountToUsers.get(teamMember.AccountId).add(teamMember.UserId);
            system.debug('came here--->'+accountToUsers);
        }

        for (Set<Id> users : accountToUsers.values()) {
            oldEndCustomerUsers.addAll(users);
        }
        if (oldEndCustomerUsers.isEmpty()) {
            return;
        }
        Map<Id, PRM_Partner_Deal_Opportunity__c> pdoMap = new Map<Id, PRM_Partner_Deal_Opportunity__c>([SELECT Id,PRM_Partner_Account__c,PRM_End_Customer_Account__c,PRM_Sales_Opportunity__c FROM PRM_Partner_Deal_Opportunity__c WHERE Id IN :pdoIds]);
        
        for (PRM_Partner_Deal_Opportunity__c pdo : pdoMap.values()) {
            if (pdo.PRM_Partner_Account__c != null) {
                partnerAccountIds.add(pdo.PRM_Partner_Account__c);
            }
            system.debug('came here 1--->'+partnerAccountIds);
        }
        if (!partnerAccountIds.isEmpty()) {
            for (AccountTeamMember teamMember : [SELECT UserId FROM AccountTeamMember WHERE AccountId IN :partnerAccountIds
                AND UserId IN :oldEndCustomerUsers
            ]) {
                partnerUsers.add(teamMember.UserId);
            }
        }
        
        usersToRemove.addAll(oldEndCustomerUsers);
        usersToRemove.removeAll(partnerUsers);

        if (usersToRemove.isEmpty()) {
            return;
        }
        for (PRM_Partner_Deal_Opportunity__Share shareRecord : [SELECT Id,ParentId,UserOrGroupId FROM PRM_Partner_Deal_Opportunity__Share WHERE ParentId IN :pdoIds AND UserOrGroupId IN :usersToRemove
            AND RowCause = 'Account_Team_Access__c'
        ]) {
            pdoSharesToDelete.add(shareRecord);
        }
        try{
            
            if (!accListToUpdate.isEmpty()) {
                //Database.update(accListToUpdate, false);
            }
            if (!pdoSharesToDelete.isEmpty()) {
            Database.delete(pdoSharesToDelete, false);
            }
        }
        catch(Exception ex){
            logEntryMsgString += '\n[PDO sharing failed] ' + ex.getMessage();
        }
        for (PRM_Partner_Deal_Opportunity__c pdo : pdoMap.values()) {
            if (pdo.PRM_Sales_Opportunity__c != null) {
                opportunityIds.add(pdo.PRM_Sales_Opportunity__c);
            }
        }
        if (opportunityIds.isEmpty()) {
            return;
        }
        for (OpportunityShare shareRecord : [SELECT Id,OpportunityId,UserOrGroupId FROM OpportunityShare WHERE OpportunityId IN :opportunityIds AND UserOrGroupId IN :usersToRemove
            AND RowCause = 'Manual'
        ]) {
            opportunitySharesToDelete.add(shareRecord);
        }
        try{
            if (!opportunitySharesToDelete.isEmpty()) {
                Database.delete(opportunitySharesToDelete, false);
            }
        }
        catch(Exception ex){
            logEntryMsgString += '\n[PDO sharing failed] ' + ex.getMessage();
        }
        // Update end customer flag on account if end customer changes on PDO.
        /*for(Account acc : [Select id,name,PRM_Is_Deal_End_Customer_Account__c from Account where Id IN :oldEndCustomerAccountIds]){
            if(acc.PRM_Is_Deal_End_Customer_Account__c == true){
                acc.PRM_Is_Deal_End_Customer_Account__c = false;
                accListToUpdate.add(acc);
            }
        }
        system.debug('accListToUpdate--->'+accListToUpdate);
        try{
            if (!accListToUpdate.isEmpty()) {
                Database.update(accListToUpdate, false);
            }
        }
        catch(Exception ex){
            logEntryMsgString += '\n[Account update failed] ' + ex.getMessage();
        }
        finally{
            createLogEntry(logEntryMsgString);
        }*/
    }
    
    /* Method to remove PDO record share when opportunity removes from PDO.*/
    
    public static void removeOpportunityOwnerSharing(List<PRM_Partner_Deal_Opportunity__c> newRecords,Map<Id, PRM_Partner_Deal_Opportunity__c> oldMap) {
        logEntryMsgString+='Update share when sales opportunity is removed '+newRecords;
        Set<Id> pdoIds = new Set<Id>();
        for (PRM_Partner_Deal_Opportunity__c pdo : newRecords) {
            PRM_Partner_Deal_Opportunity__c oldPdo = oldMap.get(pdo.Id);
            if (oldPdo.PRM_Sales_Opportunity__c != null && pdo.PRM_Sales_Opportunity__c == null) {
                pdoIds.add(pdo.Id);
            }
        }
        if (pdoIds.isEmpty()) {
            return;
        }

        List<PRM_Partner_Deal_Opportunity__Share> sharesToDelete = [SELECT Id FROM PRM_Partner_Deal_Opportunity__Share WHERE ParentId IN :pdoIds AND RowCause =:OPP_SHARING_REASON
        ];
        try{
            if (!sharesToDelete.isEmpty()) {
                Database.delete(sharesToDelete, false);
            }
        }
        catch(Exception ex){
            logEntryMsgString += '\n[PDO sharing failed] ' + ex.getMessage();
        }
        finally{
            createLogEntry(logEntryMsgString);
        }
    }
    public static void createLogEntry(String logEntryMsgString){
        string jobInitiatedDateTime = System.Now().format('MM/dd/YYYY HH:MM:SS','PST');
        if(logEntryMsgString!=''){// this block will create Log Entry records on the basis of length of logEntryMsg and Field limit.
            PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility=new PRM_ProcessInboundOPIDLogEntriesUtility();
            Integer fieldLength=Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength();
            logEntryUtility.addLogEntry(logEntryMsgString,fieldLength);
            for(Integer i=0; i<logEntryUtility.logEntryList.size();i++){
               Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'Job started at: '+ jobInitiatedDateTime +' PST' ,logEntryUtility.logEntryList[i] , '', '', '');
            }
        }
    }
}