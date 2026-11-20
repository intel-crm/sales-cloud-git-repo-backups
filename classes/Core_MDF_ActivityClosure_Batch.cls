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
            'Amount,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Is_Outcome_Based_Ind__c,Core_MDF_Activity_Level_nm__c,'+
            '(select Id,Amount from PartnerFundClaims where Core_MDF_Status__c IN : claimStatus AND Core_MDF_Type_Txt__c = \'Claim\') '+
            'FROM PartnerFundRequest '+
            'WHERE Core_MDF_ToBeClosedDate__c <: todaysDate ' +
            'AND Core_MDF_Fund_Request_Status__c != \'Closed\' AND Core_MDF_Fund_Request_Status__c != \'Cancelled\' AND Core_MDF_Fund_Request_Status__c != \'Declined\'';
		
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<PartnerFundRequest> pfrList){
        map<Id,PartnerFundRequest> pfrToUpdateMap = new map<Id,PartnerFundRequest>();
        Map<Id,List<string>> pfrIdToErrorsMap = new Map<Id,List<string>>();
        List<String> activityBudgetType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EligibleBT_ActivityAutoClose').split(';');
        List<string> pfrProgramSpecific = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Close_Open_Activity_Program').split(';');
        
        try{
            // Guard clause to handle null or empty pfrList - US - TWC702-14285
            if(pfrList == null || pfrList.isEmpty()){
                return;
            }
            
            // Separate outcome-based parent activities from regular activities
            List<PartnerFundRequest> outcomeBasedParentActivities = new List<PartnerFundRequest>();
            List<PartnerFundRequest> regularActivities = new List<PartnerFundRequest>();
            
            for(PartnerFundRequest pfr : pfrList){
                if(isOutcomeBasedParentActivity(pfr)) {
                    outcomeBasedParentActivities.add(pfr);
                } else {
                    regularActivities.add(pfr);
                }
            }
            // Process regular activities (existing logic)
            processRegularActivities(regularActivities, pfrToUpdateMap, activityBudgetType, pfrProgramSpecific);
            // Process outcome-based parent activities
            processOutcomeBasedActivities(outcomeBasedParentActivities, pfrToUpdateMap, activityBudgetType, pfrProgramSpecific);
            // Early return if no records to update - US - TWC702-14285
            if(pfrToUpdateMap.isEmpty()){
                return;
            }
            
            Database.SaveResult[] srList = Database.update(pfrToUpdateMap.values(),false);  
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                  
                }
                else {
                    List<string> errorMsgs = new List<string>();
                    for(Database.Error err : sr.getErrors()) { 
                        string errorMsg = err.getStatusCode() + ': ' + err.getFields() + ': ' + err.getMessage();
                        errorMsgs.add(errorMsg);
                    }
                    pfrIdToErrorsMap.put(sr.getId(),errorMsgs);
                }
            }
            
            Map<String, String> coreLogMap = new Map<String, String>();
            coreLogMap.put('Core_Origin__c','Core_MDF_ActivityClosure_Batch');
            coreLogMap.put('Core_Severity__c','Low');
            coreLogMap.put('Core_sObjectType__c','PartnerFundRequest');
            coreLogMap.put('Core_Project__c','Consolidated Co-Marketing Program (CCP)');
            
            if(pfrIdToErrorsMap != null && !pfrIdToErrorsMap.values().isEmpty()){
                    Integer strLength = JSON.serialize(pfrIdToErrorsMap).length();
                    string details;
                    coreLogMap.put('Core_Message__c','Records Failed: '+JSON.serialize(pfrIdToErrorsMap.keySet()));
                    details = strLength < LONG_TEXT_AREA_LIMIT ? JSON.serialize(pfrIdToErrorsMap) : JSON.serialize(pfrIdToErrorsMap).substring(0,LONG_TEXT_AREA_LIMIT);
                    coreLogMap.put('Core_Details__c',details);
                   Core_MDF_CCP_UtilityClass.createLogEntry(coreLogMap);
                }
        }
        catch(Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    /**
     * Check if the activity is an outcome-based parent activity
     */
    private Boolean isOutcomeBasedParentActivity(PartnerFundRequest activity) {
        return (activity.Core_MDF_Is_Outcome_Based_Ind__c == true && 
                (activity.Core_MDF_Activity_Level_nm__c == null || activity.Core_MDF_Activity_Level_nm__c != 'Sub Activity'));
    }
    
    /**
     * Process regular activities - existing logic preserved
     */
    private void processRegularActivities(List<PartnerFundRequest> regularActivities, Map<Id,PartnerFundRequest> pfrToUpdateMap, List<String> activityBudgetType, List<String> pfrProgramSpecific) {
        for(PartnerFundRequest pfr : regularActivities){
            PartnerFundRequest pfrToBeUpdated = new PartnerFundRequest();
            pfrToBeUpdated.Id = pfr.Id;
            if(activityBudgetType.contains(pfr.Core_MDF_Budget_Type_nm__c) || pfrProgramSpecific.contains(pfr.Core_MDF_Program__c)){
                Decimal amountSum = 0;
                if(pfr.PartnerFundClaims != null & !pfr.PartnerFundClaims.isEmpty()){
                    for(PartnerFundClaim pfc : pfr.PartnerFundClaims){
                        amountSum += pfc.Amount;
                    }
                }
                pfrToBeUpdated.Amount = amountSum;
            } 
            if(pfr.Core_MDF_Fund_Request_Status__c == PLANNED || pfr.Core_MDF_Fund_Request_Status__c == INPROGRESS){	
                pfrToBeUpdated.Core_MDF_Activity_Closure_Type__c = AUTO;
            }
            else if (pfr.Core_MDF_Fund_Request_Status__c == INPROGRESS_PENDING_REVIEW || 
                     pfr.Core_MDF_Fund_Request_Status__c == INPROGRESS_PENDING_APPROVAL || 
                     pfr.Core_MDF_Fund_Request_Status__c == INPROGRESS_REVISION_REQUIRED) {
                pfrToBeUpdated.Core_MDF_Activity_Closure_Type__c = AUTO_MISSED_IN_PROGRESS_APPROVAL;
            }
            else{
                pfrToBeUpdated.Core_MDF_Activity_Closure_Type__c = AUTO_MISSED_APPROVAL;
            }
            pfrToBeUpdated.Core_MDF_Fund_Request_Status__c = CLOSED;
            pfrToUpdateMap.put(pfrToBeUpdated.Id, pfrToBeUpdated);
        }
    }
    
    /**
     * Process outcome-based parent activities and their sub-activities
     */
    private void processOutcomeBasedActivities(List<PartnerFundRequest> outcomeBasedParentActivities, Map<Id,PartnerFundRequest> pfrToUpdateMap, List<String> activityBudgetType, List<String> pfrProgramSpecific) {
        Set<Id> parentActivityIds = new Set<Id>();
        for(PartnerFundRequest parent : outcomeBasedParentActivities) {
            parentActivityIds.add(parent.Id);
        }
        // Get all sub-activities for these parent activities
        Map<Id, List<PartnerFundRequest>> parentToSubActivitiesMap = new Map<Id, List<PartnerFundRequest>>();
        List<PartnerFundRequest> allSubActivities = [SELECT Id, Core_MDF_Parent_Activity_Id__c, Core_MDF_Fund_Request_Status__c, Amount,Core_MDF_Budget_Type_nm__c, Core_MDF_Program__c,(SELECT Id, Amount FROM PartnerFundClaims WHERE Core_MDF_Claim_Id__c != null AND Core_MDF_Claim_Id__r.Core_MDF_Status__c IN :claimStatus AND Core_MDF_Type_Txt__c = 'Claim') FROM PartnerFundRequest WHERE Core_MDF_Parent_Activity_Id__c IN :parentActivityIds AND Core_MDF_Activity_Level_nm__c = 'Sub Activity' AND Core_MDF_Fund_Request_Status__c != 'Cancelled'];
        // Group sub-activities by parent
        for(PartnerFundRequest subActivity : allSubActivities) {
            if(!parentToSubActivitiesMap.containsKey(subActivity.Core_MDF_Parent_Activity_Id__c)) {
                parentToSubActivitiesMap.put(subActivity.Core_MDF_Parent_Activity_Id__c, new List<PartnerFundRequest>());
            }
            parentToSubActivitiesMap.get(subActivity.Core_MDF_Parent_Activity_Id__c).add(subActivity);
        }
        // Process each parent activity and its sub-activities
        for(PartnerFundRequest parentActivity : outcomeBasedParentActivities) {
            // Process sub-activities first
            List<PartnerFundRequest> subActivities = parentToSubActivitiesMap.get(parentActivity.Id);
            if(subActivities != null && !subActivities.isEmpty()) {
                for(PartnerFundRequest subActivity : subActivities) {
                    PartnerFundRequest subActivityToUpdate = new PartnerFundRequest();
                    subActivityToUpdate.Id = subActivity.Id;
                    // Calculate claim amount for sub-activity
                    if(activityBudgetType.contains(subActivity.Core_MDF_Budget_Type_nm__c) || pfrProgramSpecific.contains(subActivity.Core_MDF_Program__c)){
                        Decimal subAmountSum = 0;
                        if(subActivity.PartnerFundClaims != null && !subActivity.PartnerFundClaims.isEmpty()){
                            for(PartnerFundClaim pfc : subActivity.PartnerFundClaims){
                                subAmountSum += pfc.Amount;
                            }
                        }
                        subActivityToUpdate.Amount = subAmountSum;
                    }
                    // Set closure type based on current status
                    if(subActivity.Core_MDF_Fund_Request_Status__c == PLANNED || subActivity.Core_MDF_Fund_Request_Status__c == INPROGRESS){	
                        subActivityToUpdate.Core_MDF_Activity_Closure_Type__c = AUTO;
                    }
                    else if (subActivity.Core_MDF_Fund_Request_Status__c == INPROGRESS_PENDING_REVIEW || subActivity.Core_MDF_Fund_Request_Status__c == INPROGRESS_PENDING_APPROVAL || subActivity.Core_MDF_Fund_Request_Status__c == INPROGRESS_REVISION_REQUIRED) {
                        subActivityToUpdate.Core_MDF_Activity_Closure_Type__c = AUTO_MISSED_IN_PROGRESS_APPROVAL;
                    }
                    else{
                        subActivityToUpdate.Core_MDF_Activity_Closure_Type__c = AUTO_MISSED_APPROVAL;
                    }
                    subActivityToUpdate.Core_MDF_Fund_Request_Status__c = CLOSED;
                    pfrToUpdateMap.put(subActivityToUpdate.Id, subActivityToUpdate);
                }
            }
            // Process parent activity
            PartnerFundRequest parentToUpdate = new PartnerFundRequest();
            parentToUpdate.Id = parentActivity.Id;
            parentToUpdate.Amount = 0;
            // Set closure type for parent
            if(parentActivity.Core_MDF_Fund_Request_Status__c == PLANNED || parentActivity.Core_MDF_Fund_Request_Status__c == INPROGRESS){	
                parentToUpdate.Core_MDF_Activity_Closure_Type__c = AUTO;
            }
            else if (parentActivity.Core_MDF_Fund_Request_Status__c == INPROGRESS_PENDING_REVIEW ||  parentActivity.Core_MDF_Fund_Request_Status__c == INPROGRESS_PENDING_APPROVAL || parentActivity.Core_MDF_Fund_Request_Status__c == INPROGRESS_REVISION_REQUIRED) {
                parentToUpdate.Core_MDF_Activity_Closure_Type__c = AUTO_MISSED_IN_PROGRESS_APPROVAL;
            }
            else{
                parentToUpdate.Core_MDF_Activity_Closure_Type__c = AUTO_MISSED_APPROVAL;
            }
            parentToUpdate.Core_MDF_Fund_Request_Status__c = CLOSED;
            pfrToUpdateMap.put(parentToUpdate.Id, parentToUpdate);
        }
    }
    
    global void finish(Database.BatchableContext bc){
    }
}