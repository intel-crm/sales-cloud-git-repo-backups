/**************************************************************************************
Apex Class Name:  Core_UpdateOppsConcateFields_Test
Version     : 1.0 
Created Date: 2/16/2023
User Story: TWC3123-3499
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pratik Padwal              2/16/2023                Initial Revision
*************************************************************************************/
@isTest
public class Core_UpdateOppsConcateFields_Test {
static Opportunity opportunityWithConcateDetails;
static Account     accountForOppos;
    
    static void setupTestData(){
	
    // A C C O U N T S
    accountForOppos = Core_Test_Utility.createAccount(1)[0];
    insert accountForOppos;
      
    // O P P O R T U N I T Y
    opportunityWithConcateDetails = Core_Test_Utility.createOpportunity(1)[0];
    opportunityWithConcateDetails.AccountId = accountForOppos.Id;
    opportunityWithConcateDetails.Core_Concatenated_Industry_use_case__c ='Human Wellness Monitoring-Chessboard;Situational Monitoring-Chessboard';
    opportunityWithConcateDetails.Core_Concatenated_Application_workload__c ='Internet of Things (IoT)';
    opportunityWithConcateDetails.Core_Concatenated_Technology_Enabled__c ='MRS/RRK WIP;MRS/RRK WIP';
    insert opportunityWithConcateDetails;
    }
    
    Static testmethod void Test_removeDuplicateValues(){
        setupTestData();
        List<Opportunity> oppsList = [SELECT id,Core_Concatenated_Industry_use_case__c,Core_Concatenated_Application_workload__c,Core_Concatenated_Technology_Enabled__c FROM Opportunity];
    
        test.startTest();
        List<Opportunity> resultOppsList = Core_UpdateOppsConcateFields.removeDuplicateValues(oppsList);
        system.Assert(resultOppsList.size()>0,'Duplicate values are removed');
        test.stopTest();
    }
        Static testmethod void Test_removeDuplicateValuesForNullList(){
        setupTestData();
        List<Opportunity> oppsList = new List<Opportunity>();

        test.startTest();
        List<Opportunity> resultOppsList = Core_UpdateOppsConcateFields.removeDuplicateValues(oppsList);
        system.Assert(resultOppsList.size()==0,'List is empty');
        test.stopTest();
    }

}