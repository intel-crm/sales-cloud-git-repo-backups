public with sharing class ACM_BU_AssignParentToIntelAcct implements UCD_ACM_ServiceContracts.IBeforeUpdateAccountTrigger {
    
    static boolean runOnce = true;
    private static Id intelAcctRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    private static Id inactiveAcctRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inactive_Account').getRecordTypeId();
    Map<ID, String> oldParentBPID = new Map<ID, String>();

    public void execute( Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        try {
            // Run the logic only once and after all validations are completed 
            if ((runOnce && isValid()) || Test.isRunningTest()) {
                //get Intel accounts
                System.debug('New Hierarchy Update Class  : '+newAccounts);
                Set<Account> intelAccounts = getIntelAccounts(oldAccounts, newAccounts); 
                UCD_ACM_Logger.information('ACM_BU_AssignParentToIntelAccount','execute','Intel Accounts: ' + intelAccounts ,null);
                if(!intelAccounts.isEmpty()) {
                    // get Parent of Intel accounts based on parent BP Id
                    Map<String, Account> pAcctByBPId = getParentAccountByBpId(intelAccounts);
                    UCD_ACM_Logger.information('ACM_BU_AssignParentToIntelAccount','execute','Parent account: ' + pAcctByBPId ,null);
                    // Set parent to Intel accounts
                    setParentToIntelAccount(intelAccounts, pAcctByBPId);
                }
                ACM_BU_AssignParentToIntelAcct.setAccountHierarchieAttributes(oldAccounts, newAccounts);    
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
     * Adding Inactive account Check for ECB flagged x-walk merge
     */
    private Set<Account> getIntelAccounts(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        Set<Account> intelAccounts = new Set<Account>();
        for (Account account : newAccounts.values()) {
            if ((account.RecordTypeId == intelAcctRTId || (account.Core_Export_Compliance_Block__c == true && account.RecordTypeId == inactiveAcctRTId)) && account.Core_Customer_Aggregation_Type__c != 'UNFD_GLBL_CUST' && (oldAccounts.get(account.Id).Core_Parent_Business_Party_Id__c == null || account.Core_Parent_Business_Party_Id__c == null) && (oldAccounts.get(account.Id).Core_Parent_Business_Party_Id__c != account.Core_Parent_Business_Party_Id__c || (String.isNotEmpty(account.Core_Parent_Business_Party_Id__c) && account.ParentId == null))) {
                intelAccounts.add(account);
                UCD_ACM_Logger.information('ACM_BU_AssignParentToIntelAccount','getIntelAccounts','Intel AccountId: ' + account.ID + ' Intel Account Business Party Id: ' + account.Core_Business_Party_Id__c + ' Intel Account Parent Business Party Id: ' + account.Core_Parent_Business_Party_Id__c + ' ParentId: '+account.ParentId,null);
            }
        }
        return intelAccounts;
    }

    /**
     * Method to get Parent of intel accounts based on parent BP Id
     */
    public static Map<String, Account> getParentAccountByBpId(Set<Account> intelAccounts) {
        Map<String, Account> pAcctByBPId = new Map<String, Account>();
        Set<String> parentBpIds = new Set<String>();
        for (Account account : intelAccounts) {
            if (account.Core_Parent_Business_Party_Id__c != null) {
                parentBpIds.add(account.Core_Parent_Business_Party_Id__c);
            } else {
                account.parentId = null;
            }
        }
        UCD_ACM_Logger.information('ACM_BU_AssignParentToIntelAccount','getParentAccountByBpId','Intel Account ParentBpids: ' + parentBpIds ,null);
        if(!parentBpIds.isEmpty()){
            List<Account> pAccts;
            // SOQL to get parent account details based on BPID
            // Adding Core_Export_Compliance_Block__c Check For TWC2056-5253
            if (Schema.sObjectType.Account.fields.Core_Business_Party_Id__c.isAccessible()){
                 pAccts = [
                    SELECT Id, Name, Core_Business_Party_Id__c, RecordTypeId
                    FROM Account
                    WHERE
                    Core_Business_Party_Id__c IN :parentBpIds
                    AND (RecordTypeId = :intelAcctRTId OR (Core_Export_Compliance_Block__c = true AND RecordTypeId = :inactiveAcctRTId))
                    ORDER BY CreatedDate ASC
                ];
            }
            // Adding data into collection - parent account by BP ID
            if (pAccts!=null && !pAccts.isEmpty()) {
                for (Account account : pAccts) {
                    //Below code-line helps getting the second parent, in the case of same account as parent
                    String key = pAcctByBPId.get(account.Core_Business_Party_Id__c) == null ? account.Core_Business_Party_Id__c : (account.Core_Business_Party_Id__c+'_2');
                    if (pAcctByBPId.get(key) == null) {
                        pAcctByBPId.put(key, account);
                    }
                }
            }
        }

        return pAcctByBPId;
    }

    /**
     * Method to set parent to Intel accounts
     */
    public static List<Account> setParentToIntelAccount(Set<Account> intelAccounts, Map<String, Account> pAcctByBPId) {
        List<Account> accList = new List<Account>();
        for (Account account : intelAccounts) {
            String pBPId = account.Core_Parent_Business_Party_Id__c;
            if (pBPId != null && !pAcctByBPId.isEmpty() && pAcctByBPId.get(pBPId) != null) {
                String key = (account.Id != pAcctByBPId.get(pBPId).Id) ? pBPId : (pBPId+'_2');
                if (account.ParentId != null && account.ParentId == pAcctByBPId.get(key).Id ) {
                    continue;
                }
                account.parentId = (pAcctByBPId.get(key) != null) ? pAcctByBPId.get(key).Id : null;
            } else if(pBPId != null) {
                account.parentId = null;
            }
            accList.add(account);
            UCD_ACM_Logger.information('ACM_BU_AssignParentToIntelAccount','setParentToIntelAccount','Parent to Intel Accounts: ' +  account.parentId ,null);
        }
        return accList;
    }

    private static void setAccountHierarchieAttributes(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts){
        System.debug('New Hierarchy Update : '+newAccounts);
        List<Account> accountList = new List<Account>();

        for (Account account : newAccounts.values()) {
            if (String.isNotBlank(account.Core_Customer_Aggregation_Type__c) &&
                    (oldAccounts.get(account.Id).Core_Business_Party_Id__c == null || oldAccounts.get(account.Id).ParentId == null || account.Core_Parent_Business_Party_Id__c == null) &&
                    ( account.Core_Business_Party_Id__c != oldAccounts.get(account.Id).Core_Business_Party_Id__c ||
                        account.ParentId != oldAccounts.get(account.Id).ParentId || 
                        account.Core_Customer_Aggregation_Type__c != oldAccounts.get(account.Id).Core_Customer_Aggregation_Type__c || 
                        account.RecordTypeId != oldAccounts.get(account.Id).RecordTypeId ||
                        account.Core_Data_Simplified_Account_Nm__c != oldAccounts.get(account.Id).Core_Data_Simplified_Account_Nm__c ||
                        (   String.isNotBlank(account.Core_Data_Simplified_Account_Nm__c) && 
                            String.isNotBlank(oldAccounts.get(account.Id).Core_Data_Simplified_Account_Nm__c) &&
                            !(account.Core_Data_Simplified_Account_Nm__c.equals(oldAccounts.get(account.Id).Core_Data_Simplified_Account_Nm__c))
                        )
                    )
                ){
                    accountList.add(account); 
                }
            if(Schema.sObjectType.Account.fields.Unified_Hierarchy_View__c.isUpdateable()){
                ACM_BU_SetAccountHierarchyAttributes.updateUnifiedHierarchy(account);
            }
        }
        System.debug('Hierarchy Accounts : '+accountList);
        if(accountList.size()>0){
            //ACM_BU_SetAccountHierarchyAttributes.updateAccHierarchyAttributes(accountList);
        }

    }

}