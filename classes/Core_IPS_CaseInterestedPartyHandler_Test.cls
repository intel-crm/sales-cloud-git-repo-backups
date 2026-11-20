/***************************************************************************************************
Class Name:  Core_IPS_CaseInterestedPartyHandler_Test
Class Type: Test Class
Version     : 1.0
Created Date: 25 Jan 2016
Function    : This class contains test coverage for Core_IPS_Case_Interested_Party_Handler class
Input Parameters: None
Output Parameters: None
Description:   This class contains unit test scenarios for Core_IPS_Case_Interested_Party_Handler class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                
* Abhishek Ekbote       25/01/2016                 Created
* Manoj Kumar B         24/04/2017                 Modified - Updated getRecordsForIntIP() to create AccountTeamMembers for Case's Account to check whether
                                                   Interested Party User is part of Case's AccountTeam and provide Case Access accordingly as per Implementation US61151
****************************************************************************************************/  
@isTest
public class Core_IPS_CaseInterestedPartyHandler_Test {
        static List<Case> caseRecList;
        static List<User> ListOfUser;
        static List<User> ListOfCustomUsers;
        
        
        static List<Core_IPS_Case_Interested_Party__c> ipRecList = new List<Core_IPS_Case_Interested_Party__c>();
        static Profile p = null;

        private static void insertUsersWithValidationBypass(List<User> users) {
            User validationBypassUser = [SELECT Id FROM User WHERE Profile.Name = :System.Label.Core_System_Admin_Profile_Name AND IsActive = true LIMIT 1];
            System.runAs(validationBypassUser) {
                insert users;
            }
        }

        public static void getRecordsForIntIP(){
        
        //Profiles of SalesReps & IPS Agents to add these Users to Case' Account    --  4/24/2017     Manoj Kumar
        List<String> salesRepProfIds = new List<String>();
        List<String> ipAgentProfileIds = new List<String>();
        List<AccountTeamMember> atmList = new List<AccountTeamMember>();
        
        ipAgentProfileIds.addall(Label.Interested_Parties_Internal_Agent_ProfileIds.split(','));
        salesRepProfIds.addall(label.Core_IPS_Sales_Rep_ProfileIds.split(','));
        
        //Creating Custom Settings for search criteria of Case Accountteammembers   --  4/24/2017     Manoj Kumar
        List<Core_IPS_Labels__c> ipsLabels = new List<Core_IPS_Labels__c>();
            
        Core_IPS_Labels__c ipsLabelTeam = new Core_IPS_Labels__c(Name='RowCause_Team',Value__c='Team');
        Core_IPS_Labels__c ipsLabelOwner = new Core_IPS_Labels__c(Name='Rowcause_Owner',Value__c='Owner');
        Core_IPS_Labels__c ipsLabelRead = new Core_IPS_Labels__c(Name='AccessLevel_Read',Value__c='Read');
        Core_IPS_Labels__c ipsLabelEdit = new Core_IPS_Labels__c(Name='AccessLevel_Edit',Value__c='Edit');
            
        ipsLabels.add(ipsLabelTeam);
        ipsLabels.add(ipsLabelOwner);
        ipsLabels.add(ipsLabelRead);
        ipsLabels.add(ipsLabelEdit);
        
        Insert ipsLabels;
    
        //create cases
        caseRecList = TestUtilities.getListOfCases(10);
        
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> profileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }        
        // Create Users
        ListOfUser = new List<User>();
        for(integer i=0;i<10;i++){
             User userRec = TestUtilities.getUser();
             userRec.Username = userRec.Username+''+i;
             ListOfUser.add(userRec);
        }
        for(User userRecord : ListOfUser){
            userRecord.ProfileID =  profiles.get('System Administrator');
        }
        
        // Creating IPS Agent & Sales Rep which are added to Case's AccountTeam     --  4/24/2017     Manoj Kumar
        ListOfUser.get(1).FirstName= 'Test';
        ListOfUser.get(1).LastName= 'IPS Agent';
        ListOfUser.get(1).ProfileID =  ipAgentProfileIds.get(0);
        
        ListOfUser.get(2).FirstName= 'Test';
        ListOfUser.get(2).LastName= 'Sales Rep';
        ListOfUser.get(2).ProfileID =  salesRepProfIds.get(0);
        
