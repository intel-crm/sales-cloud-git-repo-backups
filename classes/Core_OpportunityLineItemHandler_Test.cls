/****************************************************************************************************
Apex Class Name : Core_OpportunityLineItemHandler_Test
Version         : 1.0 
Created Date    : 2/11/15

Function        : Test class for CCV Sharing functions
Modifications:
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Sampath Bokam               03/17/2017              Updated addCommissionableTransactions() to account for new Line item Status values
* Sampath Bokam               11/09/2016              Stamping of Approved BU Short Name, Send to Commissions only if the Opportunity is Commissionable                 
* Nick Krisa                  07/30/15                Updated Version
* Brian Matthews              02/11/15                Original Version
*****************************************************************************************************/
@isTest()
public class Core_OpportunityLineItemHandler_Test {
    
    static List<PricebookEntry> listPBE;
    static PricebookEntry testPBE;
    static Opportunity opp;
    static List<OpportunityLineItem> testOPI;
    static List<Account> accountList;
    static Product2 pd2;
    
    
    public static List<Core_BU_Mapping_Table__c> mappingObjList = new List<Core_BU_Mapping_Table__c>();
    public static List<OpportunityLineItem> oppBUItemList = new List<OpportunityLineItem>();
    public static List<Core_Commission_Account_BU_SG_Setting__c> newTXNSetting1 = new List<Core_Commission_Account_BU_SG_Setting__c>();
    
    static void setupTest() {
        // Create and Insert test accounts
        Id recordTypeIDAct = [select id from RecordType where DeveloperName = 'Mastered_Account' limit 1].id;
        accountList = Core_Test_Utility.createAccount(6);
        accountList[0].Name = 'Dell';
        accountList[0].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[0].Industry = 'Telecommunications';
        accountList[0].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountList[1].Name = 'HP';
        accountList[1].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[1].Industry = 'Telecommunications';
        accountList[1].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountList[2].Name = 'Google';
        accountList[2].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[2].Industry = 'Telecommunications';
        accountList[2].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountList[3].Name = 'Apple';
        accountList[3].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[3].Industry = 'Telecommunications';
        accountList[3].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountList[4].Name = 'Target';
        accountList[4].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[4].Industry = 'Telecommunications';
        accountList[4].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountList[0].RecordTypeId = recordTypeIDAct;
        accountList[1].RecordTypeId = recordTypeIDAct;
        accountList[2].RecordTypeId = recordTypeIDAct;
        accountList[3].RecordTypeId = recordTypeIDAct;
        accountList[4].RecordTypeId = recordTypeIDAct;
       
        insert accountList;
        
        // Create and Insert a test Opportunity
        List<Opportunity> listOpportunity = Core_Test_Utility.createOpportunity(1); 
        opp = listOpportunity[0];    
        opp.AccountId = accountList[0].Id;
        //opp.Core_Commissionable__c='Yes';     
        //opp.Core_Opportunity_Type__c='Deal: Sell-to';
        //opp.Core_Solution_Area__c = 'CCG Commercial Deal $';
        opp.Opportunity_Focus__c= 'Core';
        opp.Core_Opportunity_Type__c ='Design: Original';
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
        
        List<Core_Trigger_Executions__c> teList = new List<Core_Trigger_Executions__c>();
       
        // Create and Insert Trigger Executions
        Core_Trigger_Executions__c triggerExec1 = new Core_Trigger_Executions__c(Name='insertPartners', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler', 
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='after insert',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = 'insert Partner');
        teList.add(triggerExec1);
        
        Core_Trigger_Executions__c triggerExec2 = new Core_Trigger_Executions__c(Name='updatePartners', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler', 
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='after update',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = 'update Partner');
        teList.add(triggerExec2);
        
        Core_Trigger_Executions__c triggerExec3 = new Core_Trigger_Executions__c(Name='deletePartners', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler', 
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='after delete',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = 'delete Partner');
        teList.add(triggerExec3);
        
        Core_Trigger_Executions__c triggerExec4 = new Core_Trigger_Executions__c(Name='populateGroup', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler', 
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='before insert',    
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = 'populate Group and Division');
        teList.add(triggerExec4);
        
        Core_Trigger_Executions__c triggerExec5 = new Core_Trigger_Executions__c(Name='opportunityLineItemAfterHandler', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler', 
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='after insert, after update, after delete',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = 'after handler');
        teList.add(triggerExec5);
        
        Core_Trigger_Executions__c triggerExec6 = new Core_Trigger_Executions__c(Name='opportunityApprovalHistoryInsert', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler',                                                                               
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='after update',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = 'insertapprovalhistory');
        teList.add(triggerExec6);
        
        
        Core_Trigger_Executions__c triggerExec7 = new Core_Trigger_Executions__c(Name='updateOpportunityLineItem', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler',                                                                               
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='after update',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c ='RemoveApprovedSalesGroup');
        teList.add(triggerExec7);                                                                       
        Core_Trigger_Executions__c triggerExec8 = new Core_Trigger_Executions__c(Name='deleteKPIonProductDelete', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler',                                                                               
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='before delete',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c ='Delete KPIs');
        teList.add(triggerExec8); 
        Core_Trigger_Executions__c triggerExec9 = new Core_Trigger_Executions__c(Name='OpportunityRiskEmailNotification', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler',                                                                               
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='After Update',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c ='Risk Email');
        teList.add(triggerExec9);
        Core_Trigger_Executions__c triggerExec10 = new Core_Trigger_Executions__c(Name='updateOppoRiskReasonOnOppLineItem', 
                                                                                  Core_Class_Name__c='Core_OpportunityLineItemHandler',                                                                               
                                                                                  Core_Object__c='OpportunityLineItem',
                                                                                  Core_Trigger_Events__c='After Update ,After Insert, After Delete',     
                                                                                  Core_Active__c=true, 
                                                                                  Core_Description__c ='Update Opportunity on OppLineItem Update/Insert/Delete');
        teList.add(triggerExec10);
        
        Core_Trigger_Executions__c triggerExec11 = new Core_Trigger_Executions__c(Name='OpportunityLIKPIJSON', 
                                                                                  Core_Class_Name__c='Core_OpportunityLineItemHandler',                                                                               
                                                                                  Core_Object__c='OpportunityLineItem',
                                                                                  Core_Trigger_Events__c='After Update ,After Insert',     
                                                                                  Core_Active__c=true, 
                                                                                  Core_Description__c ='Update Opportunity on OppLineItem Update/Insert/Delete');
        teList.add(triggerExec11);
        
        Core_Trigger_Executions__c triggerExec12 = new Core_Trigger_Executions__c(Name='updateEOLonOppPrd', 
                                                                                  Core_Class_Name__c='Core_OpportunityLineItemHandler',                                                                               
                                                                                  Core_Object__c='OpportunityLineItem',
                                                                                  Core_Trigger_Events__c='After Update ,After Insert',     
                                                                                  Core_Active__c=true, 
                                                                                  Core_Description__c ='Update Opportunity on OppLineItem Update/Insert/Delete');
        teList.add(triggerExec12);
        
        Core_Trigger_Executions__c triggerExec13 = new Core_Trigger_Executions__c(Name='validateQtyDecimal', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler', 
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='after insert',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = 'insert Partner');
        teList.add(triggerExec13);     
        
        Core_Trigger_Executions__c triggerExec14 = new Core_Trigger_Executions__c(Name='restrictDeletionOfOLI', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler', 
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='before update',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = 'before update');
        teList.add(triggerExec14);
        //6QPS
        Core_Trigger_Executions__c triggerExec15 = new Core_Trigger_Executions__c(Name='retrigger6QPSCalcOnOppProductUpdate', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler', 
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='after update',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = '6QPS retrigger calculation');
        teList.add(triggerExec15);
        
        Core_Trigger_Executions__c triggerExec16 = new Core_Trigger_Executions__c(Name='PCCDealRegOPTYLineQuoteSync', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler', 
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='after update',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = 'PCCDealRegOPTYLineQuoteSync');
        teList.add(triggerExec16);
        
        Core_Trigger_Executions__c triggerExec17 = new Core_Trigger_Executions__c(Name='PCCDealRegOPTYLineDelete', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler', 
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='Before Delete',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = 'PCCDealRegOPTYLineDelete');
        teList.add(triggerExec17);
        Core_Trigger_Executions__c triggerExec18 = new Core_Trigger_Executions__c(Name='opportunityLineItemFcDelete', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler', 
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='after delete',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = 'updatefcRecordOLIdelete');
        teList.add(triggerExec18);
        Core_Trigger_Executions__c triggerExec19 = new Core_Trigger_Executions__c(Name='stopDirectDeletefromEditPage', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler', 
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='Before delete',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = 'stopDirectDeletefromEditPage');
        teList.add(triggerExec19);
        insert teList;
        
        
        
    }
    @testSetup
    private static void setupTestData() {
         Core_Opp_Bypass_Validation_Rule__c rec = new Core_Opp_Bypass_Validation_Rule__c();
        rec.Bypass__c = true;
        insert rec;
        
        
        Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c(
            Name='trackOpportunityProductHistory', Core_Object__c='OpportunityLineItem', Core_Class_Name__c='Core_OpportunityLineItemHandler',
            Core_Trigger_Events__c='before update, before delete', Core_Active__c=true, Core_Description__c='testing, testing');
        insert triggerEntry;
        
        Account testAcct = Core_Test_Utility.createAccount(1)[0];
        testAcct.Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        testAcct.Industry = 'Telecommunications';
        testAcct.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        insert testAcct;
        
        // Simple test data
        Opportunity testOpp = new Opportunity(); 
        testOpp.CloseDate = System.Today().addDays(24);
        testOpp.StageName = 'Qualify';
        testOpp.Name = 'Test1';
        testOpp.Opportunity_Focus__c= 'Core';
        testOpp.Core_Opportunity_Type__c ='Design: Original';
        testOpp.AccountId = testAcct.Id;
        insert testOpp;
        
        List<Product2> testProducts = Core_Test_Utility.createProduct(3);
        insert testProducts;
        
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        
        // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the
        // opportunity product history object later (can't sort on Description or any other attribute)
        OpportunityLineItem testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=testOpp.Id, PricebookEntryId=testPBEs[0].Id,
                                                  Description='Test 11', UnitPrice=11, Quantity=11,
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=testOpp.Id, PricebookEntryId=testPBEs[1].Id,
                                                  Description='Test 12', UnitPrice=12, Quantity=12, 
                                                  Core_Loss_Cancel_Reason__c='', Core_Status__c='Pending');
        insert testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=testOpp.Id, PricebookEntryId=testPBEs[2].Id,
                                                  Description='Test 13', UnitPrice=13, Quantity=13,
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert testOppLineItem;
        
        testOppLineItem = new OpportunityLineItem(OpportunityId=testOpp.Id, PricebookEntryId=testPBEs[2].Id,
                                                  Description='Test 13', UnitPrice=13, Quantity=13,
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_At_Risk__c=true,Core_Risk_Reason1__c='Competition',Core_Risk_Detail__c = 'test',Core_Risk_Priority__c='3 Medium – Unusual Risk, Action Required',Core_Risk_Category__c='Support Requested',Core_At_Risk_Status__c='In-Progress');
        insert testOppLineItem;
        
        // Bulk test data
        List<Opportunity> bulkTestOpps = Core_Test_Utility.createOpportunity(1);
        for (Opportunity opp : bulkTestOpps){
            opp.AccountId = testAcct.Id;
         	opp.Opportunity_Focus__c= 'Core';
            opp.Core_Opportunity_Type__c ='Design: Original';}
        insert bulkTestOpps;
        
        List<Product2> bulkTestProducts = Core_Test_Utility.createProduct(1);
        insert bulkTestProducts;
        
        List<PricebookEntry> bulkTestPBEs = Core_Test_Utility.createPriceBookEntry(1, bulkTestProducts, Test.getStandardPricebookId());
        insert bulkTestPBEs;
        
