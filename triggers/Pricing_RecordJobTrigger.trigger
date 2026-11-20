/****************************************************************************************************
Apex Trigger Name : Pricing_RecordJobTrigger
Version         : 1.0 
Created Date    : 10/06/2024
Function        : This is 'Record Job' object trigger
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sandeep                 10/06/2024               Created
*****************************************************************************************************/
trigger Pricing_RecordJobTrigger on SBQQ__RecordJob__c (before update) {
    new Pricing_RecordJobHandler().run();
}