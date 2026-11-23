public class PRM_ProfileResponses_TriggerHandler extends TriggerHandler{
    //To prevent calling handler class twice
    //Please make use of different variable for before/delete scenarios
    public static boolean firstRun = true;
    public override void afterInsert() {
        if(isActive('PrflRes_Insert_ERPM_Integration_Trigger') && firstRun) {
            System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_Profile_Responses__c>)Trigger.new,  Trigger.new.getSObjectType()));
            firstRun = false;
        }
    }
    
    public override void afterUpdate() {
        if(isActive('PrflRes_Update_ERPM_Integration_Trigger') && firstRun) {
            boolean isUpdated = false; 
            //List<PRM_Profile_Responses__c> newProfileresponses = Trigger.New;
            system.debug('Equals check next');
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
                system.debug('Before update -'+isUpdated);
                System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_Profile_Responses__c>)Trigger.new,  Trigger.new.getSObjectType()));
                firstRun = false;
            }
            
        }
    }
    
}