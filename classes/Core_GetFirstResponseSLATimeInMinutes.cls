global class Core_GetFirstResponseSLATimeInMinutes implements Support.MilestoneTriggerTimeCalculator {   

     global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
         
        return Integer.valueOf(Label.CORE_IPS_CASE_SLA_FIRST_RESPONSE_IN_MINUTES);       
     }                
}