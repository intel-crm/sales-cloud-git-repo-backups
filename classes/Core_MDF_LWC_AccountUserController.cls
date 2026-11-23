/****************************************************************************************************************************************
 * Class Name  : Core_MDF_LWC_AccountUserController
 * Version     : 1.0
 * Created Date: 10-24-2019
 * Modification Log :
 * Developer                 Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Accenture - Krishna      10/24/2019          Class for handling Partner Node User Mapping object bulk record creation/deletion from LWC.
 * Intel	 - Areefa		05/12/2020			Return null value removed and add return result
 * Intel	 - Areefa		05/29/2020			add new method for create and Edit access check
*****************************************************************************************************************************************/
//DO NOT REMOVE WITH SHARING
public with sharing class Core_MDF_LWC_AccountUserController {
    /*****************************************************************************************************
     Method Name:        getResults
     @return  :          List<SObjectResult>
     @parameters:        String searchObjectName, String searchFieldName, String value
     Description:        To Fetch Account or User values on type ahead lookup
     Added By:           Accenture - KK - 10/24/2019
     ******************************************************************************************************/
    @AuraEnabled
    public static List<SObjectResult> getResults(String searchObjectName, String searchFieldName, String value, String programName) {
        String sanitizedSearchObjectName = String.escapeSingleQuotes(searchObjectName);
        String sanitizedSearchFieldName = String.escapeSingleQuotes(searchFieldName);
        String sanitizedValue = String.escapeSingleQuotes(value);
        if(programName != null && programName.length()>0){
            String sanitizedProgramName = String.escapeSingleQuotes(programName);
        }
        List<SObjectResult> sObjectResultList = new List<SObjectResult>();
        String query='';
        if(sanitizedSearchObjectName == 'Account') {
            String recordType = System.Label.Core_MDF_Co_Marketing_Record_Type_Developer_Name;
            query = 'Select Id,'+sanitizedSearchFieldName+' FROM '+sanitizedSearchObjectName+' WHERE '+sanitizedSearchFieldName+' LIKE \'%' + sanitizedValue + '%\' AND RecordType.DeveloperName = :recordType AND Core_MDF_Active_Ind__c = true AND Core_MDF_Channel_Program__c = :sanitizedProgramName';
        }else if(sanitizedSearchObjectName == 'User') {
            String partnerUser = System.Label.Core_MDF_Partner_User_Type;
            query = 'Select Id,'+sanitizedSearchFieldName+' FROM '+sanitizedSearchObjectName+' WHERE '+sanitizedSearchFieldName+' LIKE \'%' + sanitizedValue + '%\' AND UserType = :partnerUser AND IsActive = true';
        }
        if(String.isNotEmpty(sanitizedValue) && String.isNotEmpty(query)) {
            for(sObject record : Database.Query(query)) {
                String fieldvalue = (String)record.get(sanitizedSearchFieldName);
                sObjectResultList.add(new SObjectResult(fieldvalue, record.Id));
            }
        }

        return sObjectResultList;
    }
    /*****************************************************************************************************
     Class Name:         SObjectResult
     Description:        Wrapper Class for type ahead search
     Added By:           Accenture - KK - 10/24/2019
     ******************************************************************************************************/
    public class SObjectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;

        public SObjectResult(String recNameTemp, Id recIdTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
        }
    }
    /*****************************************************************************************************
     Method Name:        fetchUserInfo
     @return  :          String - User Type
     @parameters:        -
     Description:        To fetch user information
     Added By:           Accenture - KK - 10/24/2019
     ******************************************************************************************************/
    @AuraEnabled
    public static String fetchUserInfo() {
        String usrType = UserInfo.getUserType();
        return usrType;
    }
    /*****************************************************************************************************
     Method Name:        fetchUserAccessiblePrograms
     @return  :          Map - Program Id To Program Name
     @parameters:        -
     Description:        To fetch user accessible programs
     Added By:           Accenture - KK - 12/16/2019
     ******************************************************************************************************/
    @AuraEnabled
    public static Map<Id,String> fetchUserAccessiblePrograms() {
        Map<Id,String> programMap = new map<Id,String>();
        for(ChannelProgram p:[select Id, toLabel(Core_MDF_Technical_Program_Name__c) from ChannelProgram order by Name]){
            programMap.put(p.Id,p.Core_MDF_Technical_Program_Name__c);
        }
        return programMap;
    }
    /*****************************************************************************************************
     Method Name:        findSelectedUsers
     @return  :          UserInfoWrapper
     @parameters:        Id accountId
     Description:        to get available users
     Added By:           Accenture - KK - 10/24/2019
     ******************************************************************************************************/
    @AuraEnabled
    public static UserInfoWrapper findSelectedUsers(Id accountId) {
        UserInfoWrapper userInfoWrap = new UserInfoWrapper();
        //map to show at left
        Map<Id, String> totalUserIdToUserNameMap = new Map<Id, String>();
        //map to show at right
        Map<Id, String> existingUserIdToUserNameMap = new Map<Id, String>();
        List<Core_MDF_Partner_Node_User_Mapping__c> accUserList = [SELECT Id, Core_MDF_Account__c, Core_MDF_User__c, Core_MDF_User__r.Name FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_Account__c =:accountId AND Core_MDF_User__r.IsActive = true AND Core_MDF_User__r.UserType =:Label.Core_MDF_Partner_User_Type AND Core_MDF_Account__r.Core_MDF_Active_Ind__c = true order by name];
        //To get already mapped Account Users
        for(Core_MDF_Partner_Node_User_Mapping__c accountUserRecord: accUserList) {
            existingUserIdToUserNameMap.put(accountUserRecord.Core_MDF_User__c, accountUserRecord.Core_MDF_User__r.Name);
        }
        //To get total available partner users
        for(user userRecord: [SELECT Id, Name FROM user where IsActive = true AND UserType =: Label.Core_MDF_Partner_User_Type order by name]) {
            totalUserIdToUserNameMap.put(userRecord.Id, userRecord.Name);//Label.Core_MDF_Partner_User_Type
        }
        userInfoWrap.toShowAtLeft = totalUserIdToUserNameMap;
        userInfoWrap.toShowAtRight = existingUserIdToUserNameMap;
        return userInfoWrap;
    }
     /*****************************************************************************************************
     Method Name:        saveMapping
     @return  :          String - Exception if occured
     @parameters:        Id recordId, List<Id> objectListToBeProcessed, String objectName
     Description:        To save account to user mapping
     Added By:           Accenture - KK - 10/24/2019
     ******************************************************************************************************/
    @AuraEnabled
    public static String saveAccountUserMapping(Id accountOrUserId, List<Id> objectListToBeProcessed, String mappingType, String programName) {
        String returnValue = '';
        try{
            String sanitizedProgramName = '';
            if(programName != null && programName.length()>0){
            	sanitizedProgramName = String.escapeSingleQuotes(programName);
        	}
                        
            if(mappingType == 'AccountToUser') {
                returnValue = saveAccountToUserMapping(accountOrUserId, objectListToBeProcessed, mappingType);
            }else{
                returnValue = saveUserToAccountMapping(accountOrUserId, objectListToBeProcessed, mappingType, sanitizedProgramName);
            }
            return returnValue; }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e); throw e;}  //return e.getMessage();
    }
    
    public static String saveAccountToUserMapping(Id accountOrUserId, List<Id> objectListToBeProcessed, String mappingType) {
        try{
        Savepoint sp = Database.setSavepoint();
        Map<Id, String> userIdToUserNameMap = new Map<Id, String>();
        String exceptionMessage = '';
        String exceptionMessageTemp = '';
        String result = '';
        Database.deleteResult[] drList;
        Database.saveResult[] srList;
        Boolean saveResultError = false;
        List<Id> usrListToDeleteAccountUsers = new List<Id>();
        List<Id> usrListToCreateAccountUsers = new List<Id>();
        List<Id> toDeleteAccountUsers = new List<Id>();
        Map<Id, Core_MDF_Partner_Node_User_Mapping__c> userIdToAccountUserMap = new Map<Id, Core_MDF_Partner_Node_User_Mapping__c>();
        Core_MDF_Partner_Node_User_Mapping__c createAccountUserInstance;
        List<Core_MDF_Partner_Node_User_Mapping__c> createAccountUserList = new List<Core_MDF_Partner_Node_User_Mapping__c>();

        List<Core_MDF_Partner_Node_User_Mapping__c> existingAccountUserList = [select Id, Core_MDF_Account__c, Core_MDF_User__c, Core_MDF_User__r.Name from Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_Account__c =:accountOrUserId AND Core_MDF_User__r.IsActive = true AND Core_MDF_Account__r.Core_MDF_Active_Ind__c = true];
        for(Core_MDF_Partner_Node_User_Mapping__c accountUserRecord : existingAccountUserList) {
            userIdToAccountUserMap.put(accountUserRecord.Core_MDF_User__c, accountUserRecord);
        }

        //Collect user Ids whos mapping needs to be deleted
        for(Id usrId: userIdToAccountUserMap.KeySet()) {
            if(!objectListToBeProcessed.contains(usrId)) {
                usrListToDeleteAccountUsers.add(usrId);
            }
        }
        //To make UserId To UserName Map for final exception
        List<User> tempUserList = [select Id, Name from user where id in:usrListToDeleteAccountUsers];
        for(user userRecord:tempUserList) {
            userIdToUserNameMap.put(userRecord.Id, userRecord.Name);
        }
        //Creating Account User List to be deleted
        for(Id usrId : usrListToDeleteAccountUsers) {
            if(userIdToAccountUserMap.Keyset().contains(usrId)) {
                if(!toDeleteAccountUsers.contains(userIdToAccountUserMap.get(usrId).Id)) {
                    toDeleteAccountUsers.add(userIdToAccountUserMap.get(usrId).Id);
                }
            }
        }

        //Creating Account User List to insert & Collect user Ids for exception handling
        for(Id usrId: objectListToBeProcessed) {
            if(!userIdToAccountUserMap.KeySet().contains(usrId)) {
                usrListToCreateAccountUsers.add(usrId);
                createAccountUserInstance = new Core_MDF_Partner_Node_User_Mapping__c();
                createAccountUserInstance.Core_MDF_User__c = usrId;
                createAccountUserInstance.Core_MDF_Account__c = accountOrUserId;
                createAccountUserList.add(createAccountUserInstance);
            }
        }
        //To make UserId To UserName Map for final exception
        List<User> tempUsrList = [select Id, Name from user where id in:usrListToCreateAccountUsers];
        for(user userRecord:tempUsrList) {
            userIdToUserNameMap.put(userRecord.Id, userRecord.Name);
        }
        //inserting account users
        if(createAccountUserList != null && !createAccountUserList.isEmpty()) {
            srList = database.insert(createAccountUserList, false);
            List<id> idList = new List<id>();
            List<String> errorStringList = new List<String>();
            for (Database.saveResult sr : srList) {
                if (sr.isSuccess() && (sr.getId() != null)) {
                    idList.add(sr.getId());
                }else{ saveResultError = true;
                    for(Database.Error err : sr.getErrors()) {
                        if(!errorStringList.contains(err.getMessage())) {errorStringList.add(err.getMessage());}
                    }
                }
            }
            List<Core_MDF_Partner_Node_User_Mapping__c> failAccountUserList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
            for(Core_MDF_Partner_Node_User_Mapping__c accUser:createAccountUserList) {
                if(!idList.contains(accUser.Id)) {
                    failAccountUserList.add(accUser);
                }
            }

            for(Core_MDF_Partner_Node_User_Mapping__c a:failAccountUserList) {
                exceptionMessageTemp = exceptionMessageTemp + userIdToUserNameMap.get(a.Core_MDF_User__c)+';';
            }
            exceptionMessage = 'Users - ' + exceptionMessageTemp + ' Errors - ' + errorStringList;
        }
        //deleting account users if insertion successful
        if(!saveResultError && toDeleteAccountUsers != null && !toDeleteAccountUsers.isEmpty()) {
            Core_MDF_AccountUser_Controller.deleteAccountUsers(toDeleteAccountUsers);
        }

        if(saveResultError) { Database.rollback(sp);
            Core_MDF_CCP_UtilityClass.logErrorinLogObject(exceptionMessage, 'AccountUser');
            result = exceptionMessage;
        }
        return result;
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e); throw e; }        
    }
    
    public static String saveUserToAccountMapping(Id accountOrUserId, List<Id> objectListToBeProcessed, String mappingType, String sanitizedProgramName) {
        try{
        Savepoint sp = Database.setSavepoint();
        Map<Id, String> accountIdToAccountNameMap = new Map<Id, String>();
        String exceptionMessage = '';
        String exceptionMessageTemp = '';
        String result ='' ;
        Database.deleteResult[] drList;
        Database.saveResult[] srList;
        Boolean saveResultError = false;
        List<Id> accListToDeleteAccountUsers = new List<Id>();
        List<Id> accListToCreateAccountUsers = new List<Id>();
        List<Id> toDeleteAccountUsers = new List<Id>();
        Map<Id, Core_MDF_Partner_Node_User_Mapping__c> accountIdToAccountUserMap = new Map<Id, Core_MDF_Partner_Node_User_Mapping__c>();
        Core_MDF_Partner_Node_User_Mapping__c createAccountUserInstance;
        List<Core_MDF_Partner_Node_User_Mapping__c> createAccountUserList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
        List<Core_MDF_Partner_Node_User_Mapping__c> existingAccountUserList = [select Id, Core_MDF_Account__c, Core_MDF_User__c, Core_MDF_Account__r.Name from Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_User__c =:accountOrUserId AND Core_MDF_User__r.IsActive = true AND Core_MDF_Account__r.Core_MDF_Active_Ind__c = true AND Core_MDF_Account__r.Core_MDF_Channel_Program__c = :sanitizedProgramName];
        //To get existing account Ids mapped with this user
        for(Core_MDF_Partner_Node_User_Mapping__c accountUser : existingAccountUserList) {
            accountIdToAccountUserMap.put(accountUser.Core_MDF_Account__c, accountUser);
        }
        //Collect account Ids whose mapping needs to be deleted
        for(Id accId: accountIdToAccountUserMap.keyset()) {
            if(!objectListToBeProcessed.contains(accId)) {
                accListToDeleteAccountUsers.add(accId);
            }
        }
        //To get account id to account name map for exception handling
        List<Account> tempAccountList = [select Id, Name from account where id in:accListToDeleteAccountUsers];
        for(Account accRecord:tempAccountList) {
            accountIdToAccountNameMap.put(accRecord.Id, accRecord.Name);
        }

        //To get list of account users to be deleted
        for(Id accId : accListToDeleteAccountUsers) {
            if(accountIdToAccountUserMap.keyset().contains(accId)) {
                if(!toDeleteAccountUsers.contains(accountIdToAccountUserMap.get(accId).Id)) {
                    toDeleteAccountUsers.add(accountIdToAccountUserMap.get(accId).Id);
                }
            }
        }
        //Collect account Ids whose mapping needs to be created
        for(Id accId: objectListToBeProcessed) {
            if(!accountIdToAccountUserMap.keyset().contains(accId)) {
                accListToCreateAccountUsers.add(accId);
                createAccountUserInstance = new Core_MDF_Partner_Node_User_Mapping__c();
                createAccountUserInstance.Core_MDF_Account__c = accId;
                createAccountUserInstance.Core_MDF_User__c = accountOrUserId;
                createAccountUserList.add(createAccountUserInstance);
            }
        }
        //To Maintain Account Id to Account Name Map for Exception Handling
        List<Account> tempAccList = [select Id, Name from account where id in:accListToCreateAccountUsers];
        for(Account accRecord:tempAccList) {
            accountIdToAccountNameMap.put(accRecord.Id, accRecord.Name);
        }
        //inserting account user list
        if(createAccountUserList != null && !createAccountUserList.isEmpty()) {
            srList = database.insert(createAccountUserList, false);
            List<id> idList = new List<id>();
            List<String> errorStringList = new List<String>();
            for (Database.saveResult sr : srList) {
                if (sr.isSuccess() && (sr.getId() != null)) {
                    idList.add(sr.getId());
                }else{ saveResultError = true;
                    for(Database.Error err : sr.getErrors()) {
                        if(!errorStringList.contains(err.getMessage())) { errorStringList.add(err.getMessage()); }
                    }
                }
            }
            List<Core_MDF_Partner_Node_User_Mapping__c> failAccountUserList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
            for(Core_MDF_Partner_Node_User_Mapping__c accUser:createAccountUserList) {
                if(!idList.contains(accUser.Id)) {
                    failAccountUserList.add(accUser);
                }
            }
            for(Core_MDF_Partner_Node_User_Mapping__c a:failAccountUserList) {
                exceptionMessageTemp = exceptionMessageTemp + accountIdToAccountNameMap.get(a.Core_MDF_Account__c)+';';
            }
            exceptionMessage = 'Accounts - ' + exceptionMessageTemp + ' Errors - ' + errorStringList;
        }
        //to delete account users if insertion successful
        if(!saveResultError && toDeleteAccountUsers != null && !toDeleteAccountUsers.isEmpty()) {
            Core_MDF_AccountUser_Controller.deleteAccountUsers(toDeleteAccountUsers);
        }
        if(saveResultError) { Database.rollback(sp);
            Core_MDF_CCP_UtilityClass.logErrorinLogObject(exceptionMessage, 'AccountUser');
            result = exceptionMessage;
        }
        return result;
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e); throw e; }
    }
    
    
    /*****************************************************************************************************
     Method Name:        UserInfoWrapper
     Description:        wrapper for showing data in dual list box
     Added By:           Accenture - KK - 10/24/2019
     ******************************************************************************************************/
    public class UserInfoWrapper{
        @AuraEnabled
        public Map<Id, String> toShowAtLeft;
        @AuraEnabled
        public Map<Id, String> toShowAtRight;
    }
     /*****************************************************************************************************
     Method Name:        findSelectedAccounts
     @return  :          UserInfoWrapper
     @parameters:        Id userId
     Description:        to get available accounts when user is searched for user to account mapping
     Added By:           Accenture - KK - 10/24/2019
     ******************************************************************************************************/
    @AuraEnabled
    public static UserInfoWrapper findSelectedAccounts(Id userId, String programName) {
        UserInfoWrapper userInfoWrap = new UserInfoWrapper();
        //map to show at left
        Map<Id, String> totalAccountIdToAccountNameMap = new Map<Id, String>();
        // map to show at right
        Map<Id, String> existingAccountIdToAccountNameMap = new Map<Id, String>();
        //to get existing mapped accounts
        for(Core_MDF_Partner_Node_User_Mapping__c accountUserRecord: [SELECT Id, Core_MDF_Account__c, Core_MDF_User__c, Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Name, Core_MDF_Account__r.Name FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_User__c =:userId AND Core_MDF_User__r.IsActive = true AND Core_MDF_Account__r.RecordType.DeveloperName =: Label.Core_MDF_Co_Marketing_Record_Type_Developer_Name AND Core_MDF_Account__r.Core_MDF_Active_Ind__c = true AND Core_MDF_Account__r.Core_MDF_Channel_Program__c =:programName]) {
            existingAccountIdToAccountNameMap.put(accountUserRecord.Core_MDF_Account__c, accountUserRecord.Core_MDF_Account__r.Name+' - '+accountUserRecord.Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Name);
        }
        //To get total accounts
        for(Account accRecord: [SELECT Id, Name, Core_MDF_Parent_Fund_Account__r.Name FROM Account Where RecordType.DeveloperName =: Label.Core_MDF_Co_Marketing_Record_Type_Developer_Name  AND Core_MDF_Active_Ind__c = true AND Core_MDF_Channel_Program__c =:programName]) {
            totalAccountIdToAccountNameMap.put(accRecord.Id, accRecord.Name+' - '+accRecord.Core_MDF_Parent_Fund_Account__r.Name);
        }
        userInfoWrap.toShowAtLeft = totalAccountIdToAccountNameMap;
        userInfoWrap.toShowAtRight = existingAccountIdToAccountNameMap;
        return userInfoWrap;
    }
    /*****************************************************************************************************
     Method Name:        isAccountUserEligibleForCreateEdit
     @return  :          boolean
     @parameters:        
     Description:        check user is having access to create and Edit Permission on the Core_MDF_Partner_Node_User_Mapping__c Object
     Added By:           Intel - Areefa - 05/29/2020
     ******************************************************************************************************/
    @AuraEnabled
    public static boolean isAccountUserEligibleForCreateEdit(){

        try{
            //check user is having access to create and Edit Permission on the Core_MDF_Partner_Node_User_Mapping__c Object
            boolean hasCreatAccess = Core_MDF_checkSObjectCRUDPermission.checkSObjectCreatePermission('Core_MDF_Partner_Node_User_Mapping__c');
            boolean hasEditAccess = Core_MDF_checkSObjectCRUDPermission.checkSObjectEditPermission('Core_MDF_Partner_Node_User_Mapping__c');
            if(hasCreatAccess && hasEditAccess)
            {   return true;  }
            else
            {   return false; }   }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e; } 
    }
}