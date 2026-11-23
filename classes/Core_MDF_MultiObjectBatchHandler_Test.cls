@isTest
private class Core_MDF_MultiObjectBatchHandler_Test {

    // ---------------------------------------------------------
    // Helper – Create Active User
    // ---------------------------------------------------------
    private static User createActiveUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@test.com',
            Username = 'testuser' + System.currentTimeMillis() + '@test.com',
            Alias = 'tusr',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert u;
        return u;
    }

    // ---------------------------------------------------------
    // Helper – Create Public Group
    // ---------------------------------------------------------
    private static Group createPublicGroup(String name) {
        Group g = new Group(
            Name = name,
            Type = 'Regular'
        );
        insert g;
        return g;
    }

    // ---------------------------------------------------------
    // Helper – Create Queue
    // ---------------------------------------------------------
    private static Group createQueue(String developerName) {
        Group g = new Group(
            Name = developerName,
            DeveloperName = developerName,
            Type = 'Queue'
        );
        insert g;
        return g;
    }

    // ---------------------------------------------------------
    // TEST getRoleRegionCombinations()
    // ---------------------------------------------------------
    @isTest static void test_getRoleRegionCombinations() {

        List<List<String>> fields = new List<List<String>>{
            new List<String>{'A', 'B'},
            new List<String>{'X', 'Y'}
        };

        Set<String> result =
            Core_MDF_MultiObjectBatchHandler.getRoleRegionCombinations(fields);

        System.assertEquals(4, result.size());
        System.assert(result.contains('A|X'));
        System.assert(result.contains('A|Y'));
        System.assert(result.contains('B|X'));
        System.assert(result.contains('B|Y'));
    }

    // ---------------------------------------------------------
    // TEST buildUniqueKey()
    // ---------------------------------------------------------
    @isTest static void test_buildUniqueKey() {

        List<String> input = new List<String>{' A ', null, 'B', '', 'C '};

        String key = Core_MDF_MultiObjectBatchHandler.buildUniqueKey(input);

        System.assertEquals('A|B|C', key);
    }

    // ---------------------------------------------------------
    // TEST getPublicGroupsWithActiveUsers()
    // ---------------------------------------------------------
    @isTest static void test_getPublicGroupsWithActiveUsers() {

        User u = createActiveUser();

        Group pg1 = createPublicGroup('PG1');
        Group pg2 = createPublicGroup('PG2');

        // Add user to PG1 only
        insert new GroupMember(GroupId = pg1.Id, UserOrGroupId = u.Id);

        Set<String> inputGroups = new Set<String>{'PG1', 'PG2'};

        Set<String> result =
            Core_MDF_MultiObjectBatchHandler.getPublicGroupsWithActiveUsers(inputGroups);

        System.assertEquals(1, result.size());
        System.assert(result.contains('PG1'));
    }

    // ---------------------------------------------------------
    // TEST getQueuesWithActiveUsers()
    // ---------------------------------------------------------
    @isTest static void test_getQueuesWithActiveUsers() {

        User u = createActiveUser();

        Group queue1 = createQueue('Queue_A');
        Group queue2 = createQueue('Queue_B');

        // Add active user to Queue_A
        insert new GroupMember(GroupId = queue1.Id, UserOrGroupId = u.Id);

        Set<String> queueNames = new Set<String>{'Queue_A', 'Queue_B'};

        Set<String> result =
            Core_MDF_MultiObjectBatchHandler.getQueuesWithActiveUsers(queueNames);

        System.assertEquals(1, result.size());
        System.assert(result.contains('Queue_A'));
    }

    // ---------------------------------------------------------
    // TEST prepareQueries()
    // ---------------------------------------------------------
    @isTest static void test_prepareQueries() {

        // Create Custom Metadata Record
     /*   Core_MDF_CCP_Custom_Metadata_Utility__mdt md = new Core_MDF_CCP_Custom_Metadata_Utility__mdt(
            DeveloperName = 'TestCMD',
            MasterLabel = 'TestCMD',
            Core_MDF_Category__c = 'Missed_Approver_Email_Notification',
            Core_MDF_Is_Active_Ind__c = true,
            Core_MDF_Field_1_txt__c = 'Account',
            Core_MDF_Field_5_txt__c = 'Name,Id',
            Core_MDF_Field_6_txt__c = 'CreatedDate > TODAY',
            Core_MDF_Field_7_txt__c = '{"Stage1":"RoleA"}',
            Core_MDF_Field_9_txt__c = '{"P1":"R1"}',
            Core_MDF_Field_8_txt__c = '{"ProgramA":{"Stage1":["Role1","Role2"]}}',
            Core_MDF_Field_15_txt__c = '{"ProgramA":{"US":"RoleUS"}}',
            Core_MDF_Field_16_txt__c = '{"ProgramA":{"Budget1":"Queue1"}}',
            Core_MDF_Field_12_txt__c = '{"ProgramA":{"Budget1":"PublicGroup1"}}'
        );
        insert md;*/

        Test.startTest();
        List<Core_MDF_MultiObjectBatchHandler.Core_MDF_ObjectQuery> listResult =
            Core_MDF_MultiObjectBatchHandler.prepareQueries();
        Test.stopTest();

        System.assert(listResult.size() > 0, 'Queries should be returned');
        System.assertEquals('Account', listResult[0].objectName);
    }
}