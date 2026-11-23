/***************************************************************************************************
Class Name:  Core_IPS_Helper_Utility
Class Type: Utility Class 
Version     : 1.0
Created Date: 14 Oct 2015
Function    : This class contains utility 
Input Parameters: None 
Output Parameters: None
Description:   Used in case edit page to get the case information
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/14/2015              Created
****************************************************************************************************/   
public without sharing class Core_IPS_Helper_Utility { 
    
    public static boolean stopCaseSharingTrigger=false;
    /***************************************************************************************************
    Method Name:  getFAEsByAccount
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 14 Oct 2015
    Function    : This method is used to get FAEs associated to accounts
    Input Parameters: Account ID Set
    Output Parameters: FAEs grouped by Account
    Description:   This method takes a set of account identifiers and returns the FAEs associated to those accounts grouping them by account.
    Used in     : Product access and Project sharing
    Number of Queries Within this Method: 2
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/14/2015              Created
    * Jayaprakash T              10/28/2015              Moved hard coded values to IPS Labels custom setting
    ****************************************************************************************************/       
    public Static Map<Id,Set<Id>> getFAEsByAccount(Set<Id> acctIdSet){
        Map<Id,Set<Id>> faesByAccount = new Map<Id,Set<Id>>();
        try{
            List<String> rowCauseList = new List<String>();
            List<AccountShare> acctShare = new List<AccountShare>();
            //Remove Hardcoded values and move to IPS Labels
            rowCauseList.add(getIPSLabel('RowCause_Team'));
            rowCauseList.add(getIPSLabel('Rowcause_Owner'));
            List<String> caseAccessLevel = new List<String>();
            caseAccessLevel.add(getIPSLabel('AccessLevel_Read'));
            caseAccessLevel.add(getIPSLabel('AccessLevel_Edit'));
            Set<Id> userIdSet = new Set<id>();
            Set<id> accountIdSet = new Set<Id>();
            //if(accountshare.SObjectType.getDescribe().isAccessible()){ // FLS check already added - aditya
            	acctShare = [select accountId, caseaccesslevel, userOrGroupId, rowcause from accountshare where rowcause in :rowCauseList and caseAccessLevel IN: caseAccessLevel and  accountId in :acctIdSet];
            //}
            for(AccountShare share: acctShare){
                String userId = share.userOrGroupId;
                if(userId.startsWith('005')){
                    userIdSet.add(share.userOrGroupId);
                    accountIdSet.add(share.accountId);
                }
            }
            List<AccountShare> faeSharedAccounts = new List<AccountShare>();
            //Move profile as a comma separated list of profiles to custom label (names)
            //List of FAE profiles
            List<String> profileNames = Label.Core_IPS_FAE_ProfileName.split(';');
            List<User> faeUsers = [select id from User where id in :userIdSet and profile.name IN: profileNames];
            for(User u: faeUsers){
                for(AccountShare share: acctShare){
                    if(u.id == share.userOrGroupId){
                        faeSharedAccounts.add(share);
                        break;
                    }
                }
            }
            
            for(Id acctId:accountIdSet){
                Set<Id> faeIdSet = new Set<Id>();
                for(AccountShare share:faeSharedAccounts){
                    if(acctId==share.accountId){
                        faeIdSet.add(share.userOrGroupId);
                    }
                }
                faesByAccount.put(acctId,faeIdSet);
            }
        }catch(Exception e){
            
        }
        return faesByAccount;
        
    }

    /***************************************************************************************************
    Method Name:  getCasesByAccount
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 14 Oct 2015
    Function    : This method is used to get FAEs associated to accounts
    Input Parameters: List of cases
    Output Parameters: Cases grouped by account
    Description:   This method takes list of cases and groups them by Account
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/14/2015              Created
    ****************************************************************************************************/    
    //change name to listCasesByAccount
    public static Map<Id,List<Id>> listCasesByAccount(List<Case> caseList){
        Map<Id,List<Id>> casesByAccount = new Map<Id,List<Id>>();
        for(case cs: caseList){
            List<Id> caseIdList = new List<Id>();
            Id accountId = cs.accountId;
            for(case cs1:caseList){
                if(cs1.accountId == accountId){
                    caseIdList.add(cs1.id);
                }
            }
            
            casesByAccount.put(accountId,caseIdList);
        }
        return casesByAccount;
    }

    /***************************************************************************************************
    Method Name:  getCasesByProject
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 14 Oct 2015
    Function    : This method is used to get FAEs associated to accounts
    Input Parameters: List of cases
    Output Parameters: Cases grouped by account
    Description:   This method takes list of cases and groups them by Account
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/14/2015              Created
    ****************************************************************************************************/    
    //change name to listCasesByAccount
    public static Map<Id,List<Id>> listCasesByProject(List<Case> caseList){
        Map<Id,List<Id>> casesByProject = new Map<Id,List<Id>>();
        for(case cs: caseList){
            List<Id> caseIdList = new List<Id>();
            Id projectId = cs.Core_IPS_Project_Case__c;
            for(case cs1:caseList){
                if(cs1.Core_IPS_Project_Case__c == projectId){
                    caseIdList.add(cs1.id);
                }
            }
            
            casesByProject.put(projectId,caseIdList);
        }
        return casesByProject;
        
    }
    
    
    /***************************************************************************************************
    Method Name:  getFAEsByProject
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 14 Oct 2015
    Function    : This method is used to get FAEs associated to accounts
    Input Parameters: Account ID Set
    Output Parameters: FAEs grouped by Account
    Description:   This method takes a set of project identifiers and returns the FAEs associated to those projects grouping them by project.
    Used in     : Asset sharing
    Number of Queries Within this Method: 1
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  2
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/14/2015              Created
    * JRK                        11/16/2015              Added null checks to prevent errors
    ****************************************************************************************************/     
    public static Map<id,Set<Id>> getFAEsByProject(set<id> projIdSet){
        List<core_ips_account__c> ipsAccountList = new List<core_ips_account__c>();
        //Map<Id,Set<Id>> assetsByProj = new Map<Id,Set<Id>>();
        /*set<id> projIdSet = new Set<Id>();
        //Project should be active
        for(asset ast: assetList){
            projIdSet.add(ast.Core_IPS_Project__c);
        }*/
        //assetsByProj = getAssetsByProject(assetList);
        //if(core_ips_account__c.SObjectType.getDescribe().isAccessible()){ //FLS check already added - Aditya
        ipsAccountList = [select id, core_account__c,core_ips_project__c from core_ips_account__c where core_ips_project__c in :projIdset];
        //}
        Map<Id, Set<id>> accountsByProject = new Map<Id,Set<id>>();
        Set<id> acctIdSet = new Set<Id>();
        for(core_ips_account__c ipsA:ipsAccountList){
            acctIdSet.Add(ipsA.core_account__c);
        }
        accountsByProject= ListAccountsByProject(ipsAccountList);
        Map<Id,set<Id>> faesByAccount = new Map<Id,Set<Id>>();
        faesByAccount=getFAEsByAccount(acctIdSet);
        Map<Id,Set<Id>> faesByProject = new Map<Id,Set<Id>>();
        //faesByProject = getFAEsByProj(accountsByProject, faesByAccount);
        //Set<Id> faeIdSet;
        for(id projId:accountsByProject.keySet()){
            Set<Id> faeIdSet = new Set<Id>();
            for(Id acctId:accountsByProject.get(projId)){
                if(faesByAccount.get(acctId) <> null){
                    for(Id userId:faesByAccount.get(acctId)){
                        faeIdSet.add(userId);
                    }
                }
            }
            if(faeIdSet <> null)
            faesByProject.put(projId,faeIdSet);
        }
        //assetShareList = getFAEAssetShareRecords(assetsByProj,faesByAccount);
        return faesByProject;
    }

    /***************************************************************************************************
    Method Name:  ListAccountsByProject
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 14 Oct 2015
    Function    : This method is used to get FAEs associated to accounts
    Input Parameters: Account ID Set
    Output Parameters: FAEs grouped by Account
    Description:   This method takes a list of ips accounts and groups them by project.
    Used in     : 
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/14/2015              Created
    ****************************************************************************************************/     
    public static Map<Id, Set<Id>> ListAccountsByProject(List<core_ips_account__c> ipsAccountList){
        Map<Id,Set<Id>> accountsByProject = new Map<Id,Set<Id>>();
            for(core_ips_account__c ipsAct:ipsAccountList){
                Set<id> actSet = new Set<id>();
                for(core_ips_account__c ipsAct1:ipsAccountList){
                    if(ipsAct.Core_IPS_Project__c==ipsAct1.Core_IPS_Project__c){
                        actSet.add(ipsAct1.core_account__c);
                    }
                }
                accountsByProject.put(ipsAct.Core_IPS_Project__c,actSet);
            }
        return accountsByProject;
    }

    /***************************************************************************************************
    Method Name:  listAssetsByProject
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 14 Oct 2015
    Function    : This method is used to group assets by project
    Input Parameters: Account ID Set
    Output Parameters: FAEs grouped by Account
    Description:   This method takes a list of assets and groups them by Project
    Used in     : 
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/14/2015              Created
    ****************************************************************************************************/      
    //Rename the method to ListAssetsByProject
    public static Map<Id,Set<Id>> listAssetsByProject(List<Asset> assetList){
        Map<Id,Set<Id>> assetsByProject = new Map<Id,Set<Id>>();
            for(asset ast:assetList){
                Set<id> astSet = new Set<id>();
                for(asset ast1:assetList){
                    if(ast.Core_IPS_Project__c==ast1.Core_IPS_Project__c){
                        astSet.add(ast1.id);
                    }
                }
                assetsByProject.put(ast.Core_IPS_Project__c,astSet);
            }
        return assetsByProject;
    }
    
    //Remove this method
    public static List<Asset> getAssets(List<String> idList){
            List<Asset> assetList;
            if(idList!=null && idList.get(0)!=null && idList.get(0).startsWith('001') && asset.SObjectType.getDescribe().isAccessible()){ //FLS Check Added -Aditya
                assetList = [SELECT ID, accountId, contactId, product2Id,Core_Supported_Product__c , Core_Product_Organization__c,Core_Map_List__c from asset where accountid in :idList]; 
            }
            return assetList;
    }

    /***************************************************************************************************
    Method Name:  getAssetsByAccount
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 14 Oct 2015
    Function    : This method is to group assets by Account
    Input Parameters: Account ID Set
    Output Parameters: FAEs grouped by Account
    Description:   This method takes a list of assets and groups them by Account
    Used in     : 
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/14/2015              Created
    ****************************************************************************************************/    
   //method should be renamed as listAssetsByAccount
   public static Map<Id,List<Id>> getAssetsByAccount(List<Asset> assetList){
        Map<Id,List<Id>> assetsByAccount = new Map<Id,List<Id>>();
        for(Asset ast: assetList){
            List<Id> assetIdList = new List<Id>();
            if(ast.accountId!=null){
                Id accountId = ast.accountId;
                for(asset ast1:assetList){
                    if(ast1.accountId == accountId){
                        assetIdList.add(ast1.id);
                    }
                }
                assetsByAccount.put(accountId,assetIdList);
            }
            
        }
        return assetsByAccount;
    }

    /***************************************************************************************************
    Method Name:  getIPSCustUsersbyAccounts
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 14 Oct 2015
    Function    : This method returns IPS Enabled users associated to accounts
    Input Parameters: Account ID Set
    Output Parameters: Users grouped by account
    Description:   This method takes a list of account identifiers and groups the IPS Users by Account
    Used in     : 
    Number of Queries Within this Method: 1
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/14/2015              Created
    ****************************************************************************************************/        
    public static Map<id,Set<id>> getIPSCustUsersbyAccounts(Set<Id> accountIds){
        Map<id,Set<id>> UsersbyAccount = new Map<id,Set<id>>();
        String userType=Label.Core_IPS_CustCommPlus_UserType;
        List<User> customerUsersbyAccount = [select id,ContactId,AccountId from User where AccountId In: accountIds and UserType=:userType and contact.core_ips_Active__c=true];
        Set<Id> UserIds;
        for(User recUser : customerUsersbyAccount){
            
            if(UsersbyAccount.containsKey(recUser.AccountId)){
                UserIds = UsersbyAccount.get(recUser.AccountId);
            }else{
                UserIds = new Set<Id>();
            }
            UserIds.add(recUser.id);
            if(!UserIds.isempty())
            UsersbyAccount.put(recUser.AccountId,UserIds);
        }
        return UsersbyAccount;  
    } 
    
    /***************************************************************************************************
    Method Name:  getFAEsofAccount
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 20 Nov 2015
    Function    : This method returns boolean value for PAR VF page Validation
    Input Parameters: List of Account Ids
    Output Parameters: Boolean value either True or False
    Description:   This method takes a list of Account Ids and checks if FAEs under that account and Users 
                   from list of profiles against the User in context to return true or false value
    Used in     : 
    Number of Queries Within this Method: 2
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        11/20/2015              Created
    ****************************************************************************************************/
    
    public Static boolean getFAEsofAccount(Account acc, List<String> UserInContext){
        Boolean ValueReturned;
        Set<Id> AccIdSet = new Set<Id>();
        AccIdSet.add(acc.id);
        Set<Id> accOwnerId = new Set<Id>();
        accOwnerId.add(acc.OwnerId);
        Map<Id,set<Id>> FAEIdtoAccountId = Core_IPS_Helper_Utility.getFAEsByAccount(AccIdSet);
        Set<Id> FAEIdSet = FAEIdtoAccountId.get(acc.id);    
        List<String> profileNameList = new List<String>();
        profileNameList = System.Label.Core_Validation_Profile_Names.split(';');
        Set<Id> AllUserIdSet = new Set<Id>();
        List<User> FAEUsrList = [Select id,Profile.Name from User where id IN: FAEIdSet];
        User Usr = [Select id,Profile.Name from User where id IN: UserInContext];        
        List<Profile> Prfl =  [Select id,Name from Profile where Name IN:profileNameList];
        // List<User> Owner = [Select id from User where id IN: accOwnerId];
        
        if(Usr != null ){       
            if(FAEUsrList != null){
                for(User FAEUsr: FAEUsrList){
                    if(Usr.id == FAEUsr.Id){
                        ValueReturned = true;
                    }
                }
            }
            if(Prfl!=null){
                for(Profile P: Prfl){                
                    if(P.name == Usr.Profile.Name){
                        ValueReturned = true;
                    }
                }
            }
            if(accOwnerId <> null){
                for(id onwerId: accOwnerId){
                    if(onwerId == Usr.Id){
                        ValueReturned = true;
                    }
                }
            }
        }
        return ValueReturned;
    }
    
    /***************************************************************************************************
    Method Name:  getOrgAdminsByOrg
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 20 Nov 2015
    Function    : This method returns boolean value for MAP VF page Validation
    Input Parameters: List of Supproted Product Organization Records
    Output Parameters: Boolean value either True or False
    Description:   This method takes a list of Supproted Product Organization Records and checks if admins under that Org and Users 
                   from list of profiles against the User in context to return true or false value
    Used in     : 
    Number of Queries Within this Method: 3
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        11/20/2015              Created
    ****************************************************************************************************/   
    public Static boolean getOrgAdminsByOrg(List<Core_IPS_Product_Organization__c> ProdOrgs ){
        Boolean ValueReturned;
        List<Id> POrgOwnerId = new List<Id>();
        for(Core_IPS_Product_Organization__c PrdOrg: ProdOrgs ){
            POrgOwnerId.add(PrdOrg.OwnerId);
        }

        List<Id> QueueMemberIds = listOwnerIdQueueMembers(POrgOwnerId);
        List<User> QueueUsers = [Select id,Profile.Name from User where id IN: QueueMemberIds];
        List<String> profileNameList = new List<String>();
        profileNameList = System.Label.Core_MAP_Validation_Profile_Names.split(';');    
        User Usr = [Select id,Profile.Name from User where id =: UserInfo.getUserid()]; 
        List<Profile> Prfl =  [Select id,Name from Profile where Name IN:profileNameList];
        if(Usr != null ){       
            if(QueueUsers != null){
                for(User QueueUsr: QueueUsers){
                    if(Usr.id == QueueUsr.Id){
                        ValueReturned = true;
                    }
                }
            }
            
            if(Prfl!=null){
                for(Profile P: Prfl){
                    if(P.name == Usr.Profile.Name){
                        ValueReturned = true;
                    }
                }
            }
        } 
        return ValueReturned;
    }

   
   /***************************************************************************************************
    Method Name:  isIPSCustomerUser
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 09 Oct 2015
    Function    : This function is used to Test if the logged in user is agent or not
    Input Parameters: contact ID Set
    Output Parameters: Intel support owner by contact
    Description:   This method checks if logged in user is IPS user or not
    Used in     : Internal and external case page controller
    Number of Queries Within this Method: 1
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/09/2015              Created
    ****************************************************************************************************/ 
    public static boolean isIPSCustomerUser(){
        boolean isAgent = false;
        User u = [select Id, username,contactid,userType from User where Id = :UserInfo.getUserId()];
        if((u.contactid != Null) ||(u.userType==Label.Core_IPS_CustCommPlus_UserType)){ // Added by PartnerProfile doc  //  
            isAgent=false;
        }else{
            isAgent=true;
        }
        return isAgent;
    }

   /***************************************************************************************************
    Method Name:  isGECAccount
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 09 Oct 2015
    Function    : Boolean. Returns true if loggedIn users account is MAG Account, else returns false
    Input Parameters: None
    Output Parameters: Boolean
    Description:   This function is used to Test if the logged in users account is MAG account
    Used in     : Internal and external case page controller
    Number of Queries Within this Method: 1
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/09/2015              Created
    ****************************************************************************************************/     
    public static boolean isGECAccount(){
        User Usr = [select contactId, contact.accountId, contact.account.Core_Military_Aerospace_and_Government__c from User where id = :UserInfo.getUserId() limit 1];
        if(usr!=null && usr.contactId!=null && usr.contact.accountId!=null && usr.contact.account.Core_Military_Aerospace_and_Government__c){
            return true;
        }
        return false;
    }
    
   /***************************************************************************************************
    Method Name:  isGECAccount
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 09 Oct 2015
    Function    : Boolean. Returns true if passed contact id's account is MAG Account, else returns false
    Input Parameters: None
    Output Parameters: Boolean
    Description:   This function is used to Test if the contact's account id is MAG account
    Used in     : Internal and external case page controller
    Number of Queries Within this Method: 1
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/09/2015              Created
    ****************************************************************************************************/   
    public static boolean isGECAccount(Id contId){
        List<Contact> contList = new List<Contact>();
        if(Contact.SObjectType.getDescribe().isAccessible()){ // FLS Check added by - aditya
        contList = [select accountId, account.Core_Military_Aerospace_and_Government__c from Contact where id = :contId limit 1];
        }
        if(contList != null && contList.size() > 0 && contList[0].accountId != null && contList[0].account.Core_Military_Aerospace_and_Government__c <> null && contList[0].account.Core_Military_Aerospace_and_Government__c){
            return true;
        }
        return false;
    }
    
    /***************************************************************************************************
    Apex Method Name: getIntelSupportOwnerByContact 
    Parameters : None
    Return Type: Id. Returns Intel support owner Id from Contact
    Version     : 1.0 
    Created Date: 09 Oct 2015
    Function    : This function returns intel support owners grouped by contacts.
    Used In     :
    Modification Log :
    Number of Queries Within this Method: 1
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/09/2015              Created
    * Sugandha                   07/09/2018              Modified(US# - US148966)
    ****************************************************************************************************/  
    public static List<Contact> getIntelSupportOwnerByContact_ResultList;
    public static List<String> getIntelSupportOwnerByContact_oldContIdList = new List<String>();
    public static List<String> getIntelSupportOwnerByContact_newContIdList = new List<String>();
    public static Map<id,id> getIntelSupportOwnerByContact(Set<String> contIdSet){
    
        Map<Id,Id> isoByContact = new Map<Id,Id>();
        Map<Id,Contact> ContactRecords = new Map<Id,Contact>();
        List<Id> contactIdslist = new List<Id>(); //Added logic as part of Code Refactor TWC745-6459
        if(contIdSet <> null && contIdSet.size() > 0){
            getIntelSupportOwnerByContact_newContIdList.clear();
            getIntelSupportOwnerByContact_newContIdList.addAll(contIdSet);
            //START - Added logic as part of Code Refactor TWC745-6459
            for(String c:contIdSet){
                contactIdslist.add(c);
            }
            //END
            if(getIntelSupportOwnerByContact_ResultList == null || Core_Utility.executeQuery(getIntelSupportOwnerByContact_newContIdList,getIntelSupportOwnerByContact_oldContIdList))
            {
                //added Alternate ISO and support org in query by Sugandha 
                //FLS check already added - Aditya
                //Added logic as part of Code Refactor TWC745-6459
                if(Core_IPS_CaseTriggerHandler.GlobalContactRecords!=null && Core_IPS_CaseTriggerHandler.GlobalContactRecords.size()>0 && !Core_IPS_CaseTriggerHandler.isQueryRequired(contactIdslist,Core_IPS_CaseTriggerHandler.GlobalContactRecords,null) ){
                    getIntelSupportOwnerByContact_ResultList = Core_IPS_CaseTriggerHandler.GlobalContactRecords.Values();
                }    
                else if(Contact.SObjectType.getDescribe().isAccessible()){
                    getIntelSupportOwnerByContact_ResultList = [select Id,Core_IPS_Intel_Support_Owner__c,Core_IPS_Alternate_Support_Owner__c,Core_IPS_Alternate_Support_Org__c from Contact where id in :contIdSet];
                }
                getIntelSupportOwnerByContact_oldContIdList.clear();
                getIntelSupportOwnerByContact_oldContIdList.addAll(contIdSet);
            }
        }
        if(getIntelSupportOwnerByContact_ResultList <> null && getIntelSupportOwnerByContact_ResultList.size() > 0){            
            //List<Contact> contList = [select Id,Core_IPS_Intel_Support_Owner__c from Contact where id in :contIdSet];
            for(Contact con:getIntelSupportOwnerByContact_ResultList){
                isoByContact.put(con.Id,con.Core_IPS_Intel_Support_Owner__c);
            }            
        }
        return isoByContact;
    }
    
    /***************************************************************************************************
    Apex Method Name: getIntelSupportOwner 
    Parameters : None
    Return Type: Id. Returns Intel support owner Id from Contact
    Version     : 1.0 
    Created Date: 09 Oct 2015
    Function    : This function is used to Test if the logged in users account is MAG account
    Used In     :
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/09/2015              Created
    ****************************************************************************************************/   
    //Remove this method as it is redundant
    public static Id getIntelSupportOwner(){
        User Usr = [select contactid, contact.Core_IPS_Intel_Support_Owner__c from User where id = :UserInfo.getUserId() limit 1];
        if(usr!=null && usr.contactId!=null && usr.contact.Core_IPS_Intel_Support_Owner__c!=null){
            return usr.contact.Core_IPS_Intel_Support_Owner__c;
        }
        return null;
    }
    
    /***************************************************************************************************
    Apex Method Name: isGECAccount 
    Parameters : Contact Id
    Return Type: Boolean. Returns true if contacts account is MAG Account, else returns false
    Version     : 1.0 
    Created Date: 09 Oct 2015
    Function    : This function is used to Test if contacts account is MAG account
    Used In     :
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/09/2015              Created
    ****************************************************************************************************/   
    //remove this also
    public static Id getIntelSupportOwner(Id contId){
        Contact cont;
        //FLS check added-Venugopal
        if(Contact.SObjectType.getDescribe().isAccessible()){
        	cont = [select Core_IPS_Intel_Support_Owner__c from Contact where id = :contId limit 1];
        }
        //contList = [select accountId, account.Core_Military_Aerospace_and_Government__c from Contact where id = :contId limit 1];
        if(cont != null && cont.Core_IPS_Intel_Support_Owner__c != null ){
            return cont.Core_IPS_Intel_Support_Owner__c;
        }
        return null;
    }

    //methodName
    public static boolean isHandlerMethodExecutionEnabled(String methodName){
        Core_Trigger_Executions__c triggerExecRecord = Core_Trigger_Executions__c.getValues(methodName);
        if(triggerExecRecord!=null && triggerExecRecord.Core_Active__c){
            return true;
        }else{
            return false;
        }
    }
    
    public static String getIPSLabel(String name){
        Core_IPS_Labels__c ipsLabel;
        //Added 
      // if(Core_IPS_Labels__c.SObjectType.getDescribe().isAccessible()){   
         ipsLabel = Core_IPS_Labels__c.getValues(name);
        // }
        if(ipsLabel!=null){
            return ipsLabel.Value__c;
        }else{
            return '';
        }
    }
    
    /***************************************************************************************************
    Apex Method Name: getIPSCustomerUsersByProject 
    Parameters : Project Id
    Return Type: Map of project Id with set of all Customer Users.
    Version     : 1.0 
    Created Date: 29 Oct 2015
    Function    : This function is used to return all Customer Users related to Project.
    Used In     :
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              10/29/2015              Created
    ****************************************************************************************************/
    
    public static Map<Id,Set<Id>> getIPSCustomerUsersByProject(Set<Id> projIdSet){
    Map<id,Core_IPS_Project__c> IPS_Projects = new Map<id,Core_IPS_Project__c>();
        if(projIdSet <> null && projIdSet.size() > 0){
            Map<Id,Set<Id>> projIdUserIdsMap = new Map<Id,Set<Id>>();
            if(Core_IPS_Project__c.SObjectType.getDescribe().isAccessible()){ //FLS Check already added - Aditya
            	IPS_Projects = new Map<id,Core_IPS_Project__c>([select id,(select id,Core_IPS_Contact__c,Core_User__c,core_status__c from Project_Members__r) from Core_IPS_Project__c where id IN:projIdSet]);
            }
                if(IPS_Projects <> null && IPS_Projects.size() > 0){
                for(Core_IPS_Project__c project: IPS_Projects.values()){
                    Set<id> userIds = new Set<id>();
                    for(Core_IPS_Project_Member__c recIPSmember :project.Project_Members__r){    
                        userIds.add(recIPSmember.Core_User__c);
                    }
                    projIdUserIdsMap.put(project.id,userIds);                           
                }           
            }
            if(projIdUserIdsMap <> null && projIdUserIdsMap.size() > 0)
                return projIdUserIdsMap;        
        }
        return null;
    }
    /***************************************************************************************************
    Method Name:  GetSetOfUsersbyQueueID 
    Method Type: Helper Method 
    Version     : 1.0 
    Created Date: 28 Oct 2015
    Function    : Returns all the users available in the Queue and the users available in the public groups which are assigned to the Queue directly. Second Level of nested public group is not handled in the code as business does not need.
    Input Parameters: QueueOrGrpId
    Output Parameters: Set of User Id's
    Description:   Returns all the users available in the Queue and the users available in the public groups which are assigned to the Queue directly. Second Level of nested public group is not handled in the code as business does not need.
    Used in     : used in Core_IssueCategoryController and Core_EnvironmentVariablesController Class
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       28/10/2015                Created
    ****************************************************************************************************/
    public static set<id> GetSetOfUsersbyQueueID(Id QueueOrGrpId){
        Set<Id> SetOfUserId = new Set<Id>();
        Set<Id> SetOfGrpId = new Set<Id>();
        if(QueueOrGrpId != null){
            if(QueueOrGrpId.getSObjectType() == group.SObjectType){
                for (GroupMember GrpMem : [Select GroupId, UserOrGroupId From GroupMember Where (GroupId =: QueueOrGrpId)]){
                    if(GrpMem.UserOrGroupId.getSObjectType() == group.SObjectType){
                        SetOfGrpId.add(GrpMem.UserOrGroupId);
                    }
                    else{
                        SetOfUserId.add(GrpMem.UserOrGroupId);
                    }
                }
                if(!SetOfGrpId.isEmpty()){
                    for (GroupMember GrpMem : [Select GroupId, UserOrGroupId From GroupMember Where (GroupId IN: SetOfGrpId)]){
                        if(GrpMem.UserOrGroupId.getSObjectType() == user.SObjectType){
                            SetOfUserId.add(GrpMem.UserOrGroupId);
                        }
                    }
                }
            }
            else if(QueueOrGrpId.getSObjectType() == user.SObjectType){
                SetOfUserId.add(QueueOrGrpId);
            }
        }
        return SetOfUserId;  
    }
    
    //gves the acc based on contact
    public static Map<Contact,Account> getAccountsfromContacts(List<Account> acctList, List<Contact> conList){
    //List<Account> acctList = Core_IPS_Project_Handler.getAccounts(existingAccountIdSet);
        //List<Contact> conList = [Select id,Core_IPS_Active__c,accountid from contact where accountid in: acctList];
        Map<Contact,Account> ContoAcc = new Map<Contact,Account>();
        for(Account acc: acctList){
            for(Contact con: conList){
                if(con.accountid == acc.id)
                ContoAcc.put(con,acc);
            }
        }
        return ContoAcc;
    }
    
    /***************************************************************************************************
    Method Name:  getCasesByAccount
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 07 Nov 2015
    Function    : This method is used to get Cases associated to accountIds
    Input Parameters: List of Account Ids
    Output Parameters: List of Case
    Description:   This method takes list of account and provide the Cases associated.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              11/07/2015              Created
    ****************************************************************************************************/    

    public static List<Case> getCasesByAccount(List<Id> accIdList){
        List<Case> casesList;
        if(accIdList <> null && accIdList.size() > 0){
            casesList = new List<Case>();
            if(Case.SObjectType.getDescribe().isAccessible()){ //FLS Check already added - Aditya
            	casesList = [select Id,AccountId from Case where AccountId in:accIdList];
            }
            return casesList;
        }   
        return null;
    }    
    
    
    public static List<Case> getNonProjectCasesByAccount(List<Id> accIdList){
        List<Case> casesList;
        if(accIdList <> null && accIdList.size() > 0 && Case.SObjectType.getDescribe().isAccessible()){ //FLS Check added - Aditya
            casesList = new List<Case>();
            casesList = [select Id,AccountId from Case where AccountId in:accIdList and Core_IPS_Project_Case__c=null];
            return casesList;
        }   
        return null;
    }   
    
    
    /***************************************************************************************************
    Method Name:  getCasesByProject
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 07 Nov 2015
    Function    : This method is used to get Cases associated to Project.
    Input Parameters: List of Project Ids
    Output Parameters: List of Case
    Description:   This method takes list of project ids and provide the Cases associated.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              11/07/2015              Created
    ****************************************************************************************************/    

    public static List<Case> getCasesByProject(Set<Id> projIdList){
        List<Case> casesList;
        if(projIdList <> null && projIdList.size() > 0){
            casesList = new List<Case>();
            if(Case.SObjectType.getDescribe().isAccessible()){
            	casesList = [select Id,Core_IPS_Project_Case__c from Case where Core_IPS_Project_Case__c in:projIdList];
            }
            return casesList;
        }   
        return null;
    }
    
    /***************************************************************************************************
    Method Name:  getShareCaseFromAccount
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 07 Nov 2015
    Function    : This method is used to get CaseId along with respective Set of Users..
    Input Parameters: List of Account Ids and Set of UserIds.
    Output Parameters: Map of CaseId and Set of UserIds. 
    Description:   This method takes list of account ids and set of userid set and return the CaseId v/s set of UserId Set.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              11/07/2015              Created
    ****************************************************************************************************/    

    public static Map<Id,Set<Id>> shareCaseMapFromAccount(Map<Id,Id> userIdaccIdMap){        
        Map<Id,Set<Id>> caseShareMap = new Map<Id,Set<Id>>();
        List<Case> csList = Core_IPS_Helper_Utility.getCasesByAccount(userIdaccIdMap.values());
        //If(userIdaccIdMap <> null && userIdaccIdMap.size() > 0 && Core_IPS_Helper_Utility.getCasesByAccount(userIdaccIdMap.values()) <> null && Core_IPS_Helper_Utility.getCasesByAccount(userIdaccIdMap.values()).size() > 0){
        If(userIdaccIdMap <> null && userIdaccIdMap.size() > 0 && csList <> null && csList.size() > 0){
            for(Case csObj:csList){
                caseShareMap.put(csObj.Id,userIdaccIdMap.keyset());
            }
        }
        return caseShareMap;
    }
    
    /***************************************************************************************************
    Method Name:  getShareCaseFromProject
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 07 Nov 2015
    Function    : This method is used to get CaseId along with respective Set of Users..
    Input Parameters: Set of Project Ids and Set of UserIds.
    Output Parameters: Map of CaseId and Set of UserIds. 
    Description:   This method takes set of project ids and set of userid set and return the CaseId v/s set of UserId Set.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              11/07/2015              Created
    ****************************************************************************************************/    

    public static Map<Id,Set<Id>> shareCaseMapFromProject(Map<Id,Id> userIdAccountIdMap){        
        Map<Id,Set<Id>> caseShareMap = new Map<Id,Set<Id>>();
        If(userIdAccountIdMap <> null && userIdAccountIdMap.size() > 0){
            Map<Id,Set<Id>> projIdUserIdMap = Core_IPS_Helper_Utility.shareProjectIdsUserMap(userIdAccountIdMap);
            if(projIdUserIdMap <> null && projIdUserIdMap.size() > 0 && Core_IPS_Helper_Utility.getCasesByProject(projIdUserIdMap.keyset()) <> null){
                for(Case csObj:Core_IPS_Helper_Utility.getCasesByProject(projIdUserIdMap.keyset())){
                    caseShareMap.put(csObj.Id,projIdUserIdMap.get(csObj.Core_IPS_Project_Case__c));
                }        
            }
        }
        return caseShareMap;
    }
    
    /***************************************************************************************************
    Method Name:  projectIdsUserMap
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 07 Nov 2015
    Function    : This method is used to get Map of UserId v/s related Project Id List.
    Input Parameters: Set of UserIds.
    Output Parameters: Map of UserId and List of ProjectId. 
    Description:   This method takes list of user ids and return the userId v/s list of ProjectId.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              11/18/2015              Created
    ****************************************************************************************************/    

    public static Map<Id,Set<Id>> shareProjectIdsUserMap(Map<Id,Id> userIdAccountIdMap){        
        Map<id,Set<Id>> projIdUserSetMap;
        List<Core_IPS_Project_Member__c> cpmList = new List<Core_IPS_Project_Member__c>();
        //FLS check added-Venugopal
        if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){ //FLS Check already added - Aditya
        	cpmList = [select id,Core_IPS_Project__c,Core_User__c from Core_IPS_Project_Member__c where Core_User__c in:userIdAccountIdMap.keyset()];                        
        }
        if(cpmList <> null && cpmList.size() > 0){            
            projIdUserSetMap = new Map<Id,Set<Id>>();
            for(Core_IPS_Project_Member__c cpmObj:cpmList){
                if(cpmObj.Core_IPS_Project__c <> null && userIdAccountIdMap <> null){
                    projIdUserSetMap.put(cpmObj.Core_IPS_Project__c,userIdAccountIdMap.keyset());
                }
            }
        }                                   
        return projIdUserSetMap;
    }            
    
    /***************************************************************************************************
    Method Name:  getShareAssetMapByUser
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 19 Nov 2015
    Function    : This method is used to get Assetid along with respective Set of Users..
    Input Parameters: Set of User Ids.
    Output Parameters: Map of AssetId and Set of UserIds. 
    Description:   This method takes Set of user ids and return the AssetId v/s set of UserId Set.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              11/19/2015              Created
    ****************************************************************************************************/    

    public static Map<Id,Set<Id>> getShareAssetMapByUser(Set<Id> userIdSet){
        List<AssetShare> astShareList = new List<AssetShare>();
        if(userIdSet <> null && userIdSet.size() > 0){
            if(AssetShare.SObjectType.getDescribe().isAccessible()){ //FLS Check already added 
            	astShareList = [Select Id,AssetId,UserOrGroupId from AssetShare where UserOrGroupId in:userIdSet];
            }
        }
        Map<Id,Set<Id>> assetShareMap = new Map<Id,Set<Id>>();
        Set<Id> usrSet;
        if(astShareList <> null && astShareList.size() > 0){            
            for(AssetShare astShareObj:astShareList){
                usrSet = new Set<Id>();
                for(AssetShare astShareObj1:astShareList){    
                    if(astShareObj.AssetId == astShareObj1.AssetId)
                    usrSet.add(astShareObj1.UserOrGroupId);
                }   
                assetShareMap.put(astShareObj.AssetId,usrSet);
            }
        }    
        return assetShareMap;
    }
    
    /***************************************************************************************************
    Method Name:  getShareCaseMapByUser
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 19 Nov 2015
    Function    : This method is used to get Caseid along with respective Set of Users..
    Input Parameters: Set of User Ids.
    Output Parameters: Map of CaseId and Set of UserIds. 
    Description:   This method takes Set of user ids and return the CaseId v/s set of UserId Set.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              11/19/2015              Created
    ****************************************************************************************************/    

    public static Map<Id,Set<Id>> getShareCaseMapByUser(Set<Id> userIdSet){
        List<String> rowCauseList = new List<String>();
        rowCauseList.add(getIPSLabel('RowCause_Team'));
        rowCauseList.add(getIPSLabel('Rowcause_Owner'));
        List<CaseShare> csShareList = new List<CaseShare>();
        if(userIdSet <> null && userIdSet.size() > 0){
            if(CaseShare.SObjectType.getDescribe().isAccessible()){ //FLS check already added - Aditya
            	csShareList = [Select Id,CaseId,UserOrGroupId from CaseShare where RowCause NOT IN: rowCauseList AND UserOrGroupId in:userIdSet];
            }
        }
        Map<Id,Set<Id>> caseShareMap = new Map<Id,Set<Id>>();
        Set<Id> usrSet;
        if(csShareList <> null && csShareList.size() > 0){            
            for(CaseShare csShareObj:csShareList){
                usrSet = new Set<Id>();
                for(CaseShare csShareObj1:csShareList){    
                    if(csShareObj.CaseId == csShareObj1.CaseId)
                    usrSet.add(csShareObj1.UserOrGroupId);
                }   
                caseShareMap.put(csShareObj.CaseId,usrSet);
            }
        }    
        return caseShareMap;
    }
    
    /***************************************************************************************************
    Method Name:  listOwnerIdQueueMembers
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 20 Nov 2015
    Function    : This method is used get Product org admins based on the queue they are under
    Input Parameters: List of Product Organization Owner Ids
    Output Parameters: List of UserIds. 
    Description:   This method takes the list of Owner Ids of Product Orgs and gives the list of Users
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        11/19/2015              Created
    ****************************************************************************************************/
    public static List<Id> listOwnerIdQueueMembers(List<Id> POrgOwnerId){
        List<GroupMember> publicGroupIds = new List<GroupMember>();
        List<GroupMember> QueueMemberIds = new List<GroupMember>();
        //if(GroupMember.SObjectType.getDescribe().isAccessible()){ //FLS check Commented
       		publicGroupIds = [SELECT userOrGroupId FROM GroupMember WHERE groupId IN: POrgOwnerId];
           // }
        List<Id> groupMemIds = new List<Id>();
        for(GroupMember gm : publicGroupIds){
            groupMemIds.add(gm.userOrGroupId);
        }
        //if(GroupMember.SObjectType.getDescribe().isAccessible()){ FLS Check Commented - Aditya
            QueueMemberIds = [SELECT userOrGroupId FROM GroupMember WHERE groupId In: groupMemIds];
        //}
        List<Id> actQueueMemIds = new List<ID>();
        for(groupmember  gm : queueMemberIds){
            actQueueMemIds.add(gm.userOrGroupId);
        }
        return actQueueMemIds;
    }     
    
    /***************************************************************************************************
    Method Name:  shareAssetMapByProjectMember
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 19 Nov 2015
    Function    : This method is used to get Assetid along with respective Set of Users..
    Input Parameters: Map of user Id v/s Account id.
    Output Parameters: Map of AssetId and Set of UserIds. 
    Description:   This method takes Set of project ids and return the AssetId v/s set of UserId Set.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              11/19/2015              Created
    ****************************************************************************************************/    

    public static Map<Id,Set<Id>> shareAssetMapByProjectMember(Map<Id,Id> userIdAccountIdMap){       
        Map<Id,Set<Id>> assetShareMap = new Map<Id,Set<Id>>();
        Set<Id> projIdSet;  
        List<Asset> astList = new List<Asset>();
        List<Core_IPS_Project_Member__c> cpmList = new List<Core_IPS_Project_Member__c>();
        if(userIdAccountIdMap <> null && userIdAccountIdMap.size() > 0){
            projIdSet = new Set<Id>();
            if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){ //FLS Check already added - Aditya
               cpmList = [select id,Core_IPS_Project__c,Core_User__c from Core_IPS_Project_Member__c where Core_User__c in:userIdAccountIdMap.keySet()];                        
            }
                if(cpmList <> null && cpmList.size() > 0){
                for(Core_IPS_Project_Member__c cpmObj:cpmList){                    
                    projIdSet.add(cpmObj.Core_IPS_Project__c);
                }
            }            
            if(projIdSet <> null && projIdSet.size() > 0){
                if(Asset.SObjectType.getDescribe().isAccessible()){
                astList = [Select Id,Core_IPS_Project__c from Asset where Core_IPS_Project__c in:projIdSet];                
                }
                if(astList <> null && astList.size() > 0){
                    for(Asset astObj:astList){
                        assetShareMap.put(astObj.Id,userIdAccountIdMap.keyset());
                    }   
                }
            }
        }                                    
        return assetShareMap;    
    }
    
    /***************************************************************************************************
    Method Name:  shareAssetMapByAccount
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 19 Nov 2015
    Function    : This method is used to get Assetid along with respective Set of Users..
    Input Parameters: Map of user Id v/s Account id.
    Output Parameters: Map of AssetId and Set of UserIds. 
    Description:   This method takes Set of project ids and return the AssetId v/s set of UserId Set.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              11/19/2015              Created
    ****************************************************************************************************/    

    public static Map<Id,Set<Id>> shareAssetMapByAccount(Map<Id,Id> userIdAccountIdMap){       
        Map<Id,Set<Id>> assetShareMap = new Map<Id,Set<Id>>();
        List<Asset> astList = new List<Asset>();
        if(userIdAccountIdMap <> null && userIdAccountIdMap.size() > 0){
            Set<id> userSet;
            List<Id> assetIdList;
            if(Asset.SObjectType.getDescribe().isAccessible()){
                astList = [Select Id,AccountId from Asset where AccountId in:userIdAccountIdMap.values()];  
            }
            if(astList <> null && astList.size() > 0){
                for(Asset astObj:astList){                    
                    assetShareMap.put(astObj.Id,userIdAccountIdMap.keyset());
                }   
            }                            
        }                                     
        return assetShareMap;    
    }   
    
    /***************************************************************************************************
    Method Name:  deleteProjectMembers
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 09 Dec 2015
    Function    : This method is used to delete the Project Members.
    Input Parameters: Map of UserId v/s AccountId.
    Output Parameters: none. 
    Description:   This method takes Map of user id and related AccountIds and delete the Project Member.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              12/09/2015              Created
    ****************************************************************************************************/    

    public static void deleteProjectMembers(Map<Id,Id> userIdAccountIdMap){        
        List<Core_IPS_Project_Member__c> cpmList = new List<Core_IPS_Project_Member__c>();
        List<Core_IPS_Project_Member__c> cpmListToUpdate = new List<Core_IPS_Project_Member__c>();
        if(userIdAccountIdMap <> null && userIdAccountIdMap.size() > 0 && userIdAccountIdMap.keyset() <> null){
            cpmList = [select id,Core_IPS_Project__c,Core_User__c,Core_Status__c from Core_IPS_Project_Member__c where Core_User__c in:userIdAccountIdMap.keyset()];                        
        }
        if(cpmList <> null && cpmList.size() > 0){            
            Core_IPS_Project_Member_Dispatcher.preventDelete = false; 
            /*US1038641 - 06/23/2021 - Yamini - CRUD Delete Check for security vulnerability --*/
            if (Core_IPS_Project_Member__c.sObjectType.getDescribe().isDeletable()) {    
              delete cpmList; 
            }
                       
        }                                                   
    }
    
    /***************************************************************************************************
    Method Name:  deactivateProjectMembers
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 09 Dec 2015
    Function    : This method is used to deactivate the Project Members.
    Input Parameters: Map of UserId v/s AccountId.
    Output Parameters: none. 
    Description:   This method takes Map of user id and related AccountIds and delete the Project Member.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              12/09/2015              Created
    ****************************************************************************************************/    

    public static void deactivateProjectMembers(Map<Id,Id> userIdAccountIdMap){        
        List<Core_IPS_Project_Member__c> cpmList = new List<Core_IPS_Project_Member__c>();
        List<Core_IPS_Project_Member__c> cpmListToUpdate = new List<Core_IPS_Project_Member__c>();
        if(userIdAccountIdMap <> null && userIdAccountIdMap.size() > 0 && userIdAccountIdMap.keyset() <> null){
            //FLS-check added -Venugopal
            if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){
            	cpmList = [select id,Core_IPS_Project__c,Core_User__c,Core_Status__c from Core_IPS_Project_Member__c where Core_User__c in:userIdAccountIdMap.keyset()];                        
        	}
        }
        if(cpmList <> null && cpmList.size() > 0){                        
            for(Core_IPS_Project_Member__c cpm : cpmList){
                /*US1021248 - 05/26/2021 - Vishal - FLS Check for security vulnerability --*/
               // if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Status__c.isUpdateable()) {
                    cpm.Core_Status__c = 'Inactive';
               // }
                cpmListToUpdate.add(cpm);
            }
        }
        //FLS Added as Part of code refactor
        if(Schema.sObjectType.Core_IPS_Project_Member__c.isUpdateable() && cpmListToUpdate <> null && cpmListToUpdate.size() > 0){
            update cpmListToUpdate;
            
        }                                           
    }
    
    /***************************************************************************************************
    Method Name:  createProjectMembers
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 09 Dec 2015
    Function    : This method is used to deactivate the Project Members.
    Input Parameters: Map of UserId v/s AccountId.
    Output Parameters: none. 
    Description:   This method takes Map of user id and related AccountIds and delete the Project Member.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              12/09/2015              Created
    ****************************************************************************************************/    

    public static void createProjectMembers(Map<Id,Id> userIdAccountIdMap){        
            List<Core_IPS_Account__c> projAccounts = new List<Core_IPS_Account__c>();
        if(userIdAccountIdMap <> null && userIdAccountIdMap.size() > 0){
            List<Core_IPS_Project_Member__c> cpmListToCreate = new List<Core_IPS_Project_Member__c>();        
            Map<Id,Id> userIdConIdMap = new Map<Id,Id>();
            Map<Id,Set<Id>> projectsandAccountMap = new Map<Id,Set<Id>>();
            List<User> userList = [select ContactId,Id,AccountId from User where Id in:userIdAccountIdMap.keyset()];            
            if(userList <> null && userList.size() > 0){
                for(User usrObj:userList){
                    if(usrObj.ContactId <> null)
                        userIdConIdMap.put(usrObj.Id,usrObj.ContactId);
                }
            }  
            if(Core_IPS_Account__c.SObjectType.getDescribe().isAccessible()){
                 projAccounts = [Select id, Core_Account__c, Core_IPS_Project__c, Core_Status__c from Core_IPS_Account__c where Core_Account__c IN: userIdAccountIdMap.values() and Core_Members__c ='All'];
            }
                if(projAccounts <> null && projAccounts.size()>0){
                Set<Id> projIdSet;
                Set<Id> accountIdSet = new Set<Id>();
                for(Core_IPS_Account__c projAcc: projAccounts){                   
                    projIdSet = new Set<Id>();
                    for(Core_IPS_Account__c projAcc1: projAccounts){
                        if(projAcc.Core_Account__c <> null && projAcc.Core_IPS_Project__c <> null && projAcc1.Core_Account__c <> null && projAcc1.Core_IPS_Project__c <> null && projAcc1.Core_Account__c == projAcc.Core_Account__c)
                            projIdSet.add(projAcc1.Core_IPS_Project__c);    
                    }
                    if(!accountIdSet.contains(projAcc.Core_Account__c)){
                        projectsandAccountMap.put(projAcc.Core_Account__c,projIdSet);
                        accountIdSet.add(projAcc.Core_Account__c);
                    }
                }   
            }
                        
            for(Id userId:userIdAccountIdMap.keyset()){
                if(userIdAccountIdMap.get(userId) <> null && projectsandAccountMap.get(userIdAccountIdMap.get(userId)) <> null){
                    for(Id projId : projectsandAccountMap.get(userIdAccountIdMap.get(userId))){
                        Core_IPS_Project_Member__c prjMem = new Core_IPS_Project_Member__c();
                       /*US1021248 - 05/26/2021 - Vishal - FLS Check for security vulnerability --*/
                        //if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_User__c.isCreateable()) {
                            prjMem.Core_User__c= userId;
                        //}
                        //if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Selective_Member__c.isCreateable()) {
                            prjMem.Core_Selective_Member__c= false;
                        //}
                        //if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Contact__c.isCreateable()) {
                            prjMem.Core_IPS_Contact__c = userIdConIdMap.get(userId);
                        //}
                        
                       // if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Status__c.isCreateable()) {
                            prjMem.Core_Status__c= 'Active';
                      //  }
                        if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Project__c.isCreateable()) {
                            prjMem.Core_IPS_Project__c = projId;
                        }
                        cpmListToCreate.add(prjMem);
                    }
                }
            }
            if(cpmListToCreate <> null && cpmListToCreate.size() > 0){
                if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isCreateable()) {
                     insert cpmListToCreate;
                }
            }
        }                                                                       
    }
    
    /***************************************************************************************************
    Method Name:  isIPSSalesUser
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 10 Dec 2015
    Function    : This function is used to Test if the logged in user is sales user or not
    Input Parameters: contact ID Set
    Output Parameters: Intel support owner by contact
    Description:   This method checks if logged in user is IPS user or not
    Used in     : Internal case page controller
    Number of Queries Within this Method: 1
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              Dec/10/2015              Created
    ****************************************************************************************************/ 
    public static boolean isIPSSalesUser(){
        boolean isSales = false;
        User u = [select Id, Profile.Name from User where Id = :UserInfo.getUserId()];
        for(String profileName : Label.Core_IPS_Sales_Profiles.split(';')){
            if(u.Profile.Name == profileName){
                isSales = true;
            }
        }
        return isSales;
    }
    
    
    //[Commented below method after discussion with JP.]
    /*public Static Map<String, List<Id>> compareAccountTeams(List<Core_Account_Team__c> oldList, List<AccountTeamMember> newList,Map<Id,String> caseAccessLevelMap){
        Map<String, List<Id>> updatedAccountTeams = new Map<String, List<Id>>();
        
        for(Core_Account_Team__c coreAcctTeam:oldList){
            for(AccountTeamMember acctTeam:newList){
                if(coreAcctTeam.Core_Team_Member__c==acctTeam.userId){
                    if(coreAcctTeam.Core_Case_Access__c!=caseAccessLevelMap.get(acctTeam.userId)){
                        
                    }
                }
                break;
            }
        }
        return null;
    }*/
    
    public static Set<Id> getFAEsFromUsers(Set<Id> userIdSet){
        List<String> profileNames = Label.Core_IPS_FAE_ProfileName.split(';');
        List<User> faeUsers = [select id from User where id in :userIdSet and profile.name IN: profileNames];
        Set<Id> faeUserSet = new Set<Id>();
        if(faeUsers<>null && faeUsers.size()>0){
            for(User uid:faeUsers)
                faeUserSet.add(uid.id);
            return faeUserSet;
        }else{
            return null;
        }
    }
    
    public static Map<Id,Set<id>> getProjectsByAccountId(Set<Id> acctIdSet){
        List<Core_IPS_Account__c> projAccountList = new List<Core_IPS_Account__c>();
        if(acctIdSet!=null){
            Map<Id,Set<Id>> projectsByAccountId = new Map<Id,Set<Id>>();
            //FLS-check added -Venugopal
            if(Core_IPS_Account__c.SObjectType.getDescribe().isAccessible()){
            	projAccountList = [select id,Core_Account__c,Core_IPS_Project__c,Core_Status__c from Core_IPS_Account__c where Core_Account__c in :acctIdSet];
            }
            if(projAccountList!=null){
                for(Id accId:acctIdSet){
                    Set<Id> projIdSet = new Set<Id>();
                    for(Core_IPS_Account__c pAcct:projAccountList){
                        if(accId==pAcct.Core_Account__c){
                            projIdSet.add(pAcct.Core_IPS_Project__c);
                        }
                    }
                    projectsByAccountId.put(accId,projIdSet);
                }
                return projectsByAccountId;
            }else{
                return null;
            }
        }else{
            return null;
        }
    }
    
    public static Map<Id,Set<Id>> getAssetsByAccountId(Set<Id> acctIdSet){
         List<asset> assetList = new List<asset>();
        if(acctIdSet!=null && acctIdSet.size()>0){
            Map<Id,Set<Id>> assetsByAccount = new Map<Id,Set<Id>>();
            //FLS check added - Venugopal
            if(Asset.SObjectType.getDescribe().isAccessible()){
            assetList = [select id,accountid from Asset where accountId in :acctIdSet];
            }
            if(assetList!=null && assetList.size()>0){
                for(Id acctId: acctIdSet){
                    Set<id> assetIdSet = new Set<Id>();
                    for(Asset ast:assetList){
                        if(ast.accountId==acctId){
                            assetIdSet.add(ast.id);
                        }
                    }
                    assetsByAccount.put(acctId,assetIdSet);
                }
                return assetsByAccount;
            }else{
                return null;
            }
        }else{
            return null;
        }
    }
    
    public static Map<Id,Set<Id>> getAssetsByProjectId(Set<Id> projectIdSet){
        List<asset> assetList = new List<asset>();
        if(projectIdSet!=null && projectIdSet.size()>0){
            Map<Id,Set<Id>> assetsByProject = new Map<Id,Set<Id>>();
            //FLS check added - Venugopal
            if(Asset.SObjectType.getDescribe().isAccessible()){
            	assetList = [select id,Core_IPS_Project__c from Asset where Core_IPS_Project__c in:projectIdSet];
            }
            if(assetList!=null && assetList.size()>0){
                for(Id projId: projectIdSet){
                    Set<id> assetIdSet = new Set<Id>();
                    for(Asset ast:assetList){
                        if(ast.Core_IPS_Project__c==projId){
                            assetIdSet.add(ast.id);
                        }
                    }
                    assetsByProject.put(projId,assetIdSet);
                }
                return assetsByProject;
            }else{
                return null;
            }
        }else{
            return null;
        }
    }
    
    public static Map<Id,Set<Id>> getPARsByAccountId(Set<Id> accountIdSet){
        List<Core_IPS_MAP_Account__c> parAccountList = new List<Core_IPS_MAP_Account__c>();
        if(accountIdSet!=null && accountIdSet.size()>0){
            Map<Id,Set<Id>> parsByAccountId = new Map<Id,Set<Id>>();
            //FLS check added-Venugopal
            if(Core_IPS_MAP_Account__c.SObjectType.getDescribe().isAccessible()){
            	parAccountList= [select Core_Account__c,Core_MAP_PAR__c,Core_MAP_PAR__r.RecordTypeId from Core_IPS_MAP_Account__c where Core_Account__c in :accountIdSet];            
            }
            //Map<ID,Schema.RecordTypeInfo> rt_Map = Core_IPS_MAP_PAR__c.sObjectType.getDescribe().getRecordTypeInfosByName();
            if(parAccountList!=null && parAccountList.size()>0){
                for(Id acctId: accountIdSet){
                    Set<id> parSet = new Set<Id>();
                    for(Core_IPS_MAP_Account__c par:parAccountList){
                        if(par.Core_Account__c==acctId){
                            for(String recTypeName : Label.Core_IPS_PAR_Record_Type_Name.split(',')){
                                if(par.Core_MAP_PAR__r <> null && par.Core_MAP_PAR__r.RecordTypeId <> null && par.Core_MAP_PAR__r.RecordTypeId == Core_IPS_MAP_PAR__c.sObjectType.getDescribe().getRecordTypeInfosByName().get(recTypeName).getRecordTypeId())
                                    parSet.add(par.Core_MAP_PAR__c);
                            }
                        }
                    }
                    if(parSet <> null && parSet.size() > 0)
                        parsByAccountId.put(acctId,parSet);
                }
                return parsByAccountId;
            }else{
                return null;
            }
        }else{
            return null;
        }
    }
    
    public static Map<Id,Set<Id>> getAccountIdsbyProjectId(Set<Id> projectIdSet){
        if(projectIdSet !=null && projectIdSet.size()>0){
            Map<Id,Set<Id>> accountIdsbyProjectId = new Map<Id,Set<Id>>();
            List<Core_IPS_Account__c> projAccountList = new List<Core_IPS_Account__c>();
            if(Core_IPS_Account__c.SObjectType.getDescribe().isAccessible()){
                projAccountList = [select Core_Account__c,Core_IPS_Project__c from Core_IPS_Account__c where Core_IPS_Project__c in :projectIdSet];
            }
                if(projAccountList!=null && projAccountList.size()>0){
                for(Id projId: projectIdSet){
                    Set<id> accountIdSet = new Set<Id>();
                    for(Core_IPS_Account__c acc:projAccountList){
                        if(acc.Core_IPS_Project__c == projId){
                            accountIdSet.add(acc.Core_Account__c);
                        }
                    }
                    accountIdsbyProjectId.put(projId,accountIdSet);
                }
                return accountIdsbyProjectId;
            }else{
                return null;
            }
        }else{
            return null;
        }
    }
    
    /***************************************************************************************************
    Method Name:  getIPSRecords
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Function    : This function is used to only consider the IPS related records.
    Input Parameters: sObject Name, List of records
    Output Parameters: List of IPS records
    Description:  This method is used to only consider the IPS related records.
    Used in     : All Dispatcher Classes
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              Feb/02/2016              Created
    ****************************************************************************************************/
    public static List<SObject> getIPSRecords(String sObjectName,List<SObject> records){
        List<SObject> ipsRecords;
        if(records <> null && records.size() > 0){            
            //[To get all RecordTypeIds on Case.]
            Map<ID,Schema.RecordTypeInfo> rt_Map = Schema.getGlobalDescribe().get(sObjectName).getDescribe().getRecordTypeInfosById();
            ipsRecords = new List<SObject>();
            Set<String> recordTypeNameSet = new Set<String>();
            recordTypeNameSet.addAll(System.Label.Core_IPS_RecordType_Names.split(';'));
            for(SObject rec:records){
                
                /*for(String recTypeName:System.Label.Core_IPS_RecordType_Names.split(';')){
                   if(rt_Map <> null && rec.get('RecordTypeId')<> null && rt_Map.get((ID)rec.get('RecordTypeId'))<>null && rt_Map.get((ID)rec.get('RecordTypeId')).getName() == recTypeName){
                       ipsRecords.add(rec);
                   } 
                }    */      
                if(rt_Map <> null && rec.get('RecordTypeId')<> null && rt_Map.get((ID)rec.get('RecordTypeId'))<>null && recordTypeNameSet.contains(rt_Map.get((ID)rec.get('RecordTypeId')).getName())){
                       ipsRecords.add(rec);
                   }
            }
        }
        
        if(ipsRecords <> null && ipsRecords.size() > 0)
            return ipsRecords;
        else
        return null;
    }        
}