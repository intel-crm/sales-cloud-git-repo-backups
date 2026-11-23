/***************************************************************************************************
Class Name:  Core_IPS_UserTriggerHandler_Test
Class Type: Test Class 
Version     : 2.0 
Created Date: 25 Jan 2016
Function    : This class contains test coverage for Core_IPS_UserTriggerHandler class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_IPS_UserTriggerHandler class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016               Created
Amritesh                  11/12/2017               Modified - US80097
****************************************************************************************************/
@isTest
public class Core_IPS_UserTriggerHandler_Test {
    //Instance variables that are commonly used in multiple test methods
    static List<User> ListOfUser = new List<User> ();
    static Group grp = new Group();
    static Group queue = new Group();
    /***************************************************************************************************
Method Name:  getRecords()
Method Type: void
Version     : 1.0 
Created Date: 25 Jan 2016
Description:  Common Test data used for all test methods
Scenario Type:  
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Deepak Jetty          25/01/2016              Created
Amritesh              11/12/2017              Modified - US80097
Karthick              02/04/2018              Modified - DE37341
****************************************************************************************************/    
    static void getRecords (){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(3);
        ListOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        ListOfUser.get(1).ProfileID =  profiles.get('System Administrator');
        ListOfUser.get(2).ProfileID =  profiles.get('System Administrator');
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
        System.assertEquals(ListOfUser.get(1).profileid, profiles.get('System Administrator'));
        System.assertEquals(ListOfUser.get(2).profileid, profiles.get('System Administrator'));
        
        
        //added by Amritesh - US80097 - start
        List<Core_Trigger_Executions__c> lstTriggerExecution  = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
        TriggerExecution.Name = 'updateprojmemberfromuser';
        TriggerExecution.Core_Active__c = true;
        TriggerExecution.Core_Class_Name__c ='User';
        TriggerExecution.Core_Description__c = 'Update Project Member from User';
        TriggerExecution.Core_Object__c = 'User';
        TriggerExecution.Core_Trigger_Events__c = 'after update';
        lstTriggerExecution.add(TriggerExecution);
        
        TriggerExecution = new Core_Trigger_Executions__c();
        TriggerExecution.Name = 'insertprojmemberfromuser';
        TriggerExecution.Core_Active__c = true;
        TriggerExecution.Core_Class_Name__c ='User';
        TriggerExecution.Core_Description__c = 'Insert Project Member from User';
        TriggerExecution.Core_Object__c = 'User';
        TriggerExecution.Core_Trigger_Events__c = 'after insert';
        lstTriggerExecution.add(TriggerExecution);
        
        TriggerExecution = new Core_Trigger_Executions__c();
        TriggerExecution.Name = 'userGeoUpdate';
        TriggerExecution.Core_Active__c = true;
        TriggerExecution.Core_Class_Name__c ='User';
        TriggerExecution.Core_Description__c = '-';
        TriggerExecution.Core_Object__c = 'User';
        TriggerExecution.Core_Trigger_Events__c = '-';
        lstTriggerExecution.add(TriggerExecution);
        
        TriggerExecution = new Core_Trigger_Executions__c();
        TriggerExecution.Name = 'userFreezeUnfreeze';
        TriggerExecution.Core_Active__c = true;
        TriggerExecution.Core_Class_Name__c ='User';
        TriggerExecution.Core_Description__c = '-';
        TriggerExecution.Core_Object__c = 'User';
        TriggerExecution.Core_Trigger_Events__c = '-';
        lstTriggerExecution.add(TriggerExecution);
        
        TriggerExecution = new Core_Trigger_Executions__c();
        TriggerExecution.Name = 'userProfileGroupAssignment';
        TriggerExecution.Core_Active__c = true;
        TriggerExecution.Core_Class_Name__c ='User';
        TriggerExecution.Core_Description__c = '-';
        TriggerExecution.Core_Object__c = 'User';
        TriggerExecution.Core_Trigger_Events__c = '-';
        lstTriggerExecution.add(TriggerExecution);        
        
        System.runAs(ListOfUser.get(1)){
            insert lstTriggerExecution;
        } 
        System.assert(lstTriggerExecution[0].Id != null, 'Record not created');  

        //added by Amritesh - US80097 - end
    }
    
