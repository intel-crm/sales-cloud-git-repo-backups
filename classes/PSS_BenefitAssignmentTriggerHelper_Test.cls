/****************************************************************************************************************************************
* Class Name  : PSS_BenefitAssignmentTriggerHelper_Test  
* Version     : 1.0 
* Created Date: 18-06-2021
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* MP Team - Manjula      18-06-2021          Test class for PSS_BenefitAssignmentTriggerHelper
*****************************************************************************************************************************************/
@isTest //IPA2.0: US-TWC729-7976
public class PSS_BenefitAssignmentTriggerHelper_Test {
    
    /*@testSetup static void setup() {
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id intelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acc3 = PMP_TestDataUtility.createAccount('TestPartnerAccount3', devRecordTypeId, true);
        acc3.Core_IPA_Partner_Role__c= 'Manufacturer';
        acc3.Core_IPA_Badge_Tier__c = 'Titanium';
        
        update acc3;
        
        Account intelAcc3 = PMP_TestDataUtility.createAccount('TestIntelAccount3', intelRecordTypeId, true);
        intelAcc3.Core_IPA_Partner_Role__c= 'Manufacturer';
        intelAcc3.Core_IPA_Badge_Tier__c = 'Titanium';
        intelAcc3.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        update intelAcc3;
     
        Contact con = PMP_TestDataUtility.createContact(intelAcc3.Id,true);
        
        PMP_Company__c companyInfo3 = PMP_TestDataUtility.createCompanyInformation('test intel company2', acc3.Id, true);
        companyInfo3.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Enhanced';
        companyInfo3.PMP_One_Partner_ID__c = acc3.Id;
        update companyInfo3;
        
        Id specid = Schema.SObjectType.PRM_Specialty__c.getRecordTypeInfosByName().get('Select Benefits').getRecordTypeId();
        PRM_Specialty__c spec1 = new PRM_Specialty__c();
        spec1.name='Cloud Data Center Specialty';
        spec1.PRM_Description_Txt__c='This is description';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Manufacturer';
        spec1.PRM_Tier_Nm__c='Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_Access_Level_Nm__c='Public';
        spec1.RecordTypeId=specid;
        spec1.PRM_Inactive_Ind__c=false;
        insert spec1;
        
        Id specid2 = Schema.SObjectType.PRM_Specialty__c.getRecordTypeInfosByName().get('Select Benefits').getRecordTypeId();
        PRM_Specialty__c spec2 = new PRM_Specialty__c();
        spec2.name='Video Specialty';
        spec2.PRM_Description_Txt__c='This is description';
        spec2.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec2.PRM_Role_Nm__c='Manufacturer';
        spec2.PRM_Tier_Nm__c='Gold';
        spec2.PRM_Start_Date_Dt__c= system.today() + 7;
        spec2.PRM_Access_Level_Nm__c='Public';
        spec2.RecordTypeId=specid2;
        spec2.PRM_Inactive_Ind__c=false;
        insert spec2;
        
        Core_Account_Group_Member__c agm = new Core_Account_Group_Member__c();
        agm.Core_Partner_Account_Id__c = acc3.id;
        agm.Core_Intel_Account_Id__c = intelAcc3.Id;
        insert agm;
    
        ArdiraSurvey__Survey_Result__c surveyResult2 = PSS_TestDataUtility.createSolution();
        surveyResult2.PSS_Proposal_Name_Txt__c='TestDuplicateSolution2';
        surveyResult2.PSS_Company_Id__c=companyInfo3.Id;
        //surveyResult2.PSS_Partner_Account_Id__c   = acc3.Id;
        surveyResult2.PSS_Partner_Account_Id__c = intelAcc3.Id;
        surveyResult2.PSS_OPID_Account_Id__c = acc3.Id;
        surveyResult2.PSS_Programs_Applicable_Nm__c = 'MRS;RRK';
        surveyResult2.PSS_Admin_Suggested_Benefit_Level__c = spec1.Id;
        surveyResult2.PSS_Is_Benefit_Assigned_Ind__c = true;
        surveyResult2.PSS_System_Suggested_Benefit_Level__c = spec1.Id;
        surveyResult2.PSS_Solution_Category_Nm__c = 'IOTG';
        surveyResult2.PSS_Impact_Path_Score__c = 6;
        surveyResult2.ArdiraSurvey__Score_Level__c = 'High';
        surveyResult2.ArdiraSurvey__Assigned_To_Contact__c = con.Id;
        insert surveyResult2;
        
        ArdiraSurvey__Survey_Result__c resultNew = [Select Id,PSS_Partner_Account_Id__c,PSS_OPID_Account_Id__c from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c='TestDuplicateSolution2'];
        //system.debug('resultNew::'+resultNew);
        
        ArdiraSurvey__Survey_Result__c surveyResult3 = PSS_TestDataUtility.createSolution();
        surveyResult3.PSS_Proposal_Name_Txt__c='TestDuplicateSolution2';
        surveyResult3.PSS_Company_Id__c=companyInfo3.Id;
        surveyResult3.PSS_Partner_Account_Id__c   = acc3.Id;
        surveyResult3.PSS_Programs_Applicable_Nm__c = 'MRS;RRK';
        surveyResult3.PSS_Admin_Suggested_Benefit_Level__c = spec1.Id;
        surveyResult3.PSS_Is_Benefit_Assigned_Ind__c = true;
        surveyResult3.PSS_System_Suggested_Benefit_Level__c = spec1.Id;
        surveyResult3.PSS_Solution_Category_Nm__c = 'IOTG';
        surveyResult3.PSS_Impact_Path_Score__c = 6;
        surveyResult3.ArdiraSurvey__Score_Level__c = 'High';
        surveyResult3.ArdiraSurvey__Assigned_To_Contact__c = con.Id;
        surveyResult3.PSS_Solution_Revenue_Projection__c = 10;
        insert surveyResult3;
        
       
        PSS_Solution_Scoring__c solScoring = new PSS_Solution_Scoring__c();
        solScoring.Name ='High_IOTG';
        solScoring.PSS_Scoring_Range_Upper_Bound_Nbr__c = 30;
        solScoring.PSS_Scoring_Range_Lower_Bound_Nbr__c = 1;
        solScoring.PSS_Scoring_Type__c = 'Consolidate';
        solScoring.PSS_Solution_Category_Nm__c = 'IOTG';
        insert solScoring;
        
        PSS_Solution_Scoring__c solScoring2 = new PSS_Solution_Scoring__c();
        solScoring2.Name ='High_DCG';
        solScoring2.PSS_Scoring_Range_Upper_Bound_Nbr__c = 30;
        solScoring2.PSS_Scoring_Range_Lower_Bound_Nbr__c = 1;
        solScoring2.PSS_Scoring_Type__c = 'Consolidate';
        solScoring2.PSS_Solution_Category_Nm__c = 'IOTG';
        insert solScoring2;
        
        ArdiraSurvey__Category__c category = new ArdiraSurvey__Category__c();
        category.PSS_Priority_Nbr__c = 1;
        category.Name = 'MRS';
        category.PSS_Is_Active_Ind__c = true;
        insert category;
        
        PSS_Solutions_Impact_Path_Scoring__c impactScoring = new PSS_Solutions_Impact_Path_Scoring__c();
        impactScoring.GeTm_IPA_Tier__c = 'Titanium';
        impactScoring.PSS_Solution_Scoring__c = solScoring.Id;
        impactScoring.GeTm_Solution_Type__c = category.id;
        impactScoring.GeTm_Admin_Suggested_Select_Benefit__c = spec2.Id;
        insert impactScoring;
        
        PSS_Solutions_Impact_Path_Scoring__c impactScoring2 = new PSS_Solutions_Impact_Path_Scoring__c();
        impactScoring2.GeTm_IPA_Tier__c = 'Titanium';
        impactScoring2.PSS_Solution_Scoring__c = solScoring2.Id;
        impactScoring2.GeTm_Solution_Type__c = category.id;
        impactScoring2.GeTm_Admin_Suggested_Select_Benefit__c = spec2.Id;
        insert impactScoring2;
     
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
            
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Titanium';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        List<PRM_AccountChannelMembership__c> acmData = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=acc3.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Manufacturer';
        acmData.add(acm);
        //insert acm;
      
        PRM_AccountChannelMembership__c acm2 = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm2.PRM_Account_Id__c=intelAcc3.id;
        acm2.PRM_Status_Nm__c='Approved';
        acm2.PRM_Channel_Program_Id__c=cp.Id;
        acm2.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm2.PRM_Partner_Role__c='Manufacturer';
        acmData.add(acm2);
        
        insert acmData;
        

        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Partner_Role__c = 'Manufacturer';
        asa.PRM_Account_Id__c = acc3.id;
        asa.PRM_Specialty_Id__c = spec1.Id;
        insert asa;
    }
    
    public static testMethod void convertSolutionToOfferingTest(){
         
       List<ArdiraSurvey__Survey_Result__c> solutionList2 = [Select id,PSS_OPID_Account_Id__c,PSS_Partner_Account_Id__c,PSS_Solution_Category_Nm__c,ArdiraSurvey__Score_Level__c,PSS_Admin_Suggested_Benefit_Level__c,PSS_System_Suggested_Benefit_Level__c,
                                                             PSS_Programs_Applicable_Nm__c,PSS_Impact_Path_Scoring__c,PSS_Impact_Path_Score__c,PSS_Solution_Revenue_Projection__c,PSS_Partner_Solution_Lifecycle_Status_Nm__c,ArdiraSurvey__Assigned_To_Contact__r.AccountId,
                                                             PSS_System_Suggested_Benefit_Level__r.Name, PSS_Admin_Suggested_Benefit_Level__r.Name
                                                             from ArdiraSurvey__Survey_Result__c limit 10];
       test.startTest();
       PSS_BenefitAssignmentTriggerHelper.convertSolutionToOffering(solutionList2);
       PSS_BenefitAssignmentTriggerHelper.assignBenefitToAccount(solutionList2);
       PRM_Account_Specialty_Association__c asa = [Select Id, PRM_Partner_Role__c from PRM_Account_Specialty_Association__c
                                                    where PRM_Partner_Role__c = 'Manufacturer' Limit 1];
         
       system.assertEquals('Manufacturer', asa.PRM_Partner_Role__c, 'passed');
       test.stopTest();
    }*/

}