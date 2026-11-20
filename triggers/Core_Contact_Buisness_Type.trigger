/******************************************************************************************************************************************
Trigger Name: Core_Contact_Buisness_Type
Version     : 1.0 
Created Date: 30 NOV 2021
Function    : Trigger for the object Core_Contact_Buisness_Type__c.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Gaurav Kurwade            11/11/2021           Added Trigger Handler for New framework
*****************************************************************************************************************************************/


trigger Core_Contact_Buisness_Type on Contact_Business_Types__c (before insert,after update,after insert, before update, before delete) {   
    new ER_CBT_TriggerHandler().run();
}