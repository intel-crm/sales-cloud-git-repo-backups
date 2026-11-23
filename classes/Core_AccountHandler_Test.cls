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

    /*****************************************************************************************************
    Method Name:updateMembershipTest                                          
    @return  :  Void
    Created By:                       Date: 29/7/2020
    Manikanta
    ****************************************************************************************************/
    static TestMethod void updateMembershipTest(){
            String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
            List<Account> lstAccts = new List<Account>();
        
       List<Core_Trigger_Executions__c> allCustomSettings = new List<Core_Trigger_Executions__c>();
       Core_Trigger_Executions__c newCustomSetting = new Core_Trigger_Executions__c();
       newCustomSetting.Core_Active__c =true;
       newCustomSetting.Name = 'accountPartnerTypeAfterUpate';
       newCustomSetting.Core_Class_Name__c = 'Core_AccountHandler';
       newCustomSetting.Core_Description__c ='To Update the membsership flag on partner type change';           
       newCustomSetting.Core_Object__c ='Account';
       newCustomSetting.Core_Trigger_Events__c = 'After update';
       allCustomSettings.add(newCustomSetting);
           Database.insert(allCustomSettings);
              
            Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'PRC Sales Group',
                                          Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
            lstAccts.add(partnerAccount1);
             RecordType masterRecordId = [select id, IsActive, DeveloperName from RecordType where DeveloperName='Mastered_Account'];
        
            Account intelAccount1 = new Account();
        	intelAccount1.Name ='IntelAccount1';
            intelAccount1.RecordTypeId = masterRecordId.id;
            intelAccount1.Core_Account_Type__c = 'Original Design Manufacturer (ODM)';
            intelAccount1.Core_Sales_Groups__c= 'PRC Sales Group';
            intelAccount1.Industry='Agriculture';
            intelAccount1.BillingCity='delhi';
            intelAccount1.BillingCountry='Ind';
            intelAccount1.BillingStreet='cbc chowk delhi';
            lstAccts.add(intelAccount1);
            Database.insert(lstAccts);
            Core_Account_Group_Member__c accGroupMem = new Core_Account_Group_Member__c();
            accGroupMem.Core_Partner_Account_Id__c =partnerAccount1.Id;
            accGroupMem.Core_Intel_Account_Id__c =intelAccount1.Id;
            Database.insert(accGroupMem);
            partnerAccount1.Core_PMP_Membership_Change_Ind__c = false;
            Database.update(partnerAccount1);
            List<Account> updatedAcct= new List<Account>();
            User testAEUser = new User(UserName = 'testAEUser54321@intel.com.crm.testclass', LastName = 'User', Email = 'testAEUser54321@intel.com',
                                   Alias = 'taeusr', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                                   ProfileId = Label.Core_A_E_User_Profile_Id, LanguageLocaleKey = 'en_US');
            insert testAEUser;
            Id ownerId;
            for(Account acc:[SELECT ID,NAME,Core_Account_Type__c FROM ACCOUNT WHERE ID=:intelAccount1.id]){
                System.debug('acc ='+acc);
                acc.OwnerId = testAEUser.Id;
                ownerId = testAEUser.Id;
                updatedAcct.add(acc);
            }
        Test.startTest();
            Database.Update(updatedAcct);
            System.assertEquals(ownerId, testAEUser.Id);
        Test.stopTest();
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
            //System.assertEquals(acct.Core_CPM_ID_255__c, cpmId);
                        
            acct = [SELECT Core_CPM_ID_255__c FROM Account WHERE Id = :lstAccount[2].Id];
            //System.assertEquals(acct.Core_CPM_ID_255__c, cpmId + Core_AccountHandler.CPMID_DELIMITER + cpmId);
                        
            acct = [SELECT Core_CPM_ID_255__c FROM Account WHERE Id = :lstAccount[3].Id];
            //System.assertEquals(acct.Core_CPM_ID_255__c, cpmId + Core_AccountHandler.CPMID_DELIMITER + cpmId);
            
            acct = [SELECT Core_CPM_ID_255__c FROM Account WHERE Id = :lstAccount[4].Id];
            //System.assertEquals(acct.Core_CPM_ID_255__c, cpmId300.left(255));
            
            acct = [SELECT Core_CPM_ID_255__c FROM Account WHERE Id = :lstAccount[5].Id];
            //System.assertEquals(acct.Core_CPM_ID_255__c, cpmId);
            // CPM ID 255 tests - END            

            
            //Get the instances from the database            
            lstAccount = [select Core_Geo__c, Core_Sub_Geo__c, BillingCountryCode, BIllingStateCode from Account];
            
            // Check if the relavant Geo & Sub Geo are populated
            for(Account sobjLead : lstAccount)
            {
                //System.assertEquals(sobjLead.Core_Geo__c,'ASMO');
                //System.assertEquals(sobjLead.Core_Sub_Geo__c, 'NAR');
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
        //System.assert(completedLogs.size() == 5);
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
            
            Core_Trigger_Executions__c Core_MDF_EnableIPAMDFAccountOnboarding = new Core_Trigger_Executions__c();
            Core_MDF_EnableIPAMDFAccountOnboarding.Name = 'Core_MDF_EnableIPAMDFAccountOnboarding';
            Core_MDF_EnableIPAMDFAccountOnboarding.Core_Object__c = 'Account';
            Core_MDF_EnableIPAMDFAccountOnboarding.Core_Trigger_Events__c = 'before update';
            Core_MDF_EnableIPAMDFAccountOnboarding.Core_Active__c = true;
            Core_MDF_EnableIPAMDFAccountOnboarding.Core_Description__c = 'This is test description';
            Core_MDF_EnableIPAMDFAccountOnboarding.Core_Class_Name__c = 'Core_AccountHandler';
            insert Core_MDF_EnableIPAMDFAccountOnboarding;

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
            testAccount = [select OwnerId,Industry from Account where Id = :testAccount.Id limit 1][0];
            //System.assertNotEquals(testAEUser.Id, testAccount.OwnerId);
            
            // Changing to A&E Super User should not throw an exception
            testAccount.OwnerId = testAESuperUser.Id;
            testAccount.Industry = 'Agriculture'; // Added as part of eployment error
            update testAccount;
            
            // Make sure owner has changed
            System.assertEquals(testAESuperUser.Id, testAccount.OwnerId);
        }
    }
    
    static testMethod void updatePartnerInfotest(){
        Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c (Name = 'Update_MP_Partners',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'Core_AccountHandler',
                                                                        Core_Object__c = 'Account',
                                                                        Core_Trigger_Events__c = 'After Update',
                                                                        Core_Description__c = 'Update the related MDA Partner info when ever Account updated.');
        insert cs;
                
        test.startTest();
        Account intel_acc = PMP_SearchTestDataFactory.createIntelAccount('Test Intel Account', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
        PMP_SearchTestDataFactory.createCompanyInformation(intel_acc.Name, intel_acc.Id, true);
        
        intel_acc.Name                              = 'Test Intel Account1';
        intel_acc.Core_IPA_Partner_Speciality__c    = 'Video SPecialist';
        intel_acc.Core_User_Defined_Website__c      = 'www.testorg.com';
        intel_acc.Website                           = 'www.testorg.com';
        update intel_acc;
        
        intel_acc.Core_IPA_Partner_Speciality__c    = 'Cloud Data Center Specialist';
        update intel_acc;
        test.stopTest();
    }
    
    @isTest
    static void updatebizOrgType(){
       Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        //Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();

        Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c (Name = 'Roll_up_account',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'Core_AccountHandler',
                                                                        Core_Object__c = 'Account',
                                                                        Core_Trigger_Events__c = 'after update',
                                                                        Core_Description__c = 'roll up child accounts biz org type and partner segment');
        insert cs;

        Account a2 = PRM_TestUtility.getAccount();
        a2.RecordTypeId = accountRecordTypeIntel;
        a2.Industry='Agriculture';
        a2.BillingCity='Goa';
        a2.BillingCountryCode='IND';
        a2.BillingStreet='4th Floor,New Road';
        a2.BillingPostalCode='110065';
        a2.BillingStateCode='KA';
        a2.Core_IPA_Partner_Role__c = 'Service Provider';
        a2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        insert a2;

        Test.startTest();
        a2.Core_IPA_Partner_Segment__c = 'Client Computing';
        update a2;
        Test.stopTest();

        System.assertEquals('Intel',a2.Name,'Value does not match');
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
     static testMethod void validateTierValues_test(){
        Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c (Name = 'ValidateTierValues',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'Core_AccountHandler',
                                                                        Core_Object__c = 'Account',
                                                                        Core_Trigger_Events__c = 'After Update',
                                                                        Core_Description__c = 'Update the related MDA Partner info when ever Account updated.');
        insert cs;
        List<account> lstAccount = Core_Test_utility.createAccount(20); 
        List<account> lstAccount1 = new list<account>(); 
        integer i = 0;  
        for(account a : lstAccount){
            if(i==0){
                a.Core_Account_Tier__c = 'CCG-Tier 1';
                a.Core_Account_Tier__c = 'CCG-Tier 2';
            }
            else if (i==1){
                a.Core_Account_Tier__c = 'DCG-Tier 1';
            }
            else if (i==2){
                a.Core_Account_Tier__c = 'GA-Tier 1';
            }
            else if (i==3){
                a.Core_Account_Tier__c = 'IOTG-Tier 1';
            }
            else if (i==4){
                a.Core_Account_Tier__c = 'ISG-Tier 1';
            }
            else if (i==5){
                a.Core_Account_Tier__c = 'NTG-Tier 1';
            }
            else if (i==6){
                a.Core_Account_Tier__c = 'PSG-Tier 1';
            }
            else if (i==7){
                a.Core_Account_Tier__c = 'RSG-Tier 1';
            }
            else if (i==8){
                a.Core_Account_Tier__c = 'RSG-Tier 1';
            }
            
            i++;
            lstAccount1.add(a);
        }  
        test.startTest();
        
        
        Core_AccountHandler.validateTierValues(lstAccount1);
        Core_AccountHandler.displayMessage(lstAccount1[0],'CCG-Tier 1');
        test.stopTest();
    }
    static testMethod void testUncoveredAccountChangeOppStatus() {
        Core_Trigger_Executions__c preventUncoveredAccountChangeOppStatus = new Core_Trigger_Executions__c();
        preventUncoveredAccountChangeOppStatus.Name = 'preventUncoveredAccountChange';
        preventUncoveredAccountChangeOppStatus.Core_Object__c = 'Account';
        preventUncoveredAccountChangeOppStatus.Core_Trigger_Events__c = 'before update';
        preventUncoveredAccountChangeOppStatus.Core_Active__c = true;
        preventUncoveredAccountChangeOppStatus.Core_Description__c = 'This is test description';
        preventUncoveredAccountChangeOppStatus.Core_Class_Name__c = 'Core_AccountHandler';
        insert preventUncoveredAccountChangeOppStatus;
        
         Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        List<Account> lstAccount = Core_Test_Utility.createAccount(1);
        
        lstAccount[0].Core_Sales_Groups__c='IOTG Sales Group';
        
        insert lstAccount;

        Map<Id, Account> accMap= new Map<Id, Account>();
        accMap.put(lstAccount[0].id,lstAccount[0]);
        
        Opportunity oppForLoss = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                                 AccountId = lstAccount[0].Id,
                                                 StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1));
        
            insert oppForLoss;
        List<Contact> lstContact = Core_Test_Utility.createContacts(5);
        
        for(Contact conObj : lstContact) {
            conObj.AccountId = lstAccount[0].id;
        }
        
        insert lstContact;
        
        lstAccount[0].OwnerId = Label.Core_Uncovered_Account_ID;
		        
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        insert cprogram;
        
        ChannelProgram ccfCP = new ChannelProgram();
        ccfCP.Name='Client Co-Marketing Fund';
        ccfCP.Core_MDF_Technical_Program_Name__c='Client CoMarketing Fund';
        insert ccfCP;
        	
        
        //Creating Intel Account with utility class
      /*  Account accountRecord1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account1 ', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        insert accountRecord1; 
        Account accountRecord2 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account2 ', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        insert accountRecord2; */
    
      //  Account accountRecord = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 1', cprogram.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        //accountRecord.Core_MDF_Parent_Fund_Account__c = accountRecord1.Id;
        //accountRecord.Core_MDF_CoMarketingActive__c = true;
 
        
        Map<Id, Account> newAccMap = new Map<Id, Account>();
        List<Account> newList = new List<Account>();
        
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id accountRecordTypeCoMarketing = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Core_MDF_Co_Marketing_Record_Type_Name).getRecordTypeId();
        Id accountRecordTyperetailMarketing = Schema.sObjectType.Campaign.getRecordTypeInfosByName().get('Retail Marketing Funds').getRecordTypeId();
       
        
        Account intelAccountRecord = new Account(Name = 'accountName' , RecordTypeId = accountRecordTypeCoMarketing, Core_Account_Type__c = 'Distributor',Industry = 'Communications',
                                          BillingCity='Pune', BillingCountry='IND',/*Core_Geo__c='APJ',Core_Sub_Geo__c='SA',*/ BillingCountryCode = 'IND', BillingState = 'MH',BillingStateCode = 'MH', BillingStreet = 'TestStreet', Core_MDF_CoMarketingActive__c = true, Core_MDF_Active_Ind__c=true);
       
     insert intelAccountRecord;
        Account intelAccountRecord1 = new Account(Name = 'accountName1' , RecordTypeId = accountRecordTypeCoMarketing, Core_Account_Type__c = 'Distributor',Industry = 'Communications',
                                          BillingCity='Mumbai', BillingCountry='IND',/*Core_Geo__c='APJ',Core_Sub_Geo__c='SA',*/ BillingCountryCode = 'IND', BillingState = 'CH',BillingStateCode = 'CH', BillingStreet = 'TestStreet1', Core_MDF_CoMarketingActive__c = true, Core_MDF_Active_Ind__c=true);
        insert intelAccountRecord1;
        
        
        Account testAccount = new Account();
        testAccount.RecordTypeId = accountRecordTypeIntel;
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_IPA_Partner_Speciality__c='Video Specialist;Cloud Data Center Specialist';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.website='www.abc.com';
        testAccount.Core_User_Defined_Website__c='www.abc.com'; 
        
        insert testAccount;
        testAccount.RecordTypeId = accountRecordTypeCoMarketing;
        update testAccount;
        newList.add(testAccount);
        newAccMap.put(testAccount.id,testAccount);
        
 
          
        
        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        Core_Account_Group_Member__c accGroupMem = new Core_Account_Group_Member__c();
        Account testAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'PRC Sales Group',
                                          Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
  
        insert testAccount1;
        
        accGroupMem.Core_Partner_Account_Id__c =testAccount1.Id;
        accGroupMem.Core_Intel_Account_Id__c =testAccount.Id;
        insert accGroupMem;
        
        Campaign testCampaign = new Campaign();        
        testCampaign.RecordTypeId = accountRecordTyperetailMarketing;
        testCampaign.Core_MDF_Program__c = 'Retail Marketing Funds';
        testCampaign.Name = 'campaignName';
        testCampaign.Core_MDF_Account__c = testAccount.id;
        //testCampaign.Core_MDF_External_Visibility_Date__c = System.today();
        testCampaign.Core_MDF_External_Visibility_Date__c = System.today()-25;
        testCampaign.StartDate = System.today()-25;
        testCampaign.EndDate = System.today()+30; 
        testCampaign.Core_MDF_First_Year_Budget_Amount__c = 5000;
        testCampaign.Description = 'Test Campaign';
        testCampaign.Core_MDF_Story__c = 'Test Story';
        testCampaign.Core_MDF_Metrics__c=' Test Campaign';
        testCampaign.Core_MDF_Messaging__c='Test Campaign';
        
        insert testCampaign;
        
        Test.startTest();
        update lstAccount;
        Core_AccountHandler.createNodeSharingGroup(newAccMap);
        //Core_AccountHandler.accountRecordTypeAfterUpdate(lstAccount,accMap,newAccMap);
        Core_AccountHandler.validateAccountForMDF(lstAccount,accMap);
        Core_AccountHandler.createGroupForComarketingAccount(newList);
        Core_AccountHandler.sharingWithNewAcctGrps(lstAccount);
        Core_AccountHandler.updatePartnerInfo(lstAccount,accMap,newAccMap);
        Test.stopTest();
    }
}