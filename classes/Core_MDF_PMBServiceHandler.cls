/****************************************************************************************************************************************
* Class Name  : Core_MDF_PMBServiceHandler
* Version     : 1.0
* Created Date: 09-03-2018
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - JV       03/09/2018          Service Class for handling trigger related functions on Partner Marketing Budget object.
* Ayush                04/02/2024          ApexGuru fix in validateDecreasedBudgetAmount method - converted pmbToBeProcessed list to map and used in query
* Mohit                07/03/2024          Commented code associated to Channel and Legacy program/bugdet
* Ramapriya            27/01/2025          Included code for Co-GTM Program
*****************************************************************************************************************************************/
public without sharing class Core_MDF_PMBServiceHandler {
    //to get CMDF Proposal Based Record Type ID  
    //to get IPA Proposal Based Record Type ID  
    public static Id ipaProposalBasedRT = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Record_Type_Developer_Name')).getRecordTypeId();
    public static Boolean sendEmailOnce = true;
    /*****************************************************************************************************
Method Name:        checkPMBDuplicateRecords
@return  :          void
@parameters:        newPMBList - This will contain all the pmb records to be inserted/updated.
Description:        Whenever a record is inserted/updated of Partner Marketing object, this method checks whether the current record is duplicate or not
@Added By:          Accenture - JV - 09/03/2018
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static void checkPMBDuplicateRecords(List<PartnerMarketingBudget> newPMBList) {
        //List of partner account
        List<Id> partnerAccountList = new List<Id>();
        //List of budgets
        List<Id> pmbIdList = new List<Id>();
        try{            
            for(PartnerMarketingBudget pmbRecord :newPMBList) {                                
                //to skip IPA proposal based Budgets and CMDF proposal based budgets
                if(pmbRecord.RecordTypeId == ipaProposalBasedRT
                   || !checkforLegacy(pmbRecord)){
                       continue;
                   }
                PartnerAccountList.add(pmbRecord.Core_MDF_Budget_Partner__c);
                pmbIdList.add(pmbRecord.Id);
            }
            //List of existing budgets corresponding to partner account
            List<PartnerMarketingBudget> existingpmbList = [SELECT Id, Core_MDF_Budget_Partner__c, StartDate, EndDate, Core_MDF_Program__c, Core_MDF_Budget_Type_Txt__c
                                                            FROM PartnerMarketingBudget WHERE Core_MDF_Budget_Partner__c IN :partnerAccountList limit 1000];
            
            
            for(PartnerMarketingBudget newpmbRecord :newPMBList) {
                //to skip IPA proposal based Budgets and CMDF proposal based budgets from Duplicate and Overlapping check
                if(newpmbRecord.RecordTypeId == ipaProposalBasedRT
                   || !checkforLegacy(newpmbRecord)){
                       continue;
                   }
                for(PartnerMarketingBudget existingpmbRecord :existingpmbList) {
                    if(validatePmbWithOverlapAndDupCheck(newpmbRecord, existingpmbRecord) && (newpmbRecord.StartDate == existingpmbRecord.StartDate && newpmbRecord.EndDate == existingpmbRecord.EndDate)){
                        //Duplicate budget error
                        newpmbRecord.addError(Label.Core_MDF_PMBDuplicateError);
                    } else if(validatePmbWithOverlapAndDupCheck(newpmbRecord, existingpmbRecord) && checkOverlapBudget(newpmbRecord, existingpmbRecord)){
                        //Overlapping budget error
                        newpmbRecord.addError(Label.Core_MDF_PMBOverlapError);
                    }
                }
            }
        } 
        catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e;} // JV- Accenture : Add the exception into Core_Log_Entry Object 
    }
    
    /*****************************************************************************************************
Method Name:        checkforLegacy
@return  :          Boolean
@parameters:        pmbRecord - PartnerMarketingBudget to be checked for Legacy.
Description:        Checks whether the PartnerMarketingBudget is of Legacy budget type/Program
@Added By:          
Modified By:        Date:       Changes:
******************************************************************************************************/   
    public static Boolean checkforLegacy(PartnerMarketingBudget pmbRecord){
        List<string> budgetLegacyPrograms = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_LegacyBudgetPrograms').split(',');
        
        if(pmbRecord!=null && !Core_MDF_Utility.byPassFeature('Core_MDF_PMB_Bypass_LegacyBudgets')&&
           ((pmbRecord.Core_MDF_Budget_Type_Txt__c!=null && System.Label.Core_MDF_LegacyRestricBudgetTypes.contains(pmbRecord.Core_MDF_Budget_Type_Txt__c)) ||
            budgetLegacyPrograms.contains(pmbRecord.Core_MDF_Program_Nm__c))){
                return true;
            }
        
        return false;
    }
    /*****************************************************************************************************
Method Name:        checkPMBDuplicateRecordsOnUpdate
@return  :          void
@parameters:        newPMBList - This will contain all the pmb records to be updated.
oldPMBMap -  Map of the old Partner Marketing Budget.
Description:        Whenever a record is updated of Partner Marketing object, this method checks whether the current record is duplicate or not
@Added By:          Accenture - AD - 12/21/2018
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static void checkPMBDuplicateRecordsOnUpdate(List<PartnerMarketingBudget> newPMBList, Map<Id, PartnerMarketingBudget> oldPMBMap) {
        //To store PMB which to be processed for duplicate check
        List<PartnerMarketingBudget> pmbToBeProcessedForDupCheck = new List<PartnerMarketingBudget>();
        try{
            for(PartnerMarketingBudget newPmbRecord :newPMBList) {
                if(newPmbRecord.Core_MDF_Budget_Partner__c != oldPMBMap.get(newPmbRecord.ID).Core_MDF_Budget_Partner__c
                   || newPmbRecord.StartDate != oldPMBMap.get(newPmbRecord.ID).StartDate ||newpmbRecord.EndDate != oldPMBMap.get(newPmbRecord.ID).EndDate
                   || newPmbRecord.Core_MDF_Program__c != oldPMBMap.get(newPmbRecord.ID).Core_MDF_Program__c
                   || newpmbRecord.Core_MDF_Budget_Type_Txt__c != oldPMBMap.get(newPmbRecord.ID).Core_MDF_Budget_Type_Txt__c) {
                       pmbToBeProcessedForDupCheck.add(newPmbRecord);
                   }
            }
            if(pmbToBeProcessedForDupCheck != null && pmbToBeProcessedForDupCheck.size() > 0) {
                //Invoke method to check duplicate and overlapping budgets
                checkPMBDuplicateRecords(pmbToBeProcessedForDupCheck);
            }
            
        } catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e);  throw e; }
    }
    
    /*****************************************************************************************************
Method Name:        validateDecreasedBudgetAmount
@return  :          void
@parameters:        newPMBList - This will contain all the pmb records to be updated.
Description:        This method is validating the decrease budget amount with corp allocated amount
@Added By:          Accenture - AD - 3/20/2019
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static void validateDecreasedBudgetAmount(Map<Id, PartnerMarketingBudget> newPmbToBeProcessed, Map<Id, PartnerMarketingBudget> oldPMBMap) {
        try{
            //Map of budget record Ids and related budget allocations
            //List<PartnerMarketingBudget> pmbToBeProcessed = new List<PartnerMarketingBudget>();
            Map<Id, PartnerMarketingBudget> pmbToBeProcessedMap = new Map<Id, PartnerMarketingBudget>();
            list<String> progBudLst=new List<String>();
            string key;
            Map<String,Boolean> isActivityAvailAmountBased=new Map<String,Boolean>();
            for(PartnerMarketingBudget pmb :newPmbToBeProcessed.values()) { 
                String prgBudTypeKey = pmb.Core_MDF_Program_Nm__c+':'+pmb.Core_MDF_Budget_Type_Txt__c;
                if(prgBudTypeKey!=NULL){
                    progBudLst.add(prgBudTypeKey);
                }                
                
                if(pmb.Core_MDF_Decrease_Budget_Amount_Amt__c != oldPMBMap.get(pmb.ID).Core_MDF_Decrease_Budget_Amount_Amt__c || pmb.Core_MDF_Budget_Status__c !=oldPMBMap.get(pmb.ID).Core_MDF_Budget_Status__c ) {
                    //pmbToBeProcessed.add(pmb);
                    //converting list to map and using map.keySet() in below query as part of ApexGuru fix
                    pmbToBeProcessedMap.put(pmb.ID,pmb);
                }
            }
            if(progBudLst != NULL && progBudLst.size()>0){
                isActivityAvailAmountBased=isActAvailAmtValidationReq(progBudLst);
            }
            if(pmbToBeProcessedMap != null && !pmbToBeProcessedMap.isEmpty()) {
                Map<Id, PartnerMarketingBudget> existingBudgetAllocations = new Map<Id, PartnerMarketingBudget>([select Id, (select id, Core_MDF_Available_Allocation_Amount__c, Core_MDF_Available_Activity_Alloc_Amt__c, ChannelPartnerId from PartnerFundAllocations) from PartnerMarketingBudget where Id IN :pmbToBeProcessedMap.keySet()]); //converting list to map and using map.keySet() in the query as part of ApexGuru fix
                // Get the mdf budget types for allocation available amount check
                for(PartnerMarketingBudget pmb :pmbToBeProcessedMap.values()) {  
                    String uniqueKey = pmb.Core_MDF_Program_Nm__c+':'+pmb.Core_MDF_Budget_Type_Txt__c;
                    //checking map values
                    if(existingBudgetAllocations.containsKey(pmb.Id) && (existingBudgetAllocations.get(pmb.Id).PartnerFundAllocations) != null) {
                        for(PartnerFundAllocation alloc :existingBudgetAllocations.get(pmb.Id).PartnerFundAllocations) {
                            // check if allocation budget type is in mdfBudgetTypes list
                            if(isActivityAvailAmountBased.containsKey(uniqueKey) && isActivityAvailAmountBased.get(uniqueKey) && pmb.Core_MDF_Budget_Partner__c == alloc.ChannelPartnerId 
                               && (pmb.Core_MDF_Decrease_Budget_Amount_Amt__c != null && pmb.Core_MDF_Decrease_Budget_Amount_Amt__c > alloc.Core_MDF_Available_Activity_Alloc_Amt__c)
                               && pmb.Core_MDF_Budget_Status__c == Label.Core_MDF_Budget_Status_Released) {
                                   //set error
                                   pmb.addError(Label.Core_MDF_Budget_Decrease_Amount_ErrorMsgForMDF); break;
                                   // check if allocation budget type is not in mdfBudgetTypes list
                               }else if(((isActivityAvailAmountBased.containsKey(uniqueKey) && !isActivityAvailAmountBased.get(uniqueKey)) || !isActivityAvailAmountBased.containsKey(uniqueKey)) && pmb.Core_MDF_Budget_Partner__c == alloc.ChannelPartnerId 
                                        && (pmb.Core_MDF_Decrease_Budget_Amount_Amt__c != null && pmb.Core_MDF_Decrease_Budget_Amount_Amt__c > alloc.Core_MDF_Available_Allocation_Amount__c)
                                        && pmb.Core_MDF_Budget_Status__c == Label.Core_MDF_Budget_Status_Released){
                                            pmb.addError(Label.Core_MDF_Budget_Decrease_Amount);
                                            break;
                                        }   
                        }                    
                    }
                }
            }
            
        } 
        catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e; }
    }
    
    /*****************************************************************************************************
Method Name:        validatePmbWithOverlapAndDupCheck
@return  :          boolean
@parameters:        newpmbRecord - This will contain all new pmb records
existingpmbRecord - This will contain all existing pmb records corresponding to budget partner
Description:        This method is used to validate common conditions to check duplicate and overlap budget
@Added By:          Accenture - AD - 7/30/2019
Modified By:        Date:       Changes:
******************************************************************************************************/
    
    public static boolean validatePmbWithOverlapAndDupCheck(PartnerMarketingBudget newpmbRecord,PartnerMarketingBudget existingpmbRecord){
        try{
            //flag to hold result
            Boolean isValid = false;
            if(newpmbRecord != null && existingpmbRecord != null && existingpmbRecord.Id != newpmbRecord.Id &&
               newpmbRecord.Core_MDF_Budget_Partner__c == existingpmbRecord.Core_MDF_Budget_Partner__c &&
               newpmbRecord.Core_MDF_Program__c == existingpmbRecord.Core_MDF_Program__c &&
               newpmbRecord.Core_MDF_Budget_Type_Txt__c == existingpmbRecord.Core_MDF_Budget_Type_Txt__c) {
                   isValid = true;
               }
            return isValid;
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e; } 
    }
    
    /*****************************************************************************************************
Method Name:        checkOverlapBudget
@return  :          boolean
@parameters:        newpmbRecord - This will contain all new pmb records
existingpmbRecord - This will contain all existing pmb records corresponding to budget partner
Description:        This method is used to validate condition to check overlap budget
@Added By:          Accenture - AD - 7/30/2019
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static boolean checkOverlapBudget(PartnerMarketingBudget newpmbRecord, PartnerMarketingBudget existingpmbRecord) {
        try{
            //flag to hold result
            Boolean isValid = false;
            if((newpmbRecord != null && existingpmbRecord != null) && ((newpmbRecord.StartDate == existingpmbRecord.EndDate || newpmbRecord.EndDate == existingpmbRecord.StartDate) || (newpmbRecord.StartDate > existingpmbRecord.StartDate && newpmbRecord.EndDate < existingpmbRecord.EndDate) || (newpmbRecord.StartDate > existingpmbRecord.StartDate && newpmbRecord.StartDate < existingpmbRecord.EndDate && newpmbRecord.EndDate > existingpmbRecord.EndDate) || (newpmbRecord.StartDate == existingpmbRecord.StartDate && ((newpmbRecord.EndDate > existingpmbRecord.StartDate && newpmbRecord.EndDate < existingpmbRecord.EndDate)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    || newpmbRecord.EndDate > existingpmbRecord.EndDate)) || (newpmbRecord.EndDate == existingpmbRecord.EndDate && ((newpmbRecord.StartDate > existingpmbRecord.StartDate && newpmbRecord.StartDate < existingpmbRecord.EndDate)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    || newpmbRecord.StartDate < existingpmbRecord.StartDate)) || (newpmbRecord.StartDate < existingpmbRecord.StartDate && ((newpmbRecord.EndDate > existingpmbRecord.StartDate && newpmbRecord.EndDate < existingpmbRecord.EndDate) || newpmbRecord.EndDate > existingpmbRecord.EndDate)))) {
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        isValid = true;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    }
            return isValid;}catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e; } 
    }
    
    /*****************************************************************************************************
Method Name:        invokeBudgetShareRecordToGeoGroup
@return  :          void
@parameters:        List of Budget record
Description:        This is invocable method to perform Geo Based Sharing for a Budget record
Added By:           Accenture-VD
Date :                04-Nov-2019
Modified By:        Date:       Changes:
*****************************************************************************************************/
    @InvocableMethod
    public static void invokeBudgetShareRecordToGeoGroup(List<PartnerMarketingBudget> listOfPMB) {
        if(!Core_MDF_Utility.byPassFeature('Bypass_GeoBased_Budget_Sharing')){
            //To share record on the basis of Channel Program and geo
            List<Core_MDF_RecordGeoShare> recordGeoShareList = new List<Core_MDF_RecordGeoShare>();
            List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList= new List<Core_MDF_RecordPGMShareWrapper>();
            //To store account ids from Partner Marketing Budget
            List<Id> accountIds = new List<Id>();
            //Map of account id and account
            Map<Id, Account> accountIdToAccountMap = new Map<Id, Account>();
            //To store program ids
            List<Id> programIds = new List<Id>();
            //Map of channel Program id and technical program name
            Map<Id, String> cpIdToTechProgNameMap = new Map<Id, String>();
            // Map of Budget Id and Budget Partner
            Map<Id, Id> budgetIdToBudgetParnerIdMap = new Map<Id, Id>();
            // Map of Virtual Corp and Intel        
            Map<Id, Id> corpAccountToUltimateAcctMap = new map<Id, Id>();
            // Map of Budget Id and Intel Account
            Map<Id, String> budgetIdToIntelAcctIdProgramIdMap = new Map<Id, String>();
            // Set of Accounts requires node based sharing
            Set<Id> setOfNodeBasedAccounts = new Set<Id>();
            // Set of Programs requires node based sharing
            Set<Id> setOfNodeBasedPrograms = new Set<Id>();
            try{
                // Create a set of program names from metadata directly in the query loop
                Set<String> programNamesFromMetadata = new Set<String>();
                for (Core_MDF_ChannelProgram__mdt mdtRec : [
                    SELECT DeveloperName, Core_MDF_Program_ID__c, Label, Core_MDF_BudgetTypeBasedSharing_Ind__c 
                    FROM Core_MDF_ChannelProgram__mdt
                    WHERE Core_MDF_BudgetTypeBasedSharing_Ind__c  = True]) {
                        programNamesFromMetadata.add(mdtRec.Label);
                    }
                for(PartnerMarketingBudget pmb :listOfPMB) {
                    //Getting all the accounts from Budget List
                    accountIds.add(pmb.Core_MDF_Budget_Partner__c);
                    //storing program ids of accounts
                    programIds.add(pmb.Core_MDF_Program__c);
                    //Storing budget id and coressonding budget partner
                    budgetIdToBudgetParnerIdMap.put(pmb.Id, pmb.Core_MDF_Budget_Partner__c);
                }
                //To get account's geo and subgeo field
                for (Account acc :[Select Id, Core_Geo__c, Core_Sub_Geo__c, Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_CoMarketing_Ultimate_Account__c from Account where id IN :accountIds]) {
                    //To get account's geo and subgeo field
                    accountIdToAccountMap.put(acc.Id, acc);
                    // Storing the Virtual corp account and corresponding Ultimate Account
                    corpAccountToUltimateAcctMap.put(acc.Id, acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                }
                //Iterating to get channel program technical program name
                for (ChannelProgram cp :[Select Id, Name, Core_MDF_Technical_Program_Name__c from ChannelProgram where id IN :programIds]) {
                    cpIdToTechProgNameMap.put(cp.Id, cp.Name);
                }
                for(PartnerMarketingBudget pmbObj :listOfPMB) {
                    Account account = accountIdToAccountMap.get(pmbObj.Core_MDF_Budget_Partner__c);
                    // Preparing final Map of budget Id as key and Intel Account Id and Program Id as value
                    if(Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd(account.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c)){
                        setOfNodeBasedAccounts.add(account.Core_MDF_CoMarketing_Ultimate_Account__c);
                        setOfNodeBasedPrograms.add(pmbObj.Core_MDF_Program__c);
                        budgetIdToIntelAcctIdProgramIdMap.put(pmbObj.Id, String.valueOf(account.Core_MDF_CoMarketing_Ultimate_Account__c) + String.valueOf(pmbObj.Core_MDF_Program__c));
                    }
                    // Use metadata program names in conditional logic
                    if (programNamesFromMetadata != null && programNamesFromMetadata.contains(cpIdToTechProgNameMap.get(pmbObj.Core_MDF_Program__c))) {
                        recordGeoShareList.add(new Core_MDF_RecordGeoShare(pmbObj.id, account.Core_Geo__c, account.Core_Sub_Geo__c, cpIdToTechProgNameMap.get(pmbObj.Core_MDF_Program__c),pmbObj.Core_MDF_Budget_Type_Txt__c));
                        recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pmbObj.id, account.Core_Geo__c, account.Core_Sub_Geo__c, cpIdToTechProgNameMap.get(pmbObj.Core_MDF_Program__c), pmbObj.Core_MDF_Budget_Type_Txt__c, account.Core_MDF_CoMarketing_Ultimate_Account__c));
                    }else{
                        recordGeoShareList.add(new Core_MDF_RecordGeoShare(pmbObj.id, account.Core_Geo__c, account.Core_Sub_Geo__c, cpIdToTechProgNameMap.get(pmbObj.Core_MDF_Program__c)));
                        recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pmbObj.id, account.Core_Geo__c, account.Core_Sub_Geo__c, cpIdToTechProgNameMap.get(pmbObj.Core_MDF_Program__c), account.Core_MDF_CoMarketing_Ultimate_Account__c));
                    } 
                }
                //To share record on the basis of Channel Program and geo
                if(recordGeoShareList != null && recordGeoShareList.size() > 0) {
                    Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('PartnerMarketingBudget', recordGeoShareList);               
                } 
                // to share the budget to the respective Group
                if(recordPGMShareList != null && recordPGMShareList.size() >0){
                    Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('PartnerMarketingBudget', recordPGMShareList);
                }
                //To share budget with its account group            
                if(budgetIdToIntelAcctIdProgramIdMap!=Null && !budgetIdToIntelAcctIdProgramIdMap.isEmpty()){
                    Core_MDF_shareRecordToAccountGroup.shareRecordToAllAcctGroupInHierarchy(budgetIdToIntelAcctIdProgramIdMap, 'PartnerMarketingBudget', new List<Id>(setOfNodeBasedAccounts), new List<Id>(setOfNodeBasedPrograms));
                }               
            }
            catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}
        }
    }
    
    /*****************************************************************************************************
Method Name:        validatePMBCreationOrUpdateAccess
@return  :          void
@parameters:        newPMBList - This will contain all the pmb records to be inserted/updated.
Description:        Whenever a record is inserted/updated of Partner Marketing object, this method checks the user has necessary permissions to create Budget
@Added By:          Accenture - JV - 26/Oct/2021
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static void validatePMBCreationOrUpdateAccess(List<PartnerMarketingBudget> listOfPMB,Map<Id,PartnerMarketingBudget> oldPMBMap, Boolean isInsert) {
        //list to store the MDF/MDF+ budget types from custom metadata
        List<String> mdfBudgetTypes = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_MDFBudgetTypesForPMB');
        //check the current user has custom permission or not
        Boolean hasMDFBudgetCreationPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_MDF_Budget_Loader_Approver'); 
        //check the current user has custom permission or not
        Boolean hasFinanceUserPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Finance_User_Manager') || FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Finance_Usr') || FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Finance_Manager'); 
        //check the current user has IPA custom permission or not
        Boolean hasIPABudgetCreationAccess = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_IPA_Budget_Loader_Approver');
        //check the current user has Co-GTM custom permission or not
        Boolean hasCoGTMBudgetCreationAccess = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Co_GTM_Budget_Loader_Approver');
        //check the current user has EEF custom permission or not
        Boolean hasEEFBudgetCreationAccess = FeatureManagement.checkPermission('Core_MDF_Internal_EEF_Budget_Loader');
        //list to store the CCF/DCF budget loaders roles
        List<String> rolesList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_MDF_Budget_Roles');
        //map to store the IUPGM for the unique key(combination account id and program)
        Map<String,Core_MDF_Int_Users_Partner_Geo_Mapping__c> mapOfPgmAccountForIUPGM = new Map<String,Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        //List to store the permission set name for the current logged in user
        List<String> mdfBudgetPermissionSetAssigned = new List<String>();
        //String to store the unique value for IUPGM record
        String combinationOfPgmAccountIUPGMKey;
        //String to store the unique value for budget record
        String combinationOfPgmAccountBudget;
        //list to store the incoming MDF/MDF+ budget record's 
        List<PartnerMarketingBudget> listOfMDFBudgets = new List<PartnerMarketingBudget>();
        //list to store the incoming channel MDF budget record's 
        Map<PartnerMarketingBudget,Id> channelMDFBudToAccMap = new Map<PartnerMarketingBudget,Id>();
        // set to store IPA budget type values
        Set<String> ipaBudgetTypeValues = new Set<String>();
        // set to store IPA Ultimate Account Id values
        Set<Id> ipaUltAccId = new Set<Id>();
        Map<Id,PartnerMarketingBudget> ipaPmbIdToPmbMap = new Map<Id,PartnerMarketingBudget>();  
        Map<Id,PartnerMarketingBudget> eefPmbIdToPmbMap = new Map<Id,PartnerMarketingBudget>();
        Map<Id,PartnerMarketingBudget> cogtmPmbIdToPmbMap = new Map<Id,PartnerMarketingBudget>();  
        //account manager permissions
        Boolean hasAccountMgrPermission = FeatureManagement.checkPermission('Core_MDF_Internal_Account_Manager');
        try{
            
            for(PartnerMarketingBudget pmbObj : listOfPMB){  
                if((!(hasIPABudgetCreationAccess) && ((pmbObj.Core_MDF_Program_Nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name') && pmbObj.RecordTypeId != ipaProposalBasedRT) ))){
                    pmbObj.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MDF_BudgetCreation_ErrorMessage'));
                }else if((hasIPABudgetCreationAccess && pmbObj.Core_MDF_Program_Nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name') && pmbObj.RecordTypeId == ipaProposalBasedRT)){
                    pmbObj.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PropBased_Budget_ErrorMessage'));
                }else if(hasIPABudgetCreationAccess && pmbObj.Core_MDF_Program_Nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name') && pmbObj.RecordTypeId != ipaProposalBasedRT){
                    ipaBudgetTypeValues.add(pmbObj.Core_MDF_Budget_Type_Txt__c);
                    ipaUltAccId.add(pmbObj.Core_MDF_Ultimate_Account_Id__c);
                    ipaPmbIdToPmbMap.put(pmbObj.Id,pmbObj);
                } else if(hasEEFBudgetCreationAccess && pmbObj.Core_MDF_Program_Nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name')){
                    eefPmbIdToPmbMap.put(pmbObj.Id,pmbObj);
                }
                else if(hasCoGTMBudgetCreationAccess && pmbObj.Core_MDF_Program_Nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Co_GTM_program_name')){
                    cogtmPmbIdToPmbMap.put(pmbObj.Id,pmbObj);
                }
                if(pmbObj.Core_MDF_Program_Nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name') &&
                   pmbObj.Core_MDF_Program_Nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name') && pmbObj.Core_MDF_Program_Nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Co_GTM_program_name') ){
                       //check the current user has the custom permission and choosing the approriate budget type
                       if(hasMDFBudgetCreationPermission && !hasFinanceUserPermission && !mdfBudgetTypes.contains(pmbObj.Core_MDF_Budget_Type_Txt__c)){
                           //display error message if the user tries to create budget with other budget types
                           pmbObj.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MDF_BudgetCreation_ErrorMessage'));
                       }else if(!hasMDFBudgetCreationPermission && mdfBudgetTypes.contains(pmbObj.Core_MDF_Budget_Type_Txt__c)){
                           //display error message if the user tries to create budget with MDF/MDF+ budget type
                           pmbObj.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MDF_BudgetCreation_ErrorMessage'));
                       }else if(hasMDFBudgetCreationPermission && !hasFinanceUserPermission && mdfBudgetTypes.contains(pmbObj.Core_MDF_Budget_Type_Txt__c)){
                           listOfMDFBudgets.add(pmbObj);
                       }else if(oldPMBMap==null && (hasMDFBudgetCreationPermission && hasFinanceUserPermission && hasAccountMgrPermission) && mdfBudgetTypes.contains(pmbObj.Core_MDF_Budget_Type_Txt__c)){
                           listOfMDFBudgets.add(pmbObj);
                       }else if(oldPMBMap!=null && (hasMDFBudgetCreationPermission && hasFinanceUserPermission && hasAccountMgrPermission) && (pmbObj.Amount != oldPMBMap.get(pmbObj.Id).Amount || pmbObj.Type != oldPMBMap.get(pmbObj.Id).Type || pmbObj.Description != oldPMBMap.get(pmbObj.Id).Description || pmbObj.OwnerId != oldPMBMap.get(pmbObj.Id).OwnerId || 
                                                                                                                                               pmbObj.Core_MDF_Program__c != oldPMBMap.get(pmbObj.Id).Core_MDF_Program__c || pmbObj.StartDate != oldPMBMap.get(pmbObj.Id).StartDate || pmbObj.Title != oldPMBMap.get(pmbObj.Id).Title || pmbObj.EndDate != oldPMBMap.get(pmbObj.Id).EndDate || pmbObj.Core_MDF_Decrease_Budget_Amount_Amt__c != oldPMBMap.get(pmbObj.Id).Core_MDF_Decrease_Budget_Amount_Amt__c || pmbObj.Core_MDF_Budget_Partner__c != oldPMBMap.get(pmbObj.Id).Core_MDF_Budget_Partner__c ||
                                                                                                                                               pmbObj.Core_MDF_Budget_Comments__c != oldPMBMap.get(pmbObj.Id).Core_MDF_Budget_Comments__c || pmbObj.Core_MDF_Budget_Type_Txt__c != oldPMBMap.get(pmbObj.Id).Core_MDF_Budget_Type_Txt__c) && mdfBudgetTypes.contains(pmbObj.Core_MDF_Budget_Type_Txt__c)){
                                                                                                                                                   listOfMDFBudgets.add(pmbObj);
                                                                                                                                               }
                   }
            }
            //For EEF Program ,checking Record creator access
            if(!eefPmbIdToPmbMap.isEmpty()){
                validateOnCreateOrUpdateBudgetAccess(eefPmbIdToPmbMap, Label.Core_MDF_EEF_Program_Name);
            }
            if(!cogtmPmbIdToPmbMap.isEmpty()){
                validateOnCreateOrUpdateBudgetAccess(cogtmPmbIdToPmbMap, Label.Core_MDF_Co_GTM_Technical_program_name);
            }
            if(!ipaPmbIdToPmbMap.isEmpty()){
                validateOnCreateOrUpdateBudgetAccess(ipaPmbIdToPmbMap, Label.Core_MDF_IPA_Technical_program_name);
                if(isInsert && ipaBudgetTypeValues.size()>0 && ipaUltAccId.size()>0 
                   && !Core_MDF_Utility.byPassFeature('Core_MDF_bypassIPAAccBasedBdgtBnftChck')){
                       validateBudTypeBenefitMappingOnCreate(ipaPmbIdToPmbMap,ipaBudgetTypeValues,ipaUltAccId);
                   }
            }
            
            //by passing the permission set assignment check and IUPGM check for Budget manager
            if(!FeatureManagement.checkPermission('Core_MDF_CCP_Internal_MDF_Budget_Manager')){
                //iterating the PermissionSetAssignment
                if(listOfMDFBudgets.size()>0 && !listOfMDFBudgets.isEmpty()){
                    for(PermissionSetAssignment psa : [SELECT Id,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId=:UserInfo.getUserId() and PermissionSet.Name IN: rolesList]){
                        mdfBudgetPermissionSetAssigned.add(psa.PermissionSet.Name);
                    }
                    //checking the size of the permissionSet list
                    if(mdfBudgetPermissionSetAssigned.size()>0 && !mdfBudgetPermissionSetAssigned.isEmpty()){
                        //iterating the IUPGM records based on current user's permission set and user id
                        for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmRecord : [Select Id, Core_MDF_Account_id__c,Core_MDF_Channel_Program_id__c from Core_MDF_Int_Users_Partner_Geo_Mapping__c where 
                                                                                     Core_MDF_Active_Ind__c=true and Core_MDF_is_User_Active_ind__c=true and Core_MDF_User_id__c=:UserInfo.getUserId() and Core_MDF_Role_nm__c IN: mdfBudgetPermissionSetAssigned]){
                                                                                         
                                                                                         //preparing the unique key for the IUPGM map
                                                                                         combinationOfPgmAccountIUPGMKey = String.valueOf(iupgmRecord.Core_MDF_Account_id__c)+String.valueOf(iupgmRecord.Core_MDF_Channel_Program_id__c);
                                                                                         //putting the unique key and assigning the IUPGM records into the map
                                                                                         mapOfPgmAccountForIUPGM.put(combinationOfPgmAccountIUPGMKey,iupgmRecord);
                                                                                     }  
                        //iterating the list of incoming budgets
                        for(PartnerMarketingBudget pmbRecord : listOfMDFBudgets){
                            //preparing the unique string for budget    
                            combinationOfPgmAccountBudget = String.valueOf(pmbRecord.Core_MDF_Ultimate_Account_Id__c)+String.valueOf(pmbRecord.Core_MDF_Program__c);
                            if(!mapOfPgmAccountForIUPGM.containskey(combinationOfPgmAccountBudget)){
                                //comparing the budget unique value with IUPGM unique value and displaying error message if it is not matching
                                pmbRecord.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetLoaderRole_ErrorMessage'));
                            }
                        } 
                    }else{
                        for(PartnerMarketingBudget pmbObj : listOfPMB){
                            pmbObj.addError(Label.Core_MDF_NoClaimCreatePermissionText);
                        }
                    }
                }
            }
        }catch(Exception ex){Core_MDF_CCP_UtilityClass.logError(ex);
                            }  
    }
    
    /*****************************************************************************************************
Method Name:        validateOnCreateOrUpdateBudgetAccess
@return  :          void
@parameters:        ipaBudToAccMap - This will contain all the ipa pmb records to be inserted/updated.
Description:        Whenever a record is inserted/updated of Partner Marketing object, validate the budgettype and access for ipa budgets
@Added By:          Accenture - HP - 10/Jun/2022
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static void validateOnCreateOrUpdateBudgetAccess(Map<Id,PartnerMarketingBudget> ipaPmbIdToPmbMap, String technicalProgramName){
        //list to store the ipa budget loaders roles
        //List<String> ipaRolesList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_IPA_Budget_Roles');
        //List to store the permission set name for the current logged in user
        List<String> assignedPS = new List<String>();
        Set<String> iupgmUniqueKeySet = new Set<String>();
        List<String> rolesList = new List<String>();
        if(technicalProgramName == Core_MDF_CCP_ConstantClass.IPA_PROGRAM){
            rolesList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_IPA_Budget_Roles');
        } else if(technicalProgramName == Core_MDF_CCP_ConstantClass.EEF_PROGRAM){
            rolesList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_EEF_Budget_Roles');
        }
        else if(technicalProgramName == Core_MDF_CCP_ConstantClass.Co_GTM_TECHNICAL_PROGRAM){
            rolesList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Co_GTM_Budget_Roles');
        }
        try{            
            
            for(PermissionSetAssignment psa : [SELECT Id,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId=:UserInfo.getUserId() and PermissionSet.Name IN: rolesList]){
                assignedPS.add(psa.PermissionSet.Name);
            } 
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmRecord : [SELECT Id, Core_MDF_Account_id__c,Core_MDF_Channel_Program_id__c,Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Budget_Type_nm__c,Core_MDF_All_Budget_Type_Access_Ind__c,Core_MDF_All_Accounts_cd__c 
                                                                         FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c 
                                                                         WHERE Core_MDF_Active_Ind__c= TRUE 
                                                                         AND Core_MDF_is_User_Active_ind__c= TRUE 
                                                                         AND Core_MDF_User_id__c=:UserInfo.getUserId() 
                                                                         AND Core_MDF_Role_nm__c IN: assignedPS
                                                                         AND Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c =: technicalProgramName])
            {                
                if(iupgmRecord.Core_MDF_All_Accounts_cd__c == 'Yes' && iupgmRecord.Core_MDF_All_Budget_Type_Access_Ind__c){
                    iupgmUniqueKeySet.add(String.valueOf(iupgmRecord.Core_MDF_Channel_Program_id__c));
                }else if(iupgmRecord.Core_MDF_All_Accounts_cd__c == 'No' && iupgmRecord.Core_MDF_All_Budget_Type_Access_Ind__c){
                    iupgmUniqueKeySet.add(String.valueOf(iupgmRecord.Core_MDF_Account_id__c)+String.valueOf(iupgmRecord.Core_MDF_Channel_Program_id__c));
                }else if(iupgmRecord.Core_MDF_Budget_Type_nm__c != NULL){
                    for(String budType : iupgmRecord.Core_MDF_Budget_Type_nm__c.split(';')){ 
                        String budgetTypeUniqueKey = iupgmRecord.Core_MDF_All_Accounts_cd__c == 'Yes' ?  (String.valueOf(iupgmRecord.Core_MDF_Channel_Program_id__c)+budType) :  (String.valueOf(iupgmRecord.Core_MDF_Account_id__c)+String.valueOf(iupgmRecord.Core_MDF_Channel_Program_id__c)+budType);                    
                            iupgmUniqueKeySet.add(budgetTypeUniqueKey);
                    }
                }
            }
            for(PartnerMarketingBudget pmbObj : ipaPmbIdToPmbMap.values()){
                String accProgBTKey = String.valueOf(pmbObj.Core_MDF_Ultimate_Account_Id__c)+String.valueOf(pmbObj.Core_MDF_Program__c)+String.valueOf(pmbObj.Core_MDF_Budget_Type_Txt__c);
                String accProgKey = String.valueOf(pmbObj.Core_MDF_Ultimate_Account_Id__c)+String.valueOf(pmbObj.Core_MDF_Program__c);  
                String progBTKey = String.valueOf(pmbObj.Core_MDF_Program__c)+String.valueOf(pmbObj.Core_MDF_Budget_Type_Txt__c);
                String progKey = String.valueOf(pmbObj.Core_MDF_Program__c);
                //check if Budget Type is not enabled for the selected Budget Partner or not
                if(iupgmUniqueKeySet.isEmpty() || (!iupgmUniqueKeySet.isEmpty() && !iupgmUniqueKeySet.contains(accProgBTKey) && !iupgmUniqueKeySet.contains(accProgKey) && !iupgmUniqueKeySet.contains(progBTKey) && !iupgmUniqueKeySet.contains(progKey)))
                {
                    pmbObj.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetLoaderRole_ErrorMessage'));
                }                
            }                            
        }catch(Exception ex){ Core_MDF_CCP_UtilityClass.logError(ex);}
    }
    
    /*****************************************************************************************************
Method Name:        validateBudTypeBenefitMappingOnCreate
@return  :          void
@parameters:        ipaBudToAccMap - This will contain all the ipa pmb records to be inserted/updated.
Description:        Whenever a record is inserted/updated of Partner Marketing object, validate the budgettype and access for ipa budgets
@Added By:          Accenture - HP - 10/Jun/2022
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static void validateBudTypeBenefitMappingOnCreate(Map<Id,PartnerMarketingBudget> ipaPmbIdToPmbMap, Set<String> ipaBudgetTypeValues,Set<Id> ipaUltAccId){
        //check the current user has IPA custom permission or not
        Boolean hasIPABudgetCreationAccess = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_IPA_Budget_Loader_Approver');                
        Map<String,Set<String>> budTypeToBenefitsMap = new Map<String,Set<String>>();
        Map<Id,String> mapOfIntelAccountandPrimeId = new Map<Id,String>();
        Map<Id,Set<String>> accIdToBenefitsMap = new Map<Id,Set<String>>();
        Set<String> benefitSet = new Set<String>();
        Set<String> primeIdSet = new Set<String>();
        Set<Id> allIntelAccIdSet = new Set<Id>();
        Set<Id> setOfOnePartnerIds = new Set<Id>();
        List<Id> accInIpaAffiliation = new List<id>();
        Map<String, Set<Id>> mapOfPrimeIdSetofAccountId = new Map<String, Set<Id>>();
        Map<String, Set<Id>> mapOfUCDIdSetofOPId = new Map<String, Set<Id>>();
        boolean isUnifiedIdEnabled = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_UnifiedIdCheck');
        Boolean optAccountBenefitAssociation = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_OptAccountBenefitAssoc');
        try{ 
            if(isUnifiedIdEnabled){
                //Quering existing accounts corresponding to Core_Unified_Global_Customer_BP_Id__c
                for(Account account : [Select Id,Core_Unified_Global_Customer_BP_Id__c,Core_MDF_CoMarketingActive__c,Core_IPA_One_Partner_Id__c 
                                       from Account 
                                       where Id IN: (ipaUltAccId) 
                                       and Core_Unified_Global_Customer_BP_Id__c!=null]){                
                                           // map to store UCD Id corresponding to each incoming Intel Account 
                                           mapOfIntelAccountandPrimeId.put(account.Id,account.Core_Unified_Global_Customer_BP_Id__c);
                                           primeIdSet.add(account.Core_Unified_Global_Customer_BP_Id__c);
                                           
                                       } 
                
                for(Account acc : [Select Id,Core_Unified_Global_Customer_BP_Id__c,Core_MDF_CoMarketingActive__c,Core_IPA_One_Partner_Id__c 
                                   from Account 
                                   where Core_Unified_Global_Customer_BP_Id__c IN: (primeIdSet)
                                   and ((RecordType.DeveloperName = 'Core_Partner_Account_Group')
                                        OR (RecordType.DeveloperName =: Label.Core_MDF_MasterAccount AND Core_Intel_Partner_Alliance_PartnerGroup__c = TRUE))]){                
                                            // creating a map of UCDId and set of All Account Ids
                                            
                                            if(mapOfPrimeIdSetofAccountId.containsKey(acc.Core_Unified_Global_Customer_BP_Id__c)){
                                                mapOfPrimeIdSetofAccountId.get(acc.Core_Unified_Global_Customer_BP_Id__c).add(acc.Id);                    
                                            }
                                            else{
                                                mapOfPrimeIdSetofAccountId.put(acc.Core_Unified_Global_Customer_BP_Id__c, new Set<Id>{acc.Id});
                                            }
                                            // creating a map of UCDId and set of All One partner Ids
                                            if(mapOfUCDIdSetofOPId.containsKey(acc.Core_Unified_Global_Customer_BP_Id__c)){
                                                mapOfUCDIdSetofOPId.get(acc.Core_Unified_Global_Customer_BP_Id__c).add(acc.Core_IPA_One_Partner_Id__c);
                                                
                                            }
                                            else{
                                                mapOfUCDIdSetofOPId.put(acc.Core_Unified_Global_Customer_BP_Id__c, new Set<Id>{acc.Core_IPA_One_Partner_Id__c});
                                            }
                                            
                                            allIntelAccIdSet.add(acc.Id);//contains all account Ids
                                            
                                            setOfOnePartnerIds.add(acc.Core_IPA_One_Partner_Id__c); // contains all OPIds
                                            
                                        }
                
                //Querying Core_MDF_BudgetType_Benefit_Mappings__c fields
                // Here we update the custometa data into custom label--RS
                /*for(Core_MDF_BudgetType_Benefit_Mapping__mdt  mdfPartnerBenefit : [Select Id, Core_MDF_Budget_Type__c, Core_MDF_Partner_Benefit__c from Core_MDF_BudgetType_Benefit_Mapping__mdt  WHERE Core_MDF_IsActive__c = TRUE AND Core_MDF_Budget_Type__c IN: ipaBudgetTypeValues])*/
                for(Core_MDF_BudgetType_Benefit_Mappings__c  mdfPartnerBenefit : [Select Id, Core_MDF_Budget_Type__c, Core_MDF_Partner_Benefit__c from Core_MDF_BudgetType_Benefit_Mappings__c  WHERE Core_MDF_IsActive__c = TRUE AND Core_MDF_Budget_Type__c IN: ipaBudgetTypeValues])
                {
                    if(budTypeToBenefitsMap.containsKey(mdfPartnerBenefit.Core_MDF_Budget_Type__c)){
                        budTypeToBenefitsMap.get(mdfPartnerBenefit.Core_MDF_Budget_Type__c).add(mdfPartnerBenefit.Core_MDF_Partner_Benefit__c);
                    }else{
                        budTypeToBenefitsMap.put(mdfPartnerBenefit.Core_MDF_Budget_Type__c, new set<String>{mdfPartnerBenefit.Core_MDF_Partner_Benefit__c});
                    }  
                    benefitSet.add(mdfPartnerBenefit.Core_MDF_Partner_Benefit__c);
                }
                
                if(!allIntelAccIdSet.isEmpty()){
                    for(PRM_IPA_Affiliation__c accIpaAff : [SELECT Id, PRM_Account__c,PRM_Account__r.Core_Unified_Global_Customer_BP_Id__c 
                                                            FROM PRM_IPA_Affiliation__c 
                                                            WHERE PRM_Builder_Strategy__r.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ExcludedPartner')
                                                            AND PRM_Account__c IN: allIntelAccIdSet AND PRM_Active__c = TRUE]){
                                                                accInIpaAffiliation.add(accIpaAff.PRM_Account__c);
                                                            }
                }
                
                if(optAccountBenefitAssociation){
                    
                    processAccountBenefitAssociations(benefitSet, setOfOnePartnerIds, accIdToBenefitsMap, budTypeToBenefitsMap, ipaPmbIdToPmbMap, mapOfIntelAccountandPrimeId, mapOfUCDIdSetofOPId, accInIpaAffiliation);
                }
                
                else{
                    processAccountSpecialtyAssociations(benefitSet, allIntelAccIdSet, accIdToBenefitsMap, budTypeToBenefitsMap, ipaPmbIdToPmbMap, mapOfIntelAccountandPrimeId, mapOfPrimeIdSetofAccountId, accInIpaAffiliation);
                    
                }
                
            }
        }catch(Exception ex){ Core_MDF_CCP_UtilityClass.logError(ex);}
    }
    /*****************************************************************************************************
Method Name:        updateBudgetFields
@return  :          void
@parameters:        newPMBList,oldPMBMap - This will contain all the pmb records to be inserted/updated.
Description:        Whenever a record is inserted/updated of Partner Marketing object, updating budget fields based on certain conditions
@Added By:          Accenture - HP - 25/Nov/2021
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static void updateBudgetFields(List<PartnerMarketingBudget> newPMBList,Map<Id,PartnerMarketingBudget> oldPMBMap){
        //list to store MDF/MDF+ budget types from custom metadata
        List<String> mdfBudgetTypes = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_MDFBudgetTypesForPMB');
        //Boolean hasMDFBudgetApproverPermission = FeatureManagement.checkPermission('Core_MDF_BudgetApprover');
        if(FeatureManagement.checkPermission('Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader') || FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Finance_Usr') || FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Finance_User') || FeatureManagement.checkPermission('Core_MDF_CCP_Internal_DCF_MDF_Budget_Loader') || FeatureManagement.checkPermission('Core_MDF_CCP_Internal_IPA_Budget_Loader') || FeatureManagement.checkPermission('Core_MDF_Internal_EEF_Budget_Loader') || FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Co_GTM_Budget_Loader')){
            for(PartnerMarketingBudget newPmbRecord : newPMBList){
                if(oldPMBMap == null){
                    //Populate Value on old Budget Type Field
                    newPmbRecord.Core_MDF_Budget_Type__c = newPmbRecord.Core_MDF_Budget_Type_Txt__c;                
                }
                if(newpmbRecord.Core_MDF_Decrease_Budget_Amount_Amt__c==null){
                    newpmbRecord.Core_MDF_Decrease_Budget_Amount_Amt__c=0;
                }
                if(oldPMBMap == null || (oldPMBMap != null && (newPmbRecord.StartDate != oldPMBMap.get(newPmbRecord.ID).StartDate 
                                                               || newpmbRecord.EndDate != oldPMBMap.get(newPmbRecord.ID).EndDate
                                                               || newpmbRecord.Amount != oldPMBMap.get(newPmbRecord.ID).Amount 
                                                               || (newpmbRecord.Core_MDF_Decrease_Budget_Amount_Amt__c != oldPMBMap.get(newPmbRecord.ID).Core_MDF_Decrease_Budget_Amount_Amt__c
                                                                   && newpmbRecord.Core_MDF_Decrease_Budget_Amount_Amt__c!=null && newpmbRecord.Core_MDF_Decrease_Budget_Amount_Amt__c>0) )))
                {
                    //checking the budget type and program to assign the status value 
                    if((newPmbRecord.Core_MDF_Program_Nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name') && newPmbRecord.RecordTypeId != ipaProposalBasedRT && FeatureManagement.checkPermission('Core_MDF_CCP_Internal_IPA_Budget_Loader'))  || (newPmbRecord.Core_MDF_Program_Nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Co_GTM_program_name') && FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Co_GTM_Budget_Loader'))  
                       || (/*mdfBudgetTypes.contains(newPmbRecord.Core_MDF_Budget_Type_Txt__c) &&*/ ((newPmbRecord.Core_MDF_Program_Nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Program_Name') && (FeatureManagement.checkPermission('Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader') || FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Finance_User'))) || (newPmbRecord.Core_MDF_Program_Nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Program_Name') && (FeatureManagement.checkPermission('Core_MDF_CCP_Internal_DCF_MDF_Budget_Loader') || FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Finance_User'))) || 
                                                                                                     (newPmbRecord.Core_MDF_Program_Nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Channel_Program_Name') && FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Finance_Usr')) ||
                                                                                                     ((newPmbRecord.Core_MDF_Program_Nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCFB_Program_Name') || newPmbRecord.Core_MDF_Program_Nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SPCF_Program_Name')) && FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Finance_User')))))
                    {
                        newPmbRecord.Core_MDF_Budget_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PMB_Status_PendingReview');
                    }
                }
            }    
        }
        
    }
    /*****************************************************************************************************
Method Name:        isActAvailAmtValidationReq
@return  :          void
@parameters:        Program,Budget Type
Description:        returns boolean value,budget is program based orBudget Type based
@Added By:          Accenture -Nirmala K - 14/JAN/2022
Modified By:        Date:       Changes:
******************************************************************************************************/
    Public Static Map<String,Boolean> isActAvailAmtValidationReq(List<String> progToBudgetUniqueKey){
        Map<String,Boolean> progBudTypeToBooleanMap = new Map<String,Boolean>();
        Set<String> mdtUniqueSet = new Set<String>();
        Set<String> progSet = new Set<String>();
        if(progToBudgetUniqueKey != NULL && progToBudgetUniqueKey.size()>0){
            for(String prgBT : progToBudgetUniqueKey) {
                if(prgBT.split(':').size()>0){
                    progSet.add(prgBT.split(':')[0]);
                }
            }
        }
        if(progSet != NULL && progSet.size()>0){
            List<Core_MDF_Program_BudgetTypeConfig__c> progBudTypeMdtList = [SELECT Id,Core_MDF_Program_Txt__c,Core_MDF_BudgetTypes_Txt__c,Core_MDF_AllBudgetTypes_Ind__c FROM Core_MDF_Program_BudgetTypeConfig__c WHERE (Core_MDF_Program_Txt__c IN: progSet AND Core_MDF_isActive__c = true AND Core_MDF_activityAvlAmtValidationReq_Ind__c = true)];            
            if(progBudTypeMdtList != NULL && progBudTypeMdtList.size()>0){
                for(Core_MDF_Program_BudgetTypeConfig__c pbmdt : progBudTypeMdtList){
                    if(pbmdt.Core_MDF_BudgetTypes_Txt__c != NULL){
                        for(String budType : pbmdt.Core_MDF_BudgetTypes_Txt__c.split(';')){
                            mdtUniqueSet.add(pbmdt.Core_MDF_Program_Txt__c+':'+budType);
                        }
                    }else if(pbmdt.Core_MDF_AllBudgetTypes_Ind__c){
                        mdtUniqueSet.add(pbmdt.Core_MDF_Program_Txt__c);
                    }
                }                
            }
            for(String progBudgetType: progToBudgetUniqueKey){
                if(mdtUniqueSet.contains(progBudgetType) || (progBudgetType.split(':').size()>0 && mdtUniqueSet.contains(progBudgetType.split(':')[0]))){
                    progBudTypeToBooleanMap.put(progBudgetType,true);
                }else{
                    progBudTypeToBooleanMap.put(progBudgetType,false);
                }
            }
        }
        return progBudTypeToBooleanMap;        
    }
    /*************************************************************************** 
Method Name:        validateOnCreateBudget
@return  :          void
@parameters:        budget list
Description:        restrict budget creation for cross-role
@Added By:          Accenture- 28/Apr/2022
Modified By:        Date:       Changes:
*********************************************************************************/
    public static void validateRoleBudgetTypeAccess(List<PartnerMarketingBudget> newPMBList){
        //EOL - Removed condition associated to legacy
        Boolean hasCCFMDFBudgetPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader'); 
        Boolean hasDCFMDFBudgetPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_DCF_MDF_Budget_Loader'); 
        Boolean hasFinanceUserPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Finance_User'); 
        Boolean hasCCFUserPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_CCF_User');
        Boolean hasDCFUserPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_DCF_User'); 
        /*Boolean hasCCFBUserPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_CCFB_User'); 
Boolean hasSPCFUserPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_SPCF_User');*/
        Boolean hasIPABudgetPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_IPA_Budget_Loader');
        Boolean hasEEFBudgetPermission = FeatureManagement.checkPermission('Core_MDF_Internal_EEF_Budget_Loader');
        Boolean hasCoGTMBudgetPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Co_GTM_Budget_Loader');
        Boolean hasRetailBudgetPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Finance_Usr');
        //finance manager or budget approver
        Boolean hasFinanceManagerPermission = FeatureManagement.checkPermission('Core_MDF_FinanceManager');
        Boolean hasBudgetApproverPermission = FeatureManagement.checkPermission('Core_MDF_BudgetApprover');
        try{
            for(PartnerMarketingBudget newPmbRecord : newPMBList){
                if(newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Program_Name') && ((!hasCCFMDFBudgetPermission && !hasCCFUserPermission && !hasFinanceUserPermission) || 
                                                                                                                                   (hasCCFMDFBudgetPermission && !hasFinanceUserPermission && !hasCCFUserPermission && (newPmbRecord.Core_MDF_Legacy_Budget_Ind__c || newPmbRecord.Core_MDF_Budget_Type_Txt__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP'))) || 
                                                                                                                                   (!hasCCFMDFBudgetPermission && hasFinanceUserPermission && hasCCFUserPermission && !newPmbRecord.Core_MDF_Legacy_Budget_Ind__c && newPmbRecord.Core_MDF_Budget_Type_Txt__c!=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP')) || 
                                                                                                                                   (!hasFinanceUserPermission && hasCCFUserPermission && !hasCCFMDFBudgetPermission) || 
                                                                                                                                   (hasFinanceUserPermission && !hasCCFUserPermission && !hasCCFMDFBudgetPermission) || 
                                                                                                                                   (hasCCFMDFBudgetPermission && !hasCCFUserPermission && hasFinanceUserPermission && (newPmbRecord.Core_MDF_Legacy_Budget_Ind__c || newPmbRecord.Core_MDF_Budget_Type_Txt__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP'))) ||
                                                                                                                                   (hasFinanceUserPermission && !hasCCFUserPermission && !hasCCFMDFBudgetPermission && (newPmbRecord.Core_MDF_Legacy_Budget_Ind__c || newPmbRecord.Core_MDF_Budget_Type_Txt__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP'))))){
                                                                                                                                       newPmbRecord.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Creation_Validation'));
                                                                                                                                   }else if(newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Program_Name') && ((!hasDCFMDFBudgetPermission && !hasDCFUserPermission && !hasFinanceUserPermission) || 
                                                                                                                                                                                                                                                            (hasDCFMDFBudgetPermission && !hasFinanceUserPermission && !hasDCFUserPermission && (newPmbRecord.Core_MDF_Legacy_Budget_Ind__c || newPmbRecord.Core_MDF_Budget_Type_Txt__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP') || newPmbRecord.Core_MDF_Budget_Type_Txt__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP'))) || 
                                                                                                                                                                                                                                                            (!hasDCFMDFBudgetPermission && hasFinanceUserPermission && hasDCFUserPermission && !newPmbRecord.Core_MDF_Legacy_Budget_Ind__c && newPmbRecord.Core_MDF_Budget_Type_Txt__c!=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP') && newPmbRecord.Core_MDF_Budget_Type_Txt__c!=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP')) || 
                                                                                                                                                                                                                                                            (!hasFinanceUserPermission && hasDCFUserPermission && !hasDCFMDFBudgetPermission) ||(hasFinanceUserPermission && !hasDCFUserPermission && !hasDCFMDFBudgetPermission) || 
                                                                                                                                                                                                                                                            (hasDCFMDFBudgetPermission && !hasDCFUserPermission && hasFinanceUserPermission && (newPmbRecord.Core_MDF_Legacy_Budget_Ind__c || newPmbRecord.Core_MDF_Budget_Type_Txt__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP') || newPmbRecord.Core_MDF_Budget_Type_Txt__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP'))) ||
                                                                                                                                                                                                                                                            (hasFinanceUserPermission && !hasDCFUserPermission && !hasDCFMDFBudgetPermission && (newPmbRecord.Core_MDF_Legacy_Budget_Ind__c || newPmbRecord.Core_MDF_Budget_Type_Txt__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP') || newPmbRecord.Core_MDF_Budget_Type_Txt__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP'))))){
                                                                                                                                                                                                                                                                newPmbRecord.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Creation_Validation'));
                                                                                                                                                                                                                                                            }else if(newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name') && newPmbRecord.RecordTypeId != ipaProposalBasedRT && !hasIPABudgetPermission){
                                                                                                                                                                                                                                                                newPmbRecord.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Creation_Validation'));
                                                                                                                                                                                                                                                            }else if(newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Channel_Program_Name') && !hasRetailBudgetPermission){
                                                                                                                                                                                                                                                                newPmbRecord.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Creation_Validation'));
                                                                                                                                                                                                                                                            }else if(newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name') && !hasEEFBudgetPermission){
                                                                                                                                                                                                                                                                newPmbRecord.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Creation_Validation'));
                                                                                                                                                                                                                                                            }
                else if(newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Co_GTM_program_name') && !hasCoGTMBudgetPermission){
                    newPmbRecord.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Creation_Validation'));
                }
                /*else if(newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCFB_Program_Name')  && ((!hasCCFBUserPermission && !hasFinanceUserPermission) ||
(hasFinanceUserPermission && hasCCFBUserPermission && newPmbRecord.Core_MDF_Budget_Type_Txt__c!=null) ||(!hasFinanceUserPermission && hasCCFBUserPermission && newPmbRecord.Core_MDF_Budget_Type_Txt__c==null) ||
(hasFinanceUserPermission && !hasCCFBUserPermission && newPmbRecord.Core_MDF_Budget_Type_Txt__c==null))){
newPmbRecord.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Creation_Validation'));
}else if(newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SPCF_Program_Name') && ((!hasSPCFUserPermission && !hasFinanceUserPermission) ||
(hasFinanceUserPermission && hasSPCFUserPermission && newPmbRecord.Core_MDF_Budget_Type_Txt__c!=null) ||(!hasFinanceUserPermission && hasSPCFUserPermission && newPmbRecord.Core_MDF_Budget_Type_Txt__c==null) ||
(hasFinanceUserPermission && !hasSPCFUserPermission && newPmbRecord.Core_MDF_Budget_Type_Txt__c==null))){
newPmbRecord.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Creation_Validation'));
}*/
            }
        }catch(Exception ex){ Core_MDF_CCP_UtilityClass.logError(ex);}  
    }
    
    /*************************************************************************** 
Method Name:        validateOnUpdateBudget
@return  :          void
@parameters:        budget list
Description:        restrict budget status update
@Added By:          Accenture- 28/Apr/2022
Modified By:        Date:       Changes:
*********************************************************************************/
    public static void validateBudgetStatusOnUpdate(List<PartnerMarketingBudget> newPMBList,Map<Id,PartnerMarketingBudget> oldPMBMap){
        
        Boolean hasCCFMDFBudgetPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader'); 
        Boolean hasDCFMDFBudgetPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_DCF_MDF_Budget_Loader'); 
        Boolean hasFinanceUserPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Finance_User'); 
        Boolean hasCCFUserPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_CCF_User');
        Boolean hasDCFUserPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_DCF_User'); 
        Boolean hasCCFBUserPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_CCFB_User'); 
        Boolean hasSPCFUserPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_SPCF_User');
        Boolean hasIPABudgetPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_IPA_Budget_Loader');
        Boolean hasRetailBudgetPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Finance_Usr');
        Boolean hasCoGTMBudgetPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Co_GTM_Budget_Loader');
        //finance manager or budget approver
        Boolean hasFinanceManagerPermission = FeatureManagement.checkPermission('Core_MDF_FinanceManager');
        Boolean hasBudgetApproverPermission = FeatureManagement.checkPermission('Core_MDF_BudgetApprover');
        Boolean hasEEFBudgetApproverPermission = FeatureManagement.checkPermission('Core_MDF_Internal_EEF_Budget_Approver');
        
        try{
            for(PartnerMarketingBudget newPmbRecord : newPMBList){
                Boolean byPassAmtValidation = false;
                if(hasFinanceManagerPermission || hasBudgetApproverPermission){ 
                    if(newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Program_Name')  && ((!hasCCFMDFBudgetPermission && !hasFinanceUserPermission && newPmbRecord.Core_MDF_Budget_Status__c!=null && oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Status__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Opal_Available_Budget_Status') && newPmbRecord.Core_MDF_Budget_Status__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Status__c) ||
                                                                                                                                        ((hasCCFMDFBudgetPermission || hasFinanceUserPermission) && newPmbRecord.Core_MDF_Budget_Status__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Status__c && newPmbRecord.Core_MDF_Budget_Status__c!='Pending Review'))){
                                                                                                                                            //((hasCCFMDFBudgetPermission || hasFinanceUserPermission) && (newPmbRecord.Core_MDF_Budget_Status__c=='Pending Review' && !(newPmbRecord.StartDate != oldPMBMap.get(newPmbRecord.Id).StartDate || newPmbRecord.EndDate != oldPMBMap.get(newPmbRecord.Id).EndDate || newPmbRecord.Amount != oldPMBMap.get(newPmbRecord.Id).Amount || newPmbRecord.Core_MDF_Decrease_Budget_Amount_Amt__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Decrease_Budget_Amount_Amt__c))))){
                                                                                                                                            newPmbRecord.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Status_Validation'));
                                                                                                                                        }else if(newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Program_Name') && ((!hasDCFMDFBudgetPermission && !hasFinanceUserPermission && newPmbRecord.Core_MDF_Budget_Status__c!=null && oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Status__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Opal_Available_Budget_Status') && newPmbRecord.Core_MDF_Budget_Status__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Status__c) ||
                                                                                                                                                                                                                                                                 ((hasDCFMDFBudgetPermission || hasFinanceUserPermission) && newPmbRecord.Core_MDF_Budget_Status__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Status__c && newPmbRecord.Core_MDF_Budget_Status__c!='Pending Review'))){
                                                                                                                                                                                                                                                                     //((hasDCFMDFBudgetPermission || hasFinanceUserPermission) && (newPmbRecord.Core_MDF_Budget_Status__c=='Pending Review' && !(newPmbRecord.StartDate != oldPMBMap.get(newPmbRecord.Id).StartDate || newPmbRecord.EndDate != oldPMBMap.get(newPmbRecord.Id).EndDate || newPmbRecord.Amount != oldPMBMap.get(newPmbRecord.Id).Amount || newPmbRecord.Core_MDF_Decrease_Budget_Amount_Amt__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Decrease_Budget_Amount_Amt__c))))){
                                                                                                                                                                                                                                                                     newPmbRecord.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Status_Validation'));
                                                                                                                                                                                                                                                                 }else if(newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name') && newPmbRecord.RecordTypeId != ipaProposalBasedRT && ((!hasIPABudgetPermission && newPmbRecord.Core_MDF_Budget_Status__c!=null && oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Status__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Opal_Available_Budget_Status') && newPmbRecord.Core_MDF_Budget_Status__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Status__c) ||
                                                                                                                                                                                                                                                                                                                                                                                                                                                       (hasIPABudgetPermission && newPmbRecord.Core_MDF_Budget_Status__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Status__c && newPmbRecord.Core_MDF_Budget_Status__c!='Pending Review'))){
                                                                                                                                                                                                                                                                                                                                                                                                                                                           newPmbRecord.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Status_Validation'));
                                                                                                                                                                                                                                                                                                                                                                                                                                                       }else if(newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Channel_Program_Name')  && ((!hasRetailBudgetPermission && newPmbRecord.Core_MDF_Budget_Status__c!=null && oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Status__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Opal_Available_Budget_Status') && newPmbRecord.Core_MDF_Budget_Status__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Status__c) ||
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            (hasRetailBudgetPermission && newPmbRecord.Core_MDF_Budget_Status__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Status__c && newPmbRecord.Core_MDF_Budget_Status__c!='Pending Review'))){
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //(hasRetailBudgetPermission && (newPmbRecord.Core_MDF_Budget_Status__c=='Pending Review' && !(newPmbRecord.StartDate != oldPMBMap.get(newPmbRecord.Id).StartDate || newPmbRecord.EndDate != oldPMBMap.get(newPmbRecord.Id).EndDate || newPmbRecord.Amount != oldPMBMap.get(newPmbRecord.Id).Amount || newPmbRecord.Core_MDF_Decrease_Budget_Amount_Amt__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Decrease_Budget_Amount_Amt__c))))){
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                newPmbRecord.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Status_Validation'));
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            }
                    else if(newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Co_GTM_program_name') && ((!hasCoGTMBudgetPermission && newPmbRecord.Core_MDF_Budget_Status__c!=null && oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Status__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Opal_Available_Budget_Status') && newPmbRecord.Core_MDF_Budget_Status__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Status__c) ||
                                                                                                                                               (hasCoGTMBudgetPermission && newPmbRecord.Core_MDF_Budget_Status__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Status__c && newPmbRecord.Core_MDF_Budget_Status__c!='Pending Review'))){
                                                                                                                                                   newPmbRecord.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Status_Validation'));
                                                                                                                                               }
                    else if((newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCFB_Program_Name')  || newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SPCF_Program_Name')) && ((!hasFinanceUserPermission && newPmbRecord.Core_MDF_Budget_Status__c!=null && oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Status__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Opal_Available_Budget_Status') && newPmbRecord.Core_MDF_Budget_Status__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Status__c) ||
                                                                                                                                                                                                                                                                (hasFinanceUserPermission && newPmbRecord.Core_MDF_Budget_Status__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Status__c && newPmbRecord.Core_MDF_Budget_Status__c!='Pending Review'))){
                                                                                                                                                                                                                                                                    //(hasFinanceUserPermission && (newPmbRecord.Core_MDF_Budget_Status__c=='Pending Review' && !(newPmbRecord.StartDate != oldPMBMap.get(newPmbRecord.Id).StartDate || newPmbRecord.EndDate != oldPMBMap.get(newPmbRecord.Id).EndDate || newPmbRecord.Amount != oldPMBMap.get(newPmbRecord.Id).Amount || newPmbRecord.Core_MDF_Decrease_Budget_Amount_Amt__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Decrease_Budget_Amount_Amt__c))))){
                                                                                                                                                                                                                                                                    newPmbRecord.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Status_Validation'));
                                                                                                                                                                                                                                                                } 
                    if(newPmbRecord.Core_MDF_Budget_Status__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Status__c && newPmbRecord.Core_MDF_Budget_Status__c == 'Rejected' && oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Status__c == 'Pending Review'){
                        if(newPmbRecord.Amount != newPmbRecord.TotalAllocatedAmount){
                            newPmbRecord.Amount = newPmbRecord.TotalAllocatedAmount;
                            byPassAmtValidation = True;
                        }
                        if(newPmbRecord.Core_MDF_Decrease_Budget_Amount_Amt__c > 0){
                            newPmbRecord.Core_MDF_Decrease_Budget_Amount_Amt__c = 0;
                            byPassAmtValidation = True;
                        }
                    }
                    
                }
                //validate the user's access based on program during update
                if(!Core_MDF_Utility.byPassFeature('Bypass_MDF_Budget_Update_Validation')){
                    if(!isBudgetReduction(newPmbRecord,oldPMBMap) && ((newPmbRecord.Amount != oldPMBMap.get(newPmbRecord.Id).Amount && !byPassAmtValidation) || newPmbRecord.Type != oldPMBMap.get(newPmbRecord.Id).Type || newPmbRecord.Description != oldPMBMap.get(newPmbRecord.Id).Description || newPmbRecord.OwnerId != oldPMBMap.get(newPmbRecord.Id).OwnerId || 
                                                                      newPmbRecord.Core_MDF_Program__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Program__c || newPmbRecord.StartDate != oldPMBMap.get(newPmbRecord.Id).StartDate || newPmbRecord.Title != oldPMBMap.get(newPmbRecord.Id).Title || newPmbRecord.EndDate != oldPMBMap.get(newPmbRecord.Id).EndDate || 
                                                                      (newPmbRecord.Core_MDF_Decrease_Budget_Amount_Amt__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Decrease_Budget_Amount_Amt__c && !byPassAmtValidation) || newPmbRecord.Core_MDF_Budget_Partner__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Partner__c ||
                                                                      newPmbRecord.Core_MDF_Budget_Comments__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Comments__c || newPmbRecord.Core_MDF_Budget_Type_Txt__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Budget_Type_Txt__c ) && 
                       
                       ((newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Program_Name') && ((!hasCCFMDFBudgetPermission && !hasCCFUserPermission && !hasFinanceUserPermission) || 
                                                                                                                                         (hasCCFMDFBudgetPermission && !hasFinanceUserPermission && !hasCCFUserPermission && (newPmbRecord.Core_MDF_Legacy_Budget_Ind__c || newPmbRecord.Core_MDF_Budget_Type_Txt__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP'))) || 
                                                                                                                                         (!hasCCFMDFBudgetPermission && hasFinanceUserPermission && hasCCFUserPermission && !newPmbRecord.Core_MDF_Legacy_Budget_Ind__c && newPmbRecord.Core_MDF_Budget_Type_Txt__c!=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP')) || 
                                                                                                                                         (!hasFinanceUserPermission && hasCCFUserPermission && !hasCCFMDFBudgetPermission) || 
                                                                                                                                         (hasFinanceUserPermission && !hasCCFUserPermission && !hasCCFMDFBudgetPermission) ||
                                                                                                                                         (hasCCFMDFBudgetPermission && !hasCCFUserPermission && hasFinanceUserPermission && (newPmbRecord.Core_MDF_Legacy_Budget_Ind__c || newPmbRecord.Core_MDF_Budget_Type_Txt__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP'))) ||
                                                                                                                                         (hasFinanceUserPermission && !hasCCFUserPermission && !hasCCFMDFBudgetPermission && (newPmbRecord.Core_MDF_Legacy_Budget_Ind__c || newPmbRecord.Core_MDF_Budget_Type_Txt__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP'))))) ||
                        
                        (newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Program_Name') && ((!hasDCFMDFBudgetPermission && !hasDCFUserPermission && !hasFinanceUserPermission) || 
                                                                                                                                         (hasDCFMDFBudgetPermission && !hasFinanceUserPermission && !hasDCFUserPermission && (newPmbRecord.Core_MDF_Legacy_Budget_Ind__c || newPmbRecord.Core_MDF_Budget_Type_Txt__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP') || newPmbRecord.Core_MDF_Budget_Type_Txt__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP'))) || 
                                                                                                                                         (!hasDCFMDFBudgetPermission && hasFinanceUserPermission && hasDCFUserPermission && !newPmbRecord.Core_MDF_Legacy_Budget_Ind__c && newPmbRecord.Core_MDF_Budget_Type_Txt__c!=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP') && newPmbRecord.Core_MDF_Budget_Type_Txt__c!=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP')) || 
                                                                                                                                         (!hasFinanceUserPermission && hasDCFUserPermission && !hasDCFMDFBudgetPermission) || (hasFinanceUserPermission && !hasDCFUserPermission && !hasDCFMDFBudgetPermission) || 
                                                                                                                                         (hasDCFMDFBudgetPermission && !hasDCFUserPermission && hasFinanceUserPermission && (newPmbRecord.Core_MDF_Legacy_Budget_Ind__c || newPmbRecord.Core_MDF_Budget_Type_Txt__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP') || newPmbRecord.Core_MDF_Budget_Type_Txt__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP'))) ||
                                                                                                                                         (hasFinanceUserPermission && !hasDCFUserPermission && !hasDCFMDFBudgetPermission && (newPmbRecord.Core_MDF_Legacy_Budget_Ind__c || newPmbRecord.Core_MDF_Budget_Type_Txt__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CMP') || newPmbRecord.Core_MDF_Budget_Type_Txt__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_SP_CMP'))))) || 
                        
                        
                        (newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name') && newPmbRecord.RecordTypeId != ipaProposalBasedRT && !hasIPABudgetPermission) ||
                        
                        (newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Channel_Program_Name') && !hasRetailBudgetPermission) ||
                        (newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name') && hasEEFBudgetApproverPermission) ||
                        (newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Co_GTM_program_name') && !hasCoGTMBudgetPermission) ||
                        (newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCFB_Program_Name')  && ((!hasCCFBUserPermission && !hasFinanceUserPermission) ||
                                                                                                                                           (hasFinanceUserPermission && hasCCFBUserPermission && newPmbRecord.Core_MDF_Budget_Type_Txt__c!=null) || (!hasFinanceUserPermission && hasCCFBUserPermission && newPmbRecord.Core_MDF_Budget_Type_Txt__c==null) ||
                                                                                                                                           (hasFinanceUserPermission && !hasCCFBUserPermission && newPmbRecord.Core_MDF_Budget_Type_Txt__c==null))) ||
                        
                        (newPmbRecord.Core_MDF_Program_Nm__c ==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SPCF_Program_Name') && ((!hasSPCFUserPermission && !hasFinanceUserPermission) ||
                                                                                                                                          (hasFinanceUserPermission && hasSPCFUserPermission && newPmbRecord.Core_MDF_Budget_Type_Txt__c!=null) || (!hasFinanceUserPermission && hasSPCFUserPermission && newPmbRecord.Core_MDF_Budget_Type_Txt__c==null) ||
                                                                                                                                          (hasFinanceUserPermission && !hasSPCFUserPermission && newPmbRecord.Core_MDF_Budget_Type_Txt__c==null)))
                        
                       )){
                           newPmbRecord.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Update_Validation'));
                       }
                }
            }
        }catch(Exception ex){ Core_MDF_CCP_UtilityClass.logError(ex);}  
    }
    /*************************************************************************** 
Method Name:        isBudgetReduction
@return  :          void
@parameters:        budget
Description:        check the budget reduction amount
@Added By:          Accenture- 24/May/2022
Modified By:        Date:       Changes:
*********************************************************************************/
    public static boolean isBudgetReduction(PartnerMarketingBudget newPmbRecord, Map<Id,PartnerMarketingBudget> oldPMBMap){
        Boolean isBudgetReduction = false;
        
        if(newPmbRecord.Amount != oldPMBMap.get(newPmbRecord.Id).Amount && newPmbRecord.Core_MDF_Decrease_Budget_Amount_Amt__c != oldPMBMap.get(newPmbRecord.Id).Core_MDF_Decrease_Budget_Amount_Amt__c
           && newPmbRecord.Core_MDF_Decrease_Budget_Amount_Amt__c==0 && newPmbRecord.Core_MDF_Budget_Status__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Opal_Available_Budget_Status')){
               isBudgetReduction=true;
           }
        return isBudgetReduction;   
    }
    
    /*************************************************************************** 
Method Name:        notifyApprovers
@return  :          void
@parameters:        newbudgetList,oldBudgetMap
Description:        to send email notification to approvers
@Added By:          
Modified By:        Date:       Changes:
*********************************************************************************/
    public static void notifyApprovers(List<PartnerMarketingBudget> newPmbList, Map<Id, PartnerMarketingBudget> oldPMBMap){
        
        List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();
        Map<String, Map<String, List<Id>>> resultMap = new Map<String, Map<String, List<Id>>>();
        List<PartnerMarketingBudget> pendingApprovalPMB = new List<PartnerMarketingBudget>();
        Map<String, String> roleCheckforAccountAccessMap = new Map<String, String>();
        Map<String, String> programToEmailTemplateMap = new Map<String, String>();
        Map<String, String> programToRoleMap = new Map<String, String>(); 
        List<String> approvalStageStatusList = new List<String>(); 
        List<String> budgetTypeList = new List<String>();  
        List<String> programList = new List<String>();  
        List<String> accntList = new List<String>();  
        List<String> roleList = new List<String>();     
        List<String> geoList = new List<String>(); 
        List<String> prgmList = new List<String>();
        String emailTemplate; 
        String category ='notifyIUPGMBasedNotification';
        String categoryGeneralUtility = 'Core_MDF_GeneralPurpose_UI_Utility_Role_Mappings';
        
        try{
            for(PartnerMarketingBudget newPmb: newPmbList){
                PartnerMarketingBudget oldPmb = oldPMBMap != null ? oldPmbMap.get(newPmb.Id) : null;
                if(sendEmailToBudgetApprover(newPmb, oldPmb)){
                    pendingApprovalPMB.add(newPmb);
                    programList.add(newPmb.Core_MDF_Program_Nm__c);
                    budgetTypeList.add(newPmb.Core_MDF_Budget_Type__c);
                    accntList.add(newPmb.Core_MDF_Ultimate_Account_Id__c);
                }
            }
            
            
            if(!pendingApprovalPMB.isEmpty()){
                Map<String,Object> programNameByRecNameMap = Core_MDF_GeneralPurpose_UI_Utility.getProgramNameByRecName();
                for(String prgm : programList){
                    if(programNameByRecNameMap.containsKey(prgm)){
                        prgmList.add((String)programNameByRecNameMap.get(prgm));
                    } else {
                        prgmList.add(prgm);
                    }
                }
                
                //To get role and email template 
                List<Core_MDF_Custom_Label_Configration__mdt> mdtRecList = [SELECT DeveloperName, Core_MDF_Value_Txt__c, 
                                                                            Core_MDF_Value2_Txt__c,Core_MDF_Value3_Txt__c,Core_MDF_Value4_Txt__c, Core_MDF_Category_Txt__c, 
                                                                            Core_MDF_Org_Specific_Ind__c,Core_MDF_Value5_Txt__c
                                                                            FROM Core_MDF_Custom_Label_Configration__mdt 
                                                                            WHERE Core_MDF_Category_Txt__c =: category 
                                                                            AND Core_MDF_Value3_Txt__c = 'None'
                                                                            AND Core_MDF_Value_Txt__c IN: prgmList ];
                
                if(mdtRecList != null && !mdtRecList.isEmpty()){
                    for(Core_MDF_Custom_Label_Configration__mdt meta: mdtRecList){
                        roleList.add(meta.Core_MDF_Value4_Txt__c);
                        programToEmailTemplateMap.put(meta.Core_MDF_Value_Txt__c, meta.Core_MDF_Value2_Txt__c);
                        programToRoleMap.put(meta.Core_MDF_Value_Txt__c, meta.Core_MDF_Value4_Txt__c);
                    }
                }
                
                //To know all account yes or no based on program and role
                List<Core_MDF_Custom_Label_Configration__mdt> mdtAccountRecList =  [SELECT DeveloperName, Core_MDF_Value_Txt__c,Core_MDF_Value2_Txt__c,Core_MDF_Value3_Txt__c,
                                                                                    Core_MDF_Value4_Txt__c,Core_MDF_Category_Txt__c, Core_MDF_Org_Specific_Ind__c
                                                                                    FROM Core_MDF_Custom_Label_Configration__mdt 
                                                                                    WHERE Core_MDF_Category_Txt__c =: categoryGeneralUtility
                                                                                    AND Core_MDF_Value_Txt__c IN: prgmList 
                                                                                    AND Core_MDF_Value2_Txt__c IN: roleList];
                
                if(mdtAccountRecList != null && !mdtAccountRecList.isEmpty()){
                    for(Core_MDF_Custom_Label_Configration__mdt mdtRec: mdtAccountRecList){
                        roleCheckforAccountAccessMap.put(mdtRec.Core_MDF_Value_Txt__c+mdtRec.Core_MDF_Value2_Txt__c, mdtRec.Core_MDF_Value3_Txt__c);
                    } 
                }
                
                //Call IUPGM methods to get the list of users based on account, program, role, budget type
                resultMap = Core_MDF_GeneralPurpose_UI_Utility.getIupgmForApproversWithBudgetType(accntList, programList, geoList,
                                                                                                  roleList, budgetTypeList, approvalStageStatusList);
                for(PartnerMarketingBudget pmb : pendingApprovalPMB){
                    String region = '';
                    String program = '';
                    Map<string, List<Id>> resultsubMap;
                    if(programNameByRecNameMap.containsKey(pmb.Core_MDF_Program_Nm__c)){
                        program = ((String)programNameByRecNameMap.get(pmb.Core_MDF_Program_Nm__c));   
                    } else {
                        program = (String)pmb.Core_MDF_Program_Nm__c;
                    }
                    List<Id> userIds;
                    if(resultMap != null){
                        String role ='';
                        if(programToRoleMap.containsKey(program)){
                            role = programToRoleMap.get(program);
                        }
                        String roleCheckforAccountKey = program + role;
                        String accountAccess = roleCheckforAccountAccessMap.get(roleCheckforAccountKey);
                        
                        //Prepare the key based on different conditions
                        String allAccountNOKey = program + region + role + pmb.Core_MDF_Ultimate_Account_Id__c;
                        String allAccountNOKeyWW = program +'WW'+ role + pmb.Core_MDF_Ultimate_Account_Id__c;
                        String allAccountYesKey = program + region + role +'null';
                        String allAccountYesKeyWW = program + 'WW' + role + 'null';
                        String allAccountNOKeyWithBT = program + region + pmb.Core_MDF_Budget_Type__c + role + pmb.Core_MDF_Ultimate_Account_Id__c;
                        String allAccountNOKeyWithBTWW = program + 'WW' + pmb.Core_MDF_Budget_Type__c + role + pmb.Core_MDF_Ultimate_Account_Id__c;
                        String allAccountYesKeyWithBT = program + region + pmb.Core_MDF_Budget_Type__c + role + 'null';
                        String allAccountYesKeyWithBTWW = program + 'WW' + pmb.Core_MDF_Budget_Type__c + role + 'null';
                        
                        
                        userIds = new List<Id>(); 
                        
                        if(resultMap.containsKey(role) && accountAccess=='allAccountsYesOrNo'){
                            resultsubMap = resultMap.get(role);                        
                            for(String key :resultsubMap.keySet()){
                                if(key == allAccountNOKey || key == allAccountNOKeyWW ||
                                   key == allAccountYesKey || key == allAccountYesKeyWW ||
                                   key  == allAccountNOKeyWithBT || key == allAccountYesKeyWithBT ||
                                   key  == allAccountNOKeyWithBTWW || key == allAccountYesKeyWithBTWW){
                                       userIds.addAll(resultsubMap.get(Key));
                                   }
                            }
                        } 
                        else if(resultMap.containsKey(role) && accountAccess=='allAccountsYes'){
                            resultsubMap = resultMap.get(role);
                            for(String key :resultsubMap.keySet()){
                                if(key == allAccountYesKey || key == allAccountYesKeyWW 
                                   ||key == allAccountYesKeyWithBT || key == allAccountYesKeyWithBTWW){
                                       userIds.addAll(resultsubMap.get(Key));
                                   }
                            }
                        }
                        else if(resultMap.containsKey(role) && accountAccess=='allAccountsNo'){
                            resultsubMap = resultMap.get(role);
                            
                            for(String key :resultsubMap.keySet()){
                                if(key == allAccountNOKey || key == allAccountNOKeyWW  
                                   || key  == allAccountNOKeyWithBT || key == allAccountNOKeyWithBTWW){
                                       userIds.addAll(resultsubMap.get(Key));
                                   }
                            }
                        }
                    }
                    if(programToEmailTemplateMap.containsKey(program)){
                        emailTemplate = programToEmailTemplateMap.get(program);    
                    }
                    
                    //Create MailParams to send email to the users
                    if(userIds != NULL && !userIds.isEmpty()){
                        Core_MDF_GenericClassToSendMail.MailParams sendEmailToBudgetApprover = new Core_MDF_GenericClassToSendMail.MailParams();
                        sendEmailToBudgetApprover.recordId = pmb.Id;
                        sendEmailToBudgetApprover.templateName = emailTemplate;
                        sendEmailToBudgetApprover.userIdList = userIds;
                        sendEmailToBudgetApprover.sendDiff = false;
                        inputList.add(sendEmailToBudgetApprover);
                    }
                }
                //Send email to the users
                if(inputList != NULL && inputList.size() > 0 && sendEmailOnce){
                    Core_MDF_GenericClassToSendMail.sendEmailMethod(inputList); 
                    sendEmailOnce = false;
                }
            }
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    /****************************************************************************************************** 
Method Name:        sendEmailToBudgetApprover
@return  :          Boolean
@parameters:        New_PMB
Description:        
Added By:           
Modified By:         
*******************************************************************************************************/
    public static Boolean sendEmailToBudgetApprover(PartnerMarketingBudget newPmb, PartnerMarketingBudget oldPmb){
        Boolean isSendEmail = false;
        Boolean isInsert = oldPmb != null ? false : true;
        
        
        if((isInsert == true || (isInsert == false && newPmb.Core_MDF_Budget_Status__c != oldPmb.Core_MDF_Budget_Status__c))
           && newPmb.Core_MDF_Budget_Status__c == Core_MDF_CCP_ConstantClass.Budget_PENDING_REVIEW
           && (newPmb.Core_MDF_Budget_Type__c == Core_MDF_CCP_ConstantClass.MDF_BUDGET_TYPE || newPmb.Core_MDF_Budget_Type__c == Core_MDF_CCP_ConstantClass.MDFPLUS_BUDGET_TYPE
               || newPmb.Core_MDF_Program_Nm__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM || newPmb.Core_MDF_Program_Nm__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM || newPmb.Core_MDF_Program_Nm__c == Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM)){
                   isSendEmail = true;
               }
        
        return isSendEmail;
    }
    
    /****************************************************************************************************** 
Method Name:        Core_MDF_RestrictLegacyBudgetCreation
@return  :          Boolean
@parameters:        New_PMB
Description:        Method added to restrict legacy budget creation
Added By:           Mohit Sharma
Modified By:         
*******************************************************************************************************/
    public static void restrictLegacyBudgetCreation(List<PartnerMarketingBudget> newPMBList){
        List<string> budgetLegacyPrograms = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_LegacyBudgetPrograms').split(',');
        try{
            for(PartnerMarketingBudget newPmbRecord : newPMBList){
                if( budgetLegacyPrograms.contains(newPmbRecord.Core_MDF_Program_Nm__c) || 
                   (newPmbRecord.Core_MDF_Budget_Type_Txt__c!=null && System.Label.Core_MDF_LegacyRestricBudgetTypes.contains(newPmbRecord.Core_MDF_Budget_Type_Txt__c))){
                       newPmbRecord.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Legacy_Budget_Creation_Error'));
                   }
            }
        }catch(Exception ex){ Core_MDF_CCP_UtilityClass.logError(ex);} 
        
    }
    /****************************************************************************************************** 
Method Name:        processAccountBenefitAssociations
@return  :          void
@parameters:        benefitSet, setOfOnePartnerIds, accIdToBenefitsMap, budTypeToBenefitsMap, ipaPmbIdToPmbMap, mapOfIntelAccountandPrimeId, mapOfUCDIdSetofOPId, accInIpaAffiliation
Description:        Method added to validate the budgettype and it's access for particular account on PMB creation through Account Benefit Association Object
Added By:           Ramapriya Rajesh
Modified By:         
*******************************************************************************************************/
    
    public static void processAccountBenefitAssociations(Set<String> benefitSet, Set<Id> setOfOnePartnerIds, Map<Id,Set<String>> accIdToBenefitsMap, Map<String, Set<String>> budTypeToBenefitsMap, Map<Id, PartnerMarketingBudget> ipaPmbIdToPmbMap, Map<Id, String> mapOfIntelAccountandPrimeId, Map<String, Set<Id>> mapOfUCDIdSetofOPId, List<Id> accInIpaAffiliation) {
        
        for(PRM_AccountBenefitAssociation__c  accountBenefitAscRec: [SELECT ID,PRM_Account_Id__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c from PRM_AccountBenefitAssociation__c
                                                                     where PRM_Account_Id__r.RecordType.DeveloperName ='Core_Partner_Account_Group' AND PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c IN:(benefitSet) AND PRM_Account_Id__c IN: (setOfOnePartnerIds) AND PRM_Status_Nm__c = 'Active'])
        {
            
            if(accIdToBenefitsMap.containsKey(accountBenefitAscRec.PRM_Account_Id__c)){
                accIdToBenefitsMap.get(accountBenefitAscRec.PRM_Account_Id__c).add(accountBenefitAscRec.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c);
            }else{
                accIdToBenefitsMap.put(accountBenefitAscRec.PRM_Account_Id__c, new set<String>{accountBenefitAscRec.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c});
            } 
            
        }
        for(PartnerMarketingBudget pmbObj : ipaPmbIdToPmbMap.values()){                
            Boolean isBenefitAssociated = false;
            
            //mapOfIntelAccountandPrimeId-> key= Ultimate Account of Budget;value= UCD Id
            //mapOfUCDIdSetofOPId->key= UCD Id of Budget's Ultimate Account;value=set of OPID Accounts
            if(!mapOfIntelAccountandPrimeId.isEmpty() && mapOfIntelAccountandPrimeId.containsKey(pmbObj.Core_MDF_Ultimate_Account_Id__c) && mapOfIntelAccountandPrimeId.get(pmbObj.Core_MDF_Ultimate_Account_Id__c) != NULL &&
               (!mapOfUCDIdSetofOPId.isEmpty() && mapOfUCDIdSetofOPId.containsKey(mapOfIntelAccountandPrimeId.get(pmbObj.Core_MDF_Ultimate_Account_Id__c)) && mapOfUCDIdSetofOPId.get(mapOfIntelAccountandPrimeId.get(pmbObj.Core_MDF_Ultimate_Account_Id__c)) != NULL ))
            {
                
                // Iterate over set of opid accounts 
                
                for(Id accId :mapOfUCDIdSetofOPId.get(mapOfIntelAccountandPrimeId.get(pmbObj.Core_MDF_Ultimate_Account_Id__c))) {
                    if(!accIdToBenefitsMap.isEmpty() && accIdToBenefitsMap.containsKey(accId) && accIdToBenefitsMap.get(accId) != NULL){
                        for(String benefit: accIdToBenefitsMap.get(accId)){
                            if(!isBenefitAssociated && (budTypeToBenefitsMap.get(pmbObj.Core_MDF_Budget_Type_Txt__c)).contains(benefit)){
                                isBenefitAssociated = true;
                                break;
                            }
                        }                            
                    }
                    if(isBenefitAssociated){break;}
                }
                if(!isBenefitAssociated){
                    pmbObj.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPABudgetTypeAccessError'));
                }
                if(accInIpaAffiliation.contains(pmbObj.Core_MDF_Ultimate_Account_Id__c)){
                    pmbObj.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPABudgetAffiliationError'));
                }
            }
            else{
                pmbObj.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPABudgetTypeAccessError'));
            }
        }
    }
    
    /****************************************************************************************************** 
Method Name:        processAccountSpecialtyAssociations
@return  :          void
@parameters:        benefitSet, allIntelAccIdSet, accIdToBenefitsMap, budTypeToBenefitsMap, ipaPmbIdToPmbMap, mapOfIntelAccountandPrimeId, mapOfPrimeIdSetofAccountId, accInIpaAffiliation
Description:        Method added to validate the budgettype and it's access for particular account on PMB creation through Account Specialty Association Object
Added By:           Ramapriya Rajesh
Modified By:         
*******************************************************************************************************/
    
    public static void processAccountSpecialtyAssociations(Set<String> benefitSet, Set<Id> allIntelAccIdSet, Map<Id, Set<String>> accIdToBenefitsMap, Map<String, Set<String>> budTypeToBenefitsMap, Map<Id, PartnerMarketingBudget> ipaPmbIdToPmbMap, Map<Id, String> mapOfIntelAccountandPrimeId, Map<String, Set<Id>> mapOfPrimeIdSetofAccountId, List<Id> accInIpaAffiliation) {
        //Quering existig account specialty association records, to check for MDF specialty corresponding to account Id or primeId
        for(PRM_Account_Specialty_Association__c accSpecialtRec : [SELECT ID, PRM_Account_Id__c, PRM_Specialty_Id__r.name from PRM_Account_Specialty_Association__c
                                                                   where PRM_Specialty_Id__r.name IN: (benefitSet) AND PRM_Account_Id__c IN: (allIntelAccIdSet) and PRM_InActive_Ind__c = FALSE])
        {
            if(accIdToBenefitsMap.containsKey(accSpecialtRec.PRM_Account_Id__c)){
                accIdToBenefitsMap.get(accSpecialtRec.PRM_Account_Id__c).add(accSpecialtRec.PRM_Specialty_Id__r.name);
            }else{
                accIdToBenefitsMap.put(accSpecialtRec.PRM_Account_Id__c, new set<String>{accSpecialtRec.PRM_Specialty_Id__r.name});
            }
        }
        
        for(PartnerMarketingBudget pmbObj : ipaPmbIdToPmbMap.values()){                
            Boolean isBenefitAssociated = false;
            if(!mapOfIntelAccountandPrimeId.isEmpty() && mapOfIntelAccountandPrimeId.containsKey(pmbObj.Core_MDF_Ultimate_Account_Id__c) && mapOfIntelAccountandPrimeId.get(pmbObj.Core_MDF_Ultimate_Account_Id__c) != NULL &&
               !mapOfPrimeIdSetofAccountId.isEmpty() && mapOfPrimeIdSetofAccountId.containsKey(mapOfIntelAccountandPrimeId.get(pmbObj.Core_MDF_Ultimate_Account_Id__c)) && mapOfPrimeIdSetofAccountId.get(mapOfIntelAccountandPrimeId.get(pmbObj.Core_MDF_Ultimate_Account_Id__c)) != NULL)
            {
                for(Id accId :mapOfPrimeIdSetofAccountId.get(mapOfIntelAccountandPrimeId.get(pmbObj.Core_MDF_Ultimate_Account_Id__c))) {
                    if(!accIdToBenefitsMap.isEmpty() && accIdToBenefitsMap.containsKey(accId) && accIdToBenefitsMap.get(accId) != NULL){
                        for(String benefit: accIdToBenefitsMap.get(accId)){
                            if(!isBenefitAssociated && (budTypeToBenefitsMap.get(pmbObj.Core_MDF_Budget_Type_Txt__c)).contains(benefit)){
                                isBenefitAssociated = true;
                                break;
                            }                          
                        }                            
                    }
                    if(isBenefitAssociated){break;}
                }
                if(!isBenefitAssociated){
                    pmbObj.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPABudgetTypeAccessError'));
                }
                if(accInIpaAffiliation.contains(pmbObj.Core_MDF_Ultimate_Account_Id__c)){
                    pmbObj.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPABudgetAffiliationError'));
                }
            }else{
                pmbObj.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPABudgetTypeAccessError'));
            }
        }
    }
}