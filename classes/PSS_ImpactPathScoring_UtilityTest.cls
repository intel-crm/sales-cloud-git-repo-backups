/*****************************************************************************************************************************************************************
* Class Name  : PSS_ImpactPathScoring_UtilityTest

* Version     : 1.0 
* Modification Log :
*
* Developer                           Date                          Description
* ----------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team                          18-06-2021                    Test class of PSS_ImpactPathScoring_Utility apex class
******************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public class PSS_ImpactPathScoring_UtilityTest {
    
    // @testSetup
    // public static void calculateImpactPathScore(){
        
    //     Profile salesRepPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
    //     User usr1 = PSS_TestDataUtility.createTestUser(salesRepPrf.Id,'testFirstName123','testLastName');
    //     insert usr1;
        
    //     ArdiraSurvey__Survey__c survey = New ArdiraSurvey__Survey__c();
    //     survey.Name = 'Test Survey';
    //     survey.ArdiraSurvey__CNav_Pagination__c = 'Section';
    //     survey.ArdiraSurvey__Status__c = 'Open';
    //     // system.runAs(usr1){
    //     insert survey ;
    //     // }
        
        
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
        
        
    //     ArdiraSurvey__Survey_Result__c solutionresult1 = PSS_TestDataUtility.createSolution();
    //     solutionresult1.PSS_Proposal_Name_Txt__c='TestSurveyResult2';
    //     solutionresult1.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Admin Review';
    //     solutionresult.ArdiraSurvey__Status__c='Completed';
    //     solutionresult1.PSS_Impact_Path_Score__c = 2;
    //     solutionresult1.PSS_No_Of_Strategic_Attributes_Applicabl__c = 3;
    //     solutionresult1.PSS_Solution_Category_Nm__c = 'IOTG';
    //     solutionresult1.PSS_No_of_Geographies__c = 2;
    //     solutionresult1.PSS_Solution_Revenue_Projection__c = 3;
    //     solutionresult1.PSS_Solution_ASP_Profile_Value__c = 3;
    //     solutionresult1.PSS_No_of_Different_Intel_Technologies__c = 2;
    //     solutionresult1.PSS_Strategic_area_DCG__c = '2';
    //     solutionresult1.ArdiraSurvey__Survey__c = survey.id;
    //     solutionresult1.ArdiraSurvey__Assigned_To_User__c = usr1.Id;
    //     solutionresult1.PSS_Intel_Admin_Id__c=usr1.id;
    //     system.runAs(usr1){
    //         insert solutionresult1;
    //     }
        
        
    //     ArdiraSurvey__Question__c  question = New ArdiraSurvey__Question__c();
    //     question.ArdiraSurvey__C_Date_Correct_Answer_When__c= 'Answered';
    //     question.ArdiraSurvey__C_Polar_Correct_Answer_When__c = 'True';
    //     question.ArdiraSurvey__C_Radio_Display__c = 'Vertical Radio';
    //     question.ArdiraSurvey__C_Ranking_Correct_Answer_When__c = 'Correct Order';
    //     question.ArdiraSurvey__C_Text_Correct_Answer_When__c = 'Answered';
    //     question.ArdiraSurvey__C_Display_Image_Size__c = 'Small';
    //     question.ArdiraSurvey__Question__c = 'How do the solution’s edge hardware/gateways connect to the server and/or cloud? Select all that apply.';
    //     question.ArdiraSurvey__Date_Allowed_Dates__c = 'Any';
    //     question.ArdiraSurvey__C_Multiple_Choice_Display__c = 'Checkbox';
    //     question.ArdiraSurvey__C_Multiple_Choice_Scoring_option__c = 'Use Choice Score';
    //     question.ArdiraSurvey__C_Polar_Yes_No_Display__c = 'YesNo';
    //     question.ArdiraSurvey__Rating_Rating_Range__c = '3';
    //     question.ArdiraSurvey__C_Rating_Shape__c = 'Star';
    //     question.PSS_Question_Unique_Key_Txt__c = 'Current_customers';
    //     question.ArdiraSurvey__Survey__c = survey.id;
    //     system.runAs(usr1){
    //         insert question; 
    //     }
        
        
    //     ArdiraSurvey__Question__c  question1 = New ArdiraSurvey__Question__c();
    //     question1.ArdiraSurvey__C_Date_Correct_Answer_When__c= 'Answered';
    //     question1.ArdiraSurvey__C_Polar_Correct_Answer_When__c = 'True';
    //     question1.ArdiraSurvey__C_Radio_Display__c = 'Vertical Radio';
    //     question1.ArdiraSurvey__C_Ranking_Correct_Answer_When__c = 'Correct Order';
    //     question1.ArdiraSurvey__C_Text_Correct_Answer_When__c = 'Answered';
    //     question1.ArdiraSurvey__C_Display_Image_Size__c = 'Small';
    //     question1.ArdiraSurvey__Question__c = 'How do the solution’s edge hardware/gateways connect to the server and/or cloud? Select all that apply.';
    //     question1.ArdiraSurvey__Date_Allowed_Dates__c = 'Any';
    //     question1.ArdiraSurvey__C_Multiple_Choice_Display__c = 'Checkbox';
    //     question1.ArdiraSurvey__C_Multiple_Choice_Scoring_option__c = 'Use Choice Score';
    //     question1.ArdiraSurvey__C_Polar_Yes_No_Display__c = 'YesNo';
    //     question1.ArdiraSurvey__Rating_Rating_Range__c = '3';
    //     question1.ArdiraSurvey__C_Rating_Shape__c = 'Star';
    //     question1.PSS_Question_Unique_Key_Txt__c = 'Current_customers';
    //     question1.ArdiraSurvey__Survey__c = survey.id;
    //     system.runAs(usr1){
    //         insert question1;
    //     }
        
        
        
    //     ArdiraSurvey__Question_Result__c questionresult = New ArdiraSurvey__Question_Result__c();
    //     questionresult.ArdiraSurvey__Question__c = question.id;
    //     questionresult.ArdiraSurvey__Survey_Result__c = solutionresult.id;
    //     questionresult.ArdiraSurvey__Survey__c = survey.id;
    //     questionresult.ArdiraSurvey__Answered__c=true;
    //     questionresult.ArdiraSurvey__Answer_Text__c='5';
    //     system.runAs(usr1){
    //         insert questionresult;
    //     }
        
        
    //     ArdiraSurvey__Question_Result__c questionresult1 = New ArdiraSurvey__Question_Result__c();
    //     questionresult1.ArdiraSurvey__Question__c = question1.id;
    //     questionresult1.ArdiraSurvey__Survey_Result__c = solutionresult1.id;
    //     questionresult1.ArdiraSurvey__Survey__c = survey.id;
    //     questionresult1.ArdiraSurvey__Answered__c=true;
    //     questionresult1.ArdiraSurvey__Answer_Text__c='2-3';
    //     system.runAs(usr1){
    //         insert questionresult1; 
    //     }
        
        
        
    //     PSS_Impact_Path_Scoring_Criteria__c impactPath = new PSS_Impact_Path_Scoring_Criteria__c();
    //     impactPath.PSS_Ardira_Question__c = question.Id;
    //     impactPath.PSS_Is_Active__c = true;
    //     impactPath.PSS_Question_Unique_Key__c = 'Current_customers';
    //     impactPath.PSS_Solution_Category__c = 'IOTG';
    //     impactPath.PSS_Survey_Result_Field_Name__c = 'PSS_Strategic_area_DCG__c';
    //     impactPath.PSS_Weightage__c = 2;
    //     system.runAs(usr1){
    //         Insert impactPath; 
    //     }
        
        
    //     PSS_Impact_Path_Scoring_Criteria__c impactPath1 = new PSS_Impact_Path_Scoring_Criteria__c();
    //     impactPath1.PSS_Ardira_Question__c = question1.Id;
    //     impactPath1.PSS_Is_Active__c = true;
    //     impactPath1.PSS_Question_Unique_Key__c = 'Current_customers';
    //     impactPath1.PSS_Solution_Category__c = 'IOTG';
    //     impactPath1.PSS_Weightage__c = 2;
    //     system.runAs(usr1){
    //         Insert impactPath1;
    //     }
        
        
    //     PSS_Impact_Path_Scoring_Criteria__c impactPath2 = new PSS_Impact_Path_Scoring_Criteria__c();
    //     impactPath2.PSS_Ardira_Question__c = question1.Id;
    //     impactPath2.PSS_Is_Active__c = true;
    //     impactPath2.PSS_Question_Unique_Key__c = 'Current_customers';
    //     impactPath2.PSS_Solution_Category__c = 'IOTG';
    //     impactPath2.PSS_Weightage__c = 2;
    //     system.runAs(usr1){
    //         Insert impactPath2; 
    //     }
        
        
    //     PSS_Impact_Path_Scoring_Criteria__c impactPath3 = new PSS_Impact_Path_Scoring_Criteria__c();
    //     impactPath3.PSS_Ardira_Question__c = question1.Id;
    //     impactPath3.PSS_Is_Active__c = true;
    //     impactPath3.PSS_Question_Unique_Key__c = 'Current_customers';
    //     impactPath3.PSS_Solution_Category__c = 'IOTG';
    //     impactPath3.PSS_Weightage__c = 2;
    //     system.runAs(usr1){
    //         Insert impactPath3;
    //     }
        
        
        
    //     PSS_Solution_with_Impact_Path_Scoring__c solutionImpactPath = new PSS_Solution_with_Impact_Path_Scoring__c();
    //     solutionImpactPath.PSS_Ardira_Survey_Result__c = solutionresult.id;
    //     solutionImpactPath.PSS_Impact_Path_Scoring_Criteria__c = impactPath.Id;
    //     solutionImpactPath.PSS_Question_Impact_Path_Score__c = 2;
    //     system.runAs(usr1){
    //         insert solutionImpactPath; 
    //     }
        
        
    //     PSS_Solution_with_Impact_Path_Scoring__c solutionImpactPath2 = new PSS_Solution_with_Impact_Path_Scoring__c();
    //     solutionImpactPath2.PSS_Ardira_Survey_Result__c = solutionresult1.id;
    //     solutionImpactPath2.PSS_Impact_Path_Scoring_Criteria__c = impactPath1.Id;
    //     solutionImpactPath2.PSS_Question_Impact_Path_Score__c = 2;
    //     system.runAs(usr1){
    //         insert solutionImpactPath2; 
    //     }
        
        
    //     PSS_Solution_with_Impact_Path_Scoring__c solutionImpactPath3 = new PSS_Solution_with_Impact_Path_Scoring__c();
    //     solutionImpactPath3.PSS_Ardira_Survey_Result__c = solutionresult.id;
    //     solutionImpactPath3.PSS_Impact_Path_Scoring_Criteria__c = impactPath2.Id;
    //     solutionImpactPath3.PSS_Question_Impact_Path_Score__c = 2;
    //     system.runAs(usr1){
    //         insert solutionImpactPath3;
    //     }
        
        
    //     PSS_Solution_with_Impact_Path_Scoring__c solutionImpactPath4 = new PSS_Solution_with_Impact_Path_Scoring__c();
    //     solutionImpactPath4.PSS_Ardira_Survey_Result__c = solutionresult.id;
    //     solutionImpactPath4.PSS_Impact_Path_Scoring_Criteria__c = impactPath3.Id;
    //     solutionImpactPath4.PSS_Question_Impact_Path_Score__c = 2;
    //     system.runAs(usr1){
    //         insert solutionImpactPath4; 
    //     }
        
        
    //     PSS_Solution_with_Impact_Path_Scoring__c solutionImpactPath5 = new PSS_Solution_with_Impact_Path_Scoring__c();
    //     solutionImpactPath5.PSS_Ardira_Survey_Result__c = solutionresult.id;
    //     solutionImpactPath5.PSS_Impact_Path_Scoring_Criteria__c = impactPath3.Id;
    //     solutionImpactPath5.PSS_Question_Impact_Path_Score__c = 2;
    //     system.runAs(usr1){
    //         insert solutionImpactPath5;
    //     }
        
        
    //     PSS_Impact_Path_Scoring_Range__c scoringRange1 = new PSS_Impact_Path_Scoring_Range__c();
    //     scoringRange1.PSS_Impact_Path_Scoring_Criteria__c = impactPath.Id;
    //     scoringRange1.PSS_Logical_Operator__c = 'Equal to';
    //     scoringRange1.PSS_Response__c = '2';
    //     scoringRange1.PSS_Score_Value__c = 2;
    //     system.runAs(usr1){
    //         insert scoringRange1;
    //     }
        
        
    //     PSS_Impact_Path_Scoring_Range__c scoringRange3 = new PSS_Impact_Path_Scoring_Range__c();
    //     scoringRange3.PSS_Impact_Path_Scoring_Criteria__c = impactPath1.Id;
    //     scoringRange3.PSS_Logical_Operator__c = 'Range';
    //     scoringRange3.PSS_Response__c = '2-5';
    //     scoringRange3.PSS_Score_Value__c = 2;
    //     system.runAs(usr1){
    //         insert scoringRange3;
    //     }
        
        
    //     PSS_Impact_Path_Scoring_Range__c scoringRange = new PSS_Impact_Path_Scoring_Range__c();
    //     scoringRange.PSS_Impact_Path_Scoring_Criteria__c = impactPath2.Id;
    //     scoringRange.PSS_Logical_Operator__c = 'Greater than';
    //     scoringRange.PSS_Response__c = '2';
    //     scoringRange.PSS_Score_Value__c = 2;
    //     system.runAs(usr1){
    //         insert scoringRange;
    //     }
        
        
    //     PSS_Impact_Path_Scoring_Range__c scoringRange5 = new PSS_Impact_Path_Scoring_Range__c();
    //     scoringRange5.PSS_Impact_Path_Scoring_Criteria__c = impactPath3.Id;
    //     scoringRange5.PSS_Logical_Operator__c = 'Does not contain';
    //     scoringRange5.PSS_Response__c = '0';
    //     scoringRange5.PSS_Score_Value__c = 2;
    //     system.runAs(usr1){
    //         insert scoringRange5;
    //     }
        
        
    //     PSS_Impact_Path_Scoring_Range__c scoringRange4 = new PSS_Impact_Path_Scoring_Range__c();
    //     scoringRange4.PSS_Impact_Path_Scoring_Criteria__c = impactPath3.Id;
    //     scoringRange4.PSS_Logical_Operator__c = 'Contains';
    //     scoringRange4.PSS_Response__c = '2';
    //     scoringRange4.PSS_Score_Value__c = 2;
    //     system.runAs(usr1){
    //         insert scoringRange4;
    //     }
        
        
        
    //     PSS_Impact_Path_Scoring_Range__c scoringRange2 = new PSS_Impact_Path_Scoring_Range__c();
    //     scoringRange2.PSS_Impact_Path_Scoring_Criteria__c = impactPath.Id;
    //     scoringRange2.PSS_Logical_Operator__c = 'Lower than';
    //     scoringRange2.PSS_Response__c = '1';
    //     scoringRange2.PSS_Score_Value__c = 2;
        
    //     system.runAs(usr1){
    //         insert scoringRange2;
    //     }
        
        
        
    // }
    
    // public static testMethod void calculateImpactPathScoreTest(){
        
    //     list<ArdiraSurvey__Survey_Result__c> solutionList1 = [Select id,Name,ArdiraSurvey__Status__c,PSS_Programs_Applicable_Nm__c,
    //                                                           PSS_Partner_Solution_Lifecycle_Status_Nm__c,
    //                                                           PSS_Impact_Path_Score__c,PSS_No_Of_Strategic_Attributes_Applicabl__c,
    //                                                           PSS_Solution_Category_Nm__c,PSS_No_of_Geographies__c,
    //                                                           PSS_Solution_Revenue_Projection__c,PSS_Solution_ASP_Profile_Value__c,
    //                                                           PSS_No_of_Different_Intel_Technologies__c,PSS_Strategic_area_DCG__c,
    //                                                           (SELECT id, name,ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c,ArdiraSurvey__Answer_Text__c
    //                                                            FROM ArdiraSurvey__Question_Results__r limit 10),
    //                                                           (SELECT id, name,PSS_Impact_Path_Scoring_Criteria__c,PSS_Question_Impact_Path_Score__c,PSS_Impact_Path_Scoring_Criteria__r.PSS_Ardira_Question__c, 
    //                                                            PSS_Impact_Path_Scoring_Criteria__r.PSS_Question_Unique_Key__c,PSS_Impact_Path_Scoring_Criteria__r.PSS_Solution_Category__c,
    //                                                            PSS_Impact_Path_Scoring_Criteria__r.PSS_Survey_Result_Field_Name__c,PSS_Impact_Path_Scoring_Criteria__r.PSS_Weightage__c
    //                                                            FROM Solution_with_Impact_Path_Scorings__r limit 10)
    //                                                           from ArdiraSurvey__Survey_Result__c limit 10];
    //     Map<Id,ArdiraSurvey__Survey_Result__c> solutionResultMap = new Map<Id,ArdiraSurvey__Survey_Result__c>();
    //     For(ArdiraSurvey__Survey_Result__c result : solutionList1){
    //         solutionResultMap.put(result.Id,result);
    //     }
    //     Test.startTest();
    //     //solutionList.ArdiraSurvey__Status__c = 'Admin Review';
    //     //update solutionList;
    //     List<ArdiraSurvey__Survey_Result__c> resultList = PSS_ImpactPathScoring_Utility.calculateImpactPathScore(solutionResultMap);
    //     Test.stopTest();
        
    //     List<PSS_Impact_Path_Scoring_Range__c> scoringRangeList = [SELECT Id,PSS_Impact_Path_Scoring_Criteria__c,PSS_Logical_Operator__c,PSS_Response__c,PSS_Score_Value__c
    //                                                               FROM PSS_Impact_Path_Scoring_Range__c WHERE PSS_Logical_Operator__c = 'Contains' OR PSS_Logical_Operator__c = 'Lower than'];
        
        
    //     Decimal scoreValue = new PSS_ImpactPathScoring_Utility().getApplicableScore(0,scoringRangeList);
        
    //     PSS_Impact_Path_Scoring_Range__c temp = scoringRangeList[0];
    //     scoringRangeList[0] = scoringRangeList[1];
    //     scoringRangeList[0] = temp;
        
    //     Decimal scoreValue2 = new PSS_ImpactPathScoring_Utility().getApplicableScore(0,scoringRangeList);
    //     List<PSS_Solution_with_Impact_Path_Scoring__c> scoringRecordList = [Select id from PSS_Solution_with_Impact_Path_Scoring__c 
    //                                                                         where PSS_Question_Impact_Path_Score__c = 2 Limit 1];
        
    //     system.assertNotEquals(resultList.get(0).PSS_Impact_Path_Score__c, 0, 'record updated');
        
    // }
    
}