/******************************************************************************************************************************************
Trigger Name: Core_CampaignMember
Version     : 1.0 
Created Date: 05 OCT 2015
Function    : Trigger for the object Campaign Member.
              NOTE: this is using the new trigger framework agreed upon in the technical governance meetings,
              which is why it may look a little different than other triggers.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Dave Hood                 10/05/2015              Original version
* Dave Hood                 03/02/2016              Extended to support "Assign To User ID" lookup as records are inserted
*****************************************************************************************************************************************/
trigger Core_CampaignMember on CampaignMember (before insert, after delete) {
    
    if (Trigger.isBefore)
        Core_CampaignMemberHandler.beforeMethod(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    
    if (Trigger.isAfter)
        Core_CampaignMemberHandler.afterMethod(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
}