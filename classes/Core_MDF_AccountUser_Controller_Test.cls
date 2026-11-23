/****************************************************************************************************************************************
* Class Name  : Core_MDF_AccountUser_Controller_Test
* Version     : 1.0 
* Created Date: 09-08-2019
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture-KK                    09/08/2019                    Created to test Account User add/delete functionality 
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_AccountUser_Controller_Test {
    // test method for data setup
    @TestSetup static void setUpData(){
        //Create Exchnage rates records
        
        List<Core_MDF_Currency_Exchange_Rates__c> newValues = new List<Core_MDF_Currency_Exchange_Rates__c>();
        
        Core_MDF_Currency_Exchange_Rates__c record2 = new Core_MDF_Currency_Exchange_Rates__c();
        record2.Name= 'INR';
        record2.Core_MDF_Exchange_Rate__c = 1;
        record2.Core_MDF_Market_Date__c =System.today();
        record2.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        record2.Core_MDF_Unique_Key__c = 'INR'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        newValues.add(record2); 
        
        Core_MDF_Currency_Exchange_Rates__c record3 = new Core_MDF_Currency_Exchange_Rates__c();
        record3.Name= 'USD';
        record3.Core_MDF_Exchange_Rate__c = 1;
        record3.Core_MDF_Market_Date__c =System.today();
        record3.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        record3.Core_MDF_Unique_Key__c = 'USD'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        newValues.add(record3); 
        database.insert(newValues);
        
        
        Test.startTest();
        
        List<Account> accList = new List<Account>();
        List<Account> updateAccList = new List<Account>();
        
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        // Creating Intel Account with utility class
       /* Account acc1 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account ', cp.Id,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        acc1.BillingCity = 'Test City';         
        acc1.BillingCountry= 'AUS';
        acc1.BillingStreet= 'Test Street';
        Database.insert(acc1); */
        
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        insert acc1;
        
        // Creating Co-marketing Account with utility class
        Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 1', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        accList.add(acc);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 2', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
        acc2.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        accList.add(acc2);
        
        Database.insert(accList);
        
        acc1.IsPartner = true;
        updateAccList.add(acc1);
        acc.IsPartner = true;
        updateAccList.add(acc);
        acc2.IsPartner = true;
        updateAccList.add(acc2);
        
        Database.update(updateAccList);
        
        //Creating Contact for Partner User
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,true);
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,true);
        Contact conRecord3 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,true);
        
        //Creating Case on the Account
        Case case1 = new Case(AccountId=acc.Id);
        Database.insert(case1);
        
        // Creating User with utility class 
        List<User> userList = new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        userList.add(usr);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        userList.add(usr1);
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.Email='test2@example.com';
        usr2.ContactId = conRecord2.Id;
        usr2.ProfileId = profileId;
        usr2.isActive = true;
        userList.add(usr2);
                
        Database.insert(userList);        
        
        
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        // Create PMB for the above Account 
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc.Id,cp.Id,123456,System.today(),Date.newInstance(System.today().year(),12,31),false);
        pmbRecord.IsIgnoreValidation = true;
        insert pmbRecord;
        
        
        // Create PFA records for the above accounts :
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA',pmbRecord, acc, 1234,true);
        
        System.runAs(usr){
            Core_MDF_Partner_Node_User_Mapping__c pnumRecord = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc.Id,usr1.Id,true);
        }
        
        Test.stopTest();
        
    }
    
    // Test method
    @isTest static void testIsAccountUserEligibleForDelete(){
        Test.startTest();
        
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        Core_MDF_Partner_Node_User_Mapping__c pnumRecord = [SELECT ID,Core_MDF_Account__c,Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_Account__r.Name = 'Test Account 1' AND Core_MDF_User__r.Email = 'test1@example.com'];                                             
        List<Id> deleteRecordList = new List<Id>();
        try{      
            System.runAs(usr){
                System.assertEquals(true,Core_MDF_AccountUser_Controller.isAccountUserEligibleForDelete(pnumRecord.Id));
                deleteRecordList.add(pnumRecord.Id);
                Core_MDF_AccountUser_Controller.deleteAccountUsers(deleteRecordList);
                List<Core_MDF_Partner_Node_User_Mapping__c> pnumRecordList = [SELECT ID,Core_MDF_Account__c,Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_Account__r.Name = 'Test Account 1' AND Core_MDF_User__r.Email = 'test1@example.com']; 
                
                System.assertEquals(pnumRecordList.size(),0);                       
            }
        }
        catch(Exception e){System.debug('' + e.getMessage());}
        
        Test.stopTest();
    }
    
     // Test method
    @isTest static void testgetResults(){
        Test.startTest();
            User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        	ChannelProgram cp = [SELECT Id from ChannelProgram Limit 1];
            System.runAs(usr){
                Account acc = [Select Id,Name from Account where Name='Test Account 2'];
                Account acc1 = [Select Id,Name from Account where Name='Test Account 1'];
                List<Id> accountIdsList = new List<Id>();
                accountIdsList.add(acc.Id);
                User user = [Select Id from User where Email='test2@example.com'];
                User user1 = [Select Id from User where Email='test1@example.com'];
                List<Id> userIdsList = new List<Id>();
                userIdsList.add(user.Id);
                Core_MDF_LWC_AccountUserController.fetchUserAccessiblePrograms();
                Core_MDF_LWC_AccountUserController.getResults('Account', 'Name', 'test', cp.Id);
                Core_MDF_LWC_AccountUserController.getResults('User', 'Email', 'test', cp.Id);
                Core_MDF_LWC_AccountUserController.fetchUserInfo();
                Core_MDF_LWC_AccountUserController.findSelectedUsers(acc1.Id);
                Core_MDF_LWC_AccountUserController.findSelectedAccounts(user1.Id, cp.Id);
                Core_MDF_LWC_AccountUserController.saveAccountUserMapping(acc.Id, userIdsList, 'AccountToUser', cp.Id);
                Core_MDF_LWC_AccountUserController.saveAccountUserMapping(acc1.Id, userIdsList, 'AccountToUser', cp.Id);
                Core_MDF_LWC_AccountUserController.saveAccountUserMapping(user.Id, accountIdsList, 'UserToAccount', cp.Id);
                String returnString = Core_MDF_LWC_AccountUserController.saveAccountUserMapping(user1.Id, accountIdsList, 'UserToAccount', cp.Id);
                System.assertEquals(returnString,'');  
            }
        Test.stopTest();
    }
    /* Areefa: Method to testAccountUserEligibleForCreateEdit */
    @isTest
    public static void testAccountUserEligibleForCreateEdit(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            boolean hasAccess = Core_MDF_LWC_AccountUserController.isAccountUserEligibleForCreateEdit();
            system.assertEquals(true,hasAccess);
        }
    }
     
    @isTest
    public static void testDoesNothaveAccountUserPermission(){
       PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_External_Claim_Submitter'];        
        User usr2 = [ SELECT Id FROM User WHERE Email='test2@example.com'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = usr2.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
            System.runAs(usr2){
                boolean hasAccess = Core_MDF_LWC_AccountUserController.isAccountUserEligibleForCreateEdit();
                system.assertEquals(false,hasAccess);
            }        
    }
    
 
    @isTest
    static void testSaveAccountUserExceptionMethod()
    {
        try{
            Test.startTest();
            User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        	ChannelProgram cp = [SELECT Id from ChannelProgram Limit 1];
            System.runAs(usr){
                Account acc = [Select Id,Name from Account where Name='Test Account 2'];
                Account acc1 = [Select Id,Name from Account where Name='Test Account 1'];
                List<Id> accountIdsList = new List<Id>();
                accountIdsList.add(acc.Id);
                User user = [Select Id from User where Email='test2@example.com'];
                User user1 ; //= [Select Id from User where Email='test1@example.com'];                
                List<Id> userIdsList = new List<Id>();
                userIdsList.add(user.Id);
                Core_MDF_LWC_AccountUserController.fetchUserAccessiblePrograms();
                Core_MDF_LWC_AccountUserController.getResults('Account', 'Name', 'test', cp.Id);
                Core_MDF_LWC_AccountUserController.getResults('User', 'Email', 'test', cp.Id);
                Core_MDF_LWC_AccountUserController.fetchUserInfo();
                Core_MDF_LWC_AccountUserController.findSelectedUsers(acc1.Id);
                Core_MDF_LWC_AccountUserController.findSelectedAccounts(user1.Id, cp.Id);
                Core_MDF_LWC_AccountUserController.saveAccountUserMapping(acc.Id, userIdsList, 'AccountToUser', cp.Id);
                Core_MDF_LWC_AccountUserController.saveAccountUserMapping(acc1.Id, userIdsList, 'AccountToUser', cp.Id);
                Core_MDF_LWC_AccountUserController.saveAccountUserMapping(user.Id, accountIdsList, 'UserToAccount', cp.Id);
                String returnString = Core_MDF_LWC_AccountUserController.saveAccountUserMapping(user1.Id,accountIdsList, 'UserToAccount', cp.Id);
            	System.debug('returnString::::' +returnString);
            }
        Test.stopTest();
        }catch(Exception e){
            System.assertNotEquals(NULL,e);
        }
        
    }
    
}