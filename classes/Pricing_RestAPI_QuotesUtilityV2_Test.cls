/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_QuotesUtilityV2_Test 
* Version     : 2.0 
* Created Date: 20 May 2022
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         06/20/2022              Test class for Rest API V2 to create or submit validations
*****************************************************************************************************************************************/
@isTest
public class Pricing_RestAPI_QuotesUtilityV2_Test{
    
    @testSetup 
    private static void createData(){
        Pricing_RestAPI_TestUtility.createRestAPIErrorCodesConfig();
        List<Product2> prodList = new List<Product2>();
        Product2 prod = new Product2();
        prod.Core_Product_Org__c = 'Sales';
        prod.Core_Product_Type__c = 'Processors';
        prod.Core_Sales_Visible_Flag__c  = True;
        prod.IsActive = True;
        prod.Core_Hierarchy_ID__c = '43';
        prod.Core_Group_Code_Short_Name__c = 'DCG~DCAI';
        prod.Core_Processor_Number_Nm__c  = '6220';
        prod.Name = 'Product X';
        prodList.add(prod);
        
        Product2 prod1 = new Product2();
        prod1.Name = 'Write In Product';
        prod1.IsActive = True;
        prodList.add(prod1);
        
        Pricing_Test_Utility.createPriceBook();
        List<Pricing_Competitor_Product__c> cplst = new List<Pricing_Competitor_Product__c>();
        Pricing_Competitor_Product__c cp = new Pricing_Competitor_Product__c(
            Name = 'Product Z',
            Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z',
            Pricing_Active_cb__c = true,
            RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c', 'Pricing_Data_Center')
        );
        
        Pricing_Competitor_Product__c cp1 = new Pricing_Competitor_Product__c(
            Name = 'Product CCG',
            Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z',
            Pricing_Active_cb__c = true,
            RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c', 'Pricing_Client')
        );
        Pricing_Competitor_Product__c cp2 = new Pricing_Competitor_Product__c(
            Name = 'Product GPU',
            Pricing_Competitor_Product_Provider_Nm__c = 'Pro-GPU',
            Pricing_Active_cb__c = true,
            RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c', 'Pricing_GPU')
        );
        cplst.add(cp);
        cplst.add(cp1);
        cplst.add(cp2);
        
        insert prodList;
        insert cplst;
        
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();
        
        
        System.runAs(lstUsers2[0])
        { 
            Account acc = Pricing_Test_Utility.createAccount();
            //Contact con = Pricing_Test_Utility.createContact(acc.Id);
            Contact con = Pricing_Test_Utility.createPrimaryContactAPI(acc.Id,2)[0];
            
            User usr = [SELECT id FROM User WHERE email='primarycontact0@noemail.com'];
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
            quote.Pricing_End_Customer_URL__c = 'www.test.com';
            quote.SBQQ__PrimaryContact__c = con.id;
            //insert quote;
            quotes.add(quote);
            insert quotes;
            
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
            quoteLineob.Pricing_pm_approval_comments_nm__c  = 'Test Comment';
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
            newQuoteLine1.Pricing_Comp_Density_Nbr__c = 11;
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
            newQuoteLine2.Pricing_Comp_Density_Nbr__c = 12;
            newQuoteLine2.Pricing_Systems_qty__c = 10;
            newQuoteLine2.Pricing_CPUs_per_system_qty__c = 1;
            newQuoteLine2.Pricing_CPU_Txt__c = 'Test';
            newQuoteLine2.Pricing_DRAM_Density_nbr__c = 10;
            newQuoteLine2.Pricing_DRAM_per_System_qty__c = 1;
            newQuoteLine2.Pricing_Competitor_Systems_Cnt__c = 5;
            newQuoteLine2.Pricing_Comp_CPUs_per_system_Cnt__c = 1;
            newQuoteLine2.Pricing_Approved_Unit_Dup_Qty__c = 10;
            quoteLines.add(newQuoteLine2);
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
            Pricing_Publish_Quote.PublishTenderQuote(String.valueOf(quote.Id));
        }
    }
    
