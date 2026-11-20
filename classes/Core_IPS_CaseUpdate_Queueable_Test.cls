/***********************************************************************************************************
* Name 			: Core_IPS_CaseUpdate_Queueable_Test
* Author 		: Shipra Bardhan
* Date Created 	: 08/01/2025
* Description 	: Test Class for  Core_IPS_CaseUpdate_Queueable
* Version Updates : 1.0
* LastModified                  Date                   
* ------------------------------------------------------------------------------------------------------------                
* Shipra Bardhan             08/01/2025         		
*************************************************************************************************************/ 
@isTest
public class Core_IPS_CaseUpdate_Queueable_Test {

    private static List<Case> createTestCases(Integer numberOfCases) {
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < numberOfCases; i++) {
            cases.add(new Case(
                Subject = 'Test Case ' + i,
                Status = Math.mod(i , 2) == 0 ? 'New' : 'Closed',
                Core_Sub_Status__c = Math.mod(i , 2) == 0 ? 'Open' : 'Resolved'
            ));
        }
        insert cases;
        return cases;
    }
    
    @isTest
    static void testCore_IPS_CaseUpdate_Queueable() {
        List<Case> testCases = createTestCases(5);
        
        Map<Id, Case> caseMap = new Map<Id, Case>();
        for (Case testCase : testCases) {
            caseMap.put(testCase.Id, new Case(
                Id = testCase.Id,
                Status = testCase.Status,
                Core_Sub_Status__c = testCase.Core_Sub_Status__c
            ));
        }
        
        String strCaseList = JSON.serialize(testCases);
        String strCaseMap = JSON.serialize(caseMap);
        
        Test.startTest();
        System.enqueueJob(new Core_IPS_CaseUpdate_Queueable(strCaseList, strCaseMap));
        Test.stopTest();
        
        List<Case> updatedCases = [SELECT Id, Status, Core_Sub_Status__c FROM Case WHERE Id IN :testCases];
        
        for (Case updatedCase : updatedCases) {
            if (updatedCase.Status == 'Closed') {
                System.assert(updatedCase.Core_Sub_Status__c == 'Resolved');
            } else {
                System.assert(updatedCase.Core_Sub_Status__c == 'Open');
            }
        }
    }
}