/*********************************************************************************************************************
Class Name    : Sales_LicenseTrigger
Version       : 1.0
Created Date  : Mar 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Saba Husain           09-Mar-2021              License Trigger 
* *********************************************************************************************************************/
trigger Sales_LicenseTrigger on Sales_License__c (after Insert, before Insert, before Update, after update,before delete,after undelete) {
    /*if(Sales_UpdateContactDetails.BypassTriggerForContactUpdate==false){
    new Sales_LicenseTriggerHandler().run();
    }*/
}