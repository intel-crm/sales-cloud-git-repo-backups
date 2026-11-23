/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_Opportunities_Test 
* Version     : 1.0 
* Created Date: 8/8/2023
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Biswa			         8/8/2023             Test class for Core_RestAPI_Opportunities class
*****************************************************************************************************************************************/
@isTest
public class Core_RestAPI_Opportunities_Test {
    public static final String REQUEST_TEMPLATE = '{"resourcePath":"/services/apexrest/v1.0/unitTest","requestURI":"/v1.0/unitTest","requestBody":"","remoteAddress":"170.178.140.170","params":{},"httpMethod":"GET","headers":{"X-Salesforce-SIP":"170.178.140.170","Accept-Language":"en-US,en;q=0.9","Accept-Encoding":"gzip, deflate, br","Postman-Token":"09c84838-c53c-e33a-34ed-1717086d6c9e","Host":"intel--crmdevcase.cs92.my.salesforce.com","User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.75 Safari/537.36","Connection":"keep-alive","CipherSuite":"ECDHE-RSA-AES256-GCM-SHA384 TLSv1.2 256-bits","Accept":"*/*","Cache-Control":"no-cache"}}';
	@testSetup 
    private static void createData(){
        Profile prf = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
      //  User usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :prf.Id AND isActive = true AND Core_Employee_Type_Code__c='EMP' LIMIT 1];
	//	PermissionSetAssignment psa = [SELECT Id, PermissionSet.Name,PermissionSetId, AssigneeId from PermissionSetAssignment  where PermissionSet.Name='SalesRepBB' LIMIT 1];
	//	User usr = [SELECT id, Name, isActive FROM User WHERE Id = :psa.AssigneeId AND isActive = true AND Core_Employee_Type_Code__c='EMP' LIMIT 1];        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        Id usr = UserInfo.getUserId();
        // Create a product/price book entry to use on the opportunities
        Product2 p = new Product2(Name = 'Test Product KPI',Core_Inf_KPI_ProdGroup__c='PSG Board');
        insert p;
        PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 0, IsActive = true);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert pbe;
        }
        
		//SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        // Create an account
        Account acct = new Account();
        acct.name = 'TestAccountKPI';
		acct.RecordTypeId = recTypeId;
        acct.BillingCountryCode = 'USA';
        acct.BIllingStateCode = 'AL';
        acct.BillingCity = 'Alabama123';
        acct.BillingStreet = 'test123';  
        acct.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();
        acct.Industry='Health and Life Sciences'; 
        acct.Core_Sub_Industry__c='Biotechnology';     
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        
        Opportunity opp = new Opportunity(Name = 'OpportunityGetAPITest', RecordTypeId = newOppRecTypeId,core_approval_status__c = 'Approved',
                                                 AccountId = acct.Id,Core_Commissionable__c = 'Yes',Core_Technical_Owner__c=usr,Core_Date_Submitted_for_Approval__c = System.Date.today()+1,
                                                 StageName = 'Qualify', CloseDate = System.Date.today()+1);
       // System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opp;
       // }
     
        OpportunityTeamMember otm = new OpportunityTeamMember (OpportunityId = opp.Id,UserId = usr,TeamMemberRole = 'Team Member');
		insert otm;
        
        List<OpportunityLineItem> oppForKPIItems = new List<OpportunityLineItem>();
        oppForKPIItems.add(new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 0, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForKPIItems.add(new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 0, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppForKPIItems;
        }
        
        system.runAs(Core_Test_Utility.systemAdminUser){
        Map<id,SBQQ__Quote__c> quotesMap = new Map<Id,SBQQ__Quote__c>([SELECT id FROM SBQQ__Quote__c Limit 1]);
        List<SBQQ__QuoteLine__c> quoteLies = new List<SBQQ__QuoteLine__c>();
        
        for(SBQQ__QuoteLine__c qli : [SELECT id,Pricing_Status_Nm__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :quotesMap.keySet()]){
            qli.Pricing_Status_Nm__c = 'Approved';
            quoteLies.add(qli);
        }
        if(quoteLies.size() > 0){
            update quoteLies;
        }   
        Blob bodyBlob = Blob.valueOf('This is a test File');
        ContentVersion cv1 = new ContentVersion(Title='SampleFile',PathOnClient='Sample.pdf', VersionData=bodyBlob, Origin='H');
        insert cv1;
        List<ContentVersion> cv2 = [SELECT id,Title,ContentDocumentId FROM ContentVersion WHERE id=:cv1.Id LIMIT 1];
        List<SBQQ__QuoteDocument__c> sr = new List<SBQQ__QuoteDocument__c>();
        for (SBQQ__Quote__c q: quotesMap.values()){
            
            sr.add (new SBQQ__QuoteDocument__c(
                SBQQ__Quote__c = q.Id,
                SBQQ__Template__c = 'Standard Quote',
                SBQQ__DocumentId__c= cv2[0].ContentDocumentId
            ));  
            
        }
        insert sr;
           
        }
    }
    
    @isTest static void testDoGet_OpportunityData() {
        List<Opportunity> lstOpp = [select id,Name from Opportunity Where Name='OpportunityGetAPITest' limit 1];
        system.runAs(Core_Test_Utility.systemAdminUser){
            test.startTest();        
            RestRequest req = (RestRequest)System.jSON.deserialize(REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/opportunity?id=&type=';
            req.httpMethod = 'GET';
            req.addParameter('type', '');
            req.addParameter('id', lstOpp[0].id);
            RestContext.request = req;        
            Core_SalesCRM_RestAPI_Response response = Core_RestAPI_Opportunities.doGet();
            system.assert(response!=null);
            test.stopTest();
        }
    }
    
    @isTest static void testDoGet_OpportunityDataError() {
        List<Opportunity> lstOpp = [select id,Name from Opportunity Where Name='OpportunityGetAPITest' limit 1];
        system.runAs(Core_Test_Utility.systemAdminUser){
            test.startTest();        
            RestRequest req = (RestRequest)System.jSON.deserialize(REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/opportunity?id=&type=';
            req.httpMethod = 'GET';
            req.addParameter('type', '');
            req.addParameter('id', '');
            RestContext.request = req;        
            Core_SalesCRM_RestAPI_Response response = Core_RestAPI_Opportunities.doGet();
            system.assert(response!=null);
            test.stopTest();
        }
    }
    
    @isTest static void testDoGet_OpportunityDataError1() {
        List<Opportunity> lstOpp = [select id,Name from Opportunity Where Name='OpportunityGetAPITest' limit 1];
        system.runAs(Core_Test_Utility.systemAdminUser){
            test.startTest();        
            RestRequest req = (RestRequest)System.jSON.deserialize(REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/opportunity?id=&type=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'opportunity');
            req.addParameter('id', lstOpp[0].id);
            RestContext.request = req;        
            Core_SalesCRM_RestAPI_Response response = Core_RestAPI_Opportunities.doGet();
            system.assert(response!=null);
            test.stopTest();
        }
    }
    
    @isTest static void testDoPut_OpportunityValidationsSuccess() {
        List<Opportunity> lstOpp = [select id,Name,Core_Design_Registration_Id__c from Opportunity Where Name='OpportunityGetAPITest' limit 1];
        List<OpportunityLineItem> lstOppItms = [select id from OpportunityLineItem Where OpportunityId =: lstOpp[0].Id];
        DateTime dt = Date.Today().addDays(10);
		String dateStr = dt.format('MM/dd/yyyy') ;
        system.runAs(Core_Test_Utility.systemAdminUser){
            test.startTest();            
            RestRequest request = (RestRequest)System.jSON.deserialize(REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/opportunity';
            request.httpMethod = 'PUT';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{"opportunityId":"'+lstOpp[0].Id+'","stage":"Define","decisionDate":"'+dateStr+'","statusUpdate":"PQR 45678","competitiveArchitecture":"ASIC","architectureConversion":"true","volume":10,"IntelPlatform":"Agilex","productionEndDate":"'+dateStr+'","firstCustomerShipDate":"'+dateStr+'","manufacturingRegion":"ASMO","opportunityProducts":[{"status":"Pending","salesPrice":111,"quantity":10,"opportunityProductId":"' +lstOppItms[0].Id+'" }],"opportunityPoP": []}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Core_SalesCRM_RestAPI_Response restResponse = Core_RestAPI_Opportunities.doPut();
            system.assert(restResponse!=null);
            
            test.stopTest();
        }    
    }
}