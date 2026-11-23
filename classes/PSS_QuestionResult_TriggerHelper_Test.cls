/*IPA2.0: US-TWC729-7976*/
@istest
public class PSS_QuestionResult_TriggerHelper_Test {
    
    // @testSetup static void setup() {
        
    //     User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator'  AND isActive=true Limit 1];
    //     UserRole role = [Select id from UserRole where DeveloperName = 'Admin' limit 1]; 
    //     adminUser.userRoleId = role.id;
    //     update adminUser;
        
        
        
    //     System.runAs(adminUser){
    //         //trigger switch custom setting
    //         Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c();
    //         cs.Name = 'PSS_QuestionResult_trigger';
    //         cs.Core_Active__c = true;
    //         cs.Core_Class_Name__c='PSS_QuestionResult_TriggerHandler';
    //         cs.Core_Description__c='PSS_QuestionResult_TriggerHandler';
    //         cs.Core_Object__c='ArdiraSurvey__Question_Result__c';
    //         cs.Core_Trigger_Events__c='After Insert, After Update';
    //         insert cs;
            
            
            
            
            
    //     }
    // }
    
    // @isTest static void testSolutionupdate() {
    //     List<ArdiraSurvey__Question_Result__c>  aqrlist = new List<ArdiraSurvey__Question_Result__c>();
        
    //     Account acc = PMP_TestDataUtility.createAccount('testAccount', PMP_TestDataUtility.intel_Account_Record_Type, true );
    //     Contact con = PMP_TestDataUtility.createContact(acc.Id, true);
        
    //    /* //trigger switch custom setting
    //         Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c();
    //         cs.Name = 'PSS_QuestionResult_trigger';
    //         cs.Core_Active__c = true;
    //         cs.Core_Class_Name__c='PSS_QuestionResult_TriggerHandler';
    //         cs.Core_Description__c='PSS_QuestionResult_TriggerHandler';
    //         cs.Core_Object__c='ArdiraSurvey__Question_Result__c';
    //         cs.Core_Trigger_Events__c='After Insert, After Update';
    //         insert cs;*/
        
    //     //Inserting Survey
    //     ArdiraSurvey__Survey__c survey = New ArdiraSurvey__Survey__c();
    //     survey.Name = 'Test Survey';
    //     survey.ArdiraSurvey__CNav_Pagination__c = 'Section';
    //     survey.ArdiraSurvey__Status__c = 'Open';
    //     insert survey ;
        
    //     List<ArdiraSurvey__Survey_Result__c> surveyResultList = New List<ArdiraSurvey__Survey_Result__c>();
    //     //Create Solution with Draft Status
    //     ArdiraSurvey__Survey_Result__c surResult = PSS_TestDataUtility.createSolution();
    //     surResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Draft';
    //     surResult.PSS_Proposal_Name_Txt__c='Test Proposal Draft';
    //     surResult.ArdiraSurvey__Survey__c = survey.id;
    //     surResult.ArdiraSurvey__Assigned_To_Contact__c = con.Id;
    //     //surveyResultList.add(surResult);
    //     insert surResult;
        
    //     List<ArdiraSurvey__Question__c> questionList = New List<ArdiraSurvey__Question__c>();
    //     ArdiraSurvey__Question__c   question2 = New ArdiraSurvey__Question__c();
    //     question2.ArdiraSurvey__C_Date_Correct_Answer_When__c= 'Answered';
    //     question2.ArdiraSurvey__C_Polar_Correct_Answer_When__c = 'True';
    //     question2.ArdiraSurvey__C_Radio_Display__c = 'Vertical Radio';
    //     question2.ArdiraSurvey__C_Ranking_Correct_Answer_When__c = 'Correct Order';
    //     question2.ArdiraSurvey__C_Text_Correct_Answer_When__c = 'Answered';
    //     question2.ArdiraSurvey__C_Display_Image_Size__c = 'Small';
    //     question2.ArdiraSurvey__Question__c = 'Select Industry';
    //     question2.ArdiraSurvey__Date_Allowed_Dates__c = 'Any';
    //     question2.ArdiraSurvey__C_Multiple_Choice_Display__c = 'Checkbox';
    //     question2.ArdiraSurvey__C_Multiple_Choice_Scoring_option__c = 'Use Choice Score';
    //     question2.ArdiraSurvey__C_Polar_Yes_No_Display__c = 'YesNo';
    //     question2.ArdiraSurvey__Rating_Rating_Range__c = '3';
    //     question2.ArdiraSurvey__C_Rating_Shape__c = 'Star';
    //     question2.PSS_Question_Unique_Key_Txt__c ='IOTG_PrimaryIndustry';
    //     question2.ArdiraSurvey__Survey__c = survey.id;
    //     questionList.add(question2);
        
        
    //     ArdiraSurvey__Question__c   question3 = New ArdiraSurvey__Question__c();
    //     question3.ArdiraSurvey__C_Date_Correct_Answer_When__c= 'Answered';
    //     question3.ArdiraSurvey__C_Polar_Correct_Answer_When__c = 'True';
    //     question3.ArdiraSurvey__C_Radio_Display__c = 'Vertical Radio';
    //     question3.ArdiraSurvey__C_Ranking_Correct_Answer_When__c = 'Correct Order';
    //     question3.ArdiraSurvey__C_Text_Correct_Answer_When__c = 'Answered';
    //     question3.ArdiraSurvey__C_Display_Image_Size__c = 'Small';
    //     question3.ArdiraSurvey__Question__c = 'Enter the solution name';
    //     question3.ArdiraSurvey__Date_Allowed_Dates__c = 'Any';
    //     question3.ArdiraSurvey__C_Multiple_Choice_Display__c = 'Checkbox';
    //     question3.ArdiraSurvey__C_Multiple_Choice_Scoring_option__c = 'Use Choice Score';
    //     question3.ArdiraSurvey__C_Polar_Yes_No_Display__c = 'YesNo';
    //     question3.ArdiraSurvey__Rating_Rating_Range__c = '3';
    //     question3.ArdiraSurvey__C_Rating_Shape__c = 'Star';
    //     question3.PSS_Offering_Nm__c = 'PMP_Partner_Offering_Nm__c';
    //     question3.ArdiraSurvey__Survey__c = survey.id;
    //     questionList.add(question3);
    //     insert questionList;
        
        
    //     ArdiraSurvey__Question_Result__c questionRes2 = New ArdiraSurvey__Question_Result__c(ArdiraSurvey__Question__c = question2.id, ArdiraSurvey__Survey_Result__c = surResult.id, ArdiraSurvey__Survey__c = survey.id,ArdiraSurvey__Answered__c=true,ArdiraSurvey__Answer_Text__c='Agriculture');
    //     insert questionRes2;
        
    //     questionRes2.ArdiraSurvey__Answer_Text__c = 'Education';
    //     update questionRes2;
        
    //     aqrlist.add(questionRes2);
    //     Test.StartTest();
    //     PSS_QuestionResult_TriggerHelper.solutionUpdate(aqrlist);
    //     Test.stopTest();
        
    // }
    
    
}