/*********************************************************************************************************************
Apex Class Name  : UCD_ACM_AcctDeactivtionReactivtion_Batch
    Author And Date  : Roushan Kumar, 5 May 2024
    Function         : This class has code for Activation and Reactivation Batch
    Modification Log :
     * Developer                 Date                    Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Roushan Kumar             5/5/2024                Created
 * Chethan Kunder            17/10/2024              Created removeCWLXwalk(),updated some conditions and variables
 * Aaryaman Bhardwaj         18/10/2024              Implemented exception handling in execute() and added logging in finish()
 *****************************************************************************************************************************/
public without sharing class UCD_ACM_AcctDeactivtionReactivtion_Batch implements Database.Batchable<sObject> , Database.AllowsCallouts, Database.Stateful{
    Map<Id,Core_ACM_Account_Staging__c> failedRecords = new Map<Id,Core_ACM_Account_Staging__c>();
    List<Core_ACM_Account_Staging__c> successRecords = new List<Core_ACM_Account_Staging__c>();
    Set<Id> failedRecordsToRetry = new Set<Id>();
    private Integer retryCount;
    List<Account> accountToInsertSalesCrmCPE = new List<Account>();
    List<Core_ACM_Account_Staging__c> skipRetryingRecords = new List<Core_ACM_Account_Staging__c>();
    public UCD_ACM_AcctDeactivtionReactivtion_Batch(){
        this.retryCount = 0;
    }
    public UCD_ACM_AcctDeactivtionReactivtion_Batch(Set<Id> failedRecordsId,Integer retryCounter){
        this.failedRecordsToRetry = failedRecordsId;
        this.retryCount = retryCounter + 1;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(failedRecordsToRetry.size()>0){
            return Database.getQueryLocator([SELECT Id,Name,AccountId__c,Account_Action_Refrence__c,Core_Action__c,Core_Status__c,Status_Details__c,Core_Retry_Counter__c FROM Core_ACM_Account_Staging__c WHERE Id IN: failedRecordsToRetry]);
        }else{
            Datetime timeInterval = System.now().addHours(integer.valueOf(System.Label.UCD_ACM_AccountDeactivation_Time_Interval));
            // added extra conditions : Account_Action_Refrence__c != null AND AccountId__c != null
            return Database.getQueryLocator([SELECT Id,Name,AccountId__c,Account_Action_Refrence__c,Core_Action__c,Core_Status__c,Status_Details__c,Core_Retry_Counter__c FROM Core_ACM_Account_Staging__c WHERE Core_Status__c = 'NEW' AND (Core_Action__c = 'DEACTIVATE' OR Core_Action__c= 'REACTIVATE') AND Account_Action_Refrence__c != null AND AccountId__c != null AND LastModifiedDate  <=:timeInterval]);
        }
    }
    public void execute(Database.BatchableContext BC, List<Core_ACM_Account_Staging__c> accountStaging) {
        try{
            Set<Id> deactivatedAccIdSet = new Set<Id>();
            Set<Id> reactivatedAccountsIdSet = new Set<Id>();
            //changed name of map from accToUpdateParentorMdmStatus to mAcctsToUpdate
            Map<Id,Account> mAcctsToUpdate = new Map<Id,Account>();
            Set<String> deactivatedAccBPIid = new Set<String>();
            List<Core_Account_Compliance_Watch_List__c> lstAllAcctCWL = new List<Core_Account_Compliance_Watch_List__c>();
            
            for(Core_ACM_Account_Staging__c accStaging : accountStaging){
                UCD_ACM_AccountDeactivationService acctReltioService = new UCD_ACM_AccountDeactivationService();
                UCD_ACM_AccountDeactivationService.ResponseModelForDeactivation responseFromReltio = acctReltioService.removeAcctXwalk(accStaging.Account_Action_Refrence__c, accStaging.AccountId__c, accStaging.Core_Action__c);
                if(responseFromReltio != null && (responseFromReltio.status == 'inactivated' || responseFromReltio.status == 'activated')){
                    accStaging.Status_Details__c = JSON.serialize(responseFromReltio);
                    if(responseFromReltio.status == 'inactivated'){
                        removeCWLXwalk(accStaging,lstAllAcctCWL,acctReltioService);
                        deactivatedAccIdSet.add(accStaging.AccountId__c);
                        accStaging.Core_Status__c = 'COMPLETED';
                    }
                    if(responseFromReltio.status == 'activated'){
                        reactivatedAccountsIdSet.add(accStaging.AccountId__c);
                        accStaging.Core_Status__c = 'COMPLETED';
                    }
                    successRecords.add(accStaging);
                }else {
                    accStaging.Status_Details__c = responseFromReltio != null ? JSON.serialize(responseFromReltio) : '';
                    accStaging.Core_Retry_Counter__c = retryCount;
                    accStaging.Core_Status__c = 'FAILED';
                    if (responseFromReltio != Null && responseFromReltio.message != Null) {
                        //if the reltio response message contains the following error message then the record will not be added to the failedRecords map for retrying
                        for (String errorMessage : System.Label.UCD_ACM_Reltio_Error_Message.split(',')) {
                            if (responseFromReltio?.message?.contains(errorMessage.trim())) {
                                skipRetryingRecords.add(accStaging);
                                break;
                            }
                        }

                        if (!skipRetryingRecords.isEmpty() && skipRetryingRecords.contains(accStaging)) {
                            continue;
                        }
                    }
                    failedRecords.put(accStaging.Id,accStaging);
                }
            }
            
            if(!deactivatedAccIdSet.isEmpty()){
                if(Schema.sObjectType.Account.fields.ParentId.isAccessible() && Schema.sObjectType.Account.fields.Core_Sales_Groups__c.isAccessible() &&
                Schema.sObjectType.Account.fields.Core_Business_Party_Id__c.isAccessible() && Schema.sObjectType.Account.fields.Core_MDM_Status__c.isAccessible()){
                    Map<Id,Account> accountsToRemoveParentAndCPE = new Map<Id,Account>([SELECT id,ParentId,Core_Sales_Groups__c,Core_Business_Party_Id__c,Core_MDM_Status__c FROM Account WHERE Id IN: deactivatedAccIdSet]);
                    for(Account acc : accountsToRemoveParentAndCPE.Values()){
                        deactivatedAccBPIid.add(acc.Core_Business_Party_Id__c);
                        mAcctsToUpdate.put(acc.Id,UCD_ACM_AccountDeactivation.removeHierarchyAttr(acc));
                    }
                    UCD_ACM_AccountDeactivation.removeUCDAttributes(accountsToRemoveParentAndCPE, lstAllAcctCWL);
                }
            }
            
            if(!reactivatedAccountsIdSet.isEmpty()){
                if(Schema.sObjectType.Account.fields.Name.isAccessible() && Schema.sObjectType.Account.fields.Core_Business_Party_Id__c.isAccessible() &&
                    Schema.sObjectType.Account.fields.Core_Intel_Partner_Alliance_PartnerGroup__c.isAccessible() && Schema.sObjectType.Account.fields.Core_MDF_CoMarketingActive__c.isAccessible() &&
                    Schema.sObjectType.Account.fields.Core_Is_Opportunity_Account__c.isAccessible() && Schema.sObjectType.Account.fields.Core_B2B_Entitlement__c.isAccessible() &&
                Schema.sObjectType.Account.fields.Core_MDM_Status__c.isAccessible() && Schema.sObjectType.Account.fields.Core_Sales_Groups__c.isAccessible()){
                    Map<Id,Account> reactivatedAccountMap = New Map<Id,Account>([Select Id,Name,Core_Business_Party_Id__c,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_MDF_CoMarketingActive__c,Core_Is_Opportunity_Account__c,Core_B2B_Entitlement__c,Core_MDM_Status__c,Core_Sales_Groups__c From Account WHERE Id IN:reactivatedAccountsIdSet]);
                    for(Account acc : reactivatedAccountMap.Values()){
                        acc.Core_MDM_Status__c = 'RQST';
                        mAcctsToUpdate.put(acc.Id,acc);
                        accountToInsertSalesCrmCPE.add(acc);
                    }
                }
            }
            /**
             * MDM Status need to be set to 'INACTV' if the account is sole x-walk with Reltio entity
             * This will not update if the BP Id is associated with another account
             */
            if(deactivatedAccBPIid.size()>0){
                if(Schema.sObjectType.Account.fields.Core_MDM_Status__c.isAccessible() && Schema.sObjectType.Account.fields.Core_Business_Party_Id__c.isAccessible()){
                    List<Account> accountsAssociatedWitDeactivatedAccount = [Select Id,Core_MDM_Status__c,Core_Business_Party_Id__c FROM Account Where Core_Business_Party_Id__c IN : deactivatedAccBPIid];
                    Map<String,List<Account>> accountWithBPIidMap = new Map<String,List<Account>>();
                    for(Account acc : accountsAssociatedWitDeactivatedAccount){
                        if(accountWithBPIidMap.get(acc.Core_Business_Party_Id__c) != null){
                            accountWithBPIidMap.get(acc.Core_Business_Party_Id__c).add(acc);
                        }else{
                            accountWithBPIidMap.put(acc.Core_Business_Party_Id__c,new List<Account>{acc});
                        }
                    }
                    for(String accBPIid : accountWithBPIidMap.keySet()){
                        if(accountWithBPIidMap.get(accBPIid).size() == 1){
                            if(mAcctsToUpdate.get(accountWithBPIidMap.get(accBPIid)[0].Id) != null){
                                mAcctsToUpdate.get(accountWithBPIidMap.get(accBPIid)[0].Id).Core_MDM_Status__c = 'INACTV';
                            }else{
                                Account acct = accountWithBPIidMap.get(accBPIid)[0];
                                acct.Core_MDM_Status__c = 'INACTV';
                                mAcctsToUpdate.put(acct.Id,acct);
                            }
                        }
                    }
                }
            }
            if(!mAcctsToUpdate.isEmpty() ){
                update mAcctsToUpdate.values();
            }
        }
        catch(Exception ex) {
            UCD_ACM_Logger.error('UCD_ACM_AcctDeactivtionReactivtion_Batch','execute',ex.getMessage() +  '==>' + ex.getStackTraceString(),null);
        }
        finally {
            UCD_ACM_Logger.setLogDetails();
        }
    }
    public void finish(Database.BatchableContext BC) {
        if(successRecords.size()>0){
            update successRecords;
        }
        
        if (skipRetryingRecords.size()>0) {
            UPDATE skipRetryingRecords;
        }
        if(accountToInsertSalesCrmCPE.size()>0){
            UCD_ACM_AcctDeactivtionReactivtion_Batch.insertSalesCRMCPE(accountToInsertSalesCrmCPE);
        }
        if(failedRecords.size()>0){
            update failedRecords.values();
            if(retryCount < 3){
                UCD_ACM_AcctDeactivtionReactivtion_Batch ucdDeactivatioReactivation = new UCD_ACM_AcctDeactivtionReactivtion_Batch(failedRecords.keySet(),retryCount);
                Database.executeBatch(ucdDeactivatioReactivation,1);
            }
        }
        UCD_ACM_Logger.information('UCD_ACM_AcctDeactivtionReactivtion_Batch','finish',successRecords +' '+failedRecords+' '+skipRetryingRecords ,null);
        UCD_ACM_Logger.setLogDetails();
    }
    
    public static void createAccountStagingForCPEOfReActivatedAcc(List<Account> accList) {
        List<Core_ACM_Account_Staging__c> accStagingList = new List<Core_ACM_Account_Staging__c>();
        List<String> salegroupLabelValue = String.IsNotEmpty(System.Label.UCD_Salesgroup_Value)? System.Label.UCD_Salesgroup_Value.split(','): new List<String>();
        for(Account acc : accList){
            if(acc.Core_Intel_Partner_Alliance_PartnerGroup__c==true){
                accStagingList.add(createAccStag(acc.Id,'PTNR'));
            }
            if(acc.Core_MDF_CoMarketingActive__c == true){
                accStagingList.add(createAccStag(acc.Id,'CO_MKT'));
            }
            if(acc.Core_Is_Opportunity_Account__c == true){
                accStagingList.add(createAccStag(acc.Id,'SLS_PPLN'));
            }
            if(acc.Core_B2B_Entitlement__c == true){
                accStagingList.add(createAccStag(acc.Id,'ACCS_ENTTL'));
            }
            if(salegroupLabelValue.contains(acc.Core_Sales_Groups__c)){
                accStagingList.add(createAccStag(acc.Id,'SLS_KPI_HOST'));
            }
        }
        if(accStagingList.size()>0){
            if(Schema.sObjectType.Core_ACM_Account_Staging__c.fields.AccountId__c.isCreateable() && Schema.sObjectType.Core_ACM_Account_Staging__c.fields.Core_Action__c.isCreateable() &&
            Schema.sObjectType.Core_ACM_Account_Staging__c.fields.Core_Status__c.isCreateable() && Schema.sObjectType.Core_ACM_Account_Staging__c.fields.Account_Action_Refrence__c.isCreateable()){
                insert accStagingList;
            }
        }
    }
    private static void insertSalesCRMCPE(List<Account> accounts) {
        Map<String,Business_Types__c> businessTypeMap = UCD_ACM_AddOrRemoveCPE.getMapOfBusinessTypes();
        List<Account_Business_Types__c> salesCrmCPEToInsert = new List<Account_Business_Types__c>();
        for(Account acc : accounts){
            Account_Business_Types__c cpe = new Account_Business_Types__c();
            cpe.Business_Types__c = businessTypeMap.get('SLS_CRM').Id;
            cpe.Account__c = acc.Id;
            cpe.Effective_Start_Date__c = System.today();
            salesCrmCPEToInsert.add(cpe);
        }
        if(Schema.sObjectType.Account_Business_Types__c.fields.Business_Types__c.isCreateable() && Schema.sObjectType.Account_Business_Types__c.fields.Account__c.isCreateable() &&
        Schema.sObjectType.Account_Business_Types__c.fields.Effective_Start_Date__c.isCreateable()){
            database.insert(salesCrmCPEToInsert,false);
        }
    }
    private static Core_ACM_Account_Staging__c createAccStag(Id accId,String accActionRef) {
        Core_ACM_Account_Staging__c accStag = new Core_ACM_Account_Staging__c();
        accStag.AccountId__c = accId;
        accStag.Core_Action__c = 'ADD_CPE';
        accStag.Core_Status__c = 'NEW';
        accStag.Account_Action_Refrence__c = accActionRef;
        return accStag;
    }
    
    /**
     * This method is used to set CWL x-walk delete date in Reltio
     * Author: Chethan Kunder
     * Date: 17/10/2024
     */
    private void removeCWLXwalk(Core_ACM_Account_Staging__c acmAcctStg, List<Core_Account_Compliance_Watch_List__c> allAcctCWL, UCD_ACM_AccountDeactivationService acctReltioService) {
        Set<Id> cwlIds = new Set<Id>();
        List<Core_Account_Compliance_Watch_List__c> cwlRecords = [
            SELECT Id 
            FROM Core_Account_Compliance_Watch_List__c 
            WHERE Core_Account_Id__c =:acmAcctStg.AccountId__c
        ];
        if(!cwlRecords.isEmpty()) {
            allAcctCWL.addAll(cwlRecords);
            cwlIds.addAll(new Map<Id, Core_Account_Compliance_Watch_List__c>(cwlRecords).keySet());
            acctReltioService.removeCWLXwalk(acmAcctStg.Account_Action_Refrence__c, acmAcctStg.Core_Action__c, cwlIds);
        }
    }
}