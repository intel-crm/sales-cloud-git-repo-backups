public without sharing class UCD_ACM_AccountDomain implements UCD_ACM_DomainContracts.IAccountDomain {
    private static UCD_ACM_Models.BusinessOrganizationResponseforService modelResponse = new UCD_ACM_Models.BusinessOrganizationResponseforService();
    private static UCD_ACM_SelectorContracts.IAccountQuerySelector accountQuerySelectorInstance = UCD_ACM_AccountQuerySelector.getInstance();
    private static UCD_ACM_Models.AccountResponseModel model = new UCD_ACM_Models.AccountResponseModel();
    private static UCD_ACM_DomainContracts.IAccountDomain instance = null;
    private UCD_ACM_AccountDomain() {}

    public static Id intelAccountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    public static Id endCustomerRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('End Customer Deal Account').getRecordTypeId();
    public static Id requestedAccountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Requested Account').getRecordTypeId();
    public static Id rejectedAcountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Rejected Account').getRecordTypeId();

    public static UCD_ACM_DomainContracts.IAccountDomain getInstance() {
        if (instance  == null) {
            instance  = new UCD_ACM_AccountDomain();
        }
        return instance;
    }

    /*
     * description : Validate CustomerAggregation Type Code
     * params : List<UCD_ACM_Models.AccountModel> validAccountRequests,  List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse
     * return : N/A
     * author and date : ankit1x.sharma@intel.com, 06 Dec 2021
     */
    public static void ValidateCustomerAggregationType(List<UCD_ACM_Models.AccountModel> validAccountRequests,  List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse) {
        Schema.DescribeFieldResult fieldResult = Account.Core_Customer_Aggregation_Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

        for (Integer index = 0; index < validAccountRequests.size(); index++) {
            validAccountRequests[index].recordTypeId = requestedAccountRecordType;
            Boolean validCustomerAggregationType = false;
            for (Schema.PicklistEntry pickListVal : picklistValues) {
                if (pickListVal.getValue() == validAccountRequests[index].CustomerAggregationTypeCode) {
                    validCustomerAggregationType = true;
                    break;
                }
            }
            if (!validCustomerAggregationType) {
                invalidResponse.add( modelResponse.mapAccountsToAccountResponseModel (new Account (name = validAccountRequests[index].Name), '', validAccountRequests[index].Addresses.size() > 0 ? validAccountRequests[index].Addresses[0].CountryName : null,'CustomerAggregationTypeCode is not valid','',validAccountRequests[index].DuplicateAccountInfo) );
                validAccountRequests.remove(index);
                index--;
            }
        }
    }


    /*
     * description : Validate Account Request Reference
     * params : List<UCD_ACM_Models.AccountModel> validAccountRequests,  List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse
     * return : N/A
     * author and date : ankit1x.sharma@intel.com, 18 June 2022
     */
    public static void ValidateAccountRequestReference(List<UCD_ACM_Models.AccountModel> validAccountRequests,  List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse) {
        Schema.DescribeFieldResult fieldResult = Account.Core_Account_Reference_Source_Name__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

        for (Integer index = 0; index < validAccountRequests.size(); index++) {
            if( validAccountRequests[index].AccountRequestReferences !=null){
                Boolean isCorrectValueContains = false;
                for (Schema.PicklistEntry pickListVal : picklistValues) {
                    if (  validAccountRequests[index].AccountRequestReferences.containsKey(pickListVal.getValue())  ) {
                            isCorrectValueContains = true;
                            break;
                    }
                }

                if (!isCorrectValueContains) {
                    validAccountRequests[index].AccountRequestReferences  = null ;
                }
                
            }
        }
    }

    /*
     * description : Validate Customer Process Engagement
     * params : List<UCD_ACM_Models.AccountModel> validAccountRequests,  List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse
     * return : N/A
     * author and date : ankit1x.sharma@intel.com, 06 Dec 2021
     */
    public static void ValidateCustomerProcessEngagement(List<UCD_ACM_Models.AccountModel> validAccountRequests,  List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse) {
        Set<String> CustomerProcessEngagmentCodes = new Set<String>();
        for (UCD_ACM_Models.AccountModel accountModel : validAccountRequests) {
            CustomerProcessEngagmentCodes.add(accountModel.CustomerProcessEngagmentCode);
        }
        Map<String,Business_Types__c> businessTypeById = accountQuerySelectorInstance.getBusinessTypeId(CustomerProcessEngagmentCodes);
        for (Integer index = 0; index < validAccountRequests.size(); index++) {
            if (businessTypeById == null || businessTypeById.get(validAccountRequests[index].CustomerProcessEngagmentCode) == null) {
                invalidResponse.add( modelResponse.mapAccountsToAccountResponseModel (new Account (name = validAccountRequests[index].Name), '', validAccountRequests[index].Addresses.size() > 0 ? validAccountRequests[index].Addresses[0].CountryName : null,'CustomerProcessEngagement is not valid','',validAccountRequests[index].DuplicateAccountInfo) );
                validAccountRequests.remove(index);
                index--;
            }
        }
    }

    /*
     * description : Validate Duplicate Account in SF
     * params : List<UCD_ACM_Models.AccountModel> validAccountRequests, List<Account> nameBasedAccounts, List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse
     * return : N/A
     * author and date : ankit1x.sharma@intel.com, 06 Dec 2021
     */
    public static void validateDuplicateAccountRequests(List<UCD_ACM_Models.AccountModel> validAccountRequests, List<Account> nameBasedAccounts, List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse ) {
        List<Account> invalidAccounts = new List<Account>();
        // Compare request parameters with account parameters
        for (Integer index = 0; index < validAccountRequests.size(); index++) {
            String countryCode =  validAccountRequests[index].Addresses.size() > 0 ? (String.isNotBlank(validAccountRequests[index].Addresses[0].countryCode) ? validAccountRequests[index].Addresses[0].countryCode : UCD_ACM_Utils.validateCountryName(validAccountRequests[index].Addresses[0].countryname) ) : '';
            String countryName =  validAccountRequests[index].Addresses.size() > 0 ? (String.isNotBlank(validAccountRequests[index].Addresses[0].countryName) ? validAccountRequests[index].Addresses[0].countryName : UCD_ACM_Utils.validateCountryCode(validAccountRequests[index].Addresses[0].countryCode) ) : '';
            for (Account accountRecord : nameBasedAccounts) {
                if (validAccountRequests.size() > 0) {
                    if ( (accountRecord.Name == validAccountRequests[index].name &&   accountRecord.ShippingCountryCode == countryCode  && accountRecord.Core_Customer_Aggregation_Type__c == validAccountRequests[index].CustomerAggregationTypeCode) ||
                         ( accountRecord.Core_Data_Simplified_Account_Nm__c == validAccountRequests[index].name && accountRecord.Core_Data_Country_Nm__c == countryName && accountRecord.Core_Customer_Aggregation_Type__c == validAccountRequests[index].CustomerAggregationTypeCode) ) {
                        invalidAccounts.add(accountRecord);
                        validAccountRequests.remove(index);
                        index--;
                        break;
                    }
                }
            }
        }
        if (invalidAccounts.size() > 0) {
            Map<Id,UCD_ACM_Models.AccountResponseModel>  duplicateInfoByAccountId =  getAccountDetailsForDuplicate(invalidAccounts);
            for (UCD_ACM_Models.AccountResponseModel DuplicateAccountInfo : duplicateInfoByAccountId.values()) {
                invalidResponse.add( modelResponse.mapAccountsToAccountResponseModel (new Account (name = DuplicateAccountInfo.AccountName), '', DuplicateAccountInfo.PrimaryAddress != null ? DuplicateAccountInfo.PrimaryAddress.CountryName : null,'Duplicate Account','',DuplicateAccountInfo) );
            }
        }
    }

    /*
     * description : getting Duplicate Account Info details
     * params : List<Account> accounts
     * return : N/A
     * author and date : ankit1x.sharma@intel.com, 06 Dec 2021
     */
    public static Map<Id,UCD_ACM_Models.AccountResponseModel> getAccountDetailsForDuplicate(List<Account> accounts) {
        Map<Id,UCD_ACM_Models.AccountResponseModel> duplicateInfoByAccountId = new Map<Id,UCD_ACM_Models.AccountResponseModel>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> parentAccountIds = new Set<Id>();
        for (Account acct : accounts) {
            accountIds.add(acct.Id);
            parentAccountIds.add(acct.ParentId);
        }
        Map<Id, Account> parentAccountById = accountQuerySelectorInstance.getAccountsByIds(parentAccountIds, model.getParentAccountQueryForEvent());
        Map<Id,List<Business_Types__c> > businessTypesByAccountId = accountQuerySelectorInstance.getBusinessTypesByAccountId(accountIds, model.getAccountBusinessTypesQueryForEvent());
        for (Account account : accounts) {
            duplicateInfoByAccountId.put(account.Id, mapAccountResponseModel(account,parentAccountById,businessTypesByAccountId));
        }
        return duplicateInfoByAccountId;
    }

    /*
     * description : Map account Data to AccountResponseModel from UCD_ACM_Models to publish platform event and duplicate accounts.
     * params : Account,Map<Id, Account>,Map<Id,List<Business_Types__c>>
     * return : UCD_ACM_Models.AccountResponseModel
     * author and date : harshalx.sunil.gosavi@intel.com, 23 Nov 2021
     */
    public static UCD_ACM_Models.AccountResponseModel mapAccountResponseModel(Account account,Map<Id, Account> parentAccountById,Map<Id,List<Business_Types__c> > businessTypesByAccountId) {
        UCD_ACM_Models.AccountResponseModel model = new UCD_ACM_Models.AccountResponseModel();
        UCD_ACM_Models.AccountResponseModel mappedResponse = new UCD_ACM_Models.AccountResponseModel();
        try {
            //map Account response to the model classes
            mappedResponse = model.mapAccountsToAccountResponseModel(account, parentAccountById);
            //map CustomerProcessEngagement to the model classes
            if (businessTypesByAccountId != null && businessTypesByAccountId.containsKey(account.Id))
                mappedResponse = model.mapBusinessTypesToModel(mappedResponse,businessTypesByAccountId.get(account.Id));   
        }
        catch (exception ex) {
            //System.debug('error in domain@@@%%%'+ex.getStackTraceString());
            UCD_ACM_Logger.error('UCD_ACM_AccountDomain','mapAccountResponseModel','Message: ' + ex.getMessage() + '. StackTrace: ' + ex.getStackTraceString(),'AccountIds: ' + account.Id);
        }
        finally{
            UCD_ACM_Logger.setLogDetails();
        }
        return mappedResponse;
    }
    
    /*
     * description : Map account- req Data to AccountRequestQueueModel from UCD_ACM_Models to publish platform event.
     * params : Account_Create_Request__c, Map<Id, Account>,Map<Id, Account>, Map<Id, List<Business_Types__c>>
     * return : UCD_ACM_Models.AccountRequestQueueModel
     * author and date : Tejasri, 13 Nov 2023
     */
    public static UCD_ACM_Models.AccountRequestQueueModel mapAccountRequestQueueResponseModel(Account_Create_Request__c acrRecord, Account account, Map<Id, Account> parentAccountById, Map<Id,List<Business_Types__c> > businessTypesByAccountId) {
        UCD_ACM_Models.AccountResponseModel model = new UCD_ACM_Models.AccountResponseModel();
        UCD_ACM_Models.AccountResponseModel mappedResponse = new UCD_ACM_Models.AccountResponseModel();
        UCD_ACM_Models.AccountRequestQueueModel finalResponse = new UCD_ACM_Models.AccountRequestQueueModel();

        try {
            if (acrRecord != null) {
                finalResponse.RequestId = acrRecord.Id;
                finalResponse.Status = acrRecord.Status__c;
                finalResponse.AccountId = acrRecord.Requested_Account__c;
                finalResponse.RejectionReason = acrRecord.Rejected_Reason__c;
                finalResponse.AccountReferenceSourceName = acrRecord.Core_Account_Reference_Source_Name__c;
            }

            if (account != null) {
                //map Account response to the model classes
                mappedResponse = model.mapAccountsToAccountResponseModel(account, parentAccountById);

                //map Compliance Watch List to the model classes
                if (businessTypesByAccountId != null && businessTypesByAccountId.containsKey(account.Id)) {
                    model.mapBusinessTypesToModel(mappedResponse, businessTypesByAccountId.get(account.Id));
                }
            }

            finalResponse.Account = mappedResponse;
                        
        } catch (exception ex) {
            UCD_ACM_Logger.error('UCD_ACM_AccountDomain','mapAccountRequestQueueResponseModel','Message: ' + ex.getMessage() + '. StackTrace: ' + ex.getStackTraceString(),'Account Request Queue Id: ' + acrRecord.Id);
        } finally{
            UCD_ACM_Logger.setLogDetails();
        }

        return finalResponse;
    }



    /*
     * description : Sync parent and child accounts with Reltio data on account merge and parent change
     * params : UCD_ACM_UnitOfWork unitwork, List<Account> updatedParentAccountsInMDM, List<Account> mergedAccountsInMDM,
     *          Map<Id,Account> parentAccountById, Map<String,List<Account> > parentAccountsByBpId,
     *          Map<String,List<Account> > accountsByBpId
     * return : NA
     * author and date : yashvir.pathak@intel.com - 5 June, 2022
     */
    public void setParentOnUpdateOrMergeInMDM(UCD_ACM_UnitOfWork unitwork, List<Account> updatedParentAccountsInMDM, List<Account> mergedAccountsInMDM, Map<Id,Account> parentAccountById, Map<String,List<Account>> parentAccountsByBpId, Map<String,List<Account> > accountsByBpId) {
        String message = 'Enter method. updatedParentAccountsInMDM - ' + updatedParentAccountsInMDM + '' + '. mergedAccountsInMDM - ' + mergedAccountsInMDM + '' + '. parentAccountById - ' + parentAccountById + '' + '. parentAccountsByBpId - ' + parentAccountsByBpId + '' + '. accountsByBpId - ' + accountsByBpId + '';
        UCD_ACM_Logger.information('UCD_ACM_AccountDomain','setParentOnUpdateOrMergeInMDM',message,NULL);
        if (updatedParentAccountsInMDM.size() > 0) {
            UCD_ACM_Logger.information('UCD_ACM_AccountDomain','setParentOnUpdateOrMergeInMDM','Account Parent change scenario',NULL);
            setAccountParent(unitwork,updatedParentAccountsInMDM, parentAccountById,parentAccountsByBpId);
            setAccountSiblingParent( unitwork, updatedParentAccountsInMDM, accountsByBpId, parentAccountById);
        }
        // Sync child and parent accounts in account merge scenario
        if (mergedAccountsInMDM.size() > 0) {
            UCD_ACM_Logger.information('UCD_ACM_AccountDomain','setParentOnUpdateOrMergeInMDM','Account merge scenario',NULL);
            setAccountParentFromSibling(unitwork, mergedAccountsInMDM, accountsByBpId, parentAccountById);
            setCurrentAccountChildParent(unitwork, mergedAccountsInMDM, accountsByBpId);
        }
    }

    /*
     * description : For parent change, if parent and parent sibling record type is different than current account record type,
     *              then, set current parent to null otherwise, set Parent To Matched ParentSibling
     * params : UCD_ACM_UnitOfWork unitwork, List<Account> updatedParentAccountsInMDM
     *          Map<Id,Account> parentAccountById, Map<String,List<Account>> parentAccountsByBpId
     * return : NA
     * author and date : yashvir.pathak@intel.com - 5 June, 2022
     */
    private void setAccountParent(UCD_ACM_UnitOfWork unitwork, List<Account> updatedParentAccountsInMDM, Map<Id,Account> parentAccountById, Map<String,List<Account> > parentAccountsByBpId) {
        UCD_ACM_Logger.information('UCD_ACM_AccountDomain','setAccountParent', 'Enter method',NULL);
        For(Account account: updatedParentAccountsInMDM) {
            if (account.ParentId != null) {
                Boolean assignNull = true;
                Account currentAccountToUpdate  = new Account(Id = account.Id);
                Account parentAccount = parentAccountById.get(account.ParentId);
                // If same record type, continue to next record
                if (account.RecordTypeId == parentAccount.RecordTypeId) {
                    continue;
                }
                //Adding by Ankit  If parent Account has not BP Id.
                if(parentAccountsByBpId.get(parentAccount.Core_Business_Party_Id__c) == null){
                    UCD_ACM_Logger.information('UCD_ACM_AccountDomain','setAccountParent', 'Parent Account does not have BP Id'+ parentAccount.Id ,NULL);
                    continue;
                }
                // Check for Recordtype of current account and parent account
                if (account.RecordTypeId != parentAccount.RecordTypeId) {
                    // set Parent To Matched ParentSibling
                    for (Account parentSibling : parentAccountsByBpId.get(parentAccount.Core_Business_Party_Id__c)) {
                        if (account.RecordTypeId == parentSibling.RecordTypeId) {
                            currentAccountToUpdate.parentId = parentSibling.Id;
                            unitwork.registerModified(currentAccountToUpdate);
                            UCD_ACM_Logger.information('UCD_ACM_AccountDomain','setAccountParent',currentAccountToUpdate.Id + ' parent is assigned with -' + currentAccountToUpdate.ParentId,currentAccountToUpdate.Id);
                            assignNull = false;
                            break;
                        }
                    }
                }
                // if parent and parent sibling record type is different than current account record type,
                // then, set current parent to null
                if (assignNull) {
                    currentAccountToUpdate.ParentId = null;
                    UCD_ACM_Logger.information('UCD_ACM_AccountDomain','setAccountParent', currentAccountToUpdate.Id + ' parent is assigned null',currentAccountToUpdate.Id);
                    unitwork.registerModified(currentAccountToUpdate);
                }
            }
        }
    }

    /*
     * description : For parent change, set account's sibling parent. 
     * Fetch siblings of the current account. Check sibling RT with current account parent RT. If matches, update the parent.
     * params : UCD_ACM_UnitOfWork unitwork, List<Account> updatedParentAccountsInMDM
     *          Map<Id,Account> parentAccountById, Map<String,List<Account>> parentAccountsByBpId
     * return : NA
     * author and date : yashvir.pathak@intel.com - 5 June, 2022
     */
    private void setAccountSiblingParent(UCD_ACM_UnitOfWork unitwork, List<Account> updatedParentAccountsInMDM, Map<String,List<Account> > accountsByBpId, Map<Id,Account> parentAccountById) {
        UCD_ACM_Logger.information('UCD_ACM_AccountDomain','setAccountSiblingParent','Enter method',NULL);
        for (Account currentAccount : updatedParentAccountsInMDM) {
            if (currentAccount.ParentId != null && accountsByBpId != null && accountsByBpId.size() > 0
               && accountsByBpId.containsKey(currentAccount.Core_Business_Party_Id__c)
               && parentAccountById.containsKey(currentAccount.ParentId)) {
                Account currentAccountParent = parentAccountById.get(currentAccount.ParentId);
                // set Account Sibling Parent
                For(Account siblingAccount: accountsByBpId.get(currentAccount.Core_Business_Party_Id__c)) {
                    if (siblingAccount.Id != currentAccount.Id && siblingAccount.ParentId != currentAccountParent.Id && siblingAccount.RecordTypeId == currentAccountParent.RecordTypeId) {
                        Account siblingAccountToUpdate  = new Account(Id = siblingAccount.Id);
                        siblingAccountToUpdate.ParentId = currentAccountParent.Id;
                        UCD_ACM_Logger.information('UCD_ACM_AccountDomain','setAccountSiblingParent',siblingAccountToUpdate.Id + ' parent is assigned with -' + siblingAccountToUpdate.ParentId,siblingAccountToUpdate.Id);
                        unitwork.registerModified(siblingAccountToUpdate);
                    }
                }
            }
        }
    }

    /**
     * This method prepared data collections for child accounts and current accounts
     * and call setAccountParentInMerge to assign parent to child accounts
     * params : UCD_ACM_UnitOfWork unitwork, List<Account> mergedAccounts,Map<String,List<Account> > accountsByBpId
     * return : NA
     * author and date : yashvir.pathak@intel.com - 14 June, 2022
     */
    private void setCurrentAccountChildParent(UCD_ACM_UnitOfWork unitwork,List<Account> mergedAccounts,Map<String,List<Account> > accountsByBpId) {
        Set<Id> siblingAccountsId = new Set<Id>();
        Set<String> childAccountsBpId = new Set<String>();
        List<Account> allChildAccounts = new List<Account>();
        Map<Id, Account> accountById = new Map<Id, Account>();
        Map<String,List<Account> > childAccountsByBpId = new Map<String,List<Account> >();
        // Get all child account Ids of merge accounts
        for (Account currentAccount : mergedAccounts) {
            if (accountsByBpId != null && accountsByBpId.containsKey(currentAccount.Core_Business_Party_Id__c)) {
                For(Account chkAccount: accountsByBpId.get(currentAccount.Core_Business_Party_Id__c)) {
                    siblingAccountsId.add(chkAccount.Id);
                }
            }
        }
        if (siblingAccountsId.size() > 0) {
            // Get the all children of sibling accounts of current account.
            String andClause = 'Core_Customer_Aggregation_Type__c != null and (RecordType.Name = \'End Customer Deal Account\' OR RecordType.Name = \'Intel Account\')';
            Map<Id, Account> childAccountById = accountQuerySelectorInstance.getAccountsByParentId(siblingAccountsId, 'Id,Name,RecordTypeId,Core_Business_Party_Id__c,ParentId', andClause);
            if (childAccountById != null && childAccountById.size() > 0) {
                // Get the Siblings of child accounts
                for (Account childAccount : childAccountById.values()) {
                    if (!String.isBlank(childAccount.Core_Business_Party_Id__c)) {
                        childAccountsBpId.add(childAccount.Core_Business_Party_Id__c);
                    }
                }
                if (childAccountsBpId != null && childAccountsBpId.size() > 0) {
                    childAccountsByBpId = accountQuerySelectorInstance.getAccountByBpId(childAccountsBpId);
                }
                // Listing all child accounts based on BP ID. Children without parent are selected.
                // No need to do any change to the child accounts with parent
                if (childAccountsByBpId != null && childAccountsByBpId.size() > 0) {
                    for (List<Account> childAcctColl : childAccountsByBpId.values()) {
                        for (Account childAcct: childAcctColl) {
                            // Child account without parent are selected
                            if (childAcct.ParentId == null) {
                                allChildAccounts.add(childAcct);
                            }
                        }
                    }
                }
                // Listing all current accounts based on BP ID
                if (accountsByBpId != null && accountsByBpId.size() > 0) {
                    List<Account> allAccounts = new List<Account>();
                    for (List<Account> acctColl : accountsByBpId.values()) {
                        allAccounts.addAll(acctColl);
                    }
                    accountById = new Map<Id,Account>(allAccounts);
                }
                // Logging collection data
                string message = 'allChildAccounts - ' + allChildAccounts.toString() + '. childAccountsByBpId - ' + childAccountsByBpId.toString() + '. accountById - ' + accountById.toString() + '. accountsByBpId' + accountsByBpId.toString();
                UCD_ACM_Logger.information('UCD_ACM_AccountDomain','setCurrentAccountChildParent',message,NULL);
                // Calling method to set parent
                setAccountParentInMerge(unitwork, allChildAccounts, childAccountsByBpId, accountById, accountsByBpId);
            }
        }
    }

    /**
     * This method prepared data collections for current accounts and parent accounts
     * and call setAccountParentInMerge to assign parent to current accounts
     * params : UCD_ACM_UnitOfWork unitwork, List<Account> mergedAccounts,Map<String,List<Account> > accountsByBpId, Map<Id,Account> parentAccountById
     * return : NA
     * author and date : yashvir.pathak@intel.com - 14 June, 2022
     */
    private void setAccountParentFromSibling(UCD_ACM_UnitOfWork unitwork,List<Account> mergedAccounts,Map<String,List<Account> > accountsByBpId, Map<Id,Account> parentAccountById) {
        Set<Id> siblingParentAccountIds = new Set<Id>();
        Map<Id,Account> siblingParentsById = new Map<Id,Account>();
        Map<String,List<Account> > siblingParentAccountsByBpId = new Map<String,List<Account> >();
        // Get the parent ids of the current accounts
        for (Account currAcct: mergedAccounts) {
            for (Account siblingAcct :accountsByBpId.get(currAcct.Core_Business_Party_Id__c)) {
                if (siblingAcct.ParentId != null && !parentAccountById.containsKey(siblingAcct.ParentId)) {
                    siblingParentAccountIds.add(siblingAcct.ParentId);
                }
            }
        }
        // get parent details and create 2 collections - siblingParentsById and siblingParentAccountsByBpId
        if (siblingParentAccountIds != null && siblingParentAccountIds.size() > 0) {
            // get sibling parent details
            siblingParentsById = accountQuerySelectorInstance.getAccountsByIds(siblingParentAccountIds,'Id,Name,RecordTypeId,Core_Business_Party_Id__c');
            Set<String> siblingParentAccountsBpIds = new Set<String>();
            for (Account siblingAcct : siblingParentsById.values()) {
                if (!String.isBlank(siblingAcct.Core_Business_Party_Id__c)) {
                    siblingParentAccountsBpIds.add(siblingAcct.Core_Business_Party_Id__c);
                }
            }
            // Arranging sibling parents by BPID
            if (siblingParentAccountsBpIds != null && siblingParentAccountsBpIds.size() > 0) {
                siblingParentAccountsByBpId = accountQuerySelectorInstance.getAccountByBpId(siblingParentAccountsBpIds);
            }
        }
        string message = 'MergeAccounts - ' + mergedAccounts.toString() + '. accountsByBpId - ' + accountsByBpId.toString() + '. siblingParentsById - ' + siblingParentsById.toString() + '. siblingParentAccountsByBpId' + siblingParentAccountsByBpId.toString();
        UCD_ACM_Logger.information('UCD_ACM_AccountDomain','setAccountParentFromSibling', message, NULL);
        // Calling method to set parent
        setAccountParentInMerge(unitwork,mergedAccounts, accountsByBpId, siblingParentsById, siblingParentAccountsByBpId);
    }

    /**
     * This method set parent of accounts in merge scenario. It works for both current accounts and child accounts depending on the input variables
     * params : UCD_ACM_UnitOfWork unitwork, List<Account> mergedAccounts,Map<String,List<Account> > accountsByBpId, 
     *          Map<Id,Account> siblingParentsById, Map<String,List<Account> > siblingParentAccountsByBpId
     * return : NA
     * author and date : yashvir.pathak@intel.com - 14 June, 2022
     */
    private void setAccountParentInMerge(UCD_ACM_UnitOfWork unitwork,List<Account> mergedAccounts,Map<String,List<Account> > accountsByBpId, Map<Id,Account> siblingParentsById, Map<String,List<Account> > siblingParentAccountsByBpId) {
        UCD_ACM_Logger.information('UCD_ACM_AccountDomain','setAccountParentInMerge','Enter method',NULL);
        List<Account> accountsWithoutParent = new List<Account>();
        // Setting parent to the non-survivor account. If survivor RT is same as non-survivor RT, assign survivor parent to non-survivor
        for (Account currentAccount : mergedAccounts) {
            Boolean parentAssigned = false;
            Account currentAccountToUpdate  = new Account(Id = currentAccount.Id);
            List<Account> siblingAccounts = accountsByBpId.get(currentAccount.Core_Business_Party_Id__c);
            for (Account siblingacct: siblingAccounts) {
                //If survivor RT is same as non-survivor RT, assign survivor parent to non-survivor
                if (siblingacct.Id != currentAccount.Id && siblingacct.ParentId != null && siblingacct.RecordTypeId == currentAccount.RecordTypeId) {
                    currentAccountToUpdate.ParentId = siblingacct.ParentId;
                    unitwork.registerModified(currentAccountToUpdate);
                    parentAssigned = true;
                    UCD_ACM_Logger.information('UCD_ACM_AccountDomain','setAccountParentInMerge',currentAccountToUpdate.Id + ' parent is assigned with -' + currentAccountToUpdate.ParentId,currentAccountToUpdate.Id);
                    break;
                }
            }
            // If survivor RT is different than non-survivor RT, add into the collection
            if (!parentAssigned) {
                accountsWithoutParent.add(currentAccount);
            }
        }
        // For non-survivor accounts with different RT, get survivor's parent siblings and compare their RT with non-survivor RT
        // If any match is found, assign the parent to non-survivor else assign null.
        if (accountsWithoutParent.size() > 0) {
            for (Account currentAccount : accountsWithoutParent) {
                Boolean siblingParentAssigned = false;
                Account currentAccountToUpdate  = new Account(Id = currentAccount.Id);
                for (Account siblingacct: accountsByBpId.get(currentAccount.Core_Business_Party_Id__c)) {
                    if (currentAccount.Id != siblingacct.Id && siblingacct.ParentId != null && siblingacct.RecordTypeId != currentAccount.RecordTypeId) {
                        Account siblingParentAccount = siblingParentsById.get(siblingacct.ParentId);
                        for (Account acct : siblingParentAccountsByBpId.get(siblingParentAccount.Core_Business_Party_Id__c)) {
                            if (acct.RecordTypeId == currentAccount.RecordTypeId) {
                                currentAccountToUpdate.ParentId = acct.Id;
                                unitwork.registerModified(currentAccountToUpdate);
                                siblingParentAssigned = true;
                                UCD_ACM_Logger.information('UCD_ACM_AccountDomain','setAccountParentInMerge',currentAccountToUpdate.Id + ' parent is assigned with -' + currentAccountToUpdate.ParentId,currentAccountToUpdate.Id);
                                break;
                            }
                        }
                    }
                    if (siblingParentAssigned)
                        break;
                }
                // If non-survivor RT does not match any parent's sibling, assign parent as null
                if (!siblingParentAssigned) {
                    currentAccountToUpdate.ParentId = null;
                    UCD_ACM_Logger.information('UCD_ACM_AccountDomain','setAccountParentInMerge',currentAccountToUpdate.Id + ' parent is assigned with -null',currentAccountToUpdate.Id);
                    unitwork.registerModified(currentAccountToUpdate);
                }
            }
        }
    }

    
}