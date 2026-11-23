/***********************************************************************************************************************************************
Apex Class Name:  PRM_Purge_Registration_Requests
Version     : 1.0 
Created Date: 17 October 2022
Function    : Schedular Class for Batch for 'PRM_Purge_Registration_Requests' Batch class

Modification Log :
* Developer          Date           Description                                                     TestClass
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Tanya Rajesh       17/10/2022     Schedular Class for Batch for 'PRM_Purge_Registration_Requests'  PRM_Purge_Registration_Requests_Test
                                        
*************************************************************************************************************************************************/	
global class PRM_Purge_RegReq_Schedular implements Schedulable{
	global void execute(SchedulableContext sc)
    {
        Id batchJobId = Database.executeBatch(new PRM_Purge_Registration_Requests_Batch()); 
    }
}