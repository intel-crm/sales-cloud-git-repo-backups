/*********************************************************************************************************************
Trigger Name  : PRM_Registration_Request_Trigger
   Version       : 1.0
   Created Date  : OCT 2018
   Function      : It calls the triggerHandler of 'Registration Request' object
   
Modification Log :
    * Developer                 Date                    Description
 * --------------------------------------------------------------------------------------------------------------------
 * Kushal Soni               10/05/2018              It calls the run method of TriggerHandler of 'Registration Request' object

 *********************************************************************************************************************/

trigger PRM_Registration_Request_Trigger on PRM_Registration_Request__c (before insert, before update , after insert, after update) {
   // bypass added by Dinesh as part of IPA2.0 Refresh change
   if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
      new PRM_RegRequest_TriggerHandler().run();
   }
   
}