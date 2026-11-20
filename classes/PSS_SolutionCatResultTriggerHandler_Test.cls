/****************************************************************************************************************************************
* Class Name  : PSS_SolutionCatResultTriggerHandler_Test  
* Version     : 1.0 
* Created Date: 18-06-2021
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* MP Team - Sooriya			18-06-2021				  Test class for PSS_SolutionCategoryResultTriggerHandler
*****************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public class PSS_SolutionCatResultTriggerHandler_Test {
    
       
	// @isTest
    // static void afterInsertTest(){
        
    //     Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
    //     Account acc = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
    //     Contact con = PMP_TestDataUtility.createContact(acc.Id,true);
        
    //     PMP_Company__c companyInfo1 = PMP_TestDataUtility.createCompanyInformation('test intel company', acc.Id, true);
    //     companyInfo1.PMP_Partner_Benefit_Type__c = PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED;
    //     companyInfo1.PMP_One_Partner_ID__c = acc.Id;
    //     update companyInfo1;
        
        
    //     ArdiraSurvey__Survey_Result__c surveyResult1 = PSS_TestDataUtility.createSolution();
    //     surveyResult1.PSS_Proposal_Name_Txt__c='TestSurveyResult1';
    //     surveyResult1.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Approved';
    //     surveyResult1.ArdiraSurvey__Assigned_To_Contact__c = con.Id;
    //     surveyResult1.PSS_Partner_Account_Id__c = acc.Id;
    //     surveyResult1.PSS_Programs_Applicable_Nm__c = 'MRS';
    //     surveyResult1.PSS_Company_Id__c = companyInfo1.Id;
    //     insert surveyResult1;
        
    //     ArdiraSurvey__Survey_Result__c surveyResult2 = PSS_TestDataUtility.createSolution();
    //     surveyResult2.PSS_Proposal_Name_Txt__c='TestSurveyResult1';
    //     surveyResult2.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Approved';
    //     surveyResult2.ArdiraSurvey__Assigned_To_Contact__c = con.Id;
    //     surveyResult2.PSS_Partner_Account_Id__c = acc.Id;
    //     surveyResult2.PSS_Programs_Applicable_Nm__c = 'RRK';
    //     surveyResult2.PSS_Company_Id__c = companyInfo1.Id;
    //     insert surveyResult2;
        
    //     ArdiraSurvey__Category__c surveyCategory = New ArdiraSurvey__Category__c ();
    //     surveyCategory.Name = 'MRS';
    //     surveyCategory.PSS_Category_Threshold_Value__c = 2;
    //     insert surveyCategory;
        
    //     ArdiraSurvey__Survey__c survey=new ArdiraSurvey__Survey__c();
    //     survey.ArdiraSurvey__CNav_Pagination__c='Section';
    //     survey.Name='Solution Survey';
    //     survey.ArdiraSurvey__Status__c='Closed';
    //     insert survey;
        
    //     ArdiraSurvey__Question__c question1 = New ArdiraSurvey__Question__c();
    //     question1.PSS_Question_Unique_Key_Txt__c = PMP_Utility.getValue('PSS_Hidden_Question_Key');
    //     question1.ArdiraSurvey__Survey__c = survey.Id;
    //     insert question1;
        
    //     Test.startTest();
    //     ArdiraSurvey__Question_Result__c questionResult1 = New ArdiraSurvey__Question_Result__c();
    //     questionResult1.ArdiraSurvey__Answer_Text__c ='MRS';
    //     questionResult1.ArdiraSurvey__Survey__c = survey.Id;
    //     questionResult1.ArdiraSurvey__Answered__c = true;
    //     questionResult1.ArdiraSurvey__Survey_Result__c = surveyResult1.Id;
    //     questionResult1.ArdiraSurvey__Question__c = question1.Id;
    //     insert questionResult1;
        
    //     ArdiraSurvey__Survey_Category_Result__c surveyCategoryResult1 = New ArdiraSurvey__Survey_Category_Result__c();
    //     surveyCategoryResult1.ArdiraSurvey__Survey_Result__c = surveyResult1.Id;
    //     surveyCategoryResult1.ArdiraSurvey__Category__c = surveyCategory.Id;
    //     surveyCategoryResult1.ArdiraSurvey__Score_Raw__c =2;
    //     insert surveyCategoryResult1;
        
    //     system.assertEquals(2, surveyCategoryResult1.ArdiraSurvey__Score_Raw__c, 'value is equal');
        
    //     ArdiraSurvey__Survey_Category_Result__c surveyCategoryResult2 = [Select Id, ArdiraSurvey__Category__c ,ArdiraSurvey__Score_Raw__c
    //                                                                     from ArdiraSurvey__Survey_Category_Result__c 
    //                                                                      where ArdiraSurvey__Score_Raw__c =2 LIMIT 1];
    //     surveyCategoryResult2.ArdiraSurvey__Score_Raw__c = 3;
    //     update surveyCategoryResult2;
    //     Test.stopTest();
    //   /*  try{
    //         //insert surveyCategory;
    //      ArdiraSurvey__Survey_Category_Result__c surveyCategoryResult5 = New ArdiraSurvey__Survey_Category_Result__c();
       
    //     insert surveyCategoryResult5;
    //         // throw new DMLException('My DML EXCEPTION'); 
    //     }
    //     catch(DMLException e){
    //        throw e;
    //     }*/
           
        
       
      
    // }
    
}