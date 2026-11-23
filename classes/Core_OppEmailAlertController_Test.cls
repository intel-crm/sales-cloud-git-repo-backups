@isTest
public class Core_OppEmailAlertController_Test {
	@testSetup
    static void setupTest() {
        Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
        triggerExecList.Bypass__c = true;
        INSERT triggerExecList;
               
        Document document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'application/pdf';
        document.DeveloperName = 'test';
        document.IsPublic = true;
        document.Name = Label.Pricing_IQR_Intel_Logo;
        document.FolderId = userinfo.getuserid();
        insert document;
        
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        lstAcc[1].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();      
        
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        lstAcc[1].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
        
        List<Opportunity> listOpportunity = Core_Test_Utility.createOpportunity(1);
        Id oppDealID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity(Name = 'PCCEmailNotification', RecordTypeId = oppDealID,
                                           AccountId = LstAcc[0].Id, OwnerId= UserInfo.getUserId(),
                                           Core_Coverage_Type_Nm__c = 'Deal Registration',Core_Opportunity_Type__c='Deal: Sell-to',Core_External_ID__c= 'TEST-123',
                                           StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_First_Customer_Ship_Date__c = System.Date.today().addYears(1),
                                           Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity');
        
        System.runAs(Core_Test_Utility.systemAdminUser){
            insert opp;
        }
        List<Product2> testProducts = Core_Test_Utility.createProduct(1);
        insert testProducts;
        
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(1, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        OpportunityLineItem testOppLineItem = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=testPBEs[0].Id,
                                                                      Description='Test 11', UnitPrice=11, Quantity=11,Core_Vendor__c=null,
                                                                      Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_BU_Mapping_record__c=null);
        
        System.runAs(Core_Test_Utility.systemAdminUser){
            insert testOppLineItem;
        }
    }
    
     @isTest
    public static void testOppEmailAlert(){
        Test.StartTest();
        List<Opportunity> lstOpp = [SELECT Id,Name,CreatedDate, CloseDate, Account.Name,Core_External_ID__c,OwnerId FROM Opportunity]; 
        List<OpportunityLineItem> lstOppProd = [SELECT Id,Name,Quantity,Core_Status__c  FROM OpportunityLineItem where OpportunityId =: lstOpp[0].Id];
        Core_OppEmailAlertController p1 = new Core_OppEmailAlertController();
        p1.oppId = lstOpp[0].Id;
        P1.headerURL = 'test';
        String domain = p1.getDomainName();
        String headerURL = p1.getHeaderURL();  
        String dealRegURL = p1.getDealRegExternalDomainName();
        Opportunity opp = p1.getOppData();  
        List<OpportunityLineItem> lstOppProddt = p1.getOppProdData();
        //System.assertEquals(lstOpp[0],opp);
        System.assertEquals(lstOppProd,lstOppProddt);
        Test.StopTest();
    }
}