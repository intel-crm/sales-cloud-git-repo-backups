/****************************************************************************************************************************************
* Trigger Name  : PMP_Specification_Value 
* Version     : 1.0 
* Created Date: 09-11-2018
* Modification Log :
* Description:                                                
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Infosys-Sangeetha Ganta        9/11/2018                     Trigger to handle Core PMP Specification Value functionalities. 
*****************************************************************************************************************************************/

trigger PMP_Specification_Value on PMP_Specification_Value__c (before insert, before update, after insert, after update) {
 
    new PMP_SpecValueTriggerHandler().run();
}