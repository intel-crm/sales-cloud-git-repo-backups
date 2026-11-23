@isTest
private class Core_IntegrationInboundMessageERPM_Test {
    
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
    
    
    static Core_Integration_Inbound_Message__c newERPMPersonMessage(String payload) {
        return newMessage('ERPM', 'Contact', payload);
    }
    
    
    static Core_Integration_Inbound_Message__c newERPMAccountMessage(String payload) {
        return newMessage('ERPM', 'Account', payload);
    }
    
    
    static Core_Integration_Inbound_Message__c newERPMBlackboxMessage(String payload) { 
        return newMessage('ERPM', 'Blackbox', payload);
    }
    
    static Core_Integration_Inbound_Message__c newERPMPersonMessageSplit() {     
        return new Core_Integration_Inbound_Message__c(Core_Source_System__c = 'ERPM',
                                                       Core_Message_Type__c = 'Contact', Core_Processing_Status__c = 'Pending', Core_Payload__c = TEST_ERPM_PERSON_XML1, Core_Payload1__c = TEST_ERPM_PERSON_XML2,Core_Payload2__c = TEST_ERPM_PERSON_XML3,Core_Payload3__c = TEST_ERPM_PERSON_XML4);
    }     
    
    
    //--------------------------------------------------------------------------------------------------
    // PERSON MESSAGE TESTS
    //
    // Test the following scenarios, for inserts (unless otherwise noted):
    // 1.1 Contact match on ERPM Person ID. Update core info on Contact record, including Email, Identity Status.
    // 1.1.1 Contact match on ERPM Person ID, but test an update operation, to simulate a "retry" of message processing.
    // 1.2 Contact match on Email (ERPM Person ID on matching record is blank). Update Contact with ERPM Person ID, plus other core info.
    // 1.2.1 Contact match on Email (ERPM Person ID on match is blank). And NO Enterprise ID in the message. Update Contact with ERPM Person ID, plus other core info.
    // 1.3 Contact match. Update Person & Account Engagements at Contact level where all exist in DB (add, update, deselect).
    // 1.4 Contact match. Update Person & Account Engagements where 2 need to be added to DB.
    // 1.5 Contact match. Account has changed, and it's not a B2B Account. Update Account. <=== THIS WAS REMOVED AFTER DISCUSSION WITH GULSHAN
    // 1.6 Contact match. Account has changed, but it's a B2B Account. Don't update Account.
    // 1.7.1 ERPM Delete scenario.
    // 1.7.2 ERPM Disabled scenario.
    // 1.7.3 ERPM Soft delete scenario.
    // 1.8 Message has email address that contains ".duplicate", before @ symbol. Ignore the message even if there's a matching contact record.
    // 2.1 No Contact match, but Account match on CIM ID. Create Contact and associate with Account.
    // 2.2 No Contact match, and no Account match, but it's RDC self-reg. Create Account, then Contact. <== REMOVED AFTER DISCUSSION WITH JORDAN
    // 2.3 No Contact match, and no Account match, and not RDC self-reg. Do nothing.
    // 2.4 No Contact match, and message does not contain Account. Do nothing.
    // 3.1 ERPM soft delete (first message). Contact match. Update Contact to blank out necessary fields and deselect Entitlements.
    // 3.2 ERPM soft delete (subsequent messages). Contact match. Update Contact to blank out necessary fields and deselect Entitlements.
    // 4.1 Bogus message was sent, which should generate an exception.
    // 5.1 Bulk messages. Check to make sure bulkification is working, loading records from a static resource.
    
