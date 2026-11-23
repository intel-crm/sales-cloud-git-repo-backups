/***************************************************************************************************
Class Name:  Core_IPS_IntelSupportTeam_Handler_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 1 Feb 2016
Function    : This class contains test coverage for Core_IPS_IntelSupportTeam_Handler class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_IPS_IntelSupportTeam_Handler class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Karthick                 25/05/2018                 Created
****************************************************************************************************/
@isTest
public class Core_IPS_IntelSupportTeam_Handler_Test {

    //Instance variables that are commonly used in multiple test methods
    static List<User> ListOfUser = new List<User> ();
    static Group grp = new Group();
    static Group queue = new Group();
    
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
        ListOfUser = TestUtilities.getListOfUser(1);
        ListOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
    }
    
    static testmethod void removeGroupMembersTest(){
        
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
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
        }
        
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        
        //Custom setting record
        Core_Trigger_Executions__c  TriggerProj = new Core_Trigger_Executions__c();
        TriggerProj.Name = 'internalProjectGroup';
        TriggerProj.Core_Active__c = true;
        TriggerProj.Core_Class_Name__c ='Core_IPS_Project_Handler';
        TriggerProj.Core_Description__c = 'Intel Support Team Public Group functioanlity';
        TriggerProj.Core_Object__c = 'Project';
        TriggerProj.Core_Trigger_Events__c = 'After Insert';
        System.runAs(ListOfUser.get(0)){
            insert TriggerProj;
        }
        
        // Create Ips Labels added by Aayushi US79852
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c IL: IPSLabels){
            if(IL.name=='ProjectGroupPrefix'){
                IL.Value__c = 'IPS_Proj_';
            }
             if(IL.name=='CoreStatus_SPtoActive_Error'){
                IL.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';
            }
             if(IL.name=='Core_OneProjProdMem_Error'){
                IL.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';
            }
            if(IL.name=='CoreStatus_Draft'){
               IL.Value__c = 'Draft'; 
            }
            if(IL.name=='CoreStatus_Active'){
               IL.Value__c = 'Active' ;
            }
            if(IL.name=='CoreStatus_Inactive'){
               IL.Value__c = 'Inactive' ;
            }
            if(IL.name=='CoreStatus_SP'){
               IL.Value__c = 'Submitted Pending' ;
            }
        }
        
        Test.startTest();
        
        System.runAs(ListOfUser.get(0)){
            ListOfIpsProjects[0].Core_MPNDA__c = '';
            insert IPSLabels;
            insert ListOfIpsProjects;
            
            TestUtilities.addAccMemProdToProject(ListOfIpsProjects);
        
            for(Core_IPS_Project__c proj:ListOfIpsProjects){
                proj.Core_Status__c = 'Active';
                proj.Core_MPNDA__c='1234';
                proj.Core_IPS_Enable_ISTasInterested_Parties__c  = true;
                proj.Core_IPS_EnableMemberasInterestedParties__c = true;
                
            }
            Update ListOfIpsProjects;
            
            
            // Create Ips Account
            List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
            for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
                IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            }
            
            insert ListOfIpsAccounts;
            
            System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
            
            //Creating cases
            List<Case> ListOfCases = TestUtilities.getListOfCases(5);
            for(Case cs : ListOfCases){
                ListOfCases.get(0).OwnerId=ListOfUser.get(0).Id;
                ListOfCases.get(0).ContactId = ListOfContacts[0].id;
                ListOfCases.get(0).Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).Id;
            }
            
            // Create Project Member
            List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(5);
            for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
                ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
                ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
                ProjMem.Core_User__c = intelSupportOwner;                            
                ProjMem.Core_Status__c = 'Active';
            }
            
            
                
            insert ListOfCases;
            insert ListOfProjectMembers;
        
                
            //Create IST members
            List<Core_IPS_Intel_Support_Team__c> ListOfISTMembers = TestUtilities.getListOfIntelSupportTeamMembers(5);
            for(Core_IPS_Intel_Support_Team__c istMem : ListOfISTMembers){
                istMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
                istMem.Core_IPS_User__c = intelSupportOwner;                             
                istMem.Status__c = 'Active';
            }
            
            List<Core_IPS_Intel_Support_Team__c> ListOfISTMembers2 = TestUtilities.getListOfIntelSupportTeamMembers(5);
            for(Core_IPS_Intel_Support_Team__c istMem : ListOfISTMembers2){
                istMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
                istMem.Core_IPS_User__c = intelSupportOwner;                             
                istMem.Status__c = 'Active';
            }
            
            
            
            try{
                
                insert ListOfISTMembers;
                insert ListOfISTMembers2;
                
                ListOfIpsProjects.get(0).Core_IPS_Enable_ISTasInterested_Parties__c  = false;
                ListOfIpsProjects[0].Core_IPS_EnableMemberasInterestedParties__c = false;
                update ListOfIpsProjects;
                
                
                delete ListOfISTMembers2;
                
            }catch(Exception e){
                system.debug('---Exception caught at Test class -remove method --');
            }
                        
            
        }
        Test.stopTest();
        
    }
    
    
    static testmethod void manageGroupMembersTest(){
        
        getrecords();
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        
        //Create Role
        UserRole r = [SELECT Id, Name FROM UserRole WHERE DeveloperName = 'IPS_Product_Org_Admin' LIMIT 1];
        
        User userRecord = new User(
            Alias = 'StdUser', 
            Email = 'newuser211@intel.com', 
            EmailEncodingKey ='UTF-8',
            LastName = 'Testing',
            FirstName = 'FName',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'nnnnewuser12300000@intel.com',
            isActive = true,
            UserRoleId = r.Id
            
        );
        
        
        List<User> ListOfUser1 = new List<User>{userRecord}; //TestUtilities.getListOfUser(1);
            ListOfUser1.get(0).ProfileID =  profiles.get('System Administrator');
        //ListOfUser1.get(1).ProfileID =  profiles.get('IPS Support Org Admin');
        
        insert ListOfUser1;  
        
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser1.get(0).id; 
        String ExceptionError;
        
        
        
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Core_IPS_Product_Organization__c');
        insert q1;
        
        //Custom setting record
        List<Core_Trigger_Executions__c> triggerExecList= new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  TriggerExec = new Core_Trigger_Executions__c();
        TriggerExec.Name = 'setAddToCaseIP';
        TriggerExec.Core_Active__c = true;
        TriggerExec.Core_Class_Name__c ='Core_IPS_IntelSupportTeam_Handler';
        TriggerExec.Core_Description__c = 'Intel Support Team Add as Case IP';
        TriggerExec.Core_Object__c = 'Intel Support Team';
        TriggerExec.Core_Trigger_Events__c = 'Before Insert';
        triggerExecList.add(TriggerExec);
        
        Core_Trigger_Executions__c  TriggerProj = new Core_Trigger_Executions__c();
        TriggerProj.Name = 'internalProjectGroup';
        TriggerProj.Core_Active__c = true;
        TriggerProj.Core_Class_Name__c ='Core_IPS_Project_Handler';
        TriggerProj.Core_Description__c = 'Intel Support Team Public Group functioanlity';
        TriggerProj.Core_Object__c = 'Project';
        TriggerProj.Core_Trigger_Events__c = 'After Insert';
        triggerExecList.add(TriggerProj);
        
        System.runAs(ListOfUser.get(0)){
            insert triggerExecList;
        }

        //Get Record Type
        Id projectRecordTypeId = Schema.SObjectType.Core_IPS_Project__c.getRecordTypeInfosByName().get('Active').getRecordTypeId();
        
        Integer counter = 0;
        //Create Ips Project
        Core_IPS_Project__c ipsProjectRecord = new Core_IPS_Project__c(
            Name = 'pro-111Test',
            Core_Status__c = 'Draft',
            Core_MPNDA__c='12345',
            recordTypeId = projectRecordTypeId
        );
        List<Core_IPS_Project__c> ListOfIpsProjects = new List<Core_IPS_Project__c>{ipsProjectRecord};
            System.runAs(ListOfUser1.get(0)){
                insert ListOfIpsProjects; 
                ListOfIpsProjects.get(0).Core_Status__c = 'Active';              
                ListOfIpsProjects.get(0).Core_IPS_Enable_ISTasInterested_Parties__c  = true;              
                update ListOfIpsProjects;
                
                //Add Member And Account to Project 
                TestUtilities.addAccMemProdToProject(ListOfIpsProjects);
            } 
        
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        Test.startTest();
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(3);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
            ContactRec.Core_IPS_Active__c = true;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfContacts;
        }
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        Id ExternalUserProfileId = [select id, name from Profile where name='IPS External Customer'].Id;
        
        
        User customerUser = TestUtilities.getListOfUser(1).get(0);
        customerUser.ProfileId = ExternalUserProfileId;
        customerUser.UserName = 'testips.contact199@intel.com.crm';
        customerUser.FirstName = 'TestExt';
        customerUser.LastName = 'User199';
        customerUser.Alias = 'eusr199'; 
        customerUser.CommunityNickname = 'IPSExtUser199';
        customerUser.ContactId = ListOfContacts[0].Id;
        insert customerUser;
        
        User customerUser2 = TestUtilities.getListOfUser(1).get(0);
        customerUser2.ProfileId = ExternalUserProfileId;
        customerUser2.UserName = 'testips.contact299@intel.com.crm';
        customerUser2.FirstName = 'TestExt';
        customerUser2.LastName = 'User292';
        customerUser2.Alias = 'eusr292'; 
        customerUser2.CommunityNickname = 'IPSExtUser292';
        customerUser2.ContactId = ListOfContacts[1].Id;
        insert customerUser2;
        
        User customerUser3 = TestUtilities.getListOfUser(1).get(0);
        customerUser3.ProfileId = ExternalUserProfileId;
        customerUser3.UserName = 'testips.contact399@intel.com.crm';
        customerUser3.FirstName = 'TestExt';
        customerUser3.LastName = 'User392';
        customerUser3.Alias = 'eusr392'; 
        customerUser3.CommunityNickname = 'IPSExtUser392';
        customerUser3.ContactId = ListOfContacts[2].Id;
        insert customerUser3;
        
        
        //Creating cases
        List<Case> ListOfCases = TestUtilities.getListOfCases(2);
        ListOfCases.get(0).OwnerId=ListOfUser.get(0).Id;
        ListOfCases.get(0).ContactId = ListOfContacts[0].id;
        ListOfCases.get(0).Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).Id;
        
        
        // Create Project Member
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(2);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = customerUser.Id;                             
            ProjMem.Core_Status__c = 'Active';
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfCases;
            insert ListOfProjectMembers;
        }
        
        
        //Create IST members
        List<Core_IPS_Intel_Support_Team__c> ListOfISTMembers = TestUtilities.getListOfIntelSupportTeamMembers(2);
        for(Core_IPS_Intel_Support_Team__c istMem : ListOfISTMembers){
            istMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            istMem.Core_IPS_User__c = customerUser.Id;                             
            istMem.Status__c = 'Active';
        }
        
        List<Core_IPS_Intel_Support_Team__c> ListOfISTMembers2 = TestUtilities.getListOfIntelSupportTeamMembers(2);
        Integer i=0;
        for(Core_IPS_Intel_Support_Team__c istMem : ListOfISTMembers2){
            istMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            if(i==0)
            istMem.Core_IPS_User__c = customerUser.Id;
            else if(i==1)
                istMem.Core_IPS_User__c = customerUser2.Id;
            else
                istMem.Core_IPS_User__c = customerUser3.Id;
            istMem.Status__c = 'Active';
            i++;
        }
        
        System.runAs(ListOfUser.get(0)){
            
            //Test.startTest();
            insert ListOfISTMembers;
            
            insert ListOfISTMembers2;
            
            List<Core_IPS_Intel_Support_Team__c> updateList = [select id,Status__c from Core_IPS_Intel_Support_Team__c where id IN :ListOfISTMembers2];
            
            List<Core_IPS_Intel_Support_Team__c> delList = [select id,Status__c from Core_IPS_Intel_Support_Team__c where id IN :ListOfISTMembers];
            //DeActivating the IST member
            for(Core_IPS_Intel_Support_Team__c istMem : updateList){                            
                istMem.Status__c = 'Inactive';
            }
            
            update updateList;
            //Activating the IST member
            for(Core_IPS_Intel_Support_Team__c istMem : updateList){                            
                istMem.Status__c = 'Active';
            }
            
            update updateList;
            
            delete delList;
            
            ListOfIpsProjects[0].Core_IPS_Enable_ISTasInterested_Parties__c = false;
            ListOfIpsProjects[0].Core_IPS_EnableMemberasInterestedParties__c = false;
            update ListOfIpsProjects;
            
            ListOfIpsProjects[0].Core_IPS_Enable_ISTasInterested_Parties__c = true;
            ListOfIpsProjects[0].Core_IPS_EnableMemberasInterestedParties__c = true;
            update ListOfIpsProjects;
            
           // Test.stopTest();
        }
        
		Test.stopTest();        
        
    }
    
    /***************************************************************************************************
    Method Name:  interestedParties_IntelSupportTeam_test
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 23 April 2018
    Description:  Testing with Intel Support Team Members and adding them to Interested Parties
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    *Rakesh Marka                23/05/2018              User Story--US107411 
	* Amritesh					 05/10/2018				 Modified - US137508
    ****************************************************************************************************/ 
    static testmethod void interestedParties_IntelSupportTeam_test(){
        getRecords();
        System.runAs(ListOfUser.get(0)){
            List<Core_Trigger_Executions__c> lstTriggerExecution = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'interestedParties_IntelSupportTeam';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_IntelSupportTeam_Handler';
            TriggerExecution.Core_Description__c = 'interestedParties_IntelSupportTeam';
            TriggerExecution.Core_Object__c = 'Core_IPS_Intel_Support_Team__c';
            TriggerExecution.Core_Trigger_Events__c = 'After Update';
            lstTriggerExecution.add(TriggerExecution);
            
            TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'create_InterestedParty_using_checkBox';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_IntelSupportTeam_Handler';
            TriggerExecution.Core_Description__c = 'create_InterestedParty_using_checkBox';
            TriggerExecution.Core_Object__c = 'Core_IPS_Intel_Support_Team__c';
            TriggerExecution.Core_Trigger_Events__c = 'After Update';
            lstTriggerExecution.add(TriggerExecution);
            
            TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'removeRelatedIpsOnStatusChangeForIST';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_IntelSupportTeam_Handler';
            TriggerExecution.Core_Description__c = 'removeRelatedIpsOnStatusChangeForIST';
            TriggerExecution.Core_Object__c = 'Core_IPS_Intel_Support_Team__c';
            TriggerExecution.Core_Trigger_Events__c = 'After Update';
            lstTriggerExecution.add(TriggerExecution);
            
            TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'removeISOonProject';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_IntelSupportTeam_Handler';
            TriggerExecution.Core_Description__c = 'removeISOonProject';
            TriggerExecution.Core_Object__c = 'Core_IPS_Intel_Support_Team__c';
            TriggerExecution.Core_Trigger_Events__c = 'After Update';
            lstTriggerExecution.add(TriggerExecution);
            
            insert lstTriggerExecution;
        }
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
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
        }
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
        
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
                
        System.runAs(ListOfUser.get(0)) {
            insert IPSLabels;
            ListOfIpsProjects[0].Core_MPNDA__c = '';
            ListOfIpsProjects[0].Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            
            insert ListOfIpsProjects;
            /*
            //TestUtilities.addAccMemProdToProject(ListOfIpsProjects);
            
            for(Core_IPS_Project__c proj:ListOfIpsProjects){
                proj.Core_Status__c = 'Active';
                //proj.Core_MPNDA__c='1234';
                //proj.Core_IPS_Enable_ISTasInterested_Parties__c  = true;
                //proj.Core_IPS_EnableMemberasInterestedParties__c = true;                
            }
            //Update ListOfIpsProjects;
            */
            
            // Create Ips Account
            List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
            for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
                IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            }
            
            insert ListOfIpsAccounts;
            
            System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
            
            //Creating cases
            List<Case> ListOfCases = TestUtilities.getListOfCases(2);
           /* for(Case cs : ListOfCases){
                ListOfCases.get(0).OwnerId=ListOfUser.get(0).Id;
                ListOfCases.get(0).ContactId = ListOfContacts[0].id;
                ListOfCases.get(0).Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).Id;
                ListOfCases.get(0).Core_Intel_Sup_Owner__c = intelSupportOwner;
            }*/
            
            for(Case cs : ListOfCases){
                cs.OwnerId=ListOfUser.get(0).Id;
                cs.ContactId = ListOfContacts[0].id;
                cs.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).Id;
                cs.Core_Intel_Sup_Owner__c = intelSupportOwner;
                cs.Core_IPS_Customer_Visible__c=true;
            }
            
            insert ListOfCases;
            
            //Create Interested Party
            List<Core_IPS_Case_Interested_Party__c> internalcipListToBeInserted = new List<Core_IPS_Case_Interested_Party__c>();  
            Core_IPS_Case_Interested_Party__c cip = new Core_IPS_Case_Interested_Party__c();                
            cip.User__c = ListOfUser.get(0).Id;
            cip.Case__c = ListOfCases[0].Id;
            cip.Type__c = 'Internal';
            cip.Active__c = true;
            cip.Core_IPS_Project_Interested_Party__c = true;
            internalcipListToBeInserted.add(cip);
            insert internalcipListToBeInserted;
            System.debug('internalcipListToBeInserted-->'+internalcipListToBeInserted);
            System.assert(internalcipListToBeInserted[0].Id != null, 'Record not created');
            
            //Create IST members
            List<Core_IPS_Intel_Support_Team__c> ListOfISTMembers = TestUtilities.getListOfIntelSupportTeamMembers(2);
            for(Core_IPS_Intel_Support_Team__c istMem : ListOfISTMembers){
                istMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
                istMem.Core_IPS_User__c = intelSupportOwner;                             
                istMem.Status__c = 'Active';
            }   
            insert ListOfISTMembers;
            
            Test.startTest();
            for(Core_IPS_Intel_Support_Team__c istMem : ListOfISTMembers) {
                istMem.Add_as_Case_Interested_Party__c = true;
            }
            update ListOfISTMembers;
            for(Core_IPS_Intel_Support_Team__c istMem : ListOfISTMembers) {
                istMem.Status__c = 'Inactive';
            }
            update ListOfISTMembers;
            //ListOfIpsProjects.get(0).Core_IPS_Enable_ISTasInterested_Parties__c  = false;
            //ListOfIpsProjects[0].Core_IPS_EnableMemberasInterestedParties__c = false;
            //update ListOfIpsProjects;
            
            Test.stopTest();
        }
    }
        
}