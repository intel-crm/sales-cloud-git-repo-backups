@isTest(SeeAllData=false)
public class Core_MDF_CloseActivity_Test {

     @TestSetUp
    static void createTestData(){

        //Test.startTest();
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
       
        PartnerMarketingBudget testBudget = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                      acc2.id, cp.Id , 10000 , System.today() - 25 , System.today() + 45 , 
                                                                                      false);
        testBudget.IsIgnoreValidation = true;
        insert testBudget;
        testBudget.Core_MDF_Budget_Status__c = 'Released';
        update testBudget;
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', 
                                                                    Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                    'Client CoMarketing Fund', System.today().addDays(-2), 
                                                                    System.today().addDays(346), 10000, 'Always Connected PC', 
                                                                    acc2.Id,'Desktop', true); 
        
        PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                                                testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                'Member Participation in Third-Party Event','Draft',false);
        testPartnerFundRequestRecord.RequestedAmount = 250;
        testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Planned';
        testPartnerFundRequestRecord.Amount = 0;
        insert testPartnerFundRequestRecord;

        PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                                                testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                'Member Participation in Third-Party Event','Draft',false);
        pfr1.RequestedAmount = 250;
        pfr1.Core_MDF_Fund_Request_Status__c = 'Planned';
        pfr1.Title = 'TEST1';
        date sdate = date.today();
        sdate = sdate.addDays(2);
        pfr1.Core_MDF_Start_Date__c = sdate;
        pfr1.Core_MDF_End_Date__c = sdate;
        insert pfr1;
        
        /*PartnerFundRequest pfr2 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                                                testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                'Member Participation in Third-Party Event','Draft',false);
        pfr2.RequestedAmount = 250;
        pfr2.Core_MDF_Fund_Request_Status__c = 'Planned';
        pfr2.Title = 'TEST2';
        insert pfr2;*/
        
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund', FALSE,'1231231230');
        bank.Core_MDF_Program__c = 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund';
        bank.Core_MDF_Bank_Status__c = 'Active';
        insert(bank);
        Test.startTest();
        Core_MDF_Account_Bank_Mapping__c abmCCF1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id, bank.Id, FALSE);
        abmCCF1.Core_MDF_Active_ind__c = true;
        insert(abmCCF1);
        
        PartnerFundClaim pfc =  Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 100.00, System.today(), bank.Id, false);    
        pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
        pfc.Title = 'Test Claim 1' ;
        pfc.RequestId = testPartnerFundRequestRecord.Id;
        pfc.Core_MDF_Total_Invoice_Amount_Local__c = 400;                            
        pfc.Core_MDF_Status__c = 'Submitted';
        pfc.Description = 'Test PFC ';
        pfc.Core_MDF_Ad_Run_Start_Date__c = System.today();
        pfc.Core_MDF_Ad_Run_End_Date__c = System.today();
        pfc.Core_MDF_Invoice_Date__c = System.today();
        pfc.Core_MDF_Invoice_Number__c = '1121';
        pfc.Core_MDF_Media_Vehicle__c = 'test';
        pfc.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
        pfc.Core_MDF_Taxes_Local__c = 0;
        pfc.Core_MDF_Currency__c = 'USD';
        pfc.Core_MDF_Exchange_rate__c = 1;
        pfc.Core_MDF_Bank__c = bank.Id;
        insert pfc;
        Test.stopTest();
    }

    @isTest 
    static void runCloseActivityTest(){
        boolean hasAccess = false;
	Test.startTest();  
        PermissionSet accountManager = [SELECT Id FROM permissionset where name = 'Core_MDF_CCP_Internal_CCF_Account_Manager' limit 1];
        PermissionSet claimcaseReviewerManagerPS = [SELECT Id FROM permissionset WHERE name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager' LIMIT 1];
        //Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];

        // Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        Database.insert(usr1);
		
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = accountManager.Id, AssigneeId = usr1.Id);
        Database.upsert(psa);
        
        PermissionSetAssignment psa2 = new PermissionSetAssignment (PermissionSetId = claimcaseReviewerManagerPS.Id, AssigneeId = usr1.Id);
        Database.upsert(psa2);
       	System.runAs(usr1){
           
            // Call user eligibility method
           Map<string,List<string>> permissionsetsMap = new Map<string,List<string>>();
           string permissionSetName = Label.Core_MDF_Close_Activity_Allowed_Roles;
           List<String> permissionSets = new List<String>();

           permissionSets = permissionSetName.split(',');
           permissionsetsMap.put('closeactivity', permissionSets);
		   
           
           hasAccess = Core_MDF_CloseActivity.userEligibilitytoIncloseActivity(permissionsetsMap);
           
           Core_MDF_CloseActivity.activityCloseWrapper wrapper = new Core_MDF_CloseActivity.activityCloseWrapper();
             
           PartnerFundRequest pfrtest = [select id from PartnerFundRequest where title =: 'test' and recordtypeid =: Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF];
           wrapper = Core_MDF_CloseActivity.checkActivityEligibiltyForClose(pfrtest.id);
           
           PartnerFundClaim pfc2 = [select id from PartnerFundClaim where title =: 'Test Claim 1' and RecordTypeId =: Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF and RequestId =: pfrtest.id];
           pfc2.Core_MDF_Status__c = 'Paid';
           update pfc2;
           Test.stopTest();
		   /* Core_MDF_CloseActivity.activityCloseWrapper wrapper1 = new Core_MDF_CloseActivity.activityCloseWrapper();
           wrapper1 = Core_MDF_CloseActivity.checkActivityEligibiltyForClose(pfrtest.id);
           
           PartnerFundRequest pfrtest1 = [select id,Core_MDF_Start_Date__c from PartnerFundRequest where title =: 'TEST1' and recordtypeid =: Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF];
           wrapper = Core_MDF_CloseActivity.checkActivityEligibiltyForClose(pfrtest1.id);
           
           PartnerFundClaim pfc3 = [select id from PartnerFundClaim where title =: 'Test Claim 1' and RecordTypeId =: Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF and RequestId =: pfrtest.id];
           pfc3.Core_MDF_Status__c = 'Payment Due';
           update pfc3;
           wrapper = Core_MDF_CloseActivity.checkActivityEligibiltyForClose(pfrtest.id); */
           
           
           
        }
        
        System.assert(hasAccess == true);
    }

    @isTest 
    static void runCloseActivityTest2(){
        boolean hasAccess = false;
		test.startTest();
        PermissionSet accountManager = [SELECT Id FROM permissionset where name = 'Core_MDF_CCP_Internal_CCF_Account_Manager' limit 1];
        PermissionSet claimcaseReviewerManagerPS = [SELECT Id FROM permissionset WHERE name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager' LIMIT 1];
        //Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];

        // Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        Database.insert(usr1);
		
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = accountManager.Id, AssigneeId = usr1.Id);
        Database.upsert(psa);
        
        PermissionSetAssignment psa2 = new PermissionSetAssignment (PermissionSetId = claimcaseReviewerManagerPS.Id, AssigneeId = usr1.Id);
        Database.upsert(psa2);
       	System.runAs(usr1){
           
            // Call user eligibility method
           Map<string,List<string>> permissionsetsMap = new Map<string,List<string>>();
           string permissionSetName = Label.Core_MDF_Close_Activity_Allowed_Roles;
           List<String> permissionSets = new List<String>();

           permissionSets = permissionSetName.split(',');
           permissionsetsMap.put('closeactivity', permissionSets);
		   
           
           hasAccess = Core_MDF_CloseActivity.userEligibilitytoIncloseActivity(permissionsetsMap);
           
           Core_MDF_CloseActivity.activityCloseWrapper wrapper = new Core_MDF_CloseActivity.activityCloseWrapper();
               
           /* PartnerFundRequest pfrtest = [select id from PartnerFundRequest where title =: 'test' and recordtypeid =: Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF];
           wrapper = Core_MDF_CloseActivity.checkActivityEligibiltyForClose(pfrtest.id);
           Test.startTest();
           PartnerFundClaim pfc2 = [select id from PartnerFundClaim where title =: 'Test Claim 1' and RecordTypeId =: Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF and RequestId =: pfrtest.id];
           pfc2.Core_MDF_Status__c = 'Paid';
           update pfc2;
             
		   Core_MDF_CloseActivity.activityCloseWrapper wrapper1 = new Core_MDF_CloseActivity.activityCloseWrapper();
           wrapper1 = Core_MDF_CloseActivity.checkActivityEligibiltyForClose(pfrtest.id); */
           //Test.startTest();
           PartnerFundRequest pfrtest1 = [select id,Core_MDF_Start_Date__c from PartnerFundRequest where title =: 'TEST1' and recordtypeid =: Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF];
           wrapper = Core_MDF_CloseActivity.checkActivityEligibiltyForClose(pfrtest1.id);
           
           //PartnerFundRequest pfrtest2 = [select id,Core_MDF_Start_Date__c from PartnerFundRequest where title =: 'TEST2' and recordtypeid =: Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF];
           //wrapper = Core_MDF_CloseActivity.checkActivityEligibiltyForClose(pfrtest2.id);
           Test.stopTest();
           /* PartnerFundClaim pfc3 = [select id from PartnerFundClaim where title =: 'Test Claim 1' and RecordTypeId =: Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF and RequestId =: pfrtest1.id];
           pfc3.Core_MDF_Status__c = 'Payment Due';
           update pfc3;
           wrapper = Core_MDF_CloseActivity.checkActivityEligibiltyForClose(pfrtest1.id); */
           
           
           
        }
        
        System.assert(hasAccess == true);
    }
}