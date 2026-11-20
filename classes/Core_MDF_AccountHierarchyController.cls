/****************************************************************************************************************************************
* Class Name  : Core_MDF_AccountHierarchyController 
* Version     : 1.0 
* Created Date: 10-Mar-2020
* Modification Log :
* Developer                 Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Pranav       10-Mar-2021         It contains Methods related To Fetching Accounts Data of a particular hierarchy to display
in a tree view
*****************************************************************************************************************************************/

public without sharing class Core_MDF_AccountHierarchyController {
    
    /*This Method Returns Base URL of the current Salesforce environment*/
    @AuraEnabled
    public static String fetchSalesforceBaseURL(){
        //String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
        return URL.getOrgDomainUrl().toExternalForm() + '/';
    }
    
    /*It Fetches All the Ultimate/Intel Accounts that are Comarketing Active for the logged In user's Context*/
    /*It Check Whether logged in User has any role that requires IUPGM then It will fetch Only those acccounts that is mapped to user */
    /*Else If User Does not require IUPGM then All the Ultimate accounts will be returned*/
    @AuraEnabled(cacheable = true)
    public static List<Account> fetchUltimateAccounts(){
        List<String> listOfIUPGMRoleValues = getIUPGMRolePickListValues();
        Boolean loggedInUserHasIUPGMReqdRole = checkLoggedInUserhasReqdRole(listOfIUPGMRoleValues);
        Boolean isCSCUser = FeatureManagement.checkPermission('Core_MDF_Internal_CSC_User'); 
        
        //List<Account> ultimateAccountList = new List<Account>();
        //List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        //List<String> listOfIUPGMRoleValues = new List<String>();
        //Boolean loggedInUserHasIUPGMReqdRole = false;
        //Set<Id> ultimateAccountIds = new Set<Id>();
        
        // Fetching IUPGM Role Picklist Values 
        //listOfIUPGMRoleValues = getIUPGMRolePickListValues();
        // Method to check If logged In User has IUPGM Required role
        //loggedInUserHasIUPGMReqdRole = checkLoggedInUserhasReqdRole(listOfIUPGMRoleValues);
        //String recType = 'Core_MDF_Co_Marketing';
        List<String> recTypeList = new List<String>{'Mastered_Account', 'Inactive_Account'};
        //Boolean isCSCUser = FeatureManagement.checkPermission('Core_MDF_Internal_CSC_User'); 
        // Dynamic Query to Fetch Ultimate Accounts
        String accountQuery = 'Select Id, Name FROM Account Where RecordType.DeveloperName IN:recTypeList AND Core_MDF_CoMarketingActive__c = true ';        
        
        /*if(loggedInUserHasIUPGMReqdRole){
            Boolean iupgmAllAccountsFlag = false;
            List<String> channelProgramsList = new List<String>();
            // Querying All Accounts that are mapped with the logged In User through IUPGM
            if(!isCSCUser){
                iupgmList = [SELECT Core_MDF_Account_id__c,Core_MDF_Program_nm__c,Core_MDF_All_Accounts_cd__c, Core_MDF_Account_id__r.Core_MDF_CoMarketingActive__c,Core_MDF_Account_id__r.RecordType.DeveloperName, Core_MDF_Account_id__r.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_User_id__c FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c WHERE Core_MDF_User_id__c =: Userinfo.getUserId() AND Core_MDF_User_id__r.IsActive = true AND Core_MDF_Active_Ind__c = true];
                if(iupgmList != NULL && iupgmList.size()>0){
                    // Adding Ultimate Accounts in a Set
                    for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmList){
                        // If All Accounts field on iupgm is set to Yes then set the boolean to true and Add the Programs into List
                        if(iupgm.Core_MDF_All_Accounts_cd__c == Label.Core_MDF_NonTranslateYes){
                            channelProgramsList.add(iupgm.Core_MDF_Program_nm__c);
                            iupgmAllAccountsFlag = true;
                        }
                        else{
                            if(iupgm.Core_MDF_Account_id__r.RecordType.DeveloperName != 'Core_MDF_Co_Marketing'){
                                if(iupgm.Core_MDF_Account_id__c != NULL){
                                    ultimateAccountIds.add(iupgm.Core_MDF_Account_id__c);
                                }
                            }
                            else{
                                if(iupgm.Core_MDF_Account_id__r.Core_MDF_CoMarketing_Ultimate_Account__c != NULL){
                                    ultimateAccountIds.add(iupgm.Core_MDF_Account_id__r.Core_MDF_CoMarketing_Ultimate_Account__c);
                                }
                            }
                        }
                    }                
                }
                
            }
            else{
                Core_MDF_AccountHierarchyController_Sharing accHierarchy = new Core_MDF_AccountHierarchyController_Sharing();
                channelProgramsList.addAll(accHierarchy.getChannelProgram());
            }            
            // If AllAccounts flag is true then Add the Account's ultimateAccounts for the Program for which this flag is set to true          
            if(iupgmAllAccountsFlag || isCSCUser){
                for(Account acc :[SELECT Id, Core_MDF_CoMarketing_Ultimate_Account__c FROM Account WHERE Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c IN: channelProgramsList and Core_MDF_CoMarketing_Ultimate_Account__c != NULL]){ //ATHR Fix 
                    //if(acc.Core_MDF_CoMarketing_Ultimate_Account__c != NULL){//ATHR Comment
                        ultimateAccountIds.add(acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                    //}
                }                
            }
            // Appending into dynamic query to fetch only those Ultimate Accounts that are mapped to the logged in User 
            accountQuery += 'AND Id IN :ultimateAccountIds ';
        }  */
        
        Set<Id> ultimateAccountIds = new Set<Id>();
        if (loggedInUserHasIUPGMReqdRole) {
            ultimateAccountIds = getIUPGMUserAccountIds(isCSCUser);
            accountQuery += 'AND Id IN :ultimateAccountIds ';
        }
        accountQuery += 'order by Name';
        // Final Query
        return Database.query(string.escapeSingleQuotes(accountQuery));
    }
    
    public static Set<Id> getIUPGMUserAccountIds(Boolean isCSCUser) {
        Set<Id> accountIds = new Set<Id>();
        Set<String> channelPrograms = new Set<String>();
        Boolean includeAllAccounts = false;

        if (isCSCUser) {
            channelPrograms.addAll(new Core_MDF_AccountHierarchyController_Sharing().getChannelProgram());
        } else {
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> mappings = [SELECT Core_MDF_Account_id__c,Core_MDF_Program_nm__c,Core_MDF_All_Accounts_cd__c, Core_MDF_Account_id__r.Core_MDF_CoMarketingActive__c,Core_MDF_Account_id__r.RecordType.DeveloperName, Core_MDF_Account_id__r.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_User_id__c FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c WHERE Core_MDF_User_id__c =: Userinfo.getUserId() AND Core_MDF_User_id__r.IsActive = true AND Core_MDF_Active_Ind__c = true];            
            for (Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : mappings) {
                // If All Accounts field on iupgm is set to Yes then set the boolean to true and Add the Programs into List
                if (iupgm.Core_MDF_All_Accounts_cd__c == Label.Core_MDF_NonTranslateYes) {
                    channelPrograms.add(iupgm.Core_MDF_Program_nm__c);
                    includeAllAccounts = true;
                    continue;
                }                
                if (iupgm.Core_MDF_Account_id__r != null) {
                    if (iupgm.Core_MDF_Account_id__r.RecordType.DeveloperName == 'Core_MDF_Co_Marketing' && iupgm.Core_MDF_Account_id__r.Core_MDF_CoMarketing_Ultimate_Account__c != null) {
                        accountIds.add(iupgm.Core_MDF_Account_id__r.Core_MDF_CoMarketing_Ultimate_Account__c);
                    } else {
                        accountIds.add(iupgm.Core_MDF_Account_id__c);
                    }
                }
            }                        
        }
        if ((includeAllAccounts || isCSCUser) && !channelPrograms.isEmpty()) {
            for (Account acc : [SELECT Core_MDF_CoMarketing_Ultimate_Account__c FROM Account WHERE Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c IN: channelPrograms and Core_MDF_CoMarketing_Ultimate_Account__c != NULL]) {
                accountIds.add(acc.Core_MDF_CoMarketing_Ultimate_Account__c);
            }
        }        
        return accountIds;
    }
    
    /*It fetches all the Accounts of a hierarchy except for the Ultimate Account*/
    @AuraEnabled
    public static List<Account> fetchChildAccounts(String ultimateAccountId){
        if(String.isBlank(ultimateAccountId)){return new List<Account>();}
        List<Account> finalAccountList= new List<Account>();
        List<Id> activeAccIdList = new List<Id>();
        Set<Id> finalAccIdList = new Set<Id>();
        Map<Id,Account> idToAccountRecordMap= new map<Id,Account>();
        Map<Id,Boolean> idToaccountActiveMap = new map<id,Boolean>();
        Map<Id,Id> childParentMap = new map<Id,Id>();
        try{
            // Querying All the Child Accounts for an Ultimate Account
            //if(ultimateAccountId != null){
            for(Account acc : [Select Name,Id,Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_CoMarketing_Ultimate_Account__r.Name,Core_MDF_Parent_Fund_Account__c, Core_MDF_CoMarketingActive__c, RecordType.DeveloperName,Core_MDF_Active_Ind__c,Core_MDF_Parent_Fund_Account__r.RecordType.DeveloperName,Core_MDF_Channel_Program__r.Name 
                               from Account Where (Id =: ultimateAccountId OR Core_MDF_CoMarketing_Ultimate_Account__c =: ultimateAccountId) order by Name]){
                //collecting all the accounts which are already Active
                if(acc.Core_MDF_Active_Ind__c == true){
                    activeAccIdList.add(acc.id);
                }
                //to get ultimate account ids
                //checks if ultimate acc id already not present and acc's parent and ultimate both same acc - means its VC
                /*if(acc.Core_MDF_CoMarketing_Ultimate_Account__c != null && !finalAccIdList.contains(acc.Core_MDF_CoMarketing_Ultimate_Account__c) && acc.Core_MDF_CoMarketing_Ultimate_Account__c == acc.Core_MDF_Parent_Fund_Account__c){//already present check
                    finalAccIdList.add(acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                }*/
                //map to hold Account Record wrt the accountIds
                idToAccountRecordMap.put(acc.id,acc);
                //map to hold Account Id and its active/inactive status
                //idToaccountActiveMap.put(acc.id,acc.Core_MDF_Active_Ind__c);  
                //map to hold accountId and its parentId
                childParentMap.put(acc.id,acc.Core_MDF_Parent_Fund_Account__c);
                
            }
            //in the final list adding all the active account - because those we need to show anyways
            finalAccIdList.add(Id.valueOf(ultimateAccountId));
            finalAccIdList.addAll(activeAccIdList);
            //looping over all active account list to make sure that each active node is present in the finalList of accounts regardless of the accounts active/inactive status
            /*for(integer i=0;i<activeAccIdList.size();i++){
                
                id accId = childParentMap.get(activeAccIdList[i]);//assuming its on fifth level getting forth level acc
                
                if(idToaccountActiveMap.get(accId) == false){
                    if(!finalAccIdList.contains(accId)){
                        finalAccIdList.add(accId);
                    }
                    accId = childParentMap.get(accId);//from fourth getting third level acc
                    if(accId == null){
                        continue;
                    }
                    if(idToaccountActiveMap.get(accId) == false){
                        if(!finalAccIdList.contains(accId)){
                            finalAccIdList.add(accId);
                        }
                        accId = childParentMap.get(accId);//from third getting second level acc
                        if(accId == null){
                            continue;
                        }
                        if(idToaccountActiveMap.get(accId) == false){
                            if(!finalAccIdList.contains(accId)){
                                finalAccIdList.add(accId);
                            }
                        }
                    }
                }
            }*/
            for (Id aId : activeAccIdList) {
                addParentAccounts(aId, childParentMap, finalAccIdList);
            }
            //in the above logic if we have only 3 level hierarchy - 
            for(id eachId:finalAccIdList){
                finalAccountList.add(idToAccountRecordMap.get(eachId));
            }                                   
            //}
        }catch(Exception e){
            //System.debug('ErrorMessage '+e);
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        return finalAccountList;
    }
    
    public static void addParentAccounts(Id startId, Map<Id, Id> childParentMap, Set<Id> finalAccIdList) {
        Integer depth = 0;
        Id current = childParentMap.get(startId);        
        while (current != null && depth < 3) {
            finalAccIdList.add(current);
            current = childParentMap.get(current);
            depth++;
        }
    }
    
    /* Getting IUPGM Role Picklist field Values*/
    public static List<String> getIUPGMRolePickListValues(){
        List<String> listOfPicklistValues= new List<String>();
        Schema.DescribeFieldResult fieldResult = Core_MDF_Int_Users_Partner_Geo_Mapping__c.Core_MDF_Role_nm__c.getDescribe();
        //List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : fieldResult.getPicklistValues()){
            listOfPicklistValues.add(pickListVal.getValue());
        }
        return listOfPicklistValues;
    }
    
    /*Method to Check If Logged In User has IUPGM Required Role*/
    public static Boolean checkLoggedInUserhasReqdRole(List<String> iupgmRoleValues){
        /*Boolean loggedInUserHasIUPGMReqdRole = false;
        List<PermissionSetAssignment> iupgmPermissionSetsAssigned = new List<PermissionSetAssignment>();
        // Querying All IUPGM Required Permission Sets Assigned to the Logged In User
        iupgmPermissionSetsAssigned = [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name IN: iupgmRoleValues];
        // If the User has at least single Role Set the flag to true
        if(iupgmPermissionSetsAssigned != NULL && iupgmPermissionSetsAssigned.size()>0){
            loggedInUserHasIUPGMReqdRole = true;
        }
        return loggedInUserHasIUPGMReqdRole;*/
        if (iupgmRoleValues == null || iupgmRoleValues.isEmpty()) {
            return false;
        }
        Integer matchCount = [SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name IN :iupgmRoleValues];
        return matchCount > 0;
    }
    
    /* fetch Account details of the current Account's detail page */
    @AuraEnabled(cacheable = true)
    public static List<Account> getAccountDetails(Id accountId){
        
        /*List<Account> account = new List<Account>();
        // Query the Required fields data
        account = [SELECT Id, Name, RecordType.DeveloperName, Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_CoMarketing_Ultimate_Account__r.Name
                   FROM Account WHERE Id=: accountId];
        return account;*/
        if (accountId == null){ return new List<Account>();}
        return [SELECT Id, Name, RecordType.DeveloperName, Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_CoMarketing_Ultimate_Account__r.Name
            FROM Account WHERE Id = :accountId];
    }
    /*It fetches all the Accounts of a hierarchy */
    @AuraEnabled(cacheable = true)
    public static List<Account> fetchAllAccounts(List<Account> ultimateAccountIdList){
        /*List<Account> acctList = new List<Account>(); 
        // Querying All the Child Accounts for an Ultimate Account
        if(ultimateAccountIdList != null && ultimateAccountIdList.size()>0){
            acctList = [Select Id, Name,Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_CoMarketing_Ultimate_Account__r.Name,Core_MDF_Parent_Fund_Account__c, Core_MDF_CoMarketingActive__c, RecordType.DeveloperName from Account  where ((Id in: ultimateAccountIdList AND Core_MDF_CoMarketing_Ultimate_Account__c = null) OR (Core_MDF_CoMarketing_Ultimate_Account__c In: ultimateAccountIdList AND Core_MDF_CoMarketing_Ultimate_Account__c!=null))];
        }
        return acctList;*/
        if (ultimateAccountIdList == null || ultimateAccountIdList.isEmpty()){ return new List<Account>();}
        return [Select Id, Name,Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_CoMarketing_Ultimate_Account__r.Name,Core_MDF_Parent_Fund_Account__c, Core_MDF_CoMarketingActive__c, RecordType.DeveloperName from Account  where (Id in: ultimateAccountIdList OR Core_MDF_CoMarketing_Ultimate_Account__c In: ultimateAccountIdList)];
    }

    /****************************************************************************************************** 
    Method Name:        checkUserPermissionSet
    @return  :          Boolean
    Description:        Method to check the current user's assigned Permission to set the partnerscore for Account
    Added By:           Aswin - 21/02/2022
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Boolean checkUserPermissionSet(Id userId){
        Boolean isAccessProvided = false;
        String customPermissionSetName = 'Core_MDF_CCP_Account_Recovery_Manager';
        try {
            isAccessProvided = FeatureManagement.checkPermission(customPermissionSetName);
        } catch(Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return isAccessProvided;
    }

    /****************************************************************************************************** 
    Method Name:        submitPartnerScore
    @return  :          String message
    Description:        This method is to update/create partner score record without duplicates
    Added By:           Manjula - 28/02/2022
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    @AuraEnabled
    public static submitPartnerScoreReturnResultWrapper submitPartnerScore(submitPartnerScoreWrapper partnerScoreWrapper)
    {   
        submitPartnerScoreReturnResultWrapper partnerScoreReturnResultWrapper = new submitPartnerScoreReturnResultWrapper();
        //List<Core_MDF_Partnership_Score__c> existingPartnershipScoreRecordList = getExistingPartnerScoreRecord(partnerScoreWrapper);
        //Core_MDF_Partnership_Score__c existingPartnershipScoreRecordData;
        //ChannelProgram cp= [Select Name, Core_MDF_Technical_Program_Name__c from ChannelProgram where Id =:partnerScoreWrapper.programId  Limit 1];
        try {
            List<Core_MDF_Partnership_Score__c> existingPartnershipScoreRecordList = getExistingPartnerScoreRecord(partnerScoreWrapper);
            ChannelProgram cp= [Select Name, Core_MDF_Technical_Program_Name__c from ChannelProgram where Id =:partnerScoreWrapper.programId  Limit 1];
            if(!existingPartnershipScoreRecordList.isEmpty()) {
                Core_MDF_Partnership_Score__c existingPartnershipScoreRecordData = existingPartnershipScoreRecordList[0];
                if(existingPartnershipScoreRecordData.Core_MDF_Partnership_Score_Nbr__c == null)
                {
                    existingPartnershipScoreRecordData.Core_MDF_Partnership_Score_Nbr__c = partnerScoreWrapper.partnerScoreNumber;
                    update existingPartnershipScoreRecordData;
                    partnerScoreReturnResultWrapper.isSuccess = true;
                    partnerScoreReturnResultWrapper.message='Record updated successfully';
                } else if( existingPartnershipScoreRecordData.Core_MDF_Partnership_Score_Nbr__c !=null ){   
                    partnerScoreReturnResultWrapper.isDuplicate = true;
                    partnerScoreReturnResultWrapper.message='Duplicate record found';
                    partnerScoreReturnResultWrapper.partnerScoreDuplicateId= existingPartnershipScoreRecordData.Id;
                }
            } else {
                Map<Id,Map<Id,Id>> intelAccountIdToProgramToVirtualCorpAccountId = Core_MDF_IAH_Partnership_Score.getVirtualCorpAccount(cp.Name, partnerScoreWrapper.accountId);
                if(intelAccountIdToProgramToVirtualCorpAccountId.containsKey(partnerScoreWrapper.accountId) && intelAccountIdToProgramToVirtualCorpAccountId.get(partnerScoreWrapper.accountId).containsKey(cp.Id)){
                    Core_MDF_Partnership_Score__c partnershipScoreObj = new Core_MDF_Partnership_Score__c();
                    Id virtualCorpAccountId = intelAccountIdToProgramToVirtualCorpAccountId.get(partnerScoreWrapper.accountId).get(cp.Id);
                    partnershipScoreObj.Core_MDF_Account_Id__c = partnerScoreWrapper.accountId;
                    partnershipScoreObj.Core_MDF_Virtual_Corp_Account_Id__c = virtualCorpAccountId;
                    partnershipScoreObj.Core_MDF_External_Id__c = partnerScoreWrapper.programId + virtualCorpAccountId + partnerScoreWrapper.quarter + ' ' + partnerScoreWrapper.year;
                    partnershipScoreObj.Core_MDF_Program_nm__c = cp.Core_MDF_Technical_Program_Name__c;
                    partnershipScoreObj.Core_MDF_Channel_Program_Id__c=partnerScoreWrapper.programId;
                    partnershipScoreObj.Core_MDF_Year_nm__c = partnerScoreWrapper.year;
                    partnershipScoreObj.Core_MDF_Quarter_nm__c = partnerScoreWrapper.quarter;
                    partnershipScoreObj.Core_MDF_Partnership_Score_Nbr__c = partnerScoreWrapper.partnerScoreNumber;
                    partnershipScoreObj.Core_MDF_Quarter_Year_Nm__c = partnerScoreWrapper.quarter+' '+partnerScoreWrapper.year;
                    
                    //insert partnershipScoreObj;
                    Schema.SObjectField externalID = Core_MDF_Partnership_Score__c.Core_MDF_External_Id__c;
                    Database.UpsertResult urList = Database.upsert(partnershipScoreObj, externalID, false);
                    partnerScoreReturnResultWrapper.isSuccess = true;
                    partnerScoreReturnResultWrapper.message = 'Record created successfully';
                }else{
                    partnerScoreReturnResultWrapper.message = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ProgramSelectionError');
                }
            }
        } catch(Exception ex) {
            partnerScoreReturnResultWrapper.isDuplicate = false;
            partnerScoreReturnResultWrapper.isSuccess = false;
            partnerScoreReturnResultWrapper.message = ex.getMessage();
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        
        return partnerScoreReturnResultWrapper; 
    }

    /****************************************************************************************************** 
    Method Name:        getExistingPartnerScoreRecord
    @return  :          Core_MDF_Partnership_Score__c[]
    Description:        This method is to fetch the existing partner score records based on program, account, year and quarter
    Added By:           Manjula - 28/02/2022
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public static List<Core_MDF_Partnership_Score__c> getExistingPartnerScoreRecord(submitPartnerScoreWrapper partnerScoreWrapper) {
        /*List<Core_MDF_Partnership_Score__c> existingPartnershipScoreRecordData = new List<Core_MDF_Partnership_Score__c>();
        existingPartnershipScoreRecordData = [Select Core_MDF_External_Id__c,Core_MDF_Partnership_Score_Nbr__c
            from Core_MDF_Partnership_Score__c where Core_MDF_Account_Id__c =: partnerScoreWrapper.accountId and Core_MDF_Channel_Program_Id__c =: partnerScoreWrapper.programId and Core_MDF_Year_nm__c =: partnerScoreWrapper.year
            and Core_MDF_Quarter_nm__c =: partnerScoreWrapper.quarter limit 1];
        return existingPartnershipScoreRecordData;*/
        return [Select Core_MDF_External_Id__c,Core_MDF_Partnership_Score_Nbr__c
            from Core_MDF_Partnership_Score__c where Core_MDF_Account_Id__c =: partnerScoreWrapper.accountId and Core_MDF_Channel_Program_Id__c =: partnerScoreWrapper.programId and Core_MDF_Year_nm__c =: partnerScoreWrapper.year
            and Core_MDF_Quarter_nm__c =: partnerScoreWrapper.quarter limit 1];
    }

    // submitPartnerScoreWrapper
    public class submitPartnerScoreWrapper {
        @AuraEnabled
        public String accountId{get;set;}
        @AuraEnabled
        public String programId{get;set;}
        @AuraEnabled
        public String year{get;set;}
        @AuraEnabled
        public String quarter{get;set;}
        @AuraEnabled
        public Decimal partnerScoreNumber{get;set;}
    }

    // wrapper returned to lwc on insert/update/duplicate/error of partner score
    public class submitPartnerScoreReturnResultWrapper {
        @AuraEnabled
        public Boolean isDuplicate{get;set;}
        @AuraEnabled
        public Boolean isSuccess{get;set;}
        @AuraEnabled
        public String message{get;set;}
        @AuraEnabled
        public String partnerScoreDuplicateId{get;set;}
    }
    
    public with sharing class Core_MDF_AccountHierarchyController_Sharing {
        
        Public List<String> getChannelProgram(){
            List<string> channelProgramsList = new List<string>();
            List<String> allowedPrograms = new List<String>();
            if (!String.isBlank(Label.Core_MDF_TechnicalProgramName)) {
                allowedPrograms = Label.Core_MDF_TechnicalProgramName.split(';');
            }
            for(ChannelProgram channelProg : [SELECT Id,Core_MDF_Technical_Program_Name__c FROM ChannelProgram WHERE Core_MDF_Technical_Program_Name__c IN :allowedPrograms LIMIT 50]){
                channelProgramsList.add(channelProg.Core_MDF_Technical_Program_Name__c);
            }
            return channelProgramsList;
        }
    }
}