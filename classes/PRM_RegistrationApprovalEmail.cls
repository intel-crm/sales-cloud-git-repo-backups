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
Start Method updated with logic to check if older batch is still processing then new batch execution mehtod will not run.
*********************************************************************************************************************************************/

global class PRM_RegistrationApprovalEmail implements Database.Batchable<sObject>, Database.stateful {
    public static Set<Id> processedIds = new Set<Id>();
    global set<string> regIds = new Set<String>();
    global string logentries;
    //US821810-Start method will return null query if existing batch is in processing status.
    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<AsyncApexJob> inprogressJobList = [
            SELECT Id, Status, ApexClass.Name
            FROM AsyncApexjob
            WHERE
                Status = 'Processing'
                AND ApexClass.Name = 'PRM_RegistrationApprovalEmail'
        ]; //US821810-This will query current running job which is not completed.
        if (inprogressJobList.size() > 0) {
            //block started
            String nullQuery = 'Select Id,PRM_Business_Event__c,PRM_Contact__c,PRM_Tier__c,PRM_Contact__r.AccountId,PRM_Contact__r.Core_Preferred_Language__c,PRM_Contact__r.Email,PRM_Contact__r.Core_Do_Not_Contact__c,PRM_Status__c,PRM_PartnerRole__c,PRM_Registration_Request__c,CreatedDate from PRM_EmailQueue__c where IsDeleted=true AND IsDeleted=false';
            return Database.getQueryLocator(nullQuery); //US821810:returning querylocator with no records.
        } else {
            //US821810-block ends here..
            //block started
            String q = 'Select Id,PRM_Business_Event__c,PRM_Contact__c,PRM_Tier__c,PRM_Contact__r.AccountId,PRM_Contact__r.Account.Core_IPA_Badge_Tier__c,PRM_Contact__r.Core_Preferred_Language__c,PRM_Contact__r.Email,PRM_Contact__r.Core_Do_Not_Contact__c,PRM_Status__c,PRM_PartnerRole__c,PRM_Registration_Request__c,CreatedDate from PRM_EmailQueue__c where PRM_Status__c = \'PENDING\' and createddate=today AND PRM_Business_Event__c != \'\' ORDER BY PRM_Priority__c NULLS LAST,CreatedDate';
            return Database.getQueryLocator(q);
        } //US821810-block ends here..
    }

    global void execute(
        Database.BatchableContext bc,
        List<PRM_EmailQueue__c> emailQueueList
    ) {
        for (PRM_EmailQueue__c eq : emailQueueList) {
            regIds.add(eq.PRM_Registration_Request__c);
        }
        try {
            sendWelcomeEmail(emailQueueList);
        } catch (Exception e) {
            logentries = PRM_ErrorUtilityClass.logError(e);
        }
    }

    public static void sendWelcomeEmail(
        List<PRM_EmailQueue__c> emailQueueList
    ) {
        System.debug('<--Execute-->');
        Map<String, PRM_EmailQueue__c> partnerRoleEmailQueueMap = new Map<String, PRM_EmailQueue__c>();
        Map<String, PRM_EmailQueue__c> contactEmailQueue = new Map<String, PRM_EmailQueue__c>();
        Map<String, PRM_EmailConfiguration__mdt> mapEmailConfiguration = new Map<String, PRM_EmailConfiguration__mdt>();
        Map<String, PRM_EmailConfiguration__mdt> mapEmailConfigurationOnTier = new Map<String, PRM_EmailConfiguration__mdt>();
        Map<String, PRM_EmailQueue__c> mapOfProcessContactId = new Map<String, PRM_EmailQueue__c>();
        Set<String> partnerRoleonTier = new Set<String>();
        Map<String, PRM_EmailLog__c> mapOfEmailLog = new Map<String, PRM_EmailLog__c>();
        Set<String> regIdSet = new Set<String>(); //TWC729-4865 : to store Registration Request Id

        try {
            List<PRM_EmailConfiguration__mdt> emailConfigList = [
                SELECT
                    Id,
                    PRM_BusinessEvent__c,
                    PRM_PartnerRole__c,
                    PRM_Entitlement_List__c,
                    PRM_Priority__c,
                    PRM_Tier__c
                FROM PRM_EmailConfiguration__mdt
                ORDER BY PRM_Priority__c
            ];
            PRM_EmailConfiguration__mdt eConfig;
            for (PRM_EmailConfiguration__mdt emailCon : emailConfigList) {
                //map of business event+partner role , emailCon
                if (
                    mapEmailConfiguration.containsKey(
                        (emailCon.PRM_BusinessEvent__c +
                            emailCon.PRM_PartnerRole__c)
                            .toLowercase()
                    )
                ) {
                    eConfig = mapEmailConfiguration.get(
                        (emailCon.PRM_BusinessEvent__c +
                            emailCon.PRM_PartnerRole__c)
                            .toLowercase()
                    );
                    mapEmailConfiguration.remove(
                        emailCon.PRM_BusinessEvent__c +
                        emailCon.PRM_PartnerRole__c
                    );
                    mapEmailConfigurationOnTier.put(
                        (eConfig.PRM_BusinessEvent__c +
                            eConfig.PRM_PartnerRole__c +
                            eConfig.PRM_Tier__c)
                            .toLowercase(),
                        eConfig
                    );
                    mapEmailConfigurationOnTier.put(
                        (emailCon.PRM_BusinessEvent__c +
                            emailCon.PRM_PartnerRole__c +
                            emailCon.PRM_Tier__c)
                            .toLowercase(),
                        emailCon
                    );
                    String KeyOfMapForDebugPurpose =
                        emailCon.PRM_BusinessEvent__c +
                        emailCon.PRM_PartnerRole__c +
                        emailCon.PRM_Tier__c;
                    System.debug(
                        'mapEmailConfigurationOnTier Key: ' +
                        KeyOfMapForDebugPurpose
                    );
                    partnerRoleonTier.add(
                        emailCon.PRM_PartnerRole__c.toLowercase()
                    );
                } else if (
                    partnerRoleonTier.contains(
                        emailCon.PRM_PartnerRole__c.toLowercase()
                    )
                ) {
                    mapEmailConfigurationOnTier.put(
                        (emailCon.PRM_BusinessEvent__c +
                            emailCon.PRM_PartnerRole__c +
                            emailCon.PRM_Tier__c)
                            .toLowercase(),
                        emailCon
                    );
                    String KeyOfMapForDebugPurpose =
                        emailCon.PRM_BusinessEvent__c +
                        emailCon.PRM_PartnerRole__c +
                        emailCon.PRM_Tier__c;
                    System.debug(
                        'mapEmailConfigurationOnTier Key: ' +
                        KeyOfMapForDebugPurpose
                    );
                    System.debug(
                        'mapEmailConfigurationOnTier Value: ' + emailCon
                    );
                } else {
                    mapEmailConfiguration.put(
                        (emailCon.PRM_BusinessEvent__c +
                            emailCon.PRM_PartnerRole__c)
                            .toLowercase(),
                        emailCon
                    );
                }
            }

            //contact Id - entitlement List Map from Email Queue
            //starts
            /*for(String str : mapEmailConfiguration.keyset()){
                system.debug('>>>'+mapEmailConfiguration.get(str)); 
            }
            for(String str : mapEmailConfigurationOnTier.keyset()){
                system.debug('>>>'+mapEmailConfigurationOnTier.get(str)); 
            }*/

            Map<id, Contact> mapContact = new Map<id, Contact>();
            List<Id> conIds = new List<Id>();
            for (PRM_EmailQueue__c eq : emailQueueList) {
                conIds.add(eq.PRM_Contact__c);
            }
            if (!emailQueueList.isEmpty()) {
                for (Contact con : [
                    SELECT
                        Name,
                        Email,AccountId,
                        id,
                        Core_Preferred_Language__c,
                        Core_Do_Not_Contact__c
                    FROM Contact
                    WHERE id IN :conIds
                ]) {
                    mapContact.put(con.id, con);
                }
            }

            Map<String, String> mapOfContactEntitlement = new Map<String, String>();
            Map<String, String> mapOfContactandBusinessEvent = new Map<String, String>();
            for (PRM_EmailQueue__c ec : emailQueueList) {
                System.debug(
                    'Key putting: ' +
                    (ec.PRM_Business_Event__c +
                        ec.PRM_PartnerRole__c +
                        ec.PRM_Tier__c)
                        .toLowercase()
                );
                System.debug(
                    'mapEmailConfigurationOnTier  Get: ' +
                    mapEmailConfigurationOnTier.get(
                        ec.PRM_Business_Event__c +
                        ec.PRM_PartnerRole__c +
                        ec.PRM_Tier__c
                    )
                );
                processedIds.add(ec.Id);
                partnerRoleEmailQueueMap.put(ec.PRM_Contact__c, ec);
                if (
                    mapEmailConfiguration.containsKey(
                        (ec.PRM_Business_Event__c + ec.PRM_PartnerRole__c)
                            .toLowercase()
                    )
                ) {
                    String entitlements = '';
                    entitlements = mapEmailConfiguration.get(
                            (ec.PRM_Business_Event__c + ec.PRM_PartnerRole__c)
                                .toLowercase()
                        )
                        .PRM_Entitlement_List__c;
                    mapOfContactEntitlement.put(
                        ec.PRM_Contact__c,
                        entitlements
                    );
                    mapOfContactandBusinessEvent.put(
                        ec.PRM_Contact__c,
                        ec.PRM_Business_Event__c
                    );
                } else if (
                    mapEmailConfigurationOnTier.containsKey(
                        (ec.PRM_Business_Event__c +
                            ec.PRM_PartnerRole__c +
                            ec.PRM_Tier__c)
                            .toLowercase()
                    )
                ) {
                    String entitlements = '';
                    entitlements = mapEmailConfigurationOnTier.get(
                            (ec.PRM_Business_Event__c +
                                ec.PRM_PartnerRole__c +
                                ec.PRM_Tier__c)
                                .toLowercase()
                        )
                        .PRM_Entitlement_List__c;
                    mapOfContactEntitlement.put(
                        ec.PRM_Contact__c,
                        entitlements
                    );
                    mapOfContactandBusinessEvent.put(
                        ec.PRM_Contact__c,
                        ec.PRM_Business_Event__c
                    );
                }
            }

            Map<String, Set<String>> mapOfQueueContactEntitlement = new Map<String, Set<String>>();
            for (String contactId : mapOfContactEntitlement.keySet()) {
                String en = mapOfContactEntitlement.get(contactId);
                Set<String> finalSetOfQueueEntitlements = new Set<String>(
                    en.split(',')
                );
                /*System.debug(
                    'finalSetOfQueueEntitlements' + finalSetOfQueueEntitlements
                );
                System.debug('contactId' + contactId);*/
                mapOfQueueContactEntitlement.put(
                    contactId,
                    finalSetOfQueueEntitlements
                );
            }
            //ends

            /* for (String f : mapOfQueueContactEntitlement.keySet()) {
                System.debug(
                    'f' +
                    f +
                    'value' +
                    mapOfQueueContactEntitlement.get(f)
                );
            }*/

            //contact Id - entitlement List Map from Core Contact Entitlement
            //query contact entitlements which are complete and assigned(selected = true)
            Map<String, Set<String>> mapCoreContactEntitlement = new Map<String, Set<String>>();
            Map<String, Set<String>> mapfinalCoreContactEntitlement = new Map<String, Set<String>>();
            for (Core_Contact_Entitlement__c ce : [
                SELECT Id, Core_Contact_Id__c, Core_Entitlement_Id__r.Name
                FROM Core_Contact_Entitlement__c
                WHERE
                    Core_Contact_Id__c IN :mapOfQueueContactEntitlement.keySet()
                    AND Core_Status__c = 'Complete'
                    AND Core_Type__c = 'Entitlement'
                    AND Core_Selected__c = TRUE
            ]) {
                //System.debug('----------------');
                /*System.debug(
                    'ce.Core_Entitlement_Id__r.Name' +
                    ce.Core_Entitlement_Id__r.Name
                );*/
                Set<String> finalCoreContactEntitlement = new Set<String>();
                if (
                    mapOfQueueContactEntitlement.get(ce.Core_Contact_Id__c)
                        .contains(ce.Core_Entitlement_Id__r.Name)
                ) {
                    if (
                        mapCoreContactEntitlement.keySet()
                            .contains(ce.Core_Contact_Id__c)
                    ) {
                        mapCoreContactEntitlement.get(ce.Core_Contact_Id__c)
                            .add(ce.Core_Entitlement_Id__r.Name);
                    } else {
                        Set<String> coreContactEntitlement = new Set<String>();
                        coreContactEntitlement.add(
                            ce.Core_Entitlement_Id__r.Name
                        );
                        mapCoreContactEntitlement.put(
                            ce.Core_Contact_Id__c,
                            coreContactEntitlement
                        );
                    }
                }
                /*Utkarsh - US741977 - Changes done to accomodate Team RUBY Flow*/
                if (
                    mapfinalCoreContactEntitlement.get(ce.Core_Contact_Id__c) !=
                    null &&
                    !mapfinalCoreContactEntitlement.get(ce.Core_Contact_Id__c)
                        .IsEmpty()
                ) {
                    finalCoreContactEntitlement = mapfinalCoreContactEntitlement.get(
                        ce.Core_Contact_Id__c
                    );
                    /*system.debug(
                        'finalCoreContactEntitlement inside if=====>' +
                        finalCoreContactEntitlement
                    );*/
                }
                finalCoreContactEntitlement.add(ce.Core_Entitlement_Id__r.Name);
                mapfinalCoreContactEntitlement.put(
                    ce.Core_Contact_Id__c,
                    finalCoreContactEntitlement
                );
                /*system.debug(
                    'mapfinalCoreContactEntitlement=====>' +
                    mapfinalCoreContactEntitlement
                );*/
                /*END - US741977*/
            }

            //verify if all the entitlements present in the IPA Email configuration are complete
            Set<String> contactIdsToProcess = new Set<String>();
            for (
                String finalContactId : mapOfQueueContactEntitlement.keySet()
            ) {
                if (mapCoreContactEntitlement.containsKey(finalContactId)) {
                    //System.debug('finalContactId' + finalContactId);
                    /*Utkarsh - US760255 - Changes done to accomodate Team RUBY Flow*/
                    if (
                        mapOfContactandBusinessEvent.get(finalContactId) ==
                        System.Label.PRM_OPIDGold_BusinessEvent ||
                        mapOfContactandBusinessEvent.get(finalContactId) ==
                        System.Label.PRM_OPIDTitanium_BusinessEvent
                    ) {
                        if (
                            mapOfQueueContactEntitlement.get(finalContactId)
                                .containsAll(
                                    mapCoreContactEntitlement.get(
                                        finalContactId
                                    )
                                )
                        ) {
                            contactIdsToProcess.add(finalContactId);
                            //System.debug('All entitlements are Complete');
                        }
                    } else {
                        /*END - US760255*/
                        if (
                            mapCoreContactEntitlement.get(finalContactId)
                                .equals(
                                    mapOfQueueContactEntitlement.get(
                                        finalContactId
                                    )
                                )
                        ) {
                            //System.debug('All entitlements are Complete');
                            contactIdsToProcess.add(finalContactId);
                        }
                    }
                }
            }
            System.debug(
                Logginglevel.Info,
                'contactIdsToProcess' + contactIdsToProcess
            );

            //iterate over contact Ids on which all entitlements are complete and trigger email for those contacts
            //
            Map<String, PRM_Language_Culture_Mapping__mdt> mapLangAndCountryToCulture = new Map<String, PRM_Language_Culture_Mapping__mdt>();
            for (PRM_Language_Culture_Mapping__mdt lngCultureMdt : [
                SELECT
                    Id,
                    MasterLabel,
                    PRM_Culture__c,
                    PRM_Country__c,
                    PRM_Country_Cd__c
                FROM PRM_Language_Culture_Mapping__mdt
                WHERE PRM_Country_Cd__c != NULL
            ]) {
                mapLangAndCountryToCulture.put(
                    lngCultureMdt.PRM_Country_Cd__c + lngCultureMdt.MasterLabel,
                    lngCultureMdt
                );
                if (lngCultureMdt.PRM_Country_Cd__c.equalsIgnoreCase('us')) {
                    mapLangAndCountryToCulture.put('USDefault', lngCultureMdt);
                }
            }

            Map<String, Contact> mapofqueue = new Map<String, Contact>();
            if (!contactIdsToProcess.isEmpty()) {
                List<PRM_Bulk_Data_Upload__c> bulkUploadrecord = [
                    SELECT
                        Id,
                        PRM_Contact_Id__c,
                        PRM_Suppress_Email__c,
                        PRM_Contact_Email__c
                    FROM PRM_Bulk_Data_Upload__c
                    WHERE PRM_Contact_Id__c IN :contactIdsToProcess
                    ORDER BY CreatedDate
                ];
                List<PRM_EmailUtility.EmailNotification> notiflist  = new List<PRM_EmailUtility.EmailNotification>();
                for (Contact con : [
                    SELECT 
                        Id,
                        MailingCountryCode,
                        Core_Preferred_Language__c
                    FROM Contact
                    WHERE Id IN :contactIdsToProcess
                ]) {
                    PRM_Language_Culture_Mapping__mdt langCultureForEmail;
                    if (
                        con.MailingCountryCode != null &&
                        String.isNotBlank(con.Core_Preferred_Language__c) &&
                        mapLangAndCountryToCulture.containsKey(
                            con.MailingCountryCode +
                            con.Core_Preferred_Language__c
                        )
                    ) {
                        langCultureForEmail = mapLangAndCountryToCulture.get(
                            con.MailingCountryCode +
                            con.Core_Preferred_Language__c
                        );
                    } else {
                        langCultureForEmail = mapLangAndCountryToCulture.get(
                            'USDefault'
                        );
                    }

                    Boolean suppressIPAEmail = false;
                    if (
                        bulkUploadrecord != null && !bulkUploadrecord.isEmpty()
                    ) {
                        suppressIPAEmail = bulkUploadrecord[0]
                            .PRM_Suppress_Email__c;
                    }
                    //
                    //System.debug('After lang culture soql');
                    if (partnerRoleEmailQueueMap.keySet().contains(con.Id)) {
                        PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();
                        //PRM_Email_Content_DataSetup__c emailSetup = PRM_Email_Content_DataSetup__c.getValues(partnerRoleEmailQueueMap.get(con.Id).PRM_PartnerRole__c);
                        map<String, String> inputParameters = new Map<String, String>();
                        objEmailNotif.InputParameters = inputParameters;

                        objEmailNotif.BusinessEvent = partnerRoleEmailQueueMap.get(
                                con.Id
                            )
                            .PRM_Business_Event__c;
                        objEmailNotif.Language = mapContact.get(con.Id)
                            .Core_Preferred_Language__c;
                        objEmailNotif.ChannelProgram = System.Label.PRM_Intel_Partner_Alliance;
                        objEmailNotif.EmailID = mapContact.get(con.Id).Email;

                        //set registration request Id only for self registration process
                        if (
                            objEmailNotif.BusinessEvent ==
                            System.Label.PRM_Welcome_Email_New_Event ||
                            objEmailNotif.BusinessEvent ==
                            System.Label.PRM_Welcome_Email_Existing_Event ||
                            objEmailNotif.BusinessEvent ==
                            System.label.PRM_Email_Admin_Approval_Event
                        ) {
                            inputParameters.put(
                                'Registration_Request_ID',
                                partnerRoleEmailQueueMap.get(con.Id)
                                    .PRM_Registration_Request__c
                            );
                        }
                        //
                        if (langCultureForEmail != null) {
                            inputParameters.put(
                                'LanguageCulture_MDT',
                                langCultureForEmail.Id
                            );

                        }
                        //set partner type only for admin registration
                        if (
                            objEmailNotif.BusinessEvent ==
                            System.Label.PRM_Email_Admin_Approval_Event
                        ) {
                            objEmailNotif.PartnerType = System.Label.PRM_CsP;
                        }
                        /*Utkarsh - US741977 - Changes done to accomodate Team RUBY Flow*/
                        if (
                            (!mapfinalCoreContactEntitlement.get(con.Id)
                                .contains(System.Label.PRM_Partner_Admin)) &&
                            (!mapfinalCoreContactEntitlement.get(con.Id)
                                .contains(System.Label.PRM_Admin_Delegate))
                        ) {
                            objEmailNotif.partnerAdmin = false;
                        }
                        /*END - US741977*/
                        /*Utkarsh - US709296 - Changes done to accomodate Team RUBY Flow*/
                        if (
                            partnerRoleEmailQueueMap.get(con.Id)
                                .PRM_Business_Event__c ==
                            System.Label.PRM_OPIDGold_BusinessEvent ||
                            partnerRoleEmailQueueMap.get(con.Id)
                                .PRM_Business_Event__c ==
                            System.Label.PRM_OPIDTitanium_BusinessEvent
                        ) {
                            inputParameters.put('Contact_ID', con.Id);
                        } else {
                            /*US709296 - END*/
                            inputParameters.put(
                                'Account_ID',
                                mapContact.get(con.Id).AccountId
                            );
                        }

                        if (
                            mapContact.get(con.Id).Core_Do_Not_Contact__c ==
                            false &&
                            suppressIPAEmail == false
                        ) {
                            //PRM_EmailUtility.sendEmail(objEmailNotif);
                            //added as part of governor limit story:4380
                            //TWC729-4865 : storing registration Request Id
                            notiflist.add(objEmailNotif);
                            mapOfProcessContactId.put(
                                mapContact.get(con.Id).Email,
                                partnerRoleEmailQueueMap.get(con.Id)
                            );
                        }
                    }
                }
                if(!notiflist.isEmpty()){
                    regIdSet = PRM_EmailUtility.sendEmail(notiflist);
                }

                /*if (!regIdSet.IsEmpty() && Trigger.isExecuting) {
                    System.enqueueJob(
                        new PRM_RegistrationTrackerUtility.UpdateTrackerSteps(
                            regIdSet,
                            null,
                            null,
                            'PRM_RegistrationApprovalEmail',
                            null
                        )
                    );
                }*/
            }

            //update email logs on contact for which email is triggered
            List<PRM_EmailLog__c> emailLogsToUpdate = new List<PRM_EmailLog__c>();
            Map<String, PRM_EmailLog__c> mapOfContactEmailLog = new Map<String, PRM_EmailLog__c>();
            Set<String> setOfEmail = new Set<String>();
            Set<String> subjectSet = new Set<String>{
                '[Chinese]Intel® Partner Alliance Gold',
                'Intel® Partner Alliance Gold'
            };
            System.debug('>>>mapOfProcessContactId'+mapOfProcessContactId);
            for (PRM_EmailLog__c eLog : [
                SELECT
                    Id,
                    PRM_Subject__c,
                    PRM_Contact__c,
                    PRM_EmailContent__c,
                    PRM_EmailHTMLContent__c,
                    PRM_User__c,
                    PRM_EmailDeliverabilityStatus__c,
                    PRM_ToEmailID__c,
                    Email_Template_Name__c,
                    PRM_Contact__r.Core_Preferred_Language__c
                FROM PRM_EmailLog__c
                WHERE PRM_ToEmailID__c IN :mapOfProcessContactId.keySet()
                order by createddate
            ]) {
                System.debug('@@ eLog' + eLog);
                mapOfContactEmailLog.put(eLog.PRM_ToEmailID__c, eLog);
            }

            Map<String, User> mapEmailToUser = new Map<String, User>();

            if (!mapOfContactEmailLog.isEmpty()) {
                for(USer usr : [
                    SELECT id, Email, contactId
                    FROM User
                    WHERE contact.Email in : mapOfContactEmailLog.keySet()
                ]){
                    mapEmailToUser.put(usr.Email, usr);
                }
            }
            System.debug('>>>>mapEmailToUser'+mapEmailToUser);
            for (String email : mapOfContactEmailLog.keyset()) {

                    if (mapEmailToUser.containsKey(email)) {
                        System.debug('>>>>inside for '+email);
                        mapOfContactEmailLog.get(email).PRM_Contact__c = mapEmailToUser.get(email).ContactId;
                        mapOfContactEmailLog.get(email).PRM_User__c =  mapEmailToUser.get(email).id;

                        if (
                            String.isNotBlank(
                                mapOfContactEmailLog.get(email)
                                    .Email_Template_Name__c
                            ) &&
                            (mapOfContactEmailLog.get(email)
                                .Email_Template_Name__c.contains(
                                    System.Label.PRM_Registration_Template
                                ) ||
                            mapOfContactEmailLog.get(email)
                                .Email_Template_Name__c.contains(
                                    System.Label.PRM_Reuse_Registration_Template
                                ) ||
                            mapOfContactEmailLog.get(email)
                                .Email_Template_Name__c.contains(
                                    System.Label.PRM_OPID_GoldUpgrade_Template
                                ) ||
                            mapOfContactEmailLog.get(email)
                                .Email_Template_Name__c.contains(
                                    System.Label.PRM_OPID_TitaniumUpgrade_Template
                                ))
                        ) {
                            System.debug(
                                '@@ Template Name' +
                                mapOfContactEmailLog.get(email)
                                    .Email_Template_Name__c
                            );
                            mapOfEmailLog.put(
                                mapOfContactEmailLog.get(email).PRM_ToEmailID__c,
                                mapOfContactEmailLog.get(email)
                            );
                        }
                        System.debug('>>>>mapOfContactEmailLog.get(email) adding to queue'+mapOfContactEmailLog.get(email));
                        emailLogsToUpdate.add(mapOfContactEmailLog.get(email));
                    }
            }

            if (emailLogsToUpdate.size() > 0) {
                System.debug('<--Update Email Log 2-->'+emailLogsToUpdate);
                
                Database.saveResult[] svreslt = Database.update(emailLogsToUpdate, false);
                for (Database.saveResult sr : svreslt ) {
                    if(!sr.isSuccess()){
                        System.debug('>>>>>'+sr.getErrors()[0].getMessage());
                        //Core_Log_Entry.logEntryWithDetails('PRM_BenefitUtility', 'IPA', 'Tracker record', 'exception', 'Exception occured while inserting PRM_Tracker__c', sr.getErrors()[0].getMessage(), sr.getId(), 'PRM_Tracker__c', 'PRM_Tracker__c');
                    }
                }
            }

            List<PRM_EmailQueue__c> ipaEmailQueueToUpdate = new List<PRM_EmailQueue__c>();
            for (String email : mapOfProcessContactId.keySet()) {
                if (mapOfEmailLog.containsKey(email)) {
                    System.debug('<--Update IPA Email Queue 1-->');

                    //update email content & status to complete only when email deliverability status is true
                    if (
                        mapOfEmailLog.get(email)
                            .PRM_EmailDeliverabilityStatus__c == true
                    ) {
                        if (
                            mapOfEmailLog.get(email).PRM_EmailHTMLContent__c !=
                            null
                        ) {
                            mapOfProcessContactId.get(email)
                                .PRM_Email_Content__c = mapOfEmailLog.get(email)
                                .PRM_EmailHTMLContent__c;
                        } else if (
                            mapOfEmailLog.get(email).PRM_EmailContent__c != null
                        ) {
                            mapOfProcessContactId.get(email)
                                .PRM_Email_Content__c = mapOfEmailLog.get(email)
                                .PRM_EmailContent__c;
                        }
                        mapOfProcessContactId.get(email)
                            .PRM_Status__c = System.Label.PRM_Complete;
                    } else {
                        //update status to error when email deliverability status is false
                        mapOfProcessContactId.get(email)
                            .PRM_Status__c = System.Label.PRM_Error;
                    }
                    ipaEmailQueueToUpdate.add(mapOfProcessContactId.get(email));
                    System.debug(
                        'ipaEmailQueueToUpdate ' + ipaEmailQueueToUpdate
                    );
                }
            }

            if (ipaEmailQueueToUpdate.size() > 0) {
                System.debug('<--Update IPA Email Queue 2-->');
                
                Database.saveResult[] svreslt = Database.update(ipaEmailQueueToUpdate, false);
                for (Database.saveResult sr : svreslt ) {
                    if(!sr.isSuccess()){
                        System.debug('>>>>>'+sr.getErrors()[0].getMessage());
                        //Core_Log_Entry.logEntryWithDetails('PRM_BenefitUtility', 'IPA', 'Tracker record', 'exception', 'Exception occured while inserting PRM_Tracker__c', sr.getErrors()[0].getMessage(), sr.getId(), 'PRM_Tracker__c', 'PRM_Tracker__c');
                    }
                }
            }
        } catch (Exception e) {
            string LogEntry = PRM_ErrorUtilityClass.logError(e);
        }
    }
    global void finish(Database.BatchableContext bc) {
        System.debug('<----POST PROCESSING STEPS---->');
        AsyncApexJob job = [
            SELECT
                Id,
                Status,
                NumberOfErrors,
                JobItemsProcessed,
                TotalJobItems,
                CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()
        ];
        system.debug('---regIds ' + regIds.size());
        /*if (regIds.size() > 0 && System.Label.PRM_Tracker_Enabled == 'true')
            System.enqueueJob(
                new PRM_RegistrationTrackerUtility.UpdateTrackerSteps(
                    regIds,
                    null,
                    logentries,
                    'PRM_RegistrationApprovalEmail',
                    null
                )
            );*/

        System.debug('Result' + job);
        System.debug('processedIds - SIZE' + processedIds.size());
        System.debug('processedIds' + processedIds);

        //to check if email log has been updated for contact present in the email queue
    }
}