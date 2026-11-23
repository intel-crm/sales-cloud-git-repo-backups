@isTest 
public class Core_Batch_OpportunityKPIInsert_Test 
{
    static void setUpData(){
        Core_Trigger_Executions__c triggerSetting = new Core_Trigger_Executions__c();
        triggerSetting.name = 'KPIDeltaLoad';
        triggerSetting.Core_Object__c = 'Core_KPI_Staging__c';
        triggerSetting.Core_Active__c = TRUE;
        triggerSetting.Core_Description__c = 'This is test description';
        triggerSetting.Core_Class_Name__c = 'Core_KPIDeltaLoadHandler';
        triggerSetting.Core_Trigger_Events__c = 'After Insert, After Update';
        insert triggerSetting;
        
        Core_KPI_FullRefresh_Check__c triggerSetting2 = new Core_KPI_FullRefresh_Check__c();
        triggerSetting2.name = 'Core_KPI_FullRefresh_Check';
        triggerSetting2.IsFullRefresh__c = TRUE;
        
        insert triggerSetting2;
        
    }
    
    static testMethod void positivetestMethod1() 
    {
        List <Opportunity> oppList= Core_Test_Utility.createOpportunity(1);
        List<Core_KPI_Staging__c> lstOpptyStage= new List<Core_KPI_Staging__c>();
        for(Integer i=0 ;i <200;i++)
        {
            Core_KPI_Staging__c o = new Core_KPI_Staging__c();
            if(i==0){
                o.Core_Begin_Of_File__c = true;
                
            }
            else if(i==199){
                o.Core_End_Of_File__c = true;
                
            }   
                o.core_kpi_name__c = 'aa';
                o.Core_Refresh_Type__c = 'full';
                o.core_status__c = 'New';
                o.Core_Batch_ID__c = '27';
                o.Core_Opportunity_ID__c = oppList[0].id;
                //o.Core_Batch_Time__c = Datetime.newInstance(2021, 01, 30, 04, 15, 00);
                o.Core_Batch_Time__c = system.now();
                o.Core_Is_Delete__c = false;
                //o.core_opp_kpi_product__c = 'abcd';
            
                lstOpptyStage.add(o);
        } 
        
        insert lstOpptyStage;
        
        Test.startTest();

            Core_Batch_OpportunityKPIInsert obj = new Core_Batch_OpportunityKPIInsert(lstOpptyStage[0].Core_Batch_ID__c, 'full');
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
    static testMethod void negativetestMethod1() 
    {
        List <Opportunity> oppList= Core_Test_Utility.createOpportunity(1);
        List<Core_KPI_Staging__c> lstOpptyStage= new List<Core_KPI_Staging__c>();
        for(Integer i=0 ;i <200;i++)
        {
            Core_KPI_Staging__c o = new Core_KPI_Staging__c();
            if(i==0){
                o.Core_Begin_Of_File__c = true;
                
            }
            else if(i==199){
                o.Core_End_Of_File__c = true;
                
            }   
                o.core_kpi_name__c = 'aa';
                o.Core_Refresh_Type__c = 'full';
                o.core_status__c = 'New';
                o.Core_Batch_ID__c = '27';
                o.Core_Opportunity_ID__c = oppList[0].id;
                //o.Core_Batch_Time__c = Datetime.newInstance(2021, 01, 30, 04, 15, 00);
                o.Core_Batch_Time__c = system.now();
                o.Core_Is_Delete__c = false;
                o.core_opp_kpi_product__c = 'abcd';
            
                lstOpptyStage.add(o);
        } 
        
        insert lstOpptyStage;
        
        Test.startTest();

            Core_Batch_OpportunityKPIInsert obj = new Core_Batch_OpportunityKPIInsert(lstOpptyStage[0].Core_Batch_ID__c, 'full');
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
    
    static testMethod void testMethod3() 
    {    
        //setupData();
        
        Account acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c= Core_CRM_Utility.getSalesGroupAPI(), Industry = 'Agriculture' , Core_Sub_Industry__c ='Animal Production');
        insert acct;
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        
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
        Opportunity oppo = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, 
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today());
        insert oppo;
        
        OpportunityLineItem opptyProd = new OpportunityLineItem(OpportunityId=oppo.Id, PricebookEntryId=pbeList[0].Id,
                                                                Description='Test 11', UnitPrice=11, Quantity=11,
                                                                Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert opptyProd;
        
        
        //List <Opportunity> oppList= Core_Test_Utility.createOpportunity(1);
        List<Core_Oppty_KPI_New__c> oppKPIList = new List<Core_Oppty_KPI_New__c>();
        for(Integer i=0;i<2;i++){        
            Core_Oppty_KPI_New__c OppKPI1 = new Core_Oppty_KPI_New__c();
            OppKPI1.Name='aa'+i;
            OppKPI1.Core_KPI_Opportunity__c = oppo.id;
            OppKPI1.Core_Batch_Time__c = System.Now().addHours(-4);
            OppKPI1.Core_Opportunity_KPI_Batch_ID__c = '25';
            oppKPIList.add(OppKPI1);
        }
        insert oppKPIList;
        
        
        //List <Opportunity> oppList= Core_Test_Utility.createOpportunity(1);
        List<Core_KPI_Staging__c> lstOpptyStage= new List<Core_KPI_Staging__c>();
        for(Integer i=0 ;i <200;i++)
        {
            Core_KPI_Staging__c o = new Core_KPI_Staging__c();
            if(i==0){
                o.Core_Begin_Of_File__c = true;
                
            }
            else if(i==199){
                o.Core_End_Of_File__c = true;
                
            }   
                o.core_kpi_name__c = 'aa';
                o.Core_Refresh_Type__c = 'full';
                o.core_status__c = 'New';
                o.Core_Batch_ID__c = '27';
                o.Core_Opportunity_ID_Txt__c = oppo.id;
                o.Core_Batch_Time__c = system.now();
                o.Core_Is_Delete__c = false;
                o.Core_Opportunity_Product_Txt__c = opptyProd.id;
            
                lstOpptyStage.add(o);
        } 
        insert lstOpptyStage;
        Test.startTest();
            Core_Batch_OpportunityKPIInsert obj = new Core_Batch_OpportunityKPIInsert(lstOpptyStage[0].Core_Batch_ID__c, 'full');
            DataBase.executeBatch(obj);
        Test.stopTest();
    }
    
    static testMethod void testMethod4() 
    {    
        //setupData();
        
        Account acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c= Core_CRM_Utility.getSalesGroupAPI(), Industry = 'Agriculture' , Core_Sub_Industry__c ='Animal Production');
        insert acct;
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        
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
        Opportunity oppo = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, 
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today());
        insert oppo;
        
