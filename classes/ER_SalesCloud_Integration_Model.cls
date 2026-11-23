/******************************************************************************************************************************************
Class Name  : ER_SalesCloud_Integration_Model
Test Class Name : ER_SalesCloud_Integration_Test, Coverage:93%
Version     : 1.0 
Created Date: 15 May 2024
Function    : Wrapper class for ER_SalesCloud_Integration.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Shreyash Agrawal         15/05/2024             Original version 
*****************************************************************************************************************************************/
public class ER_SalesCloud_Integration_Model {
    
    public class AEAccountInformation {
        public String Name {set;get;}
        public String AccountNo {set;get;}
        public String PrimeAccountName {set;get;}
        public String SalesGroup {set;get;}
        public String Industry {set;get;}
        public boolean CoveredAccount {set;get;}
        public String CNDANumber {set;get;}
        public String CIMId {set;get;}
        public String UnifiedID {set; get;} //TWC729-6800 EOL activities
        public String BusinessPartnerId {set;get;}
        public String BusinessId {set;get;}
        public String BizOrgType {set;get;}
        public String PartnerRole {set;get;}
        public String Region {set;get;}
        public String SubRegion {set;get;}
        public String UserDefinedPhoneNumber {set;get;}
        public String UserDefinedWebsite {set;get;}        
        public String EnglishNameOnly {set;get;}        
        public String PartnerProgramSegment {set;get;}
        public String PartnerProgramSpecialty {set;get;}     
        public String AccountLegalName {set;get;}
        public String AccountBUFocus {set;get;}   
        public String OnePartnerIdAccountName {set;get;}
        public RecordOwner AccountOwner {set;get;}       
        public String RecordType {set;get;} 
        public String BadgeTier {set;get;}
        public Boolean Deactivated {set;get;} 
        public String DeactivatedReason {set;get;}
        public boolean IsIPA {set;get;}
        public Boolean IsODM {set;get;}
        public AccountAddress Address {set; get;}
    }  
    public class AccountBasicInformation {
        public String Name {set;get;}
        public String AccountNo {set;get;}
        public String PrimeAccountName {set;get;}
        public String BusinessPartnerId {set;get;}
        public String BusinessId {set;get;}
        public boolean CoveredAccount {set;get;}
        public RecordOwner AccountOwner {set;get;}  
        public AccountAddress Address {set; get;}
        public String UCDID {set;get;}
    }
    public class RecordOwner {
        public String Email {set;get;}
        public String FirstName {set;get;}
        public String LastName {set;get;}
        public RecordOwner(String Email,String FirstName, String LastName ){
            this.Email = Email;
            this.FirstName = FirstName;
            this.LastName = LastName;
        }
    }
    public class AccountAddress {
        public Address PrimaryAddress {set;get;}
        public Address SecondaryAddress {set;get;}
    } 
    public class AccountAEPayload{
        public String MessageType {set;get;} 
        public String BusinessTypeNames {set;get;} 
        public String AccountId {set;get;}
        public String AccountStatus {set;get;}
        public AEAccountInformation AccountInformation{set;get;}
        public List<AccountBusinessType> AccountBusinessTypes {set;get;}
        public DateTime LastModifiedDate {set;get;}
        public DateTime CreatedDate {set;get;}
        public String LastModifiedBy {set;get;}
        public String CreatedBy {set;get;} 
        
    }
    public class DSAPayload {
        public String ContactId {set;get;}
        public String AccountId {set;get;}
        public String AccountStatus {set;get;}
        public String ContactStatus {set;get;}
        public String DeletionReason {set;get;}
        public Boolean isODMAccount {set;get;}
        //public ContactBasicProfile ContactBasicProfile {set;get;}
        public AccountBasicInformation AccountBasicInformation {set;get;}
        public ContactBasicInformation ContactBasicInformation {set;get;}
        //public List<ContactSubscription> ContactSubscriptions {set;get;}
        public List<ContactEntitlementAnE> ContactEntitlements {set;get;}
        //public List<AccountContactRelationship> AccountContactRelationships {set;get;}
        public List<ContactBusinessType> ContactBusinessTypes {set;get;}
        public String MessageType {set;get;} 
         public String BusinessTypeNames {set;get;} 
        //public String CIMID {set; get;}
        public DateTime LastModifiedDate {set;get;}
        //public String AccountNum {set;get;}
        public List<cmfWrapper> CMFGroups{set;get;}
    }
    public class cmfWrapper {
        public String GroupName{set;get;}
        public String GroupId{set;get;}
        public string Description{set;get;}
        public Boolean Active{set;get;}
        public String ActiveCMFCount{set;get;}
        public String InActiveCMFCount{set;get;}
        public String ActiveContactCount{set;get;}
        public String InActiveContactCount{set;get;}
        public DateTime LastModifiedDate {set;get;}
        public DateTime CreatedDate {set;get;}
        public String LastModifiedBy {set;get;}
        public String CreatedBy {set;get;}
        public List <cmfData> CMFs {set;get;}
    
