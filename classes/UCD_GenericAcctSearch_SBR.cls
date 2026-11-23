/*********************************************************************************************************************
Apex Class Name  : UCD_GenericAcctSearch_SBR
Version       : 1.0
Created Date  : May 2021
Function      : Accepts the input from LWC and send data back to LWC

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Saranya Ramaiah              9/8/2020            Calling account data
*********************************************************************************************************************/
public without sharing class UCD_GenericAcctSearch_SBR {

    private static UCD_ACM_ServiceContracts.IMDMService reltioServiceInstance = UCD_ACM_ReltioService.getInstance();
    private static UCD_ACM_ServiceContracts.IAccountService accountServiceInstance = UCD_ACM_AccountService.getInstance();

    private static String cols = ' id,Name,Core_Business_Party_Id__c,BillingCountryCode,BillingStateCode,BillingCountry,BillingCity,BillingPostalCode,BillingStreet,Owner.Name,Core_MDM_Website__c,RecordType.Name,Core_Customer_Aggregation_Type__c,Core_Unified_Global_Customer__c,Core_Sales_Groups__c,Core_Unified_Global_Customer__r.Name, Core_Unified_Intermediate_Customer__c, Unified_Hierarchy_View__c,ParentId, BillingState, Core_Requested_Name__c, Parent.Core_Customer_Aggregation_Type__c,Core_User_Defined_Website__c,Core_Unified_Intermediate_Customer_2__c  ';
    private static Map<Id,List<Business_Types__c>> businessTypeByAccountId  = new Map<Id,List<Business_Types__c>>();
    private static Map<String,String> countryNameByCountryCode = new Map<String,String>();
    private static Map<String, Map<String,String>> stateNameBycodes = new Map<String, Map<String,String>>();
    private static Map<String,String> aggregationLabelByCode = new Map<String,String>();
    private static Map<String,String> salesGroupByCode = new Map<String,String>();
    private static String errorMessage;
    //private static Map<String,String> stateNameByStateCode = new Map<String,String>();

    private static Map< String, Map< Account, AccountSearchDataModel> > mapOfAggCodeByListAccount = new  Map< String, Map< Account, AccountSearchDataModel> >();
    private static Map< Account, AccountSearchDataModel> resultForUI = new Map< Account, AccountSearchDataModel>();


   
    public class Fieldsetwrapper{
        @AuraEnabled
        public String fieldLabel {get;set;}
        @AuraEnabled
        public String fieldAPIName {get;set;}
        @AuraEnabled
        public String fieldValue {get;set;}
    }
   
    public class customerProcessEngOption{
        @AuraEnabled 
        public string label{get;set;}
        @AuraEnabled 
        public string value{get;set;}
    }
   
    public static void setErrorMessage(String message) {
        if(errorMessage == null) {
            errorMessage = message;
        } else {
            errorMessage = errorMessage + ' ' + message;
        }
    }
    
    @AuraEnabled
    public static List<customerProcessEngOption> getCustomerProcesEngg(){
        List<customerProcessEngOption> cpeOptions = new List<customerProcessEngOption>();
        if ((Schema.sObjectType.Business_Types__c.fields.Name.isAccessible()) &&
        (Schema.sObjectType.Business_Types__c.fields.Business_Type_Code__c.isAccessible())) {
            For(Business_Types__c businessType : [Select Id,Business_Type_Code__c, Name  from Business_Types__c where Is_Active__c = true]){
                if(businessType.Name != null && businessType.Name != '' && businessType.Business_Type_Code__c != null && businessType.Business_Type_Code__c != '' && (
                    businessType.Business_Type_Code__c == 'DIR_PRC_EXCPT' || businessType.Business_Type_Code__c == 'DISTI_PRC_EXCPT' || businessType.Business_Type_Code__c == 'SD_REV' || businessType.Business_Type_Code__c == 'SLS_PPLN'
                )){
                    customerProcessEngOption cpeOption = new customerProcessEngOption();
                    cpeOption.label = businessType.Name;
                    cpeOption.value = businessType.Business_Type_Code__c;
                    cpeOptions.add(cpeOption);
                }
            }
        }
        return cpeOptions;
    }

    @AuraEnabled
    public static Account_Create_Process_Mapping__mdt getAccCreateProcessMapping(String processType){
        try {
            if(String.isNotBlank(processType)){
                Map<String, Account_Create_Process_Mapping__mdt> accCreateProMapByDevName = Account_Create_Process_Mapping__mdt.getAll();

                For(Account_Create_Process_Mapping__mdt accCreateProcessMapping : accCreateProMapByDevName.values()){
                    if(accCreateProcessMapping.label == processType){
                        return accCreateProcessMapping;
                    }
                }
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<accRequestWrap> getAcctRequests(){
        try {
            if(Schema.SObjectType.Account_Create_Request__c.isAccessible()){
                List<Account_Create_Request__c> accCreateRequests = [Select Id,Name,Account_Name__c,Requested_Account__r.Name,toLabel(Customer_Process_Engagement__c),/*Country__c,*/toLabel(Status__c),Rejected_Reason__c,CreatedDate,Request_Flow_Status__c,Owner.Name from Account_Create_Request__c where CreatedById=:UserInfo.getUserId()];
                List<accRequestWrap> accReqWraplst = new List<accRequestWrap>();
                For(Account_Create_Request__c accReq : accCreateRequests){
                    accRequestWrap accReqWrap = new accRequestWrap();
                    accReqWrap.recordUrl = '/'+accReq.Id;
                    accReqWrap.recId = accReq.Name;
                    accReqWrap.accName = accReq.Account_Name__c;
                    accReqWrap.reqAccName = accReq.Requested_Account__r.Name;
                    accReqWrap.cpe = accReq.Customer_Process_Engagement__c;
                    accReqWrap.status = accReq.Status__c;
                    accReqWrap.reqFlowStatus = accReq.Request_Flow_Status__c;
                    accReqWrap.rejReason = accReq.Rejected_Reason__c;
                    accReqWrap.ownerName = accReq.Owner.Name;
                    accReqWrap.createdDate = Date.valueOf(accReq.CreatedDate);
                    accReqWraplst.add(accReqWrap);
                }
                if(accReqWraplst.size() > 0){
                    return accReqWraplst;
                }
                return null;
            }
            return null;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static boolean callSubmitFlow(String recordId,String accName,String accId,String accBpId){
        try{
            Map<String,Object> flowValueByName = new Map<String,Object>();
            flowValueByName.put('recordId',recordId);
            flowValueByName.put('accountId',accId);
            flowValueByName.put('accountName',accName);
            flowValueByName.put('accountBpId',accBpId);
            Flow.Interview.SBR_Reuse_Account_field_updates reUseSubmit = new Flow.Interview.SBR_Reuse_Account_field_updates(flowValueByName);

            reUseSubmit.start(); 


            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class accRequestWrap{
        @AuraEnabled public string recordUrl{get;set;}
        @AuraEnabled public string recId{get;set;}
        @AuraEnabled public string accName{get;set;}
        @AuraEnabled public string reqAccName{get;set;}
        @AuraEnabled public string cpe{get;set;}
        @AuraEnabled public string country{get;set;}
        @AuraEnabled public string status{get;set;}
        @AuraEnabled public string reqFlowStatus{get;set;}
        @AuraEnabled public string rejReason{get;set;}
        @AuraEnabled public string ownerName{get;set;}
        @AuraEnabled public Date createdDate{get;set;}
    }    
    
    /*public class SBRRadioOption{
        @AuraEnabled 
        public string label{get;set;}
        @AuraEnabled 
        public string value{get;set;}
        @AuraEnabled 
        public string description{get;set;}
        @AuraEnabled 
        public string profileName{get;set;}
    }

      @AuraEnabled
    public static List<SBRRadioOption> getSBRProcessMapping(){
        List<SBRRadioOption> getAllMetadataList = new List<SBRRadioOption>();
        try {
                List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
                String MyProflieName = PROFILE[0].Name;

                List< Account_Create_Process_Mapping__mdt> SBRProMapByDevNames = [SELECT Id, Label_Name__c,label, Description_Text__c, Profile_Name__c,Permission_Set__c,Order__c 
                                                                       FROM Account_Create_Process_Mapping__mdt 
                                                                       WHERE Active__c = true 
                                                                       ORDER BY Order__c ASC];
                
                List<PermissionSetAssignment> lstcurrentUserPerSet = [ SELECT Id, PermissionSet.Name,AssigneeId
                                                                       FROM PermissionSetAssignment
                                                                       WHERE AssigneeId = :Userinfo.getUserId() ];

                System.debug('MyProflieName==>'+MyProflieName);
                System.debug('SBRProMapByDevNames==>'+SBRProMapByDevNames);
            
                For(Account_Create_Process_Mapping__mdt SBRProMapByDevName : SBRProMapByDevNames){
                    SBRRadioOption metadataOption = new SBRRadioOption();
                    metadataOption.label = SBRProMapByDevName.Label_Name__c;
                    metadataOption.value = SBRProMapByDevName.label;
                    metadataOption.description = SBRProMapByDevName.Description_Text__c;
                    metadataOption.profileName = SBRProMapByDevName.Profile_Name__c;

                    System.debug('SBRProMapByDevName.Profile_Name__c==>'+SBRProMapByDevName.Profile_Name__c);
                    
                     boolean checkProfile = checkProfileContains(SBRProMapByDevName, MyProflieName);

                     boolean checkPermissionSet = checkPermisionSetContains(SBRProMapByDevName, lstcurrentUserPerSet);

                    if(checkProfile || checkPermissionSet){
                        getAllMetadataList.add(metadataOption);
                    }
                }
                return getAllMetadataList;
            }
        
        catch (Exception e) {
            System.debug('Exception==>'+e.getStackTraceString());

            return null;
        }
    }

    private static boolean  checkPermisionSetContains(Account_Create_Process_Mapping__mdt SBRProMapByDevName, List<PermissionSetAssignment> lstcurrentUserPerSet){

        if(SBRProMapByDevName.Permission_Set__c != null){
            if(lstcurrentUserPerSet != null && lstcurrentUserPerSet.size() > 0){
                for (PermissionSetAssignment psa: lstcurrentUserPerSet)
                {
                    if(psa.PermissionSet.Name.equals(SBRProMapByDevName.Permission_Set__c)){
                        return true;
                    }
                }
            }else{
                return false;

            }
        }else{
            return false;
        }

        return false;
    }

    private static boolean  checkProfileContains(Account_Create_Process_Mapping__mdt SBRProMapByDevName, String MyProflieName){

        if(SBRProMapByDevName.Profile_Name__c  != null ){
            for(Integer i = 0; SBRProMapByDevName.Profile_Name__c.split(',').size() > i ; i++){

                if(MyProflieName.equals(SBRProMapByDevName.Profile_Name__c.split(',')[i].trim())){
                   // metadataOption.profileName = SBRProMapByDevName.Profile_Name__c;
                   return true;
                }
            }
        }else{
            return true;
        }

        return false;

    }*/


   



    //SBR search
    ///////////////////////////////////////////////////////////////////////////////////////////////////


    /**********Seach Mock Data****************/
    public class AccountSearchDataModel {
        @AuraEnabled
        public String accId{get;set;}
        @AuraEnabled
        public String accName{get;set;}
        @AuraEnabled
        public String unifiedHierarchy{get;set;}
        @AuraEnabled
        public String bpId{get;set;}
        @AuraEnabled
        public String customerAggregationCode{get;set;}
        @AuraEnabled
        public String salesGroupCode{get;set;}
        @AuraEnabled
        public String address{get;set;}
        @AuraEnabled
        public String cpe{get;set;}
        @AuraEnabled
        public String Website{get;set;}
        @AuraEnabled
        public String recordType{get;set;}
        @AuraEnabled
        public String accOwner{get;set;}
        @AuraEnabled
        public String unifiedGlobalCustomer{get;set;}
        @AuraEnabled
        public String recordUrl{get;set;}
        @AuraEnabled
        public String requestedName{get;set;}
        @AuraEnabled
        public List<AccountSearchDataModel> childAccounts{get;set;}

    }

    public class AccountSearchDataModelWithError {
        @AuraEnabled
        public List<AccountSearchDataModel> accountSearchModel{get;set;}

        @AuraEnabled
        public Boolean isError{get;set;}

        @AuraEnabled
        public String errorMessage{get;set;}
    }

    @AuraEnabled
    public static AccountSearchDataModelWithError getAcctResults(List<fieldsetwrapper> fDetails, String requestReason) {
        List<AccountSearchDataModel> mergedResults = new List<AccountSearchDataModel>();
        AccountSearchDataModelWithError mergedResultsWithError = new AccountSearchDataModelWithError();

        try{
            List<Account> accResults = new List<Account>();
            List<String> reltioBpId = new List<String>();
            String requestReasonAPIName = '';        
            Long time1 = System.now().getTime();

            // call Reltio API
            List<UCD_ACM_Models.ReltioResponse> reltioAccounts = reltioSearch(fDetails);
            System.debug('reltioAccounts@@%%'+reltioAccounts);

            Long time2 = System.now().getTime();
            Long milliseconds1 = time2 - time1;
            Long seconds1 = milliseconds1 / 1000;
            UCD_ACM_Logger.information('UCD_GenericAcctSearch_SBR', 'getAcctResults', 'Time For Reltio API- '+ seconds1, 'SBR');

            if(reltioAccounts != null && reltioAccounts.size() > 0) {
                UCD_ACM_Logger.information('UCD_GenericAcctSearch_SBR', 'getAcctResults', 'Reltio results Count -'+reltioAccounts.size(), 'SBR');
                For(UCD_ACM_Models.ReltioResponse reltioAccount : reltioAccounts) {
                    if(String.isNotBlank(reltioAccount.BusinessPartyId))
                        reltioBpId.add(reltioAccount.BusinessPartyId);
                }
            }
        
            if(String.isNotBlank(requestReason)) {
                Map<String, Account_Create_Process_Mapping__mdt> accCreateProMapByDevName = Account_Create_Process_Mapping__mdt.getAll();
                For(Account_Create_Process_Mapping__mdt accCreateProcessMapping : accCreateProMapByDevName.values()) {
                    if(accCreateProcessMapping.label == requestReason) {
                        requestReasonAPIName = accCreateProcessMapping.DeveloperName;
                    }
                }
            }

            accResults = reltioSearchAccount(fDetails,'Account',requestReasonAPIName,reltioBpId);


            if(accResults != null && accResults.size() > 0) {

                Map<String, Account>  mapAccountSort = customSortingMethod(accResults);
                 mergedResults = acctWrapContructor(mapAccountSort,requestReasonAPIName);    
            }

            //Performance Logging
            Long time3 = System.now().getTime();

            Long milliseconds2 = time3 - time1;
            Long seconds2 = milliseconds2 / 1000;
            UCD_ACM_Logger.information('UCD_GenericAcctSearch_SBR', 'getAcctResults', 'Time For Reltio API for whole searching- '+ seconds2, 'SBR');

        }catch(Exception ex){
            setErrorMessage(String.valueOf(ex.getMessage()));
            System.debug('Exception1==>'+ex.getMessage());

            System.debug('Exception1==>'+ex.getStackTraceString());
            UCD_ACM_Logger.error('UCD_GenericAcctSearch_SBR','getAcctResults','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        }finally{
            UCD_ACM_Logger.setLogDetails();
        }

        if(errorMessage != Null) {
            mergedResultsWithError.accountSearchModel = mergedResults;
            mergedResultsWithError.isError = true;
            mergedResultsWithError.errorMessage = errorMessage;
        } else {
            mergedResultsWithError.accountSearchModel = mergedResults;
            mergedResultsWithError.isError = false;
            mergedResultsWithError.errorMessage = '';
        }
        System.debug('mergedResultsWithError===>'+mergedResultsWithError);

        return mergedResultsWithError;

    } 

    public static Map<String, Account>  customSortingMethod(List<Account> lstAccount){
        Map<Id,Account> allstrartingAccount = new Map<Id,Account>(lstAccount);
        Map<String, Account> finalMapcustomSorting = new Map<String, Account>();


        try{
        List<String> ListaccountName = new List<String>();

        For(Account accRec : lstAccount){
            ListaccountName.add(accRec.Name.toLowercase()+ '@' + accRec.Id);
        }
        ListaccountName.sort();

        for(String newKey : ListaccountName){
            List<String> splitparts = newKey.split('@');
            String accId = splitparts[splitparts.size() - 1];

            finalMapcustomSorting.put(newKey, allstrartingAccount.get(accId));

        }

    }catch(Exception ex){
        setErrorMessage(String.valueOf(ex.getMessage()));
        UCD_ACM_Logger.error('UCD_GenericAcctSearch_SBR','customSortingMethod','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);

    }

        return finalMapcustomSorting;


    }

    /**********Reltio search****************/
    public static List<UCD_ACM_Models.ReltioResponse> reltioSearch(List<fieldsetwrapper> fDetails){
        List<UCD_ACM_Models.ReltioResponse> reltioResponse = new List<UCD_ACM_Models.ReltioResponse>();
        UCD_ACM_Models.SearchRequest searchReqBody = new UCD_ACM_Models.SearchRequest();

        //Ankit
        for(fieldsetwrapper fs:fDetails){
            if(String.isNotBlank(fs.fieldValue)) {   
                switch on fs.fieldAPIName {
                    when 'Name' {
                        searchReqBody.BusinessOrganizationName = fs.fieldValue;
                    }
                    when 'Website' {
                        searchReqBody.WebsiteURL = fs.fieldValue;
                    }
                    when 'BillingCountry' {
                        searchReqBody.Address = fs.fieldValue;
                    }
                }
            }
        }        
        
        //call Reltio API
        reltioResponse = reltioServiceInstance.searchAccountReltio(searchReqBody);
        System.debug('reltioResponse@@%%'+reltioResponse);
        //For Test Class
        if(Test.isRunningTest()){
            UCD_ACM_Models.ReltioResponse relResponse = new UCD_ACM_Models.ReltioResponse();
            relResponse.BusinessPartyId = '12345';
            reltioResponse.add(relResponse);
        }
        return reltioResponse;
    }

    /**********Heirarchy Building Method****************/
    public static List<AccountSearchDataModel> acctWrapContructor(Map<String, Account> acctList, String requestReasonAPIName){

        Map< String, AccountSearchDataModel> mapOfModelByString = new Map< String, AccountSearchDataModel>();
        List<AccountSearchDataModel> finalResult = new List<AccountSearchDataModel>();
        List<Account> allChildAccounts = new List<Account>();
        Set<Id> accountIdsToGetCPE = new Set<Id>();
        Set<Id> setOfGlobalId = new Set<Id>();
        String queryForChildAccount = '';
        String recordTypeForSearch = '';

        // get Aggegation code values
        aggregationLabelByCode = getAggregationCode();
        // get Salesgroup values
        salesGroupByCode = getSalesGroup();
        // get country Name
        countryNameByCountryCode = UCD_ACM_Utils.getCountryName();
        // get state Name
        //stateNameByStateCode =  UCD_ACM_Utils.getStateName();
        // get stateName and codes
        stateNameBycodes = UCD_ACM_Utils.getGlobalPickList();
        // sorting of All Accounts
       // acctList.sort();


        for(Account objAccount : acctList.values()){
            accountIdsToGetCPE.add(objAccount.Id);

            if(objAccount.Core_Customer_Aggregation_Type__c != null && objAccount.Core_Customer_Aggregation_Type__c == 'UNFD_GLBL_CUST') {
                setOfGlobalId.add(objAccount.Id);

            }
        }

        // get Recordtype Id
        if(String.isNotBlank(requestReasonAPIName)){
            recordTypeForSearch = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Account_Create_Process_Mapping__mdt.getInstance(requestReasonAPIName).RecordType_Name__c).getRecordTypeId();
        }

        // Create Query All Child Accounts for global Accounts
        if(setOfGlobalId.size() > 0){
            queryForChildAccount = 'Select ' + cols + ' From Account' ;
            queryForChildAccount += ' WHERE Core_Unified_Global_Customer__c IN: setOfGlobalId ';
            queryForChildAccount += ' AND Core_Customer_Aggregation_Type__c != \'UNFD_GLBL_CUST\' ';
            queryForChildAccount += ' AND recordtypeId =: recordTypeForSearch ';

        }

         // Get All Child Accounts for global Accounts
         if(String.isNotBlank(queryForChildAccount)){
            allChildAccounts = Database.query(queryForChildAccount);
        }

        for(Account AccountRecord : allChildAccounts){
            accountIdsToGetCPE.add(AccountRecord.Id);
        }

        // get CPE fro ALL accounts
        if(accountIdsToGetCPE.size() > 0){
            businessTypeByAccountId = accountServiceInstance.getActiveBusinessTypeForAccount(accountIdsToGetCPE);
        }

        for(Account objAccount : acctList.values()){
            resultForUI.put(objAccount , buildSearchModel(objAccount));
        }

        for(Account AccountRecord : allChildAccounts){


            
            // collect Intermediate Account
            if(AccountRecord.Core_Customer_Aggregation_Type__c == 'UNFD_INTRMD_CUST'){

                if(AccountRecord.Core_Unified_Intermediate_Customer__c != null){

                    if(AccountRecord.Core_Unified_Intermediate_Customer_2__c != null){

                        if(mapOfAggCodeByListAccount.size() > 0 &&  mapOfAggCodeByListAccount.get('Intermediate3') != null){
                            mapOfAggCodeByListAccount.get('Intermediate3').put(AccountRecord, buildSearchModel(AccountRecord));
    
                        }else{
                            Map<Account, AccountSearchDataModel> innerMapData = new Map<Account, AccountSearchDataModel>();
                            innerMapData.put(AccountRecord, buildSearchModel(AccountRecord));
                            mapOfAggCodeByListAccount.put('Intermediate3',innerMapData);
                        }

                    }else{

                        if(mapOfAggCodeByListAccount.size() > 0 &&  mapOfAggCodeByListAccount.get('Intermediate2') != null){
                            mapOfAggCodeByListAccount.get('Intermediate2').put(AccountRecord, buildSearchModel(AccountRecord));
    
                        }else{
                            Map<Account, AccountSearchDataModel> innerMapData = new Map<Account, AccountSearchDataModel>();
                            innerMapData.put(AccountRecord, buildSearchModel(AccountRecord));
                            mapOfAggCodeByListAccount.put('Intermediate2',innerMapData);
                        }
                    }
                }else{
                    if(mapOfAggCodeByListAccount.size() > 0 && mapOfAggCodeByListAccount.get('Intermediate1') != null){
                        mapOfAggCodeByListAccount.get('Intermediate1').put(AccountRecord, buildSearchModel(AccountRecord));

                    }else{
                        Map<Account, AccountSearchDataModel> innerMapData = new Map<Account, AccountSearchDataModel>();
                        innerMapData.put(AccountRecord, buildSearchModel(AccountRecord));
                        mapOfAggCodeByListAccount.put('Intermediate1',innerMapData);
                    }
                } 
            }

            // collect country Account
            if(AccountRecord.Core_Customer_Aggregation_Type__c == 'UNFD_CTRY_CUST'){

                if(mapOfAggCodeByListAccount.size() > 0 &&  mapOfAggCodeByListAccount.get('Country') != null){
                        mapOfAggCodeByListAccount.get('Country').put(AccountRecord, buildSearchModel(AccountRecord));

                }else{
                     Map<Account, AccountSearchDataModel> innerMapData = new Map<Account, AccountSearchDataModel>();
                     innerMapData.put(AccountRecord, buildSearchModel(AccountRecord));
                    mapOfAggCodeByListAccount.put('Country',innerMapData);
                }
            }
            
            // collect Location Account
            if(AccountRecord.Core_Customer_Aggregation_Type__c == 'UNFD_LOC_CUST'){

                if(mapOfAggCodeByListAccount.size() > 0 &&  mapOfAggCodeByListAccount.get('Location') != null){
                        mapOfAggCodeByListAccount.get('Location').put(AccountRecord, buildSearchModel(AccountRecord));

                }else{
                    Map<Account, AccountSearchDataModel> innerMapData = new Map<Account, AccountSearchDataModel>();
                    innerMapData.put(AccountRecord, buildSearchModel(AccountRecord));
                    mapOfAggCodeByListAccount.put('Location',innerMapData);
                }
            }
                        
        

        }



        // creating heirarchy for Location and country

        if(mapOfAggCodeByListAccount!= null &&  mapOfAggCodeByListAccount.size() > 0 && mapOfAggCodeByListAccount.get('Location') != null  ){

            for(Account accountRec :mapOfAggCodeByListAccount.get('Location').keySet()){


                if(accountRec.ParentId != null){

                    for(Account coountryAcc : mapOfAggCodeByListAccount.get('Country').keySet()){


                        if(accountRec.ParentId == coountryAcc.Id){
                            AccountSearchDataModel childModel =   mapOfAggCodeByListAccount.get('Location').get(accountRec);
                            AccountSearchDataModel parentModel =   mapOfAggCodeByListAccount.get('Country').get(coountryAcc);
                            
                            if(parentModel.childAccounts != null){
                                parentModel.childAccounts.add(childModel);
                            }else{
                                
                                parentModel.childAccounts = new List<AccountSearchDataModel>();
                                parentModel.childAccounts.add(childModel);
                            }

                        }

                    }

                }

            }
        }


        // creting heirarchy for country and intermediate3,intermediate2, intermediate1, global
        if(mapOfAggCodeByListAccount!= null &&  mapOfAggCodeByListAccount.size() > 0 && mapOfAggCodeByListAccount.get('Country') != null ){

            for(Account accountRec :mapOfAggCodeByListAccount.get('Country').keySet()){


                if(accountRec.ParentId != null){

                    if(accountRec.Parent.Core_Customer_Aggregation_Type__c != null && accountRec.Parent.Core_Customer_Aggregation_Type__c == 'UNFD_INTRMD_CUST' &&   mapOfAggCodeByListAccount.get('Intermediate3') != null ){

                        for(Account Interm1Account : mapOfAggCodeByListAccount.get('Intermediate3').keySet()){
                            if(accountRec.ParentId == Interm1Account.Id){
                                AccountSearchDataModel childModel =   mapOfAggCodeByListAccount.get('Country').get(accountRec);
                                AccountSearchDataModel parentModel =   mapOfAggCodeByListAccount.get('Intermediate3').get(Interm1Account);

                                if(parentModel.childAccounts != null){
                                    parentModel.childAccounts.add(childModel);
                                }else{
                                    
                                    parentModel.childAccounts = new List<AccountSearchDataModel>();
                                    parentModel.childAccounts.add(childModel);
                                }

                            }
                        } 
                    }else if(accountRec.Parent.Core_Customer_Aggregation_Type__c != null && accountRec.Parent.Core_Customer_Aggregation_Type__c == 'UNFD_INTRMD_CUST' &&   mapOfAggCodeByListAccount.get('Intermediate2') != null ){

                        for(Account Interm1Account : mapOfAggCodeByListAccount.get('Intermediate2').keySet()){
                            if(accountRec.ParentId == Interm1Account.Id){
                                AccountSearchDataModel childModel =   mapOfAggCodeByListAccount.get('Country').get(accountRec);
                                AccountSearchDataModel parentModel =   mapOfAggCodeByListAccount.get('Intermediate2').get(Interm1Account);

                                if(parentModel.childAccounts != null){
                                    parentModel.childAccounts.add(childModel);
                                }else{
                                    
                                    parentModel.childAccounts = new List<AccountSearchDataModel>();
                                    parentModel.childAccounts.add(childModel);
                                }

                            }
                        } 
                    }else if(accountRec.Parent.Core_Customer_Aggregation_Type__c != null && accountRec.Parent.Core_Customer_Aggregation_Type__c == 'UNFD_INTRMD_CUST' && mapOfAggCodeByListAccount.get('Intermediate1') != null){
                        for(Account Interm1Account : mapOfAggCodeByListAccount.get('Intermediate1').keySet()){
                            if(accountRec.ParentId == Interm1Account.Id){
                                AccountSearchDataModel childModel =   mapOfAggCodeByListAccount.get('Country').get(accountRec);
                                AccountSearchDataModel parentModel =   mapOfAggCodeByListAccount.get('Intermediate1').get(Interm1Account);

                                if(parentModel.childAccounts != null){
                                    parentModel.childAccounts.add(childModel);
                                }else{
                                    
                                    parentModel.childAccounts = new List<AccountSearchDataModel>();
                                    parentModel.childAccounts.add(childModel);
                                }


                            }
                        } 
                    } else if(accountRec.Parent.Core_Customer_Aggregation_Type__c != null && accountRec.Parent.Core_Customer_Aggregation_Type__c == 'UNFD_GLBL_CUST'){

                        for(Account globalAccount : resultForUI.keySet()){

                            if(globalAccount.Core_Customer_Aggregation_Type__c != null && globalAccount.Core_Customer_Aggregation_Type__c == 'UNFD_GLBL_CUST') {
                                if(accountRec.ParentId == globalAccount.Id){
                                    AccountSearchDataModel childModel =   mapOfAggCodeByListAccount.get('Country').get(accountRec);
                                    AccountSearchDataModel parentModel =   resultForUI.get(globalAccount);

                                    if(parentModel.childAccounts != null){
                                        parentModel.childAccounts.add(childModel);
                                    }else{
                                        
                                        parentModel.childAccounts = new List<AccountSearchDataModel>();
                                        parentModel.childAccounts.add(childModel);
                                    }
    
                                }
                            }

                        }
                    }
                }
            }
        }


        // creting heirarchy for  intermediate3 and intermediate2
        if(mapOfAggCodeByListAccount!= null && mapOfAggCodeByListAccount.size() > 0 && mapOfAggCodeByListAccount.get('Intermediate3') != null &&  mapOfAggCodeByListAccount.get('Intermediate3') != null){

            for(Account accountRec :mapOfAggCodeByListAccount.get('Intermediate3').keySet()){
                if(accountRec.ParentId != null){
                    for(Account interm2Account : mapOfAggCodeByListAccount.get('Intermediate2').keySet()){
                        if(accountRec.ParentId == interm2Account.Id){
                            AccountSearchDataModel childModel =   mapOfAggCodeByListAccount.get('Intermediate3').get(accountRec);
                            AccountSearchDataModel parentModel =   mapOfAggCodeByListAccount.get('Intermediate2').get(interm2Account);
                            

                            if(parentModel.childAccounts != null){
                                parentModel.childAccounts.add(childModel);
                            }else{
                                
                                parentModel.childAccounts = new List<AccountSearchDataModel>();
                                parentModel.childAccounts.add(childModel);
                            }


                        }
                    } 
                }
            }
        }

        // creting heirarchy for  intermediate2 and intermediate1
        if(mapOfAggCodeByListAccount!= null && mapOfAggCodeByListAccount.size() > 0 && mapOfAggCodeByListAccount.get('Intermediate2') != null &&  mapOfAggCodeByListAccount.get('Intermediate1') != null){

            for(Account accountRec :mapOfAggCodeByListAccount.get('Intermediate2').keySet()){
                if(accountRec.ParentId != null){
                    for(Account interm2Account : mapOfAggCodeByListAccount.get('Intermediate1').keySet()){
                        if(accountRec.ParentId == interm2Account.Id){
                            AccountSearchDataModel childModel =   mapOfAggCodeByListAccount.get('Intermediate2').get(accountRec);
                            AccountSearchDataModel parentModel =   mapOfAggCodeByListAccount.get('Intermediate1').get(interm2Account);
                            

                            if(parentModel.childAccounts != null){
                                parentModel.childAccounts.add(childModel);
                            }else{
                                
                                parentModel.childAccounts = new List<AccountSearchDataModel>();
                                parentModel.childAccounts.add(childModel);
                            }


                        }
                    } 
                }
            }
        }

        // creting heirarchy for intermediate1 and Global
        if(mapOfAggCodeByListAccount!= null && mapOfAggCodeByListAccount.size() > 0 && mapOfAggCodeByListAccount.get('Intermediate1') != null && resultForUI != null && resultForUI.size() > 0){

            for(Account accountRec :mapOfAggCodeByListAccount.get('Intermediate1').keySet()){
                if(accountRec.ParentId != null){
                    for(Account globalAccount : resultForUI.keySet() ){
                        if(globalAccount.Core_Customer_Aggregation_Type__c != null && globalAccount.Core_Customer_Aggregation_Type__c == 'UNFD_GLBL_CUST') {
                            if(accountRec.ParentId == globalAccount.Id){
                                AccountSearchDataModel childModel =   mapOfAggCodeByListAccount.get('Intermediate1').get(accountRec);
                                AccountSearchDataModel parentModel =   resultForUI.get(globalAccount);

                                if(parentModel.childAccounts != null){
                                    parentModel.childAccounts.add(childModel);
                                }else{
                                    
                                    parentModel.childAccounts = new List<AccountSearchDataModel>();
                                    parentModel.childAccounts.add(childModel);
                                }


                            }
                        }
                    } 
                }
            }
        }
    
        // Diffrentiate all Account Based on aggregation code
        Map<String, List<AccountSearchDataModel> > afterSortingResult = sortingForUI(resultForUI);

        if(afterSortingResult.get('Global') != null){
            finalResult.addAll(afterSortingResult.get('Global'));
        }

        if(afterSortingResult.get('Intermediate1')!= null){
            finalResult.addAll(afterSortingResult.get('Intermediate1'));
        }

        if(afterSortingResult.get('Intermediate2')!= null){
            finalResult.addAll(afterSortingResult.get('Intermediate2'));
        }

        if(afterSortingResult.get('Country')!= null){
            finalResult.addAll(afterSortingResult.get('Country'));
        }

        if(afterSortingResult.get('Location')!= null){
            finalResult.addAll(afterSortingResult.get('Location'));
        }

        if(afterSortingResult.get('NonUnified')!= null){
            finalResult.addAll(afterSortingResult.get('NonUnified'));
        }
        
        if(afterSortingResult.get('Others')!= null){
            finalResult.addAll(afterSortingResult.get('Others'));
        }

        return finalResult;

    }

    // Diffrentiate all Account Based on aggregation code
    private static Map<String, List<AccountSearchDataModel> >  sortingForUI(Map< Account, AccountSearchDataModel> resultForUI){

        Map<String, List<AccountSearchDataModel> > finalResultAfterSorting = new Map < String, List < AccountSearchDataModel > >();
       // List<Account> countryAccount = new List<Account>();

        for(Account accountRecord : resultForUI.keySet()){
            if(accountRecord.Core_Customer_Aggregation_Type__c == 'UNFD_GLBL_CUST'){

                if(finalResultAfterSorting.get('Global') != null){
                    finalResultAfterSorting.get('Global').add(resultForUI.get(accountRecord));
                }else{
                    finalResultAfterSorting.put('Global', new List<AccountSearchDataModel>{resultForUI.get(accountRecord)});
                }
            }else if(accountRecord.Core_Customer_Aggregation_Type__c == 'UNFD_INTRMD_CUST'){
                if(accountRecord.Core_Unified_Intermediate_Customer__c != null){
                    if(finalResultAfterSorting.get('Intermediate2') != null){
                        finalResultAfterSorting.get('Intermediate2').add(resultForUI.get(accountRecord));
                    }else{
                        finalResultAfterSorting.put('Intermediate2', new List<AccountSearchDataModel>{resultForUI.get(accountRecord)});
                    }
                }else{
                    if(finalResultAfterSorting.get('Intermediate1') != null){
                        finalResultAfterSorting.get('Intermediate1').add(resultForUI.get(accountRecord));
                    }else{
                        finalResultAfterSorting.put('Intermediate1', new List<AccountSearchDataModel>{resultForUI.get(accountRecord)});
                    }
                }
            }else if(accountRecord.Core_Customer_Aggregation_Type__c == 'UNFD_CTRY_CUST'){
               // countryAccount.add(accountRecord);
                if(finalResultAfterSorting.get('Country') != null){
                    finalResultAfterSorting.get('Country').add(resultForUI.get(accountRecord));
                }else{
                    finalResultAfterSorting.put('Country', new List<AccountSearchDataModel>{resultForUI.get(accountRecord)});
                }

            }else if(accountRecord.Core_Customer_Aggregation_Type__c == 'UNFD_LOC_CUST'){
                // countryAccount.add(accountRecord);
                 if(finalResultAfterSorting.get('Location') != null){
                     finalResultAfterSorting.get('Location').add(resultForUI.get(accountRecord));
                 }else{
                     finalResultAfterSorting.put('Location', new List<AccountSearchDataModel>{resultForUI.get(accountRecord)});
                 }
 
             }else if(accountRecord.Unified_Hierarchy_View__c == 'Not Unified'){
                if(finalResultAfterSorting.get('NonUnified') != null){
                    finalResultAfterSorting.get('NonUnified').add(resultForUI.get(accountRecord));
                }else{
                    finalResultAfterSorting.put('NonUnified', new List<AccountSearchDataModel>{resultForUI.get(accountRecord)});
                }

            }else{
                if(finalResultAfterSorting.get('Others') != null){
                    finalResultAfterSorting.get('Others').add(resultForUI.get(accountRecord));
                }else{
                    finalResultAfterSorting.put('Others', new List<AccountSearchDataModel>{resultForUI.get(accountRecord)});
                }
            }
        }

       /* if(countryAccount != null && countryAccount.size() > 0){
            countryAccount.sort();
            for(Account accRecord : countryAccount){
                if(finalResultAfterSorting.get('Country') != null){
                    finalResultAfterSorting.get('Country').add(resultForUI.get(accRecord));
                }else{
                    finalResultAfterSorting.put('Country', new List<AccountSearchDataModel>{resultForUI.get(accRecord)});
                }
            }
        }*/
        return finalResultAfterSorting;
    }


    // Get Aggregation Codes
    private static Map<String,String> getAggregationCode(){
        List<Schema.PicklistEntry> aggregationCodes = Account.Core_Customer_Aggregation_Type__c.getDescribe().getPicklistValues();

        For(Schema.PicklistEntry aggregationCode : aggregationCodes){
            aggregationLabelByCode.put(aggregationCode.getValue(), aggregationCode.getLabel());
        }
        return aggregationLabelByCode;
    }

    // get Sales groupes
    private static Map<String,String> getSalesGroup(){
        List<Schema.PicklistEntry> salesGroupCodes = Account.Core_Sales_Groups__c.getDescribe().getPicklistValues();

        For(Schema.PicklistEntry salesGroupCode : salesGroupCodes){
            salesGroupByCode.put(salesGroupCode.getValue(), salesGroupCode.getLabel());
        }
        return salesGroupByCode;
    }

    // Create Data model for Accounts
    private static AccountSearchDataModel buildSearchModel(Account accountRecord){

        String countryCode =  (countryNameByCountryCode != null && countryNameByCountryCode.get(String.valueOf(accountRecord.BillingCountryCode)) != null) ? countryNameByCountryCode.get(String.valueOf(accountRecord.BillingCountryCode)) : '' ;

        String  stateNames = accountRecord.BillingCountryCode != null && stateNameBycodes.get(String.valueOf(accountRecord.BillingCountryCode)) != null ? 
                             stateNameBycodes.get(String.valueOf(accountRecord.BillingCountryCode)).get(String.valueOf(accountRecord.BillingStateCode)) != null ?
                             stateNameBycodes.get(String.valueOf(accountRecord.BillingCountryCode)).get(String.valueOf(accountRecord.BillingStateCode)) + ', ' :
                             '' :
                             '' ;

        AccountSearchDataModel accountSearchModel= new AccountSearchDataModel();

        accountSearchModel.accId = accountRecord.Id;   
        accountSearchModel.accName = accountRecord.Name;  
        accountSearchModel.address = (accountRecord.BillingStreet != null?String.valueOf(accountRecord.BillingStreet)+', ':'')+
                                    (accountRecord.BillingCity != null?String.valueOf(accountRecord.BillingCity)+', ':'')+
                                    stateNames +
                                    countryCode +
                                    (accountRecord.BillingPostalCode != null? +', ' + String.valueOf(accountRecord.BillingPostalCode):'');      
        accountSearchModel.accOwner = accountRecord.Owner.Name;
        accountSearchModel.bpId = accountRecord.Core_Business_Party_Id__c;
        accountSearchModel.customerAggregationCode = aggregationLabelByCode.get(accountRecord.Core_Customer_Aggregation_Type__c);
        accountSearchModel.salesGroupCode = salesGroupByCode.get(accountRecord.Core_Sales_Groups__c);
        accountSearchModel.unifiedHierarchy = accountRecord.Unified_Hierarchy_View__c;
        accountSearchModel.Website = accountRecord.Core_MDM_Website__c;
        accountSearchModel.recordType = accountRecord.RecordType.Name;
        accountSearchModel.unifiedGlobalCustomer = accountRecord.Core_Unified_Global_Customer__r.Name;
        accountSearchModel.recordUrl = '/'+accountRecord.Id;
        accountSearchModel.requestedName = accountRecord.Core_Requested_Name__c;

        if(businessTypeByAccountId != null && businessTypeByAccountId.containsKey(accountRecord.Id)){
            for(Business_Types__c businessType : businessTypeByAccountId.get(accountRecord.Id)){
                if(String.isBlank(accountSearchModel.cpe)){
                    accountSearchModel.cpe = businessType.Name;
                }else{
                    accountSearchModel.cpe = accountSearchModel.cpe +', '+businessType.Name;
                }
            }
        }
        return accountSearchModel;  
   }



    private static List<Account> localSearch(List<fieldsetwrapper> fDetails,String recordType,List<String> reltioBpId){
        String condition = '';
        String searchName = '';
        String countryCode;
        String stateCode;
        Map<Id,Account> localAccountById = new Map<Id,Account>();

        //Ankit
        for(fieldsetwrapper fs:fDetails) {
            if(String.isNotBlank(fs.fieldValue)) {    
                switch on fs.fieldAPIName {
                    when 'Name'{
                       // searchName = '*' + fs.fieldValue.trim() + '*';
                        searchName = fs.fieldValue.trim() ;

                        String SName = '%' + String.escapeSingleQuotes(fs.fieldValue.trim()) + '%';
                        condition =  ' ( ' + (fs.fieldAPIName+' LIKE '+ '\''+ SName + '\'' ); 
                    }
                    when 'Core_Requested_Name__c' {
                        String requestedName = '%' + String.escapeSingleQuotes(fs.fieldValue.trim()) + '%';
                        condition += String.isNotBlank(condition) ? (' OR ' + fs.fieldAPIName+' LIKE ' +'\''+ requestedName + '\'') + ' ) ' : (fs.fieldAPIName+' LIKE '+ '\''+ requestedName + '\'' );   
                    }

                    when 'Website' {
                        String cleanedWebsite = '%' + String.escapeSingleQuotes(fs.fieldValue.trim()) + '%';
                        condition += String.isNotBlank(condition) ? (' AND ( ' + fs.fieldAPIName+' LIKE ' +'\''+ cleanedWebsite + '\'') : (fs.fieldAPIName+' LIKE '+ '\''+ cleanedWebsite + '\'' );   
                    }


                    when 'Core_MDM_Website__c' {
                        String cleanedWebsite = '%' + String.escapeSingleQuotes(fs.fieldValue.trim()) + '%';
                        condition += String.isNotBlank(condition) ? (' OR ' + fs.fieldAPIName+' LIKE ' +'\''+ cleanedWebsite + '\'') : (fs.fieldAPIName+' LIKE '+ '\''+ cleanedWebsite + '\'' );   
                    }

                   

                    when 'Core_User_Defined_Website__c' {
                        String cleanedWebsite = '%' + String.escapeSingleQuotes(fs.fieldValue.trim()) + '%';
                        condition += String.isNotBlank(condition) ? (' OR ' + fs.fieldAPIName+' LIKE ' +'\''+ cleanedWebsite + '\'') + ' ) ' : (fs.fieldAPIName+' LIKE '+ '\''+ cleanedWebsite + '\'' );   
                    }
                    when 'BillingCountry'{
                        countryCode = UCD_AccountConnector.getCountryCode(fs.fieldValue);
                        if(String.isNotBlank(countryCode)){
                            condition += String.isNotBlank(condition) ? (' AND ' + fs.fieldAPIName+' = '+ '\''+countryCode+'\'') : (fs.fieldAPIName+' = '+ '\''+countryCode+'\'');
                        }
                    }
                    when 'BillingState'{
                        //stateName = UCD_AccountConnector.getStateAndCountryName(fs.fieldValue);
                        //Map<String, String> statePicklistValues = UCD_ACM_Utils.getStateValuesForCountryCode(countryName);
                        //stateName = statePicklistValues.get(fs.fieldValue);
                        stateCode = UCD_ACM_Utils.getStateCodeForStateName(fs.fieldValue, countryCode);
                        System.debug('SBR Country code is - '+countryCode);
                        System.debug('SBR State code is - '+stateCode);
                        if(String.isNotBlank(stateCode)){
                            condition += String.isNotBlank(condition) ? (' AND ' + fs.fieldAPIName+' = '+ '\''+stateCode+'\'') : (fs.fieldAPIName+' = '+ '\''+stateCode+'\'');
                        }
                    }
                }              
            }
        }

        if(String.isNotBlank(recordType)){
            condition = condition + ' AND RecordTypeId = \''+ recordType+'\'';
        }

        if(reltioBpId.size() > 0){            
            String sBPIds = String.join(reltioBpId, '\',\'');
            condition +=  ' AND Core_Business_Party_Id__c NOT IN (\'' + sBPIds + '\')';  
        }
       
        List<Account> localAccountResults = new List<Account>();
        List<Account> accountsAfterSorting = new List<Account>();

       if(Account.SObjectType.getDescribe().isAccessible()){  
            String localSearchQuery = 'FIND :searchName IN ALL Fields  RETURNING Account ('+ cols + ' WHERE '+ condition + ' ORDER BY Name) LIMIT 50 ';
            UCD_ACM_Logger.information('UCD_GenericAcctSearch_SBR', 'localSearch', 'searchName-'+ searchName + ',' + '  Local Search Query -'+localSearchQuery, 'SBR');
            List<List<sObject>> localSoslAccountResults = new List<List<sObject>>();

                System.debug('localSearchQuery==>'+localSearchQuery);
               localSoslAccountResults = Search.query(localSearchQuery);
            if(localSoslAccountResults.size()>0){
                localAccountResults = localSoslAccountResults[0] ;
            }

            UCD_ACM_Logger.information('UCD_GenericAcctSearch_SBR', 'localSearch', 'reult from local Search' + localAccountResults.size(), 'SBR');

            if(localAccountResults != null && localAccountResults.size() > 0){
                accountsAfterSorting = sortingAccount(searchName.substring(1, searchName.length()-1 ),localAccountResults);
            }
        } 
        return accountsAfterSorting;

    }

    public static List<Account> reltioSearchAccount(List<fieldsetwrapper> fDetails,String objectApiName,String requestReasonAPIName,List<String> reltioBpId){

        Long time11 = System.now().getTime();
        List<String> filteredReltioBpId = new List<String>();
        String reltioSearchCondition = '';
        String recordType;
        Map<Id,Account> accountById = new Map<Id,Account>();
        String countryCode;

        //Ankit
        for(fieldsetwrapper fs:fDetails) {
            if(String.isNotBlank(fs.fieldValue)) {                
                switch on fs.fieldAPIName {
                    when 'BillingCountry' {
                        countryCode = UCD_AccountConnector.getCountryCode(fs.fieldValue);
                        if(String.isNotBlank(countryCode)){
                            reltioSearchCondition  += ' AND ' +  (fs.fieldAPIName+' = '+ '\''+countryCode+'\'');
                        }
                    }
                    when 'BillingState' {
                        //String stateName = UCD_AccountConnector.getStateAndCountryName(fs.fieldValue);
                        String stateCode = UCD_ACM_Utils.getStateCodeForStateName(fs.fieldValue, countryCode);
                        System.debug('SBR Country code is - '+countryCode);
                        System.debug('SBR State code is - '+stateCode);
                        if(String.isNotBlank(stateCode)){
                            reltioSearchCondition += + (' AND ' + fs.fieldAPIName+' = '+ '\''+stateCode+'\'') ;
                        }
                    }
                    when 'Core_MDM_Website__c' {
                        String cleanedWebsite = '%' + String.escapeSingleQuotes(fs.fieldValue.trim()) + '%';
                        reltioSearchCondition += (' AND ' + fs.fieldAPIName+' LIKE ' +'\''+ cleanedWebsite + '\'');
                    }
                }              
            }
        }

        if(String.isNotBlank(requestReasonAPIName)){
            recordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Account_Create_Process_Mapping__mdt.getInstance(requestReasonAPIName).RecordType_Name__c).getRecordTypeId();
        }
        

        List<Account> localSearchAccountforReltio = new List<Account>();
        List<Account> accountsByBpId = new  List<Account>();

        
        if(reltioBpId.size() > 0){            
            String reltioCondition =  'Core_Business_Party_Id__c IN : reltioBpId' + (String.isNotBlank(recordType)?' AND RecordTypeId = \''+ recordType+'\'':'');            
            String reltioSearchQuery = 'select '+cols+' from Account where '+reltioCondition+'  '+reltioSearchCondition+'   ORDER BY Name limit 20';

            if(Account.SObjectType.getDescribe().isAccessible()){  
                UCD_ACM_Logger.information('UCD_GenericAcctSearch_SBR', 'reltioSearchAccount', 'Local Unified Data Query -'+reltioSearchQuery, 'SBR');
                accountsByBpId = Database.query(reltioSearchQuery); 

                if(accountsByBpId != null && accountsByBpId.size() > 0){
                    for(Account reltioAcc : accountsByBpId){
                        if(!accountById.containsKey(reltioAcc.Id)){
                            filteredReltioBpId.add(reltioAcc.Core_Business_Party_Id__c);
                            accountById.put(reltioAcc.Id,reltioAcc);
                        }
                    }
                }
            } 

        }

        Long time12 = System.now().getTime();

        Long milliseconds11 = time12 - time11;
        Long seconds11 = milliseconds11 / 1000;

        UCD_ACM_Logger.information('UCD_GenericAcctSearch_SBR', 'reltioSearchAccount', 'Unified Accounts Count -'+accountById.size(), 'SBR');
        UCD_ACM_Logger.information('UCD_GenericAcctSearch_SBR', 'reltioSearchAccount', 'Timing for Reltio Search (In SF) -'+ seconds11, 'SBR');


        Integer reltioAccountsSize = 0;
        if(accountById.size() > 0) {
            localSearchAccountforReltio = accountById.values();
            reltioAccountsSize = localSearchAccountforReltio.size();
        }
        
        List<Account> finalAccount = new List<Account>();
        finalAccount.addAll(accountById.values());

        if(reltioAccountsSize < 20) {

                List<Account>  localSearchAccount = localSearch(fDetails,recordType,filteredReltioBpId);

                Integer RestAccountSize = 20 - reltioAccountsSize ;

                if(RestAccountSize < localSearchAccount.size()){
                    for(Integer i = 0; i < RestAccountSize  ; i++){
                        localSearchAccountforReltio.add(localSearchAccount[i]);
                    }
                }else{
                    localSearchAccountforReltio.addAll(localSearchAccount);
                }
        }

        Long time13 = System.now().getTime();

        Long milliseconds12 = time13 - time12;
        Long seconds12 = milliseconds12 / 1000;

        UCD_ACM_Logger.information('UCD_GenericAcctSearch_SBR', 'reltioSearchAccount', 'Timing for Reltio Search (In SF) -'+ seconds12, 'SBR');

        return localSearchAccountforReltio;
    }



    public static List<Account> sortingAccount(String searchName ,List<Account> localSearchAccounts){

        List<Account> startWithSearchNameAccounts = new List<Account>();
        List<Account> startWithoutSearchNameAccounts = new List<Account>();

        if(localSearchAccounts != null){
            for(Account localSearchAccount : localSearchAccounts){
                if(localSearchAccount.Name.toLowercase().indexOf(searchName.toLowercase()) != -1 || ( localSearchAccount.Core_Requested_Name__c != null && localSearchAccount.Core_Requested_Name__c.toLowercase().indexOf(searchName.toLowercase()) != -1) ){
                    if(localSearchAccount.Name.startsWithIgnoreCase(searchName)){
                        startWithSearchNameAccounts.add(localSearchAccount);
                    }else{
                        startWithoutSearchNameAccounts.add(localSearchAccount);
                    }
                }
            }
            if(startWithoutSearchNameAccounts.size()>0){
                startWithSearchNameAccounts.addAll(startWithoutSearchNameAccounts);
            }
        }

        return startWithSearchNameAccounts;
    }

    @AuraEnabled(cacheable = true)
    public static List<DuplicateRecordWrapper> checkForDuplicates(String customername, String alternateLangName, String primaryCountry, String primaryStreet, String primaryCity, String primaryState){
        Id intelAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        customername=customername.trim().replaceAll('\\s{2,}', ' ');
        primaryStreet=primaryStreet.trim().replaceAll('\\s{2,}', ' ');
        alternateLangName=alternateLangName.trim().replaceAll('\\s{2,}', ' ');
        primaryCity=primaryCity.trim().replaceAll('\\s{2,}', ' ');
        List<DuplicateRecordWrapper> duplicateRecords=new List<DuplicateRecordWrapper>();
        try{
            String queryAccount='Select Id, Name, Core_Alternate_Language_Name__c,BillingCountry, Core_Business_Party_Id__c,Owner.Name,BillingStreet, BillingCity, BillingState, BillingPostalCode,Core_Unified_Global_Customer_Name__c FROM Account Where (Name=:customername OR (Core_Alternate_Language_Name__c!=null AND Core_Alternate_Language_Name__c=:alternateLangName)) AND (BillingCountry=:primaryCountry AND BillingStreet=:primaryStreet AND BillingCity=:primaryCity AND BillingState=:primaryState AND RecordTypeId=:intelAccountRTId)';
            String queryAccountReqQueue='Select Id, Account_Name__c, Core_Alternate_Language_Name__c, Status__c, Address__CountryCode__s, Address__Street__s, Address__City__s,Address__StateCode__s,Address__PostalCode__s,CreatedDate,Requestor_Name__c,Process_Type__c From Account_Create_Request__c Where (Account_Name__c=:customername OR (Core_Alternate_Language_Name__c!=null AND Core_Alternate_Language_Name__c=:alternateLangName)) AND (Address__CountryCode__s=:primaryCountry AND Address__Street__s=:primaryStreet AND Address__City__s=:primaryCity AND Address__StateCode__s=:primaryState) AND (Status__c=\'In Process\' OR Status__c=\'Pending Approval\')';
            List<Account> duplicateAccounts=Database.query(queryAccount);
            List<DuplicateRecordWrapper> acctwrapperList=new List<DuplicateRecordWrapper>();
            List<DuplicateRecordWrapper> acctReqwrapperList=new List<DuplicateRecordWrapper>();
            for(Account acctRecord: duplicateAccounts){
                acctwrapperList.add(new DuplicateRecordWrapper(acctRecord.Id,
                acctRecord.Name,
                (acctRecord.BillingStreet != null?String.valueOf(acctRecord.BillingStreet)+', ':'')
                +(acctRecord.BillingCity != null?String.valueOf(acctRecord.BillingCity)+', ':'')
                +(acctRecord.BillingState != null?String.valueOf(acctRecord.BillingState)+', ':'')
                +(acctRecord.BillingPostalCode != null?String.valueOf(acctRecord.BillingPostalCode)+', ':'')
                +(acctRecord.BillingCountry != null?String.valueOf(acctRecord.BillingCountry)+', ':''),
                acctRecord.Owner.Name,
                acctRecord.Core_Unified_Global_Customer_Name__c,
                acctRecord.getSObjectType().getDescribe().getName()));
            }
            duplicateRecords.addAll(acctwrapperList);
    
            List<Account_Create_Request__c> duplicateAccountRequest=Database.query(queryAccountReqQueue);
            for(Account_Create_Request__c accReq:duplicateAccountRequest){
                acctReqwrapperList.add(new DuplicateRecordWrapper(accReq.Id,
                accReq.Account_Name__c,
                (accReq.Address__Street__s!= null?String.valueOf(accReq.Address__Street__s)+', ':'')
                +(accReq.Address__City__s!= null?String.valueOf(accReq.Address__City__s)+', ':'')
                +(accReq.Address__StateCode__s!= null?String.valueOf(accReq.Address__StateCode__s)+', ':'')
                +(accReq.Address__PostalCode__s!= null?String.valueOf(accReq.Address__PostalCode__s)+', ':'')
                +(accReq.Address__CountryCode__s!= null?String.valueOf(accReq.Address__CountryCode__s)+', ':''),
                Date.valueOf(accReq.CreatedDate),
                accReq.Requestor_Name__c,
                accReq.Process_Type__c,
                accReq.getSObjectType().getDescribe().getName()));
            }
            duplicateRecords.addAll(acctReqwrapperList);
        }
        catch(Exception ex){
            UCD_ACM_Logger.error('UCD_GenericAcctSearch_SBR','checkForDuplicates','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        }
        finally{
            UCD_ACM_Logger.setLogDetails();
        }
        return duplicateRecords;
    }

    public class DuplicateRecordWrapper {
	    @AuraEnabled
        public String acctRequestId {get;set;}

        @AuraEnabled
        public String customername {get;set;}

        @AuraEnabled
        public String acctRequestCountry {get;set;}

        @AuraEnabled
        public String status {get;set;}

        @AuraEnabled
        public String acctId {get;set;}

        @AuraEnabled
        public String accountName {get;set;}

        @AuraEnabled
        public String accountCountry {get;set;}

        @AuraEnabled
        public String unifiedId {get;set;}

        @AuraEnabled
        public String acctOwner {get;set;}

        @AuraEnabled
        public String unifiedGlobalCustomerName {get;set;}

        @AuraEnabled
        public String objectName {get;set;}

        @AuraEnabled
        public Date createdDate {get;set;}

        @AuraEnabled
        public String requestorName {get;set;}

        @AuraEnabled
        public String processType {get;set;}

        public DuplicateRecordWrapper(String acctRequestId, String customername, String acctRequestCountry, Date createdDate, String requestorName, String processType, String objectName){
            this.acctRequestId=acctRequestId;
            this.customername=customername;
            this.acctRequestCountry=acctRequestCountry;
            this.createdDate=createdDate;
            this.requestorName=requestorName;
            this.processType=processType;
            this.objectName=objectName;
        }

        public DuplicateRecordWrapper(String acctId, String accountName, String accountCountry, String acctOwner,String unifiedGlobalCustomerName,String objectName){
            this.acctId=acctId;
            this.accountName=accountName;
            this.accountCountry=accountCountry;
            this.acctOwner=acctOwner;
            this.unifiedGlobalCustomerName=unifiedGlobalCustomerName;
            this.objectName=objectName;
        }
    }
}