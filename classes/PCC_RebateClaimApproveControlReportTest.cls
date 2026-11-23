@isTest
public class PCC_RebateClaimApproveControlReportTest {

    @isTest (SeeAllData= true)
    public static void testAsyncReportWithTestData() {

      List <Report> reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName = 'Rebate_Claim_INTEL_CONFIDENTIAL_Xhw'];

      String reportId = (String)reportList.get(0).get('Id');
      PCC_Rebate_Claim__c rcInstance = new PCC_Rebate_Claim__c();
        rcInstance.PCC_Claim_Status__c = 'Draft';       
        rcInstance.PCC_Partner_Name__c = 'DELL';
        insert rcInstance;
      // Create an Opportunity object.
      // //Opportunity opp = new Opportunity(Name='ApexTestOpp', StageName='stage',Probability = 95, CloseDate=system.today());

      //insert opp;

      Reports.ReportMetadata reportMetadata = Reports.ReportManager.describeReport(reportId).getReportMetadata();

      // Add a filter.

      List<Reports.ReportFilter> filters = new List<Reports.ReportFilter>(); 

      Reports.ReportFilter newFilter = new Reports.ReportFilter();

      newFilter.setColumn('CUST_NAME');

      newFilter.setOperator('equals');

      newFilter.setValue('ApexTestOpp');

      filters.add(newFilter);

      reportMetadata.setReportFilters(filters);

      Test.startTest();
        PCC_RebateClaimApproveController.getRCData(rcInstance.Id);
      Reports.ReportInstance instanceObj = Reports.ReportManager.runAsyncReport(reportId,reportMetadata,false);
      

      String instanceId = instanceObj.getId();

      // Report instance is not available yet.

      Test.stopTest();

      // After the stopTest method, the report has finished executing

      // and the instance is available.

      instanceObj = Reports.ReportManager.getReportInstance(instanceId);

      System.assertEquals(instanceObj.getStatus(),'Success');

      Reports.ReportResults result = instanceObj.getReportResults();

      Reports.ReportFact grandTotal = (Reports.ReportFact)result.getFactMap().get('T!T');

