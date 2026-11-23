@isTest
public class Core_ACM_PayloadWrapper_Test {
    
    @isTest
    static void testCore_ACM_PayloadWrapperConstructor() {
        // Test the main wrapper constructor
        Test.startTest();
        Core_ACM_PayloadWrapper wrapper = new Core_ACM_PayloadWrapper();
        Test.stopTest();
        
        // Verify default values are set correctly
        System.assertNotEquals(null, wrapper.PersonAccountProfile, 'PersonAccountProfile should be initialized');
        System.assertEquals(Core_ACM_Constants.CHANGE_AGENT, wrapper.ChangeAgent, 'ChangeAgent should be set from constants');
        System.assertEquals(true, wrapper.blnPublish, 'blnPublish should be true by default');
        System.assertEquals(true, wrapper.blnNotify, 'blnNotify should be true by default');
        System.assertEquals(Core_ACM_Constants.CHANGE_AGENT_LOGIN_ID, wrapper.ChgAgtLoginId, 'ChgAgtLoginId should be set from constants');
    }
    
    @isTest
    static void testPersonAccountProfileConstructor() {
        // Test PersonAccountProfile constructor
        Test.startTest();
        Core_ACM_PayloadWrapper.PersonAccountProfile profile = new Core_ACM_PayloadWrapper.PersonAccountProfile();
        Test.stopTest();
        
        // Verify lists are initialized
        System.assertNotEquals(null, profile.Subscriptions, 'Subscriptions list should be initialized');
        System.assertNotEquals(null, profile.PersonPhysicalAddresses, 'PersonPhysicalAddresses list should be initialized');
        System.assertNotEquals(null, profile.PersonElectronicAddresses, 'PersonElectronicAddresses list should be initialized');
        System.assertNotEquals(null, profile.Memberships, 'Memberships list should be initialized');
        System.assertNotEquals(null, profile.ExternalAttributes, 'ExternalAttributes should be initialized');
        
        // Verify lists are empty initially
        System.assertEquals(0, profile.Subscriptions.size(), 'Subscriptions list should be empty initially');
        System.assertEquals(0, profile.PersonPhysicalAddresses.size(), 'PersonPhysicalAddresses list should be empty initially');
        System.assertEquals(0, profile.PersonElectronicAddresses.size(), 'PersonElectronicAddresses list should be empty initially');
        System.assertEquals(0, profile.Memberships.size(), 'Memberships list should be empty initially');
    }
    
    @isTest
    static void testPersonAccountProfileProperties() {
        // Test PersonAccountProfile property setters and getters
        Core_ACM_PayloadWrapper.PersonAccountProfile profile = new Core_ACM_PayloadWrapper.PersonAccountProfile();
        
        Test.startTest();
        // Set properties
        profile.PersonID = 'TEST123';
        profile.FirstName = 'John';
        profile.LastName = 'Doe';
        profile.EmailID = 'john.doe@test.com';
        profile.EnterpriseID = 'ENT123';
        profile.LoginID = 'jdoe';
        profile.CountryCode = 'US';
        profile.LanguageCode = 'EN';
        profile.JobFunction = 'Developer';
        profile.PersonTitle = 'Mr.';
        profile.PersonRegistrationTypeCode = 'INTEL';
        profile.DoNotContactFlag = 'N';
        profile.SalesDoNotContactFlag = 'N';
        profile.EnglishFirstName = 'John';
        profile.EnglishLastName = 'Doe';
        Test.stopTest();
        
        // Verify properties are set correctly
        System.assertEquals('TEST123', profile.PersonID, 'PersonID should be set correctly');
        System.assertEquals('John', profile.FirstName, 'FirstName should be set correctly');
        System.assertEquals('Doe', profile.LastName, 'LastName should be set correctly');
        System.assertEquals('john.doe@test.com', profile.EmailID, 'EmailID should be set correctly');
        System.assertEquals('ENT123', profile.EnterpriseID, 'EnterpriseID should be set correctly');
        System.assertEquals('jdoe', profile.LoginID, 'LoginID should be set correctly');
        System.assertEquals('US', profile.CountryCode, 'CountryCode should be set correctly');
        System.assertEquals('EN', profile.LanguageCode, 'LanguageCode should be set correctly');
        System.assertEquals('Developer', profile.JobFunction, 'JobFunction should be set correctly');
        System.assertEquals('Mr.', profile.PersonTitle, 'PersonTitle should be set correctly');
        System.assertEquals('INTEL', profile.PersonRegistrationTypeCode, 'PersonRegistrationTypeCode should be set correctly');
        System.assertEquals('N', profile.DoNotContactFlag, 'DoNotContactFlag should be set correctly');
        System.assertEquals('N', profile.SalesDoNotContactFlag, 'SalesDoNotContactFlag should be set correctly');
        System.assertEquals('John', profile.EnglishFirstName, 'EnglishFirstName should be set correctly');
        System.assertEquals('Doe', profile.EnglishLastName, 'EnglishLastName should be set correctly');
    }
    
