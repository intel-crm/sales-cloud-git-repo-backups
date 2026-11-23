/**************************************************************************************
Apex Class Name:  Core_InactiveAccountonOpp_Test
Version     : 1.0 
Created Date: 20 APR 2022
Function    : Test Class for the Core_InactiveAccountonOpp class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             20/04/2022              Original Version
*************************************************************************************/
@isTest
public class Core_InactiveAccountonOpp_Test{
    static List<PricebookEntry> listPBE;
    static PricebookEntry testPBE;
    static Opportunity opp;
    static List<OpportunityLineItem> testOPI;
    static List<Account> accountList;
    static Product2 pd2;
    static void setupTest() {
          // Create and Insert test accounts
          // 
       // RecordType accRecordType = [select id from recordType where sObjectType='Account' and name ='Inactive Account' limit 1];
        accountList = Core_Test_Utility.createAccount(6);
        accountList[0].Name = 'Dell';
        accountList[0].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[0].Industry = 'Agriculture';
        accountList[0].Core_Sub_Industry__c = 'Forestry';
       // accountList[0].RecordType.name =accRecordType.Id;
         insert accountList;
        // Create and Insert a test Opportunity
        List<Opportunity> listOpportunity = Core_Test_Utility.createOpportunity(1); 
        opp = listOpportunity[0];    
        opp.Name='Test Opp';
        opp.AccountId = accountList[0].Id;
        opp.Core_First_Customer_Ship_Date__c=System.today()+90;
        //opp.Core_Commissionable__c='Yes';     
        //opp.Core_Opportunity_Type__c='Deal: Sell-to';
        //opp.Core_Solution_Area__c = 'CCG Commercial Deal $';
        System.runAs(Core_Test_Utility.systemAdminUser){          
            insert opp;
        }
        
         // Create and Insert a test Product
        pd2 = new Product2(Name = 'Test Product',
                           Core_Division_Code__c = '000',
                           Core_Division_Code_Short_Name__c = 'BBB',
                           Core_Group_Code__c = '111',
                           Core_Group_Code_Short_Name__c = 'AAA');
        System.runAs(Core_Test_Utility.systemAdminUser){  
            insert pd2;
        }
        
        // Create and Insert a test PriceBook Entry
        testPBE = new PricebookEntry();
        testPBE.UnitPrice = 1;
        testPBE.isActive  = TRUE;
        testPBE.Pricebook2Id = Test.getStandardPricebookId();
        testPBE.Product2Id = pd2.Id;      
        testPBE.UseStandardPrice = false;   
        System.runAs(Core_Test_Utility.systemAdminUser){  
            insert testPBE;
        }
        
        listPBE = new List<PricebookEntry>();
        for (Integer i = 0; i < 10; i++) {
            listPBE.add(testPBE);
        }
    }
    
     static TestMethod void testmethod1(){
        setupTest();
        Test.startTest();
        
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(1, listPBE, opp);
        List<Core_Opportunity_Partner__c> lstOppPartner = Core_Test_Utility.createOpportunityPartners(1, opp);
        lstOppPartner[0].Core_Partner__c = accountList[0].Id;
        oppLineItems[0].core_vendor__c = accountList[0].id;
        insert lstOppPartner; 
        insert oppLineItems;
        
        
        Core_InactiveAccountonOpp.getData(opp.Id);
        accountList[0].Core_Deactivated__c = true;
        accountList[0].Core_Deactivation_Reason__c = 'dd';
        update accountList;
        Core_InactiveAccountonOpp.getData(opp.Id);
        Test.stopTest();
    }
    
    static TestMethod void testmethod2(){
       Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;        
        // Create an account
        Account acct = new Account(Name = 'TestoppAccounthandle', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
        System.runAs(Core_Test_Utility.systemAdminUser) {
        insert acct;
        }
        //List<Opportunity> oppsd = new List<Opportunity>();
        Map<Id, OpportunityLineItem> OldOppLineItemMap = new Map<Id, OpportunityLineItem>();
        List<OpportunityLineItem> NewOppLineItemList = new List<OpportunityLineItem>();
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
    	System.runAs(Core_Test_Utility.systemAdminUser) {
            opps.Core_Opportunity_Type__c = 'Design: Original';
            opps.Core_First_Customer_Ship_Date__c = system.today()-1000;
            opps.Core_Number_of_Quarters__c = 6;
            insert opps;
            opps.StageName = 'Design';
            Update opps;
        }
        // Create a product/price book entry to use on the opportunities
            Product2 p = new Product2(Name = 'Test Product 03-24-2015');
		System.runAs(Core_Test_Utility.systemAdminUser) {
            insert p;
        }         PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                    UnitPrice = 0, IsActive = true);
		System.runAs(Core_Test_Utility.systemAdminUser) {
            insert pbe;
        }        List<OpportunityLineItem> oppItems = new List<OpportunityLineItem>();
            oppItems.add(new OpportunityLineItem(OpportunityId = opps.Id, PricebookEntryId = pbe.Id, Core_Status__c='Pending',
                                                        UnitPrice = 200, Quantity = 10)); 
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppItems;
        }             
		List<Core_Opp_FC_Prod_Schedule__c> fcRec = new List<Core_Opp_FC_Prod_Schedule__c>();
            fcRec.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opps.Id, Core_Opp_Line_Item_RecordID__c = oppItems[0].Id,Core_Opp_FC_Quarter_Date__c=System.Today())); 
        System.runAs(Core_Test_Utility.systemAdminUser) {
            //fcRec.Core_Opp_FC_Quarter_Date__c=System.Today();
            insert fcRec;
        }                             
        //OldOppLineItemMap.put(oppItems[0].Id, oppItems[0]);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Test.StartTest();
            Boolean Flag=Core_InactiveAccountonOpp.get6QPSData(opps.Id);
            System.debug('&&Flag'+Flag);
            system.assertEquals(true,Flag);
            opps.Core_First_Customer_Ship_Date__c=System.today();
            update fcRec;
            Flag=Core_InactiveAccountonOpp.get6QPSData(opps.Id);
            system.assertEquals(true,Flag);
            Test.stopTest();
        }
    }
}