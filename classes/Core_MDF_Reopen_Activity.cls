public without sharing class Core_MDF_Reopen_Activity {
    
    Public static List<string> multipleBTProg = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Close_Open_Activity_Program').split(';');
    public static List<String> cmpBudgetType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CMP_BudgetType').split(';');

    Public static string ESC_APPROVED_STATUS = Core_MDF_CCP_ConstantClass.ESC_APPROVED_STATUS;
    Public static string TYPE_CLAIM = Core_MDF_CCP_ConstantClass.TYPE_CLAIM;

    Public static String reopenStatus = System.Label.Core_MDF_ATF_Reopen_Status;
    public static string autoClosurekeyStr = '';
    public static Map<String,Date> quarterEndMap = new Map<String,Date>();

    @AuraEnabled
    public static string validateActivity(string activityId) {
        string returnMsg = 'success';
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<String> eligibleBudgets = new List<String>();
        List<String> eligiblePS = new List<String>();
        
        List<Core_MDF_Program_Budget_RecordType__mdt> progBudgetMdt = new List<Core_MDF_Program_Budget_RecordType__mdt>();
        List<Core_MDF_Program_Budget_RecordType__mdt> programbudgetRecordType = new List<Core_MDF_Program_Budget_RecordType__mdt>();
        List<string> claimCloseStatus = new List<string>();
        Map<Id,String> accIdRegMap = new Map<Id,String>();
        Boolean hasPermission = false;
        string budgetType,program;
        
       Date activityCloseDate;
        Decimal claimedAmount = 0.0;
        Decimal escAmount = 0.0;
        Decimal totalConsumedAmt = 0.0;
        Decimal reimbursementAmt = 0.0;
        Decimal allocationAvailAmt = 0.0;
        Decimal totalAvailableAmt = 0.0;
        ReopenWrapper reopenWrap = new ReopenWrapper();
        
        try{
            
            if(string.isNotBlank(activityId)){
                pfrList = [SELECT Id,campaign.Core_MDF_Program__c,ChannelPartnerId,RecordType.DeveloperName,Core_MDF_Fund_Request_Status__c,
                           Core_MDF_End_Date__c,Amount,Core_MDF_Activity_Closure_Type__c,Core_MDF_Activity_Reimbursement_Amt_nbr__c,Core_MDF_Ultimate_Account_Name__c,
                           Core_MDF_Program__c,Core_MDF_Budget_Type_nm__c,Budget.EndDate,Allocation.Core_MDF_Available_Activity_Alloc_Amt__c,Campaign.Core_MDF_Reimbursement_Amt__c,
                           Tolabel(ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.BillingCountryCode),Core_MDF_End_Date_Is_Changed_ind__c,Core_MDF_ATF_Flag_nm__c,CreatedDate,
                           ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Geo__c,Core_MDF_Proposal_Based_Ind__c,
                           BudgetId,CampaignId,Campaign.Core_MDF_Budget__r.EndDate,Core_MDF_PriorValueOfStatus__c,Core_MDF_Campaign_Amount__c,Budget.Core_MDF_Budget_Partner__c,
                           Core_MDF_Is_Outcome_Based_Ind__c, Core_MDF_Activity_Level_nm__c, Core_MDF_Parent_Activity_Id__c // Added outcome-based fields
                           FROM PartnerFundRequest 
                           WHERE Id =: activityId LIMIT 1];
            }
            
            if(pfrList != null && !pfrList.isEmpty()){
                budgetType =  pfrList[0].Core_MDF_Budget_Type_nm__c;
                program = pfrList[0].Core_MDF_Is_Outcome_Based_Ind__c == true ? pfrList[0].Core_MDF_Program__c : pfrList[0].campaign.Core_MDF_Program__c; // Rishabh
                
                if(pfrList[0].Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name')){
                    accIdRegMap.put(pfrList[0].ChannelPartnerId,pfrList[0].ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Geo__c);
                    Core_MDF_Process_PartnerFundRequest.accIdRegionMap = accIdRegMap;
                }
            }
            
            if(string.isNotBlank(budgetType) && string.isNotBlank(program)){
                progBudgetMdt = [SELECT Id,Core_MDF_Account_Manager_PS_API_Name__c,Core_MDF_RecordType__c,Core_MDF_BudgetType__c 
                                 FROM Core_MDF_Program_Budget_RecordType__mdt 
                                 WHERE Core_MDF_Account_Manager_PS_API_Name__c != null AND Core_MDF_Program__c =: program]; 
            }
            
            if(multipleBTProg.contains(pfrList[0].Core_MDF_Program__c)){
                if(pfrList[0].Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM){
                    for(Core_MDF_Program_Budget_RecordType__mdt pbr : progBudgetMdt){
                        programbudgetRecordType.add(pbr);
                        eligiblePS.add((string)pbr.Core_MDF_Account_Manager_PS_API_Name__c);
                    }
                } else {
                    programbudgetRecordType.add(progBudgetMdt[0]);
                }
            }else{
                for(Core_MDF_Program_Budget_RecordType__mdt pbr : progBudgetMdt){
                    if(pbr.Core_MDF_BudgetType__c == budgetType){
                        programbudgetRecordType.add(pbr);
                        break;
                    }
                }
            }
            
            if(programbudgetRecordType != null && !programbudgetRecordType.isEmpty()){
                
		        if(pfrList[0].Core_MDF_Program__c != Core_MDF_CCP_ConstantClass.EEF_PROGRAM){
                    eligiblePS.add((string)programbudgetRecordType[0].Core_MDF_Account_Manager_PS_API_Name__c);
                }
                if(UserInfo.getUserType() == 'PowerPartner'){
                    if(FeatureManagement.checkPermission('Core_MDF_CCP_External_Activity_Submitter') || FeatureManagement.checkPermission('Core_MDF_CCP_External_IPA_Activity_Manager') || FeatureManagement.checkPermission('Core_MDF_CCP_External_IPA_Proposal_Manager') || FeatureManagement.checkPermission('Core_MDF_CCP_EEF_Activating_Partner_User')){hasPermission = true;}
                }else {
                    List<PermissionSetAssignment> permissionAssign = [SELECT Id,AssigneeId, PermissionSet.Name
                                                                      FROM PermissionSetAssignment
                                                                      WHERE AssigneeId =: UserInfo.getUserId() and PermissionSet.Name In: eligiblePS];
                    
                    if(permissionAssign != null && !permissionAssign.isEmpty()){
                        hasPermission = true;
                    }
                }
            }
            
            if(pfrList != null && !pfrList.isEmpty()){
                string eligiblebudgetString = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ReOpen_Eligible_Budget_Types');
                eligibleBudgets = eligiblebudgetString.split(';');
                quarterEndMap = getActClosureDate(pfrList);
                string autoClosurekeyStr = Core_MDF_Process_PartnerFundRequest.buildKeyForActivityClosure(pfrList[0],pfrList[0].RecordType.DeveloperName);
                
                activityCloseDate = quarterEndMap.get(autoClosurekeyStr);
                
                List<PartnerFundRequestHistory> pfrHistoryList = new List<PartnerFundRequestHistory>();
                PartnerFundRequestHistory pfrHistory = new PartnerFundRequestHistory();
                if(activityCloseDate < system.today() && pfrList[0].Core_MDF_ATF_Flag_nm__c != null && pfrList[0].Core_MDF_ATF_Flag_nm__c.contains(System.Label.Core_MDF_ATF_Closed_Status)){
                    pfrHistoryList =  [select Id,NewValue, OldValue,Field,PartnerFundRequestId 
                                       from PartnerFundRequestHistory 
                                       Where Field =: 'Core_MDF_ToBeClosedDate__c' AND PartnerFundRequestId =:pfrList[0].Id 
                                       order By CreatedDate Desc Limit 1];
                    if(pfrHistoryList != null && !pfrHistoryList.isEmpty()){
                        pfrHistory = pfrHistoryList[0];
                        //Avoid Deeply Nested IF Statements
                        Date oldValueDate = (Date)pfrHistory.OldValue;
                        activityCloseDate = (oldValueDate == null) ? (Date)pfrHistory.NewValue : (oldValueDate >= System.today()) ? oldValueDate : getCloseDate(pfrList[0]);
                    }
                    else
                    {
                        activityCloseDate = getCloseDate(pfrList[0]);
                    }
                }
                
		//Cannot Reopen Activity for non eligible budgets
                if(!eligibleBudgets.contains(pfrList[0].Core_MDF_Budget_Type_nm__c) && !multipleBTProg.contains(pfrList[0].Core_MDF_Program__c)){
                       returnMsg = System.Label.Core_MDF_Cannot_Reopen_Activity;
                   }
                //check for user permission
                else if(!hasPermission){
                    returnMsg = System.Label.Core_MDF_CloneAccessError;
                }
                //Status should be in closed
                else if(pfrList[0].Core_MDF_Fund_Request_Status__c != 'Closed'){
                    returnMsg = System.Label.Core_MDF_Activity_Status_Not_Closed;
                } 
                //Only manually closed activity can be reopened
                else if(pfrList[0].Core_MDF_Activity_Closure_Type__c != 'Manual'){
                    returnMsg = System.Label.Core_MDF_Activity_Not_Closed_Manually;
                }         
                //Check if Activity Close Date is past
                else if(activityCloseDate < System.today()){
                    returnMsg = System.Label.Core_MDF_Claiming_Window_Closed;
                }
                //Check if Budget is expired
                else if(pfrList[0].Budget.EndDate < System.today()){
                    returnMsg = System.Label.Core_MDF_No_Matching_Budgets_Available;
                }
                //Check $ available in Partner Fund Allocation
                else if((isOutcomeBasedParentActivity(pfrList[0]) ? hasAnySubActivityWithZeroAllocation(activityId) : pfrList[0].Allocation.Core_MDF_Available_Activity_Alloc_Amt__c == 0)
                        && pfrList[0].Core_MDF_Budget_Type_nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_RSAMD_UnTranslated')
                        && !cmpBudgetType.contains(pfrList[0].Core_MDF_Budget_Type_nm__c)
                        && !(multipleBTProg.contains(pfrList[0].Core_MDF_Program__c) && pfrList[0].Core_MDF_Proposal_Based_Ind__c == True)
                        && pfrList[0].Core_MDF_Program__c != Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM
                        && pfrList[0].Core_MDF_Program__c != Core_MDF_CCP_ConstantClass.EEF_PROGRAM){
                            returnMsg = System.Label.Core_MDF_Activities_Exceeds_The_Allocated_Budget;
                        }
                //Check $ available in campaign budget
                else if(pfrList[0].Core_MDF_Budget_Type_nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_RSAMD_UnTranslated')){
                        returnMsg = validateActivityWithCampaign(pfrList[0]);
                }
                // For EEF Validation with Allocation
                if(returnMsg == 'success' && pfrList[0].Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM){
                    returnMsg = validatePfrWithAllocationForAutoTransfer(pfrList[0], false);
                }
                
                //Calculate amount to be claimed - Enhanced for outcome-based activities
                string claimStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimStatus_ActivityClose');
                if(returnMsg == 'success'){
                    claimCloseStatus = claimStatus.split(';');
                    
                    // Check if this is an outcome-based parent activity
                    if(isOutcomeBasedParentActivity(pfrList[0])) {
                        // For outcome-based activities, validate each sub-activity individually
                        List<SubActivityValidationResult> subActivityResults = validateOutcomeBasedSubActivities(activityId, claimCloseStatus, pfrList[0]);
                        
                        // Check if any sub-activity has validation errors
                        Boolean hasValidationError = false;
                        String validationErrorMsg = '';
                        Decimal totalParentReimbursementAmt = 0;
                        Decimal totalParentAvailableAmt = 0;
                        Decimal totalParentClaimedAmount = 0;
                        Decimal totalParentEscAmount = 0;
                        
                        for(SubActivityValidationResult result : subActivityResults) {
                            if(result.hasError) {
                                hasValidationError = true;
                                validationErrorMsg = result.errorMessage;
                                break; // Stop at first error
                            }
                            totalParentReimbursementAmt += result.reimbursementAmount;
                            totalParentAvailableAmt += result.availableAmount;
                            totalParentClaimedAmount += result.claimedAmount;
                            totalParentEscAmount += result.escAmount;
                        }
                        
                        if(hasValidationError) {
                            returnMsg = validationErrorMsg;
                        } else {
                            // Set parent activity values as sum of all sub-activities
                            reimbursementAmt = totalParentReimbursementAmt;
                            totalAvailableAmt = totalParentAvailableAmt;
                            reopenWrap.intelContribution = reimbursementAmt;
                            reopenWrap.pendingClaimableAmount = totalAvailableAmt;
                            reopenWrap.totalClaimAmount = totalParentClaimedAmount + totalParentEscAmount;
                        }
                    } else {
                        // Regular activity calculation (existing logic)
                        List<AggregateResult> pfcAmountList = [SELECT RequestId Id ,sum(Amount)amt 
                                                               FROM PartnerFundClaim 
                                                               WHERE RequestId =: activityId AND Core_MDF_Status__c IN: claimCloseStatus AND Core_MDF_Type_Txt__c =: TYPE_CLAIM
                                                               AND Core_MDF_Escalation_Id__c = null  
                                                               GROUP BY RequestId];


                    List<AggregateResult> escAmountList = [SELECT Core_MDF_Co_Marketing_Activity_id__c Id,sum(Core_MDF_Approved_Amount_amt__c)amt
                                                           FROM Core_MDF_Escalation__c
                                                           WHERE Core_MDF_Co_Marketing_Activity_id__c =: activityId 
                                                           AND Core_MDF_Escalation_Status_nm__c =: ESC_APPROVED_STATUS
                                                           GROUP BY Core_MDF_Co_Marketing_Activity_id__c];
                                                   
                                                   
                    
                    if( pfcAmountList != null && !pfcAmountList.isEmpty()){
                        claimedAmount = (Decimal)pfcAmountList[0].get('amt');
                    }

                        if(escAmountList != null && !escAmountList.isEmpty()){
                            escAmount = (Decimal)escAmountList[0].get('amt');
                        }
                        
                        if(pfrList[0].Allocation.Core_MDF_Available_Activity_Alloc_Amt__c != null){
                            allocationAvailAmt = pfrList[0].Allocation.Core_MDF_Available_Activity_Alloc_Amt__c;   
                        }
                        
                        if(pfrList[0].Core_MDF_Activity_Reimbursement_Amt_nbr__c != null && pfrList[0].Amount != null){
                            reimbursementAmt = pfrList[0].Core_MDF_Activity_Reimbursement_Amt_nbr__c;
                            reopenWrap.intelContribution = pfrList[0].Core_MDF_Activity_Reimbursement_Amt_nbr__c;    
                        }

                        totalConsumedAmt = claimedAmount + escAmount;
                        totalConsumedAmt = totalConsumedAmt >= reimbursementAmt ? reimbursementAmt : totalConsumedAmt;
                    
                        reopenWrap.intelContribution = reimbursementAmt;

                       Decimal availableAmount = 0;
                       availableAmount = (reimbursementAmt - totalConsumedAmt);
                    
                        if(availableAmount <= 0){
                            returnMsg = System.Label.Core_MDF_Claims_Exceeds_The_Activity_Spending_Limit;
                        }
                    
                        if((availableAmount > allocationAvailAmt) 
                           && pfrList[0].Core_MDF_Budget_Type_nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_RSAMD_UnTranslated')
                           && !cmpBudgetType.contains(pfrList[0].Core_MDF_Budget_Type_nm__c)
                           && !(multipleBTProg.contains(pfrList[0].Core_MDF_Program__c) && pfrList[0].Core_MDF_Proposal_Based_Ind__c == True)
                           && pfrList[0].Core_MDF_Program__c != Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM
                           && pfrList[0].Core_MDF_Program__c != Core_MDF_CCP_ConstantClass.EEF_PROGRAM){
                            returnMsg = System.Label.Core_MDF_Activities_Exceeds_The_Allocated_Budget;
                        }else{
                            totalAvailableAmt = availableAmount;
                        }
                        
                        reopenWrap.pendingClaimableAmount = totalAvailableAmt;
                        reopenWrap.totalClaimAmount = totalConsumedAmt;
                    }
                }
                
            }
            
        }catch(Exception ex){returnMsg = ex.getMessage();
                            }
        
        
        reopenWrap.validationMsg = returnMsg;
        return JSON.serialize(reopenWrap);
    }

    /**
     * @description Validate each sub-activity individually for outcome-based activities
     * @param parentActivityId The parent activity ID
     * @param claimCloseStatus List of claim statuses to consider
     * @param parentActivity The parent activity record
     * @return List<SubActivityValidationResult> List of validation results for each sub-activity
     */
    public static List<SubActivityValidationResult> validateOutcomeBasedSubActivities(Id parentActivityId, List<String> claimCloseStatus, PartnerFundRequest parentActivity) {
        List<SubActivityValidationResult> results = new List<SubActivityValidationResult>();
        
        try {
            // Get all closed sub-activities
            List<PartnerFundRequest> subActivities = [SELECT Id, Core_MDF_Activity_Reimbursement_Amt_nbr__c, Allocation.Core_MDF_Available_Activity_Alloc_Amt__c,Core_MDF_Budget_Type_nm__c, Core_MDF_Program__c, Core_MDF_Proposal_Based_Ind__c FROM PartnerFundRequest WHERE Core_MDF_Parent_Activity_Id__c = :parentActivityId AND Core_MDF_Activity_Level_nm__c = 'Sub Activity' AND Core_MDF_Fund_Request_Status__c = 'Closed'];
            Set<Id> subActivityIds = new Set<Id>();
            for(PartnerFundRequest subActivity : subActivities) {
                subActivityIds.add(subActivity.Id);
            }
            // Get claim amounts for all sub-activities
            Map<Id, Decimal> subActivityClaimAmounts = new Map<Id, Decimal>();
            for(AggregateResult ar : [SELECT RequestId, SUM(Amount) totalAmount FROM PartnerFundClaim WHERE RequestId IN :subActivityIds AND Core_MDF_Status__c IN :claimCloseStatus AND Core_MDF_Type_Txt__c = :TYPE_CLAIM AND Core_MDF_Escalation_Id__c = null GROUP BY RequestId]) {
                Id requestId = (Id)ar.get('RequestId');
                Decimal claimAmount = (Decimal)ar.get('totalAmount');
                subActivityClaimAmounts.put(requestId, claimAmount != null ? claimAmount : 0);
            }
            // Get escalation amounts for all sub-activities
            Map<Id, Decimal> subActivityEscAmounts = new Map<Id, Decimal>();
            for(AggregateResult ar : [SELECT Core_MDF_Co_Marketing_Activity_id__c, SUM(Core_MDF_Approved_Amount_amt__c) totalAmount  FROM Core_MDF_Escalation__c WHERE Core_MDF_Co_Marketing_Activity_id__c IN :subActivityIds AND Core_MDF_Escalation_Status_nm__c = :ESC_APPROVED_STATUS GROUP BY Core_MDF_Co_Marketing_Activity_id__c
            ]) {
                Id activityId = (Id)ar.get('Core_MDF_Co_Marketing_Activity_id__c');
                Decimal escAmount = (Decimal)ar.get('totalAmount');
                subActivityEscAmounts.put(activityId, escAmount != null ? escAmount : 0);
            }
            // Validate each sub-activity individually
            for(PartnerFundRequest subActivity : subActivities) {
                SubActivityValidationResult result = new SubActivityValidationResult();
                result.subActivityId = subActivity.Id;
                // Get amounts for this specific sub-activity
                result.claimedAmount = subActivityClaimAmounts.containsKey(subActivity.Id) ? subActivityClaimAmounts.get(subActivity.Id) : 0;
                result.escAmount = subActivityEscAmounts.containsKey(subActivity.Id) ? subActivityEscAmounts.get(subActivity.Id) : 0;
                result.reimbursementAmount = subActivity.Core_MDF_Activity_Reimbursement_Amt_nbr__c != null ? subActivity.Core_MDF_Activity_Reimbursement_Amt_nbr__c : 0;
                result.allocationAvailAmount = subActivity.Allocation.Core_MDF_Available_Activity_Alloc_Amt__c != null ? subActivity.Allocation.Core_MDF_Available_Activity_Alloc_Amt__c : 0;
                // Calculate consumed and available amounts for this sub-activity
                Decimal totalConsumedAmt = result.claimedAmount + result.escAmount;
                totalConsumedAmt = totalConsumedAmt >= result.reimbursementAmount ? result.reimbursementAmount : totalConsumedAmt;
                Decimal availableAmount = result.reimbursementAmount - totalConsumedAmt;
                // Validate this sub-activity
                if(availableAmount <= 0) {
                    result.hasError = true;
                    result.errorMessage = System.Label.Core_MDF_Claims_Exceeds_The_Activity_Spending_Limit;
                } else if((availableAmount > result.allocationAvailAmount)
                         && !(multipleBTProg.contains(parentActivity.Core_MDF_Program__c) && parentActivity.Core_MDF_Proposal_Based_Ind__c == True)) {
                    result.hasError = true;
                    result.errorMessage = System.Label.Core_MDF_Activities_Exceeds_The_Allocated_Budget;
                } else {
                    result.availableAmount = availableAmount;
                    result.hasError = false;
                }
                results.add(result);
            }
            
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        return results;
    }

    /**
     * @description Check if any sub-activity has zero allocation amount
     */
    private static Boolean hasAnySubActivityWithZeroAllocation(Id parentActivityId) {
        List<AggregateResult> results = [SELECT COUNT(Id) cnt FROM PartnerFundRequest WHERE Core_MDF_Parent_Activity_Id__c = :parentActivityId AND Core_MDF_Activity_Level_nm__c = 'Sub Activity' AND Core_MDF_Fund_Request_Status__c = 'Closed'
            AND (Allocation.Core_MDF_Available_Activity_Alloc_Amt__c = 0 OR Allocation.Core_MDF_Available_Activity_Alloc_Amt__c = null)];
        return (Integer)results[0].get('cnt') > 0;
    }
    
    @AuraEnabled
    public static string reOpenActivity(string actId){
        string returnMsg = '';

        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
 
        
        try{
            String reopenStatus = System.Label.Core_MDF_ATF_Reopen_Status;
            if(string.isNotBlank(actId)){
                pfrList = [SELECT Id,Core_MDF_Fund_Request_Status__c,Core_MDF_Manual_Closure_Prior_Status_txt__c,Core_MDF_ATF_Flag_nm__c,Core_MDF_Start_Date__c,
                           RecordType.DeveloperName,RecordTypeId,ChannelPartnerId,Tolabel(ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.BillingCountryCode),Core_MDF_Activity_Reimbursement_Amt_nbr__c,BudgetId,
                           ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Geo__c,Core_MDF_Ultimate_Account_Name__c,Core_MDF_Activity_Closure_Type__c,Budget.Core_MDF_Budget_Partner__c,
                           Core_MDF_Budget_Type_nm__c,CreatedDate,Core_MDF_End_Date_Is_Changed_ind__c,Amount,Core_MDF_ToBeClosedDate__c,Core_MDF_Program__c,Core_MDF_End_Date__c,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Actual_closedt_beforeclosure_dt__c,
                           Core_MDF_Is_Outcome_Based_Ind__c, Core_MDF_Activity_Level_nm__c, Core_MDF_Parent_Activity_Id__c // Added outcome-based fields
                           FROM PartnerFundRequest 
                           WHERE Id =: actId LIMIT 1]; 
            }
            
            if(pfrList != null && !pfrList.isEmpty()){
                // For EEF Validation with Allocation
                if(pfrList[0].Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM){
                    returnMsg = validatePfrWithAllocationForAutoTransfer(pfrList[0], true);
                }
                // Check if this is an outcome-based parent activity
                if(isOutcomeBasedParentActivity(pfrList[0])) {
                    // Handle outcome-based activity reopening
                    returnMsg = handleOutcomeBasedActivityReopen(pfrList[0], reopenStatus);
                } else {
                    // Handle regular activity reopening (existing logic)
                    returnMsg = handleRegularActivityReopen(pfrList[0], reopenStatus);
                }
            }
        }catch(Exception ex){
            Core_MDF_CCP_UtilityClass.logError(ex);
            return ex.getMessage();
        }
        return returnMsg;
    }
    
    /**
     * @description Check if the activity is an outcome-based parent activity
     * @param activity The PartnerFundRequest record to check
     * @return Boolean True if it's an outcome-based parent activity
     */
    private static Boolean isOutcomeBasedParentActivity(PartnerFundRequest activity) {
        return (activity.Core_MDF_Is_Outcome_Based_Ind__c == true && 
                (activity.Core_MDF_Activity_Level_nm__c == null || activity.Core_MDF_Activity_Level_nm__c != 'Sub Activity'));
    }

    /**
     * @description Handle reopening of outcome-based activities with sub-activities
     * @param parentActivity The parent activity to reopen
     * @param reopenStatus The reopen status flag
     * @return String Success message or error message
     */
    private static String handleOutcomeBasedActivityReopen(PartnerFundRequest parentActivity, String reopenStatus) {
        try {
            Map<Id,String> accIdRegMap = new Map<Id,String>();
            accIdRegMap.put(parentActivity.ChannelPartnerId, parentActivity.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Geo__c);
            Core_MDF_Process_PartnerFundRequest.accIdRegionMap = accIdRegMap;
            List<PartnerFundRequest> subActivities = [SELECT Id, Core_MDF_Fund_Request_Status__c, Core_MDF_Manual_Closure_Prior_Status_txt__c,Core_MDF_ATF_Flag_nm__c, Core_MDF_Start_Date__c, Core_MDF_Activity_Closure_Type__c, Core_MDF_Activity_Reimbursement_Amt_nbr__c, Amount, Core_MDF_ToBeClosedDate__c, Core_MDF_Actual_closedt_beforeclosure_dt__c, RecordType.DeveloperName, Core_MDF_Budget_Type_nm__c, Core_MDF_End_Date__c, CreatedDate, Core_MDF_Program__c, Core_MDF_Proposal_Based_Ind__c FROM PartnerFundRequest WHERE Core_MDF_Parent_Activity_Id__c = :parentActivity.Id AND Core_MDF_Activity_Level_nm__c = 'Sub Activity' AND Core_MDF_Fund_Request_Status__c = 'Closed'];
            
            List<PartnerFundRequest> activitiesToUpdate = new List<PartnerFundRequest>();
            // Process parent activity - keep amount as 0
            PartnerFundRequest updatedParent = processActivityReopen(parentActivity, reopenStatus);
            // Ensure parent amount stays 0
            updatedParent.Amount = 0;
            activitiesToUpdate.add(updatedParent);
            // Process each sub-activity
            for(PartnerFundRequest subActivity : subActivities) {
                PartnerFundRequest updatedSubActivity = processActivityReopen(subActivity, reopenStatus);
                activitiesToUpdate.add(updatedSubActivity);
            }
            if(!activitiesToUpdate.isEmpty()) {
                update activitiesToUpdate;
            }
            return 'success';
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            return e.getMessage();
        }
    }
    
    /**
     * @description Handle reopening of regular (non-outcome-based) activities
     * @param activity The activity to reopen
     * @param reopenStatus The reopen status flag
     * @return String Success message or error message
     */
    private static String handleRegularActivityReopen(PartnerFundRequest activity, String reopenStatus) {
        try {
            Map<Id,String> accIdRegMap = new Map<Id,String>();
            accIdRegMap.put(activity.ChannelPartnerId, activity.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Geo__c);
            Core_MDF_Process_PartnerFundRequest.accIdRegionMap = accIdRegMap;
            
            PartnerFundRequest updatedActivity = processActivityReopen(activity, reopenStatus);
            update updatedActivity;
            
            return 'success';
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            return e.getMessage();
        }
    }
    
    /**
     * @description Process individual activity reopening logic
     * @param activity The activity to process
     * @param reopenStatus The reopen status flag
     * @return PartnerFundRequest Updated activity record
     */
    private static PartnerFundRequest processActivityReopen(PartnerFundRequest activity, String reopenStatus) {
        Map<String,Date> quarterEndMap = new Map<String,Date>();
        List<PartnerFundRequest> tempList = new List<PartnerFundRequest>{activity};
        
        quarterEndMap = getActClosureDate(tempList);
        String autoClosurekeyStr = Core_MDF_Process_PartnerFundRequest.buildKeyForActivityClosure(activity, activity.RecordType.DeveloperName);
        activity.Core_MDF_ToBeClosedDate__c = quarterEndMap.get(autoClosurekeyStr);
        
        List<PartnerFundRequestHistory> pfrHistoryList = new List<PartnerFundRequestHistory>();
        
        if(activity.Core_MDF_ToBeClosedDate__c < system.today() && activity.Core_MDF_ATF_Flag_nm__c != null && activity.Core_MDF_ATF_Flag_nm__c.contains(System.Label.Core_MDF_ATF_Closed_Status)){
             pfrHistoryList = [select Id,NewValue,OldValue,Field,PartnerFundRequestId 
                               from PartnerFundRequestHistory 
                               Where Field = 'Core_MDF_ToBeClosedDate__c' AND PartnerFundRequestId = :activity.Id 
                               order By CreatedDate Desc Limit 1];
            if(pfrHistoryList != null && !pfrHistoryList.isEmpty()){
                PartnerFundRequestHistory pfrHistory = pfrHistoryList[0];
                Date oldValueDate = (Date)pfrHistory.OldValue;
                activity.Core_MDF_ToBeClosedDate__c = (oldValueDate == null) ? (Date)pfrHistory.NewValue : (oldValueDate >= System.today()) ? oldValueDate : getCloseDate(activity);
            }
            else
            {
                activity.Core_MDF_ToBeClosedDate__c = getCloseDate(activity);
            }
        }
        
        if(string.isNotBlank(activity.Core_MDF_Manual_Closure_Prior_Status_txt__c)){
            activity.Core_MDF_Fund_Request_Status__c = activity.Core_MDF_Manual_Closure_Prior_Status_txt__c;
        }
        
        if(activity.Core_MDF_Budget_Type_nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_RSAMD_UnTranslated') &&
           !cmpBudgetType.contains(activity.Core_MDF_Budget_Type_nm__c) && activity.Core_MDF_Budget_Type_nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CoGTM_BudgetType')){
            activity.Amount = activity.Core_MDF_Activity_Reimbursement_Amt_nbr__c;
        }
        
        if(activity.Core_MDF_Start_Date__c < System.today()){
            if(string.isBlank(activity.Core_MDF_ATF_Flag_nm__c)){
                activity.Core_MDF_ATF_Flag_nm__c = reopenStatus;
            }
            else if(!activity.Core_MDF_ATF_Flag_nm__c.contains(reopenStatus))
            {
                activity.Core_MDF_ATF_Flag_nm__c = activity.Core_MDF_ATF_Flag_nm__c+';'+reopenStatus;
            }
        } 
        
        // While reopening the activity we made the Activity Closure Type field as Blank
        if(activity.Core_MDF_Activity_Closure_Type__c != ''){
            activity.Core_MDF_Activity_Closure_Type__c = '';
            activity.Core_MDF_Actual_closedt_beforeclosure_dt__c = null;
        }
        
        return activity;
    }
    
    Public static Date getCloseDate(PartnerFundRequest pfr){
        string program = pfr.Core_MDF_Program__c;
        boolean isProposalBased =pfr.Core_MDF_Proposal_Based_Ind__c;
        Integer dateCount = 0;
        date activityCloseDate;
        DateTime createdDateTime = pfr.CreatedDate;
        Date creationdate = createdDateTime.date();
        List<Core_MDF_CCP_Submission_Window__mdt> ClaimActAllocRecTypeList = Core_MDF_CCP_Submission_Window__mdt.getAll().values();
        for(Core_MDF_CCP_Submission_Window__mdt mtrecord : ClaimActAllocRecTypeList){
            //Avoid Deeply Nested IF Statements
                if(string.isNotBlank(program) && mtrecord.Core_MDF_Program__c == program && (mtrecord.Core_MDF_Budget_Type__c == pfr.Core_MDF_Budget_Type_nm__c || mtrecord.Core_MDF_Budget_Type__c == 'NA' || mtrecord.Core_MDF_Budget_Type__c != null)) {
                    //ATF flow past dated activity
                    if(mtrecord.Core_MDF_Closure_Date_Extension__c != null && mtrecord.Core_MDF_Closure_Date_Extension__c > 0){
                        dateCount = (Integer)mtrecord.Core_MDF_Closure_Date_Extension__c;
                        activityCloseDate = creationdate.addDays(dateCount);
                        break;
                    }
                    else
                    { 
                        activityCloseDate = Core_MDF_Process_PartnerFundRequest.getActSubDueDate(pfr.Core_MDF_End_Date__c, mtrecord);
                        break;
                    }
                }
        }
        
        return activityCloseDate;
    }    
    
    //Used Only for RMF to calculate EndDate based on Quarter EndDate.
    Public static Map<String,Date> getActClosureDate(List<PartnerFundRequest> pfrList){
        
        Map<string,Integer> metadtMap = new Map<string,Integer>();
        Map<Id,string> ccpRecordTypeIds = new Map<Id,string>();
        Map<String,Date> quarterEndRsltMap = new Map<String,Date>();
        Map<String, Date> quarterEndDateMap = new Map<String, Date>();
        
        try{
            string autoClosurekey = Core_MDF_Process_PartnerFundRequest.buildKeyForActivityClosure(pfrList[0],pfrList[0].RecordType.DeveloperName);
            quarterEndDateMap.put(autoClosurekey, null);
            
            quarterEndRsltMap = Core_MDF_Process_PartnerFundRequest.getActivitySubDueDate(quarterEndDateMap);
        }catch(Exception ex){
            
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return quarterEndRsltMap;
    }
    /*****************************************************************************
    Method Name :   isRetailAccountBasedOrEGF
    @return     :   Boolean
    @parameters :   Activity record
    Description :   Returns true if the incoming actvity's program is RMF/IPA-Account based/EGF
    Added By    :   Aswin Selvaraj
    Modified By :                      Date:07/Feb/2024                     Changes:None
 * ***************************************************************************/
    public static Boolean isRetailAccountBasedOrEEF(PartnerFundRequest pfr){
        Boolean isRetailAccountBasedOrEEF = false;
        if((pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM && pfr.Core_MDF_Proposal_Based_Ind__c == false && pfr.Core_MDF_Is_Outcome_Based_Ind__c == false) || 
           (pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM && pfr.Core_MDF_Budget_Type_nm__c==Core_MDF_CCP_ConstantClass.EEF_BUDGET_TYPE) ||
           pfr.Core_MDF_Budget_Type_nm__c == System.Label.Core_MDF_RetailMDF_BudgetType){
               isRetailAccountBasedOrEEF = true;
           }
        return isRetailAccountBasedOrEEF;
    }    
    /*****************************************************************************
    Method Name :   validateActivityWithCampaign
    @return     :   Campaign Full stack validation
    @parameters :   Activity record
    Description :   Returns error message when incoming pfr's Intel contribution is more than the campaign amount
    Modified By :   Aswin Selvaraj            Date:07/Feb/2024  Changes:Enhanced the camp full stack validation to support EEF program
    ****************************************************************************/
    public static string validateActivityWithCampaign(PartnerFundRequest pfr){
        
        string returnMsg = 'success';
        Map<Id, PartnerFundRequest> cmpEEFBudgetPfrMap = new Map<Id, PartnerFundRequest>();
        Map <Id,Decimal> pfrToClaimAmtMap = new Map<Id,Decimal>();
        Map <Id,Decimal> pfrToEscalationAmtMap = new Map<Id,Decimal>();
        string IPA_PROG = Core_MDF_CCP_ConstantClass.IPA_PROGRAM;
        
        Map<String,Id> campaignIdBudgetTypeToBudgetIdMap = new Map<String,Id>();
        Map<String,Decimal> budgetAgainstAmountMap = new Map<String,Decimal>();
        Set<Id> ipaAccBasedRMFEEFCampIdSet = new Set<Id>();
        Set<Id> campaignIdSet = new Set<Id>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        
        List<String> cmpBudgetTypeList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CMP_BudgetType') != null 
            ? Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CMP_BudgetType').split(';') : null;
        
        Map<String,Decimal> cmpIdBudgetIdBudgetTypeToAmountMap = new Map<String,Decimal>();
        List<String> opalBudgetTypeList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_OPAL_BudgetTypes').Split(';');
        List<string> pfcCloseStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimStatus_ActivityAutoClose').split(';');
        List<Campaign> campReimbAmount = new List<Campaign>();
        
        Decimal eefAmount = 0;
        Decimal rmfAmount = 0;
        Decimal pfrCampaignAmtAccount = 0;
        Decimal pfrCampAmount = 0;
        
        Boolean isRMF = false;
        Boolean isEEF = false;
        Boolean isIPAAccountBased = false;
        Boolean isIPARetailEEF =false;
        Boolean checkCampaignError = false;
        
        try{
            if(opalBudgetTypeList.contains(pfr.Core_MDF_Budget_Type_nm__c)){
                String campaignIdBudgetType = string.valueOf(pfr.CampaignId)+pfr.Core_MDF_Budget_Type_nm__c;
                campaignIdBudgetTypeToBudgetIdMap.put(campaignIdBudgetType, pfr.BudgetId);
                checkCampaignError = true;
                campaignIdSet.add(pfr.CampaignId);
            }
            else if(isRetailAccountBasedOrEEF(pfr)){
                String campaignIdBudgetType = string.valueOf(pfr.CampaignId)+pfr.Core_MDF_Budget_Type_nm__c;
                campaignIdBudgetTypeToBudgetIdMap.put(campaignIdBudgetType, pfr.BudgetId);
                pfrCampAmount =  pfr.Core_MDF_Campaign_Amount__c;                                                                     
                checkCampaignError = true;
                isIPARetailEEF = true; 
                ipaAccBasedRMFEEFCampIdSet.add(pfr.CampaignId);
            }
            /*else if(pfr.Core_MDF_Program__c == IPA_PROG && !pfr.Core_MDF_Proposal_Based_Ind__c){
                isIPAAccountBased = true;
                String campaignIdBudgetType = string.valueOf(pfr.CampaignId)+pfr.Core_MDF_Budget_Type_nm__c;
                campaignIdBudgetTypeToBudgetIdMap.put(campaignIdBudgetType, pfr.BudgetId);
                pfrCampaignAmtAccount =(Decimal)pfr.Campaign.Core_MDF_Reimbursement_Amt__c;
                checkCampaignError = true;
                ipaAccBasedRMFEEFCampIdSet.add(pfr.CampaignId);
            }
            else if(pfr.Core_MDF_Budget_Type_nm__c == 'Retail MDF'){                                                              
                String campaignIdBudgetType = string.valueOf(pfr.CampaignId)+pfr.Core_MDF_Budget_Type_nm__c;
                campaignIdBudgetTypeToBudgetIdMap.put(campaignIdBudgetType, pfr.BudgetId);
                rmfAmount =  pfr.Core_MDF_Campaign_Amount__c;                                                                     
                checkCampaignError = true;isRMF = true; 
                ipaAccBasedRMFEEFCampIdSet.add(pfr.CampaignId);
            } 
            else if(pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM){                                                              
                String campaignIdBudgetType = string.valueOf(pfr.CampaignId)+pfr.Core_MDF_Budget_Type_nm__c;
                campaignIdBudgetTypeToBudgetIdMap.put(campaignIdBudgetType, pfr.BudgetId);
                eefAmount =  pfr.Core_MDF_Campaign_Amount__c;                                                                     
                checkCampaignError = true;isEEF = true; 
                ipaAccBasedRMFEEFCampIdSet.add(pfr.CampaignId);
            }*/ 
            
            if(campaignIdBudgetTypeToBudgetIdMap != NULL && campaignIdBudgetTypeToBudgetIdMap.Size() > 0){
                Map<Id, Decimal> allocationInDraftState = new Map<Id, Decimal>();
                Map<Id, Decimal> finalAllocationAmountMap = new Map<Id, Decimal>();
                map<Id, Decimal> allocationIdToAllocatedAmountMap = new Map<Id,Decimal>();
                
                
                if(/*!isRMF && !isIPAAccountBased && !isEEF*/ !isIPARetailEEF){  
                    for(Core_MDF_Campaign_Budgets__c campBudget : [SELECT Id, Core_MDF_Reimbursement_Amt__c, Core_MDF_Budget_Type_Nm__c,
                                                                   Core_MDF_Campaign_Id__c,Core_MDF_Budget_Name_Id__c
                                                                   FROM Core_MDF_Campaign_Budgets__c
                                                                   WHERE Core_MDF_Budget_Name_Id__c IN: campaignIdBudgetTypeToBudgetIdMap.values() AND
                                                                   Core_MDF_Campaign_Id__c =: pfr.CampaignId]){
                                                                       String cmpIdBudgetIdBudgetType = String.ValueOf(campBudget.Core_MDF_Campaign_Id__c) + campBudget.Core_MDF_Budget_Name_Id__c + campBudget.Core_MDF_Budget_Type_Nm__c;
                                                                       cmpIdBudgetIdBudgetTypeToAmountMap.put(cmpIdBudgetIdBudgetType, campBudget.Core_MDF_Reimbursement_Amt__c);             
                                                                   }
                    
                }
                
                for(PartnerFundRequest pfrObj : [SELECT Id, BudgetId, ChannelPartnerId, Core_MDF_Activity_Reimbursement_Amt_nbr__c,Core_MDF_Fund_Request_Status__c, CampaignId, Core_MDF_Budget_Type_nm__c,Amount, Core_MDF_Proposal_Based_Ind__c,Core_MDF_Program__c
                                                 FROM PartnerFundRequest
                                                 WHERE ((BudgetId IN: campaignIdBudgetTypeToBudgetIdMap.values() AND CampaignId IN: campaignIdSet)
                                                        OR CampaignId IN: ipaAccBasedRMFEEFCampIdSet)
                                                 AND Core_MDF_Fund_Request_Status__c != 'Cancelled' AND Id !=: pfr.Id]){
                                                     //looping through other activities for the campaign
                                                     String cmpIdBudgetIdBudgetType = String.ValueOf(pfrObj.CampaignId) + pfrObj.BudgetId + pfrObj.Core_MDF_Budget_Type_nm__c;
                                                     String campaignIdBudgetType = string.valueOf(pfrObj.CampaignId) + pfrObj.Core_MDF_Budget_Type_nm__c;
                                                     Boolean isCmpEEFBudget = false;
                                                     
                                                     if((cmpBudgetTypeList != null && cmpBudgetTypeList.contains(pfrObj.Core_MDF_Budget_Type_nm__c)) || 
                                                       pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM){
                                                         isCmpEEFBudget = true;
                                                        
                                                         if(pfrObj.Core_MDF_Fund_Request_Status__c == 'Closed'){
                                                             cmpEEFBudgetPfrMap.put(pfrObj.Id,pfrObj);
                                                         }   
                                                     }
                                                     if((budgetAgainstAmountMap.containsKey(cmpIdBudgetIdBudgetType) ||  budgetAgainstAmountMap.containsKey(campaignIdBudgetType))
                                                        && pfrObj.Amount != null){
                                                            decimal amount = 0;
                                                            if((pfrObj.Core_MDF_Program__c == IPA_PROG && pfrObj.Core_MDF_Proposal_Based_Ind__c == false) || 
                                                               pfr.Core_MDF_Budget_Type_nm__c == 'Retail MDF'){
                                                                amount += budgetAgainstAmountMap.get(campaignIdBudgetType);// map to store total of amounts on pfr for each camp+budgettype
                                                            } else {
                                                                amount += budgetAgainstAmountMap.get(cmpIdBudgetIdBudgetType);
                                                            }
                                                            if(isCmpEEFBudget){
                                                                if(pfrObj.Core_MDF_Fund_Request_Status__c != 'Closed'){ 
                                                                    amount += pfrObj.Core_MDF_Activity_Reimbursement_Amt_nbr__c;
                                                                }
                                                            }else{
                                                                amount += pfrObj.Amount;
                                                            } 
                                                            
                                                            if((pfrObj.Core_MDF_Program__c == IPA_PROG && pfrObj.Core_MDF_Proposal_Based_Ind__c == false) || 
                                                               pfr.Core_MDF_Budget_Type_nm__c == 'Retail MDF'){
                                                                budgetAgainstAmountMap.put(campaignIdBudgetType, amount);// map to store total of amounts on pfr for each camp+budgettype
                                                            } else {
                                                         budgetAgainstAmountMap.put(cmpIdBudgetIdBudgetType, amount);
                                                            }
                                                         
                                                     }else{
                                                         if(pfrObj.Amount != null){
                                                             decimal amount = 0;
                                                             if(isCmpEEFBudget){
                                                                 if(pfrObj.Core_MDF_Fund_Request_Status__c != 'Closed'){
                                                                     amount = pfrObj.Core_MDF_Activity_Reimbursement_Amt_nbr__c;
                                                                 }
                                                             }else{
                                                                 amount = pfrObj.Amount;
                                                             } 
                                                                
                                                                if((pfrObj.Core_MDF_Program__c == IPA_PROG && pfrObj.Core_MDF_Proposal_Based_Ind__c == false) || 
                                                               		pfr.Core_MDF_Budget_Type_nm__c == 'Retail MDF'){
                                                                    budgetAgainstAmountMap.put(campaignIdBudgetType, amount);// map to store total of amounts on pfr for each camp+budgettype
                                                                } else {
                                                             budgetAgainstAmountMap.put(cmpIdBudgetIdBudgetType, amount);
                                                                }
                                                             
                                                         }    
                                                     }
                                                 }
                
                
                if(cmpEEFBudgetPfrMap != NULL && cmpEEFBudgetPfrMap.keyset() != null && !cmpEEFBudgetPfrMap.isEmpty()){
                    
                    for(AggregateResult pfc : [SELECT RequestId Id ,sum(Amount)amt
                                               FROM PartnerFundClaim 
                                               WHERE RequestId IN:cmpEEFBudgetPfrMap.keyset() AND Core_MDF_Status__c IN:pfcCloseStatus  
                                               AND Core_MDF_Type_Txt__c =: TYPE_CLAIM AND Core_MDF_Escalation_Id__c = null 
                                               GROUP BY RequestId]){ 
                                                   ID pfrID =(Id)pfc.get('Id');    
                                                   Decimal pfrClaimedAmount =(Decimal)pfc.get('amt');
                                                   pfrToClaimAmtMap.put(pfrID,pfrClaimedAmount);
                                               }
                    
                    for(AggregateResult esc : [SELECT Core_MDF_Co_Marketing_Activity_id__c Id,sum(Core_MDF_Approved_Amount_amt__c)amt
                                               FROM Core_MDF_Escalation__c
                                               WHERE Core_MDF_Co_Marketing_Activity_id__c IN:cmpEEFBudgetPfrMap.keyset() AND Core_MDF_Escalation_Status_nm__c =: ESC_APPROVED_STATUS
                                               GROUP BY Core_MDF_Co_Marketing_Activity_id__c]){
                                                   ID pfrID =(Id)esc.get('Id');
                                                   Decimal pfrEscAmount =(Decimal)esc.get('amt');
                                                   pfrToEscalationAmtMap.put(pfrID,pfrEscAmount); 
                                               }
                    
                    
                    for(PartnerFundRequest pfrObj: cmpEEFBudgetPfrMap.Values()){
                        decimal totalEscAmt = 0.0;
                        decimal totalClaimedAmt = 0.0;
                        decimal totalClaimEscConsumedAmt = 0.0;
                        decimal amount = 0.0;

                        String cmpIdBudgetIdBudgetType = String.ValueOf(pfrObj.CampaignId) + pfrObj.BudgetId + pfrObj.Core_MDF_Budget_Type_nm__c;
                        if(pfrObj.Amount != null){
                            totalEscAmt = pfrToEscalationAmtMap.containskey(pfrObj.Id) ? pfrToEscalationAmtMap.get(pfrObj.Id) : 0;
                            totalClaimedAmt = pfrToClaimAmtMap.containskey(pfrObj.Id) ? pfrToClaimAmtMap.get(pfrObj.Id) : 0;
                            totalClaimEscConsumedAmt = totalEscAmt + totalClaimedAmt;
                            amount = totalClaimEscConsumedAmt >= pfrObj.Core_MDF_Activity_Reimbursement_Amt_nbr__c
                                ? pfrObj.Core_MDF_Activity_Reimbursement_Amt_nbr__c : totalClaimEscConsumedAmt;

                            if(budgetAgainstAmountMap.containsKey(cmpIdBudgetIdBudgetType)){
                               amount += budgetAgainstAmountMap.get(cmpIdBudgetIdBudgetType);
                                budgetAgainstAmountMap.put(cmpIdBudgetIdBudgetType, amount);
                            }else{
                                budgetAgainstAmountMap.put(cmpIdBudgetIdBudgetType, amount); 
                            }                                                                        
                        }
                    }
                    
                }

                string campaignBudgetkey = pfr.CampaignId+pfr.Core_MDF_Budget_Type_nm__c;
                String campaignIdBudgetType = string.valueOf(pfr.CampaignId) + pfr.Core_MDF_Budget_Type_nm__c;
                if(campaignIdBudgetTypeToBudgetIdMap.containsKey(campaignBudgetkey) && campaignIdBudgetTypeToBudgetIdMap.get(campaignBudgetkey) != NULL){
                    
                    Id budgetId = pfr.BudgetId;                  
                    String cmpIdBudgetIdBudgetType = String.ValueOf(pfr.CampaignId) + pfr.BudgetId + pfr.Core_MDF_Budget_Type_nm__c;
                    
                    decimal amountOnBudget = 0;
                    if(isIPARetailEEF){
                        amountOnBudget = pfrCampAmount;
                    }
                    /*if(isRMF){
                        amountOnBudget =   rmfAmount  ; 
                    }
                    else if(isIPAAccountBased){
                        amountOnBudget = pfrCampaignAmtAccount;
                    }
                    else if(isEEF){
                        amountOnBudget = eefAmount;
                    }*/
                    else{
                        amountOnBudget  =  cmpIdBudgetIdBudgetTypeToAmountMap.get(cmpIdBudgetIdBudgetType);                
                    }
                    decimal existingPfrAmount = 0;
                    if(((pfr.Core_MDF_Program__c == IPA_PROG && pfr.Core_MDF_Proposal_Based_Ind__c == false) || 
                       pfr.Core_MDF_Budget_Type_nm__c == 'Retail MDF')
                       && budgetAgainstAmountMap.containsKey(campaignIdBudgetType)){
                           existingPfrAmount += budgetAgainstAmountMap.get(campaignIdBudgetType);//sum of amount on other activities
                       } else {
                           if(budgetAgainstAmountMap.containsKey(cmpIdBudgetIdBudgetType)){
                               existingPfrAmount += budgetAgainstAmountMap.get(cmpIdBudgetIdBudgetType);
                           }
                       }
                    
                    decimal currentActivityAmount = pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c;
                    decimal finalAmountForCompare = existingPfrAmount != NULL ? 
                        (existingPfrAmount + currentActivityAmount) : currentActivityAmount;
                    
                    if(finalAmountForCompare > amountOnBudget && checkCampaignError){+
                        returnMsg = Label.Core_MDF_OPAL_Amount_Validation_Error;
                    }
                } 
            }  
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e); returnMsg = e.getMessage();
        } 
        
        return returnMsg;
        
    }

    /*****************************************************************************
    Method Name :   validatePfrWithAllocationForAutoTransfer
    @return     :   
    @parameters :   Activity record, isAutoTransferRequired
    Description :   Returns error message when auto transfer is not available at CSP VC
    Modified By :   Saikat           Date:04-04-2024  
    ****************************************************************************/
    public static string validatePfrWithAllocationForAutoTransfer(PartnerFundRequest pfr, Boolean isAutoTransferRequired){
        string returnMsg = 'success';
        Decimal reimbursementAmt = 0.0;
        Decimal totalActivityConsumedAmt = 0.0;
        Decimal amountToBeReopen = 0.0;
        Decimal remainingReopenAmount = 0.0;
        Set<Id> accountIds = new Set<Id>();
        Set<Id> budgetIds = new Set<Id>();
        Map<String, Decimal> activatingAccIdBudIdToAllocAvailAmtMap = new Map<String, Decimal>();
        List<Core_MDF_BudgetTransferWrapper> budgetTransferWrapperList = new List<Core_MDF_BudgetTransferWrapper>();
        
        try{
            budgetIds.add(pfr.BudgetId);
            accountIds.add(pfr.ChannelPartnerId);
            accountIds.add(pfr.Budget.Core_MDF_Budget_Partner__c);

            if(!budgetIds.isEmpty() && !accountIds.isEmpty()){
                for(PartnerFundAllocation pfa : [SELECT Id, Amount, ChannelPartnerId, BudgetId, Core_MDF_Available_Activity_Alloc_Amt__c
                                                 FROM PartnerFundAllocation
                                                 WHERE ChannelPartnerId IN: accountIds 
                                                 AND BudgetId IN: budgetIds]){
                    String accIdBudgetIdKey = (String)pfa.ChannelPartnerId + (String)pfa.BudgetId;
                    activatingAccIdBudIdToAllocAvailAmtMap.put(accIdBudgetIdKey, pfa.Core_MDF_Available_Activity_Alloc_Amt__c);
                }
            }

            String pfrAccIdBudgetIdKey = (String)pfr.ChannelPartnerId + (String)pfr.BudgetId;
            //String primaryAccIdBudgetIdKey = (String)pfr.Core_MDF_Budget_Channel_Partner__c + (String)pfr.BudgetId;
            String primaryAccIdBudgetIdKey = (String)pfr.Budget.Core_MDF_Budget_Partner__c + (String)pfr.BudgetId;

            reimbursementAmt = pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c;
            totalActivityConsumedAmt = pfr.Amount;
            //This is the amount which we need to auto transfer if the amount is not available on the activity allocation
            amountToBeReopen = (reimbursementAmt - totalActivityConsumedAmt);

            if(!activatingAccIdBudIdToAllocAvailAmtMap.isEmpty()
                && activatingAccIdBudIdToAllocAvailAmtMap.containsKey(pfrAccIdBudgetIdKey)
                && activatingAccIdBudIdToAllocAvailAmtMap.get(pfrAccIdBudgetIdKey) != null
                && amountToBeReopen > activatingAccIdBudIdToAllocAvailAmtMap.get(pfrAccIdBudgetIdKey)){
                    remainingReopenAmount = amountToBeReopen - activatingAccIdBudIdToAllocAvailAmtMap.get(pfrAccIdBudgetIdKey);
                    // Show error if CSP allocation activity available amount is lesser than Pfr Amount
                    if(activatingAccIdBudIdToAllocAvailAmtMap.containsKey(primaryAccIdBudgetIdKey)
                       && activatingAccIdBudIdToAllocAvailAmtMap.get(primaryAccIdBudgetIdKey) != null
                       && remainingReopenAmount > activatingAccIdBudIdToAllocAvailAmtMap.get(primaryAccIdBudgetIdKey)){
                        returnMsg = Label.Core_MDF_AutoBudgetTransfer_ErrorMsg;
                    } else if(isAutoTransferRequired) {
                        budgetTransferWrapperList.add(new Core_MDF_BudgetTransferWrapper(pfr.Budget.Core_MDF_Budget_Partner__c,
                                                      pfr.ChannelPartnerId, pfr.BudgetId, remainingReopenAmount,
                                                      Core_MDF_CCP_ConstantClass.AUTO_ACTIVITY_TRANSFER_TYPE, pfr.Id, false));                   
                    }
            }
            if(!budgetTransferWrapperList.isEmpty() && budgetTransferWrapperList.size() > 0) {
                returnMsg = Core_MDF_BudgetTransferUtility.budgetTransfer(budgetTransferWrapperList);
                returnMsg = returnMsg == 'Success' ? 'success' : returnMsg;
            }
        } catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e); returnMsg = e.getMessage();
        }
        return returnMsg;
    }
    
    /**
     * @description Wrapper class for sub-activity validation results
     */
    public class SubActivityValidationResult {
        public Id subActivityId { get; set; }
        public Decimal claimedAmount { get; set; }
        public Decimal escAmount { get; set; }
        public Decimal reimbursementAmount { get; set; }
        public Decimal allocationAvailAmount { get; set; }
        public Decimal availableAmount { get; set; }
        public Boolean hasError { get; set; }
        public String errorMessage { get; set; }
        
        public SubActivityValidationResult() {
            this.claimedAmount = 0;
            this.escAmount = 0;
            this.reimbursementAmount = 0;
            this.allocationAvailAmount = 0;
            this.availableAmount = 0;
            this.hasError = false;
            this.errorMessage = '';
        }
    }
    
    Public class ReopenWrapper {
        Public string validationMsg {get; set;}
        Public decimal pendingClaimableAmount {get; set;}
        Public decimal totalClaimAmount {get; set;}
        Public decimal intelContribution {get; set;}
        Public ReopenWrapper() {
            validationMsg = '';
            pendingClaimableAmount = 0.0;
            totalClaimAmount = 0.0;
            intelContribution = 0.0;
        }
    }
    
}