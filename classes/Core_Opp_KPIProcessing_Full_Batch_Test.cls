/********************************************************************************************************************************************************************
Apex Class Name:  Core_Opp_KPIProcessing_Full_Batch_Test
Version     : 1.0 
Created Date: 01/15/2019
Function    : Test class for Core_Opp_KPIProcessing_Full_Batch

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar           01/15/2019              Original Version developed
*******************************************************************************************************************************************************************/

@isTest
public class Core_Opp_KPIProcessing_Full_Batch_Test{
    
    public static List<PricebookEntry> pbeList = new List<PricebookEntry>();
    
    static void testData(){
        // Create a new account        
        Account acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', Core_CIM_ID__c = '8675309',Core_Sales_Groups__c='DCG Sales Group');
        insert acct;
        
        // Create a new product
        Product2 product = new Product2(Name = 'Test Product1');
        insert product;
        Product2 product1 = new Product2(Name = 'Test Product2');
        insert product1;
        
        // Create a new price book entry using the product created above
        PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 100, IsActive = true);
        pbeList.add(pbe);
        
        PricebookEntry pbe1 = new PricebookEntry(Product2Id = product1.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 110, IsActive = true);
        pbeList.add(pbe1);
		insert pbeList;
        
        // Create a new opportunity using the account created above
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, 
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today());
        insert opportunity;
        
        OpportunityLineItem opptyProd = new OpportunityLineItem(OpportunityId=opportunity.Id, PricebookEntryId=pbeList[0].Id,
                                                  Description='Test 11', UnitPrice=11, Quantity=11,Core_BU_Short_Name__c='T11',
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert opptyProd;
        
        Core_Opp_KPI_Criteria__c kpiCriteria = new Core_Opp_KPI_Criteria__c();
        kpiCriteria.Name = 'test kpi';
        kpiCriteria.Core_Opp_KPI_BU_Owner__c = UserInfo.getUserId();
        kpiCriteria.Core_Opp_KPI_Description__c = 'Kpi Criteria Description';
        kpiCriteria.Core_Opp_Threshold_Requirement__c = 'Test Threshold';
        insert kpiCriteria;
        Core_Opp_KPI_Criteria__c kpiCriteria1 = new Core_Opp_KPI_Criteria__c();
        kpiCriteria1.Name = 'test kpis';
        kpiCriteria1.Core_Opp_KPI_BU_Owner__c = UserInfo.getUserId();
        kpiCriteria1.Core_Opp_KPI_Description__c = 'Kpi Criteria Description';
        kpiCriteria1.Core_Opp_Threshold_Requirement__c = 'Test Threshold';
        insert kpiCriteria1;
    }
    
    static void testDataWithoutKpi(){
        Opportunity opp = [select Id from Opportunity LIMIT 1];
        List<OpportunityLineItem> product = [select id from OpportunityLineItem LIMIT 1];
        List<Core_KPI_Integration_Inbound__c> intList = new List<Core_KPI_Integration_Inbound__c>();
        for(Integer i=0; i<5; i++){
            Core_KPI_Integration_Inbound__c intOutMsg1 = new Core_KPI_Integration_Inbound__c();
            intOutMsg1.Core_IAH_KPI_Achieved__c = true;
            intOutMsg1.Core_IAH_KPI_Added_Date__c = system.now();
            intOutMsg1.Core_IAH_KPI_Batch_Time__c = system.now();
            intOutMsg1.Core_IAH_KPI_DB_Status__c = 'Insert';
            intOutMsg1.Core_IAH_KPI_Last_Updated_Date__c = system.now();
            if(math.mod(i, 2) == 0){
                intOutMsg1.Core_IAH_KPI_Name__c = 'test kpi';
            }else{
                intOutMsg1.Core_IAH_KPI_Name__c = 'test kpis';
            }
            intOutMsg1.Core_IAH_KPI_Oppty_Id__c = opp.Id;
            intOutMsg1.Core_IAH_KPI_Oppty_Prod_Id__c = product[0].Id;
            intOutMsg1.Core_IAH_KPI_Oppty_Volume__c = 2345;
            intOutMsg1.Core_IAH_KPI_Quantity__c = 12;
            //intOutMsg1.Core_IAH_KPI_Record_ID__c = oppKpiList[1].Id;
            intOutMsg1.Core_IAH_KPI_Threshold_Met__c = 'No';
            intOutMsg1.Core_IAH_KPI_Total_Price__c = 98764;
            intOutMsg1.Core_IAH_KPI_Type__c = 'Salesforce Pipeline $';
            intOutMsg1.Core_IAH_SF_KPI_ID__c = 'SF kpi id';
            intOutMsg1.Core_KPI_Processing_Status__c = 'New';
            intList.add(intOutMsg1);
        }
        intList[4].Core_IAH_KPI_Name__c = 'different name';
        intList[3].Core_IAH_KPI_Oppty_Prod_Id__c = '00k2D000003PjzmQAC';
        insert intList;
    }
    
    static void testDataWithKpi(){
        Opportunity opp = [select Id from Opportunity LIMIT 1];
		OpportunityLineItem opptyProd1 = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=pbeList[1].Id,
                                                  Description='Test 11', UnitPrice=11, Quantity=11,Core_BU_Short_Name__c='T11',
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert opptyProd1;
        List<OpportunityLineItem> product = [select id, Product2.Id from OpportunityLineItem];
        List<Core_Opportunity_KPI__c> oppKpiList = new List<Core_Opportunity_KPI__c>();
        for(Integer i=0; i<2; i++){
            Core_Opportunity_KPI__c oppKpi = new Core_Opportunity_KPI__c();
            oppKpi.Name = 'test kpi';
            oppKpi.Core_Opp_KPI_BatchTime__c = Datetime.newInstance(date.today() - 1, time.newInstance(1, 1, 1, 1));
            oppKpi.Core_Opp_KPI_Achieved__c = false;
            oppKpi.Core_Opp_KPI_Add_Date__c = system.now();
            oppKpi.Core_Opp_KPI_BU_Owner__c = userInfo.getUserId();
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
        
        List<Core_KPI_Integration_Inbound__c> intOutMsgList = new List<Core_KPI_Integration_Inbound__c>();
        for(Integer i=0; i<5; i++){
            Core_KPI_Integration_Inbound__c intOutMsg = new Core_KPI_Integration_Inbound__c();
            intOutMsg.Core_IAH_KPI_Achieved__c = true;
            intOutMsg.Core_IAH_KPI_Added_Date__c = system.now();
            intOutMsg.Core_IAH_KPI_Batch_Time__c = system.now();
            intOutMsg.Core_IAH_KPI_DB_Status__c = 'Insert';
            intOutMsg.Core_IAH_KPI_Last_Updated_Date__c = system.now();
            if(math.mod(i, 2) == 0){
                intOutMsg.Core_IAH_KPI_Name__c = 'test kpi';
            }else{
                intOutMsg.Core_IAH_KPI_Name__c = 'test kpis';
            }
            intOutMsg.Core_IAH_KPI_Oppty_Id__c = opp.Id;
            intOutMsg.Core_IAH_KPI_Oppty_Prod_Id__c = product[0].Id;
            /*if(math.mod(i, 2) == 0){
                intOutMsg.Core_IAH_KPI_Oppty_Prod_Id__c = product.Id;
            }else{
                intOutMsg.Core_IAH_KPI_Oppty_Prod_Id__c = product1.Id;
            }*/
            intOutMsg.Core_IAH_KPI_Oppty_Volume__c = 2345;
            intOutMsg.Core_IAH_KPI_Quantity__c = 12;
            intOutMsg.Core_IAH_KPI_Record_ID__c = oppKpiList[1].Id;
            intOutMsg.Core_IAH_KPI_Threshold_Met__c = 'No';
            intOutMsg.Core_IAH_KPI_Total_Price__c = 98764;
            intOutMsg.Core_IAH_KPI_Type__c = 'Salesforce Pipeline $';
            intOutMsg.Core_IAH_SF_KPI_ID__c = 'SF kpi id';
            intOutMsg.Core_KPI_Processing_Status__c = 'New';
            intOutMsgList.add(intOutMsg);
        }
        intOutMsgList[1].Core_IAH_KPI_DB_Status__c = 'Update';
        intOutMsgList[2].Core_IAH_KPI_DB_Status__c = 'Update';
        intOutMsgList[3].Core_IAH_KPI_DB_Status__c = 'No Change';
        intOutMsgList[4].Core_IAH_KPI_DB_Status__c = 'Update';
        intOutMsgList[4].Core_IAH_KPI_Name__c = 'New Name';
        //intOutMsgList[4].Core_IAH_KPI_Oppty_Id__c = '00k2D000003PjzmQAC';
        insert intOutMsgList;
    }
    
    static testMethod void fullrefreshWithoutKPITest(){
        Test.startTest();
        testData();
        testDataWithoutKpi();
        Database.executeBatch(new Core_Opp_KPIProcessing_Full_Batch());        
        Test.stopTest();
        List<Core_KPI_Integration_Inbound__c> kpiIntList = [SELECT id, Core_KPI_Processing_Status__c, Core_IAH_KPI_Error_Message__c, Core_IAH_KPI_Oppty_Prod_Id__c FROM Core_KPI_Integration_Inbound__c];
        System.debug('***KPI List****');
        for(Core_KPI_Integration_Inbound__c kpi : kpiIntList){
            System.debug('**KPI Id - '+kpi.Id);
            System.debug('**KPI Status - '+kpi.Core_KPI_Processing_Status__c);
            System.debug('**KPI Error - '+kpi.Core_IAH_KPI_Error_Message__c);
            System.debug('**KPI Prod - '+kpi.Core_IAH_KPI_Oppty_Prod_Id__c);
        }
    }
    
    static testMethod void fullrefreshWithKPITest(){
        Test.startTest();
        testData();        
        testDataWithKpi();
        Database.executeBatch(new Core_Opp_KPIProcessing_Full_Batch());
        Test.stopTest();
        List<Core_KPI_Integration_Inbound__c> kpiIntList = [SELECT id, Core_KPI_Processing_Status__c, Core_IAH_KPI_Error_Message__c, Core_IAH_KPI_Oppty_Prod_Id__c FROM Core_KPI_Integration_Inbound__c];
        System.debug('***KPI List****');
        for(Core_KPI_Integration_Inbound__c kpi : kpiIntList){
            System.debug('**KPI Id - '+kpi.Id);
            System.debug('**KPI Status - '+kpi.Core_KPI_Processing_Status__c);
            System.debug('**KPI Error - '+kpi.Core_IAH_KPI_Error_Message__c);
            System.debug('**KPI Prod - '+kpi.Core_IAH_KPI_Oppty_Prod_Id__c);
        }
    }

}