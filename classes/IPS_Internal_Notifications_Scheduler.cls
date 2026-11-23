public class IPS_Internal_Notifications_Scheduler implements Schedulable {
 public List<Id> recordListId ;
    public IPS_Internal_Notifications_Scheduler (List<Id> recordIds){
        this.recordListId = recordIds ;

    }
    public void execute(SchedulableContext sc) {
      // IPS_Internal_Notifications.updateEmailTextAndSendEmail(recordListId);
    }
}