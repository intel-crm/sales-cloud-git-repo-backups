/***************************************************************************************************************************************
Apex Class Name     : PRM_VXData_Report_Utility_Test 
Version             : 1.0
Created Date        : Sept 2020
Function            : Test class for PRM_VXData_Report_TriggerHandler,PRM_VXData_Report_Utility.
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Srishty                       15-Sept-2020                      US775505:Update Total Sales, Total Training.. Total Sales Units , reports with the partner role filter
This test class will cover the VX data trigger and its utitlity class
**************************************************************************************************************************************/
@isTest
public class PRM_VXData_Report_Utility_Test {
    
    @testSetup static void setup(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.PRM_Intel_Account_Record_Type).getRecordTypeId();
        Id recordTypeIdOPIDAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.PRM_ParentAccRecordType).getRecordTypeId();
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
        newAccount.Core_IPA_Partner_Role__c = 'Service Provider';
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
        
        Account newAccount2 = new Account();//OPID Account
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
        
        //Test Data for Value Exchange Data to mimic existing vx datas
        PRM_Value_Exchange_Data__c vxData1 = new PRM_Value_Exchange_Data__c();
        vxData1.Name='vx1';
        vxData1.PRM_Sales_Amount_Nbr__c = 2000000;
        vxData1.PRM_Account_Id__c = acc[0].Id;
        vxData1.PRM_One_Partner_Id__c=acc[2].Id;
        vxData1.PRM_Tier_Id__c = cplList[0].Id;
        vxData1.PRM_Partner_Role_Nm__c = 'Solution Integrator';
        vxData1.PRM_Country_Market_Type_Nm__c = 'NA';
        vxData1.PRM_Sales_Calculation_Group_Txt__c='Branded';
        vxData1.PRM_Training_Credit_Points_Count_Nbr__c=50;
        vxData1.PRM_MP_Solutions_Count_Nbr__c=15;
        vxData1.PRM_Number_Of_Employees_Nbr__c=10;
        vxData1.PRM_Total_Achieved_Competency_Nbr__c=8;
        vxData1.PRM_Change_Date_Dt__c = System.today();
        vxData1.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData1.PRM_To_Dt__c =Date.Today();
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
        //vxData2.PRM_TimePeriod_Nm__c ='Q4 2021 - Q3 2022';
        insert vxData2;
        
        PRM_Value_Exchange_Data__c vxData3 = new PRM_Value_Exchange_Data__c();
        vxData3.Name='vx3';
        vxData3.PRM_Sales_Amount_Nbr__c = 1000000;
        vxData3.PRM_Account_Id__c = acc[1].Id;
        vxData3.PRM_Tier_Id__c = cplList[0].Id;
        vxData3.PRM_One_Partner_Id__c=acc[2].Id;
        vxData3.PRM_Partner_Role_Nm__c = 'Service Provider';
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
       // vxData3.PRM_TimePeriod_Nm__c ='Q4 2020 - Q3 2021';        
        insert vxData3;
        // Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id OpidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        //testAccount.Core_IPA_Partner_Speciality__c='Cloud Data Center Specialist';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert testAccount;
        
        PRM_Value_Exchange_Data__c vxData9 = new PRM_Value_Exchange_Data__c();
        vxData9.Name='vx311';
        vxData9.PRM_Sales_Amount_Nbr__c = 1000000;
        vxData9.PRM_Account_Id__c = testAccount.Id;
        vxData9.PRM_Tier_Id__c = cplList[0].Id;
       // vxData9.PRM_One_Partner_Id__c=acc[2].Id;
        vxData9.PRM_Partner_Role_Nm__c = 'Service Provider';
        vxData9.PRM_Country_Market_Type_Nm__c = 'NA';
        vxData9.PRM_Sales_Calculation_Group_Txt__c='Component';
        vxData9.PRM_Training_Credit_Points_Count_Nbr__c=100;
        vxData9.PRM_MP_Solutions_Count_Nbr__c=25;
        vxData9.PRM_Number_Of_Employees_Nbr__c=20;
        vxData9.PRM_Total_Achieved_Competency_Nbr__c=18;
        vxData9.PRM_Sales_Calculation_Group_Txt__c='PRC SMS';
        vxData9.PRM_Change_Date_Dt__c = System.today();
        vxData9.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData9.PRM_To_Dt__c =Date.Today();
        vxData9.PRM_TimePeriod_Nm__c ='Q4 2024 - Q3 2025';        
        insert vxData9;
        
         Account testAccount1 = new Account();
        testAccount1.RecordTypeId = recordTypeIdAccount;
        testAccount1.Name='John Wickneww';
        testAccount1.BillingCity='Cityw';
        testAccount1.BillingStreet='Streew';
        testAccount1.BillingCountry='India';
        testAccount1.BillingPostalCode='Postal cwode';
        testAccount1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
       // testAccount1.Core_IPA_Partner_Speciality__c='Cloud Data Center Specialist';
        testAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert testAccount1;
        
        Account parent1 = new Account();
        parent1.RecordTypeId = OpidAccRecordTypeId;
        parent1.Name='Cello Ltd';
        parent1.BillingCity='New City';
        parent1.BillingStreet='New Street';
        parent1.BillingCountry='India';
        parent1.BillingPostalCode='999999';
        parent1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        insert parent1;
        
         PRM_Value_Exchange_Data__c vxData11 = new PRM_Value_Exchange_Data__c();
        vxData11.PRM_Sales_Amount_Nbr__c = 2000000;
        vxData11.PRM_Account_Id__c = testAccount1.id;
        vxData11.PRM_One_Partner_Id__c = parent1.id;
        vxData11.PRM_Tier_Id__c = cplList[0].Id;
        vxData11.PRM_Partner_Role_Nm__c = 'Distributor';
        vxData11.PRM_Country_Market_Type_Nm__c = 'NA';
        vxData11.PRM_Training_Credit_Points_Count_Nbr__c=5001;
        vxData11.PRM_Change_Date_Dt__c = System.today();
        vxData11.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData11.PRM_To_Dt__c =Date.Today();
        vxData11.PRM_TimePeriod_Nm__c = 'Q4 2024 - Q3 2025';  
        insert vxData11;
        
        PRM_Value_Exchange_Data__c vxData4 = new PRM_Value_Exchange_Data__c();
        vxData4.Name='vx4';
        vxData4.PRM_Sales_Amount_Nbr__c = 1000000;
        vxData4.PRM_Account_Id__c = acc[1].Id;
        vxData4.PRM_One_Partner_Id__c=acc[2].Id;
        vxData4.PRM_Tier_Id__c = cplList[0].Id;
        vxData4.PRM_Partner_Role_Nm__c = 'Distributor';
        vxData4.PRM_Country_Market_Type_Nm__c = 'Emerging';
        vxData4.PRM_Training_Credit_Points_Count_Nbr__c=100;
        vxData4.PRM_MP_Solutions_Count_Nbr__c=25;
        vxData4.PRM_Number_Of_Employees_Nbr__c=20;
        vxData4.PRM_Total_Achieved_Competency_Nbr__c=18;
        vxData4.PRM_Sales_Calculation_Group_Txt__c='PRC SMS';
        vxData4.PRM_Change_Date_Dt__c = System.today();
        vxData4.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData4.PRM_To_Dt__c =Date.Today();
        insert vxData4;
        
        PRM_Value_Exchange_Data__c vxData5 = new PRM_Value_Exchange_Data__c();
        vxData5.Name='vx5';
        vxData5.PRM_Sales_Amount_Nbr__c = 1000000;
        vxData5.PRM_Account_Id__c = acc[1].Id;
        vxData5.PRM_One_Partner_Id__c=acc[2].Id;
        vxData5.PRM_Tier_Id__c = cplList[1].Id;
        vxData5.PRM_Partner_Role_Nm__c = 'Builder';
        vxData5.PRM_Country_Market_Type_Nm__c = 'NA';
        vxData5.PRM_Training_Credit_Points_Count_Nbr__c=100;
        vxData5.PRM_MP_Solutions_Count_Nbr__c=25;
        vxData5.PRM_Number_Of_Employees_Nbr__c=20;
        vxData5.PRM_Total_Achieved_Competency_Nbr__c=18;
        vxData5.PRM_Sales_Calculation_Group_Txt__c='PRC SMS';
        vxData5.PRM_Change_Date_Dt__c = System.today();
        vxData5.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData5.PRM_To_Dt__c =Date.Today();
        insert vxData5;
        
    }
    
    private static List<PRM_Value_Exchange_Data__c> getVxDataRecord(Integer numOfVxRecords){
        Id accId =[Select Id from Account where Name='Test 2' limit 1][0].Id;
        Id opidAccId =[Select Id from Account where Name='Test 3' Limit 1][0].Id;
        Id memberTierId =[Select Id from ChannelProgramLevel where Name ='Member' Limit 1][0].Id;
        List<PRM_Value_Exchange_Data__c> vxRecordsList = new List<PRM_Value_Exchange_Data__c>();
        for(Integer i = 0; i < numOfVxRecords; i++){
            PRM_Value_Exchange_Data__c vxData = new PRM_Value_Exchange_Data__c();
            vxData.Name='New Inserted'+i;
            vxData.PRM_Sales_Amount_Nbr__c = 2000000;
            vxData.PRM_Account_Id__c = accId;
            vxData.PRM_One_Partner_Id__c=opidAccId;
            vxData.PRM_Tier_Id__c = memberTierId;
            vxData.PRM_Partner_Role_Nm__c = 'Builder';
            vxData.PRM_Country_Market_Type_Nm__c = 'NA';
            vxData.PRM_Training_Credit_Points_Count_Nbr__c=100;
            vxData.PRM_MP_Solutions_Count_Nbr__c=25;
            vxData.PRM_Number_Of_Employees_Nbr__c=20;
            vxData.PRM_Total_Achieved_Competency_Nbr__c=18;
            vxData.PRM_Sales_Calculation_Group_Txt__c='PRC SMS';
            vxData.PRM_Change_Date_Dt__c = System.today();
            vxData.PRM_From_Dt__c = Date.Today().addDays(-2);
            vxData.PRM_To_Dt__c =Date.Today();
            vxRecordsList.add(vxData);
        }
        return vxRecordsList;
    }
    
    private static List<PRM_Value_Exchange_Data__c> getVxDataRecordWithoutOpid(Integer numOfVxRecords){
        Id accId =[Select Id from Account where Name='Test 2' limit 1][0].Id;
        Id memberTierId =[Select Id from ChannelProgramLevel where Name ='Member' Limit 1][0].Id;
        List<PRM_Value_Exchange_Data__c> vxRecordsListWithoutOpid = new List<PRM_Value_Exchange_Data__c>();
        for(Integer i = 0; i < numOfVxRecords; i++){
            PRM_Value_Exchange_Data__c vxData = new PRM_Value_Exchange_Data__c();
            vxData.Name='New Inserted without OPID'+i;
            vxData.PRM_Sales_Amount_Nbr__c = 2000000;
            vxData.PRM_Account_Id__c = accId;
            vxData.PRM_Tier_Id__c = memberTierId;
            vxData.PRM_Partner_Role_Nm__c = 'Builder';
            vxData.PRM_Country_Market_Type_Nm__c = 'NA';
            vxData.PRM_Training_Credit_Points_Count_Nbr__c=100;
            vxData.PRM_MP_Solutions_Count_Nbr__c=25;
            vxData.PRM_Number_Of_Employees_Nbr__c=20;
            vxData.PRM_Total_Achieved_Competency_Nbr__c=18;
            vxData.PRM_Sales_Calculation_Group_Txt__c='PRC SMS';
            vxData.PRM_Change_Date_Dt__c = System.today();
            vxData.PRM_From_Dt__c = Date.Today().addDays(-2);
            vxData.PRM_To_Dt__c =Date.Today();
            vxRecordsListWithoutOpid.add(vxData);
        }
        return vxRecordsListWithoutOpid;
    }
    
    @isTest
    private static void testInsertVXDataReport(){
        PRM_Value_Exchange_Data__c vxData = getVxDataRecord(1)[0];
        PRM_Value_Exchange_Data__c vxDataToAssertBeforeInsert = [Select id,PRM_Training_Credit_Points_Report_Nbr__c,
                                                                 PRM_Training_Credit_Points_Count_Nbr__c 
                                                                 from PRM_Value_Exchange_Data__c where Name='vx3' Limit 1];
        //System.assertEquals((vxDataToAssertBeforeInsert.PRM_Training_Credit_Points_Count_Nbr__c/3), vxDataToAssertBeforeInsert.PRM_Training_Credit_Points_Report_Nbr__c);
        
        Test.startTest();
        insert vxData;
        Test.stopTest();
        PRM_Value_Exchange_Data__c vxDataToAssertAfterInsert = [Select PRM_Training_Credit_Points_Report_Nbr__c,
                                                                PRM_Training_Credit_Points_Count_Nbr__c 
                                                                from PRM_Value_Exchange_Data__c 
                                                                where Name='New Inserted0' Limit 1];
        //System.assertEquals((vxDataToAssertAfterInsert.PRM_Training_Credit_Points_Count_Nbr__c/4), vxDataToAssertAfterInsert.PRM_Training_Credit_Points_Report_Nbr__c);
    }
    
    @isTest
    private static void testUpdateVXDataReport(){
        PRM_Value_Exchange_Data__c vxData = getVxDataRecord(1)[0];
        insert vxData;
        PRM_Value_Exchange_Data__c vxDataToUpdate = [Select id,PRM_Sales_Calculation_Group_Txt__c,PRM_Sales_Amount_Report_Nbr__c,PRM_Sales_Amount_Nbr__c from PRM_Value_Exchange_Data__c where Name='New Inserted0' Limit 1];
        //System.assertEquals((vxDataToUpdate.PRM_Sales_Amount_Nbr__c/4), vxDataToUpdate.PRM_Sales_Amount_Report_Nbr__c);
        vxDataToUpdate.PRM_Sales_Calculation_Group_Txt__c='Branded';
        Test.startTest();
        update vxDataToUpdate;
        Test.stopTest();
        PRM_Value_Exchange_Data__c vxDataToAssertAfterUpdate = [Select PRM_Sales_Amount_Report_Nbr__c,
                                                                PRM_Sales_Amount_Nbr__c from PRM_Value_Exchange_Data__c 
                                                                where Name='New Inserted0' Limit 1];
        //System.assertEquals((vxDataToAssertAfterUpdate.PRM_Sales_Amount_Nbr__c/1), vxDataToAssertAfterUpdate.PRM_Sales_Amount_Report_Nbr__c);
    }
    
    @isTest
    private static void testDeleteVXDataReport(){
        PRM_Value_Exchange_Data__c vxData = getVxDataRecord(1)[0];
        insert vxData;
        PRM_Value_Exchange_Data__c vxDataToDelete = [Select id,PRM_Sales_Calculation_Group_Txt__c 
                                                     from PRM_Value_Exchange_Data__c 
                                                     where Name='New Inserted0' Limit 1];
        
        PRM_Value_Exchange_Data__c vxDataToAssertBeforeDeletion = [Select PRM_Sales_Amount_Nbr__c,
                                                                   PRM_Sales_Amount_Report_Nbr__c 
                                                                   from PRM_Value_Exchange_Data__c 
                                                                   where Name='vx5' Limit 1];
       // System.assertEquals((vxDataToAssertBeforeDeletion.PRM_Sales_Amount_Nbr__c/4), vxDataToAssertBeforeDeletion.PRM_Sales_Amount_Report_Nbr__c);
        Test.startTest();
        delete vxDataToDelete;
        Test.stopTest();
        PRM_Value_Exchange_Data__c vxDataToAssertAfterDeletion = [Select PRM_Sales_Amount_Nbr__c,
                                                                  PRM_Sales_Amount_Report_Nbr__c 
                                                                  from PRM_Value_Exchange_Data__c 
                                                                  where Name='vx5' Limit 1];
        //System.assertEquals((vxDataToAssertAfterDeletion.PRM_Sales_Amount_Nbr__c/3), vxDataToAssertAfterDeletion.PRM_Sales_Amount_Report_Nbr__c);
    }
    
    @isTest
    private static void testBulkInsertVXDataReport(){
        List<PRM_Value_Exchange_Data__c> vxDataList = getVxDataRecord(200);
        Test.startTest();
        insert vxDataList;
        Test.stopTest();
        PRM_Value_Exchange_Data__c vxDataToAssertAfterInsert = [Select PRM_Training_Credit_Points_Report_Nbr__c,
                                                                PRM_Training_Credit_Points_Count_Nbr__c 
                                                                from PRM_Value_Exchange_Data__c 
                                                                where Name='New Inserted0' Limit 1];
       // System.assertEquals((vxDataToAssertAfterInsert.PRM_Training_Credit_Points_Count_Nbr__c/203), vxDataToAssertAfterInsert.PRM_Training_Credit_Points_Report_Nbr__c);
    
    }
    @isTest 
    private static void testNonOPIDAccount(){
        List<PRM_Value_Exchange_Data__c> vxDataList = getVxDataRecordWithoutOpid(200);
        Test.startTest();
        insert vxDataList;
        Test.stopTest();
        PRM_Value_Exchange_Data__c vxDataToAssertAfterInsert = [Select PRM_Sales_To_Next_Tier_Nbr__c,
                                                                PRM_Sales_To_Next_Tier_Report_Nbr__c,
                                                                PRM_Training_Credits_to_Next_Tier_Nbr__c,
                                                                PRM_Training_credits_tier_report_Nbr__c 
                                                                from PRM_Value_Exchange_Data__c 
                                                                where Name='New Inserted without OPID0' Limit 1];
        //System.assertEquals((vxDataToAssertAfterInsert.PRM_Sales_To_Next_Tier_Nbr__c/200), vxDataToAssertAfterInsert.PRM_Sales_To_Next_Tier_Report_Nbr__c);
    	System.assertEquals((vxDataToAssertAfterInsert.PRM_Training_Credits_to_Next_Tier_Nbr__c/200), vxDataToAssertAfterInsert.PRM_Training_credits_tier_report_Nbr__c);
    }
}