public without sharing class Core_MDF_CloseActivity {
    
    private static String claimStatusList = System.label.Core_MDF_Claim_Status_For_Account_Inactive; 
    private static String CCFProgram = system.label.Core_MDF_CCF_Program;
    private static String DCFProgram = system.label.Core_MDF_DCF_Program_Name;
    private static list<String> claimStatusSet = new list<String>();
    private static string pfrManualClosureType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ActvityClosureType').split(';')[0];
    private static List<String> pfrBudgetType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_ActivityClose').split(';');
    private static List<string> pfcCloseStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimStatus_ActivityClose').split(';');
    private static string pfrActivityClosed = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_ClosedStatus');
    private static List<string> pfrProgramSpecific = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Close_Open_Activity_Program').split(';');
    private static string ESC_APPROVED_STATUS = Core_MDF_CCP_ConstantClass.ESC_APPROVED_STATUS;
    private static string TYPE_CLAIM = Core_MDF_CCP_ConstantClass.TYPE_CLAIM;
    	
    
    
    /****************************************************************************************************** 
Class Name:         activityCloseWrapper
@parameters:        N/A
Description:        Wrapper which will hold return values of all the validation check to close activity
Added By:           Sridhar   04-08-2019
Modified By:        Date:      Changes: 
Nuzhath				11-3-2019		Added an attribute for retail program
*******************************************************************************************************/
    public class activityCloseWrapper{   	
        @AuraEnabled
        public boolean isValidActivity=false;
        @AuraEnabled
        public boolean hasActiveClaims=false;
        @AuraEnabled
        public List<PartnerFundClaim> listOfClaim = new List<PartnerFundClaim>();
        @AuraEnabled
        public boolean isValidActStatus=true;
        @AuraEnabled
        public boolean activityNotStarted=false;
        @AuraEnabled
        public boolean retailActivity = false;
        @AuraEnabled
        public boolean ipaActivity = false;
        
        
    }
    
    
    /****************************************************************************************************** 
Method Name:        userEligibilitytoIncloseActivity
@return  :          Boolean whether the user has permission or not.
@parameters:        Allowed permission sets
Description:        This method is used to check if user has permission to close the activity.
Added By:           Sridhar - 03/04/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/  
    @AuraEnabled
    Public static Boolean userEligibilitytoIncloseActivity(Map<string,List<string>> permissionsets){
        Boolean eligibleUser=false;
        Core_MDF_PartnerFundRequestCreatePage.userPermissionSetWrapper permissionWrapper = new Core_MDF_PartnerFundRequestCreatePage.userPermissionSetWrapper();
        Map<string,boolean> perMap = new Map<string,boolean>();
       
        try {
            
            permissionWrapper = Core_MDF_PartnerFundRequestCreatePage.userHasPermissionSet(permissionsets);
            perMap = permissionWrapper.userPermissions;
            
            if (perMap != null)
            {
                for(string key : perMap.keySet())
                {
                    if (perMap.get(key) == true)
                    {
                        eligibleUser = true;
                        break;
                    }
                }
            }
                      
        } 
        catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}
        return eligibleUser;
    }
    
    /****************************************************************************************************** 
Method Name:        checkActivityEligibiltyForClose
@return  :          activityCloseWrapper
@parameters:        Activity Id
Description:        This method will call other methods to check for different validations
Added By:           Sridhar - 03/04/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public  static activityCloseWrapper checkActivityEligibiltyForClose (Id activityId ){
        
        activityCloseWrapper actWrap  = new activityCloseWrapper();
        activityCloseWrapper claimActWrap = new activityCloseWrapper();
        PartnerFundRequest activity = NULL;
        try{
            
            activity = [SELECT Id, Amount,campaign.Core_MDF_Program__c,Core_MDF_Activity_Reimbursement_Amt_nbr__c,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Start_Date__c, Core_MDF_Budget_Type_nm__c,Core_MDF_Fund_Request_Status__c,Core_MDF_Program__c,Core_MDF_ToBeClosedDate__c,Core_MDF_Actual_closedt_beforeclosure_dt__c, Core_MDF_Is_Outcome_Based_Ind__c, Core_MDF_Activity_Level_nm__c FROM PartnerFundRequest WHERE Id =: activityId LIMIT 1];
            String actNotAllowedStatus = System.label.Core_MDF_Close_Activity_NotAllowed_ActStatus;
            List<String> actNotAllowedStatusList = new List<String>();
            actNotAllowedStatusList = actNotAllowedStatus.split(',');
            
            //Avoid Deeply Nested IF Statements
                if(activity != null && !actNotAllowedStatusList.contains(activity.Core_MDF_Fund_Request_Status__c) || 
                   (activity.Core_MDF_Fund_Request_Status__c == 'Revision Required' && activity.Core_MDF_Program__c == 'Retail Marketing Funds')
                  )
                {
                    Boolean actNotAllowedStatuss = (!(activity.Core_MDF_Start_Date__c > Date.Today()));
                    if (actNotAllowedStatuss)
                    {
                        claimActWrap = checkClaims(activityId);
                        actWrap.hasActiveClaims = claimActWrap.hasActiveClaims;
                        actWrap.listOfClaim = claimActWrap.listOfClaim.clone();
                        actWrap.isValidActivity = true; 
                    }
                    if(actNotAllowedStatuss && (actWrap != null && !actWrap.hasActiveClaims)){
                            Map<Id,PartnerFundRequest> pfrMap = new Map<Id,PartnerFundRequest>();
                            pfrMap.put(activity.Id,activity);
                            closeActivityAmountCalculation(pfrMap,pfrManualClosureType);
                    }
                    if(!actNotAllowedStatuss){
                        actWrap.activityNotStarted = true;
                    }
                    
                }                
                else
                {
                    actWrap.isValidActStatus = false;actWrap.retailActivity = activity.Core_MDF_Program__c == 'Retail Marketing Funds' ? true : false;
                    actWrap.ipaActivity= activity.Core_MDF_Program__c == 'Intel Partner Alliance' ? true : false;
                }
        }
        
        catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;//throw new AuraHandledException(e.getMessage());
                           }
        
        return actWrap; 
    }
    
    /****************************************************************************************************** 
Method Name:        checkClaims
@return  :          wrapper which will hold the values of all the validation checks.
@parameters:        N/A
Description:        This method is used to check claims associated with this activity which doesn't have end status.
Added By:           Sridhar   10/04/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    Public static activityCloseWrapper checkClaims (Id activityId){
        activityCloseWrapper checkClaimWrapper = new activityCloseWrapper ();
        if(!String.IsBlank(claimStatusList)){
            claimStatusSet = claimStatusList.split(';');
        }
        //Fetch claim status from custom label
        
        //List to store the claims which are in submitted, hold, pending available funds, payment due and pending payment status
       
        List<PartnerFundClaim> claimList = [SELECT Id FROM PartnerFundClaim WHERE RequestId =:activityId and Core_MDF_Status__c  IN:claimStatusSet];		
        if (claimList != Null && claimList.size()>0 ){
            checkClaimWrapper.hasActiveClaims = true;
            checkClaimWrapper.listOfClaim = claimList.clone();
        }
        return checkClaimWrapper;
    } 
    
    /****************************************************************************************************** 
Method Name:        closeActivityAmountCalculation
Description:        This method is used to update activity amount for manual close
Added By:           Hemapriyadharshini.k - 14/4/2022 
Modified By:   Saikat Manna     Date:   03/01/2023   Changes: 
*******************************************************************************************************/
    
    Public static List<Database.SaveResult> closeActivityAmountCalculation(Map<Id,PartnerFundRequest> pfrMap, String pfrClosureType){
        Decimal pfrReleasedAmount =0.0;
        Decimal pfrEscAmount=0.0;
        Decimal checkPfrAmount=0.0;
        Id pfrID;
        List<Database.SaveResult> pfrListAfterSave = new List<Database.SaveResult>();
        List<PartnerFundRequest> pfrClosureList = new List<PartnerFundRequest>();
        PartnerFundRequest pfrgetId = new PartnerFundRequest();
        Map<Id,Decimal> pfcMap = new Map<Id,Decimal>();
        Map<Id,Decimal> pfrToEscalationAmtMap = new Map<Id,Decimal>();
        List<String> cmpBudgetType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CMP_BudgetType').split(';');
        
        
        try{
            if(pfrMap != null && !pfrMap.isEmpty()){
                // Check if this is an outcome-based parent activity
                PartnerFundRequest parentActivity = pfrMap.values()[0];
                if(isOutcomeBasedParentActivity(parentActivity)) {
                    // Handle outcome-based activity closure
                    handleOutcomeBasedActivityClosure(pfrMap, pfrClosureType, pfrClosureList);
                } else {
                    // Handle regular activity closure (existing logic)
                    handleRegularActivityClosure(pfrMap, pfrClosureType, pfrClosureList, pfcMap, pfrToEscalationAmtMap, cmpBudgetType);
                }
            }
            if(!pfrClosureList.isEmpty()){
                //Updating PartnerFundRequest
                pfrListAfterSave = Database.update(pfrClosureList,False);
            }    
        }
        catch (Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);throw e;
        }                  
        return pfrListAfterSave;  
    }
    
    /****************************************************************************************************** 
    Method Name:        isOutcomeBasedParentActivity
    Description:        Check if the activity is an outcome-based parent activity
    Added By:           Modified for outcome-based activities
    *******************************************************************************************************/
    private static Boolean isOutcomeBasedParentActivity(PartnerFundRequest activity) {
        return (activity.Core_MDF_Is_Outcome_Based_Ind__c == true && 
                (activity.Core_MDF_Activity_Level_nm__c == null || activity.Core_MDF_Activity_Level_nm__c != 'Sub Activity'));
    }
    
    /****************************************************************************************************** 
    Method Name:        handleOutcomeBasedActivityClosure
    Description:        Handle closure of outcome-based activities with sub-activities
    Added By:           Modified for outcome-based activities
    *******************************************************************************************************/
    private static void handleOutcomeBasedActivityClosure(Map<Id,PartnerFundRequest> pfrMap, String pfrClosureType, List<PartnerFundRequest> pfrClosureList) {
        try {
            Id parentActivityId = pfrMap.keySet().iterator().next();
            PartnerFundRequest parentActivity = pfrMap.get(parentActivityId);
            
            // Get all sub-activities for this parent
            List<PartnerFundRequest> subActivities = [
                SELECT Id, Amount, Core_MDF_Maximum_Intel_Investment_amt__c, RequestedAmount, ChannelPartnerId, Core_MDF_Fund_Request_Status__c, Core_MDF_ToBeClosedDate__c,Core_MDF_Activity_Reimbursement_Amt_nbr__c,AllocationId
                FROM PartnerFundRequest WHERE Core_MDF_Parent_Activity_Id__c = :parentActivityId AND Core_MDF_Activity_Level_nm__c = 'Sub Activity'AND Core_MDF_Fund_Request_Status__c != 'Cancelled'
            ];
            // Get claims for all sub-activities
            Map<Id, Decimal> subActivityClaimAmounts = getSubActivityClaimAmounts(subActivities);
            // Process each sub-activity
            for(PartnerFundRequest subActivity : subActivities) {
                Decimal claimAmount = subActivityClaimAmounts.containsKey(subActivity.Id) ? subActivityClaimAmounts.get(subActivity.Id) : 0;
                // Update sub-activity amount based on claims
                PartnerFundRequest updatedSubActivity = updatedPfr(subActivity, pfrClosureType, claimAmount);
                pfrClosureList.add(updatedSubActivity);
            }
            
            // Calculate total claim amount for parent activity
            Decimal totalClaimAmount = 0;
            // Update parent activity
            PartnerFundRequest updatedParentActivity = updatedPfr(parentActivity, pfrClosureType, totalClaimAmount);
            pfrClosureList.add(updatedParentActivity);
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            throw e;
        }
    }
    
    /****************************************************************************************************** 
    Method Name:        getSubActivityClaimAmounts
    Description:        Get claim amounts for sub-activities
    Added By:           Modified for outcome-based activities
    *******************************************************************************************************/
    private static Map<Id, Decimal> getSubActivityClaimAmounts(List<PartnerFundRequest> subActivities) {
        Map<Id, Decimal> claimAmounts = new Map<Id, Decimal>();
        Set<Id> subActivityIds = new Set<Id>();
        for(PartnerFundRequest subActivity : subActivities) {
            subActivityIds.add(subActivity.Id);
        }
        // Get claim amounts for sub-activities
        for(AggregateResult ar : [
            SELECT RequestId, SUM(Amount) totalAmount FROM PartnerFundClaim WHERE RequestId IN :subActivityIds AND Core_MDF_Status__c IN :pfcCloseStatus AND Core_MDF_Escalation_Id__c = null AND Core_MDF_Type_Txt__c = :TYPE_CLAIM GROUP BY RequestId]) {
            Id requestId = (Id)ar.get('RequestId');
            Decimal totalAmount = (Decimal)ar.get('totalAmount');
            claimAmounts.put(requestId, totalAmount != null ? totalAmount : 0);
        }
        return claimAmounts;
    }
    
    /****************************************************************************************************** 
    Method Name:        handleRegularActivityClosure
    Description:        Handle closure of regular (non-outcome-based) activities - existing logic
    Added By:           Modified for outcome-based activities
    *******************************************************************************************************/
    private static void handleRegularActivityClosure(Map<Id,PartnerFundRequest> pfrMap, String pfrClosureType, 
                                                   List<PartnerFundRequest> pfrClosureList, Map<Id,Decimal> pfcMap, 
                                                   Map<Id,Decimal> pfrToEscalationAmtMap, List<String> cmpBudgetType) {
        Decimal pfrReleasedAmount = 0.0;
        Decimal pfrEscAmount = 0.0;
        Decimal checkPfrAmount = 0.0;
        Id pfrID;
        PartnerFundRequest pfrgetId = new PartnerFundRequest();
        
        //Iterating AggregateResult to get claim amount and activity Id(requestId)      
        for(AggregateResult pfcAmountMaps : [SELECT RequestId Id ,sum(Amount)amt 
                                             FROM PartnerFundClaim 
                                             WHERE RequestId IN:pfrMap.keyset() AND Core_MDF_Status__c IN:pfcCloseStatus AND Core_MDF_Escalation_Id__c = null 
                                             AND Core_MDF_Type_Txt__c =: TYPE_CLAIM                                                     
                                             AND (Core_MDF_Budget_Type_Options_Nm__c IN: pfrBudgetType OR 
                                                  Request.Core_MDF_Program__c IN: pfrProgramSpecific) 
                                             GROUP BY RequestId]) {      
                                             pfrID = (Id)pfcAmountMaps.get('Id');
                                             pfrReleasedAmount = (Decimal)pfcAmountMaps.get('amt');
                                             pfcMap.put(pfrID, pfrReleasedAmount);
        }
        //Iterating AggregateResult to get escalation amount and activity Id(requestId) 
        for(AggregateResult esc : [SELECT Core_MDF_Co_Marketing_Activity_id__c Id,sum(Core_MDF_Approved_Amount_amt__c)amt
                                   FROM Core_MDF_Escalation__c
                                   WHERE Core_MDF_Co_Marketing_Activity_id__c IN:pfrMap.keyset() AND Core_MDF_Escalation_Status_nm__c =: ESC_APPROVED_STATUS
                                   GROUP BY Core_MDF_Co_Marketing_Activity_id__c]){
                                    pfrID = (Id)esc.get('Id');
                                    pfrEscAmount = (Decimal)esc.get('amt');
                                    pfrToEscalationAmtMap.put(pfrID, pfrEscAmount); 
        }
        for(PartnerFundRequest pfrList :pfrMap.values()){
            Decimal pfrAmountToBeUpdated = 0.0;
            pfrgetId = pfrMap.get(pfrList.Id); 
            //Checking BudgetType for Opal
            if(pfrgetId != null && ((pfrBudgetType.contains(pfrgetId.Core_MDF_Budget_Type_nm__c)) 
                    || pfrProgramSpecific.contains(pfrgetId.Core_MDF_Program__c)))
            { 
                // Calculating PFR Amount [SUM(Claim Amount) + SUM(Excalation Amount)]
                if(!pfcMap.isEmpty() && pfcMap.containsKey(pfrgetId.Id)){
                    pfrAmountToBeUpdated =  pfrAmountToBeUpdated + pfcMap.get(pfrgetId.Id);
                }
                if(!pfrToEscalationAmtMap.isEmpty() && pfrToEscalationAmtMap.containsKey(pfrgetId.Id)){
                    pfrAmountToBeUpdated =  pfrAmountToBeUpdated + pfrToEscalationAmtMap.get(pfrgetId.Id);
                }
                if(pfrAmountToBeUpdated != null && pfrAmountToBeUpdated >= 0){  
                    checkPfrAmount = cmpBudgetType.contains(pfrgetId.Core_MDF_Budget_Type_nm__c) ? 0 : pfrAmountToBeUpdated;
                    //Check the Intel Contributon is greater equal to Activity amount
                    //Avoid Deeply Nested IF Statements
                    // Use ternary to determine the amount parameter
                    Decimal amountToUse = (checkPfrAmount <= pfrgetId.Core_MDF_Activity_Reimbursement_Amt_nbr__c) ? 
                        checkPfrAmount : pfrgetId.Core_MDF_Activity_Reimbursement_Amt_nbr__c;
                    
                    pfrClosureList.add(updatedPfr(pfrgetId, pfrClosureType, amountToUse));
                } else { 
                    // PFR Closed from Planned or RR Status 
                    pfrClosureList.add(updatedPfr(pfrgetId, pfrClosureType, 0));
                }
            } else {
                pfrClosureList.add(updatedPfr(pfrgetId, pfrClosureType, 0));
            }
        }
    }
    
    /****************************************************************************************************** 
    Method Name:        updatedPfr
    Description:        Create PFR Object record which needs to updated
    Added By:           Saikat Manna- 03/01/2023
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    Public static PartnerFundRequest updatedPfr(PartnerFundRequest pfr, String pfrClosureType, Decimal pfrAmount){
        PartnerFundRequest pfrToBeUpdated = new PartnerFundRequest();
        try{
            if(pfrAmount != null){
                pfrToBeUpdated.Amount = pfrAmount; 
            }
            pfrToBeUpdated.Core_MDF_Actual_closedt_beforeclosure_dt__c = pfr.Core_MDF_ToBeClosedDate__c; //Update - Actual Close Date before Manual closure
            pfrToBeUpdated.Core_MDF_ToBeClosedDate__c = System.today();
            pfrToBeUpdated.Core_MDF_Manual_Closure_Prior_Status_txt__c = pfr.Core_MDF_Fund_Request_Status__c;
            pfrToBeUpdated.Core_MDF_Fund_Request_Status__c = pfrActivityClosed;
            pfrToBeUpdated.Core_MDF_Activity_Closure_Type__c = pfrClosureType;
            pfrToBeUpdated.Id = pfr.Id;
        }
        catch (Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);throw e;
        }
        return pfrToBeUpdated;
    }
    /****************************************************************************************************** 
    Method Name:        isOutcomeBasedActivity
    Description:        Check whether given activity is Outcome-Based or not
    Added By:           Rishabh 30/01/2026
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    @AuraEnabled
    public static Boolean isOutcomeBasedActivity(String pfrId) {
        
        if(pfrId == null || pfrId == null){
            return false;
        }
        PartnerFundRequest pfr = [SELECT Core_MDF_Is_Outcome_Based_Ind__c FROM PartnerFundRequest WHERE Id = :pfrId LIMIT 1];
        return pfr.Core_MDF_Is_Outcome_Based_Ind__c;
    }
    
}