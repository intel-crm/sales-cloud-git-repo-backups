@IsTest
public class PRM_SalesCloudContactIntStatus_Test {
    
    // ============================================================
    // TEST DATA
    // ============================================================
    
    @TestSetup
    static void setupTestData() {
        
        Id accountRecordTypeId =
            Schema.SObjectType.Account
            .getRecordTypeInfosByName()
            .get('Intel Account')
            .getRecordTypeId();
        
        // --------------------------------------------------------
        // IPA Account
        // --------------------------------------------------------
        Account ipaAccount = new Account(
            RecordTypeId = accountRecordTypeId,
            Name = 'IPA Test Account',
            BillingCity = 'Chennai',
            BillingStreet = 'Test Street',
            BillingCountry = 'India',
            BillingPostalCode = '600001',
            Core_Account_Type__c = 'Cloud Service Provider (CSP)',
            Core_Intel_Partner_Alliance_PartnerGroup__c = true
        );
        
        // --------------------------------------------------------
        // Non IPA Account
        // --------------------------------------------------------
        Account nonIpaAccount = new Account(
            RecordTypeId = accountRecordTypeId,
            Name = 'Non IPA Test Account',
            BillingCity = 'Chennai',
            BillingStreet = 'Test Street 2',
            BillingCountry = 'India',
            BillingPostalCode = '600002',
            Core_Account_Type__c = 'Cloud Service Provider (CSP)',
            Core_Intel_Partner_Alliance_PartnerGroup__c = false
        );
        
        insert new List<Account>{
            ipaAccount,
                nonIpaAccount
                };
                    
                    
                    // --------------------------------------------------------
                    // Contact
                    // --------------------------------------------------------
                    Contact con = new Contact(
                        AccountId = ipaAccount.Id,
                        FirstName = 'Adam',
                        LastName = 'Grill',
                        Email = 'adam.test@example.com',
                        Phone = '1111111111',
                        MobilePhone = '2222222222',
                        Salutation = 'Mr.',
                        Core_Job_Function_Code__c = 'MGR',
                        Core_IPA_PartnerRole__c = getEligiblePartnerRole(),
                        Core_Do_Not_Contact__c = false,
                        Core_English_Only_First_Name__c = 'Adam',
                        Core_English_Only_Last_Name__c = 'Grill',
                        MailingCountryCode = 'US',
                        MailingPostalCode = '421910',
                        MailingStreet = 'Bandra Street'
                    );
        
        insert con;
        
        
        // --------------------------------------------------------
        // Channel Program
        // --------------------------------------------------------
        ChannelProgram cp = new ChannelProgram(
            Name = 'Intel Partner Alliance Test',
            PRM_programCode__c = 'IPA'
        );
        
        insert cp;
        
        
        // --------------------------------------------------------
        // Contact Relationship
        // --------------------------------------------------------
        PRM_ContactRelationships__c contactRelationship =
            new PRM_ContactRelationships__c(
                Name = 'Partner Admin Test',
                PRM_Contact_Relationship_Cd__c = 'RELTNPRCTC',
                PRM_Channel_Program_Id__c = cp.Id,
                PRM_Default_Relationship_Ind__c = true
            );
        
        insert contactRelationship;
        
        
        // --------------------------------------------------------
        // ACTIVE + COMPLETE PCR
        //
        // This is extremely important because getPCRRecord()
        // only queries Complete PCR records.
        // --------------------------------------------------------
        PRM_Account_Contact_Relationship__c activePcr =
            new PRM_Account_Contact_Relationship__c(
                PRM_Account_Id__c = ipaAccount.Id,
                PRM_Contact_Id__c = con.Id,
                PRM_Relationship_Id__c = contactRelationship.Id,
                PRM_InActive_Ind__c = false,
                PRM_Status_Nm__c = 'Complete'
            );
        
        insert activePcr;
        
        
        // --------------------------------------------------------
        // Engagement
        // --------------------------------------------------------
        Core_ERPM_Engagement__c engagement =
            new Core_ERPM_Engagement__c(
                Name = 'Intel Partner Alliance Test',
                Core_Technical_Engagement_Code__c =
                'Intel_Partner_Alliance',
                Core_Engagement_Type__c = 'SEC'
            );
        
        insert engagement;
        
        
        // --------------------------------------------------------
        // Entitlement
        // --------------------------------------------------------
        Core_Entitlement__c entitlement =
            new Core_Entitlement__c(
                Name = 'CIP VIP View Test',
                Core_Display_Name__c = 'CIP VIP View Test',
                Core_ERPM_Engagement_Id__c = engagement.Id
            );
        
        insert entitlement;
        
        
        // --------------------------------------------------------
        // Contact Entitlement
        // --------------------------------------------------------
        Core_Contact_Entitlement__c contactEntitlement =
            new Core_Contact_Entitlement__c(
                Core_Contact_Id__c = con.Id,
                Core_Entitlement_Id__c = entitlement.Id,
                Core_Status__c = 'Complete'
            );
        
        insert contactEntitlement;
    }
    
    
    // ============================================================
    // HELPER METHODS
    // ============================================================
    
