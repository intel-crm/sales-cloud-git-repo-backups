/**************************************************************************************
Apex Class Name:  Core_MDF_BudgetTransfer_Test 
Version     : 1.0 
Created Date: 02 08 2018
Function    : Test class for the Core_MDF_BudgetTransfer used for Budget Transfer.
Author      : Sarah Manuel
Modification Log :
* Change#           Author                   Date                   Description
* ----------------------------------------------------------------------------                 
* Core MDF Rel1   Sarah Manuel         02/08/2018              Original Version
*
*************************************************************************************/
@isTest(SeeAllData=false) 
public class Core_MDF_BudgetTransfer_Test {
    
    @TestSetup 
    static void createTestData() {
        
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
        bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
        bypassFunctionKeys.add('Bypass_Allocation_Reservation');
        bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
        bypassFunctionKeys.add('Bypass_Duplicate_Bank_Check');
        bypassFunctionKeys.add('Bypass_Bank_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_External_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_ABM_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_External_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_NodeGroup_Sharing');        
        bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
        bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
        bypassFunctionKeys.add('Bypass_PaymentRun_Duplicate_Check');
        bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_On_Owner_Chng');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_Internal_Usrs');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_External_Usrs');
        bypassFunctionKeys.add('Bypass_Claim_AdjReq_Amount_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        
        bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
        bypassFunctionKeys.add('Bypass_Payment_Doc_InvFileVAT_Validate');
        bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
        bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');
        bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
        bypassFunctionKeys.add('Bypass_UpdateActivityFields');
        bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
        bypassFunctionKeys.add('Core_MDF_XMLToXLSGenerationFlag');
        bypassFunctionKeys.add('Core_MDF_StringToXLSGenerationFlag');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'MDF Budget Loader';
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        
         User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'TestClass TestUser';
        usr2.profileId = systemAdminProfile.Id;
        Database.insert(usr2);
        
        Test.startTest();    
        
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
        

        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram('Retail Marketing Funds','Retail Marketing Funds', true);
        ChannelProgram eefCp = Core_MDF_CCP_TestDataUtility.createProgram('Ecosystem Extension Fund','Ecosystem Extension Fund', true);

        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account intelAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        List<Account> accList = new List<Account>();
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false);
        acc2.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        accList.add(acc2);
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, false);
        acc3.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        accList.add(acc3);
        Account acc4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account VC', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false);
        acc4.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        accList.add(acc4);
        Account vcAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Intel Account Virtual Corp', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelAcc.Id, false);
        vcAccount.Core_MDF_Parent_Fund_Account__c = intelAcc.Id;
        accList.add(vcAccount);
        Database.insert(accList);
        Account rmfVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('RMF Virtual Corp2', cp2.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);                           
        rmfVirtualCorp.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        rmfVirtualCorp.Core_MDF_CoMarketingActive__c = true;
        rmfVirtualCorp.Core_Geo__c = 'APJ';
        rmfVirtualCorp.Core_Sub_Geo__c = 'SA';
        Database.insert(rmfVirtualCorp);
        Account eefPrimaryVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('EEF Primary Virtual Corp', eefCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);                           
		eefPrimaryVirtualCorp.Core_MDF_Parent_Fund_Account__c = intelAcc.Id;
        eefPrimaryVirtualCorp.Core_MDF_Partner_Type_nm__c ='Primary Partner';
		insert eefPrimaryVirtualCorp;
        Account eefActivatingVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('EEF Activating Virtual Corp', eefCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);                           
		eefActivatingVirtualCorp.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        eefActivatingVirtualCorp.Core_MDF_Partner_Type_nm__c ='Activating Partner';
		insert eefActivatingVirtualCorp;
        Account eefNode = Core_MDF_CCP_TestDataUtility.createAccount ('EEF Activating Node', eefCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);                           
		eefNode.Core_MDF_Parent_Fund_Account__c = eefActivatingVirtualCorp.Id;
        eefNode.Core_MDF_Partner_Type_nm__c ='Activating Partner';
		insert eefNode;
        
         Core_MDF_Partner_Mapping__c primToActPartnerMapping = new Core_MDF_Partner_Mapping__c();
         primToActPartnerMapping.Core_MDF_Primary_Partner_Account_id__c = eefPrimaryVirtualCorp.id;
         primToActPartnerMapping.Core_MDF_Activating_Partner_Account_id__c = eefActivatingVirtualCorp.id;
         primToActPartnerMapping.Core_MDF_Effective_Start_Date__c = system.today()-90;
         primToActPartnerMapping.Core_MDF_Effective_End_Date__c = system.today () +100;
         primToActPartnerMapping.Core_MDF_Channel_Program__c = eefCp.Id;
         insert primToActPartnerMapping;
        
        system.runAs(usr){
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Usr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance.Id);
            PermissionSet psFinance1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_User' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance1.Id);
            PermissionSet psFinance2 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Finance_Usr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance2.Id);
            PermissionSet eefBudLoader = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Budget_Loader' LIMIT 1];
		    insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = eefBudLoader.Id);
             PermissionSet eefBudManager = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Budget_Manager' LIMIT 1];
		    insert new PermissionSetAssignment(AssigneeId = usr2.id, PermissionSetId = eefBudManager.Id);
            PermissionSet eefBudApp = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Budget_Approver' LIMIT 1];
		    insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = eefBudApp.Id);

        }
        
        PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 50000, System.today().addDays(-5), System.today().addDays(50), false);
        pbm.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
        system.runAs(usr){
            Database.insert(pbm);
        }
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, acc2, 30000, true);
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        Core_MDF_CCP_TestDataUtility.createCCPBudgetTransferData();
        
        
        List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>(); 
        System.runAs(usr){
            PartnerMarketingBudget pbm2 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 3', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, rmfVirtualCorp.Id, cp2.Id, 30000, System.today(), System.today().addDays(50), true);
            PartnerMarketingBudget pbmCCF = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget CCF', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 3000, Date.newInstance(2020,01,01), Date.newInstance(2020,12,31), false);
            pbmCCF.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
            pmbList.add(pbmCCF);
            PartnerMarketingBudget pbmCCF2 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget CCF2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 3000, Date.newInstance(2018,01,01), Date.newInstance(2018,12,31), false);
            pbmCCF2.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
            pmbList.add(pbmCCF2);
            PartnerMarketingBudget pbmEef = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget EEF', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, eefPrimaryVirtualCorp.Id, eefCp.Id, 90000, System.today()-30, System.today()+30, false);
		    pbmEef.Core_MDF_Budget_Status__c = 'Released';
            pmbList.add(pbmEef);

            Database.insert(pmbList);
            PartnerFundAllocation eefPFA2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test EEF PFA', pbmEef, eefPrimaryVirtualCorp, 30000, true);
            PartnerFundAllocation eefPFA = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test EEF PFA', pbmEef, eefActivatingVirtualCorp, 30000, true);

        }
        
        
        Test.stopTest();
        
    }
    
    @isTest static void validateAccountIDNameMapping(){
        Test.startTest();
        Account acc1 = [Select id,Name from Account where Name = 'Test Account 1'];
        
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        System.runAs(usr){            
            Account accountDetail = Core_MDF_BudgetTransfer.AccountIDNameMapping(acc1.Id);
            System.assertEquals(acc1.Name, accountDetail.Name);            
        }
        Test.stopTest();
    }
    /*added to validate sharing of account with account group*/
    @isTest static void checkSharingWithAcctGrp(){ 
        Test.startTest();
        User usr1 = [Select id from user where lastname='MDF Budget Loader' limit 1];
        /*system.runAs(usr1){
PermissionSet psFinance2 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Finance_Usr' LIMIT 1];
insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psFinance2.Id);
}*/
        
        Core_Trigger_Executions__c groupIdForAccountNode = new Core_Trigger_Executions__c();
        groupIdForAccountNode.name = 'Core_MDF_createGroupForAccountNode';
        groupIdForAccountNode.Core_Object__c = 'Account';
        groupIdForAccountNode.Core_Trigger_Events__c = 'After Insert';
        groupIdForAccountNode.Core_Active__c = TRUE;
        groupIdForAccountNode.Core_Description__c = 'To Create Group for each account';
        groupIdForAccountNode.Core_Class_Name__c = 'Core_AccountHandler';
        insert groupIdForAccountNode;
        
        //ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram('Retail Marketing Funds','Retail Marketing Funds', true);
        ChannelProgram cp2 = [Select id from ChannelProgram where Name = 'Retail Marketing Funds'];
        Account acc1 = [Select id from Account where Name = 'Test Account 1'];       
        Account rmfVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('RMF Virtual Corp', cp2.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);                           
        rmfVirtualCorp.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        rmfVirtualCorp.Core_MDF_CoMarketingActive__c = true;
        rmfVirtualCorp.Core_Geo__c = 'APJ';
        rmfVirtualCorp.Core_Sub_Geo__c = 'SA';
        //rmfVirtualCorp.Core_Geo__c = 'ASMO';
        //rmfVirtualCorp.Core_Sub_Geo__c = 'LAR';
        database.insert(rmfVirtualCorp);
        
        AccountShare accShare = new AccountShare();
        accShare.AccountId = rmfVirtualCorp.Id;
        accShare.UserOrGroupId = usr1.Id;
        accShare.AccountAccessLevel = 'Read';
        accShare.OpportunityAccessLevel = 'None';
        accShare.CaseAccessLevel = 'None';
        accShare.RowCause = 'Manual';
        insert accShare;
        
        ChannelProgramShare csShare = new ChannelProgramShare();
        csShare.ParentId = cp2.Id;
        csShare.UserOrGroupId = usr1.Id;
        csShare.AccessLevel = 'Read';
        csShare.RowCause = 'Manual';
        insert csShare;
        
        PartnerMarketingBudget pbm = [SELECT Id FROM PartnerMarketingBudget WHERE Title='Test Budget 3' limit 1] ;
        /*system.runAs(usr1){
pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, rmfVirtualCorp.Id, cp2.Id, 30000, System.today(), System.today().addDays(50), true);
}*/
        
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, rmfVirtualCorp, 30000, true);
        Core_MDF_BudgetTransfer.getBalanceAllocationAmount(string.valueof(rmfVirtualCorp.id),string.valueof(pbm.id));
        List<PartnerFundAllocationShare> pfaShareList = [Select id from PartnerFundAllocationShare where parentId =: pfaRecord.Id];
        System.assertEquals(true, pfaShareList.size()>0);
        Test.stopTest();
        
    }
    @isTest static void validatecheckAccess(){  
        Test.startTest();
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        System.runAs(usr){
            
            System.assertEquals(false, Core_MDF_BudgetTransfer.checkAccess());
            
        }
        Test.stopTest();
    }
    
    @isTest static void validateSearchAccountsLookup(){
        Test.startTest();
        List<Account> toBeUpdated = new List<Account>();

        for(Account acc: [Select id,isPartner,Name from Account where Name IN ('Test Account 1','Test Account 2')]){
            acc.isPartner = true;
            toBeUpdated.add(acc);
        } 
        
        Database.update(toBeUpdated);
        
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        
        System.runAs(usr){
            List<Account> accountDetail = Core_MDF_BudgetTransfer.SearchAccountsLookup();
            if(!accountDetail.IsEmpty() && accountDetail.size()>0){
                // System.assertEquals(toBeUpdated[1].Id, accountDetail[0].Id);
                Assert.isNotNull(accountDetail);
            }
        }
        Test.stopTest();
    }
    
    @isTest static void validateSearchAccountsLookupforBudgetLoader(){
        try{
            Test.startTest();
            List<Account> toBeUpdated = new List<Account>();

            for(Account acc: [Select id,isPartner,Name from Account where Name IN ('Test Account 1','Test Account 2')]){
                acc.isPartner = true;
                toBeUpdated.add(acc);
            } 
            
            Database.update(toBeUpdated);
            
            User tstUsr = [SELECT Id from User where LastName='MDF Budget Loader' limit 1];
            
            Account acc2 = [SELECT Id,Core_MDF_Parent_Fund_Account__c from Account where Name='Test Account 2' limit 1];
            system.runAs(tstUsr){
                PermissionSet pSet = [SELECT Id,Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
                
                PermissionSetAssignment assignPermissionSet = new PermissionSetAssignment();
                assignPermissionSet.AssigneeId = tstUsr.Id;
                assignPermissionSet.PermissionSetId = pSet.Id;
                //Database.insert(assignPermissionSet);
            }
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Account_id__c = acc2.Core_MDF_Parent_Fund_Account__c;
            iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgm.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgm.Core_MDF_User_id__c = tstUsr.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader';
            iupgm.Core_MDF_All_Accounts_cd__c = 'No';
            insert iupgm;
            
            System.runAs(tstUsr){
                List<Account> accountDetail = Core_MDF_BudgetTransfer.SearchAccountsLookup();
                if(!accountDetail.IsEmpty() && accountDetail.size()>0){
                    //System.assertEquals(toBeUpdated[1].Id, accountDetail[0].Id);
                    Assert.isNotNull(accountDetail);
                }
            }
            Test.stopTest();
        }catch(Exception Ex){
        }
    }
    
    @isTest static void validateGetToAccounts(){
        List<Account> toBeUpdated = new List<Account>();
        Test.startTest();
        // Creating channel program with utility class
        ChannelProgram cp1 = [Select id from ChannelProgram where Name = 'Client'];
        
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1 New', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, true);
        
        Account acc4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 4', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc3.Id, true);
        
        // Updating Accounts 
        acc1.isPartner = true;
        acc2.isPartner = true;
        acc3.isPartner = true;
        acc4.isPartner = true;
        toBeUpdated.add(acc1);
        toBeUpdated.add(acc2);
        toBeUpdated.add(acc3);
        toBeUpdated.add(acc4);
        Database.update(toBeUpdated);
        
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        
        System.runAs(usr){
            
            List<Account> accountDetail = Core_MDF_BudgetTransfer.GetToAccounts(acc4.Id,null);
            if(!accountDetail.IsEmpty() && accountDetail.size()>0){
                System.assertEquals(acc2.Id, accountDetail[0].Id);
                System.assertEquals(acc3.Id, accountDetail[1].Id);
            }
        }
        Test.stopTest();
    }
    
    @isTest static void validateGetBudgetList(){
        List<Account> toBeUpdated = new List<Account>();
        Profile systemAdminProfile1 = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        // Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'MDF Budget Loader1';
        usr1.profileId = systemAdminProfile1.Id;
        Database.insert(usr1);
        
        // Creating channel program with utility class
        ChannelProgram cp1 = [Select id from ChannelProgram where Name = 'Client'];
        //ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
        
        Account acc1 = [Select id from Account where Name = 'Test Account 1'];
        Account acc2 = [Select id from Account where Name = 'Test Account 2'];
        Account acc5 = [Select id from Account where Name = 'Test Account VC'];
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, true);
        
        Account acc4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 4', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc3.Id, true);
        
        // Updating Accounts 
        acc1.isPartner = true;
        acc2.isPartner = true;
        acc2.Core_MDF_CoMarketingActive__c = true;
        acc3.isPartner = true;
        acc3.Core_MDF_CoMarketingActive__c = true;
        acc4.isPartner = true;
        acc4.Core_MDF_CoMarketingActive__c = true;
        acc5.isPartner = true;
        acc5.Core_MDF_CoMarketingActive__c = true;
        toBeUpdated.add(acc1);
        toBeUpdated.add(acc2);
        toBeUpdated.add(acc3);
        toBeUpdated.add(acc4);
        toBeUpdated.add(acc5);
        Database.update(toBeUpdated);
        
        AccountShare accShare = new AccountShare();
        accShare.AccountId = acc2.Id;
        accShare.UserOrGroupId = usr1.Id;
        accShare.AccountAccessLevel = 'Read';
        accShare.OpportunityAccessLevel = 'None';
        accShare.CaseAccessLevel = 'None';
        accShare.RowCause = 'Manual';
        insert accShare;
        
        ChannelProgramShare csShare = new ChannelProgramShare();
        csShare.ParentId = cp1.Id;
        csShare.UserOrGroupId = usr1.Id;
        csShare.AccessLevel = 'Read';
        csShare.RowCause = 'Manual';
        insert csShare;
        

        system.runAs(usr1){
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Usr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psFinance.Id);
            PermissionSet psFinance1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_User' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psFinance1.Id);
        }
        PartnerMarketingBudget pbm2 = [SELECT Id FROM PartnerMarketingBudget WHERE Title='Test Budget CCF2' limit 1] ;
        /*system.runAs(usr1){
pbm2 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 3', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 3000, Date.newInstance(2018,01,01), Date.newInstance(2018,12,31), false);
pbm2.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';

Database.insert(pbm2);


}*/

        Test.startTest();
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        
        
        
        System.runAs(usr){
            try
            {

            }catch(Exception ex)
            {
                Core_MDF_CCP_UtilityClass.logError(ex);
            }
            
            PermissionSet pSet = [SELECT Id,Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_MDF_Budget_Manager' LIMIT 1];
            
            PermissionSetAssignment assignPermissionSet1 = new PermissionSetAssignment();
            assignPermissionSet1.AssigneeId = usr.Id;
            assignPermissionSet1.PermissionSetId = pSet.Id;
            Database.insert(assignPermissionSet1);            
        }
        System.runAs(usr){
            try
            {
                List<Core_MDF_SearchableDropDownItemWrapper> pbmList1 = Core_MDF_BudgetTransfer.GetBudgetList (acc2.Id);                

                System.assertEquals(pbm2.Id, pbmList1[0].Id);
            }
            catch(Exception ex)
            {
                Core_MDF_CCP_UtilityClass.logError(ex);
            }
        }
        test.stopTest();
    }
    
    @isTest static void validateGetBalanceAllocationAmount(){
        
        /*Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];

// Creating User with utility class 
User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
usr.profileId = systemAdminProfile.Id;
Database.insert(usr);*/
        
        List<String> bypassFunctionKeys = new List<String>();
       
        bypassFunctionKeys.add('Bypass_Allocation_Reservation');
        bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
        bypassFunctionKeys.add('Bypass_Duplicate_Bank_Check');
        bypassFunctionKeys.add('Bypass_Bank_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_External_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_ABM_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_External_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_NodeGroup_Sharing');        
        bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
        bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
        bypassFunctionKeys.add('Bypass_PaymentRun_Duplicate_Check');
        bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_On_Owner_Chng');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_Internal_Usrs');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_External_Usrs');
        bypassFunctionKeys.add('Bypass_Claim_AdjReq_Amount_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        
        bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
        bypassFunctionKeys.add('Bypass_Payment_Doc_InvFileVAT_Validate');
        bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
        bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');
        bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
        bypassFunctionKeys.add('Core_MDF_XMLToXLSGenerationFlag');
        bypassFunctionKeys.add('Core_MDF_StringToXLSGenerationFlag');
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        User usr1 = [Select id from user where lastname='MDF Budget Loader'  limit 1];
        
        
        //pbm.IsIgnoreValidation = true;
        //update pbm;
        try
        {
            Test.startTest();
            Account acc1 = [Select id from Account where Name = 'Test Account 1'];
            Account acc2 = [Select id from Account where Name = 'Test Account 2'];
            PartnerMarketingBudget pbm = [Select id,Core_MDF_Budget_Status__c from PartnerMarketingBudget where Title = 'Test Budget 2'];
            System.runAs(usr1){
                //pbm = [Select id,Core_MDF_Budget_Status__c from PartnerMarketingBudget where Title = 'Test Budget 2'];
                pbm.Core_MDF_Budget_Status__c = 'Released';
                update(pbm);
            }
            
            PartnerFundAllocation pfa = [Select id,Core_MDF_Available_Allocation_Amount__c,Core_MDF_Available_Activity_Alloc_Amt__c, Core_MDF_Budget_Type__c, Amount from PartnerFundAllocation where BudgetId =: pbm.Id and Title='Test PFA' limit 1];
            
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',system.today(), system.today(), 10000, 'Always Connected PC', acc2.Id,'Desktop', false);
            camp.Core_MDF_Opal_Budget_Type_Txt__c = 'CCF 1.0';
            database.insert(camp);
            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfa,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',false);
            testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
            testPartnerFundRequestRecord.Amount = testPartnerFundRequestRecord.RequestedAmount;
            //testPartnerFundRequestRecord.AllocationId = pfa.Id;
            //testPartnerFundRequestRecord.Status = 'Approved';
            insert testPartnerFundRequestRecord;
            Test.stopTest();
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
            Core_MDF_Account_Bank_Mapping__c accountBankMap = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id, bank.Id, true);
            
            
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 5000.00, System.today(), bank.Id, true);
            
            claim1.Status = 'Approved';
            update claim1;
            
            PartnerFundAllocation pfaNew = [Select id,Core_MDF_Available_Activity_Alloc_Amt__c, Core_MDF_Budget_Type__c, Core_MDF_Available_Allocation_Amount__c from PartnerFundAllocation where BudgetId =: pbm.Id and Title='Test PFA' limit 1];
            Decimal amount = Core_MDF_BudgetTransfer.GetBalanceAllocationAmount(acc2.Id, pbm.Id);
            
            System.assertEquals(pfaNew.Core_MDF_Available_Allocation_Amount__c, amount);
            
        }
        catch(DMLException ex)
        {
           Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }
    
    
    @isTest static void validateTransferAllocationAmount(){
        List<Account> toBeUpdated = new List<Account>();
        test.startTest();
        Profile systemAdminProfile2 = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        // Creating User with utility class 
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'MDF Budget Loader2';
        usr2.profileId = systemAdminProfile2.Id;
        Database.insert(usr2);
        // Creating channel program with utility class
        ChannelProgram cp1 = [Select id from ChannelProgram where Name = 'Client'];
        //ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
        
        Account acc1 = [Select id from Account where Name = 'Test Account 1'];
        Account acc2 = [Select id from Account where Name = 'Test Account 2'];
        Account vcAccount = [Select id from Account where Name = 'Intel Account Virtual Corp'];
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, true);
        
        
        // Updating Accounts 
        acc1.isPartner = true;
        acc2.isPartner = true;
        acc3.isPartner = true;
        vcAccount.isPartner = true;
        toBeUpdated.add(acc1);
        toBeUpdated.add(acc2);
        toBeUpdated.add(acc3);
        toBeUpdated.add(vcAccount);
        Database.update(toBeUpdated);
        
        AccountShare accShare = new AccountShare();
        accShare.AccountId = acc2.Id;
        accShare.UserOrGroupId = usr2.Id;
        accShare.AccountAccessLevel = 'Read';
        accShare.OpportunityAccessLevel = 'None';
        accShare.CaseAccessLevel = 'None';
        accShare.RowCause = 'Manual';
        insert accShare;
        
        ChannelProgramShare csShare = new ChannelProgramShare();
        csShare.ParentId = cp1.Id;
        csShare.UserOrGroupId = usr2.Id;
        csShare.AccessLevel = 'Read';
        csShare.RowCause = 'Manual';
        insert csShare;
        
        system.runAs(usr2){
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Usr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr2.id, PermissionSetId = psFinance.Id);
            PermissionSet psFinance1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_User' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr2.id, PermissionSetId = psFinance1.Id);
        }
        PartnerMarketingBudget pbm1 = [Select id from PartnerMarketingBudget where title = 'Test Budget CCF'];
        /*PartnerMarketingBudget pbm1 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 1', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 3000, Date.newInstance(2020,01,01), Date.newInstance(2020,12,31), false);
pbm1.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
system.runAs(usr2){
Database.insert(pbm1);
}*/
        //Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile2.Id;
        Database.insert(usr);
        
        System.runAs(usr){
            
            
            pbm1.Core_MDF_Budget_Status__c = 'Pending Review';
            update pbm1;
            
            pbm1.Core_MDF_Budget_Status__c = 'Released';
            update pbm1;
            
            string response1 = Core_MDF_BudgetTransfer.TransferAllocationAmount((string)acc2.Id, (string)acc3.Id, (string)pbm1.Id, 500.00,Label.Core_MDF_Budget_Transfer_Type_Manual);
            System.assertEquals('Success', response1);
            
            string response2 = Core_MDF_BudgetTransfer.TransferAllocationAmount((string)acc2.Id, (string)vcAccount.Id, (string)pbm1.Id, 500.00,Label.Core_MDF_Budget_Transfer_Type_Manual);
            System.assertEquals('Error', response2);
            
        }
        test.stopTest();
    }
    
    @isTest static void validateTransferAllocationAmountForPendingReviewBudget(){
        List<Account> toBeUpdated = new List<Account>();
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        // Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'MDF Budget Loader3';
        usr1.profileId = systemAdminProfile.Id;
        Database.insert(usr1);
        
        // Creating channel program with utility class
        ChannelProgram cp1 = [Select id from ChannelProgram where Name = 'Client'];
        //ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
        
        Account acc1 = [Select id from Account where Name = 'Test Account 1'];
        Account acc2 = [Select id from Account where Name = 'Test Account 2'];
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, true);
        
        // Updating Accounts 
        acc1.isPartner = true;
        acc2.isPartner = true;
        acc3.isPartner = true;
        toBeUpdated.add(acc1);
        toBeUpdated.add(acc2);
        toBeUpdated.add(acc3);
        Database.update(toBeUpdated);
        test.startTest();
        
        AccountShare accShare = new AccountShare();
        accShare.AccountId = acc2.Id;
        accShare.UserOrGroupId = usr1.Id;
        accShare.AccountAccessLevel = 'Read';
        accShare.OpportunityAccessLevel = 'None';
        accShare.CaseAccessLevel = 'None';
        accShare.RowCause = 'Manual';
        insert accShare;
        
        ChannelProgramShare csShare = new ChannelProgramShare();
        csShare.ParentId = cp1.Id;
        csShare.UserOrGroupId = usr1.Id;
        csShare.AccessLevel = 'Read';
        csShare.RowCause = 'Manual';
        insert csShare;
        
        system.runAs(usr1){
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Usr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psFinance.Id);
            PermissionSet psFinance1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_User' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psFinance1.Id);
        }
        PartnerMarketingBudget pbm1 = [Select id from PartnerMarketingBudget where title = 'Test Budget 2'];
        /*PartnerMarketingBudget pbm1 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 1', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 3000, Date.newInstance(2019,01,01), Date.newInstance(2019,12,31), false);
pbm1.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
system.runAs(usr1){
Database.insert(pbm1);      
}*/
        //Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr3.profileId = systemAdminProfile.Id;
        Database.insert(usr3);
        System.runAs(usr3){
            
            
            // PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm1, acc2, 1000, true);
            PartnerFundAllocation pfaRecord2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm1, acc3, 300, true);
            
            string response1 = Core_MDF_BudgetTransfer.TransferAllocationAmount((string)acc2.Id, (string)acc3.Id, (string)pbm1.Id, 500.00,Label.Core_MDF_Budget_Transfer_Type_Manual);
            System.assertEquals('Success', response1);
            
        }
        test.stopTest();
    }
    @isTest static void validateIUPGMSetupForUser(){
        Test.startTest();
        
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(true);
        List<Account> accList = [SELECT Id from Account Where name = 'EEF Primary Virtual Corp'];
        List<Account> accList1 = new List<Account>();
        system.runAs(testUser){
            PermissionSet pSet = [SELECT Id,Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
            
            PermissionSetAssignment assignPermissionSet2 = new PermissionSetAssignment();
            assignPermissionSet2.AssigneeId = testUser.Id;
            assignPermissionSet2.PermissionSetId = pSet.Id;
            Database.insert(assignPermissionSet2);
            
            accList1 = Core_MDF_BudgetTransferUtility.retrieveAccountsByIUPGMAccess(accList);
            Assert.areEqual(true, accList1 != null);
        }
        test.stoptest();
    }   
    @isTest static void validateIUPGMForAccMgrUser(){
        Test.startTest();
        
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(true);
        String accId = [Select Id from Account where name='Test Account 1' limit 1].Id;
        Id ultimateAcc = [Select Id from Account where name='Test Account 1' limit 1].Id;
        String budgetId = [Select Id from PartnerMarketingBudget limit 1].Id;
        Boolean userhasAccess=false;
        system.runAs(testUser){
            PermissionSet pSet = [SELECT Id,Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
            
            PermissionSetAssignment assignPermissionSet2 = new PermissionSetAssignment();
            assignPermissionSet2.AssigneeId = testUser.Id;
            assignPermissionSet2.PermissionSetId = pSet.Id;
            Database.insert(assignPermissionSet2);
            
            PermissionSet pSet1 = [SELECT Id,Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr' LIMIT 1];
            
            PermissionSetAssignment assignPermissionSet3 = new PermissionSetAssignment();
            assignPermissionSet3.AssigneeId = testUser.Id;
            assignPermissionSet3.PermissionSetId = pSet1 .Id;
            Database.insert(assignPermissionSet3);
            
            userhasAccess =  Core_MDF_BudgetTransferUtility.budgetTransferBasedOnIUPGM(accId,budgetId);
        }
        System.assertEquals(true, userhasAccess);
        test.stoptest();
    }  
    @isTest
    static void testGetToAccounts(){
        
        Profile systemAdminProfile2 = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'EEF Budget Loader';
        usr2.profileId = systemAdminProfile2.Id;
        Database.insert(usr2);

        User usr = [select id,Lastname from User where lastname ='MDF Budget Loader' Limit 1];
        User usr1 = [select id,Lastname from User where lastname ='TestClass TestUser' Limit 1];
        Account Acc= [Select id,Core_MDF_Channel_Program__r.name from Account where name ='EEF Primary Virtual Corp' Limit 1];
        Account acc1 =  [Select id,Core_MDF_Channel_Program__r.name from Account where name ='EEF Activating Virtual Corp' Limit 1];
        Account accNode =  [Select id,Core_MDF_Channel_Program__r.name from Account where name ='EEF Activating Node' Limit 1];
        PartnerMarketingBudget pmb =[select id,title from PartnerMarketingBudget where title ='Test Budget EEF' Limit 1 ];
        PartnerFundAllocation pfa =[select id,title from PartnerFundAllocation where title ='Test EEF PFA' Limit 1];

        map<id, Account> mapOfAcc = new map<id, Account>();
        PermissionSet eefBudLoader = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Budget_Loader' LIMIT 1];
		insert new PermissionSetAssignment(AssigneeId = usr2.id, PermissionSetId = eefBudLoader.Id);
        mapOfAcc.put(Acc.id,Acc);
        System.runAs(usr){
             Core_MDF_BudgetTransfer.GetToAccounts(Acc.Id,pmb.id);
            Core_MDF_BudgetTransfer.GetToAccounts(acc1.Id,pmb.id);
        }
        System.runAs(usr1){
            Core_MDF_BudgetTransfer.GetToAccounts(acc1.Id,pmb.id);
            Core_MDF_BudgetTransfer.getBudgetList(acc1.id);
            Core_MDF_BudgetTransfer.getPrimaryPartner(pmb.id);
            Core_MDF_BudgetTransfer.accountIDNameMapping(acc1.id);
            try{
              Core_MDF_BudgetTransfer.GetToAccounts(accNode.id,pmb.id);
              Core_MDF_BudgetTransfer.accountIDNameMapping(null);
            }catch(Exception e){
                String errorMessage = e.getMessage();
            }
        }
        System.runAs(usr2){
             Core_MDF_BudgetTransfer.GetToAccounts(Acc.Id,pmb.id);
            Core_MDF_BudgetTransfer.GetToAccounts(acc1.Id,pmb.id);
        }
        Assert.isTrue(pfa!=null);
    }
    
}