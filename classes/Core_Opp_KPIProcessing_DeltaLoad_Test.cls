/********************************************************************************************************************************************************************
Apex Class Name:  Core_Opp_KPIProcessing_DeltaLoad_Test
Version     : 1.0 
Created Date: 01/15/2019
Function    : Test class for Core_Opp_KPIProcessing_DeltaLoad_Batch

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar           01/15/2019              Original Version developed
*******************************************************************************************************************************************************************/

@isTest
public class Core_Opp_KPIProcessing_DeltaLoad_Test {
    
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
            // intOutMsg1.Core_IAH_KPI_Record_ID__c = oppKpiList[1].Id;
            intOutMsg1.Core_IAH_KPI_Threshold_Met__c = 'No';
            intOutMsg1.Core_IAH_KPI_Total_Price__c = 12345;
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
        for(Integer i=0; i<10; i++){
            Core_Opportunity_KPI__c oppKpi = new Core_Opportunity_KPI__c();
            oppKpi.Name = 'test kpi';
            oppKpi.Core_Opp_KPI_BatchTime__c = Datetime.newInstance(date.today() - 1, time.newInstance(1, 1, 1, 1));
            oppKpi.Core_Opp_KPI_Achieved__c = false;
            oppKpi.Core_Opp_KPI_Add_Date__c = system.now();
            oppKpi.Core_Opp_KPI_BU_Owner__c = userInfo.getUserId();
            oppKpi.Core_Opp_KPI_Description__c = 'Test Description';
            oppKpi.Core_Opp_KPI_Last_Update_Date__c = system.now();
            oppKpi.Core_Opp_KPI_Volume__c = 10;
            oppKpi.Core_IAH_KPI_Record_ID__c='12345';
            oppKpi.Core_Opp_KPI_IntRecord_Id__c='12345';
            oppKpi.Core_Opp_KPI_Quantity__c = 5;
            oppKpi.Core_Opp_KPI_Total_Price__c = 100;
            if(math.mod(i, 2) == 0){
                oppKpi.Core_Opp_KPI_Opportunity__c = opp.Id;
            }else{
                oppKpi.Core_Opp_KPI_Opportunity__c = opp.Id;
            }
            oppKpi.Core_Opp_KPI_Threshold_Met__c = 'No';
            oppKpi.Core_Opp_KPI_Threshold_Req__c = 'Testing';
            Date myDate = Date.today();
            Time myTime = Time.newInstance(8, 0, 0, 0);
            DateTime dt1 = DateTime.newInstanceGMT(myDate, myTime);
            
            // oppKpi.CreatedDate=dt1;
            // oppKpi.LastModifiedDate=dt1;
            
            string oppKpiJSON=JSON.serialize(oppKpi);
            Core_Opportunity_KPI__c oppKpiLL = (Core_Opportunity_KPI__c) JSON.deserialize(oppKpiJSON, Core_Opportunity_KPI__c.class );
            oppKpiList.add(oppKpiLL);
        }
        insert oppKpiList;
        // system.debug('the test last modified date===>'+oppKpiList[0].createddate);
        
        Core_Opp_KPI_Product__c kpiProd = new Core_Opp_KPI_Product__c();
        kpiProd.Core_Opp_KPI__c = oppKpiList[0].Id;
        kpiProd.Core_Opp_KPI_Product__c = product[0].Product2.Id;
        kpiProd.Core_Opp_KPI_Oppty_Product_Id__c = product[0].Id;
        insert kpiProd;
        Core_Opp_KPI_Product__c kpiProd1 = new Core_Opp_KPI_Product__c();
        kpiProd1.Core_Opp_KPI__c = oppKpiList[0].Id;
        kpiProd1.Core_Opp_KPI_Product__c = product[1].Product2.Id;
        kpiProd1.Core_Opp_KPI_Oppty_Product_Id__c = product[1].Id;
        insert kpiProd1;
        
