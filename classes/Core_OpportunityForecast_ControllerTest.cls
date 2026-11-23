/******************************************************************************************************************************************
Trigger Name:  Core_OpportunityForecast_ControllerTest
Version     : 1.0 
Function    : Test Class to update long text with multiple picklists
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gaurav Kurwade             12/08/2022              Original Version
*****************************************************************************************************************************************/

@isTest
public class Core_OpportunityForecast_ControllerTest {
    
    @TestSetup static void setUpData(){
        List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
        triggerExecList.add(new Core_Trigger_Executions__c(Name='updateOpportunityForecast', Core_Class_Name__c='Core_Opportunity', Core_Object__c='Opportunity Forecast', Core_Trigger_Events__c='After Update', Core_Active__c=true, Core_Description__c = 'blah blah'));
        insert triggerExecList;
        
        Core_Opp_Bypass_Validation_Rule__c bypass = new Core_Opp_Bypass_Validation_Rule__c();
        bypass.Bypass__c = true;
        insert bypass;
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        
        // Create an account
        Account acct = new Account(Name = 'TestDE', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1));
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps;
            Core_Opportunity_Forecast__c oSA= new Core_Opportunity_Forecast__c();
            oSA.Core_Opportunity__c = opps.id;
            oSA.Core_Forecast_Quarter__c ='Q4 2023';
            oSA.Core_Forecast__c = 'Commit';
            oSA.Core_Read_Only__c = false;
            insert oSA;
        }
        
        Core_CRM_Labels__c qtr = new Core_CRM_Labels__c();
        qtr.Name = 'Opportunity_Forecast_Quarters';
        qtr.Value__c = '5';
        insert qtr;
        
        Core_CRM_Labels__c qtrExtraDays = new Core_CRM_Labels__c();
        qtrExtraDays.Name = 'Oppo_Forecast_Qtr_Extra_Days';
        qtrExtraDays.Value__c = '0';
        insert qtrExtraDays;
        
    }
    
    static testMethod void oppForecastFalseTest(){           
        System.runAs(Core_Test_Utility.systemAdminUser) {
            List<Core_Opportunity_Forecast__c> oSAList= new List<Core_Opportunity_Forecast__c>();
            Core_Opportunity_Forecast__c oSA= [select id,Core_Opportunity__c,Core_Forecast_Quarter__c,Core_Forecast__c from Core_Opportunity_Forecast__c limit 1];
            oSAList.add(oSA);
            Test.startTest();
            Core_OpportunityForecastController.createOppForecastAmount(oSAList);
            Core_Opportunity_Forecast__c oSA1 = [select id,RecordTypeId,Core_Opportunity__c,Core_Forecast_Quarter__c,Core_Forecast__c from Core_Opportunity_Forecast__c limit 1];
            system.assert(oSA1.RecordTypeId!=null);
            Test.stopTest();
        }
    }
    static testMethod void oppForecastTrueTest(){        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            List<Core_Opportunity_Forecast__c> oSAList= new List<Core_Opportunity_Forecast__c>();
            Core_Opportunity_Forecast__c oSA= [select id,Core_Opportunity__c,Core_Forecast_Quarter__c,Core_Forecast__c from Core_Opportunity_Forecast__c limit 1];
            oSAList.add(oSA);
            Test.startTest();
            Core_OpportunityForecastController.createOppForecastAmount(oSAList);
            oSA.Core_Forecast_Quarter__c ='Q3 2023';
            update oSA;
            oSAList.add(oSA);
            Core_OpportunityForecastController.createOppForecastAmount(oSAList);
            oSA.Core_Forecast_Quarter__c ='Q2 2023';
            update oSA;
            oSAList.add(oSA);
            Core_OpportunityForecastController.createOppForecastAmount(oSAList);
            oSA.Core_Forecast_Quarter__c ='Q1 2023';
            update oSA;
            oSAList.add(oSA);
            Core_OpportunityForecastController.createOppForecastAmount(oSAList);
            Test.stopTest();
            Core_Opportunity_Forecast__c oSA1 = [select id,RecordTypeId,Core_Opportunity__c,Core_Forecast_Quarter__c,Core_Forecast__c from Core_Opportunity_Forecast__c limit 1];
            system.assert(oSA1.RecordTypeId!=null);
        }
    }
    static testMethod void updateForecastTrueTest(){
        System.runAs(Core_Test_Utility.systemAdminUser) { 
            List<Core_Opportunity_Forecast__c> oSAList= new List<Core_Opportunity_Forecast__c>();
            Core_Opportunity_Forecast__c oSA= [select id,Core_Opportunity__c,Core_Forecast_Quarter__c,Core_Forecast__c from Core_Opportunity_Forecast__c limit 1];
            oSAList.add(oSA);
            Core_Opportunity_Forecast__c oSA1 = [select id,RecordTypeId,Core_Opportunity__c,Core_Forecast_Quarter__c,Core_Forecast__c from Core_Opportunity_Forecast__c limit 1];
            system.assert(oSA1.RecordTypeId!=null);
        }
    }
    
    static testMethod void schdeuledForecastTrueTest(){ 
        Test.startTest();
        // This test runs a scheduled job at midnight Jan. 13th. 2023
        String CRON_EXP = '0 0 0 13 02 ? *';
        // Schedule the test job  
        String jobId = System.schedule('Core_ScheduledOppoForecastTest', CRON_EXP, new Core_ScheduledOppoForecast());
        System.assert(jobId!=null);
        Test.stopTest();        
    }
    
    static testMethod void oppForecastuniqueTest(){       
        System.runAs(Core_Test_Utility.systemAdminUser) {
            
            List<Core_Opportunity_Forecast__c> oSAList= new List<Core_Opportunity_Forecast__c>();
            Map<Id, Core_Opportunity_Forecast__c> oSAMap= new Map<Id, Core_Opportunity_Forecast__c>();
            Core_Opportunity_Forecast__c oSA= [select id,Core_Opportunity__c,Core_Forecast_Quarter__c,Core_Forecast__c from Core_Opportunity_Forecast__c limit 1];
            oSAList.add(oSA);
            for(Core_Opportunity_Forecast__c OfList: oSAList){
                oSAMap.put(OfList.Id, OfList); 
            }
            
            Test.startTest();
            Core_OpportunityForecastController.uniqueOppForecastAmount(oSAList, oSAMap);
            Core_OpportunityForecastController.restrictDeleteOppForecast(oSAList);
            Test.stopTest();
            
            oSA.Core_Forecast__c = 'Cancel';
            update oSA;
            
            Core_Opportunity_Forecast__c oSA1 = [select id,RecordTypeId,Core_Opportunity__c,Core_Forecast_Quarter__c,Core_Forecast__c from Core_Opportunity_Forecast__c limit 1];
            system.assert(oSA1.RecordTypeId!=null);
            
            delete oSA;
        }
    }
    
    static testMethod void determineQuarterTest(){
        date myDate = date.newInstance(2023, 3, 20);
        string result = Core_OpportunityForecastController.determineQuarter(myDate);
        system.assertEquals('Q1 2023', result);
        myDate = date.newInstance(2023, 5, 26);
        result =Core_OpportunityForecastController.determineQuarter(myDate);
        system.assertEquals('Q2 2023', result);
        myDate = date.newInstance(2023, 8, 26);
        result =Core_OpportunityForecastController.determineQuarter(myDate);
        system.assertEquals('Q3 2023', result);
        myDate = date.newInstance(2023, 10, 26);
        result =Core_OpportunityForecastController.determineQuarter(myDate);
        system.assertEquals('Q4 2023', result);
        Core_OpportunityForecastController.insertForecastQuarters();
    }
    
}