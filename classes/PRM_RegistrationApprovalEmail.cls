/********************************************************************************************************************************************
Class Name    : PRM_RegistrationApprovalEmail
    Version       : 1.0
    Created Date  : 10 June 2020
    Function      : To assign email logs and send emails to particular contacts on which entitlements are complete.
    After sending emails, related email queues will get complete
    
Modification Log :
     * Developer                                Date                 Description
 *--------------------------------------------------------------------------------------------------------------------------------------------
 *Bishal Singh/Rahul Kainth/Keerthan Nanjunda      10/06/2020           To assign email logs and send emails to particular contacts on which entitlements are complete.
After sending emails, related email queues will get complete
     *Srishty Sharma                                   2/11/2020            US821810: KIIT Secondary user created from PCR tab for the existing account- Welcome email is received twice.
Start Method updated with logic to check if older batch is still processing then new batch execution method will not run.
     *********************************************************************************************************************************************/

global class PRM_RegistrationApprovalEmail implements Database.Batchable<sObject>, Database.stateful {
    public static Set<Id> processedIds = new Set<Id>();
    global set<string> regIds = new Set<String>();
	public static final String LOG_ENTRY_ORIGIN  = 'PRM_RegistrationApprovalEmail';
	public static final String LOG_ENTRY_PROJECT = 'IPA';
	public static final String LOG_ENTRY_SCOPE   = 'SendWelcomeEmail';
	public static final String LOG_ENTRY_SEVERITY = 'Medium';

    
    // US821810-Start method will return null query if existing batch is in processing status.
    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> restrictedBusinessEvents = new List<String>();
        restrictedBusinessEvents = ((String) System.Label.PRM_RestrictedBusinessEvents).split(',');
        
        List<AsyncApexJob> inprogressJobList = [
            SELECT Id, Status, ApexClass.Name
            FROM AsyncApexjob
            WHERE Status = 'Processing'
            AND ApexClass.Name = 'PRM_RegistrationApprovalEmail'
        ]; // US821810-This will query current running job which is not completed.
        
        if (inprogressJobList.size() > 0) {
            // block started
            String nullQuery = 'Select Id,PRM_Business_Event__c,PRM_Contact__c,PRM_Tier__c,PRM_Contact__r.AccountId,PRM_Contact__r.Core_Preferred_Language__c,PRM_Contact__r.Email,PRM_Contact__r.Core_Do_Not_Contact__c,PRM_Status__c,PRM_PartnerRole__c,PRM_Registration_Request__c,CreatedDate from PRM_EmailQueue__c where IsDeleted=true AND IsDeleted=false';
            return Database.getQueryLocator(nullQuery); // US821810:returning querylocator with no records.
        } else {
            // US821810-block ends here..
            // block started
            String q = 'Select Id,PRM_Business_Event__c,PRM_Contact__c,PRM_Tier__c,PRM_Contact__r.AccountId,PRM_Contact__r.Account.Core_IPA_Badge_Tier__c,PRM_Contact__r.Core_Preferred_Language__c,PRM_Contact__r.Email,PRM_Contact__r.Core_Do_Not_Contact__c,PRM_Status__c,PRM_PartnerRole__c,PRM_Registration_Request__c,CreatedDate from PRM_EmailQueue__c where PRM_Status__c = \'PENDING\' AND PRM_Business_Event__c != \'\' AND PRM_Business_Event__c NOT IN: restrictedBusinessEvents ORDER BY PRM_Priority__c NULLS LAST,CreatedDate';
            return Database.getQueryLocator(q);
        } // US821810-block ends here..
    }
    
    global void execute(Database.BatchableContext bc, List<PRM_EmailQueue__c> emailQueueList) {
	    String errorMsg = '\n[Execute START] Records: ' + emailQueueList.size();
        for (PRM_EmailQueue__c eq : emailQueueList) {
            regIds.add(eq.PRM_Registration_Request__c);
        }
        try {
            sendWelcomeEmail(emailQueueList);

        } catch (Exception e) {
			errorMsg += '\nException: ' + e.getMessage();
			errorMsg += '\nStackTrace: ' + e.getStackTraceString();
			createLogEntry(errorMsg,LOG_ENTRY_ORIGIN,LOG_ENTRY_PROJECT,LOG_ENTRY_SCOPE,LOG_ENTRY_SEVERITY);

        }
    }
    
    public static void sendWelcomeEmail(List<PRM_EmailQueue__c> emailQueueList) {
        Map<String, PRM_EmailQueue__c> partnerRoleEmailQueueMap = new Map<String, PRM_EmailQueue__c>();
        Map<String, PRM_EmailConfiguration__mdt> mapEmailConfiguration = new Map<String, PRM_EmailConfiguration__mdt>();
        Map<String, PRM_EmailConfiguration__mdt> mapEmailConfigurationOnTier = new Map<String, PRM_EmailConfiguration__mdt>();
        Map<String, PRM_EmailQueue__c> mapOfProcessContactId = new Map<String, PRM_EmailQueue__c>();
        Set<String> partnerRoleonTier = new Set<String>();
        Map<String, PRM_EmailLog__c> mapOfEmailLog = new Map<String, PRM_EmailLog__c>();
        Set<String> regIdSet = new Set<String>(); // TWC729-4865 : to store Registration Request Id
        //boolean ipaRefresh = Boolean.valueOf(label.PRM_IPARefresh); // :RUBY - IPA 2.0 ADDED BY DINESH
        String errorMsg = '\n[sendWelcomeEmail START]';
        try {
            List<PRM_EmailConfiguration__mdt> emailConfigList = [
                SELECT Id, PRM_BusinessEvent__c, PRM_PartnerRole__c, PRM_Entitlement_List__c, PRM_Priority__c, PRM_Tier__c
                FROM PRM_EmailConfiguration__mdt
                ORDER BY PRM_Priority__c
            ];
            PRM_EmailConfiguration__mdt eConfig;
            for (PRM_EmailConfiguration__mdt emailCon : emailConfigList) {
                // map of business event+partner role , emailCon
                if (mapEmailConfiguration.containsKey((emailCon.PRM_BusinessEvent__c + emailCon.PRM_PartnerRole__c).toLowercase())) {
                    eConfig = mapEmailConfiguration.get((emailCon.PRM_BusinessEvent__c + emailCon.PRM_PartnerRole__c).toLowercase());
                    mapEmailConfiguration.remove((emailCon.PRM_BusinessEvent__c + emailCon.PRM_PartnerRole__c).toLowerCase());
                    mapEmailConfigurationOnTier.put((eConfig.PRM_BusinessEvent__c + eConfig.PRM_PartnerRole__c + eConfig.PRM_Tier__c).toLowercase(), eConfig);
                    mapEmailConfigurationOnTier.put((emailCon.PRM_BusinessEvent__c + emailCon.PRM_PartnerRole__c + emailCon.PRM_Tier__c).toLowercase(), emailCon);
                    partnerRoleonTier.add(emailCon.PRM_PartnerRole__c.toLowercase());
                } else if (partnerRoleonTier.contains(emailCon.PRM_PartnerRole__c.toLowercase())) {
                    mapEmailConfigurationOnTier.put((emailCon.PRM_BusinessEvent__c + emailCon.PRM_PartnerRole__c + emailCon.PRM_Tier__c).toLowercase(), emailCon);
                } else {
                    mapEmailConfiguration.put((emailCon.PRM_BusinessEvent__c + emailCon.PRM_PartnerRole__c).toLowercase(), emailCon);
                 }
            }
            errorMsg+= '\nmapEmailConfiguration : '+mapEmailConfiguration.keySet();
            Map<id, Contact> mapContact = new Map<id, Contact>();
            List<Id> conIds = new List<Id>();
            for (PRM_EmailQueue__c eq : emailQueueList) {
                conIds.add(eq.PRM_Contact__c);
            }

            
            Set<Id> onePartnerIds = new Set<Id>();
            
            // get opid account and benefit details
            Map<Id, contactWrapper> contactWrapperMap = new Map<Id, contactWrapper>();
            if (!emailQueueList.isEmpty()) {
                for (Contact con : [
                    SELECT Name, Email,Account.Core_IPA_One_Partner_Id__c, AccountId, id, Core_Preferred_Language__c, Core_Do_Not_Contact__c
                    FROM Contact
                    WHERE id IN :conIds
                ]) {
                    mapContact.put(con.id, con);
                    onePartnerIds.add(con.Account.Core_IPA_One_Partner_Id__c);
                    /*if(ipaRefresh){*/
                        contactWrapper wrap = new contactWrapper();
                        wrap.contactId = con.Id;
                        wrap.accountId = con.accountId;
                        wrap.onePartnerId= con.Account.Core_IPA_One_Partner_Id__c;
                        contactWrapperMap.put(con.id, wrap);
                    //} // IPA refresh - switch removal
                }
            }
            
            
            //IPA 2.0 Refresh changes : Dinesh
            // get aggregated benefits
            Map<Id, Integer> accountIdToBnftMap = new Map<Id, Integer>();
            List<AggregateResult> aggrResult = new List<AggregateResult>();
            // get OPID Benefits
            if(/*ipaRefresh &&*/ !onePartnerIds.isEmpty() && onePartnerIds!=null){
                aggrResult = [select count(Id) benefitsCount, PRM_Account_Id__c  from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c in :onePartnerIds  and PRM_Status_Nm__c ='Active' group by PRM_Account_Id__c];
                for(AggregateResult result : aggrResult){
                    accountIdToBnftMap.put((Id)result.get('PRM_Account_Id__c'), (integer)result.get('benefitsCount'));
                }
			errorMsg += '\naccountIdToBnftMap : ' + accountIdToBnftMap;
            }
            
            Map<String, String> mapOfContactEntitlement = new Map<String, String>();
            Map<String, String> mapOfContactandBusinessEvent = new Map<String, String>();
            for (PRM_EmailQueue__c ec : emailQueueList) {
                processedIds.add(ec.Id);
                partnerRoleEmailQueueMap.put(ec.PRM_Contact__c, ec);
                if (mapEmailConfiguration.containsKey((ec.PRM_Business_Event__c + ec.PRM_PartnerRole__c).toLowercase())) {
                    String entitlements = '';
                    entitlements = mapEmailConfiguration.get((ec.PRM_Business_Event__c + ec.PRM_PartnerRole__c).toLowercase()).PRM_Entitlement_List__c;
                    mapOfContactEntitlement.put(ec.PRM_Contact__c, entitlements);
                    mapOfContactandBusinessEvent.put(ec.PRM_Contact__c, ec.PRM_Business_Event__c);
                } else if (mapEmailConfigurationOnTier.containsKey((ec.PRM_Business_Event__c + ec.PRM_PartnerRole__c + ec.PRM_Tier__c).toLowercase())) {
                    String entitlements = '';
                    entitlements = mapEmailConfigurationOnTier.get((ec.PRM_Business_Event__c + ec.PRM_PartnerRole__c + ec.PRM_Tier__c).toLowercase()).PRM_Entitlement_List__c;
                    mapOfContactEntitlement.put(ec.PRM_Contact__c, entitlements);
                    mapOfContactandBusinessEvent.put(ec.PRM_Contact__c, ec.PRM_Business_Event__c);
                }
            }
	        errorMsg += '\npartnerRoleEmailQueueMap : ' + partnerRoleEmailQueueMap.keySet();
            
            Map<String, Set<String>> mapOfQueueContactEntitlement = new Map<String, Set<String>>();
            for (String contactId : mapOfContactEntitlement.keySet()) {
                String en = mapOfContactEntitlement.get(contactId);
                Set<String> finalSetOfQueueEntitlements = new Set<String>(en.split(','));
                mapOfQueueContactEntitlement.put(contactId, finalSetOfQueueEntitlements);
            }
            
            Map<String, Set<String>> mapCoreContactEntitlement = new Map<String, Set<String>>();
            Map<String, Set<String>> mapfinalCoreContactEntitlement = new Map<String, Set<String>>();
            for (Core_Contact_Entitlement__c ce : [
                SELECT Id, Core_Contact_Id__c, Core_Entitlement_Id__r.Name
                FROM Core_Contact_Entitlement__c
                WHERE Core_Contact_Id__c IN :mapOfQueueContactEntitlement.keySet()
                AND Core_Status__c = 'Complete'
                AND Core_Type__c = 'Entitlement'
                AND Core_Selected__c = TRUE
            ]) {
                Set<String> finalCoreContactEntitlement = new Set<String>();
                if (mapOfQueueContactEntitlement.get(ce.Core_Contact_Id__c).contains(ce.Core_Entitlement_Id__r.Name)) {
                    if (mapCoreContactEntitlement.keySet().contains(ce.Core_Contact_Id__c)) {
                        mapCoreContactEntitlement.get(ce.Core_Contact_Id__c).add(ce.Core_Entitlement_Id__r.Name);
                    } else {
                        Set<String> coreContactEntitlement = new Set<String>();
                        coreContactEntitlement.add(ce.Core_Entitlement_Id__r.Name);
                        mapCoreContactEntitlement.put(ce.Core_Contact_Id__c, coreContactEntitlement);
                    }
                }
                if (mapfinalCoreContactEntitlement.get(ce.Core_Contact_Id__c) != null && !mapfinalCoreContactEntitlement.get(ce.Core_Contact_Id__c).IsEmpty()) {
                    finalCoreContactEntitlement = mapfinalCoreContactEntitlement.get(ce.Core_Contact_Id__c);
                }
                finalCoreContactEntitlement.add(ce.Core_Entitlement_Id__r.Name);
                mapfinalCoreContactEntitlement.put(ce.Core_Contact_Id__c, finalCoreContactEntitlement);
            }
	        errorMsg += '\nmapfinalCoreContactEntitlement : ' + mapfinalCoreContactEntitlement;

            Set<String> contactIdsToProcess = new Set<String>();
            for (String finalContactId : mapOfQueueContactEntitlement.keySet()) {
                if (mapCoreContactEntitlement.containsKey(finalContactId)) {
                    if (mapOfContactandBusinessEvent.get(finalContactId) == System.Label.PRM_OPIDGold_BusinessEvent || mapOfContactandBusinessEvent.get(finalContactId) == System.Label.PRM_OPIDTitanium_BusinessEvent) {
                        if (mapOfQueueContactEntitlement.get(finalContactId).containsAll(mapCoreContactEntitlement.get(finalContactId))) {
                            contactIdsToProcess.add(finalContactId);
                        }
                    } else {
                        if (mapCoreContactEntitlement.get(finalContactId).equals(mapOfQueueContactEntitlement.get(finalContactId))) {
                            contactIdsToProcess.add(finalContactId);
                        }
                    }
                }
            }
	        errorMsg += '\ncontactIdsToProcess: ' + contactIdsToProcess;
            
            Map<String, PRM_Language_Culture_Mapping__mdt> mapLangAndCountryToCulture = new Map<String, PRM_Language_Culture_Mapping__mdt>();
            for (PRM_Language_Culture_Mapping__mdt lngCultureMdt : [
                SELECT Id, MasterLabel, PRM_Culture__c, PRM_Country__c, PRM_Country_Cd__c
                FROM PRM_Language_Culture_Mapping__mdt
                WHERE PRM_Country_Cd__c != NULL
            ]) {
                mapLangAndCountryToCulture.put(lngCultureMdt.PRM_Country_Cd__c + lngCultureMdt.MasterLabel, lngCultureMdt);
                if (lngCultureMdt.PRM_Country_Cd__c.equalsIgnoreCase('us')) {
                    mapLangAndCountryToCulture.put('USDefault', lngCultureMdt);
                }
            }

            Map<String,Id> mapOfContactEmailtoId = new Map<String,Id>();
            if (!contactIdsToProcess.isEmpty()) { //ATHR Fix - TWC729-9556 - SJ
                List<PRM_Bulk_Data_Upload__c> bulkUploadrecord = [
                    SELECT Id, PRM_Contact_Id__c, PRM_Suppress_Email__c/*,PRM_ContactEmail__c*/
                    FROM PRM_Bulk_Data_Upload__c
                    WHERE PRM_Contact_Id__c IN :contactIdsToProcess
                    ORDER BY CreatedDate
                ];
				
                List<PRM_EmailUtility.EmailNotification> notiflist = new List<PRM_EmailUtility.EmailNotification>();
                for (Contact con : [
                    SELECT Id,email, MailingCountryCode, Core_Preferred_Language__c
                    FROM Contact
                    WHERE Id IN :contactIdsToProcess
                ]) {
                    mapOfContactEmailtoId.put(con.email,con.id);
                    PRM_Language_Culture_Mapping__mdt langCultureForEmail;
                    if (con.MailingCountryCode != null && String.isNotBlank(con.Core_Preferred_Language__c) && mapLangAndCountryToCulture.containsKey(con.MailingCountryCode + con.Core_Preferred_Language__c)) {
                        langCultureForEmail = mapLangAndCountryToCulture.get(con.MailingCountryCode + con.Core_Preferred_Language__c);
                    } else {
                        langCultureForEmail = mapLangAndCountryToCulture.get('USDefault');
                    }
                    
                    Boolean suppressIPAEmail = false;
                    if (bulkUploadrecord != null && !bulkUploadrecord.isEmpty()) {
                        suppressIPAEmail = bulkUploadrecord[0].PRM_Suppress_Email__c;
                    }
                    
                    if (/*(partnerRoleEmailQueueMap.keySet().contains(con.Id) && !ipaRefresh) ||*/ (/*ipaRefresh &&*/ partnerRoleEmailQueueMap.keySet().contains(con.Id) && contactWrapperMap.get(con.Id).onePartnerId!=null && accountIdToBnftMap.containsKey(contactWrapperMap.get(con.Id).onePartnerId) && accountIdToBnftMap.get(contactWrapperMap.get(con.Id).onePartnerId) > 0)) {
                        errorMsg += '\n***next is email utility creation***';
                        PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();
                        map<String, String> inputParameters = new Map<String, String>();
                        objEmailNotif.InputParameters = inputParameters;
                        objEmailNotif.BusinessEvent = partnerRoleEmailQueueMap.get(con.Id).PRM_Business_Event__c;
                        objEmailNotif.Language = mapContact.get(con.Id).Core_Preferred_Language__c;
                        objEmailNotif.ChannelProgram = System.Label.PRM_Intel_Partner_Alliance;
                        objEmailNotif.EmailID = mapContact.get(con.Id).Email;

                        if (objEmailNotif.BusinessEvent == System.Label.PRM_Welcome_Email_New_Event || objEmailNotif.BusinessEvent == System.Label.PRM_Welcome_Email_Existing_Event || objEmailNotif.BusinessEvent == System.label.PRM_Email_Admin_Approval_Event) {
                            inputParameters.put('Registration_Request_ID', partnerRoleEmailQueueMap.get(con.Id).PRM_Registration_Request__c);
                        }
                        
                        if (langCultureForEmail != null) {
                            inputParameters.put('LanguageCulture_MDT', langCultureForEmail.Id);
                        }
                        
                        if (objEmailNotif.BusinessEvent == System.Label.PRM_Email_Admin_Approval_Event) {
                            objEmailNotif.PartnerType = System.Label.PRM_CsP;
                        }
                        
                        if (!mapfinalCoreContactEntitlement.get(con.Id).contains(System.Label.PRM_Partner_Admin) && !mapfinalCoreContactEntitlement.get(con.Id).contains(System.Label.PRM_Admin_Delegate)) {
                            objEmailNotif.partnerAdmin = false;
                        }
                        
                        if (partnerRoleEmailQueueMap.get(con.Id).PRM_Business_Event__c == System.Label.PRM_OPIDGold_BusinessEvent || partnerRoleEmailQueueMap.get(con.Id).PRM_Business_Event__c == System.Label.PRM_OPIDTitanium_BusinessEvent) {
                            inputParameters.put('Contact_ID', con.Id);
                        } else {
                            inputParameters.put('Account_ID', mapContact.get(con.Id).AccountId);
                        }
                        
                        if (mapContact.get(con.Id).Core_Do_Not_Contact__c == false && suppressIPAEmail == false) {
                            notiflist.add(objEmailNotif);
                            mapOfProcessContactId.put(mapContact.get(con.Id).Email, partnerRoleEmailQueueMap.get(con.Id));
                        }
                    }
                }
		        errorMsg += '\nmapOfContactEmailtoId: ' + mapOfContactEmailtoId;
                if (!notiflist.isEmpty()) {
					errorMsg += '\nSending emails count: ' + notiflist.size();
					
                    regIdSet = PRM_EmailUtility.sendEmail(notiflist);
					errorMsg += '\nEmails sent. RegId count: ' + regIdSet.size();
					
		      
                }
                
                if (!regIdSet.IsEmpty() && Trigger.isExecuting) {
                    System.enqueueJob(new PRM_RegistrationTrackerUtility.UpdateTrackerSteps(regIdSet, null, null, 'PRM_RegistrationApprovalEmail', null));
                }
            }
            
            List<PRM_EmailLog__c> emailLogsToUpdate = new List<PRM_EmailLog__c>();
            Map<String, PRM_EmailLog__c> mapOfContactEmailLog = new Map<String, PRM_EmailLog__c>();
            
            for (PRM_EmailLog__c eLog : [
                SELECT Id, PRM_Subject__c, PRM_Contact__c, PRM_EmailContent__c, PRM_EmailHTMLContent__c, PRM_User__c, PRM_EmailDeliverabilityStatus__c, PRM_ToEmailID__c, Email_Template_Name__c, PRM_Contact__r.Core_Preferred_Language__c
                FROM PRM_EmailLog__c
                WHERE PRM_ToEmailID__c IN :mapOfProcessContactId.keySet()
                order by createddate
            ]) {
                mapOfContactEmailLog.put(eLog.PRM_ToEmailID__c, eLog);
            }
            
            Map<String, User> mapEmailToUser = new Map<String, User>();
            
            if (!mapOfContactEmailLog.isEmpty()) {
                for (User usr : [
                    SELECT id, Email, contactId
                    FROM User
                    WHERE contact.Email in :mapOfContactEmailLog.keySet()
                ]) {
                    mapEmailToUser.put(usr.Email, usr);
                }
            }
            
            for (String email : mapOfContactEmailLog.keyset()) {
                if (mapEmailToUser.containsKey(email) || mapOfContactEmailLog.containsKey(email)) {
                        mapOfContactEmailLog.get(email).PRM_Contact__c = mapEmailToUser.containsKey(email)? mapEmailToUser.get(email).ContactId: mapOfContactEmailtoId.get(email);
                    mapOfContactEmailLog.get(email).PRM_User__c = mapEmailToUser.containsKey(email) ? mapEmailToUser.get(email).id : null;
                    
                    if (String.isNotBlank(mapOfContactEmailLog.get(email).Email_Template_Name__c) && (mapOfContactEmailLog.get(email).Email_Template_Name__c.contains(System.Label.PRM_Registration_Template) || mapOfContactEmailLog.get(email).Email_Template_Name__c.contains(System.Label.PRM_Reuse_Registration_Template) || mapOfContactEmailLog.get(email).Email_Template_Name__c.contains(System.Label.PRM_OPID_GoldUpgrade_Template) || mapOfContactEmailLog.get(email).Email_Template_Name__c.contains(System.Label.PRM_OPID_TitaniumUpgrade_Template))) {
                        mapOfEmailLog.put(mapOfContactEmailLog.get(email).PRM_ToEmailID__c, mapOfContactEmailLog.get(email));
                    }
                    emailLogsToUpdate.add(mapOfContactEmailLog.get(email));
                }
            }
            
            if (emailLogsToUpdate.size() > 0) {
                Database.saveResult[] svreslt = Database.update(emailLogsToUpdate, false);
                for (Database.saveResult sr : svreslt) {
                    if (!sr.isSuccess()) {
                        System.debug('>>>>>' + sr.getErrors()[0].getMessage());
                    }
                }
            }
            
            List<PRM_EmailQueue__c> ipaEmailQueueToUpdate = new List<PRM_EmailQueue__c>();
            for (String email : mapOfProcessContactId.keySet()) {
                if (mapOfEmailLog.containsKey(email)) {
                    if (mapOfEmailLog.get(email).PRM_EmailDeliverabilityStatus__c == true) {
                        if (mapOfEmailLog.get(email).PRM_EmailHTMLContent__c != null) {
                            mapOfProcessContactId.get(email).PRM_Email_Content__c = mapOfEmailLog.get(email).PRM_EmailHTMLContent__c;
                        } else if (mapOfEmailLog.get(email).PRM_EmailContent__c != null) {
                            mapOfProcessContactId.get(email).PRM_Email_Content__c = mapOfEmailLog.get(email).PRM_EmailContent__c;
                        }
                        mapOfProcessContactId.get(email).PRM_Status__c = System.Label.PRM_Complete;
                    } else {
                        mapOfProcessContactId.get(email).PRM_Status__c = System.Label.PRM_Error;
                    }
                    ipaEmailQueueToUpdate.add(mapOfProcessContactId.get(email));
                }
            }
            
            if (ipaEmailQueueToUpdate.size() > 0) {
                Database.saveResult[] svreslt = Database.update(ipaEmailQueueToUpdate, false);
                for (Database.saveResult sr : svreslt) {
                    if (!sr.isSuccess()) {
                        System.debug('>>>>>' + sr.getErrors()[0].getMessage());
                    }
                }
            }
			errorMsg += '\n[sendWelcomeEmail END]';
			createLogEntry(errorMsg,LOG_ENTRY_ORIGIN,LOG_ENTRY_PROJECT,LOG_ENTRY_SCOPE,LOG_ENTRY_SEVERITY);
			
        } catch (Exception e) {
			errorMsg += '\nERROR in sendWelcomeEmail: ' + e.getMessage();
			errorMsg += '\nStackTrace: ' + e.getStackTraceString();
			createLogEntry(errorMsg,LOG_ENTRY_ORIGIN,LOG_ENTRY_PROJECT,LOG_ENTRY_SCOPE,LOG_ENTRY_SEVERITY);

            List<PRM_EmailQueue__c> emailQueueListUpdated = mapOfProcessContactId.values();
            if (emailQueueListUpdated.isEmpty()) {
                emailQueueListUpdated = new List<PRM_EmailQueue__c>();
                emailQueueListUpdated.addAll(emailQueueList);
            }
            for (PRM_EmailQueue__c emailqueue : emailQueueListUpdated) {
                if (emailqueue.PRM_Status__c != System.Label.PRM_Complete || emailqueue.PRM_Status__c != System.Label.PRM_Error) {
                    emailqueue.PRM_Status__c = System.Label.PRM_Error;
                }
            }
            Database.update(emailQueueListUpdated, false);
	    
        }
    }
    
    public class contactWrapper{
        string contactId{get;set;}
        string accountId{get;set;}
        string onePartnerId{get;set;}
    }
    
    global void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()
        ];
        if (regIds.size() > 0 && System.Label.PRM_Tracker_Enabled == 'true') {
            System.enqueueJob(new PRM_RegistrationTrackerUtility.UpdateTrackerSteps(regIds, null, null, 'PRM_RegistrationApprovalEmail', null));
        }
    }
	public static void createLogEntry(String message,String origin,String project,String scope,String severity) {
    String jobTime = System.now().format('MM/dd/yyyy HH:mm:ss', 'PST');
    if (String.isNotBlank(message)) {
        PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility = new PRM_ProcessInboundOPIDLogEntriesUtility();
        Integer fieldLength = Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength();
        logEntryUtility.addLogEntry(message, fieldLength);
        for (Integer i = 0; i < logEntryUtility.logEntryList.size(); i++) {
            Core_Log_Entry.logEntryWithDetails(origin,project,scope,severity,'Batch log at: ' + jobTime,logEntryUtility.logEntryList[i],'','','');
        }
    }
}
}