/****************************************************************************************************************************************
* Class Name  : Core_MDF_BudgetTransferHandler_INT 
* Version     : 1.0 
* Created Date: 8-15-2018
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - SM      8/15/2018          Handler Class for Budget Transfer functionalities.
*****************************************************************************************************************************************/

public with sharing class Core_MDF_BudgetTransferHandler_INT {
    
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
            List<Account> fromAccount = [Select Id, Name, Core_MDF_Channel_Program__c, Core_MDF_CoMarketing_Ultimate_Account__c from Account where Id = :fromAcctId AND Core_MDF_Active_Ind__c = TRUE];
            
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
                budgetList =  [select Id, Title from PartnerMarketingBudget where Id in :budgetIdList];
            }
            else
            {
                AuraHandledException ex = new AuraHandledException(Label.Core_MDF_No_Available_Budget_Error);
                ex.setMessage(Label.Core_MDF_No_Available_Budget_Error);
                throw ex;
            }
        }
        catch(Exception e){ if(e.getMessage() == Label.Core_MDF_No_Available_Budget_Error) {throw e;}
                           else{
                               Core_MDF_CCP_UtilityClass.logError(e);// JV- Accenture : Add the exception into Core_Log_Entry Object}
                           }
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
        string transactionStatus = '';
        // Adding the below Savepoint incase any technical error occurs, rollback till this point
        Savepoint sp = Database.setSavepoint();
        try {
            List<PartnerFundAllocation> pfaFrom;
            List<PartnerFundAllocation> pfaTo;
            string userId=userinfo.getuserid();
            User user=[select id, isactive, IsPortalEnabled from User where id=:userId limit 1];
            if(user.IsActive && user.IsPortalEnabled)
            {
                transactionStatus=Core_MDF_BudgetTransferHandler_EXT.TransferAllocationAmount(partnerFrom,partnerTo,pbmId,amount,typeOfTransfer);return transactionStatus; 
            }
            
            else
            {
                Id recordtype;
                Account fromAccount;
                fromAccount = [select Id, Core_MDF_Channel_Program__r.Name, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c  from Account WHERE Id =:partnerFrom AND Core_MDF_Active_Ind__c = TRUE];
                string program = fromAccount.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c;
                //Avoid using Soql / Sosl queries without filters and limits
                Map<String,String> mapProgramToRecordTypeAPI = new Map<String,String>();
                for(Core_MDF_ClaimActAllocRecTypeMapping__mdt recTypeMetaData:[Select Id,Core_MDF_Channel_Program_Name_txt__c,Core_MDF_Allocation_RecordType_txt__c 
                                                                               from Core_MDF_ClaimActAllocRecTypeMapping__mdt Limit 5000]){
                                                                                   
                                                                                   mapProgramToRecordTypeAPI.put(recTypeMetaData.Core_MDF_Channel_Program_Name_txt__c, recTypeMetaData.Core_MDF_Allocation_RecordType_txt__c);
                                                                                   
                                                                               }               
                
                
                String allocationRecTypeDevName = mapProgramToRecordTypeAPI.get(program); 
                recordtype = Schema.SObjectType.PartnerFundAllocation.getRecordTypeInfosByDeveloperName().get(allocationRecTypeDevName).getRecordTypeId();
                
                
                pfaFrom= [select Amount from PartnerFundAllocation 
                          where BudgetId=:pbmId and ChannelPartnerId=:partnerFrom limit 1 ];
                
                
                
                pfaTo= [select Amount from PartnerFundAllocation 
                        where BudgetId=:pbmId and ChannelPartnerId=:partnerTo limit 1];
                
                
                // added below two variables to calculate the opening and current balance of the From Accounts
                Double fromAccountOpeningBalance,fromAccountCurrentBalance;
                if(pfaFrom != NULL && pfaFrom.size() > 0){
                    fromAccountOpeningBalance = pfaFrom[0].Amount;
                    pfaFrom[0].Amount=pfaFrom[0].Amount-amount;
                    update pfaFrom;
                    fromAccountCurrentBalance = pfaFrom[0].Amount;
                } 
                // added below two variables to calculate the opening and current balance of the To Accounts    
                Double toAccountOpeningBalance,toAccountCurrentBalance;    
                
                PartnerFundAllocation newPfa;
                //dummy update
                
                List<PartnerMarketingBudget> budgetList;
                budgetList=[SELECT id, title,Core_MDF_Budget_Status__c,TotalAllocatedAmount 
                            FROM PartnerMarketingBudget
                            WHERE id=:pbmId LIMIT 1];  
                if(budgetList!=null && !budgetList.IsEmpty() && budgetList.size()>0){   
                    //START: When record is in Pending Review status,it wont allow you to update record.Hence Unlocking the record,Updating it AND Locking the record back : DE21119 
                    if(Approval.isLocked(budgetList[0]) && Label.Core_MDF_Budget_Status_Pending_Review.equals(budgetList[0].Core_MDF_Budget_Status__c)){
                        // Unlock the budget, Update it and Lock it again
                        Core_MDF_Budget_Utility.unlockBudget(budgetList);
                    }else{
                        update budgetList;
                    }
                    //END: When record is in Pending Review status,it wont allow you to update record.Hence Unlocking the record,Updating it AND Locking the record back : DE21119 
                    if(pfaTo != NULL && pfaTo.size() > 0)
                    {
                        toAccountOpeningBalance = pfaTo[0].Amount; 
                        pfaTo[0].Amount=pfaTo[0].Amount+amount;
                        update pfaTo;
                        toAccountCurrentBalance = pfaTo[0].Amount;
                    }
                    else 
                    {
                        toAccountOpeningBalance = 0;
                        newPfa = new PartnerFundAllocation(Title = budgetList[0].title, BudgetId = pbmId, ChannelPartnerId = partnerTo, Amount = amount, RecordTypeId = recordtype);
                        insert newPfa;
                        toAccountCurrentBalance = newPfa.Amount;
                    }
                    
                    Core_MDF_Budget_Transfer_Log__c log = new Core_MDF_Budget_Transfer_Log__c(Core_MDF_Source_Account__c = partnerFrom, Core_MDF_Target_Account__c = partnerTo,
                                                                                              Core_MDF_Transfer_Type__c = typeOfTransfer, Core_MDF_Transferred_Amount__c = amount,
                                                                                              Core_MDF_From_Account_Opening_Balance__c=fromAccountOpeningBalance,
                                                                                              Core_MDF_From_Account_Current_Balance__c=fromAccountCurrentBalance,
                                                                                              Core_MDF_To_Account_Opening_Balance__c= toAccountOpeningBalance,
                                                                                              Core_MDF_To_Account_Current_Balance__c = toAccountCurrentBalance,
                                                                                              Core_MDF_Partner_Marketing_Budget__c = budgetList[0].Id);
                    
                    insert log;  
                    
                    transactionStatus = 'Success'; 
                }
            }
        } 
        catch(Exception e){
            // Rollback the transaction in case of Exception // JV- Accenture : Add the exception into Core_Log_Entry Object
            Database.rollback(sp);Core_MDF_CCP_UtilityClass.logError(e);return transactionStatus = Label.Core_MDF_ApplicationErrorMessage;
            //return transactionStatus = e.getMessage();
            
        }
        return transactionStatus;
    }
    
}