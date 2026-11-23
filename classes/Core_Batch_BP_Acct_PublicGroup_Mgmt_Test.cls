@isTest
private class Core_Batch_BP_Acct_PublicGroup_Mgmt_Test {
    
    private static final String TARGET_PUBLIC_GROUP = 'ER_cmfGroup';
    private static final String PERMISSION_SET_1 = 'ER_Search_to_CMF_Admin';
    private static final String PERMISSION_SET_2 = 'ER_Search_to_CMF_Read_Only';
    
    @TestSetup
    static void setupTestData() {
        // Create test users
        List<User> testUsers = new List<User>();
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        for (Integer i = 0; i < 5; i++) {
            User testUser = new User(
                FirstName = 'Test',
                LastName = 'User' + i,
                Email = 'testuser' + i + '@example.com',
                Username = 'testuser' + i + '@test.com.test',
                Alias = 'tuser' + i,
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId = standardProfile.Id,
                IsActive = true
            );
            testUsers.add(testUser);
        }
        insert testUsers;
        
        // Create public group
        Group publicGroup;
        List<Group> existingGroups = [SELECT Id FROM Group WHERE DeveloperName = :TARGET_PUBLIC_GROUP LIMIT 1];
        if (existingGroups.isEmpty()) {
            publicGroup = new Group(
                Name = 'ER CMF Group',
                DeveloperName = TARGET_PUBLIC_GROUP,
                Type = 'Regular'
            );
            insert publicGroup;
        } else {
            publicGroup = existingGroups[0];
        }
        
        // Create permission sets
        String testPS1Name = 'Test_PS_Admin';
        String testPS2Name = 'Test_PS_ReadOnly';
        
        List<PermissionSet> psToInsert = new List<PermissionSet>();
        PermissionSet ps1 = new PermissionSet(
            Name = testPS1Name,
            Label = 'Test ER Search CMF Admin '
        );
        PermissionSet ps2 = new PermissionSet(
            Name = testPS2Name,
            Label = 'Test ER Search CMF Read Only '
        );
        psToInsert.add(ps1);
        psToInsert.add(ps2);
        
        insert psToInsert;
        
        // Assign permission sets to some users
        List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
        psAssignments.add(new PermissionSetAssignment(
            AssigneeId = testUsers[0].Id,
            PermissionSetId = ps1.Id
        ));
        psAssignments.add(new PermissionSetAssignment(
            AssigneeId = testUsers[1].Id,
            PermissionSetId = ps2.Id
        ));
        psAssignments.add(new PermissionSetAssignment(
            AssigneeId = testUsers[2].Id,
            PermissionSetId = ps1.Id
        ));
        insert psAssignments;
        
        // Add some users to the group initially
        List<GroupMember> groupMembers = new List<GroupMember>();
        groupMembers.add(new GroupMember(
            GroupId = publicGroup.Id,
            UserOrGroupId = testUsers[0].Id
        ));
        groupMembers.add(new GroupMember(
            GroupId = publicGroup.Id,
            UserOrGroupId = testUsers[3].Id // User without permission set
        ));
        insert groupMembers;
    }
    
    @isTest
    static void testDefaultConstructor() {
        Test.startTest();
        Core_Batch_BP_Acct_PublicGroup_Mgmt batch = new Core_Batch_BP_Acct_PublicGroup_Mgmt();
        Test.stopTest();
    }
    
    @isTest
    static void testParameterizedConstructor() {
        Test.startTest();
        Core_Batch_BP_Acct_PublicGroup_Mgmt batch = new Core_Batch_BP_Acct_PublicGroup_Mgmt(true);
        Test.stopTest();
    }
    
    @isTest
    static void testAddUsersOperation() {
        Test.startTest();
        Core_Batch_BP_Acct_PublicGroup_Mgmt batch = new Core_Batch_BP_Acct_PublicGroup_Mgmt(false);
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Verify users with permission sets are added to the group
        List<User> testUsers = [SELECT Id FROM User WHERE Email LIKE 'testuser%@@example.com'];
        Group publicGroup = [SELECT Id FROM Group WHERE DeveloperName = :TARGET_PUBLIC_GROUP];
        
        List<GroupMember> groupMembers = [
            SELECT UserOrGroupId 
            FROM GroupMember 
            WHERE GroupId = :publicGroup.Id
            AND UserOrGroupId IN :testUsers
        ];
    }

    @isTest
    static void testRemoveUsersOperation() {
        Group publicGroup = [SELECT Id FROM Group WHERE DeveloperName = :TARGET_PUBLIC_GROUP LIMIT 1];
        List<User> testUsers = [SELECT Id FROM User WHERE Username LIKE 'testuser%@test.com.test'];

        Test.startTest();
        Core_Batch_BP_Acct_PublicGroup_Mgmt batch = new Core_Batch_BP_Acct_PublicGroup_Mgmt(true);
        Database.executeBatch(batch);
        Test.stopTest();

        List<GroupMember> remainingGroupMembers = [
            SELECT Id, UserOrGroupId
            FROM GroupMember
            WHERE GroupId = :publicGroup.Id
            AND UserOrGroupId IN :testUsers
        ];

        System.assertEquals(0, remainingGroupMembers.size(), 'All test users should be removed from the target public group when they do not have target permission sets.');
    }
}