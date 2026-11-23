/******************************************************************************************************
* Class Name  : Core_MDF_BudgetTransferHandler_EXT
* Modification Log :
* Modified By:         	Date                Description
* Accenture- VD			05-02-2019   		Added check for SPCF Record Type 
* Accenture- HP			07-02-2019   		Modified check for SPCF Record Type 
* -----------------------------------------------------------------------------------------------------
*******************************************************************************************************/
public without sharing class Core_MDF_BudgetTransferHandler_EXT {
    
    @AuraEnabled
    public static String transferAllocationAmount(String partnerFrom,String partnerTo,String pbmId,Decimal amount, string typeOfTransfer)
    {
        String transactionStatus='';
        // Adding the below Savepoint incase any technical error occurs, rollback till this point
        Savepoint sp = Database.setSavepoint();
        try
        {
            Id recordtype;
            Account fromAccount;
            List<PartnerFundAllocation> pfaFrom;
            List<PartnerFundAllocation> pfaTo;
            fromAccount = [SELECT Id, Core_MDF_Channel_Program__r.Name, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c
                           FROM Account
                           WHERE Id =:partnerFrom AND Core_MDF_Active_Ind__c = TRUE];
            String program = fromAccount.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c;
            
            Map<String,String> mapProgramToRecordTypeAPI = new Map<String,String>();
            //Avoid using Soql / Sosl queries without filters and limits
                for(Core_MDF_ClaimActAllocRecTypeMapping__mdt recTypeMetaData:[Select Id,Core_MDF_Channel_Program_Name_txt__c,Core_MDF_Allocation_RecordType_txt__c 
                                                                               from Core_MDF_ClaimActAllocRecTypeMapping__mdt Limit 5000]){
                                                                                   
                                                                                   mapProgramToRecordTypeAPI.put(recTypeMetaData.Core_MDF_Channel_Program_Name_txt__c, recTypeMetaData.Core_MDF_Allocation_RecordType_txt__c);
                                                                                   
                                                                               }               
                
                
                String allocationRecTypeDevName = mapProgramToRecordTypeAPI.get(program);               
                recordtype = Schema.SObjectType.PartnerFundAllocation.getRecordTypeInfosByDeveloperName().get(allocationRecTypeDevName).getRecordTypeId();
			
            pfaFrom= [SELECT Amount
                      FROM PartnerFundAllocation 
                      WHERE BudgetId=:pbmId AND ChannelPartnerId=:partnerFrom
                      LIMIT 1 ];
            
            
            
            pfaTo= [SELECT Amount
                    FROM PartnerFundAllocation
                    WHERE BudgetId=:pbmId AND ChannelPartnerId=:partnerTo LIMIT 1];
            
            // JV-Accenture: added below two variables to calculate the opening AND current balance of the From Accounts
            Double fromAccountOpeningBalance,fromAccountCurrentBalance;
            if(pfaFrom != NULL && pfaFrom.size() > 0){
                fromAccountOpeningBalance = pfaFrom[0].Amount;
                pfaFrom[0].Amount=pfaFrom[0].Amount-amount;
                update pfaFrom;
                fromAccountCurrentBalance = pfaFrom[0].Amount;
            }
            
            // JV-Accenture:  added below two variables to calculate the opening AND current balance of the To Accounts    
            Double toAccountOpeningBalance,toAccountCurrentBalance; 
            List<PartnerMarketingBudget> budgetList;
            PartnerFundAllocation newPfa;
            //dummy update
            budgetList=[SELECT id, title,Core_MDF_Budget_Status__c
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
                                                                                          Core_MDF_From_Account_Opening_Balance__c = fromAccountOpeningBalance,
                                                                                          Core_MDF_From_Account_Current_Balance__c = fromAccountCurrentBalance,
                                                                                          Core_MDF_To_Account_Opening_Balance__c = toAccountOpeningBalance,
                                                                                          Core_MDF_To_Account_Current_Balance__c = toAccountCurrentBalance,
                                                                                          Core_MDF_Partner_Marketing_Budget__c = budgetList[0].Id);
                insert log;
                
                transactionStatus = 'Success';    
            }
        }
        
        catch(Exception e) {
            // Rollback the transaction in case of exception // JV- Accenture : Add the exception into Core_Log_Entry Object
            Database.rollback(sp);Core_MDF_CCP_UtilityClass.logError(e);return transactionStatus = Label.Core_MDF_ApplicationErrorMessage;
        }
        return transactionStatus;
    }    
}