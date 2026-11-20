/*
Modification Log
Brian Matthews     6/5/16    Wingin'It Here.
*/
@isTest(SeeAllData=true)

public class Core_MilestoneScreenController_Test { 
            
    public testMethod static void testMSC_1(){
        
        List<AggregateResult> aggResult = [SELECT CaseId
                                           FROM CaseMilestone
                                           WHERE BusinessHoursId != NULL 
                                           GROUP BY CaseId
                                           HAVING COUNT(Id) > 4
                                           LIMIT 1];
                                                          
        Object objCaseId = aggResult[0].get('CaseId');                                                                                      
        Id caseId = (Id)objCaseId;
        List<Case> lstCase = [SELECT Id
                              FROM Case
                              WHERE Id = :caseId 
                              LIMIT 1];        
                                        
        ApexPages.StandardController StndContr = new ApexPages.standardController(lstCase[0]);
        Core_MilestoneScreenController ctrlMSC = new Core_MilestoneScreenController(StndContr);
        Core_IPS_MilestoneScreen_Controller.getcaseMilestones(lstCase[0].id);
        List<Core_MilestoneScreenController.WrapMileStone> lstWMS = ctrlMSC.getcaseMilestones();
    }
}