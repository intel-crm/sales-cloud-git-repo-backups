/*
* description : Queueable Class to Set UCD hierarchy fields for child accounts 
* params : Set<Id> parentAccId
* author and date : swarupx.kumar.singh@intel.com, 09 Jan 2023
*/
public without sharing class UCD_ACM_UpdateHierarchyFieldsQueueable implements Queueable {
    
    private static UCD_ACM_SelectorContracts.IAccountQuerySelector accountQuerySelectorInstance = UCD_ACM_AccountQuerySelector.getInstance();
    Set<Id> parentAccountIds = new Set<Id>();
    public UCD_ACM_UpdateHierarchyFieldsQueueable(Set<Id> parentAccId) { 
        this.parentAccountIds.addAll(parentAccId); 
    }
    public void execute(QueueableContext context) {
        Map<Id, Account> mChildAccounts = accountQuerySelectorInstance.getAllChildAccounts(this.parentAccountIds);

        if(mChildAccounts <> null && mChildAccounts.Values().size() > 0) {
            Map<Id, Account> mAccountsToUpdate = new Map<Id, Account>();

            mAccountsToUpdate = UCD_ACM_Common.setHierarchyFieldsBulk(mChildAccounts);
            
            UCD_ACM_Logger.information('UCD_ACM_UpdateHierarchyFieldsQueueable','updateHierarchyFieldsForChildAccounts','AFTER - Account Added for Update - IDs:' + mChildAccounts.keySet(),'AccountIds: '+mChildAccounts.keySet());
            if(mAccountsToUpdate <> null && mAccountsToUpdate.Values().size() > 0) {
                try {
                    Map<Id,Account> accForInbound = new Map<Id,Account>();
                    Database.SaveResult[] result = Database.Update(mAccountsToUpdate.Values(),false);
                    for (Database.SaveResult sr : result) {
                        if (sr.isSuccess()) {
                            accForInbound.put(sr.getId(),mAccountsToUpdate.get(sr.getId()));    
                        }
                    }
                    if(accForInbound!=null && !accForInbound.isEmpty()){
                        PRM_OPIDPAGRecordOperation.accountEligibleForOPID(accForInbound,false,null);
                    }
                    ACM_AU_TriggerPlatformEventOnUpdate.platformRunOnce=true;                   
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