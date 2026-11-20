/****************************************************************************************************************************
Apex Class Name     : PRM_Specialty_Qualitative_Handler 
Version             : 1.0
Created Date        : Dec 2019

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Teja Munagala      2-Dec-2019                   Added a new method specialtyDuplicateCheck to restrict duplicate  in insert and update events 

****************************************************************************************************************************/
public class PRM_Specialty_Benefit_Group_Asso_Handler extends TriggerHandler{

    
        
        public override void beforeInsert() {
        if(isActive('PRM_Specialty_Benefit_Group_Asso_switch')) {     //Retrieved from Custom Metadata  
           PRM_Specialty_Benefit_Group_Asso_Utility.specialtyDuplicateCheck(Trigger.new,null);
            PRM_Specialty_Benefit_Group_Asso_Utility.newBGspecialtyCheck(Trigger.new,null);
        }   
    }
    
    public override void beforeUpdate() {
        if(isActive('PRM_Specialty_Benefit_Group_Asso_switch')) {     //Retrieved from Custom Metadata          
           PRM_Specialty_Benefit_Group_Asso_Utility.specialtyDuplicateCheck(Trigger.new,(Map<Id,PRM_Specialty_Benefit_Group_Association__c>) Trigger.oldMap);
            PRM_Specialty_Benefit_Group_Asso_Utility.newBGspecialtyCheck(Trigger.new,(Map<Id,PRM_Specialty_Benefit_Group_Association__c>) Trigger.oldMap);
        }
    }
       
}