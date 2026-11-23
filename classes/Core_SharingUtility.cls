public without sharing class Core_SharingUtility{

    public static boolean assetAccessFlag=false;  
    Public Static List<String> OldAccountIds = new List<String>(); // added by chiru Code Refactor
    Public Static List<String> OldUserRoleIds = new List<String>(); // Added by Chiru Code refactor
    Public Static List<UserRole> globalUserRoleRecords = new List<UserRole>();
    Public Static List<Group> globalGroupList = new List<Group>();
    /***************************************************************************************************
    Method Name:  provideAccess
    Method Type: Sharing Utility Method 
    Version     : 1.0 
    Created Date: 
    Function    : This method contains Sharing logic for User Id parameter of type Map<Id,Set<Id>>
    Input Parameters: Object Name, ShareTable Name,Record Access Level, Map of Set of User Ids and Object Ids 
    Output Parameters: None
    Description:   Used as a Generic Method to create Share Records for any type of Sobject
    Used in     : sharing of Records to Users
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JayaPrakash T                                       Created
    ****************************************************************************************************/    
     public static void provideAccess(String objectName, String shareTableName, string recordAccessLevel, MAP<id,Set<id>> recordUserList){
        List<sObject> shareRecords = new List<sObject>();
        Map<String, Schema.SObjectType> tokens = Schema.getGlobalDescribe();
        if(tokens.containsKey(shareTableName)) {
            for(Id obj : RecordUserList.keyset()){
                if(RecordUserList.get(obj) <> null){
                    for(Id uId: RecordUserList.get(obj)){
                        SObject share = tokens.get(shareTableName).newSObject();
                        if(objectName=='Asset'){
                            share.put('assetId', obj);
                            share.put('AssetAccessLevel',recordAccessLevel);
                        } else if(objectName=='Case'){
                            share.put('CaseId', obj);
                            share.put('CaseAccessLevel',recordAccessLevel);
                        }
                        else{
                           share.put('ParentId', obj);
                           share.put('AccessLevel',recordAccessLevel);
                        }
                        share.put('UserOrGroupId', uId);
                        share.put('RowCause', 'Manual');
                        shareRecords.add(share);
                    }
                }
            }
        try{
            Database.SaveResult[] shareInsertResult = Database.insert(shareRecords,false);
            for(Database.SaveResult sr:shareInsertResult){
               if(sr.isSuccess()){
                }
                else {
                   Database.Error err = sr.getErrors()[0];
                
                   if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                            err.getMessage().contains('AssetAccessLevel')){
                   }
                   else{
                   }
                 }
            }
        }   catch(Exception e){
        }
      } 
    }
    
   

    /***************************************************************************************************
    Method Name:  provideAccess
    Method Type: Sharing Utility Method 
    Version     : 1.0 
    Created Date: 7 Oct 2015
    Function    : This method contains Sharing logic for User Id parameter of type Map<Id,Id>
    Input Parameters: Object Name, ShareTable Name,Record Access Level, Map of User Ids and Object Ids 
    Output Parameters: None
    Description:   Used as a Generic Method to create Share Records for any type of Sobject
    Used in     : sharing of Records to Users
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        10/07/2015              Created
    ****************************************************************************************************/ 
    public static void provideAccess(String objectName, String shareTableName, string recordAccessLevel, MAP<id,id> RecordUserList){
        List<sObject> shareRecords = new List<sObject>();
        Map<String, Schema.SObjectType> tokens = Schema.getGlobalDescribe();
        if(tokens.containsKey(shareTableName)) {
            for(Id obj : RecordUserList.keyset()){
                SObject share = tokens.get(shareTableName).newSObject();
                if(objectName=='Asset'){
                    share.put('assetId', obj);
                    share.put('AssetAccessLevel',recordAccessLevel);
                } else if(objectName=='Case'){
                    share.put('CaseId', obj);
                    share.put('CaseAccessLevel',recordAccessLevel);
                }
                else{
                   share.put('ParentId', obj);
                   share.put('AccessLevel',recordAccessLevel);
                }
                //share.put('ParentId', obj);
                //share.put('AccessLevel',recordAccessLevel);
                share.put('UserOrGroupId', RecordUserList.get(obj));
                share.put('RowCause', 'Manual');
                shareRecords.add(share);
            } 
            
            Database.SaveResult[] shareInsertResult = Database.insert(shareRecords,false);
        } 
    }
    
     
    public static Sobject shareAssettoUser(ID userId, ID assetId){
        Map<String, Schema.SObjectType> tokens = Schema.getGlobalDescribe();
        SObject share = tokens.get('AssetShare').newSObject();
        share.put('assetId', assetId);
        share.put('UserOrGroupId', userId);
        share.put('AssetAccessLevel','Read');
        share.put('RowCause', 'Manual');
     return share;
    }
    
    /***************************************************************************************************
    Method Name:  RevokeAccess
    Method Type: Sharing Utility Method 
    Version     : 1.0 
    Created Date: 2 Nov 2015
    Function    : This method contains UnSharing logic
    Input Parameters: Object Name, ShareTable Name,List of User Ids 
    Output Parameters: None
    Description:   Used as a Generic Method to remove Share Records for any type of Sobject
    Used in     : Unsharing of Records from Users
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        11/02/2015              Created
    ****************************************************************************************************/ 
      
    public static void revokeAccess(String objectName, String shareTableName, Map<Id,Set<Id>> inactiveUserList){
        List<String> rowCauseList = new List<String>();
        rowCauseList.add(Core_IPS_Helper_Utility.getIPSLabel('RowCause_Team'));
        rowCauseList.add(Core_IPS_Helper_Utility.getIPSLabel('Rowcause_Owner'));
        rowCauseList.add(Core_IPS_Helper_Utility.getIPSLabel('Rowcause_Rule'));
        rowCauseList.add(Core_IPS_Helper_Utility.getIPSLabel('Rowcause_RelatedProtalUser'));
        List<sObject> shareRecords = new List<sObject>();
        List<Id> assetIds = new List<Id>();
        List<Id> caseIds = new List<Id>();
        List<Id> customObjIds = new List<Id>();
        List<Id> inactiveUserIds = new List<Id>();
        List<sObject> sObjectShares = new List<sObject>();
        Map<String, Schema.SObjectType> tokens = Schema.getGlobalDescribe();
        if(tokens.containsKey(shareTableName)) {
            for(Id objId: InactiveUserList.keyset()){
                for(Id userId: InactiveUserList.get(objId)){
                    if(objectName=='Asset'){
                        AssetIds.add(objId);
                    } else if(objectName=='Case'){
                        CaseIds.add(objId);
                    }
                    else{
                       CustomObjIds.add(objId);
                    }
                    InactiveUserIds.add(UserId);
                }
            }
            if(AssetIds <> null && AssetIds.size()>0 && InactiveUserIds <> null && InactiveUserIds.size()>0){
                SObjectShares = Database.Query('select id,UserorGroupId from  '+shareTableName.escapeHtml4()+ ' where UserOrGroupId IN: InactiveUserIds and AssetId IN: AssetIds and RowCause Not In:rowCauseList');
            }
            if(CaseIds <> null && CaseIds.size()>0 && InactiveUserIds <> null && InactiveUserIds.size()>0) {
                SObjectShares = Database.Query('select id,UserorGroupId from  '+shareTableName.escapeHtml4()+ ' where UserOrGroupId IN: InactiveUserIds and CaseId IN: CaseIds and RowCause Not In:rowCauseList');
            }if(CustomObjIds <> null && CustomObjIds.size()>0 && InactiveUserIds <> null && InactiveUserIds.size()>0) {
                SObjectShares = Database.Query('select id,UserorGroupId from  '+shareTableName.escapeHtml4()+ ' where UserOrGroupId IN: InactiveUserIds and ParentId IN: CustomObjIds and RowCause Not In:rowCauseList');
            }
            if(SObjectShares <> null && SObjectShares.size()>0){
                if (Schema.sObjectType.Asset.isDeletable() || Schema.sObjectType.Case.isDeletable() ) {
                delete SObjectShares;
                }
            }
        } 
    }
    
    /***************************************************************************************************
    Method Name:  RevokeAccess
    Method Type: Sharing Utility Method 
    Version     : 1.0 
    Created Date: 2 Nov 2015
    Function    : This method contains UnSharing logic only for future call
    Input Parameters: Object Name, ShareTable Name,JSON String 
    Output Parameters: None
    Description:   Used as a Generic Method to remove Share Records for any type of Sobject
    Used in     : Unsharing of Records from Users
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              12/22/2015              Created
    ****************************************************************************************************/
    @future  
    public static void revokeAccess(String objectName, String shareTableName, String inactiveUserMap){        
        List<String> rowCauseList = new List<String>();
        rowCauseList.add(Core_IPS_Helper_Utility.getIPSLabel('RowCause_Team'));
        rowCauseList.add(Core_IPS_Helper_Utility.getIPSLabel('Rowcause_Owner'));
        rowCauseList.add(Core_IPS_Helper_Utility.getIPSLabel('Rowcause_Rule'));
        rowCauseList.add(Core_IPS_Helper_Utility.getIPSLabel('Rowcause_RelatedProtalUser'));
        List<sObject> shareRecords = new List<sObject>();
        List<Id> assetIds = new List<Id>();
        List<Id> caseIds = new List<Id>();
        List<Id> customObjIds = new List<Id>();
        List<Id> inactiveUserIds = new List<Id>();
        List<sObject> sObjectShares = new List<sObject>();
        Map<Id,Set<Id>> deserializedInactiveUser = (Map<Id,Set<Id>>)JSON.deserialize(InactiveUserMap, Map<Id,Set<Id>>.class);
        
        Map<String, Schema.SObjectType> tokens = Schema.getGlobalDescribe();
        if(tokens.containsKey(shareTableName)) {
            for(Id objId: deserializedInactiveUser.keyset()){
                for(Id userId: deserializedInactiveUser.get(objId)){
                    if(objectName=='Asset'){
                        AssetIds.add(objId);
                    } else if(objectName=='Case'){
                        CaseIds.add(objId);
                    }else{
                       CustomObjIds.add(objId);
                    }
                    InactiveUserIds.add(UserId);
                }
            }
            if(AssetIds <> null && AssetIds.size()>0 && InactiveUserIds <> null && InactiveUserIds.size()>0) {
                SObjectShares = Database.Query('select id,UserorGroupId from  '+shareTableName.escapeHtml4()+ ' where UserOrGroupId IN: InactiveUserIds and AssetId IN: AssetIds and RowCause Not In:rowCauseList');
            }if(CaseIds <> null && CaseIds.size()>0 && InactiveUserIds <> null && InactiveUserIds.size()>0) {
                SObjectShares = Database.Query('select id,UserorGroupId from  '+shareTableName.escapeHtml4()+ ' where UserOrGroupId IN: InactiveUserIds and CaseId IN: CaseIds and RowCause Not In:rowCauseList');
            }if(CustomObjIds <> null && CustomObjIds.size()>0 && InactiveUserIds <> null && InactiveUserIds.size()>0) {
                SObjectShares = Database.Query('select id,UserorGroupId from  '+shareTableName.escapeHtml4()+ ' where UserOrGroupId IN: InactiveUserIds and ParentId IN: CustomObjIds and RowCause Not In:rowCauseList');
            }
            if(SObjectShares <> null && SObjectShares.size()>0){
                if (Schema.sObjectType.Asset.isDeletable() || Schema.sObjectType.Case.isDeletable() ) {
                delete SObjectShares;
                }
            }
        } 
       
    }
    
    /***************************************************************************************************
    Method Name:  RevokeAccess
    Method Type: Sharing Utility Method 
    Version     : 1.0 
    Created Date: 2 Nov 2015
    Function    : This method contains UnSharing logic only for future call
    Input Parameters: Object Name, ShareTable Name,JSON String 
    Output Parameters: None
    Description:   Used as a Generic Method to remove Share Records for any type of Sobject
    Used in     : Unsharing of Records from Users
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        12/22/2015              Created
    ****************************************************************************************************/
    public static void revokeAccess(String objectName, String shareTableName, Map<Id,Id> inactiveUserMap){        
        List<String> rowCauseList = new List<String>();
        rowCauseList.add(Core_IPS_Helper_Utility.getIPSLabel('RowCause_Team'));
        rowCauseList.add(Core_IPS_Helper_Utility.getIPSLabel('Rowcause_Owner'));
        rowCauseList.add(Core_IPS_Helper_Utility.getIPSLabel('Rowcause_Rule'));
        rowCauseList.add(Core_IPS_Helper_Utility.getIPSLabel('Rowcause_RelatedProtalUser'));
        List<sObject> shareRecords = new List<sObject>();
        List<Id> assetIds = new List<Id>();
        List<Id> caseIds = new List<Id>();
        List<Id> customObjIds = new List<Id>();
        List<Id> inactiveUserIds = new List<Id>();
        List<sObject> sObjectShares = new List<sObject>();
        // Map<Id,<Id>> deserializedInactiveUser = (Map<Id,Set<Id>>)JSON.deserialize(InactiveUserMap, Map<Id,Set<Id>>.class);
        
        
        Map<String, Schema.SObjectType> tokens = Schema.getGlobalDescribe();
        if(tokens.containsKey(shareTableName)) {
            for(Id objId: InactiveUserMap.keyset()){
                if(objectName=='Asset'){
                    AssetIds.add(objId);
                } else if(objectName=='Case'){
                    CaseIds.add(objId);
                } 
                
                else{
                   CustomObjIds.add(objId);
                }
                InactiveUserIds.add(InactiveUserMap.get(objId));
                
            }
            if(AssetIds <> null && AssetIds.size()>0 && InactiveUserIds <> null && InactiveUserIds.size()>0){
                SObjectShares = Database.Query('select id,UserorGroupId from  '+shareTableName.escapeHtml4()+ ' where UserOrGroupId IN: InactiveUserIds and AssetId IN: AssetIds and RowCause Not In:rowCauseList');
            }if(CaseIds <> null && CaseIds.size()>0 && InactiveUserIds <> null && InactiveUserIds.size()>0){
                SObjectShares = Database.Query('select id,UserorGroupId from  '+shareTableName.escapeHtml4()+ ' where UserOrGroupId IN: InactiveUserIds and CaseId IN: CaseIds and RowCause Not In:rowCauseList');
            }if(CustomObjIds <> null && CustomObjIds.size()>0 && InactiveUserIds <> null && InactiveUserIds.size()>0){
                SObjectShares = Database.Query('select id,UserorGroupId from  '+shareTableName.escapeHtml4()+ ' where UserOrGroupId IN: InactiveUserIds and ParentId IN: CustomObjIds and RowCause Not In:rowCauseList');
            }if(SObjectShares <> null && SObjectShares.size()>0){
                if (Schema.sObjectType.Asset.isDeletable() || Schema.sObjectType.Case.isDeletable() ) {
                delete SObjectShares;
                }
            }
        } 
    }
    
    //Fixed User Role empty if no portal user is present
   /* public static Map<Id,Set<Id>> getCustomerUserRoleIdsByAccountId(Set<Id> accountIdSet) {
        List<UserRole> lstUserRole;
        List<String> NewAccountIds = new List<String>();
         for(Id idVal : accountIdSet) {
           NewAccountIds.add(String.valueOf(idVal));
         } 
       
        //if(UserRole.SObjectType.getDescribe().isAccessible()){
        // Condition Added by chiru Code Refactor
        if(!NewAccountIds.isEmpty() && ( Core_Utility.executeQuery(NewAccountIds,OldAccountIds))){
      
        lstUserRole = new List<UserRole>([SELECT Id,Name,DeveloperName,PortalAccountId FROM UserRole WHERE PortalAccountId IN : accountIdSet]);
        globalUserRoleRecords = new List<userRole> (lstUserRole);
        OldAccountIds = new List<String>(NewAccountIds);
        
        } else if(globalUserRoleRecords != null && !globalUserRoleRecords.isEmpty()){
           lstUserRole = new List<UserRole>(globalUserRoleRecords);
        }
        //END
        //}
        Map<id,Set<id>> userRolesbyAccount = new Map<id,Set<id>>();        
        if(lstUserRole <> null && lstUserRole.size() > 0){
            for(UserRole objUsrRole : lstUserRole) {
                if(objUsrRole.DeveloperName.contains('CustomerUser') || objUsrRole.DeveloperName.contains('PartnerUser')) {
                    if(!userRolesbyAccount.containsKey(objUsrRole.PortalAccountId)){
                        userRolesbyAccount.put(objUsrRole.PortalAccountId, new Set<Id>());                        
                    } 
                    userRolesbyAccount.get(objUsrRole.PortalAccountId).add(objUsrRole.Id);
                }
            }
        }        
        return userRolesbyAccount;
    }*/
    
  
    public static Map<Id,Set<Id>> getCustomerUserRoleIdsByAccountId(Set<Id> accountIdSet){
        String userType=Label.Core_IPS_CustCommPlus_UserType;
        String partnerUserType = Label.Core_IPS_Partner_Community_User_Type;
        // Added by PartnerProfile doc
        List<String> userTypelst = new List<String>();
        UserTypelst.add (userType);
        UserTypelst.add (partnerUserType);
        // End by PartnerProfile doc
        List<User> customerUsersbyAccount = [select id,ContactId,AccountId,userroleid from User where AccountId In: accountIdSet and UserType=:userTypelst and contact.core_ips_Active__c=true];
        Map<id,Set<id>> userRolesbyAccount = new Map<id,Set<id>>();
        Set<Id> userRoleIds;
        if(customerUsersbyAccount <> null && customerUsersbyAccount.size() > 0){
            for(User recUser : customerUsersbyAccount){
                if(userRolesbyAccount.containsKey(recUser.AccountId)){
                    userRoleIds = userRolesbyAccount.get(recUser.AccountId);
                }else{
                userRoleIds = new Set<Id>();
                }
                userRoleIds.add(recUser.userroleid);                   
                if(!userRoleIds.isempty())
                    userRolesbyAccount.put(recUser.AccountId,userRoleIds);
            }
        }        
        return userRolesbyAccount;
    }
    
    public static Map<id,Set<id>> getGroupIdsByRoleId(List<Id> userRoleIdSet){
        // Code Refactor Changes Added By Chiru - 
        // Start
        List<String> newUserRoleIds  = new List<String>();
        for(Id idVal : userRoleIdSet) {
           newUserRoleIds.add(String.valueOf(idVal));
         } 
        //END
        Map<id,Set<id>> groupIdsByRoleId = new Map<id,Set<id>>();
        if(userRoleIdSet <> null && userRoleIdSet.size() > 0){
            // Start --> Added FLS for Query by Chiru
          
            List<Group> groupList = new List<Group>();
            if(!newUserRoleIds.isEmpty() && ( Core_Utility.executeQuery(newUserRoleIds,OldUserRoleIds))){
             
            //List<Group> groupList = [select id,developername,relatedid from Group where relatedid in :userRoleIdSet and type in ('role')];
              groupList = [select id,developername,relatedid from Group where relatedid in :userRoleIdSet and type in ('role')];
               globalGroupList = new List<Group>(groupList);
                OldUserRoleIds = new List<String>(newUserRoleIds);
            } else if(globalGroupList != null && !globalGroupList.isEmpty()){
               groupList = new List<group> (globalGroupList); 
            }
            //END
            if(groupList <> null && groupList.size() > 0){
                for(id userRoleId:userRoleIdSet){
                    Set<Id> groupIdSet = new Set<Id>();
                    for(Group grp:groupList){
                        if(grp.relatedId==userRoleId){
                            groupIdSet.add(grp.id);
                        }                        
                    }
                    if(groupIdSet.size() > 0){
                        groupIdsByRoleId.put(userRoleId,groupIdSet);
                    }    
                }
            }
        }
        if(groupIdsByRoleId <> null && groupIdsByRoleId.size() > 0){
            return groupIdsByRoleId;
        }  
        else{
            return null;
        }    
    }
   
    public static Map<id,Set<id>> getGroupIdByProject(Set<id> projIdSet){
        return null;
    }    
    
    public static void revokeProjectAccess(Map<Id,Set<Id>> deserializedInactiveUser){
        if(deserializedInactiveUser!=null && deserializedInactiveUser.size()>0){
            //Map<Id,Set<Id>> deserializedInactiveUser = (Map<Id,Set<Id>>)JSON.deserialize(InactiveUserMap, Map<Id,Set<Id>>.class);
            Map<Id,Set<Id>> accountsByProjId = new Map<Id,Set<Id>>();
            accountsByProjId=Core_IPS_Helper_Utility.getAccountIdsbyProjectId(deserializedInactiveUser.keySet());
            Set<Id> acctIdSet = new Set<Id>();
            for(id projId: accountsByProjId.keySet()){
                for(id acctId:accountsByProjId.get(projId)){
                    acctIdSet.add(acctId);
                }
            }
            Map<id,Set<Id>> faesByAccount = new Map<Id,Set<Id>>();
            faesByAccount = Core_IPS_Helper_Utility.getFAEsByAccount(acctIdSet);
            Map<id,Set<Id>> validFaesByProj = new Map<Id,Set<Id>>();
            
            for(Id projId:deserializedInactiveUser.keySet()){
                Set<Id> invalidfaeIds = new Set<Id>();
                Set<Id> validfaeIds = new Set<Id>();
                for(Id userId:deserializedInactiveUser.get(projId)){
                    Integer count=0;
                    for(id acctId: accountsByProjId.get(projId)){
                        for(id faeId:faesByAccount.get(acctId)){
                            if(faeId==userId){
                               count++;
                            }
                        }
                        if(count>1){
                           break;
                        }
                    }
                    if(count>1){
                       invalidfaeIds.add(userId);
                    }else{
                        validfaeIds.add(userId);
                    }
                }
                if(validFaeIds.size()>0){
                   validFaesByProj.put(projId,validfaeIds);
                }   
            }
            revokeAccess('Core_IPS_Project__c','Core_IPS_Project__Share',validFaesByProj);
        }
    }
    
   
}