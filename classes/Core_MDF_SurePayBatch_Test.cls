@isTest
public class Core_MDF_SurePayBatch_Test {

  
    @TestSetup static void setUpData(){
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        bypassFunctionKeys.add('checkAndSendClaimsForPIC');
        bypassFunctionKeys.add('duplicateClaimCheck');
        bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
        bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
        bypassFunctionKeys.add('Bypass_ShareActivityWithUsers');
        bypassFunctionKeys.add('Bypass_Activity_ApprovalProcess');
        bypassFunctionKeys.add('Bypass_ShareActivityWithAccNodeGroup');
        bypassFunctionKeys.add('ShareActivityWithInternalUsers_Bypass');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_Bank_ABM_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_External_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_NodeGroup_Sharing');
        bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
         ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        
        Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        intelAccount.Core_Geo__c = 'APJ';
        intelAccount.Core_Sub_Geo__c = 'SA';
        Database.insert(intelAccount);
        
        Account virtualAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Virtual Corp Account', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        virtualAcc.Core_MDF_Parent_Fund_Account__c = intelAccount.Id;
        virtualAcc.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccount.Id;
        Database.insert(virtualAcc);
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
         
        
        List<Account> toBeUpdated = new List<Account>();
        
        // Creating Account with utility class
        List<Account> accList = new List<Account>();
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        insert acc1;
        Account acc2 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        acc2.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        accList.add(acc2);
         
        Database.insert(accList);
        // Updating Accounts 
        acc1.isPartner = true;
        acc2.isPartner = true;
        toBeUpdated.add(acc1);
        toBeUpdated.add(acc2);
        Database.update(toBeUpdated);
        
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        
        
    	List<User> userlistToInsert = new List<User>();
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        usr.LastName = 'SysAdmUser';
        userlistToInsert.add(usr);
        
        // Creating User with utility class 
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.profileId = systemAdminProfile.Id;
        usr2.LastName = 'SysAdmUser1';
        userlistToInsert.add(usr2);
        
        Profile coreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' limit 1];
        
        // Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.profileId = coreAccessProfile.Id;
        usr1.LastName = 'TestClassClaimCaseReviewwerManager';
        userlistToInsert.add(usr1);
        Database.insert(userlistToInsert);
        
        
        System.runAs(usr){
            PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp.Id, 200000, System.today(),System.today(), false);
        //pbm.IsIgnoreValidation = true;
        pbm.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
        insert pbm;
            
        // Creating a map of PS names and PS
        Map<String,PermissionSet> nameToPerSet = new Map<String,PermissionSet>();
        for(PermissionSet pSet:[SELECT Id,Name FROM PermissionSet WHERE Name IN (
            'Core_MDF_CCP_Internal_Generic_Access',
            'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager',
            'Core_MDF_CCP_Internal_APJ_User',
            'View_All_Data'
        )]) {
            nameToPerSet.put(pSet.Name,pSet);
        }
        
        PermissionSet intnernalGenericPS = nameToPerSet.get('Core_MDF_CCP_Internal_Generic_Access'); 
        PermissionSet claimCaseReviewerManagerPS = nameToPerSet.get('Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager'); 
        PermissionSet internalApjUser= nameToPerSet.get('Core_MDF_CCP_Internal_APJ_User');
        PermissionSet viewAllDataPS = nameToPerSet.get('View_All_Data');
            
        List<PermissionSetAssignment> permSetAssgnLst = new List<PermissionSetAssignment>();
        
        PermissionSetAssignment assignIntnernalGenericPS = new PermissionSetAssignment();
        assignIntnernalGenericPS.AssigneeId = usr1.Id;
        assignIntnernalGenericPS.PermissionSetId = intnernalGenericPS.Id;
        permSetAssgnLst.add(assignIntnernalGenericPS);
        
        PermissionSetAssignment assignClaimCaseReviewerManagerPS = new PermissionSetAssignment();
        assignClaimCaseReviewerManagerPS.AssigneeId = usr1.Id;
        assignClaimCaseReviewerManagerPS.PermissionSetId = claimCaseReviewerManagerPS.Id;
        permSetAssgnLst.add(assignClaimCaseReviewerManagerPS);
            
        
       	PermissionSetAssignment assignInternalApjUser = new PermissionSetAssignment();
        assignInternalApjUser.AssigneeId = usr1.Id;
        assignInternalApjUser.PermissionSetId = internalApjUser.Id;
        permSetAssgnLst.add(assignInternalApjUser);
            
        PermissionSetAssignment assignViewAllPermissionSet = new PermissionSetAssignment();
        assignViewAllPermissionSet.AssigneeId = usr1.Id;
        assignViewAllPermissionSet.PermissionSetId = viewAllDataPS.Id;
        permSetAssgnLst.add(assignViewAllPermissionSet);
            
        system.runAs(usr){
            Database.insert(permSetAssgnLst);
            
        }
        
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, acc2, 30000, true);
            
