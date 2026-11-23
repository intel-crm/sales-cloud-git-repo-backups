@isTest(SeeAllData=false) 
public class BudTranfer {
	@isTest static void validatecheckAccess(){  
        Test.startTest();
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='IT Admin' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_User'];
		insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);

        System.runAs(usr){
            System.debug('a'+Core_MDF_BudgetTransfer.checkAccess());
            //System.assertEquals(false, Core_MDF_BudgetTransfer.checkAccess());
            
        }
        Test.stopTest();
    }
}