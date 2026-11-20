/**************************************************************************************
Apex Class Name : EPUM_SearchContact_Test
Version     : 1.0 
Created Date: 8th April 2020
Description : Test Class for Controller class to retrieve the Contact information based on Email
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Vaibhav                  08/04/2020             Original Version
*************************************************************************************/

@isTest(SeeAllData=false)
public class EPUM_SearchContact_Test{
    
    //public List<User> userList;
    
    @testSetup 
    static void setup() {
        /**** Fetching Record TypeId from custom label******/
        String partnerAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        //String core_Entitlement_Id_Label = System.Label.PMP_External_Entitlement_Ids;
        List<Account> accts = new List<Account>();   
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        //System.runAs (thisUser) {
        
        Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'PRC Sales Group',
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
        
        Account partnerAccount2 = new Account(Name ='PartnerAccount2',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'PRC Sales Group',
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
        
        Account partnerAccount3 = new Account(Name ='PartnerAccount3',Core_Account_Type__c = 'Distributor',
                                              Core_Sales_Groups__c= 'PRC Sales Group',
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, 
                                              BillingCity='delhi',BillingCountry='Ind',
                                              BillingStreet='abc chowk delhi');
        Account partnerAccount4 = new Account(Name ='PartnerAccount4',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'PRC Sales Group',
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
        Account partnerAccount5 = new Account(Name ='PartnerAccount5',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'PRC Sales Group',
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
        Account partnerAccount6 = new Account(Name ='PartnerAccount6',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'PRC Sales Group',
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',Core_PMP_Membership_Change_Ind__c=true);
        Account partnerAccount7 = new Account(Name ='PartnerAccount7',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'PRC Sales Group',
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
        Account partnerAccount8 = new Account(Name ='PartnerAccount8',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'PRC Sales Group',
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
        Account partnerAccount9 = new Account(Name ='PartnerAccount9',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'PRC Sales Group',
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
        
        
        //System.debug('partnerAccount test class ='+partnerAccount);
        accts.add(partnerAccount1);
        accts.add(partnerAccount2);
        accts.add(partnerAccount3);
        accts.add(partnerAccount4);
        accts.add(partnerAccount5);
        accts.add(partnerAccount6);
        accts.add(partnerAccount7);
        accts.add(partnerAccount8);
        accts.add(partnerAccount9);
        //
        Id intelAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account intelAccount1 = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'PRC Sales Group', Core_User_Defined_Website__c = 'https://test.com',
                                            Industry='Agriculture', RecordTypeId=intelAccountRTId,BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi', Core_IPA_Partner_Role__c = 'Distributor');
        Account intelAccount2 = new Account(Name ='IntelAccount2',Core_Account_Type__c = 'System Integrator',Core_Sales_Groups__c= 'PRC Sales Group', Core_User_Defined_Website__c = 'https://test.com',
                                            Industry='Agriculture',RecordTypeId=intelAccountRTId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        Account intelAccount3 = new Account(Name ='IntelAccount3',Core_Account_Type__c = 'System Integrator',Core_Sales_Groups__c= 'PRC Sales Group', Core_User_Defined_Website__c = 'https://test.com',
                                            Industry='Agriculture',RecordTypeId=intelAccountRTId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi'
                                           ); 
        Account intelAccount4 = new Account(Name ='IntelAccount4',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'PRC Sales Group', Core_User_Defined_Website__c = 'https://test.com',
                                            Industry='Agriculture',RecordTypeId=intelAccountRTId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        Account intelAccount5 = new Account(Name ='IntelAccount5',Core_Account_Type__c = 'System Integrator',Core_Sales_Groups__c= 'PRC Sales Group', Core_User_Defined_Website__c = 'https://test.com',
                                            Industry='Agriculture',RecordTypeId=intelAccountRTId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        Account intelAccount6 = new Account(Name ='IntelAccount6',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'PRC Sales Group', Core_User_Defined_Website__c = 'https://test.com',
                                            Industry='Agriculture', RecordTypeId=intelAccountRTId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        Account intelAccount7 = new Account(Name ='IntelAccount7',Core_Account_Type__c = 'System Integrator',Core_Sales_Groups__c= 'PRC Sales Group', Core_User_Defined_Website__c = 'https://test.com',
                                            Industry='Agriculture',RecordTypeId=intelAccountRTId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi'); 
        Account intelAccount8 = new Account(Name ='IntelAccount8',Core_Account_Type__c = 'System Integrator',Core_Sales_Groups__c= 'PRC Sales Group', Core_User_Defined_Website__c = 'https://test.com',
                                            Industry='Agriculture',RecordTypeId=intelAccountRTId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        Account intelAccount9 = new Account(Name ='IntelAccount9',Core_Account_Type__c = 'System Integrator',Core_Sales_Groups__c= 'PRC Sales Group', Core_User_Defined_Website__c = 'https://test.com',
                                            Industry='Agriculture',RecordTypeId=intelAccountRTId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi'); 
        Account intelAccount10 = new Account(Name ='IntelAccount10',Core_Account_Type__c = 'System Integrator',Core_Sales_Groups__c= 'PRC Sales Group', Core_User_Defined_Website__c = 'https://test.com',
                                             Industry='Agriculture',RecordTypeId=intelAccountRTId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        
        Account intelAccount11 = new Account(Name ='IntelAccount11',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'PRC Sales Group', Core_User_Defined_Website__c = 'https://test.com',
                                             Industry='Agriculture',RecordTypeId=intelAccountRTId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi', Core_IPA_Partner_Role__c = 'Builder');
        
        accts.add(intelAccount1);
        accts.add(intelAccount2);
        accts.add(intelAccount3);
        accts.add(intelAccount4);
        accts.add(intelAccount5);
        accts.add(intelAccount6);
        accts.add(intelAccount7);
        accts.add(intelAccount8);
        accts.add(intelAccount9);
        accts.add(intelAccount10);
        accts.add(intelAccount11);
        
        // Inserting Acounts
        Database.insert(accts);
        
        System.debug('Accounts = '+ accts);
        List<Account> allPartnerAccount = new List<Account>();
        allPartnerAccount = [SELECT Id,Name,RecordTypeId FROM Account WHERE RecordTypeId=:partnerAccRecTypeId];
        /****** Updating Account As Partner*****/
        List<Account> accToUpdate = new List<Account>();
        For(Account acc:accts){
            acc.IsPartner = true;
            accToUpdate.add(acc);
        }
        Database.update(accToUpdate);
        
        System.debug('accToUpdate ='+accToUpdate);
        
        /****** Creating Partner account group member record*****/
        List<Core_Account_Group_Member__c> allPag = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c accGroupMem1 = new Core_Account_Group_Member__c();
        accGroupMem1.Core_Partner_Account_Id__c =partnerAccount1.Id;
        accGroupMem1.Core_Intel_Account_Id__c =intelAccount1.Id;
        //accGroupMem1.Core_Partner_Account_Id__r.Core_PMP_Membership_Change_Ind__c = true;
        allPag.add(accGroupMem1);
        
        Core_Account_Group_Member__c accGroupMem2 = new Core_Account_Group_Member__c();
        
        accGroupMem2.Core_Partner_Account_Id__c =partnerAccount2.Id;
        accGroupMem2.Core_Intel_Account_Id__c =intelAccount2.Id;
        allPag.add(accGroupMem2);
        
        Core_Account_Group_Member__c accGroupMem3 = new Core_Account_Group_Member__c();
        accGroupMem3.Core_Partner_Account_Id__c =partnerAccount3.Id;
        accGroupMem3.Core_Intel_Account_Id__c =intelAccount3.Id;
        allPag.add(accGroupMem3);
        
        Core_Account_Group_Member__c accGroupMem4 = new Core_Account_Group_Member__c();
        accGroupMem4.Core_Partner_Account_Id__c =partnerAccount1.Id;
        accGroupMem4.Core_Intel_Account_Id__c =intelAccount4.Id;
        allPag.add(accGroupMem4);
        
        Core_Account_Group_Member__c accGroupMem5 = new Core_Account_Group_Member__c();
        accGroupMem5.Core_Partner_Account_Id__c =partnerAccount5.Id;
        accGroupMem5.Core_Intel_Account_Id__c =intelAccount5.Id;
        allPag.add(accGroupMem5);
        
        Core_Account_Group_Member__c accGroupMem6 = new Core_Account_Group_Member__c();
        accGroupMem6.Core_Partner_Account_Id__c =partnerAccount6.Id;
        accGroupMem6.Core_Intel_Account_Id__c =intelAccount6.Id;
        accGroupMem6.Core_Inactive_Ind__c = false;
        allPag.add(accGroupMem6);
        
        Core_Account_Group_Member__c accGroupMem7 = new Core_Account_Group_Member__c();
        accGroupMem7.Core_Partner_Account_Id__c =partnerAccount6.Id;
        accGroupMem7.Core_Intel_Account_Id__c =intelAccount7.Id;
        accGroupMem7.Core_Inactive_Ind__c = false;
        allPag.add(accGroupMem7); 
        
        Core_Account_Group_Member__c accGroupMem8 = new Core_Account_Group_Member__c();
        accGroupMem8.Core_Partner_Account_Id__c =partnerAccount7.Id;
        accGroupMem8.Core_Intel_Account_Id__c =intelAccount8.Id;
        accGroupMem8.Core_Inactive_Ind__c = false;
        allPag.add(accGroupMem8);
        
        
        Core_Account_Group_Member__c accGroupMem9 = new Core_Account_Group_Member__c();
        accGroupMem9.Core_Partner_Account_Id__c =partnerAccount7.Id;
        accGroupMem9.Core_Intel_Account_Id__c =intelAccount9.Id;
        accGroupMem9.Core_Inactive_Ind__c = false;
        allPag.add(accGroupMem9); 
        
        Core_Account_Group_Member__c accGroupMem10 = new Core_Account_Group_Member__c();
        accGroupMem10.Core_Partner_Account_Id__c =partnerAccount8.Id;
        accGroupMem10.Core_Intel_Account_Id__c =intelAccount10.Id;
        accGroupMem10.Core_Inactive_Ind__c = false;
        allPag.add(accGroupMem10);
        
        Core_Account_Group_Member__c accGroupMem11 = new Core_Account_Group_Member__c();
        
        accGroupMem11.Core_Partner_Account_Id__c =partnerAccount9.Id;
        accGroupMem11.Core_Intel_Account_Id__c =intelAccount11.Id;
        accGroupMem11.Core_Inactive_Ind__c = false;
        allPag.add(accGroupMem11);
      //  Test.startTest();
        //Inserting Account Group Member Record
        Database.insert(allPag);
        accGroupMem7.Core_Inactive_Ind__c = true;
        update accGroupMem7;
        /****** Creating ERPM_Engagement record*****/
        Core_ERPM_Engagement__c erpmEng1 =new Core_ERPM_Engagement__c(Name  ='Intel Premier Support',Core_IsActive__c=true);
        Database.insert(erpmEng1);
        System.debug('erpmEngagements ='+erpmEng1);
        
        /****** Creating Contact record*****/
        List<Contact> allContacts = new List<Contact>();
        Contact contact1 = new Contact(firstname='Intel', MailingCountry='India',
                                       lastname='Contact1', accountId=intelAccount4.id,Core_Enterprise_Id__c='300002701661',Email='dellco1234c1@dell.com',Core_IPA_PartnerRole__c = 'Distributor');
        allContacts.add(contact1);
        
        Contact contact2 = new Contact(firstname='Intel', MailingCountry='India',
                                       lastname='Contact2', accountId=intelAccount1.id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                       Core_Enterprise_Id__c='300002701661',Email='dellco12345c2@dell.com', Core_IPA_PartnerRole__c = 'Distributor');
        allContacts.add(contact2);
        
        Contact contact7 = new Contact(firstname='Intel', MailingCountry='India',
                                       lastname='Contact7', accountId=intelAccount2.id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                       Core_Enterprise_Id__c='300002701661',Email='dellco12345c7@dell.com');
        allContacts.add(contact7);
        Contact contact3 = new Contact(firstname='Intel', MailingCountry='India',
                                       lastname='Contact3', accountId=intelAccount11.Id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                       Core_Enterprise_Id__c='300002701661',Email='dellco12345c3@dell.com', Core_IPA_PartnerRole__c = 'Solution Integrator');
        allContacts.add(contact3);
        Contact contact4 = new Contact(firstname='Intel', MailingCountry='India',
                                       lastname='Contact4', accountId=intelAccount7.Id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                       Core_Enterprise_Id__c='300002701661',Email='dellco12345c4@dell.com');
        allContacts.add(contact4); 
        Contact contact5 = new Contact(firstname='Intel', MailingCountry='India',
                                       lastname='Contact5', accountId=intelAccount8.Id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                       Core_Enterprise_Id__c='300002701661',Email='dellco12345c5@dell.com', Core_IPA_PartnerRole__c = 'Solution Integrator');
        allContacts.add(contact5);
        Contact contact6 = new Contact(firstname='Intel', MailingCountry='India',
                                       lastname='Contact6', accountId=intelAccount1.Id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                       Core_Enterprise_Id__c='300002701661',Email='dellco12345c6@dell.com', Core_IPA_PartnerRole__c = 'Distributor');
        allContacts.add(contact6); 
        Contact contact8 = new Contact(firstname='Intel', Core_IPA_PartnerRole__c = 'Distributor',MailingCountry='India',
                                       lastname='Contact8', accountId=intelAccount10.id,Core_Enterprise_Id__c='300002701661',Email='dellco1234c8@dell.com');
        allContacts.add(contact8);
        Contact contact9 = new Contact(firstname='Intel', Core_IPA_PartnerRole__c = 'Distributor',MailingCountry='India',
                                       lastname='Contact9', accountId=intelAccount1.id,Core_Enterprise_Id__c='300002701661',Email='dellco1234i10@dell.com');
        allContacts.add(contact9);
        Contact contact10 = new Contact(firstname='Intel', MailingCountry='India',
                                        lastname='Contact10', accountId=intelAccount1.Id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                        Core_Enterprise_Id__c='300002701661',Email='dellco12345c10@dell.com');
        allContacts.add(contact10); 
        
        Contact contact11 = new Contact(firstname='Intel', MailingCountry='India',
                                        lastname='Contact11', accountId=intelAccount1.Id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                        Core_Enterprise_Id__c='300002701661',Email='dellco12345c11@dell.com');
        allContacts.add(contact11);
        
        Contact contact12 = new Contact(firstname='Intel', MailingCountry='India',
                                        lastname='Contact12', accountId=intelAccount1.Id, Core_IPA_Contact_Segment__c ='Internet of Things and Embedded;Client Computing;Data Center',
                                        Core_Enterprise_Id__c='300002701661',Email='dellco12345c12@dell.com', Core_IPA_PartnerRole__c = 'Distributor');
        allContacts.add(contact12);
        
        
        //Test.startTest();
        Database.insert(allContacts);
        System.debug('contact1 ='+contact1);
        
        
        /****** Creating Contact Relationship record*****/            
        PRM_ContactRelationships__c cr = new PRM_ContactRelationships__c();
        cr.PRM_Contact_Relationship_Cd__c = 'WORKSFOR';
        cr.Name = 'Employee';
        insert cr;
        
        /****** Creating ACR record*****/
        List<PRM_Account_Contact_Relationship__c> insertAcrs = new List<PRM_Account_Contact_Relationship__c>();
        Contact con = [Select Id,Name,AccountId from Contact Where Email='dellco12345c2@dell.com'];
        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = con.AccountId;
        acr.PRM_Contact_Id__c = con.Id;
        acr.PRM_Relationship_Id__c = cr.Id;
        acr.PRM_Status_Nm__c = 'Pending Action';
        acr.PRM_Status_Reason_Txt__c='test';
        insertAcrs.add(acr);
        
        Contact con1 = [Select Id,Name,AccountId,Core_IPA_PartnerRole__c,Core_IPA_One_Partner_Id__c from Contact Where Email='dellco12345c6@dell.com'];
        PRM_Account_Contact_Relationship__c acr1 = new PRM_Account_Contact_Relationship__c();
        acr1.PRM_Account_Id__c = con1.AccountId;
        acr1.PRM_Contact_Id__c = con1.Id;
        acr1.PRM_Relationship_Id__c = cr.Id;
        acr1.PRM_Status_Nm__c = 'Pending Action';
        acr1.PRM_Status_Reason_Txt__c='test';
        insertAcrs.add(acr1);
        
        PRM_Account_Contact_Relationship__c acr2 = new PRM_Account_Contact_Relationship__c();
        acr2.PRM_Account_Id__c = contact11.AccountId;
        acr2.PRM_Contact_Id__c = contact11.Id;
        acr2.PRM_Relationship_Id__c = cr.Id;
        acr2.PRM_Status_Nm__c = 'Complete';
        acr2.PRM_InActive_Ind__c = true;
        acr2.PRM_Status_Reason_Txt__c='test';
        insertAcrs.add(acr2);
        
        PRM_Account_Contact_Relationship__c acr3 = new PRM_Account_Contact_Relationship__c();
        acr3.PRM_Account_Id__c = contact12.AccountId;
        acr3.PRM_Contact_Id__c = contact12.Id;
        acr3.PRM_Relationship_Id__c = cr.Id;
        acr3.PRM_Status_Nm__c = 'Complete';
        acr3.PRM_InActive_Ind__c = true;
        acr3.PRM_Status_Reason_Txt__c='test';
        insertAcrs.add(acr3);
        test.startTest();
        insert insertAcrs;
        
        acr.PRM_Status_Nm__c = 'Complete';
        update acr;
    //    Test.stopTest();
        /****** Creating Channel Program record*****/
        ChannelProgram newCP = new ChannelProgram();
        newCP.Name = 'Intel Partner Alliance';
        newCP.IsActive = true;
        insert newCP;
        
        /****** Creating Account Channel Membership record*****/
        List<PRM_AccountChannelMembership__c> insertAcms = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acm1 = new PRM_AccountChannelMembership__c();
        acm1.PRM_Account_Id__c = con1.AccountId;
        acm1.PRM_Partner_Role__c = 'Distributor';
        acm1.PRM_Status_Nm__c = 'Approved';
        acm1.PRM_Status_Reason_Txt__c = 'Test class';
        insertAcms.add(acm1);
        Account opidAcc = [Select id from Account where name='PartnerAccount1' limit 1];
        PRM_AccountChannelMembership__c acm2 = new PRM_AccountChannelMembership__c();
        acm2.PRM_Account_Id__c = opidAcc.id;
        acm2.PRM_Partner_Role__c = 'Distributor';
        acm2.PRM_Status_Nm__c = 'Approved';
        acm2.PRM_Status_Reason_Txt__c = 'Test class';
        insertAcms.add(acm2);
        
        insert insertAcms;
        
        /****** Creating Pending Registration record*****
Id AccountCreateRT = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get('Account_Create_Request').getRecordTypeId();
PRM_Registration_Request__c pendingReg = new PRM_Registration_Request__c();
pendingReg.Name = 'Test Registration Request 1';
pendingReg.PRM_First_Name__c = 'First Name';
pendingReg.PRM_Last_Name__c = 'Last Name';
pendingReg.PRM_Email_ID__c = 'pendingregreq1234@mailer.com';
pendingReg.PRM_Status__c = 'New';
pendingReg.RecordTypeId = AccountCreateRT;
pendingReg.PRM_Partner_Role__c = con1.Core_IPA_PartnerRole__c;
pendingReg.PRM_Salesforce_ID__c = con1.AccountId;

insert pendingReg;
*/
        /*PRM_ContactRelationships__c cr = new PRM_ContactRelationships__c();
cr.PRM_Contact_Relationship_Cd__c = 'WORKSFOR';
cr.Name = 'Works For';
Insert cr;*/
        
        /****** Creating User record*****/
        List<user> userList = new List<User>();
        Profile profile = [select Id,name from Profile where Name ='Partner' Limit 1];
        //UserRole role = [select Id from UserRole where PortalType = 'Partner' Limit 1];
        intelAccount1.isPartner = true;
        update intelAccount1;
        //UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role', PortalType = 'CustomerPortal', PortalAccountId = intelAccount1.id);
        //insert r;
        User newUser1 = new User(
            // UserRoleId = userRole.Id,
            profileId = profile.id, 
            //UserRoleId = r.Id,
            username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com', 
            email = 'pbuser@ff.com', 
            emailencodingkey = 'UTF-8', 
            localesidkey = 'en_US', 
            languagelocalekey = 'en_US', 
            timezonesidkey = 'America/Los_Angeles', 
            alias='nuser', 
            lastname='lastname', 
            contactId = allContacts[0].id);
        User newUser2 = new User(
            // UserRoleId = userRole.Id,
            profileId = profile.id, 
            //UserRoleId = r.Id,
            username = 'testUser0'+String.valueOf(Math.random())+'@CoreMD.com', 
            email = 'pbuser0@ff0.com', 
            emailencodingkey = 'UTF-8', 
            localesidkey = 'en_US', 
            languagelocalekey = 'en_US', 
            timezonesidkey = 'America/Los_Angeles', 
            alias='nuser', 
            lastname='lastname', 
            contactId = allContacts[1].id);
        //insert newUser1;
        userList.add(newUser1);
        userList.add(newUser2);
        insert userList;
        //Database.insert(userList);
        //}
        //
        List<Core_AGS_Role__c> lstAGSRole = new List<Core_AGS_Role__c>();
        Core_AGS_Role__c testAGSRole = new Core_AGS_Role__c();
        testAGSRole.Name = 'Test SMP AGS Role ';
        testAGSRole.Core_IsActive__c = true;
        testAGSRole.Core_Technical_Name__c = 'Test SMP AGS Role Tech Name ';
        lstAGSRole.add(testAGSRole);
        
        /*Core_AGS_Role__c testAGSRole1 = new Core_AGS_Role__c();
testAGSRole1.Name = 'Test SMP AGS Role 00';
testAGSRole1.Core_IsActive__c = true;
testAGSRole1.Core_Technical_Name__c = 'Test SMP AGS Role Tech Name 00';
lstAGSRole.add(testAGSRole1);

Core_AGS_Role__c testAGSRole2 = new Core_AGS_Role__c();
testAGSRole2.Name = 'Test SMP AGS Role 01';
testAGSRole2.Core_IsActive__c = true;
testAGSRole2.Core_Technical_Name__c = 'Test SMP AGS Role Tech Name 01';
lstAGSRole.add(testAGSRole2);*/
        
        insert lstAGSRole;
        Core_Entitlement__c testEntitlementDetail = new Core_Entitlement__c();
        testEntitlementDetail.Name = 'Partner Admin';
        testEntitlementDetail.Core_Display_Name__c = 'Partner Admin';
        testEntitlementDetail.Core_AGS_Role_Id__c = testAGSRole.Id;
        testEntitlementDetail.Core_IsActive__c = true;
        insert testEntitlementDetail;
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c=allContacts[0].id, Core_From_Source__c=true, Core_Selected__c=true,Core_Data_Loaded__c= true,
            Core_Entitlement_Id__c=testEntitlementDetail.id,Core_Status__c ='Complete');
        insert ce;
        Test.stopTest();
        system.debug('test acr00');List<PRM_Account_Contact_Relationship__c> acr12 = [SELECT Id,PRM_Relationship_Id__r.Name,PRM_Status_Nm__c, PRM_InActive_Ind__c FROM PRM_Account_Contact_Relationship__c WHERE PRM_Contact_Id__r.Email = 'dellco12345c12@dell.com'];
        system.debug(acr12);
    }
    
    @isTest
    static void testSearchContactByEmail(){
        
        Test.startTest();
        User usr1 = [select Id from User where email = 'pbuser@ff.com'];
        
        
        
        //Login deleted 
        /*  EPUM_SearchContact.WrapperContactDetails result6 = EPUM_SearchContact.searchContactByEmail('dellco1234i1001@dell.com',usr1.Id);   
System.debug('result1'+result6);
System.assertEquals( true , result6 != null ? true : false, 'Contact deleted');*/
        EPUM_SearchContact.WrapperContactDetails result0 = EPUM_SearchContact.searchContactByEmail('dellco1234c1@dell.com',usr1.Id);
        System.debug('result0 '+result0);
        //perfect match Done
        EPUM_SearchContact.WrapperContactDetails result = EPUM_SearchContact.searchContactByEmail('dellco12345c2@dell.com',usr1.Id);   
        System.debug('result1'+result);
        System.assertEquals( true , result != null ? true : false, 'Contact Found');
        
        //contact not found in DB Done
        EPUM_SearchContact.WrapperContactDetails result1 = EPUM_SearchContact.searchContactByEmail('dellco12345c200@dell.com',usr1.Id);
        System.assertEquals( false , result1.isContactExistsinDB , 'Contact not found in DB');
        
        //contact not found under one partnerid
        EPUM_SearchContact.WrapperContactDetails result2 = EPUM_SearchContact.searchContactByEmail('dellco1234c8@dell.com',usr1.Id);
        System.assertEquals( false , result2.isContactExistsinOnePartnerAcc , 'Contact not found under PAG');
        
        //contact role miss match done
        EPUM_SearchContact.WrapperContactDetails result3 = EPUM_SearchContact.searchContactByEmail('dellco12345c3@dell.com',usr1.Id);
        System.assertEquals( false , result3.isContactExitssWithSameRole , 'Contact dont have a maching role');
        
        //contact invitation is in progress
        EPUM_SearchContact.WrapperContactDetails result4 = EPUM_SearchContact.searchContactByEmail('dellco12345c6@dell.com',usr1.Id); 
        system.debug('result4'+result4);
        System.assertEquals( true , result4.isPendingContact, 'Contact invitation is in progress');
        
        //contact without ACR
        EPUM_SearchContact.WrapperContactDetails result5 = EPUM_SearchContact.searchContactByEmail('dellco1234i10@dell.com',usr1.Id);   
        System.assertEquals( true , result5.isSendInvite, 'Contact without ACR');
        List<Contact> lstContacts = [SELECT Id, Email, Phone, Name, FirstName, LastName, AccountId, Account.Name, Core_IPA_One_Partner_Id__c, Core_IPA_PartnerRole__c,(SELECT PRM_Relationship_Id__r.Name,PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c,PRM_Status_Nm__c FROM Account_Contact_Relationships__r WHERE PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c =: 'WORKSFOR'), (SELECT Id,Core_Entitlement_Id__r.Name,Core_Entitlement_Id__c FROM Contact_Entitlements__r WHERE Core_Selected__c =true AND Core_Status__c ='Complete'  ORDER BY Core_Entitlement_Id__r.Name) FROM Contact WHERE Email ='dellco1234i10@dell.com'];
        system.debug('contacts'+lstContacts);
        
        //re-onboard old IPA contact with diffrent role
        EPUM_SearchContact.WrapperContactDetails result6 = EPUM_SearchContact.searchContactByEmail('dellco12345c11@dell.com',usr1.Id); 
        System.assertEquals( true , result6.isSendInvite, 're-onboard old IPA contact with diffrent role');
        
        //re-onboard old IPA contact with same role
        EPUM_SearchContact.WrapperContactDetails result7 = EPUM_SearchContact.searchContactByEmail('dellco12345c12@dell.com',usr1.Id); 
        System.assertEquals( true , result7.isSendInvite, 're-onboard old IPA contact with diffrent role');
        //system.debug('contacts acr'+lstContacts[0].Account_Contact_Relationships__r);
        Test.stopTest();
    }
    
    @isTest
    static void testFetchContactPickListValues() {
        
        Test.startTest();        
        EPUM_SearchContact.WrapperPicklists lstCountryValues = EPUM_SearchContact.fetchContactPickListValues('dellco12345c200@dell.com');
        System.assertNotEquals( null , lstCountryValues , 'picklist values returned');
        Test.stopTest();
    }
    
    @isTest
    static void testshowReInvite() {
        
        Test.startTest();
        Contact con1 = [Select Id,Name,AccountId,Core_IPA_PartnerRole__c,Core_IPA_One_Partner_Id__c from Contact Where Email='dellco12345c6@dell.com'];
        Boolean showReInviteResult = EPUM_SearchContact.showReInvite(con1.Id);
        System.assertEquals(true, showReInviteResult);
        Test.stopTest();
    }
    
    @isTest
    static void testsendReInvite() {
        
        Test.startTest();
        Map<String,String> mapSendReinviteStatus = EPUM_SearchContact.sendReInvite('dellco12345c6@dell.com');
        System.assertEquals( 'failed' , mapSendReinviteStatus.get('status') , 'contact reinvited successfully');
        Test.stopTest();
    }
    
    @isTest
    static void fetchPendingRegRequests() {
        Contact con1 = [Select Id,Name,AccountId,Core_IPA_PartnerRole__c,Core_IPA_One_Partner_Id__c from Contact Where Email='dellco12345c6@dell.com'][0];
        /****** Creating Pending Registration record****/
        Id AccountCreateRT = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get('Account_Create_Request').getRecordTypeId();
        PRM_Registration_Request__c pendingReg = new PRM_Registration_Request__c();
        pendingReg.Name = 'Test Registration Request 1';
        pendingReg.PRM_First_Name__c = 'First Name';
        pendingReg.PRM_Last_Name__c = 'Last Name';
        pendingReg.PRM_Email_ID__c = 'pendingregreq1234@mailer.com';
        pendingReg.PRM_Status__c = 'New';
        pendingReg.RecordTypeId = AccountCreateRT;
        pendingReg.PRM_Partner_Role__c = con1.Core_IPA_PartnerRole__c;
        pendingReg.PRM_Salesforce_ID__c = con1.AccountId;
        
        insert pendingReg;
        
        User usr1 = [select Id from User where email = 'pbuser@ff.com'];
        System.runAs(usr1){
            String secContactResult = EPUM_SearchContact.getMyCompanySecContForEPUM();
        }
    }
    
    @isTest
    static void fetchContactListView() {
        
        /*Core_AGS_Role__c testAGSRole = new Core_AGS_Role__c();

List<Core_AGS_Role__c> lstAgsRole = new List<Core_AGS_Role__c>();
/*testAGSRole.Name = 'Test SMP AGS Role 00';
testAGSRole.Core_IsActive__c = true;
testAGSRole.Core_Technical_Name__c = 'Test SMP AGS Role Tech Name 00 ';
lstAgsRole.add(testAGSRole);
insert lstAgsRole;*/
        /*lstAgsRole = [Select id from Core_AGS_Role__c where Core_Technical_Name__c in ('Test SMP AGS Role Tech Name','Test SMP AGS Role Tech Name 00','Test SMP AGS Role Tech Name 01')];
List<Core_Entitlement__c> lstEntitlement = new List<Core_Entitlement__c>();
/*Core_Entitlement__c testEntitlementDetail0 = new Core_Entitlement__c();
testEntitlementDetail0.Name = 'Partner Admin';
testEntitlementDetail0.Core_Display_Name__c = 'Partner Admin';
testEntitlementDetail0.Core_AGS_Role_Id__c = lstAgsRole[0].Id;
testEntitlementDetail0.Core_IsActive__c = true;
lstEntitlement.add(testEntitlementDetail0);*/
        
        /*Core_Entitlement__c testEntitlementDetail1 = new Core_Entitlement__c();
testEntitlementDetail1.Name = 'Partner Admin Delegate';
testEntitlementDetail1.Core_Display_Name__c = 'Partner Admin Delegate';
testEntitlementDetail1.Core_AGS_Role_Id__c = lstAgsRole[1].Id;
testEntitlementDetail1.Core_IsActive__c = true;
lstEntitlement.add(testEntitlementDetail1);

Core_Entitlement__c testEntitlementDetail2 = new Core_Entitlement__c();
testEntitlementDetail2.Name = 'Employee';
testEntitlementDetail2.Core_Display_Name__c = 'Employee';
testEntitlementDetail2.Core_AGS_Role_Id__c = lstAgsRole[2].Id;
testEntitlementDetail2.Core_IsActive__c = true;
lstEntitlement.add(testEntitlementDetail2);

insert lstEntitlement;



Test.startTest();
List<Core_Contact_Entitlement__c> lstConEntl = new List<Core_Contact_Entitlement__c>();
for(contact c :[select id,email from contact where email in ('dellco12345c6@dell.com','dellco1234i10@dell.com','dellco12345c10@dell.com','dellco12345c11@dell.com')]){
system.debug(c);
Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
ce.Core_Contact_Id__c = c.Id;
ce.Core_From_Source__c=true;
ce.Core_Selected__c=true;
ce.Core_Data_Loaded__c= true;
ce.Core_Entitlement_Id__c=lstEntitlement[1].Id;
ce.Core_Status__c ='Complete';

Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c();
ce1.Core_Contact_Id__c = c.Id;
ce1.Core_From_Source__c=true;
ce1.Core_Selected__c=true;
ce1.Core_Data_Loaded__c= true;
ce1.Core_Entitlement_Id__c=lstEntitlement[0].Id;
ce1.Core_Status__c ='Complete';

lstConEntl.add(ce);
lstConEntl.add(ce1);
}
system.debug('con ent '+lstConEntl);
insert lstConEntl;*/
        Test.startTest();
        User usr1 = [select Id from User where email = 'pbuser0@ff0.com'];
        System.runAs(usr1){
            EPUM_SearchContact.WrapperCotactListView lstView = EPUM_SearchContact.contactListView();
            System.assert(lstView != NULL );
            EPUM_SearchContact.isLoggedInUserPAOrPAD();
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void fetchContactListView1() {
        
        Test.startTest();
        User usr1 = [select Id from User where email = 'pbuser@ff.com'];
        System.runAs(usr1){
            EPUM_SearchContact.WrapperCotactListView lstView = EPUM_SearchContact.contactListView();
            System.assert(lstView != NULL );
            EPUM_SearchContact.isLoggedInUserPAOrPAD();
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testCreateContact() {
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'contact';
        con.email = 'testcontact@mail.com';
        con.MailingCountry = 'IND';
        con.Core_Preferred_Language__c ='ENG';
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test';
        //con1.LastName = 'contact';
        con1.email = 'testcontact1@mail.com';
        con1.MailingCountry = 'IND';
        con1.Core_Preferred_Language__c ='ENG';
        
        User usr1 = [select Id from User where email = 'pbuser0@ff0.com'];
        
        Test.startTest();        
        Map<String,String> mapContactStatus = EPUM_SearchContact.createContact(con, usr1.Id);
        
        Map<String,String> mapContactStatusError = EPUM_SearchContact.createContact(con1, usr1.Id);
        System.assertEquals( 'error' , mapContactStatusError.get('status') , 'contact creation failed');
        EPUM_SearchContact.insertEpumLog();
        System.runAs(usr1){
            List<Contact> con2 = [Select Id, AccountId, Core_IPA_PartnerRole__c FROM Contact Where Email='dellco12345c10@dell.com'];
            Map<String,String> mapCreateACR1 = EPUM_SearchContact.createACR(con2[0], null);
            List<Contact> con3 = [Select Id, AccountId, Core_IPA_PartnerRole__c FROM Contact Where Email='dellco12345c12@dell.com'];
            system.debug(con3);
            List<PRM_Account_Contact_Relationship__c> acr12 = [SELECT Id,PRM_Relationship_Id__r.Name,PRM_Status_Nm__c, PRM_InActive_Ind__c FROM PRM_Account_Contact_Relationship__c WHERE PRM_Contact_Id__r.Email = 'dellco12345c12@dell.com'];
            system.debug(acr12);
            Map<String,String> mapCreateACR2 = EPUM_SearchContact.createACR(con3[0], acr12[0]);
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCreateContact1() {
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'contact';
        con.email = 'testcontact@mail.com';
        con.MailingCountry = 'IND';
        con.Core_Preferred_Language__c ='ENG';
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test';
        //con1.LastName = 'contact';
        con1.email = 'testcontact1@mail.com';
        con1.MailingCountry = 'IND';
        con1.Core_Preferred_Language__c ='ENG';
        
         User usr1 = [select Id, ContactId, Contact.Account.id from User where email = 'pbuser0@ff0.com'];
        Contact contnew = new Contact();
        contnew.id = usr1.ContactId;
        contnew.MailingCountry = 'CUB';
        update contnew;              
        
        Test.startTest();    
        System.runAs(usr1){
            Map<String,String> mapContactStatus = EPUM_SearchContact.createContact(con1, usr1.Id);
            System.assertEquals( 'error' , mapContactStatus.get('status') , 'contact creation failed');
        }
        	
            contnew.MailingCountry = 'IND';
            update contnew;
        
            Account acc = new Account();
            acc.id = usr1.Contact.Account.id;
            acc.Core_User_Defined_Website__c = null;
            update acc;
         System.runAs(usr1){   
            Map<String,String> mapContactStatusError = EPUM_SearchContact.createContact(con1, usr1.Id);
            System.assertEquals( 'error' , mapContactStatusError.get('status') , 'contact creation failed');
                            
        }
        Test.stopTest();
    }       
    
    
    /*------------If T&C not checked Redirected to overview page - DRACO -start ------------------*/
    @isTest
    static void TCRedirection()
    {
        /* Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
Account testAccount = new Account();
testAccount.RecordTypeId = recordTypeIdAccount;
testAccount.Name='John Wick';
testAccount.BillingCity='City';
testAccount.BillingStreet='Street';
testAccount.BillingCountry='India';
testAccount.BillingPostalCode='Postal code';
testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
testAccount.Core_IPA_Partner_Speciality__c='Video Specialist;Cloud Data Center Specialist';
testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
testAccount.Industry='Construction';
testAccount.OwnerId = UserInfo.getUserId();
insert testAccount;
Contact cont2 = new Contact();  //Contact
cont2.AccountId=testAccount.Id;
cont2.lastName='John';
cont2.FirstName='Parker';
cont2.email='Peterparker@rediff.com';
cont2.Core_Job_Function__c='Branch Manager';
cont2.Core_IPA_PartnerRole__c='Distributor';
cont2.Core_Preferred_Language__c='FRA';
insert cont2;

Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='Partner'];
User partnerUser2 = new User(FirstName='Test2',LastName='User',alias='t2user',Email='mrt2r@mailinator.com',UserName='notheruser@xyz.com', ContactId=cont2.Id,ProfileId=communityUsrProfile.Id,
emailencodingkey='UTF-8', languagelocalekey='fr', localesidkey='fr_FR',timezonesidkey='Europe/London');//, UserRoleId = r.id);

insert partnerUser2;
Id userId2=partnerUser2.Id;
string ipalabel=Label.PRM_IPATNCCode;
*/
        /********Subhadeep change start*****/
        User partUser = [Select id from user where email = 'pbuser@ff.com'][0];
        /********Subhadeep change start*****/
        
        System.runAs(partUser)
        {
            Test.startTest();
            EPUM_SearchContact.TCRedirection();
            System.assertNotEquals( null , partUser.Id);
            test.stopTest();        
        }
        // System.assertEquals(cont.FirstName, 'Adam', 'Value does not match');
        
    }
    
    /*------------If T&C not checked Redirected to overview page - DRACO -End ------------------*/
}