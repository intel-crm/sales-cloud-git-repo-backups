/*********************************************************************************************************************
Apex Class Name  : UCD_AccountHierarchyBatch
Author And Date  : Roushan Kumar, 01 Oct 2024
Function         : This class has code for Managing Account Hierarchies
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------
* Roushan Kumar             01/10/2024                Created
*****************************************************************************************************************************/
public without sharing class UCD_AccountHierarchyBatch implements Database.Batchable<sObject>, Database.Stateful {
    Map<Id,Account> accMapForChildPublish = new Map<Id,Account>();
    Map<String,String> allResults = new Map<String,String>();

    public Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator([SELECT Id,Core_Reltio_Integration_Status__c,Name,RecordTypeId,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Parent_Data_Simplified_Account_Nm__c,ParentId,Core_Customer_Aggregation_Type__c,Core_Unified_Global_Customer_Name__c,Core_Unified_Global_Customer_BP_Id__c,Core_Account_Reference_Source_Name__c,Core_Unified_Intermediate_Customer_BP_Id__c,Parent.Core_Customer_Aggregation_Type__c,Parent.Core_Business_Party_Id__c,Parent.Id,Core_Unified_Intermediate_Customer_Name__c,Core_Unified_Intermdt_Customer_2_BP_Id__c,Core_Unified_Intermdt_Customer_2_Name__c,Core_Survivor_Account_Id__c,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,BillingCountry,BillingCountryCode,ShippingCountry,ShippingCountryCode,Core_Data_Country_Nm__c,Core_Parent_Business_Party_Id__c,KCR_Process_Outcome_Temp__c,Unified_Hierarchy_View__c
        FROM Account WHERE Core_Reltio_Integration_Status__c != null AND Core_Reltio_Integration_Status__c != 'COMPLETED']); 
    }

    public void execute(Database.BatchableContext BC, List<Account> accounts) {
        try{

            List<Account> globalAcctList = new List<Account>();
            List<Account> IntrmdtAcctList = new List<Account>();
            List<Account> countryAcctList = new List<Account>();
            List<Account> locationAcctList = new List<Account>();

            for (Account acc : accounts) {
                accMapForChildPublish.put(acc.Id,acc);

                if (acc.Core_Customer_Aggregation_Type__c == 'UNFD_GLBL_CUST') {
                    if(!acc.Core_Reltio_Integration_Status__c.Contains('CHILD_UPDATE')){
                        allResults.put(acc.Id,'COMPLETED');
                        continue;
                    }
                    globalAcctList.add(acc);
                }
                else if (acc.Core_Customer_Aggregation_Type__c == 'UNFD_INTRMD_CUST') {
                    IntrmdtAcctList.add(acc);
                }
                else if (acc.Core_Customer_Aggregation_Type__c == 'UNFD_CTRY_CUST') {
                    countryAcctList.add(acc);
                }
                else if (acc.Core_Customer_Aggregation_Type__c == 'UNFD_LOC_CUST') {
                    locationAcctList.add(acc);
                }
            }

            if (globalAcctList.size() > 0) { 
                allResults.putAll(UCD_AccountHierarchyBatch.processHierarchy(globalAcctList,'GLBL'));
            }

            if (IntrmdtAcctList.size() > 0) {
                allResults.putAll(UCD_AccountHierarchyBatch.processHierarchy(IntrmdtAcctList,'INTR'));
            }

            if (countryAcctList.size() > 0) {
                allResults.putAll(UCD_AccountHierarchyBatch.processHierarchy(countryAcctList,'CTRY'));
            }
            if (locationAcctList.size() > 0) {
                allResults.putAll(UCD_AccountHierarchyBatch.processHierarchy(locationAcctList,'LOC'));
            }
        }catch (Exception ex) {
            UCD_ACM_Logger.error('UCD_AccountHierarchyBatch','execute','Message: ' + ex.getStackTraceString(),NULL);
            UCD_ACM_Logger.setLogDetails();
        }        
    }

    public void finish(Database.BatchableContext BC) {
        try{
            // Finish logic
            List<Account> accList = new List<Account>();
            for(String accId :allResults.keySet()){
                Account acc = new Account();
                acc.Id = accId;
                acc.Core_Reltio_Integration_Status__c = allResults.get(accId);
                accList.add(acc);
            }
            if(accList.size()>0){
                Database.SaveResult[] results = Database.update(accList, false);
            }
            if(!accMapForChildPublish.isEmpty()){
                UCD_ACM_UpdateHierarchyFieldsQueueable updateJob = new UCD_ACM_UpdateHierarchyFieldsQueueable(accMapForChildPublish.keySet());
                ID jobID = System.enqueueJob(updateJob);
            }
        }catch (Exception ex) {
            UCD_ACM_Logger.error('UCD_AccountHierarchyBatch','finish','Message: ' + ex.getStackTraceString(),NULL);
            UCD_ACM_Logger.setLogDetails();
        }
        
    }

    private static Map<String,String> processHierarchy(List<Account> accountList,String aggregationType){
        Map<String,String> resultMap = new Map<String,String>();
        if(aggregationType != 'GLBL'){
            Map<String,String> parentMap = UCD_AccountHierarchyBatch.handleParentUpdate(accountList);
            if(parentMap != null){
                resultMap.putAll(parentMap);
            }
            Map<String,String> HierarchyAttrMap = UCD_AccountHierarchyBatch.handleCurntAcctHierarchyAttr(accountList);
            if(HierarchyAttrMap != null){
                resultMap.putAll(HierarchyAttrMap);
            }
        }
        if(aggregationType != 'LOC'){
            Map<String,String> childMap = UCD_AccountHierarchyBatch.handleChildAcctsUpdate(accountList);
            if(childMap != null){
                resultMap.putAll(childMap);
            }
        }
        // Map<String,String> unifiedHierarchyMap = UCD_AccountHierarchyBatch.handleUnifiedHierarchy(accountList);
        // if(unifiedHierarchyMap != null){
        //     resultMap.putAll(unifiedHierarchyMap);
        // }
        return resultMap;
    }

    private static Map<String,String> handleParentUpdate(List<Account> accountList){
        Set<Account> accSetForParentChange = new Set<Account>();
        Map<String,String> resultMap = new Map<String,String>();
        for (Account acc : accountList) {
            if (acc.Core_Reltio_Integration_Status__c.Contains('PARENT_UPDATE')) {
                
                if(acc.Parent.Core_Business_Party_Id__c == acc.Core_Parent_Business_Party_Id__c && acc.ParentId == acc.Parent.Id){
                    resultMap.put(acc.Id,'COMPLETED');
                }else{
                    accSetForParentChange.add(acc);
                }
                
            }
        }
        if(accSetForParentChange.size()>0){
            Map<String, Account> parentAccByBPId = UCD_ACM_Common.getParentAccountByBpId(accSetForParentChange);
            List<Account> accToUpdate = UCD_ACM_Common.setParentToIntelOrECBAccount(accSetForParentChange,parentAccByBPId);
            if(accToUpdate != null && accToUpdate.size()>0){
                Database.SaveResult[] results = Database.update(accToUpdate, false);
                Map<String,String> parentAccMap = handleAcctStatus(results,null);
                if(parentAccMap != null){
                    resultMap.putAll(parentAccMap);
                }
                
            }
        }
        return resultMap;

    }

    private static Map<String,String> handleCurntAcctHierarchyAttr(List<Account> accountList){
        List<Account> updateAccHierarchyAttr = UCD_ACM_Common.updateAccHierarchyAttributes(accountList);
        if(updateAccHierarchyAttr != null && updateAccHierarchyAttr.size()>0){
            Database.SaveResult[] results = Database.update(updateAccHierarchyAttr, false);
            return handleAcctStatus(results,null);
        }
        return null;
    }

    private static Map<String,String> handleChildAcctsUpdate(List<Account> accountList){
        Set<String> accSetForChildPublish = new Set<String>();
        Map<String, List<Account>> parentAccountByBPID = new Map<String, List<Account>>();
        Map<String,String> resultMap = new Map<String,String>();
        Set<Id> updatedAccsId = new Set<Id>();
        
        for (Account acc : accountList) {
            if (acc.Core_Reltio_Integration_Status__c.Contains('CHILD_UPDATE')) {
                accSetForChildPublish.add(acc.Core_Business_Party_Id__c);
                if (String.isNotEmpty(acc.Core_Business_Party_Id__c)) {
                    updatedAccsId.add(acc.Id);
                    if (parentAccountByBPID.containsKey(acc.Core_Business_Party_Id__c)) {
                        parentAccountByBPID.get(acc.Core_Business_Party_Id__c).add(acc);
                    } else {
                        parentAccountByBPID.put(acc.Core_Business_Party_Id__c, new List<Account>{ acc });
                    }
                }
            }
        }
        if(accSetForChildPublish.size()>0){
            
            Map<String,List<Account>> childAccts = UCD_ACM_Common.getChildAccountColl(accSetForChildPublish,updatedAccsId);
            List<Account> allChildAcctList = new List<Account>();
            for(Account acc : accountList){
                if(childAccts.get(acc.Id) == null){
                    if(childAccts.get(acc.Core_Business_Party_Id__c) != null) allChildAcctList.addAll(childAccts.get(acc.Core_Business_Party_Id__c));
                    resultMap.put(acc.Id,'COMPLETED');
                }else{
                    allChildAcctList.addAll(childAccts.get(acc.Id));
                }
            }
            if(childAccts != null && childAccts.size()>0 && allChildAcctList.size()>0){
                Map<Id,Account> accToUpdate = UCD_ACM_Common.setParentToChildAccount(allChildAcctList,parentAccountByBPID);
                if(accToUpdate != null && accToUpdate.size()>0){
                    Database.SaveResult[] results = Database.update(accToUpdate.values(), false);
                    Map<String,String> updatedChildsMap = handleAcctStatus(results,accToUpdate);
                    if(updatedChildsMap != null){
                        resultMap.putAll(updatedChildsMap);
                    }
                    //return handleAcctStatus(results,accToUpdate);
                }
            }
        }
        for(Account acc : accountList){
            if(resultMap.get(acc.Id) == null){
                resultMap.put(acc.Id,'COMPLETED');
            }
        }
        return resultMap;
    }
    // private static Map<String,String> handleUnifiedHierarchy(List<Account> accountList){
    //     List<Account> accList = UCD_ACM_Common.updateUnifiedHierarchy(accountList);
    //     if(accList != null){
    //         Database.SaveResult[] results = Database.update(accList, false);
    //         return handleAcctStatus(results);
    //     }
    //     return null;
    // }
    private static Map<String,String> handleAcctStatus(Database.SaveResult[] results,Map<Id,Account> childAcctMap){
        Map<String,String> resultMap = new Map<String,String>();
        for (Database.SaveResult result : results) {
            if (result.isSuccess()) {
                if(childAcctMap != null && childAcctMap.get(result.getId()).ParentId != null){
                    resultMap.put(childAcctMap.get(result.getId()).ParentId,'COMPLETED');
                }else{
                    if(childAcctMap != null && childAcctMap.get(result.getId()).ParentId == null && childAcctMap.get(result.getId()).Core_Reltio_Integration_Status__c != null && childAcctMap.get(result.getId()).Core_Reltio_Integration_Status__c == 'REPROCESS'){
                       continue;
                    } else
                    resultMap.put(result.getId(),'COMPLETED');
                }
            } else {
                if(childAcctMap != null && childAcctMap.get(result.getId()).ParentId != null){
                    resultMap.put(childAcctMap.get(result.getId()).ParentId,'FAILED');
                }else{
                    resultMap.put(result.getId(),'FAILED');
                }
                String ErrorMsgs;
                String ErrorFields;
                for(Database.Error err : result.getErrors()) {
                    ErrorMsgs += err.getMessage() + '|';
                    ErrorFields += err.getFields() + '|';

                }
                UCD_ACM_Logger.error('UCD_AccountHierarchyBatch','handleAcctStatus','AccountID: '+result.getId()+' Message: ' + ErrorMsgs + ' For Fields: '+ ErrorFields,NULL);
                UCD_ACM_Logger.setLogDetails();
            }
        }
        return resultMap;
    }

}