public without sharing class ACM_AI_ParentToChildOnPublish implements UCD_ACM_ServiceContracts.IAfterInsertAccountTrigger{
    static boolean runOnce = true;
    Id dealAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_Customer_Deal_Account').getRecordTypeId();
    Map<String, List<Account>> parentAccountByBPID = new Map<String,List<Account>>();
    public void execute(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        if (runOnce && (isValid() || Test.isRunningTest())) {
            try {
                setParentAcctByBPIDColl(newAccounts);
                if(!parentAccountByBPID.isEmpty()) {
                    List<Account> childAccounts=getChildAccountColl();
                    if(!childAccounts.isEmpty()) {
                        setParentToChildAccount(unitOfWork,childAccounts);
                    }
                }
            } catch (Exception ex) {
                UCD_ACM_Logger.error('ACM_AI_ParentToChildOnPublish','execute',ex.getMessage() +  '==>' + ex.getStackTraceString(),null);
            }
        }
        runOnce = false;
    }
    private Boolean isValid() {
        return userInfo.getUserId() == Label.UCD_ACM_ReltioUser;
    }
    private List<Account> getChildAccountColl() {
        List<Account> childAccounts= [
            Select Id, RecordTypeId, Core_Parent_Business_Party_Id__c, ParentId
            From Account
            Where ParentId = null 
            AND RecordTypeId =: dealAccountRTId
            AND Core_Customer_Aggregation_Type__c != null
            AND Core_Business_Party_Id__c != null
            AND Core_Parent_Business_Party_Id__c IN:parentAccountByBPID.keySet() LIMIT 100 
        ];
        System.debug('$#@childAccounts '+childAccounts);
        return childAccounts; 
    }

    private void setParentToChildAccount(UCD_ACM_UnitOfWork unitOfWork, List<Account> childAccounts) {
        for(Account account : childAccounts) {
            List<Account> parentAccounts = parentAccountByBPID.get(account.Core_Parent_Business_Party_Id__c);
            Account parentAccount = getSameRTParentAccount(account.RecordTypeId, parentAccounts);
            if(parentAccount != null) {
                Account accountToUpdate = new Account(Id = account.Id);
                accountToUpdate.ParentId = parentAccount.Id;
                unitOfWork.registerModified(accountToUpdate);
            }
        }
    }
    private void setParentAcctByBPIDColl(Map<Id, Account> newAccounts) {
        for(Account currentAccount : newAccounts.values()) {
            if(String.isNotEmpty(currentAccount.Core_Business_Party_Id__c)) {
                if(parentAccountByBPID.containsKey(currentAccount.Core_Business_Party_Id__c)) {
                    List<Account> accounts=parentAccountByBPID.get(currentAccount.Core_Business_Party_Id__c);
                    accounts.add(currentAccount);
                }
                else {
                    parentAccountByBPID.put(currentAccount.Core_Business_Party_Id__c,new List<Account>{currentAccount});
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