/*
 * Starts PRM_OpidPartnerAdminFlagService.SyncJob (SET, then CLEAR) on a schedule.
 *
 * Hourly (Anonymous Apex, run once):
 *   System.schedule('PRM OPID PA Flag Sync', '0 0 * * * ?', new PRM_OpidPartnerAdminFlagScheduler());
 */
public class PRM_OpidPartnerAdminFlagScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        System.enqueueJob(new PRM_OpidPartnerAdminFlagService.SyncJob());
    }
}