        List<Core_KPI_Integration_Inbound__c> intOutMsgList = new List<Core_KPI_Integration_Inbound__c>();
        try{
            Core_KPI_Integration_Inbound__c intOutMsg = new Core_KPI_Integration_Inbound__c();
            intOutMsg.Core_IAH_KPI_Achieved__c = false;
            intOutMsg.Core_IAH_KPI_Added_Date__c = system.now();
            intOutMsg.Core_IAH_KPI_Batch_Time__c = system.now();
            intOutMsg.Core_IAH_KPI_Last_Updated_Date__c = system.now();
            intOutMsg.Core_IAH_KPI_Oppty_Id__c = opp.Id;
            intOutMsg.Core_IAH_KPI_Oppty_Prod_Id__c = product[0].Id;
            intOutMsg.Core_IAH_KPI_DB_Status__c = 'Delete';
            intOutMsg.Core_IAH_KPI_Name__c = 'test kpi';
            intOutMsg.Core_IAH_KPI_Oppty_Volume__c = 2345;
            intOutMsg.Core_IAH_KPI_Quantity__c = 12;
            intOutMsg.Core_IAH_KPI_Record_ID__c = '12345';
            intOutMsg.Core_IAH_KPI_Threshold_Met__c = 'No';
            intOutMsg.Core_IAH_KPI_Total_Price__c = 98764;
            intOutMsg.Core_IAH_KPI_Type__c = 'Salesforce Pipeline $';
            intOutMsg.Core_IAH_SF_KPI_ID__c = 'SF kpi id';
            intOutMsg.Core_KPI_Processing_Status__c = 'New';
            intOutMsgList.add(intOutMsg);
            
            Core_KPI_Integration_Inbound__c intOutMsg1 = new Core_KPI_Integration_Inbound__c();
            intOutMsg1.Core_IAH_KPI_Achieved__c = false;
            intOutMsg1.Core_IAH_KPI_Added_Date__c = system.now();
            intOutMsg1.Core_IAH_KPI_Batch_Time__c = system.now();
            intOutMsg1.Core_IAH_KPI_Last_Updated_Date__c = system.now();
            intOutMsg1.Core_IAH_KPI_Oppty_Id__c = opp.Id;
            intOutMsg1.Core_IAH_KPI_Oppty_Prod_Id__c = product[1].Id;
            intOutMsg1.Core_IAH_KPI_DB_Status__c = 'Delete';
            intOutMsg1.Core_IAH_KPI_Name__c = 'test kpi';
            intOutMsg1.Core_IAH_KPI_Oppty_Volume__c = 2345;
            intOutMsg1.Core_IAH_KPI_Quantity__c = 12;
            intOutMsg1.Core_IAH_KPI_Record_ID__c = '12345';
            intOutMsg1.Core_IAH_KPI_Threshold_Met__c = 'No';
            intOutMsg1.Core_IAH_KPI_Total_Price__c = 98764;
            intOutMsg1.Core_IAH_KPI_Type__c = 'Salesforce Pipeline $';
            intOutMsg1.Core_IAH_SF_KPI_ID__c = 'SF kpi id';
            intOutMsg1.Core_KPI_Processing_Status__c = 'New';
            intOutMsgList.add(intOutMsg1);
            
            Core_KPI_Integration_Inbound__c intOutMsg2 = new Core_KPI_Integration_Inbound__c();
            intOutMsg2.Core_IAH_KPI_Achieved__c = false;
            intOutMsg2.Core_IAH_KPI_Added_Date__c = system.now();
            intOutMsg2.Core_IAH_KPI_Batch_Time__c = system.now();
            intOutMsg2.Core_IAH_KPI_Last_Updated_Date__c = system.now();
            intOutMsg2.Core_IAH_KPI_Oppty_Id__c = opp.Id;
            intOutMsg2.Core_IAH_KPI_Oppty_Prod_Id__c = product[0].Id;
            intOutMsg2.Core_IAH_KPI_DB_Status__c = 'Delete';
            intOutMsg2.Core_IAH_KPI_Name__c = 'test kpi';
            intOutMsg2.Core_IAH_KPI_Oppty_Volume__c = 2345;
            intOutMsg2.Core_IAH_KPI_Quantity__c = 12;
            intOutMsg2.Core_IAH_KPI_Record_ID__c = '12345';
            intOutMsg2.Core_IAH_KPI_Threshold_Met__c = 'No';
            intOutMsg2.Core_IAH_KPI_Total_Price__c = 98764;
            intOutMsg2.Core_IAH_KPI_Type__c = 'Salesforce Pipeline $';
            intOutMsg2.Core_IAH_SF_KPI_ID__c = 'SF kpi id';
            intOutMsg2.Core_KPI_Processing_Status__c = 'New';
            intOutMsgList.add(intOutMsg2);
        }
        catch(exception e){
            Core_KPI_Integration_Inbound__c intOutMsg3 = new Core_KPI_Integration_Inbound__c();
            intOutMsg3.Core_IAH_KPI_Achieved__c = false;
            intOutMsg3.Core_IAH_KPI_Added_Date__c = system.now();
            intOutMsg3.Core_IAH_KPI_Batch_Time__c = system.now();
            intOutMsg3.Core_IAH_KPI_Last_Updated_Date__c = system.now();
            intOutMsg3.Core_IAH_KPI_Oppty_Id__c = opp.Id;
            intOutMsg3.Core_IAH_KPI_Oppty_Prod_Id__c = product[0].Id;
            intOutMsg3.Core_IAH_KPI_DB_Status__c = 'Delete';
            intOutMsg3.Core_IAH_KPI_Name__c = 'test kpi';
            intOutMsg3.Core_IAH_KPI_Oppty_Volume__c = 2345;
            intOutMsg3.Core_IAH_KPI_Quantity__c = 12;
            intOutMsg3.Core_IAH_KPI_Record_ID__c = '12345';
            intOutMsg3.Core_IAH_KPI_Threshold_Met__c = 'No';
            intOutMsg3.Core_IAH_KPI_Total_Price__c = 98764;
            intOutMsg3.Core_IAH_KPI_Type__c = 'Salesforce Pipeline $';
            intOutMsg3.Core_IAH_SF_KPI_ID__c = 'SF kpi id';
            intOutMsg3.Core_KPI_Processing_Status__c = 'test';
            insert intOutMsg3;
            
        }
        
