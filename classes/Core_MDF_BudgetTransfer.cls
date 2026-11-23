/****************************************************************************************************************************************
* Class Name  : Core_MDF_BudgetTransfer  
* Version     : 1.0 
* Created Date: 8-15-2018
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - SM      8/15/2018          Handler Class for Budget Transfer functionalities.
*****************************************************************************************************************************************/
public with sharing class Core_MDF_BudgetTransfer {
    
    /***************************************************************************************************** 
Method Name:        checkAccess
@return  :          hasAccess
@parameters:        
Description:        This method is used to check whether the logged in user has access to Transfer Budgets.
Added By:           Intel - SM - 08/19/2018
Modified By:        Date:       Changes: 
******************************************************************************************************/
    @AuraEnabled
    public static boolean checkAccess(){
        
        String rawLabelValue = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Transfer_Access');
        List<String> permissionSets = rawLabelValue.split(';');
        List<PermissionSetAssignment> validPermissionSet = new List<PermissionSetAssignment>();
        
        validPermissionSet = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userinfo.getuserid() AND 
                              PermissionSet.Name In :permissionSets];
        return validPermissionSet.size() > 0 ? true : false;  
        
    }
    
	/***************************************************************************************************** 
Method Name:        SearchAccountsLookup
@return  :          List<Account>
@parameters:        
Description:        This method will be invoked when the user open Account Transfer screen and return all the accounts.
Added By:           Intel - SM - 08/15/2018
Modified By:  Accenture - Sandesh H       Date: 24-05-2022      Changes: Removed search parameter
******************************************************************************************************/
    @AuraEnabled
    public static List<Account> searchAccountsLookup(){
        
        List<Account> listOfAccounts;
        map<id, Account> mapOfIUPGMAccounts = new map<id, Account>();
        //map<id, Account> mapOfEEFAccounts = new map<id, Account>();
        //check the current user has custom permission or not
        Boolean hasMDFBudgetCreationPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_MDF_Budget_Loader_Approver'); 
        
        Boolean hasIPABudgetCreationAccess = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_IPA_Budget_Loader_Approver');          
        Boolean hasCoGTMBudgetTransferAccess=FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Co_GTM_Budget_Loader') || FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Co_GTM_Budget_Approver') ||FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Co_GTM_Budget_Manager');
        Boolean hasFinanceUserPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Finance_User_Manager') || FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Finance_Usr') || FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Finance_Manager'); 
        Boolean hasEEFBudgetTransferAccess = FeatureManagement.checkPermission('Core_MDF_Internal_EEF_Budget_Manager') || FeatureManagement.checkPermission('Core_MDF_Internal_EEF_Budget_Loader') ||FeatureManagement.checkPermission('Core_MDF_Internal_EEF_Budget_Approver');
        Boolean hasEEFprimaryBudgetLoader = FeatureManagement.checkPermission('Core_MDF_Internal_EEF_Budget_Loader');
        Boolean hasEEFprimaryBudgetApprover = FeatureManagement.checkPermission('Core_MDF_Internal_EEF_Budget_Approver') ;
        Boolean hasEEFactivatingBudgetMgr = FeatureManagement.checkPermission('Core_MDF_Internal_EEF_Budget_Manager');
        
        try
        {
            ID coMarketingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_Marketing').getRecordTypeId();
            
            listOfAccounts = [select Id, Name, Core_MDF_Channel_Program__r.Name, Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Channel_Program__c from Account where 
                              RecordTypeId=:coMarketingRecordTypeId and IsPartner = TRUE and Core_MDF_Active_Ind__c = TRUE order by Name ASC];
            
            
            if((listOfAccounts.size()>0 && !listOfAccounts.isEmpty()) && ((hasMDFBudgetCreationPermission || hasIPABudgetCreationAccess || hasEEFBudgetTransferAccess || hasCoGTMBudgetTransferAccess) && !hasFinanceUserPermission)){
                //invoking the system context class to fetch IUPGM records to comparing it with incoming accoun records.
                listOfAccounts = Core_MDF_BudgetTransferUtility.retrieveAccountsByIUPGMAccess(listOfAccounts);
		}
            
            //Below condition has been added to show only virtaul corp account when primary budget loader/approver is doing a transfer
            if((hasEEFprimaryBudgetLoader || hasEEFprimaryBudgetApprover) && !hasEEFactivatingBudgetMgr){
                List<Account> finalAccountList = new List<Account>();
                String EEF_Program = Core_MDF_CCP_ConstantClass.EEF_PROGRAM;

                //creating a map of IUPGM accounts
                if(listOfAccounts.size()>0){
                    for(Account ac : listOfAccounts){
                        mapOfIUPGMAccounts.put(ac.id,ac);                    
                    }
                }
                //Below query will return all the EEF Nodes(Primary & Activating) except the virtual corp and will add it to map directly
                map<id, Account> mapOfEEFAccounts = new map<id, Account>(
                    [select Id, Name, Core_MDF_Channel_Program__r.Name, Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Channel_Program__c from Account where 
                                  RecordTypeId=:coMarketingRecordTypeId and IsPartner = TRUE and Core_MDF_Active_Ind__c = TRUE and Core_MDF_Parent_Fund_Account__r.RecordTypeId =: coMarketingRecordTypeId
                                  and Core_MDF_Channel_Program__r.name =:EEF_Program  order by Name ASC]);                 
                
                //iterating over map of account from IUPGM and adding account(only virtual corps for EEF) and virtual corp and nodes for other program if exist
                for(Id accId  : mapOfIUPGMAccounts.keyset()){
                    if(!mapOfEEFAccounts.isempty() && !mapOfEEFAccounts.containsKey(accId)){
                        finalAccountList.add(mapOfIUPGMAccounts.get(accid));
                    }
                }
                //Clearing existing list and adding valid accounts to be shown in the same list 
                if(!finalAccountList.isEmpty()){
                    listOfAccounts.clear();
                    listOfAccounts.addAll(finalAccountList);
                }
            }
            
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}// JV- Accenture : Add the exception into Core_Log_Entry Object
        return listOfAccounts;
    }
    
    
    /***************************************************************************************************** 
Method Name:        AccountIDNameMapping
@return  :          Account
@parameters:        Account Id
Description:        This method is used to get the name of an account given the Id.
Added By:           Intel - SM - 08/15/2018
Modified By:        Date:       Changes: 
******************************************************************************************************/
    
    @AuraEnabled
    public static Account accountIDNameMapping(Id id){
        Account accountDetail;
        Boolean activatingBudgetManager = FeatureManagement.checkPermission('Core_MDF_Internal_EEF_Budget_Manager');
 
        try
        {
            if(activatingBudgetManager){
            BudgetDetailsWithoutShare instWithoutShare = new BudgetDetailsWithoutShare();
            accountDetail = instWithoutShare.getAccountWithoutShare(id);
            }
            else{
            accountDetail=[select id, Name from Account where id = :id];
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}// JV- Accenture : Add the exception into Core_Log_Entry Object
        
        return accountDetail;
        
    }
    
    /***************************************************************************************************** 
Method Name:        GetToAccounts
@return  :          List<Account>
@parameters:        fromAcctId
Description:        This method is used to get the list of Accounts in the hierarchy of the selected 
fromAccount in the Budget Transfer
Added By:           Intel - SM - 08/15/2018
Modified By: Accenture - Sandesh H       Date: 24-05-2022      Changes: Added Order by in query
******************************************************************************************************/
    
    @AuraEnabled
    public static List<Account> getToAccounts(Id fromAcctId,String budgetId)  {
        List<Account> toAccounts = new List<Account>();
        
        Boolean activatingBudgetAdmin = FeatureManagement.checkPermission('Core_MDF_CCP_External_EEF_Account_Budget_Administrator');
        Boolean activatingBudgetManager = FeatureManagement.checkPermission('Core_MDF_Internal_EEF_Budget_Manager');
        Boolean primaryBudgetLoader = FeatureManagement.checkPermission('Core_MDF_Internal_EEF_Budget_Loader');
        Boolean primaryBudgetApprover = FeatureManagement.checkPermission('Core_MDF_Internal_EEF_Budget_Approver') ;
        String ACTIVATING_PARTNER = Core_MDF_CCP_ConstantClass.ACTIVATING_PARTNER ;            
	   String PRIMARY_PARTNER = Core_MDF_CCP_ConstantClass.PRIMARY_PARTNER ;   
       Id primaryPartnerId ;
        String str = '';
       	Set<String> toAccountIds = new Set<String>();

        try
        {
            ID coMarketingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_Marketing').getRecordTypeId();
            List<Account> fromAccount = [Select Id, Name, Core_MDF_Channel_Program__c, Core_MDF_Virtual_Corp_Account_Id__c,Core_MDF_Channel_Program__r.Name,Core_MDF_Partner_Type_nm__c, Core_MDF_CoMarketing_Ultimate_Account__c from Account where Id = :fromAcctId AND Core_MDF_Active_Ind__c = TRUE];
            
            // Early return if no account found to prevent "List index out of bounds" error
            if(fromAccount == null || fromAccount.size() == 0){
                return toAccounts;
            }
            
            //Avoid Deeply Nested IF Statements
                if(coMarketingRecordTypeId != null && fromAccount[0].Core_MDF_Channel_Program__r.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name')){
                    Boolean isFromAccPrimary = (fromAccount[0].Core_MDF_Partner_Type_nm__c!=null && fromAccount[0].Core_MDF_Virtual_Corp_Account_Id__c == null && fromAccount[0].Core_MDF_Partner_Type_nm__c.contains(PRIMARY_PARTNER))? true : false ;
        			Boolean isFromAccActivating = (fromAccount[0].Core_MDF_Partner_Type_nm__c!=null && fromAccount[0].Core_MDF_Virtual_Corp_Account_Id__c == null &&fromAccount[0].Core_MDF_Partner_Type_nm__c.contains(ACTIVATING_PARTNER))? true : false ;
        			Boolean isFromAccNode = fromAccount[0].Core_MDF_Virtual_Corp_Account_Id__c != null ?true : false;
                    //If from Account is Primary account
                   
                    if(isFromAccPrimary && (primaryBudgetLoader || primaryBudgetApprover)){//add budget loader and approver
                        for(Core_MDF_Partner_Mapping__c primaryToActivating : [Select Id,  Core_MDF_Activating_Partner_Account_id__c From Core_MDF_Partner_Mapping__c 
                                                                           Where Core_MDF_Primary_Partner_Account_id__c = :fromAccount[0].Id ]){
                                                                               toAccountIds.add(primaryToActivating.Core_MDF_Activating_Partner_Account_id__c);
                                                                           }
                        toAccounts = [Select Id, Name, Core_MDF_Channel_Program__c,Core_MDF_Parent_Fund_Account__r.RecordType.Name From Account where Core_MDF_Channel_Program__c = :fromAccount[0].Core_MDF_Channel_Program__c And RecordTypeId=:coMarketingRecordTypeId 
                                          And Id <> :fromAccount[0].Id And Id = :toAccountIds AND Core_MDF_Active_Ind__c = TRUE AND Core_MDF_Parent_Fund_Account__r.RecordType.Name !='CoMarketing' Order by Name ASC];//parent rec not in co-marketing
                        
                    }
                    //If FromAccount is Activating Account
                    if(isFromAccActivating){
                        BudgetDetailsWithoutShare getBudgets = new BudgetDetailsWithoutShare();
                        if(budgetId != '' && activatingBudgetManager){
                            // toAccounts.addAll(getBudgets.getToAccountsWithoutShare(fromAccount[0],coMarketingRecordTypeId,primaryPartnerId));
                            primaryPartnerId = getBudgets.getPrimaryPartnerWithoutShare(budgetId);
                        }else{
                            primaryPartnerId = getPrimaryPartner(budgetId);
                        }
                        if (activatingBudgetManager){
                            
                            toAccounts.addAll(getBudgets.getToAccountsWithoutShare(fromAccount[0],coMarketingRecordTypeId,primaryPartnerId));
                        }else{ //csp bud loader/approver and external isv acc admin
                            List<Account> accList = new List<Account> ();
                             Id cpId = fromAccount[0].Core_MDF_Channel_Program__c;
                            Id fromAccId =fromAccount[0].Id;
                            String qryStr = 'SELECT Id,Name,Core_MDF_Channel_Program__c FROM Account '+
                                'WHERE Core_MDF_Channel_Program__c =:cpId '+
                                'AND RecordTypeId =: coMarketingRecordTypeId '+
                                'AND Core_MDF_Active_Ind__c = TRUE ';
                            
                            if(primaryBudgetLoader || primaryBudgetApprover ){//CSP BUD Loader/Approver
                                str = qryStr + 'AND Id <>: fromAccId AND Id =: primaryPartnerId Order by Name ASC';
                                accList = Database.query(str);
                                toAccounts.addAll(accList);
                            }
                            if(activatingBudgetAdmin){
                                Id ultimateAccId = fromAccount[0].Core_MDF_CoMarketing_Ultimate_Account__c ;
                                str  = qryStr + 'AND Id <>: fromAccId AND Core_MDF_CoMarketing_Ultimate_Account__c =: ultimateAccId Order by Name ASC' ;
                                accList = Database.query(str);
                                toAccounts.addAll(accList);
                                
                            }
                            
                        }
                        
                    } 
                    //If From Account is Activating Account Node
                    if(isFromAccNode){
                        toAccounts = [Select Id, Name, Core_MDF_Channel_Program__c From Account where Core_MDF_Channel_Program__c = :fromAccount[0].Core_MDF_Channel_Program__c 
                                      And RecordTypeId=:coMarketingRecordTypeId And Id <> :fromAccount[0].Id And Id = :fromAccount[0].Core_MDF_Virtual_Corp_Account_Id__c  AND Core_MDF_Active_Ind__c = TRUE Order by Name ASC];
                    }
                    
                }else{
                toAccounts = [Select Id, Name, Core_MDF_Channel_Program__c From Account     where Core_MDF_CoMarketing_Ultimate_Account__c = :fromAccount[0].Core_MDF_CoMarketing_Ultimate_Account__c
                              And Core_MDF_Channel_Program__c = :fromAccount[0].Core_MDF_Channel_Program__c And RecordTypeId=:coMarketingRecordTypeId and Id <> :fromAccount[0].Id AND Core_MDF_Active_Ind__c = TRUE Order by Name ASC];
                }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}// JV- Accenture : Add the exception into Core_Log_Entry Object
                
        return toAccounts;
    }
    /**************************************************************************************************************************  
Method Name:        GetPrimaryPartnerId
@return  :          ID
@parameters:        BudgetID
Description:        This method is used to get the Account on which budget is created
Added By:           Keerthi

****************************************************************************************************************************/
    public static Id getPrimaryPartner (String budgetId){
        Id primaryPartnerid ;
        List<PartnerMarketingBudget> budgetList = [SELECT ID, Core_MDF_Budget_Partner__c FROM PartnerMarketingBudget where Id = :budgetId ];
        if(!budgetList.isEmpty()){
            primaryPartnerid =budgetList[0].Core_MDF_Budget_Partner__c;
        }
        return primaryPartnerid;
    }  
    
    /**************************************************************************************************************************  
Method Name:        GetBudgetList
@return  :          List<PartnerMarketingBudget>
@parameters:        fromAcctId - Selected FromAccount
Description:        This method is used to get the list of budgets that have an allocation for the selected FromAccount.
Added By:           Intel - SM - 08/15/2018
Modified By: Accenture - Sandesh H       Date: 24-05-2022       Changes: Wrapper class is used
****************************************************************************************************************************/
    
    @AuraEnabled
    public static List<Core_MDF_SearchableDropDownItemWrapper> getBudgetList(Id fromAcctId)
    {   
        Set<Id> budgetIdList = new Set<Id>();
        List<PartnerMarketingBudget> budgetList = new List<PartnerMarketingBudget>();
        List<Core_MDF_SearchableDropDownItemWrapper> results = new List<Core_MDF_SearchableDropDownItemWrapper>();
        List<PartnerFundAllocation> allocations; 
        Boolean activatingBudgetAdmin = FeatureManagement.checkPermission('Core_MDF_CCP_External_EEF_Account_Budget_Administrator');
        Boolean activatingBudgetManager = FeatureManagement.checkPermission('Core_MDF_Internal_EEF_Budget_Manager');
        try{
            allocations = [SELECT ID, BudgetId FROM PartnerFundAllocation where ChannelPartnerId = :fromAcctId];
            if(allocations != null && allocations.size()>0)
            {
                for(PartnerFundAllocation pfa:allocations){
                    budgetIdList.add(pfa.BudgetId);
                }
            }
            
            // Custom permission to Budget Transfer record // Budget Transfer contains Allowed Budget Types, Programs for that custom permission 
            Map<String,Core_MDF_CCP_Budget_Transfer_Config__c> cpNameBudTransferMap = new Map<String,Core_MDF_CCP_Budget_Transfer_Config__c>();
            
            // Fetching all values of Core_MDF_CCP_Budget_Transfer_Config__c and storing in a map with key as custom permission name and value as custom setting record
            for(Core_MDF_CCP_Budget_Transfer_Config__c budgetTransferConfig : Core_MDF_CCP_Budget_Transfer_Config__c.getall().values())
            {
                cpNameBudTransferMap.put(budgetTransferConfig.Core_MDF_Custom_Permission_Name_Txt__c,budgetTransferConfig);
            }
            
            // Logic to check available access for logged in user and storing Budget Types and Programs applicable in a set<string>
            Set<String> applicableBudgetTypes = new Set<String>();
            Set<String> applicablePrograms = new Set<String>();
            for(String cp : cpNameBudTransferMap.keySet()){
                if(FeatureManagement.checkPermission(cp) && cpNameBudTransferMap != NULL && cpNameBudTransferMap.containsKey(cp)){
                    Core_MDF_CCP_Budget_Transfer_Config__c budTransferData = cpNameBudTransferMap.get(cp);
                    applicableBudgetTypes.addAll(budTransferData.Core_MDF_Budget_Type_Txt__c.split(';'));
                    applicablePrograms.addAll(budTransferData.Core_MDF_Program_Txt__c.split(';'));
                }
            }
            
            if(budgetIdList.size() > 0){
                
                
                if(activatingBudgetManager||activatingBudgetAdmin){
                    
                    BudgetDetailsWithoutShare getBudgets = new BudgetDetailsWithoutShare();
                    budgetList =getBudgets.getApplicableBudgetList(applicableBudgetTypes,applicablePrograms,budgetIdList);
                    
                }else{
                    budgetList = getApplicableBudgetList(applicableBudgetTypes,applicablePrograms,budgetIdList);
                }
                
                
            }
            else
            {
                AuraHandledException ex = new AuraHandledException(Label.Core_MDF_No_Available_Budget_Error);
                ex.setMessage(Label.Core_MDF_No_Available_Budget_Error);
                throw ex;
            }
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            throw e;
        }
        
        if(budgetList != null && budgetList.size()>0){
            for(PartnerMarketingBudget Budget : budgetList){
                if(Budget.Core_MDF_Budget_Type_Txt__c != null){
                results.add(new Core_MDF_SearchableDropDownItemWrapper(Budget.Id, Budget.Title+' - '+Budget.Core_MDF_Budget_Type_Txt__c));
                }
                else{
                    results.add(new Core_MDF_SearchableDropDownItemWrapper(Budget.Id, Budget.Title));
                }
            }
        }        
        return results;
    }
    
    /**************************************************************************************************************************  
Method Name:        getApplicableBudgetList
@return  :          List<PartnerMarketingBudget>
@parameters:        applicableBudgetTypes,applicablePrograms,budgetIdList
Description:        This method is used to get the applicable budgets based on logged in user's access
Added By:           Accenture-HP - 03/01/2021
Modified By: Accenture - Sandesh H       Date: 24-05-2022       Changes: Added Order by in query 
****************************************************************************************************************************/
    public static List<PartnerMarketingBudget> getApplicableBudgetList(Set<String>applicableBudgetTypes,Set<String>applicablePrograms,Set<Id> budgetIdList){
        List<PartnerMarketingBudget> budgetList = new List<PartnerMarketingBudget>();
        // checking if applicableBudgetTypes,applicablePrograms are not null
        if(applicableBudgetTypes != NULL && applicableBudgetTypes.size() > 0 && applicablePrograms != NULL && applicablePrograms.size() > 0){
            budgetList =  [select Id, Title,Core_MDF_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Budget_Type_Txt__c, toLabel(Core_MDF_Budget_Type_Txt__c) Budget_type_localized 
                           from PartnerMarketingBudget where Id IN: budgetIdList 
                           and ((Core_MDF_Program__r.Core_MDF_Technical_Program_Name__c IN: applicablePrograms
                                 AND Core_MDF_Budget_Type_Txt__c IN: applicableBudgetTypes) OR 
                                Core_MDF_Program__r.Core_MDF_Technical_Program_Name__c NOT IN: applicablePrograms)
                           Order by Title ASC
                          ];
        }else{
            budgetList =  [select Id, Title, Core_MDF_Budget_Type_Txt__c,toLabel(Core_MDF_Budget_Type_Txt__c) Budget_type_localized from PartnerMarketingBudget where Id in :budgetIdList Order by Title ASC];
        }
        // if budgetList is empty, throw error
        if(budgetList.size() == 0){
            AuraHandledException ex = new AuraHandledException(Label.Core_MDF_No_Available_Budget_Error);
            ex.setMessage(Label.Core_MDF_No_Available_Budget_Error);
            throw ex;
        }
        return budgetList;
    }
    
    /**************************************************************************************************************************  
Method Name:        GetBalanceAllocationAmount
@return  :          Decimal - Available Allocation Amount
@parameters:        fromAcctId - Selected FromAccount, parentAcctId - Parent Co-marketing Account of selected FromAccount
Description:        This method is used to get the available Allocation amount for the given FromAccount that can be transferred.
Added By:           Intel - SM - 08/15/2018
Modified By:        Date:       Changes: 
****************************************************************************************************************************/
    
    @AuraEnabled
    public static Decimal getBalanceAllocationAmount(String accountId, String pmbId){
        List<PartnerFundAllocation> allocationAmount;
        // Get the applicable budget types for allocation check
        Decimal availableAmount = 0.00;
        Map<String,Boolean> isActivityAvailAmountBased = new Map<String,Boolean>();
        try{
            allocationAmount= [select Core_MDF_Available_Allocation_Amount__c,Budget.Core_MDF_Program_Nm__c,Core_MDF_Available_Activity_Alloc_Amt__c, Core_MDF_Budget_Type__c from PartnerFundAllocation 
                               where BudgetId=:pmbId and ChannelPartnerId=:accountId limit 1 ];
            list<String> progBudLst=new List<String>();
            // check if allocation budget type is in applicableBudgetTypes list and Available activity allocation amount is less than available allocation amount,
            // then display Available activity allocation amount, else display available allocation amount
            if(allocationAmount != null && allocationAmount.size() > 0){
                string key=allocationAmount[0].Budget.Core_MDF_Program_Nm__c+':'+allocationAmount[0].Core_MDF_Budget_Type__c;
                if(key!=NULL){
                    progBudLst.add(key);
                }
                if(progBudLst!=NULL){
                    isActivityAvailAmountBased = Core_MDF_PMBServiceHandler.isActAvailAmtValidationReq(progBudLst);
                } 
                
                availableAmount = (isActivityAvailAmountBased.containsKey(key) && isActivityAvailAmountBased.get(key) && allocationAmount[0].Core_MDF_Available_Activity_Alloc_Amt__c <= allocationAmount[0].Core_MDF_Available_Allocation_Amount__c) ? 
                    allocationAmount[0].Core_MDF_Available_Activity_Alloc_Amt__c : allocationAmount[0].Core_MDF_Available_Allocation_Amount__c; 
            }
        }         
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}// JV- Accenture : Add the exception into Core_Log_Entry Object
        return availableAmount;
    }
    
    /**************************************************************************************************************************  
Method Name:        TransferAllocationAmount
@return  :          Decimal - Available Allocation Amount
@parameters:        fromAcctId - Selected FromAccount, parentAcctId - Parent Co-marketing Account of selected FromAccount
Description:        This method is used to get the available Allocation amount for the given FromAccount that can be transferred.
Added By:           Intel - SM - 08/15/2018
Modified By:        Date:        Changes: 
Accenture- VD       05-02-2019   Added check for SPCF Record Type
Accenture- HP       07-02-2019   Modified check for SPCF Record Type
****************************************************************************************************************************/
    
    @AuraEnabled
    public static string transferAllocationAmount(string partnerFrom,string partnerTo, string pbmId, Decimal amount, string typeOfTransfer){ 
        
        Boolean hasMDFBudgetCreationPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_MDF_Budget_Loader_Approver');
        Boolean hasFinanceUserPermission = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Finance_User_Manager') || FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Finance_Usr') || FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Finance_Manager'); 
        Boolean hasAccountMgrPermission = FeatureManagement.checkPermission('Core_MDF_Internal_Account_Manager');
        
        Boolean userHasBudgetTransferAccess=false;
        String transactionStatus;
        //check the user is having Account mgr role, Budget loader role & Finance user role
        if(hasAccountMgrPermission && hasMDFBudgetCreationPermission && hasFinanceUserPermission){
            userHasBudgetTransferAccess = Core_MDF_BudgetTransferUtility.budgetTransferBasedOnIUPGM(partnerFrom,pbmId);
        }else{
            userHasBudgetTransferAccess = true;
        }

        if(userHasBudgetTransferAccess){
            Core_MDF_BudgetTransferWrapper budgetTransferWrap = new Core_MDF_BudgetTransferWrapper(partnerFrom,partnerTo,pbmId,amount,typeOfTransfer);
            List<Core_MDF_BudgetTransferWrapper> budgetTransferWrapLst = new List<Core_MDF_BudgetTransferWrapper>();
            budgetTransferWrapLst.add(budgetTransferWrap);
            Core_MDF_BudgetTransferUtility.skipBudgetUpdate = true;
            transactionStatus = Core_MDF_BudgetTransferUtility.budgetTransfer(budgetTransferWrapLst);
            Core_MDF_BudgetTransferUtility.skipBudgetUpdate = false;
        }else{
            transactionStatus =Label.Core_MDF_NoIUPGMExists;
        }
        
        return transactionStatus;
    }
    public without sharing class BudgetDetailsWithoutShare{
        
        public List<PartnerMarketingBudget> getApplicableBudgetList(Set<String>applicableBudgetTypes,Set<String>applicablePrograms,Set<Id> budgetIdList){
           
            List<PartnerMarketingBudget> budgetList = new List<PartnerMarketingBudget>();
            // checking if applicableBudgetTypes,applicablePrograms are not null
            if(applicableBudgetTypes != NULL && applicableBudgetTypes.size() > 0 && applicablePrograms != NULL && applicablePrograms.size() > 0){
                budgetList =  [select Id, Title,Core_MDF_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Budget_Type_Txt__c, toLabel(Core_MDF_Budget_Type_Txt__c) Budget_type_localized 
                               from PartnerMarketingBudget where Id IN: budgetIdList 
                               and ((Core_MDF_Program__r.Core_MDF_Technical_Program_Name__c IN: applicablePrograms
                                     AND Core_MDF_Budget_Type_Txt__c IN: applicableBudgetTypes) OR 
                                    Core_MDF_Program__r.Core_MDF_Technical_Program_Name__c NOT IN: applicablePrograms)
                               Order by Title ASC
                              ];
                 
            }else{
                
                budgetList =  [select Id, Title, Core_MDF_Budget_Type_Txt__c,toLabel(Core_MDF_Budget_Type_Txt__c) Budget_type_localized from PartnerMarketingBudget where Id in :budgetIdList Order by Title ASC];
                
            }
            // if budgetList is empty, throw error
            
            if(budgetList.size() == 0){
                AuraHandledException ex = new AuraHandledException(Label.Core_MDF_No_Available_Budget_Error);
                ex.setMessage(Label.Core_MDF_No_Available_Budget_Error);
                throw ex;
            }
            return budgetList;
        }
        public Id getPrimaryPartnerWithoutShare (String budgetId){
            Id primaryPartnerid;
            List<PartnerMarketingBudget> budgetList = [SELECT ID, Core_MDF_Budget_Partner__c FROM PartnerMarketingBudget where Id = :budgetId ];
            if(!budgetList.isEmpty()){
                primaryPartnerid =budgetList[0].Core_MDF_Budget_Partner__c;
            }
            return primaryPartnerid;
        }
        public List<Account> getToAccountsWithoutShare(Account fromAccount, Id coMarketingRecordTypeId,Id primaryPartnerId){
            List<Account> toAccounts = [Select Id, Name, Core_MDF_Channel_Program__c From Account where Core_MDF_Channel_Program__c = :fromAccount.Core_MDF_Channel_Program__c 
                                        And RecordTypeId=:coMarketingRecordTypeId And Id <> :fromAccount.Id AND (Id = :primaryPartnerId OR  Core_MDF_CoMarketing_Ultimate_Account__c = :fromAccount.Core_MDF_CoMarketing_Ultimate_Account__c) AND 
                                        Core_MDF_Active_Ind__c = TRUE  Order by Name ASC];
            return toAccounts;
        }
        public  Account getAccountWithoutShare (Id id){
            Account Acc = [select id, Name from Account where id = :id];
            return Acc;
        }
    }
        
    }