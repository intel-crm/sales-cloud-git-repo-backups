@isTest(SeeAllData=false)
public class Core_MDF_DetermineActiveUsersToSendETest {
    @TestSetUp
    static void createTestData(){
        test.startTest();
        UserRole adminRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = adminRole.Id;
        insert usr;
    }
    @isTest
    static void sendEmailonRejectionTest(){
        User user = [SELECT Id FROM User WHERE LastName = 'User Test' limit 1];
        System.runAs(user){
            test.startTest();
            List<Core_MDF_DetermineActiveUsersToSendEmail.MailParams> inputList = new List<Core_MDF_DetermineActiveUsersToSendEmail.MailParams>();
            
            Core_MDF_DetermineActiveUsersToSendEmail.MailParams accMgr = new Core_MDF_DetermineActiveUsersToSendEmail.MailParams();

            List<Id> userIdsList = new List<Id>();
            for(User userId : [SELECT Id,LastName FROM USER WHERE LastName LIKE '%Manager%']){
                userIdsList.add(userId.Id);
            }
            accMgr.recordId = 'a4SDz000000FvqxMAE';
            accMgr.sendDiff = True;
            accMgr.templateName = 'Core_MDF_EscalationApprovalTemplate_VF';
            accMgr.userIdList = userIdsList;
            inputList.add(accMgr);

            Core_MDF_DetermineActiveUsersToSendEmail.sendEmailToActiveUsers(inputList);

            test.stopTest();
        }
    }
}