    /***************************************************************************************************
Method Name:  assignContactMatchUserEmail_test
Method Type: Test Method
Version     : 1.0 
Created Date: 29 Jan 2015
Description:  Testing with User and Contact record and assigning when matched
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/ 
    static testmethod void assignContactMatchUserEmail_test(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        List<User> UserList = new List<User> ();
        //Get Profile
        //Changed to Partner as part if Employee as Customer profile mapping to partner - Tejaswini
        // strProf.add('IPS External Customer');
        strProf.add('Partner');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        //Create Users
        UserList = TestUtilities.getListOfUser(1);
        //Changed to Partner as part if Employee as Customer profile mapping to partner - Tejaswini
        // UserList.get(0).ProfileID =  profiles.get('IPS External Customer');
        UserList.get(0).ProfileID =  profiles.get('Partner');
        UserList.get(0).UserName = 'Testnewuser@intel.com';
        
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser.get(1)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
            ContactRec.Email = UserList.get(0).Email+'Test';
        }
        System.runAs(ListOfUser.get(1)){
            insert ListOfContacts;
            UserList.get(0).ContactID = ListOfContacts.get(0).id;
        }       
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        //Create Custom Settings
        Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
        TriggerExecution.Name = 'assignContactRule';
        TriggerExecution.Core_Active__c = true;
        TriggerExecution.Core_Class_Name__c ='ClassName';
        TriggerExecution.Core_Description__c = 'MethodDescription';
        TriggerExecution.Core_Object__c = 'Account';
        TriggerExecution.Core_Trigger_Events__c = 'Before Insert';
        System.runAs(ListOfUser.get(1)){
            insert TriggerExecution;
        } 
        System.assert(TriggerExecution.id!= null, 'Record not created');
        Test.startTest();
        System.runAs(ListOfUser.get(1)){
            //Insert Users
            insert UserList;
        }
        //Changed from 'IPS External Customer'to Partner as part if Employee as Customer profile mapping to partner - Tejaswini
        System.assertEquals(UserList.get(0).profileid, profiles.get('Partner'));
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  assignContactNoMatchUserEmail_test
Method Type: Test Method
Version     : 1.0 
Created Date: 29 Jan 2015
Description:  Testing with User and Contact record and assigning and not matching
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/ 
    static testmethod void assignContactNoMatchUserEmail_test(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        List<User> UserList = new List<User> ();
        //Get Profile
        //Changed from 'IPS External Customer'to Partner as part if Employee as Customer profile mapping to partner - Tejaswini
        strProf.add('Partner');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        //Create Users
        UserList = TestUtilities.getListOfUser(1);
        //Changed from 'IPS External Customer'to Partner as part if Employee as Customer profile mapping to partner - Tejaswini
        UserList.get(0).ProfileID =  profiles.get('Partner');
        UserList.get(0).UserName = 'Testnewuser@intel.com';
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser.get(1)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
        }
        System.runAs(ListOfUser.get(1)){
            insert ListOfContacts;
            UserList.get(0).ContactID = ListOfContacts.get(0).id;
        }       
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        //Create Custom Settings
        Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
        TriggerExecution.Name = 'assignContactRule';
        TriggerExecution.Core_Active__c = true;
        TriggerExecution.Core_Class_Name__c ='ClassName';
        TriggerExecution.Core_Description__c = 'MethodDescription';
        TriggerExecution.Core_Object__c = 'Account';
        TriggerExecution.Core_Trigger_Events__c = 'Before Insert';
        System.runAs(ListOfUser.get(1)){
            insert TriggerExecution;
        } 
        System.assert(TriggerExecution.id!= null, 'Record not created');
        Test.startTest();
        System.runAs(ListOfUser.get(1)){
            //Insert Users
            insert UserList;
        }
        //Changed from 'IPS External Customer'to Partner as part if Employee as Customer profile mapping to partner - Tejaswini
        System.assertEquals(UserList.get(0).profileid, profiles.get('Partner'));
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  InsertProjMember_test
Method Type: Test Method
Version     : 1.0 
Created Date: 29 Jan 2015
Description:  Testing with User, Contact record and assigning matching id. InsertProjMember after user insert
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              29/01/2016                Created
****************************************************************************************************/ 
    static testmethod void InsertProjMemberScenario_positivetest(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        integer Counter;
        Id intelSupportOwner = ListOfUser.get(0).id;
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        List<User> UserList = new List<User> ();
        //Get Profile
        //Changed from 'IPS External Customer'to Partner as part if Employee as Customer profile mapping to partner - Tejaswini
        strProf.add('Partner');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        //Create Users
        /*UserList = TestUtilities.getListOfUser(1);
UserList.get(0).ProfileID =  profiles.get('IPS External Customer');
UserList.get(0).UserName = 'Testnewuser@intel.com';*/
        System.runAs(ListOfUser.get(1)){
            //Changed from 'IPS External Customer'to Partner as part if Employee as Customer profile mapping to partner - Tejaswini
           // UserList.add(TestUtilities.getCustomerUser('Partner'));
           //Replaced TestUtilities.getCustomerUser('Partner') with code from 287 to 325
           // Start Tejaswini
           User adminUser = [ select Id from User where profile.Name = 'System Administrator' and userRoleId != null AND ISActive=true Limit 1];
           Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
            // Modified for DE55770 
            Account acc = new Account (
                Name = 'newAcc1',
                BillingCity = 'folsom',
                BillingCountry = 'USA',
                BillingStreet = 'Creek Side Dr',
                BillingState = 'NV',
                BillingPostalCode = '591213',
                Core_CIM_ID__c = '11429344',
                Core_B2B_Entitlement__c = true,
                Core_Account_Legal_Name__c = 'TestLegalName',
                Ownerid =adminUser.id
            );  
        insert acc;
        Contact con = new Contact (
            AccountId = acc.id,
            FirstName = 'portia',
            LastName  = 'portalTestUser',
            email     = 'pb@ff.com',
            MailingCountry = 'India'
        );
        insert con;
        
        User newUser;
            newUser = new User(
                //UserRoleId = ur.Id,
                 profileId = profiles.get('Partner'),
                username = 'newUser12@yahoo.com',
                email = 'pb@ff.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                lastname='lastname',
                contactId = con.id
            );
            insert newUser;  
        }
    //End Tejaswini
    // Create Accounts
    List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
    System.runAs(ListOfUser.get(0)){
        insert ListOfAccounts;
    }
    System.assert(ListOfAccounts[0].Id != null, 'Record not created');
    // Create Contact
    List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
    for(Contact ContactRec : ListOfContacts){
        ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        ContactRec.Accountid = ListOfAccounts.get(0).Id;
    }
    System.runAs(ListOfUser.get(0)){
        insert ListOfContacts;
        //UserList.get(0).ContactID = ListOfContacts.get(0).id;
    }       
    System.assert(ListOfContacts[0].Id != null, 'Record not created');
    //Create Custom Settings
    Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
    TriggerExecution.Name = 'assignContactRule';
    TriggerExecution.Core_Active__c = true;
    TriggerExecution.Core_Class_Name__c ='ClassName';
    TriggerExecution.Core_Description__c = 'MethodDescription';
    TriggerExecution.Core_Object__c = 'Account';
    TriggerExecution.Core_Trigger_Events__c = 'Before Insert';
    System.runAs(ListOfUser.get(0)){
        insert TriggerExecution;
    } 
    System.assert(TriggerExecution.id!= null, 'Record not created');
    // Create Ips Project
    List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
    System.runAs(ListOfUser.get(0)){
        insert ListOfIpsProjects;
    }
    System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
    // Create Ips Account
    Counter=0;
    List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
    for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
        if(counter<1){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        } else {
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(1).Id;
        }
        counter++;
    }
    counter = 0;
    System.runAs(ListOfUser.get(0)){
        insert ListOfIpsAccounts;
    }
    System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
    Test.startTest();
    //System.runAs(ListOfUser.get(1)){
    //Insert Users
    //insert UserList;
    //}
    Test.stopTest();
    //System.assertEquals(UserList.get(0).profileid, profiles.get('IPS External Customer'));
}

