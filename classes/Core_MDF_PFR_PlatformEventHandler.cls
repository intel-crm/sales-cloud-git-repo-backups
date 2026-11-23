/*****************************************************************************************************
Class        :   Core_MDF_PFR_PlatformEventHandler
Description  :   Class to handle Activity PlatformEvent
Developed By :   Weezer - Shiva
*****************************************************************************************************/
public without sharing class Core_MDF_PFR_PlatformEventHandler {
    
    Public static Integer BATCH_SCOPE = Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BulkUpdate_BatchSize'));
    Public static List<string> pfcStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EscClaim_Cancel_or_ReSubClosed').split(';');
    public static string LATECLAIM_TYPE = Core_MDF_CCP_ConstantClass.LATECLAIM_TYPE;
    
    //Method to update escalation status to cancelled once associated late claim is cancelled or Expired if associated claim goes into resubmission window closed
    public static void updateEscalationStatus(set<Id> escalationIds){
        List<Core_MDF_Escalation__c> escalationList = new List<Core_MDF_Escalation__c>();
       // Highlight: Unused Local Variable - 14285
       // Set<Id> escalationIdSet = new Set<Id>();
        string ESC_CANCELLED_STATUS = Core_MDF_CCP_ConstantClass.CANCELLED_STATUS;
        string ESC_EXPIRED_STATUS = Core_MDF_CCP_ConstantClass.ESC_EXPIRED_STATUS;
        
        string ESC_APPROVED_STATUS = Core_MDF_CCP_ConstantClass.ESC_APPROVED_STATUS;
        string systemCancelText = '\n' + 'Note: ' + System.now().date().format() + ' ' + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Escalation_with_Cancel_Claims');
        string systemCloseText = '\n' + 'Note: ' + System.now().date().format() + ' ' + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Esc_With_ResubClosed_Claims');
        
        for(Core_MDF_Escalation__c esc : [SELECT Id, Core_MDF_Escalation_Status_nm__c, Core_MDF_Issue_Description_txt__c,Core_MDF_Claim_Number_id__r.Core_MDF_Status__c,
                                          (select id,Core_MDF_Status__c from Partner_Fund_Claims__r where Core_MDF_Status__c NOT IN: pfcStatus)
                                          FROM Core_MDF_Escalation__c 
                                          Where //Core_MDF_Claim_Number_id__c != Null 
                                          Core_MDF_Escalation_Type_nm__c =: LATECLAIM_TYPE
                                          AND Core_MDF_Escalation_Status_nm__c =: ESC_APPROVED_STATUS
                                          AND ID IN: escalationIds]){
                                              
                                              if(esc.Partner_Fund_Claims__r == NULL || (esc.Partner_Fund_Claims__r != NULL && esc.Partner_Fund_Claims__r.isEmpty())){//add comment
                                                  Core_MDF_Escalation__c escObj = new Core_MDF_Escalation__c();
                                                  escObj.Id = esc.Id;    	
                                                  
                                                  if(esc.Core_MDF_Claim_Number_id__c == Null || (esc.Core_MDF_Claim_Number_id__c != Null && esc.Core_MDF_Claim_Number_id__r.Core_MDF_Status__c == Label.Core_MDF_Claim_Status_Cancelled)){
                                                      escObj.Core_MDF_Issue_Description_txt__c = esc.Core_MDF_Issue_Description_txt__c != null ? 
                                                          esc.Core_MDF_Issue_Description_txt__c + systemCancelText:
                                                      systemCancelText;
                                                      escObj.Core_MDF_Escalation_Status_nm__c = ESC_CANCELLED_STATUS;
                                                      
                                                  }else{
                                                      escObj.Core_MDF_Issue_Description_txt__c = esc.Core_MDF_Issue_Description_txt__c != null ?esc.Core_MDF_Issue_Description_txt__c + systemCloseText:systemCloseText;escObj.Core_MDF_Escalation_Status_nm__c = ESC_EXPIRED_STATUS;
                                                  }
                                                  escalationList.add(escObj);	
                                              }
                                          }
        if(escalationList.size() == 1){
            update escalationList;
        }
        
        if(!escalationList.isEmpty() && escalationList.size() > 1){
            Database.executeBatch(new Core_MDF_BulkUpdate_Batch(escalationList), BATCH_SCOPE);
        }  
        
    }    
    
    //Method to update amount on activity once claim is cancelled or claim goes to resubmission window closed
public static void updateActivityAmount(set<Id> pfrIds){
    string TYPE_CLAIM = Core_MDF_CCP_ConstantClass.TYPE_CLAIM; 
    string ESC_APPROVED_STATUS = Core_MDF_CCP_ConstantClass.ESC_APPROVED_STATUS;
    Map<Id, Decimal> pfrToClaimAmtMap = new Map<Id,Decimal>();
    Map<Id, Decimal> pfrToEscalationAmtMap = new Map<Id, Decimal>();
    List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
    List<string> pfcCloseStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimStatus_ActivityAutoClose').split(';');
    
    // Check if any records are IPA Outcome-based
    Set<Id> ipaOutcomeParentIds = new Set<Id>();
    for(PartnerFundRequest pfr : [SELECT Id FROM PartnerFundRequest 
                                  WHERE Id IN :pfrIds 
                                  AND RecordType.Name = 'Intel Partner Alliance' 
                                  AND Core_MDF_Is_Outcome_Based_Ind__c = true]) {
        ipaOutcomeParentIds.add(pfr.Id);
    }
    
    if(ipaOutcomeParentIds.isEmpty()) {
        for(AggregateResult pfc : [SELECT RequestId Id ,sum(Amount)amt
                                   FROM PartnerFundClaim 
                                   WHERE RequestId IN: pfrIds AND Core_MDF_Status__c IN:pfcCloseStatus  
                                   AND Core_MDF_Type_Txt__c =: TYPE_CLAIM 
                                   AND Core_MDF_Escalation_Id__c = null 
                                   GROUP BY RequestId]){ 
            ID pfrID =(Id)pfc.get('Id');
            Decimal pfrClaimedAmount =(Decimal)pfc.get('amt'); 
            pfrToClaimAmtMap.put(pfrID,pfrClaimedAmount);
        }
        
        for(Core_MDF_Escalation__c esc : [SELECT Id,Core_MDF_Co_Marketing_Activity_id__c,Core_MDF_Claim_Number_id__c,Core_MDF_Approved_Amount_amt__c,
                                          (select id,Core_MDF_Status__c from Partner_Fund_Claims__r where Core_MDF_Status__c NOT IN: pfcStatus)
                                          FROM Core_MDF_Escalation__c 
                                          Where Core_MDF_Escalation_Type_nm__c =: LATECLAIM_TYPE
                                          AND Core_MDF_Escalation_Status_nm__c =: ESC_APPROVED_STATUS
                                          AND Core_MDF_Co_Marketing_Activity_id__c IN: pfrIds]){
            
            if(!esc.Partner_Fund_Claims__r.isEmpty() || esc.Core_MDF_Claim_Number_id__c == NULL) { 
                if(pfrToEscalationAmtMap.containskey(esc.Core_MDF_Co_Marketing_Activity_id__c)){
                    Decimal pfrEscAmount = esc.Core_MDF_Approved_Amount_amt__c + pfrToEscalationAmtMap.get(esc.Core_MDF_Co_Marketing_Activity_id__c);
                    pfrToEscalationAmtMap.put(esc.Core_MDF_Co_Marketing_Activity_id__c,pfrEscAmount);
                }else{
                    pfrToEscalationAmtMap.put(esc.Core_MDF_Co_Marketing_Activity_id__c,esc.Core_MDF_Approved_Amount_amt__c);
                }
            }
        }
        
        for(PartnerFundRequest pfr : [SELECT Id, Amount, Core_MDF_Activity_Reimbursement_Amt_nbr__c FROM PartnerFundRequest WHERE Id IN: pfrIds]){
            PartnerFundRequest pfrObj = new PartnerFundRequest();
            pfrObj.Id = pfr.Id;                               
            Decimal totalEscAmt = pfrToEscalationAmtMap.containskey(pfr.Id) ? 
                pfrToEscalationAmtMap.get(pfr.Id) : 0;
            Decimal totalClaimedAmt = pfrToClaimAmtMap.containskey(pfr.Id) ? 
                pfrToClaimAmtMap.get(pfr.Id) : 0;

            pfrObj.Amount = (totalEscAmt + totalClaimedAmt) > pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c ?
                pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c:
                totalEscAmt + totalClaimedAmt;
            
            pfrList.add(pfrObj);
        }
    } 

 else{
    
    // Get ALL Sub Activities for ALL outcome-based parent activities
    Map<Id, List<PartnerFundRequest>> parentToSubActivitiesMap = new Map<Id, List<PartnerFundRequest>>();
    Map<Id, PartnerFundRequest> allSubActivities = new Map<Id, PartnerFundRequest>();
    
    for(PartnerFundRequest subPfr : [SELECT Id, Core_MDF_Activity_Reimbursement_Amt_nbr__c, Core_MDF_Parent_Activity_Id__c FROM PartnerFundRequest WHERE Core_MDF_Parent_Activity_Id__c IN :ipaOutcomeParentIds AND Core_MDF_Activity_Level_nm__c = 'Sub Activity']) {
        
        allSubActivities.put(subPfr.Id, subPfr);
        
        // Group sub activities by parent
        if(!parentToSubActivitiesMap.containsKey(subPfr.Core_MDF_Parent_Activity_Id__c)) {
            parentToSubActivitiesMap.put(subPfr.Core_MDF_Parent_Activity_Id__c, new List<PartnerFundRequest>());
        }
        parentToSubActivitiesMap.get(subPfr.Core_MDF_Parent_Activity_Id__c).add(subPfr);
    }
    
    // Get Fund Allocation Distribution percentages 
    Map<Id, Map<Id, Decimal>> parentToSubPercentageMap = new Map<Id, Map<Id, Decimal>>();
    for(Core_MDF_Outcome_Account_Mapping__c fad : [SELECT Core_MDF_OutcomeBased_SubAct_Id__c, Core_MDF_Percentage_pct__c,Core_MDF_Outcome_Based_CampaignId__c FROM Core_MDF_Outcome_Account_Mapping__c WHERE Core_MDF_OutcomeBased_SubAct_Id__c IN :allSubActivities.keySet() AND Core_MDF_Outcome_Based_CampaignId__c IN :ipaOutcomeParentIds]) {
        
        Id parentId = fad.Core_MDF_Outcome_Based_CampaignId__c;
        Id subActivityId = fad.Core_MDF_OutcomeBased_SubAct_Id__c;
        Decimal percentage = fad.Core_MDF_Percentage_pct__c / 100; // Convert whole number to decimal
        
        if(!parentToSubPercentageMap.containsKey(parentId)) {
            parentToSubPercentageMap.put(parentId, new Map<Id, Decimal>());
        }
        parentToSubPercentageMap.get(parentId).put(subActivityId, percentage);
    }
    
    // Get Super Claims (from parent activities)
    for(AggregateResult pfc : [SELECT RequestId Id, SUM(Amount) amt FROM PartnerFundClaim WHERE RequestId IN: ipaOutcomeParentIds AND Core_MDF_Status__c IN: pfcCloseStatus  AND Core_MDF_Type_Txt__c =: TYPE_CLAIM AND Core_MDF_Escalation_Id__c = null GROUP BY RequestId]){ 
        ID pfrID = (Id)pfc.get('Id');
        Decimal pfrClaimedAmount = (Decimal)pfc.get('amt'); 
        pfrToClaimAmtMap.put(pfrID, pfrClaimedAmount);
    }
    
    // Get Escalations (from parent activities)
    for(Core_MDF_Escalation__c esc : [SELECT Id,Core_MDF_Co_Marketing_Activity_id__c,Core_MDF_Claim_Number_id__c,Core_MDF_Approved_Amount_amt__c,(select id,Core_MDF_Status__c from Partner_Fund_Claims__r where Core_MDF_Status__c NOT IN: pfcStatus)FROM Core_MDF_Escalation__c Where Core_MDF_Escalation_Type_nm__c =: LATECLAIM_TYPE AND Core_MDF_Escalation_Status_nm__c =: ESC_APPROVED_STATUS AND Core_MDF_Co_Marketing_Activity_id__c IN: ipaOutcomeParentIds]){
        
        if(!esc.Partner_Fund_Claims__r.isEmpty() || esc.Core_MDF_Claim_Number_id__c == NULL) { 
            if(pfrToEscalationAmtMap.containskey(esc.Core_MDF_Co_Marketing_Activity_id__c)){
                Decimal pfrEscAmount = esc.Core_MDF_Approved_Amount_amt__c + pfrToEscalationAmtMap.get(esc.Core_MDF_Co_Marketing_Activity_id__c);
                pfrToEscalationAmtMap.put(esc.Core_MDF_Co_Marketing_Activity_id__c, pfrEscAmount);
            }else{
                pfrToEscalationAmtMap.put(esc.Core_MDF_Co_Marketing_Activity_id__c, esc.Core_MDF_Approved_Amount_amt__c);
            }
        }
    }
    
    // Get Sub Claims (directly on sub activities)
    Map<Id, Decimal> subClaimAmtMap = new Map<Id, Decimal>();
    for(AggregateResult ar : [SELECT RequestId Id, SUM(Amount) amt FROM PartnerFundClaim WHERE RequestId IN :allSubActivities.keySet() AND Core_MDF_Status__c IN :pfcCloseStatus AND Core_MDF_Type_Txt__c = :TYPE_CLAIM AND Core_MDF_Escalation_Id__c = null GROUP BY RequestId]) {
        ID pfrID = (Id)ar.get('Id');
        Decimal pfrClaimedAmount = (Decimal)ar.get('amt'); 
        subClaimAmtMap.put(pfrID, pfrClaimedAmount);
    }
    
    // Process EACH PARENT ACTIVITY individually
    for(Id parentId : ipaOutcomeParentIds) {
        
        // Get parent totals for THIS specific parent
        Decimal parentTotalEscAmt = pfrToEscalationAmtMap.containsKey(parentId) ? 
            pfrToEscalationAmtMap.get(parentId) : 0;
        Decimal parentTotalClaimedAmt = pfrToClaimAmtMap.containsKey(parentId) ? 
            pfrToClaimAmtMap.get(parentId) : 0;
        
        // Get percentage mapping for THIS parent's sub activities
        Map<Id, Decimal> thisParentSubPercentages = parentToSubPercentageMap.get(parentId);
        
        // Process each sub activity for THIS parent
        List<PartnerFundRequest> subActivitiesForThisParent = parentToSubActivitiesMap.get(parentId);
        if(subActivitiesForThisParent != null && thisParentSubPercentages != null) {
            
            for(PartnerFundRequest subPfr : subActivitiesForThisParent) {
                PartnerFundRequest pfrObj = new PartnerFundRequest();
                pfrObj.Id = subPfr.Id;
                
                // Get percentage for this specific sub activity under this parent
                Decimal percentage = thisParentSubPercentages.containsKey(subPfr.Id) ? 
                    thisParentSubPercentages.get(subPfr.Id) : 0;
                
                // Apply percentage distribution to BOTH escalation and claims from parent
                Decimal distributedEscAmt = parentTotalEscAmt * percentage;
                Decimal distributedClaimAmt = parentTotalClaimedAmt * percentage;
                
                // Add any direct claims on this sub activity
                Decimal directSubClaimAmt = subClaimAmtMap.containsKey(subPfr.Id) ? 
                    subClaimAmtMap.get(subPfr.Id) : 0;
                
                Decimal totalEscAmt = distributedEscAmt;
                Decimal totalClaimedAmt = distributedClaimAmt + directSubClaimAmt;
                
                // Apply reimbursement limit (Intel contribution limit)
                pfrObj.Amount = (totalEscAmt + totalClaimedAmt) > subPfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c ?
                    subPfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c :
                    totalEscAmt + totalClaimedAmt;
                
                pfrList.add(pfrObj);
            }
        }
    }
    
}

  if(!pfrList.isEmpty()){
        Database.executeBatch(new Core_MDF_BulkUpdate_Batch(pfrList),BATCH_SCOPE);
    }
}
    
    
     /*****************************************************************************************************
Method Name :   updateActivityStatus 
@return     :   NULL
@parameters :   Set of Activity Ids
Description :   When all related claims are cancelled, the Activity status changes to Planned.
Added By    :   Accenture - Rishabh - 12/22/2025	
******************************************************************************************************/
    public static void updateActivityStatus(set<Id> pfrIds){
        String claimCancelledstatus=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Cancelled');
        Map<Id, Integer> mapOfActivityIdVsCountOfClaim = new Map<Id, Integer>();
        Map<Id, Integer> mapOfActivityIdVsCountOfCancelledClaim = new Map<Id, Integer>();
        String planned_status= Core_MDF_CCP_ConstantClass.PFR_PLANNED_STATUS;
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        
        
        
        for (AggregateResult pfc : [SELECT RequestId requestId, COUNT(Id) claimCount FROM PartnerFundClaim WHERE RequestId IN :pfrIds GROUP BY RequestId ]){
                                        mapOfActivityIdVsCountOfClaim.put((Id) pfc.get('requestId'),((Decimal) pfc.get('claimCount')).intValue());
                                    }
        for (AggregateResult pfc : [ SELECT RequestId requestId, COUNT(Id) cancelledCount FROM PartnerFundClaim WHERE RequestId IN :pfrIds AND Core_MDF_Status__c = :claimCancelledstatus GROUP BY RequestId]) {
                                        mapOfActivityIdVsCountOfCancelledClaim.put((Id) pfc.get('requestId'), ((Decimal) pfc.get('cancelledCount')).intValue());
                                    }
        
        for (Id pfrId : pfrIds) {
            
            Integer totalClaimsOnActivity = mapOfActivityIdVsCountOfClaim.containsKey(pfrId) ? mapOfActivityIdVsCountOfClaim.get(pfrId) : 0;
            Integer cancelledClaimsOnActivity  = mapOfActivityIdVsCountOfCancelledClaim.containsKey(pfrId) ? mapOfActivityIdVsCountOfCancelledClaim.get(pfrId): 0;
            
            if(totalClaimsOnActivity > 0 && totalClaimsOnActivity == cancelledClaimsOnActivity){pfrList.add(new PartnerFundRequest(Id = pfrId,Core_MDF_Fund_Request_Status__c = planned_status));}
        }
        
        if(!pfrList.isEmpty()){
            if (pfrList.size() > 10000) {Database.executeBatch(new Core_MDF_BulkUpdate_Batch(pfrList), BATCH_SCOPE);} else {update pfrList;}
        }
        
    }
    
}