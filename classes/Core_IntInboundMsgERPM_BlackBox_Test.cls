@isTest
private class Core_IntInboundMsgERPM_BlackBox_Test{
       
    //--------------------------------------------------------------------------------------------------
    // TEST SETUP AND HELPER METHODS
    
    @testSetup
    static void setupTestData() {
    
      
        Core_IntegrationTestUtility.setupAcctContactEntitlementTestData(false);
        
    }
    
    // Helper methods to make it easy to create our messages
    static Core_Integration_Inbound_Message__c newMessage(String sourceSystem, String messageType, String payload){  
        return new Core_Integration_Inbound_Message__c(Core_Source_System__c = sourceSystem,
                                                       Core_Message_Type__c = messageType, Core_Processing_Status__c = 'Pending', Core_Payload__c = payload);
    }
    
   static Core_Integration_Inbound_Message__c newERPMPersonMessageSplit() {     
        return new Core_Integration_Inbound_Message__c(Core_Source_System__c = 'ERPM',
                                                       Core_Message_Type__c = 'Contact', Core_Processing_Status__c = 'Pending', Core_Payload__c = TEST_ERPM_PERSON_XML1, Core_Payload1__c = TEST_ERPM_PERSON_XML2,Core_Payload2__c = TEST_ERPM_PERSON_XML3,Core_Payload3__c = TEST_ERPM_PERSON_XML4);
    }
    
    static Core_Integration_Inbound_Message__c newERPMBlackboxMessage(String payload) { 
        return newMessage('ERPM', 'Blackbox', payload);
    }
     
    //--------------------------------------------------------------------------------------------------
    // BLACKBOX RESPONSE MESSAGE TESTS
    //
    // Test the following scenarios:
    // 11.1 Success message, with Contact match on ERPM Person ID.
    // 11.2 Success message, with Contact match on Email.
    // 11.3 Success message, but no Contact match.
    // 12.1 Failure message, with Contact match on ERPM Person ID.
    // 12.2 Failure message, but no Contact match on ERPM Person ID.
    // 13.1 Bogus message. Should generate an exception.
    
    // 11.1 Success message, with Contact match on ERPM Person ID.
    static testMethod void testERPMBlackboxMessage_11_1_SuccessPersonId() {
        
        System.debug('***** Test 11.1');
        
        Contact testContact = [select Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c
                               from Contact where Core_ERPM_Person_Id__c = '3000000' limit 1];
        
        System.assertEquals('In-Progress', testContact.Core_ERPM_Integration_Status__c);
        System.assertEquals('Testing', testContact.Core_ERPM_Integration_Message__c);
        
        String msg = TEST_ERPM_BLACKBOX_SUCCESS_JSON;
        msg = msg.replace('REPLACE_BB_PERSON_ID',     '3000000');
        msg = msg.replace('REPLACE_BB_ENTERPRISE_ID', '1000001000');
        msg = msg.replace('REPLACE_BB_LOGIN_ID',      'test0');
        msg = msg.replace('REPLACE_BB_EMAIL_ID',      '');
        msg = msg.replace('REPLACE_BB_ACCT1_NUMBER',  '301392141');
        
        Test.startTest();
        insert newERPMBlackboxMessage(msg);
        Test.stopTest();
        
        testContact = [select Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c
                       from Contact where Core_ERPM_Person_Id__c = '3000000' limit 1];
        
        System.assertEquals('Successful', testContact.Core_ERPM_Integration_Status__c);
        System.assertNotEquals(null, testContact.Core_ERPM_Integration_Message__c);
    }
    
