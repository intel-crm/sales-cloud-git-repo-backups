/***************************************************************************************************************************************
Apex Class Name     : PRM_Batch_OPID_Trigger_Scheduler 
Version             : 1.0
Created Date        : March 2020
Function            : Schedular class for PRM_OPIDTriggerBatch.
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Srishty                        9-March-2020                     US599996-This is scheduler class for PRM_OPIDTriggerBatch
* Srishty                        14-April-2020                    Batch size set to 1000 records .
* Tejasree                       7-October-2020                   US790425 - Schedular class for PRM_VxDataStageBatch 
*************************************************************************************************************************************/

global without sharing class PRM_Batch_OPID_Trigger_Scheduler implements Schedulable{
    public static String sch ='00 30 6,18 * * ? *'; //Every Day 
    global static String scheduleOPIDTriggerScheduler(String jobName) {
        PRM_Batch_OPID_Trigger_Scheduler batchOpidTrigger = new PRM_Batch_OPID_Trigger_Scheduler(); 
        return System.schedule(jobName, sch, batchOpidTrigger);
    }
    global void execute(SchedulableContext ctx) {
        PRM_VxDataStageBatch vxDataStageBatch = new PRM_VxDataStageBatch();
        //ID batchprocessid = 
            Database.executeBatch(vxDataStageBatch,Integer.valueOf(Label.PRM_OPID_VxBatch)); 
    }
}