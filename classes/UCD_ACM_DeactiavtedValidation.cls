public without sharing class UCD_ACM_DeactiavtedValidation implements UCD_ACM_ServiceContracts.IBeforeUpdateAccountTrigger {
    static boolean runOnce = true;
    Id intelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    Set<Id> parentAccountIds = new Set<Id>();
    Map<Id,List<Account>> parentAccountIdsWithChild = new map<Id,List<Account>>();

    public void execute(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts){

        try{       
            if(runOnce || Test.isRunningTest()){
                parentAccountData(oldAccounts,newAccounts);
                Map<Id,List<Account>> childAccount = getChildAccounts();
                if(childAccount != null && !childAccount.isEmpty()){
                    ValidationMessage(newAccounts);
                }
                
            }
        }
        catch (Exception ex) {
        UCD_ACM_Logger.error('UCD_ACM_DeactiavtedValidation','execute',ex.getMessage() +  '==>' + ex.getStackTraceString(),null);
        }
        runOnce = false;
    }
    private void parentAccountData(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts){  
        for(Account account : newAccounts.values()){
            if( oldAccounts.get(account.Id).Core_Deactivated__c != account.Core_Deactivated__c && account.Core_Deactivated__c==true){
                parentAccountIds.add(account.id);
            }
        }   
    }

    private map<Id,List<Account>> getChildAccounts(){

        List<Account> childAccounts = new List<Account>();

        if (Schema.sObjectType.Account.fields.RecordTypeId.isAccessible() && 
            Schema.sObjectType.Account.fields.Core_Parent_Business_Party_Id__c.isAccessible()  &&
            Schema.sObjectType.Account.fields.ParentId.isAccessible()){

                childAccounts = [
                Select Id, RecordTypeId, Core_Parent_Business_Party_Id__c, ParentId, Parent.Core_Business_Party_Id__c
                From Account
                Where (RecordTypeId =: intelRecordTypeId) 
                AND Core_Customer_Aggregation_Type__c != null
                AND Core_Business_Party_Id__c != null
                AND ParentId IN:parentAccountIds LIMIT 100 
            
                ];

        }
        
        for(Account account: childAccounts){
            if(parentAccountIdsWithChild.containsKey(account.id)){
                parentAccountIdsWithChild.get(account.parent.Id).add(account);
            }
            else {
                parentAccountIdsWithChild.put(account.parent.Id, new List<Account>{account});
            }
        }
        return parentAccountIdsWithChild;
    }
    private void ValidationMessage( Map<Id, Account> newAccounts){
        for(Account account : newAccounts.values()){
            if(parentAccountIdsWithChild.containsKey(account.id)){
              account.addError(System.Label.UCD_AccountDeactivation_Validation_Message); // Custom Label UCD_AccountDeactivation_Validation_Message
            }    
        }
    }
}