/**
 * Class to assign current deal account coming from Reltio MDM system as parent to Deal child accounts when BpId is updated
 * Current account siblings are set as parent to current deal account child with same record types
 * Author - Yashvir.pathak@intel.com
 * Date - 25 Feb 2023
 */
public without sharing class ACM_AU_ParentToDealChildAccount implements UCD_ACM_ServiceContracts.IAfterUpdateAccountTrigger {
    static boolean runOnce = true;
    Id dealRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_Customer_Deal_Account').getRecordTypeId();
    Map<String, Account> dealAccountByBpIds = new Map<String, Account>();
    List<String> validRecordTypeDeveloperName = new List<String>{'Mastered_Account'};

    /**
     * Method to set parent to Deal child accounts when BpId is updated
     */
    public void execute(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        try {
        // Run the logic only once and after all validations are completed
        if (runOnce && isValid()) {
            //set deal accounts collections
            setDealAccountCollection(oldAccounts, newAccounts);
            if(!dealAccountByBpIds.isEmpty()){
                // set parent to deal child accounts
                parentToDealChildAccounts(unitOfWork);
                // set parent to other child accounts
                parentToOtherChildAccounts(unitOfWork);                
            }
            
        }
        runOnce = false;
        } catch (Exception ex) {
        }
    }

    /**
     * Method to add validations
     */
    private Boolean isValid() {
        return userInfo.getUserId() == Label.UCD_ACM_ReltioUser;
    }

    /**
     * Method to filter deal accounts from new accounts collection when BpId is updated
     */
    private void setDealAccountCollection(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        for (Account account : newAccounts.values()) {
            if (account.RecordTypeId == dealRecordTypeId && oldAccounts.get(account.Id).Core_Business_Party_Id__c != account.Core_Business_Party_Id__c) {
                if(!dealAccountByBpIds.containsKey(account.Core_Business_Party_Id__c)){
                    dealAccountByBpIds.put(account.Core_Business_Party_Id__c, account);
                }
            }
        }
    }

    /**
     * Method to set parent to deal child accounts
     */
    private void parentToDealChildAccounts(UCD_ACM_UnitOfWork unitOfWork){
        // Get child accounts with parent BP Id as Current account BP Id
        Set<Account> childAccounts = getDealChildAccounts();

        // set current account as parent to child siblings with Deal record type
        setCurrentAccountParentToDealChild(unitOfWork, childAccounts);

    }

    /**
     * method to set parent to other child accounts
     */
    private void parentToOtherChildAccounts(UCD_ACM_UnitOfWork unitOfWork){
        // get current account siblings with record type in valid record type collection defined above
        Map<String, Set<Account>> currentAccountSiblingsByBpId = getCurrentAccountSiblingsByBpId();
        if(!currentAccountSiblingsByBpId.isEmpty()){
            // get Other Record Type Child Accounts from current account with record type in valid record type collection defined above
            Set<Account> otherChildAccounts = getOtherRecordTypeChildAccounts();

            if(!otherChildAccounts.isEmpty()){
                // set parent to child accounts with record type in valid record type collection defined above
                setParentToOtherChildAccounts(unitOfWork, otherChildAccounts, currentAccountSiblingsByBpId);
            }
        }
    }
    
    /**
     * Method to get child accounts with record type as ECD
     */
    private Set<Account> getDealChildAccounts(){
        // SOQL to get current account child with ECD record type
        List<Account> childAccounts = [
            SELECT Id, Name, Core_Business_Party_Id__c, RecordTypeId
            FROM Account
            WHERE
                Core_Parent_Business_Party_Id__c IN :dealAccountByBpIds.keySet()
                AND RecordTypeId = :dealRecordTypeId
                AND ParentId = null
        ];

        return childAccounts == null? new Set<Account>(): new Set<Account>(childAccounts);
    }

    /**
     * Method to set current account as parent to child accounts with Deal record type
     */
    private void setCurrentAccountParentToDealChild(UCD_ACM_UnitOfWork unitOfWork, Set<Account> childAccounts){
        // for each child, set current account as parent
        for(Account account: childAccounts){
            if(dealAccountByBpIds.containsKey(account.Core_Parent_Business_Party_Id__c)){
                Account accountToUpdate = new Account(Id = account.Id);
                // Update parent id
                accountToUpdate.ParentId = dealAccountByBpIds.get(account.Core_Parent_Business_Party_Id__c).Id;
                unitOfWork.registerModified(accountToUpdate);
            }
        }
    }

    /**
     * Method to get current account siblings with record type in valid record type collection defined above
     */
    private Map<String, Set<Account>> getCurrentAccountSiblingsByBpId(){
        Map<String, Set<Account>> currentAccountSiblingsByBpId = new Map<String, Set<Account>>();
        // SOQL to get current account sibling based on BPID and record type in valid record type collection defined above
        List<Account> accountSiblings = [
            SELECT Id, Name, Core_Business_Party_Id__c, RecordTypeId
            FROM Account
            WHERE
                Core_Business_Party_Id__c IN :dealAccountByBpIds.keySet()
                AND RecordType.DeveloperName IN :validRecordTypeDeveloperName
            ORDER BY CreatedDate ASC
        ];

        // Creating collection - account siblings by BPId
        if(accountSiblings!= null){
            for(Account sibling: accountSiblings){
                if(currentAccountSiblingsByBpId.containsKey(sibling.Core_Business_Party_Id__c)){
                    Set<Account> siblingAccounts = currentAccountSiblingsByBpId.get(sibling.Core_Business_Party_Id__c);
                    siblingAccounts.add(sibling);
                }else{
                    currentAccountSiblingsByBpId.put(sibling.Core_Business_Party_Id__c, new Set<account>{sibling});
                }
            }
        }

        return currentAccountSiblingsByBpId;
    }

    /**
     * Method to get Other Record Type Child Accounts from current account
     */
    private Set<Account> getOtherRecordTypeChildAccounts(){
        // SOQL to get current account child accounts based on BPID and and record type in valid record type collection defined above
        List<Account> childAccounts = [
            SELECT Id, Name, Core_Business_Party_Id__c, RecordTypeId
            FROM Account
            WHERE
                Core_Parent_Business_Party_Id__c IN :dealAccountByBpIds.keySet()
                AND RecordType.DeveloperName IN :validRecordTypeDeveloperName
                AND ParentId = null
        ];

        return childAccounts==null? new Set<Account>(): new Set<Account>(childAccounts);
    }

    /**
     * Method to set parent to child accounts with record type in valid record type collection defined above
     */
    private void setParentToOtherChildAccounts(UCD_ACM_UnitOfWork unitOfWork, Set<Account> childAccounts, Map<String, Set<Account>> currentAccountSiblingsByBpId){
        for(Account childAccount: childAccounts){
            if(currentAccountSiblingsByBpId.containsKey(childAccount.Core_Parent_Business_Party_Id__c)){

                for(Account siblingAccount: currentAccountSiblingsByBpId.get(childAccount.Core_Parent_Business_Party_Id__c)){
                    if(siblingAccount.RecordTypeId == childAccount.RecordTypeId){
                        Account accountToUpdate= new Account(Id = childAccount.Id);
                        accountToUpdate.ParentId = siblingAccount.Id;
                        unitOfWork.registerModified(accountToUpdate);
                        break;
                    }
                }
            }
            
        }
    }
}