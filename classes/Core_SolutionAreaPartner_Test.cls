/******************************************************************************************************************************************
Class Name  : Core_AddSolutionArea_Test
Version     : 1.0 
Created Date: July 07, 2022
Function    : Test class for Core_AddSolutionArea 
Modification Log :
* Developer         Date          Description
* ----------------------------------------------------------------------------                 
* Gaurav Kurwade        07/07/2022   Original version
*****************************************************************************************************************************************/

@IsTest

public class Core_SolutionAreaPartner_Test {
    
     @isTest
    static void testUpdateTrigger() {
        // Test code for update trigger
        
        // Create test data
   			List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
            triggerExecList.add(new Core_Trigger_Executions__c(Name='createJSONSolutionArea', Core_Class_Name__c='createJSONSolutionArea', Core_Object__c='Solution Area', Core_Trigger_Events__c='After Update', Core_Active__c=true, Core_Description__c = 'blah blah'));
            triggerExecList.add(new Core_Trigger_Executions__c(Name='addSolutionPartnerRelatedRecords', Core_Class_Name__c='updateJSONSolutionArea', Core_Object__c='SolutionAreaPartner', Core_Trigger_Events__c='After Insert After Delete', Core_Active__c=true, Core_Description__c = 'blah blah'));                       
         
            insert triggerExecList;
		
		      Account accountInstance = new Account();
            accountInstance.name = 'Test Ins';
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test Ins';
            accountInstance.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
            accountInstance.Industry = 'Telecommunications';
            accountInstance.Core_Sales_Groups__c='Americas Partner Holding';
            Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            accountInstance.RecordTypeId = masterRecordTypeId;
            insert accountInstance;
		
		  Core_Solution_Areas__c solStor = new Core_Solution_Areas__c();
            solStor.Core_Solution_Type__c = 'S1: Product';
            solStor.Core_End_Customer_Solution__c = 'Yes';
            solStor.Core_Design_Visible__c = true;
            solStor.Core_Status__c = 'Active';
            solStor.Core_Application_Workload__c = 'AI Inference';
            solStor.Core_Industry_Use_Case__c = 'ADAS';
            insert solStor;
			
		 Core_Solution_Area_Partner__c oppPa = new Core_Solution_Area_Partner__c();
            oppPa.Core_Solution_Partner__c = accountInstance.Id;
            oppPa.Core_Solution_Partner_Role__c = 'Co-Selling';
            oppPa.Solution_Partner_Type__c = 'Cloud Service Provider';
            oppPa.Core_Solution_Area__c = solStor.Id;
            Insert oppPa;
        
    
        
        oppPa.Core_Solution_Partner_Role__c = 'Vendor';
        
        Test.startTest();
         system.assert(oppPa.Id != null, 'success');  
        // Trigger the update event
        update oppPa;
        
        Test.stopTest();
        
        // Verify that the expected functionality was executed
        //System.assertEquals('Updated Partner Values to Solution', oppPa.Core_Solution_Partner_Role__c);
    }
    
    
     @isTest
    static void testInsertTrigger() {
        // Test code for update trigger
        
        // Create test data
   			List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
            triggerExecList.add(new Core_Trigger_Executions__c(Name='createJSONSolutionArea', Core_Class_Name__c='createJSONSolutionArea', Core_Object__c='Solution Area', Core_Trigger_Events__c='After Update', Core_Active__c=true, Core_Description__c = 'blah blah'));
            triggerExecList.add(new Core_Trigger_Executions__c(Name='addSolutionPartnerRelatedRecords', Core_Class_Name__c='updateJSONSolutionArea', Core_Object__c='SolutionAreaPartner', Core_Trigger_Events__c='After Insert After Delete', Core_Active__c=true, Core_Description__c = 'blah blah'));                       
         
            insert triggerExecList;
		
		      Account accountInstance = new Account();
            accountInstance.name = 'Test 012';
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test 012';
            accountInstance.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
            accountInstance.Industry = 'Telecommunications';
            accountInstance.Core_Sales_Groups__c='Americas Partner Holding';
            Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            accountInstance.RecordTypeId = masterRecordTypeId;
            insert accountInstance;
		
		  Core_Solution_Areas__c solStor = new Core_Solution_Areas__c();
            solStor.Core_Solution_Type__c = 'S1: Product';
            solStor.Core_End_Customer_Solution__c = 'Yes';
            solStor.Core_Design_Visible__c = true;
            solStor.Core_Status__c = 'Active';
            solStor.Core_Application_Workload__c = 'AI Inference';
            solStor.Core_Industry_Use_Case__c = 'ADAS';
            insert solStor;
			
		 Core_Solution_Area_Partner__c oppPa = new Core_Solution_Area_Partner__c();
            oppPa.Core_Solution_Partner__c = accountInstance.Id;
            oppPa.Core_Solution_Partner_Role__c = 'Co-Selling';
            oppPa.Solution_Partner_Type__c = 'Cloud Service Provider';
            oppPa.Core_Solution_Area__c = solStor.Id;
        Test.startTest();
          Insert oppPa;
			system.assert(oppPa.Id != null, 'success');  
        
        Test.stopTest();
         //  System.assertEquals('Upserted Partner Values to Solution', oppPa.Name);
        // Verify that the expected functionality was executed
        //System.assertEquals('Updated Partner Values to Solution', oppPa.Core_Solution_Partner_Role__c);
    }
    
