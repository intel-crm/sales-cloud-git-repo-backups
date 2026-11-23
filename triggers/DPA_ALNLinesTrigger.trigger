/****************************************************************************************************
Apex Class Name : DPA_ALNLinesTrigger
Version         : 1.0 
Function        : DPA/ALN Line Trigger.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshadeep		                  4/11/2021               Created
*****************************************************************************************************/
trigger DPA_ALNLinesTrigger on core_cpq_dpa_aln_line__c (before insert,after insert, after update,before update,before delete) {
    if(PSG_Constants.isDPAALNLineTriggerActive){
        new DPA_ALNLinesTriggerHandler().run();
    }
}