    @isTest
    static void testSubscriptionClass() {
        // Test Subscription class
        Test.startTest();
        Core_ACM_PayloadWrapper.Subscription subscription = new Core_ACM_PayloadWrapper.Subscription();
        subscription.SubscriptionCode = 'SUB001';
        subscription.SubscriptionName = 'Test Subscription';
        subscription.SubscriptionStatusCode = 'ACTIVE';
        subscription.UnSubscriptionReason = 'User Request';
        Test.stopTest();
        
        // Verify properties
        System.assertEquals('SUB001', subscription.SubscriptionCode, 'SubscriptionCode should be set correctly');
        System.assertEquals('Test Subscription', subscription.SubscriptionName, 'SubscriptionName should be set correctly');
        System.assertEquals('ACTIVE', subscription.SubscriptionStatusCode, 'SubscriptionStatusCode should be set correctly');
        System.assertEquals('User Request', subscription.UnSubscriptionReason, 'UnSubscriptionReason should be set correctly');
    }
    
    @isTest
    static void testPersonPhysicalAddressClass() {
        // Test PersonPhysicalAddress class
        Test.startTest();
        Core_ACM_PayloadWrapper.PersonPhysicalAddress address = new Core_ACM_PayloadWrapper.PersonPhysicalAddress();
        address.AddressLine1 = '123 Main St';
        address.City = 'Anytown';
        address.State = 'CA';
        address.PostalCode = '12345';
        address.CountryCode = 'US';
        Test.stopTest();
        
        // Verify properties
        System.assertEquals('123 Main St', address.AddressLine1, 'AddressLine1 should be set correctly');
        System.assertEquals('Anytown', address.City, 'City should be set correctly');
        System.assertEquals('CA', address.State, 'State should be set correctly');
        System.assertEquals('12345', address.PostalCode, 'PostalCode should be set correctly');
        System.assertEquals('US', address.CountryCode, 'CountryCode should be set correctly');
    }
    
    @isTest
    static void testPersonElectronicAddressConstructor() {
        // Test PersonElectronicAddress constructor
        Test.startTest();
        Core_ACM_PayloadWrapper.PersonElectronicAddress electronicAddress = 
            new Core_ACM_PayloadWrapper.PersonElectronicAddress('EMAIL', 'test@example.com');
        Test.stopTest();
        
        // Verify constructor sets values correctly
        System.assertEquals('EMAIL', electronicAddress.ElectronicAddressType, 'ElectronicAddressType should be set from constructor');
        System.assertEquals('test@example.com', electronicAddress.ElectronicAddressText, 'ElectronicAddressText should be set from constructor');
        System.assertEquals(Core_ACM_Constants.LOCATION_TYPE_HOME, electronicAddress.LocationType, 'LocationType should be set from constants');
    }
    
    @isTest
    static void testMembershipConstructor() {
        // Test Membership constructor
        Test.startTest();
        Core_ACM_PayloadWrapper.Membership membership = 
            new Core_ACM_PayloadWrapper.Membership('ENG001', 'APPROVED');
        Test.stopTest();
        
        // Verify constructor sets values correctly
        System.assertEquals('ENG001', membership.EngagementCode, 'EngagementCode should be set from constructor');
        System.assertEquals('APPROVED', membership.EnggStatus, 'EnggStatus should be set from constructor');
    }
    
