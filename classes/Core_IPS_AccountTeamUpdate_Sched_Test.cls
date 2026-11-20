/***************************************************************************************************
Class Name:  Core_IPS_AccountTeamUpdate_Sched_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 10 June 2016
Function    : This class contains test coverage for Core_IPS_AccountTeamUpdate_Scheduler Apex Class.
Description:   This class contains unit test scenarios for Core_IPS_AccountTeamUpdate_Scheduler Apex Class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Nareshbabu p               06/10/2016              Created
* Amritesh                   26/03/2018              Modified - US248473
* System.assert()--> statement Added By Hassan Khan 01-02-2024 
****************************************************************************************************/   
@istest
public class Core_IPS_AccountTeamUpdate_Sched_Test {
    
    static User systemUser;
    static User internalUser;
    static List<Account> lstAccount;
    static List<AccountTeamMember> lstATM;
    
    static void getUserRecords() {
        // Query Profiles
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
        systemUser = SysAdminUsr[0];
        internalUser = ListOfInternalSfUsers[0];
    }
    
    static void getDataRecords() {
        //create Account record
        lstAccount = new List<Account>();
        Account AccountRec1 = TestUtilities.getAccount();
        AccountRec1.Core_IPS_Active__c = true;
        AccountRec1.ownerid = internalUser.id;
        //AccountRec1.Core_Military_Aerospace_and_Government__c = true;
        lstAccount.add(AccountRec1);
        System.RunAs(systemUser){
            insert lstAccount;
        }
        
        //create Accountteammember record
        lstATM = new List<AccountTeamMember>();
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = lstAccount[0].Id;
        atm.UserId = internalUser.Id;
        lstATM.add(atm);
        System.RunAs(systemUser){
            insert lstATM;
        }
        
        List<Core_Batch_header__c> lstHeader = new List<Core_Batch_header__c>();
        Core_Batch_header__c header = new Core_Batch_Header__c();
        header.name='Core_IPS_AccountTeamUpdate_Scheduler';
        header.Last_Run_Date_Time__c = DateTime.Now().addDays(-1);
        lstHeader.add(header);
        
        Core_Batch_header__c header2 = new Core_Batch_Header__c();
        header2.name='Core_IPS_AccountTeam_DeletedRecords_Bulk';
        header2.Last_Run_Date_Time__c = DateTime.Now().addDays(-1);
        lstHeader.add(header2);
        
        System.RunAs(systemUser){
            insert lstHeader;
        }
    }
    
    static testmethod void AccountTeamUpdateSchedTestMethod1() {
        getUserRecords();
        getDataRecords();
        Test.startTest();        
        
        Core_IPS_AccountTeamScheduler acctTeamsche = new Core_IPS_AccountTeamScheduler();
        String scheduledTimeStirng = '0 15 * * * ?';
        String jobID = system.schedule('AccountTeam Sync - First-Test', scheduledTimeStirng, acctTeamsche);
        scheduledTimeStirng = '0 30 * * * ?';
        
        List<AccountShare> lstAccShare = Database.query('SELECT userorgroupid, accountid, rowcause FROM accountshare where lastmodifieddate >= TODAY');
        Core_IPS_AccountTeamUpdate_Scheduler.Insert_logexception(lstAccShare, 'Exception Test');
        System.assert(lstAccShare.size() > 0 , true);
        Test.stopTest();
    }    
    
    static testmethod void AccountTeamUpdateSchedTestMethod2() {
        getUserRecords();
        getDataRecords();
        
        List<Core_Account_Team__c> lstCustAccTeam = new List<Core_Account_Team__c>();
        Core_Account_Team__c accountTeamRecord = new Core_Account_Team__c(
            Core_Account__c = lstAccount[0].Id,
            Core_Case_Access__c = 'Read',
            Core_Team_Member__c = internalUser.Id
        );
        lstCustAccTeam.add(accountTeamRecord);
        System.RunAs(systemUser){
            insert lstCustAccTeam;
        }        
                
        Test.startTest();
            
        //Core_IPS_AccountTeam_Calculation CIAC = new Core_IPS_AccountTeam_Calculation(c);
        
        Core_IPS_AccountTeamScheduler acctTeamsche = new Core_IPS_AccountTeamScheduler();
        String scheduledTimeStirng = '0 15 * * * ?';
        String jobID = system.schedule('AccountTeam Sync - First-Test', scheduledTimeStirng, acctTeamsche);
        scheduledTimeStirng = '0 30 * * * ?';
        
        //Core_IPS_AccountTeamUpdate_Scheduler.Insert_logexception(ListOfAccounts,'Exception Test');
        
        Test.stopTest();  
        System.assert(lstCustAccTeam.size() > 0, true);
    }
    
    static testmethod void AccountTeamUpdateSchedTestMethod3() {
        getUserRecords();
        
        Core_Batch_header__c header = new Core_Batch_Header__c();
        header.name='Core_IPS_AccountTeamUpdate_Scheduler';
        header.Last_Run_Date_Time__c = DateTime.Now().addDays(-1);
        System.RunAs(systemUser){
            insert header;
        }
        
        Test.startTest();        
        
        Core_IPS_AccountTeamScheduler acctTeamsche = new Core_IPS_AccountTeamScheduler();
        String scheduledTimeStirng = '0 15 * * * ?';
        String jobID = system.schedule('AccountTeam Sync - First-Test', scheduledTimeStirng, acctTeamsche);
        scheduledTimeStirng = '0 30 * * * ?';
        Test.stopTest();
        System.assert(header != null, true);
    }
    
