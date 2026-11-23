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
@isTest
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
        accountList = Core_Test_Utility.createAccount(6);
        accountList[0].Name = 'Dell';
        accountList[0].Core_Sales_Groups__c = 'CCG Sales Group';
        accountList[1].Name = 'HP';
        accountList[1].Core_Sales_Groups__c = 'CCG Sales Group';
        accountList[2].Name = 'Google';
        accountList[2].Core_Sales_Groups__c = 'CCG Sales Group';
        accountList[3].Name = 'Apple';
        accountList[3].Core_Sales_Groups__c = 'CCG Sales Group';
        accountList[4].Name = 'Target';
        accountList[4].Core_Sales_Groups__c = 'CCG Sales Group';
        insert accountList;
        
        // Create and Insert a test Opportunity
        List<Opportunity> listOpportunity = Core_Test_Utility.createOpportunity(1); 
        opp = listOpportunity[0];    
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
        
         Core_Trigger_Executions__c triggerExec6 = new Core_Trigger_Executions__c(Name='opportunityApprovalHistoryInsert', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler',                                                                               
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='after update',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c = 'insertapprovalhistory');
        insert triggerExec6;
        
        
         Core_Trigger_Executions__c triggerExec7 = new Core_Trigger_Executions__c(Name='updateOpportunityLineItem', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler',                                                                               
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='after update',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c ='RemoveApprovedSalesGroup');
         insert triggerExec7;                                                                        
        Core_Trigger_Executions__c triggerExec8 = new Core_Trigger_Executions__c(Name='deleteKPIonProductDelete', 
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler',                                                                               
                                                                                 Core_Object__c='OpportunityLineItem',
                                                                                 Core_Trigger_Events__c='before delete',     
                                                                                 Core_Active__c=true, 
                                                                                 Core_Description__c ='Delete KPIs');
         insert triggerExec8; 
      
    }
  @testSetup
    private static void setupTestData() {
        
        Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c(
            Name='trackOpportunityProductHistory', Core_Object__c='OpportunityLineItem', Core_Class_Name__c='Core_OpportunityLineItemHandler',
            Core_Trigger_Events__c='before update, before delete', Core_Active__c=true, Core_Description__c='testing, testing');
        insert triggerEntry;
        
        Account testAcct = Core_Test_Utility.createAccount(1)[0];
        testAcct.Core_Sales_Groups__c = 'CCG Sales Group';
        insert testAcct;
        
        // Simple test data
        Opportunity testOpp = Core_Test_Utility.createOpportunity(1)[0];
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
                                                  Description='Test 11', UnitPrice=11, Quantity=11,Core_BU_Short_Name__c='T11',
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
       insert testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=testOpp.Id, PricebookEntryId=testPBEs[1].Id,
                                                  Description='Test 12', UnitPrice=12, Quantity=12, Core_BU_Short_Name__c='T12',
                                                  Core_Loss_Cancel_Reason__c='', Core_Status__c='Pending');
        insert testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=testOpp.Id, PricebookEntryId=testPBEs[2].Id,
                                                  Description='Test 13', UnitPrice=13, Quantity=13, Core_BU_Short_Name__c='T13',
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
       insert testOppLineItem;
        
        // Bulk test data
        List<Opportunity> bulkTestOpps = Core_Test_Utility.createOpportunity(10);
        for (Opportunity opp : bulkTestOpps)
            opp.AccountId = testAcct.Id;
        insert bulkTestOpps;
        
        List<Product2> bulkTestProducts = Core_Test_Utility.createProduct(5);
        insert bulkTestProducts;
        
        List<PricebookEntry> bulkTestPBEs = Core_Test_Utility.createPriceBookEntry(5, bulkTestProducts, Test.getStandardPricebookId());
        insert bulkTestPBEs;
        
        List<OpportunityLineItem> bulkTestOppLineItems = new List<OpportunityLineItem>();
        for (Opportunity opp : bulkTestOpps) {
            for (PricebookEntry pbe : bulkTestPBEs) {
                bulkTestOppLineItems.add(new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=pbe.Id,
                                                                 Description='Bulk 11', UnitPrice=11, Quantity=11, Core_BU_Short_Name__c='B11',
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
                                                  Core_Product_Segment__c='Client Computing', Core_Product_Application__c='Business Desktop',Core_Weightage__c=4,
                                                              Core_BU_Segment__c='1111',Core_BU_Shortname__c='ABCD'));
                                                              
            mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1110',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='Emerging Technologies',
                                                              Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c='',Core_Weightage__c=3,Core_BU_Segment__c='1110',Core_BU_Shortname__c='ABC'));
                                                              
            mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1101',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='Emerging Technologies',
                                                              Core_Product_Segment__c='', Core_Product_Application__c='Business Desktop',Core_Weightage__c=3,Core_BU_Segment__c='1101',Core_BU_Shortname__c='ABD'));
            
            mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1100',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='Emerging Technologies',
                                                              Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='1100',Core_BU_Shortname__c='AB'));
            
            mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1000',Core_Division_Shortname__c='',Core_Product_Type__c='Emerging Technologies',
                                                              Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=1,Core_BU_Segment__c='1000',Core_BU_Shortname__c='A'));  
            
            mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1001',Core_Division_Shortname__c='',Core_Product_Type__c='Emerging Technologies',
                                                              Core_Product_Segment__c='', Core_Product_Application__c='Business Desktop',Core_Weightage__c=2,Core_BU_Segment__c='1001',Core_BU_Shortname__c='AD'));
            
            mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1010',Core_Division_Shortname__c='',Core_Product_Type__c='Emerging Technologies',
                                                              Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='1010',Core_BU_Shortname__c='AC'));
            mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1011',Core_Division_Shortname__c='',Core_Product_Type__c='Emerging Technologies',
                                                              Core_Product_Segment__c='Client Computing', Core_Product_Application__c='Business Desktop',Core_Weightage__c=3,Core_BU_Segment__c='1011',Core_BU_Shortname__c='ACD'));
            mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0100',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='',
                                                              Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=1,Core_BU_Segment__c='0100',Core_BU_Shortname__c='B'));
            
            mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0101',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='',
                                                              Core_Product_Segment__c='', Core_Product_Application__c='Business Desktop',Core_Weightage__c=2,Core_BU_Segment__c='0101',Core_BU_Shortname__c='BD'));
            mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0110',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='',
                                                              Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='0110',Core_BU_Shortname__c='BC'));
                                                                                                              
            mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0111',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='',
                                                              Core_Product_Segment__c='Client Computing', Core_Product_Application__c='Business Desktop',Core_Weightage__c=3,Core_BU_Segment__c='0111',Core_BU_Shortname__c='BCD'));                                              
            
            mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0001',Core_Division_Shortname__c='',Core_Product_Type__c='',
                                                              Core_Product_Segment__c='', Core_Product_Application__c='Business Desktop',Core_Weightage__c=1,Core_BU_Segment__c='0001',Core_BU_Shortname__c='D'));
            mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0010',Core_Division_Shortname__c='',Core_Product_Type__c='',
                                                              Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=1,Core_BU_Segment__c='0010',Core_BU_Shortname__c='C'));  
            mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0011',Core_Division_Shortname__c='',Core_Product_Type__c='',
                                                              Core_Product_Segment__c='Client Computing', Core_Product_Application__c='Business Desktop',Core_Weightage__c=2,Core_BU_Segment__c='0011',Core_BU_Shortname__c='CD'));
                                                  
                                                  
    insert mappingObjList;                                            
                                                  
        Core_BU_Mapping_Email_recipients__c recObj = new Core_BU_Mapping_Email_recipients__c();
        recObj.Core_isActive__c=true;
        recObj.Name='1';
        recObj.Core_User_Ids__c='Salesforce@intel.sfdc.com';  
        insert recObj; 
     // *********************************Here End  for BU Mapping Record****************************************** //
    }
    static testMethod void Core_OpportunityLineItemHandler_Test_1() {    
        setupTest();
        Test.startTest();

        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(1, listPBE, opp);
        insert oppLineItems;

        Core_OpportunityLineItemHandler.opportunityLineItemAfterHandler(oppLineItems, null, null, null, true, false, false);

        Test.stopTest();
    }

    static testMethod void Core_OpportunityLineItemHandler_Test_2() {  
        setupTest();

        Test.startTest();

        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(1, listPBE, opp);
        insert oppLineItems;

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
       

        List<OpportunityLineItem> insertedOLI = [SELECT Core_Group__c, Core_Group_Code__c, Core_Division__c, Core_Division_Code__c FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];

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

       
        insert oppLineItems;
        oppLineItemsupdate.addAll(oppLineItems);
        oppLineItems[0].Core_Status__c = 'Production Win';
        update oppLineItems;
        //List<> lstOppLItem = new List<OpportunityLineItem>();
        //lstOppLItem.add(oppLineItems);
        map<id,OpportunityLineItem> mp = new map<id,OpportunityLineItem>();
        mp.put(oppLineItems[0].id,oppLineItems[0]);
        Core_OpportunityLineItemHandler.beforeInsertForecastRecords(oppLineItems );
        Core_OpportunityLineItemHandler.insertForecastRecords(oppLineItems,True);
        Core_OpportunityLineItemHandler.deleteForecastRecords(mp);
        Core_OpportunityLineItemHandler.updateForecastRecords(oppLineItems,mp);
        Core_OpportunityLineItemHandler.opptyLineItemUpdateSalesGroupandUserCovg(oppLineItems,mp,oppLineItems,mp,True);

        List<Core_Opportunity_Partner__c> relatedPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 

        //System.assertEquals(1, relatedPartners.size());
        //System.assertEquals(accountList[0].Id, relatedPartners.get(0).Core_Partner__c);
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

       
        insert oppLineItems;
       // Test.stopTest();

        List<Core_Opportunity_Partner__c> relatedPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 

        //System.assertEquals(1, existingPartners.size());
        //System.assertEquals(1, relatedPartners.size());
        //System.assertEquals(existingPartners, relatedPartners);
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

             
        delete oppLineItems;
        
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

        List<Core_Opportunity_Partner__c> existingPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 

       
        delete oppLineItems[0];
       

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

        List<Core_Opportunity_Partner__c> existingPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 

       // Test.startTest();
        delete oppLineItems[1];
        delete oppLineItems[3];
        delete oppLineItems[4];
        delete oppLineItems[5];
        delete oppLineItems[6];
        delete oppLineItems[7];
       // Test.stopTest();

        List<Core_Opportunity_Partner__c> relatedPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 
      Test.stopTest();
       
    }

    // Unique old, unique new -> update
    static testMethod void updatePartner_Test_1() {
    Test.startTest();
        setupTest();

        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(1, listPBE, opp);
        oppLineItems[0].Core_Vendor__c = accountList[0].Id;
        insert oppLineItems[0];

        List<Core_Opportunity_Partner__c> existingPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 

        oppLineItems[0].Core_Vendor__c = accountList[1].Id;

       // Test.startTest();
        update oppLineItems[0];
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

        List<Core_Opportunity_Partner__c> existingPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 

        oppLineItems[1].Core_Vendor__c = accountList[1].Id;

      //  Test.startTest();
        update oppLineItems[1];
      //  Test.stopTest();

        List<Core_Opportunity_Partner__c> relatedPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 

        System.assertEquals(1, existingPartners.size());
        System.assertEquals(accountList[0].Id, existingPartners[0].Core_Partner__c);
        System.assertEquals(2, relatedPartners.size());
        System.assertEquals(accountList[0].Id, relatedPartners[0].Core_Partner__c);
        System.assertEquals(accountList[1].Id, relatedPartners[1].Core_Partner__c);
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

        List<Core_Opportunity_Partner__c> relatedPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 

        System.assertEquals(2, existingPartners.size());
        System.assertEquals(accountList[0].Id, existingPartners[0].Core_Partner__c);
        System.assertEquals(accountList[1].Id, existingPartners[1].Core_Partner__c);
        System.assertEquals(2, relatedPartners.size());
        System.assertEquals(accountList[0].Id, relatedPartners[0].Core_Partner__c);
        System.assertEquals(accountList[1].Id, relatedPartners[1].Core_Partner__c);
        System.assertEquals(existingPartners.get(0), relatedPartners.get(0));
        System.assertEquals(existingPartners.get(1), relatedPartners.get(1));
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

        System.assertEquals(2, existingPartners.size());
        System.assertEquals(accountList[0].Id, existingPartners[0].Core_Partner__c);
        System.assertEquals(accountList[1].Id, existingPartners[1].Core_Partner__c);
        System.assertEquals(1, relatedPartners.size());
        System.assertEquals(accountList[1].Id, relatedPartners[0].Core_Partner__c);
        System.assertEquals(existingPartners.get(1), relatedPartners.get(0));
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
        oppLineItems[0].Core_Loss_Cancel_Reason__c = 'Other';
        oppLineItems[1].Core_Status__c = 'Cancelled';
        oppLineItems[1].Core_Loss_Cancel_Reason__c = 'Other';
        oppLineItems[2].Core_Status__c = 'Deleted';
        oppLineItems[2].Core_Loss_Cancel_Reason__c = 'Other';
        update1List.add(oppLineItems[0]);
        update1List.add(oppLineItems[1]);
        update1List.add(oppLineItems[2]);

        update update1List;

        List<Core_Opportunity_Partner__c> update1 = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id]; 

        List<OpportunityLineItem> update2List = new List<OpportunityLineItem>();
        oppLineItems[0].Core_Status__c = 'Pending';
        oppLineItems[1].Core_Status__c = 'Pending';
        oppLineItems[2].Core_Status__c = 'Pending';
        update2List.add(oppLineItems[0]);
        update2List.add(oppLineItems[1]);
        update2List.add(oppLineItems[2]);

        update update2List;

        List<Core_Opportunity_Partner__c> update2 = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :opp.Id];

        System.assertEquals(3, existingPartners.size());
        System.assertEquals(0, update1.size());
        System.assertEquals(3, update2.size());

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
        account.Name = 'testacct_solutionMilestoneAddCommissionableTxns';            
        account.BillingCountryCode = 'USA';
        account.Core_Sales_Groups__c = 'CCG Sales Group';
        account.BillingStateCode = 'AL';
        account.BillingCity = 'Alabama';
        account.BillingStreet = 'test';
        account.Core_CIM_ID__c = '98765432';
        try {
            insert account;
            System.debug('Account ' + account.Name + ' inserted.');
        } catch(DmlException e) {
            System.debug('Exception: ' + e.getMessage());
        }

        List<Account> accounts = [SELECT Id, Core_CIM_ID__c, Name FROM Account WHERE name = :account.Name LIMIT 1];
        //System.assert(!accounts.isEmpty());
        account = accounts.get(0);

        //Create an associated opportunity  
        opportunity.CloseDate = System.Today().addDays(24);
        opportunity.StageName = 'Prospecting';
        opportunity.Name = 'testop_solutionMilestoneAddCommissionableTxns';
        opportunity.AccountId = account.Id;
        opportunity.Core_Opportunity_Type__c = 'Design: Original';
        opportunity.Core_Technical_Owner__c = UserInfo.getUserId();
        opportunity.Core_Solution_Area__c='CCG Unite Deal #';
        opportunity.Core_First_Customer_Ship_Date__c = System.Today();
        opportunity.Core_Intel_Platform__c = 'Apollo Lake D';
        opportunity.Core_Opp_Prime_Account_Name__c = 'Tes PrimeAccount';
        opportunity.Core_Commissionable__c = 'Yes';
        try {
            insert opportunity;
            System.debug('Opportunity ' + opportunity.Name + ' inserted.  AccountID: ' + account.Id);
        } catch(DmlException e) {
            System.debug('Exception: ' + e.getMessage());
        }

        List<Opportunity> opportunityList = [SELECT Id, Name, Core_Opportunity_Type__c FROM Opportunity WHERE name = :opportunity.Name LIMIT 1];
        //System.assert(!opportunityList.isEmpty());
        opportunity = opportunityList.get(0);

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
            system.debug('Adding user: ' + user.FirstName + ' ' + user.LastName + ' ' + user.Core_WWID__c + ' ' + user.Core_Employee_Type_Code__c );
        }

        try {
            insert lstUser;            
        } catch(DmlException e) {
            System.debug('Exception: ' + e.getMessage());
        }
        //Database.SaveResult[] lstSaveResultUser = Database.insert(lstUser, false);

        lstUser = [SELECT Id, Name, Core_WWID__c, FirstName, LastName, Core_Employee_Type_Code__c
                   FROM User WHERE FirstName = 'testusmact'];
        //System.assert(!lstUser.isEmpty());

        //Create a series of associated opportunity team members (one of each Opportunity Team Member Role)
        i = 0;
        for(User user:lstUser)
        {
            System.debug('User ' + user.Id + ' inserted.  Name: ' + user.Name + ' Type: ' + user.Core_Employee_Type_Code__c );
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
            System.debug('Exception: ' + e.getMessage());
        }
        //Database.SaveResult[] lstSaveResultOTM = Database.insert(lstOpportunityTeamMember, false);

        lstOpportunityTeamMember = [SELECT Id, UserId, TeamMemberRole from OpportunityTeamMember WHERE OpportunityId = :opportunity.Id];        
        //System.assert(!lstOpportunityTeamMember.isEmpty());
        System.debug(lstOpportunityTeamMember.size() + ' entries added to OpportunityTeamMember.  OpportunityID: ' + opportunity.Id);

        //Create associated opportunity product

        lstOP = Core_Test_Utility.createOpportunityLineItems(1, PBEs, opportunity);
        OpportunityLineItem op = lstOP.get(0);
        op.Core_Status__c = 'Pending';
        op.Core_Approved_Commissionable__c=Null; 
        op.Core_Claim_Date__c = System.today();

        System.debug('Adding OP: ' + lstOP.get(0).Core_Approved_Total_Price__c +'|' + lstOP.get(0).Core_Status__c);

        try {
            insert lstOP;            
        } catch(DmlException e) {
            System.debug('Exception: ' + e.getMessage());
        }

        lstOP = [SELECT Id, Core_Status__c, Core_Approved_Decision_Date__c, Core_Approved_Total_Price__c, Core_Claim_Date__c, TotalPrice, UnitPrice, Quantity
             FROM OpportunityLineItem WHERE OpportunityId = :opportunity.Id];
        //System.assert(!lstOP.isEmpty());
        System.debug('Added OP -- Claim Date: ' + lstOP.get(0).Core_Claim_Date__c);
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
        op.Core_BU_Short_Name__c = 'BU Short Name';
        op.Core_Approved_KPI_Product_Group__c  = 'test unqualified';
        op.Core_Approved_Prime_Account_Name__c  = 'test PrimeAccount';
        op.Core_Claim_Date__c = System.today();
        Core_OpportunityLineItemHandler.alreadyAddedCommissionableTransactions = false;
        try {
             
            update op; 
                   
        } catch(DmlException e) {
            System.debug('Exception: ' + e.getMessage());
        }

        lop = 
            [SELECT Id, Core_Status__c, Core_Approved_Decision_Date__c, Core_Approved_Total_Price__c, Core_Claim_Date__c, TotalPrice, UnitPrice, Quantity, Core_BU_Short_Name__c,Core_Approved_Commissionable__c
             FROM OpportunityLineItem WHERE Id = :lstOP.get(0).Id];
        //System.assert(!lop.isEmpty());
        System.debug('Status After Update:' + lop.get(0).Core_Status__c);

        List <Core_Commissionable_Transaction__c> lct = [            
            SELECT Core_Account_Name__c,Core_Approved_Total_Price__c,Core_CIM_ID__c,Core_Claim_Date__c,
            Core_Employee_Name__c,Core_Last_Approved_Date__c,Core_Milestone_Area__c,
            Core_Milestone_Focus__c,Core_Milestone__c,Core_Opportunity_Name__c,Core_Opportunity_Team_Member_Role__c,
            Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,Core_Product_Type__c,
            Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,Core_Transaction_Type__c,Core_WWID__c,Core_Approved_BU_Short_Name__c
            FROM Core_Commissionable_Transaction__c 
        ];

        //System.assert(!lct.isEmpty());
        System.debug(lct.size() + ' entries in Commissionable Transactions associated with milestone ' + op.Id);   
        for(Integer i=0; i<lct.size(); i++) {
            System.debug('CT Entries: ' + lct.get(i).Core_Status__c + ' ' + lct.get(i).Core_Employee_Name__c + ' ' 
                         + lct.get(i).Core_WWID__c + ' ' + lct.get(i).Core_Opportunity_Team_Member_Role__c 
                         + ' ' + lct.get(i).Core_Percent_Contribution__c);
          

        }
        op.Core_Status__c = 'Pending';
        try {
             
            update op; 
                   
        } catch(DmlException e) {
            System.debug('Exception: ' + e.getMessage());
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
        //System.assert(!lop.isEmpty());

        OpportunityLineItem op = lop.get(0);        
        op.Core_Status__c = 'Win Approved';
        op.Core_Approved_Commissionable__c='Yes' ; 
        op.Core_Approved_Decision_Date__c = System.today();
        op.Core_Approved_Total_Price__c = op.UnitPrice * op.Quantity;
        op.TotalPrice = op.UnitPrice * op.Quantity;
        op.Core_BU_Short_Name__c = 'BU Short Name';
        op.Core_Approved_KPI_Product_Group__c  = 'test unqualified';
        op.Core_Approved_Prime_Account_Name__c  = 'test PrimeAccount';
        op.Core_Claim_Date__c = System.today();
        Core_OpportunityLineItemHandler.alreadyAddedCommissionableTransactions = false;
        try {
             
            update op; 
                   
        } catch(DmlException e) {
            System.debug('Exception: ' + e.getMessage());
        }

        lop = 
            [SELECT Id, Core_Status__c, Core_Approved_Decision_Date__c, Core_Approved_Total_Price__c, Core_Claim_Date__c, TotalPrice, UnitPrice, Quantity, Core_BU_Short_Name__c,Core_Approved_Commissionable__c
             FROM OpportunityLineItem WHERE Id = :lstOP.get(0).Id];
        //System.assert(!lop.isEmpty());
        System.debug('Status After Update:' + lop.get(0).Core_Status__c);

        List <Core_Commissionable_Transaction__c> lct = [            
            SELECT Core_Account_Name__c,Core_Approved_Total_Price__c,Core_CIM_ID__c,Core_Claim_Date__c,
            Core_Employee_Name__c,Core_Last_Approved_Date__c,Core_Milestone_Area__c,
            Core_Milestone_Focus__c,Core_Milestone__c,Core_Opportunity_Name__c,Core_Opportunity_Team_Member_Role__c,
            Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,Core_Product_Type__c,
            Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,Core_Transaction_Type__c,Core_WWID__c,Core_Approved_BU_Short_Name__c
            FROM Core_Commissionable_Transaction__c 
        ];

        //System.assert(!lct.isEmpty());
        System.debug(lct.size() + ' entries in Commissionable Transactions associated with milestone ' + op.Id);   
        for(Integer i=0; i<lct.size(); i++) {
            System.debug('CT Entries: ' + lct.get(i).Core_Status__c + ' ' + lct.get(i).Core_Employee_Name__c + ' ' 
                         + lct.get(i).Core_WWID__c + ' ' + lct.get(i).Core_Opportunity_Team_Member_Role__c 
                         + ' ' + lct.get(i).Core_Percent_Contribution__c);
          

        }
        op.Core_Status__c = 'Pending';
        try {
             
            update op; 
                   
        } catch(DmlException e) {
            System.debug('Exception: ' + e.getMessage());
        }
        //System.assert(lct.size() == 5);       
    }

    static testMethod void testApproveAndRejectOP() {
        
        newTXNSetting1.add (new Core_Commission_Account_BU_SG_Setting__c(Name='CMSN01', 
                                                                                 Core_Approved_BU_Product_Segment__c='<any>', 
                                                                                 Core_Approved_BU_Short_Name__c='CCG',
                                                                                 Core_Approved_Opp_Product_Segment__c='<any>',     
                                                                                 Core_Approved_Prime_Account_Name__c='Dell', 
                                                                                 Core_Approved_Sales_Group__c = 'CCG Sales Group',
                                                                                 Core_IsActive__c=true));
        newTXNSetting1.add (new Core_Commission_Account_BU_SG_Setting__c(Name='CMSN02', 
                                                                                 Core_Approved_BU_Product_Segment__c='<any>', 
                                                                                 Core_Approved_BU_Short_Name__c='null',
                                                                                 Core_Approved_Opp_Product_Segment__c='<any>',     
                                                                                 Core_Approved_Prime_Account_Name__c='Dell', 
                                                                                 Core_Approved_Sales_Group__c = 'CCG Sales Group',
                                                                                 Core_IsActive__c=true));
        newTXNSetting1.add (new Core_Commission_Account_BU_SG_Setting__c(Name='CMSN03', 
                                                                                 Core_Approved_BU_Product_Segment__c='<any>', 
                                                                                 Core_Approved_BU_Short_Name__c='null',
                                                                                 Core_Approved_Opp_Product_Segment__c='null',     
                                                                                 Core_Approved_Prime_Account_Name__c=null, 
                                                                                 Core_Approved_Sales_Group__c = 'CCG Sales Group',
                                                                                 Core_IsActive__c=true));
        newTXNSetting1.add (new Core_Commission_Account_BU_SG_Setting__c(Name='CMSN04', 
                                                                                 Core_Approved_BU_Product_Segment__c='null', 
                                                                                 Core_Approved_BU_Short_Name__c='null',
                                                                                 Core_Approved_Opp_Product_Segment__c='null',     
                                                                                 Core_Approved_Prime_Account_Name__c='null', 
                                                                                 Core_Approved_Sales_Group__c = 'null',
                                                                                 Core_IsActive__c=true));
        insert newTXNSetting1;
         
        createData();
        
        List<OpportunityLineItem> lop = 
            [SELECT Id, Core_Status__c, Core_Approved_By__c, Core_Approved_Decision_Date__c, Core_Approved_Total_Price__c, Core_Claim_Date__c, TotalPrice, UnitPrice, Quantity, Core_BU_Short_Name__c,Core_Approved_Commissionable__c
             FROM OpportunityLineItem WHERE Id = :lstOP.get(0).Id];
        //System.assert(!lop.isEmpty());

        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('ProfileName: '+ profileName);

        OpportunityLineItem op = lop.get(0);        
        op.Core_Status__c = 'Win Approved';
        op.Core_Approved_Commissionable__c='Yes'; 
        op.Core_Approved_By__c = profileName;
        op.Core_Approved_Decision_Date__c = System.today();
        op.Core_Approved_Total_Price__c = op.UnitPrice * op.Quantity;
        op.TotalPrice = op.UnitPrice * op.Quantity;
        op.Core_BU_Short_Name__c = 'BU Short Name';
        op.Core_Approved_KPI_Product_Group__c  = 'test unqualified';
        op.Core_Approved_Prime_Account_Name__c  = 'test PrimeAccount';
        op.Core_Claim_Date__c = System.today();
        Core_OpportunityLineItemHandler.alreadyAddedCommissionableTransactions = false;
        system.debug('Attempting to set OP.Core_Approved_By__c to: '+ op.Core_Approved_By__c);
        // test.startTest();
        try {
           
          //  update op; 
         //   test.stopTest();        
        } catch(DmlException e) {
            System.debug('Exception: ' + e.getMessage());
        }

        Long start = System.now().getTime();

        List <Core_Commissionable_Transaction__c> lct = [            
            SELECT Core_Account_Name__c,Core_Approved_Total_Price__c,Core_CIM_ID__c,Core_Claim_Date__c,
            Core_Employee_Name__c,Core_Last_Approved_Date__c,Core_Milestone_Area__c,
            Core_Milestone_Focus__c,Core_Milestone__c,Core_Opportunity_Name__c,Core_Opportunity_Team_Member_Role__c,
            Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,Core_Product_Type__c,
            Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,Core_Transaction_Type__c,Core_WWID__c,Core_Approved_BU_Short_Name__c
            FROM Core_Commissionable_Transaction__c 
            ORDER BY Core_WWID__c ASC, Core_Employee_Name__c ASC
        ];
        for(Core_Commissionable_Transaction__c ct : lct)
        {        
            System.debug('Core_Account_Name__c ' + ct.Core_Account_Name__c + 
                                                                                        ' Core_Approved_Total_Price__c ' + ct.Core_Approved_Total_Price__c + 
                                                                                        ' Core_Last_Approved_Date__c ' + ct.Core_Last_Approved_Date__c + 
                                                                                        ' Core_Status__c ' + ct.Core_Status__c);
        }   

        //System.assert(!lct.isEmpty());
        System.debug(lct.size() + ' entries in Commissionable Transactions associated with OP ' + op.Id);  
        //System.assert(lct.size() == 5);  

        lop = 
            [SELECT Id, Core_Status__c, Core_Approved_By__c, Core_Approved_Decision_Date__c, Core_Approved_Total_Price__c, Core_Claim_Date__c, TotalPrice, UnitPrice, Quantity, Core_BU_Short_Name__c
             FROM OpportunityLineItem WHERE Id = :lstOP.get(0).Id];
        //System.assert(!lop.isEmpty());
        System.debug('Status After Update:' + lop.get(0).Core_Status__c + ' Core_Approved_By__c ' + lop.get(0).Core_Approved_By__c );

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
            System.debug('Exception: ' + e.getMessage());
        }

        start = System.now().getTime();

        List <Core_Commissionable_Transaction__c> lct2 = [            
            SELECT Core_Account_Name__c,Core_Approved_Total_Price__c,Core_CIM_ID__c,Core_Claim_Date__c,
            Core_Employee_Name__c,Core_Last_Approved_Date__c,Core_Milestone_Area__c,
            Core_Milestone_Focus__c,Core_Milestone__c,Core_Opportunity_Name__c,Core_Opportunity_Team_Member_Role__c,
            Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,Core_Product_Type__c,
            Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,Core_Transaction_Type__c,Core_WWID__c,Core_Approved_BU_Short_Name__c
            FROM Core_Commissionable_Transaction__c 
            WHERE Core_Status__c != 'Approved'
            ORDER BY Core_WWID__c ASC, Core_Employee_Name__c ASC
        ];

        for(Core_Commissionable_Transaction__c ct : lct2)
        {        
            System.debug('UNAPPROVED Core_Account_Name__c ' + ct.Core_Account_Name__c + ' Core_Approved_Total_Price__c ' 
                         + ct.Core_Approved_Total_Price__c + ' Core_Last_Approved_Date__c ' + ct.Core_Last_Approved_Date__c + ' Core_Status__c ' + ct.Core_Status__c);
        }

        //System.assert(!lct2.isEmpty());
        System.debug(lct2.size() + ' unapproved entries in Commissionable Transactions associated with OP ' + op.Id);  
        
        lop = 
            [SELECT Id, Core_Status__c, Core_Approved_By__c, Core_Approved_Decision_Date__c, Core_Approved_Total_Price__c, Core_Claim_Date__c, TotalPrice, UnitPrice, Quantity, Core_BU_Short_Name__c
             FROM OpportunityLineItem WHERE Id = :lstOP.get(0).Id];
        //System.assert(!lop.isEmpty());
        System.debug('Status After Update:' + lop.get(0).Core_Status__c + ' Core_Approved_By__c ' + lop.get(0).Core_Approved_By__c );

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
            System.debug('Exception: ' + e.getMessage());
        }

        List <Core_Commissionable_Transaction__c> lct3 = [            
            SELECT Core_Account_Name__c,Core_Approved_Total_Price__c,Core_CIM_ID__c,Core_Claim_Date__c,
            Core_Employee_Name__c,Core_Last_Approved_Date__c,Core_Milestone_Area__c,
            Core_Milestone_Focus__c,Core_Milestone__c,Core_Opportunity_Name__c,Core_Opportunity_Team_Member_Role__c,
            Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,Core_Product_Type__c,
            Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,Core_Transaction_Type__c,Core_WWID__c,Core_Approved_BU_Short_Name__c
            FROM Core_Commissionable_Transaction__c 
            ORDER BY Core_Transaction_Timestamp__c ASC, Core_WWID__c ASC, Core_Employee_Name__c ASC
        ];

        //System.assert(!lct3.isEmpty());
        System.debug(lct3.size() + ' total entries in Commissionable Transactions associated with OP ' + op.Id);    
       
        lop = 
            [SELECT Id, Core_Status__c, Core_Approved_By__c, Core_Approved_Decision_Date__c, Core_Approved_Total_Price__c, Core_Claim_Date__c, TotalPrice, UnitPrice, Quantity, Core_BU_Short_Name__c
             FROM OpportunityLineItem WHERE Id = :lstOP.get(0).Id];
        //System.assert(!lop.isEmpty());
        System.debug('Status After Update:' + lop.get(0).Core_Status__c + ' Core_Approved_By__c ' + lop.get(0).Core_Approved_By__c );

        op = lop.get(0);  
        op.Core_Status__c = 'Production Win';
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
            System.debug('Exception: ' + e.getMessage());
        }

        start = System.now().getTime();
        lop = 
            [SELECT Id, Core_Status__c, Core_Approved_By__c, Core_Approved_Decision_Date__c, Core_Approved_Total_Price__c, Core_Claim_Date__c, TotalPrice, UnitPrice, Quantity, Core_BU_Short_Name__c
             FROM OpportunityLineItem WHERE Id = :lstOP.get(0).Id];
        //System.assert(!lop.isEmpty());
        System.debug('Status After Update:' + lop.get(0).Core_Status__c + ' Core_Approved_By__c ' + lop.get(0).Core_Approved_By__c );

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
            System.debug('Exception: ' + e.getMessage());
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
        testOppLineItems[1].Description = '';
        testOppLineItems[2].Core_BU_Short_Name__c = 'T23';
        testOppLineItems[2].Core_Group_Code__c = 'GC23'; // We're not tracking this field!
        
        Test.startTest();
        update testOppLineItems;
        Test.stopTest();
        
        List<Core_Opportunity_Product_History__c> oppProdHistory = [select Core_Opportunity__c, Core_Opportunity_Product_ID__c,
                                                                           Core_Field__c, Core_Old_Value__c, Core_New_Value__c
                                                                    from Core_Opportunity_Product_History__c
                                                                    order by Core_Opportunity_Product_ID__c, Core_Field__c];
        
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
            oppLineItem.Core_BU_Short_Name__c = oppLineItem.Core_BU_Short_Name__c + 'X';
            oppLineItem.Core_Loss_Cancel_Reason__c = 'Testing';
            oppLineItem.Core_Status__c = 'On Hold';
        }
        
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
        
    }

