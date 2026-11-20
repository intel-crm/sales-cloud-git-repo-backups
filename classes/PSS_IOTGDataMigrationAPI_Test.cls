@isTest
public class PSS_IOTGDataMigrationAPI_Test {
    
    //testsetup
    // @testSetup static void setup(){
    //     User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator'  AND isActive=true Limit 1];
    //     UserRole role = [Select id from UserRole where DeveloperName = 'Admin' limit 1]; 
    //     adminUser.userRoleId = role.id;
    //     update adminUser;
    //     System.runAs ( adminUser ) {
    //     ArdiraSurvey__Survey__c survey = PSS_TestDataUtility.createSurvey();
    //     insert survey;
        
    //     Profile salesRepPrf = [select id, name from Profile where name = 'Partner' Limit 1];
    //     Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
    //     UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
    //     Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
    //     Id intelAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    //     User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
    //     User partnerOwner = PSS_TestDataUtility.partnerAccountOwner();
    //     System.runAs ( thisUser ) {
    //         insert partnerOwner;
    //     }
        
    //     Account partnerAccount = PSS_TestDataUtility.createPartnerAccount('TestPartnerAccount2',devRecordTypeId,partnerOwner.Id);
    //     System.runAs ( thisUser ) {
    //         insert partnerAccount;
    //     }
        
    //     Account intelAccount1 = PMP_TestDataUtility.createIntelAccount('TestPartnerAccount3',intelAccountRecordTypeId,true);
        
    //     List<Contact> conList = new List<Contact>();
    //     Contact contact1 = PSS_TestDataUtility.createPartnerContact('Test1','test12345@intel.com',intelAccount1.Id);
    //     conList.add(contact1);
        
    //     Contact contact2 = PSS_TestDataUtility.createPartnerContact('Test2','abc@intel.com',intelAccount1.Id);
    //     conList.add(contact2);
    //     System.runAs ( thisUser ) {
    //         insert conList;
    //     }
        
        
    //     List<User> userList = new List<User>();
        
    //     Profile portalProfile = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' Limit 1];
        
        
    //     String orgId = UserInfo.getOrganizationId();
    //     String dateString = 
    //         String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    //     Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
    //     String uniqueName = orgId + dateString + randomInt;
        
    //     User usr1 = new User();
    //     usr1.Username = uniqueName + '@test' + orgId + '.org';
    //     usr1.ContactId = contact1.Id;
    //     usr1.ProfileId = portalProfile.Id;
    //     usr1.Alias = 'gM1235';
    //     usr1.Email = 'test12345@intel.com';
    //     usr1.EmailEncodingKey = 'UTF-8';
    //     usr1.LastName = 'McTesty';
    //     usr1.CommunityNickname = 'test123456';
    //     usr1.TimeZoneSidKey = 'America/Los_Angeles';
    //     usr1.LocaleSidKey = 'en_US';
    //     usr1.LanguageLocaleKey = 'en_US';
        
    //     usr1.contact = contact1;
    //     userList.add(usr1);
        
    //     User usr2 = new User();
    //     usr2.Username = uniqueName + '@test1' + orgId + '.org';
    //     usr2.ContactId = contact2.Id;
    //     usr2.ProfileId = portalProfile.Id;
    //     usr2.Alias = 'gM2356';
    //     usr2.Email = 'test123@intel.com';
    //     usr2.EmailEncodingKey = 'UTF-8';
    //     usr2.LastName = 'McTesty1';
    //     usr2.CommunityNickname = 'user2356';
    //     usr2.TimeZoneSidKey = 'America/Los_Angeles';
    //     usr2.LocaleSidKey = 'en_US';
    //     usr2.LanguageLocaleKey = 'en_US';
        
    //     usr2.contact = contact2;
    //     userList.add(usr2);
        
    //     System.runAs ( thisUser ) {
    //         insert userList;
    //     }
   
    //     List<Core_Account_Group_Member__c> accgrp = new List<Core_Account_Group_Member__c>();
    //     Core_Account_Group_Member__c accGroupMem = new Core_Account_Group_Member__c();
    //     accGroupMem.Core_Partner_Account_Id__c =partnerAccount.Id;
    //     accGroupMem.Core_Intel_Account_Id__c =intelAccount1.Id;
    //     insert accGroupMem;
        
    //     ChannelProgram testChannelProgram = new ChannelProgram();
    //     testChannelProgram.Name='Member';
    //     insert testChannelProgram;
        
    //     PRM_ContactRelationships__c cr1 = new PRM_ContactRelationships__c();
    //     cr1.Name = 'Employee';
    //     cr1.PRM_Contact_Relationship_Cd__c = 'PRIMCONTDEL';
    //     insert cr1;
        
