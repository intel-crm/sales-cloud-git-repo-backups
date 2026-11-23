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
        //To store the Id's of accounts from which transfer has to be done
        Set<Id> fromAccountSet = new Set<Id>();
        //To store the Id's of accounts to which transfer has to be done
        Set<Id> toAccountSet = new Set<Id>();
        //To store the Id's of Budgets to used for transfer
        Set<Id> budgetIdSet = new Set<Id>();
        Set<String> transferTypeSet = new Set<String>();
        string transactionStatus = '';
        // Adding the below Savepoint incase any technical error occurs, rollback till this point
        Savepoint sp = Database.setSavepoint();
        Set<Id> fromAccountUltimateIdSet = new Set<Id>();
        Set<Id> toAccountUltimateIdSet = new Set<Id>();
        //Below 2 string are added to store parent account record type
        string fromAccParentRecType = '';
        string toAccParentRecType = '';
        Boolean hasEEFprimaryBudgetLoader = FeatureManagement.checkPermission('Core_MDF_Internal_EEF_Budget_Loader');
        Boolean hasEEFprimaryBudgetApprover = FeatureManagement.checkPermission('Core_MDF_Internal_EEF_Budget_Approver') ;
        Boolean hasEEFactivatingBudgetMgr = FeatureManagement.checkPermission('Core_MDF_Internal_EEF_Budget_Manager');
        LogEntryDetailsWrapper logEntryWrapper = new LogEntryDetailsWrapper();
        try
        {
            //To prepare the Sets
            for(Core_MDF_BudgetTransferWrapper budgetTransferItem : budgetTransferLst)
            {
                fromAccountSet.add(budgetTransferItem.fromAccount);
                toAccountSet.add(budgetTransferItem.toAccount);
                budgetIdSet.add(budgetTransferItem.budgetId);
                transferTypeSet.add(budgetTransferItem.transferType);
            }
            //Map to store the Account and its Program
            Map<Id,String> acctPgmMap = new Map<Id,String>();
            for(Account acct:[Select Id, Core_MDF_Channel_Program__r.Name, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_CoMarketing_Ultimate_Account__c,   
                              Core_MDF_Parent_Fund_Account__r.RecordType.Name From Account 
                              Where (Id IN :fromAccountSet OR Id IN :toAccountSet) AND Core_MDF_Active_Ind__c = TRUE])
            {
                if(fromAccountSet.contains(acct.Id) ){
                    acctPgmMap.put(acct.Id, acct.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c);
                    if(acct.Core_MDF_Channel_Program__r.Name != Label.Core_MDF_EEF_Program_Name){
                        fromAccountUltimateIdSet.add(acct.Core_MDF_CoMarketing_Ultimate_Account__c);
                    }else{
                        fromAccParentRecType=acct.Core_MDF_Parent_Fund_Account__r.RecordType.Name;
                    }
                    
                }
                if(toAccountSet.contains(acct.Id)){
                    if(acct.Core_MDF_Channel_Program__r.Name != Label.Core_MDF_EEF_Program_Name){
                        toAccountUltimateIdSet.add(acct.Core_MDF_CoMarketing_Ultimate_Account__c);
                    }else{
                        toAccParentRecType=acct.Core_MDF_Parent_Fund_Account__r.RecordType.Name;
                    }
                }
            }
            
            Id fromAccIdValue = new List<Id> (fromAccountSet).get(0);
            //Added below condition to throw error when transferring from EEF Primary Budget Loader or Approver and from account is Node Account
            //This is to throw when user is transferring from Acccount Transfer button on Account Record    
            if(transferTypeSet.contains('Manual') && acctPgmMap.containskey(fromAccIdValue) && acctPgmMap.get(fromAccIdValue) == Label.Core_MDF_EEF_Program_Name 
               && ((hasEEFprimaryBudgetLoader || hasEEFprimaryBudgetApprover) && !hasEEFactivatingBudgetMgr) &&
                !String.isBlank(fromAccParentRecType) && !String.isBlank(toAccParentRecType) && 
               !fromAccParentRecType.equalsIgnoreCase(toAccParentRecType) && fromAccParentRecType == Core_MDF_CCP_ConstantClass.CO_MARKETING_ACCOUNT){
                //Reusing the below error label, error message - 'You do not have the appropriate access permissions to do this operation for the selected Account'
                return Label.Core_MDF_RestrictTransfer_from_Nodes_for_PrimaryRoles;
            }
            
            if(transferTypeSet.contains('Manual') && !fromAccountUltimateIdSet.containsAll(toAccountUltimateIdSet)){
                Id fromAccId = new List<Id> (fromAccountSet).get(0);
                Id toAccId = new List<Id> (toAccountSet).get(0);
                logEntryWrapper.origin = 'Core_MDF_BudgetTransferUtility.budgetTransfer';
                logEntryWrapper.message = 'Missmatch in Intel Accounts for From AccountId - ' + fromAccId + ' and To AccountId - ' + toAccId;
            
                if(logEntryWrapper != null){
                    Core_Log_Entry__c logEntryObj = createLogInstance(logEntryWrapper); // calling createLogInstance method with wrapper as parameter
                    
                    List<Core_MDF_Bulk_Transaction__e> logEntryPEList = new List<Core_MDF_Bulk_Transaction__e>();
                    logEntryPEList.add(createBulkTransactionPlatEventInstance(logEntryObj)); //calling createBulkTransactionPlatEventInstance method with logEntryObj parameters
                    //Avoid Deeply Nested IF Statements here if condition commented no need we are checking logEntryWrapper
                        EventBus.publish(logEntryPEList);

                }
                return 'Error';
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
            Map<Id,PartnerMarketingBudget> pmbMap = new Map<Id,PartnerMarketingBudget>([SELECT Id, title, Core_MDF_Budget_Type_Txt__c, Core_MDF_Budget_Status__c,TotalAllocatedAmount 
                                                                                        FROM PartnerMarketingBudget
                                                                                        WHERE Id IN :budgetIdSet]);
            //List to store Budgets for Dummy Update
            List<PartnerMarketingBudget> pmbLstToUpdate = new List<PartnerMarketingBudget>();
            //List to store Budgets for Unlocking from Approval
            List<PartnerMarketingBudget> pmbLstToUnlock = new List<PartnerMarketingBudget>();
            //To perform Budget Transfer
            List<Core_MDF_Budget_Transfer_Log__c> budgetTransferLogs = new List<Core_MDF_Budget_Transfer_Log__c>();
            List<Id> budgetIds = new List<Id>();
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
                budgetIds.add(budgetTransferItem.budgetId);
               
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
               Boolean reverseTransferInd =  budgetTransferItem.reverseTransfer == null ? false : budgetTransferItem.reverseTransfer ;
                Core_MDF_Budget_Transfer_Log__c log = new Core_MDF_Budget_Transfer_Log__c(Core_MDF_Source_Account__c = budgetTransferItem.fromAccount, Core_MDF_Target_Account__c = budgetTransferItem.toAccount,
                                                                                          Core_MDF_Transfer_Type__c = budgetTransferItem.transferType, Core_MDF_Transferred_Amount__c = budgetTransferItem.transferAmount,
                                                                                          Core_MDF_From_Account_Opening_Balance__c=fromAccountOpeningBalance,
                                                                                          Core_MDF_From_Account_Current_Balance__c=fromAccountCurrentBalance,
                                                                                          Core_MDF_To_Account_Opening_Balance__c= toAccountOpeningBalance,
                                                                                          Core_MDF_To_Account_Current_Balance__c = toAccountCurrentBalance,
                                                                                          Core_MDF_Partner_Marketing_Budget__c = pmb.Id,
                                                                                          Core_MDF_Co_Marketing_Activity__c = budgetTransferItem.pfrid,
                                                                                         Core_MDF_Activity_Reverse_Transfer_Ind__c = reverseTransferInd);
                
                budgetTransferLogs.add(log);  
            }

        
            if(!budgetIds.isEmpty()) {
                Map<Id,boolean> budgetApprovalResult = Approval.isLocked(budgetIds);
                if(budgetApprovalResult != null && !budgetApprovalResult.isEmpty()) {
                    for(Id budgetId: budgetApprovalResult.keySet()) {
                        PartnerMarketingBudget pmb = pmbMap.get(budgetId);
                        /*START: When record is in Pending Review status,it wont allow you to 
                        update record.Hence Unlocking the record,Updating it AND Locking the record back : DE21119 */
                        //Avoid Deeply Nested IF Statements
                        Boolean pmbUnblock = (pmb != null && budgetApprovalResult.get(budgetId) && Label.Core_MDF_Budget_Status_Pending_Review.equals(pmb.Core_MDF_Budget_Status__c));
                        Boolean pmbUpdate = (pmb != null && !pmbUnblock);
                        if(pmbUnblock) {
                            pmbLstToUnlock.add(Pmb);
                        }
                        if(pmbUpdate) {
                            pmbLstToUpdate.add(Pmb);
                        }
                    }
                }     
            }
            if(pfaFromMap.values() != NULL && pfaFromMap.values().size() > 0)
            {
                Database.update(pfaFromMap.values());
            }
            if(pmbLstToUnlock != NULL && pmbLstToUnlock.size() > 0)
            {
                Core_MDF_Budget_Utility.unlockBudget(pmbLstToUnlock);   
            }
            if(pmbLstToUpdate != NULL && pmbLstToUpdate.size() > 0)
            {
                Database.update(pmbLstToUpdate);
            }
            if(pfaToMap != NULL && pfaToMap.values() != NULL && pfaToMap.values().size() > 0)
            {
                Database.upsert(pfaToMap.values());
            }
            if(budgetTransferLogs != NULL && budgetTransferLogs.size() > 0)
            {
                Database.insert(budgetTransferLogs);
            }
            transactionStatus = Label.Core_MDF_Success;
        }
        catch(Exception e){
            
            // Rollback the transaction in case of Exception // JV- Accenture : Add the exception into Core_Log_Entry Object
            Database.rollback(sp); Core_MDF_CCP_UtilityClass.logError(e); return transactionStatus = e.getMessage();
            
        }
        return transactionStatus;
    }
