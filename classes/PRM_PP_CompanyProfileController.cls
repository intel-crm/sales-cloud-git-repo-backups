public without sharing class PRM_PP_CompanyProfileController {

  public static boolean IPARefresh = Boolean.valueOf(label.PRM_IPARefresh);

  @AuraEnabled(cacheable = true)
  public Static String getCompanyAndRoleInfo(){
    CompanyInfoAndRoleDescWrapper compnyInfo = new CompanyInfoAndRoleDescWrapper();
        String loggedInUserName = UserInfo.getUserName();
        User loggedInUser = [SELECT ContactId From User WHERE Id= :UserInfo.getUserId()];
    if(!String.isEmpty(loggedInUser.ContactId)) {          
            Contact cont = [SELECT id,Name,AccountId,Core_IPA_Partner_Role__c,Core_Preferred_Language__c,
                            (SELECT Id,PRM_Relationship_Id__r.Name,PRM_Account_Id__r.Id FROM Account_Contact_Relationships__r)
                            FROM Contact WHERE Id= :loggedInUser.ContactId];
            
            if(cont!=null) {
        Account acct = [SELECT id,Name,Core_User_Defined_Website__c,Core_CNDA_Number__c,Core_User_Defined_Phone_Number__c,Core_IPA_Partner_Role__c,
                        BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode,
                        ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingPostalCode,
                        (SELECT PRM_Specialty_Id__r.Name,PRM_Specialty_Type__c FROM Account_Specialty_Associations__r WHERE PRM_InActive_Ind__c=false),
                        (SELECT Core_Partner_Account_Id__r.Name FROM Partner_Account_Group_Members1__r WHERE Core_Inactive_Ind__c=false LIMIT 1)
                        FROM Account WHERE Id= : cont.AccountId];
                if(cont.Account_Contact_Relationships__r.size() > 0) {
                    List<String> partnerRoles = new List<String>();
                    if(!String.isEmpty(cont.Core_IPA_Partner_Role__c)) {
                        partnerRoles = cont.Core_IPA_Partner_Role__c.split(';');
                    }
                    boolean isPrimary = false;
                    for(PRM_Account_Contact_Relationship__c acr: cont.Account_Contact_Relationships__r) {
                        if(acr.PRM_Relationship_Id__r.Name == System.label.PRM_Primary_Contact || acr.PRM_Relationship_Id__r.Name == System.label.PRM_Partner_Admin_Delegate && acr.PRM_Account_Id__r.Id == cont.AccountId){
                            //compnyInfo.CompanyInfo = getCompanyInfo(acct, true, partnerRoles[0]);
                            isPrimary = true;
                            break;
                        }
                    }
                    /*if(!isPrimary){
                        //compnyInfo.CompanyInfo = getCompanyInfo(acct, false, partnerRoles[0]);
                    }*/
                    compnyInfo.CompanyInfo = getCompanyInfo(acct, isPrimary, partnerRoles[0]);
              }
        if(!String.isEmpty(cont.Core_IPA_Partner_Role__c)) {
          String language = String.isEmpty(cont.Core_Preferred_Language__c) ? 'ENG' : cont.Core_Preferred_Language__c;
          List<String> partnerRoles = cont.Core_IPA_Partner_Role__c.split(';');
          compnyInfo.RoleDescriptions = getRoleDescriptions(language, partnerRoles);
          compnyInfo.CompanyInfo.ProfileResponses = getProfileResponses(acct.Id);
          system.debug('ProfileResponses ===>'+compnyInfo.CompanyInfo.ProfileResponses);
        }
      }
    }
        system.debug('company role info'+compnyInfo);
        system.debug('company relo info JSON'+ JSON.serialize(compnyInfo));
    return JSON.serialize(compnyInfo);
  }
    
  @AuraEnabled(cacheable = true)
  public static String getMyCompanySecondaryContacts(){
    //CompanyInfoAndRoleDescWrapper compnyAndRoleInfo = new CompanyInfoAndRoleDescWrapper();
    SecondaryContacts scs = new SecondaryContacts();
    User loggedInUser = [SELECT ContactId,Contact.AccountId,Contact.Core_IPA_Partner_Role__c FROM User WHERE Id= :UserInfo.getUserId()];
    if(!String.isEmpty(loggedInUser.ContactId) && !String.isEmpty(loggedInUser.Contact.Core_IPA_Partner_Role__c)) {
      //Contact cont = [SELECT id,Name,AccountId,Account.Name,Core_IPA_Partner_Role__c FROM Contact WHERE Core_Login_Id__c= 'megatronic.bates@yhwjncdcik.com'];
      //system.debug('Account Name ==>'+cont.Account.Name);
      //system.debug('Account Id ==>'+cont.AccountId);
      //if(cont!=null && !String.isEmpty(cont.Core_IPA_Partner_Role__c)) {
        //List<PRM_Registration_Request__c> regReqs
        scs.RegRequests = getPendingSecondaryContactRequests(loggedInUser.Contact.AccountId, loggedInUser.Contact.Core_IPA_Partner_Role__c.split(';'));
        //scs.Contacts = getPendingSecondaryContacts(cont.AccountId, cont.Core_IPA_Partner_Role__c.split(';'), cont.Id);
        system.debug('RegRequests ==>'+ scs );
      //}
    }
    return JSON.serialize(scs.RegRequests);
  }

    @AuraEnabled(cacheable = true)
    public static string getMyCompanyContacts() {
        User loggedInUser = [SELECT ContactId FROM User WHERE Id= :UserInfo.getUserId()];
        List<SecondaryContactWrapper> contacts = new List<SecondaryContactWrapper>();
        if(!String.isEmpty(loggedInUser.ContactId)) {
            Contact cont = [SELECT id,Name,AccountId,Account.Name,Core_IPA_Partner_Role__c,
                            (SELECT Id,PRM_Relationship_Id__r.Name,PRM_Account_Id__r.Id FROM Account_Contact_Relationships__r)
                            FROM Contact WHERE Id= :loggedInUser.ContactId];
            system.debug('Account Name ==>'+cont.Account.Name);
            system.debug('Account Id ==>'+cont.AccountId);
            if(cont!=null && !String.isEmpty(cont.Core_IPA_Partner_Role__c)) {
                for(Contact con : [Select id,Name,Email,Core_IPA_Partner_Role__c,Phone,
                                   (SELECT Id,Core_Entitlement_Id__r.Name FROM Contact_Entitlements__r WHERE Core_Selected__c=True),
                                   (SELECT Id, PRM_Status_Nm__c, PRM_Relationship_Id__r.Name,PRM_Account_Id__r.Id FROM Account_Contact_Relationships__r 
                                   WHERE PRM_InActive_Ind__c=false)
                                   FROM Contact WHERE AccountId= :cont.AccountId AND
                                    Core_IPA_Partner_Role__c in: cont.Core_IPA_Partner_Role__c.split(';')])
                {
                    system.debug('con list - '+con.Name);
                    SecondaryContactWrapper acctContact = new SecondaryContactWrapper();
                    Boolean isPrimary = false;
                    acctContact.RecordId = con.Id;
                    acctContact.Name = con.Id == cont.Id ? con.Name+ ' (You)':con.Name;
                    acctContact.Phone = con.Phone;
                    acctContact.Status = con.Account_Contact_Relationships__r[0].PRM_Status_Nm__c;
                    acctContact.isLoggedinUser = con.Id == cont.Id ? true : false;
                    for(PRM_Account_Contact_Relationship__c acr : con.Account_Contact_Relationships__r) {
                        if(acr.PRM_Account_Id__r.Id == cont.AccountId && !isPrimary) {
                            isPrimary = (acr.PRM_Relationship_Id__r.Name == 'Partner Admin' || acr.PRM_Relationship_Id__r.Name == 'Partner Admin Delegate')
              ? true : false;  
                        }
                    }
                    acctContact.isPrimary = isPrimary;
                    Set<String> responsibilities = new Set<String>();
                    for(Core_Contact_Entitlement__c ce: con.Contact_Entitlements__r) {
                        responsibilities.add(ce.Core_Entitlement_Id__r.Name);
                    }
                    acctContact.Responsibilities = responsibilities;
                    contacts.add(acctContact);
                }
            }
        }
        //system.debug(JSON.serialize(contacts));
        return JSON.serialize(contacts);
    }
    @AuraEnabled(cacheable = true)
  public static String getMyCompanyLegalAgreemnent(){
        List<LegalAgreementWrapper> legalResponse= new List<LegalAgreementWrapper>();
        User loggedInUser = [SELECT ContactId, Contact.AccountId FROM User WHERE Id= :UserInfo.getUserId()];
    if(!String.isEmpty(loggedInUser.ContactId)) {
            //Contact cont = [SELECT id,Name,AccountId,Account.Name,Core_IPA_Partner_Role__c FROM Contact WHERE Core_Login_Id__c= 'megatronic.bates@yhwjncdcik.com'];
            //if(cont!=null) {
                legalResponse=getComapanyLegalAgreementDetails(loggedInUser.Contact.AccountId);
            //}
        }
        return JSON.serialize(legalResponse);
    }
    

  private Static List<SecondaryContactWrapper> getPendingSecondaryContacts(Id AccountId, List<String> partnerRoles, Id ContactId){
    Set<String> contactEmails = new Set<String>();
    Set<String> regReqEmails =  new Set<String>();
    List<SecondaryContactWrapper> Contacts = new List<SecondaryContactWrapper>();
    Map<String,PRM_Registration_Request__c> emailRegReqMap = new Map<String,PRM_Registration_Request__c>();
    List<Contact> lstContacts = [Select id,Name,Email,Core_IPA_Partner_Role__c,Phone,
                                 (SELECT Id,Core_Entitlement_Id__r.Name FROM Contact_Entitlements__r WHERE Core_Selected__c=True),
                                 (SELECT Id FROM Account_Contact_Relationships__r WHERE PRM_InActive_Ind__c=false AND PRM_Status_Nm__c='Pending Action')
                                 FROM Contact WHERE AccountId= :AccountId AND Id!= :ContactId AND Core_IPA_Partner_Role__c!=null];
    system.debug('Contacts ==>'+lstContacts);
    for(Contact cont: lstContacts) {
      contactEmails.add(cont.Email);
    }
    system.debug('contactEmails ==>'+contactEmails);
    if(contactEmails.size() > 0) {
      Id AccountCreateRT = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get('Account_Create_Request').getRecordTypeId();
      Id AdminRegistrationRT = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get('Admin_Registration').getRecordTypeId();
      for(PRM_Registration_Request__c regReq : [SELECT PRM_Partner_Role__c,PRM_Email_ID__c,PRM_Status__c FROM PRM_Registration_Request__c WHERE
                                                    (RecordTypeId= :AccountCreateRT OR RecordTypeId= :AdminRegistrationRT)
                                                AND PRM_Partner_Role__c IN :partnerRoles AND PRM_Salesforce_ID__c!=null AND PRM_Email_ID__c IN :contactEmails]) {
        regReqEmails.add(regReq.PRM_Email_ID__c);
        if(regReq.PRM_Status__c=='Approved') {
          emailRegReqMap.put(regReq.PRM_Email_ID__c+'~~'+regReq.PRM_Email_ID__c, regReq);
        }
      }
    }
    system.debug('regReqEmails ==>'+regReqEmails);
    system.debug('emailRegReqMap ===>'+emailRegReqMap);

    for(Contact cont: lstContacts) {      
      List<String> contPartnerRoles = cont.Core_IPA_Partner_Role__c.split(';');
      for(String contPartnerRole : contPartnerRoles) {      
        if(partnerRoles.contains(contPartnerRole) && (!regReqEmails.contains(cont.Email) || emailRegReqMap.containsKey(cont.Email+'~~'+contPartnerRole) )) {          
          SecondaryContactWrapper acctContact = new SecondaryContactWrapper();
          acctContact.RecordId = cont.Id;
          acctContact.Name = cont.Name;
          acctContact.Phone = cont.Phone;
          acctContact.Status = cont.Account_Contact_Relationships__r.size() > 0 ? 'Pending' : 'Approved';
          Set<String> responsibilities = new Set<String>();
          for(Core_Contact_Entitlement__c ce: cont.Contact_Entitlements__r) {
            responsibilities.add(ce.Core_Entitlement_Id__r.Name);
          }
          acctContact.Responsibilities = responsibilities;
          Contacts.add(acctContact);
          break;
        }
      }
    }
    system.debug('Contacts Wrapper ==>'+Contacts);
    return Contacts;
  }
  private Static List<SecondaryContactWrapper> getPendingSecondaryContactRequests(Id sfAccountId, List<String> partnerRoles){
    //Account_Create_Request
    //PRM_Account_Phone__c, PRM_Partner_Role__c, PRM_Partner_Relationship__c
    List<SecondaryContactWrapper> regRequests = new List<SecondaryContactWrapper>();
    Id AccountCreateRT = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get('Account_Create_Request').getRecordTypeId();
    Id AdminRegistrationRT = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get('Admin_Registration').getRecordTypeId();
        for(PRM_Registration_Request__c regReq : [SELECT id,PRM_Person_Phone_Number__c,PRM_First_Name__c,PRM_Last_Name__c,PRM_Partner_Relationship__c,PRM_Email_ID__c,Email_Verification_Status__c,PRM_EmailVerifiedDateTime__c FROM PRM_Registration_Request__c WHERE 
          PRM_Status__c='New'
        AND (RecordTypeId= :AccountCreateRT OR RecordTypeId= :AdminRegistrationRT)
          AND PRM_Partner_Role__c IN :partnerRoles AND PRM_Salesforce_ID__c=:sfAccountId Order By PRM_First_Name__c ASC ]) {
      SecondaryContactWrapper RegRequest = new SecondaryContactWrapper();
      RegRequest.RecordId = regReq.Id;
            RegRequest.Name = regReq.PRM_First_Name__c+' '+regReq.PRM_Last_Name__c;
            RegRequest.Email=regReq.PRM_Email_ID__c;
      RegRequest.Phone = regReq.PRM_Person_Phone_Number__c;
            RegRequest.EVStatus = regReq.Email_Verification_Status__c=='SUCCESS'?'Verified':'Not Verified';
            RegRequest.Relationship=regReq.PRM_Partner_Relationship__c.Replace(';',',');
            RegRequest.EVVerificationDateTime=regReq.PRM_EmailVerifiedDateTime__c;
      regRequests.add(RegRequest);
    }
    return regRequests;
  }
  public static CompanyInfoWrapper getCompanyInfo(Account acct, boolean acctContRelNameFlag, String role){
        CompanyInfoWrapper CompanyInfo = new CompanyInfoWrapper();
        CompanyInfo.Name = acct.Name != null ? acct.Name : '';
        CompanyInfo.NaturalGrouping = (acct.Partner_Account_Group_Members1__r.size()>0) ? acct.Partner_Account_Group_Members1__r[0].Core_Partner_Account_Id__r.Name : '';
        CompanyInfo.Website = acct.Core_User_Defined_Website__c != null ? acct.Core_User_Defined_Website__c : '';
        CompanyInfo.Phone = acct.Core_User_Defined_Phone_Number__c != null ? acct.Core_User_Defined_Phone_Number__c : '';
        CompanyInfo.NDA = acct.Core_CNDA_Number__c != null ? acct.Core_CNDA_Number__c : '';
        CompanyInfo.MailingAddress = getMailingAddress(acct);
        CompanyInfo.PhysicalAddress = getPhysicalAddress(acct);
        CompanyInfo.isPrimary = acctContRelNameFlag;
        CompanyInfo.AccountId = acct.Id;
        CompanyInfo.Specialties = new Set<String>();
        CompanyInfo.SelectBenefits = new Set<String>();
        CompanyInfo.PartnerRole = role;
        for(PRM_Account_Specialty_Association__c asa : acct.Account_Specialty_Associations__r) {
            if(asa.PRM_Specialty_Type__c == 'Specialty') {
                CompanyInfo.Specialties.add(asa.PRM_Specialty_Id__r.Name);
            }else if(asa.PRM_Specialty_Type__c == 'Select Benefits') {
                CompanyInfo.SelectBenefits.add(asa.PRM_Specialty_Id__r.Name); 
                
            }
        }
        CompanyInfo.WhitelistedDomains = getWhitelistedDomains(acct.Id);
        
        return CompanyInfo;
    }
  private Static Address getMailingAddress(Account acct){
    Address MailingAdress = new Address();
    boolean isAddressEmpty = false;
    isAddressEmpty = (String.isEmpty(acct.BillingStreet) && String.isEmpty(acct.Billingcity)
                      && String.isEmpty(acct.BillingState) && String.isEmpty(acct.BillingCountry)
                      && String.isEmpty(acct.BillingPostalCode) ) ? true : false;
    if(!isAddressEmpty) {
      MailingAdress.Street = acct.BillingStreet;
      MailingAdress.City = acct.Billingcity;
      MailingAdress.State = acct.BillingState;
      MailingAdress.Country = acct.BillingCountry;
      MailingAdress.PostalCode = acct.BillingPostalCode;
      return MailingAdress;
    }else{
      return MailingAdress;
    }
  }
  private Static Address getPhysicalAddress(Account acct){
    boolean isAddressEmpty = false;
    Address PhysicalAdress = new Address();
    isAddressEmpty = (String.isEmpty(acct.ShippingStreet) && String.isEmpty(acct.Shippingcity) && String.isEmpty(acct.ShippingState) && String.isEmpty(acct.ShippingCountry) && String.isEmpty(acct.ShippingPostalCode) ) ? true : false;
    if(!isAddressEmpty) {
      PhysicalAdress.Street = acct.ShippingStreet;
      PhysicalAdress.City = acct.Shippingcity;
      PhysicalAdress.State = acct.ShippingState;
      PhysicalAdress.Country = acct.ShippingCountry;
      PhysicalAdress.PostalCode = acct.ShippingPostalCode;
      return PhysicalAdress;
    }else{
      return PhysicalAdress;
    }
  }
  private static List<RoleDescription> getRoleDescriptions(String language, List<String> partnerRoles){
    List<RoleDescription> roleDescs = new List<RoleDescription>();
    for(PRM_Role_Descriptions__mdt roleDescription : [SELECT Partner_Role__c,PRM_ShortDescription__c,PRM_Description__c,PRM_Support_URL__c FROM PRM_Role_Descriptions__mdt WHERE PRM_Language_Code__c= :language AND Partner_Role__c IN :partnerRoles]) {
      RoleDescription roleDesc = new RoleDescription();
      roleDesc.PartnerRole = roleDescription.Partner_Role__c != null ? roleDescription.Partner_Role__c : '';
      roleDesc.ShortDesc = roleDescription.PRM_ShortDescription__c != null ? roleDescription.PRM_ShortDescription__c : '';
      if(roleDescription.PRM_Description__c.split('<EOL>').size() > 0) {
        roleDesc.DescriptionItems = roleDescription.PRM_Description__c.split('<EOL>');
      }
      roleDesc.SupportURL = roleDescription.PRM_Support_URL__c != null ? roleDescription.PRM_Support_URL__c : '';
      roleDescs.add(roleDesc);
    }
    return roleDescs;
  }
  private static List<ProfileResponse> getProfileResponses(Id recordId){
        
        String channelProg = 'Intel Partner Alliance';
        String objectName = 'Account';
        String questionCode = 'PRM_AcceptableDomain';
        List<String> channelProgramNames = new List<String>();
        Set<Id> channelProgId = new Set<Id>();
        
        if(channelProg != null) {
            channelProgramNames = channelProg.split(',');
        }    
        List<ProfileResponse> ProfileResponses = new List<ProfileResponse>();
        for(PRM_Profile_Responses__c response: [SELECT Id,PRM_Profile_Questions_Id__r.PRM_Question_Display_Txt__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,PRM_Response_Txt__c 
                                                FROM PRM_Profile_Responses__c 
                                                WHERE PRM_InActive_Ind__c=false AND PRM_Account_Id__c =: recordId
                                                //AND PRM_Profile_Questions_Id__r.PRM_Question_Cd__c =: questionCode
                                                AND PRM_Profile_Questions_Id__r.PRM_Channel_Program_Id__r.Name in: channelProgramNames
                                               ]) {
                                                   ProfileResponse resp = new ProfileResponse();
                                                   resp.RecordId = response.Id;                  
                                                   resp.QuestionText = response.PRM_Profile_Questions_Id__r.PRM_Question_Display_Txt__c;
                                                   resp.QuestionCode = response.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c;
                                                   resp.ResponseText = response.PRM_Response_Txt__c;
                                                   ProfileResponses.add(resp);
                                                   
                                               }
        return ProfileResponses;
    }
    
    private Static List<LegalAgreementWrapper> getComapanyLegalAgreementDetails(Id AccountId){
        List<LegalAgreementWrapper> lglAgreementList=new List<LegalAgreementWrapper>();
        List<PRM_AccountLegalAgreemntAssociation__c> LegalArgmnt = new List<PRM_AccountLegalAgreemntAssociation__c>();
        // IPA 2.0 - TWC729-7874
        LegalArgmnt = [SELECT Id,PRM_InActive_Ind__c,PRM_Agreement_Sign_Dt__c, PRM_Signed_By_Name__c,PRM_Signed_By_Email__c, PRM_Partner_Agreement_Id__r.Name from PRM_AccountLegalAgreemntAssociation__c where PRM_Account_Id__r.Id=:AccountId AND PRM_InActive_Ind__c = false];
        for(PRM_AccountLegalAgreemntAssociation__c agreement:LegalArgmnt)
        {
            LegalAgreementWrapper lglAgreement=new LegalAgreementWrapper();
            lglAgreement.LegalAgreementName=agreement.PRM_Partner_Agreement_Id__r.Name;
            // IPA 2.0 - TWC729-7874
            lglAgreement.LegalAgreementSignedBy=agreement.PRM_Signed_By_Name__c;
            ////IPA 2.0 - TWC729-7874-end
            lglAgreement.LegalAgreementSignedDate=agreement.PRM_Agreement_Sign_Dt__c;
            lglAgreement.RecordId=agreement.Id;
            lglAgreementList.add(lglAgreement);
        }
        return lglAgreementList;
    }
    
    @AuraEnabled
    public static boolean updateAccountInfo(String accountId, String website, String phone) {
        Account acct = [Select Id, Core_User_Defined_Website__c, Core_User_Defined_Phone_Number__c from Account where Id =: accountId];
        system.debug(accountId+'-------'+website+'-------'+phone);
        if(acct != null) {
            acct.Core_User_Defined_Website__c = website;
            acct.Core_User_Defined_Phone_Number__c = phone;
            update acct;
            return true;
        }
        return false;
    }
    
    @AuraEnabled
    public static boolean saveWhitelistedDomains(String AcctId, String whitelistedDomains){
        try {
            String answerCode = 'PRM_AcceptableDomainAns';
            PRM_Profile_Answer__c profileAnswer = [Select id,PRM_Profile_Questions_Id__c FROM PRM_Profile_Answer__c WHERE PRM_Answer_Cd__c=:answerCode];
            if(profileAnswer!=null){
                PRM_Profile_Responses__c response = [SELECT id,PRM_Response_Txt__c FROM PRM_Profile_Responses__c WHERE PRM_Profile_Questions_Id__r.PRM_Question_Cd__c=:profileAnswer.PRM_Profile_Questions_Id__c AND PRM_Profile_Answer_Id__c= :Id.valueOf(AcctId)];
                //Account acct = [Select id,(SELECT id,PRM_Response_Txt__c FROM Profile_Responses__r WHERE PRM_Profile_Questions_Id__r.PRM_Question_Cd__c=:profileAnswer.PRM_Profile_Questions_Id__c) FROM Account WHERE id= :AcctId];
                if(response!=null) {
                    //PRM_Profile_Responses__c
                    response.PRM_Response_Txt__c = whitelistedDomains;
                    update response;
                }else {
                    PRM_Profile_Responses__c profileResponse = new PRM_Profile_Responses__c();
                    profileResponse.PRM_Account_Id__c = Id.valueOf(AcctId);
                    profileResponse.PRM_Profile_Answer_Id__c = profileAnswer.Id;
                    profileResponse.PRM_Profile_Questions_Id__c = profileAnswer.PRM_Profile_Questions_Id__c;
                    profileResponse.PRM_Response_Txt__c = whitelistedDomains;
                    insert profileResponse;
                } 
            }            
            return true;
        }catch(Exception ex){
            system.debug('Error Cause==>'+ex.getCause());
            system.debug('Error Message==>'+ex.getMessage());
            system.debug('Error StackTrace String==>'+ex.getStackTraceString());
            return false;
        }      
    }
    private static String getWhitelistedDomains(Id AcctId){       
        String answerCode = 'PRM_AcceptableDomainAns';
        PRM_Profile_Answer__c profileAnswer = [Select id,PRM_Profile_Questions_Id__c FROM PRM_Profile_Answer__c WHERE PRM_Answer_Cd__c=:answerCode];
        system.debug('profileAnswer-Silam     : ' + profileAnswer.PRM_Profile_Questions_Id__c);
        if(profileAnswer!=null){
            system.debug('profileAnswer-Silam    Inside If Condition  : ' + profileAnswer.Id);
            try {
                PRM_Profile_Responses__c resp = [SELECT id,PRM_Response_Txt__c FROM PRM_Profile_Responses__c WHERE PRM_Profile_Questions_Id__r.PRM_Question_Cd__c=:profileAnswer.PRM_Profile_Questions_Id__c AND PRM_Profile_Answer_Id__c= :AcctId];
                system.debug('response-Silam' + resp);
                return ((resp!=null) ? resp.PRM_Response_Txt__c : '');
            }
            catch(Exception ex){
                system.debug('Error Cause==>'+ex.getCause());
                system.debug('Error Message==>'+ex.getMessage());
                system.debug('Error StackTrace String==>'+ex.getStackTraceString());
            }            
        }
        return '';
    }
    
    
  public class CompanyInfoAndRoleDescWrapper {
    public CompanyInfoWrapper CompanyInfo {set; get;}
    public List<RoleDescription> RoleDescriptions {set; get;}
  }
  public class CompanyInfoWrapper {
        public String Name {set; get;}
        public String NaturalGrouping {set; get;}
        public String Website {set; get;}
        public String Phone {set; get;}
        public String NDA {set; get;}
        public String AccountId {set; get;}
        public String PartnerRole {set; get;}
        public boolean isPrimary {set; get;}
        public Address MailingAddress {set; get;}
        public Address PhysicalAddress {set; get;}
        public Set<String> Specialties {set; get;}
        public Set<String> SelectBenefits {set; get;}
        public List<ProfileResponse> ProfileResponses {set; get;}
        public String WhitelistedDomains {set; get;}        
    }
  public class ProfileResponse {
        public String RecordId {set; get;}
        public String QuestionText {set; get;}
        public String QuestionCode {set; get;}
        public String ResponseText {set; get;}
    }
  public class Address {
    public String Street {set; get;}
    public String City {set; get;}
    public String State {set; get;}
    public String Country {set; get;}
    public String PostalCode {set; get;}
  }
  public class RoleDescription {
    public String PartnerRole {set; get;}
    public String ShortDesc {set; get;}
    public List<String> DescriptionItems {set; get;}
    public String SupportURL {set; get;}
  }
  public class SecondaryContacts {
    public List<SecondaryContactWrapper> RegRequests {set; get;}
    public List<SecondaryContactWrapper> Contacts {set; get;}
  }
  public class SecondaryContactWrapper {
    public Id RecordId {set; get;}
        public String Name {set; get;}
        public String Email{get;set;}
    public String Phone {set; get;}
    public Set<String> Responsibilities {set; get;}
        public String Status {set; get;}
        public String EVStatus {set; get;}
        public Datetime EVVerificationDateTime {set; get;}
        public Boolean isLoggedinUser  {set; get;}
        public Boolean isPrimary {set; get;}
        public String Relationship {set; get;}
    }
    
    public class LegalAgreementWrapper {
    public Id RecordId {set; get;}
        public String LegalAgreementName {set; get;}
        public String LegalAgreementSignedBy{get;set;}
    public Datetime LegalAgreementSignedDate {set; get;}
    
  }

}