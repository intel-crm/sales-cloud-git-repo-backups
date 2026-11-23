/**************************************************************************************
Apex Class Name:  Core_AccountHandler_Test
Version     : 1.0 
Created Date: 06 OCT 2014
Function    : Test Class for the Core_Account trigger
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             10/06/2014              Original Version
*************************************************************************************/
@isTest
public class Core_AccountHandler_Test{
     
    /*
    * Method name  : Core_Account_Test
    * Description  : test method to cover Core_Account trigger
    */ 
    static TestMethod void Core_AccountHandler_Test()
    {
        Core_Test_AccountObjectAfterDelete();   
        accountGeoSubGeoPopulation();    
    }
       
     /*
    * Method name  : Core_Account_Test
    * Description  : test method to cover Core_Account trigger
    */   
    static void accountGeoSubGeoPopulation()
    {    
        //Declare/Initialize the Variables
        List<Account> lstAccount = new List<Account>();
        List<Core_Country_Reference__c> lstCS = new List<Core_Country_Reference__c>{};
        
        try{
        
            Core_Trigger_Executions__c OpportunityFactsUpdate = new Core_Trigger_Executions__c();
            OpportunityFactsUpdate.name = 'accountObjectBeforeHandler';
            OpportunityFactsUpdate.Core_Object__c = 'Descriptive Feature';
            OpportunityFactsUpdate.Core_Trigger_Events__c = 'After insert';
            OpportunityFactsUpdate.Core_Active__c = TRUE;
            OpportunityFactsUpdate.Core_Description__c = 'This is test description';
            OpportunityFactsUpdate.Core_Class_Name__c = 'Test Class';
            
            Core_Trigger_Executions__c OpportunityFactsUpdate1 = new Core_Trigger_Executions__c();
            OpportunityFactsUpdate1.name = 'accountObjectAfterDelete';
            OpportunityFactsUpdate1.Core_Object__c = 'Descriptive Feature';
            OpportunityFactsUpdate1.Core_Trigger_Events__c = 'After insert';
            OpportunityFactsUpdate1.Core_Active__c = TRUE;
            OpportunityFactsUpdate1.Core_Description__c = 'This is test description';
            OpportunityFactsUpdate1.Core_Class_Name__c = 'Test Class';
            
            insert OpportunityFactsUpdate ;
            insert OpportunityFactsUpdate1 ;
        
            lstCS = Core_Test_Utility.Core_CountryState(1);
            
            // Construct the CountryStateReference instances
            for(Core_Country_Reference__c sobjCS : lstCS){
                sobjCS.Name='United States';
                sobjCS.Core_Geo__c='ASMO';
                sobjCS.Core_Has_States__c=true;
                sobjCS.Core_ISO_Code__c='USA';
                sobjCS.Core_Sub_Geo__c='NAR';
            }
            
            // Insert the intialized country state reference
            Database.SaveResult[] lstSaveResultCS = Database.insert(lstCS, false);
            
            lstAccount = Core_Test_utility.createAccount(10);
            
            String cpmId    = '1234567890';
            String cpmId300 = '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890' +
                              '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890' +
                              '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
            
            lstAccount[1].Core_CPM_ID__c = cpmId;
            lstAccount[2].Core_CPM_ID__c = cpmId + ', , ' + cpmId;
            lstAccount[3].Core_CPM_ID__c = cpmId + ' '  + cpmId;
            lstAccount[4].Core_CPM_ID__c = cpmId300;
            lstAccount[5].Core_CPM_ID__c = cpmId + ', , ' + cpmId300;
                                      
            // Insert the intialized accounts
            Database.SaveResult[] lstSaveResultAccount = Database.insert(lstAccount, false);


            // CPM ID 255 tests - START           
            Account acct;
            acct = [SELECT Core_CPM_ID_255__c FROM Account WHERE Id = :lstAccount[0].Id];
            System.assertEquals(acct.Core_CPM_ID_255__c, null);
                                    
            acct = [SELECT Core_CPM_ID_255__c FROM Account WHERE Id = :lstAccount[1].Id];
            System.assertEquals(acct.Core_CPM_ID_255__c, cpmId);
                        
            acct = [SELECT Core_CPM_ID_255__c FROM Account WHERE Id = :lstAccount[2].Id];
            System.assertEquals(acct.Core_CPM_ID_255__c, cpmId + Core_AccountHandler.CPMID_DELIMITER + cpmId);
                        
            acct = [SELECT Core_CPM_ID_255__c FROM Account WHERE Id = :lstAccount[3].Id];
            System.assertEquals(acct.Core_CPM_ID_255__c, cpmId + Core_AccountHandler.CPMID_DELIMITER + cpmId);
            
            acct = [SELECT Core_CPM_ID_255__c FROM Account WHERE Id = :lstAccount[4].Id];
            System.assertEquals(acct.Core_CPM_ID_255__c, cpmId300.left(255));
            
            acct = [SELECT Core_CPM_ID_255__c FROM Account WHERE Id = :lstAccount[5].Id];
            System.assertEquals(acct.Core_CPM_ID_255__c, cpmId);
            // CPM ID 255 tests - END            

            
            //Get the instances from the database            
            lstAccount = [select Core_Geo__c, Core_Sub_Geo__c, BillingCountryCode, BIllingStateCode from Account];
            
            // Check if the relavant Geo & Sub Geo are populated
            for(Account sobjLead : lstAccount)
            {
                System.assertEquals(sobjLead.Core_Geo__c,'ASMO');
                System.assertEquals(sobjLead.Core_Sub_Geo__c, 'NAR');                 
            }
            for(Account sobjAcc : lstAccount){
                //sobjAcc.billingCountry = 'Mexico';
                sobjAcc.billingCountryCode = 'MEX';
                sobjAcc.BIllingStateCode= 'AGU';    
            }
            
            //Insert the updated accounts
            update lstAccount;
            //Get the instances from the database
            lstAccount = [select Core_Geo__c,Core_Sub_Geo__c, BillingCountryCode, BillingStateCode from Account];
            // Check if the relavant Geo & Sub Geo are NULL since the same doesnt exist for the country code
            for(Account sobjLead : lstAccount)
            {
                System.assertEquals(sobjLead.Core_Geo__c, NULL);
                System.assertEquals(sobjLead.Core_Sub_Geo__c, NULL);
            
            }
            
            //Delete the created accounts
            delete lstAccount;
            
         }
        catch(Exception e){
            System.debug(System.Label.Core_Exception+e.getMessage());
        }   
    }
    
    
    // account.MasterRecordId = '5250';  NOT ALLOWED
    //
    // MasterRecordId can't be loaded even through the contructor!
    // Testing will be minimal-coverage.
    //    
    static void Core_Test_AccountObjectAfterDelete()
    {    
        List<Account> oldList = Core_Test_Utility.createAccount(1);
        Core_AccountHandler.accountObjectAfterDelete(null, null, oldList, null);     
    }
    