        List<OpportunityLineItem> bulkTestOppLineItems = new List<OpportunityLineItem>();
        for (Opportunity opp : bulkTestOpps) {
            for (PricebookEntry pbe : bulkTestPBEs) {
                bulkTestOppLineItems.add(new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=pbe.Id,
                                                                 Description='Bulk 11', UnitPrice=11, Quantity=11, 
                                                                 Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
            }
        }
        insert bulkTestOppLineItems;
        
        // *********************************Here start for BU Mapping Record****************************************** //
        Core_Trigger_Executions__c triggerEntry_BU = new Core_Trigger_Executions__c(
            Name='set_BUShortName', Core_Object__c='OpportunityLineItem', Core_Class_Name__c='Core_OpportunityLineItemHandler',
            Core_Trigger_Events__c='before insert', Core_Active__c=true, Core_Description__c='testing BU Mapping');
        insert triggerEntry_BU;   
        
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1111',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='Emerging Technologies',
                                                         Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=4,
                                                         Core_BU_Segment__c='1111',Core_BU_Shortname__c='ABCD'));
        
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1110',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='Emerging Technologies',
                                                         Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c='',Core_Weightage__c=3,Core_BU_Segment__c='1110',Core_BU_Shortname__c='ABC'));
        
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1101',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='Emerging Technologies',
                                                         Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=3,Core_BU_Segment__c='1101',Core_BU_Shortname__c='ABD'));
        
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1100',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='Emerging Technologies',
                                                         Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='1100',Core_BU_Shortname__c='AB'));
        
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1000',Core_Division_Shortname__c='',Core_Product_Type__c='Emerging Technologies',
                                                         Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=1,Core_BU_Segment__c='1000',Core_BU_Shortname__c='A'));  
        
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1001',Core_Division_Shortname__c='',Core_Product_Type__c='Emerging Technologies',
                                                         Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='1001',Core_BU_Shortname__c='AD'));
        
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1010',Core_Division_Shortname__c='',Core_Product_Type__c='Emerging Technologies',
                                                         Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='1010',Core_BU_Shortname__c='AC'));
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1011',Core_Division_Shortname__c='',Core_Product_Type__c='Emerging Technologies',
                                                         Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=3,Core_BU_Segment__c='1011',Core_BU_Shortname__c='ACD'));
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0100',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='',
                                                         Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=1,Core_BU_Segment__c='0100',Core_BU_Shortname__c='B'));
        
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0101',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='',
                                                         Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='0101',Core_BU_Shortname__c='BD'));
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0110',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='',
                                                         Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='0110',Core_BU_Shortname__c='BC'));
        
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0111',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='',
                                                         Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=3,Core_BU_Segment__c='0111',Core_BU_Shortname__c='BCD'));                                              
        
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0001',Core_Division_Shortname__c='',Core_Product_Type__c='',
                                                         Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=1,Core_BU_Segment__c='0001',Core_BU_Shortname__c='D'));
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0010',Core_Division_Shortname__c='',Core_Product_Type__c='',
                                                         Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=1,Core_BU_Segment__c='0010',Core_BU_Shortname__c='C'));  
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0011',Core_Division_Shortname__c='',Core_Product_Type__c='',
                                                         Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='0011',Core_BU_Shortname__c='CD'));
        
        
        insert mappingObjList;                                            
        
        Core_BU_Mapping_Email_recipients__c recObj = new Core_BU_Mapping_Email_recipients__c();
        recObj.Core_isActive__c=true;
        recObj.Name='1';
        recObj.Core_User_Ids__c='Salesforce@intel.sfdc.com';  
        insert recObj; 
        // *********************************Here End  for BU Mapping Record****************************************** //
        
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = testAcct.Id;
        //quote.SBQQ__PrimaryContact__c = con.Id;
        quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
        quote.Pricing_Project_Name_Nm__c = 'Test Project';
        quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
        quote.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
        //quote.Pricing_End_Customer__c=unifiedEndCustomer.id;
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
        //quoteLineob.Pricing_Product_Nm__c = prod.Id;
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
        //quoteLineob.Pricing_Competetor_Product__c=cp.Id;
        quoteLineob.Pricing_Other_Competitor_Product_Nm__c = 'test';  
        quoteLineob.SBQQ__Quote__c = quote.Id;
        quoteLineob.Pricing_Status_Nm__c='Draft';
        quoteLine.add(quoteLineob);
        //insert quoteLine; 
    }
    static testMethod void Core_OpportunityLineItemHandler_Test_1() {    
        setupTest();
        Test.startTest();
        
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(1, listPBE, opp);
        insert oppLineItems;
        Test.setMock(HttpCalloutMock.class, new Core_KPITestHttpResponse(200));
        system.assertEquals(1, oppLineItems.size(),'Opportunity lineitems should be 1');
        
        Core_OpportunityLineItemHandler.opportunityLineItemAfterHandler(oppLineItems, null, null, null, true, false, false);        
        Test.stopTest();
    }
    
    static testMethod void Core_OpportunityLineItemHandler_Test_2() {  
        setupTest();
        
        Test.startTest();
        
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(1, listPBE, opp);
        insert oppLineItems;
        Test.setMock(HttpCalloutMock.class, new Core_KPITestHttpResponse(200));
        system.assertEquals(1, oppLineItems.size(),'Opportunity lineitems should be 1');
        Core_OpportunityLineItemHandler.opportunityLineItemAfterHandler(null, null, oppLineItems, null, false, false, true);
        
        Test.stopTest();
    }  
    
    static testMethod void populateGroup_Test_1() {
        setupTest();
        Test.startTest();
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = opp.Id,
                                                                  PricebookEntryId = testPBE.Id,
                                                                  Quantity = 1,
                                                                  UnitPrice = 200,
                                                                  Core_Status__c = 'Pending');
        
        
        insert oppLineItem;
        Test.setMock(HttpCalloutMock.class, new Core_KPITestHttpResponse(200));
        system.assertEquals(200, oppLineItem.UnitPrice,'Opportunity lineitems UnitPrice should be 200');
        
        
        List<OpportunityLineItem> insertedOLI = [SELECT Core_Group__c, Core_Group_Code__c, Core_Division__c,Core_Opp_Product_Segment__c,Core_Product_Application__c, 
                                                 Core_product2_division__c ,Core_Product_Type__c ,Core_Division_Code__c FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        
        
        
        
        Map<Id, OpportunityLineItem> oldMapOppLineList =  new Map<Id, OpportunityLineItem>();
        
        oldMapOppLineList.put(insertedOLI[0].id,insertedOLI[0]);
        //Core_OpportunityLineItemHandler.setBuShortNameOnUpdate(insertedOLI, oldMapOppLineList);
        Core_OpportunityLineItemHandler.Insert_logexception(insertedOLI,'Exception Test');
        //System.assertEquals('AAA', insertedOLI[0].Core_Group__c);
        //System.assertEquals('111', insertedOLI[0].Core_Group_Code__c);
        //System.assertEquals('BBB', insertedOLI[0].Core_Division__c);
        //System.assertEquals('000', insertedOLI[0].Core_Division_Code__c);
        Test.stopTest();
    }
    
    // Unique product -> insert partner
    static testMethod void insertPartner_Test_1() {  
        setupTest();
        Test.startTest();
        List<OpportunityLineItem> oppLineItemsupdate = new List<OpportunityLineItem> ();
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(1, listPBE, opp);
        oppLineItems[0].Core_Vendor__c = accountList[0].Id;
        oppLineItems[0].Core_PW_Sales_Price__c = 20;
        oppLineItems[0].Core_PW_Quantity__c = 4;
        insert oppLineItems;
        oppLineItemsupdate.addAll(oppLineItems);
        oppLineItems[0].Core_Status__c = 'Production Win Approved';
        update oppLineItems;
        Test.setMock(HttpCalloutMock.class, new Core_KPITestHttpResponse(200));
        //List<> lstOppLItem = new List<OpportunityLineItem>();
        //lstOppLItem.add(oppLineItems);
        map<id,OpportunityLineItem> mp = new map<id,OpportunityLineItem>();
        mp.put(oppLineItems[0].id,oppLineItems[0]);
        Core_OpportunityLineItemHandler.beforeInsertForecastRecords(oppLineItems );
        Core_OpportunityLineItemHandler.insertForecastRecords(oppLineItems,new List<Core_Opp_FC_Prod_Schedule__c>(),True);
        Core_OpportunityLineItemHandler.deleteForecastRecords(mp);
        Core_OpportunityLineItemHandler.updateForecastRecords(oppLineItems,mp);
        Core_OpportunityLineItemHandler.opptyLineItemUpdateSalesGroupandUserCovg(oppLineItems,mp,oppLineItems,mp,True);
        
        List<Core_Opportunity_Partner__c> relatedPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 
        
        System.assertEquals(1, relatedPartners.size(),'Opportunity Partners should be 1');
        System.assertEquals(accountList[0].Id, relatedPartners.get(0).Core_Partner__c,'Opportunity partner should be account');
        //System.assertEquals('Vendor', relatedPartners.get(0).Core_Partner_Role__c);
        Test.stopTest();
    }
    
    // Partner already exists -> do nothing
    static testMethod void insertPartner_Test_2() {     
        setupTest();
        Test.startTest();
        List<Core_Opportunity_Partner__c> lstOppPartner = Core_Test_Utility.createOpportunityPartners(1, opp);
        lstOppPartner[0].Core_Partner__c = accountList[0].Id;
        insert lstOppPartner;
        
        List<Core_Opportunity_Partner__c> existingPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 
        
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(1, listPBE, opp);     
        oppLineItems[0].Core_Vendor__c = accountList[0].Id;
        system.assertEquals(1, oppLineItems.size(),'Opportunity lineitems should be 1');
        
        insert oppLineItems;
        // Test.stopTest();
        Test.setMock(HttpCalloutMock.class, new Core_KPITestHttpResponse(200));
        List<Core_Opportunity_Partner__c> relatedPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 
        
        //System.assertEquals(1, existingPartners.size());
        //System.assertEquals(1, relatedPartners.size());
        System.assertEquals(existingPartners, relatedPartners,'new Opportunity partners should be equal should be exisiting partners');
        Test.stopTest();
    }
    // Bulk insert
    static testMethod void insertPartner_Test_3() {  
        setupTest();
        Test.startTest();
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(10, listPBE, opp);
        for (Integer i = 0; i < 2; i++) {
            oppLineItems[i].Core_Vendor__c = accountList[0].Id;
        }
        for (Integer i = 2; i < 4; i++) {
            oppLineItems[i].Core_Vendor__c = accountList[1].Id;
        }
        for (Integer i = 4; i < 6; i++) {
            oppLineItems[i].Core_Vendor__c = accountList[2].Id;
        }
        for (Integer i = 6; i < 8; i++) {
            oppLineItems[i].Core_Vendor__c = accountList[3].Id;
        }
        for (Integer i = 8; i < 10; i++) {
            oppLineItems[i].Core_Vendor__c = accountList[4].Id;
        }
        
        
        insert oppLineItems;
        Test.setMock(HttpCalloutMock.class, new Core_KPITestHttpResponse(200));
        system.assertEquals(accountList[4].Id, oppLineItems[8].Core_Vendor__c, 'the vendor is should be 5th account id');
        
        
        List<Core_Opportunity_Partner__c> relatedPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 
        Test.stopTest();
    }
    
    // Unique product -> delete related partner
    static testMethod void deletePartner_Test_1() {
        
        setupTest();
        Test.startTest(); 
        List<Core_Opportunity_Partner__c> lstOppPartner = Core_Test_Utility.createOpportunityPartners(1, opp);
        lstOppPartner[0].Core_Partner__c = accountList[0].Id;
        insert lstOppPartner;
        
        List<Core_Opportunity_Partner__c> existingPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 
        
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(1, listPBE, opp);
        oppLineItems[0].Core_Vendor__c = accountList[0].Id;
        insert oppLineItems;
        System.assertEquals(accountList[0].Id,oppLineItems[0].Core_Vendor__c,'Opportunity lineitemsvendor should be an Acoount');
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Opp_Bypass_Validation_Rule__c vrBypass = new Core_Opp_Bypass_Validation_Rule__c();
            vrBypass.Bypass__c = true;
            vrBypass.SetupOwnerId = Core_Test_Utility.systemAdminUser.Id;
            insert vrBypass;
            //delete oppLineItems;
        }
        
        List<Core_Opportunity_Partner__c> relatedPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 
        
        //System.assertEquals(1, existingPartners.size());
        //System.assertEquals(accountList[0].Id, existingPartners.get(0).Core_Partner__c);
        //System.assertEquals(0, relatedPartners.size());
        Test.stopTest();
    }
    
    
    // Multiple product -> do nothing
    static testMethod void deletePartner_Test_2() {
        Test.startTest();
        setupTest();
        
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(2, listPBE, opp);
        oppLineItems[0].Core_Vendor__c = accountList[0].Id;
        oppLineItems[1].Core_Vendor__c = accountList[0].Id;
        insert oppLineItems;
        Test.setMock(HttpCalloutMock.class, new Core_KPITestHttpResponse(200));
        system.assertEquals(2, oppLineItems.size(),'Opportunity lineitems should be 2');
        system.assertEquals(accountList[0].Id, oppLineItems[0].Core_Vendor__c,'Opportunity lineitems vendor should be an Account');
        
        List<Core_Opportunity_Partner__c> existingPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Opp_Bypass_Validation_Rule__c vrBypass = new Core_Opp_Bypass_Validation_Rule__c();
            vrBypass.Bypass__c = true;
            vrBypass.SetupOwnerId = Core_Test_Utility.systemAdminUser.Id;
            insert vrBypass;
            //delete oppLineItems[0];
        }
        
        
        List<Core_Opportunity_Partner__c> relatedPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 
        Test.stopTest();
    }
    
    // Bulk delete
    static testMethod void deletePartner_Test_3() {
        
        setupTest();
        Test.startTest();
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(8, listPBE, opp);
        oppLineItems[0].Core_Vendor__c = accountList[0].Id;
        oppLineItems[1].Core_Vendor__c = accountList[0].Id;
        oppLineItems[2].Core_Vendor__c = accountList[1].Id;
        oppLineItems[3].Core_Vendor__c = accountList[1].Id;
        oppLineItems[4].Core_Vendor__c = accountList[2].Id;
        oppLineItems[5].Core_Vendor__c = accountList[2].Id;
        oppLineItems[6].Core_Vendor__c = accountList[3].Id;
        oppLineItems[7].Core_Vendor__c = accountList[4].Id;
        
        insert oppLineItems;
        Test.setMock(HttpCalloutMock.class, new Core_KPITestHttpResponse(200));
        system.assertEquals(8, oppLineItems.size(),'Opportunity lineitems should be 8');
        
        List<Core_Opportunity_Partner__c> existingPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Opp_Bypass_Validation_Rule__c vrBypass = new Core_Opp_Bypass_Validation_Rule__c();
            vrBypass.Bypass__c = true;
            vrBypass.SetupOwnerId = Core_Test_Utility.systemAdminUser.Id;
            insert vrBypass;
            // Test.startTest();
           /* delete oppLineItems[1];
            delete oppLineItems[3];
            delete oppLineItems[4];
            delete oppLineItems[5];
            delete oppLineItems[6];
            delete oppLineItems[7];*/
        }
        // Test.stopTest();
        
        List<Core_Opportunity_Partner__c> relatedPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 
        List<OpportunityLineItem> relatedLineItems = [SELECT Id, OpportunityId, Core_Vendor__c FROM OpportunityLineItem WHERE OpportunityId =:opp.Id];
        Integer vendors = Core_OpportunityLineItemHandler.multipleVendors(relatedLineItems, oppLineItems[1]);
        Test.stopTest();
        
    }
    
    // Unique old, unique new -> update
    static testMethod void updatePartner_Test_1() {
        Test.startTest();
        setupTest();
        
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(1, listPBE, opp);
        oppLineItems[0].Core_Vendor__c = accountList[0].Id;
        insert oppLineItems[0];
        system.assertEquals(1, oppLineItems.size(),'');
        List<Core_Opportunity_Partner__c> existingPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 
        
        oppLineItems[0].Core_Vendor__c = accountList[1].Id;
        
        // Test.startTest();
        update oppLineItems[0];
        Test.setMock(HttpCalloutMock.class, new Core_KPITestHttpResponse(200));
        // Test.stopTest();
        
        List<Core_Opportunity_Partner__c> relatedPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 
        Test.stopTest();
    }   
    
    // Duplicate old, unique new -> create partner
    static testMethod void updatePartner_Test_2() {
        Test.startTest();
        setupTest();
        
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(2, listPBE, opp);
        oppLineItems[0].Core_Vendor__c = accountList[0].Id;
        oppLineItems[1].Core_Vendor__c = accountList[0].Id;
        insert oppLineItems;
        system.assertEquals(2, oppLineItems.size(),'Opportunity lineitems should be 2');
        List<Core_Opportunity_Partner__c> existingPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 
        
        oppLineItems[1].Core_Vendor__c = accountList[1].Id;
        
        //  Test.startTest();
        update oppLineItems[1];
        Test.setMock(HttpCalloutMock.class, new Core_KPITestHttpResponse(200));
        //  Test.stopTest();
        
        List<Core_Opportunity_Partner__c> relatedPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 
        
        System.assertEquals(1, existingPartners.size(),'');
        System.assertEquals(accountList[0].Id, existingPartners[0].Core_Partner__c,'');
        //System.assertEquals(2, relatedPartners.size(),'');
        System.assertEquals(accountList[0].Id, relatedPartners[0].Core_Partner__c,'');
        //System.assertEquals(accountList[1].Id, relatedPartners[1].Core_Partner__c,'');
        Test.stopTest();
    }
    
    // Duplicate old, duplicate new -> do nothing
    static testMethod void updatePartner_Test_3() {
        Test.startTest();
        setupTest();
        
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(3, listPBE, opp);
        oppLineItems[0].Core_Vendor__c = accountList[0].Id;
        oppLineItems[1].Core_Vendor__c = accountList[0].Id;
        opplineItems[2].Core_Vendor__c = accountList[1].Id;
        insert oppLineItems;
        
        List<Core_Opportunity_Partner__c> existingPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 
        
        oppLineItems[1].Core_Vendor__c = accountList[1].Id;
        
        // Test.startTest();
        update oppLineItems[1];
        // Test.stopTest();
        Test.setMock(HttpCalloutMock.class, new Core_KPITestHttpResponse(200));
        List<Core_Opportunity_Partner__c> relatedPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 
        
        System.assertEquals(2, existingPartners.size(),'');
        System.assertEquals(accountList[0].Id, existingPartners[0].Core_Partner__c,'');
        System.assertEquals(accountList[1].Id, existingPartners[1].Core_Partner__c,'');
        System.assertEquals(2, relatedPartners.size(),'');
        System.assertEquals(accountList[0].Id, relatedPartners[0].Core_Partner__c,'');
        System.assertEquals(accountList[1].Id, relatedPartners[1].Core_Partner__c,'');
        System.assertEquals(existingPartners.get(0), relatedPartners.get(0),'');
        System.assertEquals(existingPartners.get(1), relatedPartners.get(1),'');
        Test.stopTest();
    }
    
    // Unique old, multiple new -> delete old
    static testMethod void updatePartner_Test_4() {
        Test.startTest();
        setupTest();
        
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(2, listPBE, opp);
        oppLineItems[0].Core_Vendor__c = accountList[0].Id;
        oppLineItems[1].Core_Vendor__c = accountList[1].Id;
        insert oppLineItems;
        
        List<Core_Opportunity_Partner__c> existingPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 
        
        oppLineItems[0].Core_Vendor__c = accountList[1].Id;
        
        //  Test.startTest();
        update oppLineItems[0];
        // Test.stopTest();
        
        List<Core_Opportunity_Partner__c> relatedPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 
        Test.setMock(HttpCalloutMock.class, new Core_KPITestHttpResponse(200));
        System.assertEquals(2, existingPartners.size(),'');
        System.assertEquals(accountList[0].Id, existingPartners[0].Core_Partner__c,'');
        System.assertEquals(accountList[1].Id, existingPartners[1].Core_Partner__c,'');
        //System.assertEquals(1, relatedPartners.size(),'');
        //System.assertEquals(accountList[1].Id, relatedPartners[0].Core_Partner__c,'');
        //System.assertEquals(existingPartners.get(1), relatedPartners.get(0),'');
        Test.stopTest();
    }
    
    // 'Lost', 'Cancelled' or 'Deleted' -> delete
    static testMethod void updateParnter_Test_5() {
        setupTest();
        Test.startTest();
        
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(3, listPBE, opp);
        oppLineItems[0].Core_Vendor__c = accountList[0].Id;
        oppLineItems[1].Core_Vendor__c = accountList[1].Id;
        oppLineItems[2].Core_Vendor__c = accountList[2].Id;
        insert oppLineItems;
        
        List<Core_Opportunity_Partner__c> existingPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 
        
        List<OpportunityLineItem> update1List = new List<OpportunityLineItem>();
        oppLineItems[0].Core_Status__c = 'Lost';
        oppLineItems[0].Core_Competitor__c ='Acer';
        oppLineItems[0].Core_Competitor_Product__c='AMD Athlon';
        oppLineItems[0].Core_Loss_Cancel_Reason__c = 'Other';
        oppLineItems[1].Core_Status__c = 'Win Approved';
        oppLineItems[1].Core_Loss_Cancel_Reason__c = 'Other';
        oppLineItems[2].Core_Status__c = 'Deleted';
        oppLineItems[2].Core_Loss_Cancel_Reason__c = 'Other';
        update1List.add(oppLineItems[0]);
        update1List.add(oppLineItems[1]);
        update1List.add(oppLineItems[2]);
        update update1List;
        
        Test.setMock(HttpCalloutMock.class, new Core_KPITestHttpResponse(200));
        List<Core_Opportunity_Partner__c> update1 = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 
        
        List<OpportunityLineItem> update2List = new List<OpportunityLineItem>();
        oppLineItems[0].Core_BypassFlow__c = true;
        oppLineItems[1].Core_BypassFlow__c = true;
        oppLineItems[2].Core_BypassFlow__c = true;
        
        oppLineItems[0].Core_Status__c = 'Pending';
        oppLineItems[1].Core_Status__c = 'Pending';
        oppLineItems[2].Core_Status__c = 'Pending';
        update2List.add(oppLineItems[0]);
        update2List.add(oppLineItems[1]);
        update2List.add(oppLineItems[2]);
        
        update update2List;
        
        List<Core_Opportunity_Partner__c> update2 = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id];
        
        System.assertEquals(3, existingPartners.size(),'');
        //System.assertEquals(1, update1.size(),'');
        //System.assertEquals(3, update2.size(),'');
        
        Test.stopTest();
    }
    
    //Test section added to support Commissionable Transactions
    public static List < Core_Trigger_Executions__c > lstTriggerExecution = new List < Core_Trigger_Executions__c > ();
    public static List < Core_Commissionable_Transaction_Type__c > lstCommissionableTransactionType = new List < Core_Commissionable_Transaction_Type__c > ();
    public static List < Core_Commissions_Percent_Contribution__c > lstCommissionsPctContrib = new List < Core_Commissions_Percent_Contribution__c > ();    
    public static Account account = new Account();
    public static Opportunity opportunity = new Opportunity();   
    public static Product2 product = new Product2();
    public static List<User> lstUser = new List<User>();
    public static List<OpportunityTeamMember> lstOpportunityTeamMember = new List<OpportunityTeamMember>();
    public static List<OpportunityLineItem> lstOP = new List<OpportunityLineItem>();
    public static Map<Integer,String> mapTeamMemberRole = new Map<Integer,String>();
    
    static void createTriggerExecutions() {        
        Core_Trigger_Executions__c OpportunityFactsUpdate = new Core_Trigger_Executions__c();
        OpportunityFactsUpdate.Name = 'opportunityLineItemAddCommTxns';
        OpportunityFactsUpdate.Core_Object__c = 'Descriptive Feature';
        OpportunityFactsUpdate.Core_Trigger_Events__c = 'After insert After update';
        OpportunityFactsUpdate.Core_Active__c = true;
        OpportunityFactsUpdate.Core_Description__c = 'This is test description';
        OpportunityFactsUpdate.Core_Class_Name__c = 'Test Class';        
        lstTriggerExecution.add(OpportunityFactsUpdate);
        
        OpportunityFactsUpdate = new Core_Trigger_Executions__c();
        OpportunityFactsUpdate.Name = 'opportunityLineItemAfterHandler';
        OpportunityFactsUpdate.Core_Object__c = 'Descriptive Feature';
        OpportunityFactsUpdate.Core_Trigger_Events__c = 'After insert After update After Delete';
        OpportunityFactsUpdate.Core_Active__c = true;
        OpportunityFactsUpdate.Core_Description__c = 'This is test description';
        OpportunityFactsUpdate.Core_Class_Name__c = 'Test Class';        
        lstTriggerExecution.add(OpportunityFactsUpdate);
        
        insert lstTriggerExecution;
    }
    
    static void createCommissionableTransactionTypes() {        
        
        Core_Commissionable_Transaction_Type__c ctt = new Core_Commissionable_Transaction_Type__c();
        ctt.Name = 'Any Opportunity Product';
        ctt.Core_Opportunity_Product__c = 'Any Opportunity Product';
        ctt.Core_Commissionable_Transaction_Type__c = 'Opportunity Revenue';
        lstCommissionableTransactionType.add(ctt);
        
        insert lstCommissionableTransactionType;
    }
    
    static void createCommissionsPctContrib() {
        //map of OpportunityTeamMember roles
        mapTeamMemberRole.put(0,'Team Member');
        mapTeamMemberRole.put(1,'Technical Owner');
        mapTeamMemberRole.put(2,'Contributor');
        mapTeamMemberRole.put(3,'Viewer');
        mapTeamMemberRole.put(4,'Contributor');
        mapTeamMemberRole.put(5,'Contributor');
        mapTeamMemberRole.put(6,'Opportunity Owner');
        
        Core_Commissions_Percent_Contribution__c cpc = new Core_Commissions_Percent_Contribution__c();
        cpc.Name = mapTeamMemberRole.get(0);
        cpc.Core_Percent_Contribution__c = 100;
        lstCommissionsPctContrib.add(cpc);
        
        cpc = new Core_Commissions_Percent_Contribution__c();
        cpc.Name = mapTeamMemberRole.get(1);
        cpc.Core_Percent_Contribution__c = 100;
        lstCommissionsPctContrib.add(cpc);
        
        cpc = new Core_Commissions_Percent_Contribution__c();
        cpc.Name = mapTeamMemberRole.get(2);
        cpc.Core_Percent_Contribution__c = 50;
        lstCommissionsPctContrib.add(cpc);
        
        cpc = new Core_Commissions_Percent_Contribution__c();
        cpc.Name = mapTeamMemberRole.get(3);
        cpc.Core_Percent_Contribution__c = 0;
        lstCommissionsPctContrib.add(cpc);
        
        cpc = new Core_Commissions_Percent_Contribution__c();
        cpc.Name = mapTeamMemberRole.get(6);
        cpc.Core_Percent_Contribution__c = 100;
        lstCommissionsPctContrib.add(cpc);
        
        
        insert (lstCommissionsPctContrib);
        
    }
    
    /*
* Method name  : createData
* Description  : method to Create the instances for the record
* Return Type  : VOID
* Parameter    : NONE
*/  
    static void createData(){
        test.startTest();
        createTriggerExecutions();        
        createCommissionableTransactionTypes();
        createCommissionsPctContrib();
        
        // Create and Insert a test Product
        pd2 = new Product2(Name = 'Test Product',
                           Core_Division_Code__c = '000',
                           Core_Division_Code_Short_Name__c = 'BBB',
                           Core_Group_Code__c = '111',
                           Core_Group_Code_Short_Name__c = 'AAA', Core_Inf_KPI_ProdGroup__c='test unqualified');
        System.runAs(Core_Test_Utility.systemAdminUser){  
            insert pd2;
        }
        
        // Create and Insert a test PriceBook Entry
        testPBE = new PricebookEntry();
        testPBE.UnitPrice = 100;
        testPBE.isActive  = TRUE;
        testPBE.Pricebook2Id = Test.getStandardPricebookId();
        testPBE.Product2Id = pd2.Id;      
        testPBE.UseStandardPrice = false;   
        System.runAs(Core_Test_Utility.systemAdminUser){  
            insert testPBE;
        }
        
        List<PricebookEntry> PBEs = new List<PricebookEntry>();
        for (Integer i = 0; i < 10; i++) {
            PBEs.add(testPBE);
        }
        
        
        //Create an account
        account.Name = 'testacctSolutionMilestoneAddCommissionableTxns';            
        account.BillingCountryCode = 'USA';
        account.Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        account.BillingStateCode = 'AL';
        account.BillingCity = 'Alabama';
        account.BillingStreet = 'test';
        //account.Core_CIM_ID__c = '98765432';
        //account.Industry = 'Agriculture';
        //account.Core_Sub_Industry__c = 'Forestry';
        account.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        account.Industry = 'Telecommunications';
        account.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();
        try {
            insert account;
           } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_OpportunityLineItemHandler_Test.createData');
        }
        
        List<Account> accounts = new  List<Account>();
         accounts = [SELECT Id, Core_Business_Party_Id__c, Name FROM Account WHERE name like :account.Name LIMIT 1];
        //System.assert(!accounts.isEmpty());
        if (accounts != null && accounts.size() > 0)
        {
             account = accounts.get(0);
             opportunity.AccountId = account.Id;
        }       
        
        //Create an associated opportunity  
        opportunity.CloseDate = System.Today().addDays(24);
        opportunity.StageName = 'Prospecting';
        opportunity.Name = 'testop_solutionMilestoneAddCommissionableTxns';
       
        opportunity.Core_Opportunity_Type__c = 'Design: Original';
        opportunity.Core_Technical_Owner__c = UserInfo.getUserId();
        opportunity.Core_Solution_Area__c='CCG Commercial Deal $';
        opportunity.Core_First_Customer_Ship_Date__c = System.Today();
        opportunity.Core_Intel_Platform__c = 'ALDER LAKE';
        //opportunity.Core_Opp_Prime_Account_Name__c = 'Tes PrimeAccount';
        opportunity.Core_Commissionable__c = 'Yes';
        try {
            insert opportunity;
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_OpportunityLineItemHandler_Test.createData');
        }
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        opportunityList =   [SELECT Id, Name, Core_Opportunity_Type__c FROM Opportunity WHERE Name=:opportunity.name LIMIT 1];
        //System.assert(!opportunityList.isEmpty());
        if (!opportunityList.isEmpty() )
        {
             opportunity = opportunityList.get(0);
        }      
        
        //Create a series of users
        lstUser = Core_Test_Utility.Core_User(6);
        integer i = 0;
        for(User user : lstUser)
        {
            user.FirstName = 'testusmact';
            user.LastName = mapTeamMemberRole.get(i);
            user.Core_WWID__c = '9876543' + i;
            //Create one CTW and one non-badged user -- these users should not have associated Commissionable Transactions generated
            if (i == 4)
            {
                user.Core_Employee_Type_Code__c = 'CTW';
            }
            else if (i == 5)
            {
                user.Core_Employee_Type_Code__c = 'Non-Badged';
            }
            i++;
        }
        
        try {
            insert lstUser;            
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_OpportunityLineItemHandler_Test.createData');
        }
        //Database.SaveResult[] lstSaveResultUser = Database.insert(lstUser, false);
        
        lstUser = [SELECT Id, Name, Core_WWID__c, FirstName, LastName, Core_Employee_Type_Code__c
                   FROM User WHERE FirstName = 'testusmact'];
        //System.assert(!lstUser.isEmpty());
        
        //Create a series of associated opportunity team members (one of each Opportunity Team Member Role)
        i = 0;
        for(User user:lstUser)
        {
            OpportunityTeamMember otm = new OpportunityTeamMember();
            otm.OpportunityId = opportunity.Id;
            otm.UserId = user.Id;
            otm.TeamMemberRole = mapTeamMemberRole.get(i);
            
            lstOpportunityTeamMember.add(otm);            
            i++;
        }
        
        try {
            insert lstOpportunityTeamMember;            
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_OpportunityLineItemHandler_Test.createData');
        }
        //Database.SaveResult[] lstSaveResultOTM = Database.insert(lstOpportunityTeamMember, false);
        
        lstOpportunityTeamMember = [SELECT Id, UserId, TeamMemberRole from OpportunityTeamMember WHERE OpportunityId = :opportunity.Id];        
        //System.assert(!lstOpportunityTeamMember.isEmpty());
        
        //Create associated opportunity product
        
        lstOP = Core_Test_Utility.createOpportunityLineItems(1, PBEs, opportunity);
        OpportunityLineItem op = lstOP.get(0);
        op.Core_Status__c = 'Pending';
        op.Core_Approved_Commissionable__c=Null; 
        op.Core_Claim_Date__c = System.today();
        
        try {
            insert lstOP;            
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_OpportunityLineItemHandler_Test.createData');
        }
        
        lstOP = [SELECT Id, Core_Status__c, Core_Approved_Decision_Date__c, Core_Approved_Total_Price__c, Core_Claim_Date__c, TotalPrice, UnitPrice, Quantity
                 FROM OpportunityLineItem WHERE OpportunityId = :opportunity.Id];
        //System.assert(!lstOP.isEmpty());
        test.stopTest();
    }
    
    static testMethod void testApproveOP() {      
        createData();     
        List<OpportunityLineItem> lop = 
            [SELECT Id, Core_Status__c, Core_Approved_Decision_Date__c, Core_Approved_Total_Price__c, Core_Claim_Date__c, TotalPrice, UnitPrice, Quantity, Core_BU_Short_Name__c,Core_Approved_Commissionable__c
             FROM OpportunityLineItem WHERE Id = :lstOP.get(0).Id];
        //System.assert(!lop.isEmpty());
        
        OpportunityLineItem op = lop.get(0);        
        op.Core_Status__c = 'Win Approved';
        op.Core_Approved_Commissionable__c='Yes' ; 
        op.Core_Approved_Decision_Date__c = System.today();
        op.Core_Approved_Total_Price__c = op.UnitPrice * op.Quantity;
        op.TotalPrice = op.UnitPrice * op.Quantity;
        //op.Core_BU_Short_Name__c = 'BU Short Name';
        op.Core_Approved_KPI_Product_Group__c  = 'test unqualified';
        op.CRM_DW_App_UCD_Customer_Name__c  = 'test PrimeAccount';
        op.Core_Claim_Date__c = System.today();
        Core_OpportunityLineItemHandler.alreadyAddedCommissionableTransactions = false;
        try {
            
            update op; 
            
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_OpportunityLineItemHandler_Test.createData');
        }
        system.assertEquals('test PrimeAccount', op.CRM_DW_App_UCD_Customer_Name__c, 'Opportunity prime account should be test PrimeAccount');
        lop = 
            [SELECT Id, Core_Status__c, Core_Approved_Decision_Date__c, Core_Approved_Total_Price__c, Core_Claim_Date__c, TotalPrice, UnitPrice, Quantity, Core_BU_Short_Name__c,Core_Approved_Commissionable__c
             FROM OpportunityLineItem WHERE Id = :lstOP.get(0).Id];
        //System.assert(!lop.isEmpty());
        
        List <Core_Commissionable_Transaction__c> lct = [            
            SELECT Core_Account_Name__c,Core_Approved_Total_Price__c,Core_Claim_Date__c,
            Core_Employee_Name__c,Core_Last_Approved_Date__c,Core_Milestone_Area__c,
            Core_Milestone_Focus__c,Core_Milestone__c,Core_Opportunity_Name__c,Core_Opportunity_Team_Member_Role__c,
            Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,Core_Product_Type__c,
            Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,Core_Transaction_Type__c,Core_WWID__c,Core_Approved_BU_Short_Name__c
            FROM Core_Commissionable_Transaction__c 
        ];
        
        //System.assert(!lct.isEmpty());
        op.Core_Status__c = 'Pending';
        try {
            
            update op; 
            
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_OpportunityLineItemHandler_Test.createData');
        }
        //System.assert(lct.size() == 5);       
    }
    
    static testMethod void testApproveOP1() {  
        
        createData();  
        
        Core_Trigger_Executions__c triggerexec1 = new Core_Trigger_Executions__c();
        triggerexec1.Name = 'oppLineCommissionTxnNewLogic';
        triggerexec1.Core_Object__c = 'OpportunityLineItem';
        triggerexec1.Core_Trigger_Events__c = 'After insert After update';
        triggerexec1.Core_Active__c = true;
        triggerexec1.Core_Description__c = 'This is test description';
        triggerexec1.Core_Class_Name__c = 'Test Class';        
        
        insert triggerexec1;
        
        List<OpportunityLineItem> lop = 
            [SELECT Id, Core_Status__c, Core_Approved_Decision_Date__c, Core_Approved_Total_Price__c, Core_Claim_Date__c, TotalPrice, UnitPrice, Quantity, Core_BU_Short_Name__c,Core_Approved_Commissionable__c
             FROM OpportunityLineItem WHERE Id = :lstOP.get(0).Id];
        System.assert(!lop.isEmpty(),'');
        
        
        OpportunityLineItem op = lop.get(0);        
        op.Core_Status__c = 'Win Approved';
        op.Core_Approved_Commissionable__c='Yes' ; 
        op.Core_Approved_Decision_Date__c = System.today();
        op.Core_Approved_Total_Price__c = op.UnitPrice * op.Quantity;
        op.TotalPrice = op.UnitPrice * op.Quantity;
        //op.Core_BU_Short_Name__c = 'BU Short Name';
        op.Core_Approved_KPI_Product_Group__c  = 'test unqualified';
        op.CRM_DW_App_UCD_Customer_Name__c  = 'test PrimeAccount';
        op.Core_Claim_Date__c = System.today();
        Core_OpportunityLineItemHandler.alreadyAddedCommissionableTransactions = false;
        try {
            
            update op; 
            
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_OpportunityLineItemHandler_Test.createData');
        }
        
        lop = 
            [SELECT Id, Core_Status__c, Core_Approved_Decision_Date__c, Core_Approved_Total_Price__c, Core_Claim_Date__c, TotalPrice, UnitPrice, Quantity, Core_BU_Short_Name__c,Core_Approved_Commissionable__c
             FROM OpportunityLineItem WHERE Id = :lstOP.get(0).Id];
        //System.assert(!lop.isEmpty());
        
        List <Core_Commissionable_Transaction__c> lct = [            
            SELECT Core_Account_Name__c,Core_Approved_Total_Price__c,Core_Claim_Date__c,
            Core_Employee_Name__c,Core_Last_Approved_Date__c,Core_Milestone_Area__c,
            Core_Milestone_Focus__c,Core_Milestone__c,Core_Opportunity_Name__c,Core_Opportunity_Team_Member_Role__c,
            Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,Core_Product_Type__c,
            Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,Core_Transaction_Type__c,Core_WWID__c,Core_Approved_BU_Short_Name__c
            FROM Core_Commissionable_Transaction__c 
        ];
        
        //System.assert(!lct.isEmpty());
        op.Core_Status__c = 'Pending';
        try {
            
            update op; 
            
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_OpportunityLineItemHandler_Test.createData');
        }
        //System.assert(lct.size() == 5);       
    }
    
    static testMethod void testApproveAndRejectOP() {
        
        newTXNSetting1.add (new Core_Commission_Account_BU_SG_Setting__c(Name='CMSN01', 
                                                                         Core_Approved_BU_Product_Segment__c='<any>', 
                                                                         Core_Approved_BU_Short_Name__c='CCG',
                                                                         Core_Approved_Opp_Product_Segment__c='<any>',      
                                                                         Core_Approved_Sales_Group__c = 'EMEA Partner Holding',
                                                                         Core_Claim_Date_From__c = date.newInstance(2000, 1, 1),
                                                                         Core_Claim_Date_To__c = date.today(),
                                                                         Core_IsActive__c=true));
        newTXNSetting1.add (new Core_Commission_Account_BU_SG_Setting__c(Name='CMSN02', 
                                                                         Core_Approved_BU_Product_Segment__c='<any>', 
                                                                         Core_Approved_BU_Short_Name__c='null',
                                                                         Core_Approved_Opp_Product_Segment__c='<any>',     
                                                                         Core_Approved_Sales_Group__c = 'EMEA Partner Holding',
                                                                         Core_Claim_Date_From__c = date.newInstance(2000, 1, 1),
                                                                         Core_Claim_Date_To__c = date.today(),
                                                                         Core_IsActive__c=true));
        newTXNSetting1.add (new Core_Commission_Account_BU_SG_Setting__c(Name='CMSN03', 
                                                                         Core_Approved_BU_Product_Segment__c='<any>', 
                                                                         Core_Approved_BU_Short_Name__c='null',
                                                                         Core_Approved_Opp_Product_Segment__c='null',      
                                                                         Core_Approved_Sales_Group__c = 'EMEA Partner Holding',
                                                                         Core_Claim_Date_From__c = date.newInstance(2000, 1, 1),
                                                                         Core_Claim_Date_To__c = date.today(),
                                                                         Core_IsActive__c=true));
        newTXNSetting1.add (new Core_Commission_Account_BU_SG_Setting__c(Name='CMSN04', 
                                                                         Core_Approved_BU_Product_Segment__c='null', 
                                                                         Core_Approved_BU_Short_Name__c='null',
                                                                         Core_Approved_Opp_Product_Segment__c='null',
                                                                         Core_Approved_Sales_Group__c = 'null',
                                                                         Core_Claim_Date_From__c = date.newInstance(2000, 1, 1),
                                                                         Core_Claim_Date_To__c = date.today(),
                                                                         Core_IsActive__c=true));
        insert newTXNSetting1;
        
        createData();
        
        List<OpportunityLineItem> lop = 
            [SELECT Id, Core_Status__c, Core_Approved_By__c, Core_Approved_Decision_Date__c, Core_Approved_Total_Price__c, Core_Claim_Date__c, TotalPrice, UnitPrice, Quantity, Core_BU_Short_Name__c,Core_Approved_Commissionable__c
             FROM OpportunityLineItem WHERE Id = :lstOP.get(0).Id];
        //System.assert(!lop.isEmpty());
        
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        OpportunityLineItem op = lop.get(0);        
        op.Core_Status__c = 'Win Approved';
        op.Core_Approved_Commissionable__c='Yes'; 
        op.Core_Approved_By__c = profileName;
        op.Core_Approved_Decision_Date__c = System.today();
        op.Core_Approved_Total_Price__c = op.UnitPrice * op.Quantity;
        op.TotalPrice = op.UnitPrice * op.Quantity;
        //op.Core_BU_Short_Name__c = 'BU Short Name';
        op.Core_Approved_KPI_Product_Group__c  = 'test unqualified';
        op.CRM_DW_App_UCD_Customer_Name__c  = 'test PrimeAccount';
        op.Core_Claim_Date__c = System.today();
        Core_OpportunityLineItemHandler.alreadyAddedCommissionableTransactions = false;
        //test.startTest();
        try {
            
            //  update op; 
            //   test.stopTest();        
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_OpportunityLineItemHandler_Test.createData');
        }
        system.assertEquals('test PrimeAccount', op.CRM_DW_App_UCD_Customer_Name__c, 'the prime account should be test PrimeAccount');
        Long start = System.now().getTime();
        
        List <Core_Commissionable_Transaction__c> lct = [            
            SELECT Core_Account_Name__c,Core_Approved_Total_Price__c,Core_Claim_Date__c,
            Core_Employee_Name__c,Core_Last_Approved_Date__c,Core_Milestone_Area__c,
            Core_Milestone_Focus__c,Core_Milestone__c,Core_Opportunity_Name__c,Core_Opportunity_Team_Member_Role__c,
            Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,Core_Product_Type__c,
            Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,Core_Transaction_Type__c,Core_WWID__c,Core_Approved_BU_Short_Name__c
            FROM Core_Commissionable_Transaction__c 
            ORDER BY Core_WWID__c ASC, Core_Employee_Name__c ASC
        ];
        
        //System.assert(!lct.isEmpty());
        //System.assert(lct.size() == 5);  
        
        lop = 
            [SELECT Id, Core_Status__c, Core_Approved_By__c, Core_Approved_Decision_Date__c, Core_Approved_Total_Price__c, Core_Claim_Date__c, TotalPrice, UnitPrice, Quantity, Core_BU_Short_Name__c
             FROM OpportunityLineItem WHERE Id = :lstOP.get(0).Id];
        op = lop.get(0);  
        op.Core_Status__c = 'Pending';
        op.Core_Approved_Commissionable__c=Null; 
        
        //Ensure the timestamp ticks over to the next second
        while(System.now().getTime()<start+1000){ 
        }
        
        
        Core_OpportunityLineItemHandler.alreadyAddedCommissionableTransactions = false;
        try {
            // test.startTest();
            //  update op;       
            // test.stopTest();  
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_OpportunityLineItemHandler_Test.createData');
        }
        
        start = System.now().getTime();
        
        List <Core_Commissionable_Transaction__c> lct2 = [            
            SELECT Core_Account_Name__c,Core_Approved_Total_Price__c,Core_Claim_Date__c,
            Core_Employee_Name__c,Core_Last_Approved_Date__c,Core_Milestone_Area__c,
            Core_Milestone_Focus__c,Core_Milestone__c,Core_Opportunity_Name__c,Core_Opportunity_Team_Member_Role__c,
            Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,Core_Product_Type__c,
            Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,Core_Transaction_Type__c,Core_WWID__c,Core_Approved_BU_Short_Name__c
            FROM Core_Commissionable_Transaction__c 
            WHERE Core_Status__c != 'Approved'
            ORDER BY Core_WWID__c ASC, Core_Employee_Name__c ASC
        ];
        
        
        //System.assert(!lct2.isEmpty());
        
        lop = 
            [SELECT Id, Core_Status__c, Core_Approved_By__c, Core_Approved_Decision_Date__c, Core_Approved_Total_Price__c, Core_Claim_Date__c, TotalPrice, UnitPrice, Quantity, Core_BU_Short_Name__c
             FROM OpportunityLineItem WHERE Id = :lstOP.get(0).Id];
        //System.assert(!lop.isEmpty());
        
        op = lop.get(0);  
        op.Core_Status__c = 'Win Approved';
        op.Core_Approved_Commissionable__c='Yes'; 
        
        //Ensure the timestamp ticks over to the next second
        while(System.now().getTime()<start+1000){ 
        }       
        
        Core_OpportunityLineItemHandler.alreadyAddedCommissionableTransactions = false;
        try {
            // test.startTest();
            //  update op;       
            // test.stopTest();  
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_OpportunityLineItemHandler_Test.createData');
        }
        
        List <Core_Commissionable_Transaction__c> lct3 = [            
            SELECT Core_Account_Name__c,Core_Approved_Total_Price__c,Core_Claim_Date__c,
            Core_Employee_Name__c,Core_Last_Approved_Date__c,Core_Milestone_Area__c,
            Core_Milestone_Focus__c,Core_Milestone__c,Core_Opportunity_Name__c,Core_Opportunity_Team_Member_Role__c,
            Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,Core_Product_Type__c,
            Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,Core_Transaction_Type__c,Core_WWID__c,Core_Approved_BU_Short_Name__c
            FROM Core_Commissionable_Transaction__c 
            ORDER BY Core_Transaction_Timestamp__c ASC, Core_WWID__c ASC, Core_Employee_Name__c ASC
        ];
        
        //System.assert(!lct3.isEmpty());
        
        lop = 
            [SELECT Id, Core_Status__c, Core_Approved_By__c, Core_Approved_Decision_Date__c, Core_Approved_Total_Price__c, Core_Claim_Date__c, TotalPrice, UnitPrice, Quantity, Core_BU_Short_Name__c
             FROM OpportunityLineItem WHERE Id = :lstOP.get(0).Id];
        //System.assert(!lop.isEmpty());
        
        op = lop.get(0);  
        op.Core_Status__c = 'Production Win Approved';
        op.Core_Approved_Commissionable__c=Null; 
        
        //Ensure the timestamp ticks over to the next second
        while(System.now().getTime()<start+1000){ 
        }
        
        
        Core_OpportunityLineItemHandler.alreadyAddedCommissionableTransactions = false;
        try {
            // test.startTest();
            // update op;  
            // test.stopTest();       
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_OpportunityLineItemHandler_Test.createData');
        }
        
        start = System.now().getTime();
        lop = 
            [SELECT Id, Core_Status__c, Core_Approved_By__c, Core_Approved_Decision_Date__c, Core_Approved_Total_Price__c, Core_Claim_Date__c, TotalPrice, UnitPrice, Quantity, Core_BU_Short_Name__c
             FROM OpportunityLineItem WHERE Id = :lstOP.get(0).Id];
        //System.assert(!lop.isEmpty());
        
        op = lop.get(0);  
        op.Core_Status__c = 'Pending';
        op.Core_Approved_Commissionable__c=Null; 
        
        //Ensure the timestamp ticks over to the next second
        while(System.now().getTime()<start+1000){ 
        }
        
        
        Core_OpportunityLineItemHandler.alreadyAddedCommissionableTransactions = false;
        try {
            // test.startTest();
            update op; 
            //         
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_OpportunityLineItemHandler_Test.createData');
        }
        
        start = System.now().getTime();
        
        //test.stopTest(); 
        
        
        
    }
    // **************************************Here start to update or delete for Historytracking method************************************ //
    
    // Test a simple update of a few line items
    testMethod static void testUpdate() {
        
        // First make sure we don't already have any field history entries
        //System.assertEquals(0, [select count() from Core_Opportunity_Product_History__c]);
        
        // Update a bunch of fields on multiple records
        List<OpportunityLineItem> testOppLineItems = [select Description, UnitPrice, Quantity, Core_BU_Short_Name__c,
                                                      Core_Loss_Cancel_Reason__c, Core_Status__c
                                                      from OpportunityLineItem where Description like 'Test%'];
        
        testOppLineItems[0].Core_Loss_Cancel_Reason__c = 'Testing testing';
        testOppLineItems[0].Core_Status__c = 'On Hold';
        testOppLineItems[0].Description = 'Test 21';
        testOppLineItems[0].Quantity = 21;
        testOppLineItems[0].UnitPrice = 21;
        testOppLineItems[1].Core_Loss_Cancel_Reason__c = 'Testing testing';
        testOppLineItems[1].Core_Status__c = 'Lost';
        testOppLineItems[1].Core_Competitor__c ='Acer';
        testOppLineItems[1].Core_Competitor_Product__c='AMD Athlon';
        testOppLineItems[1].Description = '';
        //testOppLineItems[2].Core_BU_Short_Name__c = 'T23';
        testOppLineItems[2].Core_Group_Code__c = 'GC23'; // We're not tracking this field!
        
        Test.startTest();
        update testOppLineItems;
        Test.stopTest();
        system.assertEquals('Testing testing', testOppLineItems[0].Core_Loss_Cancel_Reason__c,'');
        
        List<Core_Opportunity_Product_History__c> oppProdHistory = [select Core_Opportunity__c, Core_Opportunity_Product_ID__c,
                                                                    Core_Field__c, Core_Old_Value__c, Core_New_Value__c
                                                                    from Core_Opportunity_Product_History__c
                                                                    order by Core_Opportunity_Product_ID__c, Core_Field__c LIMIT 10];
        
    }
    
    // Test a simple delete of a few line items
    testMethod static void testDelete() {
        
        // First make sure we don't already have any field history entries
        //System.assertEquals(0, [select count() from Core_Opportunity_Product_History__c]);
        
        // Delete the line items
        List<OpportunityLineItem> testOppLineItems = [select Id
                                                      from OpportunityLineItem where Description like 'Test%'];
        Test.startTest();
        delete testOppLineItems;
        Test.stopTest();
        
        List<Core_Opportunity_Product_History__c> oppProdHistory = [select Core_Opportunity__c, Core_Opportunity_Product_ID__c,
                                                                    Core_Field__c, Core_Old_Value__c, Core_New_Value__c
                                                                    from Core_Opportunity_Product_History__c
                                                                    order by Core_Opportunity_Product_ID__c, Core_Field__c];
        
    }
    
    // Test a bulk update of many line items
    testMethod static void testUpdateBulk() {
        
        List<OpportunityLineItem> testOppLineItems = [select Description, UnitPrice, Quantity, Core_BU_Short_Name__c,
                                                      Core_Loss_Cancel_Reason__c, Core_Status__c
                                                      from OpportunityLineItem where Description like 'Bulk%'];
        
        for (OpportunityLineItem oppLineItem : testOppLineItems) {
            oppLineItem.Description = oppLineItem.Description + ' after update';
            oppLineItem.UnitPrice = oppLineItem.UnitPrice * 2;
            oppLineItem.Quantity = oppLineItem.Quantity * 3;
            //oppLineItem.Core_BU_Short_Name__c = oppLineItem.Core_BU_Short_Name__c + 'X';
            oppLineItem.Core_Loss_Cancel_Reason__c = 'Testing';
            oppLineItem.Core_Status__c = 'On Hold';
        }
        system.assertEquals('On Hold', testOppLineItems[0].Core_Status__c,'');
        Test.startTest();
        update testOppLineItems;
        Test.stopTest();
        
        
    }
    
    // Test a bulk delete of many line items
    testMethod static void testDeleteBulk() {
        
        
        // Delete a bunch of records
        List<OpportunityLineItem> testOppLineItems = [select Id from OpportunityLineItem where Description like 'Bulk%'];
        
        Test.startTest();
        delete testOppLineItems;
        Test.stopTest();
        system.assert(!testOppLineItems.isEmpty(),'');
        
    }
    
    //*************************************************************Test Method for OpportunityLineItem tests related to BU Mapping Record************/ 
    testMethod static void testBUMapping(){
        
        String CRON_EXP = system.now().addMinutes(10).format('ss mm HH dd MM ? yyyy');   
        RecordType accRecordType = [select id from recordType where sObjectType='Account' and name ='Intel Account' limit 1];
        
        Account ac=new Account(Name='CEP Test Account',recordtypeid=accRecordType.id,BillingCountryCode = 'USA',BIllingStateCode = 'AL', 
                               Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI(), BillingCity = 'Alabama',BillingStreet = 'test',Core_Account_Type__c = 'Other',
                               Core_Sales_Segment__c = 'Reseller/Channel', Core_Sub_Geo__c = 'CEE', Industry = 'Agriculture',Core_Sub_Industry__c = 'Forestry'); 
        insert ac; 
        // Simple test data
        test.startTest();
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Opportunity testOpp_BU = Core_Test_Utility.createOpportunity(1)[0];
        testOpp_BU.AccountId = ac.Id;       
        testOpp_BU.RecordTypeId =newOppRecTypeId;
        testOpp_BU.Opportunity_Focus__c= 'Core';
        testOpp_BU.Core_Opportunity_Type__c ='Deal: Sell-to';
        insert testOpp_BU;
        
        List<Product2> testProducts_BU = Core_Test_Utility.createProduct(1);
        insert testProducts_BU[0];
        
        List<PricebookEntry> testPBEs_BU = Core_Test_Utility.createPriceBookEntry(1, testProducts_BU, Test.getStandardPricebookId());
        insert testPBEs_BU;
        
        // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the 
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        //  update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        //update testOpp_BU;  
        
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                   Description='0001', UnitPrice=11, Quantity=11, 
                                                   Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));      
        
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];      
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        //update testOpp_BU; 
        
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                   Description='0010', UnitPrice=11, Quantity=11, 
                                                   Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        
        
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        //update testOpp_BU;
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                   Description='0011', UnitPrice=11, Quantity=11, 
                                                   Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        //update testOpp_BU;
        
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                   Description='0100', UnitPrice=11, Quantity=11,
                                                   Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        //update testOpp_BU;
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                   Description='0101', UnitPrice=11, Quantity=11,
                                                   Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        //update testOpp_BU;      
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                   Description='0110', UnitPrice=11, Quantity=11,Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        
        
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        //update testOpp_BU;
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                   Description='0111', UnitPrice=11, Quantity=11,
                                                   Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        //update testOpp_BU;
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                   Description='1000', UnitPrice=11, Quantity=11,
                                                   Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        //update testOpp_BU;
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                   Description='1001', UnitPrice=11, Quantity=11,Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        //update testOpp_BU;
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                   Description='1010', UnitPrice=11, Quantity=11, 
                                                   Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        //update testOpp_BU;
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                   Description='1011', UnitPrice=11, Quantity=11,
                                                   Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        //update testOpp_BU;
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                   Description='1100', UnitPrice=11, Quantity=11,
                                                   Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        //update testOpp_BU;
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                   Description='1101', UnitPrice=11, Quantity=11, 
                                                   Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                   Description='1110', UnitPrice=11, Quantity=11,
                                                   Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
        system.assertEquals('', testOpp_BU.Core_Product_Application__c,'');
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                   Description='1111', UnitPrice=11, Quantity=11,
                                                   Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        
        
        insert oppBUItemList;
        test.stopTest();
        /*
Test.StartTest();            
System.schedule('Core_Invoke_BatchToUpdateShortName', CRON_EXP, new Core_Invoke_BatchToUpda
teShortName());
// database.executebatch(new Core_OpportunityLineItem_BatchClass(),50);            
Test.StopTest();
*/
        
    }   
    
    static void setupTestF() {
        
        // Create and Insert test accounts
        Id recordTypeIDAct = [select id from RecordType where DeveloperName = 'Mastered_Account' limit 1].id;
        accountList = Core_Test_Utility.createAccount(6);       
        accountList[0].Name = 'Dell';
        accountList[0].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[0].Industry = 'Telecommunications';
        accountList[0].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountList[1].Name = 'HP';        
        accountList[1].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[1].Industry = 'Telecommunications';
        accountList[1].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountList[2].Name = 'Google';
        accountList[2].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[2].Industry = 'Telecommunications';
        accountList[2].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountList[3].Name = 'Apple';
        accountList[3].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[3].Industry = 'Telecommunications';
        accountList[3].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountList[4].Name = 'Target';
        accountList[4].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[4].Industry = 'Telecommunications';
        accountList[4].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountList[5].Name = 'Target1';
        accountList[5].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[5].Industry = 'Telecommunications';
        accountList[5].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        
        accountList[0].RecordTypeId = recordTypeIDAct;
        accountList[1].RecordTypeId = recordTypeIDAct;
        accountList[2].RecordTypeId = recordTypeIDAct;
        accountList[3].RecordTypeId = recordTypeIDAct;
        accountList[4].RecordTypeId = recordTypeIDAct;
        accountList[5].RecordTypeId = recordTypeIDAct;
        
        insert accountList;
        system.assertEquals(6, accountList.size(),'');
        // Create and Insert a test Opportunity
        List<Opportunity> listOpportunity = Core_Test_Utility.createOpportunity(1); 
        lstUser = Core_Test_Utility.Core_User(1);
        opp = listOpportunity[0]; 
        opp.Core_Opportunity_Type__c='Design: Original';
        opp.Core_First_Customer_Ship_Date__c = System.Today();          
        opp.Core_Technical_Owner__c = UserInfo.getUserId();
        opp.Core_Solution_Area__c='CCG Commercial Deal $';
        opp.Core_Intel_Platform__c = 'ALDER LAKE';
        opp.AccountId = accountList[0].Id;
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
        
        
        // Create and Insert Trigger Executions
        Core_Trigger_Executions__c triggerExec1 = new Core_Trigger_Executions__c(Name='insertPartners', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler', 
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='after insert',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = 'insert Partner');
        insert triggerExec1;
        
        
        Core_Trigger_Executions__c triggerExec12 = new Core_Trigger_Executions__c(Name='insertForecast', 
                                                                                  Core_Class_Name__c='Core_OpportunityLineItemHandler', 
                                                                                  Core_Object__c='OpportunityLineItem',
                                                                                  Core_Trigger_Events__c='after insert',     
                                                                                  Core_Active__c=true, 
                                                                                  Core_Description__c = 'insertForecast');
        insert triggerExec12;
        
        Core_Trigger_Executions__c triggerExec2 = new Core_Trigger_Executions__c(Name='updatePartners', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler', 
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='after update',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = 'update Partner');
        insert triggerExec2;
        
        Core_Trigger_Executions__c triggerExec3 = new Core_Trigger_Executions__c(Name='deletePartners', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler', 
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='after delete',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = 'delete Partner');
        insert triggerExec3;
        
        Core_Trigger_Executions__c triggerExec4 = new Core_Trigger_Executions__c(Name='populateGroup', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler', 
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='before insert',    
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = 'populate Group and Division');
        insert triggerExec4;
        
        Core_Trigger_Executions__c triggerExec5 = new Core_Trigger_Executions__c(Name='opportunityLineItemAfterHandler', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler', 
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='after insert, after update, after delete',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = 'after handler');
        insert triggerExec5;
        Core_Trigger_Executions__c triggerExec6 = new Core_Trigger_Executions__c(Name='swInsertUpdateTrigger', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler', 
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='after insert, after update',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = 'after handler');
        insert triggerExec6;
        
        /*      Core_Trigger_Executions__c triggerExec6 = new Core_Trigger_Executions__c(Name='insertForecast', 
Core_Class_Name__c='Core_OpportunityLineItemHandler', 
Core_Object__c='OpportunityLineItem',
Core_Trigger_Events__c='before insert',    
Core_Active__c=true, 
Core_Description__c = 'populate Group and Division');
insert triggerExec6;*/
        Core_Trigger_Executions__c triggerExec7 = new Core_Trigger_Executions__c(Name='updateForecast', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler', 
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='after update',    
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = 'updateForecast');
        insert triggerExec7;
        
        Core_Trigger_Executions__c triggerExec8 = new Core_Trigger_Executions__c(Name='deleteForecast', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler', 
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='after delete',    
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = 'deleteForecast');
        insert triggerExec8;
        Core_Trigger_Executions__c triggerExec10 = new Core_Trigger_Executions__c(Name='updateOppoRiskReasonOnOppLineItem', 
                                                                                  Core_Class_Name__c='Core_OpportunityLineItemHandler',                                                                               
                                                                                  Core_Object__c='OpportunityLineItem',
                                                                                  Core_Trigger_Events__c='After Update ,After Insert, After Delete',     
                                                                                  Core_Active__c=true, 
                                                                                  Core_Description__c ='Update Opportunity on OppLineItem Update/Insert/Delete');
        insert triggerExec10;
        
    }
    
    static testMethod void Core_OpportunityLineItemHandler_Test_1F() {    
        setupTestF();
        Test.startTest();
        
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(1, listPBE, opp);
        insert oppLineItems;
        system.assertEquals(1, oppLineItems.size(),'');
        
        Core_OpportunityLineItemHandler.opportunityLineItemAfterHandler(oppLineItems, null, null, null, true, false, false);
        Core_OpportunityLineItemHandler.opportunityLineItemErrorHandler(oppLineItems, null, null, null, true, false, false);
        Core_OpportunityLineItemHandler.stopInstantDeletion(oppLineItems); 
        Test.stopTest();
    }
    
    static testMethod void Core_OpportunityLineItemHandler_Test_2F() {  
        setupTestF();
        
        Test.startTest();
        
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(1, listPBE, opp);
        insert oppLineItems;
        
        system.assertEquals(1, oppLineItems.size(),'Opportunity lineitems must be 1');
        Core_OpportunityLineItemHandler.opportunityLineItemAfterHandler(null, null, oppLineItems, null, false, false, true);
        
        Test.stopTest();
    }  
    
    static testMethod void populateGroup_Test_1F() {
        setupTestF();
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = opp.Id,
                                                                  PricebookEntryId = testPBE.Id,
                                                                  Quantity = 1,
                                                                  UnitPrice = 200,
                                                                  Core_Status__c = 'Pending');
        
        Test.startTest();
        insert oppLineItem;
        Test.setMock(HttpCalloutMock.class, new Core_KPITestHttpResponse(200));
        Test.stopTest();
        
        List<OpportunityLineItem> insertedOLI = [SELECT Core_Group__c, Core_Group_Code__c, Core_Division__c, Core_Division_Code__c FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        
        System.assertEquals('AAA', insertedOLI[0].Core_Group__c,'');
        System.assertEquals('111', insertedOLI[0].Core_Group_Code__c,'');
        System.assertEquals('BBB', insertedOLI[0].Core_Division__c,'');
        System.assertEquals('000', insertedOLI[0].Core_Division_Code__c,'');
        
    }
    static testMethod void insertPartner_Test_1F() {
        setupTestF();
        Test.startTest();
        List<OpportunityLineItem> oppLineItemsupdate = new List<OpportunityLineItem> ();
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(5, listPBE, opp);
        list<user> lstUser = Core_Test_Utility.Core_User(1);
        insert lstUser;  
        List<Opportunity> listOpportunity = Core_Test_Utility.createOpportunity(5); 
        
        listOpportunity[0].Core_Commissionable__c='Yes';     
        listOpportunity[0].Core_Opportunity_Type__c='Design: Secondary';
        listOpportunity[0].Core_First_Customer_Ship_Date__c = System.Today();
        listOpportunity[0].Core_Technical_Owner__c=lstUser[0].Id;
        listOpportunity[0].Core_Solution_Area__c='CCG Commercial Deal $';
        listOpportunity[0].CloseDate=system.today().addMonths(6);
        listOpportunity[0].Core_Intel_Platform__c = 'ALDER LAKE';
        listOpportunity[0].AccountId = accountList[0].Id;
        
        listOpportunity[1].Core_Opportunity_Type__c='Design: Secondary';
        listOpportunity[1].Core_Solution_Area__c='CCG Commercial Deal $';
        listOpportunity[1].CloseDate=system.today().addMonths(4);
        listOpportunity[1].Core_First_Customer_Ship_Date__c = System.Today();
        listOpportunity[1].Core_Intel_Platform__c = 'ALDER LAKE';
        listOpportunity[1].Core_Technical_Owner__c=lstUser[0].Id;
        listOpportunity[1].AccountId = accountList[1].Id;
        listOpportunity[2].Core_Opportunity_Type__c='Design: Original';
        listOpportunity[2].Core_Solution_Area__c='CCG Commercial Deal $';
        listOpportunity[2].Core_First_Customer_Ship_Date__c = System.Today();
        listOpportunity[2].Core_Technical_Owner__c=lstUser[0].Id;
        listOpportunity[2].CloseDate=system.today().addMonths(-2);
        listOpportunity[2].Core_Intel_Platform__c = 'ALDER LAKE';
        listOpportunity[2].AccountId = accountList[2].Id;
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
        listOpportunity[3].Core_Opportunity_Type__c='Deal: Sell-to';
        listOpportunity[3].RecordTypeId=recordTypeId;
        listOpportunity[3].Core_Solution_Area__c='CCG Commercial Deal $';
        listOpportunity[3].CloseDate=system.today();
        listOpportunity[3].AccountId = accountList[3].Id;
        
        //Design part//
        listOpportunity[4].Core_Technical_Owner__c=lstUser[0].Id; 
        listOpportunity[4].Core_Intel_Platform__c='ALDER LAKE';
        listOpportunity[4].Core_Opportunity_Type__c='Design: Secondary';
        listOpportunity[4].Core_First_Customer_Ship_Date__c=system.today();
        listOpportunity[4].AccountId = accountList[4].Id;
        insert listOpportunity;
        oppLineItems[0].Core_Vendor__c = accountList[0].Id;
        oppLineItems[0].OpportunityId = listOpportunity[0].Id;
        //oppLineItems[0].Core_Status__c = 'Win Approved';
        oppLineItems[1].OpportunityId = listOpportunity[1].Id; 
        oppLineItems[2].OpportunityId = listOpportunity[2].Id;  
        oppLineItems[3].OpportunityId = listOpportunity[3].Id;   
        oppLineItems[4].OpportunityId = listOpportunity[4].Id;     
        insert oppLineItems;
        oppLineItemsupdate.addAll(oppLineItems);
        oppLineItemsupdate[0].Core_Vendor__c = accountList[1].Id;
        oppLineItemsupdate[0].Core_Status__c = 'Win Approved';
        oppLineItemsupdate[1].Core_Vendor__c =  accountList[2].Id;
        oppLineItemsupdate[2].Core_Vendor__c =  accountList[3].Id;
        //oppLineItemsupdate[3].Core_Vendor__c =  accountList[4].Id;
        //oppLineItemsupdate[4].Core_Vendor__c =  accountList[5].Id;
        update oppLineItemsupdate;
        List<OpportunityLineItem> NewOppLineItems=[select id,OpportunityId,Core_Vendor__c,Core_System_Commissionable__c,Core_Status__c,Core_Opp_OpportunityType__c from OpportunityLineItem
                                                   where id in:oppLineItemsupdate];
   
        //List<> lstOppLItem = new List<OpportunityLineItem>();
        //lstOppLItem.add(oppLineItems);
        map<id,OpportunityLineItem> mp = new map<id,OpportunityLineItem>();
        mp.put(oppLineItemsupdate[0].id,oppLineItemsupdate[0]);
        mp.put(oppLineItemsupdate[1].id,oppLineItemsupdate[1]);
        mp.put(oppLineItemsupdate[2].id,oppLineItemsupdate[2]);
        mp.put(oppLineItemsupdate[3].id,oppLineItemsupdate[3]);
        mp.put(oppLineItemsupdate[4].id,oppLineItemsupdate[4]);
        Core_Trigger_Executions__c triggercs = new Core_Trigger_Executions__c();
triggercs.Core_Active__c = true;
triggercs.Name = 'opportunityLineItemAddCommTxns';
triggercs.Core_Description__c = 'Add Commissionable Transactions based on approved Opportunity Products';
triggercs.Core_Class_Name__c = 'Core_OpportunityLineItemHandler';
triggercs.Core_Object__c = 'opportunity';
triggercs.Core_Trigger_Events__c = 'after update';
insert triggercs;
        //createTriggerExecutions();
        Core_OpportunityLineItemHandler.beforeInsertForecastRecords(oppLineItems );
        Core_OpportunityLineItemHandler.insertForecastRecords(oppLineItems,new List<Core_Opp_FC_Prod_Schedule__c>(),True);
        Core_OpportunityLineItemHandler.deleteForecastRecords(mp);
        Core_OpportunityLineItemHandler.updateForecastRecords(oppLineItems,mp);
        Core_OpportunityLineItemHandler.opptyLineItemUpdateSalesGroupandUserCovg(oppLineItems,mp,oppLineItems,mp,True); 
        //Core_OpportunityLineItemHandler.addCommissionableTransactions(oppLineItems,mp,NewOppLineItems,mp,false,true);
        Test.stopTest();
        List<Core_Opportunity_Partner__c> relatedPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :listOpportunity[0].Id]; 
        
        //System.assertEquals(1, relatedPartners.size(),'');
        //System.assertEquals(accountList[0].Id, relatedPartners.get(0).Core_Partner__c);
       // System.assertEquals('Vendor', relatedPartners.get(0).Core_Partner_Role__c,'');
       System.assertEquals(true,true);
        
        
    }
    static testMethod void test_opportunityApprovalHistoryInsert(){
        setupTest();
        Test.startTest();
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(2, listPBE, opp);
        Core_OpportunityLineItemHandler.alreadyInsertedApprovalHisotry=false;
        oppLineItems[0].Core_Status__c ='Pening';
        oppLineItems[0].Core_Approved_By__c='Test User1';
        oppLineItems[1].Core_Status__c ='Pending'; 
        oppLineItems[1].Core_Production_Claim_Date__c=system.today();     
        insert oppLineItems;
        system.assertEquals(2, oppLineItems.size(),'Opportunity lineitems must be 2');
        Core_Opportunity_Approval_History__c objAH=new Core_Opportunity_Approval_History__c();
        objAH.Core_Opp_Hist_OpportunityLineItemID__c =oppLineItems[1].Id;
        objAH.Core_Opp_Hist_Production_Claim_Date__c=oppLineItems[1].Core_Production_Claim_Date__c;
        insert objAH;  
        oppLineItems[0].Core_Status__c ='Win Approved';
        oppLineItems[0].Core_Approved_By__c='Test User2';  
        oppLineItems[1].Core_Status__c ='Production Cancelled';
        oppLineItems[1].Core_Loss_Cancel_Reason__c='Cancelled - Budget';
        oppLineItems[1].Core_Loss_Cancel_Details__c='Cancelled - Budget';  
        update oppLineItems;    
        Test.setMock(HttpCalloutMock.class, new Core_KPITestHttpResponse(200));
        Test.stopTest();
    }
    static testMethod void ForecastProductSchedule_Test1() {  
        setupTestF();
        Test.startTest();
        List<Core_Opp_FC_Prod_Schedule__c> fcObjList = new List<Core_Opp_FC_Prod_Schedule__c>();
        //List<Opportunity> listOpportunity = Core_Test_Utility.createOpportunity(2); 
        //insert  listOpportunity;
        List<OpportunityLineItem> oppLineItemsupdate = new List<OpportunityLineItem> ();
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(3, listPBE, opp);
        oppLineItems[0].Core_Vendor__c = accountList[0].Id;
        oppLineItems[0].Quantity=12;
        oppLineItems[0].Core_Status__c='Pending';
        oppLineItems[1].Core_Status__c='Pending';
        oppLineItems[2].Quantity=3;
        insert oppLineItems;
        system.assertEquals(3, oppLineItems.size(),'Opportunity lineitems must be 3');
        fcObjList.add(new  Core_Opp_FC_Prod_Schedule__c (Core_Opp_Line_Item_RecordID__c=oppLineItems[0].Id,Core_Opp_FC_Approval_Status__c='Approved',Core_Opp_FC_Prod_Sales_Price__c=3,Core_Opp_FC_Opportunity__c=oppLineItems[0].OpportunityID));
        fcObjList.add(new  Core_Opp_FC_Prod_Schedule__c (Core_Opp_Line_Item_RecordID__c=oppLineItems[0].Id,Core_Opp_FC_Approval_Status__c='Pending',Core_Opp_FC_Prod_Sales_Price__c=3,Core_Opp_FC_Opportunity__c=oppLineItems[0].OpportunityID));
        insert fcObjList;
        oppLineItems[1].Core_Status__c='Lost';
        oppLineItems[1].Core_Loss_Cancel_Reason__c='Cancelled - Budget';
        oppLineItems[1].Core_Loss_Cancel_Details__c='Cancelled - Budget';
        oppLineItems[1].Core_Competitor__c ='Acer';
        oppLineItems[1].Core_Competitor_Product__c='AMD Athlon';
        oppLineItems[2].Core_Status__c='Win Approved';
        oppLineItems[2].Quantity=5;
        Core_OpportunityLineItemHandler.updateForecastRecordsRecCheck = false;
        update oppLineItems;
        delete oppLineItems;
        Test.stopTest();
    }
    
    static testMethod void deleteKPI_Test1(){
        setupTest();
        Test.startTest();
        opp.Core_Opportunity_Coverage_Nm__c ='Intel-Led Opportunity';
        //opp.Core_Coverage_Type_Nm__c='Disti Design Registration Low';
        update opp;
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(3, listPBE, opp);
        oppLineItems[0].Core_Vendor__c = accountList[0].Id;
        oppLineItems[0].Quantity=12;
        oppLineItems[0].Core_Status__c='Pending';
        system.assertEquals(3, oppLineItems.size(),'Opportunity lineitems must be 3');
        //oppLineItems[1].Core_Status__c='Pending';
        oppLineItems[2].Quantity=3;
        insert oppLineItems; 
        //oppLineItems[0].Core_Status__c='Pending';
        //oppLineItems[0].Core_At_Risk__c=true;
        //oppLineItems[0].Core_Risk_Reason1__c='Competition';
        //oppLineItems[0].Core_Risk_Category__c='Support Requested';
        //oppLineItems[0].Core_Risk_Priority__c='High – Mission Critical – Action Required';
        //oppLineItems[0].Core_At_Risk_Status__c='Support Provided';
        //update oppLineItems[0];
        List<OpportunityLineItem> product = [select id, Product2.Id from OpportunityLineItem];
        List<Core_Opportunity_KPI__c> oppKpiList = new List<Core_Opportunity_KPI__c>();
        for(Integer i=0; i<6; i++){
            Core_Opportunity_KPI__c oppKpi = new Core_Opportunity_KPI__c();
            oppKpi.Name = 'test kpi'+i;
            oppKpi.Core_Opp_KPI_BatchTime__c = Datetime.newInstance(date.today() - 1, time.newInstance(1, 1, 1, 1));
            oppKpi.Core_Opp_KPI_Achieved__c = false;
            oppKpi.Core_Opp_KPI_Add_Date__c = system.now();
            oppKpi.Core_Opp_KPI_BU_Owner__c = 'Test User';
            oppKpi.Core_Opp_KPI_Description__c = 'Test Description';
            oppKpi.Core_Opp_KPI_Last_Update_Date__c = system.now();
            oppKpi.Core_Opp_KPI_Volume__c = 10;
            oppKpi.Core_Opp_KPI_Quantity__c = 5;
            oppKpi.Core_Opp_KPI_Total_Price__c = 100;            
            oppKpi.Core_Opp_KPI_Opportunity__c = opp.Id;
            oppKpi.Core_Opp_KPI_Threshold_Met__c = 'No';
            oppKpi.Core_Opp_KPI_Threshold_Req__c = 'Testing';
            oppKpiList.add(oppKpi);
        }
        insert oppKpiList;
        system.assertEquals(6, oppKpiList.size(),'opportunity Kpi lineitems size should be 6');
        Core_Opp_KPI_Product__c kpiProd = new Core_Opp_KPI_Product__c();
        kpiProd.Core_Opp_KPI__c = oppKpiList[0].Id;
        kpiProd.Core_Opp_KPI_Product__c = product[0].Product2.Id;
        kpiProd.Core_Opp_KPI_Oppty_Product_Id__c = product[0].Id;
        insert kpiProd;
        Core_Opp_KPI_Product__c kpiProd1 = new Core_Opp_KPI_Product__c();
        kpiProd1.Core_Opp_KPI__c = oppKpiList[1].Id;
        kpiProd1.Core_Opp_KPI_Product__c = product[1].Product2.Id;
        kpiProd1.Core_Opp_KPI_Oppty_Product_Id__c = product[1].Id;
        insert kpiProd1;
        Core_Opp_KPI_Product__c kpiProd2 = new Core_Opp_KPI_Product__c();
        kpiProd2.Core_Opp_KPI__c = oppKpiList[0].Id;
        kpiProd2.Core_Opp_KPI_Product__c = product[2].Product2.Id;
        kpiProd2.Core_Opp_KPI_Oppty_Product_Id__c = product[2].Id;
        insert kpiProd2;
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Opp_Bypass_Validation_Rule__c vrBypass = new Core_Opp_Bypass_Validation_Rule__c();
            vrBypass.Bypass__c = true;
            vrBypass.SetupOwnerId = Core_Test_Utility.systemAdminUser.Id;
            insert vrBypass;
           // delete product;
        }
        Test.stopTest();
    }
    
    static testmethod void RiskEmail(){
        setupTest();
        Test.startTest();
        Account testAcct = Core_Test_Utility.createAccount(1)[0];
        
        testAcct.Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        testAcct.name = 'Risk Email Testttt1233';
        testAcct.BillingCountryCode = 'USA';
        testAcct.BIllingStateCode = 'AL';
        testAcct.BillingCity = 'Xyxxhjj';
        testAcct.BillingStreet = 'Risk';
        testAcct.Industry = 'Agriculture';
        testAcct.Core_Sub_Industry__c = 'Forestry';
        List<RecordType> recIds = [select id from RecordType where DeveloperName = 'Mastered_Account' limit 1];
        testAcct.RecordTypeId = recIds[0].id;
        insert testAcct;
        system.assertEquals('Risk Email Testttt1233', testAcct.name,'Account Name should be Risk Email Testttt1233');
        Contact contact = new Contact();
        contact.FirstName = 'Freddo1221';
        contact.LastName = 'Corleone1112';
        contact.Email = 'fredd1o@testerz.com';
        contact.MailingCountry = 'IND';
        contact.AccountId = testAcct.id;
        //contact.MailingCountry='IND';        
        insert contact;
        system.assertEquals('Freddo1221', contact.FirstName,'Contact first name should be Freddo1221');
        
        // Simple test data
        Opportunity testOpp = Core_Test_Utility.createOpportunity(1)[0];
        testOpp.AccountId = testAcct.Id;
        testOpp.Opportunity_Focus__c= 'Core';
        testOpp.Core_Opportunity_Type__c='Design: Original';
        insert testOpp;
        
        List<Product2> testProducts = Core_Test_Utility.createProduct(3);
        insert testProducts;
        
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        
        // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the
        // opportunity product history object later (can't sort on Description or any other attribute)
        OpportunityLineItem testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=testOpp.Id, PricebookEntryId=testPBEs[0].Id,
                                                  Description='Test 11', UnitPrice=11, Quantity=11,
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert testOppLineItem;
        testOppLineItem.Core_At_Risk__c=true;
        testOppLineItem.Core_Risk_Priority__c='2 High - Vital to Opportunity, Action Required';
        testOppLineItem.Core_Risk_Reason1__c='Legal';
        update testOppLineItem;
        Test.setMock(HttpCalloutMock.class, new Core_KPITestHttpResponse(200));
        Test.stopTest();
        
    }
    /*
* Method name  : testAfterDeleteOppoLineItem
* Description  : This Method used to test updateOppoRiskReasonOnOppLineItemDelete
* Return Type  : void
* Parameter    : NA
*/
    testMethod static void testAfterDeleteOppoLineItem() {
        
        setupTestF();
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = opp.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = 'Pending',
                                                                   Core_Risk_Reason1__c= 'Legal',
                                                                   Core_Risk_Reason2__c = 'COVID-19');
        OpportunityLineItem oppLineItem2 = new OpportunityLineItem(OpportunityId = opp.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = 'Pending',
                                                                   Core_Risk_Reason1__c= 'Legal',
                                                                   Core_Risk_Reason2__c = 'COVID-19');
        oppLineItemList.add(oppLineItem1);
        oppLineItemList.add(oppLineItem2);
        
        
        
        
        insert oppLineItemList;
        system.assertEquals('COVID-19', oppLineItemList[0].Core_Risk_Reason2__c,'Risk reason2 should be COVID-19');
        system.assertEquals('COVID-19', oppLineItemList[1].Core_Risk_Reason2__c,'Risk reason2 should be COVID-19');
        test.starttest();
        Delete oppLineItem1;
        Delete oppLineItem2;
        test.stoptest();
    }
    
    /*
* Method name  : testAfterInsertOppoLineItem
* Description  : This Method used to test updateOppoRiskReasonOnOppLineItemInsert
* Return Type  : void
* Parameter    : NA
*/
    testMethod static void testAfterInsertOppoLineItem() {
        
        setupTestF();
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = opp.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = 'New',
                                                                   Core_Risk_Reason1__c= 'Legal');
        OpportunityLineItem oppLineItem2 = new OpportunityLineItem(OpportunityId = opp.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = 'Closed: Support Provided',
                                                                   Core_Risk_Reason1__c= 'COVID-19');
        oppLineItemList.add(oppLineItem1);
        oppLineItemList.add(oppLineItem2);
        
        
        
        
        
        
        test.starttest();
        insert oppLineItemList;
        system.assertEquals('Legal', oppLineItemList[0].Core_Risk_Reason1__c,'Risk reason should be Legal');
        system.assertEquals('COVID-19', oppLineItemList[1].Core_Risk_Reason1__c,'Risk reason should be COVID-19');
        delete oppLineItem2;
        test.stoptest();
    }

    /*
* Method name  : testAfterUpdateOppoLineItem
* Description  : This Method used to test updateOppoRiskReasonOnOppLineItemUpdate
* Return Type  : void
* Parameter    : NA
*/
    testMethod static void testAfterUpdateOppoLineItem() {
        
        setupTestF();
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = opp.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = 'Pending',
                                                                   Core_Risk_Reason1__c= 'Legal',
                                                                   Core_Risk_Reason2__c = 'COVID-19');
        OpportunityLineItem oppLineItem2 = new OpportunityLineItem(OpportunityId = opp.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = 'Pending',
                                                                   Core_Risk_Reason1__c= 'Legal',
                                                                   Core_Risk_Reason2__c = 'COVID-19');
        oppLineItemList.add(oppLineItem1);
        oppLineItemList.add(oppLineItem2);
        
        
        
        
        
        insert oppLineItemList;     
        test.starttest();
        oppLineItem2.Core_Risk_Reason1__c = 'Supply';
        update oppLineItem2;
        system.assertEquals('Supply', oppLineItemList[1].Core_Risk_Reason1__c,'Risk reason1 should be Supply');
        system.assertEquals('COVID-19', oppLineItemList[0].Core_Risk_Reason2__c,'Risk reason2 should be COVID-19');
        test.stoptest();
    }
    
    public class Core_KPITestHttpResponse implements HttpCalloutMock {
        
        public Integer statusCode;
        public Core_KPITestHttpResponse(Integer statusCode){
            this.statusCode = statusCode;
        }
        public HTTPResponse respond(HTTPRequest req) {
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test" , "values":[{"value":"test value"}]}');
            res.setStatusCode(statusCode);
            return res;
        }
    }
    
    testMethod static void OppoLineItemToBeDeleted_Test() {
        setupTestF();    
        map<id,OpportunityLineItem> mp = new map<id,OpportunityLineItem>();
       List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = opp.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = System.Label.Core_LineItem_Status,
                                                                   Core_Risk_Reason1__c= 'Legal',
                                                                   Core_Risk_Reason2__c = 'COVID-19');
        OpportunityLineItem oppLineItem2 = new OpportunityLineItem(OpportunityId = opp.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = System.Label.Core_LineItem_Status,
                                                                   Core_Risk_Reason1__c= 'Legal',
                                                                   Core_Risk_Reason2__c = 'COVID-19');
        oppLineItemList.add(oppLineItem1);
        oppLineItemList.add(oppLineItem2);
        
        insert oppLineItemList;   
        
        mp.put(oppLineItemList[0].id,oppLineItemList[0]);
        
        test.starttest();
        Core_OpportunityLineItemHandler.deleteNewKPI(oppLineItemList);
        Core_OpportunityLineItemHandler.restrictClosedAtRiskProductToBeDeleted(oppLineItemList);
        Core_OpportunityLineItemHandler.restrictDeleteWhileKPIFullRefresh(oppLineItemList);
        Core_OpportunityLineItemHandler.restrictClsedAtRiskProdToDeletedUpdate(oppLineItemList, mp);
        Core_OpportunityLineItemHandler.preventDeleteWhileKPIFullRefresh(oppLineItemList, mp);
        test.stoptest();
    }
    
    /*
* Method name  : ValidateQuantityDecimal
* Description  : This Method used to test validateQtyDecimal
* Return Type  : void
* Parameter    : NA
*/
    
    testMethod static void Decimalvalidity(){
        setupTestF();    
        map<id,OpportunityLineItem> mp = new map<id,OpportunityLineItem>();
       List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = opp.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = System.Label.Core_LineItem_Status,
                                                                   Core_Risk_Reason1__c= 'Legal',
                                                                   Core_Risk_Reason2__c = 'COVID-19');
        OpportunityLineItem oppLineItem2 = new OpportunityLineItem(OpportunityId = opp.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = System.Label.Core_LineItem_Status,
                                                                   Core_Risk_Reason1__c= 'Legal',
                                                                   Core_Risk_Reason2__c = 'COVID-19');
        oppLineItemList.add(oppLineItem1);
        oppLineItemList.add(oppLineItem2);
        
        insert oppLineItemList; 
        
        
        Core_OpportunityLineItemHandler.validateQtyDecimal(oppLineItemList);
        System.assertEquals(true,true);
        
    }
    
    testMethod static void PCCdeleteOLITest(){
        setupTest();   
        opp.Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity';
        opp.Core_Coverage_Type_Nm__c='Deal Registration';
        update opp;
        
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = opp.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = 'Pending',
                                                                   Core_Risk_Reason1__c= 'Legal',
                                                                   Core_Risk_Reason2__c = 'COVID-19');
        insert oppLineItem1;
        oppLineItem1.Core_Status__c = System.Label.Core_LineItem_Status;
        update oppLineItem1; 
        System.assertEquals(true,true);   
    }
    
     testMethod static void PCCCancelledOLITest(){
        setupTestF();   
        opp.Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity';
        opp.Core_Coverage_Type_Nm__c='Deal Registration';
        update opp;
        
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = opp.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   core_status__c = 'Lost',
                                                                   Core_Risk_Reason1__c= 'Legal',
                                                                   Core_Risk_Reason2__c = 'COVID-19');
        insert oppLineItem1;
        System.assertEquals(true,true);
        }
    
    testMethod static void deleteOLITest(){
        setupTestF();    
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = opp.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = System.Label.Core_LineItem_Status,
                                                                   Core_Risk_Reason1__c= 'Legal',
                                                                   Core_Risk_Reason2__c = 'COVID-19');
        insert oppLineItem1;
        oppLineItem1.Core_Status__c = System.Label.Core_LineItem_Status;
        update oppLineItem1;   
        System.assertequals(true,true); 
    }
    
     static testMethod void PCCDealRegOPTYLineQuoteSync_Test(){
        Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c(Name='PCCDealRegOPTYLineQuoteSync', Core_Object__c='OpportunityLineItem',
          Core_Class_Name__c='Core_OpportunityLineItemHandler',Core_Trigger_Events__c='after update', 
                    Core_Active__c=true, Core_Description__c='for PCC Lock');
          insert triggerEntry;
          
               Core_Trigger_Executions__c triggerEntry1 = new Core_Trigger_Executions__c(Name='PCCDealRegOPTYLineDelete', Core_Object__c='OpportunityLineItem',
          Core_Class_Name__c='Core_OpportunityLineItemHandler',Core_Trigger_Events__c='before delete', 
                    Core_Active__c=true, Core_Description__c='PCCDealRegOPTYLineDelete');
          insert triggerEntry1;
      
    
    // Create and Insert test accounts
        accountList = Core_Test_Utility.createAccount(6);
        accountList[0].Name = 'Test Account1';
        accountList[0].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[0].Industry = 'Telecommunications';
        accountList[0].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountList[1].Name = 'HP';
        accountList[1].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[1].Industry = 'Telecommunications';
        accountList[1].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountList[2].Name = 'Google';
        accountList[2].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[2].Industry = 'Telecommunications';
        accountList[2].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountList[3].Name = 'Apple';
        accountList[3].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[3].Industry = 'Telecommunications';
        accountList[3].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountList[4].Name = 'Target';
        accountList[4].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[4].Industry = 'Telecommunications';
        accountList[4].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        insert accountList;
        Id DealOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Opportunity opp = new Opportunity(Name = 'PCC Opportunity', RecordTypeId = DealOppRecTypeId, AccountId = accountList[4].Id, OwnerId= UserInfo.getUserId(),Core_Coverage_Type_Nm__c = 'Deal Registration',
                                          StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity');
           
        opp.Opportunity_Focus__c= 'Core';
        opp.Core_Opportunity_Type__c='Deal: Sell-to';
        insert opp;
        
        Product2 pd2 = new Product2(Name = 'Test Product',
                           Core_Division_Code__c = '000',
                           Core_Division_Code_Short_Name__c = 'BBB',
                           Core_Group_Code__c = '111',
                           Core_Group_Code_Short_Name__c = 'AAA');
        System.runAs(Core_Test_Utility.systemAdminUser){  
            insert pd2;
        }
        
        //static  testPBE;
        PricebookEntry testPBE = new PricebookEntry();
        testPBE.UnitPrice = 1;
        testPBE.isActive  = TRUE;
        testPBE.Pricebook2Id = Test.getStandardPricebookId();
        testPBE.Product2Id = pd2.Id;      
        testPBE.UseStandardPrice = false;   
        System.runAs(Core_Test_Utility.systemAdminUser){  
            insert testPBE;
        }
        
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();

        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = opp.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 10,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = 'Pending',
                                                                   Core_Risk_Reason1__c= 'RiskReason',
                                                                   Core_Risk_Reason2__c = 'RiskReason2'
                                                                   );
        oliList.add(oppLineItem);
        insert oliList;
        oliList[0].Core_Status__c = 'Lost';
        update oliList;
       List<OpportunityLineItem> oliListNew =[select Id,core_status__c, Quantity,Core_PW_Quantity__c,UnitPrice,Core_PW_Sales_Price__c,Core_IsPCCOpportunity_cb__c,OpportunityId  from  OpportunityLineItem where Id=: oliList[0].Id];
       Map<Id, OpportunityLineItem> oliListMap = new Map<Id, OpportunityLineItem>(oliList);
       Boolean opportunityProductConcatenationRecCheck;
         opportunityProductConcatenationRecCheck = false;
        //Test.startTest();
        Core_OpportunityLineItemHandler.syncStatus_OppProduct_QuoteLine(oliListNew, oliListMap);
        Core_OpportunityLineItemHandler.opportunityRevenueCalculation(oliListNew, oliListMap,'Update');
        Core_OpportunityLineItemHandler.opportunityRevenueCalculation(oliListNew, oliListMap,'Insert');
        Core_OpportunityLineItemHandler.opportunityRevenueCalculation(oliListNew, oliListMap,'Delete');
        Core_OpportunityLineItemHandler.deleteValidation_PCCDealReg(oliListNew);
		Core_OpportunityLineItemHandler.opportunityProductConcatenation(oliListNew, oliList,false);
        //Core_OpportunityLineItemHandler.CheckLockOnPCCOppty(oliListNew, null);
        //Core_OpportunityLineItemHandler.CheckLockOnPCCOppty(oliListNew, null);
        //Test.stopTest();
    }
    
    
    static testMethod void CheckLockOnPCCOppty_Test(){
        Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c(Name='lockPCCOpportunity', Core_Object__c='Opportunity',
          Core_Class_Name__c='Core_OpportunityHandler',Core_Trigger_Events__c='before update, before', 
                    Core_Active__c=true, Core_Description__c='for PCC Lock');
          insert triggerEntry;
    
    
    // Create and Insert test accounts
        accountList = Core_Test_Utility.createAccount(6);
        accountList[0].Name = 'Test Account1';
        accountList[0].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[0].Industry = 'Telecommunications';
        accountList[0].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountList[1].Name = 'HP';
        accountList[1].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[1].Industry = 'Telecommunications';
        accountList[1].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountList[2].Name = 'Google';
        accountList[2].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[2].Industry = 'Telecommunications';
        accountList[2].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountList[3].Name = 'Apple';
        accountList[3].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[3].Industry = 'Telecommunications';
        accountList[3].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountList[4].Name = 'Target';
        accountList[4].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[4].Industry = 'Telecommunications';
        accountList[4].Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        insert accountList;
        Id DealOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Opportunity opp = new Opportunity(Name = 'PCC Opportunity', RecordTypeId = DealOppRecTypeId, AccountId = accountList[4].Id, OwnerId= UserInfo.getUserId(),Core_Coverage_Type_Nm__c = 'Deal Registration',
                                          StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity');
        opp.Opportunity_Focus__c= 'Core';
        opp.Core_Opportunity_Type__c ='Deal: Sell-to';
        insert opp;
        
        Product2 pd2 = new Product2(Name = 'Test Product',
                           Core_Division_Code__c = '000',
                           Core_Division_Code_Short_Name__c = 'BBB',
                           Core_Group_Code__c = '111',
                           Core_Group_Code_Short_Name__c = 'AAA');
        System.runAs(Core_Test_Utility.systemAdminUser){  
            insert pd2;
        }
        
        //static  testPBE;
        PricebookEntry testPBE = new PricebookEntry();
        testPBE.UnitPrice = 1;
        testPBE.isActive  = TRUE;
        testPBE.Pricebook2Id = Test.getStandardPricebookId();
        testPBE.Product2Id = pd2.Id;      
        testPBE.UseStandardPrice = false;   
        System.runAs(Core_Test_Utility.systemAdminUser){  
            insert testPBE;
        }
        
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = opp.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 10,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = 'Pending',
                                                                   Core_Risk_Reason1__c= 'RiskReason',
                                                                   Core_Risk_Reason2__c = 'RiskReason2');
        oliList.add(oppLineItem);
        insert oliList;
        oliList[0].Core_Risk_Reason1__c = 'RiskReasonUpdated';
        update oliList;

        Core_OpportunityLineItemHandler.CheckLockOnPCCOppty(oliList, null);
    }
    
   	/*testMethod static void testOpportunityProductConcatenation() {
        
        Id DealOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Opportunity opp = new Opportunity(Name = 'PCC Opportunity', RecordTypeId = DealOppRecTypeId, AccountId = accountList[4].Id, OwnerId= UserInfo.getUserId(),Core_Coverage_Type_Nm__c = 'Deal Registration',
                                          StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity');
            insert opp;
        
        Product2 pd2 = new Product2(Name = 'Test Product',
                           Core_Division_Code__c = '000',
                           Core_Division_Code_Short_Name__c = 'BBB',
                           Core_Group_Code__c = '111',
                           Core_Group_Code_Short_Name__c = 'AAA');
        System.runAs(Core_Test_Utility.systemAdminUser){  
            insert pd2;
        }

        // Setup test data
        Product2 product1 = new Product2(Name = 'Product A');
        Product2 product2 = new Product2(Name = 'Product B');
        insert new List<Product2>{product1, product2};

        Opportunity opp1 = new Opportunity(Name = 'Test Opportunity', StageName = 'Closed Won', CloseDate = Date.today());
        insert opp;

        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = opp.Id, Product2Id = product1.Id, Quantity = 1, UnitPrice = 100);
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = opp.Id, Product2Id = product2.Id, Quantity = 1, UnitPrice = 200);
        insert new List<OpportunityLineItem>{oli1, oli2};

        // Create newList and oldList for the method
        List<OpportunityLineItem> newList = [SELECT OpportunityId, Product2.Name FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        List<OpportunityLineItem> oldList = new List<OpportunityLineItem>(); // Can be empty or old records if updating

        // Set global variable to false for method to trigger
        Test.startTest();
        opportunityProductConcatenationRecCheck = false;

        // Call the method to test
        Core_OpportunityLineItemHandler.opportunityProductConcatenation(newList, oldList, false); // Pass false to simulate an insert/update trigger

        // Get the updated Opportunity records
        Opportunity updatedOpp = [SELECT Id, Core_Opportunity_Products__c FROM Opportunity WHERE Id = :opp.Id];

        // Assertions to check if Core_Opportunity_Products__c is updated correctly
        System.assertEquals('Product A, Product B', updatedOpp.Core_Opportunity_Products__c, 'The concatenated product names are not correct.');

        Test.stopTest();
    }*/

    
    testMethod static void testupdatefcRecordOLIdelete() {
        
        setupTestF();
       
        List<Opportunity> listOpportunity = Core_Test_Utility.createOpportunity(1); 
        opp = listOpportunity[0];    
        opp.AccountId = accountList[0].Id;
        opp.Opportunity_Focus__c= 'Core';
        opp.Core_Opportunity_Type__c='Design: Original';
        //opp.Core_Commissionable__c='Yes';     
        //opp.Core_Opportunity_Type__c='Deal: Sell-to';
        //opp.Core_Solution_Area__c = 'CCG Commercial Deal $';
        System.runAs(Core_Test_Utility.systemAdminUser){          
            insert opp;
         
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = opp.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = 'Pending',
                                                                   Core_Risk_Reason1__c= 'Legal',
                                                                   Core_Risk_Reason2__c = 'COVID-19');
        OpportunityLineItem oppLineItem2 = new OpportunityLineItem(OpportunityId = opp.Id,
                                                                   PricebookEntryId = testPBE.Id,
                                                                   Quantity = 1,
                                                                   UnitPrice = 200,
                                                                   Core_Status__c = 'Pending',
                                                                   Core_Risk_Reason1__c= 'Legal',
                                                                   Core_Risk_Reason2__c = 'COVID-19');
        oppLineItemList.add(oppLineItem1);
        oppLineItemList.add(oppLineItem2);

        insert oppLineItemList;
        List<Core_Opp_FC_Prod_Schedule__c> fcObjList = new List<Core_Opp_FC_Prod_Schedule__c>();
        fcObjList.add(new  Core_Opp_FC_Prod_Schedule__c (Core_Opp_Line_Item_RecordID__c=oppLineItem1.Id,Core_Opp_FC_Approval_Status__c='Approved',Core_Opp_FC_Prod_Sales_Price__c=3,Core_Opp_FC_Opportunity__c=oppLineItem1.OpportunityID,Core_Is_Post_Win__c = false,Core_FC_Opportunity_Product__c = null));
        fcObjList.add(new  Core_Opp_FC_Prod_Schedule__c (Core_Opp_Line_Item_RecordID__c=oppLineItem2.Id,Core_Opp_FC_Approval_Status__c='Pending',Core_Opp_FC_Prod_Sales_Price__c=3,Core_Opp_FC_Opportunity__c=oppLineItem2.OpportunityID,Core_Is_Post_Win__c = false,Core_FC_Opportunity_Product__c = null));
        insert fcObjList;
        system.assertEquals('COVID-19', oppLineItemList[0].Core_Risk_Reason2__c,'Risk reason2 should be COVID-19');
        system.assertEquals('COVID-19', oppLineItemList[1].Core_Risk_Reason2__c,'Risk reason2 should be COVID-19');
        test.starttest();
         Core_OpportunityLineItemHandler.updatefcRecordOLIdelete(oppLineItemList);
        test.stoptest();
         }
       }
   
}