       // public List <accountBPData> BPAccounts {set;get;}
        
    }
    public class cmfWrapperAnE {
        public String MessageType{set;get;}
        public String GroupName{set;get;}
        public String GroupId{set;get;}
        public string Description{set;get;}
        public Boolean Active{set;get;}
        public String ActiveCMFCount{set;get;}
        public String InActiveCMFCount{set;get;}
        public String ActiveContactCount{set;get;}
        public String InActiveContactCount{set;get;}
        public DateTime LastModifiedDate {set;get;}
        public DateTime CreatedDate {set;get;}
        public String LastModifiedBy {set;get;}
        public String CreatedBy {set;get;} 
        public List <cmfData> CMFs {set;get;}
        //public List <accountBPData> BPAccounts {set;get;}
        public List<ContactBasicInfoAE> ContactBasicInformation {set;get;}
    }
    
    public class cmfData{
        public String CMFID {set;get;}
        public string Name {set;get;}
        public string SalesOrgCode {set;get;}
        public string SalesOrgName {set;get;}
        public string SalesDistiChannelCode {set;get;}
        public string SalesDistiChannelName {set;get;}
        public string Address {set;get;}
        public string AccountGroup {set;get;}
        public string DirectCustomerRoleName {set;get;}
        public string DirectCustomerRoleCode {set;get;}
        public Boolean IsPartOfGroup {set;get;}
        public boolean CentralBlock {set;get;}
        public DateTime CMFAddedToGroup {set;get;}
        public String CMFAddedToGroupBy {set;get;}
        public DateTime LastModifiedDate {set;get;}
        public DateTime CreatedDate {set;get;}
        public String LastModifiedBy {set;get;}
        public String CreatedBy {set;get;} 
        public boolean isActive {set;get;}
        
    }
   /* public class accountBPData{
        public String DirectAccountID {set;get;}
        public String CMFID {set;get;}
        public string Name {set;get;}
        public string SalesOrgCode {set;get;}
        public string SalesOrgName {set;get;}
        public string SalesDistiChannelCode {set;get;}
        public string SalesDistiChannelName {set;get;}
        public string Address {set;get;}
        public string AccountGroup {set;get;}
        public string DirectCustomerRoleName {set;get;}
        public string DirectCustomerRoleCode {set;get;}
        public DateTime LastModifiedDate {set;get;}
        public DateTime CreatedDate {set;get;}
        public String LastModifiedBy {set;get;}
        public String CreatedBy {set;get;} 
        public boolean isActive {set;get;}
    }*/
    public class ContactBasicInfoAE {
        public String FirstName {set;get;}
        public String LastName {set;get;}
        public String AccountName {set;get;}
        public String AccountId {set;get;}
        public String Email {set;get;}
        public String EnterpriseId {set;get;} 
        public DateTime LastModifiedDate {set;get;}
        public DateTime CreatedDate {set;get;}
        public String LastModifiedBy {set;get;}
        public String CreatedBy {set;get;} 
        public Boolean IsPartOfGroup {set;get;}
        public Boolean IsODMAccount {set;get;}
        public DateTime ContactAddedToCMF {set;get;}
        public String ContactAddedToCMFBy {set;get;}
        public String ContactCountryCode {set;get;}
        public String UCDID {set;get;}
    }
    
    
    /*public class ContactBasicProfile {
public ContactBasicInformation ContactBasicInformation {set;get;}
public List<ContactSubscription> ContactSubscriptions {set;get;}
public List<ContactEntitlement> ContactEntitlements {set;get;}
public List<AccountContactRelationship> AccountContactRelationships {set;get;}

//Updated for US604638 (As an IPA admin I would like Contact to Contact integration to be established for all core contact attributes that are synced from Sales cloud to service cloud.)
//public ContactAccountInformation AccountInformation {set; get;}
}*/
    public class ContactBusinessType{
        public String Name {set;get;}
        public String BusinessTypeCode {set;get;}  
        public String BusinessTypeCategory {set;get;}
        public Boolean IsActive {set;get;}
        public String Status {set;get;}
        public String StatusReason {set;get;}
        public Boolean PendingRegistration {set;get;}
    }
    public class AccountBusinessType{
        public String Name {set;get;}
        public String BusinessTypeCode {set;get;}  
        public Boolean IsActive {set;get;}
        public String Status {set;get;}
        public String StatusReason {set;get;}
        public DateTime LastModifiedDate {set;get;}
        public DateTime CreatedDate {set;get;}
        public String LastModifiedBy {set;get;}
        public String CreatedBy {set;get;}
        
    }
    public class ContactBasicInformation {
        public String FullName {set;get;}  
        public String FirstName {set;get;}
        public String LastName {set;get;}
        public String Title {set;get;}
        public String Segment {set;get;}
        public String PreferredLanguage {set;get;}
        public String PreferredCommunication {set;get;}
        public String Phone {set;get;}
        public String Fax {set;get;}
        public String Mobile {set;get;}
        public String Email {set;get;}
        public String PartnerRole {set;get;}
        public String PartnerRoleLabel {set;get;}
        Public String Region {set;get;}
        Public String SubRegion {set;get;}
        public String LoginId {set;get;}
        public String LocalFirstName {set;get;}
        public String LocalLastName {set;get;}
        public String EnglishFirstName {set;get;}
        public String EnglishLastName {set;get;}        
        public String JobFunction {set;get;}
        public String JobFunctionCode {set;get;}
        public String Profession {set;get;}
        public DateTime EmailVerificationDate {set;get;}        
        public String eRPMPersonId {set;get;}
        public String EnterpriseId {set;get;} 
        public String AccountName {set;get;}
        public boolean DNC {set;get;}
        public  String WeChatUnionId {set; get;}
        public String Communities {set;get;} // Rohit 
        //public  String RegistrationSource {set; get;}
        //-----------------------------We chat-----------------------------
        /*
public  String WechatOpenId {set; get;}
public  String WechatUnionId {set; get;}
public  String RegistrationSource {set; get;}
*/
        //-----------------------------We chat-----------------------------
        
        public Address MailingAddress {set;get;}        
    }
    public class ContactEntitlementAnE{
        public String Name {set;get;}
        public String Type {set;get;}
        public String Status {set;get;}
        public DateTime StatusChangeDateUtc {set;get;}
        public boolean IsSelected {set;get;}
        public DateTime LastModifiedDate {set;get;}
        public DateTime CreatedDate {set;get;}
        public String LastModifiedBy {set;get;}
        public String CreatedBy {set;get;}
        
    }
    public class address{
        public String Street {set;get;}
        public String City {set;get;}
        public String State {set;get;}
        public String StateCode {set;get;}
        public String Country {set;get;}
        public String CountryCode {set;get;}
        public String PostalCode {set;get;}
    }
}