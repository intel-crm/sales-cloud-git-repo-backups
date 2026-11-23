/**
 * Class to handle scenario when rejected account is approved in Reltio
 */
public without sharing class ACM_BU_RTForRejectedAccount implements UCD_ACM_ServiceContracts.IBeforeUpdateAccountTrigger {
    static Boolean runOnce = true;
    Id rejectedRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Rejected_Account').getRecordTypeId();
    Id endCustomerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_Customer_Deal_Account').getRecordTypeId();
    Map<Id, Account> rejectedAccounts = new Map<Id, Account>();

    /**
     * Method to execute the logic
     */
    public void execute(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        if (runOnce && (isValid() || Test.isRunningTest())) {
            try {
                // get rejected accounts
                setRejectedCollection(oldAccounts,newAccounts);
                UCD_ACM_Logger.information('ACM_BU_RTForRejectedAccount','execute','New Accounts: '+newAccounts,null);
                if (!rejectedAccounts.isEmpty()) {
                    // set record type of rejected accounts
                    setRejectedToApprovedAttributes();
                }
            } catch (Exception ex) {
                UCD_ACM_Logger.error('ACM_BU_RTForRejectedAccount','execute',ex.getMessage() +  '==>' + ex.getStackTraceString(),rejectedAccounts.keySet().toString());
            } finally {
                UCD_ACM_Logger.setLogDetails();
            }
        }
        runOnce = false;
    }

    /**
     * Method to add validations
     */
    private Boolean isValid() {
        return userInfo.getUserId() == Label.UCD_ACM_ReltioUser;
    }

    /**
     * Method to set Rejected account collection when status is changed to Approved in reltio
     */
    private void setRejectedCollection(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        for (Account account : newAccounts.values()) {
            if (oldAccounts.get(account.Id).recordTypeId == rejectedRecordTypeId && account.Core_MDM_Status__c == 'APRV' && 
            String.isEmpty(account.Core_Survivor_Account_Id__c)) {
                rejectedAccounts.put(account.Id, account);
                
            }
        }
    }

    /**
     * Method to set correct record type and name for rejected accounts when status is updated to approved in reltio
     */
    private void setRejectedToApprovedAttributes() {
        // Get Custom metadata - Account Create Process Mapping
        Map<String, Account_Create_Process_Mapping__mdt> processMappingBySourceName = UCD_ACM_Utils.getAccountProcessMappingBySourceName();
        // Get survivor account details
        Map<String, Id> survivorAccountIdById = getSurvivorAccountIdById();
        // Set record type for each rejected account
        for (Account account : rejectedAccounts.values()) {
            if (!String.isEmpty(account.Core_Account_Reference_Source_Name__c) && processMappingBySourceName.containsKey(account.Core_Account_Reference_Source_Name__c)) {
                // get record type based on source
                String recordTypeDeveloperName = processMappingBySourceName.get(account.Core_Account_Reference_Source_Name__c).RecordType_Developer_Name__c;

                // If duplicate rejected flag is true- in custom metadata, survivor account logic kicks in
                if (processMappingBySourceName.get(account.Core_Account_Reference_Source_Name__c).Duplicate_Rejected__c) {
                    // 1. If survivor exists, no change
                    // 2. If survivor is null, check duplicate. If duplicate is there, no change in record type but set survivor for the account
                    // 3. If survivor is null, check duplicate. If duplicate is not there, change record type to ECD
                    if (!survivorAccountIdById.isEmpty() 
                        && survivorAccountIdById.containsKey(account.Core_Business_Party_Id__c)) {
                            account.Core_Survivor_Account_Id__c = survivorAccountIdById.get(account.Core_Business_Party_Id__c);
                    }else{
                        account.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
                    }
                }else{
                    account.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
                }
            }
        }
        UCD_ACM_Logger.information('ACM_BU_RTForRejectedAccount','setRejectedToApprovedAttributes','Rejected Accounts: '+rejectedAccounts,null);
    }

    /**
     * Method to get ECD survivor account based on BP Id
     */
    private Map<String, Id> getSurvivorAccountIdById() {
        Set<string> bpIds = new Set<String>();
        Map<String, Id> survivorAccountIdByBPId = new Map<String, Id>();

        // get BP Ids of rejected account
        for (Account account : rejectedAccounts.values()) {
            if (!String.isEmpty(account.Core_Business_Party_Id__c)) {
                bpIds.add(account.Core_Business_Party_Id__c);
            }
        }
        List<Account> dealSurvivorAccounts;
        if(!bpIds.isEmpty()) {
            // SOQL to get deal survivor account details based on BPID
            if (Schema.sObjectType.Account.fields.Core_Business_Party_Id__c.isAccessible()){
                dealSurvivorAccounts= [
                SELECT Id, Core_Business_Party_Id__c
                FROM Account
                WHERE
                    Core_Business_Party_Id__c IN :bpIds
                    AND RecordTypeId =: endCustomerRecordTypeId
                ORDER BY CreatedDate
            ];
            }
            // add survivor into the collection - survivorAccountIdByBPId
            if (!dealSurvivorAccounts.isEmpty()) {
                for (Account account : dealSurvivorAccounts) {
                    if (!survivorAccountIdByBPId.containsKey(account.Core_Business_Party_Id__c)) {
                        survivorAccountIdByBPId.put(account.Core_Business_Party_Id__c, account.Id);
                    }
                }
            }
        }
        UCD_ACM_Logger.information('ACM_BU_RTForRejectedAccount','getSurvivorAccountIdById','survivorAccountIdByBPId: '+survivorAccountIdByBPId, null);

        return survivorAccountIdByBPId;
    }
}