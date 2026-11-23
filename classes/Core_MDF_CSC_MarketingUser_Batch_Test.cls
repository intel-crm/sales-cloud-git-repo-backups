@isTest
public class Core_MDF_CSC_MarketingUser_Batch_Test {
	@TestSetup
    static void createTestData(){
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false); 
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        testUser.LastName='Admin_user';
        testUser.UserRoleId = usRole.Id;
        insert testUser;
        System.runAs(testUser){
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            User user1 = Core_MDF_CCP_TestDataUtility.createUser(false);       
            user1.LastName = 'Test CSC User';
            user1.UserPermissionsMarketingUser= false ;
            insert user1;
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            PermissionSet cscPS = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_CSC_User' LIMIT 1];
            psaList.add(new PermissionSetAssignment(AssigneeId = user1.id, PermissionSetId = cscPS.Id));
            insert psaList;
        }
        
        
    }
    @isTest
    static Void testBatchMethod(){
         User usr=[Select id,LastName  from User where LastName ='Admin_user' Limit 1];
        system.runAs(usr){
         Map<Id,List<string>> usrIdToErrorsMap = new Map<Id,List<string>>();
            List<String> errList = new List<String>();
            errList.add('TestError');
         User cscUsr=[Select id,LastName  from User where LastName ='Test CSC User' Limit 1];
        usrIdToErrorsMap.put(cscUsr.id,errList);
         Core_MDF_CSC_MarketingUser_Batch.createLogEntry(usrIdToErrorsMap);
        Core_MDF_CSC_MarketingUser_Batch cscbtach = new Core_MDF_CSC_MarketingUser_Batch();
        Id jobId = Database.executeBatch(cscbtach);
        Assert.isNotNull(jobId);
        }
       
    }
    
}