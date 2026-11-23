/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_QuotelinesV2_Test 


* Version     : 2.0 
* Created Date: 20 May 2022
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         06/20/2022              Test class for Rest API V2 to create or submit all QuoteLine sections
*****************************************************************************************************************************************/
@isTest
public class Pricing_RestAPI_QuotelinesV2_Test{
    
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
        prod.Core_Hierarchy_ID__c = '43';
        prod.Core_Line_of_Business__c = lobValuesList[0];
        prod.Core_Processor_Number_Nm__c  = '6220';
        prod.Name = 'Product X';
        prodList.add(prod);
        
        Product2 prod1 = new Product2();
        prod1.Name = 'Write In Product';
        prod1.IsActive = True;
        prodList.add(prod1);
        
        Pricing_Test_Utility.createPriceBook();
        
         List<Pricing_Competitor_Product__c> compprodList = new List<Pricing_Competitor_Product__c>();
        Pricing_Competitor_Product__c cp = new Pricing_Competitor_Product__c(
            Name = 'Product Z',
            Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z',
            Pricing_Active_cb__c = true,
            RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c', 'Pricing_Data_Center')
        );
        compprodList.add(cp);

        Pricing_Competitor_Product__c cpGPU = new Pricing_Competitor_Product__c(
            Name = 'Product XYZ',
            Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z',
            Pricing_Active_cb__c = true,
            RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c', 'Pricing_GPU')
        );
        compprodList.add(cpGPU);

        Pricing_Competitor_Product__c cpGPUWIP = new Pricing_Competitor_Product__c(
            Name = 'Write In Product',
            Pricing_Active_cb__c = true
        );
        compprodList.add(cpGPUWIP);

