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
*****************************************************************************************************************************************/

global class Core_Entitlement_Outbound_Integrations 
{
    public static Boolean runOnce = false;
    public static Boolean hasRun = false;
    
    public static final String LOG_ENTRY_ORIGIN = 'SFDC';
    public static final String LOG_ENTRY_PROJECT = 'Entitlement';
    public static final String LOG_ENTRY_AGS_SCOPE = 'IntegrationInboundMessageAGS';
    public static final String LOG_ENTRY_ERPM_SCOPE = 'IntegrationInboundMessageERPM';
    public static final String LOG_ENTRY_BOXBACCOUNT_SCOPE = 'IntegrationInboundMessageBOXBACCOUNT';
    public static final String LOG_ENTRY_ERROR = 'error';
    public static final String LOG_ENTRY_INFO = 'info';
    public static final String LOG_ENTRY_OBJECT = 'Core_Integration_Outbound_Message__c';
    public Static String IPATier = '';
    
    //public static Id coMarketingRecordTypeId = null;
    public static Id coMarketingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Core_MDF_Co_Marketing_Record_Type_Name).getRecordTypeId(); //Added by Accenture - VD -> Check if the record type is not Co-Marketing
    
    public static Id pAGRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId(); //Added by Accenture - US408340 -> Check if the record type is not Core_Partner_Account_Group
    
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
    public static void generateAgsOutboundMessage(List<Contact> lContacts, Map<Id, Contact> lOldContacts) {
        List<Core_Integration_Outbound_Message__c> lOutboundMsg = new List<Core_Integration_Outbound_Message__c>();
        List<Core_Contact_Entitlement__c> lContactEnt = new List<Core_Contact_Entitlement__c>();
        List<Contact> contactsWithPending = new List<Contact>();
        
        Id currentContactId;  //added by popcorn
        
        String tags = '';
        try {
            for(Contact cObj : lContacts) {
                if(cObj.Core_AGS_Integration_Status__c == 'Pending' && cObj.Core_ERPM_Integration_Status__c == 'Successful'
                   && lOldContacts.get(cObj.Id).Core_ERPM_Integration_Status__c != 'Successful' && !String.isBlank(cObj.Core_Enterprise_Id__c)) 
                {
                    contactsWithPending.add(cObj);
                } else if(cObj.Core_AGS_Integration_Status__c == 'Pending' && cObj.Core_ERPM_Integration_Status__c == 'Successful'
                          && lOldContacts.get(cObj.Id).Core_AGS_Integration_Status__c != 'Pending' && !String.isBlank(cObj.Core_Enterprise_Id__c)) 
                {
                    contactsWithPending.add(cObj);
                } else if(cObj.Core_AGS_Integration_Status__c == 'Pending' && cObj.Core_ERPM_Integration_Status__c == 'Successful'
                          && String.isBlank(lOldContacts.get(cObj.Id).Core_Enterprise_Id__c) && !String.isBlank(cObj.Core_Enterprise_Id__c)) 
                {
                    contactsWithPending.add(cObj);
                }
            }
            
            List<Core_Contact_Entitlement__c> lContEnt = new List<Core_Contact_Entitlement__c>();
            system.debug('contactsWithPending in AGS method==>'+contactsWithPending);
            if(contactsWithPending != null && !contactsWithPending.isEmpty()) {
                lContEnt = [SELECT id, Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c,
                            Core_Contact_Id__c, Core_Selected__c, Core_Entitlement_Id__r.Core_AGS_Role_Id__c,Core_Status__c
                            FROM Core_Contact_Entitlement__c
                            WHERE Core_Contact_Id__c IN :contactsWithPending AND Core_Entitlement_Id__r.Core_AGS_Role_Id__c != null];
            }
            Map<id,Core_Integration_Outbound_Message__c> mapMsg = new Map<id,Core_Integration_Outbound_Message__c>();
            for(Contact c : contactsWithPending) {
                currentContactId = c.Id;
                // Build up tags for log entry
                if (!String.isBlank(c.Core_eRPM_Person_Id__c))
                    tags += addTag(c.Core_eRPM_Person_Id__c);           
                if (!String.isBlank(c.Core_Enterprise_Id__c))
                    tags += addTag(c.Core_Enterprise_Id__c);
                if (!String.isBlank(c.Core_Login_Id__c))
                    tags += addTag(c.Core_Login_Id__c);           
                if (!String.isBlank(c.Email))
                    tags += addTag(c.Email);
                if (!String.isBlank(c.Id))
                    tags += addTag(c.Id);
                
                Core_Integration_Outbound_Message__c outboundMsg = new Core_Integration_Outbound_Message__c();
                AGS_Outbound_Msg_Wrapper agsOMW = new AGS_Outbound_Msg_Wrapper(c.Core_Enterprise_Id__c, Label.Core_Contact_Ent_AGS_Justification);
                
                for(Core_Contact_Entitlement__c ce : lContEnt) {  
                    
                    if(ce.Core_Contact_Id__c == c.Id && ce.Core_Selected__c == true && ce.Core_Status__c != 'In Progress' && ce.Core_Entitlement_Id__r.Core_AGS_Role_Id__c != null) {
                        
                        agsOMW.roles.add(ce.Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c);
                    }
                    if(ce.Core_Contact_Id__c == c.Id && ce.Core_Status__c == 'In Progress' && ce.Core_Entitlement_Id__r.Core_AGS_Role_Id__c != null) {
                        
                        agsOMW.InProgressRoles.add(ce.Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c);
                        
                    }
                }
                String strJSON = JSON.serialize(agsOMW);
                
                outboundMsg.Core_MessageType__c = 'AGS Contact Entitlement';
                outboundMsg.Core_Payload__c = '<![CDATA[' +  strJSON + ']]>';
                outboundMsg.Core_Tags__c = tags == null || tags.length() <= 255 ? tags : tags.substring(0, 255);
                
                lOutboundMsg.add(outBoundMsg);
                mapMsg.put(currentContactId, outBoundMsg);
            }
            if(lOutboundMsg != null && lOutboundMsg.size()>0) {
                insert lOutboundMsg;
                
                // Add contact message entries for each of the messages
                List<Contact_Message__c> ContactMsg = new List<Contact_Message__c>();
                for(Id cid : mapMsg.keySet()) ContactMsg.add(
                    new Contact_Message__c(Contact__c = cid, Outbound_Message__c = mapMsg.get(cid).id)
                );
                insert ContactMsg;
            }
            
        } catch(Exception ex) {
            String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
            System.debug('##### Exception: ' + exceptionMessage);    
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
    
    private static List<Core_Contact_Email_Notification_Disabler__mdt> getEmailDisableRuleRecords(String engagementId){
        
        System.debug('emailDisablerRuleRecords = '+ emailDisablerRuleRecords);
        
        if(!Test.isRunningTest()){ // Normal scenario, when the test execution doesn't happen
            if(emailDisablerRuleRecords != null && emailDisablerRuleRecords.isEmpty()){ //&& emailDisablerRuleRecords.isEmpty()
                emailDisablerRuleRecords =
                    [Select Core_Allowed_Entitlement_Ids__c,Core_Engagement_Id__c,Core_Excluded_Entitlement_Ids__c,Core_Is_the_Rule_Active__c from
                     Core_Contact_Email_Notification_Disabler__mdt where Core_Is_the_Rule_Active__c = true
                     and Core_Engagement_Id__c = :engagementId];
            }
        }else{
            emailDisablerRuleRecords = (List<Core_Contact_Email_Notification_Disabler__mdt>) 
                new ContactNotificationDisabler().getCustomMetadataRecords('SELECT Id,Label,Core_Allowed_Entitlement_Ids__c,Core_Engagement_Id__c,Core_Excluded_Entitlement_Ids__c,Core_Is_the_Rule_Active__c FROM Core_Contact_Email_Notification_Disabler__mdt WHERE DeveloperName = \'Default\'');
        }
        
        return emailDisablerRuleRecords;
    }
    
    private static Boolean IsEmailTriggerDisabledForEntitlement(Core_Contact_Entitlement__c coreContactEntitlement){
        
        Boolean engagementToBeExcluded = false;
        Id engagementId = coreContactEntitlement.Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__c;
        emailDisablerRuleRecords = getEmailDisableRuleRecords(engagementId);
        System.debug('emailDisablerRuleRecords ='+ emailDisablerRuleRecords);
        
        if(emailDisablerRuleRecords != null && !emailDisablerRuleRecords.isEmpty()){
            
            for(Core_Contact_Email_Notification_Disabler__mdt emailNotificationDisablerRec : emailDisablerRuleRecords){
                if(emailNotificationDisablerRec.Core_Engagement_Id__c != null && emailNotificationDisablerRec.Core_Engagement_Id__c == engagementId){
                    String excludedEntitlements = emailNotificationDisablerRec.Core_Excluded_Entitlement_Ids__c;
                    String allowedEntitlements = emailNotificationDisablerRec.Core_Allowed_Entitlement_Ids__c;
                    if(coreContactEntitlement.Core_Entitlement_Id__c != null && 
                       !String.isBlank(excludedEntitlements) &&
                       excludedEntitlements.contains(coreContactEntitlement.Core_Entitlement_Id__c)){
                           engagementToBeExcluded = true;
                       }else if(coreContactEntitlement.Core_Entitlement_Id__c != null && 
                                !String.isBlank(allowedEntitlements) &&
                                allowedEntitlements.contains(coreContactEntitlement.Core_Entitlement_Id__c)){
                                    engagementToBeExcluded = false; 
                                }else{
                                    engagementToBeExcluded = false;
                                }
                }  
            }
        }
        System.debug('Entitlement id = ' + coreContactEntitlement.Core_Entitlement_Id__c);
        System.debug('engagementToBeExcluded =' + engagementToBeExcluded);
        return engagementToBeExcluded;
        
    }
    
    public static void generateErpmOutboundMessage(List<Contact> lContacts, Map<Id,Contact> oldLstContacts) 
    {
        List<Core_Integration_Outbound_Message__c> lOutboundMsg = new List<Core_Integration_Outbound_Message__c>();
        Set<Core_Integration_Outbound_Message__c> sOutboundMsg = new Set<Core_Integration_Outbound_Message__c>();
        List<Core_Contact_Entitlement__c> lContactEnt = new List<Core_Contact_Entitlement__c>();
        List<Contact> contactsWithPending = new List<Contact>();
        List<Contact> updateContacts = new List<Contact>();
        System.debug('Core_Entitlement_Outbound_Integrations hasRun' + hasRun);
        if(!hasRun) {
            Id currentContactId;
            for(Contact cObj : lContacts) 
            {
                // && !cObj.Core_IPS_Employee_Customer__c added by Sugandha on 24 Nov 2017 for US79061
                System.debug('Core_ERPM_Integration_Queue_txt__c : ' +  cObj.Core_ERPM_Integration_Queue_txt__c + 'Core_ERPM_Integration_Status__c' + cObj.Core_ERPM_Integration_Status__c);
                
                if(cObj.Core_ERPM_Integration_Status__c == 'Pending' && cObj.Core_ERPM_Integration_Queue_txt__c != 'Full' 
                   && !cObj.Core_IPS_Employee_Customer__c) 
                {
                    contactsWithPending.add(cObj);
                }
            }
            
            List<Contact> lCont = new List<Contact>();
            System.debug('contactsWithPending = '+ contactsWithPending);
            
            if(contactsWithPending != null && !contactsWithPending.isEmpty()) 
            {
                lCont = [SELECT id, Core_eRPM_Person_Id__c, Core_Enterprise_Id__c, Core_Login_Id__c, FirstName, LastName,
                         Email, Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c, 
                         Core_Sales_Do_Not_Contact_Ind__c,Core_Do_Not_Contact_Dtm__c, Core_Do_Not_Contact__c,Core_Marketing_Do_Not_Contact_Dtm__c,  Salutation,Core_Profession__c,
                         Core_Job_Function_Code__c, MailingStreet, MailingCity, MailingStateCode, MailingCountryCode,
                         MailingPostalCode, Phone, MobilePhone, Core_Preferred_Language__c, Account.Name, Account.Core_CNDA_Number__c, Account.Id,
                         Account.BillingStreet, Account.BillingCity, Account.BillingStateCode, Account.BillingCountryCode, Account.Core_CIM_ID__c,
                         Account.BillingPostalCode, Account.ShippingStreet, Account.ShippingCity, Account.ShippingStateCode, Account.ShippingCountryCode, 
                         Account.ShippingPostalCode, Account.Core_User_Defined_Phone_Number__c, Account.Core_Account_Legal_Name__c, Account.Core_IsODM__c,
                         MailingCountry, Account.BillingCountry,Account.ShippingCountry, Account.Core_B2B_ERPM_Account_Number__c, Account.Core_English_Only_Name__c,
                         Account.Core_Alternate_Language_Name__c, Core_Set_ERPM_Status_Bypass__c, Account.Core_User_Defined_Website__c, Account.Core_User_Defined_Number_of_Employees__c 
                         FROM Contact
                         WHERE id IN :contactsWithPending];
                
                
                System.debug('Zay - ' + lCont[0]);
                System.debug('Zay - ' + lCont[0].Core_English_Only_First_Name__c);
                System.debug('Zay - ' + lCont[0].Core_English_Only_Last_Name__c);
                System.debug('Zay - ' + lCont[0].Core_Set_ERPM_Status_Bypass__c);
                
                lContactEnt = [Select id, Core_Selected__c,Core_DontNotify__c,Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c,
                               Core_Contact_Id__c,Core_Entitlement_Id__r.Core_IsActive__c,Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Engagement_Type__c
                               FROM Core_Contact_Entitlement__c
                               WHERE Core_Contact_Id__c IN :contactsWithPending];
                
                System.debug('252 : lContactEnt = ' + lContactEnt);
                
                Map<Contact, List<Core_Contact_Entitlement__c>> mContEnt = new Map<Contact, List<Core_Contact_Entitlement__c>>();
                
                String tags = '';
                try
                {
                    Map<id,Core_Integration_Outbound_Message__c> mapMsg = new Map<id,Core_Integration_Outbound_Message__c>();
                    Organization org = [Select IsSandbox from Organization LIMIT 1];
                    for(Contact cObj : lCont) 
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
                        
                        
                        List<Core_Contact_Entitlement__c> lContactEntitlements = new List<Core_Contact_Entitlement__c>();
                        Core_Integration_Outbound_Message__c outboundMsg = new Core_Integration_Outbound_Message__c();
                        PersonAccountProfile pAcctProf = new PersonAccountProfile();
                        pAcctProf.PersonID = cObj.Core_eRPM_Person_Id__c;
                        pAcctProf.EnterpriseID = cObj.Core_Enterprise_Id__c;
                        pAcctProf.LoginID = cObj.Core_Login_Id__c;
                        pAcctProf.ExternalAttributes.ProfessionCode=cObj.Core_Profession__c ;
                        
                        
                        //pAcctProf.Profession = String.valueOf(cObj.Core_Profession__c);
                        // 2/10/2017 Add truncated fields check
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
                        //Gireesh:US942207:Adding SalesDoNotContact, MarketingDoNotContact, SalesDoNotContactDate, MarketingDoNotContactDate 
                        if(cObj.Core_Sales_Do_Not_Contact_Ind__c)//Sales Do Not Contact
                        {
                            pAcctProf.SalesDoNotContactFlag = 'Y';
                            pAcctProf.SalesDoNotContactDate = cObj.Core_Do_Not_Contact_Dtm__c;

                        }
                        else{
                            pAcctProf.SalesDoNotContactFlag = 'N';
                        }

                        if(cObj.Core_Do_Not_Contact__c) //Marketing Do Not Contact
                        {
                            pAcctProf.MarketingDoNotContactFlag = 'Y';
                            pAcctProf.MarketingDoNotContactDate = cObj.Core_Marketing_Do_Not_Contact_Dtm__c;

                        }
                        else{
                            pAcctProf.MarketingDoNotContactFlag='N';
                        }
                        
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
                        if(String.isNotBlank(cObj.MailingCountryCode)) {
                            PersonPhysicalAddresses phyAddr =new PersonPhysicalAddresses();
                            phyAddr.CountryCode = getISO2CountryCode(cObj.MailingCountryCode) !=null ? getISO2CountryCode(cObj.MailingCountryCode):getISO2CountryCode(cObj.Account.BillingCountryCode);
                            if(cObj.MailingStateCode != null){
                                phyAddr.State = cObj.MailingStateCode;
                            }
                            pAcctProf.PersonPhysicalAddresses.add(phyAddr);
                        }
                        
                        if(cObj.Phone != null) {
                            pAcctProf.PersonElectronicAddresses.add(new PersonElectronicAddresses('PHONE', cObj.Phone)); //, getISO2CountryCode(cObj.MailingCountry) Removed CountryCode 2/1/2017
                        } else if(String.isBlank(cObj.Phone) && !String.isBlank(oldLstContacts.get(cObj.id).Phone)) {
                            pAcctProf.PersonElectronicAddresses.add(new PersonElectronicAddresses('PHONE', ''));
                        }
                        if(cObj.MobilePhone != null) {
                            pAcctProf.PersonElectronicAddresses.add(new PersonElectronicAddresses('MOB', cObj.MobilePhone)); //, getISO2CountryCode(cObj.MailingCountry) Removed CountryCode 2/1/2017
                        } else if(String.isBlank(cObj.MobilePhone) && !String.isBlank(oldLstContacts.get(cObj.id).MobilePhone)) {
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
                        System.debug('AccountAddress : ' + acctProf.AccountPhysicalAddresses);
                        
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
                        
                        System.debug('lContactEnt = '+ lContactEnt);
                        
                        for(Core_Contact_Entitlement__c cEnt : lContactEnt) 
                        {
                            //System.debug('Comaparison Result = '+ (Label.Core_Exclude_Lead_Management_Engagement == Label.Core_MDF_DQYes));
                            
                            if(cEnt.Core_Contact_Id__c == cObj.Id && !IsEmailTriggerDisabledForEntitlement(cEnt))
                            {
                                if(cEnt.Core_Entitlement_Id__r.Core_IsActive__c) 
                                {
                                    String engCode = cEnt.Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c;
                                    Boolean selected = cEnt.Core_Selected__c;
                                    String action = '';
                                    if(selected) 
                                    {
                                        action = 'ENGSTSAPRD';
                                    } else 
                                    {
                                        action = 'ENGSTSRJTD';
                                    }
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
                        
                        // ------------------------------ ERPM Changes : BEGIN -------------------------------- //
                        
                        //List<PRM_AccountChannelMembership__c> acctMemberships = new List<PRM_AccountChannelMembership__c>();
                        //acctProf.MembershipCollections = GetMembershipCollection(cObj.Account.Id);                    
                        //System.debug(':::::::: acctProf.MembershipCollections ::::::::  ' + acctProf.MembershipCollections);
                        
                        RelationshipCollection prsnAcctRelationship = GetContactRelationship(cObj.Id,cObj.Account.Id);
                        System.debug(':::::::: prsnAcctRelationship ::::::::  ' + prsnAcctRelationship);
                        List<Relationship> accountContactRelationships = prsnAcctRelationship.relationshipCollection;
                        System.debug(':::::::: accountContactRelationships ::::::::  ' + accountContactRelationships);
                        
                        List<Membership> membershipList = GetMembershipCollection(cObj.Account.Id);
                        System.debug(':::::::: membershipList ::::::::  ' + membershipList);
                        
                        //Added outside if condition because of Subscriptions are need to be flown in eRPM for FPGA.
                        pAcctProf.Subscriptions = GetSubscriptions(cObj.Id);
                        system.debug(':::::::: pAcctProf.Subscriptions :::::::: ' + pAcctProf.Subscriptions);
                        
                        if(membershipList.size() > 0 && accountContactRelationships.size() > 0)
                        {                                                
                            acctProf.MembershipCollections = membershipList;
                            System.debug(':::::::: acctProf.MembershipCollections ::::::::  ' + acctProf.MembershipCollections);                      
                            
                            acctProf.RelationshipCollections = accountContactRelationships;
                            System.debug(':::::::: acctProf.RelationshipCollections ::::::::: ' + acctProf.RelationshipCollections);                                               
                            
                            acctProf.AccountBenefits = GetAccountBenefits(cObj.Account.Id);
                            system.debug(':::::::: acctProf.AccountBenefits :::::::: ' + acctProf.AccountBenefits);
                            
                            pAcctProf.LegalAgreements = GetLegalAgreements(cObj.Account.Id);
                            system.debug(':::::::: pAcctProf.LegalAgreements :::::::: ' + pAcctProf.LegalAgreements);                        
                            
                            // --Profile responses for accounts associated to IPA program ; Picking Questions that belong to IPA + Account of Type 'CSP'                        
                            acctProf.ResponsesCollections = GetProfileResponses(cObj.Account.Id);
                            system.debug(':::::::: pAcctProf.Responses :::::::: ' + acctProf.ResponsesCollections);  
                            
                        }
                        else if(membershipList.size() > 0 && !(accountContactRelationships.size() > 0))
                        {
                            System.debug('entered here membership');
                            for(Membership mbrshp : membershipList)
                            {
                                if(!prsnAcctRelationship.NewUser)
                                {
                                    mbrshp.EnggStatus = Label.ERPM_Engagement_Rejected_Sts;
                                    acctProf.MembershipCollections.add(mbrshp);
                                }
                            }
                            
                        }
                        
                        
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
                                System.debug('noncip membership' + membership);
                            }                        
                        }
                        
                        System.Debug('acctProf.MembershipCollections final'+acctProf.MembershipCollections);
                        // ------------------------------ ERPM Changes : START -------------------------------- //
                        if(acctProf !=null && (acctProf.MembershipCollections != null && acctProf.MembershipCollections.size() >0))
                            pAcctProf.AccountProfiles.add(acctProf);
                        else                    
                            pAcctProf.AccountProfiles = null;                    
                        // ------------------------------ ERPM Changes : END -------------------------------- //
                        
                        // Always add Sales Soft engagement
                        pAcctProf.Memberships.add(new Memberships('CRM_Cloud_Cntct', 'ENGSTSAPRD'));
                        String ChngAgentLoginId;
                        boolean isPSG = false;
                        
                        if(mSoftEngCodes.size() > 0) {
                            for(String key : mSoftEngCodes.keySet()) {
                                if(key == 'PSG_Basic' && !isPSG)
                                {
                                    //ChngAgentLoginId =([Select IsSandbox from Organization LIMIT 1].IsSandbox)?Label.ERPM_Change_Agent_ID_Pre_Prod_PSG:Label.ERPM_Change_Agent_ID_Prod_PSG;
                                    ChngAgentLoginId =(org.IsSandbox)?Label.ERPM_Change_Agent_ID_Pre_Prod_PSG:Label.ERPM_Change_Agent_ID_Prod_PSG;
                                    isPSG = true;
                                }
                                pAcctProf.Memberships.add(new Memberships(key, mSoftEngCodes.get(key)));
                            }
                        }                   
                        
                        System.debug('PersonAccountProfile : ' + pAcctProf);
                        System.debug('AccountProfile - membershipCollection full : ' + acctProf.MembershipCollections);
                        //System.debug('PersonAccountProfile.AccountProfiles.RelationshipCollections : '+ pAcctProf.AccountProfiles[0].RelationshipCollections);
                        ERPM_Outbound_Msg_Wrapper outboundMsgWrapper = new ERPM_Outbound_Msg_Wrapper();
                        outboundMsgWrapper.PersonAccountProfile = pAcctProf;
                        if(isPSG){
                            outboundMsgWrapper.ChgAgtLoginId = ChngAgentLoginId;
                        }
                        //Added by mahendra as per userstory US95251
                        for(Core_Contact_Entitlement__c cEnt : lContactEnt) { 
                            system.debug('==currentContactId==>>'+currentContactId);
                            system.debug('==cEnt.Core_DontNotify__c==>>'+cEnt.Core_DontNotify__c);
                            if(cEnt.Core_DontNotify__c &&  cEnt.Core_Contact_Id__c == currentContactId){   
                                outboundMsgWrapper.blnNotify=false;  
                            }               
                        }
                        //End by mahendra
                        String strJSON = JSON.serialize(outboundMsgWrapper);
                        
                        outboundMsg.Core_MessageType__c = 'ERPM Contact Entitlement';
                        outboundMsg.Core_Payload__c = '<![CDATA[' +  strJSON + ']]>';
                        outboundMsg.Core_Tags__c = tags == null || tags.length() <= 255 ? tags : tags.substring(0, 255);
                        
                        cObj.Core_ERPM_Integration_Status__c = 'In-Progress';
                        updateContacts.add(cObj);
                        lOutboundMsg.add(outBoundMsg);
                        mapMsg.put(currentContactId, outBoundMsg);
                        
                    }
                    if(lOutboundMsg != null && lOutboundMsg.size()>0) {
                        System.debug('Zay - Outbound Msg Inserted');
                        Core_Integration_Outbound_Message__c verifyboundMsg =new Core_Integration_Outbound_Message__c();
                        verifyboundMsg=lOutboundMsg[0];
                        System.debug('Any items?:'+ verifyboundMsg.Core_Payload__c);
                        insert lOutboundMsg;
                        
                        update updateContacts;
                        System.debug('Updated these contacts : ' + updateContacts);
                        
                        // Add contact message entries for each of the messages
                        List<Contact_Message__c> ContactMsg = new List<Contact_Message__c>();
                        for(Id cid : mapMsg.keySet()) ContactMsg.add(
                            new Contact_Message__c(Contact__c = cid, Outbound_Message__c = mapMsg.get(cid).id)
                        );
                        insert ContactMsg;
                        hasRun = true;
                    }
                } catch(Exception ex) {
                    String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
                    System.debug('##### Exception: ' + exceptionMessage);    
                    Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_ERPM_SCOPE, LOG_ENTRY_ERROR,
                                                         'Error generating ERPM OBM', '', currentContactId, LOG_ENTRY_OBJECT, tags, ex);
                }
            }
        }
    }
    
    // ----------- #REGION :: eRPM - IPA Changes :: START ------------- //
    
    //Get the list of account memberships for generate payload to eRPM wrt IPA engg and AccountType as CSP
    private static List<Membership> GetMembershipCollection(Id accountId)
    {        
        List<Membership> membership = new List<Membership>();
        //PMD Issue Fix
        List<PRM_AccountChannelMembership__c> acms = new List<PRM_AccountChannelMembership__c>();
        Set<String> acmStatuses = new Set<String>();
        Set<String> acmTiers = new Set<String>();
        Map<String,String> acmStsERPMKeyValueMap = new Map<String,String>();
        Map<String,String> acmTierERPMKeyValueMap = new Map<String,String>();
        
        //Added by Naresh Yendluri to resolve PMD scan issue -  PMD Issue Fix
        for(PRM_AccountChannelMembership__c acctMembership : [SELECT Id, PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Channel_Program_Id__r.IsActive, 
                                                              PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c,PRM_Account_Id__r.Core_Account_Type__c,PRM_Status_Nm__c 
                                                              FROM PRM_AccountChannelMembership__c 
                                                              WHERE PRM_Channel_Program_Id__r.PRM_programCode__c =: Label.PRM_IPAEngagement 
                                                              AND PRM_Account_Id__r.Core_Account_Type__c INCLUDES ('Cloud Service Provider (CSP)')
                                                              AND PRM_Partner_Role__c =: Label.PRM_Service_Provider
                                                              AND PRM_Status_Nm__c != 'Pending'
                                                              AND PRM_Account_Id__c=: accountId AND PRM_Channel_Program_Id__r.IsActive = true]) 
        {
            IPATier = acctMembership.PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c;
            acms.add(acctMembership);
            acmStatuses.add(acctMembership.PRM_Status_Nm__c);
            acmTiers.add(acctMembership.PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c );
        }
        
        if(acmStatuses.size() > 0) {
            for(ERPM_SF_MAPPING_SETTING__mdt eRPMSFMapping :  [SELECT SF_KeyValue__c, eRPM_KeyValue__c FROM ERPM_SF_MAPPING_SETTING__mdt 
                                                               WHERE Mappting_Type__c =: Label.PRM_Engagement_Status AND eRPM_EngagementCodes__c =:  Label.PRM_CSPx2EngagementCode
                                                               AND SF_KeyValue__c IN :acmStatuses]){
                                                                   acmStsERPMKeyValueMap.put(eRPMSFMapping.SF_KeyValue__c.toUpperCase(), eRPMSFMapping.eRPM_KeyValue__c );
                                                               }
            system.debug('acmStsERPMKeyValueMap : '+ acmStsERPMKeyValueMap);
        }
        system.debug('acmTiers : ' +acmTiers);
        if(acmTiers.size() > 0) {
            for(ERPM_SF_MAPPING_SETTING__mdt eRPMSFMapping :  [SELECT SF_KeyValue__c, eRPM_KeyValue__c FROM ERPM_SF_MAPPING_SETTING__mdt 
                                                               WHERE Mappting_Type__c =: Label.PRM_ProgramLevel 
                                                               AND eRPM_EngagementCodes__c =:   Label.PRM_CSPx2EngagementCode
                                                               AND SF_KeyValue__c IN: acmTiers ]){
                                                                   acmTierERPMKeyValueMap.put(eRPMSFMapping.SF_KeyValue__c.toUpperCase(), eRPMSFMapping.eRPM_KeyValue__c );
                                                               }
            system.debug('acmTierERPMKeyValueMap : '+ acmTierERPMKeyValueMap);
        }
        
        for(PRM_AccountChannelMembership__c acctMembership : acms) 
        {
            //This will change.Currently the tier is mentioned at Channel Program level and not at individual engg. level.            
            system.debug('acctMembership.PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c :::: ' + acctMembership.PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c);
            Membership enggCodeTierAndStatus=new Membership();
            enggCodeTierAndStatus.EngagementCode = Label.PRM_CSPx2EngagementCode;
            enggCodeTierAndStatus.EnggStatus = (acmStsERPMKeyValueMap.containsKey(acctMembership.PRM_Status_Nm__c.toUpperCase())) ? acmStsERPMKeyValueMap.get(acctMembership.PRM_Status_Nm__c.toUpperCase()): null ;
            System.debug('Engagement Status : ' + enggCodeTierAndStatus.EnggStatus);
            enggCodeTierAndStatus.Tier = (acmTierERPMKeyValueMap.containsKey(acctMembership.PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c.toUpperCase())) ? acmTierERPMKeyValueMap.get(acctMembership.PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c.toUpperCase()): null ;
            System.debug('Engagement Tier : ' + enggCodeTierAndStatus.Tier);
            /*
enggCodeTierAndStatus.EnggStatus =  [SELECT eRPM_KeyValue__c FROM ERPM_SF_MAPPING_SETTING__mdt 
WHERE Mappting_Type__c =: Label.PRM_Engagement_Status AND eRPM_EngagementCodes__c =:  enggCodeTierAndStatus.EngagementCode
AND SF_KeyValue__c =: acctMembership.PRM_Status_Nm__c LIMIT 1].eRPM_KeyValue__c; 
System.debug('Engagement Status : ' + enggCodeTierAndStatus.EnggStatus);
enggCodeTierAndStatus.Tier = [SELECT eRPM_KeyValue__c FROM ERPM_SF_MAPPING_SETTING__mdt 
WHERE Mappting_Type__c =: Label.PRM_ProgramLevel 
AND eRPM_EngagementCodes__c =:  enggCodeTierAndStatus.EngagementCode
AND SF_KeyValue__c =: acctMembership.PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c LIMIT 1].eRPM_KeyValue__c; 
System.debug('Engagement Tier : ' + enggCodeTierAndStatus.Tier);
*/
            membership.add(enggCodeTierAndStatus);
            
        }  
        System.debug(':::::::: GetMembershipCollection ::::::::: ' + membership);
        return membership;
    }
    
    //This is added temporarily for the demo to show relationships with CSPX2.  (by ERPM Team)
    //If the contact's Account has CSP as partner Role and relationship defined with IPA, get the list of contact relationships to generate payload to eRPM 
    private static RelationshipCollection GetContactRelationship(Id contactId, Id accountId)
    {   
        RelationshipCollection personAccountrelationships = new RelationshipCollection();
        personAccountrelationships.NewUser = true;
        //personAccountrelationships.NewSecondaryUser = Database.countQuery('SELECT COUNT(Id) from Contact WHERE Account.Id =: ' + accountId) > 1 ? true : false;
        //System.debug('Count : ' + Database.countQuery('SELECT COUNT(Id) from Contact WHERE Account.Id =: ' + accountId));
        List<Relationship> relationshipCollection = new List<Relationship>();        
        List<EngagementRelationship> lstEngRelColl  = new List<EngagementRelationship>();
        Relationship relation = new Relationship();
        
        //PMD Issue Fix
        List<PRM_Account_Contact_Relationship__c> acrs = new List<PRM_Account_Contact_Relationship__c>();
        set<String> acrRelCodes = new set<String>();        
        Map<String,String> acrRelCodeERPMKeyValueMap = new Map<String,String>();
        
        for(PRM_Account_Contact_Relationship__c acctContactRelationship : [SELECT Id, PRM_Account_Id__c, PRM_Contact_Id__c, PRM_Relationship_Id__c,
                                                                           PRM_InActive_Ind__c, PRM_Account_Id__r.Core_Account_Type__c,PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c,LastModifiedDate
                                                                           FROM PRM_Account_Contact_Relationship__c where PRM_Contact_Id__c=: contactId AND PRM_Contact_Id__r.Core_IPA_Partner_Role__c INCLUDES ('Service Provider') 
                                                                           AND PRM_Account_Id__c=: accountId AND PRM_Status_Nm__c != 'Pending Action'
                                                                           AND PRM_Account_Id__r.Core_Account_Type__c INCLUDES ('Cloud Service Provider (CSP)')]){
                                                                               
                                                                               acrs.add(acctContactRelationship);  
                                                                               if(!String.isEmpty(acctContactRelationship.PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c)){
                                                                                   acrRelCodes.add(acctContactRelationship.PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);  
                                                                               }            
                                                                           }
        if(acrs.size() > 0) {
            if(acrRelCodes.size() > 0){
                for(SF_ERPM_MAPPING_SETTING__mdt sfERPMMapping : [SELECT SF_KeyValue__c, eRPM_KeyValue__c FROM SF_ERPM_MAPPING_SETTING__mdt 
                                                                  WHERE Mapping_Type__c =: Label.PRM_Relationship AND eRPMEngagementCode__c =: Label.PRM_CSPx2EngagementCode
                                                                  AND SF_KeyValue__c IN :acrRelCodes]){
                                                                      acrRelCodeERPMKeyValueMap.put(sfERPMMapping.SF_KeyValue__c, sfERPMMapping.eRPM_KeyValue__c);
                                                                  }
            }
            for(PRM_Account_Contact_Relationship__c acctContactRelationship : acrs){
                
                personAccountrelationships.NewUser = false;
                relation.EngagementCode = Label.PRM_CSPx2EngagementCode;                                                                               
                EngagementRelationship enggRelationship = new EngagementRelationship();
                /*
enggRelationship.RelationshipCode = [SELECT eRPM_KeyValue__c FROM SF_ERPM_MAPPING_SETTING__mdt 
WHERE Mapping_Type__c =: Label.PRM_Relationship AND eRPMEngagementCode__c =: Label.PRM_CSPx2EngagementCode
AND SF_KeyValue__c =: acctContactRelationship.PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c LIMIT 1].eRPM_KeyValue__c;
*/ 
                enggRelationship.RelationshipCode = acrRelCodeERPMKeyValueMap.containsKey(acctContactRelationship.PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c) ? acrRelCodeERPMKeyValueMap.get(acctContactRelationship.PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c): null ;        
                // enggRelationship.RelationshipCode =                            
                enggRelationship.RelationshipStartDate = String.valueOf(acctContactRelationship.LastModifiedDate);
                if(!acctContactRelationship.PRM_InActive_Ind__c)
                {
                    lstEngRelColl.add(enggRelationship);
                }                                                              
            }
            
            if(lstEngRelColl != null && lstEngRelColl.size() > 0)
            {
                relation.EngRelationshipCollection = lstEngRelColl;
                relationshipCollection.add(relation);
                personAccountrelationships.relationshipCollection = relationshipCollection;
            }
            
        }  
        System.debug(':::::::: GetContactRelationship :::::::: ' + relationshipCollection);
        return personAccountrelationships;
    }
    
    //Get the list of account benefits for generate payload to eRPM 
    private static List<AccountBenefit> GetAccountBenefits(Id accountId)
    {
        List<AccountBenefit> accountBenefits = new List<AccountBenefit>();
        if(String.isEmpty(IPATier)) {
            return accountBenefits;
        }
        Set<Id> partnerBenefitIds = new Set<Id>();
        Set<Id> cspBenefitIds = new Set<Id>();
        List<PRM_AccountBenefitAssociation__c> acctBenefitAssocs = [SELECT PRM_Partner_Benefit_Id__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c, PRM_Status_Nm__c, PRM_Status_Reason_Txt__c, PRM_Status_Change_Dt__c
                                                                    FROM PRM_AccountBenefitAssociation__c
                                                                    WHERE PRM_Account_Id__c =: accountId
                                                                    AND PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.PRM_programCode__c =: Label.PRM_IPAEngagement
                                                                    AND PRM_Account_Id__r.Core_Account_Type__c INCLUDES ('Cloud Service Provider (CSP)') ];
        if(acctBenefitAssocs.size() > 0) {
            for(PRM_AccountBenefitAssociation__c acctBnftAssoc: acctBenefitAssocs ) {
                partnerBenefitIds.add(acctBnftAssoc.PRM_Partner_Benefit_Id__c);
            }
            for(PRM_VXBnftMatrix__c benefitMatrix : [SELECT PRM_Partner_Benefit_Id__c FROM PRM_VXBnftMatrix__c
                                                     WHERE PRM_Partner_Benefit_Id__c IN :partnerBenefitIds AND PRM_Partner_Role_Nm__c= :Label.PRM_Service_Provider AND PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c=: IPATier]){
                                                        cspBenefitIds.add(benefitMatrix.PRM_Partner_Benefit_Id__c);   
                                                     }
            if(cspBenefitIds.size() > 0) {
                for(PRM_AccountBenefitAssociation__c acctBnftAssoc : acctBenefitAssocs) {
                    if(cspBenefitIds.contains(acctBnftAssoc.PRM_Partner_Benefit_Id__c)) {            
                        AccountBenefit acctBnft = new AccountBenefit();
                        acctBnft.BenefitCode = acctBnftAssoc.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c;
                        acctBnft.EngagementCode = Label.PRM_CSPx2EngagementCode;                   
                        acctBnft.InactiveReason = acctBnftAssoc.PRM_Status_Nm__c == 'Inactive' ? acctBnftAssoc.PRM_Status_Nm__c: null;
                        acctBnft.InactiveReasonCode = acctBnftAssoc.PRM_Status_Nm__c == 'Inactive' ? Label.ERPM_BenefitCode_Other : null;
                        acctBnft.NoteText = acctBnftAssoc.PRM_Status_Reason_Txt__c;                                   
                        accountBenefits.add(acctBnft);
                    }
                } 
            }        
        }       
        system.debug(':::::::: accountBenefits :::::::: ' + accountBenefits);
        return accountBenefits;
    }
    
    //Get the list of account legal Agreements for generate payload to eRPM 
    private static List<LegalAgreement> GetLegalAgreements(Id accountId)
    {
        System.debug('accountId'+accountId);
        List<LegalAgreement> accountLegalAgreements = new List<LegalAgreement>();
        for(PRM_AccountLegalAgreemntAssociation__c ALA : [SELECT ID, PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c, PRM_Partner_Agreement_Id__r.PRM_Agreement_Category_Nm__c,
                                                          PRM_Agreement_Sign_Dt__c, PRM_Contact__r.FirstName, PRM_Contact__r.LastName, PRM_Contact__r.Core_Login_Id__c,PRM_Partner_Agreement_Id__r.PRM_Language_Codes__c
                                                          FROM PRM_AccountLegalAgreemntAssociation__c 
                                                          WHERE PRM_Account_Id__c =: accountId
                                                          AND PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.PRM_programCode__c =:Label.PRM_IPAEngagement
                                                          AND PRM_Partner_Agreement_Id__r.PRM_Partner_Role__c=:Label.PRM_Service_Provider
                                                          AND PRM_Account_Id__r.Core_Account_Type__c INCLUDES ('Cloud Service Provider (CSP)') ]){
                                                              LegalAgreement legalAgrmnt = new LegalAgreement();
                                                              legalAgrmnt.Name = ALA.PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c;
                                                              legalAgrmnt.Category = ALA.PRM_Partner_Agreement_Id__r.PRM_Agreement_Category_Nm__c;
                                                              legalAgrmnt.SignDate = ALA.PRM_Agreement_Sign_Dt__c;
                                                              legalAgrmnt.IsOrgBased = 'true';
                                                              legalAgrmnt.EngagementCode = Label.PRM_CSPx2EngagementCode;
                                                              SignedByUser signedby = new SignedByUser();
                                                              signedby.FirstName = ALA.PRM_Contact__r.FirstName;
                                                              signedby.LastName = ALA.PRM_Contact__r.LastName;
                                                              signedby.LoginId = ALA.PRM_Contact__r.Core_Login_Id__c;
                                                              legalAgrmnt.SignedBy = signedby;
                                                              legalAgrmnt.LangCode=ALA.PRM_Partner_Agreement_Id__r.PRM_Language_Codes__c!=null ? ALA.PRM_Partner_Agreement_Id__r.PRM_Language_Codes__c :'ENG';
                                                              accountLegalAgreements.add(legalAgrmnt);
                                                          }
        system.debug(':::::::: accountLegalAgreements :::::::: ' + accountLegalAgreements);
        return accountLegalAgreements;
    }
    
    //Get the list of contact subscriptions for generate payload to eRPM 
    private static List<Subscription> GetSubscriptions(Id contactId)
    {
        List<Subscription> psnSub = new List<Subscription>();
        System.debug('---- Contact Subscription begin ------');
        for(PRM_ContactSubscriptionAssociation__c contSub : [SELECT PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c,PRM_Partner_Subscription_Id__r.Name,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c 
                                                             FROM PRM_ContactSubscriptionAssociation__c
                                                             WHERE PRM_Contact_Id__c =: contactId] ) 
        {
            Subscription psnSubscription = new Subscription();
            psnSubscription.SubscriptionCode = contSub.PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c;
            psnSubscription.SubscriptionName = contSub.PRM_Partner_Subscription_Id__r.Name;
            psnSubscription.SubscriptionStatusCode = contSub.PRM_Status_Nm__c == 'Active' ? 'USER-SUB' :'USER-UNSUB';
            psnSubscription.UnSubscriptionReason = contSub.PRM_Status_Reason_Txt__c;
            psnSub.add(psnSubscription);
        }
        
        System.debug(':::::::: GetSubscriptions :::::::: : ' + psnSub);
        return psnSub;        
    }
    
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
                                                         System.debug('After adding to payload Profile responses' + responses);
                                                     }
        System.debug(':::::::: GetProfileResponses :::::::: : ' + responses);
        return responses;
    }    
    
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
                    if(acctObj.RecordTypeId != coMarketingRecordTypeId && acctObj.RecordTypeId != pAGRecordTypeId) //Added by Accenture - VD -> Check if the record type is not Co-Marketing
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
            System.debug('##### Exception: ' + exceptionMessage);    
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
    public static void generateOBMOnCIMUpdate(List<Account> lNewAccounts, Map<Id, Account> lOldAccounts) {
        System.debug('lOldAccounts'+lOldAccounts);
        /* List<Contact> lCont = [SELECT id, Core_ERPM_Integration_Status__c, AccountId FROM Contact WHERE AccountId IN :lNewAccounts
AND Core_Contact_B2B_Indicator__c = true];
Map<Account, Contact> mAcctContacts = new Map<Account,Contact>();
for(Contact conObj : lCont) {
if()
}*/
        List<Contact> contactsToUpdate = new List<Contact>();
        
        if(!runOnce) 
        {
            //Added to resolve PMD Scan issue fix.
            Map<Id,Contact> acctIdContactMap = new Map<Id,Contact>();  
            for(Contact cont: [SELECT id, Core_ERPM_Integration_Status__c, Core_Contact_B2B_Indicator__c, AccountId,
                               (SELECT Id FROM Account_Contact_Relationships__r WHERE PRM_Status_Nm__c='Complete') 
                               FROM Contact WHERE AccountId IN :lOldAccounts.keySet()
                               AND (Core_Contact_B2B_Indicator__c = true
                                    OR Core_IPA_Partner_Role__c INCLUDES ('Service Provider'))]){
                                        if(!acctIdContactMap.containsKey(cont.AccountId) && (cont.Core_Contact_B2B_Indicator__c || cont.Account_Contact_Relationships__r.size() > 0)){
                                            acctIdContactMap.put(cont.AccountId, cont);
                                        }
                                    }
            for(Account acctObj : lNewAccounts) 
            {   
                System.debug('acctObj'+acctObj);
                //Start of Changes - To check if the record type is not Core_Partner_Account_Group - US408340 - by Accenture 
                if(acctObj.RecordTypeId != coMarketingRecordTypeId && acctObj.RecordTypeId != pAGRecordTypeId) //Added by Accenture - VD -> Check if the record type is not Co-Marketing
                    //End of Changes - To check if the record type is not Core_Partner_Account_Group - US408340 - by Accenture 
                {
                    System.debug('Entered If');
                    if((acctIdContactMap.containsKey(acctObj.Id)) && (acctObj.Core_B2B_Entitlement__c == true || (acctObj.Core_Account_Type__c!=null && acctObj.Core_Account_Type__c.Contains(Label.PRM_Cloud_Service_Provider_CSP)))
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
                           || acctObj.Core_User_Defined_Number_of_Employees__c != lOldAccounts.get(acctObj.Id).Core_User_Defined_Number_of_Employees__c
                           || acctObj.Core_User_Defined_Phone_Number__c != lOldAccounts.get(acctObj.Id).Core_User_Defined_Phone_Number__c
                           || acctObj.Core_User_Defined_Website__c != lOldAccounts.get(acctObj.Id).Core_User_Defined_Website__c
                           || acctObj.Core_English_Only_Name__c != lOldAccounts.get(acctObj.Id).Core_English_Only_Name__c)) {
                               system.debug('acct update');
                               
                               //Added to resolve PMD Scan issue fix.                               
                               /*
List<Contact> lCont = [SELECT id, Core_ERPM_Integration_Status__c, Core_Contact_B2B_Indicator__c, AccountId FROM Contact WHERE AccountId= :acctObj.id
AND (Core_Contact_B2B_Indicator__c = true
OR Core_IPA_Partner_Role__c INCLUDES ('Service Provider'))
LIMIT 1];  
*/
                               Contact lCont = acctIdContactMap.containsKey(acctObj.Id) ? acctIdContactMap.get(acctObj.Id) : null ;
                               // TO check if the contact has atleast one relationship
                               if(lCont != null && (lCont.Core_Contact_B2B_Indicator__c || GetContactRelationship(lCont.Id,acctObj.id).relationshipCollection.size() > 0)) {
                                   //eRPM trigger logic - atb
                                   contactsToUpdate.add(new Contact(id=lCont.id
                                                                    //, Core_ERPM_Integration_Status__c='Pending'
                                                                   ));
                               }
                               
                           }
                    /*
if(lCont != null && lCont.size() > 0
&& (lCont[0].Core_Contact_B2B_Indicator__c || GetContactRelationship(lCont[0].Id,acctObj.id).relationshipCollection.size() > 0)) {
//eRPM trigger logic - atb
contactsToUpdate.add(new Contact(id=lCont[0].id
//, Core_ERPM_Integration_Status__c='Pending'
));
}

}
*/
                    
                }
            }
            runOnce = true;
        }
        if(contactsToUpdate != null && contactsToUpdate.size()>0) {
            //update contactsToUpdate;
            Core_ERPM_Outbound_Integration.evaluateAndSetERPMOutboundIntegrationStatus(contactsToUpdate,null,false);
        }
    }
    
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
    private class AGS_Outbound_Msg_Wrapper {
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
        String MarketingDoNotContactFlag {get; set; }
        DateTime SalesDoNotContactDate {get;set;}
        DateTime MarketingDoNotContactDate {get;set;}
        //String DoNotContactFlag { get; set; }
        String PersonTitle { get; set; }        
        String JobFunction { get; set; }
        //String Profession { get; set; }
        String LanguageCode { get ; set; }
        String CountryCode { get ; set; }
        
        List<PersonPhysicalAddresses> PersonPhysicalAddresses { get; set; }
        List<PersonElectronicAddresses> PersonElectronicAddresses { get; set; }        
        List<AccountProfiles> AccountProfiles { get; set; }
        List<Memberships> Memberships { get; set; }
        ExternalAttributes ExternalAttributes { get; set; }
        // ----------- #REGION :: eRPM Code Changes :: START ------------- //            
        List<LegalAgreement> LegalAgreements = new List<LegalAgreement>();
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
        String ProfessionCode='';
        
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
        
        List<Relationship> RelationshipCollections = new List<Relationship>();
        List<AccountBenefit> AccountBenefits = new List<AccountBenefit>();
        List<Response> ResponsesCollections = new List<Response>();
        
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
    
    private class Response
    {
        String QuestionCode { get; set; }
        String ResponseCode { get; set; }
        String ResponseValue { get; set; }
        String EngagementCode { get; set; }
    }
    
    private class Membership 
    {
        String EngagementCode { get; set; } 
        String EnggStatus { get; set; } 
        String Tier { get; set; } 
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
    }
    // ----------- #REGION :: eRPM Code Changes :: END ------------- //
}