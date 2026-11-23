global class Core_IPS_GetNextResponseDueDateInMis implements Support.MilestoneTriggerTimeCalculator { 
    public Static boolean runOnce = false;
    
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId) {
    
        Integer timeInMins=1;
        
        System.debug('caseId:'+caseId);
        System.debug('MileStoneTypeId:'+milestoneTypeId);                        

        /* If the case has a NULL BusinessHoursId, mileStoneUtils.getSetNextResponse will load it.
        /  This code check is no longer required.
        */
        
        Case caseObj = [SELECT CreatedDate, Core_IPS_isNextResponseActive__c,Core_Trigger_Next_Response__c, 
                               BusinessHoursId, Core_Next_Response_Due_Date__c 
                        FROM Case 
                        WHERE Id=:caseId
                        LIMIT 1];  
        System.debug('#71 caseObj: ' + caseObj);

        List<CaseMilestone> lstMilestoneObj = [SELECT Id, StartDate
                                               FROM CaseMilestone
                                               WHERE CaseId=:caseId
                                                 AND isCompleted = FALSE
                                               LIMIT 1];  
            
        CaseMilestone milestoneObj;        
        if (lstMilestoneObj.size() > 0) {
            System.debug('#72 milestoneObj: ' + milestoneObj);        
            milestoneObj = lstMilestoneObj[0];
        }
        else    
            System.debug('#73 milestoneObj IS NULL');        
                                               
                        
        if (caseObj != NULL && milestoneObj != NULL) {                        
            if (caseObj.Core_Next_Response_Due_Date__c != NULL && milestoneObj.StartDate != NULL) { 
                if (caseObj.BusinessHoursId == NULL) {                               
                    timeInMins = timeUtils.diffMinutes(milestoneObj.StartDate, caseObj.Core_Next_Response_Due_Date__c);               
                    System.debug('#74.1 milestoneObj.StartDate: ' + milestoneObj.StartDate + 
                                 '    caseObj.Core_Next_Response_Due_Date__c: ' + caseObj.Core_Next_Response_Due_Date__c + 
                                 '    timeInMins: ' + timeInMins); 
                }                
                else { 
                    Double denom = 60 * 1000;
                    timeInMins = Integer.Valueof(Math.Ceil(BusinessHours.diff(caseObj.BusinessHoursId, milestoneObj.StartDate, caseObj.Core_Next_Response_Due_Date__c) / denom));               
                    System.debug('#74.2 milestoneObj.StartDate: ' + milestoneObj.StartDate + 
                                 '    caseObj.Core_Next_Response_Due_Date__c: ' + caseObj.Core_Next_Response_Due_Date__c + 
                                 '    timeInMins: ' + timeInMins + 
                                 '    Math.Ceil: ' + Math.Ceil(BusinessHours.diff(caseObj.BusinessHoursId, milestoneObj.StartDate, caseObj.Core_Next_Response_Due_Date__c) / denom)); 
                    if (timeInMins <= 0) {                    
                        
                        // BM 8/1
                        // timeInMins = 1;
                        timeInMins = Integer.valueof(System.Label.IPS_Next_Response_Due_Default_in_Minutes);
                        
                        System.debug('#74.3 timeInMins: ' + timeInMins); 
                    }
                
                }             
            }    
        }
        else {                                          
            timeInMins = Integer.valueof(System.Label.IPS_Next_Response_Due_Default_in_Minutes);
            System.debug('#75 timeInMins: ' + timeInMins);            
        }    
        
        return timeInMins;            
                                        
    }
}