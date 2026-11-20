public without sharing class ACM_BI_ParentToDealAccount implements UCD_ACM_ServiceContracts.IBeforeInsertAccountTrigger {
    static boolean runOnce = true;
    Id dealRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_Customer_Deal_Account').getRecordTypeId();

    /**
     * Method to set parent to deal accounts when account is created directly in Reltio with parent
     */
    public void execute(List<Account> newAccounts) {
        try {
            // Run the logic only once and after all validations are completed
        if ((runOnce && isValid()) || Test.isRunningTest()) {
            //get deal accounts
            Set<Account> dealAccounts = getDealAccounts(newAccounts);
            if(!dealAccounts.isEmpty()){
                // get Parent of deal accounts based on parent BP Id
                Map<String, Account> parentAccountByBpId = getParentAccountByBpId(dealAccounts);
                // Set parent to Deal accounts
                setParentToDealAccount( dealAccounts, parentAccountByBpId);
            }
            
        }
        runOnce = false;
        } catch (Exception ex) {
            UCD_ACM_Logger.error('ACM_BI_ParentToDealAccount','execute',ex.getMessage() +  '==>' + ex.getStackTraceString(),null);
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
    private Set<Account> getDealAccounts(List<Account> newAccounts) {
        Set<Account> dealAccounts = new Set<Account>();
        for (Account account : newAccounts) {
            if (account.RecordTypeId == dealRecordTypeId 
                && String.isNotEmpty(account.Core_Parent_Business_Party_Id__c)
                && account.Core_Customer_Aggregation_Type__c != 'UNFD_GLBL_CUST') {
                    // add deal account
                    dealAccounts.add(account);
            }
        }

        return dealAccounts;
    }

    /**
     *  Method to get Parent of deal accounts based on parent BP Id
     */ 
    private Map<String, Account> getParentAccountByBpId(Set<Account> dealAccounts) {
        Map<String, Account> parentAccountIdByBpId = new Map<String, Account>();
        Set<String> parentBpIds = new Set<String>();
        for (Account account : dealAccounts) {
            if (String.isNotEmpty(account.Core_Parent_Business_Party_Id__c)) {
                parentBpIds.add(account.Core_Parent_Business_Party_Id__c);
            }
        }

        if(!parentBpIds.isEmpty()){
            List<Account> parentAccounts;
            // SOQL to get parent account details based on BPID
            if (Schema.sObjectType.Account.fields.Core_Business_Party_Id__c.isAccessible()){
             parentAccounts = [
                SELECT Id, Name, Core_Business_Party_Id__c, RecordTypeId
                FROM Account
                WHERE
                    Core_Business_Party_Id__c = :parentBpIds
                    AND RecordTypeId = :dealRecordTypeId
                ORDER BY CreatedDate ASC
            ];
            }

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
     * Method to set parent to Deal accounts
     */
    private void setParentToDealAccount(Set<Account> dealAccounts, Map<String, Account> parentAccountByBpId) {
        for (Account account : dealAccounts) {
            // If parent BpId is present and parent account is available in SF
            if (!parentAccountByBpId.isEmpty() && parentAccountByBpId.containsKey(account.Core_Parent_Business_Party_Id__c)) {
                account.parentId = parentAccountByBpId.get(account.Core_Parent_Business_Party_Id__c).Id;
            }
        }
    }
}