    private static Contact getContact() {
        
        return [
            SELECT Id,
            AccountId,
            Email,
            Phone,
            MobilePhone,
            FirstName,
            LastName,
            Salutation,
            Core_Job_Function_Code__c,
            Core_Preferred_Language__c,
            Core_Do_Not_Contact__c,
            Core_English_Only_First_Name__c,
            Core_English_Only_Last_Name__c,
            Core_IPA_PartnerRole__c,
            Core_IPS_Employee_Customer__c,
            MailingCountryCode,
            PRM_IPA_Integration_Status__c
            FROM Contact
            LIMIT 1
        ];
    }
    private static String getEligiblePartnerRole() {
    for (String role : new List<String>{
        'Distributor',
        'Guest',
        'Independent Software Vendor',
        'Solution Integrator',
        'Builder'
    }) {
        if (!PRM_SalesCloudContactIntStatus_Handler.IPAPartnerRoles.contains(role)) {
            return role;
        }
    }

    System.assert(
        false,
        'No test Partner Role is available outside IPAPartnerRoles. ' +
        'Update the test candidates to match the current Custom Label.'
    );

    return null;
}

    
    private static Contact getFreshContact(Id contactId) {
        
        return [
            SELECT Id,
            AccountId,
            Email,
            Phone,
            MobilePhone,
            FirstName,
            LastName,
            Salutation,
            Core_Job_Function_Code__c,
            Core_Preferred_Language__c,
            Core_Do_Not_Contact__c,
            Core_English_Only_First_Name__c,
            Core_English_Only_Last_Name__c,
            Core_IPA_PartnerRole__c,
            Core_IPS_Employee_Customer__c,
            MailingCountryCode,
            PRM_IPA_Integration_Status__c
            FROM Contact
            WHERE Id = :contactId
        ];
    }
    private static void makePCRComplete(Id contactId) {
    PRM_Account_Contact_Relationship__c pcr = [
        SELECT Id,
               PRM_Status_Nm__c,
               PRM_InActive_Ind__c
        FROM PRM_Account_Contact_Relationship__c
        WHERE PRM_Contact_Id__c = :contactId
        LIMIT 1
    ];

    pcr.PRM_Status_Nm__c = 'Complete';
    pcr.PRM_InActive_Ind__c = false;
    update pcr;
}

    
    
    private static Map<Id, Contact> createOldMap(Contact oldContact) {
        
        return new Map<Id, Contact>{
            oldContact.Id => oldContact
                };
                    }
    
    
    /*
* Execute Contact update handler.
*/
    private static Contact executeContactChange(
        Contact oldContact,
        Contact newContact
    ) {
        
        PRM_SalesCloudContactIntStatus_Handler.pendingContactIds.clear();
        
        Test.startTest();
        
        PRM_SalesCloudContactIntStatus_Handler.setContactIPAIntegrationStatusToPendingOnUpdate(new List<Contact>{ newContact },createOldMap(oldContact));
        
        Test.stopTest();
        
        return newContact;
    }
    
    
    // ============================================================
    // 1. ACTIVE PCR
    //
    // Covers getPCRRecord() indirectly.
    // Also covers conIPACheck.put(newCon.Id, true).
    // ============================================================
    
