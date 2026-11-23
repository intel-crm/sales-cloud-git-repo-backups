/****************************************************************************************************
Apex Class Name : PSG_ApprovalBusinessLogic_Test
Version         : 1.0 
Created Date    : 08/13/2021
Function        : Test class for PSG_ApprovalBusinessLogic.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Tushar             08/13/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_ApprovalBusinessLogic_Test{
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
                acc1.Core_Sales_Groups__c = 'PRC Sales Group'; 
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
                                             Core_Product_Type__c = 'Intel® FPGAs',                                           
                                             Core_Hierarchy_ID__c = '43',
                                             Core_Group_Code_Short_Name__c = 'DCG',
                                             Core_OPN__c = 'OPN1',
                                             Core_Sales_Visible_Flag__c=true,
                                             Core_Item_Orderable_Ind__c=true,
                                             Core_Item_Quotable_Ind__c=true,
                                             IsActive=true,
                                             Core_Item_Class_Nm__c='BD',
                                             Core_BU_Operation_Code__c='KP');            
                insert prod;
                prod.Core_Sales_Visible_Flag__c=true;
                prod.Core_Item_Orderable_Ind__c=true;
                prod.Core_Item_Quotable_Ind__c=true;
                update prod;
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
                quote.core_cpq_end_customer_nm__c=acc1.Id;
                quote.core_cpq_ready_for_submission__c=true;
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
                quoteLine.core_cpq_opn__c = prod.Core_OPN__c;
                quoteLine.core_cpq_production_dt__c = System.today();
                quoteLine.Pricing_Quote_Program_Nm__c = 'PSG';
                quoteLine.core_cpq_pricing_start_date_dt__c = System.today() + 5;
                quoteLine.core_cpq_dollar_change_flag_cb__c = false;
                quoteLine.price_brokencost_amt__c = 10;
                quoteLine.price_std_fwd_cost_amt__c = 21;
                quoteLine.price_suggested_resale_amt__c = 200;
                quoteLine.core_cpq_distributor_margin_pct__c = 10;
                quoteLine.SBQQ__Quantity__c = 400;
                
                insert quoteLine;
                Test.stopTest();
            }   
        }
    }
    static testmethod void testData1(){
        SBQQ.TriggerControl.disable();
        List<User> lstUsers1 = PSG_Test_Utility.createBOUser();
        List<SBQQ__Quote__c> lstquote = [select id, core_cpq_negative_margin_quote_Value__c from SBQQ__Quote__c ];
        List<SBQQ__QuoteLine__c> qlList = [SELECT Id, Name, price_std_fwd_cost_amt__c, core_cpq_distributor_margin_pct__c, price_suggested_resale_amt__c, 
                                           core_cpq_intel_margin_pct__c, price_broken_cost_cp__c, SBQQ__Quote__r.core_cpq_negative_margin_quote_Value__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:lstquote[0].id];
      
        
        qlList[0].core_cpq_quote_line_type_txt__c='Flat';
        qlList[0].core_cpq_price_eligibility_date_dt__c=system.today() + 6;
         Test.startTest();
        Update qlList[0];
 
        
       
        List<sbaa__Approval__c> approvalList = PSG_Test_Utility.createApproval(lstquote[0].Id);
        List<sbaa__Approver__c> approverList = PSG_Test_Utility.createApprover(lstUsers1[0].Id);
        List<sbaa__ApprovalRule__c> approverRuleList = [SELECT Id,Name from sbaa__ApprovalRule__c limit 1];
        PSG_ApprovalBusinessLogic.getApprovalList();
        System.assertEquals(null,approvalList[0].Name);
        if(!approvalList.isEmpty()){
              
            update approvalList;
        }
        Test.stopTest();
        
    }
    
    static testmethod void testData2(){
        SBQQ.TriggerControl.disable();
        PSG_Constants.isQuoteLineTriggerActive=false;
        List<User> lstUsers1 = PSG_Test_Utility.createBOUser();
        
        List<SBQQ__Quote__c> lstquote = [select id, core_cpq_negative_margin_quote_Value__c from SBQQ__Quote__c ];
        List<SBQQ__QuoteLine__c> qlList = [SELECT Id, Name, price_std_fwd_cost_amt__c, core_cpq_distributor_margin_pct__c, price_suggested_resale_amt__c, 
                                           core_cpq_intel_margin_pct__c, price_broken_cost_cp__c, SBQQ__Quote__r.core_cpq_negative_margin_quote_Value__c,Core_OPN__c,core_cpq_product_nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:lstquote[0].id];
       
      
        qlList[0].price_std_fwd_cost_amt__c = 8;
        qlList[0].core_cpq_distributor_margin_pct__c = 0;
        qlList[0].price_suggested_resale_amt__c = 2;
        qlList[0].core_cpq_quote_line_type_txt__c='Flat';
        qlList[0].core_cpq_price_eligibility_date_dt__c=system.today() + 6;
         Test.startTest();
        Update qlList;
        qlList = [SELECT Id, Name, price_std_fwd_cost_amt__c, core_cpq_distributor_margin_pct__c, price_suggested_resale_amt__c, 
                                           core_cpq_intel_margin_pct__c, price_broken_cost_cp__c, SBQQ__Quote__r.core_cpq_negative_margin_quote_Value__c,Core_OPN__c,core_cpq_product_nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:lstquote[0].id];
        system.debug('ql-->'+qlList);
 
        
       
        List<User> uL1 = PSG_Test_Utility.createBMUser();
        List<core_cpq_bm_level__c> bmlist = new List<core_cpq_bm_level__c>();
        core_cpq_bm_level__c bmrecc = new core_cpq_bm_level__c();
        bmrecc.core_cpq_bm_level_nm__c = 'Level 5';
        bmrecc.core_cpq_bm_name__c = uL1[0].Id ;
        bmlist.add(bmrecc);
        insert bmlist;
        
        Group grp = new Group();
        grp.name = 'Test Group11';
        grp.Type = 'Regular'; 
        System.runAs(uL1[0]){
            Insert grp; 
        }
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = uL1[0].Id;
        grpMem1.GroupId = grp.Id;
        
        System.runAs(uL1[0]){
            Insert grpMem1;
        }
        
        Group subGrp  = new Group();
        subGrp.name = 'Test Group21';
        subGrp.Type = 'Regular'; 
        System.runAs(uL1[0]){
            Insert subGrp; 
        }
        GroupMember grpMem2 = new GroupMember();
        grpMem2.UserOrGroupId = subGrp.Id;
        grpMem2.GroupId = grp.Id;
        System.runAs(uL1[0]){
            Insert grpMem2;  
        }
        
        
        
        List<sbaa__Approver__c> approverList = new List<sbaa__Approver__c>();
        approverList.add(new sbaa__Approver__c(Name = 'test approver1',sbaa__Unanimous__c=true,sbaa__User__c = uL1[0].Id,
                                               sbaa__GroupId__c = grp.Id));
        insert approverList;
        System.assert( approverList[0].Name!=null,'Approval is created sucessfully');
        
        List<sbaa__ApprovalRule__c> approverRuleList = new List<sbaa__ApprovalRule__c>();
        approverRuleList.add(new sbaa__ApprovalRule__c(Name = 'BizOps Approval Rule - APJ', sbaa__TargetObject__c = 'SBQQ__Quote__c'));
        insert approverRuleList;
        
        
        List<sbaa__ApprovalChain__c> approverChainList = new List<sbaa__ApprovalChain__c>();
        approverChainList.add(new sbaa__ApprovalChain__c(Name = 'BM Chain1', sbaa__TargetObject__c = 'SBQQ__Quote__c'));
        insert approverChainList;
        
        List<sbaa__Approval__c> approvalList = new List<sbaa__Approval__c>();
        
        SBQQ__Quote__c quoteRec = new SBQQ__Quote__c();
        quoteRec.core_cpq_first_bm_approver__c = uL1[0].Id;
        
        sbaa__Approval__c appr1 = new sbaa__Approval__c(sbaa__RecordField__c = 'test1',sbaa__ApprovalStep__c=1,sbaa__Status__c ='Requested', 
                                                        sbaa__AssignedTo__c = uL1[0].Id, Quote__c = lstquote[0].id, sbaa__Approver__c = approverList[0].Id, sbaa__Rule__c = approverRuleList[0].Id,
                                                        sbaa__DelegatedApprover__c = approverList[0].Id,sbaa__ApprovalChain__c = approverChainList[0].Id);
        approvalList.add(appr1);
        
        sbaa__Approval__c appr2 = new sbaa__Approval__c(sbaa__RecordField__c = 'test21',sbaa__ApprovalStep__c=1,sbaa__Status__c ='Requested', 
                                                        sbaa__AssignedTo__c = uL1[0].Id, Quote__c = lstquote[0].id, sbaa__Approver__c = approverList[0].Id, sbaa__Rule__c = approverRuleList[0].Id,
                                                        sbaa__DelegatedApprover__c = approverList[0].Id,sbaa__ApprovalChain__c = approverChainList[0].Id);
        approvalList.add(appr2);
        insert approvalList;
        
        
        approvalList[0].sbaa__Status__c = 'Approved';
        approvalList[0].sbaa__ApprovedBy__c=uL1[0].id;
        update approvalList;
        
        List<sbaa__Approver__c> approverList1 = PSG_Test_Utility.createApprover(lstUsers1[0].Id);
        PSG_ApprovalBusinessLogic.getApprovalList();
        Test.stopTest();
        
    }
}