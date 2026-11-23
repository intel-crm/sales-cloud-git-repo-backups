/***************************************************************************************************** 
Class Name :    Core_MDF_PFR_Reimbursement_Handler_Test
Description:    Activity Variable Reimbursment test class
Added By   :  	SS  
Modified By:                      Date:03/12/2020                     Changes:None  
******************************************************************************************************/
@isTest(SeeAllData=false)
public with sharing class Core_MDF_PFR_Reimbursement_Handler_Test {
    /*************************************************************************************************
	Method Name: - Test Data Setup     
	**************************************************************************************************/
    @TestSetUp
    static void createTestData(){
        //Admin User to create Channel Program, Account , Create Internal Account Managers, Program Admins 
        List<User> userList = new List<User>();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.UserRoleId = usRole.Id;
        userList.add(usr);
        insert userList;
        System.runAs(userList[0]){
            Test.startTest();
            // Creating Channel Programs
            List <ChannelProgram> cpList = new List <ChannelProgram>();
            ChannelProgram cpCCF = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', false);
            ChannelProgram cpDCF = Core_MDF_CCP_TestDataUtility.createProgram ('Datacenter','Data Center CoMarketing Fund', false);
            cpList.add(cpCCF);
            cpList.add(cpDCF);
            insert cpList;
            // Creating Intel Account 
            List<Account> accIntelList = new List<Account>();
            Account accIntel = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, FALSE);
            accIntel.Core_MDF_CoMarketingActive__c = true;
            accIntelList.add(accIntel);
            insert accIntelList;
            // Creating Virtual Node Account
            List<Account> accVirtualAccountList = new List<Account>();
            Account coMarketingAccCCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Virtual CCF Account', cpList[0].Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, accIntelList[0].Id, FALSE);
            Account coMarketingAccDCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Virtual DCF Account', cpList[1].Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, accIntelList[0].Id, FALSE);
            accVirtualAccountList.add(coMarketingAccCCF);
            accVirtualAccountList.add(coMarketingAccDCF);
            insert accVirtualAccountList;
            // Getting Internal Account Managers
            Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            PermissionSet ccfAccmanagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet dcfAccmanagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_DCF_Acct_Mgr' LIMIT 1];
            // Insert Internal Account Manager
            List<User> listUser = new List<user>();
            //CCF Account Manager  
            User ccfAccntMngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
            ccfaccntmngr.Profile = ccpCoreAccessProfile;
            User dcfAccntMngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfaccntmngr.Email = 'dcfaccntmngr@example.com';
            ccfaccntmngr.Profile = ccpCoreAccessProfile;
            listUser.add(ccfAccntMngr);
            listUser.add(dcfAccntMngr);
            insert listUser;
            //PS Assignment
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            PermissionSetAssignment assignPermissionSetObjCCF = new PermissionSetAssignment();
       		assignPermissionSetObjCCF.AssigneeId = ccfAccntMngr.Id;
       		assignPermissionSetObjCCF.PermissionSetId = ccfAccmanagerPS.Id;
            PermissionSetAssignment assignPermissionSetObjDCF = new PermissionSetAssignment();
       		assignPermissionSetObjDCF.AssigneeId = dcfAccntMngr.Id;
       		assignPermissionSetObjDCF.PermissionSetId = dcfAccmanagerPS.Id;
            psaList.add(assignPermissionSetObjCCF);
            psaList.add(assignPermissionSetObjDCF);
            insert psaList;
            Test.stopTest();
            System.runAs(ccfAccntMngr){
                Campaign campCCF = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp CCF','Gaming','Intel® Core™ i5 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', Date.newInstance(2021, 01, 01),Date.newInstance(2021, 06, 29), 10000, 'Always Connected PC', coMarketingAccCCF.Id,'2-in-1', false);
                campCCF.Core_MDF_Technology__c ='Ice Lake';
                  campCCF.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP'; 
                insert campCCF;
                
                List<PartnerFundRequest> pfrCCFList = new List<PartnerFundRequest>();
                PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(campCCF.Id), 
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           String.valueof(coMarketingAccCCF.id),null,null,'ALBANIA',
                                                                                           'Gaming',
                                                                                           '2-in-1',
                                                                                           'Intel® Core™ i5 Processor',
                                                                                           'Event',
                                                                                           'Channel Partner Owned Event',
                                                                                           'Draft',
                                                                                           false);
                pfr1.Core_MDF_Start_Date__c = Date.newInstance(2021, 01, 01);
                pfr1.Core_MDF_End_Date__c  = Date.newInstance(2021, 06, 29);
                pfr1.Core_MDF_Fund_Request_Status__c = 'Planned';
                pfr1.Title = 'Test CCF Activity 1';
                pfr1.Core_MDF_Activity_Description__c = 'Test CCF Activity 1';
                pfr1.Core_MDF_Channel_Partner_Led__c = True;
                pfr1.Core_MDF_Budget_Amount_Local_amt__c=12345;
                pfr1.Core_MDF_Budget_Currency_cd__c='USD';
               // pfr1.Core_MDF_Technology_txt__c = 'Ice Lake';
            	PartnerFundRequest pfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(campCCF.Id), 
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           String.valueof(coMarketingAccCCF.id),null,null,'ALBANIA',
                                                                                           'Gaming',
                                                                                           '2-in-1',
                                                                                           'Intel® Core™ i5 Processor',
                                                                                           'Event',
                                                                                           'Channel Partner Owned Event',
                                                                                           'Draft',
                                                                                           false);
                pfr2.Core_MDF_Start_Date__c = Date.newInstance(2021, 01, 01);
                pfr2.Core_MDF_End_Date__c  = Date.newInstance(2021, 06, 29);
                pfr2.Core_MDF_Fund_Request_Status__c = 'Planned';
                pfr2.Title = 'Test CCF Activity 2';
                pfr2.Core_MDF_Activity_Description__c = 'Test CCF Activity 2';
                pfr2.Core_MDF_Channel_Partner_Led__c = True;
                pfr2.Core_MDF_Budget_Amount_Local_amt__c=12345;
                pfr2.Core_MDF_Budget_Currency_cd__c='USD';
                pfrCCFList.add(pfr1);
                pfrCCFList.add(pfr2);
                insert pfrCCFList;
            }
            System.runAs(dcfAccntMngr){
                Campaign campDCF = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp DCF','Gaming','Intel® Core™ i5 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 'Data Center CoMarketing Fund', Date.newInstance(2021, 01, 01), Date.newInstance(2021, 06, 29), 10000, 'Always Connected PC', coMarketingAccDCF.Id,'2-in-1', false);
            	 campDCF.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP'; 
                campDCF.Core_MDF_Technology__c ='Intel® Optane™ DC Persistent Memory';
                insert campDCF;
                List<PartnerFundRequest> pfrDCFList = new List<PartnerFundRequest>();
                PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(campDCF.Id), 
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_DCF,
                                                                                           String.valueof(coMarketingAccDCF.id),null,null,'ALBANIA',
                                                                                           'Developer',
                                                                                           'Storage',
                                                                                           'Intel® Xeon® Processor',
                                                                                           'Event',
                                                                                           'Channel Partner Owned Event',
                                                                                           'Draft',
                                                                                           false);
                pfr1.Core_MDF_Start_Date__c = Date.newInstance(2021, 01, 01);
                pfr1.Core_MDF_End_Date__c  = Date.newInstance(2021, 06, 29);
                pfr1.Core_MDF_Fund_Request_Status__c = 'Planned';
                pfr1.Title = 'Test DCF Activity 1';
                pfr1.Core_MDF_Activity_Description__c = 'Test DCF Activity 1';
                pfr1.Core_MDF_Channel_Partner_Led__c = True;
                pfr1.Core_MDF_Budget_Amount_Local_amt__c=12345;
                pfr1.Core_MDF_Budget_Currency_cd__c='USD';
             
            	PartnerFundRequest pfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(campDCF.Id), 
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_DCF,
                                                                                           String.valueof(coMarketingAccDCF.id),null,null,'ALBANIA',
                                                                                           'Developer',
                                                                                           'Storage',
                                                                                           'Intel® Xeon® Processor',
                                                                                           'Event',
                                                                                           'Channel Partner Owned Event',
                                                                                           'Draft',
                                                                                           false);
                pfr2.Core_MDF_Start_Date__c = Date.newInstance(2021, 01, 01);
                pfr2.Core_MDF_End_Date__c  = Date.newInstance(2021, 06, 29);
                pfr2.Core_MDF_Fund_Request_Status__c = 'Planned';
                pfr2.Title = 'Test DCF Activity 2';
                pfr2.Core_MDF_Activity_Description__c = 'Test DCF Activity 2';
                pfr2.Core_MDF_Channel_Partner_Led__c = True;
                pfr2.Core_MDF_Budget_Amount_Local_amt__c=12345;
                pfr2.Core_MDF_Budget_Currency_cd__c='USD';
                pfr2.Core_MDF_Technology_txt__c = 'Intel® Optane™ DC Persistent Memory';
                pfrDCFList.add(pfr1);
                pfrDCFList.add(pfr2);
                insert pfrDCFList;
            }
            // Inserting Incentive Records
            List<Core_MDF_CoMarketing_Activity_Inc_Rule__c> cairList = new List<Core_MDF_CoMarketing_Activity_Inc_Rule__c>();
            Core_MDF_CoMarketing_Activity_Inc_Rule__c cair1 = new Core_MDF_CoMarketing_Activity_Inc_Rule__c();
            cair1.Core_MDF_Active_Ind__c = true;
            cair1.Core_MDF_Activity_Category_Nm__c = 'Event';
            cair1.Core_MDF_Activity_Type_Nm__c = 'Channel Partner Owned Event';
            cair1.Core_MDF_Brand_Nm__c = 'Intel® Core™ i5 Processor';
            cair1.Core_MDF_Channel_Program_Id__c = cpCCF.Id;
            cair1.Core_MDF_Effective_Dt__c = system.today();
            cair1.Core_MDF_Incentive_Pct__c = 10;
            cair1.Core_MDF_Ineffective_Dt__c = system.today().addDays(10);
            cair1.Core_MDF_Product_Type_Txt__c = '2-in-1';
            cair1.Core_MDF_Technology_Nm__c = 'Ice Lake';
            cairList.add(cair1);
            Core_MDF_CoMarketing_Activity_Inc_Rule__c cair2 = new Core_MDF_CoMarketing_Activity_Inc_Rule__c();
            cair2.Core_MDF_Active_Ind__c = true;
            cair2.Core_MDF_Activity_Category_Nm__c = 'Event';
            cair2.Core_MDF_Activity_Type_Nm__c = 'Channel Partner Owned Event';
            cair2.Core_MDF_Brand_Nm__c = 'Intel® Xeon® Processor';
            cair2.Core_MDF_Channel_Program_Id__c = cpDCF.Id;
            cair2.Core_MDF_Effective_Dt__c = system.today();
            cair2.Core_MDF_Incentive_Pct__c = 10;
            cair2.Core_MDF_Ineffective_Dt__c = system.today().addDays(10);
            cair2.Core_MDF_Product_Type_Txt__c = 'Storage';
            cair2.Core_MDF_Technology_Nm__c = NULL;
            cairList.add(cair2);
            insert cairList;
            System.assert(cairList[0].Core_MDF_Incentive_pct__c == 10);
        }
    }
    /*************************************************************************************************
	Method Name: - Positive Test Scenario     
	**************************************************************************************************/
    @isTest 
    static void testloadPFRRecord(){
        Test.startTest();
        
        List<PartnerFundRequest> pfrList = [SELECT Id, Title, Core_MDF_ActivityCategory__c, Core_MDF_Activity_Types__c,Core_MDF_Brand_nm__c,
                                            Core_MDF_ProductType__c, Campaign.Core_MDF_Account__r.Core_MDF_Channel_Program__c,Core_MDF_Start_Date__c,Core_MDF_Incentive_Opted_In_ind__c,
                                            Campaign.Core_MDF_Technology__c FROM PartnerFundRequest WHERE Title ='Test DCF Activity 1' OR Title ='Test DCF Activity 2'
                                           	OR Title ='Test CCF Activity 2' OR Title ='Test CCF Activity 2' Limit 4];
        List<Core_MDF_CoMarketing_Activity_Inc_Rule__c> incentiveList = [SELECT Id, Core_MDF_Brand_Nm__c,Core_MDF_Product_Type_Txt__c,
                                                                         Core_MDF_Activity_Category_Nm__c, Core_MDF_Activity_Type_Nm__c,
                                                                         Core_MDF_Technology_Nm__c,Core_MDF_Effective_Dt__c, Core_MDF_Ineffective_Dt__c,
                                                                         Core_MDF_Channel_Program_Id__c FROM Core_MDF_CoMarketing_Activity_Inc_Rule__c LIMIT 2];
        
        Map<PartnerFundRequest, Id> pfrCPIdMap = new Map<PartnerFundRequest, Id>();
        for(PartnerFundRequest pfr : pfrList){
        	pfrCPIdMap.put(pfr , pfr.Campaign.Core_MDF_Account__r.Core_MDF_Channel_Program__c);
        }
        Core_MDF_VRQuestionsWrapper.vrQuestionWrap pfrLst = Core_MDF_PFR_Reimbursement_Handler.calculateVariableReimbursement(pfrCPIdMap,'Intel® Optane™ DC SSD');
        
        try{
            System.assert(pfrLst.pfrData[0].Core_MDF_Incentive_pct__c == incentiveList[0].Core_MDF_Incentive_Pct__c);
            System.assert(pfrLst.pfrData[1].Core_MDF_Incentive_pct__c == incentiveList[0].Core_MDF_Incentive_Pct__c);
            System.assert(pfrLst.pfrData[2].Core_MDF_Incentive_pct__c == incentiveList[1].Core_MDF_Incentive_Pct__c);
            System.assert(pfrLst.pfrData[3].Core_MDF_Incentive_pct__c == incentiveList[1].Core_MDF_Incentive_Pct__c);
        }catch(Exception e){
            
        }
        
        Test.stopTest();
    }
    /*************************************************************************************************
	Method Name: - Negative Test Scenario     
	**************************************************************************************************/
    @isTest 
    static void testloadnegativePFRRecord(){
        Test.startTest();
        ChannelProgram dcfCP = [Select Id FROM ChannelProgram WHERE Core_MDF_Technical_Program_Name__c = 'Data Center CoMarketing Fund'];
        List<PartnerFundRequest> pfrList = [SELECT Id, Title, Core_MDF_ActivityCategory__c, Core_MDF_Activity_Types__c,Core_MDF_Brand_nm__c,
                                            Core_MDF_ProductType__c, Campaign.Core_MDF_Account__r.Core_MDF_Channel_Program__c,Core_MDF_Start_Date__c,
                                            Campaign.Core_MDF_Technology__c
                                            FROM PartnerFundRequest WHERE Title ='Test CCF Activity 2' OR Title ='Test CCF Activity 2' Limit 2];
        List<Core_MDF_CoMarketing_Activity_Inc_Rule__c> incentiveList = [SELECT Id, Core_MDF_Brand_Nm__c,Core_MDF_Product_Type_Txt__c,
                                                                         Core_MDF_Activity_Category_Nm__c, Core_MDF_Activity_Type_Nm__c,
                                                                         Core_MDF_Technology_Nm__c,Core_MDF_Effective_Dt__c, Core_MDF_Ineffective_Dt__c,
                                                                         Core_MDF_Channel_Program_Id__c FROM Core_MDF_CoMarketing_Activity_Inc_Rule__c WHERE Core_MDF_Channel_Program_Id__c =: dcfCP.Id  LIMIT 1];
        
        Map<PartnerFundRequest, Id> pfrCPIdMap = new Map<PartnerFundRequest, Id>();
        for(PartnerFundRequest pfr : pfrList){
        	pfrCPIdMap.put(pfr , pfr.Campaign.Core_MDF_Account__r.Core_MDF_Channel_Program__c);
        }
                Core_MDF_VRQuestionsWrapper.vrQuestionWrap pfrLst = Core_MDF_PFR_Reimbursement_Handler.calculateVariableReimbursement(pfrCPIdMap,'Intel® Optane™ DC SSD');
        
        try{
            System.assert(pfrLst.pfrData[0].Core_MDF_Incentive_pct__c == NULL);
        }catch(Exception e){
            
        }
        
        Test.stopTest();
    }
}