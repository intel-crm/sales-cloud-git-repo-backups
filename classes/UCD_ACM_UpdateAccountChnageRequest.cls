public with sharing class UCD_ACM_UpdateAccountChnageRequest {
    //private static UCD_ACM_ServiceContracts.IAccountService accountServiceInstance = UCD_ACM_AccountService.getInstance();
    /*private static UCD_ACM_SelectorContracts.IAccountQuerySelector accountQuerySelectorInstance = UCD_ACM_AccountQuerySelector.getInstance();
    @AuraEnabled
    public static boolean approveAccountChangeRequest(String recId){
        try {
            Account_Create_Request__c accountChangeReq = [Select Id,Account_Name__c, Country__c,City__c, Customer_Aggregation_Type__c, Customer_Process_Engagement__c, Status__c, State__c, Street__c, Requested_Account__c from Account_Create_Request__c where Id=: recId];
            
            if(accountChangeReq.Status__c == 'New'){
                accountChangeReq.Status__c = 'Approved';
                accountChangeReq.Request_Flow_Status__c = 'Approved';
                Boolean isSuccess = approveAccountRequest(new List<Account_Create_Request__c>{accountChangeReq});
                return isSuccess;
            }
            return false;
        } catch (Exception e) {
            system.debug('Error is--> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static boolean rejectAccountChangeRequest(String recId,String rejectionReason){
        try {
            Account_Create_Request__c accountChangeReq = [Select Id,Account_Name__c, Country__c,City__c, Customer_Aggregation_Type__c, Customer_Process_Engagement__c, Status__c, State__c, Street__c, Requested_Account__c,Rejected_Reason__c from Account_Create_Request__c where Id=: recId];
            
            if(accountChangeReq.Status__c == 'New'){
                accountChangeReq.Status__c = 'Rejected';
                accountChangeReq.Rejected_Reason__c = rejectionReason;
                Boolean isSuccess = rejectAccountRequest(new List<Account_Create_Request__c>{accountChangeReq});
                return isSuccess;
            }
            return false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
            //return null;
        }
    }*/


    /** 
    * description : Mapping for Insert Account Business Type
    * params : String CustomerProcessEngagmentCode, String AccountId
    * return : Account_Business_Types__c
    * author and date :ankit1x.sharma@intel.com 02/11/2021
    */
    /*private static Account_Business_Types__c mappingCreateAccountBusinessType(String CustomerProcessEngagmentCode, Map<String,Business_Types__c> businessTypeById){
        Account_Business_Types__c accountBusinessType = new Account_Business_Types__c();
        system.debug('CustomerProcessEngagmentCode--> '+CustomerProcessEngagmentCode);
        system.debug('businessTypeById--> '+businessTypeById);
        accountBusinessType.Business_Types__c = (businessTypeById!= null && businessTypeById.get(CustomerProcessEngagmentCode) != null ) ? businessTypeById.get(CustomerProcessEngagmentCode).Id : null;
        accountBusinessType.Effective_Start_Date__c = System.today();
        return accountBusinessType;
    }*/
    /*
    private static Account mappingCreateAccount(Account_Create_Request__c accountCreateReq ){
        Account account = new Account();

        account.Name =  String.isNotBlank(accountCreateReq.Account_Name__c)  ? accountCreateReq.Account_Name__c : NULL ;
        account.BillingCity = String.isNotBlank(accountCreateReq.City__c)? accountCreateReq.City__c : NULL ;
        account.BillingCountry = String.isNotBlank(accountCreateReq.Country__c)  ? accountCreateReq.Country__c : NULL ;
        //account.Core_Customer_Process_Engg__c = String.isNotBlank(accountCreateReq.Customer_Process_Engagement__c)  ? accountCreateReq.Customer_Process_Engagement__c : NULL ;
        account.BillingState = String.isNotBlank(accountCreateReq.State__c)  ? accountCreateReq.State__c : NULL ;
        account.BillingStreet = String.isNotBlank(accountCreateReq.Street__c) ? accountCreateReq.Street__c : NULL ;
        account.RecordTypeId =  Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Requested Account').getRecordTypeId();
        account.OwnerId = System.Label.Core_Uncovered_Account_ID;
        return account ;
    }*/


    /** 
    * description : Account creation
    * params : List<Account_Create_Request__c> AccountCreateRequests,Map<Account_Create_Request__c,Account> AccountByAccountCreateReq
    * return : Boolean
    * author and date : ankit1x.sharma@intel.com 23/06/2022
    */
    /*private static Boolean createAccountForApproval(List<Account_Create_Request__c> AccountCreateRequests,Map<Account_Create_Request__c,Account> AccountByAccountCreateReq){
            UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
            Schema.sObjectField schemaFields = Account_Business_Types__c.Account__c.getDescribe().getSObjectField();

            Set<String> CustomerProcessEngagmentCodes = new Set<String>();
            for(Account_Create_Request__c accountCreateReq :AccountCreateRequests){
                CustomerProcessEngagmentCodes.add(accountCreateReq.Customer_Process_Engagement__c);
            }
            system.debug('CustomerProcessEngagmentCodes--> '+CustomerProcessEngagmentCodes);
            Map<String,Business_Types__c> businessTypeById = accountQuerySelectorInstance.getBusinessTypeId(CustomerProcessEngagmentCodes); 
            system.debug('businessTypeById--> '+businessTypeById);

            for(Account_Create_Request__c accountCreateReq : AccountCreateRequests){
                Account account = mappingCreateAccount(accountCreateReq) ;
                Account_Business_Types__c accountBusinessType = mappingCreateAccountBusinessType(accountCreateReq.Customer_Process_Engagement__c, businessTypeById) ;
                unitwork.registerNew(account);
                unitwork.registerNew(accountBusinessType,schemaFields,account);
                AccountByAccountCreateReq.put(accountCreateReq, account);
            }

            return unitwork.commitWork();
           
    }*/

    /** 
    * description : Update Account create Request 
    * params : Map<Account_Create_Request__c,Account> AccountByAccountCreateReq
    * return : Boolean
    * author and date : ankit1x.sharma@intel.com 23/06/2022
    */
    /*
    private static Boolean updateAccountCreateRequest(Map<Account_Create_Request__c,Account> AccountByAccountCreateReq){
        UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
      
        for(Account_Create_Request__c accountCreateRequestRecord :  AccountByAccountCreateReq.keySet()){
            accountCreateRequestRecord.Requested_Account__c = AccountByAccountCreateReq.get(accountCreateRequestRecord).Id ;
            accountCreateRequestRecord.Status__c = 'Approved';
            unitwork.registerModified(accountCreateRequestRecord);
        }

       return unitwork.commitWork();


    }*/

    /** 
    * description : This method call from Approval Button
    * params : List<Account_Create_Request__c> AccountCreateRequests
    * return : Boolean
    * author and date : ankit1x.sharma@intel.com 23/06/2022
    */
    /*
    public static Boolean  approveAccountRequest (List<Account_Create_Request__c> AccountCreateRequests){
        List <Account> Accounts = new List <Account>();
        Map<Account_Create_Request__c,Account> AccountByAccountCreateReq = new Map<Account_Create_Request__c,Account>();

        
            boolean resultCreateAccount = createAccountForApproval(AccountCreateRequests, AccountByAccountCreateReq);
            boolean resultUpdateCreateAccountReq =  updateAccountCreateRequest(AccountByAccountCreateReq);
            if(resultCreateAccount && resultUpdateCreateAccountReq){
                //Map<Id,Account_Create_Request__c> AccountCreateReqById = new Map<Id,Account_Create_Request__c>(new List<Account_Create_Request__c>(AccountByAccountCreateReq.keySet()));
                return true;
                
            }
            return false;
            


    }*/


     /** 
    * description : This method call from Reject Button
    * params : List<Account_Create_Request__c> AccountCreateRequests
    * return : Boolean
    * author and date : ankit1x.sharma@intel.com 23/06/2022
    */
    /*public static Boolean  rejectAccountRequest (List<Account_Create_Request__c> AccountCreateRequests){
        List <Account> Accounts = new List <Account>();
        UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();

            for(Account_Create_Request__c accountCreateReq : AccountCreateRequests){
                accountCreateReq.Status__c = 'Rejected';
                unitwork.registerModified(accountCreateReq);
            }
                boolean resultRejectAccount = unitwork.commitWork(); 
                return resultRejectAccount ;

    }*/
}