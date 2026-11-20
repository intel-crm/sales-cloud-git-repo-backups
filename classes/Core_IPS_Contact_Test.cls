/***************************************************************************************************
* Apex Class Name: Core_IPS_Contact_Test
* Version     : 1.0 
* Created Date: 19th Dec 2015
* Function    : Test class for Contact_Handler
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                       02/01/2015                Created
****************************************************************************************************/
@istest
public class Core_IPS_Contact_Test{
    
    public static User systUserRunAs; 
    public static List<Case> caseList = new List<Case>();
    public static List<Core_IPS_Case_Interested_Party__c> interestedPartyListoptIn = new List<Core_IPS_Case_Interested_Party__c>();
    public static List<Core_IPS_Case_Interested_Party__c> interestedPartyListoptOut = new List<Core_IPS_Case_Interested_Party__c>();
    public static List<Account> accountList =  new List<Account>();
    public static List<Contact> contactListOptIn =  new List<Contact>();
    public static List<Contact> contactListOptOut =  new List<Contact>();
    public static List<User> userList = new List<user>();
    
    public static void getRecords(){
        
        Profile prof = [select id from profile where name = 'System Administrator' limit 1];    
        userList = TestUtilities.getListOfUser(1);
        userList[0].profileId=prof.id;
        User validationBypassUser = [SELECT Id FROM User WHERE Profile.Name = :System.Label.Core_System_Admin_Profile_Name AND IsActive = true LIMIT 1];
        System.runAs(validationBypassUser){
           insert userlist;
        }
        
        systUserRunAs = new User();
        systUserRunAs = userList[0];
        System.runAs(systUserRunAs){
        Core_Trigger_Executions__c executeTrigger = new Core_Trigger_Executions__c();
        executeTrigger.Name = 'test';
        executeTrigger.Core_Object__c = 'Contact';
        executeTrigger.Core_Active__c = TRUE;
        executeTrigger.Core_Trigger_Events__c = 'After Insert, After Update';
        executeTrigger.Core_Description__c = 'test';
        executeTrigger.Core_Class_Name__c = 'Contact_Handler';
        insert executeTrigger;
        
        
        
        accountList = TestUtilities.getListOfAccounts(2);
        insert AccountList;
        
        contactListOptIn = TestUtilities.getListOfContact(2);
        contactListOptOut = TestUtilities.getListOfContact(2);
        Integer i = 0;
        for(Contact contactRecord: contactListOptIn){
            contactRecord.accountid = AccountList.get(0).id;
            contactRecord.Core_IPS_Email_Opt_Out__c = false;
            i++;
        }
        insert contactListOptIn;
        
        for(Contact contactRecord: contactListOptOut){
            contactRecord.accountid = AccountList.get(1).id;
            contactRecord.Core_IPS_Email_Opt_Out__c = true;
            contactRecord.Email = 'Contact1Dell@yahoo.com';
            i++;
        }
        insert contactListOptOut;
        
        caseList = TestUtilities.getListOfCases(2);
        integer  counter = 0 ;
        for(Case caseRec : caseList){
                caseRec.ContactId = contactListOptIn.get(counter).id;
                caseRec.accountId = AccountList.get(counter).Id;
                counter++;
            }
        insert caseList;
        
        
        interestedPartyListoptIn = TestUtilities.getInternalInterestedParties(2);
        interestedPartyListoptOut = TestUtilities.getInternalInterestedParties(2);
        for(Core_IPS_Case_Interested_Party__c ip: interestedPartyListoptIn){
            ip.Case__c = caseList[0].id;
            ip.Contact__c = contactListOptIn.get(0).id;
            i++;
        }
        insert interestedPartyListoptIn;
        
        for(Core_IPS_Case_Interested_Party__c ip: interestedPartyListoptOut){
            ip.Case__c = caseList[0].id;
            ip.Contact__c = contactListOptOut.get(0).id;
            i++;
        }
        insert interestedPartyListoptOut;
        }
    }
    
    /***************************************************************************************************
    * Method Name: inactivatingIPtest
    * Method Type: Test Method
    * Version     : 1.0 
    * Created Date: 1st Feb 2016
    * Description:   
    * Scenario Type: Positive 
    * Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                       02/01/2015                Created
    ****************************************************************************************************/         
    public static testmethod void inactivatingIPtest(){
        getRecords();
        Test.starttest();
        List<Contact> updatecontactList =  new List<Contact>();
        System.runAs(systUserRunAs){        
            for(Contact contactRecord: contactListOptIn){
                contactRecord.Core_IPS_Email_Opt_Out__c = true;
                updatecontactList.add(contactRecord);
            }
            update updatecontactList;
        }
        Test.stoptest();
        
    }
    
    /***************************************************************************************************
    * Method Name: reactivatingIPtest
    * Method Type: Test Method
    * Version     : 1.0 
    * Created Date: 19th Dec 2015
    * Description:  
    * Scenario Type: Positive 
    * Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                       02/01/2015                Created
    ****************************************************************************************************/         
    public static testmethod void reactivatingIPtest(){
        getRecords();
        Test.starttest();
        List<Contact> updatecontactList =  new List<Contact>();
        System.runAs(systUserRunAs){
            for(Contact contactRecord: contactListOptOut){
                contactRecord.Core_IPS_Email_Opt_Out__c = false;
                updatecontactList.add(contactRecord);
            }
            update updatecontactList;
        }
        Test.stoptest();
        
    }  

    /***************************************************************************************************
    * Method Name: reactivatingIPtest
    * Method Type: Test Method
    * Version     : 1.0 
    * Created Date: 19th Dec 2015
    * Description:  
    * Scenario Type: Positive 
    * Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                       02/01/2015                Created
    ****************************************************************************************************/         
    public static List<Core_IPS_Project__c> projectList =  new List<Core_IPS_Project__c>();
    public static List<Core_IPS_Project_Member__c> projMembersList = new List<Core_IPS_Project_Member__c>();
    public static List<User> contactUserList = new List<User>();
    public static testmethod void inactivateProjectMembers(){
        getRecords();
        Test.starttest();
        List<Contact> updatecontactList =  new List<Contact>();
        System.runAs(systUserRunAs){
            Profile prof = [select id from profile where name = 'IPS External Customer' limit 1];
            contactUserList = TestUtilities.getListOfUser(1);
            contactUserList[0].profileId=prof.id;
            contactUserList[0].contactid=contactListOptIn[0].id;
            contactUserList[0].username='teshekx@test.com';
            insert contactUserList;
            Id testUserId = contactUserList[0].id;
            projectList = TestUtilities.getListOfIpsProjects(2);
            // Create Project Member
            projMembersList = TestUtilities.getListOfProjectMembers(2);
            for(Core_IPS_Project_Member__c projMem : projMembersList){
                projMem.Core_IPS_Contact__c = contactListOptIn.get(0).Id;
                projMem.Core_IPS_Project__c = projectList.get(0).Id;
                projMem.Core_Status__c = 'Active';
                projMem.Core_User__c = testUserId;            
            }
            for(Contact contactRecord: contactListOptIn){
                contactRecord.Core_IPS_Active__c  = false;
                updatecontactList.add(contactRecord);
            }
            update updatecontactList;
        }
        Test.stoptest();
        
    }
           
    
}