    @isTest
    static void testExternalAttributesClass() {
        // Test ExternalAttributes class
        Test.startTest();
        Core_ACM_PayloadWrapper.ExternalAttributes extAttributes = new Core_ACM_PayloadWrapper.ExternalAttributes();
        extAttributes.ProfessionCode = 'DEV';
        Test.stopTest();
        
        // Verify property
        System.assertEquals('DEV', extAttributes.ProfessionCode, 'ProfessionCode should be set correctly');
    }
    
    @isTest
    static void testResponseWrapperClass() {
        // Test ResponseWrapper class
        Test.startTest();
        Core_ACM_PayloadWrapper.ResponseWrapper response = new Core_ACM_PayloadWrapper.ResponseWrapper();
        response.Status = 'Success';
        response.ErrorCode = 'ERR001';
        response.ErrorType = 'Validation';
        response.ErrorText = 'Test Error';
        response.ErrorDetails = 'Detailed error message';
        response.PersonID = 'PER123';
        response.EnterpriseID = 'ENT123';
        response.EmailID = 'test@example.com';
        Test.stopTest();
        
        // Verify properties
        System.assertEquals('Success', response.Status, 'Status should be set correctly');
        System.assertEquals('ERR001', response.ErrorCode, 'ErrorCode should be set correctly');
        System.assertEquals('Validation', response.ErrorType, 'ErrorType should be set correctly');
        System.assertEquals('Test Error', response.ErrorText, 'ErrorText should be set correctly');
        System.assertEquals('Detailed error message', response.ErrorDetails, 'ErrorDetails should be set correctly');
        System.assertEquals('PER123', response.PersonID, 'PersonID should be set correctly');
        System.assertEquals('ENT123', response.EnterpriseID, 'EnterpriseID should be set correctly');
        System.assertEquals('test@example.com', response.EmailID, 'EmailID should be set correctly');
    }
    
    @isTest
    static void testAGSOutboundPayloadConstructor() {
        // Test AGSOutboundPayload constructor (Ganesh Changes)
        Test.startTest();
        Core_ACM_PayloadWrapper.AGSOutboundPayload agsPayload = 
            new Core_ACM_PayloadWrapper.AGSOutboundPayload(
                'ENT123',
                'Test Justification',
                'John',
                'Doe',
                'john.doe@test.com',
                'EN',
                'US',
                '+1',
                '1234567890'
            );
        Test.stopTest();
        
        // Verify constructor sets values correctly
        System.assertEquals('ENT123', agsPayload.enterpriseId, 'enterpriseId should be set from constructor');
        System.assertEquals('Test Justification', agsPayload.justification, 'justification should be set from constructor');
        System.assertEquals('John', agsPayload.firstName, 'firstName should be set from constructor');
        System.assertEquals('Doe', agsPayload.lastName, 'lastName should be set from constructor');
        System.assertEquals('john.doe@test.com', agsPayload.email, 'email should be set from constructor');
        System.assertEquals('EN', agsPayload.language, 'language should be set from constructor');
        System.assertEquals('US', agsPayload.country, 'country should be set from constructor');
        System.assertEquals('+1', agsPayload.phonePrefix, 'phonePrefix should be set from constructor');
        System.assertEquals('1234567890', agsPayload.phone, 'phone should be set from constructor');
        
        // Verify lists are initialized
        System.assertNotEquals(null, agsPayload.InProgressRoles, 'InProgressRoles should be initialized');
        System.assertNotEquals(null, agsPayload.pendingRoles, 'pendingRoles should be initialized');
        System.assertNotEquals(null, agsPayload.roleRequests, 'roleRequests should be initialized');
        
        // Verify lists are empty initially
        System.assertEquals(0, agsPayload.InProgressRoles.size(), 'InProgressRoles should be empty initially');
        System.assertEquals(0, agsPayload.pendingRoles.size(), 'pendingRoles should be empty initially');
        System.assertEquals(0, agsPayload.roleRequests.size(), 'roleRequests should be empty initially');
    }
    
