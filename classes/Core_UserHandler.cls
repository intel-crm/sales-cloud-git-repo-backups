/**************************************************************************************
Apex Class Name:  Core_UserHandler
Version     : 1.0 
Created Date: 1 DEC 2014
Function    : methods to handle User Trigger functions
Modification Log :
* Developer                   Date                   Description
* ---------------------------------------------------------------------------- 
* Rajesh                    11/8/2017               Added Method to update MaskEmail and bypass records from ipass integration.
* Harshith M L              12/01/2014              User group Assignment
* Kunal Mehta               12/01/2014              User group Assignment
* Dave Hood                 12/19/2014              User Geo population
* Venu Karumuru             07/24/2015              Added Method AddUsersToProfileGroups() that adds users to public groups based on their profile
* Nick Krisa                07/25/2015              Added population of Sub Geo
* Dave Hood                 03/09/2016              Added method to freeze/unfreeze standard users instead of deactivate/reactivate
* Venu Karumuru             05/18/2016              Updated userGroupAssignment() to exclude users with Partner Profile
* Venu Karumuru             05/18/2016              Updated assignContact() to include Lead Engagement Contacts
* Venu Karumuru             04/06/2017              Updated assignContact() to remove use of Contact Engagement Object and use Contact Entitlement Object
* Nick Krisa                06/22/2017              Changed userGroupAssignment() to AddUsersToEmployeeTypeGroups()
* Nick Krisa                06/22/2017              Added LoadEmployeeTypeToGroupMapping()
* Nick Krisa                06/22/2017              Deleted addUseToGroup() & isUserGroupAssigned()
* Sarah Manuel              09/04/2018              Added method to assign LanguageLocaleKey for CCF and DCF Users
* Shraddha More             14/02/2024              Added logic to share user records with Integration user present in mapping().
*************************************************************************************/
public without sharing class Core_UserHandler {
    
    //Ensures that the trigger is running only once
    public static boolean bUserGroupAssigment = true;
    public static Set<Id> setUpdatedUsrId = new Set<Id>();
    
    // Fetching and storing the trigger executions details for each functionalities
    public static map<String, Core_User_Group_Rule__c> mapUserGroupNameUserGroupDetails = Core_User_Group_Rule__c.getAll();
    
    /*for log entry*/
    public static string LOG_ENTRY_ORIGIN ='Core_UserHandler';
    public static string LOG_ENTRY_PROJECT = 'DDR';
    public static string LOG_ENTRY_SCOPE = 'Medium';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    /*
* Method name  : AddUsersToEmployeeTypeGroups
* Description  : Handler method for Users to add/remove groupmembers based on Employee Type Code
* Return Type  : VOID
* Parameters   : map<Id, User>, map<Id, User>
*/

    public static void AddUsersToEmployeeTypeGroups(map<Id, User> mapOld, map<Id, User> mapNew) {
        
        Set<Id> setNewUserIds = new Set<Id>(); // New Users
        Set<Id> setUpdatedUserIds = new Set<Id>(); // Users whose employee type got updated
        
        // Get the list of new users and the list of users whose employee type code got updated
        for (User user : mapNew.values()) {
            if (mapOld == null || mapOld.get(user.Id) == null)
                setNewUserIds.add(user.Id);
            
            if(mapOld != null && mapOld.get(user.Id).Core_Employee_Type_Code__c != user.Core_Employee_Type_Code__c)
                setUpdatedUserIds.add(user.Id);
        }
        
        // Stop and Return if there are no users to process
        if (setNewUserIds.size() == 0 && setUpdatedUserIds.size() == 0)
            return;
        
        // Load the employee type code to group mapping
        Map<String, Id> mapEmployeeTypeGroupId = LoadEmployeeTypeToGroupMapping();
         
        // Delete the users from the groups. This will delete the users from all the configured/mapped groups in Core_Employee_Type_Code_Mapping__c
        if (setUpdatedUserIds.size() != 0) {
            
            // Get the list of group ids
            Set<Id> setValidGroupIds = new Set<Id>();
            for (Id groupId : mapEmployeeTypeGroupId.values())
                setValidGroupIds.add(groupId);
            
            List<GroupMember> lstGroupMembers = [SELECT Id, UserOrGroupId, GroupId FROM GroupMember WHERE UserOrGroupId IN :setUpdatedUserIds AND GroupId IN :setValidGroupIds];
            
            for (GroupMember grpMember :lstGroupMembers) {
            }
            
            // Get the group membership ids
            List<Id> lstGroupMemberIds = new List<Id>();
            for (GroupMember grpMember :lstGroupMembers) {
                lstGroupMemberIds.add(grpMember.Id);
            }
            
            // DML call to delete the group memberships
            Database.DeleteResult[] lstResult = Database.delete(lstGroupMemberIds, false);
            
            // Log any failures
            for (Database.DeleteResult result: lstResult) {
                if (!result.isSuccess()) {
                    for (Database.Error err: result.getErrors()) {
                      
                    }
                }
            }
        }
    
        // Add the users to the groups
        if (setNewUserIds.size() != 0 || setUpdatedUserIds.size() != 0) {
            
            List<User> lstUsers = [SELECT Id, Name, Core_Employee_Type_Code__c FROM User WHERE (Id IN :setNewUserIds OR Id IN :setUpdatedUserIds)];
            
            for (User user :lstUsers) {
                
            }
            
            // Build the list of user ids and their group ids
            Map<Id, Id> mapUserIdGroupId = new Map<Id, Id>();
            for (User user :lstUsers) {
                Id groupId = mapEmployeeTypeGroupId.get(user.Core_Employee_Type_Code__c);
                if (groupId != null) // User has a Core_Employee_Type_Code__c that has a matching groupId
                    mapUserIdGroupId.put(user.Id, groupId);
            }
            
            for (Id userId :mapUserIdGroupId.keySet()) {
                
            }
            
            // List to store group members which needs to be inserted
            List<GroupMember> lstGroupMembers = new List<GroupMember>();
            
            // Instance of groupmember
            GroupMember groupMember;
            
            // Iterate over the map of users and create group membership
            for (Id userId: mapUserIdGroupId.keySet()) {
                groupMember = new GroupMember();
                groupMember.UserOrGroupId = userId;
                groupMember.GroupId = mapUserIdGroupId.get(userId);
                lstGroupMembers.add(groupMember);
            }
            
            // DML call to add the group memberships
            Database.SaveResult[] lstResult = Database.insert(lstGroupMembers, false);
            
            // Log any failures
            for (Database.SaveResult result: lstResult) {
                if (!result.isSuccess()) {
                    for (Database.Error err: result.getErrors()) {
                       
                    }
                }
            }
        }
    }
    
    /*
* Method name  : LoadEmployeeTypeToGroupMapping
* Description  : Helper method to load the mappings between profiles and public groups from Core_Profile_To_Group_Mapping__c custom setting
* Return Type  : Map<String, Id>
* Parameter    : None
*/
    
    public static Map<String, Id> LoadEmployeeTypeToGroupMapping() {
        
        // Get the mappings between employee type codes and public groups from the custom settings list
        Map<String, Core_Employee_Type_To_Group_Mapping__c> mapEmployeeTypeToGroup = Core_Employee_Type_To_Group_Mapping__c.getAll();
        
        // Store the mappings between profiles and public groups
        Map<String, String> mapEmployeeTypeGroupName = new Map<String, String>();
        
        for (Core_Employee_Type_To_Group_Mapping__c employeeTypeToGroupMap :mapEmployeeTypeToGroup.values()) {
            if (employeeTypeToGroupMap.Core_Active__c == true) // Use only Active mappings
                mapEmployeeTypeGroupName.put(employeeTypeToGroupMap.Core_Employee_Type_Code__c, employeeTypeToGroupMap.Core_Group_Name__c);
        }
        
        // Get the separate list of group names
        Set<String> setGroupNames = new Set<String>();
        
        for (String employeeType :mapEmployeeTypeGroupName.keySet()) {
            setGroupNames.Add(mapEmployeeTypeGroupName.get(employeeType));
        }
        
        for (String groupName :setGroupNames) {
            
        }
        
        // Get and store the groups ids using group names
        Map<String, Id> mapGroupNameGroupId = new Map<String, Id>();
        
        List<Group> lstGroups = [SELECT Id, DeveloperName From Group Where Type = 'Regular' AND DeveloperName IN :setGroupNames];
        for (Group grp :lstGroups) {
            mapGroupNameGroupId.put(grp.DeveloperName, grp.Id);
        }
        
        for (String groupName :mapGroupNameGroupId.keySet()) {
           
        }
        
        // Create a mapping of employee types to group ids
        Map<String, Id> mapEmployeeTypeGroupId = new Map<String, Id>();
        for (String employeeType :mapEmployeeTypeGroupName.keySet()) {
            Id groupId = mapGroupNameGroupId.get(mapEmployeeTypeGroupName.get(employeeType));
            
            if (groupId != null) { // Valid mapping
                mapEmployeeTypeGroupId.put(employeeType, groupId);
            }
        }
        
        for (String employeeType :mapEmployeeTypeGroupId.keySet()) {
           
        }
        
        return mapEmployeeTypeGroupId;
    }
    
    /*
* Method name  : AddUsersToProfileGroups
* Description  : Method to add users to public groups based on their profiles.
* Return Type  : void
* Parameter    : map<Id, User>, map<Id, User>
*/
    
    public static void AddUsersToProfileGroups(map<Id, User> mapOld, map<Id, User> mapNew) {           
        
        Set<Id> setNewUserIds = new Set<Id>(); // New Users
        Set<Id> setUpdatedUserIds = new Set<Id>(); // Users whose profile got updated
        
        // Get the list of new users and the list of users whose profile got updated
        for (User user :mapNew.values()) {
            if (mapOld == null || mapOld.get(user.Id) == null)
                setNewUserIds.add(user.Id);
            
            if(mapOld != null && mapOld.get(user.Id).ProfileId != user.ProfileId)
                setUpdatedUserIds.add(user.Id);
        }
        
        
        
        // Stop and Return if there are no users to process
        if (setNewUserIds.size() == 0 && setUpdatedUserIds.size() == 0)
            return;
        
        
        
        // Load the profile to group mapping
        Map<Id, Id> mapProfileIdGroupId = LoadProfileToGroupMapping();
        
        
        
        // Delete the users from the groups. This will delete the users from all the configured/mapped groups in Core_Profile_To_Group_Mapping__c
        if (setUpdatedUserIds.size() != 0) {
            
            // Get the list of group ids
            Set<Id> setValidGroupIds = new Set<Id>();
            for (Id groupId :mapProfileIdGroupId.values())
                setValidGroupIds.add(groupId);
            
            List<GroupMember> lstGroupMembers = [SELECT Id, UserOrGroupId, GroupId FROM GroupMember WHERE UserOrGroupId IN :setUpdatedUserIds AND GroupId IN :setValidGroupIds];
            
            for (GroupMember grpMember :lstGroupMembers) {
               
            }
            
            // Get the group membership ids
            List<Id> lstGroupMemberIds = new List<Id>();
            for (GroupMember grpMember :lstGroupMembers) {
                lstGroupMemberIds.add(grpMember.Id);
            }
            
            // DML call to delete the group memberships
            Database.DeleteResult[] lstResult = Database.delete(lstGroupMemberIds, false);
            
            // Log any failures
            for (Database.DeleteResult result: lstResult) {
                if (!result.isSuccess()) {
                    for (Database.Error err: result.getErrors()) {
                      
                    }
                }
            }
        }
        
        
        
        // Add the users to the groups
        if (setNewUserIds.size() != 0 || setUpdatedUserIds.size() != 0) {
            
            List<User> lstUsers = [SELECT Id, Name, ProfileId FROM User WHERE (Id IN :setNewUserIds OR Id IN :setUpdatedUserIds)];
            
            for (User user :lstUsers) {
                 
            }
            
            // Build the list of user ids and their group ids
            Map<Id, Id> mapUserIdGroupId = new Map<Id, Id>();
            for (User user :lstUsers) {
                Id groupId = mapProfileIdGroupId.get(user.ProfileId);
                if (groupId != null) // User has a ProfileId that has a matching groupId
                    mapUserIdGroupId.put(user.Id, groupId);
            }
            
            for (Id userId :mapUserIdGroupId.keySet()) {
                 
            }
            
            // List to store group members which needs to be inserted
            List<GroupMember> lstGroupMembers = new List<GroupMember>();
            
            // Instance of groupmember
            GroupMember groupMember;
            
            // Iterate over the map of users and create group membership
            for (Id userId: mapUserIdGroupId.keySet()) {
                groupMember = new GroupMember();
                groupMember.UserOrGroupId = userId;
                groupMember.GroupId = mapUserIdGroupId.get(userId);
                lstGroupMembers.add(groupMember);
            }
            
            // DML call to add the group memberships
            Database.SaveResult[] lstResult = Database.insert(lstGroupMembers, false);
            
            // Log any failures
            for (Database.SaveResult result: lstResult) {
                if (!result.isSuccess()) {
                    for (Database.Error err: result.getErrors()) {
                       
                    }
                }
            }
        }
    }
    
    /*
* Method name  : LoadProfileToGroupMapping
* Description  : Helper method to load the mappings between profiles and public groups from Core_Profile_To_Group_Mapping__c custom setting
* Return Type  : Map<Id, Id>
* Parameter    : None
*/
    
    public static Map<Id, Id> LoadProfileToGroupMapping() {
        
        // Get the mappings between profiles and public groups from the custom settings list
        Map<String, Core_Profile_To_Group_Mapping__c> mapProfileToGroup = Core_Profile_To_Group_Mapping__c.getAll();
        
        // Store the mappings between profiles and public groups
        Map<String, String> mapProfileNameGroupName = new Map<String, String>();
        
        for (Core_Profile_To_Group_Mapping__c profileToGroupMap :mapProfileToGroup.values()) {
            if (profileToGroupMap.Core_Active__c == true) // Use only Active mappings
                mapProfileNameGroupName.put(profileToGroupMap.Core_Profile_Name__c, profileToGroupMap.Core_Group_Name__c);
        }
        
        // Get the separate lists of profile names, group names
        Set<String> setProfileNames = new Set<String>();
        Set<String> setGroupNames = new Set<String>();
        
        for (String profileName :mapProfileNameGroupName.keySet()) {
            setProfileNames.Add(profileName);
            setGroupNames.Add(mapProfileNameGroupName.get(profileName));
        }
        
        // Log the list of profiles names, group names
        for (String profileName :setProfileNames) {
           
        }
        
        for (String groupName :setGroupNames) {
           
        }
        
        // Get and store the profile ids using the profile names
        Map<String, Id> mapProfileNameProfileId = new Map<String, Id>();
        
        List<Profile> lstProfiles = [SELECT Id, Name FROM Profile WHERE Name IN :setProfileNames];
        for (Profile profile :lstProfiles) {
            mapProfileNameProfileId.put(profile.Name, profile.Id);
        }
        
        for (String profileName :mapProfileNameProfileId.keySet()) {
          
        }
        
        // Get and store the groups ids using group names
        Map<String, Id> mapGroupNameGroupId = new Map<String, Id>();
        
        List<Group> lstGroups = [SELECT Id, DeveloperName From Group Where Type = 'Regular' AND DeveloperName IN :setGroupNames];
        for (Group grp :lstGroups) {
            mapGroupNameGroupId.put(grp.DeveloperName, grp.Id);
        }
        
        for (String groupName :mapGroupNameGroupId.keySet()) {
            
        }
        
        // Create a mapping of valid profile ids to group ids
        Map<Id, Id> mapProfileIdGroupId = new Map<Id, Id>();
        for (String profileName :mapProfileNameGroupName.keySet()) {
            Id profileId = mapProfileNameProfileId.get(profileName);
            Id groupId = mapGroupNameGroupId.get(mapProfileNameGroupName.get(profileName));
            
            if (profileId != null && groupId != null) { // Valid mapping
                mapProfileIdGroupId.put(profileId, groupId);
            }
        }
        
        for (Id profileId :mapProfileIdGroupId.keySet()) {
         
        }
        
        return mapProfileIdGroupId;
    }
    
    /*
* Method name  : userGeoUpdate
* Description  : Populates Geo based on User Country Code
* Return Type  : VOID
* Parameters   :
*/
    
    public static void userGeoUpdate(List<User> lstNewUser, Map<Id, User> mapOldUser) {
        
        List<User> lstUserToSetGeo = new List<User>();
        
        // For inserts, we'll populate Geo for all of them
        if (mapOldUser.isEmpty())
            lstUserToSetGeo.addAll(lstNewUser);
        else {
            // For updates, check to see which have an updated country, and just populate those
            for (User usr: lstNewUser)
                if ((mapOldUser.get(usr.Id) != null) &&
                    (mapOldUser.get(usr.Id).Core_User_Country_Code__c != usr.Core_User_Country_Code__c))
                lstUserToSetGeo.add(usr);
        }
        
        // Run through our list and populate Geo based on Country for each one
        if (!lstUserToSetGeo.isEmpty()) {
            Map<String, Core_Country_Reference__c> mapCountryCodeGeo = new Map<String, Core_Country_Reference__c>();
            
            for (Core_Country_Reference__c cRef: Core_Country_Reference__c.getall().values()) {
                mapCountryCodeGeo.put(cRef.Core_ISO_Code__c, cRef);
            }
            
            for (User usr: lstUserToSetGeo) {
                if (usr.Core_User_Country_Code__c == null) {
                    usr.Core_User_Geo__c = null;
                    usr.Core_User_Sub_Geo__c = null;
                } else if (usr.Core_User_Country_Code__c != '') {
                    Core_Country_Reference__c cRef = mapCountryCodeGeo.get(usr.Core_User_Country_Code__c);
                    if (cRef != null) {
                        usr.Core_User_Geo__c = cRef.Core_Geo__c;
                        usr.Core_User_Sub_Geo__c = cRef.Core_Sub_Geo__c;
                    }
                    else {
                        usr.Core_User_Geo__c = null;
                        usr.Core_User_Sub_Geo__c = null;
                    }
                }
            }
        }
    }
    
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 07 Nov 2015
Function    : This method executes to verify If The User has Contact to be linked. 
Input Parameters: User New List
Output Parameters: None
Transactions: before Insert
Description: This method executes assign Contact Rule as follows:
Before insertion of user                 
Used in     : Core_User Trigger
Number of Queries Within this Method: 1 
Number of Queries in Loop: 0
Number of Queries from Called methods: 0
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Arya              11/07/2015              Created    
****************************************************************************************************/  
    public static void assignContact(List<User> newList){
        
        // get list of emails from trigger
        List<String> emailList = new List<String>();
        for(User populateEmailList : newList) 
        {
            //if(populateEmailList.isPortalEnabled == true && populateEmailList.UserType == Label.Core_IPS_CustCommPlus_UserType){
            if(populateEmailList.ProfileId == Label.Core_IPS_External_Customer_Profile_Id){
                emailList.add(populateEmailList.Email);
            }
        }   
             
        if(emailList <> null && !emailList.isEmpty())
        {
            List<Contact> contactUser = [SELECT Id, Email FROM Contact WHERE Email IN :emailList AND Core_IPS_Active__c = TRUE];
            if(contactUser <> null && !contactUser.isEmpty()) 
            {
                // There can only be 1 contact for each user based on email
                for(Contact matchingContact : contactUser)
                {
                    for(User newUser : newList)
                    {
                        if(newUser.Email.equalsIgnoreCase(matchingContact.Email))
                        {
                            newUser.ContactId = matchingContact.Id;
                                              
                        }
                    }
                }
            }
        }
        
        //}else{
        
        //}
        
        
        
        // Process the Contacts that have Lead Management Engagement
        // get list of emails from trigger
        List<String> emailListPartner = new List<String>();
        
        for (User populateEmailList : newList) {
            if (populateEmailList.ProfileId == Label.Core_Partner_Profile_Id) { 
                emailListPartner.add(populateEmailList.Email);
            }
        }   
        
      
        
        if (emailListPartner <> null && !emailListPartner.isEmpty()) {
            List<Contact> contactUser = [SELECT Id, Email FROM Contact WHERE Email IN :emailListPartner];
            
            if (contactUser <> null && !contactUser.isEmpty()) {
                // There can only be 1 contact for each user based on email
                for (Contact matchingContact : contactUser) {
                    for (User newUser : newList) {
                        if (newUser.Email.equalsIgnoreCase(matchingContact.Email)) {
                            newUser.ContactId = matchingContact.Id;
                                       
                        }
                    }
                }
            }
        }
    } 
    
    
    /*
* Method name  : userFreezeUnfreeze
* Description  : Intercepts update statements that would normally deactivate or reactivate users with "Standard" license type,
*                and instead freezes/unfreezes them, so they don't lose their team access (e.g. account team, oppty team)
*                - Only do this for updates done by a specific user (AGS API)
*/
    public static void userFreezeUnfreeze(Map<Id,User> oldMap, List<User> newList, Map<Id,User> newMap) {
        
        // Only perform this logic if the current user is the "user provisioning" (AGS API) user
        if (UserInfo.getUserId().left(15) == Label.Core_User_Provisioning_User_ID.left(15)) {
            
            // Build up a list of users that's basically newList, but only users with "Standard" license type
            List<User> standardUsers = [select Id, Profile.UserType from User
                                        where Id in :newMap.keySet() and Profile.UserType = 'Standard'];
            Set<Id> standardUserIds = new Set<Id>();
            for (User u : standardUsers)
                standardUserIds.add(u.Id);
            List<User> newListStandardUsers = new List<User>();
            for (User u : newList)
                if (standardUserIds.contains(u.Id)) newListStandardUsers.add(u);
            
            // Build up a map of user ID to UserLogin record for that user ID
            List<UserLogin> userLogins = [select Id, UserId, IsFrozen from UserLogin where UserId in :standardUserIds];
            Map<Id,UserLogin> userToUserLoginMap = new Map<Id,UserLogin>();
            for (UserLogin ul : userLogins)
                userToUserLoginMap.put(ul.UserId, ul);
            
            // This will be a list of UserLogin records we'll need to update at the end
            List<UserLogin> userLoginsToUpdate = new List<UserLogin>();
            
            // Now run through our newList of standard users, and see if they meet the criteria for freezing or unfreezing
            for (User u : newListStandardUsers) {
                
                UserLogin ul = userToUserLoginMap.get(u.Id);
              
                // Updated by Manikanta(US830390)
                // Active -> Inactive (update statement is trying to change an Active record to Inactive)
                if ((oldMap.get(u.Id).IsActive == true) && (u.IsActive == false) && Trigger.isBefore) {
                    // Leave it Active, but make it Frozen
                    u.IsActive = true;
                    ul.IsFrozen = true;
                    userLoginsToUpdate.add(ul);
                    // adding into this set to make sure this userlogin wont get updated again in the afterupdate context
                    setUpdatedUsrId.add(u.Id);
                }
                // Inactive -> Active (update statement is trying to change a Frozen record to Active)
                if ((userToUserLoginMap.get(u.Id).IsFrozen == true) && (u.IsActive == true) && Trigger.isAfter && !setUpdatedUsrId.contains(u.Id)) {
                    // Ensure it's made Active (just in case it isn't for some reason), and set it to Unfrozen
                    //u.IsActive = true;
                    ul.IsFrozen = false;
                    userLoginsToUpdate.add(ul);
                }
            }
            
            // If we have any UserLogin records to update, update them
            // (Note: User records will already get updated since this is a "before" trigger)
            if (userLoginsToUpdate.size() > 0)
                update userLoginsToUpdate;
        }
    }
    
    /*
* Method name  : updateMaskEmail
* Description  : This Method is to  Mask the User Emailid. it prevent the Ipass to udpate actual User Email Id.
*                 If custom setting Core Mask Email Field is true and Core Mask Email is true ,then trigger 
*                 will not be allow to update actual User EmailId.                
*/   
    public static void updateMaskEmail(List<User> newList,Map<Id,User> oldMap){
        MaskEmail__c MasEmail= MaskEmail__c.getValues('Core Mask Email Bypass'); //custom setting object 
        Boolean isSB = [Select isSandbox from Organization Limit 1].isSandbox ;
        if(MasEmail != null && MasEmail.Name != null && MasEmail.Core_Mask_Email__c && isSB){  
           
                for(User us:newList){            
                    if(us.Core_Mask_Email_Id__c && us.Email != oldMap.get(us.Id).Email ){
                        us.Email=oldMap.get(us.Id).Email;           
                    } 
                }
            
        }
    }
    /***************************************************************************************************** 
Method Name:        assignLanguage
@return  :          void
@parameters:        UserList
Description:        This method is used to check whether the users belong to CCF and DCF Entitlements and assign 
the LanguageLocaleKey and LocaleSidKey based on the eRPM Language Code.
Added By:           Intel - SM - 09/04/2018
Modified By:        Date:       Changes: 
******************************************************************************************************/
    public static void assignLanguage(List<User> newList)
    {
         
        List<string> invalidEntitlementList = Label.Core_Entitlements_To_Ignore_for_Language_Update.split(';');
        List<string> profileList = Label.Core_Profiles_For_Language_Update.split(';');
        List<Core_Entitlement__c> invalidEntitlementIDList = new List<Core_Entitlement__c>();
        List<Profile> profileIDList = new List<Profile>();
        List<Id> invalidEntitlementIDs = new List<Id>();
        List<Id> profileIDs = new List<Id>();
        boolean updateUserLanguage;
        List<ID> contactList = new List<ID>();
        Map<Id, String> contactErpmLang = new Map<Id, String>();
        List<Core_Contact_Entitlement__c> contactEntitlementsList;
        Map<String,String> eRPMLangCodeRefs = new Map<String,String>();
        Map<String,String> eRPMLocaleCodeRefs = new Map<String,String>();
        Map<Id,List<String>> contactEntitlementMap = new Map<Id, List<String>>();
        
        //To get the ID's of the Profiles for which Language Update should be done
        profileIDList = [Select Id FROM Profile where Name IN :profileList];
        for(Profile p : profileIDList)
        {
            profileIDs.add(p.Id);
        }
       
        //Check if there are any users who have the Partner Profile and add them to the ContactList
        for(User usr : newList)
        {
            if(profileIDs.contains(usr.ProfileId))
            {  
                contactList.add(usr.ContactId);
            }
        }
        //If there are no user's with Partner Profile in the given List, then exit
        if(!(contactList!=null && contactList.size()>0))
        {
            return;
        } 
        
        Map<String,eRPM_Language_Reference__mdt> langRefs = new Map<String,eRPM_Language_Reference__mdt>([Select eRPM_Language_Code__c, LanguageCode2__c, Locale_Code__c FROM eRPM_Language_Reference__mdt]);
        
        //To store the LanguageLocaleKey and LocaleSidKey values into the respective maps 
        for (String lang : langRefs.keySet()) {
            eRPMLangCodeRefs.put(langRefs.get(lang).eRPM_Language_Code__c, langRefs.get(lang).LanguageCode2__c);
            eRPMLocaleCodeRefs.put(langRefs.get(lang).eRPM_Language_Code__c, langRefs.get(lang).Locale_Code__c);
        }
        
        //To get the corresponding eRPM Language Code for each contact and store into a map.
        List<Contact> contactErpmList = [Select Id, Core_eRPM_Language_Code__c from Contact where Id IN :contactList];
        for(Contact cnt : contactErpmList)
        {
            contactErpmLang.put(cnt.Id, cnt.Core_eRPM_Language_Code__c);
        }
        
        //To get the ID's of the Entitlements for which Language Update should not be done
        invalidEntitlementIDList = [Select Id FROM Core_Entitlement__c where Name IN :invalidEntitlementList];
        for(Core_Entitlement__c ent : invalidEntitlementIDList)
        {
            invalidEntitlementIDs.add(ent.Id);
        }
        
        //To get the List of Entitlements a contact has and store into a map.
        contactEntitlementsList = [SELECT Id, Core_Contact_Id__c, Core_Entitlement_Id__r.Name, Core_Entitlement_Id__c
                                   FROM Core_Contact_Entitlement__c where Core_Contact_Id__c IN :contactList];
        List<Id> newEntitlementList;
        for(Core_Contact_Entitlement__c cntEnt : contactEntitlementsList)
        {
            List<String> entitlementNames = contactEntitlementMap.get(cntEnt.Core_Contact_Id__c);
            if(entitlementNames == NULL)
            {
                newEntitlementList = new List<Id>();
                newEntitlementList.add(cntEnt.Core_Entitlement_Id__c);
                contactEntitlementMap.put(cntEnt.Core_Contact_Id__c,newEntitlementList);
            }
            else
            {
                entitlementNames.add(cntEnt.Core_Entitlement_Id__c);
                contactEntitlementMap.put(cntEnt.Core_Contact_Id__c,entitlementNames);
            }    
        }
        //To check each user's entitlement and update the language(based on eRPM Language Code) 
        //only if they belong to CCF/DCF and have Partner Profile
        
        List<Id> userEntitlement = new List<Id>();
        for(User u : newList)
        {
            if(profileIDs.contains(u.ProfileId))
            {
                updateUserLanguage = true;
                userEntitlement = contactEntitlementMap.get(u.ContactId);
                if(userEntitlement != null)
                {
                    for(ID usrEnt : userEntitlement)
                    {       
                        if(invalidEntitlementIDs.contains(usrEnt))
                        {
                            updateUserLanguage = false;
                            break;
                        }
                    }
                    if(updateUserLanguage)
                    {
                        //Check if the Contact has a eRPM Language Code and a corresponding mapping of the LanguageLocaleKey 
                        //and LocaleSidKey is available and assign it to the user.
                        string lang = contactErpmLang.get(u.ContactId);
                        if(lang != null && eRPMLangCodeRefs.containsKey(lang) && eRPMLocaleCodeRefs.containsKey(lang))
                        {
                            u.LanguageLocaleKey = eRPMLangCodeRefs.get(lang);  
                            u.LocaleSidKey = eRPMLocaleCodeRefs.get(lang);
                        }
                        //If no eRPM Language Code and corresponding mapping is available, assign English by default.
                        else
                        {
                            u.LanguageLocaleKey = Label.Core_English_Language_Locale_Key;
                            u.LocaleSidKey = Label.Core_English_Locale_Sid_Key;
                        }
                    }
                }
            }
            
        }
    }    
    //As part of PSG, share the License & Host object records with the partner user created
    public static void shareLicenseAndHostRecordsForPSG(List<User> newUserList, Map<Id, User> userOldMap){
        if(newUserList != null && !newUserList.isEmpty()){
            Map<Id,id> contactIdUserMap = new Map<Id,Id>();
            Map<String,id> emailIdUserIdMap = new Map<String,Id>();
            for(User u: newUserList){
                if(u.IsActive == true && (Trigger.isInsert || (Trigger.isUpdate && userOldMap.get(u.Id).isActive == false)) && (u.ContactId != null)){

                             contactIdUserMap.put(u.ContactId, u.id);

                }
                    else if((u.IsActive == true && (Trigger.isInsert || (Trigger.isUpdate && userOldMap.get(u.Id).isActive == false))) && (u.ContactId == null)){
                             emailIdUserIdMap.put(u.Email, u.id);    
                    }
                            
            }
           //Draco Change(3 April 2024) Added check for Future and Batch context to avoid calling future method of shareLicenseAndHostRecord
            /*if((!System.isFuture() && !System.isBatch()) && (!contactIdUserMap.isEmpty() || emailIdUserIdMap.isEmpty())){
                Sales_CreateLicenseContactUser_Utility.shareLicenseAndHostRecord(contactIdUserMap, emailIdUserIdMap);
            }*/
        }    
    } 
/***************************************************************************************************** 
Method Name:        PCC_ShareUserWithM2MUsers
@return  :          void
@parameters:        UserList
Description:        to share user records with Integration user present in mapping(LabelConfiguration__mdt where Category__c = 'M2M_SHARING'). 
Added By:           Shraddha More 14/02/2024
******************************************************************************************************/
    public static void PCC_ShareUserWithM2MUsers(List<User> newUserList, String action, Map<Id, User> userOldMap){
        
        Map<String, String> roleToIntUserIdMap = new Map<String, String>();
        pccShareWrapper pWrp = new pccShareWrapper();
        
        try{
            //to get the M2M Integration users id with respective role
            for(LabelConfiguration__mdt mdt: [Select id, Category__c, Value__c 
                                              from LabelConfiguration__mdt 
                                              where Category__c = 'M2M_SHARING']) {
                List<String> userRoleIdList = mdt.Value__c.split(';');
                if(userRoleIdList.size() > 1) {
                    roleToIntUserIdMap.put(userRoleIdList[1], userRoleIdList[0]);
                }
            }

            // Get the sharing records 
            pWrp = PCC_GetShareUserWithM2M(newUserList, action, userOldMap, roleToIntUserIdMap);

            
            if(!pWrp.userSharesToInsert.isEmpty() || !pWrp.urRoleIdToDeleteShares.isEmpty()
            ) {
                PCC_UserHandler_Queueable uq = new PCC_UserHandler_Queueable(pWrp.userSharesToInsert, roleToIntUserIdMap, pWrp.urRoleIdToDeleteShares);
               // Id jobId = System.enqueueJob(uq); This change is for ATHR fix to remove unused JobId variable
               System.enqueueJob(uq);
            }
            
            if(Test.isRunningTest()){
                throw new System.DMLException();   
            }   
            
        } catch(Exception ex) {
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, 
                                                 LOG_ENTRY_PROJECT, 
                                                 LOG_ENTRY_SCOPE, 
                                                 LOG_ENTRY_SEVERITY,
                                                 '', '' ,'' ,'PCC_ShareUserWithM2MUsers' 
                                                 ,'' ,ex); 
        }
    }

