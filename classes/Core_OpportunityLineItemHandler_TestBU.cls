/****************************************************************************************************
Apex Class Name : Core_OpportunityLineItemHandler_Test3
Version         : 1.0 
Created Date    : 07/28/16
Function        : Test class for OpportunityLineItem tests related to History Tracking 
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Dave Hood                   07/28/16               Original Version
****************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_OpportunityLineItemHandler_TestBU {
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
                                                  Core_BU_Segment__c='1111',Core_BU_Shortname__c='ABCD', Core_Processed__c = false)); 

       mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1110',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='Emerging Technologies',
                                                  Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c='',Core_Weightage__c=3,Core_BU_Segment__c='1110',Core_BU_Shortname__c='ABC')); 
      
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1101',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='Emerging Technologies',
                                                  Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=3,Core_BU_Segment__c='1101',Core_BU_Shortname__c='ABD')); //Business Desktop
       
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1100',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='Emerging Technologies',
                                                  Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='1100',Core_BU_Shortname__c='AB')); 
        
        
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1000',Core_Division_Shortname__c='',Core_Product_Type__c='Emerging Technologies',
                                                  Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=1,Core_BU_Segment__c='1000',Core_BU_Shortname__c='A')); 
       
        
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1001',Core_Division_Shortname__c='',Core_Product_Type__c='Emerging Technologies',
                                                  Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='1001',Core_BU_Shortname__c='AD')); //Business Desktop
       
        
         mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1010',Core_Division_Shortname__c='',Core_Product_Type__c='Emerging Technologies',
                                                  Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='1010',Core_BU_Shortname__c='AC')); 
       
        
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='1011',Core_Division_Shortname__c='',Core_Product_Type__c='Emerging Technologies',
                                                  Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=3,Core_BU_Segment__c='1011',Core_BU_Shortname__c='ACD')); //Business Desktop
       
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0100',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='',
                                                  Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=1,Core_BU_Segment__c='0100',Core_BU_Shortname__c='B')); 
       
         mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0101',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='',
                                                  Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='0101',Core_BU_Shortname__c='BD')); //Business Desktop
        
         mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0110',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='',
                                                  Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='0110',Core_BU_Shortname__c='BC')); 
        
         mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0111',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='',
                                                  Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=3,Core_BU_Segment__c='0111',Core_BU_Shortname__c='BCD')); //Business Desktop
      
         mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0001',Core_Division_Shortname__c='',Core_Product_Type__c='',
                                                  Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=1,Core_BU_Segment__c='0001',Core_BU_Shortname__c='D')); //Business Desktop
        
         mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0010',Core_Division_Shortname__c='',Core_Product_Type__c='',
                                                  Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=1,Core_BU_Segment__c='0010',Core_BU_Shortname__c='C')); 
     
         mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0011',Core_Division_Shortname__c='',Core_Product_Type__c='',
                                                  Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='0011',Core_BU_Shortname__c='CD')); //Business Desktop
        
        mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='00118',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='',
                                                  Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='0011',Core_BU_Shortname__c='CD')); 
        
         mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='00119',Core_Division_Shortname__c='CCD',Core_Product_Type__c='',
                                                  Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='0011',Core_BU_Shortname__c='CD')); 
        
         mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='001167',Core_Division_Shortname__c='CCD',Core_Product_Type__c='',
                                                  Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='0011',Core_BU_Shortname__c='CD'));//Business Desktop
        
                 mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='0011679',Core_Division_Shortname__c='CCD',Core_Product_Type__c='',
                                                  Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='0011',Core_BU_Shortname__c='CD')); //Business Desktop
                  mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='00116709',Core_Division_Shortname__c='CCD',Core_Product_Type__c='Emerging Technologies',
                                                  Core_Product_Segment__c='', Core_Product_Application__c='',Core_Weightage__c=2,Core_BU_Segment__c='0011',Core_BU_Shortname__c='CD'));
        
                  mappingObjList.add(new  Core_BU_Mapping_Table__c(Core_Code__c='001916709',Core_Division_Shortname__c='CCD P&L',Core_Product_Type__c='',
                                                  Core_Product_Segment__c='Client Computing', Core_Product_Application__c='',Core_Weightage__c=1,Core_BU_Segment__c='0011',Core_BU_Shortname__c='CD'));//Business Desktop
        
		Test.StartTest();
        insert mappingObjList;
        Test.StopTest();
        Core_BU_Mapping_Email_recipients__c recObj = new Core_BU_Mapping_Email_recipients__c();
        recObj.Core_isActive__c=true;
        recObj.Name='1';
        recObj.Core_User_Ids__c='Salesforce@intel.sfdc.com';  
        insert recObj;  

		Account testAcct_BU = Core_Test_Utility.createAccount(1)[0];
         testAcct_BU.Core_Sales_Groups__c =Core_CRM_Utility.getSalesGroupAPI(); // 'Americas Brazil Sales Group';
         testAcct_BU.Industry = 'Telecommunications'; // 'Education';
         testAcct_BU.Core_Sub_Industry__c = 'Diversified Telecommunications Services'; // 'Student';
        insert testAcct_BU;
        
          
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
        
    }
    
    testMethod static void testBUMapping1(){
        String CRON_EXP = system.now().addMinutes(10).format('ss mm HH dd MM ? yyyy');
        Account testAcct_BU = [SELECT ID,Name FROM Account LIMIT 1];
        Opportunity testOpp_BU = [SELECT ID,Name,Core_Product_Segment__c,Core_Product_Application__c,Core_Approved_Date__c FROM Opportunity LIMIT 1];
        List<Product2> testProducts_BU = [SELECT ID,Name,Core_Product_Type__c,Core_Division_Code_Short_Name__c FROM Product2 LIMIT 1];
		List<PricebookEntry> testPBEs_BU = [SELECT ID,Name FROM PricebookEntry];
        // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the 
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c=''; //Business Desktop
        testOpp_BU.Core_Approved_Date__c =system.today();
        update testOpp_BU;      
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0001', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        //testProducts_BU[0].Core_Product_Type__c='';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        //update testProducts_BU[0];      
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;      
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0010', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
       
        //testProducts_BU[0].Core_Product_Type__c='';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        //System.assertEquals(testOpp_BU.Core_Product_Application__c, 'Business Desktop','Connected Home');

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
       
        //testProducts_BU[0].Core_Product_Type__c='';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0101', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        //testProducts_BU[0].Core_Product_Type__c='';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;      
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0110', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
       
        //testProducts_BU[0].Core_Product_Type__c='';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0111', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
       
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1000', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
       
        //testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1001', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        //testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1010', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        //testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1011', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1100', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
       
        //testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1101', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
      
        
        
        //testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1110', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        
        //testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1111', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
        
        insert oppBUItemList;       
    //}catch(Exception e){System.debug('Exception from Test class-->'+e.getMessage()+' @ Line Number'+e.getLinenumber());}  
        Test.StartTest();            
            
             database.executebatch(new Core_OpportunityLineItem_Daily(),20);
          
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

        Test.StopTest();
    }     
  
    
     testMethod static void testBUMapping(){
        String CRON_EXP = system.now().addMinutes(10).format('ss mm HH dd MM ? yyyy');
        
        Account testAcct_BU = [SELECT ID,Name FROM Account LIMIT 1];
        Opportunity testOpp_BU = [SELECT ID,Name,Core_Product_Segment__c,Core_Product_Application__c,Core_Approved_Date__c FROM Opportunity LIMIT 1];
        List<Product2> testProducts_BU = [SELECT ID,Name,Core_Product_Type__c,Core_Division_Code_Short_Name__c FROM Product2 LIMIT 1];
		List<PricebookEntry> testPBEs_BU = [SELECT ID,Name FROM PricebookEntry];
        
        // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the 
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        testOpp_BU.Core_Approved_Date__c =system.today();
        update testOpp_BU;      
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0001', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
        //testProducts_BU[0].Core_Product_Type__c='';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        //update testProducts_BU[0];      
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;      
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0010', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
       
        //testProducts_BU[0].Core_Product_Type__c='';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        ///System.assertEquals(testOpp_BU.Core_Product_Application__c, 'Business Desktop','Connected Home');

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
       
        //testProducts_BU[0].Core_Product_Type__c='';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0101', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        //testProducts_BU[0].Core_Product_Type__c='';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;      
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0110', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
       
        //testProducts_BU[0].Core_Product_Type__c='';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0111', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
       
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1000', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
       
        //testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1001', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        //testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1010', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        //testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1011', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1100', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
       
        //testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1101', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
      
        
        
        //testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1110', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        
        //testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1111', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
        
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1111', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
        
        insert oppBUItemList;       
    //}catch(Exception e){System.debug('Exception from Test class-->'+e.getMessage()+' @ Line Number'+e.getLinenumber());}  
        Test.StartTest();            
           //System.schedule('Core_Invoke_BatchToUpdateShortName', CRON_EXP, new Core_Invoke_BatchToUpdateShortName());   
             database.executebatch(new Core_OpportunityLineItem_Daily(),20);    
           
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

        Test.StopTest();
    }     
  
    testMethod static void testBUMapping11(){
        String CRON_EXP = system.now().addMinutes(10).format('ss mm HH dd MM ? yyyy');
        
        Account testAcct_BU = [SELECT ID,Name FROM Account LIMIT 1];
        Opportunity testOpp_BU = [SELECT ID,Name,Core_Product_Segment__c,Core_Product_Application__c,Core_Approved_Date__c FROM Opportunity LIMIT 1];
        List<Product2> testProducts_BU = [SELECT ID,Name,Core_Product_Type__c,Core_Division_Code_Short_Name__c FROM Product2 LIMIT 1];
		List<PricebookEntry> testPBEs_BU = [SELECT ID,Name FROM PricebookEntry];
        
        // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the 
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c=''; //Business Desktop
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
       
        //testProducts_BU[0].Core_Product_Type__c='';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c=''; //Business Desktop
        //System.assertEquals(testOpp_BU.Core_Product_Application__c, 'Business Desktop','Connected Home');

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
       
        //testProducts_BU[0].Core_Product_Type__c='';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0101', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        //testProducts_BU[0].Core_Product_Type__c='';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;      
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0110', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
       
        //testProducts_BU[0].Core_Product_Type__c='';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0111', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
       
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1000', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
       
        //testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1001', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        //testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1010', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        //testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1011', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1100', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
       
        //testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1101', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
      
        
        
        //testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';
        update testOpp_BU;
         oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1110', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        
        //testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        //testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD P&L';
        //update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1111', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        testProducts_BU[0].Core_Product_Type__c='Emerging Technologies';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
        
        oppBUItemList.add(new OpportunityLineItem(OpportunityId=testOpp_BU.Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='1111', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Approved_Date__c =system.today()));
        
        testProducts_BU[0].Core_Product_Type__c='';
        testProducts_BU[0].Core_Division_Code_Short_Name__c='CCD';
        update testProducts_BU[0];
        
        testOpp_BU.Core_Product_Segment__c='Client Computing';
        testOpp_BU.Core_Product_Application__c='';//Business Desktop
        update testOpp_BU;
        
        insert oppBUItemList;       
    //}catch(Exception e){System.debug('Exception from Test class-->'+e.getMessage()+' @ Line Number'+e.getLinenumber());}  
        Test.StartTest();            
           //System.schedule('Core_Invoke_BatchToUpdateShortName', CRON_EXP, new Core_Invoke_BatchToUpdateShortName()); 
             database.executebatch(new Core_OpportunityLineItem_Daily(),20);
        
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

        Test.StopTest();
    }     
   
}