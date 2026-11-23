public class PRM_SalesCloud_Integration_Model {
    
    Public class AccountPayload {
        //public List<String> observers {set;get;}
        public String AccountId {set;get;}
        public String CIMId {set;get;}
	public String UnifiedID {set; get;} //TWC729-6800 EOL activities
        public AccountInformation AccountInformation {set;get;}
        //public List<AccountContactRelationship> AccountContactRelationships {set;get;}
        public List<AccountSpecialityAssociation> AccountSpecialities {set;get;}
        public List<AccoutBenefitAssociation> AccoutBenefits {set;get;}
        public List<AccountChannelMembership> AccountChannelMemberships {set;get;}
        public List<OnePartnerIDGroupMember> OnePartnerIDGroupMembers {set;get;}     
        public List<AccountLegalAgreement> AccountLegalAgreements {set;get;} 
        public WarrantyBenefit WarrantyBenefits {set;get;}
        //public Warranty AWR {set;get;}
        public String MessageType {set;get;}
        public DateTime LastModifiedDate {set;get;}
        //TWC729-7183 : Adding Deactivated checkbox and Deactivation Reason to Service cloud payload
        public Boolean Deactivated {set;get;} 
        public String DeactivatedReason {set;get;}
    }
    
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
        public String PAGAccountId {set; get;}
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
    }
        
    public class AccountInformation {
        public String Name {set;get;}
        public String AccountNo {set;get;}
        public String PrimeAccountName {set;get;}
        public String SalesGroup {set;get;}
        public String Industry {set;get;}
        public boolean CoveredAccount {set;get;}
        public String CNDANumber {set;get;}
        public String BusinessPartnerId {set;get;}
        public String BusinessId {set;get;}
        public String BizOrgType {set;get;}
        public String PartnerRole {set;get;}
        public String PartnerRoleLabel {set;get;}
        public String Region {set;get;}
        public String SubRegion {set;get;}
        public String UserDefinedPhoneNumber {set;get;}
        public String UserDefinedWebsite {set;get;}        
        public String EnglishNameOnly {set;get;}        
        public String PartnerProgramSegment {set;get;}
        public String PartnerProgramSpecialty {set;get;}     
        public String AccountLegalName {set;get;}
        public String AccountBUFocus {set;get;}
        public RecordOwner AccountOwner {set;get;}       
        public String RecordType {set;get;}     
        public boolean IsIPA {set;get;}
        public AccountAddress Address {set; get;}
        public String PAGAccountId {set; get;}
        public String BadgeTier {set; get;}
        public String BadgeTierLabel {set; get;}
        public List<WhitelistedDomain> WhiteListedDomains {set;get;}
        public List<PartnerAssist> PartnerAssist {set;get;}
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
   /* public class AccountERPMEngagement{        
        public  string AccountName {set;get;}
        public  String EngagementName {set;get;}
        public  String EngagementCode {set;get;}
        public  String Tier {set;get;}
        public  String SalesCloudId {set;get;}
        public  String EngagementId {set;get;}
    }*/  
    public class AccountLegalAgreement{        
        public String LeagalAgreementName {set;get;}
        public DateTime AgreementSignedDate {set;get;}
        public String AgreementSignedBy {set;get;}      
        public boolean IsInActive {set;get;}
        public String PartnerAgreementName {set;get;}
        public String PartnerAgreementCode {set;get;}
        public String PartnerProgramName {set;get;}        
    }  
   /** public class AccountSpecialityAssociation {        
        public String Name {set;get;}      
        public boolean IsInactive {set;get;}       
        public String SpecialityName {set;get;}
        public String SpecialityRole {set;get;}
        public String SpecialityTier {set;get;}    
        public String SpecialityId {set;get;}
        public String SalesCloudId {set;get;}
        public Date StartDateUtc {set;get;}
    }**/
    
    public class AccountSpecialityAssociation {        
        public String Name {set;get;}      
        public boolean IsInactive {set;get;}       
        public String SpecialityName {set;get;}
        public String SpecialityRole {set;get;}
        public String SpecialityTier {set;get;}
        public String SpecialityType {set;get;}
        public Date StartDateUtc {set;get;}
    }
    
    public class AccountChannelMembership {        
        public String PartnerProgramName {set;get;}
        public String PartnerProgramCode {set;get;}
        public String PartnerTier {set;get;}
        public String PartnerTierLabel  {set;get;}
        public String PartnerRole {set;get;}
        public String PartnerRoleLabel {set;get;}
        public String Status {set;get;}
        
        //ACM id
        //public String AccountChannelMembershipId {set;get;}
        //Updated for US612331 (As an IPA admin I would like Contact to Contact integration to be established for all related contact attributes that are synced from Sales cloud to service cloud.)
        public DateTime StatusChangeDateUtc {set;get;}
        //Updated for US612331 (As an IPA admin I would like Contact to Contact integration to be established for all related contact attributes that are synced from Sales cloud to service cloud.)
    }
    public class AccoutBenefitAssociation {        
        public String BenefitName {set;get;}
        public String BenefitCode {set;get;}
        public String BenefitType {set;get;}
        public String PartnerProgamName {set;get;}
        public String PartnerProgamCode {set;get;}
        public String Status {set;get;}
    }   
    
    /*public class OnePartnerIDGroupMember {
        public String OnePartnerGroupMemberName {set;get;}        
        public String IntelAccountName {set;get;}       
        public String OnePartnerAccountName {set;get;}
        public boolean IsInactive {set;get;}
        public String CIMId {set;get;}
    } */
    
    public class OnePartnerIDGroupMember {
        public String AccountId {set;get;}
        public boolean IsInactive {set;get;}
        public String CIMId {set;get;}
	public String UnifiedID {set; get;} //TWC729-6800 EOL activities
        public boolean IsIPA {set;get;}
    } 
    
    public class ContactPayload {
        public String ContactId {set;get;}
        public String AccountId {set;get;}
        //public ContactBasicProfile ContactBasicProfile {set;get;}
        public ContactBasicInformation ContactBasicInformation {set;get;}
        public List<ContactSubscription> ContactSubscriptions {set;get;}
        public List<ContactEntitlement> ContactEntitlements {set;get;}
        public List<AccountContactRelationship> AccountContactRelationships {set;get;}
        public String MessageType {set;get;} 
        public String CIMID {set; get;}
        public String UnifiedID {set; get;} //TWC729-6800 EOL activities
        public DateTime LastModifiedDate {set;get;}
        public String AccountNum {set;get;}
    }
    
    public class AccountAEPayload{
        public String MessageType {set;get;} 
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
        //public ContactBasicProfile ContactBasicProfile {set;get;}
        public AccountBasicInformation AccountBasicInformation {set;get;}
        public ContactBasicInformation ContactBasicInformation {set;get;}
        //public List<ContactSubscription> ContactSubscriptions {set;get;}
        public List<ContactEntitlementAnE> ContactEntitlements {set;get;}
        //public List<AccountContactRelationship> AccountContactRelationships {set;get;}
        public List<ContactBusinessType> ContactBusinessTypes {set;get;}
        public String MessageType {set;get;} 
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
        
    }
    
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
        public String ExternalUserState {set;get;}
        public String ExternalUserStateChangeDtTime {set;get;}
        public DateTime IntelLastLoginDate {set;get;}
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
     public class ContactSubscription{
        public String Name {set;get;}
        public String Status {set;get;}
        public String Code {set;get;}        
    }
    public class ContactEntitlement{
        public String Name {set;get;}
        public String Type {set;get;}
        public String Status {set;get;}
        public DateTime StatusChangeDateUtc {set;get;}
        public boolean IsSelected {set;get;}
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
    public class AccountContactRelationship{ 
        public String Status {set; get;}
        public String Relationship {set;get;}
        //public String AccountName {set;get;}
        public String PartnerRole {set;get;}
    public String PartnerRoleLabel {set;get;}        
        public boolean InactiveIndicator {set;get;}
        //public ACRContact ContactInfo  {set;get;}
    }
    /*
    public class ACRContact {
        public String Email {set;get;}
        public String Firstname {set;get;}
        public String LastName {set;get;}
        public String LoginId {set;get;}
        public String EnterpriseId {set;get;}
        public ACRContact(String Email, String Firstname, String LastName, String LoginId, String EnterpriseId){
            this.Email = Email;
            this.Firstname = Firstname;
            this.LastName = LastName;
            this.LoginId = LoginId;
            this.EnterpriseId = EnterpriseId;
        }
    }*/
    public class address{
        public String Street {set;get;}
        public String City {set;get;}
        public String State {set;get;}
        public String StateCode {set;get;}
        public String Country {set;get;}
        public String CountryCode {set;get;}
        public String PostalCode {set;get;}
    }
    
    /*
    public class WarrantyBenefit {
        public String BenefitName {set;get;}
        public String BenefitCode {set;get;}
        public String PartnerRole {set;get;}
        public String PartnerTier {set;get;}
        public Integer Quantity {set;get;}
        //public String StartDate {set;get;}
        public String Status {set;get;}
    }
    */
    public class WarrantyBenefit {
        public Integer AWRQuantity {set;get;}
        public Integer SWRQuantity {set;get;}
        public Integer SLAHours {set;get;}
    }
    
    public class WarrantyOld {
        public String STDWRTY {set;get;}
        public String ADVDWRTY {set;get;}
        public WarrantyOld(String STDWRTY, String ADVDWRTY ){
            this.STDWRTY = STDWRTY;
            this.ADVDWRTY = ADVDWRTY;
        }
    } 
    
    //Updated for US612331 (As an IPA admin I would like Contact to Contact integration to be established for all related contact attributes that are synced from Sales cloud to service cloud.)
   /* public class ContactAccountInformation{
        public String SalesGroup {set;get;}
        public String Name {set;get;}
        public String Industry {set;get;}
        public String BizOrgType {set;get;}
        public String PartnerRole {set;get;}
        public ContactAccountAddress Address {set; get;}
    } */
   /* public class ContactAccountAddress {
        public Address PrimaryAddress {set;get;}
    } */
    //Updated for US612331 (As an IPA admin I would like Contact to Contact integration to be established for all related contact attributes that are synced from Sales cloud to service cloud.)
    public class WhitelistedDomain {
        public string DomainName {set;get;}
        public string PartnerProgramName {set;get;}
        public DateTime EndDate {set;get;}
        public boolean IsInactive {set;get;}
    }
    public class PartnerAssist {
        public String DistributorName {set;get;}
        public String choice {set;get;}
        public String ConsentProvidedBy {set;get;} 
        public DateTime ConsentProvidedDate {set;get;}
        public DateTime StartDate {set;get;}
        public DateTime EndDate {set;get;}
        public boolean ConsentProvidedIndicator {set;get;}
    }
}