        insertUsersWithValidationBypass(ListOfUser);
        
        //Creating Account for Case to add Case's Account Teams     --  4/24/2017     Manoj Kumar
        System.RunAs(ListOfUser[0]){
        
        Account acct = new Account();
        acct = TestUtilities.getAccountRecord();
        insert acct;
        
        //Adding Sales Rep to AccountTeamMember     --  4/24/2017     Manoj Kumar
        AccountTeamMember atm = new AccountTeamMember(UserId=ListOfUser.get(2).Id,AccountId=acct.Id,TeamMemberRole ='Team Member (100%)');
        
        atmList.add(atm);
        
        insert atmList;
        
        List<AccountShare> affectedAcctShare = [select Id,CaseAccessLevel,rowcause from AccountShare where AccountId=:atm.AccountId and UserOrGroupId =:atm.UserId limit 1];
        
        //Providing Read-Only to Case for Sales Rep     --  4/24/2017     Manoj Kumar
        for(AccountShare actshare: affectedAcctShare){
            actshare.CaseAccessLevel = 'Read';
        }
        
        update affectedAcctShare;
        
        caseRecList.get(0).AccountId = acct.Id;
        insert caseRecList;
        System.assert(caseRecList[0].Id != null, 'Record not created');
        
        }
        ipRecList = TestUtilities.getInternalInterestedParties(10);
        integer counter = 0;
        for(Core_IPS_Case_Interested_Party__c ipRec : ipRecList){
            ipRec.User__c = ListOfUser[counter].id;
            ipRec.case__c = caseRecList[counter].id;
            counter++;
        }            
    }
    
    /***************************************************************************************************
    Method Name:  testInsertIntIntrestedParty
    Method Type: Test Method
    Version     : 1.0 
    Modified Date: 24 April 2017
    Description:  This method will creates Interested Party records which are needed for Adding Case Team Members
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
      Manoj Kumar               04/18/2017                Modified
    ****************************************************************************************************/
    static testmethod void testInsertIntIntrestedParty(){
        Test.startTest();
        getRecordsForIntIP();
        insert ipRecList;
        List<Core_IPS_Case_Interested_Party__c> insertedRec = [select id from Core_IPS_Case_Interested_Party__c];
        system.assertEquals(ipRecList.size(), insertedRec.size());
        List<CaseTeamMember> listOfCaseMembers = new List<CaseTeamMember> ();
        listOfCaseMembers = [select id, parentId from CaseTeamMember where parentId =: caseRecList[0].Id];         
        system.assert(!(listOfCaseMembers.isEmpty()), 'Case Member Team is not inserted');
        
        //Creating Internal Interested Party with Case which is not having Account      --  4/24/2017     Manoj Kumar
        List<Core_IPS_Case_Interested_Party__c> ipRec1 = TestUtilities.getInternalInterestedParties(1);
        ipRec1[0].User__c = ListOfUser[1].id;
        ipRec1[0].case__c = caseRecList[1].id;
        
        Insert ipRec1;
        
        List<CaseTeamMember> listCaseTeamMembers = new List<CaseTeamMember> ();
        listCaseTeamMembers = [select id, parentId from CaseTeamMember where parentId =: caseRecList[1].Id];         
        system.assert(!(listCaseTeamMembers.isEmpty()), 'Case Member Team is not inserted'); // END  --   Manoj Kumar
        
        Test.stopTest();
    }
    
    public static void getRecordsForExtIP(){
            p = [select Id,name from Profile where name = 'System Administrator' limit 1];
            User userRec = TestUtilities.getUser();
            userRec.ProfileId = p.Id;
            insertUsersWithValidationBypass(new List<User>{userRec});
            System.runAs(userRec){
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
            insert listOfAccounts;
            System.assert(listOfAccounts[0].Id != null, 'Record not created');
            List<Contact> listOfContacts = TestUtilities.getListOfContact(10);
            for(Contact contactRec : listOfContacts){
                contactRec.Accountid = listOfAccounts.get(0).Id;
                contactRec.MailingCountry = 'India';
            }
            insert listOfContacts;
            Profile customerProfile = [select Id,name from Profile where UserType = 'PowerCustomerSuccess' limit 1]; 
            integer count =0;
            ListOfCustomUsers = new List<User>();
            for(integer i=0;i<10;i++){
                User customerUserRec = TestUtilities.getUser();
                customerUserRec.Username = customerUserRec.Username+''+i;
                customerUserRec.ProfileId = customerProfile.Id;
                customerUserRec.contactid = listOfContacts[count].id;
                customerUserRec.CommunityNickname = 'testUser'+i;
                ListOfCustomUsers.add(customerUserRec);
                count++;
            }
            insertUsersWithValidationBypass(ListOfCustomUsers);
            caseRecList = TestUtilities.getListOfCases(10);
            insert caseRecList;
            System.assert(caseRecList[0].Id != null, 'Record not created');
            ipRecList = TestUtilities.getInternalInterestedParties(10);
            integer counter = 0;
            for(Core_IPS_Case_Interested_Party__c ipRec : ipRecList){
                ipRec.User__c = ListOfCustomUsers[counter].id;
                ipRec.case__c = caseRecList[counter].id;
                ipRec.Contact__c = listOfContacts[0].id;
                counter++;
            }  
    }
    }
    
    static testmethod void testInsertExtIntrestedParty(){   
        getRecordsForExtIP();
        Test.startTest();
        insert ipRecList;
        List<Core_IPS_Case_Interested_Party__c> insertedRec = [select id from Core_IPS_Case_Interested_Party__c];
        system.assertEquals(ipRecList.size(), insertedRec.size());
        List<CaseTeamMember> listOfCaseMembers = new List<CaseTeamMember> ();
        listOfCaseMembers = [select id, parentId from CaseTeamMember where parentId =: caseRecList[0].id];  
        system.assert(!(listOfCaseMembers.isEmpty()), 'Case Member Team is not inserted');
        Test.stopTest();
    }
    
    static testmethod void testDeleteIntrestedParty(){          
        getRecordsForExtIP();
        Test.startTest();
        insert ipRecList;
        List<Core_IPS_Case_Interested_Party__c> insertedRec = [select id from Core_IPS_Case_Interested_Party__c];
        system.assertEquals(ipRecList.size(), insertedRec.size());
        List<CaseTeamMember> listOfCaseMembers = new List<CaseTeamMember> ();
        listOfCaseMembers = [select id, parentId from CaseTeamMember where parentId =: caseRecList[0].id];  
        system.assert(!(listOfCaseMembers.isEmpty()), 'Case Member Team is not inserted');
        delete insertedRec;
        insertedRec = [select id from Core_IPS_Case_Interested_Party__c];
        system.assertEquals(0, insertedRec.size());
        Test.stopTest();
    }
    
    static testmethod void testUpdateInActiveIntrestedParty(){  
        getRecordsForExtIP();
        Test.startTest();
        for(Core_IPS_Case_Interested_Party__c ipRec : ipRecList){
            ipRec.Active__c = false;
        } 
        insert ipRecList;
        List<Core_IPS_Case_Interested_Party__c> insertedRec = [select id from Core_IPS_Case_Interested_Party__c];
        system.assertEquals(ipRecList.size(), insertedRec.size());
        List<CaseTeamMember> listOfCaseMembers = new List<CaseTeamMember> ();
        listOfCaseMembers = [select id, parentId from CaseTeamMember where parentId =: caseRecList[0].id];  
        system.assert(!(listOfCaseMembers.isEmpty()), 'Case Member Team is not inserted');         
        Core_IPS_Case_IP_Dispatcher.DeleteCTM =false;
        update insertedRec;
        Test.stopTest();
    }
    static testmethod void testUpdateActiveIntrestedParty(){    
        Test.startTest();
        getRecordsForExtIP();
        insert ipRecList;
        List<Core_IPS_Case_Interested_Party__c> insertedRec = [select id from Core_IPS_Case_Interested_Party__c];
        system.assertEquals(ipRecList.size(), insertedRec.size());
        List<CaseTeamMember> listOfCaseMembers = new List<CaseTeamMember> ();
        listOfCaseMembers = [select id, parentId from CaseTeamMember where parentId =: caseRecList[0].id];  
        system.assert(!(listOfCaseMembers.isEmpty()), 'Case Member Team is not inserted');
        Core_IPS_Case_IP_Dispatcher.DeleteCTM =false;
        update ipRecList;
        Test.stopTest();
    }
}