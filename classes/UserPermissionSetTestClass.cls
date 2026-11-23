@isTest
private class UserPermissionSetTestClass {

    static testmethod void testUserPermissionSetClass(){
        test.startTest();
        PermissionSet ps=new PermissionSet();
        ps.PermissionsViewAllData  = true; 
          ps.PermissionsManageUsers = true;  
            ps.PermissionsModifyAllData = true; 
             ps.PermissionsManageAuthProviders=true;
            ps.PermissionsManageInternalUsers=true;
             ps.PermissionsAuthorApex=true;
            ps.PermissionsCustomizeApplication=true;
             ps.PermissionsApiEnabled=true;
            ps.PermissionsManagePartners=true;
        UserPermissionSetClass upsc=new UserPermissionSetClass();
         UserPermissionSetClass.getCount();
        test.stopTest();
    }
}