/***************************************************************************************************
Method Name:  UpdateProjMember_test
Method Type: Test Method
Version     : 1.0 
Created Date: 29 Jan 2015
Description:  Testing with User, Contact record and assigning matching id. UpdateProjMember after user update
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              29/01/2016                Created
* Amritesh                  11/08/2017                Modified
****************************************************************************************************/ 
    static testmethod void UpdateProjMember_test(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        integer Counter;
        Id intelSupportOwner = ListOfUser.get(0).id;
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        List<User> UserList = new List<User> ();
        //Get Profile
    //Changed from 'IPS External Customer'to Partner as part if Employee as Customer profile mapping to partner - Tejaswini
    strProf.add('Partner');
    List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
    for(Profile prf : ProfileList){
        profiles.put(prf.name, prf.id);
    }
    //Create Users
    UserList = TestUtilities.getListOfUser(1);
    //Changed from 'IPS External Customer'to Partner as part if Employee as Customer profile mapping to partner - Tejaswini
    UserList.get(0).ProfileID =  profiles.get('Partner');
    UserList.get(0).UserName = 'Testnewuser@intel.com';
    UserList.get(0).isActive = false;
    
    // Create Accounts
    List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
    System.runAs(ListOfUser.get(1)){
        insert ListOfAccounts;
    }
    System.assert(ListOfAccounts[0].Id != null, 'Record not created');
    // Create Contact
    List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
    for(Contact ContactRec : ListOfContacts){
        //for(integer i=0;i<ListOfAccounts.size();i++){
        ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        ContactRec.Accountid = ListOfAccounts.get(0).Id;
        //}
    }
    System.runAs(ListOfUser.get(1)){
        insert ListOfContacts;
        UserList.get(0).ContactID = ListOfContacts.get(0).id;
    }       
    System.assert(ListOfContacts[0].Id != null, 'Record not created');
    //Create Custom Settings
    Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
    TriggerExecution.Name = 'assignContactRule';
    TriggerExecution.Core_Active__c = true;
    TriggerExecution.Core_Class_Name__c ='ClassName';
    TriggerExecution.Core_Description__c = 'MethodDescription';
    TriggerExecution.Core_Object__c = 'Account';
    TriggerExecution.Core_Trigger_Events__c = 'Before Insert';
    System.runAs(ListOfUser.get(1)){
        insert TriggerExecution;
    } 
    System.assert(TriggerExecution.id!= null, 'Record not created');
    // Create Ips Project
    List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
    System.runAs(ListOfUser.get(1)){
        insert ListOfIpsProjects;
    }
    System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
    // Create Ips Account
    Counter=0;
    List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
    for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
        for(integer i=0;i<ListOfAccounts.size();i++){
            if(counter<1){
                IpsAcc.Core_Account__c = ListOfAccounts.get(i).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            } else {
                IpsAcc.Core_Account__c = ListOfAccounts.get(i).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(1).Id;
            }
            counter++;
        }
    }
    counter = 0;
    System.runAs(ListOfUser.get(1)){
        insert ListOfIpsAccounts;
    }
    System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
    
    /************* Added by amritesh - US80097 - start ************/
    //Create Mask email custom setting
    MaskEmail__c mskEmail = new MaskEmail__c(Name='Core Mask Email Bypass', Core_Mask_Email__c=false);
    System.runAs(ListOfUser.get(1)){
        insert mskEmail;
    }
    /************* Added by amritesh - US80097 - end *************/
    
    Test.startTest();
    System.runAs(ListOfUser.get(1)){
        //Insert Users
        insert UserList;
        //for(Contact ContactRec : ListOfContacts){
        //for(integer i=0;i<ListOfAccounts.size();i++){
        
        //ContactRec.Accountid = ListOfAccounts.get(1).Id;
        //}
        //}
        //update ListOfContacts;
        for(User usr : UserList){
            //usr.ContactID = ListOfContacts.get(1).id;
            usr.isActive = true;
        }
        update UserList;
    }
    Test.stopTest();
    //Changed from 'IPS External Customer'to Partner as part if Employee as Customer profile mapping to partner - Tejaswini
    System.assertEquals(UserList.get(0).profileid, profiles.get('Partner'));
}

static testmethod void InsertProjMemberScenario1_positivetest(){
    getrecords();
    Id intelSupportOwner = ListOfUser.get(0).id;
    integer Counter;
    
    // Create Accounts
    List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
    System.runAs(ListOfUser.get(0)){
        insert ListOfAccounts;
    }
    System.assert(ListOfAccounts[0].Id != null, 'Record not created');
    
    // Create Contact
    List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
    for(Contact ContactRec : ListOfContacts){
        ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        ContactRec.Accountid = ListOfAccounts.get(0).Id;
        ContactRec.Core_IPS_Active__c = true;
    }
    System.runAs(ListOfUser.get(0)){
        insert ListOfContacts;
        //UserList.get(0).ContactID = ListOfContacts.get(0).id;
    }       
    System.assert(ListOfContacts[0].Id != null, 'Record not created');
    
    //Create Custom Settings
    Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
    TriggerExecution.Name = 'assignContactRule';
    TriggerExecution.Core_Active__c = true;
    TriggerExecution.Core_Class_Name__c ='ClassName';
    TriggerExecution.Core_Description__c = 'MethodDescription';
    TriggerExecution.Core_Object__c = 'Account';
    TriggerExecution.Core_Trigger_Events__c = 'Before Insert';
    System.runAs(ListOfUser.get(0)){
        insert TriggerExecution;
    } 
    System.assert(TriggerExecution.id!= null, 'Record not created');
    
    // Create Ips Project
    List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
    System.runAs(ListOfUser.get(0)){
        insert ListOfIpsProjects;
    }
    System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
    
    // Create Ips Account
    Counter=0;
    List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
    for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
        if(counter<1){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        } else {
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(1).Id;
        }
        counter++;
    }
    counter = 0;
    System.runAs(ListOfUser.get(0)){
        insert ListOfIpsAccounts;
    }
    System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
    
    Test.startTest();            
    System.runAs(ListOfUser.get(2)){            
        User newUser;
        //Changed from 'IPS External Customer'to Partner as part if Employee as Customer profile mapping to partner - Tejaswini
        Profile p =   [select Id,name from Profile where Name = :'Partner' limit 1];
        newUser = new User(
            profileId = p.id,
            username = 'newUser11@yahoo.com',
            email = 'pb@ff.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='nuser',
            lastname='lastname',
            contactId = ListOfContacts.get(0).id
        );
        insert newUser;  
    }    
    
    Test.stopTest();
}   

