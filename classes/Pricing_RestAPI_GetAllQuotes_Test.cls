@isTest
public class Pricing_RestAPI_GetAllQuotes_Test {
    @testSetup 
    private static void createData(){
        Pricing_RestAPI_TestUtility.createRestAPIErrorCodesConfig();
        Product2 prod = new Product2();
        prod.Core_Product_Org__c = 'Sales';
        prod.Core_Product_Type__c = 'Processors';
        prod.Core_Sales_Visible_Flag__c  = True;
        prod.IsActive = True;
        prod.Core_Hierarchy_ID__c = '43';
        prod.Core_Group_Code_Short_Name__c = 'CCG';
        prod.Core_Processor_Number_Nm__c  = '6220';
        prod.Name = 'Product X';
        
        Pricing_Test_Utility.createPriceBook();
        
        Pricing_Competitor_Product__c cp = new Pricing_Competitor_Product__c(
            Name = 'Product Z',
            Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z',
            RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c', 'Pricing_Data_Center')
        );
        insert prod;
        insert cp;
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();
        System.runAs(lstUsers2[0])
        {                      
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];

            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
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
            quotes.add(quote);
            test.startTest();
            insert quotes;
          
            List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>(); 
            SBQQ__QuoteLine__c quoteLineob = new SBQQ__QuoteLine__c(); 
            quoteLineob.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
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
            insert quoteLines; 
            
            test.stopTest();
        }
    }
    
    static testMethod void testgetAllQuoteswithoutParam(){
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
            test.startTest(); 
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/getallquotes?id=&endDate=&status=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('id', '');
            req.addParameter('endDate', '');
            req.addParameter('status', '');
            req.addParameter('limit', '');
            req.addParameter('offset', '');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_GetAllQuotes.doGet();
            system.assert(response!=null);
            test.stopTest();
    	}
    }
    static testMethod void testgetAllQuoteswithParam(){
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
            test.startTest(); 
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/getallquotes?id=&endDate=&status=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('id', '');
            req.addParameter('endDate', '');
            req.addParameter('status', '');
            req.addParameter('limit', '1');
            req.addParameter('offset', '1');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_GetAllQuotes.doGet();
            system.assert(response!=null);
            test.stopTest();
    	}
    }
}