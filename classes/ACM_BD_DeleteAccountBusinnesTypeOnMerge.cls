public without sharing class ACM_BD_DeleteAccountBusinnesTypeOnMerge implements UCD_ACM_ServiceContracts.IBeforeDeleteAccountTrigger {
    static boolean runOnce = true;
    public void execute(List<Account> oldListAccounts) {
        try {
            if (runOnce) {
                deleteAccountBusinnesTypeOnMerge(oldListAccounts);
            }
            runOnce = false;
        }catch (Exception ex) {
            UCD_ACM_Logger.error('ACM_BU_SetAttributesOnMDMUpdate','execute',ex.getMessage() +  '==>' + ex.getStackTraceString(),null);
        }
    }
    public void deleteAccountBusinnesTypeOnMerge(List<Account> oldListAccount){
        System.debug('##oldListAccount '+oldListAccount);
        Set<Id> nonSurvivorAccountIds=new Set<Id>();
        List<Account_Business_Types__c>  acctBusinessTypeToDelete=new List<Account_Business_Types__c>();
        for(Account acc : oldListAccount){
            nonSurvivorAccountIds.add(acc.Id);
        }
        if(!nonSurvivorAccountIds.isEmpty()){
            acctBusinessTypeToDelete = [SELECT Id FROM Account_Business_Types__c WHERE Account__c IN :nonSurvivorAccountIds];
        }
        if(!acctBusinessTypeToDelete.isEmpty()){
            delete acctBusinessTypeToDelete;
        }
    }
}