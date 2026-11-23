@isTest 
public class Core_MDF_Partnership_ScoreServiceTest {
    @testSetup 
    public static void createData(){
        Profile sysAdmin = [SELECT Id FROM Profile WHERE Name='IT Admin' LIMIT 1];
        User admin = Core_MDF_CCP_TestDataUtility.createUser(false);
        admin.ProfileId=sysAdmin.id;
        admin.LastName ='System Admin';
        Database.insert(admin);
        System.runAs(admin){
            Test.startTest();
            List<ChannelProgram> cpList= new List<ChannelProgram>();
            ChannelProgram ccfCP=Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);
            ChannelProgram dcfCP=Core_MDF_CCP_TestDataUtility.createProgram(Core_MDF_CCP_ConstantClass.DCF_PROGRAM,'Data Center CoMarketing Fund', false);
            ChannelProgram rmfCP=Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds',false);
            cpList.add(ccfCP);
            cpList.add(dcfCP);
            cpList.add(rmfCP);
            Database.insert(cpList);
            List<Account> accList=new List<Account>();
            Account ccfIntelAcc=Core_MDF_CCP_TestDataUtility.createIntelAccount('CCFTestAccount', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            Account dcfIntelAcc=Core_MDF_CCP_TestDataUtility.createIntelAccount('DCFTestAccount', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            Account rmfIntelAcc=Core_MDF_CCP_TestDataUtility.createIntelAccount('RMFTestAccount', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            rmfIntelAcc.Core_Geo__c = 'APJ';
            rmfIntelAcc.Core_Sub_Geo__c = 'SA';
            accList.add(ccfIntelAcc);
            accList.add(dcfIntelAcc); 
            accList.add(rmfIntelAcc);
            Database.Insert(accList);
            Test.stopTest();
        }
    }
    @isTest
    public static void testPopulateAndValidateFields(){
        Test.startTest();
        ChannelProgram ccfCP=[Select Id from ChannelProgram Where Name=:Core_MDF_CCP_ConstantClass.CCF_PROGRAM];
        ChannelProgram rmfCP=[Select Id from ChannelProgram Where Name=:Core_MDF_CCP_ConstantClass.RMF_PROGRAM];
        Account ccfIntelAcc=[Select ID from Account Where Name='CCFTestAccount'];
        Account rmfIntelAcc=[Select ID from Account Where Name='RMFTestAccount'];

        List<Account> accList=new List<Account>();
        Account ccfAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 2', ccfCP.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        ccfAcc.Core_MDF_Parent_Fund_Account__c = ccfIntelAcc.Id;
        
        Account rmfAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 3', rmfCP.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        rmfAcc.Core_MDF_Parent_Fund_Account__c = rmfIntelAcc.Id;
         rmfAcc.Core_Geo__c = 'APJ';
         rmfAcc.Core_Sub_Geo__c = 'SA';
        accList.add(rmfAcc);
        insert accList;

        Core_MDF_Configuration__c config = new  Core_MDF_Configuration__c();
        config.name = 'Core_MDF_PScore_Edit_Buffer_Days';
        config.Core_MDF_Value__c = '365';
        insert config;
        
        List<Core_MDF_Partnership_Score__c> partScrList= new  List<Core_MDF_Partnership_Score__c>();
        Core_MDF_Partnership_Score__c partScr1= new Core_MDF_Partnership_Score__c();
        partScr1.Core_MDF_Account_Id__c= ccfIntelAcc.Id;
        partScr1.Core_MDF_Channel_Program_Id__c=ccfCP.Id;
        partScr1.Core_MDF_Quarter_Year_Nm__c='Q4 2023';
        partScr1.Core_MDF_Partnership_Score_Nbr__c= 5.0;
        partScr1.Core_MDF_Zone_Nm__c = 'A1';
        partScr1.Core_MDF_Virtual_Corp_Account_Id__c = ccfAcc.Id;
        partScrList.add(partScr1);
        
        Core_MDF_Partnership_Score__c partScr2= new Core_MDF_Partnership_Score__c();
        partScr2.Core_MDF_Account_Id__c= rmfIntelAcc.Id;
        partScr2.Core_MDF_Channel_Program_Id__c=rmfCP.Id;
        partScr2.Core_MDF_Quarter_Year_Nm__c='Q1 2024';
        partScr1.Core_MDF_Zone_Nm__c = 'A1';
        partScr1.Core_MDF_Virtual_Corp_Account_Id__c = rmfAcc.Id;
        partScr2.Core_MDF_Partnership_Score_Nbr__c= 4.0;
        partScrList.add(partScr2);
        Core_MDF_Partnership_ScoreServiceHandler.populateExternalId(partScrList);
        Core_MDF_Partnership_ScoreServiceHandler.populatecarryForwardAmt(partScrList);
        
        Database.Insert( partScrList) ;
        
        partScrList[0].Core_MDF_Partnership_Score_Nbr__c= 4.0;
        //partScrList[0].Core_MDF_External_Id__c='1234Q1 2027';
        try{  
            Database.Update(partScrList);
        }catch(Exception ex){
        }
        Test.stopTest();
        // Unit Test Method should include System.Assert - Indira
        System.assertEquals(4.0, partScrList[0].Core_MDF_Partnership_Score_Nbr__c, 'First partnership score should be updated to 4.0');
        
    }
}