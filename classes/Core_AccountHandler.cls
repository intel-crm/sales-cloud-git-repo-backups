/**************************************************************************************
Apex Class Name:  Core_AccountHandler
Version     : 1.0 
Created Date: 13 NOV 2014
Function    : methods to handle Account Trigger functions
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             11/13/2014              Original Version
* Brian Matthews            12/3/2014               After-Delete added 
* Brian Matthews            4/22/2015               LoadCPMID255 added
* Kalpana Choudhary         17/10/2015              Added deleteSalesoutShairing
*************************************************************************************/
public class Core_AccountHandler{

    public static final String CPMID_DELIMITER       = ', ';  
    public static final String CPMID_DELIMITER_REGEX = '(,[\\s]*|\\s)';  // Delimiters: comma, or a blank, or any combination
    
    /*
    * Method name  : AccountObjectBeforeHandler
    * Description  : Matches the Billing state in the accounts and populates Geo/Sub Geo fields 
    * Return Type  : VOID
    * Parameter    : List Trigger.new, MAP Trigger.newmap,MAP Trigger.oldmap,Country field of Sobject
    */     
    public static void accountObjectBeforeHandler(List<Account> listNewAccount, Map<Id,Account> mapNewsObject, Map<Id,Account> mapOldsObject)
    {
        //Call the method to populate both Geo & Sub Geo fields using the Country State Reference object
        //Core_Utility.sObjectGeoMappingField(listNewAcccount,mapNewsObject,mapOldsObject,'BillingCountryCode','BillingStateCode','Core_Geo__c','Core_Sub_Geo__c','Account');

        loadCPMID255(listNewAccount, mapOldsObject);

        Core_Utility.sObjectGeoMappingField(listNewAccount, mapOldsObject, new list<String>{'BillingCountry', 'BillingCountryCode'}, 
                                                new list<String>{'BillingState', 'BillingStateCode'}, 'Core_Geo__c','Core_Sub_Geo__c');
    }
    
    
    private static void loadCPMID255(List<Account> accounts, Map<Id, Account> mapOldsObject)
    {
        final integer MAX_FIELD_LENGTH     = 255;

        String newStr;
        String cpmIdStr;
        List<String> cpmIdList = new List<String>();
        for (Account acct : accounts)
        {
            // Set to TRUE for initial load
            if (TRUE ||
                Trigger.isInsert || 
               (mapOldsObject.get(acct.Id) == null) ||
               (acct.Core_CPM_ID__c != mapOldsObject.get(acct.Id).Core_CPM_ID__c))
            {
                System.debug('Evaluating CPM ID');
                cpmIdStr = acct.Core_CPM_ID__c;
                if (string.isblank(cpmIdStr))
                    continue;
                
                cpmIdList.clear();
                cpmIdList = cpmIdStr.split(CPMID_DELIMITER_REGEX);
                
                if (cpmIdList.size() == 1)
                    cpmIdStr = cpmIdList[0];
                else
                {                
                    cpmIdStr = '';
                    newStr   = '';
                    for (String cpmStr : cpmIdList)
                    {
                        if (string.isblank(cpmStr))
                            continue;
                            
                        newStr = cpmIdStr + cpmStr;
                        if (newStr.length() > MAX_FIELD_LENGTH)
                            break;
                        else
                            cpmIdStr = newStr + CPMID_DELIMITER;  
                            
                        System.debug('cpmIdStr = ' + cpmIdStr);     
                    }    
                    
                    while (cpmIdStr.right(2) == CPMID_DELIMITER)
                        cpmIdStr = cpmIdStr.removeEnd(CPMID_DELIMITER);
                }
                                        
                // In the unlikely event that somehow something greater than 255 characters was created . . .
                if (cpmIdStr.length() > MAX_FIELD_LENGTH)        
                    cpmIdStr = cpmIdStr.left(MAX_FIELD_LENGTH);
                               
                acct.Core_CPM_ID_255__c = cpmIdStr;         
            }
        }        
    }
    
