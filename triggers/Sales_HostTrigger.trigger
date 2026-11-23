/*********************************************************************************************************************
Class Name    : Sales_HostTrigger
Version       : 1.0
Created Date  : Apr 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        21-Apr-2021             Sales_Host Trigger  
* *********************************************************************************************************************/
trigger Sales_HostTrigger on Sales_Host__c (before insert, after insert, before update, after update) {
     if(Sales_UpdateContactDetails.BypassTriggerForContactUpdate==false){
    new Sales_HostTriggerHandler().run();
     }
}