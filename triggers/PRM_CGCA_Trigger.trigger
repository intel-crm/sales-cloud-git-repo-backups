/***************************************************************************************************************************************
Apex Class Name     : PRM_CGCA_Trigger 
Version             : 1.0
Created Date        : March 2020
Function            : PRM_CGCA_Trigger on PRM_Contact_Group_Contact_Association__c
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Srishty                        17-June-2020                     US695552-Create trigger on contact group contact association
*************************************************************************************************************************************/

trigger PRM_CGCA_Trigger on PRM_Contact_Group_Contact_Association__c (before insert,before update,after insert,after update) {
    
    // bypass added by Dinesh as part of IPA2.0 Refresh change
    if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
        new PRM_CGCA_Trigger_Handler().run();
    }
    
}