/***************************************************************************************************************************************
Apex Class Name     : PRM_MCGA_Trigger 
Version             : 1.0
Created Date        : March 2020
Function            : Trigger for PRM_Message_Contact_Group_Association__c.
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Srishty                        5-June-2020                     US651041-add the contacts form the group into the message log on assigning the contact group to the message
*************************************************************************************************************************************/
trigger PRM_MCGA_Trigger on PRM_Message_Contact_Group_Association__c (before update, before insert, after update, after insert) {
    // bypass added by Dinesh as part of IPA2.0 Refresh change
    if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
        new PRM_MCGA_Trigger_Handler().run();
    }
}