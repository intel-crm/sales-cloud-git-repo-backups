public without sharing class UCD_ACM_AccountBusinessTypeHandler {
    private static UCD_ACM_ServiceContracts.IAccountService accountServiceInstance = UCD_ACM_AccountService.getInstance();
    public static Id rejectedAccountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Rejected Account').getRecordTypeId();
    
    public static void triggerPlatformEventOnInsert(System.TriggerOperation operation,List<Account_Business_Types__c> AccountBusinessTypes,Map<Id,Account_Business_Types__c> accountBusinessTypeById){
        Set<Id> accountIds = new Set<Id>();
        Map<Id,Business_Types__c> businessTypeById = new Map<Id,Business_Types__c>();
        Set<Id> businessTypeIds = new Set<Id>();

        try{
            if(AccountBusinessTypes.size() > 0){
                For(Account_Business_Types__c accountBusinessType : AccountBusinessTypes){
                    businessTypeIds.add(accountBusinessType.Business_Types__c);
                }
            }   
            // Get Map of Business Type By Id
            businessTypeById = accountServiceInstance.getBusinessTypeMap(businessTypeIds,'Id,Business_Type_Code__c');
            List<String> businessTypeNames = System.Label.UCD_ACM_Business_Type.split(',');

            For(Account_Business_Types__c AccountBusinessType :AccountBusinessTypes){
                if(businessTypeNames.contains(businessTypeById.get(AccountBusinessType.Business_Types__c).Business_Type_Code__c)){
                    if(operation == System.TriggerOperation.AFTER_INSERT){
                        accountIds.add(AccountBusinessType.Account__c);
                    }else if(operation == System.TriggerOperation.AFTER_UPDATE && ((AccountBusinessType.Account__c != accountBusinessTypeById.get(AccountBusinessType.Id).Account__c) ||
                                                                                   (AccountBusinessType.Business_Types__c != null && (AccountBusinessType.Business_Types__c != accountBusinessTypeById.get(AccountBusinessType.Id).Business_Types__c)) ||
                                                                                   (AccountBusinessType.Status__c != null && (AccountBusinessType.Status__c != accountBusinessTypeById.get(AccountBusinessType.Id).Status__c)) ||
                                                                                   (AccountBusinessType.Status_Reason__c != null && (AccountBusinessType.Status_Reason__c != accountBusinessTypeById.get(AccountBusinessType.Id).Status_Reason__c)) || 
                                                                                   (AccountBusinessType.Effective_End_Date__c != accountBusinessTypeById.get(AccountBusinessType.Id).Effective_End_Date__c) ||
                                                                                   (AccountBusinessType.Effective_Start_Date__c != null && (AccountBusinessType.Effective_Start_Date__c != accountBusinessTypeById.get(AccountBusinessType.Id).Effective_Start_Date__c)))){
                                                                                       accountIds.add(AccountBusinessType.Account__c);
                                                                                   }
                }
            }
            if(accountIds.size() > 0){
                Set<Id> accountIdsToPublish = new Set<Id>();
                List<Account> accounts = UCD_ACM_AccountService.getAccountsToPublishEvent(accountIds);
                if(accounts != null && accounts.size() >0){
                    for(Account account :accounts){
                        accountIdsToPublish.add(account.Id);
                    }
                    //UCD_ACM_AccountService.publishAccountChangeEvent(accountIdsToPublish);
                    accountServiceInstance.updateACMIntegrationMessage(accountIdsToPublish);
                }
                
                
            }
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_AccountBusinessTypeHandler','triggerPlatformEventOnInsert','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString()+' UserName: '+UserInfo.getUserName(),'AccountIds: '+accountIds.toString());
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
        List<Account_Business_Types__c> rNewAccountBusinessTypes = new List<Account_Business_Types__c>();
        List<Account_Business_Types__c> rOldAccountBusinessTypes = new List<Account_Business_Types__c>();
        Map<Id,Account_Business_Types__c> rNewMapAccountBusinessType = new Map<Id,Account_Business_Types__c>();
        Map<Id,Account_Business_Types__c> rOldMapAccountBusinessType = new Map<Id,Account_Business_Types__c>();
        
        Map<Id,Business_Types__c> businessTypeById = new Map<Id,Business_Types__c>();
        
        Set<Id> businessTypeIds = new Set<Id>();
        try{
            if(newAccountBusinessTypes.size() > 0){
                For(Account_Business_Types__c accountBusinessType : newAccountBusinessTypes){
                    businessTypeIds.add(accountBusinessType.Business_Types__c);
                }
                
                // Get Map of Business Type By Id
                businessTypeById = accountServiceInstance.getBusinessTypeMap(businessTypeIds,'Id,Business_Type_Code__c');
                List<String> businessTypeNames = System.Label.UCD_ACM_Business_Type.split(',');
                if(operation == System.TriggerOperation.AFTER_UPDATE && businessTypeById != null){
                    For(Account_Business_Types__c accountBusinessType : newAccountBusinessTypes){
                        // Check Account Customer Aggregation is Not Null
                        // Compare Current Start Date and End Date with old Values
                        // Check Business Type Code is present in 'UCD_ACM_Business_Type' custom label.
                        if((accountBusinessType.Effective_Start_Date__c != mOldAccountBusinessTypes.get(accountBusinessType.Id).Effective_Start_Date__c || accountBusinessType.Effective_End_Date__c != mOldAccountBusinessTypes.get(accountBusinessType.Id).Effective_End_Date__c) && businessTypeNames.contains(businessTypeById.get(accountBusinessType.Business_Types__c).Business_Type_Code__c)){
                            rNewAccountBusinessTypes.add(accountBusinessType);
                            rOldAccountBusinessTypes.add(mOldAccountBusinessTypes.get(accountBusinessType.Id));
                            rNewMapAccountBusinessType.put(accountBusinessType.Id,accountBusinessType);
                            rOldMapAccountBusinessType.put(mOldAccountBusinessTypes.get(accountBusinessType.Id).Id,mOldAccountBusinessTypes.get(accountBusinessType.Id));
                        }
                    }
                    if(rNewAccountBusinessTypes.size() > 0){
                     //   rtsync.TriggerHandler.handle(operation, rNewAccountBusinessTypes, rNewMapAccountBusinessType, rOldAccountBusinessTypes, rOldMapAccountBusinessType);
                    }
                }else if(operation == System.TriggerOperation.AFTER_INSERT && businessTypeById != null){
                    For(Account_Business_Types__c accountBusinessType : newAccountBusinessTypes){
                        // Check Account Customer Aggregation is Not Null
                        if(businessTypeNames.contains(businessTypeById.get(accountBusinessType.Business_Types__c).Business_Type_Code__c)){
                            rNewAccountBusinessTypes.add(accountBusinessType);
                            rNewMapAccountBusinessType.put(accountBusinessType.Id,accountBusinessType);
                        }
                    }
                    if(rNewAccountBusinessTypes.size() > 0){
                     //   rtsync.TriggerHandler.handle(operation, rNewAccountBusinessTypes, rNewMapAccountBusinessType, oldAccountBusinessTypes, mOldAccountBusinessTypes);
                    }
                }
            }
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_AccountBusinessTypeHandler','triggerReltioSync','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString()+' UserName: '+UserInfo.getUserName(),NULL);
            UCD_ACM_Logger.setLogDetails();
        }
    }

    public static void triggerAccountCPECheck(System.TriggerOperation operation, List<Account_Business_Types__c> newAccountBusinessTypes, Map<Id,Account_Business_Types__c> mOldAccountBusinessTypes) {
        Map<Id,Business_Types__c> businessTypeById = new Map<Id,Business_Types__c>();        
        Set<Id> businessTypeIds = new Set<Id>();
        try{
            System.debug('@@newAccountBusinessTypes '+newAccountBusinessTypes);
            if(newAccountBusinessTypes.size() > 0){
                For(Account_Business_Types__c accountBusinessType : newAccountBusinessTypes){
                    businessTypeIds.add(accountBusinessType.Business_Types__c);
                }
                // Get Map of Business Type By Id
                businessTypeById = accountServiceInstance.getBusinessTypeMap(businessTypeIds,'Id,Business_Type_Code__c');
                System.debug('@@BusinessTypeById '+businessTypeById);
                if(businessTypeById.size() > 0) {
                    List<String> allowedBusinessTypeCodes = System.Label.UCD_ACM_Business_Type.split(',');                    
                    for(Account_Business_Types__c accountBusinessType : newAccountBusinessTypes){
                        Account acc=[Select Id, Name, RecordTypeId from Account Where Id=:accountBusinessType.Account__c];
                        System.debug('@@Current BusinessType code '+businessTypeById.get(accountBusinessType.Business_Types__c).Business_Type_Code__c);
                        System.debug('@@Account recordType '+acc.RecordTypeId);
                        if(operation == System.TriggerOperation.AFTER_UPDATE) {
                            if(allowedBusinessTypeCodes.contains(businessTypeById.get(accountBusinessType.Business_Types__c).Business_Type_Code__c) && accountBusinessType.Effective_End_Date__c != mOldAccountBusinessTypes.get(accountBusinessType.Id).Effective_End_Date__c && accountBusinessType.Effective_End_Date__c != null && acc.RecordTypeId!=rejectedAccountRecordType) {
                                setRejectedAccountRecordType(accountBusinessType,allowedBusinessTypeCodes);
                            }  
                            System.debug('@@Leaving after update'); 
                        }
                        else if(operation == System.TriggerOperation.AFTER_INSERT) {
                            System.debug('@@Business Type code'+businessTypeById.get(accountBusinessType.Business_Types__c).Business_Type_Code__c);
                            System.debug('@@Account recordType '+acc.RecordTypeId);
                            if(allowedBusinessTypeCodes.contains(businessTypeById.get(accountBusinessType.Business_Types__c).Business_Type_Code__c) && acc.RecordTypeId==rejectedAccountRecordType){
                                system.debug('@@@Enter if');
                                //Account account=[Select Id, Name from Account Where Id=:accountBusinessType.Account__c];
                                acc.RecordTypeId=Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('End Customer Deal Account').getRecordTypeId();
                                update acc;
                            }
                            else if(!allowedBusinessTypeCodes.contains(businessTypeById.get(accountBusinessType.Business_Types__c).Business_Type_Code__c) && acc.RecordTypeId!=rejectedAccountRecordType){
                                setRejectedAccountRecordType(accountBusinessType,allowedBusinessTypeCodes);
                            }
                            System.debug('@@Leaving after insert'); 
                        }
                    }                    
                }
            }
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_AccountBusinessTypeHandler','triggerReltioSync','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString()+' UserName: '+UserInfo.getUserName(),NULL);
            UCD_ACM_Logger.setLogDetails();
        }
    }

    private static void setRejectedAccountRecordType(Account_Business_Types__c accountBusinessType,List<String> allowedBusinessTypeCodes){
        Boolean isSAPMDGAccount=true;
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountBusinessType.Account__c);
        System.debug('accountIds '+accountIds);
        Map<Id,List<Business_Types__c>> accountBusTypes = UCD_ACM_AccountService.getActiveBusinessTypeForAccount(accountIds);
        System.debug('@@accountBusTypes '+accountBusTypes);
        for(List<Business_Types__c> busineesType : accountBusTypes.values()){
            for(Business_Types__c busiTypes:busineesType){
                if(allowedBusinessTypeCodes.contains(busiTypes.Business_Type_Code__c)){
                    isSAPMDGAccount=false;
                    break;
                }
            }
        }
        System.debug('@@isSAPMDGAccount '+isSAPMDGAccount);
        if(isSAPMDGAccount){
            Account account=[Select Id, Name from Account Where Id=:accountBusinessType.Account__c];
            account.RecordTypeId=Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Rejected Account').getRecordTypeId();
            update account;
            System.debug('@@Account RecordType '+account.RecordTypeId);
        }
    }
}