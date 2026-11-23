@isTest(SeeAllData=true)
private class Core_IPS_GetNextRespDueDateInMis_Test {
    
    public static testmethod void getActiveMileStone_Test1(){

        List<CaseMilestone> lstCaseMilestone = [SELECT CaseId
                                                FROM CaseMilestone
                                                WHERE BusinessHoursId != NULL 
                                                  AND isCompleted=False
                                                LIMIT 1];                                                        

        Id caseId = lstCaseMilestone[0].CaseId;

        Core_IPS_GetNextResponseDueDateInMis nextResp = new Core_IPS_GetNextResponseDueDateInMis();
        Integer timeInMins = nextResp.calculateMilestoneTriggerTime(caseId,'IPS Next Response');
    }

    public static testmethod void getActiveMileStone_Test2(){

        List<CaseMilestone> lstCaseMilestone = [SELECT CaseId
                                                FROM CaseMilestone
                                                WHERE isCompleted = False
                                                  AND StartDate != NULL
                                                  AND case.Core_Next_Response_Due_Date__c != NULL
                                                LIMIT 1];                                                        

        Id caseId = lstCaseMilestone[0].CaseId;

        Core_IPS_GetNextResponseDueDateInMis nextResp = new Core_IPS_GetNextResponseDueDateInMis();
        Integer timeInMins = nextResp.calculateMilestoneTriggerTime(caseId,'IPS Next Response');
    }
    
}