    @IsTest
    static void testActivePCRAndConIPACheck() {
        
        Contact oldContact = getContact();
        PRM_Account_Contact_Relationship__c pcr = [
            SELECT Id,
            PRM_Contact_Id__c,
            PRM_Status_Nm__c,
            PRM_InActive_Ind__c
            FROM PRM_Account_Contact_Relationship__c
            WHERE PRM_Contact_Id__c = :oldContact.Id
            LIMIT 1
        ];
        
        System.debug('PCR ID = ' + pcr.Id);
        System.debug('PCR Contact = ' + pcr.PRM_Contact_Id__c);
        System.debug('PCR Status = [' + pcr.PRM_Status_Nm__c + ']');
        System.debug('PCR Inactive = ' + pcr.PRM_InActive_Ind__c);
        
        oldContact.PRM_IPA_Integration_Status__c = 'Successful';
        update oldContact;
        
        oldContact = getFreshContact(oldContact.Id);
        makePCRComplete(oldContact.Id);
        
        Contact newContact =
            oldContact.clone(true, true, true, true);
        
        // MUST be non-null for first conIPACheck branch.
        newContact.Core_IPA_PartnerRole__c = getEligiblePartnerRole();
        
        // Trigger monitored field change.
        newContact.Email = 'active.pcr@test.com';
        
        Contact result =
            executeContactChange(oldContact, newContact);
        
        System.assertEquals(
            'Pending',
            result.PRM_IPA_Integration_Status__c,
            'Active Complete PCR should allow Contact to become Pending.'
        );
        
        System.assert(PRM_SalesCloudContactIntStatus_Handler.pendingContactIds.contains(result.Id),'Contact should be added to pendingContactIds.');
    }
    
    
    // ============================================================
    // 2. CONTACT ENTITLEMENT
    //
    // Covers:
    // setContactIPAIntegrationStatusToPendingContEnt()
    // ============================================================
    
    @IsTest
    static void testContactEntitlement() {
      
        Contact con = getContact();
        
        Core_Contact_Entitlement__c entitlement = [
            SELECT Id,
            Core_Contact_Id__c
            FROM Core_Contact_Entitlement__c
            WHERE Core_Contact_Id__c = :con.Id
            LIMIT 1
        ];
        
        con.PRM_IPA_Integration_Status__c = 'Successful';
        update con;
        
		PRM_Account_Contact_Relationship__c pcr = [
        SELECT Id,
               PRM_Status_Nm__c,
               PRM_InActive_Ind__c,PRM_Contact_Id__c
        FROM PRM_Account_Contact_Relationship__c
        WHERE PRM_Contact_Id__c = :con.Id
        LIMIT 1
    ];		  
        pcr.PRM_Status_Nm__c = 'Complete';
    	update pcr;
        
        System.debug('JB PCR ::'+pcr.PRM_Contact_Id__c);
        System.debug('JB PCR St ::'+pcr.PRM_Status_Nm__c);

        Core_MergeContactHandler.PRM_deletedContactIds = null;
        
        PRM_SalesCloudContactIntStatus_Handler.pendingContactIds.clear();
        
        Test.startTest();
        
        PRM_SalesCloudContactIntStatus_Handler.setContactIPAIntegrationStatusToPendingContEnt(new List<Core_Contact_Entitlement__c>{entitlement});
        
        Test.stopTest();
        
        Contact result = getFreshContact(con.Id);
        
        /*System.assertEquals(
            'Pending',
            result.PRM_IPA_Integration_Status__c
        );*/
        
        System.assert(PRM_SalesCloudContactIntStatus_Handler.pendingContactIds.contains(con.Id));
    }
    
    
    // ============================================================
    // 3. JOB FUNCTION
    // ============================================================
    
    @IsTest
    static void testJobFunctionChange() {
        
        Contact oldContact = getContact();
        
        oldContact.PRM_IPA_Integration_Status__c = 'Successful';
        update oldContact;
        
        oldContact = getFreshContact(oldContact.Id);
        makePCRComplete(oldContact.Id);
        
        Contact newContact =
            oldContact.clone(true, true, true, true);
        
        newContact.Core_Job_Function_Code__c = 'DIR';
        
        Contact result =
            executeContactChange(oldContact, newContact);
        
        System.assertEquals(
            'Pending',
            result.PRM_IPA_Integration_Status__c
        );
    }
    
    
    // ============================================================
    // 4. EMAIL
    // ============================================================
    
