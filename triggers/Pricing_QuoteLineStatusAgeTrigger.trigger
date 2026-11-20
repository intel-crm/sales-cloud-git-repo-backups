/****************************************************************************************************
Apex Trigger Name : Pricing_QuoteLineStatusAgeTrigger
Version         : 1.0 
Created Date    : 18/10/2022
Function        : This is 'Quote Line Status Age' object trigger
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rahul                     18/10/2022               Created
*****************************************************************************************************/
trigger Pricing_QuoteLineStatusAgeTrigger on Pricing_Quote_Line_Status_Age__c (after insert) {
    new Pricing_QuoteLineStatusAgeHandler().run();   
}