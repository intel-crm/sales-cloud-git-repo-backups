/****************************************************************************************************************************************
* Class Name  : Core_MDF_Account_PGM_Sync_ServiceHandler
* Version     : 1.0 
* Created Date: 02/16/2023
* Modification Log :
* Developer                     Date                        Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* JB - Accenture    		02/16/2023                    
* *****************************************************************************************************************************************/
public without sharing class Core_MDF_Account_PGM_Sync_ServiceHandler {

    //Get the channel Program id of IPA program
    private static Core_MDF_ChannelProgram__mdt channelProgramDetailsOfIPA = Core_MDF_ChannelProgram__mdt.getInstance('Intel_Partner_Alliance');
    private static string externalType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External');
    private static String ipaTechnicalProgramName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name');

    private static Map<Id,Core_MDF_Partner_Group_Mapping__c> pgmToActivateExistingMap = new Map<Id,Core_MDF_Partner_Group_Mapping__c>();
    private static List<Core_MDF_Partner_Group_Mapping__c> pgmToCreateList = new List<Core_MDF_Partner_Group_Mapping__c>();

    private static Map<Id, List<String>> nonCoMarkRecordIdToActionsMap = new Map<Id, List<String>>();
    private static Set<Id> nonCoMarkAccountIdsToSendEmail = new Set<Id>();

    private static Map<Id, List<String>> recordIdToFieldValuesMap = new Map<Id, List<String>>();
    private static Map<Id,String> recordIdToAccountNameMap = new Map<Id,String>();
    private static List<String> actionList = new List<String>();
    private static String actions = '';
    //added by JK to replace prime id with UCD id field
    public static boolean isUnifiedIdEnabled = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_UnifiedIdCheck');
    public static String isUnifiedIdOrPrimeIdErrorMessage = 'Unified ID';
    public static List<Core_MDF_BudgetType_Benefit_Mappings__c> budgetTypeBenefitMapping = new List<Core_MDF_BudgetType_Benefit_Mappings__c>();
    public static  String objectApiName = 'Core_MDF_BudgetType_Benefit_Mappings__c';
    public static Boolean optAccountBenefitAssociation = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_OptAccountBenefitAssoc');

    /*****************************************************************************************************                              
    Method Name   :        processRecords                                
    @return       :        void                          
    @parameters   :        List<Core_MDF_Account_PGM_Sync__e>
    Description   :        To process Account, Account Specialty Association, IPA Affiliation records
    Added By      :        JB - Accenture - 02/16/2023
    Modified By   :        Date:           Changes:                                 
    JB - Accenture         02/16/2023      To process Account, Account Specialty Association, IPA Affiliation records                     
    ******************************************************************************************************/
    public static void processRecords(List<Core_MDF_Account_PGM_Sync__e> newList){

        Map<Id, Account> accountIdToOldAccountRecMap = new Map<Id, Account>();
        Map<Id, List<PRM_IPA_Affiliation__c>> accountIdToIpaAffilicationRecsMap = new Map<Id, List<PRM_IPA_Affiliation__c>>();
        Map<Id,String> recordIdToDmlOperationType = new Map<Id,String>();
        Set<Id> accountIdSet = new Set<Id>();

        //Roshan
        Map<Id, List<AccountBenefitAssociationWrapper>> accountIdToAssociationRecsMap = new Map<Id, List<AccountBenefitAssociationWrapper>>();
        Set<Id> opidSet = new Set<Id>();
        PRM_AccountBenefitAssociation__c abaRecord;
        Map<Id, Set<Id>> mapOfOPIDtoSetofAccountId = new Map<Id, Set<Id>>();
	
        try{
            for(Core_MDF_Account_PGM_Sync__e  eventRecord : newList){

                SObject sobj = (SObject) JSON.deserialize(eventRecord.Core_MDF_JSON_Data__c, SObject.class);

                switch on eventRecord.Core_MDF_Object_API_Name__c {
                    when 'Account' {
                        Account accountRecord = (Account)sobj;
                        accountIdToOldAccountRecMap.put(accountRecord.Id, accountRecord);
                        accountIdSet.add(accountRecord.Id);
                    }
		    
		    when 'PRM_Account_Specialty_Association__c' {
                        PRM_Account_Specialty_Association__c asaRecord = (PRM_Account_Specialty_Association__c)sobj;
                        String status = asaRecord.PRM_InActive_Ind__c ? 'Inactive' : 'Active';

                        List<AccountBenefitAssociationWrapper> assocList = accountIdToAssociationRecsMap.get(asaRecord.PRM_Account_Id__c);
                        if(assocList == null) {
                            assocList = new List<AccountBenefitAssociationWrapper>();
                            accountIdToAssociationRecsMap.put(asaRecord.PRM_Account_Id__c, assocList);
                        }

                        assocList.add(new AccountBenefitAssociationWrapper(asaRecord.PRM_Account_Id__c, status, asaRecord.Id));
                        accountIdSet.add(asaRecord.PRM_Account_Id__c);
                    }

                    when 'PRM_AccountBenefitAssociation__c' {
                        //Preparing OPID set just for ABA
                        abaRecord = (PRM_AccountBenefitAssociation__c)sobj;
                        opidSet.add(abaRecord.PRM_Account_Id__c);
                    }
                    when 'PRM_IPA_Affiliation__c' {
                        PRM_IPA_Affiliation__c ipaAffiliationRecord = (PRM_IPA_Affiliation__c)sobj;

                        if(accountIdToIpaAffilicationRecsMap.containsKey(ipaAffiliationRecord.PRM_Account__c)){
                            accountIdToIpaAffilicationRecsMap.get(ipaAffiliationRecord.PRM_Account__c).add(ipaAffiliationRecord);
                        }else{
                            accountIdToIpaAffilicationRecsMap.put(ipaAffiliationRecord.PRM_Account__c, new List<PRM_IPA_Affiliation__c>{ipaAffiliationRecord});
                        }
                        accountIdSet.add(ipaAffiliationRecord.PRM_Account__c);
                    }
                }
                recordIdToDmlOperationType.put(sobj.Id, eventRecord.Core_MDF_DML_Operation_Type_txt__c);
            }

            if (!opidSet.isEmpty() && optAccountBenefitAssociation) {
                for (Account acc : [SELECT Id, Core_IPA_One_Partner_Id__c FROM Account WHERE Core_IPA_One_Partner_Id__c IN :opidSet AND RecordType.DeveloperName = 'Mastered_Account' AND Core_Intel_Partner_Alliance_PartnerGroup__c = TRUE]) {
                    Id opid = acc.Core_IPA_One_Partner_Id__c;

                    if (!mapOfOPIDtoSetofAccountId.containsKey(opid)) {
                        mapOfOPIDtoSetofAccountId.put(opid, new Set<Id>());
                    }
                    mapOfOPIDtoSetofAccountId.get(opid).add(acc.Id);
                
                    if(abaRecord != null) {
                        List<AccountBenefitAssociationWrapper> assocList = accountIdToAssociationRecsMap.get(acc.Id);
                        if (assocList == null) {
                            assocList = new List<AccountBenefitAssociationWrapper>();
                            accountIdToAssociationRecsMap.put(acc.Id, assocList);
                        }
                        assocList.add(new AccountBenefitAssociationWrapper(acc.Id, abaRecord.PRM_Status_Nm__c, abaRecord.Id));
                        accountIdSet.add(acc.Id);  
                    }
                }
            }
            
            processAccounts(accountIdSet, accountIdToOldAccountRecMap, accountIdToAssociationRecsMap, accountIdToIpaAffilicationRecsMap, recordIdToDmlOperationType, mapOfOPIDtoSetofAccountId);

        }catch(Exception e){Core_MDF_CCP_UtilityClass.logErrorinLogObject(Core_MDF_CCP_UtilityClass.getErrorDetails(e) + ' \n' + prepareEmailContent(recordIdToFieldValuesMap, recordIdToAccountNameMap, new List<String>{'Account Id', 'Account Name', 'Action' }).unescapeHtml4(), 'Account');}
        
    }


    /*****************************************************************************************************                              
    Method Name   :        processAccounts                                
    @return       :        void                          
    @parameters   :        Map<Id, SObject>
    Description   :        To process Account records
    Added By      :        JB - Accenture - 02/16/2023
    Modified By   :        Date:           Changes:                                 
    JB - Accenture         02/16/2023      To process Account records                     
    ******************************************************************************************************/
    public static void processAccounts(Set<Id> accountIdSet, Map<Id, Account> accountIdToOldAccountRecMap, Map<Id, List<AccountBenefitAssociationWrapper>> accountIdToAssociationRecsMap, Map<Id, List<PRM_IPA_Affiliation__c>> accountIdToIpaAffilicationRecsMap, Map<Id,String> recordIdToDmlOperationType, Map<Id, Set<Id>> mapOfOPIDtoSetofAccountId) {
        
        Set<Id> accountIdToInactivatePGMSet = new Set<Id>();
        //Set<Id> accountIdToCreatePGMSet = new Set<Id>();
        Map<Id,String> accountIdToUnifiedIdMap = new Map<Id,String>();//changed from accountIdToPrimeIdMap to accountIdToUnifiedIdMap
       // Set<Id> coMarketingActiveAccountIds = new Set<Id>();
        Map<Id,Core_MDF_Partner_Group_Mapping__c> pgmToInactivateMap = new Map<Id, Core_MDF_Partner_Group_Mapping__c>();

        Map<Id, Account> newAccountMap = new Map<Id, Account>();
        Map<Id,String> accountIdsToUnifiedIdToIgnoreMap = new Map<Id,String>();//changed from accountIdsToPrimeIdToIgnoreMap to accountIdsToUnifiedIdToIgnoreMap
        //added by JK to replace primeID with Unified Id field
        String accountIdSetQuery = '(\''+String.join(new List<Id>(accountIdSet), '\', \'') + '\')';
        String whereClause = ' Id IN '+accountIdSetQuery;
        List<Account> accounts = Core_MDF_Account_Utility.fetchAccounts(whereClause);
        for(Account acc : accounts){
            String accPrimeIdOrUnifiedField = acc.Core_Unified_Global_Customer_BP_Id__c;
		
		if(mapOfOPIDtoSetofAccountId.isEmpty() && optAccountBenefitAssociation) {
                    if (acc.Core_IPA_One_Partner_Id__c != null) {
                        if (!mapOfOPIDtoSetofAccountId.containsKey(acc.Core_IPA_One_Partner_Id__c)) {
                            mapOfOPIDtoSetofAccountId.put(acc.Core_IPA_One_Partner_Id__c, new Set<Id>());
                        }
                        mapOfOPIDtoSetofAccountId.get(acc.Core_IPA_One_Partner_Id__c).add(acc.Id);
        	    }
                 }
		 
                if(acc.Core_MDF_CoMarketingActive__c){

                //Co-Marketing Active Accounts email contents
                //Account
                if(accountIdToOldAccountRecMap.containsKey(acc.Id)){
                    recordIdToFieldValuesMap = addAccountActions(recordIdToFieldValuesMap, accountIdToOldAccountRecMap.get(acc.Id), acc);
                }

                //Roshan - ASA + ABA
                if(accountIdToAssociationRecsMap.containsKey(acc.Id) && accountIdToAssociationRecsMap.get(acc.Id).size() > 0){
                    for(AccountBenefitAssociationWrapper wrapper : accountIdToAssociationRecsMap.get(acc.Id)){
                        if(wrapper.status == 'Inactive' && recordIdToDmlOperationType.containsKey(wrapper.recordId) && recordIdToDmlOperationType.get(wrapper.recordId) == 'Update'){
                            String newStatus = (wrapper.status == 'Inactive') ? 'Active' : 'Inactive';
                            recordIdToFieldValuesMap = addAsaOrIpaAffiliationActions(recordIdToFieldValuesMap, acc, wrapper.recordId, 'MDF Benefit record', newStatus, wrapper.status);
                            accountIdsToUnifiedIdToIgnoreMap.put(acc.Id, accPrimeIdOrUnifiedField);
                        }
                    }
                }


                //IPA Affiliation
                if(accountIdToIpaAffilicationRecsMap.containsKey(acc.Id) && accountIdToIpaAffilicationRecsMap.get(acc.Id).size() > 0){
                    for(PRM_IPA_Affiliation__c ipaAffiliation : accountIdToIpaAffilicationRecsMap.get(acc.Id)){
                        recordIdToFieldValuesMap = addAsaOrIpaAffiliationActions(recordIdToFieldValuesMap, acc, ipaAffiliation.Id, 'MDF-Excluded Partner', String.valueOf(!ipaAffiliation.PRM_Active__c), String.valueOf(ipaAffiliation.PRM_Active__c));
                    }
                }
                }
                else{ 
                        if(acc.Core_Intel_Partner_Alliance_PartnerGroup__c && String.isNotBlank(accPrimeIdOrUnifiedField)){ //Ignore IPA Active FALSE records
                            newAccountMap.put(acc.Id, acc);
                            accountIdToUnifiedIdMap.put(acc.Id, accPrimeIdOrUnifiedField);
                        }else{
                            accountIdToInactivatePGMSet.add(acc.Id);
                        }
                //String accIdToOldAccRecMapFieldReplace = isUnifiedIdEnabled  ? ((accountIdToOldAccountRecMap.containsKey(acc.Id)) ? accountIdToOldAccountRecMap.get(acc.Id).Core_Unified_Global_Customer_BP_Id__c : '') : ((accountIdToOldAccountRecMap.containsKey(acc.Id)) ? accountIdToOldAccountRecMap.get(acc.Id).Core_Prime_Id__c : '');  
		String accIdToOldAccRecMapFieldReplace = accountIdToOldAccountRecMap.containsKey(acc.Id) ? accountIdToOldAccountRecMap.get(acc.Id).Core_Unified_Global_Customer_BP_Id__c : '' ;  
                    //If Unified Id changed on Account record
                        if(accountIdToOldAccountRecMap.containsKey(acc.Id) && String.isNotBlank(accIdToOldAccRecMapFieldReplace/*accountIdToOldAccountRecMap.get(acc.Id).Core_Prime_Id__c*/) && /*accountIdToOldAccountRecMap.get(acc.Id).Core_Prime_Id__c*/accIdToOldAccRecMapFieldReplace != accPrimeIdOrUnifiedField/*acc.Core_Prime_Id__c*/){
                            accountIdToInactivatePGMSet.add(acc.Id);
                        }


                //Non Co-Marketing Active Accounts email contents
                //Account
                if(accountIdToOldAccountRecMap.containsKey(acc.Id)){
                    nonCoMarkRecordIdToActionsMap = addAccountActions(nonCoMarkRecordIdToActionsMap, accountIdToOldAccountRecMap.get(acc.Id), acc);
                }

		// Roshan - ASA + ABA
                if(accountIdToAssociationRecsMap.containsKey(acc.Id) && accountIdToAssociationRecsMap.get(acc.Id).size() > 0) {
                    for (AccountBenefitAssociationWrapper wrapper : accountIdToAssociationRecsMap.get(acc.Id)) {
                        String newStatus = (wrapper.status == 'Inactive') ? 'Active' : 'Inactive';
                        nonCoMarkRecordIdToActionsMap = addAsaOrIpaAffiliationActions(nonCoMarkRecordIdToActionsMap, acc, wrapper.recordId, 'MDF Benefit record', newStatus, wrapper.status);
                    }
                }


                //IPA Affiliation
                if(accountIdToIpaAffilicationRecsMap.containsKey(acc.Id) && accountIdToIpaAffilicationRecsMap.get(acc.Id).size() > 0){
                    for(PRM_IPA_Affiliation__c ipaAffiliation : accountIdToIpaAffilicationRecsMap.get(acc.Id)){
                        nonCoMarkRecordIdToActionsMap = addAsaOrIpaAffiliationActions(nonCoMarkRecordIdToActionsMap, acc, ipaAffiliation.Id, 'MDF-Excluded Partner', String.valueOf(!ipaAffiliation.PRM_Active__c), String.valueOf(ipaAffiliation.PRM_Active__c));
                    }
                }
            }
        }

        //Only for ASA Records
        /*if(accountIdsToPrimeIdToIgnoreMap != null && !accountIdsToPrimeIdToIgnoreMap.isEmpty()){
            checkMdfBenefitsWithPrimeId(accountIdsToPrimeIdToIgnoreMap);
        }*/
        
        if(newAccountMap != null && !newAccountMap.isEmpty()){

            Set<Id> accountIds = newAccountMap.keySet();
            accountIds.removeAll(filterRecordsToCreateOrUpdatePGM(newAccountMap.keySet(), accountIdToUnifiedIdMap, mapOfOPIDtoSetofAccountId)); //Remove the Account Id which passed all conditions(IPA Active, Having ASA, Not included in IPA Affiliation, Has Co-marketing active Account)

            //Add the remaining Account Ids to inactive the existing PGM records.
            if(!accountIds.isEmpty()){
                accountIdToInactivatePGMSet.addAll(accountIds);
            }
        }

        if(!accountIdToInactivatePGMSet.isEmpty()){
            pgmToInactivateMap.putAll(inactivatePGMRecords(accountIdToInactivatePGMSet));
        }

        Map<Id, Core_MDF_Partner_Group_Mapping__c> finalPgmMapToUpdate = new Map<Id, Core_MDF_Partner_Group_Mapping__c>();
        /*List<Core_MDF_UserGroupMapping_Log__c> userGroupMappingList = new List<Core_MDF_UserGroupMapping_Log__c>();
        Core_MDF_Partner_Group_Mapping__c pgmRecord = new Core_MDF_Partner_Group_Mapping__c();*/

        for(Core_MDF_Partner_Group_Mapping__c pgmToUpdate : pgmToInactivateMap.values()){
            finalPgmMapToUpdate.put(pgmToUpdate.Id, new Core_MDF_Partner_Group_Mapping__c(Id = pgmToUpdate.Id, Core_MDF_Inactive_Ind__c = pgmToUpdate.Core_MDF_Inactive_Ind__c));
        }

        if(finalPgmMapToUpdate != null && !finalPgmMapToUpdate.isEmpty()){
            List<Database.SaveResult> uResults = Database.update(finalPgmMapToUpdate.values(), false);//Updating existing PGM records
        
            /*for(Database.SaveResult ur : uResults){
                if(ur.isSuccess()){
                    pgmRecord = pgmToInactivateMap.get(ur.getId());
                    String action = 'PGM Inactivate';
                    userGroupMappingList.add(new Core_MDF_UserGroupMapping_Log__c(Core_MDF_Error_Message_txt__c = pgmRecord.Id, Core_MDF_Group_id__c = pgmRecord.Core_MDF_Group_Id__c, Core_MDF_Account_id__c = pgmRecord.Core_MDF_Account__c, Core_MDF_Channel_Program_id__c = pgmRecord.Core_MDF_Channel_Program__c, Core_MDF_Action_nm__c= action, Core_MDF_Status_nm__c = 'Completed', Core_MDF_Processed_dtm__c = System.now()));
                }
            }*/
        }

        Map<Id, Core_MDF_Partner_Group_Mapping__c> finalPgmMapToActivate = new Map<Id, Core_MDF_Partner_Group_Mapping__c>();
        for(Core_MDF_Partner_Group_Mapping__c pgmToUpdate : pgmToActivateExistingMap.values()){
            finalPgmMapToActivate.put(pgmToUpdate.Id, new Core_MDF_Partner_Group_Mapping__c(Id = pgmToUpdate.Id, Core_MDF_Inactive_Ind__c = pgmToUpdate.Core_MDF_Inactive_Ind__c));
        }

        if(finalPgmMapToActivate != null && !finalPgmMapToActivate.isEmpty()){
            List<Database.SaveResult> uResults = Database.update(finalPgmMapToActivate.values(), false);//Updating existing PGM records
        
            /*for(Database.SaveResult ur : uResults){
                if(ur.isSuccess()){
                    pgmRecord = pgmToActivateExistingMap.get(ur.getId());
                    String action = 'PGM Activate';
                    userGroupMappingList.add(new Core_MDF_UserGroupMapping_Log__c(Core_MDF_Error_Message_txt__c = pgmRecord.Id, Core_MDF_Group_id__c = pgmRecord.Core_MDF_Group_Id__c, Core_MDF_Account_id__c = pgmRecord.Core_MDF_Account__c, Core_MDF_Channel_Program_id__c = pgmRecord.Core_MDF_Channel_Program__c, Core_MDF_Action_nm__c= action, Core_MDF_Status_nm__c = 'Completed', Core_MDF_Processed_dtm__c = System.now()));
                }
            }*/
        }

        if(!pgmToCreateList.isEmpty()){
            //Map<Id, Core_MDF_Partner_Group_Mapping__c> insertedPgmMap = new Map<Id, Core_MDF_Partner_Group_Mapping__c>();
            List<Database.SaveResult> sResults = Database.insert(pgmToCreateList, false);//Inerting new PGM records
            
            /*for(Core_MDF_Partner_Group_Mapping__c pgm : pgmToCreateList){
                if(String.isNotBlank(pgm.Id)){
                    insertedPgmMap.put(pgm.Id, pgm);
                }
            }
            
            for(Database.SaveResult sr : sResults){
                if(sr.isSuccess()){
                    pgmRecord = insertedPgmMap.get(sr.getId());
                    userGroupMappingList.add(new Core_MDF_UserGroupMapping_Log__c(Core_MDF_Error_Message_txt__c = pgmRecord.Id, Core_MDF_Group_id__c = pgmRecord.Core_MDF_Group_Id__c, Core_MDF_Account_id__c = pgmRecord.Core_MDF_Account__c, Core_MDF_Channel_Program_id__c = pgmRecord.Core_MDF_Channel_Program__c, Core_MDF_Action_nm__c = 'Add', Core_MDF_Status_nm__c = 'Completed', Core_MDF_Processed_dtm__c = System.now()));
                }
            }*/
        }

        /*if(!userGroupMappingList.isEmpty()){
            Database.insert(userGroupMappingList, false);
        }*/

        //Include Non Co-marketning account details if it satisfies all the criteria's but not onboardced yet.
        for(Id recId : nonCoMarkAccountIdsToSendEmail){
            if(nonCoMarkRecordIdToActionsMap.containsKey(recId) && nonCoMarkRecordIdToActionsMap.get(recId).size() > 0){
                recordIdToFieldValuesMap.put(recId, nonCoMarkRecordIdToActionsMap.get(recId));
            }
        }

        //Send email to Co-Marketing Active accounts
        if(recordIdToFieldValuesMap != null && !recordIdToFieldValuesMap.isEmpty()){

            //To By-pass the email sending
            //if(!Core_MDF_Utility.byPassFeature('Bypass_AccountPgmSyncEmailNotification')){
            //ATHR Fix - Deeply nested if
            if(Core_MDF_Utility.byPassFeature('Bypass_AccountPgmSyncEmailNotification')){  
                return;
            }//ATHR End
            String emailContent = prepareEmailContent(recordIdToFieldValuesMap, recordIdToAccountNameMap, new List<String>{'Account Id', 'Account Name', 'Action' });
            
            List<String> emailRecipiants = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Emails');
            if(!emailRecipiants.isEmpty()){
                Messaging.SingleEmailMessage emailObj = new Messaging.SingleEmailMessage();
                emailObj.setToAddresses(emailRecipiants);
                emailObj.setSaveAsActivity(false);
                emailObj.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
                emailObj.setSubject('Action Required: IPA Physical Accounts was updated');
                emailObj.setHtmlBody(emailContent);
                
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emailObj});
            }
            //} ATHR Comment
        }
    }

    /*****************************************************************************************************                              
    Method Name   :        checkMdfBenifitsWithPrimeId                                
    @return       :        void                          
    @parameters   :        Map<Id, SObject>
    Description   :        To process Account records
    Added By      :        JB - Accenture - 02/16/2023
    Modified By   :        Date:           Changes:                                 
    JB - Accenture         02/16/2023                          
    ******************************************************************************************************/
    /*public static void checkMdfBenefitsWithPrimeId(Map<Id,String> accountIdsToPrimeIdToIgnoreMap){
        System.debug('recordIdToFieldValuesMap1::' + recordIdToFieldValuesMap);
        Map<Id, String> allAccountIdToPrimeIdMap = new Map<Id, String>();
        Set<String> primeIdSet = new Set<String>();
        //Query Accounts with Prime Id
        for(Account acc: [SELECT Id, Core_Prime_Id__c, Core_MDF_CoMarketingActive__c, Core_Intel_Partner_Alliance_PartnerGroup__c FROM Account WHERE Core_Prime_Id__c IN: (new Set<String>(accountIdsToPrimeIdToIgnoreMap.values())) ORDER BY Core_MDF_CoMarketingActive__c DESC]){
            allAccountIdToPrimeIdMap.put(acc.Id, acc.Core_Prime_Id__c);
        }

        for(Id accountId : hasMDFBenefit(allAccountIdToPrimeIdMap.keySet())){
            if(allAccountIdToPrimeIdMap.containsKey(accountId)){
                primeIdSet.add(allAccountIdToPrimeIdMap.get(accountId));
            }
        }

        for(Id accountId : accountIdsToPrimeIdToIgnoreMap.keySet()){
            if(primeIdSet.contains(accountIdsToPrimeIdToIgnoreMap.get(accountId)) && recordIdToFieldValuesMap.containsKey(accountId)){
                recordIdToFieldValuesMap.remove(accountId);
            }
        }
        System.debug('recordIdToFieldValuesMap2::' + recordIdToFieldValuesMap);
    }*/

    /*****************************************************************************************************                              
    Method Name   :        addAccountActions                                
    @return       :        void                          
    @parameters   :        Map<Id, SObject>
    Description   :        To process Account records
    Added By      :        JB - Accenture - 02/16/2023
    Modified By   :        Date:           Changes:                                 
    JB - Accenture         02/16/2023      To process Account records                     
    ******************************************************************************************************/
    public static Map<Id, List<String>> addAccountActions(Map<Id, List<String>> recordIdToFieldValuesMap, Account oldRecord, Account newRecord){
        actions = '';
        actionList = new List<String>();
        //added by JK to replace prime id with UCD id field
        //String primeIdOrUnifiedFieldOld = isUnifiedIdEnabled?oldRecord.Core_Unified_Global_Customer_BP_Id__c:oldRecord.Core_Prime_Id__c;
        String primeIdOrUnifiedFieldOld = oldRecord.Core_Unified_Global_Customer_BP_Id__c;
        //String primeIdOrUnifiedFieldNew = isUnifiedIdEnabled?newRecord.Core_Unified_Global_Customer_BP_Id__c:newRecord.Core_Prime_Id__c;
        String primeIdOrUnifiedFieldNew = newRecord.Core_Unified_Global_Customer_BP_Id__c;
          //If Unified Id changed
        if(String.isNotBlank(primeIdOrUnifiedFieldOld) && primeIdOrUnifiedFieldOld != primeIdOrUnifiedFieldNew){
            actions = isUnifiedIdOrPrimeIdErrorMessage+' value changed from \'' + (String.isNotBlank(primeIdOrUnifiedFieldOld) ? primeIdOrUnifiedFieldOld : '' ) + '\' to \'' + (String.isNotBlank(primeIdOrUnifiedFieldNew) ?primeIdOrUnifiedFieldNew : '') + '\'';
            actionList.add(actions);
        }

        //If IPA Flag changed
        if(oldRecord.Core_Intel_Partner_Alliance_PartnerGroup__c != newRecord.Core_Intel_Partner_Alliance_PartnerGroup__c){
            actions = 'IPA Active flag value changed from \'' + oldRecord.Core_Intel_Partner_Alliance_PartnerGroup__c + '\' to \'' + newRecord.Core_Intel_Partner_Alliance_PartnerGroup__c + '\'';
            actionList.add(actions);
        }
        if(!newRecord.Core_MDF_CoMarketingActive__c){
            actionList.add('\'' + primeIdOrUnifiedFieldNew + '\' is not onboarded on co-marketing platform');
        }  

        recordIdToAccountNameMap.put(newRecord.Id, newRecord.Name);

        return createKeyAndValues(recordIdToFieldValuesMap, newRecord.Id, actionList);
    }

    /*****************************************************************************************************                              
    Method Name   :        addAsaOrIpaAffiliationActions                                
    @return       :        void                          
    @parameters   :        Map<Id, SObject>
    Description   :        To process Account records
    Added By      :        JB - Accenture - 02/16/2023
    Modified By   :        Date:           Changes:                                 
    JB - Accenture         02/16/2023      To process Account records                     
    ******************************************************************************************************/
    public static Map<Id, List<String>> addAsaOrIpaAffiliationActions(Map<Id, List<String>> recordIdToFieldValuesMap, Account accountRecord, Id recordId, String fieldDetails, String OldValue, String newValue){
        actions = '';
        actionList = new List<String>();
        
        actions = fieldDetails + ' value changed from \'' + OldValue + '\' to \'' + newValue + '\' - ' + '<a href = "' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + recordId + '"> ' + recordId + ' </a>' ;
        actionList.add(actions);
        //added by JK to replace prime id with UCD id field
        //String primeIdOrUnifiedField = isUnifiedIdEnabled?accountRecord.Core_Unified_Global_Customer_BP_Id__c:accountRecord.Core_Prime_Id__c;
        String primeIdOrUnifiedField = accountRecord.Core_Unified_Global_Customer_BP_Id__c;
        if(!accountRecord.Core_MDF_CoMarketingActive__c){
            actionList.add('\'' + primeIdOrUnifiedField + '\' is not onboarded on co-marketing platform');
        }

        recordIdToAccountNameMap.put(accountRecord.Id, accountRecord.Name);

        return createKeyAndValues(recordIdToFieldValuesMap, accountRecord.Id, actionList);
    }

    /*****************************************************************************************************                              
    Method Name   :        filterRecordsToCreateOrUpdatePGM                                
    @return       :        void                          
    @parameters   :        Set<Id>, Map<Id,String>
    Description   :        To filter and create PGM records
    Added By      :        JB - Accenture - 02/20/2023
    Modified By   :        Date:           Changes:                                 
    JB - Accenture         02/20/2023      prepare PGM instance record for the eligible accounts
    ******************************************************************************************************/
    public static Set<Id> filterRecordsToCreateOrUpdatePGM(Set<Id> filteredIntelAccountIds,Map<Id,String> intelAccountIdToUnifiedIdMap, Map<Id, Set<Id>> mapOfOPIDtoSetofAccountId/*changed from intelAccountIdToPrimeIdMap to intelAccountIdToUnifiedIdMap*/ ){

        //Remove the accounts
        Set<Id> filterAccountIdsByIpaAffiliaion = new Set<Id>(filteredIntelAccountIds);
        Map<Id,String> finalIntelAccountIdToUnifiedIdMap = new Map<Id,String>();//changed from finalIntelAccountIdToPrimeIdMap to finalIntelAccountIdToUnifiedIdMap
        Set<String> UnifiedIdSet = new Set<String>();//changed from primeIdSet to UnifiedIdSet
        Map<String, String> unifiedIdToGroupName = new Map<String, String>();//changed from primeIdToGroupName to unifiedIdToGroupName
        Map<String, String> unifiedIdToGroupId = new Map<String, String>();//changed from primeIdToGroupId to unifiedIdToGroupId
        Set<Id> accountWithNewOrExistingPgmSet = new Set<Id>();
	Set<Id> finalIntelAccountIdSet = hasMDFBenefit(filterAccountIdsByIpaAffiliaion, intelAccountIdToUnifiedIdMap, mapOfOPIDtoSetofAccountId);
        //added by JK to replace prime id with UCD id field
        
        List<PRM_IPA_Affiliation__c> prmIPAAff = Core_MDF_Account_Utility.fetchPRMIPAAffiliation(filteredIntelAccountIds,null);
            //Querying existing Account IPA Affiliation records to check if any MDF-Excluded Partner account is available
       	    for(PRM_IPA_Affiliation__c accIpaAff : prmIPAAff/*[SELECT Id, PRM_Account__c, PRM_Account__r.Core_Prime_Id__c FROM PRM_IPA_Affiliation__c 
            WHERE PRM_Builder_Strategy__r.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ExcludedPartner') AND 
            PRM_Account__c IN: filteredIntelAccountIds AND PRM_Active__c = TRUE]*/){
                filterAccountIdsByIpaAffiliaion.remove(accIpaAff.PRM_Account__c);
            }       
        if(filterAccountIdsByIpaAffiliaion.isEmpty()){
            return new Set<Id>();
        }

        //Set<Id> finalIntelAccountIdSet = hasMDFBenefit(filterAccountIdsByIpaAffiliaion);

        if(finalIntelAccountIdSet.isEmpty()){
            return new Set<Id>();
        }
        
        //Map<Id,String> finalIntelAccountIdToPrimeIdMap = new Map<Id,String>();
        //Set<String> primeIdSet = new Set<String>();
        for(Id accountId : finalIntelAccountIdSet){
            if(intelAccountIdToUnifiedIdMap.containsKey(accountId)){
                finalIntelAccountIdToUnifiedIdMap.put(accountId, intelAccountIdToUnifiedIdMap.get(accountId));
                UnifiedIdSet.add(intelAccountIdToUnifiedIdMap.get(accountId));
            }
        }
        //String primeIdOrUnifiedField = isUnifiedIdEnabled?'Core_MDF_Account__r.Core_Unified_Global_Customer_BP_Id__c':'Core_MDF_Account__r.Core_Prime_Id__c';
        String primeIdOrUnifiedField = 'Core_MDF_Account__r.Core_Unified_Global_Customer_BP_Id__c';
		Set<Id> finalAccountIds = finalIntelAccountIdToUnifiedIdMap.keySet();
        String PgmQuery = 'SELECT Id, Core_MDF_Account__c,Core_MDF_CoMarketingActive_Ind__c, Core_MDF_Account__r.Name, Core_MDF_Channel_Program__c, Core_MDF_Group_Id__c, Core_MDF_Group_Name__c,  Core_MDF_Inactive_Ind__c,'+primeIdOrUnifiedField+' FROM Core_MDF_Partner_Group_Mapping__c '+
       ' WHERE (('+primeIdOrUnifiedField+' IN: UnifiedIdSet AND Core_MDF_CoMarketingActive_Ind__c = true) OR (Core_MDF_Account__c IN:finalAccountIds AND Core_MDF_CoMarketingActive_Ind__c = false))'+
       ' AND Core_MDF_Type_of_Access__c =: externalType AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c =: ipaTechnicalProgramName ORDER BY Core_MDF_CoMarketingActive_Ind__c DESC';
        for(Core_MDF_Partner_Group_Mapping__c pgm : Database.Query(PgmQuery)){
            //String pgmprimeIdOrUnifiedField = isUnifiedIdEnabled?pgm.Core_MDF_Account__r.Core_Unified_Global_Customer_BP_Id__c:pgm.Core_MDF_Account__r.Core_Prime_Id__c;
            String pgmprimeIdOrUnifiedField = pgm.Core_MDF_Account__r.Core_Unified_Global_Customer_BP_Id__c;
            if(String.isNotBlank(pgm.Core_MDF_Account__c) && pgm.Core_MDF_CoMarketingActive_Ind__c && !pgm.Core_MDF_Inactive_Ind__c){
                unifiedIdToGroupName.put(pgmprimeIdOrUnifiedField, pgm.Core_MDF_Group_Name__c);
                unifiedIdToGroupId.put(pgmprimeIdOrUnifiedField, pgm.Core_MDF_Group_Id__c);
            }

            if(String.isNotBlank(pgm.Core_MDF_Account__c) && !pgm.Core_MDF_CoMarketingActive_Ind__c && 
                    finalIntelAccountIdToUnifiedIdMap.containsKey(pgm.Core_MDF_Account__c) && String.isNotBlank(finalIntelAccountIdToUnifiedIdMap.get(pgm.Core_MDF_Account__c)) &&
                    String.isNotBlank(pgm.Core_MDF_Group_Name__c) && unifiedIdToGroupName.containsKey(pgmprimeIdOrUnifiedField) && pgm.Core_MDF_Group_Name__c == unifiedIdToGroupName.get(pgmprimeIdOrUnifiedField)){
                
                if(pgm.Core_MDF_Inactive_Ind__c){
                    pgm.Core_MDF_Inactive_Ind__c = false;
                    pgmToActivateExistingMap.put(pgm.Id, pgm); //Activate Existing PGM
                }
                finalIntelAccountIdSet.remove(pgm.Core_MDF_Account__c);//Account Ids
                accountWithNewOrExistingPgmSet.add(pgm.Core_MDF_Account__c);
            }

        }

		ChannelProgram cpForTest = [SELECT Id FROM ChannelProgram WHERE Core_MDF_Technical_Program_Name__c = 'Intel Partner Alliance' LIMIT 1];
        for(Id accountId: finalIntelAccountIdSet){
            //if(finalIntelAccountIdToUnifiedIdMap.containsKey(accountId) && String.isNotBlank(finalIntelAccountIdToUnifiedIdMap.get(accountId))){
            //ATHR Fix- Deeply nested if
            if(!(finalIntelAccountIdToUnifiedIdMap.containsKey(accountId) && String.isNotBlank(finalIntelAccountIdToUnifiedIdMap.get(accountId)))){
                continue;
            }//ATHR end
            

                    //To create new PGM
                    if(unifiedIdToGroupName.containsKey(finalIntelAccountIdToUnifiedIdMap.get(accountId))){
                        if(String.isNotBlank(unifiedIdToGroupName.get(finalIntelAccountIdToUnifiedIdMap.get(accountId)))){
                            Core_MDF_Partner_Group_Mapping__c newPGM = new Core_MDF_Partner_Group_Mapping__c();
                            newPGM.Core_MDF_Account__c = accountId;
                            newPGM.Core_MDF_Channel_Program__c = Test.isRunningTest() ? (cpForTest.Id) : channelProgramDetailsOfIPA.Core_MDF_Program_ID__c;
                            newPGM.Core_MDF_Group_Name__c = unifiedIdToGroupName.get(finalIntelAccountIdToUnifiedIdMap.get(accountId));
                            newPGM.Core_MDF_Group_Id__c = unifiedIdToGroupId.get(finalIntelAccountIdToUnifiedIdMap.get(accountId));
                            newPGM.Core_MDF_Type_of_Access__c = externalType;
                            
                            pgmToCreateList.add(newPGM);
                            finalIntelAccountIdSet.remove(accountId);
                            accountWithNewOrExistingPgmSet.add(accountId);
                        }
                    }else{
                        nonCoMarkAccountIdsToSendEmail.add(accountId);
                    }
           // } ATHR comment           
        }

        return accountWithNewOrExistingPgmSet;
    }

    /*****************************************************************************************************                              
    Method Name   :        prepareEmailContent                                
    @return       :        void                          
    @parameters   :        Map<String, Map<Id,String>>, Map<Id,String>, List<String>
    Description   :        To send email if any value changed in the record
    Added By      :        JB - Accenture - 03/01/2023
    Modified By   :        Date:           Changes:                                 
    JB - Accenture         03/01/2023      To send email if any value changed in the record
    ******************************************************************************************************/
    public static String prepareEmailContent(Map<Id, List<String>> recordIdToFieldValuesMap, Map<Id,String> recordIdToAccountNameMap, List<String> tableheaders){

        String cont = 'The following accounts have undergone some changes and needed to be dispositioned.';
        String tableContent = '<html><head><style>table,td,th{border: 1px solid black;border-collapse: collapse;padding: 3px 15px;}</style></head><body><div style="font-size:14px;font-family:Calibri"><div>' + Label.Core_MDF_EmailTemp_DearIntelemployee + '<br/><br/>' + cont +'<br/><br/></div><table style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">';
        String tableRows = '';
        Boolean repeatedRecord = false;

        //Table header
        for(String header : tableheaders){
            tableContent += '<th style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">' + header + '</th>';
        }

        //Table Rows
        for(Id recordId : recordIdToFieldValuesMap.keySet()){

            tableRows = '<tr style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">'+
                            +'<td style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">' + '<a href = "' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + recordId + '"> ' + recordId + ' </a>' + '</td>'+
                            +'<td style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">' + recordIdToAccountNameMap.get(recordId) + '</td>'+
                            +'<td style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">';

            for(String msg : recordIdToFieldValuesMap.get(recordId)){
                tableRows += (repeatedRecord ? '<br/>' : '') + msg;
                repeatedRecord = true;
            }

            repeatedRecord = false;
            tableRows += '</td></tr>';
            tableContent += tableRows;
        }

        tableContent += '</table><br/><br/>' + Label.Core_MDF_EmailTemp_StatusUpdate_Body7 + '<br/>' + Label.Core_MDF_Email_Signature + '<br/></div></body><html>';

        return tableContent;
    }

    /*****************************************************************************************************                              
    Method Name   :        inactivatePGMRecords                                
    @return       :        void                          
    @parameters   :        Set<Id>
    Description   :        To Inactivate PGM records
    Added By      :        JB - Accenture - 02/20/2023
    Modified By   :        Date:           Changes:                                 
    JB - Accenture         02/20/2023      To prepare Inactivate PGM records instance
    ******************************************************************************************************/
    public static Map<Id, Core_MDF_Partner_Group_Mapping__c> inactivatePGMRecords(Set<Id> accountIdSet){

        Map<Id, Core_MDF_Partner_Group_Mapping__c> pgmToInactivateMap = new Map<Id, Core_MDF_Partner_Group_Mapping__c>();

        for(Core_MDF_Partner_Group_Mapping__c pgmToInactivate : [SELECT Id, Core_MDF_Account__c, Core_MDF_Group_Id__c, Core_MDF_Channel_Program__c, Core_MDF_Inactive_Ind__c 
                                                                FROM Core_MDF_Partner_Group_Mapping__c 
                                                                WHERE Core_MDF_Account__c IN: accountIdSet AND Core_MDF_Inactive_Ind__c = false AND Core_MDF_Type_of_Access__c =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External') AND 
                                                                Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name')]){
            pgmToInactivate.Core_MDF_Inactive_Ind__c = true;
            pgmToInactivateMap.put(pgmToInactivate.Id, pgmToInactivate);
        }

        return pgmToInactivateMap;
    }

    /*****************************************************************************************************                              
    Method Name   :        hasMDFBenefit                                
    @return       :        void                          
    @parameters   :        Set<Id>
    Description   :        Check the account has MDF Benifits
    Added By      :        JB - Accenture - 02/20/2023
    Modified By   :        Date:           Changes:                                 
    JB - Accenture         02/20/2023      Check the account has MDF Benifits
    ******************************************************************************************************/
        public static Set<Id> hasMDFBenefit(Set<Id> intelAccountIdSet, Map<Id, String> accountIdToUnifiedIdMap, Map<Id, Set<Id>> mapOfOPIDtoSetofAccountId) {

        Set<Id> filteredIntelAccountIds = new Set<Id>();
        Map<String, Set<Id>> mapOfUnifiedIdSetofIntelAccId = new Map<String, Set<Id>>();

        String setOfGeneralizedAccountIdsStr = '(\'' + String.join(new List<Id>(optAccountBenefitAssociation && mapOfOPIDtoSetofAccountId != null ? new List<Id>(mapOfOPIDtoSetofAccountId.keySet()) : new List<Id>(intelAccountIdSet)), '\', \'') +'\')';

        Map<Id, Set<String>> accountIdToBenefitMap = Core_MDF_CampaignCreatePage.getAccountToBenefitsMap(optAccountBenefitAssociation, setOfGeneralizedAccountIdsStr);

        if (optAccountBenefitAssociation) {
            for (Id opid : accountIdToBenefitMap.keySet()) {
                if (mapOfOPIDtoSetofAccountId.containsKey(opid)) {
                    Set<String> benefits = accountIdToBenefitMap.get(opid);
                    for (Id intelAccId : mapOfOPIDtoSetofAccountId.get(opid)) {
                        accountIdToBenefitMap.put(intelAccId, new Set<String>(benefits));
                    }
                }
            }
        }

        for (Id accId : intelAccountIdSet) {
            if (accountIdToBenefitMap.containsKey(accId)) {
                filteredIntelAccountIds.add(accId);
            }
        }

        return filteredIntelAccountIds;
    }


    /*****************************************************************************************************                              
    Method Name   :        createKeyAndValues                                
    @return       :        void                          
    @parameters   :        Map<Id, List<String>>
    Description   :        Check the account has MDF Benifits
    Added By      :        JB - Accenture - 03/13/2023
    Modified By   :        Date:           Changes:                                 
    JB - Accenture         03/13/2023      
    ******************************************************************************************************/
    public static Map<Id, List<String>> createKeyAndValues(Map<Id, List<String>> recordIdToFieldValuesMap, Id recordId, List<String> actionList){
        if(recordIdToFieldValuesMap.containsKey(recordId)){
            recordIdToFieldValuesMap.get(recordId).addAll(actionList);
        }else{
            recordIdToFieldValuesMap.put(recordId, actionList);
        }

        return recordIdToFieldValuesMap;
    }

    public class AccountBenefitAssociationWrapper {
        public Id accountId;
        public String status;
        public Id recordId;

        public AccountBenefitAssociationWrapper(Id accountId, String status, Id recordId) {
            this.accountId = accountId;
            this.status = status;
            this.recordId = recordId;
        }
    }
}