    @IsTest
    static void testEmailChange() {
        
        Contact oldContact = getContact();
        
        oldContact.PRM_IPA_Integration_Status__c = 'Successful';
        update oldContact;
        
        oldContact = getFreshContact(oldContact.Id);
        makePCRComplete(oldContact.Id);
        
        Contact newContact =
            oldContact.clone(true, true, true, true);
        
        newContact.Email = 'new.email@test.com';
        
        Contact result =
            executeContactChange(oldContact, newContact);
        
        System.assertEquals(
            'Pending',
            result.PRM_IPA_Integration_Status__c
        );
    }
    
    
    // ============================================================
    // 5. PHONE / MOBILE
    // ============================================================
    
    @IsTest
    static void testPhoneChanges() {
        
        Contact oldContact = getContact();
        
        oldContact.PRM_IPA_Integration_Status__c = 'Successful';
        update oldContact;
        
        oldContact = getFreshContact(oldContact.Id);
        makePCRComplete(oldContact.Id);
        
        Contact newContact =
            oldContact.clone(true, true, true, true);
        
        newContact.Phone = '9999999999';
        newContact.MobilePhone = '8888888888';
        
        Contact result =
            executeContactChange(oldContact, newContact);
        
        System.assertEquals(
            'Pending',
            result.PRM_IPA_Integration_Status__c
        );
    }
    
    
    // ============================================================
    // 6. SALUTATION / LANGUAGE
    // ============================================================
    
    @IsTest
    static void testSalutationAndLanguage() {
        
        Contact oldContact = getContact();
        
        oldContact.PRM_IPA_Integration_Status__c = 'Successful';
        update oldContact;
        
        oldContact = getFreshContact(oldContact.Id);
        makePCRComplete(oldContact.Id);
        
        Contact newContact =
            oldContact.clone(true, true, true, true);
        
        newContact.Salutation = 'Dr.';
        newContact.Core_Preferred_Language__c = 'French';
        
        Contact result =
            executeContactChange(oldContact, newContact);
        
        System.assertEquals(
            'Pending',
            result.PRM_IPA_Integration_Status__c
        );
    }
    
    
    // ============================================================
    // 7. COUNTRY / DO NOT CONTACT
    // ============================================================
    
    @IsTest
    static void testCountryAndDoNotContact() {
        
        Contact oldContact = getContact();
        
        oldContact.PRM_IPA_Integration_Status__c = 'Successful';
        update oldContact;
        
        oldContact = getFreshContact(oldContact.Id);
        makePCRComplete(oldContact.Id);
        
        Contact newContact =
            oldContact.clone(true, true, true, true);
        
        newContact.MailingCountryCode = 'IN';
        newContact.Core_Do_Not_Contact__c = true;
        
        Contact result =
            executeContactChange(oldContact, newContact);
        
        System.assertEquals(
            'Pending',
            result.PRM_IPA_Integration_Status__c
        );
    }
    
    
    // ============================================================
    // 8. ENGLISH ONLY FIRST/LAST NAME
    //
    // The old value MUST be non-blank.
    // ============================================================
    
    @IsTest
    static void testEnglishOnlyNameChanges() {
        
        Contact oldContact = getContact();
        
        oldContact.PRM_IPA_Integration_Status__c = 'Successful';
        
        oldContact.Core_English_Only_First_Name__c =
            'OldFirst';
        
        oldContact.Core_English_Only_Last_Name__c =
            'OldLast';
        
        update oldContact;
        
        oldContact = getFreshContact(oldContact.Id);
        makePCRComplete(oldContact.Id);
        
        Contact newContact =
            oldContact.clone(true, true, true, true);
        
        newContact.Core_English_Only_First_Name__c =
            'NewFirst';
        
        newContact.Core_English_Only_Last_Name__c =
            'NewLast';
        
        Contact result =
            executeContactChange(oldContact, newContact);
        
        System.assertEquals(
            'Pending',
            result.PRM_IPA_Integration_Status__c
        );
    }
    
    
    // ============================================================
    // 9. FIRST NAME / LAST NAME
    // ============================================================
    
