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
    public static List<Core_Opp_FC_Prod_Schedule__c> foreCastList = new List<Core_Opp_FC_Prod_Schedule__c>();
    public static List<User> sysAdminList = new List<User>();
    
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
        sysAdminList =  [SELECT Id, Name FROM User WHERE isActive = TRUE AND Core_Employee_Type_Code__c = 'EMP' AND Profile.Name = 'Sales Rep-BB' AND ManagerId != '' AND Manager.DelegatedApproverId != '' LIMIT 1];
        Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;
        Account acct;
        System.runAs(sysAdminList[0]){
            acct = new Account(Name = 'Test Account territory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId, 
                                           BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA', Core_Sales_Groups__c='CCG Sales Group',
                                           BillingPostalCode = '12345', Core_CIM_ID__c = '8675309');
            insert acct;
        }
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;        
        Profile p = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :p.Id AND isActive = true LIMIT 1];
        
        System.runAs(sysAdminList[0]){
            opptyList.add(new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = sysAdminList[0].Id, Core_Sales_Group__c='Global Accounts', Core_Commissionable__c ='No', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c = 'Storage', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='Apollo Lake D', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8), Core_Solution_Area__c='DCG Compute Deal $'));
            opptyList.add(new Opportunity(Name = 'Test Opportunity2', RecordTypeId = newOppRecTypeId,
                AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = sysAdminList[0].Id, Core_Sales_Group__c='Regional Sales', Core_Commissionable__c ='No', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c = 'Storage', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='Apollo Lake D', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8), Core_Solution_Area__c='DCG Compute Deal $'));
            opptyList.add(new Opportunity(Name = 'Test Opportunity3', RecordTypeId = newOppRecTypeId,
                AccountId = acct.Id, StageName = 'Define', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = sysAdminList[0].Id, Core_Sales_Group__c='Regional Sales', Core_Commissionable__c ='No', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c = 'Storage', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='Apollo Lake D', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8), Core_Solution_Area__c='DCG Compute Deal $'));
            insert opptyList;
        }
        
        testProducts = Core_Test_Utility.createProduct(3);
        insert testProducts;
        
        testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        System.runAs(Core_Test_Utility.systemAdminUser){
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[0].Id, PricebookEntryId= testPBEs[0].Id, Description = 'Test 11', UnitPrice=11, Quantity=2000, Core_BU_Short_Name__c='T11', Core_Loss_Cancel_Reason__c = null, Core_Status__c='Pending'));
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[1].Id, PricebookEntryId= testPBEs[1].Id, Description = 'Test 11', UnitPrice=11, Quantity=2345, Core_BU_Short_Name__c='T12', Core_Loss_Cancel_Reason__c = null, Core_Status__c='Pending'));
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[1].Id, PricebookEntryId= testPBEs[1].Id, Description = 'Test 11', UnitPrice=11, Quantity=123, Core_BU_Short_Name__c='T13', Core_Loss_Cancel_Reason__c = null, Core_Status__c ='Pending')); 
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[2].Id, PricebookEntryId= testPBEs[2].Id, Description = 'Test 11', UnitPrice=11, Quantity=1230, Core_BU_Short_Name__c='T14', Core_Loss_Cancel_Reason__c = null, Core_Status__c = 'Pending'));                 
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[2].Id, PricebookEntryId= testPBEs[1].Id, Description = 'Test 11', UnitPrice=20, Quantity=11000, Core_BU_Short_Name__c='T15', Core_Loss_Cancel_Reason__c = null, Core_Status__c = 'Pending')); 
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[2].Id, PricebookEntryId= testPBEs[2].Id, Description = 'Test 11', UnitPrice=20, Quantity=11000, Core_BU_Short_Name__c='T16', Core_Loss_Cancel_Reason__c = null, Core_Status__c = 'Pending'));  
            insert oliTestList;
        }        
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = null, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 1000, Core_Opp_FC_isdeleted__c = true));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 123, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 134, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 13555, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 12344, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 1234, Core_Opp_FC_isdeleted__c = false));
        insert insertForeCastList;
        Set<Id> oliSet = new Set<Id>();
        for(OpportunityLineItem oli : oliTestList){
            oliSet.add(oli.Id);
        }
        foreCastList = [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Product__c, Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, Core_Opp_FC_Approval_Status__c, Core_Opp_FC_Prod_Sales_Price__c, Core_Opp_FC_Sched_Revenue__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_Line_Item_RecordID__c IN : oliSet];
    }
    
    static testMethod void recallLastApprovedFCTest(){
        setupData();
        Test.startTest();
        //System.runAs(sysAdminList[0]){
        PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
        Test.setCurrentPage(FC_6QPS_Page);
        ApexPages.StandardController sc = new ApexPages.StandardController(opptyList[2]);
        apexpages.currentpage().getparameters().put('id' , opptyList[2].Id);
        apexpages.currentpage().getparameters().put('isNew' , 'true');
        Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc); 
        qps_cont.submitForApproval();
        //apexpages.currentpage().getparameters().put('isNew' , 'true');
        qps_cont.approvalMethod();
        qps_cont.lastApprovedProdList = [SELECT id, Core_Opp_FC_Claim_Date__c, Core_Forecast_Old_Claim_Date__c, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Product__c, Core_Opp_FC_Product__r.Name, Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quarter__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, lastModifiedDate, createdDate, Core_FC_4Q_Shed_Quantity__c, Core_FC_Last_Modified_Date__c, Core_FC_Vendor__c, Core_Opp_FC_Approval_Status__c, Core_Opp_FC_Approved_Date__c, Core_Core_FC_Appvd_SalesPrice__c, Core_Opp_FC_Prod_Sales_Price__c, Core_Opp_FC_Sched_Revenue__c from Core_Opp_FC_Prod_Schedule__c where Core_Opp_FC_Approval_Status__c =: 'Approved' AND Core_Opp_FC_Opportunity__c =: opptyList[2].Id];
        qps_cont.recallLastApprovedFC();
        //}
        Test.stopTest();
    }
    
    static testmethod void deleteAllBlankQuantityTest1(){   
        setupData();
        Test.startTest();
        System.runAs(sysAdminList[0]){
            PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
            Test.setCurrentPage(FC_6QPS_Page);
            ApexPages.StandardController sc = new ApexPages.StandardController(opptyList[0]);
            apexpages.currentpage().getparameters().put('id' , opptyList[0].Id);
            Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
            qps_cont.deleteAllBlankQuantity();
        }
        Test.stopTest();
    }
    
    static testmethod void editAllMethodTest1(){ 
        setupData();
        Test.startTest();
        System.runAs(sysAdminList[0]){
            PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
            Test.setCurrentPage(FC_6QPS_Page);
            ApexPages.StandardController sc = new ApexPages.StandardController(opptyList[1]);
            apexpages.currentpage().getparameters().put('id' , opptyList[1].Id);
            apexpages.currentpage().getparameters().put('edit' , 'true');
            Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
            
            for(Core_FC_ProductSchedule_ExtController.displayWrapper dw : qps_cont.forecastTable){
                for(Integer i=0; i<dw.fcObjList.size(); i++){
                    dw.viewQuantityList[i] = '34567';
                }
            }
            qps_cont.editAllMethod();
            //qps_cont.flag = true;
            qps_cont.addQuarterMethod();
            qps_cont.cancelMethod();
            List<Core_Opp_FC_Prod_Schedule__c> fcList1 = new List<Core_Opp_FC_Prod_Schedule__c>();
            for(Core_Opp_FC_Prod_Schedule__c fc : [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, Core_Opp_Line_Item_RecordID__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_Opportunity__c = :opptyList[1].id AND Core_Opp_FC_isdeleted__c = false]){
                if(fc.Core_Opp_FC_Quantity__c == null || String.valueOf(fc.Core_Opp_FC_Quantity__c) == ''){
                    fc.Core_Opp_FC_Quantity__c = 10;
                    fcList1.add(fc);
                }
            }
            update fcList1;
            qps_cont.saveAllMethod();
            fcList1.clear();
            
        }
        Test.stopTest();
    }
    
    static testmethod void submitAndAddQuarterMethod1(){ 
        setupData();
        Test.startTest();
        System.runAs(sysAdminList[0]){
            PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
            Test.setCurrentPage(FC_6QPS_Page);
            ApexPages.StandardController sc = new ApexPages.StandardController(opptyList[1]);
            apexpages.currentpage().getparameters().put('id' , opptyList[1].Id);
            apexpages.currentpage().getparameters().put('isAddQuarter' , 'true');
            Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
            qps_cont.submitForApproval();
            qps_cont.approvalMethod();
            qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
            qps_cont.isAddQuarter = true;
            qps_cont.addQuarterMethod();
            qps_cont.saveAllMethod();
            qps_cont.cancelMethod();
            qps_cont.addQuarterMethod();
            qps_cont.cancelRecentFC();
        }
        Test.stopTest();
    }
    
    static testmethod void migrateAndClearMethod1(){        
        
        setupData();
        PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
        Test.setCurrentPage(FC_6QPS_Page);
        ApexPages.StandardController sc = new ApexPages.StandardController(opptyList[1]);
        apexpages.currentpage().getparameters().put('id' , opptyList[1].Id);
        Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
        Test.startTest();
        qps_cont.migrate6QPSMethod();
        qps_cont.clearQuantities();
        Test.stopTest();
    }
    
    static testmethod void submitAndRejectMethod1(){ 
        setupData();
        Test.startTest();
        System.runAs(sysAdminList[0]){
            PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
            Test.setCurrentPage(FC_6QPS_Page);
            ApexPages.StandardController sc = new ApexPages.StandardController(opptyList[1]);
            apexpages.currentpage().getparameters().put('id' , opptyList[1].Id);
            Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
            qps_cont.submitForApproval();
            qps_cont.rejectionMethod();  
        }       
        Test.stopTest();
    }
    
    static testmethod void submitAndRejectMethod2(){ 
        setupData();
        Test.startTest();
        System.runAs(sysAdminList[0]){
            PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
            Test.setCurrentPage(FC_6QPS_Page);
            ApexPages.StandardController sc = new ApexPages.StandardController(opptyList[2]);
            apexpages.currentpage().getparameters().put('id' , opptyList[2].Id);
            Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
            Map<String, List<Core_Opp_FC_Prod_Schedule__c>> qtrFCMap1 = qps_cont.getQtrSortedForecastRec(qps_cont.qtrNameList ,qps_cont.productSortedForecastMap);
            List<Core_Opp_FC_Prod_Schedule__c> updtList = new List<Core_Opp_FC_Prod_Schedule__c>();
            for(String qtr : qtrFCMap1.keySet()){
                for(Core_Opp_FC_Prod_Schedule__c fcQtr : qtrFCMap1.get(qtr)){
                    fcQtr.Core_Opp_FC_Quantity__c = 0;
                    updtList.add(fcQtr);
                }
            }
            if(!updtList.isEmpty())
                update updtList;
            
            qps_cont.submitForApproval();
            qps_cont.isAllZeroQuantity(qtrFCMap1);
        }
        Test.stopTest();
    }
    
    static testmethod void blankForecastMethod1(){ 
        setupData();
        Test.startTest();
        PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
        Test.setCurrentPage(FC_6QPS_Page);
        ApexPages.StandardController sc = new ApexPages.StandardController(opptyList[2]);
        apexpages.currentpage().getparameters().put('id' , opptyList[2].Id);
        Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
        Map<String, List<Core_Opp_FC_Prod_Schedule__c>> qtrFCMap1 = qps_cont.getQtrSortedForecastRec(qps_cont.qtrNameList ,qps_cont.productSortedForecastMap);
        List<Core_Opp_FC_Prod_Schedule__c> updtList = new List<Core_Opp_FC_Prod_Schedule__c>();
        for(String qtr : qtrFCMap1.keySet()){
            updtList.addAll(qtrFCMap1.get(qtr));
        }
        if(!updtList.isEmpty())
            delete updtList;
        qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
        Test.stopTest();
    }
    
    static testmethod void deleteOliMethod1(){ 
        setupData();
        Test.startTest();
        System.runAs(sysAdminList[0]){
            PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
            Test.setCurrentPage(FC_6QPS_Page);
            ApexPages.StandardController sc = new ApexPages.StandardController(opptyList[2]);
            apexpages.currentpage().getparameters().put('id' , opptyList[2].Id);
            Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc); 
            qps_cont.submitForApproval();
            qps_cont.approvalMethod();
            delete oliTestList[4];
            qps_cont = new Core_FC_ProductSchedule_ExtController(sc); 
        }       
        Test.stopTest();
    }
    
     static testmethod void removeQuantitiesTest(){
         setupData();
         Test.startTest();
        System.runAs(sysAdminList[0]){
            PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
            Test.setCurrentPage(FC_6QPS_Page);
            ApexPages.StandardController sc = new ApexPages.StandardController(opptyList[2]);
            apexpages.currentpage().getparameters().put('id' , opptyList[2].Id);
            Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc); 
            qps_cont.removeQuantities();
            //delete oliTestList[4];
            //qps_cont = new Core_FC_ProductSchedule_ExtController(sc); 
        }       
        Test.stopTest();
         
     }
    /*static testmethod void saveAllMethod1(){ 
        setupData();
        Test.startTest();
        System.runAs(sysAdminList[0]){
            PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
            Test.setCurrentPage(FC_6QPS_Page);
            ApexPages.StandardController sc = new ApexPages.StandardController(opptyList[2]);
            apexpages.currentpage().getparameters().put('id' , opptyList[2].Id);
            Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc); 
            List<Core_Opp_FC_Prod_Schedule__c> fcList1 = new List<Core_Opp_FC_Prod_Schedule__c>();
            for(Core_Opp_FC_Prod_Schedule__c fc : [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, Core_Opp_Line_Item_RecordID__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_Opportunity__c = :opptyList[1].id AND Core_Opp_FC_isdeleted__c = false]){
                if(fc.Core_Opp_FC_Quantity__c == null || String.valueOf(fc.Core_Opp_FC_Quantity__c) == ''){
                    fc.Core_Opp_FC_Quantity__c = 10;
                    fcList1.add(fc);
                }
            }
            qps_cont.saveAllMethod();
        }       
        Test.stopTest();
    }*/
    //Adding comment to migrate
    
    static testmethod void handlerBeforeUpdate(){ 
        setupData();
        Test.startTest();
        System.runAs(sysAdminList[0]){
            PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
            Test.setCurrentPage(FC_6QPS_Page);
            ApexPages.StandardController sc = new ApexPages.StandardController(opptyList[2]);
            apexpages.currentpage().getparameters().put('id', opptyList[2].Id);
            Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc); 
            List<OpportunityLineItem> oliOppty2List = [SELECT id, Core_Status__c FROM OpportunityLineItem WHERE OpportunityId = :opptyList[2].id LIMIT 1];
            oliOppty2List[0].Core_Status__c = 'Lost';
            update oliOppty2List;
        }       
        Test.stopTest();
    }
    
}