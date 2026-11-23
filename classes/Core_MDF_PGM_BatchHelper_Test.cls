@isTest(SeeAllData=false)
public class Core_MDF_PGM_BatchHelper_Test{
    
    @TestSetup static void setUpData() {
        
        List<User> userList = new List<User>();
        List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
        
        Profile coreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
        
        PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];        
        
        UserRole adminRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        User accMgr =  Core_MDF_CCP_TestDataUtility.createUser(false);
        accMgr.profileId = coreProfile.Id;
        accMgr.LastName = 'IUPGM Test User';
        accMgr.UserRoleId = adminRole.Id;
        userList.add(accMgr);        
        
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = adminRole.Id;
        userList.add(usr);
        
        database.insert(userList);
        
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = accMgr.Id);
        permissionSetAssignmentList.add(psa);
        
        database.insert(permissionSetAssignmentList);
        
        system.runAs(usr){
            
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
            
            List<Core_Trigger_Executions__c> executionList = new List<Core_Trigger_Executions__c>();
            
            Core_Trigger_Executions__c accountShareSetting = new Core_Trigger_Executions__c();
            accountShareSetting.Core_Active__c = true;
            accountShareSetting.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            accountShareSetting.Core_Trigger_Events__c = 'after insert';
            accountShareSetting.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
            accountShareSetting.Name = 'createAccountShareRecords';
            accountShareSetting.Core_Description__c = 'test';
            executionList.add(accountShareSetting);
            
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
            
            Database.insert(executionList);
            
            //Creating channel program 
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);            

            //Creating Intel Account
            Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Intel Account', 
                                                                                    Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                                    false);
            intelAccount.Core_Account_Type__c = 'Reseller';
            intelAccount.Industry = 'Food & Beverage';
            intelAccount.Core_MDF_CoMarketingActive__c=true;
            Database.insert(intelAccount);
            
            //Creating Co-marketing Account with utility class
            Account intelCCF = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', ccfCp.Id,
                                                                           Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            intelCCF.Core_MDF_Parent_Fund_Account__c = intelAccount.Id;
            intelCCF.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccount.Id;
            Database.insert(intelCCF);            
            
            Account intelCcfApj = Core_MDF_CCP_TestDataUtility.createAccount ('Second Level Account', ccfCp.Id,
                                                                              Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            intelCcfApj.Core_MDF_Parent_Fund_Account__c = intelCCF.Id;
            intelCcfApj.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccount.Id;
            Database.insert(intelCcfApj);
            
            //Creating contact
            Contact externalUser = Core_MDF_CCP_TestDataUtility.createContact(intelAccount.Id,true);            
           
            //Assigning external user with partner profile
            Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
            
            User extUser = Core_MDF_CCP_TestDataUtility.createUser(false);        
            extUser.Email='test1@example.com';
            extUser.ContactId = externalUser.Id;
            extUser.ProfileId = profileId;
            extUser.isActive = true;
            Database.insert(extUser);
            
            //Creating Acc User record
            Core_MDF_Partner_Node_User_Mapping__c pnum = new Core_MDF_Partner_Node_User_Mapping__c();
            pnum.Core_MDF_Account__c = intelCCF.Id;
            pnum.Core_MDF_User__c = extUser.Id;
            Database.insert(pnum);
            
            //Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                        'Client CoMarketing Fund',System.today(),System.today().addDays(200), 
                                                                        2000,'Test',intelCCF.Id,'2-in-1', true);
            
            //Creating Budget using utility class
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   intelCCF.Id,ccfCp.Id,5000000,
                                                                                   System.today(),System.today().addDays(110), true);            
            
            //Creating Allocation using utility class
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,intelCCF,1000000.0,true);
            
            //Creating Account transfer log
            Core_MDF_Budget_Transfer_Log__c atl = new Core_MDF_Budget_Transfer_Log__c();    
            atl.Core_MDF_Partner_Marketing_Budget__c = pmb.Id;
            atl.Core_MDF_Source_Account__c = intelCCF.Id;
            atl.Core_MDF_Target_Account__c = intelCcfApj.Id;
            atl.Core_MDF_Transfer_Type__c = 'Manual';
            atl.Core_MDF_Transferred_Amount__c = 100;
            insert atl;
            
            //Creating Budget Cap
            Core_MDF_Budget_Cap__c budgetCap = new Core_MDF_Budget_Cap__c();
            budgetCap.Core_MDF_Cap_Type_nm__c = 'Channel Led Activity';
            budgetCap.Core_MDF_Budget_Name_id__c = pmb.Id;
            budgetCap.Core_MDF_Requested_Cap_amt__c = 100;
            budgetCap.Core_MDF_Approved_Cap_amt__c = 100;
            Database.insert(budgetCap);
            
            test.startTest();            
            
            //Creating activity
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(intelCCF.id),null,null,'INDIA','Small Business',
                                                                                           'Desktop','Intel® Core™ i7 Processor','Broadcast',
                                                                                           'Radio','Draft',false);
            pfr.RequestedAmount = 500000;
            pfr.Amount = 500000;
            pfr.Core_MDF_Channel_Partner_Led__c = FALSE;
            pfr.Core_MDF_Start_Date__c = system.today();
            pfr.Core_MDF_End_Date__c = system.today() + 2;
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
            
            database.insert(pfc);      
            
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
            payRunRecord.Core_MDF_Program_Id__c  = ccfCp.Id;
            Database.insert(payRunRecord);                   
            
            //Creating Case
            Case cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit_Closed').getRecordTypeId();
            cs.Status = 'Closed';
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = intelCCF.Id;
            database.insert(cs); 
            
            test.stopTest();
        }
    }
    
    @isTest
    static void insertingIUPGM(){
        
        Id budgetRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Budget').getRecordTypeId();
        Id caseRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId();
        Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();        
        
        test.startTest();
        
        Account acc = [SELECT Id, Name FROM Account where Name ='Intel Account' limit 1];
        
        ChannelProgram cp = [SELECT Id, Name FROM ChannelProgram WHERE Name = 'Client Co-Marketing Fund' limit 1];
        
        User user = [SELECT Id FROM User WHERE LastName = 'IUPGM Test User' limit 1];
        
        //Activity for late claim escalation
        PartnerFundRequest pfrToBeEscalated = [select Id,Core_MDF_Activity_Number__c from PartnerFundRequest LIMIT 1];
        
        //Budget for budget escalation
        PartnerMarketingBudget pmb = [SELECT id from PartnerMarketingBudget WHERE Title = 'Test Budget' LIMIT 1];
        
        //Case for claim review result escalation
        Case cs = [SELECT Id from Case where Status ='Closed' LIMIT 1];
        
        PartnerFundClaim pfc = [Select Id,Title from PartnerFundCLaim where Title ='Test Claim' limit 1];                
        
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
        escList.add(activityEsc);        
        
        
        Core_MDF_Escalation__c caseEsc = new Core_MDF_Escalation__c();
        caseEsc.Core_MDF_Escalation_Status_nm__c='Pending Review';
        caseEsc.Core_MDF_Escalation_Name_txt__c='Test2';
        caseEsc.Core_MDF_Total_Dollar_Impact_amt__c= 45;
        caseEsc.Core_MDF_Root_Cause_nm__c = 'Creative';
        caseEsc.Core_MDF_Case_ID_Number_id__c = cs.Id;
        caseEsc.Core_MDF_Channel_Program_id__c = cp.Id;
        caseEsc.recordtypeid = caseRecType;
        escList.add(caseEsc);
        
        database.insert(escList);
        
        Core_MDF_Adjustment_Request__c adjustment = new Core_MDF_Adjustment_Request__c();          
        adjustment.Core_MDF_Reference_Claim_Nbr__c = pfc.Id;
        adjustment.Core_MDF_Amount_Amt__c = 10;
        adjustment.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
        Database.insert(adjustment);
        
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
        
        System.assertEquals(1, pgmList.Size());
    }
    
    @isTest
    static void insertingException(){        
        
        Test.startTest();
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'Intel Account' LIMIT 1];
        
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
            
            Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
            expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            expt.Core_MDF_Comments_txt__c = 'Test Comments';
            expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
            expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
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
        database.insert(ecm);
 
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmUpdate = [SELECT Id, Core_MDF_Region_Sub_Region_nm__c
                                                                 FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c LIMIT 1];
        iupgmUpdate.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        database.update(iupgmUpdate);
        
        Core_MDF_Partner_Group_Mapping__c pgm = [SELECT Id, Core_MDF_Account__c, Core_MDF_Channel_Program__c,Core_MDF_Group_Id__c,
                                                 Core_MDF_Channel_Program__r.Name,Core_MDF_Region_cd__c
                                                 FROM Core_MDF_Partner_Group_Mapping__c
                                                 WHERE Core_MDF_Account__c =: acc.Id AND
                                                 Core_MDF_Channel_Program__r.Name =: 'Client Co-Marketing Fund' AND 
                                                 Core_MDF_Region_cd__c =: 'APJ' LIMIT 1];
        
        Test.stopTest();
        
        System.assert(pgm != NULL);
 
    }
}