    static TestMethod void testAccountTeamAuditCompletion() {
        setupAccountTeamAuditTestData();
        List<Core_Audit_Log__c> logs = [select Id, Core_Account__r.Name from Core_Audit_Log__c where Core_Completed_Time__c = null];
        System.debug(logs);
        System.assert(logs.size() == 5);
        
        Test.startTest();        
        List<Account>   lstAccount = [select Id, Core_Account_Team_Audit_Complete__c from Account where Core_Account_Team_Audit_Complete__c = false];   
        System.debug(lstAccount);
        for (Account acct:lstAccount) {
            acct.Core_Account_Team_Audit_Complete__c = true;
        }
        update lstAccount;
        Test.stopTest();
        
        List<Core_Audit_Log__c> completedLogs = [select Id, Core_Completed_Time__c from Core_Audit_Log__c where Core_Completed_Time__c != null];
        System.debug(completedLogs);
        System.assert(completedLogs.size() == 5);
    }
    
    static void setupAccountTeamAuditTestData()
    {
        List<Account>   lstAccount;        
        lstAccount = Core_Test_Utility.createAccount(10);
        
        Integer count = 0;
        for (Account acct : lstAccount) {
            System.debug('Account: ' + acct);
            if(count < 5) {
                acct.Core_Account_Team_Audit_Complete__c = false;
                acct.Core_Account_Team_Audit_Due_Date__c = Date.today();
                count++;
            }     
            else 
            {
                acct.Core_Account_Team_Audit_Complete__c = true;
                count++;
            }
        }
        insert lstAccount;
        
        List<Account> accountsToLog = [select Id, Core_Account_Team_Audit_Complete__c from Account where Core_Account_Team_Audit_Complete__c = false];
        List<Core_Audit_Log__c> logs = new List<Core_Audit_Log__c>();
        Core_Audit_Log__c newLog;  
        
        for (Account acct:accountsToLog) {
            newLog = new Core_Audit_Log__c();
            newLog.Core_Account__c = acct.Id;
            newLog.Core_Event_Type__c = 'Account Team Audit';
            newLog.Core_Event_Time__c = system.now();
            newLog.Core_Generated_By_User__c = UserInfo.getUserId();
            logs.add(newLog);            
        }
        insert logs;
    }
    
    // Test preventUncoveredAccountChange in Core_AccountHandler
    static testMethod void testUncoveredAccountChange() {
        List<Account> lstAccount = Core_Test_Utility.createAccount(1);
        
        insert lstAccount;
        
        List<Contact> lstContact = Core_Test_Utility.createContacts(5);
        
        for(Contact conObj : lstContact) {
            conObj.AccountId = lstAccount[0].id;
        }
        
        insert lstContact;
        
        lstAccount[0].OwnerId = Label.Core_Uncovered_Account_ID;
        
        Test.startTest();
        update lstAccount;
        Test.stopTest();
    }
    