/***************************************************************************************************** 
Method Name:        retrieveAccountsByIUPGMAccess
@return  :          List<Account>
@parameters:        List<Account>
Description:        This method will return the Accounts for MDF loader/approver based on IUPGM setup
Added By:           Accenture  - 11/11/2021
Modified By:        Date:       Changes: 
******************************************************************************************************/
    public static List<Account> retrieveAccountsByIUPGMAccess(List<Account> listOfAccounts){
        //list to store the CCF/DCF budget loaders roles
        List<String> mdfRolesList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_MDF_Budget_Roles'); 
        //list to store the CMDF budget loaders roles
        //list to store the IPA budget loaders roles
        List<String> ipaRolesList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_IPA_Budget_Roles');
        //list to store the budget managers roles
        List<String> budMgrRolesList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_BudgetManagerRoles');
        //list to store EEF budget Roles
        List<String> eefBudgetRolesList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_EEF_Budget_Roles');
        //list to store Co-GTM budget Roles
        List<String> coGTMRoleList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Co_GTM_Budget_Roles');
        //list to store the budget loaders and approver roles
        List<String> rolesList = new List<String>();
        rolesList.addAll(mdfRolesList);
        rolesList.addAll(ipaRolesList);
        rolesList.addAll(budMgrRolesList);
        rolesList.addAll(eefBudgetRolesList);
        rolesList.addAll(coGTMRoleList);
        //List to store the permission set name for the current logged in user
        List<String> mdfBudgetPermissionSetAssigned = new List<String>();
        //String to store the unique value for IUPGM record
        Set<String> iupgmUniqueKeySet = new Set<String>();
        //map to store Account id and account 
        Map<Id,Account> mapOfAccount = new Map<Id,Account>();
        //map to store the IUPGM for the unique key(combination account id and channel  program)
        Map<String,Core_MDF_Int_Users_Partner_Geo_Mapping__c> mapOfPgmAccountForIUPGM = new Map<String,Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        try{
            for(PermissionSetAssignment psa : [SELECT Id,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId=:UserInfo.getUserId() and PermissionSet.Name IN: rolesList]){
                            mdfBudgetPermissionSetAssigned.add(psa.PermissionSet.Name);
            }
            if(mdfBudgetPermissionSetAssigned.size()>0 && !mdfBudgetPermissionSetAssigned.isEmpty()){
                //iterating the incoming account list and assiging it to the map
                for(Account accRecord : listOfAccounts){
                    mapOfAccount.put(accRecord.id,accRecord);
                }
                //iterating the IUPGM records based on current user's permission set and user id
                for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmRecord : [Select Id,Core_MDF_All_Accounts_cd__c, Core_MDF_Account_id__c,Core_MDF_Channel_Program_id__c from Core_MDF_Int_Users_Partner_Geo_Mapping__c where Core_MDF_Active_Ind__c=true and Core_MDF_is_User_Active_ind__c=true and Core_MDF_User_id__c=:UserInfo.getUserId() and Core_MDF_Role_nm__c IN: mdfBudgetPermissionSetAssigned]){                                  
                    //preparing the unique key for the IUPGM map
                    if(iupgmRecord.Core_MDF_All_Accounts_cd__c == 'Yes'){
                        iupgmUniqueKeySet.add(String.valueOf(iupgmRecord.Core_MDF_Channel_Program_id__c));
                    }else{
                        iupgmUniqueKeySet.add(String.valueOf(iupgmRecord.Core_MDF_Account_id__c)+String.valueOf(iupgmRecord.Core_MDF_Channel_Program_id__c));
                    }
                }
                //iterating the list of Accounts and removing the Account from the list based on IUPGM Map
                for(Integer index=0; index<listOfAccounts.size();index++){
                    //preparing the unique key of Account
                    String accProgKey = String.valueOf(listOfAccounts.get(index).Core_MDF_CoMarketing_Ultimate_Account__c)+ String.valueOf(listOfAccounts.get(index).Core_MDF_Channel_Program__c);
                    String progKey = String.valueOf(listOfAccounts.get(index).Core_MDF_Channel_Program__c);
                    //Camparing Account unique key with IUPGM unique key and Removing unmatched Account from list
                    if(!iupgmUniqueKeySet.contains(accProgKey) && !iupgmUniqueKeySet.contains(progKey))
                    {
                        mapOfAccount.remove(listOfAccounts[index].Id);
                    }
                }
                
            }
        }Catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        return mapOfAccount.values();
    } 
    
