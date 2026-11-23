/****************************************************************************************************************************************
* Class Name  : Core_MDF_Audit_Document
* Test Class  : Core_MDF_Audit_Document_Trigger_Test
* Version     : 1.0 
* Created Date: 15-02-2022   
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – NK    		15-02-2022                   Trigger on Core_MDF_Audit_Document__c
*****************************************************************************************************************************************/

trigger Core_MDF_Audit_Document on Core_MDF_Audit_Document__c (before insert,after insert, after update) {
    
    new Core_MDF_Audit_Document_TriggerHandler().run();

}