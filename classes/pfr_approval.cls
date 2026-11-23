/****************************************************************************************************************************************
* Class Name        : Core_MDF_PFR_Approval_Test
* Created Date      : 11/26/2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - HA       11/26/2019         Test Class for Core_MDF_PFR_Approval
*****************************************************************************************************************************************/

@isTest(SeeAllData=false)
public class pfr_approval {
    
    @TestSetUp
    static void createData(){
        
       
        
        UserRole usRole1 = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole1.Id;
        Database.insert(usr);

        List<Core_MDF_Partner_Group_Mapping__c> ccfpgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
        
        System.runAs(usr){
            
        /**List<String> bypassFunctionKeys = new List<String>();
		bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
		bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            
            

		Set<String> myset1 = new Set<String>();
		List<String> result1 = new List<String>();
		myset1.addAll(bypassFunctionKeys);
		result1.addAll(myset1);



		Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);**/
            
            //Create CCF Channel Program
            ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            
            //Creating Client Co-Marketing Fund program using Data Utility
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        
            
            // Creating Intel Account for retail program
            Account acc1Retail = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Retail', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                                  false);
            acc1Retail.Core_Account_Type__c = 'Reseller';
            //acc1Retail.Core_Sales_Groups__c = 'Automotive Sales Group';
            acc1Retail.Industry = 'Food & Beverage';
            acc1Retail.Core_MDF_Channel_Program__c = cpRetail.Id;
            acc1Retail.Core_Geo__c = 'EMEA';
            acc1Retail.Core_Sub_Geo__c = 'WEUR';
            Database.insert(acc1Retail);
            
            // Creating Retail Account with utility class
            Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cpRetail.Id,
                                                                            Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accRetail.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
            accRetail.Core_Geo__c = 'EMEA';
            accRetail.Core_Sub_Geo__c = 'WEUR';
            Database.insert(accRetail);
            
            // Creating Co-marketing Account with utility class
            Account accCoMarketing = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account CCP', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
            accCoMarketing.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
            accCoMarketing.Core_MDF_CoMarketing_Ultimate_Account__c = acc1Retail.Id;
            Database.insert(accCoMarketing);
            
            PermissionSet accountManager = [select id from PermissionSet where name='Core_MDF_CCP_Internal_Retail_Account_Manager'];
            PermissionSet accountReviewer = [select id from PermissionSet where name=:Label.Core_MDF_Retail_Reviewer_Permission_Set];
            PermissionSet afterTheFactApprover = [select id from PermissionSet where name=:'Core_MDF_CCP_Internal_After_The_Fact'];
            PermissionSet fieldOwnerPS = [select id from PermissionSet where name=:'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr'];//Core_MDF_CCP_Internal_CCF_Field_Owner
            PermissionSet marktngOwnerPS = [select id from PermissionSet where name=:'Core_MDF_CCP_Internal_CCF_Acct_Mgr'];//Core_MDF_CCP_Internal_CCF_Marketing_Owner
             //PermissionSet BudgetLoaderPS = [select id from PermissionSet where name=:'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader'];
            //PermissionSet extrnlActSubmtr = [select id from PermissionSet where name=:'Core_MDF_CCP_External_Activity_Submitter'];
             PermissionSet priceReviewer = [select id from PermissionSet where name=:'Core_MDF_CCP_Internal_Price_Reviewer'];
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
            
            
            //Creating User who is an Account Manager
            User usrAM = Core_MDF_CCP_TestDataUtility.createUser(false);
            usrAM.LastName = 'Retail Account Manager';
            userList.add(usrAM);
            
            //Creating User who is an CCF Account Manager
            User usrCCFAM = Core_MDF_CCP_TestDataUtility.createUser(false);
            usrCCFAM.LastName = 'CCF Account Manager';
            userList.add(usrCCFAM);
            Database.insert(userList);
            
            
            PermissionSetAssignment psAR = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usrRW.id,accountReviewer.id,false);
            PermissionSetAssignment psAM = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usrAM.id,accountManager.id,false);
            PermissionSetAssignment psAFA = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(userAF.id,afterTheFactApprover.id,false);
           
