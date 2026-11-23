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
*****************************************************************************************************************************************/

global class Core_Entitlement_Outbound_Integrations {
    public static Boolean runOnce = false;
    
    public static final String LOG_ENTRY_ORIGIN = 'SFDC';
    public static final String LOG_ENTRY_PROJECT = 'Entitlement';
    public static final String LOG_ENTRY_AGS_SCOPE = 'IntegrationInboundMessageAGS';
    public static final String LOG_ENTRY_ERPM_SCOPE = 'IntegrationInboundMessageERPM';
    public static final String LOG_ENTRY_BOXBACCOUNT_SCOPE = 'IntegrationInboundMessageBOXBACCOUNT';
    public static final String LOG_ENTRY_ERROR = 'error';
    public static final String LOG_ENTRY_INFO = 'info';
    public static final String LOG_ENTRY_OBJECT = 'Core_Integration_Outbound_Message__c';
    
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
                if(cs.ISO_Code__c == countrycode){
                    if(Core_IPS_Labels__c.SObjectType.getDescribe().isAccessible()){   
                        return cs.Country_Code__c;
                    }
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
                   && lOldContacts.get(cObj.Id).Core_ERPM_Integration_Status__c != 'Successful' && !String.isBlank(cObj.Core_Enterprise_Id__c)) {
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
                if (Schema.sObjectType.Core_Integration_Outbound_Message__c.fields.Core_MessageType__c.isCreateable()) {
                outboundMsg.Core_MessageType__c = 'AGS Contact Entitlement';
                }
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


    public static void generateErpmOutboundMessage(List<Contact> lContacts, Map<Id,Contact> oldLstContacts) {
        List<Core_Integration_Outbound_Message__c> lOutboundMsg = new List<Core_Integration_Outbound_Message__c>();
        List<Core_Contact_Entitlement__c> lContactEnt = new List<Core_Contact_Entitlement__c>();
        List<Contact> contactsWithPending = new List<Contact>();
        
        Id currentContactId;
        for(Contact cObj : lContacts) {
            // && !cObj.Core_IPS_Employee_Customer__c added by Sugandha on 24 Nov 2017 for US79061
            if(cObj.Core_ERPM_Integration_Status__c == 'Pending' && !cObj.Core_IPS_Employee_Customer__c) {
                contactsWithPending.add(cObj);
            }
        }
        
        List<Contact> lCont = new List<Contact>();
        
        if(contactsWithPending != null && !contactsWithPending.isEmpty()) {
            lCont = [SELECT id, Core_eRPM_Person_Id__c, Core_Enterprise_Id__c, Core_Login_Id__c, FirstName, LastName,
                     Email, Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c, Core_Do_Not_Contact__c, Salutation,
                     Core_Job_Function_Code__c, MailingStreet, MailingCity, MailingStateCode, MailingCountryCode,
                     MailingPostalCode, Phone, MobilePhone, Account.Name, Account.Core_CNDA_Number__c, Account.Id,
                     Account.BillingStreet, Account.BillingCity, Account.BillingStateCode, Account.BillingCountryCode, 
                     Account.BillingPostalCode, Account.Phone, Account.Core_Account_Legal_Name__c, Account.Core_IsODM__c,
                     MailingCountry, Account.BillingCountry, Account.Core_B2B_ERPM_Account_Number__c, Account.Core_English_Only_Name__c,
                     Account.Core_Alternate_Language_Name__c, Core_Set_ERPM_Status_Bypass__c
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
            Map<Contact, List<Core_Contact_Entitlement__c>> mContEnt = new Map<Contact, List<Core_Contact_Entitlement__c>>();
            
            String tags = '';
            try{
            Map<id,Core_Integration_Outbound_Message__c> mapMsg = new Map<id,Core_Integration_Outbound_Message__c>();
            for(Contact cObj : lCont) {
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
                if(cObj.Core_Do_Not_Contact__c) {
                    pAcctProf.DoNotContactFlag = 'Y';
                } else {
                    pAcctProf.DoNotContactFlag = 'N';
                }
                pAcctProf.PersonTitle = getPersonTitle(cObj.Salutation); 
                
                // JobFunction is set to null until we have the correct values that ERPM uses 12/14/2016
                // JobFunction is being passed to ERPM as of 4/4/2017
                pAcctProf.JobFunction = cObj.Core_Job_Function_Code__c;
                
                //Send it empty for now because we need to come up with a solution when partial data is sent 12/14/2016
                //pAcctProf.PersonPhysicalAddresses.add(new PersonPhysicalAddresses(cObj.MailingStreet, cObj.MailingCity, cObj.MailingStateCode, getISO2CountryCode(cObj.MailingCountry), cObj.MailingPostalCode));
                
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
                
                AccountProfiles acctProf = new AccountProfiles(cObj.Account.Core_B2B_ERPM_Account_Number__c, cObj.Account.Name, cObj.Account.Core_CNDA_Number__c);
                String addressLine1 = '';
                String addressLine2 = '';
                List<String> lstAddressLine = smartSplit(cObj.Account.BillingStreet, 125);
                if(lstAddressLine != null && lstAddressLine.size() == 1) {
                    addressLine1 = lstAddressLine[0];
                }
                if(lstAddressLine != null && lstAddressLine.size()>1) {
                    addressLine1 = lstAddressLine[0];
                    addressLine2 = lstAddressLine[1];
                }
                acctProf.AccountPhysicalAddresses.add(new AccountPhysicalAddresses(addressLine1, addressLine2, cObj.Account.BillingCity, cObj.Account.BillingStateCode, getISO2CountryCode(cObj.Account.BillingCountry), cObj.Account.BillingPostalCode));
                if(cObj.Account.Phone != null) {
                    acctProf.AccountElectronicAddresses.add(new AccountElectronicAddresses(cObj.Account.Phone, getISO2CountryCode(cObj.Account.BillingCountry)));
                }
                Map<String,String> mEngCodes = new Map<String,String>();
                Map<String,String> mSoftEngCodes = new Map<String,String>();
                
                for(Core_Contact_Entitlement__c cEnt : lContactEnt) {
                    if(cEnt.Core_Contact_Id__c == cObj.Id) {
                        if(cEnt.Core_Entitlement_Id__r.Core_IsActive__c) {
                            String engCode = cEnt.Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c;
                            Boolean selected = cEnt.Core_Selected__c;
                            String action = '';
                            if(selected) {
                                action = 'ENGSTSAPRD';
                            } else {
                                action = 'ENGSTSRJTD';
                            }
                            if(cEnt.Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Engagement_Type__c == 'SEC') {
                                if(!mEngCodes.containsKey(engCode)) {                                
                                    mEngCodes.put(engCode, action);
                                } else {
                                    if(mEngCodes.get(engCode).equals('ENGSTSRJTD')) {
                                        mEngCodes.put(engCode, action);
                                    }
                                }
                            } else {
                                if(!mSoftEngCodes.containsKey(engCode)) {                                
                                    mSoftEngCodes.put(engCode, action);
                                } else {
                                    if(mSoftEngCodes.get(engCode).equals('ENGSTSRJTD')) {
                                        mSoftEngCodes.put(engCode, action);
                                    }
                                }
                            }
                        }             
                    }
                }
                // If no membership collections in AccountProfile set AccountProfile to null 12/14/2016
                if(mEngCodes.size() > 0) {
                    Set<String> keyset = mEngCodes.keySet();
                    for(String key : keyset) {
                        acctProf.MembershipCollections.add(new MembershipCollections(key, mEngCodes.get(key)));
                    }
                    acctProf.ExternalSystems.add(new ExternalSystems(cObj.Account.Id));
                    // Adding null checks until validation rules are complete
                    // 2/10/2017 Adding truncated fields check
                    if(cObj.Account.Core_Account_Legal_Name__c != null && !String.isBlank(cObj.Account.Core_Account_Legal_Name__c)) {
                        String truncName = cObj.Account.Core_Account_Legal_Name__c;
                        if(truncName.length() > 129) {
                            truncName = truncName.substring(0,129);
                        }
                        acctProf.AccountNameCollections.add(new AccountNameCollections(truncName, 'ACTNMTYLGL'));
                    }
                    if(cObj.Account.Core_English_Only_Name__c != null && !String.isBlank(cObj.Account.Core_English_Only_Name__c)) {
                        String truncName = cObj.Account.Core_English_Only_Name__c;
                        if(truncName.length() > 129) {
                            truncName = truncName.substring(0,129);
                        }
                        acctProf.AccountNameCollections.add(new AccountNameCollections(truncName, 'ACTNMTYENG'));
                    }
                    if(cObj.Account.Core_Alternate_Language_Name__c != null && !String.isBlank(cObj.Account.Core_Alternate_Language_Name__c)) {
                        acctProf.AccountNameCollections.add(new AccountNameCollections(cObj.Account.Core_Alternate_Language_Name__c, 'ACTNMTYALS'));
                    }
                    if(cObj.Account.Core_IsODM__c) {
                        acctProf.AccountTypeCollections.add(new AccountTypeCollections());
                    }
                    pAcctProf.AccountProfiles.add(acctProf);
                } else {
                    pAcctProf.AccountProfiles = null;
                }
                
                // Always add Sales Soft engagement
                pAcctProf.Memberships.add(new Memberships('CRM_Cloud_Cntct', 'ENGSTSAPRD'));
                
                if(mSoftEngCodes.size() > 0) {
                    Set<String> keyset = mSoftEngCodes.keySet();
                    for(String key : keyset) {
                        pAcctProf.Memberships.add(new Memberships(key, mSoftEngCodes.get(key)));
                    }
                }
                for(Core_Contact_Entitlement__c cEnt : lContactEnt) {
                    
                }
                ERPM_Outbound_Msg_Wrapper outboundMsgWrapper = new ERPM_Outbound_Msg_Wrapper();
                outboundMsgWrapper.PersonAccountProfile = pAcctProf;
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
                
                lOutboundMsg.add(outBoundMsg);
                mapMsg.put(currentContactId, outBoundMsg);
            }
            if(lOutboundMsg != null && lOutboundMsg.size()>0) {
                System.debug('Zay - Outbound Msg Inserted');
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
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_ERPM_SCOPE, LOG_ENTRY_ERROR,
                                     'Error generating ERPM OBM', '', currentContactId, LOG_ENTRY_OBJECT, tags, ex);
            }
        }
    }
    public static void generateBoxBAccountOutboundMessage(List<Account> lNewAccounts, Map<Id, Account> lOldAccounts) {
        Set<Id> sAcctIds = new Set<Id>();
        List<Core_Integration_Outbound_Message__c> lOutboundMsg = new List<Core_Integration_Outbound_Message__c>();
        List<BoxB_AccountWrapper> boxBAccounts = new List<BoxB_AccountWrapper>();
        Id currentAccountId;
        String tags = '';
        try {  
        if(lNewAccounts != null && lNewAccounts.size() >0) {
            for(Account acctObj : lNewAccounts) {
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
                      
                      String strJSON = JSON.serialize(baw);
                      
                      Core_Integration_Outbound_Message__c outboundMsg = new Core_Integration_Outbound_Message__c();
                      outboundMsg.Core_MessageType__c = 'BoxB Account';
                      outboundMsg.Core_Payload__c ='<![CDATA[' +  strJSON + ']]>';
                      outboundMsg.Core_Tags__c = tags == null || tags.length() <= 255 ? tags : tags.substring(0, 255);
                      
                      lOutboundMsg.add(outboundMsg);
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
    public static void generateOBMOnCIMUpdate(List<Account> lNewAccounts, Map<Id, Account> lOldAccounts) {
        /* List<Contact> lCont = [SELECT id, Core_ERPM_Integration_Status__c, AccountId FROM Contact WHERE AccountId IN :lNewAccounts
        AND Core_Contact_B2B_Indicator__c = true];
        Map<Account, Contact> mAcctContacts = new Map<Account,Contact>();
        for(Contact conObj : lCont) {
        if()
        }*/
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Contact> lCont;
        
        if(!runOnce) {
            for(Account acctObj : lNewAccounts) {
                if(acctObj.Core_B2B_Entitlement__c == true 
                   && (acctObj.Core_Account_Legal_Name__c != lOldAccounts.get(acctObj.Id).Core_Account_Legal_Name__c
                       || acctObj.BillingCity != lOldAccounts.get(acctObj.Id).BillingCity
                       || acctObj.BillingCountry != lOldAccounts.get(acctObj.Id).BillingCountry
                       || acctObj.BillingState != lOldAccounts.get(acctObj.Id).BillingState
                       || acctObj.BillingPostalCode != lOldAccounts.get(acctObj.Id).BillingPostalCode
                       || acctObj.BillingStreet != lOldAccounts.get(acctObj.Id).BillingStreet
                       || acctObj.Name != lOldAccounts.get(acctObj.Id).Name
                       || acctObj.Core_CIM_ID__c != lOldAccounts.get(acctObj.Id).Core_CIM_ID__c
                       || acctObj.Core_English_Only_Name__c != lOldAccounts.get(acctObj.Id).Core_English_Only_Name__c)) {
                           
                                   if(Contact.SObjectType.getDescribe().isAccessible()){
                                       lCont = [SELECT id, Core_ERPM_Integration_Status__c, AccountId FROM Contact WHERE AccountId= :acctObj.id
                                                  AND Core_Contact_B2B_Indicator__c = true LIMIT 1];
                                   }
                           if(lCont != null && lCont.size()>0) {
                               Contact c = new Contact(id=lCont[0].id, Core_ERPM_Integration_Status__c='Pending');
                               contactsToUpdate.add(c);
                           }
                       }
            }
            runOnce = true;
        }
        if(contactsToUpdate != null && contactsToUpdate.size()>0) {
            update contactsToUpdate;
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
        String DoNotContactFlag { get; set; }
        String PersonTitle { get; set; }        
        String JobFunction { get; set; }
        
        List<PersonPhysicalAddresses> PersonPhysicalAddresses { get; set; }
        List<PersonElectronicAddresses> PersonElectronicAddresses { get; set; }
        List<AccountProfiles> AccountProfiles { get; set; }
        List<Memberships> Memberships { get; set; }
        
        public PersonAccountProfile() {
            PersonPhysicalAddresses = new List<PersonPhysicalAddresses>();
            PersonElectronicAddresses = new List<PersonElectronicAddresses>();
            AccountProfiles = new List<AccountProfiles>();
            Memberships = new List<Memberships>();
        }
        
    }
    
    private class PersonPhysicalAddresses {
        String AddressType;
        String LocationType;
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
        List<AccountPhysicalAddresses> AccountPhysicalAddresses { get; set; }
        List<AccountElectronicAddresses> AccountElectronicAddresses { get; set; }
        List<MembershipCollections> MembershipCollections { get; set; }
        List<ExternalSystems> ExternalSystems { get; set; }
        List<AccountNameCollections> AccountNameCollections { get; set; }
        List<AccountTypeCollections> AccountTypeCollections { get; set; }
        public AccountProfiles(String aNum, String aName, String agreementNum) {
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
            MembershipCollections = new List<MembershipCollections>();
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
        public AccountPhysicalAddresses(String aLine1, String aLine2, String cityValue, String stateValue, String cCode, String pCode) {
            AddressType = 'PHY';
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
        public AccountElectronicAddresses(String eAddressText, String cCode) {
            ElectronicAddressType = 'PHONE';
            LocationType = 'HOME';
            ElectronicAddressText = eAddressText;
            CountryCode = cCode;
        }
    }  
    private class MembershipCollections {
        String EngagementCode;
        String EnggStatus;
        public MembershipCollections(String engCode, String engStatus) {
            EngagementCode = engCode;
            EnggStatus = engStatus;
        }
    }  
    private class ExternalSystems {
        String Name;
        String Value;
        public ExternalSystems(String val) {
            Name = 'SLSCLDID';
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
}