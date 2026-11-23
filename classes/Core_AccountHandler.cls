/**************************************************************************************
Apex Class Name: Core_AccountHandler
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
 * Sarah Manuel        25/08/2020        Added code to onboard IPA accounts and Create group for Co-marketing Accounts
*************************************************************************************/
public class Core_AccountHandler{

    public static final String CPMID_DELIMITER       = ', ';  
    public static final String CPMID_DELIMITER_REGEX = '(,[\\s]*|\\s)';  // Delimiters: comma, or a blank, or any combination
    public static final String PARTNER_TYPE ='Core_Account_Type__c'; 
    public static final String COMPLETE_STR = 'Complete';
    public static final string eventType='Prime Name Update';
    static final String ODM ='Original Design Manufacturer (ODM)';
    static final String CORE_MP_STR = System.Label.PMP_Group_Name_Prefix;
    public static Map<Id,set<Id>> accIdToExtGrpIdMap = new Map<Id,set<Id>>();
    public static Id coMarketingRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Core_MDF_Co_Marketing_Record_Type_Name).getRecordTypeId(); //Added by Accenture - VD -> Check if the record type is not Co-Marketing
    public static Id pAGRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId(); //Added by Accenture - US408340 -> Check if the record type is not Core_Partner_Account_Group
    public static Id DirectAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Direct Account').getRecordTypeId();// Added by Unicorn Team to bypass trigger methods 
	public static Id requestedAccount = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Requested Account').getRecordTypeId();


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
            //Start of Changes - To check if the record type is not Core_Partner_Account_Group - US408340 - by Accenture 
            if(acc.RecordTypeId != coMarketingRecordTypeId && acc.RecordTypeId != pAGRecordTypeId && acc.RecordTypeId != DirectAccRecTypeId && acc.RecordTypeId != requestedAccount){
            //End of Changes - To check if the record type is not Core_Partner_Account_Group - US408340 - by Accenture 
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
    
    public static void accountObjectAfterHandler(List<Account> listNewAccount, Map<Id,Account> mapNewsObject, Map<Id,Account> mapOldsObject)
    {
        //added by LATA for PA/APD 2305 story
          List<PRM_Notification_Event_Log__c> notificationEventLog=new List<PRM_Notification_Event_Log__c>();
            for(account acc:listNewAccount){
                if(acc.Core_Prime_Account_Name__c != mapOldsObject.get(acc.Id).Core_Prime_Account_Name__c){
                    PRM_Notification_Event_Log__c eventLog=PRM_IPA_Utility.getNotificationLogInstance(eventType,acc.Core_Prime_Account_Name__c,acc.id,null);
                    notificationEventLog.add(eventLog);
                }
            }
            if(!notificationEventLog.isEmpty() && notificationEventLog.size()>0){
                insert notificationEventLog;
            }
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
            if(acct.RecordTypeId != coMarketingRecordTypeId && acct.RecordTypeId != pAGRecordTypeId && acct.RecordTypeId != DirectAccRecTypeId) //Added by Accenture - VD -> Check if the record type is not Co-Marketing. Check to bypass for PAG record type is Added by Accenture - Anupam 
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
            if(newAcc.RecordTypeId != coMarketingRecordTypeId && newAcc.RecordTypeId != pAGRecordTypeId && newAcc.RecordTypeId != DirectAccRecTypeId) //Added by Accenture - VD -> Check if the record type is not Co-Marketing. Check to bypass for PAG record type is Added by Accenture - Anupam 
            {
                if ((newAcc.Core_Account_Team_Audit_Complete__c == true && oldMap.get(newAcc.Id).Core_Account_Team_Audit_Complete__c == false)
                    && (newAcc.Core_Account_Team_Audit_Due_Date__c != null)) {
                        auditCompletedAccounts.add(newAcc.Id);
                    }
            }
        }
        
        //Get a list of associated audit log entries
        if(!auditCompletedAccounts.isEmpty()&& auditCompletedAccounts.size()>0){
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
                if(coMarketingRecordTypeId != account.RecordTypeId && pAGRecordTypeId != account.RecordTypeId && DirectAccRecTypeId != account.RecordTypeId ) //Added by Accenture - VD -> Check if the record type is not Co-Marketing. Check to bypass for PAG record type is Added by Accenture - Anupam 
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
            if(acctObj.RecordTypeId != coMarketingRecordTypeId && acctObj.RecordTypeId != pAGRecordTypeId && acctObj.RecordTypeId != DirectAccRecTypeId) //Added by Accenture - VD -> Check if the record type is not Co-Marketing. Check to bypass for PAG record type is Added by Accenture - Anupam 
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
           if(a.RecordTypeId != coMarketingRecordTypeId && a.RecordTypeId != pAGRecordTypeId && a.RecordTypeId != DirectAccRecTypeId) //Added by Accenture - VD -> Check if the record type is not Co-Marketing. Check to bypass for PAG record type is Added by Accenture - Anupam
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
    
    public static void validateAccountForMDF(List<Account> newAccountList,Map<Id,Account> oldAccountMap){
        //To store accounts that are IPA and are being made as Co-Marketing Active
        List<Account> accountToBeProcessed = new List<Account>();
        for(Account newAcc : newAccountList){
            if(oldAccountMap!=null && newAcc.Core_MDF_CoMarketingActive__c != oldAccountMap.get(newAcc.Id).Core_MDF_CoMarketingActive__c &&    
               (!(oldAccountMap.get(newAcc.Id).Core_MDF_CoMarketingActive__c)) && newAcc.Core_MDF_CoMarketingActive__c && newAcc.Core_Intel_Partner_Alliance_PartnerGroup__c){
                   accountToBeProcessed.add(newAcc);
               }
        }
        system.debug('validateAccountForMDF accountToBeProcessed - '+accountToBeProcessed);
        if(accountToBeProcessed!=null && accountToBeProcessed.size()>0){
            //Method to validate and onBoard an IPA Account into MDF
            //Commented below line because dependant classes were not available in DEVIPA
           // Core_MDF_CCPAccount_Onboard.isAccountEligibleForMDF(accountToBeProcessed); //Agate
        }
    }
  
    // Uday 5/5/2019 US351963 - Populate all the MP fields from Account to its Company Information object.
    /***************************************************************************************************** 
    Method Name:                                             updatePartnerInfo
    @return  :                                               Void
    Modified By:                       Date:                 Changes: 
    Udaya Katta                      5/5/2019                Original Version
    ******************************************************************************************************/
    public static void updatePartnerInfo(List<Account> newList, Map<Id,Account> newMap, Map<Id,Account> oldMap) {
        
       /* Set<Id> accountsChanged = new Set<Id>();
        List<PMP_Company__c> updateCompanies = new List<PMP_Company__c>();
        Map<Id, List<PMP_Company__c>> acc_companiesMap = new Map<Id, List<PMP_Company__c>>();
        Id intelacc_rectypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        try{
            for(Account acc : newList){
                Account old = oldMap.get(acc.Id);
                if(acc.RecordTypeId == intelacc_rectypeid && 
                   (acc.Name != old.Name || 
                    acc.Core_IPA_Partner_Speciality__c != old.Core_IPA_Partner_Speciality__c  ||
                    acc.Core_User_Defined_Website__c != old.Core_User_Defined_Website__c||
                    acc.Core_IPA_Partner_Role__c != old.Core_IPA_Partner_Role__c)){
                        accountsChanged.add(acc.Id);
                    }
            }
            
            if(accountsChanged.size() > 0){
                for(PMP_Company__c comp : [Select Id, PMP_Account_Id__c, PMP_Account_Application__c, 
                                           PMP_Account_Industry__c, PMP_Account_Region__c, PMP_Account_Specialty__c, 
                                           PMP_Account_Sub_Region__c,  PMP_Account_Website__c, PMP_Account_Program_Membership__c,
                                           PMP_Partner_Program_nm__c From PMP_Company__c 
                                           Where PMP_Account_Id__c IN: accountsChanged]){
                    Account acc_new = newMap.get(comp.PMP_Account_Id__c);
                    Account acc_old = oldMap.get(comp.PMP_Account_Id__c);
                    String partnerPgm = comp.PMP_Partner_Program_nm__c;
                    String progMember = comp.PMP_Account_Program_Membership__c;
                    String acctPartnerPgm = acc_new.Core_IPA_Partner_Role__c;
                    if(acc_new.Name != acc_old.Name){
                        comp.Name    = acc_new.Name;                                               
                    }
                    
                    if(acc_new.Core_IPA_Partner_Speciality__c != acc_old.Core_IPA_Partner_Speciality__c){
                        comp.PMP_Account_Specialty__c    = acc_new.Core_IPA_Partner_Speciality__c;                                               
                    }
                    
                    if(acc_new.Core_User_Defined_Website__c != acc_old.Core_User_Defined_Website__c){
                        comp.PMP_Account_Website__c    = acc_new.Core_User_Defined_Website__c;                                               
                    }
            //Added by Manjula as part of Sponsor partner program changes -US617305                            
                   if(acc_new.Core_IPA_Partner_Role__c != acc_old.Core_IPA_Partner_Role__c && acctPartnerPgm.contains(System.Label.PMP_Sponsor_Partner_Program) && (!partnerPgm.contains(System.Label.PMP_Other_Partner_Program))){
                        comp.PMP_Partner_Program_nm__c = partnerPgm +';'+ System.Label.PMP_Other_Partner_Program;
                        comp.PMP_Account_Program_Membership__c = progMember +';'+ System.Label.PMP_Other_Partner_Program;
                    }
                    
                    updateCompanies.add(comp);
                }
            }
            if(updateCompanies.size() > 0)  update(updateCompanies);
            
        } catch (exception ex){
            system.debug('Error : '+ ex.getMessage()+ ' Cause : ' + ex.getCause()+' Line : '+ ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage()+ ' ' + ex.getCause()+' '+ ex.getLineNumber());
        }*/
    }   

    /***************************************************************************************************** 
    Method Name:membershipFlagUpdate                                          
    @return  :  Void
    Created By:                       
    Date: 29/7/2020                  
    Manikanta                                                  
    ******************************************************************************************************/
   public static void membershipFlagUpdate(List<Account> oldAccList,List<Account> newAccList, Map<Id,Account> oldAccMap, Map<Id,Account> newAccMap){
        
       System.debug('oldAccList = '+ oldAccList);
       System.debug('newAccList = '+ newAccList);
       Set<Id> accIds = new Set<Id>();
       
       for(Account changedAcc:newAccList){
           Account oldAccount = oldAccMap.get(changedAcc.Id);
           Account newAccount = newAccMap.get(changedAcc.Id);
           System.debug('oldAccount partner type = '+ oldAccount.OwnerId);
           System.debug('newAccount partner type = '+ newAccount.OwnerId);
           if(oldAccount.OwnerId != newAccount.OwnerId){
               accIds.add(changedAcc.Id);  
           }
        }
       
       
          
        Set<ID> partneracctIds=new Set<ID>();
       if(accIds!=null && !accIds.isEmpty()){ 
        for(Core_Account_Group_Member__c partneraccount : [SELECT Id, Core_Partner_Account_Id__c, Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c 
                                                               WHERE Core_Intel_Account_Id__c IN :accIds ]) {
                   if(partneraccount != null && partneraccount.Core_Partner_Account_Id__c != null)
                    partneracctIds.add(partneraccount.Core_Partner_Account_Id__c);
        }
} 
        List<Account> accToUpdate = new List<Account>();
        
        for(Id partnerAcc : partneracctIds){
            
            Account accTemp = new Account();
            accTemp.Id = partnerAcc;
            accTemp.Core_PMP_Membership_Change_Ind__c = true;
            accToUpdate.add(accTemp);
            
        }
       if(!accToUpdate.isEmpty()){
           Database.Update(accToUpdate);
       }
       
    }
    
    
    /***************************************************************************************************** 
    Method Name:invokeRollUpScenario                                          
    @return  :  Void
    Created By :  Rahul Kainth                    
    Date: 15/9/2020                  
    ******************************************************************************************************/
    public static void invokeRollUpScenario(List<Account> actList,Map<Id,Account> acctMap){
        PRM_PAGAccountTriggerRollUp.updatepagaccount(actList,acctMap);
    }
    
    
    /*************************************************************************************************************
   * Method Name:                                            createGroupForComarketingAccount
    @return  :                                               Void
    Modified By:                            Date:            Changes: 
    Accenture – AS                          19/08/2020       This method is used Create Group on Co-Marketing Account
************************************************************************************************************/
    public static List<Account> createGroupForComarketingAccount(List<Account> accountList){
        //To Store Co-Marketing Accounts
        List<Account> coMarkAccountToBeProcessed= new List<Account>();
        
        for(Account acc : accountList){
            if(acc.RecordTypeId == coMarketingRecordTypeId){
                coMarkAccountToBeProcessed.add(acc);
            }
        }        
        if(coMarkAccountToBeProcessed!=null && coMarkAccountToBeProcessed.size()>0){
            //Method to Create Groups for Co-Marketing Accounts
            //Core_MDF_Account_Utility.createGroupForAccountNode(coMarkAccountToBeProcessed); //Agate
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
           //Id batchInstanceId = Database.executeBatch(new Core_MDF_Batch_SharingWithNewAcctGrp(accountList));  //Agate 
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
    Method Name: validateTierValues
    @return  :  Void
    Created By: Sanket Mahajan                   
    Date: 03 June, 2021                  
    ******************************************************************************************************/
    public static void validateTierValues(List<Account> newAccList){
        Core_Opp_Bypass_Validation_Rule__c bypassValidationProfile = Core_Opp_Bypass_Validation_Rule__c.getInstance(UserInfo.getProfileId());
        Core_Opp_Bypass_Validation_Rule__c bypassValidationUser = Core_Opp_Bypass_Validation_Rule__c.getInstance(UserInfo.getUserId());
        if(!bypassValidationProfile.Bypass__c || !bypassValidationUser.Bypass__c  ){
            for(account acc: newAccList){
                String tier = acc.Core_Account_Tier__c;
                if(!String.isBlank(tier)){
                    if(tier.contains('CCG')){
                        Integer ccg = tier.countMatches('CCG');
                        if(ccg > 1)
                        displayMessage(acc,'CCG');
                    }
                    if(tier.contains('DCG')){
                        Integer tierValue = tier.countMatches('DCG');
                        if(tierValue > 1)
                        displayMessage(acc,'DCG');
                    }
                    if(tier.contains('GA')){
                        Integer tierValue = tier.countMatches('GA');
                        if(tierValue > 1)
                        displayMessage(acc,'GA');
                    }
                    if(tier.contains('IOTG')){
                        Integer tierValue = tier.countMatches('IOTG');
                        if(tierValue > 1)
                        displayMessage(acc,'IOTG');
                    }
                    if(tier.contains('ISG')){
                        Integer tierValue = tier.countMatches('ISG');
                        if(tierValue > 1)
                        displayMessage(acc,'ISG');
                    }
                    if(tier.contains('NTG')){
                        Integer tierValue = tier.countMatches('NTG');
                        if(tierValue > 1)
                        displayMessage(acc,'NTG');
                    }
                    if(tier.contains('PSG')){
                        system.debug('PSG');
                        Integer tierValue = tier.countMatches('PSG');
                        if(tierValue > 1)
                        displayMessage(acc,'PSG');
                        system.debug('>1 psg');
                    }
                    if(tier.contains('RSG')){
                        Integer tierValue = tier.countMatches('RSG');
                        if(tierValue > 1)
                        displayMessage(acc,'RSG');
                    }
                }
            }
        }
    }
    /***************************************************************************************************** 
    Method Name: displayMessage
    @return  :  Void
    Created By: Sanket Mahajan                   
    Date: 03 June, 2021                  
    ******************************************************************************************************/
    public static void displayMessage(Account acc,String tierValue){
        acc.Core_Account_Tier__c.addError('Please select only one '+tierValue+ ' Tier value.');
    }
    
    /***************************************************************************************************** 
    Method Name: preventUncoveredAccountChangeOnOppStatus
    @return  :  Void
    Created By: Sanket Mahajan                   
    Date: 24 Sep, 2021          
    TWC3123-75     
    ******************************************************************************************************/
    public static void preventUncoveredAccountChangeOnOppStatus(List<Account> newList, Map<Id, Account> oldMap) {
        List<Account> accountsChangedToUncovered = new List<Account>();
        for(Account acctObj : newList) {
            if(acctObj.OwnerId == Label.Core_Uncovered_Account_ID && oldMap.get(acctObj.Id).OwnerId != Label.Core_Uncovered_Account_ID) {
                accountsChangedToUncovered.add(acctObj);
            }
        }
        
        Map<id, List<Opportunity>> AccntOppMap = new Map<id, List<Opportunity>>();
        if(accountsChangedToUncovered.size()>0 && !accountsChangedToUncovered.isEmpty()){
            for(Account accObj : [Select id, name, (Select id,Core_Pending_Product_Count__c,Core_No_of_On_Hold_Opportunity_Products__c,Core_Open_Oppty__c from Opportunities) from Account where id in:accountsChangedToUncovered ]){
                if(accObj.Opportunities.size()>0){
                  //AccntOppMap.put(accObj.id,accObj.Opportunities);
                    for(Opportunity sr : accObj.Opportunities){
                        if(!AccntOppMap.containskey(accObj.id)){
                            AccntOppMap.put(accObj.id, new List<Opportunity>{sr});
                        }
                        else{
                            AccntOppMap.get(accObj.id).add(sr);
                        }
                    }
                }
                
            }
        }

        if(!AccntOppMap.isEmpty()){
            for(Account acctObj : accountsChangedToUncovered){
                List<Opportunity> OppList = new List<Opportunity>();
                OppList = AccntOppMap.get(acctObj.id);
                if(OppList.size()>0){
                    for(Opportunity opp : OppList){
                        if(opp.Core_Open_Oppty__c  == 1 || opp.Core_Pending_Product_Count__c > 0 || opp.Core_No_of_On_Hold_Opportunity_Products__c > 0){
                            acctObj.addError(Label.Core_PreventUncoveredonUpdate);
                        }
                    }
                }
            }
        }
    }
    Public static void createNodeSharingGroup(Map<Id,Account> newMap){
        Id coMarketingRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Core_MDF_Co_Marketing_Record_Type_Name).getRecordTypeId();
        Map<Id,Group> accIdGrpNameMap = new Map<Id,Group>();
        for(Account acc : newMap.values()){
            if(acc.RecordTypeId == coMarketingRecordtypeId){
                Group newNodeGroup = new Group();
                newNodeGroup.name = 'CCP_'+acc.Id+'_EXT_GRP';
                newNodeGroup.DeveloperName = 'Core_MDF_CCP_'+acc.Id+'_EXT_GRP';	
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
        //Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Account',accIdGrpIdListMap, 'Edit');//Agate
    	//List<AccountShare> accountShareList = Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst); //Agate
        List<Account> accToUpdate = new List<Account>();
    /*    for(account acc : [select id,Core_MDF_External_Group_Id__c from Account where Id in:accIdGrpNameMap.keyset()]){
            acc.Core_MDF_External_Group_Id__c = accIdGrpNameMap.get(acc.Id).Id;
                accToUpdate.add(acc);
        } */
        Database.update(accToUpdate); 
        
    }
    
    //TWC729-3627:Update Intel Record type field for Inactive_Account.
    Public static void accountRecordTypeAfterUpdate(List<Account> newAccList, Map<Id,Account> oldAccMap, Map<Id,Account> newAccMap){
        
        Set<Id> accountId = new Set<Id>();         
        for(Account acc:newAccList){
           if(oldAccMap.get(acc.Id).RecordTypeID != newAccMap.get(acc.Id).RecordTypeID){
               accountId.add(acc.ID); 
           }
        } 
        
      /*  System.debug('Account Group query->'+[SELECT Id, Core_Partner_Account_Id__c,Core_Intel_Account_Id__c,Core_Intel_Account_Id__r.RecordType.DeveloperName
                                                               FROM Core_Account_Group_Member__c 
                                                               WHERE Core_Intel_Account_Id__c IN :accountId]);*/
        List<Core_Account_Group_Member__c> coreActList = new  List<Core_Account_Group_Member__c>();        
        if(accountId!=null && !accountId.isEmpty()){ 
            
            for(Core_Account_Group_Member__c partneraccount : [SELECT Id, Core_Partner_Account_Id__c,Core_Intel_Account_Id__c,Core_Intel_Account_Id__r.RecordType.DeveloperName
                                                               FROM Core_Account_Group_Member__c 
                                                               WHERE Core_Intel_Account_Id__c IN :accountId ]) {
                     if(partneraccount != null && partneraccount.Core_Partner_Account_Id__c != null){
                         partneraccount.Intel_Record_Type_Text__c = partneraccount.Core_Intel_Account_Id__r.RecordType.DeveloperName;  
                         coreActList.add(partneraccount);
                     }                        
                }
            if(!coreActList.isEmpty()){
                update coreActList;
            }   
             System.debug('Account Group query->'+[SELECT Id, Core_Partner_Account_Id__c,Core_Intel_Account_Id__c,Core_Intel_Account_Id__r.RecordType.DeveloperName
                                                               FROM Core_Account_Group_Member__c 
                                                               WHERE Core_Intel_Account_Id__c IN :accountId]); 
        }        
    }
    

}