/****************************************************************************************************
Apex Trigger Name : Pricing_QuoteHoldStatusAgeTrigger
Version         : 1.0 
Created Date    : 10/02/2024
Function        : This is 'Quote Line Status Age' object trigger
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Siddharth                 10/02/2024               Created
*****************************************************************************************************/
trigger Pricing_QuoteHoldStatusAgeTrigger on Pricing_Quote_Hold_Status_Age__c (before insert, after insert) {
	new Pricing_QuoteHoldStatusAgeHandler().run();
}