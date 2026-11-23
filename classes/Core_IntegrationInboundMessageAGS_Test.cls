@isTest
    private class Core_IntegrationInboundMessageAGS_Test {
        
        private static final String TEST_ENTERPRISE_ID = '1000001000';  
        private static final String TEST_ENTERPRISE2_ID = '300000062481'; 
        private static final String TEST_EMAIL_ID = 'testcontact0@acct0.com'; 
        private static final String TEST_EMAIL2_ID = 'testprocessing@agsresponse.com';
        
        //--------------------------------------------------------------------------------------------------
        // TEST SETUP AND UTILITY METHODS
        
        @testSetup 
        static void setupTestData() {
            Core_IntegrationTestUtility.setupAcctContactEntitlementTestData(false);
        }
        
        static Core_Integration_Inbound_Message__c newMessage(String sourceSystem, String messageType, String payload) {
            return new Core_Integration_Inbound_Message__c(Core_Source_System__c = sourceSystem,
                                                           Core_Message_Type__c = messageType, Core_Processing_Status__c = 'Pending', Core_Payload__c = payload);
        }
        
        static Core_Integration_Inbound_Message__c newAGSResponseMessage(String payload) {
            return newMessage('AGS', 'Role', payload);
        }
        static Core_Integration_Inbound_Message__c newAGSResponseMessage1(String payload) {
            return newMessage('AGS', 'Role 2.0', payload);
        }
        
        static Core_Integration_Inbound_Message__c newAGSPersonMessageSplit() {     
            return new Core_Integration_Inbound_Message__c(Core_Source_System__c = 'AGS',
                                                           Core_Message_Type__c = 'Role', Core_Processing_Status__c = 'Pending', Core_Payload__c = TEST_AGS_RESPONSE_SUCCESS_JSON1, Core_Payload1__c = TEST_AGS_RESPONSE_SUCCESS_JSON2,Core_Payload2__c = TEST_AGS_RESPONSE_SUCCESS_JSON3,Core_Payload3__c = TEST_AGS_RESPONSE_SUCCESS_JSON4);
        }  
        static Core_Integration_Inbound_Message__c newAGS2PersonMessageSplit() {     
            return new Core_Integration_Inbound_Message__c(Core_Source_System__c = 'AGS',
                                                           Core_Message_Type__c = 'Role 2.0', Core_Processing_Status__c = 'Pending', Core_Payload__c = TEST_AGS_RESPONSE2_SUCCESS_JSON1, Core_Payload1__c = TEST_AGS_RESPONSE2_SUCCESS_JSON2,Core_Payload2__c = TEST_AGS_RESPONSE2_SUCCESS_JSON3,Core_Payload3__c = TEST_AGS_RESPONSE2_SUCCESS_JSON4);
        }  
        //--------------------------------------------------------------------------------------------------
        // AGS RESPONSE MESSAGE TESTS
         // 
        // 1.1 Test AGS Response message with only Successes, where there's a match on Enterprise ID 
        // 2.1 Test AGS Response message with some Successes, some Failures, where there's a match on Enterprise ID
        // 2.2 Test AGS Response message with some Successes, some Failures, where there's NO match on Enterprise ID
        // 3.1 Test invalid JSON
        // 3.2 Test blank Enterprise ID
        // 4.1 Test AGS Response message with role removal Success, where the Contact Entitlement also needs to be removed
        
        // 1.1 Test AGS Response message with only Successes, where there's a match on Enterprise ID
        static testMethod void testAGSResponseMessage_1_1_SuccessMatch() {
            
            Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c,Core_Enterprise_Id__c
                                   from Contact where Core_Enterprise_Id__c = :TEST_ENTERPRISE_ID limit 1];
           
            //System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            String msg = TEST_AGS_RESPONSE_SUCCESS_JSON;
            msg = msg.replace('REPLACE_AGS_ENTERPRISE_ID', TEST_ENTERPRISE_ID);
            
            Test.startTest();
            insert newAGSResponseMessage(msg);
            Test.stopTest();
            
            testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                           from Contact where Core_Enterprise_Id__c = :TEST_ENTERPRISE_ID limit 1];
          
            //System.assertEquals('Successful', testContact.Core_AGS_Integration_Status__c);
            //System.assert((testContact.Core_AGS_Integration_Message__c != null) &&
                          //(testContact.Core_AGS_Integration_Message__c) != 'Testing');
            
            // Make sure a log entry was created and it's linked to from the inbound message
            List<Core_Log_Entry__c> logEntries = [select Core_Severity__c from Core_Log_Entry__c
                                                  where Core_Origin__c = :Core_IntegrationInboundMessageAGS.LOG_ENTRY_ORIGIN
                                                  and Core_Project__c = :Core_IntegrationInboundMessageAGS.LOG_ENTRY_PROJECT
                                                  and Core_Scope__c = :Core_IntegrationInboundMessageAGS.LOG_ENTRY_SCOPE];
            //System.assertEquals(1, logEntries.size());
            //System.assertEquals(Core_IntegrationInboundMessageAGS.LOG_ENTRY_INFO, logEntries[0].Core_Severity__c);
           // System.assertEquals(logEntries[0].Id, [select Core_Log_Entry__c from Core_Integration_Inbound_Message__c limit 1][0].Core_Log_Entry__c);
        }
        
        // 2.1 Test AGS Response message with some Successes, some Failures, where there's a match on Enterprise ID
        static testMethod void testAGSResponseMessage_2_1_MixedMatch() {
            
            Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                                   from Contact where Core_Enterprise_Id__c = :TEST_ENTERPRISE_ID limit 1];
            
            
            //System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            String msg = TEST_AGS_RESPONSE_MIXED_JSON;
            msg = msg.replace('REPLACE_AGS_ENTERPRISE_ID', TEST_ENTERPRISE_ID);
            
            Test.startTest();
            insert newAGSResponseMessage(msg);
            Test.stopTest();
            
            testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                           from Contact where Core_Enterprise_Id__c = :TEST_ENTERPRISE_ID limit 1];
            
           // System.assertEquals('Failed', testContact.Core_AGS_Integration_Status__c);
           // System.assert((testContact.Core_AGS_Integration_Message__c != null) &&
                        //  (testContact.Core_AGS_Integration_Message__c) != 'Testing');
        }
        
        // 2.2 Test AGS Response message with some Successes, some Failures, where there's NO match on Enterprise ID
        static testMethod void testAGSResponseMessage_2_2_MixedNoMatch() {
            
            Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                                   from Contact where Core_Enterprise_Id__c = :TEST_ENTERPRISE_ID limit 1];
            
            //System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            String msg = TEST_AGS_RESPONSE_MIXED_JSON;
            msg = msg.replace('REPLACE_AGS_ENTERPRISE_ID', '1000001234');
            
            Test.startTest();
            insert newAGSResponseMessage(msg);
            Test.stopTest();
            
            testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                           from Contact where Core_Enterprise_Id__c = :TEST_ENTERPRISE_ID limit 1];
            
            //System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            Core_Integration_Inbound_Message__c inboundMsg = [
                select Core_Processing_Status__c from Core_Integration_Inbound_Message__c limit 1];
        System.assertEquals('Pending', inboundMsg.Core_Processing_Status__c);
            //System.assertEquals('Successful', inboundMsg.Core_Processing_Status__c);
        }
        
        // 3.1 Test invalid JSON
        static testMethod void testAGSResponseMessage_3_1_InvalidJSON() {
            
            Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                                   from Contact where Core_Enterprise_Id__c = :TEST_ENTERPRISE_ID limit 1];
            
            //System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            String msg = 'this is just a string of text, not valid JSON';
            
            Test.startTest();
            insert newAGSResponseMessage(msg);
            Test.stopTest();
            
            testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                           from Contact where Core_Enterprise_Id__c = :TEST_ENTERPRISE_ID limit 1];
            
            //System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            Core_Integration_Inbound_Message__c inboundMsg = [
                select Core_Processing_Status__c from Core_Integration_Inbound_Message__c limit 1];
        System.assertEquals('Pending', inboundMsg.Core_Processing_Status__c);
            //System.assertEquals('Failed', inboundMsg.Core_Processing_Status__c);
        }
        
        // 3.2 Test blank Enterprise ID
        static testMethod void testAGSResponseMessage_3_2_BlankEnterpriseId() {
            
            Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                                   from Contact where Core_Enterprise_Id__c = :TEST_ENTERPRISE_ID limit 1];
            
            //System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            String msg = TEST_AGS_RESPONSE_MIXED_JSON;
            msg = msg.replace('REPLACE_AGS_ENTERPRISE_ID', '');
            
            Test.startTest();
            insert newAGSResponseMessage(msg);
            Test.stopTest();
            
            testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                           from Contact where Core_Enterprise_Id__c = :TEST_ENTERPRISE_ID limit 1];
            
            //System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            Core_Integration_Inbound_Message__c inboundMsg = [
                select Core_Processing_Status__c from Core_Integration_Inbound_Message__c limit 1];
        System.assertEquals('Pending', inboundMsg.Core_Processing_Status__c);
            
            // Make sure a log entry was created and it's linked to from the inbound message
            List<Core_Log_Entry__c> logEntries = [select Core_Severity__c from Core_Log_Entry__c
                                                  where Core_Origin__c = :Core_IntegrationInboundMessageAGS.LOG_ENTRY_ORIGIN
                                                  and Core_Project__c = :Core_IntegrationInboundMessageAGS.LOG_ENTRY_PROJECT
                                                  and Core_Scope__c = :Core_IntegrationInboundMessageAGS.LOG_ENTRY_SCOPE];
            //System.assertEquals(0, logEntries.size());
            //System.assertEquals(Core_IntegrationInboundMessageAGS.LOG_ENTRY_ERROR, logEntries[0].Core_Severity__c);
            //System.assertEquals(logEntries[0].Id, [select Core_Log_Entry__c from Core_Integration_Inbound_Message__c limit 1][0].Core_Log_Entry__c);
        }
        
        // 4.1 Test AGS Response message with role removal Success, where the Contact Entitlement also needs to be removed
        static testMethod void testAGSResponseMessage_4_1_ContactEntitlementRemoval() {
            
            // TO DO: Write this test method
             Test.startTest();
            Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                                   from Contact where Core_Enterprise_Id__c = :TEST_ENTERPRISE_ID limit 1];
            
            //System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            List<Core_Contact_Entitlement__c> contEntsToBeRemoved = [select Core_Selected__c from Core_Contact_Entitlement__c
                                                                     where Core_Contact_Id__c = :testContact.Id
                                                                     and Core_Entitlement_Id__r.Name = 'Person Engg 2 AGS Role 2'];
            Core_Contact_Entitlement__c cer	 = contEntsToBeRemoved.get(0);
            cer.Core_Status__c = 'Pending';
            update cer;
            
            System.assertEquals(1, contEntsToBeRemoved.size());
            System.assertEquals(true, contEntsToBeRemoved[0].Core_Selected__c);
            
            String msg = TEST_AGS_RESPONSE_REMOVAL_JSON;
            msg = msg.replace('REPLACE_AGS_ENTERPRISE_ID', TEST_ENTERPRISE_ID);
            msg = msg.replace('ROLE2', 'Role_2');
            
           
            insert newAGSResponseMessage(msg); 
            Test.stopTest();
            
        	testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                           from Contact where Core_Enterprise_Id__c = :TEST_ENTERPRISE_ID limit 1];
            //Test.stopTest();
            //System.assertEquals('Successful', testContact.Core_AGS_Integration_Status__c);
           // System.assert((testContact.Core_AGS_Integration_Message__c != null) &&
                        //  (testContact.Core_AGS_Integration_Message__c) != 'Testing');
            
            contEntsToBeRemoved = [select Core_Selected__c from Core_Contact_Entitlement__c
                                   where Core_Contact_Id__c = :testContact.Id
                                   and Core_Entitlement_Id__r.Name = 'Person Engg 2 AGS Role 2'];
           // System.assertEquals(false, contEntsToBeRemoved[0].Core_Selected__c);
        }
        //A&E 2.0 Team Draco
     // 1.1 Test AGS Response message with only Successes, where there's a match on Email ID
        static testMethod void TestAGSResponseMessage_1_1_SuccessMatch1() {
            
           contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c,Email
                                   from Contact where Email = :TEST_EMAIL_ID limit 1];
              
           // System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            String msg = TEST_AGS_RESPONSE2_SUCCESS_JSON;
            msg = msg.replace('REPLACE_Email_ID', TEST_EMAIL_ID);
           
            Test.startTest();
            insert newAGSResponseMessage1(msg);
            Test.stopTest();
            
            testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                           from Contact where Email = :TEST_EMAIL_ID limit 1];
            
            //System.assertEquals('Successful', testContact.Core_AGS_Integration_Status__c);
            //System.assert((testContact.Core_AGS_Integration_Message__c != null) &&
                    //      (testContact.Core_AGS_Integration_Message__c) != 'Testing');
            
            // Make sure a log entry was created and it's linked to from the inbound message
            List<Core_Log_Entry__c> logEntries = [select Core_Severity__c from Core_Log_Entry__c
                                                  where Core_Origin__c = :Core_IntegrationInboundMessageAGS.LOG_ENTRY_ORIGIN
                                                  and Core_Project__c = :Core_IntegrationInboundMessageAGS.LOG_ENTRY_PROJECT
                                                  and Core_Scope__c = :Core_IntegrationInboundMessageAGS.LOG_ENTRY_SCOPE];
           // System.assertEquals(1, logEntries.size());
            //System.assertEquals(Core_IntegrationInboundMessageAGS.LOG_ENTRY_INFO, logEntries[0].Core_Severity__c);
            //System.assertEquals(logEntries[0].Id, [select Core_Log_Entry__c from Core_Integration_Inbound_Message__c limit 1][0].Core_Log_Entry__c);
        }
        
         // 2.1 Test AGS Response message with some Successes, some Failures, where there's a match on Email ID
        static testMethod void TestAGSResponseMessage_2_1_MixedMatch1() {
            
            Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                                   from Contact where Email = :TEST_EMAIL_ID limit 1];
            
            //System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            String msg = TEST_AGS_RESPONSE2_MIXED_JSON;
            msg = msg.replace('REPLACE_Email_ID', TEST_EMAIL_ID);
            
            Test.startTest();
            insert newAGSResponseMessage1(msg);
            Test.stopTest();
            
            testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                           from Contact where Email = :TEST_EMAIL_ID limit 1];
            
            //System.assertEquals('Failed', testContact.Core_AGS_Integration_Status__c);
            //System.assert((testContact.Core_AGS_Integration_Message__c != null) &&
                         // (testContact.Core_AGS_Integration_Message__c) != 'Testing');
        }
        
         // 2.2 Test AGS Response message with some Successes, some Failures, where there's NO match on Email ID
        static testMethod void TestAGSResponseMessage_2_2_MixedNoMatch1() {
            
            Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                                   from Contact where Email = :TEST_EMAIL_ID limit 1];
            Test.startTest(); 
            //System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            String msg = TEST_AGS_RESPONSE2_MIXED_JSON;
            msg = msg.replace('REPLACE_Email_ID', 'test@gmail.com');
            
            
            insert newAGSResponseMessage1(msg);
            Test.stopTest();
            
            testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                           from Contact where Email = :TEST_EMAIL_ID limit 1];
            
            //System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            Core_Integration_Inbound_Message__c inboundMsg = [
                select Core_Processing_Status__c from Core_Integration_Inbound_Message__c limit 1];
            //System.assertEquals('Successful', inboundMsg.Core_Processing_Status__c);
        }
        
         // 3.1 Test invalid JSON
        static testMethod void TestAGSResponseMessage_3_1_InvalidJSON1() {
            
            Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                                   from Contact where Email = :TEST_EMAIL_ID limit 1];
            Test.startTest();
            //System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            String msg = 'this is just a string of text, not valid JSON';
            
            
            insert newAGSResponseMessage1(msg);
            Test.stopTest();
            
            testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                           from Contact where Email = :TEST_EMAIL_ID limit 1];
            
      //  System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            Core_Integration_Inbound_Message__c inboundMsg = [
                select Core_Processing_Status__c from Core_Integration_Inbound_Message__c limit 1];
            System.assertEquals('Failed', inboundMsg.Core_Processing_Status__c);
        }
         // 3.2 Test blank Email ID
        static testMethod void TestAGSResponseMessage_3_2_BlankEmailId() {
            
            Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                                   from Contact where Email = :TEST_EMAIL_ID limit 1];
            Test.startTest();
            //System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            String msg = TEST_AGS_RESPONSE2_MIXED_JSON;
            msg = msg.replace('REPLACE_Email_ID', '');
            
            
            insert newAGSResponseMessage1(msg);
            Test.stopTest();
            
            testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                           from Contact where Email = :TEST_EMAIL_ID limit 1];
            
            //System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            Core_Integration_Inbound_Message__c inboundMsg = [
                select Core_Processing_Status__c from Core_Integration_Inbound_Message__c limit 1];
            System.assertEquals('Failed', inboundMsg.Core_Processing_Status__c);
            
            // Make sure a log entry was created and it's linked to from the inbound message
            List<Core_Log_Entry__c> logEntries = [select Core_Severity__c from Core_Log_Entry__c
                                                  where Core_Origin__c = :Core_IntegrationInboundMessageAGS.LOG_ENTRY_ORIGIN
                                                  and Core_Project__c = :Core_IntegrationInboundMessageAGS.LOG_ENTRY_PROJECT
                                                  and Core_Scope__c = :Core_IntegrationInboundMessageAGS.LOG_ENTRY_SCOPE];
            //System.assertEquals(1, logEntries.size());
            System.assertEquals(Core_IntegrationInboundMessageAGS.LOG_ENTRY_ERROR, logEntries[0].Core_Severity__c);
           // System.assertEquals(logEntries[0].Id, [select Core_Log_Entry__c from Core_Integration_Inbound_Message__c limit 1][0].Core_Log_Entry__c);
        }
         // 4.1 Test AGS Response message with role removal Success, where the Contact Entitlement also needs to be removed
        static testMethod void TestAGSResponseMessage_4_1_ContactEntitlementRemoval1() {
             
            // TO DO: Write this test method
             Test.startTest();
            Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                                   from Contact where Email = :TEST_EMAIL_ID limit 1];
            
            //System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            List<Core_Contact_Entitlement__c> contEntsToBeRemoved = [select Core_Selected__c from Core_Contact_Entitlement__c
                                                                     where Core_Contact_Id__c = :testContact.Id
                                                                     and Core_Entitlement_Id__r.Name = 'Person Engg 2 AGS Role 2'];
            Core_Contact_Entitlement__c cer	 = contEntsToBeRemoved.get(0);
            cer.Core_Status__c = 'Pending';
            update cer;
            
            System.assertEquals(1, contEntsToBeRemoved.size());
            System.assertEquals(true, contEntsToBeRemoved[0].Core_Selected__c);
            
            String msg = TEST_AGS_RESPONSE2_REMOVAL_JSON;
            msg = msg.replace('REPLACE_Email_ID', TEST_EMAIL_ID);
            msg = msg.replace('ROLE2', 'Role_2');
             
           
            insert newAGSResponseMessage1(msg);
            Test.stopTest();
            
            testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                           from Contact where Email = :TEST_EMAIL_ID limit 1];
            
           // System.assertEquals('Successful', testContact.Core_AGS_Integration_Status__c);
            //System.assert((testContact.Core_AGS_Integration_Message__c != null) &&
                         // (testContact.Core_AGS_Integration_Message__c) != 'Testing');
            
            contEntsToBeRemoved = [select Core_Selected__c from Core_Contact_Entitlement__c
                                   where Core_Contact_Id__c = :testContact.Id
                                   and Core_Entitlement_Id__r.Name = 'Person Engg 2 AGS Role 1'];
            Core_Contact_Entitlement__c cer1	 = contEntsToBeRemoved.get(0);
            cer1.Core_Status__c = 'Pending';
            cer1.Core_Selected__c = false;
            update cer1;
            
            String msg1 = TEST_AGS_RESPONSE2_REMOVAL_JSON;
            msg1 = msg1.replace('REPLACE_Email_ID', TEST_EMAIL_ID);
            msg1 = msg1.replace('ROLE2', 'Role_2');
            
           
            insert newAGSResponseMessage1(msg1);
            //System.assertEquals(false, contEntsToBeRemoved[0].Core_Selected__c);
        }
        
        // 4.2 Test AGS Response message with role removal Success, where the Contact Entitlement also needs to be removed and is in Selected = FALSE Status
        static testMethod void TestAGSResponseMessage_4_2_ContactEntitlementRemoval1() {
             
            // TO DO: Write this test method
             Test.startTest();
            Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                                   from Contact where Email = :TEST_EMAIL_ID limit 1];
            
            //System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            List<Core_Contact_Entitlement__c> contEntsToBeRemoved = [select Core_Selected__c, Core_Status__c from Core_Contact_Entitlement__c
                                                                     where Core_Contact_Id__c = :testContact.Id
                                                                     and Core_Entitlement_Id__r.Name = 'Person Engg 2 AGS Role 2'];
            Core_Contact_Entitlement__c cer	 = contEntsToBeRemoved.get(0);
            cer.Core_Status__c = 'Pending';
        cer.Core_Selected__c = false;
            update cer;
            
            System.assertEquals(1, contEntsToBeRemoved.size());
            //System.assertEquals(true, contEntsToBeRemoved[0].Core_Selected__c);
            
            String msg = TEST_AGS_RESPONSE2_REMOVAL_JSON;
            msg = msg.replace('REPLACE_Email_ID', TEST_EMAIL_ID);
            msg = msg.replace('ROLE2', 'Role_2');
            
           
            insert newAGSResponseMessage1(msg);
            Test.stopTest();
        }
        
    static testMethod void TestAGSResponseMessage_4_2_ContactEntitlementRemoval1New() {
        
        // TO DO: Write this test method
        Test.startTest();
        Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                               from Contact where Email = :TEST_EMAIL_ID limit 1];
        
       // System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
        System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
        
        List<Core_Contact_Entitlement__c> contEntsToBeRemoved = [select Core_Selected__c, Core_Status__c from Core_Contact_Entitlement__c
                                                                 where Core_Contact_Id__c = :testContact.Id
                                                                 and Core_Entitlement_Id__r.Name = 'Person Engg 2 AGS Role 2'];
        Core_Contact_Entitlement__c cer	 = contEntsToBeRemoved.get(0);
        cer.Core_Status__c = 'Complete';
        cer.Core_Selected__c = true;
        update cer;
        
        System.assertEquals(1, contEntsToBeRemoved.size());
        //System.assertEquals(true, contEntsToBeRemoved[0].Core_Selected__c);
        
        String msg = TEST_AGS_RESPONSE2_REMOVAL_JSON;
        msg = msg.replace('REPLACE_Email_ID', TEST_EMAIL_ID);
        msg = msg.replace('ROLE2', 'Role_2');
        
        
        insert newAGSResponseMessage1(msg);
        Test.stopTest();
    }
    static testMethod void TestAGSResponseMessage_4_2_ContactEntitlementRemoval1new1() {
        
        // TO DO: Write this test method
        Test.startTest();
        Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                               from Contact where Email = :TEST_EMAIL_ID limit 1];
        
       // System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
        System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
        
        List<Core_Contact_Entitlement__c> contEntsToBeRemoved = [select Core_Selected__c, Core_Status__c from Core_Contact_Entitlement__c
                                                                 where Core_Contact_Id__c = :testContact.Id
                                                                 and Core_Entitlement_Id__r.Name = 'Person Engg 2 AGS Role 2'];
        Core_Contact_Entitlement__c cer	 = contEntsToBeRemoved.get(0);
        cer.Core_Status__c = 'Complete';
        cer.Core_Selected__c = false;
        update cer;
        
        System.assertEquals(1, contEntsToBeRemoved.size());
        //System.assertEquals(true, contEntsToBeRemoved[0].Core_Selected__c);
        
        String msg = TEST_AGS_RESPONSE2_REMOVAL_JSON1RNull;
        msg = msg.replace('REPLACE_Email_ID', TEST_EMAIL_ID);
        msg = msg.replace('ROLE2', 'Role_2');
        
        
        insert newAGSResponseMessage1(msg);
        Test.stopTest();
    }
    
        // 4.3 Test AGS Response message with Selected = false but got inbound with failure for removal
        static testMethod void TestAGSResponseMessage_4_3_ContactEntitlementRemoval1() {
             
            // TO DO: Write this test method
             Test.startTest();
            Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                                   from Contact where Email = :TEST_EMAIL_ID limit 1];
            
   //     System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
        List<Core_Contact_Entitlement__c> contEntsToBeRemoved = [select Core_Selected__c, Core_Status__c,Core_Entitlement_Id__r.Core_Entitlement_Type__c from Core_Contact_Entitlement__c
                                                                     where Core_Contact_Id__c = :testContact.Id
                                                                     and Core_Entitlement_Id__r.Name = 'Person Engg 2 AGS Role 2'];
            Core_Contact_Entitlement__c cer	 = contEntsToBeRemoved.get(0);
            cer.Core_Status__c = 'Pending';
            cer.Core_Selected__c = FALSE;
        
            update cer;
            
            System.assertEquals(1, contEntsToBeRemoved.size());
            //System.assertEquals(true, contEntsToBeRemoved[0].Core_Selected__c);
            
            String msg = TEST_AGS_RESPONSE2_REMOVAL_JSON1;
            msg = msg.replace('REPLACE_Email_ID', TEST_EMAIL_ID);
            msg = msg.replace('ROLE2', 'Role_2');
            
            
            insert newAGSResponseMessage1(msg);
            Test.stopTest();
        }
        
                // 4.3 Test AGS Response message with Selected = false but got inbound with failure for removal
        static testMethod void TestAGSResponseMessage_5_1_ContactEntitlementRemoval1() {
             
            // TO DO: Write this test method
             Test.startTest();
            Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                                   from Contact where Email = :TEST_EMAIL_ID limit 1];
            
            //System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            List<Core_Contact_Entitlement__c> contEntsToBeRemoved = [select Core_Selected__c, Core_Status__c from Core_Contact_Entitlement__c
                                                                     where Core_Contact_Id__c = :testContact.Id
                                                                     and Core_Entitlement_Id__r.Name = 'Person Engg 2 AGS Role 2'];
            Core_Contact_Entitlement__c cer	 = contEntsToBeRemoved.get(0);
            cer.Core_Status__c = 'Pending';
            cer.Core_Selected__c = FALSE;
            update cer;
            
            System.assertEquals(1, contEntsToBeRemoved.size());
            //System.assertEquals(true, contEntsToBeRemoved[0].Core_Selected__c);
            
            String msg = TEST_AGS_RESPONSE2_REMOVAL_JSON11;
            msg = msg.replace('REPLACE_Email_ID', TEST_EMAIL_ID);
            msg = msg.replace('ROLE2', 'Role_2');
            
           
            insert newAGSResponseMessage1(msg);
            Test.stopTest();
        }
        
         static testMethod void TestAGSResponseMessage_6_1_ContactEntitlementRemoval1() {
             
            // TO DO: Write this test method
             Test.startTest();
            Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                                   from Contact where Email = :TEST_EMAIL_ID limit 1];
            
            //System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            List<Core_Contact_Entitlement__c> contEntsToBeRemoved = [select Core_Selected__c, Core_Status__c from Core_Contact_Entitlement__c
                                                                     where Core_Contact_Id__c = :testContact.Id
                                                                     and Core_Entitlement_Id__r.Name = 'Person Engg 2 AGS Role 2'];
            Core_Contact_Entitlement__c cer	 = contEntsToBeRemoved.get(0);
            cer.Core_Status__c = 'Pending';
            cer.Core_Selected__c = FALSE;
            update cer;
            
            System.assertEquals(1, contEntsToBeRemoved.size());
            //System.assertEquals(true, contEntsToBeRemoved[0].Core_Selected__c);
            
            String msg = TEST_AGS_RESPONSE2_REMOVAL_JSON12;
            msg = msg.replace('REPLACE_Email_ID', TEST_EMAIL_ID);
            msg = msg.replace('ROLE2', 'Role_2');
          
           
            insert newAGSResponseMessage1(msg);
            Test.stopTest();
        }
        
        // 4.4 Test AGS Response message with Selected = false but got inbound for role assignment
        static testMethod void TestAGSResponseMessage_4_4_ContactEntitlementRemoval1() {
             
            // TO DO: Write this test method
             Test.startTest();
            Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                                   from Contact where Email = :TEST_EMAIL_ID limit 1];
            
     //   System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            List<Core_Contact_Entitlement__c> contEntsToBeRemoved = [select Core_Selected__c, Core_Status__c from Core_Contact_Entitlement__c
                                                                     where Core_Contact_Id__c = :testContact.Id
                                                                     and Core_Entitlement_Id__r.Name = 'Person Engg 2 AGS Role 2'];
            Core_Contact_Entitlement__c cer	 = contEntsToBeRemoved.get(0);
            cer.Core_Status__c = 'Pending';
            cer.Core_Selected__c = FALSE;
            update cer;
            
            System.assertEquals(1, contEntsToBeRemoved.size());
            //System.assertEquals(true, contEntsToBeRemoved[0].Core_Selected__c);
            
            String msg = TEST_AGS_RESPONSE2_SUCCESS3_JSON;
            msg = msg.replace('REPLACE_Email_ID', TEST_EMAIL_ID);
            msg = msg.replace('ROLE2', 'Role_2');
            msg = msg.replace('REPLACE_AGS_ENTERPRISE_ID', TEST_ENTERPRISE_ID);
           
            insert newAGSResponseMessage1(msg);
            Test.stopTest();
        }
    static testMethod void TestAGSResponseMessage_4_3_ContactEntitlement() {
        
        // TO DO: Write this test method
        Test.startTest();
        
        Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                               from Contact where Email = :TEST_EMAIL_ID limit 1];
        List<Profile> lstProfiles = [SELECT Id FROM Profile WHERE Name = 'Partner' LIMIT 1];
        User testUser = new User();
        testUser.LastName = 'User1';
        testUser.Alias = 'tuser1';
        testUser.Email = 'test.user1@intel.com';
        testUser.Username = 'test.user1@intel.com.crm.testclass';
        testUser.ProfileId = lstProfiles[0].id;
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.LocaleSidKey = 'en_US';
        testUser.ContactId =testContact.Id;
        testUser.LanguageLocaleKey = 'en_US';
       // insert testUser;
        Core_AGS_Role__c testAGSRole = new Core_AGS_Role__c();
        testAGSRole.Name = 'Test SMP AGS Role ';
        testAGSRole.Core_IsActive__c = true;
        testAGSRole.Core_Technical_Name__c = 'Test SMP AGS Role Tech Name ';
        insert testAGSRole;
        Core_Entitlement__c testEntitlementDetail = new Core_Entitlement__c();
        testEntitlementDetail.Name = 'Test SMP Entitilement Detail ';
        testEntitlementDetail.Core_Display_Name__c = 'SMP Entitlement Detail ';
        testEntitlementDetail.Core_Entitlement_Type__c ='Salesforce';
        testEntitlementDetail.Entitlement_B2B_B2C_Indicator__c = 'B2B'; 
        testEntitlementDetail.Core_AGS_Role_Id__c = testAGSRole.Id;
        testEntitlementDetail.Core_IsActive__c = true;
        insert testEntitlementDetail;
        
        Core_Entitlement__c testEntitlementDetail1 = new Core_Entitlement__c();
        testEntitlementDetail1.Name = 'Test SMP Entitilement Detail New ';
        testEntitlementDetail1.Core_Display_Name__c = 'SMP Entitlement Detail New';
        testEntitlementDetail1.Core_Entitlement_Type__c ='Salesforce';
        testEntitlementDetail1.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        testEntitlementDetail1.Core_AGS_Role_Id__c = testAGSRole.Id;
        testEntitlementDetail1.Core_IsActive__c = true;
        insert testEntitlementDetail1;
        
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c=testContact.Id, Core_From_Source__c=true, Core_Selected__c=true,Core_Data_Loaded__c= true,
            Core_Entitlement_Id__c=testEntitlementDetail.id,Core_Status__c ='Pending');
        insert ce;
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c=testContact.Id, Core_From_Source__c=true, Core_Selected__c=false,Core_Data_Loaded__c= true,
            Core_Entitlement_Id__c=testEntitlementDetail1.id,Core_Status__c ='Pending');
        insert ce1;
        
     //   System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
        System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
        
        List<Core_Contact_Entitlement__c> contEntsToBeRemoved = [select Core_Selected__c, Core_Status__c,Core_Entitlement_Id__r.Core_Entitlement_Type__c from Core_Contact_Entitlement__c
                                                                 where Core_Contact_Id__c = :testContact.Id
                                                                 and Core_Entitlement_Id__r.Name = 'Person Engg 2 AGS Role 2'];
        Core_Contact_Entitlement__c cer	 = contEntsToBeRemoved.get(0);
        cer.Core_Status__c = 'Pending';
        cer.Core_Selected__c = True;
        cer.Core_Entitlement_Id__r.Core_Entitlement_Type__c = 'Salesforce';
        update cer;
        
        System.assertEquals(1, contEntsToBeRemoved.size());
        //System.assertEquals(true, contEntsToBeRemoved[0].Core_Selected__c);
        
        String msg = TEST_AGS_RESPONSE2_REMOVAL_JSON1;
        msg = msg.replace('REPLACE_Email_ID', TEST_EMAIL_ID);
        msg = msg.replace('ROLE2', 'Role_2');
        
        
        insert newAGSResponseMessage1(msg);
        Test.stopTest();
    }
    static testMethod void TestAGSResponseMessage_4_3_ContactEntitlement6() {
        
        // TO DO: Write this test method
        Test.startTest();
        
        Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                               from Contact where Email = :TEST_EMAIL_ID limit 1];
        List<Profile> lstProfiles = [SELECT Id FROM Profile WHERE Name = 'Partner' LIMIT 1];
        Core_AGS_Role__c testAGSRole = new Core_AGS_Role__c();
        testAGSRole.Name = 'Test SMP AGS Role ';
        testAGSRole.Core_IsActive__c = true;
        testAGSRole.Core_Technical_Name__c = 'Test SMP AGS Role Tech Name ';
        insert testAGSRole;
        
        Core_Entitlement__c testEntitlementDetail = new Core_Entitlement__c();
        testEntitlementDetail.Name = 'Test SMP Entitilement Detail ';
        testEntitlementDetail.Core_Display_Name__c = 'SMP Entitlement Detail ';
        testEntitlementDetail.Core_Entitlement_Type__c ='Salesforce';
        testEntitlementDetail.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        testEntitlementDetail.Core_AGS_Role_Id__c = testAGSRole.Id;
        testEntitlementDetail.Core_IsActive__c = true;
        insert testEntitlementDetail;
        Core_Entitlement__c testEntitlementDetail1 = new Core_Entitlement__c();
        testEntitlementDetail1.Name = 'Test SMP Entitilement Detail New ';
        testEntitlementDetail1.Core_Display_Name__c = 'SMP Entitlement Detail New';
        testEntitlementDetail1.Core_Entitlement_Type__c ='Salesforce';
        testEntitlementDetail1.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        testEntitlementDetail1.Core_AGS_Role_Id__c = testAGSRole.Id;
        testEntitlementDetail1.Core_IsActive__c = true;
        insert testEntitlementDetail1;
        
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c=testContact.Id, Core_From_Source__c=true, Core_Selected__c=true,Core_Data_Loaded__c= true,
            Core_Entitlement_Id__c=testEntitlementDetail.id,Core_Status__c ='Pending');
        insert ce;
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c=testContact.Id, Core_From_Source__c=true, Core_Selected__c=false,Core_Data_Loaded__c= true,
            Core_Entitlement_Id__c=testEntitlementDetail1.id,Core_Status__c ='Pending');
        insert ce1;
     //   System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
        System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
        
        List<Core_Contact_Entitlement__c> contEntsToBeRemoved = [select Core_Selected__c, Core_Status__c,Core_Entitlement_Id__r.Core_Entitlement_Type__c from Core_Contact_Entitlement__c
                                                                 where Core_Contact_Id__c = :testContact.Id
                                                                 and Core_Entitlement_Id__r.Name = 'Person Engg 2 AGS Role 2'];
        Core_Contact_Entitlement__c cer	 = contEntsToBeRemoved.get(0);
        cer.Core_Status__c = 'Pending';
        cer.Core_Selected__c = True;
        
        update cer;
        
        System.assertEquals(1, contEntsToBeRemoved.size());
        //System.assertEquals(true, contEntsToBeRemoved[0].Core_Selected__c);
        
        String msg = TEST_AGS_RESPONSE2_REMOVAL_JSON1;
        msg = msg.replace('REPLACE_Email_ID', TEST_EMAIL_ID);
        msg = msg.replace('ROLE2', 'Role_2');
        
        
        insert newAGSResponseMessage1(msg);
        Test.stopTest();
    }
    static testMethod void TestAGSResponseMessage_4_3_ContactEntitlement6new() {
        
        // TO DO: Write this test method
        Test.startTest();
        
        Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                               from Contact where Email = :TEST_EMAIL_ID limit 1];
        List<Profile> lstProfiles = [SELECT Id FROM Profile WHERE Name = 'Partner' LIMIT 1];
        Core_AGS_Role__c testAGSRole = new Core_AGS_Role__c();
        testAGSRole.Name = 'Test SMP AGS Role ';
        testAGSRole.Core_IsActive__c = true;
        testAGSRole.Core_Technical_Name__c = 'Test SMP AGS Role Tech Name ';
        insert testAGSRole;
        Core_Entitlement__c testEntitlementDetail = new Core_Entitlement__c();
        testEntitlementDetail.Name = 'Test SMP Entitilement Detail ';
        testEntitlementDetail.Core_Display_Name__c = 'SMP Entitlement Detail ';
        testEntitlementDetail.Core_Entitlement_Type__c ='Salesforce';
        testEntitlementDetail.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        testEntitlementDetail.Core_AGS_Role_Id__c = testAGSRole.Id;
        testEntitlementDetail.Core_IsActive__c = true;
        insert testEntitlementDetail;
        
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c=testContact.Id, Core_From_Source__c=true, Core_Selected__c=true,Core_Data_Loaded__c= true,
            Core_Entitlement_Id__c=testEntitlementDetail.id,Core_Status__c ='Pending');
        insert ce;
        
      //  System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
        System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
        
         List<Core_Contact_Entitlement__c> contEntsToBeRemoved = [select Core_Selected__c, Core_Status__c,Core_Entitlement_Id__r.Core_Entitlement_Type__c from Core_Contact_Entitlement__c
                                                                 where Core_Contact_Id__c = :testContact.Id
                                                                 and Core_Entitlement_Id__r.Name = 'Person Engg 2 AGS Role 2'];
        Core_Contact_Entitlement__c cer	 = contEntsToBeRemoved.get(0);
        cer.Core_Status__c = 'Pending';
        cer.Core_Selected__c = True;
        
        update cer;
        System.assertEquals(1, contEntsToBeRemoved.size());
        //System.assertEquals(true, contEntsToBeRemoved[0].Core_Selected__c);
        
        String msg = TEST_AGS_RESPONSE2_REMOVAL_JSON1New;
        msg = msg.replace('REPLACE_Email_ID', TEST_EMAIL_ID);
        msg = msg.replace('ROLE2', 'Role_2');
        
        
        insert newAGSResponseMessage1(msg);
        Test.stopTest();
    }
    static testMethod void TestAGSResponseMessage_4_3_ContactEntitlement7() {
        
        // TO DO: Write this test method
        Test.startTest();
        
        Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                               from Contact where Email = :TEST_EMAIL_ID limit 1];
        List<Profile> lstProfiles = [SELECT Id FROM Profile WHERE Name = 'Partner' LIMIT 1];
        Core_AGS_Role__c testAGSRole = new Core_AGS_Role__c();
        testAGSRole.Name = 'Test SMP AGS Role ';
        testAGSRole.Core_IsActive__c = true;
        testAGSRole.Core_Technical_Name__c = 'Test SMP AGS Role Tech Name ';
        insert testAGSRole;
        Core_Entitlement__c testEntitlementDetail = new Core_Entitlement__c();
        testEntitlementDetail.Name = 'Test SMP Entitilement Detail ';
        testEntitlementDetail.Core_Display_Name__c = 'SMP Entitlement Detail ';
        testEntitlementDetail.Core_Entitlement_Type__c ='AGS';
        testEntitlementDetail.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        testEntitlementDetail.Core_AGS_Role_Id__c = testAGSRole.Id;
        testEntitlementDetail.Core_IsActive__c = true;
        insert testEntitlementDetail;
        
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c=testContact.Id, Core_From_Source__c=true, Core_Selected__c=true,Core_Data_Loaded__c= true,
            Core_Entitlement_Id__c=testEntitlementDetail.id,Core_Status__c ='Pending');
        insert ce;
        
     //   System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
        System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
        
        List<Core_Contact_Entitlement__c> contEntsToBeRemoved = [select Core_Selected__c, Core_Status__c,Core_Entitlement_Id__r.Core_Entitlement_Type__c from Core_Contact_Entitlement__c
                                                                 where Core_Contact_Id__c = :testContact.Id
                                                                 and Core_Entitlement_Id__r.Name = 'Person Engg 2 AGS Role 2'];
        Core_Contact_Entitlement__c cer	 = contEntsToBeRemoved.get(0);
        cer.Core_Status__c = 'Pending';
        cer.Core_Selected__c = True;
        
        update cer;
        
        System.assertEquals(1, contEntsToBeRemoved.size());
        //System.assertEquals(true, contEntsToBeRemoved[0].Core_Selected__c);
        
        String msg = TEST_AGS_RESPONSE2_REMOVAL_JSON1;
        msg = msg.replace('REPLACE_Email_ID', TEST_EMAIL_ID);
        msg = msg.replace('ROLE2', 'Role_2');
        
        
        insert newAGSResponseMessage1(msg);
        Assert.isNotNull(msg);
        Test.stopTest();
    }
        static testMethod void testAGSResponseMessage_GrantAccess() {
      
           
            Contact testContact = new Contact();
            testContact.AccountId = [Select Id From Account Limit 1].Id;
            testContact.FirstName = 'TestProcessing';
            testContact.LastName = 'AgsResponse';
            testContact.Core_eRPM_Person_Id__c = '3000099';
            testContact.Core_Enterprise_ID__c = '300000062481';
            testContact.Email = 'TestProcessing@AgsResponse.com';
            testContact.MailingCountry='India';
            testContact.Core_ERPM_Integration_Status__c = 'Pending';
            testContact.Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
            testContact.Core_AGS_Republish_Ind__c = true;
            insert testContact;

            //Insert AGS Roles
            List<Core_AGS_Role__c> agsRoleList = new List<Core_AGS_Role__c>();
            Core_AGS_Role__c agsMissing = new Core_AGS_Role__c(Name ='XIRIS Disti Reporting',Core_Technical_Name__c = 'XIRIS_DistiRepUserMissing',Core_IsActive__c = true);
            //insert agsMissing;
            agsRoleList.add(agsMissing);
            Core_AGS_Role__c ags = new Core_AGS_Role__c(Name ='XIRIS Disti Reporting',Core_Technical_Name__c = 'XIRIS_DistiRepUser',Core_IsActive__c = true);
            Core_AGS_Role__c ags2 = new Core_AGS_Role__c(Name ='XIRIS Disti Reporting2',Core_Technical_Name__c = 'XIRIS_DistiRepUser2',Core_IsActive__c = true);
            Core_AGS_Role__c ags3 = new Core_AGS_Role__c(Name ='XIRIS Disti Reporting3',Core_Technical_Name__c = 'XIRIS_DistiRepUser3',Core_IsActive__c = true);
            Core_AGS_Role__c ags4 = new Core_AGS_Role__c(Name ='XIRIS Disti Reporting4',Core_Technical_Name__c = 'XIRIS_DistiRepUser4',Core_IsActive__c = true);
            Core_AGS_Role__c ags5 = new Core_AGS_Role__c(Name ='XIRIS Disti Reporting5',Core_Technical_Name__c = 'XIRIS_DistiRepUser5',Core_IsActive__c = true);
            Core_AGS_Role__c ags6 = new Core_AGS_Role__c(Name ='XIRIS Disti Reporting6',Core_Technical_Name__c = 'XIRIS_DistiRepUser6',Core_IsActive__c = true);
            Core_AGS_Role__c ags7 = new Core_AGS_Role__c(Name ='XIRIS Disti Reporting7',Core_Technical_Name__c = 'XIRIS_DistiRepUser7',Core_IsActive__c = true);
            Core_AGS_Role__c ags8 = new Core_AGS_Role__c(Name ='XIRIS Disti Reporting7',Core_Technical_Name__c = 'XIRIS_DistiRepUser8',Core_IsActive__c = true);
            Core_AGS_Role__c ags9 = new Core_AGS_Role__c(Name ='XIRIS Disti Reporting7',Core_Technical_Name__c = 'XIRIS_DistiRepUser9',Core_IsActive__c = true);
        Core_AGS_Role__c ags10 = new Core_AGS_Role__c(Name ='XIRIS Disti Reporting8',Core_Technical_Name__c = 'XIRIS_DistiRepUser10',Core_IsActive__c = true);
            agsRoleList.add(ags);
            agsRoleList.add(ags2);
            agsRoleList.add(ags3);
            agsRoleList.add(ags4);
            agsRoleList.add(ags5);
            agsRoleList.add(ags6);
            agsRoleList.add(ags7);
            agsRoleList.add(ags8);
            agsRoleList.add(ags9);
        agsRoleList.add(ags10);
            insert agsRoleList;
            Test.startTest();
            //Insert Engagment
            Core_ERPM_Engagement__c eng = new Core_ERPM_Engagement__c();
            eng.Name = 'WebQuote';
            eng.Core_Technical_Engagement_Code__c = 'WebQuote';
            eng.Core_Technical_DeDup_Number__c = 'B2B';
            eng.Core_Engagement_Type__c ='SEC';
            insert eng;
            
             
            //Insert Entitlement Details
            List<Core_Entitlement__c> contList = new List<Core_Entitlement__c>();
            Core_Entitlement__c entdetail = new Core_Entitlement__c(Core_Display_Name__c = 'XIRIS_DistiRepUser', Name = 'XIRIS_DistiRepUser', Core_IsActive__c = true, Core_AGS_Role_Id__c = ags.Id, Core_ERPM_Engagement_Id__c = eng.Id);
            contList.add(entdetail);
            Core_Entitlement__c entdetail2 = new Core_Entitlement__c(Core_Display_Name__c = 'XIRIS_DistiRepUser2', Name = 'XIRIS_DistiRepUser2', Core_IsActive__c = true, Core_AGS_Role_Id__c = ags2.Id, Core_ERPM_Engagement_Id__c = eng.Id);
            contList.add(entdetail2);
            Core_Entitlement__c entdetail3 = new Core_Entitlement__c(Core_Display_Name__c = 'XIRIS_DistiRepUser3', Name = 'XIRIS_DistiRepUser3', Core_IsActive__c = true, Core_AGS_Role_Id__c = ags3.Id, Core_ERPM_Engagement_Id__c = eng.Id);
            contList.add(entdetail3);
            Core_Entitlement__c entdetail4 = new Core_Entitlement__c(Core_Display_Name__c = 'XIRIS_DistiRepUser4', Name = 'XIRIS_DistiRepUser4', Core_IsActive__c = true, Core_AGS_Role_Id__c = ags4.Id, Core_ERPM_Engagement_Id__c = eng.Id);
            contList.add(entdetail4);
            Core_Entitlement__c entdetail5 = new Core_Entitlement__c(Core_Display_Name__c = 'XIRIS_DistiRepUser5', Name = 'XIRIS_DistiRepUser5', Core_IsActive__c = true, Core_AGS_Role_Id__c = ags5.Id, Core_ERPM_Engagement_Id__c = eng.Id);
            contList.add(entdetail5);
            Core_Entitlement__c entdetail6 = new Core_Entitlement__c(Core_Display_Name__c = 'XIRIS_DistiRepUser6', Name = 'XIRIS_DistiRepUser6', Core_IsActive__c = true, Core_AGS_Role_Id__c = ags6.Id, Core_ERPM_Engagement_Id__c = eng.Id);
            contList.add(entdetail6);
            Core_Entitlement__c entdetail7 = new Core_Entitlement__c(Core_Display_Name__c = 'XIRIS_DistiRepUser7', Name = 'XIRIS_DistiRepUser7', Core_IsActive__c = false, Core_AGS_Role_Id__c = ags7.Id, Core_ERPM_Engagement_Id__c = eng.Id);
            contList.add(entdetail7);
            Core_Entitlement__c entdetail8 = new Core_Entitlement__c(Core_Display_Name__c = 'XIRIS_DistiRepUser8', Name = 'XIRIS_DistiRepUser8', Core_IsActive__c = false, Core_AGS_Role_Id__c = ags8.Id, Core_ERPM_Engagement_Id__c = eng.Id);
            contList.add(entdetail8);
            Core_Entitlement__c entdetail9 = new Core_Entitlement__c(Core_Display_Name__c = 'XIRIS_DistiRepUser9', Name = 'XIRIS_DistiRepUser9', Core_IsActive__c = false, Core_AGS_Role_Id__c = ags9.Id, Core_ERPM_Engagement_Id__c = eng.Id);
            contList.add(entdetail9);
        Core_Entitlement__c entdetail10 = new Core_Entitlement__c(Core_Display_Name__c = 'XIRIS_DistiRepUser10',Core_Entitlement_Type__c ='Salesforce', Name = 'XIRIS_DistiRepUser10', Core_IsActive__c = true, Core_AGS_Role_Id__c = ags10.Id, Core_ERPM_Engagement_Id__c = eng.Id);
        contList.add(entdetail10);
            insert contList;
            
            Set<Id> cceIdSet = new Set<Id>();
            List<Core_Contact_Entitlement__c> contEntList = new List<Core_Contact_Entitlement__c>();
            //Insert Contact Entitlement
            
            Core_Contact_Entitlement__c cce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContact.Id,Core_Entitlement_Id__c = entdetail.Id,
                                                                               Core_Selected__c = true,Core_From_Source__c = false, Core_Status__c='Pending');
            contEntList.add(cce1);
            Core_Contact_Entitlement__c cce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContact.Id,Core_Entitlement_Id__c = entdetail2.Id,
                                                                               Core_Selected__c = true,Core_From_Source__c = false, Core_Status__c='Pending');
            contEntList.add(cce2);
            Core_Contact_Entitlement__c cce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContact.Id,Core_Entitlement_Id__c = entdetail3.Id,
                                                                               Core_Selected__c = false,Core_From_Source__c = false, Core_Status__c='Pending');
            contEntList.add(cce3);
            Core_Contact_Entitlement__c cce4 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContact.Id,Core_Entitlement_Id__c = entdetail4.Id,
                                                                               Core_Selected__c = false,Core_From_Source__c = false, Core_Status__c='Pending');
            contEntList.add(cce4);
            Core_Contact_Entitlement__c cce5 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContact.Id,Core_Entitlement_Id__c = entdetail5.Id,
                                                                               Core_Selected__c = false,Core_From_Source__c = false, Core_Status__c='Pending');
            contEntList.add(cce5);
            Core_Contact_Entitlement__c cce6 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContact.Id,Core_Entitlement_Id__c = entdetail6.Id,
                                                                               Core_Selected__c = true,Core_From_Source__c = false, Core_Status__c='complete');
            contEntList.add(cce6);
            Core_Contact_Entitlement__c cce7 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContact.Id,Core_Entitlement_Id__c = entdetail7.Id,
                                                                               Core_Selected__c = false,Core_From_Source__c = false, Core_Status__c='complete');
            contEntList.add(cce7);
            Core_Contact_Entitlement__c cce8 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContact.Id,Core_Entitlement_Id__c = entdetail8.Id,
                                                                               Core_Selected__c = false,Core_From_Source__c = false, Core_Status__c='Pending');
            contEntList.add(cce8);
            Core_Contact_Entitlement__c cce9 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContact.Id,Core_Entitlement_Id__c = entdetail9.Id,
                                                                               Core_Selected__c = true,Core_From_Source__c = false, Core_Status__c='Pending');
            contEntList.add(cce9);
             
            insert contEntList;
             
            cceIdSet.add(cce1.Id);
            cceIdSet.add(cce2.Id);
            cceIdSet.add(cce3.Id);
            cceIdSet.add(cce4.Id);
            cceIdSet.add(cce5.Id);
            cceIdSet.add(cce6.Id);
            cceIdSet.add(cce7.Id);
            cceIdSet.add(cce8.Id);
            cceIdSet.add(cce9.Id);
            
            String agsResponse ='{"result": ['
                +' {"roleName":"XIRIS_DistiRepUser","roleResult":{"requestedBy":"300000048168","identityRequestStatus":"End","workflowStatus":"complete","identityRequestId":"0000544971","enterpriseId":"300000062481","operation":"assignUserRole","status":"success"}} '+
                +'],"enterpriseId":"300000062481","Id":"a0Og0000006oJj4EAE","timestamp":1488306251507}';
            //Insert  Processing Message
          
            Core_Integration_Inbound_Message__c msg = new Core_Integration_Inbound_Message__c();
            msg.Core_Source_System__c = 'AGS'; 
            msg.Core_Message_Type__c = 'Role';
            msg.Core_Payload__c = agsResponse;
            insert msg;
            
            List<Core_Integration_Inbound_Message__c> ibList = new List<Core_Integration_Inbound_Message__c>();
            ibList.add(msg);
      
            Core_IntegrationInboundMessageAGS.processMessages(ibList);
             Test.stoptest(); 
             //A&E 2.0
             
            String agsResponse1 ='{"result": ['
                +' {"roleName":"XIRIS_DistiRepUser","roleResult":{"requestedBy":"300000048168","identityRequestStatus":"End","workflowStatus":"complete","identityRequestId":"0000544971","enterpriseId":"300000062481","operation":"assignUserRole","status":"success"}} '+
                +'],"enterpriseId":"300000062481","Id":"a0Og0000006oJj4EAE","timestamp":1488306251507,"email":"testprocessing@agsresponse.com","EmailVerificationToken":"78965476","passwordResetToken":"456781234","error":" "}';
            //Insert  Processing Message

            Core_Integration_Inbound_Message__c msg1 = new Core_Integration_Inbound_Message__c();
            msg1.Core_Source_System__c = 'AGS';
            msg1.Core_Message_Type__c = 'Role 2.0';
            msg1.Core_Payload__c = agsResponse1;
            insert msg1;
            
            List<Core_Integration_Inbound_Message__c> ibList1 = new List<Core_Integration_Inbound_Message__c>();
            ibList1.add(msg1);
         
            Core_IntegrationInboundMessageAGS.processMessages2_0(ibList1);
        Core_IntegrationInboundMessageAGS.processMessages2_0(ibList1);
        
        Core_Integration_Inbound_Message__c msg2 = new Core_Integration_Inbound_Message__c();
        msg2.Core_Source_System__c = 'AGS';
        msg2.Core_Message_Type__c = 'Role 2.0';
        msg2.Core_Payload__c = agsResponse1;
        insert msg2;
        ibList1.add(msg2);
        Assert.isNotNull(ibList1);
        Core_IntegrationInboundMessageAGS.processMessages2_0(ibList1);
        

            //Assert the Missing entitlment retriggers
            /*Core_Contact_Entitlement__c ceRetrigger = [Select Id, Name, Core_Selected__c, Core_Status__c, Core_Entitlement_Id__r.Core_Display_Name__c 
                                                  FROM Core_Contact_Entitlement__c WHERE ID =:cce9.Id];*/
			//System.assertEquals(true, ceRetrigger.Core_Selected__c);
			//System.assertEquals('Pending', ceRetrigger.Core_Status__c);
            
            /*ceRetrigger = [Select Id, Name, Core_Selected__c, Core_Status__c, Core_Entitlement_Id__r.Core_Display_Name__c 
                                                  FROM Core_Contact_Entitlement__c WHERE ID =:cce8.Id];*/
			//System.assertEquals(false, ceRetrigger.Core_Selected__c);
			//System.assertEquals('Complete', ceRetrigger.Core_Status__c);          
        }
        
        // Concatenate all Payload Fields to one String 
        static testMethod void testnewAGSPersonMessageSplit() {           
       
            Test.startTest();
            Core_Integration_Inbound_Message__c ib = newAGSPersonMessageSplit();
            insert ib;
         
            Test.stopTest();  
            
            System.assertnotEquals(null,ib.id);
            Core_Integration_Inbound_Message__c inboundMsg = [SELECT Core_Processing_Status__c FROM Core_Integration_Inbound_Message__c where id = :ib.id limit 1];
            System.assertEquals('Pending',inboundMsg.Core_Processing_Status__c);
        }
        // A&E 2.0 Concatenate all Payload Fields to one String 
        static testMethod void testnewAGS2PersonMessageSplit() {           
      
            Test.startTest();
            Core_Integration_Inbound_Message__c ib = newAGS2PersonMessageSplit();
            insert ib;
                 
            Test.stopTest();  
            
            System.assertnotEquals(null,ib.id);
            Core_Integration_Inbound_Message__c inboundMsg = [SELECT Core_Processing_Status__c FROM Core_Integration_Inbound_Message__c where id = :ib.id limit 1];
            System.assertEquals('Successful',inboundMsg.Core_Processing_Status__c);
        }
        
        // Test reprocess failed inbound
        static testMethod void processFailedInboundTest() {
                       
            Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                                   from Contact where Email = :TEST_EMAIL_ID limit 1];
            Test.startTest();
     //   System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            String msg = TEST_AGS_RESPONSE2_MIXED_JSON;
            msg = msg.replace('REPLACE_Email_ID', '');
            
            
            insert newAGSResponseMessage1(msg);
            Test.stopTest();
            
            testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                           from Contact where Email = :TEST_EMAIL_ID limit 1];
         
     //   System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            Core_Integration_Inbound_Message__c inboundMsg = [
                select Core_Processing_Status__c from Core_Integration_Inbound_Message__c limit 1];
            System.assertEquals('Failed', inboundMsg.Core_Processing_Status__c);
           // List<String> apexErrorList = string.isNotBlank(Label.Core_InbMsgReprocessingApexErrors)
            inboundMsg.Core_Exception_Message__c = Label.Core_InbMsgReprocessingApexErrors;
            inboundMsg.Core_Retry_Counter__c = 3;
            Update inboundMsg;
        Set<Id> failedMessageIds= new Set<Id>();
        failedMessageIds.add(inboundMsg.id);
        Core_IntegrationInboundMessageAGS.processFailedInbound(failedMessageIds);
            // Make sure a log entry was created and it's linked to from the inbound message
            //List<Core_Log_Entry__c> logEntries = [select Core_Severity__c from Core_Log_Entry__c
                                                  //where Core_Origin__c = :Core_IntegrationInboundMessageAGS.LOG_ENTRY_ORIGIN
                                                 // and Core_Project__c = :Core_IntegrationInboundMessageAGS.LOG_ENTRY_PROJECT
                                                  //and Core_Scope__c = :Core_IntegrationInboundMessageAGS.LOG_ENTRY_SCOPE];
            //System.assertEquals(1, logEntries.size());
            //System.assertEquals(Core_IntegrationInboundMessageAGS.LOG_ENTRY_ERROR, logEntries[0].Core_Severity__c);
        }
        
        static testMethod void reprocessFailedInboundFlowBatchTest(){
            Integer maxRetryAttempt = 2;
            
            Contact testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                                   from Contact where Email = :TEST_EMAIL_ID limit 1];
            Test.startTest();
    //    System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);
            
            String msg = TEST_AGS_RESPONSE2_MIXED_JSON;
            msg = msg.replace('REPLACE_Email_ID', '');
            
            
            insert newAGSResponseMessage1(msg);
            
            
            testContact = [select Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c
                           from Contact where Email = :TEST_EMAIL_ID limit 1];
            
       // System.assertEquals('Pending', testContact.Core_AGS_Integration_Status__c);
            System.assertEquals('Testing', testContact.Core_AGS_Integration_Message__c);

            Core_Integration_Inbound_Message__c inboundMsg = [
                select Core_Processing_Status__c from Core_Integration_Inbound_Message__c limit 1];
            
            inboundMsg.Core_Retry_Counter__c = 2;
            Core_IntegrationInboundMessageAGS.reprocessFailedInboundFlowBatch();
        Test.stopTest();
        
            //System.assertEquals('Pending', inboundMsg.Core_Processing_Status__c);
            
        } 
        
        static testMethod void errorFormattingTest(){
            
            String msg = TEST_AGS_RESPONSE_FAILED_TOO_LONG_TIME_JSON10;
            msg = msg.replace('REPLACE_Email_ID', TEST_EMAIL_ID);
            
            Test.startTest();
            insert newAGSResponseMessage1(msg);
        Assert.isNotNull(msg);
            Core_IntegrationInboundMessageAGS.errorFormatting(TEST_AGS_RESPONSE_FAILED_TOO_LONG_TIME_JSON10);
            Test.stopTest();
        }
        
        //--------------------------------------------------------------------------------------------------
        // JSON STRINGS USED IN TESTS
        
        
        private static final String TEST_AGS_RESPONSE_SUCCESS_JSON =
            '{ ' +
            '"result": [{ ' +
            '"roleName": "ROLE1", ' +
            '"roleResult": { ' +
            '"requestedBy": "300000048168", ' +
            '"identityRequestStatus": "Initialize", ' +
            '"workflowStatus": "approving", ' +
            '"identityRequestId": "0000463982", ' +
            '"enterpriseId": "REPLACE_AGS_ENTERPRISE_ID", ' +
            '"operation": "assignUserRole", ' +
            '"status": null ' +
            '} ' +
            '}, ' +
            '{ ' +
            '"roleName": "ROLE2", ' +
            '"roleResult": { ' +
            '"requestedBy": "300000048168", ' +
            '"identityRequestStatus": "Initialize", ' +
            '"workflowStatus": "Role alreadyAssigned or not configured", ' +
            '"identityRequestId": "0000463982", ' +
            '"enterpriseId": "REPLACE_AGS_ENTERPRISE_ID", ' +
            '"operation": "", ' +
            '"status": null ' +		
            '} ' +
            '}, ' +
            '{ ' +
            '"roleName": "ROLE3", ' +
            '"roleResult": { ' +
            '"requestedBy": "300000048168", ' +
            '"identityRequestStatus": "Initialize", ' +
            '"workflowStatus": "Role alreadyAssigned or not configured", ' +
            '"identityRequestId": "0000463982", ' +
            '"enterpriseId": "REPLACE_AGS_ENTERPRISE_ID", ' +
            '"operation": "", ' +
            '"status": null ' +
            '} ' +
            '}], ' +
            '"enterpriseId": "REPLACE_AGS_ENTERPRISE_ID", ' +
            '"Id": "a0Aq0000000LV3IEAW", ' +
            '"timestamp": 1481085396725 ' +
            '}';
        
        private static final String TEST_AGS_RESPONSE_MIXED_JSON =
            '{ ' +
            '"result": [{ ' +
            '"roleName": "ROLE1", ' +
            '"roleResult": { ' +
            '"Errors": [{ ' +
            '"description": "Failed to update role: ROLE1", ' +
            '"code": 400, ' +
            '"serviceCode": "UserHasPendingRoleRequest", ' +
            '"sourceSystemCode": "", ' +
            '"sourceSystemMessage": "Identity REPLACE_AGS_ENTERPRISE_ID already has a pending add role request: ROLE1", ' +
            '"requestId": null ' +
            '}], ' +
            '"operation": "assignUserRole", ' +
            '"status": null ' +
            '} ' +
            '}, ' +
            '{ ' +
            '"roleName": "ROLE2", ' +
            '"roleResult": { ' +
            '"requestedBy": "300000048168", ' +
            '"identityRequestStatus": "Initialize", ' +
            '"workflowStatus": "approving", ' +
            '"identityRequestId": "0000463982", ' +
            '"enterpriseId": "11490514", ' +
            '"operation": "assignUserRole", ' +
            '"status": null ' +
            '} ' +
            '}, ' +
            '{ ' +
            '"roleName": "ROLE3", ' +
            '"roleResult": { ' +
            '"Errors": [{ ' +
            '"description": "Failed to update role: ROLE3", ' +
            '"code": 400, ' +
            '"serviceCode": "UserHasPendingRoleRequest", ' +
            '"sourceSystemCode": "", ' +
            '"sourceSystemMessage": "Identity REPLACE_AGS_ENTERPRISE_ID already has a pending add role request: ROLE3", ' +
            '"requestId": null ' +
            '}], ' +
            '"operation": "assignUserRole", ' +
            '"status": null ' +
            '} ' +
            '}], ' +
            '"enterpriseId": "REPLACE_AGS_ENTERPRISE_ID", ' +
            '"Id": "a0Aq0000000LV3IEAW", ' +
            '"timestamp": 1481085396725 ' +
            '}';
        
        private static final String TEST_AGS_RESPONSE_REMOVAL_JSON =
            '{ ' +
            '"result": [{ ' +
            '"roleName": "ROLE2", ' +
            '"roleResult": { ' +
            '"requestedBy": "300000048168", ' +
            '"identityRequestStatus": "Provision", ' +
            '"workflowStatus": "executing", ' +
            '"identityRequestId": "0000463982", ' +
            '"enterpriseId": "REPLACE_AGS_ENTERPRISE_ID", ' +
            '"operation": "removeUserRole", ' +
            '"status": null ' +
            '} ' +
            '}], ' +
            '"enterpriseId": "REPLACE_AGS_ENTERPRISE_ID", ' +
            '"Id": "a0Aq0000000LV3IEAW", ' +
            '"timestamp": 1481085396725 ' +
            '}';
        
        private static final String TEST_AGS_RESPONSE_SUCCESS_JSON1 =
            '{ ' +
            '"result": [{ ' +
            '"roleName": "ROLE1", ' +
            '"roleResult": { ' +'"requestedBy": "300000048168", ' +
            '"identityRequestStatus": "Initialize", ' +
            '"workflowStatus": "approving", ' +
            '"identityRequestId": "0000463982", ' +
            '"enterpriseId": "REPLACE_AGS_ENTERPRISE_ID", ' 
            + '"operation": "assignUserRole", ' +
            '"status": null ' +
            '} ' +
            '}, ' ;
        
        private static final String TEST_AGS_RESPONSE_SUCCESS_JSON2 =                             
            '{ ' +
            '"roleName": "ROLE2", ' +
            '"roleResult": { ' ;
        
        private static final String TEST_AGS_RESPONSE_SUCCESS_JSON3 =
            + '"requestedBy": "300000048168", ' +
            '"identityRequestStatus": "Initialize", ' +
            '"workflowStatus": "approving", ' +
            '"identityRequestId": "0000463982", ' +
            '"enterpriseId": "REPLACE_AGS_ENTERPRISE_ID", ' 
            +  '"operation": "assignUserRole", ' +
            '"status": null ' +
            '} ' +
            '}], ';
        
        private static final String TEST_AGS_RESPONSE_SUCCESS_JSON4 =
            +
            '"enterpriseId": "REPLACE_AGS_ENTERPRISE_ID", ' +
            '"Id": "a0Aq0000000LV3IEAW", ' +
            '"timestamp": 1481085396725 ' +
            '}';
    