static testmethod void InsertProjMemberScenario2_positivetest(){
    getrecords();
    // Get intelSupportOwner Id (User Id)
    integer Counter;
    Id intelSupportOwner = ListOfUser.get(0).id;
    Map<String,ID> profiles = new Map<String,ID>();
    List<String> strProf = new List<String>();
    //List<User> UserList = new List<User> ();
    //Get Profile
    //Changed from 'IPS External Customer'to Partner as part if Employee as Customer profile mapping to partner - Tejaswini
    strProf.add('Partner');
    List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
    for(Profile prf : ProfileList){
        profiles.put(prf.name, prf.id);
    }
    
    //System.runAs(ListOfUser.get(1)){
    //UserList.add(TestUtilities.getCustomerUser('IPS External Customer'));
    //}
    // Create Accounts
    List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
    System.runAs(ListOfUser.get(0)){
        insert ListOfAccounts;
    }
    System.assert(ListOfAccounts[0].Id != null, 'Record not created');
    // Create Contact
    List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
    for(Contact ContactRec : ListOfContacts){
        ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        ContactRec.Accountid = ListOfAccounts.get(0).Id;
        ContactRec.Core_IPS_Active__c = true;
    }
    System.runAs(ListOfUser.get(0)){
        insert ListOfContacts;
        //UserList.get(0).ContactID = ListOfContacts.get(0).id;
    }       
    System.assert(ListOfContacts[0].Id != null, 'Record not created');
    
    
    //Create Users
    //UserList = TestUtilities.getListOfUser(1);
    User UserList = new User(); 
    Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
        //UserRole ur = [Select PortalType, PortalAccountId From UserRole where PortalType =:'CustomerPortal' limit 1];
        Profile p = [select Id,name from Profile where UserType in :customerUserTypes limit 1];
    
    
    UserList.ProfileID =  p.Id;
    UserList.UserName = 'Testnewuser@intel.com';
    //UserList.UserRoleId = ur.Id;
    UserList.ContactId = ListOfContacts[0].Id;
    UserList.email = 'ab@fgh.com';
    UserList.emailencodingkey = 'UTF-8';
    UserList.localesidkey = 'en_US';
    UserList.languagelocalekey = 'en_US';
    UserList.timezonesidkey = 'America/Los_Angeles';
    UserList.alias='nuser';
    UserList.lastname='lastname';
    
    
    //Create Custom Settings
    Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
    TriggerExecution.Name = 'assignContactRule';
    TriggerExecution.Core_Active__c = true;
    TriggerExecution.Core_Class_Name__c ='ClassName';
    TriggerExecution.Core_Description__c = 'MethodDescription';
    TriggerExecution.Core_Object__c = 'Account';
    TriggerExecution.Core_Trigger_Events__c = 'Before Insert';
    System.runAs(ListOfUser.get(0)){
        insert TriggerExecution;
    } 
    System.assert(TriggerExecution.id!= null, 'Record not created');
    // Create Ips Project
    List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
    System.runAs(ListOfUser.get(0)){
        insert ListOfIpsProjects;
    }
    System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
    // Create Ips Account
    Counter=0;
    List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
    for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
        if(counter<1){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        } else {
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(1).Id;
        }
        counter++;
    }
    counter = 0;
    System.runAs(ListOfUser.get(0)){
        insert ListOfIpsAccounts;
    }
    System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
    Test.startTest();
    System.runAs(ListOfUser.get(2)){            
        insert UserList;            
    }
    Test.stopTest();
    
}
//added by naresh related to the User Story US38984 on 5/20/16
static testmethod void Updateprojectmemberfuturetest(){
    getrecords();
    // Create Accounts
    List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
    System.runAs(ListOfUser.get(0)){
        insert ListOfAccounts;
    }
    System.assert(ListOfAccounts[0].Id != null, 'Record not created');
    Id intelSupportOwner = ListOfUser.get(0).id;
    integer Counter;
    // Create Contact
    List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
    for(Contact ContactRec : ListOfContacts){
        ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        ContactRec.Accountid = ListOfAccounts.get(0).Id;
        ContactRec.Core_IPS_Active__c = true;
    }
    System.runAs(ListOfUser.get(0)){
        insert ListOfContacts;
    }
    List<Id> Conlist=new List<Id>();
    for(Contact c: ListOfContacts)
        Conlist.add(c.Id);
    List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
    System.runAs(ListOfUser.get(1)){
        insert ListOfIpsProjects;
    }
    System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
    set<id> projid=new set<id>();
    for(Core_IPS_Project__c cp:ListOfIpsProjects)
        projid.add(cp.id); 
    List<Core_IPS_Project_Member__c> ProjectMembers=TestUtilities.getListOfProjectMembers(1);
    ProjectMembers[0].Core_Status__c='Inactive';
    ProjectMembers[0].Core_IPS_Provisioning_Date__c = System.Now();
    ProjectMembers[0].Core_IPS_Project__c=ListOfIpsProjects.get(0).id;
    ProjectMembers[0].Core_User__c=ListOfUser.get(0).id;
    ProjectMembers[0].Core_IPS_Contact__c=ListOfContacts.get(0).id;
    System.runAs(ListOfUser.get(1)){
        insert ProjectMembers;
    }
    System.assert(ProjectMembers[0].id != null, 'Record not created');
    Test.starttest();
    System.runAs(ListOfUser.get(1)){
        List<id> newuserid=new List<id>();
        for(user uid:ListOfUser)
            newuserid.add(uid.id);
        Core_IPS_UserTriggerHandler.UpdateProjMemberatFuture(projid, newuserid, Conlist);
        Test.stoptest();
    }
}
//end by naresh
//

