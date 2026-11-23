/****************************************************************************************************
Apex Class Name : Core_Batch_DDR_PriceBook_Scheduler
Version         : 1.0 
Created Date    : 11/03/2017
Function        : This Scheduler class is used to schedule the batch apex 'Core_Batch_DDR_PriceBook'
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rajadinakaran             11/03/2017             Created
*****************************************************************************************************/
global Class Core_Batch_DDR_PriceBook_Scheduler implements Schedulable 
{

    global void execute(SchedulableContext sc) 
    {
        Core_Batch_DDR_PriceBook objCore_Batch_DDR_PriceBook  = new Core_Batch_DDR_PriceBook();
        database.executeBatch(objCore_Batch_DDR_PriceBook,100);
    }

    Public static void SchedulerMethod() 
    {
        
        String strJobName = 'DDR - Update Partner Price Book';
        
          System.schedule(strJobName, '0 0 * * * ?',  new Core_Batch_DDR_PriceBook_Scheduler());
        //System.schedule(strJobName, '0 10 * * * ?', new Core_Batch_DDR_PriceBook_Scheduler());
        //System.schedule(strJobName, '0 20 * * * ?', new Core_Batch_DDR_PriceBook_Scheduler());
        //System.schedule(strJobName, '0 39 * * * ?', new Core_Batch_DDR_PriceBook_Scheduler());
        //System.schedule(strJobName, '0 40 * * * ?', new Core_Batch_DDR_PriceBook_Scheduler());
        //System.schedule(strJobName, '0 50 * * * ?', new Core_Batch_DDR_PriceBook_Scheduler());
        
    }
    
    
}