    // 11.2 Success message, with Contact match on Email.
    static testMethod void testERPMBlackboxMessage_11_2_SuccessEmail() {
        
        System.debug('***** Test 11.2');
        
        Contact testContact = [select Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c
                               from Contact where Email = 'testcontact0@acct0.com' limit 1];
        
        System.assertEquals('In-Progress', testContact.Core_ERPM_Integration_Status__c);
        System.assertEquals('Testing', testContact.Core_ERPM_Integration_Message__c);
        
        String msg = TEST_ERPM_BLACKBOX_SUCCESS_JSON;
        msg = msg.replace('REPLACE_BB_PERSON_ID',     '3123456');
        msg = msg.replace('REPLACE_BB_ENTERPRISE_ID', '1000001000');
        msg = msg.replace('REPLACE_BB_LOGIN_ID',      'test0');
        msg = msg.replace('REPLACE_BB_EMAIL_ID',      'testcontact0@acct0.com');
        msg = msg.replace('REPLACE_BB_ACCT1_NUMBER',  '301392141');
        
        Test.startTest();
        insert newERPMBlackboxMessage(msg);
        Test.stopTest();
        
        testContact = [select Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c
                       from Contact where Email = 'testcontact0@acct0.com' limit 1];
        
        System.assertEquals('Successful', testContact.Core_ERPM_Integration_Status__c);
        System.assertNotEquals(null, testContact.Core_ERPM_Integration_Message__c);
    }
    
     static testMethod void testERPMBlackboxMessage_11_2_CamelCaseEmailCheck() {
        
        System.debug('***** CamelCaseEmailCheck');
        
        Contact testContact = [select Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c
                               from Contact where Email = 'testcontact0@acct0.com' limit 1];
        
        System.assertEquals('In-Progress', testContact.Core_ERPM_Integration_Status__c);
        System.assertEquals('Testing', testContact.Core_ERPM_Integration_Message__c);
        
        String msg = TEST_ERPM_BLACKBOX_SUCCESS_JSON;
        msg = msg.replace('REPLACE_BB_PERSON_ID',     '3123456');
        msg = msg.replace('REPLACE_BB_ENTERPRISE_ID', '1000001000');
        msg = msg.replace('REPLACE_BB_LOGIN_ID',      'test0');
        msg = msg.replace('REPLACE_BB_EMAIL_ID',      'TestContact0@Acct0.com');
        msg = msg.replace('REPLACE_BB_ACCT1_NUMBER',  '301392141');
        
        Test.startTest();
        insert newERPMBlackboxMessage(msg);
        Test.stopTest();
        
        testContact = [select Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c
                       from Contact where Email = 'testcontact0@acct0.com' limit 1];
        
        System.assertEquals('Successful', testContact.Core_ERPM_Integration_Status__c);
        System.assertNotEquals(null, testContact.Core_ERPM_Integration_Message__c);
    }
     static testMethod void testERPMBlackboxMessage_11_2_CamelCaseEmailCheckWithSpecialChars() {
        
        System.debug('***** CamelCaseEmailCheck');
        
        Contact testContact = [select Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c
                               from Contact where Email = 'blackbox_integ_user@mailnator.com' limit 1];
         testContact.Core_ERPM_Integration_Status__c='In-Progress';
        
        System.assertEquals('In-Progress', testContact.Core_ERPM_Integration_Status__c);
        System.assertEquals('Testing', testContact.Core_ERPM_Integration_Message__c);
        
        String msg = TEST_ERPM_BLACKBOX_SUCCESS_JSON;
        msg = msg.replace('REPLACE_BB_PERSON_ID',     '3123456');
        msg = msg.replace('REPLACE_BB_ENTERPRISE_ID', '1000001000');
        msg = msg.replace('REPLACE_BB_LOGIN_ID',      'test0');
        msg = msg.replace('REPLACE_BB_EMAIL_ID',      'BlackBox_Integ_User@mailnator.com');
        msg = msg.replace('REPLACE_BB_ACCT1_NUMBER',  '301392141');
        
        Test.startTest();
        insert newERPMBlackboxMessage(msg);
        Test.stopTest();
        
        testContact = [select Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c
                       from Contact where Email = 'blackbox_integ_user@mailnator.com' limit 1];
        
        System.assertEquals('Successful', testContact.Core_ERPM_Integration_Status__c);
     
    }
    
    
    