    // 1.1 Contact match on ERPM Person ID. Update core info on Contact record, including Email, Identity Status.
    static testMethod void testERPMPersonMessage_1_1_UpdateCoreOnInsert() {
        
        System.debug('***** Test 1.1');
        
        String msg = TEST_ERPM_PERSON_XML;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000000');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test0_new');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000001001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'Dr');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName0_New');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName0_New');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact0_new@acct0duplicate.com'); // By including "duplicate" after @ symbol, we ensure we *will* process
        // such messages and only ignore them if it's before @ symbol
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1000');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 0');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'AE1');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE2', 'AE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE1',  'PE1');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME1',  'PE1 Name');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE2',  'PE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME2',  'PE2 Name');
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        Contact c = [select Id, Core_eRPM_Person_Id__c, Core_Enterprise_ID__c, Core_Identity_Status__c, Core_Login_Id__c,
                     Core_Login_Status__c, Title, FirstName, LastName, Email, Phone, MobilePhone, Fax,
                     MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,
                     Core_ERPM_Integration_Status__c
                     from Contact where Core_eRPM_Person_Id__c = '3000000' limit 1];
        
        System.debug('##### c = ' + c);
        
        System.assertEquals('test0_new',                   c.Core_Login_Id__c);
        System.assertEquals('1000001001',                  c.Core_Enterprise_ID__c);
        System.assertEquals('A',                           c.Core_Identity_Status__c);
        System.assertEquals('Active',                      c.Core_Login_Status__c);
        System.assertEquals('Mr',                          c.Title);
        System.assertEquals('FName0_New',                  c.FirstName);
        System.assertEquals('LName0_New',                  c.LastName);
        System.assertEquals('testcontact0_new@acct0duplicate.com', c.Email);
        System.assertEquals('1001001001',                  c.Phone);
        System.assertEquals('2001001001',                  c.MobilePhone);
        System.assertEquals('3001001001',                  c.Fax);
        //System.assertEquals('Addr 1 Addr 2 Addr 3 Addr 4', c.MailingStreet);
        //System.assertEquals('Portland',                    c.MailingCity);
        //System.assertEquals('OR',                          c.MailingState);
        //System.assertEquals('97229',                       c.MailingPostalCode);
        //System.assertEquals('USA',                         c.MailingCountry);
        //System.assertEquals('Successful',                  c.Core_ERPM_Integration_Status__c);
        
        // Make sure an outbound message was generated, for Box B - Removed Pooja
        /* List<Core_Integration_Outbound_Message__c> outboundMsgs = [
select Id from Core_Integration_Outbound_Message__c where Core_MessageType__c = 'Box B Contact'];

System.debug('##### OUTBOUND MESSAGES: ' + outboundMsgs);

System.assertEquals(1, outboundMsgs.size()); */
        
        // Make sure a log entry was created and it's linked to from the inbound message
        List<Core_Log_Entry__c> logEntries = [select Core_Severity__c from Core_Log_Entry__c
                                              where Core_Origin__c = :Core_IntegrationInboundMessageERPM.LOG_ENTRY_ORIGIN
                                              and Core_Project__c = :Core_IntegrationInboundMessageERPM.LOG_ENTRY_PROJECT
                                              and Core_Scope__c = :Core_IntegrationInboundMessageERPM.LOG_ENTRY_SCOPE
                                              order by Id desc];
        System.assert(logEntries.size() >= 1);
        System.assertEquals(Core_IntegrationInboundMessageERPM.LOG_ENTRY_INFO, logEntries[0].Core_Severity__c);
        System.assertEquals(logEntries[0].Id, [select Core_Log_Entry__c from Core_Integration_Inbound_Message__c limit 1][0].Core_Log_Entry__c);
    }
    
    // 1.1.1 Contact match on ERPM Person ID, but test an update operation, to simulate a "retry" of message processing.
    static testMethod void testERPMPersonMessage_1_1_1_UpdateCoreOnUpdate() {
        
        System.debug('***** Test 1.1.1');
        
        String msg = basicERPMPersonMessageXml();
        msg = msg.replace('FName0', 'FName0_New');
        msg = msg.replace('LName0', 'LName0_New');
        
        System.debug('##### msg = ' + msg);
        
        // Turn off the trigger functionality when inserting the message
        Core_Trigger_Executions__c triggerEntry = [select Core_Active__c from Core_Trigger_Executions__c
                                                   where Name = 'processInboundMessagesERPM' limit 1];
        triggerEntry.Core_Active__c = false;
        update triggerEntry;
        
        // Insert the message
        insert newERPMPersonMessage(msg);
        
        // Make sure the insert didn't do anything
        Contact c = [select Id, Core_eRPM_Person_Id__c, Core_Enterprise_ID__c, Core_Identity_Status__c,
                     Title, FirstName, LastName, Email, Phone, MobilePhone, Fax,
                     MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
                     from Contact where Core_eRPM_Person_Id__c = '3000000' limit 1];
        
        System.assertEquals('FName0', c.FirstName);
        System.assertEquals('LName0', c.LastName);
        
        // Select the message we just inserted
        Core_Integration_Inbound_Message__c inboundMsg = [
            select Core_Processing_Status__c from Core_Integration_Inbound_Message__c
            where Core_Source_System__c = 'ERPM' and Core_Message_Type__c = 'Contact' limit 1];
        
        // Turn our trigger functionality back on
        triggerEntry.Core_Active__c = true;
        update triggerEntry;
        
        // Update our message back to Pending
        Core_IntegrationInboundMessageHandler.hasProcessedNewMessagesAfter = false;
        inboundMsg.Core_Processing_Status__c = 'Pending';
        
        Test.startTest();
        update inboundMsg;
        Test.stopTest();
        
        // Make sure the update worked
        c = [select Id, Core_eRPM_Person_Id__c, Core_Enterprise_ID__c, Core_Identity_Status__c,
             Title, FirstName, LastName, Email, Phone, MobilePhone, Fax,
             MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
             from Contact where Core_eRPM_Person_Id__c = '3000000' limit 1];
        
        System.debug('##### c = ' + c);
        
        System.assertEquals('FName0_New', c.FirstName);
        System.assertEquals('LName0_New', c.LastName);
    }
    
    // 1.2 Contact match on Email (ERPM Person ID on matching record is blank). Update Contact with ERPM Person ID, plus other core info.
    static testMethod void testERPMPersonMessage_1_2_UpdateOnEmailMatch() {
        
        System.debug('***** Test 1.2');
        
        Contact c = [select Id, Core_eRPM_Person_Id__c from Contact where Core_eRPM_Person_Id__c = '3000000' limit 1];
        c.Core_eRPM_Person_Id__c = null;
        update c;
        
        String msg = basicERPMPersonMessageXml();
        msg = msg.replace('<person-id>3000000', '<person-id>3000005');
        msg = msg.replace('FName0', 'FName0_New');
        msg = msg.replace('LName0', 'LName0_New');
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        c = [select Id, Core_eRPM_Person_Id__c, Core_Enterprise_ID__c, Core_Identity_Status__c,
             Title, FirstName, LastName, Email, Phone, MobilePhone, Fax,
             MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
             from Contact where Email = 'testcontact0@acct0.com' limit 1];
        
        System.debug('##### c = ' + c);
        
        System.assertEquals('3000005',    c.Core_eRPM_Person_Id__c);
        System.assertEquals('FName0_New', c.FirstName);
        System.assertEquals('LName0_New', c.LastName);
    }
    
    // 1.2.1 Contact match on Email (ERPM Person ID on match is blank). And NO Enterprise ID in the message. Update Contact with ERPM Person ID, plus other core info.
    static testMethod void testERPMPersonMessage_1_2_1_UpdateOnEmailMatchNoEntId() {
        
        System.debug('***** Test 1.2.1');
        
        Contact c = [select Id, Core_eRPM_Person_Id__c from Contact where Core_eRPM_Person_Id__c = '3000000' limit 1];
        c.Core_eRPM_Person_Id__c = null;
        update c;
        
        String msg = basicERPMPersonMessageXml();
        msg = msg.replace('<person-id>3000000', '<person-id>3000005');
        msg = msg.replace('<enterprise-id isnull-indicator="N">1000001000</enterprise-id>', '<enterprise-id isnull-indicator="Y"/>');
        msg = msg.replace('FName0', 'FName0_New');
        msg = msg.replace('LName0', 'LName0_New');
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        c = [select Id, Core_eRPM_Person_Id__c, Core_Enterprise_ID__c, Core_Identity_Status__c,
             Title, FirstName, LastName, Email, Phone, MobilePhone, Fax,
             MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
             from Contact where Email = 'testcontact0@acct0.com' limit 1];
        
        System.debug('##### c = ' + c);
        
        System.assertEquals('3000005',    c.Core_eRPM_Person_Id__c);
        System.assertEquals('FName0_New', c.FirstName);
        System.assertEquals('LName0_New', c.LastName);
    }
    
    // 1.2.2 Contact match on Email (ERPM Person ID on matching record is *not* blank and doesn't match message). Ignore message.
    static testMethod void testERPMPersonMessage_1_2_2_UpdateOnEmailMatchDiffPersonId() {
        
        System.debug('***** Test 1.2.2');
        
        String msg = basicERPMPersonMessageXml();
        msg = msg.replace('<person-id>3000000', '<person-id>3000005');
        msg = msg.replace('FName0', 'FName0_New');
        msg = msg.replace('LName0', 'LName0_New');
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        Contact c = [select Id, Core_eRPM_Person_Id__c, Core_Enterprise_ID__c, Core_Identity_Status__c,
                     Title, FirstName, LastName, Email, Phone, MobilePhone, Fax,
                     MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
                     from Contact where Email = 'testcontact0@acct0.com' limit 1];
        
        System.debug('##### c = ' + c);
        
        //System.assertNotEquals('3000005',    c.Core_eRPM_Person_Id__c);
        // System.assertNotEquals('FName0_New', c.FirstName);
        //System.assertNotEquals('LName0_New', c.LastName);
    }
    
    // 1.3 Contact match. Update Person & Account Engagements at Contact level where all exist in DB (add, update, deselect).
    static testMethod void testERPMPersonMessage_1_3_UpdateEnggs() {
        
        System.debug('***** Test 1.3');
        
        String msg = basicERPMPersonMessageXml();
        
        // Initial state = AE1: true, AE2: true, PE1: false, PE2-1: false, PE2-2: true, PE2-0: true
        
        // Original logic: AE1 updated, AE2 removed, AE3 added (note: per new logic, these shouldn't matter as far as contact entitlements)
        // NOTE: this was commented out & changed when we received new logic from the ERPM team on how it should work
        //msg = msg.replace('<account-engagements><engagement><engg-code>AE1</engg-code><eff-tier-cd>ACCTTIER1</eff-tier-cd><engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm></engagement><engagement><engg-code>AE2</engg-code><eff-tier-cd>ACCTTIER2</eff-tier-cd><engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm></engagement></account-engagements>',
        //                  '<account-engagements><engagement><engg-code>AE1</engg-code><eff-tier-cd>ACCTTIER2</eff-tier-cd><engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm></engagement><engagement><engg-code>AE3</engg-code><eff-tier-cd>ACCTTIER3</eff-tier-cd><engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm></engagement></account-engagements>');
        
        // New logic: AE1 removed & AE3 added, by adding & removing account engagements & person account relations
        msg = msg.replace('<account-engagements><engagement><engg-code>AE1</engg-code><eff-tier-cd>ACCTTIER1</eff-tier-cd><engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm></engagement><engagement><engg-code>AE2</engg-code><eff-tier-cd>ACCTTIER2</eff-tier-cd><engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm></engagement></account-engagements>',
                          '<account-engagements><engagement><engg-code>AE1</engg-code><eff-tier-cd>ACCTTIER2</eff-tier-cd><engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm></engagement><engagement><engg-code>AE3</engg-code><eff-tier-cd>ACCTTIER3</eff-tier-cd><engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm></engagement></account-engagements>');
        msg = msg.replace('<person-account-relation inact-indicator="N" engagement-code="AE1"><relation-code>RELTNTRNFR</relation-code><relation-name>Trainee</relation-name><effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm></person-account-relation>',
                          '<person-account-relation inact-indicator="N" engagement-code="AE3"><relation-code>RELTNTRNFR</relation-code><relation-name>Trainee</relation-name><effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm></person-account-relation>');
        
        // PE1 updated, PE2 removed, PE3 added
        msg = msg.replace('<person-engagements><engagement inact-indicator="N" engg-cat-code="ENGCATCD16" engg-type-code="ENGTYPSOFT"><engg-code>PE1</engg-code><engg-name>PE1 Name</engg-name><tier-code>MEMBER</tier-code><effective-tier-code>PERSONTIER1</effective-tier-code><engg-status-code>ENGSTSAPRD</engg-status-code><engg-status-dtm isnull-indicator="N">08/16/2016 06:12:55 PM</engg-status-dtm></engagement><engagement inact-indicator="N" engg-cat-code="ENGCATCD16" engg-type-code="ENGTYPSOFT"><engg-code>PE2</engg-code><engg-name>PE2 Name</engg-name><tier-code>MEMBER</tier-code><effective-tier-code>PERSONTIER2</effective-tier-code><engg-status-code>ENGSTSAPRD</engg-status-code><engg-status-dtm isnull-indicator="N">08/16/2016 06:12:55 PM</engg-status-dtm></engagement></person-engagements>',
                          '<person-engagements><engagement inact-indicator="N" engg-cat-code="ENGCATCD16" engg-type-code="ENGTYPSOFT"><engg-code>PE1</engg-code><engg-name>PE1 Name</engg-name><tier-code>MEMBER</tier-code><effective-tier-code>PERSONTIER2</effective-tier-code><engg-status-code>ENGSTSAPRD</engg-status-code><engg-status-dtm isnull-indicator="N">08/16/2016 06:12:55 PM</engg-status-dtm></engagement><engagement inact-indicator="N" engg-cat-code="ENGCATCD16" engg-type-code="ENGTYPSOFT"><engg-code>PE3</engg-code><engg-name>PE3 Name</engg-name><tier-code>MEMBER</tier-code><effective-tier-code>PERSONTIER3</effective-tier-code><engg-status-code>ENGSTSAPRD</engg-status-code><engg-status-dtm isnull-indicator="N">08/16/2016 06:12:55 PM</engg-status-dtm></engagement></person-engagements>');
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        Contact c = [select Id from Contact where Core_eRPM_Person_Id__c = '3000000' limit 1];
        
        List<Core_Contact_Entitlement__c> ceList = [
            select Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c,
            Core_Selected__c, Core_From_Source__c, Core_Engagement_Tier__c, Core_Entitlement_Id__r.Name
            from Core_Contact_Entitlement__c
            where Core_Contact_Id__c = :c.Id
            order by Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c];
        
        // Original expected state = AE1: true, AE2: false, AE3: true, PE1: true, PE2-1: false, PE2-2: false, PE2-0: false, PE3: true
        // After first big change per Jordan, expected state = AE1: false, AE2: false, AE3: true, PE1: true, PE2-1: false, PE2-2: false, PE2-0: false, PE3: true
        // After Phoenix Go-Live with changes per Thirumala = AE1: true, AE2: true, AE3: true, PE1: true, PE2-1: false, PE2-2: true, PE2-0: true, PE3: true
        // Final (hopefully) logic with removals added back = AE1: false, AE2: false, AE3: true, PE1: true, PE2-1: false, PE2-2: true, PE2-0: false, PE3: true
        // 
        // Note: originally, this was coded so ERPM engagement removal would only remove the entitlements with blank AGS roles.
        // Then, based on discussion with Jordan, ERPM engagement removal results in removal of all related entitlements.
        // 
        // DH 4/17/17: After Phoenix Go-Live (discussion with Thirumala, Subbaro, Troy A), the logic was changed yet again
        // so nothing ever gets removed based on the ERPM message (engagements or entitlements).
        // 
        // DH 5/4/17: Since we addressed other issues (out-of-order messages), removal of engagements (but not entitlements) was added back in.
        
        System.assertEquals('AE3', ceList[0].Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
        System.assertEquals(true, ceList[0].Core_Selected__c);
        //System.assertEquals('ACCTTIER2', ceList[0].Core_Engagement_Tier__c);
        /*
System.assertEquals('AE2', ceList[1].Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
System.assertEquals(false, ceList[1].Core_Selected__c);

System.assertEquals('AE3', ceList[2].Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
System.assertEquals(true, ceList[2].Core_Selected__c);
System.assertEquals(true, ceList[2].Core_From_Source__c);

System.assertEquals('PE1', ceList[3].Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
System.assertEquals(true, ceList[3].Core_Selected__c);

System.assertEquals('PE2', ceList[4].Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
System.assertEquals('Person Engg 2 AGS Role 1', ceList[4].Core_Entitlement_Id__r.Name);
System.assertEquals(false, ceList[4].Core_Selected__c);

System.assertEquals('PE2', ceList[5].Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
System.assertEquals('Person Engg 2 AGS Role 2', ceList[5].Core_Entitlement_Id__r.Name);
System.assertEquals(true, ceList[5].Core_Selected__c);

System.assertEquals('PE2', ceList[6].Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
System.assertEquals('Person Engg 2 No Role', ceList[6].Core_Entitlement_Id__r.Name);
System.assertEquals(false, ceList[6].Core_Selected__c);
System.assertEquals(true, ceList[6].Core_From_Source__c);

System.assertEquals('PE3', ceList[7].Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
System.assertEquals(true, ceList[7].Core_Selected__c);
System.assertEquals(true, ceList[7].Core_From_Source__c);*/
    }
    
    // 1.4 Contact match. Update Person & Account Engagements where 2 need to be added to DB.
    static testMethod void testERPMPersonMessage_1_4_UpdateEnggsAddToDB() {
        
        System.debug('***** Test 1.4');
        
        String msg = basicERPMPersonMessageXml();
        
        // AE4 added
        msg = msg.replace('<account-engagements><engagement><engg-code>AE1</engg-code><eff-tier-cd>ACCTTIER1</eff-tier-cd><engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm></engagement><engagement><engg-code>AE2</engg-code><eff-tier-cd>ACCTTIER2</eff-tier-cd><engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm></engagement></account-engagements>',
                          '<account-engagements><engagement><engg-code>AE1</engg-code><eff-tier-cd>ACCTTIER2</eff-tier-cd><engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm></engagement><engagement><engg-code>AE4</engg-code><eff-tier-cd>ACCTTIER4</eff-tier-cd><engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm></engagement></account-engagements>');
        msg = msg.replace('<person-account-relation inact-indicator="N" engagement-code="AE1"><relation-code>RELTNTRNFR</relation-code><relation-name>Trainee</relation-name><effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm></person-account-relation>',
                          '<person-account-relation inact-indicator="N" engagement-code="AE4"><relation-code>RELTNTRNFR</relation-code><relation-name>Trainee</relation-name><effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm></person-account-relation>');
        
        // PE5 added
        msg = msg.replace('<person-engagements><engagement inact-indicator="N" engg-cat-code="ENGCATCD16" engg-type-code="ENGTYPSOFT"><engg-code>PE1</engg-code><engg-name>PE1 Name</engg-name><tier-code>MEMBER</tier-code><effective-tier-code>PERSONTIER1</effective-tier-code><engg-status-code>ENGSTSAPRD</engg-status-code><engg-status-dtm isnull-indicator="N">08/16/2016 06:12:55 PM</engg-status-dtm></engagement><engagement inact-indicator="N" engg-cat-code="ENGCATCD16" engg-type-code="ENGTYPSOFT"><engg-code>PE2</engg-code><engg-name>PE2 Name</engg-name><tier-code>MEMBER</tier-code><effective-tier-code>PERSONTIER2</effective-tier-code><engg-status-code>ENGSTSAPRD</engg-status-code><engg-status-dtm isnull-indicator="N">08/16/2016 06:12:55 PM</engg-status-dtm></engagement></person-engagements>',
                          '<person-engagements><engagement inact-indicator="N" engg-cat-code="ENGCATCD16" engg-type-code="ENGTYPSOFT"><engg-code>PE1</engg-code><engg-name>PE1 Name</engg-name><tier-code>MEMBER</tier-code><effective-tier-code>PERSONTIER2</effective-tier-code><engg-status-code>ENGSTSAPRD</engg-status-code><engg-status-dtm isnull-indicator="N">08/16/2016 06:12:55 PM</engg-status-dtm></engagement><engagement inact-indicator="N" engg-cat-code="ENGCATCD16" engg-type-code="ENGTYPSOFT"><engg-code>PE5</engg-code><engg-name>PE5 Name</engg-name><tier-code>MEMBER</tier-code><effective-tier-code>PERSONTIER3</effective-tier-code><engg-status-code>ENGSTSAPRD</engg-status-code><engg-status-dtm isnull-indicator="N">08/16/2016 06:12:55 PM</engg-status-dtm></engagement></person-engagements>');
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        Contact c = [select Id from Contact where Core_eRPM_Person_Id__c = '3000000' limit 1];
        
        List<Core_Contact_Entitlement__c> ceList = [
            select Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c,
            Core_Selected__c, Core_From_Source__c, Core_Entitlement_Id__c, Core_Entitlement_Id__r.Name
            from Core_Contact_Entitlement__c
            where Core_Contact_Id__c = :c.Id
            and Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c in ('AE4', 'PE5')
            order by Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c];
        
        System.assertEquals('AE4', ceList[0].Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
        System.assertEquals(true, ceList[0].Core_Selected__c);
        System.assertEquals(true, ceList[0].Core_From_Source__c);
        
        System.assertEquals('PE5', ceList[1].Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
        System.assertEquals(true, ceList[1].Core_Selected__c);
        System.assertEquals(true, ceList[1].Core_From_Source__c);
        
        List<Core_Entitlement__c> entList = [select Name, Core_IsActive__c, Core_ERPM_Engagement_Id__c, Core_AGS_Role_Id__c
                                             from Core_Entitlement__c
                                             where Id = :ceList[0].Core_Entitlement_Id__c
                                             or Id = :ceList[1].Core_Entitlement_Id__c
                                             order by Name];
        
        System.assertEquals('AE4', entList[0].Name);
        System.assertEquals(false, entList[0].Core_IsActive__c);
        System.assertEquals(null, entList[0].Core_AGS_Role_Id__c);
        
        System.assertEquals('PE5 Name', entList[1].Name);
        System.assertEquals(false, entList[1].Core_IsActive__c);
        System.assertEquals(null, entList[1].Core_AGS_Role_Id__c);
        
        List<Core_ERPM_Engagement__c> enggList = [select Core_IsActive__c, Core_Technical_Engagement_Code__c
                                                  from Core_ERPM_Engagement__c
                                                  where Id = :entList[0].Core_ERPM_Engagement_Id__c
                                                  or Id = :entList[1].Core_ERPM_Engagement_Id__c
                                                  order by Core_Technical_Engagement_Code__c];
        
        System.assertEquals('AE4', enggList[0].Core_Technical_Engagement_Code__c);
        System.assertEquals(false, enggList[0].Core_IsActive__c);
        
        System.assertEquals('PE5', enggList[1].Core_Technical_Engagement_Code__c);
        System.assertEquals(false, enggList[1].Core_IsActive__c);
    }
    
    // 1.5 Contact match. Account has changed, and it's not a B2B Account. Update Account.
    /*static testMethod void testERPMPersonMessage_1_5_UpdateAccount() {

String msg = TEST_ERPM_PERSON_XML;
msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000020');
msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test2');
msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000101020');
msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
msg = msg.replace('REPLACE_PERSON_TITLE',              'Dr');
msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName2');
msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName2');
msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact2@acct0.com');
msg = msg.replace('REPLACE_PERSON_PHONE',              '1001002001');
msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001002001');
msg = msg.replace('REPLACE_PERSON_FAX',                '3001002001');
msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1003');
msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 3');
msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'AE1');
msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE2', 'AE2');
msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE1',  'PE1');
msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME1',  'PE1 Name');
msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE2',  'PE2');
msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME2',  'PE2 Name');

System.debug('##### msg = ' + msg);

Test.startTest();
insert newERPMPersonMessage(msg);
Test.stopTest();

Account a = [select Id from Account where Core_CIM_ID__c = '1003' limit 1];

Contact c = [select Id, AccountId from Contact where Core_eRPM_Person_Id__c = '3000020' limit 1];

System.debug('##### c = ' + c);

System.assertEquals(a.Id, c.AccountId);
}*/
    
    // 1.6 Contact match. Account has changed, but it's a B2B Account. Don't update Account.
    // Note: after discussion with Gulshan, now we're NEVER updating accounts, so this isn't as relevant.
    static testMethod void testERPMPersonMessage_1_6_DontUpdateAccount() {
        
        System.debug('***** Test 1.6');
        
        String msg = TEST_ERPM_PERSON_XML;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000000');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test0');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000101000');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'Dr');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName0');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName0');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact0@acct0.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1001');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 1');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'AE1');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE2', 'AE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE1',  'PE1');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME1',  'PE1 Name');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE2',  'PE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME2',  'PE2 Name');
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        Account a = [select Id from Account where Core_CIM_ID__c = '1001' limit 1];
        
        Contact c = [select Id, AccountId from Contact where Core_eRPM_Person_Id__c = '3000000' limit 1];
        
        System.debug('##### c = ' + c);
        
        System.assertNotEquals(a.Id, c.AccountId);
    }
    
    // 1.7.1 ERPM Delete scenario.
    static testMethod void testERPMPersonMessage_1_7_1_Delete() {
        
        System.debug('***** Test 1.7.1');
        
        Contact c = [select Id, Core_eRPM_Person_Id__c, Core_Enterprise_ID__c, Core_Login_Id__c, Core_Login_Status__c, Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c
                     from Contact where Core_eRPM_Person_Id__c = '3000000' limit 1];
        
        System.debug('##### c = ' + c);
        
        // Make sure our contact has values in these fields, and entitlements
        System.assertNotEquals(null, c.Core_Enterprise_ID__c);
        System.assertNotEquals(null, c.Core_Login_Id__c);
        System.assertNotEquals(0, [select count() from Core_Contact_Entitlement__c where Core_Contact_Id__c = :c.Id and Core_Selected__c = true]);
        
        String msg = TEST_ERPM_PERSON_DELETE_XML;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','Y');
        msg = msg.replace('REPLACE_PERSON_INACT_INDICATOR',    'N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000000');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000001000');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test0');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact0@acct0.com');
        
        System.debug('ERPM_Outbound_Inegration  :  Core_ERPM_Integration_Queue_txt__c - ' +c.Core_ERPM_Integration_Queue_txt__c);
        System.debug('ERPM_Outbound_Inegration  :  Core_ERPM_Integration_Status__c - ' +c.Core_ERPM_Integration_Status__c);
        
        // adding this line as part of trigger logic (In-Pgrogress status)
        c.Core_ERPM_Integration_Status__c = 'Successful';
        update c;
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        c = [select Id, Core_eRPM_Person_Id__c, Core_Enterprise_ID__c, Core_Login_Id__c, Core_Login_Status__c,
             FirstName, LastName, Email, Phone, MobilePhone
             from Contact where Core_eRPM_Person_Id__c = '3000000' limit 1];
        
        System.debug('##### c = ' + c);
        
        // Make sure our contact has these values nulled out, and no entitlements
        // System.assertEquals(null, c.Core_Enterprise_ID__c);
        //System.assertEquals(null, c.Core_Login_Id__c);
        // System.assertEquals('Deleted', c.Core_Login_Status__c);
        //System.assertEquals(0, [select count() from Core_Contact_Entitlement__c where Core_Contact_Id__c = :c.Id and Core_Selected__c = true]);
        
        // For US61328, make sure it's been "tokenized"
        // NOTE: commented out after the Phoenix release since this was causing issues; will probably add it back in later
        //System.assertEquals('?????', c.FirstName);
        //System.assertEquals('?????', c.LastName);
        //System.assertEquals('?????', c.Email.left(5));
        //System.assert(String.isBlank(c.Phone));
        //System.assert(String.isBlank(c.MobilePhone));
    }
    
    // 1.7.2 ERPM Disabled scenario.
    static testMethod void testERPMPersonMessage_1_7_2_Disabled() {
        
        System.debug('***** Test 1.7.2');
        
        Contact c = [select Id, Core_eRPM_Person_Id__c, Core_Enterprise_ID__c, Core_Login_Id__c, Core_Login_Status__c
                     from Contact where Core_eRPM_Person_Id__c = '3000000' limit 1];
        
        System.debug('##### c = ' + c);
        
        // Make sure our contact has values in these fields, and entitlements
        System.assertNotEquals(null, c.Core_Enterprise_ID__c);
        System.assertNotEquals(null, c.Core_Login_Id__c);
        System.assertNotEquals(0, [select count() from Core_Contact_Entitlement__c where Core_Contact_Id__c = :c.Id and Core_Selected__c = true]);
        
        String msg = TEST_ERPM_PERSON_DELETE_XML;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_INACT_INDICATOR',    'Y');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000000');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000001000');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test0');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact0@acct0.com');
        
        // adding this line as part of trigger logic (In-Pgrogress status)
        c.Core_ERPM_Integration_Status__c = 'Successful';
        update c;
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        c = [select Id, Core_eRPM_Person_Id__c, Core_Enterprise_ID__c, Core_Login_Id__c, Core_Login_Status__c
             from Contact where Core_eRPM_Person_Id__c = '3000000' limit 1];
        
        System.debug('##### c = ' + c);
        
        // Make sure our contact has these values nulled out, and no entitlements
        System.assertEquals(null, c.Core_Login_Status__c);
    }
    
    // 1.7.3 ERPM Soft delete scenario.
    static testMethod void testERPMPersonMessage_1_7_3_SoftDelete() {
        
        System.debug('***** Test 1.7.3');
        
        Contact c = [select Id, Core_eRPM_Person_Id__c, Core_Enterprise_ID__c, Core_Login_Id__c, Core_Login_Status__c
                     from Contact where Core_eRPM_Person_Id__c = '3000000' limit 1];
        
        System.debug('##### c = ' + c);
        
        // Make sure our contact has values in these fields, and entitlements
        System.assertNotEquals(null, c.Core_Enterprise_ID__c);
        System.assertNotEquals(null, c.Core_Login_Id__c);
        System.assertNotEquals(0, [select count() from Core_Contact_Entitlement__c where Core_Contact_Id__c = :c.Id and Core_Selected__c = true]);
        
        String msg = TEST_ERPM_PERSON_DELETE_XML;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_INACT_INDICATOR',    'N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000000');
        msg = msg.replace('<enterprise-id isnull-indicator="N">REPLACE_PERSON_ENTERPRISE_ID</enterprise-id>', '<enterprise-id isnull-indicator="Y"/>');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test0');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact0@acct0.com');
        
        // adding this line as part of trigger logic (In-Pgrogress status)
        c.Core_ERPM_Integration_Status__c = 'Successful';
        update c;
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        c = [select Id, Core_eRPM_Person_Id__c, Core_Enterprise_ID__c, Core_Login_Id__c, Core_Login_Status__c
             from Contact where Core_eRPM_Person_Id__c = '3000000' limit 1];
        
        System.debug('##### c = ' + c);
        
        // Make sure our contact has these values nulled out, and no entitlements
        // System.assertEquals(null, c.Core_Enterprise_ID__c);
        System.assertEquals('test0', c.Core_Login_Id__c);
        //System.assertEquals('Deleted', c.Core_Login_Status__c);
        //System.assertEquals(0, [select count() from Core_Contact_Entitlement__c where Core_Contact_Id__c = :c.Id and Core_Selected__c = true]);
    }
    
    // 1.8 Message has email address that contains ".duplicate". Ignore the message even if there's a matching contact record.
    static testMethod void testERPMPersonMessage_1_8_EmailWithDuplicate() {
        
        System.debug('***** Test 1.8');
        
        String msg = TEST_ERPM_PERSON_XML;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000000');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test0_new');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000001001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'Dr');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName0_New');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName0_New');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact0.duplicate23@acct0.com'); // Include ".duplicate", before the @ sign
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1000');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 0');
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        // Make sure there wasn't an account created or anything updated based on the message
        List<Contact> contacts = [select Id, Core_eRPM_Person_Id__c, Core_Enterprise_Id__c, LastName
                                  from Contact where Core_eRPM_Person_Id__c = '3000000' or Email like 'testcontact0.duplicate23@acct0.com'];
        System.assertEquals(1, contacts.size());
        //System.assertNotEquals('1000001001', contacts[0].Core_Enterprise_Id__c);
        System.assertNotEquals('LName0_New', contacts[0].LastName);
    }
    
    // 2.1 No Contact match, but Account match on CIM ID. Create Contact and associate with Account.
    static testMethod void testERPMPersonMessage_2_1_CreateContact() {
        
        System.debug('***** Test 2.1');
        
        String msg = TEST_ERPM_PERSON_XML;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3001000');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test7');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000101000');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'Dr');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName7');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName7');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact7@acct0.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1000');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 0');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'AE1');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE2', 'AE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE1',  'PE1');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME1',  'PE1 Name');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE2',  'PE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME2',  'PE2 Name');
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        /*
Contact c = [select Id, Core_eRPM_Person_Id__c, Core_Enterprise_ID__c, Core_Identity_Status__c, Core_Login_Id__c,
Title,Salutation,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c, FirstName, LastName, Email, Phone, MobilePhone, Fax,
MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,
Account.Name, Account.Core_CIM_ID__c
from Contact where Core_eRPM_Person_Id__c = '3001000' limit 1];

System.debug('##### c = ' + c);

System.assertEquals('test7',                       c.Core_Login_ID__c);
System.assertEquals('1000101000',                  c.Core_Enterprise_ID__c);
System.assertEquals('A',                           c.Core_Identity_Status__c);
System.assertEquals('Dr.',                          c.Salutation);
System.assertEquals('FName7',                      c.FirstName);
System.assertEquals('LName7',                      c.LastName);
System.assertEquals('testcontact7@acct0.com',      c.Email);
System.assertEquals('1001001001',                  c.Phone);
System.assertEquals('2001001001',                  c.MobilePhone);
System.assertEquals('3001001001',                  c.Fax);
//System.assertEquals('Addr 1 Addr 2 Addr 3 Addr 4', c.MailingStreet);
//System.assertEquals('Portland',                    c.MailingCity);
//System.assertEquals('OR',                          c.MailingState);
//System.assertEquals('97229',                       c.MailingPostalCode);
//System.assertEquals('USA',                         c.MailingCountry);
System.assertEquals('Test Account 0',              c.Account.Name);
System.assertEquals('1000',                        c.Account.Core_CIM_ID__c);
*/
    }
    
    // 2.2 No Contact match, and no Account match, but it's RDC self-reg. Create Account, then Contact.
    /*static testMethod void testERPMPersonMessage_2_2_CreateAcctContact() {

String msg = TEST_ERPM_PERSON_XML;
msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3001000');
msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test7');
msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000101000');
msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
msg = msg.replace('REPLACE_PERSON_TITLE',              'Dr');
msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName7');
msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName7');
msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact7@acct0.com');
msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1007');
msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 7');
msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', Core_IntegrationInboundMessageERPM.RDC_ENGAGEMENT_CODE);
msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE2', 'AE2');
msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE1',  'PE1');
msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME1',  'PE1 Name');
msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE2',  'PE2');
msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME2',  'PE2 Name');

System.debug('##### msg = ' + msg);

Test.startTest();
insert newERPMPersonMessage(msg);
Test.stopTest();

Account a = [select Id, Name, Industry, Core_Account_Type__c, Core_Sales_Group__c,
BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
from Account where Core_CIM_ID__c = '1007' limit 1];

System.debug('##### a = ' + a);

System.assertEquals('Test Account 7',              a.Name);
System.assertEquals('Addr 1 Addr 2 Addr 3 Addr 4', a.BillingStreet);
System.assertEquals('Portland',                    a.BillingCity);
System.assertEquals('OR',                          a.BillingState);
System.assertEquals('97229',                       a.BillingPostalCode);
System.assertEquals('USA',                         a.BillingCountry);
System.assertEquals(Core_IntegrationInboundMessageERPM.RDC_ACCOUNT_INDUSTRY,    a.Industry);
System.assertEquals(Core_IntegrationInboundMessageERPM.RDC_ACCOUNT_TYPE,        a.Core_Account_Type__c);
System.assertEquals(Core_IntegrationInboundMessageERPM.RDC_ACCOUNT_SALES_GROUP, a.Core_Sales_Group__c);

Contact c = [select AccountId from Contact where Core_eRPM_Person_Id__c = '3001000' limit 1];

System.debug('##### c = ' + c);

System.assertEquals(a.Id, c.AccountId);
}*/
    
    // 2.3 No Contact match, and no Account match, and not RDC self-reg. Do nothing.
    static testMethod void testERPMPersonMessage_2_3_DropMessage() {
        
        System.debug('***** Test 2.3');
        
        String msg = TEST_ERPM_PERSON_XML;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3001000');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test7');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000101000');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'Dr');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName7');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName7');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact7@acct0.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1007');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 7');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'AE1');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE2', 'AE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE1',  'PE1');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME1',  'PE1 Name');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE2',  'PE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME2',  'PE2 Name');
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        List<Contact> contacts = [select Id from Contact where Core_eRPM_Person_Id__c = '3001000' limit 1];
        
        System.assertEquals(0, contacts.size());
    }
    
    // 2.4 No Contact match, and message does not contain Account. Do nothing.
    static testMethod void testERPMPersonMessage_2_4_DropMessage() {
        
        System.debug('***** Test 2.4');
        
        String msg = TEST_ERPM_PERSON_NO_ACCOUNT_XML;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3001000');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test7');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000101000');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'Dr');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName7');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName7');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact7@acct0.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE1',  'PE1');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME1',  'PE1 Name');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE2',  'PE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME2',  'PE2 Name');
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        List<Contact> contacts = [select Id from Contact where Core_eRPM_Person_Id__c = '3001000' limit 1];
        System.assertEquals(0, contacts.size());
        
        Core_Integration_Inbound_Message__c msgAfter = [select Core_Processing_Status__c from Core_Integration_Inbound_Message__c limit 1];
        System.assertEquals('Successful', msgAfter.Core_Processing_Status__c);
        
        Core_Log_Entry__c logEntry = [select Core_Message__c from Core_Log_Entry__c where Core_Message__c like 'ignored%' limit 1];
        System.assertEquals('ignored', logEntry.Core_Message__c.toLowerCase().left(7));
    }
    
    // 3.1 ERPM soft delete. Contact match. Update Contact to blank out necessary fields and deselect Entitlements.
    /*static testMethod void testERPMPersonMessage_3_1_SoftDelete() {

System.debug('***** Test 3.1');

String msg = basicERPMPersonMessageXml();
msg = msg.replace('is-delete-indicator="N">', 'is-delete-indicator="Y">');

System.debug('##### msg = ' + msg);

Test.startTest();
insert newERPMPersonMessage(msg);
Test.stopTest();

Contact c = [select Id, Core_eRPM_Person_Id__c, Core_Enterprise_ID__c, Core_Login_Id__c, FirstName, LastName, Email
from Contact where Core_eRPM_Person_Id__c = '3000000' limit 1];

System.debug('##### c = ' + c);

System.assertEquals(null,                     c.Core_Login_Id__c);
System.assertEquals(null,                     c.Core_Enterprise_ID__c);
System.assertEquals('3000000',                c.Core_eRPM_Person_Id__c);
System.assertEquals('FName0',                 c.FirstName);
System.assertEquals('LName0',                 c.LastName);
System.assertEquals('testcontact0@acct0.com', c.Email);

List<Core_Contact_Entitlement__c> ceList = [
select Core_Selected__c from Core_Contact_Entitlement__c
where Core_Contact_Id__c = :c.Id and Core_Entitlement_Id__r.Core_AGS_Role_Id__c = ''];

System.debug('##### ceList = ' + ceList);

for (Core_Contact_Entitlement__c ce : ceList)
System.assertEquals(false, ce.Core_Selected__c);
}

// 3.2 ERPM soft delete (subsequent messages). Contact match. Update Contact to blank out necessary fields and deselect Entitlements.
static testMethod void testERPMPersonMessage_3_2_SoftDelete() {

String msg = basicERPMPersonMessageXml();
msg = msg.replace('<enterprise-id isnull-indicator="N">1000001000', '<enterprise-id isnull-indicator="N">');
msg = msg.replace('<external-login-id isnull-indicator="N">test0', '<external-login-id isnull-indicator="N">');

System.debug('##### msg = ' + msg);

Test.startTest();
insert newERPMPersonMessage(msg);
Test.stopTest();

Contact c = [select Id, Core_eRPM_Person_Id__c, Core_Login_ID__c, Core_Enterprise_ID__c
from Contact where Core_eRPM_Person_Id__c = '3000000' limit 1];

System.debug('##### c = ' + c);

System.assertEquals(null,      c.Core_Login_ID__c);
System.assertEquals(null,      c.Core_Enterprise_ID__c);
System.assertEquals('3000000', c.Core_eRPM_Person_Id__c);

List<Core_Contact_Entitlement__c> ceList = [
select Core_Selected__c from Core_Contact_Entitlement__c
where Core_Contact_Id__c = :c.Id and Core_Entitlement_Id__r.Core_AGS_Role_Id__c = ''];

System.debug('##### ceList = ' + ceList);

for (Core_Contact_Entitlement__c ce : ceList)
System.assertEquals(false, ce.Core_Selected__c);
}*/
    
    // 4.1 XML Parsing error. Should generate a "Failure" for processing status.
    static testMethod void testERPMPersonMessage_4_1_XMLParseError() {
        
        System.debug('***** Test 4.1');
        
        // Try to insert an "ERPM Person message", but make it a Blackbox message, which should throw
        // an exception since it's not even XML
        String msg = TEST_ERPM_BLACKBOX_FAILURE_JSON;
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        List<Core_Integration_Inbound_Message__c> msgs =
            [select Core_Processing_Status__c from Core_Integration_Inbound_Message__c];
        
        System.assertEquals(1, msgs.size());
        System.assertEquals('Failed', msgs[0].Core_Processing_Status__c);
    }
    
    // 4.2 Bogus message sent. Should generate a "Failure" for processing status.
    static testMethod void testERPMPersonMessage_4_2_BogusMessage() {
        
        System.debug('***** Test 4.2');
        
        // Try to insert an "ERPM Person message", but make it a Blackbox message, surrounded by XML,
        // which hits a different exception path in real-world testing
        String msg = '<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ' +
            'xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <soapenv:Body> ' +
            '<notifications xmlns="http://soap.sforce.com/2005/09/outbound"> <OrganizationId>00Dg0000006HgSZEA0</OrganizationId> ' +
            '<ActionId>04kq00000000058AAA</ActionId> <SessionId xsi:nil="true"/> ' +
            '<EnterpriseUrl>https://cs21.salesforce.com/services/Soap/c/32.0/00Dq00000009GvZ</EnterpriseUrl> ' +
            '<PartnerUrl>https://cs21.salesforce.com/services/Soap/u/32.0/00Dq00000009GvZ</PartnerUrl> <Notification> ' +
            '<Id>04lq0000000KR3lAAG</Id> <sObject xmlns:sf="urn:sobject.enterprise.soap.sforce.com" xsi:type="Contact_thing"> ' +
            '<Id>a0Aq0000000LV3HEAW</Id> <Core_MessageType__c>ContactRole</Core_MessageType__c> <Core_Payload__c>' +
            TEST_ERPM_BLACKBOX_FAILURE_JSON +
            '</Core_Payload__c> </sObject> </Notification> </notifications> </soapenv:Body> </soapenv:Envelope>';
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        List<Core_Integration_Inbound_Message__c> msgs =
            [select Core_Processing_Status__c from Core_Integration_Inbound_Message__c];
        
        System.assertEquals(1, msgs.size());
        System.assertEquals('Failed', msgs[0].Core_Processing_Status__c);
        
        // Make sure a log entry was created and it's linked to from the inbound message
        List<Core_Log_Entry__c> logEntries = [select Core_Severity__c from Core_Log_Entry__c
                                              where Core_Origin__c = :Core_IntegrationInboundMessageERPM.LOG_ENTRY_ORIGIN
                                              and Core_Project__c = :Core_IntegrationInboundMessageERPM.LOG_ENTRY_PROJECT
                                              and Core_Scope__c = :Core_IntegrationInboundMessageERPM.LOG_ENTRY_SCOPE
                                              order by Id desc];
        System.assert(logEntries.size() >= 1);
        System.assertEquals(Core_IntegrationInboundMessageERPM.LOG_ENTRY_ERROR, logEntries[0].Core_Severity__c);
        System.assertEquals(logEntries[0].Id, [select Core_Log_Entry__c from Core_Integration_Inbound_Message__c limit 1][0].Core_Log_Entry__c);
    }
    
    // 5.1 Bulk messages. Check to make sure bulkification is working, loading records from a static resource.
    /*static testMethod void testERPMPersonBulkMessages() {

System.debug('***** Test 5.1');

Test.startTest();
Test.loadData(Core_Integration_Inbound_Message__c.sObjectType, 'Core_IntegrationInboundMessageSamples');
Test.stopTest();
}*/
    
    // Return XML for a "basic ERPM Person Message" with Contact 0 info
    static String basicERPMPersonMessageXml() {
        String msg = TEST_ERPM_PERSON_XML;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000000');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test0');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000001000');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'Mr');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName0');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName0');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact0@acct0.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001000');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001000');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001000');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Test Address 0');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         '');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         '');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         '');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Vancouver');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'BC');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '10000');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'CAN');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1000');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 0');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'AE1');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE2', 'AE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE1',  'PE1');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME1',  'PE1 Name');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE2',  'PE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME2',  'PE2 Name');
        return msg;
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
        System.assertEquals('ISA', acctERPMEnggs[2].Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
        System.assertEquals(4, acctERPMEnggs.size());
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
        System.assertEquals('ISA', acctERPMEnggs[2].Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
        System.assertEquals(4, acctERPMEnggs.size());
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
        
        System.assertEquals(0, accts.size());
        //System.assertEquals('COMPUTER CONTACT', accts[0].Name);
        
        List<Core_Account_ERPM_Engagement__c> acctERPMEnggs = [
            select Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c
            from Core_Account_ERPM_Engagement__c
            where Core_Account_Id__r.Core_CIM_ID__c = '1010'
            order by Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c];
        
        //System.assertEquals(2, acctERPMEnggs.size());
        //System.assertEquals('AE2', acctERPMEnggs[0].Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
        System.assertEquals(0,acctERPMEnggs.size());
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
        System.debug('Raj'+ib);            
        Test.stopTest();         
        System.assertnotEquals(null,ib.id); 
        Core_Integration_Inbound_Message__c inboundMsg = [
            select Core_Processing_Status__c from Core_Integration_Inbound_Message__c where id = :ib.id limit 1];        
        System.assertEquals('Successful',inboundMsg.Core_Processing_Status__c);
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
    
    
    
    private static final String TEST_ERPM_PERSON_XML2 = +
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
    
    private static final String TEST_ERPM_PERSON_XML = '<?xml version="1.0" encoding="UTF-8"?>' +
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
        '<relation-code>RELTNTRNFR</relation-code>' +
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
        '<engagement>' +
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
        '</person-electronic-address>' +
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
    
    private static final String TEST_ERPM_PERSON_NO_ACCOUNT_XML = '<?xml version="1.0" encoding="UTF-8"?>' +
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
        '<person-accounts />' +
        '<person-electronic-addresses>' +
        '<person-electronic-address electronic-addr-type-code="FAX" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_FAX</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_MOBILE</electronic-address>' +
        '</person-electronic-address>' +
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
        '<publish-timestamp>01/01/2029 12:00:01 AM</publish-timestamp>' +
        '</person>';
    
    private static final String TEST_ERPM_PERSON_DELETE_XML =
        '<person xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" inact-indicator="REPLACE_PERSON_INACT_INDICATOR" is-delete-indicator="REPLACE_PERSON_IS_DELETE_INDICATOR">' +
        '<changed-attributes />' +
        '<person-information>' +
        '<person-id>REPLACE_PERSON_ERPM_PERSON_ID</person-id>' +
        '<external-login-id isnull-indicator="N">REPLACE_PERSON_EXTERNAL_LOGIN</external-login-id>' +
        '<enterprise-id isnull-indicator="N">REPLACE_PERSON_ENTERPRISE_ID</enterprise-id>' +
        '<internal-login-id isnull-indicator="Y" />' +
        '<primary-email-address>REPLACE_PERSON_EMAIL</primary-email-address>' +
        '</person-information>' +
        '<person-accounts />' +
        '<person-electronic-addresses />' +
        '<person-engagements />' +
        '<person-attributes />' +
        '<person-external-systems />' +
        '<person-interests />' +
        '<person-physical-addresses />' +
        '<person-subscription />' +
        '<person-preferences />' +
        '<change-agt-id>RIALTO</change-agt-id>' +
        '<publish-timestamp>01/01/2029 12:00:01 AM</publish-timestamp>' +
        '</person>';
    
    private static final String TEST_ERPM_PERSON_SAMPLE_XML =
        '<?xml version="1.0" encoding="UTF-8"?>' +
        '<person xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" inact-indicator="N" is-delete-indicator="N">' +
        '<changed-attributes>' +
        '<person-information xsi:type="xsd:string" />' +
        '<person-accounts xsi:type="xsd:string" />' +
        '<person-engagements xsi:type="xsd:string" />' +
        '<person-attributes xsi:type="xsd:string" />' +
        '<person-external-systems xsi:type="xsd:string" />' +
        '<person-physical-addresses xsi:type="xsd:string" />' +
        '</changed-attributes>' +
        '<person-information>' +
        '<person-id>3087464</person-id>' +
        '<external-login-id isnull-indicator="N">mayala@sistemaysistema.com.ec</external-login-id>' +
        '<enterprise-id isnull-indicator="N">300000597557</enterprise-id>' +
        '<internal-login-id isnull-indicator="Y" />' +
        '<identity-status isnull-indicator="N">A</identity-status>' +
        '<person-title isnull-indicator="Y" />' +
        '<person-given-name isnull-indicator="N">Marlon</person-given-name>' +
        '<person-middle-name isnull-indicator="Y" />' +
        '<person-family-name isnull-indicator="N">Mayala</person-family-name>' +
        '<family-name-suffix-code isnull-indicator="Y" />' +
        '<person-english-given-name isnull-indicator="N">Marlon</person-english-given-name>' +
        '<person-english-family-name isnull-indicator="N">Mayala</person-english-family-name>' +
        '<person-alternate-name isnull-indicator="Y" />' +
        '<person-registration-type>INTEL</person-registration-type>' +
        '<language-code>ENG</language-code>' +
        '<email-valid-status-code>N</email-valid-status-code>' +
        '<occupation-title-code isnull-indicator="N">OPER</occupation-title-code>' +
        '<occupation-title isnull-indicator="N">Operations</occupation-title>' +
        '<primary-email-address>mayala@sistemaysistema.com.ec</primary-email-address>' +
        '<timezone-code isnull-indicator="Y" />' +
        '<all-intel-no-contact-dtm isnull-indicator="Y" />' +
        '<all-intel-remove-dtm isnull-indicator="Y" />' +
        '<email-valid-status-dtm isnull-indicator="Y" />' +
        '<first-contact-dtm isnull-indicator="Y" />' +
        '<effective-start-dtm isnull-indicator="Y" />' +
        '<effective-end-dtm isnull-indicator="Y" />' +
        '<last-login-dtm isnull-indicator="Y" />' +
        '<person-create-dtm isnull-indicator="Y" />' +
        '</person-information>' +
        '<person-accounts>' +
        '<person-account inact-indicator="Y">' +
        '<account-number>10450334</account-number>' +
        '<effective-start-dtm>08/16/2016 06:12:43 PM</effective-start-dtm>' +
        '<effective-end-date isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-date>' +
        '<cim-id isnull-indicator="N">11154430</cim-id>' +
        '<account-name>Sistemas y Servicios Erazo Cia. Ltda.</account-name>' +
        '<busn_grp_cd>BIZGRPCHNL</busn_grp_cd>' +
        '<prim_addr_type>MAIL</prim_addr_type>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGPITP</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="Y" engagement-code="ITP">' +
        '<relation-code>RELTNTRNFR</relation-code>' +
        '<relation-name>Trainee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<person-account-relation inact-indicator="N" engagement-code="ITP">' +
        '<relation-code>RELTNWSCTC</relation-code>' +
        '<relation-name>Warranty and Support Contact</relation-name>' +
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
        '<effective-start-dtm>08/16/2016 06:12:56 PM</effective-start-dtm>' +
        '<effective-end-date isnull-indicator="Y" />' +
        '<cim-id isnull-indicator="N">11154430</cim-id>' +
        '<account-name>SISTEMAS Y SERVICIOS ERAZO CA</account-name>' +
        '<busn_grp_cd>BIZGRPSMGP</busn_grp_cd>' +
        '<prim_addr_type>MAIL</prim_addr_type>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGPSCD</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="ITP">' +
        '<relation-code>RELTNWSCTC</relation-code>' +
        '<relation-name>Warranty and Support Contact</relation-name>' +
        '<effective-end-dtm isnull-indicator="Y" />' +
        '</person-account-relation>' +
        '<account-engagements>' +
        '<engagement>' +
        '<engg-code>ISvC_Auth_Cntct</engg-code>' +
        '<eff-tier-cd>MEMBER</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' +
        '</account-engagements>' +
        '</person-account>' +
        '</person-accounts>' +
        '<person-electronic-addresses>' +
        '<person-electronic-address electronic-addr-type-code="FAX" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="Y" />' +
        '<person-electronic-address electronic-addr-type-code="IMODE" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="Y" />' +
        '<person-electronic-address electronic-addr-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="Y" />' +
        '<person-electronic-address electronic-addr-type-code="PAGER" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="Y" />' +
        '<person-electronic-address electronic-addr-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="Y" />' +
        '<person-electronic-address electronic-addr-type-code="URL" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="Y" />' +
        '</person-electronic-addresses>' +
        '<person-engagements>' +
        '<engagement inact-indicator="N" engg-cat-code="ENGCATCD16" engg-type-code="ENGTYPSOFT">' +
        '<engg-code>ISvC_Consumer</engg-code>' +
        '<engg-name>Intel Customer Support Consumer</engg-name>' +
        '<tier-code>MEMBER</tier-code>' +
        '<effective-tier-code>MEMBER</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
        '<engg-status-dtm isnull-indicator="N">08/16/2016 06:12:55 PM</engg-status-dtm>' +
        '<engg-status-reason-code isnull-indicator="Y" />' +
        '<comments isnull-indicator="Y" />' +
        '<effective-end-dtm isnull-indicator="Y" />' +
        '<engg-renewal-status-code isnull-indicator="Y" />' +
        '<engg-renewal-status-dtm isnull-indicator="Y" />' +
        '<engg-last-renewal-status-dtm isnull-indicator="Y" />' +
        '<engg-renewal-due-dtm isnull-indicator="Y" />' +
        '<engg-renewal-status-note isnull-indicator="Y" />' +
        '</engagement>' +
        '</person-engagements>' +
        '<person-responses />' +
        '<person-attributes>' +
        '<attribute>' +
        '<promo-code isnull-indicator="Y" />' +
        '<lead-source isnull-indicator="Y" />' +
        '</attribute>' +
        '</person-attributes>' +
        '<person-external-systems>' +
        '<person-external-system system-name="ProfileID">17760809</person-external-system>' +
        '</person-external-systems>' +
        '<person-interests />' +
        '<person-physical-addresses>' +
        '<physical-address location-type-code="HOME" address-usg-type-code="MAIL" contact-indicator="Y" inact-indicator="N" preferred-indicator="Y" isnull-indicator="">' +
        '<address-line1-text isnull-indicator="Y" />' +
        '<address-line2-text isnull-indicator="Y" />' +
        '<address-line3-text isnull-indicator="Y" />' +
        '<address-line4-text isnull-indicator="N" />' +
        '<effective-start-dtm>08/16/2016 10:13:06 AM</effective-start-dtm>' +
        '<city-name isnull-indicator="Y" />' +
        '<state-code isnull-indicator="Y" />' +
        '<state-name isnull-indicator="Y" />' +
        '<postal-code isnull-indicator="Y" />' +
        '<country-code>EC</country-code>' +
        '<country-name isnull-indicator="N">Ecuador</country-name>' +
        '<language-code isnull-indicator="N">ENG</language-code>' +
        '<iso-country-code>ECU</iso-country-code>' +
        '<effective-end-dtm isnull-indicator="Y" />' +
        '</physical-address>' +
        '<physical-address location-type-code="BUS" address-usg-type-code="PHY" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '</person-physical-addresses>' +
        '<person-subscription opt-in-date="" sent-date="" opt-in-confirmation-date="" />' +
        '<person-preferences />' +
        '<change-agt-id>EOT</change-agt-id>' +
        '<publish-timestamp>01/01/2029 12:00:01 AM</publish-timestamp>' +
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