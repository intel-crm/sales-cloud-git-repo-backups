/**************************************************************************************
Apex Class Name : PSS_SolutionOPIDRollup_Test
Version     : 1.0 
Created Date: 26th July, 2021
Description : Rollup Solution to OPID when OPID/Solution is created/updated/deleted  
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Onyx Team(Infosys)                  27/07/2021               Original Version
*************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public class PSS_SolutionOPIDRollup_Test {

//     @testSetup
//     static void setup(){
//     User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator'  AND isActive=true Limit 1];
//         UserRole role = [Select id from UserRole where DeveloperName = 'Admin' limit 1]; 
//         adminUser.userRoleId = role.id;
//         update adminUser;
//         System.runAs(adminUser){
//         Profile salesRepPrf = [select id, name from Profile where name = 'Partner' Limit 1];
//         Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
//         UserRole portalRole = [Select Id,Name,DeveloperName From UserRole Where DeveloperName = 'Admin' Limit 1];
//         Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
//         Id intelAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
//         User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
//         Test.startTest();
//         User partnerOwner = PSS_TestDataUtility.partnerAccountOwner();
//         System.runAs ( thisUser ) {
//             insert partnerOwner;
//         }

//         Account partnerAccount = PSS_TestDataUtility.createPartnerAccount('TestPartnerAccount2',devRecordTypeId,partnerOwner.Id);
//         System.runAs ( thisUser ) {
//             insert partnerAccount;
//         }
      


//         Account intelAccount1 = PMP_TestDataUtility.createIntelAccount('TestPartnerAccount3',intelAccountRecordTypeId,true);
//         Account intelAccount2 = PMP_TestDataUtility.createIntelAccount('TestPartnerAccount4',intelAccountRecordTypeId,true);
        
//         List<Contact> conList = new List<Contact>();
//         Contact contact1 = PSS_TestDataUtility.createPartnerContact('Test1','test12345@intel.com',intelAccount1.Id);
//         conList.add(contact1);
        
//         Contact contact2 = PSS_TestDataUtility.createPartnerContact('Test2','test123@intel.com',partnerAccount.Id);
//         conList.add(contact2);
//         System.runAs ( thisUser ) {
//             insert conList;
//         }

//         List<User> userList = new List<User>();
//          Profile partnerProfile = [select id, name from Profile where name = 'Partner' Limit 1];
//          UserRole partnerRole = [Select Id From UserRole Where PortalType = 'Partner' Limit 1];

//        // Profile portalProfile = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' Limit 1];

        
//        String orgId = UserInfo.getOrganizationId();
//        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
//        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
//        String uniqueName = orgId + dateString + randomInt;

//         User usr1 = new User();
//         usr1.Username = uniqueName + '@test' + orgId + '.org';
//         usr1.ContactId = contact1.Id;
//         usr1.ProfileId = partnerProfile.Id;
//         usr1.Alias = 'gM1235';
//         usr1.Email = 'test12345@intel.com';
//         usr1.EmailEncodingKey = 'UTF-8';
//         usr1.LastName = 'McTesty';
//         usr1.CommunityNickname = 'test123456';
//         usr1.TimeZoneSidKey = 'America/Los_Angeles';
//         usr1.LocaleSidKey = 'en_US';
//         usr1.LanguageLocaleKey = 'en_US';
//         //usr1.UserRoleId = partnerRole.id;

//         usr1.contact = contact1;
//         userList.add(usr1);
        
//         System.runAs ( thisUser ) {
//             insert userList;
//         }

//         List<Core_Account_Group_Member__c> accgrp = new List<Core_Account_Group_Member__c>();
//         Core_Account_Group_Member__c accGroupMem = new Core_Account_Group_Member__c();
//         accGroupMem.Core_Partner_Account_Id__c =partnerAccount.Id;
//         accGroupMem.Core_Intel_Account_Id__c =intelAccount1.Id;
//         insert accGroupMem;

//         Core_Account_Group_Member__c accGroupMem2 = new Core_Account_Group_Member__c();
//         accGroupMem2.Core_Partner_Account_Id__c =partnerAccount.Id;
//         accGroupMem2.Core_Intel_Account_Id__c =intelAccount2.Id;
//         insert accGroupMem2;

//         List<PMP_Company__c> pmpCpmpany = new List<PMP_Company__c>();

//         PMP_Company__c companyInfo1 = PSS_TestDataUtility.createCompany('intelCompany1',partnerAccount.Id,PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED);
//         companyInfo1.PMP_Benefit_Update_Ind__c = false;
//         companyInfo1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        
//         pmpCpmpany.add(companyInfo1);
//         PMP_Company__c companyInfo3 = PSS_TestDataUtility.createCompany('intelCompany2',intelAccount1.Id,'Solutions Marketplace Basic Profile');
        
//         pmpCpmpany.add(companyInfo3);
//         insert pmpCpmpany;
        
//         List<PMP_OPID_MPI_Rel__c> opidMPIList = new List<PMP_OPID_MPI_Rel__c>();
//         PMP_OPID_MPI_Rel__c opidMpi= new PMP_OPID_MPI_Rel__c();
//         opidMpi.Is_Active__c=True;
//         opidMpi.PMP_One_Partner_ID__c = partnerAccount.id;
//         opidMpi.PMP_Marketing_Profile_Id__c =companyInfo1.id;
//         opidMPIList.add(opidMpi);
        
//         PMP_OPID_MPI_Rel__c opidMpi1= new PMP_OPID_MPI_Rel__c();
//         opidMpi1.Is_Active__c=True;
//         opidMpi1.PMP_One_Partner_ID__c = intelAccount1.id;
//         opidMpi1.PMP_Marketing_Profile_Id__c =companyInfo3.id;
//         opidMPIList.add(opidMpi1);
//         insert opidMPIList;

//         PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering1','Public Content', 
//                                                                            'TestDuplicate',companyInfo1.Id, true,'Draft','');  
        
//         ArdiraSurvey__Survey__c survey = PSS_TestDataUtility.createSurvey();
//         insert survey;
        
//         ArdiraSurvey__Survey_Workflow_Stage__c workStage1 = New ArdiraSurvey__Survey_Workflow_Stage__c();
//         workStage1.ArdiraSurvey__Survey__c = survey.Id;
        
//         workStage1.ArdiraSurvey__Rank__c = 1;
//         workStage1.Name = PSS_StaticConstants.DATA_COLLECTION;
        
//         insert workStage1;

//         List<ArdiraSurvey__Survey_Result__c> surveyResultList = new List<ArdiraSurvey__Survey_Result__c>();
//         ArdiraSurvey__Survey_Result__c surveyResult1 = PSS_TestDataUtility.createArdiraSolution(survey.Id,companyInfo1.Id,partnerAccount.Id);
//         surveyResult1.ArdiraSurvey__Assigned_To_Contact__c=contact1.id;
//         surveyResultList.add(surveyResult1);
            
//         system.debug('*'+surveyResult1.Id);
        
//        /* ArdiraSurvey__Survey_Result__c surveyResult3 = PSS_TestDataUtility.createArdiraSolution(survey.Id,companyInfo3.Id,intelAccount1.Id);
//         surveyResult3.ArdiraSurvey__Assigned_To_Contact__c = contact2.Id;
//         surveyResultList.add(surveyResult3);*/
//         insert surveyResultList;
         
