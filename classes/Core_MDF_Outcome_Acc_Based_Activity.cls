/*********************************************************************************************************************************************************************************
* Class Name  : Core_MDF_Outcome_Acc_Based_Activity 
* Test class : Core_MDF_Outcome_Acc_Based_Activity_Test
* Version     : 1.0 
* Created Date: 18-12-2025
* Modification Log :
* Developer                         Date                          Description
Accenture - Akash				18-12-2025				Account Percentage Allocation
**********************************************************************************************************************************************************************************/
public without sharing class Core_MDF_Outcome_Acc_Based_Activity {
    /**
     * @description Searches for accounts based on parent account ID and search key, excluding specified IDs
     * param parentAccountId The parent account ID to filter by
     * param searchKey The search term to match against account names
     * param excludeIds List of account IDs to exclude from results
     * return List<Account> List of matching accounts
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccounts(String parentAccountId,String searchKey,List<Id> excludeIds) {
        String searchPattern = '%' + searchKey + '%';
        List<Account> accounts = [Select Id, Name, ParentId From Account Where (Core_MDF_Parent_Fund_Account__c = :parentAccountId OR Id = :parentAccountId OR Core_MDF_Virtual_Corp_Account_Id__c = :parentAccountId) 
        and Name Like :searchPattern and Id Not In :excludeIds Order By Name];
        return accounts;
    }
    /**
     * @description Validates allocation information for multiple accounts against a specific budget
     * param budgetId The budget ID to check allocations against
     * param accountIds List of account IDs to validate
     * return Map<String, AllocationCheckResult> Map of account IDs to their allocation check results
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, AllocationCheckResult> validateAllAllocations(String budgetId, List<String> accountIds) {
        Map<String, AllocationCheckResult> results = new Map<String, AllocationCheckResult>();
        try {
            List<PartnerFundAllocation> allocations = [Select Id, BudgetId, ChannelPartnerId, Core_MDF_Available_Activity_Alloc_Amt__c From PartnerFundAllocation Where BudgetId = :budgetId And ChannelPartnerId IN :accountIds];
            Map<String, PartnerFundAllocation> allocationMap = new Map<String, PartnerFundAllocation>();
            for (PartnerFundAllocation allocation : allocations) {
                allocationMap.put(allocation.ChannelPartnerId, allocation);
            }
            for (String accountId : accountIds) {
                AllocationCheckResult result = new AllocationCheckResult();
                if (allocationMap.containsKey(accountId)) {
                    PartnerFundAllocation allocation = allocationMap.get(accountId);
                    result.allocationExists = true;
                    result.availableAmount = allocation.Core_MDF_Available_Activity_Alloc_Amt__c != null ? allocation.Core_MDF_Available_Activity_Alloc_Amt__c : 0;
                    result.hasZeroAmount = result.availableAmount == 0;
                } else {
                    result.allocationExists = false;
                    result.availableAmount = 0;
                    result.hasZeroAmount = false;
                }
                results.put(accountId, result);
            }   
        } catch (Exception e) {
            for (String accountId : accountIds) {
                AllocationCheckResult result = new AllocationCheckResult();
                result.allocationExists = false;
                result.availableAmount = 0;
                result.hasZeroAmount = false;
                results.put(accountId, result);
            }
        }
        return results;
    }
    /**
     * @description Saves account allocations for a specific activity, creating sub-activities and account mappings
     * param activityId The ID of the parent activity
     * param accountAllocationValues Object containing account allocation data
     */
    @AuraEnabled
    public static void saveAccountAllocations(Id activityId, Object accountAllocationValues) {
        try {
            PartnerFundRequest parentActivity = [Select Id, Title, Core_MDF_Activity_Description__c, Core_MDF_Start_Date__c, Core_MDF_End_Date__c, Core_MDF_Focus_Area_nm__c, RecordTypeId, Core_MDF_Budget_Type_nm__c, Core_MDF_Maximum_Intel_Investment_amt__c, Core_MDF_Country_nm__c, Core_MDF_Brand_nm__c, Core_MDF_Tactics_nm__c,Core_MDF_TargetAudience_nm__c, Core_MDF_Initiative_nm__c,Core_MDF_EcosystemPartner_nm__c, Core_MDF_Technology_txt__c,Core_MDF_Outcomes_nm__c, Core_MDF_Priority_nm__c, Core_MDF_Priority_2_nm__c,
                Core_MDF_ProductType__c,Core_MDF_BU_Split__c,Core_MDF_BU1_Split_Percent_nbr__c,Core_MDF_Activity_Number__c , Core_MDF_Outcome_Region_nm__c, Core_MDF_Fund_Request_Status__c, RequestedAmount, AllocationId, Status, Core_MDF_Reimbursement_Rate_txt__c,Core_MDF_Budget_Amount_Local_amt__c,Core_MDF_Exchange_Rate_ptc__c,Core_MDF_Region_nm__c From PartnerFundRequest Where Id = :activityId];
            List<AccountAllocationWrapper> wrapperList =(List<AccountAllocationWrapper>) JSON.deserialize(JSON.serialize(accountAllocationValues),List<AccountAllocationWrapper>.class);
            
            List<PartnerFundRequest> createdSubActivities = createNodeActivities(parentActivity, wrapperList);
            processAccountMappings(activityId, wrapperList, createdSubActivities);
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description Processes account mappings by creating or updating Core_MDF_Outcome_Account_Mapping__c records
     * param activityId The parent activity ID
     * param wrapperList List of account allocation wrappers
     * param subActivities List of created sub-activities for mapping reference
     */
    private static void processAccountMappings(Id activityId, List<AccountAllocationWrapper> wrapperList, List<PartnerFundRequest> subActivities) {
        Map<String, Core_MDF_Outcome_Account_Mapping__c> existingMap = new Map<String, Core_MDF_Outcome_Account_Mapping__c>();
        List<Core_MDF_Outcome_Account_Mapping__c> recordsToUpsert = new List<Core_MDF_Outcome_Account_Mapping__c>();
        Set<String> incomingAccountIds = new Set<String>();
        
        // Create map of account ID to sub-activity ID for reliable matching
        Map<String, Id> accountToSubActivityMap = new Map<String, Id>();
        if (subActivities != null) {
            for (PartnerFundRequest subActivity : subActivities) {
                if (String.isNotBlank(subActivity.ChannelPartnerId)) {
                    accountToSubActivityMap.put(subActivity.ChannelPartnerId, subActivity.Id);
                }
            }
        }
        
        for (Core_MDF_Outcome_Account_Mapping__c existing : [Select Id, Core_MDF_AccountId__c, Core_MDF_Percentage_pct__c, Core_MDF_Amount_nbr__c, Core_MDF_Active_Ind__c From Core_MDF_Outcome_Account_Mapping__c Where Core_MDF_Outcome_Based_CampaignId__c = :activityId]) {
            if (existing.Core_MDF_AccountId__c != null) {
                existingMap.put(existing.Core_MDF_AccountId__c,existing);
            }
        }
        if (wrapperList != null && !wrapperList.isEmpty()) {
            for (AccountAllocationWrapper wrap : wrapperList) {
                if (String.isNotBlank(wrap.accountId)) {
                    incomingAccountIds.add(wrap.accountId);                   
                    Core_MDF_Outcome_Account_Mapping__c record;
                    if (existingMap.containsKey(wrap.accountId)) {
                        record = existingMap.get(wrap.accountId); 
                    } else {
                        record = new Core_MDF_Outcome_Account_Mapping__c();
                        record.Core_MDF_Outcome_Based_CampaignId__c = activityId;
                        record.Core_MDF_AccountId__c = wrap.accountId;
                    }
                    record.Core_MDF_Percentage_pct__c = wrap.percent;
                    record.Core_MDF_Amount_nbr__c = wrap.amount;
                    record.Core_MDF_Active_Ind__c = true;
                    
                    // Set sub-activity ID using the map for reliable matching
                    if (accountToSubActivityMap.containsKey(wrap.accountId)) {
                        record.Core_MDF_OutcomeBased_SubAct_Id__c = accountToSubActivityMap.get(wrap.accountId);
                    }
                    
                    recordsToUpsert.add(record);
                }
            }
        }
        for (Core_MDF_Outcome_Account_Mapping__c existing : existingMap.values()) {
            if (!incomingAccountIds.contains(existing.Core_MDF_AccountId__c) && existing.Core_MDF_Active_Ind__c) {
                existing.Core_MDF_Active_Ind__c = false; 
                recordsToUpsert.add(existing);
            }
        }
        if (!recordsToUpsert.isEmpty()) {
            upsert recordsToUpsert;
        }
    }
    /**
     * @description Creates or updates node activities (sub-activities) based on parent activity and account allocations
     * @=param parentActivity The parent PartnerFundRequest record
     * @=param wrapperList List of account allocation wrappers
     * return List<PartnerFundRequest> List of created/updated sub-activities
     */
    private static List<PartnerFundRequest> createNodeActivities(PartnerFundRequest parentActivity, List<AccountAllocationWrapper> wrapperList) {
        Map<String, PartnerFundRequest> existingNodeActivities = new Map<String, PartnerFundRequest>();
        // Get existing sub-activities with their current status
        for (PartnerFundRequest nodeActivity : [
            Select Id, ChannelPartnerId, Core_MDF_Parent_Activity_Id__c, Core_MDF_Fund_Request_Status__c, Status, Amount, Core_MDF_Maximum_Intel_Investment_amt__c, AllocationId, Core_MDF_Is_Outcome_Based_Ind__c, Core_MDF_Activity_Level_nm__c From PartnerFundRequest Where Core_MDF_Parent_Activity_Id__c = :parentActivity.Id]) {
            existingNodeActivities.put(nodeActivity.ChannelPartnerId, nodeActivity);  
        }
        Map<String, Id> accountToAllocationMap = getAccountAllocationsMap(parentActivity, wrapperList);
        List<PartnerFundRequest> nodeActivitiesToUpsert = new List<PartnerFundRequest>();
        List<PartnerFundRequest> nodeActivitiesToDelete = new List<PartnerFundRequest>();
        Set<String> activeAccountIds = new Set<String>();
        for (AccountAllocationWrapper wrap : wrapperList) {
            if (String.isNotBlank(wrap.accountId)) {
                activeAccountIds.add(wrap.accountId);
                PartnerFundRequest nodeActivity;
                if (existingNodeActivities.containsKey(wrap.accountId)) {
                    PartnerFundRequest existingActivity = existingNodeActivities.get(wrap.accountId);   
                    // Check if this is a reactivation (was previously cancelled/deactivated)
                    if (existingActivity.Core_MDF_Fund_Request_Status__c == 'Cancelled'){  
                        // For reactivation, delete the old record and create a new one
                        // This ensures proper allocation recalculation
                        nodeActivitiesToDelete.add(new PartnerFundRequest(Id = existingActivity.Id));
                        nodeActivity = createNodeActivityFromParent(parentActivity, wrap);
                    } else {
                        // Active account - just update amounts
                        nodeActivity = existingActivity;
                    }
                } else {
                    // New account
                    nodeActivity = createNodeActivityFromParent(parentActivity, wrap);
                }
                // Set allocation ID
                if (accountToAllocationMap.containsKey(wrap.accountId)) {
                    nodeActivity.AllocationId = accountToAllocationMap.get(wrap.accountId);
                }   
                // Set amounts and ensure proper status
                if (wrap.amount != null) {
                    nodeActivity.Core_MDF_Maximum_Intel_Investment_amt__c = wrap.amount;
                    nodeActivity.Amount = wrap.amount;
                    nodeActivity.RequestedAmount = wrap.amount;
                }
                // Ensure active status
                nodeActivity.Core_MDF_Fund_Request_Status__c = parentActivity.Core_MDF_Fund_Request_Status__c;
                nodeActivity.Status = parentActivity.Status;
                nodeActivity.Core_MDF_Is_Outcome_Based_Ind__c = true;
                nodeActivity.Core_MDF_Activity_Level_nm__c = 'Sub Activity';
                nodeActivitiesToUpsert.add(nodeActivity);
            }
        }
        // Handle deactivation/cancellation of removed accounts
        for (String existingAccountId : existingNodeActivities.keySet()) {
            if (!activeAccountIds.contains(existingAccountId)) {
                PartnerFundRequest nodeToDeactivate = existingNodeActivities.get(existingAccountId);
                // Only deactivate if not already deactivated
                if (nodeToDeactivate.Core_MDF_Fund_Request_Status__c != 'Cancelled') {
                    nodeToDeactivate.Core_MDF_Fund_Request_Status__c = 'Cancelled';
                    nodeToDeactivate.Amount = 0;
                    nodeActivitiesToUpsert.add(nodeToDeactivate);
                }
            }
        }
        // Delete old deactivated records first (for reactivation cases)
        if (!nodeActivitiesToDelete.isEmpty()) {
            delete nodeActivitiesToDelete;
        }
        // Then upsert the active records
        if (!nodeActivitiesToUpsert.isEmpty()) {
            upsert nodeActivitiesToUpsert;
        }
        return nodeActivitiesToUpsert;
    }
    /**
     * @description Creates a new node activity (sub-activity) from parent activity data and account allocation wrapper
     * param parentActivity The parent PartnerFundRequest record to copy data from
     * param wrap The account allocation wrapper containing account-specific data
     * return PartnerFundRequest New sub-activity record with parent's data
     */
    private static PartnerFundRequest createNodeActivityFromParent(PartnerFundRequest parentActivity, AccountAllocationWrapper wrap) {
            PartnerFundRequest nodeActivity = new PartnerFundRequest();
            String subActivityTitle = '';
            if (String.isNotBlank(parentActivity.Core_MDF_Activity_Number__c)) {
                subActivityTitle = parentActivity.Core_MDF_Activity_Number__c + ' - ';
            }
            if (String.isNotBlank(parentActivity.Title)) {
                subActivityTitle += parentActivity.Title;
            }
            nodeActivity.Title = subActivityTitle;
            nodeActivity.Core_MDF_Activity_Description__c = parentActivity.Core_MDF_Activity_Description__c;
            nodeActivity.Core_MDF_Start_Date__c = parentActivity.Core_MDF_Start_Date__c;
            nodeActivity.Core_MDF_End_Date__c = parentActivity.Core_MDF_End_Date__c;
            nodeActivity.Core_MDF_Focus_Area_nm__c = parentActivity.Core_MDF_Focus_Area_nm__c;
            nodeActivity.RecordTypeId = parentActivity.RecordTypeId;
            nodeActivity.Core_MDF_Budget_Type_nm__c = parentActivity.Core_MDF_Budget_Type_nm__c;
            nodeActivity.ChannelPartnerId = wrap.accountId;
            nodeActivity.Core_MDF_Parent_Activity_Id__c = parentActivity.Id;
            nodeActivity.Core_MDF_Is_Outcome_Based_Ind__c = true;
            nodeActivity.Core_MDF_Fund_Request_Status__c = parentActivity.Core_MDF_Fund_Request_Status__c;
            nodeActivity.Core_MDF_Activity_Level_nm__c = 'Sub Activity';
            nodeActivity.Core_MDF_Country_nm__c = parentActivity.Core_MDF_Country_nm__c;
            nodeActivity.Core_MDF_Brand_nm__c = parentActivity.Core_MDF_Brand_nm__c;
            nodeActivity.Core_MDF_Tactics_nm__c = parentActivity.Core_MDF_Tactics_nm__c;
            nodeActivity.Core_MDF_TargetAudience_nm__c = parentActivity.Core_MDF_TargetAudience_nm__c;
            nodeActivity.Core_MDF_Initiative_nm__c = parentActivity.Core_MDF_Initiative_nm__c;
            nodeActivity.Core_MDF_EcosystemPartner_nm__c = parentActivity.Core_MDF_EcosystemPartner_nm__c;
            nodeActivity.Core_MDF_Technology_txt__c = parentActivity.Core_MDF_Technology_txt__c;
            nodeActivity.Core_MDF_Outcomes_nm__c = parentActivity.Core_MDF_Outcomes_nm__c;
            nodeActivity.Core_MDF_Priority_nm__c = parentActivity.Core_MDF_Priority_nm__c;
            nodeActivity.Core_MDF_Priority_2_nm__c = parentActivity.Core_MDF_Priority_2_nm__c;
            nodeActivity.Core_MDF_ProductType__c = parentActivity.Core_MDF_ProductType__c;
            nodeActivity.Core_MDF_BU_Split__c = parentActivity.Core_MDF_BU_Split__c;
            nodeActivity.Core_MDF_BU1_Split_Percent_nbr__c = parentActivity.Core_MDF_BU1_Split_Percent_nbr__c;
            nodeActivity.Core_MDF_Outcome_Region_nm__c = parentActivity.Core_MDF_Outcome_Region_nm__c;
            nodeActivity.RequestedAmount = parentActivity.RequestedAmount;
            nodeActivity.OwnerId = System.Label.Core_MDF_Bypass_FLAO_UserIsactive;
            nodeActivity.Status = parentActivity.Status;
            nodeActivity.Core_MDF_Reimbursement_Rate_txt__c = parentActivity.Core_MDF_Reimbursement_Rate_txt__c;
            nodeActivity.Core_MDF_Exchange_Rate_ptc__c = parentActivity.Core_MDF_Exchange_Rate_ptc__c;
            nodeActivity.Core_MDF_Budget_Amount_Local_amt__c = parentActivity.Core_MDF_Budget_Amount_Local_amt__c;
            nodeActivity.Core_MDF_Region_nm__c = parentActivity.Core_MDF_Region_nm__c;
            return nodeActivity;
    }
    /**
     * @description Gets mapping of account IDs to their corresponding allocation IDs based on budget matching
     * param parentActivity The parent activity containing the budget reference
     * param wrapperList List of account allocation wrappers
     * return Map<String, Id> Map of account IDs to allocation IDs
     */
    private static Map<String, Id> getAccountAllocationsMap(PartnerFundRequest parentActivity, List<AccountAllocationWrapper> wrapperList) {
        Map<String, Id> accountToAllocationMap = new Map<String, Id>();
        try {
            Set<String> accountIds = new Set<String>();
            for (AccountAllocationWrapper wrap : wrapperList) {
                if (String.isNotBlank(wrap.accountId)) {
                    accountIds.add(wrap.accountId);
                }
            }
            // Add parent allocation ID to the account IDs set for single query
            Set<Id> allAllocationIds = new Set<Id>{parentActivity.AllocationId};
            // Single query to get both parent allocation and target allocations
            List<PartnerFundAllocation> allAllocations = [Select Id, ChannelPartnerId, BudgetId From PartnerFundAllocation Where (Id = :parentActivity.AllocationId) Or (ChannelPartnerId In :accountIds)];
            // Find the budget ID from parent allocation
            String budgetId = null;
            for (PartnerFundAllocation allocation : allAllocations) {
                if (allocation.Id == parentActivity.AllocationId) {
                    budgetId = allocation.BudgetId;
                    break;
                }
            }
            
            // Build the map for allocations with matching budget ID
            if (budgetId != null) {
                for (PartnerFundAllocation allocation : allAllocations) {
                    if (allocation.BudgetId == budgetId && String.isNotBlank(allocation.ChannelPartnerId) && accountIds.contains(allocation.ChannelPartnerId)) {
                        accountToAllocationMap.put(allocation.ChannelPartnerId, allocation.Id);
                    }
                }
            }
        } catch (Exception e) {
        } 
        return accountToAllocationMap;
    }
    /**
     * @description Handles updates to parent activities by synchronizing changes to their sub-activities
     * param newMap Map of updated PartnerFundRequest records (new values)
     * param oldMap Map of PartnerFundRequest records before update (old values)
     */
    public static void handleParentActivityUpdates(Map<Id, PartnerFundRequest> newMap, Map<Id, PartnerFundRequest> oldMap) {
        Set<Id> parentActivityIds = new Set<Id>();       
        try {
            // Identify parent activities that were updated
            for (Id activityId : newMap.keySet()) {
                PartnerFundRequest newActivity = newMap.get(activityId);
                PartnerFundRequest oldActivity = oldMap.get(activityId);               
                // Check if this is a parent outcome-based activity and if relevant fields changed
                if (isParentOutcomeBasedActivity(newActivity) && hasRelevantFieldsChanged(newActivity, oldActivity)) {
                    parentActivityIds.add(activityId);
                }
            } 
            if (!parentActivityIds.isEmpty()) {
                updateSubActivitiesFromParents(parentActivityIds, newMap);
            }
        } catch (Exception e) {
            // Don't throw exception in trigger context to avoid blocking parent update
        }
    }
    /**
     * @description Check if the activity is a parent outcome-based activity
     * param activity The PartnerFundRequest record to check
     * return Boolean True if it's a parent outcome-based activity
     */
    private static Boolean isParentOutcomeBasedActivity(PartnerFundRequest activity) {
        return (activity.Core_MDF_Is_Outcome_Based_Ind__c == true && (activity.Core_MDF_Activity_Level_nm__c == null || activity.Core_MDF_Activity_Level_nm__c != 'Sub Activity'));
    }
    /**
     * @description Check if relevant fields have changed between old and new versions
     * param newActivity The updated PartnerFundRequest record
     * param oldActivity The original PartnerFundRequest record
     * return Boolean True if any relevant fields have changed
     */
    private static Boolean hasRelevantFieldsChanged(PartnerFundRequest newActivity, PartnerFundRequest oldActivity) {
        return (
            newActivity.Title != oldActivity.Title ||
            newActivity.Core_MDF_Activity_Description__c != oldActivity.Core_MDF_Activity_Description__c ||
            newActivity.Core_MDF_Start_Date__c != oldActivity.Core_MDF_Start_Date__c ||
            newActivity.Core_MDF_End_Date__c != oldActivity.Core_MDF_End_Date__c ||
            newActivity.Core_MDF_Focus_Area_nm__c != oldActivity.Core_MDF_Focus_Area_nm__c ||
            newActivity.Core_MDF_Budget_Type_nm__c != oldActivity.Core_MDF_Budget_Type_nm__c ||
            newActivity.Core_MDF_Country_nm__c != oldActivity.Core_MDF_Country_nm__c ||
            newActivity.Core_MDF_Brand_nm__c != oldActivity.Core_MDF_Brand_nm__c ||
            newActivity.Core_MDF_Tactics_nm__c != oldActivity.Core_MDF_Tactics_nm__c ||
            newActivity.Core_MDF_TargetAudience_nm__c != oldActivity.Core_MDF_TargetAudience_nm__c ||
            newActivity.Core_MDF_Initiative_nm__c != oldActivity.Core_MDF_Initiative_nm__c ||
            newActivity.Core_MDF_EcosystemPartner_nm__c != oldActivity.Core_MDF_EcosystemPartner_nm__c ||
            newActivity.Core_MDF_Technology_txt__c != oldActivity.Core_MDF_Technology_txt__c ||
            newActivity.Core_MDF_Outcomes_nm__c != oldActivity.Core_MDF_Outcomes_nm__c ||
            newActivity.Core_MDF_Priority_nm__c != oldActivity.Core_MDF_Priority_nm__c ||
            newActivity.Core_MDF_Priority_2_nm__c != oldActivity.Core_MDF_Priority_2_nm__c ||
            newActivity.Core_MDF_ProductType__c != oldActivity.Core_MDF_ProductType__c ||
            newActivity.Core_MDF_Outcome_Region_nm__c != oldActivity.Core_MDF_Outcome_Region_nm__c ||
            newActivity.Core_MDF_Fund_Request_Status__c != oldActivity.Core_MDF_Fund_Request_Status__c ||
            newActivity.Core_MDF_BU_Split__c != oldActivity.Core_MDF_BU_Split__c ||
            newActivity.Core_MDF_Reimbursement_Rate_txt__c != oldActivity.Core_MDF_Reimbursement_Rate_txt__c ||
            newActivity.Core_MDF_Exchange_Rate_ptc__c != oldActivity.Core_MDF_Exchange_Rate_ptc__c ||
            newActivity.Core_MDF_Budget_Amount_Local_amt__c != oldActivity.Core_MDF_Budget_Amount_Local_amt__c ||
            newActivity.RequestedAmount != oldActivity.RequestedAmount ||
            newActivity.Core_MDF_Region_nm__c != oldActivity.Core_MDF_Region_nm__c
        );
    }

    /**
     * @description Update sub-activities based on parent activity changes
     * param parentActivityIds Set of parent activity IDs that were updated
     * param parentActivitiesMap Map of updated parent activities
     */
    private static void updateSubActivitiesFromParents(Set<Id> parentActivityIds, Map<Id, PartnerFundRequest> parentActivitiesMap) {
        try {
            // Get all sub-activities for the updated parents
            List<PartnerFundRequest> subActivities = [SELECT Id, Core_MDF_Parent_Activity_Id__c, ChannelPartnerId, Core_MDF_Maximum_Intel_Investment_amt__c, Amount, RequestedAmount FROM PartnerFundRequest WHERE Core_MDF_Parent_Activity_Id__c IN :parentActivityIds AND Core_MDF_Fund_Request_Status__c != 'Cancelled' AND Core_MDF_Activity_Level_nm__c = 'Sub Activity'];
            if (!subActivities.isEmpty()) {
                List<PartnerFundRequest> subActivitiesToUpdate = new List<PartnerFundRequest>(); 
                for (PartnerFundRequest subActivity : subActivities) {
                    PartnerFundRequest parentActivity = parentActivitiesMap.get(subActivity.Core_MDF_Parent_Activity_Id__c);
                    if (parentActivity != null) {
                        PartnerFundRequest updatedSubActivity = createUpdatedSubActivity(parentActivity, subActivity);
                        subActivitiesToUpdate.add(updatedSubActivity);
                    }
                }
                if (!subActivitiesToUpdate.isEmpty()) {
                    String jsonData = JSON.serialize(subActivitiesToUpdate);
                    updateSubActivitiesAsync(jsonData);
                }
            }
        } catch (Exception e) {
            // Log error but don't throw to avoid blocking parent update
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    /*****************************************************************************************************************************************
    Method Name:                                             updateSubActivitiesAsync
    @return  :                                               void
    @parameters:                                             String jsonData - JSON serialized list of PartnerFundRequest sub-activities
    Description:                                             Asynchronously updates sub-activity records using Queueable interface 
                                                        to avoid SOQL 101 errors in trigger context and support batch job execution.
                                                        Processes updates in batches to stay within DML governor limits.
    Modifies :                                              Updates sub-activity records with synchronized field values from parent activities.
    **************************************************************************************************************************************************/
    public static void updateSubActivitiesAsync(String jsonData) {
        try {
            System.enqueueJob(new UpdateSubActivitiesQueueable(jsonData));
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }

    /*****************************************************************************************************************************************
    Class Name:                                              UpdateSubActivitiesQueueable
    Description:                                             Queueable class for asynchronously updating sub-activities.
                                                        Can be called from triggers, batches, and other async contexts.
    **************************************************************************************************************************************************/
    public class UpdateSubActivitiesQueueable implements Queueable {
        private String jsonData;

        public UpdateSubActivitiesQueueable(String jsonData) {
            this.jsonData = jsonData;
        }

        public void execute(QueueableContext context) {
            try {
                List<PartnerFundRequest> subActivitiesToUpdate = (List<PartnerFundRequest>) JSON.deserialize(jsonData, List<PartnerFundRequest>.class);
                if (subActivitiesToUpdate.isEmpty()) return;

                // Re-query current status to avoid editing already-Cancelled records (race condition guard)
                Set<Id> subActivityIds = new Map<Id, PartnerFundRequest>(subActivitiesToUpdate).keySet();
                Map<Id, String> currentStatusMap = new Map<Id, String>();
                for (PartnerFundRequest pfr : [SELECT Id, Core_MDF_Fund_Request_Status__c FROM PartnerFundRequest WHERE Id IN :subActivityIds]) {
                    currentStatusMap.put(pfr.Id, pfr.Core_MDF_Fund_Request_Status__c);
                }

                List<PartnerFundRequest> filteredList = new List<PartnerFundRequest>();
                for (PartnerFundRequest sub : subActivitiesToUpdate) {
                    String currentStatus = currentStatusMap.get(sub.Id);
                    // Skip if already Cancelled — goal is achieved, editing would violate validation rule
                    if (currentStatus != 'Cancelled') {
                        filteredList.add(sub);
                    }
                }

                if (!filteredList.isEmpty()) {
                    update filteredList;
                }
            } catch (Exception e) {
                Core_MDF_CCP_UtilityClass.logError(e);
            }
        }
    }

    /**
     * @description Create updated sub-activity record with parent's field values
     * param parentActivity The parent activity with updated values
     * param subActivity The existing sub-activity to update
     * return PartnerFundRequest Updated sub-activity record
     */
    private static PartnerFundRequest createUpdatedSubActivity(PartnerFundRequest parentActivity, PartnerFundRequest subActivity) {
        PartnerFundRequest updatedSubActivity = new PartnerFundRequest();
        updatedSubActivity.Id = subActivity.Id;
        // Sync all fields from parent to sub-activity (excluding account-specific fields)
         String subActivityTitle = '';
        if (String.isNotBlank(parentActivity.Core_MDF_Activity_Number__c)) {
            subActivityTitle = parentActivity.Core_MDF_Activity_Number__c + ' - ';
        }
        if (String.isNotBlank(parentActivity.Title)) {
            subActivityTitle += parentActivity.Title;
        }
        updatedSubActivity.Title = subActivityTitle;
        updatedSubActivity.Core_MDF_Activity_Description__c = parentActivity.Core_MDF_Activity_Description__c;
        updatedSubActivity.Core_MDF_Start_Date__c = parentActivity.Core_MDF_Start_Date__c;
        updatedSubActivity.Core_MDF_End_Date__c = parentActivity.Core_MDF_End_Date__c;
        updatedSubActivity.Core_MDF_Focus_Area_nm__c = parentActivity.Core_MDF_Focus_Area_nm__c;
        updatedSubActivity.Core_MDF_Budget_Type_nm__c = parentActivity.Core_MDF_Budget_Type_nm__c;
        updatedSubActivity.Core_MDF_Country_nm__c = parentActivity.Core_MDF_Country_nm__c;
        updatedSubActivity.Core_MDF_Brand_nm__c = parentActivity.Core_MDF_Brand_nm__c;
        updatedSubActivity.Core_MDF_Tactics_nm__c = parentActivity.Core_MDF_Tactics_nm__c;
        updatedSubActivity.Core_MDF_TargetAudience_nm__c = parentActivity.Core_MDF_TargetAudience_nm__c;
        updatedSubActivity.Core_MDF_Initiative_nm__c = parentActivity.Core_MDF_Initiative_nm__c;
        updatedSubActivity.Core_MDF_EcosystemPartner_nm__c = parentActivity.Core_MDF_EcosystemPartner_nm__c;
        updatedSubActivity.Core_MDF_Technology_txt__c = parentActivity.Core_MDF_Technology_txt__c;
        updatedSubActivity.Core_MDF_Outcomes_nm__c = parentActivity.Core_MDF_Outcomes_nm__c;
        updatedSubActivity.Core_MDF_Priority_nm__c = parentActivity.Core_MDF_Priority_nm__c;
        updatedSubActivity.Core_MDF_Priority_2_nm__c = parentActivity.Core_MDF_Priority_2_nm__c;
        updatedSubActivity.Core_MDF_ProductType__c = parentActivity.Core_MDF_ProductType__c;
        updatedSubActivity.Core_MDF_Outcome_Region_nm__c = parentActivity.Core_MDF_Outcome_Region_nm__c;
        updatedSubActivity.Core_MDF_Fund_Request_Status__c = parentActivity.Core_MDF_Fund_Request_Status__c;
        updatedSubActivity.Core_MDF_BU_Split__c = parentActivity.Core_MDF_BU_Split__c;
        updatedSubActivity.Core_MDF_Reimbursement_Rate_txt__c = parentActivity.Core_MDF_Reimbursement_Rate_txt__c;
        updatedSubActivity.Core_MDF_Exchange_Rate_ptc__c = parentActivity.Core_MDF_Exchange_Rate_ptc__c;
        updatedSubActivity.Core_MDF_Budget_Amount_Local_amt__c = parentActivity.Core_MDF_Budget_Amount_Local_amt__c;
        updatedSubActivity.RequestedAmount = parentActivity.RequestedAmount;
        updatedSubActivity.Core_MDF_Region_nm__c = parentActivity.Core_MDF_Region_nm__c;
        return updatedSubActivity;
    }

    /**
     * @description Retrieves stored account allocations for a specific activity
     * param activityId The ID of the activity to get allocations for
     * return List<AccountAllocationWrapper> List of account allocation wrappers with stored data
     */
    @AuraEnabled(cacheable=true)
    public static List<AccountAllocationWrapper> getStoredAccountAllocations(Id activityId) {
        List<AccountAllocationWrapper> results = new List<AccountAllocationWrapper>();
        for (Core_MDF_Outcome_Account_Mapping__c rec : [Select Id,Core_MDF_AccountId__c,Core_MDF_AccountId__r.Name,Core_MDF_Percentage_pct__c,Core_MDF_Amount_nbr__c From Core_MDF_Outcome_Account_Mapping__c Where Core_MDF_Outcome_Based_CampaignId__c = :activityId And Core_MDF_Active_Ind__c = true]) {
            AccountAllocationWrapper wrap = new AccountAllocationWrapper();
            wrap.accountId = rec.Core_MDF_AccountId__c;
            wrap.accountName = rec.Core_MDF_AccountId__r.Name;
            wrap.percent = rec.Core_MDF_Percentage_pct__c;
            wrap.amount = rec.Core_MDF_Amount_nbr__c;
            results.add(wrap);
        }
        return results;
    }

    public class AccountAllocationWrapper {
        @AuraEnabled public String accountId { get; set; }
        @AuraEnabled public String accountName { get; set; }
        @AuraEnabled public Decimal percent { get; set; }
        @AuraEnabled public Decimal amount { get; set; }
    }

    public class AllocationCheckResult {
        @AuraEnabled public Boolean allocationExists { get; set; }
        @AuraEnabled public Decimal availableAmount { get; set; }
        @AuraEnabled public Boolean hasZeroAmount { get; set; }
        
        public AllocationCheckResult() {
            this.allocationExists = false;
            this.availableAmount = 0;
            this.hasZeroAmount = false;
        }
    }
}