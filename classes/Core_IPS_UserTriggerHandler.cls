public without sharing class Core_IPS_UserTriggerHandler{
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 04 Dec 2015
Function    : This method adds  
Input Parameters: List<User>
Output Parameters: None
Transactions: 
Description: This method creates a new Project Member record under projects having the Account under which the contact is created.     
Number of Queries Within this Method: 2
Number of Queries in Loop: 0
Number of Queries from Called methods: 0
Number of times called: 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        12/04/2015              Created    
* Amritesh                   11/08/2017              Modified - updated the InsertProjMemberatFuture with Queueable apex
****************************************************************************************************/ 
    public static void InsertProjMember(List<User> UserList){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('insertprojmemberfromuser')) return;
        List<Id> accList = new List<Id>();
        List<Id> usersList = new List<Id>();
        if(UserList <> null && UserList.size()>0){
            List<User> ipsUsers = new List<User>();
            String userType = 'PowerCustomerSuccess';
            String query = 'select id, name, Contact.Id, Contact.AccountId from user where id IN: UserList and usertype=:userType and userroleid!=null and Contact.Core_IPS_Active__c = true';
              ipsUsers = Database.query(query);
            
            for(User Usr: ipsUsers){
                accList.add(Usr.Contact.AccountId);
                usersList.add(Usr.id);
            }                               
            //InsertProjMemberatFuture(usersList, accList);    // commented as logic moved to queueable apex
            if(!Test.isRunningTest()){ System.enqueueJob(new Core_IPS_ProjectMemberQueueable(usersList, accList));  // added by amritesh - US80097
                                     }
        }
    }
    
    /************************ ***************************************************************************
Version     : 1.0 
Created Date: 04 Dec 2015
Function    : This method is a future call method which does the insert of Project Member records
Input Parameters: Set<Id>, List<Id>
Output Parameters: None
Transactions: 
Description: This method inserts the project member records when the User record is created.        
Number of Queries Within this Method: 1
Number of Queries in Loop: 0
Number of Queries from Called methods: 0
Number of times called: 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        12/04/2015              Created    
****************************************************************************************************/ 
    // method commented as logic moved to queueable apex -- amritesh - US80097 - 11/08/2017
    /*
@future
public static void InsertProjMemberatFuture(List<Id> usersList, List<Id> accList){
if(usersList <> null && usersList.size()>0 && accList <> null && accList.size()>0){
List<Core_IPS_Project_Member__c> ProjMemberList = new List<Core_IPS_Project_Member__c>();
List<User> ipsUsers = [select id, name, Contact.Id, Contact.AccountId from user where id IN: usersList and usertype='PowerCustomerSuccess' and userroleid!=null and Contact.Core_IPS_Active__c = true];
List<Core_IPS_Account__c> ProjAccounts = [Select id, Core_Account__c, Core_IPS_Project__c, Core_Status__c from Core_IPS_Account__c where Core_Account__c IN: accList and Core_Members__c ='All'];
if(ipsUsers <> null && ipsUsers.size()>0){
for(User u: ipsUsers){
for(Core_IPS_Account__c projAccount: ProjAccounts){
if(u.Contact.AccountId == projAccount.Core_Account__c){
Core_IPS_Project_Member__c ProjMembers = new Core_IPS_Project_Member__c();
ProjMembers.Core_User__c= u.id;
ProjMembers.Core_Selective_Member__c= false;
ProjMembers.Core_IPS_Contact__c = u.Contactid;
ProjMembers.Core_Status__c= 'Active';
ProjMembers.Core_IPS_Provisioning_Date__c = System.Now();                            
ProjMembers.Core_IPS_Project__c = projAccount.Core_IPS_Project__c;
ProjMemberList.add(ProjMembers);
}
}
}
if(ProjMemberList <> null && ProjMemberList.size()>0){
try{
insert ProjMemberList;
}catch(exception e){
Core_Exceptionclass Exce =  new Core_Exceptionclass();
string  Str = Exce.InsertException('','Core_IPS_UserTriggerHandler','User','','InsertProjMemberatFuture',e);
}
}
}
}
}
*/
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 04 Dec 2015
Function    : This method is a future call method which does the update on Project Member records
Input Parameters: Map<Id,User>, Map<Id,User>, List<User>
Output Parameters: None
Transactions: 
Description: This method re-activates the project member records when the User Active field is updated to True        
Number of Queries Within this Method: 1
Number of Queries in Loop: 0
Number of Queries from Called methods: 0
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        12/04/2015              Created    
* Amritesh                   11/08/2017              Modified - updated the UpdateProjMemberatFuture with Queueable apex
****************************************************************************************************/ 
    public static void UpdateProjMember(Map<Id,User> oldMap, Map<Id,User> newMap, List<User> UserList){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateprojmemberfromuser')) return;
        List<Id> AccountIds = new List<Id>();
        Set<Id> ProjectIds = new Set<Id>();
        List<Id> ContactIds = new List<Id>();
        List<Id> UserIds = new List<Id>();
        List<Core_IPS_Account__c> ProjAccounts = new List<Core_IPS_Account__c>();
        List<User> ipsUsers = new List<User>();
        String userType = 'PowerCustomerSuccess';
        String query = 'select id, name, Contact.Id, Contact.AccountId,isActive , usertype from user where id IN: UserList and usertype=:userType and userroleid!=null and Contact.Core_IPS_Active__c = true';
         ipsUsers = Database.query(query);
        
        for(User ipsUser: ipsUsers){
            if(oldMap <> null && newMap <> null && ipsUser.usertype=='PowerCustomerSuccess' && ipsUser.isActive == true && ((oldMap.get(ipsUser.id).IsActive <> newMap.get(ipsUser.id).IsActive) ||(oldMap.get(ipsUser.id).AccountId <> newMap.get(ipsUser.id).AccountId))){
                AccountIds.add(ipsUser.Contact.AccountId);
                ContactIds.add(ipsUser.Contactid);
                UserIds.add(ipsUser.id);
            }
        }
        if(AccountIds <> null && AccountIds.size()>0) 
            if(Core_IPS_Account__c.SObjectType.getDescribe().isQueryable()){
                ProjAccounts = [Select id, Core_Account__c, Core_IPS_Project__c, Core_Status__c from Core_IPS_Account__c where Core_Account__c IN: AccountIds];
            }
        for(Core_IPS_Account__c ProjAcc: ProjAccounts){
            ProjectIds.add(ProjAcc.Core_IPS_Project__c);
        }        
        //UpdateProjMemberatFuture(ProjectIds,UserIds, ContactIds);  // commented as logic moved to queueable apex
        if(!Test.isRunningTest()){ System.enqueueJob(new Core_IPS_ProjectMemberQueueable(ProjectIds, UserIds, ContactIds)); // added by amritesh - US80097
                                 }
    } 
    
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 27 Nov 2017
Function    : This method takes the Region, Sub Region,Country fields to Contact that can be used in Case Routing
Input Parameters: User New List
Output Parameters: None
Transactions: After Insert, After Update
Description: This method takes the Region, Sub Region,Country fields to Contact that can be used in Case Routing                
Used in     : Core_User Trigger
Number of Queries Within this Method: 0
Number of Queries in Loop: 0
Number of Queries from Called methods: 2
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Vishwakarma        27/11/2017             Created  - Calling the future method to avoid Mixed DML issue - US87938
****************************************************************************************************/  
    public static void updateUserRegionFields(List<User> lstUsers,Map<Id,User> mapOldValues){
        
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateUserRegionFields'))
            return;
        try{
            
            List<Id> lstUsersIds = new List<Id>();
            for(User objUser : lstUsers){
                if(mapOldValues != null){
                    
                    if(objUser.ContactId != null && objUser.Core_User_Country_Code__c != mapOldValues.get(objUser.Id).Core_User_Country_Code__c) {
                        lstUsersIds.add(objUser.Id);
                    }
                }
                else{
                    lstUsersIds.add(objUser.Id);
                }
            }
            
            if(!lstUsersIds.isEmpty())
                updateUserRegionFieldsAtFuture(lstUsersIds);
        }
        catch(Exception e){  
            Core_IPS_ExceptionHandling.logEntryWithException(e, 'User', 'Core_IPS_UserTriggerHandler');
            }        
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 27 Nov 2017
Function    : This method takes the Region, Sub Region,Country fields to Contact that can be used in Case Routing
Input Parameters: User Id List
Output Parameters: None
Transactions: After Insert, After Update
Description: This method takes the Region, Sub Region,Country fields to Contact that can be used in Case Routing                
Used in     : Core_IPS_UserTriggerHandler class
Number of Queries Within this Method: 2
Number of Queries in Loop: 0
Number of Queries from Called methods: 0
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Vishwakarma        27/11/2017             Created  
****************************************************************************************************/      
    @future
    public static void updateUserRegionFieldsAtFuture(List<String> lstUsersIds){
        
        Map<Id,User> mapUserRegion = new Map<Id,User>();
        for(User objUser : [Select Id,ContactId,Core_User_Geo__c,Core_User_Country_Code__c,Core_User_Sub_Geo__c 
                            FROM User 
                            WHERE Id IN : lstUsersIds AND Core_User_Country_Code__c!=null AND isActive=True]){
                                if(objUser.ContactId != null){
                                    mapUserRegion.put(objUser.ContactId, objUser);
                                }
                            }
        
        List<Contact> lstFilteredContacts = new List<Contact>();
        //FLS check added-Venugopal
        if(Contact.SObjectType.getDescribe().isAccessible()){
        for(Contact objContact : [Select Id,Core_IPS_Region__c,Core_IPS_Sub_Region__c,MailingCountry,Core_IPS_Employee_Customer__c
                                  FROM Contact 
                                  WHERE Id IN : mapUserRegion.keyset()]){
                                      
                                      if(mapUserRegion.containsKey(objContact.Id)) {
                                          
                                          objContact.Core_IPS_Region__c = mapUserRegion.get(objContact.Id).Core_User_Geo__c;
                                          objContact.Core_IPS_Sub_Region__c = mapUserRegion.get(objContact.Id).Core_User_Sub_Geo__c;
                                          
                                          if(objContact.Core_IPS_Employee_Customer__c && String.isNotBlank(mapUserRegion.get(objContact.Id).Core_User_Country_Code__c)) {
                                              objContact.MailingCountry= mapUserRegion.get(objContact.Id).Core_User_Country_Code__c;
                                          }
                                          lstFilteredContacts.add(objContact);
                                      }
                                  }
        }
        
        if(!Test.isRunningTest()){ if(!lstFilteredContacts.isEmpty()) { Database.update(lstFilteredContacts,false);}      }       
    }
    
    
    /***************************************************************************************************
Version     : 1.0 US80492 I3
Created Date: 27 Nov 2017
Function    : This method checks if User has email id as '@intel.com' and profile as 'External customer/IPS Agent Partner' then it creates the Contact for that user and assoicate that conatct with existing Intel Acount.
Input Parameters: User New List
Output Parameters: None
Transactions: Before Insert
Description: This method will check if request which is raised from AGS for user creation has @intel.com email and IPS External customer profile then we will create a contact with user details if no existing contact else we will update the existing contact and we will assoicate that contact with Intel Account which is already there.                            
Used in     : Core_User Trigger
Number of Queries Within this Method: 0 
Number of Queries in Loop: 0
Number of Queries from Called methods: 0
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sandeep Sankhla          27/11/2017               Created 
* PopcornApps         12/04/2018        Update 
****************************************************************************************************/
    public static void createContactForEAC(List<User> lstUsers){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('createContactForEAC'))
            return;
        try{
            
            //Map to store the user email id and conatct record to associate for employee as customer. US80492
            map<String, Contact> mapEmployeeEmailToContact = new map<String,Contact>();
            map<String, String> mapEmailToExistingContactId = new map<String,String>();

            Id ConRecId=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
            Boolean isSB = [Select isSandbox from Organization Limit 1].isSandbox ; 
            
            set<String> setEmailIds = new set<String>();
            for(User objUN : lstUsers) {
                //Added null check for email - US219056
                if(objUN.Email!=null && objUN.Email.Contains('@intel.com') &&( (string.valueof(objUN.ProfileId).contains(Label.Core_IPS_External_Customer_Profile_Id)) ||(string.valueof(objUN.ProfileId).contains(Label.Core_IPS_Partner_AE_Profile_Id))  )){
                    if(isSB)
                        objUN.Email = objUN.Email + '.sndbx';
                    setEmailIds.add(objUN.Email);
                }
            } 
            if(setEmailIds.size()>0) {
                //FLS check added-Venugopal
                if(Contact.SObjectType.getDescribe().isAccessible()){
                    for(Contact objContact : [Select Id, Email from Contact where Email IN:setEmailIds]){
                        mapEmailToExistingContactId.put(objContact.Email, objContact.Id);
                    }
                }
                
                for(User populateEmailList : lstUsers){
                //Added by Sandeep US80492 to check if its Internal Employee requested as customer.                
                //Added null check for email - US219056
                if(populateEmailList.Email!=null && populateEmailList.Email.Contains('@intel.com') && ((string.valueof(populateEmailList.ProfileId).contains(Label.Core_IPS_External_Customer_Profile_Id))||(string.valueof(populateEmailList.ProfileId).contains(Label.Core_IPS_Partner_AE_Profile_Id))  )){
                    
                    Contact objIPSContact;
                    
                    if(!mapEmailToExistingContactId.containskey(populateEmailList.Email)){
                        //Raj Kommera added below code for US96050
                        if (string.valueof(populateEmailList.ProfileId).contains(Label.Core_IPS_External_Customer_Profile_Id) ){//RK add
                            objIPSContact = new Contact(Core_IPS_Active__c = true,RecordtypeId = ConRecId,AccountId = Label.Core_IPS_AccountID ,FirstName = populateEmailList.FirstName, LastName = populateEmailList.LastName, Email = populateEmailList.Email, MailingCountry='USA');//Tejaswini: Added MailingCountry='USA'to consider MailingCountry validation rule
                            //AccountID: 0013F0000052PUp
                            //Profile ID:  00eo0000000f7GOAAY
                        }else if(string.valueof(populateEmailList.ProfileId).contains(Label.Core_IPS_Partner_AE_Profile_Id)){//RK add
                            objIPSContact = new Contact(Core_IPS_Active__c = true,RecordtypeId = ConRecId,AccountId = Label.Core_Partner_Agent_Holding_Account ,FirstName = populateEmailList.FirstName, LastName = populateEmailList.LastName, Email = populateEmailList.Email);//RK Changes
                            //AccountID: 0014F000004C9FOQA0
                            //Profile ID: 00e4F000000LrLB
                        }//RK add
                        //RK Changes end
                    }
                    else{
                       if (string.valueof(populateEmailList.ProfileId).contains(Label.Core_IPS_External_Customer_Profile_Id) ){//RK add
                            objIPSContact = new Contact(Core_IPS_Active__c = true,Core_Account_Changeable__c = true, Id = mapEmailToExistingContactId.get(populateEmailList.Email),RecordtypeId = ConRecId, AccountId = Label.Core_IPS_AccountID ,FirstName = populateEmailList.FirstName, LastName = populateEmailList.LastName, Email = populateEmailList.Email, MailingCountry='USA');//Tejaswini: Added MailingCountry='USA'to consider MailingCountry validation rule
                        }//RK add
                        else if(string.valueof(populateEmailList.ProfileId).contains(Label.Core_IPS_Partner_AE_Profile_Id)){//RK add
                            objIPSContact = new Contact(Core_IPS_Active__c = true, Id = mapEmailToExistingContactId.get(populateEmailList.Email),RecordtypeId = ConRecId,FirstName = populateEmailList.FirstName, LastName = populateEmailList.LastName, Email = populateEmailList.Email);
                        }
                    }
                    //RK add
                    
                    if(populateEmailList.Phone != null & populateEmailList.Phone != '')
                        objIPSContact.Phone = populateEmailList.Phone;
                    if(populateEmailList.MobilePhone != null & populateEmailList.MobilePhone != '')
                        objIPSContact.MobilePhone = populateEmailList.MobilePhone;
                    
                    
                    mapEmployeeEmailToContact.put(populateEmailList.Email, objIPSContact);
                }
            }
            
            }
            if(!mapEmployeeEmailToContact.IsEmpty()){
                
                Database.upsert(mapEmployeeEmailToContact.values(), true);  
                //insert mapEmployeeEmailToContact.values();             
                                
                for(User objUser : lstUsers) 
                {
                    //Added null check for email - US219056
                    if(objUser.Email!=null && mapEmployeeEmailToContact.containsKey(objUser.Email))
                        objUser.ContactId = mapEmployeeEmailToContact.get(objUser.Email).Id;
                    
                }
            }
        }
        catch(Exception e){ 
            Core_IPS_ExceptionHandling.logEntryWithException(e, 'User', 'Core_IPS_UserTriggerHandler');
            }
    }
    
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 04 Dec 2015
Function    : This method is a future call method which does the update on Project Member records
Input Parameters: Set<Id>, List<Id>, List<Id>
Output Parameters: None
Transactions: 
Description: This method re-activates the project member records when the User Active field is updated to True        
Number of Queries Within this Method: 1
Number of Queries in Loop: 0
Number of Queries from Called methods: 0
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        12/04/2015              Created    
****************************************************************************************************/ 
    @future
    public static void UpdateProjMemberatFuture(Set<Id> ProjectIds, List<Id> UserIds, List<Id> ContactIds){
        List<Core_IPS_Project_Member__c> ProjMemberList = new List<Core_IPS_Project_Member__c>();
        List<Core_IPS_Project_Member__c> ProjectMembers = new List<Core_IPS_Project_Member__c>();
        if(ProjectIds <> null && ProjectIds.size()>0){
            if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){
                ProjectMembers = [Select id from Core_IPS_Project_Member__c where Core_Status__c = 'Inactive' and Core_User__c IN: UserIds and Core_IPS_Contact__c IN: ContactIds AND Core_IPS_Project__c IN: ProjectIds];
            }
            if(ProjectMembers <> null && ProjectMembers.size()>0){
                for(Core_IPS_Project_Member__c ProjMember: ProjectMembers){
                    ProjMember.Core_Status__c = 'Active';
                    ProjMember.Core_IPS_Provisioning_Date__c = System.Now();
                    ProjMemberList.add(ProjMember);
                }
                if(ProjMemberList <> null && ProjMemberList.size()>0 && Core_IPS_Project_Member__c.SObjectType.getDescribe().isUpdateable()){
                    update ProjMemberList;
                }
            }
        }
    }
    
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 28 March 2018
Function    : This method takes the Region, Sub Region,Country fields to Contact that can be used in Case Routing
Input Parameters: User New List
Output Parameters: None
Transactions: After Insert, After Update
Description:  This Method to add EAC users to public groups based on their profiles(PG :IPS External Customer).              
Used in     : Core_User Trigger
Number of Queries Within this Method: 1
Number of Queries in Loop: 0
Number of Queries from Called methods: 0
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Karthick                  28/03/2018                 Created - Defect Fix - DE37341 
****************************************************************************************************/  
    
    public static void addEACUsersToIECGroups(map<Id, User> mapOld, map<Id, User> mapNew) {           
        
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('addEACUsersToIECGroups'))
            return;
        
        Set<Id> setNewUserIds = new Set<Id>(); // New EAC Users
        
        //Collect userId list for Internal Employee As Customer
        for (User user :mapNew.values()) {
            //Added null check for email - US219056
            if(user.Email!=null && user.Email.Contains('@intel.com') &&( (string.valueof(user.ProfileId).contains(Label.Core_IPS_External_Customer_Profile_Id)) ||(string.valueof(user.ProfileId).contains(Label.Core_IPS_Partner_AE_Profile_Id))  )){
                
                if (mapOld == null || mapOld.get(user.Id) == null)
                    setNewUserIds.add(user.Id);
            }
            
        }
               
        // Stop and Return if there are no EAC users to process
        if (setNewUserIds.size() == 0 )
            return;                
        
        // Load the profile to group mapping
        Map<Id, Id> mapProfileIdGroupId = Core_UserHandler.LoadProfileToGroupMapping();        
        
        // Add the users to the groups
        if (setNewUserIds.size() != 0 ) {
            String query = 'SELECT Id, Name, ProfileId,Email FROM User WHERE Id IN :setNewUserIds';   //Added Email to queried field Tejaswini   
            List<User> lstUsers = Database.query(query);
            
            // Build the list of user ids and their group ids
            Map<Id, Id> mapUserIdGroupId = new Map<Id, Id>();
            for (User user :lstUsers) {
                
                if(mapProfileIdGroupId.containsKey(user.ProfileId) ){
                    Id groupId = mapProfileIdGroupId.get(user.ProfileId);
                
                    if (groupId != null) {// User has a ProfileId that has a matching groupId
                        /*added by Tejaswini for Employee as Customer profil migration to Partner */
                       if(user.Email!=null && user.Email.Contains('@intel.com') && string.valueof(user.ProfileId).contains(Label.Core_IPS_External_Customer_Profile_Id) ){
                           mapUserIdGroupId.put(user.Id, Label.Core_IPS_Employee_As_Customer_PG_Id);
                        } else {
                           mapUserIdGroupId.put(user.Id, groupId);
                        }
                    	/*End of code by Tejaswini */ 

                    }
                }
                
            }
            
            if(mapUserIdGroupId!=null && mapUserIdGroupId.size()>0)
                addGroupMembersAtFuture(JSON.serialize(mapUserIdGroupId));
    
        }
    }
    

