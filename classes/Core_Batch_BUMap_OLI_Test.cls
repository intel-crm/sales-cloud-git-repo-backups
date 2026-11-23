@isTest 
public class Core_Batch_BUMap_OLI_Test{
     public static List<Core_BU_Mapping_Table__c> mappingObjList = new List<Core_BU_Mapping_Table__c>();
    public static List<OpportunityLineItem> oppBUItemList = new List<OpportunityLineItem>();
     @testSetup
    private static void setupTestData() {
               
        Core_Trigger_Executions__c triggerEntry_BU = new Core_Trigger_Executions__c(
            Name='set_BUShortName', Core_Object__c='OpportunityLineItem', Core_Class_Name__c='Core_OpportunityLineItemHandler',
            Core_Trigger_Events__c='before insert', Core_Active__c=true, Core_Description__c='testing BU Mapping');
        insert triggerEntry_BU;             
       mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1111',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='Emerging Technologies',
                                                  Core_Product_Segment__c='Client Computing', Core_Product_Application__c='Business Desktop',Core_Weightage__c=4,
                                                  Core_BU_Segment__c='1111',Core_BU_Shortname__c='ABCD',Core_Processed__c=false)); 
        
    }
    
    testMethod static void TestBuLogic(){
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1111',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='Emerging Technologies',
                                                  Core_Product_Segment__c='Client Computing', Core_Product_Application__c='Business Desktop',Core_Weightage__c=4,
                                                  Core_BU_Segment__c='1111',Core_BU_Shortname__c='ABCD',Core_Processed__c=false)); 
        insert mappingObjList;
        Account testAcct_BU = Core_Test_Utility.createAccount(1)[0];
         testAcct_BU.Core_Sales_Groups__c = 'CCG Sales Group';
         testAcct_BU.Industry = 'Education';
         testAcct_BU.Core_Sub_Industry__c = 'Student';
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
        
        Test.StartTest();            
           
          Core_OppLineItem_Batch_Helper.WrapperHelper wrap;
         wrap = Core_OppLineItem_Batch_Helper.prepareBuMappingTable();
          Core_BU_Mapping_Table__c finalBuMap;
         finalBuMap = Core_OppLineItem_Batch_Helper.buShortNmUpdateLogic(oppBUItemList[0], wrap);
        Test.StopTest();
    }

}