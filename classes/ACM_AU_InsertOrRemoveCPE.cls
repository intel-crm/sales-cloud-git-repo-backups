public without sharing class ACM_AU_InsertOrRemoveCPE {
    private static UCD_ACM_ServiceContracts.IAccountService accountServiceInstance = UCD_ACM_AccountService.getInstance();
    public static void insertLogic(Map<Id,Account> mapOfAccount){
        UCD_ACM_UnitOfWork unitOfWork = new UCD_ACM_UnitOfWork();
        try{
            Map<Id,List<Business_Types__c>> mapOfBusinessTypesByAccountId=accountServiceInstance.getActiveBusinessTypeForAccount(mapOfAccount.keySet());
            Map<String,Business_Types__c> mapOfBusineesType=getMapOfBusinessTypes();
            if(!mapOfBusinessTypesByAccountId.isEmpty()){
                Map<Id,List<String>> setOfBusinessType=getSetOfBusinessTypeByBusinessTypeCode(mapOfBusinessTypesByAccountId);
                if(!mapOfBusineesType.isEmpty() && !setOfBusinessType.isEmpty()){
                    checkAndInsertBusinessTypeofAccount(unitOfWork,mapOfAccount,mapOfBusinessTypesByAccountId,mapOfBusineesType,setOfBusinessType);
                }
            }
        }
        catch(Exception ex){
            UCD_ACM_Logger.error('ACM_AU_InsertOrRemoveCPE','insertLogic','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString()+' Failed Account Ids :'+mapOfAccount.keySet().toString(),'AccountIds: '+mapOfAccount.keySet().toString());
        }
        finally{
            UCD_ACM_Logger.setLogDetails();
        }
    }
    private static Map<String,Business_Types__c> getMapOfBusinessTypes(){
        Map<String,Business_Types__c> mapOfBusineesType=new  Map<String,Business_Types__c>();
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

    private static Map<Id,List<String>> getSetOfBusinessTypeByBusinessTypeCode(Map<Id,List<Business_Types__c>> mapOfBusinessTypesByAccountId){
        Map<Id,List<String>> setOfBusinessType=new Map<Id,List<String>>();
        for(Id val : mapOfBusinessTypesByAccountId.keySet()){
            for(Business_Types__c businessType : mapOfBusinessTypesByAccountId.get(val)){
                setOfBusinessType.put(val,new List<String>{businessType.Business_Type_Code__c});
            }
        }
        return setOfBusinessType.size() > 0 ? setOfBusinessType : null;
    }

    private static void checkAndInsertBusinessTypeofAccount(UCD_ACM_UnitOfWork unitOfWork,Map<Id,Account> mapOfAccount,Map<Id,List<Business_Types__c>> mapOfBusinessTypesByAccountId,Map<String,Business_Types__c> mapOfBusineesType,Map<Id,List<String>> setOfBusinessType){
        for(Account account : mapOfAccount.values()){
            if(account.Core_Business_Party_Id__c!=null && mapOfBusinessTypesByAccountId.containsKey(account.Id)){
                for(Business_Types__c acctbusinessType : mapOfBusinessTypesByAccountId.get(account.Id)){
                    if(account.Core_Intel_Partner_Alliance_PartnerGroup__c==true && acctbusinessType.Business_Type_Code__c!='PTNR' && !setOfBusinessType.get(account.Id).contains('PTNR')){
                        //Business_Types__c businessType=mapOfBusineesType.get('PTNR');
                        Account_Business_Types__c accountBusinessType=new Account_Business_Types__c();
                        accountBusinessType.Account__c=account.Id;
                        accountBusinessType.Business_Types__c=mapOfBusineesType.get('PTNR').Id;
                        accountBusinessType.Effective_Start_Date__c = System.today();
                        unitOfWork.registerNew(accountBusinessType);
                    }
                }
            }
        }
        unitOfWork.commitWork();
    }

    public static void deleteLogic(Map<String, Map<Id,Account>> mapOfdeletionAccount){
        Set<Id> ipaIds=new Set<Id>();
        Set<Id> coMarketingIds=new Set<Id>();
        if(mapOfdeletionAccount.get('IPA')!=null){
            ipaIds=mapOfdeletionAccount.get('IPA').keySet();
        }
        if(mapOfdeletionAccount.get('CoMarketing')!=null){
            coMarketingIds=mapOfdeletionAccount.get('CoMarketing').keySet();
        }
        Set<Id> finalIds=new Set<Id>();
        if(ipaIds.size()>0){
            finalIds.addAll(ipaIds);
        }
        if(coMarketingIds.size()>0){
            finalIds.addAll(coMarketingIds);
        }
        Map<Id,List<Business_Types__c>> mapOfBusinessTypesByAccountId=accountServiceInstance.getActiveBusinessTypeForAccount(finalIds);
        if(!mapOfBusinessTypesByAccountId.isEmpty()){
            deleteAccountBusinessType(mapOfdeletionAccount,mapOfBusinessTypesByAccountId);
        }
    }

    private static void deleteAccountBusinessType(Map<String, Map<Id,Account>> mapOfdeletionAccount,Map<Id,List<Business_Types__c>> mapOfBusinessTypesByAccountId){
        Set<Id> ipaAccountIds=new Set<Id>();
        Set<Id> coMarketingAccountIds=new Set<Id>();
        Set<Id> accountIds=new Set<Id>();
        List<Account_Business_Types__c> acctBusinessTypes=new List<Account_Business_Types__c>();
        List<Account_Business_Types__c> acctBusinessTypetoDelete=new List<Account_Business_Types__c>();
        Set<Id> partnerbusinessTypeIds=new Set<Id>();
        Set<Id> coMarketingbusinessTypeIds=new Set<Id>();
        Set<Id> businessTypeIds=new Set<id>();
        if(mapOfdeletionAccount.get('IPA')!=null && mapOfdeletionAccount.get('IPA').values().size()>0){
            for(Account account : mapOfdeletionAccount.get('IPA').values()){
                if(mapOfBusinessTypesByAccountId.containsKey(account.Id)){
                    for(Business_Types__c acctbusinessType : mapOfBusinessTypesByAccountId.get(account.Id)){
                        if(account.Core_Intel_Partner_Alliance_PartnerGroup__c==false && acctbusinessType.Business_Type_Code__c=='PTNR'){
                            ipaAccountIds.add(account.Id);
                            partnerbusinessTypeIds.add(acctbusinessType.Id);    
                        }
                    }
                }
            }
        }
        if(mapOfdeletionAccount.get('CoMarketing')!=null && mapOfdeletionAccount.get('CoMarketing').values().size()>0){
            for(Account account : mapOfdeletionAccount.get('CoMarketing').values()){
                if(mapOfBusinessTypesByAccountId.containsKey(account.Id)){
                    for(Business_Types__c acctbusinessType : mapOfBusinessTypesByAccountId.get(account.Id)){
                        if(account.Core_MDF_CoMarketingActive__c==false && acctbusinessType.Business_Type_Code__c=='Co_Marketing'){
                            coMarketingAccountIds.add(account.Id);
                            coMarketingbusinessTypeIds.add(acctbusinessType.Id);
                        }
                    }
                }
            }
        }
        if(ipaAccountIds.size()>0 && partnerbusinessTypeIds.size()>0){
            accountIds.addAll(ipaAccountIds);
            businessTypeIds.addAll(partnerbusinessTypeIds);
        }
        if(coMarketingAccountIds.size()>0 && coMarketingbusinessTypeIds.size()>0){
            accountIds.addAll(coMarketingAccountIds);
            businessTypeIds.addAll(coMarketingbusinessTypeIds);
        }
        acctBusinessTypes=[Select Id,Account__c,Business_Types__c,Effective_End_Date__c from Account_Business_Types__c Where Account__c IN :accountIds AND Business_Types__c IN :businessTypeIds];
        for(Account_Business_Types__c acctBusinessType : acctBusinessTypes){
            if(ipaAccountIds.contains(acctBusinessType.Account__c) && partnerbusinessTypeIds.contains(acctBusinessType.Business_Types__c)){
                acctBusinessType.Effective_End_Date__c=System.today();
                acctBusinessTypetoDelete.add(acctBusinessType);
            }
            if(coMarketingAccountIds.contains(acctBusinessType.Account__c) && coMarketingbusinessTypeIds.contains(acctBusinessType.Business_Types__c)){
                acctBusinessType.Effective_End_Date__c=System.today();
                acctBusinessTypetoDelete.add(acctBusinessType);
            }
        }
        if(acctBusinessTypetoDelete.size()>0){
            update acctBusinessTypetoDelete;
        }
    }
}