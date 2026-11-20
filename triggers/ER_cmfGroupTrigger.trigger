/******************************************************************************************************************************************
Class Name  : ER_cmfGroupTrigger
Test Class Name : ER_cmfGroupBusinessLogic_Test, Coverage:93%
Version     : 1.0 
Created Date: 15 Nov 2023
Function    : Trigger to handle CMF group business logics.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Shreyash Agrawal         15/11/2023              Original version 
*****************************************************************************************************************************************/
trigger ER_cmfGroupTrigger on ER_Customer_Master_File_Group__c (before insert , before update, after insert, after update) {
     new ER_cmfGroupTriggerHandler().run();
}