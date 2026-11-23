@isTest
private class Core_IntInboundMsgERPM_Account_Test{
    
    //--------------------------------------------------------------------------------------------------
    // TEST SETUP AND HELPER METHODS
    
    @testSetup
    static void setupTestData() {
        Core_IntegrationTestUtility.setupAcctContactEntitlementTestData();
    }
    
    // Helper methods to make it easy to create our messages
    static Core_Integration_Inbound_Message__c newMessage(String sourceSystem, String messageType, String payload){  
        return new Core_Integration_Inbound_Message__c(Core_Source_System__c = sourceSystem,
                                                       Core_Message_Type__c = messageType, Core_Processing_Status__c = 'Pending', Core_Payload__c = payload);
    }
    
    static Core_Integration_Inbound_Message__c newERPMAccountMessage(String payload) {
        return newMessage('ERPM', 'Account', payload);
    }
    
    static Core_Integration_Inbound_Message__c newERPMPersonMessageSplit() {     
        return new Core_Integration_Inbound_Message__c(Core_Source_System__c = 'ERPM',
                                                       Core_Message_Type__c = 'Contact', Core_Processing_Status__c = 'Pending', Core_Payload__c = TEST_ERPM_PERSON_XML1, Core_Payload1__c = TEST_ERPM_PERSON_XML2,Core_Payload2__c = TEST_ERPM_PERSON_XML3,Core_Payload3__c = TEST_ERPM_PERSON_XML4);
    }     
    
    //--------------------------------------------------------------------------------------------------
    // ACCOUNT MESSAGE TESTS
    //
    // Test the following scenarios:
    // 6.1 Account match on SFDC ID. B2B Dedup Group Code. Update Account ERPM Engagements.
    // 6.2 Account match on CIM ID. No B2B Dedup Group Code. Update Account ERPM Engagements.
    // 7.1 No Account match, but it's RDC self-reg. Create Account.
    // 7.2 No Account match, and it's not RDC self-reg. Do nothing.
    // 8.1 Bogus message. Should generate an exception.
    
