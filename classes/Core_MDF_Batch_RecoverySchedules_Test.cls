@isTest public class Core_MDF_Batch_RecoverySchedules_Test {
    @isTest static void testExecute(){
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = sysAdminProfile.Id;
        usr.FirstName ='RecoverySchedule';
        usr.LastName ='User';
        Database.insert(usr);
        
        system.runAs(usr){
            Test.startTest();
            Id batchJobId = Database.executeBatch(new Core_MDF_Batch_RecoverySchedules(System.today()+60));
            Test.stopTest();
            Assert.isTrue(batchJobId != null);
        }
        
    }
}