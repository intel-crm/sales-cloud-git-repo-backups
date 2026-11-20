/****************************************************************************************************************************************
* Class Name  : PSS_SolutionResultTriggerHelper_Test
* Version     : 1.0 
* Created Date: 16-02-2021
* Modification Log :
*
* Developer      Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Shahrukh     16/02/2021                   Test class of PSS_SolutionResultTriggerHelper
*****************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public class PSS_SolutionResultTriggerHelper_Test{

//    @testSetup static void setup() {
//         Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
//         Account acc2 = PMP_TestDataUtility.createIntelAccount('TestAccount2', PMP_TestDataUtility.intel_Account_Record_Type, true);
//         acc2.Core_IPA_One_Partner_Id__c = string.valueOf(acc1.id);
//         update acc2;
        
//         Contact con1 = PMP_TestDataUtility.createContact(acc2.id,true);
        
//         PMP_TestDataUtility.createDocument();
      
//     }
    
//     @isTest
//     public static void convertSolutionToOfferingTest(){
        
//         Account acc = [select id,name,Core_IPA_One_Partner_Id__c from account where name='TestAccount2' limit 1];
        
//         contact con = [select id,name,Account.Core_IPA_One_Partner_Id__c,accountid from contact where accountid=:acc.id limit 1];
        
//         String orgId = UserInfo.getOrganizationId();
//         String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
//         Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
//         String uniqueName = orgId + dateString + randomInt;
        
//         //Create portal account owner
//         UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
//         Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
//         User portalAccountOwner1 = new User(
//             UserRoleId = portalRole.Id,
//             ProfileId = profile1.Id,
//             Username = uniqueName + '@test' + orgId + '.org',
//             Alias = 'batman',
//             Email='bruce.wayne@intel.com',
//             EmailEncodingKey='UTF-8',
//             Firstname='Bruce',
//             Lastname='Wayne',
//             LanguageLocaleKey='en_US',
//             LocaleSidKey='en_US',
//             TimeZoneSidKey='America/Chicago'
//         );
//         Database.insert(portalAccountOwner1);
        
//         system.runAs(portalAccountOwner1){      
//         //Create account
//             Account portalAccount1 = PMP_TestDataUtility.createIntelAccount('TestAccount3', PMP_TestDataUtility.intel_Account_Record_Type, false);
//             portalAccount1.OwnerId = portalAccountOwner1.Id;
//             portalAccount1.Core_IPA_One_Partner_Id__c = string.valueOf(acc.id);
//             Database.insert(portalAccount1);
                
//             //Create contact
//             Contact contact1 = new Contact(
//                 FirstName = 'Test',
//                     Lastname = 'McTesty',
//                 AccountId = portalAccount1.Id,
//                     Email = System.now().millisecond() + 'test@test.com'
//             );
//             Database.insert(contact1);
          
//             //Create user
//             Profile portalProfile = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' Limit 1];
            
            
            
//             User user1 = new User(
//                 Username = uniqueName + '@test1' + orgId + '.org',
//                 ContactId = contact1.Id,
//                 ProfileId = portalProfile.Id,
//                 Alias = 'test123',
//                 Email = 'test12345@intel.com',
//                 EmailEncodingKey = 'UTF-8',
//                 LastName = 'McTesty',
//                 CommunityNickname = 'test12345',
//                 TimeZoneSidKey = 'America/Los_Angeles',
//                 LocaleSidKey = 'en_US',
//                 LanguageLocaleKey = 'en_US'
//             );
//             user1.contact = contact1;
//             Database.insert(user1);
        
//             List<user> userList = new List<user>();
//             userList.add(user1);
            
            
//             List<FormulaRecalcResult> results = Formula.recalculateFormulas(userList);


            
//             PMP_Company__c newCompany = PMP_TestDataUtility.createCompanyInformation('TestCompany',portalAccount1.Id,false);
//             newCompany.PMP_Partner_Benefit_Type__c  = 'Solutions Marketplace Enhanced';
//             newCompany.PMP_One_Partner_ID__c = acc.Id;
//             newCompany.PMP_Benefit_Update_Ind__c = false;
//             insert newCompany;
            

//             ArdiraSurvey__Survey_Result__c surResult = PSS_TestDataUtility.createSolution();
//             surResult.PSS_Proposal_Name_Txt__c = 'test solution';
//             surResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Draft';
//             surResult.ArdiraSurvey__Assigned_To_User__c  = user1.Id;
//             surResult.createdByID = user1.Id;
//             surResult.PSS_Intel_Admin_Id__c=user1.id;
//             surResult.PSS_Company_Id__c = newCompany.Id;
//             surResult.PSS_Solution_Submitter_UserId_Id__c=user1.id;
            
//             insert surResult;
            
//             Map<Id,ArdiraSurvey__Survey_Result__c> oldMap=new Map<Id,ArdiraSurvey__Survey_Result__c>();
//             oldMap.put(surResult.id,surResult);
            
//            /* ArdiraSurvey__Survey_Result__c surResult2 = PSS_TestDataUtility.createSolution();
//             surResult2.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Admin Review';
//             surResult2.ArdiraSurvey__Assigned_To_User__c  = user1.Id;
//             surResult2.createdByID = user1.Id;
//             surResult2.PSS_Intel_Admin_Id__c=user1.id;
//             insert surResult2;*/
            
//             system.assertEquals(surResult.PSS_Company_Id__c,newCompany.Id);
//             PSS_SolutionResponse_TriggerHandler.isRecursive = false;
//             List<ArdiraSurvey__Survey_Result__c> surResList= new List<ArdiraSurvey__Survey_Result__c>();
//             ArdiraSurvey__Survey_Result__c surResult1 = new ArdiraSurvey__Survey_Result__c();
//             surResult1 = [Select Id,CreatedById,PSS_Partner_Solution_Lifecycle_Status_Nm__c,PSS_Last_Modified_Partner_Id__c,ArdiraSurvey__Assignee_Type__c,PSS_Proposal_Name_Txt__c,PSS_Convert_Solution_Ind__c,PSS_Intel_Admin_Id__c,PSS_Partner_Name__c,PSS_Solution_Submitter_UserId_Id__c from  ArdiraSurvey__Survey_Result__c WHERE PSS_Proposal_Name_Txt__c = 'test solution'];
//             //system.debug('surResult1 Id :::::: '+surResult1.Id);
//             //system.debug('surResult1 Proposal Name :::::: '+surResult1.PSS_Proposal_Name_Txt__c);
            
//             //surResult2.id=surResult.id;
//           //  oldMap.put(surResult2.id,surResult2);
            
//             surResult1.ArdiraSurvey__Assignee_Type__c = 'User';
//             surResult1.PSS_Last_Modified_Partner_Id__c = user1.id;
//             surResult1.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Admin Review';
//             update surResult1;
//             surResList.add(surResult1);
            
//             Test.startTest();
//             PSS_SolutionResultTriggerHelper.convertSolutionToOffering(surResList,oldMap);
            
//             Test.stopTest();
            
            
//            // system.AssertEquals(surResult1.PSS_Convert_Solution_Ind__c,false);
//       }  
        
//     }    
    
   
}