//         List<ArdiraSurvey__Survey_Result__Share> shareResultList = new List<ArdiraSurvey__Survey_Result__Share>();
//         ArdiraSurvey__Survey_Result__Share sharedSolution = new ArdiraSurvey__Survey_Result__Share();
//         sharedSolution.ParentId = surveyResult1.Id;
//         sharedSolution.UserOrGroupId = usr1.id;
//         sharedSolution.AccessLevel ='edit';
//         sharedSolution.RowCause ='Manual';
//         shareResultList.add(sharedSolution);

//         insert shareResultList;
//         system.assertNotEquals(contact1.id, null);
//               Test.stopTest();
//         }
      
//     }
    
//     @isTest
//     static void removeOPIDTest(){
//         List<Core_Account_Group_Member__c> memberList=[Select Core_Partner_Account_Id__c,Core_Intel_Account_Id__c from Core_Account_Group_Member__c LIMIT 1];
//         Test.startTest();
//         PSS_SolutionOPIDRollup.removeOPIDFromSolutionOnDeletion(memberList);
//         Test.stopTest();
//         system.assertNotEquals(memberList, null);
//     }
    
//     @isTest
//     static void updateAccountOnSolutionTest(){
//         List<ArdiraSurvey__Survey_Result__c> surveyList =[Select Id,ArdiraSurvey__Assigned_To_Contact__c,PSS_Company_Id__c 
//                                                           from  ArdiraSurvey__Survey_Result__c limit 10];
//         List<PMP_OPID_MPI_Rel__c> opidMPIList =[select id,Name,PMP_One_Partner_ID__c,PMP_Marketing_Profile_Id__c from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__r.Name LIKE '%TestPartnerAccount%'];

