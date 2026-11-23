global class Core_GetFirstResponseSLATimeInMinutes implements Support.MilestoneTriggerTimeCalculator {   

     global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
          system.debug(' Inside  SLLLAAAAAAAA class ::');
          //commented by Pavani as part of code refactor 
          /* Case caseObj = [SELECT CreatedDate, Core_First_Response_Completed__c,Core_Trigger_Next_Response__c, 
                               BusinessHoursId, Core_Next_Response_Due_Date__c, Core_IPS_Product_Org_Number__c, Priority
                        FROM Case 
                        WHERE Id=:caseId
                        LIMIT 1];
          system.debug('Completed first response due date2222222222222222222222222 '  + caseObj.Core_First_Response_Completed__c  );*/
          return Integer.valueOf(Label.CORE_IPS_CASE_SLA_FIRST_RESPONSE_IN_MINUTES);
       
     }                
}