//*************************************************************Test Method for OpportunityLineItem tests related to BU Mapping Record************/ 
 testMethod static void testBUMapping(){
     
        String CRON_EXP = system.now().addMinutes(10).format('ss mm HH dd MM ? yyyy');   
         RecordType accRecordType = [select id from recordType where sObjectType='Account' and name ='Intel Account' limit 1];
                               
              Account ac=new Account(Name='CEP Test Account',recordtypeid=accRecordType.id,BillingCountryCode = 'USA',BIllingStateCode = 'AL', 
                                    Core_Sales_Groups__c = 'CCG Sales Group', BillingCity = 'Alabama',BillingStreet = 'test',Core_Account_Type__c = 'Other',
                                    Core_Sales_Segment__c = 'Reseller/Channel', Core_Sub_Geo__c = 'CEE'); 
              insert ac; 
        // Simple test data
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity testOpp_BU = Core_Test_Utility.createOpportunity(1)[0];
        testOpp_BU.AccountId = ac.Id;       
        testOpp_BU.RecordTypeId =newOppRecTypeId;
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
        testOpp_BU.Core_Product_Application__c='Business Desktop';
        update testOpp_BU;  
        
         oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0001', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));      
       
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];      
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU; 
        
         oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0010', UnitPrice=11, Quantity=11, Core_BU_Short_Name__c='T11',
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        
        
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='Business Desktop';
        update testOpp_BU;
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0011', UnitPrice=11, Quantity=11, Core_BU_Short_Name__c='T11',
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
       
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
        
       oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0100', UnitPrice=11, Quantity=11, Core_BU_Short_Name__c='T11',
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
       
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='Business Desktop';
        update testOpp_BU;
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0101', UnitPrice=11, Quantity=11, Core_BU_Short_Name__c='T11',
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
       
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;      
         oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0110', UnitPrice=11, Quantity=11, Core_BU_Short_Name__c='T11',Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        
        
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='Business Desktop';
        update testOpp_BU;
         oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0111', UnitPrice=11, Quantity=11, Core_BU_Short_Name__c='T11',
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
       
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1000', UnitPrice=11, Quantity=11, Core_BU_Short_Name__c='T11',
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='Business Desktop';
        update testOpp_BU;
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1001', UnitPrice=11, Quantity=11, Core_BU_Short_Name__c='T11',Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
       
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1010', UnitPrice=11, Quantity=11, Core_BU_Short_Name__c='T11',
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
       
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='Business Desktop';
        update testOpp_BU;
         oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1011', UnitPrice=11, Quantity=11, Core_BU_Short_Name__c='T11',
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
       
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1100', UnitPrice=11, Quantity=11, Core_BU_Short_Name__c='T11',
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='Business Desktop';
        update testOpp_BU;
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1101', UnitPrice=11, Quantity=11, Core_BU_Short_Name__c='T11',
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
       
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
        oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1110', UnitPrice=11, Quantity=11, Core_BU_Short_Name__c='T11',
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='Business Desktop';
        update testOpp_BU;
       oppBUItemList.add(new  OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1111', UnitPrice=11, Quantity=11, Core_BU_Short_Name__c='T11',
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        insert oppBUItemList;       
        /*
        Test.StartTest();            
           System.schedule('Core_Invoke_BatchToUpdateShortName', CRON_EXP, new Core_Invoke_BatchToUpdateShortName());
           // database.executebatch(new Core_OpportunityLineItem_BatchClass(),50);            
        Test.StopTest();
        */
       
    }   
    
    static void setupTestF() {

        // Create and Insert test accounts
        accountList = Core_Test_Utility.createAccount(6);       
        accountList[0].Name = 'Dell';
        accountList[0].Core_Sales_Groups__c = 'CCG Sales Group';
        accountList[1].Name = 'HP';
        accountList[1].Core_Sales_Groups__c = 'CCG Sales Group';
        accountList[2].Name = 'Google';
        accountList[2].Core_Sales_Groups__c = 'CCG Sales Group';
        accountList[3].Name = 'Apple';
        accountList[3].Core_Sales_Groups__c = 'CCG Sales Group';
        accountList[4].Name = 'Target';
        accountList[4].Core_Sales_Groups__c = 'CCG Sales Group';
        accountList[5].Name = 'Target1';
        accountList[5].Core_Sales_Groups__c = 'CCG Sales Group';
        insert accountList;
        
        // Create and Insert a test Opportunity
        List<Opportunity> listOpportunity = Core_Test_Utility.createOpportunity(1); 
        lstUser = Core_Test_Utility.Core_User(1);
        opp = listOpportunity[0]; 
        opp.Core_Opportunity_Type__c='Design: Original';
        opp.Core_First_Customer_Ship_Date__c = System.Today();          
        opp.Core_Technical_Owner__c = UserInfo.getUserId();
        opp.Core_Solution_Area__c='CCG Unite Deal #';
        opp.Core_Intel_Platform__c = 'Apollo Lake D';
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

    }
    
      static testMethod void Core_OpportunityLineItemHandler_Test_1F() {    
        setupTestF();
        Test.startTest();

        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(1, listPBE, opp);
        insert oppLineItems;

        Core_OpportunityLineItemHandler.opportunityLineItemAfterHandler(oppLineItems, null, null, null, true, false, false);

        Test.stopTest();
    }

    static testMethod void Core_OpportunityLineItemHandler_Test_2F() {  
        setupTestF();

        Test.startTest();

        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(1, listPBE, opp);
        insert oppLineItems;

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
        Test.stopTest();

        List<OpportunityLineItem> insertedOLI = [SELECT Core_Group__c, Core_Group_Code__c, Core_Division__c, Core_Division_Code__c FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];

        System.assertEquals('AAA', insertedOLI[0].Core_Group__c);
        System.assertEquals('111', insertedOLI[0].Core_Group_Code__c);
        System.assertEquals('BBB', insertedOLI[0].Core_Division__c);
        System.assertEquals('000', insertedOLI[0].Core_Division_Code__c);

    }
 static testMethod void insertPartner_Test_1F() {  
        setupTestF();
        Test.startTest();
        List<OpportunityLineItem> oppLineItemsupdate = new List<OpportunityLineItem> ();
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(5, listPBE, opp);
        list<user> lstUser = Core_Test_Utility.Core_User(1);
        insert lstUser;  
        List<Opportunity> listOpportunity = Core_Test_Utility.createOpportunity(5);  
        listOpportunity[0].Core_Commissionable__c='No';     
        listOpportunity[0].Core_Opportunity_Type__c='Design: Secondary';
        listOpportunity[0].Core_First_Customer_Ship_Date__c = System.Today();
        listOpportunity[0].Core_Technical_Owner__c=lstUser[0].Id;
        listOpportunity[0].Core_Solution_Area__c='CCG Unite Deal #';
        listOpportunity[0].CloseDate=system.today().addMonths(6);
        listOpportunity[0].Core_Intel_Platform__c = 'Apollo Lake D';
        listOpportunity[0].AccountId = accountList[0].Id;
        listOpportunity[1].Core_Opportunity_Type__c='Design: Secondary';
        listOpportunity[1].Core_Solution_Area__c='CCG Unite Deal #';
        listOpportunity[1].CloseDate=system.today().addMonths(4);
        listOpportunity[1].Core_First_Customer_Ship_Date__c = System.Today();
        listOpportunity[1].Core_Intel_Platform__c = 'Apollo Lake D';
        listOpportunity[1].Core_Technical_Owner__c=lstUser[0].Id;
        listOpportunity[1].AccountId = accountList[1].Id;
        listOpportunity[2].Core_Opportunity_Type__c='Design: Original';
        listOpportunity[2].Core_Solution_Area__c='CCG Unite Deal #';
        listOpportunity[2].Core_First_Customer_Ship_Date__c = System.Today();
        listOpportunity[2].Core_Technical_Owner__c=lstUser[0].Id;
        listOpportunity[2].CloseDate=system.today().addMonths(-2);
        listOpportunity[2].Core_Intel_Platform__c = 'Apollo Lake D';
        listOpportunity[2].AccountId = accountList[2].Id;
        listOpportunity[3].Core_Opportunity_Type__c='Deal: Sell-to';
        listOpportunity[3].Core_Solution_Area__c='CCG Unite Deal #';
        listOpportunity[3].CloseDate=system.today();
        listOpportunity[3].AccountId = accountList[3].Id;

        //Design part//
        listOpportunity[4].Core_Technical_Owner__c=lstUser[0].Id; 
        listOpportunity[4].Core_Intel_Platform__c='Apollo Lake D';
        listOpportunity[4].Core_Opportunity_Type__c='Design: Secondary';
        listOpportunity[4].Core_First_Customer_Ship_Date__c=system.today();
        listOpportunity[4].AccountId = accountList[4].Id;
        insert listOpportunity;
        oppLineItems[0].Core_Vendor__c = accountList[0].Id;
        oppLineItems[0].OpportunityId = listOpportunity[0].Id; 
        oppLineItems[1].OpportunityId = listOpportunity[1].Id; 
        oppLineItems[2].OpportunityId = listOpportunity[2].Id;  
        oppLineItems[3].OpportunityId = listOpportunity[3].Id;   
        oppLineItems[4].OpportunityId = listOpportunity[4].Id;     
        insert oppLineItems;
        oppLineItemsupdate.addAll(oppLineItems);
        oppLineItemsupdate[0].Core_Vendor__c = accountList[1].Id;
        oppLineItemsupdate[1].Core_Vendor__c =  accountList[2].Id;
        oppLineItemsupdate[2].Core_Vendor__c =  accountList[3].Id;
        oppLineItemsupdate[3].Core_Vendor__c =  accountList[4].Id;
        oppLineItemsupdate[4].Core_Vendor__c =  accountList[5].Id;
        update oppLineItemsupdate;
        //List<> lstOppLItem = new List<OpportunityLineItem>();
        //lstOppLItem.add(oppLineItems);
        map<id,OpportunityLineItem> mp = new map<id,OpportunityLineItem>();
        mp.put(oppLineItemsupdate[0].id,oppLineItemsupdate[0]);
        mp.put(oppLineItemsupdate[1].id,oppLineItemsupdate[1]);
        mp.put(oppLineItemsupdate[2].id,oppLineItemsupdate[2]);
        mp.put(oppLineItemsupdate[3].id,oppLineItemsupdate[3]);
        mp.put(oppLineItemsupdate[4].id,oppLineItemsupdate[4]);
        Core_OpportunityLineItemHandler.beforeInsertForecastRecords(oppLineItems );
        Core_OpportunityLineItemHandler.insertForecastRecords(oppLineItems,True);
        Core_OpportunityLineItemHandler.deleteForecastRecords(mp);
        Core_OpportunityLineItemHandler.updateForecastRecords(oppLineItems,mp);
        Core_OpportunityLineItemHandler.opptyLineItemUpdateSalesGroupandUserCovg(oppLineItems,mp,oppLineItems,mp,True); 
        // Core_OpportunityLineItemHandler.addCommissionableTransactions(oppLineItems,mp,oppLineItems,mp,false,true);
        Test.stopTest();
        List<Core_Opportunity_Partner__c> relatedPartners = [SELECT Id, Core_Partner__c, Core_Partner_Role__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c = :listOpportunity[0].Id]; 

        System.assertEquals(1, relatedPartners.size());
        //System.assertEquals(accountList[0].Id, relatedPartners.get(0).Core_Partner__c);
        System.assertEquals('Vendor', relatedPartners.get(0).Core_Partner_Role__c);

           
    } 
   static testMethod void test_opportunityApprovalHistoryInsert(){
   system.debug('checktestclass');
        setupTest();
        Test.startTest();
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(2, listPBE, opp);
        Core_OpportunityLineItemHandler.alreadyInsertedApprovalHisotry=false;
        oppLineItems[0].Core_Status__c ='On Hold';
        oppLineItems[0].Core_Approved_By__c='Test User1';
        oppLineItems[1].Core_Status__c ='Pending'; 
        oppLineItems[1].Core_Production_Claim_Date__c=system.today();     
        insert oppLineItems;
        Core_Opportunity_Approval_History__c objAH=new Core_Opportunity_Approval_History__c();
        objAH.Core_Opp_Hist_OpportunityLineItemID__c =oppLineItems[1].Id;
        objAH.Core_Opp_Hist_Production_Claim_Date__c=oppLineItems[1].Core_Production_Claim_Date__c;
        insert objAH;  
        oppLineItems[0].Core_Status__c ='Win Approved';
        oppLineItems[0].Core_Approved_By__c='Test User2';  
        oppLineItems[1].Core_Status__c ='Production Cancelled';      
        update oppLineItems;      
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
        fcObjList.add(new  Core_Opp_FC_Prod_Schedule__c (Core_Opp_Line_Item_RecordID__c=oppLineItems[0].Id,Core_Opp_FC_Approval_Status__c='Approved',Core_Opp_FC_Prod_Sales_Price__c=3,Core_Opp_FC_Opportunity__c=oppLineItems[0].OpportunityID));
        fcObjList.add(new  Core_Opp_FC_Prod_Schedule__c (Core_Opp_Line_Item_RecordID__c=oppLineItems[0].Id,Core_Opp_FC_Approval_Status__c='Pending',Core_Opp_FC_Prod_Sales_Price__c=3,Core_Opp_FC_Opportunity__c=oppLineItems[0].OpportunityID));
        insert fcObjList;
        oppLineItems[1].Core_Status__c='Lost';
        oppLineItems[2].Core_Status__c='Win Approved';
        oppLineItems[2].Quantity=5;
        update oppLineItems;
        delete oppLineItems;
        Test.stopTest();
    }
    
    static testMethod void deleteKPI_Test1(){
        setupTest();
        Test.startTest();
        List<OpportunityLineItem> oppLineItems = Core_Test_Utility.createOpportunityLineItems(3, listPBE, opp);
        oppLineItems[0].Core_Vendor__c = accountList[0].Id;
        oppLineItems[0].Quantity=12;
        oppLineItems[0].Core_Status__c='Pending';
        oppLineItems[1].Core_Status__c='Pending';
        oppLineItems[2].Quantity=3;
        insert oppLineItems;        
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
        
        delete product;
        Test.stopTest();
    }
}