public class PRM_PlatformEventBusTriggerHandler extends TriggerHandler {
	  public override void afterInsert() {
        //Method to Share Email Log records
        PRM_PlatformEventBusUtility.sendEmailLogDetails(Trigger.new);
      }
}