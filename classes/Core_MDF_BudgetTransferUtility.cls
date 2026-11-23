/****************************************************************************************************************************************
* Class Name  : Core_MDF_BudgetTransferUtility 
* Version     : 1.0   
* Created Date: 11-13-2018
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - SM         06/18/2019                    Created Core_MDF_BudgetTransferUtility for Budget Transfer Utility Methods      
*****************************************************************************************************************************************/
public without sharing class Core_MDF_BudgetTransferUtility {
    /***************************************************************************************************** 
Method Name:        budgetTransfer
@return  :          void
@parameters:        List of Core_MDF_BudgetTransferWrapper
Description:        This method is used to perform Budget Transfer in Bulk 
Added By:           Intel - SM
Modified By:        Date:       Changes: 
******************************************************************************************************/

    public static string budgetTransfer(List<Core_MDF_BudgetTransferWrapper> budgetTransferLst)
    {
        System.debug('Inside Budget Transfer');
        //To store the Id's of accounts from which transfer has to be done
        Set<Id> fromAccountSet = new Set<Id>();
        //To store the Id's of accounts to which transfer has to be done
        Set<Id> toAccountSet = new Set<Id>();
        //To store the Id's of Budgets to used for transfer
        Set<Id> budgetIdSet = new Set<Id>();
        string transactionStatus = '';
        // Adding the below Savepoint incase any technical error occurs, rollback till this point
        Savepoint sp = Database.setSavepoint();
        try
        {
            //To prepare the Sets
            for(Core_MDF_BudgetTransferWrapper budgetTransferItem : budgetTransferLst)
            {
                fromAccountSet.add(budgetTransferItem.fromAccount);
                toAccountSet.add(budgetTransferItem.toAccount);
                budgetIdSet.add(budgetTransferItem.budgetId);
            }
            //Map to store the Account and its Program
            Map<Id,String> acctPgmMap = new Map<Id,String>();
            for(Account acct:[Select Id, Core_MDF_Channel_Program__r.Name, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c  
                              From Account 
                              Where Id IN :fromAccountSet AND Core_MDF_Active_Ind__c = TRUE])
            {
                acctPgmMap.put(acct.Id, acct.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c);
            }  
            //Map to store Allocation Record Types
            Map<String,String> mapProgramToRecordTypeAPI = new Map<String,String>();
            for(Core_MDF_ClaimActAllocRecTypeMapping__mdt recTypeMetaData:[Select Id,Core_MDF_Channel_Program_Name_txt__c,Core_MDF_Allocation_RecordType_txt__c 
                                                                           from Core_MDF_ClaimActAllocRecTypeMapping__mdt where Core_MDF_Channel_Program_Name_txt__c IN :acctPgmMap.values()])
            {
                mapProgramToRecordTypeAPI.put(recTypeMetaData.Core_MDF_Channel_Program_Name_txt__c, recTypeMetaData.Core_MDF_Allocation_RecordType_txt__c);
            } 
            //Map to store From Accounts and its allocations
            Map<String,PartnerFundAllocation> pfaFromMap = new Map<String,PartnerFundAllocation>();
            //Map to store To Accounts and its allocations if any
            Map<String,PartnerFundAllocation> pfaToMap = new Map<String,PartnerFundAllocation>();
            for(PartnerFundAllocation pfaFrom : [Select Id, ChannelPartnerId, BudgetId, Amount From PartnerFundAllocation 
                                                 Where BudgetId IN :budgetIdSet and ChannelPartnerId IN :fromAccountSet])
            {
                pfaFromMap.put(pfaFrom.ChannelPartnerId + Label.Core_MDF_Underscore + pfaFrom.BudgetId, pfaFrom);
            }
            for(PartnerFundAllocation pfaTo : [Select Id, ChannelPartnerId, BudgetId, Amount From PartnerFundAllocation 
                                               Where BudgetId IN :budgetIdSet and ChannelPartnerId IN :toAccountSet])
            {
                pfaToMap.put(pfaTo.ChannelPartnerId + Label.Core_MDF_Underscore + pfaTo.BudgetId, pfaTo);
            }
            //Map to store Budgets
            Map<Id,PartnerMarketingBudget> pmbMap = new Map<Id,PartnerMarketingBudget>([SELECT Id, title,Core_MDF_Budget_Status__c,TotalAllocatedAmount 
                                                                                        FROM PartnerMarketingBudget
                                                                                        WHERE Id IN :budgetIdSet]);
            //List to store Budgets for Dummy Update
            List<PartnerMarketingBudget> pmbLstToUpdate = new List<PartnerMarketingBudget>();
            //List to store Budgets for Unlocking from Approval
            List<PartnerMarketingBudget> pmbLstToUnlock = new List<PartnerMarketingBudget>();
            //To perform Budget Transfer
            List<Core_MDF_Budget_Transfer_Log__c> budgetTransferLogs = new List<Core_MDF_Budget_Transfer_Log__c>();
            for(Core_MDF_BudgetTransferWrapper budgetTransferItem : budgetTransferLst)
            {
                
                String allocationRecTypeDevName = mapProgramToRecordTypeAPI.get(acctPgmMap.get(budgetTransferItem.fromAccount));
                Id recordtype = Schema.SObjectType.PartnerFundAllocation.getRecordTypeInfosByDeveloperName().get(allocationRecTypeDevName).getRecordTypeId();
                
                Double fromAccountOpeningBalance,fromAccountCurrentBalance;
                PartnerFundAllocation pfaFrom = pfaFromMap.get(budgetTransferItem.fromAccount+Label.Core_MDF_Underscore+budgetTransferItem.budgetId);
                if(pfaFrom != NULL){
                    fromAccountOpeningBalance = pfaFrom.Amount;
                    pfaFrom.Amount=pfaFrom.Amount-budgetTransferItem.transferAmount;
                    fromAccountCurrentBalance = pfaFrom.Amount;
                } 
                // added below two variables to calculate the opening and current balance of the To Accounts    
                Double toAccountOpeningBalance,toAccountCurrentBalance;    
                PartnerMarketingBudget pmb = pmbMap.get(budgetTransferItem.budgetId);
                if(pmb!=null){   
                    //START: When record is in Pending Review status,it wont allow you to update record.Hence Unlocking the record,Updating it AND Locking the record back : DE21119 
                    if(Approval.isLocked(pmb) && Label.Core_MDF_Budget_Status_Pending_Review.equals(pmb.Core_MDF_Budget_Status__c)){
                        // Unlock the budget, Update it and Lock it again
                        if(!pmbLstToUnlock.contains(pmb)){pmbLstToUnlock.add(pmb);}
                    }else{
                        if(!pmbLstToUpdate.contains(pmb)){pmbLstToUpdate.add(pmb);}
                    }
                }
                //END: When record is in Pending Review status,it wont allow you to update record.Hence Unlocking the record,Updating it AND Locking the record back : DE21119 
                PartnerFundAllocation newPfa;
                PartnerFundAllocation pfaTo = pfaToMap.get(budgetTransferItem.toAccount+Label.Core_MDF_Underscore+budgetTransferItem.budgetId);
                if(pfaTo != NULL)
                {
                    toAccountOpeningBalance = pfaTo.Amount; 
                    pfaTo.Amount=pfaTo.Amount + budgetTransferItem.transferAmount;
                    toAccountCurrentBalance = pfaTo.Amount;
                }
                else 
                {
                    toAccountOpeningBalance = 0;
                    newPfa = new PartnerFundAllocation(Title = pmb.title, BudgetId = pmb.Id, ChannelPartnerId = budgetTransferItem.toAccount, Amount = budgetTransferItem.transferAmount, RecordTypeId = recordtype);
                    toAccountCurrentBalance = newPfa.Amount;
                    pfaToMap.put(budgetTransferItem.toAccount+Label.Core_MDF_Underscore+budgetTransferItem.budgetId, newPfa);
                }
                
                Core_MDF_Budget_Transfer_Log__c log = new Core_MDF_Budget_Transfer_Log__c(Core_MDF_Source_Account__c = budgetTransferItem.fromAccount, Core_MDF_Target_Account__c = budgetTransferItem.toAccount,
                                                                                          Core_MDF_Transfer_Type__c = budgetTransferItem.transferType, Core_MDF_Transferred_Amount__c = budgetTransferItem.transferAmount,
                                                                                          Core_MDF_From_Account_Opening_Balance__c=fromAccountOpeningBalance,
                                                                                          Core_MDF_From_Account_Current_Balance__c=fromAccountCurrentBalance,
                                                                                          Core_MDF_To_Account_Opening_Balance__c= toAccountOpeningBalance,
                                                                                          Core_MDF_To_Account_Current_Balance__c = toAccountCurrentBalance,
                                                                                          Core_MDF_Partner_Marketing_Budget__c = pmb.Id);
                
                budgetTransferLogs.add(log);  
            }
            System.debug('budgetTransferLogs:'+budgetTransferLogs);
            System.debug('pfaToMap.values().size():'+pfaToMap.values().size());
            if(pfaFromMap.values() != NULL && pfaFromMap.values().size() > 0)
            {
                Database.update(pfaFromMap.values());
            }
            if(pmbLstToUnlock != NULL && pmbLstToUnlock.size() > 0)
            {
                Core_MDF_Budget_Utility.unlockBudget(pmbLstToUnlock);   
            }
            System.debug('pmbLstToUpdate.size():'+pmbLstToUpdate.size());
            if(pmbLstToUpdate != NULL && pmbLstToUpdate.size() > 0)
            {
                Database.update(pmbLstToUpdate);
            }
            System.debug('pfaToMap.values().size():'+pfaToMap.values().size());
            if(pfaToMap != NULL && pfaToMap.values() != NULL && pfaToMap.values().size() > 0)
            {
                Database.upsert(pfaToMap.values());
            }
            System.debug('budgetTransferLogs.size():'+budgetTransferLogs.size());
            if(budgetTransferLogs != NULL && budgetTransferLogs.size() > 0)
            {
                Database.insert(budgetTransferLogs);
            }
            transactionStatus = Label.Core_MDF_Success;
        }
        catch(Exception e){
            
            // Rollback the transaction in case of Exception // JV- Accenture : Add the exception into Core_Log_Entry Object
            Database.rollback(sp);Core_MDF_CCP_UtilityClass.logError(e);return transactionStatus = e.getMessage();
            
        }
        return transactionStatus;
    }    
}