/***************************************************************************************************
Version     : 1.0 
Created Date: 28 March 2018
Function    : This method takes the Region, Sub Region,Country fields to Contact that can be used in Case Routing
Input Parameters: User and Group Id Map
Output Parameters: None
Transactions: After Insert, After Update
Description: This Method to add EAC users to public groups based on their profiles(PG :IPS External Customer).                
Used in     : Core_IPS_UserTriggerHandler class
Number of Queries Within this Method: 0
Number of Queries in Loop: 0
Number of Queries from Called methods: 0
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Karthick                  28/03/2018                Created  
****************************************************************************************************/      
   @future
    public static void addGroupMembersAtFuture(String serializedMap){
        
        
        Map<Id,Id> mapUserIdGroupId = (Map<Id,Id>)JSON.deserialize(serializedMap, Map<Id,Id>.class);
        
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
        
        try{
            if(!Test.isRunningTest()){
                
                if(lstGroupMembers!=null && lstGroupMembers.size()>0) {
                    Database.insert(lstGroupMembers,false);
                } 
            }
        }catch(Exception e){
            Core_IPS_ExceptionHandling.logEntryWithException(e, 'User', 'Core_IPS_UserTriggerHandler'); 
        }
             
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 22 May 2018
Function    : This method assign the SFDC country code based on AGS Country Code.
Input Parameters: User New List
Output Parameters: None
Transactions: Before Insert,Before Update           
Used in     : Core_User Trigger
Number of Queries Within this Method: 0
Number of Queries in Loop: 0
Number of Queries from Called methods: 0
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Karthick                  25/05/2018              Created - US79064- R4.3
****************************************************************************************************/ 
    
    public static void convertCountryCodeToISO(List<User> newList,map<Id, User> mapOld) {
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('convertCountryCodeToISO'))
            return;
        try {
            //Map to get SFDC Country code based on AGS country code
            Map<String, Core_IPS_Country_Code_Mapping__c> mapCountryCode = new Map<String, Core_IPS_Country_Code_Mapping__c>();
            
            for (Core_IPS_Country_Code_Mapping__c country: Core_IPS_Country_Code_Mapping__c.getall().values()) {
                mapCountryCode.put(country.Core_IPS_AGS_Country_Code__c,country);
            }
            
            Set<string> provisioningUserSet = new Set<String>();
            
            provisioningUserSet.addAll(Label.Core_User_Provisioning_User_ProfileId.split(','));
            
            // Only perform this logic if the current user is the "user provisioning" (AGS API) user
            if ( provisioningUserSet.contains(UserInfo.getUserId().left(15)) ) { 
                
                for (User user : newList) {             
                    //Check if the user is Interanl user or not
                    //Added null check for email - US219056
                    if(user.Email!=null && user.Email.Contains('@intel.com')){              
                        if(user.CountryCode!=null){
                            if(mapCountryCode!=null && mapCountryCode.containsKey(user.CountryCode) ){
                                Core_IPS_Country_Code_Mapping__c country = mapCountryCode.get(user.CountryCode);
                                user.CountryCode = country.Core_IPS_SFDC_Country_Code__c;                            
                            }else{
                                user.CountryCode = Label.Core_IPS_Default_Country;
                            }
                        }
                        
                    }
                    /*else{
                        //Clearing the country code value for Non Internal User.
                        if(user.CountryCode!=null ){
                            if( mapOld.containsKey(user.Id) && mapOld.get(user.Id).CountryCode != null)
                                user.CountryCode = mapOld.get(user.Id).CountryCode;
                            else
                                user.CountryCode = null;
                        }
                    } */              
                }
            }
        } catch(Exception e){ 
            Core_IPS_ExceptionHandling.logEntryWithException(e, 'User', 'Core_IPS_UserTriggerHandler');
             }
    
    }
    
        
    /***************************************************************************************************
    Version     : 1.0 
    Function    : This method activates and inactivates the related Case Internal Interested Party
    Input Parameters: User New List, Old User Map
    Output Parameters: None
    Transactions: After Update           
    Used in     : Core_User Trigger
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods: 0
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh                    10/08/2018              Created - US113971
    ****************************************************************************************************/ 
    
    public static void InactivateActivateInterestedParty(List<User> newList,map<Id, User> mapOld) {
        //check if enabled from custom setting
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('InactivateInternalInterestedParty')) return;
        
        List<Id> lstActivatedUsers = new List<Id>();
        List<Id> lstInactivatedUsers = new List<Id>();
        
        for(User objUser : newList) {
            //if(objUser.IsActive!=mapOld.get(objUser.Id).IsActive && objUser.IsActive  && objUser.ContactId==null) {
            //Start --DE35667
            if(objUser.IsActive!=mapOld.get(objUser.Id).IsActive && objUser.IsActive) {
                lstActivatedUsers.add(objUser.Id);
            }
            //else if(objUser.IsActive!=mapOld.get(objUser.Id).IsActive && objUser.IsActive==false && objUser.ContactId==null) {
            //Start --DE35667
            else if(objUser.IsActive!=mapOld.get(objUser.Id).IsActive && objUser.IsActive==false ) {
                lstInactivatedUsers.add(objUser.Id);
            }
        }
        if((lstActivatedUsers.size()>0 || lstInactivatedUsers.size()>0) && !system.isBatch()) {
            InactivateActivateInterestedParty_Future(JSON.serialize(lstActivatedUsers), JSON.serialize(lstInactivatedUsers));
        }
    }
    
    /***************************************************************************************************
    Version     : 1.0 
    Function    : This method activates and inactivates the related Case Internal Interested Party
    Input Parameters: JSON String of List
    Output Parameters: None
    Transactions: After Update           
    Used in     : Core_User Trigger
    Number of Queries Within this Method: 2
    Number of Queries in Loop: 0
    Number of Queries from Called methods: 0
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh                    10/08/2018              Created - US113971
    ****************************************************************************************************/ 
    @future
    public static void InactivateActivateInterestedParty_Future(String strActivatedUsers, String strInactivatedUsers) {
            
        List<Id> lstActivatedUsers = (List<Id>)JSON.deserialize(strActivatedUsers, List<Id>.class);
        List<Id> lstInactivatedUsers = (List<Id>)JSON.deserialize(strInactivatedUsers, List<Id>.class);
        
        if(lstActivatedUsers!=null && lstActivatedUsers.size()>0) {
            //Start --DE35667--Added type external 
            List<Core_IPS_Case_Interested_Party__c> lstCaseInterestedParty2Activate = new List<Core_IPS_Case_Interested_Party__c>([SELECT Id FROM Core_IPS_Case_Interested_Party__c WHERE Type__c IN ('Internal','External') AND User__c IN :lstActivatedUsers AND Active__c=false]);
            //End --DE35667--Added type external
            for(Core_IPS_Case_Interested_Party__c objIP : lstCaseInterestedParty2Activate) {
                objIP.Active__c = true;
            }
            if(Core_IPS_Case_Interested_Party__c.SObjectType.getDescribe().isUpdateable()){
              update lstCaseInterestedParty2Activate;
            }
        }
        
        if(lstInactivatedUsers!=null && lstInactivatedUsers.size()>0) {
            //Start DE35667--Added type external
            List<Core_IPS_Case_Interested_Party__c> lstCaseInterestedParty2Inactivate = new List<Core_IPS_Case_Interested_Party__c>([SELECT Id FROM Core_IPS_Case_Interested_Party__c WHERE Type__c IN ('Internal','External') AND User__c IN :lstInactivatedUsers AND Active__c=true]);
            //End --DE35667--Added type external
            for(Core_IPS_Case_Interested_Party__c objIP : lstCaseInterestedParty2Inactivate) {
                objIP.Active__c = false;
            
            }
            if(Core_IPS_Case_Interested_Party__c.SObjectType.getDescribe().isUpdateable()){
              update lstCaseInterestedParty2Inactivate;
            }
        }
    }
    
