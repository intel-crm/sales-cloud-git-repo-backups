/****************************************************************************************************
Apex Class Name : Core_Batch_DDR_NotifyApprover_Scheduler
Version         : 1.0 
Created Date    : 10/06/2017
Function        : This Scheduler class is used to schedule the batch apex 'Core_Batch_DDR_NotifyApprover'
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rajadinakaran             10/06/2017             Created
*****************************************************************************************************/
global Class Core_Batch_DDR_NotifyApprover_Scheduler implements Schedulable 
{

    global void execute(SchedulableContext sc) 
    {
        Core_Batch_DDR_NotifyApprover objCore_Batch_DDR_NotifyApprover  = new Core_Batch_DDR_NotifyApprover();
        database.executeBatch(objCore_Batch_DDR_NotifyApprover,100);
    }

    Public static void SchedulerMethod() 
    {
       
        String strJobName = 'DDR - Notify Design Approvers - New';
        
          System.schedule(strJobName, '0 0 * * * ?', new Core_Batch_DDR_NotifyApprover_Scheduler());
        //System.schedule(strJobName, '0 10 * * * ?', new Core_Batch_DDR_NotifyApprover_Scheduler());
        //System.schedule(strJobName, '0 20 * * * ?', new Core_Batch_DDR_NotifyApprover_Scheduler());
        //System.schedule(strJobName, '0 39 * * * ?', new Core_Batch_DDR_NotifyApprover_Scheduler());
        //System.schedule(strJobName, '0 40 * * * ?', new Core_Batch_DDR_NotifyApprover_Scheduler());
        //System.schedule(strJobName, '0 50 * * * ?', new Core_Batch_DDR_NotifyApprover_Scheduler());
        
    }
    
    
}