//         Test.startTest();
//         PSS_SolutionOPIDRollup.updateAccountDetails(surveyList);
//         Test.stopTest();
//         system.assertNotEquals(surveyList, null);
//     }
    
//     @isTest
//     static void insertOPIDTest(){
//         List<Account> accountList=[Select id from Account where Name LIKE 'TestPartnerAccount%'];
//         List<PMP_OPID_MPI_Rel__c> opidMPIList =[select id,Name,PMP_One_Partner_ID__c,PMP_Marketing_Profile_Id__c from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__r.Name LIKE '%TestPartnerAccount%'];

//         //System.debug('accountList ::'+accountList);
//         List<Core_Account_Group_Member__c> newList=[Select Id,Core_Inactive_Ind__c,Core_Partner_Account_Id__c,
//                                                     Core_Intel_Account_Id__c 
//                                                     from Core_Account_Group_Member__c 
//                                                     where Core_Intel_Account_Id__c=:accountList.get(1).id];
//         Test.startTest();
//         PSS_SolutionOPIDRollup.populateOPIDOnSolution(newList,null,'insert');
//         Test.stopTest();
//         system.assertNotEquals(newList, null);
//     }
    
    
    
//    /* @isTest
//     static void updateOPIDTest2(){
//         List<Account> accountList=[Select id,name from Account where Name LIKE 'TestPartnerAccount%'];
//         List<PMP_OPID_MPI_Rel__c> opidMPIList =[select id,Name,PMP_One_Partner_ID__c,PMP_Marketing_Profile_Id__c from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__r.Name LIKE '%TestPartnerAccount%'];

//         List<Core_Account_Group_Member__c> oldList=[Select Id,Core_Inactive_Ind__c,Core_Partner_Account_Id__c,
//                                                     Core_Intel_Account_Id__c
//                                                     from Core_Account_Group_Member__c where Core_Intel_Account_Id__c=:accountList.get(1).id];
//         List<Core_Account_Group_Member__c> newList=[Select Id,Core_Inactive_Ind__c,Core_Partner_Account_Id__c,
//                                                     Core_Intel_Account_Id__c 
//                                                     from Core_Account_Group_Member__c where Core_Intel_Account_Id__c=:accountList.get(1).id];
//         newList[0].Core_Inactive_Ind__c = true;
        
//         Map<Id,Core_Account_Group_Member__c> oldMap = new Map<Id,Core_Account_Group_Member__c>();
//         oldMap.put(oldList[0].Id,oldList[0]);