/***************************************************************************************************
    Version     : 1.0 
    Function    : This method logs manager change
    Input Parameters: User New List, Old User Map
    Output Parameters: None
    Transactions: After Update           
    Used in     : Core_User Trigger
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods: 0
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh                    19/10/2018              Created - US194563
    ****************************************************************************************************/ 
    public static void managerChangelogger(List<User> newList,map<Id, User> mapOld) {
        //check if enabled from custom setting
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('managerChangelogger')) return;
        try {
            List<Core_IPS_User_Manager_Tracker__c> lstTracker = new List<Core_IPS_User_Manager_Tracker__c>();
            
            for(User objUser : newList) {
                if(objUser.ManagerId!=mapOld.get(objUser.Id).ManagerId) {
                    lstTracker.add(new Core_IPS_User_Manager_Tracker__c(Name=objUser.Id));
                }            
            }
            if(lstTracker.size()>0) {
                Database.insert(lstTracker, false);
            }
        } catch(Exception e){ 
            Core_IPS_ExceptionHandling.logEntryWithException(e, 'User', 'Core_IPS_UserTriggerHandler');
            }
    }
    /***************************************************************************************************
Version     : 1.0 
Function    : This method shares assets to customers
Input Parameters: User New List
Output Parameters: None
Transactions: After Intert           
Used in     : Core_User Trigger
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ganapati                    22/04/2020              Created for US618169 - PRB000091747: Fix issue with Product Access and when Contacts become IPS Active
****************************************************************************************************/     
    public static void shareAssetsToCustomers(List<User> usrList) {
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('shareAssetsToCustomers')) {
            return;
        }
        List<User> userList = new List<User>();
        if(User.SObjectType.getDescribe().isQueryable()){
           userList = [SELECT Id, Contact.AccountId, ContactId, UserRoleId FROM User WHERE Id IN :usrList AND (Profile.Name = : System.Label.Core_IPS_Profile_Name OR Profile.Name =: System.Label.Core_IPS_Partner_AE_ProfileName ) AND ContactId != null and Contact.Core_IPS_Active__c = true and Contact.Account.Core_IPS_Active__c = true ];
        }
            if(userList!=null && !userList.isEmpty()) {
            Set<Id> accountIdSet = new Set<Id>();
            Map<Id, Set<Id>> assetUsrRoleIdMap = new Map<Id, Set<Id>>();
            Map<Id, Id> assetShareIdMap = new Map<Id, Id>();
            List<Asset> assetToShare = new List<Asset>();
            Map<Id, Id> groupUsrRoleIdMap = new Map<Id, Id>();
            Map<Id, Asset> assetMap;
            List<AssetShare> assetShareList;
            List<Group> groupList;
            
            for(User usr : userList ) {
                accountIdSet.add(usr.Contact.AccountId);
            }
            
                if(!accountIdSet.isEmpty()) {
                    if(Asset.SObjectType.getDescribe().isQueryable()){
                        assetMap = new Map<Id, Asset>([SELECT Id, AccountId, Status, Core_IPS_Project__c, RecordTypeId FROM Asset WHERE AccountId IN :accountIdSet]);
                    }
                    if(AssetShare.SObjectType.getDescribe().isQueryable()){
                        assetShareList = [select AssetId, Asset.AccountId, UserOrGroupId from AssetShare  where Asset.AccountId IN : accountIdSet];
                    }
                    if(Group.SObjectType.getDescribe().isQueryable()){
                        groupList  = [SELECT Id, Name, DeveloperName, RelatedId, Related.Name FROM Group WHERE Id IN ( SELECT UserOrGroupId FROM AssetShare WHERE Asset.AccountId IN : accountIdSet)];
                    }
                }
            if( groupList != null && !groupList.isEmpty()) {                
                for(Group grpObj : groupList) {
                    groupUsrRoleIdMap.put(grpObj.Id, grpObj.RelatedId);
                }
            }
            if(assetShareList!=null && !assetShareList.isEmpty() && !groupUsrRoleIdMap.isEmpty()) {
                for(AssetShare assetShareObj : assetShareList) {    
                    if(assetUsrRoleIdMap.get(assetShareObj.AssetId)!= null) {
                        assetUsrRoleIdMap.get(assetShareObj.AssetId).add(groupUsrRoleIdMap.get(assetShareObj.UserOrGroupId));
                    } else {
                        Set<Id> usrRoleSet = new Set<Id>();
                        usrRoleSet.add(groupUsrRoleIdMap.get(assetShareObj.UserOrGroupId));
                        assetUsrRoleIdMap.put(assetShareObj.AssetId, usrRoleSet);
                    }
                }
            }
            if(assetMap!=null && !assetMap.isEmpty()) {
                for(User usr : userList ) {
                    for(Id assetid : assetMap.keySet()) {
                        if(!(assetUsrRoleIdMap != null && !assetUsrRoleIdMap.isEmpty() && assetUsrRoleIdMap.get(assetid).contains(usr.UserRoleId))) {
                            assetToShare.add(assetMap.get(assetid));
                        } 
                    }
                }
            }
            if(assetToShare!=null && !assetToShare.isEmpty()) {
                List<Asset> ipsNewRecordList = Core_IPS_Helper_Utility.getIPSRecords('Asset',assetToShare);
                if(ipsNewRecordList!=null && !ipsNewRecordList.isEmpty()) {
                    String newListStr = JSON.serialize(ipsNewRecordList);
                    Core_Asset_Handler.grantAssetAccesstoCustomers(newListStr); //Sharing asset to IPS External
                }
            }
        }
    }   
 /***************************************************************************************************
Version     : 1.0 
Created Date: 12 Nov 2020
Function    : This method adds  
Input Parameters: List<User>
Output Parameters: None
Transactions: 
Description: This method update Active Project Member and interested party record with active user. 
Number of Queries Within this Method: 2
Number of Queries in Loop: 0
Number of Queries from Called methods: 0
Number of times called: 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Prem                      11/12/2020              Added - updated the InsertProjMemberatFuture with Queueable apex
****************************************************************************************************/ 
    public static void UpdateUIOLIUserLostVisibilty(Map<Id, User> UserMap){
        List<User> ipsUsers = [select id, name, ContactId, Contact.AccountId from user where Contact.Core_IPS_Active__c = true AND isActive=true and Id In :UserMap.keyset()];
        Map<Id,Id> contactUserMap = new Map<Id,Id>();
        for(User ipsUser : ipsUsers){
            contactUserMap.put(ipsUser.ContactId,ipsUser.Id);
        }
        List<Sobject> allProjectMemAndIntParty =new List<Sobject>();
        List<Core_IPS_Project_Member__c> ProjectMembers = new List<Core_IPS_Project_Member__c>();
        //FLS check added-Venugopal.
        if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){
            ProjectMembers = [Select id,Core_IPS_Contact__c,Core_User__c from Core_IPS_Project_Member__c where Core_Status__c = 'active' and Core_IPS_Contact__c IN :contactUserMap.keySet() and Core_User__c NOT IN :contactUserMap.values()];
        }
        for( Core_IPS_Project_Member__c projMem: ProjectMembers){
            projMem.Core_User__c = contactUserMap.get((Id)projMem.Core_IPS_Contact__c);
        }
        //database.update(ProjectMembers);
        allProjectMemAndIntParty.addAll((List<Sobject>)ProjectMembers);
        //Interested party adding
        List<Core_IPS_Case_Interested_Party__c> interestedparties = new List<Core_IPS_Case_Interested_Party__c>();
        //FLS check added-Venugopal
        if(Core_IPS_Case_Interested_Party__c.SObjectType.getDescribe().isAccessible()){
            interestedparties = [Select id,Contact__c,User__c from Core_IPS_Case_Interested_Party__c where Active__c = true and Contact__c IN :contactUserMap.keySet() and User__c NOT IN :contactUserMap.values()];
        }
        for( Core_IPS_Case_Interested_Party__c interestedParty: interestedparties){
            interestedParty.User__c = contactUserMap.get((Id)interestedParty.Contact__c);
        }
        //database.update(interestedparties);
        allProjectMemAndIntParty.addAll((List<Sobject>)interestedparties);
        if(allProjectMemAndIntParty.size()>0){
            ID jobID = System.enqueueJob(new UpdateProjectMemAndIntParty(allProjectMemAndIntParty));
        }
        
    }
    
    //Queueable class
    public class UpdateProjectMemAndIntParty implements Queueable {
        public List<Sobject> allMemAndIntPartyList =null;
        public updateProjectMemAndIntParty(List<Sobject> sobjectList){
            allMemAndIntPartyList = sobjectList;
        }
        public void execute(QueueableContext context) {
            if(allMemAndIntPartyList.size()>0){
                database.update(allMemAndIntPartyList);
            }      
        }
    }    
    
}