@isTest(SeeAllData=false) 
public class Core_MDF_Claim_Utility_Test {

    @TestSetup static void setupData() //validatereleaseHold()
    {
         //Test.startTest();
         
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        	bypassFunctionKeys.add('BypassCampaignBenefitValidation');
        	bypassFunctionKeys.add('Core_MDF_BudgetCapValidation');
            bypassFunctionKeys.add('Core_MDF_BypassBudgCapIUPGMValidation');
            bypassFunctionKeys.add('Core_MDF_Bypass_Manual_Share');
        	bypassFunctionKeys.add('checkAndSendClaimsForPIC');
        	bypassFunctionKeys.add('duplicateClaimCheck');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
         
            List<Core_MDF_Currency_Exchange_Rates__c> newValues = new List<Core_MDF_Currency_Exchange_Rates__c>();
            Core_MDF_Currency_Exchange_Rates__c record1 = new Core_MDF_Currency_Exchange_Rates__c();
            record1.Name= 'ZMK';
            record1.Core_MDF_Exchange_Rate__c = 0.0000850159;
            record1.Core_MDF_Market_Date__c =System.today();
            record1.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
            record1.Core_MDF_Unique_Key__c = 'ZMK'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
            newValues.add(record1);
            
            Core_MDF_Currency_Exchange_Rates__c record2 = new Core_MDF_Currency_Exchange_Rates__c();
            record2.Name= 'INR';
            record2.Core_MDF_Exchange_Rate__c = 1;
            record2.Core_MDF_Market_Date__c =System.today();
            record2.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
            record2.Core_MDF_Unique_Key__c = 'INR'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
            newValues.add(record2); 
            
            Core_MDF_Currency_Exchange_Rates__c record3 = new Core_MDF_Currency_Exchange_Rates__c();
            record3.Name= 'USD';
            record3.Core_MDF_Exchange_Rate__c = 1;
            record3.Core_MDF_Market_Date__c =System.today();
            record3.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
            record3.Core_MDF_Unique_Key__c = 'USD'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
            newValues.add(record3); 
            database.insert(newValues);
        
        List<Account> toBeUpdated = new List<Account>();
        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
		ChannelProgram coGTMCP = Core_MDF_CCP_TestDataUtility.createProgram ('Co-GTM','CoGTM', true);
        
        insert new Core_MDF_Configuration__c(Name = 'ALLOWED_PRG_FOR_RUS_NOTIF', Core_MDF_Category__c = 'Bank Document Hold Logic', Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance,Channel MDF,Co-GTM');
        // Creating Account with utility class
        List<Account> accList = new List<Account>();
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);     
		insert acc1;        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false);
        acc2.Core_MDF_Parent_Fund_Account__c = acc1.id;
        accList.add(acc2);
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, false);
        acc3.Core_MDF_Parent_Fund_Account__c = acc1.id;
        accList.add(acc3);
        Account coGTMCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('CoGTM Co-Marketing Account', coGTMCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,acc1.id, false);
        coGTMCoMarketingAccount.Core_MDF_Payment_Type_nm__c = 'Customer (Pass Through)';
        accList.add(coGTMCoMarketingAccount);
    
        Database.insert(accList);
        // Updating Accounts 
        acc1.isPartner = true;
        acc2.isPartner = true;
        acc3.isPartner = true;
        toBeUpdated.add(acc1);
        toBeUpdated.add(acc2);
        toBeUpdated.add(acc3);
        Database.update(toBeUpdated);
        
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        
        
    
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        usr.LastName = 'SysAdmUser';
        Database.insert(usr);
        
        System.runAs(usr){
            Id pmb_RecordType_CoGTM = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            Id pfa_RecordType_CoGTM = Schema.SObjectType.PartnerFundAllocation.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 200000, System.today(),System.today(), false);
        //pbm.IsIgnoreValidation = true;
        pbm.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
        insert pbm;
            
            PartnerMarketingBudget  coGTMPMB = Core_MDF_CCP_TestDataUtility.createBudget('CoGTMPMB', pmb_RecordType_CoGTM, coGTMCoMarketingAccount.Id, coGTMCP.Id, 
                                                                                         1000000, System.today().addDays(-5), System.today().addDays(5),false);
            coGTMPMB.Core_MDF_Budget_Type_Txt__c = 'Co-Engineering';
            insert coGTMPMB;
        
        //pbm.IsIgnoreValidation = true;
       // update pbm;
        
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, acc2, 30000, true);
            
            PartnerFundAllocation pfa = [Select id, Amount from PartnerFundAllocation where BudgetId =: pbm.Id and Title='Test PFA' limit 1];
            
            PartnerFundAllocation coGTMPFA = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('CoGTMPFA',coGTMPMB,coGTMCoMarketingAccount,100000.0,true);

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
            testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            testPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            
            insert testPartnerFundRequestRecord;
            
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');

            List<PartnerFundClaim> claimList1 = new List<PartnerFundClaim>();
            Test.startTest();
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim1', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 5000.00, System.today(), bank.Id, false);
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim2', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 500.00, System.today(), bank.Id, false);
            PartnerFundClaim claim3 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim3', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 500.00, System.today(), bank.Id, false);
            PartnerFundClaim claim4 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim4', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 500.00, System.today(), bank.Id, false);
            claim1.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            claim2.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            claim3.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            claim4.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            claimList1.add(claim1);
            claimList1.add(claim2);
            claimList1.add(claim3);
            claimList1.add(claim4);
            database.insert(claimList1);
          //  Core_MDF_Claim_Utility.duplicateClaimCheckOnUpdate(claimList1,)
            Test.stopTest();
            /*
            claim1.Core_MDF_Audit_Hold__c = true;
            claim1.Status= 'Submitted';
            claim1.Core_MDF_Status__c = 'Hold';
            claim1.Core_MDF_Claim_Previous_Status__c = 'Payment Due';

            update claim1;
            claimList1.add(claim1);
            List<String> releaseReason = new List<String>();
            releaseReason.add(Label.Core_MDF_Audit_Hold);
            Core_MDF_Claim_Utility.releaseHold(claimList1,releaseReason);
            
            
            PartnerFundClaim claim = [SELECT Id, Status, Core_MDF_Status__c, Core_MDF_Audit_Hold__c, Core_MDF_ESD_Hold__c, Core_MDF_Claim_Previous_Status__c FROM PartnerFundClaim where Id = :claim1.Id];
            
            System.assertEquals(false, claim.Core_MDF_Audit_Hold__c);
            //System.assertEquals('Approved', claim.Status);
            //System.assertEquals('Payment Due', claim.Core_MDF_Status__c);
            //System.assertEquals('Hold', claim.Core_MDF_Claim_Previous_Status__c);
            //Test.stopTest();
            
            List<PartnerFundClaim> claimList2 = new List<PartnerFundClaim>();
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 500.00, System.today(), bank.Id, true);
            claim2.Core_MDF_ESD_Hold__c = true;
            claim2.Status= 'Submitted';
            claim2.Core_MDF_Status__c = 'Hold';
            claim2.Core_MDF_Claim_Previous_Status__c = 'Payment Due';
            update claim2;
            claimList2.add(claim2);
            List<String> releaseReason2 = new List<String>();
            releaseReason2.add(Label.Core_MDF_ESD_Hold);
            Core_MDF_Claim_Utility.releaseHold(claimList2,releaseReason2);
            PartnerFundClaim claim02 = [SELECT Id, Status, Core_MDF_Status__c, Core_MDF_Audit_Hold__c, Core_MDF_ESD_Hold__c, Core_MDF_Claim_Previous_Status__c FROM PartnerFundClaim where Id = :claim2.Id];
            
            System.assertEquals(false, claim02.Core_MDF_Audit_Hold__c);
            //System.assertEquals('Approved', claim02.Status);
            //System.assertEquals('Payment Due', claim02.Core_MDF_Status__c);
            //System.assertEquals('Hold', claim02.Core_MDF_Claim_Previous_Status__c);
            
            List<PartnerFundClaim> claimList3 = new List<PartnerFundClaim>();
            PartnerFundClaim claim3 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 500.00, System.today(), bank.Id, true);
            claim3.Core_MDF_Audit_Hold__c = true;
            claim3.Core_MDF_ESD_Hold__c = true;
            claim3.Status= 'Submitted';
            claim3.Core_MDF_Status__c = 'Hold';
            claim3.Core_MDF_Claim_Previous_Status__c = 'Submitted';
            update claim3;
            claimList3.add(claim3);
            List<String> releaseReason3 = new List<String>();
            releaseReason3.add(Label.Core_MDF_Audit_Hold);
            Core_MDF_Claim_Utility.releaseHold(claimList3,releaseReason3);
            
            PartnerFundClaim claim03 = [SELECT Id, Status, Core_MDF_Status__c, Core_MDF_Audit_Hold__c, Core_MDF_ESD_Hold__c, Core_MDF_Claim_Previous_Status__c FROM PartnerFundClaim where Id = :claim3.Id];
            
            System.assertEquals(false, claim03.Core_MDF_Audit_Hold__c);
            //System.assertEquals('Submitted', claim03.Status);
            System.assertEquals('Hold', claim03.Core_MDF_Status__c);
            //System.assertEquals('Submitted', claim03.Core_MDF_Claim_Previous_Status__c);
            //Test.stopTest();
            List<PartnerFundClaim> claimList4 = new List<PartnerFundClaim>();
            PartnerFundClaim claim4 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 500.00, System.today(), bank.Id, true);
            claim4.Core_MDF_Audit_Hold__c = true;
            claim4.Core_MDF_ESD_Hold__c = true;
            claim4.Status= 'Submitted';
            claim4.Core_MDF_Status__c = 'Hold';
            claim4.Core_MDF_Claim_Previous_Status__c = 'Payment Due';
            update claim4;
            claimList4.add(claim4);
            List<String> releaseReason4 = new List<String>();
            releaseReason4.add(Label.Core_MDF_Audit_Hold);
            releaseReason4.add(Label.Core_MDF_ESD_Hold);
            Core_MDF_Claim_Utility.releaseHold(claimList4,releaseReason4);
            PartnerFundClaim claim04 = [SELECT Id, Status, Core_MDF_Status__c, Core_MDF_Audit_Hold__c, Core_MDF_ESD_Hold__c, Core_MDF_Claim_Previous_Status__c FROM PartnerFundClaim where Id = :claim4.Id];
            
            System.assertEquals(false, claim04.Core_MDF_Audit_Hold__c);
            System.assertEquals('Approved', claim04.Status);
            System.assertEquals('Payment Due', claim04.Core_MDF_Status__c);
            System.assertEquals('Hold', claim04.Core_MDF_Claim_Previous_Status__c);
            
            PartnerFundClaim claim05 = [SELECT Id, Status, Core_MDF_Status__c, Core_MDF_Audit_Hold__c, Core_MDF_ESD_Hold__c, Core_MDF_Claim_Previous_Status__c FROM PartnerFundClaim where Id = :claim4.Id];
            claim05.Core_MDF_Status__c = Label.Core_MDF_Status_Paid;
            update claim05;
            
            PartnerFundClaim claim06 = [SELECT Id, Status, Core_MDF_Status__c, Core_MDF_Audit_Hold__c, Core_MDF_ESD_Hold__c, Core_MDF_Claim_Previous_Status__c FROM PartnerFundClaim where Id = :claim4.Id];
            claim06.Core_MDF_Status__c = Label.Core_MDF_Status_Denied;
            update claim06;
            Test.stopTest(); */
            
        }
        
    }
    @isTest
    static void validatereleaseHold(){
        Test.starttest();
        User sysAdminUser = [SELECT Id,Email from User where LastName = 'SysAdmUser' limit 1];
        List<PartnerFundClaim> claimList1 = new List<PartnerFundClaim>();
        System.runAs(sysAdminUser){
            PartnerFundClaim claim = [SELECT Id, Status, Core_MDF_Audit_Hold__c,Core_MDF_Status__c,Core_MDF_Claim_Previous_Status__c, Core_MDF_ESD_Hold__c,Core_MDF_Payment_Hold_ind__c,Core_MDF_Criteria_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_VAT_Hold_Ind__c,Core_MDF_Bank_Doc_Hold_Ind__c,Core_MDF_Document_Hold_Ind__c, Core_MDF_Intel_Manual_Hold_Ind__c FROM PartnerFundClaim where Title = 'Test Claim1'];
            claim.Core_MDF_Audit_Hold__c = true;
            claim.Status= 'Submitted';
            claim.Core_MDF_Status__c = 'Hold';
            claim.Core_MDF_Claim_Previous_Status__c = 'Payment Due';
            claim.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c = false;
            update claim;
            claimList1.add(claim);
            List<String> releaseReason = new List<String>();
            releaseReason.add(Label.Core_MDF_Audit_Hold);
            Core_MDF_Claim_Utility.releaseHold(claimList1,releaseReason);
            System.assertEquals(false, claim.Core_MDF_Audit_Hold__c);
        }
        Test.stopTest();
    }
    
    @isTest
    static void validatereleaseHold1(){
        Test.starttest();
        User sysAdminUser = [SELECT Id,Email from User where LastName = 'SysAdmUser' limit 1];
        List<PartnerFundClaim> claimList2 = new List<PartnerFundClaim>();
        System.runAs(sysAdminUser){
            PartnerFundClaim claim2 = [SELECT Id, Status, Core_MDF_Audit_Hold__c,Core_MDF_Status__c,Core_MDF_Claim_Previous_Status__c, Core_MDF_ESD_Hold__c,Core_MDF_Payment_Hold_ind__c,Core_MDF_Criteria_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_VAT_Hold_Ind__c,Core_MDF_Bank_Doc_Hold_Ind__c,Core_MDF_Document_Hold_Ind__c, Core_MDF_Intel_Manual_Hold_Ind__c FROM PartnerFundClaim where Title = 'Test Claim1'];
            claim2.Core_MDF_ESD_Hold__c = true;
            claim2.Status= 'Submitted';
            claim2.Core_MDF_Status__c = 'Hold';
            claim2.Core_MDF_Claim_Previous_Status__c = 'Payment Due';
            claim2.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c = false;
            update claim2;
            claimList2.add(claim2);
            List<String> releaseReason2 = new List<String>();
            releaseReason2.add(Label.Core_MDF_ESD_Hold);
            Core_MDF_Claim_Utility.releaseHold(claimList2,releaseReason2);
            List<String> releaseReason = new List<String>();
            releaseReason.add(Label.Core_MDF_Audit_Hold);
            Core_MDF_Claim_Utility.releaseHold(claimList2,releaseReason);
            System.assertEquals(false, claim2.Core_MDF_Audit_Hold__c);
        }
        Test.stopTest();
    }
    
    @isTest
    static void validatereleaseHold2(){
        Test.starttest();
        User sysAdminUser = [SELECT Id,Email from User where LastName = 'SysAdmUser' limit 1];
        List<PartnerFundClaim> claimList3 = new List<PartnerFundClaim>();
        System.runAs(sysAdminUser){
            PartnerFundClaim claim3 = [SELECT Id, Status, Core_MDF_Audit_Hold__c,Core_MDF_Status__c,Core_MDF_Claim_Previous_Status__c, Core_MDF_ESD_Hold__c,Core_MDF_Payment_Hold_ind__c,Core_MDF_Criteria_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_VAT_Hold_Ind__c,Core_MDF_Bank_Doc_Hold_Ind__c,Core_MDF_Document_Hold_Ind__c, Core_MDF_Intel_Manual_Hold_Ind__c FROM PartnerFundClaim where Title = 'Test Claim1'];
            claim3.Core_MDF_Audit_Hold__c = true;
            claim3.Core_MDF_ESD_Hold__c = true;
            claim3.Status= 'Submitted';
            claim3.Core_MDF_Status__c = 'Hold';
            claim3.Core_MDF_Claim_Previous_Status__c = 'Submitted';
            claim3.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c = true;
            update claim3;
            claimList3.add(claim3);
            List<String> releaseReason3 = new List<String>();
            releaseReason3.add(Label.Core_MDF_Audit_Hold);
            Core_MDF_Claim_Utility.releaseHold(claimList3,releaseReason3);
            List<String> releaseReason = new List<String>();
            releaseReason.add(Label.Core_MDF_Audit_Hold);
            Core_MDF_Claim_Utility.releaseHold(claimList3,releaseReason);
            System.assertEquals(false, claim3.Core_MDF_Audit_Hold__c);
        }
        Test.stopTest();

    }
    
    @isTest
    static void validatereleaseHold3(){
        Test.starttest();
        User sysAdminUser = [SELECT Id,Email from User where LastName = 'SysAdmUser' limit 1];
        List<PartnerFundClaim> claimList4 = new List<PartnerFundClaim>();
        List<PartnerFundClaim> claimList5 = new List<PartnerFundClaim>();
        System.runAs(sysAdminUser){
            PartnerFundClaim claim4 = [SELECT Id, Status, Core_MDF_Audit_Hold__c,Core_MDF_Status__c,Core_MDF_Claim_Previous_Status__c, Core_MDF_ESD_Hold__c,Core_MDF_Payment_Hold_ind__c,Core_MDF_Criteria_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_VAT_Hold_Ind__c,Core_MDF_Bank_Doc_Hold_Ind__c,Core_MDF_Document_Hold_Ind__c, Core_MDF_Intel_Manual_Hold_Ind__c FROM PartnerFundClaim where Title = 'Test Claim1'];
            claim4.Core_MDF_Audit_Hold__c = true;
            claim4.Core_MDF_ESD_Hold__c = true;
            claim4.Core_MDF_Payment_Hold_ind__c = true;
            claim4.Core_MDF_Criteria_Hold_Ind__c = true;
            claim4.Core_MDF_Intel_Manual_Hold_Ind__c = true;
            claim4.Core_MDF_Member_Manual_Hold_Ind__c = true;
            claim4.Core_MDF_VAT_Hold_Ind__c = true;
            claim4.Core_MDF_Bank_Doc_Hold_Ind__c = true;
            claim4.Core_MDF_Document_Hold_Ind__c = true;
            claim4.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c = true;
            claim4.Status= 'Submitted';
            claim4.Core_MDF_Status__c = 'Hold';
            claim4.Core_MDF_Claim_Previous_Status__c = 'Payment Due';
            update claim4;
            claimList4.add(claim4);
            List<String> releaseReason4 = new List<String>();
            releaseReason4.add(Label.Core_MDF_Audit_Hold);
            releaseReason4.add(Label.Core_MDF_ESD_Hold);
            releaseReason4.add(Label.Core_MDF_Payment_Hold);
            releaseReason4.add(Label.Core_MDF_Intel_Manual_Hold);
            releaseReason4.add(Label.Core_MDF_Criteria_Hold);
            releaseReason4.add(Label.Core_MDF_Member_Manual_Hold);
            releaseReason4.add(Label.Core_MDF_VAT_Hold);
            releaseReason4.add(Label.Core_MDF_Bank_Document_Hold);
            releaseReason4.add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Document_Hold'));
            Core_MDF_Claim_Utility.releaseHold(claimList4,releaseReason4);
            System.assertEquals(false, claim4.Core_MDF_Audit_Hold__c);
            
            claim4.Core_MDF_Status__c = Label.Core_MDF_Status_Paid;
            update claim4;
            /*claim4.Core_MDF_Status__c = Label.Core_MDF_Status_Denied;
            update claim4;*/
            PartnerFundClaim claim5 = [SELECT Id, Status, Core_MDF_Audit_Hold__c,Core_MDF_Status__c,Core_MDF_Claim_Previous_Status__c, Core_MDF_ESD_Hold__c,Core_MDF_Payment_Hold_ind__c,Core_MDF_Criteria_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_VAT_Hold_Ind__c,Core_MDF_Bank_Doc_Hold_Ind__c,Core_MDF_Document_Hold_Ind__c, Core_MDF_Intel_Manual_Hold_Ind__c FROM PartnerFundClaim where Title = 'Test Claim2'];
            claim5.Core_MDF_Audit_Hold__c = true;
            claim5.Core_MDF_ESD_Hold__c = true;
            claim5.Core_MDF_Payment_Hold_ind__c = true;
            claim5.Core_MDF_Criteria_Hold_Ind__c = true;
            claim5.Core_MDF_Intel_Manual_Hold_Ind__c = true;
            claim5.Core_MDF_Member_Manual_Hold_Ind__c = true;
            claim5.Core_MDF_VAT_Hold_Ind__c = true;
            claim5.Core_MDF_Bank_Doc_Hold_Ind__c = true;
            claim5.Core_MDF_Document_Hold_Ind__c = true;
            claim5.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c = true;
            claim5.Status= 'Submitted';
            claim5.Core_MDF_Status__c = 'Hold';
            claim5.Core_MDF_Claim_Previous_Status__c = 'Payment Due';
            update claim5;
            claimList5.add(claim5);
            List<String> releaseReason5 = new List<String>();
            releaseReason5.add(Label.Core_MDF_Audit_Hold);
            releaseReason5.add(Label.Core_MDF_ESD_Hold);
            releaseReason5.add(Label.Core_MDF_Payment_Hold);
            releaseReason5.add(Label.Core_MDF_Intel_Manual_Hold);
            releaseReason5.add(Label.Core_MDF_Criteria_Hold);
            releaseReason5.add(Label.Core_MDF_Member_Manual_Hold);
            releaseReason5.add(Label.Core_MDF_VAT_Hold);
            releaseReason5.add(Label.Core_MDF_Bank_Document_Hold);
            releaseReason5.add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Document_Hold'));
            Core_MDF_Claim_Utility.releaseHold(claimList5,releaseReason5);
            System.assertEquals(false, claim5.Core_MDF_Audit_Hold__c);
            
            claim5.Core_MDF_Status__c = Label.Core_MDF_Status_Denied;
            update claim5;
        }
        Test.stopTest();
    }
   /*@isTest
    public static void  duplicateClaimCheckOnUpdateTest(){
        Test.startTest();
           List<PartnerFundClaim> claimList1 =[SELECT Id, Status, Core_MDF_Audit_Hold__c,Core_MDF_Status__c,Core_MDF_Claim_Previous_Status__c, Core_MDF_ESD_Hold__c,Core_MDF_Payment_Hold_ind__c,Core_MDF_Criteria_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_VAT_Hold_Ind__c,Core_MDF_Bank_Doc_Hold_Ind__c,Core_MDF_Document_Hold_Ind__c, Core_MDF_Intel_Manual_Hold_Ind__c FROM PartnerFundClaim];
            Map<Id,PartnerFundClaim> oldClaimMap=new Map<Id,PartnerFundClaim>();
                   PartnerFundClaim claim4=claimList1.get(0);
        oldClaimMap.put(claim4.id,claim4);
      
               Id IPARecTypeId = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName().get(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Client_Co_Marketing_Fund')).getRecordTypeId();   
            Core_MDF_CCP_TestDataUtility.createClaim('testdev',IPARecTypeId,' ','7/15/2020','7/20/2020','20.0','7/15/2021',' ',true);
        PartnerFundClaim claim=[select amount,id from PartnerFundClaim where Title='testdev'];
       
      Core_MDF_Claim_Utility.duplicateClaimCheckOnUpdate(claimList1, oldClaimMap);

            Test.stopTest();
    }*/
    @isTest
    public static void updateStatusToSubmittedTest(){
        test.startTest();
        List<PartnerFundClaim> claims=[SELECT Id, Status,Core_MDF_Ad_Run_End_Date__c,Core_MDF_Program__c,Core_MDF_To_Be_Audited_Ind__c,Core_MDF_Currency__c,Core_MDF_Audit_Adjustment_Amount__c,Core_MDF_Taxes_Local__c,Core_MDF_OtherCostsnotReimbursable_Local__c,Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Invoice_Date__c,Core_MDF_Invoice_Number__c,Core_MDF_Bank__c,Core_MDF_Ad_Run_Start_Date__c,Core_MDF_Media_Vehicle__c,Core_MDF_AuditSelectionInProgress__c, Core_MDF_Status__c,Core_MDF_Type_Txt__c, Core_MDF_Audit_Hold__c, Core_MDF_ESD_Hold__c, Core_MDF_Claim_Previous_Status__c FROM PartnerFundClaim limit 5];
        Map<Id,PartnerFundClaim> inputClaimMap=new Map<Id,PartnerFundClaim>();
        for(PartnerFundClaim claim:claims){
             inputClaimMap.put(claim.id,claim);
        }
        Core_MDF_Claim_Utility.updateStatusToSubmitted(inputClaimMap, claims);
        //Core_MDF_Claim_Utility.sendClaimsToAudit(claims,inputClaimMap);
        test.stopTest();
    }
    @isTest
    public static void duplicateClaimCheckOnUpdateTest(){
        test.startTest();
        List<PartnerFundClaim> claims=[SELECT Id, Status,Core_MDF_Country_Location_nm__c,Core_MDF_AccountCompany__c,Core_MDF_Activity_Types__c,Core_MDF_Ad_Run_End_Date__c,Core_MDF_To_Be_Audited_Ind__c,Core_MDF_Currency__c,Core_MDF_Audit_Adjustment_Amount__c,Core_MDF_Taxes_Local__c,Core_MDF_OtherCostsnotReimbursable_Local__c,Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Invoice_Date__c,Core_MDF_Invoice_Number__c,Core_MDF_Bank__c,Core_MDF_Ad_Run_Start_Date__c,Core_MDF_Media_Vehicle__c,Core_MDF_AuditSelectionInProgress__c, Core_MDF_Status__c,Core_MDF_Type_Txt__c, Core_MDF_Audit_Hold__c, Core_MDF_ESD_Hold__c, Core_MDF_Claim_Previous_Status__c FROM PartnerFundClaim limit 5];
        Map<Id,PartnerFundClaim> inputClaimMap=new Map<Id,PartnerFundClaim>();
        for(PartnerFundClaim claim:claims){
             inputClaimMap.put(claim.id,claim);
        }
        Core_MDF_PFC_Sharing.shareClaimToInternalUsers(claims);
        Core_MDF_Claim_Utility.duplicateClaimCheckOnUpdate(claims,inputClaimMap);
        test.stopTest();
    }
    @isTest
    public static void calculateClaimFieldsforUpdateTest(){
        test.startTest();
          List<PartnerFundClaim> claims=[SELECT Id, Status,Core_MDF_Country_Location_nm__c,Core_MDF_Reimbursable_Transaction_Amount__c,Core_MDF_Exchange_rate__c,Core_MDF_Reimbursement_Percent__c,Core_MDF_AccountCompany__c,Core_MDF_Activity_Types__c,Core_MDF_Ad_Run_End_Date__c,Core_MDF_To_Be_Audited_Ind__c,Core_MDF_Currency__c,Core_MDF_Audit_Adjustment_Amount__c,Core_MDF_Taxes_Local__c,Core_MDF_OtherCostsnotReimbursable_Local__c,Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Invoice_Date__c,Core_MDF_Invoice_Number__c,Core_MDF_Bank__c,Core_MDF_Ad_Run_Start_Date__c,Core_MDF_Media_Vehicle__c,Core_MDF_AuditSelectionInProgress__c, Core_MDF_Status__c,Core_MDF_Type_Txt__c, Core_MDF_Audit_Hold__c, Core_MDF_ESD_Hold__c, Core_MDF_Claim_Previous_Status__c FROM PartnerFundClaim limit 5];	
        Map<Id,PartnerFundClaim> inputClaimMap=new Map<Id,PartnerFundClaim>();
        for(PartnerFundClaim claim:claims){
             inputClaimMap.put(claim.id,claim);
        }
        Core_MDF_Claim_Utility.calculateClaimFieldsforUpdate(inputClaimMap,inputClaimMap,claims);
        test.stopTest();
    }

	@isTest 
    static void cogtmClaim(){
        
                User usr = [Select Id, lastName from User where lastName = 'SysAdmUser' limit 1];

        
        System.runAs(usr){ 
            test.startTest();
	
            ChannelProgram coGTMCP = [Select Id from ChannelProgram where Name = 'Co-GTM' limit 1];
            Id pmb_RecordType_CoGTM = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            Id pfa_RecordType_CoGTM = Schema.SObjectType.PartnerFundAllocation.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            Id campaign_RecordType_CoGTM = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            Id pfr_RecordType_CoGTM = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            Id pfc_RecordType_CoGTM = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();

            Account coGTMCoMarketingAccount = [SELECT Id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c FROM Account WHERE Name= 'CoGTM Co-Marketing Account'];
            
            PartnerMarketingBudget  coGTMPMB = [Select Id from PartnerMarketingBudget where Title = 'CoGTMPMB'];
            
            PartnerFundAllocation coGTMPFA = [Select Id from PartnerFundAllocation where Title = 'CoGTMPFA']; 

            Campaign coGTMCampaign = new Campaign();
            coGTMCampaign.Name = 'Test CoGTM Camp';
            coGTMCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'Co-Engineering';
            coGTMCampaign.Core_MDF_Proposal_Based_Ind__c = true;
            coGTMCampaign.Core_MDF_Program__c = 'CoGTM';
            coGTMCampaign.Status = 'Draft';
            coGTMCampaign.Core_MDF_Account__c = coGTMCoMarketingAccount.id;
            coGTMCampaign.RecordTypeId = campaign_RecordType_CoGTM;
            coGTMCampaign.StartDate = System.today().addDays(-5);
            coGTMCampaign.EndDate = System.today().addDays(15);
            coGTMCampaign.Core_MDF_Reimbursement_Amt__c = 1000200;
            coGTMCampaign.Core_MDF_Activity_Category_Type__c = 'Innovation ->Engineering';
            Database.insert(coGTMCampaign);
            
            PartnerFundRequest coGTMPFR = new PartnerFUndRequest();
            coGTMPFR.CampaignId=coGTMCampaign.id;
            coGTMPFR.RecordTypeId = pfr_RecordType_CoGTM;
            coGTMPFR.ChannelPartnerId = coGTMCoMarketingAccount.id;
            coGTMPFR.Core_MDF_ActivityCategory__c='Innovation';
            coGTMPFR.Core_MDF_Activity_Types__c='Engineering';
            coGTMPFR.Core_MDF_Start_Date__c=System.today().addDays(-5);
            coGTMPFR.Core_MDF_End_Date__c =System.today().addDays(2);
            coGTMPFR.Title ='Test CoGTM PFR';
            coGTMPFR.Status = 'Draft';
            coGTMPFR.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            coGTMPFR.RequestedAmount = 1000200;
            coGTMPFR.AllocationId = coGTMPFA.Id;
            coGTMPFR.BudgetId = coGTMPMB.Id;
            Database.insert(coGTMPFR);
                        
			try { Database.update(coGTMCampaign); } catch (Exception e) {}

            List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
            PartnerFundClaim coGTMPFC = new PartnerFundClaim();
            coGTMPFC.RequestId = coGTMPFR.Id;
            coGTMPFC.RecordTypeId = pfc_RecordType_CoGTM;
            coGTMPFC.amount = 50;
            coGTMPFC.Core_MDF_Status__c = 'Submitted';
            coGTMPFC.Core_MDF_Invoice_Date__c = System.today().addDays(-4);
            coGTMPFC.Core_MDF_Invoice_Number__c = 'INV1686';
            coGTMPFC.Core_MDF_Media_Vehicle__c = 'Test';
            coGTMPFC.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
            coGTMPFC.Core_MDF_Taxes_Local__c = 12;
            coGTMPFC.Core_MDF_Total_Invoice_Amount_Local__c = 50;
            coGTMPFC.Core_MDF_Ad_Run_Start_Date__c = System.today().addDays(-4);
            coGTMPFC.Core_MDF_Ad_Run_End_Date__c = System.today().addDays(-4);
            coGTMPFC.Title = 'Test CoGTM PFC';
            coGTMPFC.Core_MDF_Currency__c = 'USD';        
            //coGTMPFC.Core_MDF_Bank__c = coGTMBank.id;
            coGTMPFC.Description = 'Test';
            //coGTMPFC.Core_MDF_Country_Location_nm__c= 'BRAZIL';
            //coGTMPFC.Core_MDF_Payment_Type_nm__c = 'Customer (Pass Through)';
           	coGTMPFC.Core_MDF_Reimbursable_Transaction_Amount__c=100;
            //Database.insert(coGTMPFC);
            pfcList.add(coGTMPFC);
            Core_MDF_PFC_Sharing.shareClaimToInternalUsers(pfcList);

        }
    }
}