        insert prodList;
        insert compprodList;
        
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();
        
        
        System.runAs(lstUsers2[0])
        { 
            Account acc = Pricing_Test_Utility.createAccount();
            //Contact con = Pricing_Test_Utility.createContact(acc.Id);
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Rest_API_Quote_lines_V2_Test');
            
            User usr = [SELECT id FROM User WHERE email='Rest_API_Quote_lines_V2_Test@noemail.com'];
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
            newQuoteLineGPU.Pricing_Paired_CPU_Nm__c = prod.Id; //GPU
            newQuoteLineGPU.Pricing_Write_In_Paired_CPU_Nm__c = null; //GPU
            newQuoteLineGPU.Pricing_Other_Product_Nm__c='test prod';
            newQuoteLineGPU.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            newQuoteLineGPU.Pricing_Systems_qty__c = 6; 
            newQuoteLineGPU.Pricing_pm_approval_comments_nm__c = 'Test Comment';
            newQuoteLineGPU.Pricing_No_of_GPUs_per_system_nbr__c = 1; //GPU
            newQuoteLineGPU.Pricing_CPUs_per_system_qty__c = 1;
            newQuoteLineGPU.Pricing_Single_System_Price_Amt__c = 4;
            newQuoteLineGPU.Pricing_Comp_Single_System_Price_Amt__c = 2;
            newQuoteLineGPU.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            newQuoteLineGPU.Pricing_Req_Discounted_Unit_Price__c = 1;
            newQuoteLineGPU.Pricing_Additional_OEM_Discount_Amt__c = 1;
            newQuoteLineGPU.Pricing_Comp_No_of_GPUs_per_Sys__c = 5; //GPU
            newQuoteLineGPU.Pricing_Competitor_Systems_Cnt__c = 5;
            newQuoteLineGPU.Pricing_Comp_CPUs_per_system_Cnt__c = 5;
            newQuoteLineGPU.Pricing_Competetor_Product__c = cpGPU.Id;
            newQuoteLineGPU.Pricing_Other_Competitor_Product_Nm__c = null; 
            quoteLines.add(newQuoteLineGPU);
            insert quoteLines;            
            
            test.stopTest();
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
            
            Set<Id> quoteIds = new Set<Id>{quote.Id};
                List<Pricing_Comments__c> qComments = [SELECT id,name,Pricing_Answer__c FROM Pricing_Comments__c WHERE Pricing_Quote__c IN :quoteIds];
            for(Pricing_Comments__c qc : qComments){
                qc.Pricing_Answer__c = 'This is a test Answer. Test';
            }
            if(qComments.size() > 0){
                update qComments; 
            }
            //Pricing_Publish_Quote.PublishTenderQuote(String.valueOf(quote.Id));
        }
    }
    
    @isTest 
    static void testDoPost_createQuoteline() {
        SBQQ__Quote__c quote = [select id from SBQQ__Quote__c limit 1];
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = :'Product Z'];
        Product2 p = [Select Id from Product2 where Name = :'Write In Product'];
        User usr = [SELECT id, AccountId FROM User WHERE email='Rest_API_Quote_lines_V2_Test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v2.0/quoterequest/quotelines';
            request.addParameter('action', 'create');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{     "quoteId":"'+quote.id+'", "quoteLines": {             "OptaneSSD": [                 {                     "productId": "'+p.Id+'",                     "writeInProduct": "test",                     "quoteLinePricingEndDate": "12/12/3000",                     "quotelineReferenceID": "002",                     "quantity": 10,                     "requestedUnitPrice": 10,                     "competitorName": "test",                     "competitorProduct": "test",                     "competitorSingleSystemPricePoint": 10,                     "competitorDensity": 10,                     "additionalComment": "",                     "volumeByQuarterAndReasoning": ""                 }             ],             "OptanePMem": [                 {                     "productId": "'+p.Id+'",                     "quoteLinePricingEndDate": "12/12/3000",                     "writeInProduct": "test",                     "quotelineReferenceID": "003",                     "systemModel": "Test",                     "noOfSystems": 10,                     "noOfUnitsPerSystem": 1,                     "customerStdUnitPrice": 90,                     "requestedUnitPrice": 2,                     "pairedCPU": "1",                     "noOfCPUsPerSystem": 1,                     "dramDensity": 2,                     "noOfDRAMPerSystem": 2,                     "competitorName": "Test",                     "competitorDensity": 1,                     "competitorSingleSystemPricePoint": 5,                     "competitorNoOfSystems": 1,                     "competitorNoOfUnitsPerSystem": 1,                     "serverIntegration": "",                     "workload": "",                     "pocTestingResults": "",                     "additionalComment": null                 }             ],             "Ethernet": [                 {                     "productId": "'+p.Id+'",                     "writeInProduct": "test",                     "quoteLinePricingEndDate": "12/12/3000",                     "quotelineReferenceID": "004",                     "quantity": 10,                     "requestedUnitPrice": 20,                     "competitorProduct": "test",                     "competitorSingleSystemPricePoint": 20000,                     "competitorQuantity": 2000,                     "additionalComment": "test"                 }             ],             "DataCenterCPU": [                 {                     "productId": "'+p.Id+'",                     "quoteLinePricingEndDate": "12/12/3000",                     "writeInProduct": "test",                     "quotelineReferenceID": "001",                     "systemModel": "Test",                     "noOfSystems": 10,                     "noOfCPUsPerSystem": 1,                     "singleSystemPricePoint": 100,                     "customerStdUnitPrice": 90,                     "requestedUnitPrice": 2,                     "additionalDiscount": 0,                     "competitorName": "Test",                     "competitorSystemModel": "Test",                     "competitorProductId": "'+cp.Id+'",                     "competitorWriteInProduct": null,                     "competitorNoOfSystems": 1,                     "competitorNoOfCPUsPerSystem": 1,                     "competitorSingleSystemPrice": 8,                     "competitorAdditionalDiscount": 2,                     "additionalComment": null,                     "performanceMetrics": [                         {                             "performanceMetricsUsed": "Other",                             "performanceMetricsReferenceId": "PM-003",                             "weighting": 10,                             "intelScore": 10,                             "compScore": 5,                             "otherText": "Test"                         }                     ]                 }             ]         },         "quoteComments": [             {                 "quoteCommentReferenceId": "QC-001",                 "answer": "This is a test Message 1.## 123"             },             {                 "quoteCommentReferenceId": "QC-002",                 "answer": "This is a test Message 2."             },             {                 "quoteCommentReferenceId": "QC-003",                 "answer": "Test"             },             {                 "quoteCommentReferenceId": "QC-004",                 "answer": "This is a test Message 3."             }         ]     } }');       
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_QuotelinesV2.doPost();
            system.assert(restResponse.successContent!=null);
            test.stopTest();
        }        
    }
    
    @isTest 
    static void testDoPatch_updateQuoteline() {
        SBQQ__Quote__c quote = [select id,(select Id from SBQQ__LineItems__r order by Pricing_Quote_Line_Number__c) from SBQQ__Quote__c Limit 1];
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = :'Product Z'];
        Product2 p = [Select Id from Product2 where Name = :'Write In Product'];
        User usr = [SELECT id, AccountId FROM User WHERE email='Rest_API_Quote_lines_V2_Test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v2.0/quoterequest/quotelines';
            request.addParameter('action', 'update');
            request.httpMethod = 'PATCH';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{     "quoteId": "'+quote.Id+'", "quoteLines": {             "OptaneSSD": [                 {                     "quoteLineId":"'+quote.SBQQ__LineItems__r[1].Id+'",                     "productId": "'+p.Id+'",                     "writeInProduct": "test",                     "quoteLinePricingEndDate": "12/12/3000",                     "quotelineReferenceID": "002",                     "quantity": 10,                     "requestedUnitPrice": 10,                     "competitorName": "test",                     "competitorProduct": "test",                     "competitorSingleSystemPricePoint": 10,                     "competitorDensity": 10,                     "additionalComment": "",                     "volumeByQuarterAndReasoning": ""                 }             ],             "OptanePMem": [                 {                     "quoteLineId":"'+quote.SBQQ__LineItems__r[2].Id+'",                     "productId": "'+p.Id+'",                     "quoteLinePricingEndDate": "12/12/3000",                     "writeInProduct": "test",                     "quotelineReferenceID": "003",                     "systemModel": "Test",                     "noOfSystems": 10,                     "noOfUnitsPerSystem": 1,                     "customerStdUnitPrice": 90,                     "requestedUnitPrice": 2,                     "pairedCPU": "1",                     "noOfCPUsPerSystem": 1,                     "dramDensity": 2,                     "noOfDRAMPerSystem": 2,                     "competitorName": "Test",                     "competitorDensity": 1,                     "competitorSingleSystemPricePoint": 5,                     "competitorNoOfSystems": 1,                     "competitorNoOfUnitsPerSystem": 1,                     "serverIntegration": "",                     "workload": "",                     "pocTestingResults": "",                     "additionalComment": null                 }             ],             "Ethernet": [                 {                     "quoteLineId":"'+quote.SBQQ__LineItems__r[3].Id+'",                     "productId": "'+p.Id+'",                     "writeInProduct": "test",                     "quoteLinePricingEndDate": "12/12/3000",                     "quotelineReferenceID": "004",                     "quantity": 10,                     "requestedUnitPrice": 20,                     "competitorProduct": "test",                     "competitorSingleSystemPricePoint": 20000,                     "competitorQuantity": 2000,                     "additionalComment": "test"                 }             ],             "DataCenterCPU": [                 {                     "quoteLineId":"'+quote.SBQQ__LineItems__r[0].Id+'",                     "productId": "'+p.Id+'",                     "quoteLinePricingEndDate": "12/12/3000",                     "writeInProduct": "test",                     "quotelineReferenceID": "001",                     "systemModel": "Test",                     "noOfSystems": 10,                     "noOfCPUsPerSystem": 1,                     "singleSystemPricePoint": 100,                     "customerStdUnitPrice": 90,                     "requestedUnitPrice": 2,                     "additionalDiscount": 0,                     "competitorName": "Test",                     "competitorSystemModel": "Test",                     "competitorProductId": "'+cp.Id+'",                     "competitorWriteInProduct": null,                     "competitorNoOfSystems": 1,                     "competitorNoOfCPUsPerSystem": 1,                     "competitorSingleSystemPrice": 8,                     "competitorAdditionalDiscount": 2,                     "additionalComment": null,                     "performanceMetrics": [                         {                             "performanceMetricsUsed": "Other",                             "performanceMetricsReferenceId": "PM-003",                             "weighting": 10,                             "intelScore": 10,                             "compScore": 5,                             "otherText": "Test"                         }                     ]                 }             ]         },         "quoteComments": [             {                 "quoteCommentReferenceId": "QC-001",                 "answer": "This is a test Message 1.## 123"             },             {                 "quoteCommentReferenceId": "QC-002",                 "answer": "This is a test Message 2."             },             {                 "quoteCommentReferenceId": "QC-003",                 "answer": "Test"             },             {                 "quoteCommentReferenceId": "QC-004",                 "answer": "This is a test Message 3."             }         ]     } }');       
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_QuotelinesV2.doPatch();
            system.assert(restResponse.successContent!=null);
            test.stopTest();
        }        
    }
    
    @isTest 
    static void testDoGet_GetQuotelineCPU() {
        SBQQ__QuoteLine__c qli = [select id from SBQQ__QuoteLine__c where Pricing_Program_Type_Nm__c =: Label.Pricing_Tender_Standard_QuoteLine  Limit 1];
        User usr = [SELECT id, AccountId FROM User WHERE email='Rest_API_Quote_lines_V2_Test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest req = new RestRequest();
            req.requestUri='/services/apexrest/v2.0/quoterequest/quotelines?type=all&id=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'all');
            req.addParameter('id', String.valueOf(qli.Id));
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_QuotelinesV2.doGet();
            system.assert(response!=null);
            test.stopTest();
        }        
    }
    
    @isTest
    static void testDoGet_GetQuotelineGPU() {
        test.startTest();
        SBQQ__QuoteLine__c qli = [select id from SBQQ__QuoteLine__c where Pricing_Program_Type_Nm__c =: Label.Pricing_Tender_DataCenter_GPU Limit 1];           
        User usr = [SELECT id, AccountId FROM User WHERE email='Rest_API_Quote_lines_V2_Test@noemail.com'];
        system.runAs(usr){
            //test.startTest();
            RestRequest req = new RestRequest();
            req.requestUri='/services/apexrest/v2.0/quoterequest/quotelines?type=all&id=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'all');
            req.addParameter('id', String.valueOf(qli.Id));
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_QuotelinesV2.doGet();
            system.assert(response!=null);
            test.stopTest();
        }        
    }
    
    @isTest 
    static void testDoGet_GetQuotelineSSD() {
        SBQQ__QuoteLine__c qli = [select id from SBQQ__QuoteLine__c where Pricing_Program_Type_Nm__c =: Label.Pricing_Tender_SSD_Quote  Limit 1];
        User usr = [SELECT id, AccountId FROM User WHERE email='Rest_API_Quote_lines_V2_Test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest req = new RestRequest();
            req.requestUri='/services/apexrest/v2.0/quoterequest/quotelines?type=all&id=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'all');
            req.addParameter('id', String.valueOf(qli.Id));
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_QuotelinesV2.doGet();
            system.assert(response!=null);
            test.stopTest();
        }        
    }
    
    @isTest 
    static void testDoGet_GetQuotelinePMem() {
        SBQQ__QuoteLine__c qli = [select id from SBQQ__QuoteLine__c where Pricing_Program_Type_Nm__c =: Label.Pricing_Tender_PMem_Quote  Limit 1];
        User usr = [SELECT id, AccountId FROM User WHERE email='Rest_API_Quote_lines_V2_Test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest req = new RestRequest();
            req.requestUri='/services/apexrest/v2.0/quoterequest/quotelines?type=all&id=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'all');
            req.addParameter('id', String.valueOf(qli.Id));
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_QuotelinesV2.doGet();
            system.assert(response!=null);
            test.stopTest();
        }        
    }
    
    @isTest 
    static void testDoGet_GetQuotelineEthernet() {
        SBQQ__QuoteLine__c qli = [select id from SBQQ__QuoteLine__c where Pricing_Program_Type_Nm__c =: Label.Pricing_Tender_NIC_Quote  Limit 1];
        User usr = [SELECT id, AccountId FROM User WHERE email='Rest_API_Quote_lines_V2_Test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest req = new RestRequest();
            req.requestUri='/services/apexrest/v2.0/quoterequest/quotelines?type=all&id=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'all');
            req.addParameter('id', String.valueOf(qli.Id));
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_QuotelinesV2.doGet();
            system.assert(response!=null);
            test.stopTest();
        }        
    }
    
    @isTest 
    static void testDoGet_GetQuotelineClient() {
        SBQQ__Quote__c quoteClient = [select Id from SBQQ__Quote__c 
                                      WHERE Pricing_Project_Name_Nm__c = 'Test Project123' Limit 1];
        User usr = [SELECT id, AccountId FROM User WHERE email='Rest_API_Quote_lines_V2_Test@noemail.com'];
        User adminUser = [SELECT Id FROM User WHERE email = 'firstName@intel.com'];
        List<SBQQ__QuoteLine__c> qlClientList = new List<SBQQ__QuoteLine__c>(); 
        SBQQ__QuoteLine__c qlClient = new SBQQ__QuoteLine__c(); 
        system.runAs(adminUser){
            test.startTest();
            product2 prodClient = new product2();
            List<String> lobValuesList = Label.Pricing_LOB_Values.split(',');
            prodClient.Core_product_Org__c = 'Sales';
            prodClient.Core_product_Type__c = 'Processors';
            prodClient.Core_Sales_Visible_Flag__c  = True;
            prodClient.IsActive = True;
            prodClient.Core_VerticalSegment__c = 'Desktop';
            prodClient.Core_Hierarchy_ID__c = '43';
            prodClient.Core_Line_of_Business__c = lobValuesList[1];
            prodClient.Core_Processor_Number_Nm__c  = '6220';
            prodClient.Name = 'product Y';
            insert prodClient;
            Pricing_Competitor_Product__c cp1 = new Pricing_Competitor_Product__c(
                Name = 'Product CCG',
                Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z',
                Pricing_Active_cb__c = true,
                RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c', 'Pricing_Client')
            );
            insert cp1;
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
            Set<Id> quoteIdsClient = new Set<Id>{quoteClient.Id};
                List<Pricing_Comments__c> qCommentsClient = [SELECT id,name,Pricing_Answer__c FROM Pricing_Comments__c 
                                                             WHERE Pricing_Quote__c IN :quoteIdsClient];
            for(Pricing_Comments__c qcClient : qCommentsClient){
                qcClient.Pricing_Answer__c = 'This is a test Answer. Test';
            }
            if(qCommentsClient.size() > 0){
                update qCommentsClient; 
            }
        }
        system.runAs(usr){
            RestRequest req = new RestRequest();
            req.requestUri='/services/apexrest/v2.0/quoterequest/quotelines?type=all&id=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'all');
            req.addParameter('id', String.valueOf(qlClient.Id));
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_QuotelinesV2.doGet();
            system.assert(response!=null);
            test.stopTest();
        }        
    }
    
    @isTest 
    static void testDoGet_GetQuotelineClient_QuoteLine_Param() {
        SBQQ__Quote__c quoteClient = [select Id from SBQQ__Quote__c 
                                      WHERE Pricing_Project_Name_Nm__c = 'Test Project123' Limit 1];
        User usr = [SELECT id, AccountId FROM User WHERE email='Rest_API_Quote_lines_V2_Test@noemail.com'];
        User adminUser = [SELECT Id FROM User WHERE email = 'firstName@intel.com'];
        List<SBQQ__QuoteLine__c> qlClientList = new List<SBQQ__QuoteLine__c>(); 
        SBQQ__QuoteLine__c qlClient = new SBQQ__QuoteLine__c();
        system.runAs(adminUser){
            test.startTest();
            product2 prodClient = new product2();
            List<String> lobValuesList = Label.Pricing_LOB_Values.split(',');
            prodClient.Core_product_Org__c = 'Sales';
            prodClient.Core_product_Type__c = 'Processors';
            prodClient.Core_Sales_Visible_Flag__c  = True;
            prodClient.IsActive = True;
            prodClient.Core_VerticalSegment__c = 'Desktop';
            prodClient.Core_Hierarchy_ID__c = '43';
            prodClient.Core_Line_of_Business__c = lobValuesList[1];
            prodClient.Core_Processor_Number_Nm__c  = '6220';
            prodClient.Name = 'product Y';
            insert prodClient;
            Pricing_Competitor_Product__c cp1 = new Pricing_Competitor_Product__c(
                Name = 'Product CCG',
                Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z',
                Pricing_Active_cb__c = true,
                RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c', 'Pricing_Client')
            );
            insert cp1; 
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
            Set<Id> quoteIdsClient = new Set<Id>{quoteClient.Id};
                List<Pricing_Comments__c> qCommentsClient = [SELECT id,name,Pricing_Answer__c FROM Pricing_Comments__c 
                                                             WHERE Pricing_Quote__c IN :quoteIdsClient];
            for(Pricing_Comments__c qcClient : qCommentsClient){
                qcClient.Pricing_Answer__c = 'This is a test Answer. Test';
            }
            if(qCommentsClient.size() > 0){
                update qCommentsClient; 
            }
        }
        system.runAs(usr){
            RestRequest req = new RestRequest();
            req.requestUri='/services/apexrest/v2.0/quoterequest/quotelines?type=quoteline&id=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'quoteline');
            req.addParameter('id', String.valueOf(qlClient.Id));
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_QuotelinesV2.doGet();
            system.assert(response!=null);
            test.stopTest();
        }        
    }
    
    @isTest 
    static void test_deleteQuotelineValidation() {
        SBQQ__QuoteLine__c quoteline = [select id from SBQQ__QuoteLine__c where Pricing_Status_Nm__c = 'Draft' Limit 1];
        User usr = [SELECT id, AccountId FROM User WHERE email='Rest_API_Quote_lines_V2_Test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v2.0/quoterequest/quotelines';
            request.addParameter('id', quoteline.id);
            request.httpMethod = 'Delete';
            request.addHeader('Content-Type', 'application/json');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_QuotelinesV2.doDelete();
            system.assert(restResponse.successContent!=null);
            test.stopTest();
        }        
    }
    
    @isTest 
    static void testDoPost_recallQuoteline() {
        SBQQ__Quote__c quote = [select id,name from SBQQ__Quote__c Limit 1];
        SBQQ__Quoteline__c qli = [SELECT Id,Pricing_Status_Nm__c FROM SBQQ__Quoteline__c WHERE SBQQ__Quote__c =: quote.Id LIMIT 1];
        User usr = [SELECT id, AccountId FROM User WHERE email='Rest_API_Quote_lines_V2_Test@noemail.com'];
        qli.Pricing_Status_Nm__c = 'Pending Intel Field Review';
        test.startTest();
        update qli;
        system.runAs(usr){
            RestRequest req = new RestRequest();
            req.requestUri='/services/apexrest/v2.0/quoterequest/quotelines?action=&id=';
            req.httpMethod = 'POST';
            req.addParameter('action', 'recall');
            req.addParameter('id', String.valueOf(qli.Id));
            req.addHeader('Content-Type', 'application/json');
            req.requestBody = Blob.valueOf('{"comment":""}');       
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_QuotelinesV2.doPost();
            system.assert(response!=null);
            test.stopTest();
        }
    }
    
    @isTest static void testDoPost_statusChange() {
        test.startTest();
        SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
        SBQQ__QuoteLine__c quoteline = Pricing_Test_Utility.createQuoteLineByStatus(quote.Id,'Approved');
        User usr = [SELECT id FROM User WHERE email='Rest_API_Quote_lines_V2_Test@noemail.com']; 
        system.runAs(usr){
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v2.0/quoterequest/quotelines';
            request.addParameter('action', 'statuschange');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{"quoteLines": [{"quotelineReferenceID": "QL-001","wonLostComments":"dasda","status":"Lost","quotelineId":"'+quoteline.Id+'"}]}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_QuotelinesV2.doPost();
            system.assert(restResponse!=null);
            test.stopTest();
        }
    }
    
    @isTest static void testDoPostCR() {
        test.startTest();
        SBQQ__QuoteLine__c quoteline = [Select Id,SBQQ__Quote__c from SBQQ__QuoteLine__c where Pricing_Status_Nm__c = 'Draft' limit 1];
        quoteline.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
        quoteline.Pricing_ECAP_Price_Amt__c = 1200;
        quoteline.Pricing_Approved_Unit_Qty__c = 10;
        quoteline.Pricing_Approved_End_Date_Dt__c = system.today()+1;
        update quoteline;
        User usr = [SELECT id FROM User WHERE email='Rest_API_Quote_lines_V2_Test@noemail.com']; 
        system.runAs(usr){
            
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v2.0/quoterequest/quotelines';
            request.addParameter('action', 'changerequest');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{"quoteId": "'+quoteline.SBQQ__Quote__c+'","quoteLines": [{"quotelineId": "'+quoteline.id+'","quotelineReferenceID": "001","quoteLinePricingEndDate": "12/12/3000","newQuantity": 120,"newRequestedDiscountUnitPrice": 1200,"additionalComment": "1123456789"}]}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_QuotelinesV2.doPost();
            system.assert(restResponse!=null);
            test.stopTest();
        }
    }
    
    @isTest 
    static void testDoPost_createGPUQuoteline() {
        SBQQ__Quote__c quote = [select id from SBQQ__Quote__c limit 1];
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = :'Write In Product'];
        Product2 p = [Select Id from Product2 where Name = :'Write In Product'];
        User usr = [SELECT id, AccountId FROM User WHERE email='Rest_API_Quote_lines_V2_Test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v2.0/quoterequest/quotelines';
            request.addParameter('action', 'create');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{"quoteId":"'+quote.id+'","quoteLines":{"OptaneSSD":[],"OptanePMem":[],"Ethernet":[],"DataCenterCPU":[],"DataCenterGPU":[{"productId":"'+p.Id+'","quoteLinePricingEndDate":"12/12/3000","writeInProduct":"test","quotelineReferenceID":"001","systemModel":"Test","noOfSystems":10,"noOfCPUsPerSystem":1,"noOfGPUsPerSystem":1,"singleSystemPricePoint":100,"customerStdUnitPrice":90,"requestedUnitPrice":2,"additionalDiscount":0,"pairedCPUId":"'+p.Id+'","writeInPairedCPU":"Test","competitorName":"Test","competitorSystemModel":"Test","competitorProductId":"'+cp.Id+'","competitorWriteInProduct":"Test Comp","competitorNoOfSystems":1,"competitorNoOfUnitsPerSystem":1,"competitorNoOfGPUsPerSystem":1,"competitorSingleSystemPrice":8,"competitorAdditionalDiscount":2,"additionalComment":null}]},"quoteComments":[{"quoteCommentReferenceId":"QC-001","answer":"This is a test Message 1.## 123"},{"quoteCommentReferenceId":"QC-002","answer":"This is a test Message 2."},{"quoteCommentReferenceId":"QC-003","answer":"Test"},{"quoteCommentReferenceId":"QC-004","answer":"This is a test Message 3."}]}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_QuotelinesV2.doPost();
            system.assert(restResponse.successContent!=null);
            test.stopTest();
        }        
    }
    
    @isTest 
    static void testDoPost_createClientQuoteline() {
        SBQQ__Quote__c quote = [select id from SBQQ__Quote__c where Pricing_Program_Type_Nm__c = 'Client' limit 1];
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product' limit 1];
        Product2 p = [Select Id from Product2 where Name = 'Write In Product' limit 1];
        User usr = [SELECT id, AccountId FROM User WHERE email='Rest_API_Quote_lines_V2_Test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v2.0/quoterequest/quotelines';
            request.addParameter('action', 'create');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{"quoteId":"'+quote.id+'","quoteLines":{"Client":[{"productId":"'+p.Id+'","quoteLinePricingEndDate":"12/12/3000","writeInProduct":"test","quotelineReferenceID":"001","systemModel":"Test","quantity":1,"singleSystemPricePoint":100,"customerStdUnitPrice":90,"requestedUnitPrice":2,"formFactor":"Desktop","competitorName":"Test","competitorSystemModel":"Test","competitorProductId":"'+cp.Id+'","competitorWriteInProduct":"Test Comp","competitorSingleSystemPricePoint":8,"additionalComment":null}]},"quoteComments":[{"quoteCommentReferenceId":"QC-001","answer":"This is a test Message 1.## 123"},{"quoteCommentReferenceId":"QC-002","answer":"This is a test Message 2."},{"quoteCommentReferenceId":"QC-003","answer":"Test"},{"quoteCommentReferenceId":"QC-004","answer":"This is a test Message 3."}]}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_QuotelinesV2.doPost();
            system.assert(restResponse.successContent!=null);
            test.stopTest();
        }        
    }
}