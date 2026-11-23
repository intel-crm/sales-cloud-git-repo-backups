/**************************************************************************************
Apex Class Name:  Core_Opp_KPI_Handler
Version     : 1.0 
Created Date: 18/1/2019
Description : Test class for the Core_Opp_KPI_Handler class
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh Manikonda            18/1/2019               Original Version
*************************************************************************************/
@isTest
public class Core_Opp_KPI_Handler_Test {
    
	public static User usr = new User();
	public static List<Core_Opportunity_KPI__c> newKPIList= new List<Core_Opportunity_KPI__c>();
	public static Map<Id, Core_Opportunity_KPI__c> oldKPIMap = new Map<Id, Core_Opportunity_KPI__c>();
    
	static void createTriggerExecutions() {        
		List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
		Core_Trigger_Executions__c triggerExec = new Core_Trigger_Executions__c();
		triggerExec.Name = 'beforeupdateinsertGoalKPI';
		triggerExec.Core_Active__c = true;
		triggerExec.Core_Class_Name__c = 'Core_Opp_KPI_Handler';
		triggerExec.Core_Description__c = 'Test';
		triggerExec.Core_Object__c = 'Core_Opportunity_KPI__c';
		triggerExec.Core_Trigger_Events__c = 'Before Insert Before Update Before Delete';
		triggerExecList.add(triggerExec);   
		insert triggerExecList;
	}
    