      //System.assertEquals('0E-18',(String)grandTotal.getAggregates().get(1).getValue());

    }
    //@isTest(SeeAllData='true')
    /*public static void testSyncReportWithTestData() {

      // Create an Opportunity Object.

      //Opportunity opp = new Opportunity(Name='ApexTestOpp', StageName='stage',Probability = 95, CloseDate=system.today());

      //insert opp;

      List <Report> reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName = 'Rebate_Claim_INTEL_CONFIDENTIAL_Xhw'];

      String reportId = (String)reportList.get(0).get('Id');

      Reports.ReportMetadata reportMetadata = Reports.ReportManager.describeReport(reportId).getReportMetadata();

      // Add a filter.

      List<Reports.ReportFilter> filters = new List<Reports.ReportFilter>(); 

      Reports.ReportFilter newFilter = new Reports.ReportFilter();

      newFilter.setColumn('CUST_NAME');

      newFilter.setOperator('equals');

      newFilter.setValue('ApexTestOpp');

      filters.add(newFilter);

      reportMetadata.setReportFilters(filters);

      Reports.ReportResults result = Reports.ReportManager.runReport(reportId,reportMetadata,false); 

      Reports.ReportFact grandTotal = (Reports.ReportFact)result.getFactMap().get('T!T');

      //System.assertEquals(1,(Decimal)grandTotal.getAggregates().get(1).getValue());

    }*/
    public static User usr = new User();
    //@isTest (SeeAllData= true)
    /*public static void getRCDatanew() {
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Opp_Bypass_Validation_Rule__c rec = new Core_Opp_Bypass_Validation_Rule__c();
            rec.Bypass__c = true;
            //insert rec;   
        } 
                
        Product2 p = new Product2();
        p.Name = 'Intel Atom® CE4275 Media Processor';
        p.IsActive = TRUE;
        p.Core_Avail_for_New_Designs__c = TRUE;
        p.Core_Sales_Visible_Flag__c = TRUE;
        p.Core_Intel_vPro_Platform_Eligibility__c  = TRUE;       
        p.Core_Product_Org__c = 'Sales';
        p.Core_Product_Type__c = 'Processors';
        p.Core_Hierarchy_ID__c = '43';
        //p.Core_Group_Code_Short_Name__c = 'CCG';
        p.Core_Group_Code_Short_Name__c = 'CCG';
        p.Core_Processor_Number_Nm__c = '1234';
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert p;
        }
        
        Product2 prod1 = new Product2();
        prod1.Name = 'Write In Product';
        prod1.IsActive = True;
        insert prod1;
        
        PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 10, IsActive = true);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert pbe;
        }
        
        Account accountInstance = new Account();
        accountInstance.Name = 'TestoppAcchandl';
        accountInstance.BillingStreet = '123 Fake St';
        accountInstance.BillingCity = 'Springfield';
        accountInstance.BillingState = 'IL';
        accountInstance.BillingCountry = 'USA';
        accountInstance.Industry='Agriculture';
        accountInstance.Core_Sub_Industry__c= 'Crop Production';
        accountInstance.BillingPostalCode = '12345';
        //accountInstance.Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
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
            quoteLineob1.Pricing_Product_Nm__c = p.Id;
            //quoteLineob.SBQQ__Product__c = prod.Id;
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
        rc_line.PCC_Product__c= p.Id;        
        rc_line.PCC_Quantity__c= 100;
        rc_line.PCC_Invoice__c= '2000'; 
        rc_line.PCC_OEM_Name__c = 'DELL';
        rc_line.PCC_Status__c = 'Submitted';
        rc_line.PCC_Invoice_Date__c = Date.newInstance(2024, 12, 9);
        rc_line.PCC_Claimed_Rebate_Amount__c = 50000;
        rcList.add(rc_line);
        
        PCC_Rebate_Claim_Line_Item__c rc_line1 = new PCC_Rebate_Claim_Line_Item__c();
        rc_line1.PCC_Rebate_Claim__c = prc_List[1].Id;
        rc_line1.PCC_Quote_Line_Number__c = quoteLines[0].Id;
        rc_line1.PCC_Opportunity__c= opportunityInstance.Id;
        rc_line1.PCC_Product__c= p.Id;        
        rc_line1.PCC_Quantity__c= 200;
        rc_line1.PCC_Invoice__c= '3000'; 
        rc_line1.PCC_OEM_Name__c = 'DELL New';
        rc_line1.PCC_Status__c = 'Submitted';
        rc_line1.PCC_Invoice_Date__c = Date.newInstance(2024, 12, 9);
        rc_line1.PCC_Claimed_Rebate_Amount__c = 5000;
        rcList.add(rc_line1);
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
        OLI_line.Product2Id = p.Id;
        OLI_line.PricebookEntryId = pbe.Id;
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert OLI_line;
        }
        List<Core_Opp_FC_Prod_Schedule__c> insertForeCastList = new List<Core_Opp_FC_Prod_Schedule__c>();
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opportunityInstance.Id, Core_Opp_Line_Item_RecordID__c = OLI_line.Id, Core_Opp_FC_Product__c = OLI_line.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(-3), Core_Opp_FC_Approval_Status__c = 'Approved', Core_Opp_FC_Quantity__c = 134, Core_Opp_FC_isdeleted__c = false, Core_Core_FC_Appvd_SalesPrice__c=12000, Core_FC_Approved_Claim_Quantity_nbr__c = 10, Core_FC_Submitted_Claim_Quantity_nbr__c = 10));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opportunityInstance.Id, Core_Opp_Line_Item_RecordID__c = OLI_line.Id, Core_Opp_FC_Product__c = OLI_line.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Approval_Status__c = 'Submitted', Core_Opp_FC_Quantity__c = 34, Core_Opp_FC_isdeleted__c = false,Core_FC_Approved_Claim_Quantity_nbr__c = 10, Core_FC_Submitted_Claim_Quantity_nbr__c = 10));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opportunityInstance.Id, Core_Opp_Line_Item_RecordID__c = OLI_line.Id, Core_Opp_FC_Product__c = OLI_line.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(3), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 34, Core_Opp_FC_isdeleted__c = false,Core_FC_Approved_Claim_Quantity_nbr__c = 10, Core_FC_Submitted_Claim_Quantity_nbr__c = 10));
        System.runAs(Core_Test_Utility.systemAdminUser) {
             insert insertForeCastList;
        }
        List<Core_Opp_FC_Prod_Schedule__c> insertForeCastList1 = new List<Core_Opp_FC_Prod_Schedule__c>();
        insertForeCastList1.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opportunityInstance.Id, Core_Opp_Line_Item_RecordID__c = OLI_line.Id, Core_Opp_FC_Product__c = OLI_line.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(-3), Core_Opp_FC_Approval_Status__c = 'Approved', Core_Opp_FC_Quantity__c = 100, Core_Opp_FC_isdeleted__c = false, Core_Core_FC_Appvd_SalesPrice__c=2000));
        insert insertForeCastList1;
        
        Test.startTest();
        PCC_RebateClaimApproveController.getRCData(prc_List[0].Id);
         //PCC_RebateClaimApproveController.getFilters(prc_List[0].Name);
        Test.stopTest();
       
    }*/


}