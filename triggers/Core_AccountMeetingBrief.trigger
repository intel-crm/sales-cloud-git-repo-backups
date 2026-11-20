/******************************************************************************************************************************************
Trigger Name: Core_AccountMeetingBrief
Version     : 1.0 
Created Date: 18 MAR 2016
Function    : Trigger for the object Account Meeting Brief
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Dave Hood                 03/18/2015              Original version
*****************************************************************************************************************************************/
trigger Core_AccountMeetingBrief on Account_Meeting_Brief__c (after insert) {
    /*
    if (Trigger.isBefore)
        Core_AccountMeetingBriefHandler.beforeMethod(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);*/
    
    if (Trigger.isAfter)
        Core_AccountMeetingBriefHandler.afterMethod(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
}