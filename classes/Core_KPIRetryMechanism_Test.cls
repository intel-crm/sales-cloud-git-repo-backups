@isTest
public class Core_KPIRetryMechanism_Test {
    static testMethod void testMethod1(){
        List <Opportunity> oppList= Core_Test_Utility.createOpportunity(1);
        List<Id> lstOpptyStageId= new List<Id>();
        List<Core_KPI_Staging__c> lstOpptyStage= new List<Core_KPI_Staging__c>();
        List<Core_KPI_Staging__c> lstOpptyStage1= new List<Core_KPI_Staging__c>();
        for(Integer i=0 ;i <20;i++)
        {
            Core_KPI_Staging__c o = new Core_KPI_Staging__c();
            if(i==0){
                o.Core_Begin_Of_File__c = true;
                
            }
            else if(i==19){
                o.Core_End_Of_File__c = true;
                
            }   
                o.core_kpi_name__c = 'aa';
                o.Core_Refresh_Type__c = 'incremental';
                o.core_status__c = 'New';
                o.Core_Batch_ID__c = '27';
                o.Core_Opportunity_ID_Txt__c = String.valueOf(oppList[0].id);
            	o.Core_Opportunity_Stage_Txt__c = 'Design Win';
                o.Core_Batch_Time__c = System.now();
                o.Core_Retry_Counter__c = 0;
                lstOpptyStage.add(o);
        } 
        insert lstOpptyStage;
        system.assertEquals(lstOpptyStage.isempty(),false);
        for(Integer i=0 ;i <20;i++)
        {
            Core_KPI_Staging__c o = new Core_KPI_Staging__c();
            if(i==0){
                o.Core_Begin_Of_File__c = true;
                
            }
            else if(i==19){
                o.Core_End_Of_File__c = true;
                
            }   
                o.core_kpi_name__c = 'aa';
                o.Core_Refresh_Type__c = 'incremental';
                o.core_status__c = 'Failure';
                o.Core_Batch_ID__c = '27';
                o.Core_Opportunity_ID_Txt__c = String.valueOf(oppList[0].id);
            	o.Core_Opportunity_Stage_Txt__c = 'Design Win';
                o.Core_Batch_Time__c = Datetime.newInstance(2021, 01, 30, 04, 15, 00);
                o.Core_Retry_Counter__c = 0;
                lstOpptyStage1.add(o);
        } 

        
        Test.startTest();
        insert lstOpptyStage1;
        for(Core_KPI_Staging__c stagg : lstOpptyStage1){
           lstOpptyStageId.add(stagg.Id);
        }
        Core_KPIRetryMechanism.retryFailedStagingKPIs(lstOpptyStageId);
        Test.stopTest();
        
       
    }
    static testMethod void testMethod2(){ 
        List <Opportunity> oppList= Core_Test_Utility.createOpportunity(1);
        List<Id> lstOpptyStageId= new List<Id>();
        List<Core_KPI_Staging__c> lstOpptyStage= new List<Core_KPI_Staging__c>();
        List<Core_KPI_Staging__c> lstOpptyStage1= new List<Core_KPI_Staging__c>();
        for(Integer i=0 ;i <20;i++)
        {
            Core_KPI_Staging__c o = new Core_KPI_Staging__c();
            if(i==0){
                o.Core_Begin_Of_File__c = true;
                
            }
            else if(i==19){
                o.Core_End_Of_File__c = true;
                
            }   
                o.core_kpi_name__c = 'aa';
                o.Core_Refresh_Type__c = 'incremental';
                o.core_status__c = 'New';
                o.Core_Batch_ID__c = '27';
                o.Core_Opportunity_ID_Txt__c = String.valueOf(oppList[0].id);
            	o.Core_Opportunity_Stage_Txt__c = 'Design Win';
                o.Core_Batch_Time__c = System.now();
                o.Core_Retry_Counter__c = 0;
                lstOpptyStage.add(o);
        } 
        insert lstOpptyStage;
        Product2 product = new Product2(Name = 'Test Product1');
        insert product;
        
        for(Integer i=0 ;i <20;i++)
        {
            Core_KPI_Staging__c o = new Core_KPI_Staging__c();
            if(i==0){
                o.Core_Begin_Of_File__c = true;
                
            }
            else if(i==19){
                o.Core_End_Of_File__c = true;
                
            }   
                o.core_kpi_name__c = 'aa';
                o.Core_Refresh_Type__c = 'incremental';
                o.core_status__c = 'Failure';
                o.Core_Batch_ID__c = '26';
                o.Core_Opportunity_ID_Txt__c = String.valueOf(oppList[0].id);
            	o.Core_Opportunity_Stage_Txt__c = 'Design Win';
                o.Core_Batch_Time__c = Datetime.newInstance(2021, 01, 30, 04, 15, 00);
                o.core_opp_kpi_product__c = product.Id;
                o.Core_Retry_Counter__c = 0;
                lstOpptyStage1.add(o);
        } 

        
        Test.startTest();
        insert lstOpptyStage1;
        system.assertEquals(lstOpptyStage1.isempty(),false);
        for(Core_KPI_Staging__c stagg : lstOpptyStage1){
           lstOpptyStageId.add(stagg.Id);
        }
        Core_KPIRetryMechanism.retryFailedStagingKPIs(lstOpptyStageId);
        Test.stopTest();
        
       
    }
    static testMethod void testMethod3(){    
        Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' and sobjecttype = 'Account' limit 1][0].Id;
        Account acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St', RecordTypeId = newAccountRecTypeId,
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(), Industry = 'Agriculture' , Core_Sub_Industry__c ='Animal Production');
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
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Opp_Bypass_Validation_Rule__c rec = new Core_Opp_Bypass_Validation_Rule__c();
            rec.Bypass__c = true;
            insert rec;  
            oppo.StageName = 'Design Win';
            oppo.core_approval_status__c = 'Approved';
            Update oppo;
        }
        List<Core_Oppty_KPI_New__c> oppKPIList = new List<Core_Oppty_KPI_New__c>();
        for(Integer i=0;i<2;i++){        
            Core_Oppty_KPI_New__c OppKPI1 = new Core_Oppty_KPI_New__c();
            OppKPI1.Name='aa'+i;
            OppKPI1.Core_KPI_Opportunity__c = oppo.id;
            OppKPI1.Core_Batch_Time__c = System.Now().addHours(-4);
            OppKPI1.Core_Opportunity_KPI_Batch_ID__c = '25';
            OppKPI1.Core_IsActive__c = true;
            oppKPIList.add(OppKPI1);
        }
        insert oppKPIList;
        system.assertEquals(oppKPIList.isempty(),false);
        //List <Opportunity> oppList= Core_Test_Utility.createOpportunity(1);
        List<Id> lstOpptyStageId= new List<Id>();
        List<Core_KPI_Staging__c> lstOpptyStage= new List<Core_KPI_Staging__c>();
        List<Core_KPI_Staging__c> lstOpptyStage1= new List<Core_KPI_Staging__c>();
        for(Integer i=0 ;i <20;i++)
        {
            Core_KPI_Staging__c o = new Core_KPI_Staging__c();
            if(i==0){
                o.Core_Begin_Of_File__c = true;
                
            }
            else if(i==19){
                o.Core_End_Of_File__c = true;
                
            }   
                o.core_kpi_name__c = 'aa';
                o.Core_Refresh_Type__c = 'incremental';
                o.core_status__c = 'New';
                o.Core_Batch_ID__c = '27';
                o.Core_Opportunity_ID_Txt__c = String.valueOf(oppo.id);
            	o.Core_Opportunity_Stage_Txt__c = 'Design Win';
                o.Core_Batch_Time__c = System.now();
                o.Core_Retry_Counter__c = 0;
                o.Core_Is_Delete__c = true;
                lstOpptyStage.add(o);
                lstOpptyStageId.add(o.Id);
        } 
        insert lstOpptyStage;        
        List<Core_KPI_Staging__c> kpiListUpdate = new List<Core_KPI_Staging__c>();
        kpiListUpdate = [SELECT Id, Core_Status__c, Core_Retry_Counter__c, Core_Invalid_Record__c, Core_Begin_Of_File__c,Core_End_Of_File__c  FROM Core_KPI_Staging__c LIMIT 10];
        
        for(Core_KPI_Staging__c stag : kpiListUpdate){
            if(stag.Core_Begin_Of_File__c == false && stag.Core_End_Of_File__c == false){
                Core_KPI_Staging__c stagi = new Core_KPI_Staging__c();
                stagi.Id = stag.Id;
                stagi.Core_Status__c = 'Failure';
                stagi.Core_Retry_Counter__c = 1;
                stagi.Core_Invalid_Record__c = false;
                lstOpptyStage1.add(stagi);
            }
        }
        update lstOpptyStage1;        
        Test.startTest();
        for(Core_KPI_Staging__c stagg : lstOpptyStage1){
           lstOpptyStageId.add(stagg.Id);
        }
        Core_KPIRetryMechanism.retryFailedStagingKPIs(lstOpptyStageId);
        Test.stopTest();             
    } 
}