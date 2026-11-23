/**
 * Class to set sales crm attributes for account coming from Reltio MDM system
 * Author - ajayx.gat@intel.com
 * Date - 20 Feb 2023
 */
public without sharing class ACM_BU_RTForRequestedAccount implements UCD_ACM_ServiceContracts.IBeforeUpdateAccountTrigger {

    static Boolean runOnce = true;
    Id requestedRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Requested_Account').getRecordTypeId();
    Id rejectedRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Rejected_Account').getRecordTypeId();

    /**
     * Method to set record type of Requested account.
     */
    public void execute(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        // Run the logic only once and after all validations are completed
        if(runOnce && (isValid() || Test.isRunningTest())) {
            try {
                //Set sales crm attributes.
                UCD_ACM_Logger.information('ACM_BU_RTForRequestedAccount','execute','newAccounts: '+newAccounts,null);
                setSalesCRMAttributes(oldAccounts, newAccounts);
            } catch(exception ex) {
                UCD_ACM_Logger.error('ACM_BU_RTForRequestedAccount','execute',ex.getMessage() +  '==>' + ex.getStackTraceString(),null);
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
     * Method to set Sales CRM attributes.
     */
    private void setSalesCRMAttributes(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {

        Map<String, Account_Create_Process_Mapping__mdt> processBySource = UCD_ACM_Utils.getAccountProcessMappingBySourceName();
        Map<String, Id> survivorAccountIdById = getSurvivorAccountIdById(oldAccounts, newAccounts);

        for(Account account : newAccounts.values()) {
            
            setRecordType(account, oldAccounts, survivorAccountIdById, processBySource);
        } 
        UCD_ACM_Logger.information('ACM_BU_RTForRequestedAccount','setSalesCRMAttributes','updated Accounts: '+newAccounts,null);

    }

    /**
     * Method to set record type of requested account
     */
    private void setRecordType (Account account, Map<Id, Account> oldAccounts, Map<String, Id> survivorAccountIdById, Map<String, Account_Create_Process_Mapping__mdt> processBySource) {
         
        // Run the logic after all validations are completed
        if(oldAccounts.get(account.Id).Core_Business_Party_Id__c != account.Core_Business_Party_Id__c 
        && account.Core_MDM_Status__c == 'APRV'
        && oldAccounts.get(account.Id).recordTypeId == requestedRecordTypeId
        && processBySource.containsKey(account.Core_Account_Reference_Source_Name__c)) {

            if(processBySource.get(account.Core_Account_Reference_Source_Name__c).Duplicate_Rejected__c
                && survivorAccountIdById != null 
                && survivorAccountIdById.containsKey(account.Core_Business_Party_Id__c)) {
                
                account.RecordTypeId = rejectedRecordTypeId;
                account.Core_Survivor_Account_Id__c = survivorAccountIdById.get(account.Core_Business_Party_Id__c);
                account.Core_Account_Request_Rejection_Reason__c = 'DUP';
            } else {
                String recordTypeDeveloperName = processBySource.get(account.Core_Account_Reference_Source_Name__c).RecordType_Developer_Name__c;
                account.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
                
                if(processBySource.get(account.Core_Account_Reference_Source_Name__c).Duplicate_Rejected__c) {
                    survivorAccountIdById.put(account.Core_Business_Party_Id__c, account.Id);
                }
            }
        } else if(account.Core_MDM_Status__c == 'REJ' 
                && oldAccounts.get(account.Id).recordTypeId == requestedRecordTypeId) {
                account.RecordTypeId = rejectedRecordTypeId;
        }

    }

    /**
     * Method to get Parent of deal accounts based on account BP Id
     */
    private Map<String, Id> getSurvivorAccountIdById (Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {

        Set<String> bpIds = new Set<String>();
        Map<String, Id> survivorAccountIdById = new Map<String, Id>();

        for(Account account : newAccounts.values()) {
            if(oldAccounts.get(account.Id).recordTypeId == requestedRecordTypeId && !String.isBlank(account.Core_Business_Party_Id__c)) {
                bpIds.add(account.Core_Business_Party_Id__c);
            }
        }

        if(!bpIds.isEmpty()) {
            // SOQL to get deal account details based on BPID
            List<Account> dealAccounts = [
                    SELECT Id, Core_Business_Party_Id__c 
                    FROM Account 
                    WHERE 
                        Core_Business_Party_Id__c IN: bpIds 
                        AND RecordType.DeveloperName = 'End_Customer_Deal_Account' 
                    ORDER BY CreatedDate
                ];
            
            // Adding data into collection - deal account Id by BP ID
            if(!dealAccounts.isEmpty()) {
                for(Account account : dealAccounts) {
                    if(!survivorAccountIdById.containsKey(account.Core_Business_Party_Id__c)) {
                        survivorAccountIdById.put(account.Core_Business_Party_Id__c, account.Id);
                    }
                }
            }
        }
        UCD_ACM_Logger.information('ACM_BU_RTForRequestedAccount','getSurvivorAccountIdById','getSurvivorAccountIdById: '+survivorAccountIdById,null);

        return survivorAccountIdById;
    }
}