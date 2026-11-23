@isTest(SeeAllData=false)
/****************************************************************************************************************************************
* Class Name  : Core_MDF_ExceptionAccController_Test
* Version     : 1.0 
* Created Date: 05-09-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Nuzhath Zaiba                    05-09-2019                   Test class for Core_MDF_ExceptionAccountsController class
*****************************************************************************************************************************************/
public class Core_MDF_ExceptionAccController_Test {
    
    @TestSetUp
    static void createExceptionRecord(){
        
        //Create User with profile -IT ADMIN
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='IT Admin' limit 1].Id;
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        Database.insert(usr1);
        
        // Creating Account with utility class
        Test.startTest();
        System.runAs(usr1){
            //ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            Account acc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            // Creating Co-marketing Account with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Virtual Account map1', cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,acc.Id,false);
            acc1.Core_MDF_Parent_Fund_Account__c = acc.Id;
            acc1.Core_MDF_CoMarketing_Ultimate_Account__c = acc.Id;            
            Database.insert(acc1);
            acc1.IsPartner = true;
            Database.update(acc1);
        }
        
        
        //Create Exception Submitter User
        User submitter = Core_MDF_CCP_TestDataUtility.createUser(false);
        submitter.LastName = 'Exception Submitter';
        submitter.UserRoleId = usRole.Id;
        Database.insert(submitter);
        
