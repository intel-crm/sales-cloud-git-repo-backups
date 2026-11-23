/****************************************************************************************************
Apex Class Name : Core_FC_ProductSchedule_ExtCont_Test
Version         : 1.0 
Created Date    : 10/22/17
Function        : Test class for Forecasting 6Quarter Product Schedule Controller class
Modifications:
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Ashwin Dash                10/22/17                Original Version
*****************************************************************************************************/
@isTest
public class Core_FC_ProductSchedule_ExtCont_Test{
    
    public static List<Core_Trigger_Executions__c> triggExecList = new List<Core_Trigger_Executions__c>();
    public static List<Opportunity> opptyList = new List<Opportunity>();
    public static List<OpportunityLineItem> oliTestList = new List<OpportunityLineItem>();
    public static List<Core_Opp_FC_Prod_Schedule__c> insertForeCastList = new List<Core_Opp_FC_Prod_Schedule__c>();
    public static List<Product2> testProducts = new List<Product2>();
    public static List<PricebookEntry> testPBEs = new List<PricebookEntry>();
    
    static void getTriggerExecutionPopulated(){
        triggExecList.add(new Core_Trigger_Executions__c(Name='opportunityLineItemAfterHandler', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='insertForecast', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='updateForecast', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='trackOpportunityProductHistory', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='deleteForecast', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='UpdateTerritoryInfoOnOppty', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='determineApprovers', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='updateProductLineItems', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='opportunityStageUpdate', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='forecastUpdateFromOppty', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='beforeFCUpdate', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='afterFCUpdate', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        insert triggExecList;
    }
    static void setupData(){
        
        getTriggerExecutionPopulated();
        
        Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;
        Account acct = new Account(Name = 'Test Account territory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                       BillingPostalCode = '12345', Core_CIM_ID__c = '8675309');
        insert acct;
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;        
        Profile p = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :p.Id AND isActive = true LIMIT 1];
        System.runAs(Core_Test_Utility.systemAdminUser){
            opptyList.add(new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = usr.Id, Core_Sales_Group__c='Global Accounts', Core_Commissionable__c ='No', Core_Opportunity_Type__c='Design: Original', Core_Product_Segment__c='Client Computing', Core_Product_Application__c = 'Mobile', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='Broadwell', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8)));
            opptyList.add(new Opportunity(Name = 'Test Opportunity2', RecordTypeId = newOppRecTypeId,
                AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = usr.Id, Core_Sales_Group__c='Regional Sales', Core_Commissionable__c ='No', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Client Computing', Core_Product_Application__c = 'Mobile', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='Broadwell', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8)));
            opptyList.add(new Opportunity(Name = 'Test Opportunity3', RecordTypeId = newOppRecTypeId,
                AccountId = acct.Id, StageName = 'Define', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = usr.Id, Core_Sales_Group__c='Regional Sales', Core_Commissionable__c ='No', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Client Computing', Core_Product_Application__c = 'Mobile', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='Broadwell', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8)));
            insert opptyList;
        }
        
        testProducts = Core_Test_Utility.createProduct(3);
        insert testProducts;
        
        testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        System.runAs(Core_Test_Utility.systemAdminUser){
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[0].Id, PricebookEntryId=testPBEs[0].Id, Description = 'Test 11', UnitPrice=11, Quantity=2000,
              Core_BU_Short_Name__c='T11', Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[1].Id, PricebookEntryId=testPBEs[1].Id, Description='Test 11', UnitPrice=11, Quantity=2345, 
                Core_BU_Short_Name__c='T12', Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[1].Id, PricebookEntryId=testPBEs[1].Id, Description='Test 11', UnitPrice=11, Quantity=123, 
                Core_BU_Short_Name__c='T13', Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending')); 
            //oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[2].Id, PricebookEntryId=testPBEs[2].Id, Description='Test 11', UnitPrice=11, Quantity=1234, 
            //    Core_BU_Short_Name__c='T13', Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending'));                 
            insert oliTestList;
        }        
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = null, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 1000, Core_Opp_FC_isdeleted__c = true));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 123, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 1000, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 1234, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 1000, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 1000, Core_Opp_FC_isdeleted__c = false));
        insert insertForeCastList;
    }
    
    static testmethod void pageOnloadTest1(){       
        Test.startTest();
        setupData();
        PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
        Test.setCurrentPage(FC_6QPS_Page);
        ApexPages.StandardController sc = new ApexPages.StandardController(opptyList[1]);
        apexpages.currentpage().getparameters().put('id' , opptyList[1].Id);
        Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
        qps_cont.deleteAllBlankQuantity();
        Test.stopTest();
    }
    
