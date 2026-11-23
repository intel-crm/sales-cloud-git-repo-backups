public without sharing class UCD_ACM_AccountMutationSelector implements UCD_ACM_SelectorContracts.IAccountMutationSelector  {

    private static UCD_ACM_SelectorContracts.IAccountMutationSelector instance = null; 
    private UCD_ACM_AccountMutationSelector() {}
    private static UCD_ACM_SelectorContracts.IAccountQuerySelector accountQuerySelectorInstance = UCD_ACM_AccountQuerySelector.getInstance();


    public static UCD_ACM_SelectorContracts.IAccountMutationSelector getInstance()
    {
        if (instance  == null) {
            instance  = new UCD_ACM_AccountMutationSelector();
        }
        return instance;
    }


     /** 
    * description : Mapping for Insert Account 
    * params : UCD_ACM_Models.AccountModel
    * return : Account
    * author and date : ankit1x.sharma@intel.com 06/19/2022
    */
    private Account mappingCreateAccount(UCD_ACM_Models.AccountModel accountRecord ){
        Account account = new Account();
        account.Name = accountRecord.Name;
        account.Core_Customer_Aggregation_Type__c = accountRecord.CustomerAggregationTypeCode;
        account.Core_Intel_Requester_Email__c = accountRecord.RequesterEmail != null ? accountRecord.RequesterEmail : NULL;
        account.Core_Intel_Requester_Name__c = accountRecord.RequesterName != null ? accountRecord.RequesterName : NULL;
        account.Core_Intel_Requester_WWID__c = accountRecord.RequesterWWID != null ? accountRecord.RequesterWWID : NULL;
        account.Core_Requested_Parent_BP_ID__c = accountRecord.ParentBusinessPartyIdentifierReference != null ? accountRecord.ParentBusinessPartyIdentifierReference : NULL;
        account.RecordTypeId = accountRecord.RecordTypeId;
        account.OwnerId = System.Label.Core_Uncovered_Account_ID;

        for( UCD_ACM_Models.AccountAddress  accountAddress : accountRecord.Addresses){
                account.ShippingCountryCode	= accountAddress.CountryCode;
                account.BillingCountryCode	= accountAddress.CountryCode;
           
        }
        if( accountRecord.AccountRequestReferences != null ){
            for( String Key : accountRecord.AccountRequestReferences.keySet()){
                account.Core_Account_Reference_Source_ID__c	=  accountRecord.AccountRequestReferences.get(Key);
                account.Core_Account_Reference_Source_Name__c	=  Key;
        
            }
        }
        return account;
    }

    /** 
    * description : Mapping for Insert Account Business Type
    * params : String CustomerProcessEngagmentCode, String AccountId
    * return : Account_Business_Types__c
    * author and date :ankit1x.sharma@intel.com 02/11/2021
    */
    private Account_Business_Types__c mappingCreateAccountBusinessType(String CustomerProcessEngagmentCode, Map<String,Business_Types__c> businessTypeById){
        Account_Business_Types__c accountBusinessType = new Account_Business_Types__c();
        accountBusinessType.Business_Types__c = businessTypeById.get(CustomerProcessEngagmentCode) != null ? businessTypeById.get(CustomerProcessEngagmentCode).Id : null;
        accountBusinessType.Effective_Start_Date__c = System.today();
        return accountBusinessType;
    }

   /** 
    * description : Insert Account 
    * params : List <UCD_ACM_Models.AccountModel> accountModel
    * return : Map<Id,Account>
    * author and date : ankit1x.sharma@intel.com 12/03/2021
    */
    public Map<Id,Account>  createAccount( List <UCD_ACM_Models.AccountModel> accountModel){
        Map<Id,Account> AccountByAccountId = new Map<Id,Account>();
        List <Account> Accounts = new List <Account>();
        UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();

        try{
            Schema.sObjectField schemaFields = Account_Business_Types__c.Account__c.getDescribe().getSObjectField();

            Set<String> CustomerProcessEngagmentCodes = new Set<String>();
            for(UCD_ACM_Models.AccountModel accountRecord :accountModel){
                CustomerProcessEngagmentCodes.add(accountRecord.CustomerProcessEngagmentCode);
            }
            Map<String,Business_Types__c> businessTypeById = accountQuerySelectorInstance.getBusinessTypeId(CustomerProcessEngagmentCodes); 

            for(UCD_ACM_Models.AccountModel accountRecord :accountModel){
                //Mapping of Account/Accoun
                Account account = mappingCreateAccount(accountRecord) ;
                Account_Business_Types__c accountBusinessType = mappingCreateAccountBusinessType(accountRecord.CustomerProcessEngagmentCode, businessTypeById) ;
                unitwork.registerNew(account);
                unitwork.registerNew(accountBusinessType,schemaFields,account);
                Accounts.add( account );
            }

            boolean validateAccountCreation = unitwork.commitWork();          
            if(validateAccountCreation){    
                UCD_ACM_Logger.information('UCD_ACM_AccountMutationSelector','createAccount','Accounts created successfully '+ Accounts.toString(),NULL);
                AccountByAccountId = new Map<Id, Account>(Accounts);
            }else{
                UCD_ACM_Logger.error('UCD_ACM_AccountMutationSelector','createAccount','Error in creating Accounts'+ accountModel.toString(),NULL);
            }
           
       }catch(Exception ex){
           System.debug('Exception3==>>'+ex.getStackTraceString());
        UCD_ACM_Logger.error('UCD_ACM_AccountMutationSelector','createAccount','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
    }
        return AccountByAccountId;
    }

    /** 
    * description : Insert or Update ACM_Integration_Message_Queue__c 
    * params : Set<Id> accountIds
    * return : void
    * author and date : harshalx.sunil.gosavi@intel.com 08/02/2022.
    */

    public void setIntegrationMessage(Set<Id> accountIds){
        Map<Id,ACM_Integration_Message_Queue__c> integrationMessageQueueById = accountQuerySelectorInstance.getIntegrationMessageQueueByAccountId(accountIds);
        List<ACM_Integration_Message_Queue__c> insertIntegrationMessages = new List<ACM_Integration_Message_Queue__c>();
        List<ACM_Integration_Message_Queue__c> updateIntegrationMessages = new List<ACM_Integration_Message_Queue__c>();
        Map<Id,ACM_Integration_Message_Queue__c> integrationMessageQueueByAccountId = new Map<Id,ACM_Integration_Message_Queue__c>(); 

        try{
            if(integrationMessageQueueById !=null && integrationMessageQueueById.size()>0){
                For(ACM_Integration_Message_Queue__c integrationMessageQueue : integrationMessageQueueById.values()){
                    integrationMessageQueueByAccountId.put(integrationMessageQueue.Content__c,integrationMessageQueue);
                }
            }
            system.debug('accountIds--> '+ accountIds);
            For(Id accountId : accountIds){
                system.debug('integrationMessageQueueByAccountId--> '+integrationMessageQueueByAccountId);
                system.debug('integrationMessageQueueByAccountId.get(accountId)--> '+integrationMessageQueueByAccountId.get(accountId));

                if(integrationMessageQueueByAccountId != null && integrationMessageQueueByAccountId.size() > 0 && integrationMessageQueueByAccountId.containsKey(accountId)){
                    if(integrationMessageQueueByAccountId.get(accountId).Message_Status__c == 'Success' ){
                        ACM_Integration_Message_Queue__c integrationMessage = integrationMessageQueueByAccountId.get(accountId);
                        integrationMessage.Message_Status__c = 'New';
                        updateIntegrationMessages.add(integrationMessage);
                    }
                }else{
                    ACM_Integration_Message_Queue__c integrationMessage = new ACM_Integration_Message_Queue__c();
                        integrationMessage.Content__c = accountId;
                        integrationMessage.Custom_Filter__c = accountId;
                        integrationMessage.Content_Type__c = 'AccountId';
                        integrationMessage.Message_Status__c = 'New';
                        integrationMessage.Module_Name__c = 'ACM';
                        integrationMessage.Queue_Type__c = 'Outbound';
                        integrationMessage.Retry_Count__c = 0;
                        integrationMessage.Source_System__c = 'Reltio';
                        insertIntegrationMessages.add(integrationMessage);
                }
        }

        if(insertIntegrationMessages.size() > 0){
            insert insertIntegrationMessages;
        }
        if(updateIntegrationMessages.size() > 0){
            update updateIntegrationMessages;
        }

        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_AccountMutationSelector','createUpdateIntegrationMessage','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),'AccountIds: '+accountIds.toString());
        }

    }

    /** 
    * description : Update ACM_Integration_Message_Queue__c  with Status Error
    * params : Set<Id> accountIds
    * return : void
    * author and date : harshalx.sunil.gosavi@intel.com 09/05/2022.
    */
    public void updateIntegrationMsgQueueStatus(Set<Id> accountIds,String statusType){
        List<ACM_Integration_Message_Queue__c> integrationMsgsToUpdate = new List<ACM_Integration_Message_Queue__c>();
        Map<Id,ACM_Integration_Message_Queue__c> integrationMessageQueueByAccountId = accountQuerySelectorInstance.getIntegrationMessageQueueByAccountId(accountIds);
        
        try{
            if(integrationMessageQueueByAccountId.size()>0){
                for(ACM_Integration_Message_Queue__c integrationMessage :integrationMessageQueueByAccountId.values()){
                    integrationMessage.Message_Status__c = statusType;
                        if(statusType == 'Error'){
                            integrationMessage.Retry_Count__c += 1;
                        }
                        integrationMsgsToUpdate.add(integrationMessage);
                }
            }

            if(integrationMsgsToUpdate.size() > 0){
                update integrationMsgsToUpdate;
            }
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_AccountMutationSelector','updateIntegrationMsgQueueStatus','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),'AccountIds: '+accountIds.toString());
        }
    }

    /** 
    * description : Mapping Of Account
    * params : Account_Create_Request__c accountCreateReq 
    * return : Account
    * author and date : ankit1x.sharma@intel.com 23/06/2022
    */
    /**private Account mappingCreateAccount(Account_Create_Request__c accountCreateReq ){
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
    }**/


    /** 
    * description : Account creation
    * params : List<Account_Create_Request__c> AccountCreateRequests,Map<Account_Create_Request__c,Account> AccountByAccountCreateReq
    * return : Boolean
    * author and date : ankit1x.sharma@intel.com 23/06/2022
    */
    /**private Boolean createAccountForApproval(List<Account_Create_Request__c> AccountCreateRequests,Map<Account_Create_Request__c,Account> AccountByAccountCreateReq){
            UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
            Schema.sObjectField schemaFields = Account_Business_Types__c.Account__c.getDescribe().getSObjectField();

            Set<String> CustomerProcessEngagmentCodes = new Set<String>();
            for(Account_Create_Request__c accountCreateReq :AccountCreateRequests){
                CustomerProcessEngagmentCodes.add(accountCreateReq.Customer_Process_Engagement__c);
            }
            Map<String,Business_Types__c> businessTypeById = accountQuerySelectorInstance.getBusinessTypeId(CustomerProcessEngagmentCodes); 


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

    /**private Boolean updateAccountCreateRequest(Map<Account_Create_Request__c,Account> AccountByAccountCreateReq){
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

    /**public  Map<Id,Account_Create_Request__c>  approveAccountRequest (List<Account_Create_Request__c> AccountCreateRequests){
        List <Account> Accounts = new List <Account>();
        Map<Account_Create_Request__c,Account> AccountByAccountCreateReq = new Map<Account_Create_Request__c,Account>();

        
            boolean resultCreateAccount = createAccountForApproval(AccountCreateRequests, AccountByAccountCreateReq);
            boolean resultUpdateCreateAccountReq =  updateAccountCreateRequest(AccountByAccountCreateReq);
            if(resultCreateAccount && resultUpdateCreateAccountReq){
                Map<Id,Account_Create_Request__c> AccountCreateReqById = new Map<Id,Account_Create_Request__c>(new List<Account_Create_Request__c>(AccountByAccountCreateReq.keySet()));
                return AccountCreateReqById;
                
            }
            return null;
            


    }*/


     /** 
    * description : This method call from Reject Button
    * params : List<Account_Create_Request__c> AccountCreateRequests
    * return : Boolean
    * author and date : ankit1x.sharma@intel.com 23/06/2022
    */
    /**public Boolean  rejectAccountRequest (List<Account_Create_Request__c> AccountCreateRequests){
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