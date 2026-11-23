/**
* @description       : 
* @author            : Rajesh Gajul
* @group             : 
* @last modified on  : 09-03-2024
* @last modified by  : Rajesh Gajul
**/
@isTest
public class PCC_RebateClaimApproveControllerTest {
    
    public static User usr = new User();
    
    @testSetup
    public static void setUpData() {
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Opp_Bypass_Validation_Rule__c rec = new Core_Opp_Bypass_Validation_Rule__c();
            rec.Bypass__c = true;
            insert rec;   
        } 
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name = 'Write In Product';
        prod1.IsActive = True;
        prodList.add(prod1);
        
        Product2 prod2 = new Product2();
        prod2.Name = 'Intel Atom® CE4275 Media Processor';
        prod2.IsActive = TRUE;
        prod2.Core_Avail_for_New_Designs__c = TRUE;
        prod2.Core_Sales_Visible_Flag__c = TRUE;
        prod2.Core_Intel_vPro_Platform_Eligibility__c  = TRUE;       
        prod2.Core_Product_Org__c = 'Sales';
        prod2.Core_Product_Type__c = 'Processors';
        prod2.Core_Hierarchy_ID__c = '43';
        prod2.Core_Group_Code_Short_Name__c = 'CCG';
        prod2.Core_Processor_Number_Nm__c = '1234';
        prodList.add(prod2);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert prodList;
        }
        
        PricebookEntry pbe = new PricebookEntry(Product2Id = prodList[1].Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 10, IsActive = true);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert pbe;
        }
        
        Account accountInstance = new Account(Name = 'TestoppAcchandle', BillingStreet = '123 Fake St',
                                              BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                              BillingPostalCode = '12345',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert accountInstance;
        }
        Contact con = Core_Test_Utility.createContacts(1)[0];
        
        Id designOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.RecordTypeId = designOppRecTypeId;
        opportunityInstance.CloseDate = System.Today().addDays(24);
        opportunityInstance.StageName = 'Qualify';
        opportunityInstance.Name = 'TestRE1';
        opportunityInstance.AccountId =accountInstance.id;
        opportunityInstance.Core_Product_Segment__c='Client Computing';
        opportunityInstance.Core_Consumption_Market__c = 'Education';
        opportunityInstance.Core_Product_Application__c ='Business Mobility';
        opportunityInstance.Core_Opportunity_Type__c = 'Design: Original';
        opportunityInstance.Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity';
        opportunityInstance.Description = 'test';
        opportunityInstance.Core_IsClone__c = False;
        opportunityInstance.OwnerId= UserInfo.getUserId();
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opportunityInstance;
        }
        List<PCC_Rebate_Claim__c> prc_List = new List<PCC_Rebate_Claim__c>();
        PCC_Rebate_Claim__c rcInstance = new PCC_Rebate_Claim__c();
        rcInstance.PCC_Claim_Status__c = 'Draft';       
        rcInstance.PCC_Partner_Name__c = 'DELL';
        prc_List.add(rcInstance);
        
        PCC_Rebate_Claim__c rcInstance1 = new PCC_Rebate_Claim__c();
        rcInstance1.PCC_Claim_Status__c = 'Draft';       
        rcInstance1.PCC_Partner_Name__c = 'DELL';
        prc_List.add(rcInstance1);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert prc_List; 
        } 
        Pricing_UnifiedEndCustomerAccountMapping__c uniEndCustomerL1 = new Pricing_UnifiedEndCustomerAccountMapping__c();
        uniEndCustomerL1.Name = 'Write In End Customer';
        uniEndCustomerL1.Pricing_Active_cb__c = true;
        uniEndCustomerL1.Pricing_Account_Nm__c = accountInstance.Id;
        uniEndCustomerL1.Pricing_Unified_EndCustomer_Id__c = '1111';
        insert uniEndCustomerL1;
        
        Pricing_UnifiedEndCustomerCountryMapping__c uniEndCustomerL2 = new Pricing_UnifiedEndCustomerCountryMapping__c();
        uniEndCustomerL2.Name = 'FMH';
        uniEndCustomerL2.Pricing_Unified_EndCustomer_Act_Mapping__c = uniEndCustomerL1.Id;
        uniEndCustomerL2.Pricing_Country_Nm__c = 'Afghanistan';
        uniEndCustomerL2.Pricing_Unified_Country_EndCustomer_Id__c = '2222';
        insert uniEndCustomerL2;
        
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
        quote1.SBQQ__Account__c =  accountInstance.Id;
        quote1.SBQQ__PrimaryContact__c = con.Id;
        quote1.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
        quote1.Pricing_Project_Name_Nm__c = 'Test Project';
        quote1.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
        quote1.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
        quote1.Pricing_End_Customer__c = uniEndCustomerL1.Id;
        quote1.Pricing_Customer_Nm__c = 'FMH';
        quote1.Pricing_Unified_Global_End_Customer_Nm__c = uniEndCustomerL2.Id;
        quote1.Pricing_ShipmentStDate_Dt__c = system.today()+1;
        quote1.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
        quote1.Pricing_Bid_Dt__c = quote1.Pricing_ShipmentStDate_Dt__c.addDays(7);
        quote1.Pricing_Intel_Response_Requested_By_Date__c = quote1.Pricing_ShipmentStDate_Dt__c.addDays(7);
        quote1.Pricing_ShipmentEndDate_Dt__c = quote1.Pricing_ShipmentStDate_Dt__c.addDays(30);
        quote1.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
        quote1.Pricing_Region_Nm__c = 'APJ';
        quote1.SBQQ__PrimaryContact__c = con.id;
        quote1.SBQQ__Status__c = 'Submitted';
        quotes.add(quote1);
        insert quotes;
        
        
        List<Pricing_Competitor_Product__c> compprodList = new List<Pricing_Competitor_Product__c>();
        Pricing_Competitor_Product__c cp = new Pricing_Competitor_Product__c(
            Name = 'Product Z',
            Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z',
            Pricing_Active_cb__c = true,
            RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c', 'Pricing_Data_Center')
        );
        compprodList.add(cp);
        
        Id qliRecId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
        
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>(); 
        SBQQ__QuoteLine__c quoteLineob1 = new SBQQ__QuoteLine__c(); 
        quoteLineob1.RecordTypeId=qliRecId;
        quoteLineob1.Pricing_Product_Nm__c = prodList[1].Id;
        quoteLineob1.Pricing_Other_Product_Nm__c=null;
        quoteLineob1.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
        quoteLineob1.Pricing_Systems_qty__c = 6; 
        quoteLineob1.Pricing_pm_approval_comments_nm__c  = 'Test Comment';
        quoteLineob1.Pricing_CPUs_per_system_qty__c = 1;
        quoteLineob1.Pricing_Single_System_Price_Amt__c = 4;
        quoteLineob1.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
        quoteLineob1.Pricing_Req_Discounted_Unit_Price__c = 1;
        quoteLineob1.Pricing_Additional_OEM_Discount_Amt__c = 1;
        quoteLineob1.Pricing_Competetor_Product__c=cp.Id;
        quoteLineob1.Pricing_Other_Competitor_Product_Nm__c = null;  
        quoteLineob1.SBQQ__Quote__c = quotes[0].Id;
        quoteLineob1.Pricing_Status_Nm__c='Draft';
        quoteLineob1.Pricing_Approved_Start_Date_Dt__c = Date.newInstance(2024, 2, 9);
        quoteLineob1.Pricing_Approved_End_Date_Dt__c = Date.newInstance(2025, 3, 9);
        quoteLines.add(quoteLineob1);
        
        insert quoteLines;
        
        List<Pricing_Performance_Metric__c> mList=new List<Pricing_Performance_Metric__c>();
        Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
        metrics.Pricing_Comp_SKU_Performance_Nbr__c=1;
        metrics.Pricing_Intel_SKU_Performance_Nbr__c=1;
        metrics.Pricing_Other_Nm__c='test';
        metrics.Pricing_Performance_Metric_Nm__c='Other';
        metrics.Pricing_Quote_Line__c=quoteLines[0].Id;
        metrics.Pricing_Weighting_Pct__c=10;
        mList.add(metrics);
        
        insert mList;
        
        
        
        List<PCC_Rebate_Claim_Line_Item__c> rcList = new List<PCC_Rebate_Claim_Line_Item__c>();
        PCC_Rebate_Claim_Line_Item__c rc_line = new PCC_Rebate_Claim_Line_Item__c();
        rc_line.PCC_Rebate_Claim__c = prc_List[0].Id;
        rc_line.PCC_Quote_Line_Number__c = 	quoteLines[0].Id;
        rc_line.PCC_Opportunity__c= opportunityInstance.Id;
        rc_line.PCC_Product__c= prodList[1].Id;        
        rc_line.PCC_Quantity__c= 100;
        rc_line.PCC_Invoice__c= '2000'; 
        rc_line.PCC_OEM_Name__c = 'DELL';
        rc_line.PCC_Status__c = 'Submitted';
        rc_line.PCC_Invoice_Date__c = Date.newInstance(2024, 11, 12);
        rc_line.PCC_Claimed_Rebate_Amount__c = 50000;
        rcList.add(rc_line);
        
        PCC_Rebate_Claim_Line_Item__c rc_line1 = new PCC_Rebate_Claim_Line_Item__c();
        rc_line1.PCC_Rebate_Claim__c = prc_List[1].Id;
        rc_line1.PCC_Quote_Line_Number__c = quoteLines[0].Id;
        rc_line1.PCC_Opportunity__c= opportunityInstance.Id;
        rc_line1.PCC_Product__c= prodList[1].Id;        
        rc_line1.PCC_Quantity__c= 200;
        rc_line1.PCC_Invoice__c= '3000'; 
        rc_line1.PCC_OEM_Name__c = 'DELL New';
        rc_line1.PCC_Status__c = 'Submitted';
        rc_line1.PCC_Invoice_Date__c = Date.newInstance(2024, 12, 9);
        rc_line1.PCC_Claimed_Rebate_Amount__c = 5000;
        rcList.add(rc_line1);
        
        PCC_Rebate_Claim_Line_Item__c rc_line2 = new PCC_Rebate_Claim_Line_Item__c();
        rc_line2.PCC_Rebate_Claim__c = prc_List[0].Id;
        rc_line2.PCC_Quote_Line_Number__c = quoteLines[0].Id;
        rc_line2.PCC_Opportunity__c= opportunityInstance.Id;
        rc_line2.PCC_Product__c= prodList[1].Id;        
        rc_line2.PCC_Quantity__c= 34;
        rc_line2.PCC_Invoice__c= '3000'; 
        rc_line2.PCC_OEM_Name__c = 'Nokia';
        rc_line2.PCC_Status__c = 'Submitted';
        rc_line2.PCC_Invoice_Date__c = Date.newInstance(2024, 11, 12);
        rc_line2.PCC_Claimed_Rebate_Amount__c = 5000;
        rcList.add(rc_line2);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert rcList;
        }
        
        rcInstance.PCC_Claim_Status__c = 'Claim Submitted';
        rcInstance.PCC_Submitted_By__c = usr.Id;
        System.runAs(Core_Test_Utility.systemAdminUser) {
            update rcInstance;
        } 
        OpportunityLineItem OLI_line = new OpportunityLineItem();
        OLI_line.SBQQ__QuoteLine__c = quoteLines[0].Id;
        OLI_line.OpportunityId = opportunityInstance.Id;
        OLI_line.Quantity = 100;
        OLI_line.TotalPrice = 500;
        OLI_line.Product2Id = prodList[1].Id;
        OLI_line.PricebookEntryId = pbe.Id;
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert OLI_line;
        }
        OpportunityLineItem OLI_line2 = new OpportunityLineItem();
        OLI_line2.SBQQ__QuoteLine__c = quoteLines[0].Id;
        OLI_line2.OpportunityId = opportunityInstance.Id;
        OLI_line2.Quantity = 100;
        OLI_line2.TotalPrice = 500;
        OLI_line2.Product2Id = prodList[1].Id;
        OLI_line2.PricebookEntryId = pbe.Id;
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert OLI_line2;
        }
        List<Core_Opp_FC_Prod_Schedule__c> insertForeCastList = new List<Core_Opp_FC_Prod_Schedule__c>();
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opportunityInstance.Id, Core_FC_Opportunity_Product__c = OLI_line.Id, Core_Opp_Line_Item_RecordID__c = OLI_line.Id, Core_Opp_FC_Product__c = OLI_line.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(-6), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 50, Core_Opp_FC_isdeleted__c = false, Core_Core_FC_Appvd_SalesPrice__c=2000));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opportunityInstance.Id, Core_FC_Opportunity_Product__c = OLI_line.Id, Core_Opp_Line_Item_RecordID__c = OLI_line.Id, Core_Opp_FC_Product__c = OLI_line.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(-3), Core_Opp_FC_Approval_Status__c = 'Approved', Core_Opp_FC_Quantity__c = 134, Core_Opp_FC_isdeleted__c = false, Core_Core_FC_Appvd_SalesPrice__c=12000, Core_FC_Approved_Claim_Quantity_nbr__c = 10, Core_FC_Submitted_Claim_Quantity_nbr__c = 10));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opportunityInstance.Id, Core_FC_Opportunity_Product__c = OLI_line.Id, Core_Opp_Line_Item_RecordID__c = OLI_line.Id, Core_Opp_FC_Product__c = OLI_line.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Approval_Status__c = 'Submitted', Core_Opp_FC_Quantity__c = 34, Core_Opp_FC_isdeleted__c = false,Core_FC_Approved_Claim_Quantity_nbr__c = 10, Core_FC_Submitted_Claim_Quantity_nbr__c = 10));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opportunityInstance.Id, Core_FC_Opportunity_Product__c = OLI_line.Id, Core_Opp_Line_Item_RecordID__c = OLI_line.Id, Core_Opp_FC_Product__c = OLI_line.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(3), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 34, Core_Opp_FC_isdeleted__c = false,Core_FC_Approved_Claim_Quantity_nbr__c = 10, Core_FC_Submitted_Claim_Quantity_nbr__c = 10));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opportunityInstance.Id, Core_FC_Opportunity_Product__c = OLI_line.Id, Core_Opp_Line_Item_RecordID__c = OLI_line.Id, Core_Opp_FC_Product__c = OLI_line.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(4), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 100, Core_Opp_FC_isdeleted__c = false, Core_Core_FC_Appvd_SalesPrice__c=2000));
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert insertForeCastList;
        }
        
    }
    
    
    static testMethod void getRebateClaimLineItems_test() {
        PCC_Rebate_Claim__c rebateClaimId = [select id, PCC_Approval_Date__c, PCC_Approved_By__c, PCC_Claim_Status__c from PCC_Rebate_Claim__c limit 1];
        List<PCC_Rebate_Claim_Line_Item__c> rcLI = [select id,PCC_Invoice_Date__c,PCC_Quote_Line_Number__c,PCC_Quantity__c from PCC_Rebate_Claim_Line_Item__c where PCC_OEM_Name__c in ('DELL','Nokia')];
        Id pr = [SELECT id, Name FROM Profile WHERE Name='IT Admin'][0].Id;
        
        List<User> users = Core_Test_Utility.Core_User(1);        
        User user        = users[0];
        user.ProfileId   = pr;
        user.userName    = 'test0'+ user.userName ;
        insert user;
        
        Test.startTest();
        List<PCC_Rebate_Claim_Line_Item__c> getRebateClaimLineItem = PCC_RebateClaimApproveController.getRebateClaimLineItems(rebateClaimId.Id);
        system.assertEquals(true, getRebateClaimLineItem.size()>0); 
        
        PCC_RebateClaimApproveController.showErrorWrap errWrap1 = PCC_RebateClaimApproveController.showToast(rebateClaimId.Id);
        
        system.assertEquals(true, errWrap1<>null); 
        
        System.runAs(user) {
            PCC_RebateClaimApproveController.showErrorWrap errWrap2 = PCC_RebateClaimApproveController.showToast(rebateClaimId.Id);
        } 
        
        String jsonRebateClaimLI = '[{\"PCC_Status__c\":\"Approved\",\"PCC_Rejection_Code__c\":\"\",\"PCC_Rejection_Comments__c\":\"\",\"Id\":\"'+rcLI[0].Id+'\",\"PCC_Invoice_Date__c\":\"2024-11-12\",\"PCC_Quantity__c\":\"'+rcLI[0].PCC_Quantity__c+'\",\"PCC_Quote_Line_Number__c\":\"'+rcLI[0].PCC_Quote_Line_Number__c+'\"}]';
        boolean updateClaimLineItems1 = PCC_RebateClaimApproveController.updateClaimLineItemsDataList(jsonRebateClaimLI,rebateClaimId.Id,0);
        
        String jsonRebateClaimLI2 = '[{\"PCC_Status__c\":\"Rejected\",\"PCC_Rejection_Code__c\":\"Duplicate Submission\",\"PCC_Rejection_Comments__c\":\"Rejected\",\"Id\":\"'+rcLI[0].Id+'\",\"PCC_Invoice_Date__c\":\"2024-11-12\",\"PCC_Quantity__c\":\"'+rcLI[0].PCC_Quantity__c+'\",\"PCC_Quote_Line_Number__c\":\"'+rcLI[0].PCC_Quote_Line_Number__c+'\"}]';
        boolean updateClaimLineItems2 = PCC_RebateClaimApproveController.updateClaimLineItemsDataList(jsonRebateClaimLI2,rebateClaimId.Id,0);
        
        String jsonRebateClaimLI3 = '[{\"PCC_Status__c\":\"Approved\",\"PCC_Rejection_Code__c\":\"\",\"PCC_Rejection_Comments__c\":\"\",\"Id\":\"'+rcLI[1].Id+'\",\"PCC_Invoice_Date__c\":\"2024-11-12\",\"PCC_Quantity__c\":\"'+rcLI[1].PCC_Quantity__c+'\",\"PCC_Quote_Line_Number__c\":\"'+rcLI[1].PCC_Quote_Line_Number__c+'\"}]';
        boolean updateClaimLineItems3 = PCC_RebateClaimApproveController.updateClaimLineItemsDataList(jsonRebateClaimLI3,rebateClaimId.Id,0);
        
        String jsonRebateClaimLI4 = '[{\"PCC_Status__c\":\"Approved\",\"PCC_Rejection_Code__c\":\"\",\"PCC_Rejection_Comments__c\":\"\",\"Id\":\"'+rcLI[1].Id+'\",\"PCC_Invoice_Date__c\":\"2024-11-12\",\"PCC_Quantity__c\":\"144\",\"PCC_Quote_Line_Number__c\":\"'+rcLI[1].PCC_Quote_Line_Number__c+'\"}]';
        boolean updateClaimLineItems4 = PCC_RebateClaimApproveController.updateClaimLineItemsDataList(jsonRebateClaimLI4,rebateClaimId.Id,0);
        
        String jsonRebateClaimLI5 = '[{\"PCC_Status__c\":\"Submitted\",\"PCC_Rejection_Code__c\":\"\",\"PCC_Rejection_Comments__c\":\"\",\"Id\":\"'+rcLI[1].Id+'\",\"PCC_Invoice_Date__c\":\"2024-11-12\",\"PCC_Quantity__c\":\"144\",\"PCC_Quote_Line_Number__c\":\"'+rcLI[1].PCC_Quote_Line_Number__c+'\"}]';
        boolean updateClaimLineItems5 = PCC_RebateClaimApproveController.updateClaimLineItemsDataList(jsonRebateClaimLI5,rebateClaimId.Id,0);
        
        try{
            boolean updateClaimLineItems6 = PCC_RebateClaimApproveController.updateClaimLineItemsDataList(null,rebateClaimId.Id,0);
        }catch(Exception ex){
            System.debug ('all right' + ex.getMessage());
            return;
        }        
        Test.stopTest(); 
    }
    
    static testMethod void testGet6QPSData() {
        // Test data setup
        // Prepare JSON strings for test
        Map<Id, Double> rebateAppQtyMap = new Map<Id, Double>();
        Map<Id, Double> rebateRejQtyMap = new Map<Id, Double>();
        for(PCC_Rebate_Claim_Line_Item__c lineItem : [select id,PCC_Quote_Line_Number__c,PCC_Quantity__c from PCC_Rebate_Claim_Line_Item__c where PCC_OEM_Name__c = 'DELL'  Limit 1]){
            
            rebateAppQtyMap.put(lineItem.PCC_Quote_Line_Number__c , lineItem.PCC_Quantity__c);
        }
        for(PCC_Rebate_Claim_Line_Item__c lineItem : [select id,PCC_Quote_Line_Number__c,PCC_Quantity__c from PCC_Rebate_Claim_Line_Item__c where PCC_OEM_Name__c = 'DELL New' Limit 1]){
            rebateRejQtyMap.put(lineItem.PCC_Quote_Line_Number__c , lineItem.PCC_Quantity__c);
            
        }
        
        String rebateAppQtyJson = JSON.serialize(rebateAppQtyMap);
        String rebateRejQtyJson = JSON.serialize(rebateRejQtyMap);
        Test.startTest();
        // Call the method to test
        PCC_RebateClaimApproveController.rebateQuoteLineError result = PCC_RebateClaimApproveController.get6QPSData(rebateAppQtyJson, rebateRejQtyJson);
        // Verify the results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(!result.errorMsgWrpallqty.equals(null), 'errorMsgWrpallqty should be empty');
        System.assert(!result.errorMsgWrpsubQty.equals(null), 'errorMsgWrpsubQty should be empty');
        Test.stopTest();
    }
    static testMethod void miscellaneousMethods_test() {
        Date dt1 = PCC_RebateClaimApproveController.getQuarterEndDateFromQtrName('2025-Q1');
        Date dt2 = PCC_RebateClaimApproveController.getQuarterEndDateFromQtrName('2025-Q2');
        Date dt3 = PCC_RebateClaimApproveController.getQuarterEndDateFromQtrName('2025-Q3');
        Date dt4 = PCC_RebateClaimApproveController.getQuarterEndDateFromQtrName('2025-Q4');
        Date dt5 = PCC_RebateClaimApproveController.getQuarterEndDateFromQtrName('2025-Q5');
        Date dt6 = PCC_RebateClaimApproveController.getQuarterStartDateFromQtrName('2025-Q1');
        Date dt7 = PCC_RebateClaimApproveController.getQuarterStartDateFromQtrName('2025-Q2');
        Date dt8 = PCC_RebateClaimApproveController.getQuarterStartDateFromQtrName('2025-Q3');
        Date dt9 = PCC_RebateClaimApproveController.getQuarterStartDateFromQtrName('2025-Q4');
        Date dt10 = PCC_RebateClaimApproveController.getQuarterStartDateFromQtrName('2025-Q5');
        String Quarter1 = PCC_RebateClaimApproveController.getQuarterFromDate(Date.newInstance(2024, 12, 9));
        String Quarter2 = PCC_RebateClaimApproveController.getQuarterFromDate(Date.newInstance(2024, 5, 9));
        
        PCC_Rebate_Claim__c rebateClaimId = [select id, PCC_Approval_Date__c, PCC_Approved_By__c, PCC_Claim_Status__c from PCC_Rebate_Claim__c limit 1];
        List<PCC_Rebate_Claim_Line_Item__c> rcLI = [select id,PCC_Invoice_Date__c,PCC_Quote_Line_Number__c,PCC_Quantity__c from PCC_Rebate_Claim_Line_Item__c where PCC_OEM_Name__c in ('DELL','Nokia')];
        system.assertEquals(true, rcLI.size()>0); 
        Test.startTest();
        
        String jsonRebateClaimLI2 = '[{\"PCC_Status__c\":\"Approved\",\"PCC_Rejection_Code__c\":\"\",\"PCC_Rejection_Comments__c\":\"\",\"Id\":\"'+rcLI[1].Id+'\",\"PCC_Invoice_Date__c\":\"2025-03-12\",\"PCC_Quantity__c\":\"144\",\"PCC_Quote_Line_Number__c\":\"'+rcLI[1].PCC_Quote_Line_Number__c+'\"}]';
        boolean updateClaimLineItems2 = PCC_RebateClaimApproveController.updateClaimLineItemsDataList(jsonRebateClaimLI2,rebateClaimId.Id,0);
        try{
            String jsonRebateClaimLI1 = '[{\"PCC_Status__c\":\"Approved\",\"PCC_Rejection_Code__c\":\"\",\"PCC_Rejection_Comments__c\":\"\",\"Id\":\"'+rcLI[1].Id+'\",\"PCC_Quantity__c\":\"144\",\"PCC_Quote_Line_Number__c\":\"'+rcLI[1].PCC_Quote_Line_Number__c+'\"}]';
            boolean updateClaimLineItems1 = PCC_RebateClaimApproveController.updateClaimLineItemsDataList(jsonRebateClaimLI1,rebateClaimId.Id,0);
        }catch(Exception ex){
            System.debug ('all right' + ex.getMessage());
            return;
        }        
        Test.stopTest();
    }    
}