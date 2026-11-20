//IPA2.0: US-TWC729-7976
/****************************************************************************************************************************************
* Class Name  : PSS_AdminDetailsController_Test 
* Version     : 1.0 
* Created Date: 03/26/2021
* Created By  : ONYX Team (Infosys)
* Modification Log : 
*****************************************************************************************************************************************/
@isTest
public class PSS_AdminDetailsController_Test {
    /*@testSetup
    public static void testDataSetUp() {
        User u =PMP_TestDataUtility.createUser(true); 
       
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account acc = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
        Account acc2 = PMP_TestDataUtility.createAccount('TestPartnerAccount2', devRecordTypeId, true);
        Account acc3 = PMP_TestDataUtility.createIntelAccount('TestIntelAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        Contact con = PMP_TestDataUtility.createContact(acc3.Id,true);
        List<PMP_Company__c> companyInfoList = new List<PMP_Company__c>();
        List<ArdiraSurvey__Survey_Result__c> surveyResultList = new List<ArdiraSurvey__Survey_Result__c>();
        PMP_Company__c companyInfo1 = PMP_TestDataUtility.createCompanyInformation('test intel company', acc.Id, true);
        PMP_Company__c companyInfo2 = PMP_TestDataUtility.createCompanyInformation('test intel company', acc.Id, true);
        PMP_Company__c companyInfo3 = PMP_TestDataUtility.createCompanyInformation('test intel company2', acc2.Id, true);
        //companyInfo1.PMP_Partner_Benefit_Type__c = PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED; //IPA2.0 - TWC729-7885
        companyInfo1.PMP_One_Partner_ID__c = acc.Id;
        companyInfo1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        //companyInfo2.PMP_Partner_Benefit_Type__c = PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED; //IPA2.0 - TWC729-7885
        companyInfo2.PMP_One_Partner_ID__c = acc.Id;
        companyInfo2.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        companyInfo3.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        companyInfo3.PMP_One_Partner_ID__c = acc2.Id;
        companyInfoList.add(companyInfo1);
        companyInfoList.add(companyInfo2);
        companyInfoList.add(companyInfo3);
        
        update companyInfoList;

        PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering1','Public Content', 
                                                                               'TestDuplicate',companyInfo1.Id, true,'Draft','');
        PMP_Partner_Offering__c offering2 = PMP_TestDataUtility.createOffering('TestDuplicateOffering2','Public Content', 
                                                                               'TestDuplicate',companyInfo2.Id, true,'Draft','');  
        ArdiraSurvey__Survey__c survey1 = new ArdiraSurvey__Survey__c();
     
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-',''); */
      /*  
        Id specid = Schema.SObjectType.PRM_Specialty__c.getRecordTypeInfosByName().get('Specialty').getRecordTypeId();PRM_Specialty__c spec1 = new PRM_Specialty__c();
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
        
        system.debug('spec1 inserted--->'+spec1);
         */
        /*survey1.Name = 'Test Survey1'+dateString;
        survey1.ArdiraSurvey__CNav_Pagination__c = 'Question';
        survey1.ArdiraSurvey__Status__c = 'Draft';
        insert survey1;
        
        ArdiraSurvey__Survey_Result__c surveyResult1 = new ArdiraSurvey__Survey_Result__c();
        surveyResult1.ArdiraSurvey__Assigned_To_User__c = u.Id;
        surveyResult1.PSS_Proposal_Name_Txt__c='TestDuplicateOffering1';
        surveyResult1.PSS_Company_Id__c = companyInfo1.Id;
        surveyResult1.PSS_Partner_Account_Id__c   = acc3.Id;
        surveyResult1.PSS_OPID_Account_Id__c = acc.id;
        surveyResult1.ArdiraSurvey__Survey__c = survey1.Id;
        surveyResult1.PSS_Programs_Applicable_Nm__c='Intel Select';
        surveyResultList.add(surveyResult1);
        
        ArdiraSurvey__Survey_Result__c surveyResult2 = new ArdiraSurvey__Survey_Result__c();
        surveyResult2.ArdiraSurvey__Assigned_To_User__c = u.Id;
        surveyResult2.PSS_Proposal_Name_Txt__c='TestDuplicateOffering2';
        surveyResult2.PSS_Partner_Account_Id__c = acc3.Id;
        //surveyResult1.PSS_OPID_Account_Id__c = acc.id;
        surveyResult2.PSS_OPID_Account_Id__c = acc.id;
        surveyResult2.PSS_Company_Id__c = companyInfo2.Id;
        surveyResult2.PSS_Programs_Applicable_Nm__c='Intel Select';
        surveyResult2.ArdiraSurvey__Survey__c = survey1.Id;
        surveyResultList.add(surveyResult2);
        
        
        ArdiraSurvey__Survey_Result__c surveyResult3 = new ArdiraSurvey__Survey_Result__c();
        surveyResult3.ArdiraSurvey__Assigned_To_User__c = u.Id;
        surveyResult3.PSS_Proposal_Name_Txt__c='TestDuplicateOffering3';
        surveyResult3.PSS_Follow_up_Date_Dt__c=system.today()+2;
        surveyResult3.PSS_Review_Scheduled_Date_dt__c =system.today()+10;
        surveyResult3.ArdiraSurvey__Score_Raw__c=20;
        surveyResult3.PSS_Partner_Account_Id__c = acc3.Id;
        //surveyResult1.PSS_OPID_Account_Id__c=acc.id;
        surveyResult3.PSS_OPID_Account_Id__c = acc.id;
        surveyResult3.PSS_Company_Id__c = companyInfo3.Id;
        surveyResult3.PSS_Programs_Applicable_Nm__c='Intel Select';
        //surveyResult3.PSS_Admin_Suggested_Benefit_Level__c =spec1.id;
        //surveyResult3.PSS_System_Suggested_Benefit_Level__c =spec1.id;
        surveyResult3.ArdiraSurvey__Survey__c = survey1.Id;
        surveyResult3.PSS_Partner_Solution_Lifecycle_Status_Nm__c = PSS_StaticConstants.SOLUTION_APPROVED_STATUS;
        //surveyResult3.PSS_Intel_Admin_Id__c=id;
        surveyResultList.add(surveyResult3);

        
        ArdiraSurvey__Survey_Result__c surveyResult4 = new ArdiraSurvey__Survey_Result__c();
        surveyResult4.ArdiraSurvey__Assigned_To_User__c = u.Id;
        surveyResult4.PSS_Proposal_Name_Txt__c = 'SampleTestSolution1';
        surveyResult4.PSS_Company_Id__c=companyInfo3.Id;
        surveyResult4.PSS_Partner_Account_Id__c = acc3.Id;
        //surveyResult1.PSS_OPID_Account_Id__c=acc2.id;
        surveyResult4.PSS_OPID_Account_Id__c =acc2.id;
        //surveyResult4.PSS_Company_Id__c = null;
        surveyResult4.PSS_Programs_Applicable_Nm__c='Intel Select';
        surveyResult4.ArdiraSurvey__Survey__c = survey1.Id;
        surveyResultList.add(surveyResult4);
        
        ArdiraSurvey__Survey_Result__c surveyResult5 = new ArdiraSurvey__Survey_Result__c();
        surveyResult5.ArdiraSurvey__Assigned_To_User__c = u.Id;
        surveyResult5.PSS_Proposal_Name_Txt__c = 'SampleTestSolution2';
		surveyResult5.ArdiraSurvey__Assigned_To_Contact__c = con.Id;        
        surveyResult5.PSS_Partner_Account_Id__c = acc3.Id;
        surveyResult5.PSS_OPID_Account_Id__c = acc2.id;
        surveyResult5.PSS_Company_Id__c=companyInfo2.Id;
        surveyResult5.PSS_Programs_Applicable_Nm__c='Intel Select';

        //surveyResult1.PSS_OPID_Account_Id__c=acc2.id;
        surveyResult5.ArdiraSurvey__Survey__c = survey1.Id;
        surveyResultList.add(surveyResult5);
        insert surveyResultList;
        
        //Contact Entitlement
        Account acct = [Select Id from Account where Name = 'TestPartnerAccount1' LIMIT 1];
        Contact conCase = new Contact (
        AccountId = acct.id,
        Salutation = 'Mr',FirstName = 'Test',
        LastName = 'portalTestUserv1',
        Email='testcontact'+String.valueOf(Math.random())+'@CorePMP.com',
        Phone='123456798',
        MailingCountry='USA'
        );
        insert conCase;
        
		Core_Entitlement__c entitlement = new Core_Entitlement__c(Name = 'Offering Editor',Core_IsActive__c = true,Core_Display_Name__c= 'Offering Editor');
        insert entitlement;
       
        
    }
    @isTest static void isDuplicateOfferingCheck(){
        ArdiraSurvey__Survey_Result__c surveyResult1 = [Select id ,name, PSS_Proposal_Name_Txt__c ,PSS_Company_Id__c,PSS_Company_Id__r.name,PSS_OPID_Account_Id__c from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c ='TestDuplicateOffering1'];
        
        ArdiraSurvey__Survey_Result__c surveyResult2 = [Select id ,name, PSS_Proposal_Name_Txt__c ,PSS_Company_Id__c,PSS_Company_Id__r.name,PSS_OPID_Account_Id__c from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c ='TestDuplicateOffering2'];

		ArdiraSurvey__Survey_Result__c surveyResult3 = [Select id ,name, PSS_Proposal_Name_Txt__c ,PSS_Company_Id__c,PSS_Company_Id__r.name,ArdiraSurvey__Score_Raw__c,PSS_Review_Scheduled_Date_dt__c ,PSS_Follow_up_Date_Dt__c,PSS_OPID_Account_Id__c,PSS_Admin_Suggested_Benefit_Level__c from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c='TestDuplicateOffering3'];

		ArdiraSurvey__Survey_Result__c surveyResult4 = [Select id ,name, PSS_Proposal_Name_Txt__c  ,PSS_Company_Id__c,PSS_Company_Id__r.name,PSS_OPID_Account_Id__c from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c ='SampleTestSolution1'];

        ArdiraSurvey__Survey_Result__c surveyResult5 = [Select id ,name, PSS_Proposal_Name_Txt__c   ,PSS_Company_Id__c,PSS_Company_Id__r.name,PSS_OPID_Account_Id__c from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c ='SampleTestSolution2'];

                List<PMP_OPID_MPI_Rel__c> opidMpiList = new List<PMP_OPID_MPI_Rel__c>();

        
        PMP_OPID_MPI_Rel__c opidMpi = new PMP_OPID_MPI_Rel__c();
        opidMpi.PMP_One_Partner_ID__c = surveyResult1.PSS_OPID_Account_Id__c;
        opidMpi.PMP_Marketing_Profile_Id__c = surveyResult1.PSS_Company_Id__c;
        opidMpi.Is_Active__c = true;
        opidMpiList.add(opidMpi);
        
        PMP_OPID_MPI_Rel__c opidMpi2 = new PMP_OPID_MPI_Rel__c();
        opidMpi2.PMP_One_Partner_ID__c = surveyResult2.PSS_OPID_Account_Id__c;
        opidMpi2.PMP_Marketing_Profile_Id__c = surveyResult2.PSS_Company_Id__c;
        opidMpi.Is_Active__c = true;
        opidMpiList.add(opidMpi2);
        
        PMP_OPID_MPI_Rel__c opidMpi3 = new PMP_OPID_MPI_Rel__c();
        opidMpi3.PMP_One_Partner_ID__c = surveyResult3.PSS_OPID_Account_Id__c;
        opidMpi3.PMP_Marketing_Profile_Id__c = surveyResult3.PSS_Company_Id__c;
        opidMpi.Is_Active__c = true;
        opidMpiList.add(opidMpi3);
       
        PMP_OPID_MPI_Rel__c opidMpi4 = new PMP_OPID_MPI_Rel__c();
        opidMpi4.PMP_One_Partner_ID__c = surveyResult4.PSS_OPID_Account_Id__c;
        opidMpi4.PMP_Marketing_Profile_Id__c = surveyResult4.PSS_Company_Id__c;
        opidMpi.Is_Active__c = true;
        opidMpiList.add(opidMpi4);
         
        PMP_OPID_MPI_Rel__c opidMpi5 = new PMP_OPID_MPI_Rel__c();
        opidMpi5.PMP_One_Partner_ID__c = surveyResult5.PSS_OPID_Account_Id__c;
        opidMpi5.PMP_Marketing_Profile_Id__c = surveyResult5.PSS_Company_Id__c;
        opidMpi.Is_Active__c = true;
        opidMpiList.add(opidMpi5);

        insert opidMpiList;
        
        test.startTest();
        Integer count1=PSS_AdminDetailsController.isDuplicateOffering(surveyResult1.Id, 'Approved');
        System.AssertEquals(count1,-1, 'cant approve');
        
        Integer count2=PSS_AdminDetailsController.isDuplicateOffering(surveyResult2.Id, 'Approved');
        //System.AssertEquals(count2,0, 'can approve on click of ok');
        System.AssertEquals(count2,-1, 'can approve on click of ok');

        
        Integer count3=PSS_AdminDetailsController.isDuplicateOffering(surveyResult3.Id, 'Approved');
        System.AssertEquals(count3,1, 'good to save');
       
        Integer count4=PSS_AdminDetailsController.isDuplicateOffering(surveyResult4.Id, 'Approved');
        System.AssertEquals(count4,2, 'Not Eligible for Offering Conversion');
         
        Integer count5=PSS_AdminDetailsController.isDuplicateOffering(surveyResult5.Id, 'Approved');
        System.AssertEquals(count5,2, 'No OPID.Not Eligible for Offering Conversion'); 
        
        PMP_LightningServerResponse response=PSS_AdminDetailsController.getAdminDetails(surveyResult1.Id);
        System.AssertNotEquals(response,null,'');
        Map<String,String> mapVal= new Map<String,String>();
        mapVal.put('ArdiraSurvey__Score_Raw__c',String.valueOf(surveyResult3.ArdiraSurvey__Score_Raw__c));
        mapVal.put('PSS_Review_Scheduled_Date_dt__c', String.valueOf(surveyResult3.PSS_Review_Scheduled_Date_dt__c  ));
        mapVal.put('PSS_Follow_up_Date_Dt__c', String.valueOf(surveyResult3.PSS_Follow_up_Date_Dt__c ));
        mapVal.put('PSS_Conversion_Admin_Log_Details_Txt__c', system.label.PSS_Conversion_MPI_Record_Validation_Error);
        //mapVal.put('PSS_Admin_Suggested_Benefit_Level__c', String.valueOf(surveyResult3.PSS_Admin_Suggested_Benefit_Level__c ));

        
        Map<String,String> mapVal2 = new Map<String,String>();
        mapVal2.put('ArdiraSurvey__Score_Raw__c',String.valueOf(surveyResult3.ArdiraSurvey__Score_Raw__c));
        mapVal2.put('PSS_Review_Scheduled_Date_dt__c', String.valueOf(surveyResult3.PSS_Review_Scheduled_Date_dt__c  ));
        mapVal2.put('PSS_Follow_up_Date_Dt__c', String.valueOf(surveyResult3.PSS_Follow_up_Date_Dt__c ));
        mapVal2.put('PSS_Partner_Solution_Lifecycle_Status_Nm__c',PSS_StaticConstants.SOLUTION_APPROVED_STATUS);
        //mapVal.put('PSS_Follow_up_Date_Dt__c', String.valueOf(surveyResult3.PSS_Follow_up_Date_Dt__c ));

        
        Map<String,String> mapVal3 = new Map<String,String>();
        mapVal3.put('ArdiraSurvey__Score_Raw__c',String.valueOf(surveyResult3.ArdiraSurvey__Score_Raw__c));
        mapVal3.put('PSS_Review_Scheduled_Date_dt__c', String.valueOf(surveyResult3.PSS_Review_Scheduled_Date_dt__c  ));
        mapVal3.put('PSS_Follow_up_Date_Dt__c', String.valueOf(surveyResult3.PSS_Follow_up_Date_Dt__c ));
        mapVal3.put('PSS_Partner_Solution_Lifecycle_Status_Nm__c',PSS_StaticConstants.SOLUTION_APPROVED_STATUS);        
        mapVal3.put('PSS_Conversion_Admin_Log_Details_Txt__c', system.label.PSS_DuplicateOfferingWarningMessage);
        //mapVal.put('PSS_Follow_up_Date_Dt__c', String.valueOf(surveyResult3.PSS_Follow_up_Date_Dt__c ));

        PSS_AdminDetailsController.saveAdminDetails(surveyResult2.Id, mapVal2);
        PSS_AdminDetailsController.saveAdminDetails(surveyResult4.Id, mapVal);
        PSS_AdminDetailsController.saveAdminDetails(surveyResult3.Id, mapVal3);        
        
        test.stopTest();
    }
    
    @isTest static void isIntelMPAdminCheck(){

        test.startTest();

        Boolean isMPAdmin = PSS_AdminDetailsController.isIntelMPAdmin();

        System.AssertEquals(isMPAdmin,isMPAdmin, 'Executed the Method');

        test.stopTest();

    }

    @isTest public static void createOfferingFromSolutionCheck(){

        ArdiraSurvey__Survey_Result__c surveyResults3 = [Select id ,name, PSS_Proposal_Name_Txt__c ,PSS_Company_Id__c,PSS_Company_Id__r.name,ArdiraSurvey__Score_Raw__c,PSS_Review_Scheduled_Date_dt__c ,PSS_Follow_up_Date_Dt__c,PSS_Intel_Admin_Id__c,PSS_Admin_Suggested_Benefit_Level__c,PSS_Programs_Applicable_Nm__c,PSS_System_Suggested_Benefit_Level__c from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c='TestDuplicateOffering3'];
        test.startTest();
        Map<String,String> mapVal3 = new Map<String,String>();
        mapVal3.put('ArdiraSurvey__Score_Raw__c',String.valueOf(surveyResults3.ArdiraSurvey__Score_Raw__c));
        mapVal3.put('PSS_Review_Scheduled_Date_dt__c', String.valueOf(surveyResults3.PSS_Review_Scheduled_Date_dt__c  ));
        mapVal3.put('PSS_Follow_up_Date_Dt__c', String.valueOf(surveyResults3.PSS_Follow_up_Date_Dt__c ));
        mapVal3.put('PSS_Partner_Solution_Lifecycle_Status_Nm__c',PSS_StaticConstants.SOLUTION_APPROVED_STATUS);        
        mapVal3.put('PSS_Conversion_Admin_Log_Details_Txt__c', system.label.PSS_DuplicateOfferingWarningMessage);
        //mapVal3.put('PSS_Intel_Admin_Id__c', String.valueOf(surveyResult3.PSS_Intel_Admin_Id__c ));
        //mapVal3.put('PSS_Admin_Suggested_Benefit_Level__c',String.valueOf(surveyResults3.PSS_Admin_Suggested_Benefit_Level__c));
        //mapVal3.put('PSS_System_Suggested_Benefit_Level__c',String.valueOf(surveyResults3.PSS_System_Suggested_Benefit_Level__c));

        
        PSS_AdminDetailsController.saveAdminDetails(surveyResults3.Id, mapVal3);   
        
        PSS_AdminDetailsController.createOfferingFromSolution(surveyResults3.Id);
        
        Map<String,String> mapVal4 = new Map<String,String>();
        mapVal4.put('PSS_Strategic_Attributes_Nm__c','Alibaba Co-Sponsor');
        mapVal4.put('PSS_Programs_Applicable_Nm__c', 'MRS');
        mapVal4.put('PSS_Programs_Applicable_Nm__c', String.valueOf(surveyResults3.PSS_Programs_Applicable_Nm__c));
        mapVal4.put('PSS_Programs_Applicable_Nm__c', 'IOTG');
        //mapVal4.put('PSS_Programs_Applicable_Nm__c', 'DCG');
        
        PSS_AdminDetailsController.reCalculateImpactPathScoring(surveyResults3.Id, mapVal4);*/
        
