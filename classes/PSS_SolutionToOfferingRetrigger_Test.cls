/*************************************************************************************************************************************************************************
* Class Name  : PSS_SolutionToOfferingRetrigger_Test 
* Version     : 1.0 
* Created Date: 6/17/2021
* Modification Log :
*
* Developer         Modification Log                    Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Sooriya              M-01    : Original version       6/17/2021                         Test class for PSS_SolutionToOfferingRetrigger
**************************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public class PSS_SolutionToOfferingRetrigger_Test {
    
    /*@testSetup
    public static void testDataSetUp() {
       
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account acc = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
        Account acc3 = PMP_TestDataUtility.createIntelAccount('TestIntelAccount123', PMP_TestDataUtility.intel_Account_Record_Type, true);
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = PMP_TestDataUtility.createTestUser(profileId);
        insert u;
        
        PMP_Company__c companyInfo1 = PMP_TestDataUtility.createCompanyInformation('test intel company', acc.Id, true);
        companyInfo1.PMP_Partner_Benefit_Type__c = PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED;
        companyInfo1.PMP_One_Partner_ID__c = acc.Id;
        companyInfo1.PMP_Benefit_Update_Ind__c = false;
        companyInfo1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        companyInfo1.PMP_Is_Published_Ind__c = true;
        update companyInfo1;
        
        ArdiraSurvey__Survey_Result__c surveyResult1 = PSS_TestDataUtility.createSolution();
        surveyResult1.PSS_Proposal_Name_Txt__c='TestSurveyResult1';
        surveyResult1.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Approved';
        surveyResult1.PSS_Partner_Account_Id__c = acc3.Id;
        surveyResult1.PSS_Programs_Applicable_Nm__c = 'MRS';
        surveyResult1.PSS_Company_Id__c = companyInfo1.Id;
        surveyResult1.PSS_OPID_Account_Id__c = acc.id;
        surveyResult1.ArdiraSurvey__Assigned_To_User__c=UserInfo.getUserId();
        surveyResult1.PSS_Solution_Submitter_UserId_Id__c = UserInfo.getUserId();
        insert surveyResult1;
         
        List<PMP_OPID_MPI_Rel__c> opidMpiList = new List<PMP_OPID_MPI_Rel__c>();
		PMP_OPID_MPI_Rel__c opidMpi = new PMP_OPID_MPI_Rel__c();
        opidMpi.PMP_One_Partner_ID__c = surveyResult1.PSS_OPID_Account_Id__c;
        opidMpi.PMP_Marketing_Profile_Id__c = surveyResult1.PSS_Company_Id__c;
        opidMpi.Is_Active__c = true;
        opidMpiList.add(opidMpi);
        insert opidMpiList;
        
        Account acc2 = PMP_TestDataUtility.createIntelAccount('TestIntelAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        Contact con = PMP_TestDataUtility.createContact(acc2.Id,true);
       
        ArdiraSurvey__Survey_Result__c surveyResult2 = PSS_TestDataUtility.createSolution();
        surveyResult2.PSS_Proposal_Name_Txt__c='TestSurveyResult2';
        surveyResult2.ArdiraSurvey__Assigned_To_Contact__c = con.Id;
        surveyResult2.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Approved';
        surveyResult2.PSS_Partner_Account_Id__c = acc3.Id;
        surveyResult2.PSS_OPID_Account_Id__c = acc.Id;
        surveyResult2.PSS_Company_Id__c = companyInfo1.Id;
        surveyResult2.ArdiraSurvey__Assigned_To_User__c=UserInfo.getUserId();
        surveyResult2.PSS_Solution_Submitter_UserId_Id__c = UserInfo.getUserId();
        insert surveyResult2;
        
        List<PMP_Category__c> catList =New List<PMP_Category__c>();
        PMP_Category__c newcat1 = New PMP_Category__c(Name = 'Categories',PMP_Partner_Product_Parent_Category_Cd__c= 'Solution_Marketplace_Hierarchy',
                                                      PMP_Partner_Product_Category_Cd__c = 'NPP_01_TYPE',PMP_Partner_Product_Category_Key__c = 'npp_01_type',
													  PMP_Active_Ind__c=true);
        catList.add(newcat1);
        
        PMP_Category__c newcat2 = New PMP_Category__c(Name = 'Solution',PMP_Parent_Category_Id__c= newcat1.id,PMP_Partner_Product_Category_Cd__c = 'IPA_TYPE_Sol',
                                                      PMP_Partner_Product_Category_Key__c = 'ipa_type_sol',PMP_Partner_Product_Parent_Category_Cd__c ='NPP_01_TYPE',
													  PMP_Active_Ind__c=true);
        catList.add(newcat2);
        insert catList;

    }
    
    @isTest
    Public static void convertSolutionToOfferingTest(){
        ArdiraSurvey__Survey_Result__c surveyResult1 = [Select id from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c ='TestSurveyResult1' Limit 1];
        ArdiraSurvey__Survey_Result__c surveyResult2 = [Select id from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c ='TestSurveyResult2' Limit 1];

        Test.startTest();
        
        PSS_SolutionToOfferingRetrigger.convertSolutionToOffering(surveyResult1.Id);
        
        Test.stopTest();
        
        integer offeringCount = [Select count() from PMP_Partner_Offering__c];
        
        system.assertEquals(2,offeringCount, 'offering record is created');
    }
    
    @isTest
    Public static void convertSolutionToOfferingFailTest(){
        ArdiraSurvey__Survey_Result__c surveyResult1 = [Select id from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c ='TestSurveyResult1' Limit 1];
		PMP_Category__c cat1 =[Select id, PMP_Active_Ind__c from PMP_Category__c  
                               where PMP_Partner_Product_Category_Cd__c = 'IPA_TYPE_Sol' And PMP_Active_Ind__c = True Limit 1];
        cat1.PMP_Active_Ind__c =False;
        update cat1;
        
        Test.startTest();
        	PSS_SolutionToOfferingRetrigger.convertSolutionToOffering(surveyResult1.Id);
        Test.stopTest();
        
        integer offeringCount = [Select count() from PMP_Partner_Offering__c];
        
        system.assertEquals(0,offeringCount, 'Exception occurred');
    }*/
	
}