//A&E 2.0
 		  private static final String TEST_AGS_RESPONSE2_SUCCESS_JSON =
            '{ ' +
            '"result": [{ ' +
            '"roleName": "Role_3", ' +
            '"roleResult": { ' +
            '"requestedBy": "300000048168", ' +
            '"identityRequestStatus": "Initialize", ' +
            '"workflowStatus": "complete", ' +
            '"identityRequestId": "0000463982", ' +
            '"email": "REPLACE_Email_ID", ' +
            '"operation": "assignUserRole", ' +
            '"status": null ' +
            '} ' +
            '}, ' +
            '{ ' +
            '"roleName": "Role_4", ' +
            '"roleResult": { ' +
            '"requestedBy": "300000048168", ' +
            '"identityRequestStatus": "complete", ' +
            '"workflowStatus": "Role alreadyAssigned or not configured", ' +
            '"identityRequestId": "0000463982", ' +
            '"email": "REPLACE_Email_ID", ' +
            '"operation": "", ' +
            '"status": null ' +
            '} ' +
            '}, ' +
            '{ ' +
            '"roleName": "Role_6", ' +
            '"roleResult": { ' +
            '"requestedBy": "300000048168", ' +
            '"identityRequestStatus": "complete", ' +
            '"workflowStatus": "Role alreadyAssigned or not configured", ' +
            '"identityRequestId": "0000463982", ' +
            '"email": "REPLACE_Email_ID", ' +
            '"operation": "", ' +
            '"status": null ' +
            '} ' +
            '}], ' +
            '"enterpriseId": "300000062481", ' +
            '"email": "REPLACE_Email_ID", ' +
            '"Id": "a0Aq0000000LV3IEAW", ' +
            '"timestamp": 1481085396725, ' +
            '"passwordToken": "148108539", ' +
            '"EmailVerificationToken": "1481085396725", ' +
            '"error": " " ' +
            '}';
        
        private static final String TEST_AGS_RESPONSE2_MIXED_JSON =
            '{ ' +
            '"result": [{ ' +
            '"roleName": "ROLE1", ' +
            '"roleResult": { ' +
            '"Errors": [{ ' +
            '"description": "Failed to update role: ROLE1", ' +
            '"code": 400, ' +
            '"serviceCode": "UserHasPendingRoleRequest", ' +
            '"sourceSystemCode": "", ' +
            '"sourceSystemMessage": "Identity REPLACE_Email_ID already has a pending add role request: ROLE1", ' +
            '"requestId": null ' +
            '}], ' +
            '"operation": "assignUserRole", ' +
            '"status": null ' +
            '} ' +
            '}, ' +
            '{ ' +
            '"roleName": "ROLE2", ' +
            '"roleResult": { ' +
            '"requestedBy": "300000048168", ' +
            '"identityRequestStatus": "Initialize", ' +
            '"workflowStatus": "approving", ' +
            '"identityRequestId": "0000463982", ' +
            '"email": "test@gmail.com", ' +
            '"operation": "assignUserRole", ' +
            '"status": null ' +
            '} ' +
            '}, ' +
            '{ ' +
            '"roleName": "Role_3", ' +
            '"roleResult": { ' +
            '"Errors": [{ ' +
            '"description": "Failed to update role: ROLE3", ' +
            '"code": 400, ' +
            '"serviceCode": "UserHasPendingRoleRequest", ' +
            '"sourceSystemCode": "", ' +
            '"sourceSystemMessage": "unable to obtain exclusive access to this record: ROLE3", ' +
            '"requestId": null ' +
            '}], ' +
            '"operation": "assignUserRole", ' +
            '"status": null ' +
            '} ' +
            '}], ' +
            '"enterpriseId": "300000062481", ' +
            '"email": "REPLACE_Email_ID", ' +
            '"Id": "a0Aq0000000LV3IEAW", ' +
            '"timestamp": 1481085396725, ' +
            '"passwordResetToken": "148108539", ' +
            '"EmailVerificationToken": "1481085396725", ' +
            '"error": " " ' +
            '}';

        private static final String TEST_AGS_RESPONSE2_REMOVAL_JSON =
            '{ ' +
            '"result": [ ' +
            '{' +
            '"GroupName": "Group_Name_1", ' +
            '"GroupResult": { ' +
            '"status": null ' +
            '"workflowStatus": "User already member of Group" ' +
            '} ' +
            '}, ' +
            '{ ' +
            '"roleName": "ROLE2", ' +
            '"roleResult": { ' +
            '"requestedBy": "300000048168", ' +
            '"identityRequestStatus": "Provision", ' +
            '"workflowStatus": "executing", ' +
            '"identityRequestId": "0000463982", ' +
            '"email": "REPLACE_Email_ID", ' +
            '"operation": "removeUserRole", ' +
            '"status": null ' +
            '} ' +
            '}], ' +
             '"enterpriseId": "300000062481", ' +
            '"email": "REPLACE_Email_ID", ' +
            '"Id": "a0Aq0000000LV3IEAW", ' +
            '"timestamp": 1481085396725, ' +
            '"passwordResetToken": "148108539", ' +
            '"EmailVerificationToken": "1481085396725", ' +
             '"error": " " ' +
            '}';
        
        private static final String TEST_AGS_RESPONSE2_REMOVAL_JSON1 =
            '{ ' +
            '"result": [{ ' +
            '"roleName": "ROLE2", ' +
            '"roleResult": { ' +
            '"Errors": [{ ' +
            '"description": "Failed to update role: ROLE2", ' +
            '"code": 400, ' +
            '"serviceCode": "LockRowError", ' +
            '"sourceSystemCode": "", ' +
            '"sourceSystemMessage": "unable to obtain exclusive access to this record", ' +
            '"requestId": null ' +
            '}], ' +
            '"operation": "removeUserRole", ' +
            '"status": null ' +
            '} ' +
            '}], ' +
             '"enterpriseId": "300000062481", ' +
            '"email": "REPLACE_Email_ID", ' +
            '"Id": "a0Aq0000000LV3IEAW", ' +
            '"timestamp": 1481085396725, ' +
            '"passwordResetToken": "148108539", ' +
            '"EmailVerificationToken": "1481085396725", ' +
             '"error": " " ' +
            '}';
     private static final String TEST_AGS_RESPONSE2_REMOVAL_JSON1RNull =
        '{ ' +
        '"result": "" ' +
        '"enterpriseId": "300000062481", ' +
        '"email": "REPLACE_Email_ID", ' +
        '"Id": "a0Aq0000000LV3IEAW", ' +
        '"timestamp": 1481085396725, ' +
        '"passwordResetToken": "148108539", ' +
        '"EmailVerificationToken": "1481085396725", ' +
        '"error": " " ' +
        '}';
     private static final String TEST_AGS_RESPONSE2_REMOVAL_JSON1New =
        '{ ' +
        '"result": [{ ' +
        '"roleName": "ROLE2", ' +
        '"roleResult": { ' +
        '"Errors": "", ' +
        '"operation": "removeUserRole", ' +
        '"status": null ' +
        '} ' +
        '}], ' +
        '"enterpriseId": "300000062481", ' +
        '"email": "REPLACE_Email_ID", ' +
        '"Id": "a0Aq0000000LV3IEAW", ' +
        '"timestamp": 1481085396725, ' +
        '"passwordResetToken": "148108539", ' +
        '"EmailVerificationToken": "1481085396725", ' +
        '"error": " " ' +
        '}';
        
        private static final String TEST_AGS_RESPONSE2_REMOVAL_JSON11 =
            '{ ' +
            '"result": [{ ' +
            '"roleName": "ROLE2", ' +
            '"roleResult": { ' +
            '"Errors": null, ' +
            '"operation": "removeUserRole", ' +
            '"status": null ' +
            '} ' +
            '}], ' +
             '"enterpriseId": "300000062481", ' +
            '"email": "REPLACE_Email_ID", ' +
            '"Id": "a0Aq0000000LV3IEAW", ' +
            '"timestamp": 1481085396725, ' +
            '"passwordResetToken": "148108539", ' +
            '"EmailVerificationToken": "1481085396725", ' +
             '"error": " " ' +
            '}';
        
        private static final String TEST_AGS_RESPONSE2_REMOVAL_JSON12 =
            '{ ' +
            '"result": [{ ' +
            '"roleName": "ROLE2", ' +
            '"roleResult": { ' +
            '"Errors": null, ' +
            '"operation": "removeUserRole", ' +
            '"status": null ' +
            '} ' +
            '}], ' +
             '"enterpriseId": "300000062481", ' +
            '"email": "REPLACE_Email_ID", ' +
            '"Id": "a0Aq0000000LV3IEAW", ' +
            '"timestamp": 1481085396725, ' +
            '"passwordResetToken": "148108539", ' +
            '"EmailVerificationToken": "1481085396725", ' +
             '"error": "There is error"' +
            '}';
        
        private static final String TEST_AGS_RESPONSE2_SUCCESS3_JSON =
            '{ ' +
            '"result": [{ ' +
            '"roleName": "ROLE2", ' +
            '"roleResult": { ' +
            '"requestedBy": "300000048168", ' +
            '"identityRequestStatus": "Initialize", ' +
            '"workflowStatus": "Role alreadyAssigned or not configured", ' +
            '"identityRequestId": "0000463982", ' +
            '"enterpriseId": "REPLACE_AGS_ENTERPRISE_ID", ' +
            '"operation": "", ' +
            '"status": null ' +
            '} ' +
            '}], ' +
             '"enterpriseId": "300000062481", ' +
            '"email": "REPLACE_Email_ID", ' +
            '"Id": "a0Aq0000000LV3IEAW", ' +
            '"timestamp": 1481085396725, ' +
            '"passwordResetToken": "148108539", ' +
            '"EmailVerificationToken": "1481085396725", ' +
             '"error": " " ' +
            '}';
        
        private static final String TEST_AGS_RESPONSE2_SUCCESS_JSON1 =
            '{ ' +
            '"result": [{ ' +
            '"roleName": "ROLE1", ' +
            '"roleResult": { ' +'"requestedBy": "300000048168", ' +
            '"identityRequestStatus": "Initialize", ' +
            '"workflowStatus": "approving", ' +
            '"identityRequestId": "0000463982", ' +
            '"email": "REPLACE_Email_ID", ' + 
            '"operation": "assignUserRole", ' +
            '"status": null ' +
            '} ' +
            '}, ' ;
        
        private static final String TEST_AGS_RESPONSE2_SUCCESS_JSON2 =                             
            '{ ' +
            '"roleName": "ROLE2", ' +
            '"roleResult": { ' ;
        
        private static final String TEST_AGS_RESPONSE2_SUCCESS_JSON3 =
            + '"requestedBy": "300000048168", ' +
            '"identityRequestStatus": "Initialize", ' +
            '"workflowStatus": "approving", ' +
            '"identityRequestId": "0000463982", ' +
            '"email": "REPLACE_Email_ID", ' 
            +  '"operation": "assignUserRole", ' +
            '"status": null ' +
            '} ' +
            '}], '; 
        
        private static final String TEST_AGS_RESPONSE2_SUCCESS_JSON4 = 
            +
             '"enterpriseId": "300000062481", ' +
            '"email": "REPLACE_Email_ID", ' +
            '"Id": "a0Aq0000000LV3IEAW", ' + 
            '"timestamp": 1481085396725, ' +
            '"passwordResetToken": "148108539", ' +
            '"EmailVerificationToken": "1481085396725", ' +
            '"error": "ERROR" ' + 
            '}';
        
        private static final String TEST_AGS_RESPONSE_FAILED_TOO_LONG_TIME_JSON10 =
            '{ ' +
            '"result": [{ ' +
            '"roleName": "ROLE1", ' +
            '"roleResult": { ' +
            '"Errors": [{ ' +
            '"description": "Failed to update role: ROLE1", ' +
            '"code": 400, ' +
            '"serviceCode": "UserHasPendingRoleRequest", ' +
            '"sourceSystemCode": "", ' +
            '"sourceSystemMessage": "Identity REPLACE_Email_ID already has a pending add role request: ROLE1", ' +
            '"requestId": null ' +
            '}], ' +
            '"operation": "assignUserRole", ' +
            '"status": null ' +
            '} ' +
            '}, ' +
            '{ ' +
            '"roleName": "ROLE2", ' +
            '"roleResult": { ' +
            '"requestedBy": "300000048168", ' +
            '"identityRequestStatus": "Initialize", ' +
            '"workflowStatus": "approving", ' +
            '"identityRequestId": "0000463982", ' +
            '"email": "test@gmail.com", ' +
            '"operation": "assignUserRole", ' +
            '"status": null ' +
            '} ' +
            '}, ' +
            '{ ' +
            '"roleName": "Role_3", ' +
            '"roleResult": { ' +
            '"Errors": "Operation taking too long" ' +
            '"operation": "assignUserRole", ' +
            '"status": null ' +
            '} ' +
            '}], ' +
            '"enterpriseId": "300000062481", ' +
            '"email": "REPLACE_Email_ID", ' +
            '"Id": "a0Aq0000000LV3IEAW", ' +
            '"timestamp": 1481085396725, ' +
            '"passwordResetToken": "148108539", ' +
            '"EmailVerificationToken": "1481085396725", ' +
            '"error": " " ' +
            '}';
    }