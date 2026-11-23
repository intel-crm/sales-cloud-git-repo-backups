/**
* @description       : 
* @author            : Bharath Chandrashekar
* @group             : 
* @last modified on  : 11-28-2024
* @last modified by  : Bharath Chandrashekar
**/
@isTest
public class Pricing_SyncSDMToQuote_Test {
    @testSetup
    public static void setUpData() {
        List<User> adminUserList = Pricing_Test_Utility.createAdminUserWithParam('qlBusinessLogicAdmin');
        Pricing_Test_Utility.createPriceBook();
        System.runAs(adminUserList[0]) {
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = adminUserList[0].Id);
            insert accTeam;
            Test.startTest();
            Group grp = Pricing_Test_Utility.createGroupRecord();
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = salesRepUserList[0].id;
            grpMem1.GroupId = grp.Id;
            Insert grpMem1;
            ChannelProgram chProg = Pricing_Test_Utility.createChannelProgramRecord();
            List<Core_MDF_Partner_Group_Mapping__c> partnerGroupList = Pricing_Test_Utility.createPGMRecord(acc,grp,chProg,1);
            Test.stopTest();
        }
    }
    @isTest
    public static void testaddCurrentUserToPublicGroups() {
        List<Id> Ids = new List<Id>();
        Account acct = [SELECT Id from Account LIMIT 1];
        List<User> adminUserList = [Select id from User where Email='qlBusinessLogicAdmin@intel.com'];
        List<User> salesRepUserList = [Select id from User where Email='firstNameSalesRep@intel.com'];
        AccountTeamMember acc = [SELECT Id,AccountId,Account.Name FROM AccountTeamMember where AccountId =: acct.Id];
        Core_MDF_Partner_Group_Mapping__c PGMgroup = [Select Id, Core_MDF_Group_Name__c, Core_MDF_Group_Id__c FROM Core_MDF_Partner_Group_Mapping__c where Core_MDF_Account__c =:acct.Id];
        GroupMember grpMember = [SELECT Id,UserOrGroupId,GroupId FROM GroupMember limit 1];
        Ids.add(acct.Id);
        System.runAs(adminUserList[0]){
            Test.startTest();
            Pricing_SyncSDMToQuote.addCurrentUserToPublicGroups(Ids);
            Test.stopTest();
        }   
    }
}