//         Test.startTest();
//         update newList[0];
//         PSS_SolutionOPIDRollup.populateOPIDOnSolution(newList,oldMap,'update');
//         Test.stopTest();
//         system.assertNotEquals(oldList[0].Id, null);

//     }*/


    
//    /* @isTest
//     static void updateOPIDTest3(){
//         List<Account> accountList=[Select id,name from Account where Name LIKE 'TestPartnerAccount%'];
//         List<PMP_Company__c> CmpList=[Select id,name,PMP_Account_Id__c from PMP_Company__c where Name LIKE 'intelCompany1%'];
//         PMP_OPID_MPI_Rel__c opidMPIList =[select id,Name,PMP_One_Partner_ID__c,PMP_Marketing_Profile_Id__c from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__r.Name LIKE '%TestPartnerAccount2%' LIMIT 1];
//         Map<id,PMP_OPID_MPI_Rel__c> oldMPIOPIDMap = new Map<id,PMP_OPID_MPI_Rel__c>();
                
        
//        List<ArdiraSurvey__Survey_Result__c> surveyList =[Select Id,ArdiraSurvey__Assigned_To_Contact__c,PSS_Company_Id__c 
//                                                           from  ArdiraSurvey__Survey_Result__c];
        
        
//         surveyList[0].PSS_Company_Id__c = CmpList[0].id;
//         surveyList[0].PSS_OPID_Account_Id__c = CmpList[0].PMP_Account_Id__c;
        
//         update surveyList[0];
      
        
//         List<PMP_OPID_MPI_Rel__c> newOpidList = new List<PMP_OPID_MPI_Rel__c>();*/
        
//        /* PMP_OPID_MPI_Rel__c oldMpi= new PMP_OPID_MPI_Rel__c();
//         opidMPIList.Is_Active__c = True;
//         oldMpi.PMP_Marketing_Profile_Id__c=CmpList[0].id;
//         oldMpi.PMP_One_Partner_ID__c =accountList[0].id;
//        // insert oldMpi;*/
        
//         /*opidMPIList.Is_Active__c = False;
//         update opidMPIList;

//         oldMPIOPIDMap.put(opidMPIList.id,opidMPIList);
        
//         List<Core_Account_Group_Member__c> oldList=[Select Id,Core_Inactive_Ind__c,Core_Partner_Account_Id__c,
//                                                     Core_Intel_Account_Id__c
//                                                     from Core_Account_Group_Member__c 
//                                                     where Core_Intel_Account_Id__c=:accountList.get(1).id];
//         List<Core_Account_Group_Member__c> newList=[Select Id,Core_Inactive_Ind__c,Core_Partner_Account_Id__c,
//                                                     Core_Intel_Account_Id__c 
//                                                     from Core_Account_Group_Member__c 
//                                                     where Core_Intel_Account_Id__c=:accountList.get(1).id];

//         Map<Id,Core_Account_Group_Member__c> oldMap = new Map<Id,Core_Account_Group_Member__c>();
//         oldMap.put(oldList[0].Id,oldList[0]);
//         Test.startTest();
        
//         opidMPIList.Is_Active__c = False;
//         Update opidMPIList;
//          newOpidList.add(opidMPIList);
//         system.assertNotEquals(opidMPIList.id, null);
        
//         PSS_SolutionOPIDRollup.populateOPIDOnSolution(newList,oldMap,'update');
//         PSS_SolutionOPIDRollup.populateMPIOnSolution(CmpList);
//         PSS_SolutionOPIDRollup.populateMPIOPIDOnSolution(newOpidList,oldMPIOPIDMap,false,true);

//         Test.stopTest();
        
//     }*/
    
