public without sharing class UCD_ACM_CompWatchListTriggerHandler {
    private static UCD_ACM_ServiceContracts.IAccountService accountServiceInstance = UCD_ACM_AccountService.getInstance();
    
    public static void triggerPlatformEventOnInsert(System.TriggerOperation operation,List<Core_Account_Compliance_Watch_List__c> complianceWatchLists,Map<Id,Core_Account_Compliance_Watch_List__c> complianceWatchListById){
        Set<Id> accountIds = new Set<Id>();
        UCD_ACM_UnitOfWork unitOfWork = new UCD_ACM_UnitOfWork();
        try{
            Set<Id> accountIdsToPublish = new Set<Id>();

            For(Core_Account_Compliance_Watch_List__c complianceWatchList :complianceWatchLists){

                if(complianceWatchList.Core_Account_Id__c!=null ){
                    if(operation == System.TriggerOperation.AFTER_INSERT){
                        accountIds.add(complianceWatchList.Core_Account_Id__c);
                    }else if(operation == System.TriggerOperation.AFTER_UPDATE && ((complianceWatchList.Core_Account_Id__c != complianceWatchListById.get(complianceWatchList.Id).Core_Account_Id__c) ||
                                                                                   (complianceWatchList.Core_Trusted_Source__c != complianceWatchListById.get(complianceWatchList.Id).Core_Trusted_Source__c) || 
                                                                                   (complianceWatchList.Core_Effective_End_Date__c != complianceWatchListById.get(complianceWatchList.Id).Core_Effective_End_Date__c) ||
                                                                                   (complianceWatchList.Core_Effective_Start_Date__c != complianceWatchListById.get(complianceWatchList.Id).Core_Effective_Start_Date__c) ||
                                                                                   (complianceWatchList.Core_Type__c != complianceWatchListById.get(complianceWatchList.Id).Core_Type__c))){
                                                                                       accountIds.add(complianceWatchList.Core_Account_Id__c);
                                                                                   }
                }
            }


            if(accountIds.size() > 0){ 
                List<Account> accounts = UCD_ACM_AccountService.getAccountsToPublishEvent(accountIds);
                if(accounts != null && accounts.size() >0){
                    for(Account account :accounts){
                        if(account.RecordTypeId!=UCD_ACM_ConstantUtil.acctRTRejected){
                            accountIdsToPublish.add(account.Id);
                        }
                    }
                }
            }
            if(accountIdsToPublish.size() > 0){                  
                    UCD_ACM_Common.updateACMIntegrationMessage(unitOfWork, accountIdsToPublish);
            }
        

        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_CompWatchListTriggerHandler','triggerPlatformEventOnInsert','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString()+' UserName: '+UserInfo.getUserName(),'AccountIds: '+accountIds.toString());
        }
        finally{
            unitOfWork.commitWork();
            UCD_ACM_Logger.setLogDetails();
        }
    }


    
}