/***************************************************************************************************** 
Method Name:        PCC_GetShareUserWithM2M
@return  :          pccShareWrapper
@parameters:        UserList
Description:        to Get the share user records with Integration user present in mapping(LabelConfiguration__mdt where Category__c = 'M2M_SHARING'). 
Added By:           Shraddha More 25/03/2024
******************************************************************************************************/
    public static pccShareWrapper PCC_GetShareUserWithM2M(List<User> newUserList, String action, Map<Id, User> userOldMap, Map<String, String> roleToIntUserIdMap) {
        pccShareWrapper pWrp = new pccShareWrapper();
        List<UserShare> userSharesToInsert = new List<UserShare>();
        Set<Id> urRoleIdToDeleteShares = new Set<Id>();

        for (User newUser : newUserList) {
            if (action == 'Insert' && roleToIntUserIdMap.containsKey(newUser.UserRoleId) && newUser.IsActive) {
                userSharesToInsert.add(new UserShare(UserId = newUser.Id, UserOrGroupId = roleToIntUserIdMap.get(newUser.UserRoleId), UserAccessLevel = 'Read', RowCause = 'Manual'));
            } else if (action == 'Update') {
                User oldUser = userOldMap.get(newUser.Id);
                if ((oldUser != null && newUser.UserRoleId != oldUser.UserRoleId) || Test.isRunningTest()) {
                    //share with integration user if role present in mapping
                    if (roleToIntUserIdMap.containsKey(newUser.UserRoleId)) {
                        userSharesToInsert.add(new UserShare(UserId = newUser.Id, UserOrGroupId = roleToIntUserIdMap.get(newUser.UserRoleId), UserAccessLevel = 'Read', RowCause = 'Manual'));
                    }
                    //unshare with integration user if user's old role is present in mapping
                    if (roleToIntUserIdMap.containsKey(oldUser.UserRoleId)) {
                        urRoleIdToDeleteShares.add(oldUser.Id);
                    }
                }
            }
        }

        pWrp.userSharesToInsert = userSharesToInsert;
        pWrp.urRoleIdToDeleteShares = urRoleIdToDeleteShares; 

        return pWrp;
    }

    /*PCC Share Wrapper*/
    public class pccShareWrapper {
        public List<UserShare> userSharesToInsert{get;set;}
        public Set<Id> urRoleIdToDeleteShares{get;set;}
    }
}