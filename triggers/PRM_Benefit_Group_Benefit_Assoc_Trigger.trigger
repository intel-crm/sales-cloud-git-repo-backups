/****************************************************************************************************************************
Apex Class Name     : PRM_Benefit_Group_Benefit_Assoc_Trigger 
Version             : 1.0
Created Date        : Nov 2019

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Teja Munagala      27-Nov-2019                   Added a new method benefitDuplicateCheck(List) to restrict duplicate  in insert and update events

****************************************************************************************************************************/
trigger PRM_Benefit_Group_Benefit_Assoc_Trigger on PRM_Benefit_Group_Benefit_Association__c (before insert, before update,after insert, after update) {
    new PRM_Benefit_Group_Benefit_Assoc_Handler().run();
}