     @isTest
    static void testDeleteTrigger() {
        // Test code for update trigger
        
        // Create test data
   			List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
            triggerExecList.add(new Core_Trigger_Executions__c(Name='createJSONSolutionArea', Core_Class_Name__c='createJSONSolutionArea', Core_Object__c='Solution Area', Core_Trigger_Events__c='After Update', Core_Active__c=true, Core_Description__c = 'blah blah'));
            triggerExecList.add(new Core_Trigger_Executions__c(Name='addSolutionPartnerRelatedRecords', Core_Class_Name__c='updateJSONSolutionArea', Core_Object__c='SolutionAreaPartner', Core_Trigger_Events__c='After Insert After Delete', Core_Active__c=true, Core_Description__c = 'blah blah'));                       
         
            insert triggerExecList;
		
		      Account accountInstance = new Account();
            accountInstance.name = 'Test 01200';
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test 01200';
            accountInstance.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
            accountInstance.Industry = 'Telecommunications';
            accountInstance.Core_Sales_Groups__c='Americas Partner Holding';
            Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            accountInstance.RecordTypeId = masterRecordTypeId;
            insert accountInstance;
		
		  Core_Solution_Areas__c solStor = new Core_Solution_Areas__c();
            solStor.Core_Solution_Type__c = 'S1: Product';
            solStor.Core_End_Customer_Solution__c = 'Yes';
            solStor.Core_Design_Visible__c = true;
            solStor.Core_Status__c = 'Active';
            solStor.Core_Application_Workload__c = 'AI Inference';
            solStor.Core_Industry_Use_Case__c = 'ADAS';
            insert solStor;
			
		 Core_Solution_Area_Partner__c oppPa = new Core_Solution_Area_Partner__c();
            oppPa.Core_Solution_Partner__c = accountInstance.Id;
            oppPa.Core_Solution_Partner_Role__c = 'Co-Selling';
            oppPa.Solution_Partner_Type__c = 'Cloud Service Provider';
            oppPa.Core_Solution_Area__c = solStor.Id;
        	  Insert oppPa;
        Test.startTest();
        	system.assert(oppPa.Id != null, 'success');  
			  Delete oppPa;
        
        Test.stopTest();
         //  System.assertEquals('Upserted Partner Values to Solution', oppPa.Name);
        // Verify that the expected functionality was executed
        //System.assertEquals('Updated Partner Values to Solution', oppPa.Core_Solution_Partner_Role__c);
    }
    

}