    //     List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
    //     PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
    //     acr.PRM_Account_Id__c = intelAccount1.Id;
    //     acr.PRM_Contact_Id__c = contact1.Id;
    //     acr.PRM_InActive_Ind__c = false;
    //     acr.PRM_Status_Nm__c = 'Complete';
    //     acr.PRM_Relationship_Id__c = cr1.Id;
    //     acrList.add(acr);
        
    //     PRM_Account_Contact_Relationship__c acr2 = new PRM_Account_Contact_Relationship__c();
    //     acr2.PRM_Account_Id__c = intelAccount1.Id;
    //     acr2.PRM_Contact_Id__c = contact2.Id;
    //     acr2.PRM_InActive_Ind__c = false;
    //     acr2.PRM_Status_Nm__c = 'Complete';
    //     acr2.PRM_Relationship_Id__c = cr1.Id;
    //     acrList.add(acr2);
    //     insert acrList;
        
    //     List<PMP_Company__c> pmpCpmpany = new List<PMP_Company__c>();
        
    //     PMP_Company__c companyInfo1 = PSS_TestDataUtility.createCompany('intelCompany1',partnerAccount.Id,PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED);
    //     pmpCpmpany.add(companyInfo1);
    //     insert pmpCpmpany;
        
           
    //     /*List<ArdiraSurvey__Survey_Result__c> surveyResultList = new List<ArdiraSurvey__Survey_Result__c>();
    //     ArdiraSurvey__Survey_Result__c surveyResult1 = PSS_TestDataUtility.createArdiraSolution(survey.Id,companyInfo1.Id,partnerAccount.Id);
    //     surveyResultList.add(surveyResult1);
        
    //     List<ArdiraSurvey__Survey_Result__Share> shareResultList = new List<ArdiraSurvey__Survey_Result__Share>();
    //     ArdiraSurvey__Survey_Result__Share sharedSolution = new ArdiraSurvey__Survey_Result__Share();
    //     sharedSolution.ParentId = surveyResult1.Id;
    //     sharedSolution.UserOrGroupId = usr1.id;
    //     sharedSolution.AccessLevel ='edit';
    //     sharedSolution.RowCause ='Manual';
        
    //     insert shareResultList;*/
    //     } 
    // }
    
    
    // @isTest
    // static void testdoPostMethod(){
    //     ArdiraSurvey__Survey__c survey=[Select id,ArdiraSurvey__Logical_Id__c from ArdiraSurvey__Survey__c where name like '%Test Survey%' limit 1];
    //     ArdiraSurvey__Question__c ques = PSS_TestDataUtility.createQuestion(survey.id);
    //     insert ques;
    //     ques= [Select id,ArdiraSurvey__Logical_Id__c from ArdiraSurvey__Question__c where ArdiraSurvey__Type__c ='Text-Short' limit 1];
    //     // system.debug('survey.ArdiraSurvey__Logical_Id__c'+survey.ArdiraSurvey__Logical_Id__c);
    //     // system.debug('ques.ArdiraSurvey__Logical_Id__c'+ques.ArdiraSurvey__Logical_Id__c);
        
    //     Test.startTest(); 
    //     User u=[Select id from user where Username like '%@test1%' limit 1];
    //     RestRequest req = new RestRequest(); 
    //     RestResponse res = new RestResponse();
    //     req.addHeader('httpMethod', 'POST');
    //     req.requestUri = '/services/apexrest/IOTGMigration/';       
    //     String request = '{"results": [{"resultChoices": [],';
    //     request +='"ArdiraSurvey__Question__c": "'+ques.ArdiraSurvey__Logical_Id__c+'",';
    //     request +='"ArdiraSurvey__Answer_Text__c": null}],"PSS_Source_System__c": "IOTG","PSS_Partner_Solution_Lifecycle_Status_Nm__c": "","PSS_IOTG_Contacts__c": "abdevilliers@icc.com;abc@intel.com;asd@asd.com","PSS_External_Id__c": "00QW0000007bz9OMAQ","ArdiraSurvey__Target_Account__c": null,"ArdiraSurvey__Status__c": "In Progress",';
    //     request +='"ArdiraSurvey__Survey__c": "'+survey.ArdiraSurvey__Logical_Id__c+'",';
    //     request +='"ArdiraSurvey__Assigned_To_User__c": "'+u.id+'"}';
    //     //String JsonMsg=JSON.serialize(postData);
    //     //system.debug('request '+request);
    //     req.requestBody = Blob.valueof(request);
    //     RestContext.request = req; 
    //     RestContext.response= res;
        
    //     PSS_IOTGDataMigrationAPI.resultWrapper result=PSS_IOTGDataMigrationAPI.doPost();
    //     system.assertEquals(result.errorCode, '0');
    //     Test.stopTest();
    //     //System.debug(res.getBody());
    //     // System.debug(result);
        
    // }    
}