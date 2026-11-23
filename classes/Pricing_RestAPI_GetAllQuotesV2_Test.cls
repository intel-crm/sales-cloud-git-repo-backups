/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-18-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_RestAPI_GetAllQuotesV2_Test {
    @testSetup 
    private static void createData(){
        Pricing_RestAPI_TestUtility.createRestAPIErrorCodesConfig();
        List<Product2> prodList = new List<Product2>();
        List<String> lobValuesList = Label.Pricing_LOB_Values.split(',');
        Product2 prod = new Product2();
        prod.Core_Product_Org__c = 'Sales';
        prod.Core_Product_Type__c = 'Processors';
        prod.Core_Sales_Visible_Flag__c  = True;
        prod.IsActive = True;
        prod.Core_Line_of_Business__c = lobValuesList[0];
        prod.Core_Processor_Number_Nm__c = 'P6500';
        prod.Core_Hierarchy_ID__c = '43';
        prod.Name = 'Product X';
        prodList.add(prod);
        
        Product2 prod1 = new Product2();
        prod1.Name = 'Write In Product';
        prod1.IsActive = True;
        prodList.add(prod1);
        
        Pricing_Test_Utility.createPriceBook();
        
        Pricing_Competitor_Product__c cp = new Pricing_Competitor_Product__c(
            Name = 'Product Z',
            Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z',
            RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c', 'Pricing_Data_Center'),
            Pricing_Active_cb__c = true
        );
        
        insert prodList;
        insert cp;
        
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();
        
        
        System.runAs(lstUsers2[0])
        { 
            Account acc = Pricing_Test_Utility.createAccount();
            //Contact con = Pricing_Test_Utility.createContact(acc.Id);
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Rest_API_Get_All_Quotes_V2_Test');
            
            User usr = [SELECT id FROM User WHERE email='Rest_API_Get_All_Quotes_V2_Test@noemail.com'];
            Group grp = new Group();
            grp.name = 'PG: Partner';
            grp.Type = 'Regular'; 
            Insert grp; 
            
            //Create Group Member
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = usr.id;
            grpMem1.GroupId = grp.Id;
            Insert grpMem1;
            
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
            //Pricing_Test_Utility.createAEUser();
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            
            
            Pricing_QuoteProgram_CAPSize__c capRec = new Pricing_QuoteProgram_CAPSize__c();
            capRec.Name = 'Test Account';
            capRec.Pricing_Account_Id__c = acc.Id;
            capRec.Pricing_Active_cb__c = true;
            capRec.Pricing_Small_Deal_CAP_size_Number__c = 300;
            insert capRec;  
            
            Pricing_UnifiedEndCustomerAccountMapping__c uniEndCustomerL1 = new Pricing_UnifiedEndCustomerAccountMapping__c();
            uniEndCustomerL1.Name = 'Write In End Customer';
            uniEndCustomerL1.Pricing_Active_cb__c = true;
            uniEndCustomerL1.Pricing_Account_Nm__c = acc.Id;
            uniEndCustomerL1.Pricing_Unified_EndCustomer_Id__c = '1111';
            insert uniEndCustomerL1;
            
            Pricing_UnifiedEndCustomerCountryMapping__c uniEndCustomerL2 = new Pricing_UnifiedEndCustomerCountryMapping__c();
            uniEndCustomerL2.Name = 'FMH';
            uniEndCustomerL2.Pricing_Unified_EndCustomer_Act_Mapping__c = uniEndCustomerL1.Id;
            uniEndCustomerL2.Pricing_Country_Nm__c = 'Afghanistan';
            uniEndCustomerL2.Pricing_Unified_Country_EndCustomer_Id__c = '2222';
            insert uniEndCustomerL2;
            
            Id recId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            Id recIdClient = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Client_Quote_RecordType_Create);
            
            List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c =  acc.Id;
            quote.SBQQ__PrimaryContact__c = con.Id;
            quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote.Pricing_Project_Name_Nm__c = 'Test Project';
            quote.RecordTypeId=recId;
            quote.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote.Pricing_End_Customer__c = uniEndCustomerL1.Id;
            quote.Pricing_Customer_Nm__c = 'FMH';
            quote.Pricing_Unified_Global_End_Customer_Nm__c = uniEndCustomerL2.Id;
            quote.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote.Pricing_Intel_Response_Requested_By_Date__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote.Pricing_Region_Nm__c = 'APJ';
            quote.SBQQ__PrimaryContact__c = con.id;
            //insert quote;
            quotes.add(quote);
            insert quotes;
            
            List<SBQQ__Quote__c> quoteClients = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quoteClient = new SBQQ__Quote__c();
            quoteClient.SBQQ__Account__c =  acc.Id;
            quoteClient.SBQQ__PrimaryContact__c = con.Id;
            quoteClient.Pricing_Market_Segment_values_Nm__c = 'Corp';
            quoteClient.Pricing_Project_Name_Nm__c = 'Test Project123';
            quoteClient.RecordTypeId=recIdClient;
            quoteClient.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quoteClient.Pricing_End_Customer__c = uniEndCustomerL1.Id;
            quoteClient.Pricing_Customer_Nm__c = 'FMH';
            quoteClient.Pricing_Unified_Global_End_Customer_Nm__c = uniEndCustomerL2.Id;
            quoteClient.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quoteClient.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quoteClient.Pricing_Bid_Dt__c = quoteClient.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quoteClient.Pricing_Intel_Response_Requested_By_Date__c = quoteClient.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quoteClient.Pricing_ShipmentEndDate_Dt__c = quoteClient.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quoteClient.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quoteClient.Pricing_Region_Nm__c = 'APJ';
            quoteClient.SBQQ__PrimaryContact__c = con.id;
            quoteClients.add(quoteClient);
            insert quoteClients;
            
            test.startTest();
            Id qliRecId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            
            List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>(); 
            SBQQ__QuoteLine__c quoteLineob = new SBQQ__QuoteLine__c(); 
            quoteLineob.RecordTypeId=qliRecId;
            quoteLineob.Pricing_Product_Nm__c = prod.Id;
            //quoteLineob.SBQQ__Product__c = prod.Id;
            quoteLineob.Pricing_Other_Product_Nm__c=null;
            quoteLineob.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLineob.Pricing_Systems_qty__c = 6; 
            quoteLineob.Pricing_pm_approval_comments_nm__c = 'Test Comment';
            quoteLineob.Pricing_CPUs_per_system_qty__c = 1;
            quoteLineob.Pricing_Single_System_Price_Amt__c = 4;
            quoteLineob.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLineob.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLineob.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLineob.Pricing_Competetor_Product__c=cp.Id;
            quoteLineob.Pricing_Other_Competitor_Product_Nm__c = null;  
            quoteLineob.SBQQ__Quote__c = quote.Id;
            quoteLines.add(quoteLineob);
            
            SBQQ__QuoteLine__c newQuoteLine = new SBQQ__QuoteLine__c(); 
            newQuoteLine.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SSD_Quote_Line_Create);
            newQuoteLine.SBQQ__Quote__c = quote.Id;
            newQuoteLine.Pricing_Product_Nm__c = prod1.Id;
            newQuoteLine.Pricing_Other_Product_Nm__c = 'test';
            newQuoteLine.Pricing_Req_Discounted_Unit_Price__c = 100;
            newQuoteLine.Pricing_Competitor_OEM_Nm__c = 'test';
            newQuoteLine.Pricing_Total_Volume_Qty__c = 10;
            newQuoteLine.Pricing_Comp_Product_Txt__c = 'Test';
            newQuoteLine.Pricing_Comp_Unit_Price_Amt__c = 100;
            newQuoteLine.Pricing_Comp_Density_Nbr__c = 10;
            newQuoteLine.Pricing_VolumeByQuarterAndReasoning_Txt__c = 'test'; 
            quoteLines.add(newQuoteLine);
            
            SBQQ__QuoteLine__c newQuoteLine1 = new SBQQ__QuoteLine__c();
            newQuoteLine1.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_PMem_Quote_Line_Create);
            newQuoteLine1.SBQQ__Quote__c = quote.Id;
            newQuoteLine1.Pricing_Product_Nm__c = prod1.Id;
            newQuoteLine1.Pricing_Other_Product_Nm__c = 'test';
            newQuoteLine1.Pricing_Req_Discounted_Unit_Price__c = 100;
            newQuoteLine1.Pricing_Competitor_OEM_Nm__c = 'test';
            newQuoteLine1.Pricing_Total_Volume_Qty__c = 10;
            newQuoteLine1.Pricing_Comp_Unit_Price_Amt__c = 100;
            newQuoteLine1.Pricing_Comp_Density_Nbr__c = 10;
            newQuoteLine1.Pricing_Systems_qty__c = 10;
            newQuoteLine1.Pricing_CPUs_per_system_qty__c = 1;
            newQuoteLine1.Pricing_CPU_Txt__c = 'Test';
            newQuoteLine1.Pricing_DRAM_Density_nbr__c = 10;
            newQuoteLine1.Pricing_DRAM_per_System_qty__c = 1;
            newQuoteLine1.Pricing_Competitor_Systems_Cnt__c = 5;
            newQuoteLine1.Pricing_Comp_CPUs_per_system_Cnt__c = 1;
            newQuoteLine1.Pricing_Approved_Unit_Dup_Qty__c = 10;
            quoteLines.add(newQuoteLine1);
            
            SBQQ__QuoteLine__c newQuoteLine2 = new SBQQ__QuoteLine__c();
            newQuoteLine2.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_NIC_Quote_Line_Create);
            newQuoteLine2.SBQQ__Quote__c = quote.Id;
            newQuoteLine2.Pricing_Product_Nm__c = prod1.Id;
            newQuoteLine2.Pricing_Other_Product_Nm__c = 'test';
            newQuoteLine2.Pricing_Req_Discounted_Unit_Price__c = 100;
            newQuoteLine2.Pricing_Competitor_OEM_Nm__c = 'test';
            newQuoteLine2.Pricing_Total_Volume_Qty__c = 10;
            newQuoteLine2.Pricing_Comp_Unit_Price_Amt__c = 100;
            newQuoteLine2.Pricing_Comp_Density_Nbr__c = 10;
            newQuoteLine2.Pricing_Systems_qty__c = 10;
            newQuoteLine2.Pricing_CPUs_per_system_qty__c = 1;
            newQuoteLine2.Pricing_CPU_Txt__c = 'Test';
            newQuoteLine2.Pricing_DRAM_Density_nbr__c = 10;
            newQuoteLine2.Pricing_DRAM_per_System_qty__c = 1;
            newQuoteLine2.Pricing_Competitor_Systems_Cnt__c = 5;
            newQuoteLine2.Pricing_Comp_CPUs_per_system_Cnt__c = 1;
            newQuoteLine2.Pricing_Approved_Unit_Dup_Qty__c = 10;
            quoteLines.add(newQuoteLine2);
            
            SBQQ__QuoteLine__c newQuoteLineGPU = new SBQQ__QuoteLine__c();
            newQuoteLineGPU.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_GPU_DataCenter_QuoteLine_Create);
            newQuoteLineGPU.SBQQ__Quote__c = quote.Id;
            newQuoteLineGPU.Pricing_Product_Nm__c = prod1.Id;
            newQuoteLineGPU.Pricing_Other_Product_Nm__c = 'test';
            newQuoteLineGPU.Pricing_Req_Discounted_Unit_Price__c = 100;
            newQuoteLineGPU.Pricing_Competitor_OEM_Nm__c = 'test';
            newQuoteLineGPU.Pricing_Total_Volume_Qty__c = 10;
            newQuoteLineGPU.Pricing_Comp_Unit_Price_Amt__c = 100;
            newQuoteLineGPU.Pricing_Comp_Density_Nbr__c = 10;
            newQuoteLineGPU.Pricing_Systems_qty__c = 10;
            newQuoteLineGPU.Pricing_CPUs_per_system_qty__c = 1;
            newQuoteLineGPU.Pricing_CPU_Txt__c = 'Test';
            newQuoteLineGPU.Pricing_DRAM_Density_nbr__c = 10;
            newQuoteLineGPU.Pricing_DRAM_per_System_qty__c = 1;
            newQuoteLineGPU.Pricing_Competitor_Systems_Cnt__c = 5;
            newQuoteLineGPU.Pricing_Comp_CPUs_per_system_Cnt__c = 1;
            newQuoteLineGPU.Pricing_Approved_Unit_Dup_Qty__c = 10;
            quoteLines.add(newQuoteLineGPU);
            
            SBQQ__QuoteLine__c newQuoteLineClient = new SBQQ__QuoteLine__c();
            newQuoteLineClient.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_CCG_Quote_Line_Create);
            newQuoteLineClient.SBQQ__Quote__c = quoteClient.Id;
            newQuoteLineClient.Pricing_Product_Nm__c = prod1.Id;
            newQuoteLineClient.Pricing_Other_Product_Nm__c = 'test';
            newQuoteLineClient.Pricing_Req_Discounted_Unit_Price__c = 100;
            newQuoteLineClient.Pricing_Competitor_OEM_Nm__c = 'test';
            newQuoteLineClient.Pricing_Total_Volume_Qty__c = 10;
            newQuoteLineClient.Pricing_Comp_Unit_Price_Amt__c = 100;
            newQuoteLineClient.Pricing_Comp_Density_Nbr__c = 10;
            newQuoteLineClient.Pricing_Systems_qty__c = 10;
            newQuoteLineClient.Pricing_CPUs_per_system_qty__c = 1;
            newQuoteLineClient.Pricing_CPU_Txt__c = 'Test';
            newQuoteLineClient.Pricing_DRAM_Density_nbr__c = 10;
            newQuoteLineClient.Pricing_DRAM_per_System_qty__c = 1;
            newQuoteLineClient.Pricing_Competitor_Systems_Cnt__c = 5;
            newQuoteLineClient.Pricing_Comp_CPUs_per_system_Cnt__c = 1;
            newQuoteLineClient.Pricing_Approved_Unit_Dup_Qty__c = 10;
            quoteLines.add(newQuoteLineClient);
            
            insert quoteLines;
            test.stopTest();
        }
    }
    
    static testMethod void testgetAllQuotesV2withoutParam(){
        SBQQ__Quote__c quoteClient = [select Id from SBQQ__Quote__c 
                                      WHERE Pricing_Project_Name_Nm__c = 'Test Project123' Limit 1];
        User usr = [SELECT id, AccountId FROM User WHERE email='Rest_API_Get_All_Quotes_V2_Test@noemail.com'];
        product2 prodClient = new product2();
        List<String> lobValuesList = Label.Pricing_LOB_Values.split(',');
        prodClient.Core_product_Org__c = 'Sales';
        prodClient.Core_product_Type__c = 'Processors';
        prodClient.Core_Sales_Visible_Flag__c  = True;
        prodClient.IsActive = True;
        prodClient.Core_VerticalSegment__c = 'Desktop';
        prodClient.Core_Processor_Number_Nm__c = 'P6500';
        prodClient.Core_Hierarchy_ID__c = '43';
        prodClient.Core_Line_of_Business__c = lobValuesList[1];
        prodClient.Name = 'product Y';
        insert prodClient;
        system.runAs(usr){
            test.startTest();
            /*product2 prodClient = new product2();
prodClient.Core_product_Org__c = 'Sales';
prodClient.Core_product_Type__c = 'Processors';
prodClient.Core_Sales_Visible_Flag__c  = True;
prodClient.IsActive = True;
prodClient.Core_VerticalSegment__c = 'Desktop';
prodClient.Core_Processor_Number_Nm__c = 'P6500';
prodClient.Core_Hierarchy_ID__c = '43';
prodClient.Core_Line_of_Business__c = lobValuesList[1];
prodClient.Name = 'product Y';
insert prodClient;*/
            Pricing_Competitor_Product__c cp1 = new Pricing_Competitor_Product__c(
                Name = 'Product CCG',
                Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z',
                RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c', 'Pricing_Client'),
                Pricing_Active_cb__c = true
            );
            insert cp1;
            List<SBQQ__QuoteLine__c> qlClientList = new List<SBQQ__QuoteLine__c>(); 
            SBQQ__QuoteLine__c qlClient = new SBQQ__QuoteLine__c(); 
            qlClient.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_CCG_Quote_Line_Create);
            qlClient.Pricing_Product_Nm__c = prodClient.Id;
            qlClient.Pricing_Other_Product_Nm__c=null;
            qlClient.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            qlClient.Pricing_Systems_qty__c = 6; 
            qlClient.Pricing_pm_approval_comments_nm__c = 'Test Comment';
            qlClient.Pricing_CPUs_per_system_qty__c = 1;
            qlClient.Pricing_Single_System_Price_Amt__c = 4;
            qlClient.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            qlClient.Pricing_Req_Discounted_Unit_Price__c = 1;
            qlClient.Pricing_Comp_Unit_Price_Amt__c = 10;
            //qlClient.Pricing_Performance_Metric_Nm__c = 'Passmark';
            //qlClient.Pricing_Write_In_Performance_Metric_Nm__c = null;
            qlClient.Pricing_Additional_OEM_Discount_Amt__c = 1;
            qlClient.Pricing_Competetor_Product__c=cp1.Id;
            qlClient.Pricing_Other_Competitor_Product_Nm__c = null;  
            //qlClient.Pricing_Intel_SKU_Performance_Nbr__c = 5;
            //qlClient.Pricing_Comp_SKU_Performance_Nbr__c = 2;
            qlClient.Pricing_Form_Factor_Nm__c = 'AIO';
            qlClient.SBQQ__Quote__c = quoteClient.Id;
            qlClientList.add(qlClient);
            insert qlClientList;
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v2.0/quoterequest/getallquotes?id=&endDate=&status=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('id', '');
            req.addParameter('endDate', '');
            req.addParameter('status', '');
            req.addParameter('limit', '');
            req.addParameter('offset', '');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_GetAllQuotesV2.doGet();
            system.assert(response!=null);
            test.stopTest();
        }
    }
    static testMethod void testgetAllQuotesV2withParam(){
        User usr = [SELECT id FROM User WHERE email='Rest_API_Get_All_Quotes_V2_Test@noemail.com'];
        system.runAs(usr){
            test.startTest(); 
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v2.0/quoterequest/getallquotes?id=&endDate=&status=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('id', '');
            req.addParameter('endDate', '');
            req.addParameter('status', '');
            req.addParameter('limit', '1');
            req.addParameter('offset', '1');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_GetAllQuotesV2.doGet();
            system.assert(response!=null);
            test.stopTest();
        }
    }
    
    static testMethod void testgetAllQuotesV2_OptanePMem(){
        User usr = [SELECT id FROM User WHERE email='Rest_API_Get_All_Quotes_V2_Test@noemail.com'];
        system.runAs(usr){
            test.startTest(); 
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v2.0/quoterequest/getallquotes?id=&endDate=&status=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('id', '');
            req.addParameter('endDate', '');
            req.addParameter('status', '');
            req.addParameter('limit', '1');
            req.addParameter('offset', '1');
            req.addParameter('quotelinetype', 'OptanePMem');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_GetAllQuotesV2.doGet();
            system.assert(response!=null);
            test.stopTest();
        }
    }
    
    static testMethod void testgetAllQuotesV2_Ethernet(){
        User usr = [SELECT id FROM User WHERE email='Rest_API_Get_All_Quotes_V2_Test@noemail.com'];
        system.runAs(usr){
            test.startTest(); 
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v2.0/quoterequest/getallquotes?id=&endDate=&status=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('id', '');
            req.addParameter('endDate', '');
            req.addParameter('status', '');
            req.addParameter('limit', '1');
            req.addParameter('offset', '1');
            req.addParameter('quotelinetype', 'Ethernet');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_GetAllQuotesV2.doGet();
            system.assert(response!=null);
            test.stopTest();
        }
    }
    
    static testMethod void testgetAllQuotesV2_Client(){
        User usr = [SELECT id FROM User WHERE email='Rest_API_Get_All_Quotes_V2_Test@noemail.com'];
        system.runAs(usr){
            test.startTest(); 
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v2.0/quoterequest/getallquotes?id=&endDate=&status=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('id', '');
            req.addParameter('endDate', '');
            req.addParameter('status', '');
            req.addParameter('limit', '1');
            req.addParameter('offset', '1');
            req.addParameter('quotelinetype', 'Client');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_GetAllQuotesV2.doGet();
            system.assert(response!=null);
            test.stopTest();
        }
    }    
    
    static testMethod void testgetAllQuotesV2_Test(){
        User usr = [SELECT id FROM User WHERE email='Rest_API_Get_All_Quotes_V2_Test@noemail.com'];
        system.runAs(usr){
            test.startTest(); 
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v2.0/quoterequest/getallquotes?id=&endDate=&status=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('id', '');
            req.addParameter('endDate', '');
            req.addParameter('status', '');
            req.addParameter('limit', '1');
            req.addParameter('offset', '1');
            req.addParameter('quotelinetype', 'OptaneSSD');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_GetAllQuotesV2.doGet();
            system.assert(response!=null);
            test.stopTest();
        }
    }
    
    static testMethod void testgetAllQuotesV2_DataCenterGPU_Test(){
        SBQQ__Quote__c quote = [select id from SBQQ__Quote__c limit 1];
        test.startTest();
        List<SBQQ__QuoteLine__c> ql = [select id from SBQQ__QuoteLine__c limit 1];
        User usr = [SELECT id FROM User WHERE email='Rest_API_Get_All_Quotes_V2_Test@noemail.com'];
        system.runAs(usr){
            //test.startTest(); 
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v2.0/quoterequest/getallquotes?id=&endDate=&status=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('id', '');
            req.addParameter('endDate', '');
            req.addParameter('status', '');
            req.addParameter('limit', '1');
            req.addParameter('offset', '1');
            req.addParameter('quotelinetype', Label.Pricing_RestAPI_Products_GPU_Param);
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_GetAllQuotesV2.doGet();
            system.assert(response!=null);
            test.stopTest();
        }
    } 
    
}