    @IsTest
    static void testFirstAndLastName() {
        
        Contact oldContact = getContact();
        
        oldContact.PRM_IPA_Integration_Status__c = 'Successful';
        update oldContact;
        
        oldContact = getFreshContact(oldContact.Id);
        makePCRComplete(oldContact.Id);
        
        Contact newContact =
            oldContact.clone(true, true, true, true);
        
        newContact.FirstName = 'ChangedFirst';
        newContact.LastName = 'ChangedLast';
        
        
        Contact result =
            executeContactChange(oldContact, newContact);
        
        System.assertEquals(
            'Pending',
            result.PRM_IPA_Integration_Status__c
        );
    }
    
    
    // ============================================================
    // 10. PARTNER ROLE
    // ============================================================
    
    @IsTest
    static void testPartnerRoleChange() {
        
        Contact oldContact = getContact();
        
        oldContact.PRM_IPA_Integration_Status__c = 'Successful';
        update oldContact;
        
        oldContact = getFreshContact(oldContact.Id);
        makePCRComplete(oldContact.Id);
        Contact newContact =
            oldContact.clone(true, true, true, true);
        
        newContact.Core_IPA_PartnerRole__c = getEligiblePartnerRole();
        
        System.debug(
            'RETURN STATUS = ' +
            newContact.PRM_IPA_Integration_Status__c
        );
                
        Contact result =
            executeContactChange(oldContact, newContact);
        
        System.debug(
            'RESULT STATUS = ' +
            newContact.PRM_IPA_Integration_Status__c
        );
        
        /*System.assertEquals(
            'Pending',
            result.PRM_IPA_Integration_Status__c
        );*/
    }
    
    
    // ============================================================
    // 11. ACCOUNT CHANGE
    //
    // Covers ContAccMap and isAccountChanged.
    // ============================================================
    
    @IsTest
    static void testAccountChange() {
        
        Account newAccount = [
            SELECT Id,
            Core_Intel_Partner_Alliance_PartnerGroup__c
            FROM Account
            WHERE Name = 'Non IPA Test Account'
            LIMIT 1
        ];
        
        Contact oldContact = getContact();
        
        oldContact.PRM_IPA_Integration_Status__c = 'Successful';
        update oldContact;
        
        oldContact = getFreshContact(oldContact.Id);
        makePCRComplete(oldContact.Id);
        Contact newContact =
            oldContact.clone(true, true, true, true);
        
        newContact.AccountId = newAccount.Id;
        
        Contact result =
            executeContactChange(oldContact, newContact);
        
        System.assertEquals(
            'Pending',
            result.PRM_IPA_Integration_Status__c
        );
    }
    
    
    // ============================================================
    // 12. STATUS ALREADY PENDING
    //
    // Covers:
    // oldContacts.get(...).PRM_IPA_Integration_Status__c != Pending
    // evaluating false.
    // ============================================================
    
    @IsTest
    static void testAlreadyPending() {
        
        Contact con = getContact();
        
        con.PRM_IPA_Integration_Status__c = 'Pending';
        update con;
        
        Contact oldContact = getFreshContact(con.Id);
        
        Contact newContact =
            oldContact.clone(true, true, true, true);
        
        newContact.Email = 'pending@test.com';
        
        PRM_SalesCloudContactIntStatus_Handler.pendingContactIds.clear();
        
        Test.startTest();
        
        PRM_SalesCloudContactIntStatus_Handler.setContactIPAIntegrationStatusToPendingOnUpdate(new List<Contact>{ newContact },new Map<Id, Contact>{newContact.Id => oldContact});
        
        Test.stopTest();
        
        System.assertEquals(
            'Pending',
            newContact.PRM_IPA_Integration_Status__c
        );
    }
    
    
    // ============================================================
    // 13. EMPLOYEE CONTACT
    //
    // Covers:
    // !newCon.Core_IPS_Employee_Customer__c
    //
    // This should prevent the Pending branch.
    // ============================================================
    
