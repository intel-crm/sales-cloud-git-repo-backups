public with sharing class ACM_AU_PublishChildAccts implements UCD_ACM_ServiceContracts.IAfterUpdateAccountTrigger {
    static boolean runOnce = true;
    private static Id dealAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_Customer_Deal_Account').getRecordTypeId();
    private static Id intelAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    private static Id inactiveAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inactive_Account').getRecordTypeId();
    Map<String, List<Account>> parentAccountByBPIDMap = new Map<String,List<Account>>();
    public void execute(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        if ((runOnce && (isValid() || Test.isRunningTest()))) {
            try {
                    setParentAccountByBPID(oldAccounts, newAccounts);
                if(!parentAccountByBPIDMap.isEmpty()) {
                    List<Account> childAccounts = getChildAccountColl(parentAccountByBPIDMap.keySet());

                    if(!childAccounts.isEmpty()) {
                        setParentToChildAccount(unitOfWork, childAccounts,parentAccountByBPIDMap);
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
    public static List<Account> getChildAccountColl(Set<String> parentAccountBPID){

        List<Account> childAccounts = new List<Account>();

        if (Schema.sObjectType.Account.fields.RecordTypeId.isAccessible() &&
            Schema.sObjectType.Account.fields.Core_Parent_Business_Party_Id__c.isAccessible()  &&
            Schema.sObjectType.Account.fields.ParentId.isAccessible() &&
            Schema.sObjectType.Account.fields.Core_Business_Party_Id__c.isAccessible()  ){
            childAccounts = [
                Select Id, RecordTypeId, Core_Parent_Business_Party_Id__c, ParentId, Account.Parent.Core_Business_Party_Id__c
                From Account
                Where (RecordTypeId =: intelAccountRTId OR RecordTypeId =: dealAccountRTId OR (Core_Export_Compliance_Block__c = true AND RecordTypeId =: inactiveAccountRTId))
                AND Core_Customer_Aggregation_Type__c != null
                AND Core_Customer_Aggregation_Type__c != 'UNFD_GLBL_CUST'
                AND Core_Business_Party_Id__c != null
                AND Core_Parent_Business_Party_Id__c!=null
                AND Core_Parent_Business_Party_Id__c IN:parentAccountBPID LIMIT 100 
            ];

        }
        
        return childAccounts;
    }

    public static List<Account> setParentToChildAccount(UCD_ACM_UnitOfWork unitOfWork, List<Account> childAccounts,Map<String, List<Account>> parentAccountByBPID){
        List<Account> accToUpdate = new List<Account>();
        for(Account account : childAccounts) {
            Boolean isChanged = false;
            List<Account> parentAccounts = parentAccountByBPID.get(account.Core_Parent_Business_Party_Id__c);
            Account parentAccount = getSameRTParentAccount(account.RecordTypeId, parentAccounts);
            if(parentAccount != null) {
                Account accountToUpdate = new Account(Id = account.Id);
                if(parentAccount.id != account.id && (account.ParentId == null || (account.ParentId != null && account.ParentId != parentAccount.Id && account.Core_Parent_Business_Party_Id__c != parentAccount.Core_Business_Party_Id__c && account.Parent.Core_Business_Party_Id__c != parentAccount.Core_Business_Party_Id__c))) {
                    accountToUpdate.ParentId = parentAccount.Id;
                    isChanged = true;
                }
                if(account.RecordTypeId == intelAccountRTId && account.ParentId != null && parentAccount.id == account.ParentId && account.Core_Parent_Business_Party_Id__c != parentAccount.Core_Business_Party_Id__c) {
                    accountToUpdate.ParentId = null;
                    isChanged = true;
                    ACM_BU_SetAccountHierarchyAttributes.runOnce = true;
                }
                if(isChanged && unitOfWork != null) {
                    unitOfWork.registerModified(accountToUpdate);
                }
                accToUpdate.add(accountToUpdate);
            }            
        }
        return accToUpdate;
    }
    private void setParentAccountByBPID(Map<Id, Account> oldAccounts,Map<Id, Account> newAccounts) {
        for(Account parentAccount : newAccounts.values()) {
            if(String.isNotEmpty(parentAccount.Core_Business_Party_Id__c) && oldAccounts.get(parentAccount.Id).Core_Business_Party_Id__c != parentAccount.Core_Business_Party_Id__c) {
                if(parentAccountByBPIDMap.containsKey(parentAccount.Core_Business_Party_Id__c)) {
                    List<Account> accounts = parentAccountByBPIDMap.get(parentAccount.Core_Business_Party_Id__c);
                    accounts.add(parentAccount);
                }
                else {
                    parentAccountByBPIDMap.put(parentAccount.Core_Business_Party_Id__c, new List<Account>{ parentAccount });
                }
                /*if(oldAccounts.get(parentAccount.Id).Core_Business_Party_Id__c != parentAccount.Core_Business_Party_Id__c){
                    parentAccountByBPID.put(oldAccounts.get(parentAccount.Id).Core_Business_Party_Id__c, new List<Account>{ parentAccount });
                }*/
            }
        }
    }
    private static Account getSameRTParentAccount(Id childRecordType, List<Account> parentAccounts) {
        for(Account account : parentAccounts) {
            if(account.RecordTypeId == childRecordType) {
                return account;
            }
        }
        return null;
    }
}