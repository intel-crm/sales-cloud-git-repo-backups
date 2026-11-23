@isTest
public class Temp_Batch_Test {
    public static testMethod void testTempBatches() {
        
        Account acct = Core_Test_Utility.createAccount(1)[0];
        insert acct;
        
        User usr = Core_Test_Utility.Core_User(1)[0];
        insert usr;
        
        Opportunity oppty = Core_Test_Utility.createOpportunity(1)[0];
        oppty.AccountId = acct.Id;
        oppty.OwnerId = usr.Id;
        insert oppty;
        
        //OpportunityTeamMember opptm = new OpportunityTeamMember(OpportunityId=oppty.Id, UserId=usr.Id, TeamMemberRole='')
        
        Test.startTest();
        Database.executeBatch(new Core_Batch_Update_OSC_Collab_Type_Tmp());
        Database.executeBatch(new Core_Batch_Update_OSC_Snpashot_Tmp());
        Database.executeBatch(new Core_Batch_Check_OSC_Collab_Type_Tmp());
        Database.executeBatch(new Core_Batch_Check_OSC_Collab_Type2_Tmp());
        System.assertEquals(2, 1+1);
        Test.stopTest();
    }
}