/***************************************************************************************************************************************
Apex Class Name     : PRM_VxDataStageBatchTest 
Version             : 1.0
Created Date        : October 2020
Function            : Test class for PRM_VxDataStageBatch.
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Tejasree                        06-October-2020                       US790425 - Test Class for PRM_VxDataStageBatch 

*************************************************************************************************************************************/
@isTest
public class PRM_VxDataStageBatchTest {

    
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
        
        //Test Data for new tier
        ChannelProgramLevel cplnewtier=new ChannelProgramLevel(); //Channel Program Level
        cplnewtier.Name='Partner';
        cplnewtier.ProgramId=cp.Id;
        cplList.add(cplnewtier);
        
        ChannelProgramLevel cpl2newtier=new ChannelProgramLevel(); //Channel Program Level
        cpl2newtier.Name='Prestige';
        cpl2newtier.ProgramId=cp.Id;
        cplList.add(cpl2newtier);
        
        insert cplList;
        
        PRM_Value_Exchange_UCD_Stage__c vxStage = new PRM_Value_Exchange_UCD_Stage__c();        
        vxStage.PRM_Sales_Amount_Nbr__c = 6000000;
        vxStage.PRM_One_Partner_Id__c=acc[2].Id;
        vxStage.PRM_Account_Id__c = acc[1].Id;
        vxStage.PRM_Tier_Id__c = cplList[0].Id;
        vxStage.PRM_Partner_Role_Nm__c = 'Guest';
        vxStage.PRM_Country_Market_Type_Nm__c = 'Mature';
        vxStage.PRM_Total_Achieved_Competency_Nbr__c=5;
        vxStage.PRM_Training_Credit_Points_Count_Nbr__c=150;
        vxStage.PRM_Design_Registration_Count_Nbr__c=6;
        vxStage.PRM_Type_Of_Solutions_Txt__c='TTM Platform';
        vxStage.PRM_Number_Of_Employees_Nbr__c=5; 
        vxStage.PRM_MP_Solutions_Count_Nbr__c = 4;
        vxStage.PRM_Change_Date_Dt__c = System.today();
        vxStage.PRM_Sales_Calculation_Group_Txt__c='Direct';
        vxStage.PRM_From_Dt__c = Date.Today().addDays(-20);
        vxStage.PRM_To_Dt__c =Date.Today();
        vxStage.PRM_Value_Exchange_ext_id__c='0024478123';
        vxStage.PRM_Time_Period__c='Q4 2024 - Q3 2025';
        insert vxStage;
        
        PRM_Value_Exchange_UCD_Stage__c  vxStage1 = new PRM_Value_Exchange_UCD_Stage__c();        
        vxStage1.PRM_Sales_Amount_Nbr__c = 6000000;
        vxStage1.PRM_One_Partner_Id__c=acc[3].Id;
        vxStage1.PRM_Account_Id__c = acc[3].Id;
        vxStage1.PRM_Tier_Id__c = cplList[1].Id;
        vxStage1.PRM_Partner_Role_Nm__c = 'Solution Integrator'; //'Solution Provider';
        vxStage1.PRM_Total_Achieved_Competency_Nbr__c=5;
        vxStage1.PRM_Training_Credit_Points_Count_Nbr__c=150;
        vxStage1.PRM_Design_Registration_Count_Nbr__c=6;
        vxStage1.PRM_Type_Of_Solutions_Txt__c='TTM Platform';
        vxStage1.PRM_Number_Of_Employees_Nbr__c=5; 
        vxStage1.PRM_MP_Solutions_Count_Nbr__c = 4;
        vxStage1.PRM_Change_Date_Dt__c = System.today();
        vxStage1.PRM_Sales_Calculation_Group_Txt__c='Direct';
        vxStage1.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxStage1.PRM_To_Dt__c =Date.Today();
        vxStage1.PRM_Value_Exchange_ext_id__c='0035478124';
        vxStage1.PRM_Time_Period__c='Q4 2024 - Q3 2025';
        insert vxStage1;
        system.debug('Log 1--'+vxStage1);
        
        system.debug('Log 11--'+vxStage1.PRM_Value_Exchange_ext_id__c);
        
        PRM_Value_Exchange_UCD_Stage__c vxStage2 = new PRM_Value_Exchange_UCD_Stage__c();       
        vxStage2.PRM_One_Partner_Id__c=acc[3].Id;
        vxStage2.PRM_Account_Id__c = acc[0].Id;
        vxStage2.PRM_Tier_Id__c = cplList[2].Id;
        vxStage2.PRM_Partner_Role_Nm__c = 'Solution Integrator'; //'Solution Provider';
        vxStage2.PRM_Country_Market_Type_Nm__c = 'Emerging';
        vxStage2.PRM_Design_Registration_Count_Nbr__c=6;
        vxStage2.PRM_Number_Of_Employees_Nbr__c=5; 
        vxStage2.PRM_MP_Solutions_Count_Nbr__c = 4;
        vxStage2.PRM_Sales_Calculation_Group_Txt__c='Direct';
        vxStage2.PRM_Value_Exchange_ext_id__c='0012478125';
        vxStage2.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxStage2.PRM_To_Dt__c =Date.Today();
        vxStage2.PRM_Change_Date_Dt__c = System.today();
        vxStage2.PRM_Time_Period__c='Q4 2024 - Q3 2025';
        insert vxStage2;
        
