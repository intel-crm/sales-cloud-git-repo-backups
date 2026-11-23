@isTest
public class Pricing_RestAPI_QuotesUtilityTest {
    
    Public static PermissionSet permissionRec;
    Static{
        permissionRec = [SELECT Id, Name FROM PermissionSet where Name=:Label.Pricing_CPQ_Managed_License_User Limit 1];
    }
    
    @testSetup
    static void dataSetup(){
        Pricing_RestAPI_TestUtility.createRestAPIErrorCodesConfig();
        List<Product2> prodList = new List<Product2>();
        Product2 prod = new Product2();
        prod.Core_Product_Org__c = 'Sales';
        prod.Core_Product_Type__c = 'Processors';
        prod.Core_Sales_Visible_Flag__c  = True;
        prod.IsActive = True;
        prod.Core_Hierarchy_ID__c = '43';
        prod.Core_Group_Code_Short_Name__c = 'CCG';
        prod.Name = 'Product X';
        prod.Core_Processor_Number_Nm__c = '1234';
        prodList.add(prod);
        
        Product2 prod1 = new Product2();
        prod1.Core_Product_Org__c = 'Sales';
        prod1.Core_Product_Type__c = 'Processors';
        prod1.Core_Sales_Visible_Flag__c  = True;
        prod1.IsActive = True;
        prod1.Core_Hierarchy_ID__c = '43';
        prod1.Core_Group_Code_Short_Name__c = 'CCG';
        prod1.Name = 'Product1';
        prod.Core_Processor_Number_Nm__c = '1234';
        prodList.add(prod1);
        
        Product2 prod2 = new Product2();
        prod2.Core_Product_Org__c = 'Sales';
        prod2.Core_Product_Type__c = 'Processors';
        prod2.Core_Sales_Visible_Flag__c  = True;
        prod2.IsActive = True;
        prod2.Core_Hierarchy_ID__c = '43';
        prod2.Core_Group_Code_Short_Name__c = 'CCG';
        prod2.Name = 'Write In Product';
        prodList.add(prod2);
        System.debug('Queries'+Limits.getQueries());
        insert prodList;
        System.debug('Queries'+Limits.getQueries());
        Pricing_Test_Utility.createPriceBook();
        
        List<Pricing_Competitor_Product__c> cpList = new List<Pricing_Competitor_Product__c>();
        
        Pricing_Competitor_Product__c cp = new Pricing_Competitor_Product__c();
        cp.Name = 'Product Z';
        cp.Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z';
        cp.Pricing_Active_cb__c = true;
        cpList.add(cp);
        
        Pricing_Competitor_Product__c cp1 = new Pricing_Competitor_Product__c();
        cp1.Name = 'Comp Product';
        cp1.Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z';
        cp1.Pricing_Active_cb__c = true;
        cpList.add(cp1);
        
        Pricing_Competitor_Product__c cp2 = new Pricing_Competitor_Product__c();
        cp2.Name = 'Write In Product';
        cp2.Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z';
        cp2.Pricing_Active_cb__c = true;
        cpList.add(cp2);
        
        insert cpList;
        
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();  
        List<User> normalUser = createUser();
        System.runAs(lstUsers2[0])
        {
            Test.startTest();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            
            Pricing_UnifiedEndCustomerAccountMapping__c unifiedEndCustomer = new Pricing_UnifiedEndCustomerAccountMapping__c();
            unifiedEndCustomer.name='Write In End Customer';
            insert unifiedEndCustomer;
            
            insert accTeam;
            Test.stopTest();
        }     
    }
    
