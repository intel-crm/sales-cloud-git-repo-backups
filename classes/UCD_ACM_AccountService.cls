public without sharing class UCD_ACM_AccountService implements UCD_ACM_ServiceContracts.IAccountService {
    private static UCD_ACM_ServiceContracts.IAccountService instance = null;
    private UCD_ACM_AccountService() {} 

    private static UCD_ACM_Models.BusinessOrganizationResponseforService modelResponse = new UCD_ACM_Models.BusinessOrganizationResponseforService();
    private static UCD_ACM_DomainContracts.IAccountDomain accountDomianInstance = UCD_ACM_AccountDomain.getInstance();
    private static UCD_ACM_SelectorContracts.IAccountQuerySelector accountQuerySelectorInstance = UCD_ACM_AccountQuerySelector.getInstance();
    private static UCD_ACM_SelectorContracts.IAccountMutationSelector accountMutationSelectorInstance = UCD_ACM_AccountMutationSelector.getInstance();

    public static boolean isTestException = false;
    public static Id intelAccountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    public static Id endCustomerRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('End Customer Deal Account').getRecordTypeId();
    public static Id requestedAccountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Requested Account').getRecordTypeId();

    public static UCD_ACM_ServiceContracts.IAccountService getInstance(){
        if (instance  == null){
            instance  = new UCD_ACM_AccountService();
        }
        return instance;
    }

   /*
    * description : Based on CustomerAgregationTypeCode  call next class for validation and create Accounts
    * params : List<UCD_ACM_Models.AccountModel> accountModel
    * return : UCD_ACM_Models.AccountResponseModel
    * author and date : ankit1x.sharma@intel.com, 06 Dec 2021
    */
    public List <UCD_ACM_Models.BusinessOrganizationResponseforService> createBusinessOrganizationRequest (List<UCD_ACM_Models.AccountModel> accountModel) {
        List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse = new List<UCD_ACM_Models.BusinessOrganizationResponseforService>();
        List<UCD_ACM_Models.BusinessOrganizationResponseforService> validResponse = new List<UCD_ACM_Models.BusinessOrganizationResponseforService>();   
        List<UCD_ACM_Models.AccountModel> validAccountRequests = new List<UCD_ACM_Models.AccountModel>();      
        try{
                Map<String, List<UCD_ACM_Models.AccountModel>> accountRequestByAggregationType = new Map<String, List<UCD_ACM_Models.AccountModel>>();
                for(UCD_ACM_Models.AccountModel request:accountModel){
                    if(accountRequestByAggregationType.containsKey(request.CustomerAggregationTypeCode))
                    accountRequestByAggregationType.get(request.CustomerAggregationTypeCode).add(request);
                    else
                    accountRequestByAggregationType.put(request.CustomerAggregationTypeCode, new List<UCD_ACM_Models.AccountModel>{request});
                }
                for(String aggregationType: accountRequestByAggregationType.KeySet()){
                    UCD_ACM_ServiceContracts.ICustomerAggregationType customerAggregationType = getAggregationServiceInstance(aggregationType);
                    validResponse.addall(customerAggregationType.createBusinessOrganizationRequest(accountRequestByAggregationType.get(aggregationType),validAccountRequests,  invalidResponse));
                    if(invalidResponse.size()>0)
                        UCD_ACM_Logger.warning('UCD_ACM_AccountService','createBusinessOrganizationRequest',invalidResponse.toString(),NULL);
                }
                throwTestException();
    
        }catch(Exception ex){
            invalidResponse.add(modelResponse.mapAccountsToAccountResponseModel (null, '', '',ex.getMessage(),'',null) );
            validResponse.addAll(invalidResponse);
            UCD_ACM_Logger.error('UCD_ACM_AccountService','createBusinessOrganizationRequest','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        }finally{
            UCD_ACM_Logger.setLogDetails();
        }
        return validResponse;
    }
   /*
    * description : Based on CustomerAgregationTypeCode  Identify the class
    * params : String aggregationType
    * return :  UCD_ACM_ServiceContracts.ICustomerAggregationType
    * author and date : ankit1x.sharma@intel.com, 06 Dec 2021
    */
    private UCD_ACM_ServiceContracts.ICustomerAggregationType getAggregationServiceInstance(String aggregationType) {
        switch on aggregationType {
            when 'UNFD_CTRY_CUST' {
                return UCD_ACM_CountryAccount.getInstance();
            }
            when else {
                return UCD_ACM_CountryAccount.getInstance();
            }
        }
    }
    

    /*
    * description : Get the account Data to publish platform event from UCD_ACM_CompWatchListTriggerHandler and 
                    UCD_ACM_AccountBusinessTypeHandler
    * params : Set<Id>
    * return : List<Account>
    * author and date : harshalx.sunil.gosavi@intel.com, 23 Nov 2021
    */
    public static List<Account> getAccountsToPublishEvent(Set<Id> accountIds){
        try{
            String queryFields = 'Id, Name,Core_Survivor_Account_Id__c, Core_Business_Party_Id__c, Core_Customer_Aggregation_Type__c, ParentId, RecordTypeId, Core_Data_Simplified_Account_Nm__c,Core_Parent_Business_Party_Id__c,Core_Parent_Data_Simplified_Account_Nm__c, Core_Data_Country_Nm__c, BillingCountryCode, BillingCountry,ShippingCountryCode,ShippingCountry, Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,Core_Data_Simplified_Local_Language_Nm__c,Unified_Hierarchy_View__c,Core_Account_Reference_Source_Name__c';
            String andClause = 'Core_Customer_Aggregation_Type__c != null and (RecordType.Name = \'End Customer Deal Account\' OR RecordType.Name = \'Rejected Account\')';
            Map<Id,Account> accountById = accountQuerySelectorInstance.getAccountsByIds(accountIds,queryFields,andClause);
            if(accountById != null){
                return accountById.values();
            }
            throwTestException();
            return null;
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_AccountService','getAccountsToPublishEvent','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),'AccountIds: '+accountIds.toString());
        }finally{
            UCD_ACM_Logger.setLogDetails();
        }
        return null;
    }
    /*
    * description : If Business Party Id is already present in salesforce then change the recordType
    *               to RejectedAccount otherwise it is EndCustomer.
    * params : Account
    * return : Account
    * author and date : harshalx.sunil.gosavi@intel.com, 23 Nov 2021
    */

    public void updateAccRecordTypeByBpId(List<Account> accounts,Map<Id,Account> oldAccountById){
        try{
            Set<String> accountsBpId = new Set<String>();
            Map<String,List<Account>> accountsByBpId = new Map<String,List<Account>>();
            
            For(Account acc : accounts){
                if(acc.Core_Business_Party_Id__c != null){
                    accountsBpId.add(acc.Core_Business_Party_Id__c);
                }
            }
            if(accountsBpId.size() > 0){
                accountsByBpId = accountQuerySelectorInstance.getAccountByBpId(accountsBpId);
            }
            
            For(Account account : accounts){
                if(accountsByBpId != null && accountsByBpId.size() > 0 && accountsByBpId.containsKey(account.Core_Business_Party_Id__c)){
                    For(Account siblingAccount : accountsByBpId.get(account.Core_Business_Party_Id__c)){
                        if(account.Core_Business_Party_Id__c != null && oldAccountById!= null &&  oldAccountById.get(account.Id)!= null && oldAccountById.get(account.Id).RecordTypeId == requestedAccountRecordType && account.RecordTypeId == endCustomerRecordType && siblingAccount.RecordTypeId == endCustomerRecordType){
                            account.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Rejected Account').getRecordTypeId();
                            account.Core_Survivor_Account_Id__c = siblingAccount.Id;
                            account.Core_Account_Request_Rejection_Reason__c = 'DUP';
                            break;
                        }
                    }
                }					
            }
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_AccountService','updateAccRecordTypeByBpId','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),'AccountIds: '+ oldAccountById != null ? oldAccountById.keySet()+'' : '');
        }finally{
            UCD_ACM_Logger.setLogDetails();
        }
    }

    /*
    * description : Read API Response Construction.
    * params : requestModel
    * return : BusinessOrganizationResponse
    * author and date : Saranya Ramaiah, 3rd November 2021
    */
    public UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse getBusinessOrganization(UCD_ACM_BusinessOrganizationModel requestModel){
        try{
            UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse response = new UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse();
            response.Status = '200';
            response.ExecutionTime = null;
            response.InternalTxnID = '999345-AF9875-H2478-F245A';
            List<UCD_ACM_BusinessOrganizationModel.ResponseData> lstresponseData = new List<UCD_ACM_BusinessOrganizationModel.ResponseData>();
            
            List<UCD_ACM_BusinessOrganizationModel.AttributesData> AttributeList = requestModel.Attributes;
            Set<Id> AccountId = new Set<Id>();
            for(Integer i = 0 ; i< requestModel.BusinessOrganization.AccountId.size(); i++){ 
                AccountId.add(requestModel.BusinessOrganization.AccountId[i]);
            }
            
            Map<String, UCD_Business_Organization_API__mdt> MetaMap = UCD_Business_Organization_API__mdt.getAll();
            List<UCD_Business_Organization_API__mdt> MetaList = new List<UCD_Business_Organization_API__mdt>();
            for(String Meta: MetaMap.keySet()){
                MetaList.add(MetaMap.get(Meta));
            }   
            String FieldString = '' ;
            List<String> FieldList = new List<String>();
            Set<String> FieldSet = new Set<String>();
            String FieldListCompliance = '' ;
            String FieldListEngagement = '' ;
            for(UCD_Business_Organization_API__mdt Meta:MetaList){
                for(UCD_ACM_BusinessOrganizationModel.AttributesData Atti:AttributeList){
                    if(Atti.AttributeName == Meta.Account_Attributes__c && Meta.Object_Name__c == 'Account'){
                        FieldSet.add(Meta.Field_API_Name__c);
                    }
                    else if (Atti.AttributeName == Meta.Account_Attributes__c && Meta.Object_Name__c == 'Compliance Watch List' ){
                        if(FieldListCompliance == ''){
                            FieldListCompliance = Meta.Field_API_Name__c;
                        }
                        else{
                            FieldListCompliance = FieldListCompliance + ',' +Meta.Field_API_Name__c;
                        }
                    }
                    else if (Atti.AttributeName == Meta.Account_Attributes__c && Meta.Object_Name__c == 'Account Business Types' ){
                        if(FieldListEngagement == ''){
                            FieldListEngagement = Meta.Field_API_Name__c;
                        }
                        else{
                            FieldListEngagement = FieldListEngagement + ',' +Meta.Field_API_Name__c;
                        }
                    }
                }
            }
            
            FieldList.addall(FieldSet); 
            for(Integer i=0;i<FieldList.Size();i++){
                if(FieldString == ''){
                    FieldString = FieldList[i];
                }
                else{
                    FieldString= FieldString + ',' + FieldList[i];
                }
            }
            Map<Id,Account> AccountMap = new Map<Id,Account>();
            if(FieldString != ''){
                AccountMap= accountQuerySelectorInstance.getAccountsByIds(AccountId,FieldString);
            }
            Map<Id,List<Core_Account_Compliance_Watch_List__c>> ComplianceMap  = new Map<Id,List<Core_Account_Compliance_Watch_List__c>>();
            Map<Id,List<Business_Types__c>> EngagementMap  = new Map<Id,List<Business_Types__c>>();
            if(FieldListCompliance != ''){
            ComplianceMap = accountQuerySelectorInstance.getComplianceWatchListByAccountId(AccountId,FieldListCompliance);
            }
            if(FieldListEngagement!= ''){
            EngagementMap = accountQuerySelectorInstance.getBusinessTypesByAccountId(AccountId,FieldListEngagement);
            }
            
            for(Integer i = 0 ; i< requestModel.BusinessOrganization.AccountId.size(); i++){    
                UCD_ACM_BusinessOrganizationModel.ResponseData  responseData = new UCD_ACM_BusinessOrganizationModel.ResponseData();
                    responseData.Id = requestModel.BusinessOrganization.AccountId[i];
                    
                    List<UCD_ACM_BusinessOrganizationModel.AccountAddressInformation> accountAddressesInfo = new  List<UCD_ACM_BusinessOrganizationModel.AccountAddressInformation>();                   
                    List<UCD_ACM_BusinessOrganizationModel.AccountComplianceDetails> AccountCompliancesInfo= new  List<UCD_ACM_BusinessOrganizationModel.AccountComplianceDetails>();                     
                    List<UCD_ACM_BusinessOrganizationModel.cusProcEng> cusProcEngInfo= new  List<UCD_ACM_BusinessOrganizationModel.cusProcEng>();                     
                    if(AccountMap != null){
                    Account accInfo = AccountMap.get(requestModel.BusinessOrganization.AccountId[i]);
                    
                    List<Core_Account_Compliance_Watch_List__c> complist = new List<Core_Account_Compliance_Watch_List__c>();
                    if(ComplianceMap != null && ComplianceMap.get(requestModel.BusinessOrganization.AccountId[i]) != null){
                        complist = ComplianceMap.get(requestModel.BusinessOrganization.AccountId[i]);
                    }
                    
                    List<Business_Types__c> Engagelist = new List<Business_Types__c>();
                    if(EngagementMap != null && EngagementMap.get(requestModel.BusinessOrganization.AccountId[i]) != null){
                        Engagelist = EngagementMap.get(requestModel.BusinessOrganization.AccountId[i]);
                    }
                        for(UCD_ACM_BusinessOrganizationModel.AttributesData attribute : requestModel.Attributes){
                            if( attribute.AttributeName == 'AccountInformation' ){
                                UCD_ACM_BusinessOrganizationModel.AccountInformationData accountInfoData = new UCD_ACM_BusinessOrganizationModel.AccountInformationData();
                                accountInfoData.AccountName = accInfo.Name;
                                accountInfoData.AccountOwner = accInfo.Owner.Name;
                                accountInfoData.AccountId = requestModel.BusinessOrganization.AccountId[i];
                                accountInfoData.BusinessPartyIdentifier = accInfo.Core_Business_Party_Id__c;
                                    UCD_ACM_BusinessOrganizationModel.CustAggType CustAggTypeData = new UCD_ACM_BusinessOrganizationModel.CustAggType();
                                    CustAggTypeData.Code = accInfo.Core_Customer_Aggregation_Type__c;
                                    CustAggTypeData.Name = UCD_ACM_Utils.getPicklistLabel('Account','Core_Customer_Aggregation_Type__c',accInfo.Core_Customer_Aggregation_Type__c);
                                accountInfoData.CustomerAggregationType =  CustAggTypeData;
                                if(EngageList.size()>0){
                                for(Business_Types__c eng:EngageList){
                                        UCD_ACM_BusinessOrganizationModel.cusProcEng EngageInfo = new UCD_ACM_BusinessOrganizationModel.cusProcEng();
                                        EngageInfo.Name = eng.Name;
                                        EngageInfo.Code = eng.Business_Type_Code__c;
                                        cusProcEngInfo.add(EngageInfo); 
                                    }
                                accountInfoData.CustomerProcessEngagement=  cusProcEngInfo;
                                }
                                responseData.AccountInformation = accountInfoData;
                                
                            }

                            if(attribute.AttributeName == 'AccountAddressInformation'){
                                accountAddressesInfo.add(getAccountAddressInfo(accInfo,'Billing'));
                                accountAddressesInfo.add(getAccountAddressInfo(accInfo,'Shipping'));
                                responseData.AccountAddressInformation = accountAddressesInfo;
                            }

                            if(attribute.AttributeName == 'ParentAccountInfomation'){
                                UCD_ACM_BusinessOrganizationModel.ParentAccountInfomation parentAccountInfo = new UCD_ACM_BusinessOrganizationModel.ParentAccountInfomation();
                                parentAccountInfo.AccountName = accInfo.Parent.Name;
                                parentAccountInfo.AccountId = accInfo.ParentId;
                                parentAccountInfo.AcocuntId = accInfo.ParentId;
                                parentAccountInfo.BusinessPartyIdentifier = accInfo.Core_Parent_Business_Party_Id__c;
                                parentAccountInfo.SimplifiedAccountName = accInfo.Core_Parent_Data_Simplified_Account_Nm__c;
                                responseData.ParentAccountInfomation = parentAccountInfo;
                            }

                            if(attribute.AttributeName == 'AccountMasteredDetails'){
                                UCD_ACM_BusinessOrganizationModel.AccountMasteredDetails accountMasterInfo = new UCD_ACM_BusinessOrganizationModel.AccountMasteredDetails();
                                
                                accountMasterInfo.SimplifiedAccountName = accInfo.Core_Data_Simplified_Account_Nm__c;
                                accountMasterInfo.BusinessPartyIdentifier = accInfo.Core_Business_Party_Id__c;
                                UCD_ACM_BusinessOrganizationModel.Address address = new UCD_ACM_BusinessOrganizationModel.Address();
                                address.CountryCode = null;
                                address.CountryName = accInfo.Core_Data_Country_Nm__c;
                                accountMasterInfo.Address = address;
                                accountMasterInfo.SimplifiedLocalLanguageName = accInfo.Core_Data_Simplified_Local_Language_Nm__c;
                                accountMasterInfo.UnifiedHierarchy = accInfo.Unified_Hierarchy_View__c;

                                responseData.AccountMasteredDetails = accountMasterInfo;
                            }

                            if(attribute.AttributeName == 'AccountComplianceDetails'){
                                if(complist.size()>0){
                                    for(Core_Account_Compliance_Watch_List__c comp:compList){
                                        UCD_ACM_BusinessOrganizationModel.AccountComplianceDetails accountComplianceInfo = new UCD_ACM_BusinessOrganizationModel.AccountComplianceDetails();
                                        accountComplianceInfo.Name = UCD_ACM_Utils.getPicklistLabel('Core_Account_Compliance_Watch_List__c','Core_Type__c',comp.Core_Type__c);
                                        accountComplianceInfo.Code = comp.Core_Type__c;
                                        accountCompliancesInfo.add(accountComplianceInfo); 
                                    }
                                    responseData.AccountComplianceDetails = accountCompliancesInfo;
                                }
                                
                            }
                            }
                    }
                    lstresponseData.add(responseData);
            }
            
            response.Data = lstresponseData;
            throwTestException();
            return response;
        }catch(exception ex){
            UCD_ACM_Logger.error('UCD_ACM_AccountService','getBusinessOrganization','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        }finally{
            UCD_ACM_Logger.setLogDetails();
        }
        return null;
    }
    /*
    * description : Account Address construction for Read ApI Response
    * params : Account & String
    * return : AccountAddressInformation
    * author and date : Saranya Ramaiah, 3rd November 2021
    */
    private UCD_ACM_BusinessOrganizationModel.AccountAddressInformation getAccountAddressInfo(Account accInfo,String type){
        if(type != null && accInfo != null){
            UCD_ACM_BusinessOrganizationModel.AccountAddressInformation accountAddressInfo = new UCD_ACM_BusinessOrganizationModel.AccountAddressInformation();
            accountAddressInfo.AddressType = type == 'Billing'?'Billing':'Shipping';
            accountAddressInfo.Street = type == 'Billing'?accInfo.BillingStreet:accInfo.ShippingStreet;
            accountAddressInfo.City = type == 'Billing'?accInfo.BillingCity:accInfo.ShippingCity;
            accountAddressInfo.StateCode = type == 'Billing'?accInfo.BillingStateCode:accInfo.ShippingStateCode;
            accountAddressInfo.StateName = type == 'Billing'?accInfo.BillingState:accInfo.ShippingState;
            accountAddressInfo.CountryName = type == 'Billing'?UCD_ACM_Utils.validateCountryCode(accInfo.BillingCountry) == null?accInfo.BillingCountry:UCD_ACM_Utils.validateCountryCode(accInfo.BillingCountry):UCD_ACM_Utils.validateCountryCode(accInfo.ShippingCountry) == null ? accInfo.ShippingCountry :UCD_ACM_Utils.validateCountryCode(accInfo.ShippingCountry) ;
            accountAddressInfo.Countrycode = type == 'Billing'?accInfo.BillingCountryCode:accInfo.ShippingCountryCode;
            accountAddressInfo.ZipCode = type == 'Billing'?accInfo.BillingPostalCode:accInfo.ShippingPostalCode;
            return accountAddressInfo;
        }
        return null; 
    }
    /*
    * description : Publish Platform Events.
    * params : Set<Id>
    * return : NA
    * author and date : harshalx.sunil.gosavi@intel.com, 4th August 2021
    */

    //@future
    public static void publishAccountChangeEvent(Set<Id> accountIds) {

        //Create Instance for AccountSelector and initialize models and platform event class
        UCD_ACM_Models.AccountResponseModel model = new UCD_ACM_Models.AccountResponseModel();
        UCD_ACM_Models.PE_HeaderResponse headerModel = new UCD_ACM_Models.PE_HeaderResponse();
        List<ACM_Account_Change_Event__e> accountChangeEvents  = new List<ACM_Account_Change_Event__e>();
        List<Database.SaveResult> eventPublishResultList = new List<Database.SaveResult>();
        List<String> eventPayloads=new List<String>();
        // //Get List of Accounts
         List<Account> accounts = new List<Account>();
         accounts = getAccountsToPublishEvent(accountIds); 

        // Fetch parent account details        
        Set<Id> parentAccountIds = new Set<Id>();
        if(accounts!=null){
            for (Account acct : accounts) {
                parentAccountIds.add(acct.ParentId);
            }
            
            try {
                Map<Id, Account> parentAccountById = accountQuerySelectorInstance.getAccountsByIds(parentAccountIds, model.getParentAccountQueryForEvent());
                Map<Id,List<Business_Types__c>> businessTypesByAccountId = accountQuerySelectorInstance.getBusinessTypesByAccountId(accountIds, model.getAccountBusinessTypesQueryForEvent());
                Map<Id,List<Core_Account_Compliance_Watch_List__c>> complianceWatchListByAccountId = accountQuerySelectorInstance.getComplianceWatchListByAccountId(accountIds, model.getComplianceWatchListQueryForEvent());
                // Publish event 
                For(Account account: accounts) {
                    UCD_ACM_Models.PE_HeaderResponse mappedHeaderResponse = new UCD_ACM_Models.PE_HeaderResponse();
                    UCD_ACM_Models.AccountResponseModel mappedResponse = UCD_ACM_AccountDomain.mapAccountResponseModel(account,parentAccountById,businessTypesByAccountId,complianceWatchListByAccountId);
                    mappedHeaderResponse = businessTypesByAccountId != null && businessTypesByAccountId.containsKey(account.Id) && businessTypesByAccountId.get(account.Id).size() > 0?headerModel.mapAccountsToHeaders(account,businessTypesByAccountId.get(account.Id)):headerModel.mapAccountsToHeaders(account,null);
                    ACM_Account_Change_Event__e accountChangeEvent=new ACM_Account_Change_Event__e(Message__c = JSON.serialize(mappedResponse,true),Headers__c = JSON.serialize(mappedHeaderResponse,true));
                    accountChangeEvents.add(accountChangeEvent);
                    eventPayloads.add(accountChangeEvent.Message__c);
                }
                //call the publish event method
                
                If(accountChangeEvents.size() > 0) {    
                    eventPublishResultList = EventBus.publish(accountChangeEvents);
                }

                if(eventPublishResultList.size() > 0){
                    for (Database.SaveResult sr : eventPublishResultList) {
                        if (sr.isSuccess()) {
                            accountMutationSelectorInstance.updateIntegrationMsgQueueStatus(accountIds,'Success');
                            UCD_ACM_Logger.warning('UCD_ACM_AccountService','publishAccountChangeEvent','Account Change Event publish successfully for accounts :'+accountIds.toString()+'.Payload:'+eventPayloads,'AccountIds: '+accountIds.toString());
                            break;
                        }else {
                            // This method update the IntegrationMessageQueue status with error.
                            accountMutationSelectorInstance.updateIntegrationMsgQueueStatus(accountIds,'Error');

                            String errorMessage = '';
                            For(Database.error error : sr.getErrors()){
                                errorMessage += error.getMessage();
                            }
                            UCD_ACM_Logger.error('UCD_ACM_AccountService','publishAccountChangeEvent',errorMessage+' Failed Account Ids :'+accountIds.toString(),'AccountIds: '+accountIds.toString());
                            break;
                        }
                    }


                }
                throwTestException();
            }
            catch (Exception ex) {
                UCD_ACM_Logger.error('UCD_ACM_AccountService','publishAccountChangeEvent','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString()+' Failed Account Ids :'+accountIds.toString(),'AccountIds: '+accountIds.toString());
            }finally{
                UCD_ACM_Logger.setLogDetails(); 
            }
        }
    }
    /*
     * description : Ignore updating Name/Billing/Shipping Address/Account Owner if existing UCD SF record.
     * params : List<Account> newValues, List<Account> oldvalues
     * return : NA
     * author and date : ankit1x.sharma@intel.com, 20/11/2021
     */
    public void restrictUpdatingSFFields(List<Account> newValues, List<Account> oldvalues){
        try{
            accountDomianInstance.restrictUpdatingSFFields(newValues,oldvalues);
            throwTestException();
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_AccountService','restrictUpdatingSFFields','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        }finally{
            UCD_ACM_Logger.setLogDetails();
        }
    }
   
    /*
    /*
     * description : Set UCD hierarchy fields for child accounts
     * params : Id parentAccId
     * author and date : chethan.s.kunder@intel.com, 1 Dec 2021
     
    @future
    private static void updateHierarchyFieldsForChildAccounts(Id parentAccId) {  
        Set<Id> parentAccountIds = new Set<Id>();
        parentAccountIds.add(parentAccId);      
        Map<Id, Account> mChildAccounts = getAllChildAccounts(parentAccountIds);
        if(mChildAccounts <> null && mChildAccounts.Values().size() > 0) {
            Map<Id, Account> mAccountsToUpdate = new Map<Id, Account>();
            for (Id acctId: mChildAccounts.keySet()) {
                Account acct = mChildAccounts.get(acctId);
                Account parentAcct = acct.ParentId <> null ? mChildAccounts.get(acct.ParentId) : null;
                setHierarchyFields(acct, parentAcct);            
                mAccountsToUpdate.put(acctId, acct);
                UCD_ACM_Logger.information('UCD_ACM_AccountService','updateHierarchyFieldsForChildAccounts','AFTER - Account Added for Update - ID:' + acctId,'AccountIds: '+acctId);
            }            
            if(mAccountsToUpdate <> null && mAccountsToUpdate.Values().size() > 0) {
                try {
                    update mAccountsToUpdate.Values();
                } catch(DMLException e) {
                    UCD_ACM_Logger.error('UCD_ACM_AccountService', 'updateHierarchyFieldsForChildAccounts', 'Message: '+e.getMessage()+'. StackTrace: '+e.getStackTraceString(),'ParentAccountIds: '+parentAccountIds.toString());
                }
                finally {
                    UCD_ACM_Logger.setLogDetails();
                }        
            }
        }
    }*/

    /*
     * description : Get all child accounts for an account
     * params : Id parentAccId
     * author and date : chethan.s.kunder@intel.com, 1 Dec 2021
     
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
    }*/

    /*
     * description : Set UCD hierarchy fields
     * params : Account
     * author and date : chethan.s.kunder@intel.com, 25 Nov 2021
     * Updated : chethan.s.kunder@intel.com, 01 Dec 2022 - New UCD hierachy attributes integration
     
    public static void setHierarchyFields(Account account, Account parentAcct) {
        UCD_ACM_Logger.information('UCD_ACM_AccountService','setHierarchyFields','Account:ID: '+account.Id +' and AccountCustAggrType :' + account.Core_Customer_Aggregation_Type__c,'AccountIds: '+account.Id);
        if(parentAcct == null) {
            Set<Id> parentAccountIds = new Set<Id>();
            parentAccountIds.add(account.ParentId);              
            UCD_ACM_Models.AccountResponseModel model = new UCD_ACM_Models.AccountResponseModel(); 
            parentAcct = accountQuerySelectorInstance.getAccountsByIds(parentAccountIds, model.getParentAccountQueryForEvent()).get(account.ParentId);
        }        
        string parentCustAggrType = parentAcct.Core_Customer_Aggregation_Type__c;
        Boolean hasSecondaryIntermediateParent = parentCustAggrType == 'UNFD_INTRMD_CUST' ? hasSecondaryIntermediateParent(parentAcct) : false;
        UCD_ACM_Logger.information('UCD_ACM_AccountService','setHierarchyFields','ParentCustAggrType:' + parentCustAggrType,'AccountIds: '+account.Id);
        account.Core_Unified_Global_Customer__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? parentAcct.Id : parentAcct.Core_Unified_Global_Customer__c;
        account.Core_Unified_Global_Customer_BP_Id__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? parentAcct.Core_Business_Party_Id__c : parentAcct.Core_Unified_Global_Customer__r.Core_Business_Party_Id__c;
        account.Core_Unified_Global_Customer_Name__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? parentAcct.Core_Data_Simplified_Account_Nm__c : parentAcct.Core_Unified_Global_Customer__r.Core_Data_Simplified_Account_Nm__c;
       
        switch on account.Core_Customer_Aggregation_Type__c {
            when 'UNFD_LOC_CUST' {
                account.Core_Unified_Country_Customer__c = parentCustAggrType == 'UNFD_CTRY_CUST' ? parentAcct.Id : null;
                account.Core_Unified_Intermediate_Customer__c = parentCustAggrType == 'UNFD_INTRMD_CUST' ? parentAcct.Id : parentAcct.Core_Unified_Intermediate_Customer__c;  
                account.Core_Unified_Intermediate_Customer_2__c = hasSecondaryIntermediateParent ? parentAcct.ParentId : parentAcct.Core_Unified_Intermediate_Customer_2__c;
            }
            when 'UNFD_CTRY_CUST' {
                account.Core_Unified_Intermediate_Customer__c = hasSecondaryIntermediateParent ? parentAcct.ParentId : (parentCustAggrType == 'UNFD_INTRMD_CUST' ? parentAcct.Id : null);             
                account.Core_Unified_Intermediate_Customer_2__c = hasSecondaryIntermediateParent ? parentAcct.Id : null;
                account.Core_Unified_Intermediate_Customer_BP_Id__c = hasSecondaryIntermediateParent ? parentAcct.Core_Unified_Intermediate_Customer__r.Core_Business_Party_Id__c: (parentCustAggrType == 'UNFD_INTRMD_CUST' ? parentAcct.Core_Business_Party_Id__c : null);
                account.Core_Unified_Intermediate_Customer_Name__c = hasSecondaryIntermediateParent ? parentAcct.Core_Unified_Intermediate_Customer__r.Core_Data_Simplified_Account_Nm__c: (parentCustAggrType == 'UNFD_INTRMD_CUST' ? parentAcct.Core_Data_Simplified_Account_Nm__c : null);
             }
            when 'UNFD_INTRMD_CUST' {
                account.Core_Unified_Intermediate_Customer__c = parentCustAggrType == 'UNFD_INTRMD_CUST' ? parentAcct.Id : null;                
                account.Core_Unified_Intermediate_Customer_2__c = null;
                account.Core_Unified_Intermediate_Customer_BP_Id__c = parentCustAggrType == 'UNFD_INTRMD_CUST'? parentAcct.Core_Business_Party_Id__c:account.Core_Business_Party_Id__c;
                account.Core_Unified_Intermediate_Customer_Name__c =parentCustAggrType == 'UNFD_INTRMD_CUST' ? parentAcct.Core_Data_Simplified_Account_Nm__c :account.Core_Data_Simplified_Account_Nm__c;
            }
         }
    }*/

    /**
     * description : To check if an intermediate account has secondary intermediate parent
     * params : Account
     * author and date : chethan.s.kunder@intel.com, 15 Mar 2022
     
    public static Boolean hasSecondaryIntermediateParent(Account parentAccount){
        if(parentAccount.ParentId == null){
            return false;
        }
        Map<Id, Account> parent2AccountById = new Map<Id,Account>();
        Set<Id> parent2AccountIds = new Set<Id>();
        parent2AccountIds.add(parentAccount.ParentId);              
        UCD_ACM_Models.AccountResponseModel model = new UCD_ACM_Models.AccountResponseModel(); 
        parent2AccountById = accountQuerySelectorInstance.getAccountsByIds(parent2AccountIds, model.getParentAccountQueryForEvent());
        return parent2AccountById.get(parentAccount.ParentId).Core_Customer_Aggregation_Type__c == 'UNFD_INTRMD_CUST';
    }*/
    
    public static Map<Id,Account> getAccountMap(Set<Id> accountIds, String queryFields){
        try{
            Map<Id,Account> accountById = accountQuerySelectorInstance.getAccountsByIds(accountIds,queryFields);
            if(accountById != null){
                return accountById;
            }
            return null;
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_AccountService','getAccountMap','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),'AccountIds: '+accountIds.toString());
        }finally{
            UCD_ACM_Logger.setLogDetails();
        }
        return null;
    }

    public static Map<Id,Business_Types__c> getBusinessTypeMap(Set<Id> businessTypeIds, String queryFields){
        try{
            Map<Id,Business_Types__c> businessTypeById = accountQuerySelectorInstance.getBusinessTypeById(businessTypeIds,queryFields);
            if(businessTypeById != null){
                return businessTypeById;
            }
            return null;
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_AccountService','getBusinessTypeMap','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        }finally{
            UCD_ACM_Logger.setLogDetails();
        }
        return null;
    }

    private static void throwTestException(){
        if(Test.isRunningTest() && isTestException)
			{
				throw new NoDataFoundException();
			}
    }
    
    /** 
    * description : Insert or Update the Status of  UCD_ACM_Outbound__c
    * params : Set<Id> accountIds
    * return : void
    * author and date : harshalx.sunil.gosavi@intel.com 08/02/2022.
    */
    public void updateACMIntegrationMessage(Set<Id> accountIds){
        accountMutationSelectorInstance.setIntegrationMessage(accountIds);
    }

    /** 
    * description : This method sync parent attribute SF accounts with Reltio. Method is called after-update trigger
    * params : List<Account> updatedParentAccountsInMDM, List<Account> mergedAccountsInMDM,Set<String> currentAccountsBpIds,Set<Id> parentAcountIds
    * return : void
    * author and date : yashvir.pathak@intel.com 15 June 2022.
    */
    public void onUpdatedOrMergedAccountsInMDM(List<Account> updatedParentAccountsInMDM, List<Account> mergedAccountsInMDM,Set<String> currentAccountsBpIds,Set<Id> parentAcountIds) {
        String message = 'Enter method. updatedParentAccountsInMDM - ' + updatedParentAccountsInMDM + '' +'. mergedAccountsInMDM - '+mergedAccountsInMDM + ''+'. currentAccountsBpIds - '+currentAccountsBpIds + ''+'. parentAcountIds - '+parentAcountIds + '';
        UCD_ACM_Logger.information('UCD_ACM_AccountService','onUpdatedOrMergedAccountsInMDM',message, 'TriggerData');
        // change unitofwork logic
        UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
        Set<String> parentAccountsBpIds = new Set<String>();
        Map<Id,Account> parentAccountById = new Map<Id,Account>();
        Map<String,List<Account> > parentAccountsByBpId = new Map<String,List<Account> >();
        Map<String,List<Account> > accountsByBpId = new Map<String,List<Account> >();
        try {
            // Get the parent accounts
            if (parentAcountIds != null && parentAcountIds.size() > 0) {
                parentAccountById = accountQuerySelectorInstance.getAccountsByIds(parentAcountIds,'Id,Name,RecordTypeId,Core_Business_Party_Id__c');
                // Create a set for BPIds of Parent Account
                for (Account parentAccount : parentAccountById.values()) {
                    if (parentAccount.Core_Business_Party_Id__c != null && parentAccount.Core_Business_Party_Id__c != '') {
                        parentAccountsBpIds.add(parentAccount.Core_Business_Party_Id__c);
                    }
                }
            }
            // Get the Siblings of account parents based on BPIds
            if (parentAccountsBpIds != null && parentAccountsBpIds.size() > 0)
                parentAccountsByBpId = accountQuerySelectorInstance.getAccountByBpId(parentAccountsBpIds);
            // Get the Siblings of current Account based on BPIds
            if (currentAccountsBpIds != null && currentAccountsBpIds.size() > 0)
                accountsByBpId = accountQuerySelectorInstance.getAccountByBpId(currentAccountsBpIds);

            // call domain class to set parent
            accountDomianInstance.setParentOnUpdateOrMergeInMDM(unitwork, updatedParentAccountsInMDM, mergedAccountsInMDM, parentAccountById, parentAccountsByBpId, accountsByBpId);
            
            // Update accounts
            unitwork.commitWork();
        }
        catch (Exception ex) {
            UCD_ACM_Logger.error('UCD_ACM_AccountService','onUpdatedOrMergedAccountsInMDM','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        }
        finally {
            UCD_ACM_Logger.setLogDetails();
        }
    }

    public static Map<Id,List<Business_Types__c>> getActiveBusinessTypeForAccount(Set<Id> accountIds) {
        UCD_ACM_Models.AccountResponseModel model = new UCD_ACM_Models.AccountResponseModel();
        return accountQuerySelectorInstance.getBusinessTypesByAccountId(accountIds, model.getAccountBusinessTypesQueryForEvent());
    }
    
    public Map<Id,String> getComplianceWatchListByAccountId(Set<Id> accountIds){
        List<Schema.PicklistEntry> watchlistTypes = Core_Account_Compliance_Watch_List__c.Core_Type__c.getDescribe().getPicklistValues();
        Map<String,String> complianceWatchListLabelByType = new Map<String,String>();
        For(Schema.PicklistEntry watchlistType : watchlistTypes){
            complianceWatchListLabelByType.put(watchlistType.getValue(), watchlistType.getLabel());
        }
        String query ='Id,Core_Account_Id__c,Core_Type__c,Core_Effective_End_Date__c';
        Map<Id,List<Core_Account_Compliance_Watch_List__c>> mapOfCompliancesByAccountId = accountQuerySelectorInstance.getComplianceWatchListByAccountId(accountIds,query);
        Map<Id,String> complianceWatchListByAccountId = new Map<Id,String>();
        For(Id accountId : accountIds){
            if(mapOfCompliancesByAccountId != null && mapOfCompliancesByAccountId.containsKey(accountId)){
                for(Core_Account_Compliance_Watch_List__c complianceWatchList : mapOfCompliancesByAccountId.get(accountId)){
                    if(complianceWatchListByAccountId.containsKey(accountId)){
                        String watchListType = complianceWatchListByAccountId.get(accountId);
                        watchListType = watchListType+', '+complianceWatchListLabelByType.get(complianceWatchList.Core_Type__c);
                        complianceWatchListByAccountId.put(accountId,watchListType);
                    }else{
                        complianceWatchListByAccountId.put(accountId,complianceWatchListLabelByType.get(complianceWatchList.Core_Type__c));
                    }
                }
            }
        }
        if(complianceWatchListByAccountId != null && complianceWatchListByAccountId.size() > 0){
            return complianceWatchListByAccountId;
        }
        return null;
    }


    /*
    * description : If account approves from Reltio then recordtype should be intel
    * params : Trigger.New
    * return : NA
    * author and date :ankit1x.sharma@intel.com, 10/11/2022
    */
    public void updateRecordtype(List<Account> newAccounts, Map<Id, Account> oldAccountById){
        try{
            accountDomianInstance.updateRecordtype( newAccounts,oldAccountById);
            throwTestException();
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_AccountService','updateRecordtype','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        }finally{
            UCD_ACM_Logger.setLogDetails();
        }
    }

    public void updateParentAccountRecordtype(List<Account> newAccounts, Map<Id, Account> oldAccountById){
        UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
        try{
            accountDomianInstance.updateParentAccountRecordtype(unitwork, newAccounts,oldAccountById);
             Boolean result =  unitwork.commitWork();
            throwTestException();
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_AccountService','updateParentAccountRecordtype','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        }finally{
            UCD_ACM_Logger.setLogDetails();
        }

    }
 }