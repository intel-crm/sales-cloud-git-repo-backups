/****************************************************************************************************************************************
* Trigger Name  : PMP_Category 
* Version     : 1.0 
* Created Date: 09-11-2018
* Modification Log :
* Description:                                                
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Infosys-Sangeetha Ganta        9/11/2018                     Trigger to handle Core PMP Category functionalities. 
*****************************************************************************************************************************************/

trigger PMP_Category on PMP_Category__c (before insert, before update, after insert, after update) {
 
    new PMP_CategoryTriggerHandler().run();
}