    static testmethod void deleteAllBlankQuantityTest1(){       
        Test.startTest();
        setupData();
        PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
        Test.setCurrentPage(FC_6QPS_Page);
        ApexPages.StandardController sc = new ApexPages.StandardController(opptyList[0]);
        apexpages.currentpage().getparameters().put('id' , opptyList[0].Id);
        Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
        qps_cont.deleteAllBlankQuantity();
        Test.stopTest();
    }
    
    static testmethod void editAllMethodTest1(){        
        Test.startTest();
        setupData();
        PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
        Test.setCurrentPage(FC_6QPS_Page);
        ApexPages.StandardController sc = new ApexPages.StandardController(opptyList[1]);
        apexpages.currentpage().getparameters().put('id' , opptyList[1].Id);
        Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
        
        for(Core_FC_ProductSchedule_ExtController.displayWrapper dw : qps_cont.forecastTable){
            for(Integer i=0; i<dw.fcObjList.size(); i++){
                dw.viewQuantityList[i] = '34567';
            }
        }
        qps_cont.editAllMethod();
        //qps_cont.flag = true;
        qps_cont.addQuarterMethod();
        List<Core_Opp_FC_Prod_Schedule__c> fcList1 = new List<Core_Opp_FC_Prod_Schedule__c>();
        for(Core_Opp_FC_Prod_Schedule__c fc : [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, Core_Opp_Line_Item_RecordID__c FROM 
                                            Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_Opportunity__c = :opptyList[1].id AND Core_Opp_FC_isdeleted__c = false]){
            if(fc.Core_Opp_FC_Quantity__c == null || String.valueOf(fc.Core_Opp_FC_Quantity__c) == ''){
                fc.Core_Opp_FC_Quantity__c = 10;
                fcList1.add(fc);
            }
        }
        update fcList1;
        qps_cont.saveAllMethod();
        qps_cont.cancelMethod();
        Test.stopTest();
    }
    
    static testmethod void editAllMethodTest2(){        
        Test.startTest();
        setupData();
        PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
        Test.setCurrentPage(FC_6QPS_Page);
        ApexPages.StandardController sc = new ApexPages.StandardController(opptyList[1]);
        apexpages.currentpage().getparameters().put('id' , opptyList[1].Id);
        Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
        
        for(Core_FC_ProductSchedule_ExtController.displayWrapper dw : qps_cont.forecastTable){
            for(Integer i=0; i<dw.fcObjList.size(); i++){
                dw.viewQuantityList[i] = String.valueOf(34567);
            }
        }
        qps_cont.saveAllMethod();
        qps_cont.migrate6QPSMethod();
        Test.stopTest();
    }
    
    static testmethod void migrateTest1(){      
        Test.startTest();
        setupData();
        for(Core_Trigger_Executions__c trE : triggExecList){
            if(trE.Name == 'insertForecast')
                trE.Core_Active__c = false;
        }
        update triggExecList;
        OpportunityLineItem opptyLine = new OpportunityLineItem(OpportunityId = opptyList[2].Id, PricebookEntryId=testPBEs[2].Id, Description = 'Test 11', UnitPrice=11, Quantity=2000, Core_BU_Short_Name__c='T11', Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert opptyLine;
        PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
        Test.setCurrentPage(FC_6QPS_Page);
        ApexPages.StandardController sc = new ApexPages.StandardController(opptyList[2]);
        apexpages.currentpage().getparameters().put('id' , opptyList[2].Id);
        Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc);     
        Test.stopTest();
    }
    
    static testmethod void qpsHandlerTest1(){       
        Test.startTest();
        setupData();
        for(Core_Trigger_Executions__c trE : triggExecList){
            if(trE.Name == 'insertForecast')
                trE.Core_Active__c = true;
        }
        update triggExecList;
        Core_Opp_FC_Prod_Schedule__c fc = [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Product__c, Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_Line_Item_RecordID__c = :oliTestList[1].Id LIMIT 1];
        fc.Core_Opp_FC_Quantity__c = 9000;
        update fc;
        Test.stopTest();
    }
    
    static testmethod void prodStateOnHoldTest1(){       
        Test.startTest();
        setupData();
        OpportunityLineItem opptyLine = new OpportunityLineItem(OpportunityId = opptyList[0].Id, PricebookEntryId=testPBEs[2].Id, Description = 'Test 11', UnitPrice=11, Quantity=2000, Core_BU_Short_Name__c='T11', Core_Loss_Cancel_Reason__c=null, Core_Status__c='On Hold');
        insert opptyLine;
        Core_Opp_FC_Prod_Schedule__c fc = [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Product__c, Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_Line_Item_RecordID__c = :opptyLine.Id LIMIT 1];
        fc.Core_Opp_FC_Quantity__c = null;
        try{
            update fc;
        }catch(Exception e){
        }
        Test.stopTest();
    }
    
    //Adding comment to migrate
}