    // Test prevention of A&E User account ownership
    static testMethod void testPreventAEUserAccountOwnership() {

        // Insert our 2 test users
        User testAEUser = new User(UserName = 'testAEUser54321@intel.com.crm.testclass', LastName = 'User', Email = 'testAEUser54321@intel.com',
                                   Alias = 'taeusr', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                                   ProfileId = Label.Core_A_E_User_Profile_Id, LanguageLocaleKey = 'en_US');
        insert testAEUser;
        
        User testAESuperUser = new User(UserName = 'testAESuperUser54321@intel.com.crm.testclass', LastName = 'User', Email = 'testAESuperUser54321@intel.com',
                                   Alias = 'taesusr', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                                   ProfileId = Label.Core_A_E_User_Profile_Id, LanguageLocaleKey = 'en_US');
        insert testAESuperUser;
        
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = testAESuperUser.Id,
                                                                  PermissionSetId = Label.Core_A_E_Super_User_Permission_Set_Id);
        insert psa;
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
        
            // Ensure our trigger code is active
            Core_Trigger_Executions__c accountPreventAEUserOwnership = new Core_Trigger_Executions__c();
            accountPreventAEUserOwnership.Name = 'accountPreventAEUserOwnership';
            accountPreventAEUserOwnership.Core_Object__c = 'Account';
            accountPreventAEUserOwnership.Core_Trigger_Events__c = 'before update';
            accountPreventAEUserOwnership.Core_Active__c = true;
            accountPreventAEUserOwnership.Core_Description__c = 'This is test description';
            accountPreventAEUserOwnership.Core_Class_Name__c = 'Core_AccountHandler';
            insert accountPreventAEUserOwnership;
            
            // Now insert our test account and try changing the owner to those 2 users
            Account testAccount = Core_Test_Utility.createAccount(1)[0];
            testAccount.OwnerId = Label.Core_Uncovered_Account_ID;
            insert testAccount;
            
            // Changing to A&E User who isn't a Super User will throw an error, so catch it
            testAccount.OwnerId = testAEUser.Id;
            try {
                update testAccount;
            }
            catch (Exception ex) {
                System.debug(ex);
            }
            
            // Make sure owner hasn't changed
            testAccount = [select OwnerId from Account where Id = :testAccount.Id limit 1][0];
            System.assertNotEquals(testAEUser.Id, testAccount.OwnerId);
            
            // Changing to A&E Super User should not throw an exception
            testAccount.OwnerId = testAESuperUser.Id;
            update testAccount;
            
