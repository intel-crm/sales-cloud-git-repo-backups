/****************************************************************************************************************************************
* Class Name        : Core_MDF_PFR_Approval_Test
* Created Date      : 11/26/2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - HA       11/26/2019         Test Class for Core_MDF_PFR_Approval
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_PFR_Approval_Test {
    
    @TestSetUp
    static void createData(){
               
        UserRole usRole1 = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole1.Id;
        Database.insert(usr);
       	List<Core_MDF_Partner_Group_Mapping__c> ccfpgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
        System.runAs(usr){
        	Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            Set<String> psNameSet = new Set<String> ();
            Map<string,String>  psNameVsIdMap = new Map<string,String>();
            psNameSet.add('Core_MDF_CCP_Internal_Retail_Account_Manager');
            psNameSet.add('Core_MDF_CCP_Internal_Generic_Access');
            psNameSet.add('Core_MDF_CCP_Internal_Price_Reviewer');
            psNameSet.add('Core_MDF_CCP_Internal_Retail_Lvl1_Activity_Approver');
            psNameSet.add('Core_MDF_CCP_Internal_IPA_Acct_Mg');
            psNameVsIdMap = getPermissionSetIdbyName(psNameSet);
            String rmfAcctMgrPsId =  psNameVsIdMap.get('Core_MDF_CCP_Internal_Retail_Account_Manager');
            String genricAccessPsId =  psNameVsIdMap.get('Core_MDF_CCP_Internal_Generic_Access');
            String priceRevPsId =  psNameVsIdMap.get('Core_MDF_CCP_Internal_Price_Reviewer');
            String rmfL1PsId =  psNameVsIdMap.get('Core_MDF_CCP_Internal_Retail_Lvl1_Activity_Approver');
            String IPAPsId =  psNameVsIdMap.get('Core_MDF_CCP_Internal_IPA_Acct_Mg');
            User rmfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            rmfaccntmngr.Email = 'rmfaccntmngr@example.com';
            rmfaccntmngr.Profile = ccpCoreAccessProfile;
            Database.insert(rmfaccntmngr);
            
            User rmfpricerev = Core_MDF_CCP_TestDataUtility.createUser(false);
            rmfpricerev.Email = 'rmfpricerev@example.com';
            rmfpricerev.Profile = ccpCoreAccessProfile;
            Database.insert(rmfpricerev);
            
            User rmfL1approver = Core_MDF_CCP_TestDataUtility.createUser(false);
            rmfL1approver.Email = 'rmfL1approver@example.com';
            rmfL1approver.Profile = ccpCoreAccessProfile;
            Database.insert(rmfL1approver);
            
            User IPAmanager = Core_MDF_CCP_TestDataUtility.createUser(false);
            IPAmanager.Email = 'IPAmanager@example.com';
            IPAmanager.Profile = ccpCoreAccessProfile;
            Database.insert(IPAmanager);
            
            List<PermissionSetAssignment> psAssignList = new List<PermissionSetAssignment>();
            psAssignList.add(new PermissionSetAssignment(AssigneeId = rmfaccntmngr.id, PermissionSetId =rmfAcctMgrPsId));   
            psAssignList.add(new PermissionSetAssignment(AssigneeId = rmfaccntmngr.id, PermissionSetId =genricAccessPsId));
            psAssignList.add(new PermissionSetAssignment(AssigneeId = rmfpricerev.id, PermissionSetId =priceRevPsId)); 
            psAssignList.add(new PermissionSetAssignment(AssigneeId = rmfL1approver.id, PermissionSetId =priceRevPsId)); 
            insert psAssignList;
            
            ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
            ChannelProgram eefCp = Core_MDF_CCP_TestDataUtility.createProgram('Ecosystem Extension Fund','Ecosystem Extension Fund', true);
            
            List<Account> accList = new List<Account>();
            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account IPACoMarketingAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Test IPA Account', ipaCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
            IPACoMarketingAcc.Core_MDF_Parent_Fund_Account__c = ipaUltimateAccount.Id;
            IPACoMarketingAcc.Core_MDF_CoMarketing_Ultimate_Account__c = ipaUltimateAccount.Id;
            Database.insert(IPACoMarketingAcc);
            Account acc1Retail = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Retail', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                                  false);
            acc1Retail.Core_Account_Type__c = 'Reseller';
            acc1Retail.Industry = 'Food & Beverage';
            acc1Retail.Core_MDF_Channel_Program__c = cpRetail.Id;
            acc1Retail.Core_Geo__c = 'EMEA';
            acc1Retail.Core_Sub_Geo__c = 'WEUR';
            accList.add(acc1Retail);

            //EEF Account
            Account intelPrimAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Primary Intel Account', 
                                     Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            accList.add(intelPrimAcc);
            Account intelActAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Activating Intel Account', 
                                    Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            accList.add(intelActAcc);

            Database.insert(accList);
            
            List<Account> accCoMarketingList = new List<Account>();
           	Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cpRetail.Id,
                                                                            Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accRetail.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
            accRetail.Core_Geo__c = 'EMEA';
            accRetail.Core_Sub_Geo__c = 'WEUR';
            accCoMarketingList.add(accRetail);

            Account accCoMarketing = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account CCP', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
            accCoMarketing.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
            accCoMarketing.Core_MDF_CoMarketing_Ultimate_Account__c = acc1Retail.Id;
            accCoMarketingList.add(accCoMarketing);

            Account PrimaryVC = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Primary VC Account',
                                                                             eefCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, 
                                                                             intelPrimAcc.Id, false);
            PrimaryVC.Core_MDF_Partner_Type_nm__c = 'Primary Partner';
            PrimaryVC.Core_MDF_Active_Ind__c = true;
            accCoMarketingList.add(PrimaryVC);

            Account activatingVC = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Acticating VC Account',
                                                                             eefCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, 
                                                                             intelActAcc.Id, false);
            activatingVC.Core_MDF_Partner_Type_nm__c = 'Activating Partner';
            activatingVC.Core_MDF_Active_Ind__c = true;
            accCoMarketingList.add(activatingVC);

            Database.insert(accCoMarketingList);
            
            PermissionSet accountManager = [select id from PermissionSet where name='Core_MDF_CCP_Internal_Retail_Account_Manager'];
            PermissionSet accountReviewer = [select id from PermissionSet where name=:Label.Core_MDF_Retail_Reviewer_Permission_Set];
           	PermissionSet fieldOwnerPS = [select id from PermissionSet where name=:'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr'];//Core_MDF_CCP_Internal_CCF_Field_Owner
            PermissionSet marktngOwnerPS = [select id from PermissionSet where name=:'Core_MDF_CCP_Internal_CCF_Acct_Mgr'];//Core_MDF_CCP_Internal_CCF_Marketing_Owner
           	PermissionSet priceReviewer = [select id from PermissionSet where name=:'Core_MDF_CCP_Internal_Price_Reviewer'];
            PermissionSet ProgOfficeReviewer = [select id from PermissionSet where name=:'Core_MDF_CCP_Internal_Proposal_Activity_POR_Approver'];
            List<User> userList = new List<User>();
            
            //Creating User who is an Account Manager
            User usrRW = Core_MDF_CCP_TestDataUtility.createUser(false);
            usrRW.UserRoleId = usRole1.Id;
            usrRW.LastName = 'Retail Account Reviewer Test ';
            userList.add(usrRW);
            
            //Creating User who is an Retail After The Fact
            User userAF = Core_MDF_CCP_TestDataUtility.createUser(false);
            userAF.UserRoleId = usRole1.Id;
            userAF.LastName = 'Retail After The Fact';
            userList.add(userAF);
            
            User userPR = Core_MDF_CCP_TestDataUtility.createUser(false);
            userPR.UserRoleId = usRole1.Id;
            userPR.LastName = 'PRICE REVIEWER';
            userList.add(userPR);
            
            User userPOR = Core_MDF_CCP_TestDataUtility.createUser(false);
            userPOR.UserRoleId = usRole1.Id;
            userPOR.LastName = 'PROGRAM OFFICE REVIEWER';
            userList.add(userPOR);
            
            //Creating User who is an Account Manager
            User usrAM = Core_MDF_CCP_TestDataUtility.createUser(false);
            usrAM.LastName = 'Retail Account Manager';
            userList.add(usrAM);
            
            //Creating User who is an CCF Account Manager
            User usrCCFAM = Core_MDF_CCP_TestDataUtility.createUser(false);
            usrCCFAM.LastName = 'CCF Account Manager';
            userList.add(usrCCFAM);

            //EEF User
            User usr8 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr8.lastname = 'Test EEF User8';
            userList.add(usr8);
            User usrEEFPP = Core_MDF_CCP_TestDataUtility.createUser(false);
            usrEEFPP.lastname = 'Test EEF Primary Account Manager';
            userList.add(usrEEFPP);
            User usr9 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr9.lastname = 'Test EEF Account Manager';
            userList.add(usr9);
            Database.insert(userList);
            
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            PermissionSetAssignment psPOR = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(userPOR.id,ProgOfficeReviewer.id,false);
            PermissionSetAssignment psAR = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usrRW.id,accountReviewer.id,false);
            PermissionSetAssignment psAM = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usrAM.id,accountManager.id,false);
            //PermissionSetAssignment psAFA = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(userAF.id,afterTheFactApprover.id,false);
            
            PermissionSetAssignment psFO = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usrCCFAM.id,fieldOwnerPS.id,false);
            PermissionSetAssignment psMO = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usrCCFAM.id,marktngOwnerPS.id,false);
            PermissionSetAssignment psPR = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(userPR.id,priceReviewer.id,false);
            permissionSet eefBudgetLoaderPs= [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Budget_Loader' LIMIT 1];
            PermissionSetAssignment perm4 = new PermissionSetAssignment(AssigneeId = usr8.id, PermissionSetId = eefBudgetLoaderPs.Id);
            psaList.add(perm4);
            permissionSet primaryAccManPs= [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr' LIMIT 1];
            PermissionSetAssignment perm5 = new PermissionSetAssignment(AssigneeId = usrEEFPP.id, PermissionSetId = primaryAccManPs.Id);
            psaList.add(perm5);
            
            psaList.add(psAR);
            psaList.add(psAM);
            psaList.add(psPOR);
           	psaList.add(psFO);
            psaList.add(psMO);
            psaList.add(psPR);
            Database.insert(psaList);
            
            // Creating Contact with utility class
            Contact con = Core_MDF_CCP_TestDataUtility.createContact(acc1Retail.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            con.Core_Audience_List__c = 'RMF User; RMF External activity approver';
            Database.insert(con);
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name = 'Partner' LIMIT 50000];
            
            // Creating User with utility class
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'External Approver 1';
            usr2.ProfileId = partnerProfile.Id;
            usr2.ContactId = con.Id;
            usr2.isActive = true;
            Database.insert(usr2);
            Test.startTest();
            
            Group grp1 = new Group();
            grp1.Name = 'Core_MDF_CCP_External';
            grp1.DeveloperName = 'Core_MDF_CCP_External';
            Database.insert(grp1);
            
            // Creating Group Members
            GroupMember grpMember = new GroupMember();
            grpMember.UserOrGroupId = usr2.Id;
            grpMember.GroupId = grp1.Id;
            Database.insert(grpMember);
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = acc1Retail.Id;
            pgm1.Core_MDF_Virtual_Corp_nm__c = accRetail.id ;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_External';
            pgm1.Core_MDF_Type_of_Access__c = 'External';
            pgm1.Core_MDF_Group_Id__c = grp1.Id;
            pgm1.Core_MDF_Channel_Program__c = cpRetail.Id;
            pgm1.Core_MDF_AccountIdGroupName__c = acc1Retail.Id+'Core_MDF_CCP_External';
            pgm1.Core_MDF_Source_Txt__c = 'test';
            Database.insert(pgm1);
            
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: 'Core_MDF_CCP_External_Activity_Approver'];
            PermissionSet psextrnl = [SELECT Id FROM PermissionSet WHERE Name =: 'Core_MDF_CCP_External_Activity_Submitter'];
            insert new PermissionSetAssignment(AssigneeId = usr2.id, PermissionSetId = ps.Id);
            insert new PermissionSetAssignment(AssigneeId = usr2.id, PermissionSetId = psextrnl.Id);
            
            //Create Retail Group
            Group ccfgrp3 = new Group();
            ccfgrp3.Name = 'Core CCP Retail Internal EMEA';
            ccfgrp3.DeveloperName = 'Core_CCP_Retail_Internal_EMEA';
            Database.insert(ccfgrp3);
            
            // Creating Group Members
            GroupMember grpMemberam = new GroupMember();
            grpMemberam.UserOrGroupId = usrAM.Id;
            grpMemberam.GroupId = ccfgrp3.Id;
            Database.insert(grpMemberam);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgm3 = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm3.Core_MDF_Account__c = acc1Retail.Id;
            ccfPgm3.Core_MDF_Virtual_Corp_nm__c = accRetail.id ;
            ccfPgm3.Core_MDF_Group_Name__c = 'Core_CCP_Retail_Internal_EMEA';
            ccfPgm3.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm3.Core_MDF_Group_Id__c = ccfgrp3.Id;
            ccfPgm3.Core_MDF_Channel_Program__c = cpRetail.Id;
            ccfPgm3.Core_MDF_Region_cd__c = 'EMEA';
            ccfPgm3.Core_MDF_Source_Txt__c = 'test';
            ccfPgm3.Core_MDF_AccountIdGroupName__c = acc1Retail.Id+'Core_CCP_Retail_Internal_EMEA';
            //Database.insert(ccfPgm3);
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
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
        	bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
        	bypassFunctionKeys.add('Core_MDF_XMLToXLSGenerationFlag');
       	 	bypassFunctionKeys.add('Core_MDF_StringToXLSGenerationFlag');
            bypassFunctionKeys.add('Core_MDF_Bypass_TargetSetngValidations');
        	bypassFunctionKeys.add('Bypass_PaymentsBulkAPISharing');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Update_Validation');
            bypassFunctionKeys.add('byPass_Cancel_Activity');
            bypassFunctionKeys.add('byPass_PastDated_Activity');
            bypassFunctionKeys.add('Core_MDF_Bypass_LateClaimOperations');
            bypassFunctionKeys.add('Core_MDF_Bypass_TargetSetngValidations');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true); 
            
            //IUPGM Insert
            Id iupgm_Recordtype_EEF = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm1.RecordTypeId =  iupgm_Recordtype_EEF;
            iupgm1.Core_MDF_Program_nm__c = 'Ecosystem Extension Fund';
            iupgm1.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgm1.Core_MDF_User_id__c =  usrEEFPP.Id;
            iupgm1.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            iupgm1.Core_MDF_All_Accounts_cd__c = 'No';
            iupgm1.Core_MDF_Account_id__c = intelPrimAcc.Id;
            iupgm1.Core_MDF_Role_nm__c='Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr';
            iupgm1.Core_MDF_Channel_Program_id__c = eefCp.Id;
            iupgmList.add(iupgm1);

            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm2 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm2.RecordTypeId =  iupgm_Recordtype_EEF;
            iupgm2.Core_MDF_Program_nm__c = 'Ecosystem Extension Fund';
            iupgm2.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgm2.Core_MDF_User_id__c =  usr8.Id;
            iupgm2.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            iupgm2.Core_MDF_All_Accounts_cd__c = 'Yes';
            iupgm2.Core_MDF_Role_nm__c='Core_MDF_Internal_EEF_Budget_Loader';
            iupgm2.Core_MDF_Channel_Program_id__c = eefCp.Id;
            iupgmList.add(iupgm2);

            //Database.insert(iupgmList);
            
            Id camp_Recordtype_EEF = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
            Id pfr_Recordtype_EEF = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
        
            Core_MDF_Partner_Mapping__c primToActPartnerMapping = new Core_MDF_Partner_Mapping__c();
            primToActPartnerMapping.Core_MDF_Primary_Partner_Account_id__c = PrimaryVC.id;
            primToActPartnerMapping.Core_MDF_Activating_Partner_Account_id__c = activatingVC.id;
            primToActPartnerMapping.Core_MDF_Effective_Start_Date__c = system.today()-90;
            primToActPartnerMapping.Core_MDF_Effective_End_Date__c = system.today () +100;
            primToActPartnerMapping.Core_MDF_Channel_Program__c = eefCp.Id;
            insert primToActPartnerMapping;

            PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                           accRetail.id, cpRetail.Id , 10000 , System.today()-60 , System.today() + 30 , 
                                                                                           false);
            
            
            testBudget1.IsIgnoreValidation = true;
           	insert testBudget1;
            testBudget1.Core_MDF_Budget_Status__c = 'Released';
            update testBudget1;

            Id budget_EEFRecord_Type = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
            PartnerMarketingBudget testBudgetCloud = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetCloud',budget_EEFRecord_Type,
                                                                                         PrimaryVC.id, eefCp.Id , 300 ,  System.today().addDays(-30) ,System.today().addDays(30),
                                                                                         false);
        
            testBudgetCloud.IsIgnoreValidation = true;
            testBudgetCloud.Core_MDF_Budget_Type_Txt__c = 'Cloud';
            testBudgetCloud.Core_MDF_Budget_Type__c='Cloud';
            //System.runAs(usr8){
                insert testBudgetCloud;
            //}
            List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
            PartnerFundAllocation eefAllocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation EEF',
                                              testBudgetCloud,PrimaryVC,200.0,false);
		    PartnerFundAllocation eefActAllocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation activating EEF',
                                              testBudgetCloud,activatingVC,100.0,false);
            pfaList.add(eefAllocation);
            pfaList.add(eefActAllocation);

            database.insert(pfaList);
                        
            List<Campaign> campLst = new List<Campaign>();
            
            Campaign camp2 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena','MDF or both CMP & MDF', 
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today().addDays(16) , 
                                                                         System.today().addYears(1), 2000, 'Instore innovation', accRetail.Id,'2-in-1', false);
            camp2.Core_MDF_Opal_Budget_Type_Txt__c= 'Retail MDF';
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7+ Processor','CMP only', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today()-15, System.today()+15, 10000, 'Consumer Chromebook', accCoMarketing.Id, '2-in-1', false);
            camp.Core_MDF_Opal_Budget_Type_Txt__c= 'OEM CMP';
            Campaign camp4 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp IPA','Gaming','Intel® Core™ i7+ Processor','All MDF or both CMP & MDF', Core_MDF_CCP_IPA_TestDataUtility.campaign_RecordType_IPA, 'Intel Partner Alliance', System.today()-15, System.today()+15, 10000, 'Consumer Chromebook', IPACoMarketingAcc.Id, '2-in-1', false);
            camp4.Core_MDF_Proposal_Based_Ind__c=false;
            camp4.Core_MDF_Program__c='Intel Partner Alliance';
            camp4.Core_MDF_Market__c='India';
            camp4.Core_MDF_Opal_Budget_Type_Txt__c= 'Account Plan';
            campLst.add(camp2);
            campLst.add(camp);
            campLst.add(camp4);

            Campaign eefCampaign  = Core_MDF_CCP_TestDataUtility.createCampaign('Test EEF Camp','Gaming','Athena', 'MDF or both CMP & MDF',
                                                                         camp_Recordtype_EEF, 
                                                                         'Ecosystem Extension Fund', system.today() - 30, //System.today().addDays(-300), 
                                                                         System.today() + 30, 100000, 'Advanced Analystics', 
                                                                         PrimaryVC.Id,'Cloud Instance Consumption', false);
            eefCampaign.Core_MDF_Partner_Mapping_Txt__c = activatingVC.id;
            eefCampaign.Core_MDF_Reimbursement_Rate__c = '100%';
            eefCampaign.Core_MDF_Opal_Budget_Type_Txt__c= 'Cloud';
            campLst.add(eefCampaign);
            Database.insert(campLst);
            
            Account accCoMarketingCCF = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 2', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
            Campaign campCCF= Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo','Yes', 
                                                                       Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',System.today() , 
                                                                       System.today().addYears(1), 2000, 'Unite', accCoMarketingCCF.Id,'2-in-1', false);
            campCCF.Core_MDF_Opal_Budget_Type_Txt__c= 'OEM CMP';
            insert campCCF;
            
            
            Core_MDF_Criteria__c crMulti = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_MultiLevel',
                                                                                       'Core_MDF_Program__c','Equal','Retail Marketing Funds','RequestedAmount','Greater Than', '0',
                                                                                       'Core_MDF_Program__c','Equal','Retail Marketing Funds','RequestedAmount','Greater Than','0','RequestedAmount','Greater Than','0',false);
            crMulti.Core_MDF_Number_Of_Steps__c = '4';
            Database.insert(crMulti);
            
            Core_MDF_Approver__c ap1Retail = Core_MDF_CCP_TestDataUtility.createApprover(crMulti.Id,usrAM.Id, false);
            ap1Retail.Core_MDF_Approver_Type__c = 'Internal';
            ap1Retail.Core_MDF_Step_Number__c = 1;
            Database.insert(ap1Retail);
            
            // Retail criteria rules
            Core_MDF_Criteria_Rule__c cruleR1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'Core_MDF_Program__c','Equal',
                                                                                                'Retail Marketing Funds',true);
            
            Core_MDF_Criteria_Rule__c cruleR2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'RequestedAmount','Greater Than',
                                                                                                '0',true);
            
            Core_MDF_Criteria_Rule__c cruleR3 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'Core_MDF_Fund_Request_Status__c','Equal',
                                                                                                'Pending Review',true);
            Core_MDF_Criteria_Rule__c cruleR4 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'Core_MDF_Approval_Step_Completed__c','Equal',
                                                                                                '0',true);
            
            ap1Retail.Core_MDF_Active__c = true;
            Database.update(ap1Retail);
            crMulti.Core_MDF_Active__c = true;
            Database.update(crMulti);
            
            Core_MDF_Approver__c ap2Retail = Core_MDF_CCP_TestDataUtility.createApprover(crMulti.Id,usr2.Id, false);
            ap2Retail.Core_MDF_Approver_Type__c = 'External';
            ap2Retail.Core_MDF_Step_Number__c = 2;
            Database.insert(ap2Retail);
            
            // Retail criteria rules
            Core_MDF_Criteria_Rule__c cruleR21 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2Retail.Id,'Core_MDF_Program__c','Equal',
                                                                                                 'Retail Marketing Funds',true);
            
            Core_MDF_Criteria_Rule__c cruleR22 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2Retail.Id,'RequestedAmount','Greater Than',
                                                                                                 '0',true);
            
            Core_MDF_Criteria_Rule__c cruleR23 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2Retail.Id,'Core_MDF_Fund_Request_Status__c','Equal',
                                                                                                 'Pending Approval',true);
            
            Core_MDF_Criteria_Rule__c cruleR24 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2Retail.Id,'Core_MDF_Approval_Step_Completed__c','Equal',
                                                                                                 '1',true);
            
            ap2Retail.Core_MDF_Active__c = true;
            Database.update(ap2Retail);
            
            // Create activity
            date sdate = date.today();        
            list<PartnerFundRequest> pfrs = new list<PartnerFundRequest>();
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp2.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accRetail.id),NULL,NULL,'UNITED KINGDOM','Partner Sales Force','Traditional Notebook',
                                                                                           'Intel® 11ᵗʰ Gen','Sales Incentive','Seller - Target SPIF','Draft',false); 
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr.Core_MDF_Start_Date__c = System.today().addDays(17);
            pfr.Core_MDF_End_Date__c = System.today().addDays(18);
            pfr.RequestedAmount = 15;
            pfr.Core_MDF_Country_nm__c = 'UNITED KINGDOM;FRANCE';
            //pfr.Core_MDF_Region_Cd__c = 'EMEA';
            pfr.Core_MDF_Region_nm__c = 'EMEA';
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Core_MDF_Approval_Step_Completed__c = 0;
            pfr.Core_MDF_Price_reviewer_check_ind__c = true;
            pfrs.add(pfr);

            PartnerFundRequest eefPfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(eefCampaign.Id),
                                                                                        pfr_Recordtype_EEF,string.valueof(activatingVC.id),eefAllocation,testBudgetCloud,'INDIA','Technical Influencer','Cloud Instance Consumption',
                                                                                        'Intel® SGX','Broadcast','Radio','Draft',false);
            eefPfr.Core_MDF_Budget_Type_nm__c = 'Cloud'; 
            eefPfr.Title ='Test EEF Activity';
            eefPfr.RequestedAmount =200;
            eefPfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            eefPfr.Core_MDF_Approval_Step_Completed__c=1;
        	eefPfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfrs.add(eefPfr);
            
            //Retail SPIF
            PartnerFundRequest pfrspif = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp2.Id),
                                                                                               Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accRetail.id),NULL,NULL,'India','Partner Sales Force','Traditional Notebook',
                                                                                               'Intel® 11ᵗʰ Gen','Sales Readiness','In-Store Promotion','Draft',false); 
            pfrspif.Title = 'Test Retail Activity';
            pfrspif.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfrspif.Core_MDF_Start_Date__c = System.today().addDays(17);
            pfrspif.Core_MDF_End_Date__c = System.today().addDays(18);
            pfrspif.RequestedAmount = 15;
            pfrspif.Core_MDF_Country_nm__c = 'India';
            //pfrspif.Core_MDF_Region_Cd__c = 'APJ';
            pfrspif.Core_MDF_Region_nm__c = 'APJ';
            pfrspif.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfrspif.Core_MDF_Price_reviewer_check_ind__c = true;
            pfrspif.Core_MDF_Approval_Step_Completed__c = 0;
           	pfrs.add(pfrspif);
            
            PartnerFundRequest pfrspif2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp2.Id),
                                                                                               Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accRetail.id),NULL,NULL,'India','Partner Sales Force','Traditional Notebook',
                                                                                               'Intel® 11ᵗʰ Gen','Sales Readiness','In-Store Promotion','Draft',false); 
            pfrspif2.Title = 'Test Retail Activity Spif';
            pfrspif2.Core_MDF_Activity_Description__c = 'Test Retail Activity Spif';
            pfrspif2.Core_MDF_Start_Date__c = System.today().addDays(17);
            pfrspif2.Core_MDF_End_Date__c = System.today().addDays(18);
            pfrspif2.RequestedAmount = 15;
            pfrspif2.Core_MDF_Country_nm__c = 'India';
            //pfrspif2.Core_MDF_Region_Cd__c = 'APJ';
            pfrspif2.Core_MDF_Region_nm__c = 'APJ';
           	pfrspif2.Core_MDF_Price_reviewer_check_ind__c = true;
            pfrspif2.Core_MDF_Approval_Step_Completed__c = 0;
            pfrspif2.Core_MDF_Fund_Request_Status__c = 'Pending Approval';  
            pfrs.add(pfrspif2);
            
            PartnerFundRequest pfrspif3 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp2.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accRetail.id),NULL,NULL,'UNITED KINGDOM','Partner Sales Force','Traditional Notebook',
                                                                                           'Intel® 11ᵗʰ Gen','Sales Incentive','Seller - Target SPIF','Draft',false); 
            pfrspif3.Title = 'Test Retail Activity Spif';
            pfrspif3.Core_MDF_Activity_Description__c = 'Test Retail Activity Spif';
            pfrspif3.Core_MDF_Start_Date__c = System.today().addDays(17);
            pfrspif3.Core_MDF_End_Date__c = System.today().addDays(18);
            pfrspif3.RequestedAmount = 15;
            pfrspif3.Core_MDF_Country_nm__c = 'UNITED KINGDOM;FRANCE';
            //pfrspif3.Core_MDF_Region_Cd__c = 'EMEA';
            pfrspif3.Core_MDF_Region_nm__c = 'EMEA';
            pfrspif3.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
            pfrspif3.Core_MDF_Approval_Step_Completed__c = 0;
           	pfrspif3.Core_MDF_Price_reviewer_check_ind__c = true;
            pfrs.add(pfrspif3);
            
           	PartnerFundRequest pfrCCF = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(camp.id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event','Channel Partner Owned Event','Draft',false);
            pfrCCF.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfrCCF.Title = 'Test Activity CCF';
            pfrCCF.Core_MDF_Activity_Description__c = 'Test Activity CCF';
            pfrCCF.Core_MDF_Channel_Partner_Led__c = True;
            pfrCCF.Core_MDF_Budget_Amount_Local_amt__c=100000000;
            pfrCCF.Core_MDF_Budget_Currency_cd__c='USD';
            pfrCCF.Core_MDF_Start_Date__c= System.today()-15;
            pfrCCF.Core_MDF_End_Date__c = System.today()-15;
           	pfrs.add(pfrCCF);
            
            PartnerFundRequest pfrCCF2 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(camp.id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event','Channel Partner Owned Event','Draft',false);
            pfrCCF2.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
            pfrCCF2.Title = 'Test Activity CCF2';
            pfrCCF2.Core_MDF_Activity_Description__c = 'Test Activity CCF2';
            pfrCCF2.Core_MDF_Channel_Partner_Led__c = True;
            pfrCCF2.Core_MDF_Budget_Amount_Local_amt__c=100000000;
            pfrCCF2.Core_MDF_Budget_Currency_cd__c='USD';
            pfrCCF2.Core_MDF_Approval_Stage__c = 'L1 Approval';
            pfrCCF2.Core_MDF_Start_Date__c= System.today()-15;
            pfrCCF2.Core_MDF_End_Date__c = System.today()-15;
           	pfrs.add(pfrCCF2);
            
            
            PartnerFundRequest IPApfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp4.Id),
                                                                                              Core_MDF_CCP_IPA_TestDataUtility.partnerFund_RecordType_IPA,string.valueof(IPACoMarketingAcc.id),NULL,NULL,'India','','Cloud',
                                                                                              'Intel® 11ᵗʰ Gen','Sales Incentive','Seller - Target SPIF','Draft',false); 
            IPApfr.Core_MDF_Activity_Description__c = 'Test IPA Activity';
            IPApfr.Title = 'Test IPA Activity';
            IPApfr.Core_MDF_Approval_Stage__c='Program Office Reviewer';
            IPApfr.Core_MDF_Start_Date__c = System.today().addDays(1);
            IPApfr.Core_MDF_End_Date__c = System.today().addDays(2);
            IPApfr.Core_MDF_Program_Office_Check_ind__c = true;
            IPApfr.Core_MDF_Country_nm__c = 'India';
            IPApfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfrs.add(IPApfr);
            //Database.insert(pfrs);
            
            PartnerFundRequest pfr12 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp2.Id),Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accRetail.id),NULL,NULL,
                                                                                             'UNITED KINGDOM','Partner Sales Force','Traditional Notebook', 'Intel® 11ᵗʰ Gen','Sales Incentive','Seller - Target SPIF','Draft',false); 
            
            pfr12.Title = 'Test Retail Activity12';
            pfr12.Core_MDF_Activity_Description__c = 'Test Retail Activity12';
            pfr12.Core_MDF_Start_Date__c = System.today().addDays(17);
            pfr12.Core_MDF_End_Date__c = System.today().addDays(18);
            pfr12.RequestedAmount = 25005; 
            pfr12.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr12.Core_MDF_Approval_Step_Completed__c = 0;
            pfr12.Core_MDF_Price_reviewer_check_ind__c = true;
            //pfr12.Core_MDF_Region_Cd__c = 'EMEA';
            pfr12.Core_MDF_Region_nm__c = 'EMEA';
            pfrs.add(pfr12);
            //Database.insert(pfr12);
            
            PartnerFundRequest pfrtest = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp2.Id), Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accRetail.id),NULL,NULL,'UNITED KINGDOM','Partner Sales Force','Traditional Notebook',
                                                                                            'Intel® 11ᵗʰ Gen','Sales Incentive','Seller - Per Unit SPIF','Draft',false); 
            pfrtest.Title = 'Test Retail Activity2';
            pfrtest.Core_MDF_Activity_Description__c = 'Test Retail Activity2';
            pfrtest.Core_MDF_Start_Date__c = System.today().addDays(17);
            pfrtest.Core_MDF_End_Date__c = System.today().addDays(18);
            pfrtest.RequestedAmount = 25004;
            pfrtest.Core_MDF_Country_nm__c = 'UNITED KINGDOM';
            //pfrtest.Core_MDF_Region_Cd__c = 'EMEA';
            pfrtest.Core_MDF_Region_nm__c = 'EMEA';
            pfrtest.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfrtest.Core_MDF_Approval_Step_Completed__c = 0;
            pfrtest.Core_MDF_Price_reviewer_check_ind__c = true;
            pfrs.add(pfrtest);
            //Database.insert(pfrtest);
            
            PartnerFundRequest IPApfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp4.Id),
                                                                                          Core_MDF_CCP_IPA_TestDataUtility.partnerFund_RecordType_IPA,string.valueof(IPACoMarketingAcc.id),NULL,NULL,'India','','Cloud',
                                                                                          'Intel® 11ᵗʰ Gen','Sales Incentive','Seller - Target SPIF','Draft',false); 
            IPApfr2.Core_MDF_Activity_Description__c = 'Test IPA Activity2';
            IPApfr2.Title = 'Test IPA Activity2';
            IPApfr2.Core_MDF_Approval_Stage__c='Program Office Reviewer';
            IPApfr2.Core_MDF_Start_Date__c = System.today().addDays(1);
            IPApfr2.Core_MDF_End_Date__c = System.today().addDays(2);
            IPApfr2.Core_MDF_Program_Office_Check_ind__c = true;
            IPApfr2.Core_MDF_Country_nm__c = 'India';
            IPApfr2.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfrs.add(IPApfr2);
            //Database.insert(IPApfr2);
         	Database.insert(pfrs);
            
            User usrg = Core_MDF_CCP_TestDataUtility.createUser(false);
            usrg.LastName = 'User Testg';
            usrg.UserRoleId = usRole1.Id;
            Database.insert(usrg);
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail];
            insert new PermissionSetAssignment(AssigneeId = usrg.id, PermissionSetId = ps1.Id);
            
            Test.stopTest(); 
        }
    }
    
    static Map<string,String> getPermissionSetIdbyName(Set<String> psNameSet){
        Map<string,String>  resultMap = new Map<string,String>();
        for(permissionSet ps: [SELECT Id , Name
                               FROM PermissionSet
                               WHERE Name IN:psNameSet]){
             resultMap.put(ps.Name, ps.Id);
            
        }
    	return resultMap;
    }
    
    
    @isTest
    static void loadPFRAccountManagerSubmit(){        
        
        User usr1 = [select id from user where lastname = 'Retail Account Reviewer Test' LIMIT 1];
        PartnerFundRequest pfr = [select id, RecordType.Name, Core_MDF_Fund_Request_Status__c,Core_MDF_Country_nm__c from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM;FRANCE' limit 1];
        Map<String,String> pfrInstanceMap = new Map<String,String>();
        Map<Id,Map<String,String>> pfrMapValues = new Map<Id,Map<String,String>>();
        List<Id> pfrsId = new List<Id>();
        pfrsId.add(pfr.Id);
        String res='';
        test.startTest();
        Boolean submitStatus=false;
        Core_MDF_PFR_Approval.userPermissionApproval perApproval=new  Core_MDF_PFR_Approval.userPermissionApproval();
        try{
            
            System.runAs(usr1){
                submitStatus = Core_MDF_PFR_Approval.submitForApproval(pfrsId,'Test');
                string approvalComments = 'Test';
                pfrInstanceMap.put('Test internal comments', 'Approve');
                pfrMapValues.put(pfr.Id, pfrInstanceMap);
                perApproval=Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id);
                //System.assert(perApproval!=null);
                Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments,true);
                pfrMapValues = new Map<Id,Map<String,String>>();
                pfrInstanceMap = new Map<String,String>();
                pfrInstanceMap.put('Test internal comments', 'Decline');
                pfrMapValues.put(pfr.Id, pfrInstanceMap);
                Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id);
                Core_MDF_PFR_Approval.loadPFRRecord(null);
                Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments,true);
                
            }
            
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('PFRIDs->') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
        Assert.areEqual(true, submitStatus);
        
    }
    
    @isTest
    static void handleException(){  
        User usr1 = [select id from user where lastname = 'Retail Account Reviewer Test' LIMIT 1];
        test.startTest();
        Core_MDF_PFR_Approval.userPermissionApproval res=new Core_MDF_PFR_Approval.userPermissionApproval();
        String errorMsg='';
        System.runAs(usr1){
            try{
                Core_MDF_PFR_Approval.loadPFRRecord(null);
                res=Core_MDF_PFR_Approval.loadPFRRecord('123');
            }
            catch(Exception ex){
                errorMsg=ex.getMessage();
            }
        }
        test.stopTest();
        Assert.areEqual(null, res);
    }
    
    @isTest
    static void loadPFRAccountManagerSubmitTest(){        
        
        User usr1 = [select id from user where lastname = 'Retail Account Reviewer Test' LIMIT 1];
        test.startTest();
        PartnerFundRequest pfr = [select id, RecordType.Name, Core_MDF_Fund_Request_Status__c,Core_MDF_Country_nm__c from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM;FRANCE' limit 1];
        pfr.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
        Boolean submitStatus=false;
        System.runAs(usr1){
            Database.update(pfr);
            Map<String,String> pfrInstanceMap = new Map<String,String>();
            Map<Id,Map<String,String>> pfrMapValues = new Map<Id,Map<String,String>>();
            List<Id> pfrsId = new List<Id>();
            pfrsId.add(pfr.Id);
            submitStatus = Core_MDF_PFR_Approval.submitForApproval(pfrsId,'Test');
            
            try{
                string approvalComments = 'Test';
                pfrInstanceMap.put('Test internal comments', 'Reject');
                pfrMapValues.put(pfr.Id, pfrInstanceMap);
                Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id);
            }
            catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('PFRIDs->') ? true : false;
                System.assertEquals(expectedExceptionThrown, false);
            }
        }
        Test.stopTest();
        Assert.areEqual(true, submitStatus);
        
    }
    
    @isTest
    static void recallAction(){ 
        User usr3 = [select id from user where lastname = 'Retail Account Manager' LIMIT 1];
        PartnerFundRequest pfr = [select id, RecordType.Name, Core_MDF_Fund_Request_Status__c,Core_MDF_Country_nm__c,OwnerId from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM;FRANCE' limit 1];
        PartnerFundRequest pfr1 = [select id, RecordType.Name, Core_MDF_Fund_Request_Status__c,Core_MDF_Price_reviewer_check_ind__c  from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'INDIA' limit 1];
       	Map<String,String> pfrInstanceMap = new Map<String,String>();
        Map<Id,Map<String,String>> pfrMapValues = new Map<Id,Map<String,String>>();
        List<Id> pfrsId = new List<Id>();
        pfrsId.add(pfr.Id);
        Boolean res=false;
        Core_MDF_PFR_Approval.userPermissionApproval perapproval=new Core_MDF_PFR_Approval.userPermissionApproval();
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(pfr.id);
        app.setSubmitterId(pfr.OwnerId);
        app.setProcessDefinitionNameOrId('Core_MDF_OPAL_Approval_Process_V9'); 
        app.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(app);
        Test.startTest();
        try{
            
            System.runAs(usr3){
             	string approvalComments = 'Test';
                pfrInstanceMap.put('Test internal comments', 'Approve');
                pfrMapValues.put(pfr.Id, pfrInstanceMap);
                perapproval=Core_MDF_PFR_Approval.loadPFRRecord(string.valueOf(pfr1.Id));
                Core_MDF_PFR_Approval.submitForApprovalClosed(pfrsId,'Test1');
                List<Id> pfrsId1 = new List<Id>();
                pfrsId1.add(pfr1.Id);
                res=Core_MDF_PFR_Approval.submitForApprovalClosed(pfrsId1,'Test1');   
                
            }
            
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('PFRIDs->') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
        Assert.areEqual(true, perApproval.isAccountMng);
    }
    
    @isTest
    static void loadPFRCCF(){        
        test.startTest();
        //External Approver 1
        User usr1 = [select id from user where lastname = 'CCF Account Manager' LIMIT 1]; 
		Core_MDF_PFR_Approval.userPermissionApproval perapproval=new Core_MDF_PFR_Approval.userPermissionApproval();
        PartnerFundRequest pfr = [select id, RecordType.Name, Core_MDF_Fund_Request_Status__c, Core_MDF_Approval_Stage__c, Core_MDF_Country_nm__c,Core_MDF_Budget_Type_nm__c from PartnerFundRequest where Title = 'Test Activity CCF2' limit 1];
        System.runAs(usr1){
           	perApproval=Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id); 
            
        }
    	test.stopTest();
        Assert.areEqual('Client', perapproval.pfrInstance.Core_MDF_Program__c);
    }

     @isTest
     static void loadPFRCCF2(){  
        User usr2 = [select id from user where lastname = 'External Approver 1' LIMIT 1]; 
        Core_MDF_PFR_Approval.userPermissionApproval perapproval=new Core_MDF_PFR_Approval.userPermissionApproval();
        test.startTest();
        PartnerFundRequest pfr = [select id, RecordType.Name, Core_MDF_Fund_Request_Status__c, Core_MDF_Approval_Stage__c, Core_MDF_Country_nm__c,Core_MDF_Budget_Type_nm__c from PartnerFundRequest where Title = 'Test Activity CCF2' limit 1];
        System.runAs(usr2){
            
            perApproval=Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id); 
        }
        test.stopTest();
        Assert.areEqual('Client', perapproval.pfrInstance.Core_MDF_Program__c);
    }
    
    @isTest
    static void loadPFRCCF3(){  
        User usr2 = [select id from user where lastname = 'PRICE REVIEWER' LIMIT 1]; 
        Core_MDF_PFR_Approval.userPermissionApproval perapproval=new Core_MDF_PFR_Approval.userPermissionApproval();
        test.startTest();
        PartnerFundRequest pfr = [select id, RecordType.Name, Core_MDF_Fund_Request_Status__c, Core_MDF_Approval_Stage__c, Core_MDF_Country_nm__c,Core_MDF_Budget_Type_nm__c from PartnerFundRequest where Title = 'Test Activity CCF2' limit 1];
		System.runAs(usr2){
            perapproval=Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id); 
        }
        test.stopTest();
        Assert.areEqual('Client', perapproval.pfrInstance.Core_MDF_Program__c);
    }
     
    @isTest    
    static void loadPFRAccountManagerReject(){
       	Map<Id,Map<String,String>> pfrMapValues = new Map<Id,Map<String,String>>();
        Map<Id,Map<String,String>> pfrMapValues1 = new Map<Id,Map<String,String>>();
        Map<String,String> pfrInstanceMap = new Map<String,String>();
        Map<String,String> pfrInstanceMap1 = new Map<String,String>();
        PartnerFundRequest PFR = new PartnerFundRequest();
        Boolean approvalStatus = false;
        string approvalComments = 'Test';
        String result='';
        Test.startTest();
        try{
            User usr1 = [select id from user where lastname = 'Retail Account Reviewer Test' limit 1];
            pfr = [select id,Core_MDF_Country_nm__c,Core_MDF_Program__c from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM;FRANCE' limit 1];
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
           	PartnerFundRequest pfr1 = [select id,Core_MDF_Country_nm__c from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'India' limit 1];
            
            System.runAs(usr1){
                Database.update(pfr);
                pfrInstanceMap.put('Test internal comments', 'Reject');
                pfrMapValues.put(pfr.Id, pfrInstanceMap);
                pfrInstanceMap1.put('Test internal comments', 'Recall');
                pfrMapValues1.put(pfr1.Id, pfrInstanceMap1);
                result=Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments,true);
                Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues1, approvalComments,true);
                
            }
            
            Core_MDF_PFR_Approval.populateApproverComments('Approve','','Test Approve');
            Core_MDF_PFR_Approval.populateApproverComments('Decline','Test','Test Approve');
            Core_MDF_PFR_Approval.populateApproverComments('Approve','Test','');
            
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage() == '' ? false : true;
            System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
        Assert.areEqual('true', result);
        
    }
    
    @isTest    
    static void loadPFRAccountManagerReject2(){
        Map<Id,Map<String,String>> pfrMapValues = new Map<Id,Map<String,String>>();
        Map<Id,Map<String,String>> pfrMapValues1 = new Map<Id,Map<String,String>>();
        Map<String,String> pfrInstanceMap = new Map<String,String>();
        Map<String,String> pfrInstanceMap1 = new Map<String,String>();
        PartnerFundRequest PFR = new PartnerFundRequest();
        Boolean approvalStatus = false;
        string approvalComments = 'Test';
        String result='';
        Test.startTest();
        try{
            User usr1 = [select id from user where lastname = 'Retail Account Reviewer Test' limit 1];
            PartnerFundRequest pfr1 = [select id,Core_MDF_Host_Region_or_Region_txt__c,Core_MDF_Country_nm__c from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'India' limit 1];
            pfr1.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
            System.runAs(usr1){
                Database.update(pfr1);
                pfrInstanceMap1.put('Test internal comments', 'Recall');
                pfrMapValues1.put(pfr1.Id, pfrInstanceMap1);
                result=Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues1, approvalComments,true);
                
            }
               
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage() == '' ? false : true;
            System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
        //Assert.areEqual('true', result);
     }
    
    @isTest    
    static void loadPFRAccountManagerReject3(){
        Map<Id,Map<String,String>> pfrMapValues = new Map<Id,Map<String,String>>();
        Map<Id,Map<String,String>> pfrMapValues1 = new Map<Id,Map<String,String>>();
        Map<String,String> pfrInstanceMap = new Map<String,String>();
        Map<String,String> pfrInstanceMap1 = new Map<String,String>();
        Boolean approvalStatus = false;
        string approvalComments = 'Test';
        String res='';
        Test.startTest();
        try{
            User usr1 = [select id from user where lastname = 'Retail Account Reviewer Test' limit 1];
            PartnerFundRequest pfr = [select id,Core_MDF_Country_nm__c from PartnerFundRequest where Title = 'Test IPA Activity2' limit 1];
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Core_MDF_Approval_Stage__c='L1 Approval';
            System.runAs(usr1){
                Database.update(pfr);
                pfrInstanceMap.put('Test internal comments', 'Approve');
                pfrMapValues.put(pfr.Id, pfrInstanceMap);
                res=Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments,true);
                
            }
              
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage() == '' ? false : true;
            System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
        //Assert.areEqual('true', res);
    }
	
	@isTest    
    static void loadPFRAccountManagerApprove2(){
        Map<Id,Map<String,String>> pfrMapValues = new Map<Id,Map<String,String>>();
        Map<Id,Map<String,String>> pfrMapValues1 = new Map<Id,Map<String,String>>();
        Map<String,String> pfrInstanceMap = new Map<String,String>();
        Map<String,String> pfrInstanceMap1 = new Map<String,String>();
        PartnerFundRequest PFR = new PartnerFundRequest();
        string approvalComments = 'Test';
        String res='';   
        Test.startTest();
        try{
            User usr1 = [select id from user where lastname = 'Retail Account Reviewer Test' limit 1];
            pfr = [select id,Core_MDF_Host_Region_or_Region_txt__c,Core_MDF_Country_nm__c,Core_MDF_Program__c from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM;FRANCE' limit 1];
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
            PartnerFundRequest pfr1 = [select id,Core_MDF_Host_Region_or_Region_txt__c,Core_MDF_Country_nm__c from PartnerFundRequest where Title = 'Test IPA Activity2' and Core_MDF_Country_nm__c = 'India' limit 1];
            
            System.runAs(usr1){
                Database.update(pfr);
                pfrInstanceMap.put('Test internal comments', 'Approve');
                pfrMapValues.put(pfr.Id, pfrInstanceMap);
                pfrInstanceMap1.put('Test internal comments', 'Approve');
                pfrMapValues1.put(pfr1.Id, pfrInstanceMap1);
                res=Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments,true);
                Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues1, approvalComments,true);
                Core_MDF_PFR_Approval.populateApproverComments('Approve','','Test Approve');
                Core_MDF_PFR_Approval.populateApproverComments('Decline','Test','Test Approve');
                Core_MDF_PFR_Approval.populateApproverComments('Approve','Test','');
                
            }
            
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage() == '' ? false : true;
            System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
        //Assert.areEqual('true', res);  
       
    }
        
    @isTest
    static void loadSubmitForApprovalClosed(){
        Test.startTest();
		User usr1 = [select Id from user where lastname = 'Retail After The Fact' LIMIT 1];
        PartnerFundRequest pfr = [select Id, RecordType.Name, RequestedAmount, Core_MDF_Fund_Request_Status__c ,Core_MDF_Country_nm__c
                                  from PartnerFundRequest 
                                  where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM;FRANCE' limit 1];
      	List<Id> pfrsId = new List<Id>();
        pfrsId.add(pfr.Id);
        Boolean submitStatus=false;
        System.runAs(usr1){
           	pfr.RequestedAmount = 10000; //100000
            update pfr;
            submitStatus = Core_MDF_PFR_Approval.submitForApprovalClosed(pfrsId,'Test1233');             
           	pfr.RequestedAmount = 100000; //10000
            update pfr;
            PartnerFundRequest pfr2 =[Select id,Title from PartnerFundRequest where Title='Test Retail Activity2'];
            List<Id>  pfrsId3=new List<Id>();
            pfrsId3.add(pfr2.Id);
            Core_MDF_PFR_Approval.submitForApprovalClosed(pfrsId3,'Test1234');
        }
        Test.stopTest(); 
        Assert.areEqual(true, submitStatus);
    }
    
    @isTest
    static void loadATFActivity(){
        User usr1 = [select Id from user where lastname = 'Retail After The Fact' LIMIT 1];
        Test.startTest();
        Core_MDF_PFR_Approval.userPermissionApproval perapproval=new Core_MDF_PFR_Approval.userPermissionApproval();
        PartnerFundRequest pfr = [select Id, RecordType.Name,Core_MDF_Approval_Step_Completed__c, Core_MDF_Activity_CreatedByExternalUsr__c,RequestedAmount, Core_MDF_Fund_Request_Status__c,Core_MDF_Country_nm__c 
                                  from PartnerFundRequest 
                                  where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM;FRANCE' limit 1];
        pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        pfr.Core_MDF_Approval_Stage__c ='Price Reviewer';
        pfr.Core_MDF_Approval_Step_Completed__c = 0;
        pfr.Core_MDF_Activity_CreatedByExternalUsr__c = true;
        System.runAs(usr1){ 
            Database.update(pfr);  
            perapproval=Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id);
            Core_MDF_PFR_Approval.isApproverAssigned(pfr.Id,usr1.Id,false);
            Core_MDF_PFR_Approval.isApproverActive(pfr.Id,usr1.Id);
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
            Database.update(pfr);
            Core_MDF_PFR_Approval.isApproverActive(pfr.Id,usr1.Id);
            pfr.Core_MDF_Fund_Request_Status__c = 'closed';
            Database.update(pfr);
            Core_MDF_PFR_Approval.isApproverActive(pfr.Id,usr1.Id);
         
        }   
        Test.stopTest();
        Assert.areEqual('Price Reviewer', perapproval.pfrInstance.Core_MDF_Approval_Stage__c);
    }
        
    @isTest
    static void loadATFActivity2(){
        User usr2 = [select Id,email from user where email = 'rmfpricerev@example.com' LIMIT 1];
        test.startTest();
        Core_MDF_PFR_Approval.userPermissionApproval perapproval=new Core_MDF_PFR_Approval.userPermissionApproval();
        PartnerFundRequest pfr = [select Id, RecordType.Name,Core_MDF_Approval_Step_Completed__c, Core_MDF_Activity_CreatedByExternalUsr__c,RequestedAmount, Core_MDF_Fund_Request_Status__c,Core_MDF_Country_nm__c 
                                  from PartnerFundRequest 
                                  where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM;FRANCE' limit 1];
        pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        pfr.Core_MDF_Approval_Step_Completed__c = 0;
        pfr.Core_MDF_Activity_CreatedByExternalUsr__c = true;
        System.runAs(usr2){ 
            Database.update(pfr);
            perapproval=Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id);
            Core_MDF_PFR_Approval.isApproverActive(pfr.Id,usr2.Id);
        }
        test.stopTest();
        Assert.areEqual('Pending Review', perapproval.pfrInstance.Core_MDF_Fund_Request_Status__c);
    }
    
   /* @isTest
    static void loadATFActivityIPA(){
        User usr2 = [select Id,email from user where email = 'IPAmanager@example.com' LIMIT 1];
        test.startTest();
        Core_MDF_PFR_Approval.userPermissionApproval perapproval=new Core_MDF_PFR_Approval.userPermissionApproval();
        PartnerFundRequest pfr = [select Id,Core_MDF_Host_Region_or_Region_txt__c, RecordType.Name,Core_MDF_Approval_Step_Completed__c, Core_MDF_Activity_CreatedByExternalUsr__c,RequestedAmount, Core_MDF_Fund_Request_Status__c,Core_MDF_Country_nm__c 
                                  from PartnerFundRequest 
                                  where Title = 'Test IPA Activity' limit 1];
        pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        pfr.Core_MDF_Approval_Stage__c ='L2 Regional Sales';
        System.runAs(usr2){ 
            Database.update(pfr);
            //perapproval=Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id);
            //Core_MDF_PFR_Approval.isApproverActive(pfr.Id,usr2.Id);
            
        }
        test.stopTest();
       //Assert.areEqual('L2 Regional Sales', perapproval.pfrInstance.Core_MDF_Approval_Stage__c);
        
    }*/
    
    @isTest
    static void loadGeoActivity(){
        User usr2 = [select Id,email from user where email = 'rmfaccntmngr@example.com' LIMIT 1];
        test.startTest();
        Core_MDF_PFR_Approval.userPermissionApproval perapproval=new Core_MDF_PFR_Approval.userPermissionApproval();
        PartnerFundRequest pfr = [select Id, RecordType.Name,Core_MDF_Approval_Step_Completed__c, Core_MDF_Activity_CreatedByExternalUsr__c,RequestedAmount, Core_MDF_Fund_Request_Status__c,Core_MDF_Country_nm__c 
                                  from PartnerFundRequest 
                                  where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM;FRANCE' limit 1];
        pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        pfr.Core_MDF_Approval_Stage__c ='Geo Lead Approval';
        pfr.Core_MDF_Approval_Step_Completed__c = 0;
        pfr.Core_MDF_Activity_CreatedByExternalUsr__c = true;
        System.runAs(usr2){ 
            Database.update(pfr); 
        	perapproval= Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id);
        }
        test.stopTest();
         Assert.areEqual('Geo Lead Approval', perapproval.pfrInstance.Core_MDF_Approval_Stage__c);
    }
        
    @isTest
    static void loadPORActivity(){
        User usr2 = [select Id,email from user where email = 'rmfaccntmngr@example.com' LIMIT 1];
        test.startTest();
        Core_MDF_PFR_Approval.userPermissionApproval perapproval=new Core_MDF_PFR_Approval.userPermissionApproval();
        PartnerFundRequest pfr = [select Id, RecordType.Name,Core_MDF_Approval_Step_Completed__c, Core_MDF_Activity_CreatedByExternalUsr__c,RequestedAmount, Core_MDF_Fund_Request_Status__c,Core_MDF_Country_nm__c 
                                  from PartnerFundRequest 
                                  where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM;FRANCE' limit 1];
        pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        pfr.Core_MDF_Approval_Stage__c ='Program Office Reviewer';
        pfr.Core_MDF_Approval_Step_Completed__c = 0;
        pfr.Core_MDF_Activity_CreatedByExternalUsr__c = true;
        System.runAs(usr2){ 
            Database.update(pfr); 
        	perapproval= Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id);
        }
        test.stopTest();
        Assert.areEqual('Program Office Reviewer', perapproval.pfrInstance.Core_MDF_Approval_Stage__c);
    }
    
    @isTest
    static void loadL1Activity(){
        User usr2 = [select Id,email from user where email = 'rmfaccntmngr@example.com' LIMIT 1];
        test.startTest();
        Core_MDF_PFR_Approval.userPermissionApproval perapproval=new Core_MDF_PFR_Approval.userPermissionApproval();
        PartnerFundRequest pfr = [select Id, RecordType.Name,Core_MDF_Approval_Step_Completed__c, Core_MDF_Activity_CreatedByExternalUsr__c,RequestedAmount, Core_MDF_Fund_Request_Status__c,Core_MDF_Country_nm__c 
                                  from PartnerFundRequest 
                                  where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM;FRANCE' limit 1];
        pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        pfr.Core_MDF_Approval_Stage__c ='L1 Approval';
        pfr.Core_MDF_Approval_Step_Completed__c = 0;
        pfr.Core_MDF_Activity_CreatedByExternalUsr__c = true;
        System.runAs(usr2){ 
            Database.update(pfr); 
        	 perapproval=Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id);
        }
        test.stopTest();
        Assert.areEqual('L1 Approval', perapproval.pfrInstance.Core_MDF_Approval_Stage__c);
    }
     
    @isTest
    static void activityForATFApproval(){
        User usr1 = [select Id from user where lastname = 'Retail After The Fact' LIMIT 1];
       	PartnerFundRequest pfr = [select Id, RecordType.Name, RequestedAmount, Core_MDF_Fund_Request_Status__c ,Core_MDF_Country_nm__c
                                  from PartnerFundRequest 
                                  where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM;FRANCE' limit 1];
        List<Id> pfrsId = new List<Id>();
        pfrsId.add(pfr.Id);
        Boolean submitStatus=false;
        Test.startTest();
        System.runAs(usr1){         
            pfr.RequestedAmount = 100000000;
            update pfr;
            submitStatus = Core_MDF_PFR_Approval.submitForApprovalClosed(pfrsId,'Test1233'); 
         }
        Test.stopTest();
        Assert.areEqual(true, submitStatus);
    }
    
    @isTest
    static void loadSubmitForApprovalClosedPCT(){
        User usr1 = [select Id from user where lastname = 'Retail After The Fact' LIMIT 1];
        PartnerFundRequest pfr = [select Id, RecordType.Name, RequestedAmount, Core_MDF_Fund_Request_Status__c ,Core_MDF_Price_reviewer_check_ind__c
                                  from PartnerFundRequest 
                                  where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM;FRANCE' limit 1];
        List<Id> pfrsId = new List<Id>();
        pfrsId.add(pfr.Id);
        Boolean submitStatus=false;
        Test.startTest();
        System.runAs(usr1){
            pfr.RequestedAmount = 100000;
            pfr.Core_MDF_Price_reviewer_check_ind__c = false;
            update pfr;
            pfrsId.add(pfr.Id);
            submitStatus = Core_MDF_PFR_Approval.submitForApprovalClosed(pfrsId,'Test1233');             
            pfr.Core_MDF_Price_reviewer_check_ind__c = true;
            update pfr;
        }
        Test.stopTest();
        Assert.areEqual(true, submitStatus);
    }
    
    @isTest
    static void loadSubmitForApprovalClosedPCT12(){
        User usr3 = [select id,email from user where email = 'rmfaccntmngr@example.com' LIMIT 1];
        PartnerFundRequest pfr12=[Select id,title from PartnerFundRequest where title='Test Retail Activity12'];
        test.startTest();
        Boolean submitStatus=false;
        System.runAs(usr3){
           List<Id> pfrID12= new List<Id>();
            pfrID12.add(pfr12.Id);
            submitStatus= Core_MDF_PFR_Approval.submitForApprovalClosed(pfrID12,'test1234567');
        }
        test.stopTest();
        Assert.areEqual(true, submitStatus);
    }
    
    @isTest
    static void recallActionTest(){        
        User usr3 = [select id,email from user where email = 'rmfaccntmngr@example.com' LIMIT 1];
        PartnerFundRequest pfr = [select id, RecordType.Name, Core_MDF_Fund_Request_Status__c,Core_MDF_Country_nm__c from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM;FRANCE' limit 1];
        Map<String,String> pfrInstanceMap = new Map<String,String>();
        Map<Id,Map<String,String>> pfrMapValues = new Map<Id,Map<String,String>>();
        List<Id> pfrsId = new List<Id>();
        pfrsId.add(pfr.Id);
        String approvalComments = 'Test';
        pfrInstanceMap.put('Test internal comments', 'Approve');
        pfrMapValues.put(pfr.Id, pfrInstanceMap);
        pfr.RequestedAmount = 30000;
        pfr.Core_MDF_Region_nm__c = 'EMEA';
        test.startTest();
        Boolean res=false;
        System.runAs(usr3){
            update pfr;
            List<Id> pfrsId1 = new List<Id>();
            pfrsId1.add(pfr.Id);
            List<Id> pfrsIdList = new List<Id>();
            pfrsIdList.add(pfr.Id);
            /*pfrsIdList.add((Id)'0RJ3b000000CrEKGA0');*/
            res=Core_MDF_PFR_Approval.submitForApproval(pfrsIdList, 'CHECK 1');
            try{
                Core_MDF_PFR_Approval.submitForApproval(null,' ');
            }
            catch(exception e){
                system.assert(e != null);
            }
        }
        Test.stopTest();
        Assert.areEqual(true, res);
    }
       
   /* @isTest
    static void recallActionTest2(){        
      	User usr3 = [select id,email from user where email = 'rmfaccntmngr@example.com' LIMIT 1];
        PartnerFundRequest IPApfr = [select id, RecordType.Name,Core_MDF_Program__c,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Approval_Stage__c, Core_MDF_Fund_Request_Status__c  from PartnerFundRequest where Title = 'Test IPA Activity' and Core_MDF_Country_nm__c = 'India' limit 1];
        string approvalComments = 'Test';
        Map<String,String> pfrInstanceMap = new Map<String,String>();
        Map<Id,Map<String,String>> pfrMapValues = new Map<Id,Map<String,String>>();
        pfrInstanceMap.put('Test IPA internal comments', 'Approve');
        pfrMapValues.put(IPApfr.Id, pfrInstanceMap);
        test.startTest();
        String res='';
        System.runAs(usr3){
        	res=Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments,true);
        }
        test.stopTest();
        //Assert.areEqual('true', res);
    }*/
    
   
    @isTest
    static void loadPFRAccountManagerApprove(){
        test.startTest();
        Map<Id,Map<String,String>> pfrMapValues = new Map<Id,Map<String,String>>();
        Map<String,String> pfrInstanceMap = new Map<String,String>();
        PartnerFundRequest PFR = new PartnerFundRequest();
        Core_MDF_PFR_Approval.userPermissionApproval perApproval=new  Core_MDF_PFR_Approval.userPermissionApproval();
        Boolean approvalStatus = false;
        string approvalComments = 'Test';
        String result='';
        try{
           
            pfr = [select id, Core_MDF_Fund_Request_Status__c, RecordType.Name,Core_MDF_Country_nm__c from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM;FRANCE' limit 1];
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Approval';  
            List<Id> pfrIdLst = new List<Id>();
            pfrIdLst.add(pfr.Id);
            pfrInstanceMap.put('Test internal comments', 'Approve');
            pfrMapValues.put(pfr.Id, pfrInstanceMap);
            result=Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments,true);
            User usr2 = [select id from User where LastName = 'External Approver 1' LIMIT 1];
           	List<Id> pfrsId = new List<Id>();
            pfrMapValues = new Map<Id,Map<String,String>>();
           	pfr = [select id,Core_MDF_Fund_Request_Status__c,Core_MDF_Country_nm__c from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM;FRANCE' limit 1];
            
            System.runAs(usr2){
                Database.update(pfr);
                pfrInstanceMap = new Map<String,String>();
                pfrInstanceMap.put('Test external comments', 'Approve');
                pfrMapValues.put(pfr.Id, pfrInstanceMap);
                perApproval=Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id);
                pfrsId.add(pfr.id);
                Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments,true);
                               
            }
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage() == '' ? false : true;
        }
       	Test.stopTest();
        Assert.areNotEqual(null, perApproval);
    }
 
    @isTest
    static void isApproverActiveTestL2(){
        User usr1 = [select Id from user where lastname = 'Retail After The Fact' LIMIT 1];
        
        PartnerFundRequest pfr = [select Id,Core_MDF_Approval_Step_Completed__c,Core_MDF_Activity_CreatedByExternalUsr__c,Core_MDF_Fund_Request_Status__c,recordType.DeveloperName,Core_MDF_Approval_Stage__c,Core_MDF_Program__c,Core_MDF_Country_nm__c,ChannelPartnerId,Core_MDF_Budget_Type_nm__c,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest
                                  where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM;FRANCE' limit 1];
        
        pfr.Core_MDF_Approval_Stage__c = 'L2 Approval';
        test.startTest();
        Boolean res=false;
        System.runAs(usr1){
            Database.update(pfr);
            res=Core_MDF_PFR_Approval.isApproverActive(pfr.id,usr1.id);
            pfr.Core_MDF_Approval_Stage__c = 'L1 Approval';
            Database.update(pfr);
            Core_MDF_PFR_Approval.isApproverActive(pfr.id,usr1.id);
            pfr.Core_MDF_Approval_Stage__c = 'Price Reviewer';
            Database.update(pfr);
            Core_MDF_PFR_Approval.isApproverActive(pfr.id,usr1.id);
            pfr.Core_MDF_Approval_Stage__c='Program Office Reviewer';
            Database.update(pfr);
            Core_MDF_PFR_Approval.isApproverActive(pfr.id,usr1.id);
            try{
                Core_MDF_PFR_Approval.isApproverActive(null,null);
            }catch(Exception e){
                system.assert(e!=null);
            }
        } 
        test.stopTest();
        Assert.areEqual(true, res);
    }
    @isTest
    static void loadEEFPFRAccountManagerSubmitTest(){
        User usr1 = [select Id from user where lastname = 'User Test' LIMIT 1];
        User eefPP = [select Id from user where lastname = 'Test EEF Primary Account Manager' LIMIT 1];
        Core_MDF_PFR_Approval.userPermissionApproval perApproval = new  Core_MDF_PFR_Approval.userPermissionApproval();
        PartnerFundRequest pfr = [select Id, Core_MDF_Approval_Step_Completed__c, Core_MDF_Activity_CreatedByExternalUsr__c, Core_MDF_Fund_Request_Status__c, recordType.DeveloperName,Core_MDF_Approval_Stage__c,Core_MDF_Program__c,Core_MDF_Country_nm__c,ChannelPartnerId,Core_MDF_Budget_Type_nm__c,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest
                                  where Title = 'Test EEF Activity' limit 1];
        pfr.Core_MDF_Approval_Stage__c = 'L1 Approval (Primary Partner)';
        Database.update(pfr);
        test.startTest();
        //Boolean res = false;
        System.runAs(usr1){
            perApproval = Core_MDF_PFR_Approval.loadPFRRecord(pfr.id);
        } 
        test.stopTest();
    }
}