//      @isTest
//     static void updateOPIDTest4(){
//         List<Account> accountList=[Select id,name from Account where Name LIKE 'TestPartnerAccount%'];
//         List<PMP_Company__c> CmpList=[Select id,name,PMP_Company_Lifecycle_Status_Nm__c,PMP_Benefit_Update_Ind__c,PMP_Account_Id__c from PMP_Company__c where Name LIKE 'intelCompany1%'];
//         List<PMP_OPID_MPI_Rel__c> opidMPIList =[select id,Name,Is_Active__c,PMP_One_Partner_ID__c,PMP_Marketing_Profile_Id__c from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__r.Name LIKE '%TestPartnerAccount%'];

//        /* Map<id,PMP_OPID_MPI_Rel__c> oldMPIOPIDMap = new Map<id,PMP_OPID_MPI_Rel__c>();
//         oldMPIOPIDMap.put(opidMPIList[0].id,opidMPIList[0]);
        
//         List<PMP_OPID_MPI_Rel__c> newOpidList = new List<PMP_OPID_MPI_Rel__c>();
//         opidMPIList[0].Is_Active__c = false;
//         update opidMPIList[0];
//         newOpidList.add(opidMPIList[0]);*/

//         CmpList[0].PMP_Benefit_Update_Ind__c = true;
//         update CmpList[0];
        
//         Map<id,PMP_Company__c> oldmap = new Map<id,PMP_Company__c>();
//         oldmap.put(CmpList[0].id,CmpList[0]);
        
//         CmpList[0].PMP_Benefit_Update_Ind__c = false;
//         update CmpList[0];
        
//         List<PMP_Company__c> newList = new List<PMP_Company__c>();
//         newList.add(CmpList[0]);
        
        
        
//        List<ArdiraSurvey__Survey_Result__c> surveyList =[Select Id,ArdiraSurvey__Assigned_To_Contact__c,PSS_Company_Id__c 
//                                                           from  ArdiraSurvey__Survey_Result__c limit 10];
        
//         surveyList[0].PSS_Company_Id__c = CmpList[0].id;
//         surveyList[0].PSS_OPID_Account_Id__c = CmpList[0].PMP_Account_Id__c;
        
//         update surveyList[0];

//         Test.startTest();
//         PSS_SolutionOPIDRollup.updateMPIOnSlution(newList,oldmap);
//        // PSS_SolutionOPIDRollup.populateMPIOPIDOnSolution(newOpidList,oldMPIOPIDMap,false,true);

//         Test.stopTest();
//         system.assertNotEquals(surveyList[0], null);
//     }
    
//       @isTest
//     static void updateOPIDTest5(){
//         List<Account> accountList=[Select id,name from Account where Name LIKE 'TestPartnerAccount%'];
//         List<PMP_Company__c> CmpList=[Select id,name,PMP_Company_Lifecycle_Status_Nm__c,PMP_Benefit_Update_Ind__c,PMP_Account_Id__c from PMP_Company__c where Name LIKE 'intelCompany1%'];
//         //CmpList[0].PMP_Benefit_Update_Ind__c = true;
//        // update CmpList[0];
//        List<PMP_OPID_MPI_Rel__c> opidMPIList =[select id,Name,Is_Active__c,PMP_One_Partner_ID__c,PMP_Marketing_Profile_Id__c from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__r.Name LIKE '%TestPartnerAccount2%'];
        
//         Map<id,PMP_OPID_MPI_Rel__c> oldMPIOPIDMap = new Map<id,PMP_OPID_MPI_Rel__c>();
     
        
//         Map<id,PMP_Company__c> oldmap = new Map<id,PMP_Company__c>();
//         oldmap.put(CmpList[0].id,CmpList[0]);
        
//         CmpList[0].PMP_Benefit_Update_Ind__c = true;
//         update CmpList[0];
        
//         List<PMP_Company__c> newList = new List<PMP_Company__c>();
//         newList.add(CmpList[0]);
        
        
        
