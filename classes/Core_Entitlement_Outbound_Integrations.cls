/*****************************************************************************************************************************************
    * Class Name  : Core_Entitlement_Outbound_Integrations
*
* Modification Log :
* Developer                 Date            Description
* ----------------------------------------------------------------------------
* Aran Wongsaprome          7/19/2017       Map contact salutation to the ERPM PersonTitle
* Aran Wongsaprome          8/18/2017       US77274 Fix exceptions from tag size overflow
* Aran Wongsaprome          8/22/2017       US71628 Related list of messages under contact
* Sugandha                  24/11/2017      US79061 Prevent Employee as Customer being sent to ERPM
* Rajesh Kumar              28/6/2018       US108564-For any Contacts entitled to RDC privileged access under this account, selection of this field prevents access to standard CNDA content but allows access to content specifically targeted to this account.
* Accenture-VD              23/7/2018       US99134 Stop Outbound messages to CIM and EPRM for Virtual Accounts
Updated Below Methods to stop creating OutBound message for Co-Marketing Record Type of Account
-generateBoxBAccountOutboundMessage
-generateOBMOnCIMUpdate
* ERPM Team                 26/6/2019       Additional changes to generateErpmOutboundMessage Method; Generate BlackBox API payload to suffice both B2B and IPA memberships
* Ruby Team                 23/10/2019      Commented Line #36 and uncommented Line #37 as a fix to include Marketing RT again by Ruby Team
* Draco Team                15/5/2020       Additional changes to generateErpmOutboundMessage Method; A&E 2.0 Enhance/Bypass ERPM
* Draco Team                15/5/2020       Additional changes to generateAgsOutboundMessage Method; A&E 2.0 Enhance AGS Flow
* Draco Team                19/8/2020       Additional/Remove changes to generateAgsOutboundMessage Method; A&E 2.0 Enhance AGS Flow
* Draco Team                18/6/2021       Added code to call AGS along with ERPM for fresh contact for A&E 2.o
* Draco Team                09/10/2021      Added condition cObj.Core_AGS_Integration_Status__c != 'Successful' in line 1104 to avoid sending AGS Outbound again if it is already successful
* Draco Team                22/10/2021      Added condition cObj.Core_AGS_Integration_Status__c != 'In-Progress' in line 1104 to avoid sending AGS Outbound again if it is already in progress
* Draco Team                01/02/2022      Don't change ERPM Integration Status in case of 2.0 flow - ERPM Bypass Logic
* Draco Team                07/07/2022      Added bug fix for AGS OBM tags mismatch in case of Data load [TWC1811-2597]
* Draco Team                07/07/2022      Added bug fix for ERPM OBM tags mismatch in case of Data load [TWC1811-2597]
* Draco Team                22/12/2022     Added logic to stop call to AGS due to ERPM By-pass logic upon Email change
* Draco Team                25/09/2023      Added logic to send only pending entitlement/role request & role operation in payload as a part of GetRole API EOL Changes
* Draco Team                20/11/2023      Added logic for Internal and External Entitlements processing and OBM Generation
*****************************************************************************************************************************************/

