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
        User usr = Core_MDF_CCP_TestDataUtility.createUser(true);
        User ccfAccountManager;
        User exceptionReviewer;
        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        Account flipkartTestAccount = new Account();
        Case cs = new Case();
        System.runAs(usr){
           
            
            
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            ChannelProgram dcfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
            
            flipkartTestAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('FlipkartTestAccount', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account myntraTestAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('MyntraTestAccount', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            
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
            
            
            
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Account_id__c = flipkartTestAccount.Id;
            iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgm.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
            iupgm.Core_MDF_Region_cd__c = 'APJ';
            iupgm.Core_MDF_User_id__c = ccfAccountManager.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
            iupgmList.add(iupgm);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm.Core_MDF_Account__c = flipkartTestAccount.Id;
            ccfPgm.Core_MDF_Group_Name__c = 'Core_MDF_CCP_FLIPKARTT_CCF_APJ_INTERNAL';
            ccfPgm.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm.Core_MDF_Group_Id__c = ccfgrp.Id;
            ccfPgm.Core_MDF_Channel_Program__c = ccfCp.Id;
            ccfPgm.Core_MDF_Region_cd__c = 'APJ';
            ccfPgm.Core_MDF_Source_Txt__c = 'Test';
            Database.insert(ccfPgm);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgmRegion = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgmRegion.Core_MDF_Account__c = flipkartTestAccount.Id;
            ccfPgmRegion.Core_MDF_Group_Name__c = 'Core_MDF_CCP_FLIPKARTT_CCF_APJ_SA_INTERNAL';
            ccfPgmRegion.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgmRegion.Core_MDF_Group_Id__c = ccfgrp.Id;
            ccfPgmRegion.Core_MDF_Channel_Program__c = ccfCp.Id;
            ccfPgmRegion.Core_MDF_Region_cd__c = 'APJ';
            ccfPgmRegion.Core_MDF_Sub_Region_cd__c = 'SA';
            ccfPgmRegion.Core_MDF_Source_Txt__c = 'Test';
            Database.insert(ccfPgmRegion);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgmWW = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgmWW.Core_MDF_Account__c = flipkartTestAccount.Id;
            ccfPgmWW.Core_MDF_Group_Name__c = 'Core_MDF_CCP_FLIPKARTT_CCF_APJ_WW_INTERNAL';
            ccfPgmWW.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgmWW.Core_MDF_Group_Id__c = ccfgrp.Id;
            ccfPgmWW.Core_MDF_Channel_Program__c = ccfCp.Id;
            ccfPgmWW.Core_MDF_Region_cd__c = 'WW';
            ccfPgmWW.Core_MDF_Source_Txt__c = 'Test';
            Database.insert(ccfPgmWW);
            
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
            
            System.assert(bank.Core_MDF_Bank_Status__c == 'Active');
            
            //Create ABM
            Core_MDF_Account_Bank_Mapping__c abmCCF1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(accCCF.Id, bank.Id, TRUE);
            
            //Create Budget
            PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',
                                                                                      Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                      accCCF.Id,ccfCp.Id,10000,
                                                                                      System.today() -20,System.today().addDays(40), 
                                                                                      true);
            
            //Create Allocation
            PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,accCCF,10000,true);
            
            //Create Campaign
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                        'Client CoMarketing Fund', System.today() - 5, System.today().addDays(15), 
                                                                        10000, 'Always Connected PC', accCCF.Id,'Desktop', true); 
            
            Test.startTest();
            
             //Create Activity
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           String.valueof(accCCF.Id),allocation,null,'BRAZIL',
                                                                                           'Consumer',
                                                                                           'Desktop',
                                                                                           'Intel® Core™ i7 Processor',
                                                                                           'Broadcast',
                                                                                           'Podcast',
                                                                                           'Draft',
                                                                                           false);
            pfr.Core_MDF_Start_Date__c = system.today() - 5;
            pfr.Core_MDF_End_Date__c  = system.today() + 5;
            pfr.Amount = 0;
            insert pfr;
            
            //Create Claim
            PartnerFundClaim newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                                 Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                                 System.today() - 5, System.today(), 122, 
                                                                                 System.today(), bank.Id, false);
            newClaim.Core_MDF_Currency__c = 'USD';
            newClaim.Core_MDF_Type_Txt__c = 'Claim';
            newClaim.Core_MDF_Taxes_Local__c = 0;
            insert newClaim;
            
            //Create case of Audit record type
            cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            cs.Status = 'New';
            cs.recordTypeId = caseAuditRecType;
            cs.Core_MDF_Activity_Category__c = 'Broadcast';
            cs.Core_MDF_Activity_Start_Date__c = System.today();
            cs.Core_MDF_Activity_End_Date__c = System.today() + 5;
            cs.Core_MDF_Claim_ID__c = newClaim.Id;
            cs.Core_MDF_Activity_Type__c = 'Podcast';
            cs.AccountId  = accCCF.Id;
            insert cs;
        }


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
            expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            expt.Core_MDF_Country_Region_nm__c = 'INDIA';
            expt.Core_MDF_Account_id__c = flipkartTestAccount.Id;
            expt.Core_MDF_Select_All_Accounts_ind__c = false;
            
            insert expt;
        }

        System.runAs(usr){
            //SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Core_MDF_Exception__Share
            Core_MDF_Exception__Share exceptionShare = new Core_MDF_Exception__Share(ParentId = expt.Id, 
                                                                                     UserOrGroupId = exceptionReviewer.Id,
                                                                                     AccessLevel = 'Read',
                                                                                     RowCause = 'Manual');
            insert exceptionShare;
        }

        
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
            update expt;
        }
        
        Test.stopTest();

        System.runAs(usr){
            //Create ECM
            Core_MDF_Exception_Case_Mapping__c ecm = new Core_MDF_Exception_Case_Mapping__c();
            ecm.Core_MDF_Case_id__c = cs.Id;
            ecm.Core_MDF_Exception_id__c = expt.Id;
            //ecm.Core_MDF_Claim_id__c = newClaim.Id;
            //ecm.Core_MDF_Program_txt__c = expt.Core_MDF_Program_nm__c;
            insert ecm;
            
            
        }
    }
    
    @isTest
    static void ecmControllerTest(){
        
       
        
        Core_MDF_Exception__c expt = [SELECT Id, Name, Core_MDF_Exception_Start_Date_dt__c, Core_MDF_Exception_End_Date_dt__c,
                                             Core_MDF_Program_nm__c, Core_MDF_Activity_Cate_and_Type_nm__c, Core_MDF_Account_id__c,
                                             Core_MDF_Select_All_Accounts_ind__c, Core_MDF_Name_of_Exception_nm__c, Core_MDF_Exception_Reason_nm__c
                                      FROM Core_MDF_Exception__c 
                                      WHERE Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country'];
        
        Case cs = [SELECT Id, AccountId, Account.Core_MDF_Channel_Program__r.Name, Core_MDF_Claim_ID__c, Account.Core_MDF_CoMarketing_Ultimate_Account__c
                   FROM Case 
                   WHERE Core_MDF_Activity_Category__c = 'Broadcast'];
        
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

        ChannelProgram cp = [SELECT Id FROM ChannelProgram WHERE Name = 'Client Co-Marketing Fund' LIMIT 1];
        String cpId = cp.Id;
        
        Core_MDF_BankProgram_Entitlement_Mapping__mdt bpem = [SELECT Core_MDF_Bank_Program_Name__c, Core_MDF_Channel_Program__c
                                                              FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt
                                                              WHERE Core_MDF_Channel_Program__c = :cs.Account.Core_MDF_Channel_Program__r.Name LIMIT 1];
        
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
        System.assert(ecmList != NULL);
        Core_MDF_ECMCreationServerController.saveECMRecordsCtrl(NULL,ecmString);
        Core_MDF_ECMCreationServerController.fetchExceptions(NULL);
        Core_MDF_ECMCreationServerController.fetchExceptionRecords('XYZ');
        Core_MDF_ECMCreationServerController.fetchExceptionRecords(NULL);
        
        Test.stopTest();       
    }
    
    @isTest
    static void createECM(){
        
        
        Core_MDF_Exception__c expt = [SELECT Id, Name, Core_MDF_Exception_Start_Date_dt__c, Core_MDF_Exception_End_Date_dt__c,
                                             Core_MDF_Program_nm__c, Core_MDF_Activity_Cate_and_Type_nm__c, Core_MDF_Account_id__c,
                                             Core_MDF_Select_All_Accounts_ind__c, Core_MDF_Name_of_Exception_nm__c, Core_MDF_Exception_Reason_nm__c
                                      FROM Core_MDF_Exception__c 
                                      WHERE Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country'];
        Test.startTest();
        
        Case cs = [SELECT Id, AccountId, Account.Core_MDF_Channel_Program__r.Name
                   FROM Case 
                   WHERE Core_MDF_Activity_Category__c = 'Broadcast'];
        
        Core_MDF_BankProgram_Entitlement_Mapping__mdt bpem = [SELECT Core_MDF_Bank_Program_Name__c, Core_MDF_Channel_Program__c
                                                              FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt
                                                              WHERE Core_MDF_Channel_Program__c = :cs.Account.Core_MDF_Channel_Program__r.Name LIMIT 1];
        String ecamCreated;
        ecamCreated = '[{"ecmRecordId":"","exceptionRecord":{"Id":"'+expt.Id+'","Name":"'+expt.Name+'","Core_MDF_Exception_Start_Date_dt__c":"2019-06-24","Core_MDF_Exception_End_Date_dt__c":"2019-06-29","Core_MDF_Program_nm__c":"Core_MDF_Client_CoMarketing_Fund","Core_MDF_Activity_Cate_and_Type_nm__c":"Broadcast->Podcast","Core_MDF_Account_id__c":"'+expt.Core_MDF_Account_id__c+'","Core_MDF_Select_All_Accounts_ind__c":false,"Core_MDF_Name_of_Exception_nm__c":"'+expt.Core_MDF_Name_of_Exception_nm__c+'","Core_MDF_Exception_Reason_nm__c":"'+expt.Core_MDF_Exception_Reason_nm__c+'"},"exceptionRecordLink":"'+'/'+expt.Id+'","isChecked":true,"isECMAlreadyCreated":true}]';
        
        String caseId;
        caseId = cs.Id;
        
        Test.stopTest();
        
        Core_MDF_ECMCreationServerController.saveECMRecordsCtrl(caseId,ecamCreated);
        
        Core_MDF_Exception_Case_Mapping__Share ecmShare = [SELECT ParentId FROM Core_MDF_Exception_Case_Mapping__Share LIMIT 1];
        System.assert(ecmShare != NULL);
        
        
    }
}