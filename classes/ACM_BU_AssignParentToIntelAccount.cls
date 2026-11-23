/**
 * Class to assign parent to Intel account coming from Reltio MDM system when parent is either null or it is updated
 * Author - Yashvir.pathak@intel.com
 * Date - 21 Feb 2023
 */ 
public without sharing class ACM_BU_AssignParentToIntelAccount implements UCD_ACM_ServiceContracts.IBeforeUpdateAccountTrigger {
    static boolean runOnce = true;
    Id intelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();

    /**
     * Method to set parent to Intel accounts when parent is either null or it is updated
     */
    public void execute( Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        try {
        // Run the logic only once and after all validations are completed 
        if ((runOnce && isValid()) || Test.isRunningTest()) {
            //get Intel accounts
            Set<Account> intelAccounts = getIntelAccounts(oldAccounts, newAccounts);
            UCD_ACM_Logger.information('ACM_BU_AssignParentToIntelAccount','execute','Intel Accounts: ' + intelAccounts ,null);
            if(!intelAccounts.isEmpty()){
                // get Parent of Intel accounts based on parent BP Id
                Map<String, Account> parentAccountByBpId = getParentAccountByBpId(intelAccounts);
                UCD_ACM_Logger.information('ACM_BU_AssignParentToIntelAccount','execute','Parent account: ' + parentAccountByBpId ,null);
                // Set parent to Intel accounts
                setParentToIntelAccount( intelAccounts, parentAccountByBpId);
            }
            
        }
        runOnce = false;
        } catch (Exception ex) {
            UCD_ACM_Logger.error('ACM_BU_AssignParentToIntelAccount','execute',ex.getMessage() +  '==>' + ex.getStackTraceString(),null);
        }
    }

    /**
     * Method to add validations
     */
    private Boolean isValid() {
        return userInfo.getUserId() == Label.UCD_ACM_ReltioUser;
    }

    /**
     *  Method to filter intel accounts from new accounts collection
     */
    private Set<Account> getIntelAccounts(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        Set<Account> intelAccounts = new Set<Account>();
        for (Account account : newAccounts.values()) {
            if (account.RecordTypeId == intelRecordTypeId && account.Core_Customer_Aggregation_Type__c != 'UNFD_GLBL_CUST'
            && (oldAccounts.get(account.Id).Core_Parent_Business_Party_Id__c != account.Core_Parent_Business_Party_Id__c || (String.isNotEmpty(account.Core_Parent_Business_Party_Id__c)
            && account.ParentId == null))) {
                intelAccounts.add(account);
                UCD_ACM_Logger.information('ACM_BU_AssignParentToIntelAccount','getIntelAccounts','Intel AccountId: ' + account.ID + ' Intel Account Business Party Id: ' + account.Core_Business_Party_Id__c + ' Intel Account Parent Business Party Id: ' + account.Core_Parent_Business_Party_Id__c + ' ParentId: '+account.ParentId,null);
            }
        }
        
        return intelAccounts;
    }

    /**
     * Method to get Parent of intel accounts based on parent BP Id
     */
    private Map<String, Account> getParentAccountByBpId(Set<Account> intelAccounts) {
        Map<String, Account> parentAccountIdByBpId = new Map<String, Account>();
        Set<String> parentBpIds = new Set<String>();
        for (Account account : intelAccounts) {
            if (account.Core_Parent_Business_Party_Id__c != null) {
                parentBpIds.add(account.Core_Parent_Business_Party_Id__c);
            }
        }
        UCD_ACM_Logger.information('ACM_BU_AssignParentToIntelAccount','getParentAccountByBpId','Intel Account ParentBpids: ' + parentBpIds ,null);

        if(!parentBpIds.isEmpty()){
            // SOQL to get parent account details based on BPID
            List<Account> parentAccounts = [
                SELECT Id, Name, Core_Business_Party_Id__c, RecordTypeId
                FROM Account
                WHERE
                    Core_Business_Party_Id__c IN :parentBpIds
                    AND RecordTypeId = :intelRecordTypeId
                ORDER BY CreatedDate ASC
            ];

            // Adding data into collection - parent account by BP ID
            if (!parentAccounts.isEmpty()) {
                for (Account account : parentAccounts) {
                    if (parentAccountIdByBpId.get(account.Core_Business_Party_Id__c) == null) {
                    parentAccountIdByBpId.put(account.Core_Business_Party_Id__c, account);
                    }
                }
            }
        }

        return parentAccountIdByBpId;
    }

    /**
     * Method to set parent to Intel accounts
     */
    private void setParentToIntelAccount( Set<Account> intelAccounts, Map<String, Account> parentAccountByBpId) {
        for (Account account : intelAccounts) {
        // if parent Bpid is removed
            if (account.Core_Parent_Business_Party_Id__c == null) {
                account.parentId = null;
            }
            // If parent BpId is added or modified
            if (account.Core_Parent_Business_Party_Id__c != null && !parentAccountByBpId.isEmpty() && parentAccountByBpId.get(account.Core_Parent_Business_Party_Id__c) != null) {
                if (account.ParentId != null && account.ParentId == parentAccountByBpId.get(account.Core_Parent_Business_Party_Id__c).Id) {
                    continue;
                }
                account.parentId = parentAccountByBpId.get(account.Core_Parent_Business_Party_Id__c).Id;

            }
            UCD_ACM_Logger.information('ACM_BU_AssignParentToIntelAccount','setParentToIntelAccount','Parent to Intel Accounts: ' +  account.parentId ,null);

        }
    }
}