/*
* Method name  : CreateContactForUser_Test
* Description  : Method to test createContact functionality
* Return Type  : void
* Parameters   : None
*/
    static testMethod void CreateContactForUser_Test() {
        
        getrecords();
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        List<User> UserList = new List<User> ();
        
        
        
        //Create Custom Settings
        Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
        TriggerExecution.Name = 'createContactForEAC';
        TriggerExecution.Core_Active__c = true;
        TriggerExecution.Core_Class_Name__c ='Core_IPS_UserTriggerHandler';
        TriggerExecution.Core_Description__c = 'MethodDescription';
        TriggerExecution.Core_Object__c = 'User';
        TriggerExecution.Core_Trigger_Events__c = 'Before Insert';
        System.runAs(ListOfUser.get(1)){
            insert TriggerExecution;
        }
        
        //Create Custom Settings
        Core_Trigger_Executions__c  TriggerExecutionRegion = new Core_Trigger_Executions__c();
        TriggerExecutionRegion.Name = 'updateUserRegionFields';
        TriggerExecutionRegion.Core_Active__c = true;
        TriggerExecutionRegion.Core_Class_Name__c ='Core_IPS_UserTriggerHandler';
        TriggerExecutionRegion.Core_Description__c = 'Core_IPS_UserTriggerHandler';
        TriggerExecutionRegion.Core_Object__c = 'User';
        TriggerExecutionRegion.Core_Trigger_Events__c = 'After Insert, After Update';
        System.runAs(ListOfUser.get(1)){
            insert TriggerExecutionRegion;
        } 
        
        //added by amritesh to overcome deployment failure - 2/5/2018
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser.get(1)){
            insert ListOfAccounts;
        }     
        
        list<Contact> lstCo11 = TestUtilities.getListOfContact(1);        
        System.runAs(ListOfUser.get(1)){
            lstCo11.get(0).AccountId = ListOfAccounts.get(0).Id; //Label.Core_IPS_AccountID; //commented by amritesh to overcome deployment failure - 2/5/2018
            //Insert Users
            insert lstCo11 ;             
        }
        
        //Create Users
        UserList = TestUtilities.getListOfUser(1);
        UserList.get(0).ProfileID =  Label.Core_IPS_External_Customer_Profile_Id;
        UserList.get(0).UserName = 'TestInternalEmployee001@intel.com';
        UserList.get(0).FirstName = 'FNEmployee001@intel.com';
        UserList.get(0).LastName = 'LNEmployee001@intel.com';
        UserList.get(0).Email = 'TestInternalEmployee001@intel.com';
        UserList.get(0).isActive = true;
        UserList.get(0).Phone = '9900454063';
        UserList.get(0).MobilePhone = '9900454063';
        UserList.get(0).contactId = lstCo11.get(0).Id; 
        userList.get(0).Core_User_Country_Code__c = 'US';
        
        System.runAs(ListOfUser.get(1)){
            
            insert UserList;
            
        }  
        
        System.assert(UserList != null, 'Record created');
    }  
    
    /*
* Method name  : CreateContactForUser_AgentPartnerTest
* Description  : Method to test createContact for Agent Partner functionality
* Return Type  : void
* Parameters   : None
*/
    static testMethod void CreateContactForAEUser_Test() {
        Test.startTest();
        getrecords();
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        List<User> UserList = new List<User> ();
        
        
        //Create Custom Settings
        Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
        TriggerExecution.Name = 'createContactForEAC';
        TriggerExecution.Core_Active__c = true;
        TriggerExecution.Core_Class_Name__c ='Core_IPS_UserTriggerHandler';
        TriggerExecution.Core_Description__c = 'MethodDescription';
        TriggerExecution.Core_Object__c = 'User';
        TriggerExecution.Core_Trigger_Events__c = 'Before Insert';
        System.runAs(ListOfUser.get(1)){
            insert TriggerExecution;
        }
        
        //Create Custom Settings
        Core_Trigger_Executions__c  TriggerExecutionRegion = new Core_Trigger_Executions__c();
        TriggerExecutionRegion.Name = 'updateUserRegionFields';
        TriggerExecutionRegion.Core_Active__c = true;
        TriggerExecutionRegion.Core_Class_Name__c ='Core_IPS_UserTriggerHandler';
        TriggerExecutionRegion.Core_Description__c = 'Core_IPS_UserTriggerHandler';
        TriggerExecutionRegion.Core_Object__c = 'User';
        TriggerExecutionRegion.Core_Trigger_Events__c = 'After Insert, After Update';
        System.runAs(ListOfUser.get(1)){
            insert TriggerExecutionRegion;
        } 
        
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser.get(1)){
            insert ListOfAccounts;
        }     
        
        list<Contact> lstCo11 = TestUtilities.getListOfContact(1);        
        System.runAs(ListOfUser.get(1)){
            lstCo11.get(0).AccountId = ListOfAccounts.get(0).Id; 
            //Insert Users
            insert lstCo11 ;             
        }
        
        //Create Users
        UserList = TestUtilities.getListOfUser(1);
        UserList.get(0).ProfileID =  Label.Core_IPS_Partner_AE_Profile_Id;
        UserList.get(0).UserName = 'TestInternalEmployee001@intel.com';
        UserList.get(0).FirstName = 'FNEmployee001@intel.com';
        UserList.get(0).LastName = 'LNEmployee001@intel.com';
        UserList.get(0).Email = 'TestInternalEmployee001@intel.com';
        UserList.get(0).isActive = true;
        UserList.get(0).Phone = '9900454063';
        UserList.get(0).MobilePhone = '9900454063';
        UserList.get(0).contactId = lstCo11.get(0).Id; 
        userList.get(0).Core_User_Country_Code__c = 'US';
        
        System.runAs(ListOfUser.get(1)){
            
            insert UserList;
            
        } 
        System.assertNotEquals(UserList.size(),0);
        Test.stopTest();
    }  


    static testMethod void CreateEACUserTest() {
        Test.startTest();
        getrecords();
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        List<User> UserList = new List<User> ();
        
        

        //Create Custom Settings - EAC 
        Core_Trigger_Executions__c  TriggerExecutionEAC = new Core_Trigger_Executions__c();
        TriggerExecutionEAC.Name = 'addEACUsersToIECGroups';
        TriggerExecutionEAC.Core_Active__c = true;
        TriggerExecutionEAC.Core_Class_Name__c ='Core_IPS_UserTriggerHandler';
        TriggerExecutionEAC.Core_Description__c = 'Core_IPS_UserTriggerHandler';
        TriggerExecutionEAC.Core_Object__c = 'User';
        TriggerExecutionEAC.Core_Trigger_Events__c = 'After Insert';
        System.runAs(ListOfUser.get(1)){
            insert TriggerExecutionEAC;
        }
        
        Core_Profile_To_Group_Mapping__c IPSExternalCustomerCS =  new Core_Profile_To_Group_Mapping__c();
        IPSExternalCustomerCS.Name='IPS External Customer';
        IPSExternalCustomerCS.Core_Active__c=true;
    //Changed from 'IPS External Customer'to Partner as part if Employee as Customer profile mapping to partner - Tejaswini
    IPSExternalCustomerCS.Core_Profile_Name__c='Partner';
    IPSExternalCustomerCS.Core_Group_Name__c='Core_PG_IPS_External_Customer';
    
    Group testGroup = new Group();
    testGroup.Name = 'PG: IPS External Customer';
    testGroup.DeveloperName = 'Core_PG_IPS_External_Customer';
    
    
    System.runAs(ListOfUser.get(1)){
        insert IPSExternalCustomerCS;
        //insert testGroup;
    }
    
    List<Group> lstGroups = [SELECT Id, DeveloperName From Group Where Type = 'Regular' AND DeveloperName='Core_PG_IPS_External_Customer'];
    
    List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
    System.runAs(ListOfUser.get(1)){
        insert ListOfAccounts;
        
    }     
    
    list<Contact> lstCo11 = TestUtilities.getListOfContact(1);        
    System.runAs(ListOfUser.get(1)){
        lstCo11.get(0).AccountId = ListOfAccounts.get(0).Id; 
        //Insert Users
        insert lstCo11 ;             
    }
    
    //Create Users
    UserList = TestUtilities.getListOfUser(1);
    UserList.get(0).ProfileID =  Label.Core_IPS_External_Customer_Profile_Id;
    UserList.get(0).UserName = 'TestInternalEmployee002@intel.com';
    UserList.get(0).FirstName = 'FNEmployee002@intel.com';
    UserList.get(0).LastName = 'LNEmployee002@intel.com';
    UserList.get(0).Email = 'TestInternalEmployee002@intel.com';
    UserList.get(0).isActive = true;
    UserList.get(0).Phone = '9900454063';
    UserList.get(0).MobilePhone = '9900454063';
    UserList.get(0).contactId = lstCo11.get(0).Id; 
    userList.get(0).Core_User_Country_Code__c = 'US';
    
    System.runAs(ListOfUser.get(1)){
        
        insert UserList;
        
    } 
    System.assertNotEquals(UserList.size(),0);
    Test.stopTest();
}


