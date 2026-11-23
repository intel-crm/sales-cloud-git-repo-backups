/********************************************************************************************************************
    Class Name: Core_OpportunityLineBUShort_Weekend_Test
    Version     : 1.0 
    Created Date: 15 Sept 2020
    Function    : Test Class to cover the Weekly batch classes
    *******************************************************************************************************************/
@isTest
public class Core_OpportunityLineBUShort_Weekend_Test {
    
     public static List<Core_BU_Mapping_Table__c> mappingObjList = new List<Core_BU_Mapping_Table__c>();
    public static List<OpportunityLineItem> oppBUItemList = new List<OpportunityLineItem>();
    
     @testSetup
    private static void setupTestData() {
        
         Core_Trigger_Executions__c triggerEntry_BU = new Core_Trigger_Executions__c(
            Name='set_BUShortName', Core_Object__c='OpportunityLineItem', Core_Class_Name__c='Core_OpportunityLineItemHandler',
            Core_Trigger_Events__c='before insert', Core_Active__c=false, Core_Description__c='testing BU Mapping');
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
        
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='00118',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='',
                                                  Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='0011',Core_BU_Shortname__c='CD')); 
        
         mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='00119',Core_Division_Shortname__c='CCD',Core_Product_Type__c='',
                                                  Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='0011',Core_BU_Shortname__c='CD')); 
        
         mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='001167',Core_Division_Shortname__c='CCD',Core_Product_Type__c='',
                                                  Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='0011',Core_BU_Shortname__c='CD'));
        
                 mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0011679',Core_Division_Shortname__c='CCD',Core_Product_Type__c='',
                                                  Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='0011',Core_BU_Shortname__c='CD'));
                  mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='00116709',Core_Division_Shortname__c='CCD',Core_Product_Type__c='Emerging Technologies',
                                                  Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='0011',Core_BU_Shortname__c='CD'));
        
                  mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='001916709',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='',
                                                  Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=1,Core_BU_Segment__c='0011',Core_BU_Shortname__c='CD'));
        

        insert mappingObjList;
        
        Core_BU_Mapping_Email_recipients__c recObj = new Core_BU_Mapping_Email_recipients__c();
        recObj.Core_isActive__c=true;
        recObj.Name='1';
        recObj.Core_User_Ids__c='Salesforce@intel.sfdc.com';  
        insert recObj;     
        
    }
    
            testMethod static void testBUMappingWeekly(){
        String CRON_EXP = system.now().addMinutes(10).format('ss mm HH dd MM ? yyyy');
        
                Core_Opp_Bypass_Validation_Rule__c bp = new Core_Opp_Bypass_Validation_Rule__c();
            bp.Bypass__c = true;
            bp.SetupOwnerId = Core_Test_Utility.systemAdminUser.Id;
            insert bp;
                
        Account testAcct_BU = Core_Test_Utility.createAccount(1)[0];
         testAcct_BU.Core_Sales_Groups__c = 'Americas Brazil Sales Group';
         testAcct_BU.Industry = 'Education';
         testAcct_BU.Core_Sub_Industry__c = 'Student';
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
        testOpp_BU.Core_Product_Application__c='Workstation';
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
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0011', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
      
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
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
        testOpp_BU.Core_Product_Application__c='';
        testOpp_BU.CloseDate=Date.valueOf('2021-01-02');
       // System.assertEquals(testOpp_BU.Core_Product_Application__c, 'Workstation','Connected Home');
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
        testOpp_BU.Core_Product_Application__c='';
         testOpp_BU.CloseDate=Date.valueOf('2022-01-02');
        update testOpp_BU;
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0111', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
       
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        testOpp_BU.CloseDate=Date.valueOf('2022-01-02');
        testOpp_BU.StageName = 'Lost';
        testOpp_BU.Core_Loss_Cancel_Reason__c = 'Cancelled - Budget';
        testOpp_BU.Core_Loss_Cancel_Details__c= 'Cancelled - Budget';
       // testOpp_BU.Core_Approval_Status__c='Approved';
      
                System.runAs(Core_Test_Utility.systemAdminUser) { update testOpp_BU;}
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1000', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
       
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
         testOpp_BU.CloseDate=Date.valueOf('2022-01-02');
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1001', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1010', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        testOpp_BU.CloseDate=Date.valueOf('2022-01-02');
        update testOpp_BU;
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1011', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
         testOpp_BU.CloseDate=Date.valueOf('2022-01-02');
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1100', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
       
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
         testOpp_BU.CloseDate=Date.valueOf('2022-01-02');
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1101', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
      
        
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
         testOpp_BU.CloseDate=Date.valueOf('2022-01-02');
        update testOpp_BU;
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1110', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c=''; //Workstation
         update testOpp_BU;
        /*oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1111', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='Workstation';
        update testOpp_BU;  */      
        insert oppBUItemList;       
    //}catch(Exception e){System.debug('Exception from Test class-->'+e.getMessage()+' @ Line Number'+e.getLinenumber());}  
        Test.StartTest();              
            database.executebatch(new Core_OpportunityLineBUShortName_Weekly(),20); 
        Test.StopTest();
         Core_OppLineItem_Batch_Helper.WrapperHelper wrap;
          wrap = Core_OppLineItem_Batch_Helper.prepareBuMappingTable();
          Core_BU_Mapping_Table__c finalBuMap;
          finalBuMap = Core_OppLineItem_Batch_Helper.buShortNmUpdateLogic(oppBUItemList[0], wrap);
           finalBuMap = Core_OppLineItem_Batch_Helper.buShortNmUpdateLogic(oppBUItemList[1], wrap);
         finalBuMap = Core_OppLineItem_Batch_Helper.buShortNmUpdateLogic(oppBUItemList[2], wrap);
        finalBuMap = Core_OppLineItem_Batch_Helper.buShortNmUpdateLogic(oppBUItemList[3], wrap);
        finalBuMap = Core_OppLineItem_Batch_Helper.buShortNmUpdateLogic(oppBUItemList[4], wrap);
        finalBuMap = Core_OppLineItem_Batch_Helper.buShortNmUpdateLogic(oppBUItemList[5], wrap);
        finalBuMap = Core_OppLineItem_Batch_Helper.buShortNmUpdateLogic(oppBUItemList[6], wrap);

        //Test.StopTest();
    }


}