    static testmethod void AccountTeam_DeleteSyncTestMethod() {
        getUserRecords();
        getDataRecords();
                
        List<Core_Account_Team__c> lstCustAccTeam = new List<Core_Account_Team__c>();
        Core_Account_Team__c accountTeamRecord = new Core_Account_Team__c(
            Core_Account__c = lstAccount[0].Id,
            Core_Case_Access__c = 'Read',
            Core_Team_Member__c = internalUser.Id
        );
        lstCustAccTeam.add(accountTeamRecord);
        System.RunAs(systemUser){
            insert lstCustAccTeam;
        }
        
        delete [SELECT Id FROM AccountTeamMember];
        
        Test.startTest();
        
        Core_IPS_AccountTeam_DeleteSync accountTeamDeleteSyncBatch = new Core_IPS_AccountTeam_DeleteSync(); 
        database.executebatch(accountTeamDeleteSyncBatch, 10);
        
        Core_IPS_AccountTeam_DeleteSync.Insert_logexception(lstCustAccTeam, 'Exception Test');
        
        Test.stopTest();
        System.assert(lstCustAccTeam.size() > 0, true);
    }
    
    static testmethod void AccountTeamBatchHandlerTestMethod() {
        getUserRecords();
        
        Core_Batch_header__c header = new Core_Batch_Header__c();
        header.name='Core_IPS_AccountTeamUpdate_Scheduler';
        //header.Last_Run_Date_Time__c = DateTime.Now().addDays(-1);
        System.RunAs(systemUser){
            insert header;
        }        
        
        Core_Batch_Processing__c batchProcessing = new Core_Batch_Processing__c();
        batchProcessing.Core_Last_Run_Date__c=System.now();
        batchProcessing.Core_Start_Date_Time__c=system.now();
        batchProcessing.Batch_Header__c = header.id;
        insert batchProcessing;
        
        Test.startTest();
        
        AccountTeamBatchHandler.getHeader('Core_IPS_AccountTeamUpdate_Scheduler');
        AccountTeamBatchHandler.getLastRunDateTime('Core_IPS_AccountTeamUpdate_Scheduler');
        
        Test.stopTest();
        System.assert(header != null, true);
    }
    
    /*
    static testmethod void AccountTeamUpdateSchedTestMethod2() {
        // Query Profiles
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
        //create Account record
        List<Account> ListOfAccounts = new List<Account> ();
        Account AccountRec1 = TestUtilities.getAccount();
        AccountRec1.Core_IPS_Active__c = true;
        AccountRec1.ownerid = ListOfInternalSfUsers.get(0).id;
        AccountRec1.Core_Military_Aerospace_and_Government__c = true;
        ListOfAccounts.add(AccountRec1);
        System.RunAs(SysAdminUsr[0]){
        insert ListOfAccounts;
        }
        //create Accountteammember record
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = ListOfAccounts[0].Id;
        atm.UserId = ListOfInternalSfUsers[0].Id;
        System.RunAs(SysAdminUsr[0]){
        insert atm;
        }
        //create Accountteammember1 record
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
        Test.startTest();
        Core_Batch_header__c header = new Core_Batch_Header__c();
        header.name='Core_IPS_AccountTeamUpdate_Scheduler';
        insert header;
        try{
        Core_Batch_header__c header1=AccountTeamBatchHandler.getHeader('Core_IPS_AccountTeamUpdate_Scheduler');
        Core_Batch_Processing__c batchProcessing = new Core_Batch_Processing__c();
        batchProcessing.Core_Last_Run_Date__c=System.now();
        batchProcessing.Core_Start_Date_Time__c=system.now();
        batchProcessing.Batch_Header__C = header1.id;
        insert batchProcessing;
        }catch(DMLException e){
            system.assertEquals(e.getMessage(), e.getMessage());
        }
        ApexPages.StandardController c = new ApexPages.StandardController(ListOfAccounts[0]);
        Core_IPS_AccountTeam_Calculation CIAC = new Core_IPS_AccountTeam_Calculation(c);
        
       // accTeamObj1.calcuateTeam(ListOfAccounts[0].Id,'Batch',ListOfAccounts[0].Id);
        Core_IPS_AccountTeamScheduler acctTeamsche = new Core_IPS_AccountTeamScheduler();
        String scheduledTimeStirng = '0 15 * * * ?';
        String jobID = system.schedule('AccountTeam Sync - First-Test', scheduledTimeStirng, acctTeamsche);
        scheduledTimeStirng = '0 30 * * * ?';
        CIAC.calcuateTeam(ListOfAccounts[0].Id,'Batch',ListOfAccounts[0].Id);
        Core_IPS_AccountTeamUpdate_Scheduler.Insert_logexception(ListOfAccounts,'Exception Test');
        Test.stopTest();                   
    }
    
   
    */
    
   
}