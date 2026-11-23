/***************************************************************************************************
* Apex Class Name: Core_IPS_GetNextResponseDueDateInMis
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rickey Flores               14/2/2016               Created
* Sumukh                      06/08/2019              Modified for US390495 & DE57852
* Ganapati                    28/08/2019              Modified for DE49777
****************************************************************************************************/
global without sharing class Core_IPS_GetNextResponseDueDateInMis implements Support.MilestoneTriggerTimeCalculator { 
    public Static boolean runOnce = false;
    
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId) {
    
        Integer timeInMins=1;                     

        /* If the case has a NULL BusinessHoursId, mileStoneUtils.getSetNextResponse will load it.
        /  This code check is no longer required.
        */
        
        Case caseObj = [SELECT CreatedDate, Core_IPS_isNextResponseActive__c,Core_Trigger_Next_Response__c, 
                               BusinessHoursId, Core_Next_Response_Due_Date__c, Core_IPS_Product_Org_Number__c, Priority
                        FROM Case 
                        WHERE Id=:caseId
                        LIMIT 1];  // Modified ( added Core_IPS_Product_Org_Number__c, Priority ) by sumukh for DE57852    
       
        List<CaseMilestone> lstMilestoneObj = [SELECT Id, StartDate
                                               FROM CaseMilestone
                                               WHERE CaseId=:caseId
                                                 AND isCompleted = FALSE
                                               LIMIT 1];  
            
        CaseMilestone milestoneObj; 
        Integer nxtResponse; // added by sumukh for DE57852      
        if (lstMilestoneObj.size() > 0) {          
            milestoneObj = lstMilestoneObj[0];
        }
        else {   
           }                                    
                        
        if (caseObj != NULL && milestoneObj != NULL) {                                     
            if (caseObj.Core_Next_Response_Due_Date__c != NULL && milestoneObj.StartDate != NULL) { 
                if (caseObj.BusinessHoursId == NULL) {
                    timeInMins = timeUtils.diffMinutes(milestoneObj.StartDate, caseObj.Core_Next_Response_Due_Date__c);
                }                
                else { 
                    Double denom = 60 * 1000;
                    timeInMins = Integer.Valueof(Math.Ceil(BusinessHours.diff(caseObj.BusinessHoursId, milestoneObj.StartDate, caseObj.Core_Next_Response_Due_Date__c) / denom));
                    if (timeInMins <= 0) {                    
                        // BM 8/1
                        // timeInMins = 1;
                        timeInMins = Integer.valueof(System.Label.IPS_Next_Response_Due_Default_in_Minutes);                        
                    }
                
                }             
            }    
        }
        else { // added by sumukh for DE57852              
            nxtResponse = milestoneUtils.getBusinessHours(caseObj.Core_IPS_Product_Org_Number__c,caseObj.Priority);                
            if(nxtResponse!=null){            
              timeInMins = nxtResponse * Integer.Valueof(System.Label.IPS_Hours_in_Minutes); 
            } // end by sumukh for DE57852
            else {    
                 timeInMins = Integer.valueof(System.Label.IPS_Next_Response_Due_Default_in_Minutes);
           }                  
        }    
        return timeInMins;            
                                        
    }
}