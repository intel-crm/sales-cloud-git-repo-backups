/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_Scheduler_Multicurrency_Test 
* Version     : 1.0 
* Created Date: 12-05-2018
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Narayani Perachi 		12-05-2018					  Test class for Core_MDF_SchedulerClass_Multicurrency
**************************************************************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_Scheduler_Multicurrency_Test 
    {
        
        @isTest static void testExecute()
            {           
                Core_MDF_SchedulerClass_Multicurrency test = new Core_MDF_SchedulerClass_Multicurrency();
                test.execute(null);            
            }
    
    }