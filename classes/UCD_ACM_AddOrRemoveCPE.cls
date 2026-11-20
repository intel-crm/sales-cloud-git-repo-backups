public without sharing class UCD_ACM_AddOrRemoveCPE {
    
    public static AccountBusinessTypesAndInsertedOrDeletedRecord addCpeToAccount(List<Core_ACM_Account_Staging__c> accStaging){
        AccountBusinessTypesAndInsertedOrDeletedRecord accountWrapper = new AccountBusinessTypesAndInsertedOrDeletedRecord();
        Set<Id> accountIdSet = new Set<Id>();
        try{
            List<Account_Business_Types__c> acctBusinessTypeToInsert=new List<Account_Business_Types__c>();
            List<Account_Business_Types__c> acctBusinessTypeToUpdate = new List<Account_Business_Types__c>();
            Map<String,Business_Types__c> mapOfBusineesType = getMapOfBusinessTypes();
            List<Core_ACM_Account_Staging__c> accStagingToCancel = new List<Core_ACM_Account_Staging__c>();
            for(Core_ACM_Account_Staging__c stag : accStaging){
                accountIdSet.add(stag.AccountId__c);
            }
            Map<Id,Map<String,Id>> mapOfBusinessTypesByAccountId = UCD_ACM_AddOrRemoveCPE.getActiveBusinessTypeForAccount(accountIdSet);

            for(Core_ACM_Account_Staging__c stag : accStaging){
                if(mapOfBusinessTypesByAccountId == null || mapOfBusinessTypesByAccountId.get(stag.AccountId__c) == null ){
                    Account_Business_Types__c accountBusinessType = UCD_ACM_AddOrRemoveCPE.createAccountBusinessType(stag.AccountId__c,mapOfBusineesType.get(stag.Account_Action_Refrence__c).Id,stag.Id,null);
                    acctBusinessTypeToInsert.add(accountBusinessType);
                }
                else {
                    if(mapOfBusinessTypesByAccountId.get(stag.AccountId__c) != null && mapOfBusinessTypesByAccountId.get(stag.AccountId__c).get(stag.Account_Action_Refrence__c) == null){
                        Account_Business_Types__c accountBusinessType = UCD_ACM_AddOrRemoveCPE.createAccountBusinessType(stag.AccountId__c,mapOfBusineesType.get(stag.Account_Action_Refrence__c).Id,stag.Id,null);
                        acctBusinessTypeToInsert.add(accountBusinessType);
                    }else if(mapOfBusinessTypesByAccountId.get(stag.AccountId__c) != null && mapOfBusinessTypesByAccountId.get(stag.AccountId__c).get(stag.Account_Action_Refrence__c) != null){
                        Account_Business_Types__c accountBusinessType = UCD_ACM_AddOrRemoveCPE.createAccountBusinessType(stag.AccountId__c,null,stag.Id,mapOfBusinessTypesByAccountId.get(stag.AccountId__c).get(stag.Account_Action_Refrence__c));
                        acctBusinessTypeToUpdate.add(accountBusinessType);
                    }
                }
            }
            if(!acctBusinessTypeToInsert.isEmpty()){
                Database.SaveResult[] insertedCPE = database.insert(acctBusinessTypeToInsert,false);
                accountWrapper.accountBusinessTypes = acctBusinessTypeToInsert;//System.debug('insertd : '+insertedCPE);
                accountWrapper.insertedResult = insertedCPE;
                //accountWrapper.accStagingToCancel = accStagingToCancel;
                //accountWrapper.businessTypeMap = acctBusinessTypeIdWithCode;
            }
            if(!acctBusinessTypeToUpdate.isEmpty()){
                Database.SaveResult[] updatedCPE = database.update(acctBusinessTypeToUpdate,false);
                accountWrapper.updatedAccountBusinessTypes = acctBusinessTypeToUpdate;
                accountWrapper.updatedResult = updatedCPE;
            }
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_AddOrRemoveCPE','addCpeToAccount','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),'ACM Account StgingIds: '+accountIdSet.toString());
        }
        finally{
            UCD_ACM_Logger.setLogDetails();
        }
        
        return accountWrapper;

    }

    public static AccountBusinessTypesAndInsertedOrDeletedRecord deleteCpeToAccount(List<Core_ACM_Account_Staging__c> accStaging){
        AccountBusinessTypesAndInsertedOrDeletedRecord accountWrapper = new AccountBusinessTypesAndInsertedOrDeletedRecord();
        Set<Id> accountIdSet = new Set<Id>();
        try{
            Set<String> businessTypeCodeSet = new Set<String>();
            List<Account_Business_Types__c> acctBusinessTypeToDelete = new List<Account_Business_Types__c>();
            List<Core_ACM_Account_Staging__c> accStagingToCancel = new List<Core_ACM_Account_Staging__c>();

            for(Core_ACM_Account_Staging__c accStag : accStaging){
                accountIdSet.add(accStag.AccountId__c);
                businessTypeCodeSet.add(accStag.Account_Action_Refrence__c);
            }
            Map<Id,Map<String,Id>> mapOfBusinessTypesByAccountId = UCD_ACM_AddOrRemoveCPE.getActiveBusinessTypeForAccount(accountIdSet);
            
            for(Core_ACM_Account_Staging__c accStag : accStaging){
                if(mapOfBusinessTypesByAccountId != null && mapOfBusinessTypesByAccountId.get(accStag.AccountId__c) != null && mapOfBusinessTypesByAccountId.get(accStag.AccountId__c).get(accStag.Account_Action_Refrence__c) != null){
                    Account_Business_Types__c businessTypes = new Account_Business_Types__c();
                    businessTypes.Id = mapOfBusinessTypesByAccountId.get(accStag.AccountId__c).get(accStag.Account_Action_Refrence__c);
                    businessTypes.Account_Staging_Id__c = accStag.Id;
                    acctBusinessTypeToDelete.add(businessTypes);
                }else{
                    Core_ACM_Account_Staging__c staging = new Core_ACM_Account_Staging__c();
                    staging.Id = accStag.Id;
                    staging.Core_Status__c = 'CANCELLED';
                    accStagingToCancel.add(staging);
                }

            }

            if(!acctBusinessTypeToDelete.isEmpty() || !accStagingToCancel.isEmpty()){
                Database.DeleteResult[] deletedCpe = database.delete(acctBusinessTypeToDelete,false);
                accountWrapper.deletedResult = deletedCpe;
                accountWrapper.accountBusinessTypes = acctBusinessTypeToDelete;
                accountWrapper.accStagingToCancel = accStagingToCancel;
            }
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_AddOrRemoveCPE','deleteCpeToAccount','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),'ACM Account StgingIds: '+accountIdSet.toString());
        }
        finally{
            UCD_ACM_Logger.setLogDetails();
        }
        return accountWrapper;
    }

    private static Account_Business_Types__c createAccountBusinessType(Id accId,Id businessTypeId,Id stagingId,Id accBusinessTypeId){
        Account_Business_Types__c accountBusinessType = new Account_Business_Types__c();
        accountBusinessType.Account__c = accId;
        if(businessTypeId != null){
            accountBusinessType.Business_Types__c = businessTypeId;
        }
        if(accBusinessTypeId != null){
            accountBusinessType.Id = accBusinessTypeId;
        }
        accountBusinessType.Effective_Start_Date__c = System.today();
        accountBusinessType.Account_Staging_Id__c = stagingId;
        return accountBusinessType;
    }

    public static Map<Id,Map<String,Id>> getActiveBusinessTypeForAccount(Set<Id> accountIdSet){
        List<Account_Business_Types__c> activeAccountBusinessType = [SELECT Account__c,Effective_Start_Date__c,Business_Types__c,Business_Types__r.Business_Type_Code__c,Business_Types__r.Is_Active__c FROM Account_Business_Types__c Where Account__c IN : accountIdSet AND Business_Types__r.Is_Active__c = true];
        Map<Id,Map<String,Id>> accActiveBusinessType = new Map<Id,Map<String,Id>>();
        if(activeAccountBusinessType.size()>0){
            for(Account_Business_Types__c businessType : activeAccountBusinessType){
                if(accActiveBusinessType.get(businessType.Account__c) == null ){
                    accActiveBusinessType.put(businessType.Account__c,new Map<String,Id>{businessType.Business_Types__r.Business_Type_Code__c => businessType.Id});
                }else{
                    accActiveBusinessType.get(businessType.Account__c).put(businessType.Business_Types__r.Business_Type_Code__c, businessType.Id);                }
            }
        }
        return accActiveBusinessType.size() > 0 ? accActiveBusinessType : null;
    }

    
    public static Map<String,Business_Types__c> getMapOfBusinessTypes(){
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

    public class AccountBusinessTypesAndInsertedOrDeletedRecord{
        public List<Account_Business_Types__c> accountBusinessTypes;
        public Database.SaveResult[] insertedResult;
        public List<Account_Business_Types__c> updatedAccountBusinessTypes;
        public Database.SaveResult[] updatedResult;
        public Database.DeleteResult[] deletedResult;
        public List<Core_ACM_Account_Staging__c> accStagingToCancel;
    }

}