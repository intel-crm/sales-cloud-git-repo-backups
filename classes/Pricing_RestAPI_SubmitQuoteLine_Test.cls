@isTest
public class Pricing_RestAPI_SubmitQuoteLine_Test {
    @testSetup
    static void dataSetup(){
        
        Pricing_RestAPI_TestUtility.createRestAPIErrorCodesConfig();
        List<Product2> prodList = new List<Product2>();
        Product2 prod = new Product2();
        prod.Core_Product_Org__c = 'Sales';
        prod.Core_Product_Type__c = 'Processors';
        prod.Core_Sales_Visible_Flag__c  = True;
        prod.IsActive = True;
        prod.Core_Group_Code_Short_Name__c = 'DCG~DCAI';
        prod.Core_Hierarchy_ID__c = '43';
        prod.Name = 'Product X';
        prod.Core_Processor_Number_Nm__c = 'test';
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
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
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
            
            
            List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c =  acc.Id;
            quote.SBQQ__PrimaryContact__c = con.Id;
            quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote.Pricing_Project_Name_Nm__c = 'Test Project';
            quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote.Pricing_Customer_Nm__c = 'FMH';
            quote.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote.Pricing_Intel_Response_Requested_By_Date__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote.Pricing_Region_Nm__c = 'APJ';
            //insert quote;
            quotes.add(quote);
            
            
            SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
            quote1.SBQQ__Account__c =  acc.Id;
            quote1.SBQQ__PrimaryContact__c = con.Id;
            quote1.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote1.Pricing_Project_Name_Nm__c = 'Test Project';
            quote1.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote1.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote1.Pricing_Customer_Nm__c = 'FMH';
            quote1.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote1.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote1.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote1.Pricing_Intel_Response_Requested_By_Date__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote1.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote1.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote1.Pricing_Region_Nm__c = 'APJ';
            quotes.add(quote1);
            
            SBQQ__Quote__c quote2 = new SBQQ__Quote__c();
            quote2.SBQQ__Account__c =  acc.Id;
            quote2.SBQQ__PrimaryContact__c = con.Id;
            quote2.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote2.Pricing_Project_Name_Nm__c = 'Test Project';
            quote2.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote2.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote2.Pricing_Customer_Nm__c = 'FMH';
            quote2.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote2.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote2.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote2.Pricing_Intel_Response_Requested_By_Date__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote2.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote2.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote2.Pricing_Region_Nm__c = 'APJ';
            quotes.add(quote2);
            insert quotes;
            
            List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>(); 
            SBQQ__QuoteLine__c quoteLineob = new SBQQ__QuoteLine__c(); 
            quoteLineob.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLineob.Pricing_Product_Nm__c = prod.Id;
            quoteLineob.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLineob.Pricing_Systems_qty__c = 6; 
            quoteLineob.Pricing_pm_approval_comments_nm__c  = 'Test Comment';
            quoteLineob.Pricing_CPUs_per_system_qty__c = 1;
            quoteLineob.Pricing_Single_System_Price_Amt__c = 4;
            quoteLineob.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLineob.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLineob.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLineob.Pricing_Competetor_Product__c=cp.Id;
            quoteLineob.SBQQ__Quote__c = quote.Id;
            quoteLines.add(quoteLineob);
            //insert quoteLine;
            //quoteLines.add(quoteLineob);
            
            SBQQ__QuoteLine__c quoteLineob1 = new SBQQ__QuoteLine__c(); 
            quoteLineob1.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLineob1.Pricing_Product_Nm__c = prod.Id;
            quoteLineob1.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLineob1.Pricing_Systems_qty__c = 6; 
            quoteLineob1.Pricing_pm_approval_comments_nm__c  = 'Test Comment';
            quoteLineob1.Pricing_CPUs_per_system_qty__c = 1;
            quoteLineob1.Pricing_Single_System_Price_Amt__c = 4;
            quoteLineob1.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLineob1.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLineob1.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLineob1.Pricing_Competetor_Product__c=cp.Id;  
            quoteLineob1.SBQQ__Quote__c = quote1.Id;
            quoteLines.add(quoteLineob1);
            
            SBQQ__QuoteLine__c quoteLineob2 = new SBQQ__QuoteLine__c(); 
            quoteLineob2.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLineob2.Pricing_Product_Nm__c = prod.Id;
            quoteLineob2.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLineob2.Pricing_Systems_qty__c = 6; 
            quoteLineob2.Pricing_pm_approval_comments_nm__c  = 'Test Comment';
            quoteLineob2.Pricing_CPUs_per_system_qty__c = 1;
            quoteLineob2.Pricing_Single_System_Price_Amt__c = 4;
            quoteLineob2.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLineob2.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLineob2.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLineob2.Pricing_Competetor_Product__c=cp.Id;  
            quoteLineob2.SBQQ__Quote__c = quote2.Id;
            quoteLines.add(quoteLineob2);            
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
            
            Pricing_Performance_Metric__c metrics1=new Pricing_Performance_Metric__c();
            metrics1.Pricing_Comp_SKU_Performance_Nbr__c=1;
            metrics1.Pricing_Intel_SKU_Performance_Nbr__c=1;
            metrics1.Pricing_Other_Nm__c='test';
            metrics1.Pricing_Performance_Metric_Nm__c='Other';
            metrics1.Pricing_Quote_Line__c=quoteLines[1].Id;
            metrics1.Pricing_Weighting_Pct__c=10;
            mList.add(metrics1);
            
            Pricing_Performance_Metric__c metrics2=new Pricing_Performance_Metric__c();
            metrics2.Pricing_Comp_SKU_Performance_Nbr__c=1;
            metrics2.Pricing_Intel_SKU_Performance_Nbr__c=1;
            metrics2.Pricing_Other_Nm__c='test';
            metrics2.Pricing_Performance_Metric_Nm__c='Other';
            metrics2.Pricing_Quote_Line__c=quoteLines[2].Id;
            metrics2.Pricing_Weighting_Pct__c=10;
            mList.add(metrics2);
            insert mList;  
            
            Set<Id> quoteIds = new Set<Id>{quote.Id, quote2.Id};
            List<Pricing_Comments__c> qComments = [SELECT id,name,Pricing_Answer__c FROM Pricing_Comments__c WHERE Pricing_Quote__c IN :quoteIds];
            for(Pricing_Comments__c qc : qComments){
                qc.Pricing_Answer__c = 'This is a test Answer. Test';
            }
            if(qComments.size() > 0){
                update qComments; 
            }
            test.startTest();
            Pricing_Publish_Quote.PublishTenderQuote(String.valueOf(quote2.Id));
            
            List<SBQQ__QuoteLine__c> qLines = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c quoteLineob3 = new SBQQ__QuoteLine__c(); 
            quoteLineob3.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLineob3.Pricing_Product_Nm__c = prod.Id;
            quoteLineob3.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLineob3.Pricing_Systems_qty__c = 6; 
            quoteLineob3.Pricing_pm_approval_comments_nm__c  = 'Test Comment';
            quoteLineob3.Pricing_CPUs_per_system_qty__c = 1;
            quoteLineob3.Pricing_Single_System_Price_Amt__c = 4;
            quoteLineob3.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLineob3.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLineob3.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLineob3.Pricing_Competetor_Product__c=cp.Id;  
            quoteLineob3.SBQQ__Quote__c = quote2.Id;  
            qLines.add(quoteLineob3);
            
            SBQQ__QuoteLine__c quoteLineob4 = new SBQQ__QuoteLine__c(); 
            quoteLineob4.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLineob4.Pricing_Product_Nm__c = prod.Id;
            quoteLineob4.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLineob4.Pricing_Systems_qty__c = 6; 
            quoteLineob4.Pricing_pm_approval_comments_nm__c  = 'Test Comment';
            quoteLineob4.Pricing_CPUs_per_system_qty__c = 1;
            quoteLineob4.Pricing_Single_System_Price_Amt__c = 4;
            quoteLineob4.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLineob4.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLineob4.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLineob4.Pricing_Competetor_Product__c=cp.Id; 
            quoteLineob4.SBQQ__Quote__c = quote2.Id;  
            qLines.add(quoteLineob4);
            insert qLines;
            
            Pricing_Performance_Metric__c metrics3=new Pricing_Performance_Metric__c();
            metrics3.Pricing_Comp_SKU_Performance_Nbr__c=1;
            metrics3.Pricing_Intel_SKU_Performance_Nbr__c=1;
            metrics3.Pricing_Other_Nm__c='test';
            metrics3.Pricing_Performance_Metric_Nm__c='Other';
            metrics3.Pricing_Quote_Line__c=quoteLineob3.Id;
            metrics3.Pricing_Weighting_Pct__c=10;            
            insert metrics3;
            
            test.stopTest();
        }
    } 
    
    private testMethod static void submitQuoteLine_Test(){
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
            
            List<SBQQ__QuoteLine__c> quoteLines = [SELECT id FROM SBQQ__QuoteLine__c ORDER BY CreatedDate DESC LIMIT 1];
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/submitquoteline';
            req.httpMethod = 'POST';
            req.addParameter('id', String.valueOf(quoteLines[0].Id));
            RestContext.request = req;        
            test.startTest();
            Pricing_RestAPI_Response response = Pricing_RestAPI_SubmitQuoteLine.doPost();
            //system.debug('response===>'+response);
            system.assert(response!=null);
            test.stopTest();
        }
    }
    
    private testMethod static void submitQuoteLine_AlreadySubmitted_Test(){
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
                       
            List<SBQQ__QuoteLine__c> quoteLines = [SELECT id,SBQQ__Quote__r.SBQQ__Status__c FROM SBQQ__QuoteLine__c ORDER BY CreatedDate DESC LIMIT 2];
            /*System.debug('quoteLines=>'+quoteLines[1]);
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/submitquoteline?id='+String.valueOf(quoteLines[0].Id);
            req.httpMethod = 'POST';
            req.addParameter('id', String.valueOf(quoteLines[0].Id));
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_SubmitQuoteLine.doPost();
            //system.debug('response===>'+response);
            system.assert(response!=null);*/
            
            RestRequest req1 = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            //RestResponse resp1 = RestContext.response;     
            req1.requestUri='/services/apexrest/v1.0/quoterequest/submitquoteline?id='+String.valueOf(quoteLines[1].Id);
            req1.httpMethod = 'POST';
            req1.addParameter('id', String.valueOf(quoteLines[1].Id));
            RestContext.request = req1;        
            test.startTest(); 
            Pricing_RestAPI_Response response1 = Pricing_RestAPI_SubmitQuoteLine.doPost();
            //system.debug('response===>'+response);
            system.assert(response1!=null);
            test.stopTest();
        }
    }
    
    private testMethod static void submitQuoteLine_InvalidInput_Test(){
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
            
            List<SBQQ__QuoteLine__c> quoteLines = [SELECT id FROM SBQQ__QuoteLine__c ORDER BY CreatedDate DESC LIMIT 1];
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/submitquoteline?id=6000AAA';
            req.httpMethod = 'POST';
            req.addParameter('id', '6000AAA');
            RestContext.request = req;        
            test.startTest();
            Pricing_RestAPI_Response response = Pricing_RestAPI_SubmitQuoteLine.doPost();
            //system.debug('response===>'+response);
            system.assert(response!=null);
            test.stopTest();
        }
    }
    
    private testMethod static void submitQuoteLine_DraftQuote_Test(){
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
            
            List<SBQQ__Quote__c> quotes = [SELECT id FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            List<SBQQ__QuoteLine__c> quoteLines = [SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quotes[0].Id LIMIT 1];
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/submitquoteline';
            req.httpMethod = 'POST';
            req.addParameter('id', String.valueOf(quoteLines[0].id));
            RestContext.request = req;        
            test.startTest();
            Pricing_RestAPI_Response response = Pricing_RestAPI_SubmitQuoteLine.doPost();
            //system.debug('response===>'+response);
            system.assert(response!=null);
            test.stopTest();
        }
    }
    private testMethod static void submitQuoteLine_NotFound_Test(){
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
           
            //List<SBQQ__Quote__c> quotes = [SELECT id FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft'];
            List<SBQQ__QuoteLine__c> quoteLines = [SELECT id FROM SBQQ__QuoteLine__c LIMIT 1];
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/submitquoteline';
            req.httpMethod = 'POST';
            String recId = String.valueOf(quoteLines[0].id);
            req.addParameter('id', recId.left(recId.length()-1)+'0');
            RestContext.request = req;        
             test.startTest();
            Pricing_RestAPI_Response response = Pricing_RestAPI_SubmitQuoteLine.doPost();
            //system.debug('response===>'+response);
            system.assert(response!=null);
            test.stopTest();
        }
    }
    
   
}