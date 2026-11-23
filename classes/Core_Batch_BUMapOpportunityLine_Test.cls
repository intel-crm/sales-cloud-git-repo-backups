/**************************************************************************************
Apex Class Name:  Core_Batch_BUMapOpportunityLine_Test 
Version     : 1.0 
Created Date:  9/26/17 
Description : Test Class to cover the Weekly batch classes
* Developer                   Date                     Description
* ----------------------------------------------------------------------------                 
* Gaurav K.            		21/07/2022                Initial Revision
*************************************************************************************/
@isTest
public class Core_Batch_BUMapOpportunityLine_Test {
    
    public static List<Core_BU_Mapping_Table__c> mappingObjList = new List<Core_BU_Mapping_Table__c>();
    public static List<OpportunityLineItem> oppBUItemList = new List<OpportunityLineItem>();
    @testSetup
    private static void setupTestData() {
        
        Core_Trigger_Executions__c triggerEntry_BU = new Core_Trigger_Executions__c(
            Name='set_BUShortName', Core_Object__c='OpportunityLineItem', Core_Class_Name__c='Core_OpportunityLineItemHandler',
            Core_Trigger_Events__c='before insert', Core_Active__c=false, Core_Description__c='testing BU Mapping');
        insert triggerEntry_BU;             
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1111',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='Emerging Technologies',
                                                         Core_Product_Segment__c='Client Computing', Core_Product_Application__c='Business Desktop',Core_Weightage__c=4,
                                                         Core_BU_Segment__c='1111',Core_BU_Shortname__c='ABCD', Core_Processed__c = false)); 
        
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1110',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='Emerging Technologies',
                                                         Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c='',Core_Weightage__c=3,Core_BU_Segment__c='1110',Core_BU_Shortname__c='ABC', Core_Mid_Week_Processed__c = false)); 
        
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1101',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='Emerging Technologies',
                                                         Core_Product_Segment__c='', Core_Product_Application__c='Business Desktop',Core_Weightage__c=3,Core_BU_Segment__c='1101',Core_BU_Shortname__c='ABD', Core_End_of_Week_Processed__c = false)); 
        
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1100',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='Emerging Technologies',
                                                         Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='1100',Core_BU_Shortname__c='AB')); 
        
        
        insert mappingObjList;
        
        Core_BU_Mapping_Email_recipients__c recObj = new Core_BU_Mapping_Email_recipients__c();
        recObj.Core_isActive__c=true;
        recObj.Name='1';
        recObj.Core_User_Ids__c='Salesforce@intel.sfdc.com';  
        insert recObj;     
        
    }
    
    testMethod static void testBUMappingWeekly1(){
        String CRON_EXP = system.now().addMinutes(10).format('ss mm HH dd MM ? yyyy');
        
        Account testAcct_BU = Core_Test_Utility.createAccount(1)[0];
  		testAcct_BU.Core_Sub_Industry__c = 'Crop Production';
        testAcct_BU.Industry = 'Agriculture';
        testAcct_BU.Core_Sales_Groups__c='PRC Sales Group';
        insert testAcct_BU;
        //testAcct_BU.Core_CIM_ID__c='1234569';
        //update testAcct_BU;
        
        // Simple test data
        //try{
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity testOpp_BU = Core_Test_Utility.createOpportunity(1)[0];
        testOpp_BU.AccountId = testAcct_BU.Id;       
        testOpp_BU.RecordTypeId =newOppRecTypeId;
        testOpp_BU.StageName ='Qualify';
        insert testOpp_BU;
        
        List<Product2> testProducts_BU = Core_Test_Utility.createProduct(1);
        insert testProducts_BU[0];
        
        List<PricebookEntry> testPBEs_BU = Core_Test_Utility.createPriceBookEntry(1, testProducts_BU, Test.getStandardPricebookId());
        insert testPBEs_BU;
        
        // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the 
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='Business Desktop';
        testOpp_BU.Core_Approved_Date__c =system.today();
        update testOpp_BU;      
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0001', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];      
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;      
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0010', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='Business Desktop';
        update testOpp_BU;
        
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0111', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        testOpp_BU.CloseDate=Date.valueOf('2021-01-01');
        testOpp_BU.StageName = 'Closed/Lost';
        testOpp_BU.Core_Loss_Cancel_Reason__c = 'Cancelled - Budget';
         testOpp_BU.Core_Loss_Cancel_Details__c = 'test cancel';
        // testOpp_BU.Core_Approval_Status__c='Approved';
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1000', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='Business Desktop';
        testOpp_BU.CloseDate=Date.valueOf('2021-01-01');
        update testOpp_BU;
        
        
        insert oppBUItemList;       
        //}catch(Exception e){System.debug('Exception from Test class-->'+e.getMessage()+' @ Line Number'+e.getLinenumber());}  
        Test.StartTest();               
        database.executebatch(new Core_Batch_BUMapOpportunityLine_MidWeek(),20);   
        
        Core_OppLineItem_Batch_Helper.WrapperHelper wrap;
        wrap = Core_OppLineItem_Batch_Helper.prepareBuMappingTable();
        Core_BU_Mapping_Table__c finalBuMap;
        finalBuMap = Core_OppLineItem_Batch_Helper.buShortNmUpdateLogic(oppBUItemList[0], wrap);
        finalBuMap = Core_OppLineItem_Batch_Helper.buShortNmUpdateLogic(oppBUItemList[1], wrap);
        
        
        Test.StopTest();
    }   
    
    testMethod static void testBUMappingWeekly(){
        String CRON_EXP = system.now().addMinutes(10).format('ss mm HH dd MM ? yyyy');
        
        Account testAcct_BU = Core_Test_Utility.createAccount(1)[0];
  		testAcct_BU.Core_Sub_Industry__c = 'Crop Production';
        testAcct_BU.Industry = 'Agriculture';
        testAcct_BU.Core_Sales_Groups__c='PRC Sales Group';
        insert testAcct_BU;
      //  testAcct_BU.Core_CIM_ID__c='1234569';
       // update testAcct_BU;
        
        // Simple test data
        //try{
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity testOpp_BU = Core_Test_Utility.createOpportunity(1)[0];
        testOpp_BU.AccountId = testAcct_BU.Id;       
        testOpp_BU.RecordTypeId =newOppRecTypeId;
        testOpp_BU.StageName ='Qualify';
        testOpp_BU.CloseDate = Date.newInstance(2018, 12, 31);
        insert testOpp_BU;
        
        List<Product2> testProducts_BU = Core_Test_Utility.createProduct(1);
        insert testProducts_BU[0];
        
        List<PricebookEntry> testPBEs_BU = Core_Test_Utility.createPriceBookEntry(1, testProducts_BU, Test.getStandardPricebookId());
        insert testPBEs_BU;
        
        // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the 
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='Business Desktop';
        testOpp_BU.Core_Approved_Date__c =system.today();
        update testOpp_BU;      
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0001', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];      
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;      
        
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0100', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='Business Desktop';
        testOpp_BU.CloseDate=Date.valueOf('2018-01-02');
        System.assertEquals(testOpp_BU.Core_Product_Application__c, 'Business Desktop','Connected Home');
        update testOpp_BU;
        
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0111', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        testOpp_BU.CloseDate=Date.valueOf('2018-01-02');
        testOpp_BU.StageName = 'Closed/Lost';
        testOpp_BU.Core_Loss_Cancel_Reason__c = 'Cancelled - Budget';
        testOpp_BU.Core_Loss_Cancel_Details__c = 'test cancel';
        // testOpp_BU.Core_Approval_Status__c='Approved';
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1000', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='Business Desktop';
        testOpp_BU.CloseDate=Date.valueOf('2018-01-02');
        update testOpp_BU;
        
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1100', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='Business Desktop';
        testOpp_BU.CloseDate=Date.valueOf('2020-01-02');
        update testOpp_BU;
        
        insert oppBUItemList;    
        
        List<OpportunityLineItem> queriedOppLineItems = [SELECT Id, OpportunityId, Description, Core_Status__c, Core_Approved_Date__c FROM OpportunityLineItem WHERE Id IN :oppBUItemList];
        //}catch(Exception e){System.debug('Exception from Test class-->'+e.getMessage()+' @ Line Number'+e.getLinenumber());}  
        Test.StartTest();              
        
        database.executebatch(new Core_Batch_BUMapOpportunityLine_EOW(),20); 
        
        Core_OppLineItem_Batch_Helper.WrapperHelper wrap;
        wrap = Core_OppLineItem_Batch_Helper.prepareBuMappingTable();
        Core_BU_Mapping_Table__c finalBuMap;
        finalBuMap = Core_OppLineItem_Batch_Helper.buShortNmUpdateLogic(oppBUItemList[0], wrap);
        finalBuMap = Core_OppLineItem_Batch_Helper.buShortNmUpdateLogic(oppBUItemList[1], wrap);
        
        
        Test.StopTest();
    }
       
    testMethod static void testBUMapping11(){
        String CRON_EXP = system.now().addMinutes(10).format('ss mm HH dd MM ? yyyy');
        
        Account testAcct_BU = Core_Test_Utility.createAccount(1)[0];
		testAcct_BU.Core_Sub_Industry__c = 'Crop Production';
        testAcct_BU.Industry = 'Agriculture';
        testAcct_BU.Core_Sales_Groups__c='PRC Sales Group';
        insert testAcct_BU;
        
        // Simple test data
        //try{
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity testOpp_BU = Core_Test_Utility.createOpportunity(1)[0];
        testOpp_BU.AccountId = testAcct_BU.Id;       
        testOpp_BU.RecordTypeId =newOppRecTypeId;
        testOpp_BU.StageName ='Qualify';
        insert testOpp_BU;
        
        List<Product2> testProducts_BU = Core_Test_Utility.createProduct(1);
        insert testProducts_BU[0];
        
        List<PricebookEntry> testPBEs_BU = Core_Test_Utility.createPriceBookEntry(1, testProducts_BU, Test.getStandardPricebookId());
        insert testPBEs_BU;
        
        // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the 
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='Business Desktop';
        testOpp_BU.Core_Approved_Date__c =system.today();
        update testOpp_BU;      
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0001', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];      
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;      
        
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0101', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;      
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0110', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='Business Desktop';
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0111', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        
        insert oppBUItemList;       
        //}catch(Exception e){System.debug('Exception from Test class-->'+e.getMessage()+' @ Line Number'+e.getLinenumber());}  
        Test.StartTest();            
        //System.schedule('Core_Invoke_BatchToUpdateShortName', CRON_EXP, new Core_Invoke_BatchToUpdateShortName()); 
        database.executebatch(new Core_Batch_BUMap_OpportunityLineItem(),10);
        
        Core_OppLineItem_Batch_Helper.WrapperHelper wrap;
        wrap = Core_OppLineItem_Batch_Helper.prepareBuMappingTable();
        Core_BU_Mapping_Table__c finalBuMap;
        finalBuMap = Core_OppLineItem_Batch_Helper.buShortNmUpdateLogic(oppBUItemList[0], wrap);
        finalBuMap = Core_OppLineItem_Batch_Helper.buShortNmUpdateLogic(oppBUItemList[1], wrap);
        
        Delete oppBUItemList[0];
        
        Test.StopTest();
    }     
    
    
}