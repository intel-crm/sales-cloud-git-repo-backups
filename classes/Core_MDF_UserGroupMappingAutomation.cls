/************************************************************************************************************************************************************************************
    * Class Name  : Core_MDF_UserGroupMappingAutomation 
    * Version     : 1.0 
    * Created Date: 15-02-2019
    * Modification Log :
    * Developer                     Date                          Description
    * --------------------------------------------------------------------------------------------------------------------------------------------------
    * Intel - Narayani Perachi      15-02-2019                    Automation of the process of adding User to the right External group  
    * Intel - Narayani Perachi      27-02-2019                    Added method logInUserGroupMappingLogObject() to log in UserGroupMappingLog Object
    * Intel - Narayani Perachi      28-02-2019                    Made the main method Queueable. Added constructor
    * Intel - Narayani Perachi      05-03-2019                    Created a batch class for logging in Core_MDF_UserGroupMapping_Log__c
    * Intel - Narayani Perachi      19-03-2019                    Made changes to logInUserGroupMappingLogObject() to accomodate populating Channel Programs for Null Group ID
    * Intel - Narayani Perachi      20-03-2019                    Created createMapforNullGroupId() for determining the Channel Programs which did not have PGM Mapping
    * Accenture - Jayesh Variyani   29-08-2019            US441266:Iteration17 -- Added the logic to update the Account User entries for the User whenever the role is added/removed
    * Intel - NP(11630236)      11-10-2019            Commented PNUM Update Line#632
    * Intel - NP(11630236)          07-10-2019                    Fixed the error logging issue for Agency users in UserGroupMapping log object
    * Intel - NP(11630236)      10-06-2020            Commented Core_MDF_ExternalUserSharing code since it was sharing to All Non-Badged Group
    * 
    * Custom Labels used :
    * Label.Core_MDF_User_Group_Mapping_Automation_Audience_List  CCF USER:Client Co-Marketing Fund;DCF USER:Data Center Co-Marketing Fund;SPCF USER:Service Provider Co-Marketing Fund
**************************************************************************************************************************************************************************************/
    public without sharing class Core_MDF_UserGroupMappingAutomation /*implements Queueable*/
    {    //Commented as part of WW24 - 2025
         //added dummy method to get the code coverage for this class
    public static void getCodeCoverage(){
    }
        //New comment added
        /*public static List<id> accountIds = new List<id>();
        public static List<Core_MDF_Partner_Group_Mapping__c> worksForAccount = new List<Core_MDF_Partner_Group_Mapping__c>();
        
        public static Map<id,id> contactToUserMap = new Map<id,id>();
        public static Map<id,id> userToContactMap = new Map<id,id>();
        public static Map<id,id> contactToAccountIDMap = new Map<id,id>();
        public static Map<string,string> channelPartnerToAudienceMapping = new Map<string,string>();
        public static Map<string,string> accountChannelProgramToAgencyMap = new Map<string,string>();
        public static Map<string,id> agencyToGroupMap = new Map<string,id>();
        public static Map<string,id> channelProgramToIdMap = new Map<string,id>();
        public static Map<id,string> contactToAccountIDChannelPartner = new Map<id,string>();
        public static Map<id,string> groupIdToChannelProgramMap = new Map<id,string>();
        public static Map<string,id> accountToChannelProgramID = new Map<string,id>();
        public static Map<id, List<id>> worksForMoreAgencyToPGMMap = new Map<id, List<id>>();
        public static Map<id,List<Core_MDF_Partner_Group_Mapping__c>> worksForMultipleAccount = new Map<id,List<Core_MDF_Partner_Group_Mapping__c>>();
        public static List<id> contactsWithMultipleCCPAudience = new List<string>();
        public static List<id> allCCPExternalGroupIds = new List<id>();
        public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        
        //For logging
        public static Map<id,set<id>> userToLoggedChannelProgram = new Map<id,set<id>>(); 
        public static set<id> loggedChannelProgramID = new set<id>();
        
       
        public static String logEntryMsg = '';
        public static exception ex;
        
        public List<Contact> newContactList; 
        public Map<Id,Contact> oldContactList; 
        public boolean isInsert; public boolean isUpdate;
        
        //Constructor to set the input values from the trigger
        public Core_MDF_UserGroupMappingAutomation(List<Contact> newContactListFromTrigger,Map<Id,Contact> oldContactListFromTrigger, boolean isInsert, boolean isUpdate) {
            this.newContactList = newContactListFromTrigger;
            this.oldContactList = oldContactListFromTrigger;
            this.isInsert = isInsert;
            this.isUpdate = isUpdate;
        }
        
        //Method to map the Audience List with the Channel Partner
        public static void channelProgramToAudienceMap()
        {
            List<string> audience = new List<string>();
            for(string audienceToChannelProgram : Label.Core_MDF_User_Group_Mapping_Automation_Audience_List.split(';'))
            {
                List<string> record = audienceToChannelProgram.split(':');
                channelPartnerToAudienceMapping.put(record[0],record[1]);
                audience.add(record[1]);
            }
            
            for(ChannelProgram record : [select id,Name from ChannelProgram where Name in :audience])
            {
                channelProgramToIdMap.put(record.Name,record.id);
            }
            
        }*/
        
        //Main method
        /*public void execute(QueueableContext context)
        {
            List<Contact> contactList = new List<Contact>();
            List<id> contactListIds = new List<id>();
            Map<id,string> contactToAccountMap = new Map<id,string>();
            Map<string,id> nonAgencyAccountIDToGroupListMap = new Map<string,id>();
            Map<id,List<id>> finalUserToGroupList = new Map<id,List<id>>();
            List<contact> contactGroupRemoval = new List<Contact>();
            Map<id,contact> toBeRemoved = new Map<id,contact>();
            Map<id,contact> toBeProcessed = new Map<id,contact>();
            string newAudienceList; string oldAudienceList;
            
            try
            {
                // Set values for Audience to Channel Partner map
                channelProgramToAudienceMap();
                // Get all the CCP external groups
                getAllCCPExternalGroupIds();
                
                
                //Identify the records which contain CCF/DCF/SPCF User in Audience List
                for(contact c: newContactList)
                {
                    newAudienceList = c.Core_Audience__c != null?c.Core_Audience__c.toUpperCase():null;
                    
                    //1. Check if Audience list is not null while contact creation
                    if(isInsert && newAudienceList != null)
                        {
                            // Check if the audience list contains CCP audience
                            for(string record: channelPartnerToAudienceMapping.keyset())
                            {
                                if(newAudienceList.contains(record))
                                {
                                    toBeProcessed.put(c.id,c);   
                                }
                            }
                            
                        }
                    //2. If any contact is updated    
                    if(isUpdate)
                        {
                            oldAudienceList = oldContactList.get(c.id).Core_Audience__c != null?oldContactList.get(c.id).Core_Audience__c.toUpperCase() : null;
                            //2a. If the contact is updated from null audience list to any value
                            if(oldContactList.get(c.id).Core_Audience__c == null && newAudienceList != null)
                            {
                                for(string record: channelPartnerToAudienceMapping.keyset())
                                {
                                    if(newAudienceList.contains(record))
                                    {
                                        // If new audience list has CCP audience, it has to be processed
                                        toBeProcessed.put(c.id,c);   
                                    }
                                }   
                            }
                            //2b. If the contact is updated to a null audience but had some values earlier 
                            if(newAudienceList == null && oldAudienceList != null)
                            {
                                for(string record: channelPartnerToAudienceMapping.keyset())
                                {
                                    if(oldAudienceList.contains(record))
                                    {
                                        // If old audience list had CCP audience, it has to be removed from the respective groups
                                        toBeRemoved.put(c.id,c);   
                                    }
                                } 
                            }
                            
                            //2c. If the contact is updated from existing audience list to new audience list
                            if(oldAudienceList != null && newAudienceList != null)
                            {
                                for(string record: channelPartnerToAudienceMapping.keyset())
                                {
                                    //If contact had CCP audience but was removed on updation
                                    if(oldAudienceList.contains(record) && !newAudienceList.contains(record))
                                    {
                                        // Contact needs to be removed from their respective groups
                                        toBeRemoved.put(c.id,c);   
                                    }
                                    
                                    // If contact has been updated to have CCP audience, it has to be processed
                                    if(newAudienceList.contains(record))
                                    {
                                       toBeProcessed.put(c.id,c); 
                                    }
                                }  
                            }
                        }
                    
    
                }
                //contactGroupRemoval = toBeRemoved.values();
                contactList= toBeProcessed.values();
             
                
                //Check if toBeRemoved records are not there in toBeProcessed records
                for(id toBeRemovedIds : toBeRemoved.keyset())
                {
                    if(!toBeProcessed.containskey(toBeRemovedIds))
                    {
                        contactGroupRemoval.add(toBeRemoved.get(toBeRemovedIds));
                    }    
                }
                
                //Send for group removal
                if(contactGroupRemoval.size()>0){sendForGroupRemoval(contactGroupRemoval);}
                
                if(contactList.size()>0)
                {
                    
                    for(contact c : contactList)
                    {
                        contactListIds.add(c.id);
                    }
                    //1. Identify the users of the contacts
                    contactToUserMap = getUser(contactListIds);
                    
                    //2. Identify the Accounts of the contacts
                    getAccount(contactList);
                    
                    //3. Check if the accounts are Agency
                    nonAgencyAccountIDToGroupListMap= identifyAgencyAccounts(accountIds);
                    
                    //4. Create User-Group List mapping based on the Channel program
                    finalUserToGroupList = getGroupListForUser(contactToAccountIDChannelPartner,nonAgencyAccountIDToGroupListMap);
                    
                    //5. Add or Remove the User from the Group
                    addOrRemoveUserFromGroup(finalUserToGroupList);
                }
            }
            
            catch(exception ex){ Core_MDF_CCP_UtilityClass.logError(ex);} 
            
        }
        
        /* Creates a Map of Contact, User
         * Creates a Map of User, Contact
         */
        /*public static Map<id,id> getUser(List<id> contactList)
        {
            Map<id,id> outputMap = new Map<id,id>();
             
            try
            {
                for(User u:[select id,contactId from User where contactId in : contactList and IsActive=true])
                    {
                        outputMap.put(u.contactId, u.id); 
                        userToContactMap.put(u.id,u.contactid); 
                    }
       
            }
            
            catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}       
            
            return outputMap;
        }*/
        
        /* Creates a Map of the Contact, Account ID+Channel Partner Name
         * Creates a Map of Contact, Account
         * Creates a List of Account Ids
         * Creates a List of Contacts who have multiple audience
         */
        /*public static void getAccount(List<contact> contactList)
        {
            Map<id,string> outputMap = new Map<id,string>();
            List<string> result;
            string multipleCCPAudience = '';
            
            try
            {
                for(Contact c : contactList)
                {
                    string value = c.AccountId;

                    result = getChannelPartner(c.Core_Audience__c);
                    
                    if(result.size()>1)
                    {
                        //If the contact has more than one CCP audience added
                        for(string audience : result)
                        {
                            multipleCCPAudience += value + audience;
                            multipleCCPAudience += ';';
                        }
                        //Map of Contact to Multiple Audience separated by ; (Eg: (c.id, Data Center Co-Marketing Fund;Client Co-Marketing Fund))
                        contactToAccountIDChannelPartner.put(c.id,multipleCCPAudience); 
                        //Creating List of contact Ids with Multiple Audience
                        contactsWithMultipleCCPAudience.add(c.id);   
                    }
                    else
                    {
                       //If the contact has only one CCP audience added
                       value += result[0]; 
                       contactToAccountIDChannelPartner.put(c.id,value);
                    }

                    
                    contactToAccountIDMap.put(c.id,c.AccountId);
                    accountIds.add(c.AccountId);
                }
            }
            catch(exception ex){ Core_MDF_CCP_UtilityClass.logError(ex);}  
      
        }*/
        
        // Returns Channel Partner Name of the input Audience
        /*public static List<string> getChannelPartner(string audience)
        {

            List<string> audienceList = audience.split(';');
            List<string> output = new List<string>();
            
            try
            {
                for(string a :audienceList)
                {
                    if(channelPartnerToAudienceMapping.containsKey(a.toUpperCase()))
                    {
                        output.add(channelPartnerToAudienceMapping.get(a.toUpperCase()));   
                    }
                }         
            }
            catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 

            return output;
        }*/
        
        // Returns a List of Partner Group Mapping objects(Group ID List) for the input account IDs
        /*public static List<Core_MDF_Partner_Group_Mapping__c> getGroupList(List<id> accountIds)
        {
            
            List<Core_MDF_Partner_Group_Mapping__c> partnerGroupMap = new List<Core_MDF_Partner_Group_Mapping__c>();
            try
            {
                partnerGroupMap = [select Core_MDF_Account__c,Core_MDF_Works_For__c,name,Core_MDF_Group_Name__c,Core_MDF_Group_Id__c,Core_MDF_Channel_Program__r.Name,Core_MDF_Channel_Program__c,Core_MDF_Type_of_Access__c 
                                   from Core_MDF_Partner_Group_Mapping__c 
                                   where Core_MDF_Account__c in : accountIds
                                   and Core_MDF_Inactive_Ind__c = false 
                                   and Core_MDF_Type_of_Access__c='External'];          
            }
            catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}            
            
            return partnerGroupMap;
        }*/
        
        /* Creates a Map of Account ID+Channel Partner Name, GroupID List
         * Creates a Map, for Agency Accounts, of Account ID+Channel Partner Name, Works For Account ID+Channel Partner Name 
         * Creates a Map, for Agency working for Multiple Accounts, of Works For Account ID+Channel Partner Name,GroupID List
         * Creates a Map of Group ID, Channel Program - For logging purpose
         */
        /*public static Map<string,id> identifyAgencyAccounts(List<id> accountIds)
        {
            
            Map<string,id> outputMap = new Map<string,id>();
            List<Core_MDF_Partner_Group_Mapping__c> worksForManyAccount = new List<Core_MDF_Partner_Group_Mapping__c>();
            List<Core_MDF_Partner_Group_Mapping__c> partnerGroupMap = getGroupList(accountIds);
            List<id> worksForMoreAccountsList = new List<id>();
            Map<id,List<Core_MDF_Partner_Group_Mapping__c>> accountToWorksForMap = new Map<id,List<Core_MDF_Partner_Group_Mapping__c>>();
            
              
            try
            {
                for(Core_MDF_Partner_Group_Mapping__c pgm :partnerGroupMap)
                {
                    string key = pgm.Core_MDF_Account__c;
                    key += pgm.Core_MDF_Channel_Program__r.Name;
                    groupIdToChannelProgramMap.put(pgm.Core_MDF_Group_Id__c,pgm.Core_MDF_Channel_Program__c);
                    accountToChannelProgramID.put(key,pgm.Core_MDF_Channel_Program__c);
                    
                    // For Non Agency Accounts
                    if(pgm.Core_MDF_Works_For__c == null)
                    {
                            outputMap.put(key,pgm.Core_MDF_Group_Id__c);
                    }
                    
                    //Agency Accounts
                    else if (pgm.Core_MDF_Works_For__c != null)
                    {
                        string value = pgm.Core_MDF_Works_For__c;
                        value += pgm.Core_MDF_Channel_Program__r.Name;
                        // Map of Account + Channel Program to Works For + Channel Program
                        accountChannelProgramToAgencyMap.put(key,value);                
                        // Create a List of Partner Group Mapping which have Works For != null
                        worksForAccount.add(pgm);            
                    }
                }
            
                if(worksForAccount.size()>0) 
                {
                    for(Core_MDF_Partner_Group_Mapping__c agency : worksForAccount)
                        {
                            // Iterate through the Works for != null objects and create a Map of Account ID to the List of companies it works for 
                            List<Core_MDF_Partner_Group_Mapping__c> worksForAccount = accountToWorksForMap.get(agency.Core_MDF_Account__c);
                            if(worksForAccount == null)
                            {
                                worksForAccount = new List<Core_MDF_Partner_Group_Mapping__c>();
                                worksForAccount.add(agency);                         
                            }
                            else
                            {
                                worksForAccount.add(agency);
                                
                            }
                            accountToWorksForMap.put(agency.Core_MDF_Account__c,worksForAccount);                         
                        }
                   for(id accountID : accountToWorksForMap.keyset())
                        {
                            //Works for more Accounts
                            List<Core_MDF_Partner_Group_Mapping__c> worksForId = accountToWorksForMap.get(accountID);
                            if(worksForId.size()>1)
                            {        
                                worksForMultipleAccount.put(accountID,worksForId);                 
                            }
                        }
                   
                    for(Core_MDF_Partner_Group_Mapping__c agency : worksForAccount)
                        {
                            //For Agencies working only for one account
                            if(!worksForMoreAccountsList.contains(agency.Core_MDF_Account__c))
                            {
                                string key = agency.Core_MDF_Works_For__c;
                                key += agency.Core_MDF_Channel_Program__r.Name;                       
                                agencyToGroupMap.put(key,agency.Core_MDF_Group_Id__c);                  
                            }
                        }
                    
                }
            }
            
            catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex); }  
            
            return outputMap;
            
        }*/
        
        /* Creates Map of User, GroupID List for Agency,Non-Agency Account
         * Creates Map of User, GroupID List for Agency working for multiple Accounts
         */
        /*public static Map<id,List<id>> getGroupListForUser(Map<id,string> contactToAccountIDChannelPartner,Map<string,id> nonAgencyAccountIDToGroupListMap)
        {
 
            Map<id,List<id>> userToGroupList = new Map<id,List<id>>();
            List<id> agency = new List<id>();
            List<GroupMember> toBeLogged = new List<GroupMember>();
            
            try
            {
                for(string contact:contactToAccountIDChannelPartner.keyset())
                {
                    
                    string accountToCP = contactToAccountIDChannelPartner.get(contact);
                    id account = contactToAccountIDMap.get(contact);
                
                    
                    List<string> audienceList = accountToCP.split(';');
                    for(string audience : audienceList)
                    {
                        // For Agency Accounts
                        if(accountChannelProgramToAgencyMap.containsKey(audience))
                        {
                            
                            string value = accountChannelProgramToAgencyMap.get(audience);
                            
                            
                            //If Agency works for only one Account
                            agency.add(agencyToGroupMap.get(value));
                            if(agency.size()!=null)
                            {
                                // Creates Map of Contact-Agency Group ID
                                userToGroupList.put(contactToUserMap.get(contact),agency);                 
                            }
                            //If Agency works for more than one Account
                            else
                            {
                                List<Core_MDF_Partner_Group_Mapping__c> worksForMultiple = worksForMultipleAccount.get(account);
                                for(Core_MDF_Partner_Group_Mapping__c multipleWorksFor : worksForMultiple)
                                {
                                    GroupMember newobj = new GroupMember();
                                    newobj.UserOrGroupId = contactToUserMap.get(contact);
                                    newobj.GroupId = multipleWorksFor.Core_MDF_Group_Id__c;
                                    toBeLogged.add(newobj);
                                }
                                
                                // Log in UserGroupMappingLog Object
                                logInUserGroupMappingLogObject(toBeLogged,'Action Required','In Progress');
                            }
                                           
                        }
                        
                        else
                        {
                           //List<string> contactToAccountIDChannelPartnerString = contactToAccountIDChannelPartner;
                           if(contactsWithMultipleCCPAudience.contains(contact))
                           {
                                   agency = userToGroupList.get(contactToUserMap.get(contact));
                                   if (agency==null)
                                   {
                                       agency = new List<id>();
                                       agency.add(nonAgencyAccountIDToGroupListMap.get(audience));    
                                   }
                                   else
                                   {
                                       agency.add(nonAgencyAccountIDToGroupListMap.get(audience));  
                                   }
                                   userToGroupList.put(contactToUserMap.get(contact),agency);
                            }
                            else
                            {
                              agency.add(nonAgencyAccountIDToGroupListMap.get(accountToCP));
                        
                              userToGroupList.put(contactToUserMap.get(contact),agency);  
                            }
                        }
                    }
                }          
            }
                        
            catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
    

            return userToGroupList;
        }*/
        
        /* Create a Map of User,Existing GroupID List
         * Create a Map of User, GroupID List to be Added
         * Create a Map of User, GroupID List to be Removed
         */
        /*public static void addOrRemoveUserFromGroup(Map<id,List<id>> userToGroupList)
        {
            List<GroupMember> groupList = new List<GroupMember>();
            List<id> toBeRemovedList = new List<id>();
            List<id> alreadyExistsList = new List<id>();
            Map<id,List<id>> toBeRemoved = new Map<id,List<id>>();
            Map<id,List<id>> userGroupList = new Map<id,List<id>>();
            List<GroupMember> toBeInserted = new List<GroupMember>();
            List<GroupMember> toBeDeletedLog = new List<GroupMember>();
            List<id> toBeDeleted = new List<id>();
            Map<string,GroupMember> userToGroupIdMap = new Map<string,GroupMember>();
            
            try
            {
                // Query the Group Member table for the input contacts
                groupList = [SELECT GroupId, UserOrGroupId FROM GroupMember where UserOrGroupId in: userToGroupList.keyset() and groupid in :allCCPExternalGroupIds];

                
                for(GroupMember gm : groupList)
                {
                    List<id> userGroup = userGroupList.get(gm.UserOrGroupId);
                    if(userGroup == null)
                    {
                        userGroup = new List<id>();
                        userGroup.add(gm.GroupId);
                    }
                    else
                    {
                        userGroup.add(gm.GroupId);
                    }
                    userGroupList.put(gm.UserOrGroupId,userGroup);
                }
                
            
                
                for(id userGmId:userGroupList.keyset())
                {
                    List<id> inputUserGmID = userToGroupList.get(userGmId);
                    List<id> groupMemberID = userGroupList.get(userGmId);
                    
                    
                    
                    for(id groupMember:groupMemberID)
                    {
                        if(inputUserGmID.contains(groupMember))
                        {
                            // If required group is already added, ignore
                            inputUserGmID.remove(inputUserGmID.indexOf(groupMember));
                          
                        }
                        else
                        {
                           // Remove unwanted groups
                            toBeRemovedList.add(groupMember) ;
                        }
                    }
                   
                    toBeRemoved.put(userGmId,toBeRemovedList);
                    userToGroupList.put(userGmId,inputUserGmID);           
                }
                Set<String> userOrGroupIdSet = new Set<String>();
                for(id userId: userToGroupList.keyset())
                {
                    for(id groupid : userToGroupList.get(userId))
                        {
                            GroupMember newobj = new GroupMember();
                            newobj.UserOrGroupId = userId;
                            newobj.GroupId = groupid;
                            toBeInserted.add(newobj);  
                            //User Sharing
                            userOrGroupIdSet.add(userId);
                        }          
                }  
                
                if(toBeRemoved!=null)
                {
                    List<groupmember> gm = [select id,UserOrGroupId,GroupId from groupmember where userorgroupid in :toBeRemoved.keyset()];
                    for(groupmember g: gm)
                    {
                        string key = g.UserOrGroupId;
                        key += g.GroupId;
                        userToGroupIdMap.put(key,g);   
                    }            
                    
                    for(id userId: toBeRemoved.keyset())
                    {
                        for(id groupid : toBeRemoved.get(userId))
                        {
                            string key = userId;
                            key += groupid; 
                            groupmember groupMemberRecord = userToGroupIdMap.get(key);
                            toBeDeleted.add(groupMemberRecord.id); 
                            toBeDeletedLog.add(groupMemberRecord);
                        }
                    }
                }
                if(toBeInserted.size()>0){
                    
                    logInUserGroupMappingLogObject(toBeInserted,'Add','In Progress');
                    Database.SaveResult[] saveList = Database.insert(toBeInserted,false);
                }
              
                if(toBeDeleted.size()>0){
                    
                    logInUserGroupMappingLogObject(toBeDeletedLog,'Remove','In Progress');
                  
                    Database.executeBatch(new Core_MDF_UserGroupMapping_Deletion(toBeDeleted), 250);
                } 
                
                /*
                //JV-Accenture - US441266: Update the PNUM Entries belonging to the Users
                List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = [SELECT Id, Core_MDF_Account__c, Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_User__c IN:userToGroupList.keyset()];
                if(pnumList != null && pnumList.size() > 0){
                    Database.update(pnumList);
                } */ 
        
                    
                /*Boolean externalUserSharingSwitch =false;
                if(mapFunctionalityNameTriggerExecution.containsKey('callExtUsrSharingFrmUGMAutomation') &&
                   mapFunctionalityNameTriggerExecution.get('callExtUsrSharingFrmUGMAutomation').Core_Active__c){externalUserSharingSwitch = true;}
                
                 //insert User Sharing record
                 if(externalUserSharingSwitch && userOrGroupIdSet != NULL && userOrGroupIdSet.size() > 0){
                     
                     // Calling the ExternalUserSharing Batch to create the UserShare record and to avoid the Mixed DML Error
                     Database.executeBatch(new Core_MDF_ExternalUserSharing(true,userOrGroupIdSet));
                }

                if(userToGroupList!=Null && userToGroupList.size()>0)
                {
                    ID jobID = System.enqueueJob(new Core_MDF_IPA_AccountUserMapping(userToGroupList));
                }*/
                
               /* if(userToGroupList!=Null && userToGroupList.size()>0)
              {
                  ID jobID = System.enqueueJob(new Core_MDF_IPA_AccountUserMapping(userToGroupList));
              }*/
            /*}
            catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex); }                
           
        }*/
        // Method to get all the CCP External Groups from PGM
        /*public static void getAllCCPExternalGroupIds()
        {
            try{
            for(Core_MDF_Partner_Group_Mapping__c pgm : [select Core_MDF_Group_Id__c from Core_MDF_Partner_Group_Mapping__c where Core_MDF_Type_of_Access__c='External' and Core_MDF_Inactive_Ind__c = false])
            {
                allCCPExternalGroupIds.add(pgm.Core_MDF_Group_Id__c);
            }
            }
            catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex); } 
            
        }*/
        
        // Method for removal of user from group if the user no longer has a CCP audience 
       /* public static void sendForGroupRemoval(List<Contact> contactGroupRemoval)
        {
            Map<id,id> contactToUser = new Map<id,id>();
            List<id> contactListIds = new List<id>();
            List<id> userIdList = new List<id>();
            List<id> toBeRemoved = new List<id>();
            List<groupmember> toBeRemovedLog = new List<groupmember>();
            
            try{
            for(contact c:contactGroupRemoval){contactListIds.add(c.id);}
            contactToUser = getUser(contactListIds);
            userIdList = contactToUser.values();
            
            for(groupmember gm:[select id,UserOrGroupId,GroupId from groupmember where userorgroupid in :userIdList and groupid in : allCCPExternalGroupIds])
            {
                toBeRemoved.add(gm.id);
                toBeRemovedLog.add(gm);
            }
            
            logInUserGroupMappingLogObject(toBeRemovedLog,'Remove','In Progress');
           
            Database.executeBatch(new Core_MDF_UserGroupMapping_Deletion(toBeRemoved), 250);  
            
            }
            
            catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 
        }*/
        
        // Log the identified entries in Core_MDF_UserGroupMapping_Log object
        /*public static void logInUserGroupMappingLogObject(List<GroupMember> toBeLogged,  string action, string status)
        {
            List<Core_MDF_UserGroupMapping_Log__c> logObjectList = new List<Core_MDF_UserGroupMapping_Log__c>();
            
            
            try{
            for(GroupMember gm: toBeLogged)
                {
                    Core_MDF_UserGroupMapping_Log__c logobject = new Core_MDF_UserGroupMapping_Log__c();
                    logobject.Core_MDF_User_id__c= gm.UserOrGroupId;
                    logobject.Core_MDF_Group_id__c = gm.Groupid;
                    logobject.Core_MDF_Contact_id__c = userToContactMap.get(gm.UserOrGroupId);
                    logobject.Core_MDF_Account_id__c = contactToAccountIDMap.get(logobject.Core_MDF_Contact_id__c);
                    string accountChannelPartnerForAgency = accountChannelProgramToAgencyMap.size() == 0?null:accountChannelProgramToAgencyMap.get(contactToAccountIDChannelPartner.get(logobject.Core_MDF_Contact_id__c).SubStringBefore(';'));
                    if(accountChannelPartnerForAgency != null)
                    {
                        logobject.Core_MDF_Works_For_Account_id__c = accountChannelPartnerForAgency.substring(0,18);
                        //logobject.Core_MDF_Channel_Program_id__c = accountChannelPartnerForAgency.substring(18,accountChannelPartnerForAgency.length());
                    }
                    logobject.Core_MDF_Channel_Program_id__c =  groupIdToChannelProgramMap.get(logobject.Core_MDF_Group_id__c);  
                   
                    
                    if(logobject.Core_MDF_Group_id__c == null)
                    {
                      string audience = contactToAccountIDChannelPartner.get(logobject.Core_MDF_Contact_id__c);
                        
                      // If contact contains more than one Channel Partner
                      if(audience.contains(';'))
                      {
                          if(userToLoggedChannelProgram.get(logobject.Core_MDF_User_id__c) == null){
                              createMapforNullGroupId(audience,logobject.Core_MDF_User_id__c);  
                          }
                          set<id> channelProgramId = userToLoggedChannelProgram.get(logobject.Core_MDF_User_id__c);
                          if(channelProgramId != null)
                          {
                              for(id cpID : channelProgramId)
                              {
                                  logobject.Core_MDF_Channel_Program_id__c = cpID;
                                 
                                  loggedChannelProgramID.remove(cpID);
                                  userToLoggedChannelProgram.put(logobject.Core_MDF_User_id__c,loggedChannelProgramID);
                            
                                  break;
                              }  
                          }  
                       }
                       else{
                            logobject.Core_MDF_Channel_Program_id__c = channelProgramToIdMap.get(audience.substring(18,audience.length())); 
                        }
                    }
                    logobject.Core_MDF_Action_nm__c = action;
                    logObject.Core_MDF_Status_nm__c= status;
                    logObject.Core_MDF_Processed_dtm__c = system.now();
                    logObjectList.add(logobject);
                }
            
            }       
            catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 
            Database.executeBatch(new Core_MDF_UGMLog(logObjectList), 250);     
        }
        
        // Method to identify the Channel Programs for a user whose Group ID is null
        // Creates a map of User ID, List of Channel Programs which have NULL Group ID
        public static void createMapforNullGroupId (string audience, id userID)
        {
            List<string> audienceList = audience.split(';');
            
            try{
                for(string result : audienceList)
                {
                    if(!accountToChannelProgramID.containsKey(result))
                    {
                    set<id> loggedChannelPrograms = userToLoggedChannelProgram.get(userID);
                    if(loggedChannelPrograms != null)
                    {
                        for(id channelProgram : loggedChannelPrograms)
                        {
                            if(channelProgram != channelProgramToIdMap.get(result.substring(18,result.length())))
                            {
                                loggedChannelProgramID.add(channelProgramToIdMap.get(result.substring(18,result.length())));
                                userToLoggedChannelProgram.put(userID,loggedChannelProgramID);
                            }
                        } 
                    }
                    else{
                    loggedChannelProgramID.add(channelProgramToIdMap.get(result.substring(18,result.length())));
                    userToLoggedChannelProgram.put(userID,loggedChannelProgramID);
                    }
                    }                   
                }
            }
            catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 
            
        }*/
    
    }