    public static void accountTeamAuditCompletion(List<Account> newList, Map<Id,Account> oldMap) {
        List<Id> auditCompletedAccounts = new List<Id>();

        //Get a list of all accounts whose audit was just marked complete, 
        //and the due date is not being changed to null at the same time.
        //The audit initialization process (Core_AccountTeamAuditInitialize) marks 
        //all audits as complete and clears due dates to prepare for the next round             
        //of audit.  We don't want to log the audit as complete in that case.
        
        for(Account newAcc:newList) {                    
            if ((newAcc.Core_Account_Team_Audit_Complete__c == true && oldMap.get(newAcc.Id).Core_Account_Team_Audit_Complete__c == false)
                && (newAcc.Core_Account_Team_Audit_Due_Date__c != null)) {
                    auditCompletedAccounts.add(newAcc.Id);
                }
        }
        
        //Get a list of associated audit log entries
        List<Core_Audit_Log__c> logsToUpdate = [SELECT Id, Core_Completed_Time__c, Core_Completed_By_User__c 
                                                FROM Core_Audit_Log__c 
                                                WHERE Core_Account__c IN :auditCompletedAccounts AND Core_Event_Type__c = 'Account Team Audit'];
        
        Datetime completedTime = System.now();
        for(Core_Audit_Log__c log:logsToUpdate) {
            if(log.Core_Completed_Time__c == null) { //only update if not previously completed
                log.Core_Completed_Time__c = completedTime;
                log.Core_Completed_By_User__c = UserInfo.getUserId();            
            }
        }
        
        update logsToUpdate;
    }
    

    public static void accountObjectAfterDelete(List<Account> newList, Map<Id,Account> newMap, List<Account> oldList, Map<Id,Account> oldMap)
    { 
        System.debug('accountObjectAfterDelete : START');
        try {                    
            List<Core_Integration_Outbound_Message__c> msgList;        
            Set<Id> dupeCheck = new Set<Id>();
            for (Account account: oldList) {
                        
                if (dupeCheck.contains(account.Id))
                    continue;
                else
                    dupeCheck.add(account.Id);    
    
                System.debug('IOM Message create for ' + account.Id);
    
                // Get a fresh instance for each use.
                JSONGenerator jsonGen = JSON.createGenerator(false);                    
                jsonGen.writeStartObject();
                jsonGen.writeStringField('BillingCity',                     (string.isblank(account.BillingCity)                    ? '' : account.BillingCity));
                jsonGen.writeStringField('BillingCountry',                  (string.isblank(account.BillingCountry)                 ? '' : account.BillingCountry));
                jsonGen.writeStringField('BillingCountryCode',              (string.isblank(account.BillingCountryCode)             ? '' : account.BillingCountryCode));
                jsonGen.writeStringField('BillingPostalCode',               (string.isblank(account.BillingPostalCode)              ? '' : account.BillingPostalCode));
                jsonGen.writeStringField('BillingState',                    (string.isblank(account.BillingState)                   ? '' : account.BillingState));
                jsonGen.writeStringField('BillingStateCode',                (string.isblank(account.BillingStateCode)               ? '' : account.BillingStateCode));
                jsonGen.writeStringField('BillingStreet',                   (string.isblank(account.BillingStreet)                  ? '' : account.BillingStreet));                        
                jsonGen.writeStringField('Core_Account_Country__c',         (string.isblank(account.Core_Account_Country__c)        ? '' : account.Core_Account_Country__c));                        
                jsonGen.writeStringField('Core_Account_State_Province__c',  (string.isblank(account.Core_Account_State_Province__c) ? '' : account.Core_Account_State_Province__c));                        
                jsonGen.writeStringField('Core_CIM_ID__c',                  (string.isblank(account.Core_CIM_ID__c)                 ? '' : account.Core_CIM_ID__c));
                jsonGen.writeStringField('Id',                              account.Id);
                jsonGen.writeStringField('Name',                            (string.isblank(account.Name)                           ? '' : account.Name));
                jsonGen.writeEndObject();
                                                                                       
                Core_Integration_Outbound_Message__c msgObj = new Core_Integration_Outbound_Message__c (Core_MessageType__c = 'AccountMerge', Core_Payload__c = jsonGen.getAsString());                  
                
                if (msgList == null)
                    msgList = new List<Core_Integration_Outbound_Message__c>();
                
                msgList.add(msgObj);    
            }    
            
            if (msgList != null)
                insert msgList;    
        }
        catch(Exception e){
            //If there is any exception, append it to the list of sobject records
            for(Account account : oldList)
                account.addError(System.Label.Core_Exception+e.getMessage());                          
        }    
        
        System.debug('accountObjectAfterDelete : END');        
    }
 