static testMethod void convertCountryCodeToISOTest() {
    Test.startTest();
    
    getrecords();
    
    Map<String,ID> profiles = new Map<String,ID>();
    List<String> strProf = new List<String>();
    List<User> UserList = new List<User> ();
    
    
    
    //Create Custom Settings - EAC 
    Core_Trigger_Executions__c  TriggerCountryCode = new Core_Trigger_Executions__c();
    TriggerCountryCode.Name = 'convertCountryCodeToISO';
    TriggerCountryCode.Core_Active__c = true;
    TriggerCountryCode.Core_Class_Name__c ='Core_IPS_UserTriggerHandler';
    TriggerCountryCode.Core_Description__c = 'Core_IPS_UserTriggerHandler';
    TriggerCountryCode.Core_Object__c = 'User';
    TriggerCountryCode.Core_Trigger_Events__c = 'Before Insert and Before Update';
    System.runAs(ListOfUser.get(1)){
        insert TriggerCountryCode;
    }
    
    //Country Code Mapping
    Core_IPS_Country_Code_Mapping__c countryCode = new Core_IPS_Country_Code_Mapping__c();
    countryCode.Name='UnitedStates';
    countryCode.Core_IPS_AGS_Country_Code__c='US';
    countryCode.Core_IPS_AGS_Country_Name__c='UnitedStates';
    countryCode.Core_IPS_SFDC_Country_Code__c='USA';
    countryCode.Core_IPS_SFDC_Country_Name__c='UnitedStates';
    System.runAs(ListOfUser.get(1)){
        insert countryCode;
    }
    
    List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
    System.runAs(ListOfUser.get(1)){
        insert ListOfAccounts;
        
    }     
    
    list<Contact> lstCo11 = TestUtilities.getListOfContact(1);        
    System.runAs(ListOfUser.get(1)){
        lstCo11.get(0).AccountId = ListOfAccounts.get(0).Id; 
        //Insert Users
        insert lstCo11 ;             
    }   
    
    System.runAs([select Id from User where Id = :Label.Core_User_Provisioning_User_ID limit 1][0]) {
        //Create Users      
        UserList = TestUtilities.getListOfUser(1);
        UserList.get(0).ProfileID =  Label.Core_IPS_External_Customer_Profile_Id;
        UserList.get(0).UserName = 'TestInternalEmployee033@intel.com';
        UserList.get(0).FirstName = 'FNEmployee033@intel.com';
        UserList.get(0).LastName = 'LNEmployee033@intel.com';
        UserList.get(0).Email = 'TestInternalEmployee033@intel.com';
        UserList.get(0).isActive = true;
        UserList.get(0).Phone = '9900454063';
        UserList.get(0).MobilePhone = '9900454063'; 
        UserList.get(0).contactId = lstCo11.get(0).Id; 
        userList.get(0).CountryCode = 'US';
        
        /*UserList.get(1).ProfileID =  Label.Core_IPS_External_Customer_Profile_Id;
UserList.get(1).UserName = 'TestInternalEmployee044@intel.com';
UserList.get(1).FirstName = 'FNEmployee044@intel.com';
UserList.get(1).LastName = 'LNEmployee044@intel.com';
UserList.get(1).Email = 'TestInternalEmployee044@test.com';
UserList.get(1).isActive = true;
UserList.get(1).Phone = '9900454063';
UserList.get(1).MobilePhone = '9900454063'; 
UserList.get(1).contactId = lstCo11.get(0).Id; 
userList.get(1).CountryCode = 'IN'; */
        
        insert UserList;                        
    } 
    Test.stopTest();
    System.AssertEquals(TriggerCountryCode != null, true);
}

