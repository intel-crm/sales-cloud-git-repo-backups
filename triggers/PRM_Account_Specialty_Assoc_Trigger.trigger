/****************************************************************************************************************************
Apex Class Name     : PRM_Account_Specialty_Assoc_Trigger 
Version             : 1.0
Created Date        : Nov 2019

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Teja Munagala      27-Nov-2019                   Added a new method specialtyDuplicateCheck to restrict duplicate  in insert and update events 

****************************************************************************************************************************/
trigger PRM_Account_Specialty_Assoc_Trigger on PRM_Account_Specialty_Association__c (before insert, before update, after insert, after update) {
    // bypass added by Dinesh as part of IPA2.0 Refresh change
    if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
        new PRM_Account_Specialty_Assoc_Handler().run();
    }
    
}