            PartnerFundAllocation pfa = [Select id, Amount from PartnerFundAllocation where BudgetId =: pbm.Id and Title='Test PFA' limit 1];
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', 'Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today(), 20000, 'Always Connected PC', acc2.Id,'Desktop', false);
            camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
            database.insert(camp);
            
            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,String.valueof(acc2.Id),pfa,pbm,'INDIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Podcast','Draft',false);
            testPartnerFundRequestRecord.Title = 'indiaActivity';
            testPartnerFundRequestRecord.Core_MDF_Activity_Description__c = 'indiaActivity';
            testPartnerFundRequestRecord.Core_MDF_Start_Date__c = System.today();
            testPartnerFundRequestRecord.Core_MDF_End_Date__c = System.today();
            testPartnerFundRequestRecord.RequestedAmount = 10000;
            testPartnerFundRequestRecord.Core_MDF_Channel_Partner_Led__c = True;
            testPartnerFundRequestRecord.Amount=10000;
            testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
            //testPartnerFundRequestRecord.Core_MDF_Region_cd__c = 'APJ';
            testPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_txt__c='60%';
            insert testPartnerFundRequestRecord;
            
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231230');
			insert bank;
            List<PartnerFundClaim> claimList1 = new List<PartnerFundClaim>();            
            
            List <PartnerFundClaim> claimList = new List <PartnerFundClaim>();
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim1', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 5000.00, System.today(), bank.Id, false);
            claim1.Core_MDF_Currency__c = 'USD';
            claim1.Status = 'Approved';
        	claim1.Core_MDF_Status__c = 'Payment Due';
            claim1.Core_MDF_Budget_Type_Options_Nm__c = 'CCF 1.0';
            claim1.Core_MDF_Country_Location_nm__c = 'INDIA';
            claim1.Core_MDF_Region_Cd__c = 'APJ';
            claim1.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
            claim1.Core_MDF_Number_Of_Recoveries_Nbr__c = null;
            claimList.add(claim1);
            Test.startTest();
            database.insert(claimList);
        
            Test.stopTest();
            
        for(PartnerFundClaim claim:[select id,Core_MDF_Status__c,Core_MDF_Region_Cd__c from PartnerFundClaim]){
            System.debug('sgrdgtb '+claim);
        }
        Case cs = new Case();
        Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit_Closed').getRecordTypeId();
        cs.Status = 'Open';
        cs.recordTypeId = caseAuditRecType;
        cs.AccountId = acc2.id;
        cs.Core_MDF_Claim_ID__c=claimList[0].Id;
        cs.Core_MDF_Claim_Lookup_Id__c = claimList[0].Id;
        cs.Core_MDF_Channel_Program_txt__c = Core_MDF_CCP_ConstantClass.CCF_PROGRAM;
        cs.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
        cs.Core_MDF_Country_Region__c = 'INDIA';
        cs.Core_MDF_Scorecard_Score_Nbr__c = 0;
        insert cs;
            for(PartnerFundClaim claim:[select id,Core_MDF_Status__c,Core_MDF_Region_Cd__c from PartnerFundClaim]){
            claim.Core_MDF_Status__c = 'Payment Due';
            claim.Core_MDF_Claim_Review_Case__c = cs.id;
            claimList1.add(claim);
        }
            Database.update(claimList1);
        
        Core_MDF_Configuration__c config = new  Core_MDF_Configuration__c();
        config.name = 'Core_MDF_PScore_Edit_Buffer_Days';
        config.Core_MDF_Value__c = '365';
        insert config;
        
        string quarterYear = Core_MDF_ReverseAuditDecision.determineQuartYear(system.today());
        List<string> quarterYearSplit = quarterYear.split(' ');
        Core_MDF_Partnership_Score__c ps = new Core_MDF_Partnership_Score__c();
        ps.Core_MDF_Account_Id__c  = acc1.Id;
        ps.Core_MDF_Channel_Program_Id__c =cp.Id;
        ps.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        ps.Core_MDF_Quarter_nm__c = quarterYearSplit[0].trim();
        ps.Core_MDF_Year_nm__c = quarterYearSplit[1].trim();
        ps.Core_MDF_Quarter_Year_Nm__c = quarterYear;
        ps.Core_MDF_Virtual_Corp_Account_Id__c = acc2.Id;
        ps.Core_MDF_External_Id__c = '' + cp.Id + acc2.Id + quarterYear;
        //ps.Core_MDF_Recovered_Amt__c = 25;
        insert ps;
            
        
        Core_MDF_Partnership_Score_Detail__c psd = new Core_MDF_Partnership_Score_Detail__c();
        psd.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
        psd.Core_MDF_Carry_Over_Amt__c = 0;
        psd.Core_MDF_Region_Cd__c = 'APJ';
        //psd.Core_MDF_Region_Cd__c = null;
        psd.Core_MDF_Partnership_Score_Id__c = ps.id;
        psd.Core_MDF_Recovered_Amt__c = 100.00;
        psd.Core_MDF_External_ID__c = '' + cp.Id + acc2.Id + quarterYear + psd.Core_MDF_Budget_Type_nm__c + psd.Core_MDF_Region_Cd__c;
        insert psd;
            Core_MDF_Scorecard__c scoreCard = new Core_MDF_Scorecard__c();
                        scoreCard.Core_MDF_Case_Id__c = cs.id;
                        scoreCard.Core_MDF_Attribution_Nbr__c ='2';
                        scoreCard.Core_MDF_Attribution_PV_Ind__c= 'M';
                        scoreCard.Core_MDF_Engagement_Nbr__c = '2';
                        scoreCard.Core_MDF_Engagement_PV_Ind__c = 'M';
                        scoreCard.Core_MDF_POP__c='1';
                        scoreCard.Core_MDF_POP_PV_Ind__c = 'M';
                        scoreCard.Core_MDF_Manual_Recovery_Amount_USD_Amt__c=10;
            insert scoreCard;
        Core_MDF_Recovery_Dashboard__c recDashboardRec = new Core_MDF_Recovery_Dashboard__c();
        recDashboardRec.Core_MDF_Scorecard_Id__c = scoreCard.Id;
        recDashboardRec.Core_MDF_Partnership_Score_Detail_Id__c = psd.id;
       	recDashboardRec.Core_MDF_Partnership_Score_Id__c = ps.id;    
        recDashboardRec.Core_MDF_Is_Active_Ind__c = true;
        insert recDashboardRec;

        }
        
        
        Group claimCaseReviewerGrp = [SELECT Id FROM Group WHERE DeveloperName = 'Core_MDF_CCP_Claim_Case_Reviewer_Q_Group' limit 1];
        system.debug(claimCaseReviewerGrp);
        
        system.runAs(usr2){
         	GroupMember groupMember = new GroupMember( GroupId = claimCaseReviewerGrp.Id, UserOrGroupId = usr1.Id);
        	insert groupMember;   
        }
        Case caseRec = [select id,Core_MDF_Claim_ID__c,Core_MDF_Claim_Lookup_Id__r.Core_MDF_Region_Cd__c from case LIMIT 1];
        CaseShare cs = new CaseShare(UserOrGroupId = usr1.Id, CaseAccessLevel = 'Edit', CaseId = caseRec.Id, RowCause = 'Manual' );
        insert cs;
        Core_MDF_Partnership_Score__c ps = [select Id from Core_MDF_Partnership_Score__c limit 1];
        Core_MDF_Partnership_Score__Share psShare = new Core_MDF_Partnership_Score__Share(UserOrGroupId = usr1.Id, AccessLevel = 'Edit', parentId = ps.Id, RowCause = 'Manual' );
        insert psShare;
    }
    @isTest static void testSurePay(){
        User usr1 = [SELECT Id FROM User WHERE LastName = 'TestClassClaimCaseReviewwerManager' LIMIT 1];
        system.runAs(usr1){
         	Case caseRec = [select id,Core_MDF_Claim_ID__c,Core_MDF_Claim_Lookup_Id__r.Core_MDF_Region_Cd__c,Core_MDF_Status__c,Core_MDF_Manual_Recovery_Amount_USD_Amt__c,Core_MDF_Scorecard_Score_Nbr__c from case LIMIT 1];
            PartnerFundClaim claim1 = [select  Id, Core_MDF_Budget_Type_Options_Nm__c, ChannelPartnerId, Core_MDF_Program__c, Core_MDF_Region_Cd__c, Amount, Core_MDF_Status__c,Core_MDF_Ultimate_Account_ID__c,Core_MDF_Processing_Preference_nm__c,  
                       Core_MDF_Claim_Review_Case__r.Core_MDF_Scorecard_Score_Nbr__c, Core_MDF_Claim_Review_Case__r.Core_MDF_Manual_Recovery_Amount_USD_Amt__c  from PartnerFundClaim limit 1];
            
            string result;
            caseRec.Status = 'Closed';
            caseRec.Core_MDF_Status__c ='Review Completed';
            caseRec.Core_MDF_Manual_Recovery_Amount_USD_Amt__c=10;
            caseRec.Core_MDF_Scorecard_Score_Nbr__c=0;
            update caseRec;
            Core_MDF_SurePay_Batch surePayRun = new Core_MDF_SurePay_Batch('Client');
                database.executeBatch(surePayRun,50);

			List<Core_MDF_Partnership_Score_Detail__c> scoreDetailTobeUpdated = new List<Core_MDF_Partnership_Score_Detail__c>();
            
            	Core_MDF_Batch_Bulk_CRUD_Operations updateRecBatch = new Core_MDF_Batch_Bulk_CRUD_Operations(scoreDetailTobeUpdated);
                database.executeBatch(updateRecBatch,50);
               
        }
    }
}