//        List<ArdiraSurvey__Survey_Result__c> surveyList =[Select Id,ArdiraSurvey__Assigned_To_Contact__c,PSS_Company_Id__c 
//                                                           from  ArdiraSurvey__Survey_Result__c limit 10];
        
//         surveyList[0].PSS_Company_Id__c = CmpList[0].id;
//         surveyList[0].PSS_OPID_Account_Id__c = CmpList[0].PMP_Account_Id__c;
        
//         update surveyList[0];

//         Test.startTest();
//         PSS_SolutionOPIDRollup.updateMPIOnSlution(newList,oldmap);
//         PSS_SolutionOPIDRollup.populateMPIOPIDOnSolution(opidMPIList,null,true,false);
//         Test.stopTest();
//         system.assertNotEquals(surveyList[0], null);
//     }
    
//       @isTest
//     static void updateOPIDMpiTest1(){
//         //List<Account> accountList=[Select id,name from Account where Name = 'TestPartnerAccount'];
//         List<PMP_Company__c> CmpList=[Select id,name,PMP_Company_Lifecycle_Status_Nm__c,PMP_Benefit_Update_Ind__c,PMP_Account_Id__c from PMP_Company__c where Name = 'intelCompany1'];
//         //CmpList[0].PMP_Benefit_Update_Ind__c = true;
//        // update CmpList[0];
//        List<PMP_OPID_MPI_Rel__c> opidMPIqueyList =[select id,Name,Is_Active__c,PMP_One_Partner_ID__c,PMP_Marketing_Profile_Id__c from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__r.Name = 'TestPartnerAccount2' limit 1];
//        List<PMP_OPID_MPI_Rel__c> NewopidMPIqueyList =[select id,Name,Is_Active__c,PMP_One_Partner_ID__c,PMP_Marketing_Profile_Id__c from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__r.Name = 'TestPartnerAccount2' limit 1]; 
//         opidMPIqueyList[0].Is_Active__c = false;
//         Map<id,PMP_OPID_MPI_Rel__c> oldMPIOPIDMap = new Map<id,PMP_OPID_MPI_Rel__c>();
//         oldMPIOPIDMap.put(opidMPIqueyList[0].id,opidMPIqueyList[0]);
        
        
        
//        List<ArdiraSurvey__Survey_Result__c> surveyList =[Select Id,ArdiraSurvey__Assigned_To_Contact__c,PSS_Company_Id__c 
//                                                           from  ArdiraSurvey__Survey_Result__c limit 10];
        
//         surveyList[0].PSS_Company_Id__c = CmpList[0].id;
//         surveyList[0].PSS_OPID_Account_Id__c = CmpList[0].PMP_Account_Id__c;
        
//         update surveyList[0];
//         //List<PMP_OPID_MPI_Rel__c> newOpidMPIList = new List<PMP_OPID_MPI_Rel__c>();

//         Test.startTest();
//        /// opidMPIqueyList[0].Is_Active__c = False;
//         ///opidMPIqueyList[0].id= opidMPIqueyList[0].id;
//        // opidMPIqueyList[0].PMP_One_Partner_ID__c =opidMPIqueyList[0].PMP_One_Partner_ID__c;
//         ///newOpidMPIList.add(opidMPIqueyList[0]);
//         ///update newOpidMPIList;
//         PSS_SolutionOPIDRollup.populateMPIOPIDOnSolution(NewopidMPIqueyList,oldMPIOPIDMap,False,True);
//         Test.stopTest();
//         system.assertNotEquals(opidMPIqueyList[0].id, null);
//     }
    
//     @isTest
//     public static void updateMPIOPIDOnSolution_Test(){
//         Account acc = [select Id,name from Account where Name = 'TestPartnerAccount2'];
//         Set<Id> accid = new Set<Id>();
//         accid.add(acc.Id);
//         PSS_SolutionOPIDRollup.updateMPIOPIDOnSolution(accid);
//         system.assertEquals('TestPartnerAccount2', acc.Name);
//     }

}