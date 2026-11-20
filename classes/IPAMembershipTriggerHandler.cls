public class IPAMembershipTriggerHandler extends TriggerHandler {
 
    public override void beforeInsert(){ 
        IPAMembershipUtility.checkIfMultipleACMExists(Trigger.new);
        IPAMembershipUtility.checkIfAlreadyExists(Trigger.new);
    }
}