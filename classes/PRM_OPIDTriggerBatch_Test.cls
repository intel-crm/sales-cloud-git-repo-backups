/***************************************************************************************************************************************
Apex Class Name     : PRM_OPIDTriggerBatch_Test 
Version             : 1.0
Created Date        : March 2020
Function            : Test class for PRM_OPIDTriggerBatch,PRM_Batch_OPID_Trigger_Scheduler.
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Srishty                        13-March-2020                       US599996- Test Class for PRM_OPIDTriggerBatch and PRM_Batch_OPID_Trigger_Scheduler
* Srishty             3-April-2020                US619504-Added Test Data and Test Method for Upgrade Recommendation 
* Srishty             9-April-2020            US617760-Added Test Data for doCalculations Method in PRM_OPIDTriggerBatchUtility that will calculate the total percentage
criteria pending for Next tier for VX Data  
*Srishty                        24-April-2020                       US643150-Added 'Total Nbr Achieved Competency' field and replaced 'Competency Achieved field' from VX data and VX Recommendation 
*Srishty                        8-June-2020                         US687613-Added test data for Qualittaive boolean Fields which is getting updated through batch in Recommendation converted into picklist value. 
*Srishty                        8-June-2020                         DE80439-Added test data Specialty Present Field on VX Recommendation will be "Yes" when corresponding VX Data account ASA record have Specialty type record of same partner Role.                       
*************************************************************************************************************************************/
@isTest
public class PRM_OPIDTriggerBatch_Test {
    @testSetup static void setup(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.PRM_Intel_Account_Record_Type).getRecordTypeId();
        Id recordTypeIdOPIDAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.PRM_ParentAccRecordType).getRecordTypeId();
        Id upgradeDowngradeRecordType = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_Upgrade_Downgrade).getRecordTypeId();
        
        //Test Data for Custom Setting 
        PRM_Execution_Controls__c settings = PRM_Execution_Controls__c.getOrgDefaults();
        settings.PRM_Skip_VR_for_OPID_Batch_Ind__c =true;
        insert settings;
        //Test Data for Accounts
        List<Account> acc = new List<Account>();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        newAccount.Name='Johrt Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_IPA_Partner_Role__c = 'Distributor';
        newAccount.Core_CNDA_Number__c='';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.add(newAccount);
        
        Account newAccount1 = new Account();//Account
        newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        newAccount1.Name='Test 2';
        newAccount1.BillingCity='City';
        newAccount1.BillingStreet='Street';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_IPA_Partner_Role__c = 'Guest';
        newAccount1.Core_CNDA_Number__c='676875764539878';
        newAccount1.OwnerId = UserInfo.getUserId();
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.add(newAccount1);
        
        Account newAccount2 = new Account();//Account
        newAccount2.RecordTypeId = recordTypeIdOPIDAcc;
        newAccount2.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        newAccount2.Name='Test 3';
        newAccount2.BillingCity='City';
        newAccount2.BillingStreet='Street';
        newAccount2.BillingCountry='India';
        newAccount2.BillingPostalCode='Postal code';
        newAccount2.Core_IPA_Partner_Role__c = 'Guest';
        newAccount2.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.add(newAccount2);
        
        Account newAccount3 = new Account();//Account
        newAccount3.RecordTypeId = recordTypeIdOPIDAcc;
        newAccount3.Name='Test 4';
        newAccount3.BillingCity='City';
        newAccount3.BillingStreet='Street';
        newAccount3.BillingCountry='India';
        newAccount3.BillingPostalCode='Postal code';
        newAccount3.Core_IPA_Partner_Role__c = 'Solution Integrator';
        newAccount3.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.add(newAccount3);
        insert acc;    
        
        
        //Test Data for Program
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        //Test Data for Tier
        List<ChannelProgramLevel> cplList =new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        cplList.add(cpl);
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Gold';
        cpl2.ProgramId=cp.Id;
        cplList.add(cpl2);
        
        
        ChannelProgramLevel cpl3=new ChannelProgramLevel(); //Channel Program Level
        cpl3.Name='Titanium';
        cpl3.ProgramId=cp.Id;
        cplList.add(cpl3);
        
        insert cplList;
        
        PRM_Specialty__c selectBenefit1 = new PRM_Specialty__c();//Select Benefit
        selectBenefit1.Name = 'Addition Select Benefit';
        selectBenefit1.RecordTypeId=Schema.SObjectType.PRM_Specialty__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_SelectBenefits).getRecordTypeId();
        selectBenefit1.PRM_Description_Txt__c = 'Industrial Specialty Benefit';
        selectBenefit1.PRM_Access_Level_Nm__c = 'public';
        selectBenefit1.PRM_Funding_BU_Nm__c = 'CCG Sales Group';
        selectBenefit1.PRM_Role_Nm__c = 'Guest';
        selectBenefit1.PRM_Tier_Nm__c = 'Gold';
        selectBenefit1.PRM_Start_Date_Dt__c = system.today();
        insert selectBenefit1;
        
        
        PRM_Specialty__c specialty1 = new PRM_Specialty__c();//Specialty
        specialty1.name='Select Benefits';
        specialty1.RecordTypeId=Schema.SObjectType.PRM_Specialty__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_SelectBenefits).getRecordTypeId();
        specialty1.PRM_Description_Txt__c = 'Industrial Specialty Benefit';
        specialty1.PRM_Access_Level_Nm__c = 'public';
        specialty1.PRM_Funding_BU_Nm__c = 'CCG Sales Group';
        specialty1.PRM_Role_Nm__c = 'Guest';
        specialty1.PRM_Tier_Nm__c = 'Gold';
        specialty1.PRM_Start_Date_Dt__c = system.today();
        insert specialty1;
        PRM_Account_Specialty_Association__c selectBenefitAsa = new PRM_Account_Specialty_Association__c();//asa for select benefit
        selectBenefitAsa.PRM_Account_Id__c = acc[1].Id;
        selectBenefitAsa.PRM_Specialty_Id__c = selectBenefit1.Id;
        selectBenefitAsa.PRM_Partner_Role__c = 'Guest';
        selectBenefitAsa.PRM_InActive_Ind__c = false;
        insert selectBenefitAsa;
        PRM_Account_Specialty_Association__c specialtyAsa = new PRM_Account_Specialty_Association__c();//asa record for specialty
        specialtyAsa.PRM_Account_Id__c = acc[1].Id;
        specialtyAsa.PRM_Specialty_Id__c = specialty1.Id;
        specialtyAsa.PRM_Partner_Role__c = 'Guest';
        specialtyAsa.PRM_InActive_Ind__c = false;
        insert specialtyAsa;
        
        //Test Data for Criterias
        PRM_Specialty_Criteria__c specCriteria = new PRM_Specialty_Criteria__c();
        specCriteria.Name = 'Sales';
        specCriteria.PRM_Start_Date_Dt__c = System.today();
        specCriteria.PRM_Type_Nm__c = 'Quantitative';
        insert specCriteria;
        
        PRM_Specialty_Criteria__c specCriteria1 = new PRM_Specialty_Criteria__c();
        specCriteria1.Name = 'Training Credits';
        specCriteria1.PRM_Start_Date_Dt__c = System.today();
        specCriteria1.PRM_Type_Nm__c = 'Quantitative';
        insert specCriteria1;
        
        PRM_Specialty_Criteria__c specCriteria2 = new PRM_Specialty_Criteria__c();
        specCriteria2.Name = 'Minimum Number of employees doing the training';
        specCriteria2.PRM_Start_Date_Dt__c = System.today();
        specCriteria2.PRM_Type_Nm__c = 'Quantitative';
        insert specCriteria2;
        
        PRM_Specialty_Criteria__c specCriteria3 = new PRM_Specialty_Criteria__c();
        specCriteria3.Name = 'Total Nbr Achieved Competency';
        specCriteria3.PRM_Start_Date_Dt__c = System.today();
        specCriteria3.PRM_Type_Nm__c = 'Quantitative';
        insert specCriteria3;
        
        PRM_Specialty_Criteria__c specCriteria4 = new PRM_Specialty_Criteria__c();
        specCriteria4.Name = 'FPGA Project Registrations';
        specCriteria4.PRM_Start_Date_Dt__c = System.today();
        specCriteria4.PRM_Type_Nm__c = 'Quantitative';
        insert specCriteria4;
        
        PRM_Specialty_Criteria__c specCriteria5 = new PRM_Specialty_Criteria__c();
        specCriteria5.Name = 'Number of Solutions in Mplace';
        specCriteria5.PRM_Start_Date_Dt__c = System.today();
        specCriteria5.PRM_Type_Nm__c = 'Quantitative';
        insert specCriteria5;
        
        
        PRM_Specialty_Criteria__c specCriteria6 = new PRM_Specialty_Criteria__c();
        specCriteria6.Name = 'Type of solutions';
        specCriteria6.PRM_Start_Date_Dt__c = System.today();
        specCriteria6.PRM_Type_Nm__c = 'Qualitative';
        insert specCriteria6;
        
        PRM_Specialty_Criteria__c specCriteria7 = new PRM_Specialty_Criteria__c();
        specCriteria7.Name = 'CNDA';
        specCriteria7.PRM_Start_Date_Dt__c = System.today();
        specCriteria7.PRM_Type_Nm__c = 'Qualitative';
        insert specCriteria7;
        
        PRM_Specialty_Criteria__c specCriteria8 = new PRM_Specialty_Criteria__c();
        specCriteria8.Name = 'Account Coverage';
        specCriteria8.PRM_Start_Date_Dt__c = System.today();
        specCriteria8.PRM_Type_Nm__c = 'Qualitative';
        insert specCriteria8;
        
        PRM_Specialty_Criteria__c specCriteria9 = new PRM_Specialty_Criteria__c();
        specCriteria9.Name = 'Sumbitted Integration Report';
        specCriteria9.PRM_Start_Date_Dt__c = System.today();
        specCriteria9.PRM_Type_Nm__c = 'Qualitative';
        insert specCriteria9;
        
        PRM_Specialty_Criteria__c specCriteria10 = new PRM_Specialty_Criteria__c();
        specCriteria10.Name = 'Select Benefit';
        specCriteria10.PRM_Start_Date_Dt__c = System.today();
        specCriteria10.PRM_Type_Nm__c = 'Qualitative';
        insert specCriteria10;
        
        PRM_Specialty_Criteria__c specCriteria11 = new PRM_Specialty_Criteria__c();
        specCriteria11.Name = 'Specialty present';
        specCriteria11.PRM_Start_Date_Dt__c = System.today();
        specCriteria11.PRM_Type_Nm__c = 'Qualitative';
        insert specCriteria11;
        //Test Data for Value Exchange Data
        PRM_Value_Exchange_Data__c vxData1 = new PRM_Value_Exchange_Data__c();
        vxData1.PRM_Sales_Amount_Nbr__c = 2000000;
        vxData1.PRM_Account_Id__c = acc[0].Id;
        vxData1.PRM_One_Partner_Id__c = acc[2].Id;
        vxData1.PRM_Tier_Id__c = cplList[0].Id;
        vxData1.PRM_Partner_Role_Nm__c = 'Solution Integrator';
        vxData1.PRM_Country_Market_Type_Nm__c = 'Emerging';
        vxData1.PRM_Training_Credit_Points_Count_Nbr__c=50;
        vxData1.PRM_Change_Date_Dt__c = System.today();
        vxData1.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData1.PRM_To_Dt__c =Date.Today();
        vxData1.PRM_TimePeriod_Nm__c = Label.PRM_Previous_Measurement_Period ;
        insert vxData1;
        
        PRM_Value_Exchange_Data__c vxData2 = new PRM_Value_Exchange_Data__c();
        vxData2.PRM_Sales_Amount_Nbr__c = 1900000;
        vxData2.PRM_Account_Id__c = acc[1].Id;
        vxData2.PRM_One_Partner_Id__c = acc[2].Id;
        vxData2.PRM_Tier_Id__c = cplList[0].Id;
        vxData2.PRM_Partner_Role_Nm__c = 'Solution Integrator';
        vxData2.PRM_Country_Market_Type_Nm__c = 'Mature';
        vxData2.PRM_Change_Date_Dt__c = System.today();
        vxData2.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData2.PRM_To_Dt__c =Date.Today();
        vxData2.PRM_TimePeriod_Nm__c = Label.PRM_Current_measurement_period ;
        insert vxData2;
        
        PRM_Value_Exchange_Data__c vxData3 = new PRM_Value_Exchange_Data__c();
        vxData3.PRM_Sales_Amount_Nbr__c = 1000000;
        vxData3.PRM_Account_Id__c = acc[1].Id;
        vxData3.PRM_Tier_Id__c = cplList[0].Id;
        vxData3.PRM_Partner_Role_Nm__c = 'Distributor';
        vxData3.PRM_Country_Market_Type_Nm__c = 'Mature';
        vxData3.PRM_Change_Date_Dt__c = System.today();
        vxData3.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData3.PRM_To_Dt__c =Date.Today();
        vxData3.PRM_TimePeriod_Nm__c = Label.PRM_Previous_Measurement_Period ;
        insert vxData3;
        
        PRM_Value_Exchange_Data__c vxData4 = new PRM_Value_Exchange_Data__c();
        vxData4.PRM_Sales_Amount_Nbr__c = 1000000;
        vxData4.PRM_Account_Id__c = acc[1].Id;
        vxData4.PRM_Tier_Id__c = cplList[0].Id;
        vxData4.PRM_Partner_Role_Nm__c = 'Distributor';
        vxData4.PRM_Country_Market_Type_Nm__c = 'Emerging';
        vxData4.PRM_Sales_Calculation_Group_Txt__c='PRC SMS';
        vxData4.PRM_Change_Date_Dt__c = System.today();
        vxData4.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData4.PRM_To_Dt__c =Date.Today();
        vxData4.PRM_TimePeriod_Nm__c = Label.PRM_Current_measurement_period ;
        insert vxData4;
        
        PRM_Value_Exchange_Data__c vxData5 = new PRM_Value_Exchange_Data__c();
        vxData5.PRM_Sales_Amount_Nbr__c = 2000000;
        vxData5.PRM_Account_Id__c = acc[1].Id;
        vxData5.PRM_Tier_Id__c = cplList[0].Id;
        vxData5.PRM_Partner_Role_Nm__c = 'Distributor';
        vxData5.PRM_Country_Market_Type_Nm__c = 'Emerging';
        vxData5.PRM_Change_Date_Dt__c = System.today();
        vxData5.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData5.PRM_To_Dt__c =Date.Today();
        insert vxData5;
        
        PRM_Value_Exchange_Data__c vxData6 = new PRM_Value_Exchange_Data__c();
        vxData6.PRM_Sales_Amount_Nbr__c = 6000000;
        vxData6.PRM_One_Partner_Id__c=acc[2].Id;
        vxData6.PRM_Account_Id__c = acc[1].Id;
        vxData6.PRM_Tier_Id__c = cplList[0].Id;
        vxData6.PRM_Partner_Role_Nm__c = 'Guest';
        vxData6.PRM_Country_Market_Type_Nm__c = 'Mature';
        vxData6.PRM_Total_Achieved_Competency_Nbr__c=6;
        vxData6.PRM_Training_Credit_Points_Count_Nbr__c=100;
        vxData6.PRM_Design_Registration_Count_Nbr__c=6;
        vxData6.PRM_Type_Of_Solutions_Txt__c='TTM Platform';
        vxData6.PRM_Number_Of_Employees_Nbr__c=6; 
        vxData6.PRM_MP_Solutions_Count_Nbr__c = 4;
        vxData6.PRM_Change_Date_Dt__c = System.today();
        vxData6.PRM_Sales_Calculation_Group_Txt__c='ChAMP';
        vxData6.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData6.PRM_To_Dt__c =Date.Today();
        insert vxData6;
        
        PRM_Value_Exchange_Data__c vxData7 = new PRM_Value_Exchange_Data__c();
        vxData7.PRM_Sales_Amount_Nbr__c = 6000000;
        vxData7.PRM_One_Partner_Id__c=acc[3].Id;
        vxData7.PRM_Account_Id__c = acc[0].Id;
        vxData7.PRM_Tier_Id__c = cplList[1].Id;
        vxData7.PRM_Partner_Role_Nm__c = 'Guest';
        vxData7.PRM_Country_Market_Type_Nm__c = 'Emerging';
        vxData7.PRM_Total_Achieved_Competency_Nbr__c=100;
        vxData7.PRM_Training_Credit_Points_Count_Nbr__c=300;
        vxData7.PRM_Design_Registration_Count_Nbr__c=600;
        vxData7.PRM_MP_Solutions_Count_Nbr__c=100;
        vxData7.PRM_Type_Of_Solutions_Txt__c='RTMSTG';
        vxData7.PRM_Number_Of_Employees_Nbr__c=300;   
        vxData7.PRM_Change_Date_Dt__c = System.today();
        vxData7.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData7.PRM_To_Dt__c =Date.Today();
        insert vxData7;
        
        PRM_Value_Exchange_Data__c vxData8 = new PRM_Value_Exchange_Data__c();
        vxData8.PRM_One_Partner_Id__c=acc[2].Id;
        vxData8.PRM_Account_Id__c = acc[1].Id;
        vxData8.PRM_Tier_Id__c = cplList[1].Id;
        vxData8.PRM_Partner_Role_Nm__c = 'Guest';
        vxData8.PRM_Country_Market_Type_Nm__c = 'Mature';
        vxData8.PRM_Total_Achieved_Competency_Nbr__c=1;
        vxData8.PRM_Change_Date_Dt__c = System.today();
        vxData8.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData8.PRM_To_Dt__c =Date.Today();
        insert vxData8;
        
        PRM_Value_Exchange_Data__c vxData9 = new PRM_Value_Exchange_Data__c();
        vxData9.PRM_Sales_Amount_Nbr__c = 2000000;
        vxData9.PRM_One_Partner_Id__c=acc[2].Id;
        vxData9.PRM_Account_Id__c = acc[1].Id;
        vxData9.PRM_Tier_Id__c = cplList[0].Id;
        vxData9.PRM_Partner_Role_Nm__c = 'Distributor';
        vxData9.PRM_Country_Market_Type_Nm__c = 'Mature';
        vxData9.PRM_Change_Date_Dt__c = System.today();
        vxData9.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData9.PRM_To_Dt__c =Date.Today();
        insert vxData9;
        
        PRM_Value_Exchange_Data__c vxData10 = new PRM_Value_Exchange_Data__c();
        vxData10.PRM_One_Partner_Id__c=acc[3].Id;
        vxData10.PRM_Account_Id__c = acc[1].Id;
        vxData10.PRM_Tier_Id__c = cplList[1].Id;
        vxData10.PRM_Partner_Role_Nm__c = 'Solution Integrator';
        vxData10.PRM_Country_Market_Type_Nm__c = 'Mature';
        vxData10.PRM_Total_Achieved_Competency_Nbr__c=1;
        vxData10.PRM_Training_Credit_Points_Count_Nbr__c=50;
        vxData10.PRM_Sales_Amount_Nbr__c=50000;
        vxData10.PRM_Design_Registration_Count_Nbr__c=3;
        vxData10.PRM_Number_Of_Employees_Nbr__c=4;
        vxData10.PRM_MP_Solutions_Count_Nbr__c=4;
        vxData10.PRM_Change_Date_Dt__c = System.today();
        vxData10.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData10.PRM_To_Dt__c =Date.Today();
        insert vxData10;
        
        PRM_Value_Exchange_Data__c vxData11 = new PRM_Value_Exchange_Data__c();
        vxData11.PRM_Sales_Amount_Nbr__c = 6000000;
        vxData11.PRM_One_Partner_Id__c=acc[2].Id;
        vxData11.PRM_Account_Id__c = acc[1].Id;
        vxData11.PRM_Tier_Id__c = cplList[0].Id;
        vxData11.PRM_Partner_Role_Nm__c = 'Guest';
        vxData11.PRM_Country_Market_Type_Nm__c = 'Mature';
        vxData11.PRM_Total_Achieved_Competency_Nbr__c=5;
        vxData11.PRM_Training_Credit_Points_Count_Nbr__c=150;
        vxData11.PRM_Design_Registration_Count_Nbr__c=6;
        vxData11.PRM_Type_Of_Solutions_Txt__c='TTM Platform';
        vxData11.PRM_Number_Of_Employees_Nbr__c=5; 
        vxData11.PRM_MP_Solutions_Count_Nbr__c = 4;
        vxData11.PRM_Change_Date_Dt__c = System.today();
        vxData11.PRM_Sales_Calculation_Group_Txt__c='Direct';
        vxData11.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData11.PRM_To_Dt__c =Date.Today();
        insert vxData11;
        
        //Test Data for Value Exchange 
        PRM_ValueExchange__c vx1 = new PRM_ValueExchange__c();
        vx1.Name = 'Gold-Solution Integrator-Emerging';
        vx1.PRM_Channel_Program_Level_Id__c =  cplList[1].Id;
        vx1.PRM_Country_Market_Type_Nm__c = 'NA';
        vx1.PRM_Partner_Role_Nm__c = 'Solution Integrator';
        vx1.PRM_Program_Id__c = cp.Id;
        vx1.PRM_Start_Date_Dt__c = System.today();
        insert vx1;
        
        PRM_ValueExchange__c vx2 = new PRM_ValueExchange__c();
        vx2.Name = 'Gold-Solution Integrator-Mature';
        vx2.PRM_Channel_Program_Level_Id__c =  cplList[1].Id;
        vx2.PRM_Country_Market_Type_Nm__c = 'Mature';
        vx2.PRM_Partner_Role_Nm__c = 'Solution Integrator';
        vx2.PRM_Program_Id__c = cp.Id;
        vx2.PRM_Start_Date_Dt__c = System.today();
        insert vx2;
        
        PRM_ValueExchange__c vx3 = new PRM_ValueExchange__c();
        vx3.Name = 'Gold-Seller-Mature';
        vx3.PRM_Channel_Program_Level_Id__c =cplList[1].Id;
        vx3.PRM_Country_Market_Type_Nm__c = 'Mature';
        vx3.PRM_Partner_Role_Nm__c = 'Distributor';
        vx3.PRM_Program_Id__c = cp.Id;
        vx3.PRM_Start_Date_Dt__c = System.today();
        insert vx3;
        
        PRM_ValueExchange__c vx4 = new PRM_ValueExchange__c();
        vx4.Name = 'Gold-Seller-Emerging';
        vx4.PRM_Channel_Program_Level_Id__c =cplList[1].Id;
        vx4.PRM_Country_Market_Type_Nm__c = 'Emerging';
        vx4.PRM_Partner_Role_Nm__c = 'Distributor';
        vx4.PRM_Program_Id__c = cp.Id;
        vx4.PRM_Start_Date_Dt__c = System.today();
        insert vx4;
        
        PRM_ValueExchange__c vx5 = new PRM_ValueExchange__c();
        vx5.Name = 'Gold-Distributor-Emerging';
        vx5.PRM_Channel_Program_Level_Id__c =  cplList[1].Id;
        vx5.PRM_Country_Market_Type_Nm__c = 'NA';
        vx5.PRM_Partner_Role_Nm__c = 'Distributor';
        vx5.PRM_Program_Id__c = cp.Id;
        vx5.PRM_Start_Date_Dt__c = System.today();
        insert vx5;
        
        PRM_ValueExchange__c vx6 = new PRM_ValueExchange__c();
        vx6.Name = 'Gold-Guest-Mature';
        vx6.PRM_Channel_Program_Level_Id__c =  cplList[1].Id;
        vx6.PRM_Country_Market_Type_Nm__c = 'NA';
        vx6.PRM_Partner_Role_Nm__c = 'Guest';
        vx6.PRM_Program_Id__c = cp.Id;
        vx6.PRM_Start_Date_Dt__c = System.today();
        insert vx6;
        
        PRM_ValueExchange__c vx7 = new PRM_ValueExchange__c();
        vx7.Name = 'Titanium-Guest-Emerging';
        vx7.PRM_Channel_Program_Level_Id__c =  cplList[2].Id;
        vx7.PRM_Country_Market_Type_Nm__c = 'NA';
        vx7.PRM_Partner_Role_Nm__c = 'Guest';
        vx7.PRM_Program_Id__c = cp.Id;
        vx7.PRM_Start_Date_Dt__c = System.today();
        insert vx7;
        
        PRM_ValueExchange__c vx8 = new PRM_ValueExchange__c();
        vx8.Name = 'Titanium-Guest-Mature';
        vx8.PRM_Channel_Program_Level_Id__c =  cplList[2].Id;
        vx8.PRM_Country_Market_Type_Nm__c = 'Mature';
        vx8.PRM_Partner_Role_Nm__c = 'Guest';
        vx8.PRM_Program_Id__c = cp.Id;
        vx8.PRM_Start_Date_Dt__c = System.today();
        insert vx8;
        
        PRM_ValueExchange__c vx9 = new PRM_ValueExchange__c();
        vx9.Name = 'Titanium-Solution Integrator-Mature';
        vx9.PRM_Channel_Program_Level_Id__c =  cplList[2].Id;
        vx9.PRM_Country_Market_Type_Nm__c = 'Mature';
        vx9.PRM_Partner_Role_Nm__c = 'Solution Integrator';
        vx9.PRM_Program_Id__c = cp.Id;
        vx9.PRM_Start_Date_Dt__c = System.today();
        insert vx9;
        //Test Data for Value Exchange CriteriasAssociation
        List<PRM_Value_Exchange_Criteria_Association__c> vxCriteriaList =new List<PRM_Value_Exchange_Criteria_Association__c>();
        PRM_Value_Exchange_Criteria_Association__c vxCriteria1 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria1.PRM_Value_Txt__c = '2000000.0';
        vxCriteria1.PRM_Value_Exchange_Id__c = vx1.Id;
        vxCriteria1.PRM_Start_Date_Dt__c = System.today();
        vxCriteria1.PRM_Specialty_Criteria_Id__c = specCriteria.Id;
        vxCriteria1.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria1);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria2 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria2.PRM_Value_Txt__c = '2000000.0';
        vxCriteria2.PRM_Value_Exchange_Id__c = vx2.Id;
        vxCriteria2.PRM_Start_Date_Dt__c = System.today();
        vxCriteria2.PRM_Specialty_Criteria_Id__c = specCriteria.Id;
        vxCriteria2.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria2);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria3 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria3.PRM_Value_Txt__c = '2000000.0';
        vxCriteria3.PRM_Value_Exchange_Id__c = vx3.Id;
        vxCriteria3.PRM_Start_Date_Dt__c = System.today();
        vxCriteria3.PRM_Specialty_Criteria_Id__c = specCriteria.Id;
        vxCriteria3.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria3);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria4 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria4.PRM_Value_Txt__c = '2000000.0';
        vxCriteria4.PRM_Value_Exchange_Id__c = vx4.Id;
        vxCriteria4.PRM_Start_Date_Dt__c = System.today();
        vxCriteria4.PRM_Specialty_Criteria_Id__c = specCriteria.Id;
        vxCriteria4.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria4);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria5 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria5.PRM_Value_Txt__c = '2000000.0';
        vxCriteria5.PRM_Value_Exchange_Id__c = vx5.Id;
        vxCriteria5.PRM_Start_Date_Dt__c = System.today();
        vxCriteria5.PRM_Specialty_Criteria_Id__c = specCriteria.Id;
        vxCriteria5.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria5);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria6 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria6.PRM_Value_Txt__c = '6000000.0';
        vxCriteria6.PRM_Value_Exchange_Id__c = vx6.Id;
        vxCriteria6.PRM_Start_Date_Dt__c = System.today();
        vxCriteria6.PRM_Specialty_Criteria_Id__c = specCriteria.Id;
        vxCriteria6.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria6);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria7 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria7.PRM_Value_Txt__c = '100';
        vxCriteria7.PRM_Value_Exchange_Id__c = vx6.Id;
        vxCriteria7.PRM_Start_Date_Dt__c = System.today();
        vxCriteria7.PRM_Specialty_Criteria_Id__c = specCriteria1.Id;
        vxCriteria7.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria7);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria8 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria8.PRM_Value_Txt__c ='1';
        vxCriteria8.PRM_Value_Exchange_Id__c = vx6.Id;
        vxCriteria8.PRM_Start_Date_Dt__c = System.today();
        vxCriteria8.PRM_Specialty_Criteria_Id__c = specCriteria3.Id;
        vxCriteria8.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria8);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria9 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria9.PRM_Value_Txt__c = '2';
        vxCriteria9.PRM_Value_Exchange_Id__c = vx6.Id;
        vxCriteria9.PRM_Start_Date_Dt__c = System.today();
        vxCriteria9.PRM_Specialty_Criteria_Id__c = specCriteria2.Id;
        vxCriteria9.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria9);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria10 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria10.PRM_Value_Txt__c = '4';
        vxCriteria10.PRM_Value_Exchange_Id__c = vx6.Id;
        vxCriteria10.PRM_Start_Date_Dt__c = System.today();
        vxCriteria10.PRM_Specialty_Criteria_Id__c = specCriteria4.Id;
        vxCriteria10.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria10);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria11 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria11.PRM_Value_Txt__c = '2';
        vxCriteria11.PRM_Value_Exchange_Id__c = vx6.Id;
        vxCriteria11.PRM_Start_Date_Dt__c = System.today();
        vxCriteria11.PRM_Specialty_Criteria_Id__c = specCriteria5.Id;
        vxCriteria11.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria11);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria12 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria12.PRM_Value_Txt__c = 'TTM Platform,IOT-MRS,RRK';
        vxCriteria12.PRM_Value_Exchange_Id__c = vx6.Id;
        vxCriteria12.PRM_Start_Date_Dt__c = System.today();
        vxCriteria12.PRM_Specialty_Criteria_Id__c = specCriteria6.Id;
        vxCriteria12.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria12);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria13 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria13.PRM_Value_Txt__c = 'Y';
        vxCriteria13.PRM_Value_Exchange_Id__c = vx6.Id;
        vxCriteria13.PRM_Start_Date_Dt__c = System.today();
        vxCriteria13.PRM_Specialty_Criteria_Id__c = specCriteria7.Id;
        vxCriteria13.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria13);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria14 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria14.PRM_Value_Txt__c = 'Y';
        vxCriteria14.PRM_Value_Exchange_Id__c = vx6.Id;
        vxCriteria14.PRM_Start_Date_Dt__c = System.today();
        vxCriteria14.PRM_Specialty_Criteria_Id__c = specCriteria8.Id;
        vxCriteria14.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria14);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria32 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria32.PRM_Value_Txt__c = 'Y';
        vxCriteria32.PRM_Value_Exchange_Id__c = vx6.Id;
        vxCriteria32.PRM_Start_Date_Dt__c = System.today();
        vxCriteria32.PRM_Specialty_Criteria_Id__c = specCriteria11.Id;
        vxCriteria32.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria32);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria33 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria33.PRM_Value_Txt__c = 'High Performance Computing Data Center Specialty';
        vxCriteria33.PRM_Value_Exchange_Id__c = vx6.Id;
        vxCriteria33.PRM_Start_Date_Dt__c = System.today();
        vxCriteria33.PRM_Specialty_Criteria_Id__c = specCriteria10.Id;
        vxCriteria33.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria33);
        
        //for Negative test data
        PRM_Value_Exchange_Criteria_Association__c vxCriteria15 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria15.PRM_Value_Txt__c = '6000000';
        vxCriteria15.PRM_Value_Exchange_Id__c = vx7.Id;
        vxCriteria15.PRM_Start_Date_Dt__c = System.today();
        vxCriteria15.PRM_Specialty_Criteria_Id__c = specCriteria.Id;
        vxCriteria15.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria15);
        
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria16 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria16.PRM_Value_Txt__c = '100';
        vxCriteria16.PRM_Value_Exchange_Id__c = vx7.Id;
        vxCriteria16.PRM_Start_Date_Dt__c = System.today();
        vxCriteria16.PRM_Specialty_Criteria_Id__c = specCriteria1.Id;
        vxCriteria16.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria16);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria17 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria17.PRM_Value_Txt__c ='1';
        vxCriteria17.PRM_Value_Exchange_Id__c = vx7.Id;
        vxCriteria17.PRM_Start_Date_Dt__c = System.today();
        vxCriteria17.PRM_Specialty_Criteria_Id__c = specCriteria3.Id;
        vxCriteria17.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria17);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria18 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria18.PRM_Value_Txt__c = '2';
        vxCriteria18.PRM_Value_Exchange_Id__c = vx7.Id;
        vxCriteria18.PRM_Start_Date_Dt__c = System.today();
        vxCriteria18.PRM_Specialty_Criteria_Id__c = specCriteria2.Id;
        vxCriteria18.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria18);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria19 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria19.PRM_Value_Txt__c = '4';
        vxCriteria19.PRM_Value_Exchange_Id__c = vx7.Id;
        vxCriteria19.PRM_Start_Date_Dt__c = System.today();
        vxCriteria19.PRM_Specialty_Criteria_Id__c = specCriteria4.Id;
        vxCriteria19.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria19);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria20 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria20.PRM_Value_Txt__c = '2';
        vxCriteria20.PRM_Value_Exchange_Id__c = vx7.Id;
        vxCriteria20.PRM_Start_Date_Dt__c = System.today();
        vxCriteria20.PRM_Specialty_Criteria_Id__c = specCriteria5.Id;
        vxCriteria20.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria20);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria21 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria21.PRM_Value_Txt__c = 'TTM Platform,IOT-MRS,RRK';
        vxCriteria21.PRM_Value_Exchange_Id__c = vx7.Id;
        vxCriteria21.PRM_Start_Date_Dt__c = System.today();
        vxCriteria21.PRM_Specialty_Criteria_Id__c = specCriteria6.Id;
        vxCriteria21.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria21);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria22 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria22.PRM_Value_Txt__c = 'Y';
        vxCriteria22.PRM_Value_Exchange_Id__c = vx7.Id;
        vxCriteria22.PRM_Start_Date_Dt__c = System.today();
        vxCriteria22.PRM_Specialty_Criteria_Id__c = specCriteria7.Id;
        vxCriteria22.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria22);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria23 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria23.PRM_Value_Txt__c = 'Y';
        vxCriteria23.PRM_Value_Exchange_Id__c = vx7.Id;
        vxCriteria23.PRM_Start_Date_Dt__c = System.today();
        vxCriteria23.PRM_Specialty_Criteria_Id__c = specCriteria8.Id;
        vxCriteria23.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria23);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria24 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria24.PRM_Value_Txt__c = 'Y';
        vxCriteria24.PRM_Value_Exchange_Id__c = vx6.Id;
        vxCriteria24.PRM_Start_Date_Dt__c = System.today();
        vxCriteria24.PRM_Specialty_Criteria_Id__c = specCriteria9.Id;
        vxCriteria24.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria24);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria25 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria25.PRM_Value_Txt__c = '1';
        vxCriteria25.PRM_Value_Exchange_Id__c = vx8.Id;
        vxCriteria25.PRM_Start_Date_Dt__c = System.today();
        vxCriteria25.PRM_Specialty_Criteria_Id__c = specCriteria3.Id;
        vxCriteria25.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria25);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria26 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria26.PRM_Value_Txt__c ='80000';
        vxCriteria26.PRM_Value_Exchange_Id__c = vx9.Id;
        vxCriteria26.PRM_Start_Date_Dt__c = System.today();
        vxCriteria26.PRM_Specialty_Criteria_Id__c = specCriteria.Id;
        vxCriteria26.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria26);
        
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria27 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria27.PRM_Value_Txt__c ='100';
        vxCriteria27.PRM_Value_Exchange_Id__c = vx9.Id;
        vxCriteria27.PRM_Start_Date_Dt__c = System.today();
        vxCriteria27.PRM_Specialty_Criteria_Id__c = specCriteria1.Id;
        vxCriteria27.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria27);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria28 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria28.PRM_Value_Txt__c ='6';
        vxCriteria28.PRM_Value_Exchange_Id__c = vx9.Id;
        vxCriteria28.PRM_Start_Date_Dt__c = System.today();
        vxCriteria28.PRM_Specialty_Criteria_Id__c = specCriteria2.Id;
        vxCriteria28.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria28);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria29 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria29.PRM_Value_Txt__c ='5';
        vxCriteria29.PRM_Value_Exchange_Id__c = vx9.Id;
        vxCriteria29.PRM_Start_Date_Dt__c = System.today();
        vxCriteria29.PRM_Specialty_Criteria_Id__c = specCriteria4.Id;
        vxCriteria29.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria29);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria30 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria30.PRM_Value_Txt__c ='6';
        vxCriteria30.PRM_Value_Exchange_Id__c = vx9.Id;
        vxCriteria30.PRM_Start_Date_Dt__c = System.today();
        vxCriteria30.PRM_Specialty_Criteria_Id__c = specCriteria5.Id;
        vxCriteria30.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria30);
        
        PRM_Value_Exchange_Criteria_Association__c vxCriteria31 = new PRM_Value_Exchange_Criteria_Association__c();
        vxCriteria31.PRM_Value_Txt__c = '100';
        vxCriteria31.PRM_Value_Exchange_Id__c = vx1.Id;
        vxCriteria31.PRM_Start_Date_Dt__c = System.today();
        vxCriteria31.PRM_Specialty_Criteria_Id__c = specCriteria1.Id;
        vxCriteria31.PRM_Rank_Nbr__c=1;
        vxCriteriaList.add(vxCriteria31);
        
        insert  vxCriteriaList;
        
        //Test Data for Recommnedations    
        List<PRM_Value_Exchange_Recommendation__c> vxRecommnedationList = new List<PRM_Value_Exchange_Recommendation__c>();
        PRM_Value_Exchange_Recommendation__c vxRecommnedation1 = new PRM_Value_Exchange_Recommendation__c();
        vxRecommnedation1.PRM_Account_Id__c=acc[1].Id;
        vxRecommnedation1.PRM_Tier_Id__c=cplList[0].Id;
        vxRecommnedation1.PRM_Recommendation_Status_Nm__c = PRM_OPIDTriggerBatchUtility.RECOMMENDATION_STATUS_NEW;
        vxRecommnedation1.PRM_Partner_Role_Nm__c='Solution Integrator';
        vxRecommnedation1.PRM_Market_Type_Nm__c='NA';
        vxRecommnedation1.PRM_Grouping_Method_Nm__c='GEO';
        vxRecommnedation1.RecordTypeId=upgradeDowngradeRecordType;
        //insert vxRecommnedation1;
        vxRecommnedationList.add(vxRecommnedation1);
        
        PRM_Value_Exchange_Recommendation__c vxRecommnedation2 = new PRM_Value_Exchange_Recommendation__c();
        vxRecommnedation2.PRM_Account_Id__c=acc[1].Id;
        vxRecommnedation2.PRM_Tier_Id__c=cplList[0].Id;
        vxRecommnedation2.PRM_Partner_Role_Nm__c='Solution Integrator';
        vxRecommnedation2.PRM_Market_Type_Nm__c='Emerging';
        vxRecommnedation2.PRM_Sales_Calculation_Group_Txt__c='PRC SMS';
        vxRecommnedation2.PRM_Recommendation_Status_Nm__c = PRM_OPIDTriggerBatchUtility.RECOMMENDATION_STATUS_NEW;
        vxRecommnedation2.RecordTypeId=upgradeDowngradeRecordType;
        //insert vxRecommnedation2;
        vxRecommnedationList.add(vxRecommnedation2);
        
        PRM_Value_Exchange_Recommendation__c vxRecommnedation3 = new PRM_Value_Exchange_Recommendation__c();
        vxRecommnedation3.PRM_Account_Id__c=acc[1].Id;
        vxRecommnedation3.PRM_Tier_Id__c=cplList[0].Id;
        vxRecommnedation3.PRM_Partner_Role_Nm__c='Distributor';
        vxRecommnedation3.PRM_Market_Type_Nm__c='Emerging';
        vxRecommnedation3.PRM_Recommendation_Status_Nm__c = PRM_OPIDTriggerBatchUtility.RECOMMENDATION_STATUS_NEW;
        vxRecommnedation3.RecordTypeId=upgradeDowngradeRecordType;
        vxRecommnedationList.add(vxRecommnedation3);   
        
                PRM_Value_Exchange_Recommendation__c vxRecommnedation4 = new PRM_Value_Exchange_Recommendation__c();
        vxRecommnedation4.PRM_Account_Id__c=acc[1].Id;
        vxRecommnedation4.PRM_Tier_Id__c=cplList[0].Id;
        vxRecommnedation4.PRM_Partner_Role_Nm__c='Independent Software Vendor';
        vxRecommnedation4.PRM_Market_Type_Nm__c='NA';
        vxRecommnedation4.PRM_Recommendation_Status_Nm__c = PRM_OPIDTriggerBatchUtility.RECOMMENDATION_STATUS_NEW;
        vxRecommnedation4.RecordTypeId=upgradeDowngradeRecordType;
        vxRecommnedationList.add(vxRecommnedation4);   
        
        insert vxRecommnedationList;
    }
    //Positive :Test Method for OPID Recommendation Insert 
   /* public static testMethod void opidTriggerInsertTestMethod(){
        Test.startTest();
        PRM_OPIDTriggerBatch c = new PRM_OPIDTriggerBatch();
        Database.executeBatch(c);
        
        Test.stopTest();
        PRM_Value_Exchange_Recommendation__c vxRecommendation = [Select Id,Name,PRM_Account_Id__c,PRM_Tier_Id__r.Name,PRM_Partner_Role_Nm__c,PRM_Market_Type_Nm__c,PRM_Recommendation_Type_Nm__c FROM PRM_Value_Exchange_Recommendation__c where PRM_Tier_Id__r.Name =:'Member' And PRM_Partner_Role_Nm__c='Solution Integrator' And PRM_Market_Type_Nm__c='NA' LIMIT 1];        
        System.assertEquals(PRM_OPIDTriggerBatchUtility.OPID_RECOMMENDATION_TYPE, vxRecommendation.PRM_Recommendation_Type_Nm__c);
        
    }
    //Positive:Test Methid for OPID Recommendation Update 
    public static testMethod void opidTriggerUpdateTestMethod(){
        Test.startTest();
        PRM_OPIDTriggerBatch c = new PRM_OPIDTriggerBatch();
        Database.executeBatch(c);
        Test.stopTest();
        PRM_Value_Exchange_Recommendation__c vxRecommendation2 = [Select Id,Name,PRM_Grouping_Method_Nm__c,PRM_Account_Id__c,PRM_Tier_Id__r.Name,PRM_Partner_Role_Nm__c,PRM_Market_Type_Nm__c,PRM_Recommendation_Type_Nm__c FROM PRM_Value_Exchange_Recommendation__c where PRM_Tier_Id__r.Name =:'Member' And PRM_Partner_Role_Nm__c='Solution Integrator' And PRM_Market_Type_Nm__c='NA' LIMIT 1];
        System.assertEquals(PRM_OPIDTriggerBatchUtility.OPID_RECOMMENDATION_TYPE, vxRecommendation2.PRM_Recommendation_Type_Nm__c);
        
    } */
    //Negative:Test Methid for OPID Recommendation Insert for not qualified VX Data 
    public static testMethod void opidTriggerNegativeInsertTestMethod(){
        Test.startTest();
        PRM_OPIDTriggerBatch c = new PRM_OPIDTriggerBatch();
        Database.executeBatch(c);
        Test.stopTest();
        List<PRM_Value_Exchange_Recommendation__c> vxRecommendationList = [Select Id,Name,PRM_Account_Id__c,PRM_Tier_Id__r.Name,PRM_Partner_Role_Nm__c,PRM_Market_Type_Nm__c,PRM_Recommendation_Type_Nm__c FROM PRM_Value_Exchange_Recommendation__c where PRM_Tier_Id__r.Name =:'Member' AND PRM_Partner_Role_Nm__c='Solution Integrator' AND PRM_Market_Type_Nm__c='Mature' AND PRM_Recommendation_Type_Nm__c=:PRM_OPIDTriggerBatchUtility.OPID_RECOMMENDATION_TYPE];
        System.assertEquals(0, vxRecommendationList.size());
        
    }
    //Negative:Test Methid for OPID Recommendation Update for not qualified VX Data
    public static testMethod void opidTriggerNegativeUpdateTestMethod(){
        Test.startTest();
        PRM_OPIDTriggerBatch c = new PRM_OPIDTriggerBatch();
        Database.executeBatch(c);
        Test.stopTest();
        PRM_Value_Exchange_Recommendation__c vxRecommendation = [Select Id,Name,PRM_Account_Id__c,PRM_Tier_Id__r.Name,PRM_Partner_Role_Nm__c,PRM_Market_Type_Nm__c,PRM_Recommendation_Type_Nm__c FROM PRM_Value_Exchange_Recommendation__c where PRM_Tier_Id__r.Name =:'Member' AND PRM_Partner_Role_Nm__c='Distributor' AND PRM_Market_Type_Nm__c = 'Emerging' LIMIT 1];
        System.assertEquals(null, vxRecommendation.PRM_Recommendation_Type_Nm__c);
        
    }
    //Negative:Test Method for Recommendation Insert/Update for qualified/non qualified VX Data
    public static testMethod void opidTriggerExceptionTestMethod(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        PRM_Execution_Controls__c settings = PRM_Execution_Controls__c.getOrgDefaults();
        settings.PRM_Skip_VR_for_OPID_Batch_Ind__c =false;
        update settings;
        
        Test.startTest();
        PRM_OPIDTriggerBatch c = new PRM_OPIDTriggerBatch();
        Database.executeBatch(c);
        Test.stopTest();
        
        List<Core_Log_Entry__c> logs = [SELECT Id, Core_Origin__c FROM Core_Log_Entry__c LIMIT 1];
        if (logs.isEmpty()) {
            System.debug('No Core_Log_Entry__c found');
    } else {
            Core_Log_Entry__c logEntry = logs[0];
        System.assertEquals(PRM_OPIDTriggerBatchUtility.ORIGIN, logEntry.Core_Origin__c);
    }
    }
    //Positive:Test Method for Upgrade Recommendation Insert/Update qualified VX Data
    public static testMethod void recommendationsUpgradeTestMethod(){
        Test.startTest();
        PRM_OPIDTriggerBatch c = new PRM_OPIDTriggerBatch();
        Database.executeBatch(c);
        
        Test.stopTest();
        
        PRM_Value_Exchange_Recommendation__c vxRecommendation = [Select Id,Name,PRM_Account_Id__c,PRM_Tier_Id__r.Name,PRM_Partner_Role_Nm__c,PRM_Market_Type_Nm__c,PRM_Recommendation_Type_Nm__c FROM PRM_Value_Exchange_Recommendation__c where PRM_Tier_Id__r.Name =:'Member' And PRM_Partner_Role_Nm__c='Independent Software Vendor' And PRM_Market_Type_Nm__c='NA' LIMIT 1];
        System.assertEquals(null, vxRecommendation.PRM_Recommendation_Type_Nm__c);
        
    }
    //Negative:Test Method for Upgrade Recommendation Insert/Update non-qualified VX Data
    public static testMethod void upgradeTestMethodNegative(){
        Test.startTest();
        PRM_OPIDTriggerBatch c = new PRM_OPIDTriggerBatch();
        Id batchId = Database.executeBatch(c);
        Test.stopTest();
        System.assert(batchId != null, 'Batch Id is not NULL!');
    }
    //Positive:Test Method for Schedular Class
    public static testMethod void opidTriggerSchedulerMethod(){
        Test.startTest();
        String data = PRM_Batch_OPID_Trigger_Scheduler.scheduleOPIDTriggerScheduler('TestJob');
        Test.stopTest();
        System.assert(data != null, 'Returns Empty!');
        
    }
}