/***************************************************************************************************** 
Method Name:        budgetTransferBasedOnIUPGM
@return  :          Boolean
@parameters:        FromAccount (String)
Description:        This method will return the boolean for budget transfer based on IUPGM of Account mgr and MDF budget loader/approver
Added By:           Accenture  - 05/05/2022
Modified By:        Date:       Changes: 
******************************************************************************************************/
    public static Boolean budgetTransferBasedOnIUPGM(String fromAccount,String pmbId){
        List<String> mdfRolesList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_MDF_Budget_Roles'); 
        List<String> budMgrRolesList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_BudgetManagerRoles');
        List<String> rolesList = new List<String>();
        rolesList.addAll(mdfRolesList);
        rolesList.addAll(budMgrRolesList);

        List<String> accMgrRolesList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Account_Manager_Roles'); 
        
        //List to store the permission set name for the current logged in user
        List<String> mdfBudgetPermissionSetAssigned = new List<String>();
        //String to store the unique value for Account Manager IUPGM record
        String combinationOfAccountMgrIUPGMKey;
        //String to store the unique value for MDF IUPGM record
        String combinationOfBudLoaderIUPGMKey;
        List<String> accMgrPermissionSetAssigned = new List<String>();
        Id ultimateAccountId;
        String budgetType;
        //list to store the MDF/MDF+ budget types from custom metadata
        List<String> mdfBudgetTypes = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_MDFBudgetTypesForPMB');
        Boolean userHasBudgetTransferAccess=false;
        Map<String,Core_MDF_Int_Users_Partner_Geo_Mapping__c> mapOfAccountForIUPGM = new Map<String,Core_MDF_Int_Users_Partner_Geo_Mapping__c>();

        ultimateAccountId = [Select Id,Core_MDF_CoMarketing_Ultimate_Account__c from account where Id =:fromAccount].Core_MDF_CoMarketing_Ultimate_Account__c;
        budgetType = [Select Id,Core_MDF_Budget_Type_Txt__c from PartnerMarketingBudget where Id =:pmbId].Core_MDF_Budget_Type_Txt__c;
        
        if(mdfBudgetTypes.contains(budgetType)){
            
            for(PermissionSetAssignment psa : [SELECT Id,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId=:UserInfo.getUserId() and (PermissionSet.Name IN: accMgrRolesList or PermissionSet.Name IN: rolesList)]){
                if(accMgrRolesList.contains(psa.PermissionSet.Name)){
                    accMgrPermissionSetAssigned.add(psa.PermissionSet.Name);
                }else if(rolesList.contains(psa.PermissionSet.Name)){
                    mdfBudgetPermissionSetAssigned.add(psa.PermissionSet.Name);
                }
                //accMgrPermissionSetAssigned.add(psa.PermissionSet.Name);
            }

            if(accMgrPermissionSetAssigned.size()>0){
                //iterate the IUPGM for the selected account and for account manager roles
                for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmRecord : [Select Id,Core_MDF_Role_nm__c, Core_MDF_Account_id__c,Core_MDF_Channel_Program_id__c from Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                            where Core_MDF_Active_Ind__c=true and Core_MDF_is_User_Active_ind__c=true and Core_MDF_User_id__c=:UserInfo.getUserId()
                                                                            and Core_MDF_Account_id__c=:ultimateAccountId and Core_MDF_Role_nm__c IN: accMgrPermissionSetAssigned]){
                
                combinationOfAccountMgrIUPGMKey = String.valueOf(iupgmRecord.Core_MDF_Account_id__c)+String.valueOf(iupgmRecord.Core_MDF_Channel_Program_id__c);
                mapOfAccountForIUPGM.put(combinationOfAccountMgrIUPGMKey,iupgmRecord);
                }
            }
            if(mapOfAccountForIUPGM.size()>0 && mapOfAccountForIUPGM!=null){
                /*for(PermissionSetAssignment psa : [SELECT Id,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId=:UserInfo.getUserId() and PermissionSet.Name IN: rolesList]){
                    mdfBudgetPermissionSetAssigned.add(psa.PermissionSet.Name);
                }*/
                //iterate the IUPGM for the selected account and for budget loader/approver roles
                for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmRecordMDF : [Select Id,Core_MDF_Role_nm__c,Core_MDF_Account_id__c,Core_MDF_Channel_Program_id__c from Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                                where Core_MDF_Active_Ind__c=true and Core_MDF_is_User_Active_ind__c=true and Core_MDF_User_id__c=:UserInfo.getUserId() and
                                                                                Core_MDF_Account_id__c =:ultimateAccountId and Core_MDF_Role_nm__c IN: mdfBudgetPermissionSetAssigned]){
                    combinationOfBudLoaderIUPGMKey = String.valueOf(iupgmRecordMDF.Core_MDF_Account_id__c)+ String.valueOf(iupgmRecordMDF.Core_MDF_Channel_Program_id__c);
                    
                    //allow the transaction if budget loader role is having the same account access
                    if(mapOfAccountForIUPGM.containskey(combinationOfBudLoaderIUPGMKey)){
                        userHasBudgetTransferAccess = true;
                        break;
                    }
                }
                
            }else{
                //allowing the transaction to do the transfer for the selected account
                userHasBudgetTransferAccess = true;
            }
        }else{
            //allowing the transaction to do the transfer for the selected account
            userHasBudgetTransferAccess = true;
        }
        return userHasBudgetTransferAccess;
    }
