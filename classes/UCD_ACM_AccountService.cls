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
        try{
                Map<String, List<UCD_ACM_Models.AccountModel>> accountRequestByAggregationType = new Map<String, List<UCD_ACM_Models.AccountModel>>();
                for(UCD_ACM_Models.AccountModel request:accountModel){
                    if(accountRequestByAggregationType.containsKey(request.CustomerAggregationTypeCode)){
                        accountRequestByAggregationType.get(request.CustomerAggregationTypeCode).add(request);
                    }else{
                        accountRequestByAggregationType.put(request.CustomerAggregationTypeCode, new List<UCD_ACM_Models.AccountModel>{request});
                    }
                }
                for(String aggregationType: accountRequestByAggregationType.KeySet()){
                    UCD_ACM_ServiceContracts.ICustomerAggregationType customerAggregationType = getAggregationServiceInstance(aggregationType);
                    validResponse.addall(customerAggregationType.createBusinessOrganizationRequest(accountRequestByAggregationType.get(aggregationType),  invalidResponse));
                    if(invalidResponse.size()>0){
                        UCD_ACM_Logger.warning('UCD_ACM_AccountService','createBusinessOrganizationRequest',invalidResponse.toString(),NULL);
                    }
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
            String queryFields = 'Id, Name,Core_Survivor_Account_Id__c, Core_Business_Party_Id__c, Core_Compliance_Watch_List_Type__c, Core_Customer_Aggregation_Type__c, ParentId, RecordTypeId, Core_Data_Simplified_Account_Nm__c,Core_Parent_Business_Party_Id__c,Core_Parent_Data_Simplified_Account_Nm__c, Core_Data_Country_Nm__c, BillingCountryCode, BillingCountry,ShippingCountryCode,ShippingCountry, Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,Core_Data_Simplified_Local_Language_Nm__c,Unified_Hierarchy_View__c,Core_Account_Reference_Source_Name__c,Core_Unified_Global_Customer_BP_Id__c,Core_Unified_Global_Customer_Name__c,Core_Unified_Intermediate_Customer_BP_Id__c,Core_Unified_Intermediate_Customer_Name__c,Core_Unified_Intermdt_Customer_2_BP_Id__c,Core_Unified_Intermdt_Customer_2_Name__c';
            String andClause = 'Core_Customer_Aggregation_Type__c != null and (RecordType.Name = \'End Customer Deal Account\'  OR RecordType.Name = \'Rejected Account\' OR RecordType.Name = \'Intel Account\' OR RecordType.Name = \'Inactive Account\')';
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
            Map<String, UCD_Business_Organization_Attribute__c> MetaMap = UCD_Business_Organization_Attribute__c.getAll();
            List<UCD_Business_Organization_Attribute__c> MetaList = new List<UCD_Business_Organization_Attribute__c>();
            for(String Meta: MetaMap.keySet()){
                MetaList.add(MetaMap.get(Meta));
            }   
            String acctAttrs = '' ;
            String cwlAttrs = '' ;
            String cpeAttrs = '' ;
            for(UCD_Business_Organization_Attribute__c Meta:MetaList){
                for(UCD_ACM_BusinessOrganizationModel.AttributesData Atti:AttributeList){
                    if(Atti.AttributeName == Meta.Account_Attributes__c && Meta.Object_API_Name__c == 'Account'){
                        acctAttrs = String.isNotBlank(acctAttrs) ? (acctAttrs + ',' + Meta.Field_API_Name__c) : Meta.Field_API_Name__c;
                    }
                    else if (Label.PerformScreeningFromCWLObject == 'true' && Atti.AttributeName == Meta.Account_Attributes__c && Meta.Object_API_Name__c == System.Label.Object_API_Name_CWL ){
                        cwlAttrs = String.isNotBlank(cwlAttrs) ? (cwlAttrs + ',' + Meta.Field_API_Name__c) : Meta.Field_API_Name__c;
                        }
                    else if (Atti.AttributeName == Meta.Account_Attributes__c && Meta.Object_API_Name__c == System.Label.Object_API_Name_CPE ){
                        cpeAttrs = String.isNotBlank(cpeAttrs) ? (cpeAttrs + ',' + Meta.Field_API_Name__c) : Meta.Field_API_Name__c;   
                        }
                    }
            }
            Map<Id,Account> AccountMap = new Map<Id,Account>();
            Map<Id,List<Core_Account_Compliance_Watch_List__c>> ComplianceMap  = new Map<Id,List<Core_Account_Compliance_Watch_List__c>>();
            Map<Id,List<Business_Types__c>> EngagementMap  = new Map<Id,List<Business_Types__c>>();
            if(String.isNotBlank(acctAttrs)){
                AccountMap= accountQuerySelectorInstance.getAccountsByIds(AccountId,acctAttrs);
            }
            if(String.isNotBlank(cwlAttrs)){
                ComplianceMap = accountQuerySelectorInstance.getComplianceWatchListByAccountId(AccountId,cwlAttrs);
            }
            if(String.isNotBlank(cpeAttrs)){
                EngagementMap = accountQuerySelectorInstance.getBusinessTypesByAccountId(AccountId,cpeAttrs);
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
                                if(Label.PerformScreeningFromCWLObject == 'true'){
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
                                else{
                                    if(accInfo.Core_Compliance_Watch_List_Type__c!=null){
                                        List<String> complianceWatchListValues=accInfo.Core_Compliance_Watch_List_Type__c.split(';');
                                        for(String cwlValue : complianceWatchListValues){
                                            UCD_ACM_BusinessOrganizationModel.AccountComplianceDetails accountComplianceInfo = new UCD_ACM_BusinessOrganizationModel.AccountComplianceDetails();
                                            accountComplianceInfo.Name=UCD_ACM_Utils.getPicklistLabel('Account','Core_Compliance_Watch_List_Type__c',cwlValue);
                                            accountComplianceInfo.Code = cwlValue;
                                            accountCompliancesInfo.add(accountComplianceInfo); 
                                        }
                                    }
                                    responseData.AccountComplianceDetails = accountCompliancesInfo;
                                }
                            }
                            if(attribute.AttributeName == 'AccountAddressInformation'){
                                accountAddressesInfo.add(getAccountAddressInfo(accInfo,'Billing'));
                                accountAddressesInfo.add(getAccountAddressInfo(accInfo,'Shipping'));
                                responseData.AccountAddressInformation = accountAddressesInfo;
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
                Map<Id,List<Core_Account_Compliance_Watch_List__c>> complianceWatchListByAccountId = Label.PerformScreeningFromCWLObject == 'true' ? accountQuerySelectorInstance.getComplianceWatchListByAccountId(accountIds, model.getComplianceWatchListQueryForEvent()) : null;
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
    * description : Publish Platform Events for Account Request Queue.
    * params : Set<Id>
    * return : Void
    * author and date : yenugantix.tejasri@intel.com, ajayx.gat@intel.com 09/01/2024.
    */
    public static void publishAccountRequestPlatformEvent(Set<Id> arqIds) {
            
        Set<Id> accountIds = new Set<Id>();
        Set<Id> parentAccountIds = new Set<Id>();
        List<ACM_Account_Request_Event__e> accountChangeEvents  = new List<ACM_Account_Request_Event__e>();
        List<Database.SaveResult> eventPublishResultList = new List<Database.SaveResult>();
        List<String> eventPayloads = new List<String>();
        Map<Id, Account> AccountsById = new Map<Id, Account>();
        Map<Id, Account> parentAccountById = new  Map<Id, Account>();
        Map<Id,List<Business_Types__c>> businessTypesByAccountId = new Map<Id,List<Business_Types__c>>();
        Map<Id,List<Core_Account_Compliance_Watch_List__c>> complianceWatchListByAccountId = new Map<Id,List<Core_Account_Compliance_Watch_List__c>>();

        //Create Instance for AccountSelector and initialize models and platform event class
        UCD_ACM_Models.AccountResponseModel model = new UCD_ACM_Models.AccountResponseModel();
        UCD_ACM_Models.PE_HeaderResponse headerModel = new UCD_ACM_Models.PE_HeaderResponse();

        try{
            String queryField = 'Id, Name, Requested_Account__c, Requested_Account__r.ParentId, Status__c, Rejected_Reason__c, Core_Account_Reference_Source_Name__c';
            Map<Id,Account_Create_Request__c> accountRequestsById = accountQuerySelectorInstance.getAccountRequestQueueById(arqIds, queryField);
            
            if(accountRequestsById != null) {
                For (Account_Create_Request__c accountRequest : accountRequestsById.values()) {
                    if (accountRequest.Requested_Account__c != null ) {
                        if (accountRequest.Requested_Account__r.ParentId != null) {
                            parentAccountIds.add(accountRequest.Requested_Account__r.ParentId);
                        }
                        accountIds.add(accountRequest.Requested_Account__c);
                    }
                }
            }
            
            // Fetch parent account details
            if(!accountIds.isEmpty()) {
                AccountsById = accountQuerySelectorInstance.getAccountsByIds(accountIds, model.getParentAccountQueryForEvent());

                if(!parentAccountIds.isEmpty()) {
                    parentAccountById = accountQuerySelectorInstance.getAccountsByIds(parentAccountIds, model.getParentAccountQueryForEvent());
                }

                businessTypesByAccountId = accountQuerySelectorInstance.getBusinessTypesByAccountId(accountIds, model.getAccountBusinessTypesQueryForEvent());
                complianceWatchListByAccountId = Label.PerformScreeningFromCWLObject == 'true' ? accountQuerySelectorInstance.getComplianceWatchListByAccountId(accountIds, model.getComplianceWatchListQueryForEvent()) : null;
            }

            // Publish event
            if(accountRequestsById != null) {
                For (Account_Create_Request__c accountRequest: accountRequestsById.values()) {
                    UCD_ACM_Models.PE_HeaderResponse mappedHeaderResponse = new UCD_ACM_Models.PE_HeaderResponse();
                    UCD_ACM_Models.AccountRequestQueueModel mappedResponse = new UCD_ACM_Models.AccountRequestQueueModel();
                    
                    Account account = AccountsById != null && accountRequest.Requested_Account__c != null && AccountsById.get(accountRequest.Requested_Account__c ) != null ? AccountsById.get(accountRequest.Requested_Account__c ) : null;

                    mappedResponse =  UCD_ACM_AccountDomain.mapAccountRequestQueueResponseModel(accountRequest, account, parentAccountById, businessTypesByAccountId, complianceWatchListByAccountId);
                    mappedHeaderResponse = accountRequest.Requested_Account__c != null ? businessTypesByAccountId != null && businessTypesByAccountId.containsKey(accountRequest.Requested_Account__c) && businessTypesByAccountId.get(accountRequest.Requested_Account__c).size() > 0  ? headerModel.mapAccountsToHeaders(account,businessTypesByAccountId.get(accountRequest.Requested_Account__c)): headerModel.mapAccountsToHeaders(account,null) : null;

                    ACM_Account_Request_Event__e accountChangeEvent = new ACM_Account_Request_Event__e(Message__c = JSON.serialize(mappedResponse,true),Headers__c = JSON.serialize(mappedHeaderResponse,true));
                    accountChangeEvents.add(accountChangeEvent);
                    eventPayloads.add(accountChangeEvent.Message__c);
                }
            }                 
            
            //call the publish event method
            if (!accountChangeEvents.isEmpty()) {   
                eventPublishResultList = EventBus.publish(accountChangeEvents);
            }
            
            if (!eventPublishResultList.isEmpty()) {
                for (Database.SaveResult sr : eventPublishResultList) {
                    if (sr.isSuccess()) {
                        accountMutationSelectorInstance.updateIntegrationMsgQueueStatusForARQ(arqIds,'Success');
                        UCD_ACM_Logger.information('UCD_ACM_AccountService','publishAccountRequestPlatformEvent','Account Change Event publish successfully for account request queues :'+'.Payload:'+eventPayloads,'arqIds: '+arqIds.toString());
                        break;
                    } else {
                        // This method update the IntegrationMessageQueue status with error.
                        accountMutationSelectorInstance.updateIntegrationMsgQueueStatusForARQ(arqIds,'Error');
                        String errorMessage = '';
                        For(Database.error error : sr.getErrors()) {
                            errorMessage += error.getMessage();
                        }
                        UCD_ACM_Logger.error('UCD_ACM_AccountService','publishAccountRequestPlatformEvent',errorMessage+' Failed Account Request Queue Ids :','arqIds: '+arqIds.toString());
                        break;
                    }
                }                     
            }
        } catch (Exception ex) {
            UCD_ACM_Logger.error('UCD_ACM_AccountService','publishAccountRequestPlatformEvent','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString()+' UserName: '+UserInfo.getUserName(),'arqIds:'+arqIds.toString());
        } finally {
            UCD_ACM_Logger.setLogDetails();
        }
    }
 }