/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFC_IPAClaim_Test
* Version     : 1.0 
* Created Date: 04-Aug-2020
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel -Areefa          04-Aug-2020                    Created to test IPAClaim Functionality 
*****************************************************************************************************************************************/
@isTest
public class Core_MDF_PFC_IPAClaim_Test {
    
    // test method for data setup
    @TestSetup static void setUpData(){
        
        UserRole adminRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        User u = Core_MDF_CCP_TestDataUtility.createUser(false);
        u.LastName = 'User Test';
        u.Email = 'testsysAdmin@example.com';
        u.UserRoleId = adminRole.Id;
        insert u;
        
        System.runAs(u){
        
        List<Account> acctList = new List<Account>();
        
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
        //bypassFunctionKeys.add('Bypass_Activity_ApprovalProcess');
        bypassFunctionKeys.add('Bypass_ShareActivityWithUsers');
        bypassFunctionKeys.add('Bypass_ShareActivityWithAccNodeGroup');
        bypassFunctionKeys.add('Bypass_geoLeadApprovalProcess');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
        Id campaign_RecordType_IPA = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        PermissionSet IPAPayAdmPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_IPA_Payment_Adm' LIMIT 1];
        
        // Creating a map of profile name and profile Id
        Map<String,Id> profileToId = new Map<String,Id>();
        for(Profile prfl:[SELECT Id,Name FROM Profile WHERE Name IN ('System Administrator','CCP - Core Access')]) {
            profileToId.put(prfl.Name,prfl.Id);
        }
        
        // Creating User with utility class 
        List<User> userList = new List<User>();
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.Email = 'sysadmin@example.com';
        userList.add(usr1);
        Database.insert(userList);
        system.runAs(usr1){
         PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
            assignPermissionSetObj1.AssigneeId = usr1.Id;
            assignPermissionSetObj1.PermissionSetId = IPAPayAdmPS.Id;
            Database.insert(assignPermissionSetObj1);
        }
        
        Id acctRecord_Type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Id IPABudgetCapRecord_Type = Schema.SObjectType.Core_MDF_Budget_Cap__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Budget_Type_Cap').getRecordTypeId();
        Account acc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test IPA Accounttest', acctRecord_Type, false);
        acc.Core_MDF_CoMarketingActive__c = false;
        insert acc;
        
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test IPA Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        acc1.Core_MDF_CoMarketingActive__c = true;
        acc1.Core_IPA_One_Partner_Id__c=acc.id;
        acctList.add(acc1);
        insert(acctList);
        
        // Updating Accounts 
        acc1.isPartner = true;
        Database.update(acc1); 
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false);
        acc2.Core_Geo__c='';
        acc2.Core_Sub_Geo__c='';
        insert acc2;       
        
        //string budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(acc2);
        string budgetType = 'Proposal I MDF';
        
        Group ipaGrp = new Group();
            ipaGrp.Name = 'Core CCP IPA Internal';
            ipaGrp.DeveloperName = 'Core_MDF_CCP_IPA_Internal';
          system.runAs(usr1){ 
        Database.insert(ipaGrp);
     
     GroupMember ipaGrpMem = new GroupMember();
            ipaGrpMem.UserOrGroupId = usr1.Id;
            ipaGrpMem.GroupId = ipaGrp.Id;
            Database.insert(ipaGrpMem);

        }
		Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = acc1.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_Internal';
            pgm1.Core_MDF_Type_of_Access__c = 'EXTERNAL';
            pgm1.Core_MDF_Group_Id__c = ipaGrp.Id;                
            pgm1.Core_MDF_Channel_Program__c = cp.Id;
            pgm1.Core_MDF_Source_Txt__c = 'Test';
            pgm1.Core_MDF_Region_cd__C = 'APJ';
            pgm1.Core_MDF_AccountIdGroupName__c = acc1.Id+'Core_MDF_CCP_IPA_Internal';
            Database.insert(pgm1);
        //added
        //string budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(acc2);
        //budgetType = 'Data Center Specialties MDF';
        PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_IPA_TestDataUtility.budgetIPA_ProposalBased_Record_Type,acc2.Id,cp.Id,200000,System.today().addDays(-20),System.today().addDays(300), false);
        //budget.Core_MDF_Budget_Type__c='Data Centric Acceleration - MDF';
        budget.Core_MDF_Budget_Type_Txt__c='Proposal I MDF';
        Database.insert(budget);
        
        PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('allocation',budget,acc2, 100000,true);
        
