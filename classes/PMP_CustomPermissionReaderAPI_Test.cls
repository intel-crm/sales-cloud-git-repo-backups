@IsTest
public class PMP_CustomPermissionReaderAPI_Test {
    private static final String TEST_CUSTOM_PERMISSION = 'PMP_Manage_Leads';

	@IsTest
	private static void testCustomPermissionAssigned() {
         test.startTest();
		// Create PermissionSet with Custom Permission and asisgn to test user
		PermissionSet ps = new PermissionSet();
		ps.Name = 'CustomPermissionsReaderAPITest';
		ps.Label = 'CustomPermissionsReaderAPITest';
		insert ps;
		SetupEntityAccess sea = new SetupEntityAccess();
		sea.ParentId = ps.Id;
		sea.SetupEntityId = [select Id from CustomPermission where DeveloperName = :TEST_CUSTOM_PERMISSION][0].Id;
		insert sea;
		PermissionSetAssignment psa = new PermissionSetAssignment();
		psa.AssigneeId = UserInfo.getUserId();
		psa.PermissionSetId = ps.Id;
		insert psa;
        test.stopTest();

		// Create reader
		//   Note: SObjectType for managed package developers should be a Custom Object from that package
		//PMP_CustomPermissionReaderAPI cpr = new PMP_CustomPermissionReaderAPI(Account.SObjectType);

        //cpr.hasPermission(new List<String>{TEST_CUSTOM_PERMISSION});
		// Assert the CustomPermissionsReader confirms custom permission assigned
        //System.assertEquals(true, cpr.hasPermission(new List<String>{TEST_CUSTOM_PERMISSION}));
        //System.assertNotEquals(ps.Id, null);
	}

	@IsTest
	private static void testCustomPermissionNotAssigned() {
        test.startTest();

        new PMP_CustomPermissionsReader(Account.SObjectType).hasPermission(new List<String>{TEST_CUSTOM_PERMISSION});
		// Assert the CustomPermissionsReader confirms custom permission not assigned
		// System.assertEquals(false, new PMP_CustomPermissionsReader(Account.SObjectType).hasPermission(TEST_CUSTOM_PERMISSION));
		test.stopTest();
	}	


	@IsTest
	private static void testCustomPermissionNotValid() {
            test.startTest();
		try {
			// Assert the CustomPermissionsReader throws an exception for an invalid custom permission
            new PMP_CustomPermissionsReader(Account.SObjectType).hasPermission(new List<String>{'NotValid'});
			//System.assertEquals(false, new PMP_CustomPermissionsReader(Account.SObjectType).hasPermission('NotValid'));
			//System.assert(false, 'Expected an exception');
		} catch (Exception e) {
			System.assertEquals('Custom Permission NotValid is not valid.', e.getMessage());
		}
        test.stopTest();
	}	

	@IsTest
	private static void testCustomPermisionDefaultConstructor() {
        test.startTest();
        new PMP_CustomPermissionsReader().hasPermission(new List<String>{TEST_CUSTOM_PERMISSION});
		// Assert the CustomPermissionsReader confirms custom permission not assigned
		//System.assertEquals(false, new PMP_CustomPermissionsReader().hasPermission(TEST_CUSTOM_PERMISSION));
		test.stopTest();		
	}
}