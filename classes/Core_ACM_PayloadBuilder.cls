public without sharing class Core_ACM_PayloadBuilder {
    private static Map<String, String> salutationToTitleMap;
    private static Map<String, String> iso2ToCountryCodeMap;

    public static Core_ACM_PayloadWrapper buildPayload(Contact contact, Map<Id, Contact> oldContactMap) {
        Core_ACM_PayloadWrapper payload = new Core_ACM_PayloadWrapper();
        payload.PersonAccountProfile = buildPersonAcctProfile(contact, oldContactMap);
        return payload;
    }

    public static Core_ACM_PayloadWrapper.PersonAccountProfile buildPersonAcctProfile(Contact contact, Map<Id, Contact> oldContactMap) {
        Core_ACM_PayloadWrapper.PersonAccountProfile pAcctProfile = new Core_ACM_PayloadWrapper.PersonAccountProfile();
        pAcctProfile.PersonID = contact.Core_eRPM_Person_Id__c;
        pAcctProfile.EnterpriseID = contact.Core_Enterprise_Id__c;
        pAcctProfile.LoginID = null;
        pAcctProfile.ExternalAttributes.ProfessionCode = contact.Core_Profession__c;

        pAcctProfile.FirstName = truncateField(contact.FirstName, Core_ACM_Constants.FIRST_NAME_MAX_LENGTH);
        pAcctProfile.LastName = truncateField(contact.LastName, Core_ACM_Constants.LAST_NAME_MAX_LENGTH);

        pAcctProfile.EmailID = contact.Email;
        pAcctProfile.EnglishFirstName = contact.Core_English_Only_First_Name__c;
        pAcctProfile.EnglishLastName = contact.Core_English_Only_Last_Name__c;
        pAcctProfile.PersonRegistrationTypeCode = Core_ACM_Constants.REGISTRATION_TYPE_INTEL;

        if (contact.Core_Sales_Do_Not_Contact_Ind__c) {
            pAcctProfile.SalesDoNotContactFlag = Core_ACM_Constants.getFlagValue(Core_ACM_Constants.Flag.YES);
            pAcctProfile.SalesDoNotContactDate = contact.Core_Do_Not_Contact_Dtm__c;
        } else {
            pAcctProfile.SalesDoNotContactFlag = Core_ACM_Constants.getFlagValue(Core_ACM_Constants.Flag.NO);
        }

        if (contact.Core_Do_Not_Contact__c) {
            pAcctProfile.DoNotContactFlag = Core_ACM_Constants.getFlagValue(Core_ACM_Constants.Flag.YES);
            pAcctProfile.AllIntelDoNotContactDate = contact.Core_Marketing_Do_Not_Contact_Dtm__c;
        } else {
            pAcctProfile.DoNotContactFlag = Core_ACM_Constants.getFlagValue(Core_ACM_Constants.Flag.NO);
        }

        pAcctProfile.PersonTitle = getPersonTitle(contact.Salutation);
        pAcctProfile.JobFunction = contact.Core_Job_Function_Code__c;

        // Delegate to focused builders (SRP)
        pAcctProfile.PersonPhysicalAddresses = Core_ACM_AddressBuilder.buildPhysicalAddress(contact);
        pAcctProfile.PersonElectronicAddresses = Core_ACM_AddressBuilder.buildElectronicAddress(contact, oldContactMap);

        if (contact.Core_Preferred_Language__c != null) {
            pAcctProfile.LanguageCode = contact.Core_Preferred_Language__c;
        }

        Map<String, String> mSoftEngCodes = Core_ACM_ContactDataProcessor.getSoftEngagementCode(contact);
        pAcctProfile.Subscriptions = Core_ACM_ContactDataProcessor.getSubscriptions(contact);
        pAcctProfile.Memberships = Core_ACM_ContactDataProcessor.getMemberShips(contact, mSoftEngCodes);
        return pAcctProfile;
    }

    private static String truncateField(String value, Integer maxLength) {
        if (String.isNotBlank(value) && value.length() > maxLength) {
            return value.subString(0, maxLength);
        }
        return value;
    }

    public static String getPersonTitle(String Salutation) {
        if (String.isBlank(Salutation)) {
            return null;
        }
        if (salutationToTitleMap == null) {
            salutationToTitleMap = new Map<String, String>();
            for (Core_Entitlement_Salutation_PrsTitle_Map__c mapping : Core_Entitlement_Salutation_PrsTitle_Map__c.getall().values()) {
                if (String.isNotBlank(mapping.Salutation__c)) {
                    salutationToTitleMap.put(mapping.Salutation__c, mapping.PersonTitle__c);
                }
            }
        }
        return salutationToTitleMap.get(Salutation);
    }

    public static String getISO2CountryCode(String countrycode) {
        if (String.isBlank(countrycode)) {
            return null;
        }
        if (iso2ToCountryCodeMap == null) {
            iso2ToCountryCodeMap = new Map<String, String>();
            for (Core_Country_Code_Mapping__c mapping : Core_Country_Code_Mapping__c.getall().values()) {
                if (String.isNotBlank(mapping.ISO_Code__c)) {
                    iso2ToCountryCodeMap.put(mapping.ISO_Code__c, mapping.Country_Code__c);
                }
            }
        }
        return iso2ToCountryCodeMap.get(countrycode);
    }
    
    //Ganesh Changes
	public static Core_ACM_PayloadWrapper.RoleRequestPayload buildRoleRequestPayload(
    Contact contact
) {

    Core_ACM_PayloadWrapper.RoleRequestPayload payload =
        new Core_ACM_PayloadWrapper.RoleRequestPayload();

    payload.requestee =
        new Core_ACM_PayloadWrapper.Requestee(
            contact.Core_Enterprise_Id__c
        );

    payload.requestItems =
        new List<Core_ACM_PayloadWrapper.RequestItem>();

    List<Core_Contact_Entitlement__c> entitlements = [
        SELECT Core_Selected__c,
               Core_Status__c,
               Core_Entitlement_Id__r.Entitlement_B2B_B2C_Indicator__c,
               Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c
        FROM Core_Contact_Entitlement__c
        WHERE Core_Contact_Id__c = :contact.Id
        AND Core_Entitlement_Id__r.Core_AGS_Role_Id__c != NULL
    ];

    System.debug('Total Entitlements Found: ' + entitlements.size());

    for(Core_Contact_Entitlement__c ce : entitlements){

        if(ce.Core_Status__c != 'Pending'){
            continue;
        }

        // Process ONLY B2B Entitlements
        if(
            ce.Core_Entitlement_Id__r.Entitlement_B2B_B2C_Indicator__c !=
            'B2B'
        ){
            continue;
        }

        payload.requestItems.add(
            new Core_ACM_PayloadWrapper.RequestItem(
                ce.Core_Selected__c ? 'Add' : 'Remove',
                new Core_ACM_PayloadWrapper.Access(
                    'Role',
                    ce.Core_Entitlement_Id__r
                        .Core_AGS_Role_Id__r
                        .Core_Technical_Name__c
                ),
                'SF API Request'
            )
        );
    }

    return payload;
}
//Ganesh Changes End
}