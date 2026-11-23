@isTest
private class TestGPT {

    @isTest(SeeAllData=false) 
     static void testCheckAccess() {
        // Query the profile with name 'IT Admin'
        Profile p = [SELECT Id,UserLicense.name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        system.debug(p.UserLicense.name);
        // Create a user with the required permission sets and profile
        User u = new User(Alias = 'test1', Email='testamal@intel.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='testamal@amaltv.com',
            ProfileId=p.Id);
        insert u;
        
         
        
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        for (String psName : Label.Core_MDF_Budget_Transfer_Access.split(';')) {
            if(!psName.contains('External')){ 
            system.debug(psname);
            PermissionSet ps = [SELECT Id,License.name FROM PermissionSet WHERE Name = :psName LIMIT 1];
            
            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId=u.Id,
                PermissionSetId=ps.Id
            );
            psaList.add(psa);
            }
        }
        insert psaList;
        
        // Test checkAccess method with valid user
        System.runAs(u) {
            Boolean hasAccess = Core_MDF_BudgetTransfer.checkAccess();
            System.assertEquals(true, hasAccess);
        }
        
        // Test checkAccess method with invalid user
        User u2 = new User(Alias = 'test2', Email='testamal1@intel.com',
            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='testamal1@amaltv1.com',ProfileId=p.Id);
        insert u2;
        
        System.runAs(u2) {
            Boolean hasAccess = Core_MDF_BudgetTransfer.checkAccess();
            System.assertEquals(false, hasAccess);
        }
    }

}