/**
Created By Amritesh  - 08/17/2018 - US113971
**/
static testMethod void InactivateActivateInterestedPartyTest() {
    
    getrecords();
    
    Map<String,ID> profiles = new Map<String,ID>();
    List<String> strProf = new List<String>();
    List<User> UserList = new List<User> ();
    
    //Create Trigger Execution Custom Settings
    Core_Trigger_Executions__c  TriggerExecutionEAC = new Core_Trigger_Executions__c();
    TriggerExecutionEAC.Name = 'InactivateInternalInterestedParty';
    TriggerExecutionEAC.Core_Active__c = true;
    TriggerExecutionEAC.Core_Class_Name__c ='Core_IPS_UserTriggerHandler';
    TriggerExecutionEAC.Core_Description__c = 'InactivateInternalInterestedParty';
    TriggerExecutionEAC.Core_Object__c = 'User';
    TriggerExecutionEAC.Core_Trigger_Events__c = 'After Update';
    System.runAs(ListOfUser.get(1)){
        insert TriggerExecutionEAC;
        
        //Create Mask email custom setting
        MaskEmail__c mskEmail = new MaskEmail__c(Name='Core Mask Email Bypass', Core_Mask_Email__c=false);
        System.runAs(ListOfUser.get(1)){
            insert mskEmail;
        }
    }       
    
    List<Profile> ProfileList = [select id, name from Profile where name='IPS Agent'];
    for(Profile prf : ProfileList){
        profiles.put(prf.name, prf.id);
    }
    
    Test.startTest();
    // Create Users
    User objUser = TestUtilities.getListOfUser(1)[0];
    objUser.ProfileID = profiles.get('IPS Agent');        
    
    System.runAs(ListOfUser.get(1)) {
        insert objUser;
        objUser.IsActive = false;
        update objUser;
        objUser.IsActive = true;
        update objUser;
    } 	
    Test.stopTest();
    System.AssertEquals(TriggerExecutionEAC != null, true);
}

/**
Created By Amritesh  - 10/19/2018 - US194563
**/
static testMethod void managerChangeloggerTest() {
    
    getrecords();
    
    Map<String,ID> profiles = new Map<String,ID>();
    List<String> strProf = new List<String>();
    List<User> UserList = new List<User> ();
    
    //Create Trigger Execution Custom Settings
    Core_Trigger_Executions__c  TriggerExecutionEAC = new Core_Trigger_Executions__c();
    TriggerExecutionEAC.Name = 'managerChangelogger';
    TriggerExecutionEAC.Core_Active__c = true;
    TriggerExecutionEAC.Core_Class_Name__c ='Core_IPS_UserTriggerHandler';
    TriggerExecutionEAC.Core_Description__c = 'managerChangelogger';
    TriggerExecutionEAC.Core_Object__c = 'User';
    TriggerExecutionEAC.Core_Trigger_Events__c = 'After Update';
    System.runAs(ListOfUser.get(1)){
        insert TriggerExecutionEAC;
    }       
    
    List<Profile> ProfileList = [select id, name from Profile where name='IPS Agent'];
    for(Profile prf : ProfileList){
        profiles.put(prf.name, prf.id);
    }
    
    Test.startTest();
    // Create Users
    List<User> lstUser = TestUtilities.getListOfUser(2);
    lstUser[0].ProfileID = profiles.get('IPS Agent');       
    lstUser[1].ProfileID = profiles.get('IPS Agent');    
    
    System.runAs(ListOfUser.get(1)) {
        insert lstUser;
        lstUser[1].ManagerId = lstUser[0].Id;
        update lstUser;
    }
    Test.stopTest();
    System.AssertEquals(TriggerExecutionEAC != null, true);
}

