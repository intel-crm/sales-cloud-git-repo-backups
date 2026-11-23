public without sharing class ACM_AU_InsertCpe implements UCD_ACM_ServiceContracts.IAfterUpdateAccountTrigger {
    static boolean runOnce = true;
    private static UCD_ACM_ServiceContracts.IAccountService accountServiceInstance = UCD_ACM_AccountService.getInstance();
    Id intelAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    Map<Id,List<Business_Types__c>> mapOfBusinessTypesByAccountId=new Map<Id,List<Business_Types__c>>();
    Map<Id,Account> mapOfAccount=new Map<Id,Account>();
    Set<String> setOfBusinessType=new Set<String>();
    Map<String,Business_Types__c> mapOfBusineesType=new Map<String,Business_Types__c>();
    public void execute(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        if(runOnce){
            try{
                mapOfBusineesType=getMapOfBusinessTypes();
                getmapOfBusinessTypesByAccountId(newAccounts);
                if(!mapOfBusinessTypesByAccountId.isEmpty() && !mapOfAccount.isEmpty() && !mapOfBusineesType.isEmpty() &&!setOfBusinessType.isEmpty()){
                    checkAndInsertBusinessTypeofAccount(unitOfWork);
                }
            }
            catch(Exception e){
                UCD_ACM_Logger.error('ACM_AU_InsertCpe','execute',e.getMessage() +  '==>' + e.getStackTraceString(),null);
            }
        }
        runOnce=false;
    }

    private Map<String,Business_Types__c> getMapOfBusinessTypes(){
        List<Business_Types__c> businessTypes = [
            Select Id,Business_Type_Code__c, Name 
            from Business_Types__c 
            where Is_Active__c = true
        ];
        for(Business_Types__c businessType : businessTypes){
            mapOfBusineesType.put(businessType.Business_Type_Code__c,businessType);
        }
        return mapOfBusineesType.size() > 0 ? mapOfBusineesType : null;
    }
    private void getmapOfBusinessTypesByAccountId(Map<Id, Account> newAccounts){
        for(Account account: newAccounts.values()){
           if((account.Core_Business_Party_Id__c!=null && account.RecordTypeId==intelAccountRTId) && (account.Core_Intel_Partner_Alliance_PartnerGroup__c==true||account.Core_MDF_CoMarketingActive__c==true)){
                mapOfAccount.put(account.Id,account);
           }
        }
        mapOfBusinessTypesByAccountId = accountServiceInstance.getActiveBusinessTypeForAccount(mapOfAccount.keySet());
        if(!mapOfBusinessTypesByAccountId.isEmpty()){
            for(Id val : mapOfBusinessTypesByAccountId.keySet()){
                for(Business_Types__c businessType : mapOfBusinessTypesByAccountId.get(val)){
                    setOfBusinessType.add(businessType.Business_Type_Code__c);
                }
            }
        }
    }

    private void checkAndInsertBusinessTypeofAccount(UCD_ACM_UnitOfWork unitOfWork){
        for(Account account : mapOfAccount.values()){
            if(account.Core_Business_Party_Id__c!=null && mapOfBusinessTypesByAccountId.containsKey(account.Id)){
                for(Business_Types__c acctbusinessType : mapOfBusinessTypesByAccountId.get(account.Id)){
                    if(account.Core_Intel_Partner_Alliance_PartnerGroup__c==true && acctbusinessType.Business_Type_Code__c!='PTNR' && !setOfBusinessType.contains('PTNR')){
                        Business_Types__c businessType=mapOfBusineesType.get('PTNR');
                        Account_Business_Types__c accountBusinessType=new Account_Business_Types__c();
                        accountBusinessType.Account__c=account.Id;
                        accountBusinessType.Business_Types__c=businessType.Id;
                        accountBusinessType.Effective_Start_Date__c = System.today();
                        unitOfWork.registerNew(accountBusinessType);
                    }
                    if(account.Core_MDF_CoMarketingActive__c==true && acctbusinessType.Business_Type_Code__c!='SLS_PPLN' && !setOfBusinessType.contains('SLS_PPLN')){
                        Business_Types__c businessType=mapOfBusineesType.get('SLS_PPLN');
                        Account_Business_Types__c accountBusinessType=new Account_Business_Types__c();
                        accountBusinessType.Account__c=account.Id;
                        accountBusinessType.Business_Types__c=businessType.Id;
                        accountBusinessType.Effective_Start_Date__c = System.today();
                        unitOfWork.registerNew(accountBusinessType);
                    }
                }
            }
        }
    }
}