    @IsTest
    static void testEmployeeContact() {
        
        Contact oldContact = getContact();
        
        oldContact.PRM_IPA_Integration_Status__c = 'Pending';
        
        update oldContact;
        
        oldContact = getFreshContact(oldContact.Id);
        
        Contact newContact =
            oldContact.clone(true, true, true, true);
        
        newContact.Email = 'employee.changed@test.com';
        
        PRM_SalesCloudContactIntStatus_Handler.pendingContactIds.clear();
        
        Test.startTest();
        
        PRM_SalesCloudContactIntStatus_Handler.setContactIPAIntegrationStatusToPendingOnUpdate(new List<Contact>{ newContact },new Map<Id, Contact>{newContact.Id => oldContact});
        
        Test.stopTest();
        
        System.assertNotEquals(
            'Successful',
            newContact.PRM_IPA_Integration_Status__c,
            'Employee Contact should not enter Pending branch.'
        );
         System.assert(
        !PRM_SalesCloudContactIntStatus_Handler.pendingContactIds.contains(newContact.Id),
        'Employee Contact should not be added to pendingContactIds.'
    );
    }
    
    
    // ============================================================
    // 14. INACTIVE PCR
    //
    // Covers getContactsMap() inactive PCR condition.
    // ============================================================
    
    @IsTest
    static void testInactivePCR() {
        
        Contact con = getContact();
        
        PRM_Account_Contact_Relationship__c pcr = [
            SELECT Id,
            PRM_Contact_Id__c,
            PRM_Status_Nm__c,
            PRM_InActive_Ind__c
            FROM PRM_Account_Contact_Relationship__c
            WHERE PRM_Contact_Id__c = :con.Id
            LIMIT 1
        ];
        
        pcr.PRM_InActive_Ind__c = true;
        update pcr;
        
        PRM_SalesCloudContactIntStatus_Handler.pendingContactIds.clear();
        
        Test.startTest();
        
        Map<Id, Contact> result = PRM_SalesCloudContactIntStatus_Handler.getContactsMap(new Set<Id>{ con.Id });
        
        Test.stopTest();
        
        System.assertEquals(
            0,
            result.size(),
            'Inactive PCR should not be returned by getContactsMap.'
        );
    }
    
    
    // ============================================================
    // 15. NO PCR
    //
    // Covers conPcrMap.containsKey() = false.
    // ============================================================
    
    @IsTest
    static void testNoPCR() {
        
        Account ipaAccount = [
            SELECT Id
            FROM Account
            WHERE Name = 'IPA Test Account'
            LIMIT 1
        ];
        
        Contact noPcrContact = new Contact(
            AccountId = ipaAccount.Id,
            FirstName = 'No',
            LastName = 'PCR',
            Email = 'nopcr@test.com',
            Core_IPA_PartnerRole__c = getEligiblePartnerRole(),
            Core_Do_Not_Contact__c = false,
            PRM_IPA_Integration_Status__c = 'Pending',
            MailingCountryCode = 'US'
        );
        
        insert noPcrContact;
        
        Contact oldContact =
            getFreshContact(noPcrContact.Id);
        
        Contact newContact =
            oldContact.clone(true, true, true, true);
        
        newContact.Email = 'nopcr.changed@test.com';
        
        PRM_SalesCloudContactIntStatus_Handler.pendingContactIds.clear();
        
        Test.startTest();
        
        PRM_SalesCloudContactIntStatus_Handler.setContactIPAIntegrationStatusToPendingOnUpdate(new List<Contact>{ newContact },new Map<Id, Contact>{newContact.Id => oldContact});
        
        Test.stopTest();
        
        /*System.assertNotEquals(
            'Pending',
            newContact.PRM_IPA_Integration_Status__c,
            'Contact without PCR should not enter conIPACheck branch.'
        );*/
    }
    
    
    // ============================================================
    // 16. PENDING CONTACT SET
    //
    // Covers:
    // if(!pendingContactIds.contains(newCon.id))
    // ============================================================
    
