/**************************************************************************************
Apex Class Name:  Core_CloneDWGCtrl_Test
Version     : 1.0 
Created Date: 05 March 2019
Function    : Test class for Core_CloneDWGCtrl class
Modification Log :
* Developer                       Date                    Description
* ----------------------------------------------------------------------------                 
* Mahesh Manikonda               05/03/2019              Original Version
*************************************************************************************/

@isTest
public class Core_CloneDWGCtrl_Test {
    
    public static List<Opportunity> opportunityInstanceList = new List<Opportunity>();
    public static List<Core_Opportunity_KPI__c> opptyKPIList = new List<Core_Opportunity_KPI__c>();
    public static List<Core_Goal__c> opptyDWGList = new List<Core_Goal__c>();
    
    static testMethod void CloneTestMethod() {
        Profile pr = [SELECT id, Name FROM Profile WHERE Name='IT Admin'];
        user usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pr.Id AND isActive = true LIMIT 1];  
        
        Account accountInstance = new Account();
        accountInstance.name = 'TestAccount';
        accountInstance.BillingCountryCode = 'USA';
        accountInstance.BIllingStateCode = 'AL';
        accountInstance.BillingCity = 'Alabama';
        accountInstance.BillingStreet = 'test';  
        accountInstance.Core_CIM_ID__c='10102356';
        accountInstance.Core_Sales_Groups__c='CCG Sales Group'; 
        insert accountInstance;
        
        opportunityInstanceList.add(new Opportunity(CloseDate = System.Today().addDays(24), StageName ='Define', Name ='Test OppName', AccountId = accountInstance.Id, 
                                                    Core_First_Customer_Ship_Date__c=system.today().addDays(5), Core_Production_End_Date__c =System.Today().addDays(-10), 
                                                    Core_Opportunity_Type__c='Design: Original', Core_Intel_Platform__c='Apollo Lake D', Core_Technical_Owner__c =usr.Id));
        opportunityInstanceList.add(new Opportunity(CloseDate = System.Today().addDays(24), StageName ='Define', Name ='Test OppName123', AccountId = accountInstance.Id, 
                                                    Core_First_Customer_Ship_Date__c=system.today().addDays(5), Core_Production_End_Date__c =System.Today().addDays(-10), 
                                                    Core_Opportunity_Type__c='Design: Original', Core_Intel_Platform__c='Apollo Lake D', Core_Technical_Owner__c =usr.Id));
        opportunityInstanceList.add(new Opportunity(CloseDate = System.Today().addDays(24), StageName ='Define', Name ='Test OppName1234', AccountId = accountInstance.Id, 
                                                    Core_First_Customer_Ship_Date__c=system.today().addDays(5), Core_Production_End_Date__c =System.Today().addDays(-10), 
                                                    Core_Opportunity_Type__c='Design: Original', Core_Intel_Platform__c='Apollo Lake D', Core_Technical_Owner__c =usr.Id));
        insert opportunityInstanceList;
        
        opptyKPIList.add(new Core_Opportunity_KPI__c(Name='DCG Cloud New Services Deal #', 
                                                     Core_Opp_KPI_Opportunity__c = opportunityInstanceList[0].Id, Core_Opp_KPI_Achieved__c=true));
        opptyKPIList.add(new Core_Opportunity_KPI__c(Name='DCG Cloud New Services Deal #', 
                                                     Core_Opp_KPI_Opportunity__c = opportunityInstanceList[1].Id, Core_Opp_KPI_Achieved__c=false));
        opptyKPIList.add(new Core_Opportunity_KPI__c(Name='CCG Unite Deal #', 
                                                     Core_Opp_KPI_Opportunity__c = opportunityInstanceList[2].Id, Core_Opp_KPI_Achieved__c=false));
        insert opptyKPIList;
        
        
        opptyDWGList.add(new Core_Goal__c(Name='Test DWG1', Core_Goal_Category__c = 'Assigned', Core_Goal_BU_Focus_Area__c='DCG Cloud New Services Deal #', 
                                          Core_Goal_Criteria__c='Deal Win # based on Purley XEONS flowing into Solution Types . Threshold: 60 Units Next Gen IaaS, Deep Learning, Database, Function', 
                                          Core_Opportunity__c=opportunityInstanceList[0].Id, Core_Goal_KPI_Match_Flag__c=false, Core_Goal_KPI_Achieved_Flag__c=false,Core_Goal_Status__c='Approved',Core_Goal_Claim_Date__c=system.today(),Core_Goal_Approved_Date__c=system.today()));
        opptyDWGList.add(new Core_Goal__c(Name='Test DWG12', Core_Goal_Category__c = 'Assigned', Core_Goal_BU_Focus_Area__c='DCG Cloud New Services Deal #', 
                                          Core_Goal_Criteria__c='Deal Win # based on Purley XEONS flowing into Solution Types . Threshold: 60 Units Next Gen IaaS, Deep Learning, Database, Function', 
                                          Core_Opportunity__c=opportunityInstanceList[0].Id, Core_Goal_KPI_Match_Flag__c=false, Core_Goal_KPI_Achieved_Flag__c=false));
        insert opptyDWGList;
        /*opptyDWGList[0].recordTypeId=null;
        opptyDWGList[1].recordTypeId=null;
        update opptyDWGList;*/
        map<string,Object> CloneReturn= Core_CloneDWGCtrl.cloneAnySobjet(opptyDWGList[0].id);
        
        opptyDWGList[0].Core_Goal_Claim_Date__c=null;
        opptyDWGList[1].Core_Goal_Claim_Date__c=null;
        update opptyDWGList;
        map<string,Object> CloneReturn1= Core_CloneDWGCtrl.cloneAnySobjet(opptyDWGList[0].id);
        
        opptyDWGList[0].Core_Goal_Status__c='Draft';
        opptyDWGList[0].Core_Goal_Approved_Date__c=null;
        opptyDWGList[0].Core_Goal_Approved_By__c=null;
        
        opptyDWGList[0].Core_Goal_Approver__c=null;
        
        update opptyDWGList;
        map<string,Object> CloneReturn2= Core_CloneDWGCtrl.cloneAnySobjet(opptyDWGList[0].id);
        
        
    }
    
}