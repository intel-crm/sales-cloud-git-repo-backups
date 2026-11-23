@isTest
public class PSG_QuoteLineDataTableControllerTest {
    @testSetup
    public static void setUpData() {
		//method creates product,quote and quote line records
        List < User > lstUsers3 = PSG_Test_Utility.createSOSUser();
        if (!lstUsers3.isEmpty()) {
            system.runAs(lstUsers3[0]) {
                Account acc = PSG_Test_Utility.createAccount();
                Contact con = PSG_Test_Utility.createContact(acc.Id);
                User partnerUser = PSG_Test_Utility.createPartnerUser(acc.Id);
                PSG_Test_Utility.CreatePriceBook('PSG Price Book');
                PSG_Test_Utility.CreateProduct(3);
                List < SBQQ__Quote__c > lstquote = PSG_Test_Utility.createQuote(acc.Id, partnerUser.ContactId, 1);
                System.assert(lstquote[0].id != null, 'New Quote is created');
                System.assertEquals('Design Win', lstQuote[0].core_cpq_quote_type_nm__c);

                if (lstquote[0] != null) {
                    pricebook2 pb = [Select id from pricebook2 limit 1];
                    lstquote[0].core_cpq_price_book_nm__c = pb.Id;
                    Update lstquote[0];
                    Test.startTest();
                    List < SBQQ__QuoteLine__c > lstquoteLines = PSG_Test_Utility.createQuoteLines(lstquote[0].Id, 5);
                    Test.stopTest();    
                }
            }
        }
    }

    @isTest static void createQuoteHistoryTest2() {
        SBQQ.TriggerControl.disable();
        List < User > lstUsers3 = PSG_Test_Utility.createSOSUser();
        List < SBQQ__QuoteLine__c > lstquoteLines = [SELECT Id, SBQQ__Quote__r.core_cpq_assigned_to_nm__r.Email, Name, core_cpq_product_nm__c, core_cpq_revision_reason_txt__c, core_cpq_revision_request_category_nm__c, core_cpq_altera_reg_number__c, core_cpq_product_family_txt__c, SBQQ__ListPrice__c,
            core_cpq_quote_line_type_txt__c, price_suggested_resale_amt__c, core_cpq_distributor_margin_pct__c, price_brokencost_amt__c,
            core_cpq_requested_qty__c, price_requested_resale_amt__c, price_std_fwd_cost_amt__c, core_cpq_production_dt__c, core_cpq_lower_bound_qty_qty__c, core_cpq_upper_bound_qty_nbr__c,
            core_cpq_pricing_start_date_dt__c, core_cpq_pricing_end_date_dt__c, SBQQ__ProductName__c, core_cpq_justification_txt__c, core_cpq_altera_reg_txt__c, core_cpq_external_comments_txt__c, SBQQ__Quantity__c, core_cpq_years_nbr__c, core_cpq_opn__c, SBQQ__Quote__r.Name From SBQQ__QuoteLine__c LIMIT 1
        ];
        
        Map < String, SBQQ__QuoteLine__c > quoteLineMap = new Map < String, SBQQ__QuoteLine__c > ();
        quoteLineMap.put(lstquoteLines[0].id, lstquoteLines[0]);
        List < SBQQ__Quote__c > lstquote = [select id, OwnerId, Name, core_cpq_end_customer_country_disty_nm__c, core_cpq_quote_type_nm__c, core_cpq_assigned_to_nm__r.Email,core_cpq_end_customer_disty_view_nm__c,core_cpq_end_customer_city__c, core_cpq_end_customer_State__c,core_cpq_ec_country__c,core_cpq_distributor_disty_view_nm__c,core_cpq_confirmed_order__c from SBQQ__Quote__c limit 1];
        Map < String, SBQQ__Quote__c > quoteMap = new Map < String, SBQQ__Quote__c > ();
        quoteMap.put(lstquote[0].id, lstquote[0]);
        String status = 'Approved';
        List < SBQQ__QuoteLine__c > qlst = PSG_QuoteLineDataTableController.fetchQuoteLines(lstquote[0].Id);
        System.assert(qlst[0].Id != null, 'Qoute line created');
        PSG_QuoteLineDataTableController.fetchAllQuoteLines(lstquote[0].Id);
        PSG_QuoteLineDataTableController.addNewQuoteLine(lstquote[0].Id, lstquoteLines);
        System.runAs(lstUsers3[0]) {
            PSG_QuoteLineDataTableController.cloneRecord(lstquote[0].Id);
        }
        PSG_LookupController.lookUp(lstquote[0].Name, 'SBQQ__Quote__c', '', lstquote[0].Id, 'Id');
        PSG_LookupController.lookUp(lstquote[0].Name, 'SBQQ__Quote__c', '', '', 'Id');
		//calls the sendQuoteRequestUpdate method to cover the aura exception block
        try {
            Test.startTest();
            PSG_QuoteLineDataTableController.sendQuoteRequestUpdate(lstquoteLines, quoteLineMap, lstquote, quoteMap, status);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
		//oldprIdMap created to cover the senerio when chenges are made and requested in sendQuoteRequestUpdate method
        Map < String, SBQQ__Quote__c > oldprIdMap = new Map < String, SBQQ__Quote__c > ([select id, OwnerId, Name, core_cpq_end_customer_country_disty_nm__c, core_cpq_quote_type_nm__c, core_cpq_assigned_to_nm__r.Email,core_cpq_end_customer_disty_view_nm__c,core_cpq_end_customer_city__c, core_cpq_end_customer_State__c,core_cpq_ec_country__c,core_cpq_confirmed_order__c,core_cpq_distributor_disty_view_nm__c from SBQQ__Quote__c limit 1]);
        oldprIdMap.get(lstquote[0].id).core_cpq_quote_type_nm__c = 'Tools';
        PSG_QuoteLineDataTableController.sendQuoteRequestUpdate(lstquoteLines, quoteLineMap, lstquote, oldprIdMap, status);
        PSG_QuoteLineDataTableController.updateQuoteLines(qlst);
        PSG_QuoteLineDataTableController.deleteRecord(lstquoteLines[0].Id);
        Test.stopTest();
    }
}