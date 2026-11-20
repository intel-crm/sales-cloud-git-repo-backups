public with sharing class Core_MDF_IUPGM_ApprovalRequestData {
    
    Public static List<PartnerFundRequest> getPfrRecordData(Core_MDF_IUPGM_ApprovalRequest.ParamWrapper paramWrap){
        
        Set<string> programNameSet = paramWrap.programNameSet;
        Set<string> approvalStageSet = paramWrap.approvalStageSet;
        Set<Id> inProgressTrackingRecordIds = paramWrap.inProgressTrackingRecordIds;
        
        String objQuery = 'SELECT ' +  string.escapeSingleQuotes(paramWrap.fieldApiNames) +
            ' FROM PartnerFundRequest'+
            ' WHERE '+ 
            ' Core_MDF_Program__c IN: programNameSet AND Core_MDF_Fund_Request_Status__c In (\'Pending Review\',\'In-Progress Pending Review\')' +
            ' AND Core_MDF_Approval_Stage__c IN: approvalStageSet' +
            ' AND ID In (SELECT TargetObjectId FROM ProcessInstance WHERE Status = \'Pending\')'+
            ' AND ID NOT IN: inProgressTrackingRecordIds' +
            ' ORDER BY LastModifiedDate DESC';
            
        return Database.Query(objQuery);
    }
    
    Public static List<Campaign> getCampaignRecordData(Core_MDF_IUPGM_ApprovalRequest.ParamWrapper paramWrap){
        Set<string> programNameSet = paramWrap.programNameSet;
        Set<string> approvalStageSet = paramWrap.approvalStageSet;
        Set<Id> inProgressTrackingRecordIds = paramWrap.inProgressTrackingRecordIds;
        String objQuery = 'SELECT '+  string.escapeSingleQuotes(paramWrap.fieldApiNames) +
            ',Core_MDF_Sub_Region_cd__c,Core_MDF_Ultimate_Account_txt__c' +
            ',Core_MDF_Channel_Program__r.Name' +
            ' FROM Campaign' +
            ' WHERE (Core_MDF_Program__c IN: programNameSet or Core_MDF_Channel_Program__r.Name IN: programNameSet) AND Status In (\'Pending Review\',\'In-Progress Pending Review\')' +
            ' AND Id In (SELECT TargetObjectId FROM ProcessInstance WHERE Status = \'Pending\')'+
            ' AND ID NOT IN: inProgressTrackingRecordIds' +
            ' AND Core_MDF_Approval_Stage_nm__c IN: approvalStageSet' +
            ' ORDER BY LastModifiedDate DESC ';
        return Database.Query(objQuery);
    }
    
      Public static List<PartnerMarketingBudget> getBudgetRecordData(Core_MDF_IUPGM_ApprovalRequest.ParamWrapper paramWrap){
        Set<string> programNameSet = paramWrap.programNameSet;
        Set<Id> inProgressTrackingRecordIds = paramWrap.inProgressTrackingRecordIds;
        String objQuery = 'SELECT '+  string.escapeSingleQuotes(paramWrap.fieldApiNames) + ',Core_MDF_Budget_Partner__r.Core_Geo__c' +
            ' FROM PartnerMarketingBudget' +
            ' WHERE Core_MDF_Program_Nm__c IN: programNameSet AND Core_MDF_Budget_Status__c = \'Pending Review\'' +
            ' AND Id In (SELECT TargetObjectId FROM ProcessInstance WHERE Status = \'Pending\')'+
            ' AND ID NOT IN: inProgressTrackingRecordIds' +
            ' ORDER BY LastModifiedDate DESC ';
        return Database.Query(objQuery);
    }
    Public static List<PartnerFundClaim> getClaimRecordData(Core_MDF_IUPGM_ApprovalRequest.ParamWrapper paramWrap){
        Set<string> programNameSet = paramWrap.programNameSet;
        Set<Id> inProgressTrackingRecordIds = paramWrap.inProgressTrackingRecordIds;
        String objQuery = 'SELECT '+  string.escapeSingleQuotes(paramWrap.fieldApiNames) + 
            ' FROM PartnerFundClaim' +
            ' WHERE Core_MDF_Program__c IN: programNameSet AND Core_MDF_Status__c = \'Pending Review\'' +
            ' AND Id In (SELECT TargetObjectId FROM ProcessInstance WHERE Status = \'Pending\')'+
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