@IsTest
public class Core_ACM_PayloadBuilder_Test {

    @TestSetup
    static void setupData() {

        // Custom Setting: Salutation -> Title
        Core_Entitlement_Salutation_PrsTitle_Map__c salMap = new Core_Entitlement_Salutation_PrsTitle_Map__c(
            Name = 'Mr',
            Salutation__c = 'Mr.',
            PersonTitle__c = 'Mister'
        );
        insert salMap;

        // Custom Setting: Country ISO2 Mapping
        Core_Country_Code_Mapping__c countryMap = new Core_Country_Code_Mapping__c(
            Name = 'US',
            ISO_Code__c = 'USA',
            Country_Code__c = 'US'
        );
        insert countryMap;

        // Phone Prefix Mapping
        insert new Core_Country_Phone_Prefix_Mapping__c(
            Name = 'US',
            Core_Country_Name__c = 'Antarctica',
            Core_Country_Code__c = 'USA',
            Core_Phone_Prefix__c = '+1'
        );

        // Contact
        List<Account> lstAccounts = Core_Test_Utility.createAccount(1);
        Account account = lstAccounts[0];
        account.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        insert account;
        
        Contact c = new Contact(
            LastName = 'TestLast',
            FirstName = 'TestFirst',
            Email = 'test@example.com',
            Phone = '1234567890',
            AccountId = account.id,
            Core_eRPM_Person_Id__c = 'P123',
            Core_Enterprise_Id__c = 'E123',
            Core_Profession__c = 'CISO',
            Core_English_Only_First_Name__c = 'TestFirstEN',
            Core_English_Only_Last_Name__c = 'TestLastEN',
            Core_Sales_Do_Not_Contact_Ind__c = true,
            Core_Do_Not_Contact__c = true,
            Core_Do_Not_Contact_Dtm__c = System.now(),
            Core_Marketing_Do_Not_Contact_Dtm__c = System.now(),
            Salutation = 'Mr.',
            Core_Job_Function_Code__c = 'DEV',
            Core_Preferred_Language__c = 'ENG',
            MailingCountry = 'USA'
        );
        insert c;

        // Create dependent entitlement role (minimal required structure)
        Core_AGS_Role__c role = new Core_AGS_Role__c(
            Name = 'Role1',
            Core_Technical_Name__c = 'TECH_ROLE'
        );
        insert role;

        Core_Entitlement__c ent = new Core_Entitlement__c(
            Name = 'Ent1',
            Core_Display_Name__c = 'Tets Ent1',
            Entitlement_B2B_B2C_Indicator__c = 'B2B',
            Core_AGS_Role_Id__c = role.Id
        );
        insert ent;

        insert new Core_Contact_Entitlement__c(
            Core_Contact_Id__c = c.Id,
            Core_Entitlement_Id__c = ent.Id,
            Core_Selected__c = true,
            Core_Status__c = 'Pending'
        );
    }

    @IsTest
    static void testBuildPayload() {
        Contact c = [
SELECT Id,
               FirstName,
               LastName,
               Email,
            Phone,
            MobilePhone,
               Core_eRPM_Person_Id__c,
               Core_Enterprise_Id__c,
               Core_Profession__c,
               Core_English_Only_First_Name__c,
               Core_English_Only_Last_Name__c,
               Core_Sales_Do_Not_Contact_Ind__c,
               Core_Do_Not_Contact__c,
               Core_Do_Not_Contact_Dtm__c,
               Core_Marketing_Do_Not_Contact_Dtm__c,
               Salutation,
            MailingCountryCode,
            MailingStateCode,
               Core_Job_Function_Code__c,
               Core_Preferred_Language__c
        FROM Contact LIMIT 1];

        Test.startTest();
        Core_ACM_PayloadWrapper payload =
            Core_ACM_PayloadBuilder.buildPayload(c, new Map<Id, Contact>());
        Test.stopTest();

        System.assertNotEquals(null, payload);
        System.assertNotEquals(null, payload.PersonAccountProfile);
    }

    @IsTest
    static void testBuildPersonAcctProfile() {
        Contact c = [
				SELECT Id,
               FirstName,
               LastName,
               Email,
            Phone,
            MobilePhone,
               Core_eRPM_Person_Id__c,
               Core_Enterprise_Id__c,
               Core_Profession__c,
               Core_English_Only_First_Name__c,
               Core_English_Only_Last_Name__c,
               Core_Sales_Do_Not_Contact_Ind__c,
               Core_Do_Not_Contact__c,
               Core_Do_Not_Contact_Dtm__c,
               Core_Marketing_Do_Not_Contact_Dtm__c,
               Salutation,
            MailingCountryCode,
            MailingStateCode,
               Core_Job_Function_Code__c,
               Core_Preferred_Language__c
        FROM Contact LIMIT 1];

        Core_ACM_PayloadWrapper.PersonAccountProfile profile =
            Core_ACM_PayloadBuilder.buildPersonAcctProfile(c, null);

        System.assertEquals('P123', profile.PersonID);
        System.assertEquals('E123', profile.EnterpriseID);
        System.assertEquals('CISO', profile.ExternalAttributes.ProfessionCode);
        System.assertEquals('Mister', profile.PersonTitle);
        System.assertEquals('ENG', profile.LanguageCode);
    }

    @IsTest
    static void testTruncateField() {
        String longStr = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        String result = Core_ACM_PayloadBuilder.truncateField(longStr, 10);

        System.assertEquals(10, result.length());

        String shortStr = 'Short';
        String result2 = Core_ACM_PayloadBuilder.truncateField(shortStr, 10);

        System.assertEquals('Short', result2);
    }

    @IsTest
    static void testGetPersonTitle() {
        String title = Core_ACM_PayloadBuilder.getPersonTitle('Mr.');

        System.assertEquals('Mister', title);
    }

    @IsTest
    static void testGetISO2CountryCode() {
        String code = Core_ACM_PayloadBuilder.getISO2CountryCode('USA');

        System.assertEquals('US', code);
    }

    @IsTest
    static void testBuildAGSPayload() {
        Contact c = [SELECT Id, FirstName, LastName, Email, Phone,
                            Core_Enterprise_Id__c, MailingCountry,
                            Core_Account_Primary_Country__c,
                            Core_Preferred_Language__c
                     FROM Contact LIMIT 1];

        Test.startTest();
        Core_ACM_PayloadWrapper.AGSOutboundPayload payload =
            Core_ACM_PayloadBuilder.buildAGSPayload(c);
        Test.stopTest();

        System.assertNotEquals(null, payload);
        System.assertEquals('E123', payload.enterpriseId);
        System.assertEquals('TestFirst', payload.firstName);
        System.assertEquals('TestLast', payload.lastName);
        System.assert(payload.pendingRoles.size() > 0);
    }
}