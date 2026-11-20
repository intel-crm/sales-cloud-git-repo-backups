public without sharing class UCD_ACM_AccountBusinessTypeHandler {
    private static UCD_ACM_ServiceContracts.IAccountService accountServiceInstance = UCD_ACM_AccountService.getInstance();

    public static void triggerPlatformEventOnInsert(System.TriggerOperation operation,List<Account_Business_Types__c> AccountBusinessTypes,Map<Id,Account_Business_Types__c> accountBusinessTypeById){
        Set<Id> accountIds = new Set<Id>();
        Map<Id,Business_Types__c> businessTypeById = new Map<Id,Business_Types__c>();
        Set<Id> businessTypeIds = new Set<Id>();
        UCD_ACM_UnitOfWork unitOfWork = new UCD_ACM_UnitOfWork();
        Set<Id> accountIdsToPublish = new Set<Id>();


        try{
            if(AccountBusinessTypes.size() > 0){
                For(Account_Business_Types__c accountBusinessType : AccountBusinessTypes){
                    businessTypeIds.add(accountBusinessType.Business_Types__c);
                }
            }   
            // Get Map of Business Type By Id
            businessTypeById = accountServiceInstance.getBusinessTypeMap(businessTypeIds,'Id,Business_Type_Code__c');
            List<String> businessTypeNames = System.Label.UCD_ACM_Rebates_Business_Type.split(',');
            For(Account_Business_Types__c AccountBusinessType :AccountBusinessTypes){
                if(businessTypeNames.contains(businessTypeById.get(AccountBusinessType.Business_Types__c).Business_Type_Code__c)){
                    if(AccountBusinessType.Account__c != null ){
                        if(operation == System.TriggerOperation.AFTER_INSERT){
                            accountIds.add(AccountBusinessType.Account__c);
                        }else if(operation == System.TriggerOperation.AFTER_UPDATE && ((AccountBusinessType.Account__c != accountBusinessTypeById.get(AccountBusinessType.Id).Account__c) ||
                                                                                   (AccountBusinessType.Business_Types__c != null && (AccountBusinessType.Business_Types__c != accountBusinessTypeById.get(AccountBusinessType.Id).Business_Types__c)) ||
                                                                                   (AccountBusinessType.Status__c != null && (AccountBusinessType.Status__c != accountBusinessTypeById.get(AccountBusinessType.Id).Status__c)) ||
                                                                                   (AccountBusinessType.Status_Reason__c != null && (AccountBusinessType.Status_Reason__c != accountBusinessTypeById.get(AccountBusinessType.Id).Status_Reason__c)) || 
                                                                                   (AccountBusinessType.Effective_End_Date__c != accountBusinessTypeById.get(AccountBusinessType.Id).Effective_End_Date__c) || (AccountBusinessType.Effective_Start_Date__c != null && (AccountBusinessType.Effective_Start_Date__c != accountBusinessTypeById.get(AccountBusinessType.Id).Effective_Start_Date__c)))){
                                                                                       accountIds.add(AccountBusinessType.Account__c);
                                                                                   }
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
        }
        catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_AccountBusinessTypeHandler','triggerPlatformEventOnInsert','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString()+' UserName: '+UserInfo.getUserName(),'AccountIds: '+accountIds.toString());
        } finally{
            unitOfWork.commitWork();
            UCD_ACM_Logger.setLogDetails();
        }
    }
    
    
    
    /*
* description : Conditional data sync to Reltio MDM
* params : List<Account> newValues, List<Account> oldvalues, TriggerOperation
* return : NA
* author and date : harshalx.sunil.gosavi@intel.com, 30 Dec. 2021
*/
    public static void triggerReltioSync(System.TriggerOperation operation, List<Account_Business_Types__c> newAccountBusinessTypes, Map<Id,Account_Business_Types__c> mNewAccountBusinessTypes, List<Account_Business_Types__c> oldAccountBusinessTypes, Map<Id,Account_Business_Types__c> mOldAccountBusinessTypes){
        String events = System.Label.Account_Business_Type_Reltio_Trigger_Sync_Event;
        List<String> newEvents = String.IsNotEmpty(events)? events.split(','): new List<String>();
        if(newEvents.contains(string.valueof(operation))){ 
            List<Account_Business_Types__c> rNewAccountBusinessTypes = new List<Account_Business_Types__c>();
            List<Account_Business_Types__c> rOldAccountBusinessTypes = new List<Account_Business_Types__c>();
            Map<Id,Account_Business_Types__c> rNewMapAccountBusinessType = new Map<Id,Account_Business_Types__c>();
            Map<Id,Account_Business_Types__c> rOldMapAccountBusinessType = new Map<Id,Account_Business_Types__c>();
            Map<Id,Business_Types__c> businessTypeById = new Map<Id,Business_Types__c>();
            Set<Id> businessTypeIds = new Set<Id>();
            try{
                if(newAccountBusinessTypes!=null && !newAccountBusinessTypes.isEmpty()){
                    For(Account_Business_Types__c accountBusinessType : newAccountBusinessTypes){
                        businessTypeIds.add(accountBusinessType.Business_Types__c);
                    }
                    // Get Map of Business Type By Id
                    businessTypeById = accountServiceInstance.getBusinessTypeMap(businessTypeIds,'Id,Business_Type_Code__c');
                    List<String> businessTypeNames = System.Label.UCD_ACM_Business_Type.split(',');
                    
                    if((operation == System.TriggerOperation.AFTER_INSERT || operation == System.TriggerOperation.AFTER_UPDATE) && businessTypeById != null){
                        For(Account_Business_Types__c accountBusinessType : newAccountBusinessTypes){
                            // Check Account Customer Aggregation is Not Null
                            if(businessTypeNames.contains(businessTypeById.get(accountBusinessType.Business_Types__c).Business_Type_Code__c)){
                                rNewAccountBusinessTypes.add(accountBusinessType);
                                rNewMapAccountBusinessType.put(accountBusinessType.Id,accountBusinessType);
                            }
                        }
                        if(rNewAccountBusinessTypes.size() > 0){
                            rtsync.TriggerHandler.handle(operation, rNewAccountBusinessTypes, rNewMapAccountBusinessType, oldAccountBusinessTypes, mOldAccountBusinessTypes);
                        }
                    }
                }
                //System.debug('#@oldAccountBusinessTypes '+oldAccountBusinessTypes);
                if((operation == System.TriggerOperation.BEFORE_DELETE || operation == System.TriggerOperation.AFTER_DELETE) && (oldAccountBusinessTypes!=null && !oldAccountBusinessTypes.isEmpty())){
                    for(Account_Business_Types__c accountBusinessType : oldAccountBusinessTypes){
                        businessTypeIds.add(accountBusinessType.Business_Types__c);
                    }
                    businessTypeById = accountServiceInstance.getBusinessTypeMap(businessTypeIds,'Id,Business_Type_Code__c');
                    //System.debug('#@$businessTypeById '+businessTypeById);
                    List<String> businessTypeNames = System.Label.UCD_ACM_Business_Type.split(',');
                    if(businessTypeById != null){
                        for(Account_Business_Types__c accountBusinessType : oldAccountBusinessTypes){
                            if(businessTypeNames.contains(businessTypeById.get(accountBusinessType.Business_Types__c).Business_Type_Code__c)){
                                rOldAccountBusinessTypes.add(accountBusinessType);
                                rOldMapAccountBusinessType.put(accountBusinessType.Id,accountBusinessType);
                            }
                        }
                        if(rOldAccountBusinessTypes.size() > 0){
                            //System.debug('#@$Enterreltiosync');
                            rtsync.TriggerHandler.handle(operation, newAccountBusinessTypes, mNewAccountBusinessTypes, rOldAccountBusinessTypes, rOldMapAccountBusinessType);
                        }
                    }
                }
            }
            catch(Exception ex){
                UCD_ACM_Logger.error('UCD_ACM_AccountBusinessTypeHandler','triggerReltioSync','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString()+' UserName: '+UserInfo.getUserName(),NULL);
                UCD_ACM_Logger.setLogDetails();
            }
       }
    }
}