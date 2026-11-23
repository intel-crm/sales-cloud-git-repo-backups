/****************************************************************************************************
Apex Class Name : PSG_BatchUpdateQuoteLines_Test
Version         : 1.0 
Created Date    : 26/02/2021
Function        : Test class for PSG_BatchUpdateQuoteLines.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vijay                    26/02/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_BatchUpdateQuoteLines_Test {
    /*
    @testSetup
    public static void setUpData(){
        List<User> lstUsers3 = PSG_Test_Utility.createSOSUser();
        if(!lstUsers3.isEmpty()){
            system.runAs(lstUsers3[0]){                
                Account acc = PSG_Test_Utility.createAccount();
                Contact con = PSG_Test_Utility.createContact(acc.Id);
                User partnerUser = PSG_Test_Utility.createPartnerUser(acc.Id);
                Test.startTest();
                List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc.Id, partnerUser.ContactId, 2);
                System.assert(lstquote[0].Id!=null,'Quote creation successfull');
                if(lstquote[0] != null){
                    pricebook2 pb = [Select id from pricebook2 limit 1];
                    lstquote[0].core_cpq_price_book_nm__c = pb.Id;
                    Update lstquote[0];
                    System.assert(lstquote[0].Id!=null,'Quote updation successfull');
                    List<SBQQ__QuoteLine__c> lstquoteLines= PSG_Test_Utility.createQuoteLines(lstquote[0].Id, 1);
                }
                Test.stopTest();
            }   
        }
    }
    static testmethod void batchUpdateQuoteLinesTest(){
        List<User> lstUsers3 = PSG_Test_Utility.createSOSUser();
        system.runAs(lstUsers3[0]){
            SBQQ.TriggerControl.disable();
            List<User> lstUsers2 = PSG_Test_Utility.createAdminUser();
            List<SBQQ__QuoteLine__c> lstquoteLines = [select id ,core_cpq_PRID__c,price_suggested_resale_amt__c,price_brokencost_amt__c ,SBQQ__Quote__r.SBQQ__Status__c,core_cpq_distributor_margin_pct__c from SBQQ__QuoteLine__c limit 2];
            List<SBQQ__Quote__c> lstquote = [select id from SBQQ__Quote__c limit 1];
            List<Account> acc = [select id from Account limit 1];
            List<Product2> product = PSG_Test_Utility.createProduct(1);
            List<price_prid__c> prId = new List<price_prid__c>();
            price_prid__c prIdRec = new price_prid__c();
            prIdRec.core_cpq_active_cb__c = true;
            prIdRec.core_cpq_device__c = product[0].Id;
            prIdRec.core_cpq_sap_ecp_nm__c = acc[0].Id;
            prIdRec.core_cpq_lower_bound_qty_nbr__c =  1;
            prIdRec.core_cpq_upper_bound_qty_nbr__c = 100;
            prIdRec.core_cpq_type__c =Label.PSG_PRID_Type_AVP;
            prIdRec.core_cpq_quote__c = lstquote[0].Id;
            prIdRec.core_cpq_quoteline__c = lstquoteLines[0].Id;
            prIdRec.price_amt__c = 200;
            prIdRec.core_cpq_quantity_eau_nbr__c = 100;
            prIdRec.core_cpq_price_start_date_dt__c =  Date.newInstance(2010, 12, 9);
            prIdRec.core_cpq_price_end_date_dt__c =  Date.newInstance(2011, 12, 9);
            prIdRec.core_cpq_prid_eligiblity_date_dt__c =  Date.newInstance(2012, 12, 9);
            
            prIdRec.core_cpq_update_underlying_quotelines_cb__c =true;
            prIdRec.core_cpq_active_pricing_cb__c = false;
            price_prid__c prIdRec2 = new price_prid__c();
            prIdRec2.core_cpq_active_cb__c = true;
            prIdRec2.core_cpq_device__c = product[0].Id;
            prIdRec2.core_cpq_sap_ecp_nm__c = acc[0].Id;
            prIdRec2.core_cpq_lower_bound_qty_nbr__c =  1;
            prIdRec2.core_cpq_upper_bound_qty_nbr__c = 100;
            prIdRec2.core_cpq_type__c ='Flat';
            prIdRec2.core_cpq_quote__c = lstquote[0].Id;
            prIdRec2.core_cpq_quoteline__c = lstquoteLines[0].Id;
            prIdRec2.price_amt__c = 200;
            prIdRec2.core_cpq_quantity_eau_nbr__c = 200;
            prIdRec2.core_cpq_update_underlying_quotelines_cb__c =true;
            prIdRec2.core_cpq_active_pricing_cb__c = true;
            prId.add(prIdRec);
            prId.add(prIdRec2);
            insert prId;
            Test.startTest();
            System.assert(prId!=null,'Successfully inserted');
            lstquoteLines[0].core_cpq_PRID__c=prId[0].Id;
            lstquoteLines[0].core_cpq_quote_line_type_txt__c='AVP';
            lstquoteLines[0].price_suggested_resale_amt__c=76;
            lstquoteLines[0].SBQQ__Quantity__c=200;
            
            lstquoteLines[0].core_cpq_lower_bound_qty_qty__c=1;
            lstquoteLines[0].core_cpq_upper_bound_qty_nbr__c=200;
            lstquoteLines[0].core_cpq_price_eligibility_date_dt__c= Date.newInstance(2016, 12, 9);
            lstquoteLines[0].core_cpq_active_Pricing__c=true;
            lstquoteLines[0].core_cpq_pricing_start_date_dt__c=Date.newInstance(2017, 12, 10);
            update lstquoteLines;
            Map<String,String> quoteLineApiToPridApiMap = new Map<String,String>{
                                'price_suggested_resale_amt__c' => 'price_amt__c',
                                'SBQQ__Quantity__c' => 'core_cpq_quantity_eau_nbr__c',
                                'core_cpq_upper_bound_qty_nbr__c' => 'core_cpq_upper_bound_qty_nbr__c',
                                'core_cpq_lower_bound_qty_qty__c' => 'core_cpq_lower_bound_qty_nbr__c',
                                'core_cpq_pricing_start_date_dt__c' => 'core_cpq_price_start_date_dt__c',
                                'core_cpq_pricing_end_date_dt__c' => 'core_cpq_price_end_date_dt__c',
                                'core_cpq_price_eligibility_date_dt__c' => 'core_cpq_prid_eligiblity_date_dt__c',
                                'core_cpq_review_date_dt__c' => 'core_cpq_prid_review_date_dt__c',
                                'core_cpq_reviewer__c' => 'core_cpq_prid_reviewer__c',
                                'core_cpq_active_Pricing__c' => 'core_cpq_active_pricing_cb__c'
                                };
            Map<String,String> pridApiToQuoteLineApiMap = new Map<String,String>{
                                'price_amt__c' => 'price_suggested_resale_amt__c',
                                'core_cpq_quantity_eau_nbr__c' => 'SBQQ__Quantity__c',
                                'core_cpq_upper_bound_qty_nbr__c' => 'core_cpq_upper_bound_qty_nbr__c',
                                'core_cpq_lower_bound_qty_nbr__c' => 'core_cpq_lower_bound_qty_qty__c',
                                'core_cpq_price_start_date_dt__c' => 'core_cpq_pricing_start_date_dt__c',
                                'core_cpq_price_end_date_dt__c' => 'core_cpq_pricing_end_date_dt__c',
                                'core_cpq_prid_eligiblity_date_dt__c' => 'core_cpq_price_eligibility_date_dt__c',
                                'core_cpq_prid_review_date_dt__c' => 'core_cpq_review_date_dt__c',
                                'core_cpq_prid_reviewer__c' => 'core_cpq_reviewer__c',
                                'core_cpq_active_pricing_cb__c' => 'core_cpq_active_Pricing__c'
                                };
            PSG_BatchUpdateQuoteLines updateBatch = new PSG_BatchUpdateQuoteLines();
            updateBatch.onlyDollarChangeUpdate = true;
            updateBatch.quoteLinesToIgnoreUpdateSet = new Set<Id>();
            updateBatch.quoteLineApiToPridApiMap = quoteLineApiToPridApiMap;
            updateBatch.pridApiToQuoteLineApiMap = pridApiToQuoteLineApiMap;
            updateBatch.quoteLineListToProcess = lstquoteLines;
            updateBatch.quoteLineInitiated = true;
            Database.executeBatch(updateBatch,1);
            Test.stopTest();
            SBQQ.TriggerControl.disable();
        }
    }
    */
}