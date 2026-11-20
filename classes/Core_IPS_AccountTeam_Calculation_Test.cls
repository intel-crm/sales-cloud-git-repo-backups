@isTest
private class Core_IPS_AccountTeam_Calculation_Test {

    static testmethod void calculateAccountTeamTestMethod() {
        
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
        List<Core_Account_Team__c> obj1 = TestUtilities.getReadCustomAccountTeamList(1);
        for(Core_Account_Team__c catObj:obj1){
            catObj.Core_Account__c = ListOfAccounts[0].Id;
        }
        insert obj1;
        List<Core_Account_Team__c> obj2 = TestUtilities.getPrivateCustomAccountTeamList(1);
        for(Core_Account_Team__c catObj:obj2){
            catObj.Core_Account__c = ListOfAccounts[0].Id;
        }
        insert obj2;
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
        
        // Pass the case id to page  
        // commented for Classic EOL :Tejaswini      
     /*   PageReference pageRef = Page.Core_IPS_Manage_Account_Team;
        Test.setCurrentPage(pageRef); */
        ApexPages.currentPage().getParameters().put('id', ListOfAccounts[0].Id);
        Core_IPS_AccountTeam_Calculation accTeamObj = new Core_IPS_AccountTeam_Calculation(new ApexPages.StandardController(ListOfAccounts[0]));
        Core_IPS_AccountTeam_Calculation accTeamObj1 = new Core_IPS_AccountTeam_Calculation();
        Test.startTest();
        accTeamObj.calculateTeam(); 
        Core_Batch_header__c header = new Core_Batch_Header__c();
        header.name='Core_IPS_AccountTeamUpdate_Scheduler';
        insert header;
        Core_Batch_header__c header1=AccountTeamBatchHandler.getHeader('Core_IPS_AccountTeamUpdate_Scheduler');
        Core_Batch_Processing__c batchProcessing = new Core_Batch_Processing__c();
         batchProcessing.Core_Last_Run_Date__c=System.now();
          batchProcessing.Core_Start_Date_Time__c=system.now();
          batchProcessing.Batch_Header__C = header.id;
        insert batchProcessing;
        accTeamObj1.calcuateTeam(ListOfAccounts[0].Id,'Batch',batchProcessing.id);
        Core_IPS_AccountTeamScheduler acctTeam = new Core_IPS_AccountTeamScheduler();
        String scheduledTimeStirng = '0 15 * * * ?';
        String jobID = system.schedule('AccountTeam Sync - First-Test', scheduledTimeStirng, acctTeam);
        scheduledTimeStirng = '0 30 * * * ?';
        Test.stopTest();                   
    }
}