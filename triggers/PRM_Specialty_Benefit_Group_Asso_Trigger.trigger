/****************************************************************************************************************************
Apex Class Name     : PRM_Specialty_Benefit_Group_Asso_Trigger 
Version             : 1.0
Created Date        : Dec 2019

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Teja Munagala      2-Dec-2019                   Added a new method specialtyDuplicateCheck to restrict duplicate  in insert and update events 

****************************************************************************************************************************/
trigger PRM_Specialty_Benefit_Group_Asso_Trigger on PRM_Specialty_Benefit_Group_Association__c (before insert, before update) {
    // bypass added by Dinesh as part of IPA2.0 Refresh change
    if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
        new PRM_Specialty_Benefit_Group_Asso_Handler().run();
    }
}