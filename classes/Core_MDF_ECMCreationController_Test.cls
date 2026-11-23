/****************************************************************************************************************************************
* Class Name        : Core_MDF_ECMCreationController_Test
* Created Date      : 24-06-2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VK       24/06/2019         Test class for Core_MDF_ECMCreationServerController
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_ECMCreationController_Test {

    @TestSetUp
    static void createData(){
        //try{
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(true);
        User ccfAccountManager;
        User exceptionReviewer;
        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        Account flipkartTestAccount = new Account();
        Case cs = new Case();
        System.runAs(usr){
           
            
            
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);

            
            flipkartTestAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('FlipkartTestAccount', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);

            
            Account accCCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test CCF Account', ccfCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, flipkartTestAccount.Id, true);
           
            Group ccfgrp = new Group();
            ccfgrp.Name = 'CCP FLIPKARTT CCF APJ INTERNAL';
            ccfgrp.DeveloperName = 'Core_MDF_CCP_FLIPKARTT_CCF_APJ_INTERNAL';
            Database.insert(ccfgrp);
            
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
            
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet testProgramAdmin = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Program_Adm' LIMIT 1];
            PermissionSet financeManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Manager' LIMIT 1];
            PermissionSet testExceptionReviewer = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Exception_Reviewer' LIMIT 1];
            //   PermissionSet dcfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_DCF_Acct_Mgr' LIMIT 1];
            
            group grp = [select DeveloperName from group where DeveloperName='Core_All_Employees_Group' limit 1];
            
            List<User> userList = new List<User>();
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
            
            ccfAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfAccountManager.profileId = ccpCoreProfile.Id;
            ccfAccountManager.LastName = 'CCF Acc Manager';
            userList.add(ccfAccountManager);
            
            exceptionReviewer = Core_MDF_CCP_TestDataUtility.createUser(false);
            exceptionReviewer.profileId = ccpCoreProfile.Id;
            exceptionReviewer.LastName = 'Excpetion Reviewer';
            userList.add(exceptionReviewer);
            
            insert userList;
            
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfAccountManager.Id);
            permissionSetAssignmentList.add(psa1);
            
            PermissionSetAssignment psaExpRev = new PermissionSetAssignment(PermissionSetId = testExceptionReviewer.Id, AssigneeId = ccfAccountManager.Id);
            permissionSetAssignmentList.add(psaExpRev);
            
            //Adding reviewer and program admin permission set to Excption Reviewer
            PermissionSetAssignment psaProgramAdmin = new PermissionSetAssignment(PermissionSetId = testProgramAdmin.Id, AssigneeId = exceptionReviewer.Id);
            permissionSetAssignmentList.add(psaProgramAdmin);
            PermissionSetAssignment psaExpReviewer = new PermissionSetAssignment(PermissionSetId = testExceptionReviewer.Id, AssigneeId = exceptionReviewer.Id);
            permissionSetAssignmentList.add(psaExpReviewer);
            PermissionSetAssignment psaFinManager = new PermissionSetAssignment(PermissionSetId = financeManagerPS.Id, AssigneeId = exceptionReviewer.Id);
            permissionSetAssignmentList.add(psaFinManager);

            insert permissionSetAssignmentList;

            String fccApproversGroupId, pmgApproversGroupId, allUsersInternalId;
            for(Group groupRecord : [SELECT DeveloperName, Id
                                     FROM Group
                                     WHERE DeveloperName IN ('Core_MDF_CCF_FCC_Approvers_Group', 'Core_MDF_CCF_PMG_Approvers_Group', 'Core_All_Users_CCP_Internal')]){
                if(('Core_MDF_CCF_FCC_Approvers_Group').equalsIgnoreCase(groupRecord.DeveloperName)){
                    fccApproversGroupId = groupRecord.Id;
                }
                else if(('Core_MDF_CCF_PMG_Approvers_Group').equalsIgnoreCase(groupRecord.DeveloperName)){
                    pmgApproversGroupId = groupRecord.Id;
                }
                else if(('Core_All_Users_CCP_Internal').equalsIgnoreCase(groupRecord.DeveloperName)){
                    allUsersInternalId = groupRecord.Id;
                }
            }

            List<GroupMember> gmList = new List<GroupMember>();

            if(fccApproversGroupId != NULL){
                GroupMember gm1 = new GroupMember();
                gm1.GroupId = fccApproversGroupId;
                gm1.UserOrGroupId = exceptionReviewer.Id;
                gmList.add(gm1);
            }
            
            if(pmgApproversGroupId != NULL){
                GroupMember gm2 = new GroupMember();
                gm2.GroupId = pmgApproversGroupId;
                gm2.UserOrGroupId = exceptionReviewer.Id;
                gmList.add(gm2);
            }
            
            if(ccfAccountManager.Id != NULL){
                GroupMember gm3 = new GroupMember();
                gm3.GroupId = grp.Id;
                gm3.UserOrGroupId = ccfAccountManager.Id;
                gmList.add(gm3);
            }

            if(allUsersInternalId != NULL){
                GroupMember gm4 = new GroupMember();
                gm4.GroupId = allUsersInternalId;
                gm4.UserOrGroupId = exceptionReviewer.Id;
                gmList.add(gm4);
            }
            
            insert gmList;
            
            /* groupmember grpmemb = new groupmember();
            grpmemb.groupid = grp.Id;
            grpmemb.UserOrGroupId = ccfAccountManager.Id;
            database.insert(grpmemb); */
            
            // 14285 Indira - Start
            //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
            bypassFunctionKeys.add('Core_MDF_Bypass_AccOnboardValidation'); // 14285 Indira
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            // 14285 Indira - End
            
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Account_id__c = flipkartTestAccount.Id;
            iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgm.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
            iupgm.Core_MDF_Region_cd__c = 'APJ';
            iupgm.Core_MDF_User_id__c = ccfAccountManager.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
            iupgm.Core_MDF_All_Accounts_cd__c = 'No';
            iupgmList.add(iupgm);
            
            
            AccountShare accshare = new AccountShare();
            accshare.AccountId = flipkartTestAccount.Id;
            accshare.UserOrGroupId = ccfAccountManager.Id;
            accshare.RowCause = 'Manual';
            accshare.AccountAccessLevel = 'Read';
            accshare.OpportunityAccessLevel = 'None';
            accshare.CaseAccessLevel = 'None';
            Database.insert(accshare);
            
            insert iupgmList;
                     
            //Create Bank
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(flipkartTestAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
            bank.Core_MDF_Bank_Status__c = 'Active';
            update bank;
            
            assert.istrue(bank.Core_MDF_Bank_Status__c == 'Active');
            
            //Create ABM
            
            
            
            
            //Create Budget
            PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',
                                                                                      Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                      accCCF.Id,ccfCp.Id,10000,
                                                                                      System.today() -20,System.today().addDays(40), 
                                                                                      false);
             budget.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
            insert budget;
            
            //Create Allocation
            PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,accCCF,10000,true);
            
            //Create Campaign
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor','Yes', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                        'Client CoMarketing Fund', System.today() - 5, System.today().addDays(15), 
                                                                        10000, 'Always Connected PC', accCCF.Id,'Desktop', true); 
            
            camp.Core_MDF_Reimbursement_Rate__c = '50%';
            update camp;
           // Test.startTest();
            Test.startTest();
             //Create Activity
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           String.valueof(accCCF.Id),allocation,null,'BRAZIL',
                                                                                           'Consumer',
                                                                                           'Desktop',
                                                                                           'Intel® Core™ i5 Processor',
                                                                                           'Broadcast',
                                                                                           'Podcast',
                                                                                           'Draft',
                                                                                           false);
            pfr.Core_MDF_Start_Date__c = system.today() - 5;
            pfr.Core_MDF_End_Date__c  = system.today() + 5;
            pfr.Core_MDF_Reimbursement_Rate_txt__c = '50%';
            pfr.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
             //Test.startTest();
            insert pfr;
            
            //Create Claim
            PartnerFundClaim newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                                 Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                                 System.today() - 5, System.today(), 122, 
                                                                                 System.today(), bank.Id, false);
            newClaim.Core_MDF_Currency__c = 'USD';
            newClaim.Core_MDF_Type_Txt__c = 'Claim';
            newClaim.Core_MDF_Taxes_Local__c = 0;
            newClaim.Core_MDF_Total_Invoice_Amount_Local__c = 20;
            newClaim.Core_MDF_Reimbursable_TransactionAmt_Loc__c = 10;
            newClaim.Core_MDF_Requested_Reimbursement_Amt__c = 15;
            newClaim.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            insert newClaim;
            
            //Create case of Audit record type
            cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            cs.Status = 'New';
            cs.recordTypeId = caseAuditRecType;
            cs.Core_MDF_Activity_Category__c = 'Audio';  // 14285 Indira
            cs.Core_MDF_Activity_Start_Date__c = System.today();
            cs.Core_MDF_Activity_End_Date__c = System.today() + 5;
            cs.Core_MDF_Claim_ID__c = newClaim.Id;
            cs.Core_MDF_Activity_Type__c = 'Podcast';
            cs.AccountId  = accCCF.Id;
            cs.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
            insert cs;
        }

        List<Core_MDF_Exception__c> expList = new List<Core_MDF_Exception__c>();
        System.runAs(ccfAccountManager){            
            
            //Account       Country
            //Single        Multi 
            expt = new Core_MDF_Exception__c();
            expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            expt.Core_MDF_Comments_txt__c = 'Test Comments';
            expt.Core_MDF_Exception_Start_Date_dt__c = System.today() - 5;
            expt.Core_MDF_Exception_End_Date_dt__c = System.today();
            expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Audio->Podcast';  // 14285 Indira
            expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            expt.Core_MDF_Country_Region_nm__c = 'INDIA';
            expt.Core_MDF_Account_id__c = /*flipkartTestAccount.Id*/ null;
            expt.Core_MDF_Select_All_Accounts_ind__c = true;
            expt.Core_MDF_Budget_Type_nm__c = '';  // 14285 Indira
            expList.add(expt); 
            Core_MDF_Exception__c exp = new Core_MDF_Exception__c();
            exp.Core_MDF_Name_of_Exception_nm__c = 'Test SPCF Exception';
            exp.Core_MDF_Issue_Description_dsc__c = 'Test Description1';
            exp.Core_MDF_Comments_txt__c = 'Test Comment';
            exp.Core_MDF_Exception_Start_Date_dt__c = System.today() - 5;
            exp.Core_MDF_Exception_End_Date_dt__c = System.today();
            exp.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exp.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            exp.Core_MDF_Activity_Cate_and_Type_nm__c ='Audio->Radio';  // 14285 Indira
            exp.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exp.Core_MDF_Country_Region_nm__c = 'INDIA';
            exp.Core_MDF_Account_id__c = /*flipkartTestAccount.Id*/ null;
            exp.Core_MDF_Select_All_Accounts_ind__c = true;
            exp.Core_MDF_Budget_Type_nm__c = '';
            expList.add(exp);          
            insert expList;            
        }

        /*System.runAs(usr){
            //SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Core_MDF_Exception__Share
            Core_MDF_Exception__Share exceptionShare = new Core_MDF_Exception__Share(ParentId = expt.Id, 
                                                                                     UserOrGroupId = exceptionReviewer.Id,
                                                                                     AccessLevel = 'Read',
                                                                                     RowCause = 'Manual');
            insert exceptionShare;
        }
        */
        
        System.runAs(usr){
            ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :expt.Id
                                                 AND ProcessInstance.Status = 'Pending']; 
            if(piWorkItems.size() > 0){
                //Create Process Work Item Request
                Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
                pwiRequest.setAction('Removed');
                pwiRequest.setWorkItemId(piWorkItems[0].Id);
                Approval.ProcessResult result = Approval.process(pwiRequest);
            }
        }

        System.runAs(ccfAccountManager){
            expt.Core_MDF_Exception_Status_nm__c = 'Approved';
            //update expt;
        }
        
        //Test.stopTest();

        System.runAs(usr){
            //Create ECM
            Core_MDF_Exception_Case_Mapping__c ecm = new Core_MDF_Exception_Case_Mapping__c();
            ecm.Core_MDF_Case_id__c = cs.Id;
            ecm.Core_MDF_Exception_id__c = expt.Id;
            
            //ecm.Core_MDF_Claim_id__c = newClaim.Id;
            //ecm.Core_MDF_Program_txt__c = expt.Core_MDF_Program_nm__c;
            insert ecm; 
            test.stopTest();
        }
        //}catch(exception ex){}
    }    
    @isTest
    static void ecmControllerTest(){
        //try{
        Core_MDF_Exception__c expt = [SELECT Id, Name, Core_MDF_Exception_Start_Date_dt__c, Core_MDF_Exception_End_Date_dt__c,
                                             Core_MDF_Program_nm__c, Core_MDF_Activity_Cate_and_Type_nm__c, Core_MDF_Account_id__c,
                                             Core_MDF_Select_All_Accounts_ind__c, Core_MDF_Name_of_Exception_nm__c, Core_MDF_Exception_Reason_nm__c
                                      FROM Core_MDF_Exception__c 
                                      WHERE Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country'];
        
        Case cs = [SELECT Id, AccountId, Account.Core_MDF_Channel_Program__r.Name, Core_MDF_Claim_ID__c, Account.Core_MDF_CoMarketing_Ultimate_Account__c
                   FROM Case 
                   WHERE Core_MDF_Activity_Category__c = 'Audio'];  // 14285 Indira
        
        String caseId;
        caseId = cs.Id;
        String claimId = cs.Core_MDF_Claim_ID__c;
        String accId = cs.Account.Core_MDF_CoMarketing_Ultimate_Account__c;
        
        Test.startTest();
        
        Core_MDF_Exception_Case_Mapping__c ecm = [SELECT Id 
                                                  FROM Core_MDF_Exception_Case_Mapping__c 
                                                  WHERE Core_MDF_Case_id__c =:cs.Id];
        
        String ecmrecordId;
        ecmrecordId = ecm.Id;

        ChannelProgram cp = [SELECT Id FROM ChannelProgram WHERE Name = 'Client' LIMIT 1];
        String cpId = cp.Id;
        
       
        Test.stopTest();
        
        String ecmString;
        ecmString = '[{"channelProgramId": "' + cpId + '","claimId": "' + claimId + '","corpAccountId": "' + accId + '","ecmRecordId":"' + ecm.Id + '","exceptionRecord":{"Id":"'+expt.Id+'","Name":"'+expt.Name+'","Core_MDF_Exception_Start_Date_dt__c":"2019-06-24","Core_MDF_Exception_End_Date_dt__c":"2019-06-29","Core_MDF_Program_nm__c":"Core_MDF_Client_CoMarketing_Fund","Core_MDF_Activity_Cate_and_Type_nm__c":"Broadcast->Podcast","Core_MDF_Account_id__c":"'+expt.Core_MDF_Account_id__c+'","Core_MDF_Select_All_Accounts_ind__c":false,"Core_MDF_Name_of_Exception_nm__c":"'+expt.Core_MDF_Name_of_Exception_nm__c+'","Core_MDF_Exception_Reason_nm__c":"'+expt.Core_MDF_Exception_Reason_nm__c+'"},"exceptionRecordLink":"'+'/'+expt.Id+'","isChecked":true,"isECMAlreadyCreated":true}]';
        
        Core_MDF_ECMCreationServerController.fetchExceptionRecords(caseId);
        Core_MDF_ECMCreationServerController.fetchExceptions(caseId);
        Core_MDF_ECMCreationServerController.saveECMRecordsCtrl(caseId,ecmString);
        //Core_MDF_Exception_Case_Mapping__c ecm = new Core_MDF_Exception_Case_Mapping__c(Core_MDF_Case_id__c = caseRecordId, 
                                                                                          //Core_MDF_Exception_id__c = //ew.exceptionRecord.Id);
        List<Core_MDF_Exception_Case_Mapping__c> ecmList = [SELECT Core_MDF_Case_id__c, Core_MDF_Exception_id__c
                                                            FROM Core_MDF_Exception_Case_Mapping__c
                                                            WHERE Core_MDF_Case_id__c = :caseId AND 
                                                                  Core_MDF_Exception_id__c = :expt.Id];
        
        assert.istrue(ecmList != NULL);
        Core_MDF_ECMCreationServerController.saveECMRecordsCtrl(NULL,ecmString);
        Core_MDF_ECMCreationServerController.fetchExceptions(NULL);
        Core_MDF_ECMCreationServerController.fetchExceptionRecords('XYZ');
        Core_MDF_ECMCreationServerController.fetchExceptionRecords(NULL);
        
       // Test.stopTest();   
       //}catch(Exception ex){}    
    }
    
    @isTest
    static void createECM(){
        //try{
        Test.startTest();
        Core_MDF_Exception__c expt = [SELECT Id, Name, Core_MDF_Exception_Start_Date_dt__c, Core_MDF_Exception_End_Date_dt__c,
                                             Core_MDF_Program_nm__c, Core_MDF_Activity_Cate_and_Type_nm__c, Core_MDF_Account_id__c,
                                             Core_MDF_Select_All_Accounts_ind__c, Core_MDF_Name_of_Exception_nm__c, Core_MDF_Exception_Reason_nm__c
                                      FROM Core_MDF_Exception__c 
                                      WHERE Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country'];
         User exceptionReviewer = [Select id , lastname from User where  LastName = 'Excpetion Reviewer'];
         Core_MDF_Exception__Share exceptionShare = new Core_MDF_Exception__Share(ParentId = expt.Id, 
                                                                                     UserOrGroupId = exceptionReviewer.Id,
                                                                                     AccessLevel = 'Read',
                                                                                     RowCause = 'Manual');
        
        insert exceptionShare;
        //Test.startTest();
        
        Case cs = [SELECT Id, AccountId, Account.Core_MDF_Channel_Program__r.Name
                   FROM Case 
                   WHERE Core_MDF_Activity_Category__c = 'Audio']; // 14285 Indira
        

        String ecamCreated;
        ecamCreated = '[{"ecmRecordId":"","exceptionRecord":{"Id":"'+expt.Id+'","Name":"'+expt.Name+'","Core_MDF_Exception_Start_Date_dt__c":"2019-06-24","Core_MDF_Exception_End_Date_dt__c":"2019-06-29","Core_MDF_Program_nm__c":"Core_MDF_Client_CoMarketing_Fund","Core_MDF_Activity_Cate_and_Type_nm__c":"Broadcast->Podcast","Core_MDF_Account_id__c":"'+expt.Core_MDF_Account_id__c+'","Core_MDF_Select_All_Accounts_ind__c":false,"Core_MDF_Name_of_Exception_nm__c":"'+expt.Core_MDF_Name_of_Exception_nm__c+'","Core_MDF_Exception_Reason_nm__c":"'+expt.Core_MDF_Exception_Reason_nm__c+'"},"exceptionRecordLink":"'+'/'+expt.Id+'","isChecked":true,"isECMAlreadyCreated":true}]';
      
        String caseId;
        caseId = cs.Id;
        
        //Test.stopTest();
        
        Core_MDF_ECMCreationServerController.saveECMRecordsCtrl(caseId,ecamCreated);
        
        /*Core_MDF_Exception_Case_Mapping__Share ecmShare = [SELECT ParentId FROM Core_MDF_Exception_Case_Mapping__Share LIMIT 1];
        System.assert(ecmShare != NULL);*/  
        
        Assert.areNotEqual(cs,null);
        Test.stopTest();
       // }catch(Exception ex){}
    }
    @isTest
    static void opalECMTest(){
       // try{
        Test.startTest();
        Core_MDF_Exception__c expt = [SELECT Id, Name, Core_MDF_Exception_Start_Date_dt__c, Core_MDF_Exception_End_Date_dt__c,
                                      Core_MDF_Program_nm__c, Core_MDF_Activity_Cate_and_Type_nm__c, Core_MDF_Account_id__c, Core_MDF_Budget_Type_nm__c,
                                      Core_MDF_Select_All_Accounts_ind__c, Core_MDF_Name_of_Exception_nm__c, Core_MDF_Exception_Reason_nm__c
                                      FROM Core_MDF_Exception__c 
                                      WHERE Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country'];
        assert.istrue(expt != NULL); 
        Case cs = [SELECT Id, AccountId, Account.Core_MDF_Channel_Program__r.Name, Core_MDF_Claim_ID__c, Core_MDF_Budget_Type_nm__c, Account.Core_MDF_CoMarketing_Ultimate_Account__c
                   FROM Case 
                   WHERE Core_MDF_Activity_Category__c = 'Audio'];  // 14285 Indira
        
        User ccfAccountManager = [Select Id, LastName from User where LastName = 'CCF Acc Manager'];
        
        //Test.startTest();
        ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :expt.Id
                                                 AND ProcessInstance.Status = 'Pending']; 
        if(piWorkItems.size() > 0){
            //Create Process Work Item Request
            Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
            pwiRequest.setAction('Removed');
            pwiRequest.setWorkItemId(piWorkItems[0].Id);
            Approval.ProcessResult result = Approval.process(pwiRequest);
        }      
        System.runAs(ccfAccountManager){
            expt.Core_MDF_Exception_Status_nm__c = 'Approved';
            update expt;
        }
        Core_MDF_Exception_Case_Mapping__c ecm = new Core_MDF_Exception_Case_Mapping__c();
        ecm.Core_MDF_Case_id__c = cs.Id;
        ecm.Core_MDF_Exception_id__c = expt.Id; 
        Test.stopTest(); 
        insert ecm;
        String caseId;
        caseId = cs.Id;
        Core_MDF_ECMCreationServerController.fetchExceptions(caseId);
        Core_MDF_ECMCreationServerController.fetchExceptionRecords(caseId);
      // }catch(Exception ex){}        
    }   
}