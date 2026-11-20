/****************************************************************************************************************************
Apex Class Name     : PRM_VXUpgRecomListTest 
Version             : 1.0
Created Date        : 02 Apr 2020

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Bharath Kumar       02 Apr 2020                Test class to cover PRM_VXUpgRecomListController class

****************************************************************************************************************************/
@isTest()
public class PRM_VXUpgRecomListTest {
    public static testmethod void getUpgRecListTestMethod(){
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id opidAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id upgRecTypeId = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get('Upgrade/Downgrade').getRecordTypeId();
        
        //Custom Setting 
        PRM_Execution_Controls__c settings = PRM_Execution_Controls__c.getOrgDefaults();
        settings.PRM_Skip_VR_for_OPID_Batch_Ind__c =true;
        insert settings;
        
        List<Account> accList = new List<Account>();
        Account  acc= new Account();
        acc.RecordTypeId = intelAccRecTypeId;
        acc.Name='Johrt Rick';
        acc.BillingCity='City';
        acc.BillingStreet='Street';
        acc.BillingCountry='India';
        acc.BillingPostalCode='Postal code';
        acc.Core_IPA_Partner_Role__c = System.Label.PRM_Service_Provider;
        acc.Core_CNDA_Number__c='';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        accList.add(acc);
        
        Account acc1 = new Account();
        acc1.RecordTypeId = intelAccRecTypeId;
        acc1.Name='Test 2';
        acc1.BillingCity='City';
        acc1.BillingStreet='Street';
        acc1.BillingCountry='India';
        acc1.BillingPostalCode='Postal code';
        acc1.Core_IPA_Partner_Role__c = System.Label.PRM_Service_Provider;
        acc1.Core_CNDA_Number__c='676875764539878';
        acc1.OwnerId = UserInfo.getUserId();
        acc1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        accList.add(acc1);
        
        Account acc2 = new Account();
        acc2.RecordTypeId = opidAccRecTypeId;
        acc2.Name='Test 3';
        acc2.BillingCity='City';
        acc2.BillingStreet='Street';
        acc2.BillingCountry='India';
        acc2.BillingPostalCode='Postal code';
        acc2.Core_IPA_Partner_Role__c = System.Label.PRM_Service_Provider;
        acc2.Core_Account_Type__c='Cloud Service Provider (CSP)';
        accList.add(acc2);
        
        Account acc3 = new Account();
        acc3.RecordTypeId = opidAccRecTypeId;
        acc3.Name='Test 4';
        acc3.BillingCity='City';
        acc3.BillingStreet='Street';
        acc3.BillingCountry='India';
        acc3.BillingPostalCode='Postal code';
        acc3.Core_IPA_Partner_Role__c = System.Label.PRM_Service_Provider;
        acc3.Core_Account_Type__c='Cloud Service Provider (CSP)';
        accList.add(acc3);
        insert accList;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        List<ChannelProgramLevel> cplList =new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        cplList.add(cpl);
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Prestige';
        cpl2.ProgramId=cp.Id;
        cplList.add(cpl2);
        
        
        ChannelProgramLevel cpl3=new ChannelProgramLevel(); //Channel Program Level
        cpl3.Name='Partner';
        cpl3.ProgramId=cp.Id;
        cplList.add(cpl3);
        
        insert cplList;
        
        /*List<PRM_ValueExchange__c> vxList = new List<PRM_ValueExchange__c>();
            PRM_ValueExchange__c vx1 = new PRM_ValueExchange__c();
            vx1.Name = 'Gold-Seller-Mature';
            vx1.PRM_Channel_Program_Level_Id__c =  cplList[1].Id;
            vx1.PRM_Country_Market_Type_Nm__c = 'Mature';
            vx1.PRM_Partner_Role_Nm__c = 'Seller';
            vx1.PRM_Program_Id__c = cp.Id;
            vx1.PRM_Start_Date_Dt__c = System.today();
        	vxList.add(vx1);
        
        	PRM_ValueExchange__c vx2 = new PRM_ValueExchange__c();
            vx2.Name = 'Gold-Manufacturer-Mature';
            vx2.PRM_Channel_Program_Level_Id__c =  cplList[1].Id;
            vx2.PRM_Country_Market_Type_Nm__c = 'Mature';
            vx2.PRM_Partner_Role_Nm__c = 'Manufacturer';
            vx2.PRM_Program_Id__c = cp.Id;
            vx2.PRM_Start_Date_Dt__c = System.today();
        	vxList.add(vx2);
        
        insert vxList; 
        
        List<PRM_Specialty_Criteria__c> specCriteriaList = new List<PRM_Specialty_Criteria__c>();
            PRM_Specialty_Criteria__c specCriteria1 = new PRM_Specialty_Criteria__c();
            specCriteria1.Name = 'Select Benefit';
            specCriteria1.PRM_Start_Date_Dt__c = System.today();
            specCriteria1.PRM_Type_Nm__c = 'Qualitative';
            specCriteriaList.add(specCriteria1);
            
        	PRM_Specialty_Criteria__c specCriteria2 = new PRM_Specialty_Criteria__c();
            specCriteria2.Name = 'Specialty present';
            specCriteria2.PRM_Start_Date_Dt__c = System.today();
            specCriteria2.PRM_Type_Nm__c = 'Qualitative';
            specCriteriaList.add(specCriteria2);    
        
            insert specCriteriaList;
        
        List<PRM_Value_Exchange_Criteria_Association__c> vxCriteriaList = new List<PRM_Value_Exchange_Criteria_Association__c>();
        	PRM_Value_Exchange_Criteria_Association__c vxCriteria1 = new PRM_Value_Exchange_Criteria_Association__c();
            vxCriteria1.PRM_Value_Txt__c = 'IOT Select Benefit';
        	vxCriteria1.PRM_Value_Exchange_Id__c = vxList[0].Id;
            vxCriteria1.PRM_Start_Date_Dt__c = System.today();
            vxCriteria1.PRM_Specialty_Criteria_Id__c = specCriteriaList[0].Id;
        	vxCriteriaList.add(vxCriteria1);
        
        	PRM_Value_Exchange_Criteria_Association__c vxCriteria2 = new PRM_Value_Exchange_Criteria_Association__c();
            vxCriteria2.PRM_Value_Txt__c = 'FPGA Select Benefit';
        	vxCriteria2.PRM_Value_Exchange_Id__c = vxList[0].Id;
            vxCriteria2.PRM_Start_Date_Dt__c = System.today();
            vxCriteria2.PRM_Specialty_Criteria_Id__c = specCriteriaList[0].Id;
        	vxCriteriaList.add(vxCriteria2); 
        
        	PRM_Value_Exchange_Criteria_Association__c vxCriteria3 = new PRM_Value_Exchange_Criteria_Association__c();
            vxCriteria3.PRM_Value_Txt__c = 'Y';
        	vxCriteria3.PRM_Value_Exchange_Id__c = vxList[0].Id;
            vxCriteria3.PRM_Start_Date_Dt__c = System.today();
            vxCriteria3.PRM_Specialty_Criteria_Id__c = specCriteriaList[1].Id;
        	vxCriteriaList.add(vxCriteria3);
        
        insert vxCriteriaList;*/
        
             List<PRM_Value_Exchange_Recommendation__c> vxRecordsList = new List<PRM_Value_Exchange_Recommendation__c>();
                PRM_Value_Exchange_Recommendation__c ver1 = new PRM_Value_Exchange_Recommendation__c();
                ver1.RecordTypeId = upgRecTypeId;
                ver1.PRM_Account_Id__c = accList[0].Id;		//Johrt Rick
                ver1.PRM_One_Partner_Id__c = accList[2].Id;	//Test 3	
                ver1.PRM_Partner_Role_Nm__c = System.Label.PRM_Service_Provider;
                ver1.PRM_Tier_Id__c = cplList[0].Id;		//Member
                ver1.PRM_Market_Type_Nm__c = 'Mature';
                ver1.PRM_Recommendation_Type_Nm__c = 'Upgrade';
                ver1.PRM_Recommendation_Status_Nm__c = 'New';
        		ver1.PRM_Specialty_Present_Nm__c = 'Yes';
        		ver1.PRM_Select_Benefit_Txt__c = 'FPGA Select Benefit,TTM Select Benefit';
        		ver1.PRM_Training_Credit_Points_Count_Nbr__c = 100;
        		ver1.PRM_No_Of_Employees_Done_Training_Nbr__c = 50;
        		ver1.PRM_Number_Of_MP_Solutions_Nbr__c = 200;
        		ver1.PRM_Total_Achieved_Competency_Nbr__c = 50;
        		ver1.PRM_Notes__c = 'Test Notes';
        		ver1.PRM_Account_Plan_Ind__c = false;
        		ver1.PRM_Submitted_Integration_Report_Ind__c = true;
                vxRecordsList.add(ver1);
                
                PRM_Value_Exchange_Recommendation__c ver2 = new PRM_Value_Exchange_Recommendation__c();
                ver2.RecordTypeId = upgRecTypeId;
                ver2.PRM_Account_Id__c = accList[0].Id; 	//Johrt Rick
                ver2.PRM_One_Partner_Id__c = accList[2].Id;	//Test 3
                ver2.PRM_Partner_Role_Nm__c = System.Label.PRM_Service_Provider;
                ver2.PRM_Tier_Id__c = cplList[0].Id;		//Member
                ver2.PRM_Market_Type_Nm__c = 'Mature';
                ver2.PRM_Recommendation_Type_Nm__c = 'Upgrade';
                ver2.PRM_Recommendation_Status_Nm__c = 'New';
        		ver2.PRM_Specialty_Present_Nm__c = 'Yes';
        		ver2.PRM_Select_Benefit_Txt__c = 'SI Select Benefit,IOT Select Benefit';
        		ver2.PRM_Training_Credit_Points_Count_Nbr__c = 10;
        		ver2.PRM_No_Of_Employees_Done_Training_Nbr__c = 15;
        		ver2.PRM_Number_Of_MP_Solutions_Nbr__c = 20;
        		ver2.PRM_Total_Achieved_Competency_Nbr__c = 15;
        		ver2.PRM_Notes__c = 'Test Notes';
        		ver2.PRM_Account_Plan_Ind__c = false;
        		ver2.PRM_Submitted_Integration_Report_Ind__c = true;
                vxRecordsList.add(ver2);
        
                PRM_Value_Exchange_Recommendation__c ver3 = new PRM_Value_Exchange_Recommendation__c();
                ver3.RecordTypeId = upgRecTypeId;
                ver3.PRM_Account_Id__c = accList[0].Id;
                ver3.PRM_One_Partner_Id__c = accList[3].Id;
                ver3.PRM_Partner_Role_Nm__c = System.Label.PRM_Service_Provider;
                ver3.PRM_Tier_Id__c = cplList[1].Id;
                ver3.PRM_Market_Type_Nm__c = 'Mature';
                ver3.PRM_Recommendation_Type_Nm__c = 'Upgrade';
                ver3.PRM_Recommendation_Status_Nm__c = 'New';
        		ver3.PRM_Specialty_Present_Nm__c = 'Yes';
        		ver3.PRM_Select_Benefit_Txt__c = 'SI Select Benefit';
        		ver3.PRM_Training_Credit_Points_Count_Nbr__c = 30;
        		ver3.PRM_No_Of_Employees_Done_Training_Nbr__c = 5;
        		ver3.PRM_Number_Of_MP_Solutions_Nbr__c = 25;
        		ver3.PRM_Total_Achieved_Competency_Nbr__c = 15;
        		ver3.PRM_Notes__c = 'Test Notes';
        		ver3.PRM_Account_Plan_Ind__c = false;
        		ver3.PRM_Submitted_Integration_Report_Ind__c = true;
                vxRecordsList.add(ver3);
        
        		PRM_Value_Exchange_Recommendation__c ver4 = new PRM_Value_Exchange_Recommendation__c();
                ver4.RecordTypeId = upgRecTypeId;
                ver4.PRM_Account_Id__c = accList[1].Id;
                ver4.PRM_One_Partner_Id__c = accList[2].Id;
                ver4.PRM_Partner_Role_Nm__c = System.Label.PRM_Service_Provider;
                ver4.PRM_Tier_Id__c = cplList[0].Id;
                ver4.PRM_Market_Type_Nm__c = 'Mature';
                ver4.PRM_Recommendation_Type_Nm__c = 'Upgrade';
                ver4.PRM_Recommendation_Status_Nm__c = 'New';
        		ver4.PRM_Specialty_Present_Nm__c = 'Yes';
        		ver4.PRM_Select_Benefit_Txt__c = 'IOT Select Benefit';
        		ver4.PRM_Training_Credit_Points_Count_Nbr__c = 10;
        		ver4.PRM_No_Of_Employees_Done_Training_Nbr__c = 15;
        		ver4.PRM_Number_Of_MP_Solutions_Nbr__c = 20;
        		ver4.PRM_Total_Achieved_Competency_Nbr__c = 25;
                vxRecordsList.add(ver4);
        
        		PRM_Value_Exchange_Recommendation__c ver5 = new PRM_Value_Exchange_Recommendation__c();
                ver5.RecordTypeId = upgRecTypeId;
                ver5.PRM_Account_Id__c = accList[1].Id;
                ver5.PRM_One_Partner_Id__c = accList[3].Id;
                ver5.PRM_Partner_Role_Nm__c = System.Label.PRM_Service_Provider;
                ver5.PRM_Tier_Id__c = cplList[1].Id;
                ver5.PRM_Market_Type_Nm__c = 'Mature';
                ver5.PRM_Recommendation_Type_Nm__c = 'Upgrade';
                ver5.PRM_Recommendation_Status_Nm__c = 'New';
        		/*ver4.PRM_Specialty_Present_Nm__c = 'Yes';
        		ver4.PRM_Select_Benefit_Txt__c = 'IOT Select Benefit';
        		ver4.PRM_Training_Credit_Points_Count_Nbr__c = 10;
        		ver4.PRM_No_Of_Employees_Done_Training_Nbr__c = 15;
        		ver4.PRM_Number_Of_MP_Solutions_Nbr__c = 20;
        		ver4.PRM_Total_Achieved_Competency_Nbr__c = 25;*/
                vxRecordsList.add(ver5);
                
                insert vxRecordsList;
        
        Integer mapActualSize = PRM_VXUpgRecomListController.getUpgRecList().parentRecMap.size();
        Integer listActualSize = PRM_VXUpgRecomListController.getUpgRecList().parentRecList.size();
        //System.debug('Size:'+mapActualSize);
       // System.assertEquals(3, mapActualSize);
        //System.assertEquals(3, listActualSize);
        
        //List<PRM_VXUpgRecomListController.UpgradeRecommendationWrapper> upgRecList = PRM_VXUpgRecomListController.getUpgRecList().parentRecList;
        
        //String actualBenefit = upgRecList[0].selectBenefit;
        
        //System.assertEquals('FPGA Select Benefit,IOT Select Benefit', actualBenefit);
        
        //To cover second method fetchChildRecords
        String key = 'Test 3;Distributor;Member;Mature';
        Integer childRecActSize = PRM_VXUpgRecomListController.fetchChildRecords(key).size();
       // System.assertEquals(5, childRecActSize);
        
        List<UpgradeRecommendationWrapper> toUpdateList = new List<UpgradeRecommendationWrapper>();
        UpgradeRecommendationWrapper upgWrap = new UpgradeRecommendationWrapper();
        upgWrap.notes = 'Account Plan';
        upgWrap.accountPlanInd = true;
        upgWrap.submittedIntegReport = false;
        upgWrap.key = 'Test 3;Distributor;Member;Mature';
        toUpdateList.add(upgWrap);
        //to cover updateRecords method
        Boolean actualResult = PRM_VXUpgRecomListController.updateRecords(toUpdateList);
        
        //System.assertEquals(true, actualResult);
        
        //To cover updateStatus method 
        String vxkey = 'Test 3;Distributor;Member;Mature';
        Boolean actResult = PRM_VXUpgRecomListController.updateStatus(vxkey);
        //System.assertEquals(true, actResult);
    }
    
    public with sharing class UpgradeRecommendationWrapper {
        @AuraEnabled public String notes    {set;get;}
        @AuraEnabled public Boolean accountPlanInd  {set;get;}
        @AuraEnabled public Boolean submittedIntegReport  {set;get;}
        @AuraEnabled public String key {set;get;}
    }
}