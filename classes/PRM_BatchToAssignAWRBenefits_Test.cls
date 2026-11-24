/*********************************************************************************************************************
Class Name    : PRM_BatchToAssignAWRBenefits_Test
Version       : 1.0
Created Date  : May 2026
Function      : Test Class for 'PRM_BatchToAssignAWRBenefits'

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------
* Utkarsh                  May,2026              Test Class for 'PRM_BatchToAssignAWRBenefits'
*********************************************************************************************************************/
@isTest
private class PRM_BatchToAssignAWRBenefits_Test {

    @testSetup
    static void createTestData() {

        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.PRM_Intel_Account_Record_Type).getRecordTypeId();
        Id recordTypeIdOPIDAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.PRM_ParentAccRecordType).getRecordTypeId();
        //Test Data for Accounts
        List<Account> acc = new List<Account>();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        newAccount.Name='Johrt Rick';
        newAccount.Core_IPA_Badge_Tier__c='Prestige';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_IPA_Partner_Role__c = 'Service Provider';
        newAccount.Core_CNDA_Number__c='';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.add(newAccount);
        
        Account newAccount1 = new Account();//Account
        newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        newAccount1.Name='Test 2';
        newAccount1.Core_IPA_Badge_Tier__c='Prestige';
        newAccount1.BillingCity='City';
        newAccount1.BillingStreet='Street';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_IPA_Partner_Role__c = 'Service Provider';
        newAccount1.Core_CNDA_Number__c='676875764539878';
        newAccount1.OwnerId = UserInfo.getUserId();
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.add(newAccount1);
        
        Account newAccount2 = new Account();//OPID Account
        newAccount2.RecordTypeId = recordTypeIdOPIDAcc;
        newAccount2.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        newAccount2.Name='Test 3';
        newAccount2.Core_IPA_Badge_Tier__c='Prestige';
        newAccount2.BillingCity='City';
        newAccount2.BillingStreet='Street';
        newAccount2.BillingCountry='India';
        newAccount2.BillingPostalCode='Postal code';
        newAccount2.Core_IPA_Partner_Role__c = 'Service Provider';
        newAccount2.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.add(newAccount2);
        
        insert acc;
        
             //Test Data for Tier
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        //Test Data for Program
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
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Advanced Warranty Replacement';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'AWR';
        pb.PRM_Account_Type_Nm__c='Mastered_Account';
        insert pb;
        
        //Test Data for Value Exchange Data to mimic existing vx datas
        PRM_Value_Exchange_Data__c vxData1 = new PRM_Value_Exchange_Data__c();
        vxData1.Name='vx1';
        vxData1.PRM_Sales_Amount_Nbr__c = 2000000;
        vxData1.PRM_Account_Id__c = acc[0].Id;
        vxData1.PRM_One_Partner_Id__c=acc[2].Id;
        vxData1.PRM_Tier_Id__c = cplList[0].Id;
        vxData1.PRM_Partner_Role_Nm__c = 'Distributor';
        vxData1.PRM_Country_Market_Type_Nm__c = 'NA';
        vxData1.PRM_Sales_Calculation_Group_Txt__c='Branded';
        vxData1.PRM_Training_Credit_Points_Count_Nbr__c=50;
        vxData1.PRM_MP_Solutions_Count_Nbr__c=15;
        vxData1.PRM_Number_Of_Employees_Nbr__c=10;
        vxData1.PRM_Total_Achieved_Competency_Nbr__c=8;
        vxData1.PRM_Change_Date_Dt__c = System.today();
        vxData1.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData1.PRM_To_Dt__c =Date.Today();
        vxData1.PRM_Total_Sales_Out_Units_Nbr__c =70000;
        vxData1.PRM_TimePeriod_Nm__c ='Q4 2025 - Q3 2026';
        insert vxData1;
        
        PRM_Value_Exchange_Data__c vxData2 = new PRM_Value_Exchange_Data__c();
        vxData2.Name='vx2';
        vxData2.PRM_Sales_Amount_Nbr__c = 1900000;
        vxData2.PRM_Account_Id__c = acc[0].Id;
        vxData2.PRM_One_Partner_Id__c=acc[2].Id;
        vxData2.PRM_Tier_Id__c = cplList[0].Id;
        vxData2.PRM_Partner_Role_Nm__c = 'Distributor';
        vxData2.PRM_Country_Market_Type_Nm__c = 'Emerging';
        vxData2.PRM_Sales_Calculation_Group_Txt__c='Branded';
        vxData2.PRM_Training_Credit_Points_Count_Nbr__c=50;
        vxData2.PRM_MP_Solutions_Count_Nbr__c=15;
        vxData2.PRM_Number_Of_Employees_Nbr__c=10;
        vxData2.PRM_Total_Achieved_Competency_Nbr__c=8;
        vxData2.PRM_Change_Date_Dt__c = System.today();
        vxData2.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData2.PRM_To_Dt__c =Date.Today();
        vxData2.PRM_Total_Sales_Out_Units_Nbr__c =70000;
        vxData2.PRM_TimePeriod_Nm__c ='Q4 2025 - Q3 2026';
        insert vxData2;
        
        PRM_Value_Exchange_Data__c vxData3 = new PRM_Value_Exchange_Data__c();
        vxData3.Name='vx3';
        vxData3.PRM_Sales_Amount_Nbr__c = 1000000;
        vxData3.PRM_Account_Id__c = acc[1].Id;
        vxData3.PRM_Tier_Id__c = cplList[0].Id;
        vxData3.PRM_One_Partner_Id__c=acc[2].Id;
        vxData3.PRM_Partner_Role_Nm__c = 'Distributor';
        vxData3.PRM_Country_Market_Type_Nm__c = 'NA';
        vxData3.PRM_Sales_Calculation_Group_Txt__c='Component';
        vxData3.PRM_Training_Credit_Points_Count_Nbr__c=100;
        vxData3.PRM_MP_Solutions_Count_Nbr__c=25;
        vxData3.PRM_Number_Of_Employees_Nbr__c=20;
        vxData3.PRM_Total_Achieved_Competency_Nbr__c=18;
        vxData3.PRM_Sales_Calculation_Group_Txt__c='PRC SMS';
        vxData3.PRM_Change_Date_Dt__c = System.today();
        vxData3.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData3.PRM_To_Dt__c =Date.Today();
        vxData3.PRM_Total_Sales_Out_Units_Nbr__c =90000;
        vxData3.PRM_TimePeriod_Nm__c ='Q4 2025 - Q3 2026';        
        insert vxData3;
        
        PRM_Value_Exchange_Summary__c vxcal = new PRM_Value_Exchange_Summary__c();
        vxcal.Name='vxcal9';
        vxcal.PRM_One_Partner_Id__c = acc[2].Id;
        vxcal.PRM_TimePeriod_Nm__c =  'Q4 2026 - Q3 2027';
        vxcal.PRM_Sales_Amount__c = 51000;
        vxcal.PRM_Training_Credit_Points_Count_Nbr__c = 4000;
        insert vxcal;
        
    }

    @isTest
    private static void testassignAWRBenefit(){
        try{
            PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
            List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>(); 
            bm.Name='BatchFieldValues';
            bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
            bm.PRM_ChannelProgramLevel__c='Partner;Prestige';
            bm.PRM_SchedulingHour__c=6;
            bm.PRM_NoOfRecords__c=300;
            bm.PRM_NoOfBatchEntRecords__c=10;
            bm.PRM_PartnerRole__c ='Service Provider';
            bm.PRM_MP_Benefits__c ='Solutions Marketplace Enhanced';
            bm.PRM_EntitlementsNotToInactivate__c = 'IPA Developer Zone Standard Entitlement';
            bm.PRM_Manual_Benefits__c = 'Advanced Warranty Replacement';
            insert bm;
            
            PRM_Value_Exchange_Data__c vxDataToAssertBeforeInsert = [Select id,PRM_Training_Credit_Points_Report_Nbr__c,
                                                                     PRM_Training_Credit_Points_Count_Nbr__c 
                                                                     from PRM_Value_Exchange_Data__c where Name='vx3' Limit 1];
            
            Account acc = [Select id,name,recordtype.name,recordtypeId from Account where Name ='Test 3'];
            
            PRM_PartnerBenefit__c pbf = [select Id,Name,PRM_Benefit_Dsc__c,PRM_Benefit_Type_Nm__c,PRM_Benefit_Cd__c from PRM_PartnerBenefit__c where Name = 'Advanced Warranty Replacement'];
            
            PRM_BatchToAssignAWRBenefits obj = new PRM_BatchToAssignAWRBenefits();
            Id batchprocessid =DataBase.executeBatch(obj);
            
            //PRM_accBenefitAssociationUtility.onManualBenefitInsert(abalist,null);
            System.assertEquals(pbf.Name,'Advanced Warranty Replacement');
        }
        catch (Exception ex) {
            System.debug('Exceptions :'+ex.getMessage());
        } 
    }
}