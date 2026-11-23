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
* Raushan Singh             29/1/2019               Added method to track user field change history
* Ganapati                  22/04/2020              Added Method shareAssetsToCustomers for US618169 - PRB000091747: Fix issue with Product Access and when Contacts become IPS Active
* Akshay More [Draco]       29/10/2021              Added logic to check if the trigger is hit due to leads updated in batch class 'Core_PartnerLeads_Count_Batch'
* Shraddha More             14/02/2024              Added logic to share user records with Integration user present in mapping().
*******************************************************************************************************************************/
trigger Core_User on User(before insert, before update, after insert, after update) {
    
    //************ Draco Change Start [29-10-2021] ********************//
    boolean leadTriggerExecution = FALSE; // Boolean variable to check if the trigger is hit due to leads updated in batch class 'Core_PartnerLeads_Count_Batch'
    if (Trigger.isUpdate) {
        for(User obj : trigger.new){
            if(obj.Core_Lead_Field_Update_Date__c != null && obj.Core_Lead_Field_Update_Date__c != Trigger.oldMap.get(obj.id).Core_Lead_Field_Update_Date__c){
                leadTriggerExecution = TRUE;
                break;
            }
        }
    }
    //************ Draco Change End [29-10-2021] ********************//
    
    /*Draco[Shubham] - Start - Code update to restrict recursive update of user name from AGS and CDIS & to allow only CDIS to update user name instead of AGS */
    if(Trigger.IsBefore && Trigger.isUpdate){
        for(User us : Trigger.New){
            boolean nameChanged = (us.FirstName != Trigger.OldMap.get(us.Id).FirstName || us.LastName != Trigger.OldMap.get(us.Id).LastName);
            boolean isAGSUser = System.UserInfo.getName() == 'AGS API' && us.UserType=='Standard';
            
            if(nameChanged && isAGSUser){
                us.FirstName = Trigger.OldMap.get(us.Id).FirstName; 
                us.LastName = Trigger.OldMap.get(us.Id).LastName; 
            }
            
            /*Draco-when both active and license reclaimed flags are true, updating license reclaimed to false from all the sources for all the internal or external users */
            boolean isActivated = (us.IsActive != Trigger.OldMap.get(us.Id).IsActive) && us.IsActive == true;
            if(isActivated && us.Partner_License_Reclaimed__c == true){
                us.Partner_License_Reclaimed__c=false;
            }
        }  
    }
    /*Draco[Shubham] - End - Code update to restrict recursive update of user name from AGS and CDIS & to allow only CDIS to update user name instead of AGS */
        
    // Fetching "Custom Setting" containing details to trigger switch on/off
    Map <String, Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();          
    if(mapFunctionalityNameTriggerExecution.isEmpty()) {
        return;
    }
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            //Assign Country Code based AGS Country Code for internal users
            Core_IPS_UserTriggerHandler.convertCountryCodeToISO(Trigger.new,new Map < Id, User > {});
            
            boolean userGeoUpdateActive = mapFunctionalityNameTriggerExecution.containsKey('userGeoUpdate') &&
                mapFunctionalityNameTriggerExecution.get('userGeoUpdate').Core_Active__c;
            if (userGeoUpdateActive) {
                Core_UserHandler.userGeoUpdate(Trigger.new, new Map < Id, User > {});
            }
            
            //[Below method is related to IPS and used for Linking Contact to User.]
            Core_UserHandler.assignContact(Trigger.new);
            
            //Method to check whether a User belongs to the CCF/DCF Entitlement and update the Language 
            //based on the eRPM language code
            boolean assignLanguageActive = mapFunctionalityNameTriggerExecution.containsKey('assignLanguage') &&
                mapFunctionalityNameTriggerExecution.get('assignLanguage').Core_Active__c;
            if (assignLanguageActive) {
                Core_UserHandler.assignLanguage(Trigger.new); 
            }
            
            //Create Contact from USer if Internal Employess as Customer
            Core_IPS_UserTriggerHandler.createContactForEAC(Trigger.New);                    
            
            //Method to create IPA users with employee entitlements with inactive status. 
            boolean createInactiveIPAUserActive = mapFunctionalityNameTriggerExecution.containsKey('createInactiveIPAUser') &&
                mapFunctionalityNameTriggerExecution.get('createInactiveIPAUser').Core_Active__c;
            if (createInactiveIPAUserActive){
                Core_UserHandler.createInactiveIPAUser(Trigger.new); 
            }           
        } 
        
        if (Trigger.isUpdate) {
            //Assign Country Code based AGS Country Code for internal users
            Core_IPS_UserTriggerHandler.convertCountryCodeToISO(Trigger.new,Trigger.OldMap);   
            
            boolean userGeoUpdateActive = mapFunctionalityNameTriggerExecution.containsKey('userGeoUpdate') &&
                mapFunctionalityNameTriggerExecution.get('userGeoUpdate').Core_Active__c;
            if (userGeoUpdateActive) {
                Core_UserHandler.userGeoUpdate(Trigger.new, Trigger.OldMap);
            }
            
            boolean userFreezeUnfreezeActive = mapFunctionalityNameTriggerExecution.containsKey('userFreezeUnfreeze') &&
                mapFunctionalityNameTriggerExecution.get('userFreezeUnfreeze').Core_Active__c;
            if (userFreezeUnfreezeActive){
                Core_UserHandler.userFreezeUnfreeze(Trigger.OldMap, Trigger.new, Trigger.newMap);
            }
            
            //Added below method to update the User EmailId.
            Core_UserHandler.updateMaskEmail(Trigger.new,Trigger.OldMap);
            
            /*********** Added below method to Track User field change history ******************/
            boolean createFeedActive = mapFunctionalityNameTriggerExecution.containsKey('createFeed') &&
                mapFunctionalityNameTriggerExecution.get('createFeed').Core_Active__c;
            if (createFeedActive) {
                Core_UserFieldChangeHistoryTracker.createFeed(Trigger.old, Trigger.New, Trigger.oldMap, Trigger.newMap);
            }
        }
    }
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            Core_IPS_UserTriggerHandler.shareAssetsToCustomers(Trigger.new); // added by Ganapati for US618169
            
            boolean userEmployeeTypeGroupAssignmentActive = mapFunctionalityNameTriggerExecution.containsKey('userEmployeeTypeGroupAssignment') &&
                mapFunctionalityNameTriggerExecution.get('userEmployeeTypeGroupAssignment').Core_Active__c;
            if (userEmployeeTypeGroupAssignmentActive) {
                Core_UserHandler.AddUsersToEmployeeTypeGroups(Trigger.oldMap, Trigger.newMap);
            }
            
            boolean userProfileGroupAssignmentActive = mapFunctionalityNameTriggerExecution.containsKey('userProfileGroupAssignment') &&
                mapFunctionalityNameTriggerExecution.get('userProfileGroupAssignment').Core_Active__c;
            if (userProfileGroupAssignmentActive){
                Core_UserHandler.AddUsersToProfileGroups(Trigger.oldMap, Trigger.newMap);
                //Add users to Public Group if Internal Employess as Customer
                Core_IPS_UserTriggerHandler.addEACUsersToIECGroups(Trigger.oldMap, Trigger.newMap);
            }   
            
            //[Calling IPS related method to insert the Project Member.]
            Core_IPS_UserTriggerHandler.InsertProjMember(Trigger.new);
            
            //[Calling IPS related method to update the Project Member and Interested Party user for UIOLI]
            Core_IPS_UserTriggerHandler.UpdateUIOLIUserLostVisibilty(Trigger.newMap);
            
            //Calling IPS related method to update the region fields
            Core_IPS_UserTriggerHandler.updateUserRegionFields(Trigger.New,null);
            
            //Calling PSG related method to share License & Host records for PSG users
            if(leadTriggerExecution == FALSE){ //************ Draco Change [29-10-2021]
                Core_UserHandler.shareLicenseAndHostRecordsForPSG(Trigger.New, Trigger.oldMap);
            }
            
            //Calling PCC method to share user records with Integration user
            if(TriggerHandler.isActive('PCC_UserSharing_Switch')) {
                Core_UserHandler.PCC_ShareUserWithM2MUsers(Trigger.New, 'Insert', Trigger.oldMap);
            }
        } 
        
        if (Trigger.isUpdate) {
            boolean userEmployeeTypeGroupAssignmentActive = mapFunctionalityNameTriggerExecution.containsKey('userEmployeeTypeGroupAssignment') &&
                mapFunctionalityNameTriggerExecution.get('userEmployeeTypeGroupAssignment').Core_Active__c;
            if (userEmployeeTypeGroupAssignmentActive) {
                Core_UserHandler.AddUsersToEmployeeTypeGroups(Trigger.oldMap, Trigger.newMap);
            }
            
            boolean userProfileGroupAssignmentActive = mapFunctionalityNameTriggerExecution.containsKey('userProfileGroupAssignment') &&
                mapFunctionalityNameTriggerExecution.get('userProfileGroupAssignment').Core_Active__c;
            if (userProfileGroupAssignmentActive) {
                Core_UserHandler.AddUsersToProfileGroups(Trigger.oldMap, Trigger.newMap);    
            }
            
            boolean userFreezeUnfreezeActive = mapFunctionalityNameTriggerExecution.containsKey('userFreezeUnfreeze') &&
                mapFunctionalityNameTriggerExecution.get('userFreezeUnfreeze').Core_Active__c;
            if (userFreezeUnfreezeActive){
                Core_UserHandler.userFreezeUnfreeze(Trigger.OldMap, Trigger.new, Trigger.newMap);
            }

            //[Calling IPS related method to update the Project Member.]
            if(leadTriggerExecution == FALSE){ //************ Draco Change [29-10-2021]
                Core_IPS_UserTriggerHandler.UpdateProjMember(Trigger.oldMap,Trigger.newMap,Trigger.new);
            }
            
            //Calling IPS related method to update the region fields
            Core_IPS_UserTriggerHandler.updateUserRegionFields(Trigger.New,Trigger.OldMap);
            Core_IPS_UserTriggerHandler.InactivateActivateInterestedParty(Trigger.New,Trigger.OldMap);
            
            boolean updateAGSInactiveActive = mapFunctionalityNameTriggerExecution.containsKey('updateAGSInactiveOnUserDeactivation') &&
                mapFunctionalityNameTriggerExecution.get('updateAGSInactiveOnUserDeactivation').Core_Active__c;
            boolean shouldUpdateAGS = updateAGSInactiveActive && leadTriggerExecution == FALSE && System.IsBatch() == false && System.IsFuture() == false;
            
            if (shouldUpdateAGS) {
                Set<Id> userListtoUpdate = new Set<Id>{};
                for(User us : Trigger.New){
                    if(us.IsActive != Trigger.OldMap.get(us.Id).IsActive){
                        userListtoUpdate.add(us.id);
                    }
                }
                if(!userListtoUpdate.isEmpty()) {
                    Core_UserContact_Handler.updateAGSInactiveField(userListtoUpdate);
                }
            }
            
            //Calling PSG related method to share License & Host records for PSG users
            if(leadTriggerExecution == FALSE){ //************ Draco Change [29-10-2021]
                Core_UserHandler.shareLicenseAndHostRecordsForPSG(Trigger.New, Trigger.oldMap);
            }
            
            //Added by Megha(Infosys Team) for the TWC3123-2303 on 24/8/2022
            boolean delegateApproverRoleChangeActive = mapFunctionalityNameTriggerExecution.containsKey('delegateApproverRoleChange') &&
                mapFunctionalityNameTriggerExecution.get('delegateApproverRoleChange').Core_Active__c;
            if(delegateApproverRoleChangeActive){
                Core_DelegateApproverOppShare.opportunityShare(Trigger.oldMap,Trigger.newMap);
            }
            
            //TWC3123-4472 - Deactivate user in QUIP when user deactivate in Salesforce.
            QUIP__c customSetting = QUIP__c.getInstance();
            boolean activeCheck = customSetting != null && customSetting.IsActive__c;
            if(activeCheck == True){
                Core_Quip_UserDeactivation.inactiveUserQuip(trigger.new, trigger.oldMap);
            }
            
            //Calling PCC method to share user records with Integration user
            if(TriggerHandler.isActive('PCC_UserSharing_Switch')) {
                Core_UserHandler.PCC_ShareUserWithM2MUsers(Trigger.New, 'Update', Trigger.oldMap);
            }
        }
    }
}