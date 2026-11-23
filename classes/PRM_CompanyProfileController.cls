public without sharing class PRM_CompanyProfileController {
    //-------------------Approve & Reject------------------------------
    public static final String STR_APPROVE = 'Approve';
    public static final String STR_REJECT = 'Reject';
    public static final String STR_APPROVE_SUCCESS = 'Approved Successfully';
    public static final String STR_REJECT_SUCCESS = 'Rejected Successfully';
    public static final String STR_APPROVED = 'Approved';
    public static final String STR_REJECTED = 'Rejected';
    public static String USER_NAME = '11553183@intel.com.crm.devipa';
    public static String CONTACT_ID = '';    
    
    //-------------------Approve & Reject------------------------------
    
    //public static boolean IPARefresh = Boolean.valueOf(label.PRM_IPARefresh);
    //-------------------Log Entry detail---------------------
    public static Final String ORIGIN  = 'PRM_CompanyProfileController';
    public static Final String SEVERITY  = 'Info';
    public static Final String PROJECT  = 'IPA';
	public static Final String SCOPE  = 'Exception Handling analysis';
    
    @AuraEnabled(cacheable=true)
    public static String getCompanyAndRoleInfo() {
        CompanyInfoAndRoleDescWrapper compnyInfo = new CompanyInfoAndRoleDescWrapper();
        //String loggedInUserName = UserInfo.getUserName();
        String PROC_Countries = system.label.PRM_PROC_Countries;
        List<String> blacklistDomains = new List<String>();
        boolean isPrimary = false;
        User loggedInUser = [SELECT ContactId FROM User WHERE id = :UserInfo.getUserId()];
        if (!String.isEmpty(loggedInUser.ContactId)) {
            Contact cont = [
                SELECT
                id,
                Name,
                AccountId,
                Core_IPA_PartnerRole__c,
                Core_Preferred_Language__c,
                (SELECT Id, Core_Entitlement_Id__r.Core_Display_Name__c,Core_Entitlement_Nm__c FROM Contact_Entitlements__r WHERE Core_Selected__c = TRUE AND Core_Type__c = :'Entitlement' AND Core_Status__c=:system.Label.PRM_PCREntitlement_Status),
                (SELECT Id, PRM_Relationship_Id__r.Name, PRM_Account_Id__r.Id FROM Account_Contact_Relationships__r where PRM_InActive_Ind__c=  
                 false)
                FROM Contact
                WHERE Id = :loggedInUser.ContactId
            ]; //:loggedInUserName];
            
            if (cont != null) {
                CONTACT_ID = cont.Id;
                Account acct = [
                    SELECT
                    id,
                    Name,
                    Core_User_Defined_Website__c,
                    Core_CNDA_Number__c,
                    Core_User_Defined_Phone_Number__c,
                    Core_IPA_Partner_Role__c,
                    AccountNumber,
                    BillingStreet,
                    BillingCity,
                    BillingState,
                    BillingCountry,
                    BillingPostalCode,
                    BillingCountryCode,
                    ShippingStreet,
                    ShippingCity,
                    ShippingState,
                    ShippingCountry,
                    ShippingPostalCode,
                    (
                        SELECT PRM_Profile_Questions_Id__r.PRM_Question_Cd__c, PRM_Response_Txt__c
                        FROM Profile_Responses__r
                        WHERE PRM_Profile_Questions_Id__r.PRM_Question_Cd__c = :'PRM_Opt_In' AND PRM_InActive_Ind__c = FALSE
                    ),
                    (SELECT PRM_Specialty_Id__r.Name, PRM_Specialty_Type__c FROM Account_Specialty_Associations__r WHERE PRM_InActive_Ind__c = FALSE),
                    (SELECT Core_Partner_Account_Id__r.Name FROM Partner_Account_Group_Members1__r WHERE Core_Inactive_Ind__c = FALSE LIMIT 1)
                    FROM Account
                    WHERE Id = :cont.AccountId
                ];
                
                if (PROC_Countries.contains(acct.BillingCountryCode)) {
                    for (String domains : system.label.PRM_Intel_BlackListed_Email_Domain_For_PROC_Region.split(',')) {
                        blacklistDomains.add(domains);
                    }
                } else {
                    for (String domains : system.label.PRM_Intel_BlackListed_Email_Domain.split(';')) {
                        blacklistDomains.add(domains);
                    }
                }
                
                if (cont.Account_Contact_Relationships__r.size() > 0) {
                    List<String> partnerRoles = new List<String>();
                    if (!String.isEmpty(cont.Core_IPA_PartnerRole__c)) {
                        partnerRoles = cont.Core_IPA_PartnerRole__c.split(';');
                    }
                    isPrimary=CheckIfContactIsPrimary(loggedInUser.ContactId);
                    compnyInfo.CompanyInfo = getCompanyInfo(acct, isPrimary, partnerRoles[0], blacklistDomains);
                    
                }
                if (!String.isEmpty(cont.Core_IPA_PartnerRole__c)) {
                    String language = String.isEmpty(cont.Core_Preferred_Language__c) ? 'ENG' : cont.Core_Preferred_Language__c;
                    //List<String> partnerRoles = cont.Core_IPA_PartnerRole__c.split(';');
                    compnyInfo.CompanyInfo.ProfileResponses = getProfileResponses(acct.Id);
                }
            }
        }
        return JSON.serialize(compnyInfo);
    }
    
    @AuraEnabled(cacheable=true)
    public static String getMyCompanySecondaryContacts() {
        SecondaryContacts scs = new SecondaryContacts();
        User loggedInUser = [SELECT ContactId, Contact.AccountId, Contact.Core_IPA_PartnerRole__c FROM User WHERE Id = :UserInfo.getUserId()];
        if (!String.isEmpty(loggedInUser.ContactId)) {
            //Contact cont = [SELECT id,Name,AccountId,Account.Name,Core_IPA_PartnerRole__c FROM Contact WHERE Core_Login_Id__c= :USER_NAME];//:UserInfo.getUserName()];//'megatronic.bates@yhwjncdcik.com'];
            
            //if(cont!=null && !String.isEmpty(cont.Core_IPA_PartnerRole__c)) {
            scs.RegRequests = getPendingSecondaryContactRequests(loggedInUser.Contact.AccountId, loggedInUser.Contact.Core_IPA_PartnerRole__c.split(';'));
            //}
        }
        return JSON.serialize(scs.RegRequests);
    }
    
    @AuraEnabled(cacheable=true)
    public static string getMyCompanyContacts() {
        List<SecondaryContactWrapper> contacts = new List<SecondaryContactWrapper>();
        User loggedInUser = [SELECT ContactId FROM User WHERE id = :UserInfo.getUserId()];
        if (!String.isEmpty(loggedInUser.ContactId)) {
            Contact cont = [
                SELECT id, Name, AccountId, Account.Name, Core_IPA_PartnerRole__c, (SELECT Id, PRM_Relationship_Id__r.Name, PRM_Account_Id__r.Id FROM Account_Contact_Relationships__r)
                FROM Contact
                WHERE Id = :loggedInUser.ContactId
            ]; //:UserInfo.getUserName()];//'bullock.cart@mailinator.com'];
            if (!String.isEmpty(cont.Core_IPA_PartnerRole__c)) {
                for (Contact con : [
                    SELECT
                    id,
                    Name,
                    Email,
                    Core_IPA_PartnerRole__c,
                    Phone,
                    (SELECT Id, Core_Entitlement_Id__r.Core_Display_Name__c,Core_Entitlement_Nm__c FROM Contact_Entitlements__r WHERE Core_Selected__c = TRUE AND Core_Type__c = :'Entitlement' AND Core_Status__c=:system.Label.PRM_PCREntitlement_Status),
                    (SELECT Id, PRM_Status_Nm__c, PRM_Relationship_Id__r.Name, PRM_Account_Id__r.Id FROM Account_Contact_Relationships__r WHERE PRM_InActive_Ind__c = FALSE)
                    FROM Contact
                    WHERE AccountId = :cont.AccountId  AND  Core_IPA_PartnerRole__c IN :cont.Core_IPA_PartnerRole__c.split(';') AND Core_Enterprise_Id__c!='' AND Core_Login_Status__c='Active'
                ]) {
                    if (con.Account_Contact_Relationships__r.size() > 0) {
                        SecondaryContactWrapper acctContact = new SecondaryContactWrapper();
                        acctContact.RecordId = con.Id;
                        acctContact.Name = con.Id == cont.Id ? con.Name + ' (' + Label.PRM_You + ')' : con.Name;
                        acctContact.Email = con.Email;
                        
                        acctContact.Status = con.Account_Contact_Relationships__r[0].PRM_Status_Nm__c;
                        
                        acctContact.isLoggedinUser = con.Id == cont.Id ? true : false;
                        
                        acctContact.isPrimary = con.Id == cont.Id ? CheckIfContactIsPrimary(cont.Id):false;
                        String responsibilities = '';
                        for (Core_Contact_Entitlement__c ce : con.Contact_Entitlements__r) {
                            responsibilities = responsibilities + ce.Core_Entitlement_Id__r.Core_Display_Name__c + ', ';
                        }
                        if (responsibilities.length() > 2) {
                            acctContact.Responsibilities = responsibilities.subString(0, responsibilities.length() - 2);
                        }
                        contacts.add(acctContact);
                    }
                }
            }
        }
        return JSON.serialize(contacts);
    }
    @AuraEnabled(cacheable=true)
    public static String getMyCompanyLegalAgreemnent() {
        List<LegalAgreementWrapper> legalResponse = new List<LegalAgreementWrapper>();
        User loggedInUser = [SELECT ContactId, Contact.AccountId, Contact.Email FROM User WHERE Id = :UserInfo.getUserId()];
        
        
        if (!String.isEmpty(loggedInUser.ContactId)) {
            //Contact cont = [SELECT id,Name,AccountId,Account.Name,Core_IPA_PartnerRole__c FROM Contact WHERE Core_Login_Id__c= '11553183@intel.com.crm.devipa'];//:UserInfo.getUserName()];//'megatronic.bates@yhwjncdcik.com'];
            //if(cont!=null) {
            legalResponse = getComapanyLegalAgreementDetails(loggedInUser.Contact.AccountId);
            //}
        }
        return JSON.serialize(legalResponse);
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Boolean> isLoggedInUserPrimaryContact() {
        Map<String, Boolean> result = new Map<String, Boolean>();
        Boolean isInternalUser = false;
        User loggedInUser = [SELECT ContactId, Contact.AccountId,Email FROM User WHERE Id = :UserInfo.getUserId()];
        String emailDomain = loggedInUser.email.split('@')[1];
            if(emailDomain == LabelConfiguration__mdt.getInstance('PRM_internalDomain').Value__c){
                isInternalUser = true;
            }
        result.put('isPrimary', CheckIfContactIsPrimary(loggedInUser.ContactId));
        result.put('isInternalUser', isInternalUser);
        return result;
    }
    
    /*
private Static List<SecondaryContactWrapper> getPendingSecondaryContacts(Id AccountId, List<String> partnerRoles, Id ContactId){
Set<String> contactEmails = new Set<String>();
Set<String> regReqEmails =  new Set<String>();
List<SecondaryContactWrapper> Contacts = new List<SecondaryContactWrapper>();
Map<String,PRM_Registration_Request__c> emailRegReqMap = new Map<String,PRM_Registration_Request__c>();
List<Contact> lstContacts = [Select id,Name,Email,Core_IPA_PartnerRole__c,Phone,
(SELECT Id,Core_Entitlement_Id__r.Name FROM Contact_Entitlements__r WHERE Core_Selected__c=True),
(SELECT Id FROM Account_Contact_Relationships__r WHERE PRM_InActive_Ind__c=false AND PRM_Status_Nm__c='Pending Action')
FROM Contact WHERE AccountId= :AccountId AND Id!= :ContactId AND Core_IPA_PartnerRole__c!=null];
for(Contact cont: lstContacts) {
contactEmails.add(cont.Email);
}
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

for(Contact cont: lstContacts) {
List<String> contPartnerRoles = cont.Core_IPA_PartnerRole__c.split(';');
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
return Contacts;
}
*/
    private static List<SecondaryContactWrapper> getPendingSecondaryContactRequests(Id sfAccountId, List<String> partnerRoles) {
        List<SecondaryContactWrapper> regRequests = new List<SecondaryContactWrapper>();
        Id AccountCreateRT = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get('Account_Create_Request').getRecordTypeId();
        Id AdminRegistrationRT = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get('Admin_Registration').getRecordTypeId();
        List<PRM_Registration_Request__c> regReqList = new List<PRM_Registration_Request__c>();
        
        regReqList = [SELECT id,PRM_Person_Phone_Number__c,PRM_First_Name__c,PRM_Last_Name__c,PRM_Partner_Relationship__c,PRM_Email_ID__c,Email_Verification_Status__c
                      FROM PRM_Registration_Request__c WHERE PRM_Status__c = 'New' AND (RecordTypeId = :AccountCreateRT OR RecordTypeId = :AdminRegistrationRT) AND PRM_Partner_Role__c IN :partnerRoles
                      AND PRM_Salesforce_ID__c = :sfAccountId ORDER BY PRM_First_Name__c ASC];
        
        for (PRM_Registration_Request__c regReq : regReqList) {
            SecondaryContactWrapper RegRequest = new SecondaryContactWrapper();
            RegRequest.RecordId = regReq.Id;
            RegRequest.Name = regReq.PRM_First_Name__c + ' ' + regReq.PRM_Last_Name__c;
            RegRequest.Email = regReq.PRM_Email_ID__c;
            RegRequest.Phone = regReq.PRM_Person_Phone_Number__c;
            RegRequest.EVStatus = regReq.Email_Verification_Status__c == 'SUCCESS' ? 'Verified' : 'Not Verified';
            RegRequest.Relationship = regReq.PRM_Partner_Relationship__c.Replace(';', ',');
            
            if (RegRequest.EVStatus == 'Verified') {
                RegRequest.isApprove = false;
            } else {
                RegRequest.isApprove = true;
            }
            regRequests.add(RegRequest);
        }
        return regRequests;
    }
    public static String getPartnerRoleLabel(String role) {
        String partnerRoleLabel = role;
        List<Schema.PicklistEntry> pickListValues = Contact.Core_IPA_PartnerRole__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry v : pickListValues) {
            if (v.getValue() == role) {
                partnerRoleLabel = v.getLabel();
                break;
            }
        }
        return partnerRoleLabel;
    }
    public static CompanyInfoWrapper getCompanyInfo(Account acct, boolean acctContRelNameFlag, String role, List<String> blacklistDomains) {
        CompanyInfoWrapper CompanyInfo = new CompanyInfoWrapper();
        CompanyInfo.Name = acct.Name != null ? acct.Name : '';
        CompanyInfo.NaturalGrouping = (acct.Partner_Account_Group_Members1__r.size() > 0) ? acct.Partner_Account_Group_Members1__r[0].Core_Partner_Account_Id__r.Name : '';
        CompanyInfo.Website = acct.Core_User_Defined_Website__c != null ? acct.Core_User_Defined_Website__c : '';
        CompanyInfo.Phone = acct.Core_User_Defined_Phone_Number__c != null ? acct.Core_User_Defined_Phone_Number__c : '';
        CompanyInfo.NDA = acct.Core_CNDA_Number__c != null ? acct.Core_CNDA_Number__c : '';
        CompanyInfo.MailingAddress = getMailingAddress(acct);
        CompanyInfo.PhysicalAddress = getPhysicalAddress(acct);
        CompanyInfo.isPrimary = acctContRelNameFlag;
        CompanyInfo.AccountId = acct.Id;
        CompanyInfo.Specialties = new Set<String>();
        CompanyInfo.SelectBenefits = new Set<String>();
        //CompanyInfo.PartnerRole = role;
        CompanyInfo.PartnerRole = getPartnerRoleLabel(role);
        CompanyInfo.PartnerRoleAPI = role;
        CompanyInfo.BlacklistDomains = blacklistDomains;
        CompanyInfo.ContactId = CONTACT_ID;
        CompanyInfo.AccountNumber = acct.AccountNumber;
        /*if(!IPARefresh)//IPA2.0 TWC727-2898
        {
            for (PRM_Account_Specialty_Association__c asa : acct.Account_Specialty_Associations__r) {
                if (asa.PRM_Specialty_Type__c == 'Specialty') {
                    CompanyInfo.Specialties.add(asa.PRM_Specialty_Id__r.Name);
                } else if (asa.PRM_Specialty_Type__c == 'Select Benefits') {
                    CompanyInfo.SelectBenefits.add(asa.PRM_Specialty_Id__r.Name);
                }
            } 
        } */ //switch removal  //IPA2.0 TWC727-2898
        CompanyInfo.WhitelistedDomains = getWhitelistedDomains(acct.Id);
        CompanyInfo.PartnerAssistConcents = getPartnerAssist(acct.Id);
        if (acct.Profile_Responses__r.size() > 0) {
            CompanyInfo.OptInPoints = acct.Profile_Responses__r[0].PRM_Response_Txt__c;
        }
        //CompanyInfo.PartnerAssists = getPartnerAssist(acct.Id);
        return CompanyInfo;
    }
    private static Address getMailingAddress(Account acct) {
        Address MailingAdress = new Address();
        boolean isAddressEmpty = false;
        isAddressEmpty = (String.isEmpty(acct.BillingStreet) && String.isEmpty(acct.Billingcity) &&  String.isEmpty(acct.BillingState)  && String.isEmpty(acct.BillingCountry) && String.isEmpty(acct.BillingPostalCode)) ? true : false;
        if (!isAddressEmpty) {
            MailingAdress.Street = acct.BillingStreet;
            MailingAdress.City = acct.Billingcity;
            MailingAdress.State = acct.BillingState;
            MailingAdress.Country = acct.BillingCountry;
            MailingAdress.PostalCode = acct.BillingPostalCode;
            return MailingAdress;
        } else {
            return MailingAdress;
        }
    }
    private static Address getPhysicalAddress(Account acct) {
        boolean isAddressEmpty = false;
        Address PhysicalAdress = new Address();
        isAddressEmpty = (String.isEmpty(acct.ShippingStreet) && String.isEmpty(acct.Shippingcity) && String.isEmpty(acct.ShippingState) && String.isEmpty(acct.ShippingCountry) && String.isEmpty(acct.ShippingPostalCode)) ? true : false;
        if (!isAddressEmpty) {
            string[] ctryState=getCountryStateName(acct.ShippingCountry,acct.ShippingState);
            PhysicalAdress.Street = acct.ShippingStreet;
            PhysicalAdress.City = acct.Shippingcity;
            if(ctryState!=null && ctryState.Size()>0){
                PhysicalAdress.State = ctryState[1]==null? '':ctryState[1];
                PhysicalAdress.Country = ctryState[0];
            }
            PhysicalAdress.PostalCode = acct.ShippingPostalCode;
            return PhysicalAdress;
        } else {
            return PhysicalAdress;
        }
    }
    
    /*
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
*/
    
    public static List<ProfileResponse> getProfileResponses(Id recordId) {
        String channelProg = 'Intel Partner Alliance';
        //String objectName = 'Account';
        String questionCode = 'PRM_AcceptableDomain';
        List<String> channelProgramNames = new List<String>();
        //Set<Id> channelProgId = new Set<Id>();
        
        if (channelProg != null) {
            channelProgramNames = channelProg.split(',');
        }
        List<ProfileResponse> ProfileResponses = new List<ProfileResponse>();
        for (PRM_Profile_Responses__c response : [
            SELECT Id, PRM_Profile_Questions_Id__r.PRM_Question_Display_Txt__c, PRM_Profile_Questions_Id__r.PRM_Question_Cd__c, PRM_Response_Txt__c
            FROM PRM_Profile_Responses__c
            WHERE PRM_InActive_Ind__c = FALSE AND PRM_Account_Id__c = :recordId AND PRM_Profile_Questions_Id__r.PRM_Channel_Program_Id__r.Name IN :channelProgramNames
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
    
    private static List<LegalAgreementWrapper> getComapanyLegalAgreementDetails(Id AccountId) {
        List<LegalAgreementWrapper> lglAgreementList = new List<LegalAgreementWrapper>();
        List<PRM_AccountLegalAgreemntAssociation__c> AcctLegalAgrmnt = new List<PRM_AccountLegalAgreemntAssociation__c>();
        //IPA 2.0 - TWC729-7874
        AcctLegalAgrmnt = [SELECT Id, PRM_Agreement_Sign_Dt__c,PRM_Signed_By_Name__c, PRM_Partner_Agreement_Id__r.Name
        FROM PRM_AccountLegalAgreemntAssociation__c
        WHERE PRM_Account_Id__r.Id = :AccountId AND PRM_InActive_Ind__c=false AND PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c= :system.label.PRM_IPATNCCode];
        
        for (PRM_AccountLegalAgreemntAssociation__c agreement : AcctLegalAgrmnt) {
            LegalAgreementWrapper lglAgreement = new LegalAgreementWrapper();
            lglAgreement.LegalAgreementName = agreement.PRM_Partner_Agreement_Id__r.Name;
            //IPA 2.0 - TWC729-7874
            lglAgreement.LegalAgreementSignedBy = agreement.PRM_Signed_By_Name__c;
            lglAgreement.LegalAgreementSignedDate = agreement.PRM_Agreement_Sign_Dt__c;
            lglAgreement.RecordId = agreement.Id;
            lglAgreementList.add(lglAgreement);
        }
        return lglAgreementList;
    }
    
    @AuraEnabled
    public static boolean updateAccountInfo(String accountId, String website, String phone) {
        Account acct = [SELECT Id, Core_User_Defined_Website__c, Core_User_Defined_Phone_Number__c FROM Account WHERE Id = :accountId];
        if (acct != null) {
            acct.Core_User_Defined_Website__c = website;
            acct.Core_User_Defined_Phone_Number__c = phone;
            update acct;
            return true;
        }
        return false;
    }
    // Save WhiteList
    @AuraEnabled
    public static boolean saveWhitelistedDomains(String AcctId, List<List<String>> whitelistedDomain) {
        try {
            Map<String, String> WhiteListMap = new Map<String, String>();
            Map<String, Core_Account_Whitelisted_Domains__c> WhiteListReverseMap = new Map<String, Core_Account_Whitelisted_Domains__c>();
            List<Core_Account_Whitelisted_Domains__c> updateWhiteListRecord = new List<Core_Account_Whitelisted_Domains__c>();
            List<Core_Account_Whitelisted_Domains__c> insertWhiteListRecord = new List<Core_Account_Whitelisted_Domains__c>();
            ChannelProgram ipaId = [SELECT id FROM channelProgram WHERE name = :System.label.PRM_Intel_Partner_Alliance LIMIT 1];
            for (
                Core_Account_Whitelisted_Domains__c whiteList : ([
                    SELECT Id, Name, Inactive_Indicator__c, Effective_End_Date_Time__c
                    FROM Core_Account_Whitelisted_Domains__c
                    WHERE Account__c = :AcctId AND Partner_Program__c = :ipaID.id
                ])
            ) {
                WhiteListMap.put(whiteList.Id, whiteList.Name);
                WhiteListReverseMap.put(whiteList.Name, whiteList);
            }
            for (List<String> key : whitelistedDomain) {
                String recId = key[0];
                String domain = key[1];
                if (WhiteListMap.size() > 0 && WhiteListMap.containsKey(recId)) {
                    Core_Account_Whitelisted_Domains__c updateWhiteList = new Core_Account_Whitelisted_Domains__c();
                    updateWhiteList.id = recId;
                    updateWhiteList.Name = domain;
                    updateWhiteList.Inactive_Indicator__c = false;
                    updateWhiteListRecord.add(updateWhiteList);
                } else if (WhiteListMap.size() > 0 && WhiteListReverseMap.containsKey(domain)) {
                    Core_Account_Whitelisted_Domains__c updateWhiteList = new Core_Account_Whitelisted_Domains__c();
                    //updateWhiteList.id = key;
                    //updateWhiteList.Name = whitelistedDomain.get(key);
                    updateWhiteList.id = WhiteListReverseMap.get(domain).id;
                    updateWhiteList.Name = domain;
                    updateWhiteList.Inactive_Indicator__c = false;
                    updateWhiteListRecord.add(updateWhiteList);
                } else {
                    Core_Account_Whitelisted_Domains__c insertWhiteList = new Core_Account_Whitelisted_Domains__c();
                    if (!String.isBlank(domain)) {
                        insertWhiteList.Name = domain;
                        insertWhiteList.Inactive_Indicator__c = false;
                        insertWhiteList.Account__c = AcctId;
                        insertWhiteList.Partner_Program__c = ipaID.id;
                        insertWhiteListRecord.add(insertWhiteList);
                    }
                }
            }
            if (WhiteListMap.size() > 0) {
                for (String key : WhiteListMap.keySet()) {
                    //String recIdDomain =  key+','+WhiteListMap.get(key);
                    boolean domainRemoved = true;
                    for (List<String> domainLst : whitelistedDomain) {
                        if (domainLst[0] == key || WhiteListMap.get(key) == domainLst[1]) {
                            domainRemoved = false;
                            break;
                        }
                    }
                    //if( !whitelistedDomain.contains(recIdDomain)){
                    if (domainRemoved) {
                        Core_Account_Whitelisted_Domains__c updateWhiteList = new Core_Account_Whitelisted_Domains__c();
                        updateWhiteList.id = key;
                        updateWhiteList.Inactive_Indicator__c = true;
                        updateWhiteList.Effective_End_Date_Time__c = system.now();
                        updateWhiteList.Partner_Program__c = ipaID.id;
                        updateWhiteListRecord.add(updateWhiteList);
                    }
                }
            }
            
            if (updateWhiteListRecord.size() > 0) {
                update updateWhiteListRecord;
            }
            if (insertWhiteListRecord.size() > 0) {
                insert insertWhiteListRecord;
            }
            
            return true;
        } catch (Exception ex) {
            //system.debug('Error Cause==>' + ex.getCause());
            //system.debug('Error Message==>' + ex.getMessage());
            //system.debug('Error StackTrace String==>' + ex.getStackTraceString());
            return false;
        }
    }
    /*
@AuraEnabled
public static boolean saveWhitelistedDomains(String AcctId, Map<String,String> whitelistedDomain){
try {
//system.debug('Account Id' +AcctId);
//system.debug('WhiteListed Domain' +whitelistedDomain);
Map<String,String> WhiteListMap = new Map<String,String>();
List<Core_Account_Whitelisted_Domains__c>  updateWhiteListRecord = new List<Core_Account_Whitelisted_Domains__c>();
List<Core_Account_Whitelisted_Domains__c>  insertWhiteListRecord = new List<Core_Account_Whitelisted_Domains__c>();
ChannelProgram   ipaId = [Select id from channelProgram Where name = :System.label.PRM_Intel_Partner_Alliance limit 1];
for(Core_Account_Whitelisted_Domains__c whiteList: ([Select Id, Name,Inactive_Indicator__c,Effective_End_Date_Time__c from Core_Account_Whitelisted_Domains__c Where Account__c = :AcctId AND Partner_Program__c = :ipaID.id]))
{
WhiteListMap.put(whiteList.Id,whiteList.Name);                
}
for (String key : whitelistedDomain.keySet()) {
if(WhiteListMap.size()>0 && WhiteListMap.containsKey(key)){
Core_Account_Whitelisted_Domains__c updateWhiteList = new Core_Account_Whitelisted_Domains__c();
updateWhiteList.id = key;
updateWhiteList.Name = whitelistedDomain.get(key);
updateWhiteList.Inactive_Indicator__c = false;
updateWhiteListRecord.add(updateWhiteList);
} else {
Core_Account_Whitelisted_Domains__c insertWhiteList = new Core_Account_Whitelisted_Domains__c();
insertWhiteList.Name = whitelistedDomain.get(key);
insertWhiteList.Inactive_Indicator__c = false ;
insertWhiteList.Account__c = AcctId;
insertWhiteList.Partner_Program__c  = ipaID.id;
insertWhiteListRecord.add(insertWhiteList);               
}
}
if(WhiteListMap.size()>0){
for(String key : WhiteListMap.keySet()){
if( !whitelistedDomain.containsKey(key)){
Core_Account_Whitelisted_Domains__c updateWhiteList = new Core_Account_Whitelisted_Domains__c();
updateWhiteList.id = key;
updateWhiteList.Inactive_Indicator__c = true;
updateWhiteList.Effective_End_Date_Time__c = system.now();
updateWhiteList.Partner_Program__c  = ipaID.id;
updateWhiteListRecord.add(updateWhiteList);
}
}
}

if(updateWhiteListRecord.size()>0){
//system.debug(updateWhiteListRecord);
update updateWhiteListRecord;
}
if(insertWhiteListRecord.size()>0){
//system.debug(insertWhiteListRecord);
insert insertWhiteListRecord;
}

return true;
}catch(Exception ex){
//system.debug('Error Cause==>'+ex.getCause());
//system.debug('Error Message==>'+ex.getMessage());
//system.debug('Error StackTrace String==>'+ex.getStackTraceString());
return false;
} 
}*/
    
    // Get WhiteList
    public static List<WhiteListWrapper> getWhitelistedDomains(Id AcctId) {
        List<WhiteListWrapper> whiteListWrapper = new List<WhiteListWrapper>();
        List<Core_Account_Whitelisted_Domains__c> whiteListRecList = new List<Core_Account_Whitelisted_Domains__c>();
        if (AcctId != null) {
            whiteListRecList = [
                SELECT Id, Name
                FROM Core_Account_Whitelisted_Domains__c
                WHERE Account__c = :AcctId AND Inactive_Indicator__c = FALSE AND Partner_Program__r.name = :System.label.PRM_Intel_Partner_Alliance
                ORDER BY LastModifiedDate DESC
                
            ];
        }
        if (whiteListRecList.size() > 0) {
            for (Core_Account_Whitelisted_Domains__c whiteList : whiteListRecList) {
                WhiteListWrapper whiteListObj = new WhiteListWrapper();
                whiteListObj.RecordId = whiteList.Id;
                whiteListObj.WhiteListName = whiteList.Name;
                whiteListWrapper.add(whiteListObj);
            }
        }
        //system.debug(whiteListWrapper);
        return whiteListWrapper;
    }
    
    //---------------------Approve reject---------------------------------------
    @AuraEnabled
    public static string updateFlag(String recordId, String flag) {
        //cant we send whole registration req record instead of record id
        String returnMessage = '';
        try {
            PRM_Registration_Request__c regReq = [SELECT id, Name, PRM_PC_Approve_Reject_Flag__c FROM PRM_Registration_Request__c WHERE Id = :recordId];
            if (regReq != null) {
                if (flag.equals(STR_APPROVE)) {
                    regReq.PRM_PC_Approve_Reject_Flag__c = STR_APPROVED; //constant final
                    returnMessage = STR_APPROVE_SUCCESS;
                } else if (flag.equals(STR_REJECT)) {
                    regReq.PRM_PC_Approve_Reject_Flag__c = STR_REJECTED;
                    returnMessage = STR_REJECT_SUCCESS;
                }
                update regReq;
            }
            return returnMessage;
        } catch (Exception ex) {
            //system.debug('Error ==> Exception' + ex);
            returnMessage = ex.getStackTraceString();
            return returnMessage;
        }
    }
    
    /**
* Get ProcessInstanceWorkItemId using SOQL
**/
    public static Id getWorkItemId(Id targetObjectId) {
        Id retVal = null;
        for (ProcessInstanceWorkitem workItem : [SELECT p.Id FROM ProcessInstanceWorkitem p WHERE p.ProcessInstance.TargetObjectId = :targetObjectId]) {
            retVal = workItem.Id;
        }
        return retVal;
    }
    
    @InvocableMethod(
        Label='PRM_APPROVE_REJECT_REGISTRATION_REQUEST_PARTNER_ADMIN'
        description='PRM_APPROVE_REJECT_REGISTRATION_REQUEST_PARTNER_ADMIN'
        category='Registration Request'
    )
    public static void approveRejectRequestsByPC(List<Id> regReqIds) {
        try {
            PRM_Registration_Request__c regReq = [
                SELECT id, Name, PRM_Status_Reason__c, PRM_PC_Approve_Reject_Flag__c
                FROM PRM_Registration_Request__c
                WHERE Id IN :regReqIds
                LIMIT 1
            ];
            
            if (regReq != null) {
                if (regReq.PRM_PC_Approve_Reject_Flag__c.equals(STR_APPROVED)) {
                    regReq.PRM_Status_Reason__c = 'Test ' + Math.random();
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setComments('Approving request using Button');
                    req.setAction(STR_APPROVE);
                    Id workItemId = getWorkItemId(regReq.id);
                    
                    if (workItemId != null) {
                        req.setWorkitemId(workItemId);
                        //Approval.ProcessResult result = 
                            Approval.process(req);
                    }
                }
                if (regReq.PRM_PC_Approve_Reject_Flag__c.equals(STR_REJECTED)) {
                    regReq.PRM_Status_Reason__c = 'Test ' + Math.random();
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setComments('Reject request using Button');
                    req.setAction(STR_REJECT);
                    Id workItemId = getWorkItemId(regReq.id);
                    
                    if (workItemId != null) {
                        req.setWorkitemId(workItemId);
                        //Approval.ProcessResult result = 
                            Approval.process(req);
                    }
                }
            }
        } catch (Exception ex) {
            system.debug('Error ==> Exception' + ex);
        }
    }
    //---------------------Approve reject---------------------------------------
    
    //---------------------------------- Partner Assist ----------------------------------
    public static PartnerAssistConcent getPartnerAssist(Id AcctId) {
        PartnerAssistConcent partnerAssistConcentWrapper = new PartnerAssistConcent();
        if (!String.isEmpty(AcctId)) {
            List<PRM_Partner_Assist_Utility.DistributorListWrapper> distributerWrapperList = PRM_Partner_Assist_Utility.getDistributorList();
            List<String> distibuterName = new List<String>();
            for (PRM_Partner_Assist_Utility.DistributorListWrapper disti : distributerWrapperList) {
                distibuterName.add(disti.label);
            }
            partnerAssistConcentWrapper.DistributerNames = distibuterName;
            partnerAssistConcentWrapper.PartnerAssists = getPartnerAssistList(AcctId);
        }
        return partnerAssistConcentWrapper;
    }
    
    public static List<PartnerAssist> getPartnerAssistList(Id AcctId) {
        String primaryConsent = 'Partner Assist Choice 1';
        String secondaryConsent = 'Partner Assist Choice 2';
        List<PartnerAssist> PartnerAssist = new List<PartnerAssist>();
        Map<String, PRM_Partner_Assist_Consent__c> partnerAssistMap = new Map<String, PRM_Partner_Assist_Consent__c>();
        for (
            PRM_Partner_Assist_Consent__c partnerAssistList : ([
                SELECT Id, Name, PRM_Choice_Nm__c, PRM_Consent_Provided_Ind__c, PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c
                FROM PRM_Partner_Assist_Consent__c
                WHERE PRM_Account_Id__c = :AcctId AND PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c != NULL
            ])
        ) {
            partnerAssistMap.put(partnerAssistList.PRM_Choice_Nm__c, partnerAssistList);
        }
        if (partnerAssistMap.containsKey(primaryConsent) && partnerAssistMap.containsKey(secondaryConsent)) {
            if (partnerAssistMap.get(primaryConsent).PRM_Consent_Provided_Ind__c == true && partnerAssistMap.get(secondaryConsent).PRM_Consent_Provided_Ind__c == true) {
                PartnerAssist partnerAssistRecord = new PartnerAssist();
                partnerAssistRecord.PartnerAssistId = partnerAssistMap.get(primaryConsent).Id;
                partnerAssistRecord.DistributerName = partnerAssistMap.get(primaryConsent).PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c;
                partnerAssistRecord.ConsentIndicator = partnerAssistMap.get(primaryConsent).PRM_Consent_Provided_Ind__c;
                PartnerAssist.add(partnerAssistRecord);
                
                PartnerAssist partnerAssistRecordSec = new PartnerAssist();
                partnerAssistRecordSec.PartnerAssistId = partnerAssistMap.get(secondaryConsent).Id;
                partnerAssistRecordSec.DistributerName = partnerAssistMap.get(secondaryConsent).PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c;
                partnerAssistRecordSec.ConsentIndicator = partnerAssistMap.get(secondaryConsent).PRM_Consent_Provided_Ind__c;
                PartnerAssist.add(partnerAssistRecordSec);
            }
            if (partnerAssistMap.get(primaryConsent).PRM_Consent_Provided_Ind__c == true && partnerAssistMap.get(secondaryConsent).PRM_Consent_Provided_Ind__c == false) {
                PartnerAssist partnerAssistRecord = new PartnerAssist();
                partnerAssistRecord.PartnerAssistId = partnerAssistMap.get(primaryConsent).Id;
                partnerAssistRecord.DistributerName = partnerAssistMap.get(primaryConsent).PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c;
                partnerAssistRecord.ConsentIndicator = partnerAssistMap.get(primaryConsent).PRM_Consent_Provided_Ind__c;
                PartnerAssist.add(partnerAssistRecord);
            }
            if (partnerAssistMap.get(primaryConsent).PRM_Consent_Provided_Ind__c == false && partnerAssistMap.get(secondaryConsent).PRM_Consent_Provided_Ind__c == false) {
                PartnerAssist partnerAssistRecord = new PartnerAssist();
                partnerAssistRecord.PartnerAssistId = partnerAssistMap.get(primaryConsent).Id;
                partnerAssistRecord.DistributerName = partnerAssistMap.get(primaryConsent).PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c;
                partnerAssistRecord.ConsentIndicator = partnerAssistMap.get(primaryConsent).PRM_Consent_Provided_Ind__c;
                PartnerAssist.add(partnerAssistRecord);
                
                PartnerAssist partnerAssistRecordSec = new PartnerAssist();
                partnerAssistRecordSec.PartnerAssistId = partnerAssistMap.get(secondaryConsent).Id;
                partnerAssistRecordSec.DistributerName = partnerAssistMap.get(secondaryConsent).PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c;
                partnerAssistRecordSec.ConsentIndicator = partnerAssistMap.get(secondaryConsent).PRM_Consent_Provided_Ind__c;
                PartnerAssist.add(partnerAssistRecordSec);
            }
        } else if (partnerAssistMap.containsKey(primaryConsent)) {
            PartnerAssist partnerAssistRecord = new PartnerAssist();
            partnerAssistRecord.PartnerAssistId = partnerAssistMap.get(primaryConsent).Id;
            partnerAssistRecord.DistributerName = partnerAssistMap.get(primaryConsent).PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c;
            partnerAssistRecord.ConsentIndicator = partnerAssistMap.get(primaryConsent).PRM_Consent_Provided_Ind__c;
            PartnerAssist.add(partnerAssistRecord);
        }
        
        return PartnerAssist;
    }
    @AuraEnabled
    public static boolean savePartnerAssist(String AcctId, String partnerAssistPrimary, String partnerAssistSecoundry, boolean optIn, String ContactId) {
        String primaryConsent = 'Partner Assist Choice 1';
        String secondaryConsent = 'Partner Assist Choice 2';
        // String selectDisti = 'Select any Distributor 2';
        try {
            List<PRM_Partner_Assist_Consent__c> updatePartnerListRecord = new List<PRM_Partner_Assist_Consent__c>();
            Map<String, PRM_Partner_Assist_Consent__c> partnerAssistMap = new Map<String, PRM_Partner_Assist_Consent__c>();
            if (AcctId != null) {
                for (
                    PRM_Partner_Assist_Consent__c partnerAssist : ([
                        SELECT Id, Name, PRM_Consent_Provided_Ind__c, PRM_Choice_Nm__c, PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c
                        FROM PRM_Partner_Assist_Consent__c
                        WHERE PRM_Account_Id__c = :AcctId AND PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c != NULL
                    ])
                ) {
                    partnerAssistMap.put(partnerAssist.PRM_Choice_Nm__c, partnerAssist);
                }
            }
            //system.debug('partnerAssistMap ==>' + partnerAssistMap);
            if (optIn) {
                String userGeo = '';
                if (AcctId != null) {
                    Account accObj = [SELECT id, name, Core_Account_Country__c, Core_Geo__c, Core_Sub_Geo__c FROM Account WHERE Id = :AcctId LIMIT 1];
                    if (accObj != null) {
                        userGeo = accObj.Core_Geo__c;
                    }
                }
                /* if(partnerAssistSecoundry == selectDisti &&  optIn == true){

for(PRM_Partner_Assist_Consent__c partnerAssit :partnerAssistMap.values())
{       
if(partnerAssit.PRM_Choice_Nm__c == secondaryConsent){
PRM_Partner_Assist_Consent__c updatePartnerList = new PRM_Partner_Assist_Consent__c();
updatePartnerList.Id = partnerAssit.Id;
updatePartnerList.PRM_Consent_Provided_Ind__c = false;
updatePartnerList.PRM_End_Date_Dt__c= System.now();
updatePartnerListRecord.add(updatePartnerList);
}
}
} */
                if (string.isBlank(partnerAssistPrimary) && optIn == true) {
                    if (partnerAssistMap.containsKey(primaryConsent)) {
                        PRM_Partner_Assist_Consent__c updatePartnerList = new PRM_Partner_Assist_Consent__c();
                        updatePartnerList.Id = partnerAssistMap.get(primaryConsent).Id;
                        updatePartnerList.PRM_Start_Date_Dt__c = System.now();
                        updatePartnerList.PRM_End_Date_Dt__c = null;
                        updatePartnerList.PRM_Consent_Provided_Ind__c = true;
                        updatePartnerListRecord.add(updatePartnerList);
                    }
                }
                if (string.isBlank(partnerAssistSecoundry) && optIn == true) {
                    /*  if(partnerAssistMap.containsKey(secondaryConsent)){
PRM_Partner_Assist_Consent__c updatePartnerList = new  PRM_Partner_Assist_Consent__c();  
updatePartnerList.Id = partnerAssistMap.get(secondaryConsent).Id;                    
updatePartnerList.PRM_Start_Date_Dt__c = System.now();
updatePartnerList.PRM_End_Date_Dt__c = Null;
updatePartnerList.PRM_Consent_Provided_Ind__c = true;
updatePartnerListRecord.add(updatePartnerList);
} */
                    if (partnerAssistMap.containsKey(secondaryConsent)) {
                        PRM_Partner_Assist_Consent__c updatePartnerList = new PRM_Partner_Assist_Consent__c();
                        updatePartnerList.Id = partnerAssistMap.get(secondaryConsent).Id;
                        updatePartnerList.PRM_Consent_Provided_Ind__c = false;
                        updatePartnerList.PRM_End_Date_Dt__c = System.now();
                        updatePartnerListRecord.add(updatePartnerList);
                    }
                }
                
                if (!string.isBlank(partnerAssistPrimary)) {
                    if (
                        partnerAssistMap.containsKey(primaryConsent) &&
                        (partnerAssistMap.get(primaryConsent).PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c != partnerAssistPrimary ||
                         partnerAssistMap.get(primaryConsent).PRM_Consent_Provided_Ind__c == false)
                    ) {
                        id distributorId = getIdConsentDistrbutor(partnerAssistPrimary, userGeo);
                        if (distributorId != null) {
                            PRM_Partner_Assist_Consent__c updatePartnerList = new PRM_Partner_Assist_Consent__c();
                            updatePartnerList.Id = partnerAssistMap.get(primaryConsent).Id;
                            updatePartnerList.PRM_Distributor_Id__c = distributorId;
                            updatePartnerList.PRM_Start_Date_Dt__c = System.now();
                            updatePartnerList.PRM_End_Date_Dt__c = null;
                            updatePartnerList.PRM_Consent_Provided_Ind__c = true;
                            updatePartnerListRecord.add(updatePartnerList);
                        }
                    }
                }
                if (!string.isBlank(partnerAssistSecoundry)) {
                    if (
                        partnerAssistMap.containsKey(secondaryConsent) &&
                        (partnerAssistMap.get(secondaryConsent).PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c != partnerAssistSecoundry ||
                         partnerAssistMap.get(secondaryConsent).PRM_Consent_Provided_Ind__c == false)
                    ) {
                        PRM_Partner_Assist_Consent__c updatePartnerList = new PRM_Partner_Assist_Consent__c();
                        id distributorId = getIdConsentDistrbutor(partnerAssistSecoundry, userGeo);
                        if (distributorId != null) {
                            updatePartnerList.Id = partnerAssistMap.get(secondaryConsent).Id;
                            updatePartnerList.PRM_Distributor_Id__c = distributorId;
                            updatePartnerList.PRM_Start_Date_Dt__c = System.now();
                            updatePartnerList.PRM_End_Date_Dt__c = null;
                            updatePartnerList.PRM_Consent_Provided_Ind__c = true;
                            updatePartnerList.PRM_Consent_Provided_By_Id__c = ContactId;
                            updatePartnerListRecord.add(updatePartnerList);
                        }
                    }
                }
                if (!partnerAssistMap.containsKey(secondaryConsent) && !string.isBlank(partnerAssistSecoundry)) {
                    PRM_Partner_Assist_Consent__c insertPartnerAssist = new PRM_Partner_Assist_Consent__c();
                    id distributorId = getIdConsentDistrbutor(partnerAssistSecoundry, userGeo);
                    if (distributorId != null) {
                        insertPartnerAssist.PRM_Distributor_Id__c = distributorId;
                        insertPartnerAssist.PRM_Consent_Provided_Ind__c = true;
                        insertPartnerAssist.PRM_Consent_Provided_Date_Dt__c = System.now();
                        insertPartnerAssist.PRM_Start_Date_Dt__c = System.now();
                        insertPartnerAssist.PRM_End_Date_Dt__c = null;
                        insertPartnerAssist.PRM_Choice_Nm__c = secondaryConsent;
                        insertPartnerAssist.PRM_Consent_Provided_By_Id__c = ContactId;
                        insertPartnerAssist.PRM_Account_Id__c = AcctId;
                        insert insertPartnerAssist;
                    }
                }
                if (updatePartnerListRecord.size() > 0) {
                    update updatePartnerListRecord;
                }
                
                return true;
            } else {
                for (PRM_Partner_Assist_Consent__c partnerAssit : partnerAssistMap.values()) {
                    PRM_Partner_Assist_Consent__c updatePartnerList = new PRM_Partner_Assist_Consent__c();
                    updatePartnerList.Id = partnerAssit.Id;
                    updatePartnerList.PRM_Consent_Provided_Ind__c = false;
                    updatePartnerList.PRM_End_Date_Dt__c = System.now();
                    updatePartnerListRecord.add(updatePartnerList);
                }
                if (updatePartnerListRecord.size() > 0) {
                    update updatePartnerListRecord;
                }
                return true;
            }
        } catch (Exception ex) {
            //system.debug('Error Cause==>' + ex.getCause());
            //system.debug('Error Message==>' + ex.getMessage());
            //system.debug('Error StackTrace String==>' + ex.getStackTraceString());
            return false;
        }
    }
    //---------------------------------- Partner Assist ----------------------------------
    public static Id getIdConsentDistrbutor(String consentDistributor, String userGeo) {
        try {
            if (consentDistributor != null && !String.isBlank(consentDistributor) && userGeo != null && !String.isBlank(userGeo)) {
                PRM_Partner_Consent_Distributor__c consentDistributorRecord = [
                    SELECT Id, name, PRM_Country_Name__c, PRM_Geo_Nm__c, PRM_Sub_Region_Nm__c, PRM_Distributor_Name_Txt__c
                    FROM PRM_Partner_Consent_Distributor__c
                    WHERE PRM_Geo_Nm__c = :userGeo AND PRM_Distributor_Name_Txt__c = :consentDistributor
                    LIMIT 1
                ];
                if (consentDistributorRecord != null) {
                    return consentDistributorRecord.id;
                }
            }
            return null;
        } catch (Exception ex) {
            //system.debug('Error Cause==>' + ex.getCause());
            //system.debug('Error Message==>' + ex.getMessage());
            //system.debug('Error StackTrace String==>' + ex.getStackTraceString());
            return null;
        }
    }
    //----------------------------Partner Assist------------------------------------------
    
    
    public static Boolean CheckIfContactIsPrimary(Id contactID){
        boolean isPrimary=false;
        try{
            Contact cont = [
                SELECT
                id,
                AccountId,
                (SELECT Id,Core_Entitlement_Nm__c FROM Contact_Entitlements__r WHERE Core_Selected__c = TRUE AND Core_Type__c = :'Entitlement' AND Core_Status__c=:system.Label.PRM_PCREntitlement_Status),
                (SELECT Id, PRM_Relationship_Id__r.Name, PRM_Account_Id__r.Id FROM Account_Contact_Relationships__r where PRM_InActive_Ind__c=  
                 false AND PRM_Status_Nm__c=:system.Label.PRM_PCREntitlement_Status)
                FROM Contact
                WHERE Id =: contactID
            ]; 
            for (PRM_Account_Contact_Relationship__c acr : cont.Account_Contact_Relationships__r) {
                if (acr.PRM_Account_Id__r.Id == cont.AccountId && !isPrimary) {
                    isPrimary = (acr.PRM_Relationship_Id__r.Name == system.Label.PRM_PartnerAdmin_Rel || acr.PRM_Relationship_Id__r.Name == system.Label.PRM_PartnerAdminDelegate_Rel) ? true : false;
                }
            }
            if(isPrimary){
                isPrimary=false;
                for (Core_Contact_Entitlement__c ce : cont.Contact_Entitlements__r) {
                    if (ce.Core_Entitlement_Nm__c == System.label.PRM_PartnerAdmin_Rel || ce.Core_Entitlement_Nm__c == System.label.PRM_PartnerAdminDelegate_Rel)
                    {
                        isPrimary = true;
                        break;
                    }
                }
                
            }
            
        }catch (Exception ex) {
            //system.debug('Error Cause==>' + ex.getCause());
            //system.debug('Error Message==>' + ex.getMessage());
            system.debug('Error StackTrace String==>' + ex.getStackTraceString());
            
        }
        return isPrimary;
    }
    
    public static string[] getCountryStateName(string ctryCode,string stCode){
        string[] retCountryStateName= new string[2];
        List<PRM_AdminRegistration.StateCountryInfo> ctryStateInfo=PRM_AdminRegistration.fetchStateCountryValues();
        for(PRM_AdminRegistration.StateCountryInfo item : ctryStateInfo){
            if(item.Country.Split(';')[1]==ctryCode){
                retCountryStateName[0]=item.Country.Split(';')[0];
                if(item.stateList !=null && item.stateList.Size()>0){
                    for(string StateCode : item.stateList){
                        if(StateCode.Split(';')[1]==stCode){
                            retCountryStateName[1]=StateCode.Split(';')[0];
                            return retCountryStateName;
                        }
                    }
                    
                }
            }
        }
        return retCountryStateName;
    }
    /******************************************************************
    @Description: Enable a capability for IPA admins to upload documents against an 1PID or Account
    @Author: Shraddha M
    @UserStory: TWC729-3494, TWC729-3496 
    @date: 01/07/2022
    ************************************************************************/ 

    /**
     * @Description: to check if profile has access to upload document
     * @return : true if profile has access to upload document
     */
    @AuraEnabled
    public static Boolean showUploadedDoc(){
        Boolean profileCheck = false;
        List<String> profileLabelId = System.Label.PRM_Profile_Check.split(',');
        try{
            if(profileLabelId.contains(UserInfo.getProfileId())){
                    profileCheck = true;
            }
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }   
        return profileCheck;
    }
     /**
     * @Description: fetch documents of type terms and conditions
     * @return : list of documents
     */
    @AuraEnabled
    public static List<PRM_Documents__c> getTermsandConditions(){
        List<PRM_Documents__c> docList = new List<PRM_Documents__c>();
        try {
        User loggedInUser = [SELECT ContactId FROM User WHERE id = :UserInfo.getUserId()];
        Contact cont = [SELECT id, Name, AccountId FROM Contact WHERE Id = :loggedInUser.ContactId];
        Account acc = new Account();
            if(cont != null){
                acc = [SELECT id, Core_IPA_One_Partner_Id__c  FROM Account WHERE id=:cont.AccountId];
            }   
            if(acc.Core_IPA_One_Partner_Id__c != null) {
                docList = [select Id, Title__c, Document_Id__c, Account__c,Document_Type__c from PRM_Documents__c where Account__c=:acc.Core_IPA_One_Partner_Id__c and Document_Type__c='Terms and Conditions'];
            }
            if(docList.size() == 0 || acc.Core_IPA_One_Partner_Id__c == null) {
                docList = [select Id, Title__c, Document_Id__c, Account__c,Document_Type__c from PRM_Documents__c where Account__c=:acc.Id and Document_Type__c='Terms and Conditions'];
            }
        } 
        catch (Exception e) {
            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, SCOPE, SEVERITY, e.getMessage(), e.getStackTraceString(), '', '', '');
            throw new AuraHandledException(e.getMessage());
        }
        return docList;
    }
    /**
     * @Description: insert details of Uploaded documents for reference
     * @Parameters : list of documentwrapper, Id of account from where document uploaded
     * @return : true if inserted successfully
     */
    @AuraEnabled
    public static Boolean getUploadedTermsnCondition(List<documentWrapper> docArray, Id accId){
        Boolean insertSuccess = false;
        try {
            List<PRM_Documents__c> documentList = new List<PRM_Documents__c>();
            if(docArray.size()> 0){
                for(documentWrapper dr: docArray){
                    PRM_Documents__c dc = new PRM_Documents__c();
                    dc.Title__c = dr.title;
                    dc.Document_Id__c = dr.documentId;
                    dc.Account__c = accId;
                    dc.Document_Type__c = 'Terms and Conditions';
                    documentList.add(dc);
                }
            }
            if(documentList.size()>0){
                insert documentList;
            }
            insertSuccess = true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return insertSuccess;
    }
    
      public class documentWrapper{
        @AuraEnabled
        public String title{get;set;}
        @AuraEnabled
        public String documentId{get;set;}
      }
    
    public class CompanyInfoAndRoleDescWrapper {
        public CompanyInfoWrapper CompanyInfo { get; set; }
        //public List<RoleDescription> RoleDescriptions {set; get;}
    }
    public class CompanyInfoWrapper {
        public String Name { get; set; }
        public String NaturalGrouping { get; set; }
        public String Website { get; set; }
        public String Phone { get; set; }
        public String NDA { get; set; }
        public String AccountId { get; set; }
        public String ContactId { get; set; }
        public String PartnerRole { get; set; }
        public String PartnerRoleAPI { get; set; }
        public String OptInPoints { get; set; }
        public boolean isPrimary { get; set; }
        public Address MailingAddress { get; set; }
        public Address PhysicalAddress { get; set; }
        public Set<String> Specialties { get; set; }
        public Set<String> SelectBenefits { get; set; }
        public List<ProfileResponse> ProfileResponses { get; set; }
        public List<WhiteListWrapper> WhitelistedDomains { get; set; }
        public List<String> BlacklistDomains { get; set; }
        public PartnerAssistConcent PartnerAssistConcents { get; set; }
        public String AccountNumber { get; set; }
    }
    public class ProfileResponse {
        public String RecordId { get; set; }
        public String QuestionText { get; set; }
        public String QuestionCode { get; set; }
        public String ResponseText { get; set; }
    }
    public class Address {
        public String Street { get; set; }
        public String City { get; set; }
        public String State { get; set; }
        public String Country { get; set; }
        public String PostalCode { get; set; }
    }
    
    /*
public class RoleDescription {
public String PartnerRole {set; get;}
public String ShortDesc {set; get;}
public List<String> DescriptionItems {set; get;}
public String SupportURL {set; get;}
}
*/
    public class SecondaryContacts {
        public List<SecondaryContactWrapper> RegRequests { get; set; }
        public List<SecondaryContactWrapper> Contacts { get; set; }
    }
    public class SecondaryContactWrapper {
        public Id RecordId { get; set; }
        public String Name { get; set; }
        public String Email { get; set; }
        public String Phone { get; set; }
        public String Responsibilities { get; set; }
        public String Status { get; set; }
        public String EVStatus { get; set; }
        public Datetime EVVerificationDateTime { get; set; }
        public Boolean isLoggedinUser { get; set; }
        public Boolean isPrimary { get; set; }
        public String Relationship { get; set; }
        public boolean isApprove { get; set; }
    }
    
    public class LegalAgreementWrapper {
        public Id RecordId { get; set; }
        public String LegalAgreementName { get; set; }
        public String LegalAgreementSignedBy { get; set; }
        public Datetime LegalAgreementSignedDate { get; set; }
    }
    
    public class PartnerAssistConcent {
        public List<String> DistributerNames { get; set; }
        public List<PartnerAssist> PartnerAssists { get; set; }
    }
    
    public class PartnerAssist {
        public String PartnerAssistId { get; set; }
        public String DistributerName { get; set; }
        public boolean ConsentIndicator { get; set; }
    }
    
    public class WhiteListWrapper {
        public Id RecordId { get; set; }
        public String WhiteListName { get; set; }
    }
}