@isTest(SeeAllData=false)
public class Core_MDF_DateTimeformat_test {
    
    @isTest static void testGetUserDateFormat(){
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        UserRole ur = [Select Id, Name From UserRole WHERE Name = 'Admin' LIMIT 1];
        usr.UserRoleId =ur.Id ;
        usr.profileId = sysAdminProfile.Id;
        Database.insert(usr);
        System.runAs(usr){
            
            Core_MDF_DateTimeformat.getUserDateTimeFormat();
            Assert.isNotNull(Core_MDF_DateTimeformat.getUserDateFormat());
        }
    }
     @isTest static void testClientCnst(){
         // Highlight: Unused Local Variable - Indira
        // Core_MDF_client_cnst cc = new Core_MDF_client_cnst();
     }
}