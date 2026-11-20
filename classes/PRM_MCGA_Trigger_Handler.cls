/***************************************************************************************************************************************
Apex Class Name     : PRM_MCGA_Trigger_Handler 
Version             : 1.0
Created Date        : March 2020
Function            : Handler class for PRM_MCGA_Trigger.
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Srishty                        5-June-2020                     US651041-add the contacts form the group into the message log on assigning the contact group to the message
*************************************************************************************************************************************/
public class PRM_MCGA_Trigger_Handler extends TriggerHandler{
    public override void afterInsert(){
        if(isActive('PRM_MCGA_Trigger_Switch')){
            PRM_MCGA_Trigger_Utility.createMessageLogForContact(Trigger.New);
        }     
    }
}