        //Assign Exception Submitter permission set
        PermissionSet submitterPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Account_Manager' LIMIT 1];
        PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = submitterPS.Id, AssigneeId = submitter.Id);
        Database.insert(psa1);
        
        //Create Payment Admin User
        User paymentAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);
        paymentAdmin.LastName = 'Payment Admin';
        paymentAdmin.UserRoleId = usRole.Id ;
        Database.insert(paymentAdmin);
        
        //Create Payment Admin User
        User readOnlyUsr= Core_MDF_CCP_TestDataUtility.createUser(false);
        readOnlyUsr.LastName = 'Read Only User';
        readOnlyUsr.UserRoleId = usRole.Id ;
        Database.insert(readOnlyUsr);
        
        //Create Payment Admin permisssion set
        PermissionSet readOnlyPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Read_Only' LIMIT 1];
        PermissionSetAssignment readOnlyPSAssigment = new PermissionSetAssignment(PermissionSetId = readOnlyPS.Id, AssigneeId = readOnlyUsr.Id);
        Database.insert(readOnlyPSAssigment);
        
        //Create Payment Admin permisssion set
        PermissionSet paymentAdminPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Payment_Admin' LIMIT 1];
        PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = paymentAdminPS.Id, AssigneeId = paymentAdmin.Id);
        Database.insert(psa2);
        
        System.runAs(submitter){
            Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
            expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception';
            expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            expt.Core_MDF_Comments_txt__c = 'Test Comments';
            expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
            expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            expt.Core_MDF_Country_Region_nm__c = 'India';
            expt.Core_MDF_Company_Name_txt__c = '';
            expt.Core_MDF_Exception_Status_nm__c = 'Draft';
            insert expt;
            
        }
        Test.stopTest();
    }
    
    @isTest
    static void ExceptionPendingReview(){
        User usr = [ SELECT Id FROM User where LastName='Exception Submitter' LIMIT 1];
        
        //Fetch account details
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        List<String> accIdList = new List<String>();
        accIdList.add(accList[0].Id);
        
        
        //Fetch Exception
        List<Core_MDF_Exception__c> exptList = [SELECT Id, Core_MDF_Name_of_Exception_nm__c, 
                                                Core_MDF_Exception_Status_nm__c,Core_MDF_Company_Name_txt__c
                                                FROM Core_MDF_Exception__c LIMIT 1];
        exptList[0].Core_MDF_Exception_Status_nm__c = 'Pending Review';
        Test.startTest();
        update(exptList[0]);
        Test.stopTest();
        //Run as Exception Submitter
        System.runAs(usr){
            
            //Call Test class methods
            Core_MDF_ExceptionAccountsController.getIntelAccountRecords(exptList[0].Id);
            Core_MDF_ExceptionAccountsController.saveExceptionAccountMappingRecords(exptList[0].Id, accIdList, 
                                                                                    exptList[0].Core_MDF_Exception_Status_nm__c,
                                                                                    false, 'testAcc');
            
            Core_MDF_ExceptionAccountsController.saveExceptionAccountMappingRecords(exptList[0].Id, accIdList, 
                                                                                    exptList[0].Core_MDF_Exception_Status_nm__c, 
                                                                                    true, 'testAcc');
        }
        //Check if test class has suceessfully run
        Core_MDF_Exception__c expt = [SELECT Id, Core_MDF_Company_Name_txt__c 
                                      FROM Core_MDF_Exception__c 
                                      LIMIT 1];
        System.assertEquals(NULL,expt.Core_MDF_Company_Name_txt__c);
    }
    
    
    @isTest
    static void exceptionWithoutAccess(){
        
        User usr = [ SELECT Id FROM User where LastName='Payment Admin' LIMIT 1];
        
        //Fetch account details
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        List<String> accIdList = new List<String>();
        accIdList.add(accList[0].Id);
        
        //Fetch Exception
        List<Core_MDF_Exception__c> exptList = [SELECT Id, Core_MDF_Name_of_Exception_nm__c, 
                                                Core_MDF_Exception_Status_nm__c,Core_MDF_Company_Name_txt__c
                                                FROM Core_MDF_Exception__c LIMIT 1];
        
        exptList[0].Core_MDF_Exception_Status_nm__c = 'Denied';
        Test.startTest();
        update(exptList[0]);
        Test.stopTest();
        //Run as Payment Admin
        System.runAs(usr){
            
            Core_MDF_ExceptionAccountsController.saveExceptionAccountMappingRecords(exptList[0].Id, accIdList,
                                                                                    exptList[0].Core_MDF_Exception_Status_nm__c, 
                                                                                    true, 'testAcc');
        }
       //Check if test class has suceessfully run 
        Core_MDF_Exception__c expt = [SELECT Id, Core_MDF_Company_Name_txt__c 
                                      FROM Core_MDF_Exception__c 
                                      LIMIT 1];
        System.assertEquals(NULL,expt.Core_MDF_Company_Name_txt__c);
    } 
    
    @isTest
    static void exceptionWithExceptionAccountMapping(){
        
        User usr = [ SELECT Id FROM User where LastName='Exception Submitter' LIMIT 1];
        
        //Fetch account details
        List<Account> accList = [SELECT Id, Name
                                 FROM Account
                                 WHERE Name = 'Test Account 1'
                                 LIMIT 1];
        List<String> accIdList = new List<String>();
        accIdList.add(accList[0].Id);
        
        //Fetch Exceptions
        List<Core_MDF_Exception__c> exptList = [SELECT Id, Core_MDF_Name_of_Exception_nm__c, 
                                                Core_MDF_Exception_Status_nm__c,Core_MDF_Company_Name_txt__c
                                                FROM Core_MDF_Exception__c LIMIT 1];
        
      
        Core_MDF_Exception_Account_Mapping__c eam = new Core_MDF_Exception_Account_Mapping__c();
        eam.Core_MDF_Exception_id__c = exptList[0].Id;
        eam.Core_MDF_Account_id__c = accList[0].Id;
        Test.startTest();
        insert eam;
        Test.stopTest();
        //Run as Exception Submitter
        System.runAs(usr){
            Core_MDF_ExceptionAccountsController.getIntelAccountRecords(exptList[0].Id);
            
            Core_MDF_ExceptionAccountsController.saveExceptionAccountMappingRecords(exptList[0].Id, accIdList, 
                                                                                    exptList[0].Core_MDF_Exception_Status_nm__c,
                                                                                    false, 'Test Account 1');
        }
        //Check if test class has suceessfully run
         Core_MDF_Exception__c expt = [SELECT Id, Core_MDF_Company_Name_txt__c 
                                      FROM Core_MDF_Exception__c 
                                      LIMIT 1];
        System.assertEquals(NULL,expt.Core_MDF_Company_Name_txt__c);
    }
    
    @isTest
    static void exceptionWithReadOnlyAccessUser(){
        
        User usr = [ SELECT Id FROM User where LastName='Read Only User' LIMIT 1];
        
        //Fetch account details
        List<Account> accList = [SELECT Id, Name
                                 FROM Account
                                 WHERE Name = 'Test Account 1'
                                 LIMIT 1];
        List<String> accIdList = new List<String>();
        accIdList.add(accList[0].Id);
        
        //Fetch Exceptions
        List<Core_MDF_Exception__c> exptList = [SELECT Id, Core_MDF_Name_of_Exception_nm__c, 
                                                Core_MDF_Exception_Status_nm__c,Core_MDF_Company_Name_txt__c
                                                FROM Core_MDF_Exception__c LIMIT 1];
        
      
        Core_MDF_Exception_Account_Mapping__c eam = new Core_MDF_Exception_Account_Mapping__c();
        eam.Core_MDF_Exception_id__c = exptList[0].Id;
        eam.Core_MDF_Account_id__c = accList[0].Id;
        Test.startTest();
        insert eam;
        Test.stopTest();
        //Run as Exception Submitter
        System.runAs(usr){
            Core_MDF_ExceptionAccountsController.getIntelAccountRecords(exptList[0].Id);
            
            Core_MDF_ExceptionAccountsController.saveExceptionAccountMappingRecords(exptList[0].Id, accIdList, 
                                                                                    exptList[0].Core_MDF_Exception_Status_nm__c,
                                                                                    false, 'Test Account 1');
        }
        //Check if test class has suceessfully run
         Core_MDF_Exception__c expt = [SELECT Id, Core_MDF_Company_Name_txt__c 
                                      FROM Core_MDF_Exception__c 
                                      LIMIT 1];
        System.assertEquals(NULL,expt.Core_MDF_Company_Name_txt__c);
    }
}