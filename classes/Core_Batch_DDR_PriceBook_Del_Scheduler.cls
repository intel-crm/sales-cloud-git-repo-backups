/****************************************************************************************************
Apex Class Name : Core_Batch_DDR_PriceBook_Scheduler_Del
Version         : 1.0 
Created Date    : 01/19/2018
Function        : This Scheduler class is used to schedule the batch apex 'Core_Batch_DDR_PriceBook_Del'
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rajadinakaran              01/19/2018             Created
*****************************************************************************************************/
global Class Core_Batch_DDR_PriceBook_Del_Scheduler implements Schedulable 
{

    global void execute(SchedulableContext sc) 
    {
        Core_Batch_DDR_PriceBook_Del objCore_Batch_DDR_PriceBook  = new Core_Batch_DDR_PriceBook_Del();
        database.executeBatch(objCore_Batch_DDR_PriceBook,100);
    }

    Public static void SchedulerMethod() 
    {
        
        String strJobName = 'DDR - Update Partner Price Book - Removal';
        
          System.schedule(strJobName, '0 0 * * * ?',  new Core_Batch_DDR_PriceBook_Del_Scheduler());
        //System.schedule(strJobName, '0 10 * * * ?', new Core_Batch_DDR_PriceBook_Del_Scheduler());
        //System.schedule(strJobName, '0 20 * * * ?', new Core_Batch_DDR_PriceBook_Del_Scheduler());
        //System.schedule(strJobName, '0 39 * * * ?', new Core_Batch_DDR_PriceBook_Del_Scheduler());
        //System.schedule(strJobName, '0 40 * * * ?', new Core_Batch_DDR_PriceBook_Del_Scheduler());
        //System.schedule(strJobName, '0 50 * * * ?', new Core_Batch_DDR_PriceBook_Del_Scheduler());
        
    }
    
    
}