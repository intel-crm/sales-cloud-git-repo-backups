public with sharing class Core_MDF_IUPGM_ApprovalRequestData {
        /* 
     * Pre-fetch TargetObjectIds from ProcessInstance where Status = 'Pending'
     * using IN-filtered constraints to make it SELECTIVE & FAST.
     */
    // private static Set<Id> getPendingApprovalIds(String objName) {
    //     Set<Id> setpendingIds = new Set<Id>();
    //     Long step1Start = System.currentTimeMillis();
    //     for (ProcessInstance pi :[SELECT TargetObjectId FROM ProcessInstance WHERE Status = 'Pending' AND TargetObject.Type =: objName]){
    //         setpendingIds.add(pi.TargetObjectId);
    //     }
    //     Long step1End = System.currentTimeMillis();
    //     System.debug('Step 1 (ProcessInstance) took: ' + (step1End - step1Start) + 'ms');
    //     return setpendingIds;
    // }
    // Public static List<PartnerFundRequest> getPfrRecordData(Core_MDF_IUPGM_ApprovalRequest.ParamWrapper paramWrap){
        
    //     Set<string> programNameSet = paramWrap.programNameSet;
    //     Set<string> approvalStageSet = paramWrap.approvalStageSet;
    //     Set<Id> inProgressTrackingRecordIds = paramWrap.inProgressTrackingRecordIds;
    //     Long stepStartmain = System.currentTimeMillis();
    //     String objQuery = 'SELECT ' +  string.escapeSingleQuotes(paramWrap.fieldApiNames) +
    //         ' FROM PartnerFundRequest'+
    //         ' WHERE '+ 
    //         ' Core_MDF_Program__c IN: programNameSet AND Core_MDF_Fund_Request_Status__c In (\'Pending Review\',\'In-Progress Pending Review\')' +
    //         ' AND Core_MDF_Approval_Stage__c IN: approvalStageSet' +
    //         ' AND ID In (SELECT TargetObjectId FROM ProcessInstance WHERE Status = \'Pending\')'+
    //         ' AND ID NOT IN: inProgressTrackingRecordIds' +
    //         ' ORDER BY LastModifiedDate DESC';
    //         List<PartnerFundRequest> results = Database.Query(objQuery);
    //         Long stepEndmain = System.currentTimeMillis();
    //         System.debug('Step 2 (Main query) took: ' + (stepEndmain - stepStartmain) + 'ms');
    //         return results;
    // }

    // public static List<PartnerFundRequest> getPfrRecordData(Core_MDF_IUPGM_ApprovalRequest.ParamWrapper paramWrap) {
    //     Set<string> programNameSet = paramWrap.programNameSet;
    //     Set<string> approvalStageSet = paramWrap.approvalStageSet;
    //     Set<Id> inProgressTrackingRecordIds = paramWrap.inProgressTrackingRecordIds;
    //     // PRE-FETCH Pending approval IDs (faster than a semi-join)
    //       String objName = 'PartnerFundRequest';
    //     Set<Id> pendingIds = getPendingApprovalIds(objName);
    //     system.debug('pendingIds@@@'+pendingIds);
    //     // No need to query if empty
    //     if (pendingIds.isEmpty()) return new List<PartnerFundRequest>();
    //     Long step2Start = System.currentTimeMillis();
    //     String objQuery =
    //         'SELECT ' + string.escapeSingleQuotes(paramWrap.fieldApiNames) +
    //         ' FROM PartnerFundRequest ' +
    //         ' WHERE Core_MDF_Program__c IN :programNameSet ' +
    //         ' AND Core_MDF_Fund_Request_Status__c IN (\'Pending Review\', \'In-Progress Pending Review\') ' +
    //         ' AND Core_MDF_Approval_Stage__c IN :approvalStageSet ' +
    //         ' AND Id IN :pendingIds ' +
    //         ' AND Id NOT IN :inProgressTrackingRecordIds ' +
    //         ' ORDER BY LastModifiedDate DESC';
    //     List<PartnerFundRequest> results = Database.Query(objQuery);
    //     Long step2End = System.currentTimeMillis();
    //     System.debug('Step 2 (Main query) took: ' + (step2End - step2Start) + 'ms');
    //     return results;
    // }
    private static Set<Id> getPendingProcessInstanceIds() {
        Set<Id> pendingIds = new Set<Id>();
        Long step1Start = System.currentTimeMillis();
        for(ProcessInstance pi : [SELECT TargetObjectId FROM ProcessInstance WHERE Status = 'Pending' AND TargetObject.Type = 'PartnerFundRequest']) {
            pendingIds.add(pi.TargetObjectId);
        }
        Long step1End = System.currentTimeMillis();
        System.debug('Step 1 (ProcessInstance) took: ' + (step1End - step1Start) + 'ms');
        return pendingIds;
    }
    public static List<PartnerFundRequest> getPfrRecordData(Core_MDF_IUPGM_ApprovalRequest.ParamWrapper paramWrap) {

        Set<string> programNameSet = paramWrap.programNameSet;
        Set<string> approvalStageSet = paramWrap.approvalStageSet;
        Set<Id> inProgressTrackingRecordIds = paramWrap.inProgressTrackingRecordIds;
    
        // Precompute and cache expensive operations
        Set<Id> pendingProcessInstanceIds = getPendingProcessInstanceIds();
        
        // Build selective WHERE clause
        List<String> whereConditions = new List<String>();
        whereConditions.add('Core_MDF_Program__c IN: programNameSet');
        whereConditions.add('Core_MDF_Fund_Request_Status__c IN (\'Pending Review\',\'In-Progress Pending Review\')');
        whereConditions.add('Core_MDF_Approval_Stage__c IN: approvalStageSet');
        whereConditions.add('ID IN: pendingProcessInstanceIds');
        whereConditions.add('ID NOT IN: inProgressTrackingRecordIds');
        Long step2Start = System.currentTimeMillis();
        String objQuery = 'SELECT ' + String.escapeSingleQuotes(paramWrap.fieldApiNames) +
            ' FROM PartnerFundRequest WHERE ' + 
            String.join(whereConditions, ' AND ') +
            ' ORDER BY LastModifiedDate DESC';
            system.debug('@@@objQuery'+objQuery);
        List<PartnerFundRequest> results = Database.Query(objQuery);
        Long step2End = System.currentTimeMillis();
        System.debug('Step 2 (Main query) took: ' + (step2End - step2Start) + 'ms');
        return results;
    }
    
    Public static List<Campaign> getCampaignRecordData(Core_MDF_IUPGM_ApprovalRequest.ParamWrapper paramWrap){
        Set<string> programNameSet = paramWrap.programNameSet;
        Set<string> approvalStageSet = paramWrap.approvalStageSet;
        Set<Id> inProgressTrackingRecordIds = paramWrap.inProgressTrackingRecordIds;
        // PRE-FETCH Pending approval IDs (faster than a semi-join)
        //Set<Id> pendingIds = getPendingApprovalIds();
        Long stepStartcamp = System.currentTimeMillis();
        String objQuery = 'SELECT '+  string.escapeSingleQuotes(paramWrap.fieldApiNames) +
            ',Core_MDF_Sub_Region_cd__c,Core_MDF_Ultimate_Account_txt__c' +
            ',Core_MDF_Channel_Program__r.Name' +
            ' FROM Campaign' +
            ' WHERE (Core_MDF_Program__c IN: programNameSet or Core_MDF_Channel_Program__r.Name IN: programNameSet) AND Status In (\'Pending Review\',\'In-Progress Pending Review\')' +
            ' AND ID In (SELECT TargetObjectId FROM ProcessInstance WHERE Status = \'Pending\')'+
            ' AND ID NOT IN: inProgressTrackingRecordIds' +
            ' AND Core_MDF_Approval_Stage_nm__c IN: approvalStageSet' +
            ' ORDER BY LastModifiedDate DESC ';
            List<Campaign> results = Database.Query(objQuery);
            Long stepEndcamp = System.currentTimeMillis();
            System.debug('Step 2 (Main query) took camp: ' + (stepEndcamp - stepStartcamp) + 'ms');
            return results;
    }
    
      Public static List<PartnerMarketingBudget> getBudgetRecordData(Core_MDF_IUPGM_ApprovalRequest.ParamWrapper paramWrap){
        Set<string> programNameSet = paramWrap.programNameSet;
        Set<Id> inProgressTrackingRecordIds = paramWrap.inProgressTrackingRecordIds;
        // PRE-FETCH Pending approval IDs (faster than a semi-join)
        //Set<Id> pendingIds = getPendingApprovalIds();
        String objQuery = 'SELECT '+  string.escapeSingleQuotes(paramWrap.fieldApiNames) + ',Core_MDF_Budget_Partner__r.Core_Geo__c' +
            ' FROM PartnerMarketingBudget' +
            ' WHERE Core_MDF_Program_Nm__c IN: programNameSet AND Core_MDF_Budget_Status__c = \'Pending Review\'' +
            ' AND ID In (SELECT TargetObjectId FROM ProcessInstance WHERE Status = \'Pending\')'+
            ' AND ID NOT IN: inProgressTrackingRecordIds' +
            ' ORDER BY LastModifiedDate DESC ';
        return Database.Query(objQuery);
    }
    Public static List<PartnerFundClaim> getClaimRecordData(Core_MDF_IUPGM_ApprovalRequest.ParamWrapper paramWrap){
        Set<string> programNameSet = paramWrap.programNameSet;
        Set<Id> inProgressTrackingRecordIds = paramWrap.inProgressTrackingRecordIds;
        // PRE-FETCH Pending approval IDs (faster than a semi-join)
        //Set<Id> pendingIds = getPendingApprovalIds();
        String objQuery = 'SELECT '+  string.escapeSingleQuotes(paramWrap.fieldApiNames) + 
            ' FROM PartnerFundClaim' +
            ' WHERE Core_MDF_Program__c IN: programNameSet AND Core_MDF_Status__c = \'Pending Review\'' +
            ' AND ID In (SELECT TargetObjectId FROM ProcessInstance WHERE Status = \'Pending\')'+
            ' AND ID NOT IN: inProgressTrackingRecordIds' +
            ' ORDER BY LastModifiedDate DESC ';
        return Database.Query(objQuery);
    }
  
    
    Public static List<SObject> getPIRecordData(Core_MDF_IUPGM_ApprovalRequest.ParamWrapper paramWrap){
        Set<string> objRecIds = paramWrap.objRecIds;
        String objQuery = 'SELECT '+  string.escapeSingleQuotes(paramWrap.fieldApiNames) + ' FROM '+ String.escapeSingleQuotes(paramWrap.objName) + ' WHERE '+ ' Id IN: objRecIds ORDER BY LastModifiedDate DESC';
        return Database.Query(objQuery);
    }

}