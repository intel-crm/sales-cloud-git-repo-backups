@IsTest
public class Core_MDF_SuperClaimStatusUpdateBatchTest {

    // Store Id for reuse across tests
    private static Id SUPER_CLAIM_ID;

    @testSetup
    static void setupData() {

        /* ---------- Custom Metadata Utility ---------- */
        Core_MDF_CCP_Custom_Metadata_Utility__c util =
            new Core_MDF_CCP_Custom_Metadata_Utility__c(
                Name = 'Core_MDF_SuperClaimStatusUpdateBatch',
                Core_MDF_Field_2_txt__c = 'Submitted,Approved,Pending Payment',
                Core_MDF_Field_3_txt__c = 
                    'Submitted,Submitted,' +
                    'Approved,Approved,' +
                    'Pending Payment,Pending Payment',
                Core_MDF_Field_4_txt__c = 'Pending Payment',
                Core_MDF_Field_5_txt__c = 'Approved',
                Core_MDF_Number_1_num__c = 50,
                Core_MDF_Value__c = '10'
            );
        insert util;
        
        List<User> listUser = new List<User>();
        
        User sysAdmUsr = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdmUsr.LastName = 'System Adm';
        listUser.add(sysAdmUsr);
        
		system.runAs(sysAdmUsr){
        /* ---------- Super Claim (Parent) ---------- */
         Id opidRecType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Account acc2 = new Account(Name = 'opidAcc01', RecordTypeId = opidRecType);
          insert acc2;
        //User Usr1 =[Select id from user where email = 'test1@example.com'];
        //Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
        //Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1241241240' limit 1];
        
        Core_MDF_Bank__c bank1 = Core_MDF_CCP_TestDataUtility.createBank(acc2.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231230');
        bank1.Core_MDF_Bank_Status__c='Active';
        
        //PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];    
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-15), System.today().addDays(15), 10000, 'Always Connected PC', acc2.Id,'Desktop', false);
        camp.Core_MDF_Opal_Budget_Type_Txt__c= 'OEM CMP';
        insert camp; 
        
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true); 

        
        PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_TestDataUtility.budget_Record_Type,acc2.Id,cp.Id,200000,System.today().addDays(-20),System.today(), false);
        budget.Core_MDF_Budget_Type_Txt__c='OEM CMP';
        Database.insert(budget);
        
        PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,acc2,200.0,true);

        
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.Id, 
                                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                          String.valueof(acc2.id),allocation,null,'INDIA',
                                                                                                          'Consumer',
                                                                                                          'Desktop',
                                                                                                          'Intel® Core™ i5 Processor',
                                                                                                          'Broadcast',
                                                                                                          'Television',
                                                                                                          'Draft',
                                                                                                          false);

        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
        claim1.Core_MDF_Currency__c='USD';

        SUPER_CLAIM_ID = claim1.Id;

        /* ---------- Child Claims ---------- */
        
       List<PartnerFundClaim> childClaims = new List<PartnerFundClaim>();
       PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
       claim2.Core_MDF_Claim_Id__c = SUPER_CLAIM_ID;
        childClaims.add(claim2);
       PartnerFundClaim claim3= Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
	   claim3.Core_MDF_Claim_Id__c = SUPER_CLAIM_ID;
        childClaims.add(claim3);
        
        

        /* ---------- Claim History (required by start()) ---------- */
        PartnerFundClaimHistory hist = new PartnerFundClaimHistory(
            Field = 'Core_MDF_Status__c',
            PartnerFundClaimId = childClaims[0].Id
        );
        insert hist;
        }
    }

    /* ============================================================
       Test: Normal status update
       ============================================================ */
    @IsTest
    static void testBatchUpdatesSuperClaimStatus() {

        Test.startTest();
            Database.executeBatch(
                new Core_MDF_SuperClaimStatusUpdateBatch(
                    new Set<Id>{ SUPER_CLAIM_ID },
                    System.now().addDays(-5)
                ),
                5
            );
        Test.stopTest();

        PartnerFundClaim updatedClaim =
            [SELECT Core_MDF_Status__c
             FROM PartnerFundClaim
             WHERE Id = :SUPER_CLAIM_ID];

        System.assertEquals(
            'Approved',
            updatedClaim.Core_MDF_Status__c,
            'Super claim should update based on child claim statuses'
        );
    }

    /* ============================================================
       Test: Manual Hold prevents update
       ============================================================ */
    @IsTest
    static void testManualHoldPreventsUpdate() {

        PartnerFundClaim holdClaim = new PartnerFundClaim(
            Core_MDF_Status__c = 'Approved',
            Core_MDF_Member_Manual_Hold_Ind__c = true,
            Core_MDF_Intel_Manual_Hold_Ind__c = false
        );
        insert holdClaim;

        Test.startTest();
            Database.executeBatch(
                new Core_MDF_SuperClaimStatusUpdateBatch(
                    new Set<Id>{ holdClaim.Id },
                    System.now().addDays(-2)
                ),
                5
            );
        Test.stopTest();

        PartnerFundClaim result =
            [SELECT Core_MDF_Status__c
             FROM PartnerFundClaim
             WHERE Id = :holdClaim.Id];

        System.assertEquals(
            'Approved',
            result.Core_MDF_Status__c,
            'Claim on manual hold should not be updated'
        );
    }
}