/******************************************************************************************************************************************
Trigger Name: Core_Product
Version     : 1.0 
Created Date: 16 OCT 2015
Function    : Trigger for the object Product2.
              NOTE: this is using the new trigger framework agreed upon in the technical governance meetings,
              which is why it may look a little different than other triggers.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Dave Hood                 10/16/2015              Original version
*****************************************************************************************************************************************/
trigger Core_Product on Product2 (after update) {
    
    if (Trigger.isAfter)
        Core_ProductHandler.afterMethod(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);

}