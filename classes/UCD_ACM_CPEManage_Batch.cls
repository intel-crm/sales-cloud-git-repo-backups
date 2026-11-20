public without sharing class UCD_ACM_CPEManage_Batch implements Database.Batchable<sObject>,Database.Stateful {
    private Set<Id> sucessStagingIds = new Set<Id>();
    Map<Id,Core_ACM_Account_Staging__c> failedStagingRecMap = new Map<Id,Core_ACM_Account_Staging__c>();
    private Set<Id> failedRecordIdToRetry = new Set<Id>();
    private List<Core_ACM_Account_Staging__c> stagingToCancel = new List<Core_ACM_Account_Staging__c>();
    private Map<Id,Decimal> accStageIdToTryCount = new Map<Id,Decimal>();
    public UCD_ACM_CPEManage_Batch() {
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
            return Database.getQueryLocator([SELECT Id,Name,AccountId__c,Account_Action_Refrence__c,Core_Action__c,Core_Status__c,Status_Details__c,Core_Retry_Counter__c FROM Core_ACM_Account_Staging__c WHERE (Core_Status__c = 'NEW' OR (Core_Status__c = 'FAILED' AND Core_Retry_Counter__c < 3))  AND (Core_Action__c = 'ADD_CPE' OR Core_Action__c= 'REMOVE_CPE')]);
    }
    public void execute(Database.BatchableContext BC, List<Core_ACM_Account_Staging__c> accountStaging){
        try{
            List<Core_ACM_Account_Staging__c> accStagingForCPEAddition = new List<Core_ACM_Account_Staging__c>();
            List<Core_ACM_Account_Staging__c> accStagingForCPERemoval = new List<Core_ACM_Account_Staging__c>();

            UCD_ACM_AddOrRemoveCPE.AccountBusinessTypesAndInsertedOrDeletedRecord accountWrapperForAddingCPE = new UCD_ACM_AddOrRemoveCPE.AccountBusinessTypesAndInsertedOrDeletedRecord();
            UCD_ACM_AddOrRemoveCPE.AccountBusinessTypesAndInsertedOrDeletedRecord accountWrapperForRemovingCPE = new UCD_ACM_AddOrRemoveCPE.AccountBusinessTypesAndInsertedOrDeletedRecord();
            for(Core_ACM_Account_Staging__c accStag : accountStaging){
                accStageIdToTryCount.put(accStag.Id,accStag.Core_Retry_Counter__c);
                if(accStag.Core_Action__c == 'ADD_CPE' && !String.isBlank(accStag.Account_Action_Refrence__c)){
                    accStagingForCPEAddition.add(accStag);
                }
                else if(accStag.Core_Action__c == 'REMOVE_CPE' && !String.isBlank(accStag.Account_Action_Refrence__c)){
                    accStagingForCPERemoval.add(accStag);
                }
            }


            //Insert CPE For Required Account 
            if(!accStagingForCPEAddition.isEmpty()){
                accountWrapperForAddingCPE = UCD_ACM_AddOrRemoveCPE.addCpeToAccount(accStagingForCPEAddition);
                if(accountWrapperForAddingCPE != null && accountWrapperForAddingCPE.insertedResult != null && !accountWrapperForAddingCPE.insertedResult.isEmpty()){
                    for (Integer i = 0; i < accountWrapperForAddingCPE.insertedResult.size(); i++) {
                       
                        if (accountWrapperForAddingCPE.insertedResult[i].isSuccess()) {
                            sucessStagingIds.add(accountWrapperForAddingCPE.accountBusinessTypes[i].Account_Staging_Id__c);
                        }else{
                            Core_ACM_Account_Staging__c staging = UCD_ACM_CPEManage_Batch.setAttributesACMCPEStaging(accountWrapperForAddingCPE.accountBusinessTypes[i].Account_Staging_Id__c,JSON.serialize(accountWrapperForAddingCPE.insertedResult[i].getErrors()),accStageIdToTryCount.get(accountWrapperForAddingCPE.accountBusinessTypes[i].Account_Staging_Id__c));
                            failedStagingRecMap.put(staging.Id,staging);
                        }
                    }
                }
                if(accountWrapperForAddingCPE != null && accountWrapperForAddingCPE.updatedResult != null && !accountWrapperForAddingCPE.updatedResult.isEmpty()){
                    for (Integer i = 0; i < accountWrapperForAddingCPE.updatedResult.size(); i++) {
                        if (accountWrapperForAddingCPE.updatedResult[i].isSuccess()) {
                            sucessStagingIds.add(accountWrapperForAddingCPE.updatedAccountBusinessTypes[i].Account_Staging_Id__c);
                        }else{
                            Core_ACM_Account_Staging__c staging = UCD_ACM_CPEManage_Batch.setAttributesACMCPEStaging(accountWrapperForAddingCPE.accountBusinessTypes[i].Account_Staging_Id__c,JSON.serialize(accountWrapperForAddingCPE.updatedResult[i].getErrors()),accStageIdToTryCount.get(accountWrapperForAddingCPE.accountBusinessTypes[i].Account_Staging_Id__c));
                            failedStagingRecMap.put(staging.Id,staging);
                        }
                    }
                }
            }

            //Delete CPE For Required Account 
            if(!accStagingForCPERemoval.isEmpty()){
                accountWrapperForRemovingCPE = UCD_ACM_AddOrRemoveCPE.deleteCpeToAccount(accStagingForCPERemoval);
                if(accountWrapperForRemovingCPE.accStagingToCancel != null){
                    stagingToCancel.addAll(accountWrapperForRemovingCPE.accStagingToCancel);
                }
                if(accountWrapperForRemovingCPE != null && accountWrapperForRemovingCPE.deletedResult != null && !accountWrapperForRemovingCPE.deletedResult.isEmpty()){
                    for (Integer i = 0; i < accountWrapperForRemovingCPE.deletedResult.size(); i++) {
                        if (accountWrapperForRemovingCPE.deletedResult[i].isSuccess()) {
                            sucessStagingIds.add(accountWrapperForRemovingCPE.accountBusinessTypes[i].Account_Staging_Id__c);
                        }else{
                            Core_ACM_Account_Staging__c staging = UCD_ACM_CPEManage_Batch.setAttributesACMCPEStaging(accountWrapperForAddingCPE.accountBusinessTypes[i].Account_Staging_Id__c,JSON.serialize(accountWrapperForAddingCPE.deletedResult[i].getErrors()),accStageIdToTryCount.get(accountWrapperForAddingCPE.accountBusinessTypes[i].Account_Staging_Id__c));
                            failedStagingRecMap.put(staging.Id,staging);
                        }
                    }
                }
            }
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_CPEManage_Batch','execute','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),'ACM Account Staging: '+accountStaging.toString());
        }
        finally{
            UCD_ACM_Logger.setLogDetails();
        }
    }
    public void finish(Database.BatchableContext BC){
        List<Core_ACM_Account_Staging__c> accStagtoUpdate = new List<Core_ACM_Account_Staging__c>();
        if(!sucessStagingIds.isEmpty()){
            for(Core_ACM_Account_Staging__c stag : [SELECT Id,AccountId__c,Account_Action_Refrence__c,Core_Action__c,Core_Status__c,Status_Details__c,Core_Retry_Counter__c FROM Core_ACM_Account_Staging__c WHERE Id IN : sucessStagingIds ]){
                stag.Core_Status__c = 'COMPLETED';
                if(stag.Core_Retry_Counter__c != null){
                    stag.Core_Retry_Counter__c = stag.Core_Retry_Counter__c + 1;
                }
                else{
                    stag.Core_Retry_Counter__c = 0;
                }
                accStagtoUpdate.add(stag);
            }
        }
        if(!failedStagingRecMap.isEmpty()){
            update failedStagingRecMap.values();
        }
        if(!accStagtoUpdate.isEmpty()){
                update accStagtoUpdate;
        }
        if(!stagingToCancel.isEmpty()){
            update stagingToCancel;
        }
    }
    private static Core_ACM_Account_Staging__c setAttributesACMCPEStaging(Id stagId,String statusDetail,Decimal retryCount){
        Core_ACM_Account_Staging__c staging = new Core_ACM_Account_Staging__c();
        staging.Id = stagId;
        staging.Status_Details__c = statusDetail != null ? statusDetail : '';
        staging.Core_Status__c = 'FAILED';
        if(retryCount != null){
            staging.Core_Retry_Counter__c = retryCount + 1;
        }
        else{
            staging.Core_Retry_Counter__c = 0;
        }
        return staging;
    }

}