    // 11.3 Success message, but no Contact match.
    static testMethod void testERPMBlackboxMessage_11_3_SuccessNoMatch() {
        
        System.debug('***** Test 11.3');
        
        Contact testContact = [select Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c
                               from Contact where Core_ERPM_Person_Id__c = '3000000' limit 1];
        
        System.assertEquals('In-Progress', testContact.Core_ERPM_Integration_Status__c);
        System.assertEquals('Testing', testContact.Core_ERPM_Integration_Message__c);
        
        String msg = TEST_ERPM_BLACKBOX_SUCCESS_JSON;
        msg = msg.replace('REPLACE_BB_PERSON_ID',     '3123456');
        msg = msg.replace('REPLACE_BB_ENTERPRISE_ID', '1000001000');
        msg = msg.replace('REPLACE_BB_LOGIN_ID',      'test0');
        msg = msg.replace('REPLACE_BB_EMAIL_ID',      'nomatch@acct0.com');
        msg = msg.replace('REPLACE_BB_ACCT1_NUMBER',  '301392141');
        
        Test.startTest();
        insert newERPMBlackboxMessage(msg);
        Test.stopTest();
        
        testContact = [select Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c
                       from Contact where Core_ERPM_Person_Id__c = '3000000' limit 1];
        
        System.assertEquals('In-Progress', testContact.Core_ERPM_Integration_Status__c);
        System.assertEquals('Testing', testContact.Core_ERPM_Integration_Message__c);
    }
    
    // 12.1 Failure message, with Contact match on ERPM Person ID.
    static testMethod void testERPMBlackboxMessage_12_1_FailurePersonId() {
        
        System.debug('***** Test 12.1');
        
        Contact testContact = [select Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c
                               from Contact where Core_ERPM_Person_Id__c = '3000000' limit 1];
        
        System.assertEquals('In-Progress', testContact.Core_ERPM_Integration_Status__c);
        System.assertEquals('Testing', testContact.Core_ERPM_Integration_Message__c);
        
        String msg = TEST_ERPM_BLACKBOX_FAILURE_JSON;
        msg = msg.replace('REPLACE_BB_PERSON_ID',     '3000000');
        msg = msg.replace('REPLACE_BB_ENTERPRISE_ID', '1000001000');
        msg = msg.replace('REPLACE_BB_LOGIN_ID',      'test0');
        msg = msg.replace('REPLACE_BB_EMAIL_ID',      'testcontact0@acct0.com');
        msg = msg.replace('REPLACE_BB_ERROR_CODE',    'ERRCODE');
        msg = msg.replace('REPLACE_BB_ERROR_TEXT',    'ERRTEXT');
        msg = msg.replace('REPLACE_BB_ERROR_DETAILS', 'ERRDETAILS');
        
        Test.startTest();
        insert newERPMBlackboxMessage(msg);
        Test.stopTest();
        
        testContact = [select Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c
                       from Contact where Core_ERPM_Person_Id__c = '3000000' limit 1];
        
        System.assertEquals('Failed', testContact.Core_ERPM_Integration_Status__c);
        System.assertNotEquals(null, testContact.Core_ERPM_Integration_Message__c);
        //System.assertEquals('Error Code: ERRCODE, Error Text: ERRTEXT, Error Details: ERRDETAILS',
        //    testContact.Core_ERPM_Integration_Message__c);
    }
    
    // 12.2 Failure message, but no Contact match on ERPM Person ID.
    static testMethod void testERPMBlackboxMessage_12_2_FailureNoMatch() {
        
        System.debug('***** Test 12.2');
        
        Contact testContact = [select Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c
                               from Contact where Core_ERPM_Person_Id__c = '3000000' limit 1];
        
        System.assertEquals('In-Progress', testContact.Core_ERPM_Integration_Status__c);
        System.assertEquals('Testing', testContact.Core_ERPM_Integration_Message__c);
        
        String msg = TEST_ERPM_BLACKBOX_FAILURE_JSON;
        msg = msg.replace('REPLACE_BB_PERSON_ID',     '3123456');
        msg = msg.replace('REPLACE_BB_ENTERPRISE_ID', '1000001000');
        msg = msg.replace('REPLACE_BB_LOGIN_ID',      'test0');
        msg = msg.replace('REPLACE_BB_EMAIL_ID',      'nomatch0@acct0.com');
        msg = msg.replace('REPLACE_BB_ERROR_CODE',    'ERRCODE');
        msg = msg.replace('REPLACE_BB_ERROR_TEXT',    'ERRTEXT');
        msg = msg.replace('REPLACE_BB_ERROR_DETAILS', 'ERRDETAILS');
        
        Test.startTest();
        insert newERPMBlackboxMessage(msg);
        Test.stopTest();
        
        testContact = [select Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c
                       from Contact where Core_ERPM_Person_Id__c = '3000000' limit 1];
        
        System.assertEquals('In-Progress', testContact.Core_ERPM_Integration_Status__c);
        System.assertEquals('Testing', testContact.Core_ERPM_Integration_Message__c);
    }
    
