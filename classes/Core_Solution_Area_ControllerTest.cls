/******************************************************************************************************************************************
Trigger Name:  Core_Solution_Area_ControllerTest
Version     : 1.0 
Function    : Test Class to update long text with multiple picklists
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gaurav Kurwade             18/11/2022              Original Version
*****************************************************************************************************************************************/

@isTest
public class Core_Solution_Area_ControllerTest {

    static testMethod void addSolAreaTest(){
         Test.startTest();
         List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
         triggerExecList.add(new Core_Trigger_Executions__c(Name='updateJSONSolutionArea', Core_Class_Name__c='updateJSONSolutionArea', Core_Object__c='OpportunitySolutionArea', Core_Trigger_Events__c='After Insert before Delete', Core_Active__c=true, Core_Description__c = 'blah blah'));
         insert triggerExecList;
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        // Create an account
        Account acct = new Account(Name = 'TestAccount', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c='Americas Brazil Sales Group',Core_Export_Compliance_Block__c=false, Core_Deactivated__c=false);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }        
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Qualifying',Core_Product_Segment__c='Client Computing', CloseDate = System.Date.today().addYears(1));
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps;
        }
        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Core_Solution_Areas__c.getRecordTypeInfosByName();
 		Id reqRecTypeId = recordTypes.get('Requested Solutions').getRecordTypeId();

        Core_Solution_Approvers__c customsetting= new Core_Solution_Approvers__c();
		customsetting.Name='Client Computing';
        customsetting.Approver_1__c=Userinfo.getUserId();
		customsetting.Approver_2__c=Userinfo.getUserId();
		customsetting.Approver_3__c =Userinfo.getUserId();
		insert customsetting;
        List<Core_Solution_Areas__c> SAList= new List<Core_Solution_Areas__c>();
        Map<Id, Core_Solution_Areas__c> SAMap= new Map<Id, Core_Solution_Areas__c>();
        Core_Solution_Areas__c cSA = new Core_Solution_Areas__c();
        cSA.Name = 'Test1'+ (Math.random() * 10);
        cSA.Core_Version__c = 'Test1.0';
        cSA.Core_End_Customer_Solution__c = 'Yes';
        cSA.Core_Solution_Type__c = 'S1: Product';
        cSA.Core_Design_Visible__c = true;
        cSA.Core_Deal_Visible__c = true;
      //  cSA.Core_Status__c = 'Active';
        cSA.Core_Industry_Use_Case__c='Visual Cloud-CDN/vCDN';
        cSA.Core_Application_Workload__c='AI Training';
         cSA.Core_Technology_Enabled__c='AMT';
         cSA.Core_Solution_Description__c ='Desc...';
         cSA.Core_Solution_owner_email__c ='wwwwwasfdasdf@test.com';
         cSA.Core_Region_of_availability__c = 'PRC';
         cSA.RecordTypeId=reqRecTypeId;
        
		 
        insert cSA;
          
         SAList.add(cSA);
        Core_Solution_Area_Controller.addValuesToSolution(SAList);
         cSA.Core_Solution_Description__c ='Desc...111';
        cSA.Core_Solution_owner_email__c ='wwwasfdasdf@test.com';
        /* cSA.Core_Industry_Use_Case__c ='ADAS';
         cSA.Core_Application_Workload__c ='AI Training';
         cSA.Core_Technology_Enabled__c ='AMT';
         cSA.Core_Industry__c ='Agriculture';*/
         cSA.Core_Region_of_availability__c ='APJ';
		 cSA.Opportunity__c=opps.id;
		 cSA.Core_Status__c = 'Pending';
		 //System.runAs(Core_Test_Utility.systemAdminUser) {
         update cSA;
		  
		// }
          SAMap.put(cSA.Id, cSA);
		   List<Core_Solution_Areas__c> SAUpList= new List<Core_Solution_Areas__c>();
		  SAUpList.add(cSA);
          Core_Solution_Area_Controller.updatedValuesToSolution(SAList, SAMap);
         
        System.runAs(Core_Test_Utility.systemAdminUser) {
            List<Opportunity_Solution_Area__c> oSAList= new List<Opportunity_Solution_Area__c>();
            Map<Id, Opportunity_Solution_Area__c> oSAMap= new Map<Id, Opportunity_Solution_Area__c>();
            
            Opportunity_Solution_Area__c oSA= new Opportunity_Solution_Area__c();
            oSA.Core_Opportunity__c = opps.id;
            oSA.Core_Solution_Areas__c =cSA.id;
            insert oSA;
            oSAList.add(oSA);
          Core_Solution_Area_Controller.AddOpportunitySolutionArea(oSAList);
             cSA.Core_Solution_Description__c ='Desc..111.111';
         cSA.Core_Solution_owner_email__c ='wwwasfdasdf@test.com';
            cSA.Core_Industry__c='Manufacturing';
           update cSA;
		 
             Core_Solution_Area_Controller.updateOpportunitySolutionArea(SAList, SAMap);
             Core_Solution_Area_Controller.submitSolutionsforApproval(SAUpList);
             Core_Solution_Area_Controller.determineApprovers(SAUpList);
		
        }
          Test.stopTest();
    }

}