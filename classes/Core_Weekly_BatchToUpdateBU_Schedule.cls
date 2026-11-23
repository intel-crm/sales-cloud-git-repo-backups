/********************************************************************************************************************
    Class Name: Core_Weekly_BatchToUpdateBU_Schedule
    Version     : 1.0 
    Created Date: 15 Sept 2020
    Function    : Schedular to class which runs Weekly  to update the BU short Name for Opp line items 
    *******************************************************************************************************************/
global without sharing class Core_Weekly_BatchToUpdateBU_Schedule implements schedulable
{
    global void execute(SchedulableContext sc)
    {
        Core_OpportunityLineBUShortName_Weekly classObj = new Core_OpportunityLineBUShortName_Weekly();
        system.debug('======'+database.executebatch(classObj,Integer.valueOf(Label.Core_BU_Batch_Size)));
    }
}