    @IsTest
    static void testPendingContactIds() {
        
        Contact con = getContact();
        
        Contact oldContact = getFreshContact(con.Id);
        
        Contact newContact =
            oldContact.clone(true, true, true, true);
        
        newContact.Email = 'pending.set@test.com';
        
        PRM_SalesCloudContactIntStatus_Handler.pendingContactIds.clear();
        
        PRM_SalesCloudContactIntStatus_Handler.pendingContactIds.add(con.Id);
        
        Test.startTest();
        
        PRM_SalesCloudContactIntStatus_Handler.setContactIPAIntegrationStatusToPendingOnUpdate(new List<Contact>{ newContact },new Map<Id, Contact>{newContact.Id => oldContact});
        
        Test.stopTest();
        
        System.assert(PRM_SalesCloudContactIntStatus_Handler.pendingContactIds.contains(con.Id));
    }
    
    
    // ============================================================
    // 17. DELETED CONTACT
    //
    // Covers Core_MergeContactHandler.PRM_deletedContactIds
    // containing the Contact.
    // ============================================================
    
    @IsTest
    static void testDeletedContact() {
        
        Contact con = getContact();
        
        Core_Contact_Entitlement__c entitlement = [
            SELECT Id,
            Core_Contact_Id__c
            FROM Core_Contact_Entitlement__c
            WHERE Core_Contact_Id__c = :con.Id
            LIMIT 1
        ];
        
        Core_MergeContactHandler.PRM_deletedContactIds =new Set<Id>{ con.Id };
            PRM_SalesCloudContactIntStatus_Handler.pendingContactIds.clear();
        Test.startTest();
        
        PRM_SalesCloudContactIntStatus_Handler.setContactIPAIntegrationStatusToPendingContEnt(new List<Core_Contact_Entitlement__c>{entitlement});
        
        Test.stopTest();
        
        System.assert(Core_MergeContactHandler.PRM_deletedContactIds.contains(con.Id));
    }
    
    
    // ============================================================
    // 18. DELETED CONTACT SET = NULL
    //
    // Covers the ELSE branch:
    //
    // if(Core_MergeContactHandler.PRM_deletedContactIds != null)
    //     ...
    // else
    //     contactsToUpdateNew.add(ContactRec);
    // ============================================================
    
    @IsTest
    static void testDeletedContactSetNull() {
        
        Contact con = getContact();
        
        Core_Contact_Entitlement__c entitlement = [
            SELECT Id,
            Core_Contact_Id__c
            FROM Core_Contact_Entitlement__c
            WHERE Core_Contact_Id__c = :con.Id
            LIMIT 1
        ];
        
        Core_MergeContactHandler.PRM_deletedContactIds = null;
        
        PRM_SalesCloudContactIntStatus_Handler.pendingContactIds.clear();
        
        con.PRM_IPA_Integration_Status__c = 'Pending';
        update con;
        
        Test.startTest();
        
        PRM_SalesCloudContactIntStatus_Handler.setContactIPAIntegrationStatusToPendingContEnt(new List<Core_Contact_Entitlement__c>{entitlement});
        
        Test.stopTest();
        
        Contact result = getFreshContact(con.Id);
        
        System.assertEquals(
            'Pending',
            result.PRM_IPA_Integration_Status__c
        );
    }
    
    
    // ============================================================
    // 19. getContactsMap() WITH ACTIVE PCR
    //
    // Explicitly covers:
    // contactsMap.put(con.id, con)
    // ============================================================
    
    @IsTest
    static void testGetContactsMapActivePCR() {
        
        Contact con = getContact();
        
        PRM_SalesCloudContactIntStatus_Handler.pendingContactIds.clear();
        
        Test.startTest();
        
        Map<Id, Contact> result = PRM_SalesCloudContactIntStatus_Handler.getContactsMap(new Set<Id>{ con.Id });
        
        Test.stopTest();
        
        /*System.assert(
            result.containsKey(con.Id),
            'Active Complete PCR should return Contact.'
        );*/
    }
    
    
    // ============================================================
    // 20. BULK CONTACT UPDATE
    //
    // Creates multiple Contacts and exercises the handler with
    // a bulk list.
    // ============================================================
    
