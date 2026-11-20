//IPA2.0: US-TWC729-7976
@isTest
public class PSS_ActivationCallOnSolution_Test {
    /*@isTest
    @testSetup static void setup(){

        User u =PMP_TestDataUtility.createUser(true); 
       
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account acc = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
        Account acc2 = PMP_TestDataUtility.createAccount('TestPartnerAccount2', devRecordTypeId, true);
        Account acc3 = PMP_TestDataUtility.createIntelAccount('TestIntelAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        Contact con = PMP_TestDataUtility.createContact(acc3.Id,true);
        PMP_Company__c companyInfo1 = PMP_TestDataUtility.createCompanyInformation('test intel company', acc.Id, true);
        PMP_Company__c companyInfo2 = PMP_TestDataUtility.createCompanyInformation('test intel company', acc.Id, true);
        PMP_Company__c companyInfo3 = PMP_TestDataUtility.createCompanyInformation('test intel company2', acc2.Id, true);
        companyInfo1.PMP_Partner_Benefit_Type__c = PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED;
        companyInfo1.PMP_One_Partner_ID__c = acc.Id;
        companyInfo2.PMP_Partner_Benefit_Type__c = PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED;
        companyInfo2.PMP_One_Partner_ID__c = acc.Id;
        companyInfo3.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        companyInfo3.PMP_One_Partner_ID__c = acc2.Id;
        update companyInfo1;
        update companyInfo2;
        update companyInfo3;

        PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering1','Public Content', 
                                                                               'TestDuplicate',companyInfo1.Id, true,'Draft','');
        PMP_Partner_Offering__c offering2 = PMP_TestDataUtility.createOffering('TestDuplicateOffering2','Public Content', 
                                                                               'TestDuplicate',companyInfo2.Id, true,'Draft','');  
        ArdiraSurvey__Survey_Result__c surveyResult1 = PSS_TestDataUtility.createSolution();
        surveyResult1.PSS_Proposal_Name_Txt__c='TestDuplicateOffering1';
        surveyResult1.PSS_Company_Id__c=companyInfo1.Id;
        surveyResult1.PSS_Partner_Account_Id__c   = acc.Id;
        insert surveyResult1;
        
        ArdiraSurvey__Survey_Result__c surveyResult2 = PSS_TestDataUtility.createSolution();
        surveyResult2.PSS_Proposal_Name_Txt__c='TestDuplicateOffering2';
        surveyResult2.PSS_Partner_Account_Id__c = acc.Id;
        insert surveyResult2;
        
        ArdiraSurvey__Survey_Result__c surveyResult3 = PSS_TestDataUtility.createSolution();
       surveyResult3.PSS_Proposal_Name_Txt__c='TestDuplicateOffering3';
       surveyResult3.PSS_Follow_up_Date_Dt__c=system.today()+2;
        surveyResult3.PSS_Review_Scheduled_Date_dt__c =system.today()+10;
        surveyResult3.ArdiraSurvey__Score_Raw__c=20;
        surveyResult3.PSS_Partner_Account_Id__c = acc.Id;
        insert surveyResult3;
        
        ArdiraSurvey__Survey_Result__c surveyResult4 = PSS_TestDataUtility.createSolution();
        surveyResult4.PSS_Proposal_Name_Txt__c = 'SampleTestSolution1';
        surveyResult4.PSS_Company_Id__c=companyInfo3.Id;
        surveyResult4.PSS_Partner_Account_Id__c = acc2.Id;
        insert surveyResult4;
        
        ArdiraSurvey__Survey_Result__c surveyResult5 = PSS_TestDataUtility.createSolution();
        surveyResult5.PSS_Proposal_Name_Txt__c = 'SampleTestSolution2';
		surveyResult5.ArdiraSurvey__Assigned_To_Contact__c = con.Id;        
        surveyResult5.PSS_Partner_Account_Id__c = acc3.Id;
        insert surveyResult5;
        
    }

    @isTest static void testgetSurveyResult() {
        Ardirasurvey__survey_result__c surveyList = [Select Id, Name,PSS_Proposal_Name_Txt__c FROM ArdiraSurvey__Survey_Result__c limit 1];
        Test.startTest();
        PSS_ActivationCallOnSolution.getSurveyResult(surveyList.Id);
        Test.stopTest();
       System.assertEquals(surveyList.PSS_Proposal_Name_Txt__c,'TestDuplicateOffering1');
    }

    @isTest static void testupdateResultRecord() {
        
        List<Object> answerListObject = new List<Object>();
        //List<Object> strng = new List<Object>(('2021-05-28','Done','test data'));
        //List<String> stringList = new List<String>();
        //stringList = ('2021-05-28', 'Done', 'test data')
        string answerOptions = '(2021-05-28, Done, test data)';
        string ans = answerOptions.replace('(','');
		string ansOp = ans.replace(')','');
        answerListObject = ansOp.split(',');
        //answerListObject.add(answerOptions);
        Ardirasurvey__survey_result__c surveyResult = [Select Id, Name, PSS_Solution_Activation_Call_Date_dt__c,PSS_SolutionStatusActivationComments_Txt__c, PSS_Solution_Status_Nm__c FROM 
                                                         ArdiraSurvey__Survey_Result__c limit 1];
        Test.startTest();
        PSS_ActivationCallOnSolution.updateResultRecord(answerListObject, surveyResult.Id);
        Test.stopTest();
        system.assertEquals(3, answerListObject.size());
    }*/
}