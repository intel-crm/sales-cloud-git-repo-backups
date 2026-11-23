public class ACM_InsertRemoveCPE_Batch implements Database.Batchable<sObject> {
    Id intelAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    Datetime dt=System.now().addMinutes(-60);
    public Boolean retryProcess = false; //story US661961 DEVELOPMENT ONLY : Technical Debt : KPI Architecture fixes updated by Sanket Mahajan
    public integer failedRecordsCounter = 0;
    public static Set<Id> failedAccountIds=new Set<Id>();
    public integer retryCount=0;

    public ACM_InsertRemoveCPE_Batch (){
        retryProcess =false;
    }
    public ACM_InsertRemoveCPE_Batch (String s){
        retryProcess = true;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = '';
        if(!retryProcess){
            query='Select Id,Name,Core_Business_Party_Id__c,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_MDF_CoMarketingActive__c,RecordTypeId From Account Where Core_Business_Party_Id__c!=null AND RecordTypeId =:intelAccountRTId AND Id IN(Select AccountId From AccountHistory Where (Field=\'Core_Intel_Partner_Alliance_PartnerGroup__c\' OR Field=\'Core_MDF_CoMarketingActive__c\') AND CreatedDate>=:dt)';
        }
        else{
            query='Select Id,Name,Core_Business_Party_Id__c,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_MDF_CoMarketingActive__c,RecordTypeId From Account Where Core_Business_Party_Id__c!=null AND RecordTypeId =:intelAccountRTId AND Id IN:failedAccountIds';
        }
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Account> accounts){
        if(!accounts.isEmpty()){
            Map<Id,Account> mapOfAddCpeAccount=new Map<Id,Account>();
            Map<String, Map<Id,Account>> mapOfSoftDeleteCpeAccount=new Map<String, Map<Id,Account>>();
            Map<String, Map<Id,Account>> mapOfDeleteCpeAccount=new Map<String, Map<Id,Account>>();
            Set<String> businessPartyIds=new Set<String>();
            Map<String,List<Account> > accountsByBpId = new Map<String,List<Account> >();
            List<Account> accountswithBpid=new List<Account>();
            Boolean flagForIPA = true;
            Boolean flagForCoMarketing = true;
            Boolean flagForSalesPipeline=true;
            System.debug('@@$accounts '+accounts);
            for(Account account : accounts){
                if(account.Core_Intel_Partner_Alliance_PartnerGroup__c==true || account.Core_MDF_CoMarketingActive__c==true){
                    mapOfAddCpeAccount.put(account.Id,account);
                }
            }
            System.debug('@@$mapOfAccount '+mapOfAddCpeAccount);
            if(!mapOfAddCpeAccount.isEmpty() && mapOfAddCpeAccount!=null){
                System.debug('@@#Enteracc');
                ACM_InsertOrRemoveCpe.insertLogic(mapOfAddCpeAccount);
            }
            for(Account account : accounts){
                businessPartyIds.add(account.Core_Business_Party_Id__c);
            }
            accountswithBpid=getAccountsWithBpid(businessPartyIds);//recordtype check
            System.debug('@@$accountswithBpid '+accountswithBpid);
            if(!accountswithBpid.isEmpty()){
                for(Account account:accountswithBpid){
                    if(!accountsByBpId.containsKey(account.Core_Business_Party_Id__c)){
                        accountsByBpId.put(account.Core_Business_Party_Id__c,new List<Account>{account});
                        System.debug('@@$insideaccountswithBpid '+accountsByBpId);
                    }else{
                        List<Account> accountsFromMap = accountsByBpId.get(account.Core_Business_Party_Id__c);
                        accountsFromMap.add(account);
                    }
                }
            }
            System.debug('@@$accountsByBpId '+accountsByBpId);
            for(Account account:accounts){
                if(!accountsByBpId.isEmpty() && accountsByBpId!=null && accountsByBpId.containsKey(account.Core_Business_Party_Id__c)){
                    flagForIPA = checkForIPA(accountsByBpId.get(account.Core_Business_Party_Id__c));
                    System.debug('@@flagForIPA '+flagForIPA);
                    flagForCoMarketing = checkForComarketing(accountsByBpId.get(account.Core_Business_Party_Id__c));
                    System.debug('@@flagForCoMarketing '+flagForCoMarketing);
                    flagForSalesPipeline = checkForSalesPipeline(accountsByBpId.get(account.Core_Business_Party_Id__c));
                    System.debug('@@flagForSalesPipeline '+flagForSalesPipeline);

                    if(!flagForIPA ){
                        if(mapOfSoftDeleteCpeAccount.get('IPA')!=null){
                            mapOfSoftDeleteCpeAccount.get('IPA').putAll( new Map<Id, Account>(accountsByBpId.get(account.Core_Business_Party_Id__c)));
                        }
                        else{
                            mapOfSoftDeleteCpeAccount.put('IPA',(new Map<Id, Account>(accountsByBpId.get(account.Core_Business_Party_Id__c))));
                        }
                        System.debug('@@#mapOfdeletionAccountNew '+mapOfSoftDeleteCpeAccount);
                    }
                    else{
                        if(mapOfDeleteCpeAccount.get('IPA')!=null){
                            mapOfDeleteCpeAccount.get('IPA').putAll( new Map<Id, Account>(accountsByBpId.get(account.Core_Business_Party_Id__c)));
                        }
                        else{
                            mapOfDeleteCpeAccount.put('IPA',(new Map<Id, Account>(accountsByBpId.get(account.Core_Business_Party_Id__c))));
                        }
                    }

                    if(!flagForCoMarketing){
                        if(mapOfSoftDeleteCpeAccount.get('CoMarketing')!=null){
                            mapOfSoftDeleteCpeAccount.get('CoMarketing').putAll( new Map<Id, Account>(accountsByBpId.get(account.Core_Business_Party_Id__c)));
                        }
                        else{
                            mapOfSoftDeleteCpeAccount.put('CoMarketing',(new Map<Id, Account>(accountsByBpId.get(account.Core_Business_Party_Id__c))));
                        }
                        System.debug('@@#mapOfdeletionAccountNewComarket '+mapOfSoftDeleteCpeAccount);
                    }
                    else{
                        if(mapOfDeleteCpeAccount.get('CoMarketing')!=null){
                            mapOfDeleteCpeAccount.get('CoMarketing').putAll( new Map<Id, Account>(accountsByBpId.get(account.Core_Business_Party_Id__c)));
                        }
                        else{
                            mapOfDeleteCpeAccount.put('CoMarketing',(new Map<Id, Account>(accountsByBpId.get(account.Core_Business_Party_Id__c))));
                        }
                    } 
                    
                    if(!flagForSalesPipeline){
                        if(mapOfSoftDeleteCpeAccount.get('OppManagement')!=null){
                            mapOfSoftDeleteCpeAccount.get('OppManagement').putAll( new Map<Id, Account>(accountsByBpId.get(account.Core_Business_Party_Id__c)));
                        }else{
                            mapOfSoftDeleteCpeAccount.put('OppManagement',(new Map<Id, Account>(accountsByBpId.get(account.Core_Business_Party_Id__c))));
                        }
                        System.debug('@@#mapOfdeletionAccountopp '+mapOfSoftDeleteCpeAccount);
                    }
                    else{
                        if(mapOfDeleteCpeAccount.get('OppManagement')!=null){
                            mapOfDeleteCpeAccount.get('OppManagement').putAll( new Map<Id, Account>(accountsByBpId.get(account.Core_Business_Party_Id__c)));
                        }
                        else{
                            mapOfDeleteCpeAccount.put('OppManagement',(new Map<Id, Account>(accountsByBpId.get(account.Core_Business_Party_Id__c))));
                        }
                    }
                }
            }
            System.debug('@@$mapOfSoftDeleteCpeAccount '+mapOfSoftDeleteCpeAccount);
            if(!mapOfSoftDeleteCpeAccount.isEmpty() && mapOfSoftDeleteCpeAccount!=null){
                System.debug('@@#Entereffectiveenddate');
                ACM_InsertOrRemoveCpe.deleteLogic(mapOfSoftDeleteCpeAccount,'softDelete');
            }
            System.debug('@@$mapOfDeleteCpeAccount '+mapOfDeleteCpeAccount);
            if(!mapOfDeleteCpeAccount.isEmpty() && mapOfDeleteCpeAccount!=null){
                System.debug('@@#Enteraccdelete');
                ACM_InsertOrRemoveCpe.deleteLogic(mapOfDeleteCpeAccount,'hardDelete');
            }
            if(!failedAccountIds.isEmpty()){
                failedRecordsCounter++;
            }
        }
    }
    public void finish(Database.BatchableContext BC){
        if(failedRecordsCounter>0 && retryCount<3){
            retryCount++;
            ACM_InsertRemoveCPE_Batch cpeBatchJob=new ACM_InsertRemoveCPE_Batch('failed');
            Database.executeBatch(cpeBatchJob);
        }
    }

    private List<Account> getAccountsWithBpid(Set<String> businessPartyIds){
        List<Account> accountswithBpid=[Select Id,Name,Core_Business_Party_Id__c,Core_Intel_Partner_Alliance_PartnerGroup__c, 
        Core_MDF_CoMarketingActive__c
        from Account 
        where Core_Business_Party_Id__c IN : businessPartyIds
        AND RecordTypeId =:intelAccountRTId
        ];
        return accountswithBpid;
    }
    private Boolean checkForIPA(List<Account> listOfAccount){
        System.debug('$lstAcc '+listOfAccount);
        for(Account account : listOfAccount){
            if(account.Core_Intel_Partner_Alliance_PartnerGroup__c==true){
                return true;
            }
        }
        System.debug('@Entercheckipa');
        return false;
    }

    private Boolean checkForComarketing(List<Account> listOfAccount){
        System.debug('$lstAcccom '+listOfAccount);
        for(Account account : listOfAccount){
            if(account.Core_MDF_CoMarketingActive__c==true){
                return true;
            }
        }
        System.debug('@Entercheckcom');
        return false;
    }

    private Boolean checkForSalesPipeline(List<Account> listOfAccount){
        System.debug('$lstAcccom '+listOfAccount);
        for(Account account : listOfAccount){
            /*if(account.Core_Opportunity_Account__c==true){
                return true;
            }*/
        }
        System.debug('@Entercheckopp');
        return false;
    }
}