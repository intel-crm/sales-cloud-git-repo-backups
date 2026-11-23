/****************************************************************************************************************************
Apex Class Name     : PRM_Specialty_Qualitative_Criteria_Trigger 
Version             : 1.0
Created Date        : Nov 2019

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Teja Munagala      29-Nov-2019                   Added a new method specialtyDuplicateCheck to restrict duplicate  in insert and update events

****************************************************************************************************************************/
trigger PRM_Specialty_Qualitative_Criteria_Trigger on PRM_Specialty_Qualitative_Criteria__c (before insert, before update) {
new PRM_Specialty_Qualitative_Handler().run();
}