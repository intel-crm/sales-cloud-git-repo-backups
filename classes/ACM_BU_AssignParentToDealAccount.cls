/**
 * Class to assign parent to deal account coming from Reltio MDM system when parent is either null or it is updated
 * Author - Yashvir.pathak@intel.com
 * Date - 21 Feb 2023
 */
public without sharing class ACM_BU_AssignParentToDealAccount implements UCD_ACM_ServiceContracts.IBeforeUpdateAccountTrigger {
    static boolean runOnce = true;
    Id dealRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_Customer_Deal_Account').getRecordTypeId();

    /** 
     * Method to set parent to deal accounts when parent is either null or it is updated
     */
    public void execute( Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        try {
            // Run the logic only once and after all validations are completed
        if ((runOnce && isValid()) || Test.isRunningTest()) {
            //get deal accounts
            Set<Account> dealAccounts = getDealAccounts(oldAccounts, newAccounts);
            if(!dealAccounts.isEmpty()){
                // get Parent of deal accounts based on parent BP Id
                Map<String, Account> pAcctByBPId = getParentAccountByBpId(dealAccounts);
                // Set parent to Deal accounts
                setParentToDealAccount(dealAccounts, pAcctByBPId);
            }
            
        }
        runOnce = false;
        } catch (Exception ex) {
            UCD_ACM_Logger.error('ACM_BU_AssignParentToDealAccount','execute',ex.getMessage() +  '==>' + ex.getStackTraceString(),null);
        }
    }

    /**
     * Method to add validations
     */
    private Boolean isValid() {
        return userInfo.getUserId() == Label.UCD_ACM_ReltioUser;
    }

    /**
     * Method to filter deal accounts from new accounts collection
     */
    private Set<Account> getDealAccounts(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        Set<Account> dealAccounts = new Set<Account>();
        for (Account account : newAccounts.values()) {
            if (account.RecordTypeId == dealRecordTypeId && account.Core_Customer_Aggregation_Type__c != 'UNFD_GLBL_CUST' && (oldAccounts.get(account.Id).Core_Parent_Business_Party_Id__c != account.Core_Parent_Business_Party_Id__c || (String.isNotEmpty(account.Core_Parent_Business_Party_Id__c) && account.ParentId == null))) {
                dealAccounts.add(account);
            }
        }

        return dealAccounts;
    }

    /**
     *  Method to get Parent of deal accounts based on parent BP Id
     */ 
    private Map<String, Account> getParentAccountByBpId(Set<Account> dealAccounts) {
        Map<String, Account> pAcctByBPId = new Map<String, Account>();
        Set<String> parentBpIds = new Set<String>();
        for (Account account : dealAccounts) {
            if (account.Core_Parent_Business_Party_Id__c != null) {
                parentBpIds.add(account.Core_Parent_Business_Party_Id__c);
            } else {
                account.parentId = null;
            }
        }

        if(!parentBpIds.isEmpty()){
            List<Account> pAccts = new List<Account>();
            // SOQL to get parent account details based on BPID
            if (Schema.sObjectType.Account.fields.RecordTypeId.isAccessible() &&
            Schema.sObjectType.Account.fields.Core_Business_Party_Id__c.isAccessible() &&
            Schema.sObjectType.Account.fields.Name.isAccessible()){
                Set<String> pAggrTypes = new Set<String>{'UNFD_GLBL_CUST', 'UNFD_INTRMD_CUST'};
                pAccts = [
                    SELECT Id, Name, Core_Business_Party_Id__c, RecordTypeId
                    FROM Account
                    WHERE
                        Core_Business_Party_Id__c = :parentBpIds
                        AND RecordTypeId = :dealRecordTypeId
                        AND Core_Customer_Aggregation_Type__c =: pAggrTypes
                    ORDER BY CreatedDate ASC
                ];
            }
            

            // Adding data into collection - parent account by BP ID
            if (!pAccts.isEmpty()) {
                for (Account account : pAccts) {
                    if (pAcctByBPId.get(account.Core_Business_Party_Id__c) == null) {
                        pAcctByBPId.put(account.Core_Business_Party_Id__c, account);
                    }
                }
            }
        }

        return pAcctByBPId;
    }

    /**
     * Method to set parent to Deal accounts
     */
    private void setParentToDealAccount(Set<Account> dealAccounts, Map<String, Account> pAcctByBPId) {
        for (Account account : dealAccounts) {
            // If parent BpId is added or modified
            String pBPId = account.Core_Parent_Business_Party_Id__c;
            if (pBPId != null && !pAcctByBPId.isEmpty() && pAcctByBPId.get(pBPId) != null) {
                if ((account.ParentId != null && account.ParentId == pAcctByBPId.get(pBPId).Id) || account.Id == pAcctByBPId.get(pBPId).Id) {
                    continue;
                }
                account.parentId = pAcctByBPId.get(pBPId).Id;
            }
        }
    }
}