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
        test.stopTest();
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
            Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('Flipkart', 
            					Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            					intelAccount.Core_Geo__c = 'APJ';
            					intelAccount.Core_Sub_Geo__c = 'ROA';
            database.insert(intelAccount);
            // US - TWC702-14285: Unit Test Method should include System.Assert
            System.assertNotEquals(null, intelAccount.Id, 'Account should be inserted');
            accMgr.recordId = intelAccount.Id;
            accMgr.sendDiff = True;
            accMgr.templateName = 'Core_MDF_EscalationApprovalTemplate_VF';
            accMgr.userIdList = userIdsList;
            inputList.add(accMgr);
            // US - TWC702-14285: Unit Test Method should include System.Assert
            System.assertEquals(1, inputList.size(), 'Input list should contain one element');

            Core_MDF_DetermineActiveUsersToSendEmail.sendEmailToActiveUsers(inputList);

            test.stopTest();
        }
    }
}