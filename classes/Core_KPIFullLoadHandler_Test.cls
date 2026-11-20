@isTest
public class Core_KPIFullLoadHandler_Test {
    static void setUpData(){
        Core_Trigger_Executions__c triggerSetting = new Core_Trigger_Executions__c();
        triggerSetting.name = 'KPIFullLoad';
        triggerSetting.Core_Object__c = 'Core_KPI_Staging__c';
        triggerSetting.Core_Active__c = TRUE;
        triggerSetting.Core_Description__c = 'This is test description';
        triggerSetting.Core_Class_Name__c = 'Core_KPIDeltaLoadHandler';
        triggerSetting.Core_Trigger_Events__c = 'After Insert, After Update';
        insert triggerSetting;
    }
    static testMethod void testMethod1() 
    {    
        setupData();
        SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
        Id recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(Label.Pricing_Tender_Account_RecordType_IntelAccount).getRecordTypeId();
        Account acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St', RecordTypeId = recTypeId,
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c='Americas Mexico Sales Group', Industry = 'Agriculture' , Core_Sub_Industry__c ='Animal Production');
        insert acct;
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity oppo = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, 
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today());
        List <Opportunity> oppList= new List<Opportunity>();
        oppList.add(oppo);
        insert oppList;

        List<Core_KPI_Staging__c> lstOpptyStage= new List<Core_KPI_Staging__c>();
        Set<string> batchId = new Set<String>();
        
        List<Core_Oppty_KPI_New__c> oppKPIList = new List<Core_Oppty_KPI_New__c>();
        
        for(Integer i=0;i<2;i++){        
            Core_Oppty_KPI_New__c OppKPI1 = new Core_Oppty_KPI_New__c();
            OppKPI1.Name='aa'+i;
            OppKPI1.Core_KPI_Opportunity__c = oppList[0].id;
            OppKPI1.Core_Batch_Time__c = System.Now().addHours(-4);
            OppKPI1.Core_Opportunity_KPI_Batch_ID__c = '25';
            oppKPIList.add(OppKPI1);
        }
        insert oppKPIList;
        
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
                batchId.add(o.Core_Batch_ID__c);
                lstOpptyStage.add(o);
        } 
        
        insert lstOpptyStage;
        system.assertEquals(lstOpptyStage.isEmpty(),false);
        Test.startTest();

            Core_KPIFullLoadHandler.handleFullLoad(lstOpptyStage,batchId,true);
            
        Test.stopTest();
    }
}