/***************************************************************************************************** 
Method Name   :        createLogInstance
@return       :        logEntryObj
@parameters   :        logWrapper
Description   :        creates and returns the log entry object record based on the inputs
******************************************************************************************************/
    
    public static Core_Log_Entry__c createLogInstance(LogEntryDetailsWrapper logWrapper){
        Core_Log_Entry__c logEntryObj = new Core_Log_Entry__c();
        String logDetails = JSON.serialize(logWrapper.message);
        logEntryObj.Core_Details__c = logDetails.length()> 32765? logDetails.subString(0,32765) : logDetails;    
        logEntryObj.Core_Project__c = Label.Core_MDF_Program_Name;
        logEntryObj.Core_When__c = System.now();
        logEntryObj.Core_Origin__c = logWrapper.origin;
        logEntryObj.Core_Severity__c = 'Critical';
        logEntryObj.Core_Scope__c = 'Missmatch in Intel Accounts for both the Accounts.';
    
        return logEntryObj;
    }
    
    public static Core_MDF_Bulk_Transaction__e createBulkTransactionPlatEventInstance(Core_Log_Entry__c logEntryObj){
        Core_MDF_Bulk_Transaction__e bulkTransactionEvent = new Core_MDF_Bulk_Transaction__e();
        bulkTransactionEvent.Core_MDF_JSON_Data__c = JSON.serialize(logEntryObj);
        bulkTransactionEvent.Core_MDF_Object_Name__c = 'Core_Log_Entry__c';
        return bulkTransactionEvent;
    }
    
    //Wrapper to store Log Entry Details
    public class LogEntryDetailsWrapper{
        public String origin;
        public String message;
    }    
}