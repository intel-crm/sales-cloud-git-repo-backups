/****************************************************************************************************************************************
* Class Name  : PSS_SolutionToOfferingConvertBatch_Test 
* Version     : 1.0 
* Created Date: 06-21-2021
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sooriya                         June-21-2021                  Test class for PSS_SolutionToOfferingConversionBatch class
* ****************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
Public class PSS_SolutionToOfferingConvertBatch_Test {
/*
    @isTest
    static void testMethod1(){
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account acc = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
        PMP_Company__c companyInfo1 = PMP_TestDataUtility.createCompanyInformation('test company batch', acc.Id, true);
        companyInfo1.PMP_Partner_Benefit_Type__c = PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED;
        companyInfo1.PMP_One_Partner_ID__c = acc.Id;
        update companyInfo1;
        
        ArdiraSurvey__Survey__c survey = New ArdiraSurvey__Survey__c(Name = 'Test Survey Batch', ArdiraSurvey__CNav_Pagination__c = 'Section', ArdiraSurvey__Status__c = 'Open');
        insert survey;
        
        List<ArdiraSurvey__Survey_Result__c> solutionList = New List<ArdiraSurvey__Survey_Result__c>();
        
        ArdiraSurvey__Survey_Result__c surResult1 = PSS_TestDataUtility.createSolution();
        surResult1.PSS_Proposal_Name_Txt__c='Test Batch 1';
        surResult1.ArdiraSurvey__Survey__c = survey.id;
        surResult1.PSS_Programs_Applicable_Nm__c = 'MRS;RRK';
        surResult1.PSS_Company_Id__c = companyInfo1.Id;
        surResult1.PSS_Partner_Account_Id__c   = acc.Id;
        surResult1.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Approved';
        solutionList.add(surResult1);
        
        insert solutionList;

        
        Test.startTest();
        PSS_SolutionToOfferingConversionBatch batchJob = new PSS_SolutionToOfferingConversionBatch();
        Database.executeBatch(batchJob);
		Test.stopTest();
        system.assertEquals(solutionList[0].PSS_Partner_Solution_Lifecycle_Status_Nm__c, 'Approved', 'values are equal');
        
    }
*/
}