@isTest(SeeAllData=true)
public class Core_MilestoneScreenController_LEX_Test {
   
    public static TestMethod void testMethod1(){
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
                                        
        
        
        
        List<Core_MilestoneScreenController_LEX.WrapMileStone> lstWMS = Core_MilestoneScreenController_LEX.getMileStones(caseId );
    }
}