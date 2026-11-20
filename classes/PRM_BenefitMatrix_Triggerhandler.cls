/******************************************************************************************************************************
Apex Class Name:  PRM_BenefitMatrix_Triggerhandler
Version     : 1.0 
Created Date: 15 FEB 2019
Function    : Trigger handler for the object PRM_VXBnftMatrix__c 

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
 * Teja Munagala       15-Feb-2019              Overridden the BeforeInsert(), BeforeUpdate() 
******************************************************************************************************************************/
public without sharing class PRM_BenefitMatrix_Triggerhandler extends TriggerHandler{

public override void beforeInsert(){

 if(isActive('PRM_BenfitMatrix_BeforeInsert')) //Retrieved from Custom labels
 {   
        PRM_BenefitMatrixUtility.DuplicateBMXCheck((List<PRM_VXBnftMatrix__c>)Trigger.new);    
        }
}

public override void beforeUpdate(){
if(isActive('PRM_BenfitMatrix_AfterInsert')) //Retrieved from Custom labels
 {   
        PRM_BenefitMatrixUtility.DuplicateUpdateBMXCheck((List<PRM_VXBnftMatrix__c>)Trigger.new);    
        }
}

}