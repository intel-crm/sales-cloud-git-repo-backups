public without sharing class Core_AccountTriggerHandlerController {
    public static final String CPMID_DELIMITER       = ', ';  
    public static final String CPMID_DELIMITER_REGEX = '(,[\\s]*|\\s)';  // Delimiters: comma, or a blank, or any combination
    public static final String PARTNER_TYPE ='Core_Account_Type__c'; 
    public static final String COMPLETE_STR = 'Complete';
    static final String ODM ='Original Design Manufacturer (ODM)';
    static final String CORE_MP_STR = System.Label.PMP_Group_Name_Prefix;
    public static Id coMarketingRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Core_MDF_Co_Marketing_Record_Type_Name).getRecordTypeId(); //Added by Accenture - VD -> Check if the record type is not Co-Marketing
    public static Id pAGRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId(); //Added by Accenture - US408340 -> Check if the record type is not Core_Partner_Account_Group
    public static Id DirectAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Direct Account').getRecordTypeId();// Added by Unicorn Team to bypass trigger methods 
    public static Id requestedAccount = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Requested Account').getRecordTypeId();
    public static Map<Id,set<Id>> accIdToExtGrpIdMap = new Map<Id,set<Id>>();

    private static UCD_ACM_ServiceContracts.IAccountService accountServiceInstance = UCD_ACM_AccountService.getInstance();
    private static Id intelAccountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    private static Id endCustomerRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('End Customer Deal Account').getRecordTypeId();
    private static Id rejectedAccount = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Rejected Account').getRecordTypeId();

    /*
     * description : Assign Account record type to new field value before insert and before update
                    This method is called from Core_Account trigger.
     * params : List<Account> newValues
     * return : NA
     * author and date : Tejasri yenuganti, 19 May 2022
    */
    public static void accountRecordTypeDupFieldUpdate(List<Account> allAccounts) {
        if(allAccounts!= null){
            for (Account newAccount : allAccounts) {
                String recordTypeName = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosById().get(newAccount.RecordTypeId).getName();
                newAccount.Core_Account_Record_Type_Dup_Check__c = recordTypeName;
            }
        }
    }

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
    Method Name: preventMultipleVCForSameProg
    @return  :  Void
    Created By: SH                  
    Date: 30 MAR, 2022     
    ******************************************************************************************************/
    public static void preventMultipleVCForSameProg (List<Account> newList){
        if(newList != null){
            //sets to store Channel Program Ids and Parent Fund Account Ids
            Set<Id> programIds  = new Set<Id>();
            Set<Id> parentFundAcctIds  = new Set<Id>();
            //List store UniqueKey
            List<String> uniqueKeyList = New List<String>();
            //List to store Account
            List<Account> accList = New List<Account>();
            //Map to store UniqueKey and Account Name
            Map<String,String> uniqueKeyToAccName = new Map<String,String>();
            try{
                if(newList != NULL && newList.size()>0){
                    for(Account acc : newList){
                        //Checking if Record type is co-marketing
                        if(acc.RecordTypeId == coMarketingRecordTypeId){
                            //storing Channel Program Id and Parent Fund Account Id in set
                            programIds.add(acc.Core_MDF_Channel_Program__c);
                            parentFundAcctIds.add(acc.Core_MDF_Parent_Fund_Account__c);
                            accList.add(acc);
                        }
                    }  
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
    }

    /***************************************************************************************************** 
    Method Name: validateTierValues
    @return  :  Void
    Created By: Sanket Mahajan                   
    Date: 03 June, 2021                  
    ******************************************************************************************************/
    public static void validateTierValues(List<Account> newAccList){
        if(newAccList != null){
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
                System.debug(a);
                System.debug('preventAEUserAccountOwnership!!!'+a.OwnerId + '@@@'+ oldMap.get(a.Id).OwnerId);
                if (a.OwnerId != oldMap.get(a.Id).OwnerId) {
                    accountsChangedOwnership.add(a);
                    accountOwnerIdsChangedOwnership.add(a.OwnerId);
                }
            }
        }
        Set<Id> aeUserIds = new Set<Id>();
        if(!accountOwnerIdsChangedOwnership.isEmpty()){
        	Map<Id,User> aeUserOwnerMap = new Map<Id,User>([select Id from User where Id in :accountOwnerIdsChangedOwnership
                                                        and ProfileId = :Label.Core_A_E_User_Profile_ID]);
        	aeUserIds = aeUserOwnerMap.keySet();
        }         
        
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
     * description : Update Billing Address.
     * params : List<Account> accounts
     * return : NA
     * author and date : harshalx.sunil.gosavi@intel.com, 08/12/2021
    */
    public static void updateAccountAddress(List<Account> accounts) {
        if(accounts !=null){
            Set<Id> loggingAccountIds = new Set<Id>();
            try {
                For(Account account: accounts) {
                    loggingAccountIds.add(account.Id);
                    if (account.Core_Customer_Aggregation_Type__c != null && account.Core_Data_Country_Nm__c != null) {
                        if ((account.BillingCountryCode == '' || account.BillingCountryCode == null)) {
                            account.BillingCountryCode = UCD_ACM_Utils.validateCountryName(account.Core_Data_Country_Nm__c);
                        }
                        if ((account.ShippingCountryCode == '' || account.ShippingCountryCode == null)) {
                            account.ShippingCountryCode = UCD_ACM_Utils.validateCountryName(account.Core_Data_Country_Nm__c);
                        }
                    }
                }
            }
            catch (Exception ex) {
                UCD_ACM_Logger.error('Core_AccountTriggerHandlerController','updateAccountAddress','Message: ' + ex.getMessage() + '. StackTrace: ' + ex.getStackTraceString() + ' UserName: ' + UserInfo.getUserName(),'AccountIds: ' + loggingAccountIds.toString());
                UCD_ACM_Logger.setLogDetails();
            }
        }
    }

    /*
     * description : Ignore updating Name/Billing/Shipping Address/Account Owner if existing UCD SF record.
     * params : List<Account> newValues, List<Account> oldvalues
     * return : NA
     * author and date : ankit1x.sharma@intel.com, 20/11/2021
    */
    public static void restrictUpdatingSFFields(List<Account> newValues, List<Account> oldvalues) {
        if(newValues != null && oldvalues != null){
            String allUser = System.Label.UCD_ACM_RestrictAccountsUpdateByUsers;
            Set<String> lstofUser = new Set<String>(allUser.split(','));
            boolean validUser = lstofUser.contains(UserInfo.getUserName());
            if (validUser) {
                accountServiceInstance.restrictUpdatingSFFields(newValues,oldvalues);
            }
        }
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
                System.debug('preventUncoveredAccountChange!!!'+acctObj.OwnerId + '@@@'+ oldMap.get(acctObj.Id).OwnerId);
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

    /***************************************************************************************************** 
    Method Name: preventUncoveredAccountChangeOnOppStatus
    @return  :  Void
    Created By: Sanket Mahajan                   
    Date: 24 Sep, 2021          
    TWC3123-75     
    ******************************************************************************************************/
    public static void preventUncoveredAccountChangeOnOppStatus(List<Account> newList, Map<Id, Account> oldMap) {
        if(newList != null && oldMap != null){
            List<Account> accountsChangedToUncovered = new List<Account>();
            for(Account acctObj : newList) {
                if(acctObj.OwnerId == Label.Core_Uncovered_Account_ID && oldMap.get(acctObj.Id).OwnerId != Label.Core_Uncovered_Account_ID) {
                    accountsChangedToUncovered.add(acctObj);
                }
            }
            
            Map<id, List<Opportunity>> AccntOppMap = new Map<id, List<Opportunity>>();
            if(accountsChangedToUncovered.size()>0 && !accountsChangedToUncovered.isEmpty()){
                // changed by Ankit (Remove query from for loop)
                List<Account> lstAccount = [Select id, name, (Select id,Core_Pending_Product_Count__c,Core_No_of_On_Hold_Opportunity_Products__c,Core_Open_Oppty__c from Opportunities) from Account where id in:accountsChangedToUncovered ];
                for(Account accObj : lstAccount){
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
    }
    
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
                            System.debug('acc.Core_MDF_Channel_Program__r@@@'+acc.Core_MDF_Channel_Program__c);
                            System.debug('acc.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c@@@'+acc.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c);
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

    /*
     * description : If Business Party Id is already present in salesforce then change the recordType
     *               to RejectedAccount otherwise it is EndCustomer.
     * params : Trigger.new (List<Account>,Trigger.isInsert,Trigger.isUpdate)
     * return : NA
     * author and date : Harshal Gosavi, 4th August 2021
    */
    public static void updateAccountRecordType(List<Account> newValues, Map<Id,Account> oldMap) {
        /*for(Account account : newValues){
            //accountServiceInstance.updateAccRecordTypeByBpId(account,oldMap);
           }*/
        if(newValues!=null && oldMap != null)
            accountServiceInstance.updateAccRecordTypeByBpId(newValues,oldMap);
    }

    /*
     * description : Set UCD hierarchy fields before insert
     * params : List<Account> newValues
     * return : NA
     * author and date : chethan.s.kunder@intel.com, 25 Nov. 2021
    */
    public static void updateHierarchyFields(List<Account> newValues) {
        If(newValues != null){
            Set<Id> loggingAccountIds = new Set<Id>();
            try {
                for (Account account : newValues) {
                    loggingAccountIds.add(account.Id);
                    if (account.Core_Customer_Aggregation_Type__c != null) {
                        accountServiceInstance.updateHierarchyFields(account, false);
                    }
                }
            }
            catch (Exception ex) {
                UCD_ACM_Logger.error('Core_AccountTriggerHandlerController','updateHierarchyFields','Message: ' + ex.getMessage() + '. StackTrace: ' + ex.getStackTraceString() + ' UserName: ' + UserInfo.getUserName(),'AccountIds: ' + loggingAccountIds.toString());
                UCD_ACM_Logger.setLogDetails();
            }
        }
    }

    /*
     * description : Update Account UCD hierarchy fields before update and Child account UCD hierarchy fields after update (change in ParentId/Customer Aggr. Type)
     * params : List<Account> newValues, List<Account> oldvalues, Boolean updateChildAccounts
     * return : NA
     * author and date : chethan.s.kunder@intel.com, 25 Nov. 2021
    */
    public static void updateHierarchyFields(List<Account> newAccounts, Map<Id,Account> oldAccounts, Boolean updateChildAccounts) {
        Set<Id> loggingAccountIds = new Set<Id>();
        try {
            for (Account account : newAccounts) {
                loggingAccountIds.add(account.Id);
                if (account.Core_Customer_Aggregation_Type__c != null && (account.ParentId != oldAccounts.get(account.Id).ParentId || account.Core_Customer_Aggregation_Type__c != oldAccounts.get(account.Id).Core_Customer_Aggregation_Type__c || account.RecordTypeId != oldAccounts.get(account.Id).RecordTypeId)) {
                    accountServiceInstance.updateHierarchyFields(account, updateChildAccounts);
                }
            }
        }
        catch (Exception ex) {
            UCD_ACM_Logger.error('Core_AccountTriggerHandlerController','updateHierarchyFields','Message: ' + ex.getMessage() + '. StackTrace: ' + ex.getStackTraceString() + ' UserName: ' + UserInfo.getUserName(),'AccountIds: ' + loggingAccountIds.toString());
            UCD_ACM_Logger.setLogDetails();
        }
    }

    /*************************************************************************************************************
    * Method Name:                                            createGroupForComarketingAccount
    @return  :                                               Void
    Modified By:                            Date:            Changes: 
    Accenture – AS                          19/08/2020       This method is used Create Group on Co-Marketing Account
    ***********************************************************************************************************/
    public static List<Account> createGroupForComarketingAccount(List<Account> accountList){
        If(accountList != null){
            //To Store Co-Marketing Accounts
            List<Account> coMarkAccountToBeProcessed= new List<Account>();
            
            for(Account acc : accountList){
                if(acc.RecordTypeId == coMarketingRecordTypeId){
                    coMarkAccountToBeProcessed.add(acc);
                }
            }        
            if(coMarkAccountToBeProcessed!=null && coMarkAccountToBeProcessed.size()>0){
                //Method to Create Groups for Co-Marketing Accounts
                Core_MDF_Account_Utility.createGroupForAccountNode(coMarkAccountToBeProcessed);
            }
            return coMarkAccountToBeProcessed;
        }
        return null;
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
            System.debug('check@@@!!!===>'+e.getStackTraceString());
            //If there is any exception, append it to the list of sobject records
            for(Account account : oldList)
                account.addError(System.Label.Core_Exception+e.getMessage());                          
        }    
        
        System.debug('accountObjectAfterDelete : END');        
    }
    
    //TWC729-3627:Update Intel Record type field for Inactive_Account.
    Public static void accountRecordTypeAfterUpdate(List<Account> newAccList, Map<Id,Account> oldAccMap, Map<Id,Account> newAccMap){
            Set<Id> accountId = new Set<Id>();         
            for(Account acc:newAccList){
            if(oldAccMap.get(acc.Id).RecordTypeID != newAccMap.get(acc.Id).RecordTypeID){
                accountId.add(acc.ID); 
            }
            } 
            
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
    Method Name:membershipFlagUpdate                                          
    @return  :  Void
    Created By:                       
    Date: 29/7/2020                  
    Manikanta                                                  
    ******************************************************************************************************/
    public static void membershipFlagUpdate(List<Account> oldAccList,List<Account> newAccList, Map<Id,Account> oldAccMap, Map<Id,Account> newAccMap){

        Set<Id> accIds = new Set<Id>();
        
        for(Account changedAcc:newAccList){
            Account oldAccount = oldAccMap.get(changedAcc.Id);
            Account newAccount = newAccMap.get(changedAcc.Id);
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
         /*List<Account> accToUpdate = new List<Account>();
         
         for(Id partnerAcc : partneracctIds){
             
             Account accTemp = new Account();
             accTemp.Id = partnerAcc;
             accTemp.Core_PMP_Membership_Change_Ind__c = true;
             accToUpdate.add(accTemp);
             
         }
        if(!accToUpdate.isEmpty()){
            Database.Update(accToUpdate);
        }*/
        
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

    /*
     * description : This method check accounts record type and Cutomer Aggregation Type.
       If account record type is 'Intel Account' and Customer Aggregation Type is not blank
       then pass the list of account to UCD_ACM_AccountService.
     * params : List<Account>,Trigger.isInsert,Trigger.isUpdate
     * return : NA
     * author and date : Harshal Gosavi, 4th August 2021
    */
    public static void triggerPlatformEventOnUpdate(List<Account> triggerAccounts, map<Id,Account> accountById) {
        if(triggerAccounts != null && accountById != null){
            // Create a Set for account Id.
            Set<Id> accountIds = new Set<Id>();
            //For(Account account : triggerAccounts){
            try {
                For(Account account: triggerAccounts) {
                    if ((account.RecordTypeId == intelAccountRecordType ||
                        account.RecordTypeId == rejectedAccount ||
                        account.RecordTypeId == endCustomerRecordType) &&  (account.Core_Customer_Aggregation_Type__c != null) &&
                        ((account.Core_Customer_Aggregation_Type__c != accountById.get(account.Id).Core_Customer_Aggregation_Type__c) ||
                        (account.Core_Survivor_Account_Id__c != accountById.get(account.Id).Core_Survivor_Account_Id__c) ||
                        (account.Core_Business_Party_Id__c != accountById.get(account.Id).Core_Business_Party_Id__c) ||
                        (account.Core_Data_Simplified_Account_Nm__c != accountById.get(account.Id).Core_Data_Simplified_Account_Nm__c) ||
                        (account.RecordTypeId != accountById.get(account.Id).RecordTypeId) ||
                        (account.BillingCountry != accountById.get(account.Id).BillingCountry) ||
                        (account.ShippingCountry != accountById.get(account.Id).ShippingCountry) ||
                        (account.parentId != accountById.get(account.Id).parentId) ||
                        (account.Core_Data_Country_Cd__c != accountById.get(account.Id).Core_Data_Country_Cd__c) ||
                        (account.Core_Data_Country_Nm__c != accountById.get(account.Id).Core_Data_Country_Nm__c) ||
                        (account.Core_Account_Request_Rejection_Reason__c != accountById.get(account.Id).Core_Account_Request_Rejection_Reason__c) ||
                        (account.Core_Account_Request_Rejection_Notes__c != accountById.get(account.Id).Core_Account_Request_Rejection_Notes__c) ||
                        (account.Name != accountById.get(account.Id).Name))) {
                        accountIds.add(account.Id);
                    }
                }
                if (accountIds.size() > 0) {
                    //UCD_ACM_AccountService.publishAccountChangeEvent(accountIds);
                    accountServiceInstance.updateACMIntegrationMessage(accountIds);
                }
            }
            catch (Exception ex) {
                UCD_ACM_Logger.error('Core_AccountTriggerHandlerController','triggerPlatformEventOnUpdate','Message: ' + ex.getMessage() + '. StackTrace: ' + ex.getStackTraceString() + ' UserName: ' + UserInfo.getUserName(),'AccountIds: ' + accountIds.toString());
                UCD_ACM_Logger.setLogDetails();
            }
        }
    }

    /**
     * description : call the 'updateParentOnAccountsByBpId' service class method
                    when Business Party Id or ParentId is changed and RecordType must be 'Intel Account' or 'End Customer Deal Account' and Modified by Reltio.
     * params : List<Account>,Map<Id,Account>
     * return : void
     * author and date : harshalx.sunil.gosavi@intel.com 24/05/2022.
    */
    public static void updateParentOnAccount(List<Account> newAccounts,Map<Id,Account> oldAccountById) {
        system.debug('In updateParentOnAccount--> ');
        List<Account> updatedParentAccountsInMDM = new List<Account>();
        List<Account> mergedAccountsInMDM = new List<Account>();
        Set<String> currentAccountsBpIds = new Set<String>();
        Set<Id> parentAcountIds = new Set<Id>();
        // Create a list on Accounts where Business Party Id or ParentId is changed and RecordType must be 'Intel Account' or 'End Customer Deal Account'
        // and Modified by Reltio.
        for (Account acc : newAccounts) {
            System.debug('updateParentOnAccount!!!'+acc.Core_Business_Party_Id__c + '@@@'+oldAccountById.get(acc.Id).Core_Business_Party_Id__c);
            if (acc.Core_Business_Party_Id__c != null
               && (acc.Core_Business_Party_Id__c != oldAccountById.get(acc.Id).Core_Business_Party_Id__c || acc.ParentId != oldAccountById.get(acc.Id).ParentId)
               && (acc.RecordTypeId == intelAccountRecordType || acc.RecordTypeId == endCustomerRecordType)
               /*&& acc.LastModifiedById == Label.UCD_ACM_ReltioUser*/) {
                // Merge scenario in Reltio (BPID change) 
                if (acc.Core_Business_Party_Id__c != oldAccountById.get(acc.Id).Core_Business_Party_Id__c)
                    mergedAccountsInMDM.add(acc);
                // Create a set for Parent Accounts
                if (acc.parentId != null) {
                    parentAcountIds.add(acc.parentId);
                }
                // Create a set for Account BPIds
                currentAccountsBpIds.add(acc.Core_Business_Party_Id__c);
                // Accounts for which parent is Updated
                if (acc.Core_Business_Party_Id__c == oldAccountById.get(acc.Id).Core_Business_Party_Id__c
                   && acc.ParentId != oldAccountById.get(acc.id).ParentId)
                    updatedParentAccountsInMDM.add(acc);
            }
        }
        if (updatedParentAccountsInMDM.size() > 0 || mergedAccountsInMDM.size() > 0) {
            accountServiceInstance.onUpdatedOrMergedAccountsInMDM(updatedParentAccountsInMDM,mergedAccountsInMDM,currentAccountsBpIds,parentAcountIds);
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
    /*
     * description : Conditional data sync to Reltio MDM
     * params : List<Account> newValues, List<Account> oldvalues, TriggerOperation
     * return : NA
     * author and date : chethan.s.kunder@intel.com, 12 Dec. 2021
     */
    public static void triggerReltioSync(System.TriggerOperation operation, List<Account> newAccounts, Map<Id,Account> mNewAccounts, List<Account> oldAccounts, Map<Id,Account> mOldAccounts) {
        List<Account> rNewAccounts = new List<Account>();
        List<Account> rOldAccounts = new List<Account>();
        Map<Id,Account> rMapNewAccounts = new Map<Id,Account>();
        Map<Id,Account> rMapOldAccounts = new Map<Id,Account>();
        Set<Id> loggingAccountIds = new Set<Id>();
        try {
            if (newAccounts != null && !newAccounts.isEmpty()) {
            if (operation == System.TriggerOperation.AFTER_UPDATE) {
                for (Account account : newAccounts) {
                    loggingAccountIds.add(account.Id);
                    if (account.Core_Customer_Aggregation_Type__c <> null && (account.Name <> mOldAccounts.get(account.Id).Name || account.ShippingCountry <> mOldAccounts.get(account.Id).ShippingCountry || account.Core_Customer_Aggregation_Type__c <> mOldAccounts.get(account.Id).Core_Customer_Aggregation_Type__c)) {
                        rNewAccounts.add(account);
                        rOldAccounts.add(mOldAccounts.get(account.Id));
                        rMapNewAccounts.put(account.Id, account);
                        rMapOldAccounts.put(mOldAccounts.get(account.Id).Id, mOldAccounts.get(account.Id));
                    }
                }
                if (!rNewAccounts.isEmpty()) {
                 //   rtsync.TriggerHandler.handle(operation, rNewAccounts, rMapNewAccounts, rOldAccounts, rMapOldAccounts);
                }
            } else {
                for (Account account : newAccounts) {
                    if (account.Core_Customer_Aggregation_Type__c <> null) {
                        rNewAccounts.add(account);
                        rMapNewAccounts.put(account.Id, account);
                    }
                }
                if (!rNewAccounts.isEmpty()) {
                 //   rtsync.TriggerHandler.handle(operation, rNewAccounts, rMapNewAccounts, oldAccounts, mOldAccounts);
                }
            }
        }
        }
        catch (Exception ex) {
            UCD_ACM_Logger.error('Core_AccountTriggerHandlerController','triggerReltioSync','Message: ' + ex.getMessage() + '. StackTrace: ' + ex.getStackTraceString() + ' UserName: ' + UserInfo.getUserName(),'AccountIds: ' + loggingAccountIds.toString());
            UCD_ACM_Logger.setLogDetails();
        }
    }
}