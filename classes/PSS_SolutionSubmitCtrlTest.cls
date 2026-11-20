/*IPA2.0: US-TWC729-7976*/
@isTest
public class PSS_SolutionSubmitCtrlTest {
    
//     @testSetup
//     public static void solutionSubmitCtrl(){
//         Profile salesRepPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
//         User usr1 = PSS_TestDataUtility.createTestUser(salesRepPrf.Id,'testFirstName123','testLastName');
//         insert usr1;
        
        
//         ArdiraSurvey__Survey__c survey = New ArdiraSurvey__Survey__c();
//         survey.Name = 'Test Survey';
//         survey.ArdiraSurvey__CNav_Pagination__c = 'Section';
//         survey.ArdiraSurvey__Status__c = 'Open';
//         insert survey ;
        
        
//         ArdiraSurvey__Survey_Result__c solutionresult = PSS_TestDataUtility.createSolution();
//         solutionresult.PSS_Proposal_Name_Txt__c='TestSurveyResult1';
//         solutionresult.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Admin Review';
//         solutionresult.ArdiraSurvey__Status__c='Completed';
//         solutionresult.PSS_Impact_Path_Score__c = 2;
//         solutionresult.PSS_No_Of_Strategic_Attributes_Applicabl__c = 3;
//         solutionresult.PSS_Solution_Category_Nm__c = 'IOTG';
//         solutionresult.PSS_No_of_Geographies__c = 2;
//         solutionresult.PSS_Solution_Revenue_Projection__c = 3;
//         solutionresult.PSS_Solution_ASP_Profile_Value__c = 3;
//         solutionresult.PSS_No_of_Different_Intel_Technologies__c = 2;
//         solutionresult.PSS_Strategic_area_DCG__c = '2';
//         solutionresult.ArdiraSurvey__Survey__c = survey.id;
//         solutionresult.ArdiraSurvey__Assigned_To_User__c = usr1.Id;
//         solutionresult.PSS_Solution_Submitter_UserId_Id__c=usr1.Id;
//         solutionresult.PSS_Intel_Admin_Id__c=usr1.id;
//         system.runAs(usr1){
//             insert solutionresult;
//         }
//     }
//     @isTest
//     public static void solutionTest(){
        
//         ArdiraSurvey__Survey_Result__c result=[Select id from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c='TestSurveyResult1' Limit 1];
//         PSS_SolutionSubmitCtrl ctrl=new PSS_SolutionSubmitCtrl();
//         Test.startTest();
//         //Setting Page reference params
//         Test.setCurrentPage(Page.PSS_SolutionSubmit);
//         ApexPages.currentPage().getParameters().put('recordId',result.Id);
        
//         PSS_SolutionSubmitCtrl.addContactBtnVisibility();
//         Test.stopTest();
//         system.assertNotEquals(result.id, null);
//     }
    
//     @isTest
//     public static void solutionWithoutRecordIdTest(){
//         Test.startTest();       
//         PSS_SolutionSubmitCtrl.addContactBtnVisibility();
        
//         Test.stopTest();
//     }
//     /* @isTest
// public static void solutionResultIdonSurveyLoadedTest(){
// String recordId='a7v2h00000008og';
// //PSS_SolutionSubmitCtrl ctrl=new PSS_SolutionSubmitCtrl();
// Test.startTest();
// PSS_SolutionSubmitCtrl.solutionResultIdonSurveyLoaded(recordId);
// Test.stopTest();
// }
// @isTest
// public static void solutionResultIdonSurveyLoadedTest2(){
// String recordId;
// //PSS_SolutionSubmitCtrl ctrl=new PSS_SolutionSubmitCtrl();
// Test.startTest();
// PSS_SolutionSubmitCtrl.solutionResultIdonSurveyLoaded(recordId);
// Test.stopTest();
// }*/
    
//     @isTest
//     public static void statusChangeOnSubmitTest(){
//         List<ArdiraSurvey__Survey_Result__c> result=[Select id from ArdiraSurvey__Survey_Result__c limit 10];
//         result.get(0).PSS_Programs_Applicable_Nm__c = 'MRS';
//         result.get(0).PSS_Strategic_Attributes_Nm__c = 'Workload Consolidation;Vision';  
//         update result.get(0);
//         String recordId=result.get(0).id;
//         //system.debug('recordId' + recordId);
//         Test.startTest();
//         PSS_SolutionSubmitCtrl.statusChangeOnSubmit(recordId,PSS_StaticConstants.NEXT);
//         PSS_SolutionSubmitCtrl.statusChangeOnSubmit(recordId,PSS_StaticConstants.QUIT);
//         Test.stopTest();
//         system.assertNotEquals(recordId, null);
//     }
    
//     @isTest
//     public static void strategicAttributeChangeTest(){
//         List<ArdiraSurvey__Survey_Result__c> result=[Select id from ArdiraSurvey__Survey_Result__c];
//         result.get(0).PSS_Strategic_Attributes_Nm__c = 'Workload Consolidation;Vision';  
//         update result.get(0);
//         String recordId=result.get(0).id;
//         Test.startTest();
//         PSS_SolutionSubmitCtrl.statusChangeOnSubmit(recordId,PSS_StaticConstants.NEXT);
//         PSS_SolutionSubmitCtrl.statusChangeOnSubmit(recordId,PSS_StaticConstants.QUIT);
        
//         Test.stopTest(); 
//     }
    
//     @isTest
//     public static void getSolutionDataTest(){
//         List<ArdiraSurvey__Survey_Result__c> result=[Select id from ArdiraSurvey__Survey_Result__c limit 10];
//         update result.get(0);
//         String recordId=result.get(0).id;
//         Test.startTest();
//         PSS_SolutionSubmitCtrl.getSolutionData(recordId);
//         Test.stopTest();
//         system.assertNotEquals(recordId, null);
//     }
//     @isTest
//     public static void statusChangeOnSubmitAuraTest(){
//         List<ArdiraSurvey__Survey_Result__c> result=[Select id from ArdiraSurvey__Survey_Result__c limit 10];
//          result.get(0).PSS_Programs_Applicable_Nm__c = 'MRS';
//         result.get(0).PSS_Strategic_Attributes_Nm__c = 'Workload Consolidation;Vision';  
        
//         update result.get(0);
//         String recordId=result.get(0).id;
//         //system.debug('recordId' + recordId);
//         Test.startTest();
//         PSS_SolutionSubmitCtrl.statusChangeOnSubmitAura(recordId,PSS_StaticConstants.NEXT);
//         PSS_SolutionSubmitCtrl.statusChangeOnSubmitAura(recordId,PSS_StaticConstants.QUIT);
//         result.get(0).PSS_Programs_Applicable_Nm__c = '';
        

//         update result.get(0);
//         PSS_SolutionSubmitCtrl.statusChangeOnSubmitAura(recordId,PSS_StaticConstants.NEXT);
//         PSS_SolutionSubmitCtrl.statusChangeOnSubmitAura(recordId,PSS_StaticConstants.QUIT);
        
//         Test.stopTest();
//         system.assertNotEquals(recordId, null);
//     }
//     @isTest
//     public static void getSolutionDataAuraTest(){
//         List<ArdiraSurvey__Survey_Result__c> result=[Select id from ArdiraSurvey__Survey_Result__c limit 10];
//         result.get(0).PSS_Partner_Solution_Lifecycle_Status_Nm__c = PSS_StaticConstants.SOLUTION_UPDATE_REQUIRED_STATUS;
//         update result.get(0);
//         String recordId=result.get(0).id;
//         Test.startTest();
//         PSS_SolutionSubmitCtrl.getSolutionDataAura(recordId);
//         Test.stopTest();
        
//         system.assertNotEquals(recordId, null);
//     }
}