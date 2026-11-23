public without sharing class ACM_AU_ParentToChildOnPublish implements UCD_ACM_ServiceContracts.IAfterUpdateAccountTrigger {
    static boolean runOnce = true;
    Id dealAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_Customer_Deal_Account').getRecordTypeId();
    Id intelAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    Map<String, List<Account>> parentAccountByBPID = new Map<String,List<Account>>();
    public void execute(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        if (runOnce && (isValid() || Test.isRunningTest())) {
            try {
                setParentAccountByBPID(oldAccounts, newAccounts);
                if(!parentAccountByBPID.isEmpty()) {
                    List<Account> childAccounts = getChildAccountColl();
                    if(!childAccounts.isEmpty()) {
                        setParentToChildAccount(unitOfWork, childAccounts);
                    }
                }
            } catch (Exception ex) {
                UCD_ACM_Logger.error('ACM_AU_ParentToChildOnPublish','execute',ex.getMessage() +  '==>' + ex.getStackTraceString(),null);
            }
        }
        runOnce = false;
    }
    private Boolean isValid() {
        return userInfo.getUserId() == Label.UCD_ACM_ReltioUser;
    }
    private List<Account> getChildAccountColl(){
        List<Account> childAccounts = [
            Select Id, RecordTypeId, Core_Parent_Business_Party_Id__c, ParentId, Account.Parent.Core_Business_Party_Id__c
            From Account
            Where (RecordTypeId =: intelAccountRTId OR RecordTypeId =: dealAccountRTId)
            AND Core_Customer_Aggregation_Type__c != null
            AND Core_Business_Party_Id__c != null
            AND Core_Parent_Business_Party_Id__c IN:parentAccountByBPID.keySet() LIMIT 100 
        ];
        return childAccounts;
    }

    private void setParentToChildAccount(UCD_ACM_UnitOfWork unitOfWork, List<Account> childAccounts){
        for(Account account : childAccounts) {
            List<Account> parentAccounts = parentAccountByBPID.get(account.Core_Parent_Business_Party_Id__c);
            Account parentAccount = getSameRTParentAccount(account.RecordTypeId, parentAccounts);

            if(parentAccount != null && (account.ParentId == null || (account.ParentId != null && account.ParentId != parentAccount.Id && String.isBlank(account.Parent.Core_Business_Party_Id__c)))) {
                Account accountToUpdate = new Account(Id = account.Id);
                accountToUpdate.ParentId = parentAccount.Id;
                unitOfWork.registerModified(accountToUpdate);
            }
        }
    }
    private void setParentAccountByBPID(Map<Id, Account> oldAccounts,Map<Id, Account> newAccounts) {
        for(Account parentAccount : newAccounts.values()) {
            if(String.isNotEmpty(parentAccount.Core_Business_Party_Id__c) && oldAccounts.get(parentAccount.Id).Core_Business_Party_Id__c != parentAccount.Core_Business_Party_Id__c) {
                if(parentAccountByBPID.containsKey(parentAccount.Core_Business_Party_Id__c)) {
                    List<Account> accounts = parentAccountByBPID.get(parentAccount.Core_Business_Party_Id__c);
                    accounts.add(parentAccount);
                }
                else {
                    parentAccountByBPID.put(parentAccount.Core_Business_Party_Id__c, new List<Account>{ parentAccount });
                }
            }
        }
    }
    private Account getSameRTParentAccount(Id childRecordType, List<Account> parentAccounts) {
        for(Account account : parentAccounts) {
            if(account.RecordTypeId == childRecordType) {
                return account;
            }
        }
        return null;
    }
}