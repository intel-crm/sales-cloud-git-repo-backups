@isTest
public class Temp_Core_UpdateOptyRisk_Test{
    @testSetup
    public static void setUpData(){
        
        List<User> lstUsers3 = PSG_Test_Utility.createAdminUser();
        if(!lstUsers3.isEmpty()){
            system.runAs(lstUsers3[0]){ 
                SBQQ.TriggerControl.disable();
                Account acc = PSG_Test_Utility.createDirectAccount();
                Account acc1 = new Account();
                acc1.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
                acc1.Name = 'Test Account'+System.now();
                acc1.Core_Account_Type__c = 'Distributor;End Customer';//added
                acc1.Industry = 'Banking';
                acc1.BillingCity = 'Texas';
                acc1.BillingCountry = 'USA';
                acc1.BillingStreet = 'G-2101'; 
                acc1.Core_Sales_Groups__c = 'CCG Sales Group'; 
                acc1.Core_Geo__c = 'APJ';
                acc1.Core_Sub_Geo__c = 'IJKK';
                acc1.Core_PSG_Account__c = true;
                acc1.Core_Account_Tier__c ='PSG-Tier 4';
                acc1.Core_Partner_Alliance_Program__c ='PSG Demand Creation - PSG';
                acc1.Core_Account_BU_Focus__c='PSG-CM;PSG-DISTI';
                acc1.Core_Direct_Pricing_Parent_Id__c=acc.id;
                acc1.Core_Direct_Legal_Parent_Id__c=acc.id;
                insert acc1;
                Contact con = PSG_Test_Utility.createContact(acc1.Id);
                //PSG_Test_Utility.CreatePriceBook('PSG Price Book');
                PSG_Test_Utility.createApprvRecord(acc.Id);
                PSG_Test_Utility.createBMLevel();
                PSG_Test_Utility.createBMApprThres();
                PSG_Test_Utility.createGroup();
                PSG_Test_Utility.createGroupMember();
                PSG_Test_Utility.createBMLevel();
                List<User> lstUsers = PSG_Test_Utility.createSOSUser();
                List<User> lstdistyusers = PSG_Test_Utility.createDistyUser();
                SBQQ.TriggerControl.disable();
                Product2 prod = new Product2(Name='TestProduct11',
                                             Core_Product_Org__c = 'Sales',
                                             Core_Product_Type__c = 'Processors',
                                             Core_Hierarchy_ID__c = '43',
                                             Core_Group_Code_Short_Name__c = 'DCG',
                                             Core_OPN__c = 'OPN1',
                                             Core_Sales_Visible_Flag__c=true,
                                             Core_Item_Orderable_Ind__c=true,
                                             Core_Item_Quotable_Ind__c=true,
                                             IsActive=true);            
                insert prod;
                Test.startTest();

                List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
                pricebook2 pb = PSG_Test_Utility.createPriceBook('Intel processor');
                SBQQ__Quote__c quote = new SBQQ__Quote__c();
                quote.RecordTypeId = PSG_Utility.getRecordTypeId('SBQQ__Quote__c', 'PSG_Quote_New');
                quote.SBQQ__Account__c = acc.id;
                quote.SBQQ__PrimaryContact__c = con.Id;
                quote.core_cpq_price_book_nm__c =  pb.Id;
                quote.core_cpq_revision_nbr__c =  1;
                quote.SBQQ__Status__c = 'In Review';
                quote.core_cpq_assigned_on__c = System.now();
                quote.core_cpq_quote_type_nm__c = 'Design Win';
                quote.core_cpq_end_customer_country_disty_nm__c = 'Taiwan';
                quote.core_cpq_active_cb__c = true;
                quote.SBQQ__Type__c='Quote';
                quote.core_cpq_requestor_nm__c = lstdistyusers[0].Id;
                pricebook2 pb1 = [Select id from pricebook2 limit 1];
                quote.core_cpq_price_book_nm__c = pb1.Id;
                quote.core_cpq_first_bm_approver__c = lstUsers[0].Id;
                quote.core_cpq_next_approver_nm__c = lstUsers[0].Id;
                quote.core_cpq_quote_type_nm__c = 'Transfer Pricing';
                quote.core_cpq_business_unit_nm__c = 'wireline';
                insert quote;  
                SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(); 
                quoteLine.RecordTypeId=PSG_Utility.getRecordTypeId('SBQQ__QuoteLine__c', 'PSG_Quote_Line_Create');
                quoteLine.SBQQ__Product__c = prod.Id;
                quoteLine.SBQQ__Quote__c = quote.Id;
                quoteLine.price_suggested_resale_amt__c = 100;
                quoteLine.core_cpq_previous_distributor_margin_pct__c = 10;
                quoteLine.core_cpq_quote_line_type_txt__c = 'Flat';
                quoteLine.core_cpq_requested_qty__c = 10;
                quoteLine.SBQQ__Quantity__c = null;
                quoteLine.core_cpq_lower_bound_qty_qty__c = 5;
                quoteLine.core_cpq_upper_bound_qty_nbr__c = 25;
                quoteLine.price_disty_cost_nbr__c = 100;
                quoteLine.core_cpq_internal_comments_txt__c = 'Hello';
                quoteLine.core_cpq_comments_for_customer_txt__c = 'Hi';
                quoteLine.core_cpq_comments_for_disty_txt__c = 'Yes';
                quoteLine.price_requested_resale_amt__c = 80;
                quoteLine.price_suggested_resale_amt__c = 110;
                quoteLine.price_std_fwd_cost_amt__c = 200;
                quoteLine.price_goal_price_amt__c = 60;
                quoteLine.core_cpq_years_nbr__c  = null;
                quoteLine.core_cpq_distributor_margin_pct__c = 10;
                quoteLine.core_cpq_altera_reg_txt__c = 'ABCDE';
                quoteLine.core_cpq_competitor_price_amt__c = 75;
                quoteLine.core_cpq_competitor_part_txt__c = 'Test';
                quoteLine.core_cpq_margin_exception_txt__c = 'eASIC';
                quoteLine.price_msvp_l1_amt__c = 20;
                quoteLine.price_msvp_l2_amt__c = 25;
                quoteLine.SBQQ__ListPrice__c = 55;
                quoteLine.core_cpq_reg_status__c = 'Pending';
                quoteLine.core_cpq_product_nm__c = prod.Id;
                quoteLine.core_cpq_quantity_nm__c =1234;
                quoteLine.core_cpq_gp_msvpl2_nm__c = 35;
                quoteLine.core_cpq_opn__c = 'Abc123';
                quoteLine.core_cpq_production_dt__c = System.today();
                quoteLine.Pricing_Quote_Program_Nm__c = 'PSG';
                quoteLine.core_cpq_pricing_start_date_dt__c = System.today() + 5;
                quoteLine.core_cpq_dollar_change_flag_cb__c = false;
                quoteLine.price_brokencost_amt__c = 10;
                quoteLine.price_std_fwd_cost_amt__c = 21;
                
                quoteLine.price_suggested_resale_amt__c = 200;
                quoteLine.core_cpq_distributor_margin_pct__c = 10;
                quoteLine.price_std_fwd_cost_amt__c = 1000;
                quoteLine.SBQQ__Quantity__c = 400;
                
                insert quoteLine;
                Test.stopTest();
            }   
        }
    }
    static testmethod void testData1(){
        SBQQ.TriggerControl.disable();
        List<SBQQ__Quote__c> lstquote = [select id, core_cpq_negative_margin_quote_Value__c from SBQQ__Quote__c ];
        List<SBQQ__QuoteLine__c> qlList = [SELECT Id, Name, price_std_fwd_cost_amt__c, core_cpq_distributor_margin_pct__c, price_suggested_resale_amt__c, 
                                           core_cpq_intel_margin_pct__c, price_broken_cost_cp__c, SBQQ__Quote__r.core_cpq_negative_margin_quote_Value__c from SBQQ__QuoteLine__c];
        /*if(lstquoteLines[0] != null){
qlList.add(lstquoteLines[0]);
}*/
        
        /*qlList[0].price_suggested_resale_amt__c = 200;
        qlList[0].core_cpq_distributor_margin_pct__c = 10;
        qlList[0].price_std_fwd_cost_amt__c = 1000;
        qlList[0].SBQQ__Quantity__c = 400;
        Update qlList[0];*/
        Test.startTest();
        List<sbaa__ApprovalRule__c> approverRuleList = [SELECT Id,Name from sbaa__ApprovalRule__c limit 1];
        List<sbaa__Approver__c> approverList = [SELECT Id,Name from sbaa__Approver__c limit 1];
        List<sbaa__Approval__c> approvalList = PSG_Test_Utility.createApproval(lstquote[0].Id);
        
        PSG_ApprovalBusinessLogic.getApprovalList();
        Test.stopTest();
        System.assertEquals(null,approvalList[0].Name);
        /*if(!approvalList.isEmpty()){
            update approvalList;
        }*/
        
    }
}