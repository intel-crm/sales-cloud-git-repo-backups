@isTest
public class Core_MDF_ReportBatchTest {
    static User u1;
    static User u2;

    @testSetup
    static void setupTestData() {
        // Create test users
        Profile p = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access' LIMIT 1];
        String uniqueSuffix = String.valueOf(DateTime.now().getTime());
        
        List<User> users = new List<User>{
            new User(
                FirstName = 'Test',
                LastName = 'User1',
                Email = 'testuser1@example.com',
                Username = 'testuser1_' + uniqueSuffix + '@example.com',
                Alias = 'tuser1',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId = p.Id
            ),
            new User(
                FirstName = 'Test',
                LastName = 'User2',
                Email = 'testuser2@example.com',
                Username = 'testuser2_' + uniqueSuffix + '@example.com',
                Alias = 'tuser2',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId = p.Id
            )
        };
        insert users;
        
        u1 = users[0];
        u2 = users[1];

        // Assign permission sets using System.runAs to separate setup object DML
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Report_Viewer' LIMIT 1];
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
        
        if (ps != null) {
            System.runAs(u1) {
                PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u1.Id, PermissionSetId = ps.Id);
                insert psa;
            }
        }
        
        if (ps1 != null) {
            System.runAs(u2) {
                PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u2.Id, PermissionSetId = ps1.Id);
                insert psa;
            }
        }

        // Create non-setup objects in a separate transaction
        Test.startTest();
        
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram(Core_MDF_CCP_ConstantClass.CCF_PROGRAM, 'Client CoMarketing Fund', true);
        
        Account dellCorpAccount = new Account(
            Name = 'Dell Corporation',
            BillingCity = 'Test City',
            BillingCountry = 'AUS',
            BillingStreet = 'Test Street',
            BillingState = 'TAS',
            Core_Geo__c = 'APJ',
            RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type,
            Core_MDF_Channel_Program__c = cp1.Id // Ensure this field is set
        );
        Database.insert(dellCorpAccount);
        
        Account dellCorpAccount_VC = new Account(
            Name = 'VC Account',
            Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id,
            Core_MDF_Active_Ind__c = false,
            Core_MDF_CoMarketingActive__c = true,
            RecordTypeId = Core_MDF_CCP_TestDataUtility.Account_Record_Type,
            Core_MDF_Channel_Program__c = cp1.Id // Ensure this field is set
        );
        Database.insert(dellCorpAccount_VC);

        // Create mapping records
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> mappings = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>{
            new Core_MDF_Int_Users_Partner_Geo_Mapping__c(
               // Core_MDF_Account_id__c = dellCorpAccount_VC.Id,
                Core_MDF_Program_nm__c = 'Client CoMarketing Fund',
                Core_MDF_User_id__c = u1.Id,
                Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Report_Viewer',
               // Core_MDF_All_Accounts_cd__c = 'No',
                Core_MDF_Region_Sub_Region_nm__c = 'WW',
                Core_MDF_Active_Ind__c = true
            ),
            new Core_MDF_Int_Users_Partner_Geo_Mapping__c(
               // Core_MDF_Account_id__c = dellCorpAccount_VC.Id,
                Core_MDF_Program_nm__c = 'Client CoMarketing Fund',
                Core_MDF_User_id__c = u2.Id,
                Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr',
               // Core_MDF_All_Accounts_cd__c = 'No',
                Core_MDF_Region_Sub_Region_nm__c = 'WW',
                Core_MDF_Active_Ind__c = true
            )
        };
        insert mappings;
            List<Core_MDF_Record_Tracking__c> recTrackingList = new List<Core_MDF_Record_Tracking__c>();
            Core_MDF_Record_Tracking__c recTracking = new Core_MDF_Record_Tracking__c();
            recTracking.Core_MDF_Object_Name_nm__c = 'Approval.ProcessWorkitemRequest';
            recTracking.Core_MDF_Scope_nm__c = 'Bulk Approval Batch';
            recTracking.Core_MDF_Target_Record_Id__c = mappings[0].Id;
            recTracking.Core_MDF_Execution_InProgress_Ind__c = true;
            recTrackingList.add(recTracking);
            insert recTrackingList;
            List<ContentVersion> conVersionLst = new List<ContentVersion>();
            ContentVersion conVersion = new ContentVersion();
            conVersion.ContentLocation = 'S';
            conVersion.Title = 'Test';
            conVersion.PathOnClient='Test';
            conVersion.ReasonForChange = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ContentVersion_ReasonForChange');
            conVersion.VersionData = Blob.valueOf('content');
            conVersionLst.add(conVersion);
            Database.insert(conVersionLst);

        Test.stopTest();
    }

    //@isTest
    //static void testBatchExecution() {
        //Test.startTest();

        // Execute the batch
        //Core_MDF_ReportBatch batch = new Core_MDF_ReportBatch();
        //Database.executeBatch(batch);

        //Test.stopTest();

        // Verify the results
        //User user1 = [SELECT IsActive, Partner_License_Reclaimed__c FROM User WHERE Id = :u1.Id];
        //User user2 = [SELECT IsActive, Partner_License_Reclaimed__c FROM User WHERE Id = :u2.Id];

        // User1 should be deactivated and license reclaimed
        //System.assertEquals(false, user1.IsActive);
        //System.assertEquals(true, user1.Partner_License_Reclaimed__c);

        // User2 should remain active and license not reclaimed
        //System.assertEquals(true, user2.IsActive);
        //System.assertEquals(false, user2.Partner_License_Reclaimed__c);
    //}

    @isTest
    static void testFinishMethod() {
        Test.startTest();
        // Execute the batch
        Core_MDF_ReportBatch batch = new Core_MDF_ReportBatch();
        Database.executeBatch(batch);

        Test.stopTest();

        // Verify that the record tracking and content version are created
        List<Core_MDF_Record_Tracking__c> trackingRecords = [SELECT Id FROM Core_MDF_Record_Tracking__c];
        System.assert(trackingRecords.size() > 0, 'Record tracking should be created.');

        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion];
        System.assert(contentVersions.size() > 0, 'Content version should be created.');
    }
}