        Campaign camp = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test IPA Camp',acc2.Id, System.today().addDays(-2), System.today().addDays(300),budgetType,
                                                                           1234.00, 'AFGHANISTAN','Consumer','Coffee Lake','Planned', false);
        camp.Core_MDF_Region_cd__c = 'APJ';
        camp.Core_MDF_Budget_Type_txt__c = budgetType;
        camp.Core_MDF_Budget__c = budget.Id;
        camp.Core_MDF_Reimbursement_Amt__c = 10000;
        camp.Core_MDF_CampOutcomeOpt_In_Ind__c = true;
       
        Database.insert(camp);
        
        Core_MDF_Campaign_Outcomes__c campPurpose = new Core_MDF_Campaign_Outcomes__c(Core_MDF_Active_Ind__c = true, Core_MDF_Initial_Baseline_Quantity_nbr__c =10, Core_MDF_Campaign_Id__c = camp.Id, Core_MDF_Goal_Quantity_nbr__c = 10,Core_MDF_Outcome_Criteria_txt__c = 'test', Core_MDF_Outcomes_nm__c = 'Revenue - Billings', Core_MDF_Quantity_nbr__c = 10);
        insert campPurpose;

        Test.startTest();
        PartnerFundRequest pfr = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(camp.Id,acc2.Id,System.today().addDays(-2),System.today().addDays(20),false);
        pfr.Core_MDF_BU_Split__c ='CCG';
        pfr.Core_MDF_BU1_Split_Percent_nbr__c=100;
        pfr.amount = 500;
        pfr.Core_MDF_Reimbursement_Rate_txt__c='60%';
        pfr.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        pfr.Core_MDF_ActivityCategory__c = 'Outcome-Based';
        pfr.Core_MDF_Activity_Types__c = 'Outcome-Based';
        pfr.Core_MDF_Reimbursement_Rate_txt__c ='50%';
            pfr.AllocationId=pfa.id;
        //pfr.Core_MDF_Budget_Type_nm__c = 'SOEM Client MDF';
       // pfr.Core_MDF_Budget_Type_txt__c = 'SOEM Client MDF';
        Database.insert(pfr);
        
        List<Core_MDF_Activity_Attributes__c> activityAttributeList = new List<Core_MDF_Activity_Attributes__c>();
        Core_MDF_Activity_Attributes__c activityAttributeKpi = new Core_MDF_Activity_Attributes__c();
        activityAttributeKpi.Core_MDF_Co_Marketing_Activity__c = pfr.Id;
        activityAttributeKpi.Core_MDF_Field_Name_nm__c = 'Digital Media - # of Impressions';
        activityAttributeKpi.Core_MDF_Field_Value_nbr__c = 10;
        activityAttributeKpi.Core_MDF_Is_Active_Ind__c = true;
        activityAttributeKpi.Core_MDF_Tactics_nm__c = 'Digital Media';
        activityAttributeKpi.Core_MDF_Type_nm__c = 'KPI';
        activityAttributeList.add(activityAttributeKpi);
        
        Core_MDF_Activity_Attributes__c activityAttributePercentage = new Core_MDF_Activity_Attributes__c();
        activityAttributePercentage.Core_MDF_Co_Marketing_Activity__c = pfr.Id;
        activityAttributePercentage.Core_MDF_Field_Name_nm__c = 'Digital Media Percentage Spend';
        activityAttributePercentage.Core_MDF_Field_Value_nbr__c = 100;
        activityAttributePercentage.Core_MDF_Is_Active_Ind__c = true;
        activityAttributePercentage.Core_MDF_Tactics_nm__c = 'Digital Media';
        activityAttributePercentage.Core_MDF_Type_nm__c = 'Percentage';
        activityAttributeList.add(activityAttributePercentage);
        
        insert activityAttributeList;
        
        camp.Status = 'Proposal Accepted';
        Database.update(camp);
        pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
        pfr.Core_MDF_Reimbursement_Rate_pct__c ='100%';
        Database.update(pfr);
        
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();        
        Test.stopTest();
        
        List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();
        
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Intel_Partner_Alliance', false,'1231231230');
        bank.Core_MDF_Intel_Company_Code__c = '650';
        bank.Core_MDF_Effective_Date__c = System.today().addDays(-2);
        bank.Core_MDF_Currency_cd__c = 'USD';
        bank.Core_MDF_Tax_codes_cd__c = 'UB';
        bank.Core_MDF_Bank_Status__c = 'Active';
        bank.Core_MDF_VAT_pct__c= '20';
        bank.Core_MDF_Bank_Location__c = 'US';
        bank.Core_MDF_Supplier_City_txt__c = 'New York';
        bank.Core_MDF_Supplier_Country_txt__c = 'US';
        bank.Core_MDF_Supplier_Postal_Code_cd__c = '110111';
        bank.Core_MDF_Supplier_Region_txt__c = 'USA';
        System.runAs(usr1){
            Database.insert(bank);
        }
        
        //Do Account Bank Mapping for 'bank' and ABM 
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank.Id,true);
        //Database.insert(abm1);
        
        
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        
    }   
    }
    @isTest static void validateIPAClaim() { 
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        
       // try{
            System.runAs(sysAdminUser)
            {
                
                Campaign camp  = [Select Id, Name, StartDate, EndDate, Description, Core_MDF_Budget__c,Core_MDF_Account__c,Core_MDF_Channel_Program__c,
                                  Core_MDF_Budget_Type_txt__c,Core_MDF_Total_Campaign_Cost_Amt__c
                                  from Campaign where Name = 'Test IPA Camp' limit 1];           
                //Test.startTest(); 
                PartnerFundRequest pfr = [Select id,Core_MDF_Fund_Request_Status__c,AllocationId, Core_MDF_Start_Date__c,Core_MDF_End_Date__c,Core_MDF_Country_nm__c from PartnerFundRequest where CampaignId=:camp.Id];
                //pfr.Core_MDF_Reimbursement_Rate_pct__c ='25%';
                pfr.status ='Approved';
                database.update(pfr);
                
                List<Campaign> campToBeUpdated = new List<Campaign>();
                campToBeUpdated.add(camp);
                List<PartnerFundRequest> pfrToBeUpdated = new List<PartnerFundRequest>();
                
                Id recordtype = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_ProposalBased').getRecordTypeId(); 
                
                
                
                PartnerMarketingBudget pmb = [Select id,Title, Description, Core_MDF_Budget_Status__c, StartDate, EndDate, Amount, Core_MDF_Budget_Type_Txt__c,
                                              Core_MDF_Budget_Partner__c,Core_MDF_Program__c, RecordTypeId, IsIgnoreValidation From PartnerMarketingBudget where Id = :camp.Core_MDF_Budget__c];
                
                PartnerFundAllocation pfa = [Select Id, ChannelPartnerId, Amount from PartnerFundAllocation where BudgetId = :pmb.Id];
                
                Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
                
                               
                //PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('IPA Claim', Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, System.today(), System.today(),50.00, System.today(), bank1.Id, false);
                Test.startTest();
                PartnerFundClaim claim1 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, pfr.Core_MDF_Start_Date__c , pfr.Core_MDF_Start_Date__c,50.00, bank1.Id, false); 
                claim1.Core_MDF_Type_Txt__c ='Claim';
                claim1.Core_MDF_Currency__c='USD';
                claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
                claim1.Core_MDF_Campaign_Id__c = camp.Id;
                 insert claim1;
                
                //Activity Attributes
                List<Core_MDF_Claim_Attributes__c> claimAttrList = new List<Core_MDF_Claim_Attributes__c>();
                Core_MDF_Claim_Attributes__c claimAttr1 = new Core_MDF_Claim_Attributes__c();
                claimAttr1.Core_MDF_Field_Name_nm__c = 'Digital Media - # of Clicks';
                claimAttr1.Core_MDF_Field_Value_nbr__c = 100;
                claimAttr1.Core_MDF_Is_Active_Ind__c = true;
                claimAttr1.Core_MDF_Tactics_nm__c = 'Digital Media';
                claimAttr1.Core_MDF_Type_nm__c = 'KPI - Claim';
                claimAttrList.add(claimAttr1);
                
                Core_MDF_Claim_Attributes__c claimAttr2 = new Core_MDF_Claim_Attributes__c();
                claimAttr2.Core_MDF_Field_Name_nm__c = 'Digital Media - # of Clicks';
                claimAttr2.Core_MDF_Field_Value_nbr__c = 100;
                claimAttr2.Core_MDF_Is_Active_Ind__c = true;
                claimAttr2.Core_MDF_Tactics_nm__c = 'Digital Media';
                claimAttr2.Core_MDF_Type_nm__c = 'KPI - Activity';
                claimAttrList.add(claimAttr2);
                
                Core_MDF_Claim_Attributes__c claimAttr3 = new Core_MDF_Claim_Attributes__c();
                //claimAttr2.Core_MDF_Field_Name_nm__c = '';
                claimAttr3.Core_MDF_Field_Value_nbr__c = 10;
                claimAttr3.Core_MDF_Is_Active_Ind__c = true;
                claimAttr3.Core_MDF_Tactics_nm__c = 'Digital Media';
                claimAttr3.Core_MDF_Type_nm__c = 'Spend This Period';
                claimAttrList.add(claimAttr3);
                
                Core_MDF_Claim_Attributes__c claimAttr4 = new Core_MDF_Claim_Attributes__c();
                //claimAttr2.Core_MDF_Field_Name_nm__c = '';
                claimAttr4.Core_MDF_Field_Value_nbr__c = 100;
                claimAttr4.Core_MDF_Is_Active_Ind__c = true;
                claimAttr4.Core_MDF_Tactics_nm__c = 'Digital Media';
                claimAttr4.Core_MDF_Type_nm__c = 'Total Planned Spend';
                claimAttrList.add(claimAttr4);
                
                Core_MDF_Claim_Attributes__c claimAttr5 = new Core_MDF_Claim_Attributes__c();
                //claimAttr2.Core_MDF_Field_Name_nm__c = '';
                claimAttr5.Core_MDF_Field_Value_nbr__c = 5;
                claimAttr5.Core_MDF_Is_Active_Ind__c = true;
                claimAttr5.Core_MDF_Tactics_nm__c = 'Digital Media';
                claimAttr5.Core_MDF_Type_nm__c = 'Previous Period Spends';
                claimAttrList.add(claimAttr5);
                
                
                system.debug('pfr.Idpfr.Id'+pfr.Id);
                system.debug('claim1.Idclaim1.Id'+claim1.Id);
                
                /*POP mandatory for IPA*/
                List<String> documentIdWithTitle = new List<String>();
                list<String> tempString = new list<String>();
                list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
                Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,null,null, true, claimAttrList, false, null, false);
                Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,null,null, true, claimAttrList, false, null, false);
                //Core_MDF_PartnerFundClaim.calculateAmountFields(new List<PartnerFundClaim>{claim1});
                Core_MDF_PartnerFundClaim.getCampaignPurposeDetails(pfr.Id, null);
                Core_MDF_PartnerFundClaim.getCampaignPurposeDetails(pfr.Id, claim1.Id);
              //  Core_MDF_Tactics_Controller.getTacticSpending(false, null , pfr.Id);
                Core_MDF_Tactics_Controller.getTacticSpending(true, claim1.Id, pfr.Id);
                String str1 = claim1.Id+';#'+'Test Doc1';
                String str2 = claim1.Id+';#'+'Test Doc2';
                
                documentIdWithTitle.add(str1);
                documentIdWithTitle.add(str2);
                
                for(String str: documentIdWithTitle){
                    tempString = str.split(';#');
                    Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                    auditDoc.Core_MDF_Document_Id__c = tempString[0];
                    auditDoc.Core_MDF_Document_Title__c = tempString[1];
                    auditDoc.Core_MDF_Claim__c = claim1.Id;
                    auditDoc.Core_MDF_Proof_of_Branding__c = true;
                    auditDoc.Core_MDF_Proof_of_Cost__c = true;
                    auditDoc.Core_MDF_Proof_of_Execution__c = true;  
                    auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
                    auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
                    auditDocList.add(auditDoc);
                }            
                
                if(auditDocList.size()>0){
                    Database.insert(auditDocList);                
                }
                
                Core_MDF_PartnerFundClaim.ClaimWrap iPAClaimRes = new Core_MDF_PartnerFundClaim.ClaimWrap();
                iPAClaimRes = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,null,null, false, null, false, null, false); 
                //String iPAClaimRes = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);
                //System.assertEquals(claim1.ID,iPAClaimRes.claimDetail.Id);
                pfr.status = 'Approved';
                pfr.AllocationId = pfa.Id;
                Database.update(pfr);
                
                List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
                PartnerFundClaim claim2 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim2',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, pfr.Core_MDF_Start_Date__c , pfr.Core_MDF_Start_Date__c,50.00, bank1.Id, false); 
                claim2.Core_MDF_Type_Txt__c ='Claim';
                claim2.Core_MDF_Currency__c='USD';
                claim2.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
                claim2.Core_MDF_Campaign_Id__c = camp.Id;
                claimList.add(claim2);
                    
                PartnerFundClaim claim3 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim3',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, pfr.Core_MDF_Start_Date__c , pfr.Core_MDF_Start_Date__c,30.00, bank1.Id, false); 
                claim3.Core_MDF_Type_Txt__c ='Claim';
                claim3.Core_MDF_Currency__c='USD';
                claim3.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
                claim3.Core_MDF_Campaign_Id__c = camp.Id;
                claim3.Core_MDF_Status__c = 'Cancelled';
                claimList.add(claim3);
                database.insert(claimList);
                
                //Core_MDF_IPA_Campaign_Functionality.queryPFCRecords(campToBeUpdated);
		Core_MDF_Proposal_Based_Campaign_Process.queryPFCRecords(campToBeUpdated);
                
                String record = claimList[1].Id;
                Core_MDF_PartnerFundClaim_Edit.fetchClaimById(record);
                Core_MDF_PartnerFundClaim_Edit.fetchClaimById(null);
                Core_MDF_PartnerFundClaim_Edit.isClaimEligibleForClone(record);
                Core_MDF_PartnerFundClaim_Edit.prepareCloneData(record);
                Core_MDF_PartnerFundClaim_Edit.hasAccessToEditClaim(claimList[1].Id);
                Core_MDF_PartnerFundClaim_Edit.hasAccessToEditClaim(null);
                
                
            }
        //}catch(Exception e){
        //    System.assertNotEquals(NULL,e);
        //}
    }
    
    /* Method to test Sum of IPA Claims amount should be within Activity Reimbursment  Amount*/
	@isTest static void testIPASumOfClaimAmtAgainstActivityBudgetAmtMethod() {  
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        
       // try{
            System.runAs(sysAdminUser)
            {
                
                Campaign camp  = [Select Id, Name, StartDate, EndDate, Description, Core_MDF_Budget__c,Core_MDF_Account__c,Core_MDF_Channel_Program__c,
                                  Core_MDF_Budget_Type_txt__c,Core_MDF_Total_Campaign_Cost_Amt__c
                                  from Campaign where Name = 'Test IPA Camp' limit 1];            
                Test.startTest(); 
                PartnerFundRequest pfr = [Select id,Core_MDF_Fund_Request_Status__c,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where CampaignId=:camp.Id];
                pfr.Core_MDF_Reimbursement_Rate_pct__c ='100%';
                database.update(pfr);
                
                List<Campaign> campToBeUpdated = new List<Campaign>();
                List<PartnerFundRequest> pfrToBeUpdated = new List<PartnerFundRequest>();
                List<PartnerFundClaim> pfc = new List<PartnerFundClaim>();
                Id recordtype = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_ProposalBased').getRecordTypeId(); 
                
                
                
                PartnerMarketingBudget pmb = [Select id,Title, Description, Core_MDF_Budget_Status__c, StartDate, EndDate, Amount, Core_MDF_Budget_Type_Txt__c,
                                              Core_MDF_Budget_Partner__c,Core_MDF_Program__c, RecordTypeId, IsIgnoreValidation From PartnerMarketingBudget where Id = :camp.Core_MDF_Budget__c];
                
                PartnerFundAllocation pfa = [Select Id, ChannelPartnerId, Amount from PartnerFundAllocation where BudgetId = :pmb.Id]; 
                
                Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
                
                List<String> documentIdWithTitle = new List<String>();
            	list<String> tempString = new list<String>();
            	list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>(); 
                
                PartnerFundClaim claim1 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, pfr.Core_MDF_Start_Date__c, pfr.Core_MDF_Start_Date__c,1000.00, bank1.Id, false); 
                claim1.Core_MDF_Type_Txt__c ='Claim';
                claim1.Core_MDF_Currency__c='USD';
                claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
                claim1.Core_MDF_Campaign_Id__c = camp.Id;
				//pfc.add(claim1);
				Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
            	res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,null,null, false, null, false, null, false); 
				//String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);            
            	//System.assertEquals(claim1.ID,res.claimDetail.Id);
                
				PartnerFundClaim claim2 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, pfr.Core_MDF_Start_Date__c , pfr.Core_MDF_Start_Date__c,234.00, bank1.Id, false); 
                claim2.Core_MDF_Type_Txt__c ='Claim';
                claim2.Core_MDF_Currency__c='USD';
                claim2.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
                claim2.Core_MDF_Campaign_Id__c = camp.Id;
				//pfc.add(claim2);
				
                Core_MDF_PartnerFundClaim.ClaimWrap res1 = new Core_MDF_PartnerFundClaim.ClaimWrap();
            	res1 = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList,null,null, false, null, false, null, false); 
				
				//String res1 = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList);            
            	//System.assertEquals(claim2.ID,res1.claimDetail.Id);
                
                /*POP mandatory for IPA*/
                String str1 = claim1.Id+';#'+'Test Doc1';
                String str2 = claim1.Id+';#'+'Test Doc2';
				String str3 = claim2.Id+';#'+'Test Doc3';
                String str4 = claim2.Id+';#'+'Test Doc4';
                
                documentIdWithTitle.add(str1);
                documentIdWithTitle.add(str2);
				documentIdWithTitle.add(str3);
                documentIdWithTitle.add(str4);
                
                for(PartnerFundClaim p : pfc){
					for(String str: documentIdWithTitle){
						tempString = str.split(';#');
						Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
						auditDoc.Core_MDF_Document_Id__c = tempString[0];
						auditDoc.Core_MDF_Document_Title__c = tempString[1];
						auditDoc.Core_MDF_Claim__c = p.Id;
						auditDoc.Core_MDF_Proof_of_Branding__c = true;
						auditDoc.Core_MDF_Proof_of_Cost__c = true;
						auditDoc.Core_MDF_Proof_of_Execution__c = true;
                        auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
                        auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
						auditDocList.add(auditDoc);
					}
				}   				
                
                if(auditDocList.size()>0){
                    Database.insert(auditDocList);                
                }
                /*String iPAClaimRes = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);
                System.assertEquals(claim1.ID,iPAClaimRes);*/           
                
                Test.stopTest();
                
                
            }
        //}catch(Exception e){
        //    System.assertNotEquals(NULL,e);
       // }
    }
    
    /* Method to test Sum of IPA Claims amount should be within Activity Reimbursment  Amount*/
	@isTest static void testIPASumOfClaimAmtAgainstActivityBudgetAmtExceptionMethod() {  
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        //Assert.areEqual(sysAdminUser.Email,'sysadmin@example.com');
       // try{
            System.runAs(sysAdminUser)
            {
                
                Campaign camp  = [Select Id, Name, StartDate, EndDate, Description, Core_MDF_Budget__c,Core_MDF_Account__c,Core_MDF_Channel_Program__c,
                                  Core_MDF_Budget_Type_txt__c,Core_MDF_Total_Campaign_Cost_Amt__c
                                  from Campaign where Name = 'Test IPA Camp' limit 1];     
                
                Test.startTest(); 
                /*PartnerFundRequest pfr = [Select id,Core_MDF_Fund_Request_Status__c, Core_MDF_Start_Date__c from PartnerFundRequest where CampaignId=:camp.Id];
                pfr.Core_MDF_Reimbursement_Rate_pct__c ='100%';
                database.update(pfr);*/
                
                List<Campaign> campToBeUpdated = new List<Campaign>();
                List<PartnerFundRequest> pfrToBeUpdated = new List<PartnerFundRequest>();
                List<PartnerFundClaim> pfc = new List<PartnerFundClaim>();
                Id recordtype = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_ProposalBased').getRecordTypeId(); 
                
                
                
                PartnerMarketingBudget pmb = [Select id,Title, Description, Core_MDF_Budget_Status__c, StartDate, EndDate, Amount, Core_MDF_Budget_Type_Txt__c,
                                              Core_MDF_Budget_Partner__c,Core_MDF_Program__c, RecordTypeId, IsIgnoreValidation From PartnerMarketingBudget where Id = :camp.Core_MDF_Budget__c];
                
                PartnerFundAllocation pfa = [Select Id, ChannelPartnerId, Amount from PartnerFundAllocation where BudgetId = :pmb.Id]; 
                
                Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
                
                PartnerFundRequest pfr = [Select id,Core_MDF_Fund_Request_Status__c, Core_MDF_Start_Date__c from PartnerFundRequest where CampaignId=:camp.Id];
                pfr.Core_MDF_Reimbursement_Rate_pct__c ='100%';
                pfr.Core_MDF_Fund_Request_Status__c = 'In-Progress';
                pfr.Status = 'Approved';
                pfr.AllocationId = pfa.Id;
                database.update(pfr);
                 
                PartnerFundClaim claim1 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, pfr.Core_MDF_Start_Date__c , pfr.Core_MDF_Start_Date__c,1000.00, bank1.Id, false); 
                claim1.Core_MDF_Type_Txt__c ='Claim';
                claim1.Core_MDF_Currency__c='USD';
                claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
                claim1.Core_MDF_Campaign_Id__c = camp.Id;
				pfc.add(claim1);
                
				PartnerFundClaim claim2 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id,pfr.Core_MDF_Start_Date__c , pfr.Core_MDF_Start_Date__c, 235.00, bank1.Id, false); 
                claim2.Core_MDF_Type_Txt__c ='Claim';
                claim2.Core_MDF_Currency__c='USD';
                claim2.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
                claim2.Core_MDF_Campaign_Id__c = camp.Id;
                pfc.add(claim2);
				
                /*POP mandatory for IPA*/
                List<String> documentIdWithTitle = new List<String>();
                list<String> tempString = new list<String>();
                list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
                
                String str1 = claim1.Id+';#'+'Test Doc1';
                String str2 = claim1.Id+';#'+'Test Doc2';
				String str3 = claim2.Id+';#'+'Test Doc3';
                String str4 = claim2.Id+';#'+'Test Doc4';
                
                documentIdWithTitle.add(str1);
                documentIdWithTitle.add(str2);
				documentIdWithTitle.add(str3);
                documentIdWithTitle.add(str4);
                
                for(PartnerFundClaim p : pfc){
					for(String str: documentIdWithTitle){
						tempString = str.split(';#');
						Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
						auditDoc.Core_MDF_Document_Id__c = tempString[0];
						auditDoc.Core_MDF_Document_Title__c = tempString[1];
						auditDoc.Core_MDF_Claim__c = p.Id;
						auditDoc.Core_MDF_Proof_of_Branding__c = true;
						auditDoc.Core_MDF_Proof_of_Cost__c = true;
						auditDoc.Core_MDF_Proof_of_Execution__c = true;
                        auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
                        auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
						auditDocList.add(auditDoc);
					}
				}   				
                
                if(auditDocList.size()>0){
                    Database.insert(auditDocList);                
                }
                //String iPAClaimRes = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList); 
                Database.insert(pfc);               
                Test.stopTest();
                
                
            }
       // }catch(Exception e){
       //     System.assertNotEquals(NULL,e);
       // }
    }
    
    /* @isTest static void validateIPAClaimPICFail() { 
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
          
            System.runAs(sysAdminUser) {
                
                Campaign camp  = [Select Id, Name, StartDate, EndDate, Description, Core_MDF_Budget__c,Core_MDF_Account__c,Core_MDF_Channel_Program__c,
                                  Core_MDF_Budget_Type_txt__c,Core_MDF_Total_Campaign_Cost_Amt__c
                                  from Campaign where Name = 'Test IPA Camp' limit 1];
                
                PartnerFundRequest pfr = [Select id,Core_MDF_Fund_Request_Status__c, Core_MDF_Start_Date__c,Core_MDF_End_Date__c,Core_MDF_Country_nm__c from PartnerFundRequest where CampaignId=:camp.Id];
                
                List<Campaign> campToBeUpdated = new List<Campaign>();
                campToBeUpdated.add(camp);
                List<PartnerFundRequest> pfrToBeUpdated = new List<PartnerFundRequest>();
                
                Id recordtype = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_ProposalBased').getRecordTypeId(); 
                
                PartnerMarketingBudget pmb = [Select id,Title, Description, Core_MDF_Budget_Status__c, StartDate, EndDate, Amount, Core_MDF_Budget_Type_Txt__c,
                                              Core_MDF_Budget_Partner__c,Core_MDF_Program__c, RecordTypeId, IsIgnoreValidation From PartnerMarketingBudget where Id = :camp.Core_MDF_Budget__c];
                
                PartnerFundAllocation pfa = [Select Id, ChannelPartnerId, Amount from PartnerFundAllocation where BudgetId = :pmb.Id];
                
                Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
                
     			Test.startTest();
                PartnerFundClaim claim1 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, pfr.Core_MDF_Start_Date__c , pfr.Core_MDF_Start_Date__c,50.00, bank1.Id, false); 
                claim1.Core_MDF_Type_Txt__c ='Claim';
                claim1.Core_MDF_Currency__c='USD';
                claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
                claim1.Core_MDF_Campaign_Id__c = camp.Id;
                
                //Activity Attributes
                List<Core_MDF_Claim_Attributes__c> claimAttrList = new List<Core_MDF_Claim_Attributes__c>();
                Core_MDF_Claim_Attributes__c claimAttr1 = new Core_MDF_Claim_Attributes__c();
                claimAttr1.Core_MDF_Field_Name_nm__c = 'Digital Media - # of Clicks';
                claimAttr1.Core_MDF_Field_Value_nbr__c = 100;
                claimAttr1.Core_MDF_Is_Active_Ind__c = true;
                claimAttr1.Core_MDF_Tactics_nm__c = 'Digital Media';
                claimAttr1.Core_MDF_Type_nm__c = 'KPI - Claim';
                claimAttrList.add(claimAttr1);
                
                Core_MDF_Claim_Attributes__c claimAttr2 = new Core_MDF_Claim_Attributes__c();
                claimAttr2.Core_MDF_Field_Name_nm__c = 'Digital Media - # of Clicks';
                claimAttr2.Core_MDF_Field_Value_nbr__c = 100;
                claimAttr2.Core_MDF_Is_Active_Ind__c = true;
                claimAttr2.Core_MDF_Tactics_nm__c = 'Digital Media';
                claimAttr2.Core_MDF_Type_nm__c = 'KPI - Activity';
                claimAttrList.add(claimAttr2);
                
                Core_MDF_Claim_Attributes__c claimAttr3 = new Core_MDF_Claim_Attributes__c();
                //claimAttr2.Core_MDF_Field_Name_nm__c = '';
                claimAttr3.Core_MDF_Field_Value_nbr__c = 10;
                claimAttr3.Core_MDF_Is_Active_Ind__c = true;
                claimAttr3.Core_MDF_Tactics_nm__c = 'Digital Media';
                claimAttr3.Core_MDF_Type_nm__c = 'Spend This Period';
                claimAttrList.add(claimAttr3);
                
                Core_MDF_Claim_Attributes__c claimAttr4 = new Core_MDF_Claim_Attributes__c();
                //claimAttr2.Core_MDF_Field_Name_nm__c = '';
                claimAttr4.Core_MDF_Field_Value_nbr__c = 100;
                claimAttr4.Core_MDF_Is_Active_Ind__c = true;
                claimAttr4.Core_MDF_Tactics_nm__c = 'Digital Media';
                claimAttr4.Core_MDF_Type_nm__c = 'Total Planned Spend';
                claimAttrList.add(claimAttr4);
                
                Core_MDF_Claim_Attributes__c claimAttr5 = new Core_MDF_Claim_Attributes__c();
                //claimAttr2.Core_MDF_Field_Name_nm__c = '';
                claimAttr5.Core_MDF_Field_Value_nbr__c = 5;
                claimAttr5.Core_MDF_Is_Active_Ind__c = true;
                claimAttr5.Core_MDF_Tactics_nm__c = 'Digital Media';
                claimAttr5.Core_MDF_Type_nm__c = 'Previous Period Spends';
                claimAttrList.add(claimAttr5);
                
                List<String> documentIdWithTitle = new List<String>();
                list<String> tempString = new list<String>();
                list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
               // Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,null,null, true, claimAttrList);
               // Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,null,null, true, claimAttrList);
                //Core_MDF_PartnerFundClaim.calculateAmountFields(new List<PartnerFundClaim>{claim1});
                Core_MDF_PartnerFundClaim.getCampaignPurposeDetails(pfr.Id, null);
                Core_MDF_PartnerFundClaim.getCampaignPurposeDetails(pfr.Id, claim1.Id);
                Core_MDF_Tactics_Controller.getTacticSpending(false, null , pfr.Id);
                Core_MDF_Tactics_Controller.getTacticSpending(true, claim1.Id, pfr.Id);
                String str1 = claim1.Id+';#'+'Test Doc1';
                String str2 = claim1.Id+';#'+'Test Doc2';
                
                documentIdWithTitle.add(str1);
                documentIdWithTitle.add(str2);
                
                for(String str: documentIdWithTitle){
                    tempString = str.split(';#');
                    Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                    auditDoc.Core_MDF_Document_Id__c = tempString[0];
                    auditDoc.Core_MDF_Document_Title__c = tempString[1];
                    auditDoc.Core_MDF_Claim__c = claim1.Id;
                    auditDoc.Core_MDF_Proof_of_Branding__c = true;
                    auditDoc.Core_MDF_Proof_of_Cost__c = true;
                    auditDoc.Core_MDF_Proof_of_Execution__c = true;  
                    auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
                    auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
                    auditDocList.add(auditDoc);
                }            
                
                if(auditDocList.size()>0){
                    Database.insert(auditDocList);                
                }
                
                Core_MDF_PartnerFundClaim.ClaimWrap iPAClaimRes = new Core_MDF_PartnerFundClaim.ClaimWrap();
             //   iPAClaimRes = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,null,null, false, null); 
                pfr.status = 'Approved';
                Database.update(pfr);
                
                List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
                PartnerFundClaim claim2 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim2',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, pfr.Core_MDF_Start_Date__c , pfr.Core_MDF_Start_Date__c,50.00, bank1.Id, false); 
                claim2.Core_MDF_Type_Txt__c ='Claim';
                claim2.Core_MDF_Currency__c='USD';
                claim2.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
                claim2.Core_MDF_Campaign_Id__c = camp.Id;
                claimList.add(claim2);
                    
                PartnerFundClaim claim3 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim3',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, pfr.Core_MDF_Start_Date__c , pfr.Core_MDF_Start_Date__c,30.00, bank1.Id, false); 
                claim3.Core_MDF_Type_Txt__c ='Claim';
                claim3.Core_MDF_Currency__c='USD';
                claim3.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
                claim3.Core_MDF_Campaign_Id__c = camp.Id;
                claim3.Core_MDF_Status__c = 'Cancelled';
                claimList.add(claim3);
                database.insert(claimList);
                
                List<core_MDF_PICReviewQuestion__c> questionList = new List<core_MDF_PICReviewQuestion__c>();
                core_MDF_PICReviewQuestion__c question1 = Core_MDF_PIC_SendEmailToClaimOwner_Test.createPICReviewQuestion(1, 'Internal Q1', 'External Q1', false);
                core_MDF_PICReviewQuestion__c question2 = Core_MDF_PIC_SendEmailToClaimOwner_Test.createPICReviewQuestion(2, 'Internal Q2', 'External Q2', false);
                questionList.addAll(new List<core_MDF_PICReviewQuestion__c>{question1, question2});
                insert questionList;

                List<Core_MDF_PIC_Review__c> reviewList = new List<Core_MDF_PIC_Review__c>();
                Core_MDF_PIC_Review__c review1 = Core_MDF_PIC_SendEmailToClaimOwner_Test.createPICReviewResult(claim2.Id, 1, 'Failed', false);
                Core_MDF_PIC_Review__c review2 = Core_MDF_PIC_SendEmailToClaimOwner_Test.createPICReviewResult(claim3.Id, 2, 'Failed', false);
                reviewList.addAll(new List<Core_MDF_PIC_Review__c>{review1, review2});
                insert reviewList;
                
                List<core_MDF_PICReviewResult__c> resultList = new List<core_MDF_PICReviewResult__c>();
                core_MDF_PICReviewResult__c result1 = Core_MDF_PIC_SendEmailToClaimOwner_Test.createPICReviewResult(review1.Id, question1.Id, 'evidence1.xls', 'No', false);
                core_MDF_PICReviewResult__c result2 = Core_MDF_PIC_SendEmailToClaimOwner_Test.createPICReviewResult(review2.Id, question2.Id, '', 'No', false);
                resultList.addAll(new List<core_MDF_PICReviewResult__c>{result1, result2});
                insert resultList;
                
                for(PartnerFundClaim c : new List<PartnerFundClaim>{claim2, claim3}) {
                    c.Core_MDF_Status__c = 'Pending Account Manager Clarification';
                    c.Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c = System.now().addDays(5);
                    c.Core_MDF_Legacy_Reminder_txt__c = Label.Core_MDF_Legacy_Reminder_1;
                }
                update new List<PartnerFundClaim>{claim2, claim3};
                
               // Core_MDF_PIC_SendEmailToClaimOwner.sendEmailtoClaimOwnerOnResubReqd(new List<Id>{ claim2.Id, claim3.Id });

                Test.stopTest();
                
    	}
    }*/

    
}