            // Make sure owner has changed
            System.assertEquals(testAESuperUser.Id, testAccount.OwnerId);
        }
    }
    
    /*
    static testMethod void testDeleteSharing(){ 
         list<Account> acclist = new list<Account>();
         list<Core_Channel_Salesout__c> channelSalesList = new list<Core_Channel_Salesout__c>();
         list<Core_Channel_Membership__c> channelMemberList = new list<Core_Channel_Membership__c>();
         list<Core_Training__c> trainingList = new list<Core_Training__c>();
         list<Core_Redemption_Points__c> rPointList = new list<Core_Redemption_Points__c>(); 
         list<Core_Liability_Points__c> lPointList = new list<Core_Liability_Points__c>();
         list<Core_Channel_Salesout__Share> salesOutSharingList = new list<Core_Channel_Salesout__Share>();
         list<Core_Channel_Membership__Share> memberSharingList = new list<Core_Channel_Membership__Share>();
         list<Core_Training__Share> trainingSharingList = new list<Core_Training__Share>();
         list<Core_Liability_Points__Share> lPointsSharingList = new list<Core_Liability_Points__Share>();
         list<Core_Redemption_Points__Share> rPointsSharingList = new list<Core_Redemption_Points__Share>();
         list<AccountTeamMember> accTeamList = new list<AccountTeamMember>();
         user u = new user();
         user u1 = new user();
          // Create the configuration item so the Insert and Update trigger on Opportunity gets executed
            Core_Trigger_Executions__c triggerExec = new Core_Trigger_Executions__c( 
                Name='deleteSalesoutShairing', Core_Class_Name__c='Core_AccountHandler', Core_Object__c='Account', 
                Core_Trigger_Events__c='before Insert before update', Core_Active__c=true, Core_Description__c = 'For testing Account Sharing');
    
            insert triggerExec;
         // Extracting user from Core_test_utility
        // u = Core_Test_Utility.systemAdminUser ();
         u = Core_Test_Utility.systemAdminUser;
         u1 = [SELECT Id, Name FROM User WHERE isActive = TRUE AND Profile.Name = 'Data Ops' limit 1];
         for(Integer i = 0 ; i< 10 ; i++){
            Account acct = new Account(Name = 'Test Account territory', BillingStreet = '123 Fake St',
                                               BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                               BillingPostalCode = '12345', ownerId = u.Id);
                acclist.add(acct);
        }
        insert acclist;
        for(Integer i = 0; i< 5; i++){
            AccountTeamMember acctTeam = new AccountTeamMember();
                acctTeam.AccountId = accList[i].Id;
                acctTeam.UserId = u.Id;
               // acctTeam.AccountAccessLevel = 'Edit';
                acctTeam.TeamMemberRole = 'Contributor';
                accTeamList.add(acctTeam);
        }
        insert accTeamList;
        for(Integer j = 0 ; j < 10 ; j++){
            Core_Channel_Salesout__c  chsales = new Core_Channel_Salesout__c (Name = 'test');
            chSales.Core_Account_Name__c = acclist[j].Id;
            channelSalesList.add(chSales);
        }
        insert channelSalesList;
        
        for(Core_Channel_Salesout__c chSales : channelSalesList){
            Core_Channel_Salesout__Share chSalesShare = new Core_Channel_Salesout__Share();
            chSalesShare.ParentId = chSales.id;
            chSalesShare.UserOrGroupId = u.Id;
            chSalesShare.AccessLevel = 'Read';
            chSalesShare.RowCause = 'Manual';
            salesOutSharingList.add(chSalesShare);
        }
        insert salesOutSharingList;
        for(Integer j = 0 ; j < 10 ; j++){
            Core_Channel_Membership__c  chmember = new Core_Channel_Membership__c  (Name = 'test');
            chmember.Core_Account_Name__c = acclist[j].Id;
            channelMemberList.add(chmember);
        }
        insert channelMemberList ;
        for(Core_Channel_Membership__c chMember : channelMemberList){
            Core_Channel_Membership__Share chMemberShare = new Core_Channel_Membership__Share();
            chMemberShare.ParentId = chMember.Id;
            chMemberShare.UserOrGroupId = u.Id;
            chMemberShare.AccessLevel = 'Read';
            chMemberShare.RowCause = 'Manual';
            memberSharingList.add(chMemberShare);
        }
        insert memberSharingList;
         for(Integer j = 0 ; j < 10 ; j++){
            Core_Training__c  chTraining = new Core_Training__c  (Name = 'test');
            chTraining.Core_Account__c = acclist[j].Id;
            trainingList.add(chTraining);
        }
        insert trainingList;
        for(Core_Training__c chTraining : trainingList){
            Core_Training__Share chTrainingShare = new Core_Training__Share();
            chTrainingShare.ParentId = chTraining.Id;
            chTrainingShare.UserOrGroupId = u.Id;
            chTrainingShare.AccessLevel = 'Read';
            chTrainingShare.RowCause = 'Manual';
            trainingSharingList.add(chTrainingShare);
        
        }
        insert trainingSharingList;
        for(Integer j = 0 ; j < 10 ; j++){
            Core_Redemption_Points__c  chRpoints = new Core_Redemption_Points__c  (Name = 'test');
            chRpoints.Core_Account__c = acclist[j].Id;
            rPointList.add(chRpoints);
        }
        insert rPointList;
        for(Core_Redemption_Points__c chRpoints : rPointList){
            Core_Redemption_Points__Share chRpointsShare = new Core_Redemption_Points__Share ();
            chRpointsShare.ParentId = chRpoints.Id;
            chRpointsShare.UserOrGroupId = u.Id;
            chRpointsShare.AccessLevel = 'Read';
            chRpointsShare.RowCause = 'Manual';
            rPointsSharingList.add(chRpointsShare);
        
        }
        insert rPointsSharingList;
        for(Integer j = 0 ; j < 10 ; j++){
            Core_Liability_Points__c  chLpoints = new Core_Liability_Points__c  (Name = 'test');
            chLpoints.Core_Account__c = acclist[j].Id;
            lPointList.add(chLpoints);
        }
        insert lPointList;
        for(Core_Liability_Points__c chLpoints : lPointList){
            Core_Liability_Points__Share chLPointsShare = new Core_Liability_Points__Share ();
            chLPointsShare.ParentId = chLpoints.Id;
            chLPointsShare.UserOrGroupId = u.Id;
            chLPointsShare.AccessLevel = 'Read';
            chLPointsShare.RowCause = 'Manual';
            lPointsSharingList.add(chLPointsShare);
        
        }
        insert lPointsSharingList;
        test.starttest();
        system.runAs(u1){
            for(Account a : acclist){
                a.ownerId = userinfo.getUserId();
            }
           update acclist;
       }
        test.stoptest();
     }
     */
}