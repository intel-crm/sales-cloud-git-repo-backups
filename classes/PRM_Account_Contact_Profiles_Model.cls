@SuppressWarnings('PMD')

global class PRM_Account_Contact_Profiles_Model {
    /********************** Wrapper Classes **************************/
    global class Profiles {
      	//public RegRequestAccountProfile RegRequestAccountProfile {set;get;}
      	public RegistrationRequestProfileWrapper RegistrationRequestProfile {set;get;}
        public AccountRequestWrapper AccountRequest {set;get;}
        //public List<AccountRequestWrapper> AccountRequests {set;get;}
        public AccountProfileWrapper AccountProfile {set;get;}    
        public ContactAccountWrapper ContactAccount {set;get;}
        //public List<ContactAccountWrapper> ContactAccounts {set;get;} 
        public ContactBasicProfileDetailsWrapper ContactBasicProfile {set;get;}
        public OnePartnerIDGroupMembersWrapper OnePartnerIDGroupMembers {set;get;}
        public AccountResultWrapper AccountResults {set;get;}
        public ExceptionWrapper ExceptionDetails {set;get;}
        public Long ResponseTimeMS {set;get;}
        public ErrorMsg ErrorMsg {set;get;}
    }
    public class AccountResultWrapper {
        public String Status {set;get;}
        public Integer Responsecode {set;get;}
        public String ErrorResponse {set;get;}  
        public List<AccountResult> Results {set;get;}
    }
    public class AccountResult {
        public String CIMId	{set;get;}
        public String SalesforceId {set;get;}
        public String ERPMAccountNumber {set;get;}
        public String ERPMEngagementCode {set;get;} 
    }
    /*
    public class RegRequestAccountProfileWrapper {
        public RegRequestAccountProfile RegistrationRequest {set;get;}
    }
	
    public class RegRequestAccountProfile {       
        public AccountRequestWrapper AccountRequest {set;get;}
        public ContactAccountWrapper ContactAccount {set;get;}  
    }
    
    public class RegistrationRequestProfile {
        public RegistrationRequestProfileWrapper RegistrationRequest {set;get;}
    }
	*/
    public class RegistrationRequestProfileWrapper {
        public String RequestId {set;get;}
        public String Status {set;get;}
        public String PartnerRole {set;get;}
        public RegRequestAccountWrapper AccountInformation {set;get;}
    }
    public class RegRequestAccountWrapper {
        public String Name {set;get;}   
        public AccountAddress Address {set;get;}   
        public List<AccountContactRelationship> AccountContactRelationships {set;get;}
        public List<AccountChannelMembership> AccountChannelMemberships {set;get;}        
    }
    
    public class AccountRequest {
        public AccountRequestWrapper AccountRequest {set;get;}
    } 
	
    public class AccountRequestWrapper {
        public AccountRequestInformationWrapper AccountRequestInformation {set;get;}
        public List<AccountReqSubscription> Subscriptions {set;get;}
        public List<AccountReqTermsCondition> TermsAndConditions {set;get;}
        //public List<AccountReqCIMSearchResult> CIMSearchResults {set;get;}
    }
    /*
    public class AccountReqCIMSearchResult {
        public String AccountName {set;get;}
        public String AddressLine1 {set;get;}
        public String AddressLocation {set;get;}
        public String AddressType {set;get;}
        public String CIMId {set;get;}
        public String Name {set;get;}
        public Integer CIMSearchScore {set;get;}
        public String CityName {set;get;}
        public String CountryCode {set;get;}
        public String CountryName {set;get;}
        public String CountrySubdivisionCode {set;get;}
        public String CountrySubdivisionName {set;get;}    
        public String  PostalCode {set;get;}
        public String  SLSCLDRecord {set;get;}
    }
	*/
    public class AccountReqTermsCondition {
        public String Name {set;get;}
        public DateTime SignedDate {set;get;}
        public String PartnerAgreementName {set;get;}
        public String PartnerAgreementCode {set;get;}
        public String PartnerAgreementCategory {set;get;}
    }
    public class AccountReqSubscription {
        public String name {set;get;}
        public String SubscriptionName {set;get;}
        public String SubscriptionCode {set;get;}
    }
    public class AccountRequestInformationWrapper {
        public String AccountRequestId  {set;get;}
        public String AccountCIMID {set;get;}
        public String AccountSalesforceID {set;get;}
        public String AddressLine1 {set;get;}
        public String AddressLine2 {set;get;}
        public String BizOrgType {set;get;}
        public String CIMStatusDetails {set;get;}
        public String City {set;get;}
        public String CompanyEmailDomain {set;get;}
        public String CompanyName {set;get;}
        public String CompanyNationalID {set;get;}
        public String ContactEnterpriseID {set;get;}
        public boolean ContactEVflag {set;get;}
        public String ContactEVToken {set;get;}
        public String ContactFirstName {set;get;}
        public String ContactJobFunction {set;get;}
        public String ContactLastName {set;get;}
        public String ContactLoginID {set;get;}
        public String ContactPhoneNumber {set;get;}
        public String Country {set;get;}
        public String ContactCountry {set;get;}
        public String DuplicateAccountCheck {set;get;}
        public String DuplicateAccountStatus {set;get;}
        public String DuplicateContact {set;get;}
        public String Email {set;get;}
        public String EmailDomainCheck {set;get;}
        public String EmailLog {set;get;}
        public DateTime EmailVerifiedDateTime {set;get;}
        public String EVExpiredvsPending {set;get;}
        public boolean isLocked {set;get;}
        public boolean isSubmitted {set;get;}
        public String LegalAgreementCheck {set;get;}
        public String LegalAgreements {set;get;}
        public String manualRecordCheck {set;get;}
        public String PartnerProgram {set;get;}
        public String PartnerRole {set;get;}
        public String PartnerSegment {set;get;}
        public String PartnerTier {set;get;}
        public String PhysicalAddressLine2 {set;get;}
        public String PhysicalCity {set;get;}
        public String PhysicalCountry {set;get;}
        public String PhysicalStateProvince {set;get;}
        public String PhysicalZipCode {set;get;}
        public String PreferredLanguage {set;get;}
        public String ProfileResponses {set;get;}    
        public String StateProvince {set;get;}
        public String Status {set;get;}
        public String StatusReason {set;get;}
        public String Subscriptions {set;get;}
        public String TaxIDRegistrationNumber {set;get;}   
        public String Userdefinedcompanysize {set;get;}
        public String UserdefinedPhonenumber {set;get;}
        public String UserdefinedWebsite {set;get;}
        public String ZipPostalCode {set;get;}
        //public String WeChatUnionId {set; get;}
        //-----------------------------We chat-----------------------------
        /*
        public  String WechatOpenId {set; get;}
        public  String WechatUnionId {set; get;}
        public  String RegistrationSource {set; get;}
		*/
        //-----------------------------We chat-----------------------------
        
        
    }
    /*
    public class AccountProfile {
        public AccountProfileWrapper AccountProfile {set;get;}        
    }     
	*/
    public class AccountProfileWrapper {
        public AccountInformationWrapper AccountInformation {set;get;}        
        //public List<AcctContact> Contacts {set;get;}
        public List<AccountContactRelationship> AccountContactRelationships {set;get;}
        public List<AccountERPMEngagement> AccountEngagements {set;get;}
        public List<AccountChannelMembership> AccountChannelMemberships {set;get;}
        public List<AccoutBenefitAssociation> AccoutBenefitAssociations {set;get;}
        public List<AccountSpecialityAssociation> AccountSpecialityAssociations {set;get;}
        //public List<OnePartnerIDGroupMember> OnePartnerIDGroupMembers {set;get;}
        public List<AccountLegalAgreement> AccountLegalAgreements {set;get;}
    }
    public class AccountLegalAgreement{
        //(SELECT Name,PRM_Agreement_Sign_Dt__c,PRM_Contact__c,PRM_Partner_Agreement_Id__r.Name,PRM_Partner_Agreement_Id__r.PRM_InActive_Ind__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Category_Nm__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c,PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name FROM AccountLegalAgreementAssociations__r)
        public String LeagalAgreementName {set;get;}
        public DateTime AgreementSignedDate {set;get;}
        public String AgreementSignedBy {set;get;}      
        public boolean IsPartnerAgreementActive {set;get;}
        public String PartnerAgreementName {set;get;}
        public String PartnerAgreementCode {set;get;}
        public String PartnerProgramName {set;get;}
        
    }
    
    public class AccountSpecialityAssociation {
        public String Name {set;get;}      
        public boolean IsInactive {set;get;}
        //public String Status {set;get;}
        public String SpecialityName {set;get;}
        public String SpecialityRole {set;get;}
        public String SpecialityTier {set;get;}        
    }
    public class AccountChannelMembership {        
        public String PartnerProgramName {set;get;}
        public String PartnerProgramCode {set;get;}
        public String PartnerTier {set;get;}
        public String PartnerRole {set;get;}
        public String Status {set;get;}
    }   
    public class AccoutBenefitAssociation {
        public String BenefitName {set;get;}
        public String BenefitCode {set;get;}
        public String BenefitType {set;get;}
        public String PartnerProgamName {set;get;}
        public String PartnerProgamCode {set;get;}
        public String Status {set;get;}
    }
    /*
    public class ContactAccount {
        public ContactAccountWrapper ContactAccount {set;get;}        
    }
	*/
    public class ContactAccountWrapper {
        public  AccountInformationWrapper AccountInformation {set;get;}  
        //public  ContactBasicInformationWrapper ContactBasicInformation {set;get;}
        public ContactBasicProfileDetailsWrapper ContactBasicProfile {set;get;}
    }
    public class AccountInformationWrapper{
        public String AccountId {set;get;}
        public  String Name {set;get;}       
        public  String AlternateLanguageName {set;get;}
        public  String BizOrgType {set;get;}
        public  String PartnerRole {set;get;}
        public  String ParentAccount {set;get;}
        public  String AccountLegalName {set;get;}
        public  String PrimeAccountName {set;get;}
        public  boolean CoveredAccount {set;get;}
        public  String CNDANumber {set;get;}
        public  String SalesGroup {set;get;}
        public  String AccountBUFocus {set;get;}
        public  String AccountTier {set;get;}
        public  String Industry {set;get;}
        public String CompanySize {set; get;}
        public String CompanyWebsite {set; get;}
        /*
public  String AltLanguageAddress1 {set;get;}
public  String AltLanguageAddress2 {set;get;}
public  String AltLanguageCity {set;get;}
public  String AltLanguageState {set;get;}
public  String AltLanguageCountry {set;get;}
public  String AltLanguagePostalCode {set;get;}
*/
        public String CIMId {set;get;}
        public boolean IPSActive {set;get;}
        public String BusinessId {set;get;}
        public String BusinessPartnerId {set;get;}
        public boolean IsIPA {set;get;}
        public AccountAddress Address {set;get;}   
        public List<AccountContactRelationship> AccountContactRelationships {set;get;}
        public List<AccountERPMEngagement> AccountEngagements {set;get;}
        public List<AccoutBenefitAssociation> AccoutBenefitAssociations {set;get;}
        public List<AccountChannelMembership> AccountChannelMemberships {set;get;}
        public List<ProfileResponse> ProfileResponses {set;get;} 
    }    
    public class ProfileResponse {
        public String QuestionText {set;get;}
        public String QuestionCode {set;get;}
        //public List<ProfileAnswer> Answers {set;get;}
        public List<String> Responses {set;get;}    
    }   
    public class AccountContactRelationship{
        public  string AccountName {set;get;}
        public  String PartnerRole {set;get;}
        public  String Relationship {set;get;}
        public  String Status {set;get;}
        public  boolean InactiveIndicator {set;get;}
    }
    public class AccountERPMEngagement{
        public  string AccountName {set;get;}
        public  String EngagementName {set;get;}
        public  String EngagementCode {set;get;}
        public  String Tier {set;get;}
    }
    /*
    public class ContactBasicProfileWrapper{        
        public ContactBasicProfileDetailsWrapper ContactBasicProfile {set;get;}
        //List<AccountContactRelationship> AccountContactRelationships {set;get;}        
    }
	*/
    public class AccountAddress {
        public Address PrimaryAddress {set;get;}
        public Address SecondaryAddress {set;get;}
    }
    public class ContactSubscription{
        public  String Name {set;get;}
        public  String Status {set;get;}
        public  String Code {set;get;}
    }
    public class ContactEntitlement{
        public  String Name {set;get;}
        public  String Type {set;get;}
        public  String Status {set;get;}
        //public  String OpsStatus {set;get;}
        public  boolean IsSelected {set;get;}
    }
    public class ContactBasicProfileDetailsWrapper{
        public ContactBasicInformationWrapper ContactBasicInformation {set;get;}
        public List<ContactSubscription> ContactSubscriptions {set;get;}
        public List<ContactEntitlement> ContactEntitlements {set;get;}
        //List<AccountContactRelationship> AccountContactRelationships {set;get;}        
    }
    public class ContactBasicInformationWrapper{
        public  Id ContactId {set;get;}
        public  Id AccountId {set;get;}
        public  String AccountName {set;get;}
        public  String Title {set;get;}
        public  String FullName {set;get;}
        public  String LocalFirstName {set;get;}
        public  String LocalLastName {set;get;}
        public  String EnglishFirstName {set;get;}
        public  String EnglishLastName {set;get;}
        public  String FirstName {set;get;}
        public  String LastName {set;get;}
        public 	DateTime EmailVerificationDate {set;get;}
        public  String JobFunction {set;get;}
        public  String JobFunctionCode {set;get;}
        public  String Phone {set;get;}
        public  String Mobile {set;get;}
        public  String Email {set;get;}
        public  String PreferredCommunication {set;get;}
        public  String PreferredLanguage {set;get;}
        public  String PartnerRole {set;get;}
        public  String Segment {set;get;}
        public  String LoginId {set;get;}
        public  String eRPMPersonId {set;get;}
        public  String EnterpriseId {set;get;} 
        public  String WeChatUnionId {set; get;}
        //-----------------------------We chat-----------------------------
        /*
        public  String WechatOpenId {set; get;}
        public  String WechatUnionId {set; get;}
        public  String RegistrationSource {set; get;}
		*/
        //-----------------------------We chat-----------------------------
        
        public Address MailingAddress {set;get;}        
    }
    public class address{
        public  String Street {set;get;}
        public  String City {set;get;}
        public  String State {set;get;}
        public  String StateCode {set;get;}
        public  String Country {set;get;}
        public  String CountryCode {set;get;}
        public  String CountryCodeShort {set;get;}
        public  String PostalCode {set;get;}
    }
    public class OnePartnerIDGroupMembersWrapper {
        public String AccountId {set;get;}
        public String AccountName {set;get;}
        public List<OnePartnerIDGroupMember> OnePartnerIDGroupMembers {set;get;}
    }
    public class OnePartnerIDGroupMember {
        public String OnePartnerGroupMemberName {set;get;}
        public String IntelAccountId {set;get;}
        public String IntelAccountName {set;get;}
        public String OnePartnerAccountId {set;get;}
        public String OnePartnerAccountName {set;get;}
        public boolean IsInactive {set;get;}
        public boolean MDAIndicator {set;get;}
    }    
    public class ExceptionWrapper {
        public String Status {set;get;}
        public Integer StatusCode {set;get;}
        public String Message {set;get;}
        public String StackTrace {set;get;}
    }
    public class ErrorMsg {
        public boolean error {set;get;}
        public String msg {set;get;}
    }
    
    /********************** End of Wrapper Classes **************************/
}