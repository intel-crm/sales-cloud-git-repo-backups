/******************************************************************************************************
* Class Name  : Core_MDF_CCPAccount_Onboard 
* Version     : 1.0 
* Created Date: 7-7-2020
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Intel - SM      7/7/2020          Class for IPA account creation functionality
*******************************************************************************************************/
public without sharing class Core_MDF_CCPAccount_Onboard {
    
    //Map of technical program name to program abbrivated name
    public static Map<string,string> prgmAbbName = new Map<string,string>();
    //Map of technical program name to program Id
    public static Map<string,Id> prgmIdMap = new Map<string,Id>();
    //List of accounts
    public static List<Account> accountList = new List<Account>();
    //set of accounts in AGM
    public static Map<Id,Id> mapOfIntelAccountandOpId = new Map<Id,Id>();
    //Map of Op Id and related List of Intel Accounts
    public static Map<Id, Set<Id>> mapOfOpIdSetofAccountId = new Map<Id, Set<Id>>();
    //Map of All Intel Accounts and corresponding Op Id
    public static Map<Id,Id> mapOfAllIntelAcctsIdOpId = new Map<Id, Id>(); 
    
    /*****************************************************************************************************
Method Name:        createPublicGroup
@return  :          N/A
@parameters:        list of ccp account wrapper
Description:        This method is used to create public group
Added By:           Accenture - SM - 7/7/2020
Modified By:        Date:       Changes: 

*******************************************************************************************************/ 
    public static void createPublicGroup(List<Core_MDF_CCPAccountOnboardWrapper> accountsToOnboard)
    {
        //To hold group name
        String groupName;
        //To hold group developer name
        String groupDeveloperName;
        //To hold account name length
        Integer accountNameLength;
        //To hold group list
        List<Group> grpList = new List<Group>();
        for(Core_MDF_CCPAccountOnboardWrapper accWrap : accountsToOnboard)
        {
            groupDeveloperName = 'Core_MDF_CCP_'+String.valueOf(accWrap.account.Id)+'_'+prgmAbbName.get(accWrap.program)+'_'+'EXT';
            groupName = 'CCP '+String.valueOf(accWrap.account.Id)+ ' ' + prgmAbbName.get(accWrap.program) + ' ' + ' EXT';
            Group newGroup = new Group();
            newGroup.Name = groupName;
            newGroup.DeveloperName = groupDeveloperName;
            grpList.add(newGroup);
            accWrap.grpDevName = newGroup.DeveloperName;
        }
        //Check if grp exists and then change the name and insert
        Database.insert(grpList);   
    }
    

    /****************************************************************************************************** 
Method Name:        createPGM
@return  :          N/A
@parameters:        list of ccp account wrapper
Description:        This method is used to create partner group mapping
Added By:           Accenture - SM - 7/7/2020
Modified By:        Date:       Changes: 

*******************************************************************************************************/    
    public static void createPGM(List<Core_MDF_CCPAccountOnboardWrapper> accountsToOnboard)
    {
        //List of partner group mapping
        List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
        for(Core_MDF_CCPAccountOnboardWrapper accWrap : accountsToOnboard)
        {
            //New PGM instance
            Core_MDF_Partner_Group_Mapping__c newPGM = new Core_MDF_Partner_Group_Mapping__c();
            newPGM.Core_MDF_Account__c = accWrap.account.Id;
            newPGM.Core_MDF_Channel_Program__c = prgmIdMap.get(accWrap.program);
            newPGM.Core_MDF_Group_Name__c = accWrap.grpDevName;
            newPGM.Core_MDF_Type_of_Access__c = 'External';
            pgmList.add(newPGM);
        }
        Database.insert(pgmList);
    }
    
    /****************************************************************************************************** 
Method Name:        createCorpNode
@return  :          N/A
@parameters:        list of ccp account wrapper
Description:        This method is used to create corp node
Added By:           Accenture - SM - 7/7/2020
Modified By:        Date:       Changes: 

*******************************************************************************************************/        
    public static void createCorpNode(List<Core_MDF_CCPAccountOnboardWrapper> accountsToOnboard)
    {
        //List of accounts
        List<Account> accList = new List<Account>();
        //co-marketing record type Id
        ID coMarketingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_Marketing').getRecordTypeId();
        for(Core_MDF_CCPAccountOnboardWrapper accWrap : accountsToOnboard)
        {
            //New Account Instance
            Account corpAcc = new Account();
            corpAcc.RecordTypeId = coMarketingRecordTypeId;
            //corpAcc.Core_MDF_CoMarketingActive__c = true;
            corpAcc.Core_MDF_Parent_Fund_Account__c = accWrap.account.Id;
            corpAcc.Core_MDF_Channel_Program__c = prgmIdMap.get(accWrap.program);
            corpAcc.Name = 'IPA - ' + accWrap.account.Name;
            accList.add(corpAcc);
        }
        //Insert accounts
        Database.insert(accList);
    }

    /****************************************************************************************************** 
Method Name:        onboardAccountToCCP
@return  :          N/A
@parameters:        list of ccp account wrapper
Description:        This method is used to on board accounts to CCP
Added By:           Accenture - SM - 7/7/2020
Modified By:        Date:       Changes: 

*******************************************************************************************************/ 
    public static void onboardAccountToCCP(List<Core_MDF_CCPAccountOnboardWrapper> accountsToOnboard)
    {
        //set of program
        Set<string> prgmSet = new Set<string>();
        for(Core_MDF_CCPAccountOnboardWrapper accWrap : accountsToOnboard)
        {
            prgmSet.add(accWrap.program.replace('®',''));
            accountList.add(accWrap.account);
        }
        //Preparing map of technical program name to program Id
        for(ChannelProgram prgm : [Select Id, Core_MDF_Technical_Program_Name__c, Name 
                                   from ChannelProgram 
                                   where Core_MDF_Technical_Program_Name__c IN :prgmSet])
        {
            prgmIdMap.put(prgm.Core_MDF_Technical_Program_Name__c, prgm.Id);   
        }
        //Preparing map of technical program name to program abbrivated name
        for(Core_MDF_ChannelProgram__mdt cpm : [SELECT Core_MDF_Abbreviated_ProgramName_txt__c, Core_MDF_Technical_Program_Name__c, MasterLabel
                                                FROM Core_MDF_ChannelProgram__mdt
                                                WHERE Core_MDF_Technical_Program_Name__c IN :prgmSet])
        {
            prgmAbbName.put(cpm.Core_MDF_Technical_Program_Name__c, cpm.Core_MDF_Abbreviated_ProgramName_txt__c);
        }
        //Create public group
        createPublicGroup(accountsToOnboard);
        //Create parter group mapping
        createPGM(accountsToOnboard);
        //Create IPA corp node
        createCorpNode(accountsToOnboard);    
    }
    
    /****************************************************************************************************** 
Method Name:        isAccountEligibleForMDF
@return  :          N/A
@parameters:        set of new accounts
Description:        This method is used to Create Public Group,Create PGM,Create IPA Corp Node and display error if account is not eligible for MDF
Added By:           Accenture - AD - 7/7/2020
Modified By:        Date:       Changes: 

*******************************************************************************************************/
/*    public static void isAccountEligibleForMDF(List<Account> newAccountList){
        //List of account onboard wrapper
        List<Core_MDF_CCPAccountOnboardWrapper> listOfAccountOnboardWrapper =  new List<Core_MDF_CCPAccountOnboardWrapper>();
        //set of account which has MDF benefit
        Set<Account> setOfMdfBenefitAcc;
        //set of only account with comarketing active true
        Set<Account> setOfComarketingActiveAcc;
        //set of account which is part of one partner Id
        Set<Account> setOfOpidAccounts;
        if(newAccountList!=null && newAccountList.size()>0){
            //Checking account is part of one partner Id
            setOfOpidAccounts = isOpiAccount(newAccountList);
            if(setOfOpidAccounts!=null && setOfOpidAccounts.size()>0){
                //Checking account is comarketing active
                setOfComarketingActiveAcc = hasComarketingActive(setOfOpidAccounts);
            }
            if(setOfComarketingActiveAcc!=null && setOfComarketingActiveAcc.size()>0){
                //Checking account has MDF benefit
                setOfMdfBenefitAcc = hasMDFBenefit(setOfComarketingActiveAcc);
            }
          
            if(setOfMdfBenefitAcc!=null && setOfMdfBenefitAcc.size()>0){
                for(Account acc : setOfMdfBenefitAcc){
                    Core_MDF_CCPAccountOnboardWrapper ccpAccOnBoardWrpper = new Core_MDF_CCPAccountOnboardWrapper();
                    ccpAccOnBoardWrpper.account = acc;
                    ccpAccOnBoardWrpper.program = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name');
                    //preparing list of final accounts which is eligible for MDF benfit
                    listOfAccountOnboardWrapper.add(ccpAccOnBoardWrpper);
                }
                if(listOfAccountOnboardWrapper!=null && listOfAccountOnboardWrapper.size()>0){
                     onboardAccountToCCP(listOfAccountOnboardWrapper); 
                }
            }
        }
    }*/
    
    /****************************************************************************************************** 
Method Name:        isOpiAccount
@return  :          set of final accounts
@parameters:        set of new accounts
Description:        This method is used to check whether incoming accounts are part of any one partner Id
Added By:           Accenture - AD - 7/7/2020
Modified By:        Date:       Changes: 

*******************************************************************************************************/
    
    public static Set<Account> isOpiAccount(List<Account> newAccountList)
    {
        //set of  accounts to be processed
        Set<Account> accountsToBeProcessed = new Set<Account>();
        //set of final accounts to be processed
        Set<Account> finalAccountsToBeProcessed = new Set<Account>();
        //set of final accounts which got failed
        Set<Account> setOfFailedAccounts = new Set<Account>();
        //set of  accounts which got failed
        Set<Account> setOfFinalFailedAccounts = new Set<Account>();
        
        Set<Id> setOfIncomingAccounts = new Set<Id>();
        for(Account newAccount: newAccountList){
            setOfIncomingAccounts.add(newAccount.Id);
        }

         //Preparing map of OPID account and List Of Intel Accounts
        Map<Id,Id> mapOfOPIDAndActiveAccounts = new Map<Id,Id>();
        
        //Quering existing accounts corresponding to one partner id and whose comarketing active true
        for(Core_Account_Group_Member__c agm : [Select Id,Core_Partner_Account_Id__c,Core_Intel_Account_Id__r.Core_MDF_CoMarketingActive__c,Core_Intel_Account_Id__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c IN: (newAccountList) and Core_Inactive_Ind__c= false and Core_Partner_Account_Id__c!=null]){
        
            // map to store OPID corresponding to each incoming Intel Account whose Co-marketing is set to true
            mapOfIntelAccountandOpId.put(agm.Core_Intel_Account_Id__c,agm.Core_Partner_Account_Id__c);
        }
                                
        if(newAccountList!=null && newAccountList.size()>0){
            for(Account account : newAccountList){
                if(mapOfIntelAccountandOpId!=null && mapOfIntelAccountandOpId.size()>0 
                    && mapOfIntelAccountandOpId.keySet().contains(account.Id)){
                        accountsToBeProcessed.add(account);
                    }else{
                        setOfFailedAccounts.add(account);
                    }
            }
        }
        
        //Adding error for all failed accounts
        for(Account failedAcc : setOfFailedAccounts){
            failedAcc.addError(Label.Core_MDF_AccHasNoOpidError);
        }
        
        return accountsToBeProcessed;
    }
    
    
    /****************************************************************************************************** 
Method Name:        hasComarketingActive
@return  :          set of final accounts
@parameters:        set of new accounts
Description:        This method is used to check whether any account other than incoming accounts corresponding to one partner ID has comarketing active true
Added By:           Accenture - AD - 7/7/2020
Modified By:        Date:       Changes: 

*******************************************************************************************************/
    public static Set<Account> hasComarketingActive(Set<Account> newAccountSet)
    {
        //set of one partner Ids
        Set<Id> opidSet = new Set<Id>();
        //set of final accounts to be processed
        Set<Account> accountsToBeProcessed = new Set<Account>();
        //set of final accounts which got failed
        Set<Account> listOfFailedAccounts = new Set<Account>();
        //Map of one partner id to CCP account
        Set<Id> setOfCoMarketingActiveOPIDs = new Set<Id>();
        for(Account account : newAccountSet){
            if(mapOfIntelAccountandOpId!=null && mapOfIntelAccountandOpId.size()>0 && mapOfIntelAccountandOpId.containsKey(account.id) && mapOfIntelAccountandOpId.get(account.id)!=null){
                opidSet.add(mapOfIntelAccountandOpId.get(account.id));
            }
        }
        
        //Quering existing accounts corresponding to one partner id and whose comarketing active true
        List<Core_Account_Group_Member__c> listOfExistingAccGroupMember = [Select Id,Core_Partner_Account_Id__c,Core_Intel_Account_Id__r.Core_MDF_CoMarketingActive__c,Core_Intel_Account_Id__c from Core_Account_Group_Member__c where Core_Partner_Account_Id__c IN: (opidSet)
                                                                           and Core_Inactive_Ind__c= false];
        
        //preparing map of one partner id to CCP account
        for(Core_Account_Group_Member__c accGrpMember : listOfExistingAccGroupMember){
            
            // Map of Intel Acount and their corresponding OpId
            mapOfAllIntelAcctsIdOpId.put(accGrpMember.Core_Intel_Account_Id__c,accGrpMember.Core_Partner_Account_Id__c);
            // creating a map of OPids and list of All Intel Account Ids
            if(!mapOfOpIdSetofAccountId.containsKey(accGrpMember.Core_Partner_Account_Id__c)){
                mapOfOpIdSetofAccountId.put(accGrpMember.Core_Partner_Account_Id__c, new Set<Id>{accGrpMember.Core_Intel_Account_Id__c});
            }
            else{
                mapOfOpIdSetofAccountId.get(accGrpMember.Core_Partner_Account_Id__c).add(accGrpMember.Core_Intel_Account_Id__c);
            }
            // setOfCoMarketingActiveOPIDs to store OPID and check if some other account for this OPID is already comarketing active
            if(accGrpMember.Core_Intel_Account_Id__r.Core_MDF_CoMarketingActive__c){
                setOfCoMarketingActiveOPIDs.add(accGrpMember.Core_Partner_Account_Id__c);
            }
        }
        
        //preparing final set of accounts which has to be processed
        for(Account account : newAccountSet){
            if(setOfCoMarketingActiveOPIDs.isEmpty() ||
               (setOfCoMarketingActiveOPIDs!=null && setOfCoMarketingActiveOPIDs.size()>0
                && !setOfCoMarketingActiveOPIDs.contains(mapOfIntelAccountandOpId.get(account.id)))){
                    accountsToBeProcessed.add(account);
                }else{
                    listOfFailedAccounts.add(account);
                }
        }
        //Adding error for all failed accounts
        for(Account failedAcc : listOfFailedAccounts){
            failedAcc.addError(Label.Core_MDF_OtherComarketingActiveAccExist);
        }
        return accountsToBeProcessed;
    }
    
    /****************************************************************************************************** 
Method Name:        hasMDFBenefit
@return  :          set of final accounts
@parameters:        set of new accounts
Description:        This method is used to check whether incoming accounts has MDF benefit or not
Added By:           Accenture - AD - 7/7/2020
Modified By:        Date:       Changes: 

*******************************************************************************************************/
    
  /*  public static Set<Account> hasMDFBenefit(Set<Account> newAccountSet)
    {
        //to hold benefit name string for search 
        //'%MDF%'
        //String benefitNameString = Label.Core_MDF_Benefit_Label;
        //set of final accounts to be processed 
        Set<Account> accountsToBeProcessed = new Set<Account>();
        //set of final accounts which got failed
        Set<Account> listOfFailedAccounts = new Set<Account>();
        //set of account Id and account opid
        Set<Id> setOfAccIdOrOpid = new Set<Id>();
        //set of PRM account Id
        Set<Id> setOfPrmAccountId = new Set<Id>();
        //set of opids
        Set<Id> setOfOpIds = new Set<Id>();
        //set of MDF benefits 
        Set<String> setOfMDFPartnerBenefits = new Set<String>();
        
        for(Account account : newAccountSet){            
            if(mapOfIntelAccountandOpId!=null && mapOfIntelAccountandOpId.size()>0 && mapOfIntelAccountandOpId.containsKey(account.id) && mapOfIntelAccountandOpId.get(account.Id)!=null){
                //Add account OPID
                setOfAccIdOrOpId.add(mapOfIntelAccountandOpId.get(account.id));
                //Add all intel accounts for that opid
                setOfAccIdOrOpId.addAll(mapOfOpIdSetofAccountId.get(mapOfIntelAccountandOpId.get(account.id)));             
            }
        }
        //Querying  fields and adding it in setOfMDFPartnerBenefits 
        for(Core_MDF_BudgetType_Benefit_Mappings__c mdfPartnerBenefit : [Select Id, Core_MDF_Partner_Benefit__c from Core_MDF_BudgetType_Benefit_Mappings__c LIMIT 1000])
        {
            setOfMDFPartnerBenefits.add(mdfPartnerBenefit.Core_MDF_Partner_Benefit__c);            
        }
        //Quering existig account specialty association records, to check for MDF specialty corresponding to account Id or one partner Id
        List<PRM_Account_Specialty_Association__c> listOfExistingAccBenefitAccoc = [SELECT ID, PRM_Account_Id__c, PRM_Specialty_Id__r.name from PRM_Account_Specialty_Association__c
                                                                                    where PRM_Specialty_Id__r.name IN: (setOfMDFPartnerBenefits) and PRM_Account_Id__c IN: (setOfAccIdOrOpid) and PRM_InActive_Ind__c = FALSE ];
        
        //preparing set of associated accounts
        for(PRM_Account_Specialty_Association__c accBenefitAssoc : listOfExistingAccBenefitAccoc){
            // If Account is an Intel Account having Op Id , then Add Account's Op Id in setOfOpIds  
            if(mapOfAllIntelAcctsIdOpId.containsKey(accBenefitAssoc.PRM_Account_Id__c)){
                setOfOpIds.add(mapOfAllIntelAcctsIdOpId.get(accBenefitAssoc.PRM_Account_Id__c));
            }
            //If the Account is One Partner Group Account
            else{
                setOfOpIds.add(accBenefitAssoc.PRM_Account_Id__c);
            }
            
        }
        //preparing final set of accounts which has to be processed
        for(Account account : newAccountSet){
            
            // only those account will ve processed whose benefit association exists for any Account in the same One Partner Account Group
            if(setOfOpIds!=null && setOfOpIds.size()>0 && setOfOpIds.contains(mapOfIntelAccountandOpId.get(account.Id))){
                accountsToBeProcessed.add(account);
            }
            else{
                listOfFailedAccounts.add(account);
            }           
        }
        //Adding error for all failed accounts
        for(Account failedAcc : listOfFailedAccounts){
            failedAcc.addError(Label.Core_MDF_AccHasNoMDFBenefitError);
        }
        return accountsToBeProcessed;
    }*/
}