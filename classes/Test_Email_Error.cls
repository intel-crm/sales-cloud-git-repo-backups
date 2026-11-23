/****************************************************************************************************************************************
* Class Name  : PSS_SolutionResponse_TriggerHandler_Test 
* Version     : 1.0 
* Created Date: 06/17/2021
* Modification Log :
*
* Developer                                 Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Onyx                                06/17/2021           Test class for the class PSS_SolutionResponse_TriggerHandler
*****************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/

@isTest
public class Test_Email_Error {
    // @testSetup static void setup() {
    //   /*  //create impact path scoring criteria record
    //     PSS_Impact_Path_Scoring_Criteria__c impPathScore= new PSS_Impact_Path_Scoring_Criteria__c();
    //     impPathScore.Name='Intel Tech/ASP Profile';
    //     impPathScore.PSS_Weightage__c=20;
    //     impPathScore.PSS_Survey_Result_Field_Name__c='PSS_Solution_ASP_Profile_Value__c';
    //     insert impPathScore;
        
    //     //Create Solution with In Progress Status
    //     ArdiraSurvey__Survey_Result__c surResult = PSS_TestDataUtility.createSolution();
    //     surResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Draft';
    //     surResult.PSS_Proposal_Name_Txt__c='Test Proposal';
    //     insert surResult;
        
    //     //Create Solution with On Hold Status
    //     ArdiraSurvey__Survey_Result__c surResult2 = PSS_TestDataUtility.createSolution();
    //     surResult2.PSS_Proposal_Name_Txt__c='Test-Proposal-On-Hold';
    //     surResult2.PSS_Partner_Solution_Lifecycle_Status_Nm__c='On Hold';
    //     surResult2.PSS_Follow_up_Date_Dt__c= System.today()+1;
    //     surResult2.PSS_Total_Minutes_On_Hold__c=12;
    //     insert surResult2;
        
    //     //Create Solution with Update Required Status
    //     ArdiraSurvey__Survey_Result__c surResult3 = PSS_TestDataUtility.createSolution();
    //     surResult3.PSS_Proposal_Name_Txt__c='Test-Proposal-Update-Required';
    //     surResult3.PSS_Partner_Solution_Lifecycle_Status_Nm__c='Update Required';
    //     surResult3.PSS_Follow_up_Date_Dt__c= System.today()+1;
    //     surResult3.PSS_Total_Minutes_On_Hold__c=12;
    //     surResult3.PSS_Total_Minutes_Update_Required__c=12;
    //     insert surResult3;*/
    //     Profile salesRepPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
    //     User usr1 = PSS_TestDataUtility.createTestUser(salesRepPrf.Id,'testFirstName123','testLastName');
    //     insert usr1;
        
        
    //     ArdiraSurvey__Survey__c survey = New ArdiraSurvey__Survey__c();
    //     survey.Name = 'Test Survey';
    //     survey.ArdiraSurvey__CNav_Pagination__c = 'Section';
    //     survey.ArdiraSurvey__Status__c = 'Open';
    //     insert survey ;
       
        
    //     ArdiraSurvey__Survey_Result__c solutionresult = PSS_TestDataUtility.createSolution();
    //     solutionresult.PSS_Proposal_Name_Txt__c='TestSurveyResult1';
    //     solutionresult.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Admin Review';
    //     solutionresult.ArdiraSurvey__Status__c='Completed';
    //     solutionresult.PSS_Impact_Path_Score__c = 2;
    //     solutionresult.PSS_No_Of_Strategic_Attributes_Applicabl__c = 3;
    //     solutionresult.PSS_Solution_Category_Nm__c = 'IOTG';
    //     solutionresult.PSS_No_of_Geographies__c = 2;
    //     solutionresult.PSS_Solution_Revenue_Projection__c = 3;
    //     solutionresult.PSS_Solution_ASP_Profile_Value__c = 3;
    //     solutionresult.PSS_No_of_Different_Intel_Technologies__c = 2;
    //     solutionresult.PSS_Strategic_area_DCG__c = '2';
    //     solutionresult.ArdiraSurvey__Survey__c = survey.id;
    //     solutionresult.ArdiraSurvey__Assigned_To_User__c = usr1.Id;
    //     solutionresult.PSS_Solution_Submitter_UserId_Id__c=usr1.Id;
    //     solutionresult.PSS_Intel_Admin_Id__c=usr1.id;
    //     system.runAs(usr1){
    //         insert solutionresult;
    //     }
        
    //      PMP_TestDataUtility.createDocument();
    // }
    
  
    // @isTest
    // public static void testHandlerForApproved(){
    //     //try{
    //     test.startTest();
    //     ArdiraSurvey__Survey_Result__c surResult=[select id, name,PSS_Partner_Solution_Lifecycle_Status_Nm__c,PSS_Proposal_Name_Txt__c from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c='TestSurveyResult1' ];
    //     surResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Approved';
    //     update surResult;
    //    //System.assertEquals('Admin Review', surResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c, 'Status changed to Approved');
       
    //     System.assertEquals('Approved', surResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c, 'Status changed to Approved');
    //     test.stopTest();  
    //    /* }
    //     catch (Exception e){
    //         system.debug('e4::'+e.getStackTraceString());
    //     }*/
    // }
    
}