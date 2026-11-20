/*IPA2.0: US-TWC729-7976*/
@isTest
public class PSS_UtilityTest {
	 @isTest
    static void testIsWorking() {
        Boolean result = PSS_Utility.isWorking();
        System.assertEquals(true, result);
    }
    
    
    /*@isTest
    public static void getAdminTest(){
    
    	Group gp = new Group(Name = 'All Users - IPA Internal PSS Admin');
        insert gp;
        
        GroupMember gpm = new GroupMember();
        gpm.GroupId = gp.Id;
        gpm.UserOrGroupId = UserInfo.getUserId();
        Database.insert(gpm);
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u=PSS_TestDataUtility.createTestUser(profile.id,'Test','123');
        insert u;
        GroupMember gpm2 = new GroupMember();
        gpm2.GroupId = gp.Id;
        gpm2.UserOrGroupId = u.id;
        Database.insert(gpm2);
        
        //boolean isAdmin = PSS_Utility.isLoggedInUserAdmin();         
      //need to check asserts
      system.assertNotEquals(profile.id, null);
    }
    
@isTest
    public static void utilityTest(){
     Profile profileName= [Select Id from profile where Name='System Administrator']; 
        User newUser=PMP_TestDataUtility.createTestUser(profileName); 
        insert newUser;
        List<String> allowedPermissionSet=new list<String>();
        allowedPermissionSet.add('A_E_Super_Users');
        allowedPermissionSet.add('PMP_Internal_Intel_Admin');
        allowedPermissionSet.add('PMP_Internal_Intel_Admin_Read_Only');
        Set<Id> ids=new Set<Id>();
        ids.add(newUser.id);
        String fieldValue='Test,TestField,TestFieldLimit';
        Test.startTest();
        PSS_Utility.getUsersWithAssignedPermissionSet(ids,allowedPermissionSet);
        PSS_Utility.geNumberOfValuesSelected(fieldValue);
        PSS_Utility.geNumberOfValuesSelected(fieldValue, ',');
        PSS_Utility.isLoggedInUserIsIntelEmployee();
        Test.StopTest();
    }*/
 }