global without sharing class Core_Entitlement_Outbound_Integrations
{
    public static Boolean runOnce = false;
    public static Boolean hasRun = false;
    public static boolean subsFlowIntiated = false; //TWC729-3874
    public static boolean contactUpdate = false;
    //public static Boolean isCallOutboundMsg = true;  //Added by team Draco
    public static Set<String> cId  = new Set<String>();
    public static String logEntryMsgString='';
    public static String logEntryTags = '';  
    
    public static final String LOG_ENTRY_ORIGIN = 'SFDC';
    public static final String LOG_ENTRY_PROJECT = 'Entitlement';
    public static final String LOG_ENTRY_AGS_SCOPE = 'IntegrationInboundMessageAGS';
    public static final String LOG_ENTRY_ERPM_SCOPE = 'IntegrationInboundMessageERPM';
    public static final String LOG_ENTRY_BOXBACCOUNT_SCOPE = 'IntegrationInboundMessageBOXBACCOUNT';
    public static final String LOG_ENTRY_ERROR = 'error';
    public static final String LOG_ENTRY_INFO = 'info';
    public static final String LOG_ENTRY_OBJECT = 'Core_Integration_Outbound_Message__c';
    public Static String IPATier = '';
    public static map<string,boolean> mapOfContactActivatingACR=new map<string,boolean>();
    
    //public static Id coMarketingRecordTypeId = null;
    public static Id coMarketingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Core_MDF_Co_Marketing_Record_Type_Name).getRecordTypeId(); //Added by Accenture - VD -> Check if the record type is not Co-Marketing
    
    public static Id pAGRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId(); //Added by Accenture - US408340 -> Check if the record type is not Core_Partner_Account_Group
    
    public static Id DirectAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Direct Account').getRecordTypeId();// Added by Unicorn Team to bypass trigger methods 
    
    public static List<String> smartSplit(String longString, Integer maxPartLength) {
        Boolean done = false;
        List<String> partList = new List<String>();
        if(!String.isBlank(longString)) {
            String strRemaining = longString.trim();
            while(!done) {
                if (strRemaining.length() <= maxPartLength) {
                    done = true;
                    partList.add(strRemaining);
                } else {
                    String testChunk = strRemaining.substring(0, maxPartLength);
                    Integer splitLocation = testChunk.lastIndexOf(' ');
                    String selectedChunk = testChunk.substring(0, splitLocation);
                    strRemaining = strRemaining.substring(splitLocation+1);
                    partList.add(selectedChunk);
                }
            }
        } else {
            return null;
        }
        return partList;
    }
    public static String getISO2CountryCode (String countrycode) {
        List<Core_Country_Code_Mapping__c> lcs = Core_Country_Code_Mapping__c.getall().values();
        
        if(lcs != null && lcs.size() > 0) {
            for(Core_Country_Code_Mapping__c cs : lcs) {
                if(cs.ISO_Code__c == countrycode) {
                    return cs.Country_Code__c;
                }
            }
            return null;
        } else {
            return null;
        }
    }
    public static void generateAgsOutboundMessage(List<Contact> lstcontactsWithAGSPending) {
        List<Core_Integration_Outbound_Message__c> lstOutboundMsg = new List<Core_Integration_Outbound_Message__c>();
        List<Core_Contact_Entitlement__c> lstContactEnt = new List<Core_Contact_Entitlement__c>();
        List<Core_Contact_Entitlement__c> lstContEnt = new List<Core_Contact_Entitlement__c>();
        Set<Id> setConIdExternalEnt = new Set<Id>();
        Set<Id> setConIdInternalEnt = new Set<Id>();
        Set<Id> onlyInternalEntPendingContacts = new Set<Id>();
        //String strJSON; // added by team Draco
        Id currentContactId;  //added by popcorn
        String tags = '';
        
        try {
            if(lstcontactsWithAGSPending != null && !lstcontactsWithAGSPending.isEmpty()) {
                lstContEnt = [SELECT id, Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c, Core_Entitlement_Id__r.Entitlement_B2B_B2C_Indicator__c, Core_Entitlement_Id__r.Core_Entitlement_Type__c,
                              Core_Contact_Id__c, Core_Selected__c, Core_Entitlement_Id__r.Core_AGS_Role_Id__c, Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__c,Core_Status__c
                              FROM Core_Contact_Entitlement__c
                              WHERE Core_Contact_Id__c IN :lstcontactsWithAGSPending AND Core_Entitlement_Id__r.Core_AGS_Role_Id__c != null];
            }
            
            Map<String, ContactWithConEntDetail> mapContactWithConEnt = new Map<String, ContactWithConEntDetail>();
            
            for(Core_Contact_Entitlement__c ce : lstContEnt){
                if(!mapContactWithConEnt.containsKey(ce.Core_Contact_Id__c)){
                    mapContactWithConEnt.put(ce.Core_Contact_Id__c, new ContactWithConEntDetail(ce.Core_Contact_Id__c));
                }
                if(ce.Core_Status__c == 'Pending' && (ce.Core_Entitlement_Id__r.Core_Entitlement_Type__c == 'AGS' || String.isBlank(ce.Core_Entitlement_Id__r.Core_Entitlement_Type__c ))) {
                    setConIdExternalEnt.add(ce.Core_Contact_Id__c);
                    if(ce.Core_Selected__c == true && ce.Core_Entitlement_Id__r.Entitlement_B2B_B2C_Indicator__c == 'B2B'){
                        mapContactWithConEnt.get(ce.Core_Contact_Id__c).pendingRoles.add(new pendingRoles(ce.Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c, ce.Core_Entitlement_Id__r.Entitlement_B2B_B2C_Indicator__c, 'AddRole'));
                    }
                    else if(ce.Core_Selected__c == true && ce.Core_Entitlement_Id__r.Entitlement_B2B_B2C_Indicator__c == 'B2C'){
                        mapContactWithConEnt.get(ce.Core_Contact_Id__c).pendingRoles.add(new pendingRoles(ce.Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c, ce.Core_Entitlement_Id__r.Entitlement_B2B_B2C_Indicator__c, 'AddGroup'));
                    }
                    else if(ce.Core_Selected__c == false && ce.Core_Entitlement_Id__r.Entitlement_B2B_B2C_Indicator__c == 'B2B'){
                        mapContactWithConEnt.get(ce.Core_Contact_Id__c).pendingRoles.add(new pendingRoles(ce.Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c, ce.Core_Entitlement_Id__r.Entitlement_B2B_B2C_Indicator__c, 'RemoveRole'));
                    }
                    else if(ce.Core_Selected__c == false && ce.Core_Entitlement_Id__r.Entitlement_B2B_B2C_Indicator__c == 'B2C'){
                        mapContactWithConEnt.get(ce.Core_Contact_Id__c).pendingRoles.add(new pendingRoles(ce.Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c, ce.Core_Entitlement_Id__r.Entitlement_B2B_B2C_Indicator__c, 'RemoveGroup'));
                    }                   
                } else if (ce.Core_Status__c == 'Pending' && ce.Core_Entitlement_Id__r.Core_Entitlement_Type__c == 'Salesforce'){
                    setConIdInternalEnt.add(ce.Core_Contact_Id__c);
                }
            }
            
            // --- [START] --- Check if ONLY Internal Entitlements are Pending. If YES, then check for existance of user record and assign the Entitlements.
            for(Contact c : lstcontactsWithAGSPending){
                if(!setConIdExternalEnt.contains(c.Id) && setConIdInternalEnt.contains(c.Id)){
                    onlyInternalEntPendingContacts.add(c.Id);
                    
                }
            }
            List<User> userListInterEntContacts = new List<User>();
            Map<Id, Boolean> InternalContWithUser = new Map<Id, Boolean>();
            List<Core_Contact_Entitlement__c> CEtoUpdate = new List<Core_Contact_Entitlement__c>();
            Set <Contact> lstInterContactsAGSUpdate = new Set <Contact>();
            if (onlyInternalEntPendingContacts != null && !onlyInternalEntPendingContacts.isEmpty()){
                userListInterEntContacts = [SELECT Id, ContactId, IsActive FROM User WHERE ContactId IN :onlyInternalEntPendingContacts];
                  
                for(User usr : userListInterEntContacts){
                    InternalContWithUser.put(usr.ContactId, usr.IsActive);
                      
                }
            }
            
            /* Following cases will be considered as Successful and Failed:
            IF: Just Internal Entitlements are Pending AND
                CASE 1.1: Successful Assignment/Removal --> If the User record is there and is Active
                CASE 1.2: Successful Removal --> If User record is there and is InActive, but Entitlement is for Removal
                CASE 1.3: Successful Removal --> If User record is not there, but Entitlement is for Removal
            ELSE IF: Just Internal Entitlements are Pending AND 
                CASE 2.1: Failed Assignemnt --> If User record is there and is InActive and Entitlement is for Assignment
            ELSE IF: Just Internal Entitlements are Pending AND 
                CASE 3.1: Failed Assignemnt --> If User record is not there and Entitlement is for Assignment
            */
            Set<Id> successfulContacts = new Set<Id>();
            Set<Id> failedContacts = new Set<Id>();
            Set<Id> allContactsSet = new Set<Id>();
            for(Core_Contact_Entitlement__c ce : lstContEnt){
                if((onlyInternalEntPendingContacts.contains(ce.Core_Contact_Id__c) && ce.Core_Status__c == 'Pending' && ce.Core_Entitlement_Id__r.Core_Entitlement_Type__c == 'Salesforce') && 
                ((InternalContWithUser.containsKey(ce.Core_Contact_Id__c) && InternalContWithUser.get(ce.Core_Contact_Id__c)) ||
                (InternalContWithUser.containsKey(ce.Core_Contact_Id__c) && !InternalContWithUser.get(ce.Core_Contact_Id__c) && !ce.Core_Selected__c) ||
                (!InternalContWithUser.containsKey(ce.Core_Contact_Id__c) && !ce.Core_Selected__c))){
                    ce.Core_Status__c = 'Complete';
                    ce.Core_Update_Reason__c='';
                    if(ce.Core_Selected__c){
                        ce.Core_Status_of_Assignment_Failure__c = 'Successful Assignment';
                        //ce.Core_Contact_Id__r.Core_Entitlement_Assignment_Status__c = 'Successful';
                        //ce.Core_Contact_Id__r.Core_Entitlement_Assignment_Message__c = ce.Core_Display_Nm__c +'Operation Successful'+ 'Timestamp: ' + System.now() + ' GMT';
                    } else {
                        ce.Core_Status_of_Assignment_Failure__c = 'Successful Removal';
                        //ce.Core_Contact_Id__r.Core_Entitlement_Assignment_Status__c = 'Successful';
                        //ce.Core_Contact_Id__r.Core_Entitlement_Assignment_Message__c = ce.Core_Display_Nm__c +'Operation Successful'+ 'Timestamp: ' + System.now() + ' GMT';
                    }
                    CEtoUpdate.add(ce);
                    //lstInterContactsAGSUpdate.add(new Contact(Id = ce.Core_Contact_Id__c, Core_AGS_Integration_Status__c = 'Successful'));
                    successfulContacts.add(ce.Core_Contact_Id__c);
                } else if(onlyInternalEntPendingContacts.contains(ce.Core_Contact_Id__c) && ce.Core_Status__c == 'Pending' && ce.Core_Selected__c && InternalContWithUser.containsKey(ce.Core_Contact_Id__c) && !InternalContWithUser.get(ce.Core_Contact_Id__c) && ce.Core_Entitlement_Id__r.Core_Entitlement_Type__c == 'Salesforce'){
                    ce.Core_Status__c = 'Complete';
                    ce.Core_Selected__c = false;
                    ce.Core_Status_of_Assignment_Failure__c = 'Failed Assignment';
                    ce.Core_Update_Reason__c='User record Inactive';
                    CEtoUpdate.add(ce);
                    //lstInterContactsAGSUpdate.add(new Contact(Id = ce.Core_Contact_Id__c, Core_AGS_Integration_Status__c = 'Failed', Core_AGS_Integration_Message__c = 'User record Inactive while assigning Internal Entitlements'));
                    failedContacts.add(ce.Core_Contact_Id__c);
                } else if(onlyInternalEntPendingContacts.contains(ce.Core_Contact_Id__c) && ce.Core_Status__c == 'Pending' && ce.Core_Selected__c && !InternalContWithUser.containsKey(ce.Core_Contact_Id__c) && ce.Core_Entitlement_Id__r.Core_Entitlement_Type__c == 'Salesforce'){
                    ce.Core_Status__c = 'Complete';
                    ce.Core_Selected__c = false;
                    ce.Core_Status_of_Assignment_Failure__c = 'Failed Assignment';
                    ce.Core_Update_Reason__c='User record not Available';
                    CEtoUpdate.add(ce);
                    //lstInterContactsAGSUpdate.add(new Contact(Id = ce.Core_Contact_Id__c, Core_AGS_Integration_Status__c = 'Failed', Core_AGS_Integration_Message__c = 'User record not available while assigning Internal Entitlements'));
                    failedContacts.add(ce.Core_Contact_Id__c);
                }
            }
            allContactsSet.addAll(successfulContacts);
            allContactsSet.addAll(failedContacts);
            for(Id conId : allContactsSet){
                if(failedContacts.contains(conId)){
                    lstInterContactsAGSUpdate.add(new Contact(Id = conId, Core_Entitlement_Assignment_Status__c = 'Failed', Core_Entitlement_Assignment_Message__c = 'User record InActive or Not Available while assigning Internal Entitlements' + 'Timestamp: ' + System.now() + ' GMT'));
                } else{
                    lstInterContactsAGSUpdate.add(new Contact(Id = conId, Core_Entitlement_Assignment_Status__c = 'Successful', Core_Entitlement_Assignment_Message__c = 'Operation Successful' + 'Timestamp: ' + System.now() + ' GMT'));
                }
            }
            
            if (CEtoUpdate != null && !CEtoUpdate.isEmpty()){
                update CEtoUpdate;
            }
            
            // --- [END] --- Check if ONLY Internal Entitlements are Pending. If YES, then check for existance of user record and assign the Entitlements.
            
            Map<id,Core_Integration_Outbound_Message__c> mapMsg = new Map<id,Core_Integration_Outbound_Message__c>();
            List <Contact> lstContactsInProgress = new List <Contact> ();
            Map<String,String> lstCountryPhonePrefixMapping = new Map<String,String>();
            List<Core_Country_Phone_Prefix_Mapping__c>countryPhonePrefix=[SELECT Id, Core_Country_Name__c, Core_Phone_Prefix__c, Core_Country_Code__c FROM Core_Country_Phone_Prefix_Mapping__c];
            for(Core_Country_Phone_Prefix_Mapping__c rec:countryPhonePrefix){
                lstCountryPhonePrefixMapping.put(rec.Core_Country_Code__c,rec.Core_Phone_Prefix__c);
            }
            for(Contact c : lstcontactsWithAGSPending){
                if(!cId.contains(c.Id) && setConIdExternalEnt.contains(c.Id)){
                    currentContactId = c.Id;
                    cId.add(c.Id);
                    // Build up tags for log entry
                    if (!String.isBlank(c.Core_eRPM_Person_Id__c))
                        tags += addTag(c.Core_eRPM_Person_Id__c);
                    if (!String.isBlank(c.Core_Enterprise_Id__c))
                        tags += addTag(c.Core_Enterprise_Id__c);
                    /*if (!String.isBlank(cObj.Core_Login_Id__c)) //Draco Commented deprecating attributes
tags += addTag(cObj.Core_Login_Id__c);*/
                    if (!String.isBlank(c.Email))
                        tags += addTag(c.Email);
                    if (!String.isBlank(c.Id))
                        tags += addTag(c.Id);
                    
                    Core_Integration_Outbound_Message__c outboundMsg = new Core_Integration_Outbound_Message__c();
                    //String strcontLoginId = (c.Core_Login_Id__c == null) ? c.Email : c.Core_Login_Id__c;
                    ContactWithConEntDetail conWithConEnt = mapContactWithConEnt.get(c.Id);
                    
                    // Pass Country Code, Language and Phone numbers as required by B2C account creation
                    String countryForAgsOBM = c.MailingCountry != null ? c.MailingCountry : c.Core_Account_Primary_Country__c;
                    String CountryCodeISO2 = getISO2CountryCode(countryForAgsOBM) != null ? getISO2CountryCode(countryForAgsOBM) : countryForAgsOBM;
                    String LanguageCodeISO4 = '';
                    List<Core_IAM_Microservice_Language_Code__mdt> lstLanguageCodes = Core_IAM_Microservice_Language_Code__mdt.getAll().values();
                    for(Core_IAM_Microservice_Language_Code__mdt langCode : lstLanguageCodes){
                        if(langCode.Core_ISO_3_Language_Code__c == c.Core_Preferred_Language__c){
                            LanguageCodeISO4 = langCode.B2C_Code__c;
                        }
                    }
                    if(LanguageCodeISO4 == ''){
                        LanguageCodeISO4 = 'en-US';
                    }
                    
                    String PhoneNumber = null;
                    if(c.Phone != null){
                        PhoneNumber = c.Phone;
                    } else if(c.MobilePhone != null){
                        PhoneNumber = c.MobilePhone;
                    } else{
                        PhoneNumber = null; //Passing null as phone number is not there for the contact
                    }
                    
                    String PhoneNumberPrefix = null;
                    if(c.Core_Account_Primary_Country__c != null){
                        // List<Core_Country_Phone_Prefix_Mapping__c> lstCountryPhonePrefix = new List<Core_Country_Phone_Prefix_Mapping__c>([SELECT Id, Core_Country_Name__c, Core_Phone_Prefix__c, Core_Country_Code__c FROM Core_Country_Phone_Prefix_Mapping__c WHERE Core_Country_Code__c =: c.Core_Account_Primary_Country__c]);
                         
                        if(lstCountryPhonePrefixMapping.get(c.Core_Account_Primary_Country__c) != null && PhoneNumber != null){
                            PhoneNumberPrefix = lstCountryPhonePrefixMapping.get(c.Core_Account_Primary_Country__c);
                        } else{
                            PhoneNumberPrefix = null;
                        }
                    }
                     
                    
                    // AGS_Outbound_Msg_Wrapper2 agsOMW2 = new AGS_Outbound_Msg_Wrapper2(c.Core_Enterprise_Id__c, Label.Core_Contact_Ent_AGS_Justification, c.FirstName, c.LastName, c.Email, (c.Core_Preferred_Language__c == null) ? 'ENG' : c.Core_Preferred_Language__c, B2CLanguageCode, c.Core_Account_Primary_Country__c, CountryCodeISO2, PhoneNumberPrefix, PhoneNumber, (c.Core_Login_Id__c == null) ? c.Email : c.Core_Login_Id__c);
                    AGS_Outbound_Msg_Wrapper2 agsOMW2 = new AGS_Outbound_Msg_Wrapper2(c.Core_Enterprise_Id__c, Label.Core_Contact_Ent_AGS_Justification, c.FirstName, c.LastName, c.Email, (c.Core_Preferred_Language__c == null) ? 'en-US' : LanguageCodeISO4, /*B2CLanguageCode, c.Core_Account_Primary_Country__c,*/  CountryCodeISO2, PhoneNumberPrefix, PhoneNumber /*c.Email*/);                    
                    //agsOMW2.roles = conWithConEnt.roles;
                    agsOMW2.InProgressRoles = conWithConEnt.InProgressRoles;
                    agsOMW2.roleRequests = conWithConEnt.roleRequests;
                    agsOMW2.pendingRoles = conWithConEnt.pendingRoles;
                     
                    
                    //strJSON = JSON.serialize(agsOMW2);
                    outboundMsg.Core_MessageType__c = 'AGS Contact Entitlement 2.0';
                    outboundMsg.Core_Payload__c = '<![CDATA[' +  JSON.serialize(agsOMW2) + ']]>';
                    outboundMsg.Core_Tags__c = tags == null || tags.length() <= 255 ? tags : tags.substring(0, 255);
                    lstOutboundMsg.add(outBoundMsg);
                     
                    //Contact cTemp = new Contact(id = c.Id, Core_AGS_Integration_Status__c = 'In-Progress');
                    lstContactsInProgress.Add(new Contact(id = c.Id, Core_AGS_Integration_Status__c = 'In-Progress',Core_Entitlement_Assignment_Status__c = 'Pending'));
                    mapMsg.put(c.Id, outBoundMsg);
                    tags = ''; // DRACO CHANGE [07/07/2022] ---- Added bug fix for AGS OBM tags mismatch in case of Data load [TWC1811-2597]
                    
                    //------------------------------- Draco changes for A&E 2.0 :: END --------------------------------------//
                }
            }
            if(lstOutboundMsg != null && lstOutboundMsg.size()>0) {
                 insert lstOutboundMsg;
                
                // Add contact message entries for each of the messages
                List<Contact_Message__c> lstContactMsg = new List<Contact_Message__c>();
                  for(Id cid : mapMsg.keySet())
                      lstContactMsg.add(new Contact_Message__c(Contact__c = cid, Outbound_Message__c = mapMsg.get(cid).id));
                insert lstContactMsg;
            }
            if(!lstInterContactsAGSUpdate.isEmpty()){
                lstContactsInProgress.addall(lstInterContactsAGSUpdate);
                 
            }
            if (!lstContactsInProgress.isEmpty())
                 update lstContactsInProgress;
            
        } catch(Exception ex) {
            String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
          
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_AGS_SCOPE, LOG_ENTRY_ERROR,
                                                 'Error generating AGS OBM', '', currentContactId, LOG_ENTRY_OBJECT, tags, ex);
        }
    }
    
    
    
    // Determine the correct EPRM value for the given salutation
    public static Core_Entitlement_Salutation_PrsTitle_Map__c[] SalutationMap;
    public static String getPersonTitle(String Salutation) {
        if(SalutationMap == null) SalutationMap = Core_Entitlement_Salutation_PrsTitle_Map__c.getall().values();
        String Result = null;
        if(!SalutationMap.isEmpty())
            for(Core_Entitlement_Salutation_PrsTitle_Map__c M : SalutationMap)
            if(M.Salutation__c == Salutation) { Result = M.PersonTitle__c; break; }
        return Result;
    }
    
    private static List<Core_Contact_Email_Notification_Disabler__mdt> emailDisablerRuleRecords = new List<Core_Contact_Email_Notification_Disabler__mdt>();
    private static Map<String, Core_Contact_Email_Notification_Disabler__mdt> mapEmailDisablerRuleRecords = new Map<String, Core_Contact_Email_Notification_Disabler__mdt>();
    
    
    
    
    
    //Get the list of contact subscriptions for generate payload to eRPM
    //private static List<Subscription> GetSubscriptions(Id contactId)
    private static List<Subscription> GetSubscriptions(Contact cont)
    {
        List<Subscription> psnSub = new List<Subscription>();
        
        for(PRM_ContactSubscriptionAssociation__c contSub : cont.Contact_Subscription_Associations__r )
        {
            Subscription psnSubscription = new Subscription();
            psnSubscription.SubscriptionCode = contSub.PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c;
            psnSubscription.SubscriptionName = contSub.PRM_Partner_Subscription_Id__r.Name;
            //if(cont.Core_Sales_Do_Not_Contact_Ind__c)
            if(cont.Core_Do_Not_Contact__c)//Gireesh:US942207//uncommented:US959755
            {
                psnSubscription.SubscriptionStatusCode = 'USER-UNSUB';
            }
            else
            {
                psnSubscription.SubscriptionStatusCode = contSub.PRM_Status_Nm__c == 'Active' ? 'USER-SUB' :'USER-UNSUB';
            }
            psnSubscription.UnSubscriptionReason = contSub.PRM_Status_Reason_Txt__c;
            psnSub.add(psnSubscription);
        }
        
        
        return psnSub;
    }
    
    //Commenting to Stop IPA Account Flow to ERPM (Mainly CSP & DSN) -GetProfileResponses - hsk
    /*
//Get the list of profie reponses for generate payload to eRPM wrt AccountType as CSP
private static List<Response> GetProfileResponses(Id accountId)
{
List<Response> responses = new List<Response>();
for(PRM_Profile_Responses__c prflResponse : [SELECT PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,PRM_Response_Txt__c,PRM_Account_Id__r.Core_Account_Type__c
FROM PRM_Profile_Responses__c
WHERE PRM_Profile_Questions_Id__r.PRM_Channel_Program_Id__r.PRM_programCode__c =: Label.PRM_IPAEngagement
AND PRM_Account_Id__r.Core_Account_Type__c INCLUDES ('Cloud Service Provider (CSP)')
AND PRM_Account_Id__c =: accountId
AND PRM_InActive_Ind__c = false]){
Response prflResponses = new Response();
prflResponses.QuestionCode = prflResponse.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c;
prflResponses.ResponseCode = prflResponse.PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c;
prflResponses.ResponseValue = prflResponse.PRM_Response_Txt__c;
prflResponses.EngagementCode = Label.PRM_CSPx2EngagementCode;
responses.add(prflResponses);

}

return responses;
}    */
    
    // ----------- #REGION :: eRPM Code Changes :: END ------------- //
    
    /*****************************************************************************************************
Method Name:                                             generateBoxBAccountOutboundMessage
@return  :                                               Void
Modified By:                            Date:            Changes:
Accenture – VD                          07/23/2018       US99134 - Updated Method to stop creating OutBound message for Co-Marketing Record Type of Account
******************************************************************************************************/
    public static void generateBoxBAccountOutboundMessage(List<Account> lNewAccounts, Map<Id, Account> lOldAccounts) {
        Set<Id> sAcctIds = new Set<Id>();
        List<Core_Integration_Outbound_Message__c> lOutboundMsg = new List<Core_Integration_Outbound_Message__c>();
        List<BoxB_AccountWrapper> boxBAccounts = new List<BoxB_AccountWrapper>();
        Id currentAccountId;
        String tags = '';
        try {
            if(lNewAccounts != null && lNewAccounts.size() >0) {
                for(Account acctObj : lNewAccounts)
                {   //Start of Changes - To check if the record type is not Core_Partner_Account_Group - US408340 - by Accenture
                    if(acctObj.RecordTypeId != coMarketingRecordTypeId && acctObj.RecordTypeId != pAGRecordTypeId && acctObj.RecordTypeId != DirectAccRecTypeId) //Added by Accenture - VD -> Check if the record type is not Co-Marketing
                        //End of Changes - To check if the record type is not Core_Partner_Account_Group - US408340 - by Accenture
                    {
                        // Save Account Id for log entry
                        currentAccountId = acctObj.Id;
                        
                        // Build up tags for log entry
                        if (!String.isBlank(acctObj.Id))
                            tags += addTag(acctObj.Id);
                        if (!String.isBlank(acctObj.Name))
                            tags += addTag(acctObj.Name);
                        if (!String.isBlank(acctObj.Core_CIM_ID__c))
                            tags += addTag(acctObj.Core_CIM_ID__c);
                        
                        if((acctObj.Core_Account_Legal_Name__c != lOldAccounts.get(acctObj.Id).Core_Account_Legal_Name__c
                            || acctObj.BillingAddress != lOldAccounts.get(acctObj.Id).BillingAddress
                            || acctObj.Core_Geo__c != lOldAccounts.get(acctObj.Id).Core_Geo__c
                            || acctObj.Name != lOldAccounts.get(acctObj.Id).Name
                            || acctObj.Core_English_Only_Name__c != lOldAccounts.get(acctObj.Id).Core_English_Only_Name__c
                            || acctObj.Core_CNDA_Number__c != lOldAccounts.get(acctObj.Id).Core_CNDA_Number__c
                            || acctObj.Core_Deactivated__c != lOldAccounts.get(acctObj.Id).Core_Deactivated__c
                            || acctObj.Core_B2B_Entitlement__c != lOldAccounts.get(acctObj.Id).Core_B2B_Entitlement__c)
                           && acctObj.Core_B2B_Entitlement__c == true) {
                               
                               BoxB_AccountWrapper baw = new BoxB_AccountWrapper();
                               baw.ACCT_ID = acctObj.Id;
                               baw.ORG_MSTR_NM = acctObj.Core_Account_Legal_Name__c;
                               baw.CTRY_CD = getISO2CountryCode(acctObj.BillingCountry);
                               baw.GEO_NM = acctObj.Core_Geo__c;
                               baw.ACCT_NM = acctObj.Name;
                               baw.ACCT_ENG_NM = acctObj.Core_English_Only_Name__c;
                               baw.RIALTO_ROL_ID = 'N/A';
                               baw.RIALTO_ROL_NM = 'N/A';
                               baw.CITR_ID = acctObj.Core_CNDA_Number__c;
                               baw.PROF_ORG_TY_CD = 'EXTRNORG';
                               if(acctObj.Core_Deactivated__c) {
                                   baw.INACT_IND = 'Y';
                               } else {
                                   baw.INACT_IND = 'N';
                               }
                               baw.CREATE_DT = acctObj.CreatedDate;
                               baw.CHANGE_DT = acctObj.LastModifiedDate;
                               baw.CIMID = acctObj.Core_CIM_ID__c;
                               baw.CIMID_OLD = acctObj.Core_CIM_ID_Old__c;
                               baw.CNDA_NBR = acctObj.Core_CNDA_Number__c;
                               baw.ACCT_RDC =acctObj.Core_RDC_Content_Restriction__c; //US108564-Added  RDC Content Restriction flag added to accounts,The prevent access to standard CNDA content for contacts on the account.
                               String strJSON = JSON.serialize(baw);
                               Core_Integration_Outbound_Message__c outboundMsg = new Core_Integration_Outbound_Message__c();
                               outboundMsg.Core_MessageType__c = 'BoxB Account';
                               outboundMsg.Core_Payload__c ='<![CDATA[' +  strJSON + ']]>';
                               outboundMsg.Core_Tags__c = tags == null || tags.length() <= 255 ? tags : tags.substring(0, 255);
                               
                               lOutboundMsg.add(outboundMsg);
                           }
                    }
                }
                if(lOutboundMsg != null && lOutboundMsg.size() > 0) {
                    insert lOutboundMsg;
                }
            }
        } catch(Exception ex) {
            String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
            
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_BOXBACCOUNT_SCOPE, LOG_ENTRY_ERROR,
                                                 'Error generating BoxB Account OBM', '', currentAccountId, LOG_ENTRY_OBJECT, tags, ex);
        }
    }
    /*****************************************************************************************************
Method Name:                                             generateOBMOnCIMUpdate
@return  :                                               Void
Modified By:                            Date:            Changes:
Accenture – VD                          07/23/2018       US99134 - Updated Method to stop creating OutBound message for Co-Marketing Record Type of Account
******************************************************************************************************/
    //Commented lines to avoid Account Flow to ERPM for IPA Accounts (mainly CSP & DSN enggs) - hsk
    public static void generateOBMOnCIMUpdate(List<Account> lNewAccounts, Map<Id, Account> lOldAccounts) {
         
        List<Contact> contactsToUpdate = new List<Contact>();
        Set<Id> CIMUpdatedAcctIds = new Set<Id>();
        if(!runOnce)
        {
            //Added to resolve PMD Scan issue fix.
            Map<Id,Contact> acctIdContactMap = new Map<Id,Contact>();
            if(lOldAccounts != null && !lOldAccounts.isEmpty() ){
                for(Contact cont: [SELECT id, Core_ERPM_Integration_Status__c, Core_Contact_B2B_Indicator__c, AccountId
                                   FROM Contact WHERE AccountId IN :lOldAccounts.keySet()
                                   AND Core_Contact_B2B_Indicator__c = true]){
                                       //OR Core_IPA_PartnerRole__c = 'Service Provider')]){
                                       
                                       //Commented lines to avoid Account Flow to ERPM for IPA Accounts (mainly CSP & DSN enggs) - hsk
                                       //,(SELECT Id FROM Account_Contact_Relationships__r WHERE PRM_Status_Nm__c='Complete')
                                       if(!acctIdContactMap.containsKey(cont.AccountId) && (cont.Core_Contact_B2B_Indicator__c )){
                                           //|| cont.Account_Contact_Relationships__r.size() > 0)
                                           acctIdContactMap.put(cont.AccountId, cont);
                                       }
                                   }
            }
            for(Account acctObj : lNewAccounts)
            {
                
                //Added by Naresh
                if(acctObj.Core_Intel_Partner_Alliance_PartnerGroup__c && String.isEmpty(lOldAccounts.get(acctObj.Id).Core_CIM_ID__c) && acctObj.Core_CIM_ID__c != lOldAccounts.get(acctObj.Id).Core_CIM_ID__c){
                    CIMUpdatedAcctIds.add(acctObj.Id);
                }
                
                //Start of Changes - To check if the record type is not Core_Partner_Account_Group - US408340 - by Accenture
                if(acctObj.RecordTypeId != coMarketingRecordTypeId && acctObj.RecordTypeId != pAGRecordTypeId && acctObj.RecordTypeId != DirectAccRecTypeId) //Added by Accenture - VD -> Check if the record type is not Co-Marketing
                    //End of Changes - To check if the record type is not Core_Partner_Account_Group - US408340 - by Accenture
                {
                     
                    if((acctIdContactMap.containsKey(acctObj.Id)) && (acctObj.Core_B2B_Entitlement__c == true )
                       // || (acctObj.Core_Account_Type__c!=null && acctObj.Core_Account_Type__c.Contains(Label.PRM_Cloud_Service_Provider_CSP)))
                       && (acctObj.Core_Account_Legal_Name__c != lOldAccounts.get(acctObj.Id).Core_Account_Legal_Name__c
                           || acctObj.BillingCity != lOldAccounts.get(acctObj.Id).BillingCity
                           || acctObj.BillingCountry != lOldAccounts.get(acctObj.Id).BillingCountry
                           || acctObj.BillingState != lOldAccounts.get(acctObj.Id).BillingState
                           || acctObj.BillingPostalCode != lOldAccounts.get(acctObj.Id).BillingPostalCode
                           || acctObj.BillingStreet != lOldAccounts.get(acctObj.Id).BillingStreet
                           
                           || acctObj.ShippingCity != lOldAccounts.get(acctObj.Id).ShippingCity
                           || acctObj.ShippingCountry != lOldAccounts.get(acctObj.Id).ShippingCountry
                           || acctObj.ShippingState != lOldAccounts.get(acctObj.Id).ShippingState
                           || acctObj.ShippingPostalCode != lOldAccounts.get(acctObj.Id).ShippingPostalCode
                           || acctObj.ShippingStreet != lOldAccounts.get(acctObj.Id).ShippingStreet
                           
                           || acctObj.Name != lOldAccounts.get(acctObj.Id).Name
                           || acctObj.Core_CIM_ID__c != lOldAccounts.get(acctObj.Id).Core_CIM_ID__c
                           //Commented lines to avoid Account Flow to ERPM for IPA Accounts (mainly CSP & DSN enggs) - hsk
                           /* || acctObj.Core_User_Defined_Number_of_Employees__c != lOldAccounts.get(acctObj.Id).Core_User_Defined_Number_of_Employees__c
|| acctObj.Core_User_Defined_Phone_Number__c != lOldAccounts.get(acctObj.Id).Core_User_Defined_Phone_Number__c
|| acctObj.Core_User_Defined_Website__c != lOldAccounts.get(acctObj.Id).Core_User_Defined_Website__c*/
                           || acctObj.Core_English_Only_Name__c != lOldAccounts.get(acctObj.Id).Core_English_Only_Name__c)) {
                              
                               
                               Contact lCont = acctIdContactMap.containsKey(acctObj.Id) ? acctIdContactMap.get(acctObj.Id) : null ;
                               // TO check if the contact has atleast one relationship
                               if(lCont != null && (lCont.Core_Contact_B2B_Indicator__c )){
                                   //Commented lines to avoid Account Flow to ERPM for IPA Accounts (mainly CSP & DSN enggs) - hsk
                                   // || GetContactRelationship(lCont.Id,acctObj.id).relationshipCollection.size() > 0)) {
                                   //eRPM trigger logic - atb
                                   contactsToUpdate.add(new Contact(id=lCont.id
                                                                    //, Core_ERPM_Integration_Status__c='Pending'
                                                                   ));
                               }
                               
                           }
                }
            }
            runOnce = true;
            
            if(CIMUpdatedAcctIds.size() > 0) {
                Core_ERPM_Outbound_Integration.updateContIPAIntStsOnCIMChange = true;
                Core_ERPM_Outbound_Integration.contactsToUpdateOnCIMChange = [SELECT id, PRM_IPA_Integration_Status__c from Contact WHERE AccountId IN :CIMUpdatedAcctIds AND PRM_IPA_Integration_Status__c!=null AND PRM_IPA_Integration_Status__c!='Pending'];
                
            }
            
            if(contactsToUpdate != null && (contactsToUpdate.size()>0 || Core_ERPM_Outbound_Integration.contactsToUpdateOnCIMChange.size() >0)) {
                //update contactsToUpdate;
                Core_ERPM_Outbound_Integration.evaluateAndSetERPMOutboundIntegrationStatus(contactsToUpdate,null,false);
                Core_ERPM_Outbound_Integration.updateContIPAIntStsOnCIMChange = false;
            }
        }
        
    }
    
    //Added by Draco - Changes in-Progress
    public static void publishAGSMessage(List<Contact> lstNewContacts, Map<Id, Contact> mapContIdOldContacts)
    {
        List<Contact> lstcontactsWithAGSPending = new List<Contact>();
        Boolean fromRole20WithEntPending = FALSE;
        
        
        //*********************************** DRACO- A&E 2.0 -fresh contact- ERPm Bypass -Start***********************************//
        
        List<Contact> lstcontactsWithPendingNew = new List<Contact>();
        List<Contact> lstcontactsToPublishERPMNew = new List<Contact>();
        Map<Id,Contact> mapContactsNotToPublishERPMNew = new Map<Id,Contact>();
        //Integer iPendingEntCntNew = 0;
        // Integer iPendingEngCntNew = 0;
        
        List<Contact> lstContNew = new List<Contact>();
        
        for(Contact cObj : lstNewContacts)
        {       
            
            if(Core_IntegrationInboundMessageHandler.startedFromAGSInboundMsg && cObj.Core_AGS_Integration_Status__c == 'Pending'){
                fromRole20WithEntPending = TRUE;
            }
            if((cObj.Core_ERPM_Integration_Status__c == 'In-Progress'&& cObj.Core_ERPM_Integration_Queue_txt__c == 'Full' && cObj.Core_AGS_Integration_Status__c != 'Successful' && cObj.Core_AGS_Integration_Status__c != 'In-Progress' && cObj.Core_AGS_Integration_Status__c != 'Failed') || (Core_Contact_Entitlements_Controller.startedFromGA || Core_ContactEntitlementHelper.startedFromDataLoad || fromRole20WithEntPending)) //Added by DRACO as part of ERPM Bypass
                // Added condition cObj.Core_AGS_Integration_Status__c != 'Successful' to avoid sending AGS Outbound again if it is already successful [09/10/2021]
                // Added condition cObj.Core_AGS_Integration_Status__c != 'In-Progress' to avoid sending AGS Outbound again if it is already in progress [22/10/2021]
                // Added condition cObj.Core_AGS_Integration_Status__c != 'Failed' to avoid sending AGS Outbound if it is already failed [28-04-2022]
                //||(cObj.Core_ERPM_Integration_Status__c == 'Pending'&& cObj.Core_ERPM_Integration_Queue_txt__c != 'Full'))
                // && cObj.Core_ERPM_Integration_Queue_txt__c == 'Full'&& !cObj.Core_IPS_Employee_Customer__c)
            {
                
                lstcontactsWithPendingNew.add(cObj);
                
            }
        }
        if(lstcontactsWithPendingNew != null && !lstcontactsWithPendingNew.isEmpty()) {
            lstContNew =
                [SELECT id, Core_eRPM_Person_Id__c, Core_Enterprise_Id__c, Core_Login_Id__c, FirstName, LastName,Core_AGS_Republish_Ind__c,
                 Email, Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c, Core_Sales_Do_Not_Contact_Ind__c, Core_Do_Not_Contact_Dtm__c, Core_Do_Not_Contact__c, Core_Marketing_Do_Not_Contact_Dtm__c, Salutation,
                 Core_Job_Function_Code__c, MailingStreet, MailingCity, MailingStateCode, MailingCountryCode,
                 MailingPostalCode, Phone, MobilePhone, Core_Preferred_Language__c, Account.Name, Account.Core_CNDA_Number__c, Account.Id,
                 Account.BillingStreet, Account.BillingCity, Account.BillingStateCode, Account.BillingCountryCode, Account.Core_CIM_ID__c,
                 Account.BillingPostalCode, Account.ShippingStreet, Account.ShippingCity, Account.ShippingStateCode, Account.ShippingCountryCode,
                 Account.ShippingPostalCode, Account.Core_User_Defined_Phone_Number__c, Account.Core_Account_Legal_Name__c, Account.Core_IsODM__c,
                 MailingCountry, Account.BillingCountry,Account.ShippingCountry, Account.Core_B2B_ERPM_Account_Number__c, Account.Core_English_Only_Name__c,
                 Account.Core_Alternate_Language_Name__c, Core_Set_ERPM_Status_Bypass__c, Account.Core_User_Defined_Website__c, Account.Core_User_Defined_Number_of_Employees__c,
                 (SELECT Id,PRM_Status_Nm__c, PRM_Contact_Id__c,PRM_Relationship_Id__c,PRM_Relationship_Id__r.Name,PRM_Account_Id__r.Name,PRM_Partner_Role__c,PRM_InActive_Ind__c FROM Account_Contact_Relationships__r  WHERE PRM_Relationship_Id__r.Name = :Label.PRM_Entitlement_Employee),
                 (SELECT PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c,PRM_Partner_Subscription_Id__r.Name,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c FROM Contact_Subscription_Associations__r),
                 (Select id, Core_Selected__c,Core_DontNotify__c,Core_Status__c,Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c,Core_Entitlement_Id__r.Name,Core_Contact_Id__c,Core_Entitlement_Id__r.Core_IsActive__c,Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Engagement_Type__c FROM Contact_Entitlements__r)
                 FROM Contact
                 WHERE id IN :lstcontactsWithPendingNew];
            
            for(Contact cObj : lstContNew){
                if (!cObj.Core_AGS_Republish_Ind__c || cObj.Core_AGS_Republish_Ind__c == null ){ // added by shreyash as part of TWC1811-4955
                    Integer iPendingEntCntNew = 0;
                    Integer iPendingEngCntNew = 0;
                    List<Core_Contact_Entitlement__c> lstContEntNew = new List<Core_Contact_Entitlement__c>();
                   
                    for(Core_Contact_Entitlement__c cEnt : cObj.Contact_Entitlements__r){
                        lstContEntNew.add(cEnt);
                        
                        if(cEnt.Core_Entitlement_Id__r.Core_IsActive__c){
                            
                            if(cEnt.Core_Status__c == 'Pending'){
                                iPendingEntCntNew ++;
                            }
                            if(cEnt.Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c != null && cEnt.Core_Status__c == 'Pending'){
                                iPendingEngCntNew ++;
                            }
                        }
                        
                    }
                    if(iPendingEntCntNew != 0 && iPendingEngCntNew == 0 && !Core_Contact_EmailChange_Handler.initiatedAsEmailChange) //Team Draco Change [22/12/2022]
                        
                    {
                        
                        mapContactsNotToPublishERPMNew.put(cObj.Id, cObj);
                    }
                }
            }
        } 
        
        
        //*********************************** DRACO- A&E 2.0 -fresh contact- ERPm Bypass -End ***********************************//
        for(Contact cObj : lstNewContacts)
        {
             
            if((cObj.Core_ERPM_Integration_Status__c == 'Successful' && cObj.Core_AGS_Integration_Status__c == 'Pending'
                && (mapContIdOldContacts.get(cObj.Id).Core_AGS_Integration_Status__c != 'Pending' || mapContIdOldContacts.get(cObj.Id).Core_ERPM_Integration_Status__c != 'Successful'))
               ||(mapContactsNotToPublishERPMNew.containsKey(cObj.Id))) //Added by DRACO as part of ERPM Bypass
                
                //  || (iPendingEntCntNew != 0 && iPendingEngCntNew ==0))
            {
                lstcontactsWithAGSPending.add(cObj);
            }
        }
        
        if(!lstcontactsWithAGSPending.isEmpty()){
            generateAgsOutboundMessage(lstcontactsWithAGSPending);
        }
        
    }
    //Added by Draco - Changes in-Progress
    public static void publishERPMMessage(List<Contact> lstNewContacts, Map<Id, Contact> mapContIdOldContacts){
        String tags = '';
        try{
            logEntryMsgString+='\npublishERPMMessage Method invoked at:'+System.Now().format('MM/dd/YYYY HH:MM:SS','PST')+' PST dt@@@';
            List<Contact> lstcontactsWithPending = new List<Contact>();
            List<Contact> lstcontactsToPublishERPM = new List<Contact>();
            List<Contact> lstcontactsNotToPublishERPM = new List<Contact>();
            
            //Map<String,ERPM_ContactDetailWrapper> mapERPM_ContactDetailWrapper = new Map<String,ERPM_ContactDetailWrapper>();
            List<Contact> lstCont = new List<Contact>();
            if(!hasRun){
                logEntryMsgString+='\nList of contacts received for processing: '+lstNewContacts;
                logEntryMsgString+='\nMap of old contacts received for processing: '+mapContIdOldContacts;
                for(Contact cObj : lstNewContacts)
                {
                    //Prepare list of contacts that we need to process in ERPM
                    if(cObj.Core_ERPM_Integration_Status__c == 'Pending' && cObj.Core_ERPM_Integration_Queue_txt__c != 'Full'
                       && !cObj.Core_IPS_Employee_Customer__c)
                    {
                        lstcontactsWithPending.add(cObj);
                    }
                    if (!String.isBlank(cObj.Core_eRPM_Person_Id__c))
                        tags += addTag(cObj.Core_eRPM_Person_Id__c);
                    if (!String.isBlank(cObj.Core_Enterprise_Id__c))
                        tags += addTag(cObj.Core_Enterprise_Id__c);
                    /*if (!String.isBlank(cObj.Core_Login_Id__c)) //Draco Commented deprecating attributes
tags += addTag(cObj.Core_Login_Id__c);*/
                    if (!String.isBlank(cObj.Email))
                        tags += addTag(cObj.Email);
                    if (!String.isBlank(cObj.Id))
                        tags += addTag(cObj.Id);
                    logEntryTags = tags;
                }
                if(lstcontactsWithPending != null && !lstcontactsWithPending.isEmpty()) {
                    lstCont = [SELECT id, Core_eRPM_Person_Id__c, Core_Enterprise_Id__c, Core_Login_Id__c, FirstName, LastName,Core_Profession__c,
                               Email, Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c, Core_Sales_Do_Not_Contact_Ind__c, Core_Do_Not_Contact_Dtm__c, Core_Do_Not_Contact__c, Core_Marketing_Do_Not_Contact_Dtm__c, Salutation,
                               Core_Job_Function_Code__c, MailingStreet, MailingCity, MailingStateCode, MailingCountryCode,
                               MailingPostalCode, Phone, MobilePhone, Core_Preferred_Language__c, Account.Name, Account.Core_CNDA_Number__c, Account.Id,
                               Account.BillingStreet, Account.BillingCity, Account.BillingStateCode, Account.BillingCountryCode, Account.Core_CIM_ID__c,
                               Account.BillingPostalCode, Account.ShippingStreet, Account.ShippingCity, Account.ShippingStateCode, Account.ShippingCountryCode,
                               Account.ShippingPostalCode, Account.Core_User_Defined_Phone_Number__c, Account.Core_Account_Legal_Name__c, Account.Core_IsODM__c,
                               MailingCountry, Account.BillingCountry,Account.ShippingCountry, Account.Core_B2B_ERPM_Account_Number__c, Account.Core_English_Only_Name__c,
                               Account.Core_Alternate_Language_Name__c, Core_Set_ERPM_Status_Bypass__c, Account.Core_User_Defined_Website__c, Account.Core_User_Defined_Number_of_Employees__c,
                               (SELECT Id,PRM_Status_Nm__c, PRM_Contact_Id__c,PRM_Relationship_Id__c,PRM_Relationship_Id__r.Name,PRM_Account_Id__r.Name,PRM_Partner_Role__c,PRM_InActive_Ind__c FROM Account_Contact_Relationships__r  WHERE PRM_Relationship_Id__r.Name = :Label.PRM_Entitlement_Employee),
                               (SELECT PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c,PRM_Partner_Subscription_Id__r.Name,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c FROM Contact_Subscription_Associations__r),
                               (Select id, Core_Selected__c,Core_DontNotify__c,Core_Status__c,Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c,Core_Entitlement_Id__r.Name,Core_Contact_Id__c,Core_Entitlement_Id__r.Core_IsActive__c,Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Engagement_Type__c FROM Contact_Entitlements__r),
                               (SELECT Id, Contact__c, Status__c, Business_Types__c FROM Contact_Business_Types__r WHERE Business_Types__r.Name =: Label.DZP_Business_Type)
                               FROM Contact
                               WHERE id IN :lstcontactsWithPending];
                    
                    
                    logEntryMsgString+='\nContact Records with Pending Integration Status: '+lstCont;
                    for(Contact cObj : lstCont){
                        
                        Integer iPendingEntCnt = 0;
                        Integer iPendingEngCnt = 0;
                        List<Core_Contact_Entitlement__c> lstContEnt = new List<Core_Contact_Entitlement__c>();
                   
                        for(Core_Contact_Entitlement__c cEnt : cObj.Contact_Entitlements__r){
                            lstContEnt.add(cEnt);
                            //if(cEnt.Core_Contact_Id__c == cObj.Id){
                            if(cEnt.Core_Entitlement_Id__r.Core_IsActive__c){
                                //String status = cEnt.Core_Status__c;
                                //String engCode = cEnt.Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c;
                                if(cEnt.Core_Status__c == 'Pending'){
                                    iPendingEntCnt ++;
                                }
                                if(cEnt.Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c != null && cEnt.Core_Status__c == 'Pending'){
                                    iPendingEngCnt ++;
                                }
                            }
                            //}
                        }
                        
                        
                        //prepare list of contacts which we don't want't to publish to ERPM. Added "!Core_ContactHandler.hasRunRepublish" condition to ALWAYS Publish to ERPM in case of Republish
                        
                        if(cObj.Core_eRPM_Person_Id__c != null && iPendingEntCnt != 0 && iPendingEngCnt ==0 && subsFlowIntiated == false && !contactUpdate && !Core_ContactHandler.hasRunRepublish){
                            
                            lstcontactsNotToPublishERPM.add(cObj);
                        }
                        //prepare list of contacts which we want't to publish to ERPM
                        else{
                            lstcontactsToPublishERPM.add(cObj);
                        }
                    }
                    
                    //Call ERPM helper method
                    generateErpmOutboundMessage(lstcontactsToPublishERPM, lstcontactsNotToPublishERPM, mapContIdOldContacts);
                    hasRun= true;
                }
            }
        }catch(Exception e){
            logEntryMsgString+='\nException occurred in publishERPMMessage method:'+e.getTypeName() + ': ' + e.getMessage() + ', ' + e.getStackTraceString();    
            
            /*PRM_IPA_Utility.createLogEntryIPAWrapper obj_1=new PRM_IPA_Utility.createLogEntryIPAWrapper();
            obj_1.logEntryMsgString=logEntryMsgString;
            obj_1.origin=LOG_ENTRY_ORIGIN; 
            obj_1.project=LOG_ENTRY_PROJECT;
            obj_1.scope=LOG_ENTRY_ERPM_SCOPE;
            obj_1.severity=LOG_ENTRY_ERROR;
            obj_1.tags=tags;
            PRM_IPA_Utility.createLogEntry(obj_1); //Athr fixes*/
            PRM_IPA_Utility.createLogEntry(logEntryMsgString, LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_ERPM_SCOPE, LOG_ENTRY_ERROR, tags);    
        } 
    }
    public static void generateErpmOutboundMessage(List<Contact> lstcontactsToPublishERPM, List<Contact> lstcontactsNotToPublishERPM, Map<Id, Contact> oldLstContacts){
        Id currentContactId;
        String tags = '';   
        try{
            logEntryMsgString+='\ngenerateErpmOutboundMessage Method invoked at:'+System.Now().format('MM/dd/YYYY HH:MM:SS','PST')+' PST dt@@@';
            List<Contact> lstupdateContacts = new List<Contact>();
            List<Core_Integration_Outbound_Message__c> lstOutboundMsg = new List<Core_Integration_Outbound_Message__c>();
            Set<Core_Integration_Outbound_Message__c> sOutboundMsg = new Set<Core_Integration_Outbound_Message__c>();
            
            logEntryMsgString+='\nList of Contacts received to publish to ERPM: '+lstcontactsToPublishERPM;
            logEntryMsgString+='\nList of Contacts received not to publish to ERPM: '+lstcontactsNotToPublishERPM;
            //Contacts to send ERPM OBM
            if(!lstcontactsToPublishERPM.isEmpty()){
                
                //Map<Contact, List<Core_Contact_Entitlement__c>> mapContEnt = new Map<Contact, List<Core_Contact_Entitlement__c>>();            
                
                
                Map<id,Core_Integration_Outbound_Message__c> mapMsg = new Map<id,Core_Integration_Outbound_Message__c>();
                Organization org = [Select IsSandbox from Organization LIMIT 1];
                for(Contact cObj : lstcontactsToPublishERPM)
                {
                    currentContactId = cObj.id;
                    
                    // Build up tags for log entry
                    if (!String.isBlank(cObj.Core_eRPM_Person_Id__c))
                        tags += addTag(cObj.Core_eRPM_Person_Id__c);
                    if (!String.isBlank(cObj.Core_Enterprise_Id__c))
                        tags += addTag(cObj.Core_Enterprise_Id__c);
                    if (!String.isBlank(cObj.Core_Login_Id__c))
                        tags += addTag(cObj.Core_Login_Id__c);
                    if (!String.isBlank(cObj.Email))
                        tags += addTag(cObj.Email);
                    if (!String.isBlank(cObj.Id))
                        tags += addTag(cObj.Id);
                    logEntryTags = tags;
                    Core_Integration_Outbound_Message__c outboundMsg = new Core_Integration_Outbound_Message__c();
                    PersonAccountProfile pAcctProf = new PersonAccountProfile();
                    pAcctProf.PersonID = cObj.Core_eRPM_Person_Id__c;
                    pAcctProf.EnterpriseID = cObj.Core_Enterprise_Id__c;
                    pAcctProf.LoginID = cObj.Core_Login_Id__c;
                    pAcctProf.ExternalAttributes.ProfessionCode=cObj.Core_Profession__c ;
                    
                    
                    if(cObj.FirstName.length() > 60) {
                        pAcctProf.FirstName = cObj.FirstName.subString(0,60);
                    } else {
                        pAcctProf.FirstName = cObj.FirstName;
                    }
                    if(cObj.FirstName.length() > 70) {
                        pAcctProf.LastName = cObj.LastName.subString(0,70);
                    } else {
                        pAcctProf.LastName = cObj.LastName;
                    }
                    
                    pAcctProf.EmailID = cObj.Email;
                    pAcctProf.EnglishFirstName = cObj.Core_English_Only_First_Name__c;
                    pAcctProf.EnglishLastName = cObj.Core_English_Only_Last_Name__c;
                    pAcctProf.PersonRegistrationTypeCode = 'INTEL';
                    
                    //Sales Do Not Contact
                    if(cObj.Core_Sales_Do_Not_Contact_Ind__c)
                    {
                        pAcctProf.SalesDoNotContactFlag = 'Y';
                        pAcctProf.SalesDoNotContactDate = cObj.Core_Do_Not_Contact_Dtm__c;
                        
                    }
                    else{
                        pAcctProf.SalesDoNotContactFlag = 'N';
                    }
                    //Marketing Do Not Contact
                    if(cObj.Core_Do_Not_Contact__c)
                    {
                        pAcctProf.DoNotContactFlag = 'Y';
                        pAcctProf.AllIntelDoNotContactDate = cObj.Core_Marketing_Do_Not_Contact_Dtm__c;
                        
                    }
                    else{
                        pAcctProf.DoNotContactFlag='N';
                    }
                    //Gireesh:US942207
                    /*if(cObj.Core_Do_Not_Contact__c)
{
pAcctProf.DoNotContactFlag = 'Y';
} else {
pAcctProf.DoNotContactFlag = 'N';
}*/
                    pAcctProf.PersonTitle = getPersonTitle(cObj.Salutation);
                    
                    // JobFunction is set to null until we have the correct values that ERPM uses 12/14/2016
                    // JobFunction is being passed to ERPM as of 4/4/2017
                    pAcctProf.JobFunction = cObj.Core_Job_Function_Code__c;
                    
                    //Send it empty for now because we need to come up with a solution when partial data is sent 12/14/2016
                    //Passing Country code to eRPM. Address and Location Type are set to MAIL and HOME resp through BB Api call.
                    //Add person phy address only if country code is present
                    // if(String.isNotBlank(cObj.MailingCountryCode)) {
                    PersonPhysicalAddresses phyAddr =new PersonPhysicalAddresses();
                    phyAddr.CountryCode = ((String.isNotBlank(cObj.MailingCountryCode)) && (cObj.MailingCountryCode != null)) ? getISO2CountryCode(cObj.MailingCountryCode): getISO2CountryCode(cObj.Account.BillingCountryCode);
                    if(cObj.MailingStateCode != null){
                        phyAddr.State = cObj.MailingStateCode;
                    }
                    pAcctProf.PersonPhysicalAddresses.add(phyAddr);
                    // }
                    
                    if(cObj.Phone != null) {
                        pAcctProf.PersonElectronicAddresses.add(new PersonElectronicAddresses('PHONE', cObj.Phone)); //, getISO2CountryCode(cObj.MailingCountry) Removed CountryCode 2/1/2017
                    } else if(String.isBlank(cObj.Phone) && oldLstContacts != null && !oldLstContacts.isEmpty()  && oldLstContacts.containsKey(cObj.id) &&  !String.isBlank(oldLstContacts.get(cObj.id).Phone)) {
                        pAcctProf.PersonElectronicAddresses.add(new PersonElectronicAddresses('PHONE', ''));
                    }
                    if(cObj.MobilePhone != null) {
                        pAcctProf.PersonElectronicAddresses.add(new PersonElectronicAddresses('MOB', cObj.MobilePhone)); //, getISO2CountryCode(cObj.MailingCountry) Removed CountryCode 2/1/2017
                    } else if(String.isBlank(cObj.MobilePhone) && oldLstContacts != null && !oldLstContacts.isEmpty() && oldLstContacts.containsKey(cObj.id) && !String.isBlank(oldLstContacts.get(cObj.id).MobilePhone)) {
                        pAcctProf.PersonElectronicAddresses.add(new PersonElectronicAddresses('MOB', ''));
                    }
                    
                    // ------------------------------ ERPM Changes ::: Added NumberOfEmployees-------------------------------- //
                    
                    if(cObj.Core_Preferred_Language__c != null)
                        pAcctProf.LanguageCode = cObj.Core_Preferred_Language__c;
                    
                    AccountProfiles acctProf = new AccountProfiles(cObj.Account.Core_B2B_ERPM_Account_Number__c, cObj.Account.Name, cObj.Account.Core_CNDA_Number__c,cObj.Account.Core_User_Defined_Number_of_Employees__c);
                    
                    String addressLine1 = '';
                    String addressLine2 = '';
                    List<String> lstAddressLine = smartSplit(cObj.Account.BillingStreet, 125);
                    if(lstAddressLine != null && lstAddressLine.size() == 1)
                    {
                        addressLine1 = lstAddressLine[0];
                    }
                    if(lstAddressLine != null && lstAddressLine.size()>1)
                    {
                        addressLine1 = lstAddressLine[0];
                        addressLine2 = lstAddressLine[1];
                    }
                    acctProf.AccountPhysicalAddresses.add(new AccountPhysicalAddresses(addressLine1, addressLine2, cObj.Account.BillingCity, cObj.Account.BillingStateCode, getISO2CountryCode(cObj.Account.BillingCountry), cObj.Account.BillingPostalCode,'PHY'));
                    if(String.isNotBlank(cObj.Account.ShippingStreet))
                    {
                        lstAddressLine = smartSplit(cObj.Account.ShippingStreet, 125);
                        if(lstAddressLine != null && lstAddressLine.size() == 1)
                        {
                            addressLine1 = lstAddressLine[0];
                        }
                        if(lstAddressLine != null && lstAddressLine.size()>1)
                        {
                            addressLine1 = lstAddressLine[0];
                            addressLine2 = lstAddressLine[1];
                        }
                        acctProf.AccountPhysicalAddresses.add(new AccountPhysicalAddresses(addressLine1, addressLine2, cObj.Account.ShippingCity, cObj.Account.ShippingStateCode, getISO2CountryCode(cObj.Account.ShippingCountry), cObj.Account.ShippingPostalCode,'MAIL'));
                    }
                  
                    
                    // ------------------------------ ERPM Changes : BEGIN -------------------------------- //
                    if(cObj.Account.Core_User_Defined_Phone_Number__c != null)
                    {
                        acctProf.AccountElectronicAddresses.add(new AccountElectronicAddresses(cObj.Account.Core_User_Defined_Phone_Number__c, getISO2CountryCode(cObj.Account.BillingCountry),'PHONE'));
                    }
                    if(cObj.Account.Core_User_Defined_Website__c != null)
                    {
                        acctProf.AccountElectronicAddresses.add(new AccountElectronicAddresses(cObj.Account.Core_User_Defined_Website__c , getISO2CountryCode(cObj.Account.BillingCountry),'URL'));
                    }
                    // ------------------------------ ERPM Changes : END -------------------------------- //
                    
                    Map<String,String> mEngCodes = new Map<String,String>();
                    Map<String,String> mSoftEngCodes = new Map<String,String>();
                    Map<String,Membership> mIPAEngCodes = new Map<String,Membership>();
                    
                    for(Core_Contact_Entitlement__c cEnt : cObj.Contact_Entitlements__r)
                    {
                        if(cEnt.Core_Contact_Id__c == cObj.Id) /*&& !IsEmailTriggerDisabledForEntitlement(cEnt))*/
                        {
                            if(cEnt.Core_Entitlement_Id__r.Core_IsActive__c)
                            {
                                String engCode = cEnt.Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c;
                             
                                //Boolean selected = cEnt.Core_Selected__c;
                                String action = (cEnt.Core_Selected__c) ? 'ENGSTSAPRD' : 'ENGSTSRJTD';
                                
                                if(engCode!= null)
                                {
                                    if(cEnt.Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Engagement_Type__c == 'SEC')
                                    {
                                        if(!mEngCodes.containsKey(engCode))
                                        {
                                            mEngCodes.put(engCode, action);
                                        }
                                        else
                                        {
                                            if(mEngCodes.get(engCode).equals('ENGSTSRJTD')) {
                                                mEngCodes.put(engCode, action);
                                            }
                                        }
                                    }
                                    else
                                    {
                                        if(!mSoftEngCodes.containsKey(engCode))
                                        {
                                            mSoftEngCodes.put(engCode, action);
                                            
                                        }
                                        else
                                        {
                                            if(mSoftEngCodes.get(engCode).equals('ENGSTSRJTD'))
                                            {
                                                mSoftEngCodes.put(engCode, action);
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } //END : Contact_Entitlement loop
                    
                   
                    pAcctProf.Subscriptions = GetSubscriptions(cObj);
                  
                    
                    acctProf.ExternalSystems.add(new ExternalSystems('SLSCLDID', cObj.Account.Id));
                    acctProf.ExternalSystems.add(new ExternalSystems('CIM', cObj.Account.Core_CIM_ID__c ));
                    // Adding null checks until validation rules are complete
                    // 2/10/2017 Adding truncated fields check
                    if(cObj.Account.Core_Account_Legal_Name__c != null && !String.isBlank(cObj.Account.Core_Account_Legal_Name__c))
                        acctProf.AccountNameCollections.add(new AccountNameCollections(cObj.Account.Core_Account_Legal_Name__c, 'ACTNMTYLGL'));
                    
                    if(cObj.Account.Core_English_Only_Name__c != null && !String.isBlank(cObj.Account.Core_English_Only_Name__c))
                        acctProf.AccountNameCollections.add(new AccountNameCollections(cObj.Account.Core_English_Only_Name__c, 'ACTNMTYENG'));
                    
                    if(cObj.Account.Core_Alternate_Language_Name__c != null && !String.isBlank(cObj.Account.Core_Alternate_Language_Name__c))
                        acctProf.AccountNameCollections.add(new AccountNameCollections(cObj.Account.Core_Alternate_Language_Name__c, 'ACTNMTYALS'));
                    
                    if(cObj.Account.Core_IsODM__c)
                        acctProf.AccountTypeCollections.add(new AccountTypeCollections());
                    
                    // ------------------------------ ERPM Changes : END -------------------------------- //
                    
                    // If no membership collections in AccountProfile set AccountProfile to null 12/14/2016
                    if(mEngCodes.size() > 0)
                    {
                        for(String key : mEngCodes.keySet())
                        {
                            Membership membership = new Membership();
                            membership.EngagementCode=key;
                            membership.EnggStatus = mEngCodes.get(key);
                            acctProf.MembershipCollections.add(membership);
                         
                        }
                    }
                    
                   
                    // ------------------------------ ERPM Changes : START -------------------------------- //
                    if(acctProf !=null && (acctProf.MembershipCollections != null && acctProf.MembershipCollections.size() >0))
                        pAcctProf.AccountProfiles.add(acctProf);
                    else
                        pAcctProf.AccountProfiles = null;
                    
                    //New logic for adding IPA CRM Engagement for a contact.
                    //Added status check by Naresh as per the defect#DE90608
                    /* if (cObj.Account_Contact_Relationships__r.Size() > 0 && (cObj.Account_Contact_Relationships__r[0].PRM_Status_Nm__c=='Complete' ||cObj.Account_Contact_Relationships__r[0].PRM_Status_Nm__c=='Pending Action') && String.isNotBlank(cObj.Core_Enterprise_Id__c)) {
pAcctProf.Memberships.add(new Memberships(System.Label.PRM_IPACRMCNTCSENGG, (cObj.Account_Contact_Relationships__r[0].PRM_InActive_Ind__c &&  (!mapOfContactActivatingACR.containsKey(cObj.Email) || !mapOfContactActivatingACR.get(cObj.Email)==true))?'ENGSTSRJTD':'ENGSTSAPRD'));
//pAcctProf.Memberships.add(new Memberships(System.Label.PRM_IPACRMCNTCSENGG, (cObj.Account_Contact_Relationships__r[0].PRM_InActive_Ind__c)?'ENGSTSRJTD':'ENGSTSAPRD'));
} */                           
                    
                    //Add DZS engagement in Approve/Rejected based on contact business type(DZP) status
                    if(cObj.Contact_Business_Types__r.Size() > 0 && String.isNotBlank(cObj.Core_Enterprise_Id__c)) {
                                             
                        pAcctProf.Memberships.add(new Memberships(Label.UDE_Standard_Engg_Code, (cObj.Contact_Business_Types__r[0].Status__c == 'Approved') ? 'ENGSTSAPRD' : 'ENGSTSRJTD'));
                    }
                    // ------------------------------ ERPM Changes : END -------------------------------- //
                    // Always add Sales Soft engagement
                    pAcctProf.Memberships.add(new Memberships('CRM_Cloud_Cntct', 'ENGSTSAPRD'));
                    String ChngAgentLoginId;
                    boolean isPSG = false;
                    
                    if(mSoftEngCodes.size() > 0) {
                        if(mSoftEngCodes.containsKey('PSG_Basic'))
                        {
                            ChngAgentLoginId =(org.IsSandbox)?Label.ERPM_Change_Agent_ID_Pre_Prod_PSG:Label.ERPM_Change_Agent_ID_Prod_PSG;
                            isPSG = true;
                        }
                        for(String key : mSoftEngCodes.keySet()) {
                            pAcctProf.Memberships.add(new Memberships(key, mSoftEngCodes.get(key)));
                        }
                    }
                    
                    
                    ERPM_Outbound_Msg_Wrapper outboundMsgWrapper = new ERPM_Outbound_Msg_Wrapper();
                    outboundMsgWrapper.PersonAccountProfile = pAcctProf;
                    if(isPSG){
                        outboundMsgWrapper.ChgAgtLoginId = ChngAgentLoginId;
                    }
                    //Added by mahendra as per userstory US95251
                    for(Core_Contact_Entitlement__c cEnt : cObj.Contact_Entitlements__r) {
                        
                        
                        // Redunant && query as we are checking for the same contact - Harshitha
                        //if(cEnt.Core_DontNotify__c &&  cEnt.Core_Contact_Id__c == currentContactId){
                        if(cEnt.Core_DontNotify__c){
                            outboundMsgWrapper.blnNotify=false;
                        }
                    }
                    
                    outboundMsg.Core_MessageType__c = 'ERPM Contact Entitlement';
                    outboundMsg.Core_Payload__c = '<![CDATA[' +  JSON.serialize(outboundMsgWrapper) + ']]>';
                    outboundMsg.Core_Tags__c = tags == null || tags.length() <= 255 ? tags : tags.substring(0, 255);
                    Contact cTemp = new Contact(id = cObj.Id, Core_ERPM_Integration_Status__c = 'In-Progress');
                    //lstContactsInProgress.add(cTemp);
                    //cObj.Core_ERPM_Integration_Status__c = 'In-Progress';
                    lstupdateContacts.add(cTemp);
                    lstOutboundMsg.add(outBoundMsg);
                    tags = ''; // DRACO CHANGE [07/07/2022] ---- Added bug fix for ERPM OBM tags mismatch in case of Data load [TWC1811-2597]
                    mapMsg.put(currentContactId, outBoundMsg);
                }//End : Contact Loop
                
                logEntryMsgString+='\nList of outbound messages created to publish to ERPM: '+lstOutboundMsg;
                /*for(Contact cont:updateContacts){
if(mapContactsToBeUpdated.containsKey(cont.Id)){
mapContactsToBeUpdated.get(cont.Id).Core_ERPM_Integration_Status__c = cont.Core_ERPM_Integration_Status__c;
}else{
mapContactsToBeUpdated.put(cont.Id, cont);
}
}*/
                if(lstOutboundMsg != null && lstOutboundMsg.size()>0) {
                    insert lstOutboundMsg;
                    List<Contact_Message__c> ContactMsg = new List<Contact_Message__c>();
                    for(Id cid : mapMsg.keySet()) ContactMsg.add(
                        new Contact_Message__c(Contact__c = cid, Outbound_Message__c = mapMsg.get(cid).id)
                    );
                    insert ContactMsg;
                }
                
            }
            
            //Contacts not to send ERPM OBM
            if(!lstcontactsNotToPublishERPM.isEmpty()){
                for(Contact cObj : lstcontactsNotToPublishERPM){
                    //cObj.Core_ERPM_Integration_Status__c = 'Successful';
                    Contact cTemp = new Contact(id = cObj.Id, Core_ERPM_Integration_Status__c = 'Successful');
                    lstupdateContacts.add(cTemp);
                }
            }
            
            update lstupdateContacts;
        }
        catch(Exception ex) {
            String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
           
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_ERPM_SCOPE, LOG_ENTRY_ERROR,
                                                 'Error generating ERPM OBM', '', currentContactId, LOG_ENTRY_OBJECT, tags, ex);
            logEntryMsgString+='\nException occurred in generateErpmOutboundMessage method:'+ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();    
           /* PRM_IPA_Utility.createLogEntryIPAWrapper obj_2=new PRM_IPA_Utility.createLogEntryIPAWrapper();
            obj_2.logEntryMsgString=logEntryMsgString;
            obj_2.origin=LOG_ENTRY_ORIGIN; 
            obj_2.project=LOG_ENTRY_PROJECT;
            obj_2.scope=LOG_ENTRY_ERPM_SCOPE;
            obj_2.severity=LOG_ENTRY_ERROR;
            obj_2.tags=logEntryTags;
            PRM_IPA_Utility.createLogEntry(obj_2); //Athr fixes*/
            PRM_IPA_Utility.createLogEntry(logEntryMsgString, LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_ERPM_SCOPE, LOG_ENTRY_ERROR, logEntryTags);    
        }finally{
           /* PRM_IPA_Utility.createLogEntryIPAWrapper obj_3=new PRM_IPA_Utility.createLogEntryIPAWrapper();
            obj_3.logEntryMsgString=logEntryMsgString;
            obj_3.origin=LOG_ENTRY_ORIGIN; 
            obj_3.project=LOG_ENTRY_PROJECT;
            obj_3.scope=LOG_ENTRY_ERPM_SCOPE;
            obj_3.severity=LOG_ENTRY_INFO;
            obj_3.tags=logEntryTags;
            PRM_IPA_Utility.createLogEntry(obj_3); //Athr fixes*/
            PRM_IPA_Utility.createLogEntry(logEntryMsgString, LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_ERPM_SCOPE, LOG_ENTRY_INFO, logEntryTags);
        }
    }
    /*private class ERPM_ContactDetailWrapper{
Integer iPendingEntCnt;
Integer iPendingEngCnt;
List<Core_Contact_Entitlement__C> lstContEnt { get; set; }
Contact contDetails;
public ERPM_ContactDetailWrapper (Contact cont, Integer iPendingEntCnt, Integer iPendingEngCnt){
this.contDetails = cont;
this.iPendingEntCnt = iPendingEntCnt;
this.iPendingEngCnt = iPendingEngCnt;
lstContEnt = new List<Core_Contact_Entitlement__C>();
}
}*/
    
    // Helper method to assist with building our Tags in Log Entries
    private static String addTag(String tagToAdd) {
        return String.isBlank(tagToAdd) ? '' : (tagToAdd + ';');
            }
    
    global class BoxB_AccountWrapper {
        public String ACCT_ID = '';
        public String ORG_MSTR_NM = '';
        public String CTRY_CD = '';
        public String GEO_NM = '';
        public String ACCT_NM = '';
        public String ACCT_ENG_NM = '';
        public String RIALTO_ROL_ID = '';
        public String RIALTO_ROL_NM = '';
        public String CITR_ID = '';
        public String PROF_ORG_TY_CD = '';
        public String INACT_IND = '';
        public DateTime CREATE_DT = null;
        public DateTime CHANGE_DT = null;
        public String CIMID = '';
        public String CIMID_OLD = '';
        public String CNDA_NBR = '';
        public Boolean ACCT_RDC =False; // US108564-Initialize RDC flag set to false added by-rajesh
    }
    /*private class AGS_Outbound_Msg_Wrapper {
String enterpriseId;
String justification;
List<String> roles { get; set; }
List<String> InProgressRoles { get; set; }
public AGS_Outbound_Msg_Wrapper(String entId, String just) {
justification = just;
enterpriseId=entId;
roles = new List<String>();
InProgressRoles = new List<String>();
}
}*/
    
    private class AGS_Outbound_Msg_Wrapper2 {
        String enterpriseId;
        String justification;
        String firstName;
        String lastName;
        String email;
        //String loginID;
        String language;
        //String languageB2C;
        String country;
        //String countryISO2;  // Draco Change - 21-07-2022 - Added ISO 2 digit country code to cater B2C user creation
        String phonePrefix;
        String phone;
        //List<String> roles { get; set; }
        List<String> InProgressRoles { get; set; }
        List<pendingRoles> pendingRoles { get; set; }
        List<roleRequests> roleRequests { get; set; } // Draco Change - 29-04-2022 - Send additional details of B2B or B2C type in the AGS outbound message
        public AGS_Outbound_Msg_Wrapper2(String entId, String just, String firstNm, String LastNm, String emailid,String lang,/*String langB2C,*/ String countryCode,/*String cntryISO2,*/ String phnPre,String phn /*String contLoginId*/){
            justification = just;
            enterpriseId=entId;
            //roles = new List<String>();
            InProgressRoles = new List<String>();
            pendingRoles = new List<pendingRoles>();
            roleRequests = new List<roleRequests>(); // Draco Change - 29-04-2022 - Send additional details of B2B or B2C type in the AGS outbound message
            firstName = firstNm;
            lastName = LastNm;
            email = emailid;
            //loginID = contLoginId;
            language = lang;
            //languageB2C = langB2C;
            country = countryCode;
            //countryISO2 = cntryISO2; // Draco Change - 21-07-2022 - Added ISO 2 digit country code to cater B2C user creation
            phonePrefix = phnPre;
            phone = phn;
        }  
    }
    
    private class roleRequests{ // Draco Change - 29-04-2022 - Send additional details of B2B or B2C type in the AGS outbound message
        String RoleName;
        String RoleType;
        public roleRequests (String rName, String rType){
            RoleName = rName;
            RoleType = rType;
            
        }
    }
    private class pendingRoles{ 
        String RoleName;
        String RoleType;
        String RoleOperation;
        public pendingRoles (String rName, String rType, String rOperation){
            RoleName = rName;
            RoleType = rType;
            RoleOperation = rOperation;
        }
    }
    private class ERPM_Outbound_Msg_Wrapper {
        PersonAccountProfile PersonAccountProfile { get; set; }
        Boolean blnPublish;
        Boolean blnNotify;
        String ChangeAgent;
        String ChgAgtLoginId;
        
        public ERPM_Outbound_Msg_Wrapper() {
            PersonAccountProfile = new PersonAccountProfile();
            blnPublish = true;
            blnNotify = true;
            ChangeAgent = 'SalesCloud';
            ChgAgtLoginId = 'MAD\\testuser';
        }
    }
    private class PersonAccountProfile {
        String PersonID { get; set; }
        String EnterpriseID { get; set; }
        String LoginID { get; set; }
        String FirstName { get; set; }
        String LastName { get; set; }
        String EmailID { get; set; }
        String EnglishFirstName { get; set; }
        String EnglishLastName { get; set; }
        String PersonRegistrationTypeCode { get; set; }
        String SalesDoNotContactFlag {get; set; }
        //String MarketingDoNotContactFlag {get; set; }//Using old DoNotContactFlag
        DateTime SalesDoNotContactDate {get;set;}
        DateTime AllIntelDoNotContactDate {get;set;} //Points to Marketing do not contact date time
        String DoNotContactFlag { get; set; }
        String PersonTitle { get; set; }
        String JobFunction { get; set; }
        String LanguageCode { get ; set; }
        String CountryCode { get ; set; }
        
        List<PersonPhysicalAddresses> PersonPhysicalAddresses { get; set; }
        List<PersonElectronicAddresses> PersonElectronicAddresses { get; set; }
        List<AccountProfiles> AccountProfiles { get; set; }
        List<Memberships> Memberships { get; set; }
        ExternalAttributes ExternalAttributes { get; set; }
        
        
        // ----------- #REGION :: eRPM Code Changes :: START ------------- //
        //List<LegalAgreement> LegalAgreements = new List<LegalAgreement>();
        List<Subscription> Subscriptions = new List<Subscription>();
        // ----------- #REGION :: eRPM Code Changes :: END ------------- //
        
        public PersonAccountProfile() {
            PersonPhysicalAddresses = new List<PersonPhysicalAddresses>();
            PersonElectronicAddresses = new List<PersonElectronicAddresses>();
            AccountProfiles = new List<AccountProfiles>();
            Memberships = new List<Memberships>();
            ExternalAttributes = new ExternalAttributes();          
            
        }
    }
    
    private class PersonPhysicalAddresses {
        //String AddressType;
        //String LocationType;
        String AddressLine1;
        String City;
        String State;
        String CountryCode;
        String PostalCode;
        // Commented out until solution for partial data is designed
        /*public PersonPhysicalAddresses(String aLine1, String cityValue, String stateValue, String cCode, String pCode) {
AddressType = 'PHY';
LocationType = 'HOME';
AddressLine1 = aLine1;
City = cityValue;
State = stateValue;
CountryCode = cCode;
PostalCode = pCode;
}*/
    }
    
    private class ExternalAttributes {
        String ProfessionCode ;
        
    }
    
    private class PersonElectronicAddresses {
        String ElectronicAddressType;
        String LocationType;
        String ElectronicAddressText;
        //Removed CountryCode 2/1/2017
        //String CountryCode;
        public PersonElectronicAddresses(String eAddressType, String eAddressText) { //, String cCode
            ElectronicAddressType = eAddressType;
            LocationType = 'HOME';
            ElectronicAddressText = eAddressText;
            //CountryCode = cCode;
        }
    }
    
    private class AccountProfiles {
        String AcctNumber;
        String AcctName;
        String CompanyNonDisclosureAgreementNumber;
        String CompanySize;
        String CompanySizeGroup;
        List<AccountPhysicalAddresses> AccountPhysicalAddresses { get; set; }
        List<AccountElectronicAddresses> AccountElectronicAddresses { get; set; }
        List<Membership> MembershipCollections { get; set; }
        List<ExternalSystems> ExternalSystems { get; set; }
        List<AccountNameCollections> AccountNameCollections { get; set; }
        List<AccountTypeCollections> AccountTypeCollections { get; set; }
        
        //List<Relationship> RelationshipCollections = new List<Relationship>();
        //List<AccountBenefit> AccountBenefits = new List<AccountBenefit>();
        //List<Response> ResponsesCollections = new List<Response>();
        
        public AccountProfiles(String aNum, String aName, String agreementNum, string noOfEmp)
        {
            CompanySize = String.isNotBlank(noOfEmp) ? [SELECT eRPM_KeyValue__c FROM SF_ERPM_MAPPING_SETTING__mdt
                                                        WHERE Mapping_Type__c =: Label.PRM_CompanySize AND eRPMEngagementCode__c =: Label.PRM_CSPx2EngagementCode
                                                        AND SF_KeyValue__c =: noOfEmp LIMIT 1].eRPM_KeyValue__c : null;
            CompanySizeGroup = String.isNotBlank(noOfEmp) ? noOfEmp : null;
            AcctNumber = aNum;
            if(aName.length() > 129) {              // 2/10/2017 Adding truncated fields check
                AcctName = aName.substring(0, 129);
            } else {
                AcctName = aName;
            }
            //    if(agreementNum.length() > 50) {    commented by Popcorn
            if(agreementNum != null && agreementNum.length() > 50) {        // 2/10/2017 Adding truncated fields check
                CompanyNonDisclosureAgreementNumber = agreementNum.substring(0, 50);
            } else {
                CompanyNonDisclosureAgreementNumber = agreementNum;
            }
            CompanyNonDisclosureAgreementNumber = agreementNum;
            AccountPhysicalAddresses = new List<AccountPhysicalAddresses>();
            AccountElectronicAddresses = new List<AccountElectronicAddresses>();
            MembershipCollections = new List<Membership>();
            ExternalSystems = new List<ExternalSystems>();
            AccountNameCollections = new List<AccountNameCollections>();
            AccountTypeCollections = new List<AccountTypeCollections>();
        }
    }
    
    private class AccountPhysicalAddresses {
        String AddressType;
        String LocationType;
        String AddressLine1;
        String AddressLine2;
        String City;
        String State;
        String CountryCode;
        String PostalCode;
        public AccountPhysicalAddresses(String aLine1, String aLine2, String cityValue, String stateValue, String cCode, String pCode, String addrType) {
            AddressType = addrType;
            LocationType = 'BUS';
            AddressLine1 = aLine1;
            AddressLine2 = aLine2;
            // US57102 - Added 1/19/2017
            if(!String.isBlank(cityValue)) {
                City = cityValue;
            } else {
                City = 'Dummy City';
            }
            State = stateValue;
            CountryCode = cCode;
            PostalCode = pCode;
        }
    }
    
    private class AccountElectronicAddresses {
        String ElectronicAddressType;
        String LocationType;
        String ElectronicAddressText;
        String CountryCode;
        public AccountElectronicAddresses(String eAddressText, String cCode, String addrType)
        {
            ElectronicAddressType = addrType;
            LocationType = (Label.PRM_Electronic_Addr_Loc_Type == 'true') ? 'BUS':'HOME';
            ElectronicAddressText = eAddressText;
            CountryCode = cCode;
        }
    }
    
    private class ExternalSystems {
        String Name;
        String Value;
        public ExternalSystems(String sysType, String val) {
            Name = sysType;
            Value = val;
        }
    }
    private class AccountNameCollections {
        String AccountNameTypeCode;
        String Name;
        public AccountNameCollections(String legalName, String nameType) {
            AccountNameTypeCode = nameType; //'ACTNMTYLGL';
            Name = legalName;
        }
    }
    private class AccountTypeCollections {
        String BusinessTypeCode;
        public AccountTypeCollections() {
            BusinessTypeCode = 'BIZTYCDODM';
        }
    }
    private class Memberships {
        String EngagementCode;
        String EnggStatus;
        public Memberships(String engCode, String engStatus) {
            EngagementCode = engCode;
            EnggStatus = engStatus;
        }
    }
    
    // ----------- #REGION :: eRPM Code Changes :: START ------------- //
    
    private class Subscription
    {
        String SubscriptionCode { get; set; }
        String SubscriptionName { get; set; }
        String SubscriptionStatusCode { get; set; }
        String UnSubscriptionReason { get; set; }
    }
    
    private class Membership
    {
        String EngagementCode { get; set; }
        String EnggStatus { get; set; }
        String Tier { get; set; }
    }
    // Start Code Added By Draco | Avanish | August 17, 2020
    private class ContactWithConEntDetail {
        String conId;
        List<String> roles = new List<String>();
        List<String> InProgressRoles = new List<String>();
        List<pendingRoles> pendingRoles = new List<pendingRoles>();
        List<roleRequests> roleRequests = new List<roleRequests>(); // Draco Change - 29-04-2022 - Send additional details of B2B or B2C type in the AGS outbound message
        
        public ContactWithConEntDetail(String conId){
            this.conId = conId;
        }
    }
    // End Code Added By Draco | Avanish | August 17, 2020
    
    /*
private class Response
{
String QuestionCode { get; set; }
String ResponseCode { get; set; }
String ResponseValue { get; set; }
String EngagementCode { get; set; }
}
private class Relationship
{
String EngagementCode { get; set; }
List<EngagementRelationship> EngRelationshipCollection = new List<EngagementRelationship>();
}
private class EngagementRelationship
{
String RelationshipCode { get; set; }
String RelationshipStartDate { get; set; }
String RelationshipEndDate { get; set; }
}
private class AccountBenefit
{
string BenefitCode{ get; set; }
string EngagementCode{ get; set; }
string InactiveReasonCode{ get; set; }
string InactiveReason{ get; set; }
string NoteText{ get; set; }
}
private class LegalAgreement
{
string Category { get; set; }
string Name { get; set; }
Datetime SignDate { get; set; }
string IsOrgBased { get; set; }
string EngagementCode { get; set; }
string LangCode { get; set; }
SignedByUser SignedBy { get; set; }
}
private class SignedByUser
{
string LoginID { get; set; }
string FirstName { get; set; }
string LastName { get; set; }
}
private class RelationshipCollection
{
List<Relationship> relationshipCollection = new List<Relationship>();
Boolean NewUser { get; set; }
}*/
    
    // ----------- #REGION :: eRPM Code Changes :: END ------------- //
}