public class PRM_Whitelisted_Domain_TriggerHandler extends TriggerHandler {
    public static boolean IPAfirstRun = true;
    //chaithaly - commenting as part of IP2.0
  /*  public override void afterInsert() {
        if(isActive('AWD_Insert_IPA_Integration_Trigger') && IPAfirstRun) {            
            System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<Core_Account_Whitelisted_Domains__c>)Trigger.new,  Trigger.new.getSObjectType()));
            IPAfirstRun = false;
        }
    } */
    
    public override void afterUpdate() {   
        if(isActive('AWD_Update_IPA_Integration_Trigger') && IPAfirstRun) { 
            
            boolean isUpdated = false;
            for(Core_Account_Whitelisted_Domains__c newAWD : (List<Core_Account_Whitelisted_Domains__c>)Trigger.new) {
                Core_Account_Whitelisted_Domains__c oldAWD = (Core_Account_Whitelisted_Domains__c)Trigger.oldMap.get(newAWD.Id);
                if(newAWD.Inactive_Indicator__c != oldAWD.Inactive_Indicator__c || newAWD.Name != oldAWD.Name) {
                    isUpdated = true;
                    break;
                }
            } 
           /* if(isUpdated)
            {
                System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<Core_Account_Whitelisted_Domains__c>)Trigger.new,  Trigger.new.getSObjectType()));
                IPAfirstRun = false;
            }*/
        }
    }
    
}