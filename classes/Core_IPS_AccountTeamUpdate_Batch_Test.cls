@isTest
private class Core_IPS_AccountTeamUpdate_Batch_Test {

    static testmethod void Core_IPS_AccountTeamUpdate_BatchTestMethod() {
        // The query used by the batch job.
        

       // Create some test merchandise items to be deleted
       //   by the batch job.
       List<string> ListOfProfileNames = new List<string> {'System Administrator'};
        Map<String,ID> MapOfProfiles = new Map<String,ID>();
        for(Profile prof : [select id, name from Profile where name IN: ListOfProfileNames]){
            MapOfProfiles.put(prof.name, prof.id);
        }
       List<User> SysAdminUsr = TestUtilities.getListOfUser(1);
        SysAdminUsr.get(0).UserName = 'SysAdminUsr'+SysAdminUsr.get(0).UserName;
        SysAdminUsr.get(0).ProfileID =  MapOfProfiles.get('System Administrator');
        // Create UserRole Record
        UserRole role = new UserRole();
        role.name='CEO';
        // Creating SETUP OBJECT (USERROLE) RECORD
        System.RunAs(SysAdminUsr[0]){
            insert role;
        }
        
      List<User>  ListOfInternalSfUsers = TestUtilities.getListOfUser(1);
        ListOfInternalSfUsers.get(0).ProfileID =  MapOfProfiles.get('System Administrator');
        ListOfInternalSfUsers.get(0).userroleid = role.id;
        // Creating SETUP OBJECT (USER) RECORD
        System.RunAs(SysAdminUsr[0]){
            insert ListOfInternalSfUsers;
        }
        System.assertEquals(ListOfInternalSfUsers.get(0).profileid, MapOfProfiles.get('System Administrator'));
         List<Account> ListOfAccounts = new List<Account> ();
        Account AccountRec1 = TestUtilities.getAccount();
        AccountRec1.Core_IPS_Active__c = true;
        AccountRec1.ownerid = ListOfInternalSfUsers.get(0).id;
        AccountRec1.Core_Military_Aerospace_and_Government__c = true;
        ListOfAccounts.add(AccountRec1);
        System.RunAs(SysAdminUsr[0]){
        insert ListOfAccounts;
        }
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = ListOfAccounts[0].Id;
        atm.UserId = ListOfInternalSfUsers[0].Id;
        System.RunAs(SysAdminUsr[0]){
        insert atm;
        }
        AccountTeamMember atm1 = new AccountTeamMember();
        atm1.AccountId = ListOfAccounts[0].Id;
        atm1.UserId = ListOfAccounts[0].OwnerId;
        System.RunAs(SysAdminUsr[0]){
        insert atm1;
        }
        /*AccountShare aShare = new AccountShare();
        aShare.AccountId = ListOfAccounts[0].Id;
        aShare.UserOrGroupId = ListOfInternalSfUsers[0].Id;
        aShare.RowCause = 'Manual';
        aShare.AccountAccessLevel = 'Edit';
        aShare.OpportunityAccessLevel = 'Edit';
        aShare.CaseAccessLevel = 'Edit';
        System.RunAs(SysAdminUsr[0]){
        insert aShare;
        }*/
        Test.startTest();
        Core_IPS_AccountTeamUpdate_Batch atmBatch = new Core_IPS_AccountTeamUpdate_Batch();
        Database.executeBatch(atmBatch);
       // Core_IPS_AccountTeamUpdate2_Batch atmBatch2 = new Core_IPS_AccountTeamUpdate2_Batch();
      //Database.executeBatch(atmBatch2);
        Test.stopTest();       
    }
}