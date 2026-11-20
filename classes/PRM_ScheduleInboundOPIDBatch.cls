global without sharing class PRM_ScheduleInboundOPIDBatch implements Schedulable  {
    global void execute(SchedulableContext sc) {
 //added by anish - start
        Integer numberofRecordstoProcess = !(Test.isRunningTest()) ? integer.valueof(System.Label.PRM_OPID_Batch_Processing) : 200;
        PRM_ProcessInboundOPIDRecords b = new PRM_ProcessInboundOPIDRecords(); 
        Database.executeBatch(b,numberofRecordstoProcess);
 //added by anish - end
    }
}