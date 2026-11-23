/****************************************************************************************************
Apex Class Name : DPA_ALNLinesTriggerHandler
Version         : 1.0 
Function        : Handler class for DPA/ALN Line Trigger.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshadeep                          4/11/2021               Created
*****************************************************************************************************/
public class DPA_ALNLinesTriggerHandler extends TriggerHandler {
    /************************************************************************************************************
    *Method Name : beforeInsert
    *Created Date: 08/13/2021
    *Author: Harshadeep
    *Description : Performs operations on before insert context of trigger.
    ************************************************************************************************************/
    /*public override void beforeInsert(){
        if(isActive('PSG_DPAALNLine_BeforeInsert')){
            PSG_DPA_ALNLinesBusinessLogic.beforeInsertUpdateOperations((List<core_cpq_dpa_aln_line__c>)Trigger.new,(Map<Id,core_cpq_dpa_aln_line__c>)Trigger.oldMap,Trigger.isInsert);
        }
    }
    
    /************************************************************************************************************
    *Method Name : beforeUpdate
    *Created Date: 08/13/2021
    *Author: Harshadeep
    *Description : Performs operations on before  update context of trigger.
    ************************************************************************************************************/
    /*public override void beforeUpdate(){
        if(isActive('PSG_DPAALNLine_BeforeUpdate')){
            PSG_DPA_ALNLinesBusinessLogic.beforeInsertUpdateOperations((List<core_cpq_dpa_aln_line__c>)Trigger.new,(Map<Id,core_cpq_dpa_aln_line__c>)Trigger.oldMap,Trigger.isInsert);
        }
    }
    /************************************************************************************************************
    *Method Name : beforeDelete
    *Created Date: 08/27/2021
    *Author: Harshadeep
    *Description : Performs operations on before  delete context of trigger.
    ************************************************************************************************************/
    /*public override void beforeDelete(){
        if(isActive('PSG_DPAALNLine_BeforeDelete')){
            PSG_DPA_ALNLinesBusinessLogic.beforeDeleteOperations((List<core_cpq_dpa_aln_line__c>)Trigger.old,(Map<Id,core_cpq_dpa_aln_line__c>)Trigger.oldMap,Trigger.isDelete);
        }
    }*/
}