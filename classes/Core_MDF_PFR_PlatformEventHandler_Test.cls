@IsTest(SeeAllData=false)
public class Core_MDF_PFR_PlatformEventHandler_Test {
    
    @TestSetup
    static void createTestData(){
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin' LIMIT 1];
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
        User systemAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);      
        systemAdmin.LastName = 'SystemAdmin';
        systemAdmin.UserRoleId = userRole_1.Id;
        insert systemAdmin;
        
        
        
        List<ChannelProgram> cpList=new List<ChannelProgram>();
        ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);
        ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);
        cpList.add(ipaCP);
        cpList.add(ccfCp);
        system.runAs(systemAdmin){
            database.insert(cpList);
            
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('checkAndSendClaimsForPIC');
            bypassFunctionKeys.add('duplicateClaimCheck');
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
            bypassFunctionKeys.add('Bypass_Allocation_Reservation');
            bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
            bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
            bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
            bypassFunctionKeys.add('byPass_Cancel_Activity');
            bypassFunctionKeys.add('Core_MDF_Bypass_ATFBatchUpdate');
            bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_On_Owner_Chng');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_Internal_Usrs');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_External_Usrs');
            bypassFunctionKeys.add('Bypass_Claim_AdjReq_Amount_Validation');
            bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        
            bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
            bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
            bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');
            bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
            bypassFunctionKeys.add('Core_MDF_BypassATFFlagUpdate');
            bypassFunctionKeys.add('Core_MDF_BypassATFFlagUpdateBatch');
            bypassFunctionKeys.add('Core_MDF_Bypass_CloseDateExtend_ATF');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Update_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('ShareActivityWithInternalUsers_Bypass');
            bypassFunctionKeys.add('Bypass_Duplicate_Bank_Check');
            bypassFunctionKeys.add('Bypass_Bank_Internal_Sharing');
            bypassFunctionKeys.add('Bypass_Bank_External_Sharing');
            bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
            bypassFunctionKeys.add('Bypass_Bank_ABM_Sharing');
            bypassFunctionKeys.add('Bypass_ABM_Internal_Sharing');
            bypassFunctionKeys.add('Bypass_ABM_External_Sharing');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            Core_MDF_Configuration__c execution1 = new Core_MDF_Configuration__c();
            execution1.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
            execution1.Core_MDF_Category__c = 'Bank Document Hold Logic';
            execution1.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance';
            insert execution1;   
        }
        
        List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
        PermissionSet ipaAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_IPA_Acct_Mgr' LIMIT 1];
        PermissionSet claimcaseReviewerManagerPS = [SELECT Id FROM permissionset WHERE name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager' LIMIT 1];
        PermissionSet ccfAccMgr = [SELECT Id, Name From PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr' LIMIT 1];
        PermissionSet psbudLoader = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
        //PermissionSet ccpClaimSubm = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_External_Claim_Submitter' LIMIT 1];
        PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ipaAccManagerPS.Id, AssigneeId = systemAdmin.Id);
        PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = claimcaseReviewerManagerPS.Id, AssigneeId = systemAdmin.Id);
        PermissionSetAssignment psa3 = new PermissionSetAssignment(PermissionSetId = ccfAccMgr.Id, AssigneeId = systemAdmin.Id);
        PermissionSetAssignment psa4 = new PermissionSetAssignment(PermissionSetId = psbudLoader.Id, AssigneeId = systemAdmin.Id);
        //PermissionSetAssignment psa5 = new PermissionSetAssignment(PermissionSetId = ccpClaimSubm.Id, AssigneeId = systemAdmin.Id);
        permissionSetAssignmentList.add(psa1);
        permissionSetAssignmentList.add(psa2);
        permissionSetAssignmentList.add(psa3);
        permissionSetAssignmentList.add(psa4);
        system.runAs(systemAdmin){
            insert permissionSetAssignmentList;
            
            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            update ipaUltimateAccount;
            
            Account ccpIntelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCP Test Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            Database.insert(ccpIntelAccount);
            
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);           
            ipaCoMarketingAccount.Core_Geo__c = 'APJ';
            insert ipaCoMarketingAccount;

            
            List<Account> accountList = new List<Account>();
            Account ccfVc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing CCF Test Account', 
                                                                        ccfCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            ccfVc.Core_MDF_Parent_Fund_Account__c = ccpIntelAccount.Id;
            accountList.add(ccfVc);
            System.runAs(systemAdmin){
                Database.insert(accountList);
            }
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (ccpIntelAccount.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            database.insert(con);
            
            Core_AGS_Role__c agsRoleCCF = Core_MDF_CCP_TestDataUtility.createAgsRole('CCF_USER', 'Co-Marketing(Salesforce)-CCF USER', true, true);
            
            
            Core_ERPM_Engagement__c erpmEngagementCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('CCF', 'CCF', 'DEDUPB2B', 'SEC', true, true);
            
            Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('Client User',agsRoleCCF.Id ,'Intel® Partner Investment Center','CCF User',erpmEngagementCCF.Id , true,Core_MDF_CCP_ConstantClass.CCF_PROGRAM,true);
            
            Core_Contact_Entitlement__c contactEntitlementCCF = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con.Id,entitlementCCF.Id ,true,'Complete', true);
            
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            usr1.ProfileId = partnerProfile.Id;
            usr1.email = 'xyz@mail.com';
            usr1.ContactId = con.Id;
            database.insert(usr1);
            
            PermissionSet ccpClaimSubm = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_External_Claim_Submitter' LIMIT 1];
            PermissionSetAssignment psa5 = new PermissionSetAssignment(PermissionSetId = ccpClaimSubm.Id, AssigneeId = usr1.Id);
            database.insert(psa5);
            
            Group grp1 = new Group();
            grp1.name = 'PGM_TEST';
            //grp1.DeveloperName = 'Core_MDF_CCP_External'; 
            database.insert(grp1);
            
            Group grp2 = new Group();
            grp2.name = 'PGM_TEST_Group2';
            database.insert(grp2);
            
            GroupMember gm = new GroupMember();
            gm.GroupId = grp1.Id;
            gm.UserOrGroupId = usr1.Id;
            database.insert(gm);
            
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = ccpIntelAccount.Id;
            pgm.Core_MDF_Group_Name__c = 'PGM_TEST_Group2';
            pgm.Core_MDF_Type_of_Access__c = 'Internal';
            pgm.Core_MDF_Group_Id__c = grp2.Id;                
            pgm.Core_MDF_Channel_Program__c = ccfCp.Id;
            pgm.Core_MDF_Region_cd__c='WW';
            pgm.Core_MDF_Source_Txt__c = 'test';
            pgm.Core_MDF_AccountIdGroupName__c = ccpIntelAccount.Id+'PGM_TEST_Group2';
            database.insert(pgm);
            
            Core_MDF_Partner_Node_User_Mapping__c pnumRecord = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(ccfVc.Id,usr1.Id,true);
            
            string budgetType = Core_MDF_CCP_ConstantClass.PR_MDF_BUDGET_TYPE;
            Campaign ipaCampaignForAP = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',ipaCoMarketingAccount.id, System.today().addDays(-30), System.today().adddays(300),budgetType, 110000,'INDIA', 'Developer', 'Apollo Lake', 'Pending Approval', false);
            ipaCampaignForAP.Core_MDF_Region_cd__c = 'APJ';
            ipaCampaignForAP.Core_MDF_Proposal_Based_Ind__c = true;
            ipaCampaignForAP.Status = 'Pending Review';
            ipaCampaignForAP.Core_Approval_Status__c = 'Price Reviewer';
            ipaCampaignForAP.Core_MDF_Technology__c=''; // 14285 Indira
            database.insert(ipaCampaignForAP);
            
            Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
            PartnerMarketingBudget opalbudget = Core_MDF_CCP_TestDataUtility.createBudget('TestOpalPMB',recordTypeIdPMB,ccfVc.Id,ccfCp.Id,12345678,System.today().addDays(-100),System.today().addDays(+190),false);
            opalbudget.Core_MDF_Budget_Type__c='MDF';
            opalbudget.Core_MDF_Budget_Type_Txt__c='MDF';
            System.runAs(systemAdmin){
                insert opalbudget;
            }
            
            PartnerFundAllocation pfaRecordOpal = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA3',opalbudget, ccfVc, 199999, false);
            System.runAs(systemAdmin){
                insert pfaRecordOpal;
            }  
            
            List<Campaign> campList=new List<Campaign>();
            Campaign MDFcamp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCampOpal','Consumer','Intel® Corporate Logo', 'MDF or both CMP & MDF',
                                                                           Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',System.today()-250 , 
                                                                           System.today()+90, 2000, 'Unite', ccfVc.Id,'2-in-1', false);
            MDFcamp.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF;OEM CMP'; 
            MDFcamp.Core_MDF_Market__c = 'AFGHANISTAN';
            campList.add(MDFcamp);
            System.runAs(systemAdmin){
                insert campList;
            }
            
            Core_MDF_Campaign_Budgets__c oemcmpBudget = new Core_MDF_Campaign_Budgets__c();
            oemcmpBudget.Core_MDF_Budget_Name_Id__c = opalbudget.id;
            oemcmpBudget.Core_MDF_Campaign_Id__c=MDFcamp.id;
            oemcmpBudget.Core_MDF_Budget_Amt__c=363636;
            oemcmpBudget.Core_MDF_Reimbursement_Rate_Pct__c='100%';
            oemcmpBudget.Core_MDF_Reimbursement_Amt__c= 200000;
            oemcmpBudget.Core_MDF_Active_ind__c=true;
            System.runAs(systemAdmin){
                insert oemcmpBudget;
            }
            Test.startTest();
            
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
           /* PartnerFundRequest ipaPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,ipaCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),true);
            ipaPFR.Core_MDF_ActivityCategory__c = 'Outcome-Based';
			ipaPFR.Core_MDF_Activity_Types__c='Outcome-Based';
            pfrList.add(ipaPFR);*/
            
            PartnerFundRequest pfr = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.Id,ipaCoMarketingAccount.Id,System.today().addDays(-25),System.today().addDays(25),false);
            pfr.Core_MDF_BU_Split__c ='CCG';
           /* pfr.Core_MDF_ActivityCategory__c='Sales Incentive (Pre-2025)';
            pfr.Core_MDF_Activity_Types__c='Seller - Contest SPIF';*/
            pfr.Core_MDF_ActivityCategory__c='Print';
            pfr.Core_MDF_Activity_Types__c='Collateral';
            pfr.Core_MDF_Is_Outcome_Based_Ind__c=true;
            pfr.Core_MDF_BU1_Split_Percent_nbr__c=100;
            pfr.amount = 500;
            pfr.Core_MDF_Reimbursement_Rate_txt__c='60%';
            pfr.Core_MDF_Budget_Type_nm__c = budgetType;
            Database.insert(pfr);
           
            PartnerFundRequest MDFpfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                              Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(ccfVc.id),null,null,'INDIA','Small Business','Desktop',
                                                                                              'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            MDFpfr.Title = 'Test Activity';
            MDFpfr.Core_MDF_Activity_Description__c = 'Test Activity';
            MDFpfr.Core_MDF_Start_Date__c = system.today()-90;
            MDFpfr.Core_MDF_End_Date__c =  system.today()-30;
            MDFpfr.BudgetId = opalbudget.Id;
            MDFpfr.AllocationId = pfaRecordOpal.Id;
            MDFpfr.Core_MDF_Channel_Partner_Led__c = True;
            MDFpfr.Core_MDF_Budget_Type_nm__c = 'MDF';
            MDFpfr.Core_MDF_Approval_Step_Completed__c = 1;
            MDFpfr.Core_MDF_Price_reviewer_check_ind__c = False; 
            MDFpfr.Core_MDF_Program_Office_Check_ind__c = False;
            MDFpfr.Core_MDF_Require_Additional_Review_ind__c = True;
            MDFpfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            MDFpfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
            MDFpfr.Core_MDF_Intel_Activity_Owner_Id__c=systemAdmin.id;
            MDFpfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            MDFpfr.Core_MDF_MDFReimbursement_Amt__c = 1000;
            MDFpfr.Core_MDF_ActivityCategory__c='Print';
            MDFpfr.Core_MDF_Activity_Types__c='Collateral';
            MDFpfr.RequestedAmount = 1000;
            pfrList.add(MDFpfr);
            System.runAs(systemAdmin){
                insert pfrList;
            }
            MDFpfr.Core_MDF_Fund_Request_Status__c = 'Closed';
            Database.update(MDFpfr);
            
            
            /*Core_MDF_Escalation__c esc2 = new Core_MDF_Escalation__c();
            esc2.RecordTypeId=Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId();
            esc2.Core_MDF_Escalation_Name_txt__c='Test2';
            esc2.Core_MDF_Total_Dollar_Impact_amt__c= 1;
            //esc2.Core_MDF_Root_Cause_nm__c = 'Tools and Systems';
            esc2.Core_MDF_Do_not_Auto_Create_Claim_Ind__c = false;
            esc2.Core_MDF_Co_Marketing_Activity_id__c=ipaPFR.id;
            //esc2.Core_MDF_Claim_Submitter_Id__c	=  systemAdmin.Id;
            database.insert(esc2);*/
            
            
            List<Core_MDF_Escalation__c> escList = new List<Core_MDF_Escalation__c>();
            Core_MDF_Escalation__c esc3 = new Core_MDF_Escalation__c();
            esc3.RecordTypeId=Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
            esc3.Core_MDF_Escalation_Name_txt__c='Test212';
            esc3.Core_MDF_Total_Dollar_Impact_amt__c= 1;
            esc3.Core_MDF_Root_Cause_nm__c = 'Tools and Systems';
            esc3.Core_MDF_Do_not_Auto_Create_Claim_Ind__c = false;
            esc3.Core_MDF_Co_Marketing_Activity_id__c=MDFpfr.id;
            esc3.Core_MDF_Claim_Submitter_Id__c	=  usr1.Id;
            esc3.Core_MDF_Escalation_Status_nm__c = 'Approved';
          //  esc3.Core_MDF_Escalation_Type_nm__c = 'Late Claim';
           // esc3.Core_MDF_Escalation_Status_nm__c= 'Expired';
          

            escList.add(esc3);
            
            Core_MDF_Escalation__c esc4 = new Core_MDF_Escalation__c();
            esc4.RecordTypeId=Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
            esc4.Core_MDF_Escalation_Name_txt__c='Test200';
            esc4.Core_MDF_Total_Dollar_Impact_amt__c= 1;
            esc4.Core_MDF_Root_Cause_nm__c = 'Tools and Systems';
            esc4.Core_MDF_Do_not_Auto_Create_Claim_Ind__c = false;
            esc4.Core_MDF_Co_Marketing_Activity_id__c=MDFpfr.id;
            esc4.Core_MDF_Claim_Submitter_Id__c	=  usr1.Id;
            esc4.Core_MDF_Escalation_Status_nm__c = 'Approved';
            
                  
            escList.add(esc4);
            System.runAs(systemAdmin){
                insert escList;
            }
            
            List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Paid Claim CCF', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, MDFpfr.Id, MDFpfr.Core_MDF_Start_Date__c, MDFpfr.Core_MDF_End_Date__c, 500.00, System.today(), null, false);
            claim1.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
            //claim1.Status = Label.Core_MDF_Status_Submitted;
            claim1.Core_MDF_Type_Txt__c ='Claim';
            claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_Country_Location_nm__c= 'India'; 
            claim1.Core_MDF_Quarter_Year_Txt__c = 'Q3-2020';
            claim1.Core_MDF_VAT_Eligibility_Ind__c = false;
            claim1.Core_MDF_To_Be_Audited_Ind__c=false;
            claim1.Core_MDF_Region_Cd__c='APJ';
            claim1.Core_MDF_Status__c ='PIC Pending';
            claim1.Core_MDF_PIC_Review_Completed__c = false;
            claim1.Core_MDF_Bank_Doc_Hold_Ind__c = false;
            Claim1.Core_MDF_Escalation_Id__c = esc3.id;
            //claim1.Core_MDF_Escalation_Id__c = NULL;
            pfcList.add(Claim1);
            
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Paid Claim CCF2', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, MDFpfr.Id, MDFpfr.Core_MDF_Start_Date__c, MDFpfr.Core_MDF_End_Date__c, 500.00, System.today(), null, false);
            claim2.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
            //claim1.Status = Label.Core_MDF_Status_Submitted;
            claim2.Core_MDF_Type_Txt__c ='Claim';
            claim2.Core_MDF_Currency__c='USD';
            claim2.Core_MDF_Country_Location_nm__c= 'India'; 
            claim2.Core_MDF_Quarter_Year_Txt__c = 'Q3-2020';
            claim2.Core_MDF_VAT_Eligibility_Ind__c = false;
            claim2.Core_MDF_To_Be_Audited_Ind__c=false;
            claim2.Core_MDF_Region_Cd__c='APJ';
            claim2.Core_MDF_Status__c ='PIC Pending';
            claim2.Core_MDF_PIC_Review_Completed__c = false;
            claim2.Core_MDF_Bank_Doc_Hold_Ind__c = false;
            claim2.Core_MDF_Escalation_Id__c = esc4.id;
            //claim1.Core_MDF_Escalation_Id__c = NULL;
            pfcList.add(claim2);
            
            PartnerFundClaim claim3 = Core_MDF_CCP_TestDataUtility.createClaim('Paid Claim CCFRis', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, MDFpfr.Id, MDFpfr.Core_MDF_Start_Date__c, MDFpfr.Core_MDF_End_Date__c, 500.00, System.today(), null, false);
            claim3.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
            //claim1.Status = Label.Core_MDF_Status_Submitted;
            claim3.Core_MDF_Type_Txt__c ='Claim';
            claim3.Core_MDF_Currency__c='USD';
            claim3.Core_MDF_Country_Location_nm__c= 'India'; 
            claim3.Core_MDF_Quarter_Year_Txt__c = 'Q3-2020';
            claim3.Core_MDF_VAT_Eligibility_Ind__c = false;
            claim3.Core_MDF_To_Be_Audited_Ind__c=false;
            claim3.Core_MDF_Region_Cd__c='APJ';
            claim3.Core_MDF_Status__c ='PIC Pending';
            claim3.Core_MDF_PIC_Review_Completed__c = false;
            claim3.Core_MDF_Bank_Doc_Hold_Ind__c = false;
            pfcList.add(claim3);
            System.runAs(systemAdmin){
                insert pfcList;
            }
            Test.stopTest();
            
            esc3.Core_MDF_Claim_Number_id__c = Claim1.id;
           // database.update(esc3);
            
            esc4.Core_MDF_Claim_Number_id__c = claim2.id;
          //  database.update(esc4);
            
            
            
        }
    }
    
    @isTest
    static void testMethod1(){
        User systemAdmin = [Select Id from User where LastName = 'SystemAdmin'];
        system.runAs(systemAdmin){
            Test.startTest();
            set<Id> pfrIds= new set<Id>();
            set<Id> escIds = new set<Id>();
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            List<Core_MDF_Escalation__c> escList = new List<Core_MDF_Escalation__c>();
            
            PartnerFundRequest ipaPFR = [Select Id,Core_MDF_Fund_Request_Status__c,Core_MDF_Region_nm__c from PartnerFundRequest Where campaign.name = 'Test Campaign - AP' limit 1];
            ipaPFR.Core_MDF_Fund_Request_Status__c = 'Planned';
            ipaPFR.Core_MDF_Region_nm__c = 'APJ';
           // ipaPFR.Core_MDF_ActivityCategory__c = 'Outcome-Based';
            pfrList.add(ipaPFR);
            Database.update(pfrList);
            
            PartnerFundRequest opalPFR = [Select Id,Core_MDF_Fund_Request_Status__c,Core_MDF_Region_nm__c,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title = 'Test Activity' limit 1];
            pfrList.add(opalPFR);
            Database.update(pfrList);
            
            PartnerFundClaim canClaim = [Select id,RequestId,Core_MDF_Status__c,Core_MDF_Type_Txt__c,Core_MDF_Escalation_Id__c From PartnerFundClaim where Title = 'Paid Claim CCFRis' Limit 1];
            canClaim.Core_MDF_Status__c ='Closed';
          //  canClaim.Core_MDF_Escalation_Id__c='';
            canClaim.Core_MDF_Type_Txt__c='Claim';
            Database.update(canClaim);
            
            PartnerFundClaim reSubClaim = [Select id,Core_MDF_Status__c From PartnerFundClaim where Title = 'Paid Claim CCF2' Limit 1];
            reSubClaim.Core_MDF_Status__c ='Resubmission Window Closed';
            Database.update(reSubClaim);
            
            system.debug('canClaim--'+canClaim);
          
            pfrIds.add(ipaPFR.id);
         //   escIds.add(opalEsc.id);
         //   escIds.add(opalEsc2.id);
            Core_MDF_PFR_PlatformEventHandler.updateActivityAmount(pfrIds);
           // Core_MDF_PFR_PlatformEventHandler.updateEscalationStatus(escIds);
           // Core_MDF_PFR_PlatformEventHandler.updateActivityStatus(pfrIds);
            Test.stopTest();
            Assert.isNotNull(pfrIds);
        }
        
    }
     @isTest
    static void testMethod2(){
        User systemAdmin = [Select Id from User where LastName = 'SystemAdmin'];
        system.runAs(systemAdmin){
            Test.startTest();
            set<Id> pfrIds= new set<Id>();
            set<Id> escIds = new set<Id>();
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            List<Core_MDF_Escalation__c> escList = new List<Core_MDF_Escalation__c>();
            
            PartnerFundRequest ipaPFR = [Select Id,Core_MDF_Fund_Request_Status__c,Core_MDF_Region_nm__c from PartnerFundRequest Where campaign.name = 'Test Campaign - AP' limit 1];
            ipaPFR.Core_MDF_Fund_Request_Status__c = 'Planned';
            ipaPFR.Core_MDF_Region_nm__c = 'APJ';
           // ipaPFR.Core_MDF_ActivityCategory__c = 'Outcome-Based';
            pfrList.add(ipaPFR);
            Database.update(pfrList);
            
            PartnerFundRequest opalPFR = [Select Id,Core_MDF_Fund_Request_Status__c,Core_MDF_Region_nm__c,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title = 'Test Activity' limit 1];
            pfrList.add(opalPFR);
            Database.update(pfrList);
            
            PartnerFundClaim canClaim = [Select id,Core_MDF_Status__c From PartnerFundClaim where Core_MDF_Country_Location_nm__c = 'India' Limit 1];
            canClaim.Core_MDF_Status__c ='Cancelled';
            Database.update(canClaim);
            
            PartnerFundClaim reSubClaim = [Select id,Core_MDF_Status__c From PartnerFundClaim where Title = 'Paid Claim CCF2' Limit 1];
            reSubClaim.Core_MDF_Status__c ='Resubmission Window Closed';
            Database.update(reSubClaim);
            
            Core_MDF_Escalation__c opalEsc = [Select id,Core_MDF_Issue_Description_txt__c,Core_MDF_Claim_Number_id__r.Core_MDF_Status__c,Core_MDF_Escalation_Type_nm__c,Core_MDF_Escalation_Status_nm__c from Core_MDF_Escalation__c where Core_MDF_Escalation_Name_txt__c = 'Test212' limit 1];
            opalEsc.Core_MDF_Escalation_Status_nm__c = 'Approved';
            Database.update(opalEsc);
            Core_MDF_Escalation__c opalEsc2 = [Select id,Core_MDF_Issue_Description_txt__c,Core_MDF_Claim_Number_id__r.Core_MDF_Status__c,Core_MDF_Escalation_Type_nm__c,Core_MDF_Escalation_Status_nm__c from Core_MDF_Escalation__c where Core_MDF_Escalation_Name_txt__c = 'Test200' limit 1];
            opalEsc.Core_MDF_Escalation_Status_nm__c = 'Approved';
            Database.update(opalEsc2);
            
            escList.add(opalEsc);
            escList.add(opalEsc2);
            
            system.debug('opalEsc--'+opalEsc);
            system.debug('opalEsc--'+opalEsc2);
            
            pfrIds.add(ipaPFR.id);
            escIds.add(opalEsc.id);
            escIds.add(opalEsc2.id);
            Core_MDF_PFR_PlatformEventHandler.updateActivityAmount(null);
            Core_MDF_PFR_PlatformEventHandler.updateEscalationStatus(escIds);
           // Core_MDF_PFR_PlatformEventHandler.updateActivityStatus(pfrIds);
            Test.stopTest();
            Assert.isNotNull(pfrIds);
        }
        
    }
     @isTest
    static void testMethod3(){
        User systemAdmin = [Select Id from User where LastName = 'SystemAdmin'];
        system.runAs(systemAdmin){
            Test.startTest();
            set<Id> pfrIds= new set<Id>();
            set<Id> escIds = new set<Id>();
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            List<Core_MDF_Escalation__c> escList = new List<Core_MDF_Escalation__c>();
            
            PartnerFundRequest ipaPFR = [Select Id,Core_MDF_Fund_Request_Status__c,Core_MDF_Region_nm__c from PartnerFundRequest Where campaign.name = 'Test Campaign - AP' limit 1];
            ipaPFR.Core_MDF_Fund_Request_Status__c = 'Planned';
            ipaPFR.Core_MDF_Region_nm__c = 'APJ';
           // ipaPFR.Core_MDF_ActivityCategory__c = 'Outcome-Based';
            pfrList.add(ipaPFR);
            Database.update(pfrList);
            
            PartnerFundRequest opalPFR = [Select Id,Core_MDF_Fund_Request_Status__c,Core_MDF_Region_nm__c,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title = 'Test Activity' limit 1];
            pfrList.add(opalPFR);
            Database.update(pfrList);
            
            PartnerFundClaim canClaim = [Select id,Core_MDF_Status__c From PartnerFundClaim where Core_MDF_Country_Location_nm__c = 'India' Limit 1];
            canClaim.Core_MDF_Status__c ='Cancelled';
            Database.update(canClaim);
            
            PartnerFundClaim reSubClaim = [Select id,Core_MDF_Status__c From PartnerFundClaim where Title = 'Paid Claim CCF2' Limit 1];
            reSubClaim.Core_MDF_Status__c ='Resubmission Window Closed';
            Database.update(reSubClaim);
            
            Core_MDF_Escalation__c opalEsc = [Select id,Core_MDF_Issue_Description_txt__c,Core_MDF_Claim_Number_id__r.Core_MDF_Status__c,Core_MDF_Escalation_Type_nm__c,Core_MDF_Escalation_Status_nm__c from Core_MDF_Escalation__c where Core_MDF_Escalation_Name_txt__c = 'Test212' limit 1];
            opalEsc.Core_MDF_Escalation_Status_nm__c = 'Approved';
            opalEsc.Core_MDF_Claim_Number_id__r.Core_MDF_Status__c='';
            Database.update(opalEsc);
            Core_MDF_Escalation__c opalEsc2 = [Select id,Core_MDF_Issue_Description_txt__c,Core_MDF_Claim_Number_id__r.Core_MDF_Status__c,Core_MDF_Escalation_Type_nm__c,Core_MDF_Escalation_Status_nm__c from Core_MDF_Escalation__c where Core_MDF_Escalation_Name_txt__c = 'Test200' limit 1];
            opalEsc.Core_MDF_Escalation_Status_nm__c = 'Approved';
            opalEsc.Core_MDF_Claim_Number_id__r.Core_MDF_Status__c='';
            Database.update(opalEsc2);
            
            escList.add(opalEsc);
            escList.add(opalEsc2);
            
            system.debug('opalEsc--'+opalEsc);
            system.debug('opalEsc--'+opalEsc2);
            
            pfrIds.add(ipaPFR.id);
            escIds.add(opalEsc.id);
            escIds.add(opalEsc2.id);
            Core_MDF_PFR_PlatformEventHandler.updateActivityAmount(null);
            Core_MDF_PFR_PlatformEventHandler.updateEscalationStatus(escIds);
            Core_MDF_PFR_PlatformEventHandler.updateActivityStatus(pfrIds);
            Test.stopTest();
            Assert.isNotNull(pfrIds);
        } 
    }
}