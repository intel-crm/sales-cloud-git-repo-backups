global without sharing class PRM_RegistrationApprovalEmailSchedule implements Schedulable
 {
    global void execute(SchedulableContext sc)
    {
        Integer size = Integer.valueOf(System.label.PRM_RegistrationApprovalEmail_Batch_Size);
        PRM_RegistrationApprovalEmail batch = new PRM_RegistrationApprovalEmail();
        database.executebatch(batch,size);
    }

}