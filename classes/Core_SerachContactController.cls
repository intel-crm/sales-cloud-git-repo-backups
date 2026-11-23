/******************************************************************************************************
* Class Name  : Core_SerachContactController 
* Version     : 1.0 
* Created Date: 04-06-2019
* Modification Log :
* Developer  Sandip Ghosh          
* Date   04/06/2019
* Description : This class is used for searching contact
* -----------------------------------------------------------------------------------------------------
*******************************************************************************************************/
public without sharing class Core_SerachContactController{
    /****************************************************************************************************** 
Method Name:        fetchContactbyEmail
@return  :          List of Contact record(s)
@parameters:        <String>searchKeyWord
Description:        This method is used to fetch claim data by passing claim record ID, in case of edit
Added By:           Accenture - AD - 04/06/2019
Modified By: Sandip        Date:  04/06/2019     Changes: Initial Version
*******************************************************************************************************/
    @AuraEnabled
    public static List<Contact> fetchContactbyEmail(String searchKeyWord, String userId) {
        Logginglevel logLevel = Logginglevel.ERROR;
        System.debug(logLevel, 'searchKeyWord **** = ' + searchKeyWord);
        System.debug(logLevel, 'userId **** = ' + userId);
        
        String searchKey = String.escapeSingleQuotes(searchKeyWord);
        List<Contact> returnList = new List<Contact>();
        List<Contact> lstOfContacts = new List<Contact>();
        String ContactId1;
        string loggdInUserAccountId;
            
        List<User> users = [Select Id, ContactId from User where Id = :userId];
        if(users != null && !users.isEmpty()){
        	ContactId1 = users[0].ContactId;
        }
        List<Contact> contList = [Select Id,AccountId from Contact where Id = :ContactId1];
        if(contList != null && !contList.isEmpty()){
        	loggdInUserAccountId = contList[0].AccountId;
        }
        
        /*if(!users.isEmpty()){
            User userRec = users[0];
            
            if(userRec.ContactId != null){
            lstOfContacts = [select Id, Account.Id
            from Contact where Id = :userRec.ContactId];
            System.debug('lstOfContacts **** = ' + lstOfContacts);
            
            //lstOfContacts = [select Id, Name,FirstName, LastName, Email , Account.Name
            //from Contact where Email = :searchKey];
            }
            
            }*/   
        List<GroupMember> gmList = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember where UserOrGroupId = :userId];
        
        List<Id> loggedInUserGroupIds = new List<id>();
        for(GroupMember gMember : gmList){
            loggedInUserGroupIds.add(gMember.GroupId);
        }
		
        System.debug(logLevel, 'gmList = '+ gmList);
		System.debug(logLevel, 'loggedInUserGroupIds = '+ loggedInUserGroupIds);
        
        List<Core_MDF_Partner_Group_Mapping__c>  pgMappingList = [SELECT Core_MDF_Account__c,
                                                                  Core_MDF_Channel_Program__c,Core_MDF_Group_Id__c,
                                                                  Core_MDF_Group_Name__c,Core_MDF_Type_of_Access__c,
                                                                  Core_MDF_Works_For__c FROM Core_MDF_Partner_Group_Mapping__c
                                                                  where Core_MDF_Group_Id__c in :loggedInUserGroupIds];
        Set<Id> accIds = new Set<id>();
        Set<Id> agencyaccIds = new Set<id>();      
        System.debug(logLevel, 'pgMappingList = '+ pgMappingList);

        for(Core_MDF_Partner_Group_Mapping__c pgMappingMember : pgMappingList){
            accIds.add(pgMappingMember.Core_MDF_Account__c);
            System.debug(logLevel, 'pgMappingMember.Core_MDF_Account__c = '+ pgMappingMember.Core_MDF_Account__c);
            System.debug(logLevel, 'pgMappingMember.Core_MDF_Channel_Program__c = '+ pgMappingMember.Core_MDF_Channel_Program__c);            
            System.debug(logLevel, 'pgMappingMember.Core_MDF_Group_Id__c = '+ pgMappingMember.Core_MDF_Group_Id__c);
            System.debug(logLevel, 'pgMappingMember.Core_MDF_Group_Name__c = '+ pgMappingMember.Core_MDF_Group_Name__c);
            System.debug(logLevel, 'pgMappingMember.Core_MDF_Type_of_Access__c = '+ pgMappingMember.Core_MDF_Type_of_Access__c);
            System.debug(logLevel, 'pgMappingMember.Core_MDF_Works_For__c = '+ pgMappingMember.Core_MDF_Works_For__c);  
        }
        
        System.debug(logLevel, 'accIds = '+ accIds);
        System.debug(logLevel , 'loggdInUserAccountId = '+ loggdInUserAccountId);
        
        if( !String.isBlank(loggdInUserAccountId)){
            List<Core_MDF_Partner_Group_Mapping__c> usertype = [Select Core_MDF_Account__c,Core_MDF_Works_For__c,
                                                                Core_MDF_Group_Id__c, Core_MDF_Group_Name__c from 
                                                                Core_MDF_Partner_Group_Mapping__c
                                                                where Core_MDF_Account__c = :loggdInUserAccountId 
                                                                AND Core_MDF_Account__c in :accIds
                                                                AND Core_MDF_Group_Id__c in :loggedInUserGroupIds];
            
            System.debug(logLevel, 'usertype = '+ usertype);
            
            if(!usertype.isEmpty() && usertype != null && usertype[0].Core_MDF_Works_For__c == null) { // User is a corporate Admin 
                lstOfContacts = [select Id, Name,FirstName, LastName, Email , Account.Name, Account.Id
                                 from Contact where Email = :searchKey AND Account.Id in :accIds];
            }
            else{// User is an agency user
                /*for(Core_MDF_Partner_Group_Mapping__c agencypgMappingMember : pgMappingList)
                {
                    if(agencypgMappingMember.Core_MDF_Works_For__c == null) // || agencypgMappingMember.Core_MDF_Works_For__c == usertype[0].Core_MDF_Works_For__c
                    {
                        agencyaccIds.add(agencypgMappingMember.Core_MDF_Account__c);// adding all non-agency accounts & the logged in user's agency account if the user is agency
                    }
                }*/
                if(loggdInUserAccountId != null){
                    agencyaccIds.add(loggdInUserAccountId);
                }
                System.debug(logLevel , 'agencyaccIds = '+ agencyaccIds); 
                
                lstOfContacts = [select Id, Name,FirstName, LastName, Email , Account.Name, Account.Id
                             from Contact where Email = :searchKey AND Account.Id in :agencyaccIds];
            }
        }
        
        System.debug(logLevel, 'lstOfContacts **** = ' + lstOfContacts);
            
        for (Contact contact: lstOfContacts) {
            returnList.add(contact);
        }
        return returnList;
    }
}