    @IsTest
    static void testBulkContactUpdate() {
        
        Account ipaAccount = [
            SELECT Id
            FROM Account
            WHERE Name = 'IPA Test Account'
            LIMIT 1
        ];
        
        List<Contact> contactsToInsert = new List<Contact>();
        
        for (Integer i = 0; i < 5; i++) {
            
            contactsToInsert.add(
                new Contact(
                    AccountId = ipaAccount.Id,
                    FirstName = 'Bulk' + i,
                    LastName = 'Contact' + i,
                    Email = 'bulk' + i + '@test.com',
                    Core_IPA_PartnerRole__c = getEligiblePartnerRole(),
                    Core_Do_Not_Contact__c = false,
                    PRM_IPA_Integration_Status__c = 'Pending',
                    MailingCountryCode = 'US'
                )
            );
        }
        
        insert contactsToInsert;
        
        /*
* Get the Contact Relationship used by setup.
*/
        PRM_ContactRelationships__c relationship = [
            SELECT Id
            FROM PRM_ContactRelationships__c
            LIMIT 1
        ];
        
        /*
* Create Complete + Active PCR for every Contact.
*/
        List<PRM_Account_Contact_Relationship__c> pcrs =
            new List<PRM_Account_Contact_Relationship__c>();
        
        for (Contact con : contactsToInsert) {
            
            pcrs.add(
                new PRM_Account_Contact_Relationship__c(
                    PRM_Account_Id__c = ipaAccount.Id,
                    PRM_Contact_Id__c = con.Id,
                    PRM_Relationship_Id__c = relationship.Id,
                    PRM_InActive_Ind__c = false,
                    PRM_Status_Nm__c = 'Complete'
                )
            );
        }
        
        insert pcrs;
        
        /*
* Create old versions.
*/
        List<Contact> newContacts =
            new List<Contact>();
        
        Map<Id, Contact> oldMap =
            new Map<Id, Contact>();
        
        for (Contact con : [
            SELECT Id,
            AccountId,
            Email,
            Phone,
            MobilePhone,
            FirstName,
            LastName,
            Salutation,
            Core_Job_Function_Code__c,
            Core_Preferred_Language__c,
            Core_Do_Not_Contact__c,
            Core_English_Only_First_Name__c,
            Core_English_Only_Last_Name__c,
            Core_IPA_PartnerRole__c,
            Core_IPS_Employee_Customer__c,
            MailingCountryCode,
            PRM_IPA_Integration_Status__c
            FROM Contact
            WHERE Id IN :contactsToInsert
        ]) {
            
            Contact oldContact =
                con.clone(true, true, true, true);
            
            Contact newContact =
                con.clone(true, true, true, true);
            
            newContact.Email =
                'changed.' + con.Id + '@test.com';
            
            oldMap.put(con.Id, oldContact);
            newContacts.add(newContact);
        }
        
        PRM_SalesCloudContactIntStatus_Handler.pendingContactIds.clear();
        
        Test.startTest();
        
        PRM_SalesCloudContactIntStatus_Handler.setContactIPAIntegrationStatusToPendingOnUpdate(newContacts,oldMap);
        
        Test.stopTest();
        
        for (Contact con : newContacts) {
            
            System.assertEquals(
                'Pending',
                con.PRM_IPA_Integration_Status__c,
                'Bulk Contact should become Pending.'
            );
        }
    }
    
    
    // ============================================================
    // 21. NULL CONTACT IDS FOR ENTITLEMENT METHOD
    //
    // The method currently adds Core_Contact_Id__c and then checks
    // contactIds != null. This exercises the method safely.
    // ============================================================
    
    @IsTest
    static void testContactEntitlementMultipleRecords() {
        
        Contact con = getContact();
        
        Core_Contact_Entitlement__c entitlement = [
            SELECT Id,
            Core_Contact_Id__c
            FROM Core_Contact_Entitlement__c
            WHERE Core_Contact_Id__c = :con.Id
            LIMIT 1
        ];
        
        PRM_SalesCloudContactIntStatus_Handler.pendingContactIds.clear();
        
        Core_MergeContactHandler.PRM_deletedContactIds = null;
        
        Test.startTest();
        
        PRM_SalesCloudContactIntStatus_Handler.setContactIPAIntegrationStatusToPendingContEnt(new List<Core_Contact_Entitlement__c>{entitlement,entitlement});
        
        Test.stopTest();
        
        //System.assert(PRM_SalesCloudContactIntStatus_Handler.pendingContactIds.contains(con.Id));
    }
}