    @isTest
    static void testPendingRoleConstructor() {
        // Test PendingRole constructor (Ganesh Changes)
        Test.startTest();
        Core_ACM_PayloadWrapper.PendingRole pendingRole = 
            new Core_ACM_PayloadWrapper.PendingRole('Admin', 'System', 'ADD');
        Test.stopTest();
        
        // Verify constructor sets values correctly
        System.assertEquals('Admin', pendingRole.RoleName, 'RoleName should be set from constructor');
        System.assertEquals('System', pendingRole.RoleType, 'RoleType should be set from constructor');
        System.assertEquals('ADD', pendingRole.RoleOperation, 'RoleOperation should be set from constructor');
    }
    
    @isTest
    static void testRoleRequestConstructor() {
        // Test RoleRequest constructor (Ganesh Changes)
        Test.startTest();
        Core_ACM_PayloadWrapper.RoleRequest roleRequest = 
            new Core_ACM_PayloadWrapper.RoleRequest('User', 'Application');
        Test.stopTest();
        
        // Verify constructor sets values correctly
        System.assertEquals('User', roleRequest.RoleName, 'RoleName should be set from constructor');
        System.assertEquals('Application', roleRequest.RoleType, 'RoleType should be set from constructor');
    }
    
    @isTest
    static void testCompletePayloadWrapperWithData() {
        // Test complete payload wrapper with all data populated
        Test.startTest();
        Core_ACM_PayloadWrapper wrapper = new Core_ACM_PayloadWrapper();
        
        // Populate PersonAccountProfile
        wrapper.PersonAccountProfile.PersonID = 'TEST123';
        wrapper.PersonAccountProfile.FirstName = 'John';
        wrapper.PersonAccountProfile.LastName = 'Doe';
        wrapper.PersonAccountProfile.EmailID = 'john.doe@test.com';
        
        // Add subscription
        Core_ACM_PayloadWrapper.Subscription sub = new Core_ACM_PayloadWrapper.Subscription();
        sub.SubscriptionCode = 'SUB001';
        wrapper.PersonAccountProfile.Subscriptions.add(sub);
        
        // Add electronic address
        Core_ACM_PayloadWrapper.PersonElectronicAddress emailAddr = 
            new Core_ACM_PayloadWrapper.PersonElectronicAddress('EMAIL', 'john.doe@test.com');
        wrapper.PersonAccountProfile.PersonElectronicAddresses.add(emailAddr);
        
        // Add membership
        Core_ACM_PayloadWrapper.Membership membership = 
            new Core_ACM_PayloadWrapper.Membership('ENG001', 'APPROVED');
        wrapper.PersonAccountProfile.Memberships.add(membership);
        
        Test.stopTest();
        
        // Verify data is populated correctly
        System.assertEquals('TEST123', wrapper.PersonAccountProfile.PersonID, 'PersonID should be populated');
        System.assertEquals(1, wrapper.PersonAccountProfile.Subscriptions.size(), 'Should have one subscription');
        System.assertEquals(1, wrapper.PersonAccountProfile.PersonElectronicAddresses.size(), 'Should have one electronic address');
        System.assertEquals(1, wrapper.PersonAccountProfile.Memberships.size(), 'Should have one membership');
        System.assertEquals('SUB001', wrapper.PersonAccountProfile.Subscriptions[0].SubscriptionCode, 'Subscription code should match');
        System.assertEquals('EMAIL', wrapper.PersonAccountProfile.PersonElectronicAddresses[0].ElectronicAddressType, 'Electronic address type should match');
        System.assertEquals('ENG001', wrapper.PersonAccountProfile.Memberships[0].EngagementCode, 'Engagement code should match');
    }
    
    @isTest
    static void testDateTimeProperties() {
        // Test DateTime properties
        Core_ACM_PayloadWrapper.PersonAccountProfile profile = new Core_ACM_PayloadWrapper.PersonAccountProfile();
        DateTime testDate = DateTime.now();
        
        Test.startTest();
        profile.SalesDoNotContactDate = testDate;
        profile.AllIntelDoNotContactDate = testDate;
        Test.stopTest();
        
        // Verify DateTime properties
        System.assertEquals(testDate, profile.SalesDoNotContactDate, 'SalesDoNotContactDate should be set correctly');
        System.assertEquals(testDate, profile.AllIntelDoNotContactDate, 'AllIntelDoNotContactDate should be set correctly');
    }
}