        /*surveyResults3.PSS_Programs_Applicable_Nm__c = 'Intel Select';
        update surveyResults3;
        PSS_AdminDetailsController.reCalculateImpactPathScoring(surveyResults3.Id, mapVal4);*/

        /*system.assertEquals(1, 1, 'Offering Created from Solution'); 
        test.stopTest();
    }
    
    @isTest public static void createContactEntitlementTest(){
       ArdiraSurvey__Survey_Result__c surveyResult = [Select id,PSS_Is_Benefit_Assigned_Ind__c,PSS_Programs_Applicable_Nm__c,
                                                        PSS_Conversion_Admin_Log_Details_Txt__c,PSS_Company_Id__c,
                                                        PSS_Partner_Solution_Lifecycle_Status_Nm__c,
                                                        PSS_Solution_Submitter_UserId_Id__c,ArdiraSurvey__Assigned_To_User__c,
                                                        PSS_Intel_Admin_Id__c FROM ArdiraSurvey__Survey_Result__c 
                                                        WHERE PSS_Proposal_Name_Txt__c='TestDuplicateOffering3'];
        test.startTest();
        User usr = [Select Id, Name,UserRole.DeveloperName,UserRoleId from User where IsActive = true and UserRole.DeveloperName LIKE '%PartnerUser' LIMIT 1];
        surveyResult.PSS_Solution_Submitter_UserId_Id__c = usr.Id;
        surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c = PSS_StaticConstants.SOLUTION_CONVERTED_STATUS;
        update surveyResult;
        
        String solutionId = surveyResult.Id;
        system.runAs(usr){
         	PSS_AdminDetailsController.createContactEntitlement(solutionId);
        }
        test.stopTest();
        
    }
    
    @isTest public static void updateContactEntitlementTest(){
    	test.startTest();
        User usr = [Select Id, Name,UserRole.DeveloperName,UserRoleId from User where IsActive = true and UserRole.DeveloperName LIKE '%PartnerUser' LIMIT 1];
        
        Contact c = [Select Id from Contact where LastName = 'portalTestUserv1' LIMIT 1];
        Core_Entitlement__c entitlement = [Select Id from Core_Entitlement__c where Name = 'Offering Editor' LIMIT 1];
        
         Core_Contact_Entitlement__c ccEntitlement = new Core_Contact_Entitlement__c();
            ccEntitlement.Core_Contact_Id__c = c.Id;
            ccEntitlement.Core_Entitlement_Id__c = entitlement.Id;
            ccEntitlement.Core_Selected__c = TRUE;
            ccEntitlement.Core_Status__c = PSS_StaticConstants.ENTITLEMENT_STATUS_PENDING;
            ccEntitlement.Core_Data_Loaded__c = TRUE;
            insert ccEntitlement;
        ArdiraSurvey__Survey_Result__c surveyResult2 = [Select id,PSS_Is_Benefit_Assigned_Ind__c,PSS_Programs_Applicable_Nm__c,
                                                        PSS_Conversion_Admin_Log_Details_Txt__c,PSS_Company_Id__c,
                                                        PSS_Partner_Solution_Lifecycle_Status_Nm__c,
                                                        PSS_Solution_Submitter_UserId_Id__c,ArdiraSurvey__Assigned_To_User__c FROM ArdiraSurvey__Survey_Result__c 
                                                        WHERE PSS_Proposal_Name_Txt__c='TestDuplicateOffering3'];
        
        surveyResult2.PSS_Solution_Submitter_UserId_Id__c = usr.Id;
        surveyResult2.PSS_Partner_Solution_Lifecycle_Status_Nm__c = PSS_StaticConstants.SOLUTION_CONVERTED_STATUS;
        update surveyResult2;
        String solnId = surveyResult2.Id;
        
        system.runAs(usr){
         	PSS_AdminDetailsController.createContactEntitlement(solnId);
        }
    	test.stopTest();
    }*/
    
}