	// Zay 2/7/2017 US58646 - Prevent an account going from covered to uncovered if B2B entitlements exist
    public static void preventUncoveredAccountChange(List<Account> newList, Map<Id, Account> oldMap) {
        List<Account> accountsChangedToUncovered = new List<Account>();
        for(Account acctObj : newList) {
            if(acctObj.OwnerId == Label.Core_Uncovered_Account_ID && oldMap.get(acctObj.Id).OwnerId != Label.Core_Uncovered_Account_ID) {
                accountsChangedToUncovered.add(acctObj);
            }
        }
        if(accountsChangedToUncovered != null && !accountsChangedToUncovered.isEmpty()) {
            List<Contact> lContacts = new List<Contact>();
            List<Core_Contact_Entitlement__c> lContactEntitlements = new List<Core_Contact_Entitlement__c>();
            List<Core_Contact_Entitlement__c> lContactEntitlementsForASingleObject = new List<Core_Contact_Entitlement__c>();
            Map<Account, List<Core_Contact_Entitlement__c>> mAccountsToContactEntilements = new Map<Account, List<Core_Contact_Entitlement__c>>();
            Map<Contact, List<Core_Contact_Entitlement__c>> mContactsToContactEntilements = new Map<Contact, List<Core_Contact_Entitlement__c>>();
            lContacts = [Select id, name, Core_Contact_B2B_Indicator__c, AccountId FROM Contact WHERE AccountId IN :accountsChangedToUncovered];
            lContactEntitlements = [Select id, Core_Contact_Id__c, Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_DeDup_Number__c
                                   FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c IN :lContacts
                                   AND Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_DeDup_Number__c = 'B2B'
                                   AND Core_Selected__c = true];
            // Create Map of Contacts to a List of Core_Contact_Entitlements
            for(Contact conObj : lContacts) {
                lContactEntitlementsForASingleObject = new List<Core_Contact_Entitlement__c>();
                for(Core_Contact_Entitlement__c contactEntitlementObj : lContactEntitlements) {
                    if(contactEntitlementObj.Core_Contact_Id__c == conObj.Id) {
                        lContactEntitlementsForASingleObject.add(contactEntitlementObj);
                    }
                }
                mContactsToContactEntilements.put(conObj, lContactEntitlementsForASingleObject);
            } 
            // Create Map of Accounts to a List of Core_Contact_Entitlements
            for(Account acctObj : accountsChangedToUncovered) {
                for(Contact conObj : mContactsToContactEntilements.keySet()) {
                    if(conObj.AccountId == acctObj.Id) {
                        if(mContactsToContactEntilements.get(conObj).size() > 0) {
                            acctObj.addError('An Account cannot go from covered to uncovered if B2B entitlements exist for any contacts under the Account');
                        }
                    }
                }
            }
        }
    }
    