        insert intOutMsgList;
        
    }
    
    static void testDataWithKpi1(){
        Opportunity opp = [select Id from Opportunity LIMIT 1];
        OpportunityLineItem opptyProd1 = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=pbeList[1].Id,
                                                                 Description='Test 11', UnitPrice=11, Quantity=11,Core_BU_Short_Name__c='T11',
                                                                 Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert opptyProd1;
        List<OpportunityLineItem> product = [select id, Product2.Id from OpportunityLineItem];
        List<Core_Opportunity_KPI__c> oppKpiList = new List<Core_Opportunity_KPI__c>();
        for(Integer i=0; i<10; i++){
            Core_Opportunity_KPI__c oppKpi = new Core_Opportunity_KPI__c();
            oppKpi.Name = 'test kpi';
            oppKpi.Core_Opp_KPI_BatchTime__c = Datetime.newInstance(date.today() - 1, time.newInstance(1, 1, 1, 1));
            oppKpi.Core_Opp_KPI_Achieved__c = false;
            oppKpi.Core_Opp_KPI_Add_Date__c = system.now();
            oppKpi.Core_Opp_KPI_BU_Owner__c = userInfo.getUserId();
            oppKpi.Core_Opp_KPI_Description__c = 'Test Description';
            oppKpi.Core_Opp_KPI_Last_Update_Date__c = system.now();
            oppKpi.Core_Opp_KPI_Volume__c = 10;
            oppKpi.Core_IAH_KPI_Record_ID__c='12345';
            oppKpi.Core_Opp_KPI_IntRecord_Id__c='12345';
            oppKpi.Core_Opp_KPI_Quantity__c = 5;
            oppKpi.Core_Opp_KPI_Total_Price__c = 100;
            if(math.mod(i, 2) == 0){
                oppKpi.Core_Opp_KPI_Opportunity__c = opp.Id;
            }else{
                oppKpi.Core_Opp_KPI_Opportunity__c = opp.Id;
            }
            oppKpi.Core_Opp_KPI_Threshold_Met__c = 'No';
            oppKpi.Core_Opp_KPI_Threshold_Req__c = 'Testing';
            oppKpiList.add(oppKpi);
        }
        
        try{
            insert oppKpiList;
        }
        catch(Exception e) {
            
        }
        Core_Opp_KPI_Product__c kpiProd = new Core_Opp_KPI_Product__c();
        kpiProd.Core_Opp_KPI__c = oppKpiList[0].Id;
        kpiProd.Core_Opp_KPI_Product__c = product[0].Product2.Id;
        kpiProd.Core_Opp_KPI_Oppty_Product_Id__c = product[0].Id;
        insert kpiProd;
        Core_Opp_KPI_Product__c kpiProd1 = new Core_Opp_KPI_Product__c();
        kpiProd1.Core_Opp_KPI__c = oppKpiList[0].Id;
        kpiProd1.Core_Opp_KPI_Product__c = product[1].Product2.Id;
        kpiProd1.Core_Opp_KPI_Oppty_Product_Id__c = product[1].Id;
        insert kpiProd1;
        
        
        List<Core_KPI_Integration_Inbound__c> intOutMsgList = new List<Core_KPI_Integration_Inbound__c>();
        
        Core_KPI_Integration_Inbound__c intOutMsg = new Core_KPI_Integration_Inbound__c();
        intOutMsg.Core_IAH_KPI_Achieved__c = false;
        intOutMsg.Core_IAH_KPI_Added_Date__c = system.now();
        intOutMsg.Core_IAH_KPI_Batch_Time__c = system.now();
        intOutMsg.Core_IAH_KPI_Last_Updated_Date__c = system.now();
        intOutMsg.Core_IAH_KPI_Oppty_Id__c = opp.Id;
        intOutMsg.Core_IAH_KPI_Oppty_Prod_Id__c = product[0].Id;
        intOutMsg.Core_IAH_KPI_DB_Status__c = 'Update';
        intOutMsg.Core_IAH_KPI_Name__c = 'test kpi';
        intOutMsg.Core_IAH_KPI_Oppty_Volume__c = 2345;
        intOutMsg.Core_IAH_KPI_Quantity__c = 12;
        intOutMsg.Core_IAH_KPI_Record_ID__c = '12345';
        intOutMsg.Core_IAH_KPI_Threshold_Met__c = 'No';
        intOutMsg.Core_IAH_KPI_Total_Price__c = 98764;
        intOutMsg.Core_IAH_KPI_Type__c = 'Salesforce Pipeline $';
        intOutMsg.Core_IAH_SF_KPI_ID__c = 'SF kpi id';
        intOutMsg.Core_KPI_Processing_Status__c = 'New';
        intOutMsgList.add(intOutMsg);
        
        Core_KPI_Integration_Inbound__c intOutMsg1 = new Core_KPI_Integration_Inbound__c();
        intOutMsg1.Core_IAH_KPI_Achieved__c = false;
        intOutMsg1.Core_IAH_KPI_Added_Date__c = system.now();
        intOutMsg1.Core_IAH_KPI_Batch_Time__c = system.now();
        intOutMsg1.Core_IAH_KPI_Last_Updated_Date__c = system.now();
        intOutMsg1.Core_IAH_KPI_Oppty_Id__c = opp.Id;
        intOutMsg1.Core_IAH_KPI_Oppty_Prod_Id__c = product[1].Id;
        intOutMsg1.Core_IAH_KPI_DB_Status__c = 'Update';
        intOutMsg1.Core_IAH_KPI_Name__c = 'test kpi1';
        intOutMsg1.Core_IAH_KPI_Oppty_Volume__c = 2345;
        intOutMsg1.Core_IAH_KPI_Quantity__c = 12;
        intOutMsg1.Core_IAH_KPI_Record_ID__c = '12345';
        intOutMsg1.Core_IAH_KPI_Threshold_Met__c = 'No';
        intOutMsg1.Core_IAH_KPI_Total_Price__c = 98764;
        intOutMsg1.Core_IAH_KPI_Type__c = 'Salesforce Pipeline $';
        intOutMsg1.Core_IAH_SF_KPI_ID__c = 'SF kpi id';
        intOutMsg1.Core_KPI_Processing_Status__c = 'New';
        intOutMsgList.add(intOutMsg1);
        
        Core_KPI_Integration_Inbound__c intOutMsg2 = new Core_KPI_Integration_Inbound__c();
        intOutMsg2.Core_IAH_KPI_Achieved__c = false;
        intOutMsg2.Core_IAH_KPI_Added_Date__c = system.now();
        intOutMsg2.Core_IAH_KPI_Batch_Time__c = system.now();
        intOutMsg2.Core_IAH_KPI_Last_Updated_Date__c = system.now();
        intOutMsg2.Core_IAH_KPI_Oppty_Id__c = opp.Id;
        intOutMsg2.Core_IAH_KPI_Oppty_Prod_Id__c = product[0].Id;
        intOutMsg2.Core_IAH_KPI_DB_Status__c = 'Update';
        intOutMsg2.Core_IAH_KPI_Name__c = 'test kpi1';
        intOutMsg2.Core_IAH_KPI_Oppty_Volume__c = 2345;
        intOutMsg2.Core_IAH_KPI_Quantity__c = 12;
        intOutMsg2.Core_IAH_KPI_Record_ID__c = '12345';
        intOutMsg2.Core_IAH_KPI_Threshold_Met__c = 'No';
        intOutMsg2.Core_IAH_KPI_Total_Price__c = 98764;
        intOutMsg2.Core_IAH_KPI_Type__c = 'Salesforce Pipeline $';
        intOutMsg2.Core_IAH_SF_KPI_ID__c = 'SF kpi id';
        intOutMsg2.Core_KPI_Processing_Status__c = 'New';
        intOutMsgList.add(intOutMsg2);
        
        Core_KPI_Integration_Inbound__c intOutMsg3 = new Core_KPI_Integration_Inbound__c();
        intOutMsg3.Core_IAH_KPI_Achieved__c = false;
        intOutMsg3.Core_IAH_KPI_Added_Date__c = system.now();
        intOutMsg3.Core_IAH_KPI_Batch_Time__c = system.now();
        intOutMsg3.Core_IAH_KPI_Last_Updated_Date__c = system.now();
        intOutMsg3.Core_IAH_KPI_Oppty_Id__c = opp.Id;
        intOutMsg3.Core_IAH_KPI_Oppty_Prod_Id__c = product[0].Id;
        intOutMsg3.Core_IAH_KPI_DB_Status__c = 'Update';
        intOutMsg3.Core_IAH_KPI_Name__c = 'test kpi1';
        intOutMsg3.Core_IAH_KPI_Oppty_Volume__c = 2345;
        intOutMsg3.Core_IAH_KPI_Quantity__c = 12;
        intOutMsg3.Core_IAH_KPI_Record_ID__c = '12345';
        intOutMsg3.Core_IAH_KPI_Threshold_Met__c = 'No';
        intOutMsg3.Core_IAH_KPI_Total_Price__c = 98764;
        intOutMsg3.Core_IAH_KPI_Type__c = 'Salesforce Pipeline $';
        intOutMsg3.Core_IAH_SF_KPI_ID__c = 'SF kpi id';
        intOutMsg3.Core_KPI_Processing_Status__c = 'New';
        intOutMsgList.add(intOutMsg3);
        
        insert intOutMsgList;
   
    }
    
    static void testDataWithBalnakKpiName(){
        Opportunity opp = [select Id from Opportunity LIMIT 1];
        OpportunityLineItem opptyProd1 = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=pbeList[1].Id,
                                                                 Description='Test 11', UnitPrice=11, Quantity=11,Core_BU_Short_Name__c='T11',
                                                                 Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert opptyProd1;
        List<OpportunityLineItem> product = [select id, Product2.Id from OpportunityLineItem];
        List<Core_Opportunity_KPI__c> oppKpiList = new List<Core_Opportunity_KPI__c>();
        for(Integer i=0; i<10; i++){
            Core_Opportunity_KPI__c oppKpi = new Core_Opportunity_KPI__c();
            oppKpi.Name = 'test kpi';
            oppKpi.Core_Opp_KPI_BatchTime__c = Datetime.newInstance(date.today() - 1, time.newInstance(1, 1, 1, 1));
            oppKpi.Core_Opp_KPI_Achieved__c = false;
            oppKpi.Core_Opp_KPI_Add_Date__c = system.now();
            oppKpi.Core_Opp_KPI_BU_Owner__c = userInfo.getUserId();
            oppKpi.Core_Opp_KPI_Description__c = 'Test Description';
            oppKpi.Core_Opp_KPI_Last_Update_Date__c = system.now();
            oppKpi.Core_Opp_KPI_Volume__c = 10;
            oppKpi.Core_IAH_KPI_Record_ID__c='12345';
            oppKpi.Core_Opp_KPI_IntRecord_Id__c='12345';
            oppKpi.Core_Opp_KPI_Quantity__c = 5;
            oppKpi.Core_Opp_KPI_Total_Price__c = 100;
            if(math.mod(i, 2) == 0){
                oppKpi.Core_Opp_KPI_Opportunity__c = opp.Id;
            }else{
                oppKpi.Core_Opp_KPI_Opportunity__c = opp.Id;
            }
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
        kpiProd1.Core_Opp_KPI__c = oppKpiList[0].Id;
        kpiProd1.Core_Opp_KPI_Product__c = product[1].Product2.Id;
        kpiProd1.Core_Opp_KPI_Oppty_Product_Id__c = product[1].Id;
        insert kpiProd1;
        
        List<Core_KPI_Integration_Inbound__c> intOutMsgList = new List<Core_KPI_Integration_Inbound__c>();
        
        Core_KPI_Integration_Inbound__c intOutMsg = new Core_KPI_Integration_Inbound__c();
        intOutMsg.Core_IAH_KPI_Achieved__c = false;
        intOutMsg.Core_IAH_KPI_Added_Date__c = system.now();
        intOutMsg.Core_IAH_KPI_Batch_Time__c = system.now();
        intOutMsg.Core_IAH_KPI_Last_Updated_Date__c = system.now();
        intOutMsg.Core_IAH_KPI_Oppty_Id__c = opp.Id;
        intOutMsg.Core_IAH_KPI_Oppty_Prod_Id__c = product[0].Id;
        intOutMsg.Core_IAH_KPI_DB_Status__c = 'Update';
        intOutMsg.Core_IAH_KPI_Name__c = 'Abcd';
        intOutMsg.Core_IAH_KPI_Oppty_Volume__c = 2345;
        intOutMsg.Core_IAH_KPI_Quantity__c = 12;
        intOutMsg.Core_IAH_KPI_Record_ID__c = '12345';
        intOutMsg.Core_IAH_KPI_Threshold_Met__c = 'No';
        intOutMsg.Core_IAH_KPI_Total_Price__c = 98764;
        intOutMsg.Core_IAH_KPI_Type__c = 'Salesforce Pipeline $';
        intOutMsg.Core_IAH_SF_KPI_ID__c = 'SF kpi id';
        intOutMsg.Core_KPI_Processing_Status__c = 'New';
        intOutMsgList.add(intOutMsg);
        
        Core_KPI_Integration_Inbound__c intOutMsg1 = new Core_KPI_Integration_Inbound__c();
        intOutMsg1.Core_IAH_KPI_Achieved__c = false;
        intOutMsg1.Core_IAH_KPI_Added_Date__c = system.now();
        intOutMsg1.Core_IAH_KPI_Batch_Time__c = system.now();
        intOutMsg1.Core_IAH_KPI_Last_Updated_Date__c = system.now();
        intOutMsg1.Core_IAH_KPI_Oppty_Id__c = opp.Id;
        intOutMsg1.Core_IAH_KPI_Oppty_Prod_Id__c = product[1].Id;
        intOutMsg1.Core_IAH_KPI_DB_Status__c = 'Update';
        intOutMsg1.Core_IAH_KPI_Name__c = 'Abcd';
        intOutMsg1.Core_IAH_KPI_Oppty_Volume__c = 2345;
        intOutMsg1.Core_IAH_KPI_Quantity__c = 12;
        intOutMsg1.Core_IAH_KPI_Record_ID__c = '12345';
        intOutMsg1.Core_IAH_KPI_Threshold_Met__c = 'No';
        intOutMsg1.Core_IAH_KPI_Total_Price__c = 98764;
        intOutMsg1.Core_IAH_KPI_Type__c = 'Salesforce Pipeline $';
        intOutMsg1.Core_IAH_SF_KPI_ID__c = 'SF kpi id';
        intOutMsg1.Core_KPI_Processing_Status__c = 'New';
        intOutMsgList.add(intOutMsg1);
        
        Core_KPI_Integration_Inbound__c intOutMsg2 = new Core_KPI_Integration_Inbound__c();
        intOutMsg2.Core_IAH_KPI_Achieved__c = false;
        intOutMsg2.Core_IAH_KPI_Added_Date__c = system.now();
        intOutMsg2.Core_IAH_KPI_Batch_Time__c = system.now();
        intOutMsg2.Core_IAH_KPI_Last_Updated_Date__c = system.now();
        intOutMsg2.Core_IAH_KPI_Oppty_Id__c = opp.Id;
        intOutMsg2.Core_IAH_KPI_Oppty_Prod_Id__c = product[0].Id;
        intOutMsg2.Core_IAH_KPI_DB_Status__c = 'Update';
        intOutMsg2.Core_IAH_KPI_Name__c = 'Abcd';
        intOutMsg2.Core_IAH_KPI_Oppty_Volume__c = 2345;
        intOutMsg2.Core_IAH_KPI_Quantity__c = 12;
        intOutMsg2.Core_IAH_KPI_Record_ID__c = '12345';
        intOutMsg2.Core_IAH_KPI_Threshold_Met__c = 'No';
        intOutMsg2.Core_IAH_KPI_Total_Price__c = 98764;
        intOutMsg2.Core_IAH_KPI_Type__c = 'Salesforce Pipeline $';
        intOutMsg2.Core_IAH_SF_KPI_ID__c = 'SF kpi id';
        intOutMsg2.Core_KPI_Processing_Status__c = 'New';
        intOutMsgList.add(intOutMsg2);
        
        Core_KPI_Integration_Inbound__c intOutMsg3 = new Core_KPI_Integration_Inbound__c();
        intOutMsg3.Core_IAH_KPI_Achieved__c = false;
        intOutMsg3.Core_IAH_KPI_Added_Date__c = system.now();
        intOutMsg3.Core_IAH_KPI_Batch_Time__c = system.now();
        intOutMsg3.Core_IAH_KPI_Last_Updated_Date__c = system.now();
        intOutMsg3.Core_IAH_KPI_Oppty_Id__c = opp.Id;
        intOutMsg3.Core_IAH_KPI_Oppty_Prod_Id__c = product[0].Id;
        intOutMsg3.Core_IAH_KPI_DB_Status__c = 'Update';
        intOutMsg3.Core_IAH_KPI_Name__c = 'Abcd';
        intOutMsg3.Core_IAH_KPI_Oppty_Volume__c = 2345;
        intOutMsg3.Core_IAH_KPI_Quantity__c = 12;
        intOutMsg3.Core_IAH_KPI_Record_ID__c = '12345';
        intOutMsg3.Core_IAH_KPI_Threshold_Met__c = 'No';
        intOutMsg3.Core_IAH_KPI_Total_Price__c = 98764;
        intOutMsg3.Core_IAH_KPI_Type__c = 'Salesforce Pipeline $';
        intOutMsg3.Core_IAH_SF_KPI_ID__c = 'SF kpi id';
        intOutMsg3.Core_KPI_Processing_Status__c = 'New';
        intOutMsgList.add(intOutMsg3);
        
        insert intOutMsgList;
    }
    
    static testMethod void deltaLoadTest(){
        testData();
        testDataWithoutKpi();
        Database.executeBatch(new Core_Opp_KPIProcessing_DeltaLoad_Batch()); 
        
        testDataWithKpi();
        Database.executeBatch(new Core_Opp_KPIProcessing_DeltaLoad_Batch());
        
    }
    
    static testMethod void deltaLoadTest1(){
        testData();
        testDataWithKpi1();
        Database.executeBatch(new Core_Opp_KPIProcessing_DeltaLoad_Batch());
        
    }
    static testMethod void deltaLoadTest2(){
        testData();
        testDataWithBalnakKpiName();
        Database.executeBatch(new Core_Opp_KPIProcessing_DeltaLoad_Batch());
    }
    static testMethod void deltaLoadTest3(){
        Test.startTest();
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
        
        testDataWithKpi1();
        Database.executeBatch(new Core_Opp_KPIProcessing_DeltaLoad_Batch());
        Test.stopTest();
        
    }
    
}