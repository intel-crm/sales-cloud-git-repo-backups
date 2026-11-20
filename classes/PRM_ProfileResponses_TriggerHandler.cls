public class PRM_ProfileResponses_TriggerHandler extends TriggerHandler{
    //To prevent calling handler class twice
    //Please make use of different variable for before/delete scenarios
    public static boolean firstRun = true;
    public static boolean firstUpdateRun = true;
    public static boolean firstRunRes = true;
    public static boolean firstUpdateRunRes = true; 
    public static boolean fromPoints = false;
   
    public override void afterInsert() {
        
        if(isActive('PrflRes_Insert_ERPM_Integration_Trigger') && firstRun) {
          //PRM_ProfileResponse.inactiveBenefit((List<PRM_Profile_Responses__c>)Trigger.new,null);
	     //PRM_ProfileResponse.activateBenefit((List<PRM_Profile_Responses__c>)Trigger.new,null);  
            PRM_ProfileResponse.activateInactiveBenefit((List<PRM_Profile_Responses__c>)Trigger.new, (Map<id, PRM_Profile_Responses__c>)Trigger.oldMap);
	        PRM_ProfileResponse.pointsCalculation((List<PRM_Profile_Responses__c>)Trigger.new,null);
             PRM_ProfileResponse.OPIDToLoctionRollDown((List<PRM_Profile_Responses__c>)Trigger.new, (Map<id, PRM_Profile_Responses__c>)Trigger.oldMap);
            if(system.isBatch() || System.isQueueable()){
                new ContactERPMIntegrationStatusHandler((List<PRM_Profile_Responses__c>)Trigger.new,  Trigger.new.getSObjectType());
            }
            else{
                System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_Profile_Responses__c>)Trigger.new,  Trigger.new.getSObjectType()));
            }
            if(!fromPoints){
            firstRun = false;
            }
            
        }   
    }
    
    public override void afterUpdate() {
         if(isActive('PrflRes_Update_ERPM_Integration_Trigger') && firstUpdateRun) { 
          //PRM_ProfileResponse.inactiveBenefit((List<PRM_Profile_Responses__c>)Trigger.new, (Map<id, PRM_Profile_Responses__c>)Trigger.oldMap);
	  //PRM_ProfileResponse.activateBenefit((List<PRM_Profile_Responses__c>)Trigger.new, (Map<id, PRM_Profile_Responses__c>)Trigger.oldMap);  
          PRM_ProfileResponse.activateInactiveBenefit((List<PRM_Profile_Responses__c>)Trigger.new, (Map<id, PRM_Profile_Responses__c>)Trigger.oldMap);
          PRM_ProfileResponse.OPIDToLoctionRollDown((List<PRM_Profile_Responses__c>)Trigger.new, (Map<id, PRM_Profile_Responses__c>)Trigger.oldMap);            
          PRM_ProfileResponse.pointsCalculation((List<PRM_Profile_Responses__c>)Trigger.new, (Map<id, PRM_Profile_Responses__c>)Trigger.oldMap);           
         
            boolean isUpdated = false;             
            //List<PRM_Profile_Responses__c> newProfileresponses = Trigger.New;
            //system.debug('Equals check next');
            for(PRM_Profile_Responses__c newPrRes : (List<PRM_Profile_Responses__c>)Trigger.New) {
                PRM_Profile_Responses__c oldPrRes = (PRM_Profile_Responses__c)Trigger.oldMap.get(newPrRes.Id); 
                if(newPrRes.PRM_Profile_Questions_Id__c != oldPrRes.PRM_Profile_Questions_Id__c
                   || newPrRes.PRM_Profile_Answer_Id__c != oldPrRes.PRM_Profile_Answer_Id__c
                   || newPrRes.PRM_Contact_Id__c != oldPrRes.PRM_Contact_Id__c
                   || newPrRes.PRM_InActive_Ind__c != oldPrRes.PRM_InActive_Ind__c
                   || newPrRes.PRM_Account_Id__c != oldPrRes.PRM_Account_Id__c
                   || newPrRes.PRM_Response_Txt__c != oldPrRes.PRM_Response_Txt__c                   
                  ) {                    
                      isUpdated= true; 
                      break;
                  }
                
            }
            if(isUpdated) {
               // system.debug('Before update -'+isUpdated);
                if(system.isBatch() || System.isQueueable()){
                    new ContactERPMIntegrationStatusHandler((List<PRM_Profile_Responses__c>)Trigger.new,  Trigger.new.getSObjectType());
                }
                else{
                    System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_Profile_Responses__c>)Trigger.new,  Trigger.new.getSObjectType()));  
                }
                if(!fromPoints){
                firstUpdateRun = false;
                }
            }                 
        }  
    }
    
    public override void beforeInsert() {
        for (PRM_Profile_Responses__c res: (List<PRM_Profile_Responses__c>)trigger.new) {
            if (res.PRM_Profile_Questions_Id__c != null && res.PRM_Account_Id__c != null) {
                res.Unique_Key__c = res.PRM_Account_Id__c+';'+res.PRM_Profile_Questions_Id__c+(res.PRM_Question_Type__c == 'Multiselect' ? ';'+res.PRM_Response_Txt__c : '');
            }
        }
    }
    
}