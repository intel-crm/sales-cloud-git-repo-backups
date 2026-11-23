/******************************************************************************************************************************
Apex Class Name:  Core_user
Version     : 1.0 
Created Date: 03 OCT 2014
Function    : Trigger for the object user
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kunal Mehta               11/18/2014              User assignment to a group
* Dave Hood                 12/19/2014              Opportunity Geo population
* Harshith M L              02/05/2015              Added Custom setting map ( for trigger execution ) null check - Line No 18
* Brian Matthews            03/09/2015              Clone Cleanup
* Venu Karumuru             07/24/2015              Added Method AddUsersToProfileGroups() that adds users to public groups based on their profile
* Abhishek Arya             02/02/2016              Added Method named assignContact that will assign the ContactId to User record.
* Dave Hood                 03/09/2016              Added method to freeze/unfreeze standard users instead of deactivate/reactivate
* Rajesh                    21/08/2017              Added mehtod to Mask the User EmailId.
* Abhishek Vishwakarma      27/11/2017              Added mehtod to update the region fields
* Sandeep Sankhla           27/11/2017              Added method to create contact for internal employee as customer
* Karthick                  28/03/2018              Added method to add Group Members for Employee as customer
* Karthick                  24/05/2018              Added method to assign the SFDC CountryCode based on AGS Country Code.
* Amritesh                  08/10/2018              Added method InactivateActivateInterestedParty
* Sarah Manuel              09/25/2018              Added method assignLanguage for CCF and DCF Entitlements
* Raushan Singh				29/1/2019				Added method to track user field change history
*******************************************************************************************************************************/
trigger Core_User on User(before insert, before update, after insert, after update) {
 //************ Draco Change End [29-10-2021] ********************//
     If(Trigger.IsBefore && Trigger.isUpdate){
        For(User us : Trigger.New){
            If((us.FirstName != Trigger.OldMap.get(us.Id).FirstName || us.LastName != Trigger.OldMap.get(us.Id).LastName )&& System.UserInfo.getName() == 'AGS API' && us.UserType=='Standard'){
                us.FirstName = Trigger.OldMap.get(us.Id).FirstName; 
                us.LastName = Trigger.OldMap.get(us.Id).LastName; 
                System.debug('FName->'+us.FirstName);
                System.debug('LName->'+us.LastName);
            }
        } 
 }
    
    // Fetching "Custom Setting" containing details to trigger switch on/off
    Map < String, Core_Trigger_Executions__c > mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
     public static boolean isAlreadyUpdated= false;
    if(!mapFunctionalityNameTriggerExecution.isEmpty()) {
        if (Trigger.isBefore) {
            
            if (Trigger.isInsert) {
                
                //Assign Country Code based AGS Country Code for internal users
                Core_IPS_UserTriggerHandler.convertCountryCodeToISO(Trigger.new,new Map < Id, User > {});
                
                if (mapFunctionalityNameTriggerExecution.containsKey('userGeoUpdate') &&
                    mapFunctionalityNameTriggerExecution.get('userGeoUpdate').Core_Active__c)
                    Core_UserHandler.userGeoUpdate(Trigger.new, new Map < Id, User > {});
                
                //[Below method is related to IPS and used for Linking Contact to User.]
                Core_UserHandler.assignContact(Trigger.new);
                
                //Method to check whether a User belongs to the CCF/DCF Entitlement and update the Language 
                //based on the eRPM language code
                if (mapFunctionalityNameTriggerExecution.containsKey('assignLanguage') &&
                    mapFunctionalityNameTriggerExecution.get('assignLanguage').Core_Active__c)
                {
                     Core_UserHandler.assignLanguage(Trigger.new); 
                }
                   
                
                //Create Contact from USer if Internal Employess as Customer
                Core_IPS_UserTriggerHandler.createContactForEAC(Trigger.New);                    
                
                
                
            } else if (Trigger.isUpdate) {
                //Assign Country Code based AGS Country Code for internal users
                Core_IPS_UserTriggerHandler.convertCountryCodeToISO(Trigger.new,Trigger.OldMap);   
                if (mapFunctionalityNameTriggerExecution.containsKey('userGeoUpdate') &&
                    mapFunctionalityNameTriggerExecution.get('userGeoUpdate').Core_Active__c)
                    Core_UserHandler.userGeoUpdate(Trigger.new, Trigger.OldMap);
                
                if (mapFunctionalityNameTriggerExecution.containsKey('userFreezeUnfreeze') &&
                    mapFunctionalityNameTriggerExecution.get('userFreezeUnfreeze').Core_Active__c){
                        Core_UserHandler.userFreezeUnfreeze(Trigger.OldMap, Trigger.new, Trigger.newMap);
                    }
                //Added below method to update the User EmailId.
                Core_UserHandler.updateMaskEmail(Trigger.new,Trigger.OldMap);
                
                //
               // Core_UserContact_Handler.updateUserStatusOnContact(Trigger.OldMap.keySet());
                
                /*********** Added below method to Track User field change history ******************/
                 
                  if (mapFunctionalityNameTriggerExecution.containsKey('createFeed') &&
                       mapFunctionalityNameTriggerExecution.get('createFeed').Core_Active__c)
                Core_UserFieldChangeHistoryTracker.createFeed(Trigger.old, Trigger.New, Trigger.oldMap, Trigger.newMap);
            }
        }
        
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                if (mapFunctionalityNameTriggerExecution.containsKey('userEmployeeTypeGroupAssignment') &&
                    mapFunctionalityNameTriggerExecution.get('userEmployeeTypeGroupAssignment').Core_Active__c)
                    Core_UserHandler.AddUsersToEmployeeTypeGroups(Trigger.oldMap, Trigger.newMap);
                
                if (mapFunctionalityNameTriggerExecution.containsKey('userProfileGroupAssignment') &&
                    mapFunctionalityNameTriggerExecution.get('userProfileGroupAssignment').Core_Active__c){
                        
                        Core_UserHandler.AddUsersToProfileGroups(Trigger.oldMap, Trigger.newMap);
                        
                        //Add users to Public Group if Internal Employess as Customer
                        Core_IPS_UserTriggerHandler.addEACUsersToIECGroups(Trigger.oldMap, Trigger.newMap);
                    }   
                //[Calling IPS related method to insert the Project Member.]
                Core_IPS_UserTriggerHandler.InsertProjMember(Trigger.new);
                
                //Calling IPS related method to update the region fields
                Core_IPS_UserTriggerHandler.updateUserRegionFields(Trigger.New,null);
                
                
            } else if (Trigger.isUpdate) {
                if (mapFunctionalityNameTriggerExecution.containsKey('userEmployeeTypeGroupAssignment') &&
                    mapFunctionalityNameTriggerExecution.get('userEmployeeTypeGroupAssignment').Core_Active__c)
                    Core_UserHandler.AddUsersToEmployeeTypeGroups(Trigger.oldMap, Trigger.newMap);
                
                if (mapFunctionalityNameTriggerExecution.containsKey('userProfileGroupAssignment') &&
                    mapFunctionalityNameTriggerExecution.get('userProfileGroupAssignment').Core_Active__c)
                    Core_UserHandler.AddUsersToProfileGroups(Trigger.oldMap, Trigger.newMap);
                
                if (mapFunctionalityNameTriggerExecution.containsKey('userFreezeUnfreeze') &&
                    mapFunctionalityNameTriggerExecution.get('userFreezeUnfreeze').Core_Active__c){
                        Core_UserHandler.userFreezeUnfreeze(Trigger.OldMap, Trigger.new, Trigger.newMap);
                    }
                
                //[Calling IPS related method to update the Project Member.]
                Core_IPS_UserTriggerHandler.UpdateProjMember(Trigger.oldMap,Trigger.newMap,Trigger.new);
                
                //Calling IPS related method to update the region fields
                Core_IPS_UserTriggerHandler.updateUserRegionFields(Trigger.New,Trigger.OldMap);
                
                Core_IPS_UserTriggerHandler.InactivateActivateInterestedParty(Trigger.New,Trigger.OldMap);
                
               // if (mapFunctionalityNameTriggerExecution.containsKey('updateAGSInactiveOnUserDeactivation') &&
                  //  mapFunctionalityNameTriggerExecution.get('updateAGSInactiveOnUserDeactivation').Core_Active__c)
                   // Core_UserContact_Handler.updateAGSInactiveField(Trigger.newMap.keySet());
                                                                           
            }
        }
    }
}