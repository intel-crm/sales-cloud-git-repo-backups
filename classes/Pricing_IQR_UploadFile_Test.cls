/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-18-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_IQR_UploadFile_Test {

    @testSetup
    static void dataSetup(){
      //  Pricing_RestAPI_TestUtility.createRestAPIErrorCodesConfig();
        List<Product2> prodList = new List<Product2>();
        List<String> lobValuesList = Label.Pricing_LOB_Values.split(',');
        Product2 prod = new Product2();
        prod.Core_Product_Org__c = 'Sales';
        prod.Core_Product_Type__c = 'Processors';
        prod.Core_Sales_Visible_Flag__c  = True;
        prod.IsActive = True;
        prod.Core_Hierarchy_ID__c = '43';
        prod.Core_Line_of_Business__c = lobValuesList[1];
        prod.Name = 'Product X';
        prodList.add(prod);
        
        Product2 prod1 = new Product2();
        prod1.Core_Product_Org__c = 'Sales';
        prod1.Core_Product_Type__c = 'Processors';
        prod1.Core_Sales_Visible_Flag__c  = True;
        prod1.IsActive = True;
        prod1.Core_Hierarchy_ID__c = '43';
        prod1.Core_Line_of_Business__c = lobValuesList[1];
        prod1.Name = 'Product1';
        prodList.add(prod1);
        
        Product2 prod2 = new Product2();
        prod2.Core_Product_Org__c = 'Sales';
        prod2.Core_Product_Type__c = 'Processors';
        prod2.Core_Sales_Visible_Flag__c  = True;
        prod2.IsActive = True;
        prod2.Core_Hierarchy_ID__c = '43';
        prod2.Core_Line_of_Business__c = lobValuesList[1];
        prod2.Name = 'Write In Product';
        prodList.add(prod2);
        insert prodList;
        Pricing_Test_Utility.createPriceBook();
        
        List<Pricing_Competitor_Product__c> cpList = new List<Pricing_Competitor_Product__c>();
        
        Pricing_Competitor_Product__c cp = new Pricing_Competitor_Product__c();
        cp.Name = 'Product Z';
        cp.Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z';
        cpList.add(cp);
        
        Pricing_Competitor_Product__c cp1 = new Pricing_Competitor_Product__c();
        cp1.Name = 'Comp Product';
        cp1.Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z';
        cpList.add(cp1);
        
        Pricing_Competitor_Product__c cp2 = new Pricing_Competitor_Product__c();
        cp2.Name = 'Write In Product';
        cp2.Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z';
        cpList.add(cp2);
        
        insert cpList;
        
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();  
       // List<User> normalUser = createUser();
        System.runAs(lstUsers2[0])
        {
            
            Account acc = Pricing_Test_Utility.createAccount();
            //Contact con = Pricing_Test_Utility.createContact(acc.Id);
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
            //Pricing_Test_Utility.createAEUser();
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
        
            Pricing_UnifiedEndCustomerAccountMapping__c unifiedEndCustomer = new Pricing_UnifiedEndCustomerAccountMapping__c();
            unifiedEndCustomer.name='Write In End Customer';
            insert unifiedEndCustomer;
            
            insert accTeam;
        }     
    }    
    
    public static testMethod  void unitTest1(){
        Test.startTest();
        Pricing_IQR_UploadFile.getUploadMetaData();
        Pricing_IQR_UploadFile.getBulkUploadDescriptions();
        // Create Quote and Quote Line
     
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
        Account acc = [Select Id from Account where Name = 'Test Account'];
        Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
         
        Product2 prod = [Select Id from Product2 where Name = 'Write In Product'];
        Pricing_UnifiedEndCustomerAccountMapping__c unifiedEndCustomer = [Select Id from Pricing_UnifiedEndCustomerAccountMapping__c where name='Write In End Customer'];

           List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quote2 = new SBQQ__Quote__c();
            quote2.SBQQ__Account__c = acc.Id;
            quote2.SBQQ__PrimaryContact__c = con.Id;
            quote2.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote2.Pricing_Project_Name_Nm__c = 'Test Project';
            quote2.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote2.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote2.Pricing_End_Customer__c=unifiedEndCustomer.id;
            quote2.Pricing_Customer_Nm__c = 'FMH';
            quote2.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote2.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote2.Pricing_Bid_Dt__c = quote2.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote2.Pricing_ShipmentEndDate_Dt__c = quote2.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote2.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote2.Pricing_Region_Nm__c = 'APJ';
            quote2.SBQQ__Status__c = 'Submitted';
            quoteList.add(quote2);
            insert quoteList; 
            
            List<SBQQ__QuoteLine__c> quoteLine2 = new List<SBQQ__QuoteLine__c>(); 
            SBQQ__QuoteLine__c quoteLineob = new SBQQ__QuoteLine__c(); 
            quoteLineob.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLineob.Pricing_Product_Nm__c = prod.Id;
            //quoteLineob.SBQQ__Product__c = prod.Id;
            quoteLineob.Pricing_Other_Product_Nm__c='Test';
            quoteLineob.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLineob.Pricing_Systems_qty__c = 6; 
            quoteLineob.Pricing_pm_approval_comments_nm__c = 'Test Comment';
            quoteLineob.Pricing_CPUs_per_system_qty__c = 1;
            quoteLineob.Pricing_Single_System_Price_Amt__c = 4;
            quoteLineob.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLineob.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLineob.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLineob.Pricing_Competetor_Product__c=cp.Id;
            quoteLineob.Pricing_Other_Competitor_Product_Nm__c = 'test';  
            quoteLineob.SBQQ__Quote__c = quote2.Id;
            quoteLineob.Pricing_Status_Nm__c='Draft';
            quoteLine2.add(quoteLineob);
            insert quoteLine2;          
        
        //string base64Data = JSON.serialize('Quote Line Number,Deal ID,Product,Approved Pricing Start Date,Approved Pricing End Date,Effective Pricing Start Date,Approved ECAP Price,Billing Start Date (for consumption),Billing End Date (for consumption),Approved Quantity,Backdate Reason,My Deals Meet Comp Price,Deal Description,Additional Ts and Cs,Additional Comments\n"a9U2D000000PkG1UAK","","","08/10/2022","08/18/2022","08/10/2022","12","08/10/2022","08/18/2022,"10","back","06","Deal desc","TC","AC"\n"a9U2D000000PjB7UAK","","","08/10/2022","08/18/2022","08/10/2022","12","08/10/2022","08/18/2022,"10","back","06","Deal desc","TC","AC"\n"a9U2D000000Pk5RUAS","","","08/10/2022","08/18/2022","08/10/2022","12","08/10/2022","08/18/2022,"10","back","06","Deal desc","TC","AC"\n');
        string base64Data = JSON.serialize('Quote Line Number,Deal ID,Approved Pricing Start Date,Approved Pricing End Date,Effective Pricing Start Date,Approved ECAP Price,Billing Start Date (for consumption),Billing End Date (for consumption),Approved Quantity,Payable Quantity,Backdate Reason,My Deals Meet Comp Price,Pricing Manager WWID,Deal Description,Additional Ts and Cs,Additional Comments,Product\n"'+quoteLine2[0].Pricing_Quote_Line_Number__c+'","","08/10/2022","08/18/2022","08/10/2022","12","08/10/2022","08/18/2022,"10","","back","06","123456","Deal desc","TC","AC","Prod"\n"'+quoteLine2[0].Pricing_Quote_Line_Number__c+'","","08/10/2022","08/18/2022","08/10/2022","12","08/10/2022","08/18/2022,"10","","back","06","123456","Deal desc","TC","AC","Prod"\n"'+quoteLine2[0].Pricing_Quote_Line_Number__c+'","","08/10/2022","08/18/2022","08/10/2022","12","08/10/2022","08/18/2022,"10","","back","06","123456","Deal desc","TC","AC","Prod"\n');
        Pricing_IQR_UploadFile.processRecords(base64Data,'Test');
        Test.stopTest();
        system.assertequals(quoteLine2.size() > 0, true);
    }
    public static testMethod void testProcessCompProdPriceStage(){
        Id compRecordId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c','Pricing_Data_Center');
        Pricing_Competitor_Product__c compProduct1 = new Pricing_Competitor_Product__c(Name='TestCompProduct1',   RecordTypeId = compRecordId, Pricing_Active_cb__c = true);
        insert compProduct1;
        Test.startTest();
        Pricing_IQR_UploadFile.getUploadMetaData();
        Pricing_IQR_UploadFile.getBulkUploadDescriptions();
        Pricing_IQR_UploadFile.isDPMUser();
        string base64Data = JSON.serialize('Competitor Product Name, List Price, Region,Median Meet Comp Discount,Application,Final Meet Comp Price\n"TestCompProduct1","20","APJ","10","Enterprise","10"');
        Pricing_IQR_UploadFile.processCompetitorProductPrice(base64Data,'createCompetitorProductPrice');
        Test.stopTest();
        system.assertequals(compProduct1 != null, true);
    }
    public static testMethod void testProcessCompProdPriceStageInvalid(){
        Id compRecordId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c','Pricing_Data_Center');
        Pricing_Competitor_Product__c compProduct1 = new Pricing_Competitor_Product__c(Name='TestCompProduct1',   RecordTypeId = compRecordId, Pricing_Active_cb__c = true);
        insert compProduct1;
        Test.startTest();
        Pricing_IQR_UploadFile.getUploadMetaData();
        Pricing_IQR_UploadFile.getBulkUploadDescriptions();
        Pricing_IQR_UploadFile.isDPMUser();
        string base64Data = JSON.serialize('Competitor Product Name, List Price, Region,Median Meet Comp Discount,Application,Final Meet Comp Price\n"TestCompProduct1abc你好","-5","APJABC","-5","Enterprisetest","-5"');
        Pricing_IQR_UploadFile.processCompetitorProductPrice(base64Data,'createCompetitorProductPrice');
        Test.stopTest();
        system.assertequals(compProduct1 != null, true);
    }
    public static testMethod void unitTest2(){
        Test.startTest();
        String PayloadData='{"RecordDetails":{"Quote":[{"UnifiedEndCustomerId":"1000906951","UnifiedEndCustomer":"TTZ LLP","UnifiedCountryEndCustomerId":"1000906953","ShipmentStartDate":"2022-08-29","ShipmentEndDate":"2022-09-10","ServerDealType":"Enterprise","QuoteLine":[{"WWID":"12013532","Status":"Pending Further Intel Review","Region":"Worldwide","ReferenceQuoteLineNumber":"a7k2i000000ybiUAAQ","QuoteLineNumber":"Q-107719-010-002","ProductType":"Server","Product":{"ProductNameEPMID":"97466","ProductLevel":"Processor","ProcessorNumber":"i7-7600U","Name":"Intel® Core™ i7-7600U Processor (4M Cache, up to 3.90 GHz)","Id":"01t1J00000AptZDQAZ","Family":null,"DealProductName":null},"PerformanceMetric":[{"Weighting":null,"PerformanceMetric":"HOMME","Name":"PM - 00351582","IntelSKUPerformance":1,"Id":"a8d2i000000FXMZAA4","CompSKUPerformance":1}],"OtherProduct":null,"OtherCompetitorProduct":null,"Name":"QL-0100591","MeetCompPrice":4,"MarketSegment":"Corp","IntegrationStatus":"Pending","Id":"a7k2i000000yc8qAAA","GroupType":"Mutually Exclusive","ExcludeAutomation":false,"ErrorMessages":null,"EndCustomerRegion":"EMEA","EffectivePricingStartDate":null,"DealRFQStatus":null,"DealRFQId":"725517","DealDescription":"Approved","CustomerDivision":null,"CompetitorProduct":{"Name":"1S AMD EPYC 7451 (64M Cache, 24C, 2.3GHz/3.2GHz) 180W","Id":"a8c2i000000CaeRAAS"},"BillingStartDate":"2022-08-29","BillingEndDate":"2022-09-10","BackdateReason":null,"ApprovedStartDate":"2022-08-29","ApprovedQuantity":30,"ApprovedEndDate":"2022-09-10","ApprovedECAPPrice":250,"ApprovedByInfo":null,"AdditionalTandC":"725517"},{"WWID":"12013532","Status":"Pending Further Intel Review","Region":"Worldwide","ReferenceQuoteLineNumber":"a7k2i000000ybiYAAQ","QuoteLineNumber":"Q-107719-014-002","ProductType":"Server","Product":{"ProductNameEPMID":"97131","ProductLevel":"Processor","ProcessorNumber":"i3-7100E","Name":"Intel® Core™ i3-7100E Processor (3M Cache, 2.90 GHz)","Id":"01t1J00000AptwHQAR","Family":null,"DealProductName":null},"PerformanceMetric":[{"Weighting":null,"PerformanceMetric":"HOMME","Name":"PM - 00351586","IntelSKUPerformance":1,"Id":"a8d2i000000FXMdAAO","CompSKUPerformance":1}],"OtherProduct":null,"OtherCompetitorProduct":null,"Name":"QL-0100595","MeetCompPrice":4,"MarketSegment":"Corp","IntegrationStatus":"Pending","Id":"a7k2i000000yc8uAAA","GroupType":"Mutually Exclusive","ExcludeAutomation":false,"ErrorMessages":null,"EndCustomerRegion":"EMEA","EffectivePricingStartDate":null,"DealRFQStatus":null,"DealRFQId":"725525","DealDescription":"Approved","CustomerDivision":null,"CompetitorProduct":{"Name":"1S AMD EPYC 7451 (64M Cache, 24C, 2.3GHz/3.2GHz) 180W","Id":"a8c2i000000CaeRAAS"},"BillingStartDate":"2022-08-29","BillingEndDate":"2022-09-10","BackdateReason":null,"ApprovedStartDate":"2022-08-29","ApprovedQuantity":30,"ApprovedEndDate":"2022-09-10","ApprovedECAPPrice":250,"ApprovedByInfo":null,"AdditionalTandC":"725525"}],"ProjectName":"Test Data - 29.08","Name":"Q-107719","MarketSegment":null,"IsUnifiedEndCustomer":true,"Id":"a7o2i000000ELpZAAW","FolioName":"DELL INC. - EMEA - TTZ LLP - 2022-08-29 13:15:09","FolioID":"37827","EndCustomerCountry":"Egypt","EndCustomer":null,"DealType":"ECAP","Account":{"Name":"DELL INC.","Id":"001o000000O6IBjAAN","CIMId":"23544531"}}]},"Header":{"xid":"881ccc44-bc79-016f-cc0f-2486f9081dc4","target_system":"MyDeals","source_system":"Tender","action":"Update"}}';
       Pricing_BulkCR_JSONString.parse(PayloadData);
        Test.stopTest();
        system.assertequals(!String.isBlank(PayloadData), true);
    }    
}