    // 13.1 Bogus message. Should generate an exception.
    static testMethod void testERPMBlackboxMessage_13_1_BogusMessage() {
        
        System.debug('***** Test 13.1');
        
        // Try to insert a message that isn't a proper Blackbox response message
        String msg = '{"""Staaaaatus": "Failure", "ErrorrrCode": "OOPS", "ErrrrrorText": "We screwed up!"}';
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMBlackboxMessage(msg);
        Test.stopTest();
        
        List<Core_Integration_Inbound_Message__c> msgs =
            [select Core_Processing_Status__c from Core_Integration_Inbound_Message__c];
        
        System.assertEquals(1, msgs.size());
        System.assertEquals('Failed', msgs[0].Core_Processing_Status__c);
    }
    
    //14.1 Concatenate all Payload Fields to one String 
    static testMethod void testnewERPMPerson_14_1_MessageSplit() {           
        System.debug('***** Test 14.1');
        Test.startTest();
        Core_Integration_Inbound_Message__c ib = newERPMPersonMessageSplit();
        insert ib;
        System.debug('String Split'+ib);            
        Test.stopTest();  
        
        System.assertnotEquals(null,ib.id);
        
        Core_Integration_Inbound_Message__c inboundMsg = [
            select Core_Processing_Status__c from Core_Integration_Inbound_Message__c where id = :ib.id limit 1];
        
        System.assertEquals('Successful',inboundMsg.Core_Processing_Status__c);
    }
  
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
    
    
    private static final String TEST_ERPM_BLACKBOX_FAILURE_JSON = '{ ' +
        '"Status": "Failure", ' +
        '"ErrorCode": "REPLACE_BB_ERROR_CODE", ' +
        '"ErrorText": "REPLACE_BB_ERROR_TEXT", ' +
        '"ErrorDetails": "REPLACE_BB_ERROR_DETAILS", ' +
        '"PersonID": REPLACE_BB_PERSON_ID, ' +
        '"EnterpriseID": "REPLACE_BB_ENTERPRISE_ID", ' +
        '"LoginID": "REPLACE_BB_LOGIN_ID", ' +
        '"EmailID": "REPLACE_BB_EMAIL_ID", ' +
        '"Accounts": null ' +
        '}';
    
    private static final String TEST_ERPM_BLACKBOX_SUCCESS_JSON = '{ ' +
        '"Status": "Success", ' +
        '"ErrorCode":null, ' +
        '"ErrorText": null, ' +
        '"ErrorDetails": null, ' +
        '"PersonID": REPLACE_BB_PERSON_ID, ' +
        '"EnterpriseID": "REPLACE_BB_ENTERPRISE_ID", ' +
        '"LoginID": "REPLACE_BB_LOGIN_ID", ' +
        '"EmailID": "REPLACE_BB_EMAIL_ID", ' +
        '"Accounts": [ ' +
        '{ ' +
        '"AccountNumber": REPLACE_BB_ACCT1_NUMBER, ' +
        '"CIMID": "REPLACE_BB_ACCT1_CIMID", ' +
        '"SalesCloudID": "REPLACE_BB_ACCT1_SFDCID" ' +
        '} ' +
        '] ' +
        '}';
}