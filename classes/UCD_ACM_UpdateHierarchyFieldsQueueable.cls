/*
* description : Queueable Class to Set UCD hierarchy fields for child accounts 
* params : Id parentAccId
* author and date : swarupx.kumar.singh@intel.com, 09 Jan 2023
*/
public without sharing class UCD_ACM_UpdateHierarchyFieldsQueueable implements Queueable {
    
    private static UCD_ACM_SelectorContracts.IAccountQuerySelector accountQuerySelectorInstance = UCD_ACM_AccountQuerySelector.getInstance();
    Set<Id> parentAccountIds = new Set<Id>();
    public UCD_ACM_UpdateHierarchyFieldsQueueable(Id parentAccId) { 
        this.parentAccountIds.add(parentAccId); 
    }
    public void execute(QueueableContext context) {
        Map<Id, Account> mChildAccounts = accountQuerySelectorInstance.getAllChildAccounts(this.parentAccountIds);

        if(mChildAccounts <> null && mChildAccounts.Values().size() > 0) {
            Map<Id, Account> mAccountsToUpdate = new Map<Id, Account>();
            for (Id acctId: mChildAccounts.keySet()) {
                Account acct = mChildAccounts.get(acctId);
                Account parentAcct = acct.ParentId <> null ? mChildAccounts.get(acct.ParentId) : null;

                UCD_ACM_Common.setHierarchyFields(acct, parentAcct);   

                mAccountsToUpdate.put(acctId, acct);
                UCD_ACM_Logger.information('UCD_ACM_UpdateHierarchyFieldsQueueable','updateHierarchyFieldsForChildAccounts','AFTER - Account Added for Update - ID:' + acctId,'AccountIds: '+acctId);
            }            
            if(mAccountsToUpdate <> null && mAccountsToUpdate.Values().size() > 0) {
                try {

                    update mAccountsToUpdate.Values();
                } catch(DMLException e) {
                    UCD_ACM_Logger.error('UCD_ACM_UpdateHierarchyFieldsQueueable', 'updateHierarchyFieldsForChildAccounts', 'Message: '+e.getMessage()+'. StackTrace: '+e.getStackTraceString(),'ParentAccountIds: '+this.parentAccountIds.toString());
                }
                finally {
                    UCD_ACM_Logger.setLogDetails(); 
                }        
            }
        }
    }
    

    
   
}