        OpportunityLineItem opptyProd = new OpportunityLineItem(OpportunityId=oppo.Id, PricebookEntryId=pbeList[0].Id,
                                                                Description='Test 11', UnitPrice=11, Quantity=11,
                                                                Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert opptyProd;
        
        
        //List <Opportunity> oppList= Core_Test_Utility.createOpportunity(1);
        List<Core_Oppty_KPI_New__c> oppKPIList = new List<Core_Oppty_KPI_New__c>();
        for(Integer i=0;i<2;i++){        
            Core_Oppty_KPI_New__c OppKPI1 = new Core_Oppty_KPI_New__c();
            OppKPI1.Name='aa'+i;
            OppKPI1.Core_KPI_Opportunity__c = oppo.id;
            OppKPI1.Core_Batch_Time__c = System.Now().addHours(-4);
            OppKPI1.Core_Opportunity_KPI_Batch_ID__c = '25';
            oppKPIList.add(OppKPI1);
        }
        insert oppKPIList;
        
        
        //List <Opportunity> oppList= Core_Test_Utility.createOpportunity(1);
        List<Core_KPI_Staging__c> lstOpptyStage= new List<Core_KPI_Staging__c>();
        for(Integer i=0 ;i <200;i++)
        {
            Core_KPI_Staging__c o = new Core_KPI_Staging__c();
            if(i==0){
                o.Core_Begin_Of_File__c = true;
                
            }
            else if(i==199){
                o.Core_End_Of_File__c = true;
                
            }   
                o.core_kpi_name__c = 'aa';
                o.Core_Refresh_Type__c = 'full';
                o.core_status__c = 'Failure';
                o.Core_Batch_ID__c = '27';
                o.Core_Opportunity_ID_Txt__c = oppo.id;
                o.Core_Batch_Time__c = system.now();
                o.Core_Is_Delete__c = false;
                o.Core_Opportunity_Product_Txt__c = opptyProd.id;
            
                lstOpptyStage.add(o);
        } 
        insert lstOpptyStage;
        Test.startTest();
            Core_Batch_OpportunityKPIInsert obj = new Core_Batch_OpportunityKPIInsert(lstOpptyStage[0].Core_Batch_ID__c, 'full');
            DataBase.executeBatch(obj);
        Test.stopTest();
    }
    static testMethod void testMethod5() 
    {
        
        Account acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c= Core_CRM_Utility.getSalesGroupAPI(), Industry = 'Agriculture' , Core_Sub_Industry__c ='Animal Production');
        insert acct;
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        
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
        Opportunity oppo = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, 
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today());
        insert oppo;
        oppo.Core_Is_KPI_Refresh__c = true;
        update oppo;
        OpportunityLineItem opptyProd = new OpportunityLineItem(OpportunityId=oppo.Id, PricebookEntryId=pbeList[0].Id,
                                                                Description='Test 11', UnitPrice=11, Quantity=11,
                                                                Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert opptyProd;
        
        List <Opportunity> oppList= Core_Test_Utility.createOpportunity(1);
        List<Core_Oppty_KPI_New__c> oppKPIList = new List<Core_Oppty_KPI_New__c>();
        for(Integer i=0;i<2;i++){        
            Core_Oppty_KPI_New__c OppKPI1 = new Core_Oppty_KPI_New__c();
            OppKPI1.Name='aa'+i;
            OppKPI1.Core_KPI_Opportunity__c = oppo.id;
            OppKPI1.Core_Batch_Time__c = System.Now();
            OppKPI1.Core_Opportunity_KPI_Batch_ID__c = '25';
            oppKPIList.add(OppKPI1);
        }
        insert oppKPIList;
 
        
        //List <Opportunity> oppList= Core_Test_Utility.createOpportunity(1);
        List<Core_KPI_Staging__c> lstOpptyStage= new List<Core_KPI_Staging__c>();
        for(Integer i=0 ;i <200;i++)
        {
            Core_KPI_Staging__c o = new Core_KPI_Staging__c();
            if(i==0){
                o.Core_Begin_Of_File__c = true;
                
            }
            else if(i==199){
                o.Core_End_Of_File__c = true;
                
            }   
                o.core_kpi_name__c = 'aa';
                o.Core_Refresh_Type__c = 'full';
                o.core_status__c = 'New';
                o.Core_Batch_ID__c = '27';
                o.Core_Opportunity_ID_Txt__c = oppo.id;
                o.core_opp_kpi_product__c = product.id;
                o.Core_Batch_Time__c = system.now().addHours(-4);
                o.Core_Is_Delete__c = true;
                o.Core_Opportunity_Product_Txt__c = opptyProd.id;
                lstOpptyStage.add(o);
        } 
        insert lstOpptyStage;
        Test.startTest();
        Core_Batch_OpportunityKPIInsert obj = new Core_Batch_OpportunityKPIInsert(lstOpptyStage[0].Core_Batch_ID__c, 'full');
        DataBase.executeBatch(obj);
        Test.stopTest();
    }


    static testMethod void testMethod6() {

        Account acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St',
        BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
        BillingPostalCode = '12345',Core_Sales_Groups__c= Core_CRM_Utility.getSalesGroupAPI(), Industry = 'Agriculture' , Core_Sub_Industry__c ='Animal Production');
                insert acct;
                List<PricebookEntry> pbeList = new List<PricebookEntry>();

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
                Opportunity oppo = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, 
                                    AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today());
                insert oppo;
                oppo.Core_Is_KPI_Refresh__c = true;
                update oppo;
                OpportunityLineItem opptyProd = new OpportunityLineItem(OpportunityId=oppo.Id, PricebookEntryId=pbeList[0].Id,
                                                    Description='Test 11', UnitPrice=11, Quantity=11,
                                                    Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
                insert opptyProd;

                List <Opportunity> oppList= Core_Test_Utility.createOpportunity(1);
                List<Core_Oppty_KPI_New__c> oppKPIList = new List<Core_Oppty_KPI_New__c>();
                for(Integer i=0;i<2;i++){        
                Core_Oppty_KPI_New__c OppKPI1 = new Core_Oppty_KPI_New__c();
                OppKPI1.Name='aa'+i;
                OppKPI1.Core_KPI_Opportunity__c = oppo.id;
                OppKPI1.Core_Batch_Time__c = System.Now();
                OppKPI1.Core_Opportunity_KPI_Batch_ID__c = '25';
                oppKPIList.add(OppKPI1);
                }
                insert oppKPIList;

                Core_Batch_OpportunityKPIInsert.throwException1 = true;

                //List <Opportunity> oppList= Core_Test_Utility.createOpportunity(1);
                List<Core_KPI_Staging__c> lstOpptyStage= new List<Core_KPI_Staging__c>();
                for(Integer i=0 ;i <200;i++)
                {
                Core_KPI_Staging__c o = new Core_KPI_Staging__c();
                if(i==0){
                o.Core_Begin_Of_File__c = true;

                }
                else if(i==199){
                o.Core_End_Of_File__c = true;

                }   
                o.core_kpi_name__c = 'aa';
                o.Core_Refresh_Type__c = 'full';
                o.core_status__c = 'New';
                o.Core_Batch_ID__c = '27';
                o.Core_Opportunity_ID_Txt__c = oppo.id;
                o.core_opp_kpi_product__c = product.id;
                o.Core_Batch_Time__c = system.now().addHours(-4);
                o.Core_Is_Delete__c = true;
                o.Core_Opportunity_Product_Txt__c = opptyProd.id;
                lstOpptyStage.add(o);
                } 
                insert lstOpptyStage;
                Test.startTest();
                Core_Batch_OpportunityKPIInsert obj = new Core_Batch_OpportunityKPIInsert(lstOpptyStage[0].Core_Batch_ID__c, 'full');
                DataBase.executeBatch(obj);
                Test.stopTest();
    }

    static testMethod void testMethod7() {

        Account acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St',
        BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
        BillingPostalCode = '12345',Core_Sales_Groups__c= Core_CRM_Utility.getSalesGroupAPI(), Industry = 'Agriculture' , Core_Sub_Industry__c ='Animal Production');
                insert acct;
                List<PricebookEntry> pbeList = new List<PricebookEntry>();

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
                Opportunity oppo = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, 
                                    AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today());
                insert oppo;
                oppo.Core_Is_KPI_Refresh__c = true;
                update oppo;
                OpportunityLineItem opptyProd = new OpportunityLineItem(OpportunityId=oppo.Id, PricebookEntryId=pbeList[0].Id,
                                                    Description='Test 11', UnitPrice=11, Quantity=11,
                                                    Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
                insert opptyProd;

                List <Opportunity> oppList= Core_Test_Utility.createOpportunity(1);
                List<Core_Oppty_KPI_New__c> oppKPIList = new List<Core_Oppty_KPI_New__c>();
                for(Integer i=0;i<2;i++){        
                Core_Oppty_KPI_New__c OppKPI1 = new Core_Oppty_KPI_New__c();
                OppKPI1.Name='aa'+i;
                OppKPI1.Core_KPI_Opportunity__c = oppo.id;
                OppKPI1.Core_Batch_Time__c = System.Now();
                OppKPI1.Core_Opportunity_KPI_Batch_ID__c = '25';
                oppKPIList.add(OppKPI1);
                }
                insert oppKPIList;

                Core_Batch_OpportunityKPIInsert.throwException2 = true;

                //List <Opportunity> oppList= Core_Test_Utility.createOpportunity(1);
                List<Core_KPI_Staging__c> lstOpptyStage= new List<Core_KPI_Staging__c>();
                for(Integer i=0 ;i <200;i++)
                {
                Core_KPI_Staging__c o = new Core_KPI_Staging__c();
                if(i==0){
                o.Core_Begin_Of_File__c = true;

                }
                else if(i==199){
                o.Core_End_Of_File__c = true;

                }   
                o.core_kpi_name__c = 'aa';
                o.Core_Refresh_Type__c = 'full';
                o.core_status__c = 'New';
                o.Core_Batch_ID__c = '27';
                o.Core_Opportunity_ID_Txt__c = oppo.id;
                o.core_opp_kpi_product__c = product.id;
                o.Core_Batch_Time__c = system.now().addHours(-4);
                o.Core_Is_Delete__c = true;
                o.Core_Opportunity_Product_Txt__c = opptyProd.id;
                lstOpptyStage.add(o);
                } 
                insert lstOpptyStage;
                Test.startTest();
                Core_Batch_OpportunityKPIInsert obj = new Core_Batch_OpportunityKPIInsert(lstOpptyStage[0].Core_Batch_ID__c, 'full');
                DataBase.executeBatch(obj);
                Test.stopTest();
    }




                






    
    
}