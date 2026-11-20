/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_Scheduler_IAH_Pull_test 
* Version     : 1.0 
* Created Date: 03-07-2022
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Navneet       03-07-2022                    Test Class for Core_MDF_Scheduler_IAH_Partnership_Score
* Pranjal               11-15-2022                       
*********************************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_Scheduler_IAH_Pull_test {
    @isTest static void testExecute()
    {           
        
        Core_MDF_Scheduler_IAH_Pull test = new Core_MDF_Scheduler_IAH_Pull();
        
        test.execute(null);  
        Assert.areEqual('test', 'test');
    }
    @isTest static void testNotifications()
    {            Core_MDF_Configuration__c config = new  Core_MDF_Configuration__c();
     config.name = 'Core_MDF_PScore_Edit_Buffer_Days';
     config.Core_MDF_Value__c = '365';
     insert config;
         Test.startTest();
        ChannelProgram ccfCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New ', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        insert intelAccount;
        List<string> qtr = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
        string quarter = qtr[1];
        List<String> quarterYear = quarter.split(' ');
        List<Core_MDF_Partnership_Score__c> psList = new List<Core_MDF_Partnership_Score__c>();
        Core_MDF_Partnership_Score__c ps1 = new Core_MDF_Partnership_Score__c();
        ps1.Core_MDF_Account_Id__c  = intelAccount.Id;
        ps1.Core_MDF_Channel_Program_Id__c =ccfCP.Id;
        ps1.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        ps1.Core_MDF_Quarter_nm__c = quarterYear[0];
        ps1.Core_MDF_Year_nm__c = quarterYear[1];
        ps1.Core_MDF_Quarter_Year_Nm__c = quarter;
        ps1.Core_MDF_Zone_nm__c = 'C1';
        psList.add(ps1);
        Assert.areEqual(ps1.Core_MDF_Program_nm__c, 'Client CoMarketing Fund');
        insert psList;
        
        Core_MDF_Partnership_Score_Detail__c psd = new Core_MDF_Partnership_Score_Detail__c();
        psd.Core_MDF_Budget_Type_nm__c = 'MDF+';
        psd.Core_MDF_Carry_Over_Amt__c = 2;
        psd.Core_MDF_Region_Cd__c = 'APJ';
        psd.Core_MDF_Partnership_Score_Id__c = ps1.id;
        psd.Core_MDF_Recovered_Amt__c = 100.00;
        insert psd;
        
        Core_MDF_Partnership_Score_Detail__c psd1 = new Core_MDF_Partnership_Score_Detail__c();
        psd1.Core_MDF_Budget_Type_nm__c = 'MDF+';
        psd1.Core_MDF_Carry_Over_Amt__c = 123;
        psd1.Core_MDF_Region_Cd__c = 'APJ';
        psd1.Core_MDF_Partnership_Score_Id__c = ps1.id;
        psd1.Core_MDF_Recovered_Amt__c = 100.00;
        psd1.Core_MDF_Partnership_Score_Detail_Id__c = psd.Id;
        
        insert psd1;
        Core_MDF_Batch_IAH_Pull batch = new Core_MDF_Batch_IAH_Pull(true);
            Database.executeBatch(batch);  
        Test.stopTest();
    }
    @isTest static void testBatchExecute()
    {           
        ChannelProgram ccfCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New ', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        insert intelAccount;
        Assert.areEqual(intelAccount.Name, 'Test Acc New ');
        String accountId = intelAccount.Id+'';
        Core_MDF_Batch_IAH_Pull batch = new Core_MDF_Batch_IAH_Pull(Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Q3 2023',accountId);
        Database.executeBatch(batch); 
        
    }
    
    @isTest static void testBatchExecuteWithQuarter()
    {   
        Core_MDF_Configuration__c config = new  Core_MDF_Configuration__c();
     config.name = 'Core_MDF_PScore_Edit_Buffer_Days';
     config.Core_MDF_Value__c = '365';
     insert config;
        List<string> qtr = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
        string quarter = qtr[1];
        List<String> quarterYear = quarter.split(' ');
        Test.startTest();
        ChannelProgram ccfCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New ', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        insert intelAccount;
        
        List<Core_MDF_Partnership_Score__c> psList = new List<Core_MDF_Partnership_Score__c>();
        Core_MDF_Partnership_Score__c ps1 = new Core_MDF_Partnership_Score__c();
        ps1.Core_MDF_Account_Id__c  = intelAccount.Id;
        ps1.Core_MDF_Channel_Program_Id__c =ccfCP.Id;
        ps1.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        ps1.Core_MDF_Quarter_nm__c = quarterYear[0];
        ps1.Core_MDF_Year_nm__c = quarterYear[1];
        ps1.Core_MDF_Quarter_Year_Nm__c = quarter;
        ps1.Core_MDF_Zone_nm__c = 'C1';
        psList.add(ps1);
        Assert.areEqual(ps1.Core_MDF_Program_nm__c, 'Client CoMarketing Fund');
        insert psList;
        
        Core_MDF_Partnership_Score_Detail__c psd = new Core_MDF_Partnership_Score_Detail__c();
        psd.Core_MDF_Budget_Type_nm__c = 'MDF+';
        psd.Core_MDF_Carry_Over_Amt__c = 2;
        psd.Core_MDF_Region_Cd__c = 'APJ';
        psd.Core_MDF_Partnership_Score_Id__c = ps1.id;
        psd.Core_MDF_Recovered_Amt__c = 100.00;
        insert psd;
        
        Core_MDF_Partnership_Score_Detail__c psd1 = new Core_MDF_Partnership_Score_Detail__c();
        psd1.Core_MDF_Budget_Type_nm__c = 'MDF+';
        psd1.Core_MDF_Carry_Over_Amt__c = 123;
        psd1.Core_MDF_Region_Cd__c = 'APJ';
        psd1.Core_MDF_Partnership_Score_Id__c = ps1.id;
        psd1.Core_MDF_Recovered_Amt__c = 100.00;
        psd1.Core_MDF_Partnership_Score_Detail_Id__c = psd.Id;
        
        insert psd1;
        
        Core_MDF_Batch_Partnership_Score_Detail batch = new Core_MDF_Batch_Partnership_Score_Detail('Q3 2023');
        Database.executeBatch(batch); 
        Test.stopTest();
        
    }
    
    @isTest static void testGenerateInstance(){
        Core_MDF_Batch_IAH_Pull.generateInstance( '{"sendEmailAddress":"","returnMessage":"","query":"","quarter":"Q4 2024","programToExecutionDateMap":null,"program":"Client","notifyRecoveryAdmin":false,"message":"","isIAHDataPullNotAllowed":false,"accountIds":""}', 'Core_MDF_Batch_IAH_Pull(Boolean notifyRecoveryAdmin)');
        Core_MDF_Batch_IAH_Pull.generateInstance( '{"sendEmailAddress":"","returnMessage":"","query":"","quarter":"Q4 2024","programToExecutionDateMap":null,"program":"Client","notifyRecoveryAdmin":false,"message":"","isIAHDataPullNotAllowed":false,"accountIds":""}', 'Core_MDF_Batch_IAH_Pull(string pgm, String quarter,string accounts)');
    }
    
}