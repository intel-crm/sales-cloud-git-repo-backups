//Main Class: Core_MDF_Batch_LinkClaimPayments
@isTest
public class Core_MDF_Batch_LinkClaimPaymentsTest {
    
    @TestSetup static void setUpData(){
        
        UserRole adminRole = [SELECT Id, Name FROM UserRole WHERE Name = 'Admin' LIMIT 1];
        
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
            PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_IPA_TestDataUtility.budgetIPA_ProposalBased_Record_Type,acc2.Id,cp.Id,200000,System.today().addDays(-20),System.today().addDays(300), false);
            budget.Core_MDF_Budget_Type_Txt__c='Proposal I MDF';
            Database.insert(budget);
            
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('allocation',budget,acc2, 100000,true);
            
            Campaign camp = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test IPA Camp',acc2.Id, System.today().addDays(-2), System.today().addDays(300),budgetType,
                                                                               1234.00, 'AFGHANISTAN','Consumer',null,'Planned', false);
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
            pfr.Core_MDF_Is_Outcome_Based_Ind__c = true;
            pfr.AllocationId=pfa.id;
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
            //Database.update(pfr);
            
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
            
            Core_MDF_Configuration__c mdfRecTypes = new Core_MDF_Configuration__c();
            mdfRecTypes.name='ALLOWED_PRG_FOR_RUS_NOTIF';
            mdfRecTypes.Core_MDF_Value__c='Retail Marketing Funds,Intel Partner Alliance,Channel MDF,Co-GTM';
            database.Insert(mdfRecTypes);
            
            PartnerFundClaim claimIPA =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim',Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Account_Based').getRecordTypeId(), pfr.Id, System.today(), System.today(),5.00, null, false); 
            claimIPA.Core_MDF_Type_Txt__c ='Claim';
            claimIPA.Core_MDF_Currency__c='USD';
            claimIPA.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
            //claimIPA.Core_MDF_VAT_Opt_In__c = 'Service Invoice to Intel (VAT may apply)';
            claimIPA.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claimIPA.Core_MDF_VAT_Hold_Ind__c = true;
            claimIPA.Core_MDF_Paid_By_Payment_Type_nm__c = 'Distributor (Credit Memo)';
            claimIPA.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            claimIPA.Core_MDF_Quantity_to_Date_Nbr__c = 12;
            claimIPA.Core_MDF_Budget_Type_Options_Nm__c = null;
            claimIPA.Core_MDF_Status__c = 'Hold';
            insert claimIPA;
            
            // Create test data for Core_MDF_Activity_Attributes__c
            Core_MDF_Activity_Outcome__c activityOutcome = new Core_MDF_Activity_Outcome__c(
                Core_MDF_Activity_Id__c	 = pfr.Id,
                Core_MDF_Outcome_Metric_nm__c = 'Revenue - Billings',
                Core_MDF_Goal_Value_nbr__c = 200,
                Core_MDF_Baseline_Value_nbr__c = 190,
                Core_MDF_Baseline_Period_nm__c = 'Same period as this campaign, one year before',
                Core_MDF_Active_Ind__c = true
            );
            insert activityOutcome;
        }
    }
    
    @isTest static void testBatchLinksClaimsToPayments() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test IPA Account' LIMIT 1];
        PartnerFundClaim claim = [SELECT Id, Core_MDF_Claim_Id__c FROM PartnerFundClaim LIMIT 1];
        
        // Create a Payment record
        Core_MDF_Payment__c payment = new Core_MDF_Payment__c();
        payment.Core_MDF_Payment_Status_Txt__c = 'Pending Payment';
        payment.Core_MDF_Account_Id__c = acc.Id;
        insert payment;
        
        // Link claim to payment
        claim.Core_MDF_Payment_Id__c = payment.Id;
        update claim;
        
        Test.startTest();
        Core_MDF_Batch_LinkClaimPayments batch = new Core_MDF_Batch_LinkClaimPayments();
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // Verify junction record was created
        List<Core_MDF_Claim_Payment_Link__c> junctionRecords = [
            SELECT Id, Core_MDF_Claim_Id__c, Core_MDF_Payment_Id__c, Core_MDF_Unique_Key_Id__c
            FROM Core_MDF_Claim_Payment_Link__c
            WHERE Core_MDF_Payment_Id__c = :payment.Id
        ];
        
        Assert.areEqual(1, junctionRecords.size(), 'One junction record should be created');
        Assert.areEqual(claim.Id, junctionRecords[0].Core_MDF_Claim_Id__c, 'Claim ID should match');
        Assert.areEqual(payment.Id, junctionRecords[0].Core_MDF_Payment_Id__c, 'Payment ID should match');
        Assert.isNotNull(junctionRecords[0].Core_MDF_Unique_Key_Id__c, 'Unique key should be generated');
    }
    
    @isTest static void testBatchLinksMultipleClaimsToSinglePayment() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test IPA Account' LIMIT 1];
        
        // Create a Payment record
        Core_MDF_Payment__c payment = new Core_MDF_Payment__c();
        payment.Core_MDF_Payment_Status_Txt__c = 'Pending Payment';
        payment.Core_MDF_Account_Id__c = acc.Id;
        insert payment;
        
        // Create multiple claims linked to the same payment
        List<PartnerFundClaim> claims = [
            SELECT Id FROM PartnerFundClaim LIMIT 2
        ];
        
        for (PartnerFundClaim claim : claims) {
            claim.Core_MDF_Payment_Id__c = payment.Id;
        }
        update claims;
        
        Test.startTest();
        Core_MDF_Batch_LinkClaimPayments batch = new Core_MDF_Batch_LinkClaimPayments();
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // Verify junction records were created for all claims
        List<Core_MDF_Claim_Payment_Link__c> junctionRecords = [
            SELECT Id, Core_MDF_Claim_Id__c FROM Core_MDF_Claim_Payment_Link__c
            WHERE Core_MDF_Payment_Id__c = :payment.Id
        ];
        
        Assert.areEqual(claims.size(), junctionRecords.size(), 'Junction records should be created for all claims');
    }
    
    @isTest static void testBatchOnlyProcessesPaymentsFromLast90Days() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test IPA Account' LIMIT 1];
        PartnerFundClaim claim = [SELECT Id FROM PartnerFundClaim LIMIT 1];
        
        // Create a Payment record (old payment - outside 90 days)
        Core_MDF_Payment__c oldPayment = new Core_MDF_Payment__c();
        oldPayment.Core_MDF_Payment_Status_Txt__c = 'Pending Payment';
        oldPayment.Core_MDF_Account_Id__c = acc.Id;
        insert oldPayment;
        
        // Update CreatedDate to be outside the 90-day window by using direct database update
        Test.setCreatedDate(oldPayment.Id, System.now().addDays(-100));
        
        // Create a recent Payment record
        Core_MDF_Payment__c recentPayment = new Core_MDF_Payment__c();
        recentPayment.Core_MDF_Payment_Status_Txt__c = 'Pending Payment';
        recentPayment.Core_MDF_Account_Id__c = acc.Id;
        insert recentPayment;
        
        // Link claim to old payment only
        claim.Core_MDF_Payment_Id__c = oldPayment.Id;
        update claim;
        
        Test.startTest();
        Core_MDF_Batch_LinkClaimPayments batch = new Core_MDF_Batch_LinkClaimPayments();
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // Verify no junction record was created for old payment
        List<Core_MDF_Claim_Payment_Link__c> junctionRecords = [
            SELECT Id FROM Core_MDF_Claim_Payment_Link__c
            WHERE Core_MDF_Payment_Id__c = :oldPayment.Id
        ];
        
        Assert.areEqual(0, junctionRecords.size(), 'No junction record should be created for old payments');
    }
}