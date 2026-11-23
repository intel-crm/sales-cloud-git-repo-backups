public without sharing class ACM_AU_DeleteCpe implements UCD_ACM_ServiceContracts.IAfterUpdateAccountTrigger{
    static boolean runOnce = true;
    private static UCD_ACM_ServiceContracts.IAccountService accountServiceInstance = UCD_ACM_AccountService.getInstance();
    Id intelAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    Map<Id,List<Business_Types__c>> mapOfBusinessTypesByAccountId=new Map<Id,List<Business_Types__c>>();
    Map<Id,Account> mapOfAccount=new Map<Id,Account>();
    public void execute(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        if(runOnce){
            try{
                getmapOfBusinessTypesByAccountId(oldAccounts,newAccounts);
                if(!mapOfBusinessTypesByAccountId.isEmpty() && !mapOfAccount.isEmpty()){
                    deleteAccountBusinessType(unitOfWork,mapOfAccount,mapOfBusinessTypesByAccountId);
                }
            }
            catch(Exception e){
                UCD_ACM_Logger.error('ACM_AU_DeleteCpe','execute',e.getMessage() +  '==>' + e.getStackTraceString(),null);
            }
        }
        runOnce=false;
    }
    private void getmapOfBusinessTypesByAccountId(Map<Id, Account> oldAccounts,Map<Id, Account> newAccounts){
        for(Account account: newAccounts.values()){
           if((account.Core_Business_Party_Id__c!=null && account.RecordTypeId==intelAccountRTId) && ((oldAccounts.get(account.Id).Core_Intel_Partner_Alliance_PartnerGroup__c==true && account.Core_Intel_Partner_Alliance_PartnerGroup__c==false) || (oldAccounts.get(account.Id).Core_MDF_CoMarketingActive__c==true && account.Core_MDF_CoMarketingActive__c==false))){
                mapOfAccount.put(account.Id,account);
           }
        }
        if(mapOfAccount.size()>0 && mapOfAccount!=null){
            mapOfBusinessTypesByAccountId = accountServiceInstance.getActiveBusinessTypeForAccount(mapOfAccount.keySet());
        }
    }

    private void deleteAccountBusinessType(UCD_ACM_UnitOfWork unitOfWork,Map<Id,Account> mapOfAccount,Map<Id,List<Business_Types__c>> mapOfBusinessTypesByAccountId){
        Set<Id> acctId=new Set<Id>();
        Set<Id> bpid=new Set<Id>();
        for(Account account : mapOfAccount.values()){
            if(account.Core_Business_Party_Id__c!=null && mapOfBusinessTypesByAccountId.containsKey(account.Id)){
                for(Business_Types__c acctbusinessType : mapOfBusinessTypesByAccountId.get(account.Id)){
                    if(account.Core_Intel_Partner_Alliance_PartnerGroup__c==false && acctbusinessType.Business_Type_Code__c=='PTNR'){
                        acctId.add(account.Id);
                        bpid.add(acctbusinessType.Id);
                    }
                    if(account.Core_MDF_CoMarketingActive__c==false && acctbusinessType.Business_Type_Code__c=='SLS_PPLN'){
                        acctId.add(account.Id);
                        bpid.add(acctbusinessType.Id);
                    }
                }
            }
        }
        for(Account_Business_Types__c acctBusinessType : [Select Id,Account__c,Business_Types__c from Account_Business_Types__c Where Account__c IN :acctId AND Business_Types__c IN :bpid]){
            unitOfWork.registerDeleted(acctBusinessType);
        }
    }
}