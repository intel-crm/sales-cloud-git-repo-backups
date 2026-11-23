/*IPA2.0: US-TWC729-7976*/
@isTest
public class PSS_SurveyCategoryResultUtilityTest {
    
    /*@isTest
    static void calculateCategoryScoreTest1(){
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account acc = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
        Contact con = PMP_TestDataUtility.createContact(acc.Id,true);
        
        PMP_Company__c companyInfo1 = PMP_TestDataUtility.createCompanyInformation('test intel company', acc.Id, true);
        companyInfo1.PMP_Partner_Benefit_Type__c = PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED;
        companyInfo1.PMP_One_Partner_ID__c = acc.Id;
        update companyInfo1;
        
        List<ArdiraSurvey__Survey_Result__c> surveyList = new List<ArdiraSurvey__Survey_Result__c>();
        ArdiraSurvey__Survey_Result__c surveyResult1 = PSS_TestDataUtility.createSolution();
        surveyResult1.PSS_Proposal_Name_Txt__c='TestSurveyResult1';
        surveyResult1.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Approved';
        surveyResult1.ArdiraSurvey__Assigned_To_Contact__c = con.Id;
        surveyResult1.PSS_Partner_Account_Id__c = acc.Id;
        surveyResult1.PSS_Programs_Applicable_Nm__c = 'MRS';
        surveyResult1.PSS_Company_Id__c = companyInfo1.Id;
        insert surveyResult1;
        surveyList.add(surveyResult1);
        
        ArdiraSurvey__Category__c surveyCategory = New ArdiraSurvey__Category__c ();
        surveyCategory.Name = 'MRS';
        surveyCategory.PSS_Category_Threshold_Value__c = 2;
        insert surveyCategory;
        
        List<ArdiraSurvey__Survey_Category_Result__c> catReslutsList= new List<ArdiraSurvey__Survey_Category_Result__c>();

        Test.startTest();
        ArdiraSurvey__Survey_Category_Result__c surveyCategoryResult1 = New ArdiraSurvey__Survey_Category_Result__c();
        surveyCategoryResult1.ArdiraSurvey__Survey_Result__c = surveyResult1.Id;
        surveyCategoryResult1.ArdiraSurvey__Category__c = surveyCategory.Id;
        surveyCategoryResult1.ArdiraSurvey__Score_Raw__c =2;
        insert surveyCategoryResult1;
        catReslutsList.add(surveyCategoryResult1);
        system.assertEquals(2, surveyCategoryResult1.ArdiraSurvey__Score_Raw__c, 'value is equal');
        
        ArdiraSurvey__Survey_Category_Result__c surveyCategoryResult2 = [Select Id, ArdiraSurvey__Category__c ,ArdiraSurvey__Score_Raw__c
                                                                        from ArdiraSurvey__Survey_Category_Result__c 
                                                                         where ArdiraSurvey__Score_Raw__c =2 LIMIT 1];
        surveyCategoryResult2.ArdiraSurvey__Score_Raw__c = 3;
        update surveyCategoryResult2;
        PSS_SurveyCategoryResultTrigger_Utility.calculateCategoryScore(catReslutsList);
        Test.stopTest();
        
      
    }
    
     @isTest
    static void calculateCategoryScoreTest2(){
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account acc = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
        Contact con = PMP_TestDataUtility.createContact(acc.Id,true);
        
        PMP_Company__c companyInfo1 = PMP_TestDataUtility.createCompanyInformation('test intel company', acc.Id, true);
        companyInfo1.PMP_Partner_Benefit_Type__c = PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED;
        companyInfo1.PMP_One_Partner_ID__c = acc.Id;
        update companyInfo1;
        
        List<ArdiraSurvey__Survey_Result__c> surveyList = new List<ArdiraSurvey__Survey_Result__c>();
        ArdiraSurvey__Survey_Result__c surveyResult1 = PSS_TestDataUtility.createSolution();
        surveyResult1.PSS_Proposal_Name_Txt__c='TestSurveyResult1';
        surveyResult1.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Approved';
        surveyResult1.ArdiraSurvey__Assigned_To_Contact__c = con.Id;
        surveyResult1.PSS_Partner_Account_Id__c = acc.Id;
        surveyResult1.PSS_Programs_Applicable_Nm__c = 'Partner Solution';
        surveyResult1.PSS_Company_Id__c = companyInfo1.Id;
        insert surveyResult1;
        surveyList.add(surveyResult1);
        
        ArdiraSurvey__Category__c surveyCategory = New ArdiraSurvey__Category__c ();
        surveyCategory.Name = 'Partner Solution';
        surveyCategory.PSS_Category_Threshold_Value__c = 2;
        insert surveyCategory;
        
        List<ArdiraSurvey__Survey_Category_Result__c> catReslutsList= new List<ArdiraSurvey__Survey_Category_Result__c>();

        Test.startTest();
        ArdiraSurvey__Survey_Category_Result__c surveyCategoryResult1 = New ArdiraSurvey__Survey_Category_Result__c();
        surveyCategoryResult1.ArdiraSurvey__Survey_Result__c = surveyResult1.Id;
        surveyCategoryResult1.ArdiraSurvey__Category__c = surveyCategory.Id;
        surveyCategoryResult1.ArdiraSurvey__Score_Raw__c =2;
        insert surveyCategoryResult1;
        catReslutsList.add(surveyCategoryResult1);
        system.assertEquals(2, surveyCategoryResult1.ArdiraSurvey__Score_Raw__c, 'value is equal');
        
        ArdiraSurvey__Survey_Category_Result__c surveyCategoryResult2 = [Select Id, ArdiraSurvey__Category__c ,ArdiraSurvey__Score_Raw__c
                                                                        from ArdiraSurvey__Survey_Category_Result__c 
                                                                         where ArdiraSurvey__Score_Raw__c =2 LIMIT 1];
        surveyCategoryResult2.ArdiraSurvey__Score_Raw__c = 3;
        update surveyCategoryResult2;
        PSS_SurveyCategoryResultTrigger_Utility.calculateCategoryScore(catReslutsList);
        Test.stopTest();
        
      
    }*/

}