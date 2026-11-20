/****************************************************************************************************************************************
* Trigger Name  : PMP_Specification 
* Version     : 1.0 
* Created Date: 09-11-2018
* Modification Log :
* Description:                                                
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Infosys-Sangeetha Ganta        9/11/2018                     Trigger to handle Core PMP Specification functionalities. 
*****************************************************************************************************************************************/

trigger PMP_Specification on PMP_Specification__c (before insert, before update, after insert, after update) {
 
    new PMP_SpecificationTriggerHandler().run();
}