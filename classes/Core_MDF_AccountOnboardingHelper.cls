/****************************************************************************************************************************************
* Class Name  : Core_MDF_AccountOnboardingHelper 
* Version     : 1.0 
* Created Date: 10-24-2021
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – HP             10-24-2021                   Created Core_MDF_AccountOnboardingHelper for creating PGM,VC Accounts
*****************************************************************************************************************************************/
public without sharing class Core_MDF_AccountOnboardingHelper {
    //Map of technical program name to program abbrivated name
    public static Map<string,string> prgmAbbName = new Map<string,string>();
    //Map of channel program Id to channel program record
    //public static Map<Id,ChannelProgram> cpMap = new Map<Id,ChannelProgram>();
    public static Map<Id,Core_MDF_ChannelProgram__mdt> cpMap = new Map<Id,Core_MDF_ChannelProgram__mdt>();
    // Map of uniquekey(accId_cpId) to pgm record
    public static Map<String,Core_MDF_Partner_Group_Mapping__c> pgmMap = new Map<String,Core_MDF_Partner_Group_Mapping__c>();
    //Map of account Id to account record
    public static Map<Id,Account> accMap = new Map<Id,Account>();
    //Map of account onboarding Id to group developer name
    public static Map<Id,String> grpDevName = new Map<Id,String>();   
    public static Map<Id,String> mapOfIntelAccountandUnifiedId = new Map<Id,String>();//added by JK changed from mapOfIntelAccountandPrimeId to mapOfIntelAccountandUnifiedId
    //Map of Unified Id and related Account Onboarding records
    public static Map<String, Set<Core_MDF_Account_Onboarding__c>> mapOfUnifiedIdSetofAccOnb = new Map<String, Set<Core_MDF_Account_Onboarding__c>>();//changed from mapOfPrimeIdSetofAccOnb to mapOfUnifiedIdSetofAccOnb
    //Map of Unified Id and related List of Accounts
    public static Map<String, Set<Id>> mapOfUnifiedIdSetofAccountId = new Map<String, Set<Id>>();//changed from mapOfPrimeIdSetofAccountId to mapOfUnifiedIdSetofAccountId
    //Roshan - IPA Simplification
    public static Map<String, Set<Id>> mapOfOPIDtoSetofAccountId = new Map<String, Set<Id>>();  //map of OPID to related list of accounts
    public static Map<Id,String> mapOfAllIntelAcctsIdtoOPID = new Map<Id, String>();  //map of all intel accounts to OPIDs
    //Map of Unified Id and related List of Intel Accounts
    public static Map<String, Set<Id>> mapOfUnifiedIdSetofIntelAccId = new Map<String, Set<Id>>();//changed from mapOfPrimeIdSetofIntelAccId to mapOfUnifiedIdSetofIntelAccId
    //Map of Unified Id and related List of MDF Benefit Intel Accounts
    public static Map<String, Set<Id>> mapOfUnifiedIdToMDFBenIntAccId = new Map<String, Set<Id>>();//changed from mapOfPrimeIdToMDFBenIntAccId to mapOfUnifiedIdToMDFBenIntAccId
    //Map of All Intel Accounts and corresponding Unified Id
    public static Map<Id,String> mapOfAllIntelAcctsIdUnifiedId = new Map<Id, String>(); //changed from mapOfAllIntelAcctsIdPrimeId to mapOfAllIntelAcctsIdUnifiedId
    // Final Map of non onboarded account id's to list of account onboarding records which satisfy all the OPID conditions
    public static Map<Id,Set<Core_MDF_Account_Onboarding__c>> mapOfFinalaccToAccOnboard = new Map<Id,Set<Core_MDF_Account_Onboarding__c>>();
    //Map of account onboarding Id to all access group developer name
    public static Map<Id,String> allAccessGrpDevName = new Map<Id,String>(); 
    //AccountOnboardtoVCMap
    public static Map<Core_MDF_Account_Onboarding__c,Account> accOnboardToVCMap = new Map<Core_MDF_Account_Onboarding__c,Account>();
    //added by JK to replace prime id field with UCD field
    public static boolean isUnifiedIdEnabled = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_UnifiedIdCheck');
    public static String primeIdOrUnifiedFieldErrorMsg = 'Unified ID';
    //public static String primeIdOrUnifiedFieldErrorMsg = isUnifiedIdEnabled?'Unified ID':'Prime ID';
    //public static String ucdIdOrPrimeId = isUnifiedIdEnabled?'UCD ID':'Prime ID';
    public static String ucdIdOrPrimeId = 'UCD ID';

    /****************************************************************************************************** 
Method Name:        accountOnboardingOnAfterInsert
@return  :          N/A
@parameters:        list of account onboarding records
Description:        This method is used to throw error or to process the account onboarding record
Added By:           Accenture - HP - 10/20/2021
Modified By:        Date:       Changes: 

******************************************************************************************************/    
    public static void accountOnboardingOnAfterInsert(List<Core_MDF_Account_Onboarding__c> accOnboardList){
        //method to clear all static variables
        clearAllStaticMapValues();
        // Stores account Id in a set
        Set<Id> intelAccIdSet = new Set<Id>();
        // Stores channel program in a set
        Set<Id> cpIdSet = new Set<Id>();        
        // Stores list of account onboarding records to be processed
        List<Core_MDF_Account_Onboarding__c> accToBeOnboardList = new List<Core_MDF_Account_Onboarding__c>();
        // Stores list of account onboarding records to create virtual corp nodes
        List<Core_MDF_Account_Onboarding__c> vcToBeCreatedList = new List<Core_MDF_Account_Onboarding__c>();
        // Stores list of accounts for which co-marketing active checkbox to be checked
        List<Account> coMarkActList = new List<Account>();
        //Stores list of onboarding records for which IPA conditions needs to be checked.
        Set<Account> accountToBeOnboardedSet = new Set<Account>();
        // Stores list of accounts for which co-marketing agency checkbox to be checked
        List<Account> coMarkAgencyList = new List<Account>();
        // Stores list of accounts for which isPartner checkbox to be checked
        List<Account> isPartnerList = new List<Account>();
        // Stores list of technical program names
        List<String> techProgNameList = new List<String>();
        // Map of account id's to list of account onboarding records
        Map<Id,List<Core_MDF_Account_Onboarding__c>> accIdToAccOnboardMap = new Map<Id,List<Core_MDF_Account_Onboarding__c>>();
        // Map of account id's to list of account onboarding records
        Map<Id,List<Core_MDF_Account_Onboarding__c>> nonOnboardedAccIdToAccOnboardMap = new Map<Id,List<Core_MDF_Account_Onboarding__c>>();
        //list to store combination of accId and cpId for incoming accounts.
        List<String> accToProgUniqKey = new List<String>();
        //list of virtual corps for EGF program which is already onboarded for one partner role
        List<Account> vcOfEGFPrgmtobeUpdated = new List<Account>();
        
        // Iterating over account onboarding records and collecting channel program Id's and account Id's
        for(Core_MDF_Account_Onboarding__c accOnboard : accOnboardList){          
            // Adding program Id's to cpIdSet
            cpIdSet.add(accOnboard.Core_MDF_Channel_Program__c);
            // Adding account Id's to intelAccIdSet
            intelAccIdSet.add(accOnboard.Core_MDF_Account__c);  
            // Checking if type is Agency account and works for is not null
            if(accOnboard.Core_MDF_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AgencyAccount') && accOnboard.Core_MDF_Works_For__c != NULL){
                // Adding works for account Id to intelAccIdSet
                intelAccIdSet.add(accOnboard.Core_MDF_Works_For__c); 
                
            }
        }
        String intelAccIdString = '(\''+String.join(new List<Id>(intelAccIdSet), '\', \'') + '\')';
        String whereClause = ' Id IN'+intelAccIdString;
        List<Account> accounts = Core_MDF_Account_Utility.fetchAccounts(whereClause);
        for(Account acc :accounts){
            accMap.put(acc.id,acc);
        }
            
       /* // Iterating over channelProgram metadata and storing in prgmAbbName
        for(Core_MDF_ChannelProgram__mdt cpm : [SELECT Core_MDF_Abbreviated_ProgramName_txt__c, Core_MDF_Technical_Program_Name__c, MasterLabel
                                                FROM Core_MDF_ChannelProgram__mdt
                                                WHERE Core_MDF_Technical_Program_Name__c IN :techProgNameList])
        {
            prgmAbbName.put(cpm.Core_MDF_Technical_Program_Name__c, cpm.Core_MDF_Abbreviated_ProgramName_txt__c);
        }*/
        
        for(Core_MDF_ChannelProgram__mdt cpm : [SELECT Core_MDF_Abbreviated_ProgramName_txt__c, Core_MDF_Technical_Program_Name__c, MasterLabel,Core_MDF_Program_ID__c
                                                FROM Core_MDF_ChannelProgram__mdt
                                                WHERE Core_MDF_Program_ID__c IN :cpIdSet])
        {
            cpMap.put(cpm.Core_MDF_Program_ID__c,cpm);
            //techProgNameList.add(cpm.Core_MDF_Technical_Program_Name__c);
            prgmAbbName.put(cpm.Core_MDF_Technical_Program_Name__c, cpm.Core_MDF_Abbreviated_ProgramName_txt__c);
        }
                
        // Iterating over external pgm records and storing in pgmMap where key is accId_progId uniquevalue and value is pgm record
        for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Id,Core_MDF_Channel_Program__c,Core_MDF_Group_Name__c,Core_MDF_All_Access_Group_Nm__c,
                                                     Core_MDF_AccountProgramId_Txt__c, Core_MDF_Account__r.Core_MDF_CoMarketingActive__c,
                                                     Core_MDF_Account__r.Core_MDF_CoMarketingAgency__c,Core_MDF_Group_Id__c,Core_MDF_Account__c,Core_MDF_Virtual_Corp_nm__r.Core_MDF_Partner_Type_nm__c,Core_MDF_Virtual_Corp_nm__c
                                                     FROM Core_MDF_Partner_Group_Mapping__c
                                                     WHERE Core_MDF_Type_of_Access__c ='External'
                                                     AND Core_MDF_Channel_Program__c IN: cpIdSet
                                                     AND Core_MDF_Account__c IN: intelAccIdSet
                                                     AND Core_MDF_Inactive_Ind__c = FALSE])
        {
            pgmMap.put(pgm.Core_MDF_AccountProgramId_Txt__c,pgm);
        }
        // Iterating over account onboarding list
        for(Core_MDF_Account_Onboarding__c accOnboard : accOnboardList){
            // checking if we have duplicate accounts comes to be onboarded for same prog through bulk upload. If exists,throw an error.
            if(accToProgUniqKey.contains((String.valueOf(accOnboard.Core_MDF_Account__c) + String.valueOf(accOnboard.Core_MDF_Channel_Program__c))))
            {
                accOnboard.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DuplicateOnboardingRecordError1') +' ' + cpMap.get(accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c + ' ' + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DuplicateOnboardingRecordError2') + ' ' + accMap.get(accOnboard.Core_MDF_Account__c).Name);
            }
            else
            {
                accToProgUniqKey.add((String.valueOf(accOnboard.Core_MDF_Account__c) + String.valueOf(accOnboard.Core_MDF_Channel_Program__c)));
            }
            // If type is agency and account is already co-marketing active, throw an error
            if(accOnboard.Core_MDF_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AgencyAccount') && accMap.get(accOnboard.Core_MDF_Account__c).Core_MDF_CoMarketingActive__c){
                accOnboard.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AgencyOnboardingRestriction'));
            }
            // checking if accId_progId combination exists in pgm or not. If exists,throw an error.
            //if program is EEF, check if the accId_prog_Id and Partner Role is already exists, throw an error.
            else if(pgmMap.containsKey(accOnboard.Core_MDF_Account__c+'_'+accOnboard.Core_MDF_Channel_Program__c) && (cpMap.get(accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name') || (cpMap.get(accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name') && accOnboard.Core_MDF_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AgencyAccount')) || (accOnboard.Core_MDF_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IntelAccount') && cpMap.get(accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name') && String.valueOf(pgmMap.get(accOnboard.Core_MDF_Account__c+'_'+accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Virtual_Corp_nm__r.Core_MDF_Partner_Type_nm__c).contains(accOnboard.Core_MDF_Partner_Type_nm__c)))){
                accOnboard.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AccountAlreadyExistError'));
            }
            // checking if type is agency account and works for accId_progId combination doesnot exists in pgm 
            // or works for account's co-marketing active is false then throw an error.
            else if(accOnboard.Core_MDF_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AgencyAccount') && (!pgmMap.containsKey(accOnboard.Core_MDF_Works_For__c+'_'+accOnboard.Core_MDF_Channel_Program__c) || !accMap.get(accOnboard.Core_MDF_Works_For__c).Core_MDF_CoMarketingActive__c))
            {
                accOnboard.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_WorksforAccountError'));
            }
            // If prog is IPA and account 's IPA account flag is false, then throw an error
            else if(cpMap.get(accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name') && !accMap.get(accOnboard.Core_MDF_Account__c).Core_Intel_Partner_Alliance_PartnerGroup__c){
                accOnboard.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPAAccountFlagError'));
            }
            // If prog is RMF and type is Intel Account and account's geo is empty, then throw an error
            else if(accOnboard.Core_MDF_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IntelAccount') && prgmAbbName.get(cpMap.get(accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c) == 'RMF' 
                    && (String.isEmpty(accMap.get(accOnboard.Core_MDF_Account__c).Core_Geo__c) || (accMap.get(accOnboard.Core_MDF_Account__c).Core_Geo__c == 'ASMO' && (String.isEmpty(accMap.get(accOnboard.Core_MDF_Account__c).Core_Sub_Geo__c) || (accMap.get(accOnboard.Core_MDF_Account__c).Core_Sub_Geo__c != 'LAR' && accMap.get(accOnboard.Core_MDF_Account__c).Core_Sub_Geo__c != 'NAR'))))){
                        if(!Core_MDF_Utility.byPassFeature('Bypass_RegionCheckForRMFAccount')){
                            accOnboard.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RMF_RegionMandatoryError'));
                        }
                    }else{ 
                        // If type is Intel / (prog is not IPA ) but co-marketing active is true, then add account to accToBeOnboardList,vcToBeCreatedList
                        if(isIntelAccOnboarded(accOnboard) && !isIntelIPAAccount(accOnboard) )
                        {
                            
                            if(pgmMap.containsKey(accOnboard.Core_MDF_Account__c+'_'+accOnboard.Core_MDF_Channel_Program__c) && cpMap.get(accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name')
                             && !String.valueOf(pgmMap.get(accOnboard.Core_MDF_Account__c+'_'+accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Virtual_Corp_nm__r.Core_MDF_Partner_Type_nm__c).contains(accOnboard.Core_MDF_Partner_Type_nm__c)){
                                Set<String> existingValues = new Set<String>();
                                existingValues.add(pgmMap.get(accOnboard.Core_MDF_Account__c+'_'+accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Virtual_Corp_nm__r.Core_MDF_Partner_Type_nm__c);
                                // Add the new value
                                existingValues.add(accOnboard.Core_MDF_Partner_Type_nm__c);
                                // Combine the values into a semicolon-separated string
                                String updatedPicklistValues = String.join(new List<String>(existingValues), ';');
                                Account vcAcc = new Account(Id = pgmMap.get(accOnboard.Core_MDF_Account__c+'_'+accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Virtual_Corp_nm__c, Core_MDF_Partner_Type_nm__c = updatedPicklistValues);
                                vcOfEGFPrgmtobeUpdated.add(vcAcc);
                            }
                            else{
                                vcToBeCreatedList.add(accOnboard);
                                accToBeOnboardList.add(accOnboard);
                            }
                            if(accIdToAccOnboardMap.containsKey(accOnboard.Core_MDF_Account__c)){
                                accIdToAccOnboardMap.get(accOnboard.Core_MDF_Account__c).add(accOnboard);
                            }else{
                                accIdToAccOnboardMap.put(accOnboard.Core_MDF_Account__c, new List<Core_MDF_Account_Onboarding__c>{accOnboard});
                            }
                        }
                        // If type is Intel Account but co-marketing active is false, then add account to accountToBeOnboardedSet
                        else if(isIntelAccNonOnboarded(accOnboard) || isIntelIPAAccount(accOnboard))
                        {
                            accountToBeOnboardedSet.add(accMap.get(accOnboard.Core_MDF_Account__c));
                            if(nonOnboardedAccIdToAccOnboardMap.containsKey(accOnboard.Core_MDF_Account__c)){
                                nonOnboardedAccIdToAccOnboardMap.get(accOnboard.Core_MDF_Account__c).add(accOnboard);
                            }else{
                                nonOnboardedAccIdToAccOnboardMap.put(accOnboard.Core_MDF_Account__c, new List<Core_MDF_Account_Onboarding__c>{accOnboard});
                            }
                            if(accIdToAccOnboardMap.containsKey(accOnboard.Core_MDF_Account__c)){
                                accIdToAccOnboardMap.get(accOnboard.Core_MDF_Account__c).add(accOnboard);
                            }else{
                                accIdToAccOnboardMap.put(accOnboard.Core_MDF_Account__c, new List<Core_MDF_Account_Onboarding__c>{accOnboard});
                            }
                            //added by jk to replace prime id field with UCD field
                    String primeIdOrUnifiedField = accMap.containsKey(accOnboard.Core_MDF_Account__c) && accMap.get(accOnboard.Core_MDF_Account__c) != NULL && accMap.get(accOnboard.Core_MDF_Account__c).Core_Unified_Global_Customer_BP_Id__c != NULL
                        ? accMap.get(accOnboard.Core_MDF_Account__c).Core_Unified_Global_Customer_BP_Id__c 
                        : NULL;

	                   /* if(primeIdOrUnifiedField != NULL ){                                 
	                        if(mapOfUnifiedIdSetofAccOnb.containsKey(primeIdOrUnifiedField)){
	                            mapOfUnifiedIdSetofAccOnb.get(primeIdOrUnifiedField).add(accOnboard);
	                        }else{
	                            mapOfUnifiedIdSetofAccOnb.put(primeIdOrUnifiedField, new Set<Core_MDF_Account_Onboarding__c>{accOnboard});
	                        }
	                    }*/
                           //ATHR Fix- deeply nested if
	                    if(primeIdOrUnifiedField != NULL && mapOfUnifiedIdSetofAccOnb.containsKey(primeIdOrUnifiedField)){
	                        mapOfUnifiedIdSetofAccOnb.get(primeIdOrUnifiedField).add(accOnboard);
	                    }else if(primeIdOrUnifiedField != NULL){
	                        mapOfUnifiedIdSetofAccOnb.put(primeIdOrUnifiedField, new Set<Core_MDF_Account_Onboarding__c>{accOnboard});
                            }
                        }
                        // If type is Agency and account's co-marketing agency is false, then add account to coMarkAgencyList,accToBeOnboardList
                        else if(isAgencyAccount(accOnboard)){
                            if(!accMap.get(accOnboard.Core_MDF_Account__c).Core_MDF_CoMarketingAgency__c)
                            {
                                coMarkAgencyList.add(accMap.get(accOnboard.Core_MDF_Account__c)); 
                            }
                            accToBeOnboardList.add(accOnboard);
                            if(accIdToAccOnboardMap.containsKey(accOnboard.Core_MDF_Account__c)){
                                accIdToAccOnboardMap.get(accOnboard.Core_MDF_Account__c).add(accOnboard);
                            }else{
                                accIdToAccOnboardMap.put(accOnboard.Core_MDF_Account__c, new List<Core_MDF_Account_Onboarding__c>{accOnboard});
                            }
                        } 
                        // If isPartner checkbox is false on the account For type Intel account Co-marketing active is true or For type agency Co-marketing agency is true), then add account to isPartnerList
                        if(isPartnerAccount(accOnboard)){
                            isPartnerList.add(accMap.get(accOnboard.Core_MDF_Account__c));                            
                            if(accIdToAccOnboardMap.containsKey(accOnboard.Core_MDF_Account__c)){
                                accIdToAccOnboardMap.get(accOnboard.Core_MDF_Account__c).add(accOnboard);
                            }else{
                                accIdToAccOnboardMap.put(accOnboard.Core_MDF_Account__c, new List<Core_MDF_Account_Onboarding__c>{accOnboard});
                            }
                        }
                        
                    }
                   
        }
         if(vcOfEGFPrgmtobeUpdated!=null && !vcOfEGFPrgmtobeUpdated.isEmpty() && vcOfEGFPrgmtobeUpdated[0].Id != null){
                        update vcOfEGFPrgmtobeUpdated;
                    }

        //If coMarkInactiveActList is not empty, then call the isAccountEligibleForMDF method
        if(!accountToBeOnboardedSet.isEmpty() && !nonOnboardedAccIdToAccOnboardMap.isEmpty()){
            if(!Core_MDF_Utility.byPassFeature('Bypass_AccountOnboardOPIDValidations'))
            {
                isAccountEligibleForMDF(accountToBeOnboardedSet,nonOnboardedAccIdToAccOnboardMap);
            }
            else
            {
                for(Account acc : accountToBeOnboardedSet)
                {
                    if(!acc.Core_MDF_CoMarketingActive__c){
                        coMarkActList.add(acc);
                    }
                    accToBeOnboardList.addAll(nonOnboardedAccIdToAccOnboardMap.get(acc.Id));
                    vcToBeCreatedList.addAll(nonOnboardedAccIdToAccOnboardMap.get(acc.Id));
                }
            }
        }
        //If mapOfFinalaccToAccOnboard is not empty, then add account to coMarkActList,accToBeOnboardList and vcToBeCreatedList
        if(!Core_MDF_Utility.byPassFeature('Bypass_AccountOnboardOPIDValidations') && !mapOfFinalaccToAccOnboard.isEmpty()){
            for( Id accId :mapOfFinalaccToAccOnboard.keySet() )
            {
                if(accMap.ContainsKey(accId) && !accMap.get(accId).Core_MDF_CoMarketingActive__c)
                {
                    coMarkActList.add(accMap.get(accId));
                }
                accToBeOnboardList.addAll(mapOfFinalaccToAccOnboard.get(accId));
                vcToBeCreatedList.addAll(mapOfFinalaccToAccOnboard.get(accId));
            }
        }
        if(!accToBeOnboardList.isEmpty()){
            //Moved here to populated VC id on PGM record
            if(!vcToBeCreatedList.isEmpty()){
            //Create CCP corp node
                createCorpNode(vcToBeCreatedList);
          }
            // calling updateAccountFields to check co-marketing active/ agency flags to true
            updateAccountFields(coMarkActList,coMarkAgencyList,isPartnerList, accIdToAccOnboardMap);
            //Create public group
            createPublicGroup(accToBeOnboardList);
            //Create parter group mapping
            createPGM(accToBeOnboardList);
            //Create Partner score
            if(!Core_MDF_Utility.byPassFeature('Bypass_PartnershipScoreCreation'))
            {
               createPartnerScore(accToBeOnboardList);
            }   
        }
           }
    
    /****************************************************************************************************** 
Method Name:        updateAccountFields
@return  :          N/A
@parameters:        list of ccp account wrapper and list of account onboarding records
Description:        This method is used to update co-marketing active/ co-marketing agency fields on account
Added By:           Accenture - HP - 10/20/2021
Modified By:        Date:       Changes: 

*******************************************************************************************************/
    public static void updateAccountFields(List<Account> coMarkActList,List<Account> coMarkAgencyList,List<Account> isPartnerList,Map<Id,List<Core_MDF_Account_Onboarding__c>> accIdToAccOnboardMap){
        Map<Id,Account> accIdToAccMap =new Map<Id,Account>();
        try{
            // If coMarkActList is not empty, then iterate over the account records and update comarketive active checkbox to true
            if(!coMarkActList.isEmpty()){
                for(Account acc : coMarkActList){
                    Account accInstance = new Account();
                    accInstance.Id = acc.id;
                    accInstance.Core_MDF_CoMarketingActive__c=true;
                    if(!acc.IsPartner){
                        accInstance.IsPartner=true;
                    }
                    accIdToAccMap.put(accInstance.Id,accInstance);
                }
            }
            // If coMarkAgencyList is not empty, then iterate over the account records and update comarketive agency checkbox to true
            if(!coMarkAgencyList.isEmpty()){
                for(Account acc : coMarkAgencyList){
                    Account accInstance = new Account();
                    accInstance.Id = acc.id;
                    accInstance.Core_MDF_CoMarketingAgency__c=true;
                    if(!acc.IsPartner){
                        accInstance.IsPartner=true;
                    }
                    accIdToAccMap.put(accInstance.Id,accInstance);
                }
            }
            // If isPartnerList is not empty, then iterate over the account records and update isPartner checkbox to true
            if(!isPartnerList.isEmpty()){
                for(Account acc : isPartnerList){
                    Account accInstance = new Account();
                    accInstance.Id = acc.id;
                    accInstance.IsPartner=true;
                    accIdToAccMap.put(accInstance.Id,accInstance);
                }
            }
            // If toBeUpdatedAccList is not empty, then update the account records
            if(accIdToAccMap!= NULL && accIdToAccMap.size()>0){
                Database.SaveResult[] srList = Database.update(accIdToAccMap.values(), false);
                Integer count = 0;
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            for(Core_MDF_Account_Onboarding__c accOnb : accIdToAccOnboardMap.get(new List<Id>(accIdToAccMap.keyset())[count])){
                                accOnb.addError(err.getMessage());}
                        }
                    }
                    count ++;
                }
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    /*****************************************************************************************************
Method Name:        createPublicGroup
@return  :          N/A
@parameters:        list of ccp account wrapper
Description:        This method is used to create public group
Added By:           Accenture - HP - 10/13/2021
Modified By:        Date:       Changes: s
*******************************************************************************************************/ 
    public static void createPublicGroup(List<Core_MDF_Account_Onboarding__c> accToBeOnboardList){
        //To hold program code
        String programCode;
        //To hold group name
        String groupName;
        //To hold group developer name
        String groupDeveloperName;        
        //To hold group list
        List<Group> grpList = new List<Group>();
        Map<Group,Core_MDF_Account_Onboarding__c> grpAccOnboardMap = new Map<Group,Core_MDF_Account_Onboarding__c>();
        //To hold all Access Group
        Map<Group,Core_MDF_Account_Onboarding__c> allAccessGrpAccOnboardMap = new Map<Group,Core_MDF_Account_Onboarding__c>();
        String allAccessGroupName;
        String allAccessGroupDeveloperName;
        String accId;
        try{
            // Iterating over account onboard list
            for(Core_MDF_Account_Onboarding__c accOnboard : accToBeOnboardList){
                // validate the type of account onboarding
                if(accOnboard.Core_MDF_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IntelAccount')){                
                    programCode = prgmAbbName.get(cpMap.get(accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c);
                                //Use Virtual Corp Id instead of Intel Account Id for group name/developer name
                                Id vcId;
                                if(accOnboardToVCMap != null && accOnboardToVCMap.containsKey(accOnboard) && accOnboardToVCMap.get(accOnboard) != null){
                                    vcId = accOnboardToVCMap.get(accOnboard).Id;
                                }
                                else{
                                    continue;
                                }
                                groupName = 'CCP ' + vcId + ' ' + programCode + ' ' + 'EXT';
                                groupDeveloperName = 'Core_MDF_CCP_' + vcId + '_' + programCode + '_' + 'EXT';
                                
                    //added EEF check for stamping all access group
                    if(programCode == 'CCF' || programCode == 'DCF' || programCode == 'EEF'){
                                    //Use Virtual Corp Id for all access group as well
                                    String vcIdStr = String.valueOf(vcId);
                                    allAccessGroupName = 'CCP ALL ACCESS ' + vcIdStr.right(15) + ' ' + programCode + ' ' + 'EXT'; //38 charcters
                                    allAccessGroupDeveloperName = 'Core_MDF_CCP_ALL_ACCESS_' + vcIdStr.right(15) + '_' + programCode + '_' + 'EXT'; //47 characters
                                }
                    // New group instance
                    Group newGroup = new Group();
                    newGroup.Name = groupName;
                    newGroup.DeveloperName = groupDeveloperName;
                    newGroup.DoesIncludeBosses = false;
                    grpList.add(newGroup);
                    grpDevName.put(accOnboard.id,groupDeveloperName);
                    grpAccOnboardMap.put(newGroup,accOnboard);
                    //Create a group for All_access_account_specific_group- added by NA for CCF/DCF Recovery admin access
                    //added EEF check for stamping all access group
                    if(programCode == 'CCF' || programCode == 'DCF' || programCode == 'EEF'){
                        Group allAccessGrp = new Group();
                        allAccessGrp.Name = allAccessGroupName;
                        allAccessGrp.DeveloperName = allAccessGroupDeveloperName;
                        allAccessGrp.DoesIncludeBosses = false;
                        grpList.add(allAccessGrp);
                        allAccessGrpDevName.put(accOnboard.id,allAccessGroupDeveloperName);
                        allAccessGrpAccOnboardMap.put(allAccessGrp,accOnboard);
                    }
                    
                }
            }
            // If grpList is not empty, then insert the group records
            if(!grpList.isEmpty()){
                //Database.insert(grpList);
                //database.update(toBeUpdatedAccList);
                Database.SaveResult[] srList = Database.insert(grpList, false);
                Integer count = 0;
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            grpAccOnboardMap.get(grpList[count]).adderror(err.getMessage()); 
                        }
                    }
                    count ++;
                }
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    /****************************************************************************************************** 
Method Name:        createPGM
@return  :          N/A
@parameters:        list of ccp account wrapper
Description:        This method is used to create partner group mapping
Added By:           Accenture - HP - 10/13/2021
Modified By:        Date:       Changes: 

*******************************************************************************************************/    
    public static void createPGM(List<Core_MDF_Account_Onboarding__c> accToBeOnboardList){
        //List of partner group mapping records
        List<Core_MDF_Partner_Group_Mapping__c> newpgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
        //List of account onboarding records for which partner group domain mapping records should be created
        List<Core_MDF_Account_Onboarding__c> DomainaccOnboardList = new List<Core_MDF_Account_Onboarding__c>();
        Map<Core_MDF_Partner_Group_Mapping__c,Core_MDF_Account_Onboarding__c> pgmAccOnboardMap = new Map<Core_MDF_Partner_Group_Mapping__c,Core_MDF_Account_Onboarding__c>();
        List<String> ipaPGMErrorList = new List<String>();
        List<String> allAccessGroupSupportedPrograms = Core_MDF_CCP_ConstantClass.allAccessGroupSupportedPrograms;//Client CoMarketing Fund','Data Center CoMarketing Fund','Ecosystem Extension Fund
        String ipaPGMErrorAccountId;
        try{
            // Iterating over account onboarding list
            for(Core_MDF_Account_Onboarding__c accOnboard : accToBeOnboardList){
                // String to hold group developer name based on type of onboarding
                // If onboarding type is agency, then get the group name from pgmMap where key is works for accId_progId
                String grpName =  (accOnboard.Core_MDF_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AgencyAccount')) ? (pgmMap.get(accOnboard.Core_MDF_Works_For__c+'_'+accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Group_Name__c):grpDevName.get(accOnboard.Id);
                String allAccessGrpName = (accOnboard.Core_MDF_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AgencyAccount')) ? (pgmMap.get(accOnboard.Core_MDF_Works_For__c+'_'+accOnboard.Core_MDF_Channel_Program__c).Core_MDF_All_Access_Group_Nm__c):allAccessGrpDevName.get(accOnboard.Id);
                Id virtualCorpId =  (accOnboard.Core_MDF_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AgencyAccount')) ? (pgmMap.get(accOnboard.Core_MDF_Works_For__c+'_'+accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Virtual_Corp_nm__c) : accOnboardToVCMap.get(accOnboard).id;
                //New PGM instance
                Core_MDF_Partner_Group_Mapping__c newPGM = new Core_MDF_Partner_Group_Mapping__c();
                newPGM.Core_MDF_Account__c = accOnboard.Core_MDF_Account__c;
                newPGM.Core_MDF_Channel_Program__c = accOnboard.Core_MDF_Channel_Program__c;
                newPGM.Core_MDF_Group_Name__c = grpName;
                newPGM.Core_MDF_Type_of_Access__c = 'External';
                //To populate virtual corp of respective account after saving Acoount Onboarding record
                newPGM.Core_MDF_Virtual_Corp_nm__c = virtualCorpId;
            
                //added this column to map All Access Group Name for CCF/DCF program
                if(allAccessGroupSupportedPrograms.contains(cpMap.get(accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c)){
                newPGM.Core_MDF_All_Access_Group_Nm__c = allAccessGrpName;
                }
                if(accOnboard.Core_MDF_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AgencyAccount'))
                {
                    newPGM.Core_MDF_Works_For__c = accOnboard.Core_MDF_Works_For__c;
                }
                //If type is Intel Account, then populate Account Type field on PGM 
                /*if(accOnboard.Core_MDF_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IntelAccount'))
                {
                    newPGM.Core_MDF_Payment_Type_nm__c = accOnboard.Core_MDF_Payment_Type_nm__c;
                }*/
                newpgmList.add(newPGM);
                pgmAccOnboardMap.put(newPGM,accOnboard);
                // If domain field is not empty, then add the account onboarding record to DomainaccOnboardList
                if(String.isNotEmpty(accOnboard.Core_MDF_Domains_txt__c)){
                    DomainaccOnboardList.add(accOnboard); 
                }
                if(cpMap.get(accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name') && 
                mapOfIntelAccountandUnifiedId != NULL && mapOfIntelAccountandUnifiedId.containsKey(accOnboard.Core_MDF_Account__c) &&
                mapOfIntelAccountandUnifiedId.get(accOnboard.Core_MDF_Account__c) != NULL && mapOfUnifiedIdToMDFBenIntAccId != NULL &&
                mapOfUnifiedIdToMDFBenIntAccId.containsKey(mapOfIntelAccountandUnifiedId.get(accOnboard.Core_MDF_Account__c)) && 
                mapOfUnifiedIdToMDFBenIntAccId.get(mapOfIntelAccountandUnifiedId.get(accOnboard.Core_MDF_Account__c)) != NULL)
                {
                    for(Id accId : mapOfUnifiedIdToMDFBenIntAccId.get(mapOfIntelAccountandUnifiedId.get(accOnboard.Core_MDF_Account__c))){
                        //New PGM instance
                        if(accId != accOnboard.Core_MDF_Account__c ){
                            Core_MDF_Partner_Group_Mapping__c pgmInstance = new Core_MDF_Partner_Group_Mapping__c();
                            pgmInstance.Core_MDF_Account__c = accId;
                            pgmInstance.Core_MDF_Channel_Program__c = accOnboard.Core_MDF_Channel_Program__c;
                            pgmInstance.Core_MDF_Group_Name__c = grpName;
                            pgmInstance.Core_MDF_Type_of_Access__c = 'External';                          
                            newpgmList.add(pgmInstance);
                        }
                    }
                }
            } 
            // If newpgmList is not empty, then insert the pgm records
            if(!newpgmList.isEmpty()){
                //Database.insert(newpgmList);
                Database.SaveResult[] srList = Database.insert(newpgmList, false);
                

               Integer count = 0;
                // Iterate through each returned result
               for (Database.SaveResult sr : srList) {
                  /*  if (!sr.isSuccess()) {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) { 
                            if(pgmAccOnboardMap.containsKey(newpgmList[count]) && pgmAccOnboardMap.get(newpgmList[count]) != NULL){
                                pgmAccOnboardMap.get(newpgmList[count]).adderror(err.getMessage()); 
                            }else{
                                ipaPGMErrorList.add(newpgmList[count].Core_MDF_Account__c);
                            }
                        }
                    }*/
                   //ATHR FIX -Deeply nested if                   
                    if (sr.isSuccess()) {   
                        count++; 
                        continue; // Skip successful inserts
                    }
                    for (Database.Error err : sr.getErrors()) {
                        if(pgmAccOnboardMap.containsKey(newpgmList[count]) && pgmAccOnboardMap.get(newpgmList[count]) != NULL){
                            pgmAccOnboardMap.get(newpgmList[count]).adderror(err.getMessage()); 
                        }else{
                            ipaPGMErrorList.add(newpgmList[count].Core_MDF_Account__c);
                        }
                    }//ATHR END*/
                    count++;

                }
            }
            if(ipaPGMErrorList != NULL && ipaPGMErrorList.size()>0){
                ipaPGMErrorAccountId = string.join(ipaPGMErrorList,';');
                Core_MDF_CCP_UtilityClass.logErrorinLogObject('PGM Creation failed for following Account Id(s) : '+ ipaPGMErrorAccountId,'IPA PGM Creation through Account Onboarding');
            }
            // If accOnboardList is not empty, then call createPGDM method
            if(!DomainaccOnboardList.isEmpty()){
                createPGDM(DomainaccOnboardList,newpgmList);}
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    /****************************************************************************************************** 
Method Name:        createPartnerScore
@return  :          N/A
@parameters:        list of ccp account wrapper
Description:        This method is used to create partnership score
Added By:           Accenture - 02/March/2022
Modified By:        Date:       Changes: 

*******************************************************************************************************/    
    public static void createPartnerScore(List<Core_MDF_Account_Onboarding__c> accToBeOnboardList){
        //List of =records
        List<Core_MDF_Partnership_Score__c> newScoreList = new List<Core_MDF_Partnership_Score__c>();
        Map<Core_MDF_Partnership_Score__c,Core_MDF_Account_Onboarding__c> scoreAccOnboardMap = new Map<Core_MDF_Partnership_Score__c,Core_MDF_Account_Onboarding__c>();
        
        try{
            // Iterating over account onboarding list
            Period quarterPeriod = Core_MDF_Utility.getPeriodforDate(Date.today());
            for(Core_MDF_Account_Onboarding__c accOnboard : accToBeOnboardList){
                //Create partnership score only for type as normal account(Intel Account) and bypass for agency account
                if(accOnboard.Core_MDF_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IntelAccount'))
                {
                Core_MDF_Partnership_Score__c newScore = new Core_MDF_Partnership_Score__c();
                newScore.Core_MDF_Account_Id__c = accOnboard.Core_MDF_Account__c;
                newScore.Core_MDF_Virtual_Corp_Account_Id__c = accOnboardToVCMap.get(accOnboard).Id;
                newScore.Core_MDF_Program_nm__c = cpMap.get(accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c;
                newScore.Core_MDF_Channel_Program_Id__c = cpMap.get(accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Program_ID__c;
                //Get the current date quarter period record to get the current dates quarter
                
                newScore.Core_MDF_Quarter_nm__c = 'Q'+String.valueof(quarterPeriod.Number);
                newScore.Core_MDF_Year_nm__c = String.valueof(quarterPeriod.Enddate.Year());
                newScore.Core_MDF_Quarter_Year_Nm__c = newScore.Core_MDF_Quarter_nm__c +' '+ newScore.Core_MDF_Year_nm__c;
                String externalId = '' + cpMap.get(accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Program_ID__c + accOnboardToVCMap.get(accOnboard).Id + newScore.Core_MDF_Quarter_nm__c +' '+ newScore.Core_MDF_Year_nm__c;
                newScore.Core_MDF_External_Id__c = externalId;
                newScoreList.add(newScore);
                scoreAccOnboardMap.put(newScore,accOnboard);
                }
            } 
            // If newScoreList is not empty, then insert the score records
            if(!newScoreList.isEmpty()){
                Schema.SObjectField externalID = Core_MDF_Partnership_Score__c.Core_MDF_External_Id__c;
                Database.UpsertResult[] srList = Database.upsert(newScoreList, externalID, false);

                Set<String> insertedPartnershipScoreIdSet = new Set<String>();
                Integer count = 0;
                // Iterate through each returned result
                for(Database.UpsertResult result : srList){
                    if (result.isSuccess()){
                        insertedPartnershipScoreIdSet.add(result.getId());
                    }else if (!result.isSuccess()) {
                        // Operation failed, so get all errors                
                        for(Database.Error err : result.getErrors()) {
                            scoreAccOnboardMap.get(newScoreList[count]).adderror(err.getMessage()); 
                        }
                    }
                    count ++;
                }
                
                Map<String, Core_MDF_Partnership_Score_Detail__c> psKeyTopsdRecordMap = new Map<String, Core_MDF_Partnership_Score_Detail__c>();
                for(Core_MDF_Partnership_Score__c ps : newScoreList){
                    if(String.isNotBlank(ps.Id) && insertedPartnershipScoreIdSet.contains(ps.Id)){
                        Core_MDF_Partnership_Score_Detail__c psd = new Core_MDF_Partnership_Score_Detail__c();
                        psd.Core_MDF_External_ID__c = ps.Core_MDF_External_Id__c;
                        psd.Core_MDF_Partnership_Score_Id__c = ps.Id;
                        psKeyTopsdRecordMap.put(ps.Core_MDF_External_Id__c, psd);
                    }
                }

                if(psKeyTopsdRecordMap != null && !psKeyTopsdRecordMap.isEmpty()){
                    Core_MDF_IAH_Partnership_Score.createPSDandRecoveryDashboardRecords(psKeyTopsdRecordMap);
                }
            }  
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    /****************************************************************************************************** 
Method Name:        createPGDM
@return  :          N/A
@parameters:        list of account onboarding and pgm
Description:        This method is used to create partner group domain mapping
Added By:           Accenture - HP - 10/24/2021
Modified By:        Date:       Changes: 

*******************************************************************************************************/     
    public static void createPGDM(List<Core_MDF_Account_Onboarding__c> DomainaccOnboardList,List<Core_MDF_Partner_Group_Mapping__c> newpgmList){
        // list of pgdm records to be created
        List<Core_MDF_Partner_Group_Domain_Mapping__c> pgdmToBeCreatedList = new List<Core_MDF_Partner_Group_Domain_Mapping__c>();
        Map<Core_MDF_Partner_Group_Domain_Mapping__c,Core_MDF_Account_Onboarding__c> pgdmAccOnboardMap = new Map<Core_MDF_Partner_Group_Domain_Mapping__c,Core_MDF_Account_Onboarding__c>();
        // Map of uniqueKet to pgm Id
        Map<String,Id> pgmUniqueKeyId = new Map<String,Id>();
        try{
            // Iterating over pgm records and preparing pgmUniqueKeyId map
            for(Core_MDF_Partner_Group_Mapping__c pgm : newpgmList){
                pgmUniqueKeyId.put((pgm.Core_MDF_Account__c+'_'+pgm.Core_MDF_Channel_Program__c),pgm.Id);
            }
            // Iterating over account onboarding list
            for(Core_MDF_Account_Onboarding__c accOnb : DomainaccOnboardList)
            {
                // Preparing a unique key with accId_progId
                String uniqueKey = accOnb.Core_MDF_Account__c+'_'+accOnb.Core_MDF_Channel_Program__c;
                // Checking if pgmUniqueKeyId map contains uniqueKey value
                if(pgmUniqueKeyId.containsKey(uniqueKey) && pgmUniqueKeyId.get(uniqueKey) != NULL){
                    // Splitting the domains with semi colon (';') and storing in a domainList
                    List<String> domainList = accOnb.Core_MDF_Domains_txt__c.split(';');
                    // Holds the unique domain values
                    Set<String> domainSet = new Set<String>();
                    // Iterating over domain list and removing the whitespaces and adding to a set
                    for(string domain : domainList){
                        domainSet.add(domain.trim());
                    }
                    // Iteating over the domainList
                    for(String domain : domainSet){
                        // New pgdm instance
                        Core_MDF_Partner_Group_Domain_Mapping__c  newPGDM = new Core_MDF_Partner_Group_Domain_Mapping__c();
                        // Trimming the domain name to remove whitespaces
                        newPGDM.Name = domain;
                        // Getting the pgm id from the above map
                        newPGDM.Core_MDF_Partner_Group_Mapping_Id__c=pgmUniqueKeyId.get(uniqueKey);
                        // Adding the instance to pgdmToBeCreatedList
                        pgdmToBeCreatedList.add(newPGDM);
                        pgdmAccOnboardMap.put(newPGDM,accOnb);
                    }                
                }
            }
            // If pgdmToBeCreatedList is not empty, then insert the pgdm records
            if(!pgdmToBeCreatedList.isEmpty()){
                //Database.insert(pgdmToBeCreatedList);
                Database.SaveResult[] srList = Database.insert(pgdmToBeCreatedList, false);
                Integer count = 0;
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            pgdmAccOnboardMap.get(pgdmToBeCreatedList[count]).adderror(err.getMessage()); 
                        }
                    }
                    count ++;
                }
            } 
        }catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e); }
    }
    
    
    /****************************************************************************************************** 
Method Name:        createCorpNode
@return  :          N/A
@parameters:        list of ccp account wrapper
Description:        This method is used to create corp node
Added By:           Accenture - SM - 7/7/2020
Modified By:        Date:       Changes: 

*******************************************************************************************************/        
    public static void createCorpNode(List<Core_MDF_Account_Onboarding__c> vcAccToBeCreatedList){
        // Stores abbreviatedCode
        String abbreviatedCode;
        // Stores program code
        String programCode;
        //List of accounts
        List<Account> vcAccToBeInsertList = new List<Account>();
        //co-marketing record type Id
        ID coMarketingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_Marketing').getRecordTypeId();
        Map<String,Boolean> progToGeoBasedSharingReq = Core_MDF_ManualSharing.fetchProgForGeoBasedSharing();
        Map<Account,Core_MDF_Account_Onboarding__c> vcAccToAccOnboardMap = new Map<Account,Core_MDF_Account_Onboarding__c>();
        try{
            // Iterating over vc to be created account onboarding records
            for(Core_MDF_Account_Onboarding__c accOnboard : vcAccToBeCreatedList){
                abbreviatedCode = prgmAbbName.get(cpMap.get(accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c);
                programCode = /*(abbreviatedCode == 'CMDF') ? Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ChannelMDF_Program_Name') : */abbreviatedCode;
                //New Account Instance
                Account corpAcc = new Account();            
                corpAcc.RecordTypeId = coMarketingRecordTypeId;
                corpAcc.Core_MDF_Parent_Fund_Account__c = accOnboard.Core_MDF_Account__c;
                corpAcc.Core_MDF_Channel_Program__c = accOnboard.Core_MDF_Channel_Program__c;
                                corpAcc.Core_MDF_Payment_Type_nm__c = accOnboard.Core_MDF_Payment_Type_nm__c;
                //Host Region - stamp account onboarding's Host region on Geo of Account for IPA Program
                if(cpMap.get(accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name') && accOnboard.Core_MDF_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IntelAccount')) {
                    corpAcc.Core_Geo__c = accOnboard.Core_MDF_Host_Region_nm__c;         
                }
                //Partner Role - stamp account onboarding's Partner type on Account for EGF program
                if(cpMap.get(accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name') && accOnboard.Core_MDF_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IntelAccount')) {
                    corpAcc.Core_MDF_Partner_Type_nm__c = accOnboard.Core_MDF_Partner_Type_nm__c;
                }
              
                // Checking if VC Account Name is provided or not, if provided use the same name else create a new format with programCode and account name
                corpAcc.Name  = (accOnboard.Core_MDF_Virtual_Account_Name_txt__c != NULL)? accOnboard.Core_MDF_Virtual_Account_Name_txt__c : (programCode+' - ' + accMap.get(accOnboard.Core_MDF_Account__c).Name);  
                //if(progToGeoBasedSharingReq.get(cpMap.get(accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c)                                            
                    if(cpMap.get(accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c == Label.Core_MDF_Retail_Program_Name){
                        
                        //Added by Aswin- WW24'2025 release- for India region changes
                        /*string INDIA_GEO = Core_MDF_CCP_ConstantClass.INDIA_REGION;
                        string APJ_GEO = Core_MDF_CCP_ConstantClass.APJ_Region;
                        string SA_SUBGEO = Core_MDF_CCP_ConstantClass.SA_SUBREGION;

                        String region = (accMap.get(accOnboard.Core_MDF_Account__c).Core_Geo__c!=null && accMap.get(accOnboard.Core_MDF_Account__c).Core_Geo__c.toUpperCase() == INDIA_GEO) ? APJ_GEO : accMap.get(accOnboard.Core_MDF_Account__c).Core_Geo__c;
                        String subRegion = (accMap.get(accOnboard.Core_MDF_Account__c).Core_Sub_Geo__c!=null && accMap.get(accOnboard.Core_MDF_Account__c).Core_Sub_Geo__c.toUpperCase() == INDIA_GEO) ? SA_SUBGEO : accMap.get(accOnboard.Core_MDF_Account__c).Core_Sub_Geo__c;*/
						
                        corpAcc.Core_Geo__c = accMap.get(accOnboard.Core_MDF_Account__c).Core_Geo__c;
                        corpAcc.Core_Sub_Geo__c = accMap.get(accOnboard.Core_MDF_Account__c).Core_Sub_Geo__c;
                    }                                                        
                vcAccToBeInsertList.add(corpAcc); 
                vcAccToAccOnboardMap.put(corpAcc,accOnboard);
                accOnboardToVCMap.put(accOnboard,corpAcc);
            }
            // If vcAccToBeInsertList is not empty, then insert the virtual corp account records
            if(!vcAccToBeInsertList.isEmpty()){
                //Database.insert(vcAccToBeInsertList);
                Database.SaveResult[] srList = Database.insert(vcAccToBeInsertList, false);
                Integer count = 0;
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            vcAccToAccOnboardMap.get(vcAccToBeInsertList[count]).adderror(err.getMessage()); 
                        }
                    }
                    count ++;
                }
            }                              
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    /****************************************************************************************************** 
Method Name:        isIntelAccNonOnboarded
@return  :          N/A
@parameters:        set of new Account Onboarding records
Description:        This method is used to validate incoming accounts other than IPA whose co-Marketing Active is false
Added By:           Accenture - AD - 14/4/2022
Modified By:        Date:       Changes: 

*******************************************************************************************************/
    public static Boolean isIntelAccNonOnboarded(Core_MDF_Account_Onboarding__c accOnboard){
        Boolean isValid = false;
        if(accMap.containsKey(accOnboard.Core_MDF_Account__c) && accMap.get(accOnboard.Core_MDF_Account__c) != NULL  && accOnboard.Core_MDF_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IntelAccount')
           && !accMap.get(accOnboard.Core_MDF_Account__c).Core_MDF_CoMarketingActive__c){
               isValid = true;
           }
        return isValid;
    }
    /****************************************************************************************************** 
Method Name:        isIntelIPAAccount
@return  :          N/A
@parameters:        set of new Account Onboarding records
Description:        This method is used to validate incoming IPA accounts
Added By:           Accenture - AD - 14/4/2022
Modified By:        Date:       Changes: 

*******************************************************************************************************/
    public static Boolean isIntelIPAAccount(Core_MDF_Account_Onboarding__c accOnboard){
        Boolean isValid = false;
        if(accMap.containsKey(accOnboard.Core_MDF_Account__c) && accMap.get(accOnboard.Core_MDF_Account__c) != NULL  && accOnboard.Core_MDF_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IntelAccount')
           && (cpMap.get(accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name') 
               && accMap.get(accOnboard.Core_MDF_Account__c).Core_Intel_Partner_Alliance_PartnerGroup__c)){
                   isValid = true;
               }
        return isValid;
    }
    /****************************************************************************************************** 
Method Name:        isIntelAccOnboarded
@return  :          N/A
@parameters:        set of new Account Onboarding records
Description:        This method is used to validate incoming accounts other than IPA whose co-Marketing Active is true
Added By:           Accenture - AD - 14/4/2022
Modified By:        Date:       Changes: 

*******************************************************************************************************/
    public static Boolean isIntelAccOnboarded(Core_MDF_Account_Onboarding__c accOnboard){
        Boolean isValid = false;
        if(accMap.containsKey(accOnboard.Core_MDF_Account__c) && accMap.get(accOnboard.Core_MDF_Account__c) != NULL  && accOnboard.Core_MDF_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IntelAccount')
           && accMap.get(accOnboard.Core_MDF_Account__c).Core_MDF_CoMarketingActive__c){
               isValid = true;
           }
        return isValid;
    }
    /****************************************************************************************************** 
Method Name:        isAgencyAccount
@return  :          N/A
@parameters:        set of new Account Onboarding records
Description:        This method is used to validate incoming Agency accounts whose co-Marketing Active is false
Added By:           Accenture - AD - 14/4/2022
Modified By:        Date:       Changes: 

*******************************************************************************************************/
    public static Boolean isAgencyAccount(Core_MDF_Account_Onboarding__c accOnboard){
        Boolean isValid = false;
        if(accMap.containsKey(accOnboard.Core_MDF_Account__c) && accMap.get(accOnboard.Core_MDF_Account__c) != NULL && accOnboard.Core_MDF_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AgencyAccount')){
            isValid = true;
        }
        return isValid;
    }
    /****************************************************************************************************** 
Method Name:        isPartnerAccount
@return  :          N/A
@parameters:        set of new Account Onboarding records
Description:        This method is used to validate incoming Agency accounts whose co-Marketing Active is false
Added By:           Accenture - AD - 14/4/2022
Modified By:        Date:       Changes: 

*******************************************************************************************************/
    public static Boolean isPartnerAccount(Core_MDF_Account_Onboarding__c accOnboard){
        Boolean isValid = false;
        if(accMap.containsKey(accOnboard.Core_MDF_Account__c) && accMap.get(accOnboard.Core_MDF_Account__c) != NULL && !accMap.get(accOnboard.Core_MDF_Account__c).IsPartner && ((accMap.get(accOnboard.Core_MDF_Account__c).Core_MDF_CoMarketingActive__c && (accOnboard.Core_MDF_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IntelAccount'))) ||(accOnboard.Core_MDF_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AgencyAccount') && accMap.get(accOnboard.Core_MDF_Account__c).Core_MDF_CoMarketingAgency__c))){
            isValid = true;
        }
        return isValid;
    }
    /****************************************************************************************************** 
Method Name:        isAccountEligibleForMDF
@return  :          N/A
@parameters:        set of new accounts
Description:        This method is used to check whether incoming IPA accounts are part of any Unified Id, any account other than incoming accounts 
corresponding to Unified ID has comarketing active true and accounts has MDF benefit or not.
Added By:           Accenture - AD - 7/7/2020
Modified By:        Date:       Changes: 

*******************************************************************************************************/
    public static void isAccountEligibleForMDF(Set<Account> newAccountList,Map<Id,List<Core_MDF_Account_Onboarding__c>> nonOnboardedAccIdToAccOnboardMap){
        //set of account which has MDF benefit
        Set<Account> setOfMdfBenefitAcc;
        //set of only account with comarketing active true
        List<Core_MDF_Account_Onboarding__c> listofAccOnboardingToBeProccessed = new List<Core_MDF_Account_Onboarding__c>();
        //set of account which is part of Unified Id
        Set<Account> setOfUnifiedIdAccounts;//changed from setOfPrimeidAccounts to setOfUnifiedIdAccounts
        if(newAccountList!=null && newAccountList.size()>0){
            //Checking account is part of Unified Id
            setOfUnifiedIdAccounts = isUnifiedAccount(newAccountList,nonOnboardedAccIdToAccOnboardMap);
            if(setOfUnifiedIdAccounts!=null && setOfUnifiedIdAccounts.size()>0){
                //Checking any account other than incoming accounts corresponding to Unified ID has comarketing active true
                listofAccOnboardingToBeProccessed = isOtherAccComarkActiveInUnifiedID(setOfUnifiedIdAccounts,nonOnboardedAccIdToAccOnboardMap);
            }
            if(listofAccOnboardingToBeProccessed!=null && listofAccOnboardingToBeProccessed.size()>0){
                //Checking account has MDF benefit
                hasMDFBenefit(listofAccOnboardingToBeProccessed,nonOnboardedAccIdToAccOnboardMap);
            }
        }
    }
    
    /****************************************************************************************************** 
Method Name:        isUnifiedAccount
@return  :          set of final accounts
@parameters:        set of new accounts
Description:        This method is used to check whether incoming accounts are part of any Unified Id
Added By:           Accenture - AD - 7/7/2020
Modified By:        Date:       Changes: 

*******************************************************************************************************/  
    public static Set<Account> isUnifiedAccount(Set<Account> newAccountList, Map<Id,List<Core_MDF_Account_Onboarding__c>> nonOnboardedAccIdToAccOnboardMap)
    {
        //set of  accounts to be processed
        Set<Account> accountsToBeProcessed = new Set<Account>();
        //List of account onboarding records failed due to duplicate Unified Id's from bulk load
        List<Core_MDF_Account_Onboarding__c> listOfFailedAccOnboard = new List<Core_MDF_Account_Onboarding__c>();
        //List of account onboarding records whose accounts don't have Unified ID associated.
        List<Core_MDF_Account_Onboarding__c> listOfAccOnboardWithNoUnifiedID = new List<Core_MDF_Account_Onboarding__c>();//changed from listOfAccOnboardWithNoPrimeID to listOfAccOnboardWithNoUnifiedID
        if(!newAccountList.isEmpty()){
            for(Account account : newAccountList){
                String primeIdOrUnifiedField = account.Core_Unified_Global_Customer_BP_Id__c;
               /* if(primeIdOrUnifiedField != NULL){                    
                    if(mapOfUnifiedIdSetofAccOnb.containsKey(primeIdOrUnifiedField) && mapOfUnifiedIdSetofAccOnb.get(primeIdOrUnifiedField).size() > 1){
                        listOfFailedAccOnboard.addAll(mapOfUnifiedIdSetofAccOnb.get(primeIdOrUnifiedField));
                    }else{
                        accountsToBeProcessed.add(account);
                        mapOfIntelAccountandUnifiedId.put(account.Id,primeIdOrUnifiedField);
                    }
                }else{
                    listOfAccOnboardWithNoUnifiedID.addAll(nonOnboardedAccIdToAccOnboardMap.get(account.Id));
                }*/
                
                //ATHR Fix- Deeply nested if
                if (primeIdOrUnifiedField == null) {
                    listOfAccOnboardWithNoUnifiedID.addAll(nonOnboardedAccIdToAccOnboardMap.get(account.Id));
                    continue;
                }
                                
                if (mapOfUnifiedIdSetofAccOnb.containsKey(primeIdOrUnifiedField) && mapOfUnifiedIdSetofAccOnb.get(primeIdOrUnifiedField).size() > 1) {
                    listOfFailedAccOnboard.addAll(mapOfUnifiedIdSetofAccOnb.get(primeIdOrUnifiedField));
                    continue;
                }
                
                accountsToBeProcessed.add(account);
                mapOfIntelAccountandUnifiedId.put(account.Id, primeIdOrUnifiedField);
                
            }//ATHR END
        //}
        }
        //Iterating on list of onboarding records whose accounts don't have Unified ID associated
        for(Core_MDF_Account_Onboarding__c accOnboard : listOfAccOnboardWithNoUnifiedID)
        {
            //If prog is not IPA then put account and onboarding records to mapOfFinalaccToAccOnboard map
            if(cpMap.ContainsKey(accOnboard.Core_MDF_Channel_Program__c) && cpMap.get(accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name'))
            {
                if(mapOfFinalaccToAccOnboard.containsKey(accOnboard.Core_MDF_Account__c) && mapOfFinalaccToAccOnboard.get(accOnboard.Core_MDF_Account__c)!=null)
                {
                    mapOfFinalaccToAccOnboard.get(accOnboard.Core_MDF_Account__c).add(accOnboard);
                }
                else
                {
                    mapOfFinalaccToAccOnboard.put(accOnboard.Core_MDF_Account__c, new Set<Core_MDF_Account_Onboarding__c> {accOnboard});
                }
            }
            // else add onboarding records to failed list of onboarding records
            else
            {
                accOnboard.addError(Label.Core_MDF_AccHasNoOpidError+' '+primeIdOrUnifiedFieldErrorMsg+'.');
            }
        }
             //Adding error for all failed account Onboarding records
            for(Core_MDF_Account_Onboarding__c failedAcc : listOfFailedAccOnboard){
            //String primeIdOrUnifiedField = isUnifiedIdEnabled?accMap.get(failedAcc.Core_MDF_Account__c).Core_Unified_Global_Customer_BP_Id__c:accMap.get(failedAcc.Core_MDF_Account__c).Core_Prime_Id__c;
            String primeIdOrUnifiedField = accMap.get(failedAcc.Core_MDF_Account__c).Core_Unified_Global_Customer_BP_Id__c;
            if(accMap.containsKey(failedAcc.Core_MDF_Account__c) && accMap.get(failedAcc.Core_MDF_Account__c) != NULL && primeIdOrUnifiedField != NULL){                  
                failedAcc.addError('Two or more accounts with same '+primeIdOrUnifiedFieldErrorMsg+' "'+primeIdOrUnifiedField+'" exist in the request.');
            }else{
                //failedAcc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DuplicatePrimeIdInAccOnbError'));
                failedAcc.addError('Two or more accounts with same '+primeIdOrUnifiedFieldErrorMsg+' exist in the request.');
            }
        }
        return accountsToBeProcessed;
    }
    /****************************************************************************************************** 
Method Name:        isOtherAccComarkActiveInUnifiedID
@return  :          set of final accounts
@parameters:        set of new accounts
Description:        This method is used to check whether any account other than incoming accounts corresponding to Unified ID has comarketing active true
Added By:           Accenture - AD - 7/7/2020
Modified By:        Date:       Changes: 

*******************************************************************************************************/
    public static List<Core_MDF_Account_Onboarding__c> isOtherAccComarkActiveInUnifiedID(Set<Account> newAccountSet,Map<Id,List<Core_MDF_Account_Onboarding__c>> nonOnboardedAccIdToAccOnboardMap)
    {
        //set of unified Ids -- changed from primeIdSet to unifiedIDSet --JK
        Set<String> unifiedIDSet = new Set<String>();
        //Map of unified id to account -- changed from setOfCoMarketingActivePrimeIDs to setOfCoMarketingActiveUnifiedIDs -- JK
        Set<String> setOfCoMarketingActiveUnifiedIDs = new Set<String>();
        //Set to store incoming acconts Id's
        Set<Id> newAccountSetId = new Set<Id>();
        //List of final account onboarding records which got failed due to other Comark active
        List<Core_MDF_Account_Onboarding__c> listOfFailedAccOnboarding = new List<Core_MDF_Account_Onboarding__c>();
        //List of final account onboarding records which got failed due to IPA Affiliation
        List<Core_MDF_Account_Onboarding__c> listOfIpaAffFailedAccOnb = new List<Core_MDF_Account_Onboarding__c>();
        //List of final account onboarding records to be processed
        List<Core_MDF_Account_Onboarding__c> listofAccOnboardingToBeProccessed = new List<Core_MDF_Account_Onboarding__c>();
        List<Id> accInIpaAffiliation = new List<id>();
        List<Id> accToBeExcluded = new List<id>();
        Map<String,Account> unifiedIdToCoMarkAccountMap = new Map<String,Account>();//changed from primeIdToCoMarkAccountMap to unifiedIdToCoMarkAccountMap
        for(Account account : newAccountSet){
            if(mapOfIntelAccountandUnifiedId!=null && mapOfIntelAccountandUnifiedId.size()>0 && mapOfIntelAccountandUnifiedId.containsKey(account.id) && mapOfIntelAccountandUnifiedId.get(account.id)!=null){
                unifiedIDSet.add(mapOfIntelAccountandUnifiedId.get(account.id));
                newAccountSetId.add(account.id);
            }
        }
        //added by JK to replace prime id with UCD field
        //Quering existing accounts corresponding to Unified id 
        List<Account> listOfExistingIntelAccounts = Core_MDF_Account_Utility.fetchUnifiedIdAccounts(unifiedIDSet);/*[SELECT Id,Name,Core_Prime_Id__c,RecordType.DeveloperName,Core_MDF_CoMarketingActive__c,Core_Intel_Partner_Alliance_PartnerGroup__c from Account WHERE Core_Prime_Id__c IN: (primeIdSet) AND (RecordType.DeveloperName = 'Core_Partner_Account_Group' OR (RecordType.DeveloperName =: Label.Core_MDF_MasterAccount AND Core_Intel_Partner_Alliance_PartnerGroup__c = TRUE))];*/
    Set<Id> accountsIds = new Set<Id>();
        for(Account acc:listOfExistingIntelAccounts){
            accountsIds.add(acc.Id);
        }

        //Querying existing Account IPA Affiliation records to check if any MDF-Excluded Partner account is available
        List<PRM_IPA_Affiliation__c> ipaAff = Core_MDF_Account_Utility.fetchPRMIPAAffiliation(accountsIds,/*primeIdSet,*/null);
        for(PRM_IPA_Affiliation__c accIpaAff : ipaAff/*[SELECT Id, PRM_Account__c,PRM_Account__r.Core_Prime_Id__c FROM PRM_IPA_Affiliation__c WHERE PRM_Builder_Strategy__r.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ExcludedPartner') AND PRM_Account__r.Core_Prime_Id__c IN: (primeIdSet) AND PRM_Active__c = TRUE]*/){
            accInIpaAffiliation.add(accIpaAff.PRM_Account__c);
        }
        
        for(Account acc : listOfExistingIntelAccounts){
            //String accPrimeOrUnifiedField = isUnifiedIdEnabled?acc.Core_Unified_Global_Customer_BP_Id__c:acc.Core_Prime_Id__c;
            String accPrimeOrUnifiedField = acc.Core_Unified_Global_Customer_BP_Id__c;
            if(!accInIpaAffiliation.contains(acc.Id)){
                //added by JK
                //Map of Intel Acount and their corresponding Unified Id
                mapOfAllIntelAcctsIdUnifiedId.put(acc.Id,accPrimeOrUnifiedField);
                // creating a map of Unified ids and list of All Intel Account Ids
                if(!mapOfUnifiedIdSetofAccountId.containsKey(accPrimeOrUnifiedField)){
                    mapOfUnifiedIdSetofAccountId.put(accPrimeOrUnifiedField, new Set<Id>{acc.Id});
                }
                else{
                    mapOfUnifiedIdSetofAccountId.get(accPrimeOrUnifiedField).add(acc.Id);
                }

                //Roshan - IPA Simplification
                mapOfAllIntelAcctsIdtoOPID.put(acc.Id, acc.Core_IPA_One_Partner_Id__c);
                if(!mapOfOPIDtoSetofAccountId.containsKey(acc.Core_IPA_One_Partner_Id__c)){
                    mapOfOPIDtoSetofAccountId.put(acc.Core_IPA_One_Partner_Id__c, new Set<Id>{acc.Id});
                }
                else{
                    mapOfOPIDtoSetofAccountId.get(acc.Core_IPA_One_Partner_Id__c).add(acc.Id);
                }
                
                if((acc.RecordType.DeveloperName == Label.Core_MDF_MasterAccount) && acc.Core_Intel_Partner_Alliance_PartnerGroup__c && !(newAccountSetId.contains(acc.Id))){
                   /* if(!mapOfUnifiedIdSetofIntelAccId.containsKey(accPrimeOrUnifiedField)){
                        mapOfUnifiedIdSetofIntelAccId.put(accPrimeOrUnifiedField, new Set<Id>{acc.Id});
                    }
                    else{
                        mapOfUnifiedIdSetofIntelAccId.get(accPrimeOrUnifiedField).add(acc.Id);  // key as unifiedid and only intel account as values
                    }*/
                    
                    //ATHR FIX - Deeply nested if
                    Set<Id> unifiedIds = mapOfUnifiedIdSetofIntelAccId.containsKey(accPrimeOrUnifiedField) 
                        ? mapOfUnifiedIdSetofIntelAccId.get(accPrimeOrUnifiedField)
                        : new Set<Id>();
                    unifiedIds.add(acc.Id); // Add the current Account ID to the set
                    mapOfUnifiedIdSetofIntelAccId.put(accPrimeOrUnifiedField, unifiedIds); 
                    //ATHR END
                }
                //setOfCoMarketingActiveUnifiedIDs to store Unified ID and check if some other account for this Unified ID is already comarketing active -- changed by JK
                if(acc.Core_MDF_CoMarketingActive__c && !(newAccountSetId.contains(acc.Id))){
                    
                    setOfCoMarketingActiveUnifiedIDs.add(accPrimeOrUnifiedField);
                    unifiedIdToCoMarkAccountMap.put(accPrimeOrUnifiedField, acc);
                }
            }else if(accInIpaAffiliation.contains(acc.Id) && newAccountSetId.contains(acc.Id)){
                accToBeExcluded.add(acc.Id);
            }
        }
        //preparing final set of accounts which has to be processed
        for(Account account : newAccountSet){
            if(!accToBeExcluded.contains(account.Id) && (setOfCoMarketingActiveUnifiedIDs.isEmpty() ||
                                                             (setOfCoMarketingActiveUnifiedIDs!=null && setOfCoMarketingActiveUnifiedIDs.size()>0
                                                              && !setOfCoMarketingActiveUnifiedIDs.contains(mapOfIntelAccountandUnifiedId.get(account.id)))))
            {
                listofAccOnboardingToBeProccessed.addAll(nonOnboardedAccIdToAccOnboardMap.get(account.Id));
            }else{
                listOfFailedAccOnboarding.addAll(nonOnboardedAccIdToAccOnboardMap.get(account.Id));
            }
        }
        //Adding error for all failed accounts
        for(Core_MDF_Account_Onboarding__c failedAcc : listOfFailedAccOnboarding){
            if(accToBeExcluded.contains(failedAcc.Core_MDF_Account__c) && cpMap.ContainsKey(failedAcc.Core_MDF_Channel_Program__c) && cpMap.get(failedAcc.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name')){
                failedAcc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPAAffiliationError'));//This account cannot be onboarded as it is part of 'MDF-Excluded Partner' Affiliation
            }
            else if(mapOfIntelAccountandUnifiedId.containsKey(failedAcc.Core_MDF_Account__c) && mapOfIntelAccountandUnifiedId.get(failedAcc.Core_MDF_Account__c) != NULL &&
            unifiedIdToCoMarkAccountMap.containsKey(mapOfIntelAccountandUnifiedId.get(failedAcc.Core_MDF_Account__c)) && unifiedIdToCoMarkAccountMap.get(mapOfIntelAccountandUnifiedId.get(failedAcc.Core_MDF_Account__c)) != NULL){
                  failedAcc.addError('Co-Marketing Active is enabled for "'+unifiedIdToCoMarkAccountMap.get(mapOfIntelAccountandUnifiedId.get(failedAcc.Core_MDF_Account__c)).Name+'" account in the same '+primeIdOrUnifiedFieldErrorMsg+'.');
            }else{
                failedAcc.addError(Label.Core_MDF_OtherComarketingActiveAccExist+primeIdOrUnifiedFieldErrorMsg+'.');
            }
        }
        return listofAccOnboardingToBeProccessed;
    }   
    
    /****************************************************************************************************** 
Method Name:        hasMDFBenefit
@return  :          set of final accounts
@parameters:        set of new accounts
Description:        This method is used to check whether incoming accounts has MDF benefit or not
Added By:           Accenture - AD - 7/7/2020
Modified By:        Date:       Changes: 

*******************************************************************************************************/
    
    public static void hasMDFBenefit(List<Core_MDF_Account_Onboarding__c> accOnboardList,Map<Id,List<Core_MDF_Account_Onboarding__c>> nonOnboardedAccIdToAccOnboardMap)
    {
        //set of final IPA accounts which to be processed
        Set<Account> newIPAAccountSet = new Set<Account>();
        //Map of accounts to IPA account onboarding record
        Map<Id,Core_MDF_Account_Onboarding__c> accIdToIPAOnboardMap = new Map<Id,Core_MDF_Account_Onboarding__c>();
        //set of account Id
        Set<Id> setOfAccIds = new Set<Id>();
        //set of Unified ids
        Set<String> setOfUnifiedIds = new Set<String>();//changed from setOfPrimeIds to setOfUnifiedIds
        //set of MDF benefits 
        Set<String> setOfMDFPartnerBenefits = new Set<String>();
        //List of failed account onboarding records
        List<Core_MDF_Account_Onboarding__c> listOfFailedIPAOnboarding = new List<Core_MDF_Account_Onboarding__c>();
        
        for(Core_MDF_Account_Onboarding__c accOnboard : accOnboardList)
        {
            if(cpMap.containsKey(accOnboard.Core_MDF_Channel_Program__c) && cpMap.get(accOnboard.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name'))
            {
                if(mapOfFinalaccToAccOnboard.containsKey(accOnboard.Core_MDF_Account__c) && mapOfFinalaccToAccOnboard.get(accOnboard.Core_MDF_Account__c)!=null)
                {
                    mapOfFinalaccToAccOnboard.get(accOnboard.Core_MDF_Account__c).add(accOnboard);
                }
                else
                {
                    mapOfFinalaccToAccOnboard.put(accOnboard.Core_MDF_Account__c, new Set<Core_MDF_Account_Onboarding__c> {accOnboard});
                }             
            }
            else
            {
                newIPAAccountSet.add(accMap.get(accOnboard.Core_MDF_Account__c));
                accIdToIPAOnboardMap.put(accOnboard.Core_MDF_Account__c,accOnboard);
            }
        }
        for(Account account : newIPAAccountSet){            
            if(mapOfIntelAccountandUnifiedId!=null && mapOfIntelAccountandUnifiedId.size()>0 && mapOfIntelAccountandUnifiedId.containsKey(account.id) && mapOfIntelAccountandUnifiedId.get(account.Id)!=null){
                setOfAccIds.addAll(mapOfUnifiedIdSetofAccountId.get(mapOfIntelAccountandUnifiedId.get(account.id)));             
            }
        }

        // Roshan - IPA Simplification
        Boolean optAccountBenefitAssociation = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_OptAccountBenefitAssoc');

        Set<Id> setOfOnePartnerIds = new Set<Id>();
        for (Id accId : setOfAccIds) {
            if (mapOfAllIntelAcctsIdtoOPID.containsKey(accId) && mapOfAllIntelAcctsIdtoOPID.get(accId) != null) {
                setOfOnePartnerIds.add(mapOfAllIntelAcctsIdtoOPID.get(accId));
            }
        }
        String setOfGeneralizedAccountds = optAccountBenefitAssociation ? '(\'' + String.join(new List<Id>(setOfOnePartnerIds), '\', \'') + '\')' : '(\'' + String.join(new List<Id>(setOfAccIds), '\', \'') + '\')';

        Map<Id, Set<String>> accountIdToBenefitMap = Core_MDF_CampaignCreatePage.getAccountToBenefitsMap(optAccountBenefitAssociation, setOfGeneralizedAccountds);

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

        for (Id accId : accountIdToBenefitMap.keySet()) {
            if (String.isNotBlank(mapOfAllIntelAcctsIdUnifiedId.get(accId))) {
                if (!mapOfUnifiedIdToMDFBenIntAccId.containsKey(mapOfAllIntelAcctsIdUnifiedId.get(accId))) {
                    mapOfUnifiedIdToMDFBenIntAccId.put(mapOfAllIntelAcctsIdUnifiedId.get(accId), new Set<Id>());
                }
                mapOfUnifiedIdToMDFBenIntAccId.get(mapOfAllIntelAcctsIdUnifiedId.get(accId)).add(accId);
            }
        }

        for (Account account : newIPAAccountSet) {
            Boolean hasBenefit = false;

            if (accountIdToBenefitMap.containsKey(account.Id)) {
                hasBenefit = true;
            } else {
                String unifiedId = mapOfIntelAccountandUnifiedId.get(account.Id);
                if (String.isNotBlank(unifiedId) && mapOfUnifiedIdToMDFBenIntAccId.containsKey(unifiedId)) {
                    hasBenefit = true;
                }
            }

            if (hasBenefit) {
                if (mapOfFinalaccToAccOnboard.containsKey(account.Id) && mapOfFinalaccToAccOnboard.get(account.Id) != null) {
                    mapOfFinalaccToAccOnboard.get(account.Id).add(accIdToIPAOnboardMap.get(account.Id));
                } else {
                    mapOfFinalaccToAccOnboard.put(account.Id, new Set<Core_MDF_Account_Onboarding__c> {accIdToIPAOnboardMap.get(account.Id)});
                }
            } else {
                listOfFailedIPAOnboarding.add(accIdToIPAOnboardMap.get(account.Id));
            }
        }

        //Adding error for all failed accounts
        for(Core_MDF_Account_Onboarding__c failedAcc : listOfFailedIPAOnboarding){   
            List<String> errorMsg = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AccHasNoMDFBenefitError').split(':');
            failedAcc.addError(errorMsg[0]+' '+ucdIdOrPrimeId+' '+errorMsg[1]);
           // failedAcc.addError(Label.Core_MDF_AccHasNoMDFBenefitError+' '+primeIdOrUnifiedFieldErrorMsg+'.');
           
        }
    }
    
    /****************************************************************************************************** 
Method Name:        accountOnboardingOnBeforeInsert
@return  :          N/A
@parameters:        N/A
Description:        This method is used to auto select program name on selection of record type
Added By:           Accenture - AN - 24/1/2024
Modified By:        Date:       Changes: 

*******************************************************************************************************/
    
    public static void accountOnboardingOnBeforeInsert(List<Core_MDF_Account_Onboarding__c> listOfAccOnboardingRecords){
        //Get channel Program id based on record type selection
       Map<String,Id> programNameToProgramIdMap = new Map<String,Id>();
        for(Core_MDF_ChannelProgram__mdt cp:[Select Core_MDF_Technical_Program_Name__c,Core_MDF_Program_ID__c from Core_MDF_ChannelProgram__mdt where Core_MDF_Program_ID__c!=null]){
            programNameToProgramIdMap.put(cp.Core_MDF_Technical_Program_Name__c,cp.Core_MDF_Program_ID__c);
        }
        for(Core_MDF_Account_Onboarding__c accOnb:listOfAccOnboardingRecords){
            accOnb.Core_MDF_Channel_Program__c = programNameToProgramIdMap.get(accOnb.Core_MDF_Technical_Program_nm__c);

        }
               
    }

    /****************************************************************************************************** 
Method Name:        clearAllStaticMapValues
@return  :          N/A
@parameters:        N/A
Description:        This method is used to Clear out all the static variables 
Added By:           Accenture - AD - 26/4/2022
Modified By:        Date:       Changes: 

*******************************************************************************************************/
    public static void clearAllStaticMapValues()
    {
        prgmAbbName.clear();
        cpMap.clear();
        pgmMap.clear();
        accMap.clear();
        grpDevName.clear();
        mapOfUnifiedIdSetofAccOnb.clear();
        mapOfIntelAccountandUnifiedId.clear();
        mapOfUnifiedIdSetofAccountId.clear();
        mapOfUnifiedIdSetofIntelAccId.clear();
        mapOfUnifiedIdToMDFBenIntAccId.clear();
        mapOfAllIntelAcctsIdUnifiedId.clear();
        mapOfFinalaccToAccOnboard.clear();
        allAccessGrpDevName.clear();
        //Roshan - IPA Simplification
        mapOfOPIDtoSetofAccountId.clear();
        mapOfAllIntelAcctsIdtoOPID.clear();
    }    
}