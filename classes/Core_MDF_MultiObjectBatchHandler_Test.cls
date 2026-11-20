@isTest
private class Core_MDF_MultiObjectBatchHandler_Test {
    
    @testSetup
    static void setupData() {
        
        
        // We will simulate metadata using a custom SObject for test (works since no org CMD dependency)
        Core_MDF_CCP_Custom_Metadata_Utility__c setting = new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Core_MDF_Category__c = 'Missed_Approver_Email_Notification',
            Core_MDF_Is_Active_Ind__c = true,
            Core_MDF_Field_1_txt__c = 'PartnerFundRequest',
            Core_MDF_Field_6_txt__c = 'Core_MDF_Approval_Stage__c = \'Draft\'',
            
            Core_MDF_Field_5_txt__c = 'Id,Name,Amount',
            
            Core_MDF_Field_7_txt__c = '{"Draft":"ABC_Role","Pending Approval":"XYZ_Role"}',
            
            Core_MDF_Field_9_txt__c = '{"Submitted":"Partner_Role"}',
            
            Core_MDF_Field_8_txt__c = '{"PMN Program":{"Draft":["Role1","Role2"],"Pending Approval":["Role3"]}}',
            
            Core_MDF_Field_15_txt__c = '{"ProgramA":{"APAC":"APAC_Role","EU":"EU_Role"}}',
            
            Core_MDF_Field_16_txt__c = '{"ProgramA":{"Capex":"Queue1","Opex":"Queue2"}}',
            
            Core_MDF_Field_12_txt__c = '{"ProgramA":{"Capex":"PublicGroup1","Opex":"PublicGroup2"}}'
        );
        insert setting;
    }
    @isTest
    static void testPrepareQueries() {
        
        Test.startTest();
        
        List<Core_MDF_MultiObjectBatchHandler.Core_MDF_ObjectQuery> result =
            Core_MDF_MultiObjectBatchHandler.prepareQueries();
        
        Test.stopTest();
        
        System.assertEquals(1, result.size(), 'Should return one ObjectQuery');
        
        Core_MDF_MultiObjectBatchHandler.Core_MDF_ObjectQuery q = result[0];
        
        
        System.assertEquals('PartnerFundRequest', q.objectName);
        
        System.assertEquals('Core_MDF_Approval_Stage__c = \'Draft\'', q.queryCondition);
        
        // Assert fields list
        System.assertEquals(3, q.fields.size());
        System.assertEquals('Id', q.fields[0]);
        System.assertEquals('Name', q.fields[1]);
        System.assertEquals('Amount', q.fields[2]);
        
        // Assert approval stage map
        System.assertEquals('ABC_Role', q.mapOfApprovalStageToRole.get('Draft'));
        System.assertEquals('XYZ_Role', q.mapOfApprovalStageToRole.get('Pending Approval'));
        
        // Assert PNUM map
        System.assertEquals('Partner_Role', q.mapOfPnumApprovalStageToRole.get('Submitted'));
        
        // Assert program to stage roles
        System.assert(q.mapOfProgramToApprovalStageToRolesList.containsKey('PMN Program'));
        System.assertEquals(2, q.mapOfProgramToApprovalStageToRolesList.get('PMN Program').get('Draft').size());
        
        // Assert Geo role mapping
        System.assert(q.mapOfProgramToGeoBasedToRole.containsKey('ProgramA'));
        System.assertEquals('APAC_Role', q.mapOfProgramToGeoBasedToRole.get('ProgramA').get('APAC'));
        
        // Assert BudgetType to Queue Mapping
        System.assertEquals('Queue1', q.mapOfProgramToBudgetTypeToQueue.get('ProgramA').get('Capex'));
        
        // Assert BudgetType to Public Group Mapping
        //  System.assertEquals('PublicGroup1', q.mapOfPrgmTOBudgetTypeTOPublicGrp.get('ProgramA').get('Capex'));
    }
    @isTest
    static void testStandardCombination() {
        
        List<List<String>> input = new List<List<String>>{
            new List<String>{'AMER','EMEA'},
                new List<String>{'Admin','Finance'}
        };
            
            Set<String> result = Core_MDF_MultiObjectBatchHandler.getRoleRegionCombinations(input);
        
        System.assert(!result.isEmpty(), 'Result must not be empty');
    }
    @isTest
    static void testBuildUniqueKey() {
        System.assertEquals('AMER|Manager|NW',
                            Core_MDF_MultiObjectBatchHandler.buildUniqueKey(
                                new List<String>{' AMER ','Manager',' NW '}
                            ));
        
        System.assertEquals('Finance|EMEA',
                            Core_MDF_MultiObjectBatchHandler.buildUniqueKey(
                                new List<String>{null,' ', '', 'Finance',' EMEA '}
                            ));
        
        System.assertEquals('',
                            Core_MDF_MultiObjectBatchHandler.buildUniqueKey(
                                new List<String>{null,' ', ''}
                            ));
    }
    @isTest
    static void testGetPublicGroupsWithActiveUsers() {
        
        UserRole usRole = [SELECT Id, Name FROM UserRole where Name = 'Admin' LIMIT 50000];
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'Sys Admin';
        testUser.UserRoleId = usRole.Id;
        testUser.IsActive=true;
        insert testUser;
        
        // Create public group
        Group g = new Group(Name = 'FinanceGroup', Type = 'Regular');
        insert g;
        
        // Add user to public group
        GroupMember gm = new GroupMember(GroupId = g.Id, UserOrGroupId = testUser.Id);
        insert gm;
        
        // Input set
        Set<String> inputGroups = new Set<String>{ 'FinanceGroup' };
            
            // Call method
            Set<String> result = Core_MDF_MultiObjectBatchHandler.getPublicGroupsWithActiveUsers(inputGroups);
        
        // Validate
        System.assertEquals(true, result.contains('FinanceGroup'));
    }
    @isTest
    static void test_getQueuesWithActiveUsers() {
        
        UserRole usRole = [SELECT Id, Name FROM UserRole where Name = 'Admin' LIMIT 50000];
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'Sys Admin';
        testUser.UserRoleId = usRole.Id;
        testUser.IsActive=true;
        insert testUser;
        
        // Create Queue (Group)
        Group q = new Group(
            Name = 'TestQueue',
            DeveloperName = 'TestQueue',
            Type = 'Queue'
        );
        insert q;
        
        // Add user to queue
        insert new GroupMember(
            GroupId = q.Id,
            UserOrGroupId = testUser.Id
        );
        
        // Test
        Set<String> input = new Set<String>{ 'TestQueue' };
            Set<String> result = Core_MDF_MultiObjectBatchHandler.getQueuesWithActiveUsers(input);
        
        System.assertEquals(true, result.contains('TestQueue'));
    }
}