    Static Opportunity CreateOpportunity(){
		Profile pr = [SELECT id, Name FROM Profile WHERE Name='IT Admin'];
		usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pr.Id AND isActive = true LIMIT 1];  
		Account accountInstance = new Account();
		accountInstance.name = 'TestAccount';
		accountInstance.BillingCountryCode = 'USA';
		accountInstance.BIllingStateCode = 'AL';
		accountInstance.BillingCity = 'Alabama';
		accountInstance.BillingStreet = 'test';  
		accountInstance.Core_CIM_ID__c='10102356';
		accountInstance.Core_Sales_Groups__c='CCG Sales Group'; 
		insert accountInstance;     
		Opportunity opportunityInstance = new Opportunity();
		opportunityInstance.CloseDate = System.Today().addDays(24);
		opportunityInstance.StageName ='Define';
		opportunityInstance.Name ='Test OppName';
		opportunityInstance.AccountId = accountInstance.Id;
		opportunityInstance.Core_First_Customer_Ship_Date__c=system.today().addDays(5);
		opportunityInstance.Core_Production_End_Date__c =System.Today().addDays(-10);
		opportunityInstance.Core_Opportunity_Type__c='Design: Original';
		opportunityInstance.Core_Loss_Cancel_Details__c='Test opp record';
		opportunityInstance.Core_Intel_Platform__c='Apollo Lake D';
		opportunityInstance.Core_Technical_Owner__c =usr.Id;
		insert opportunityInstance;  
		return opportunityInstance;
    }

	testMethod static void InsertOppTest1() {
		Test.startTest();
		createTriggerExecutions();
		Opportunity opportunityInstance= CreateOpportunity();

		Core_Goal__c Goal= new Core_Goal__c();
		Goal.Name='Test Goal';
		Goal.Core_Goal_Category__c='Assigned';
		Goal.Core_Goal_BU_Focus_Area__c='DCG Cloud New Services Deal #';
		Goal.Core_Goal_Criteria__c='Deal Win # based on Purley XEONS flowing into Solution Types . Threshold: 60 Units Next Gen IaaS, Deep Learning, Database, Function';
		Goal.Core_Opportunity__c=opportunityInstance.Id;
		Goal.Core_Goal_KPI_Match_Flag__c=true;
		Goal.Core_Goal_KPI_Achieved_Flag__c=false;
		insert Goal;    
		Core_Opportunity_KPI__c OppKPI = new Core_Opportunity_KPI__c();
		OppKPI.Name='DCG Cloud New Services Deal123 #';
		OppKPI.Core_Opp_KPI_Opportunity__c=opportunityInstance.Id;
		OppKPI.Core_Opp_KPI_Achieved__c=true;
		insert OppKPI;         
		Core_Opportunity_KPI__c OppKPI1 = new Core_Opportunity_KPI__c();
		OppKPI1.Name='DCG Cloud New Services Dealqqq #';
		OppKPI1.Core_Opp_KPI_Opportunity__c=opportunityInstance.Id;
		OppKPI1.Core_Opp_KPI_Achieved__c=false;
		insert OppKPI1;
		OppKPI.Name='DCG Cloud New Services Deal #';
		OppKPI.Core_Opp_KPI_Achieved__c=false;
		update OppKPI;  
		OppKPI1.Name='DCG Cloud New Services Deal #';
		update OppKPI1;
		delete OppKPI1;
		List<Core_Goal__c> GoalLst= new List<Core_Goal__c>();
		GoalLst.add(Goal);
		newKPIList.add(OppKPI);
		oldKPIMap.put(OppKPI.Id, OppKPI);
		oldKPIMap.put(OppKPI1.Id, OppKPI1);      
		Database.SaveResult[] srList = Database.update(GoalLst, false);
		Core_Opp_KPI_Handler.updDWGonInstUpdtKPI(newKPIList,oldKPIMap,true);        
		Test.stopTest(); 
	}
	testMethod static void InsertOppTest2() {
		Test.startTest();
		createTriggerExecutions();
		Opportunity opportunityInstance= CreateOpportunity();
		Profile pr = [SELECT id, Name FROM Profile WHERE Name='IT Admin'];
		usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pr.Id AND isActive = true LIMIT 1];              Account accountInstance = new Account();
		accountInstance.name = 'TestAccount1234';
		accountInstance.BillingCountryCode = 'USA';
		accountInstance.BIllingStateCode = 'AL';
		accountInstance.BillingCity = 'Alabama';
		accountInstance.BillingStreet = 'test';  
		accountInstance.Core_CIM_ID__c='10102356';
		accountInstance.Core_Sales_Groups__c='CCG Sales Group'; 
		insert accountInstance;   
		Opportunity opportunityInstance1 = new Opportunity();
		opportunityInstance1.CloseDate = System.Today().addDays(24);
		opportunityInstance1.StageName ='Define';
		opportunityInstance1.Name ='Test OppName1233';
		opportunityInstance1.AccountId = accountInstance.Id;
		opportunityInstance1.Core_First_Customer_Ship_Date__c=system.today().addDays(5);
		opportunityInstance1.Core_Production_End_Date__c =System.Today().addDays(-10);
		opportunityInstance1.Core_Opportunity_Type__c='Design: Original';
		opportunityInstance1.Core_Loss_Cancel_Details__c='Test opp record1234';
		opportunityInstance1.Core_Intel_Platform__c='Apollo Lake D';
		opportunityInstance1.Core_Technical_Owner__c =usr.Id;
		insert opportunityInstance1;
		Core_Goal__c Goal= new Core_Goal__c();
		Goal.Name='Test Goal';
		Goal.Core_Goal_Category__c='Assigned';
		Goal.Core_Goal_BU_Focus_Area__c='DCG Cloud New Services Deal #';
		Goal.Core_Goal_Criteria__c='Deal Win # based on Purley XEONS flowing into Solution Types . Threshold: 60 Units Next Gen IaaS, Deep Learning, Database, Function';
		Goal.Core_Opportunity__c=opportunityInstance.Id;
		Goal.Core_Goal_KPI_Match_Flag__c=false;
		Goal.Core_Goal_KPI_Achieved_Flag__c=false;
		insert Goal;
		Core_Goal__c Goal1= new Core_Goal__c();
		Goal1.Name='Test Goal12';
		Goal1.Core_Goal_Category__c='Assigned';
		Goal1.Core_Goal_BU_Focus_Area__c='DCG Cloud New Services Deal #';
		Goal1.Core_Goal_Criteria__c='Deal Win # based on Purley XEONS flowing into Solution Types . Threshold: 60 Units Next Gen IaaS, Deep Learning, Database, Function';
		Goal1.Core_Opportunity__c=opportunityInstance.Id;
		Goal1.Core_Goal_KPI_Match_Flag__c=false;
		Goal1.Core_Goal_KPI_Achieved_Flag__c=false; 
		insert Goal1;
		List<Core_Goal__c> DWG= new List<Core_Goal__c>();
		DWG.add(Goal);
		DWG.add(Goal1);
		Core_Opportunity_KPI__c OppKPI = new Core_Opportunity_KPI__c();
		OppKPI.Name='DCG Cloud New Services Deal #';
		OppKPI.Core_Opp_KPI_Opportunity__c=opportunityInstance1.Id;
		OppKPI.Core_Opp_KPI_Achieved__c=true;
		insert OppKPI;
		OppKPI.Core_Opp_KPI_Achieved__c=false;
		update OppKPI;
		Core_Opportunity_KPI__c OppKPI1 = new Core_Opportunity_KPI__c();
		OppKPI1.Name='DCG Cloud New Services Deal #';
		OppKPI1.Core_Opp_KPI_Opportunity__c=opportunityInstance.Id;
		OppKPI1.Core_Opp_KPI_Achieved__c=false;
		insert OppKPI1;	
		newKPIList.add(OppKPI);
		newKPIList.add(OppKPI1);
		oldKPIMap.put(OppKPI.Id, OppKPI);
		oldKPIMap.put(OppKPI1.Id, OppKPI1);
		Core_Opp_KPI_Handler.updDWGonInstUpdtKPI(newKPIList,oldKPIMap,true);          
		Test.stopTest(); 
	}

	testMethod static void InsertOppTest3() {
		Test.startTest();
		createTriggerExecutions();
		Opportunity opportunityInstance= CreateOpportunity();
		Core_Goal__c Goal= new Core_Goal__c();
		Goal.Name='Test Goal';
		Goal.Core_Goal_Category__c='Assigned';
		Goal.Core_Goal_BU_Focus_Area__c='DCG Cloud New Services Deal #';
		Goal.Core_Goal_Criteria__c='Deal Win # based on Purley XEONS flowing into Solution Types . Threshold: 60 Units Next Gen IaaS, Deep Learning, Database, Function';
		Goal.Core_Opportunity__c=opportunityInstance.Id;
		Goal.Core_Goal_KPI_Match_Flag__c=false;     
		insert Goal;
		Core_Opportunity_KPI__c OppKPI = new Core_Opportunity_KPI__c();
		OppKPI.Name='test KPI';
		OppKPI.Core_Opp_KPI_Opportunity__c=opportunityInstance.Id;
		OppKPI.Core_Opp_KPI_Achieved__c=true;
		insert OppKPI;    
		OppKPI.Name='DCG Cloud New Services Deal #';
		update OppKPI;
		delete OppKPI;
		List<Core_Goal__c> GoalLst= new List<Core_Goal__c>();
		GoalLst.add(Goal);
		newKPIList.add(OppKPI);
		// oldKPIMap.put(OppKPI.Id, OppKPI);     
		Database.SaveResult[] srList = Database.update(GoalLst, false);
		Core_Opp_KPI_Handler.updDWGonInstUpdtKPI(newKPIList,oldKPIMap,false);
		Test.stopTest(); 
	}

	testMethod static void InsertOppTest4() {
		Test.startTest();
		createTriggerExecutions();
		Opportunity opportunityInstance= CreateOpportunity();
		Core_Goal__c Goal= new Core_Goal__c();
		Goal.Name='Test Goal';
		Goal.Core_Goal_Category__c='Assigned';
		Goal.Core_Goal_BU_Focus_Area__c='DCG Cloud New Services Deal #';
		Goal.Core_Goal_Criteria__c='Deal Win # based on Purley XEONS flowing into Solution Types . Threshold: 60 Units Next Gen IaaS, Deep Learning, Database, Function';
		Goal.Core_Opportunity__c=opportunityInstance.Id;
		Goal.Core_Goal_KPI_Match_Flag__c=false;
		insert Goal;
		Core_Opportunity_KPI__c OppKPI = new Core_Opportunity_KPI__c();
		OppKPI.Name='DCG Cloud New Services Deal #';
		OppKPI.Core_Opp_KPI_Opportunity__c=opportunityInstance.Id;
		OppKPI.Core_Opp_KPI_Achieved__c=true;
		insert OppKPI; 
		OppKPI.Core_Opp_KPI_Achieved__c=false;
		update OppKPI; 
		delete OppKPI;
		Core_Opportunity_KPI__c OppKPI1 = new Core_Opportunity_KPI__c();
		OppKPI1.Name='Test 123';
		OppKPI1.Core_Opp_KPI_Opportunity__c=opportunityInstance.Id;
		OppKPI1.Core_Opp_KPI_Achieved__c=false;
		insert OppKPI1;   
		List<Core_Goal__c> GoalLst= new List<Core_Goal__c>();
		GoalLst.add(Goal);
		newKPIList.add(OppKPI);
		newKPIList.add(OppKPI1);  
		Core_Opp_KPI_Handler.updDWGonInstUpdtKPI(newKPIList,oldKPIMap,false);      
		Test.stopTest(); 
	}  
	testMethod static void InsertOppTest5() {
		Test.startTest();
		createTriggerExecutions();
		Opportunity opportunityInstance= CreateOpportunity();

		Core_Goal__c Goal= new Core_Goal__c();
		Goal.Name='Test Goal';
		Goal.Core_Goal_Category__c='Assigned';
		Goal.Core_Goal_BU_Focus_Area__c='DCG Cloud New Services Deal #';
		Goal.Core_Goal_Criteria__c='Deal Win # based on Purley XEONS flowing into Solution Types . Threshold: 60 Units Next Gen IaaS, Deep Learning, Database, Function';
		Goal.Core_Opportunity__c=opportunityInstance.Id;
		Goal.Core_Goal_KPI_Match_Flag__c=false;
		insert Goal;
		Core_Opportunity_KPI__c OppKPI = new Core_Opportunity_KPI__c();
		OppKPI.Name='DCG Cloud New Services Deal #';
		OppKPI.Core_Opp_KPI_Opportunity__c=opportunityInstance.Id;
		OppKPI.Core_Opp_KPI_Achieved__c=false;
		insert OppKPI;         
		OppKPI.Name='Test 123';
		update OppKPI; 
		oldKPIMap.put(OppKPI.id,OppKPI);
		Core_Opp_KPI_Handler.updDWGonInstUpdtKPI(newKPIList,oldKPIMap,true);      
		Test.stopTest(); 
	}  
}