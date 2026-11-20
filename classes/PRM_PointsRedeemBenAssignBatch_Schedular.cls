/***********************************************************************************************************************************************
Apex Class Name:  PRM_PointsRedeemBenAssignBatch_Schedular
Version     : 1.0 
Created Date: 12 July 2022
Function    : Schedular Class for Batch for 'PRM_PointsRedeemBenAssignBatch' Batch class

Modification Log :
* Developer          Date           Description                                                     TestClass
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Tanya Rajesh       12/07/2022     Schedular Class for Batch for 'PRM_PointsRedeemBenAssignBatch'  PRM_PointsRedeemBenAssignBatch_Test
                                        
*************************************************************************************************************************************************/	
global with sharing class PRM_PointsRedeemBenAssignBatch_Schedular implements Schedulable{
	global void execute(SchedulableContext sc)
    {
        //Id batchJobId = 
            Database.executeBatch(new PRM_PointsRedeemBenAssignBatch()); 
    }
}