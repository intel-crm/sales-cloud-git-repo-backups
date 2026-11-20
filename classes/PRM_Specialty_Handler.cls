/****************************************************************************************************************************
Apex Class Name     : PRM_Specialty_Handler 
Version             : 1.0
Created Date        : 09 Jan 2020

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Teja Munagala      09-Jan-2020                   Added a new method beforeupdate to restrict Name change and Inative Specialty check

****************************************************************************************************************************/
public class PRM_Specialty_Handler extends TriggerHandler{
    
    public override void beforeupdate() {
             if(isActive('PRM_Specialty_Switch')) { //Retrieved from Custom Metadata  
            	PRM_Specialty_Utility.inactiveASACheck(Trigger.new,(Map<Id,PRM_Specialty__c>) Trigger.oldMap);
         }   
        
    }
    

}