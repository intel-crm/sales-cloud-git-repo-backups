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
* Accenture-VD              23/7/2018               US99134 - Stop Outbound messages to CIM and EPRM for Virtual Accounts
                                                    Updated Below Methods to stop creating OutBound message for Co-Marketing Record Type of Account 
                                                    -accountObjectBeforeHandler
                                                    -loadCPMID255
                                                    -preventAEUserAccountOwnership
                                                    -preventUncoveredAccountChange
                                                    -accountObjectAfterDelete
                                                    -accountTeamAuditCompletion
* Amal Thomas               25/08/2020              Added code to onboard IPA accounts and Create group for Co-marketing Accounts
*************************************************************************************/
public class Core_AccountHandler{

    public static final String CPMID_DELIMITER       = ', ';  
    public static final String CPMID_DELIMITER_REGEX = '(,[\\s]*|\\s)';  // Delimiters: comma, or a blank, or any combination
    public static Id coMarketingRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Core_MDF_Co_Marketing_Record_Type_Name).getRecordTypeId(); //Added by Accenture - VD -> Check if the record type is not Co-Marketing
    public static Map<Id,set<Id>> accIdToExtGrpIdMap = new Map<Id,set<Id>>();
    public static Id masterRecrodtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    //Map of channel program Id to channel program record
    public static Map<Id,ChannelProgram> cpMap = new Map<Id,ChannelProgram>();
    public static Id channelProgramIdForIPA;
    //private static Id intelAccountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    
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
         //Added by Accenture - VD -> Check if the record type is not Co-Marketing **************Start***********
        List<Account> newAccountListToBeInserted = new List<Account>();
        Map<Id,Account> oldAccountMapToBeInserted = new Map<Id,Account>();

        for(Account acc : listNewAccount){
            if(acc.RecordTypeId != coMarketingRecordTypeId){
                newAccountListToBeInserted.add(acc);
                if(mapOldsObject != NULL && mapOldsObject.size() > 0){
                    oldAccountMapToBeInserted.put(acc.Id,mapOldsObject.get(acc.Id));
                }
            }
        }
        
        //Added by Accenture - VD -> Check if the record type is not Co-Marketing **************End*************
        if(newAccountListToBeInserted.size() > 0)
            Core_Utility.sObjectGeoMappingField(newAccountListToBeInserted, oldAccountMapToBeInserted, new list<String>{'BillingCountry', 'BillingCountryCode'}, 
                                                new list<String>{'BillingState', 'BillingStateCode'}, 'Core_Geo__c','Core_Sub_Geo__c');
    }
    
     /***************************************************************************************************** 
    Method Name:                                             loadCPMID255
    @return  :                                               Void
    Modified By:                         Date:               Changes: 
    Accenture – VD                      07/23/2018           US99134 - Updated Method to stop creating OutBound message for Co-Marketing Record Type of Account 
    ******************************************************************************************************/

    private static void loadCPMID255(List<Account> accounts, Map<Id, Account> mapOldsObject)
    {
        final integer MAX_FIELD_LENGTH     = 255;

        String newStr;
        String cpmIdStr;
        List<String> cpmIdList = new List<String>();
        for (Account acct : accounts)
        {
            if(acct.RecordTypeId != coMarketingRecordTypeId) //Added by Accenture - VD -> Check if the record type is not Co-Marketing
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
    }
    
     /***************************************************************************************************** 
    Method Name:                                             accountTeamAuditCompletion
    @return  :                                               Void
    Modified By:                            Date:            Changes: 
    Accenture – VD                          07/23/2018       US99134 - Updated Method to stop creating OutBound message for Co-Marketing Record Type of Account 
    ******************************************************************************************************/

    public static void accountTeamAuditCompletion(List<Account> newList, Map<Id,Account> oldMap) {
        List<Id> auditCompletedAccounts = new List<Id>();

        //Get a list of all accounts whose audit was just marked complete, 
        //and the due date is not being changed to null at the same time.
        //The audit initialization process (Core_AccountTeamAuditInitialize) marks 
        //all audits as complete and clears due dates to prepare for the next round             
        //of audit.  We don't want to log the audit as complete in that case.
        
        for(Account newAcc:newList) 
        {  
            if(newAcc.RecordTypeId != coMarketingRecordTypeId) //Added by Accenture - VD -> Check if the record type is not Co-Marketing
            {
                if ((newAcc.Core_Account_Team_Audit_Complete__c == true && oldMap.get(newAcc.Id).Core_Account_Team_Audit_Complete__c == false)
                    && (newAcc.Core_Account_Team_Audit_Due_Date__c != null)) {
                        auditCompletedAccounts.add(newAcc.Id);
                    }
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
    /***************************************************************************************************** 
    Method Name:                                             accountObjectAfterDelete
    @return  :                                               Void
    Modified By:                            Date:            Changes: 
    Accenture – VD                          07/23/2018       US99134 - Updated Method to stop creating OutBound message for Co-Marketing Record Type of Account 
    ******************************************************************************************************/
   
    public static void accountObjectAfterDelete(List<Account> newList, Map<Id,Account> newMap, List<Account> oldList, Map<Id,Account> oldMap)
    { 
        System.debug('accountObjectAfterDelete : START');
        try {                    
            List<Core_Integration_Outbound_Message__c> msgList;        
            Set<Id> dupeCheck = new Set<Id>();
            for (Account account: oldList) 
            {
                if(coMarketingRecordTypeId != account.RecordTypeId) //Added by Accenture - VD -> Check if the record type is not Co-Marketing
                {                        
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
    /***************************************************************************************************** 
    Method Name:                                             preventUncoveredAccountChange
    @return  :                                               Void
    Modified By:                            Date:            Changes: 
    Accenture – VD                          07/23/2018       US99134 - Updated Method to stop creating OutBound message for Co-Marketing Record Type of Account 
    ******************************************************************************************************/

    public static void preventUncoveredAccountChange(List<Account> newList, Map<Id, Account> oldMap) {
        List<Account> accountsChangedToUncovered = new List<Account>();
        for(Account acctObj : newList) 
        {
            if(acctObj.RecordTypeId != coMarketingRecordTypeId) //Added by Accenture - VD -> Check if the record type is not Co-Marketing
            {
                if(acctObj.OwnerId == Label.Core_Uncovered_Account_ID && oldMap.get(acctObj.Id).OwnerId != Label.Core_Uncovered_Account_ID) {
                    accountsChangedToUncovered.add(acctObj);
                }
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
    /***************************************************************************************************** 
    Method Name:                                             preventAEUserAccountOwnership
    @return  :                                               Void
    Modified By:                            Date:            Changes: 
    Accenture – VD                          07/23/2018       US99134 - Updated Method to stop creating OutBound message for Co-Marketing Record Type of Account 
    ******************************************************************************************************/

    public static void preventAEUserAccountOwnership(List<Account> newList, Map<Id,Account> oldMap) {
        
        List<Account> accountsChangedOwnership = new List<Account>();
        Set<Id> accountOwnerIdsChangedOwnership = new Set<Id>();
        
        for (Account a : newList) 
        {
            if(a.RecordTypeId != coMarketingRecordTypeId) //Added by Accenture - VD -> Check if the record type is not Co-Marketing
            {
                if (a.OwnerId != oldMap.get(a.Id).OwnerId) {
                    accountsChangedOwnership.add(a);
                    accountOwnerIdsChangedOwnership.add(a.OwnerId);
                }
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
    /***************************************************************************************************** 
    Method Name:                                             validateAccountForMDF
    @return  :                                               Void
    Modified By:                            Date:            Changes: 
    Accenture – AD                          07/24/2020       This method is used to check whether an IPA account is eligiable for MDF benefit or not
    ******************************************************************************************************/
    
    /*public static void validateAccountForMDF(List<Account> newAccountList,Map<Id,Account> oldAccountMap){
        //To store accounts that are IPA and are being made as Co-Marketing Active
        List<Account> accountToBeProcessed = new List<Account>();
        for(Account newAcc : newAccountList){
            if(oldAccountMap!=null && newAcc.Core_MDF_CoMarketingActive__c != oldAccountMap.get(newAcc.Id).Core_MDF_CoMarketingActive__c &&    
               (!(oldAccountMap.get(newAcc.Id).Core_MDF_CoMarketingActive__c)) && newAcc.Core_MDF_CoMarketingActive__c && newAcc.Core_Intel_Partner_Alliance_PartnerGroup__c){
                   accountToBeProcessed.add(newAcc);
               }
        }
        if(accountToBeProcessed!=null && accountToBeProcessed.size()>0){
            //Method to validate and onBoard an IPA Account into MDF
          System.debug('accountToBeProcessed' + accountToBeProcessed);
          Core_MDF_CCPAccount_Onboard.isAccountEligibleForMDF(accountToBeProcessed);
        }
    }*/
    /*************************************************************************************************************
   * Method Name:                                            createGroupForComarketingAccount
    @return  :                                               Void
    Modified By:                            Date:            Changes: 
    Accenture – AS                          19/08/2020       This method is used Create Group on Co-Marketing Account
************************************************************************************************************/
    public static List<Account> createGroupForComarketingAccount(List<Account> accountList){
        //To Store Co-Marketing Accounts
        List<Account> coMarkAccountToBeProcessed= new List<Account>();
        //To Store Intel Accounts
        List<Account> intelAccountToBeProcessed= new List<Account>();
        
        for(Account acc : accountList){
            if(acc.RecordTypeId == coMarketingRecordTypeId){
                coMarkAccountToBeProcessed.add(acc);
            }
            if(acc.RecordTypeId == masterRecrodtypeId  && !acc.Core_MDF_CoMarketingActive__c && acc.Core_Intel_Partner_Alliance_PartnerGroup__c && String.isNotBlank(acc.Core_Prime_Id__c)){
                intelAccountToBeProcessed.add(acc);
            }
        }        
        if(coMarkAccountToBeProcessed!=null && coMarkAccountToBeProcessed.size()>0){
            //Method to Create Groups for Co-Marketing Accounts
            Core_MDF_Account_Utility.createGroupForAccountNode(coMarkAccountToBeProcessed);
        }
        if(intelAccountToBeProcessed!=null && intelAccountToBeProcessed.size()>0){
            //Method to Create PGM's for Intel Accounts when Prime Id is present
            isPrimeIdChanged(intelAccountToBeProcessed,NULL);
        }
        return coMarkAccountToBeProcessed;
    }
    
    /*************************************************************************************************************
   * Method Name:                                            sharingWithNewAcctGrps
    @return  :                                               Void
    Modified By:                            Date:            Changes: 
    Accenture – AS                          19/08/2020       This method is used Call Batch Class for Node Sharing
************************************************************************************************************/
    public static void sharingWithNewAcctGrps(List<Account> accountList){        
       
        if(accountList!=null && accountList.size()>0){
           Id batchInstanceId = Database.executeBatch(new Core_MDF_Batch_SharingWithNewAcctGrp(accountList)); 
        }
    }
  /*************************************************************************************************************
   * Method Name:                                            createNodeSharingGroup
    @return  :                                               Void
    Modified By:                            Date:            Changes: 
    Accenture – NK                          22/02/2022       This method is used Create PNUM based External sharing group and
                                                             Share account to  that group.
************************************************************************************************************/
    Public static void createNodeSharingGroup(Map<Id,Account> newMap){
        try{
        Id coMarketingRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Core_MDF_Co_Marketing_Record_Type_Name).getRecordTypeId();
        Map<Id,Group> accIdGrpNameMap = new Map<Id,Group>();
        for(Account acc : newMap.values()){
            if(acc.RecordTypeId == coMarketingRecordtypeId){
                Group newNodeGroup = new Group();
                newNodeGroup.name = 'CCP_'+acc.Id+'_EXT_GRP';
                newNodeGroup.DeveloperName = 'Core_MDF_CCP_'+acc.Id+'_EXT_GRP'; 
                newNodeGroup.DoesIncludeBosses = false;
                accIdGrpNameMap.put(acc.Id,newNodeGroup);
           }
        }
        if(!accIdGrpNameMap.isEmpty()){
            Database.insert(accIdGrpNameMap.values());
        }

        Map<Id, List<Id>> accIdGrpIdListMap = new Map<Id, List<Id>>();
        for(Id accId : accIdGrpNameMap.keyset()){
            accIdGrpIdListMap.put(accId,new List<Id>{accIdGrpNameMap.get(accId).Id});
        }
        Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Account',accIdGrpIdListMap, 'Edit');
        List<AccountShare> accountShareList = Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst); 
        List<Account> accToUpdate = new List<Account>();
        for(account acc : [select id,Core_MDF_External_Group_Id__c from Account where Id in:accIdGrpNameMap.keyset()]){
            acc.Core_MDF_External_Group_Id__c = accIdGrpNameMap.get(acc.Id).Id;
                accToUpdate.add(acc);
        }
            
        Database.update(accToUpdate); 
        }catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
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
  
    /***************************************************************************************************** 
    Method Name: validateMDFParentFundAccChanges
    @return  :  Void
    Created By: SH                  
    Date: 09 MAR, 2022     
    ******************************************************************************************************/
    public static void validateMDFParentFundAccChanges(List<Account> newList, Map<Id,Account> oldMap){
        //To By-pass the method execution
        if(Core_MDF_Utility.byPassFeature('byPassMDFPFAChangesMethod')){
            return;
        }
        //List to store Parent Fund Accounts Ids
        List <Id> accountIds = new List<Id>();
        if(newList.size()>0 && UserInfo.getUserType() != System.Label.Core_MDF_Partner_User_Type){
            for(Account acc : newList) {
                //Check if Parent fund Account value get change
                if(oldMap != null && oldMap.size() > 0  && acc.RecordTypeId == coMarketingRecordtypeId && oldMap.get(acc.Id).Core_MDF_Parent_Fund_Account__c != acc.Core_MDF_Parent_Fund_Account__c){
                    accountIds.add(acc.Id);
                }
            }
        }
        
        if(accountIds != NULL && accountIds.size()>0){
            //List to store all child accounts
            List <Account> hierarchyList = [SELECT Id,RecordType.DeveloperName,Name,Core_MDF_Enabled_Auto_Transfer__c, Core_MDF_Auto_Transfer_Account__c,Core_MDF_Parent_Fund_Account__c , Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c,Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c,Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c,
                                        Core_MDF_External_Group_Id__c,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c ,Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c,
                                        Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c
                                        FROM Account WHERE RecordTypeId =: coMarketingRecordtypeId  AND (Id IN : accountIds 
                                                                                                                 OR Core_MDF_Parent_Fund_Account__c IN : accountIds 
                                                                                                                 OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN : accountIds  
                                                                                                                 OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN : accountIds 
                                                                                                                 OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN : accountIds)];
            
            //Check if child node list is not empty
            if(hierarchyList != NULL && hierarchyList.size()>0){
                for(Account acctObj : newList){
                    //List to store Auto Transfer Enable Nodes
                    List<String> errorNode = new List<String>();  
                    for(Account acc : hierarchyList){
                        //Retail sharing
                        if(!Core_MDF_Utility.byPassFeature('byPassRetailCampSharingOnPFAChange')){
                            if(acc.Id == acctObj.Id && acc.Core_MDF_External_Group_Id__c != NULL && acc.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c == 'Retail Marketing Funds'){
                                accIdToExtGrpIdMap.put(acc.Id, new set<Id>{acc.Core_MDF_External_Group_Id__c});
                                if(acc.Core_MDF_Parent_Fund_Account__c != null && acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c != null){
                                    if(accIdToExtGrpIdMap.containsKey(acc.id)){
                                        accIdToExtGrpIdMap.get(acc.id).add(acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c);
                                    }else{
                                        accIdToExtGrpIdMap.put(acc.id, new set<Id>{acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c});
                                    }
                                }
                                if(acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c != null 
                                && acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c != null)
                                {
                                    if(accIdToExtGrpIdMap.containsKey(acc.id)){
                                        accIdToExtGrpIdMap.get(acc.id).add(acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c);
                                    }else{
                                        accIdToExtGrpIdMap.put(acc.id, new set<Id>{acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c});
                                    }
                                }
                                system.debug('addingtomap::'+accIdToExtGrpIdMap);
                            }
                        }
                        //check if child nodes parent match with editing node  
                        if(acc.Core_MDF_Parent_Fund_Account__c == acctObj.Id || acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c == acctObj.Id 
                           || acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c == acctObj.Id 
                           || acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c == acctObj.Id
                          )
                        {
                            //check if Enable Auto Transfer is true and Auto Trandfer Account is not empty 
                            if(acc.Core_MDF_Enabled_Auto_Transfer__c == True && acc.Core_MDF_Auto_Transfer_Account__c != NULL){
                                
                                if(acc.Core_MDF_Auto_Transfer_Account__c == acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c && acctObj.id == acc.Core_MDF_Parent_Fund_Account__c){           
                                    //acctObj.Core_MDF_Parent_Fund_Account__c.addError('Parent Fund Account cannot be changed if Enable Auto Transfer/ Auto-Transfer Account is populated.1');
                                    errorNode.add(acc.Name);
                                }
                                else if(acc.Core_MDF_Auto_Transfer_Account__c == acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c && 
                                        (acctObj.id == acc.Core_MDF_Parent_Fund_Account__c || acctObj.id == acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c)){
                                            //acctObj.addError('Parent Fund Account cannot be changed if Enable Auto Transfer/ Auto-Transfer Account is populated.2'+acc.Name);
                                            errorNode.add(acc.Name);
                                        }
                                else if(acc.Core_MDF_Auto_Transfer_Account__c == acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c 
                                        && (acctObj.id == acc.Core_MDF_Parent_Fund_Account__c || acctObj.id == acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c || acctObj.id == acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c)){  
                                            //acctObj.Core_MDF_Parent_Fund_Account__c.addError('Parent Fund Account cannot be changed if Enable Auto Transfer/ Auto-Transfer Account is populated.3');
                                            errorNode.add(acc.Name);
                                        }
                            }
                            // check if Parent Fund Account is child account
                            if(acctObj.Core_MDF_Parent_Fund_Account__c == acc.id){
                                acctObj.Core_MDF_Parent_Fund_Account__c.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Child_ParenFundAccount'));
                            }
                            
                        }
                    }
                    //check if atleast one Auto Transfer Enable node available
                    if(errorNode != NULL && errorNode.size()>0){ 
                        String errorString = String.join(errorNode, ', ');
                        acctObj.Core_MDF_Parent_Fund_Account__c.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EnableAutoTransfer_error')+' '+errorString);
                    }
                }
            }
        }
    }      
    
  /***************************************************************************************************** 
    Method Name: validateAccountHierarchy
    @return  :  Void
    Created By: SH                  
    Date: 09 MAR, 2022     
    ******************************************************************************************************/
    public static void validateAccountHierarchy(List<Account> newList,Map<Id,Account> oldMap){ 
        //To By-pass the method execution
        if(Core_MDF_Utility.byPassFeature('byPassValidateAccountHierarchy')){
            return;
        }
        //List to store Parent Fund Account
        List<Account> accList = new List<Account>();
        if(newList.size()>0 && UserInfo.getUserType() != System.Label.Core_MDF_Partner_User_Type){
            for(Account acc : newList){
                //Check if Parent fund Account value get change
                if(oldMap != null && oldMap.size() > 0 && acc.RecordTypeId == coMarketingRecordtypeId && oldMap.get(acc.Id).Core_MDF_Parent_Fund_Account__c != acc.Core_MDF_Parent_Fund_Account__c){
                    accList.add(acc);
                }
            }
        }
        
        if(accList != NULL && accList.size() > 0){
            if(!Core_MDF_Utility.byPassFeature('byPassRetailCampSharingOnPFAChange')){
                checkRetailCampaignShare(accList);
            }
            
            List <Account> hierarchyList = [Select id,RecordType.DeveloperName,Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Parent_Fund_Account__c, 
                                    Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c, 
                                    Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c,
                                    Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c,
                                    Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c,
                                    Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c                           
                                    from Account 
                                    where  RecordTypeId =: coMarketingRecordtypeId  AND (Core_MDF_Parent_Fund_Account__c IN: accList 
                                                                                         OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN: accList 
                                                                                         OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN: accList 
                                                                                         OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN: accList 
                                                                                         OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN: accList 
                                                                                         OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN: accList)];
            
            if(hierarchyList != NULL && hierarchyList.size()>0){
                for(Account accInst : accList){
                    for(Account childAcc : hierarchyList){
                        if(childAcc.Core_MDF_Parent_Fund_Account__c == accInst.Id || childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c == accInst.Id ||
                           childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c ==  accInst.Id || childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c == accInst.Id ||
                           childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c == accInst.Id ||
                           childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c == accInst.Id)
                        {
                            //Check if account is not retail and Hierarchy level exceeds five
                            if(childAcc.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c != 'Retail Marketing Funds' && 
                               childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c == accInst.Core_MDF_CoMarketing_Ultimate_Account__c)
                            {
                                accInst.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Five_levels_hierarchy'));
                                break;
                                
                                //Check if account is retail and Hierarchy level exceeds three
                            }else if(childAcc.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c == 'Retail Marketing Funds' && 
                                     childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c == accInst.Core_MDF_CoMarketing_Ultimate_Account__c)
                            {
                                accInst.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Three_level_hierarchy'));
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    
  /***************************************************************************************************** 
    Method Name: checkRetailCampaignShare
    @return  :  Void
    Created By: SH                  
    Date: 09 MAR, 2022     
    ******************************************************************************************************/
    public static void checkRetailCampaignShare(List<Account> accList){
        Map<Id, Campaign> campMap = new Map<Id, Campaign>();
        Map<Id,Set<Id>> cmpIdToGrpdsIdSetToBeDltd = new Map<Id,Set<Id>>();
        for(Campaign cmp : [SELECT Id,Core_MDF_Program__c,Core_MDF_Account__c from Campaign where Core_MDF_Program__c =: 'Retail Marketing Funds' AND Core_MDF_Account__c IN: accList]){
            campMap.put(cmp.Id,cmp);
            if(accIdToExtGrpIdMap != NULL && accIdToExtGrpIdMap.containsKey(cmp.Core_MDF_Account__c) && accIdToExtGrpIdMap.get(cmp.Core_MDF_Account__c) != NULL){
               cmpIdToGrpdsIdSetToBeDltd.put(cmp.Id, accIdToExtGrpIdMap.get(cmp.Core_MDF_Account__c)); 
            }            
        }
        if(campMap != NULL && cmpIdToGrpdsIdSetToBeDltd != NULL && campMap.size()>0 && cmpIdToGrpdsIdSetToBeDltd.size() > 0){
            Core_MDF_ProcessCCP_Campaign.shareUnshareCampaignGenericMethod(campMap,cmpIdToGrpdsIdSetToBeDltd);
        }
    }

/***************************************************************************************************** 
    Method Name: preventMultipleVCForSameProg
    @return  :  Void
    Created By: SH                  
    Date: 30 MAR, 2022     
    ******************************************************************************************************/
   
    public static void preventMultipleVCForSameProg (List<Account> newList){
        //sets to store Channel Program Ids and Parent Fund Account Ids
        Set<Id> programIds  = new Set<Id>();
        Set<Id> parentFundAcctIds  = new Set<Id>();
        //List store UniqueKey
        List<String> uniqueKeyList = New List<String>();
        //List to store Account
        List<Account> accList = New List<Account>();
        //Map to store UniqueKey and Account Name
        Map<String,String> uniqueKeyToAccName = new Map<String,String>();
        Set<Id> parentAccIds = new Set<Id>();
        Map<Id,Account> parentToRecordType = new Map<Id,Account>();
        //Boolean isCoMarketingAccountCreatedManually;
        
        try{
            if(newList != NULL && newList.size()>0){
                for(Account acc : newList){
                    //Checking the source of Virtual Corp Account creation(auto/manual)
                    System.debug('Source val: '+acc.Core_MDF_Source_nm__c);
                    System.debug('acc rec type:'+acc.RecordTypeId);
                    System.debug('Parent Developer Name: '+acc.Core_MDF_Parent_Fund_Account__r.RecordType.DeveloperName);
        
                   
                    //Checking if Record type is co-marketing
                    if(acc.RecordTypeId == coMarketingRecordTypeId){
                        //storing Channel Program Id and Parent Fund Account Id in set
                        programIds.add(acc.Core_MDF_Channel_Program__c);
                        parentFundAcctIds.add(acc.Core_MDF_Parent_Fund_Account__c);
                        accList.add(acc);
                    }
                } 
                if(!parentFundAcctIds.isEmpty()) {
                    parentToRecordType = new Map<Id, Account>([Select id,RecordTypeId,RecordType.DeveloperName from Account where Id IN : parentFundAcctIds and RecordTypeId =: masterRecrodtypeId]);
                }
                
                /*if(!parentToRecordType.isEmpty()) {
                    for(Account acc: accList) {
                        if((acc.AccountSource!='CCP Onboarding' && parentToRecordType.get(acc.Core_MDF_Parent_Fund_Account__c).RecordType.DeveloperName == 'Mastered_Account'))
                        {
                            acc.addError('Please reach out to Support Team for Virtual Corp Account creation');
                        }
                    }   
                }*/
                
                
                //check if sets are not null
                if(programIds != NULL && parentFundAcctIds != NULL && programIds.size() > 0 && parentFundAcctIds.size() > 0){
                    //Querying existing Virtual Corp Accounts
                    for(Account existAcc : [SELECT Id,Name,RecordTypeId,Core_MDF_Channel_Program__c,Core_MDF_Parent_Fund_Account__c,Core_MDF_Parent_Fund_Account__r.RecordType.DeveloperName FROM Account WHERE RecordTypeId =:coMarketingRecordtypeId AND Core_MDF_Channel_Program__c IN: programIds AND Core_MDF_Parent_Fund_Account__c IN: parentFundAcctIds AND Core_MDF_Parent_Fund_Account__r.RecordType.DeveloperName =: 'Mastered_Account']){                    
                        //Unique key generating using channel Program Id and Parent fund Account Id
                        String uniqueKey = (String.valueOf(existAcc.Core_MDF_Channel_Program__c) + String.valueOf(existAcc.Core_MDF_Parent_Fund_Account__c));
                        //Storing uniqueKey to List
                        uniqueKeyList.add(uniqueKey);
                        //Storing uniqueKey and Account name to Map
                        uniqueKeyToAccName.put(uniqueKey,existAcc.Name);
                    }
                }
                //checking if both the Map are not null
                if(uniqueKeyList != NULL && uniqueKeyToAccName != NULL && uniqueKeyList.size()>0 && uniqueKeyToAccName.size()>0){
                    for(Account acc : accList){
                        //checking unique key exist in List
                        if(uniqueKeyList.contains(String.valueOf(acc.Core_MDF_Channel_Program__c) + String.valueOf(acc.Core_MDF_Parent_Fund_Account__c))){
                            acc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MultipleVCForSameProgram1')+' '+uniqueKeyToAccName.get(String.valueOf(acc.Core_MDF_Channel_Program__c) + String.valueOf(acc.Core_MDF_Parent_Fund_Account__c))+' '+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MultipleVCForSameProgram2'));
                        }
                        
                    }
                }
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    /***************************************************************************************************** 
    Method name  : updateHostRegionOnNodeAccounts
    Description  : To stamp the host region on Node/Sub node accounts from their parent fund account(before insert)
    Return Type  : VOID
    Parameter    : List Trigger.new    
    Created By   : VB                 
    Date         : 29 Nov, 2022     
    ******************************************************************************************************/
    public static void updateHostRegionOnNodeAccounts(List<Account> listNewAccount) {
        //Set to Store the parent fund account Id's of a coMarketing Account
        Set<Id> parentFundAccountIdsSet = new Set<Id>();
        List<Account> accountsWithoutSubGeo = new List<Account>();
        //Map to Store the parent fund account Id as key as Parent fund account record as value of any node account
        Map<Id,Account> coMarkAccIdToCoMarkAccMap = new Map<Id,Account>();
        try {
            //Get the channel Program id of IPA program
            Core_MDF_ChannelProgram__mdt channelProgramDetailsOfIPA = Core_MDF_ChannelProgram__mdt.getInstance('Intel_Partner_Alliance');
            // Get the parent fund account Id of node accounts
                for(Account acc : listNewAccount){
                    if (acc.RecordTypeId == coMarketingRecordTypeId && acc.Core_MDF_Channel_Program__c == channelProgramDetailsOfIPA.Core_MDF_Program_ID__c && !acc.Core_MDF_CoMarketingActive__c && !acc.Core_MDF_CoMarketingAgency__c) {
                        if(acc.Core_Sub_Geo__c != null) {
                            acc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SubRegion_Inapplicable_Message'));
                        } else {
                            accountsWithoutSubGeo.add(acc);
                            parentFundAccountIdsSet.add(acc.Core_MDF_Parent_Fund_Account__c);
                        }
                    }
                }
            //query the parent fund account details, coMarkAccIdToCoMarkAccMap - Map of key as parent fund account Id and value as parent fund account record
            if(!parentFundAccountIdsSet.isEmpty()) {
                coMarkAccIdToCoMarkAccMap = new Map<Id, Account>([select Id, Name, Core_Geo__c, RecordTypeId from Account where Id IN: parentFundAccountIdsSet and RecordTypeId =: coMarketingRecordTypeId]);
            }
            
            //stamp the host region from its parent account for the parent fund account matching records
            if(!coMarkAccIdToCoMarkAccMap.isEmpty()) {
                for(Account acc: accountsWithoutSubGeo) {
                    if(coMarkAccIdToCoMarkAccMap.containsKey(acc.Core_MDF_Parent_Fund_Account__c) && coMarkAccIdToCoMarkAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Id == acc.Core_MDF_Parent_Fund_Account__c) {
                        if(acc.Core_Geo__c != null) {
                            if(coMarkAccIdToCoMarkAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_Geo__c != acc.Core_Geo__c) {
                                acc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RegionMismatch_Error'));
                            } else {
                                acc.Core_Geo__c = coMarkAccIdToCoMarkAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_Geo__c;
                            }
                        } else {
                            acc.Core_Geo__c = coMarkAccIdToCoMarkAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_Geo__c;
                        }
                    }
                }
            }
        } catch(Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }

    /***************************************************************************************************** 
    Method name  : updateHostRegionAfterVirtualCorpUpdate
    Description  : when a virtual corp account' host region is changed, update the same to its child accounts
    Return Type  : VOID
    Parameter    : List Trigger.new, Map<Id,Account> Trigger.OldMap    
    Created By   : VB                 
    Date         : 29 Nov, 2022     
    ******************************************************************************************************/
    public static void updateHostRegionAfterVirtualCorpUpdate(List<Account> listNewAccount, Map<Id,Account> accRecsOldMap) {
        //Set to Store the coMarketing Account Ids
        Set<Id> coMarketingAccountIds = new Set<Id>();
        //Map to store the virtual corp account id as key and its details as value
        Map<Id, Account> virtualCorpIdsToVirtualCorpMap = new Map<Id, Account>();
        //List to store the accounts to update
        List<Account> childAccountsToBeUpdatedList = new List<Account>();
        Map<Id, Account> childAccIdsToChildAccMap = new Map<Id, Account>();
        try {
            //Get the channel Program id of IPA program
            Core_MDF_ChannelProgram__mdt channelProgramDetailsOfIPA = Core_MDF_ChannelProgram__mdt.getInstance('Intel_Partner_Alliance');
            // Get the account Ids of the virtual corp accounts on update of host region field
            for(Account acc : listNewAccount){
                if (acc.RecordTypeId == coMarketingRecordTypeId && acc.Core_MDF_Channel_Program__c == channelProgramDetailsOfIPA.Core_MDF_Program_ID__c && !acc.Core_MDF_CoMarketingActive__c && !acc.Core_MDF_CoMarketingAgency__c
                    && acc.Core_Geo__c != accRecsOldMap.get(acc.Id).Core_Geo__c) {
                        coMarketingAccountIds.add(acc.Id);
                    }
            }
            
            //query virtual corp and all the child accounts of virtual corp
            if(!coMarketingAccountIds.isEmpty()) {
                for(Account acc : [select Id, Name, Core_MDF_Parent_Fund_Account__c, Core_MDF_Parent_Fund_Account__r.RecordTypeId, 
                                        Core_MDF_Parent_Fund_Account__r.Core_Geo__c, Core_Geo__c, Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c,
                                        Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c, Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c 
                                        from Account where ((Core_MDF_Parent_Fund_Account__c IN: coMarketingAccountIds 
                                                             OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN: coMarketingAccountIds 
                                                             OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN: coMarketingAccountIds 
                                                             OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN: coMarketingAccountIds)
                                                            OR Id IN: coMarketingAccountIds)]) {
                                                                 if(acc.Core_MDF_Parent_Fund_Account__r.RecordTypeId == masterRecrodtypeId) {
                                                                     virtualCorpIdsToVirtualCorpMap.put(acc.Id, acc);
                                                                 } else {
                                                                     childAccIdsToChildAccMap.put(acc.Id, acc);
                                                                 }
                                                             }
            }
            
            //stamp the host region value from virtual corp to its child accounts
            if(!virtualCorpIdsToVirtualCorpMap.isEmpty() && !childAccIdsToChildAccMap.isEmpty()) {
                for(Account childAcc : childAccIdsToChildAccMap.values()) {
                    if(virtualCorpIdsToVirtualCorpMap.containsKey(childAcc.Core_MDF_Parent_Fund_Account__c) && 
                       virtualCorpIdsToVirtualCorpMap.get(childAcc.Core_MDF_Parent_Fund_Account__c).Id == childAcc.Core_MDF_Parent_Fund_Account__c) {
                           childAcc.Core_Geo__c = virtualCorpIdsToVirtualCorpMap.get(childAcc.Core_MDF_Parent_Fund_Account__c).Core_Geo__c;
                       }else if (virtualCorpIdsToVirtualCorpMap.containsKey(childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c) && 
                                 virtualCorpIdsToVirtualCorpMap.get(childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c).Id == childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c) {
                                     childAcc.Core_Geo__c = virtualCorpIdsToVirtualCorpMap.get(childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c).Core_Geo__c; 
                                 } else if (virtualCorpIdsToVirtualCorpMap.containsKey(childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c) && 
                                            virtualCorpIdsToVirtualCorpMap.get(childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c).Id == childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c) {
                                                childAcc.Core_Geo__c = virtualCorpIdsToVirtualCorpMap.get(childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c).Core_Geo__c;
                                            }else if(virtualCorpIdsToVirtualCorpMap.containsKey(childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c) && 
                                                     virtualCorpIdsToVirtualCorpMap.get(childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c).Id == childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c) {
                                                         childAcc.Core_Geo__c =virtualCorpIdsToVirtualCorpMap.get(childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c).Core_Geo__c;
                                                     }
                    childAccountsToBeUpdatedList.add(childAcc);
                }
            }

             
            
            if(!childAccountsToBeUpdatedList.isEmpty()) {
                update childAccountsToBeUpdatedList;
            }
        } catch(Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }   
    }
    
    /***************************************************************************************************** 
    Method name  : restrictHostRegionUpdateOnNodeAccounts
    Description  : To restrict the host region update on Node/Sub node accounts if its not same as its parent(before update)
    Return Type  : VOID
    Parameter    : Map<Id,Account> Trigger.NewMap, Map<Id,Account> Trigger.OldMap   
    Created By   : VB                 
    Date         : 12 Dec, 2022     
    ******************************************************************************************************/    
    public static void restrictHostRegionUpdateOnNodeAccounts(Map<Id,Account> newAccountMap, Map<Id,Account> accRecsOldMap) {
        try {
            Set<Id> parentFundAccountIdsSet = new Set<Id>();
            Map<Id,Account> coMarkAccIdToCoMarkAccMap = new Map<Id,Account>();
            List<Account> geoUpdatedAccountsList = new List<Account>();

            //Get the channel Program id of IPA program
            Core_MDF_ChannelProgram__mdt channelProgramDetailsOfIPA = Core_MDF_ChannelProgram__mdt.getInstance('Intel_Partner_Alliance');
            
            // Loop through the Accounts
            for(Account acc : newAccountMap.values()){
                if (acc.RecordTypeId == coMarketingRecordTypeId && acc.Core_MDF_Channel_Program__c == channelProgramDetailsOfIPA.Core_MDF_Program_ID__c  && !acc.Core_MDF_CoMarketingActive__c && !acc.Core_MDF_CoMarketingAgency__c) {
                    // sub-geo is updated/selected, throw error. Core_MDF_SubRegion_Inapplicable_Message - Sub-Region is not applicable for Intel Partner Alliance Program.
                    if(accRecsOldMap != null && accRecsOldMap.get(acc.Id).Core_Sub_Geo__c != acc.Core_Sub_Geo__c) {
                        acc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SubRegion_Inapplicable_Message'));
                    } 
                    //geo is updated without valid user access. Core_MDF_UserPermissionToInactivate - This user does not have permissions to perform this action.
                    else if(accRecsOldMap != null && accRecsOldMap.get(acc.Id).Core_Geo__c != acc.Core_Geo__c && !FeatureManagement.checkPermission('Core_MDF_CCP_users_with_Region_Field_Edit_Access_on_CoMarketing_Account')) {
                        acc.addError(Label.Core_MDF_UserPermissionToInactivate);
                    }
                    //geo is updated with valid user access - store the accounts and accounts parent Id
                    else if(accRecsOldMap != null && accRecsOldMap.get(acc.Id).Core_Geo__c != acc.Core_Geo__c && FeatureManagement.checkPermission('Core_MDF_CCP_users_with_Region_Field_Edit_Access_on_CoMarketing_Account')) {
                        geoUpdatedAccountsList.add(acc);
                        parentFundAccountIdsSet.add(acc.Core_MDF_Parent_Fund_Account__c);
                    }
                }
            }
            
            //query the parent fund account details, coMarkAccIdToCoMarkAccMap - Map of key as parent fund account Id and value as parent fund account record
            if(!parentFundAccountIdsSet.isEmpty()) {
                coMarkAccIdToCoMarkAccMap = new Map<Id, Account>([select Id, Name, Core_Geo__c, RecordTypeId, Core_MDF_Parent_Fund_Account__c from Account where Id IN: parentFundAccountIdsSet and RecordTypeId =: coMarketingRecordtypeId]);
            }
            
            //Throw an error 'Region Should be Same as its Parent Account', if the region on node/sub-node accounts is not same as its Parent Account's region
            if(!coMarkAccIdToCoMarkAccMap.isEmpty()) {
                    for(Account acc : geoUpdatedAccountsList){
                        if(coMarkAccIdToCoMarkAccMap.containsKey(acc.Core_MDF_Parent_Fund_Account__c) && coMarkAccIdToCoMarkAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Id == acc.Core_MDF_Parent_Fund_Account__c) {
                            if((newAccountMap.containsKey(acc.Core_MDF_Parent_Fund_Account__c) && 
                                newAccountMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_Geo__c != acc.Core_Geo__c)  || 
                               (!newAccountMap.containsKey(acc.Core_MDF_Parent_Fund_Account__c) && 
                                coMarkAccIdToCoMarkAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_Geo__c != acc.Core_Geo__c)) {
                                    acc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RegionMismatch_Error')); //Core_MDF_RegionMismatch_Error - Region Should be Same as its Parent Account
                                }
                        }
                    } 
                }
        } catch(Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }
    
    public static void processCCPTriggerUpdates(List<Account> newAccountList, Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap, String triggerContext) {
        if(triggerContext == 'before insert') {
            updateHostRegionOnNodeAccounts(newAccountList);
            system.debug('@@coming from before insert');
        } 
        
        if(triggerContext == 'after update') {
            updateHostRegionAfterVirtualCorpUpdate(newAccountList, oldAccountMap);            
        }
        
        if(triggerContext == 'before update') {
            restrictHostRegionUpdateOnNodeAccounts(newAccountMap, oldAccountMap);
            system.debug('@@coming from before update');
            isPrimeIdChanged(newAccountList, oldAccountMap);
        }
    }
    
   public static void preventManualVCInsertion(List<Account> newList){
        //sets to store Channel Program Ids and Parent Fund Account Ids
        Set<Id> programIds  = new Set<Id>();
        Set<Id> parentFundAcctIds  = new Set<Id>();
        //List store UniqueKey
        List<String> uniqueKeyList = New List<String>();
        //List to store Account
        List<Account> accList = New List<Account>();
        try{
            if(newList != NULL && newList.size()>0){
                for(Account acc : newList){
                    //Checking if Record type is co-marketing
                    if(acc.RecordTypeId == coMarketingRecordTypeId && acc.Core_MDF_Parent_Fund_Account__r.RecordType.DeveloperName =='Mastered_Account')

                        //storing Channel Program Id and Parent Fund Account Id in set
                        programIds.add(acc.Core_MDF_Channel_Program__c);
                        parentFundAcctIds.add(acc.Core_MDF_Parent_Fund_Account__c);
                        accList.add(acc);
                }  
                //check if sets are not null
                if(programIds != NULL && parentFundAcctIds != NULL && programIds.size() > 0 && parentFundAcctIds.size() > 0){
                    //Querying existing Virtual Corp Accounts
                    for( Core_MDF_Partner_Group_Mapping__c existpgm : [select Id,Name, Core_MDF_Channel_Program__c, Core_MDF_Account__c from Core_MDF_Partner_Group_Mapping__c where Core_MDF_Account__c IN : parentFundAcctIds and Core_MDF_Channel_Program__c IN : programIds and Core_MDF_Type_of_Access__c ='External']){                    
                        //Unique key generating using channel Program Id and Parent fund Account Id
                        String uniqueKey = (String.valueOf(existpgm.Core_MDF_Channel_Program__c) + String.valueOf(existpgm.Core_MDF_Account__c));
                        //Storing uniqueKey to List
                        uniqueKeyList.add(uniqueKey);
                    }
                }
                    for(Account acc : accList){
                        //checking unique key exist in List
                        if(uniqueKeyList.contains(String.valueOf(acc.Core_MDF_Channel_Program__c) + String.valueOf(acc.Core_MDF_Parent_Fund_Account__c))){
                           
                        }
                        else
                        {
                             acc.addError('Please reach out to Support Team');
                        }
                }
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    } 
    
    public static void isPrimeIdChanged(List<Account> listNewAccount, Map<Id,Account> accRecsOldMap) {
        List<Account> accLstForPgmInsertOrUpdate = new List<Account>();
        Map<Id,Account> accIdToAccMap = new Map<Id,Account>();
        List<Account> accForPGMInsert = new List<Account>();
        Set<String> accIdToPrimeIdKey = new Set<String>();
        List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
        List<Core_MDF_Partner_Group_Mapping__c> pgmListForPrimeId = new List<Core_MDF_Partner_Group_Mapping__c>();
        List<Core_MDF_Partner_Group_Mapping__c> pgmToBeUpdatedList = new List<Core_MDF_Partner_Group_Mapping__c>();
        List<Core_MDF_Partner_Group_Mapping__c> pgmToBeInsertedList = new List<Core_MDF_Partner_Group_Mapping__c>();
        Map<String,String> primeIdToGrpNameMap = new Map<String,String>();
        Set<String> primeIdSet = new Set<String>();
        //Get the channel Program id of IPA program
        Core_MDF_ChannelProgram__mdt channelProgramDetailsOfIPA = Core_MDF_ChannelProgram__mdt.getInstance('Intel_Partner_Alliance');
        try {
            for(Account acc : listNewAccount){
                if(acc.RecordTypeId == masterRecrodtypeId  && !acc.Core_MDF_CoMarketingActive__c && (accRecsOldMap == NULL || (accRecsOldMap != null && accRecsOldMap.get(acc.Id).Core_Prime_Id__c != acc.Core_Prime_Id__c))){
                    if(accRecsOldMap != null){
                        system.debug('@@coming inside accRecsOldMap != NULL');
                        accLstForPgmInsertOrUpdate.add(acc);
                        accIdToAccMap.put(acc.Id,acc);
                    }                    
                    if(String.isNotBlank(acc.Core_Prime_Id__c)){
                        system.debug('@@coming inside primeId != NULL');
                        primeIdSet.add(acc.Core_Prime_Id__c);
                        accForPGMInsert.add(acc);
                    }
                }
            }
            system.debug('@@coming to accForPGMInsert:' +accForPGMInsert);
            if((accLstForPgmInsertOrUpdate != NULL && accLstForPgmInsertOrUpdate.size()>0) || (primeIdSet != NULL && primeIdSet.size()>0)){
                pgmList =  [SELECT Id,Core_MDF_Account__c,Core_MDF_Account__r.Core_Prime_Id__c,Core_MDF_Account__r.Core_MDF_CoMarketingActive__c, Core_MDF_Account__r.Core_Intel_Partner_Alliance_PartnerGroup__c, Core_MDF_Group_Name__c,Core_MDF_Inactive_Ind__c  FROM Core_MDF_Partner_Group_Mapping__c WHERE (Core_MDF_Account__c IN: accLstForPgmInsertOrUpdate OR Core_MDF_Account__r.Core_Prime_Id__c IN: primeIdSet) AND 
                                                          Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name') AND
                                                          Core_MDF_Type_of_Access__c = 'External'];
                system.debug('@@coming inside pgmList:' +pgmList);
            }
            if(pgmList != NULL && pgmList.size()>0){
                for(Core_MDF_Partner_Group_Mapping__c pgm : pgmList){
                    accIdToPrimeIdKey.add(pgm.Core_MDF_Account__c+pgm.Core_MDF_Account__r.Core_Prime_Id__c);
                    if(accIdToAccMap.containsKey(pgm.Core_MDF_Account__c) && accIdToAccMap.get(pgm.Core_MDF_Account__c) != NULL && accIdToAccMap.get(pgm.Core_MDF_Account__c).Core_Prime_Id__c != pgm.Core_MDF_Account__r.Core_Prime_Id__c && !pgm.Core_MDF_Inactive_Ind__c){
                        Core_MDF_Partner_Group_Mapping__c pgmInstance = new Core_MDF_Partner_Group_Mapping__c();
                        pgmInstance.Id = pgm.Id;
                        pgmInstance.Core_MDF_Inactive_Ind__c = True;
                        pgmToBeUpdatedList.add(pgmInstance);
                    }else if(accIdToAccMap.containsKey(pgm.Core_MDF_Account__c) && accIdToAccMap.get(pgm.Core_MDF_Account__c) != NULL && accIdToAccMap.get(pgm.Core_MDF_Account__c).Core_Prime_Id__c == pgm.Core_MDF_Account__r.Core_Prime_Id__c && pgm.Core_MDF_Inactive_Ind__c && pgm.Core_MDF_Account__r.Core_Intel_Partner_Alliance_PartnerGroup__c){
                        Core_MDF_Partner_Group_Mapping__c pgmInstance = new Core_MDF_Partner_Group_Mapping__c();
                        pgmInstance.Id = pgm.Id;
                        pgmInstance.Core_MDF_Inactive_Ind__c = False;
                        pgmToBeUpdatedList.add(pgmInstance);
                    } 
                    if(primeIdSet.contains(pgm.Core_MDF_Account__r.Core_Prime_Id__c) && !pgm.Core_MDF_Inactive_Ind__c && pgm.Core_MDF_Account__r.Core_MDF_CoMarketingActive__c){
                        primeIdToGrpNameMap.put(pgm.Core_MDF_Account__r.Core_Prime_Id__c, pgm.Core_MDF_Group_Name__c);
                    }
                }
            }
            system.debug('@@coming inside primeIdToGrpNameMap:' +primeIdToGrpNameMap);
            if(accForPGMInsert != NULL && accForPGMInsert.size() >0 && primeIdToGrpNameMap != NULL && primeIdToGrpNameMap.size() >0){
                for(Account acc : accForPGMInsert){
                    if(primeIdToGrpNameMap.containsKey(acc.Core_Prime_Id__c) && primeIdToGrpNameMap.get(acc.Core_Prime_Id__c) != NULL && (accIdToPrimeIdKey.size() ==  0 || (accIdToPrimeIdKey != NULL && !accIdToPrimeIdKey.contains(acc.Id+acc.Core_Prime_Id__c)))){
                        system.debug('@@coming inside primeIdToGrpNameMap!= null');
                        system.debug('@@coming inside acc:' +acc.Id);
                        system.debug('@@coming inside primeId:' +acc.Core_Prime_Id__c);
                        Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
                        pgm.Core_MDF_Account__c = acc.Id;
                        pgm.Core_MDF_Channel_Program__c = channelProgramDetailsOfIPA.Core_MDF_Program_ID__c;
                        pgm.Core_MDF_Group_Name__c = primeIdToGrpNameMap.get(acc.Core_Prime_Id__c);
                        pgm.Core_MDF_Type_of_Access__c = 'External';
                        pgmToBeInsertedList.add(pgm);
                    }
                }
            }
            system.debug('@@coming inside pgmToBeInsertedList:' +pgmToBeInsertedList);
            if(pgmToBeUpdatedList != NULL && pgmToBeUpdatedList.size()>0){                
                Database.update(pgmToBeUpdatedList);
            }
            if(pgmToBeInsertedList != NULL && pgmToBeInsertedList.size()>0){ 
                system.debug('@@coming inside insert:');
                Database.insert(pgmToBeInsertedList);
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
}