    // Dave 3/28/2017 US61359 - Prevent an account from being owned by an A&E User (but not A&E Super User)
    public static void preventAEUserAccountOwnership(List<Account> newList, Map<Id,Account> oldMap) {
        
        List<Account> accountsChangedOwnership = new List<Account>();
        Set<Id> accountOwnerIdsChangedOwnership = new Set<Id>();
        
        for (Account a : newList) {
            if (a.OwnerId != oldMap.get(a.Id).OwnerId) {
                accountsChangedOwnership.add(a);
                accountOwnerIdsChangedOwnership.add(a.OwnerId);
            }
        }
        
        Map<Id,User> aeUserOwnerMap = new Map<Id,User>([select Id from User where Id in :accountOwnerIdsChangedOwnership
                                                        and ProfileId = :Label.Core_A_E_User_Profile_ID]);
        Set<Id> aeUserIds = aeUserOwnerMap.keySet();
        
        List<PermissionSetAssignment> superUserAssignments = [select AssigneeId from PermissionSetAssignment
                                                              where PermissionSetId = :Label.Core_A_E_Super_User_Permission_Set_ID];
        Set<Id> superUserIds = new Set<Id>();
        for (PermissionSetAssignment psa : superUserAssignments)
            superUserIds.add(psa.AssigneeId);
        
        for (Account a : accountsChangedOwnership)  {
            if (aeUserIds.contains(a.OwnerId) && !superUserIds.contains(a.OwnerId))
                a.addError('An Account cannot be owned by an A&E User who is not an A&E Super User');
        }
    }
    
/*    
    public static void deleteSalesoutShairing(List<Account> accList,list<Account> triggerold ,map<Id,Account> newMap, map<Id, Account> oldmap,boolean Isdelete){
        try{
            String accountOwnerId ;
            Set<Id> inputIds;
            Set<Id> validatedIds;
            map<Id,List<Core_Training__Share>> trainingShareMap = new map<Id,List<Core_Training__Share>>();
            map<Id,List<Core_Liability_Points__Share>> lPointsShareMap = new map<Id,List<Core_Liability_Points__Share>>();
            map<Id,List<Core_Channel_Salesout__Share>> channelShareMap = new map<Id,List<Core_Channel_Salesout__Share>>();
            map<Id,List<Core_Channel_Membership__Share>> channelMShareMap = new map<Id,List<Core_Channel_Membership__Share>>();
            List<Core_Channel_Salesout__Share> channelShareList = new List<Core_Channel_Salesout__Share>();
            List<Core_Channel_Membership__Share> channelMemberList = new List<Core_Channel_Membership__Share>();
            List<Core_Training__Share> coreTrainingList = new List<Core_Training__Share>();
            List<Core_Liability_Points__Share> coreLPointsList = new List<Core_Liability_Points__Share>();
            map<Id,List<AccountTeamMember>> ownerAccTeamMap = new map<Id,List<AccountTeamMember>>();
            map<Id,Core_Channel_Salesout__c> channelSalesMap = new map<Id,Core_Channel_Salesout__c>();
            map<Id,Core_Channel_Membership__c> channelMemberMap = new map<Id,Core_Channel_Membership__c>();
            map<Id,Core_Training__c> coreTrainingMap = new map<Id,Core_Training__c>();
            map<Id,Core_Liability_Points__c> coreLPointsMap = new map<Id,Core_Liability_Points__c>();
            if(!IsDelete){
                for(Core_Channel_Salesout__c coreSales : [Select Id,Core_Account_Name__c from Core_Channel_Salesout__c where Core_Account_Name__c In : newMap.keySet()]){
                    channelSalesMap.put(coreSales.Id, coreSales);
             
                }
                for(Core_Channel_Salesout__Share channelShare : [Select Id, ParentId,Parent.Core_Account_Name__c,UserOrGroupId, RowCause from Core_Channel_Salesout__Share where ParentId In : channelSalesMap.keySet() and RowCause = 'Manual']){
                    // Map between UserOrGroupId and Share Record.
                    if(!channelShareMap.keySet().contains(channelShare.UserOrGroupId)){
                            channelShareMap.put(channelShare.UserOrGroupId,new List<Core_Channel_Salesout__Share>());
                    }
                        channelShareMap.get(channelShare.UserOrGroupId).add(channelShare); 
                }
                // code added for memberShip records. 
                for(Core_Channel_Membership__c coreMember : [Select Id,Core_Account_Name__c from Core_Channel_Membership__c where Core_Account_Name__c In : newMap.keySet()]){
                    channelMemberMap.put(coreMember.Id, coreMember);
             
                }
                for(Core_Channel_Membership__Share  channelShare : [Select Id, ParentId,Parent.Core_Account_Name__c,UserOrGroupId, RowCause from Core_Channel_Membership__Share  where ParentId In : channelSalesMap.keySet() and RowCause = 'Manual']){
                    // Map between UserOrGroupId and Share Record.
                    if(!channelMShareMap.keySet().contains(channelShare.UserOrGroupId)){
                            channelMShareMap.put(channelShare.UserOrGroupId,new List<Core_Channel_Membership__Share >());
                    }
                        channelMShareMap.get(channelShare.UserOrGroupId).add(channelShare); 
                }
                // Code Added for Training records
                for(Core_Training__c coreTraining : [Select Id,Core_Account__c from Core_Training__c where Core_Account__c In : newMap.keySet()]){
                    coreTrainingMap.put(coreTraining.Id, coreTraining);
             
                }
                for(Core_Training__Share channelShare : [Select Id, ParentId,Parent.Core_Account__c,UserOrGroupId, RowCause from Core_Training__Share where ParentId In : coreTrainingMap.keySet() and RowCause = 'Manual']){
                    // Map between UserOrGroupId and Share Record.
                    if(!trainingShareMap.keySet().contains(channelShare.UserOrGroupId)){
                            trainingShareMap.put(channelShare.UserOrGroupId,new List<Core_Training__Share>());
                    }
                        trainingShareMap.get(channelShare.UserOrGroupId).add(channelShare); 
                }
                // Code Added for Core_Liability_Points__c object
                for(Core_Liability_Points__c coreLPoints : [Select Id,Core_Account__c from Core_Liability_Points__c where Core_Account__c In : newMap.keySet()]){
                    coreLPointsMap.put(coreLPoints.Id, coreLPoints);
             
                }
                for(Core_Liability_Points__Share channelShare : [Select Id, ParentId,Parent.Core_Account__c,UserOrGroupId, RowCause from Core_Liability_Points__Share where ParentId In : coreLPointsMap.keySet() and RowCause = 'Manual']){
                    // Map between UserOrGroupId and Share Record.
                    if(!lPointsShareMap.keySet().contains(channelShare.UserOrGroupId)){
                            lPointsShareMap.put(channelShare.UserOrGroupId,new List<Core_Liability_Points__Share>());
                    }
                        lPointsShareMap.get(channelShare.UserOrGroupId).add(channelShare); 
                }
                for(AccountTeamMember accTeam : [select id,AccountId,UserId from AccountTeamMember where AccountId In : accList]){
                    if(!ownerAccTeamMap.keySet().contains(accTeam.AccountId)){
                        ownerAccTeamMap.put((accTeam.AccountId),new List<AccountTeamMember>());
                    }   
                        ownerAccTeamMap.get(accTeam.AccountId).add(accTeam);
                        
                }
                
                for(Account acc : accList){
                    If(newmap.get(acc.Id).ownerId != oldmap.get(acc.Id).ownerId){
                        if(ownerAccTeamMap.size()>0){
                            for(AccountTeamMember accTeam : ownerAccTeamMap.get(acc.Id)){
                                if(accTeam.UserId == oldmap.get(acc.Id).ownerId){
                                    accountOwnerId = 'TeamMember';
                                    break;
                                }
                                else{
                                    accountOwnerId = oldmap.get(acc.Id).ownerId;
                                    
                                }
                            }
                         }   
                        if(accountOwnerId != null && accountOwnerId != 'TeamMember'){
                            // Intilization of variables in Loop so that it contain current Account only.
                            inputIds = new Set<Id>();
                            validatedIds = new Set<Id>();
                            inputIds.add(acc.Id);
                            Core_Test_Utility.checkRecordEditAccess(accountOwnerId, inputIds, validatedIds) ;
                            system.debug('***validatedIds' + validatedIds);
                            if(validatedIds.size() == 0){
                                for(Core_Channel_Salesout__Share coreSales : channelShareMap.get(accountOwnerId)){
                                    if(coreSales.Parent.Core_Account_Name__c == acc.Id)
                                        channelShareList.add(coreSales) ;    
                                }
                                for(Core_Channel_Membership__Share coremember : channelMShareMap.get(accountOwnerId)){
                                    if(coremember.Parent.Core_Account_Name__c == acc.Id)
                                        channelMemberList.add(coremember) ;    
                                }
                                for(Core_Training__Share coreTraining : trainingShareMap.get(accountOwnerId)){
                                    if(coreTraining.Parent.Core_Account__c == acc.Id)
                                        coreTrainingList.add(coreTraining) ;    
                                }
                                for(Core_Liability_Points__Share coreLPoints : lPointsShareMap.get(accountOwnerId)){
                                    if(coreLPoints.Parent.Core_Account__c == acc.Id)
                                        coreLpointsList.add(coreLPoints) ;    
                                }
                            }
                        } else if(accountOwnerId != 'TeamMember'){
                            inputIds = new Set<Id>();
                            validatedIds = new Set<Id>();
                            inputIds.add(acc.Id);
                            Core_Test_Utility.checkRecordEditAccess(oldmap.get(acc.Id).ownerId, inputIds, validatedIds) ;
                            system.debug('***validatedIds' + validatedIds);
                            if(validatedIds.size() == 0){
                                if(channelShareMap.size() >0){
                                    system.debug('***' + channelShareMap + '34' + oldmap.get(acc.Id).ownerId);
                                    for(Core_Channel_Salesout__Share coreSales : channelShareMap.get(oldmap.get(acc.Id).ownerId)){
                                        system.debug('***account' +coreSales);
                                        if(coreSales.Parent.Core_Account_Name__c == acc.Id)
                                            channelShareList.add(coreSales) ;    
                                    }
                                    for(Core_Channel_Membership__Share coremember : channelMShareMap.get(oldmap.get(acc.Id).ownerId)){
                                        if(coremember.Parent.Core_Account_Name__c == acc.Id)
                                            channelMemberList.add(coremember) ;    
                                    }
                                    for(Core_Training__Share coreTraining : trainingShareMap.get(oldmap.get(acc.Id).ownerId)){
                                        if(coreTraining.Parent.Core_Account__c == acc.Id)
                                        coreTrainingList.add(coreTraining) ;    
                                    }
                                    for(Core_Liability_Points__Share coreLPoints : lPointsShareMap.get(oldmap.get(acc.Id).ownerId)){
                                        if(coreLPoints.Parent.Core_Account__c == acc.Id)
                                        coreLpointsList.add(coreLPoints) ;    
                                    }
                                }
                            }
                        }
                    }
                }
            }   
            //When account is deleted
            if(IsDelete){
                for(Core_Channel_Salesout__c coreSales : [Select Id,Core_Account_Name__c from Core_Channel_Salesout__c where Core_Account_Name__c In : triggerOld]){
                    channelSalesMap.put(coreSales.Id, coreSales);
                }
            for(Core_Channel_Salesout__Share channelShare : [Select Id, ParentId,Parent.Core_Account_Name__c,UserOrGroupId, RowCause from Core_Channel_Salesout__Share where ParentId In : channelSalesMap.keySet() and RowCause = 'Manual']){
                // Map between UserOrGroupId and Share Record.
                if(!channelShareMap.keySet().contains(channelShare.UserOrGroupId)){
                        channelShareMap.put(channelShare.UserOrGroupId,new List<Core_Channel_Salesout__Share>());
                }
                    channelShareMap.get(channelShare.UserOrGroupId).add(channelShare); 
            }
            // code added for memberShip records.
            for(Core_Channel_Membership__c coreMember : [Select Id,Core_Account_Name__c from Core_Channel_Membership__c where Core_Account_Name__c In : newMap.keySet()]){
                    channelMemberMap.put(coreMember.Id, coreMember);
             
                }
            for(Core_Channel_Membership__Share  channelShare : [Select Id, ParentId,Parent.Core_Account_Name__c,UserOrGroupId, RowCause from Core_Channel_Membership__Share  where ParentId In : channelSalesMap.keySet() and RowCause = 'Manual']){
                // Map between UserOrGroupId and Share Record.
                if(!channelMShareMap.keySet().contains(channelShare.UserOrGroupId)){
                        channelMShareMap.put(channelShare.UserOrGroupId,new List<Core_Channel_Membership__Share >());
                }
                    channelMShareMap.get(channelShare.UserOrGroupId).add(channelShare); 
            }
            // Code Added for Training records
                for(Core_Training__c coreTraining : [Select Id,Core_Account__c from Core_Training__c where Core_Account__c In : triggerOld]){
                    coreTrainingMap.put(coreTraining.Id, coreTraining);
             
                }
                for(Core_Training__Share channelShare : [Select Id, ParentId,Parent.Core_Account__c,UserOrGroupId, RowCause from Core_Training__Share where ParentId In : coreTrainingMap.keySet() and RowCause = 'Manual']){
                    // Map between UserOrGroupId and Share Record.
                    if(!trainingShareMap.keySet().contains(channelShare.UserOrGroupId)){
                            trainingShareMap.put(channelShare.UserOrGroupId,new List<Core_Training__Share>());
                    }
                        trainingShareMap.get(channelShare.UserOrGroupId).add(channelShare); 
                }
                 // Code Added for Core_Liability_Points__c object
                for(Core_Liability_Points__c coreLPoints : [Select Id,Core_Account__c from Core_Liability_Points__c where Core_Account__c In : triggerOld]){
                    coreLPointsMap.put(coreLPoints.Id, coreLPoints);
             
                }
                for(Core_Liability_Points__Share channelShare : [Select Id, ParentId,Parent.Core_Account__c,UserOrGroupId, RowCause from Core_Liability_Points__Share where ParentId In : coreLPointsMap.keySet() and RowCause = 'Manual']){
                    // Map between UserOrGroupId and Share Record.
                    if(!lPointsShareMap.keySet().contains(channelShare.UserOrGroupId)){
                            lPointsShareMap.put(channelShare.UserOrGroupId,new List<Core_Liability_Points__Share>());
                    }
                        lPointsShareMap.get(channelShare.UserOrGroupId).add(channelShare); 
                }
                for(Account acc : triggerold){
                    if(channelShareMap.size() >0){
                        for(Core_Channel_Salesout__Share coreSales : channelShareMap.get(acc.OwnerId)){
                            if(coreSales.Parent.Core_Account_Name__c == acc.Id)
                                channelShareList.add(coreSales) ;    
                        }
                        for(Core_Channel_Membership__Share coremember : channelMShareMap.get(oldmap.get(acc.Id).ownerId)){
                            if(coremember.Parent.Core_Account_Name__c == acc.Id)
                                channelMemberList.add(coremember) ;    
                                    }
                        for(Core_Training__Share coreTraining : trainingShareMap.get(acc.OwnerId)){
                            if(coreTraining.Parent.Core_Account__c == acc.Id)
                                coreTrainingList.add(coreTraining) ;    
                        }
                        for(Core_Liability_Points__Share coreLPoints : lPointsShareMap.get(acc.OwnerId)){
                            if(coreLPoints.Parent.Core_Account__c == acc.Id)
                                coreLpointsList.add(coreLPoints) ;    
                        }
                    }   
                }
            }
            system.debug('***channelShareList' + channelShareList);
            if(channelShareList.size() >0)
                delete channelShareList;
            if(channelMemberList.size() >0)
                delete channelMemberList;
            if(coreTrainingList.size()>0)
                delete coreTrainingList;
            if(coreLpointsList.size()>0)
                delete coreLpointsList;
        }catch(Exception ex){
            system.debug('Error in Deleting Share records' + ex.getMessage());
        }
    }
*/
    
}