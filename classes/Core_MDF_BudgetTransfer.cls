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
        
        List<string> permissionSets = Label.Core_MDF_Budget_Transfer_Access.split(';');
        List<PermissionSetAssignment> validPermissionSet = new List<PermissionSetAssignment>();
        
        validPermissionSet = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userinfo.getuserid() AND 
                              PermissionSet.Name In :permissionSets];
        return validPermissionSet.size() > 0 ? true : false;  
        
    }
    
    
    /***************************************************************************************************** 
Method Name:        SearchAccountsLookup
@return  :          List<Account>
@parameters:        query - search string entered by user
Description:        This method will be invoked when the user searches for an account to transfer budget from and returns the top 15
accounts that match the search string.
Added By:           Intel - SM - 08/15/2018
Modified By:        Date:       Changes: 
******************************************************************************************************/
    @AuraEnabled
    public static List<Account> searchAccountsLookup(string query){
        List<Account> acc;
        try
        {              
            ID coMarketingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_Marketing').getRecordTypeId();
            string querySearch='%'+query+'%';
            acc = [select Id, Name, Core_MDF_Channel_Program__r.Name from Account where RecordTypeId=:coMarketingRecordTypeId and IsPartner = TRUE and Core_MDF_Active_Ind__c = TRUE and name like :querySearch limit 15];
            
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}// JV- Accenture : Add the exception into Core_Log_Entry Object
        
        return acc;
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
        try
        {
            accountDetail=[select id, Name from Account where id = :id];
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
Modified By:        Date:       Changes: 
******************************************************************************************************/
    
    @AuraEnabled
    public static List<Account> getToAccounts(Id fromAcctId)  {
        List<Account> toAccounts = new List<Account>();
        try
        {
            ID coMarketingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_Marketing').getRecordTypeId();
            List<Account> fromAccount = [Select Id, Name, Core_MDF_Channel_Program__c, Core_MDF_Channel_Program__r.Name, Core_MDF_CoMarketing_Ultimate_Account__c from Account where Id = :fromAcctId AND Core_MDF_Active_Ind__c = TRUE];
            
            if(fromAccount != null && fromAccount.size()>0 && coMarketingRecordTypeId != null)
            {
                toAccounts = [Select Id, Name, Core_MDF_Channel_Program__c From Account where Core_MDF_CoMarketing_Ultimate_Account__c = :fromAccount[0].Core_MDF_CoMarketing_Ultimate_Account__c
                              And Core_MDF_Channel_Program__c = :fromAccount[0].Core_MDF_Channel_Program__c And RecordTypeId=:coMarketingRecordTypeId and Id <> :fromAccount[0].Id AND Core_MDF_Active_Ind__c = TRUE];
                
            }
            
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}// JV- Accenture : Add the exception into Core_Log_Entry Object
        
        return toAccounts;
        
        
    }
    
    
    /**************************************************************************************************************************  
Method Name:        GetBudgetList
@return  :          List<PartnerMarketingBudget>
@parameters:        fromAcctId - Selected FromAccount
Description:        This method is used to get the list of budgets that have an allocation for the selected FromAccount.
Added By:           Intel - SM - 08/15/2018
Modified By:        Date:       Changes: 
****************************************************************************************************************************/
    
    @AuraEnabled
    public static List<PartnerMarketingBudget> getBudgetList(Id fromAcctId)
    {        
        Set<Id> budgetIdList = new Set<Id>();
        List<PartnerMarketingBudget> budgetList;
        List<PartnerFundAllocation> allocations; 
        try{
            allocations = [SELECT ID, BudgetId FROM PartnerFundAllocation where ChannelPartnerId = :fromAcctId];
            
            if(allocations != null && allocations.size()>0)
            {
                for(PartnerFundAllocation pfa:allocations){
                    budgetIdList.add(pfa.BudgetId);
                }
            }
            
            if(budgetIdList.size() > 0){
                
                budgetList =  [select Id, Title, Core_MDF_Budget_Type__c from PartnerMarketingBudget where Id in :budgetIdList];
                
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
        try{
            allocationAmount= [select Core_MDF_Available_Allocation_Amount__c from PartnerFundAllocation 
                               where BudgetId=:pmbId and ChannelPartnerId=:accountId limit 1 ];            
        } 
        
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}// JV- Accenture : Add the exception into Core_Log_Entry Object
        return allocationAmount[0].Core_MDF_Available_Allocation_Amount__c;        
    }
    
    /**************************************************************************************************************************  
Method Name:        TransferAllocationAmount
@return  :          Decimal - Available Allocation Amount
@parameters:        fromAcctId - Selected FromAccount, parentAcctId - Parent Co-marketing Account of selected FromAccount
Description:        This method is used to get the available Allocation amount for the given FromAccount that can be transferred.
Added By:           Intel - SM - 08/15/2018
Modified By:        Date:        Changes: 
Accenture- VD       05-02-2019   Added check for SPCF Record Type
Accenture- HP		07-02-2019   Modified check for SPCF Record Type
****************************************************************************************************************************/
    
    @AuraEnabled
    public static string transferAllocationAmount(string partnerFrom,string partnerTo, string pbmId, Decimal amount, string typeOfTransfer){ 
        system.debug('STart::'+System.Now());
        Core_MDF_BudgetTransferWrapper budgetTransferWrap = new Core_MDF_BudgetTransferWrapper(partnerFrom,partnerTo,pbmId,amount,typeOfTransfer);
        List<Core_MDF_BudgetTransferWrapper> budgetTransferWrapLst = new List<Core_MDF_BudgetTransferWrapper>();
        budgetTransferWrapLst.add(budgetTransferWrap);
        string transactionStatus = Core_MDF_BudgetTransferUtility.budgetTransfer(budgetTransferWrapLst);
        system.debug('ENd::'+System.Now());
        return transactionStatus;
    }
    
}