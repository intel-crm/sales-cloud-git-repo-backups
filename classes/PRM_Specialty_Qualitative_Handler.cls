/****************************************************************************************************************************
Apex Class Name     : PRM_Specialty_Qualitative_Handler 
Version             : 1.0
Created Date        : Nov 2019

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Teja Munagala      29-Nov-2019                   Added a new method specialtyDuplicateCheck to restrict duplicate  in insert and update events 

****************************************************************************************************************************/
public class PRM_Specialty_Qualitative_Handler extends TriggerHandler{

    
        
        public override void beforeInsert() {
        if(isActive('PRM_Specialty_Qualitative_Criteria')) {     //Retrieved from Custom Metadata  
           PRM_Specialty_Qualitative_Utility.specialtyDuplicateCheck(Trigger.new,null);
        }   
    }
    
    public override void beforeUpdate() {
        if(isActive('PRM_Specialty_Qualitative_Criteria')) {     //Retrieved from Custom Metadata          
           PRM_Specialty_Qualitative_Utility.specialtyDuplicateCheck(Trigger.new,(Map<Id,PRM_Specialty_Qualitative_Criteria__c>) Trigger.oldMap);
        }
    }
       
}