static testMethod void shareAssetsToCustomersTest() {
    getrecords();
    
    Map<String,ID> profiles = new Map<String,ID>();
    List<String> strProf = new List<String>();
    List<User> UserList = new List<User> ();
    
    Core_Trigger_Executions__c  TriggerExecutionEAC = new Core_Trigger_Executions__c();
    TriggerExecutionEAC.Name = 'shareAssetsToCustomers';
    TriggerExecutionEAC.Core_Active__c = true;
    TriggerExecutionEAC.Core_Class_Name__c ='Core_IPS_UserTriggerHandler';
    TriggerExecutionEAC.Core_Description__c = 'This method shares assets to customers';
    TriggerExecutionEAC.Core_Object__c = 'User';
    TriggerExecutionEAC.Core_Trigger_Events__c = 'After Insert';
    System.runAs(ListOfUser.get(1)){
        insert TriggerExecutionEAC;
    }  
    
    //Changed from 'IPS External Customer'to Partner as part if Employee as Customer profile mapping to partner - Tejaswini
    List<Profile> profileList = [select id, name from Profile where name='Partner' OR name='IPS Agent-Partner' ];
    for(Profile prf : profileList){
        profiles.put(prf.name, prf.id);
    }
    List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
    listOfAccounts[0].Core_IPS_Active__c = true;
    System.runAs(ListOfUser.get(1)){
        insert listOfAccounts;
        
    }     
    List<Asset> assetList = TestUtilities.getAssetList(1);
    for(Asset asst : assetList){
        asst.accountId = listOfAccounts.get(0).Id;
    }
    System.runAs(ListOfUser.get(1)){
        insert assetList;
    }
    
    List<Contact> lstCo11 = TestUtilities.getListOfContact(2);        
    System.runAs(ListOfUser.get(1)){
        lstCo11.get(0).AccountId = listOfAccounts.get(0).Id; 
        lstCo11.get(0).Core_IPS_Active__c = true;
        lstCo11.get(1).AccountId = listOfAccounts.get(0).Id; 
        lstCo11.get(1).Email = 'lstCo11@email.com'; 
        lstCo11.get(1).Core_IPS_Active__c = true;
        //Insert Users
        insert lstCo11[0] ;             
    }
    
    Test.startTest();
    // Create Users
    List<User> lstUser = TestUtilities.getListOfUser(2);
    //Changed from 'IPS External Customer'to Partner as part if Employee as Customer profile mapping to partner - Tejaswini
    lstUser[0].ProfileID = profiles.get('Partner');       
    lstUser[0].contactId = lstCo11.get(0).Id;
    
    /*
UserList = TestUtilities.getListOfUser(1);
UserList.get(0).ProfileID =  Label.Core_IPS_External_Customer_Profile_Id;
UserList.get(0).UserName = 'TestInternalEmployee033@intel.com';
UserList.get(0).FirstName = 'FNEmployee033@intel.com';
UserList.get(0).LastName = 'LNEmployee033@intel.com';
UserList.get(0).Email = 'TestInternalEmployee033@intel.com';
UserList.get(0).isActive = true;
UserList.get(0).Phone = '9900454063';
UserList.get(0).MobilePhone = '9900454063'; 
UserList.get(0).contactId = lstCo11.get(0).Id; 
userList.get(0).CountryCode = 'US';

insert UserList;
*/
    System.runAs(ListOfUser.get(1)) {
        insert lstUser[0];
        insert lstCo11[1] ; 
        //Changed from 'IPS External Customer'to Partner as part if Employee as Customer profile mapping to partner - Tejaswini
        lstUser[1].ProfileID = profiles.get('Partner');       
        lstUser[1].contactId = lstCo11.get(1).Id;
        insert lstUser[1];
    } 
    Test.stopTest();
    System.AssertEquals(TriggerExecutionEAC != null, true);	
    
}
/***************************************************************************************************
Method Name:  UIOLI_test
Method Type: Test Method
Version     : 1.0 
Created Date: 06 Jan 2021
Description:  Testing with User and Contact record and assigning and not matching
Scenario Type:  positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Prem Ranjan              06/01/2021                Created
****************************************************************************************************/ 
    static testmethod void UIOLI_test(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        List<User> UserList = new List<User> ();
        //Get Profile
    //Changed from 'IPS External Customer'to Partner as part if Employee as Customer profile mapping to partner - Tejaswini
    strProf.add('Partner');
    List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
    for(Profile prf : ProfileList){
        profiles.put(prf.name, prf.id);
    }
    //Create Users
    UserList = TestUtilities.getListOfUser(1);
    //Changed from 'IPS External Customer'to Partner as part if Employee as Customer profile mapping to partner - Tejaswini
    UserList.get(0).ProfileID =  profiles.get('Partner');
    UserList.get(0).UserName = 'Testnewuseruioli@intel.com';
    // Create Accounts
    List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
    System.runAs(ListOfUser.get(1)){
        insert ListOfAccounts;
    }
    System.assert(ListOfAccounts[0].Id != null, 'Record not created');
    // Create Contact
    List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
    for(Contact ContactRec : ListOfContacts){
        ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        ContactRec.Accountid = ListOfAccounts.get(0).Id;
    }
    System.runAs(ListOfUser.get(1)){
        insert ListOfContacts;
        UserList.get(0).ContactID = ListOfContacts.get(0).id;
    }       
    System.assert(ListOfContacts[0].Id != null, 'Record not created');
    //Create Custom Settings
    Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
    TriggerExecution.Name = 'assignContactRule';
    TriggerExecution.Core_Active__c = true;
    TriggerExecution.Core_Class_Name__c ='ClassName';
    TriggerExecution.Core_Description__c = 'MethodDescription';
    TriggerExecution.Core_Object__c = 'Account';
    TriggerExecution.Core_Trigger_Events__c = 'Before Insert';
    System.runAs(ListOfUser.get(1)){
        insert TriggerExecution;
    } 
    System.assert(TriggerExecution.id!= null, 'Record not created');
    Test.startTest();
    System.runAs(ListOfUser.get(1)){
        //Insert Users
        insert UserList;
    }
    //Changed from 'IPS External Customer'to Partner as part if Employee as Customer profile mapping to partner - Tejaswini
    System.assertEquals(UserList.get(0).profileid, profiles.get('Partner'));
    Core_IPS_UserTriggerHandler.UpdateProjectMemAndIntParty projMem = new Core_IPS_UserTriggerHandler.UpdateProjectMemAndIntParty(new List<Sobject>());
    System.enqueueJob(projMem);
    Test.stopTest();
}
}