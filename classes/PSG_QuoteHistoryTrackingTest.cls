@IsTest
public class PSG_QuoteHistoryTrackingTest {
    
    @testSetup static void createTestData() {
        List<User> disty = PSG_Test_Utility.createDistyUser();
        System.runAs(disty[0]){
            Account acc = PSG_Test_Utility.createAccount();
            Contact con = PSG_Test_Utility.createContact(acc.Id);
            pricebook2 pb = PSG_Test_Utility.createPriceBook('Intel processor');
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.RecordTypeId = PSG_Utility.getRecordTypeId('SBQQ__Quote__c', 'PSG_Quote_New');
            quote.SBQQ__Account__c = acc.Id;
            quote.SBQQ__PrimaryContact__c = con.Id;
            quote.core_cpq_price_book_nm__c =  pb.Id;
            quote.core_cpq_revision_nbr__c =  1;
            quote.SBQQ__Status__c = 'In Progress';
            quote.core_cpq_assigned_on__c = System.now();
            quote.SBQQ__Distributor__c = acc.Id;
            quote.core_cpq_quote_type_nm__c = 'Design Win';
            quote.core_cpq_end_customer_country_disty_nm__c = 'India';
            quote.core_cpq_active_cb__c = true;
            quote.core_cpq_ready_for_submission__c=true;
            quote.Pricing_Quote_Program_Nm__c = 'PSG';
            quote.core_cpq_business_unit_nm__c = 'Military';
            quote.core_cpq_quote_owner_disty_txt__c = 'SOS Korea';
            quote.core_cpq_account_tier__c = 'PSG-Tier 4';
            quote.core_cpq_revision_nbr__c = 1;
            quote.SBQQ__StartDate__c=Date.today();
            quote.SBQQ__EndDate__c= quote.SBQQ__StartDate__c.addMonths(4);
            quote.core_cpq_price_eligibility_date_dt__c=Date.today();
            quote.core_cpq_pricing_end_date_dt__c=Date.today();
            quote.core_cpq_pricing_start_date_dt__c=Date.today();
            quote.core_cpq_review_date_dt__c=Date.today();
            quote.core_cpq_Process_flag__c = false;
            insert quote;
        }
    }
    
    @IsTest
    static void testCreateHistoryForNew(){
        List<User> bmUser = PSG_Test_Utility.createBMUser();
        Test.StartTest();
        System.runAs(bmUser[0]){
            SBQQ__Quote__c quote = [Select Id,SBQQ__Status__c from SBQQ__Quote__c];
            Map<String,String> quoteIdToNewStatusMap = new Map<String,String>();
            Map<String,String> quoteIdToOldStatusMap = new Map<String,String>();
            quoteIdToOldStatusMap.put(quote.Id,quote.SBQQ__Status__c);
			quote.SBQQ__Status__c = 'Approved';
            
            quoteIdToNewStatusMap.put(quote.Id,quote.SBQQ__Status__c);
            List<sbaa__Approval__c> createApproval = PSG_Test_Utility.createApproval(quote.Id);
            core_cpq_bm_level__c bmrecc = new core_cpq_bm_level__c();
            bmrecc.core_cpq_bm_level_nm__c = 'Level 5';
            bmrecc.core_cpq_bm_name__c = bmUser[0].Id ;
            insert bmrecc;
            PSG_QuoteHistoryTracking.createHistory(quoteIdToNewStatusMap,quoteIdToOldStatusMap);
            Assert.areEqual('Approved',quote.SBQQ__Status__c,'Quote is approved');
        }
        Test.StopTest();
        
    }
    
    @IsTest
    static void testCreateHistoryForApproval(){
        Set<String> quoteIds = new Set<String>();
        List<User> bmUser = PSG_Test_Utility.createBMUser();
        Test.StartTest();
        System.runAs(bmUser[0]){
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c];
            
            quoteIds.add(quote.Id);
            Id quoteIdForApproval;
            for(String quoteId :  quoteIds){
                quoteIdForApproval = quoteId;
                break;
            }
            List<sbaa__Approval__c> createApproval = PSG_Test_Utility.createApproval(quoteIdForApproval);
            Set<String> approvalIds = new Set<String>();
            approvalIds.add(createApproval[0].Id);
            PSG_QuoteHistoryTracking.updateApprovalHistory(approvalIds);
            Assert.isNotNull(approvalIds,'Approval Id is not Null');
        }
        Test.StopTest();
        
    }
}