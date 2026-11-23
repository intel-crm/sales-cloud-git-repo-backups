public without sharing class UCD_ACM_AccountQuerySelector implements UCD_ACM_SelectorContracts.IAccountQuerySelector  {
    private static UCD_ACM_SelectorContracts.IAccountQuerySelector instance = null;
    private static UCD_ACM_SelectorContracts.IAccountQuerySelector accountQuerySelectorInstance = UCD_ACM_AccountQuerySelector.getInstance();
    private UCD_ACM_AccountQuerySelector() {}

    public static UCD_ACM_SelectorContracts.IAccountQuerySelector getInstance()
    {
        if (instance  == null) {
            instance  = new UCD_ACM_AccountQuerySelector();
        }
        return instance;
    }

      /*
    * description : get account record using Ids and Query.
    * params : Set<Id> , String queryFields
    * return : Map<Id,Account>
    * author and date : Harshal Gosavi, 4th August 2021
    */
    public Map<Id,Account> getAccountsByIds(Set<Id> accountIds, String queryFields){
        String query = 'SELECT '+queryFields+' FROM account WHERE Id IN :accountIds';
        List<Account> accounts = Database.query(query);

        Map<Id,Account> accountsById = new Map<Id,Account>(accounts);
        return accountsById.size() > 0 ? accountsById : null;
    }

     /*
    * description : get account record using Ids, Query and Clause.
    * params : Set<Id> , String queryFields, String andClause
    * return : Map<Id,Account>
    * author and date : Harshal Gosavi, 29th November 2021
    */
    public Map<Id,Account> getAccountsByIds(Set<Id> accountIds, String queryFields, String andClause){
        String query = 'SELECT '+queryFields+' FROM account WHERE Id IN :accountIds and '+andClause;
        List<Account> accounts = Database.query(query);

        Map<Id,Account> accountsById = new Map<Id,Account>(accounts);
        return accountsById.size() > 0 ? accountsById : null;
    }

    /*
    * description : get account record using Names and Query.
    * params : Set<String> , String queryFields
    * return :List<Account>
    * author and date : Harshal Gosavi, ankit1x.sharma@intel.com 8th August 2021
    */
    public List<Account> selectAccountsByName(Set<String> accountNames, String queryFields){
        List<Account> accounts = new List<Account>();
        String query = 'SELECT '+queryFields+' FROM account WHERE ( Name IN :accountNames OR Core_Data_Simplified_Account_Nm__c IN :accountNames) AND (RecordType.Name  = \'Requested Account\' OR RecordType.Name  = \'End Customer Deal Account\') ORDER BY RecordType.Name ASC , CreatedDate ASC';
        return Database.query(query);
    }

    /**
     * description:-  get Business Type Record Id based On TypeCode
     * params:- Set<String> typeCodes
     * return:- Map<String,Business_Types__c>
     * author and date:- ankit1x.sharma@intel.com 25/10/2021
     */

    public Map<String,Business_Types__c> getBusinessTypeId(Set<String> typeCodes ){
        String query = 'SELECT Id,Business_Type_Code__c FROM Business_Types__c WHERE Business_Type_Code__c IN :typeCodes AND Is_Active__c = true';
        Map<String,Business_Types__c> businessTypeById = new Map<String,Business_Types__c>();

        for(Business_Types__c businessType : Database.query(query))
            businessTypeById.put(businessType.Business_Type_Code__c, businessType);

        return businessTypeById.size() > 0 ? businessTypeById : null;

    }

   /**   
    * description : Formating current Date
    * params : NA
    * return : String
    * author and date : ankit1x.sharma@intel.com 12/03/2021
    */
    private static String getFormattedDate(){
        Date currentDate = System.today()+1;
        String month = string.valueof(currentDate.month()).length() == 1?'0'+string.valueof(currentDate.month()):string.valueof(currentDate.month());
        String day = string.valueof(currentDate.day()).length() == 1?'0'+string.valueof(currentDate.day()):string.valueof(currentDate.day());
        String formattedDate = String.format('{0}-{1}-{2}',new List<String>{
            string.valueof(currentDate.year()),
            month,
            day
        });
        return formattedDate;
    }

    /*
    * description : get Business Types record using Account Id.
    * params : Set of accountIds , String queryFields
    * return : Map<AccountId,List<Business_Types__c>>
    * author and date : Harshal Gosavi, 22nd August 2021
    */
    public Map<Id,List<Business_Types__c>> getBusinessTypesByAccountId(Set<Id> accountIds, String queryFields){
        Map<Id,List<Business_Types__c>> businessTypesByAccountId = new Map<Id,List<Business_Types__c>>();
        Map<Id,Business_Types__c> businessTypeById = new Map<Id,Business_Types__c>();
        try{
            For(Business_Types__c businessType : [Select Id,Name,Business_Type_Code__c,Business_Types_Category__c from Business_Types__c where Is_Active__c=true and Business_Types_Category__c = 'CPE']){
                businessTypeById.put(businessType.Id,businessType);
            }
            String formattedDate = getFormattedDate();
            //String query = String.format('Select {0} FROM Account_Business_Types__c Where Account__c IN :accountIds AND (Effective_End_Date__c = null OR (Effective_End_Date__c != null AND (Effective_Start_Date__c <= {1} AND Effective_End_Date__c > {1})))',new List<String>{queryFields,formattedDate});
            String query = String.format('SELECT {0} FROM Account_Business_Types__c Where Account__c IN :accountIds AND Effective_End_Date__c = null',new List<String>{queryFields});
            List<Account_Business_Types__c> accountBusinessTypes = Database.query(query);
            
            // Create a map of AccountId By List of Account Business Type.
            For(Account_Business_Types__c accountBusinessType : accountBusinessTypes){
                if(businessTypesByAccountId.containsKey(accountBusinessType.Account__c)){
                    if(businessTypeById.containsKey(accountBusinessType.Business_Types__c)){
                        List<Business_Types__c> businessTypes = businessTypesByAccountId.get(accountBusinessType.Account__c);
                        businessTypes.add(businessTypeById.get(accountBusinessType.Business_Types__c));
                    }
                    
                }else{
                    if(businessTypeById.containsKey(accountBusinessType.Business_Types__c))
                    businessTypesByAccountId.put(accountBusinessType.Account__c,new List<Business_Types__c>{businessTypeById.get(accountBusinessType.Business_Types__c)});
                }
            }

        }catch(Exception ex){
            // UCD_ACM_Logger.error('UCD_ACM_AccountSelector','getBusinessTypesByAccountId','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),'AccountIds: '+accountIds.toString());
            // UCD_ACM_Logger.setLogDetails();

        }
        if(businessTypesByAccountId.size() > 0){
            return businessTypesByAccountId;
        }
        return null;
    }

     /*
    * description : get Compliance Watch List record using Account Id.
    * params : Set of accountIds , String queryFields
    * return : Map<AccountId,List<Core_Account_Compliance_Watch_List__c>>
    * author and date : Harshal Gosavi, 19th August 2021
    */
    public Map<Id,List<Core_Account_Compliance_Watch_List__c>> getComplianceWatchListByAccountId(Set<Id> accountIds, String queryFields){
        Map<Id,List<Core_Account_Compliance_Watch_List__c>> complianceWatchListByAccountId = new Map<Id,List<Core_Account_Compliance_Watch_List__c>>();
        try{
            String formattedDate = getFormattedDate();
            //String query = String.format('SELECT {0} FROM Core_Account_Compliance_Watch_List__c Where Core_Account_Id__c IN :accountIds AND (Core_Effective_End_Date__c = null OR (Core_Effective_End_Date__c != null AND (Core_Effective_Start_Date__c <= {1} AND Core_Effective_End_Date__c > {1})))',new List<String>{queryFields,formattedDate});
            String query = String.format('SELECT {0} FROM Core_Account_Compliance_Watch_List__c Where Core_Account_Id__c IN :accountIds AND Core_Effective_End_Date__c = null',new List<String>{queryFields});
            List<Core_Account_Compliance_Watch_List__c> complianceWatchs = Database.query(query);
            // Create a map of AccountId By List of Compliance Watch List.
            For(Core_Account_Compliance_Watch_List__c complianceWatchList : complianceWatchs){
                if(complianceWatchListByAccountId.containsKey(complianceWatchList.Core_Account_Id__c)){
                    List<Core_Account_Compliance_Watch_List__c> complianceWatchFromMap = complianceWatchListByAccountId.get(complianceWatchList.Core_Account_Id__c);
                    complianceWatchFromMap.add(complianceWatchList);
                }else{
                    complianceWatchListByAccountId.put(complianceWatchList.Core_Account_Id__c,new List<Core_Account_Compliance_Watch_List__c>{complianceWatchList});
                }
            }
        }catch(Exception ex){
            // UCD_ACM_Logger.error('UCD_ACM_AccountSelector','getBusinessTypesByAccountId','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),'AccountIds: '+accountIds.toString());
            // UCD_ACM_Logger.setLogDetails();
        }
        
        if(complianceWatchListByAccountId.size() > 0){
            return complianceWatchListByAccountId;
        }
        return null;
    }

     /*
     * description : If Business Party Id is already present in salesforce then return true otherwise false
     * params : String Business Party Id
     * return : Boolean
     * author and date : harshalx.sunil.gosavi@intel.com, 23 Nov 2021
     */
    /*public String getAccountByBpId(String bpId){
        List<Account> accounts = [Select Id from account where Core_Business_Party_Id__c =:bpId and RecordType.Name = 'End Customer Deal Account'  ORDER BY CreatedDate ASC LIMIT 1];
        return accounts.size()>0 ? accounts[0].Id : null;
    }*/

    /*
    * description : Get account record using ParentIds.
    * params : Set<Id>, String, String
    * return : Map<Id,Account>
    * author and date : chethan.s.kunder@intel.com, 1 Dec 2021
    */
    public Map<Id,Account> getAccountsByParentId(Set<Id> parentIds, String queryFields, String andClause){
        String query = 'SELECT ' + queryFields + ' FROM Account WHERE ParentId IN :parentIds AND ' + andClause;
        List<Account> childAccounts = Database.query(query);
        Map<Id,Account> mChildAccounts = new Map<Id,Account>(childAccounts);
        return mChildAccounts.size() > 0 ? mChildAccounts : null;
    }

    /*
    * description : Get account record using ParentIds.
    * params : Set<Id>, String
    * return : Map<Id,Account>
    * author and date : ankit1x.sharma@intel.com, 22/11/2022
    */
    public Map<Id,Account> getAccountsByParentId(Set<Id> parentIds, String queryFields){
        String query = 'SELECT ' + queryFields + ' FROM Account WHERE ParentId IN :parentIds LIMIT 200';
        //System.debug('@@Query '+query);
        List<Account> childAccounts = Database.query(query);
        Map<Id,Account> mChildAccounts = new Map<Id,Account>(childAccounts);
        return mChildAccounts.size() > 0 ? mChildAccounts : null;
    }

    /*
     * description : get Business Types
     * params : Set<Id> ,String
     * return : Map<Id,Business_Types__c>
     * author and date : harshalx.sunil.gosavi@intel.com, 30 Dec 2021
     */
    public Map<Id,Business_Types__c> getBusinessTypeById(Set<Id> businessTypeIds,String queryFields){
        String query = 'SELECT '+queryFields+' FROM Business_Types__c WHERE Id IN :businessTypeIds AND Is_Active__c = true';
        List<Business_Types__c> businessTypes = Database.query(query);

        Map<Id,Business_Types__c> businessTypeById = new Map<Id,Business_Types__c>(businessTypes);
        return businessTypeById.size() > 0 ? businessTypeById : null;
    }


    public Map<Id,ACM_Integration_Message_Queue__c> getIntegrationMessageQueueByAccountId (Set<Id> accountId){
        Map<Id,ACM_Integration_Message_Queue__c> integrationMessageByAccountId = new Map<Id,ACM_Integration_Message_Queue__c>();
        List<ACM_Integration_Message_Queue__c> integrationMessages = [Select Id,Content__c,Content_Type__c,Message_Status__c,Module_Name__c,Queue_Type__c,Source_System__c,Custom_Filter__c from ACM_Integration_Message_Queue__c where Custom_Filter__c=: accountId and Content_Type__c = 'AccountId' and Module_Name__c = 'ACM' and Queue_Type__c = 'Outbound' and Source_System__c = 'Reltio'];
        
        if(integrationMessages.size() > 0){
            for(ACM_Integration_Message_Queue__c integrationMessage : integrationMessages){
                integrationMessageByAccountId.put(integrationMessage.Id,integrationMessage);
            }
            return integrationMessageByAccountId;
        }
        return null;

    }


    /*
     * description : getAccountByBpId
     * params : Set<String> BpIds
     * return : Map<String,Account>
     * author and date : harshalx.sunil.gosavi@intel.com, 01 Apr 2022
     */
    public Map<String,List<Account>> getAccountByBpId(Set<String> BpIds){
        Map<String,List<Account>> accountByBpId = new Map<String,List<Account>>();
        List<Account> accounts = [Select Id,Name,Core_Business_Party_Id__c,RecordTypeId,ParentId,Parent.Core_Business_Party_Id__c from Account where Core_Business_Party_Id__c =:BpIds and (RecordType.Name = 'End Customer Deal Account' OR RecordType.Name = 'Intel Account')];
        For(Account account : accounts){
            if(!accountByBpId.containsKey(account.Core_Business_Party_Id__c)){
                accountByBpId.put(account.Core_Business_Party_Id__c,new List<Account>{account});
            }else{
                List<Account> accountsFromMap = accountByBpId.get(account.Core_Business_Party_Id__c);
                accountsFromMap.add(account);
            }
        }
        if(accountByBpId.size() > 0){
            return accountByBpId;
        }
        return null;
    }

    /*public Map<Id,User> getUserById(Set<Id> userIds){
        Map<Id,User> userById = new Map<Id,User>();
        List<User> users = [Select Id,Name,Email from User where Id =:userIds];
        For(User user: users){
            userById.put(user.Id,user);
        }
        if(userById != null && userById.size() > 0){
            return userById;
        }
        return null;
    }*/

    /*
     * description : Get all child accounts for an account
     * params : Id parentAccId
     * author and date : chethan.s.kunder@intel.com, 1 Dec 2021
     * Moved to QuerySelector by swarupx.kumar.singh@intel.com, 27 Jan 2023
     */
    public static Map<Id, Account> getAllChildAccounts(Set<Id> parentAccIds) {
        if(parentAccIds.size() == 0) {
            return new Map<Id, Account>();
        }
        UCD_ACM_Models.AccountResponseModel model = new UCD_ACM_Models.AccountResponseModel(); 
        String andClause = 'Core_Customer_Aggregation_Type__c != null and (RecordType.Name = \'End Customer Deal Account\' OR RecordType.Name = \'Intel Account\')';
        Map<Id, Account> mChildAccounts = accountQuerySelectorInstance.getAccountsByParentId(parentAccIds, model.getParentAccountQueryForEvent(), andClause);
        if(mChildAccounts <> null && mChildAccounts.Values().size() > 0) {
            Map<Id, Account> nestedChildAccounts = getAllChildAccounts(new Set<Id>(mChildAccounts.keySet()));
            if(nestedChildAccounts <> null && nestedChildAccounts.Values().size() > 0) {
                mChildAccounts.putAll(nestedChildAccounts);
            }
        }
        return mChildAccounts;
    }


    /*
    * description : Get child account record using ParentIds.
    * params : Set<Id> parentIds, String queryFields, String andClause
    * return : Map< Id, List<Account> > 
    * author and date : ankit1x.sharma@intel.com, 08/2/2023
    */
    public Map< Id, List<Account> > getChildAccountsWithParent(Set<Id> parentIds, String queryFields, String andClause){

        Map< Id, List<Account> > accountsByParentId = new Map< Id, List<Account> > ();

        String query = 'SELECT ' + queryFields + ', (Select '+ queryFields +' From ChildAccounts Where ' + andClause + ') FROM Account WHERE ParentId IN :parentIds AND ' + andClause ;
        System.debug('query@@@@@'+query);
        List<Account> childAccounts = Database.query(query);

        for(Account accountRecord : childAccounts){
            if(! accountsByParentId.containsKey(accountRecord.parentId)){
                accountsByParentId.put(accountRecord.parentId, accountRecord.ChildAccounts);
            }
        }

        return accountsByParentId.size() > 0 ? accountsByParentId : null;

    }
    /*
    * description : get Account Request record using Ids, Query and Clause.
    * params : Set<Id> , String queryFields, String andClause
    * return : Map<Id,Account_Create_Request__c>
    * author and date : Tejasri, 7th November 2023
    */
    public Map<Id,Account_Create_Request__c> getAccountRequestsByIds(Set<Id> accountRequestIds, String queryFields, String andClause){
        System.debug('accountRequestIds@@@query'+accountRequestIds);
        String query = 'SELECT '+queryFields+' FROM Account_Create_Request__c WHERE Id IN :accountRequestIds and '+andClause;
        List<Account_Create_Request__c> accountRequests = Database.query(query);

        System.debug('accountRequests@@@selector'+accountRequests);
        Map<Id,Account_Create_Request__c> accountRequestsById = new Map<Id,Account_Create_Request__c>(accountRequests);
        return accountRequestsById.size() > 0 ? accountRequestsById : null;
    }
/*
    public Map<Id,Account_Create_Request__c> getAccountRequestsById(Set<Id> AccountRequestIds,String queryFields){
        String query = 'SELECT '+queryFields+' FROM Business_Types__c WHERE Id IN :AccountRequestIds';
        List<Account_Create_Request__c> accountRequests = Database.query(query);

        Map<Id,Account_Create_Request__c> accountRequestsById = new Map<Id,Account_Create_Request__c>(accountRequests);
        return accountRequestsById.size() > 0 ? accountRequestsById : null;
    }



    /*
    * description : get Account request queue List record using Account Id.
    * params : Set of accountIds , String queryFields
    * return : Map<AccountId,List<Account_Create_Request__c>>
    * author and date : Tejasri, 16th oct 2023
    */
    public Map<Id,List<Account_Create_Request__c>> getAccountRequestQueueByAccountId(Set<Id> accountRequestIds, String queryFields){
        Map<Id,List<Account_Create_Request__c>> accountRequestQueueByAccountId = new Map<Id,List<Account_Create_Request__c>>();
        try{
            String formattedDate = getFormattedDate();
            String query = String.format('SELECT {0} FROM Account_Create_Request__c Where Id IN :accountRequestIds ',new List<String>{queryFields});
            List<Account_Create_Request__c> AcountRequests = Database.query(query);
            // Create a map of AccountId By List of Account Requests.
            For(Account_Create_Request__c AccountRequestQueue : AcountRequests){
                if(accountRequestQueueByAccountId.containsKey(AccountRequestQueue.Id)){
                    List<Account_Create_Request__c> AccountRequestFromMap = accountRequestQueueByAccountId.get(AccountRequestQueue.Id);
                    AccountRequestFromMap.add(AccountRequestQueue);
                }else{
                    accountRequestQueueByAccountId.put(AccountRequestQueue.Id,new List<Account_Create_Request__c>{AccountRequestQueue});
                }
            }
        }catch(Exception ex){
            // UCD_ACM_Logger.error('UCD_ACM_AccountSelector','getBusinessTypesByAccountId','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),'AccountIds: '+accountIds.toString());
            // UCD_ACM_Logger.setLogDetails();
        }
        
        if(accountRequestQueueByAccountId.size() > 0){
            return accountRequestQueueByAccountId;
        }
        return null;
    }
    
}