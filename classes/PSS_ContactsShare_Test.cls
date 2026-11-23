@isTest
private class PSS_ContactsShare_Test{

    /*@testSetup static void setup(){

        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator'  AND isActive=true Limit 1];
        UserRole role = [Select id from UserRole where DeveloperName = 'Admin' limit 1]; 
        adminUser.userRoleId = role.id;
        update adminUser;
        
        System.runAs(adminUser){
        Profile salesRepPrf = [select id, name from Profile where name = 'Partner' Limit 1];
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //UserRole portalRole = [Select Id,Name,DeveloperName From UserRole Where Name = 'Basic Access_1 Partner User' Limit 1];
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id intelAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];

        User partnerOwner = PSS_TestDataUtility.partnerAccountOwner();
        System.runAs ( thisUser ) {
            insert partnerOwner;
        }

        Account partnerAccount = PSS_TestDataUtility.createPartnerAccount('TestPartnerAccount2',devRecordTypeId,partnerOwner.Id);
        partnerAccount.Core_User_Defined_Website__c='https://intel.com';
        System.runAs ( thisUser ) {
            insert partnerAccount;
        }

        Account intelAccount1 = PMP_TestDataUtility.createIntelAccount('TestPartnerAccount3',intelAccountRecordTypeId,true);
        intelAccount1.Core_User_Defined_Website__c='https://intel.com';
        update intelAccount1;

        List<Contact> conList = new List<Contact>();
        Contact contact1 = PSS_TestDataUtility.createPartnerContact('Test1','test12345@intel.com',intelAccount1.Id);
        conList.add(contact1);
        
        Contact contact2 = PSS_TestDataUtility.createPartnerContact('Test2','test123@intel.com',partnerAccount.Id);
        conList.add(contact2);
        System.runAs ( thisUser ) {
            insert conList;
        }

        List<User> userList = new List<User>();

        Profile portalProfile = [SELECT Id,UserType FROM Profile WHERE UserType = 'PowerPartner' Limit 1];
        UserRole partnerRole = [Select Id From UserRole Where PortalType = 'Partner' Limit 1];
        
       String orgId = UserInfo.getOrganizationId();
       String dateString = 
       String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
       Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
       String uniqueName = orgId + dateString + randomInt;

        User usr1 = new User();
        usr1.Username = uniqueName + '@test' + orgId + '.org';
        usr1.ContactId = contact1.Id;
        usr1.ProfileId = portalProfile.Id;
        usr1.Alias = 'gM1235';
        usr1.Email = 'test12345@intel.com';
        usr1.EmailEncodingKey = 'UTF-8';
        usr1.LastName = 'McTesty';
        usr1.CommunityNickname = 'test123456';
        usr1.TimeZoneSidKey = 'America/Los_Angeles';
        usr1.LocaleSidKey = 'en_US';
        usr1.LanguageLocaleKey = 'en_US';
        //usr1.UserRoleId = partnerRole.id;

        usr1.contact = contact1;
        userList.add(usr1);
        
        User usr2 = new User();
        usr2.Username = uniqueName + '@test1' + orgId + '.org';
        usr2.ContactId = contact2.Id;
        usr2.ProfileId = portalProfile.Id;
        usr2.Alias = 'gM2356';
        usr2.Email = 'test123@intel.com';
        usr2.EmailEncodingKey = 'UTF-8';
        usr2.LastName = 'McTesty1';
        usr2.CommunityNickname = 'user2356';
        usr2.TimeZoneSidKey = 'America/Los_Angeles';
        usr2.LocaleSidKey = 'en_US';
        usr2.LanguageLocaleKey = 'en_US';
        usr2.contact = contact2;
       //usr2.UserRoleId = partnerRole.id;
        userList.add(usr2);
        
        System.runAs ( thisUser ) {
            insert userList;
        }

        List<Core_Account_Group_Member__c> accgrp = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c accGroupMem = new Core_Account_Group_Member__c();
        accGroupMem.Core_Partner_Account_Id__c =partnerAccount.Id;
        accGroupMem.Core_Intel_Account_Id__c =intelAccount1.Id;
        insert accGroupMem;

        ChannelProgram testChannelProgram = new ChannelProgram();
        testChannelProgram.Name='Member';
        insert testChannelProgram;
        
        PRM_ContactRelationships__c cr1 = new PRM_ContactRelationships__c();
        cr1.Name = 'Employee';
        cr1.PRM_Contact_Relationship_Cd__c = 'PRIMCONTDEL';
        insert cr1;

        List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = intelAccount1.Id;
        acr.PRM_Contact_Id__c = contact1.Id;
        acr.PRM_InActive_Ind__c = false;
        acr.PRM_Status_Nm__c = 'Complete';
        acr.PRM_Relationship_Id__c = cr1.Id;
        acrList.add(acr);

        PRM_Account_Contact_Relationship__c acr2 = new PRM_Account_Contact_Relationship__c();
        acr2.PRM_Account_Id__c = partnerAccount.Id;
        acr2.PRM_Contact_Id__c = contact2.Id;
        acr2.PRM_InActive_Ind__c = false;
        acr2.PRM_Status_Nm__c = 'Complete';
        acr2.PRM_Relationship_Id__c = cr1.Id;
        acrList.add(acr2);
        insert acrList;

        List<PMP_Company__c> pmpCpmpany = new List<PMP_Company__c>();

        PMP_Company__c companyInfo1 = PSS_TestDataUtility.createCompany('intelCompany1',partnerAccount.Id,PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED);
        pmpCpmpany.add(companyInfo1);
        PMP_Company__c companyInfo3 = PSS_TestDataUtility.createCompany('intelCompany2',intelAccount1.Id,'Solutions Marketplace Basic Profile');
        pmpCpmpany.add(companyInfo3);
        insert pmpCpmpany;

        PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering1','Public Content', 
                                                                           'TestDuplicate',companyInfo1.Id, true,'Draft','');  
        
        ArdiraSurvey__Survey__c survey = PSS_TestDataUtility.createSurvey();
        insert survey;

        List<ArdiraSurvey__Survey_Result__c> surveyResultList = new List<ArdiraSurvey__Survey_Result__c>();
        ArdiraSurvey__Survey_Result__c surveyResult1 = PSS_TestDataUtility.createArdiraSolution(survey.Id,companyInfo1.Id,partnerAccount.Id);
        surveyResultList.add(surveyResult1);
        
        ArdiraSurvey__Survey_Result__c surveyResult3 = PSS_TestDataUtility.createArdiraSolution(survey.Id,companyInfo3.Id,intelAccount1.Id);
        surveyResultList.add(surveyResult3);
        insert surveyResultList;

        List<ArdiraSurvey__Survey_Result__Share> shareResultList = new List<ArdiraSurvey__Survey_Result__Share>();
        ArdiraSurvey__Survey_Result__Share sharedSolution = new ArdiraSurvey__Survey_Result__Share();
        sharedSolution.ParentId = surveyResult1.Id;
        sharedSolution.UserOrGroupId = usr1.id;
        sharedSolution.AccessLevel ='edit';
        sharedSolution.RowCause ='Manual';
        shareResultList.add(sharedSolution);

        insert shareResultList; 
        }
    }

    @isTest static void testRetrieveContactForPartnerAccount() {

        Account acclist = [Select Id,Name,RecordType.DeveloperName from Account where Name =: 'TestPartnerAccount2'];//RecordType.DeveloperName =: 'Core_Partner_Account_Group' limit 1];
    System.Debug('acclist in test class ---->'+acclist);
        Ardirasurvey__survey_result__c surveyList = [Select Id, PSS_Proposal_Name_Txt__c,PSS_OPID_Account_Id__c, PSS_Company_Id__c,PSS_Partner_Account_Id__c,ArdiraSurvey__Assigned_To_Contact__c from ArdiraSurvey__Survey_Result__c 
                                                        where PSS_Partner_Account_Id__c =: accList.Id LIMIT 1];
        surveyList.PSS_OPID_Account_Id__c=surveyList.PSS_Partner_Account_Id__c;
        update surveyList;
       // system.debug('surveyList:----->'+surveyList.PSS_OPID_Account_Id__c);
        Test.startTest();
        List<Contact> conList = new List<Contact>(); 
            conList = PSS_ContactsShare.retrieveContact(surveyList.Id);
        Test.stopTest();
        System.assertEquals(conList.size()>0,true,PSS_ContactsShare.class.getName() + 'TestMethod: ' + 'testRetrieveContact()' + ' failed');

    }

    @isTest static void testRetrieveContactForIntelAccount() {

        Account acclist = [Select Id,Name,RecordType.DeveloperName from Account where RecordType.DeveloperName =: 'Mastered_Account' limit 1];

        Ardirasurvey__survey_result__c surveyList = [Select Id, PSS_Proposal_Name_Txt__c, PSS_Company_Id__c,PSS_Partner_Account_Id__c,
                                                     ArdiraSurvey__Assigned_To_Contact__c,PSS_OPID_Account_Id__c from ArdiraSurvey__Survey_Result__c 
                                                        where PSS_Partner_Account_Id__c =: accList.Id LIMIT 1];
    system.debug('###surveyList:->'+surveyList);
        Test.startTest();
        List<Contact> conList = new List<Contact>();
            conList = PSS_ContactsShare.retrieveContact(surveyList.Id);
        Test.stopTest();
        //System.assertEquals(conList.size()>0,true,PSS_ContactsShare.class.getName() + 'TestMethod: ' + 'testRetrieveContact()' + ' failed');
    system.debug('###conList:->'+conList);
        System.assertEquals(conList.size()>0,true);
    }

    @isTest static void testRetrieveShareRecords() {
        Ardirasurvey__survey_result__c surveyList = [Select Id, PSS_Proposal_Name_Txt__c, PSS_Company_Id__c,PSS_Partner_Account_Id__c,ArdiraSurvey__Assigned_To_Contact__c from ArdiraSurvey__Survey_Result__c 
                                                        LIMIT 1];
        List<Contact> conList = [Select Id, Name, FirstName, LastName,Email from Contact Limit 1];
        Test.startTest();
        List<Object> shareList = PSS_ContactsShare.retrieveShareRecords(conList,surveyList.Id);
        Test.stopTest();
        System.assertEquals(shareList.size()>0,true,PSS_ContactsShare.class.getName() + 'TestMethod: ' + 'testRetrieveShareRecords()' + ' failed');
    }

    @isTest static void testSearchContact() {

        List<Object> conList = [Select Id, Name, FirstName, LastName,Email from Contact LIMIT 1];
        String searchKey = 'test';
        Test.startTest();
        List<Object> contactList = PSS_ContactsShare.searchContact(conList,searchKey);
        Test.stopTest();
        System.assertEquals(contactList.size()>0,true,PSS_ContactsShare.class.getName() + 'TestMethod: ' + 'testSearchContact()' + ' failed');
    }

    @isTest static void testSharingSolutionRecords() {

        List<Object> conList = [Select Id, Name, FirstName, LastName,Email from Contact LIMIT 1];
        Ardirasurvey__survey_result__c surveyList = [Select Id, PSS_Proposal_Name_Txt__c, PSS_Company_Id__c,PSS_Partner_Account_Id__c,ArdiraSurvey__Assigned_To_Contact__c from ArdiraSurvey__Survey_Result__c 
                                                        LIMIT 1];
        Test.startTest();
        List<Object> shareList = PSS_ContactsShare.sharingSolutionRecords(conList,surveyList.Id);
        List<Object> shareList1 = PSS_ContactsShare.shareSolution(conList,surveyList.Id);
        Test.stopTest();
        System.assertEquals(shareList.size()>0,true,PSS_ContactsShare.class.getName() + 'TestMethod: ' + 'testSharingSolutionRecords()' + ' failed');
        System.assertEquals(shareList1.size()>0,true,PSS_ContactsShare.class.getName() + 'TestMethod: ' + 'testSharingSolutionRecords()' + ' failed');

    }

    @isTest static void testSharingSolutionRecordsForEmptyList() {

        List<Object> conList = [Select Id, Name, FirstName, LastName,Email from Contact where Name Like 'Test5%' LIMIT 1];
        
        Ardirasurvey__survey_result__c surveyList = [Select Id, PSS_Proposal_Name_Txt__c, PSS_Company_Id__c,PSS_Partner_Account_Id__c,ArdiraSurvey__Assigned_To_Contact__c from ArdiraSurvey__Survey_Result__c 
                                                       LIMIT 1];
        Test.startTest();
        List<Object> shareList = PSS_ContactsShare.sharingSolutionRecords(conList,surveyList.Id);
        Test.stopTest();
        System.assertEquals(shareList.size() == 0,true,PSS_ContactsShare.class.getName() + 'TestMethod: ' + 'testSharingSolutionRecords()' + ' failed');

    }
    
    @isTest static void testFetchSharedContactsForSolutionforEmptyList() {

        List<Object> conList = [Select Id, Name, FirstName, LastName,Email from Contact where Name Like 'Test5%' LIMIT 1];
        
        Ardirasurvey__survey_result__c surveyList = [Select Id, PSS_Proposal_Name_Txt__c, PSS_Company_Id__c,PSS_Partner_Account_Id__c,ArdiraSurvey__Assigned_To_Contact__c from ArdiraSurvey__Survey_Result__c 
                                                       LIMIT 1];
        Test.startTest();
        List<Object> shareList = PSS_ContactsShare.fetchSharedContactsForSolution(surveyList.Id);
        Test.stopTest();
        System.assertEquals(shareList.size() == 0,true,PSS_ContactsShare.class.getName() + 'TestMethod: ' + 'testFetchSharedContactsForSolution()' + ' failed');
    }*/
    
}