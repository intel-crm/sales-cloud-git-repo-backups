@isTest
public class Pricing_SW_RoleMappingTest {
   
    @isTest
    static void testInvalidUserId() {
        Pricing_SW_RoleMapping.InputVariables input = new Pricing_SW_RoleMapping.InputVariables();
        input.userId = 'invalidUserId'; 
        input.roleName = 'Software CPQ User';

        Test.startTest();
        List<Pricing_SW_RoleMapping.Response> responses = Pricing_SW_RoleMapping.assignPermissionsAndGroups(new List<Pricing_SW_RoleMapping.InputVariables>{ input });
        Test.stopTest();

        System.assertEquals(1, responses.size());
        System.assert(responses[0].message.contains('User ID "invalidUserId" is not valid.'));
    }
    @isTest
    static void testPermissionSetPublicGroup() {
         User user = Pricing_SW_UtilityTest.createUser('SWUser', 'testuser@intel.com', 'User1');
         Pricing_SW_RoleMapping.InputVariables input = new Pricing_SW_RoleMapping.InputVariables();
         input.userId = user.Id; 
         input.roleName = 'Software CPQ User';
    
         Test.startTest();
         List<Pricing_SW_RoleMapping.Response> responses = Pricing_SW_RoleMapping.assignPermissionsAndGroups(new List<Pricing_SW_RoleMapping.InputVariables>{ input });
         Test.stopTest();
    
   
         System.assertEquals(1, responses.size());
         System.assert(responses[0].message.contains('Permission Set is assigned successfully.'));
     }

}