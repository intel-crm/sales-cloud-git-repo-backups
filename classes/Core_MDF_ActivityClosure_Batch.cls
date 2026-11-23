/****************************************************************************************************************************************
* Accenture- Weezer:  Batch class to update Activity status to closed, and to release fund back to allocation.
* Created By       :  Shiva
* Modified By      :  Ramapriya     25/07/2025
*****************************************************************************************************************************************/
global class Core_MDF_ActivityClosure_Batch implements Database.Batchable<sObject>,Database.Stateful{
    
    Public List<string> claimStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimStatus_ActivityAutoClose').split(';');
    Public string INPROGRESS = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Inprogress');
    Public string PLANNED = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Planned_Status');
    Public string INPROGRESS_PENDING_REVIEW = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_InProgress_Pending_Review');
    Public string INPROGRESS_PENDING_APPROVAL = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_InProgress_Pending_Approval');
    Public string INPROGRESS_REVISION_REQUIRED = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_InProgress_Revision_Required');
    Public string CLOSED = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Status_Closed');
    
    Public Integer LONG_TEXT_AREA_LIMIT = Core_MDF_CCP_ConstantClass.LONG_TEXT_AREA_LIMIT;
    Public string AUTO = Core_MDF_CCP_ConstantClass.PFR_AUTO;
    Public string AUTO_MISSED_APPROVAL = Core_MDF_CCP_ConstantClass.PFR_AUTO_MISSED_APPROVAL;
    Public string AUTO_MISSED_IN_PROGRESS_APPROVAL = Core_MDF_CCP_ConstantClass.PFR_AUTO_MISSED_IN_PROGRESS_APPROVAL;
   
    global Database.QueryLocator start(Database.BatchableContext bc){
        Date todaysDate = system.today();
        
        String query = 'SELECT Id,Title,Core_MDF_Budget_Type_nm__c,Core_MDF_Fund_Request_Status__c,Core_MDF_Program__c,Core_MDF_Activity_Closure_Type__c,'+
            'Amount,Core_MDF_Proposal_Based_Ind__c,(select Id,Amount from PartnerFundClaims where Core_MDF_Status__c IN : claimStatus AND Core_MDF_Type_Txt__c = \'Claim\') '+
            'FROM PartnerFundRequest '+
            'WHERE Core_MDF_ToBeClosedDate__c <: todaysDate ' +
            'AND Core_MDF_Fund_Request_Status__c != \'Closed\' AND Core_MDF_Fund_Request_Status__c != \'Cancelled\' AND Core_MDF_Fund_Request_Status__c != \'Declined\'';
		
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<PartnerFundRequest> pfrList){
        Decimal totalClaimAmt = 0.0;
        set<Id> pfrIds = new set<Id>();
        map<Id,PartnerFundRequest> pfrToUpdateMap = new map<Id,PartnerFundRequest>();
        Map<Id,List<string>> pfrIdToErrorsMap = new Map<Id,List<string>>();
        List<String> activityBudgetType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EligibleBT_ActivityAutoClose').split(';');
        List<string> pfrProgramSpecific = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Close_Open_Activity_Program').split(';');
        
        try{
            if(pfrList != null && !pfrList.isEmpty()){
                for(PartnerFundRequest pfr : pfrList){
                    PartnerFundRequest pfrToBeUpdated = new PartnerFundRequest();
                    pfrToBeUpdated.Id = pfr.Id;
                    if(activityBudgetType.contains(pfr.Core_MDF_Budget_Type_nm__c) || pfrProgramSpecific.contains(pfr.Core_MDF_Program__c)){
                        Decimal amountSum = 0;
                        if(pfr.PartnerFundClaims != null & !pfr.PartnerFundClaims.isEmpty()){
                            for(PartnerFundClaim pfc : pfr.PartnerFundClaims){amountSum += pfc.Amount;//(MDF,MDF+,Retail MDF,IPA AccountBased)
                                                                             }
                        }
                        pfrToBeUpdated.Amount = amountSum;
                    } 
                    if(pfr.Core_MDF_Fund_Request_Status__c == PLANNED || pfr.Core_MDF_Fund_Request_Status__c == INPROGRESS){	
                        pfrToBeUpdated.Core_MDF_Activity_Closure_Type__c = AUTO;
                    }
                    //Ramapriya - added code as part of In-Progress Activity Edit for IPA Program
                    else if (pfr.Core_MDF_Fund_Request_Status__c == INPROGRESS_PENDING_REVIEW || pfr.Core_MDF_Fund_Request_Status__c == INPROGRESS_PENDING_APPROVAL || pfr.Core_MDF_Fund_Request_Status__c == INPROGRESS_REVISION_REQUIRED) {
                        pfrToBeUpdated.Core_MDF_Activity_Closure_Type__c = AUTO_MISSED_IN_PROGRESS_APPROVAL;
                    }
                    else{
                          pfrToBeUpdated.Core_MDF_Activity_Closure_Type__c = AUTO_MISSED_APPROVAL;
                    }
                    pfrToBeUpdated.Core_MDF_Fund_Request_Status__c = CLOSED;
                    pfrToUpdateMap.put(pfrToBeUpdated.Id, pfrToBeUpdated);
                }
                if(!pfrToUpdateMap.isEmpty()){
                    Database.SaveResult[] srList = Database.update(pfrToUpdateMap.values(),false);  
                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {
                        }
                        else {
                            List<string> errorMsgs = new List<string>();for(Database.Error err : sr.getErrors()) { string errorMsg = err.getStatusCode() + ': ' + err.getFields() + ': ' + err.getMessage();errorMsgs.add(errorMsg);}pfrIdToErrorsMap.put(sr.getId(),errorMsgs);
                             }
                    }
                Map<String, String> coreLogMap = new Map<String, String>();
                coreLogMap.put('Core_Origin__c','Core_MDF_ActivityClosure_Batch');
                coreLogMap.put('Core_Severity__c','Low');
                coreLogMap.put('Core_sObjectType__c','PartnerFundRequest');
                coreLogMap.put('Core_Project__c','Consolidated Co-Marketing Program (CCP)');
                
                if(pfrIdToErrorsMap != null && !pfrIdToErrorsMap.values().isEmpty()){
                    Integer strLength = JSON.serialize(pfrIdToErrorsMap).length();string details;coreLogMap.put('Core_Message__c','Records Failed: '+JSON.serialize(pfrIdToErrorsMap.keySet()));details = strLength < LONG_TEXT_AREA_LIMIT ? JSON.serialize(pfrIdToErrorsMap) : JSON.serialize(pfrIdToErrorsMap).substring(0,LONG_TEXT_AREA_LIMIT);coreLogMap.put('Core_Details__c',details);string logRecordId = Core_MDF_CCP_UtilityClass.createLogEntry(coreLogMap);
                   }
                }
            }
        }
        catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    global void finish(Database.BatchableContext bc){
    }
}