    static testmethod void validQuote_Test(){
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        Pricing_UnifiedEndCustomerAccountMapping__c unifiedId =[Select Id from Pricing_UnifiedEndCustomerAccountMapping__c where name='Write In End Customer' limit 1];
        system.runAs(usr){
            test.startTest();
            Pricing_RestAPI_QuotesUtility.QuoteDetails quoteWrapper= new Pricing_RestAPI_QuotesUtility.QuoteDetails();
            quoteWrapper.primaryContactEmail='primarycontact@noemail.com';
            quoteWrapper.endCustomer='any';
            //quoteWrapper.unifiedEndCustomerId=unifiedId.id;
            quoteWrapper.referenceRequestID='IQR-Dell-001';
            quoteWrapper.projectName='Test';
            quoteWrapper.pricingStartDate='11/4/2029';
            quoteWrapper.pricingEndDate='11/8/2029';
            quoteWrapper.intelSalesRepEmail='jasminex.narula@gmail.com';
            quoteWrapper.intelAccountExecutiveEmail='sonalx.pawar@gmail.com';
            quoteWrapper.endCustomerCountry='Hungary';
            quoteWrapper.endCustomer='test';
            quoteWrapper.proposalDueDate='11/1/2029';
            quoteWrapper.intelResponseRequestedDate='11/1/2029';
            quoteWrapper.application='HPC';
            quoteWrapper.additionalQuoteLetterRecipients='test@intel.com';
            
            Pricing_RestAPI_QuotesUtility.QuoteDetails quoteWrapperWrong= new Pricing_RestAPI_QuotesUtility.QuoteDetails();
            quoteWrapperWrong.primaryContactEmail='primarcontactnoemail.com';
            quoteWrapper.endCustomer='';
            quoteWrapper.unifiedEndCustomerId=unifiedId.Id;
            quoteWrapperWrong.referenceRequestID='';
            quoteWrapperWrong.projectName='TestAaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
            quoteWrapperWrong.pricingStartDate='11/4/2029';
            quoteWrapperWrong.pricingEndDate='11/8/2019';
            quoteWrapperWrong.intelSalesRepEmail='';
            quoteWrapperWrong.intelAccountExecutiveEmail='test@xyz.com';
            quoteWrapperWrong.industryTechnicalSpecialistEmail='jasminex.narula@gmail.com';
            quoteWrapperWrong.endCustomerCountry='Hungary';
            quoteWrapperWrong.endCustomer='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest';
            quoteWrapperWrong.proposalDueDate='11/13/2009';
            quoteWrapperWrong.intelResponseRequestedDate='11/13/2009';
            quoteWrapperWrong.application='Test';
            
            Pricing_RestAPI_QuotesUtility.QuoteDetails quoteWrapperWrong1= new Pricing_RestAPI_QuotesUtility.QuoteDetails();
            quoteWrapperWrong1.primaryContactEmail='primarycontact@noemail.com';
            quoteWrapper.endCustomer='test';
            quoteWrapper.unifiedEndCustomerId='unifiedId';
            quoteWrapperWrong1.referenceRequestID='';
            quoteWrapperWrong1.projectName='TestAaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
            quoteWrapperWrong1.pricingStartDate='11/4/2029';
            quoteWrapperWrong1.pricingEndDate='11/2/2029';
            quoteWrapperWrong1.intelSalesRepEmail='jasminex.narula@gmail.com';
            quoteWrapperWrong1.intelAccountExecutiveEmail='jasminex.narula@gmail.com';
            quoteWrapperWrong1.industryTechnicalSpecialistEmail='jasminex.narula@gmail.com';
            quoteWrapperWrong1.endCustomerCountry='Hungary';
            quoteWrapperWrong1.endCustomer='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest';
            quoteWrapperWrong1.proposalDueDate='11/13/2009';
            quoteWrapperWrong1.intelResponseRequestedDate='11/13/2009';
            quoteWrapperWrong1.application='Test';
            
            Pricing_RestAPI_QuotesUtility.QuoteWrapper qw = new Pricing_RestAPI_QuotesUtility.QuoteWrapper();
            qw.QuoteDetails = quoteWrapper;
            
            Pricing_RestAPI_QuotesUtility.QuoteWrapper qww = new Pricing_RestAPI_QuotesUtility.QuoteWrapper();
            qww.QuoteDetails = quoteWrapperWrong;
            
            Pricing_RestAPI_QuotesUtility.QuoteWrapper qww1 = new Pricing_RestAPI_QuotesUtility.QuoteWrapper();
            qww1.QuoteDetails = quoteWrapperWrong1;
            
            Pricing_RestAPI_QuotesUtility quoteUtility = new Pricing_RestAPI_QuotesUtility();
            Pricing_RestAPI_QuotesUtility.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtility.createQuoteRecord(quoteWrapper);
            Pricing_RestAPI_QuotesUtility.createQuoteRecord(quoteWrapperWrong);
            boolean responce = quoteUtility.validateQuote(qw, quoteErrors, true);
            boolean responce1 = quoteUtility.validateQuote(qww, quoteErrors, true);
            boolean responce2 = quoteUtility.validateQuote(qww, quoteErrors, true);
            Pricing_RestAPI_QuotesUtility.isUpdateDraftQuote=true;
            boolean responce3 = quoteUtility.validateQuote(qww1, quoteErrors, true);
            system.assert(responce!=null);
            test.stoptest();
        }
        
    }   
    static testmethod void validQuoteLine_Test(){
        
        //CH.Start
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
        Account acc = [Select Id from Account where Name = 'Test Account'];
        Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
        Product2 prod = [Select Id from Product2 where Name = 'Product X'];
        Pricing_UnifiedEndCustomerAccountMapping__c unifiedEndCustomer = [Select Id from Pricing_UnifiedEndCustomerAccountMapping__c where name='Write In End Customer'];
        
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = acc.Id;
        quote.SBQQ__PrimaryContact__c = con.Id;
        quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
        quote.Pricing_Project_Name_Nm__c = 'Test Project';
        quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
        quote.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
        quote.Pricing_End_Customer__c=unifiedEndCustomer.id;
        quote.Pricing_Customer_Nm__c = 'FMH';
        quote.Pricing_ShipmentStDate_Dt__c = system.today()+1;
        quote.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
        quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
        quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
        quote.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
        quote.Pricing_Region_Nm__c = 'APJ';
        quote.SBQQ__Status__c = 'Submitted';
        quoteList.add(quote);
        insert quoteList; 
        
        List<SBQQ__QuoteLine__c> quoteLine = new List<SBQQ__QuoteLine__c>(); 
        SBQQ__QuoteLine__c quoteLineob = new SBQQ__QuoteLine__c(); 
        quoteLineob.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
        quoteLineob.Pricing_Product_Nm__c = prod.Id;
        //quoteLineob.SBQQ__Product__c = prod.Id;
        quoteLineob.Pricing_Other_Product_Nm__c='';
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
        quoteLineob.SBQQ__Quote__c = quote.Id;
        quoteLineob.Pricing_Status_Nm__c='Draft';
        quoteLine.add(quoteLineob);
        test.startTest();
        insert quoteLine; 
        
        List<Pricing_Performance_Metric__c> mList=new List<Pricing_Performance_Metric__c>();
        Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
        metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Other_Nm__c='test';
        metrics.Pricing_Performance_Metric_Nm__c='Other';
        metrics.Pricing_Quote_Line__c=quoteLine[0].Id;
        metrics.Pricing_Weighting_Pct__c=10;
        mList.add(metrics);
        insert mList;			
        test.stopTest();
        //CH.End        
        
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        Pricing_Competitor_Product__c compProduct = [Select Id from Pricing_Competitor_Product__c limit 1];
        system.runAs(usr){
            
            //Pricing_Competitor_Product__c compProduct = [Select Id from Pricing_Competitor_Product__c limit 1];
            Product2 product = [Select Id from Product2 limit 1];
            
            List<Pricing_RestAPI_QuotesUtility.QuoteLine> quoteLineList = new List<Pricing_RestAPI_QuotesUtility.QuoteLine>();
            Pricing_RestAPI_QuotesUtility.QuoteLine quotelineObj = new Pricing_RestAPI_QuotesUtility.QuoteLine();
            quotelineObj.productId = product.Id;
            quotelineObj.quotelineReferenceID = 'QL-001';
            quotelineObj.quoteLinePricingEndDate = '12/25/2020';
            quotelineObj.writeInProduct = 'Intel i5';
            quotelineObj.systemModel = 'Test';
            quotelineObj.noOfSystems = 10;
            quotelineObj.noOfCPUsPerSystem = 5;
            quotelineObj.singleSystemPrice = 1000;
            quotelineObj.customerStdUnitPrice = 500;
            quotelineObj.requestedDiscountUnitPrice = 200;
            quotelineObj.additionalDiscount = 0;
            quotelineObj.competitorName = 'Dell Dell';
            quotelineObj.competitorSystemModel = 'Test';
            quotelineObj.competitorProductId = compProduct.Id;
            quotelineObj.competitorWriteInProduct = 'test';
            quotelineObj.competitorNoOfSystems = 12;
            quotelineObj.competitorNoOfCPUsPerSystem = 1;
            quotelineObj.competitorSingleSystemPrice = 8;
            quotelineObj.competitorAdditionalDiscount = 2;
            quoteLineList.add(quotelineObj);
            
            SBQQ__Quote__c quotels = [Select Id from SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            Pricing_RestAPI_QuotesUtility.QuoteLineWrapper quoteLineWrapper = new  Pricing_RestAPI_QuotesUtility.QuoteLineWrapper();
            quoteLineWrapper.quoteId = quotels.Id;
            quoteLineWrapper.quoteLines = quoteLineList;
            
            List<Pricing_RestAPI_QuotesUtility.QuoteLine> quoteLineList1 = new List<Pricing_RestAPI_QuotesUtility.QuoteLine>();
            quoteLineList1.add(null);
            Pricing_RestAPI_QuotesUtility.QuoteLineWrapper quoteLineWrapper1 = new  Pricing_RestAPI_QuotesUtility.QuoteLineWrapper();
            quoteLineWrapper1.quoteId = null;
            quoteLineWrapper1.quoteLines = quoteLineList1;
            
            Pricing_RestAPI_QuotesUtility.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtility utilObj = new Pricing_RestAPI_QuotesUtility();
            //List<SBQQ__QuoteLine__c> qlList=Pricing_RestAPI_QuotesUtility.createQuoteRecord(quoteLineWrapper);
            List<SBQQ__QuoteLine__c> qlList1= Pricing_RestAPI_QuotesUtility.createQuoteLineRecords(quoteLineWrapper.quoteId,quoteLineList);
            boolean responce = utilObj.validateQuoteLineWrapper(quoteLineWrapper, qErrorMsg, false);
            boolean res = utilObj.validateQuoteLineWrapper(quoteLineWrapper, qErrorMsg, true);
            boolean responce1 = utilObj.validateQuoteLineWrapper(quoteLineWrapper1, qErrorMsg, false);
            boolean responce2 = utilObj.validateQuoteLineWrapper(quoteLineWrapper1, qErrorMsg, true);
            Pricing_RestAPI_QuotesUtility.quarterStartEndDate();
            Date pricingdate= Date.parse('11/1/2029');
            Pricing_RestAPI_QuotesUtility.QuoteLineErrorMsg quoteLineErrors = new Pricing_RestAPI_QuotesUtility.QuoteLineErrorMsg();
            utilObj.validateQuoteLine(quotelineObj, pricingdate, quoteLineErrors,true);       
            system.assert(responce!=null);
            
        }
    }
    static testmethod void validSVDQuoteLine_Test(){
        //CH.Start
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
        Account acc = [Select Id from Account where Name = 'Test Account'];
        Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
        Product2 prod = [Select Id from Product2 where Name = 'Product X'];
        Pricing_UnifiedEndCustomerAccountMapping__c unifiedEndCustomer = [Select Id from Pricing_UnifiedEndCustomerAccountMapping__c where name='Write In End Customer'];
        
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = acc.Id;
        quote.SBQQ__PrimaryContact__c = con.Id;
        quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
        quote.Pricing_Project_Name_Nm__c = 'Test Project';
        quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
        quote.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
        quote.Pricing_End_Customer__c=unifiedEndCustomer.id;
        quote.Pricing_Customer_Nm__c = 'FMH';
        quote.Pricing_ShipmentStDate_Dt__c = system.today()+1;
        quote.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
        quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
        quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
        quote.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
        quote.Pricing_Region_Nm__c = 'APJ';
        quote.SBQQ__Status__c = 'Submitted';
        quoteList.add(quote);
        insert quoteList; 
        
        List<SBQQ__QuoteLine__c> quoteLine = new List<SBQQ__QuoteLine__c>(); 
        SBQQ__QuoteLine__c quoteLineob = new SBQQ__QuoteLine__c(); 
        quoteLineob.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
        quoteLineob.Pricing_Product_Nm__c = prod.Id;
        //quoteLineob.SBQQ__Product__c = prod.Id;
        quoteLineob.Pricing_Other_Product_Nm__c='';
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
        quoteLineob.SBQQ__Quote__c = quote.Id;
        quoteLineob.Pricing_Status_Nm__c='Draft';
        quoteLine.add(quoteLineob);
        test.startTest();
        insert quoteLine; 
        
        List<Pricing_Performance_Metric__c> mList=new List<Pricing_Performance_Metric__c>();
        Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
        metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Other_Nm__c='test';
        metrics.Pricing_Performance_Metric_Nm__c='Other';
        metrics.Pricing_Quote_Line__c=quoteLine[0].Id;
        metrics.Pricing_Weighting_Pct__c=10;
        mList.add(metrics);
        insert mList;			
        test.stopTest();
        //CH.End        
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        Pricing_Competitor_Product__c compProduct = [Select Id from Pricing_Competitor_Product__c limit 1];
        system.runAs(usr){
            //test.startTest();
            //Pricing_Competitor_Product__c compProduct = [Select Id from Pricing_Competitor_Product__c limit 1];
            Product2 product = [Select Id from Product2 limit 1];
            
            List<Pricing_RestAPI_QuotesUtility.QuoteLine> quoteLineList = new List<Pricing_RestAPI_QuotesUtility.QuoteLine>();
            Pricing_RestAPI_QuotesUtility.QuoteLine quotelineObj = new Pricing_RestAPI_QuotesUtility.QuoteLine();
            quotelineObj.productId = product.Id;
            quotelineObj.quotelineReferenceID = 'QL-001';
            quotelineObj.quoteLinePricingEndDate = '12/25/2020';
            quotelineObj.writeInProduct = 'Intel i5';
            quotelineObj.systemModel = 'Test';
            quotelineObj.noOfSystems = 10;
            quotelineObj.noOfCPUsPerSystem = 5;
            quotelineObj.singleSystemPrice = 1000;
            quotelineObj.customerStdUnitPrice = 500;
            quotelineObj.requestedDiscountUnitPrice = 200;
            quotelineObj.additionalDiscount = 0;
            quotelineObj.competitorName = 'Dell Dell';
            quotelineObj.competitorSystemModel = 'Test';
            quotelineObj.competitorProductId = compProduct.Id;
            quotelineObj.competitorWriteInProduct = 'test';
            quotelineObj.competitorNoOfSystems = 12;
            quotelineObj.competitorNoOfCPUsPerSystem = 1;
            quotelineObj.competitorSingleSystemPrice = 8;
            quotelineObj.competitorAdditionalDiscount = 2;
            quoteLineList.add(quotelineObj);
            
            SBQQ__Quote__c quotels = [Select Id from SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            Pricing_RestAPI_QuotesUtility.QuoteLineWrapper quoteLineWrapper = new  Pricing_RestAPI_QuotesUtility.QuoteLineWrapper();
            quoteLineWrapper.quoteId = quotels.Id;
            quoteLineWrapper.quoteLines = quoteLineList;
            
            List<Pricing_RestAPI_QuotesUtility.QuoteLine> quoteLineList1 = new List<Pricing_RestAPI_QuotesUtility.QuoteLine>();
            quoteLineList1.add(null);
            Pricing_RestAPI_QuotesUtility.QuoteLineWrapper quoteLineWrapper1 = new  Pricing_RestAPI_QuotesUtility.QuoteLineWrapper();
            quoteLineWrapper1.quoteId = null;
            quoteLineWrapper1.quoteLines = quoteLineList1;
            Pricing_RestAPI_Quotelines.isSvdQuoteLine=true;
            Pricing_RestAPI_QuotesUtility.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtility utilObj = new Pricing_RestAPI_QuotesUtility();
            //List<SBQQ__QuoteLine__c> qlList=Pricing_RestAPI_QuotesUtility.createQuoteRecord(quoteLineWrapper);
            List<SBQQ__QuoteLine__c> qlList1= Pricing_RestAPI_QuotesUtility.createQuoteLineRecords(quoteLineWrapper.quoteId,quoteLineList);
            boolean responce = utilObj.validateQuoteLineWrapper(quoteLineWrapper, qErrorMsg, false);
            boolean res = utilObj.validateQuoteLineWrapper(quoteLineWrapper, qErrorMsg, true);
            boolean responce1 = utilObj.validateQuoteLineWrapper(quoteLineWrapper1, qErrorMsg, false);
            boolean responce2 = utilObj.validateQuoteLineWrapper(quoteLineWrapper1, qErrorMsg, true);
            
            Date pricingdate= Date.parse('11/1/2029');
            Pricing_RestAPI_QuotesUtility.QuoteLineErrorMsg quoteLineErrors = new Pricing_RestAPI_QuotesUtility.QuoteLineErrorMsg();
            utilObj.validateQuoteLine(quotelineObj, pricingdate, quoteLineErrors,true);       
            system.assert(responce!=null);
            //test.stopTest();
        }
    }    
    static testmethod void validQuoteLine_Test1(){
        
        //CH.Start
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
        Account acc = [Select Id from Account where Name = 'Test Account'];
        Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
        Product2 prod = [Select Id from Product2 where Name = 'Product X'];
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
        
        List<SBQQ__QuoteLine__c> quoteLine = new List<SBQQ__QuoteLine__c>(); 
        SBQQ__QuoteLine__c quoteLineob = new SBQQ__QuoteLine__c(); 
        quoteLineob.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
        quoteLineob.Pricing_Product_Nm__c = prod.Id;
        //quoteLineob.SBQQ__Product__c = prod.Id;
        quoteLineob.Pricing_Other_Product_Nm__c='';
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
        quoteLine.add(quoteLineob);
        test.startTest();
        insert quoteLine; 
        
        List<Pricing_Performance_Metric__c> mList=new List<Pricing_Performance_Metric__c>();
        Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
        metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Other_Nm__c='test';
        metrics.Pricing_Performance_Metric_Nm__c='Other';
        metrics.Pricing_Quote_Line__c=quoteLine[0].Id;
        metrics.Pricing_Weighting_Pct__c=10;
        mList.add(metrics);
        insert mList;			
        test.stopTest();
        //CH.End
        
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        Pricing_Competitor_Product__c compProduct = [Select Id from Pricing_Competitor_Product__c limit 1];
        system.runAs(usr){
            //test.startTest();
            //Pricing_Competitor_Product__c compProduct = [Select Id from Pricing_Competitor_Product__c limit 1];
            Product2 product = [Select Id from Product2 limit 1];
            
            List<Pricing_RestAPI_QuotesUtility.QuoteLine> quoteLineList = new List<Pricing_RestAPI_QuotesUtility.QuoteLine>();
            Pricing_RestAPI_QuotesUtility.QuoteLine quotelineObj = new Pricing_RestAPI_QuotesUtility.QuoteLine();
            quotelineObj.productId = '';
            quotelineObj.quotelineReferenceID = 'QL-001';
            quotelineObj.quoteLinePricingEndDate = '12/25/2010';
            quotelineObj.writeInProduct = 'Intel i5';
            quotelineObj.systemModel = null;
            quotelineObj.noOfSystems = -1;
            quotelineObj.noOfCPUsPerSystem = -1;
            quotelineObj.singleSystemPrice = 1.2;
            quotelineObj.customerStdUnitPrice = -500;
            quotelineObj.requestedDiscountUnitPrice = 1000;
            quotelineObj.additionalDiscount = 0;
            quotelineObj.competitorName = 'Dell DellDell DellDell DellDell DellDell DellDell DellDell DellDell DDDDDDDDell DellDell DellDell DellDell Dell';
            quotelineObj.competitorSystemModel = null;
            quotelineObj.competitorProductId = '';
            quotelineObj.competitorWriteInProduct = '';
            quotelineObj.competitorNoOfSystems = 0;
            quotelineObj.competitorNoOfCPUsPerSystem = 0;
            quotelineObj.competitorSingleSystemPrice = 1236667789;
            quotelineObj.competitorAdditionalDiscount = 0;
            quoteLineList.add(quotelineObj);
            
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            Pricing_RestAPI_QuotesUtility.QuoteLineWrapper quoteLineWrapper = new  Pricing_RestAPI_QuotesUtility.QuoteLineWrapper();
            quoteLineWrapper.quoteId = quote.Id;
            quoteLineWrapper.quoteLines = quoteLineList;
            
            List<Pricing_RestAPI_QuotesUtility.QuoteLine> quoteLineList1 = new List<Pricing_RestAPI_QuotesUtility.QuoteLine>();
            Pricing_RestAPI_QuotesUtility.QuoteLineWrapper quoteLineWrapper1 = new  Pricing_RestAPI_QuotesUtility.QuoteLineWrapper();
            quoteLineWrapper1.quoteId = '';
            quoteLineWrapper1.quoteLines = quoteLineList1;
            
            Pricing_RestAPI_QuotesUtility.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtility utilObj = new Pricing_RestAPI_QuotesUtility();
            //List<SBQQ__QuoteLine__c> qlList=Pricing_RestAPI_QuotesUtility.createQuoteRecord(quoteLineWrapper);
            boolean responce = utilObj.validateQuoteLineWrapper(quoteLineWrapper1, qErrorMsg, false);
            Date pricingdate= Date.parse('11/1/2029');
            Pricing_RestAPI_QuotesUtility.QuoteLineErrorMsg quoteLineErrors = new Pricing_RestAPI_QuotesUtility.QuoteLineErrorMsg();
            utilObj.validateQuoteLine(quotelineObj, pricingdate, quoteLineErrors,true);
            system.assert(utilObj.validateQuoteLine(quotelineObj, pricingdate, quoteLineErrors,true)!=null);
            //test.stopTest();
        }
    }
    
    static testmethod void validProducts(){
        
        //CH.Start
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
        Account acc = [Select Id from Account where Name = 'Test Account'];
        Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
        Product2 prod = [Select Id from Product2 where Name = 'Product X'];
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
        
        List<SBQQ__QuoteLine__c> quoteLine = new List<SBQQ__QuoteLine__c>(); 
        SBQQ__QuoteLine__c quoteLineob = new SBQQ__QuoteLine__c(); 
        quoteLineob.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
        quoteLineob.Pricing_Product_Nm__c = prod.Id;
        //quoteLineob.SBQQ__Product__c = prod.Id;
        quoteLineob.Pricing_Other_Product_Nm__c='';
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
        quoteLine.add(quoteLineob);
        test.startTest();
        insert quoteLine; 
        
        List<Pricing_Performance_Metric__c> mList=new List<Pricing_Performance_Metric__c>();
        Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
        metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Other_Nm__c='test';
        metrics.Pricing_Performance_Metric_Nm__c='Other';
        metrics.Pricing_Quote_Line__c=quoteLine[0].Id;
        metrics.Pricing_Weighting_Pct__c=10;
        mList.add(metrics);
        insert mList;			
        test.stopTest();
        //CH.End
        
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        Pricing_Competitor_Product__c compProduct1 = [Select Id from Pricing_Competitor_Product__c WHERE Name = 'Comp Product'];
        system.runAs(usr){
            //test.startTest();
            try{
                //Pricing_Competitor_Product__c compProduct1 = [Select Id from Pricing_Competitor_Product__c WHERE Name = 'Comp Product'];
                Product2 product1 = [Select Id from Product2 WHERE Name = 'Product X'];
                
                List<Pricing_RestAPI_QuotesUtility.QuoteLine> quoteLineList = new List<Pricing_RestAPI_QuotesUtility.QuoteLine>();
                Pricing_RestAPI_QuotesUtility.QuoteLine quotelineObj = new Pricing_RestAPI_QuotesUtility.QuoteLine();
                quotelineObj.productId = product1.Id;
                quotelineObj.quotelineReferenceID = 'QL-001';
                quotelineObj.quoteLinePricingEndDate = '12/25/2020';
                quotelineObj.writeInProduct = '';
                quotelineObj.systemModel = 'Test';
                quotelineObj.noOfSystems = 10;
                quotelineObj.noOfCPUsPerSystem = 5;
                quotelineObj.singleSystemPrice = 1000;
                quotelineObj.customerStdUnitPrice = 500;
                quotelineObj.requestedDiscountUnitPrice = 200;
                quotelineObj.additionalDiscount = 0;
                quotelineObj.competitorName = 'Dell Dell';
                quotelineObj.competitorSystemModel = 'Test';
                quotelineObj.competitorProductId = compProduct1.Id;
                quotelineObj.competitorWriteInProduct = '';
                quotelineObj.competitorNoOfSystems = 12;
                quotelineObj.competitorNoOfCPUsPerSystem = 1;
                quotelineObj.competitorSingleSystemPrice = 8;
                quotelineObj.competitorAdditionalDiscount = 2;
                quoteLineList.add(quotelineObj);
                
                SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
                Pricing_RestAPI_QuotesUtility.QuoteLineWrapper quoteLineWrapper = new  Pricing_RestAPI_QuotesUtility.QuoteLineWrapper();
                quoteLineWrapper.quoteId = quote.Id;
                quoteLineWrapper.quoteLines = quoteLineList;
                
                List<Pricing_RestAPI_QuotesUtility.QuoteLine> quoteLineList1 = new List<Pricing_RestAPI_QuotesUtility.QuoteLine>();
                Pricing_RestAPI_QuotesUtility.QuoteLineWrapper quoteLineWrapper1 = new  Pricing_RestAPI_QuotesUtility.QuoteLineWrapper();
                quoteLineWrapper1.quoteId = '';
                quoteLineWrapper1.quoteLines = quoteLineList1;
                
                Pricing_RestAPI_QuotesUtility.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
                Pricing_RestAPI_QuotesUtility utilObj = new Pricing_RestAPI_QuotesUtility();
                //List<SBQQ__QuoteLine__c> qlList=Pricing_RestAPI_QuotesUtility.createQuoteRecord(quoteLineWrapper);
                List<SBQQ__QuoteLine__c> qlList1= Pricing_RestAPI_QuotesUtility.createQuoteLineRecords(quoteLineWrapper.quoteId,quoteLineList);
                boolean responce = utilObj.validateQuoteLineWrapper(quoteLineWrapper, qErrorMsg, false);
                boolean res = utilObj.validateQuoteLineWrapper(quoteLineWrapper, qErrorMsg, true);
                boolean responce1 = utilObj.validateQuoteLineWrapper(quoteLineWrapper1, qErrorMsg, false);
                
                Date pricingdate= Date.parse('11/1/2029');
                Pricing_RestAPI_QuotesUtility.QuoteLineErrorMsg quoteLineErrors = new Pricing_RestAPI_QuotesUtility.QuoteLineErrorMsg();
                utilObj.validateQuoteLine(quotelineObj, pricingdate, quoteLineErrors,true);       
            }catch(DMLException e){
                system.assertEquals(e.getMessage(), e.getMessage());        
            }
            //test.stoptest();
        }
    }
    
    
    
    static testmethod void invalidProducts(){
        
        //CH.Start
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
        Account acc = [Select Id from Account where Name = 'Test Account'];
        Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
        Product2 prod = [Select Id from Product2 where Name = 'Product X'];
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
        quote2.SBQQ__Status__c = 'Draft';
        quoteList.add(quote2);
        insert quoteList; 
        
        List<SBQQ__QuoteLine__c> quoteLine = new List<SBQQ__QuoteLine__c>(); 
        SBQQ__QuoteLine__c quoteLineob = new SBQQ__QuoteLine__c(); 
        quoteLineob.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
        quoteLineob.Pricing_Product_Nm__c = prod.Id;
        //quoteLineob.SBQQ__Product__c = prod.Id;
        quoteLineob.Pricing_Other_Product_Nm__c='';
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
        quoteLine.add(quoteLineob);
        test.startTest();
        insert quoteLine; 
        
        List<Pricing_Performance_Metric__c> mList=new List<Pricing_Performance_Metric__c>();
        Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
        metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Other_Nm__c='test';
        metrics.Pricing_Performance_Metric_Nm__c='Other';
        metrics.Pricing_Quote_Line__c=quoteLine[0].Id;
        metrics.Pricing_Weighting_Pct__c=10;
        mList.add(metrics);
        insert mList;
        test.stopTest();
        
        //CH.End
        
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        Pricing_Competitor_Product__c compProduct1 = [Select Id from Pricing_Competitor_Product__c WHERE Name = 'Write In Product'];
        system.runAs(usr){
            //test.startTest();
            try{	
                //Pricing_Competitor_Product__c compProduct1 = [Select Id from Pricing_Competitor_Product__c WHERE Name = 'Write In Product'];
                Product2 product1 = [Select Id from Product2 WHERE Name = 'Product X'];
                
                List<Pricing_RestAPI_QuotesUtility.QuoteLine> quoteLineList = new List<Pricing_RestAPI_QuotesUtility.QuoteLine>();
                Pricing_RestAPI_QuotesUtility.QuoteLine quotelineObj = new Pricing_RestAPI_QuotesUtility.QuoteLine();
                quotelineObj.productId = '01t2h000001PlvKAAA';
                quotelineObj.quotelineReferenceID = 'QL-001';
                quotelineObj.quoteLinePricingEndDate = '12/25/2020';
                quotelineObj.writeInProduct = '';
                quotelineObj.systemModel = 'Test';
                quotelineObj.noOfSystems = 1;
                quotelineObj.noOfCPUsPerSystem = 5;
                quotelineObj.singleSystemPrice = 1000;
                quotelineObj.customerStdUnitPrice = 500;
                quotelineObj.requestedDiscountUnitPrice = 1000;
                quotelineObj.additionalDiscount = 1;
                quotelineObj.competitorName = 'Dell Dell';
                quotelineObj.competitorSystemModel = 'Test';
                quotelineObj.competitorProductId = '01t2h000001PlvKAAA';
                quotelineObj.competitorWriteInProduct = '';
                quotelineObj.competitorNoOfSystems = 12;
                quotelineObj.competitorNoOfCPUsPerSystem = 1;
                quotelineObj.competitorSingleSystemPrice = 8;
                quotelineObj.competitorAdditionalDiscount = 2;
                quoteLineList.add(quotelineObj);
                
                //SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
                Pricing_RestAPI_QuotesUtility.QuoteLineWrapper quoteLineWrapper = new  Pricing_RestAPI_QuotesUtility.QuoteLineWrapper();
                quoteLineWrapper.quoteId = quote2.Id;
                quoteLineWrapper.quoteLines = quoteLineList;
                
                List<Pricing_RestAPI_QuotesUtility.QuoteLine> quoteLineList1 = new List<Pricing_RestAPI_QuotesUtility.QuoteLine>();
                Pricing_RestAPI_QuotesUtility.QuoteLineWrapper quoteLineWrapper1 = new  Pricing_RestAPI_QuotesUtility.QuoteLineWrapper();
                quoteLineWrapper1.quoteId = '';
                quoteLineWrapper1.quoteLines = quoteLineList1;
                
                Pricing_RestAPI_QuotesUtility.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
                Pricing_RestAPI_QuotesUtility utilObj = new Pricing_RestAPI_QuotesUtility();
                //List<SBQQ__QuoteLine__c> qlList=Pricing_RestAPI_QuotesUtility.createQuoteRecord(quoteLineWrapper);
                List<SBQQ__QuoteLine__c> qlList1= Pricing_RestAPI_QuotesUtility.createQuoteLineRecords(quoteLineWrapper.quoteId,quoteLineList);
                boolean responce = utilObj.validateQuoteLineWrapper(quoteLineWrapper, qErrorMsg, false);
                boolean res = utilObj.validateQuoteLineWrapper(quoteLineWrapper, qErrorMsg, true);
                boolean responce1 = utilObj.validateQuoteLineWrapper(quoteLineWrapper1, qErrorMsg, false);
                
                Date pricingdate= Date.parse('11/1/2029');
                Pricing_RestAPI_QuotesUtility.QuoteLineErrorMsg quoteLineErrors = new Pricing_RestAPI_QuotesUtility.QuoteLineErrorMsg();
                utilObj.validateQuoteLine(quotelineObj, pricingdate, quoteLineErrors,true);       
            } catch(DMLException e){
                system.assertEquals(e.getMessage(), e.getMessage());        
            }
            //test.stopTest();
        }
    }
    static testmethod void validWIProducts(){
        //CH.Start
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
        Account acc = [Select Id from Account where Name = 'Test Account'];
        Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
        Product2 prod = [Select Id from Product2 where Name = 'Product X'];
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
        
        List<SBQQ__QuoteLine__c> quoteLine = new List<SBQQ__QuoteLine__c>(); 
        SBQQ__QuoteLine__c quoteLineob = new SBQQ__QuoteLine__c(); 
        quoteLineob.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
        quoteLineob.Pricing_Product_Nm__c = prod.Id;
        //quoteLineob.SBQQ__Product__c = prod.Id;
        quoteLineob.Pricing_Other_Product_Nm__c='';
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
        quoteLine.add(quoteLineob);
        test.startTest();
        insert quoteLine; 
        
        List<Pricing_Performance_Metric__c> mList=new List<Pricing_Performance_Metric__c>();
        Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
        metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Other_Nm__c='test';
        metrics.Pricing_Performance_Metric_Nm__c='Other';
        metrics.Pricing_Quote_Line__c=quoteLine[0].Id;
        metrics.Pricing_Weighting_Pct__c=10;
        mList.add(metrics);
        insert mList;			
        test.stopTest();
        //CH.End
        
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        Pricing_Competitor_Product__c compProduct1 = [Select Id from Pricing_Competitor_Product__c WHERE Name = 'Write In Product'];
        system.runAs(usr){
            //test.startTest();
            try{	
                //Pricing_Competitor_Product__c compProduct1 = [Select Id from Pricing_Competitor_Product__c WHERE Name = 'Write In Product'];
                Product2 product1 = [Select Id from Product2 WHERE Name = 'Write In Product'];
                
                List<Pricing_RestAPI_QuotesUtility.QuoteLine> quoteLineList = new List<Pricing_RestAPI_QuotesUtility.QuoteLine>();
                Pricing_RestAPI_QuotesUtility.QuoteLine quotelineObj = new Pricing_RestAPI_QuotesUtility.QuoteLine();
                quotelineObj.productId = product1.id;
                quotelineObj.quotelineReferenceID = 'QL-001';
                quotelineObj.quoteLinePricingEndDate = '1/25/2020';
                quotelineObj.writeInProduct = '';
                quotelineObj.systemModel = 'Test';
                quotelineObj.noOfSystems = 1;
                quotelineObj.noOfCPUsPerSystem = 5;
                quotelineObj.singleSystemPrice = 1000;
                quotelineObj.customerStdUnitPrice = 500;
                quotelineObj.requestedDiscountUnitPrice = 1000;
                quotelineObj.additionalDiscount = 1;
                quotelineObj.competitorName = 'Dell Dell';
                quotelineObj.competitorSystemModel = 'Test';
                quotelineObj.competitorProductId = compProduct1.id;
                quotelineObj.competitorWriteInProduct = '';
                quotelineObj.competitorNoOfSystems = 12;
                quotelineObj.competitorNoOfCPUsPerSystem = 1;
                quotelineObj.competitorSingleSystemPrice = 8;
                quotelineObj.competitorAdditionalDiscount = 2;
                quoteLineList.add(quotelineObj);
                
                SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
                Pricing_RestAPI_QuotesUtility.QuoteLineWrapper quoteLineWrapper = new  Pricing_RestAPI_QuotesUtility.QuoteLineWrapper();
                quoteLineWrapper.quoteId = quote.Id;
                quoteLineWrapper.quoteLines = quoteLineList;
                
                List<Pricing_RestAPI_QuotesUtility.QuoteLine> quoteLineList1 = new List<Pricing_RestAPI_QuotesUtility.QuoteLine>();
                Pricing_RestAPI_QuotesUtility.QuoteLineWrapper quoteLineWrapper1 = new  Pricing_RestAPI_QuotesUtility.QuoteLineWrapper();
                quoteLineWrapper1.quoteId = '';
                quoteLineWrapper1.quoteLines = quoteLineList1;
                
                Pricing_RestAPI_QuotesUtility.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
                Pricing_RestAPI_QuotesUtility utilObj = new Pricing_RestAPI_QuotesUtility();
                //List<SBQQ__QuoteLine__c> qlList=Pricing_RestAPI_QuotesUtility.createQuoteRecord(quoteLineWrapper);
                List<SBQQ__QuoteLine__c> qlList1= Pricing_RestAPI_QuotesUtility.createQuoteLineRecords(quoteLineWrapper.quoteId,quoteLineList);
                boolean responce = utilObj.validateQuoteLineWrapper(quoteLineWrapper, qErrorMsg, false);
                boolean res = utilObj.validateQuoteLineWrapper(quoteLineWrapper, qErrorMsg, true);
                boolean responce1 = utilObj.validateQuoteLineWrapper(quoteLineWrapper1, qErrorMsg, false);
                
                Date pricingdate= Date.parse('11/1/2029');
                Pricing_RestAPI_QuotesUtility.QuoteLineErrorMsg quoteLineErrors = new Pricing_RestAPI_QuotesUtility.QuoteLineErrorMsg();
                utilObj.validateQuoteLine(quotelineObj, pricingdate, quoteLineErrors,true);       
            } catch(DMLException e){
                system.assertEquals(e.getMessage(), e.getMessage());        
            }
            //test.stopTest();
        }
    }
    static testmethod void validPerformanceMetrics_Test(){  
        //CH.Start
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
        Account acc = [Select Id from Account where Name = 'Test Account'];
        Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
        Product2 prod = [Select Id from Product2 where Name = 'Product X'];
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
        
        List<SBQQ__QuoteLine__c> quoteLine = new List<SBQQ__QuoteLine__c>(); 
        SBQQ__QuoteLine__c quoteLineob = new SBQQ__QuoteLine__c(); 
        quoteLineob.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
        quoteLineob.Pricing_Product_Nm__c = prod.Id;
        //quoteLineob.SBQQ__Product__c = prod.Id;
        quoteLineob.Pricing_Other_Product_Nm__c='';
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
        quoteLine.add(quoteLineob);
        test.startTest();
        insert quoteLine; 
        
        List<Pricing_Performance_Metric__c> mList2=new List<Pricing_Performance_Metric__c>();
        Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
        metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Other_Nm__c='test';
        metrics.Pricing_Performance_Metric_Nm__c='Other';
        metrics.Pricing_Quote_Line__c=quoteLine[0].Id;
        metrics.Pricing_Weighting_Pct__c=10;
        mList2.add(metrics);
        insert mList2;			
        test.stopTest();
        //CH.End        
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        Pricing_Competitor_Product__c compProduct = [Select Id from Pricing_Competitor_Product__c limit 1];
        system.runAs(usr){
            //test.startTest();
            try{     
                List<SBQQ__QuoteLine__c> quoteLinelst = [Select Id,Pricing_Status_Nm__c from SBQQ__QuoteLine__c];
                List<Pricing_Performance_Metric__c> mList= [SELECT id FROM Pricing_Performance_Metric__c];        
                system.debug('quoteLine==>'+quoteLinelst);
                List<Pricing_RestAPI_QuotesUtility.PerformanceMetrics> pmList = new List<Pricing_RestAPI_QuotesUtility.PerformanceMetrics>();    
                Pricing_RestAPI_QuotesUtility.PerformanceMetrics performanceMetricsobj = new Pricing_RestAPI_QuotesUtility.PerformanceMetrics();
                performanceMetricsobj.compScore=1; 
                performanceMetricsobj.intelScore=1;
                performanceMetricsobj.otherText='ok';
                performanceMetricsobj.performanceMetricsUsed ='Other';
                performanceMetricsobj.weighting=10;
                performanceMetricsobj.performanceMetricsReferenceId = 'PM-001';
                pmList.add(performanceMetricsobj);
                
                Pricing_RestAPI_QuotesUtility.PerformanceMetricsWrapper pmWrapper=new Pricing_RestAPI_QuotesUtility.PerformanceMetricsWrapper();
                pmWrapper.quoteLineId = quoteLinelst[0].Id;
                pmWrapper.performanceMetrics = pmList;
                
                //Pricing_Competitor_Product__c compProduct = [Select Id from Pricing_Competitor_Product__c limit 1];
                Product2 product = [Select Id from Product2 limit 1];
                
                List<Pricing_RestAPI_QuotesUtility.QuoteLine> quoteLineList = new List<Pricing_RestAPI_QuotesUtility.QuoteLine>();
                Pricing_RestAPI_QuotesUtility.QuoteLine quotelineObj = new Pricing_RestAPI_QuotesUtility.QuoteLine();
                quotelineObj.productId = '12366';
                quotelineObj.quotelineReferenceID = 'QL-001';
                quotelineObj.quoteLinePricingEndDate = '12/25/202';
                quotelineObj.writeInProduct = 'Intel i5';
                quotelineObj.systemModel = 'Test';
                quotelineObj.noOfSystems = 10;
                quotelineObj.noOfCPUsPerSystem = 5;
                quotelineObj.singleSystemPrice = 1000;
                quotelineObj.customerStdUnitPrice = 500;
                quotelineObj.requestedDiscountUnitPrice = 200;
                quotelineObj.additionalDiscount = 0;
                quotelineObj.competitorName = 'Dell Dell';
                quotelineObj.competitorSystemModel = 'Test';
                quotelineObj.competitorProductId = '12476';
                quotelineObj.competitorWriteInProduct = 'test';
                quotelineObj.competitorNoOfSystems = 12;
                quotelineObj.competitorNoOfCPUsPerSystem = 1;
                quotelineObj.competitorSingleSystemPrice = 8;
                quotelineObj.competitorAdditionalDiscount = 2;
                quoteLineList.add(quotelineObj);
                
                SBQQ__Quote__c quotels = [Select Id from SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
                Pricing_RestAPI_QuotesUtility.QuoteLineWrapper quoteLineWrapper = new  Pricing_RestAPI_QuotesUtility.QuoteLineWrapper();
                quoteLineWrapper.quoteId = quotels.Id;
                quoteLineWrapper.quoteLines = quoteLineList;
                
                
                Pricing_RestAPI_QuotesUtility.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
                Pricing_RestAPI_QuotesUtility utilObj = new Pricing_RestAPI_QuotesUtility();
                Pricing_RestAPI_QuotesUtility.createPerformanceMetricsRecord(pmWrapper);
                Pricing_RestAPI_QuotesUtility.createPerformanceMetricsRecord(pmWrapper.quoteLineId ,pmList,mList);
                boolean isValidMetric = utilObj.validatePerformanceMetricsWrapper(pmWrapper, qErrorMsg);
                Date pricingdate= Date.parse('11/1/2029');
                Pricing_RestAPI_QuotesUtility.QuoteLineErrorMsg quoteLineErrors = new Pricing_RestAPI_QuotesUtility.QuoteLineErrorMsg();
                
                utilObj.validateQuoteLine(quotelineObj, pricingdate, quoteLineErrors,true);    
                system.assertEquals(utilObj.validateQuoteLine(quotelineObj, pricingdate, quoteLineErrors,true) != null, true); 
                system.debug('qErrorMsg===>'+qErrorMsg);
            }catch(Exception e){
                system.assertEquals(e.getMessage(), e.getMessage());        
            }
            //test.stopTest();
        }
    }    
    
    static testmethod void validPerformanceMetrics_Test1(){
        //CH.Start
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
        Account acc = [Select Id from Account where Name = 'Test Account'];
        Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
        Product2 prod = [Select Id from Product2 where Name = 'Product X'];
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
        quoteLineob.Pricing_Other_Product_Nm__c='';
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
        test.startTest();
        insert quoteLine2; 
        
        List<Pricing_Performance_Metric__c> mList2=new List<Pricing_Performance_Metric__c>();
        Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
        metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Other_Nm__c='test';
        metrics.Pricing_Performance_Metric_Nm__c='Other';
        metrics.Pricing_Quote_Line__c=quoteLine2[0].Id;
        metrics.Pricing_Weighting_Pct__c=10;
        mList2.add(metrics);
        insert mList2;			
        test.stopTest();
        //CH.End
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
            //test.startTest();
            List<SBQQ__QuoteLine__c> quoteLine = [Select Id,Pricing_Status_Nm__c from SBQQ__QuoteLine__c];
            List<Pricing_Performance_Metric__c> mList= [SELECT id FROM Pricing_Performance_Metric__c];
            Set<String> pmId = new Set<String>();    
            for(Pricing_Performance_Metric__c pm:mList){
                pmId.add(pm.Id);
            }
            system.debug('quoteLine==>'+quoteLine);
            List<Pricing_RestAPI_QuotesUtility.PerformanceMetrics> pmList = new List<Pricing_RestAPI_QuotesUtility.PerformanceMetrics>();    
            Pricing_RestAPI_QuotesUtility.PerformanceMetrics performanceMetricsobj = new Pricing_RestAPI_QuotesUtility.PerformanceMetrics();
            performanceMetricsobj.compScore=1; 
            performanceMetricsobj.intelScore=1;
            performanceMetricsobj.otherText='test';
            performanceMetricsobj.performanceMetricsUsed ='Other';
            performanceMetricsobj.weighting=1;
            performanceMetricsobj.performanceMetricsReferenceId = 'PM-REF-90';
            pmList.add(performanceMetricsobj);
            
            Pricing_RestAPI_QuotesUtility.PerformanceMetrics performanceMetricsobj1 = new Pricing_RestAPI_QuotesUtility.PerformanceMetrics();
            performanceMetricsobj1.compScore=-1; 
            performanceMetricsobj1.intelScore=-1;
            performanceMetricsobj1.otherText='';
            performanceMetricsobj1.performanceMetricsUsed ='test';
            performanceMetricsobj1.weighting=-1;
            performanceMetricsobj1.performanceMetricsReferenceId = '';
            pmList.add(performanceMetricsobj1);
            
            Pricing_RestAPI_QuotesUtility.PerformanceMetricsWrapper pmWrapper=new Pricing_RestAPI_QuotesUtility.PerformanceMetricsWrapper();
            pmWrapper.quoteLineId = quoteLine[0].Id;
            pmWrapper.performanceMetrics = pmList;
            
            Pricing_RestAPI_QuotesUtility.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtility.PerformanceMetricsErrorMsg pmerror = new Pricing_RestAPI_QuotesUtility.PerformanceMetricsErrorMsg();
            Pricing_RestAPI_QuotesUtility utilObj = new Pricing_RestAPI_QuotesUtility();
            Pricing_RestAPI_QuotesUtility.createPerformanceMetricsRecord(pmWrapper);
            Pricing_RestAPI_QuotesUtility.createPerformanceMetricsRecord(pmWrapper.quoteLineId ,pmList,mList);
            boolean isValid = utilObj.validatePerformanceMetrics(performanceMetricsobj,pmerror,pmId);
            boolean isVali1d = utilObj.validatePerformanceMetrics(performanceMetricsobj1,pmerror,pmId);
            Pricing_RestAPI_PerformanceMetrics.isPatch = true;
            Pricing_RestAPI_QuotesUtility.PerformanceMetrics performanceMetricsobj2 = new Pricing_RestAPI_QuotesUtility.PerformanceMetrics();
            performanceMetricsobj2.compScore=-1; 
            performanceMetricsobj2.intelScore=-1;
            performanceMetricsobj2.otherText='';
            performanceMetricsobj2.performanceMetricsUsed ='Other';
            performanceMetricsobj2.weighting=-1;
            performanceMetricsobj2.performanceMetricsReferenceId = '';
            performanceMetricsobj2.performanceMetricsId = 'sasa';
            boolean isValid2 = utilObj.validatePerformanceMetrics(performanceMetricsobj2,pmerror,pmId);
            performanceMetricsobj2.performanceMetricsId = '';
            boolean isValid3 = utilObj.validatePerformanceMetrics(performanceMetricsobj2,pmerror,pmId);
            system.debug('qErrorMsg===>'+qErrorMsg);
            system.assert(isValid);
            //test.stopTest();
        }
    }
    
    //@isTest(SeeAllData=true)
    static testmethod void validComments_Test(){  
        //CH.Start
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
        Account acc = [Select Id from Account where Name = 'Test Account'];
        Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
        Product2 prod = [Select Id from Product2 where Name = 'Product X'];
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
        quoteLineob.Pricing_Other_Product_Nm__c='';
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
        test.startTest();
        insert quoteLine2; 
        
        List<Pricing_Performance_Metric__c> mList2=new List<Pricing_Performance_Metric__c>();
        Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
        metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Other_Nm__c='test';
        metrics.Pricing_Performance_Metric_Nm__c='Other';
        metrics.Pricing_Quote_Line__c=quoteLine2[0].Id;
        metrics.Pricing_Weighting_Pct__c=10;
        mList2.add(metrics);
        insert mList2;			
        test.stopTest();
        //CH.End        
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
            //test.startTest();
            try{
                List<Pricing_RestAPI_QuotesUtility.QuoteComment> commentList=new List<Pricing_RestAPI_QuotesUtility.QuoteComment>();
                Pricing_RestAPI_QuotesUtility.QuoteComment comments1=new Pricing_RestAPI_QuotesUtility.QuoteComment();
                //comments1.question='Is Intel currently used by the end-customer? If not, who is the incumbent?';
                comments1.quoteCommentReferenceId = 'QC-001';
                comments1.answer='';
                commentList.add(comments1);
                
                Pricing_RestAPI_QuotesUtility.QuoteComment comments2=new Pricing_RestAPI_QuotesUtility.QuoteComment();
                //comments2.question='Deal description (i.e. end-customer background, explanation of project, future business opportunities, etc.)';
                comments2.quoteCommentReferenceId = 'QC-002';
                comments2.answer='tl';
                commentList.add(comments2);
                
                Pricing_RestAPI_QuotesUtility.QuoteComment comments3=new Pricing_RestAPI_QuotesUtility.QuoteComment();
                //comments3.question='How will the systems be used? What is the application & what benchmarks are being evaluated?';
                comments3.quoteCommentReferenceId = 'QC-003';
                comments3.answer='AsnwerTestTest1';
                commentList.add(comments3);
                
                Pricing_RestAPI_QuotesUtility.QuoteComment comments4=new Pricing_RestAPI_QuotesUtility.QuoteComment();
                //comments4.question='Competition Assumptions (i.e. Discount amount, rationale for pricing request, etc.)';
                comments4.quoteCommentReferenceId = 'QC-006';
                comments4.answer='AsnwerTestTest1ANSBHGDKJDCNKLkcjvkmklmvklmkvmkmscksmcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc';
                commentList.add(comments4);
                
                List<SBQQ__Quote__c> quotelst = [Select Id,SBQQ__Status__c from SBQQ__Quote__c];
                Pricing_RestAPI_QuotesUtility.QuoteCommentWrapper commentWrapper= new Pricing_RestAPI_QuotesUtility.QuoteCommentWrapper();
                commentWrapper.quoteId=quotelst[0].Id;
                commentWrapper.quoteComments=commentList;
                
                //wrong data
                List<Pricing_RestAPI_QuotesUtility.QuoteComment> commentList1=new List<Pricing_RestAPI_QuotesUtility.QuoteComment>();
                List<Pricing_RestAPI_QuotesUtility.QuoteComment> commentList2=new List<Pricing_RestAPI_QuotesUtility.QuoteComment>();
                Pricing_RestAPI_QuotesUtility.QuoteComment commentsw=new Pricing_RestAPI_QuotesUtility.QuoteComment();
                //comments1.question='Is Intel currently used by the end-customer? If not, who is the incumbent?';
                commentsw.quoteCommentReferenceId = 'QC-001';
                comments1.answer='test';
                commentList1.add(commentsw);
                
                Pricing_RestAPI_QuotesUtility.QuoteComment commentsw2=new Pricing_RestAPI_QuotesUtility.QuoteComment();
                //comments2.question='Deal description (i.e. end-customer background, explanation of project, future business opportunities, etc.)';
                commentsw2.quoteCommentReferenceId = 'QC-002';
                commentsw2.answer='AsnwerTestTest1';
                commentList1.add(commentsw2);
                
                Pricing_RestAPI_QuotesUtility.QuoteComment commentsw3=new Pricing_RestAPI_QuotesUtility.QuoteComment();
                //comments3.question='How will the systems be used? What is the application & what benchmarks are being evaluated?';
                commentsw3.quoteCommentReferenceId = 'QC-003';
                commentsw3.answer='AsnwerTestTest1';
                commentList1.add(commentsw3);
                
                Pricing_RestAPI_QuotesUtility.QuoteComment commentsw4=new Pricing_RestAPI_QuotesUtility.QuoteComment();
                //comments4.question='Competition Assumptions (i.e. Discount amount, rationale for pricing request, etc.)';
                commentsw4.quoteCommentReferenceId = 'QC-004';
                commentsw4.answer='AsnwerTestTest1';
                commentList1.add(commentsw4);
                
                Pricing_RestAPI_QuotesUtility.QuoteCommentWrapper commentWrapperw= new Pricing_RestAPI_QuotesUtility.QuoteCommentWrapper();
                commentWrapperw.quoteId=quotelst[0].Id;
                commentWrapperw.quoteComments=commentList1;
                
                Pricing_RestAPI_QuotesUtility.QuoteCommentWrapper commentWrappern= new Pricing_RestAPI_QuotesUtility.QuoteCommentWrapper();
                commentWrappern.quoteId='';
                commentWrappern.quoteComments=commentList2;
                
                
                Pricing_RestAPI_QuotesUtility.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
                Pricing_RestAPI_QuotesUtility utilObj = new Pricing_RestAPI_QuotesUtility();
                //Pricing_RestAPI_QuotesUtility.createCommentRecord(commentWrapper);
                Pricing_RestAPI_QuotesUtility.createQuoteComments(commentWrapper.quoteId,commentList);
                boolean isValidComment=	utilObj.validateQuoteCommentsWrapper(commentWrapper , qErrorMsg);
                //utilObj.validateQuoteStatus(commentWrapper,qErrorMsg);
                //system.assert(isValidComment);
                
            }catch(Exception e){
                system.assertEquals(e.getMessage(), e.getMessage());        
            }
            
            //test.stopTest();
        }
    }
    
    static testmethod void validSubmitQuote_Test(){ 
        //CH.Start
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
        Account acc = [Select Id from Account where Name = 'Test Account'];
        Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
        Product2 prod = [Select Id from Product2 where Name = 'Product X'];
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
        quoteLineob.Pricing_Other_Product_Nm__c='';
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
        test.startTest();
        insert quoteLine2; 
        
        List<Pricing_Performance_Metric__c> mList2=new List<Pricing_Performance_Metric__c>();
        Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
        metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Other_Nm__c='test';
        metrics.Pricing_Performance_Metric_Nm__c='Other';
        metrics.Pricing_Quote_Line__c=quoteLine2[0].Id;
        metrics.Pricing_Weighting_Pct__c=10;
        mList2.add(metrics);
        insert mList2;			
        test.stopTest();
        //CH.End        
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        Pricing_Competitor_Product__c compProduct = [Select Id from Pricing_Competitor_Product__c WHERE Name = 'Comp Product'];
        system.runAs(usr){
            //test.startTest();
            SBQQ__Quote__c quoteListDraft = [Select Id,SBQQ__Status__c from SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' LIMIT 1];
            //List<Pricing_RestAPI_QuotesUtility.QuoteDetails> quoteDetailsList = new List<Pricing_RestAPI_QuotesUtility.QuoteLine>();
            Pricing_RestAPI_QuotesUtility.QuoteDetails quoteWrapper= new Pricing_RestAPI_QuotesUtility.QuoteDetails();
            quoteWrapper.referenceRequestID='IQR-Dell-001';
            quoteWrapper.projectName='Test';
            quoteWrapper.pricingStartDate='11/4/3000';
            quoteWrapper.pricingEndDate='11/8/3000';
            quoteWrapper.intelSalesRepEmail='nehax.nagori@intel.com';//nehax.nagori@intel.com
            quoteWrapper.intelAccountExecutiveEmail='sonalx.pawar@intel.com';//
            quoteWrapper.endCustomerCountry='Hungary';//Hungary
            quoteWrapper.endCustomer='test';
            quoteWrapper.proposalDueDate='11/1/3000';
            quoteWrapper.intelResponseRequestedDate='11/13/3000';
            quoteWrapper.application='HPC';//HPC
            
            //Pricing_Competitor_Product__c compProduct = [Select Id from Pricing_Competitor_Product__c WHERE Name = 'Comp Product'];
            Product2 product = [Select Id from Product2 WHERE Name ='Product X'];
            
            
            List<Pricing_RestAPI_QuotesUtility.QuoteLine> quoteLineList = new List<Pricing_RestAPI_QuotesUtility.QuoteLine>();
            Pricing_RestAPI_QuotesUtility.QuoteLine quotelineObj = new Pricing_RestAPI_QuotesUtility.QuoteLine();
            String str = '12345678912454989';
            quotelineObj.productId = product.Id;
            quotelineObj.quoteLinePricingEndDate = '11/25/3000';
            quotelineObj.writeInProduct = '';
            quotelineObj.systemModel = 'Test';
            quotelineObj.noOfSystems = 1.2;
            quotelineObj.noOfCPUsPerSystem = -1;
            quotelineObj.singleSystemPrice = 1000;
            quotelineObj.customerStdUnitPrice = 500;
            quotelineObj.requestedDiscountUnitPrice = -1;
            quotelineObj.additionalDiscount = 0;
            quotelineObj.competitorName = 'Dell Dell';
            quotelineObj.competitorSystemModel = 'Test';
            quotelineObj.competitorProductId = compProduct.Id;
            quotelineObj.competitorWriteInProduct = '';
            quotelineObj.competitorNoOfSystems = null;
            quotelineObj.competitorNoOfCPUsPerSystem = Decimal.valueof(str);
            quotelineObj.competitorSingleSystemPrice = null;
            quotelineObj.competitorAdditionalDiscount = Decimal.valueof(str);
            quoteLineList.add(quotelineObj);
            
            List<Pricing_RestAPI_QuotesUtility.PerformanceMetrics> pmList = new List<Pricing_RestAPI_QuotesUtility.PerformanceMetrics>();    
            Pricing_RestAPI_QuotesUtility.PerformanceMetrics performanceMetricsobj = new Pricing_RestAPI_QuotesUtility.PerformanceMetrics();
            performanceMetricsobj.compScore=1;
            performanceMetricsobj.intelScore=1;
            performanceMetricsobj.otherText='test';
            performanceMetricsobj.performanceMetricsUsed ='';
            performanceMetricsobj.weighting=10;     
            performanceMetricsobj.performanceMetricsId=[Select Id from Pricing_Performance_Metric__c limit 1].Id;
            performanceMetricsobj.performanceMetricsReferenceId='';
            pmList.add(performanceMetricsobj);
            
            List<Pricing_RestAPI_QuotesUtility.QuoteComment> commentList=new List<Pricing_RestAPI_QuotesUtility.QuoteComment>();
            Pricing_RestAPI_QuotesUtility.QuoteComment comments1=new Pricing_RestAPI_QuotesUtility.QuoteComment();
            comments1.quoteCommentReferenceId = 'QC-001';
            comments1.answer='testsadasdsadasd';
            commentList.add(comments1);
            
            Pricing_RestAPI_QuotesUtility.QuoteComment comments2=new Pricing_RestAPI_QuotesUtility.QuoteComment();
            comments2.quoteCommentReferenceId = 'QC-002';
            comments2.answer='AsnwerTestTest1';
            commentList.add(comments2);
            Pricing_RestAPI_QuotesUtility.QuoteComment comments3=new Pricing_RestAPI_QuotesUtility.QuoteComment();
            comments3.quoteCommentReferenceId = 'QC-003';
            comments3.answer='AsnwerTestTest1';
            commentList.add(comments3);
            Pricing_RestAPI_QuotesUtility.QuoteComment comments4=new Pricing_RestAPI_QuotesUtility.QuoteComment();
            comments4.quoteCommentReferenceId = 'QC-004';
            comments4.answer='testsdasdasdasdasd';
            commentList.add(comments4);
            
            quoteLineList[0].performanceMetrics = pmList;
            quoteWrapper.quoteLines = quoteLineList;
            quoteWrapper.quoteComments = commentList;
            
            Pricing_RestAPI_QuotesUtility.QuoteWrapper quote = new Pricing_RestAPI_QuotesUtility.QuoteWrapper();
            quote.quoteDetails = quoteWrapper;
            
            Pricing_RestAPI_QuotesUtility.QuoteCommentWrapper commentWrapper = new Pricing_RestAPI_QuotesUtility.QuoteCommentWrapper();
            commentWrapper.quoteId= quoteListDraft.Id;
            commentWrapper.quoteComments= commentList;
            
            Pricing_RestAPI_QuotesUtility.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtility quoteUtility = new Pricing_RestAPI_QuotesUtility();
            boolean isValid = quoteUtility.validateQuote(quote, quoteErrors, true);
            boolean isValidQuote = quoteUtility.validateQuoteStatus (commentWrapper, quoteErrors);
            system.assert(isValid!=null);
            //test.stopTest();
        }
    }
    
    static testmethod void validWonLostQuoteline(){ 
        //CH.Start
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
        Account acc = [Select Id from Account where Name = 'Test Account'];
        Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
        Product2 prod = [Select Id from Product2 where Name = 'Product X'];
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
        quoteLineob.Pricing_Other_Product_Nm__c='';
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
        test.startTest();
        insert quoteLine2; 
        
        List<Pricing_Performance_Metric__c> mList2=new List<Pricing_Performance_Metric__c>();
        Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
        metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Other_Nm__c='test';
        metrics.Pricing_Performance_Metric_Nm__c='Other';
        metrics.Pricing_Quote_Line__c=quoteLine2[0].Id;
        metrics.Pricing_Weighting_Pct__c=10;
        mList2.add(metrics);
        insert mList2;			
        test.stopTest();
        //CH.End        
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
            //test.startTest();
            Map<String,Schema.SObjectField> sObjQuoteLineFieldMap;
            sObjQuoteLineFieldMap = Schema.sObjectType.SBQQ__QuoteLine__c.fields.getMap();
            List<Pricing_RestAPI_QuotesUtility.QuoteLine> quoteLineList = new List<Pricing_RestAPI_QuotesUtility.QuoteLine>();
            Pricing_RestAPI_QuotesUtility.QuoteLine quotelineObj = new Pricing_RestAPI_QuotesUtility.QuoteLine();
            quotelineObj.quotelineReferenceID = 'ql-001';
            quotelineObj.quotelineId = 'ql-001';
            quotelineObj.status = 'ql-001';
            quotelineObj.wonLostComments = 'ql-001';
            quoteLineList.add(quotelineObj);  
            Pricing_RestAPI_QuotesUtility.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtility.QuoteLineWrapper quotelineWrapper = new Pricing_RestAPI_QuotesUtility.QuoteLineWrapper();
            quotelineWrapper.quoteLines = quoteLineList;
            Pricing_RestAPI_QuotesUtility.validateWonLostQuotelineWrapper(quotelineWrapper, qErrorMsg, sObjQuoteLineFieldMap);
            system.assert(Pricing_RestAPI_QuotesUtility.validateWonLostQuotelineWrapper(quotelineWrapper, qErrorMsg, sObjQuoteLineFieldMap) != null);
            //test.stopTest();
        }
    }
    
    static testmethod void validSubmitQuote_Test1(){ 
        //CH.Start
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
        Account acc = [Select Id from Account where Name = 'Test Account'];
        Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
        Product2 prod = [Select Id from Product2 where Name = 'Product X'];
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
        quoteLineob.Pricing_Other_Product_Nm__c='';
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
        test.startTest();
        insert quoteLine2; 
        
        List<Pricing_Performance_Metric__c> mList2=new List<Pricing_Performance_Metric__c>();
        Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
        metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Other_Nm__c='test';
        metrics.Pricing_Performance_Metric_Nm__c='Other';
        metrics.Pricing_Quote_Line__c=quoteLine2[0].Id;
        metrics.Pricing_Weighting_Pct__c=10;
        mList2.add(metrics);
        insert mList2;			
        test.stopTest();
        //CH.End        
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
            //test.startTest();
            SBQQ__Quote__c quoteListDraft = [Select Id,SBQQ__Status__c from SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' LIMIT 1];
            Pricing_RestAPI_QuotesUtility.QuoteDetails quoteWrapper= new Pricing_RestAPI_QuotesUtility.QuoteDetails();
            quoteWrapper.referenceRequestID='IQR-Dell-001';
            quoteWrapper.projectName='Test';
            quoteWrapper.pricingStartDate='11/4/3000';
            quoteWrapper.pricingEndDate='11/8/3000';
            quoteWrapper.intelSalesRepEmail='jasmine.narula@intel.com';
            quoteWrapper.intelAccountExecutiveEmail='sonal.pawar@intel.com';//
            quoteWrapper.endCustomerCountry='test';//Hungary
            quoteWrapper.endCustomer='test';
            quoteWrapper.proposalDueDate='11/1/3000';
            quoteWrapper.intelResponseRequestedDate='11/1/3000';
            quoteWrapper.application='test';//HPC
            
            Pricing_RestAPI_QuotesUtility.QuoteWrapper quote = new Pricing_RestAPI_QuotesUtility.QuoteWrapper();
            quote.quoteDetails = quoteWrapper;
            
            Pricing_RestAPI_QuotesUtility.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtility quoteUtility = new Pricing_RestAPI_QuotesUtility();
            boolean isValid = quoteUtility.validateQuote(quote, quoteErrors, true);
            system.assert(isValid!=null);
            //test.stopTest();
        }
    }
    
    static testmethod void validQuoteTeam_Test(){
        //CH.Start
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
        Account acc = [Select Id from Account where Name = 'Test Account'];
        Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
        Product2 prod = [Select Id from Product2 where Name = 'Product X'];
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
        quoteLineob.Pricing_Other_Product_Nm__c='';
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
        test.startTest();
        insert quoteLine2; 
        
        List<Pricing_Performance_Metric__c> mList2=new List<Pricing_Performance_Metric__c>();
        Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
        metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Other_Nm__c='test';
        metrics.Pricing_Performance_Metric_Nm__c='Other';
        metrics.Pricing_Quote_Line__c=quoteLine2[0].Id;
        metrics.Pricing_Weighting_Pct__c=10;
        mList2.add(metrics);
        insert mList2;			
        test.stopTest();
        //CH.End        
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
            //test.startTest();
            Pricing_RestAPI_QuotesUtility.QuoteDetails quoteWrapper= new Pricing_RestAPI_QuotesUtility.QuoteDetails();
            quoteWrapper.intelSalesRepEmail='jasmine.narula@intel.com';
            quoteWrapper.intelAccountExecutiveEmail='sonalx.pawar@intel.com';
            quoteWrapper.industryTechnicalSpecialistEmail='firstname0@intel.com';
            
            Pricing_RestAPI_QuotesUtility.QuoteWrapper qw = new Pricing_RestAPI_QuotesUtility.QuoteWrapper();
            qw.QuoteDetails = quoteWrapper;
            
            qw.quoteId = [Select Id,SBQQ__Status__c from SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' LIMIT 1].Id;
            
            Pricing_RestAPI_QuotesUtility quoteUtility = new Pricing_RestAPI_QuotesUtility();
            Pricing_RestAPI_QuotesUtility.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
            Pricing_RestAPI_Quotes.isCreateQuoteTeam = true;
            boolean responce = quoteUtility.validateQuote(qw, quoteErrors, false);
            List<Pricing_Quote_Team__c> QTM = Pricing_RestAPI_QuotesUtility.createFSEQuoteTeam(qw.quoteId);
            QTM = Pricing_RestAPI_QuotesUtility.createAEQuoteTeam(qw.quoteId);
            QTM = Pricing_RestAPI_QuotesUtility.createITSQuoteTeam(qw.quoteId);
            system.assert(responce!=null);
            //test.stoptest();
        }        
    }
    
    static testmethod void validQuoteTeam_fail_Test(){
        //CH.Start
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
        Account acc = [Select Id from Account where Name = 'Test Account'];
        Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
        Product2 prod = [Select Id from Product2 where Name = 'Product X'];
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
        quoteLineob.Pricing_Other_Product_Nm__c='';
        quoteLineob.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
        quoteLineob.Pricing_Systems_qty__c = 6; 
        quoteLineob.Pricing_pm_approval_comments_nm__c = 'Test Comment';
        quoteLineob.Pricing_CPUs_per_system_qty__c = 1;
        quoteLineob.Pricing_Single_System_Price_Amt__c = 4;
        quoteLineob.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
        quoteLineob.Pricing_Req_Discounted_Unit_Price__c = 1;
        quoteLineob.Pricing_Additional_OEM_Discount_Amt__c = 1;
        quoteLineob.Pricing_Competetor_Product__c=cp.Id;
        quoteLineob.Pricing_Other_Competitor_Product_Nm__c = 'tset';  
        quoteLineob.SBQQ__Quote__c = quote2.Id;
        quoteLineob.Pricing_Status_Nm__c='Draft';
        quoteLine2.add(quoteLineob);
        test.startTest();
        insert quoteLine2; 
        
        List<Pricing_Performance_Metric__c> mList2=new List<Pricing_Performance_Metric__c>();
        Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
        metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Other_Nm__c='test';
        metrics.Pricing_Performance_Metric_Nm__c='Other';
        metrics.Pricing_Quote_Line__c=quoteLine2[0].Id;
        metrics.Pricing_Weighting_Pct__c=10;
        mList2.add(metrics);
        insert mList2;			
        test.stopTest();
        //CH.End        
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
            //test.startTest();
            Pricing_RestAPI_QuotesUtility.QuoteDetails quoteWrapper= new Pricing_RestAPI_QuotesUtility.QuoteDetails();
            quoteWrapper.intelSalesRepEmail='jasminex.narula@intel.com';
            quoteWrapper.intelAccountExecutiveEmail='firstname0@intel.com';
            quoteWrapper.industryTechnicalSpecialistEmail='firstname0@intel.com'; 
            
            Pricing_RestAPI_QuotesUtility.QuoteDetails quoteWrapper1 = new Pricing_RestAPI_QuotesUtility.QuoteDetails();
            quoteWrapper1.intelSalesRepEmail='';
            quoteWrapper1.intelAccountExecutiveEmail='';
            quoteWrapper1.industryTechnicalSpecialistEmail='';
            
            Pricing_RestAPI_QuotesUtility.QuoteWrapper qw = new Pricing_RestAPI_QuotesUtility.QuoteWrapper();
            qw.QuoteDetails = quoteWrapper;
            
            Pricing_RestAPI_QuotesUtility.QuoteWrapper qw1 = new Pricing_RestAPI_QuotesUtility.QuoteWrapper();
            qw1.QuoteDetails = quoteWrapper1;
            
            qw.quoteId = [Select Id,SBQQ__Status__c from SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' LIMIT 1].Id;
            
            Pricing_RestAPI_QuotesUtility quoteUtility = new Pricing_RestAPI_QuotesUtility();
            Pricing_RestAPI_QuotesUtility.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
            Pricing_RestAPI_Quotes.isCreateQuoteTeam = true;
            boolean responce = quoteUtility.validateQuote(qw, quoteErrors, false);
            boolean responce1 = quoteUtility.validateQuote(qw1, quoteErrors, false);
            system.assert(responce!=null);
            //test.stoptest();
        }        
    }
    
    //This method creates an User
    public static List<User> createUser(){
        Set<String> profileNameSet = new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};            
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderUser];
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderPartner];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            Integer i = 0;
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'newUser', Email= 'firstname'+i+'@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,
                                   TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstName@Intel.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);
                i++;
            }
            insert lstUser;
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>(); 
            for(user userId : lstUser){
                if(userId.Profile.Name == Label.Pricing_Tender_Profiles_SalesRepBB){
                    permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
                    permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));
                }
                if(userId.Profile.Name == Label.Pricing_Tender_Profiles_Partner){
                    permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
                    permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps2.Id));
                }          
            }
            if(!permissionList.isEmpty()){
                insert permissionList;
            }
        }  
        return lstUser;
    }
    
    static testmethod void validChangeRequest_Test1(){
        //CH.Start
        
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
        Account acc = [Select Id from Account where Name = 'Test Account'];
        Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
        Product2 prod = [Select Id from Product2 where Name = 'Product X'];
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
        quoteLineob.Pricing_Other_Product_Nm__c='';
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
        test.startTest();
        insert quoteLine2;  
        
        /*
List<Pricing_Performance_Metric__c> mList2=new List<Pricing_Performance_Metric__c>();
Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
metrics.Pricing_Other_Nm__c='test';
metrics.Pricing_Performance_Metric_Nm__c='Other';
metrics.Pricing_Quote_Line__c=quoteLine2[0].Id;
metrics.Pricing_Weighting_Pct__c=10;
mList2.add(metrics);
insert mList2;			
*/
        
        //CH.End        
        //test.startTest();
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        List<User> lstUsers2 = [SELECT id FROM User WHERE email='firstName@intel.com' Limit 1];
        //CH.Start
        system.runAs(lstUsers2[0]){
            List<SBQQ__QuoteLine__c> quoteLineUpdate = new List<SBQQ__QuoteLine__c>();
            quoteLine2[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            quoteLine2[0].Pricing_ECAP_Price_Amt__c = 1200;
            quoteLine2[0].Pricing_Approved_Unit_Qty__c = 10;
            quoteLine2[0].Pricing_Approved_End_Date_Dt__c = system.today()+1;
            quoteLineUpdate.add(quoteLine2[0]);
            
            update quoteLineUpdate;  
            test.stopTest();
        }
        //CH.END        
        
        system.runAs(usr){
            //  test.startTest();
            Map<String,Schema.SObjectField> sObjQuoteLineFieldMap;
            sObjQuoteLineFieldMap = Schema.sObjectType.SBQQ__QuoteLine__c.fields.getMap();
            //Id quoteID = [select id from SBQQ__Quote__c Limit 1].id;
            List<SBQQ__QuoteLine__c> quoteLine = [Select Id,SBQQ__Quote__c,Pricing_Status_Nm__c,SBQQ__Quote__r.SBQQ__Account__c from SBQQ__QuoteLine__c where Pricing_Status_Nm__c='Approved' limit 1];
            // system.debug(quoteLine);
            List<Pricing_RestAPI_QuotesUtility.QuoteLine> quoteLineList = new List<Pricing_RestAPI_QuotesUtility.QuoteLine>();
            Pricing_RestAPI_QuotesUtility.QuoteLine quotelineObj = new Pricing_RestAPI_QuotesUtility.QuoteLine();
            quotelineObj.quotelineId=quoteLine[0].id;
            quotelineObj.quotelineReferenceID='001';
            quotelineObj.quoteLinePricingEndDate='6/8/2021';
            quotelineObj.newQuantity= -20;
            quotelineObj.newRequestedDiscountUnitPrice= -1300;
            quotelineObj.additionalComment= '1123456789';
            quoteLineList.add(quotelineObj);
            Pricing_RestAPI_QuotesUtility.QuoteLineWrapper quoteLineWrapper = new  Pricing_RestAPI_QuotesUtility.QuoteLineWrapper();
            quoteLineWrapper.quoteId= quoteLine[0].SBQQ__Quote__c;
            quoteLineWrapper.quoteLines = quoteLineList;
            /*List<SBQQ__QuoteLine__c> hasCR = [SELECT Id, Pricing_Quote_Line_Number__c,Pricing_Reference_Quote_Line_Nbr__c FROM SBQQ__QuoteLine__c
where Pricing_Reference_Quote_Line_Nbr__c = : quoteLine[0].id and Pricing_Status_Nm__c != 'Rejected' and SBQQ__Quote__r.SBQQ__Account__c = :UserInfo.getUserId()];
Set<Id> hasCRSet = new Set<Id>();
for(SBQQ__QuoteLine__c qli: hasCR){
hasCRSet.add(qli.Pricing_Reference_Quote_Line_Nbr__c);
} 
Map<Id,SBQQ__QuoteLine__c> quotelineMap = new Map<Id,SBQQ__QuoteLine__c>([Select Id,Pricing_Status_Nm__c,Pricing_Quote_Line_Number__c,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__Account__c,SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Approved_Unit_Qty__c,Pricing_ECAP_Price_Amt__c from SBQQ__QuoteLine__c where Id = :quoteLine[0].id and SBQQ__Quote__r.SBQQ__Account__c = :UserInfo.getUserId()]);*/
            Pricing_RestAPI_QuotesUtility.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtility.currentUserAccountId=quoteLine[0].SBQQ__Quote__r.SBQQ__Account__c;//Pricing_Test_Utility.createAccount();
            Pricing_RestAPI_Quotelines.isChangeReq = true;
            Pricing_RestAPI_ChangeRequestQuoteLine.version = 'v1.0';
            Pricing_RestAPI_QuotesUtility utilObj = new Pricing_RestAPI_QuotesUtility();
            utilObj.validateQuoteLineWrapper(quoteLineWrapper, qErrorMsg, false);
            //test.stopTest();
        }
    }
    
    static testmethod void validChangeRequest_Test2(){
        //CH.Start
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
        Account acc = [Select Id from Account where Name = 'Test Account'];
        Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
        Product2 prod = [Select Id from Product2 where Name = 'Product X'];
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
        quoteLineob.Pricing_Other_Product_Nm__c='';
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
        test.startTest();
        insert quoteLine2; 
        
        /*  List<Pricing_Performance_Metric__c> mList2=new List<Pricing_Performance_Metric__c>();
Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
metrics.Pricing_Other_Nm__c='test';
metrics.Pricing_Performance_Metric_Nm__c='Other';
metrics.Pricing_Quote_Line__c=quoteLine2[0].Id;
metrics.Pricing_Weighting_Pct__c=10;
mList2.add(metrics);
insert mList2;		*/	
        
        //CH.End
        //test.startTest();        
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        List<User> lstUsers2 = [SELECT id FROM User WHERE email='firstName@intel.com' Limit 1];
        //CH.Start
        system.runAs(lstUsers2[0]){
            List<SBQQ__QuoteLine__c> quoteLineUpdate = new List<SBQQ__QuoteLine__c>();
            quoteLine2[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            quoteLine2[0].Pricing_ECAP_Price_Amt__c = 1200;
            quoteLine2[0].Pricing_Approved_Unit_Qty__c = 10;
            quoteLine2[0].Pricing_Approved_End_Date_Dt__c = system.today()+1;
            quoteLineUpdate.add(quoteLine2[0]);
            
            update quoteLineUpdate;  
            test.stopTest();
        }
        //CH.END
        system.runAs(usr){
            //   test.startTest();
            Map<String,Schema.SObjectField> sObjQuoteLineFieldMap;
            sObjQuoteLineFieldMap = Schema.sObjectType.SBQQ__QuoteLine__c.fields.getMap();
            List<SBQQ__QuoteLine__c> quoteLine = [Select Id,SBQQ__Quote__c,Pricing_Status_Nm__c,SBQQ__Quote__r.SBQQ__Account__c from SBQQ__QuoteLine__c where Pricing_Status_Nm__c='Approved' limit 1];
            //  system.debug(quoteLine);
            List<Pricing_RestAPI_QuotesUtility.QuoteLine> quoteLineList = new List<Pricing_RestAPI_QuotesUtility.QuoteLine>();
            Pricing_RestAPI_QuotesUtility.QuoteLine quotelineObj = new Pricing_RestAPI_QuotesUtility.QuoteLine();
            quotelineObj.quotelineId=quoteLine[0].id;
            quotelineObj.quotelineReferenceID='001';
            quotelineObj.quoteLinePricingEndDate=String.valueOf(system.today()+3);
            quotelineObj.newQuantity= 10;
            quotelineObj.newRequestedDiscountUnitPrice= 1200;
            quotelineObj.additionalComment= '1123456789';
            quoteLineList.add(quotelineObj);
            Pricing_RestAPI_QuotesUtility.QuoteLineWrapper quoteLineWrapper = new  Pricing_RestAPI_QuotesUtility.QuoteLineWrapper();
            quoteLineWrapper.quoteId=quoteLine[0].SBQQ__Quote__c;
            quoteLineWrapper.quoteLines = quoteLineList;
            
            Pricing_RestAPI_QuotesUtility.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtility.currentUserAccountId=quoteLine[0].SBQQ__Quote__r.SBQQ__Account__c;//Pricing_Test_Utility.createAccount();
            Pricing_RestAPI_Quotelines.isChangeReq = true;
            Pricing_RestAPI_ChangeRequestQuoteLine.version = 'v2.0';
            Pricing_RestAPI_QuotesUtility utilObj = new Pricing_RestAPI_QuotesUtility();
            utilObj.validateQuoteLineWrapper(quoteLineWrapper, qErrorMsg, false);
            //test.stopTest();
        }
    }
    
    static testmethod void validUpdateQuoteLine_Test(){
        //CH.Start
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
        Account acc = [Select Id from Account where Name = 'Test Account'];
        Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
        Product2 prod = [Select Id from Product2 where Name = 'Product X'];
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
        quoteLineob.Pricing_Other_Product_Nm__c='';
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
        test.startTest();
        insert quoteLine2; 
        /*
List<Pricing_Performance_Metric__c> mList2=new List<Pricing_Performance_Metric__c>();
Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
metrics.Pricing_Other_Nm__c='test';
metrics.Pricing_Performance_Metric_Nm__c='Other';
metrics.Pricing_Quote_Line__c=quoteLine2[0].Id;
metrics.Pricing_Weighting_Pct__c=10;
mList2.add(metrics);
insert mList2;		*/
        
        //test.startTest();
        List<User> lstUsers2 = [SELECT id FROM User WHERE email='firstName@intel.com' Limit 1];
        //CH.Start
        system.runAs(lstUsers2[0]){
            List<SBQQ__QuoteLine__c> quoteLineUpdate = new List<SBQQ__QuoteLine__c>();
            quoteLine2[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            quoteLine2[0].Pricing_ECAP_Price_Amt__c = 1200;
            quoteLine2[0].Pricing_Approved_Unit_Qty__c = 10;
            quoteLine2[0].Pricing_Approved_End_Date_Dt__c = system.today()+1;
            quoteLineUpdate.add(quoteLine2[0]);
            
            update quoteLineUpdate;  
            test.stopTest();
        }
        //CH.END
        
        //CH.End        
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        Pricing_Competitor_Product__c compProduct = [Select Id from Pricing_Competitor_Product__c limit 1];
        system.runAs(usr){
            //  test.startTest();
            //Pricing_Competitor_Product__c compProduct = [Select Id from Pricing_Competitor_Product__c limit 1];
            Product2 product = [Select Id from Product2 limit 1];
            SBQQ__Quote__c quotels = [Select Id from SBQQ__Quote__c WHERE SBQQ__Status__c!='Draft' LIMIT 1];
            SBQQ__QuoteLine__c qlils = [Select Id from SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quotels.id LIMIT 1];
            
            List<Pricing_RestAPI_QuotesUtility.QuoteLine> quoteLineList = new List<Pricing_RestAPI_QuotesUtility.QuoteLine>();
            Pricing_RestAPI_QuotesUtility.QuoteLine quotelineObj = new Pricing_RestAPI_QuotesUtility.QuoteLine();
            quotelineObj.quotelineId = qlils.id;
            quotelineObj.productId = product.Id;
            quotelineObj.quotelineReferenceID = 'QL-001';
            quotelineObj.quoteLinePricingEndDate = '12/25/2020';
            quotelineObj.writeInProduct = 'Intel i5';
            quotelineObj.systemModel = 'Test';
            quotelineObj.noOfSystems = 10;
            quotelineObj.noOfCPUsPerSystem = 5;
            quotelineObj.singleSystemPrice = 1000;
            quotelineObj.customerStdUnitPrice = 500;
            quotelineObj.requestedDiscountUnitPrice = 200;
            quotelineObj.additionalDiscount = 0;
            quotelineObj.competitorName = 'Dell Dell';
            quotelineObj.competitorSystemModel = 'Test';
            quotelineObj.competitorProductId = compProduct.Id;
            quotelineObj.competitorWriteInProduct = 'test';
            quotelineObj.competitorNoOfSystems = 12;
            quotelineObj.competitorNoOfCPUsPerSystem = 1;
            quotelineObj.competitorSingleSystemPrice = 8;
            quotelineObj.competitorAdditionalDiscount = 2;
            quoteLineList.add(quotelineObj);
            
            
            Pricing_RestAPI_QuotesUtility.QuoteLineWrapper quoteLineWrapper = new  Pricing_RestAPI_QuotesUtility.QuoteLineWrapper();
            quoteLineWrapper.quoteId = quotels.Id;
            
            quoteLineWrapper.quoteLines = quoteLineList;
            
            // List<Pricing_RestAPI_QuotesUtility.QuoteLine> quoteLineList1 = new List<Pricing_RestAPI_QuotesUtility.QuoteLine>();
            // quoteLineList1.add(null);
            //  Pricing_RestAPI_QuotesUtility.QuoteLineWrapper quoteLineWrapper1 = new  Pricing_RestAPI_QuotesUtility.QuoteLineWrapper();
            //  quoteLineWrapper1.quoteId = null;
            // quoteLineWrapper1.quoteLines = quoteLineList1;
            Pricing_RestAPI_Quotelines.isUpdateDraftQuoteLine=true;
            Pricing_RestAPI_QuotesUtility.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtility utilObj = new Pricing_RestAPI_QuotesUtility();
            //List<SBQQ__QuoteLine__c> qlList=Pricing_RestAPI_QuotesUtility.createQuoteRecord(quoteLineWrapper);
            List<SBQQ__QuoteLine__c> qlList1= Pricing_RestAPI_QuotesUtility.createQuoteLineRecords(quoteLineWrapper.quoteId,quoteLineList);
            boolean responce = utilObj.validateQuoteLineWrapper(quoteLineWrapper, qErrorMsg, false);
            boolean res = utilObj.validateQuoteLineWrapper(quoteLineWrapper, qErrorMsg, true);
            // boolean responce1 = utilObj.validateQuoteLineWrapper(quoteLineWrapper1, qErrorMsg, false);
            // boolean responce2 = utilObj.validateQuoteLineWrapper(quoteLineWrapper1, qErrorMsg, true);
            
            Date pricingdate= Date.parse('11/1/2029');
            Pricing_RestAPI_QuotesUtility.QuoteLineErrorMsg quoteLineErrors = new Pricing_RestAPI_QuotesUtility.QuoteLineErrorMsg();
            utilObj.validateQuoteLine(quotelineObj, pricingdate, quoteLineErrors,true);       
            system.assert(responce!=null);
            //test.stopTest();
        }
    }
    
    static testmethod void validSVDQuota(){
        //CH.Start
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
        Account acc = [Select Id from Account where Name = 'Test Account'];
        Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
        Product2 prod = [Select Id from Product2 where Name = 'Product X'];
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
        quoteLineob.Pricing_Other_Product_Nm__c='';
        quoteLineob.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
        quoteLineob.Pricing_Systems_qty__c = 6; 
        quoteLineob.Pricing_pm_approval_comments_nm__c = 'Test Comment';
        quoteLineob.Pricing_CPUs_per_system_qty__c = 1;
        quoteLineob.Pricing_Single_System_Price_Amt__c = 4;
        quoteLineob.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
        quoteLineob.Pricing_Req_Discounted_Unit_Price__c = 1;
        quoteLineob.Pricing_Additional_OEM_Discount_Amt__c = 1;
        quoteLineob.Pricing_Competetor_Product__c=cp.Id;
        quoteLineob.Pricing_Other_Competitor_Product_Nm__c = 'tst';  
        quoteLineob.SBQQ__Quote__c = quote2.Id;
        quoteLineob.Pricing_Status_Nm__c='Draft';
        quoteLine2.add(quoteLineob);
        test.startTest();
        insert quoteLine2; 
        
        List<Pricing_Performance_Metric__c> mList2=new List<Pricing_Performance_Metric__c>();
        Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
        metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Other_Nm__c='test';
        metrics.Pricing_Performance_Metric_Nm__c='Other';
        metrics.Pricing_Quote_Line__c=quoteLine2[0].Id;
        metrics.Pricing_Weighting_Pct__c=10;
        mList2.add(metrics);
        insert mList2;	
        
        
        //CH.End        
        //test.startTest();
        Pricing_RestAPI_QuotesUtility.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
        Pricing_RestAPI_QuotesUtility utilObj = new Pricing_RestAPI_QuotesUtility();
        utilObj.validateSVDQuota(qErrorMsg);
        test.stopTest();
        
    }
    static testmethod void validgetAllQuotes(){
        //CH.Start
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
        Account acc = [Select Id from Account where Name = 'Test Account'];
        Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
        Product2 prod = [Select Id from Product2 where Name = 'Product X'];
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
        quoteLineob.Pricing_Other_Product_Nm__c='';
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
        test.startTest();
        insert quoteLine2; 
        
        List<Pricing_Performance_Metric__c> mList2=new List<Pricing_Performance_Metric__c>();
        Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
        metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
        metrics.Pricing_Other_Nm__c='test';
        metrics.Pricing_Performance_Metric_Nm__c='Other';
        metrics.Pricing_Quote_Line__c=quoteLine2[0].Id;
        metrics.Pricing_Weighting_Pct__c=10;
        mList2.add(metrics);
        insert mList2;			
        //test.stopTest();
        //CH.End        
        
        //test.startTest();
        String dt = '2021/03/04';
        String op = 'operator';
        //Pricing_RestAPI_QuotesUtility.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
        //Pricing_RestAPI_QuotesUtility.ErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtility.ErrorMsg();
        Pricing_RestAPI_QuotesUtility utilObj = new Pricing_RestAPI_QuotesUtility();
        Map<String,Pricing_RestAPI_QuotesUtility.ErrorMsg> quoteMsgs = new Map<String,Pricing_RestAPI_QuotesUtility.ErrorMsg>();
        // utilObj.validateGetAllQuoteDate(dt,op,quoteMsgs);
        test.stopTest();
        
    }
    
    public class ErrorMsg {
        public Integer errorCode {set;get;} 
        public String errorMsg  {set;get;} 
        public ErrorMsg(Integer code, String Msg){
            errorCode = code;
            errorMsg = Msg;
        }     
    }
}