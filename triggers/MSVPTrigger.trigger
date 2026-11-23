/****************************************************************************************************
Apex Class Name : MSVPTrigger
Version         : 1.0 
Created Date    : 01/05/2021
Function        : Trigger for MSVP object
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Raju Malepalli                     01/05/2021               Created
*****************************************************************************************************/
trigger MSVPTrigger on price_msvp__c (before insert,after insert, after update, before update) {
    new MSVPTriggerHandler().run();
}