    // 6.1 Account match on SFDC ID. B2B Dedup Group Code. Update Account ERPM Engagements.
    static testMethod void testERPMAccountMessage_6_1_UpdateSFDCID() {
        
        System.debug('***** Test 6.1');
        
        String msg = basicERPMAccountMessageXml();
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        
        Account acct = [select Core_B2B_ERPM_Account_Number__c from Account where Core_CIM_ID__c = '1000' limit 1];
        
        System.assertNotEquals('', acct.Core_B2B_ERPM_Account_Number__c);
        
        List<Core_Account_ERPM_Engagement__c> acctERPMEnggs = [
            select Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c
            from Core_Account_ERPM_Engagement__c
            where Core_Account_Id__r.Core_CIM_ID__c = '1000'
            order by Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c];
        
        System.assertEquals('AE1', acctERPMEnggs[0].Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
        System.assertEquals('AE3', acctERPMEnggs[2].Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
        System.assertEquals(3, acctERPMEnggs.size());
    }
    
    // 6.2 Account match on CIM ID. No B2B Dedup Group Code. Update Account ERPM Engagements.
    static testMethod void testERPMAccountMessage_6_2_UpdateCIMID() {
        
        System.debug('***** Test 6.2');
        
        Account testAcct = [select Id from Account where Core_CIM_ID__c = '1000' limit 1];
        
        String msg = basicERPMAccountMessageXml();
        msg = msg.replace(testAcct.Id, ''); // Blank out SFDC ID
        msg = msg.replace('12345', '1000'); // Swap the bogus CIM ID for a real one
        msg = msg.replace('<engg-dedup-group-code>DEDUPB2B</engg-dedup-group-code>',
                          '<engg-dedup-group-code isnull-indicator="Y" />'); // No B2B Dedup Group Code
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        
        Account acct = [select Core_B2B_ERPM_Account_Number__c from Account where Core_CIM_ID__c = '1000' limit 1];
        
        System.assertEquals(null, acct.Core_B2B_ERPM_Account_Number__c);
        
        List<Core_Account_ERPM_Engagement__c> acctERPMEnggs = [
            select Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c
            from Core_Account_ERPM_Engagement__c
            where Core_Account_Id__r.Core_CIM_ID__c = '1000'
            order by Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c];
        
        System.assertEquals('AE1', acctERPMEnggs[0].Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
        System.assertEquals('AE3', acctERPMEnggs[2].Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
        System.assertEquals(3, acctERPMEnggs.size());
    }
    
    // 7.1 No Account match, but it's RDC self-reg. Create Account and RDC Engagement.
    static testMethod void testERPMAccountMessage_7_1_CreateAccount() {
        
        System.debug('***** Test 7.1');
        
        Account testAcct = [select Id from Account where Core_CIM_ID__c = '1000' limit 1];
        
        String msg = basicERPMAccountMessageXml();
        msg = msg.replace(testAcct.Id,      ''); // Blank out SFDC ID
        msg = msg.replace('12345',          '1010');
        msg = msg.replace('AE1',            Core_IntegrationInboundMessageERPM.RDC_ENGAGEMENT_CODE); // Swap out AE1 with an RDC engagement
        msg = msg.replace('Account Engg 1', 'RDC Self Reg');
        msg = msg.replace('AE3',            'AE2');
        msg = msg.replace('Account Engg 3', 'Account Engg 2');
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        
        List<Account> accts = [
            select Id, Name from Account
            where Core_CIM_ID__c = '1010'];
        
        System.assertEquals(1, accts.size());
        System.assertEquals('COMPUTER CONTACT', accts[0].Name);
        
        List<Core_Account_ERPM_Engagement__c> acctERPMEnggs = [
            select Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c
            from Core_Account_ERPM_Engagement__c
            where Core_Account_Id__r.Core_CIM_ID__c = '1010'
            order by Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c];
        
        System.assertEquals(2, acctERPMEnggs.size());
        System.assertEquals('AE2', acctERPMEnggs[0].Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
        System.assertEquals(Core_IntegrationInboundMessageERPM.RDC_ENGAGEMENT_CODE,
                            acctERPMEnggs[1].Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
    }
    
    // 7.2 No Account match, and it's not RDC self-reg. Do nothing.
    static testMethod void testERPMAccountMessage_6_2_DropMessage() {
        
        System.debug('***** Test 7.2');
        
        Account testAcct = [select Id from Account where Core_CIM_ID__c = '1000' limit 1];
        
        String msg = basicERPMAccountMessageXml();
        msg = msg.replace(testAcct.Id,      ''); // Blank out SFDC ID
        msg = msg.replace('12345',          '1010');
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        
        List<Account> accts = [select Id, Name from Account where Core_CIM_ID__c = '1010'];
        
        System.assertEquals(0, accts.size());
    }
    
    // 8.1 Bogus message. Should generate an exception.
    static testMethod void testERPMAccountMessage_8_1_BogusMessage() {
        
        System.debug('***** Test 8.1');
        
        // Try to insert a message that isn't a proper Account message
        String msg = '{"""Staaaaatus": "Failure", "ErrorrrCode": "OOPS", "ErrrrrorText": "We screwed up!"}';
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        
        List<Core_Integration_Inbound_Message__c> msgs =
            [select Core_Processing_Status__c from Core_Integration_Inbound_Message__c];
        
        System.assertEquals(1, msgs.size());
        System.assertEquals('Failed', msgs[0].Core_Processing_Status__c);
    }
    
    // Return XML for a "basic ERPM Account Message"
    static String basicERPMAccountMessageXml() {
        
        Account testAcct = [select Id from Account where Core_CIM_ID__c = '1000' limit 1];
        
        String msg = TEST_ERPM_ACCOUNT_XML;
        msg = msg.replace('REPLACE_ACCT_NAME',           'COMPUTER CONTACT');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '98765');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '12345');     // Bogus CIM ID
        msg = msg.replace('REPLACE_ACCT_SFDC_ID',        testAcct.Id); // Real SFDC ID
        msg = msg.replace('REPLACE_ACCT_PHONE',          '1001001001');
        msg = msg.replace('REPLACE_ACCT_FAX',            '3001001001');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE1',     'Addr Line 1');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE2',     'Addr Line 2');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE3',     'Addr Line 3');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE4',     'Addr Line 4');
        msg = msg.replace('REPLACE_ACCT_ADDR_CITY',      'Portland');
        msg = msg.replace('REPLACE_ACCT_ADDR_STATE',     'OR');
        msg = msg.replace('REPLACE_ACCT_ADDR_POSTALCODE','97229');
        msg = msg.replace('REPLACE_ACCT_ADDR_COUNTRY',   'USA');
        msg = msg.replace('REPLACE_ACCT_ENGG_CODE1',     'AE1');
        msg = msg.replace('REPLACE_ACCT_ENGG_NAME1',     'Account Engg 1');
        msg = msg.replace('REPLACE_ACCT_ENGG_CODE2',     'AE3');
        msg = msg.replace('REPLACE_ACCT_ENGG_NAME2',     'Account Engg 3');
        return msg;
    }
    
   
    
    //--------------------------------------------------------------------------------------------------
    // XML & JSON STRINGS USED IN TESTS
    
    private static final String TEST_ERPM_PERSON_XML1 = '<?xml version="1.0" encoding="UTF-8"?>' +
        '<person xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" inact-indicator="N" is-delete-indicator="REPLACE_PERSON_IS_DELETE_INDICATOR">' +
        '<person-information>' +
        '<person-id>REPLACE_PERSON_ERPM_PERSON_ID</person-id>' +
        '<external-login-id isnull-indicator="N">REPLACE_PERSON_EXTERNAL_LOGIN</external-login-id>' +
        '<enterprise-id isnull-indicator="N">REPLACE_PERSON_ENTERPRISE_ID</enterprise-id>' +
        '<internal-login-id isnull-indicator="Y" />' +
        '<identity-status isnull-indicator="N">REPLACE_PERSON_IDENTITY_STATUS</identity-status>' +
        '<person-title isnull-indicator="N" >REPLACE_PERSON_TITLE</person-title>' +
        '<person-given-name isnull-indicator="N">REPLACE_PERSON_FIRST_NAME</person-given-name>' +
        '<person-family-name isnull-indicator="N">REPLACE_PERSON_LAST_NAME</person-family-name>' +
        '<language-code>ENG</language-code>' +
        '<occupation-title-code isnull-indicator="N">OPER</occupation-title-code>' +
        '<primary-email-address>REPLACE_PERSON_EMAIL</primary-email-address>' +
        '<all-intel-no-contact-dtm isnull-indicator="Y" />' +
        '<email-valid-status-dtm isnull-indicator="Y" />' +
        '</person-information>' +
        '<person-accounts>' +
        '<person-account inact-indicator="Y">' +
        '<account-number>10450334</account-number>' +
        '<cim-id isnull-indicator="N">11154430</cim-id>' +
        '<account-name>Sistemas y Servicios Erazo Cia. Ltda.</account-name>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGPITP</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="ITP">' +
        '<relation-code>RELTNTRNFR</relation-code>' ;
    
    
    
    private static final String TEST_ERPM_PERSON_XML2 =  +
        '<relation-name>Trainee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<account-engagements>' +
        '<engagement>' +
        '<engg-code>ITP</engg-code>' +
        '<eff-tier-cd>GOLD</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">02/22/2006 12:00:00 AM</engg-status-dtm>' +
        '</engagement>' +
        '</account-engagements>' +
        '</person-account>' +
        '<person-account inact-indicator="N">' +
        '<account-number>1000054337</account-number>' +
        '<cim-id isnull-indicator="N">REPLACE_PERSON_ACCOUNT_CIM_ID</cim-id>' +
        '<account-name>REPLACE_PERSON_ACCOUNT_NAME</account-name>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGPSCD</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNTRNFR</relation-code>' +
        '<relation-name>Trainee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<account-engagements>' +
        '<engagement>' ;
    
    
    
    private static final String TEST_ERPM_PERSON_XML3 =  +
        '<engg-code>REPLACE_PERSON_ACCOUNT_ENGG_CODE1</engg-code>' +
        '<eff-tier-cd>ACCTTIER1</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' +
        '<engagement>' +
        '<engg-code>REPLACE_PERSON_ACCOUNT_ENGG_CODE2</engg-code>' +
        '<eff-tier-cd>ACCTTIER2</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' +
        '</account-engagements>' +
        '</person-account>' +
        '</person-accounts>' +
        '<person-electronic-addresses>' +
        '<person-electronic-address electronic-addr-type-code="FAX" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_FAX</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_MOBILE</electronic-address>' +
        '</person-electronic-address>' ;
    
    
    
    private static final String TEST_ERPM_PERSON_XML4 =  +
        '<person-electronic-address electronic-addr-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_PHONE</electronic-address>' +
        '</person-electronic-address>' +
        '</person-electronic-addresses>' +
        '<person-engagements>' +
        '<engagement inact-indicator="N" engg-cat-code="ENGCATCD16" engg-type-code="ENGTYPSOFT">' +
        '<engg-code>REPLACE_PERSON_PERSON_ENGG_CODE1</engg-code>' +
        '<engg-name>REPLACE_PERSON_PERSON_ENGG_NAME1</engg-name>' +
        '<tier-code>MEMBER</tier-code>' +
        '<effective-tier-code>PERSONTIER1</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
        '<engg-status-dtm isnull-indicator="N">08/16/2016 06:12:55 PM</engg-status-dtm>' +
        '</engagement>' +
        '<engagement inact-indicator="N" engg-cat-code="ENGCATCD16" engg-type-code="ENGTYPSOFT">' +
        '<engg-code>REPLACE_PERSON_PERSON_ENGG_CODE2</engg-code>' +
        '<engg-name>REPLACE_PERSON_PERSON_ENGG_NAME2</engg-name>' +
        '<tier-code>MEMBER</tier-code>' +
        '<effective-tier-code>PERSONTIER2</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
        '<engg-status-dtm isnull-indicator="N">08/16/2016 06:12:55 PM</engg-status-dtm>' +
        '</engagement>' +
        '</person-engagements>' +
        '<person-physical-addresses>' +
        '<physical-address location-type-code="HOME" address-usg-type-code="MAIL" contact-indicator="Y" inact-indicator="N" preferred-indicator="Y" isnull-indicator="">' +
        '<address-line1-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE1</address-line1-text>' +
        '<address-line2-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE2</address-line2-text>' +
        '<address-line3-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE3</address-line3-text>' +
        '<address-line4-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE4</address-line4-text>' +
        '<city-name isnull-indicator="N">REPLACE_PERSON_ADDR_CITY</city-name>' +
        '<state-code isnull-indicator="N">REPLACE_PERSON_ADDR_STATE</state-code>' +
        '<postal-code isnull-indicator="N">REPLACE_PERSON_ADDR_POSTALCODE</postal-code>' +
        '<language-code isnull-indicator="N">ENG</language-code>' +
        '<iso-country-code>REPLACE_PERSON_ADDR_COUNTRY</iso-country-code>' +
        '</physical-address>' +
        '<physical-address location-type-code="BUS" address-usg-type-code="PHY" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '<physical-address location-type-code="BUS" address-usg-type-code="MAIL" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '</person-physical-addresses>' +
        '</person>';
    
    
    private static final String TEST_ERPM_ACCOUNT_XML = '<?xml version="1.0" encoding="UTF-8"?>' +
        '<account xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" test-account-indicator="N" inact-indicator="N">' +
        '<account-information>' +
        '<account-name>REPLACE_ACCT_NAME</account-name>' +
        '<account-names>' +
        '<account-name type="Alias Name" isnull-indicator="Y" />' +
        '<account-name type="Doing Business As" isnull-indicator="Y" />' +
        '<account-name type="Legal Name" isnull-indicator="N" >REPLACE_ACCT_LEGAL_NAME</account-name>' +
        '</account-names>' +
        '<account-number>REPLACE_ACCT_ERPM_NUMBER</account-number>' +
        '<engg-dedup-group-code>DEDUPB2B</engg-dedup-group-code>' +
        '<language-code>SPA</language-code>' +
        '<primary-addr-type-code>MAIL</primary-addr-type-code>' +
        '</account-information>' +
        '<account-external-systems>' +
        '<account-external-system system-name="SAPID" inact-indicator="N">8000242150</account-external-system>' +
        '<account-external-system system-name="CIM" inact-indicator="N">REPLACE_ACCT_CIM_ID</account-external-system>' +
        '<account-external-system system-name="SLSCLDID" inact-indicator="N">REPLACE_ACCT_SFDC_ID</account-external-system>' +
        '</account-external-systems>' +
        '<electronic-addresses>' +
        '<electronic-address electronic-type-code="FAX" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="N">REPLACE_ACCT_FAX</electronic-address>' +
        '<electronic-address electronic-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="N">REPLACE_ACCT_PHONE</electronic-address>' +
        '<electronic-address electronic-type-code="URL" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="Y" />' +
        '<electronic-address electronic-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="Y" />' +
        '</electronic-addresses>' +
        '<physical-addresses>' +
        '<physical-address address-usg-type-code="MAIL" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
        '<physical-address address-usg-type-code="PHY" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
        '<physical-address address-usg-type-code="PHY" contact-indicator="Y" preferred-indicator="N" inact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<address-line1-text>REPLACE_ACCT_ADDR_LINE1</address-line1-text>' +
        '<address-line2-text isnull-indicator="N">REPLACE_ACCT_ADDR_LINE2</address-line2-text>' +
        '<address-line3-text isnull-indicator="N">REPLACE_ACCT_ADDR_LINE3</address-line3-text>' +
        '<address-line4-text isnull-indicator="N">REPLACE_ACCT_ADDR_LINE4</address-line4-text>' +
        '<city-name>REPLACE_ACCT_ADDR_CITY</city-name>' +
        '<state-code isnull-indicator="N">REPLACE_ACCT_ADDR_STATE</state-code>' +
        '<state-name isnull-indicator="N">Guayas</state-name>' +
        '<postal-code isnull-indicator="N">REPLACE_ACCT_ADDR_POSTALCODE</postal-code>' +
        '<country-code>EC</country-code>' +
        '<country-name isnull-indicator="N">Ecuador</country-name>' +
        '<iso-country-code>REPLACE_ACCT_ADDR_COUNTRY</iso-country-code>' +
        '</physical-address>' +
        '</physical-addresses>' +
        '<engagements>' +
        '<engagement inact-indicator="N" engg-cat-code="ENGCATCD11" engg-type-code="ENGTYPSECR">' +
        '<engg-id>10118</engg-id>' +
        '<engg-code>REPLACE_ACCT_ENGG_CODE1</engg-code>' +
        '<engg-name>REPLACE_ACCT_ENGG_NAME1</engg-name>' +
        '<tier-code>GOLD</tier-code>' +
        '<effective-tier-code>GOLD</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
        '<engg-status-reason-code isnull-indicator="Y" />' +
        '</engagement>' +
        '<engagement inact-indicator="N" engg-cat-code="ENGCATCD11" engg-type-code="ENGTYPSECR">' +
        '<engg-id>10118</engg-id>' +
        '<engg-code>REPLACE_ACCT_ENGG_CODE2</engg-code>' +
        '<engg-name>REPLACE_ACCT_ENGG_NAME2</engg-name>' +
        '<tier-code>GOLD</tier-code>' +
        '<effective-tier-code>GOLD</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
        '<engg-status-reason-code isnull-indicator="Y" />' +
        '</engagement>' +
        '</engagements>' +
        '</account>';
    
   
}