            PermissionSetAssignment psFO = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usrCCFAM.id,fieldOwnerPS.id,false);
            PermissionSetAssignment psMO = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usrCCFAM.id,marktngOwnerPS.id,false);
           // PermissionSetAssignment psbl = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usrCCFAM.id,BudgetLoaderPS.id,false);
            //PermissionSetAssignment psExtrnlAc = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usrCCFAM.id,extrnlActSubmtr.id,false);
             PermissionSetAssignment psPR = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(userPR.id,priceReviewer.id,false);
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            psaList.add(psAR);
            psaList.add(psAM);
            psaList.add(psAFA);
            psaList.add(psFO);
            psaList.add(psMO);
            psaList.add(psPR);
            //psaList.add(psbl);
            //psaList.add(psExtrnlAc);
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
           // Core_MDF_Partner_Node_User_Mapping__c pnumap = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(accRetail.Id, usr2.Id, true);
            
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
            ccfPgm3.Core_MDF_Group_Name__c = 'Core_CCP_Retail_Internal_EMEA';
            ccfPgm3.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm3.Core_MDF_Group_Id__c = ccfgrp3.Id;
            ccfPgm3.Core_MDF_Channel_Program__c = cpRetail.Id;
            ccfPgm3.Core_MDF_Region_cd__c = 'EMEA';
            ccfPgm3.Core_MDF_Source_Txt__c = 'test';
            ccfPgm3.Core_MDF_AccountIdGroupName__c = acc1Retail.Id+'Core_CCP_Retail_Internal_EMEA';
            //Database.insert(ccfPgm3);
			List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);            
            PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                           accRetail.id, cpRetail.Id , 10000 , System.today()-60 , System.today() + 30 , 
                                                                                  false);
           /*  PartnerMarketingBudget testBudget2 = Core_MDF_CCP_TestDataUtility.createBudget('TestCCFBudgetData',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                           accCoMarketing.id,cp.Id , 100000000 , System.today()-60 , System.today() + 30 , 
                                                                                           false);
            testBudget2.Core_MDF_Budget_Status__c = 'Released';
            testBudget2.Core_MDF_Budget_Type__c='MDF';
              testBudget2.Core_MDF_Budget_Type_Txt__c='MDF';
           Database.insert(testBudget2);
                                         
           PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestBudget2', testBudget2, accCoMarketing, 9999999, false);
            Database.insert(pfaRecord);*/
                             
            testBudget1.IsIgnoreValidation = true;
            // testBudget1.RecordTypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            insert testBudget1;
            testBudget1.Core_MDF_Budget_Status__c = 'Released';
            update testBudget1;
       
            List<Campaign> campLst = new List<Campaign>();
            
            Campaign camp2 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena','Yes', 
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today().addDays(16) , 
                                                                         System.today().addYears(1), 2000, 'Instore innovation', accRetail.Id,'2-in-1', false);
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today()-15, System.today()+15, 10000, 'Consumer Chromebook', accCoMarketing.Id, '2-in-1', false);
        
            campLst.add(camp2);
            campLst.add(camp);
            Database.insert(campLst);
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
                                                                                                              Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accRetail.id),NULL,NULL,'UNITED KINGDOM','Enthusiast Gaming','Traditional Notebook',
                                                                                                              'Intel® 11ᵗʰ Gen','Sales Incentive','Seller - Target SPIF','Draft',false); 
            //PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp2.Id),
            //                                                                                Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accRetail.id),NULL,NULL,'UNITED KINGDOM','Gaming','2-in-1',
            //                                                                                '10ᵗʰ Gen','Broadcast','Podcast','Draft',false);
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr.Core_MDF_Start_Date__c = System.today().addDays(17);
            pfr.Core_MDF_End_Date__c = System.today().addDays(18);
            pfr.RequestedAmount = 15;
            pfr.Core_MDF_Country_nm__c = 'UNITED KINGDOM';
            //pfr.Core_MDF_Region_Cd__c = 'EMEA';
            pfr.Core_MDF_Region_nm__c = 'EMEA';
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Core_MDF_Approval_Step_Completed__c = 0;
            pfr.Core_MDF_Approver_1__c = usrAM.Id;
            pfr.Core_MDF_Approver_2__c = usrAM.Id;
            pfr.Core_MDF_Approver_3__c = usrAM.Id;
            pfr.Core_MDF_Approver_4__c = usrAM.Id;
            pfr.Core_MDF_Approver_5__c = usrAM.Id;
            pfr.Core_MDF_Approver_6__c = usrAM.Id;
            pfr.Core_MDF_Approver_7__c = usrAM.Id;
            pfr.Core_MDF_Approver_8__c = usrAM.Id;
            pfr.Core_MDF_Approver_9__c = usrAM.Id;
            pfr.Core_MDF_Approver_10__c = usrAM.Id;
           // pfr.Core_MDF_ATF_Approval_Reqd_ind__c=false;
            pfr.Core_MDF_Price_reviewer_check_ind__c = true;
            pfrs.add(pfr);
            
            //Retail SPIF
            PartnerFundRequest pfrspif = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp2.Id),
                                                                                                              Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accRetail.id),NULL,NULL,'India','Enthusiast Gaming','Traditional Notebook',
                                                                                                              'Intel® 11ᵗʰ Gen','Sales Readiness','In-Store Promotion','Draft',false); 
            //PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp2.Id),
            //                                                                                Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accRetail.id),NULL,NULL,'UNITED KINGDOM','Gaming','2-in-1',
            //                                                                                '10ᵗʰ Gen','Broadcast','Podcast','Draft',false);
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
            pfrspif.Core_MDF_Approver_1__c = usrAM.Id;
            pfrspif.Core_MDF_Approver_2__c = usrAM.Id;
            pfrspif.Core_MDF_Approver_3__c = usrAM.Id;
            pfrspif.Core_MDF_Approver_4__c = usrAM.Id;
            pfrspif.Core_MDF_Approver_5__c = usrAM.Id;
            pfrspif.Core_MDF_Approver_6__c = usrAM.Id;
            pfrspif.Core_MDF_Approver_7__c = usrAM.Id;
            pfrspif.Core_MDF_Approver_8__c = usrAM.Id;
            pfrspif.Core_MDF_Approver_9__c = usrAM.Id;
            pfrspif.Core_MDF_Approver_10__c = usrAM.Id;
            //pfrspif.Core_MDF_Price_reviewer_check_ind__c = true;
            pfrs.add(pfrspif);
           
           // Account accCoMarketing = [select id from Account WHERE Name = 'Test Account 2'];
            PartnerFundRequest pfrCCF = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(camp.id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event','Channel Partner Owned Event','Draft',false);
            pfrCCF.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfrCCF.Title = 'Test Activity CCF';
            pfrCCF.Core_MDF_Activity_Description__c = 'Test Activity CCF';
            pfrCCF.Core_MDF_Channel_Partner_Led__c = True;
            pfrCCF.Core_MDF_Budget_Amount_Local_amt__c=100000000;
            pfrCCF.Core_MDF_Budget_Currency_cd__c='USD';
             //pfrCCF.Core_MDF_Budget_Type_nm__c='MDF';
             pfrCCF.Core_MDF_Start_Date__c= System.today()-15;
             pfrCCF.Core_MDF_End_Date__c = System.today()-15;
            pfrs.add(pfrCCF);
            
            Database.insert(pfrs);
            List<Approval.ProcessSubmitRequest> appLst = new List<Approval.ProcessSubmitRequest>();
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(pfr.id);
            appLst.add(app);
           // List<Approval.ProcessResult> result = Approval.process(appLst);
            

            
            //UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
            //Creating User with utility class 
            User usrg = Core_MDF_CCP_TestDataUtility.createUser(false);
            usrg.LastName = 'User Testg';
            usrg.UserRoleId = usRole1.Id;
            Database.insert(usrg);
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail];
            insert new PermissionSetAssignment(AssigneeId = usrg.id, PermissionSetId = ps1.Id);
            
            Test.stopTest(); 
        }
    }
    @isTest
    static void loadPFRAccountManagerSubmit(){        
    test.startTest();
        User usr1 = [select id from user where lastname = 'Retail Account Reviewer Test' LIMIT 1];
        PartnerFundRequest pfr = [select id, RecordType.Name, Core_MDF_Fund_Request_Status__c,Core_MDF_Country_nm__c from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM' limit 1];
        System.debug('pfr.Core_MDF_Fund_Request_Status__c '+pfr.Core_MDF_Fund_Request_Status__c);
        System.debug('pfr.RecordType.Name '+pfr.RecordType.Name);
        Map<String,String> pfrInstanceMap = new Map<String,String>();
        Map<Id,Map<String,String>> pfrMapValues = new Map<Id,Map<String,String>>();
        List<Id> pfrsId = new List<Id>();
        pfrsId.add(pfr.Id);
        
       
        Boolean submitStatus = Core_MDF_PFR_Approval.submitForApproval(pfrsId,'Test');
        try{

            System.runAs(usr1){
                
                string approvalComments = 'Test';
                pfrInstanceMap.put('Test internal comments', 'Approve');
                pfrMapValues.put(pfr.Id, pfrInstanceMap);
                
                
                
                Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id);
                
                /*ProcessInstanceWorkItem piwitmtst = [SELECT ProcessInstance.TargetObjectId, Id,ActorId, ProcessInstance.status FROM ProcessInstanceWorkItem 
                                            WHERE ProcessInstance.TargetObjectId IN:pfrsId];
                system.debug('piwitmtstsubmit status->' + piwitmtst.ProcessInstance.status);*/
                
               // Boolean approvalStatus = Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments);
                Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments,true);
                Test.stopTest();
                // Validate the pending approval
                pfrMapValues = new Map<Id,Map<String,String>>();
                pfrInstanceMap = new Map<String,String>();
                pfrInstanceMap.put('Test internal comments', 'Decline');
                pfrMapValues.put(pfr.Id, pfrInstanceMap);
                
                Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id);
               // Boolean extApprovalStatus = Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments);
                Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments,true);
              //  System.assertEquals(submitStatus, false);
            }
        
       }
        catch(Exception ex){
            System.debug('##Approval Test Exception->' + ex.getMessage());
            Boolean expectedExceptionThrown =  ex.getMessage().contains('PFRIDs->') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
       }
               
    }
    @isTest
    static void recallAction(){        
    
        User usr3 = [select id from user where lastname = 'Retail Account Manager' LIMIT 1];
        
        PartnerFundRequest pfr = [select id, RecordType.Name, Core_MDF_Fund_Request_Status__c,Core_MDF_Country_nm__c from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM' limit 1];
          
         PartnerFundRequest pfr1 = [select id, RecordType.Name, Core_MDF_Fund_Request_Status__c,Core_MDF_Price_reviewer_check_ind__c  from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'INDIA' limit 1];
     //   pfr.Core_MDF_Approval_Status_Stage_txt__c = 'Geo Marketing Lead';
        Map<String,String> pfrInstanceMap = new Map<String,String>();
        Map<Id,Map<String,String>> pfrMapValues = new Map<Id,Map<String,String>>();
        List<Id> pfrsId = new List<Id>();
        pfrsId.add(pfr.Id);
   
        try{

            System.runAs(usr3){
                
                string approvalComments = 'Test';
                pfrInstanceMap.put('Test internal comments', 'Approve');
                pfrMapValues.put(pfr.Id, pfrInstanceMap);
                 Test.startTest();
               // Boolean recallStatus = Core_MDF_PFR_Approval.checkRecallAction(pfrMapValues, approvalComments);
                
                Core_MDF_PFR_Approval.loadPFRRecord(string.valueOf(pfr1.Id));
                Core_MDF_PFR_Approval.submitForApprovalClosed(pfrsId,'Test1');
                Test.stopTest();
                  List<Id> pfrsId1 = new List<Id>();
                System.debug('pfr1.Core_MDF_Price_reviewer_check_ind__c '+' '+pfr1.Core_MDF_Price_reviewer_check_ind__c );
                pfrsId1.add(pfr1.Id);
                Core_MDF_PFR_Approval.submitForApprovalClosed(pfrsId1,'Test1');   
            }
           
        
       }
        catch(Exception ex){
            System.debug('##Approval Test Exception->' + ex.getMessage());
            Boolean expectedExceptionThrown =  ex.getMessage().contains('PFRIDs->') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
       }
               
    }
    
    
    
    
    @isTest
    static void loadPFRAccountManagerApprove(){
    test.startTest();
        Map<Id,Map<String,String>> pfrMapValues = new Map<Id,Map<String,String>>();
        Map<String,String> pfrInstanceMap = new Map<String,String>();
        PartnerFundRequest PFR = new PartnerFundRequest();
        Boolean approvalStatus = false;
        string approvalComments = 'Test';
        
        try{
            User usr1 = [select id from user where lastname = 'Retail Account Reviewer Test' limit 1];
            pfr = [select id, Core_MDF_Fund_Request_Status__c, RecordType.Name,Core_MDF_Country_nm__c from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM' limit 1];
            System.debug('pfr.Core_MDF_Fund_Request_Status__c '+pfr.Core_MDF_Fund_Request_Status__c);
            System.debug('pfr.RecordType.Name '+pfr.RecordType.Name);
            List<Id> pfrIdLst = new List<Id>();
            pfrIdLst.add(pfr.Id);
            //Boolean submitStatus = Core_MDF_PFR_Approval.submitForApproval(pfrIdLst);
            
            System.runAs(usr1){
                    
                pfrInstanceMap.put('Test internal comments', 'Approve');
                pfrMapValues.put(pfr.Id, pfrInstanceMap);
                
               // approvalStatus = Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments);
                Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments,true);
            }
            Test.stopTest();

            //System.assertEquals(approvalStatus, true);

            User usr2 = [select id from User where LastName = 'External Approver 1' LIMIT 1];

            List<Id> pfrsId = new List<Id>();
            pfrMapValues = new Map<Id,Map<String,String>>();

            pfr = [select id,Core_MDF_Fund_Request_Status__c,Core_MDF_Country_nm__c from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM' limit 1];
            System.debug('##pfr status external approve->' + pfr.core_mdf_fund_request_status__c);
            
            System.runAs(usr2){
                
                pfrInstanceMap = new Map<String,String>();
                pfrInstanceMap.put('Test external comments', 'Approve');
                
                pfrMapValues.put(pfr.Id, pfrInstanceMap);
                
                Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id);
                pfrsId.add(pfr.id);
                Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments,true);
               
                
            }
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage() == '' ? false : true;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }
    
    @isTest
      static void loadPFRCCF(){        
        test.startTest();
        //External Approver 1
        User usr1 = [select id from user where lastname = 'CCF Account Manager' LIMIT 1]; 
        User usr2 = [select id from user where lastname = 'External Approver 1' LIMIT 1]; 
         User usr3 = [select id from user where lastname = 'PRICE REVIEWER' LIMIT 1]; 
        PartnerFundRequest pfr = [select id, RecordType.Name, Core_MDF_Fund_Request_Status__c, Core_MDF_Approval_Stage__c, Core_MDF_Country_nm__c,Core_MDF_Budget_Type_nm__c from PartnerFundRequest where Title = 'Test Activity CCF' limit 1];
        pfr.Core_MDF_Approval_Stage__c = 'Price Reviewer';
        update pfr;
        System.runAs(usr1){
            Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id);     
        }
        System.runAs(usr2){
            Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id);     
        }
         System.runAs(usr3){
            Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id); 
           
             
        }
          
        test.stopTest();
    }
    @isTest    
    static void loadPFRAccountManagerReject(){
        
        Map<Id,Map<String,String>> pfrMapValues = new Map<Id,Map<String,String>>();
        Map<String,String> pfrInstanceMap = new Map<String,String>();
        PartnerFundRequest PFR = new PartnerFundRequest();
        Boolean approvalStatus = false;
        string approvalComments = 'Test';
        Test.startTest();
        try{
            User usr1 = [select id from user where lastname = 'Retail Account Reviewer Test' limit 1];
            pfr = [select id,Core_MDF_Country_nm__c from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM' limit 1];
            
            
            System.runAs(usr1){
                
                pfrInstanceMap.put('Test internal comments', 'Reject');
                    pfrMapValues.put(pfr.Id, pfrInstanceMap);
                    
                   // approvalStatus = Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments);
                    Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments,true);
                 
            }
            Core_MDF_PFR_Approval.populateApproverComments('Approve','','Test Approve');
            Core_MDF_PFR_Approval.populateApproverComments('Decline','Test','Test Approve');
            Core_MDF_PFR_Approval.populateApproverComments('Approve','Test','');
            //System.assertEquals(approvalStatus, true);
            
         }
         catch(Exception ex){
             Boolean expectedExceptionThrown =  ex.getMessage() == '' ? false : true;
             System.assertEquals(expectedExceptionThrown, true);
         }
        Test.stopTest();
    }
    
    @isTest
    static void loadSubmitForApprovalClosed(){
        Test.startTest();
        
        User usr1 = [select Id from user where lastname = 'Retail After The Fact' LIMIT 1];
        
        PartnerFundRequest pfr = [select Id, RecordType.Name, RequestedAmount, Core_MDF_Fund_Request_Status__c ,Core_MDF_Country_nm__c
                                  from PartnerFundRequest 
                                  where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM' limit 1];
        
    
        List<Id> pfrsId = new List<Id>();
        pfrsId.add(pfr.Id);
        
        System.runAs(usr1){
            //Boolean submitStatus = Core_MDF_PFR_Approval.submitForApprovalClosed(pfrsId,'Test123');
            
            pfr.RequestedAmount = 10000; //100000
            update pfr;
            Boolean submitStatus = Core_MDF_PFR_Approval.submitForApprovalClosed(pfrsId,'Test1233');             
            System.assertEquals(submitStatus, true);
            
            pfr.RequestedAmount = 100000; //10000
            update pfr;
            //MBoolean submitStatus1 = Core_MDF_PFR_Approval.submitForApprovalClosed(pfrsId,'Test1233');
Campaign camp2=[select Id from campaign where name='TestRetailCamp'];
            Account accRetail=[select Id from account where name='Co-marketing Test Account Retail'];
              PartnerFundRequest pfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp2.Id), Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accRetail.id),NULL,NULL,'UNITED KINGDOM','Enthusiast Gaming','Traditional Notebook',
                                                                                                            'Intel® 11ᵗʰ Gen','Sales Incentive','Seller - Per Unit SPIF','Draft',false); 
            pfr2.Title = 'Test Retail Activity2';
            pfr2.Core_MDF_Activity_Description__c = 'Test Retail Activity2';
            pfr2.Core_MDF_Start_Date__c = System.today().addDays(17);
            pfr2.Core_MDF_End_Date__c = System.today().addDays(18);
            pfr2.RequestedAmount = 25004;
            pfr2.Core_MDF_Country_nm__c = 'UNITED KINGDOM';
            //pfr2.Core_MDF_Region_Cd__c = 'EMEA';
            pfr2.Core_MDF_Region_nm__c = 'EMEA';
            pfr2.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr2.Core_MDF_Approval_Step_Completed__c = 0;
           pfr2.Core_MDF_Price_reviewer_check_ind__c = true;
            List<Id>  pfrsId3=new List<Id>();
            pfrsId3.add(pfr2.Id);
            System.debug('pfr2.Core_MDF_Price_reviewer_check_ind__c '+' '+pfr2.Core_MDF_Price_reviewer_check_ind__c );
          Core_MDF_PFR_Approval.submitForApprovalClosed(pfrsId3,'Test1234');
          
            Test.stopTest(); 
            
        }
    }

    @isTest
    static void loadATFActivity(){
        //Test.startTest();
        
        User usr1 = [select Id from user where lastname = 'Retail After The Fact' LIMIT 1];
         User usr2 = [select Id from user where lastname = 'PRICE REVIEWER' LIMIT 1];
            User usr3 = [select Id from user where lastname = 'Retail Account Manager' LIMIT 1];
        
        PartnerFundRequest pfr = [select Id, RecordType.Name,Core_MDF_Approval_Step_Completed__c, Core_MDF_Activity_CreatedByExternalUsr__c,RequestedAmount, Core_MDF_Fund_Request_Status__c,Core_MDF_Country_nm__c 
                                  from PartnerFundRequest 
                                  where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM' limit 1];
        pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        pfr.Core_MDF_Approval_Stage__c ='Price Reviewer';
        pfr.Core_MDF_Approval_Step_Completed__c = 0;
        pfr.Core_MDF_Activity_CreatedByExternalUsr__c = true;
        Database.update(pfr);
        System.assert(pfr != NULL); 
        System.runAs(usr1){  
            Test.startTest();
            Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id);
            Core_MDF_PFR_Approval.isApproverAssigned(pfr.Id,usr1.Id,false);
            Core_MDF_PFR_Approval.isApproverActive(pfr.Id,usr1.Id);
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
            Database.update(pfr);
            Core_MDF_PFR_Approval.isApproverActive(pfr.Id,usr1.Id);
            pfr.Core_MDF_Fund_Request_Status__c = 'closed';
            Database.update(pfr);
            Core_MDF_PFR_Approval.isApproverActive(pfr.Id,usr1.Id);
            
            Test.stopTest();
            
        }System.runAs(usr2){
             Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id);
        }System.runAs(usr3){
             Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id);
            
        }
       // Test.stopTest();
    } 
    
    @isTest
    static void activityForATFApproval(){
        Test.startTest();
        
        User usr1 = [select Id from user where lastname = 'Retail After The Fact' LIMIT 1];
        
        PartnerFundRequest pfr = [select Id, RecordType.Name, RequestedAmount, Core_MDF_Fund_Request_Status__c ,Core_MDF_Country_nm__c
                                  from PartnerFundRequest 
                                  where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM' limit 1];
        
    
        List<Id> pfrsId = new List<Id>();
        pfrsId.add(pfr.Id);
        
        System.runAs(usr1){         
            
            pfr.RequestedAmount = 100000000;
            update pfr;
            Boolean submitStatus = Core_MDF_PFR_Approval.submitForApprovalClosed(pfrsId,'Test1233'); 
            
            System.assertEquals(submitStatus, true);
            Test.stopTest();
            
        }
    }
    @isTest
    static void loadSubmitForApprovalClosedPCT(){
      Test.startTest();
        
        User usr1 = [select Id from user where lastname = 'Retail After The Fact' LIMIT 1];
        
        PartnerFundRequest pfr = [select Id, RecordType.Name, RequestedAmount, Core_MDF_Fund_Request_Status__c ,Core_MDF_Price_reviewer_check_ind__c
                                  from PartnerFundRequest 
                                  where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM' limit 1];
        
    
        List<Id> pfrsId = new List<Id>();
        pfrsId.add(pfr.Id);
        
        System.runAs(usr1){
            //Boolean submitStatus = Core_MDF_PFR_Approval.submitForApprovalClosed(pfrsId,'Test123');
            
            pfr.RequestedAmount = 100000;
            update pfr;
            Boolean submitStatus = Core_MDF_PFR_Approval.submitForApprovalClosed(pfrsId,'Test1233');             
            System.assertEquals(submitStatus, true);

            
            pfr.RequestedAmount = 100000;
            pfr.Core_MDF_Price_reviewer_check_ind__c = true;
            pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            update pfr;
            //MBoolean submitStatus1 = Core_MDF_PFR_Approval.submitForApprovalClosed(pfrsId,'Test1233');   
            Test.stopTest();
            
        }
    }
 @isTest
    static void loadSubmitForApprovalClosedPCT12(){
         User usr3 = [select id from user where lastname = 'Retail Account Manager' LIMIT 1];
      
        Campaign camp12=[Select Id From Campaign where name='TestRetailCamp'];
          Account accRetail12=[select Id from account where name='Co-marketing Test Account Retail'];
          System.runAs(usr3){
         PartnerFundRequest pfr12 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp12.Id),Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accRetail12.id),NULL,NULL,
                                                                                          'UNITED KINGDOM','Enthusiast Gaming','Traditional Notebook', 'Intel® 11ᵗʰ Gen','Sales Incentive','Seller - Target SPIF',' ',false); 
         
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
            List<Id> pfrID12= new List<Id>();
           pfrID12.add(pfr12.Id);
            Core_MDF_PFR_Approval.submitForApprovalClosed(pfrID12,'test1234567 ');  
            
    }
    }

     @isTest
    static void recallActionTest(){        
        User usr3 = [select id from user where lastname = 'Retail Account Manager' LIMIT 1];
        PartnerFundRequest pfr = [select id, RecordType.Name, Core_MDF_Fund_Request_Status__c,Core_MDF_Country_nm__c from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM' limit 1];
        PartnerFundRequest pfr1 = [select id, RecordType.Name, Core_MDF_Fund_Request_Status__c,Core_MDF_Price_reviewer_check_ind__c  from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'India' limit 1];
        
        Map<String,String> pfrInstanceMap = new Map<String,String>();
        Map<Id,Map<String,String>> pfrMapValues = new Map<Id,Map<String,String>>();
        List<Id> pfrsId = new List<Id>();
        pfrsId.add(pfr.Id);
        String approvalComments = 'Test';
        pfrInstanceMap.put('Test internal comments', 'Approve');
        pfrMapValues.put(pfr.Id, pfrInstanceMap);
      //  Core_MDF_PFR_Approval.checkRecallAction(pfrMapValues, approvalComments);
        
        pfr.RequestedAmount = 30000;
        pfr.Core_MDF_Region_nm__c = 'EMEA';
        update pfr;
        List<Id> pfrsId1 = new List<Id>();
        pfrsId1.add(pfr.Id);
        
        System.runAs(usr3){
            test.startTest();
            List<Id> pfrsIdList = new List<Id>();
           pfrsIdList.add((Id)'0RJ3b000000CrEKGA0');
            pfrsIdList.add((Id)'0RJ3b000000CrEKGA0');
            Core_MDF_PFR_Approval.submitForApproval(pfrsIdList, 'CHECK 1');
            Core_MDF_PFR_Approval.submitForApprovalClosed(pfrsId1, 'CHECK 2');
            Test.stopTest();
        }
        /*pfr.RequestedAmount = 25100;
        update pfr;
        System.runAs(usr3){
            List<Id> pfrsId2 = new List<Id>();
            pfrsId2.add(pfr.Id);
            Core_MDF_PFR_Approval.submitForApprovalClosed(pfrsId2,'Test1');  
        }*/ 
    }
    
    @isTest
    static void recallActionTest2(){        
        User usr3 = [select id from user where lastname = 'Retail Account Manager' LIMIT 1];
        PartnerFundRequest pfr = [select id, RecordType.Name, Core_MDF_Fund_Request_Status__c,Core_MDF_Country_nm__c from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM' limit 1];
        PartnerFundRequest pfr1 = [select id, RecordType.Name, Core_MDF_Fund_Request_Status__c,Core_MDF_Price_reviewer_check_ind__c  from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'India' limit 1];
        
        pfr.RequestedAmount = 300000;
        pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        pfr.Core_MDF_ATF_Approval_Reqd_ind__c = true;
        pfr.Core_MDF_Price_reviewer_check_ind__c = true;
        update pfr;
        List<Id> pfrsId1 = new List<Id>();
        pfrsId1.add(pfr.Id);
        
        System.runAs(usr3){
            test.startTest();
            Core_MDF_PFR_Approval.submitForApprovalClosed(pfrsId1, 'CHECK 3');
            Test.stopTest();
        }
    }
    @isTest
   public static void approveRejectActivityTest(){
        User usr1 = [select id from user where lastname = 'Retail Account Reviewer Test' LIMIT 1];
        ChannelProgram cpRetail = [select id from ChannelProgram where name='Retail Marketing Funds'];
         Account acc1Retail=[select id from Account where name='Test Account Retail'];
      	Account accRetail = [select id from Account where name='Co-marketing Test Account Retail'];
  
        Account accRetail1 = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail1', cpRetail.Id,
                                                                         Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        accRetail1.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
        accRetail1.Core_Geo__c = 'EMEA';
        accRetail1.Core_Sub_Geo__c = 'META';
        //accCoMarketingList.add(accRetail1);
        
        Database.insert(accRetail1);
        User sysAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);
        insert sysAdmin;
        System.runAs(sysAdmin){
            permissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Finance_Usr' LIMIT 1];
           insert new PermissionSetAssignment(AssigneeId = sysAdmin.id, PermissionSetId = ps.Id);
        }
            PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                           accRetail.id, cpRetail.Id , 100000 , System.today()+180, System.today() +260 , 
                                                                                           false);
            testBudget1.IsIgnoreValidation = true;
            //testBudget1.Core_MDF_Budget_Type_Txt__c = 'RSA MD';
        System.runAs(sysAdmin){
            insert testBudget1;
        }
            testBudget1.Core_MDF_Budget_Status__c = 'Released';
        System.runAs(sysAdmin){
            update testBudget1;
        }
            PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA',testBudget1, accRetail1, 89999,false);
            insert pfaRecord;
            
            
            test.startTest();
            Campaign camp2 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 'yes',
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today(), 
                                                                         System.today().addYears(1), 1000, 'Instore innovation', accRetail.Id,'2-in-1', true);
           
         /*PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp2.Id),string.valueof(accRetail.id),System.today().addDays(180),System.today().addDays(185),false); 
        
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr.Core_MDF_Start_Date__c = System.today();
            pfr.Core_MDF_End_Date__c = System.today().addDays(18);
            pfr.RequestedAmount = 26000;
            pfr.Core_MDF_Country_nm__c = 'INDIA';
           
            pfr.Core_MDF_Fund_Request_Status__c = 'In-Progress';
            Database.insert(pfr);
        	pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            Database.update(pfr);*/
        
        //test.startTest();
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp2.Id),Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accRetail.id),pfaRecord,testBudget1,'UNITED KINGDOM','Business','Chromebook',
																					'9ᵗʰ Gen','Broadcast','Podcast','Draft',false);
        pfr.RequestedAmount=25009;
        pfr.Core_MDF_Budget_Type_nm__c='Retail MDF';
        pfr.Core_MDF_External_Approval_Comment_txt__c='Test';
        pfr.Core_MDF_Fund_Request_Status__c='Pending Review';
        pfr.Core_MDF_Approval_Stage__c='L1 Approval';
        pfr.Core_MDF_ATF_Approval_Reqd_ind__c=False;
        insert pfr;
        Map<Id,Map<String,String>> mapValues=new Map<Id,Map<String,String>>();
		Map<String,String> mapValues1=new Map<String,String> ();
        System.runAs(usr1){
        mapValues1.put('Test Internal Comments','Approve');
		mapvalues.put(pfr.id,mapValues1);
		String approvalComments='Test';
		
        Core_MDF_PFR_Approval.approveRejectActivity(mapValues, approvalComments,true);
        }
        test.stoptest();
       }

}