/****************************************************************************************************
Apex Class Name : ApprovalTrigger
Version         : 1.0 
Function        : Approval Trigger.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pooja		                  4/11/2021               Created
*****************************************************************************************************/
trigger ApprovalTrigger on sbaa__Approval__c (before insert, after update,before update,after insert){
     new ApprovalTriggerHandler().run();
}