public without sharing class UCD_ACM_Models {
    public class AccountModelForService {
        public List<AccountModel> AccountModelService {
            set; get;
        }
    }

    /* Unused code Ankit 25/11/23
    public class ResponseAfterAccountInset{
        public Boolean IsSuccess {
            set; 
            get;
        }
        public String Message {
            set;
            get;
        }
        public List<Account> AccountData {
            set;
            get;
        }
    }*/

    public class AccountModel {
        public String Name {
            set;
            get;
        }
        public String CustomerURL {
            set;
            get;
        }
        public String CustomerAggregationTypeCode {
            get; set;
        }
        public String CustomerProcessEngagmentCode {
            get; set;
        }
        public String RequesterEmail {
            get; set;
        }
        public String RequesterName {
            get; set;
        }
        public String RequesterWWID {
            get; set;
        }
        public List<AccountAddress> Addresses {
            set; get;
        }
        public String RecordTypeId {
            set; get;
        }
        public Boolean IsDuplicate { 
            set; get;
        }
        public String DuplicateAccount {
            set; get;
        }
        public String DuplicateAccountRecordType {
            set; get;
        }
        public AccountResponseModel DuplicateAccountInfo{
            set; get;
        }
        public Map<String ,String> AccountRequestReferences {
            get;set;
        }
		public String ParentBusinessPartyIdentifierReference {
            get;set;
        }
    }
    public class AccountRequestQueueModel {
        public AccountResponseModel Account {
            get;
            set;
        }
        public string RequestId {
            get;
            set;
        }
        public string Status {
            get;
            set;
        }
        public string AccountId {
            get;
            set;
        }
        public string RejectionReason {
            get;
            set;
        }
        public string AccountReferenceSourceName {
            get;
            set;
        }
        
    }


    public class ListBusinessOrganizationResponseforService {
        public List<BusinessOrganizationResponseforService> BusinessOrganizationResponse {
            set;
            get;
        }
    }

    public class BusinessOrganizationResponseforService {
        public Account AccountData {
            set;
            get;
        }
        public String AccountStatus {
            set; get;
        }
        public String CountryName {
            set; get;
        }
        public string ErrorMessage {
            set; get;
        }
        public String AccountId {
            set; get;
        }
        public String DuplicateAccountId {
            set; get;
        }
        public String DuplicateAccountRecordType {
            set; get;
        }
        public AccountResponseModel DuplicateAccountInfo{
            set; get;
        }
        // public BusinessOrganizationResponseforService mapAccountsToAccountResponseModel( Account AccountData, String AccountStatus, String CountryName, String ErrorMessage, String AccountId, String DuplicateAccountId, String DuplicateAccountRecordType) {
        //     BusinessOrganizationResponseforService accountResponse = new BusinessOrganizationResponseforService();
        //     accountResponse.AccountData = AccountData;
        //     accountResponse.AccountStatus = AccountStatus;
        //     accountResponse.CountryName = CountryName;
        //     accountResponse.ErrorMessage = ErrorMessage;
        //     accountResponse.AccountId = AccountId;
        //     accountResponse.DuplicateAccountId = DuplicateAccountId;
        //     accountResponse.DuplicateAccountRecordType = DuplicateAccountRecordType;
        //     return accountResponse;
        // }
        public BusinessOrganizationResponseforService mapAccountsToAccountResponseModel( Account AccountData, String AccountStatus, String CountryName, String ErrorMessage, String AccountId, AccountResponseModel DuplicateAccountInfo) {
            BusinessOrganizationResponseforService accountResponse = new BusinessOrganizationResponseforService();
            accountResponse.AccountData = AccountData;
            accountResponse.AccountStatus = AccountStatus;
            accountResponse.CountryName = CountryName;
            accountResponse.ErrorMessage = ErrorMessage;
            accountResponse.AccountId = AccountId;
             accountResponse.DuplicateAccountId = DuplicateAccountId;
             accountResponse.DuplicateAccountRecordType = DuplicateAccountRecordType;
            accountResponse.DuplicateAccountInfo = DuplicateAccountInfo;
            return accountResponse;
        }
    }

    public class AccountAddress {
        public String TypeCode {
            set;
            get;
        }
        public string CountryCode {
            get; set;
        }
        public string CountryName {
            get; set;
        }
        public AccountAddress mapAddressToAccountAddress(Account account,String code) {
            if (account.BillingCountryCode != null && account.BillingCountryCode != '') {
                AccountAddress address = new AccountAddress();
                if(code == 'Billing'){
                    address.typeCode = 'Billing';
                    if (account.BillingCountryCode.length() == 2) {
                        String validCountryCode = UCD_ACM_Utils.validateCountryName(account.BillingCountry);
                        address.countryCode = account.BillingCountryCode;
                        address.countryName = UCD_ACM_Utils.validateCountryCode(validCountryCode);
                    } else  {
                        address.countryCode = account.BillingCountryCode;
                        address.countryName = UCD_ACM_Utils.validateCountryCode(account.BillingCountryCode);
                    }
                }else{
                    address.typeCode = 'Shipping';
                    if (account.ShippingCountryCode.length() == 2) {
                        String validCountryCode = UCD_ACM_Utils.validateCountryName(account.ShippingCountry);
                        address.countryCode = account.ShippingCountryCode;
                        address.countryName = UCD_ACM_Utils.validateCountryCode(validCountryCode);
                    } else  {
                        address.countryCode = account.ShippingCountryCode;
                        address.countryName = UCD_ACM_Utils.validateCountryCode(account.ShippingCountryCode);
                    }
                }
                
                return address;
            }
            return null;
        }
    }

    public class MasteredBusinessPhysicalAddress {
        /*public string CountryCode {
            get;
            set;
        }*/
        public string CountryName {
            get; set;
        }
        public MasteredBusinessPhysicalAddress(String countryName) {
            //this.countryCode = countryCode;
            this.countryName = countryName;
        }
    }

    public class ComplianceWatchList {
        public string Code {
            get;
            set;
        }
        public string Name {
            get; set;
        }
        public ComplianceWatchList(String code,String name) {
            this.code = code;
            this.name = name;
        }
    }

    public class CustomerAggregationType {
        public string Code {
            get;
            set;
        }
        public string Name {
            get; set;
        }
        public CustomerAggregationType(String code,String name) {
            this.Code = code;
            this.Name = name;
        }
    }

    public class CustomerProcessEngagement {
        public string Code {
            get;
            set;
        }
        public string Name {
            get; set;
        }
        public CustomerProcessEngagement(string code, string name) {
            this.code = code;
            this.name = name;
        }
    }

    public class PE_HeaderResponse {
        public string CustomerAggregationType {
            get;
            set;
        }
        public string CustomerProcessEngagement {
            get; set;
        }
        public PE_HeaderResponse mapAccountsToHeaders(Account account, List<Business_Types__c> businessTypes) {
            PE_HeaderResponse headerResponse = new PE_HeaderResponse();
            String customerProcessEngagements;
            headerResponse.customerAggregationType = account.Core_Customer_Aggregation_Type__c != null?account.Core_Customer_Aggregation_Type__c:'';
            if (businessTypes != null) {
                For(Business_Types__c businessType: businessTypes) {
                    customerProcessEngagements = customerProcessEngagements != null ? customerProcessEngagements+', '+businessType.Business_Type_Code__c : businessType.Business_Type_Code__c;
                }
                headerResponse.customerProcessEngagement = customerProcessEngagements;
            }
            return headerResponse;
        }
    }

    public class AccountResponseModel {
        public string AccountId {
            get;
            set;
        }
        public string AccountName {
            get; set;
        }
        public string SurvivorAccountId{
            get;set;
        }
        public string BusinessPartyIdentifier {
            get; set;
        }
        public string ComplianceStatus {
            get; set;
        }
        public string MasteredSimplifiedAccountName {
            get; set;
        }
        // public string DataSimplifiedAccountName {
        //     get; set;
        // }
        public String RecordType {
            get; set;
        }
        public string RequestedAccountRejectionReason {
            get; set;
        }
        public string RequestedAccountRejectionNotes {
            get; set;
        }
        public string GlobalCustomerBPId {
            get; set;
        }
        public string GlobalCustomerSimplifiedName {
            get; set;
        }
        public string IntermediateCustomer1BPId {
            get; set;
        }
        public string IntermediateCustomer1SimplifiedName {
            get; set;
        }
        public string IntermediateCustomer2BPId {
            get; set;
        }
        public string IntermediateCustomer2SimplifiedName {
            get; set;
        }
        public AccountAddress PrimaryAddress {
            get; set;
        }
        public AccountAddress SecondaryAddress {
            get; set;
        }
        public MasteredBusinessPhysicalAddress MasteredBusinessPhysicalAddress {
            get; set;
        }
        public CustomerAggregationType CustomerAggregationType {
            get; set;
        }
        public List<CustomerProcessEngagement> CustomerProcessEngagement {
            get; set;
        }
        public AccountResponseModel ParentAccount {
            get; set;
        }
        public list<ComplianceWatchList> ComplianceWatchList {
            get; set;
        }



        // This method used to return query to get parent account details.
        public String getParentAccountQueryForEvent() {
            return 'Id,Name,RecordTypeId,Core_Business_Party_Id__c, Core_Compliance_Watch_List_Type__c, Core_Compliance_Status__c, Core_Data_Simplified_Account_Nm__c,Core_Parent_Data_Simplified_Account_Nm__c,ParentId,Parent.Core_Customer_Aggregation_Type__c,Core_Customer_Aggregation_Type__c,Core_Unified_Global_Customer_Name__c,Core_Unified_Global_Customer_BP_Id__c,Core_Account_Reference_Source_Name__c,Core_Unified_Intermediate_Customer_BP_Id__c,Core_Unified_Intermediate_Customer_Name__c,Core_Unified_Intermdt_Customer_2_BP_Id__c,Core_Unified_Intermdt_Customer_2_Name__c,Core_Survivor_Account_Id__c,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,BillingCountry,BillingCountryCode,ShippingCountry,ShippingCountryCode,Core_Data_Country_Nm__c,Core_Parent_Business_Party_Id__c';        
        }

        // This method used to return query to get customerProcessEngagement details.
        public String getAccountBusinessTypesQueryForEvent() {
            return 'Account__c,Business_Types__c';
        }

        // This method used to return query to get customerProcessEngagement details.
        public String getComplianceWatchListQueryForEvent() {
            return 'Core_Account_Id__c,Core_Type__c,Core_Effective_End_Date__c ';
        }
       
        /*
         * description : Map Account Record To AccountResponseModel
         * params : Account , Map<Id,Account>
         * return : AccountResponseModel
         * author and date : harshalx.sunil.gosavi@intel.com, 4th August 2021
         */
        public AccountResponseModel mapAccountsToAccountResponseModel(Account account, Map<Id,Account> parentAccountById) {
            //do the mapping here
            AccountAddress address = new AccountAddress();
            AccountResponseModel responseModel = new AccountResponseModel();
            String objectName = 'Account';
            if(Label.UCD_ACM_Switch_IAO_Change == 'true'){
                List<UCD_ACM_Models.ComplianceWatchList> complianceWatchLists = new List<UCD_ACM_Models.ComplianceWatchList>();
                if(account.Core_Compliance_Watch_List_Type__c!=null){
                    List<String> complianceWatchListValues=account.Core_Compliance_Watch_List_Type__c.split(';');
                    for(String cwlValue : complianceWatchListValues){
                        complianceWatchLists.add(new UCD_ACM_Models.ComplianceWatchList(cwlValue,UCD_ACM_Utils.getPicklistLabel('Account','Core_Compliance_Watch_List_Type__c',cwlValue)));
                    }
                }
                responseModel.ComplianceWatchList=complianceWatchLists;
                responseModel.ComplianceStatus = String.isNotBlank(account.Core_Compliance_Status__c) ? account.Core_Compliance_Status__c : '';
            }
            else{
                List<UCD_ACM_Models.ComplianceWatchList> complianceWatchLists = new List<UCD_ACM_Models.ComplianceWatchList>();
                if(account.Core_Compliance_Watch_List_Type__c!=null){
                    List<String> complianceWatchListValues=account.Core_Compliance_Watch_List_Type__c.split(';');
                    for(String cwlValue : complianceWatchListValues){
                        complianceWatchLists.add(new UCD_ACM_Models.ComplianceWatchList(cwlValue,UCD_ACM_Utils.getPicklistLabel('Account','Core_Compliance_Watch_List_Type__c',cwlValue)));
                    }
                }
                responseModel.ComplianceWatchList=complianceWatchLists;
            }
            responseModel.accountId = account.Id;
            responseModel.accountName = String.isNotBlank(account.Name)?account.Name:'';
            responseModel.SurvivorAccountId = String.isNotBlank(account.Core_Survivor_Account_Id__c) ? account.Core_Survivor_Account_Id__c : null;
            responseModel.businessPartyIdentifier = String.isNotBlank(account.Core_Business_Party_Id__c) ? account.Core_Business_Party_Id__c:'';
            responseModel.masteredSimplifiedAccountName = String.isNotBlank(account.Core_Data_Simplified_Account_Nm__c) ? account.Core_Data_Simplified_Account_Nm__c : '';
            //responseModel.dataSimplifiedAccountName = account.Core_Data_Simplified_Account_Nm__c != null ? account.Core_Data_Simplified_Account_Nm__c : '';
            responseModel.recordType = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(account.RecordTypeId).getName();
            responseModel.requestedAccountRejectionReason = String.isNotBlank(account.Core_Account_Request_Rejection_Reason__c) ? UCD_ACM_Utils.getPicklistLabel(objectName,'Core_Account_Request_Rejection_Reason__c',account.Core_Account_Request_Rejection_Reason__c) : '';
            responseModel.requestedAccountRejectionNotes = String.isNotBlank(account.Core_Account_Request_Rejection_Notes__c) ? account.Core_Account_Request_Rejection_Notes__c : '';           
            responseModel.GlobalCustomerBPId = String.isNotBlank(account.Core_Unified_Global_Customer_BP_Id__c) ? account.Core_Unified_Global_Customer_BP_Id__c : '';
            responseModel.GlobalCustomerSimplifiedName = String.isNotBlank(account.Core_Unified_Global_Customer_Name__c) ? account.Core_Unified_Global_Customer_Name__c : '';
            responseModel.IntermediateCustomer1BPId = String.isNotBlank(account.Core_Unified_Intermediate_Customer_BP_Id__c) ? account.Core_Unified_Intermediate_Customer_BP_Id__c : '';
            responseModel.IntermediateCustomer1SimplifiedName = String.isNotBlank(account.Core_Unified_Intermediate_Customer_Name__c) ? account.Core_Unified_Intermediate_Customer_Name__c : '';
            responseModel.IntermediateCustomer2BPId = String.isNotBlank(account.Core_Unified_Intermdt_Customer_2_BP_Id__c) ? account.Core_Unified_Intermdt_Customer_2_BP_Id__c : '';
            responseModel.IntermediateCustomer2SimplifiedName = String.isNotBlank(account.Core_Unified_Intermdt_Customer_2_Name__c) ? account.Core_Unified_Intermdt_Customer_2_Name__c : '';        
            responseModel.primaryAddress = String.isNotBlank(account.BillingCountry) ? address.mapAddressToAccountAddress(account,'Billing') : null;
            responseModel.secondaryAddress = String.isNotBlank(account.ShippingCountry) ? address.mapAddressToAccountAddress(account,'Shipping') : null;
            responseModel.masteredBusinessPhysicalAddress = new UCD_ACM_Models.masteredBusinessPhysicalAddress(String.isNotBlank(account.Core_Data_Country_Nm__c) ?account.Core_Data_Country_Nm__c:'');
            responseModel.customerAggregationType = new UCD_ACM_Models.customerAggregationType(String.isNotBlank(account.Core_Customer_Aggregation_Type__c) ? account.Core_Customer_Aggregation_Type__c:'',UCD_ACM_Utils.getPicklistLabel(objectName,'Core_Customer_Aggregation_Type__c',String.isNotBlank(account.Core_Customer_Aggregation_Type__c) ? account.Core_Customer_Aggregation_Type__c:''));
            // Create Parent Account Refrence
            if (parentAccountById != null && parentAccountById.containsKey(account.parentId)) {
                AccountResponseModel responseModelForParent = new AccountResponseModel();
                responseModelForParent.accountId = account.parentId;
                responseModelForParent.accountName = String.isNotBlank(parentAccountById.get(account.parentId).Name) ? parentAccountById.get(account.parentId).Name:'';
                responseModelForParent.businessPartyIdentifier = String.isNotBlank(parentAccountById.get(account.parentId).Core_Business_Party_Id__c) ? parentAccountById.get(account.parentId).Core_Business_Party_Id__c:'';
                responseModelForParent.MasteredSimplifiedAccountName = String.isNotBlank(parentAccountById.get(account.parentId).Core_Data_Simplified_Account_Nm__c) ? parentAccountById.get(account.parentId).Core_Data_Simplified_Account_Nm__c:'';
                responseModel.parentAccount = responseModelForParent;
            }
            else if(String.isNotBlank(account.Core_Parent_Business_Party_Id__c ) && (String.isNotBlank(account.Core_Parent_Data_Simplified_Account_Nm__c))) {
                AccountResponseModel responseModelForParent = new AccountResponseModel();
                responseModelForParent.accountId = '';
                responseModelForParent.accountName = '';
                responseModelForParent.businessPartyIdentifier = account.Core_Parent_Business_Party_Id__c;
                responseModelForParent.MasteredSimplifiedAccountName = account.Core_Parent_Data_Simplified_Account_Nm__c;
                responseModel.parentAccount = responseModelForParent;
            }

            return responseModel;
        }
        /*
         * description : Map BusinessTypes Records To AccountResponseModel
         * params : AccountResponseModel , List<Business_Types__c>
         * return : AccountResponseModel
         * author and date : harshalx.sunil.gosavi@intel.com, 22nd August 2021
         */
        public AccountResponseModel mapBusinessTypesToModel(UCD_ACM_Models.AccountResponseModel mappedAccountResponse, List<Business_Types__c> businessTypes) {
            List<UCD_ACM_Models.customerProcessEngagement> customerProcessEngagements = new List<UCD_ACM_Models.customerProcessEngagement>();
            For(Business_Types__c businessType: businessTypes) {
                customerProcessEngagements.add(new UCD_ACM_Models.CustomerProcessEngagement(businessType.Business_Type_Code__c,businessType.Name));
            }
            if (customerProcessEngagements.size() > 0) {
                mappedAccountResponse.customerProcessEngagement = customerProcessEngagements;
                return mappedAccountResponse;
            }
            return mappedAccountResponse;
        } 
    }

     /***************************************
   * Reltio Model
   ***************************************/

    public class SearchRequest{ 
        public String BusinessOrganizationName {set;get;}
        public String CustomerAggregationTypeCd {set;get;}
        public String WebsiteURL {set;get;}
        public String Address {set;get;}
        public String CustomerProcessEngagement {set;get;}
    }

    public class ReltioResponse { 
        public String Uri {set;get;}
        public String Relevance {set;get;}
        public String BusinessPartyId {set;get;}
        public String Name {set;get;}
        public List<BusinessOrganisationName> BusinessOrganisationNames{set;get;}
        public String CustomerAggregationType {set;get;}
        public String WebsiteURL {set;get;}
        public String Addresses {set;get;}
        public String CustomerProcessEngagementCode {set;get;}
        public List<ParentDetail> ParentDetails{set;get;}
    }

    public class BusinessOrganisationName{
        public String Name {set;get;}
        public String Type {set;get;}
    }

    public class ParentDetail{
        public String ParentBusinessPartyId {set;get;}
        public String ParentName {set;get;}
        public String ParentAccountType {set;get;}
    }

    public class list_items{
        public List<ReltioResponsesAPI> list_items{set;get;}
        public String PotentialMatches {set;get;}
    }

    public class ReltioResponsesAPI{
        public String uri {set;get;}
        public String relevance {set;get;}
        public String Record_Label {set;get;}
        public List<BusinessOrganizationNameAPI> BusinessOrganizationName{set;get;}
        public String CustomerAggregationTypeCd {set;get;}
        public String WebsiteURL {set;get;}
        public String Addresses {set;get;}
        public String CustomerProcessEngagement {set;get;}
        public List<AggregateParent> AggregateParent{set;get;}
    }

    public class BusinessOrganizationNameAPI{
        public String BusinessOrganizationNm {set;get;}
        public String BusinessNameTypeCd {set;get;}
        public String LanguageCode {set;get;}
    }

    public class AggregateParent{
        public String label {set;get;}
        public String relationshipLabel {set;get;}
    }

    public class AccessToken{
        public String access_token;
    }
}