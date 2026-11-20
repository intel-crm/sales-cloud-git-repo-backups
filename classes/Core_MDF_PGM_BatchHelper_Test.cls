@isTest(SeeAllData=false)
public class Core_MDF_PGM_BatchHelper_Test{
    
    @TestSetup static void setUpData() {
           
          Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<User> userList = new List<User>();
        
        List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
        
        Profile coreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
        
        PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];        
        PermissionSet rmfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Price_Reviewer' LIMIT 1];
        PermissionSet cscClaimSubPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_Internal_CSC_User' LIMIT 1];

        
        UserRole adminRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];              
        
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test1231';
        usr.UserRoleId = adminRole.Id;
        userList.add(usr);
        
        database.insert(userList);        
        
        system.runAs(usr){
            
            List<String> bypassFunctionKeysTemp = new List<String>();
            bypassFunctionKeysTemp.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeysTemp.add('Bypass_MDF_Budget_Status_Validation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeysTemp);
            result1.addAll(myset1);

            Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            //Create Exchnage rates records
            List<Core_MDF_Currency_Exchange_Rates__c> newValues = new List<Core_MDF_Currency_Exchange_Rates__c>();            
            Core_MDF_Currency_Exchange_Rates__c record1 = new Core_MDF_Currency_Exchange_Rates__c();
            record1.Name= 'ZMK';
            record1.Core_MDF_Exchange_Rate__c = 0.0000850159;
            record1.Core_MDF_Market_Date__c =System.today()-2;
            record1.Core_MDF_Intel_WW__c = 'WW 46';
            newValues.add(record1);
            
            Core_MDF_Currency_Exchange_Rates__c record2 = new Core_MDF_Currency_Exchange_Rates__c();
            record2.Name= 'INR';
            record2.Core_MDF_Exchange_Rate__c = 1;
            record2.Core_MDF_Market_Date__c =System.today()-2;
            record2.Core_MDF_Intel_WW__c = 'WW 46';
            newValues.add(record2); 
            
            Core_MDF_Currency_Exchange_Rates__c record3 = new Core_MDF_Currency_Exchange_Rates__c();
            record3.Name= 'USD';
            record3.Core_MDF_Exchange_Rate__c = 1;
            record3.Core_MDF_Market_Date__c =System.today()-2;
            record3.Core_MDF_Intel_WW__c = 'WW 46';
            newValues.add(record3);             
            
            Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount aObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
            Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount bObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
            Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount cObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
            List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> listvar = new List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>();
            
            aObj.inputCurrency ='ZMK';
            aObj.inputAmount = 250.00;
            aObj.inputDate= date.newInstance(2018, 11, 13);
            bObj.inputCurrency ='INR';
            bObj.inputAmount = 350.00;
            bObj.inputDate= date.newInstance(2018, 11, 12);
            cObj.inputCurrency ='USD';
            cObj.inputAmount = 350.00;
            cObj.inputDate= date.newInstance(2018, 11, 12);
            listvar.add(aObj);
            listvar.add(bObj);
            listvar.add(cObj);
            Core_MDF_CCP_Multicurrency.getUSDExchangeRateBasedOnDate(listvar);
            
            database.insert(newValues);   
            
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
        bypassFunctionKeys.add('Core_MDF_Bypass_AccOnboardValidation');
          
            List<Core_Trigger_Executions__c> bypassfunctinalitylist = Core_MDF_CCP_TestDataUtility.byPassFeature(bypassFunctionKeys,true,true);
            
            List<Core_Trigger_Executions__c> executionList = new List<Core_Trigger_Executions__c>();
            
            Core_Trigger_Executions__c accountShareSetting = new Core_Trigger_Executions__c();
            accountShareSetting.Core_Active__c = true;
            accountShareSetting.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            accountShareSetting.Core_Trigger_Events__c = 'after insert';
            accountShareSetting.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
            accountShareSetting.Name = 'createAccountShareRecords';
            accountShareSetting.Core_Description__c = 'test';
            executionList.add(accountShareSetting);
            
            Core_Trigger_Executions__c psScoreShareSetting = new Core_Trigger_Executions__c();
            psScoreShareSetting.Core_Active__c = true;
            psScoreShareSetting.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            psScoreShareSetting.Core_Trigger_Events__c = 'after insert';
            psScoreShareSetting.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
            psScoreShareSetting.Name = 'createPartnerShipScoreShareRecords';
            psScoreShareSetting.Core_Description__c = 'test';
            executionList.add(psScoreShareSetting);
            
            Core_Trigger_Executions__c budgetShare = new Core_Trigger_Executions__c();
            budgetShare.Core_Active__c = true;
            budgetShare.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            budgetShare.Core_Trigger_Events__c = 'after insert';
            budgetShare.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
            budgetShare.Name = 'createBudgetShareRecords';
            budgetShare.Core_Description__c = 'test';
            executionList.add(budgetShare);
            
            Core_Trigger_Executions__c budgetCapShare = new Core_Trigger_Executions__c();
            budgetCapShare.Core_Active__c = true;
            budgetCapShare.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            budgetCapShare.Core_Trigger_Events__c = 'after insert';
            budgetCapShare.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
            budgetCapShare.Name = 'createBudgetCapShareRecords';
            budgetCapShare.Core_Description__c = 'test';
            executionList.add(budgetCapShare);
            
            Core_Trigger_Executions__c campaignShare = new Core_Trigger_Executions__c();
            campaignShare.Core_Active__c = true;
            campaignShare.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            campaignShare.Core_Trigger_Events__c = 'after insert';
            campaignShare.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
            campaignShare.Name = 'createCampaignShareRecords';
            campaignShare.Core_Description__c = 'test';
            executionList.add(campaignShare);
            
            Core_Trigger_Executions__c pfrShare = new Core_Trigger_Executions__c();
            pfrShare.Core_Active__c = true;
            pfrShare.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            pfrShare.Core_Trigger_Events__c = 'after insert';
            pfrShare.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
            pfrShare.Name = 'createPFRShareRecords';
            pfrShare.Core_Description__c = 'test';
            executionList.add(pfrShare);
            
            Core_Trigger_Executions__c claimShare = new Core_Trigger_Executions__c();
            claimShare.Core_Active__c = true;
            claimShare.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            claimShare.Core_Trigger_Events__c = 'after insert';
            claimShare.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
            claimShare.Name = 'createClaimAndPaymentShareRecords';
            claimShare.Core_Description__c = 'test';
            executionList.add(claimShare);
            
            Core_Trigger_Executions__c auditDocShare = new Core_Trigger_Executions__c();
            auditDocShare.Core_Active__c = true;
            auditDocShare.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            auditDocShare.Core_Trigger_Events__c = 'after insert';
            auditDocShare.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
            auditDocShare.Name = 'createAuditDocumentShareRecords';
            auditDocShare.Core_Description__c = 'test';
            executionList.add(auditDocShare);
            
            Core_Trigger_Executions__c pfaShare = new Core_Trigger_Executions__c();
            pfaShare.Core_Active__c = true;
            pfaShare.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            pfaShare.Core_Trigger_Events__c = 'after insert';
            pfaShare.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
            pfaShare.Name = 'createAllocationShareRecords';
            pfaShare.Core_Description__c = 'test';
            executionList.add(pfaShare);
            
            Core_Trigger_Executions__c pnumShare = new Core_Trigger_Executions__c();
            pnumShare.Core_Active__c = true;
            pnumShare.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            pnumShare.Core_Trigger_Events__c = 'after insert';
            pnumShare.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
            pnumShare.Name = 'createAccountUserShareRecords';
            pnumShare.Core_Description__c = 'test';
            executionList.add(pnumShare);
            
            Core_Trigger_Executions__c atlShare = new Core_Trigger_Executions__c();
            atlShare.Core_Active__c = true;
            atlShare.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            atlShare.Core_Trigger_Events__c = 'after insert';
            atlShare.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
            atlShare.Name = 'createAccountTransferLogShareRecords';
            atlShare.Core_Description__c = 'test';
            executionList.add(atlShare);
            
            Core_Trigger_Executions__c adjustmentShare = new Core_Trigger_Executions__c();
            adjustmentShare.Core_Active__c = true;
            adjustmentShare.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            adjustmentShare.Core_Trigger_Events__c = 'after insert';
            adjustmentShare.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
            adjustmentShare.Name = 'createAdjustmentRequestShareRecords';
            adjustmentShare.Core_Description__c = 'test';
            executionList.add(adjustmentShare);
            
            Core_Trigger_Executions__c caseShare = new Core_Trigger_Executions__c();
            caseShare.Core_Active__c = true;
            caseShare.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            caseShare.Core_Trigger_Events__c = 'after insert';
            caseShare.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
            caseShare.Name = 'createCaseShareRecords';
            caseShare.Core_Description__c = 'test';
            executionList.add(caseShare);
            
            Core_Trigger_Executions__c bankShare = new Core_Trigger_Executions__c();
            bankShare.Core_Active__c = true;
            bankShare.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            bankShare.Core_Trigger_Events__c = 'after insert';
            bankShare.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
            bankShare.Name = 'createBankShareRecords';
            bankShare.Core_Description__c = 'test';
            executionList.add(bankShare);
            
            Core_Trigger_Executions__c abmShare = new Core_Trigger_Executions__c();
            abmShare.Core_Active__c = true;
            abmShare.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            abmShare.Core_Trigger_Events__c = 'after insert';
            abmShare.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
            abmShare.Name = 'createAccBankMappingShareRecords';
            abmShare.Core_Description__c = 'test';
            executionList.add(abmShare);
            
            Core_Trigger_Executions__c exceptionShare = new Core_Trigger_Executions__c();
            exceptionShare.Core_Active__c = true;
            exceptionShare.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            exceptionShare.Core_Trigger_Events__c = 'after insert';
            exceptionShare.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
            exceptionShare.Name = 'createExceptionShareRecords';
            exceptionShare.Core_Description__c = 'test';
            executionList.add(exceptionShare);
            
            Core_Trigger_Executions__c escalationShare = new Core_Trigger_Executions__c();
            escalationShare.Core_Active__c = true;
            escalationShare.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            escalationShare.Core_Trigger_Events__c = 'after insert';
            escalationShare.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
            escalationShare.Name = 'createEscalationShareRecords';
            escalationShare.Core_Description__c = 'Test1';
            executionList.add(escalationShare);
            
            Core_Trigger_Executions__c ecmShare = new Core_Trigger_Executions__c();
            ecmShare.Core_Active__c = true;
            ecmShare.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            ecmShare.Core_Trigger_Events__c = 'after insert';
            ecmShare.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
            ecmShare.Name = 'createECMShareRecords';
            ecmShare.Core_Description__c = 'Test1';
            executionList.add(ecmShare);
            
            Core_Trigger_Executions__c setting = new Core_Trigger_Executions__c();
            setting.Core_Active__c = false;
            setting.Core_Class_Name__c = 'Core_MDF_AdjustmentClaimOffsetProcess';
            setting.Core_Description__c = 'Demo Description';
            setting.Core_Object__c = 'Core_MDF_Payment_Run__c';
            setting.Core_Trigger_Events__c = 'after insert';
            setting.name = 'Core_MDF_AdjustmentClaimOffsetProcess';
            executionList.add(setting);
            
            Core_Trigger_Executions__c accountShareSetting1 = new Core_Trigger_Executions__c();
            accountShareSetting1.Core_Active__c = true;
            accountShareSetting1.Core_Class_Name__c = 'Core_MDF_Payment_Sharing';
            accountShareSetting1.Core_Trigger_Events__c = 'after insert';
            accountShareSetting1.Core_Object__c = 'Core_MDF_Payment__c';
            accountShareSetting1.Name = 'Bypass_PaymentsBulkAPISharing';
            accountShareSetting1.Core_Description__c = 'test';
            executionList.add(accountShareSetting1);
            
             Core_Trigger_Executions__c accountShareSettingEEF = new Core_Trigger_Executions__c();
            accountShareSettingEEF.Core_Active__c = true;
            accountShareSettingEEF.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            accountShareSettingEEF.Core_Trigger_Events__c = 'after insert';
            accountShareSettingEEF.Core_Object__c = 'Core_MDF_Payment__c';
            accountShareSettingEEF.Name = 'CreateAccountShareRecordsEEF';
            accountShareSettingEEF.Core_Description__c = 'test';
            executionList.add(accountShareSettingEEF);
            
             Core_Trigger_Executions__c pSShareSettingEEF = new Core_Trigger_Executions__c();
            pSShareSettingEEF.Core_Active__c = true;
            pSShareSettingEEF.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            pSShareSettingEEF.Core_Trigger_Events__c = 'after insert';
            pSShareSettingEEF.Core_Object__c = 'Core_MDF_Payment__c';
            pSShareSettingEEF.Name = 'createPartnerShipScoreShareRecordsEEF';
            pSShareSettingEEF.Core_Description__c = 'test';
            executionList.add(pSShareSettingEEF);
            
             Core_Trigger_Executions__c accountUserShareSettingEEF = new Core_Trigger_Executions__c();
            accountUserShareSettingEEF.Core_Active__c = true;
            accountUserShareSettingEEF.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            accountUserShareSettingEEF.Core_Trigger_Events__c = 'after insert';
            accountUserShareSettingEEF.Core_Object__c = 'Core_MDF_Payment__c';
            accountUserShareSettingEEF.Name = 'createAccountUserShareRecordsEEF';
            accountUserShareSettingEEF.Core_Description__c = 'test';
            executionList.add(accountUserShareSettingEEF);
            
             Core_Trigger_Executions__c allocationShareSettingEEF = new Core_Trigger_Executions__c();
            allocationShareSettingEEF.Core_Active__c = true;
            allocationShareSettingEEF.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            allocationShareSettingEEF.Core_Trigger_Events__c = 'after insert';
            allocationShareSettingEEF.Core_Object__c = 'Core_MDF_Payment__c';
            allocationShareSettingEEF.Name = 'createAllocationShareRecordsEEF';
            allocationShareSettingEEF.Core_Description__c = 'test';
            executionList.add(allocationShareSettingEEF);
            
             Core_Trigger_Executions__c accountTransferShareSetting1 = new Core_Trigger_Executions__c();
            accountTransferShareSetting1.Core_Active__c = true;
            accountTransferShareSetting1.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            accountTransferShareSetting1.Core_Trigger_Events__c = 'after insert';
            accountTransferShareSetting1.Core_Object__c = 'Core_MDF_Payment__c';
            accountTransferShareSetting1.Name = 'createAccountTransferLogShareRecsEEF';
            accountTransferShareSetting1.Core_Description__c = 'test';
            executionList.add(accountTransferShareSetting1);
            
             Core_Trigger_Executions__c budgetShareSettingEEF = new Core_Trigger_Executions__c();
            budgetShareSettingEEF.Core_Active__c = true;
            budgetShareSettingEEF.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            budgetShareSettingEEF.Core_Trigger_Events__c = 'after insert';
            budgetShareSettingEEF.Core_Object__c = 'Core_MDF_Payment__c';
            budgetShareSettingEEF.Name = 'createBudgetShareRecordsEEF';
            budgetShareSettingEEF.Core_Description__c = 'test';
            executionList.add(budgetShareSettingEEF);
            
            Core_Trigger_Executions__c campShareSettingEEF = new Core_Trigger_Executions__c();
            campShareSettingEEF.Core_Active__c = true;
            campShareSettingEEF.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            campShareSettingEEF.Core_Trigger_Events__c = 'after insert';
            campShareSettingEEF.Core_Object__c = 'Core_MDF_Payment__c';
            campShareSettingEEF.Name = 'createCampaignShareRecordsEEF';
            campShareSettingEEF.Core_Description__c = 'test';
            executionList.add(campShareSettingEEF);
            
            Core_Trigger_Executions__c cmpToActShareSettingEEF = new Core_Trigger_Executions__c();
            cmpToActShareSettingEEF.Core_Active__c = true;
            cmpToActShareSettingEEF.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            cmpToActShareSettingEEF.Core_Trigger_Events__c = 'after insert';
            cmpToActShareSettingEEF.Core_Object__c = 'Core_MDF_Payment__c';
            cmpToActShareSettingEEF.Name = 'createCampToActShareRecordsEEF';
            cmpToActShareSettingEEF.Core_Description__c = 'test';
            executionList.add(cmpToActShareSettingEEF);
            
            Database.insert(executionList);
            
            List<Core_MDF_Configuration__c> mdfRecTypesList = new List<Core_MDF_Configuration__c>();
            
            Core_MDF_Configuration__c mdfbudgTypes= new Core_MDF_Configuration__c();
            mdfbudgTypes.name='BUDGET_TYPE_CLAIM_BANK_HIDE';
            mdfbudgTypes.Core_MDF_Value__c='MDF,MDF+';
            mdfRecTypesList.add(mdfbudgTypes);
            
            Core_MDF_Configuration__c Programs_For_MDF_PaymentRun= new Core_MDF_Configuration__c();
            Programs_For_MDF_PaymentRun.name='Programs_For_MDF_PaymentRun';
            Programs_For_MDF_PaymentRun.Core_MDF_Value__c='Client Co-Marketing Fund,Data Center Co-Marketing Fund';
            mdfRecTypesList.add(Programs_For_MDF_PaymentRun);            
            
            Database.insert(mdfRecTypesList);
            
            User accMgr =  Core_MDF_CCP_TestDataUtility.createUser(false);
            accMgr.profileId = coreProfile.Id;
            accMgr.LastName = 'IUPGM Test User';
            accMgr.UserRoleId = adminRole.Id;
            insert accMgr;
            
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = accMgr.Id);           
            database.insert(psa);
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = rmfAccManagerPS.Id, AssigneeId = accMgr.Id);           
            database.insert(psa1);
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = cscClaimSubPS.Id, AssigneeId = accMgr.Id);           
            database.insert(psa2);

            
            //Creating channel program 
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);                     
            ChannelProgram rmfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            
            List<ChannelProgramShare> cpSharelist = new List<ChannelProgramShare>();
            ChannelProgramShare csShare = new ChannelProgramShare();
            csShare.ParentId = ccfCp.Id;
            csShare.UserOrGroupId = accMgr.Id;
            csShare.AccessLevel = 'Read';
            csShare.RowCause = 'Manual';
            cpSharelist.add(csShare);
            
            ChannelProgramShare csShare1 = new ChannelProgramShare();
            csShare1.ParentId = rmfCp.Id;
            csShare1.UserOrGroupId = accMgr.Id;
            csShare1.AccessLevel = 'Read';
            csShare1.RowCause = 'Manual';
            cpSharelist.add(csShare1);
            Database.insert(cpSharelist);
            
            //Creating Intel Account
            Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Intel Account', 
                                                                                    Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                                    false);
            intelAccount.Core_Account_Type__c = 'Reseller';
            intelAccount.Industry = 'Food & Beverage';
            intelAccount.Core_MDF_CoMarketingActive__c=true;
            Database.insert(intelAccount);
            
            //Creating Intel Account for RMF program
            Account rmfintelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Retail Intel Account', 
                                                                                       Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                                       false);
            rmfintelAccount.Core_Account_Type__c = 'Reseller';
            rmfintelAccount.Industry = 'Food & Beverage';
            rmfintelAccount.Core_MDF_CoMarketingActive__c=true;
            Database.insert(rmfintelAccount);
            
            List<AccountShare> accShareList = new List<AccountShare>();
            AccountShare accshareRecordCCFWW = new AccountShare();
            accshareRecordCCFWW.AccountId = intelAccount.Id;
            accshareRecordCCFWW.UserOrGroupId = accMgr.Id;
            accshareRecordCCFWW.RowCause = 'Manual';
            accshareRecordCCFWW.AccountAccessLevel = 'Read';
            accshareRecordCCFWW.OpportunityAccessLevel = 'None';
            accshareRecordCCFWW.CaseAccessLevel = 'None';
            accShareList.add(accshareRecordCCFWW); //insert accshareRecordCCFWW;
            
            AccountShare accshareRecordRMFWW = new AccountShare();
            accshareRecordRMFWW.AccountId = rmfintelAccount.Id;
            accshareRecordRMFWW.UserOrGroupId = accMgr.Id;
            accshareRecordRMFWW.RowCause = 'Manual';
            accshareRecordRMFWW.AccountAccessLevel = 'Read';
            accshareRecordRMFWW.OpportunityAccessLevel = 'None';
            accshareRecordRMFWW.CaseAccessLevel = 'None';
            accShareList.add(accshareRecordRMFWW); //insert accshareRecordRMFWW;
            Database.insert(accShareList);
            
            List<Account> accList = new List<Account>();
            //Creating Co-marketing Account with utility class
            Account intelCCF = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', ccfCp.Id,
                                                                           Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            intelCCF.Core_MDF_Parent_Fund_Account__c = intelAccount.Id;
            intelCCF.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccount.Id;
            //accList.add(intelCCF);
            Database.insert(intelCCF);            
            
            Account intelCcfApj = Core_MDF_CCP_TestDataUtility.createAccount ('Second Level Account', ccfCp.Id,
                                                                              Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            intelCcfApj.Core_MDF_Parent_Fund_Account__c = intelCCF.Id;
            intelCcfApj.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccount.Id;
            accList.add(intelCcfApj);
            
            
            //Creating RMF Virtual corp with ASMO Region
            Account retailAccount = Core_MDF_CCP_TestDataUtility.createAccount ('Dell Retail Virtual Corp', rmfCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            retailAccount.Core_MDF_Parent_Fund_Account__c = intelAccount.Id;
            retailAccount.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccount.Id;
            retailAccount.Core_Geo__c = 'ASMO';
            retailAccount.Core_Sub_Geo__c = 'LAR';
            accList.add(retailAccount);  
            
            //Creating RMF Virtual Corp with PRC Region
            Account retailAccount1 = Core_MDF_CCP_TestDataUtility.createAccount ('Dell PRC Retail Virtual Corp', rmfCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            retailAccount1.Core_MDF_Parent_Fund_Account__c = rmfintelAccount.Id;
            retailAccount1.Core_MDF_CoMarketing_Ultimate_Account__c = rmfintelAccount.Id;
            retailAccount1.Core_Geo__c = 'PRC';
            accList.add(retailAccount1);
            Database.insert(accList); 
            
            //Create Master and Sub groups
            List<Group> groupRecords = new List<Group>();
            Group group1 = new Group();
            group1.developername = 'Core_MDF_PGM_Trigger_Test_Account_Group';
            group1.name='PGM Trigger Test Account Group';
            
            Group group2 = new Group();
            group2.developername = 'Core_MDF_Test_PGM_Trigger_CCF_Internal_All';
            group2.name='Test PGM Trigger CCF Internal All';
            
            Group group3 = new Group();
            group3.developername = 'Core_MDF_Test_PGM_Trigger_DCF_Internal_All';
            group3.name='Test PGM Trigger DCF Internal All';
            
            groupRecords.add(group1);groupRecords.add(group2);groupRecords.add(group3);
            
            Database.insert(groupRecords);
            assert.isNotNull(groupRecords);       
        
            //Creating Budget using utility class
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   intelCCF.Id,ccfCp.Id,5000000,
                                                                                   System.today()-10,System.today().addDays(110), false);            
            pmb.Core_MDF_Budget_Type_Txt__c='MDF';
            pmb.Core_MDF_Budget_Status__c ='Released';
            Database.insert(pmb);
            
            //Creating Allocation using utility class
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,intelCCF,1000000.0,true);
            
            //Creating Budget Cap
            Core_MDF_Budget_Cap__c budgetCap = new Core_MDF_Budget_Cap__c();
            budgetCap.Core_MDF_Cap_Type_nm__c = 'Channel Led Activity';
            budgetCap.Core_MDF_Budget_Name_id__c = pmb.Id;
            budgetCap.Core_MDF_Requested_Cap_amt__c = 100;
            budgetCap.Core_MDF_Approved_Cap_amt__c = 100;
            Database.insert(budgetCap);
            
             
            //Creating Account transfer log
            Core_MDF_Budget_Transfer_Log__c atl = new Core_MDF_Budget_Transfer_Log__c();    
            atl.Core_MDF_Partner_Marketing_Budget__c = pmb.Id;
            atl.Core_MDF_Source_Account__c = intelCCF.Id;
            atl.Core_MDF_Target_Account__c = intelCcfApj.Id;
            atl.Core_MDF_Transfer_Type__c = 'Manual';
            atl.Core_MDF_Transferred_Amount__c = 100;
            insert atl;
            
            //Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo','CMP only', 
                                                                        Core_MDF_CCP_TestDataUtility.campaign_RecordType_CCF,
                                                                        'Client CoMarketing Fund',System.today()-3,System.today().addDays(200), 
                                                                        2000,'FPGA',intelCCF.Id,'2-in-1', false);
            camp.Core_MDF_Opal_Budget_Type_Txt__c ='OEM CMP';
            database.insert(camp);
            
            test.startTest();
            
            //Creating activity
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(intelCCF.id),pfa,null,'INDIA','Creator',
                                                                                           'Desktop','Intel® Core™ i7 Processor','Broadcast (Pre-2025)',
                                                                                           'Radio','Draft',false);
            pfr.RequestedAmount = 500000;
            pfr.Amount = 500000;
            pfr.Core_MDF_Channel_Partner_Led__c = FALSE;
            pfr.Core_MDF_Start_Date__c = system.today();
            pfr.Core_MDF_End_Date__c = system.today() + 2;
            pfr.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            pfr.Core_MDF_Reimbursement_Rate_txt__c='60%';
            pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            pfr.Status = 'Approved';
            Database.insert(pfr);
            
            //Creating Bank
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(intelAccount.id,'Core_MDF_Client_CoMarketing_Fund',false,'1234567890');
            bank.Core_MDF_Bank_Status__c = 'Active'; 
            database.insert(bank);            
            
            //Creating ABM
             Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(intelCcf.Id,bank.Id,TRUE);            
            
            //Creating Claims
            PartnerFundClaim pfc = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim',Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,pfr.Id,System.today(),System.today(),20000,System.today(),bank.Id,false);
            pfc.Core_MDF_Country_Location_nm__c ='INDIA';
            pfc.Core_MDF_Currency__c = 'USD';
            pfc.Core_MDF_Status__c = 'Pending Payment';
            pfc.Status = Label.Core_MDF_Status_Approved;
            pfc.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
            Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
            database.insert(pfc);      
            List<ContentVersion> conVersionLst = new List<ContentVersion>();
            ContentVersion conVersion = new ContentVersion();
            conVersion.ContentLocation = 'S';
            conVersion.Title = 'Test';
            conVersion.PathOnClient='Test';
            conVersion.ReasonForChange = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ContentVersion_ReasonForChange');
            conVersion.VersionData = Blob.valueOf('content');
            conVersionLst.add(conVersion);
            Database.insert(conVersionLst); //Insert contentversion list
            ContentVersion contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN : conVersionLst limit 1];
            
            ContentDocument conDoc= [SELECT Id,OwnerId FROM ContentDocument WHERE Id =:contentVersions.ContentDocumentId limit 1];
            Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c(); 
            auditDoc.Core_MDF_Document_Id__c = conDoc.Id;
            auditDoc.Core_MDF_Document_Title__c = 'Test';
            auditDoc.Core_MDF_Claim__c = pfc.Id;
            auditDoc.Core_MDF_Document_Types__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDoc.Core_MDF_App_Document_Types_nm__c= 'Proof of Cost;Proof of Execution;Proof of Attribution';
            insert auditDoc;
            
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
            payRunRecord.Core_MDF_Program_Id__c  = ccfCp.Id;
            Database.insert(payRunRecord);                   
            
            
            Core_MDF_Payment__c pay = new Core_MDF_Payment__c();
            pay.Core_MDF_Payment_Run_Id__c = payRunRecord.Id;
            pay.Core_MDF_Payment_Status_Txt__c = 'Pending Payment';
            pay.Core_MDF_Paid_Amt__c = 1;   
            Insert pay;
            
            pfc.Core_MDF_Payment_Id__c = pay.Id;
            update pfc;
            
            Core_MDF_RecordGeoShare rec = new Core_MDF_RecordGeoShare(pay.Id,payRunRecord.Core_MDF_Geo_Txt__c,null, 'Client Co-marketing Fund' ,null);
            Core_MDF_RecordGeoShare rec1 = new Core_MDF_RecordGeoShare(pay.Id,payRunRecord.Core_MDF_Geo_Txt__c,null,null,intelAccount.Id, 'Client Co-marketing Fund');
            Core_MDF_RecordGeoShare rec2 = new Core_MDF_RecordGeoShare(pay.Id,payRunRecord.Core_MDF_Geo_Txt__c,null,intelAccount.Id,'Client Co-marketing Fund');
            Core_MDF_RecordGeoShare rec3 = new Core_MDF_RecordGeoShare(pay.Id,payRunRecord.Core_MDF_Geo_Txt__c,'Client Co-marketing Fund');
            Core_MDF_RecordGeoShare rec4 = new Core_MDF_RecordGeoShare(pay.Id,'Client Co-marketing Fund');
            List<Core_MDF_RecordGeoShare> recList = new  List<Core_MDF_RecordGeoShare>();
            recList.add(rec);
            //Core_MDF_ShareRecordToGeoGroup.shareRecordToGeoGroupBulkAPI('Core_MDF_Payment__c',recList);
            //Creating Case
            Case cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit_Closed').getRecordTypeId();
            cs.Status = 'Closed';
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = intelCCF.Id;
            cs.Core_MDF_Claim_ID__c = pfc.id;
            cs.Core_MDF_Region_SubRegion_txt__c = 'APJ - IJKK';
            database.insert(cs); 
            
            
            test.stopTest();
        }
    }
    
    @isTest
    static void testPnumSharing(){
        
        test.startTest();
        Account intelAccount = [SELECT Id, Name FROM Account where Name ='Intel Account' limit 1];
        
        ChannelProgram ccfCp = [SELECT Id, Name FROM ChannelProgram WHERE Name = 'Client' limit 1];
        
        Account intelCCF = [SELECT Id, Name FROM Account where Name ='Co-marketing Test Account' limit 1];
        
        Contact externalUser = Core_MDF_CCP_TestDataUtility.createContact(intelAccount.Id,true);     
        
        Core_AGS_Role__c agsRoleCCF = Core_MDF_CCP_TestDataUtility.createAgsRole('CCF_USER', 'Co-Marketing(Salesforce)-CCF USER', true, false);
        Database.insert(agsRoleCCF);
        
        Core_ERPM_Engagement__c erpmEngagementCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('CCF', 'CCF', 'DEDUPB2B', 'SEC', true, false);
        Database.insert(erpmEngagementCCF);
        
        Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('Client User',agsRoleCCF.Id ,'Intel Partner Alliance (IPA)','CCF User',erpmEngagementCCF.Id , true,'Client',false);
        Database.insert(entitlementCCF); 
        
        Core_Contact_Entitlement__c contactEntitlementCCF = Core_MDF_CCP_TestDataUtility.createContactEntitlement(externalUser.Id,entitlementCCF.Id ,true,'Complete', false);
        Database.insert(contactEntitlementCCF); 
        
        //Assigning external user with partner profile
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        
        User extUser = Core_MDF_CCP_TestDataUtility.createUser(false);        
        extUser.Email='test1@example.com';
        extUser.ContactId = externalUser.Id;
        extUser.ProfileId = profileId;
        extUser.isActive = true;
        Database.insert(extUser);
        
        Group grp = new Group();
        grp.name = 'PGM_TEST';
        insert grp;
        
        User testUser = [SELECT Id FROM User WHERE LastName = 'User Test1231'];
        
        System.runAs(testUser){
            GroupMember gm = new GroupMember();
            gm.GroupId = grp.Id;
            gm.UserOrGroupId = extUser.Id;
            insert gm;
        }        
        
        Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
        ccfPgm.Core_MDF_Account__c = intelAccount.Id;
        ccfPgm.Core_MDF_Group_Name__c = 'PGM_TEST';
        ccfPgm.Core_MDF_Type_of_Access__c = 'External';
        //ccfPgm.Core_MDF_Group_Id__c = grp.Id;
        ccfPgm.Core_MDF_Channel_Program__c = ccfCp.Id;
        ccfPgm.Core_MDF_Source_Txt__c = 'Test';
        Database.insert(ccfPgm);
        
        System.runAs(testUser){
            //Creating Acc User record
            Core_MDF_Partner_Node_User_Mapping__c pnumRecord = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(intelCCF.Id,extUser.Id,true);
        }
        
        User user = [SELECT Id FROM User WHERE LastName = 'IUPGM Test User' limit 1];
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = intelAccount.Id;
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        iupgm.Core_MDF_User_id__c = user.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        
        database.insert(iupgm);       
        
        List<Core_MDF_Partner_Group_Mapping__c> pgmList = [SELECT Id, Core_MDF_Account__c, Core_MDF_Channel_Program__c
                                                           FROM Core_MDF_Partner_Group_Mapping__c
                                                           WHERE Core_MDF_Account__c =: intelAccount.Id AND
                                                           Core_MDF_Channel_Program__c =: ccfCp.Id AND 
                                                           Core_MDF_Type_of_Access__c = 'Internal'];
        test.stopTest();
        
        Assert.areEqual(1, pgmList.Size());        
    }
    
    @isTest
    static void insertingIUPGM(){
        test.startTest();  
        Id budgetRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Budget').getRecordTypeId();
        Id caseRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId();
        Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();        
        
              
        Account acc = [SELECT Id, Name FROM Account where Name ='Intel Account' limit 1];
        
        ChannelProgram cp = [SELECT Id, Name FROM ChannelProgram WHERE Name = 'Client' limit 1];
        
        User user = [SELECT Id FROM User WHERE LastName = 'IUPGM Test User' limit 1];
        
        PartnerFundClaim pfc = [Select Id,Title from PartnerFundCLaim where Title ='Test Claim' limit 1];                

        /*Core_MDF_Adjustment_Request__c adjustment = new Core_MDF_Adjustment_Request__c();          
        adjustment.Core_MDF_Reference_Claim_Nbr__c = pfc.Id;
        adjustment.Core_MDF_Amount_Amt__c = 10;
        adjustment.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
        Database.insert(adjustment);*/
        
        Core_MDF_Partnership_Score__c PSC1=new Core_MDF_Partnership_Score__c();
        PSC1.Core_MDF_Account_Id__c=acc.Id;
        PSC1.Core_MDF_Channel_Program_Id__c =cp.Id;
        PSC1.Core_MDF_Program_nm__c ='Client CoMarketing Fund';
        PSC1.Core_MDF_Quarter_Year_Nm__c = 'Q2 2024';
        PSC1.Core_MDF_Quarter_nm__c='Q2';
        PSC1.Core_MDF_Year_nm__c='2024';
        PSC1.Core_MDF_Partnership_Score_Nbr__c=0.0;
        Database.insert(PSC1);
        
        //Activity for late claim escalation
        PartnerFundRequest pfrToBeEscalated = [select Id,Core_MDF_Activity_Number__c from PartnerFundRequest LIMIT 1];
        pfrToBeEscalated.Core_MDF_Fund_Request_Status__c = 'Closed';
        database.update(pfrToBeEscalated);
        
        //Budget for budget escalation
        PartnerMarketingBudget pmb = [SELECT id from PartnerMarketingBudget WHERE Title = 'Test Budget' LIMIT 1];
        
        //Case for claim review result escalation
        Case cs = [SELECT Id from Case where Status ='Closed' LIMIT 1];
        
        //PartnerFundClaim pfc = [Select Id,Title from PartnerFundCLaim where Title ='Test Claim' limit 1];                
        
        List<Core_MDF_Escalation__c> escList = new List<Core_MDF_Escalation__c>();
        
        Core_MDF_Escalation__c budgetEsc = new Core_MDF_Escalation__c();
        budgetEsc.Core_MDF_Escalation_Status_nm__c='Pending Review';
        budgetEsc.Core_MDF_Escalation_Name_txt__c='Test';
        budgetEsc.Core_MDF_Total_Dollar_Impact_amt__c= 56;
        budgetEsc.Core_MDF_Root_Cause_nm__c = 'Appeal of Budget';
        budgetEsc.Core_MDF_Budget_ID_Number_id__c = pmb.Id;
        budgetEsc.Core_MDF_Channel_Program_id__c = cp.Id;
        budgetEsc.recordtypeid = budgetRecType;
        escList.add(budgetEsc);
        
        Core_MDF_Escalation__c activityEsc = new Core_MDF_Escalation__c();
        activityEsc.Core_MDF_Escalation_Status_nm__c='Pending Review';
        activityEsc.Core_MDF_Escalation_Name_txt__c='Test1';
        activityEsc.Core_MDF_Total_Dollar_Impact_amt__c= 56;
        activityEsc.Core_MDF_Root_Cause_nm__c = 'Tools and Systems';
        activityEsc.Core_MDF_Co_Marketing_Activity_id__c = pfrToBeEscalated.Id;
        activityEsc.Core_MDF_Channel_Program_id__c = cp.Id;
        activityEsc.recordtypeid= claimRecType;
        //escList.add(activityEsc);        
        
        
        Core_MDF_Escalation__c caseEsc = new Core_MDF_Escalation__c();
        caseEsc.Core_MDF_Escalation_Status_nm__c='Pending Review';
        caseEsc.Core_MDF_Escalation_Name_txt__c='Test2';
        caseEsc.Core_MDF_Total_Dollar_Impact_amt__c= 45;
        caseEsc.Core_MDF_Root_Cause_nm__c = 'Claim Score Appeal';
        caseEsc.Core_MDF_Case_ID_Number_id__c = cs.Id;
        caseEsc.Core_MDF_Channel_Program_id__c = cp.Id;
        caseEsc.recordtypeid = caseRecType;
        //escList.add(caseEsc);
        
        database.insert(escList);
        
        /*Core_MDF_Adjustment_Request__c adjustment = new Core_MDF_Adjustment_Request__c();          
        adjustment.Core_MDF_Reference_Claim_Nbr__c = pfc.Id;
        adjustment.Core_MDF_Amount_Amt__c = 10;
        adjustment.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
        Database.insert(adjustment);*/
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        iupgm.Core_MDF_User_id__c = user.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        
        database.insert(iupgm);       
        
        List<Core_MDF_Partner_Group_Mapping__c> pgmList = [SELECT Id, Core_MDF_Account__c, Core_MDF_Channel_Program__c
                                                           FROM Core_MDF_Partner_Group_Mapping__c
                                                           WHERE Core_MDF_Account__c =: acc.Id AND
                                                           Core_MDF_Channel_Program__c =: cp.Id];
        test.stopTest();
        
        Assert.areEqual(1, pgmList.Size());
    }
     //Test RMF PNUM sharing where Account's region is ASMO 
    @isTest
    static void testRMFASMORegionPnumSharing(){
        
        test.startTest();
        Account intelAccount = [SELECT Id, Name FROM Account where Name ='Intel Account' limit 1];
        
        ChannelProgram rmfCp = [SELECT Id, Name FROM ChannelProgram WHERE Name = 'Retail Marketing Funds' limit 1];
        
        Account intelRMF = [SELECT Id, Name FROM Account where Name ='Dell Retail Virtual Corp' limit 1];
       
        Contact externalUser = Core_MDF_CCP_TestDataUtility.createContact(intelAccount.Id,true);     

        Core_ERPM_Engagement__c erpmEngagementRMF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('RPS_Retailer', 'RPS_Retailer', 'DEDUPGPRET', 'SEC', true, false);
        Database.insert(erpmEngagementRMF);
        
        Core_Entitlement__c entitlementRMF = Core_MDF_CCP_TestDataUtility.createEntitlement('RMF User',null,'Intel Partner Alliance (IPA)','RMF User',erpmEngagementRMF.Id , true,'Retail Marketing Funds (RMF)',false);
        Database.insert(entitlementRMF);
        
        Core_Contact_Entitlement__c contactEntitlementrmf = Core_MDF_CCP_TestDataUtility.createContactEntitlement(externalUser.Id,entitlementRMF.Id ,true,'Complete', false);
        Database.insert(contactEntitlementrmf);
        
        //Assigning external user with partner profile
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        
        User extUser = Core_MDF_CCP_TestDataUtility.createUser(false);        
        extUser.Email='test1@example.com';
        extUser.ContactId = externalUser.Id;
        extUser.ProfileId = profileId;
        extUser.isActive = true;
        Database.insert(extUser);
        
        Group grp = new Group();
        grp.name = 'PGM_TEST';
        insert grp;
        intelRMF.Core_MDF_External_Group_Id__c = grp.Id;
        update intelRMF;
        User testUser = [SELECT Id FROM User WHERE LastName = 'User Test1231'];
        
        System.runAs(testUser){
            GroupMember gm = new GroupMember();
            gm.GroupId = grp.Id;
            gm.UserOrGroupId = extUser.Id;
            insert gm;
        }        
        
        Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
        ccfPgm.Core_MDF_Account__c = intelAccount.Id;
        ccfPgm.Core_MDF_Group_Name__c = 'PGM_TEST';
        ccfPgm.Core_MDF_Type_of_Access__c = 'External';
        //ccfPgm.Core_MDF_Group_Id__c = grp.Id;
        ccfPgm.Core_MDF_Channel_Program__c = rmfCp.Id;
        ccfPgm.Core_MDF_Source_Txt__c = 'Test';
        Database.insert(ccfPgm);
        Map<Id,Core_MDF_Partner_Group_Mapping__c> pgmMap = new Map<Id,Core_MDF_Partner_Group_Mapping__c>();
        pgmMap.put(ccfPgm.Id,ccfPgm);
        Core_MDF_PGM_ServiceHandler.isInactiveIndicatorUpdated(pgmMap,pgmMap);
        System.runAs(testUser){
            Core_MDF_Partner_Node_User_Mapping__c pnumRecord = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(intelRMF.Id,extUser.Id,true);
        }
        try{
            Core_MDF_Partner_Node_User_Mapping__c pnumRecord1 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(intelRMF.Id,extUser.Id,true);
        }
        catch(Exception e){
                System.Assert(e.getMessage().contains(System.Label.Core_MDF_PNUMDuplicateError));
            }
        Map<Id,Id> userIdToAccountIdMap = new Map<Id,Id>();
        userIdToAccountIdMap.put(extUser.Id,intelRMF.Id);
        Map<Id,List<String>> inactivePgmAccountIdToPrgmsMap = new Map<Id,List<String>>();
        inactivePgmAccountIdToPrgmsMap.put(ccfPgm.Id,new List<String>{'Client'});
        Core_MDF_PGM_ServiceHandler.inactivatePnumRecords(userIdToAccountIdMap,inactivePgmAccountIdToPrgmsMap);
        Core_MDF_PGM_ServiceHandler.getUserDetails(new Set<Id>{intelAccount.Id},inactivePgmAccountIdToPrgmsMap);
        
        User user = [SELECT Id FROM User WHERE LastName = 'IUPGM Test User' limit 1];
        
        List<Core_MDF_Partner_Group_Mapping__c> pgmList = [SELECT Id, Core_MDF_Account__c, Core_MDF_Channel_Program__c
                                                           FROM Core_MDF_Partner_Group_Mapping__c
                                                           WHERE Core_MDF_Account__c =: intelAccount.Id AND
                                                           Core_MDF_Channel_Program__c =: intelRMF.Id AND 
                                                           Core_MDF_Type_of_Access__c = 'Internal'];
        test.stopTest();
        
         Assert.isTrue(pgmList!=null);                
    }
    //Test RMF PNUM sharing where Account's region is PRC

    @isTest
    static void testRMFPRCRegionPnumSharing(){
        
        test.startTest();
        Account intelAccount = [SELECT Id, Name FROM Account where Name ='Retail Intel Account' limit 1];
        
        ChannelProgram rmfCp = [SELECT Id, Name FROM ChannelProgram WHERE Name = 'Retail Marketing Funds' limit 1];
        
        Account intelRMF = [SELECT Id, Name FROM Account where Name ='Dell PRC Retail Virtual Corp' limit 1];
        
        Contact externalUser = Core_MDF_CCP_TestDataUtility.createContact(intelAccount.Id,true);     
                
        Core_ERPM_Engagement__c erpmEngagementRMF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('RPS_Retailer', 'RPS_Retailer', 'DEDUPGPRET', 'SEC', true, false);
        Database.insert(erpmEngagementRMF);
        
        Core_Entitlement__c entitlementRMF = Core_MDF_CCP_TestDataUtility.createEntitlement('RMF User',null,'Intel Partner Alliance (IPA)','RMF User',erpmEngagementRMF.Id , true,'Retail Marketing Funds (RMF)',false);
        Database.insert(entitlementRMF);
        
        Core_Contact_Entitlement__c contactEntitlementrmf = Core_MDF_CCP_TestDataUtility.createContactEntitlement(externalUser.Id,entitlementRMF.Id ,true,'Complete', false);
        Database.insert(contactEntitlementrmf);
        
        //Assigning external user with partner profile
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        
        User extUser = Core_MDF_CCP_TestDataUtility.createUser(false);        
        extUser.Email='test1@example.com';
        extUser.ContactId = externalUser.Id;
        extUser.ProfileId = profileId;
        extUser.isActive = true;
        Database.insert(extUser);
        
        Group grp = new Group();
        grp.name = 'PGM_TEST';
        insert grp;
        
        User testUser = [SELECT Id FROM User WHERE LastName = 'User Test1231'];
        
        System.runAs(testUser){
            GroupMember gm = new GroupMember();
            gm.GroupId = grp.Id;
            gm.UserOrGroupId = extUser.Id;
            insert gm;
        }        
        
        Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
        ccfPgm.Core_MDF_Account__c = intelAccount.Id;
        ccfPgm.Core_MDF_Group_Name__c = 'PGM_TEST';
        ccfPgm.Core_MDF_Type_of_Access__c = 'External';
        //ccfPgm.Core_MDF_Group_Id__c = grp.Id;
        ccfPgm.Core_MDF_Channel_Program__c = rmfCp.Id;
        ccfPgm.Core_MDF_Source_Txt__c = 'Test';
        Database.insert(ccfPgm);

        System.runAs(testUser){        
            Core_MDF_Partner_Node_User_Mapping__c pnumRecord = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(intelRMF.Id,extUser.Id,true);
        }
        
        User user = [SELECT Id FROM User WHERE LastName = 'IUPGM Test User' limit 1];
        
        List<Core_MDF_Partner_Group_Mapping__c> pgmList = [SELECT Id, Core_MDF_Account__c, Core_MDF_Channel_Program__c
                                                           FROM Core_MDF_Partner_Group_Mapping__c
                                                           WHERE Core_MDF_Account__c =: intelAccount.Id AND
                                                           Core_MDF_Channel_Program__c =: rmfCp.Id AND 
                                                           Core_MDF_Type_of_Access__c = 'Internal'];
        test.stopTest();
        
        Assert.isTrue(pgmList!=null);        
    }
    
    @isTest
    static void insertingException(){        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = [SELECT Id FROM Account WHERE Name = 'Intel Account' LIMIT 1];                
        //Test.startTest();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'IUPGM Test User'];
        
        Case cs = [SELECT Id from Case where Status ='Closed' LIMIT 1];
        
        
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm.Core_MDF_User_id__c = submitter.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        database.insert(iupgm);
        
        System.runAs(submitter){
            Test.startTest();
            Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
            expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            expt.Core_MDF_Comments_txt__c = 'Test Comments';
            expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
            expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Audio->Podcast'; // Indira
            expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            expt.Core_MDF_Country_Region_nm__c = 'INDIA';
            expt.Core_MDF_Account_id__c = acc.Id;
            insert expt;
        }        
        
        Core_MDF_Exception__c expt = [SELECT Id, Core_MDF_Program_nm__c FROM Core_MDF_Exception__c LIMIT 1];
        //Create ECM
        Core_MDF_Exception_Case_Mapping__c ecm = new Core_MDF_Exception_Case_Mapping__c();
        ecm.Core_MDF_Case_id__c = cs.Id;
        ecm.Core_MDF_Exception_id__c = expt.Id;
        ecm.Core_MDF_Program_txt__c = expt.Core_MDF_Program_nm__c;
        //database.insert(ecm);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmUpdate = [SELECT Id, Core_MDF_Region_Sub_Region_nm__c
                                                                 FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c LIMIT 1];
        iupgmUpdate.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        //database.update(iupgmUpdate);
        
        Test.stopTest();
        
        try{Core_MDF_Partner_Group_Mapping__c pgm = [SELECT Id, Core_MDF_Account__c, Core_MDF_Channel_Program__c,Core_MDF_Group_Id__c,
                                                 Core_MDF_Channel_Program__r.Name,Core_MDF_Region_cd__c
                                                 FROM Core_MDF_Partner_Group_Mapping__c
                                                 WHERE Core_MDF_Account__c =: acc.Id AND
                                                 Core_MDF_Channel_Program__r.Name =: 'Client' AND 
                                                     Core_MDF_Region_cd__c =: 'APJ' LIMIT 1];
           }catch(exception ex){}
        
        
        //Assert.isTrue(pgm != NULL);
    }
     @isTest
    static void testEEF(){    
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 50000];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'MDF Budget Loader';
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        usr1.UserRoleId = usRole.Id;
        // Database.insert(usr1);
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'TestClass TestUser';
        usr2.profileId = systemAdminProfile.Id;
        Database.insert(usr2);
        
        Test.startTest();   
        ChannelProgram eefCp = Core_MDF_CCP_TestDataUtility.createProgram('Ecosystem Extension Fund','Ecosystem Extension Fund', true);
        
        Id campaign_RecordType_EEF = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
        
        //Create Group
        Group eefGrp = new Group();
        eefGrp.Name = 'Core CCP EEF External';
        eefGrp.DeveloperName = 'Core_CCP_EEF_External';
        Database.insert(eefGrp);
        
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account Primary', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account intelAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Intel Account Activating', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account eefPrimaryVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('EEF Primary Virtual Corp', eefCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);                           
        eefPrimaryVirtualCorp.Core_MDF_Parent_Fund_Account__c = intelAcc.Id;
        eefPrimaryVirtualCorp.Core_MDF_Partner_Type_nm__c ='Primary Partner';
        eefPrimaryVirtualCorp.Core_MDF_External_Group_Id__c = eefGrp.Id;
        insert eefPrimaryVirtualCorp;
        
        Account eefActivatingVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('EEF Activating Virtual Corp', eefCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);                           
        eefActivatingVirtualCorp.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        eefActivatingVirtualCorp.Core_MDF_Partner_Type_nm__c ='Activating Partner';
        insert eefActivatingVirtualCorp;
        
        system.runAs(usr){
            PermissionSet eefBudLoader = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Budget_Loader' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = eefBudLoader.Id);
            PermissionSet eefBudManager = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Budget_Manager' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr2.id, PermissionSetId = eefBudManager.Id);
            
        }
        
        List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>(); 
        System.runAs(usr){
            Core_MDF_Partner_Mapping__c priToActiPartnerMapping = new Core_MDF_Partner_Mapping__c();
            priToActiPartnerMapping.Core_MDF_Primary_Partner_Account_id__c = eefPrimaryVirtualCorp.Id;
            priToActiPartnerMapping.Core_MDF_Activating_Partner_Account_id__c = eefActivatingVirtualCorp.Id;
            priToActiPartnerMapping.Core_MDF_Effective_Start_Date__c = System.today()-10;
            priToActiPartnerMapping.Core_MDF_Effective_End_Date__c = System.today()+10;
            priToActiPartnerMapping.Core_MDF_Channel_Program__c = eefCp.Id;
            insert priToActiPartnerMapping;
            
            /*PartnerMarketingBudget pbmEef = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget EEF Primary', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, eefPrimaryVirtualCorp.Id, eefCp.Id, 1000000, System.today()-15, System.today()+30, false);
            pbmEef.Core_MDF_Budget_Status__c = 'Released';
            pbmEef.Description = 'Test Description EEF';
           pbmEef.Core_MDF_Budget_Comments__c = 'Test Comments EEF';
            pmbList.add(pbmEef);
            
            Database.insert(pmbList);
            PartnerFundAllocation eefPFA = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test EEF PFA Primary', pbmEef, eefActivatingVirtualCorp, 20000, true);*/
            PartnerMarketingBudget pmb = [SELECT id from PartnerMarketingBudget WHERE Title = 'Test Budget' LIMIT 1];
            Group extGrp = new Group();
            extGrp.name = 'Core_MDF_EEF_EXT';
            extGrp.DoesIncludeBosses = false;
            insert extGrp;
            Group eeFWWgrp = new Group();
            eeFWWgrp.Name = 'Core CCP EEF WW INTERNAL';
            eeFWWgrp.DeveloperName = 'Core_CCP_EEF_WW_Internal';
            insert eeFWWgrp;
            
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = intelAcc.Id;
            pgm.Core_MDF_Group_Name__c = 'Core_CCP_EEF_External';
            pgm.Core_MDF_Type_of_Access__c = 'External';
            pgm.Core_MDF_Group_Id__c = intelAcc.Id;                
            pgm.Core_MDF_Channel_Program__c = eefCp.Id;
            Database.insert(pgm);
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = acc1.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_EEF_EXT';
            pgm1.Core_MDF_Type_of_Access__c = 'External';
            pgm1.Core_MDF_Group_Id__c = extGrp.Id;                
            pgm1.Core_MDF_Channel_Program__c = eefCp.Id;
            Database.insert(pgm1);
            
            Core_MDF_Partner_Group_Mapping__c wwPgm = new Core_MDF_Partner_Group_Mapping__c();
            wwPgm.Core_MDF_Account__c = intelAcc.Id;
            wwPgm.Core_MDF_Group_Name__c = 'Core_CCP_EEF_WW_Internal';
            wwPgm.Core_MDF_Type_of_Access__c = 'Internal';
            wwPgm.Core_MDF_Region_cd__c = 'WW';
            wwPgm.Core_MDF_Group_Id__c = eeFWWgrp.Id;                
            wwPgm.Core_MDF_Channel_Program__c = eefCp.Id;
            wwPgm.Core_MDF_Source_Txt__c = 'Test';
            wwPgm.Core_MDF_AccountIdGroupName__c = intelAcc.Id+'Core_CCP_DCF_WW_Internal';
            Database.Insert(wwPgm);
            
            Campaign eefCamp = new Campaign();
            eefCamp.RecordTypeId = campaign_RecordType_EEF;
            eefCamp.Core_MDF_Program__c = 'Ecosystem Extension Fund';
            eefCamp.Name = 'Campaign EEF Campaign';
            eefCamp.Description = 'Test';
            eefCamp.Core_MDF_Account__c = eefPrimaryVirtualCorp.Id;
            eefCamp.Core_MDF_Partner_Mapping_Txt__c = eefActivatingVirtualCorp.Id;
            eefCamp.StartDate = System.today();
            eefCamp.EndDate = System.today()+5;
            eefCamp.Core_MDF_External_Visibility_Date__c = System.today();
            eefCamp.Core_MDF_Opal_Budget_Type_Txt__c = 'Cloud';
            eefCamp.Core_MDF_Total_Campaign_Cost_Amt__c = 10000;
            eefCamp.Core_MDF_CSP_Intel_Based_Revenue_Amt__c = 1000;
            eefCamp.Core_MDF_Priority__c = 'Enterprise AI';
            eefCamp.Core_MDF_Market__c = 'AFGHANISTAN';
            eefCamp.Core_MDF_Audience__c = 'C-Suite';
            eefCamp.Core_MDF_Product_Type__c = 'Cloud Instance Consumption';
            eefCamp.Core_MDF_Brand__c = 'Intel® SGX';
            eefCamp.Core_MDF_Industry_Nm__c = 'Accommodation and Food Services';
            eefCamp.Core_MDF_Activity_Category__c = 'Broadcast';
            eefCamp.Core_MDF_Activity_Type__c = 'Radio';
            eefCamp.Core_MDF_Supports_legacy_program__c = 'MDF or both CMP & MDF';
            insert eefCamp;
            
            Core_MDF_Camp_to_ActPartner__c camptoActPtr = new Core_MDF_Camp_to_ActPartner__c();
            camptoActPtr.Core_MDF_Activating_Partner_Account_id__c = eefActivatingVirtualCorp.Id;
            camptoActPtr.Core_MDF_Channel_Program__c = eefCp.Id;
            camptoActPtr.Core_MDF_Campaign_Id__c = eefCamp.Id;
            camptoActPtr.Core_MDF_Reimbursement_Rate_pct__c = '100%';
            camptoActPtr.Core_MDF_Active_Ind__c = true;
            insert camptoActPtr;
        }
        
        Test.stopTest();
        
    }
    @isTest
    static void createPGMRecords(){
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = sysAdminProfile.Id;
        usr.FirstName ='PGMTestClass';
        usr.LastName ='User';
        //system.debug('usr.FirstName,'+ usr.FirstName  + usr.LastName);
        Database.insert(usr);

        Map<string,id> accessToGroupIdMap = new Map<string,id>();
        ChannelProgram cpId = [select id from ChannelProgram limit 1];
        Account accId = [select id from Account limit 1];
        List<Id> grpIdList = new List<Id>();
        //Create Master Group map
        for(Group record: [select id, developername from group limit 2]){
            accessToGroupIdMap.put('Internal',record.id);
            accessToGroupIdMap.put('External',record.id);
            grpIdList.add(record.id);
        }

        //Create a PGM record
        Core_MDF_Partner_Group_Mapping__c pgmRecord1 = new Core_MDF_Partner_Group_Mapping__c();
        pgmRecord1.Core_MDF_Account__c = accId.id;
        pgmRecord1.Core_MDF_Channel_Program__c = cpId.id;
        pgmRecord1.Core_MDF_Type_of_Access__c ='Internal';
        pgmRecord1.Core_MDF_Group_Name__c = 'Core_MDF_PGM_Trigger_Test_Account_Group';
        
        //Insert PGM record to fire Before and After Insert
        System.runAs(usr){
            Database.insert(pgmRecord1);}
        Core_MDF_Partner_Group_Mapping__c pgmGroupId = [select id,Core_MDF_Group_Id__c from Core_MDF_Partner_Group_Mapping__c limit 1];
        Map<Id,Core_MDF_Partner_Group_Mapping__c> pgmMap = new Map<Id,Core_MDF_Partner_Group_Mapping__c>();
        pgmMap.put(pgmGroupId.Id,pgmGroupId);
        Core_MDF_PGM_ServiceHandler.addUsersToPGMAccountGroupForExternal(pgmMap);
        Core_MDF_PGM_ServiceHandler.isInactiveIndicatorUpdated(pgmMap,pgmMap);
        Core_MDF_PGM_ServiceHandler.removeGroupFromGroupMember(grpIdList);
        Core_MDF_PGM_ServiceHandler.restrictDeletion(pgmMap);
        //Trigger should get the Group id and update on the PGM record
        assert.areNotEqual(null, pgmGroupId.id);

        //Update the PGM record to fire Before and After Update
        pgmRecord1.Core_MDF_Type_of_Access__c ='External';
        pgmRecord1.Core_MDF_Group_Name__c='Core_A_E_Test_Account_JJ_CCF_EXTERNAL';
        System.runAs(usr){
            Database.update(pgmRecord1);}
    }
}