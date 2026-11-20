/***************************************************************************************************************************
 * Apex Class Name  : ProcessLevel1ProductsQueueable
 * Author And Date  : Rohit Podder, 22 JUNE 2026
 * Function         : schedule delta load everyday on 1PM
 ****************************************************************************************************************************/
public class SchedulePIMDeltaLoad implements Schedulable, Database.AllowsCallouts {
   public void execute(SchedulableContext SC) {
      System.enqueueJob(new ProcessLevel1ProductsQueueable());
   }
}