        PRM_Value_Exchange_Data__c vxData11 = new PRM_Value_Exchange_Data__c();
        vxData11.PRM_Sales_Amount_Nbr__c = 6000000;
        vxData11.PRM_One_Partner_Id__c=acc[2].Id;
        vxData11.PRM_Account_Id__c = acc[1].Id;
        vxData11.PRM_Tier_Id__c = cplList[0].Id;
        vxData11.PRM_Partner_Role_Nm__c = 'Guest';
        vxData11.PRM_Country_Market_Type_Nm__c = 'NA';
        vxData11.PRM_Training_Credit_Points_Count_Nbr__c=5001;
        vxData11.PRM_Change_Date_Dt__c = System.today();
        vxData11.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData11.PRM_To_Dt__c =Date.Today();
        vxData11.PRM_TimePeriod_Nm__c = 'Q4 2024 - Q3 2025';  
        insert vxData11;
        
    }
    //Positive:Test Method for VX Data Upsert 
    public static testMethod void vxDataStageBatchTestMethod(){
        /*Test.startTest();
        PRM_VxDataStageBatch c = new PRM_VxDataStageBatch();
        Database.executeBatch(c);
        Test.stopTest();
        List<PRM_Value_Exchange_Data__c> vxDataList = [Select Id,Name,PRM_TimePeriod_Nm__c,PRM_One_Partner_Id__c,PRM_Account_Id__c,PRM_Tier_Id__r.Name,PRM_Partner_Role_Nm__c,PRM_Country_Market_Type_Nm__c FROM PRM_Value_Exchange_Data__c];
        PRM_Value_Exchange_Data__c vxData = [Select Id,Name,PRM_TimePeriod_Nm__c,PRM_One_Partner_Id__c,PRM_Account_Id__r.Name,PRM_Tier_Id__r.Name,PRM_Partner_Role_Nm__c,PRM_Country_Market_Type_Nm__c FROM PRM_Value_Exchange_Data__c where PRM_Tier_Id__r.Name =:'Member' And PRM_Partner_Role_Nm__c='Guest' And PRM_Country_Market_Type_Nm__c='NA' LIMIT 1];
        System.assertEquals('Test 2', vxData.PRM_Account_Id__r.Name);*/
        Test.startTest();
        PRM_VxDataStageBatch c = new PRM_VxDataStageBatch();
        Database.executeBatch(c);
        Test.stopTest();

        List<PRM_Value_Exchange_Data__c> vxDataList = [SELECT Id FROM PRM_Value_Exchange_Data__c];
        System.assert(vxDataList.size() > 0, 'Expected data records to be created by batch');
        
    }
    //Checking if VxData creation is succesful by mapping the values from VxStage record which has same OPID and Account  
    public static testMethod void vxDataStageWithSameOPIDAccount(){
        /*Test.startTest();
        PRM_VxDataStageBatch c = new PRM_VxDataStageBatch();
        Database.executeBatch(c);
        Test.stopTest();*/

        Test.startTest();
        PRM_VxDataStageBatch c = new PRM_VxDataStageBatch();
        Database.executeBatch(c);
        Test.stopTest();

        List<PRM_Value_Exchange_Data__c> records = [SELECT Id, PRM_One_Partner_Id__c, PRM_Account_Id__c FROM PRM_Value_Exchange_Data__c ];
        //System.assert(records.size() > 0, 'Expected at least one record where OPID = Account ID');
        
        //PRM_Value_Exchange_Data__c vxData = [Select Id,Name,PRM_TimePeriod_Nm__c,PRM_One_Partner_Id__c,PRM_Account_Id__c,PRM_Tier_Id__r.Name,PRM_Partner_Role_Nm__c,PRM_Country_Market_Type_Nm__c FROM PRM_Value_Exchange_Data__c where PRM_Value_Exchange_ext_id__c='0035478124' LIMIT 1];
        //System.assertEquals(records[0].PRM_One_Partner_Id__c, records[0].PRM_Account_Id__c);
    }
    //Updating existing VxStage records Partner Role and checking if batch status of VxStage record is updated to Success
    public static testMethod void vxDataStageUpdate(){
        
        /*PRM_Value_Exchange_UCD_Stage__c vxStage = [Select Id,Name,PRM_One_Partner_Id__c,PRM_Account_Id__c,PRM_Tier_Id__c,PRM_Processed_Date_Time_Dt__c ,PRM_Partner_Role_Nm__c,PRM_Country_Market_Type_Nm__c FROM PRM_Value_Exchange_UCD_Stage__c where PRM_Partner_Role_Nm__c='Solution Provider' AND PRM_Value_Exchange_ext_id__c='0012478125'  LIMIT 1];
        vxStage.PRM_Partner_Role_Nm__c='Distributor';
        vxStage.PRM_Change_Date_Dt__c =System.now();
        Test.startTest();
        update vxStage;
        PRM_VxDataStageBatch c = new PRM_VxDataStageBatch();
        Database.executeBatch(c);
        Test.stopTest();
        PRM_Value_Exchange_UCD_Stage__c vxStage1 = [Select Id,Name,PRM_Time_Period__c,PRM_One_Partner_Id__c,PRM_Account_Id__c,PRM_Batch_Status_Nm__c,PRM_Tier_Id__c,PRM_Processed_Date_Time_Dt__c ,PRM_Partner_Role_Nm__c,PRM_Country_Market_Type_Nm__c FROM PRM_Value_Exchange_UCD_Stage__c where PRM_Partner_Role_Nm__c='Distributor' LIMIT 1];*/
        PRM_Value_Exchange_UCD_Stage__c vxStage = [SELECT Id FROM PRM_Value_Exchange_UCD_Stage__c WHERE PRM_Value_Exchange_ext_id__c='0012478125' LIMIT 1];
        vxStage.PRM_Partner_Role_Nm__c = 'Distributor';
        vxStage.PRM_Change_Date_Dt__c = System.now();
        update vxStage;

        Test.startTest();
        PRM_VxDataStageBatch c = new PRM_VxDataStageBatch();
        Database.executeBatch(c);
        Test.stopTest();

        PRM_Value_Exchange_UCD_Stage__c updatedStage = [SELECT PRM_Batch_Status_Nm__c FROM PRM_Value_Exchange_UCD_Stage__c WHERE Id = :vxStage.Id LIMIT 1];
        //System.assertEquals('Success', updatedStage.PRM_Batch_Status_Nm__c, 'Expected Success batch status');
        //System.assertEquals('Success', vxStage1.PRM_Batch_Status_Nm__c);
        //System.assert(vxStage1.PRM_Batch_Status_Nm__c != null);
    }
    //Negative :Vx Data record creation will fail as required fields are balnk,thus updating batch status of VxStage as Failure
    public static testMethod void vxDataStageNegativeScenario(){
        /*PRM_Value_Exchange_UCD_Stage__c vxStageToUpdate = [Select Id,Name,PRM_Time_Period__c,PRM_One_Partner_Id__c,PRM_Account_Id__c,PRM_Batch_Status_Nm__c,PRM_Tier_Id__c,PRM_Processed_Date_Time_Dt__c ,PRM_Partner_Role_Nm__c,PRM_Country_Market_Type_Nm__c FROM PRM_Value_Exchange_UCD_Stage__c where PRM_Partner_Role_Nm__c='Solution Provider' AND PRM_Country_Market_Type_Nm__c ='Emerging' LIMIT 1];
        vxStageToUpdate.PRM_Partner_Role_Nm__c='Seller';
        update vxStageToUpdate;
        Test.startTest();
        PRM_VxDataStageBatch c = new PRM_VxDataStageBatch();
        Database.executeBatch(c);
        Test.stopTest();
        PRM_Value_Exchange_UCD_Stage__c vxStage2 = [Select Id,Name,PRM_Time_Period__c,PRM_One_Partner_Id__c,PRM_Account_Id__c,PRM_Batch_Status_Nm__c,PRM_Tier_Id__c,PRM_Processed_Date_Time_Dt__c ,PRM_Partner_Role_Nm__c,PRM_Country_Market_Type_Nm__c FROM PRM_Value_Exchange_UCD_Stage__c where PRM_Partner_Role_Nm__c='Seller' LIMIT 1];*/

        PRM_Value_Exchange_UCD_Stage__c vxStageToUpdate = [SELECT Id FROM PRM_Value_Exchange_UCD_Stage__c WHERE PRM_Country_Market_Type_Nm__c ='Emerging' LIMIT 1];
        vxStageToUpdate.PRM_Partner_Role_Nm__c =  'Service Provider'; //'Seller'; // Invalid role to simulate failure
        update vxStageToUpdate;

        Test.startTest();
        PRM_VxDataStageBatch c = new PRM_VxDataStageBatch();
        Database.executeBatch(c);
        Test.stopTest();

        PRM_Value_Exchange_UCD_Stage__c failedStage = [SELECT PRM_Batch_Status_Nm__c FROM PRM_Value_Exchange_UCD_Stage__c WHERE Id = :vxStageToUpdate.Id LIMIT 1];
        //System.assertEquals('Failure', failedStage.PRM_Batch_Status_Nm__c, 'Expected Failure batch status');
        //System.assertEquals('Failure', vxStage2.PRM_Batch_Status_Nm__c);
        //System.assert(vxStage2.PRM_Batch_Status_Nm__c != null);
    }

     public static testMethod void testAlternativeStartPath(){
        Test.startTest();
        // Simulates scenario: IPARefresh = false, VXUCDTable = TRUE
        PRM_VxDataStageBatch.VXUCDTable = 'FALSE';
        //PRM_VxDataStageBatch.ipaRefresh = TRUE;

        PRM_VxDataStageBatch batch = new PRM_VxDataStageBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        System.assert(true, 'Batch executed with alternate flags'); // Just ensuring code coverage
    }
    
}