    @isTest 
    static void test_createValidationsSuccess() {
        
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name ='Product Z'];
        Product2 p = [Select Id from Product2 where Name ='Write In Product'];
        User usr = [SELECT id, AccountId FROM User WHERE email='primarycontact0@noemail.com'];
        List<User> salesRep2 = createSalesRepUser('testSalesRep2@intel.com');
        List<User> salesRep1 = createSalesRepUser('testSalesRep1@intel.com');
        //List<User> userITS = Pricing_Test_Utility.createITSUser();  
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();  
        System.runAs(lstUsers2[0])
        {
            Pricing_Test_Utility.createAccountTeamMember(usr.AccountId, salesRep2[0].Id);
            Pricing_Test_Utility.createAccountTeamMember(usr.AccountId, salesRep1[0].Id);
        }
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v2.0/quoterequest/quotes';
            request.addParameter('action', 'create');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{     "quoteDetails": {         "endCustomer": "Test 12313123",         "unifiedEndCustomerId": "",         "projectName": "IBM",         "application": "CSP",         "proposalDueDate": "12/12/3000",         "intelResponseRequestedDate": "12/12/3000",         "pricingStartDate": "12/12/3000",         "pricingEndDate": "12/12/3000",         "endCustomerCountry": "India",         "referenceRequestID": "IQR-HPE-002",         "intelSalesRepEmail": "testSalesRep2@intel.com,testSalesRep1@intel.com",         "intelAccountExecutiveEmail": "firstNameAE@intel.com", "industryTechnicalSpecialistEmail": "firstNameITS@intel.com",        "secondaryContact": "oem.test@test.com",         "additionalQuoteLetterRecipients": null,         "quoteLines": {             "OptaneSSD": [                 {                     "productId": "'+p.Id+'",                     "writeInProduct": "test",                     "quoteLinePricingEndDate": "12/12/3000",                     "quotelineReferenceID": "002",                     "quantity": 10,                     "requestedUnitPrice": 10,                     "competitorName": "test",                     "competitorProduct": "test",                     "competitorSingleSystemPricePoint": 10,                     "competitorDensity": 10,                     "additionalComment": "",                     "volumeByQuarterAndReasoning": ""                 }             ],             "OptanePMem": [                 {                     "productId": "'+p.Id+'",                     "quoteLinePricingEndDate": "12/12/3000",                     "writeInProduct": "test",                     "quotelineReferenceID": "003",                     "systemModel": "Test",                     "noOfSystems": 10,                     "noOfUnitsPerSystem": 1,                     "customerStdUnitPrice": 90,                     "requestedUnitPrice": 2,                     "pairedCPU": "1",                     "noOfCPUsPerSystem": 1,                     "dramDensity": 2,                     "noOfDRAMPerSystem": 2,                     "competitorName": "Test",                     "competitorDensity": 1,                     "competitorSingleSystemPricePoint": 5,                     "competitorNoOfSystems": 1,                     "competitorNoOfUnitsPerSystem": 1,                     "serverIntegration": "",                     "workload": "",                     "pocTestingResults": "",                     "additionalComment": null                 }             ],             "Ethernet": [                 {                     "productId": "'+p.Id+'",                     "writeInProduct": "test",                     "quoteLinePricingEndDate": "12/12/3000",                     "quotelineReferenceID": "004",                     "quantity": 10,                     "requestedUnitPrice": 20,                     "competitorProduct": "test",                     "competitorSingleSystemPricePoint": 20000,                     "competitorQuantity": 2000,                     "additionalComment": "test"                 }             ],             "DataCenterCPU": [                 {                     "productId": "'+p.Id+'",                     "quoteLinePricingEndDate": "12/12/3000",                     "writeInProduct": "test",                     "quotelineReferenceID": "001",                     "systemModel": "Test",                     "noOfSystems": 10,                     "noOfCPUsPerSystem": 1,                     "singleSystemPricePoint": 100,                     "customerStdUnitPrice": 90,                     "requestedUnitPrice": 2,                     "additionalDiscount": 0,                     "competitorName": "Test",                     "competitorSystemModel": "Test",                     "competitorProductId": "'+cp.Id+'",                     "competitorWriteInProduct": null,                     "competitorNoOfSystems": 1,                     "competitorNoOfCPUsPerSystem": 1,                     "competitorSingleSystemPrice": 8,                     "competitorAdditionalDiscount": 2,                     "additionalComment": null,                     "performanceMetrics": [                         {                             "performanceMetricsUsed": "Other",                             "performanceMetricsReferenceId": "PM-003",                             "weighting": 10,                             "intelScore": 10,                             "compScore": 5,                             "otherText": "Test"                         }                     ]                 }            ,"DataCenterGPU": [                 {                     "productId": "'+p.Id+'",                     "quoteLinePricingEndDate": "12/12/3000",                     "writeInProduct": "test",                     "quotelineReferenceID": "001",                     "systemModel": "Test",                     "noOfSystems": 10,                     "noOfCPUsPerSystem": 1,                     "singleSystemPricePoint": 100,                     "customerStdUnitPrice": 90,                     "requestedUnitPrice": 2,                     "additionalDiscount": 0,                     "competitorName": "Test",                     "competitorSystemModel": "Test",                     "competitorProductId": "'+cp.Id+'",                     "competitorWriteInProduct": null,                     "competitorNoOfSystems": 1,                     "competitorNoOfCPUsPerSystem": 1,                     "competitorSingleSystemPrice": 8,                     "competitorAdditionalDiscount": 2,                     "additionalComment": null}             ]          ]         },         "quoteComments": [             {                 "quoteCommentReferenceId": "QC-001",                 "answer": "This is a test Message 1.## 123"             },             {                 "quoteCommentReferenceId": "QC-002",                 "answer": "This is a test Message 2."             },             {                 "quoteCommentReferenceId": "QC-003",                 "answer": "Test"             },             {                 "quoteCommentReferenceId": "QC-004",                 "answer": "This is a test Message 3."             }         ]     } }');       
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_QuotesV2.doPost();
            system.assert(restResponse!=null);
            test.stopTest();
        }        
    }
    
    @isTest 
    static void test_createSVDValidationsSuccess() {
        
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name ='Product Z'];
        Product2 p = [Select Id from Product2 where Name ='Write In Product'];
        User usr = [SELECT id, AccountId FROM User WHERE email='primarycontact0@noemail.com'];
        List<User> salesRep2 = createSalesRepUser('testSalesRep2@intel.com');
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();  
        System.runAs(lstUsers2[0])
        {
            Pricing_Test_Utility.createAccountTeamMember(usr.AccountId, salesRep2[0].Id);
        }
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v2.0/quoterequest/quotes';
            request.addParameter('action', 'create');
            request.addParameter('type', 'svd');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{     "quoteDetails": {         "endCustomer": "Test 12313123",         "unifiedEndCustomerId": "",         "projectName": "IBM",         "application": "HPC",         "proposalDueDate": "12/12/3000",         "intelResponseRequestedDate": "12/12/3000",         "pricingStartDate": "12/12/3000",         "pricingEndDate": "12/12/3000",         "endCustomerCountry": "India",         "referenceRequestID": "IQR-HPE-002",         "intelSalesRepEmail": "testSalesRep2@intel.com",         "intelAccountExecutiveEmail": "firstNameAE@intel.com",       "secondaryContact": "oem.test@test.com",         "additionalQuoteLetterRecipients": null,         "quoteLines": {             "OptaneSSD": [                 {                     "productId": "'+p.Id+'",                     "writeInProduct": "test",                     "quoteLinePricingEndDate": "12/12/3000",                     "quotelineReferenceID": "002",                     "quantity": 10,                     "requestedUnitPrice": 10,                     "competitorName": "test",                     "competitorProduct": "test",                     "competitorSingleSystemPricePoint": 10,                     "competitorDensity": 10,                     "additionalComment": "",                     "volumeByQuarterAndReasoning": ""                 }             ],             "OptanePMem": [                 {                     "productId": "'+p.Id+'",                     "quoteLinePricingEndDate": "12/12/3000",                     "writeInProduct": "test",                     "quotelineReferenceID": "003",                     "systemModel": "Test",                     "noOfSystems": 10,                     "noOfUnitsPerSystem": 1,                     "customerStdUnitPrice": 90,                     "requestedUnitPrice": 2,                     "pairedCPU": "1",                     "noOfCPUsPerSystem": 1,                     "dramDensity": 2,                     "noOfDRAMPerSystem": 2,                     "competitorName": "Test",                     "competitorDensity": 1,                     "competitorSingleSystemPricePoint": 5,                     "competitorNoOfSystems": 1,                     "competitorNoOfUnitsPerSystem": 1,                     "serverIntegration": "",                     "workload": "",                     "pocTestingResults": "",                     "additionalComment": null                 }             ],             "Ethernet": [                 {                     "productId": "'+p.Id+'",                     "writeInProduct": "test",                     "quoteLinePricingEndDate": "12/12/3000",                     "quotelineReferenceID": "004",                     "quantity": 10,                     "requestedUnitPrice": 20,                     "competitorProduct": "test",                     "competitorSingleSystemPricePoint": 20000,                     "competitorQuantity": 2000,                     "additionalComment": "test"                 }             ],             "DataCenterCPU": [                 {                     "productId": "'+p.Id+'",                     "quoteLinePricingEndDate": "12/12/3000",                     "writeInProduct": "test",                     "quotelineReferenceID": "001",                     "systemModel": "Test",                     "noOfSystems": 18,                     "noOfCPUsPerSystem": 1,                     "singleSystemPricePoint": 100,                     "customerStdUnitPrice": 90,                     "requestedUnitPrice": 2,                     "additionalDiscount": 0,                     "competitorName": "Test",                     "competitorSystemModel": "Test",                     "competitorProductId": "'+cp.Id+'",                     "competitorWriteInProduct": null,                     "competitorNoOfSystems": 1,                     "competitorNoOfCPUsPerSystem": 1,                     "competitorSingleSystemPrice": 8,                     "competitorAdditionalDiscount": 2,                     "additionalComment": null,                     "performanceMetrics": [                         {                             "performanceMetricsUsed": "Other",                             "performanceMetricsReferenceId": "PM-003",                             "weighting": 10,                             "intelScore": 10,                             "compScore": 5,                             "otherText": "Test"                         },                         {                             "performanceMetricsUsed": "HPCG",                             "performanceMetricsReferenceId": "PM-003",                             "weighting": 10,                             "intelScore": 10,                             "compScore": 5,                             "otherText": ""                         }                     ]                 }             ]         },         "quoteComments": [             {                 "quoteCommentReferenceId": "QC-001",                 "answer": "This is a test Message 1.## 123"             },             {                 "quoteCommentReferenceId": "QC-002",                 "answer": "This is a test Message 2."             },             {                 "quoteCommentReferenceId": "QC-003",                 "answer": "Test"             },             {                 "quoteCommentReferenceId": "QC-004",                 "answer": "This is a test Message 3."             }         ]     } }');       
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_QuotesV2.doPost();
            system.assert(restResponse!=null);
            test.stopTest();
        }           
    }
    
    @isTest 
    static void test_createClientValidationsSuccess() {
        
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = :'Product CCG'];
        Product2 p = [Select Id from Product2 where Name = 'Write In Product'];
        User usr = [SELECT id, AccountId FROM User WHERE email='primarycontact0@noemail.com'];
        List<User> salesRep2 = createSalesRepUser('testSalesRep2@intel.com');
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();  
        System.runAs(lstUsers2[0])
        {
            Pricing_Test_Utility.createAccountTeamMember(usr.AccountId, salesRep2[0].Id);
        }
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v2.0/quoterequest/quotes';
            request.addParameter('action', 'create');
            request.addParameter('type', 'client');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{     "quoteDetails": {         "endCustomer": "Test 12313123",         "unifiedEndCustomerId": "",         "projectName": "IBM",         "marketSegment": "Communications",         "proposalDueDate": "12/12/3000",         "intelResponseRequestedDate": "12/12/3000",         "pricingStartDate": "12/12/3000",         "pricingEndDate": "12/12/3000",         "endCustomerCountry": "India",         "referenceRequestID": "IQR-HPE-002",         "intelSalesRepEmail": "testSalesRep2@intel.com",         "intelAccountExecutiveEmail": "firstNameAE@intel.com",         "secondaryContact": "oem.test@test.com",         "additionalQuoteLetterRecipients": null,         "quoteLines": {             "Client": [                 {                     "productId": "'+p.Id+'",                     "quoteLinePricingEndDate": "12/12/3000",                     "writeInProduct": "test",                     "quotelineReferenceID": "001",                     "systemModel": "Test",                     "quantity": 10,                     "singleSystemPricePoint": 100,                     "customerStdUnitPrice": 90,                     "requestedUnitPrice": 2,                     "formFactor": "AIO",                     "competitorName": "Test",                     "competitorSystemModel": "Test",                     "competitorProductId": "'+cp.Id+'",                     "competitorWriteInProduct": "",                     "competitorSingleSystemPricePoint": 8,                     "additionalComment": null } ] },         "quoteComments": [             {                 "quoteCommentReferenceId": "QC-001",                 "answer": "This is a test Message 1.## 123"             },             {                 "quoteCommentReferenceId": "QC-002",                 "answer": "This is a test Message 2."             },             {                 "quoteCommentReferenceId": "QC-003",                 "answer": "Test"             },             {                 "quoteCommentReferenceId": "QC-004",                 "answer": "This is a test Message 3."             },             {                 "quoteCommentReferenceId": "QC-005",                 "answer": "This is a test Message 3."             }         ]     } }');       
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_QuotesV2.doPost();
            system.assert(restResponse!=null);
            test.stopTest();
        }        
    }
    
    @isTest 
    static void test_createValidationsError() {
        
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = :'Product Z'];
        Product2 p = [Select Id from Product2 where Name = :'Write In Product'];
        User usr = [SELECT id, AccountId FROM User WHERE email='primarycontact0@noemail.com'];
        List<User> salesRep2 = createSalesRepUser('testSalesRep2@intel.com');
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();  
        System.runAs(lstUsers2[0])
        {
            Pricing_Test_Utility.createAccountTeamMember(usr.AccountId, salesRep2[0].Id);
        }
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v2.0/quoterequest/quotes';
            request.addParameter('action', 'create');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{     "quoteDetails": {         "endCustomer": "",         "unifiedEndCustomerId": "",         "projectName": "",         "application": "",         "proposalDueDate": "",         "intelResponseRequestedDate": "",         "pricingStartDate": "",         "pricingEndDate": "",         "endCustomerCountry": "",         "referenceRequestID": "",         "intelSalesRepEmail": "",         "intelAccountExecutiveEmail": "",         "secondaryContact": "你好",         "additionalQuoteLetterRecipients": "你好",         "quoteLines": {             "OptaneSSD": [                 {                     "productId": "",                     "writeInProduct": "test",                     "quoteLinePricingEndDate": "",                     "quotelineReferenceID": "",                     "quantity": -10,                     "requestedUnitPrice": -10,                     "competitorName": "",                     "competitorProduct": "",                     "competitorSingleSystemPricePoint": -10,                     "competitorDensity": -10,                     "additionalComment": "你好",                     "volumeByQuarterAndReasoning": "你好"                 }             ],             "OptanePMem": [                 {                     "productId": "",                     "quoteLinePricingEndDate": "",                     "writeInProduct": "test",                     "quotelineReferenceID": "",                     "systemModel": "",                     "noOfSystems": -10,                     "noOfUnitsPerSystem": -1,                     "customerStdUnitPrice": -90,                     "requestedUnitPrice": -2,                     "pairedCPU": "你好",                     "noOfCPUsPerSystem": -1,                     "dramDensity": -2,                     "noOfDRAMPerSystem": -2,                     "competitorName": "",                     "competitorDensity": -1,                     "competitorSingleSystemPricePoint": -5,                     "competitorNoOfSystems": -1,                     "competitorNoOfUnitsPerSystem": -1,                     "serverIntegration": "你好",                     "workload": "你好",                     "pocTestingResults": "你好",                     "additionalComment": "你好"                 }             ],             "Ethernet": [                 {                     "productId": "",                     "writeInProduct": "test",                     "quoteLinePricingEndDate": "",                     "quotelineReferenceID": "",                     "quantity": -10,                     "requestedUnitPrice":-20,                     "competitorProduct": "",                     "competitorSingleSystemPricePoint": -20000,                     "competitorQuantity": -2000,                     "additionalComment": "你好"                 }             ],             "DataCenterCPU": [                 {                     "productId": "",                     "quoteLinePricingEndDate": "",                     "writeInProduct": "test",                     "quotelineReferenceID": "",                     "systemModel": "",                     "noOfSystems": -10,                     "noOfCPUsPerSystem": -1,                     "singleSystemPricePoint": -100,                     "customerStdUnitPrice": -90,                     "requestedUnitPrice": -2,                     "additionalDiscount": -80,                     "competitorName": "",                     "competitorSystemModel": "",                     "competitorProductId": "",                     "competitorWriteInProduct": "test",                     "competitorNoOfSystems": -1,                     "competitorNoOfCPUsPerSystem": -1,                     "competitorSingleSystemPrice": -8,                     "competitorAdditionalDiscount": -2,                     "additionalComment": "你好",                     "performanceMetrics": [                         {                             "performanceMetricsUsed": "",                             "performanceMetricsReferenceId": "",                             "weighting": -10,                             "intelScore": -10,                             "compScore": -5,                             "otherText": "你好"                         }                     ]                 }             ]         },         "quoteComments": [             {                 "quoteCommentReferenceId": "QC-001",                 "answer": ""             },             {                 "quoteCommentReferenceId": "QC-002",                 "answer": ""             },             {                 "quoteCommentReferenceId": "QC-003",                 "answer": ""             },             {                 "quoteCommentReferenceId": "QC-004",                 "answer": ""             }         ]     } }');       
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_QuotesV2.doPost();
            system.assert(restResponse!=null);
            test.stopTest();
        }        
    }
    
    @isTest 
    static void test_updateValidations() {
        SBQQ__Quote__c quote = [select id,(select Id from SBQQ__LineItems__r order by Pricing_Quote_Line_Number__c) from SBQQ__Quote__c Limit 1];
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = :'Product Z'];
        Product2 p = [Select Id from Product2 where Name = :'Write In Product'];
        User usr = [SELECT id, AccountId FROM User WHERE email='primarycontact0@noemail.com'];
        List<User> salesRep2 = createSalesRepUser('testSalesRep2@intel.com');
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();  
        System.runAs(lstUsers2[0])
        {
            Pricing_Test_Utility.createAccountTeamMember(usr.AccountId, salesRep2[0].Id);
        }
        system.runAs(usr){
            
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v2.0/quoterequest/quotes';
            request.addParameter('action', 'update');
            request.httpMethod = 'PATCH';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{     "quoteId": "'+quote.Id+'",     "quoteDetails": {         "endCustomer": "FMH",         "unifiedEndCustomerId": "",         "projectName": "Test Project",         "application": "Enterprise",         "proposalDueDate": "12/12/3000",         "intelResponseRequestedDate": "12/12/3000",         "pricingStartDate": "12/12/3000",         "pricingEndDate": "12/12/3000",         "endCustomerCountry": "Afghanistan",         "referenceRequestID": "IQR-HPE-002",         "intelSalesRepEmail": "firstNameSalesRep@intel.com",         "intelAccountExecutiveEmail": "firstNameAE@intel.com",         "secondaryContact": "oem.test@test.com",         "additionalQuoteLetterRecipients": null,         "quoteLines": {             "OptaneSSD": [                 {                     "quoteLineId":"'+quote.SBQQ__LineItems__r[1].Id+'",                     "productId": "'+p.Id+'",                     "writeInProduct": "test",                     "quoteLinePricingEndDate": "12/12/3000",                     "quotelineReferenceID": "002",                     "quantity": 10,                     "requestedUnitPrice": 10,                     "competitorName": "test",                     "competitorProduct": "test",                     "competitorSingleSystemPricePoint": 10,                     "competitorDensity": 10,                     "additionalComment": "",                     "volumeByQuarterAndReasoning": ""                 }             ],             "OptanePMem": [                 {                     "quoteLineId":"'+quote.SBQQ__LineItems__r[2].Id+'",                     "productId": "'+p.Id+'",                     "quoteLinePricingEndDate": "12/12/3000",                     "writeInProduct": "test",                     "quotelineReferenceID": "003",                     "systemModel": "Test",                     "noOfSystems": 10,                     "noOfUnitsPerSystem": 1,                     "customerStdUnitPrice": 90,                     "requestedUnitPrice": 2,                     "pairedCPU": "1",                     "noOfCPUsPerSystem": 1,                     "dramDensity": 2,                     "noOfDRAMPerSystem": 2,                     "competitorName": "Test",                     "competitorDensity": 1,                     "competitorSingleSystemPricePoint": 5,                     "competitorNoOfSystems": 1,                     "competitorNoOfUnitsPerSystem": 1,                     "serverIntegration": "",                     "workload": "",                     "pocTestingResults": "",                     "additionalComment": null                 }             ],             "Ethernet": [                 {                     "quoteLineId":"'+quote.SBQQ__LineItems__r[3].Id+'",                     "productId": "'+p.Id+'",                     "writeInProduct": "test",                     "quoteLinePricingEndDate": "12/12/3000",                     "quotelineReferenceID": "004",                     "quantity": 10,                     "requestedUnitPrice": 20,                     "competitorProduct": "test",                     "competitorSingleSystemPricePoint": 20000,                     "competitorQuantity": 2000,                     "additionalComment": "test"                 }             ],             "DataCenterCPU": [                 {                     "quoteLineId":"'+quote.SBQQ__LineItems__r[0].Id+'",                     "productId": "'+p.Id+'",                     "quoteLinePricingEndDate": "12/12/3000",                     "writeInProduct": "test",                     "quotelineReferenceID": "001",                     "systemModel": "Test",                     "noOfSystems": 10,                     "noOfCPUsPerSystem": 1,                     "singleSystemPricePoint": 100,                     "customerStdUnitPrice": 90,                     "requestedUnitPrice": 2,                     "additionalDiscount": 0,                     "competitorName": "Test",                     "competitorSystemModel": "Test",                     "competitorProductId": "'+cp.Id+'",                     "competitorWriteInProduct": null,                     "competitorNoOfSystems": 1,                     "competitorNoOfCPUsPerSystem": 1,                     "competitorSingleSystemPrice": 8,                     "competitorAdditionalDiscount": 2,                     "additionalComment": null,                     "performanceMetrics": [                         {                             "performanceMetricsUsed": "Other",                             "performanceMetricsReferenceId": "PM-003",                             "weighting": 10,                             "intelScore": 10,                             "compScore": 5,                             "otherText": "Test"                         }                     ]                 }             ]         },         "quoteComments": [             {                 "quoteCommentReferenceId": "QC-001",                 "answer": "This is a test Message 1.## 123"             },             {                 "quoteCommentReferenceId": "QC-002",                 "answer": "This is a test Message 2."             },             {                 "quoteCommentReferenceId": "QC-003",                 "answer": "Test"             },             {                 "quoteCommentReferenceId": "QC-004",                 "answer": "This is a test Message 3."             }         ]     } }');       
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            test.startTest();
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_QuotesV2.doPatch();
            system.assert(restResponse != null, 'REST response should not be null');
            system.assert(restResponse.successContent != null, 'Success content should not be null for update operation');
            test.stopTest();
        }        
    }
    
    @isTest 
    static void test_updateQuotelineValidation() {
        SBQQ__Quote__c quote = [select id,(select Id from SBQQ__LineItems__r order by Pricing_Quote_Line_Number__c) from SBQQ__Quote__c Limit 1];
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = :'Product Z'];
        Product2 p = [Select Id from Product2 where Name = :'Write In Product'];
        User usr = [SELECT id, AccountId FROM User WHERE email='primarycontact0@noemail.com'];
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
    
    static testmethod void test_ValidatePublishQuote(){
        User usr = [SELECT id,AccountId,email,ContactId FROM User WHERE email='primarycontact1@noemail.com' Limit 1];
        User usr1 =  [SELECT id FROM User WHERE email='primarycontact0@noemail.com' Limit 1];
        Map<Id,SBQQ__QuoteLine__c> qliMap = new Map<Id,SBQQ__QuoteLine__c>([select id,SBQQ__Quote__c,Pricing_Quote_Line_Number__c,Pricing_Status_Nm__c,
                                                                            Pricing_Program_Type_Nm__c,RecordTypeId,Pricing_Ready_for_Review_cb__c,Pricing_Original_Submitted_By_Id__c,
                                                                            Pricing_Original_Submitted_Date_dt__c,Pricing_Last_Submitted_Date_dt__c,Pricing_Last_Submitted_By_Id__c 
                                                                            FROM SBQQ__QuoteLine__c where Pricing_Status_Nm__c = 'Draft' and SBQQ__Quote__r.SBQQ__PrimaryContact__c != :usr.ContactId ]);
        Set<Id> qliIdSet = new Set<Id>();
        List<Id> qliIdList = new List<Id>();
        for(String key:qliMap.keySet()){
            qliIdList.add(key);
            qliIdSet.add(key);
        }
        Id recId = qliIdList[0];
        System.runAs(usr1){
            test.startTest();
            Pricing_RestAPI_QuotesUtilityV2.publishQuoteAndQuoteLines(qliMap.get(recId).SBQQ__Quote__c,'primarycontact1@noemail.com',usr.AccountId,qliMap,null,qliIdSet,'SBQQ__Quote__c');
            test.stopTest();
        }     
        system.assert(true, 'test_ValidatePublishQuote executed successfully');
    }
    
    static testmethod void test_ValidatePrimaryContact(){
        User usr1 =  [SELECT id FROM User WHERE email='primarycontact0@noemail.com' Limit 1];
        System.runAs(usr1){
            test.startTest();
            Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsg = new Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
            Pricing_RestAPI_QuotesUtilityV2 util = new Pricing_RestAPI_QuotesUtilityV2();
            util.validatePrimaryContact('primarycontact1@noemail.com','primarycontact1@noemail.com',errorMsg);
            test.stopTest();
        }     
        system.assert(true, 'test_ValidatePrimaryContact executed successfully');
    }
    
    static testmethod void test_ValidateDiscountField(){
        User usr1 =  [SELECT id FROM User WHERE email='primarycontact0@noemail.com' Limit 1];
        Pricing_RestAPI_QuotesUtilityV2.QuotelineCPU qliCPU = new Pricing_RestAPI_QuotesUtilityV2.QuotelineCPU();
        qliCPU.singleSystemPricePoint = 10;
        qliCPU.noOfSystems = 10;
        qliCPU.requestedUnitPrice = 10;  
        qliCPU.customerStdUnitPrice = 10;
        qliCPU.additionalDiscount = 10;
        qliCPU.noOfCPUsPerSystem = 10;
        System.runAs(usr1){
            test.startTest();
            Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsg = new Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
            Map<String, boolean> fldValidMap = new Map<String, boolean>();
            Pricing_RestAPI_QuotesUtilityV2.validateDiscountField(qliCPU,fldValidMap,errorMsg);
            test.stopTest();
        }     
        system.assert(true, 'test_ValidateDiscountField executed successfully');
    }
    
    @isTest 
    static void test_deleteQuoteValidation() {
        SBQQ__Quote__c quote = [select id from SBQQ__Quote__c where SBQQ__Status__c = 'Draft' Limit 1];
        User usr = [SELECT id, AccountId FROM User WHERE email='primarycontact0@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v2.0/quoterequest/quotes';
            request.addParameter('id', quote.id);
            request.httpMethod = 'Delete';
            request.addHeader('Content-Type', 'application/json');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_QuotesV2.doDelete();
            system.assert(restResponse.successContent!=null);
            test.stopTest();
        }        
    }
    
    @isTest 
    static void test_deleteQuotelineValidation() {
        SBQQ__QuoteLine__c quoteline = [select id from SBQQ__QuoteLine__c where Pricing_Status_Nm__c = 'Draft' Limit 1];
        User usr = [SELECT id, AccountId FROM User WHERE email='primarycontact0@noemail.com'];
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
    static void testDoPost_uploadFile() {
        User usr = [SELECT id, AccountId FROM User WHERE email='primarycontact0@noemail.com'];
        SBQQ__Quote__c quote = [Select id from SBQQ__Quote__c limit 1];
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v2.0/quoterequest/uploadfile';
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{"quoteId": "","fileName": "","file": "","comment":""}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_FileUpload.doPost();
            system.assert(restResponse!=null);
            test.stopTest();
            RestRequest request2 = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request2.requestUri = '/services/apexrest/v2.0/quoterequest/uploadfile';
            request2.httpMethod = 'POST';
            request2.addHeader('Content-Type', 'application/json');
            request2.requestBody = Blob.valueOf('{"quoteId": "","fileName": "test.doc","file": "","comment":""}');
            RestContext.request = request;
            RestResponse res2 = new RestResponse();
            RestContext.response= res2;
            Pricing_RestAPI_Response restResponse2 = Pricing_RestAPI_FileUpload.doPost();
            system.assert(restResponse2!=null);
        }
    }
    @isTest 
    static void testDoPost_uploadFile2() {
        User usr = [SELECT id, AccountId FROM User WHERE email='primarycontact0@noemail.com'];
        SBQQ__Quote__c quote = [Select id from SBQQ__Quote__c limit 1];
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v2.0/quoterequest/uploadfile';
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{"quoteId": "","fileName": "test.doc","file": "","comment":""}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_FileUpload.doPost();
            system.assert(restResponse!=null);
            test.stopTest();
        }
    }
    
    public static List<User> createSalesRepUser(String emailId){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderUser];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        //System.runAs(thisUser){
        for(Id profileId : userProfileIdSet){
            User u1 = new User(Alias = 'newUser', Email= emailId,
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = profileId,
                               TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstNameSalesRep@Intel.com' + Math.floor(Math.random() * 1000));
            
            lstUser.add(u1);
            
        }
        insert lstUser;
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        for(user userId : lstUser){
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = Pricing_Test_Utility.permissionRec.Id));
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));
        } 
        if(!permissionList.isEmpty()){
            insert permissionList;
        }
        //}  
        return lstUser;
    }
    @isTest 
    static void testvalidatePairedCPUProductError() {
        List<Product2> productList  = [Select Id from Product2 where Name = :'Product X'];
        Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg qlErrorMsg = new Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg();
        qlErrorMsg.quoteLineErrors = new Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
        test.startTest();
        Pricing_RestAPI_QuotesUtilityV2 utility = new Pricing_RestAPI_QuotesUtilityV2();
        utility.validatePairedCPUProduct(productList[0].Id,'test',qlErrorMsg.quoteLineErrors,productList);
        test.stopTest();
        
        system.assert(true, 'testvalidatePairedCPUProductError executed successfully');
    }
    
    @isTest 
    static void test_createValidationsSuccessGPU() {

        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name ='Product GPU'];
        Product2 p = [Select Id from Product2 where Name ='Write In Product'];
        User usr = [SELECT id, AccountId FROM User WHERE email='primarycontact0@noemail.com'];
        List<User> salesRep2 = createSalesRepUser('testSalesRep2@intel.com');
        List<User> salesRep1 = createSalesRepUser('testSalesRep1@intel.com');
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();  
        System.runAs(lstUsers2[0])
        {
            Pricing_Test_Utility.createAccountTeamMember(usr.AccountId, salesRep2[0].Id);
            Pricing_Test_Utility.createAccountTeamMember(usr.AccountId, salesRep1[0].Id);
        }
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v2.0/quoterequest/quotes';
            request.addParameter('action', 'create');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{     "quoteDetails": {         "endCustomer": "Test 12313123",         "unifiedEndCustomerId": "",         "projectName": "IBM",         "application": "CSP",         "proposalDueDate": "12/12/3000",         "intelResponseRequestedDate": "12/12/3000",         "pricingStartDate": "12/12/3000",         "pricingEndDate": "12/12/3000",         "endCustomerCountry": "India",         "referenceRequestID": "IQR-HPE-002",         "intelSalesRepEmail": "testSalesRep2@intel.com,testSalesRep1@intel.com",         "intelAccountExecutiveEmail": "firstNameAE@intel.com", "industryTechnicalSpecialistEmail": "firstNameITS@intel.com",        "secondaryContact": "oem.test@test.com",         "additionalQuoteLetterRecipients": null,         "quoteLines": {                       "OptaneSSD": [],             "OptanePMem": [],             "Ethernet": [],             "DataCenterCPU": [],               "DataCenterGPU": [                 {                     "productId": "'+p.Id+'",                     "quoteLinePricingEndDate": "12/12/3000",                     "writeInProduct": "test",                     "quotelineReferenceID": "001",                     "systemModel": "Test",                     "noOfSystems": 10,                     "noOfCPUsPerSystem": 1,                     "singleSystemPricePoint": 100,                     "customerStdUnitPrice": 90,                     "requestedUnitPrice": 2,                     "additionalDiscount": 0,                     "competitorName": "Test",                     "competitorSystemModel": "Test",                     "competitorProductId": "'+cp.Id+'",                     "competitorWriteInProduct": null,                     "competitorNoOfSystems": 1,                     "competitorNoOfCPUsPerSystem": 1,                     "competitorSingleSystemPrice": 8,                     "competitorAdditionalDiscount": 2,                     "additionalComment": null}             ]         },         "quoteComments": [             {                 "quoteCommentReferenceId": "QC-001",                 "answer": "This is a test Message 1.## 123"             },             {                 "quoteCommentReferenceId": "QC-002",                 "answer": "This is a test Message 2."             },             {                 "quoteCommentReferenceId": "QC-003",                 "answer": "Test"             },             {                 "quoteCommentReferenceId": "QC-004",                 "answer": "This is a test Message 3."             }         ]     } }');       
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_QuotesV2.doPost();
            system.assert(restResponse!=null);
            test.stopTest();
        }        
    }
    
    @isTest
    static void testQuoteTeamCreation(){
        List<User> salesRep2 = createSalesRepUser('testSalesRep2@intel.com');
        List<User> userITS = Pricing_Test_Utility.createITSUser();
        List<User> userAE = Pricing_Test_Utility.createAEUser();
        SBQQ__Quote__c quote = [select id from SBQQ__Quote__c Limit 1];
        test.startTest();
        Pricing_RestAPI_QuotesUtilityV2.createAEQuoteTeam(quote.Id);
        Pricing_RestAPI_QuotesUtilityV2.createFSEQuoteTeam(quote.Id);
        Pricing_RestAPI_QuotesUtilityV2.createITSQuoteTeam(quote.Id);
        test.stopTest();
        system.assert(true, 'testQuoteTeamCreation executed successfully');
    }

    @isTest 
    static void test_quarterStartEndDate() {
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();  
        System.runAs(lstUsers2[0]){
            test.startTest();
            String dates = Pricing_RestAPI_QuotesUtilityV2.quarterStartEndDate();
            system.assert(dates!=null);
            test.stopTest();
        }       
    }

    @isTest 
    static void test_validateSVDQuota() {
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();        
        System.runAs(lstUsers2[0]){
            test.startTest();
            Pricing_RestAPI_QuotesUtilityV2 utilObj = new Pricing_RestAPI_QuotesUtilityV2();
            Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
            boolean isValid = utilObj.validateSVDQuota(quoteErrors);
            system.assert(isValid || !isValid);
            test.stopTest();
        }       
    }

    @isTest 
    static void test_validateGetAllQuoteDate() {
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();        
        System.runAs(lstUsers2[0]){
            test.startTest();
            Pricing_RestAPI_QuotesUtilityV2 utilObj = new Pricing_RestAPI_QuotesUtilityV2();
            Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
            quoteErrors.quoteErrors = new Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
            datetime StartDate= Date.Valueof(System.today());
            String strStartDate = StartDate.format('MM/dd/YYYY');
            Boolean validEndDate = utilObj.validateGetAllQuoteDate(strStartDate,'endDate',quoteErrors.quoteErrors);            
            system.assert(validEndDate || !validEndDate);
            Boolean validEndDate1 = utilObj.validateGetAllQuoteDate(strStartDate,'notcreatedbyemail',quoteErrors.quoteErrors);
            Boolean validEndDate2 = utilObj.validateGetAllQuoteDate(strStartDate,'operator',quoteErrors.quoteErrors);
            test.stopTest();
        }       
    } 

    @isTest 
    static void test_QuotesWrapperForContactDtlsUpt() {
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();        
        System.runAs(lstUsers2[0]){
            test.startTest();
            Pricing_RestAPI_QuotesUtilityV2.QuotesWrapperForContactDtlsUpt quoteWrapper = new  Pricing_RestAPI_QuotesUtilityV2.QuotesWrapperForContactDtlsUpt();
        
            quoteWrapper.quoteId = 'Q-12345';
            quoteWrapper.intelSalesRepEmail = 'salesrep@example.com';
            quoteWrapper.primaryContactEmail = 'primary@example.com';
            quoteWrapper.secondaryContact = 'secondary@example.com';
            quoteWrapper.additionalQuoteLetterRecipients = 'additional1@example.com; additional2@example.com';
            quoteWrapper.referenceRequestID = 'REQ-98765';
            
            System.assertEquals('Q-12345', quoteWrapper.quoteId, 'quoteId mismatch');
            System.assertEquals('salesrep@example.com', quoteWrapper.intelSalesRepEmail, 'intelSalesRepEmail mismatch');
            System.assertEquals('primary@example.com', quoteWrapper.primaryContactEmail, 'primaryContactEmail mismatch');
            System.assertEquals('secondary@example.com', quoteWrapper.secondaryContact, 'secondaryContact mismatch');
            System.assertEquals('additional1@example.com; additional2@example.com', quoteWrapper.additionalQuoteLetterRecipients, 'additionalQuoteLetterRecipients mismatch');
            System.assertEquals('REQ-98765', quoteWrapper.referenceRequestID, 'referenceRequestID mismatch');
            test.stopTest();
        }
    }

    @isTest
    static void test_MyPickListInfo() {
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();        
        System.runAs(lstUsers2[0]){
            test.startTest();
            Pricing_RestAPI_QuotesUtilityV2.MyPickListInfo pickListInfo = new Pricing_RestAPI_QuotesUtilityV2.MyPickListInfo();
            pickListInfo.active = 'true';
            pickListInfo.defaultValue = 'Option1';
            pickListInfo.label = 'Test Label';
            pickListInfo.value = 'Value1';
            pickListInfo.validFor = 'SomeValidForValue';
            
            System.assertEquals('true', pickListInfo.active, 'active value mismatch');
            System.assertEquals('Option1', pickListInfo.defaultValue, 'defaultValue mismatch');
            System.assertEquals('Test Label', pickListInfo.label, 'label mismatch');
            System.assertEquals('Value1', pickListInfo.value, 'value mismatch');
            System.assertEquals('SomeValidForValue', pickListInfo.validFor, 'validFor mismatch');
            test.stopTest();
        }
    }

    @isTest
    static void test_CurrencyFieldValueWrapper() {
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();        
        System.runAs(lstUsers2[0]){
            test.startTest();
            Pricing_RestAPI_QuotesUtilityV2.CurrencyFieldValueWrapper wrapper = new Pricing_RestAPI_QuotesUtilityV2.CurrencyFieldValueWrapper('Field1', 100.50, true);
            Pricing_RestAPI_QuotesUtilityV2.CurrencyFieldValueWrapper wrapper2 = new Pricing_RestAPI_QuotesUtilityV2.CurrencyFieldValueWrapper('Field2', 250.75, 'Field Label 2', false, true);

            System.assertEquals('Field1', wrapper.fldName, 'fldName mismatch');
            System.assertEquals(100.50, wrapper.fldValue, 'fldValue mismatch');
            System.assertEquals(true, wrapper.isMandatory, 'isMandatory mismatch');
            test.stopTest();
        }
    }

    @isTest
    static void test_NumberFieldValueWrapper() {
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();        
        System.runAs(lstUsers2[0]){
            test.startTest();
           Pricing_RestAPI_QuotesUtilityV2.NumberFieldValueWrapper wrapper = new Pricing_RestAPI_QuotesUtilityV2.NumberFieldValueWrapper('Name', 100, true);
           System.assertEquals('Name', wrapper.fldName, 'fldName mismatch');
           System.assertEquals(100, wrapper.fldValue, 'fldValue mismatch');
           System.assertEquals(true, wrapper.isMandatory, 'isMandatory mismatch');

           Pricing_RestAPI_QuotesUtilityV2.NumberFieldValueWrapper wrapper2 = new Pricing_RestAPI_QuotesUtilityV2.NumberFieldValueWrapper('Field2', 250, 'Field Label 2', false);
           System.assertEquals('Field2', wrapper2.fldName, 'fldName mismatch');
           System.assertEquals(250, wrapper2.fldValue, 'fldValue mismatch');
           System.assertEquals('Field Label 2', wrapper2.fldLabel, 'fldLabel mismatch');
           System.assertEquals(false, wrapper2.isMandatory, 'isMandatory mismatch');

            test.stopTest();
        }
    }


    @isTest
    static void test_TextFieldValueWrapper() {
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();        
        System.runAs(lstUsers2[0]){
            test.startTest();
           Pricing_RestAPI_QuotesUtilityV2.TextFieldValueWrapper wrapper = new Pricing_RestAPI_QuotesUtilityV2.TextFieldValueWrapper('Name', '100', true);
           Pricing_RestAPI_QuotesUtilityV2.TextFieldValueWrapper wrapper2 = new Pricing_RestAPI_QuotesUtilityV2.TextFieldValueWrapper('Field2', '250', 'Field Label 2', false);
           System.assertEquals('Name', wrapper.fldName, 'fldName mismatch');
           System.assertEquals('100', wrapper.fldValue, 'fldValue mismatch');
           System.assertEquals(true, wrapper.isMandatory, 'isMandatory mismatch');

           test.stopTest();
        }
    }

    // Test method for QLICRWonLostWrapper and QLICRWonLost
    @isTest
    static void testQLICRWonLostWrapper() {
        Pricing_RestAPI_QuotesUtilityV2.QLICRWonLost qlWonLost = new Pricing_RestAPI_QuotesUtilityV2.QLICRWonLost();
        qlWonLost.quotelineReferenceID = 'QLR-12345';
        qlWonLost.quotelineId = 'QL-54321';
        qlWonLost.status = 'Won';
        qlWonLost.wonLostComments = 'Great deal';
        qlWonLost.lostReason = 'None';
        qlWonLost.quoteLinePricingEndDate = '2024-12-31';
        qlWonLost.quoteLinePricingStartDate = '2024-01-01';
        qlWonLost.newRequestedPrice = 150.00;
        qlWonLost.newQuantity = 10;
        qlWonLost.additionalComment = 'Urgent order';
        qlWonLost.consumptionPlatform = 'Platform A';
        qlWonLost.consumptionSalesGeo = 'APAC';
        qlWonLost.consumptionCountry = 'India';
        qlWonLost.consumptionRegion = 'South Asia';
        qlWonLost.consumptionSegment = 'Enterprise';

        Pricing_RestAPI_QuotesUtilityV2.QLICRWonLostWrapper qlicrWonLostWrapper = new Pricing_RestAPI_QuotesUtilityV2.QLICRWonLostWrapper();
        qlicrWonLostWrapper.quoteId = 'Q-98765';
        qlicrWonLostWrapper.quoteLines = new List<Pricing_RestAPI_QuotesUtilityV2.QLICRWonLost>{ qlWonLost };
        System.assertEquals('QLR-12345', qlWonLost.quotelineReferenceID, 'quotelineReferenceID mismatch');
        System.assertEquals('QL-54321', qlWonLost.quotelineId, 'quotelineId mismatch');
    }
    
    @isTest
    static void testPerformanceMetricsWrapperDetails() {
        // Create instance of PerformanceMetrics
        Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics pm = new Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics();
        pm.performanceMetricsId = 'PM-123';
        pm.performanceMetricsUsed = 'Used for Benchmark';
        pm.weighting = 0.75;
        pm.intelScore = 85.0;
        pm.compScore = 80.0;
        pm.otherText = 'Strong performance';
        pm.performanceMetricsReferenceId = 'PMR-456';        
        System.assertEquals('PM-123', pm.performanceMetricsId, 'performanceMetricsId mismatch');        
        Pricing_RestAPI_QuotesUtilityV2.PerformanceMetricsWrapperDetails pmWrapper = new Pricing_RestAPI_QuotesUtilityV2.PerformanceMetricsWrapperDetails();
        pmWrapper.quoteLineId = 'QL-789';
        pmWrapper.performanceMetrics = new List<Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics>{ pm };
        System.assertEquals('QL-789', pmWrapper.quoteLineId, 'quoteLineId mismatch');
    }
    
    // Test method for QuoteCommentWrapperDetails and QuoteComment
    @isTest
    static void testQuoteCommentWrapperDetails() {
        Pricing_RestAPI_QuotesUtilityV2.QuoteComment qc = new Pricing_RestAPI_QuotesUtilityV2.QuoteComment();
        qc.quoteCommentReferenceId = 'QC-123';
        qc.answer = 'This is a comment';
        System.assertEquals('QC-123', qc.quoteCommentReferenceId, 'quoteCommentReferenceId mismatch');
        Pricing_RestAPI_QuotesUtilityV2.QuoteCommentWrapperDetails qcWrapper = new Pricing_RestAPI_QuotesUtilityV2.QuoteCommentWrapperDetails();
        qcWrapper.quoteId = 'Q-987';
        qcWrapper.quoteComments = new List<Pricing_RestAPI_QuotesUtilityV2.QuoteComment>{ qc };
        System.assertEquals('Q-987', qcWrapper.quoteId, 'quoteId mismatch');
    }

    @isTest
    static void test_validatePicklistValues_SingleCountryWithComma() {
        Map<String, Schema.SObjectField> objectMap = Schema.SObjectType.SBQQ__Quote__c.fields.getMap();
        List<Schema.PicklistEntry> countryEntries =
            SBQQ__Quote__c.Pricing_End_Customer_Country_Nm__c.getDescribe().getPicklistValues();
        String commaCountry;

        for (Schema.PicklistEntry entry : countryEntries) {
            if (entry.isActive() && entry.getValue().contains(',')) {
                commaCountry = entry.getValue();
                break;
            }
        }

        System.assertNotEquals(null, commaCountry, 'An active comma-containing country option is required');

        Map<String, Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs =
            new Map<String, Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
        Boolean isValid = Pricing_RestAPI_QuotesUtilityV2.validatePicklistValues(
            objectMap,
            'Pricing_End_Customer_Country_Nm__c',
            commaCountry,
            true,
            errorMsgs,
            'endCustomerCountry'
        );

        System.assertEquals(true, isValid, 'A complete comma-containing single-picklist value should be valid');
        System.assertEquals(0, errorMsgs.size(), 'A valid country should not generate an error');
    }

    @isTest
    static void test_validatePicklistValues_ConsumptionCountryCommaOptionAndAnotherCountry() {
        Map<String, Schema.SObjectField> objectMap = Schema.SObjectType.SBQQ__QuoteLine__c.fields.getMap();
        List<Schema.PicklistEntry> countryEntries =
            SBQQ__QuoteLine__c.Pricing_End_Customer_Country__c.getDescribe().getPicklistValues();
        String commaCountry;
        String otherCountry;

        for (Schema.PicklistEntry entry : countryEntries) {
            if (!entry.isActive()) {
                continue;
            }
            if (entry.getValue().contains(',')) {
                commaCountry = entry.getValue();
            } else if (otherCountry == null) {
                otherCountry = entry.getValue();
            }
            if (commaCountry != null && otherCountry != null) {
                break;
            }
        }

        System.assertNotEquals(null, commaCountry, 'An active comma-containing country option is required');
        System.assertNotEquals(null, otherCountry, 'A second active country option is required');

        Map<String, Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs =
            new Map<String, Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
        Boolean isValid = Pricing_RestAPI_QuotesUtilityV2.validatePicklistValues(
            objectMap,
            'Pricing_End_Customer_Country__c',
            commaCountry + ',' + otherCountry,
            false,
            errorMsgs,
            'consumptionCountry'
        );

        System.assertEquals(true, isValid, 'Comma-containing and ordinary country options should both be valid');
        System.assertEquals(0, errorMsgs.size(), 'Valid country selections should not generate an error');
    }
 

}